/* KBot

* Version v4 -- February 2, 2009

* Credits:
*  Created by Kram (Melee Mods by Denthan)
*  Harvesting code by Abbadon
*  Massive code re-write by MadHatter and Xeon
*  In "maintain only" mode as of 2009 by Amadeus
*
* With MUCH help from: Amadeus, dontdoit, Thanatos, Abbadon, Zeek, Xeon, Tsumari,
* Xxyn, Neriod, and every helpful person in IRC
* Thanks to those who helped beta test.
*
*/

;Including the moveto.iss file from within the common folder (see requirements above)
#include common/KB_Init.iss
#include common/KB_functions.iss
#include common/KB_Target.iss
#include common/KB_MoveTo.iss
#include common/KB_AntiAdd.iss
#include common/KB_autorespond.iss
;#include common/KB_BNavObjects.iss

#include configs/Default_Combat_Routines.iss
#include configs/Default_Config.iss

;#include configs/${Me.Class}_Combat_Routines.iss
;#include configs/${Me.Class}_Config.iss

variable string Current_Version	= 4.00

;DEBUG ECHOING -Set this to TRUE if you wish to see the debuging echo's
variable bool Verbose = FALSE

variable bool doTotallyAFK
variable bool doQuitOnDeath
variable bool doHarvest
variable bool doSkinMobs
variable bool doAddChecking
variable bool useSnareAttack
variable bool doNonAgroMobs
variable bool doLootCorpses
variable bool usePortSafe
variable bool doSprintSpeed
variable bool usePullAttack
variable bool useRangedAttack
variable bool useFinishAttack
variable bool doUseFood
variable bool doLoadArrows
variable bool doRandomWP
variable bool doSitToRegen
variable bool onlyGoodLoot

variable bool doUseMeditation
variable string meditationSpell

variable bool doUseForms
variable string formName

variable bool doUseCombatForms
variable string attackFormName
variable string defenseFormName
variable string neutralFormName
variable int changeFormPct

variable bool doForage
variable bool doArrowAssemble
variable string arrowName

variable int totalWayPoints
variable int maxMeleeRange
variable int maxPullRange
variable int minRangedDistance
variable int maxRoamingDistance
variable int maxSprintSpeed
variable int maxLootDistance

variable string pullAttack
variable string finishAttack
variable string snareAttack

variable bool useSmallHeal
variable bool useBigHeal
variable bool useFastHeal

variable string smallHeal
variable string bigHeal
variable string fastHeal

variable int smallHealPct
variable int bigHealPct
variable int fastHealPct
variable int restHealthPct
variable int restEndurancePct
variable int restEnergyPct
variable int safePortPct
variable int restFoodPct

variable int ConCheck
variable int modMinLevel
variable int modMaxLevel

variable bool doSummonPet
variable bool usePetHeal
variable string summonPetSpell
variable string petHeal
variable int petHealPct

variable bool useDKCombo
variable string DKCombo1
variable string DKCombo2

variable string BardCombatSong
variable string BardRestSong
variable string BardTravelSong
variable string PrimaryWeapon
variable string SecondaryWeapon
variable string BardTravelInstrument
variable string BardRestInstrument

variable bool doNecropsy
variable bool doGetMinions
variable bool doGetEnergy
variable string vileAbility
variable string necropsyAbility
variable int vilePct
variable string minionAbility1
variable string minionAbility2

/*  Yes this is suppose to be NONE */
variable string lastMinion = "NONE"

/* Lists */
variable collection:int64 MobBlackList
variable collection:int64 CorpseBlackList
variable collection:int64 CorpseList
variable collection:int64 HarvestBlackList
variable collection:int64 HarvestList
variable collection:int64 NecropsyBlackList
variable collection:int64 NecropsyList
variable collection:int64 getManaorMinionBlackList
variable collection:int64 getManaorMinionList

/* TargetID's */
variable int64 cTargetID
variable int64 lastTargetID

/* Current STATE of the script */
variable int cState

/* Priority State that interupts current state */
variable int pState = 0

/* A TimeOut timer */
variable time tTimeOut
variable time tStartTime

/* Some Statistic Variables */
variable float timeCheck = 1
variable int startXP = 0
variable int lastXP = 0
variable int tempXP = 0
variable int tempXPHour = 0

/* Auto Respond / Warnings variables */
variable bool isAutoRespondLoaded = TRUE
variable bool doGMAlarm = TRUE
variable bool doDetectGM = TRUE
variable bool doGMRespond = TRUE
variable bool doPlayerRespond = FALSE
variable bool doTellAlarm = TRUE
variable bool doSayAlarm = TRUE
variable bool doLevelAlarm = TRUE

