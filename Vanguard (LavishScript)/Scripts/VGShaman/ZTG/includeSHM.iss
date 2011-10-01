;================================================
function SetAbilities()
{
	EchoIt "Setting Shaman Abilities..."

	;; This will find the highest ability or set it to None if it doesn't exists
	SetHighestAbility "OraclesSight" "Oracle's Sight"
	SetHighestAbility "Infusion" "Infusion"
	SetHighestAbility "RakurrsGrace" "Rakurr's Grace"
	SetHighestAbility "BoonOfBosrid" "Boon of Bosrid"
	SetHighestAbility "Panacea" "Panacea"
	SetHighestAbility "Remedy" "Remedy"
	SetHighestAbility "Restoration" "Restoration"
	SetHighestAbility "HealAttendant" "Heal Attendant"
	SetHighestAbility "AncestorsGift" "Ancestor's Gift"
	SetHighestAbility "LifeWard" "Life Ward"
	SetHighestAbility "Intercession" "Intercession"
	SetHighestAbility "AegisOfLife" "Aegis of Life"
	SetHighestAbility "Lethargy" "Lethargy"
	SetHighestAbility "SpiritOfRakurr" "Spirit of Rakurr"
	SetHighestAbility "SpeedOfRakurr" "Speed of Rakurr"
	SetHighestAbility "BoonOfBoqobol" "Boon of Boqobol"
	SetHighestAbility "BoonOfAlcipus" "Boon of Alcipus"
	SetHighestAbility "RitualOfSacrifice" "Ritual of Sacrifice"
	SetHighestAbility "Hoarfrost" "Hoarfrost"
	SetHighestAbility "BaneOfKrigus" "Bane of Krigus"
	SetHighestAbility "GelidBlast" "Gelid Blast"
	SetHighestAbility "UmbraBurst" "Umbra Burst"
	SetHighestAbility "FistOfTheEarth" "Fist of the Earth"
	SetHighestAbility "ThroatRip" "Throat Rip"
	SetHighestAbility "SpiritStrike" "Spirit Strike"
	SetHighestAbility "WintersRoar" "Winter's Roar"
	SetHighestAbility "CurseOfFrailty" "Curse of Frailty"
	SetHighestAbility "SummonAttendantOfRakurr" "Summon Attendant of Rakurr"
	SetHighestAbility "BloodyFang" "Bloody Fang"
	SetHighestAbility "Maim" "Maim"
	SetHighestAbility "ScentOfBlood" "Scent of Blood"
	SetHighestAbility "Intimidate" "Intimidate"
	SetHighestAbility "SummonSpiritOrb" "Summon Spirit Orb"
	SetHighestAbility "SpiritCall" "Spirit Call"
	SetHighestAbility "TearOfThePhoenix" "Tear of the Phoenix"
	SetHighestAbility "StrikeOfSkamadiz" "Strike of Skamadiz"
	SetHighestAbility "HammerOfKrigus" "Hammer of Krigus"
	SetHighestAbility "TearingClaw" "Tearing Claw"
	SetHighestAbility "ViciousBite" "Vicious Bite"
	SetHighestAbility "BiteOfNagSuul" "Bite of Nag-Suul"
	SetHighestAbility "Hamstring" "Hamstring"
	SetHighestAbility "Snarl" "Snarl"
	SetHighestAbility "SpiritsBoutifulBlessing" "Spirit's Bountiful Blessing"
	SetHighestAbility "FavorOfTheFlame" "Favor of the Flame"
	SetHighestAbility "Acuity" "Acuity"
	
	;; Once the above has been defined, it is put here
	Buff[1]:Set[${OraclesSight}]
	Buff[2]:Set[${Infusion}]
	Buff[3]:Set[${RakurrsGrace}]
	Buff[4]:Set[${BoonOfBosrid}]
	Buff[5]:Set[${SpiritOfRakurr}]
	HealEmg:Set[${Panacea}]
	HealSmall:Set[${Remedy}]
	HealBig:Set[${Restoration}]
	HealPet1:Set[${HealAttendant}]
	GroupHeal1:Set[${AncestorsGift}]
	HealReactive:Set[${LifeWard}]
	GroupReactive1:Set[${Intercession}]
	Rune1:Set[${AegisOfLife}]
	DefaultForm:Set["Strong Spirit Bond: Krigus"]
	Slow1:Set[${Lethargy}]
	RunSpeed1:Set[${SpeedOfRakurr}]
	EB:Set[${BoonOfBoqobol}]
	Lev:Set[${BoonOfAlcipus}]
	HealthCanni1:Set[${RitualOfSacrifice}]
	Dot1:Set[${Hoarfrost}]
	Dot2:Set[${BaneOfKrigus}]
	Finisher1:Set[${FistOfTheEarth}]
	Finisher2:Set[${GelidBlast}]
	Finisher3:Set[${UmbraBurst}]
	Nuke1:Set[${WintersRoar}]
	Nuke2:Set[${SpiritStrike}]
	Debuff1:Set[${CurseOfFrailty}]
	PetSummon1:Set[${SummonAttendantOfRakurr}]
	PetAbility1:Set[${BloodyFang}]
	PetAbility2:Set[${Maim}]
	PetAbility3:Set[${ScentOfBlood}]
	PetTaunt1:Set[${Intimidate}]
	RezStone:Set[${SummonSpiritOrb}]
	Rez:Set[${SpiritCall}]
	CombatRez:Set[${TearOfThePhoenix}]
	Melee1:Set[${StrikeOfSkamadiz}]
	Melee2:Set[${HammerOfKrigus}]
	Melee3:Set[${TearingClaw}]
	Melee4:Set[${ViciousBite}]
	Melee5:Set[${BiteOfNagSuul}]
	Melee6:Set[${Hamstring}]
	DeAggroMelee1:Set[${Snarl}]
}

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
;===================================================
atom(script) SetHighestAbility(string AbilityVariable, string AbilityName)
{
	declare L int local 8
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[8] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]
	AbilityLevels[9]:Set[IX]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	global "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Find highest Ability level - based upon current level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${Me.Level}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	global "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt " --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	global "None"
	return
}

;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][VGShaman]: ${aText}"
	}
}


