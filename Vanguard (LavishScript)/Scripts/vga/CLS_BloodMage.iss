;********************************************
function BM_DownTime()
{
	;; This function should only be called outside of combat (ie, 'downtime')
	
	if ${Me.HealthPct} < 70
	{
		Me.ToPawn:Target
		waitframe
		call checkabilitytocast "${SmallHeal}"
		if ${Return}
		{
			call executeability "${SmallHeal}" "Heal" "Neither"
			return
		}	
	}	
	
}

function BM_CheckBloodUnion()
{
	;; For now...
	if ${Me.BloodUnion} < 4
		return
	

	;; In Combat
	if (${Me.InCombat} || ${Me.ToPawn.CombatState} != 0)
	{
		switch ${Me.BloodUnion}
		{
			case 5
			case 4
				call executeability "${Me.Ability[${BMBloodUnionDumpDPSSpell}].Name}" "NoCheck" "Neither"
				return
			
			default
				break
		}
	}
	
	return
}

function BM_CheckEnergy()
{
	if (${Me.EnergyPct} > 80)
		return
	if !${Me.Ability[${BMHealthToEnergySpell}].IsReady}
		return	
	
	if ${Me.HealthPct} > 50
	{
		call executeability "${Me.Ability[${BMHealthToEnergySpell}].Name}" "utility" "Neither"
		return
	}
	if ${Me.EnergyPct} < 50 && ${Me.HealthPct} > 35
	{
		call executeability "${Me.Ability[${BMHealthToEnergySpell}].Name}" "utility" "Neither"
		return
	}
	;; TODO -- Make the final value in this next line UI settable (ie, "Never cast if health is lower than: xxx")
	if ${Me.EnergyPct} < 20 && ${Me.Health} > 300
	{
		call executeability "${Me.Ability[${BMHealthToEnergySpell}].Name}" "utility" "Neither"
		return
	}
	
}