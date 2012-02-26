variable int StartingLooterCoin
variable int GainedLooterCoin
variable int CurrentLooterCoin

function main()
{
	echo ${Time}: Starting BJ Looter
	
	StartingLooterCoin:Set[${Math.Calc[(${Me.Platinum}*1000000)+(${Me.Gold}*10000)+(${Me.Silver}*100)+${Me.Copper}]}]
	
	DisplayLooterSmall:Set[0]
	DisplayLooterTreasure:Set[0]
	DisplayLooterOrnate:Set[0]
	DisplayLooterExquisite:Set[0]
	
	DisplayLooterCopper:Set[0]
	DisplayLooterSilver:Set[0]
	DisplayLooterGold:Set[0]
	DisplayLooterPlatinum:Set[0]
	
	while 1
	{
		while ${LooterPause} == FALSE
		{
			if ${Actor[chest,"Exquisite Chest"](exists)} && ${UIElement[${EnableExquisiteChestCheckboxVar}].Checked} && ${Actor[chest,"Exquisite Chest"].Distance} <= ${ScanRangeTextEntry}
			{
				echo ${Time}:  Exquisite Chest Found...
				
				face "Exquisite Chest"
				wait 10
				
				if ${Actor[chest,"Exquisite Chest"].Distance} > 2
				{
					echo ${Time}:  Attempting to move to chest
					
					while ${Actor[chest,"Exquisite Chest"].Distance} > 2
					{
						eq2press -hold w
						face "Exquisite Chest"
					}
					eq2press -release w
					echo ${Time}:  Arrived at chest.  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Exquisite Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterExquisite:Inc
					wait 10
				}
				else
				{
					echo ${Time}:  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Exquisite Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterExquisite:Inc
					wait 10
				}
			}
			elseif ${Actor[chest,"Ornate Chest"](exists)} && ${UIElement[${EnableOrnateChestCheckboxVar}].Checked} && ${Actor[chest,"Ornate Chest"].Distance} <= ${ScanRangeTextEntry}
			{
				echo ${Time}:  Ornate Chest Found...
			
				face "Ornate Chest"
				wait 10
				
				if ${Actor[chest,"Ornate Chest"].Distance} > 2
				{
					echo ${Time}:  Attempting to move to chest
				
					while ${Actor[chest,"Ornate Chest"].Distance} > 2
					{
						eq2press -hold w
						face "Ornate Chest"
					}
					eq2press -release w
					echo ${Time}:  Arrived at chest.  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Ornate Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterOrnate:Inc
					wait 10
				}
				else
				{
					echo ${Time}:  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Ornate Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterOrnate:Inc
					wait 10
				}
			}
			elseif ${Actor[chest,"Treasure Chest"](exists)} && ${UIElement[${EnableTreasureChestCheckboxVar}].Checked} && ${Actor[chest,"Treasure Chest"].Distance} <= ${ScanRangeTextEntry}
			{
				echo ${Time}:  Treasure Chest Found...
			
				face "Treasure Chest"
				wait 10
				
				if ${Actor[chest,"Treasure Chest"].Distance} > 2
				{
					echo ${Time}:  Attempting to move to chest
				
					while ${Actor[chest,"Treasure Chest"].Distance} > 2
					{
						eq2press -hold w
						face "Treasure Chest"
					}
					eq2press -release w
					echo ${Time}:  Arrived at chest.  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Treasure Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterTreasure:Inc
					wait 10
				}
				else
				{
					echo ${Time}:  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Treasure Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterTreasure:Inc
					wait 10
				}
			}
			elseif ${Actor[chest,"Small Chest"](exists)} && ${UIElement[${EnableSmallChestCheckboxVar}].Checked} && ${Actor[chest,"Small Chest"].Distance} <= ${ScanRangeTextEntry}
			{
				echo ${Time}:  Small Chest Found...
			
				face "Small Chest"
				wait 10
				
				if ${Actor[chest,"Small Chest"].Distance} > 2
				{
					echo ${Time}:  Attempting to move to chest
				
					while ${Actor[chest,"Small Chest"].Distance} > 2
					{
						eq2press -hold w
						face "Small Chest"
					}
					eq2press -release w
					echo ${Time}:  Arrived at chest.  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Small Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterSmall:Inc
					wait 10
				}
				else
				{
					echo ${Time}:  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Small Chest].ID} Open"
					wait 10
					call LootedCoin
					wait 10
					DisplayLooterSmall:Inc
					wait 10
				}
			}
			elseif ${Actor[npc,"corpse"](exists)} && ${UIElement[${EnableLootBodyCheckboxVar}].Checked} && ${Actor[npc,"corpse"].Distance} <= ${ScanRangeTextEntry}
			{
	;//			echo ${Time}:  Corpse Found...
			
				face corpse
				wait 10
				
				if ${Actor[npc,"corpse"].Distance} > 2
				{
	;//				echo ${Time}:  Attempting to move to corpse
				
					while ${Actor[npc,"corpse"].Distance} > 2
					{
						eq2press -hold w
						face corpse
					}
					eq2press -release w
	;//				echo ${Time}:  Arrived at corpse.  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Corpse].ID} Loot"
					wait 10
					call LootedCoin
					wait 10
				}
				else
				{
	;//				echo ${Time}:  Trying to loot.
					EQ2execute "/apply_verb ${Actor[Corpse].ID} Loot"
					wait 10
					call LootedCoin
					wait 10
				}
			}
			else
			{
				if ${SetHomePoint} == TRUE
				{
					if ${Math.Distance[${Me.ToActor.Loc},${HomePointLocation}]} > 3
					{
						while ${Math.Distance[${Me.ToActor.Loc},${HomePointLocation}]} > 3
						{
							face ${HomePointLocation.X} ${HomePointLocation.Z}
							eq2press -hold w
						}
						eq2press -release w
						wait 10
					}
				}
			}
		}
		waitframe
	}	
}

function LootedCoin()
{
;//		StartingLooterCoin:Set[${Math.Calc[(${Me.Platinum}*1000000)+(${Me.Gold}*10000)+(${Me.Silver}*100)+${Me.Copper}]}]
;//	echo StartingLooterCoin: ${StartingLooterCoin}
	
		CurrentLooterCoin:Set[${Math.Calc[(${Me.Platinum}*1000000)+(${Me.Gold}*10000)+(${Me.Silver}*100)+${Me.Copper}]}]
;//		echo CurrentLooterCoin: ${CurrentLooterCoin}
		GainedLooterCoin:Set[${Math.Calc[${CurrentLooterCoin}-${StartingLooterCoin}]}]
;//		echo GainedLooterCoin: ${GainedLooterCoin}
		
		DisplayLooterCopper:Set[${Math.Calc[${GainedLooterCoin}%100]}]
		DisplayLooterSilver:Set[${Math.Calc[${GainedLooterCoin}/100%100]}]
		DisplayLooterGold:Set[${Math.Calc[${GainedLooterCoin}/10000%100]}]
		DisplayLooterPlatinum:Set[${Math.Calc[${GainedLooterCoin}/10000\\100]}]
		
;//		echo P = ${DisplayLooterPlatinum.LeadingZeroes[2]} G = ${DisplayLooterGold.LeadingZeroes[2]} S = ${DisplayLooterSilver.LeadingZeroes[2]} C = ${DisplayLooterCopper.LeadingZeroes[2]}
	
}

function atexit()
{
	echo ${Time}:  Stopping BJ Looter
}