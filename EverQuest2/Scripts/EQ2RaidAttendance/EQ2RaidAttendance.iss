#include EQ2Common/Debug.iss

variable(script) settingsetref pOverallStats
variable(script) settingsetref pRaids
variable(script) settingsetref pTodaysRaid
variable(script) settingsetref pAlts

variable(script) collection:uint CurMembers		
variable(script) collection:uint TotalMembers
variable(script) collection:string Alts
variable(script) collection:string AltCreditCheck
variable(script) index:string Sitters	
variable(script) uint RaidCount								
variable(script) string RaidName
variable(script) string sFileName
variable(script) string RaidDate
variable(script) bool StatsOnly
variable(script) bool SSOnly
variable(script) bool AltsAsMains


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Raid Attendance Tracker ;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; This script takes "snapshots" of your raid and saves that information
;;; to an xml file called 'EQ2RaidAttendance.xml'.  At the same time, it 
;;; will produce detailed attendance statistics and spew them to the console
;;; as well as to a text file entitled 'EQ2RaidAttendance.txt'.
;;;
;;; Every time that you take a "snapshot" for a particular raid, it will
;;; retrieve the members saved for that raid and then add any new people 
;;; in your current raid to the list.  Again, it will save and spew statistics.
;;; Guilds that use DKP can use multiple snapshots to indicate new stages within
;;; the same raid, as each time a raid member is counted, their "seen" counter
;;; increments within the xml.  Therefore, if someone were there for the entire
;;; raid, and 5 snapshots were taken, they would have a "seen" counter of 5.  
;;; This counter is not utilized in the output statistics; however, it is saved
;;; in the xml (per raid) and should be exportable to Excel for easy viewing
;;; and calculation.
;;;
;;; The script is used by indicating a Raid NAME (otherwise it will simply use 
;;; the current date) followed by anyone that is 'sitting out'.  For example,
;;; if you wish to call your current raid "Korsha" and Amadeus, Pygar,
;;; and Valerian are sitting out, then you would use the following command in
;;; the console window:
;;;      > run EQ2RaidAttendance "Raid=Korsha [Overking Only]" Amadeus Pygar Valerian
;;; The script will run, call the raid "Korsha [Overking Only]" and count Amadeus 
;;; Pygar and Valerian as being IN the raid.   (NOTE:  In this example you're MANUALLY
;;; adding Amadeus, Pygar, and Valerian.  Anyone that is in your current raid will be 
;;; added automatically.)
;;;
;;; NOTES: To take further snapshots it is not necessary to indicate the 'sitters' again
;;; (unless there are new 'sitters'.)  Once someone is counted as in the raid, they
;;; are always in that raid, regardless of if they are still present during the next
;;; snapshot.  ALSO, this script saves raids by date as well as by name.  Therefore,
;;; if your raid crosses over midnight (your time), then issuing another snapshot,
;;; even with the same name, will save as a new raid.
;;;
;;; Finally, the script supports alts!  If a character name is entered as an alt of a
;;; main, then when that alt is found in a raid, it will count towards the attendance
;;; percentage of the main to which it is paired.   Alts can be added to the XML file
;;; with this command:
;;;      > run EQ2RaidAttendance ALT=MAIN
;;;   (ie: run EQ2RaidAttendance MiniAma=Amadeus)
;;;
;;; To delete an alt<->main pairing, simply edit the xml.
;;;
;;; There are a few other optional command line parameters that can be added to any
;;; of the ones above:
;;;      -StatsOnly         (Produce statistis only -- no raid snapshot is taken.)
;;;      -SnapshotOnly      (Take raid snapshot only -- no stats are spewed.)
;;;      Date=xx/xx/xxxx    (Forces the script to utilize the given date as the date of the raid.)
;;;      -AltsAsMains       (When used, the script will treat all characters as mains when creating statistics.)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function main(... Args)
{	
	variable settingsetref pMember
	variable string RaidNameSuffix
	variable int count = 0
	variable bool SkipToExit = FALSE
	Debug:Enable
	Debug:SetPrefix[]
	Debug:SetEchoAlsoLogs[TRUE]
	Debug:Echo["-------- EQ2 Raid Attendance --------"]
	Debug:Echo["(Created ${Time.Date} at ${Time})"]
	Debug:Echo["-"]
	
	;;;;;;
	;; User Defined Settings
	sFileName:Set["EQ2RaidAttendance.xml"]
	Debug:SetFilename["EQ2RaidAttendance.txt"]
	;;
	;;;;;;
	
	;;;;;;
	;;
	Debug:Echo["- Initializing..."]	
	while ${count:Inc}<=${Args.Size}
	{
		if ${Args[${count}].Token[1,=].Equal[Raid]}
			RaidNameSuffix:Set[${Args[${count}].Token[2,=]}]		
		elseif ${Args[${count}].Token[1,=].Equal[Date]}
			RaidDate:Set[${Args[${count}].Token[2,=]}]				
		elseif ${Args[${count}].Find[-StatsOnly]}
			StatsOnly:Set[TRUE]
		elseif (${Args[${count}].Find[-AltsAsMains]} || ${Args[${count}].Find[-IgnoreAlts]})
			AltsAsMains:Set[TRUE]		
		elseif (${Args[${count}].Find[-SnapshotOnly]} || ${Args[${count}].Find[-SSOnly]})
			SSOnly:Set[TRUE]
		elseif ${Args[${count}].Find[=]}
		{
			Debug:Echo["- Adding '${Args[${count}].Token[1,=]}' as an alt character of '${Args[${count}].Token[2,=]}'"]
			Alts:Set[${Args[${count}].Token[1,=]},${Args[${count}].Token[2,=]}]
			call ExportAlts
			Debug:Echo["-----------------------------------"]
			return
		}			
		else
		{
		    Sitters:Insert[${Args[${count}]}]
		    Debug:Echo["-- ${Args[${count}]} is sitting out today"]
		}
	}
	
	if (${RaidDate.Length} <= 0)
		RaidDate:Set[${Time.Date}]
	if (${RaidNameSuffix.Length} > 0)
	    RaidName:Set["${RaidDate} (${RaidNameSuffix})"]
    else
        RaidName:Set["${RaidDate}"]
    Debug:Echo["-- Today's Raid will be named '${RaidName}'"]
    Debug:Echo["- Initialization complete."]
    Debug:Echo["-"]
    ;;
    ;;;;;;

	call ImportXML
	
	if !${StatsOnly}
	{
		call TakeSnapShot	
		Debug:Echo["-"]
	}
	
	if !${SSOnly}
		call GenerateStats
	
	call ExportXML
	Debug:Echo["-----------------------------------"]
	Debug:Log["\n\n\n"]
}

