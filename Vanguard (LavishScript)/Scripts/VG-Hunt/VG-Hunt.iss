;-----------------------------------------------------------------------------------------------
; Hunt.iss
;
; Description - a handy tool to use for hunting for target based upon the parameters you set. 
;
; Notes - uses LavishNav (a tool that maps the area and establish waypoints so that you can navigate
;  between points you set while it hunts for targets)
;
; Will not do - fight the target for you.  You need to write your own routine to do that.

; -----------
; * Hunts:
;    -type: NPC or AggroNPC
;    -level: low to high range
;    -difficulty: compare it to a 3-dot, 4-dot, et cetera
;    -line of sight
;    -loot: moves to corpse and loots it
;    -camp: summons tombstone, loot it, and then camps out of the game
;
; Revision History
; ----------------
; 20130408 (Zandros)
; * Wrote the basics of the routine
;
; 20130410 (Zandros)
; * Fine-tune the routines and added instant loot routines
;
; 20130414 (Zandros)
; * Added windows for easy management
;
; 20130419 (Zandros)
; * If you have no line of sight, it will now backup and
;   pull your pet to you forcing the target to come to you
;
; 20130421 (Zandros)
; * Added the most common foods to eat when resting.
;
; 20130422 (Zandros)
; * Thank you Amadeus for fixing the Altar not able to be clicked
;
; 20130424 (Zandros)
; * Fixed an issue with classes not having any Energy or Endurance
;
;===================================================
;===               Includes                     ====
;===================================================
;
#include ./VG-Hunt/Includes/FindTarget.iss
#include ./VG-Hunt/Includes/Obj_Navigator.iss
;
;===================================================
;===               Variables                    ====
;===================================================
;
;; system variables
variable int i
variable bool isRunning = TRUE
variable bool isPaused = FALSE
variable int64 CurrentTargetID = 0
variable int TotalKills = 0
variable bool doreturnHome = FALSE
variable bool WeAreDead = FALSE
variable float HomeX
variable float HomeY
variable filepath DebugFilePath = "${Script.CurrentDirectory}/Saves"
variable bool NeedMoreEnergy = FALSE

variable collection:int64 BlackListTarget

;; XML variables used to store and save data
variable settingsetref options
variable settingsetref MyPath

;; UI - Hunt Tab
variable bool doScanAreaForTarget = FALSE
variable bool doMoveBetweenWaypoints = FALSE
variable bool doCheckLineOfSight = TRUE
variable bool doAggroNPC = FALSE
variable bool doNPC = TRUE
variable bool doLoot = TRUE
variable bool doCamp = TRUE
variable int PullDistance = 22
variable int MaxDistance = 30
variable int MinimumLevel = ${Me.Level}
variable int MaximumLevel = ${Me.Level}
variable int DifficultyLevel = 2

;; Navigator variables
variable int TotalWayPoints = 0
variable int CurrentWayPoint = 0
variable int WhatStepWeOn = 0
variable bool CountUp = FALSE
variable bool BUMP = FALSE

;; initialize our objects
variable(global) Obj_Navigator Navigate

;===================================================
;===               Main Routine                 ====
;===================================================
function main()
{
	;-------------------------------------------
	; INITIALIZE - setup script
	;-------------------------------------------
	call Initialize

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning} && ${Me(exists)}
	{
		if ${GV[bool,DeathReleasePopup]}
		{
			EchoIt "We are dead! (wait for 10 minutes)"
			WeAreDead:Set[TRUE]
			if ${Navigate.isMoving}
			{
				;; Stop all movements (turning, strafing, forward, and backward)
				Navigate:Stop
				VGExecute "/stand"
				waitframe
				VG:ExecBinding[turnright,release]
				waitframe
				VG:ExecBinding[turnleft,release]
				waitframe
				VG:ExecBinding[StrafeLeft,release]
				waitframe
				VG:ExecBinding[StrafeRight,release]
				waitframe
				VG:ExecBinding[moveforward,release]
				waitframe
				VG:ExecBinding[movebackward,release]
				waitframe
			}
			;; wait until we are teleported to the nearest altar (can be in a different chunk)
			while ${GV[bool,DeathReleasePopup]}
				waitframe
		}
		
		if ${Me.Target(exists)}
			call HaveTargetRoutine
		if !${Me.Target(exists)}
			call NoTargetRoutine
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================
;===         Initialize Subroutine              ====
;===================================================
function Initialize()
{
	;-------------------------------------------
	; Load ISXVG or exit script
	;-------------------------------------------
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "Unable to load ISXVG, exiting script"
		endscript VG-Hunt
	}
	echo "Started Hunt Script"
	wait 30 ${Me.Chunk(exists)}

	;-------------------------------------------
	; Delete our debug file so that it doesn't get too big
	;-------------------------------------------
	if ${DebugFilePath.FileExists[/Debug.txt]}
		rm "${DebugFilePath}/Debug.txt"

	;-------------------------------------------
	; Reload the UI
	;-------------------------------------------
	call loadxmls
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	wait 5
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-Hunt.xml"
	;UIElement[VG-Hunt]:SetWidth[280]
	;UIElement[VG-Hunt]:SetHeight[400]
	wait 5

	;; Add in our events
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[ChatEvent]
	Event[VG_onAlertText]:AttachAtom[AlertEvent]
	Event[VG_onPawnStatusChange]:AttachAtom[PawnStatusChange]

	;; Turn mapping ON
	Navigate:StartMapping
}