; ******************
; ** Main Routine **
; ******************
function main(string Version)
{
	;Load ISXVG if its not loaded
	ext -require isxvg

	if (!${ISXVG.IsReady})
	{
		do
		{
			wait 10
		}
		while !${ISXVG.IsReady}
	}


	call KB_Init
	call InitConfig

	if !${Script[ForestRun](exists)}
	{
		runscript "${Script.CurrentDirectory}/common/forestrun.iss"
	}

	CurrentChunk:Set[${Me.Chunk}]

	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload "${Script.CurrentDirectory}/XML/KBotUI.xml"


	call PopulateLists
	call SetupAbilities

	if ${Me.Class.Equal[Bard]}
	{
		UIElement[Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:Show
	}
	elseif ${Me.Class.Equal[Dread Knight]}
	{
		UIElement[DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:Show
	}
	elseif ${Me.Class.Equal[Ranger]}
	{
		UIElement[Ranger@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:Show
	}

	; begin add by cj
	elseif ${Me.Class.Equal[Necromancer]}
	{
		UIElement[Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:Show
	}
	; end add by cj

	;echo " Your Class: ${Me.Class}   Level: ${Me.Level}"
	;echo " Killing range: ${MinLevel}- ${MaxLevel}"
	;echo " Your current Max Pulling Range is set to ${maxPullRange} meters"

	mkdir "${SaveDir}"

	Event[VG_OnIncomingCombatText]:AttachAtom[KBot_onIncomingCombatText]
	Event[VG_OnIncomingText]:AttachAtom[KBot_onIncomingText]
	Event[VG_OnPawnSpawned]:AttachAtom[KBot_onPawnSpawned]
	Event[VG_OnPawnDespawned]:AttachAtom[KBot_onPawnDespawned]

	Event[VG_onReceivedTradeInvitation]:AttachAtom[KBot_onReceivedTradeInvitation]
	Event[VG_onConnectionStateChange]:AttachAtom[KBot_onConnectionStateChange]
	Event[VG_onPawnIDChange]:AttachAtom[KBot_onPawnIDChange]
	Event[VG_onPawnStatusChange]:AttachAtom[KBot_onPawnStatusChange]

	isRunning:Set[TRUE]
	isPaused:Set[FALSE]
	hasStarted:Set[FALSE]
	CurrentWP:Set[1]
	LastWP:Set[1]

	tTimeOut:Set[${Time.Timestamp}]
	tStartTime:Set[${Time.Timestamp}]
	lastXP:Set[${Me.XP}]
	startXP:Set[${Me.XP}]

	do
	{
		if ${QueuedCommands}
		{
			ExecuteQueued
		}
		else
		{
			WaitFrame
		}

		if ${isPaused} || !${hasStarted}
		{
			wait 1
			tTimeOut:Set[${Time.Timestamp}]
			continue
		}

		; Check to see if a high Priority State was set by an error
		if ${pState}
		{
			call DebugIt ".High Priority State Change:pState: ${pState} :: ${cState}"
			cState:Set[${pState}]
			pState:Set[0]
		}

		; Check what state we are in
		if ( ${cState} == KB_PAUSE )
		{
			wait 5
		}
		else
		{
			call SetState
			call CheckState
		}

		if ( ${Math.Calc64[${Time.Timestamp} - ${tTimeOut.Timestamp}]} > 120 )
		{
			call DebugIt "NOTICE: Idle for more than 2 minutes, kickstart!"
			echo "Timeout: ${Math.Calc64[${Time.Timestamp} - ${tTimeOut.Timestamp}]}"
			cState:Set[KB_MOVE]

			tTimeOut:Set[${Time.Timestamp}]
		}

	}
	while ( ${isRunning} )


	; All done with script, save and clean up
	call SaveConfig
	call bNavi.StopMoving

	if ${Script[ForestRun](exists)}
	{
		endscript forestrun
	}

	VG:ExecBinding[movebackward,release]
	VG:ExecBinding[moveforward,release]

	call DebugIt "----- all --- MAIN --- done -----"

}

function SetState()
{
	; Now see what state we are in and what we should do next

	if !${CurrentChunk.Equal[${Me.Chunk}]}
	{
		; Oh shit, we changed Chunks!
		; Right now all kinds of stuff breaks when we change as waypoints, mobs, etc
		; Are all stored with the Chunk Name....
		; So for now, just Exit
		echo "---------------------------------------"
		echo "-   Changed Chunks -- Ending Script   -"
		echo "---------------------------------------"
		;isRunning:Set[FALSE]
		
		;; Stop all movement
		VG:ExecBinding[movebackward,release]
		VG:ExecBinding[moveforward,release]

		;; We do not want this in our future scans
		HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]

		;; Backup
		VG:ExecBinding[movebackward]
		
		;; Wait until we are back in our chunk
		while !${CurrentChunk.Equal[${Me.Chunk}]} && ${isRunning}
			waitframe

		;; backup some more
		wait 10
		
		;; stop moving
		VG:ExecBinding[movebackward,release]

		;; clear target
		VGExecute /cleartarget

		;; check for healing and drive on
		cState:Set[KB_HEAL]
	}

	if ${usePortSafe} && !${justPorted}
	{
		; See if we need to get the hell out of there!
		call SafePortCheck
		if ${Return}
		{
			cState:Set[KB_HEAL]
			return
		}
	}

	; Check to see if we are dead
	call WeAreTheDead

	if ( ${Me.XP} > ${lastXP} )
	{
		lastXP:Set[${Me.XP}]
		timeCheck:Set[${Math.Calc[${Script.RunningTime}/1000/60/60]}]
		tempXPHour:Set[${Math.Calc[(${Me.XP} - ${startXP}) / ${timeCheck}]}]
		UIElement[Title@TitleBar@KBot]:SetText["KBot -- Killing -- ${tempXPHour} XP/Hr"]
	}

	while ${Me.ToPawn.IsStunned}
	{
		call DebugIt "Stunned: ${Me.ToPawn.IsStunned}"
		wait 3
	}

/*
	if ${Me.InCombat}
	{
		call ValidTarget
		if !${Return}
		{
			call DebugIt "SetState: ValidTarget is FALSE"
			VGExecute /cleartarget
			cState:Set[KB_FINDTARGET]
		}
	}
*/

/*
	; Players Nearby?
	if ${doTotallyAFK}
	{
		call CheckForNearPlayers
		if ${Return}
		{
			call GoAFK
		}
	}
*/

/*
	; We are Drowning, get the fuck out of here!
	if ${GV[bool,bIsDrowning]}
	{
		; Let's move!
		leashToFar:Set[TRUE]
		call Roaming TRUE
	}
*/

}


function CheckState()
{
	; Wait 'till we are done casting
	call MeCasting

	call DebugIt ".                               CheckState: ${cState}"

	; Do something based on what state we are in
	switch ${cState}
	{
		case KB_WAIT
			/* We are waiting for previous action/command/etc to finish */
			;UIElement[State@CHUD]:SetText["Waiting"]
			break

		case KB_HEAL
			; Do we need to heal ourselves out of combat
			call CombatHeal
			if !${Return}
			cState:Set[KB_SAFECHECK]
			break

		case KB_SAFECHECK
			; Check to see if we are "safe" or not
			if ${Me.InCombat}
			{
				cState:Set[KB_COMBATCHECK]
				return
			}

			;call AreWeSafe
			;if ${Return}

			if ${doForage}
			call ForageCheck

			cState:Set[KB_FORMS]
			break

		case KB_FORMS
			if ${doUseForms}
			call Forms
			cState:Set[KB_BUFF]
			break

		case KB_BUFF
			call BuffUp
			cState:Set[KB_TOGGLEBUFF]
			break

		case KB_TOGGLEBUFF
			call ToggleBuffs
			if ${Me.HealthPct} < ${restHealthPct} || ${Me.EndurancePct} < ${restEndurancePct} || ${Me.EnergyPct} < ${restEnergyPct}
			cState:Set[KB_REST]
			else
			cState:Set[KB_CORPSECHECK]
			break


		case KB_REST
			; first see if there are corpses to loot
			call CorpseCheck
			if ${Return.Equal[LOOT]}
			{
				cState:Set[KB_LOOT]
				return
			}

			if ${Me.Class.Equal[Bard]}
			{
				call PlayBardSong "Rest"
			}

			call CombatHeal

			; Rest up for next fight?
			if ${Me.HealthPct} < ${restHealthPct} || ${Me.EndurancePct} < ${restEndurancePct} || ${Me.EnergyPct} < ${restEnergyPct}
			{
				call DebugIt ". Need to rest up, downtime loop started..."
				isSitting:Set[FALSE]

				do
				{
					wait 10
					call Downtime
					tTimeOut:Set[${Time.Timestamp}]
				}
				while ${Return}

				VGExecute /stand

				; Also check to see if we need to reload Ammo Case
				if ${doLoadArrows}
				{
					call LoadArrows
				}
				justAte:Set[FALSE]
				cState:Set[KB_CORPSECHECK]
			}
			else
			{
				cState:Set[KB_CORPSECHECK]
			}
			break

		case KB_CORPSECHECK
			; Check to see if there is a corpse we should loot
			call CorpseCheck
			if ${Return.Equal[LOOT]}
			{
				cState:Set[KB_LOOT]
			}
			elseif ${Return.Equal[SKIN]}
			{
				cState:Set[KB_SKIN]
			}
			elseif ${Return.Equal[NECROPSY]}
			{
				cState:Set[KB_NECROPSY]
			}
			elseif ${Return.Equal[GETENERGY]}
			{
				cState:Set[KB_GETENERGY]
			}
			elseif ${Return.Equal[GETMINIONS]}
			{
				cState:Set[KB_GETMINIONS]
			}
			else
			{
				cState:Set[KB_HARVESTCHECK]
			}
			break

		case KB_NECROPSY
			if ${Me.Class.Equal[Necromancer]}
			{
				call Necropsy
			}
			cState:Set[KB_CORPSECHECK]
			break

		case KB_GETENERGY
			if ${Me.Class.Equal[Necromancer]}
			{
				call getEnergy
			}
			cState:Set[KB_CORPSECHECK]
			break

		case KB_GETMINIONS
			if ${Me.Class.Equal[Necromancer]}
			{
				call getMinions
			}
			cState:Set[KB_CORPSECHECK]
			break

			; end add by cj
		case KB_LOOT
			if ${doLootCorpses}
			{
				call lootCorpse
				tTimeOut:Set[${Time.Timestamp}]
			}
			if ${doSkinMobs}
			{
				cState:Set[KB_CORPSECHECK]
			}
			else
			{
				cState:Set[KB_HEAL]
			}
			break

		case KB_HARVESTCHECK
			if ${doHarvest} && !${isHarvesting}
			{
				call HarvestCheck
				if ${Return}
				{
					cState:Set[KB_HARVEST]
					return
				}
			}
			cState:Set[KB_MOVE]
			break

		case KB_HARVEST
			if ${Me.Target(exists)}
			{
				; Ok, found a resource, move in for the kill!
				call DebugIt ".  Found Harvest Target"
				
				call bNavi.MovetoXYZ ${Me.Target.X} ${Me.Target.Y} ${Me.Target.Z} FALSE

				if ${Me.Target.Distance} > 5
				{
					call movetoobject ${Me.Target.ID} 4 1
					if ${Return.Equal[COLLISION]}
					{
						call DebugIt " .  Blacklist Harvest target because COLLISION: ${Me.Target.Name}"
						cState:Set[KB_HEAL]
						;HarvestBlackList:Set[${lastTargetID},${lastTargetID}]
						return
					}
				}

				wait 10
				call Harvest
				wait 10
			}
			cState:Set[KB_HEAL]
			break

		case KB_SKIN
			if ${doSkinMobs}
			{
				call skinCorpse
				tTimeOut:Set[${Time.Timestamp}]
			}
			cState:Set[KB_MOVE]
			break

		case KB_MOVE
			if ${Me.Class.Equal[Bard]}
			{
				call PlayBardSong "Travel"
			}

			; Not InCombat and nothing close by, let's move!
			call SprintStayOn

			if ${Me.InCombat}
			{
				cState:Set[KB_FINDTARGET]
				return
			}

			; The Roaming function must set the next State
			call Roaming
			break

		case KB_LEASH
			call SprintStayOn
			break

		case KB_MANAGE_ADD
			call SprintStayOn
			break

		case KB_MOVESAFE
			; Move to a safe spot
			call SprintStayOn
			; See if we need to heal and buff up
			cState:Set[KB_HEAL]
			break

		case KB_DEAD
			isRunning:Set[FALSE]
			cState:Set[KB_WAIT]
			break

		case KB_COMBATCHECK
			; First check to see if we are in combat
			if ${Me.InCombat}
			{
				call CombatHeal
				if ${Me.Target(exists)} && (${Me.Target.IsDead} || ${Me.Target.Type.Equal[Corpse]})
				{
					VGExecute /cleartarget
					; Our Target is dead and we have nothing else to fight
					; See if we need to heal and buff up
					; else find a new target
					if ${Me.Encounter} == 0
					{
						cState:Set[KB_HEAL]
					}
					else
					{
						cState:Set[KB_FINDTARGET]
					}
					return
				}
				elseif !${Me.Target(exists)}
				{
					; In Combat, but no Target
					if ${Me.Encounter} == 0
					{
						wait 10
					}
					else
					{
						cState:Set[KB_FINDTARGET]
					}
					return
				}
				else
				{
					; InCombat and Target is not dead, why are we here? FIGHT!
					cState:Set[KB_COMBATHEAL]
					return
				}
			}
			
			; If we are not in Combat but have other mobs in the Encounter
			if !${Me.InCombat} && ${Me.Encounter} > 0
			{
				call CombatHeal
				
				; Target the next mob
				cState:Set[KB_FINDTARGET]
				return
			}
			
			; Go heal and buff up
			cState:Set[KB_HEAL]
			break

		case KB_FINDTARGET
			; See if we need to heal up
			call CombatHeal
			
			; Check for new Mobs to fight
			call FindTarget
			if ${Return}
			{
				if ${usePullAttack}
				{
					cState:Set[KB_COMBATPULL]
				}
				else
				{
					cState:Set[KB_COMBATSNARE]
				}
			}
			else
			{
				cState:Set[KB_MOVE]
			}
			break

		case KB_COMBATPULL
			if ${usePullAttack}
			{
				call Pull
				tTimeOut:Set[${Time.Timestamp}]
			}
			cState:Set[KB_COMBATSNARE]
			break


		case KB_COMBATSNARE
			call SnareMob
			cState:Set[KB_COMBATBUFF]
			break

		case KB_COMBATBUFF
			if ${Me.Class.Equal[Bard]}
			{
				call PlayBardSong "Combat"
			}
			call CombatBuffsUp
			cState:Set[KB_ATTACK]
			break

		case KB_COMBATPETS
			break

		case KB_COMBATFD
			call FeigningDeath
			cState:Set[KB_HEAL]
			break

		case KB_COMBATHEAL
			; Do we need to heal ourselves?
			call CombatHeal
			call Canni
			call ValidTarget
			if !${Return}
			{
				call DebugIt ". ValidTarget is FALSE"
				VGExecute /cleartarget
				cState:Set[KB_COMBATCHECK]
				return
			}
			cState:Set[KB_ATTACK]
			break

		case KB_ATTACK
			if !${Me.InCombat}
			{
				; Not in Combat, get out of this part of the loop
				cState:Set[KB_HEAL]
			}

			call ValidTarget
			if !${Return}
			{
				call DebugIt ". ValidTarget is FALSE"
				VGExecute /cleartarget
				cState:Set[KB_COMBATCHECK]
				return
			}
			cState:Set[KB_CHAIN]
			break

		case KB_CHAIN
			call CheckForChain
			if ${Return}
			{
				cState:Set[KB_COMBATHEAL]
			}
			else
			{
				cState:Set[KB_COUNTER]
			}
			break
		case KB_COUNTER
			call CheckForCounter
			if ${Return}
			{
				cState:Set[KB_COMBATHEAL]
			}
			else
			{
				cState:Set[KB_RESCUE]
			}
			break
		case KB_RESCUE
			call CheckForRescue
			if ${Return}
			{
				cState:Set[KB_COMBATHEAL]
			}
			else
			{
				cState:Set[KB_DOT]
			}
			break

		case KB_DOT
			call ValidTarget
			if !${Return}
			{
				call DebugIt ". ValidTarget is FALSE"
				VGExecute /cleartarget
				cState:Set[KB_COMBATCHECK]
				return
			}

			; Apply any DoT's to the target
			call DoTs
			if ${Return}
			{
				cState:Set[KB_COMBATHEAL]
			}
			else
			{
				cState:Set[KB_COMBATFORMS]
			}
			break

		case KB_COMBATFORMS
			if ${doUseCombatForms}
			{
				call CombatForms
			}
			cState:Set[KB_FIGHT]
			break

		case KB_FIGHT
			tTimeOut:Set[${Time.Timestamp}]
			call Fight
			break

		default
			/* Hmm, how did we get here? */
			break
	}




/*
	; Don't fight dead things :D
	if ${Me.InCombat} && ${Me.Target(exists)} && ${Me.Target.IsDead} && ${Me.Encounter} == 0
	{
		call AreWeSafe
		if ${Return}
		{
			call DebugIt ". Target is dead and we are Safe! waiting..."
			while ${Me.InCombat} && ${Me.Encounter} == 0
			{
				wait 1
			}
		}
	}
	
	StuckLoop:Set[${StuckLoop}+1]
	
	if ${StuckLoop}>5
	{
		call DebugIt "Stuck in Main Loop: Setting Pulled to FALSE"
		StuckLoop:Set[0]
		Pulled:Set[FALSE]
	}
*/

}

; **********************
; **   Find Waypoint  **
; **********************
function:point3f FindClosestWaypoint()
{
	call DebugIt ". FindClosestWayPoint: CurrentWP: ${CurrentWP}  iCount:  ${iCount}"
	variable int iCount
	variable point3f iPoint
	variable float iDist

	iCount:Set[1]
	iDist:Set[999999999]
	while ${iCount} <= ${totalWayPoints}
	{
		if ${Math.Distance["${Me.Location}","${setPath.FindSet[${Me.Chunk}].FindSetting[waypoint_${iCount}]}"]} < ${iDist}
		{
			iDist:Set[${Math.Distance["${Me.Location}","${setPath.FindSet[${Me.Chunk}].FindSetting[waypoint_${iCount}]}"]}]
			iPoint:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[waypoint_${iCount}]}]
			CurrentWP:Set[${iCount}]
		}
		iCount:Inc
	}
	call DebugIt ". Found and Set: CurrentWP: ${CurrentWP}  iCount:  ${iCount}"
	return "${iPoint}"
}

; **********************
; **  Roaming Routine **
; **********************
function:bool Roaming(bool moveNow)
{
	call DebugIt ". Roaming: Starting Roaming Routine"

	call DoEvents

	VG:ExecBinding[movebackward,release]
	VG:ExecBinding[moveforward,release]

	variable point3f pathLoc
	variable string CPname
	variable string sTest = "NONE"
	variable int loopCount
	variable int iCount
	variable int rNum

	loopCount:Set[0]

	if ${Me.InCombat} && !${moveNow}
	{
		call DebugIt ". Roaming: InCombat is TRUE"
		return FALSE
	}

	; first, check our leash
	pathLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[waypoint_${CurrentWP}]}]

	if ${Math.Distance[${Me.X},${Me.Y},${pathLoc.X},${pathLoc.Y}]} > ${Math.Calc[${maxRoamingDistance} * 100]}
	{
		call DebugIt "Leashed to far from Waypoint_${CurrentWP} :: ${Math.Distance[${Me.X},${Me.Y},${pathLoc.X},${pathLoc.Y}]}"
		leashToFar:Set[TRUE]
	}

	if !${leashToFar} && !${moveNow}
	{
		;Target the nearest attackable pawn
		;call DebugIt "Searching For Targets while Roaming"
		call TargetInRange ${pathLoc.X} ${pathLoc.Y} ${Me.Z} ${maxRoamingDistance}
		if ${Return.Equal[MOB]}
		{
			call DebugIt "Found Target While Roaming: PreMove"
			;call bNavi.StopMoving
			;wait 5
			cState:Set[KB_FINDTARGET]
			return FALSE
		}
		elseif ${Return.Equal[CORPSE]}
		{
			call DebugIt "Found Corpse to loot While Roaming: PreMove"
			call bNavi.StopMoving
			wait 5
			cState:Set[KB_CORPSECHECK]
			return FALSE
		}
		elseif ${Return.Equal[HARVEST]}
		{
			call DebugIt "Found Harvest resource While Roaming: PreMove"
			call bNavi.StopMoving
			wait 5
			cState:Set[KB_HARVESTCHECK]
			return FALSE
		}
	}

	if ${leashToFar} || ${moveNow}
	{
		; We have moved to far from the last Waypoint, move back to it!
		iCount:Set[${CurrentWP}]
	}
	else
	{
		call DebugIt ". Roaming:  TotalWP: ${totalWayPoints}  CurrentWP: ${CurrentWP}"
		if ${WPDirection.Equal[Backward]}
		{
			LastWP:Set[${CurrentWP}]
			iCount:Set[${Math.Calc[${CurrentWP}-1]}]
			call DebugIt ".   Next WP Chosen: ${iCount} -"
			if ${iCount} <= 1
			{
				WPDirection:Set[Forward]
			}
		}
		elseif ${WPDirection.Equal[Forward]}
		{
			LastWP:Set[${CurrentWP}]
			iCount:Set[${Math.Calc[${CurrentWP}+1]}]
			call DebugIt ".   Next WP Chosen: ${iCount} +"
			if ${iCount} >= ${totalWayPoints}
			{
				WPDirection:Set[Backward]
			}
		}
	}

	if ${iCount} <= 0
	{
		iCount:Set[1]
	}

	if ${iCount} > ${totalWayPoints}
	{
		iCount:Set[${totalWayPoints}]
	}

	CurrentWP:Set[${iCount}]

	pathLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[waypoint_${iCount}]}]

	if ${pathLoc.X} == 0 || ${pathLoc.Y} == 0
	{
		call DebugIt " . Roaming ERROR, bad Waypoint_${iCount} :: ${pathLoc.X} ${pathLoc.Y} ${pathLoc.Z}"
		return FALSE
	}

	call DebugIt ". Roaming:    Moving to Waypoint_${iCount} at ${pathLoc.X} ${pathLoc.Y} ${pathLoc.Z}"

	; Setup the Path info
	call bNavi.SetupPathXYZ ${pathLoc.X} ${pathLoc.Y} ${pathLoc.Z}

	; Start Moving
	call bNavi.StartMoving

	wait 5

	call DebugIt ". Roaming: bNavi.Moving: ${bNavi.Moving}"

	do
	{
		call DoEvents
		wait 1

		if ${Me.InCombat}
		{
			call DebugIt ". Roaming: InCombat is TRUE"
			call bNavi.StopMoving
			cState:Set[KB_FINDTARGET]
			return FALSE
		}
		
		;call HarvestCheck
		;if ${Return}
		;{
		;	call DebugIt "Found Harvest resource While Roaming"
		;	call bNavi.StopMoving
		;	wait 5
		;	cState:Set[KB_HARVEST]
		;	return FALSE
		;}

		call TargetInRange ${Me.X} ${Me.Y} ${Me.Z} ${maxRoamingDistance}
		if ${Return.Equal[MOB]}
		{
			; If we are Leash'ing back, don't find more mobs to fight, just go back!
			; If we are drowning, get the hell out of the water!
			if ${leashToFar} || ${GV[bool,bIsDrowning]}
			{
				continue
			}

			call DebugIt "Found Target While Roaming"
			call bNavi.StopMoving
			wait 5
			cState:Set[KB_FINDTARGET]
			return FALSE
		}
		elseif ${Return.Equal[CORPSE]}
		{
			call DebugIt "Found Corpse to loot While Roaming"
			call bNavi.StopMoving
			wait 5
			cState:Set[KB_CORPSECHECK]
			return FALSE
		}
		elseif ${Return.Equal[HARVEST]}
		{
			call DebugIt "Found Harvest resource While Roaming"
			call bNavi.StopMoving
			wait 5
			cState:Set[KB_HARVESTCHECK]
			return FALSE
		}
	}
	while ${bNavi.Moving}

	leashToFar:Set[FALSE]

	if ${Me.Target(exists)}
	{
		call DebugIt ". Roaming: Me.Target exists!"
		return FALSE
	}

	if !${sTest.Equal[END]}
	{
		echo "Roaming: No Paths: Moving to waypoint_${iCount} directly: ${pathLoc.X} ${pathLoc.Y}"
		call DebugIt ". Roaming: No Paths: Moving to waypoint_${iCount} directly: ${pathLoc.X} ${pathLoc.Y}"
		if ${pathLoc.X} == 0 || ${pathLoc.Y} == 0
		{
			echo ".  Roaming: Error, move to pathLoc.XY is ZERO!"
			call DebugIt ".  Roaming: Error, move to pathLoc.XY is ZERO!"
			return FALSE
		}
		call moveto ${pathLoc.X} ${pathLoc.Y} 400 TRUE
		;call bNavi.FastMove ${pathLoc.X} ${pathLoc.Y} 500 NULL TRUE

		call DebugIt ". Roaming moveto: Return: ${Return}"

	}

	call DebugIt ".   Roaming DONE"

	return TRUE
}

