;===================================================
;===               VGA Logic Tree               ====
;===================================================
/*
Check UI Interaction-----> Pause,Execute QueCommands

Not In Combat ->  General Downtime -----------------> Class Specific Downtime
		         |	|				|
			 |	-> Follow/Assist/trade/etc	-> GatherEnergy/Songs/Switch Weapons
			 |
			 -> Heal or Buff ---(Cp=Neither)------->|
I should Attack							|
	|							|
	->  Pre Combat Actions ->  Class Specific Pre Combat	|
	|	|	|	   |				|
	|	|	|	   ------(Cp=Pre)-------------->|
	|	|	|	   				|
	|	|	-> EmergencyActions----(Cp=Neither)---->|
	|	|						|
	|	-> MoveToTarget, Assist, Autoattack->Return	|
	|							|
	|							|
	-> Perform A Combat Action				|
	|	|						|
	|	-> Opening Sequence				|
	|	|	|					|
	|	|	-> Spells  -------->  Melee		|
	|	|	     |			|		|
	|	|	     -----------------------(Cp=while)->|	
	|	|						|
	|	-> Main Combat(dot,debuff,DD,AOE)		|
	|		|					|
	|		-> Spells  -------->  Melee		|
	|		     |			|		|
	|		     -----------------------(Cp=Both)-->|
	|							|
	-> Post Combat Sequence ->  Class Specific Post Combat	|
	|	|				|		|
	|	-> Spells  -------->  Melee	|		|	
	|	    |			|	|		|
	|	    --------------------------------(Cp=Both)-->|	
	->Return						|
								|->CheckAbilityToCast--TRUE-->*Execute Ability/Type/CP(CastingPassIdentity)
									|								|
									->FALSE ->Return						|
																	|
	-<<--------------<<------------------------------------<<---------------------------------------<<-----------------------------<<
	|																|
	->*Execute Ability/Type														|
		|															|
		->  Check Mob Resists Lists --TRUE--> Check Spell Type Lists --TRUE-->  Dont Execute (return)				|
			  |				   	|									|
			False				   	False									|
			  |				   	|									|
			  -----> Use Ability <-------------------									|
		  		     |													|
				     |													|
		  	    Check CP(CastingPass)											|			
				|													|
				-> Neither  -> MeCasting(Wait WhileCasting,Global) -> Return						|
				|													|
				-> While Only(MeCasting_While)										|
				|	|												|
				|	->While Casting Check EmergencyActions-------------------(Cp=Post)----------------------------->|
				|	|												|
				|	->MeCastingWaits ->Return									|
				|													|
				-> Both(MeCasting_Pre_Post)										|
				|	|												|
				|	->While Casting Check EmergencyActions-------------------(Cp=Post)----------------------------->|
				|	|												|		
				|	->MeCastingWaits										|
				|	|												|
				|	->AfterGlobal Check EmergencyActions --------------------------> Criticals --------(Cp=Post)--->|
				|					|					|			|
				|					|					->Return		|
				|					-------------------------(Cp=Post)----------------------------->|
				-> Post Only(MeCasting_Post)										|
					|												|
					->MeCastingWaits										|
					|												|
					->AfterGlobal Check EmergencyActions --------------------------> Criticals --------(Cp=Post)--->|
									|					|			|
									|					->Return		|
									-------------------------(Cp=Post)----------------------------->|			

*/
;===================================================
;===               Includes                     ====
;===================================================

#include "${Script.CurrentDirectory}/scripts/vga/UTL_MoveTo.iss"
;#include "${Script.CurrentDirectory}/scripts/vga/UTL_faceslow.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_GUI_Healing.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_GUI_Utility.iss"

