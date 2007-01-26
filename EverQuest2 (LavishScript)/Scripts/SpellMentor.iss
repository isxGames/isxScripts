;  	SpellMentor version 1.0 
;  	written by Hendrix and RogueTexan
;	March 25, 2006
;
;

;  	The following program makes the mentoring of spell series up and down the levels easier and consistent.
;  	Basically, the objective is to automate the coding of a spell series across levels.  For instance, you could
;	have a level 70 character (with many scribed spells) and only program in the EQ2bot spells from level 60-70 and then run this script and it would
;	'backwards' code the spells at earlier levels all the way down to level 1.  All it requires is that you have at least one
;	spell in the series coded for EQ2bot.  Or, you could have only the lowest level spells in a spell series coded and it will
;	mentor UP the series.

;  We would like individuals with 70th level characters with lots of scribed spells to run this script and post the generated files.
;  Output to post is:  YourClass_list.xml and YourClass_Bld_List.xml
;
;  This way we can post more complete spell lists for people and make things easier for people to share spell lists.

;  In running this program BE PATIENT and follow the output dialog.  Some of the steps take a long time (minute or so).
;
;  To run the script:

;	Preparation:
;	1. Place SpellMentor.iss in the same folder as EQ2bot.iss
;	2. Make sure you have a spell list appropriate for the character class you want to mentor (in InnerSpace\Scripts\EQ2Bot\Spell List folder). 
;	3. Make sure each spell class has at least one code designation as per EQ2bot.
;	4. Optional:  turn on EQ2 output logging to follow output stream of events (can be useful later to understand spell set changes that have occurred).

;	Running:
;	1. Start your character to fully logged on screen.
;	2. Open your spell book.  Sort on spells 'by level'.
;	3. Close spell book.
;	4. Make sure ISXEQ2 is running.
;	5. Type /runscript spellmentor.iss
;	6. WAIT and be PATIENT for output to end (will say "MENTORING FINISHED!!").  
;	7. Open Class_Bld_list.xml with text editor.  Check changes that have occurred.
;	8. Once you have checked/approved the changes that have occurred to spell numbers, change name of "Class_Bld_list.xml" to "Class.xml"



;	What is going on behind the scenes:

