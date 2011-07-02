;-------------------------------------------------------
; VG-Loot.iss Version 1.0 Updated: 2011/10/17
;-------------------------------------------------------
;
; *Written by Zandros
;
; *Special thanks to:  
;	Lax for Innerspace
;	Amadeus for ISXVG
;	mmoAddict for VG_Objects
;
; *Description:
;	Just a simple loot program that does the following:
;	- Scans 5 meters to loot any target and blacklist it for 10 seconds so that it can be checked again
;	- Option to:
;		Delete Trash 
;		Delay looting so others can loot first
;		Loot a specific item
;		Loot while in combat
;		Loot while in a Raid
;		Clear the target after looting
;		Echo your loot to your console 
;
; *Requirements:
;	VG_Objects by mmoAddict
;
;===================================================
;===              INCLUDES                      ====
;===================================================
;
#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Trash.iss"
;
;===================================================
;===             VARIABLES                      ====
;===================================================
;
;; Main
variable string Version = "1.0"
variable bool doEcho = TRUE
variable bool isPaused = TRUE
variable bool isRunning = TRUE
variable bool doClearLoot=TRUE
variable int LootCheckTimer = ${Script.RunningTime}
variable int ClearLootTimer = ${Script.RunningTime}
variable int TrashLootTimer = ${Script.RunningTime}
variable bool doLoot = TRUE
variable bool doLootInCombat = TRUE
variable bool doRaidLoot = TRUE
variable int LootDelay = 0
variable bool doLootOnly = FALSE
variable bool doLootEcho = TRUE
variable string LootOnly = "Nothing"
variable bool doTrash = FALSE
variable bool doClearTarget = FALSE
variable collection:int64 TempBlackList
variable collection:int64 PermanentBlackList
;
;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
;
function main()
{
	;-------------------------------------------
	; Load ISXVG or exit script
	;-------------------------------------------
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "Unable to load ISXVG, exiting script"
		endscript VG-Loot
	}
	EchoIt "Started VG-Loot Script"
	wait 30 ${Me.Chunk(exists)}

	;; Load our Settings
	LoadXMLSettings	

	;; Reload the UI
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-Loot.xml"

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		if ${isPaused} && ${isRunning}
		{
			waitframe
			TempBlackList:Clear
		}
		elseif ${isRunning}
		{
			call LootTargets
			if ${doTrash} && !${Me.InCombat}
			{
				;; Delete trash once every 3 seconds
				if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${TrashLootTimer}]}/1000]}>3
				{
					obj_trash:Destroy
					TrashLootTimer:Set[${Script.RunningTime}]
				}
			}
			;; Clear all our collections every 60 seconds
			if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${ClearLootTimer}]}/1000]}>60
			{
				TempBlackList:Clear
				ClearLootTimer:Set[${Script.RunningTime}]
			}
		}
	}
}

function LootTargets()
{
	;; return if we are not ready
	if !${doLoot} || ${GV[bool,bHarvesting]} || (!${doLootInCombat} && ${Me.InCombat}) || (!${doRaidLoot} && ${Group.Count}>6)
	{
		return
	}
	
	;; Go find a lootable target
	if !${Me.Target(exists)}
	{
		call FindLootableTargets
	}

	;; Try to loot the target
	if ${Me.Target(exists)}
	{
		;; Set our variables
		variable string leftofname
		leftofname:Set[${Me.Target.Name.Left[9]}]
		
		;; Execute only if target is a corpse
		if (${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead} || ${leftofname.Equal[corpse of]})
		{
			;; Loot everything
			call LootCurrentTarget
		}
	}

}