#include "${Script.CurrentDirectory}/scripts/vga/Act_Interupt.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_Objects.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Spells.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Combat.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Criticals.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Combat_Main.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Melee.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Evade.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Evade.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Mobs.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Abilities.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Buff.iss"
#include "${Script.CurrentDirectory}/scripts/vga/CLS_Shaman.iss"
#include "${Script.CurrentDirectory}/scripts/vga/CLS_Sorcerer.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Mob.iss"
#include "${Script.CurrentDirectory}/scripts/vga/CLS_Bard.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_Variables.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_LavishLoad.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_LavishSave.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_LavishEvents.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_BuffWatch.iss"
#include "${Script.CurrentDirectory}/scripts/vga/ACT_BuffWatch.iss"
#include "${Script.CurrentDirectory}/scripts/vga/ACT_Merchant.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Merchant.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Bard.iss"

;===================================================
;===               Main Routine               ====
;===================================================

function main()
{
	;===================================================
	;===               ISX Load                     ====
	;===================================================	
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "[${Time}] --> Unable to load ISXVG, exiting script"
		endscript vga
	}
	;===================================================
	;===               Function Loads               ====
	;===================================================	
	call loadxmls
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
   	ui -reload "${Script.CurrentDirectory}/vga_gui.xml"
	;===================================================
	;===               Atoms and Events             ====
	;===================================================	
	call LavishEventLoad
	;===================================================
	;===               Populate GUI Lists           ====
	;===================================================
	call PopulateHealLists
	call PopulateSpellLists
	call PopulateMeleeLists
	call PopulateCritsLists
	call PopulateCombatMainLists
	call PopulateEvadeLists
	call PopulateMobLists
	call PopulateAbilitiesLists
	call PopulateBuffLists
	call PopulateSellLists
	call PopulateBardLists
	;===================================================
	;===               Bug WorkArounds              ====
	;===================================================
	call MeClassCrashWorkAround
	;===================================================
	;===               Main Loop                    ====
	;===================================================
   	do
   	{
		;-------------------------------------------
		;*****************Pause*********************
		;-------------------------------------------
		call PauseScript
		;-------------------------------------------
		;************Run Queued Stuff***************
		;-------------------------------------------
		while ${QueuedCommands}
			ExecuteQueued
		FlushQueued
		;-------------------------------------------
		;********Run Fight/Downtime Stuff***********
		;-------------------------------------------
		if !${fight.ShouldIAttack}
		{
			; Only run "downtimefunction" a max of once per second -- this helps with performance.  The "1" could be be a variable added to the UI if desired...
			if (${Math.Calc[${Math.Calc[${Script.RunningTime}-${LastDowntimeCall}]}/1000]} > 1)
			{
				LastDowntimeCall:Set[${Script.RunningTime}]
				call downtimefunction
			}
		}
		if ${fight.ShouldIAttack}
		{
			call combatfunction
		}
   	}
   	while ${Me(exists)}
}