; ***********************
; ** Downtime Routines **
; ***********************
function Downtime()
{
	call DebugIt "Starting Downtime Routine"

	call DoEvents

	if ${Me.InCombat}
	{
		call DebugIt ". Downtime: InCombat is TRUE"
		return FALSE
	}

	VG:ExecBinding[movebackward,release]
	VG:ExecBinding[moveforward,release]

	call AvoidAdds ${MobAgroRange}
	if ${Return.Equal[AGGROADD]}
	{
		call Manage_Adds
	}

	call UseMeditation

	if ${DoWeHaveMeddingHeal} && ${Me.HealthPct} < ${restHealthPct} && ${Me.Ability[${MeddingHeal}].IsReady}
	{
		;Health is low, heal up
		Me.Ability[${MeddingHeal}]:Use
		call AvoidAdds  ${MobAgroRange}
		if ${Return.Equal[AGGROADD]}
		{
			call Manage_Adds
		}
		call MeCasting
	}

	if ${doUseFood}
	call UseFoodsDrinks

	if ${Me.HealthPct} < ${restHealthPct} || ${Me.EndurancePct} < ${restEndurancePct} || ${Me.EnergyPct} < ${restEnergyPct} || ${Me.Stat["Adventuring","Jin"]} < ${RequiredJin}
	{
		if ${doSitToRegen} && !${isSitting}
		{
			VGExecute /sit
			isSitting:Set[TRUE]
		}
		return TRUE
	}

	return FALSE
}



; *******************
; **  Pull Routine **
; *******************
function:bool Pull()
{
	call DoEvents

	if ${Me.Target.IsDead} && ${Me.Encounter} == 0
	{
		call DebugIt ".Pull: Target is dead"
		return FALSE
	}

	call DebugIt ".Pull Attempt: ${PullAttempts}   Levels: ${MinLevel}-${MaxLevel}    Distance: ${maxPullRange}"
	call DebugIt ".Pull Target is: ${Me.Target.Name}"

	if !${Me.Target(exists)}
	{
		call DebugIt ". Pull: No Target to fight!"
		return FALSE
	}

	call AvoidAdds ${MobAgroRange}
	if ${Return.Equal[AGGROADD]}
	{
		call Manage_Adds
	}

	;VG:ExecBinding[movebackward,release]
	;VG:ExecBinding[moveforward,release]

	if !${Me.Target(exists)}
	{
		return FALSE
	}

	if ${doAddChecking} && ${Me.Target(exists)}
	{
		call CheckForAdds ${MobAgroRange}
		if ${Return}
		{
			call DebugIt ". Pull:  -- Mobs within ${MobAgroRange}m of Target Pull --  Aborting Pull --"
			;GUIDBlacklist:Set[${Me.Target.ID}]
			PullAttempts:Inc
			VGExecute /cleartarget
			return FALSE
		}

		call CheckForAddsInPath
		if ${Return}
		{
			call DebugIt ". Pull: --  Mobs to close to Target -- Aborting Pull --"
			;GUIDBlacklist:Set[${Me.Target.ID}]
			PullAttempts:Inc
			VGExecute /cleartarget
			return FALSE
		}
	}

	call CheckForPlayers ${PlayerAgroRange}
	if ${Return}
	{
		call DebugIt ". Pull:  Another Player too close to this mob."
		;GUIDBlacklist:Set[${Me.Target.ID}]
		PullAttempts:Inc
		VGExecute /cleartarget
		return FALSE
	}

/*
	; Skip Ownership checking for now because of a fucking bug introduced by Sigil
	if ${Me.Target.ID(exists)} && ${Me.Target.Owner(exists)} && !${Me.Target.OwnedByMe}
	{
		call DebugIt ".  Mob already engaged by anther player.  Aborting"
		;GUIDBlacklist:Set[${Me.Target.ID}]
		PullAttempts:Inc
		VGExecute /cleartarget
		return FALSE
	}
*/

	if ${Me.Target.ID(exists)} && ${Me.Target.Distance} > ${maxPullRange} && ${Me.Target.HaveLineOfSightTo}
	{
		call DebugIt ". Pull:  Moving to pull range"

		call bNavi.FastMove ${Me.Target.X} ${Me.Target.Y} ${Math.Calc[${maxPullRange}*100]} NULL FALSE
		wait 3

		if ${bNavi.Moving}
		{
			while ${bNavi.Moving}
			{
				call DoEvents
				waitframe
			}
			VG:ExecBinding[moveforward,release]
		}
		if !${Me.Target.ID(exists)}
		{
			echo ". Pull:  Error, move to Target is GONE!"
			return FALSE
		}
		if ${Me.Target.X} == 0 || ${Me.Target.Y} == 0
		{
			echo ". Pull:  Error, move to Target.XY is ZERO!"
			return FALSE
		}

	}
	
	if ${Me.Target.ID(exists)} && ${Me.Target.Distance} > ${maxPullRange} && ${Me.Target.HaveLineOfSightTo}
	{
		call DebugIt ". Pull:  Still Too Far: Moving into to pull range"
		call movetoobject ${Me.Target.ID} ${maxPullRange} 1
	}

	if ${Me.Target(exists)} && ${Me.Target.HaveLineOfSightTo}
	{
		Face
		call Tag
		if !${Return}
		{
			; We are either to far away or Pull ability not ready, try again
			call DebugIt ". Pull:  Tag returned FALSE"
			return FALSE
		}
		else
		{
			call DebugIt ". Pull:  Tag done (TRUE)"
		}
	}
	else
	{
		call DebugIt ". Pull: No Line of Sight to target"
	}

	;call ValidTarget
	;if !${Return}
	;{
	;	call DebugIt ". Pull: after Tag but ValidTarget is FALSE"
	;	PullAttempts:Inc
	;	VGExecute /cleartarget
	;	return FALSE
	;}

/*
	; Sometimes it takes a while to get into combat
	if !${Me.InCombat}
	{
		call DebugIt ". Pull: not InCombat error"
		PullAttempts:Inc
		;GUIDBlacklist:Set[${Me.Target.ID}]
		;VGExecute /cleartarget
		return FALSE
	}
*/

	PullAttempts:Set[0]
	Pulled:Set[TRUE]
	call DebugIt ".End of Pull Sub. Pulled ${Pulled}"
	return TRUE
}

