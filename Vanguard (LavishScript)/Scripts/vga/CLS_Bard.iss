;********************************************
function Bard_DownTime()
{
	If !${fight.ShouldIAttack} && !${Me.Effect[${Me.FName}'s Bard Song - "${RunSong}"](exists)}
	{
		Me.Inventory[${Drum}]:Equip
		wait 3
		Songs[${RunSong}]:Perform
	}
	If !${Me.Effect[Humming Blade VII](exists)}
	{
		call checkabilitytocast "Humming Blade VII"
		if ${Return}
		{
			call executeability "Humming Blade VII" "Buff" "Neither"
		}
	}
}
;*******************************************
function Bard_PreCombat()
{

}
;********************************************
function Bard_Opener()
{
	If ${fight.ShouldIAttack} && !${Me.Effect[${Me.FName}'s Bard Song - "${FightSong}"](exists)}
	{
		Me.Inventory[${Drum}]:Unequip
		wait 5
		If !${Me.Inventory[${PrimaryWeapon}].CurrentEquipSlot.Equal[Primary Hand]}
		{
			Me.Inventory[${PrimaryWeapon}]:Equip[Primary Hand]
			wait 4
		}
		If !${Me.Inventory[${SecondaryWeapon}].CurrentEquipSlot.Equal[Secondary Hand]}
		{
			Me.Inventory[${SecondaryWeapon}]:Equip[Secondary Hand]
			wait 5
		}
		Songs[${FightSong}]:Perform
	}
	If !${Me.Inventory[${PrimaryWeapon}].CurrentEquipSlot.Equal[Primary Hand]}
	{
		Me.Inventory[${PrimaryWeapon}]:Equip[Primary Hand]
		wait 4
	}
	If !${Me.Inventory[${SecondaryWeapon}].CurrentEquipSlot.Equal[Secondary Hand]}
	{
		Me.Inventory[${SecondaryWeapon}]:Equip[Secondary Hand]
		wait 5
	}
	call checkabilitytocast "Eaon's Booming Bellow"
	if ${Return} && ${Me.EnergyPct} > 50
	{
		call executeability "Eaon's Booming Bellow" "Attack" "both"
	}
	call checkabilitytocast "Eaon's Superior Blasting Bellow"
	if ${Return} && ${Me.EnergyPct} > 50
	{
		call executeability "Eaon's Superior Blasting Bellow" "Attack" "both"
	}

}
;********************************************
function Bard_Combat()
{
	if ${Me.TargetHealth} < 15
	{
		call checkabilitytocast "Fox Overtakes the Hare III"
		if ${Return}
		{
			debuglog "Should Cast Fox Overtakes the Hare III"
			call executeability "Fox Overtakes the Hare III" "attack" "Both"
		}
	}
	call checkabilitytocast "Shatter the Mountain II"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Shatter the Mountain II" "Attack" "both"
	}
	call checkabilitytocast "Cleave the Mountain IV"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Cleave the Mountain IV" "Attack" "both"
	}
	call checkabilitytocast "Erosive Hew"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Erosive Hew" "Attack" "both"
	}
	call checkabilitytocast "Striking the Mountain VI"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Striking the Mountain VI" "Attack" "both"
	}
	call checkabilitytocast "Eaon's Superior Blasting Bellow"
	if ${Return} && ${Me.EnergyPct} > 50 && !${Me.TargetDebuff[Eaon's Superior Blasting Bellow](exists)}
	{
		call executeability "Eaon's Superior Blasting Bellow" "Attack" "both"
	}
	call checkabilitytocast "Superior Razor Parts Silk"
	if ${Return} && ${Me.EnergyPct} > 50 && !${Me.TargetDebuff[Superior Razor Parts Silk](exists)}
	{
		call executeability "Superior Razor Parts Silk" "Attack" "both"
	}
	call checkabilitytocast "Thread the Needle V"
	if ${Return} && ${Me.EnergyPct} > 50 && !${Me.TargetDebuff[Thread the Needle V](exists)}
	{
		call executeability "Thread the Needle V" "Attack" "both"
	}
	call checkabilitytocast "Kedon's Critical Severing"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Kedon's Critical Severing" "Attack" "both"
	}
}
;********************************************
function Bard_Emergency()
{

}
;********************************************
function Bard_PostCombat()
{

}
;********************************************
function Bard_PostCasting()
{

}
;********************************************
function Bard_Burst()
{
	call checkabilitytocast "Bladedancer's Focus"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Bladedancer's Focus" "Buff" "Neither"
	}
	call checkabilitytocast "Quickening Jolt"
	if ${Return} && ${fight.ShouldIAttack}
	{
		Me.Ability["Quickening Jolt"]:Use
	}
	call checkabilitytocast "Singing Blade"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Quickening Jolt" "Buff" "Neither"
	}
	If !${Me.Effect[Humming Blade VII](exists)}
	{
		call checkabilitytocast "Humming Blade VII"
		if ${Return}
		{
			call executeability "Humming Blade VII" "Buff" "Neither"
		}
	}
	call checkabilitytocast "Lightning on the Mountaintops"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Lightning on the Mountaintops" "Attack" "Neither"
	}
	call checkabilitytocast "Humming Bird Darts In VI"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Humming Bird Darts In VI" "Attack" "Neither"
	}
	call checkabilitytocast "Shatter the Mountain II"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Shatter the Mountain II" "Attack" "Neither"
	}
	call checkabilitytocast "Cleave the Mountain IV"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Cleave the Mountain IV" "Attack" "Neither"
	}
	call checkabilitytocast "Erosive Hew"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Erosive Hew" "Attack" "Neither"
	}
	call checkabilitytocast "Striking the Mountain VI"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Striking the Mountain VI" "Attack" "Neither"
	}

	DoBurstNow:Set[FALSE]
	actionlog "End Burst Damage"
}