function LootCurrentTarget()
{
	;; Set our variables
	variable int i

	;; Reset Loot Check Timer
	LootCheckTimer:Set[${Script.RunningTime}]
	
	;; Lets loot if in range
	if ${Me.Target.Distance}<5
	{
		;; wait this long before begin looting
		if ${LootDelay}
		{
			wait ${LootDelay}
		}

		;;---------------------------------
		;; The fastest way to loot
		;;---------------------------------
		if !${doLootEcho} && !${doLootOnly}
		{
			;; Quickly loot the target, generates no error messages
			Loot:LootAll
			waitframe
			
			;; Blacklist corpse if no loot - in other words, we don't want to try to loot the corpse twice
			wait 10 ${Me.Target.ID(exists)}

			if ${Me.Target.ID(exists)}
			{
				if !${Me.Target.ContainsLoot}
				{
					TempBlackList:Set[${Me.Target.ID}, ${Math.Calc[${Script.RunningTime}+10000]}]
					ClearLootTimer:Set[${Script.RunningTime}]
				}
				;; Clear targets
				if ${doClearTarget}
				{
					VGExecute "/cleartargets"
					wait 10 !${Me.Target(exists)}
				}
			}
			
			return
		}
	
		;;---------------------------------
		;; The slowest way to loot but ensures you get every item and echoes it to your console
		;;---------------------------------
		Loot:BeginLooting
		wait 5 ${Loot.NumItems}

		;; Ready to loot
		if ${Loot.NumItems}
		{
			;; Loot only the item we want
			if ${doLootOnly}
			{
				for ( i:Set[1] ; ${i}<=${Loot.NumItems} ; i:Inc )
				{
					if ${LootOnly.Equal[${Loot.Item[${i}]}]}
					{
						if ${doLootEcho}
						{
							vgecho "*Looted:  ${Loot.Item[${i}]}"
							waitframe
						}
						Loot.Item[${LootOnly}]:Loot
						waitframe
					}
				}
			}
			
			;; Loot everything
			if !${doLootOnly}
			{
				if ${doLootEcho}
				{
					;; Loot everything 1 at a time!
					for ( i:Set[1] ; ${i}<=${Loot.NumItems} ; i:Inc )
					{
						vgecho "*Looted:  ${Loot.Item[${i}]}"
						waitframe
						if ${i}<${Loot.NumItems}
						{
							Loot.Item[${i}]:Loot
							waitframe
						}
						else
						{
							Loot:LootAll
							waitframe
						}
					}
				}
				else
				{
					;; Loot everything but may miss some items due to Collects
					Loot:LootAll
					waitframe
				}
			}
		}
		Loot:EndLooting
		wait 10 ${Me.Target.ID(exists)}
		if ${Me.Target.ID(exists)}
		{
			if !${Me.Target.ContainsLoot}
			{
				TempBlackList:Set[${Me.Target.ID}, ${Math.Calc[${Script.RunningTime}+10000]}]
				ClearLootTimer:Set[${Script.RunningTime}]
			}
		}
	}
	;; Clear targets
	if ${doClearTarget}
	{
		VGExecute "/cleartargets"
		wait 10 !${Me.Target(exists)}
	}
}

function FindLootableTargets()
{
	;; Return if there are no corpses
	if !${Pawn[Corpse,radius,5](exists)}
	{
		return
	}
	
	;; declare our variables
	variable int i
	
	;; define our variables
	variable int PawnCount
	PawnCount:Set[${VG.PawnCount}]

	;; Cycle through all the Pawns withi range and find some corpses to Loot
	for ( i:Set[1] ; ${i}<=${PawnCount} ; i:Inc )
	{
		;if ${Pawn[${i}].Type.Equal[Corpse]} && ${Pawn[${i}].Distance}<5 && ${Pawn[${i}].ContainsLoot}
		if ${Pawn[${i}].Type.Equal[Corpse]} && ${Pawn[${i}].Distance}<5
		{
			;-------------------------------------------
			; Exclude things we don't want
			;-------------------------------------------
			if ${TempBlackList.Element[${Pawn[${i}].ID}](exists)}
			{
				;; Next corpse if less than 10 seconds since we last checked the corpse
				if ${Script.RunningTime} < ${TempBlackList.Element[${Pawn[${i}].ID}]}
				{
					continue
				}
				;; erase the ID if it exists
				TempBlackList:Erase[${Pawn[${i}].ID}]
			}	
			
			;; rescan corpse in 5 seconds - gives system time to span Tranquil Slivers and what not
			TempBlackList:Set[${Pawn[${i}].ID}, ${Math.Calc[${Script.RunningTime}+5000]}]
			ClearLootTimer:Set[${Script.RunningTime}]
			
			Pawn[${i}]:Target
			waitframe
			wait 3
			return
		}
	}	
}