;===================================================
;===         HaveTargetRoutine Subroutine       ====
;===================================================
function HaveTargetRoutine()
{
	if !${Me.TargetAsEncounter.Difficulty(exists)}
		wait 10 ${Me.TargetAsEncounter.Difficulty(exists)}
		
	CurrentTargetID:Set[${Me.Target.ID}]

	if ${Navigate.isMoving}
	{
		;; We better stop moving if we have a target
		Navigate:Stop
		VGExecute "/stand"
		waitframe
		VG:ExecBinding[turnright,release]
		waitframe
		VG:ExecBinding[turnleft,release]
		waitframe
		VG:ExecBinding[StrafeLeft,release]
		waitframe
		VG:ExecBinding[StrafeRight,release]
		waitframe
		VG:ExecBinding[moveforward,release]
		waitframe
		VG:ExecBinding[movebackward,release]
		waitframe
	}

	
	;; Something is blocking us from hitting the target
	if ${NoLineOfSight}
		call FixLineOfSight

		
	;; Move closer if we have a target (we set the distance)
	if ${Me.Target.Distance}>${PullDistance}
	{
		if ${doNPC} && ${Me.Target.Type.Equal[NPC]}
			call MoveCloser ${PullDistance}
		if ${doAggroNPC} && ${Me.Target.Type.Equal[AggroNPC]}
			call MoveCloser ${PullDistance}
	}

	
	;; Backup if we are too close
	if ${Me.Target(exists)} && ${Me.Target.Distance}<1
	{
		while ${Me.Target(exists)} && ${Me.Target.Distance}<1
		{
			Me.Target:Face
			VG:ExecBinding[movebackward]
		}
		VG:ExecBinding[movebackward,release]
	}

	
	;; Move closer if target has loot - must be less than 5 so anything less than that will work
	if ${Me.Target.ContainsLoot}
	{
		call MoveCloser 4
		if ${doLoot} && ${Me.Target.ContainsLoot} && ${Me.Target.Distance}<=5
		{
			Loot:LootAll
			waitframe
			VGExecute "/cleartargets"
			wait 30
		}
	}
	
	;; Hmmm, we are going to do nothing with the target because we only find targets!
}



