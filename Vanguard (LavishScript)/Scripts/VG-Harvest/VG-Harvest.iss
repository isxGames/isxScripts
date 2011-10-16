;-----------------------------------------------------------------------------------------------
; VG-Harvest.iss 
;
; Description - Harvesting script
; -----------
; * Has 2 modes:  Master Harvester & Assist Master Harvester
; * Toggles to control:  Harvest Area, Loot, AutoMapping, and Debug Info
; * Automatically aborts harvesting after 20 seconds
; * WayPoint counter is set to nearest waypoint
; * Off Map: finds nearest mapped point that has no obtacles
;
; Revision History
; ----------------
; 20111015 (Zandros)
;  * Worked on Obj_Navigator improving pathing and movement routines
;
; 20111012 (Zandros)
;  * Major work was done.  Added a modified version of LavishNav
;    allowing mapping and setting waypoints for each chunk
;
; 20111011 (Zandros)
;  * Added added toggles
;
; 20111010 (Zandros)
;  * A simple script that handles harvesting
;
;===================================================
;===            VARIABLES                       ====
;===================================================

;; includes
#include Includes/Obj_Navigator.iss
#include Includes/Obj_Face.iss
#include Includes/FindTarget.iss

;; variables - general
variable bool isRunning = TRUE
variable bool isPaused = TRUE
variable bool doEcho = TRUE
variable bool doLoot = TRUE
variable bool doMapArea = FALSE
variable bool doAvoidAggro = TRUE
variable bool WeAreMasterHarvester = FALSE
variable bool doHarvestArea = FALSE
variable bool WeAreFollowing = FALSE
variable int HarvestingRange = 10
variable int AggroRadius = 15
variable int HarvX = 968
variable int HarvY = 924
variable string CurrentStatus = "Waiting"
variable int StartTime = ${Script.RunningTime}

;; variables - navigation
variable int TotalWayPoints = 0
variable int CurrentWayPoint = 0
variable int LastWayPoint = 0
variable bool CountUp = FALSE
variable string CurrentChunk 

;; variables - harvester
variable string MasterHarvesterName = "${Pawn[Me].Name}"
variable int64 MasterHarvesterID = ${Pawn[Me].ID}

;; variables - save/load "we keep them loaded at all times"
variable settingsetref VG-Harvest_SSR
variable settingsetref VG-MyPath_SSR

;; initialize our objects
variable(global) Obj_Navigator Navigate
variable obj_Face Face

;===================================================
;===            Main Routine                    ====
;===================================================
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
		endscript VG-Harvest
	}
	wait 50 ${Me.Chunk(exists)} && ${Me.FName(exists)}
	CurrentChunk:Set[${Me.Chunk}]

	;; load our settings and any maps in the area
	LoadXMLSettings
	
	;; Reload the UI
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-Harvest.xml"

	;-------------------------------------------
	; Loop this until program ends
	;-------------------------------------------
	while ${isRunning}
	{
		;-------------------------------------------
		;; Handle chunking, loading new chunk data  
		;-------------------------------------------
		if !${CurrentChunk.Equal[${Me.Chunk}]}
		{
			wait 50 ${Me.Chunk(exists)}

			;; we chunked
			EchoIt "We chunked from ${CurrentChunk} to ${Me.Chunk}"

			;; update current chunk
			CurrentChunk:Set[${Me.Chunk}]
			
			;; load our new settings
			EchoIt "Loading current chunk data"
			LoadXMLSettings
		}

		;-------------------------------------------
		;; slow this puppy down so we are not executing a few hounded thousand commands a second
		;-------------------------------------------
		wait .1

		;-------------------------------------------
		;; This will stop everything if we die for some reason
		;-------------------------------------------
		if ${Me.HealthPct}<=0 || ${GV[bool,DeathReleasePopup]}
		{
			call StopAutoFollow
			Navigate:Stop
			isPaused:Set[TRUE]
			VG:ExecBinding[moveforward,release]
			CurrentStatus:Set[WE ARE DEAD]
			wait 100
		}

		;-------------------------------------------
		;; execute any queued commands (add point, clear points)
		;-------------------------------------------
		if ${QueuedCommands}
		{
			ExecuteQueued
			FlushQueued
		}
		
		;-------------------------------------------
		;; Our Paused routine
		;-------------------------------------------
		if ${isPaused}
		{
			;; stop navigating
			Navigate:Stop
			call StopAutoFollow

			;; Begin mapping area if we are Master Harvester
			if ${WeAreMasterHarvester} && ${Me.Chunk(exists)} && ${doMapArea}
			{
				CurrentStatus:Set[We are mapping area]
				Navigate:StartMapping
			}
			else
			{
				CurrentStatus:Set[Not Mapping area]
				Navigate:StopMapping
			}
		}
		;-------------------------------------------
		;; Calls either Master Harvester or Assist Master Harvester
		;-------------------------------------------
		else
		{
			;; do not map area while running
			Navigate:StopMapping
			
			;; otherwise, are we the Master Harvester? (default)
			if ${WeAreMasterHarvester}
			{
				call MasterHarvester
			}
			;; or will we assist the Master Harvester
			elseif !${WeAreMasterHarvester}
			{
				call AssistMasterHarvester
			}
		}
	}
}