; *****************************
; ** Tag Pull Target Routine **
; *****************************
function:bool Tag()
{
	if !${usePullAttack}
	{
		return TRUE
	}

	call DebugIt ".   Tag: Starting Tag Routine"

	call DoEvents

	; Tag Target using Pull Abilites
	if ${Me.Target.ID(exists)} && ${Me.Target.Distance} <= ${maxPullRange}
	{
		if ${Me.Ability[${pullAttack}].IsReady}
		{
			call DebugIt ".    Tag: Tagging with: ${pullAttack}"

			Face
			VGExecute /stand

			; First, send in the pet
			if ${Me.HavePet}
			{
				call CheckForPetAttacks
			}

			Me.Ability[${pullAttack}]:Use
			;call MeCasting
			return TRUE
		}
		else
		{
			call DebugIt ".    Tag: Pull ability was not ready"
		}
	}
	else
	{
		call DebugIt ".    Tag: Target is to Far away or does not exists"
	}
	;VG:ExecBinding[movebackward,release]
	;VG:ExecBinding[moveforward,release]

	; Either we are to far away or Pull ability not ready
	return FALSE
}

; **********************
; **  Combat Routines **
; **********************
function Fight()
{
	;call DebugIt ".Starting Fight Routine"

	call DoEvents

	; Do we need to heal ourselves?
	call CombatHeal

	if ${isHarvesting}
	{
		; Harvesting has inCombat set to true, but not really a fight
		return
	}

	call ValidTarget
	if !${Return}
	{
		call DebugIt ". Fight: Target is not Valid"

		VG:ExecBinding[movebackward,release]
		VG:ExecBinding[moveforward,release]

		VGExecute /cleartarget

		cState:Set[KB_COMBATCHECK]

		return
	}

/*
	if (${Me.TargetHealth} > 20) && ${doAddChecking}
	{
		; AvoidAdds turns to face the new Add, which is really fucked up in this function
		; Commenting it out for now.. Need to find a better way to handle adds
		call AvoidAdds ${MobAgroRange}
		if ${Return.Equal[AGGROADD]}
		{
			call Manage_Adds
		}
		face ${Me.Target.X} ${Me.Target.Y}
	}
*/

	; First, send in the pet
	if ${Me.HavePet}
	{
		call CheckForPetAttacks
	}


	; Now see what we should do based on UI choices and range
	if ${useRangedAttack} && ${Me.Target.ID(exists)} && ${Me.Target.Distance} > ${maxPullRange}
	{
		; Move into Ranged Attack
		Face
		call movetoobject ${Me.Target.ID} ${maxPullRange} 1
	}
	elseif ${useRangedAttack} && ${Me.Target.ID(exists)} && ${Me.Target.Distance} > ${minRangedDistance}
	{
		; We are probably in Ranged/Nuke cooldown here, so don't do anything
		Face
	}
	elseif ${Me.Target.ID(exists)} && ${Me.Target.Distance} > ${maxMeleeRange}
	{
		; Move into melee range
		Face
		if ${maxMeleeRange}<4
		{
			call movetoobject ${Me.Target.ID} 4 1
		}
		else
		{
			call movetoobject ${Me.Target.ID} ${maxMeleeRange} 1
		}
	}

	; We are to Close, step back
	while ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
	{
		Face
		VG:ExecBinding[movebackward]
		wait 1
		VG:ExecBinding[movebackward,release]
	}

	if ${Me.Target.ID(exists)} && !${Me.Target.HaveLineOfSightTo}
	{
		Face
		VG:ExecBinding[movebackward]
		wait 1
		VG:ExecBinding[movebackward,release]
	}

	if !${justNuked} && ${Me.Target.ID(exists)}
	{
		Face
		call Nukes
		if ${Return}
		{
			cState:Set[KB_COMBATHEAL]
			justNuked:Set[TRUE]
			return
		}
	}

	justNuked:Set[FALSE]

	if ${useRangedAttack} && ${Me.Target.ID(exists)} && ${Me.Target.Distance} > ${minRangedDistance}
	{
		Face
		call RangedAttack
		if !${Return} && ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.Target.Distance} > ${maxMeleeRange}
		{
			; Move into melee range
			Face
			if ${maxMeleeRange}<4
			{
				call movetoobject ${Me.Target.ID} 4 1
			}
			else
			{
				call movetoobject ${Me.Target.ID} ${maxMeleeRange} 1
			}
		}
	}
	elseif ${Me.Target.Distance} <= ${maxMeleeRange} && ${Me.Target.ID(exists)}
	{
		if ${useDKCombo}
		{
			Face
			call DKComboAttack
			if !${Return}
			{
				call MeleeAttack
			}
		}
		else
		{
			Face
			call MeleeAttack
		}
	}

	if (${Me.TargetHealth} < 15) && ${Me.Target.ID(exists)}
	{
		Face
		call Finishers
	}

	if ${Me.Target.ID(exists)} && !${Me.Target.HaveLineOfSightTo}
	{
		face
		VG:ExecBinding[movebackward]
		wait 1
		VG:ExecBinding[movebackward,release]
	}

	call WeAreTheDead

	;Check to be sure we should even be in combat, don't return right away, only if you're stuck in combat
	if !${Me.InCombat}
	{
		call DebugIt ". Fight: in Fight() but NOT InCombat"
		cState:Set[KB_HEAL]
		return
	}

	if ${Me.InCombat} && (!${Me.Target(exists)} || ${Me.Target.IsDead})
	{
		call DebugIt ". Fight: Target NULL or IsDead and InCombat TRUE"
		cState:Set[KB_COMBATCHECK]
		return
	}

	cState:Set[KB_COMBATHEAL]
}



; ***********************************************
; ** See if there are any Agro Mobs close by   **
; ***********************************************
function:bool AreWeSafe()
{
	; Combat is generaly not safe
	if ${Me.InCombat} || ${Me.Encounter} > 0
	{
		return FALSE
	}

	if ${Pawn[AggroNPC,radius,10](exists)}
	{
		return FALSE
	}

	; Drowning
	if ${GV[bool,bIsDrowning]}
	{
		return FALSE
	}

	return TRUE
}

; ***********************************************
; **  **
; ***********************************************
function:string CorpseCheck()
{
	variable int iCount

	; We are still in combat!
	if ${Me.InCombat} || ${Me.Encounter} > 0
	{
		call DebugIt ". CorpseCheck but still in combat"
		return "NONE"
	}

	call DebugIt ".Starting CorpseCheck Routine"

	if ${doLootCorpses}
	{
		wait 5
		iCount:Set[1]
		; Cycle through all the Pawns and find some corpses to Loot and Skin
		do
		{
			; begin add by cj
			if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < ${maxLootDistance} && ${Pawn[${iCount}].ContainsLoot}
			; end add by cj
			{
				;Be sure you haven't tried looting this corpse already
				if ${Pawn[${iCount}].ID} == ${LastCorpseID}
				{
					continue
				}
				
				if ${CorpseBlackList.Element[${Pawn[${iCount}].ID}](exists)}
				{
					continue
				}

				call DebugIt ". Found a Corpse close by with Loot flag"
				Pawn[${iCount}]:Target
				wait 10
				lastTargetID:Set[${Me.Target.ID}]
				return "LOOT"
			}
		}
		while ${iCount:Inc} < ${VG.PawnCount}
	}
	; begin add by cj
/*
	check to see if I am a necro, otherwise dont do shit
	also, only one blacklist for Energy/Minions, as you are only suppose to be able to do either/or on a corpse.  Not both
	but it is bugged currently, as to sometimes you can do both to one corpse, however I do not wish to exploit
*/
	if ${Me.Class.Equal[Necromancer]}
	{
		; check for Necropsy
		if ${doNecropsy}
		{
			wait 5
			iCount:Set[1]
			; Cycle through all the Pawns and find some corpses to Loot and Skin
			do
			{
				if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < ${maxLootDistance}
				{
					;Be sure you haven't tried looting this corpse already
					if ${Pawn[${iCount}].ID} == ${LastCorpseID}
					{
						continue
					}

					if ${NecropsyBlackList.Element[${Pawn[${iCount}].ID}](exists)}
					{
						continue
					}

					call DebugIt ". Found a Corpse close by - CJ in doNecropsy"
					Pawn[${iCount}]:Target
					wait 10
					lastTargetID:Set[${Me.Target.ID}]
					return "NECROPSY"
				}
			}
			while ${iCount:Inc} < ${VG.PawnCount}
		}
		
		; check energy percent
		if ${doGetEnergy} && (${Me.EnergyPct} <= ${vilePct})
		{
			wait 5
			iCount:Set[1]
			; Cycle through all the Pawns and find some corpses to Loot and Skin
			do
			{
				if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < ${maxLootDistance}
				{
					;Be sure you haven't tried looting this corpse already
					if ${Pawn[${iCount}].ID} == ${LastCorpseID}
					{
						continue
					}

					if ${getManaorMinionBlackList.Element[${Pawn[${iCount}].ID}](exists)}
					{
						continue
					}

					call DebugIt ". Found a Corpse close by - CJ in doGetMana"
					Pawn[${iCount}]:Target
					wait 10
					lastTargetID:Set[${Me.Target.ID}]
					return "GETENERGY"
				}
			}
			while ${iCount:Inc} < ${VG.PawnCount}
		}
		
		; check for Minions
		if ${doGetMinions}
		{
			wait 5
			iCount:Set[1]
			; Cycle through all the Pawns and find some corpses to Loot and Skin
			do
			{
				if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < ${maxLootDistance}
				{
					;Be sure you haven't tried looting this corpse already
					if ${Pawn[${iCount}].ID} == ${LastCorpseID}
					{
						continue
					}

					if ${getManaorMinionBlackList.Element[${Me.Target.ID}](exists)}
					{
						continue
					}

					call DebugIt ". Found a Corpse close by - CJ in doGetMinions"
					Pawn[${iCount}]:Target
					wait 10
					lastTargetID:Set[${Me.Target.ID}]
					return "GETMINIONS"
				}
			}
			while ${iCount:Inc} < ${VG.PawnCount}
		}
	}
	; end add by cj

	if ${doSkinMobs}
	{
		iCount:Set[1]
		wait 5

		do
		{
			; begin add by cj
			if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].IsHarvestable} && ${Pawn[${iCount}].Distance} < ${maxLootDistance} && !${Pawn[${iCount}].Name.Find[remains]}
			; end add by cj
			{
				;Be sure you haven't tried looting this corpse already
				if ${HarvestBlackList.Element[${Me.Target.ID}](exists)}
				{
					continue
				}

				call DebugIt ". Found a Corpse we can Harvest"

				Pawn[${iCount}]:Target
				wait 10
				lastTargetID:Set[${Me.Target.ID}]
				return "SKIN"
			}
		}
		while ${iCount:Inc} < ${VG.PawnCount}
	}

	return "NONE"
}


