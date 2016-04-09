objectdef obj_Missioner
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
		BotCurrentState:Set["Missioner"]
		CurrentAgent:Set[0]
		TheAgents:AcquireAgentList
		TheAgents:DetermineAgent
		TheBookmarks:Acquire
		
		if !(${HomeBookmark(exists)})
		{
			StatusUpdate:Green["Can't Get Home bookmark"]
			StatusUpdate:Red["Can't Get Home bookmark"]
			return
		}
		if ${MyCurrentAgent} < 1
		{
			StatusUpdate:Green["Can't get agent"]
			StatusUpdate:Red["Can't get agent"]
			return
		}
		
		variable bool StillWaiting = TRUE
		do
		{
			switch ${MissionDoWhat}
			{
				case GetMission
					BotCurrentState:Set["Get Mission"]
					call TheAgents.Interact TRUE
					call TheAgents.Accept TRUE
					call TheAgents.Interact FALSE
					MissionDoWhat:Set["WaitForIt"]
					break
				case TurnInMission
					BotCurrentState:Set["Turn In"]
					call TheAgents.Interact TRUE
					call TheAgents.Complete
					call TheAgents.Interact FALSE
					MissionDoWhat:Set["WaitForIt"]
					break
				case GoToMission
					BotCurrentState:Set["Go To Dungeon"]
					TheAgents:GetBookmarks
					call TheAgents.GoTo TRUE
					MissionDoWhat:Set["WaitForIt"]
					break
				case AutoCombat
					BotCurrentState:Set["Lazyboy"]
					TheShip:AcquireModules
					call TheShip.BattleStations
					MissionDoWhat:Set["WaitForIt"]
					break
				case GoHome
					BotCurrentState:Set["Go Home"]
					call TheBookmarks.GoTo ${HomeBookmark}
					MissionDoWhat:Set["WaitForIt"]
					break
				case GoToCourier
					BotCurrentState:Set["Courier"]
					TheAgents:GetBookmarks
					call TheAgents.GoTo FALSE
					MissionDoWhat:Set["WaitForIt"]
					break
				case WaitForIt
					BotCurrentState:Set["Waiting"]
					wait ${Math.Calc[${Slow} / 2]}
					break
			}
		}
		while ${StillWaiting}
	}

	function MainLoop()
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
}