;===================================================
;===        Master Harvester Routine            ====
;===================================================
function MasterHarvester()
{
	;; do absolutely nothing until we get a waypoint
	if ${TotalWayPoints}==0
	{
		return
	}
	
	;; we need to find closest waypoint to us
	if ${CurrentWayPoint}==0
	{
		call FindNearestWayPoint
		CurrentWayPoint:Set[${Return}]
		;; No need to move to nothing
		if ${CurrentWayPoint}==0
		{
			CurrentStatus:Set[Not on Map]
			return
		}
		EchoIt "Closest WayPoint is ${CurrentWayPoint}"
	}

	;; Return if we are navigating
	if ${Navigate.isMoving}
	{
		CurrentStatus:Set[Moving to WP-${CurrentWayPoint}]
		return
	}

	;; go ahead and define our point3f
	variable point3f Destination = ${VG-MyPath_SSR.FindSet[${Me.Chunk}].FindSetting[WP-${CurrentWayPoint}]}
	
	;; start harvesting area if we are near it
	if ${Math.Distance["${Me.Location}","${Destination}"]} < 500
	{
		CurrentStatus:Set[Reached WP-${CurrentWayPoint}]
		
		;; keep harvesting area until nothing is left
		if ${doHarvestArea}
		{
			call HarvestArea
			if ${Return}
			{
				return
			}
			EchoIt "Done Harvesting Area"
		}
	}

	;; reset current way point if > total way points
	if ${CurrentWayPoint}>=${TotalWayPoints}
	{
		CurrentWayPoint:Set[${TotalWayPoints}]
		CountUp:Set[FALSE]
	}

	;; reset current way point if 1
	if ${CurrentWayPoint}<=1
	{
		CurrentWayPoint:Set[1]
		CountUp:Set[TRUE]
	}
		
	;; adjust out current way point to move up or down the points once we are done harvesting area
	if ${CountUp}
	{
		CurrentWayPoint:Inc
	}
	else
	{
		CurrentWayPoint:Dec
	}
		
	
	;; Lets navigate to our CurrentWayPoint - 2 seconds is plenty of time to ensure we are navigating - remember, we are still mapping
	EchoIt "Navigating to WP-${CurrentWayPoint}"
	Navigate:MoveToPoint[WP-${CurrentWayPoint}]
	wait 20 ${Navigate.isMoving}
	if !${Navigate.isMoving}
	{
		CurrentStatus:Set[Not on Map]
	}
}

