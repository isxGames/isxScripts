objectdef Missioner
{
	variable string Stage = Paused
	
	function Begin()
	{
		while 1
		{
			while ${Stage.Find[Paused]} > 0
				wait RANDOM(SLOW,SLOW)
			switch ${Stage}
			{
				case Echo
					echo Start
					call Mission.GetDetails
					break
				case Ender
					endscript wreckingball2
					break
			
			}
			Stage:Set[Paused]
		
		
		}
	}
	
	
	
	
	
	
	method GetBookmarks()
	{
		variable index:agentmission AcceptedMissions
		variable iterator AcceptedIter
		
		EVE:GetAgentMissions[AcceptedMissions]
		AcceptedMissions:GetIterator[AcceptedIter]
		if ${AcceptedIter:First(exists)}
		do
		{
			if ${AcceptedIter.Value.State} > 1
				AcceptedIter.Value:GetBookmarks[MissionBookmarks]
		}
		while ${AcceptedIter:Next(exists)}
	}
}