;===================================================
;===       NoTargetRoutine Routine            ====
;===================================================
function NoTargetRoutine()
{
	NoLineOfSight:Set[FALSE]
	LoSRetries:Set[0]

	if ${WeAreDead}
	{
		;WeAreDead:Set[FALSE]
		if ${doCamp}
		{
			;wait 600 ${Pawn[Altar](exists)}
			
			;; check the altar for any tombstones
			Pawn[Altar]:DoubleClick
			wait 10
			if ${Me.Target.Name.Equal[Altar]}
			{
				Dialog[General,"I'd like to summon my earthly remains."]:Select 
				wait 10
				Altar[Corpse,1]:Summon
				wait 10
				Altar[Corpse,1]:Cancel
			}
			if ${Pawn[Tombstone,range,20](exists)}
				VGExecute "/targetmynearestcorpse"
			wait 10
			if ${Me.Target(exists)} && ${Me.Target.Name.Find[Tombstone]} && ${Me.Target.Name.Find[${Me}]}
			{
				VGExecute "/corpsedrag"
				VGExecute "/lootall"
				wait 10
				VGExecute /cleartargets
				wait 10
			}
			EchoIt "Camping"
			vgecho "Camping"
			waitframe
			VGExecute /camp
			wait 152 ${Me.Encounter} || ${Me.InCombat} || ${Me.Target(exists)}
			if !${Me.InCombat} && !${Me.Encounter} && !${Me.Target(exists)}
			{
				endscript VG-Hunt
				waitframe
			}
		}
		
		call FindNearestWayPoint
		CurrentWayPoint:Set[${Return}]
		if ${CurrentWayPoint}
		{
			EchoIt "Moving to Neareast Waypoint: ${CurrentWayPoint} of ${TotalWayPoints}"
			Navigate:MoveToPoint[WP-${CurrentWayPoint}]
			wait 40 ${Navigate.isMoving}
		}
		;; this check is to ensure we are moving
		EchoIt "isMoving=${Navigate.isMoving}"
		return
	}
	
	;; Ensure difficulty of target doesn't exist when you do not have a target
	wait 10 !${Me.TargetAsEncounter.Difficulty(exists)}
	
	;; This is where we will consume whatever we want to restore both health and energy
	if ${Me.HealthPct} < 70 && ${Me.Inventory[Great Roseberries].IsReady}
	{
		Me.Inventory[Great Roseberries]:Use
		wait 3
	}
	;; Raise Energy by eating Druid Berries
	if ${Me.EnergyPct} < 50 && ${Me.Inventory[Large MottleBerries].IsReady}
	{
		Me.Inventory[Large MottleBerries]:Use
		wait 3
	}
	
	;; go find a target that is within 80 meters
	if ${Me.Encounter}<1 && !${Me.InCombat}
	{
		;; echo that we need more health/energy
		if !${NeedMoreEnergy}
		{
			if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.EndurancePct}<=45
			{
				NeedMoreEnergy:Set[TRUE]
				vgecho RESTING:  Endurance is below 45%
			}
			if (${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.EnergyPct}<=60) || ${Me.HealthPct}<60
			{
				NeedMoreEnergy:Set[TRUE]
				vgecho RESTING:  Health or Energy is below 60%
			}
		}
		
		if ${NeedMoreEnergy}
		{
			if (${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.EnergyPct}<60) || ${Me.HealthPct}<60
			{
				variable string EatThis = None
				if ${Me.Inventory[exactname,Fresh Berries](exists)}
					EatThis:Set["Fresh Berries"]
				if ${Me.Inventory[exactname,Fresh Fish](exists)}
					EatThis:Set["Fresh Fish"]
				if ${Me.Inventory[exactname,Shiny Red Apple](exists)}
					EatThis:Set["Shiny Red Apple"]
				if ${Me.Inventory[exactname,Block of Cheese](exists)}
					EatThis:Set["Block of Cheese"]
				if ${Me.Inventory[exactname,Loaf of Honey](exists)}
					EatThis:Set["Loaf of Honey"]
				if ${Me.Inventory[exactname,Loaf of Honey Bread](exists)}
					EatThis:Set["Loaf of Honey Bread"]
				if ${Me.Inventory[exactname,Hard Boiled Egg](exists)}
					EatThis:Set["Hard Boiled Egg"]

				VGExecute "/stand"
				vgecho "Eating:  ${EatThis}"
				wait 5
				
				Me.Inventory[${EatThis}]:Use
				wait 50
			}
		
			;; loop this to regain more energy
			while ${Me.HealthPct}<90 || (${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.EnergyPct}<90) || (${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.EndurancePct}<50)
			{
				if ${Me.Target(exists)} || ${Me.Encounter}>0 || ${Me.InCombat}
					break
				EchoIt "Resting: My Energy=${Me.EnergyPct}, My Health=${Me.HealthPct}, My Enurance=${Me.EndurancePct}"
				vgecho "Resting: My Energy=${Me.EnergyPct}, My Health=${Me.HealthPct}, My Enurance=${Me.EndurancePct}"
				wait 50 ${Me.Target(exists)} || ${Me.Encounter}>0
				waitframe
			}

			;; Always stand up
			VGExecute "/stand"
		}
		
		;; Check Inventory - for now, we will camp if it is full
		if ${Me.InventorySlotsOpen}<=5 && !${Me.Target(exists)}
		{
			EchoIt "Camping"
			vgecho "Camping"
			waitframe
			VGExecute /camp
			wait 152 ${Me.Encounter} || ${Me.InCombat} || ${Me.Target(exists)}
			if !${Me.InCombat} && !${Me.Encounter} && !${Me.Target(exists)}
			{
				endscript VG-Hunt
				waitframe
			}
		}

		;; Go find a target if our health is high enough
		if ${Me.HealthPct}>=90
		{
			;; reset our flag
			NeedMoreEnergy:Set[FALSE]
			
			if ${Me.Target.IsDead}
				wait 10
			
			if ${doLoot}
				call LootNearbyCorpses
				
			if !${Me.Target(exists)}
				call MoveToWayPoint

			if ${doScanAreaForTarget}
				call FindTarget ${MaxDistance}
				
		}
	}
}

