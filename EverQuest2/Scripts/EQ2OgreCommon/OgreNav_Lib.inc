;***Verison 2.05***
/**
Version 2.05 11/07/2011 by Kannkor
Large update.
Added additional checks for naving some, then moving off the target.
Updated OgreMove to accept 1 bool parameter that tells it to allow PrecisionToDistance, defaulted to yes.
Added a lot of debug echoing (most should be removed).

Version 2.04 10/27/2011 by Kannkor
Added zoning logic. When you zone, it should now unload the old zone map and load the new zone map.

Version 2.03 09/24/2011 by Kannkor
Minor changes to how it determines if it's stuck. Increased the count from 2 to 3.
added Nav:Reset to clear some variables. When doing a :Start it now calls :Reset

Version 2.02 05/12/2010 by Kannkor
Fixed a variable that allows Nav.ForceStopped
Added minor logic to OgreMove that goes along with Nav:Stop while it's pathing.

Version 2.01, 02/23/2010 by Kannkor (Hotshot)
Cleaned up a bit

Version 2.00, 10/14/2009 by Kannkor (Hotshot)
Minor re-write to work smoother with OgreNavCreator

Version 1.00, 09/30/2009 by Kannkor (Hotshot)
Initial release. If any changes are made please update the version, and provide well documentation on what was changed.

**/

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
#define AUTORUN "num lock"
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

	;// echo ${Time}: Entering OgreNav with Loc: ${Location} ${X},${Y},${Z}
	LoopBool:Set[TRUE]
	while ${LoopBool} && !${Nav.ForceStopped}
	{
		LoopBool:Set[FALSE]
		if ${Nav.OgreNavStatus.Equal[Stuck]}
		{
			echo We are stuck and it is looping, or calling OgreNav_Lib from ${Script.Filename}.
			return
		}

		;// ***Scripts - Below can be declared and modified with objects in your move scripts***
		if !${Nav(exists)}
			declarevariable Nav waypointNavigator script
		if !${ConditionsOb(exists)}
			declarevariable ConditionsOb ConditionsObject script
		if !${InformationOb(exists)}
			declarevariable InformationOb InformationObject script

		Nav.OgreNavStuck:Set[0]

		;// ***Nothing below should be changed***		

		if ${Location.Equal[Loc]}
		{
			Nav:MoveToLoc[${X},${Y},${Z}]
		}
		else
		{
			if !${Nav.RegionExists[${Location}]}
			{
				InformationOb:DestNotFound
				return
			}
			echo Moving to ${Location}
			Nav:MoveToRegion["${Location}"]
		}
		if ${DestPointX}==0 && ${DestPointY}==0 && ${DestPointZ}==0
		{
			echo If this is spamming repeatedly, please bug report this with as much information as possible. Spam reason: Dest not found XYZ=000
			echo Loc: ${Location} - x:${DestPointX} - y:${DestPointY} - z:${DestPointZ}
			wait 50
			InformationOb:DestNotFound
			return
		}
		Nav:OgrePath[${DestPointX},${DestPointY},${DestPointZ}]

		;// If the end point is mapped, we need to make sure we end up on a mapped point.
		if ${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}].CenterPoint}]} < ${Math.Calc[${Nav.Precision}+0]}
		{
			InformationOb:AlreadyThere
		}
		elseif ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}==${ZoneRegion.ID} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${DestPointX},${DestPointY},${DestPointZ}]} < ${Math.Calc[${Nav.Precision}+0]}
		{
			InformationOb:AlreadyThere
		}
		elseif ${Path.Hops}
		{
			;// echo Start/End points are mapped
			call OgreMove
		}
		else
		{
			if ${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
			{
				;// Start/End points mapped, but no path (hops) between them.
				;// Can we run directly there?
				if !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+1]},${Me.Z},${X},${Math.Calc[${Y}+1]},${Z}]}
				{
					call OgreMoveToPointOffPath ${X} ${Y} ${Z}
				}
				echo We're on a mapped area with no hops and can't move directly there. We're screwed :)
				Nav:Stop[Stuck]
				InformationOb:DestNotFound
				return
			}
			;// Lets see if the end point is mapped.
			if ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
			{
				;// End point _IS_ mapped
				call CheckMoveOffPath
				LoopBool:Set[TRUE]
				echo We should be back on the path, looping it..
				continue
			}
			else
			{
				
				/*
				;End point is _OFF_ the mappead area.
				;We have the closest mapped spot to the area we want to move too above
				;Check if the end spot and closest spot have collision
				;if not - lavishnav as far as we can, then raw move
				;Otherwise - no path available
				;Can we run directly there?
				*/
				if ${Nav.AllowOffMapMovement} && ( !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+1]},${Me.Z},${X},${Math.Calc[${Y}+1]},${Z}]} || ${Nav.IgnoreCollisionOnDirectMovement} )
				{
					;// echo call OgreMoveToPointOffPath ${X} ${Y} ${Z}
					call OgreMoveToPointOffPath ${X} ${Y} ${Z}
				}
				else
				{
					;// Okay we can't run directly there.
					;// Lets start backwards. Is the spot collision free to the nearest lavishnav point?
					
					NextRegion:SetRegion[${ZoneRegion.NearestChild[${DestPointX},${DestPointY},${DestPointZ}]}]
					NearestRegionDistance:Set[${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${NextRegion.CenterPoint}]}]
					;// Keep in mind, things will prevent rendering causing a false negative. Such as being behind two walls.
					if !${EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${NextRegion.CenterPoint}]} || ${NearestRegionDistance} < ${Nav.PrecisionToDestination}
					{
						;// Endspot <- lavishnav <-
						;// Lets try to lavishnav to the point.
						Nav:MoveToLoc[${NextRegion.CenterPoint}]
						Nav:OgrePath[${NextRegion.CenterPoint}]
						if !${Path.Hops}
						{
							;// No hops means we're not on the path
							call CheckMoveOffPath
							;// Should get us back on the path
						}
						NextRegion:SetRegion[${ZoneRegion.NearestChild[${DestPointX},${DestPointY},${DestPointZ}]}]
						NearestRegionDistance:Set[${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${NextRegion.CenterPoint}]}]
						Nav:MoveToLoc[${NextRegion.CenterPoint}]
						Nav:OgrePath[${DestPointX},${DestPointY},${DestPointZ}]

						if ${Path.Hops}
						{
							;// False says to not allow PrecisionToDestination
							call OgreMove FALSE
						
							;// Should get us to the end of lavishpoint
							;// Finish it off with a direct move.
							;// call OgreMoveOffPath ${X} ${Y} ${Z}

							;// Reset our Nav to the original spot.
							Nav:MoveToLoc[${X},${Y},${Z}]
							;// Do a quick check to see if we're already within our distance.
							;// echo if ${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} < ${Nav.PrecisionToDestination} ** if {Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} < ${Nav.PrecisionToDestination} ** !${EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} ** !{EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]}
							if ${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} < ${Nav.PrecisionToDestination}
							{
								echo Simply means we're within our destination! yay ${Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} < ${Nav.PrecisionToDestination} ( {Math.Distance[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} < ${Nav.PrecisionToDestination} ) xyz ref. ( ${X} ${Y} ${Z} )
								;// Simply means we're within our destination! yay
							}
							elseif !${EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]}
								call OgreMoveToPointOffPath ${X} ${Y} ${Z}
							else
							{
								echo ${Time}: OgreNavLib: At the end of our nav, and we are now reporting collision so we cannot continue. ( ${EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} ** {EQ2.CheckCollision[${DestPointX},${DestPointY},${DestPointZ},${Me.Loc}]} for reference xyz: ${X} ${Y} ${Z} )
							}
						}
						else
							echo Start/End points NOT mapped, tried to move onto the path and it's saying no hops..
					}
				}
			}
		}
		Nav:StopMoving
		break
	}
}
objectdef InformationObject
{
	method AlreadyThere()
	{
		echo EQ2OgreNav: ${Time}: Already at current point
	}
	method DestNotFound()
	{
		echo EQ2OgreNav: ${Time}: Destination not supplied or found. Where do you want to go?
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
	NextRegion:SetRegion[${ZoneRegion.NearestChild[${Me.Loc}]}]
	NearestRegionDistance:Set[${Math.Distance[${Me.Loc},${NextRegion.CenterPoint}]}]

	if ${NearestRegionDistance} <= ${Nav.DistanceToMoveBackToPath}
	{
		if !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+0.5]},${Me.Z},${NextRegion.CenterPoint.X},${Math.Calc[${NextRegion.CenterPoint.Y}+0.5]},${NextRegion.CenterPoint.Z}]}
		{
			call OgreMoveOffPath ${NextRegion.CenterPoint.X} ${Math.Calc[${NextRegion.CenterPoint.Y}+0.5]} ${NextRegion.CenterPoint.Z}
		}
		else
		{
			echo Off the mapped area and collision detected to the nearest mapped point - Can't run there.
			Nav:Stop[Stuck]
			return FALSE
		}
	}
	else
		echo Nearest point on path is located: ${NearestRegionDistance} away. This is further than we can run ( ${Nav.DistanceToMoveBackToPath} )..
}
function OgreMoveOffPath(float X, float Y, float Z)
{
	Nav.OgreNavStuck:Set[0]	

	;//	while (${Math.Distance[${Me.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
	;// echo ${Time} OgreMoveOffPath: while (${ZoneRegion.BestContainer[${Me.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped})
	if ${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.ID}
	{
		echo ${Time}: ${Script.Filename}: Func: OgreMoveOffPath. Called and exited. (${ZoneRegion.BestContainer[${Me.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped})
		InformationOb:AlreadyThere
		LoopBool:Set[FALSE]
		Nav:Stop
		return
		;// call OgreMoveOffPathNoLavishNav ${X} ${Y} ${Z}
	}
	;// Stop moving once we get back onto the path OR if we are within 2 "meters" of our destination.
	while (${ZoneRegion.BestContainer[${Me.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > 1)
	{
		if ${Nav.TargetRequired} && !${Target(exists)}
		{
			echo ${Time} OgreNav: No Valid Target, stopping movement and script
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

	if ${ZoneRegion.BestContainer[${Me.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped}
		echo Exited Func: OgreMoveOffPath because we got within 2 of our dest, but not on the path.
}
function OgreMoveOffPathNoLavishNav(float X, float Y, float Z)
{
	Nav.OgreNavStuck:Set[0]
	while (${Math.Distance[${Me.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
	{
		if ${Nav.TargetRequired} && !${Target(exists)}
		{
			echo ${Time} OgreNav: No Valid Target, stopping movement and script
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

	while (${Math.Distance[${Me.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
	{
		if ${Nav.TargetRequired} && !${Target(exists)}
		{
			echo ${Time} OgreNav: No Valid Target, stopping movement and script
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
function OgreMove(bool AllowPrecisionToDestination=TRUE)
{
	Nav.OgreNavStuck:Set[0]

	variable int HopCounter
	;// echo Center point: ${Path.Region[${Path.Hops}].CenterPoint} *  ${Nav.PrecisionToDestination} * ${Nav.Precision}
	for (HopCounter:Set[1] ; ${HopCounter} <= ${Path.Hops} ; HopCounter:Inc)
	{
		;// echo while (${Math.Distance[${Me.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision}  && !${Nav.ForceStopped})
		;// echo while (${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${HopCounter}].CenterPoint}]} && ${Math.Distance[${Me.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision} && ${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${Math.Calc[${HopCounter}+1]}].CenterPoint}]} && ${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${Math.Calc[${HopCounter}+2]}].CenterPoint}]} && !${Nav.ForceStopped})
		/*
			Scenarios for the while
			If Allow PrecisionToDestination:
				Check if our distance to end point. If it's greater, while continues. If it's less, while stops.
				If we're on the last hop, ignore Precision, and base it off of PrecisionToDestination
				If we're not on the last hope, use Precision
			if allow PrecisionToDestination is FALSE
				Ignore all PrecisionToDestination and use Precision

		*/
		while ( \
			${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${HopCounter}].CenterPoint}]} && !${Nav.ForceStopped} && \
			( \
			( ${AllowPrecisionToDestination} && ${HopCounter} != ${Path.Hops} && ${Math.Distance[${Me.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision} \
			&& ${Math.Distance[${Me.Loc},${Path.Region[${Path.Hops}].CenterPoint}]} > ${Nav.PrecisionToDestination} ) \
			|| \
			( ${AllowPrecisionToDestination} && ${HopCounter} == ${Path.Hops} && ${Math.Distance[${Me.Loc},${Path.Region[${Path.Hops}].CenterPoint}]} > ${Nav.PrecisionToDestination} ) \
			|| \
			( !${AllowPrecisionToDestination} && ${Math.Distance[${Me.Loc},${Path.Region[${HopCounter}].CenterPoint}]} > ${Nav.Precision} ) \
			) \
			)
		{
			if ${Nav.TargetRequired} && !${Target(exists)}
			{
				echo ${Time} OgreNav: No Valid Target, stopping movement and script
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
			elseif ${Nav.ForceStopped}
			{
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
atom EQ2_StartedZoning()
{
	;// echo ${Time}: EQ2_StartedZoning: ${Zone}
	;// Should probably :Stop or something
	Nav:Stop[Zoning]
	OgreMapControllerOb:UnLoadMap[${Nav.CurrentZone}]
}
atom EQ2_FinishedZoning(string TimeInSeconds)
{
	;// echo ${Time}: EQ2_FinishedZoning: ${Zone} - ${TimeInSeconds}
	Nav:UpdateZoneFile
	Nav:Reset
}
objectdef waypointNavigator
{
	variable lnavregionref WaypointSet
	variable lnavregionref LastPoint
	variable lnavregionref StartPoint
	variable lnavregionref EndPoint
	variable bool TargetRequired=FALSE
	variable float Precision=3
	variable float PrecisionToDestination=3
	variable float OffMapPrecision=3
	variable float DistanceToMoveBackToPath=50
	variable bool ForceStopped=FALSE
	variable bool OgreNavPaused=FALSE
	variable bool IgnoreCollisionOnDirectMovement=FALSE
	variable string OgreNavStatus
	variable string CurrentZone
	variable string NavFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/zonefiles/${Zone}.xml"
	variable string CallingScriptName
	variable bool AllowOffMapMovement=TRUE
	;// Constructor 
	method Initialize(string Name)
	{
		;// WaypointSet:SetRegion[${LavishNav.Tree.AddChild[universe,"WaypointNavigator",-unique]}]
		;// WaypointSet:SetRegion[${LavishNav.Tree.AddChild[universe,WaypointNavigator,-unique,-coordinatesystem]}]
		
		;// OgreMapControllerOb:LoadMap[${Zone}]
		;// ZoneRegion:SetRegion[${LNavRegion[${Zone.ShortName}]}]
		CallingScriptName:Set[${Script.Filename}]
		Event[EQ2_StartedZoning]:AttachAtom[EQ2_StartedZoning]
		Event[EQ2_FinishedZoning]:AttachAtom[EQ2_FinishedZoning]
		This:UpdateZoneFile
	}
	method UpdateZoneFile()
	{
		This.CurrentZone:Set[${Zone}]
		
		OgreMapControllerOb:LoadMap[${Zone}]
		ZoneRegion:SetRegion[${LNavRegion[${Zone.ShortName}]}]
	}
	member:bool Stuck()
	{
		if !${OgreNavTimerOb.TimeLeft}
		{
			if ${Math.Distance[${LastLoc.XYZ},${Me.Loc}]} < 2 && !${Me.IsRooted} && ${Me.CanTurn}
			{
				OgreNavStuck:Inc
				if ${OgreNavStuck}>=3
				{
					echo ${Time} ${Script.Filename}: Stuck! Stopping movement.
					Nav:Stop[Stuck]
					return TRUE
				}
			}
			elseif ${OgreNavStuck}!=0
				OgreNavStuck:Set[0]
			LastLoc:Set[${Me.Loc}]
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
	method Reset()
	{
		Nav:Status[Idle]
		ForceStopped:Set[FALSE]
		OgreNavStuck:Set[0]
		LastLoc:Set[0,0,0]
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
		;// Allows the bot to move. This method does not actually do the movement. "StartMoving" does.
		This:Reset
		This:Status[${StatusUpdate}]
	}
	method Stop(string ReasonForStop=Stopped)
	{
		;// Disallows the bot to move. This method does not actually do the movement. "StopMoving" does.
		This:StopMoving
		ForceStopped:Set[TRUE]
		LoopBool:Set[FALSE]
		This:Status[${ReasonForStop}]
	}
	method StopRoutineOnlyNotMovement(string ReasonForStop=Stopped)
	{
		;// Disallows the bot to move. This method does not actually do the movement. "StopMoving" does.
		;// This:StopMoving
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
		if !${This.RegionExists[${RegionName}]}
		{
			echo ${Time}: OgreNavLib: Region: ${RegionName} doesn't exist.
			return
		}
		DestinationRegion:SetRegion[${RegionName}]
		;// echo Dest Region: ${DestinationRegion.CenterPoint}
		This:MoveToLoc[${DestinationRegion.CenterPoint}]
		if ${DestinationRegion.CenterPoint.X}==0
			echo RegionName: ${RegionName} - CenterPoint: ${DestinationRegion.CenterPoint}
	}
	member:bool RegionExists(string RegionName)
	{
		return ${ZoneRegion.FindRegion[${RegionName}](exists)}
	}
	member:bool LocMapped(float _X, float _Y, float _Z)
	{
		if ${ZoneRegion.BestContainer[${_X},${_Y},${_Z}]} == ${ZoneRegion.ID}
			return FALSE
		else
			return TRUE
	}
	method List()
	{
		variable lnavregionref NavRef
		;// NavRef:SetRegion[${LavishNav.FindRegion[${Zone}].Children}]
		NavRef:SetRegion[${ZoneRegion.Children}]
		while ${NavRef.Region(exists)}
		{
			if ${NavRef.Unique}
			{
				echo ${NavRef.Name}
				;// echo Name: ${NavRef.Name}
			}
			NavRef:SetRegion[${NavRef.Next}]
		}
	}
	method MoveToLoc(float x, float y, float z)
	{
		DestPointX:Set[${x}]
		DestPointY:Set[${y}]
		DestPointZ:Set[${z}]
		;// echo MoveToLoc xyz: ${x} ${y} ${z}
		;// echo MoveToLoc Des: ${DestPointX} ${DestPointY} ${DestPointZ}
	}
	/*
	method Shutdown()
	{
		;// Removing our universe will "unload" all of our nav data, including the universe
		;// WaypointSet:Remove
	}
	*/
	method OgrePath(float x,float y, float z)
	{
		Path:Clear
		PathFinder:Reset
		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.Loc}].ID}]
		DestinationRegion:SetRegion[${ZoneRegion.BestContainer[${x},${y},${z}].ID}]
		PathFinder:SelectPath[${CurrentRegion.ID},${DestinationRegion.ID},Path]
		if !${Path.Hops} && ${ZoneRegion.BestContainer[${Me.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
		{
			echo Destination: ${DestinationRegion.ID} ${DestinationRegion.Name}
			echo Current: ${CurrentRegion.ID} ${CurrentRegion.Name}
			echo Hops: ${Path.Hops}
		}
	}
	/*
	;// Fires after script ends, so doesn't work.
	method Shutdown()
	{
		if ${MovementEnabled}
		{
			press AUTORUN
			MovementEnabled:Set[FALSE]
		}
		;// Below would need to be able to support a calling script name as a parameter. ${CallingScriptName}
		OgreMapControllerOb:UnLoadMap[${Zone}]
		echo End of OgreNav (Powered by script: ${Script.Filename}) --> CallingScriptName
	}
	*/
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

function atexit()
{
	if ${MovementEnabled}
	{
		press AUTORUN
		MovementEnabled:Set[FALSE]
	}

	OgreMapControllerOb:UnLoadMap[${Zone}]
	echo End of OgreNav (Powered by script: ${Script.Filename})
}