;===================================================
;===     ATOM - CALLED AT END OF SCRIPT         ====
;===================================================
function atexit()
{
	;; Save our Settings
	SaveXMLSettings	

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/VG-Loot.xml"
	
	;; Say we are done
	EchoIt "Stopped VG-Loot Script"
}


;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][VG-Loot]: ${aText}"
	}
}

;===================================================
;===     ATOM - Load Variables from XML         ====
;===================================================
atom(script) LoadXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-Loot/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-Loot_SSR
	
	;;Load Lavish Settings 
	LavishSettings[VG-Loot]:Clear
	LavishSettings:AddSet[VG-Loot]
	LavishSettings[VG-Loot]:AddSet[MySettings]
	LavishSettings[VG-Loot]:Import[${savePath}/MySettings.xml]	
	VG-Loot_SSR:Set[${LavishSettings[VG-Loot].FindSet[MySettings]}]

	;;Set values for MySettings
	doLoot:Set[${VG-Loot_SSR.FindSetting[doLoot,TRUE]}]
	LootDelay:Set[${VG-Loot_SSR.FindSetting[LootDelay,"0"]}]
	doRaidLoot:Set[${VG-Loot_SSR.FindSetting[doRaidLoot,FALSE]}]
	doLootOnly:Set[${VG-Loot_SSR.FindSetting[doLootOnly,FALSE]}]
	LootOnly:Set[${VG-Loot_SSR.FindSetting[LootOnly,""]}]
	doLootEcho:Set[${VG-Loot_SSR.FindSetting[doLootEcho,TRUE]}]
	doLootInCombat:Set[${VG-Loot_SSR.FindSetting[doLootInCombat,TRUE]}]
	doTrash:Set[${VG-Loot_SSR.FindSetting[doTrash,FALSE]}]
	doClearTarget:Set[${VG-Loot_SSR.FindSetting[doClearTarget,TRUE]}]
}
;===================================================
;===      ATOM - Save Variables to XML          ====
;===================================================
atom(script) SaveXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-Loot/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-Loot_SSR

	;; Load Lavish Settings 
	LavishSettings[VG-Loot]:Clear
	LavishSettings:AddSet[VG-Loot]
	LavishSettings[VG-Loot]:AddSet[MySettings]
	LavishSettings[VG-Loot]:Import[${savePath}/MySettings.xml]	
	VG-Loot_SSR:Set[${LavishSettings[VG-Loot].FindSet[MySettings]}]

	;; Save MySettings
	VG-Loot_SSR:AddSetting[doLoot,${doLoot}]
	VG-Loot_SSR:AddSetting[LootDelay,${LootDelay}]
	VG-Loot_SSR:AddSetting[doRaidLoot,${doRaidLoot}]
	VG-Loot_SSR:AddSetting[doLootOnly,${doLootOnly}]
	VG-Loot_SSR:AddSetting[LootOnly,${LootOnly}]
	VG-Loot_SSR:AddSetting[doLootEcho,${doLootEcho}]
	VG-Loot_SSR:AddSetting[doLootInCombat,${doLootInCombat}]
	VG-Loot_SSR:AddSetting[doTrash,${doTrash}]
	VG-Loot_SSR:AddSetting[doClearTarget,${doClearTarget}]

	;; Save to file
	LavishSettings[VG-Loot]:Export[${savePath}/MySettings.xml]
}