; ***********************************************
; **  **
; ***********************************************
function ValidTarget()
{
	;call DebugIt ".Starting ValidTarget Routine"

	;This checks to see if you're targetting a mob that you're not yet fighting while you have an add
	;This will stop going for the wrong mob and take on the one that's already agro'd you.

	if !${Me.Target(exists)}
	{
		call DebugIt ".  ValidTarget: Me.Target is NULL"
		return FALSE
	}

	if ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead}
	{
		call DebugIt ".  ValidTarget: Me.Target is Dead or a Corpse"
		return FALSE
	}

	;if ${Me.TargetHealth} <= 0
	;{
	;	call DebugIt ".  ValidTarget: Me.Target isDead, but Health > 0 == Keep Fighting!"
	;	return TRUE
	;}

	if ${Me.InCombat} || ${Me.Encounter} > 0
	{
		; If we are already in combat with it, who cares, FIGHT!
		return TRUE
	}

	if ${Me.Target.OwnedByMe}
	{
		return TRUE
	}

	if ${Me.Target.Owner(exists)} && ${Me.Target.Owner.Equal[${Me}]}
	{
		return TRUE
	}

	; Redone by MH
	if !${Me.Target.OwnedByMe} && ${Me.Target.Owner(exists)}
	{
		call DebugIt ".  ValidTarget: Mob already owned: ${Me.Target.Owner}"
		BadTargetID[1]:Set[${Me.Target.ID}]
		VGExecute /cleartargets
		VG:ExecBinding[moveforward,release]
		VG:ExecBinding[movebackward,release]
		return FALSE
	}

	if ${Me.Target.ID(exists)}
	{
		return TRUE
	}

	;echo End of CHecking
	return FALSE
}

; ***********************************************
; **  **
; ***********************************************
function WeAreTheDead()
{

	;This sub checks to see if we've died
	;echo in VG chat your current x, y loc incase you need to find your tombstone later.
	if ${Me.HealthPct} <= 0 || ${GV[bool,DeathReleasePopup]}
	{
		call DebugIt ". DEAD : -------- We are DEAD -------"
		call DebugIt ". DEAD Location: ${Me.X}, ${Me.Y} :: ${Me.Chunk}"

		VGLoc[TS]:Delete
		wait 25
		ISXVG:AddLoc[TS]

		echo ${Me.X}, ${Me.Y}
		wait 5

		echo "G-A-M-E O-V-E-R"

		cState:Set[KB_DEAD]

		isRunning:Set[FALSE]

		if ${doQuitOnDeath}
		{
			VGExecute /logout
		}
	}
}

; ***********************************************
; **  **
; ***********************************************
atom(script) AutoMap()
{
	; Addition by Xeon
	if !${CurrentChunk.Equal[${Me.Chunk}]}
	{
		; Check for Current Chuck
		bNavi:LoadPaths
		;CurrentRegion:Set[${bNavi.CurrentRegion}]
		;LastRegion:Set[${CurrentRegion}]
		CurrentChunk:Set[${Me.Chunk}]

		if ${setPath.FindSet[${Me.Chunk}](exists)}
		{
			totalWayPoints:Set[${setPath[${Me.Chunk}].FindSetting[totalWayPoints,0]}]
		}
		else
		{
			setPath:AddSet[${Me.Chunk}]
			setPath.FindSet[${Me.Chunk}]:AddSet[Mobs]
		}
	}
}

; ***********************************************
; **  **
; ***********************************************
atom ReturnToTombStone()
{
	VGLoc[TS]:Port
}

; ********************************************************
; ** Find out if we have anough XXX to use this ability **
; ********************************************************
function:bool CheckAbilCost(string abilString)
{
	variable bool haveEnough
	haveEnough:Set[FALSE]

	; First find out what this Ability uses, then check for correct amount
	if ${Me.Ability[${abilString}].EnergyCost} > 0
	{
		if ${Me.Energy} > ${Me.Ability[${abilString}].EnergyCost}
		{
			haveEnough:Set[TRUE]
		}
		else
		{
			return FALSE
		}
	}

	if ${Me.Ability[${abilString}].EnduranceCost} > 0
	{
		if ${Me.Endurance} > ${Me.Ability[${abilString}].EnduranceCost}
		{
			haveEnough:Set[TRUE]
		}
		else
		{
			return FALSE
		}
	}

	if ${Me.Ability[${abilString}].JinCost(exists)} && ${Me.Ability[${abilString}].JinCost} > 0
	{
		if ${Me.Stat[Adventuring,Jin]} > ${Me.Ability[${abilString}].JinCost}
		{
			haveEnough:Set[TRUE]
		}
		else
		{
			return FALSE
		}
	}

	; Sometimes there are ZERO cost abilities! FUCK!
	if ${Me.Ability[${abilString}].EnergyCost(exists)} && ${Me.Ability[${abilString}].EnergyCost} == 0 && ${Me.Ability[${abilString}].EnduranceCost(exists)} && ${Me.Ability[${abilString}].EnduranceCost} == 0
	{
		return TRUE
	}

	return ${haveEnough}
}

; ***********************************************
; **  **
; ***********************************************
function MeCasting()
{
	variable bool doBug
	;Sub to wait till casting is complete before running the next command
	if ${Me.IsCasting} || ${VG.InGlobalRecovery}
	{
		call DebugIt "MeCasting started"
		doBug:Set[TRUE]
	}

	if ${Me.IsCasting} || ${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned}
	{
		do
		{
			wait 1
		}
		while ${Me.IsCasting} || ${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned}
	}


	if ${doBug}
	call DebugIt "MeCasting Done"
}

; ***********************************************
; **  **
; ***********************************************
function DebugIt(string aText)
{
	if ${Verbose}
	{
		echo ${aText}
	}
	redirect -append "${OutputFile}" echo "${Time}:: ${aText}"
}

; ***************************
; ** Execute Queued Events **
; ***************************
function DoEvents()
{
	do
	{
		ExecuteQueued
		FlushQueued
	}
	while ${QueuedCommands}
}

; ***********************************************
; **  **
; ***********************************************
function CheckForNearPlayers()
{
	declare PawnCounter int local 1

	do
	{
		if ${Pawn[${PawnCounter}].Type.Equal[PC]}
		{
			call DebugIt ". CFNP: Player too close, going afk"
			return TRUE
		}
	}
	while ${PawnCounter:Inc} < ${VG.PawnCount}

	return FALSE
}


; ***********************************************
; **  **
; ***********************************************
function GoAFK()
{
	;players are close so need to do the afk stuff and then wait for the player to leave
	Me.Ability[${AFKAbility}]:Use

	VGExecute /afk ${AFKMessage}

	echo Player is close, holding here till they're gone...

	do
	{
		wait 20
		call DoEvents
		call CheckForNearPlayers
	}
	while ${Return} && !${Me.InCombat}
}

; ***********************************************
; **            SPRINT  ON/OFF                 **
; ***********************************************
function SprintStayOn()
{
	if ${doSprintSpeed}
	{
		;; turn sprint on if we are not sprinting
		if !${Me.IsSprinting}
		{
			Me:Sprint[${maxSprintSpeed}]
		}
	}
	else
	{
		;; turn sprint off if we are spinting
		if ${Me.IsSprinting}
		{
			Me:Sprint
		}
	}
}

; ***********************************************
; **  **
; ***********************************************
atom Afterburner()
{
	Me:Afterburner
}

; ***********************************************
; **  **
; ***********************************************
atom Sprint()
{
	if ${Me.IsSprinting}
	{
		echo "Turning OFF sprint mode"
		Me:Sprint
	}
	else
	{
		echo "Turning ON sprint mode"
		Me:Sprint[${maxSprintSpeed}]
		;Me:Sprint[60]
	}
}

; ***********************************************
; **  **
; ***********************************************
atom Port()
{
	ui -reload "${Script.CurrentDirectory}/XML/port.xml"
	echo To close Port, click the X in the upper right corner.
}

; ***********************************************
; **  **
; ***********************************************
atom Stop()
{
	call SaveConfig
	Script:End
}

; ***********************************************
; **  **
; ***********************************************
function Start()
{
	call SaveConfig

	if ${totalWayPoints} == 0
	{
		echo "---------------------"
		echo "---------------------"
		echo "---------------------"
		echo "---------------------"
		echo " You must first Setup your waypoints!"
		return
	}

	redirect "${OutputFile}" echo "${Time}: ------------- Started --------------"

	; Check to make sure we arn't to far from our last WayPoint
	call FindClosestWaypoint

	hasStarted:Set[TRUE]
	isPaused:Set[FALSE]
	cState:Set[KB_HEAL]
}

; ***********************************************
; **  **
; ***********************************************
function Pause()
{
	if !${isPaused}
	{
		return
	}

	call bNavi.StopMoving

	echo KBot isPaused!

	do
	{
		wait 5
		call DoEvents
	}
	while ${isPaused}

	echo KBot Unpaused!
}


; ***********************************************
; **  **
; ***********************************************
function:bool HarvestCheck()
{
	call DebugIt ".HarvestCheck: Finding Harvest Target"

	variable int iCount
	variable int iTotal
	variable iterator anIter
	variable index:pawn pIndex

	setConfig.FindSet[Harvest]:GetSettingIterator[anIter]

	if !${anIter:First(exists)}
	{
		return FALSE
	}

	while ( ${anIter.Key(exists)} )
	{
		if !${Pawn[resource,radius,${maxRoamingDistance},${anIter.Key}](exists)}
		{
			anIter:Next
			continue
		}

		pIndex:Clear
		iTotal:Set[${VG.GetPawns[pIndex,resource,radius,${maxRoamingDistance},${anIter.Key}]}]

		for (iCount:Set[1] ; ${iCount} <= ${iTotal} ; iCount:Inc)
		{
			if ${pIndex.Get[${iCount}].ID} == ${Me.ToPawn.ID}
			{
				continue
			}
			if ${HarvestBlackList.Element[${pIndex.Get[${iCount}].ID}](exists)}
			{
				continue
			}
			if ${pIndex.Get[${iCount}].Name.Find[remains]}
			{
				continue
			}
			if ${pIndex.Get[${iCount}].Name.Equal[${anIter.Key}]}
			{
				pIndex.Get[${iCount}]:Target
				wait 10
				if ${Me.Target(exists)}
				{
					lastTargetID:Set[${Me.Target.ID}]
					call DebugIt ". HC: Harvest resource found: ${Me.Target.Name}"
					return TRUE
				}
			}
		}
		anIter:Next
	}

	return FALSE
}


; ***********************************************
; **  **
; ***********************************************
function:bool SafePortCheck()
{
	if ${justPorted}
	{
		return FALSE
	}

	if ${Me.HealthPct} <= 0 || ${GV[bool,DeathReleasePopup]}
	{
		; TO late, we be dead
		return FALSE
	}

	;KB - Safe Location
	if ${usePortSafe}
	{
		if ${Me.HealthPct} <= ${safePortPct}
		{
			echo " -- Emergency Health Port -- ENERGIZE! "
			call DebugIt " -- Emergency Health Port -- ENERGIZE! "
			VGLoc[KB- ${Me.Chunk} -Safe]:Port
			justPorted:Set[TRUE]
			cState:Set[KB_HEAL]
			call CombatHeal
			call BuffUp
			call ToggleBuffs
			wait 100
			call CombatHeal
			call BuffUp
			call ToggleBuffs
			justPorted:Set[FALSE]
			return TRUE
		}
	}
	return FALSE
}