;===================================================
;===          Main Downtime Function            ====
;===================================================
function downtimefunction()
{
	call Healcheck
	call ClassSpecificDowntime
	call followpawn
	call assistpawn
	call BuffUp
	call lootit
	return
}
;===================================================
;===    Class Specific Downtime Function        ====
;===================================================
function ClassSpecificDowntime()
{
	if ${MyClass.Equal[Shaman]}
		call shamanmana
	if ${MyClass.Equal[Bard]}
		call BardSong
	return
}
;===================================================
;===               CombatRoutine Function       ====
;===================================================
function combatfunction()
{
	;-------------------------------------------
	;**********Fighting PreLoopCall*************
	;-------------------------------------------
	call PreCombatLoopFunction
	call ClassSpecificPreCombat
	call SendInPets

	;-------------------------------------------
	;************Main Combat Loop***************
	;-------------------------------------------
	if ${newattack}
		call OpeningSpellSequence
	elseif !${newattack}
	{
		call DotSpells
		call DotMelee
		call DebuffSpells
		call DebuffMelee
		call CombatSpellSequence
		call CombatMeleeSequence
		call AOESpell
		call AOEMelee
	}

	;-------------------------------------------
	;**********Fighting PostLoopCall************
	;-------------------------------------------
	call PostCombatLoopFunction
	call ClassSpecificPostCombat	

	return
}
;===================================================
;===         Pre Combat Loop Function           ====
;===================================================
function PreCombatLoopFunction()
{
 	call CheckPosition
	call EmergencyActions
	call Healcheck
	return
}
;===================================================
;===     Class Specific Pre Combat Loop         ====
;===================================================
function ClassSpecificPreCombat()
{
	if ${MyClass.Equal[Shaman]}
		call shamanmana
	if ${MyClass.Equal[Bard]}
		call BardSong
	return
}
;===================================================
;===         Post Combat Loop Function          ====
;===================================================
function PostCombatLoopFunction()
{
	return
}
;===================================================
;===     Class Specific Post Combat Loop        ====
;===================================================
function ClassSpecificPostCombat()
{
	return
}
;===================================================
;===             Emergency Actions              ====
;===================================================
function EmergencyActions()
{
	call PauseScript
	;-------------------------------------------
	;*****Check If I Need to Instant Heal*******
	;-------------------------------------------
	if ${ClassRole.healer}
		call checkinstantheal
	;-------------------------------------------
	;***Check If I Need to Turn off Attack******
	;-------------------------------------------
	call TurnOffAttackfunct
	;-------------------------------------------
	;*******Check If I Need to Evade************
	;-------------------------------------------
	call checkFD
	call checkinvoln1
	call checkinvoln2
	call checkevade1
	call checkevade2
	;-------------------------------------------
	;***Check If I Need to Counter a Spell******
	;-------------------------------------------	
	call counteringfunct
	;-------------------------------------------
	;***Check If I Need to Dispell a Spell******
	;-------------------------------------------
	call dispellfunct
	;-------------------------------------------
	;****Check If I Need to Push a Stance******
	;-------------------------------------------
	call StancePushfunct
	call clickiesfunct

	return
}