;===================================================
;===      Assist Master Harvester Routine       ====
;===================================================
function AssistMasterHarvester()
{
	;; Set DTarget to our Master Harvester
	if !${Me.DTarget.Name.Find[${MasterHarvesterName}]}
	{
		pawn[exactname,${MasterHarvesterName}]:Target
		wait 10
	}
	
	;; return if Master Harvester can't be found
	if !${Me.DTarget.Name.Find[${MasterHarvesterName}]}
	{
		return
	}

	;; always follow the Master Harvester
	if ${Me.DTarget.Distance}>=7
	{
		variable bool AreWeMoving = FALSE
		Face:Point[${Me.DTarget.X}, ${Me.DTarget.Y}, 0, FALSE]
		wait 10

		;; start moving until target is within 4m of self
		while ${Me.DTarget.Distance}>=5
		{
			;; check to see if we need to break out of loop
			if ${isPaused} || !${Me.DTarget(exists)}
			{
				VG:ExecBinding[moveforward,release]
				return
			}
			
			;; face DTarget and move forward
			Me.DTarget:Face
			VG:ExecBinding[moveforward]
			AreWeMoving:Set[TRUE]
			wait .1
		}

		;; if we moved then we want to stop moving
		if ${AreWeMoving}
		{
			VG:ExecBinding[moveforward,release]
		}
	}

	;; set our target to Harvester's target
	VGExecute /assist ${MasterHarvesterName}
	wait 5 ${Me.Target(exists)}

	;; harvest and loot Master Harvester's target
	if ${Me.Target(exists)}
	{
		;; harvest target
		call HarvestTarget
		
		;; loot target
		call LootTarget
		
		;; close that pesky harvesting window
		;call Close_HarvestingWindow
		
		;; consolidate all them resources we've been collecting
		call Consolidate_Resources
	}
}

;===================================================
;===         Harvest Area Routine               ====
;===================================================
function:bool HarvestArea()
{
	if !${doHarvestArea}
	{
		return FALSE
	}
	
	CurrentStatus:Set[Harvesting Area]

	;; Let's go find a Resource that's 10 meter radius from us (default)
	call FindTarget Resource ${HarvestingRange}
	if !${Return}
	{
		;; stop searching for we are done with this area
		return FALSE
	}

	;; harvest and loot Master Harvester's target
	if ${Me.Target(exists)} && ${Me.Target.IsHarvestable}
	{
		;; harvest target
		call HarvestTarget
	
		;; loot target
		call LootTarget

		;; close that pesky harvesting window
		;call Close_HarvestingWindow

		;; consolidate all them resources we've been collecting
		call Consolidate_Resources
	
		;; Clear Target
		VGExecute "/cleartargets"
		wait 5
		
		;; Search for more
		return TRUE
	}
	
	;; Stop searching, we are done with area, should never get here
	return FALSE
}

