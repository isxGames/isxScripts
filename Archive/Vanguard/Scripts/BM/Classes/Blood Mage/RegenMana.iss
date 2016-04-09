/* REGEN MANA */
function:bool RegenMana()
{
	if ${Me.InCombat} && ${low}>${AttackHealRatio} && ${Me.EnergyPct}<80
	{
		call UseAbility "${MentalTransmutation}"
		if ${Return}
			return TRUE
	}
	if !${Me.InCombat} && ${low}>${AttackHealRatio} && ${Me.EnergyPct}<90
	{
		call UseAbility "${MentalTransmutation}"
		if ${Return}
			return TRUE
	}
	return FALSE
}
