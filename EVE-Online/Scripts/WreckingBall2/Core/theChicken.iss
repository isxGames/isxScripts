objectdef theChicken
{

	member:string Safe()
	{
		if ${ChickenOnTank}
		{
			if SHIELD < 74
				return "ChickenOnTank"
		}
		if ${ChickenOnRat}
		{
			if ${Entity[Name =- "Mission"](exists)}
				return "ChickenOnRat"
			if ${Entity[Name =- "Deadspace"](exists)}
				return "ChickenOnRat"
		}
		if ${ChickenOnPirate}
		{
			if ${Entity[CategoryID = "6"](exists)}
				return "ChickenOnPirate"
		}
		if ${ChickenOnTargeted}
		{
			if TARGETEDBY > 0
				return "ChickenOnTargeted"
		}
		return "Null"
	}
	
	function DoChicken(string SafeSpot, string Reason)
	{
		State:Set[Chickening]
		call Ship.Goto ${SafeSpot}
		echo "Wrecking Bot Chickened because of ${Reason}"
		endscript wreckingball2
	}
}