;===================================================
;===         Harvest Target Routine             ====
;===================================================
function:bool HarvestTarget()
{
	;; we do not have a target to harvest
	if !${Me.Target(exists)}
	{
		return
	}
	
	;; our target is too far away... we need to follow to get closer
	if ${Me.Target.Distance}>15 || !${Me.Target.IsHarvestable}
	{
		return
	}
	
	;; we are going to move into harvesting range of target
	if ${Me.Target.Distance}>=4
	{
		CurrentStatus:Set[Moving closer to target]
		;; turn slowly toward the target
		Face:Point[${Me.Target.X}, ${Me.Target.Y}, 0, FALSE]
		wait 10

		;; change posture to walking
		VGExecute /walk

		;; start moving forward
		VG:ExecBinding[moveforward]

		;; loop until target doesn't exist or outside 4 meters
		while ${Me.Target.Distance}>=4
		{
			if !${Me.Target(exists)} || !${isRunning} || ${isPaused}
				break
		}

		;; stop moving forward
		VG:ExecBinding[moveforward,release]

		;; change our posture back to running
		VGExecute /run
	}
	
	;; return if Master Harvester has not started harvesting
	if !${WeAreMasterHarvester} && ${Pawn[id,${MasterHarvesterID}].CombatState}==0 
	{
		CurrentStatus:Set[Waiting on Master Harvester]
		return
	}
	
	;; return if we are harvesting 
	;if ${GV[bool,bHarvesting]} && ${Me.ToPawn.CombatState}>0
	;{
	;	return TRUE
	;}

	;; Start harvesting
	if !${GV[bool,bIsAutoAttacking]} || ${Me.ToPawn.CombatState}==0
	{
		CurrentStatus:Set[Begin harvesting]
		Me.Ability[Auto Attack]:Use
		wait 30 ${GV[bool,bIsAutoAttacking]} && ${Me.ToPawn.CombatState}>0
		waitframe
	}
	
	;; Let's wait here while we are harvesting
	if ${GV[bool,bHarvesting]} && ${Me.ToPawn.CombatState}>0
	{
		CurrentStatus:Set[Harvesting - ${Me.Target.Name}]
		EchoIt "Harvesting: ${Me.Target.Name}"
	
		;; Bonus Yield causes bHarvesting to always report TRUE
		while ${GV[bool,bHarvesting]} && ${Me.Target.IsHarvestable}
		{
			;; this will stop the harvest
			if ${Pawn[id,${MasterHarvesterID}].CombatState}==0 || ${Me.Target.Name.Find[remains of]} || !${Me.Target(exists)} || ${Pawn[id,${MasterHarvesterID}].Distance}>7 || !${isRunning} || ${isPaused}
			{
				CurrentStatus:Set[Stopped Harvesting]
				VGExecute /endharvesting
				waitframe
				break
			}
		}

		CurrentStatus:Set[Finished Harvesting]
		VGExecute /endharvesting
		wait 15 !${Me.Target.IsHarvestable} && ${Me.Target.ContainsLoot}
		waitframe
	}

	;; Turn off autoattack if it is on
	if ${GV[bool,bIsAutoAttacking]}
	{
		Me.Ability[Auto Attack]:Use
		wait 40 !${GV[bool,bIsAutoAttacking]}
		waitframe
	}
}


;===================================================
;===         Loot Target Routine                ====
;===================================================
function LootTarget()
{
	if ${doLoot}
	{
		;; Loot routine if target is a corpse
		if !${Me.Target.IsHarvestable} && ${Me.Target.ContainsLoot} && ${Me.Target.Distance}<5
		{
		
			CurrentStatus:Set[Looting]

			;; Start Loot Window
			Loot:BeginLooting
			wait 10 ${Loot.NumItems} || !${Me.Target(exists)}
			
			;; Cycle through each item and loot it
			if ${Me.IsLooting}
			{
				variable int i = 0
				for ( i:Set[${Loot.NumItems}] ; ${i}<=0 ; i:Dec )
				{
					Loot.Item[${i}]:Loot
					vgecho *Looting: ${Loot.Item[${i}]}
				}
				Loot:EndLooting
				wait 3
			}
			
			;; There is a chance we still have items to loot so loot everything
			if ${Loot.Items}
			{
				Loot:LootAll
				wait 2
			}
		}
	}
}

