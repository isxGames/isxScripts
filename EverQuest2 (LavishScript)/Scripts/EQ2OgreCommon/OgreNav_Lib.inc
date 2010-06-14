;***Version 3.01***
/**

Version 3.01, 06/13/2010 by Valerian -- Bugfix only.
*  Fixed MovementKeys.iss support to allow for older MovementKeys include file.
   Will no longer error out with _AUTORUN_ press error.

Version 3.00, 03/01/2010 by Valerian
Added MovementKeys.iss support
Removed atexit function. Include files should not include an atexit function.
Moved code from atexit into waypointNavigator:Shutdown method.
Added code to remember script name for Shutdown events after script destroyed.
Implemented Debug object

Version 2.00, 10/14/2009 by Kannkor (Hotshot)
Minor re-write to work smoother with OgreNavCreator

Version 1.00, 09/30/2009 by Kannkor (Hotshot)
Initial release. If any changes are made please update the version, and provide well documentation on what was changed.

**/

#define DEBUG_ENABLED TRUE
#ifndef _DEBUG_
#includeoptional "${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss"
#define DEBUG_OGRE_NAV TRUE
#else
#define DEBUG_OGRE_NAV FALSE
#endif /* _DEBUG_ */


#define AUTORUN "num lock" ; Set up default.

;* This could be done easier with a simple #ifdef _AUTORUN_ but the method
;  used is optimal for possible future usage of other movement keys.
#includeoptional "${LavishScript.HomeDirectory}/Scripts/EQ2Common/MovementKeys.iss"

; MovementKeys did not have an autorun define prior to version 2
; Lax needs to make comments in preprocessor lines work as intended.
#if ${Int[_MOVE_KEYS_]} >= 2
	#undef AUTORUN
	#define AUTORUN _AUTORUN_
#endif /* _MOVE_KEYS_ >= 2 */


variable dijkstrapathfinder PathFinder
variable lnavregionref CurrentRegion
variable lnavregionref ZoneRegion
variable lnavregionref DestZoneRegion
variable lnavregionref DestinationRegion
variable lnavpath Path
variable float DestPointX
variable float DestPointY
variable float DestPointZ
variable bool MovementEnabled=FALSE
variable bool AutoMovementEngaged=FALSE
variable lnavregionref NextRegion
variable lnavregionref EndCenterRegion
variable float NearestRegionDistance
variable point3f LastLoc
variable OgreNavTimerObject OgreNavTimerOb
variable int OgreNavStuck
variable bool LoopBool=TRUE

#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreMapController.inc"

