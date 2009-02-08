function Healcheck()
{
	if ${ClassRole.healer}
	{
		if ${Group.Count} < 2 && ${HealTimer.TimeLeft} == 0
		{
			waitframe

			;; Note:  [1] is always "Me"

			if ${Me.HealthPct} < ${fhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
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
			if ${Me.HealthPct} < ${hpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
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
			if ${Me.HealthPct} < ${bhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
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
					call executeability "${HotHeal}" "Heal" "Neither"
					return
				}
				return
			}
			if ${Me.HealthPct} < ${hhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
				waitframe
				call checkabilitytocast "${HotHeal}"
				if ${Return}
				{
					call executeability "${HotHeal}" "Heal" "Neither"
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
				Group[1].ToPawn:Target
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


			icnt:Set[2]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${fhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
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

			if ${healneeds.GroupHealNum} > 1 && ${healrefresh} && ${GroupStatus.AOEBuffClose}
			{
				healrefresh:Set[FALSE]
				Group[1].ToPawn:Target
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

			icnt:Set[2]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${hpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
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
	
			icnt:Set[2]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${bhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
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
						call executeability "${HotHeal}" "Heal" "Neither"
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}
		
			icnt:Set[2]
			do
			{
				if ${hgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} < ${hhpctgrp[${icnt}]} && ${Group[${GrpMemberNames[${icnt}]}].Health} > 0 && ${Group[${GrpMemberNames[${icnt}]}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
					waitframe
					call checkabilitytocast "${HotHeal}"
					if ${Return}
					{
						call executeability "${HotHeal}" "Heal" "Neither"
						return
					}
					return
				}
			} 
			while ${icnt:Inc} <= ${Group.Count}
			
			
			;; Why is this here and not in the PostCastingActions() function?  It won't get called when a heal is cast anyway
			;; since all of the 'executability' calls above are followed by a "return"...
			if ${MyClass.Equal[Shaman]}
			{
				call shamanmana
			}
			
			
			return
		}
	}

}
;**********************************************
function checkinstantheal()
{
	if ${ClassRole.healer}
	{
	If ${Me.HealthPct} < ${fhpctgrp[1]} && ${Me.HealthPct} > 0 && ${Group.Count} < 2 && ${HealTimer.TimeLeft} == 0 && ${Group[${icnt}].Distance} < 25
			{ 
			VGexecute /stopcasting
			Pawn[Me]:Target
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

	if ${Group.Count} > 1 && ${HealTimer.TimeLeft} == 0 && ${Group[${icnt}].Distance} < 25
	{
	waitframe
	variable int icnt

	If ${healneeds.GroupInstantHealNum} > 1 && ${GroupStatus.AOEBuffClose}
	{
		VGexecute /stopcasting
		Group[1].ToPawn:Target
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
	If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${fhpctgrp[${icnt}]} && ${Group[${icnt}].Health} > 0 && ${Group[${icnt}].Distance} < 25
			{
			VGexecute /stopcasting
			Group[${icnt}].ToPawn:Target
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

;******************************HealNeeds***********************
objectdef HealNeeds
{
	member:int GroupInstantHealNum()
	{
	variable int icnt = 1
	variable int needint = 0
	do
	{
	If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${gihpctgrp[${icnt}]}
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
	do
	{
	If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${ghpctgrp[${icnt}]}
			{
			needint:Inc
			}
	} 
	while ${icnt:Inc} <= ${Group.Count}
	return ${needint}
	}
}
variable HealNeeds healneeds
 