;===================================================
;=== Close that Pesky Harvesting Window Routine ====
;===================================================
function Close_HarvestingWindow()
{
	CurrentStatus:Set[Closing Harvesting Window]
	;; If we are still harvesting, not done harvesting, but our progress is stuck at 0, then close that pesky harvesting window
	if ${GV[bool,bHarvesting]} && !${GV[bool,IsHarvestingDone]} && ${GV[int,HarvestingTargetSI]}==0
	{
		VGExecute /endharvesting
		VGExecute /hidewindow Harvesting
		wait 10
	}

	;; If we are harvesting but the system reports we are done, then close that pesky harvesting window
	if ${GV[bool,bHarvesting]} && ${GV[bool,IsHarvestingDone]}
	{
		VGExecute /endharvesting
		VGExecute /hidewindow Harvesting
		wait 10
	}

	;; Harvesting variables never lie -- yeah right!
	if ${GV[bool,bHarvesting]} && ${GV[bool,IsHarvestingDone]}
	{
		echo [${Time}] bHarvesting=${GV[bool,bHarvesting]}, IsHarvestingDone=${GV[bool,IsHarvestingDone]}, HarvestingRareItemsPresent=${GV[bool,HarvestingRareItemsPresent]}

		;; Move cursor to last known position
		Mouse:SetPosition[${HarvX},${HarvY}]
		
		;; Hide Harvesting window
		VGExecute /hidewindow Harvesting
		wait 10
		
		;; cursor should be where the close button is when we show the harvesting window
		VGExecute /showwindow Harvesting
		wait 10

		;; Click at that location - nice, close button responds now :)
		Mouse:LeftClick
		Mouse:LeftClick

		;; Wait a good 10 seconds or until system reports we are not harvesting
		wait 100 !${GV[bool,bHarvesting]}

		;; Is Harvesting Window still open?
		if ${GV[bool,bHarvesting]} && ${GV[bool,IsHarvestingDone]}
		{
			echo "WARNING:  Please close the Harvesting Window"
			vgecho "Please close the Harvesting Window to save the X Y coordinates of the close button"
			
			;; Not thoroughly tested but this was true when the yield window was up
			wait 600 !${GV[bool,HarvestingRareItemsPresent]}
			
			;; save the X,Y coordinates
			HarvX:Set[${Mouse.X}]
			HarvY:Set[${Mouse.Y}]

			;; Wait a good 10 seconds or until system reports we are not harvesting
			wait 100 !${GV[bool,bHarvesting]}
			
			if ${GV[bool,bHarvesting]}
			{
				echo "FAILED - Time ran out to close the pesky window"
				vgecho "FAILED - Time ran out to close the pesky window"
			}
			else
			{
				echo "New Mouse Coordinates to close Harvesting Window are X:${HarvX}, Y:${HarvY}"
				vgecho "Successfully learnt closing Harvesting Window"
			}
		}

		;; just in case, hide any windows and end harvesting
		VGExecute /hidewindow Harvesting
		VGExecute /endharvesting
	}
}

