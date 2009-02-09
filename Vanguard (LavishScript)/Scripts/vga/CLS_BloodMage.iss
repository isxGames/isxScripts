;********************************************
function BM_DownTime()
{
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

function BM_CheckEnergy()
{
	if (${Me.EnergyPct} > 80)
		return
	if !${Me.Ability[${BMHealthToEnergySpell}].IsReady}
		return	
	
	if ${Me.HealthPct} > 50
	{
		Me.Ability[${BMHealthToEnergySpell}]:Use
		if ${Me.ToPawn.CombatState} != 1
		{
			do
			{
				waitframe
			}
			while ${Me.IsCasting}
		}
		return
	}
	if ${Me.EnergyPct} < 50 && ${Me.HealthPct} > 35
	{
		Me.Ability[${BMHealthToEnergySpell}]:Use
		if ${Me.ToPawn.CombatState} != 1
		{
			do
			{
				waitframe
			}
			while ${Me.IsCasting}
		}
		return
	}
	;; TODO -- Make the final value in this next line UI settable (ie, "Never cast if health is lower than: xxx")
	if ${Me.EnergyPct} < 20 && ${Me.Health} > 300
	{
		Me.Ability[${BMHealthToEnergySpell}]:Use
		if ${Me.ToPawn.CombatState} != 1
		{
			do
			{
				waitframe
			}
			while ${Me.IsCasting}
		}
		return
	}
	
}