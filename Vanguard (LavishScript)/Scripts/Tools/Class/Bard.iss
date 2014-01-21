
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

	
	;; Now figure out what we should do
	if ${Me.IsGrouped}
	{
		variable int i
		for (i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc)
		{
			if ${Pawn[ExactName,${Group[${i}].Name}].CombatState}>0 || ${Pawn[Name,${Tank}].CombatState}>0 || ${Me.Encounter}>0
			{
				call PlayCombatSong
				return
			}
			elseif ${Group[${i}].Health}<85 || ${Me.EnergyPct}<85
			{
				call PlayRestSong
				return
			}
		}
		call PlayTravelSong
		return
	}
	else
	{
		call OkayToAttack
		if ${Return} || ${Me.InCombat} || ${Me.Encounter}>0
		{
			call PlayCombatSong
			return
		}
		if ${Me.HealthPct}<85 || ${Me.EnergyPct}<85
		{
			call PlayRestSong
			return
		}
		call PlayTravelSong
		return
		
	}
}

;================================================
function PlayCombatSong()
{
	;; no need to go any further if song is already playing
	if ${Me.Effect[${Me.FName}'s Bard Song - \"${CombatSong}\"](exists)}
		return
		
	echo Combat song

	;; play our song
	Songs[${CombatSong}]:Perform
	wait 10
	
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
}

function PlayTravelSong()
{
	;; no need to go any further if song is already playing
	if ${Me.Effect[${Me.FName}'s Bard Song - \"${TravelSong}\"](exists)}
		return
		
	echo Travel Song
	
	;; play our song
	Songs[${TravelSong}]:Perform
	wait 10
	
	;; equip our instrument
	if ${Me.Inventory[${TravelInstrument}](exists)}
	{
		if ${TravelInstrument.NotEqual["${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}"]}
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
}

function PlayRestSong()
{
	;; no need to go any further if song is already playing
	if !${Me.Effect[${Me.FName}'s Bard Song - \"${RestSong}\"](exists)}
		return

	;; play our song
	Songs[${RestSong}]:Perform
	wait 10

	;; equip our instrument
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
