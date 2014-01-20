
variable string LastSongPlayed = "None"
variable int NextBardCheck = ${Script.RunningTime}

function Bard()
{
	;; return if your class is not a Bard
	if !${Me.Class.Equal[Bard]}
		return

	;; forces this only to run once every 2 seconds
	;if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextBardCheck}]}/1000]}<1
	;{
	;	return
	;}
	;NextBardCheck:Set[${Script.RunningTime}]

	
	;; show the Bard tab in UI
	UIElement[Bard@Class@DPS@Tools]:Show

	;; variables used in this script
	variable bool doPlayCombatSong = FALSE
	variable bool doPlayRestSong = FALSE

	;; Now figure out what we should do
	if ${Me.IsGrouped}
	{
		variable int i
		for (i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc)
		{
			if ${Pawn[ExactName,${Group[${i}].Name}].CombatState}>0
			{
				doPlayCombatSong:Set[TRUE]
				doPlayRestSong:Set[FALSE]
				break
			}
			if ${Group[${i}].Health}<90 || ${Me.EnergyPct}<90
			{
				doPlayRestSong:Set[TRUE]
			}
		}
	}
	else
	{
		call OkayToAttack
		if ${Return} || ${Me.InCombat}
		{
			doPlayCombatSong:Set[TRUE]
			doPlayRestSong:Set[FALSE]
		}
		if ${Me.HealthPct}<90 || ${Me.EnergyPct}<90
		{
			doPlayRestSong:Set[TRUE]
		}
	}
	
	;; do we want to play our Combat Song?
	if ${doPlayCombatSong}
	{
		if ${LastSongPlayed.NotEqual[CombatSong]} && ${Me.EnergyPct}>35
		{
			LastSongPlayed:Set[CombatSong]
			call PlayCombatSong
		}
		if ${Me.EnergyPct}>5
			return
		doPlayRestSong:Set[TRUE]
	}
	
	;; do we want to play our Rest Song?
	if ${doPlayRestSong}
	{
		if ${LastSongPlayed.NotEqual[RestSong]}
		{
			LastSongPlayed:Set[RestSong]
			call PlayRestSong
		}
		return
	}

	;; lets play our Travel Song
	if ${LastSongPlayed.NotEqual[TravelSong]}
	{
		LastSongPlayed:Set[TravelSong]
		call PlayTravelSong
	}
}

;================================================
function PlayCombatSong()
{
	variable int i
	variable bool EquipedPrimary = FALSE 
	variable bool EquipedSecondary = FALSE 
	variable bool EquipedTwoHands = FALSE 

	if ${Me.Inventory[${PrimaryWeapon}](exists)}
	{
		if ${Me.Inventory[${PrimaryWeapon}].DefaultEquipSlot.Equal[Two Hands]} && !${PrimaryWeapon.Equal["${Me.Inventory[CurrentEquipSlot,"Two hands"]}"]}
		{
			VGExecute /wear \"${PrimaryWeapon}\"
			EquipedTwoHands:Set[TRUE]
		}
		else
			if ${Me.Inventory[${PrimaryWeapon}].DefaultEquipSlot.Equal[Primary Hand]} && !${PrimaryWeapon.Equal["${Me.Inventory[CurrentEquipSlot,"Primary Hand"]}"]}
			{
				VGExecute /wear \"${PrimaryWeapon}\" primaryhand
				EquipedPrimary:Set[TRUE]
			}
	}

	if ${Me.Inventory[${SecondaryWeapon}](exists)}
	{
		if ${Me.Inventory[${SecondaryWeapon}].DefaultEquipSlot.Equal[Two Hands]} && !${SecondaryWeapon.Equal["${Me.Inventory[CurrentEquipSlot,"Two hands"]}"]}
		{
			VGExecute /wear \"${SecondaryWeapon}\" 
			EquipedTwoHands:Set[TRUE]
		}
		else
			if ${Me.Inventory[${SecondaryWeapon}].DefaultEquipSlot.Equal[Primary Hand]} && !${SecondaryWeapon.Equal["${Me.Inventory[CurrentEquipSlot,"Secondary Hand"]}"]}
			{
				VGExecute /wear \"${SecondaryWeapon}\" secondaryhand
				EquipedSecondary:Set[TRUE]
			}
	}

	if ${EquipedPrimary}
	{
		i:Set[0]
		do
		{
			wait 1
			if ${i:Inc}>=10
				break
		}
		while !${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)}
	}
	if ${EquipedSecondary}
	{
		i:Set[0]
		do
		{
			wait 1
			if ${i:Inc}>=10
				break
		}
		while !${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
	}
	if ${EquipedTwoHands}
	{
		i:Set[0]
		do
		{
			wait 1
			if ${i:Inc}>=10
				break
		}
		while !${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
	}
	
	;at this point proper weapons should be equipped, now play our song
	if !${Me.Effect[${Me.FName}'s Bard Song - \"${CombatSong}\"](exists)}
	{
		Songs[${CombatSong}]:Perform
		wait 30 ${Me.Effect[${Me.FName}'s Bard Song - \"${CombatSong}\"](exists)}
		wait 10
	}
}

function PlayTravelSong()
{
	if ${Me.Inventory[${TravelInstrument}](exists)}
	{
		if (${TravelInstrument.NotEqual["${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}"]})
		{
			VGExecute /wear \"${TravelInstrument}\" 
			i:Set[0]
			do
			{
				wait 1
				if ${i:Inc}>=10
					break
			}
			while !${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
		}
	}

	;at this point proper weapons should be equipped, now play our song
	if !${Me.Effect[${Me.FName}'s Bard Song - \"${TravelSong}\"](exists)}
	{
		Songs[${TravelSong}]:Perform
		wait 30 ${Me.Effect[${Me.FName}'s Bard Song - \"${TravelSong}\"](exists)}
		wait 10
	}
}

function PlayRestSong()
{
	if ${Me.Inventory[${RestInstrument}](exists)}
	{
		if (${RestInstrument.NotEqual["${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}"]})
		{
			VGExecute /wear \"${RestInstrument}\" 
			i:Set[0]
			do
			{
				wait 1
				if ${i:Inc}>=10
					break
			}
			while !${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
		}
	}

	;at this point proper weapons should be equipped, now play our song
	if !${Me.Effect[${Me.FName}'s Bard Song - \"${RestSong}\"](exists)}
	{
		Songs[${RestSong}]:Perform
		wait 30 ${Me.Effect[${Me.FName}'s Bard Song - \"${RestSong}\"](exists)}
		wait 10
	}
}

function unequipbarditems()
{
	if ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
		Me.Inventory[CurrentEquipSlot,"Two Hands"]:Unequip
	if ${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)}
		Me.Inventory[CurrentEquipSlot,"Primary Hand"]:Unequip
	if ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
		Me.Inventory[CurrentEquipSlot,"Secondary Hand"]:Unequip
	wait 50 !${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)} && !${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)} && !${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
}