function OgreNav(string Location, float X, float Y, float Z)
{

	;Debug:Echo["${Time}: Entering OgreNav with Loc: ${Location}"]
	LoopBool:Set[TRUE]
	while ${LoopBool} && !${ForcedStopped}
	{
		LoopBool:Set[FALSE]
		if ${Nav.OgreNavStatus.Equal[Stuck]}
		{
			Debug:Echo["We are stuck and it is looping, or calling OgreNav_Lib from ${Script.Filename}."]
			return
		}

		;***Scripts - Below can be declared and modified with objects in your move scripts***
		if !${Nav(exists)}
			declarevariable Nav waypointNavigator script
		if !${ConditionsOb(exists)}
			declarevariable ConditionsOb ConditionsObject script
		if !${InformationOb(exists)}
			declarevariable InformationOb InformationObject script

		Nav.OgreNavStuck:Set[0]

		;***Nothing below should be changed***

		if ${Location.Equal[Loc]}
		{
			Nav:MoveToLoc[${X},${Y},${Z}]
		}
		else
		{
			Debug:Echo["Moving to ${Location}"]
			Nav:MoveToRegion[${Location}]
		}
		if ${DestPointX}==0 && ${DestPointY}==0 && ${DestPointZ}==0
		{
			Debug:Echo["If this is spamming repeatedly, please bug report this with as much information as possible. Spam reason: Dest not found XYZ=000"]
			Debug:Echo["Loc: ${Location} - x:${DestPointX} - y:${DestPointY} - z:${DestPointZ}"]
			wait 50
			InformationOb:DestNotFound
			return
		}
		Nav:OgrePath[${DestPointX},${DestPointY},${DestPointZ}]

		;If the end point is mapped, we need to make sure we end up on a mapped point.
		if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}].CenterPoint}]} < ${Math.Calc[${Nav.Precision}+0]}
		{
			InformationOb:AlreadyThere
		}
		elseif ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}==${ZoneRegion.ID} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${DestPointX},${DestPointY},${DestPointZ}]} < ${Math.Calc[${Nav.Precision}+0]}
		{
			InformationOb:AlreadyThere
		}
		elseif ${Path.Hops}
		{
			Debug:Echo["Start/End points are mapped"]
			call OgreMove
		}
		else
		{
			if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
			{
				;Start/End points mapped, but no path (hops) between them.
				;Can we run directly there?
				if !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+1]},${Me.Z},${X},${Math.Calc[${Y}+1]},${Z}]}
				{
					call OgreMoveToPointOffPath ${X} ${Y} ${Z}
				}
				Debug:Echo["We're on a mapped area with no hops and can't move directly there. We're screwed :)"]
				Nav:Stop[Stuck]
				InformationOb:DestNotFound
				return
			}
			;Lets see if the end point is mapped.
			if ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
			{
				;End point _IS_ mapped
				call CheckMoveOffPath
				LoopBool:Set[TRUE]
				Debug:Echo["We should be back on the path, looping it.."]
				continue
			}
			else
			{
				;End point is _OFF_ the mappead area.
				;We have the closest mapped spot to the area we want to move too above
				;Check if the end spot and closest spot have collision
				;if not - lavishnav as far as we can, then raw move
				;Otherwise - no path available

				;Can we run directly there?
				if !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+1]},${Me.Z},${X},${Math.Calc[${Y}+1]},${Z}]}
				{
					call OgreMoveToPointOffPath ${X} ${Y} ${Z}
				}
				else
				{
					;Okay we can't run directly there.
					;Lets start backwards. Is the spot collision free to the nearest lavishnav point?
					
					NextRegion:SetRegion[${ZoneRegion.NearestChild[${DestPointX},${DestPointY},${DestPointZ}]}]
					NearestRegionDistance:Set[${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${NextRegion.CenterPoint}]}]

					if !${EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${NextRegion.CenterPoint}]}
					{
						;Endspot <- lavishnav <-
						;Lets try to lavishnav to the point.
						Nav:MoveToLoc[${NextRegion.CenterPoint}]
						Nav:OgrePath[${NextRegion.CenterPoint}]
						if !${Path.Hops}
						{
							;No hops means we're not on the path
							call CheckMoveOffPath
							;Should get us back on the path
						}
						NextRegion:SetRegion[${ZoneRegion.NearestChild[${DestPointX},${DestPointY},${DestPointZ}]}]
						NearestRegionDistance:Set[${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${NextRegion.CenterPoint}]}]
						Nav:MoveToLoc[${NextRegion.CenterPoint}]
						Nav:OgrePath[${DestPointX},${DestPointY},${DestPointZ}]

						if ${Path.Hops}
						{
							call OgreMove
						
							;Should get us to the end of lavishpoint
							;Finish it off with a direct move.
							;call OgreMoveOffPath ${X} ${Y} ${Z}
							call OgreMoveToPointOffPath ${X} ${Y} ${Z}
						}
						else
							Debug:Echo["Start/End points NOT mapped, tried to move onto the path and it's saying no hops.."]
					}
				}
			}
		}
;Debug:Echo["End of OgreNav_Lib"]
		;EQ2OgreHarvestNextLoc:Set[none]
		Nav:StopMoving