;===================================================
;===        Loot Nearby Corpses                 ====
;===================================================
function LootNearbyCorpses()
{
	if ${Pawn[Corpse,range,25](exists)} && ${Pawn[Corpse,range,25].ContainsLoot}
	{
		Pawn[Corpse,range,20]:Target
		wait 10 ${Me.TargetAsEncounter.Difficulty(exists)}
		call MoveCloser 4
		if ${Me.Target.ContainsLoot} && ${Me.Target.Distance}<=5
		{
			Loot:LootAll
			waitframe
			VGExecute "/cleartargets"
			wait 30
		}
	}
}

;===================================================
;===                  Debug                     ====
;===================================================
function debug(string Text)
{
	redirect -append "${DebugFilePath}/Debug.txt" echo "[${Time}] ${Text}"
	echo [${Time}][VG-Hunt] --> "${Text}"
}

;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[VG-Hunt]:Clear
	LavishSettings:AddSet[VG-Hunt]
	LavishSettings[VG-Hunt]:AddSet[options]
	LavishSettings[VG-Hunt]:AddSet[MyPath]
	
	LavishSettings[VG-Hunt]:Import[${LavishScript.CurrentDirectory}/scripts/VG-Hunt/Saves/${Me.FName}.xml]

	options:Set[${LavishSettings[VG-Hunt].FindSet[options]}]
	MyPath:Set[${LavishSettings[VG-Hunt].FindSet[MyPath]}]

	;; import Hunt variables
	doCheckLineOfSight:Set[${options.FindSetting[doCheckLineOfSight,${doCheckLineOfSight}]}]
	doAggroNPC:Set[${options.FindSetting[doAggroNPC,${doAggroNPC}]}]
	doNPC:Set[${options.FindSetting[doNPC,TRUE]}]
	doLoot:Set[${options.FindSetting[doLoot,${doLoot}]}]
	doCamp:Set[${options.FindSetting[doCamp,${doCamp}]}]
	PullDistance:Set[${options.FindSetting[PullDistance,${PullDistance}]}]
	MaxDistance:Set[${options.FindSetting[MaxDistance,${MaxDistance}]}]
	MinimumLevel:Set[${options.FindSetting[MinimumLevel,${Me.Level}]}]
	MaximumLevel:Set[${options.FindSetting[MaximumLevel,${Me.Level}]}]
	DifficultyLevel:Set[${options.FindSetting[DifficultyLevel,${DifficultyLevel}]}]

	;; setup our paths
	if ${Me.Chunk(exists)}
	{
		if !${MyPath.FindSet[${Me.Chunk}](exists)}
		{
			EchoIt "Adding (${Me.Chunk}) Chunk Region to Config"
			MyPath:AddSet[${Me.Chunk}]
			CurrentWayPoint:Set[0]
			TotalWayPoints:Set[0]
			MyPath.FindSet[${Me.Chunk}]:Clear
			Navigate:ClearAll
		}
		else
		{
			TotalWayPoints:Set[${MyPath[${Me.Chunk}].FindSetting[TotalWayPoints,0]}]
			call FindNearestWayPoint
			CurrentWayPoint:Set[${Return}]
			if ${CurrentWayPoint}<1
			{
				CurrentWayPoint:Set[1]
			}
			EchoIt "TotalWayPoints Found in ${Me.Chunk}: ${TotalWayPoints}, Closest WayPoint is ${CurrentWayPoint}"
		}
	}
}