function ImportXML()
{
	variable iterator TRIterator
	variable iterator OSIterator
	variable iterator RIterator
	variable iterator AIterator
	variable uint SSCount
	variable uint AttendanceCount
	variable string MainName
	variable string AltName
	
	;;;;; 
	;;;
	LavishSettings:AddSet[EQ2RaidAttendance]
	LavishSettings[EQ2RaidAttendance]:Clear
	LavishSettings[EQ2RaidAttendance]:AddSet[Alts]
	LavishSettings[EQ2RaidAttendance]:AddSet[Overall Stats]
	LavishSettings[EQ2RaidAttendance]:AddSet[Raids]
	LavishSettings[EQ2RaidAttendance]:Import[${sFileName}]
	
	pOverallStats:Set[${LavishSettings[EQ2RaidAttendance].FindSet[Overall Stats]}]
	pRaids:Set[${LavishSettings[EQ2RaidAttendance].FindSet[Raids]}]
	pAlts:Set[${LavishSettings[EQ2RaidAttendance].FindSet[Alts]}]
	;;
	;;;;;
	
	;;;;;
	;;; Alts
	if !${AltsAsMains}
	{
		Debug:Echo["- Loading alt <-> main information..."]
		pAlts:GetSetIterator[AIterator]
		if ${AIterator:First(exists)}
		{
			do
			{
				AltName:Set[${AIterator.Key}]
				MainName:Set[${pAlts.FindSet[${AltName}].FindSetting[Main]}]
				
				Debug:Echo["-- ${AltName} == ${MainName}"]
				Alts:Set[${AltName},${MainName}]
			}
			while ${AIterator:Next(exists)}
			Debug:Echo["- There are ${Alts.Used} alt characters being tracked."]
		}
		else
			Debug:Echo["- There are no alt characters currently being tracked."]
		Debug:Echo["-"]
	}
	;;;
	;;;;;
	
	
	;;;;;
	;;; Raid Today
	Debug:Echo["- Loading today's raid information..."]
	pTodaysRaid:Set[${pRaids.FindSet["${RaidName}"]}]	
	if ${pTodaysRaid}
	{
		Debug:Echo["-- Raid entry found for today's date.  Processing..."]
		pTodaysRaid:GetSetIterator[TRIterator]
		if ${TRIterator:First(exists)}
		{
			do
			{
				SSCount:Set[${pTodaysRaid.FindSet[${TRIterator.Key}].FindSetting["Seen"]}]
				Debug:Echo["--- Raid Member: ${TRIterator.Key} (${SSCount})"]
				
				CurMembers:Set[${TRIterator.Key},${SSCount}]
			}
			while ${TRIterator:Next(exists)}
		}
		Debug:Echo["-- Processing Finished.  There were ${CurMembers.Used} players being tracked so far in this raid."]
	}
	else
	{
		if (${StatsOnly})
			Debug:Echo["-- No Entry exists as yet for today's raid."]
		else
		{
			Debug:Echo["-- No Entry exists as yet for today's raid.  This will be the first snapshot today."]
			pRaids:AddSet["${RaidName}"]
			pTodaysRaid:Set[${pRaids.FindSet["${RaidName}"]}]
		}
	}
	;;
	;;;;;
	
	;;;;;
	;; Get Total Number of Raids tracked
	pRaids:GetSetIterator[RIterator]
	if ${RIterator:First(exists)}
	{
		do
		{
			;Debug:Echo["+ ${RIterator.Key}"]
			RaidCount:Inc
		}
		while ${RIterator:Next(exists)}
	}
	Debug:Echo["-"]
	Debug:Echo["- There are ${RaidCount} raid(s) currently being tracked."]
	if ${StatsOnly}
		Debug:Echo["-"]
	;;
	;;;;;
	
	
	;;;;;
	;;;
	
	;;
	;;;;;
}

