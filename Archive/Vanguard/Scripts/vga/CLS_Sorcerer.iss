;********************************************
function Sorcerer_DownTime()
{

}
;********************************************
function Sorcerer_PreCombat()
{

}
;********************************************
function Sorcerer_Opener()
{

}
;********************************************
function Sorcerer_Combat()
{

}
;********************************************
function Sorcerer_Emergency()
{

}
;********************************************
function Sorcerer_PostCombat()
{

}
;********************************************
function Sorcerer_PostCasting()
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
;********************************************
function Sorcerer_Burst()
{
	DoBurstNow:Set[FALSE]
}


