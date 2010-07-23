function Consumables()
{
	if !${doConsumables}
	{
		return
	}

	;; Regain some Energy
	if ${Me.InCombat} && ${Me.Inventory[Large Mottleberries](exists)} && ${Me.Inventory[Large Mottleberries].IsReady} && ${Me.EnergyPct} < 50 && ${Me.TargetHealth} > 20
	{
		EchoIt "Consumed Large Mottleberries"
		CurrentAction:Set[Consumming Large Mottleberries]
		Me.Inventory[Large Mottleberries]:Use
		wait 1
	}
	
	;; Regain some Health
	if ${Me.HealthPct}<30 && ${Me.Inventory[Great Roseberries](exists)} && ${Me.Inventory[Great Roseberries].IsReady}
	{
		EchoIt "Consumed Great Roseberries"
		CurrentAction:Set[Consumming Great Roseberries]
		Me.Inventory[Great Roseberries]:Use
		wait 1
	}

	;; Use Blood Mage's Conduct to regain some Health
	if ${Me.HealthPct}<30 && ${Me.Ability[Conduct](exists)} && ${Me.Ability[Conduct].TimeRemaining}==0 && ${Me.Ability[Conduct].IsReady}
	{
		EchoIt "Used Conduct to heal self"
		CurrentAction:Set[Conduct - healing self]
		Pawn[Me]:Target
		wait 1
		Me.Ability[Conduct]:Use
		wait 1
	}
}
