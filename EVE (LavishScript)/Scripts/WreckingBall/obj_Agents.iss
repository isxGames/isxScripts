variable(script) index:string MyAgentNames
variable(script) index:string MyAgentIndexes
variable(script) index:agentmission MyMission
variable(script) int MyCurrentAgent
variable(script) settingsetref AgentConfig
variable(script) index:bookmark MissionBookmarks

objectdef obj_Agents
{
	;variable index:agent ObjAgentList
	variable string ObjAgentList

	method Initialize()
	{
		
		ObjAgentList:Set["${Me.Name} Agents"]
		LavishSettings:AddSet[${ObjAgentList}]
		AgentConfig:Set[${LavishSettings.FindSet[${ObjAgentList}]}]
		AgentConfig:Import["${ObjAgentList}.xml"]
		
	}
	
	method Shutdown()
	{
		LavishSettings[${ObjAgentList}]:Export["${ObjAgentList}.xml"]
		LavishSettings[${ObjAgentList}]:Remove
	}
	
	method AcquireAgentList()
	{
		variable iterator ObjAgentIterator
		AgentConfig:GetSettingIterator[ObjAgentIterator]
		if ${ObjAgentIterator:First(exists)}
		do
		{
			MyAgentNames:Insert[${ObjAgentIterator.Value.Name}]
			MyAgentIndexes:Insert[${ObjAgentIterator.Value.Int}]
			StatusUpdate:Green["${Agent[${ObjAgentIterator.Value.Int}].Name} found"]
			StatusUpdate:Yellow["${Agent[${ObjAgentIterator.Value.Int}].Name} found"]
		}
		while ${ObjAgentIterator:Next(exists)}
	}
	
	method DetermineAgent()
	{
		variable iterator DeterminerA
		variable iterator DeterminerB
		variable string DeterminedAgent
		variable index:agentmission DetermineMissions
		variable collection:int AgentsThatOffered
		variable collection:int AgentsIveDeclined
		variable int BestQuality = -21
		variable int BestLevel = 0
		variable int DetermineIndex = 0
		
		MyAgentIndexes:GetIterator[DeterminerA]
		if ${DeterminerA:First(exists)}
		do
		{
			EVE:DoGetAgentMissions[DetermineMissions]
			DetermineMissions:GetIterator[DeterminerB]
			if ${DeterminerB:First(exists)}
			do
			{
				StatusUpdate:Yellow["Offered - ${DeterminerB.Value.AgentID} == ${Agent[${DeterminerA.Value}].ID} && ${DeterminerB.Value.State} == 1"]
				if ${DeterminerB.Value.AgentID} == ${Agent[${DeterminerA.Value}].ID} && ${DeterminerB.Value.State} == 1
					AgentsThatOffered:Set[${DeterminerA.Value},1]
			}
			while ${DeterminerB:Next(exists)}
			AgentConfig:GetSettingIterator[DeterminerB]
			if ${DeterminerB:First(exists)}
			do
			{
				StatusUpdate:Yellow["Declined - ${Math.Calc[(${Time.Timestamp} - ${DeterminerB.Value.FindAttribute[Decline,0].Int}) / 360]} <= 4"]
				if ${Math.Calc[(${Time.Timestamp} - ${DeterminerB.Value.FindAttribute[Decline,0].Int}) / 360]} <= 4
					AgentsIveDeclined:Set[${DeterminerA.Value},1]
			}
			while ${DeterminerB:Next(exists)}
		}
		while ${DeterminerA:Next(exists)}
		
		MyAgentIndexes:GetIterator[DeterminerA]
		if ${DeterminerA:First(exists)}
		do
		{
			StatusUpdate:Yellow["Determine - !(${AgentsThatOffered.Element[${DeterminerA.Value}](exists)} && ${AgentsIveDeclined.Element[${DeterminerA.Value}](exists)})"]
			if ${If[!(${AgentsThatOffered.Element[${DeterminerA.Value}](exists)} && ${AgentsIveDeclined.Element[${DeterminerA.Value}](exists)}),TRUE,FALSE]}
			{
				StatusUpdate:Yellow["Level - ${Agent[${DeterminerA.Value}].Level} > ${BestLevel}"]
				StatusUpdate:Yellow["Quality - ${Agent[${DeterminerA.Value}].Level} == ${BestLevel} && ${Agent[${DeterminerA.Value}].Quality} > ${BestQuality}"]
				if ${Agent[${DeterminerA.Value}].Level} > ${BestLevel}
				{
					BestQuality:Set[${Agent[${DeterminerA.Value}].Quality}]
					BestLevel:Set[${Agent[${DeterminerA.Value}].Level}]
					MyCurrentAgent:Set[${DeterminerA.Value}]
				}
				elseif ${Agent[${DeterminerA.Value}].Level} == ${BestLevel}
				{
					if ${Agent[${DeterminerA.Value}].Quality} > ${BestQuality}
					{
						BestQuality:Set[${Agent[${DeterminerA.Value}].Quality}]
						MyCurrentAgent:Set[${DeterminerA.Value}]
					}
				}
			}
		}
		while ${DeterminerA:Next(exists)}
		StatusUpdate:Yellow["${Agent[${MyCurrentAgent}].Name} is the best agent"]
		StatusUpdate:Green["${Agent[${MyCurrentAgent}].Name} is the best agent"]
	}
	
	member:bool CanDecline()
	{
		if ${Math.Calc[(${Time.Timestamp} - ${AgentConfig.FindSetting[${Agent[${MyCurrentAgent}].Name}].FindAttribute[Decline,0].Int}) / 360]} > 4
			return TRUE
		else
			return FALSE
	}
	
	member:string MissionType()
	{
		variable iterator MissTypeIter
		variable index:agentmission ObjMissType
		
		EVE:DoGetAgentMissions[ObjMissType]
		ObjMissType:GetIterator[MissTypeIter]
		if ${MissTypeIter:First(exists)}
		do
		{
			if ${MissTypeIter.Value.AgentID} == ${Agent[${MyCurrentAgent}].ID}
				return ${MissTypeIter.Value.Type}
		}
		while ${MissTypeIter:Next(exists)}
	}
	
	function Interact(bool InteractOpen)
	{
		if ${InteractOpen}
		do
		{
			if (!${EVEWindow[ByCaption,Agent Conversation](exists)})
				Agent[${MyCurrentAgent}]:StartConversation
			wait ${Math.Calc[${Slow} / 2]}
			StatusUpdate:Yellow["Interact Open - (!${EVEWindow[ByCaption,Agent Conversation](exists)})"]
		}
		while (!${EVEWindow[ByCaption,Agent Conversation](exists)})
		if !(${InteractOpen})
		do
		{
			if ${EVEWindow[ByCaption,Agent Conversation](exists)}
				EVEWindow[ByCaption,Agent Conversation]:Close
			wait ${Math.Calc[${Slow} / 2]}
			StatusUpdate:Yellow["Interact Close - ${EVEWindow[ByCaption,Agent Conversation](exists)}"]
		}
		while ${EVEWindow[ByCaption,Agent Conversation](exists)}
		StatusUpdate:Green["Interact EVEWindow[ByCaption,Agent Conversation](exists) - ${EVEWindow[ByCaption,Agent Conversation](exists)} "]
		wait ${Math.Calc[${Slow} * 2]}
	}
	
	function Accept(bool DoAccept)
	{
		variable index:dialogstring DialogIndex
		variable iterator DialogIter
		
		Agent[${MyCurrentAgent}]:DoGetDialogResponses[DialogIndex]
		DialogIndex:GetIterator[DialogIter]
		if ${DialogIter:First(exists)}
		do
		{
			StatusUpdate:Green["${DialogIter.Value.Text}"]
			StatusUpdate:Yellow[""]
			if ${DialogIter.Value.Text.Find[Accept]} > 0 && ${DoAccept}
				DialogIter.Value:Say[${Agent[${MyCurrentAgent}].ID}]
			elseif ${DialogIter.Value.Text.Find[Decline]} > 0 && !(${DoAccept})
				DialogIter.Value:Say[${Agent[${MyCurrentAgent}].ID}]
		}
		while ${DialogIter:Next(exists)}
		wait ${Math.Calc[${Slow} * 4]}
	}
	
	function Complete()
	{
		variable index:dialogstring DialogIndexa
		variable iterator DialogItera
		
		Agent[${MyCurrentAgent}]:DoGetDialogResponses[DialogIndexa]
		DialogIndexa:GetIterator[DialogItera]
		if ${DialogItera:First(exists)}
		do
		{
			StatusUpdate:Green["${DialogItera.Value.Text}"]
			StatusUpdate:Yellow[""]
			if ${DialogItera.Value.Text.Find[Complete]} > 0
				DialogItera.Value:Say[${Agent[${MyCurrentAgent}].ID}]
		}
		while ${DialogItera:Next(exists)}
		wait ${Math.Calc[${Slow} * 4]}
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
	
	function OpenJournal()
	{
		Mouse:SetPosition[40,1]
		wait 5
		Mouse:LeftClick
		wait 5
		Keyboard:Hold[Alt]
		wait 5
		Keyboard:Press[j]
		wait 5
		Keyboard:Release[Alt]
		wait 10
	}
	
	function GetDetails()
	{
		variable index:agentmission amIndex
		variable iterator amIterator
		StatusUpdate:Green["Details journal open - ${EVEWindow[ByCaption,Journal](exists)}"]
		if !(${EVEWindow[ByCaption,Journal](exists)})
			call This.OpenJournal
		EVE:DoGetAgentMissions[amIndex]
		amIndex:GetIterator[amIterator]
		if ${amIterator:First(exists)}
		{
			do
			{
				if ${amIterator.Value.AgentID} == ${Agent[${MyCurrentAgent}].ID}
				{
					break
				}
			}
			while ${amIterator:Next(exists)}
		}

		if !${amIterator.Value(exists)}
		{
			;echo No Mission
			return
		}

		StatusUpdate:Green["amIterator.Value.AgentID = ${amIterator.Value.AgentID}"]
		StatusUpdate:Green["amIterator.Value.State = ${amIterator.Value.State}"]
		StatusUpdate:Green["amIterator.Value.Type = ${amIterator.Value.Type}"]
		StatusUpdate:Green["amIterator.Value.Name = ${amIterator.Value.Name}"]
		StatusUpdate:Green["amIterator.Value.Expires = ${amIterator.Value.Expires.DateAndTime}"]

		amIterator.Value:GetDetails
		wait 50
		variable string details
		variable string caption
		variable int left = 0
		variable int right = 0
		caption:Set["${amIterator.Value.Name.Escape}"]
		left:Set[${caption.Escape.Find["u2013"]}]

		if ${left} > 0
		{
			StatusUpdate:Green["WARNING: Mission name contains u2013"]
			StatusUpdate:Green["amIterator.Value.Name.Escape = ${amIterator.Value.Name.Escape}"]

			caption:Set["${caption.Escape.Right[${Math.Calc[${caption.Escape.Length} - ${left} - 5]}]}"]

			;echo caption.Escape = ${caption.Escape}
		}
		
		details:Set["${EVEWindow[ByCaption,"${caption}"].HTML.Escape}"]

		;echo HTML.Length = ${EVEWindow[ByCaption,${caption}].HTML.Length}
		;echo details.Length = ${details.Length}

		variable file detailsFile
		detailsFile:SetFilename["Logs/${Time.Month}-${Time.Day} ${Time.Hour}${Time.Minute} - ${caption}.html"]
		if ${detailsFile:Open(exists)}
		{
			detailsFile:Write["${details.Escape}"]
		}
		detailsFile:Close
		
		variable int factionID = 0
		left:Set[${details.Escape.Find["<img src=\\\"factionlogo:"]}]
		if ${left} > 0
		{
			;echo Found \"factionlogo\" at ${left}."]
			left:Inc[23]
			;echo Found \"factionlogo\" at ${left}."]
			;echo factionlogo substring = ${details.Escape.Mid[${left},16]}"]
			right:Set[${details.Escape.Mid[${left},16].Find["\" "]}]
			if ${right} > 0
			{
				right:Dec[2]
				;echo left = ${left}"]
				;echo right = ${right}"]
				;echo string = ${details.Escape.Mid[${left},${right}]}"]
				factionID:Set[${details.Escape.Mid[${left},${right}]}]
				StatusUpdate:Green["factionID = ${factionID}"]
			}
			else
			{
				;echo ERROR: Did not find end of \"factionlogo\"!"]
			}
		}
		else
		{
			StatusUpdate:Green["Did not find \"factionlogo\".  Rouge Drones???"]
		}

		variable int typeID = 0
		left:Set[${details.Escape.Find["<img src=\\\"typeicon:"]}]
		if ${left} > 0
		{
			;echo Found \"typeicon\" at ${left}.
			left:Inc[20]
			;echo typeicon substring = ${details.Escape.Mid[${left},16]}
			right:Set[${details.Escape.Mid[${left},16].Find["\" "]}]
			if ${right} > 0
			{
				right:Dec[2]
				;echo left = ${left}
				;echo right = ${right}
				;echo string = ${details.Escape.Mid[${left},${right}]}
				typeID:Set[${details.Escape.Mid[${left},${right}]}]
				StatusUpdate:Green["typeID = ${typeID}"]
			}
			else
			{
				;echo ERROR: Did not find end of \"typeicon\"!
			}
		}
		else
		{
			StatusUpdate:Green["Did not find \"typeicon\".  No cargo???"]
		}

		variable float volume = 0

		right:Set[${details.Escape.Find["msup3"]}]
		if ${right} > 0
		{
			;echo Found \"msup3\" at ${right}.
			right:Dec
			left:Set[${details.Escape.Mid[${Math.Calc[${right}-16]},16].Find[" ("]}]
			if ${left} > 0
			{
				left:Set[${Math.Calc[${right}-16+${left}+1]}]
				right:Set[${Math.Calc[${right}-${left}]}]
				;echo left = ${left}
				;echo right = ${right}
				;echo string = ${details.Escape.Mid[${left},${right}]}
				volume:Set[${details.Escape.Mid[${left},${right}]}]
				StatusUpdate:Green["volume = ${volume}"]
			}
			else
			{
				;echo ERROR: Did not find number before \"msup3\"!
			}
		}
		else
		{
			StatusUpdate:Green["Did not find \"msup3\".  No cargo???"]
		}

   		variable bool isLowSec = FALSE
		left:Set[${details.Escape.Find["(Low Sec Warning!)"]}]
        right:Set[${details.Escape.Find["(The route generated by current autopilot settings contains low security systems!)"]}]
		if ${left} > 0 || ${right} > 0
		{
            ;echo left = ${left}
            ;echo right = ${right}
			isLowSec:Set[TRUE]
			StatusUpdate:Green["isLowSec = ${isLowSec}"]
		}
		
		EVEWindow[ByCaption,${caption}]:Close
	}
	
	function GoTo(bool GoToDungeon)
	{
	
		variable iterator MissBookIter
		MissionBookmarks:GetIterator[MissBookIter]
		if ${MissBookIter:First(exists)}
		do
		{
			StatusUpdate:Yellow[""]
			if ${MissBookIter.Value.LocationType.Find[dungeon]} && ${GoToDungeon}
				break
			elseif ${MissBookIter.Value.SolarSystemID} != ${Me.SolarSystemID}
				break
		}
		while ${MissBookIter:Next(exists)}
	
		BotCurrentState:Set["GoTo mission bookmarks"]
		StatusUpdate:Green["Begin GoTo ${MissBookIter.Value.LocationType}"]
		variable int ObjDestinationCount
		if ${Me.InStation}
			call TheShip.Undock
		StatusUpdate:Yellow[""]
		if ${MissBookIter.Value.SolarSystemID} != ${Me.SolarSystemID}
		{
			StatusUpdate:Yellow["GoTo not in system"]
			StatusUpdate:Green["Bookmark not in system, Autopilot"]
			do
			{
				ObjDestinationCount:Set[0]
				do
				{
					MissBookIter.Value:SetDestination
					ObjDestinationCount:Set[${EVE.GetToDestinationPath}]
					wait ${Slow}
					StatusUpdate:Yellow["Destination count - ${ObjDestinationCount}"]
				}
				while ${ObjDestinationCount} < 1
				do
				{
					EVE:Execute[CmdToggleAutopilot]
					wait ${Math.Calc[${Slow} * 2]}
					StatusUpdate:Yellow["Autopilot on - ${Me.AutoPilotOn}"]
				}
				while !(${Me.AutoPilotOn})
				do
				{
					StatusUpdate:Yellow["Autopilot wait"]
					if ${EntityWatchOn}
						call StatusUpdate.White
					wait ${Math.Calc[${Slow} * 4]}
				}
				while ${Me.AutoPilotOn}
				do
				{
					wait ${Slow}
					StatusUpdate:Yellow["Cloaked - ${Me.ToEntity.IsCloaked}"]
				}
				while !(${Me.ToEntity.IsCloaked})
				wait ${Math.Calc[${Slow} * 4]}
			}
			while ${MissBookIter.Value.SolarSystemID} != ${Me.SolarSystemID}
		}
		StatusUpdate:Yellow["GoTo in system"]
		StatusUpdate:Green["Bookmark in system, Warp"]
		;do
		;{
			do
			{
				MissBookIter.Value:WarpTo
				wait ${Slow}
				StatusUpdate:Yellow["WarpTo should be 3 - ${Me.ToEntity.Mode}"]
			}
			while ${Me.ToEntity.Mode} != 3
			do
			{
				StatusUpdate:Yellow["Warping is 3 - ${Me.ToEntity.Mode}"]
				if ${EntityWatchOn}
					call StatusUpdate.White
				wait ${Slow}
			}
			while ${Me.ToEntity.Mode} == 3
			wait ${Slow}
			StatusUpdate:Green["Distance to Bookmark - ${Math.Distance[${Me.ToEntity.X}, ${Me.ToEntity.Y}, ${Me.ToEntity.Z}, ${MissBookIter.Value.X}, ${MissBookIter.Value.Y}, ${MissBookIter.Value.Z}].Centi}"]
		;}
		;while ${Math.Distance[${Me.ToEntity.X}, ${Me.ToEntity.Y}, ${Me.ToEntity.Z}, ${MissBookIter.Value.X}, ${MissBookIter.Value.Y}, ${MissBookIter.Value.Z}]} > 10000
		if !(${GoToDungeon})
		{
			StatusUpdate:Yellow[""]
			if ${MissBookIter.Value.ToEntity(exists)}
			{
				StatusUpdate:Yellow["GoTo found a station"]
				StatusUpdate:Green["Bookmark is a station, docking"]
				do
				{
					MissBookIter.Value.ToEntity:Approach
					if ${EntityWatchOn}
						call StatusUpdate.White
					wait ${Math.Calc[${Slow} * 4]}
					StatusUpdate:Green["Approach left - ${MissBookIter.Value.ToEntity.Distance}"]
				}
				while ${MissBookIter.Value.ToEntity.Distance} > 400
				do
				{
					MissBookIter.Value.ToEntity:Dock
					wait ${Math.Calc[${Slow} * 4]}
					StatusUpdate:Green["Still in space - ${Me.InSpace}"]
				}
				while ${Me.InSpace}
				wait ${Math.Calc[${Slow} * 4]}
				StatusUpdate:Green["Docked"]
			}
		}
	}
	
}