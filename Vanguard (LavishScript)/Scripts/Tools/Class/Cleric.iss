variable bool ClericRunOnce = TRUE
variable int NextClericCheck = ${Script.RunningTime}
function Cleric()
{
	;; forces this only to run once every .2 seconds
	;if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextClericCheck}]}/100]}<2
	;	return
	;NextSorcCheck:Set[${Script.RunningTime}]

	;; return if your class is not a Bard
	if !${Me.Class.Equal[Cleric]}
		return
	
	;; we only want to run this once
	if ${ClericRunOnce}
	{
		;; show the Cleric tab in UI
		UIElement[Cleric@Class@DPS@Tools]:Show
		ClericRunOnce:Set[FALSE]
		
		SetHighestAbility "Alleviate" "Alleviate"
		SetHighestAbility "HealingTouch" "Healing Touch"
		SetHighestAbility "Rejuvenate" "Rejuvenate"
		
	}
	
	;; update our group members
	if ${doFindGroupMembers}
		call FindGroupMembers
	
	;; This will force the ability to become ready before continuing
	;; so that we do not miss a heal
	call ReadyCheck	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Group Healing
	if ${Me.IsGrouped}
	{
		variable int GroupNumber = 0
		variable int LowestHealth = 100
		variable int Range = 0
		variable bool isGroupMember = FALSE
		GroupNumber:Set[0]
		LowestHealth:Set[100]
		Range:Set[0]
		isGroupMember:Set[FALSE]
	
		
		;; Scan only group members
		if ${doGroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
				{
					if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
					{
						GroupNumber:Set[${i}]
						LowestHealth:Set[${Group[${i}].Health}]
						Range:Set[${Group[${i}].Distance}]
						isGroupMember:Set[TRUE]
					}
				}
			}
		}
		else
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<=${LowestHealth}
				{
					GroupNumber:Set[${i}]
					LowestHealth:Set[${Group[${i}].Health}]
					Range:Set[${Group[${i}].Distance}]
					if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
						isGroupMember:Set[TRUE]
				}
			}
		}
		
		if ${doBigHeal} && ${BigHealPct}>${LowestHealth}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[id,${Group[${GroupNumber}].ID}]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${Rejuvenate}"
			return
		}
		
		if ${doSmallHeal} && ${SmallHealPct}>${LowestHealth}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[id,${Group[${GroupNumber}].ID}]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${HealingTouch}"
			return
		}
		
		if ${doHoT} && ${HoTPct}>${LowestHealth}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[id,${Group[${GroupNumber}].ID}]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${Alleviate}"
			return
		}
	}
	
	if !${Me.IsGrouped}
	{
		if ${doBigHeal} && ${BigHealPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${Rejuvenate}"
			return
		}
		
		if ${doSmallHeal} && ${SmallHealPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${HealingTouch}"
			return
		}
		
		if ${doHoT} && ${HoTPct}>${Me.HealthPct}
		{
			if !${Group[${GroupNumber}].Name.Find[${Me.DTarget.Name}]}
			{
				Pawn[me]:Target
				waitframe
			}
			call UseAbilityNoCoolDown "${Alleviate}"
			return
		}
	}
}
