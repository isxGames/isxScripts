;********************************************
function shamanmana()
{
	if ${Me.EnergyPct}<70 && ${Me.HealthPct}>65 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 1
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
	if ${Me.EnergyPct}<90 && ${Me.HealthPct}>85 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 0
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
}