;	1.  First part of the program is collecting spell information on all scribed spells.
;	2.	Classifiers are used to group spell series across levels.  Creates Class_list.xml file with icon referencing.
;	3.  Mentoring section looks at all spells you have currently in your Class.xml, starts from the LOWEST level spells and reads up the list.  
;		Based on the first time it sees a non-zero (between 1 and 400) code for a spell (as per Blazer's EQ2bot) it then cross-references all
;		spells further UP AND DOWN the list in that series to have the same code.
;	4.	Program then MERGES the spell list in your Class.xml with the ICON list, so you have a complete list of your scribed spells and the spells you have in the Class.xml file.
;	5.  Program then outputs a file that is the mentored and merged file:  Class_Bld_list.xml 

;	You can then go in and determine if you had conflicts or other things missing.  Nothing is changed in your original Class.xml

;  	Again, BE PATIENT.  It's a rather verbose program and is doing a lot of sorting.  Must be run from within the class you are mentoring.  You can follow progress in eq2echo output tab.

;  I have found this program very useful to figure out where I had mistakes in my Class.xml file.  
;  By comparing Class.xml to the created Class_list.xml and Class_Bld_list.xml you can determine consistency, patch holes, etc. 



function main(string ma, string param1, string param2)
{

	declare xmlpath string script "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Spell List" 
	declare spellfileB string script
	declare spellfileH string script
	
	declare SpellBlzName[400] string script "EMPTY"
	declare SpellBlzLvl[400] int script 0 
	declare SpellNum[400] int script 0
	
	declare SpellHnxName[400] string script "EMPTY"
	declare SpellHnxLvl[400] int script 0
	declare SpellIcon[400] int script 0
	
	declare NewBlzNum[400] int script 0

	declare NewHnxName[400] string script "EMPTY"
	declare NewHnxLvl[400] int script 0
	declare NewIcon[400] int script 0	
	
	declare newtemp int local 0
	
	declare BlzSpellnum int script 0
	declare HnxSpellnum int script 0
	
	
	
		SettingXML[${xmlpath}/${Me.SubClass}_Bld_List.xml]:Unload 
		eq2echo Starting SpellMentor!!
		echo Starting SpellMentor!!!
		
		; Make Icon-Spell List from current character 
		eq2echo Starting Icon referencing of character ("${Me.SubClass}") spells scribed.
		call HndrxIcon
		wait 50
		eq2echo Starting mentoring of spells.
		eq2echo Read current "${Me.SubClass}" spell list.
		
		spellfileB:Set[${xmlpath}/${Me.SubClass}.xml]
		call GetBlzSpells "${Me.SubClass}"

		eq2echo Read current "${Me.SubClass}" icon list.
		spellfileH:Set[${xmlpath}/${Me.SubClass}_list.xml]
		call GetHnxSpells "${Me.SubClass}"	
		
		eq2echo Merge the lists.
		call MergeLists
		eq2echo Sort the lists.
		call SortUp
		
	newtemp:Set[1]
	do
	{
		;eq2echo ${newtemp}:  ${SpellBlzLvl[${newtemp}]} ${SpellBlzName[${newtemp}]}  ${SpellNum[${newtemp}]} ${NewBlzNum[${newtemp}]}
	}
	while ${newtemp:Inc}<=${BlzSpellnum}	
		
		eq2echo Save the new list as ${Me.SubClass}_Bld_List.xml
		call WriteNewBlz
		eq2echo MENTORING FINISHED!!

}


function WriteNewBlz()
{
declare tempvar int local 1
	SettingXML[${xmlpath}/${Me.SubClass}_Bld_List.xml]:Unload 
   do 
   { 
     SettingXML[${xmlpath}/${Me.SubClass}_Bld_List.xml].Set[${Me.SubClass}]:Set["${SpellBlzLvl[${tempvar}]},${SpellNum[${tempvar}]}",${SpellBlzName[${tempvar}]}] 
   } 
   while ${tempvar:Inc} <= ${BlzSpellnum} 
    
   SettingXML[${xmlpath}/${Me.SubClass}_Bld_List.xml]:Save 
   SettingXML[${xmlpath}/${Me.SubClass}_Bld_List.xml]:Unload 
   
}

function GetBlzSpells(string class)
{
	declare keycount int local
	declare tempnme string local
	declare tempvar int local 1

    SettingXML[${xmlpath}/${Me.SubClass}.xml]:Unload 
	keycount:Set[${SettingXML[${spellfileB}].Set[${class}].Keys}]

	do
	{
		tempnme:Set["${SettingXML[${spellfileB}].Set[${class}].Key[${tempvar}]}"]

		SpellBlzName[${tempvar}]:Set[${SettingXML[${spellfileB}].Set[${class}].GetString["${tempnme}"]}]
		SpellNum[${tempvar}]:Set[${Arg[2,${tempnme}]}]	
		SpellBlzLvl[${tempvar}]:Set[${Arg[1,${tempnme}]}]
		
		BlzSpellnum:Set[${tempvar}]		
	}
	while ${tempvar:Inc}<=${keycount}
}

function GetHnxSpells(string class)
{
	declare keycount int local
	declare tempnme string local
	declare tempvar int local 1

	SettingXML[${xmlpath}/${Me.SubClass}_list.xml]:Unload 
	keycount:Set[${SettingXML[${spellfileH}].Set[${class}].Keys}]

	do
	{
		tempnme:Set["${SettingXML[${spellfileH}].Set[${class}].Key[${tempvar}]}"]

		SpellHnxName[${tempvar}]:Set[${SettingXML[${spellfileH}].Set[${class}].GetString["${tempnme}"]}]
		SpellIcon[${tempvar}]:Set[${Arg[2,${tempnme}]}]
		SpellHnxLvl[${tempvar}]:Set[${Arg[1,${tempnme}]}]
		
		HnxSpellnum:Set[${tempvar}]
	}
	while ${tempvar:Inc}<=${keycount}
}

function SortUp()
{
	declare tempnme string local
	declare tempvarB int local 1
	declare tempvarH int local 1
	declare tempvar int local 1
	
	do
	{
		tempvarH:Set[1]
		eq2echo Checking: (${SpellBlzLvl[${tempvarB}]})  ${SpellBlzName[${tempvarB}]}
		do
		{
			if ${SpellBlzName[${tempvarB}].Equal[${SpellHnxName[${tempvarH}]}]} && ${SpellNum[${tempvarB}]}>0 && ${SpellNum[${tempvarB}]}<=400 && ${NewBlzNum[${tempvarH}]}==0
			{
				eq2echo ...Found ${SpellBlzName[${tempvarB}]}
				NewBlzNum[${tempvarH}]:Set[${SpellNum[${tempvarB}]}]
				tempvar:Set[1]
				do
				{
					if ${SpellIcon[${tempvar}]}==${SpellIcon[${tempvarH}]} && ${SpellHnxName[${tempvar}].NotEqual[${SpellHnxName[${tempvarH}]}]}
					{
						NewBlzNum[${tempvar}]:Set[${SpellNum[${tempvarB}]}]
						eq2echo .......Set ${SpellHnxName[${tempvar}]} to ${SpellNum[${tempvarB}]}
					}					
				}
				while ${tempvar:Inc}<=${HnxSpellnum}
			}			
		}
		while ${tempvarH:Inc}<=${HnxSpellnum}
	}
	while ${tempvarB:Inc}<=${BlzSpellnum}
	
	
	tempvarB:Set[1]
	do
	{
		tempvarH:Set[1]
		do
		{
			if ${SpellBlzName[${tempvarB}].Equal[${SpellHnxName[${tempvarH}]}]}
			{
				SpellNum[${tempvarB}]:Set[${NewBlzNum[${tempvarH}]}]
			}			
		}
		while ${tempvarH:Inc}<=${HnxSpellnum}
	}
	while ${tempvarB:Inc}<=${BlzSpellnum}	
	
}



function MergeLists()
{
	declare tempname string local
	declare templvl int local
	declare tempicon int local
	declare tempvarB int local 1
	declare tempvarH int local 1
	declare tempvar int local 1
	declare totallist int local 2
	declare dupelist bool local FALSE
	declare newtemp int local 1
	declare lessone int local 1
	
	do
	{
		NewHnxName[${tempvar}]:Set[${SpellBlzName[${tempvar}]}]
		NewHnxLvl[${tempvar}]:Set[${SpellBlzLvl[${tempvar}]}]
		NewIcon[${tempvar}]:Set[${SpellNum[${tempvar}]}]
		eq2echo ${NewHnxLvl[${tempvar}]} ${NewHnxName[${tempvar}]} ${NewIcon[${tempvar}]}
	}
	while ${tempvar:Inc}<=${BlzSpellnum}
	
	tempvar:Dec
	
	do
	{
		dupelist:Set[FALSE]
		tempvarB:Set[1]
		;eq2echo Checking ${SpellHnxLvl[${tempvarH}]} ${SpellHnxName[${tempvarH}]}
		do
		{
			;eq2echo Checking   ${NewHnxName[${tempvarB}]}  ${SpellHnxName[${tempvarH}]}
			if ${SpellHnxName[${tempvarH}].Equal[${NewHnxName[${tempvarB}]}]}
			{
				dupelist:Set[TRUE]
				eq2echo ....Found... ${NewHnxLvl[${tempvarB}]} ${NewHnxName[${tempvarB}]}
			}
		}
		while ${tempvarB:Inc}<=${BlzSpellnum}
		
		if !${dupelist} && ${NewHnxName[${tempvar}].NotEqual[${SpellHnxName[${tempvarH}]}]}
		{
			tempvar:Inc
			NewHnxName[${tempvar}]:Set[${SpellHnxName[${tempvarH}]}]
			NewHnxLvl[${tempvar}]:Set[${SpellHnxLvl[${tempvarH}]}]
			NewIcon[${tempvar}]:Set[${SpellIcon[${tempvarH}]}]			
			eq2echo ..................  Adding ${NewHnxLvl[${tempvar}]} ${NewHnxName[${tempvar}]}
		}
			
	}
	while ${tempvarH:Inc}<=${HnxSpellnum}
	
	
	
	eq2echo Sorting ${tempvar} spells.  BE PATIENT.
	
	do
	{
		lessone:Set[${totallist}]
		lessone:Dec
		
		
		if ${NewHnxLvl[${lessone}]}<=${NewHnxLvl[${totallist}]}
		{
			totallist:Inc
		}
		else
		{
						
			
			
			tempname:Set[${NewHnxName[${lessone}]}]
			templvl:Set[${NewHnxLvl[${lessone}]}]
			tempicon:Set[${NewIcon[${lessone}]}]
			
			NewHnxName[${lessone}]:Set[${NewHnxName[${totallist}]}]
			NewHnxLvl[${lessone}]:Set[${NewHnxLvl[${totallist}]}]
			NewIcon[${lessone}]:Set[${NewIcon[${totallist}]}]
			
			NewHnxName[${totallist}]:Set[${tempname}]
			NewHnxLvl[${totallist}]:Set[${templvl}]
			NewIcon[${totallist}]:Set[${tempicon}]
			
			
			totallist:Dec
			
			if ${totallist}==1
			{
				totallist:Set[2]
			}
		}		
	}
	while ${totallist}<=${tempvar} 
	
	
	eq2echo Sorted: 
	
	;newtemp:Set[1]
	;do
	;{
		;eq2echo ${newtemp}: ${NewHnxLvl[${newtemp}]} ${NewHnxName[${newtemp}]}
	;}
	;while ${newtemp:Inc}<=${tempvar}	
	
	
	BlzSpellnum:Set[${tempvar}]
	tempvar:Set[1]
	eq2echo Here are post transfer:
	
	do
	{
		SpellBlzName[${tempvar}]:Set[${NewHnxName[${tempvar}]}]
		SpellBlzLvl[${tempvar}]:Set[${NewHnxLvl[${tempvar}]}]
		SpellNum[${tempvar}]:Set[${NewIcon[${tempvar}]}]
		;eq2echo ${tempvar}:  ${SpellBlzLvl[${tempvar}]} ${SpellBlzName[${tempvar}]}  ${SpellNum[${tempvar}]}
	}
	while ${tempvar:Inc}<=${BlzSpellnum}
	
	eq2echo DONE with sort section....................
}



function HndrxIcon() 
;  Icon-Spell lister.  Created by Hendrix.

;  This will create a file in your Spells folder called 'Class'_list.xml.  
;  Basically, it is a listing of all the spells you have with icon classifiers.  
;  Before you run, you MUST open your knowledge book, and SORT on the spells 'by level'.  
;  Then close the spell window.  Run the script (it will open the spell book again).  
;  When this routine is finished it will create the Class_list.xml file.



{ 
   ;Lets assume the spell book is at it's default key location of k 
   press k 
   wait 10
   eq2echo Starting...
   ;Lets setup our variables 
   declare tempvar int local 1 
   declare tempabilities int local 1 
   declare tempformat int local 1 

   ;checking to see how many of our abilities are actually spells. 
   do 
   { 
      If ${Me.Ability[${tempvar}].Class[${Me.SubClass}].Level} >= 1 
         tempabilities:Inc 
       
   } 
   while ${tempvar:Inc} <= ${Me.NumAbilities} 

   ;setting up the actual number of spells we have 
   declare levellist[${tempabilities}] int script 
   declare abilitylist[${tempabilities}] int script 
   declare totalspells int script ${tempabilities} 
   ;Adding abilities to variables so that we can organize our output. 
   tempvar:Set[1] 
   tempabilities:Set[1] 
   do 
   { 
      If ${Me.Ability[${tempvar}].Class[${Me.SubClass}].Level} >= 1 
      { 
         levellist[${tempabilities}]:Set[${Me.Ability[${tempvar}].Class[${Me.SubClass}].Level}] 
         abilitylist[${tempabilities}]:Set[${tempvar}] 
         tempabilities:Inc 
      } 
   } 
   while ${tempvar:Inc} <= ${Me.NumAbilities} 
    
   tempvar:Set[1] 
   tempabilities:Set[1] 
   do 
   { 
      do 
      { 
         if ${levellist[${tempabilities}]} == ${tempvar} 
         { 
            SettingXML[${xmlpath}/${Me.SubClass}_list.xml].Set[${Me.SubClass}]:Set["${Me.Ability[${abilitylist[${tempabilities}]}].Class[${Me.SubClass}].Level},${Me.Ability[${abilitylist[${tempabilities}]}].BackDropIconID}${Me.Ability[${abilitylist[${tempabilities}]}].MainIconID}",${Me.Ability[${abilitylist[${tempabilities}]}].Name}] 
            echo found a spell that matches ${tempvar} level 
         } 
      } 
      while ${tempabilities:Inc} <= ${totalspells} 

      tempabilities:Set[1] 
   } 
   while ${tempvar:Inc} <= ${totalspells} 
    
   SettingXML[${xmlpath}/${Me.SubClass}_list.xml]:Save 
   SettingXML[${xmlpath}/${Me.SubClass}_list.xml]:Unload 
   
   eq2echo Saved as ${Me.SubClass}_List.xml
} 



function atexit()
{
	EQ2Echo Ending Mentor!

	SettingXML[${xmlpath}/${Me.SubClass}_list.xml]:Unload 
	SettingXML[${xmlpath}/${Me.SubClass}.xml]:Unload 
}
