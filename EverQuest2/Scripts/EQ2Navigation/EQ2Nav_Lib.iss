;;;;;;;;;;;;;;;;;;;;;;;;
;;; A Significant portion of the scripting used in this file was taken from OpenBot (for World of Warcraft and ISXWOW).
;;; That source is available at http://www.ob-dev.com/svn/openbot/ in its original form and, except where noted, is
;;; licensed under a Attribution-Noncommercial-No Derivative Works 3.0 United States License
;;; (http://creativecommons.org/licenses/by-nc-nd/3.0/us/)
;;;;;;;;;;;;;;;;;;;;;;;;

#ifndef _EQ2Nav_Lib_
#define _EQ2Nav_Lib_

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2NavMapper_Lib.iss
#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2NavAggressionHandler.iss

objectdef EQ2NavPath
{
	variable point3f Location
	variable int Method
	variable string FQN

	method Initialize(float X, float Y, float Z, int MoveType, string Label )
	{
		This.Location:Set[${X},${Y},${Z}]
		This.Method:Set[${MoveType}]
		This.FQN:Set[${Label}]
	}
}

objectdef EQ2Nav
{

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Values that should be set via GUI interfaces in your scripts (or config files):
	;; ~ Precision is the value to which the navigator will move you to each region centerpoint before moving on.
	;;   The better your system, the lower number you can use.  For tight/smaller zones, you'll want a smaller number;
	;;   for bigger zones you can get away with a larger number.
	;; ~ DestinationPrecision is the value to which the navigator will move you to your final destination.  By having this
	;;   value larger, it will avoid the "bouncing" effect.  As close to, but no less than 4, is best.  Tweak to your best setting.
	;; ~ SkipNavTime is the number of pulses that the Navigator skill skip past doing nothing before acting again.  The goal is
	;;   to run this at 50 with your do/wait loops using "wait 0.5"; however, if you want to use "waitframe" in your loop and/or
	;;   a larger wait time, then you should reduce this or set to zero entirely.
	;; ~ SmartDestinationDetection:  If set to TRUE, then the script will check, when it is within 10 meters of
	;;   the destination, if there are any collisions.  If there are none, it will move there directly.
	;; ~ DirectMovingToTimer:  The limitation, in milliseconds, of how often the script will check its location when moving directly
	;;   to a location (outside of the navigation system)
	;;
	;;   NOTE: DO NOT EDIT THESE VALUES HERE!  Have your script set them!  These default values MUST remain constant so that scripters
	;;         know what to expect.
	;;
	variable float gPrecision = 2
	variable float DestinationPrecision = 5
	variable int SkipNavTime = 50
	variable bool SmartDestinationDetection = TRUE
	variable int DirectMovingToTimer = 250
	variable bool IgnoreAggro = FALSE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; The following values can be changed to suit your needs either here or with your scripts that utilize this library
	variable string AUTORUN = "num lock"
	variable string MOVEFORWARD = "w"
	variable string MOVEBACKWARD = "s"
	variable string STRAFELEFT = "q"
	variable string STRAFERIGHT = "e"
	variable string TURNLEFT = "a"
	variable string TURNRIGHT = "d"
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DO NOT EDIT
	variable EQ2Mapper Mapper
	variable index:EQ2NavPath NavigationPath
	variable point3f NavDestination
	variable lnavpath Path
	variable int StuckTime
	variable int TotalStuck
	variable int SKIPNAV
	variable int degrees
	variable point3f BestPoint
	variable float BestPointDistance
	variable bool UseMapping

	variable int NAV_Wait_Until
	variable int NAV_Wait_Until_Timeout

	variable float NextHopOldDistance
	variable float NextHopDistance
	variable int NextHopOldTime=
	variable float NextHopSpeed
	variable float DestinationDistance

	variable string MeLastLocation
	variable bool MeMoving=FALSE

	variable int BackupTime
	variable int StrafeTime

	variable int MovingTo_Timer
	variable float MovingTo_X
	variable float MovingTo_Y
	variable float MovingTo_Z
	variable float MovingTo_Precision
	variable bool MovingToNearestRegion

	variable collection:string DoorsOpenedThisTrip

	variable bool UsingLSO
	variable float CheckX
	variable float CheckY
	variable float CheckZ
	variable int CheckLocSet
	variable int CheckLocPassCount
	variable int StrafeTime
	variable int BackupTime
	variable int NotMovingPassCount

	variable bool LootNearby
	variable bool AggroDetected
	variable int AggroDetectionTimer
	variable float HopDistanceCheck
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;
	;; END VARIABLE DECLARATIONS
	;;;;;


	method Initialize()
	{
		This.NavDestination:Set[0,0,0]
		This.degrees:Set[15]
		This.UsingLSO:Set[FALSE]
		This.MeLastLocation:Set[${Me.Loc}]
		This.NextHopOldTime:Set[${LavishScript.RunningTime}]
		This.StuckTime:Set[${LavishScript.RunningTime}]
		This.TotalStuck:Set[0]
		This.SKIPNAV:Set[0]
		This.NAV_Wait_Until:Set[0]
		This.NAV_Wait_Until_Timeout:Set[10]
		This.MovingToNearestRegion:Set[FALSE]
		This.CheckLocSet:Set[0]
		This.CheckLocPassCount:Set[0]
		This.StrafeTime:Set[10]
		This.BackupTime:Set[10]
		This.LootNearby:Set[FALSE]
		This.IgnoreAggro:Set[FALSE]
		This.AggroDetected:Set[FALSE]
		This.AggroDetectionTimer:Set[0]
		This.NotMovingPassCount:Set[0]
		This.HopDistanceCheck:Set[0]
	}

	method UseLSO(bool UseIt)
	{
		if (${UseIt})
		{
			This.UsingLSO:Set[TRUE]
			Mapper.UseLSO:Set[TRUE]
			This:Output["Utilizing LSO File"]
		}
		else
		{
			This.UsingLSO:Set[FALSE]
			Mapper.UseLSO:Set[FALSE]
			This:Output["Utilizing XML Files"]
		}
	}

	method LoadMap()
	{
		Mapper.UseLSO:Set[${UsingLSO}]
		Mapper:LoadMap
		This:Output["Navigation Map Loaded"]
	}


	method Shutdown()
	{
	}

	method Output(string Text)
	{
		if ${Verbose} || !${Verbose(exists)}
			echo "EQ2Nav:: ${Text}"
	}

	method Debug(string Text)
	{
		if ${Debug(exists)} && ${Debug(type).Name.Equal[bool]}
		{
			if ${Debug}
			{
				echo "EQ2Nav-Debug:: ${Text}"
			}
		}
		elseif ${Debug(exists)} && ${Debug(type).Name.Equal[debug]}
			if ${Debug.Enabled}
				Debug:Echo["${Text}"]


	}

	method ClearPath()
	{
		This.NavDestination:Set[0,0,0]
		This.NavigationPath:Clear
		This.POIStr:Set[""]
		This.Path:Clear
	}

	member NearestRegionDistance(float FinalDestX, float FinalDestY, float FinalDestZ)
	{
		variable lnavregionref ZoneRegion
		variable lnavregionref NextRegion
		variable float NearestRegionDistance
		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}]}]
		NextRegion:SetRegion[${ZoneRegion.NearestChild[${Me.Loc}]}]
		NearestRegionDistance:Set[${Math.Distance[${Me.Loc},${NextRegion.CenterPoint}]}]

		return ${NearestRegionDistance}
	}

	member:lnavregionref NearestRegion(float X, float Y, float Z)
	{
		return ${Mapper.BestorNearestContainer[${X},${Y},${Z}]}
	}

	member:bool AvailablePath(float X,float Y,float Z)
	{
		variable dijkstrapathfinder PathFinder
		variable lnavpath Path
		variable int Index = 2
		variable lnavregionref CurrentRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion
		variable index:lnavregionref SurroundingRegions

		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			return FALSE
		}

		if ${Math.Distance[${Me.Loc},${X},${Y},${Z}]} < 40 && \
			!${Me.CheckCollision[${X},${Y},${Z}]} && \
			!${Mapper.Topography.IsSteep[${Me.Loc},${X},${Y},${Z}]}
		{
			return TRUE
		}

		Path:Clear
		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}]}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}]}]
		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.Loc}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Math.Calc[${Y}+1]},${Z}].ID}]
		PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},Path]
		if ${Path.Hops}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}

	member:bool AvailablePathToRegion(string Region)
	{
		variable lnavregionref DestinationRegion

		DestinationRegion:SetRegion[${Region}]
		return ${This.AvailablePath[${DestinationRegion.CenterPoint}]}
	}


	member PointsConnect(float toX, float toY, float toZ, float fromX, float fromY, float fromZ)
	{
		variable dijkstrapathfinder PathFinder
		variable lnavpath Path
		variable lnavregionref ToRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion

		if (${toX}==0 && ${toY}==0 && ${toZ}==0) || (${fromX}==0 && ${fromY}==0 && ${fromZ}==0)
		{
			return FALSE
		}

		Path:Clear
		ZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}]}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}]}]
		ToRegion:SetRegion[${DestZoneRegion.BestContainer[${toX},${Math.Calc[${toY}+1]},${toZ}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${fromX},${Math.Calc[${fromY}+1]},${fromZ}].ID}]
		PathFinder:SelectPath[${ToRegion.FQN},${DestinationRegion.FQN},Path]
		if ${Path.Hops}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}

	method CheckAggro()
	{
		;This:Debug["Checking for aggro..."]
		;Stop Moving and pause if we have aggro
		if ${This.IgnoreAggro}
			return

		if ${MobCheck.Detect}
		{
			This:Output["Agression Detected"]
			This:StopRunning

			This.AggroDetected:Set[TRUE]
		}
		else
			This.AggroDetected:Set[FALSE]

		AggroDetectionTimer:Set[${Time.Timestamp}]
	}

	method CheckLoot()
	{
		EQ2:CreateCustomActorArray[byDist,15]

		if ${CustomActor[chest,radius,15](exists)} || ${CustomActor[corpse,radius,15](exists)}
		{
			This:Debug["Loot nearby..."]
			This.LootNearby:Set[TRUE]
		}
		else
			This.LootNearby:Set[FALSE]
	}

	method StartRunning()
	{
		;This:Debug["StartRunning() Called"]
		if !${Me.IsMoving}
			press "${This.AUTORUN}"
	}

	method StopRunning()
	{
		;;;
		;; Sigh... press does not hold down the button long enough to register with EQ2 ..and we cannot "hold" the key with atomic functions...sooo
		;;;
		;; Cutting this down to three presses from five, may help accuracy of end point in some instances.
		;;;
		This:Debug["StopRunning()"]
		press "${This.MOVEBACKWARD}"
		press "${This.MOVEBACKWARD}"
		press "${This.MOVEBACKWARD}"
	}

	method MoveTo(float X, float Y, float Z, float fPrecision)
	{
		This.CheckX:Set[${Me.X}]
		This.CheckY:Set[${Me.Y}]
		This.CheckZ:Set[${Me.Z}]
		This.CheckLocPassCount:Inc
		This.CheckLocSet:Set[${Time.Timestamp}]
		;;;;;;;;;;;
		;;; This method should ONLY be called from Pulse()!
		;;;;;;;;;;;

		;; If we're moving to a specific point, or if this is the final destination -- then accept a much higher precision value
		if !${This.NavigationPath.Get[1](exists)} || ${This.NavigationPath.Used} == 0
		{
			This:Debug["MoveTo:: Distance to Destination: ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}"]
			if (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} <= ${DestinationPrecision})
			{
				;This:Debug["Me.CheckCollision[${X},${Y},${Z}] = ${Me.CheckCollision[${X},${Y},${Z}]}"]
				if (!${Me.CheckCollision[${X},${Y},${Z}]})
				{
					if (${This.MovingToNearestRegion})
					{
						This.MovingToNearestRegion:Set[FALSE]
						if (${Math.Distance[${Me.Loc},${This.NavDestination}]} > ${DestinationPrecision})
						{
							;This:Debug["if (${Math.Distance[${Me.Loc},${This.NavDestination}]} < ${Math.Distance[${Me.Loc},${This.NearestRegion[${Me.Loc}].CenterPoint}]})"]
							if (${Math.Distance[${Me.Loc},${This.NavDestination}]} < ${Math.Distance[${Me.Loc},${This.NearestRegion[${Me.Loc}].CenterPoint}]})
							{
								This:MoveToNearestRegion[${This.NavDestination}]
							}
							else
							{
								This:MoveToNearestRegion[${This.NavDestination}]
							}
							return
						}
					}
					This:Debug["MoveTo()-] Within ${DestinationPrecision}m of destination -- ending movement."]
					This:StopRunning
					This.MovingTo_Timer:Set[0]
					face ${X} ${Y} ${Z}
					This.DoorsOpenedThisTrip:Clear
					This.MeMoving:Set[FALSE]
					return
				}
				else
				{
					;;;;;;;
					;;; TO DO  ...handle obstruction (right now it is doing the same thing as when no obstruction is being hit.)
					;;;;;;;

					if (${This.MovingToNearestRegion})
					{
						This.MovingToNearestRegion:Set[FALSE]
						if (${Math.Distance[${Me.Loc},${This.NavDestination}]} > ${DestinationPrecision})
						{
							;This:Debug["if (${Math.Distance[${Me.Loc},${This.NavDestination}]} < ${Math.Distance[${Me.Loc},${This.NearestRegion[${Me.Loc}].CenterPoint}]})"]
							if (${Math.Distance[${Me.Loc},${This.NavDestination}]} < ${Math.Distance[${Me.Loc},${This.NearestRegion[${Me.Loc}].CenterPoint}]})
								This:MoveToNearestRegion[${This.NavDestination}]
							else
								This:MoveToNearestRegion[${This.NavDestination}]
							return
						}
					}
					This:Debug["MoveTo()-] Within ${DestinationPrecision}m of destination -- ending movement."]
					This:StopRunning
					This.MovingTo_Timer:Set[0]
					face ${X} ${Y} ${Z}
					This.MeMoving:Set[FALSE]
					This.DoorsOpenedThisTrip:Clear
					return
				}
			}
			;; this value needs to be less than the one used with "within 15m of the destination and no obstruction found"
			if (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > 12 && ${This.UseMapping})
			{
				;; if Distance is greater than 10m and the zone contains a "path" to XYZ, use it!
				if (${This.PointsConnect[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]})
				{
					This:Debug["Destination is greater than 10m from your current location and a path exists -- using it."]

					This.MovingToNearestRegion:Set[FALSE]
					This:MoveToLocNoMapping[${X},${Y},${Z},${This.gPrecision}]
					return
				}
			}

			This.MovingTo_X:Set[${X}]
			This.MovingTo_Y:Set[${Y}]
			This.MovingTo_Z:Set[${Z}]
			This.MovingTo_Precision:Set[${fPrecision}]

			face ${X} ${Y} ${Z}
			This:StartRunning

			This.MeMoving:Set[TRUE]
			return
			;;;;;;;
			;;;;;;; END OF SECTION DEALING WITH DIRECT MOVEMENT WITHOUT NAVIGATION PATH
			;;;;;;;
		}


		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;
		;; Otherwise, we are using the navigation system
		;;;;;

		;This:Debug["MoveTo()-] Math.Distance[${Me.X},${Me.Z},${X},${Z}]: ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]} (Precision: ${fPrecision})"]
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > ${fPrecision} || ${Mapper.IsSteep[${X},${Y},${Z},${Me.Loc}]} || ${Me.CheckCollision[${X},${Y},${Z}]}
		{

			face ${X} ${Y} ${Z}
			This:StartRunning

			This.MeMoving:Set[TRUE]
		}
		else
		{
			;This:Debug["Me.CheckCollision[${X},${Y},${Z}] = ${Me.CheckCollision[${X},${Y},${Z}]}"]
			if (!${Me.CheckCollision[${X},${Y},${Z}]})
			{
				This:Debug["MoveTo()-] Within ${fPrecision.Precision[1]}m of destination -- ending movement."]
				This:StopRunning
				This.MovingTo_Timer:Set[0]
				This.MeMoving:Set[FALSE]
				This.DoorsOpenedThisTrip:Clear
				face ${X} ${Y} ${Z}
				if ${This.NavigationPath.Get[1](exists)} || ${This.NavigationPath.Used} > 0
				{
					This:ClearPath
				}
				return
			}
			else
			{
				;;; TO DO -- deal with collision!
				This:Debug["MoveTo()-] Within ${fPrecision.Precision[1]}m of destination -- ending movement."]
				This:StopRunning
				This.MovingTo_Timer:Set[0]
				This.MeMoving:Set[FALSE]
				This.DoorsOpenedThisTrip:Clear
				face ${X} ${Y} ${Z}
				if ${This.NavigationPath.Get[1](exists)} || ${This.NavigationPath.Used} > 0
				{
					This:ClearPath
				}
				return
			}
		}

		This.MovingTo_X:Set[${X}]
		This.MovingTo_Y:Set[${Y}]
		This.MovingTo_Z:Set[${Z}]
		This.MovingTo_Precision:Set[${fPrecision}]
		return
		;;;;;;;
		;;;;;;; END OF SECTION DEALING WITH DIRECT MOVEMENT WITH NAVIGATION PATH
		;;;;;;;
	}

	/* useful for preventing excess MoveToLoc calls */
	member MovingToPoint(float X, float Y, float Z)
	{
		variable int count = 0
		if ${This.Moving}
		{
			if ${This.NavigationPath.Get[1](exists)}
			{
				if ${This.NavDestination.X}==${X} && ${This.NavDestination.Y}==${Y} && ${This.NavDestination.Z}==${Z}
				{
					return TRUE
				}
			}
		}
		return FALSE
	}

	method PopulatePath(float X,float Y, float Z)
	{
		;;;;
		;;This.Path is of type 'lnavpath'
		;;;;

		variable dijkstrapathfinder PathFinder
		variable lnavregionref CurrentRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion

		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}]}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}]}]
		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.Loc}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Math.Calc[${Y}+1]},${Z}].ID}]
		PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},This.Path]

		This:Debug["PopulatePath(): Destination: ${DestinationRegion.FQN} -- Hops: ${This.Path.Hops}"]
	}

	method PopulateNavigationPath()
	{
		;;;;
		;;This.NavigationPath is of type 'index:EQ2NavPath'
		;;;;

		variable int Index = 2

		This.NavigationPath:Clear
		do
		{
			This:Debug["PopulateNavigationPath(): Adding [${This.Path.Region[${Index}].CenterPoint}] - [${This.Path.Region[${Index}].FQN}] to NavigationPath"]
			This.NavigationPath:Insert[${This.Path.Region[${Index}].CenterPoint},0,${This.Path.Region[${Index}].FQN}]
		}
		while ${Index:Inc} <= ${This.Path.Hops}

		This:Debug["PopulateNavigationPath(): ${NavigationPath.Used} hops used."]
	}

	; Check for existence of a region by name
	member:bool RegionExists(string RegionName)
	{
		variable lnavregionref DestinationRegion
		DestinationRegion:SetRegion[${RegionName}]
		return ${DestinationRegion.Region(exists)}
	}

	; Return the distance between a region and an arbitrary point (such as an NPC)
	member:float64 DistanceFromPointToRegion(float PointX, float PointY, float PointZ, string RegionName)
	{
		variable lnavregionref DestinationRegion
		DestinationRegion:SetRegion[${RegionName}]
		if ${DestinationRegion.Region(exists)}
		{
			return ${Math.Distance[${PointX},${PointY},${PointZ},${DestinationRegion.CenterPoint.X},${DestinationRegion.CenterPoint.Y},${DestinationRegion.CenterPoint.Z}]}
		}
		This:Debug["DistanceFromPointToRegion:: Warning: Region ${RegionName} not found"]
		return -1
	}

	; Return the region with the smallest distance to an arbitrary point (such as an NPC)
	member:string ClosestRegionToPoint(float PointX, float PointY, float PointZ, ... RegionNames)
	{
		variable string ClosestRegion
		variable float64 ClosestRegionDistance = 0
		variable float64 CurrentRegionDistance = 0
		variable int Pos

		if ${RegionNames.Size} > 0
		{
			if ${RegionNames.Size} == 1
			{
				return ${RegionNames[1]}
			}

			Pos:Set[1]
			CurrentRegionDistance:Set[${This.DistanceFromPointToRegion[${PointX},${PointY},${PointZ}, ${RegionNames[${Pos}]}]}]
			This:Debug["ClosestRegionToPoint:: Region #${Pos}:${RegionNames[${Pos}]} Distance: ${CurrentRegionDistance}"]
			ClosestRegionDistance:Set[${CurrentRegionDistance}]
			ClosestRegion:Set[${RegionNames[${Pos}]}]
			while ${Pos:Inc} <= ${RegionNames.Size}
			{
				CurrentRegionDistance:Set[${This.DistanceFromPointToRegion[${PointX},${PointY},${PointZ}, ${RegionNames[${Pos}]}]}]
				This:Debug["ClosestRegionToPoint:: Region #${Pos}:${RegionNames[${Pos}]} Distance: ${CurrentRegionDistance}"]
				if ${CurrentRegionDistance} != -1 && \
					${CurrentRegionDistance} < ${ClosestRegionDistance}
				{
					ClosestRegionDistance:Set[${CurrentRegionDistance}]
					ClosestRegion:Set[${RegionNames[${Pos}]}]
				}
			}
			This:Debug["ClosestRegionToPoint:: Returning ${ClosestRegion}"]
			return ${ClosestRegion}
		}
		This:Debug["ClosestRegionToPoint:: Error: no regions specified"]
		return ""
	}

	method MoveToRegion(string RegionName)
	{
		This.UseMapping:Set[TRUE]
		This.CheckLocPassCount:Set[0]
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion

		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}]}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Mapper.ZoneText}]}]
		DestinationRegion:SetRegion[${RegionName}]
		if !${DestinationRegion.Region(exists)}
		{
			This:Debug["MoveToRegion:: Error: Region ${RegionName} not found"]
		}
		This:Debug["MoveToRegion:: Moving to ${DestinationRegion.FQN}"]
		This:MoveToLoc[${DestinationRegion.CenterPoint}]
	}

	method MoveToLocNoMapping(float X, float Y, float Z,float Precision=${gPrecision})
	{
		variable int count = 0
		variable index:lnavregionref SurroundingRegions
		This.CheckLocPassCount:Set[0]

		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to run to NOTHING
			return
		}

		; If we are already PRECISION from it why bother moving?
		if ${Math.Distance[${Me.Loc},${X},${Y},${Z}]}<${This.PRECISION}
		{
			This:Output["Already here, not moving."]
			This:ClearPath
			This.MeMoving:Set[FALSE]
			This.DoorsOpenedThisTrip:Clear
			return
		}

		This:ClearPath
		This:Debug["Moving to ${X},${Y},${Z} directly. (Precision: ${Precision})"]

		This.MovingTo_X:Set[${X}]
		This.MovingTo_Y:Set[${Y}]
		This.MovingTo_Z:Set[${Z}]
		This.MovingTo_Precision:Set[${Precision}]
		This.MovingTo_Timer:Set[0]
		This.MeMoving:Set[TRUE]
		This.NavDestination:Set[${X},${Y},${Z}]
		This.UseMapping:Set[FALSE]
		return
	}

	method MoveToLoc(float X, float Y, float Z)
	{
		This.UseMapping:Set[TRUE]
		This.CheckLocPassCount:Set[0]

		variable int count = 0
		variable index:lnavregionref SurroundingRegions


		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to run to NOTHING
			return
		}


		; If we are already PRECISION from it why bother moving?
		if ${Math.Distance[${Me.Loc},${X},${Y},${Z}]}<${This.PRECISION}
		{
			This:Output["Already here, not moving."]
			This:ClearPath
			This.MeMoving:Set[FALSE]
			This.DoorsOpenedThisTrip:Clear
			return
		}

		;If we already have a Path make sure it is a new one
		if ${This.NavigationPath.Get[1](exists)}
		{
			if ${This.NavDestination.X}==${X} && ${This.NavDestination.Y}==${Y} && ${This.NavDestination.Z}==${Z}
			{
				This:Output["Error: Calling again to same destination. Aborting!"]
				This.MeMoving:Set[FALSE]
				This.DoorsOpenedThisTrip:Clear
				return
			}
		}

		This:ClearPath

		if (${Math.Distance[${Me.Loc},${X},${Y},${Z}]} < 20 && !${Me.CheckCollision[${X},${Y},${Z}]})
		{
			This:Debug["Moving to ${X},${Y},${Z} directly."]

			This.MovingToNearestRegion:Set[TRUE]
			This.MovingTo_X:Set[${X}]
			This.MovingTo_Y:Set[${Y}]
			This.MovingTo_Z:Set[${Z}]
			This.MovingTo_Precision:Set[${This.gPrecision}]
			This.MovingTo_Timer:Set[0]
			This.MeMoving:Set[TRUE]
			This.NavDestination:Set[${X},${Y},${Z}]
			return
		}
		else
		{
			This:PopulatePath[${X},${Y},${Z}]

			if (${This.Path.Hops} > 0)
			{
				This:PopulateNavigationPath
				This.NavDestination:Set[${X},${Y},${Z}]
				This.MeMoving:Set[TRUE]
				return
			}
			else
			{
				; We didnt get a path run to the next closest point and try from there
				This:Output["There is not enough mapping data between your current (${Me.Loc}) and destination (${X},${Y},${Z}) locations (Dist: ${Math.Distance[${Me.Loc},${X},${Y},${Z}]}).  Moving to nearest mapped point..."]
				This:MoveToNearestRegion[${X},${Y},${Z}]
			}
		}
	}

	; If you're currently in an unmapped region, call this to move to the nearest mapped region.
	method MoveToNearestRegion(float FinalDestX, float FinalDestY, float FinalDestZ)
	{
		This.CheckLocPassCount:Set[0]
		;declarevariable NextRegion lnavregionref local ${This.NearestRegion[${Me.Loc}]}
		variable lnavregionref ZoneRegion
		variable lnavregionref NextRegion
		variable float NearestRegionDistance
		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}]}]
		NextRegion:SetRegion[${ZoneRegion.NearestChild[${Me.Loc}]}]
		NearestRegionDistance:Set[${Math.Distance[${Me.Loc},${NextRegion.CenterPoint}]}]

		/*  This function is not working exactly right -- reported to Lax
		echo "Me.Loc: ${Me.Loc}"
		echo "NearestChild: ${ZoneRegion.NearestChild[${Me.Loc}].FQN} (Distance: ${NearestRegionDistance})"
		variable index:lnavregionref NearestChildren
		echo "NearestChildren: ${ZoneRegion.NearestChildren[NearestChildren,20,${Me.Loc}]}"
		echo "NearestChildren[1]: ${NearestChildren.Get[1].FQN}"
		variable index:lnavregionref DescendantsWithin
		echo "DescendantsWithin: ${ZoneRegion.DescendantsWithin[DescendantsWithin,20,${Me.Loc}]}"
		echo "DescendantsWithin[1]: ${DescendantsWithin.Get[1].FQN}"
		variable index:lnavregionref ChildrenWithin
		echo "ChildrenWithin: ${ZoneRegion.ChildrenWithin[ChildrenWithin,20,${Me.Loc}]}"
		echo "ChildrenWithin[1]: ${ChildrenWithin.Get[1].FQN}"
		*/


		if ${NearestRegionDistance} > 50
		{
			This:StopRunning
			face ${FinalDestX} ${FinalDestY} ${FinalDestZ}
			This.MeMoving:Set[FALSE]
			This:Output["The nearest mapped CenterPoint (${NextRegion.CenterPoint}) is ${NearestRegionDistance} away.  More mapping data is required before continuing"]
			return
		}

		if ${NearestRegionDistance} < ${DestinationPrecision}
		{
			This:Output["The nearest mapped CenterPoint (${NextRegion.CenterPoint}) is within ${NearestRegionDistance} meters -- Finding path to destination"]
			This:StopRunning
			face ${FinalDestX} ${FinalDestY} ${FinalDestZ}

			This:ClearPath
			This:PopulatePath[${FinalDestX},${FinalDestY},${FinalDestZ}]
			if (${This.Path.Hops} > 0)
			{
				This:PopulateNavigationPath
				This.NavDestination:Set[${FinalDestX},${FinalDestY},${FinalDestZ}]
				This.MeMoving:Set[TRUE]
			}
			else
			{
				; We didnt get a path run to the next closest point and try from there
				This:Output["There is not enough mapping data between your current (${Me.Loc}) and destination (${FinalDestX},${FinalDestY},${FinalDestZ}) locations."]
			}
			return
		}


		if ${Me.CheckCollision[${NextRegion.CenterPoint}]}
		{
			This:StopRunning
			face ${FinalDestX} ${FinalDestY} ${FinalDestZ}
			This.MeMoving:Set[FALSE]
			This:Output["The nearest mapped point (${NextRegion.CenterPoint}) is only ${NearestRegionDistance} away; however, there is an obstacle in the way.  More mapping data or manual editing of the map file is required."]
			return
		}

		This.MovingToNearestRegion:Set[TRUE]
		This.MovingTo_X:Set[${NextRegion.CenterPoint.X}]
		This.MovingTo_Y:Set[${NextRegion.CenterPoint.Y}]
		This.MovingTo_Z:Set[${NextRegion.CenterPoint.Z}]
		This.MovingTo_Precision:Set[${This.gPrecision}]
		This.MovingTo_Timer:Set[0]
		This.MeMoving:Set[TRUE]
		NavDestination:Set[${FinalDestX},${FinalDestY},${FinalDestZ}]

		This:Debug["MoveToNearestRegion() -- Moving to ${This.MovingTo_X}, ${This.MovingTo_Y}, ${This.MovingTo_Z} -- Final Destination: ${NavDestination}"]
	}

	method Pulse()
	{
		;;;;;;;;;;;
		;; NOTES:
		;; 1.
		;;;;;;;;;;;


		;Only do every x frames (CPU Saver)
		if ${This.SKIPNAV} < ${This.SkipNavTime}
		{
			This.SKIPNAV:Inc
			return
		}
		This.SKIPNAV:Set[0]

		;;;
		;; Check for Aggression every 3 seconds or so
		variable bool PreviousAggro
		PreviousAggro:Set[${AggroDetected}]
		if (${Math.Calc64[${Time.Timestamp}-${AggroDetectionTimer}]} > 3)
		   This:CheckAggro
		if ${AggroDetected}
			return
		else
		{
			if ${PreviousAggro}
			{
				This:CheckLoot
				return
			}
		}
		if ${CheckLoot}
			return
		;;
		;;;

		;;;
		;; If the obstacle handler is running...then return
		if ${Script[EQ2NavObstacleHandler](exists)}
		{
			;This:Debug["EQ2NavObstacleHandler running...."]
			return
		}
		;;
		;;;

		;;;
		;; If eq2bot is running and we are in combat...then return
		if ${Script[eq2bot](exists)}
		{
			if ${Me.InCombat} || ${Actor[${Scipt[eq2bot].Variable[KillTarget]}](exists)}
			{
				if ${Me.IsMoving}
					This:StopRunning
				return
			}
		}
		;;
		;;;


		;; TO DO -- do we want to utilize this to know if we should stop?`
		This.MeLastLocation:Set[${Me.Loc}]


		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;; Check For Door
		variable int DoorID
		DoorID:Set[${Actor[door,xzrange,5,yrange,1].ID}]
		if (${DoorID(exists)})
		{
			if (!${This.DoorsOpenedThisTrip.Element[${DoorID}](exists)})
			{
				;This:Debug["Clicking Door!"]
				Actor[id,${DoorID}]:DoubleClick
				This.DoorsOpenedThisTrip:Set[${DoorID},"Door"]
			}
		}
		;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;
		;; If the script thinks we are moving...but we really are not, then we should handle that.
		if ${This.CheckLocPassCount} > 2
		{
			;echo "This.CheckLocPassCount: ${This.CheckLocPassCount}"
			if ${Math.Calc64[${Time.Timestamp}-${CheckLocSet}]} < 2
			{
				;echo "{Math.Calc64[{Time.Timestamp}-{CheckLocSet}]}: ${Math.Calc64[${Time.Timestamp}-${CheckLocSet}]}"
				if ${Math.Distance[${Me.Loc},${This.CheckX},${This.CheckY},${This.CheckZ}]} < .1
				{
					echo "{Math.Distance[{Me.Loc},{This.CheckX},{This.CheckY},{This.CheckZ}]}: ${Math.Distance[${Me.Loc},${This.CheckX},${This.CheckY},${This.CheckZ}]}"
					This:Debug["We must be stuck...handling."]
					This:StopRunning
					runscript "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2NavObstacleHandler.iss" "${This.AUTORUN}" "${This.MOVEFORWARD}" "${This.MOVEBACKWARD}" "${This.STRAFELEFT}" "${This.STRAFERIGHT}" "${This.BackupTime}" "${This.StrafeTime}"
					This.CheckLocPassCount:Set[0]
					return
				}
			}
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;



		;;;;;;;;;;;;;;;;;;;;;;
		;; Deal with Movement without a Path
		if ${This.MeMoving}
		{
			if ${LavishScript.RunningTime}-${This.MovingTo_Timer}> ${This.DirectMovingToTimer}
			{
				;; Only pertinant if there is no current NavigationPath
				if !${This.NavigationPath.Get[1](exists)} || ${This.NavigationPath.Used} == 0
				{
					;This:Debug["Calling MoveTo(${This.MovingTo_X},${This.MovingTo_Y},${This.MovingTo_Z},${This.MovingTo_Precision})"]
					This:MoveTo[${This.MovingTo_X},${This.MovingTo_Y},${This.MovingTo_Z},${This.MovingTo_Precision}]
					This.MovingTo_Timer:Set[${LavishScript.RunningTime}]
					return
				}
			}
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;

		if ${This.NavigationPath.Get[1](exists)}
		{
			;This:Debug["DESTINATION: ${This.NavigationPath.Get[${NavigationPath.Used}].FQN}"]
			;This:Debug["NavigationPath[1] exists (${This.NavigationPath.Get[1].FQN})..."]
			This.NextHopDistance:Set[${Math.Distance[${Me.Loc},${This.NavigationPath.Get[1].Location}]}]
			This.DestinationDistance:Set[${Math.Distance[${Me.Loc},${This.NavDestination}]}]
			This:Debug["Distance to ${This.NavigationPath.Get[1].FQN}: ${This.NextHopDistance} (Distance to Destination: ${This.DestinationDistance})"]


			if (${This.DestinationDistance} < ${This.DestinationPrecision})
			{
				if (!${Me.CheckCollision[${This.NavDestination}]})
				{
					This:Debug["Within ${This.DestinationPrecision} meters of destination (${This.NavigationPath.Get[${This.NavigationPath.Used}].FQN})-- ending movement."]
					This:StopRunning
					This.MovingTo:Set[FALSE]
					This.MeMoving:Set[FALSE]
					This.MovingTo_Timer:Set[0]
					face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
					This:ClearPath
					This.DoorsOpenedThisTrip:Clear
					return
				}
				else
				{
					;; TO DO -- handle collisions!
					This:Debug["Within ${This.DestinationPrecision} meters of destination  (${This.NavigationPath.Get[${This.NavigationPath.Used}].FQN}); however, there is collision between you and the destination....."]
					This:Debug["Within ${This.DestinationPrecision} meters of destination (${This.NavigationPath.Get[${This.NavigationPath.Used}].FQN})-- ending movement."]
					This:StopRunning
					This.MovingTo:Set[FALSE]
					This.MeMoving:Set[FALSE]
					This.MovingTo_Timer:Set[0]
					face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
					This:ClearPath
					This.DoorsOpenedThisTrip:Clear
					return
				}
			}

			;; TODO -- make this value an option
			if (${SmartDestinationDetection})
			{
				if (${This.DestinationDistance} <= 10 && !${Me.CheckCollision[${This.NavDestination}]})
				{
					This:Debug["Within 10m of the destination (${This.NavigationPath.Get[${This.NavigationPath.Used}].FQN}) and no obstructions found -- moving directly (outside of navigation system)"]
					face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
					Dest:Set[${This.NavDestination}]
					This:ClearPath
					;This:Debug["Calling MoveTo(${Dest}) -- Distance: ${This.DestinationDistance}"]
					This.MeMoving:Set[TRUE]
					This:MoveTo[${Dest},${This.gPrecision}]
					return
				}
			}

			;; TODO -- make this value an option ....and fix ..it is not working as intended...maybe it is not a good idea at all
			;if ${This.NextHopDistance} > 50
			;{
			;    This:Debug["Bypassed next Hop in path -- resetting path"]
			;    Dest:Set[${This.NavDestination}]
			;    This:ClearPath
			;    This.MeMoving:Set[TRUE]
			;    This:MoveToLoc[${Dest}]
			;    return
			;}

			if ${This.NextHopDistance} <= ${This.gPrecision}
			{
				if (${Me.CheckCollision[${This.NavigationPath.Get[1].Location}]})
				{
					;;; TO DO -- handle collisions
					This:Debug["The next hop is within ${This.gPrecision}m; however, there is an obstruction...."]
				}

				;This:Debug["The next hop is within ${This.gPrecision}m -- removing ${This.NavigationPath.Get[1].FQN} from path."]
				This.NavigationPath:Remove[1]
				This.NavigationPath:Collapse


				if (!${This.NavigationPath.Get[1](exists)} || ${This.NavigationPath.Used} <= 0)
				{
					if (!${Me.CheckCollision[${This.NavDestination}]})
					{
						This:Debug["NavigationPath now empty -- ending movement."]
						This:StopRunning
						This.MeMoving:Set[FALSE]
						This.DoorsOpenedThisTrip:Clear
						return
					}
					else
					{
						;; TO DO -- handle obstructions in this context
						This:Debug["NavigationPath now empty -- ending movement. (obstruction present)"]
						This:StopRunning
						This.MeMoving:Set[FALSE]
						This.DoorsOpenedThisTrip:Clear
						return
					}
				}

				This:Debug["NavigationPath[1] is now ${This.NavigationPath.Get[1].FQN}"
				This.NextHopDistance:Set[${Math.Distance[${Me.Loc},${This.NavigationPath.Get[1].Location}]}]

				if (${This.NextHopDistance} < ${This.gPrecision})
				{
					This.DestinationDistance:Set[${Math.Distance[${Me.Loc},${This.NavDestination}]}]
					if (${This.DestinationDistance} < ${This.gPrecision})
					{
						This:Debug["Within ${This.gPrecision} meters of destination -- ending movement."]
						face ${This.NavDestination.X} ${This.NavDestination.Y} ${This.NavDestination.Z}
						This:ClearPath
						This:StopRunning
						This.MeMoving:Set[FALSE]
						This.DoorsOpenedThisTrip:Clear
						return
					}
					else
					{
						This:Debug["Next hop was within precision range as well - resetting path."]
						Dest:Set[${This.NavDestination}]
						This:ClearPath
						This.MeMoving:Set[TRUE]
						This:MoveToLoc[${Dest}]
						return
					}
				}
				else
				{
					;This:Debug["Calling MoveTo(${This.NavigationPath.Get[1].FQN}) -- Distance: ${This.NextHopDistance}"]
					This:MoveTo[${This.NavigationPath.Get[1].Location},${This.gPrecision}]
					This.MeMoving:Set[TRUE]
				}
			}
			else
			{
				;This:Debug["${This.NavigationPath.Get[1].FQN} still out of precision range."]
				if (!${Me.IsMoving})
				{
					;;; If we have not moved in more than 4 pulses, then we must be stuck... ;;;
					if (${This.NotMovingPassCount} > 4)
					{
						This:Debug["We must be stuck...handling. (NotMovingPassCount: ${This.NotMovingPassCount})"]
						This:StopRunning
						runscript "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2NavObstacleHandler.iss" "${This.AUTORUN}" "${This.MOVEFORWARD}" "${This.MOVEBACKWARD}" "${This.STRAFELEFT}" "${This.STRAFERIGHT}" "${This.BackupTime}" "${This.StrafeTime}"
						This.NotMovingPassCount:Set[0]
						return
					}

					This:Debug["NavigationPath exists, but not moving -- issuing movement"]
					This.NextHopSpeed:Set[(${This.NextHopOldDistance}-${This.NextHopDistance})/(${LavishScript.RunningTime}-${This.NextHopOldTime}]
					This.NextHopDistance:Set[${Math.Distance[${Me.Loc},${This.NavigationPath.Get[1].Location}]}]
					This:Debug["Calling MoveTo(${This.NavigationPath.Get[1].FQN}) -- Distance: ${This.NextHopDistance}"]
					This.MeMoving:Set[TRUE]
					This.CheckLocPassCount:Set[0]
					This:MoveTo[${This.NavigationPath.Get[1].Location},${This.gPrecision}]
					This.NotMovingPassCount:Inc
					This.HopDistanceCheck:Set[${This.NextHopDistance}]
					return
				}
				else
				{
					This.NextHopSpeed:Set[(${This.NextHopOldDistance}-${This.NextHopDistance})/(${LavishScript.RunningTime}-${This.NextHopOldTime}]
					This.NextHopDistance:Set[${Math.Distance[${Me.Loc},${This.NavigationPath.Get[1].Location}]}]
					;This:Debug["Calling MoveTo(${This.NavigationPath.Get[1].FQN}) -- Distance: ${This.NextHopDistance}"]
					This.MeMoving:Set[TRUE]
					This.CheckLocPassCount:Set[0]
					;;; If we have moved more than 0.1, then reset the NotMovingPassCount var. ;;;
					if (${Math.Abs[${This.NextHopDistance}-${This.HopDistanceCheck}]} > 0.1)
						This.NotMovingPassCount:Set[0]
					This:MoveTo[${This.NavigationPath.Get[1].Location},${This.gPrecision}]
					This.HopDistanceCheck:Set[${This.NextHopDistance}]
					return
				}
			}
		}
	}


	;----------
	;----- Movement Functions
	;----------

	method FaceXYZ(float X, float Y, float Z)
	{
		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to face NOTHING
			This:Debug["Error in FaceXYZ: Call to 0,0,0."]
			return
		}
		face ${X} ${Y} ${Z}
	}

	/* replacement to DegreesCCW */
	member Flip(float theHeading)
	{
		theHeading:Dec[180]
		if ${theHeading} < 0
		{
			theHeading:Inc[360]
		}
		return ${theHeading}
	}

	method FaceHeading(float hd)
	{
		if ${Math.Abs[${Me.Heading}-${hd}]} > 10
		{
			This:Debug["FaceHeading: Facing ${hd}."]
			face ${hd}
		}
	}

	member Moving()
	{
		return ${This.MeMoving}
	}
}

#endif /* _EQ2Nav_Lib_ */