;===================================================
;===        Lavish Save Routine                 ====
;===================================================
function LavishSave()
{
	;; cut down on the loading times
	if !${LavishSettings[VG-Hunt].FindSet[options](exists)}
	{
		;; build and import Settings
		LavishSettings[VG-Hunt]:Clear
		LavishSettings:AddSet[VG-Hunt]
		LavishSettings[VG-Hunt]:AddSet[options]
		LavishSettings[VG-Hunt]:AddSet[MyPath]
		LavishSettings[VG-Hunt]:Import[${LavishScript.CurrentDirectory}/scripts/VG-Hunt/Saves/${Me.FName}.xml]
	}

	;; update our pointers
	options:Set[${LavishSettings[VG-Hunt].FindSet[options]}]
	MyPath:Set[${LavishSettings[VG-Hunt].FindSet[MyPath]}]

	;; update our hunt variables
	options:AddSetting[doCheckLineOfSight,${doCheckLineOfSight}]
	options:AddSetting[doAggroNPC,${doAggroNPC}]
	options:AddSetting[doNPC,${doNPC}]
	options:AddSetting[doLoot,${doLoot}]
	options:AddSetting[doCamp,${doCamp}]
	options:AddSetting[PullDistance,${PullDistance}]
	options:AddSetting[MaxDistance,${MaxDistance}]
	options:AddSetting[MinimumLevel,${MinimumLevel}]
	options:AddSetting[MaximumLevel,${MaximumLevel}]
	options:AddSetting[DifficultyLevel,${DifficultyLevel}]

	LavishSettings[VG-Hunt]:Export[${LavishScript.CurrentDirectory}/scripts/VG-Hunt/Saves/${Me.FName}.xml]
}

;===================================================
;===                   Exit                     ====
;===================================================
atom atexit()
{
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	call LavishSave
	ui -unload "${Script.CurrentDirectory}/VG-Hunt.xml"
}


;===================================================
;===         Catch target death                 ====
;===================================================
atom(script) PawnStatusChange(string ChangeType, int64 PawnID, string PawnName)
{
	;vgecho ChangeType=${ChangeType}, PawnID=${PawnID}, CurrentTargetID=${CurrentTargetID},  PawnName=${PawnName}
	if ${PawnID}==${CurrentTargetID} && ${ChangeType.Equal[NowDead]}
	{
		TotalKills:Inc
		EchoIt "Total Kills = ${TotalKills}"
		vgecho "Total Kills = ${TotalKills}"
	}
}

;===================================================
;===         Monitor Status Alerts              ====
;===================================================
atom(script) AlertEvent(string Text, int ChannelNumber)
{
	EchoIt "[AlertChannel=${ChannelNumber}] ${Text}"
	if ${ChannelNumber}==22
	{
		if ${Text.Find[Invalid target]}
		{
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute "/cleartargets"
		}
	}
	if ${ChannelNumber}==42
	{
		if ${Text.Find[Returning you to the nearest outpost...]}
		{
			EchoIt "[AlertEvent] Teleported to Altar"
			WeAreDead:Set[TRUE]
		}
	}
}