;===================================================
;===             Post Casting Loop             ====
;===================================================
function PostCastingActions()
{
	UpdateTempBuffWatch
	call EmergencyActions
	call Healcheck
	;-------------------------------------------
	;********Check If I Can Critical************
	;-------------------------------------------
	call functAOECrits
	call functBuffCrits
	call functDotCrits
	call functCombatCrits
	;-------------------------------------------
	;****Check If I Need to use my Counter******
	;-------------------------------------------
	call counterattack
	;-------------------------------------------
	;****Check for Class Specific Post**********
	;-------------------------------------------
	call ClassSpecificPostCasting
	
	return
}
;===================================================
;===    Class Specific Post Casting Loop        ====
;===================================================
function ClassSpecificPostCasting()
{
	if ${MyClass.Equal[Shaman]}
		{
		call shamanmana
		}
	if ${MyClass.Equal[Sorcerer]}
		{
		call SorcererMana
		}
	return
}
;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[VGA]:Clear
	LavishSettings[VGA_Mobs]:Clear
	LavishSettings[VGA_General]:Clear
	LavishSettings:AddSet[VGA]
	LavishSettings:AddSet[VGA_Mobs]
	LavishSettings:AddSet[VGA_General]

	LavishSettings[VGA]:AddSet[Healers]
	LavishSettings[VGA]:AddSet[Utility]
	LavishSettings[VGA]:AddSet[OpeningSpellSequence]
	LavishSettings[VGA]:AddSet[CombatSpellSequence]
	LavishSettings[VGA]:AddSet[AOESpell]
	LavishSettings[VGA]:AddSet[DotSpell]
	LavishSettings[VGA]:AddSet[DebuffSpell]
	LavishSettings[VGA]:AddSet[Spell]
	LavishSettings[VGA]:AddSet[OpeningMeleeSequence]
	LavishSettings[VGA]:AddSet[CombatMeleeSequence]
	LavishSettings[VGA]:AddSet[AOEMelee]
	LavishSettings[VGA]:AddSet[DotMelee]
	LavishSettings[VGA]:AddSet[DebuffMelee]
	LavishSettings[VGA]:AddSet[Melee]
	LavishSettings[VGA]:AddSet[AOECrits]
	LavishSettings[VGA]:AddSet[DotCrits]
	LavishSettings[VGA]:AddSet[BuffCrits]
	LavishSettings[VGA]:AddSet[CombatCrits]
	LavishSettings[VGA]:AddSet[Clickies]
	LavishSettings[VGA]:AddSet[Counter]
	LavishSettings[VGA]:AddSet[Dispell]
	LavishSettings[VGA]:AddSet[StancePush]
	LavishSettings[VGA]:AddSet[TurnOffAttack]
	LavishSettings[VGA]:AddSet[Crits]
	LavishSettings[VGA]:AddSet[CounterAttack]
	LavishSettings[VGA]:AddSet[Evade]
	LavishSettings[VGA]:AddSet[Evade1]
	LavishSettings[VGA]:AddSet[Evade2]
	LavishSettings[VGA]:AddSet[Buff]
	LavishSettings[VGA]:AddSet[IceA]
	LavishSettings[VGA]:AddSet[FireA]
	LavishSettings[VGA]:AddSet[SpiritualA]
	LavishSettings[VGA]:AddSet[PhysicalA]
	LavishSettings[VGA]:AddSet[ArcaneA]
	LavishSettings[VGA]:AddSet[Triggers]
	LavishSettings[VGA]:AddSet[UseAbilT1]
	LavishSettings[VGA]:AddSet[UseItemsT1]
	LavishSettings[VGA]:AddSet[MobDeBuffT1]
	LavishSettings[VGA]:AddSet[BuffT1]
	LavishSettings[VGA]:AddSet[AbilReadyT1]
	LavishSettings[VGA]:AddSet[Class]

	LavishSettings[VGA_Mobs]:AddSet[Ice]
	LavishSettings[VGA_Mobs]:AddSet[Fire]
	LavishSettings[VGA_Mobs]:AddSet[Spiritual]
	LavishSettings[VGA_Mobs]:AddSet[Physical]
	LavishSettings[VGA_Mobs]:AddSet[Arcane]

	LavishSettings[VGA_General]:AddSet[BW]
	LavishSettings[VGA_General]:AddSet[DBW]
	LavishSettings[VGA_General]:AddSet[TBW]
	LavishSettings[VGA_General]:AddSet[Sell]	

	LavishSettings[VGA]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/${Me.FName}.xml]
	LavishSettings[VGA_Mobs]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Mobs.xml]
	LavishSettings[VGA_General]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_General.xml]

	call LoadHealers
	call LoadUtility
	call LoadSpells
	call LoadCrits
	call LoadCombatMain
	call LoadMelee
	call LoadEvade
	call LoadMobs
	call LoadAbilities
	call LavishLoad
}
;********************************************
atom atexit()
{
   
   VG:ExecBinding[moveforward,release]
   VG:ExecBinding[movebackward,release]
   call SaveHealers
   call SaveUtility
   call SaveSpells
   call SaveCrits
   call SaveCombatMain
   call SaveMelee
   call SaveEvade
   call SaveMobs
   call SaveAbilities
   call LavishSave
   Event[VG_OnIncomingCombatText]:DetachAtom[VG_OnIncomingCombatText]
   Event[VG_onGroupMemberAdded]:DetachAtom[NeedBuffs]
   Event[VG_onGroupMemberDeath]:DetachAtom[NeedBuffs]
   LavishSettings[VGA]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/${Me.FName}.xml]
   LavishSettings[VGA_Mobs]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Mobs.xml]
   LavishSettings[VGA_General]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_General.xml]
   ui -unload "${Script.CurrentDirectory}/vga_gui.xml"
   endscript vga.iss
	
}
