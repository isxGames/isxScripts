
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
	if ${Me.Inventory[${PrimaryWeapon}](exists)}
	{
		if (${PrimaryWeapon.NotEqual[${Me.Inventory[CurrentEquipSlot,"Primary Hand"].Name}]}) || (${SecondaryWeapon.NotEqual[${Me.Inventory[CurrentEquipSlot,"Secondary Hand"].Name}]})
		{
			;vgecho PrimaryWeapon=[${PrimaryWeapon}], SecondaryWeapon=[${SecondaryWeapon}]
			;vgecho Equiped: Primary=[${Me.Inventory[CurrentEquipSlot,"Primary Hand"].Name}], Secondary=[${Me.Inventory[CurrentEquipSlot,"Secondary Hand"].Name}], Two Hands=[${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}]

			;first unequip any items
			;call unequipbarditems

			Me.Inventory[ExactName,"${PrimaryWeapon}"]:Equip
			;wait 2
			;wait 10 ${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)}

			if ${PrimaryWeapon.Equal[${SecondaryWeapon}]}
			{
				;need to loop through and find this item that is 'not' in Primary Hand
				for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
				if (${SecondaryWeapon.Equal[${Me.Inventory[${i}].Name}]}) && (${String["Primary Hand"].NotEqual[${Me.Inventory[${i}].CurrentEquipSlot}]})
				{
					Me.Inventory[${i}]:Equip
					;wait 1
					;wait 10 ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
				}
			}
			else
			{
				Me.Inventory[ExactName,"${SecondaryWeapon}"]:Equip
				;wait 1
				;wait 10 ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
			}
			wait 2
		}
	}

	;at this point proper weapons should be equipped, now play our song
	Songs[${CombatSong}]:Perform
}

function PlayTravelSong()
{
	if ${Me.Inventory[${TravelInstrument}](exists)}
	{
		if (${TravelInstrument.NotEqual[${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}]})
		{
			;first unequip any items
			;call unequipbarditems
			Me.Inventory[ExactName,"${TravelInstrument}"]:Equip
			wait 2
			;wait 10 ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
		}
	}

	;at this point proper weapons should be equipped, now play our song
	Songs[${TravelSong}]:Perform
}

function PlayRestSong()
{
	if ${Me.Inventory[${RestInstrument}](exists)}
	{
		if (${RestInstrument.NotEqual[${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}]})
		{
			;first unequip any items
			;call unequipbarditems
			Me.Inventory[ExactName,"${RestInstrument}"]:Equip
			wait 2
			;wait 10 ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
		}
	}

	;at this point proper weapons should be equipped, now play our song
	Songs[${RestSong}]:Perform
}

function unequipbarditems()
{
	if ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
	{
		Me.Inventory[CurrentEquipSlot,"Two Hands"]:Unequip
		wait 2
	}
	if ${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)}
	{
		Me.Inventory[CurrentEquipSlot,"Primary Hand"]:Unequip
		wait 2
	}
	if ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
	{
		Me.Inventory[CurrentEquipSlot,"Secondary Hand"]:Unequip
		wait 2
	}
}
