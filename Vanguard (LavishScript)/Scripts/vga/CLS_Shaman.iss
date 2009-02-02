;********************************************
function shamanmana()
{
	if ${Me.EnergyPct}<85 && ${Me.HealthPct}>90 && ${Me.Ability[Ritual of Scarring].IsReady} && ${Pawn[${Me}].CombatState} == 1
   		{
		call executeability "Ritual of Scarring" "Heal" "Neither"
		}
	if ${Me.EnergyPct}<90 && ${Me.HealthPct}>65 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Pawn[${Me}].CombatState} == 1
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
	if ${Me.EnergyPct}<90 && ${Me.HealthPct}>85 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Pawn[${Me}].CombatState} == 0
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
}