;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	;EchoIt "[Channel=${ChannelNumber}] ${Text}"
	
	if ${ChannelNumber}==0
	{
		if ${Text.Find[I'm afraid I can't do that, Master.]}
		{
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute "/cleartargets"
		}
	}

	if ${ChannelNumber}==42
	{
		if ${Text.Find[Returning you to the nearest outpost...]}
		{
			EchoIt "[AlertEvent] Teleported to Altar"
			WeAreDead:Set[TRUE]
		}
	}	
	if ${ChannelNumber}==38
	{
		if ${Text.Find["The corpse has nothing on it for you."]}
		{
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
		}
	}
	if ${ChannelNumber}==0 || ${ChannelNumber}==1
	{
		if ${Text.Find["You must harvest this before you can loot it!"]}
		{
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
		}
	
		if ${Text.Find["no line of sight to your target"]} || ${Text.Find[You can't see your target]}
		{
			EchoIt "Face issue chatevent fired, facing target"
			Me.Target:Face
			NoLineOfSight:Set[TRUE]
		}
	}
	
}

;***************************************************************************************************************
;***************************************************************************************************************
;***************************************************************************************************************
;***************************************************************************************************************

;===================================================
;===        MOVE CLOSER TO TARGET               ====
;===================================================
function MoveCloser(int Distance=4)
{
	;;;;;;;;;;
	;; we only want to move if target doesn't exist
	waitframe

	;;;;;;;;;;
	;; Only move if target has a valid position
	if ${Me.Target.X}==0 || ${Me.Target.Y}==0
	{
		;vgecho X and Y = 0
		VGExecute /cleartargets
		wait 15
		return
	}

	;;;;;;;;;;
	;; Set our variables and turn on our bump monitor
	BUMP:Set[FALSE]
	variable float X = ${Me.X}
	variable float Y = ${Me.Y}
	variable float Z = ${Me.Z}
	variable int bailOut
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(10000)]}]
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	
	if ${Me.Target.Distance}>10
		call StartFacing


	if ${Distance}<1
		Distance:Set[1]
		
	;;;;;;;;;;
	;; Loop this until we are within range of target or our timer has expired which is 10 seconds
	while ${Me.Target(exists)} && ${Me.Target.Distance}>=${Distance} && ${LavishScript.RunningTime}<${bailOut}
	{
		CalculateAngles
		if ${AngleDiffAbs} > 10
			Me.Target:Face

		;; Start moving
		VG:ExecBinding[moveforward]
		
		
		;; did we bump into something?
		if ${BUMP}
		{
			;; try moving right or backwards if we didn't move
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
			{
				;; move right for half a second
				VG:ExecBinding[StrafeRight]
				wait 5
				VG:ExecBinding[StrafeRight,release]
				wait 1

				;; try moving backward if we didn't move
				if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
				{
					VG:ExecBinding[moveforward,release]
					wait 1
					VG:ExecBinding[movebackward]
					wait 1
					VG:ExecBinding[StrafeRight]
					wait 4
					VG:ExecBinding[StrafeRight,release]
					wait 2
					VG:ExecBinding[movebackward,release]
					wait 1
				}
				continue
			}
			BUMP:Set[FALSE]
		}

		;; update our location
		X:Set[${Me.X}]
		Y:Set[${Me.Y}]
		Z:Set[${Me.Z}]
	}

	;;;;;;;;;;
	;; stop moving forward and turn off our bump monitor
	VG:ExecBinding[moveforward,release]
	Event[VG_onHitObstacle]:DetachAtom[Bump]

	;;;;;;;;;;
	;; we timed out so clear our target and try again
	if ${BUMP} && ${Me.Encounter}>0
	{
		VGExecute /cleartargets
		wait 30
	}
}

;===================================================
;===     BUMP ROUTINE USED BY MOVE ROUTINE      ====
;===================================================
atom Bump(string Name)
{
	BUMP:Set[TRUE]
}

;===================================================
;===     Calculate closest waypoint             ====
;===================================================
function:int FindNearestWayPoint()
{
	;;;;;;;;;;
	;; cycle through all our waypoints finding nearest one
	;; to our current location
	if ${TotalWayPoints}
	{
		variable int i
		variable int ClosestDistance = 999999
		variable int ClosestWayPoint = 1
		variable point3f Destination

		for ( i:Set[1] ; ${i}<=${TotalWayPoints} ; i:Inc )
		{
			; set destination location X,Y,Z
			MyPath:Set[${LavishSettings[VG-Hunt].FindSet[MyPath]}]
			Destination:Set[${MyPath.FindSet[${Me.Chunk}].FindSetting[WP-${i}]}]

			if ${Math.Distance["${Me.Location}","${Destination}"]} < ${ClosestDistance}
			{
				ClosestWayPoint:Set[${i}]
				ClosestDistance:Set[${Math.Distance["${Me.Location}","${Destination}"]}]
			}
		}
		;EchoIt "Distance to WP-${ClosestWayPoint} is ${ClosestDistance}"
		return ${ClosestWayPoint}
	}
	return 0
}


