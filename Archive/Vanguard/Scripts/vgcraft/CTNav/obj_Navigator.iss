/*
	Navigator class
	
	Main object for interacting with the navigation and mapping routines.  Declared globaal.
	
	-- CyberTech (cybertech@gmail.com)
	
*/

objectdef obj_Navigator
{
	variable float navVersion = 0.75

	variable obj_FaceClass FaceClass
	variable obj_AutoMapper AutoMapper

	variable bool Running = TRUE
	variable bool LogToFile = TRUE
	variable filepath CTNavConfigFile = "${Script.CurrentDirectory}/CTNavigator.xml"


	/* Collision-Related */
	variable string Collision_LastActorName = ""
	variable int64 Collision_LastPawnID = 0
	
	/* Moving */
	variable bool Moving = FALSE
	variable bool StopAtDestination = TRUE
	variable int StopDistance = 300
	variable point3f LocationLastFrame
	
	/* PathFinding */
	variable point3f FinalDestination
	variable point3f CurrentDestination
	variable int CurrentHopIndex
	variable lnavpath Path
	variable dijkstrapathfinder PathFinder

	method Initialize()
	{
		;if !${UIElement[CTNavigator](exists)}
		;{
		;	UI -load "${Script.CurrentDirectory}/CTNavigator-UI.xml"
		;}
		Event[VG_onHitObstacle]:AttachAtom[This.Event_onHitObstacle]
		Event[VG_onTouchPawn]:AttachAtom[This.Event_onTouchPawn]
		Event[OnFrame]:AttachAtom[This:Move]
		Event[OnFrame]:AttachAtom[This:FollowPath]
		This.Running:Set[TRUE]
	}

	method Shutdown()
	{
		This:Echo["Shutting Down"]

		;ui -unload "${Script.CurrentDirectory}/CTNavigator-UI.xml"
		This.Running:Set[FALSE]
		Game_StopMoving()
		Event[VG_onHitObstacle]:DetachAtom[This.Event_onHitObstacle]
		Event[VG_onTouchPawn]:DetachAtom[This.Event_onTouchPawn]
		Event[OnFrame]:DetachAtom[This:Move]
		Event[OnFrame]:DetachAtom[This:FollowPath]
	}

	method Pause()
	{
		This.Running:Set[FALSE]
	}
	
	method Resume()
	{
		This.Running:Set[TRUE]
	}
	
	method Reset()
	{
		FaceClass:Reset
		This.Path:Clear
		This.Moving:Set[FALSE]
		Game_StopMoving()
	}
	
	; Calculates the next hop region, randomizing the target vector around the center.
	method CalcNextHop()
	{
		variable point3f DestinationPoint
		DeclareVariable X float local ${This.CurrentHop.CenterPoint.X}
		DeclareVariable Y float local ${This.CurrentHop.CenterPoint.Y}
		DeclareVariable Z float local ${This.CurrentHop.CenterPoint.Z}

;Navigate to the Region[NextHop].NearestPoint[Me.Location] in a path
;Then find the next region and navigate to NearestPoint[Me.Location] of that region

; This function never seems to get called...

		if ${This.CurrentPage.Hops} == 0
		{	
			; We don't have a path, so just move directly to the target vector if possible.
			This.CurrentDestination:Set[${This.FinalDestination}]
		}
		else
		{
			do
			{
				if ${Math.Rand[2]}
				{
					X:Set[${Math.Calc[${X} + ${Math.Rand[250]:Inc[25]}]}]
				}
				else
				{
					X:Set[${Math.Calc[${X} - ${Math.Rand[250]:Inc[25]}]}]
				}
				if ${Math.Rand[2]}
				{
					Y:Set[${Math.Calc[${Y} + ${Math.Rand[250]:Inc[25]}]}]
				}
				else
				{
					Y:Set[${Math.Calc[${Y} - ${Math.Rand[250]:Inc[25]}]}]
				}
			}
			while !${This.CurrentHop.Contains[${X},${Y}]}
; the above line had () instead of [] but it never get's called anyway!
; Does the below look right?
			DestinationPoint:Set[${X},${Y},${Z}]
			This.CurrentDestination:Set[${DestinationPoint}]
			DebugTrace("CalcNextHop:CurrDest: ${This.CurrentDestination}")
		}
	}

	member:lnavregion CurrentHop()
	{
		return ${This.Path.Region[${This.CurrentHopIndex}]}
	}
	
	member:lnavregionref NearestRegion(float X, float Y, float Z)
	{
		return ${This.AutoMapper.CurrentZone.NearestChild[${X},${Y},${Z}].ID}
	}

	member:bool NavigateToPawnID(int64 PawnID)
	{
		DebugTrace("NavigateToPawnID(int64 ${PawnID})")
		if !${Pawn[id,${PawnID}](exists)}
		{
			DebugPrint("NavigateToPawnID(int64): Pawn Missing")
			return FALSE
		}
		This.FinalDestination:Set[${Pawn[id,${PawnID}].Location}]
		return ${This.NavigateToFinalDestination}
	}

	member:bool NavigateToFinalDestination()
	{
		DebugTrace("NavigateToFinalDestination() (${This.FinalDestination})")
		variable lnavregionref DestinationRegion
		DestinationRegion:SetRegion[${This.AutoMapper.BestorNearestContainer[${This.FinalDestination}]}]

		return ${This.NavigateFromRegionToRegion[${This.AutoMapper.CurrentRegion},${DestinationRegion}]}
	}

	member:bool NavigateFromPointToPoint(float OriginX, float OriginY, float OriginZ, float DestinationX, float DestinationY, float DestinationZ)
	{
		variable point3f Origin
		Origin:Set[${OriginX},${OriginY},${OriginZ}]

		variable point3f Destination
		Destination:Set[${DestinationX},${DestinationY},${DestinationZ}]
		This.FinalDestination:Set[${Destination}]
				
		DebugTrace("NavigateFromPointToPoint(point3f ${Origin}, point3f ${Destination})")
		variable lnavregionref OriginRegion
		variable lnavregionref DestinationRegion

		OriginRegion:SetRegion[${This.AutoMapper.BestorNearestContainer[${Origin}]}]
		DestinationRegion:SetRegion[${This.AutoMapper.BestorNearestContainer[${Destination}]}]

		return ${This.NavigateFromRegionToRegion[${OriginRegion},${DestinationRegion}]}
	}
	
	member:bool NavigateToRegion(lnavregionref DestinationRegion)
	{
		DebugTrace("NavigateToRegion(lnavregionref ${DestinationRegion})")
		return ${This.NavigateFromRegionToRegion[${This.AutoMapper.CurrentRegion.ID},${DestinationRegion.ID}]}
	}

	; Main Navigate -- most Navigate*s all call this one eventually.
	member:bool NavigateFromRegionToRegion(lnavregionref OriginRegion, lnavregionref DestinationRegion)
	{
		DebugTrace("NavigateFromRegionToRegion(lnavregionref ${OriginRegion}, lnavregionref ${DestinationRegion})")
		This.CurrentHopIndex:Set[1]
		This.Path:Clear

		if ${OriginRegion.ID} == ${DestinationRegion.ID}
		{
			Navigator:EchoHud("Navigator:NavigateFromRegionToRegion: Already at destination region")
			return TRUE
		}
		if ${DestinationRegion(exists)} && ${OriginRegion(exists)}
		{
			PathFinder:SelectPath[${OriginRegion.ID},${DestinationRegion.ID},This.Path]

			DebugPrint("Navigator:NavigateFromRegionToRegion: ${This.Path.Hops} hops ${OriginRegion.Name} -> ${DestinationRegion.Name}")
			if (${This.Path.Hops} > 0)
			{
				This.Moving:Set[TRUE]
				return TRUE
			}		
		}
		else
		{
			DebugPrint("Navigator:NavigateFromRegionToRegion: 1 or more regions were invalid")
		}
		return FALSE
	}

	member:bool Arrived()
	{
		if ${Math.Distance[${Me.Location},${This.CurrentDestination}]} <= ${This.StopDistance}
		{
			return TRUE
		}
		return FALSE
	}
	
	member:bool ArrivedFinalDest()
	{
		if ${Math.Distance[${Me.Location},${This.FinalDestination}]} <= ${This.StopDistance}
		{
			return TRUE
		}
		return FALSE
	}
	
/* Movement-Related Members/Methods */

	method FollowPath()
	{
		if (${This.Path.Hops} == 0) || !${This.Moving} || !${This.Running}
		{
			return
		}

		/*
			Call Navigate each time we are not at the target, in case the user 
			(or other.. environment, mob, etc) has moved us.  This may case
			high load, if so we will do it without it.  There is a side effect
			in that we will always be going to the 1st hope of the set.
		*/
		This:NavigateToFinalDestination
		This:CalcNextHop
		This.StopAtDestination:Set[TRUE]
		FaceClass:FacePoint[${This.CurrentDestination.X}, ${This.CurrentDestination.Y}]
	}
	
	; If you're currently in an unmapped region, call this to move to the nearest mapped region.
	member MoveToNearestRegion(float X, float Y, float Z)
	{
		declarevariable destregion lnavregionref local ${This.NearestRegion[${X}, ${Y}, ${Z}]}
		This:MoveToPoint[${destregion.CenterPoint}]
	}

	; This function moves you to within StopDistance meters of the specified X Y loc
	method MoveToPoint(float X, float Y, float Z=0, bool StopAtDestination=TRUE, StopDistance=300)
	{
		This.CurrentDestination.X:Set[${X}]
		This.CurrentDestination.Y:Set[${Y}]
		This.CurrentDestination.Z:Set[${Z}]
		This.StopAtDestination:Set[${StopAtDestination}]
		
		if ${StopDistance} < 100
		{
			;This is specified in loc-units, not meters
			StopDistance:Set[${Math.Calc[${StopDistance} * 100]}]
		}

		This.StopDistance:Set[${StopDistance}]
		FaceClass:FacePoint[${This.CurrentDestination.X}, ${This.CurrentDestination.Y}]
		This.Moving:Set[TRUE]
	}
	
	; Designed to be an atom, called onFrame
	method Move()
	{
		if !${Moving} || !${Running}
		{
			return
		}

		This.LocationLastFrame:Set["${Me.Location}"]	
	
		if ${This.ArrivedFinalDest}
		{
			This.Moving:Set[FALSE]
			DebugPrint("We have arrived, don't forget to use the potty.")
			if ${This.StopAtDestination}
			{
				Game_StopMoving()
			}
			FaceClass:FacePoint[${This.FinalDestination.X}, ${This.FinalDestination.Y}]
			return
		}

		if ${This.Arrived}
		{
			DebugPrint("This.Arrived=TRUE")
			This.Moving:Set[FALSE]
			return
		}
				
		if ${FaceClass.AngleDiff} > 20
		{
			;If we're not heading within 30 degrees of the target, dont move yet.
			Game_StopMoving()
			return
		}
			
		;press and hold the forward button
		Game_MoveForward()
		if ${Math.Distance[${Me.Location},${This.LocationLastFrame}]} < 1
		{
			DebugPrint("Navigator:Move: Stuck?")
		}
	}

	method Stop()
	{
		Game_StopMoving()
	}

	method NoEcho(string StatusMessage)
	{
	}

	method Echo(string StatusMessage)
	{
		;echo "CTNavigator (${Time}): ${StatusMessage}"
		if ${This.LogToFile}
		{
			redirect -append "${Script.CurrentDirectory}/NavigatorLog.txt" echo "${Time}: ${StatusMessage}"
		}
	}

	method EchoHUD(string StatusMessage)
	{
		if !${UIElement[CTNavigator](exists)}
		{
			;echo "CTNavigator (${Time}): ${StatusMessage}"
		}
		else
		{
			UIElement[Console@Main@Tabs@CTNavigator]:Echo["${Time}: ${StatusMessage}"]
		}
		if ${This.LogToFile}
		{
			redirect -append "${Script.CurrentDirectory}/NavigatorLog.txt" echo "${Time}: ${StatusMessage}"
		}
	}		

	method Event_onHitObstacle(string ActorName)
	{
		DebugPrint("Navigator:Navigator_onHitObstacle: ${ActorName}")
		This.Collision_LastActorName:Set[ActorName]
	}

	method Event_onTouchPawn(string PawnName, int PawnID)
	{
		DebugPrint("Navigator:Navigator_onTouchPawn: ${Pawn[${PawnID}].Name}")
		This.Collision_LastPawnID:Set[PawnID]
	}
}
