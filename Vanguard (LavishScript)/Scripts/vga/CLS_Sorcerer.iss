;********************************************
function SorcererMana()
{
	If ${Me.Ability[Gather Energy].IsReady} && ${Pawn[${Me}].CombatState} == 1 && ${Me.Endurance}<60 && ${Me.EnergyPct} < 10
		{
		While ${Me.Endurance} < 70
			{
			wait 1
			}
		}
	
	If ${Me.Ability[Gather Energy].IsReady} && ${Pawn[${Me}].CombatState} == 1 && ${Me.Endurance}>60 && ${Me.EnergyPct} < 10
			{
			Me.Ability[Gather Energy]:Use
			while ${Me.Endurance} > 10 || ${Me.EnergyPct} < 80
			{		
			wait 1
			}
			} 
}