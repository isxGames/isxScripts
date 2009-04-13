;********************************************
function SorcererMana()
{
	If ${Me.Ability[Gather Energy].IsReady} && ${Me.InCombat} && ${Me.Endurance}<60 && ${Me.EnergyPct} < 10
			{
			Me.Ability[Gather Energy]:Use
			wait 200
			}
	
	If ${Me.Ability[Gather Energy].IsReady} && ${Me.InCombat} && ${Me.Endurance}>60 && ${Me.EnergyPct} < 10
			{
			Me.Ability[Gather Energy]:Use
			wait 200
			}
}
