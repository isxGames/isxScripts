;********************************************
function SorcererMana()
{
	If ${Me.Ability[Gather Energy].IsReady} && ${Me.InCombat} && ${Me.Endurance}<60 && ${Me.EnergyPct} < 10
		{
		While ${Me.Endurance} < 70
			{
			wait 1
			}
		}
	
	If ${Me.Ability[Gather Energy].IsReady} && ${Me.InCombat} && ${Me.Endurance}>60 && ${Me.EnergyPct} < 10
			{
			Me.Ability[Gather Energy]:Use
			while ${Me.Endurance} > 10
			{
			wait 1
			}
			} 
}
