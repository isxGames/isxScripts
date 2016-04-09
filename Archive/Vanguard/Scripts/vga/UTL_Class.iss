;===================================================
;===     Class Specific Pre Combat Loop         ====
;===================================================
function Class_PreCombat()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_PreCombat
		break
	case Warrior
		call Warrior_PreCombat
		break
	case Paladin
		call Paladin_PreCombat
		break
	case Bard
		call Bard_PreCombat
		break
	case Monk
		call Monk_PreCombat
		break
	case Ranger
		call Ranger_PreCombat
		break
	case Rogue
		call Rogue_PreCombat
		break
	case Blood Mage
		call BloodMage_PreCombat
		break
	case Cleric
		call Cleric_PreCombat
		break
	case Shaman
		call Shaman_PreCombat
		break
	case Disciple
		call Disciple_PreCombat
		break
	case Druid
		call Druid_PreCombat
		break
	case Necromancer
		call Necromancer_PreCombat
		break
	case Psionicist
		call Psionicist_PreCombat
		break
	case Sorcerer
		call Sorcerer_PreCombat
		break
	}

	return
}
;===================================================
;===         Class Specific Opener            ====
;===================================================
function Class_Opener()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_Opener
		break
	case Warrior
		call Warrior_Opener
		break
	case Paladin
		call Paladin_Opener
		break
	case Bard
		call Bard_Opener
		break
	case Monk
		call Monk_Opener
		break
	case Ranger
		call Ranger_Opener
		break
	case Rogue
		call Rogue_Opener
		break
	case Blood Mage
		call BloodMage_Opener
		break
	case Cleric
		call Cleric_Opener
		break
	case Shaman
		call Shaman_Opener
		break
	case Disciple
		call Disciple_Opener
		break
	case Druid
		call Druid_Opener
		break
	case Necromancer
		call Necromancer_Opener
		break
	case Psionicist
		call Psionicist_Opener
		break
	case Sorcerer
		call Sorcerer_Opener
		break
	}

	return
}
;===================================================
;===     Class Specific Combat Loop        ====
;===================================================
function Class_Combat()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_Combat
		break
	case Warrior
		call Warrior_Combat
		break
	case Paladin
		call Paladin_Combat
		break
	case Bard
		call Bard_Combat
		break
	case Monk
		call Monk_Combat
		break
	case Ranger
		call Ranger_Combat
		break
	case Rogue
		call Rogue_Combat
		break
	case Blood Mage
		call BloodMage_Combat
		break
	case Cleric
		call Cleric_Combat
		break
	case Shaman
		call Shaman_Combat
		break
	case Disciple
		call Disciple_Combat
		break
	case Druid
		call Druid_Combat
		break
	case Necromancer
		call Necromancer_Combat
		break
	case Psionicist
		call Psionicist_Combat
		break
	case Sorcerer
		call Sorcerer_Combat
		break
	}
	return
}
;===================================================
;===     Class Specific Post Combat Loop        ====
;===================================================
function Class_PostCombat()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_PostCombat
		break
	case Warrior
		call Warrior_PostCombat
		break
	case Paladin
		call Paladin_PostCombat
		break
	case Bard
		call Bard_PostCombat
		break
	case Monk
		call Monk_PostCombat
		break
	case Ranger
		call Ranger_PostCombat
		break
	case Rogue
		call Rogue_PostCombat
		break
	case Blood Mage
		call BloodMage_PostCombat
		break
	case Cleric
		call Cleric_PostCombat
		break
	case Shaman
		call Shaman_PostCombat
		break
	case Disciple
		call Disciple_PostCombat
		break
	case Druid
		call Druid_PostCombat
		break
	case Necromancer
		call Necromancer_PostCombat
		break
	case Psionicist
		call Psionicist_PostCombat
		break
	case Sorcerer
		call Sorcerer_PostCombat
		break
	}

	return
}
;===================================================
;===  Class Specific Emergency Casting Loop        ====
;===================================================
function Class_Emergency()
{

	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_Emergency
		break
	case Warrior
		call Warrior_Emergency
		break
	case Paladin
		call Paladin_Emergency
		break
	case Bard
		call Bard_Emergency
		break
	case Monk
		call Monk_Emergency
		break
	case Ranger
		call Ranger_Emergency
		break
	case Rogue
		call Rogue_Emergency
		break
	case Blood Mage
		call BloodMage_Emergency
		break
	case Cleric
		call Cleric_Emergency
		break
	case Shaman
		call Shaman_Emergency
		break
	case Disciple
		call Disciple_Emergency
		break
	case Druid
		call Druid_Emergency
		break
	case Necromancer
		call Necromancer_Emergency
		break
	case Psionicist
		call Psionicist_Emergency
		break
	case Sorcerer
		call Sorcerer_Emergency
		break
	}

	return
}
;===================================================
;===    Class Specific Post Casting Loop        ====
;===================================================
function Class_PostCasting()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_PostCasting
		break
	case Warrior
		call Warrior_PostCasting
		break
	case Paladin
		call Paladin_PostCasting
		break
	case Bard
		call Bard_PostCasting
		break
	case Monk
		call Monk_PostCasting
		break
	case Ranger
		call Ranger_PostCasting
		break
	case Rogue
		call Rogue_PostCasting
		break
	case Blood Mage
		call BloodMage_PostCasting
		break
	case Cleric
		call Cleric_PostCasting
		break
	case Shaman
		call Shaman_PostCasting
		break
	case Disciple
		call Disciple_PostCasting
		break
	case Druid
		call Druid_PostCasting
		break
	case Necromancer
		call Necromancer_PostCasting
		break
	case Psionicist
		call Psionicist_PostCasting
		break
	case Sorcerer
		call Sorcerer_PostCasting
		break
	}

	return
}
;===================================================
;===    Class Specific Downtime Function        ====
;===================================================
function Class_DownTime()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_DownTime
		break
	case Warrior
		call Warrior_DownTime
		break
	case Paladin
		call Paladin_DownTime
		break
	case Bard
		call Bard_DownTime
		break
	case Monk
		call Monk_DownTime
		break
	case Ranger
		call Ranger_DownTime
		break
	case Rogue
		call Rogue_DownTime
		break
	case Blood Mage
		call BloodMage_DownTime
		break
	case Cleric
		call Cleric_DownTime
		break
	case Shaman
		call Shaman_DownTime
		break
	case Disciple
		call Disciple_DownTime
		break
	case Druid
		call Druid_DownTime
		break
	case Necromancer
		call Necromancer_DownTime
		break
	case Psionicist
		call Psionicist_DownTime
		break
	case Sorcerer
		call Sorcerer_DownTime
		break
	}
	return
}
;===================================================
;===    Class Specific Burst Function        ====
;===================================================
function Class_Burst()
{
	switch ${Me.Class}
	{
	case Dread Knight
		call DreadKnight_Burst
		break
	case Warrior
		call Warrior_Burst
		break
	case Paladin
		call Paladin_Burst
		break
	case Bard
		call Bard_Burst
		break
	case Monk
		call Monk_Burst
		break
	case Ranger
		call Ranger_Burst
		break
	case Rogue
		call Rogue_Burst
		break
	case Blood Mage
		call BloodMage_Burst
		break
	case Cleric
		call Cleric_Burst
		break
	case Shaman
		call Shaman_Burst
		break
	case Disciple
		call Disciple_Burst
		break
	case Druid
		call Druid_Burst
		break
	case Necromancer
		call Necromancer_Burst
		break
	case Psionicist
		call Psionicist_Burst
		break
	case Sorcerer
		call Sorcerer_Burst
		break
	}
	return
}



