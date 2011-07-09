
;********************************************
function TSLoot()
{
	wait 20
	if ${Pawn[Tombstone](exists)}
	{
		variable int iCount
		do
		{
			if ${Pawn[${iCount}].Name.Find[Tombstone]} && ${Pawn[${iCount}].Name.Find[${Me}]}
			{
				VGExecute /targetm
				wait 4
				if ${Pawn[${iCount}].Distance} > 5 && ${Pawn[${iCount}].Distance} < 21
				{
					VGExecute /cor
				}
				VGExecute /Lootall
				waitframe
				VGExecute "/cleartargets"
			}
		}
		while ${iCount:Inc} <= ${VG.PawnCount}
	}
}