;===================================================
;===         Save current waypoint              ====
;===================================================
atom(script) AddWayPoint()
{
	;; increase our total waypoints
	TotalWayPoints:Inc

	;; store our settings for quick reference
	MyPath:Set[${LavishSettings[VG-Hunt].FindSet[MyPath]}]
	MyPath.FindSet[${Me.Chunk}]:AddSetting[TotalWayPoints, ${TotalWayPoints}]
	MyPath.FindSet[${Me.Chunk}]:AddSetting[WP-${TotalWayPoints}, "${Me.Location}"]

	;; save our settings
	call LavishSave

	;; LavishNav: add point name to path
	Navigate:AddNamedPoint[WP-${TotalWayPoints}]

	;; echo that we added our waypoint
	EchoIt "Added WP-${TotalWayPoints} to ${Me.Chunk}"
}


;===================================================
;===        Clear current waypoint              ====
;===================================================
atom(script) ClearWayPoints()
{
	;; clear our variables
	CurrentWayPoint:Set[0]
	TotalWayPoints:Set[0]

	;; clear our path settings
	MyPath.FindSet[${Me.Chunk}]:Clear

	;; save everything
	call LavishSave

	;; LavishNav: reset our path
	Navigate:ClearAll

	;; echo that we cleared our path and waypoints
	EchoIt "Cleared all Waypoints for ${Me.Chunk}"
}

;===================================================
;===     Handles movement to next waypoint      ====
;===================================================
function(script) MoveToWayPoint()
{
	;;;;;;;;;;
	;; do absolutely nothing until we get a waypoint
	if ${TotalWayPoints}==0
		return

	;;;;;;;;;;
	;; return if we are already navigating to a waypoint
	if ${Navigate.isMoving}
	{
	
		Action:Set[Moving to WP-${CurrentWayPoint}]
		
		;; we didn't move so move left then move right
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<15
		{
			VG:ExecBinding[StrafeRight]
			wait 5
			VG:ExecBinding[StrafeRight,release]
			wait 1
			VG:ExecBinding[StrafeLeft]
			wait 5
			VG:ExecBinding[StrafeLeft,release]
			wait 1
		}
		
		X:Set[${Me.X}]
		Y:Set[${Me.Y}]
		Z:Set[${Me.Z}]
		
		;; stop moving if we paused or picked up an encounter
		if ${Me.Encounter}>0 || ${Me.InCombat} || ${Me.Target(exists)} || !${doMoveBetweenWaypoints}
		{
			Navigate:Stop
			VG:ExecBinding[moveforward,release]
			wait 1
			VG:ExecBinding[StrafeLeft,release]
			wait 1
			VG:ExecBinding[StrafeRight,release]
			wait 1
		}
		return
	}
	
	if !${doMoveBetweenWaypoints}
		return
		
	;;;;;;;;;;
	;; reset waypoint
	if ${CurrentWayPoint}<1
	{
		EchoIt "Starting at WP-1"
		CurrentStatus:Set[Starting at WP-1]
		CurrentWayPoint:Set[1]
	}

	;;;;;;;;;;
	;; reset waypoint
	if ${CurrentWayPoint}>${TotalWayPoints}
	{
		EchoIt "Starting at WP-${TotalWayPoints}"
		CurrentStatus:Set[Starting at WP-${TotalWayPoints}]
		CurrentWayPoint:Set[${TotalWayPoints}]
	}

	;;;;;;;;;;
	;; calculate our distance to the waypoint
	variable point3f Destination = ${MyPath.FindSet[${Me.Chunk}].FindSetting[WP-${CurrentWayPoint}]}
	EchoIt "[WP-${CurrentWayPoint}][Distance from = ${Math.Distance[${Me.Location},${Destination}].Int}]"

	;;;;;;;;;;
	;; if we are in range of our destination then its time to go to next waypoint
	if ${Math.Distance["${Me.Location}","${Destination}"]} < 1000
	{
		;; reset current way point if equals total way points or more
		if ${CurrentWayPoint}>=${TotalWayPoints}
		{
			CurrentWayPoint:Set[${TotalWayPoints}]
			CountUp:Set[FALSE]
		}

		;; reset current way point if equals 1 or less
		if ${CurrentWayPoint}<=1
		{
			CurrentWayPoint:Set[1]
			CountUp:Set[TRUE]
		}

		;; adjust out current way point to move up or down
		if ${CountUp}
		{
			CurrentWayPoint:Inc
		}
		else
		{
			CurrentWayPoint:Dec
		}
	}

	;;;;;;;;;;
	;; LavishNav: Move to a Point
	EchoIt "Attempting to move to WP-${CurrentWayPoint}"
	Navigate:MoveToPoint[WP-${CurrentWayPoint}]

	;; allow time to register we are moving
	wait 40 ${Navigate.isMoving}

	EchoIt "isMoving=${Navigate.isMoving}"
}




