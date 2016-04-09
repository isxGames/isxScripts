#define ALARM "${Script.CurrentDirectory}/Sounds/ping.wav"


;===================================================
;===   SUBROUTINE - FIND GROUP MEMBERS          ====
;===================================================
function FindGroupMembers()
{
	if !${doFindGroupMembers}
		return
		
	;; reset our variables
	GroupMemberList:Clear
	doFindGroupMembers:Set[FALSE]
	
	if ${Me.IsGrouped}
	{
		for (i:Set[1]; ${i}<=6; i:Inc)
		{
			;; Clear our Target
			VGExecute /cleartargets
			wait 1 !${Me.DTarget(exists)}
			
			;; Target a Group Member (1-6)
			VGExecute "/targetgroupmember ${i}"
			wait 1 ${Me.DTarget(exists)}
			
			;; Add Name to GroupMemberList
			if ${Me.DTarget(exists)}
			{
				GroupMemberList:Set["${Me.DTarget.Name.Token[1," "]}", ${Me.DTarget.ID}]
				vgecho "Group Member[${i}] = ${Me.DTarget.Name}"
			}
			
			if !${Me.DTarget(exists)}
				vgecho "Group Member[${i}] = does not exist"
		}
	}
}
variable collection:int GroupMemberList
variable bool doFindGroupMembers = FALSE


;===================================================
;===   SUBROUTINE - TARGET LOWEST HEALTH        ====
;===================================================
function CheckHealing(int CheckHealth=80, int Range=25, bool GroupOnly)
{
	if !${Me.IsGrouped}
	{
		if ${Me.HealthPct} <= ${CheckHealth}
		{
			Pawn[Me]:Target
			waitframe
			return TRUE
		}
		return FALSE
	}
	

	if ${Me.IsGrouped}
	{
		;; Set our variables
		variable int GroupNumber = 0
		variable int LowestHealth = 100
		GroupNumber:Set[0]
		LowestHealth:Set[100]
		
		;; Scan everyone
		if !${GroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Group[${i}].Distance}<${Range} && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
				{
					GroupNumber:Set[${i}]
					LowestHealth:Set[${Group[${i}].Health}]
				}
			}
		}
		
		;; Scan only group members
		if ${GroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
				{
					if ${Group[${i}].Distance}<${Range} && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
					{
						GroupNumber:Set[${i}]
						LowestHealth:Set[${Group[${i}].Health}]
					}
				}
			}
		}
		
		if ${LowestHealth} <= ${CheckHealth}
		{
			Pawn[id,${Group[${GroupNumber}].ID}]:Target
			waitframe
			return TRUE
		}
		return FALSE
	}
}