; ***********************************************
; **  **
; ***********************************************
/* Read in the saved Config info */
function InitConfig()
{

	LavishSettings[KB]:Clear
	setConfig:Clear
	setPath:Clear

	LavishSettings:AddSet[KB]
	LavishSettings[KB]:AddSet[Config]
	LavishSettings[KB]:AddSet[Path]

	echo Loading Configuration Setting from: ${ConfigFile}
	LavishSettings[KB]:Import["${ConfigFile}"]
	wait 10

	setConfig:Set[${LavishSettings[KB].FindSet[Config].GUID}]
	setPath:Set[${LavishSettings[KB].FindSet[Path].GUID}]

	if !${setPath.FindSet[${Me.Chunk}].FindSet[Mobs](exists)}
	{
		setPath.FindSet[${Me.Chunk}]:AddSet[Mobs]
	}

	setConfig:AddSet[MeleeAttacks]
	setConfig:AddSet[NukeAttacks]
	setConfig:AddSet[DotAttacks]
	setConfig:AddSet[RangedAttacks]
	setConfig:AddSet[PetAttacks]

	setConfig:AddSet[Chains]
	setConfig:AddSet[Counters]
	setConfig:AddSet[Rescues]

	setConfig:AddSet[Buffs]
	setConfig:AddSet[CombatBuffs]
	setConfig:AddSet[ToggleBuffs]

	setConfig:AddSet[Harvest]
	setConfig:AddSet[Food]

	; Edit by Xeon
	if !${setPath.FindSet[${Me.Chunk}](exists)}
	{
		echo Adding Chunk Region to Config: ${Me.Chunk}
		setPath:AddSet[${Me.Chunk}]
		setPath.FindSet[${Me.Chunk}]:AddSet[Mobs]
	}
	else
	{
		totalWayPoints:Set[${setPath[${Me.Chunk}].FindSetting[totalWayPoints,0]}]
		echo totalWayPoints Found in ${Me.Chunk}: ${totalWayPoints}
	}

	doTotallyAFK:Set[${setConfig.FindSetting[doTotallyAFK,FALSE]}]
	doQuitOnDeath:Set[${setConfig.FindSetting[doQuitOnDeath,FALSE]}]
	doHarvest:Set[${setConfig.FindSetting[doHarvest,FALSE]}]
	doSkinMobs:Set[${setConfig.FindSetting[doSkinMobs,FALSE]}]
	doAddChecking:Set[${setConfig.FindSetting[doAddChecking,FALSE]}]
	doNonAgroMobs:Set[${setConfig.FindSetting[doNonAgroMobs,FALSE]}]
	doLootCorpses:Set[${setConfig.FindSetting[doLootCorpses,TRUE]}]
	doSprintSpeed:Set[${setConfig.FindSetting[doSprintSpeed,TRUE]}]
	doUseFood:Set[${setConfig.FindSetting[doUseFood,FALSE]}]
	doRandomWP:Set[${setConfig.FindSetting[doRandomWP,FALSE]}]
	doLoadArrows:Set[${setConfig.FindSetting[doLoadArrows,FALSE]}]
	doSitToRegen:Set[${setConfig.FindSetting[doSitToRegen,TRUE]}]
	onlyGoodLoot:Set[${setConfig.FindSetting[onlyGoodLoot,FALSE]}]

	doGMAlarm:Set[${setConfig.FindSetting[doGMAlarm,TRUE]}]
	doDetectGM:Set[${setConfig.FindSetting[doDetectGM,TRUE]}]
	doGMRespond:Set[${setConfig.FindSetting[doGMRespond,TRUE]}]
	doPlayerRespond:Set[${setConfig.FindSetting[doPlayerRespond,FALSE]}]
	doTellAlarm:Set[${setConfig.FindSetting[doTellAlarm,TRUE]}]
	doSayAlarm:Set[${setConfig.FindSetting[doSayAlarm,TRUE]}]
	doLevelAlarm:Set[${setConfig.FindSetting[doLevelAlarm,TRUE]}]

	doUseMeditation:Set[${setConfig.FindSetting[doUseMeditation,FALSE]}]
	meditationSpell:Set[${setConfig.FindSetting[meditationSpell,NONE]}]

	doForage:Set[${setConfig.FindSetting[doForage,FALSE]}]
	doArrowAssemble:Set[${setConfig.FindSetting[doArrowAssemble,FALSE]}]
	arrowName:Set[${setConfig.FindSetting[arrowName,NONE]}]

	doUseForms:Set[${setConfig.FindSetting[doUseForms,FALSE]}]
	formName:Set[${setConfig.FindSetting[formName,NONE]}]

	doUseCombatForms:Set[${setConfig.FindSetting[doUseCombatForms,FALSE]}]
	attackFormName:Set[${setConfig.FindSetting[attackFormName,NONE]}]
	defenseFormName:Set[${setConfig.FindSetting[defenseFormName,NONE]}]
	neutralFormName:Set[${setConfig.FindSetting[neutralFormName,NONE]}]
	changeFormPct:Set[${setConfig.FindSetting[changeFormPct,15]}]

	usePortSafe:Set[${setConfig.FindSetting[usePortSafe,TRUE]}]
	safePortPct:Set[${setConfig.FindSetting[safePortPct,15]}]

	usePullAttack:Set[${setConfig.FindSetting[usePullAttack,FALSE]}]
	pullAttack:Set[${setConfig.FindSetting[pullAttack,NONE]}]
	useFinishAttack:Set[${setConfig.FindSetting[useFinishAttack,FALSE]}]
	finishAttack:Set[${setConfig.FindSetting[finishAttack,NONE]}]
	useSnareAttack:Set[${setConfig.FindSetting[useSnareAttack,FALSE]}]
	snareAttack:Set[${setConfig.FindSetting[snareAttack,NONE]}]

	useRangedAttack:Set[${setConfig.FindSetting[useRangedAttack,FALSE]}]

	maxMeleeRange:Set[${setConfig.FindSetting[maxMeleeRange,5]}]
	maxPullRange:Set[${setConfig.FindSetting[maxPullRange,24]}]
	minRangedDistance:Set[${setConfig.FindSetting[minRangedDistance,9]}]
	maxRoamingDistance:Set[${setConfig.FindSetting[maxRoamingDistance,60]}]
	maxSprintSpeed:Set[${setConfig.FindSetting[maxSprintSpeed,100]}]
	; begin add by cj
	maxLootDistance:Set[${setConfig.FindSetting[maxLootDistance,5]}]
	; end add by cj
	useSmallHeal:Set[${setConfig.FindSetting[useSmallHeal,FALSE]}]
	smallHealPct:Set[${setConfig.FindSetting[smallHealPct,80]}]
	smallHeal:Set[${setConfig.FindSetting[smallHeal,NONE]}]

	useBigHeal:Set[${setConfig.FindSetting[useBigHeal,FALSE]}]
	bigHealPct:Set[${setConfig.FindSetting[bigHealPct,50]}]
	bigHeal:Set[${setConfig.FindSetting[bigHeal,NONE]}]

	useFastHeal:Set[${setConfig.FindSetting[useFastHeal,FALSE]}]
	fastHealPct:Set[${setConfig.FindSetting[fastHealPct,30]}]
	fastHeal:Set[${setConfig.FindSetting[fastHeal,NONE]}]

	restHealthPct:Set[${setConfig.FindSetting[restHealthPct,85]}]
	restEndurancePct:Set[${setConfig.FindSetting[restEndurancePct,85]}]
	restEnergyPct:Set[${setConfig.FindSetting[restEnergyPct,85]}]
	restFoodPct:Set[${setConfig.FindSetting[restFoodPct,50]}]

	modMinLevel:Set[${setConfig.FindSetting[modMinLevel,5]}]
	modMaxLevel:Set[${setConfig.FindSetting[modMaxLevel,5]}]
	ConCheck:Set[${setConfig.FindSetting[ConCheck,2]}]

	doSummonPet:Set[${setConfig.FindSetting[doSummonPet,FALSE]}]
	usePetHeal:Set[${setConfig.FindSetting[usePetHeal,FALSE]}]
	petHeal:Set[${setConfig.FindSetting[petHeal,NONE]}]
	summonPetSpell:Set[${setConfig.FindSetting[summonPetSpell,NONE]}]
	petHealPct:Set[${setConfig.FindSetting[petHealPct,30]}]

	useDKCombo:Set[${setConfig.FindSetting[useDKCombo,FALSE]}]
	DKCombo1:Set[${setConfig.FindSetting[DKCombo1,NONE]}]
	DKCombo2:Set[${setConfig.FindSetting[DKCombo2,NONE]}]

	;begin add spud
	BardCombatSong:Set[${setConfig.FindSetting[BardCombatSong,NONE]}]
	BardRestSong:Set[${setConfig.FindSetting[BardRestSong,NONE]}]
	BardTravelSong:Set[${setConfig.FindSetting[BardTravelSong,NONE]}]
	PrimaryWeapon:Set[${setConfig.FindSetting[PrimaryWeapon,NONE]}]
	SecondaryWeapon:Set[${setConfig.FindSetting[SecondaryWeapon,NONE]}]
	BardTravelInstrument:Set[${setConfig.FindSetting[BardTravelInstrument,NONE]}]
	BardRestInstrument:Set[${setConfig.FindSetting[BardRestInstrument,NONE]}]
	;end add spud

	; begin add CJ
	doNecropsy:Set[${setConfig.FindSetting[doNecropsy,FALSE]}]
	doGetMinions:Set[${setConfig.FindSetting[doGetMinions,FALSE]}]
	doGetEnergy:Set[${setConfig.FindSetting[doGetEnergy,FALSE]}]
	vileAbility:Set[${setConfig.FindSetting[vileAbility,NONE]}]
	necropsyAbility:Set[${setConfig.FindSetting[necropsyAbility,NONE]}]
	vilePct:Set[${setConfig.FindSetting[vilePct,70]}]
	minionAbility1:Set[${setConfig.FindSetting[minionAbility1,NONE]}]
	minionAbility2:Set[${setConfig.FindSetting[minionAbility2,NONE]}]
	; end add by CJ
}