;===================================================
;===       Consolidate Resources Routine        ====
;===================================================
function Consolidate_Resources()
{
	variable int i
	for (i:Set[0] ; ${Me.Inventory[${i:Inc}].Name(exists)} ; )
	{
		if ${Me.Inventory[${i}].Description.Find[resource]} && ${Me.Inventory[${i}].Quantity}>80
		{
			echo "Consolidate: ${Me.Inventory[${i}]}"
			Me.Inventory[${i}]:StartConvert
			wait 10
			VG:ConvertItem
			wait 10
			return
		}
	}
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;======;;;;;;;;;;;;;;;;;;;;;;;======;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


function:bool Avoid_AggroNPC()
{
	if ${Pawn[AggroNPC,radius,16](exists)}
	{
		EchoIt "Avoiding AggroNPC"

		Navigate:Stop
		VG:ExecBinding[moveforward,release]
		Pawn[AggroNPC,radius,16]:Face
		;; Reset Sprinting
		if ${Me.IsSprinting}
		{
			Me:Sprint[100]
		}
		Me:Sprint[100]
		

		VG:ExecBinding[movebackward]
		while ${Pawn[AggroNPC,radius,20](exists)}
		{
			Pawn[AggroNPC,radius,20]:Target
			wait 3
			EchoIt "AGGRO - ${Me.Target.Name} at ${Me.Target.Distance} with a Combat state of ${Me.Target.CombatState}"
			if ${Me.Target.CombatState} || ${Pawn[AggroNPC,radius,15](exists)}
			{
				EchoIt "AGGRO - Casted Mass Amnesia"
				if ${Me.Ability[Mass Amnesia].IsReady}
				{
					;Me.Ability[Mass Amnesia]:Use
					wait 3
				}
			}
			waitframe
		}
		VGExecute "/cleartargets"
		VG:ExecBinding[movebackward,release]
		if ${Me.IsSprinting}
		{
			Me:Sprint
		}
		EchoIt "Moved out of Aggro range or we are dead."
		wait 3
		return TRUE
	}
	return FALSE
}


function:int FindNearestWayPoint()
{
	if ${TotalWayPoints}
	{
		variable int i
		variable int ClosestDistance = 999999
		variable int ClosestWayPoint = 1
		variable point3f Destination
		
		vgecho "----"
		
		for ( i:Set[1] ; ${i}<=${TotalWayPoints} ; i:Inc )
		{
			; set destination location X,Y,Z 
			Destination:Set[${VG-MyPath_SSR.FindSet[${Me.Chunk}].FindSetting[WP-${i}]}]

			if ${Math.Distance["${Me.Location}","${Destination}"]} < ${ClosestDistance}
			{
				ClosestWayPoint:Set[${i}]
				ClosestDistance:Set[${Math.Distance["${Me.Location}","${Destination}"]}]
			}
		}
		EchoIt "Distance to WP-${ClosestWayPoint} is ${ClosestDistance}"
		return ${ClosestWayPoint}
	}
	return 0
}

function TestWayPoints()
{
	if ${TotalWayPoints}
	{
		variable int i
		variable int StartTime
		variable point3f Destination
		
		for ( i:Set[1] ; ${i}<=${TotalWayPoints} ; i:Inc )
		{
			; set destination location X,Y,Z 
			Destination:Set[${VG-MyPath_SSR.FindSet[${Me.Chunk}].FindSetting[WP-${i}]}]

			; say we are moving
			echo "Moving to WP-${i} at distance of ${Math.Distance["${Me.Location}","${Destination}"]}"

			wait 5
			
			; begin moving
			Navigate:MoveToPoint[WP-${i}]
			wait 20
			StartTime:Set[${Script.RunningTime}]
			while ${Navigate.isMoving}
			{
				if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${StartTime}]}/1000]}>60
				{
					echo "ABORT - taking longer than 60 seconds to move to WP-${i}"
					echo ${Me.Location} Current Location
					echo ${Destination} Destination Location
					echo ${Math.Distance["${Me.Location}","${Destination}"]} Distance
					return
				}
				waitframe
			}
			echo "Finished moving to WP-${i} at distance of ${Math.Distance[${Me.X},${Me.Y},${Destination.X},${Destination.Y}]}"
		}

		Destination:Set[${VG-MyPath_SSR.FindSet[${Me.Chunk}].FindSetting[WP-1]}]
		if ${Math.Distance["${Me.Location}","${Destination}"]}>400
		{
			;; Go Back to safe spot and wait
			Navigate:MoveToPoint[WP-1]
			wait 20
			while ${Navigate.isMoving}
			{
				waitframe
			}
		}
	}
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;===================================================
;===     ATOM - called when script is ended     ====
;===================================================
function atexit()
{
	VG:ExecBinding[moveforward,release]
	;call StopAutoFollow
	SaveXMLSettings	
	ui -unload "${Script.CurrentDirectory}/VG-Harvest.xml"
}


;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}] VG-Harvest: ${aText}"
	}
}


;===================================================
;===       SUBROUTINE - Start Auto Follow       ====
;===================================================
function StartAutoFollow()
{
	if ${WeAreFollowing}
	{
		return
	}
	VGExecute /follow
	wait 20
	WeAreFollowing:Set[TRUE]
}

;===================================================
;===       SUBROUTINE - Stop Auto Follow        ====
;===================================================
function StopAutoFollow()
{
	if !${WeAreFollowing}
	{
		return
	}
	
	;; Interupt autofollow - need better way to stop autofollow but this will do for now
	VG:ExecBinding[moveforward]
	waitframe
	VG:ExecBinding[moveforward,release]
	waitframe
	WeAreFollowing:Set[FALSE]
}


