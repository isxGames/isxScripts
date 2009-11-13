/* REGEN MANA */
function:bool RegenMana()
{
	if ${Me.HealthPct}>${AttackHealRatio} && ${Me.EnergyPct}<85
	{
		call UseAbility "${MentalTransmutation}"
		if ${Return}
			return TRUE
	}
	return FALSE
}
