
function ConsolidateResources()
{
	if ${Me.InCombat}
	return

	variable int i
	i:Set[0]
	for (i:Set[0] ; ${Me.Inventory[${i:Inc}].Name(exists)} ; )
	{
		if ${Me.Inventory[${i}].Description.Find[resource]} && ${Me.Inventory[${i}].Quantity}==100
		{
			EchoIt "Consolidate: ${Me.Inventory[${i}]}"
			Me.Inventory[${i}]:StartConvert
			wait 10
			VG:ConvertItem
			wait 10
		}
	}
}

