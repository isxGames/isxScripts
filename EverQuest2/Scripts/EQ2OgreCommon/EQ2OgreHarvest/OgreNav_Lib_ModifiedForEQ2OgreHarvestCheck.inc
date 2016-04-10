;***Verison 2.00***
/**
OgreNav_Lib_ModifiedForEQ2OgreHarvestCheck
Version 2.00, 10/14/2009 by Kannkor (Hotshot)
Greatly modified to work specifically with EQ2OgreHarvest for checking if nodes are accessible.


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

function:bool DistanceCheck()
{
}

function:bool OgreNav(string Location, float X, float Y, float Z)
{
	LoopBool:Set[TRUE]
	while ${LoopBool}
	{
		LoopBool:Set[FALSE]
		if ${Nav.OgreNavStatus.Equal[Stuck]}
		{
			echo We are "stuck" and it is looping, or calling OgreNav_Lib from ${Script.Filename}.
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
			echo Moving to ${Location}
			Nav:MoveToRegion[${Location}]
		}
		if ${DestPointX}==0 && ${DestPointY}==0 && ${DestPointZ}==0
		{
			InformationOb:DestNotFound
			return
		}
		Nav:OgrePath[${DestPointX},${DestPointY},${DestPointZ}]

		;If the end point is mapped, we need to make sure we end up on a mapped point.
		if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}].CenterPoint}]} < ${Math.Calc[${Nav.Precision}+0]}
		{
			InformationOb:AlreadyThere
			return TRUE
		}
		elseif ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}==${ZoneRegion.ID} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${DestPointX},${DestPointY},${DestPointZ}]} < ${Math.Calc[${Nav.Precision}+0]}
		{
			InformationOb:AlreadyThere
			return TRUE
		}
		elseif ${Path.Hops}
		{
			;echo Start/End points are mapped
			;call OgreMove
			return TRUE
		}
		else
		{
			if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID} && ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
			{
				;Start/End points mapped, but no path (hops) between them.
				;Can we run directly there?
				if !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+1]},${Me.Z},${X},${Math.Calc[${Y}+1]},${Z}]}
				{
					return TRUE
				}
				;Well - We're on a mapped area with no hops and can't move directly there. We're fucked :)
				;InformationOb:DestNotFound
				return FALSE
			}
			;Lets see if the end point is mapped.
			if ${ZoneRegion.BestContainer[${DestPointX},${DestPointY},${DestPointZ}]}!=${ZoneRegion.ID}
			{
				;End point _IS_ mapped
				call CheckMoveOffPath
				if ${Return}
					return TRUE
				else
					return FALSE
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
					return TRUE
					;call OgreMoveToPointOffPath ${X} ${Y} ${Z}
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
							if !${Return}
								return FALSE
							;Should get us back on the path
						}
						;At this stage, we know the end point is off the map, but
						;near a lavishnav point. We also know we are near a 
						;lavishpoint.
						return TRUE
					}
				}
			}
		}
		;echo ${Time}: ${Script.Filename}: Breaking out of OgreNav_lib
		break
	}
}
objectdef InformationObject
{
	method AlreadyThere()
	{
		echo EQ2OH: ${Time}: Already at current point
	}
	method DestNotFound()
	{
		echo EQ2OH: ${Time}: Destination not supplied or found. Where do you want to go?
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
			return TRUE
			;call OgreMoveOffPath ${NextRegion.CenterPoint.X} ${Math.Calc[${NextRegion.CenterPoint.Y}+0.5]} ${NextRegion.CenterPoint.Z}
		}
	}
}
function OgreMoveOffPath(float X, float Y, float Z)
{
	Nav.OgreNavStuck:Set[0]	

;	while (${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
;echo ${Time} OgreMoveOffPath: while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped})
if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.ID}
{
	echo This should NOT BE FUCKING HAPPENING ANYMORE
	echo ${Time}: ${Script.Filename}: Func: OgreMoveOffPath. Called and exited. (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped})
	;call OgreMoveOffPathNoLavishNav ${X} ${Y} ${Z}
}
	;Stop moving once we get back onto the path OR if we are within 2 "meters" of our destination.
	while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > 0.5)
	{
echo While.. while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > 0.5)
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
			wait 10
		}	
	}

	if ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}==${ZoneRegion.ID} && !${Nav.ForceStopped}
		echo Exited Func: OgreMoveOffPath because we got within 2 of our dest, but not on the path.
}
function OgreMoveOffPathNoLavishNav(float X, float Y, float Z)
{
	Nav.OgreNavStuck:Set[0]

if ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} < ${Nav.OffMapPrecision} 
{
echo WTF: ${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} ||| {Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} 


}
	while (${Math.Distance[${Me.ToActor.Loc},${X},${Y},${Z}]} >= ${Nav.OffMapPrecision} && !${Nav.ForceStopped})
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
			wait 10
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
			wait 10
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
		while (${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${HopCounter}].CenterPoint}]} && ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${Math.Calc[${HopCounter}+1]}].CenterPoint}]} && ${ZoneRegion.BestContainer[${Me.ToActor.Loc}]}!=${ZoneRegion.BestContainer[${Path.Region[${Math.Calc[${HopCounter}+2]}].CenterPoint}]} && !${Nav.ForceStopped})
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
			else
			{
				Nav:StopMoving
				wait 10
			}
		}
	}
}
objectdef waypointNavigator
{
	variable lnavregionref WaypointSet
	variable lnavregionref LastPoint
	variable lnavregionref StartPoint
	variable lnavregionref EndPoint
	variable bool TargetRequired=FALSE
	variable float Precision=2.8
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
		;WaypointSet:SetRegion[${LavishNav.Tree.AddChild[universe,"WaypointNavigator",-unique]}]
		;WaypointSet:Import[${NavFile}]
		;ZoneRegion:SetRegion[${LNavRegion[${Zone.ShortName}]}]
		;echo Zone Region inside of OgreNav_Lib_modified: ${ZoneRegion}
		;DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Zone.ShortName}]}]

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
					echo ${Time} ${Script.Filename}: Stuck! Stopping movement.
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
		This:MoveToLoc[${DestinationRegion.CenterPoint}]
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
	}
	method OgrePath(float x,float y, float z)
	{
		Path:Clear
		PathFinder:Reset
		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${Me.ToActor.Loc}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${x},${y},${z}].ID}]
		;DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Y},${Z}].ID}]
		;DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${X},${Math.Calc[${Y}]},${Z}].ID}]
		;PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},Path]
		PathFinder:SelectPath[${CurrentRegion.ID},${DestinationRegion.ID},Path]
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
function atexit()
{
	;LavishNav[WaypointNavigator]:Remove
	;LNavRegion[WaypointNavigator]:Remove
	OgreMapControllerOb:UnLoadMap[${Zone}]
	echo End of OgreNav (Powered by script: ${Script.Filename})
}