;===================================================
;===         FACE TARGET SUBROUTINE             ====
;===================================================
function FaceTarget()
{
	;; face only if target exists
	if ${Me.Target(exists)}
	{
		CalculateAngles
		if ${AngleDiffAbs} < 45
			return
			
		call StartFacing
	}
}
		
function StartFacing()
{
	;; face only if target exists
	if !${Me.Target(exists)}
		return

	CalculateAngles
	if ${AngleDiffAbs} <= 10
		return
	
	VGExecute /stand
	wait 1

	variable int i = ${Math.Calc[5-${Math.Rand[10]}]}
	EchoIt "Facing within ${i} degrees of ${Me.Target.Name}"
	CalculateAngles
	if ${AngleDiff}>0
	{
		VG:ExecBinding[turnright,release]
		wait 1
		VG:ExecBinding[turnleft,release]
		wait 1
		VG:ExecBinding[turnright]
		while ${AngleDiff} > ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning}
		{
			CalculateAngles
		}
		VG:ExecBinding[turnleft,release]
		wait 1
		VG:ExecBinding[turnright,release]
		wait 1
		return
	}
	CalculateAngles
	if ${AngleDiff}<0
	{
		VG:ExecBinding[turnright,release]
		wait 1
		VG:ExecBinding[turnleft,release]
		wait 1
		VG:ExecBinding[turnleft]
		while ${AngleDiff} < ${i} && ${Me.Target(exists)} && !${isPaused} && ${isRunning}
		{
			CalculateAngles
		}
		VG:ExecBinding[turnright,release]
		wait 1
		VG:ExecBinding[turnleft,release]
		wait 1
		return
	}
	VG:ExecBinding[turnright,release]
	wait 1
	VG:ExecBinding[turnleft,release]
	wait 1
}

variable int AngleDiff = 0
variable int AngleDiffAbs = 0

;===================================================
;===     CALCULATE TARGET'S ANGLE FROM YOU      ====
;===================================================
atom(script) CalculateAngles()
{
	if ${Me.Target(exists)}
	{
		variable float temp1 = ${Math.Calc[${Me.Y} - ${Me.Target.Y}]}
		variable float temp2 = ${Math.Calc[${Me.X} - ${Me.Target.X}]}
		variable float result = ${Math.Calc[${Math.Atan[${temp1},${temp2}]} - 90]}

		result:Set[${Math.Calc[${result} + (${result} < 0) * 360]}]
		result:Set[${Math.Calc[${result} - ${Me.Heading}]}]
		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		AngleDiff:Set[${result}]
		AngleDiffAbs:Set[${Math.Abs[${result}]}]
	}
	else
	{
		AngleDiff:Set[0]
		AngleDiffAbs:Set[0]
	}
}

;===================================================
;===          FIX LINE OF SIGHT                 ====
;===================================================
function FixLineOfSight()
{
	NoLineOfSight:Set[FALSE]
	LoSRetries:Inc
	if ${LoSRetries}>=3
	{
		VGExecute "/cleartargets"
		wait 3
	}
	else
	{
		EchoIt "Fixing Line of Sight"
		Me.Target:Face
		waitframe
		VG:ExecBinding[moveforward,release]
		wait 1
		VG:ExecBinding[movebackward]
		wait 2
		VG:ExecBinding[StrafeRight]
		wait 4
		VG:ExecBinding[StrafeRight,release]
		wait 1
		VG:ExecBinding[StrafeLeft]
		wait 4
		VG:ExecBinding[StrafeLeft,release]
		wait 1
		VG:ExecBinding[movebackward,release]
		wait 1
		VGExecute "/pet Guard"
		wait 10
		VGExecute "/pet Guard"
		wait 10
	}
}
variable int LoSRetries = 0
variable bool NoLineOfSight = FALSE

;===================================================
;===     Display to console what we are doing   ====
;===================================================
atom(script) EchoIt(string aText)
{
	redirect -append "${DebugFilePath}/Debug.txt" echo "[${Time}] ${aText}"
	echo "[${Time}][VG-Hunt]: ${aText}"
}

