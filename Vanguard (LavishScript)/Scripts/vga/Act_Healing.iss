;===================================================
;===     Class Specific Pre Heal Check         ====
;===================================================

function ClassSpecificPreHealCheck()
{
	switch ${Me.Class}
	{
	case Blood Mage
		call BM_PreHealRoutine
		break

	default
		break
	}
}

function Healcheck()
{
	;; If you want to avoid calling this function at all (ie, if the class specific function determines that everyone is max health -- then
	;; you can return "HEALSDONE" to avoid running the rest of this function and further optimize the script.
	call ClassSpecificPreHealCheck
	if ${Return.Equal[HEALSDONE]}
	return


	if ${ClassRole.healer}
	{
		;;  Group Healing by Type Forward
		if ${Group.Count} > 1
		{
			call CheckGroupDamage
		}

	}
}

;******************************Find My Group in Raid************************

function SetGroupMembers()
{
	UIElement[GroupMemberList@HealPctCFrm@HealPct@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:ClearItems
	if ${Group.Count} < 7
	{
		Grplog "You are Not In A Raid"
		return
	}
	variable string LastTargetedGrpMember
	variable int i
	Grplog "Grp#(Raid#) Name"
	VGExecute "/targetgroupmember 1"
	wait 3
	RaidGroupCount:Set[1]
	LastTargetedGrpMember:Set[${Me.DTarget.Name}]
	for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
	{
		if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
		{
			RaidGroup[1]:Set[${i}]
			Grplog " 1    (${RaidGroup[1]})   ${Group[${i}].ToPawn.Name}"
		}
	}

	VGExecute "/targetgroupmember 2"
	wait 3
	if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
	{
		Grplog "***${RaidGroupCount} In Your Group***"
		return
	}
	RaidGroupCount:Set[2]
	LastTargetedGrpMember:Set[${Me.DTarget.Name}]
	for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
	{
		if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
		{
			RaidGroup[2]:Set[${i}]
			Grplog " 2    (${RaidGroup[2]})   ${Group[${i}].ToPawn.Name}"
		}
	}
	VGExecute "/targetgroupmember 3"
	wait 3
	if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
	{
		Grplog "***${RaidGroupCount} In Your Group***"
		return
	}
	RaidGroupCount:Set[3]
	LastTargetedGrpMember:Set[${Me.DTarget.Name}]
	for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
	{
		if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
		{
			RaidGroup[3]:Set[${i}]
			Grplog " 3    (${RaidGroup[3]})   ${Group[${i}].ToPawn.Name}"
		}
	}
	VGExecute "/targetgroupmember 4"
	wait 3
	if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
	{
		Grplog "***${RaidGroupCount} In Your Group***"
		return
	}
	RaidGroupCount:Set[4]
	LastTargetedGrpMember:Set[${Me.DTarget.Name}]
	for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
	{
		if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
		{
			RaidGroup[4]:Set[${i}]
			Grplog " 4    (${RaidGroup[4]})   ${Group[${i}].ToPawn.Name}"
		}
	}
	VGExecute "/targetgroupmember 5"
	wait 3
	if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
	{
		Grplog "***${RaidGroupCount} In Your Group***"
		return
	}
	RaidGroupCount:Set[5]
	LastTargetedGrpMember:Set[${Me.DTarget.Name}]
	for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
	{
		if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
		{
			RaidGroup[5]:Set[${i}]
			Grplog " 5    (${RaidGroup[5]})   ${Group[${i}].ToPawn.Name}"
		}
	}
	VGExecute "/targetgroupmember 6"
	wait 3
	if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
	{
		Grplog "***${RaidGroupCount} In Your Group***"
		return
	}
	RaidGroupCount:Set[6]
	LastTargetedGrpMember:Set[${Me.DTarget.Name}]
	for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
	{
		if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
		{
			RaidGroup[6]:Set[${i}]
			Grplog " 6    (${RaidGroup[6]})   ${Group[${i}].ToPawn.Name}"
		}
	}
	Grplog "***${RaidGroupCount} People In Your Group***"
}


;******************************Change forms/Stances***********************
function changeformstance()
{
	if ${fight.ShouldIAttack} && ${doCombatStance} && !${Me.Effect[${CombatStance}](exists)}
	{
		Me.Form[${CombatStance}]:ChangeTo
	}
	if !${fight.ShouldIAttack} && ${doNonCombatStance} && !${Me.Effect[${NonCombatStance}](exists)}
	{
		Me.Form[${NonCombatStance}]:ChangeTo
	}
}



;******************************Hot Timers and IsReady Timers***********************
function SetupHOTTimer()
{
	variable int GroupNumber

	if ${Me.IsGrouped}
	{
		for ( GroupNumber:Set[1] ; ${Group[${GroupNumber}].ID(exists)} ; GroupNumber:Inc )
		{
			HOTReady[${GroupNumber}]:Set[${LavishScript.RunningTime}]
		}
	}
}

function:bool CanApplyHOT(string HealAbility, int GroupNumber)
{
	;if !${Me.IsGrouped} || !${Me.Ability[${HealAbility}].IsReady}
	;	return

	if ${LavishScript.RunningTime}<${HOTReady[${GroupNumber}]}
	return FALSE

	return TRUE
}

function:bool SaveHOTTime(string HealAbility, int GroupNumber)
{
	;Me.Ability[${HealAbility}]:Use

	variable int DelaySeconds

	if ${HealAbility.Find[Alleviate]}
	DelaySeconds:Set[17]
	elseif ${HealAbility.Find[Kiss of Heaven]}
	DelaySeconds:Set[31]
	else
	DelaySeconds:Set[1]

	HOTReady[${GroupNumber}]:Set[${Math.Calc[${LavishScript.RunningTime}+(1000*${DelaySeconds})]}]

	wait 3

	return TRUE
}