; ***********************************************
; **  **
; ***********************************************
/* Save user config to a file */
function SaveConfig()
{
	echo "VG: Saving Config Settings"

	setConfig:AddSetting[${Me.Chunk}, ${totalWayPoints}]
	setConfig:AddSetting[doTotallyAFK, ${doTotallyAFK}]
	setConfig:AddSetting[doQuitOnDeath, ${doQuitOnDeath}]
	setConfig:AddSetting[doHarvest, ${doHarvest}]
	setConfig:AddSetting[doSkinMobs, ${doSkinMobs}]
	setConfig:AddSetting[doAddChecking, ${doAddChecking}]
	setConfig:AddSetting[doNonAgroMobs, ${doNonAgroMobs}]
	setConfig:AddSetting[doLootCorpses, ${doLootCorpses}]
	setConfig:AddSetting[doSprintSpeed, ${doSprintSpeed}]
	setConfig:AddSetting[doUseFood, ${doUseFood}]
	setConfig:AddSetting[doRandomWP, ${doRandomWP}]
	setConfig:AddSetting[doLoadArrows, ${doLoadArrows}]
	setConfig:AddSetting[doSitToRegen, ${doSitToRegen}]
	setConfig:AddSetting[onlyGoodLoot, ${onlyGoodLoot}]

	setConfig:AddSetting[doGMAlarm, ${doGMAlarm}]
	setConfig:AddSetting[doDetectGM, ${doDetectGM}]
	setConfig:AddSetting[doGMRespond, ${doGMRespond}]
	setConfig:AddSetting[doPlayerRespond, ${doPlayerRespond}]
	setConfig:AddSetting[doTellAlarm, ${doTellAlarm}]
	setConfig:AddSetting[doSayAlarm, ${doSayAlarm}]
	setConfig:AddSetting[doLevelAlarm, ${doLevelAlarm}]

	setConfig:AddSetting[doUseMeditation, ${doUseMeditation}]
	setConfig:AddSetting[meditationSpell, ${meditationSpell}]

	setConfig:AddSetting[doForage, ${doForage}]
	setConfig:AddSetting[doArrowAssemble, ${doArrowAssemble}]
	setConfig:AddSetting[arrowName, ${arrowName}]

	setConfig:AddSetting[doUseForms, ${doUseForms}]
	setConfig:AddSetting[formName, ${formName}]

	setConfig:AddSetting[doUseCombatForms, ${doUseCombatForms}]
	setConfig:AddSetting[attackFormName, ${attackFormName}]
	setConfig:AddSetting[defenseFormName, ${defenseFormName}]
	setConfig:AddSetting[neutralFormName, ${neutralFormName}]
	setConfig:AddSetting[changeFormPct, ${changeFormPct}]

	setConfig:AddSetting[usePortSafe, ${usePortSafe}]
	setConfig:AddSetting[safePortPct, ${safePortPct}]

	setConfig:AddSetting[usePullAttack, ${usePullAttack}]
	setConfig:AddSetting[pullAttack, ${pullAttack}]
	setConfig:AddSetting[useFinishAttack, ${useFinishAttack}]
	setConfig:AddSetting[finishAttack, ${finishAttack}]
	setConfig:AddSetting[useSnareAttack, ${useSnareAttack}]
	setConfig:AddSetting[snareAttack, ${snareAttack}]

	setConfig:AddSetting[useRangedAttack, ${useRangedAttack}]

	setConfig:AddSetting[maxMeleeRange, ${maxMeleeRange}]
	setConfig:AddSetting[maxPullRange, ${maxPullRange}]
	setConfig:AddSetting[minRangedDistance, ${minRangedDistance}]
	setConfig:AddSetting[maxRoamingDistance, ${maxRoamingDistance}]
	setConfig:AddSetting[maxSprintSpeed, ${maxSprintSpeed}]
	; begin add by cj
	setConfig:AddSetting[maxLootDistance, ${maxLootDistance}]
	; end add by cj

	setConfig:AddSetting[useSmallHeal, ${useSmallHeal}]
	setConfig:AddSetting[smallHealPct, ${smallHealPct}]
	setConfig:AddSetting[smallHeal, ${smallHeal}]

	setConfig:AddSetting[useBigHeal, ${useBigHeal}]
	setConfig:AddSetting[bigHealPct, ${bigHealPct}]
	setConfig:AddSetting[bigHeal, ${bigHeal}]

	setConfig:AddSetting[useFastHeal, ${useFastHeal}]
	setConfig:AddSetting[fastHealPct, ${fastHealPct}]
	setConfig:AddSetting[fastHeal, ${fastHeal}]

	setConfig:AddSetting[restHealthPct, ${restHealthPct}]
	setConfig:AddSetting[restEndurancePct, ${restEndurancePct}]
	setConfig:AddSetting[restEnergyPct, ${restEnergyPct}]
	setConfig:AddSetting[restFoodPct, ${restFoodPct}]

	setConfig:AddSetting[modMinLevel, ${modMinLevel}]
	setConfig:AddSetting[modMaxLevel, ${modMaxLevel}]
	setConfig:AddSetting[ConCheck, ${ConCheck}]

	setConfig:AddSetting[doSummonPet, ${doSummonPet}]
	setConfig:AddSetting[usePetHeal, ${usePetHeal}]
	setConfig:AddSetting[petHealPct, ${petHealPct}]
	setConfig:AddSetting[summonPetSpell, ${summonPetSpell}]
	setConfig:AddSetting[petHeal, ${petHeal}]

	setConfig:AddSetting[useDKCombo, ${useDKCombo}]
	setConfig:AddSetting[DKCombo1, ${DKCombo1}]
	setConfig:AddSetting[DKCombo2, ${DKCombo2}]

	;begin add spud
	setConfig:AddSetting[BardCombatSong, ${BardCombatSong}]
	setConfig:AddSetting[BardRestSong, ${BardRestSong}]
	setConfig:AddSetting[BardTravelSong, ${BardTravelSong}]
	setConfig:AddSetting[PrimaryWeapon, ${PrimaryWeapon}]
	setConfig:AddSetting[SecondaryWeapon, ${SecondaryWeapon}]
	setConfig:AddSetting[BardRestInstrument, ${BardRestInstrument}]
	setConfig:AddSetting[BardTravelInstrument, ${BardTravelInstrument}]
	;end add spud

	; begin add by cj
	setConfig:AddSetting[doNecropsy, ${doNecropsy}]
	setConfig:AddSetting[doGetMinions, ${doGetMinions}]
	setConfig:AddSetting[doGetEnergy, ${doGetEnergy}]
	setConfig:AddSetting[vileAbility, ${vileAbility}]
	setConfig:AddSetting[necropsyAbility, ${necropsyAbility}]
	setConfig:AddSetting[vilePct, ${vilePct}]
	setConfig:AddSetting[minionAbility1, ${minionAbility1}]
	setConfig:AddSetting[minionAbility2, ${minionAbility2}]
	; end add by cj
	setPath.FindSet[${Me.Chunk}]:AddSetting[totalWayPoints, ${totalWayPoints}]

	LavishSettings[KB]:Export["${ConfigFile}"]

	bNavi:SavePaths

}

; ***********************************************
; **  **
; ***********************************************
atom(script) AddWaypoint()
{
	totalWayPoints:Inc

	; Edit by Xeon
	setPath.FindSet[${Me.Chunk}]:AddSetting[waypoint_${totalWayPoints}, "${Me.Location}"]

	echo "Adding waypoint_${totalWayPoints} at ${Me.Location}"
}

atom(script) ClearWaypoints()
{
	setPath.FindSet[${Me.Chunk}]:Clear
	UIElement[MobList@Mobs@MainTabs@MainFrame@Main@KBot@KBot]:ClearItems

	totalWayPoints:Set[0]

	echo "Clearing all Waypoints for ${Me.Chunk}"
}


