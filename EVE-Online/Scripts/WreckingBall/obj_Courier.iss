objectdef obj_Courier
{
	variable bool StillMissioning = TRUE
	variable string CourierStage
	variable bool OnMission = FALSE
	
	method Initialize()
	{
	
	}
	
	method Shutdown()
	{
	
	}
	
	function Begin()
	{
		CurrentAgent:Set[0]
		TheAgents:AcquireAgentList
		TheAgents:DetermineAgent
		TheBookmarks:Acquire
		
		if !(${HomeBookmark(exists)})
		{
			echo "must have home bookmark, ending"
			;return
		}
		if ${MyCurrentAgent} < 1
		{
			echo "problem getting currentagent"
			;return
		}
		;if ${Me.InStation}
		;{
		;	if ${Me.StationID} == ${Agent[${MyCurrentAgent}].StationID}
		;	{
				CourierStage:Set[Docked]
		;	}
		;	else
		;	{
		;		CourierStage:Set[GoHome]
		;	}
		;}
		;else
		;{
		;	CourierStage:Set[GoHome]
		;}
		
		echo ${CourierStage}
		do
		{
			switch ${CourierStage}
			{
				case GoHome
					call This.GoHome
					break
				case Docked
					call This.Docked
					break
				case GoTo
					call This.GoTo
					break
				default
					echo "I dunno what happened"
					return
			}
			echo ${CourierStage}
		}
		while ${StillMissioning}
	}

	function GoHome()
	{
		call TheBookmarks.GoTo[${HomeBookmark}]
		CourierStage:Set[Docked]
	}

	function Docked()
	{
		
		
		echo -----------------------------------------------
		StatusUpdate:Green["2-Interact TRUE"]
		;call TheAgents.Interact TRUE
		StatusUpdate:Green["3-Get Details"]
		;;;;;;;;call TheAgents.GetDetails
		StatusUpdate:Green["4-Accept TRUE"]
		;call TheAgents.Accept TRUE
		StatusUpdate:Green["5-Interact FALSE"]
		;call TheAgents.Interact FALSE
		StatusUpdate:Green["6-Agent GetBookmarks"]
		;TheAgents:GetBookmarks
		StatusUpdate:Green["7-Agent GoTo"]
		;call TheAgents.GoTo
		StatusUpdate:Green["7-Acquire Modules"]
		TheShip:AcquireModules
		StatusUpdate:Green["8-BattleStations"]
		call TheShip.BattleStations
		StatusUpdate:Green["9-Bookmarks Acquire"]
		;TheBookmarks:Acquire
		StatusUpdate:Green["10-Bookmarks Home"]
		;call TheBookmarks.GoTo ${HomeBookmark}
		StatusUpdate:Green["11-Done"]
		
		echo -----------------------------------------------
		StillMissioning:Set[FALSE]
	}
	
	function SuperDocked()
	{
		if !(${OnMission})
		{
			do
			{
				TheAgents:DetermineAgent
				call TheAgents.Interact
				wait ${Math.Calc[${Slow} * 2]}
				if ${TheAgents.MissionType.Find[Courier]} > 0
				{
					call TheAgents.Accept TRUE
					OnMission:Set[TRUE]
				}
				else
				{
					if ${TheAgents.CanDecline}
					{
						call TheAgents.Accept FALSE
						wait ${Math.Calc[${Slow} * 2]}
					}
				}
			}
			while !(${OnMision})
		}
		else
		{
		
		}
		
	
	}

	function GoTo()
	{
		
		
		
	}
}