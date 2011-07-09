;*************************************************************
function ResUp()
{

	if ${Me.InCombat} && ${DoResInCombat} && ${Group.Count} < 7
	{
		call CombatRes
	}
	if !${Me.InCombat} && ${DoResNotInCombat} && ${Group.Count} < 7
	{
		call NonCombatRes
	}
	if ${Me.InCombat} && ${DoResInCombat} && ${DoResRaid} && ${Group.Count} > 6
	{
		call CombatRes
	}
	if !${Me.InCombat} && ${DoResNotInCombat} && ${DoResRaid} && ${Group.Count} > 6
	{
		call NonCombatRes
	}

}
;*************************************************************
function CombatRes()
{
	variable int L
	for ( L:Set[1] ; ${Group[${L}].ID(exists)} ; L:Inc )
	{
		if ${Pawn[${Group[${L}]}].IsDead} && ${Group[${L}].Distance} < 20
		{
			Pawn[${Group[${L}]}]:Target
			wait 5
			call checkabilitytocast "${CombatRes}"
			if ${Return}
			{
				call executeability "${CombatRes}" "Heal" "Both"
				GroupNeedsBuffs:Set[TRUE]
			}
		}

	}
}
;*************************************************************
function NonCombatRes()
{
	variable int L
	for ( L:Set[1] ; ${Group[${L}].ID(exists)} ; L:Inc )
	{
		if ${Pawn[${Group[${L}]}].IsDead} && ${Group[${L}].Distance} < 20
		{
			Pawn[${Group[${L}]}]:Target
			wait 5
			call checkabilitytocast "${NonCombatRes}"
			if ${Return}
			{
				call executeability "${NonCombatRes}" "Heal" "Both"
				GroupNeedsBuffs:Set[TRUE]
			}
		}

	}
}

