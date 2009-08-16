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
		if ${Group.Count} < 2 && ${HealTimer.TimeLeft} == 0
		{
			waitframe

			if ${Me.HealthPct} > 90
				return

			;; Note:  [1] is always "Me"
			if ${Me.HealthPct} < ${bhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Me.ToPawn:Target
				call checkabilitytocast "${BigHeal}"
				if ${Return}
				{
					call executeability "${BigHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${HotHeal}"
				if ${Return}
				{
					call CanApplyHOT "${HotHeal}" 1
					if ${Return}
					{
						usedAbility:Set[FALSE]
						call executeability "${HotHeal}" "Heal" "Neither"
						if ${usedAbility}
							call SaveHOTTime "${HotHeal}" 1
					}
					return
				}
				return
			}

			if ${Me.HealthPct} < ${hhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Me.ToPawn:Target
				waitframe
				call checkabilitytocast "${HotHeal}"
				if ${Return}
				{
					call CanApplyHOT "${HotHeal}" 1
					if ${Return}
					{
						usedAbility:Set[FALSE]
						call executeability "${HotHeal}" "Heal" "Neither"
						if ${usedAbility}
							call SaveHOTTime "${HotHeal}" 1
					}
					return
				}
				return
			}
			
			if ${Me.HealthPct} < ${hpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Me.ToPawn:Target
				waitframe
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantHeal}"
				if ${Return}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				return
			}
			
			if ${Me.HealthPct} < ${fhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Me.ToPawn:Target
				waitframe
				call checkabilitytocast "${InstantHeal}"
				if ${Return}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				return
			}
		}
		
		if ${Group.Count} > 1 && ${HealTimer.TimeLeft} == 0
		{
			waitframe
			variable int icnt

			if ${healneeds.GroupInstantHealNum} > 1 && ${GroupStatus.AOEBuffClose}
			{
				healrefresh:Set[FALSE]
				Me.ToPawn:Target
				waitframe
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${GroupHeal}"
				if ${Return}
				{
					call executeability "${GroupHeal}" "Heal" "Neither"
					return
				}
				return
			}

			;; Group Heal
			if ${healneeds.GroupHealNum} > 1 && ${healrefresh} && ${GroupStatus.AOEBuffClose}
			{
				healrefresh:Set[FALSE]
				Me.ToPawn:Target
				waitframe
				call checkabilitytocast "${GroupHeal}"
				if ${Return}
				{
					call executeability "${GroupHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				return
			}

			;; Big Heal
			icnt:Set[1]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${bhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${GrpMemberNames[${icnt}]}].ToPawn:Target
					waitframe
					call checkabilitytocast "${BigHeal}"
					if ${Return}
					{
						call executeability "${BigHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${SmallHeal}"
					if ${Return}
					{
						call executeability "${SmallHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${HotHeal}"
					if ${Return}
					{
						call CanApplyHOT "${HotHeal}" ${icnt}
						if ${Return}
						{
							usedAbility:Set[FALSE]
							call executeability "${HotHeal}" "Heal" "Neither"
							if ${usedAbility}
								call SaveHOTTime "${HotHeal}" ${icnt}
						}
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}

			;; Heal over Time
			icnt:Set[1]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${hhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${GrpMemberNames[${icnt}]}].ToPawn:Target
					waitframe
					call checkabilitytocast "${HotHeal}"
					if ${Return}
					{
						call CanApplyHOT "${HotHeal}" ${icnt}
						if ${Return}
						{
							usedAbility:Set[FALSE]
							call executeability "${HotHeal}" "Heal" "Neither"
							if ${usedAbility}
								call SaveHOTTime "${HotHeal}" ${icnt}
						}
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}

			;; Small Heal
			icnt:Set[1]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${hpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${GrpMemberNames[${icnt}]}].ToPawn:Target
					waitframe
					call checkabilitytocast "${SmallHeal}"
					if ${Return}
					{
						call executeability "${SmallHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantHeal}"
					if ${Return}
					{
						call executeability "${InstantHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantGroupHeal}"
					if ${Return}
					{
						call executeability "${InstantGroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}
	
			;; Instant Heal ;;
			icnt:Set[1]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${fhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${GrpMemberNames[${icnt}]}].ToPawn:Target
					waitframe
					call checkabilitytocast "${InstantHeal}"
					if ${Return}
					{
						call executeability "${InstantHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${SmallHeal}"
					if ${Return}
					{
						call executeability "${SmallHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantGroupHeal}"
					if ${Return}
					{
						call executeability "${InstantGroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}
			
			return
		}
	}

}
;**********************************************
function checkinstantheal()
{
	variable int icnt = 1
	
	if ${ClassRole.healer}
	{
		if ${Group.Count} < 2 && ${Me.HealthPct} < ${fhpctgrp[1]} && ${Me.HealthPct} > 0 && ${HealTimer.TimeLeft} == 0
		{ 
			VGexecute /stopcasting
			Me.ToPawn:Target
			waitframe
			call checkabilitytocast "${InstantHeal}"
			if ${Return}
			{
				call executeability "${InstantHeal}" "Heal" "Neither"
				return
			}
			call checkabilitytocast "${InstantGroupHeal}"
			if ${Return}
			{
				call executeability "${InstantGroupHeal}" "Heal" "Neither"
				return
			}
			return
		}
		elseif ${Group.Count} > 1 && ${HealTimer.TimeLeft} == 0
		{
			waitframe
		
			if ${healneeds.GroupInstantHealNum} > 1 && ${GroupStatus.AOEBuffClose}
			{
				VGexecute /stopcasting
				Me.ToPawn:Target
				waitframe
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantHeal}"
				if ${Return}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					return
				}
				return
			}


			icnt:Set[1]
			do
			{
				If ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${fhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					VGexecute /stopcasting
					Group[${GrpMemberNames[${icnt}]}].ToPawn:Target
					waitframe
					call checkabilitytocast "${InstantHeal}"
					if ${Return}
					{
						call executeability "${InstantHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantGroupHeal}"
					if ${Return}
					{
						call executeability "${InstantGroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}
		}
	}
}
;******************************Change forms/Stances***********************
function changeformstance()
{
	if ${fight.IShouldAttack} && ${doCombatStance} && !${Me.Effect[{CombatStance}](exists)}
		{
		Me.Form[${CombatStance}]:ChangeTo
		}
	if !${fight.IShouldAttack} && ${doNonCombatStance} && !${Me.Effect[{NonCombatStance}](exists)}
		{
		Me.Form[${NonCombatStance}]:ChangeTo
		}	
}
;******************************HealNeeds***********************
objectdef HealNeeds
{
	member:int GroupInstantHealNum()
	{
		variable int icnt = 1
		variable int needint = 0
		
		if !${Group(exists)}
			return 0
			
		do
		{
			if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${gihpctgrp[${icnt}]}
			{
				needint:Inc
			}
		} 
		while ${icnt:Inc} <= ${Group.Count}
		return ${needint}
	}

	member:int GroupHealNum()
	{
		variable int icnt = 1
		variable int needint = 0
		
		if !${Group(exists)}
			return 0
					
		do
		{
			if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${ghpctgrp[${icnt}]}
			{
				needint:Inc
			}
		} 
		while ${icnt:Inc} <= ${Group.Count}
		return ${needint}
	}
}
variable HealNeeds healneeds
 
variable int HOTReady[24]
variable bool usedAbility

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