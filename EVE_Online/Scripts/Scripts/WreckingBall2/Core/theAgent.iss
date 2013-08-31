objectdef theAgent
{
	
	

	member:string MissionType()
	{
		variable iterator Iter
		variable index:agentmission Missions
		
		EVE:GetAgentMissions[Missions]
		Missions:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.AgentID} == ${Agent[${CurrentAgent}].ID}
				return ${Iter.Value.Type}
		}
		while ${Iter:Next(exists)}
	}
	
	function Interact(bool Open)
	{
		if ${Open}
		while !AGENTWINDOW
		{
			Agent[${CurrentAgent}]:StartConversation
			wait RANDOM(SLOW2,SLOW2)
		}
		
		if !(${Open})
		while AGENTWINDOW
		{
			EVEWindow[ByCaption,Agent Conversation]:Close
			wait RANDOM(SLOW2,SLOW2)
		}
	}
	
	function Accept(bool DoAccept)
	{
		variable index:dialogstring DialogIndex
		variable iterator Iter
		
		Agent[${CurrentAgent}]:GetDialogResponses[DialogIndex]
		DialogIndex:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.Text.Find[Accept]} > 0 && ${DoAccept}
				Iter.Value:Say[${Agent[${CurrentAgent}].ID}]
			elseif ${Iter.Value.Text.Find[Decline]} > 0 && !${DoAccept}
				Iter.Value:Say[${Agent[${CurrentAgent}].ID}]
		}
		while ${Iter:Next(exists)}
		wait RANDOM(SLOW2,SLOW2)
	}
	
	function Complete()
	{
		variable index:dialogstring DialogIndex
		variable iterator Iter
		
		Agent[${CurrentAgent}]:GetDialogResponses[DialogIndex]
		DialogIndex:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.Text.Find[Complete]} > 0
				Iter.Value:Say[${Agent[${CurrentAgent}].ID}]
		}
		while ${Iter:Next(exists)}
		wait RANDOM(SLOW2,SLOW2)
	}
	
	function GetDetails()
	{
		variable index:agentmission Missions
		variable iterator Iter
		variable collection:string CaptainsLog
		
		echo "Details journal open - JOURNALWINDOW"
		;if !JOURNALWINDOW
			;call This.OpenJournal
			
		
		EVE:GetAgentMissions[Missions]
		Missions:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			if ${Iter.Value.AgentID} == ${Agent[${CurrentAgent}].ID}
				break
		}
		while ${Iter:Next(exists)}

		if !${Iter.Value(exists)}
		{
			;echo No Mission
			return
		}
		

		Iter.Value:GetDetails
		wait 50
		variable string details
		variable string caption
		variable int left = 0
		variable int right = 0
		caption:Set["${Iter.Value.Name.Escape}"]
		left:Set[${caption.Escape.Find["u2013"]}]

		if ${left} > 0
		{
			echo "WARNING: Mission name contains u2013"
			echo "Iter.Value.Name.Escape = ${Iter.Value.Name.Escape}"

			caption:Set["${caption.Escape.Right[${Math.Calc[${caption.Escape.Length} - ${left} - 5]}]}"]
			CaptainsLog:Set[Caption,${caption.Escape}]
			echo caption.Escape = ${caption.Escape}
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
			;echo "Found \"factionlogo\" at ${left}."]
			left:Inc[23]
			;echo "Found \"factionlogo\" at ${left}."]
			;echo factionlogo substring = ${details.Escape.Mid[${left},16]}
			right:Set[${details.Escape.Mid[${left},16].Find["\" "]}]
			if ${right} > 0
			{
				right:Dec[2]
				;echo left = ${left}"]
				;echo right = ${right}"]
				;echo string = ${details.Escape.Mid[${left},${right}]}"]
				factionID:Set[${details.Escape.Mid[${left},${right}]}]
				;echo "factionID = ${factionID}"
				
				
			}
			else
			{
				echo ERROR: Did not find end of \"factionlogo\"!"]
			}
		}
		else
		{
			echo "Did not find \"factionlogo\".  Rouge Drones???"
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
				;echo "typeID = ${typeID}"
			}
			else
			{
				echo ERROR: Did not find end of \"typeicon\"!
			}
		}
		else
		{
			echo "Did not find \"typeicon\".  No cargo???"
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
				;echo "volume = ${volume}"
				CaptainsLog:Set[volume,${volume}]
			}
			else
			{
				echo ERROR: Did not find number before \"msup3\"!
			}
		}
		else
		{
			echo "Did not find \"msup3\".  No cargo???"
		}

   		variable bool isLowSec = FALSE
		left:Set[${details.Escape.Find["(Low Sec Warning!)"]}]
        right:Set[${details.Escape.Find["(The route generated by current autopilot settings contains low security systems!)"]}]
		if ${left} > 0 || ${right} > 0
		{
            ;echo left = ${left}
            ;echo right = ${right}
			isLowSec:Set[TRUE]
			;echo "isLowSec = ${isLowSec}"
		}
		
		CaptainsLog:Set[AgentID,${Iter.Value.AgentID}]
		CaptainsLog:Set[State,${Iter.Value.State}]
		CaptainsLog:Set[Type,${Iter.Value.Type}]
		CaptainsLog:Set[Name,${Iter.Value.Name}]
		CaptainsLog:Set[Expires,${Iter.Value.Expires}]
		CaptainsLog:Set[factionID,${factionID}]
		CaptainsLog:Set[typeID,${typeID}]
		CaptainsLog:Set[volume,${volume}]
		CaptainsLog:Set[isLowSec,${isLowSec}]
		
		if ${CaptainsLog.FirstValue(exists)}
		do
		{
			echo "${CaptainsLog.CurrentKey} - ${CaptainsLog.CurrentValue}"
		}
		while ${CaptainsLog.NextValue(exists)}
		
		EVEWindow[ByCaption,${caption}]:Close
	}
}