function ExportXML()
{
	LavishSettings[EQ2RaidAttendance]:Export[${sFileName}]	
}

function TakeSnapShot()
{
	variable iterator CIterator
	variable iterator SIterator
	variable string PlayerName
	variable int PlayerSSCount
	variable int SSCount
	variable int i 
	variable int Counter
	i:Set[1]
	Counter:Set[0]
	
	Debug:Echo["-"]
	Debug:Echo["- Taking a Snapshot of today's raid..."]
	
	;;;;
	;; First, the people in the raid
	;;;;
	if (${Me.Raid} > 0)
	{
		do
		{
			if ${Me.Raid[${i}].Name(exists)}
			{
				if (${CurMembers.Element[${Me.Raid[${i}].Name}].Name(exists)})
				{
					SSCount:Set[${CurMembers.Element[${Me.Raid[${i}].Name}]}]
					CurMembers:Set[${Me.Raid[${i}].Name},${Math.Calc[${SSCount}+1].Precision[0]}]
					Debug:Echo["--- ${Me.Raid[${i}].Name} already exists in database for today's raid.  (${Math.Calc[${SSCount}+1].Precision[0]})"]
				}
				else
				{
					CurMembers:Set[${Me.Raid[${i}].Name},1]
					Debug:Echo["--- ${Me.Raid[${i}].Name} added to database for today's raid.  (1)"]
				}
				Counter:Inc
			}
		}
		while ${i:Inc} <= ${Me.Raid}
	}
	Debug:Echo["-- ${Counter} people were found as a part of your *current* raid force."]
	
	;;;;
	;; Now, the people that are sitting out
	;;;;
	Sitters:GetIterator[SIterator]
	if ${SIterator:First(exists)}
	{
		do
		{
			PlayerName:Set[${SIterator.Value}]

			if (${CurMembers.Element[${PlayerName}](exists)})
			{
				SSCount:Set[${CurMembers.Element[${PlayerName}]}]
				CurMembers:Set[${PlayerName},${Math.Calc[${SSCount}+1].Precision[0]}]
				Debug:Echo["--- ${PlayerName} already exists in database for today's raid.  (${Math.Calc[${SSCount}+1].Precision[0]})"]
			}
			else
			{
				CurMembers:Set[${PlayerName},1]
				Debug:Echo["--- ${PlayerName} added to database for today's raid.  (1)"]
			}
		}	
		while ${SIterator:Next(exists)}
	}	
	
	
	Debug:Echo["- Snapshot complete :: ${CurMembers.Used} raid members are now being counted as a part of this raid."]
	
	;;;
	;; Now write add the raid info to xml
	;;;
	pTodaysRaid:Clear
	CurMembers:GetIterator[CIterator]
	if ${CIterator:First(exists)}
	{
		do
		{
			PlayerName:Set[${CIterator.Key}]
			PlayerSSCount:Set[${CIterator.Value}]
		
			pTodaysRaid:AddSet[${PlayerName}]
			pTodaysRaid.FindSet[${PlayerName}]:AddSetting[Seen,${PlayerSSCount}]
		}	
		while ${CIterator:Next(exists)}
	}
	call ExportXML
}