;Debug:Echo["${Time}: ${Script.Filename}: Breaking out of OgreNav_lib"]
		break
	}
}
objectdef InformationObject
{
	method AlreadyThere()
	{
		Debug:Echo["EQ2OgreNav: ${Time}: Already at current point"]
	}
	method DestNotFound()
	{
		Debug:Echo["EQ2OgreNav: ${Time}: Destination not supplied or found. Where do you want to go?"]
	}
}
objectdef ConditionsObject
{
	member:bool Checks()
	{
		return TRUE
	}
}
function:bool CheckMoveOffPath()
{
	NextRegion:SetRegion[${ZoneRegion.NearestChild[${Me.ToActor.Loc}]}]
	NearestRegionDistance:Set[${Math.Distance[${Me.ToActor.Loc},${NextRegion.CenterPoint}]}]

	if ${NearestRegionDistance} <= ${Nav.DistanceToMoveBackToPath}
	{
		if !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+0.5]},${Me.Z},${NextRegion.CenterPoint.X},${Math.Calc[${NextRegion.CenterPoint.Y}+0.5]},${NextRegion.CenterPoint.Z}]}
		{
			call OgreMoveOffPath ${NextRegion.CenterPoint.X} ${Math.Calc[${NextRegion.CenterPoint.Y}+0.5]} ${NextRegion.CenterPoint.Z}
		}
		else
		{
			Debug:Echo["Off the mapped area and collision detected to the nearest mapped point - Can't run there."]
			Nav:Stop[Stuck]
			return FALSE
		}
	}
	else
		Debug:Echo["Nearest point on path is located: ${NearestRegionDistance} away. This is further than we can run ( ${Nav.DistanceToMoveBackToPath} ).."]
}
function OgreMoveOffPath(float X, float Y, float Z)
{
	Nav.OgreNavStuck:Set[0]	

;	while (${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
;Debug:Echo["${Time} OgreMoveOffPath: while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped})"]
if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID}
{
	Debug:Echo["${Time}: ${Script.Filename}: Func: OgreMoveOffPath. Called and exited. (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped})"]
	InformationOb:AlreadyThere
	LoopBool:Set[FALSE]
	Nav:Stop
	return
	;call OgreMoveOffPathNoLavishNav ${X} ${Y} ${Z}
}
	;Stop moving once we get back onto the path OR if we are within 2 "meters" of our destination.
	while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > 1)
	{
		if ${Nav.TargetRequired} && !${Target(exists)}
		{
			Debug:Echo["${Time} OgreNav: No Valid Target, stopping movement and script"]
			Nav:Stop[Stuck]
			return
		}
		if ${ConditionsOb.Checks} && !${Nav.Paused}
		{
			face ${X} ${Y} ${Z}
			Nav:StartMoving
			wait 1
			if ${Nav.Stuck}
				return
		}
		else
		{
			Nav:StopMoving
			wait 5
		}	
	}

	if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped}
		Debug:Echo["Exited Func: OgreMoveOffPath because we got within 2 of our dest, but not on the path."]
}
function OgreMoveOffPathNoLavishNav(float X, float Y, float Z)
{
	Nav.OgreNavStuck:Set[0]

if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} < ${Nav.OffMapPrecision} 
{
Debug:Echo["WTF: ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} ||| {Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} "]


}
	while (${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
	{
		if ${Nav.TargetRequired} && !${Target(exists)}
		{
			Debug:Echo["${Time} OgreNav: No Valid Target, stopping movement and script"]
			Nav:Stop[Stuck]
			return
		}
		if ${ConditionsOb.Checks} && !${Nav.Paused}
		{
			face ${X} ${Y} ${Z}
			Nav:StartMoving
			wait 1
			if ${Nav.Stuck}
				return
		}
		else
		{
			Nav:StopMoving
			wait 5
		}	
	}
}
function OgreMoveToPointOffPath(float X, float Y, float Z)
{	
	Nav.OgreNavStuck:Set[0]

	while (${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
	{
		if ${Nav.TargetRequired} && !${Target(exists)}
		{
			Debug:Echo["${Time} OgreNav: No Valid Target, stopping movement and script"]
			Nav:Stop[Stuck]
			return
		}
		if ${ConditionsOb.Checks} && !${Nav.Paused}
		{
			face ${X} ${Y} ${Z}
			Nav:StartMoving
			wait 1
			if ${Nav.Stuck}
				return
		}
		else
		{
			Nav:StopMoving
			wait 5
		}	
	}
}
function OgreMove()
{
	Nav.OgreNavStuck:Set[0]

	variable int HopCounter
	HopCounter:Set[1]

	for (${HopCounter} <= ${Path.Hops} ;HopCounter:Inc)
	{
		;while (${Math.Distance[${Me.ToActor.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision}  && !${Nav.ForceStopped})
		;while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${HopCounter}].CenterPoint}]} && ${Math.Distance[${Me.ToActor.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision} && ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${Math.Calc[${HopCounter}+1]}].CenterPoint}]} && ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${Math.Calc[${HopCounter}+2]}].CenterPoint}]} && !${Nav.ForceStopped})
		while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${HopCounter}].CenterPoint}]} && ${Math.Distance[${Me.ToActor.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision} && !${Nav.ForceStopped})
		{
			if ${Nav.TargetRequired} && !${Target(exists)}
			{
				Debug:Echo["${Time} OgreNav: No Valid Target, stopping movement and script"]
				Nav:Stop[Stuck]
				return
			}
			if ${ConditionsOb.Checks} && !${Nav.Paused}
			{
				face ${Path.Region[${HopCounter}].CenterPoint.X} ${Path.Region[${HopCounter}].CenterPoint.Z}
				Nav:StartMoving
				wait 1
				if ${Nav.Stuck}
					return
			}
			else
			{
				Nav:StopMoving
				wait 5
			}
		}
	}

}
objectdef waypointNavigator
{
	variable string ScriptName
	variable lnavregionref WaypointSet
	variable lnavregionref LastPoint
	variable lnavregionref StartPoint
	variable lnavregionref EndPoint
	variable bool TargetRequired=FALSE
	variable float Precision=3
	variable float OffMapPrecision=3
	variable float DistanceToMoveBackToPath=50
	variable bool ForceStopped=FALSE
	variable bool OgreNavPaused=FALSE
	variable string OgreNavStatus
	;variable string NavFile="${LavishScript.HomeDirectory}/scripts/EQ2Navigation/zones/${Zone}.xml"
	variable string NavFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/zonefiles/${Zone}.xml"

	; Constructor 
	method Initialize(string Name)
	{
		if DEBUG_OGRE_NAV
		{
			if DEBUG_ENABLED
				Debug:Enable
			else
				Debug:Disable
		}
		;WaypointSet:SetRegion[${LavishNav.Tree.AddChild[universe,"WaypointNavigator",-unique]}]
		;WaypointSet:SetRegion[${LavishNav.Tree.AddChild[universe,WaypointNavigator,-unique,-coordinatesystem]}]
		;EQ2OgreHarvestPathThread
		;if ${Script.Filename.NotEqual[EQ2OgreHarvestPathThread]}
		;	WaypointSet:Import[${NavFile}]
		ScriptName:Set[${Script.Filename}]
		OgreMapControllerOb:LoadMap[${Zone}]

		ZoneRegion:SetRegion[${LNavRegion[${Zone.ShortName}]}]
	}
	member:bool Stuck()
	{
		if !${OgreNavTimerOb.TimeLeft}
		{
			if ${Math.Distance[${LastLoc.XYZ},${Me.ToActor.Loc}]} < 2 && !${Me.ToActor.IsRooted} && ${Me.ToActor.CanTurn}
			{
				OgreNavStuck:Inc
				if ${OgreNavStuck}>=2
				{
					Debug:Echo["${Time} ${Script.Filename}: Stuck! Stopping movement."]
					Nav:Stop[Stuck]
					return TRUE
				}
			}
			elseif ${OgreNavStuck}!=0
				OgreNavStuck:Set[0]
			LastLoc:Set[${Me.ToActor.Loc}]
			OgreNavTimerOb:Set[2000]
		}
	}
	method StartMoving()
	{
		if !${Me.IsMoving}
		{
			press AUTORUN
			MovementEnabled:Set[TRUE]
			Nav:Status[Moving]
		}
	}
	method StopMoving()
	{
		if ${MovementEnabled}
		{
			press AUTORUN
			MovementEnabled:Set[FALSE]
			Nav:Status[WaitingToResume]
		}
	}
	method Start(string StatusUpdate=Idle)
	{
		;Allows the bot to move. This method does not actually do the movement. "StartMoving" does.
		ForceStopped:Set[FALSE]
		This:Status[${ReasonForStop}]
	}
	method Stop(string ReasonForStop=Stopped)
	{
		;Disallows the bot to move. This method does not actually do the movement. "StopMoving" does.
		This:StopMoving
		ForceStopped:Set[TRUE]
		LoopBool:Set[FALSE]
		This:Status[${ReasonForStop}]
	}
	method StopRoutineOnlyNotMovement(string ReasonForStop=Stopped)
	{
		;Disallows the bot to move. This method does not actually do the movement. "StopMoving" does.
		;This:StopMoving
		ForceStopped:Set[TRUE]
		LoopBool:Set[FALSE]
		This:Status[${ReasonForStop}]
	}
	method Pause(bool PauseIt)
	{
		This.OgreNavPaused:Set[${PauseIt}]
	}
	member:bool Paused()
	{
		return ${This.OgreNavPaused}
	}
	method Status(string StatusUpdate)
	{
		This.OgreNavStatus:Set[${StatusUpdate}]
	}
	member:string Status()
	{
		return ${This.OgreNavStatus}
	}
	method MoveToRegion(string RegionName)
	{
		DestinationRegion:SetRegion[${RegionName}]
		;Debug:Echo["Dest Region: ${DestinationRegion.CenterPoint}"]
		This:MoveToLoc[${DestinationRegion.CenterPoint}]
		if ${DestinationRegion.CenterPoint.X}==0
			Debug:Echo["RegionName: ${RegionName} - CenterPoint: ${DestinationRegion.CenterPoint}"]
	}
	method MoveToLoc(float x, float y, float z)
	{
		DestPointX:Set[${x}]
		DestPointY:Set[${y}]
		DestPointZ:Set[${z}]
	}
	method Shutdown()
	{
		; Removing our universe will "unload" all of our nav data, including the universe
		;WaypointSet:Remove

		if ${MovementEnabled}
		{
			press AUTORUN
			MovementEnabled:Set[FALSE]
		}
		OgreMapControllerOb:UnLoadMap[${Zone}]
		Debug:Echo["End of OgreNav (Powered by script: ${ScriptName})"]
	}
	method OgrePath(float x,float y, float z)
	{
		Path:Clear
		PathFinder:Reset
		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.ToActor.Loc}].ID}]
		DestinationRegion:SetRegion[${ZoneRegion.BestContainer[${x},${y},${z}].ID}]
		PathFinder:SelectPath[${CurrentRegion.ID},${DestinationRegion.ID},Path]
		if !${Path.Hops} && ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
		{
			Debug:Echo["Destination: ${DestinationRegion.ID} ${DestinationRegion.Name}"]
			Debug:Echo["Current: ${CurrentRegion.ID} ${CurrentRegion.Name}"]
			Debug:Echo["Hops: ${Path.Hops}"]
		}
	}
}
objectdef OgreNavTimerObject
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}

	member:uint TimeLeft()
	{
		if ${Script.RunningTime}>=${EndTime}
			return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}