; ***********************************************
; **  **
; ***********************************************
atom(global) AddMeleeAttack(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[MeleeAttacks]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveMeleeAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[MeleeAttacks].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddNukeAttack(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[NukeAttacks]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveNukeAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[NukeAttacks].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddDotAttack(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[DotAttacks]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveDotAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[DotAttacks].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddRangedAttack(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[RangedAttacks]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveRangedAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[RangedAttacks].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddPetAttack(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[PetAttacks]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemovePetAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[PetAttacks].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddChain(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[Chains]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveChain(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[Chains].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddCounter(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[Counters]:AddSetting[${aName}, ${aName}]
		echo "Adding Counter: ${aName}"
	}
}
atom(global) RemoveCounter(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[Counters].FindSetting[${aName}]:Remove
		echo "Removing Counter: ${aName}"
	}
}

atom(global) AddRescue(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[Rescues]:AddSetting[${aName}, ${aName}]
		echo "Adding Rescue: ${aName}"
	}
}
atom(global) RemoveRescue(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[Rescues].FindSetting[${aName}]:Remove
		echo "Removing Rescue: ${aName}"
	}
}

atom(global) AddBuff(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[Buffs]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[Buffs].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddCombatBuff(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[CombatBuffs]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveCombatBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[CombatBuffs].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddToggleBuff(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[ToggleBuffs]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveToggleBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[ToggleBuffs].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddHarvestList(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[Harvest]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveHarvestList(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[Harvest].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}

atom(global) AddMobList(string aName)
{
	if !${setPath.FindSet[${Me.Chunk}].FindSet[Mobs](exists)}
	setPath.FindSet[${Me.Chunk}]:AddSet[Mobs]

	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setPath.FindSet[${Me.Chunk}].FindSet[Mobs]:AddSetting["${aName}","${aName}"]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveMobList(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setPath.FindSet[${Me.Chunk}].FindSet[Mobs].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}
atom(global) BuildMobList()
{
	variable int iCount = 0

	UIElement[MobCombo@Mobs@MainTabs@MainFrame@Main@KBot@KBot]:ClearItems

	do
	{
		if (${Pawn[${iCount}].Type.Equal[NPC]} || ${Pawn[${iCount}].Type.Equal[AggroNPC]})
		{
			UIElement[MobCombo@Mobs@MainTabs@MainFrame@Main@KBot@KBot]:AddItem[${Pawn[${iCount}].Name}]
		}
	}
	while ${iCount:Inc} < ${VG.PawnCount}
}

atom(global) AddFood(string aName)
{
	if (${aName.Length} > 1) && !${aName.Equal[NONE]}
	{
		setConfig.FindSet[Food]:AddSetting[${aName}, ${aName}]
		echo "Adding: ${aName}"
	}
}
atom(global) RemoveFood(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		setConfig.FindSet[Food].FindSetting[${aName}]:Remove
		echo "Removing: ${aName}"
	}
}
atom(global) BuildFoodList()
{
	variable int iCount = 0

	UIElement[FoodCombo@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot]:ClearItems

	while ${Me.Inventory[${iCount:Inc}].Name(exists)}
	{
		;if ${Me.Inventory[${iCount}].MiscDescription.Find[Small item]}
		if ${Me.Inventory[${iCount}].Type.Equal[Unknown]} || ${Me.Inventory[${iCount}].Type.Equal[Miscellaneous]}
		{
			UIElement[FoodCombo@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Inventory[${iCount}].Name}]
		}
	}
}

; ***********************************************
; **  **
; ***********************************************
function PopulateLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{

		;add spud - added a check for songs, since they shouldn't show in these lists.  They aren't really songs, but melodies that are part of songs.
		if (${Me.Ability[${i}].TargetType.Equal[Offensive]} || ${Me.Ability[${i}].IsOffensive}) && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue} && !${Me.Ability[${i}].Type.Equal[Song]}
		{
			;;; Attack Tab
			;Melee
			if ${Me.Ability[${i}].Type.Equal[Combat Art]}
			{
				UIElement[MeleeCombo@Attacks@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[FinishCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[DKCombo2@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
			}
			;Nukes
			if ${Me.Ability[${i}].Type.Equal[Spell]}
			{
				UIElement[NukeCombo@Attacks@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[DKCombo1@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
			}
			;DoTs
			if ${Me.Ability[${i}].Type.Equal[Combat Art]} || ${Me.Ability[${i}].Type.Equal[Spell]}
			{
				UIElement[DotCombo@Attacks@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
			}

			;;; Pull Tab
			;Pull
			if (${Me.Ability[${i}].Range} > 5)
			{
				UIElement[PullCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[RangedCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[SnareCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
			}
		}

		;;; Chains Tab
		if ${Me.Ability[${i}].IsChain}
		{
			UIElement[ChainCombo@Chains@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
		}
		if ${Me.Ability[${i}].IsCounter}
		{
			UIElement[CounterCombo@Chains@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
		}
		if ${Me.Ability[${i}].IsRescue}
		{
			UIElement[RescueCombo@Chains@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
		}

		if !${Me.Ability[${i}].IsOffensive} && !${Me.Ability[${i}].Type.Equal[Combat Art]} && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue}
		{
			;;; Buff Tab
			;Buffs
			;CombatBuff
			if ${Me.Ability[${i}].TargetType.Equal[Self]} || ${Me.Ability[${i}].TargetType.Equal[Defensive]} || ${Me.Ability[${i}].TargetType.Equal[Group]} || ${Me.Ability[${i}].TargetType.Equal[Ally]}
			{
				UIElement[BuffCombo@Buffs@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[CombatBuffCombo@Buffs@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[ToggleBuffCombo@Buffs@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
			}
		}

		if !${Me.Ability[${i}].IsOffensive} && !${Me.Ability[${i}].TargetType.Equal[Offensive]} && !${Me.Ability[${i}].Type.Equal[Combat Art]} && !${Me.Ability[${i}].IsChain} && !${Me.Ability[${i}].IsCounter} && !${Me.Ability[${i}].IsRescue}
		{
			;;; Heal Tab
			if ${Me.Ability[${i}].Type.Equal[Spell]}
			{
				;Spell and Defensive
				UIElement[SmallHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[BigHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[FastHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[PetCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[PetHealCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[MeditationCombo@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				; begin add by cj
				UIElement[doGetEnergyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[doNecropsyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[doGetMinionsCombo1@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				UIElement[doGetMinionsCombo2@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Ability[${i}].Name}]
				; end add by cj
			}
		}
	}

	for (i:Set[1] ; ${i} <= ${Me.Pet.Ability} ; i:Inc)
	{
		UIElement[PetAttackCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Pet.Ability[${i}].Name}]
	}

	for (i:Set[1] ; ${i} <= ${Me.Form} ; i:Inc)
	{
		UIElement[FormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Form[${i}].Name}]
		UIElement[AttackFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Form[${i}].Name}]
		UIElement[DeffenseFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Form[${i}].Name}]
		UIElement[NeutralFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Me.Form[${i}].Name}]
	}

	;begin add spud
	for (i:Set[1] ; ${i} <= ${Songs} ; i:Inc)
	{
		UIElement[BardCombatSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Songs[${i}].Name}]
		UIElement[BardRestSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Songs[${i}].Name}]
		UIElement[BardTravelSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Songs[${i}].Name}]
	}
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		if (${Me.Inventory[${i}].Keyword2.Find[Instrument]})
		{
			;add instruments
			UIElement[BardRestInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Inventory[${i}].Name}]
			UIElement[BardTravelInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Inventory[${i}].Name}]
		}
		if (${Me.Inventory[${i}].Type.Equal[Weapon]})
		{
			;add weapons
			UIElement[PrimaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Inventory[${i}].Name}]
			UIElement[SecondaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Inventory[${i}].Name}]
		}
		if (${Me.Inventory[${i}].Type.Equal[Shield]})
		{
			;add shield/parrying daggers
			UIElement[SecondaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Me.Inventory[${i}].Name}]
		}
	}
	;end add spud

/*
	Load up all the UI info from Saved info
*/

	variable iterator Iterator

	setConfig.FindSet[MeleeAttacks]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[MeleeList@Attacks@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[NukeAttacks]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[NukeList@Attacks@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[DotAttacks]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotList@Attacks@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[RangedAttacks]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[RangedList@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[PetAttacks]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PetAttackList@@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[Chains]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ChainList@Chains@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[Counters]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CounterList@Chains@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[Rescues]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[RescueList@Chains@CombatTabs@CombatFrame@Combat@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[Buffs]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffList@Buffs@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[CombatBuffs]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CombatBuffList@Buffs@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[ToggleBuffs]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ToggleBuffList@Buffs@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setPath.FindSet[${Me.Chunk}].FindSet[Mobs]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[MobList@Mobs@MainTabs@MainFrame@Main@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[Harvest]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[HarvestList@Harvest@MainTabs@MainFrame@Main@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	setConfig.FindSet[Food]:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FoodList@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

	;;;;;;;;;;;;;;;;;;;

	variable int rCount

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[SmallHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[SmallHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${smallHeal}]}
		{
			UIElement[SmallHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BigHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[BigHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${bigHeal}]}
		{
			UIElement[BigHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[FastHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[FastHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${fastHeal}]}
		{
			UIElement[FastHealCombo@Heal@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[PullCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot].Items}
	{
		if ${UIElement[PullCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot].Item[${rCount}].Text.Equal[${pullAttack}]}
		{
			UIElement[PullCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:SelectItem[${rCount}]
		}
	}

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[FinishCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot].Items}
	{
		if ${UIElement[FinishCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot].Item[${rCount}].Text.Equal[${finishAttack}]}
		{
			UIElement[FinishCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[SnareCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot].Items}
	{
		if ${UIElement[SnareCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot].Item[${rCount}].Text.Equal[${snareAttack}]}
		{
			UIElement[SnareCombo@Pull@CombatTabs@CombatFrame@Combat@KBot@KBot]:SelectItem[${rCount}]
		}
	}

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[MeditationCombo@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[MeditationCombo@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${meditationSpell}]}
		{
			UIElement[MeditationCombo@Rest@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[ArrowSelectCombo@Harvest@MainTabs@MainFrame@Main@KBot@KBot].Items}
	{
		if ${UIElement[ArrowSelectCombo@Harvest@MainTabs@MainFrame@Main@KBot@KBot].Item[${rCount}].Text.Equal[${arrowName}]}
		{
			UIElement[ArrowSelectCombo@Harvest@MainTabs@MainFrame@Main@KBot@KBot]:SelectItem[${rCount}]
		}
	}

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[FormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[FormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${formName}]}
		{
			UIElement[FormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[AttackFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[AttackFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${attackFormName}]}
		{
			UIElement[AttackFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[DeffenseFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[DeffenseFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${defenseFormName}]}
		{
			UIElement[DeffenseFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[NeutralFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Items}
	{
		if ${UIElement[NeutralFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot].Item[${rCount}].Text.Equal[${neutralFormName}]}
		{
			UIElement[NeutralFormCombo@Forms@SettingTabs@SettingFrame@Setting@KBot@KBot]:SelectItem[${rCount}]
		}
	}

	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[PetCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[PetCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${summonPetSpell}]}
		{
			UIElement[PetCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[PetHealCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[PetHealCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${petHeal}]}
		{
			UIElement[PetHealCombo@Pets@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	;begin add spud
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BardCombatSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[BardCombatSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${BardCombatSong}]}
		{
			UIElement[BardCombatSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BardRestSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[BardRestSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${BardRestSong}]}
		{
			UIElement[BardRestSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BardTravelSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[BardTravelSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${BardTravelSong}]}
		{
			UIElement[BardTravelSong@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[PrimaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[PrimaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${PrimaryWeapon}]}
		{
			UIElement[PrimaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[SecondaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[SecondaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${SecondaryWeapon}]}
		{
			UIElement[SecondaryWeapon@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BardTravelInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[BardTravelInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${BardTravelInstrument}]}
		{
			UIElement[BardTravelInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BardRestInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[BardRestInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${BardRestInstrument}]}
		{
			UIElement[BardRestInstrument@Bard@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	;end add spud
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[DKCombo1@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[DKCombo1@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${DKCombo1}]}
		{
			UIElement[DKCombo1@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[DKCombo2@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[DKCombo2@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${DKCombo2}]}
		{
			UIElement[DKCombo2@DK@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	; begin add by cj
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[doNecropsyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[doNecropsyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${necropsyAbility}]}
		{
			UIElement[doNecropsyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[doGetMinionsCombo1@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[doGetMinionsCombo1@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${minionAbility1}]}
		{
			UIElement[doGetMinionsCombo1@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[doGetMinionsCombo2@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[doGetMinionsCombo2@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${minionAbility2}]}
		{
			UIElement[doGetMinionsCombo2@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[doGetEnergyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Items}
	{
		if ${UIElement[doGetEnergyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot].Item[${rCount}].Text.Equal[${vileAbility}]}
		{
			UIElement[doGetEnergyCombo@Necro@Class@ExtraTabs@ExtraFrame@Extra@KBot@KBot]:SelectItem[${rCount}]
		}
	}
	; end add by cj
}

; ***********************************************
; **  **
; ***********************************************
function atexit()
{

	;redirect -append "${OutputFile}" echo "${Time.Timestamp}: ${Me.FName} had ${TotalKills} Kills and Total XP gained was ${GainedXP}"

	if ${Script[ForestRun](exists)}
	{
		endscript ForestRun
	}

	;Script has been ended, release the movement keys incease moveto has them pressed
	echo "-- Ending KBot --"
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	ui -unload "${Script.CurrentDirectory}/XML/KBotUI.xml"

	;Remove the event listeners
	Event[VG_OnPawnSpawned]:DetachAtom[KBot_onPawnSpawned]
	Event[VG_OnPawnDespawned]:DetachAtom[KBot_onPawnDespawned]
	Event[VG_OnIncomingText]:DetachAtom[KBot_onIncomingText]
	Event[VG_OnIncomingCombatText]:DetachAtom[KBot_onIncomingCombatText]

	Event[VG_onReceivedTradeInvitation]:DetachAtom[KBot_onReceivedTradeInvitation]
	Event[VG_onConnectionStateChange]:DetachAtom[KBot_onConnectionStateChange]
	Event[VG_onPawnIDChange]:DetachAtom[KBot_onPawnIDChange]
	Event[VG_onPawnStatusChange]:DetachAtom[KBot_onPawnStatusChange]

}


; ***********************************************
; **                   EVENTS                  **
; ***********************************************

atom(script) KBot_onPawnStatusChange(string aChangeType, int64 aPawnID, string aPawnName)
{
	call DebugIt "Pawn Status Change: ${aPawnName} (${aPawnID}) is now: ${aChangeType}"

	if ${aPawnID} == ${cTargetID} && ${aChangeType.Equal[NowDead]}
	{
		call DebugIt "Current Target is Dead"
		cTargetID:Set[0]
		VGExecute /cleartargets
	}

}

atom(script) KBot_onPawnDespawned(string anID, string aName)
{
	;call DebugIt "Pawn Despawned: ${aName} :: ${anID}"

	; if it's on the blacklist, remove it
	if ${MobBlackList.Element[${oldID}](exists)}
	{
		MobBlackList:Erase[${oldID}]
	}

	if ${CorpseList.Element[${oldID}](exists)}
	{
		CorpseList:Erase[${oldID}]
	}

	if ${HarvestList.Element[${oldID}](exists)}
	{
		HarvestList:Erase[${oldID}]
	}
	
	;begin add by cj
	if ${NecropsyBlackList.Element[${oldID}](exists)}
	{
		NecropsyBlackList:Erase[${oldID}]
	}

	if ${getManaorMinionBlackList.Element[${oldID}](exists)}
	{
		getManaorMinionBlackList:Erase[${oldID}]
	}
	;end add by cj
}

atom(script) KBot_onPawnSpawned(string anID, string aName, string aLevel, string aType)
{
	;call DebugIt "Pawn Spawned: ${aName} (${anID}) :: ${aLevel} :: ${aType}"
}

atom(script) KBot_onPawnIDChange(int64 oldID, int64 newID, string oldName, string newName)
{
	call DebugIt "Pawn ID Change: ${oldName} (${oldID}) is now: ${newName} (${newID})"

	; if it's on the blacklist, remove it
	if ${MobBlackList.Element[${oldID}](exists)}
	{
		MobBlackList:Erase[${oldID}]
	}

	if ${CorpseList.Element[${oldID}](exists)}
	{
		CorpseList:Erase[${oldID}]
	}

	if ${HarvestList.Element[${oldID}](exists)}
	{
		HarvestList:Erase[${oldID}]
	}
	
	;begin add by cj
	if ${NecropsyBlackList.Element[${oldID}](exists)}
	{
		NecropsyBlackList:Erase[${oldID}]
	}

	if ${getManaorMinionBlackList.Element[${oldID}](exists)}
	{
		getManaorMinionBlackList:Erase[${oldID}]
	}
	;end add by cj
}

atom(script) KBot_onReceivedTradeInvitation(string PCName)
{
	call DebugIt "VG: TradeInvitation with ${PCName} :: TS: ${Trade.State}"

	if ${isPaused} || !${isRunning}
	{
		return
	}

	;["TRADING", "INVITE_PENDING", "INVITE_SENT", "NOT_TRADING"]
	if ${Trade.State.Equal[TRADING]} || ${Trade.State.Equal[INVITE_PENDING]} || ${Trade.State.Equal[INVITE_SENT]}
	{
		Trade:DeclineInvite
	}

	if ${Trade.State.Equal[TRADING]} || ${Trade.State.Equal[INVITE_PENDING]} || ${Trade.State.Equal[INVITE_SENT]}
	{
		Trade:Cancel
	}
}

/* Detect Login/Logout changes */
atom(script) KBot_onConnectionStateChange(string NewConnectionState)
{
	;AT_CHARACTER_SELECT
	;IN_CHARACTER_CUSTOMIZATION
	;IN_GAME

	call DebugIt "VG: Connection State: ${NewConnectionState}"

	if ( ${NewConnectionState.Equal[AT_CHARACTER_SELECT]} )
	{
		; Hmm, how did we get here?
		call DebugIt " ========================================LOGOUT=================================="
		call DebugIt "VG:                            Error, character logged out!"
		call DebugIt " ========================================LOGOUT=================================="
		isRunning:Set[FALSE]
	}
}

atom(script) KBot_onIncomingText(string aText, string ChannelNumber, string ChannelName)
{

	; Send it off to the auto-response code for processsing
	call AutoRespond "${aText}" "${ChannelNumber}"

	if ${aText.Find[You have slain]}
	{
		call DebugIt "OnIncomingText: ${aText}"
	}

	if ${aText.Find[skill to begin harvesting]} && ${Me.Target(exists)}
	{
		HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
	}

}

atom(script) KBot_onIncomingCombatText(string aText, int iType)
{
	if ${aText.Find[You have slain]}
	{
		call DebugIt "CombatText: ${aText}"
	}

	if ${aText.Find[have no line of sight]}
	{
		call DebugIt "CombatText: ${aText}"
	}
}