function GenerateStats()
{
	variable iterator RIterator
	variable iterator RMIterator
	variable iterator SIterator
	variable string PlayerName
	variable string MainName
	variable uint PlayerRaidCount
	variable float Percentage
	variable float AverageCounter
	variable float Average
	
	Debug:Echo["- Generating Statistics..."]
	Debug:Echo["-"]
	
	pOverallStats:Clear
	
	;;;;;
	;; Go through Raids and create TotalMembers
	pRaids:GetSetIterator[RIterator]
	if ${RIterator:First(exists)}
	{
		do
		{
			pRaids.FindSet[${RIterator.Key}]:GetSetIterator[RMIterator]
			if ${RMIterator:First(exists)}
			{
				AltCreditCheck:Clear
				Debug:Echo["--"]
				Debug:Echo["-- ${RIterator.Key}"]
				do
				{
					;; "RaidMember Name = ${RMIterator.Key}"
					;; "RaidMember Snapshot count (if we wanted to use it) = ${pRaids.FindSet[${RIterator.Key}].FindSet[${RMIterator.Key}].FindSetting[Seen]}
					
					if (${Alts.Element[${RMIterator.Key}](exists)})
					{
						MainName:Set[${Alts.Element[${RMIterator.Key}]}]
						
						if ${pRaids.FindSet[${RIterator.Key}].FindSet[${MainName}](exists)}
						{
							Debug:Echo["--- ${RMIterator.Key} :: **ALT**"]
							Debug:Echo["---- ${MainName} is already counted in this raid.  Skipping..."]
							continue
						}

						Debug:Echo["--- ${RMIterator.Key} :: **ALT**"]
						
						if (${TotalMembers.Element[${MainName}](exists)})
						{
							if (!${AltCreditCheck.Element[${MainName}](exists)})
							{
								PlayerRaidCount:Set[${TotalMembers.Element[${MainName}]}]
								
								TotalMembers:Set[${MainName},${Math.Calc[${PlayerRaidCount}+1].Precision[0]}]
								
								Debug:Echo["---- Adding to ${MainName}'s total (${Math.Calc[${PlayerRaidCount}+1].Precision[0]})"]
								AltCreditCheck:Set[${MainName},${RMIterator.Key}]
							}
							else
								Debug:Echo["---- ${MainName} already given credit for one alt this raid."]
						}
						else
						{
							if (!${AltCreditCheck.Element[${MainName}](exists)})
							{
								TotalMembers:Set[${MainName},1]
								Debug:Echo["---- Adding to ${MainName}'s total (1)"]
								AltCreditCheck:Set[${MainName},${RMIterator.Key}]
							}
							else
								Debug:Echo["---- ${MainName} already given credit for one alt this raid."]
						}									
					}
					else
					{
						if (${TotalMembers.Element[${RMIterator.Key}](exists)})
						{
							PlayerRaidCount:Set[${TotalMembers.Element[${RMIterator.Key}]}]
							
							TotalMembers:Set[${RMIterator.Key},${Math.Calc[${PlayerRaidCount}+1].Precision[0]}]
							Debug:Echo["--- ${RMIterator.Key} (${Math.Calc[${PlayerRaidCount}+1].Precision[0]})"]
						}
						else
						{
							TotalMembers:Set[${RMIterator.Key},1]
							Debug:Echo["--- ${RMIterator.Key} (1)"]
						}
					}
				}
				while ${RMIterator:Next(exists)}
			}
		}
		while ${RIterator:Next(exists)}
	}
	Debug:Echo["-"]
	Debug:Echo["- A total of ${TotalMembers.Used} people are being tracked overall."]
	Debug:Echo["-"]
	;;
	;;;;;	
	
	Debug:Echo["-"]
	Debug:Echo["- Player attendance so far..."]
	TotalMembers:GetIterator[SIterator]
	if ${SIterator:First(exists)}
	{
		do
		{
			PlayerName:Set[${SIterator.Key}]
			PlayerRaidCount:Set[${SIterator.Value}]
			Percentage:Set[${Math.Calc[${PlayerRaidCount}/${RaidCount}*100]}]
			
			Debug:Echo["-- ${PlayerName} has attended ${PlayerRaidCount} of ${RaidCount} raids (${Percentage.Precision[2]}%)"]

			pOverallStats:AddSet[${PlayerName}]
			pOverallStats.FindSet[${PlayerName}]:AddSetting[Raids Attended,${PlayerRaidCount}]
			pOverallStats.FindSet[${PlayerName}]:AddSetting[Percentage Attendance,${Percentage.Precision[2]}]
			
			AverageCounter:Set[${Math.Calc[${AverageCounter}+${Percentage}]}]
		}	
		while ${SIterator:Next(exists)}
	}
	Debug:Echo["-"]
	Average:Set[${Math.Calc[${AverageCounter}/${TotalMembers.Used}]}]
	Debug:Echo["-- The average attendance rate is ${Average.Precision[2]}%."]
		
	call ExportXML
}

