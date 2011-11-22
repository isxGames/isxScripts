objectdef Missioner
{
	
	
	function Begin()
	{
	
	}
	
	
	
	
	
	
	method GetBookmarks()
	{
		variable index:agentmission AcceptedMissions
		variable iterator AcceptedIter
		
		EVE:DoGetAgentMissions[AcceptedMissions]
		AcceptedMissions:GetIterator[AcceptedIter]
		if ${AcceptedIter:First(exists)}
		do
		{
			if ${AcceptedIter.Value.State} > 1
				AcceptedIter.Value:DoGetBookmarks[MissionBookmarks]
		}
		while ${AcceptedIter:Next(exists)}
	}
}