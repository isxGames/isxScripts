function SetupAbilities()
{
	;; === COUNTER ATTACKS ===
	;	adds 391 hate
	SetHighestAbility "Retaliate" "Retaliate"
	;	stuns opponent for 3 seconds
	SetHighestAbility "Vengeance" "Vengeance"
	
	;; === CHAIN/FINISHER - Replenish Energy ===
	;; Restores some energy -- 10 Endurance, 1m cooldown
	SetHighestAbility "VileStrike" "Vile Strike"
	;; Restores some energy -- 10 Endurance, 1m cooldown
	SetHighestAbility "Anguish" "Anguish"
	
	;; === CHAIN/FINISHER - COMBO #1 ===
	;	add ???? hate, usable after Incite -- 10 endurance
	SetHighestAbility "SuperiorInflame" "Superior Inflame"
	;	add 3544 hate, usable after Incite -- 10 endurance
	SetHighestAbility "Inflame" "Inflame"
	;	add 2700 hate -- 10 endurance, 1m cooldown
	SetHighestAbility "Incite" "Incite"

	;; === CHAIN/FINISHER - COMBO #2 ===
	;	Spiritual Finisher, usable after Ill Omen -- 91 energy,
	SetHighestAbility "HexOfImpendingDoom" "Hex of Impending Doom"
	;	Spiritual Finisher -- 91 energy
	SetHighestAbility "HexOfIllOmen" "Hex of Ill Omen"
	
	;; === CHAIN/FINISHER - COMBO #3 ===
	;	increase ac by 750 and 15% damage, usable after Shield of Fear -- 10 endurance
	SetHighestAbility "DarkBastion" "Dark Bastion"
	;	increase chance to block by 12% -- 10 endurance
	SetHighestAbility "ShieldOfFear" "Shield of Fear"

	;; === CHAIN/FINISHER - COMBO #4 ===
	; 	400% damagage, usable after Wrack -- 10 endurance
	SetHighestAbility "Ruin" "Ruin"
	;	400% damage -- 10 Endurance
	SetHighestAbility "Wrack" "Wrack"
	;	400% damage -- 10 Endurance
	SetHighestAbility "SoulWrack" "Soul Wrack"
	
	;; === RESCUES / FORCE ATTACKS ===
	;	force opponent to attack me for 6 attacks or 10s
	SetHighestAbility "SeethingHatred" "Seething Hatred"
	;	force DTarget's opponent to attack me for 2 attacks or 4s
	SetHighestAbility "Scourge" "Scourge"
	;	force all targets 10m of my target to attack me for 4-8 attacks or 10s
	SetHighestAbility "NexusOfHatred" "Nexus of Hatred"

	;; === WORD OF DOOM - using this opens up the ill omen series ===
	SetHighestAbility "AncientWordOfDoom" "Ancient Word of Doom"
	SetHighestAbility "WordOfDoomHarDaalMur" "Word of Doom: Har Daal Mur"
	SetHighestAbility "WordOfDoomCeimDor" "Word of Doom: Ceim Dor"
	SetHighestAbility "WordOfDoomAmarthic" "Word of Doom: Amarthic"
	SetHighestAbility "WordOfDoomAlthen" "Word of Doom: Althen"

	;; === SYMBOLS - Only one active at a time ===
	;	15% chance to stun opponent for 2 sec -- 1 energy per second
	SetHighestAbility "SymbolOfDespair" "Symbol of Despair"
	;	adds 60 to damage -- 1 energy per second
	SetHighestAbility "SymbolOfWrath" "Symbol of Wrath"

	;; === STRIP ENCHANTMENT ===
	; strips enchantment - 54 energy
	SetHighestAbility "Despoil" "Despoil"

	;; === INCREASE HATRED ===	
	;	 adds 1234 hatred - 64 energy, 8s cooldown
	SetHighestAbility "Provoke" "Provoke"
	;	DOT: 2k dam and 1008 hate over 24s -- 218 energy
	SetHighestAbility "Torture" "Torture"
	
	;; === AOE = 2-Handed ===
	;	565 hate to all opponents infront of me -- 46 endurance
	SetHighestAbility "BlackWind" "Black Wind"
	;	heals plus damage up to 6 opponents infront of me -- 48 endurance
	SetHighestAbility "ScytheOfDoom" "Scythe of Doom"

	;; === INCREASES DREADFUL COUNTENANCE ===
	;	Max DC -- 113 energy, 15m cooldown
	SetHighestAbility "TerrorIncarnate" "Terror Incarnate"
	;	increase DC - 70 energy
	SetHighestAbility "DreadfulVisage" "Dreadful Visage"
	
	;; === BUFFS ===
	;	block 25% damages for 5 attacks -- 38 energy
	SetHighestAbility "DarkWard" "Dark Ward"
	;	opponents take 59 damage -- 59 energy
	SetHighestAbility "AnthaminesCharge" "Anthamine's Charge"
	
	;; === BACKLASH - Use before initiating battle ===
	;	2400 damage when hit within 30 seconds -- 15 endurance
	SetHighestAbility "Backlash" "Backlash"

	;; === KILLING BLOW - usable below 20% health ===
	;	400% damage, roots target for 6 sec -- 30 endurance
	SetHighestAbility "Slay" "Slay"

	;; === DOTS / DEBUFFS ===
	SetHighestAbility "AbyssalChains" "Abyssal Chains"
	SetHighestAbility "DevourMind" "Devour Mind"
	SetHighestAbility "DevourStrength" "Devour Strength"
	SetHighestAbility "SoulConsumption" "Soul Consumption"
	
	;; === IMMUNITY for 10 seconds ===
	SetHighestAbility "AphoticShield" "Aphotic Shield"
	
	;; === HEALS ===
	SetHighestAbility "Cull" "Cull"

	;; === MELEE ATTACKS ===
	;	drains 200 endurance, exploits Soul Wracked -- 10 endurance
	SetHighestAbility "RavagingDarkness" "Ravaging Darkness"

	;; === SHADOW STEP COMBOS ===
	;; Launch this 1st then one of the following
	SetHighestAbility "ShadowStep" "Shadow Step"
	;;	STUN for 20-30 seconds, great when there are 2 mobs next to each other
	SetHighestAbility "PhantasmalBlade" "Phantasmal Blade"
	;;	HEALS for a decent amount, expliots Enraged -- 28 endurance
	SetHighestAbility "Harrow" "Harrow"

	;; === MELEE ATTACKS ===
	;	increase DC -- 20 endurance
	SetHighestAbility "VexingStrike" "Vexing Strike"
	;	exploits Soul Wracked -- 24 endurance
	SetHighestAbility "Malice" "Malice"
	;	400% damage -- 40 endurance
	SetHighestAbility "Mutilate" "Mutilate"
	
	;; === INVISIBILITY ===
	SetHighestAbility "ShadowyVeil" "Shadowy Veil"
	
	;; === DEFENSIVE MANUEVER = 2-Handed ===
	SetHighestAbility "BleakFoeman" "Bleak Foeman"

	;; === STUN for 2 seconds ===
	SetHighestAbility "OminousFate" "Ominous Fate"

	;; === FEAR ===
	SetHighestAbility "Frighten" "Frighten"
	
	;; === MISCELLANEOUS - I'm too low a level to test these abilities ===
	SetHighestAbility "VileHowl" "Vile Howl"
	SetHighestAbility "Bane" "Bane"
	SetHighestAbility "HatredIncarnate" "Hatred Incarnate"
	SetHighestAbility "IncantationOfHate" "Incantation of Hate"
	SetHighestAbility "SymbolOfSuffering" "Symbol of Suffering"
	SetHighestAbility "EnthrallingNexus" "Enthralling Nexus"
}

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
;===================================================
atom(script) SetHighestAbility(string AbilityVariable, string AbilityName)
{
	declare L int local 10
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[10] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]
	AbilityLevels[9]:Set[IX]
	AbilityLevels[10]:Set[X]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		if ${Me.Ability[${ABILITY}].School.Find[Physical]} || ${Me.Ability[${ABILITY}].Description.Find[Physical]}
		{
			EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY} - Physical"
		}
		elseif ${Me.Ability[${ABILITY}].School.Find[Spiritual]} || ${Me.Ability[${ABILITY}].Description.Find[Spiritual]}
		{
			EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY} - Spiritual"
		}
		else
		{
			EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY} - None"
		}
		declare	${AbilityVariable}	string	script "${ABILITY}"
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
		if ${Me.Ability[${ABILITY}].School.Find[Physical]} || ${Me.Ability[${ABILITY}].Description.Find[Physical]}
		{
			EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY} - Physical"
		}
		elseif ${Me.Ability[${ABILITY}].School.Find[Spiritual]} || ${Me.Ability[${ABILITY}].Description.Find[Spiritual]}
		{
			EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY} - Spiritual"
		}
		else
		{
			EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY} - None"
		}
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt " --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	script "None"
	return
}