function ExportAlts()
{
	variable iterator AIterator
	variable iterator SIterator
	variable string AltName
	variable string MainName
	
	LavishSettings:AddSet[EQ2RaidAttendance]
	LavishSettings[EQ2RaidAttendance]:Clear
	LavishSettings[EQ2RaidAttendance]:AddSet[Alts]
	LavishSettings[EQ2RaidAttendance]:AddSet[Overall Stats]
	LavishSettings[EQ2RaidAttendance]:AddSet[Raids]
	LavishSettings[EQ2RaidAttendance]:Import[${sFileName}]
	pAlts:Set[${LavishSettings[EQ2RaidAttendance].FindSet[Alts]}]	
	
	;;;;;
	;;;
	Debug:Echo["- Loading alt<->main information from XML..."]
	pAlts:GetSetIterator[AIterator]
	if ${AIterator:First(exists)}
	{
		do
		{
			AltName:Set[${AIterator.Key}]
			MainName:Set[${pAlts.FindSet[${AltName}].FindSetting[Main]}]
			
			Debug:Echo["-- ${AltName} == ${MainName}"]
			Alts:Set[${AltName},${MainName}]
		}
		while ${AIterator:Next(exists)}
		Debug:Echo["- There are ${Alts.Used} alt characters being tracked."]
	}
	else
		Debug:Echo["- There are no alt characters currently being tracked."]
	Debug:Echo["-"]
	;;;
	;;;;;	
	
	
	;;;;;
	;; Add all Main<->Alt info to xml
	pAlts:Clear
	Debug:Echo["- Writing Alts to XML..."]
	Alts:GetIterator[SIterator]
	if ${SIterator:First(exists)}
	{
		do
		{
			AltName:Set[${SIterator.Key}]
			MainName:Set[${SIterator.Value}]
			
			Debug:Echo["-- Adding '${AltName}' to XML as an alt of '${MainName}'"]

			pAlts:AddSet[${AltName}]
			pAlts.FindSet[${AltName}]:AddSetting[Main,${MainName}]
		}	
		while ${SIterator:Next(exists)}
	}
	Debug:Echo["-"]
	
	LavishSettings[EQ2RaidAttendance]:Export[${sFileName}]
}