;===================================================
;===     ATOM - Save current waypoint           ====
;===================================================
atom(script) AddWayPoint()
{
	;; increase our total waypoints
	TotalWayPoints:Inc

	;; add point name to path
	Navigate:AddNamedPoint[WP-${TotalWayPoints}]

	;; store our settings
	VG-MyPath_SSR.FindSet[${Me.Chunk}]:AddSetting[TotalWayPoints, ${TotalWayPoints}]
	VG-MyPath_SSR.FindSet[${Me.Chunk}]:AddSetting[WP-${TotalWayPoints}, "${Me.Location}"]
	
	;; save everything
	SaveXMLSettings
	
	;; echo that we added our waypoint
	EchoIt "Added WP-${TotalWayPoints} to ${Me.Chunk}"
}


;===================================================
;===     ATOM - Save current waypoint           ====
;===================================================
atom(script) ClearWayPoints()
{
	;; clear our variable and path
	CurrentWayPoint:Set[0]
	TotalWayPoints:Set[0]
	VG-MyPath_SSR.FindSet[${Me.Chunk}]:Clear
	Navigate:ClearAll

	;; save everything
	SaveXMLSettings

	;; echo that we cleared our path and waypoints
	EchoIt "Cleared all Waypoints for ${Me.Chunk}"
}
	
;===================================================
;===     ATOM - Load Variables from XML         ====
;===================================================
atom(script) LoadXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-Harvest/Save"
	mkdir "${savePath}"

	;;Load Lavish Settings 
	LavishSettings[VG-Harvest]:Clear
	LavishSettings:AddSet[VG-Harvest]

	LavishSettings[VG-Harvest]:AddSet[MySettings]
	LavishSettings[VG-Harvest]:AddSet[MyPath]
	
	LavishSettings[VG-Harvest]:Import[${savePath}/MySettings.txt]	

	;; set our reference
	VG-Harvest_SSR:Set[${LavishSettings[VG-Harvest].FindSet[MySettings]}]
	VG-MyPath_SSR:Set[${LavishSettings[VG-Harvest].FindSet[MyPath]}]

	;; Load our settings
	HarvX:Set[${VG-Harvest_SSR.FindSetting[HarvX,968]}]
	HarvY:Set[${VG-Harvest_SSR.FindSetting[HarvY,924]}]
	doHarvestArea:Set[${VG-Harvest_SSR.FindSetting[doHarvestArea,TRUE]}]
	doEcho:Set[${VG-Harvest_SSR.FindSetting[doEcho,FALSE]}]
	doLoot:Set[${VG-Harvest_SSR.FindSetting[doLoot,FALSE]}]
	
	if ${Me.Chunk(exists)}
	{
		if !${VG-MyPath_SSR.FindSet[${Me.Chunk}](exists)}
		{
			EchoIt "Adding (${Me.Chunk}) Chunk Region to Config"
			VG-MyPath_SSR:AddSet[${Me.Chunk}]
			CurrentWayPoint:Set[0]
			TotalWayPoints:Set[0]
			VG-MyPath_SSR.FindSet[${Me.Chunk}]:Clear
			Navigate:ClearAll
		}
		else
		{
			TotalWayPoints:Set[${VG-MyPath_SSR[${Me.Chunk}].FindSetting[TotalWayPoints,0]}]
			EchoIt "TotalWayPoints Found in ${Me.Chunk}: ${TotalWayPoints}, Closest WayPoint is ${CurrentWayPoint}"
			call FindNearestWayPoint
			CurrentWayPoint:Set[${Return}]
		}
	}
}

;===================================================
;===      ATOM - Save Variables to XML          ====
;===================================================
atom(script) SaveXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-Harvest/Save"
	mkdir "${savePath}"

	;; save our settings
	VG-Harvest_SSR:AddSetting[HarvX,${HarvX}]
	VG-Harvest_SSR:AddSetting[HarvY,${HarvY}]
	VG-Harvest_SSR:AddSetting[doHarvestArea,${doHarvestArea}]
	VG-Harvest_SSR:AddSetting[doEcho,${doEcho}]
	VG-Harvest_SSR:AddSetting[doLoot,${doLoot}]
	
	;; Save to file
	LavishSettings[VG-Harvest]:Export[${savePath}/MySettings.txt]
}

	
	

