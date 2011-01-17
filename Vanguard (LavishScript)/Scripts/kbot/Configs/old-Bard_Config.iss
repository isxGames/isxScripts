;================================================
function SetupAbilities()
{
	call DebugIt "D. Initializing..."

	If "${Me.Class.Equal[Necromancer]} || ${Me.Class.Equal[Sorcerer]} || ${Me.Class.Equal[Druid]} || ${Me.Class.Equal[Psionicist]}"
	{
		echo ${Me.Class}'s are not recommended to use this script as it will not kite yet
		echo Proceed at your own risk.

	}

	/*=============================CHANGE THE VARIABLES BELOW================================
	*So basically there are a ton of variables that each class brings to the table
	*Look closely at EVERY ability listed below and change the info in the brackets [] to match your ablities
	*If you dont have an ability, change the value to "null" or "0" zero. If something is TRUE or FALSE it must be spelled in ALL-CAPS!!
	*If you lack an entire line of abilities (such as dots) then set the HowManyXXX variable to 0
	*
	*Example: I have no Melee attacks
	*HowManyMelee:Set[0]
	*Melee1:Set[null]
	*Melee2:Set[null]
	*Melee3:Set[null]
	*Melee4:Set[null]
	*Melee5:Set[null]
	*Melee6:Set[null]
	*
	*
	*Example 2: I have 2 melee attacks
	*HowManyMelee:Set[0]   <----NOTE the 2
	*Melee1:Set[Blade of the Winter I]
	*Melee2:Set[Cripple I]
	*Melee3:Set[null]
	*Melee4:Set[null]
	*Melee5:Set[null]
	*Melee6:Set[null]
	*
	* Last thing to note: Put the abilities in the order you wish them to be used.
	*/

	;Dots
	;List how many DoTs you will use and the names. DoTs are some type of ability that leaves an icon on the target and dose damage or debuff over time
	HowManyDoTs:Set[0]
	DoT1:Set[Feet of the Fire Dragon IV]
	DoT2:Set[Ashen Hand VI]
	DoT3:Set[null]
	DoT4:Set[null]
	DoT5:Set[null]
	DoT6:Set[null]
	DoT7:Set[null]

	;Nukes
	;List how many Nukes you will use and the names. Nukes can be any direct damage ability, they usually are used from a distance but not always
	HowManyNukes:Set[0]
	Nuke1:Set[Six Dragons Strike V]
	Nuke2:Set[Dragon's Rage II]
	Nuke3:Set[Cloud Dragon Ruse II]
	Nuke4:Set[null]
	Nuke5:Set[null]
	Nuke6:Set[null]
	Nuke7:Set[null]

	;Melee Attacks
	;List how many Melee Attacks you will use and the names. Melee Attacks are typically direct damage with a weapon or hands within 5m of the target.
	HowManyMelee:Set[0]
	Melee1:Set[Six Dragons Strike V]
	Melee2:Set[Dragon's Rage II]
	Melee3:Set[Cloud Dragon Ruse II]
	Melee4:Set[Crescent Kick VI]
	Melee5:Set[Boundless Fist V]
	Melee6:Set[null]
	Melee7:Set[null]

	;In-combat buffs
	;List how many Combat Buffs you will use and the names. Combat Buffs are cast on yourself while in combat.
	HowManyInCombatBuffs:Set[0]

	;If CombatBuff1 is active, the other buffs will not fire so use CombatBuff1 for quick buff that would get over written or make it null.
	CombatBuff1:Set[Iron Hand V]

	;If CombatBuff2 is active, CombatBuff3 will not fire and visversa, so use CombatBuff3 and CombatBuff4 for alternating buffs.
	CombatBuff2:Set[Secret of Transcendence I]
	CombatBuff3:Set[Secret of Celerity]
	CombatBuff4:Set[Secret of Flames V]
	CombatBuff5:Set[Secret of Ice IV]
	CombatBuff6:Set[Sun Dragon's Corona]
	CombatBuff7:Set[Jin Surge V]
	CombatBuff8:Set[Swaying Step IV]

	;Chains
	;List how many Chains you will use and the names. Chains are abilities that are activated by a critical hit and can be activated in sequence for a increased affect
	HowManyChains:Set[0]
	Chain1:Set[Gouging Dragon Claw I]
	Chain2:Set[Thousand Fists III]
	Chain3:Set[Flying Kick V]
	Chain4:Set[Sundering Dragon Claw I]
	Chain5:Set[Thundering Fists III]
	Chain6:Set[Kick of the Heavens III]
	Chain7:Set[null]
	Chain8:Set[null]
	Chain9:Set[null]

	;Finishers
	;List how many Finishers you will use and the names. Finishers do not have to be a finishing move, it is just an ability that will be spammed when the target is close to death in order to hasten its death
	HowManyFinishers:Set[0]
	Finisher1:Set[Thundering Fists III]
	Finisher2:Set[Kick of the Heavens III]
	Finisher3:Set[Quivering Palm IV]
	Finisher4:Set[Stinging Backfist VI]
	Finisher5:Set[Crescent Kick VI]
	Finisher6:Set[Ranged Attack]
	Finisher7:Set[null]
	Finisher8:Set[null]
	Finisher9:Set[null]

	;Forms
	;Set if you use Forms, there names and at what point you will change from AttackForm to DefForm
	;If you use Forms Set to TRUE else set to FALSE
	DoWeHaveForms:Set[FALSE]

	;AttackForm should be a Combat or Defensive Form (Even if only one Form is used, it will go back if you are knocked out of your Form)
	AttackForm:Set[Magnificent Storm Dragon]

	;NeutralForm should be a resting and/or healing Form (Used with Meditation and/or Eating)
	NeutralForm:Set[Dragon Stance]
	DefForm:Set[Eternal Stone Dragon]

	;Change to DefForm at what % of Health
	ChangeFormAt:Set[0]

	;Buffs (buffs with timers, no toggles here)
	;List how many Buffs you will use and the names. Buffs are cast on yourself after healing and/or during meditation
	HowManyBuffs:Set[0]
	Buff1:Set[Sun Dragon's Corona]
	Buff2:Set[Aum Ti]
	Buff3:Set[Aum Liat]
	Buff4:Set[null]
	Buff5:Set[null]
	Buff6:Set[null]
	Buff7:Set[null]
	Buff8:Set[null]
	Buff9:Set[null]
	Buff10:Set[null]

	;Toggle Buffs (ones that dont have a time limit)
	;List how many Buffs you will use and the names.
	HowManyToggleBuffs:Set[0]
	ToggleBuff1:Set[null]
	ToggleBuff2:Set[null]
	ToggleBuff3:Set[null]
	ToggleBuff4:Set[null]
	ToggleBuff5:Set[null]

	;This is typically a heal that is used as a last ditch effort to save yourself
	;Do we have an emergency heal? whats the name? what % do I cast it at?
	DoWeHaveEmergHeal:Set[FALSE]
	EmergHeal:Set[Racial Ability: Spirit of Jin]
	EmergHealAt:Set[40]

	;This is typically a heal that is used when your health is very low
	;Do we have a big heal? Whats it's name? What % do I cast it at?
	DoWeHaveBigHeal:Set[FALSE]
	BigHeal:Set[null]
	BigHealAt:Set[20]

	;This is typically a heal that is used for moderate healing
	;Do we have a medium heal? Whats it's name? What % do I cast it at?
	DoWeHaveMediumHeal:Set[FALSE]
	MediumHeal:Set[Ignore Pain IV]
	MediumHealAt:Set[50]

	;This is typically a heal that is used when you have very light damage to your health
	;Do we have a small heal? Whats it's name? What % do I cast it at?
	DoWeHaveSmallHeal:Set[FALSE]
	SmallHeal:Set[Iron Skin]
	SmallHealAt:Set[40]

	;Do we have a medding heal? (This heal will be cast between pulls if you're less than required hp)
	DoWeHaveMeddingHeal:Set[FALSE]
	MeddingHeal:Set[null]

	;Do we use medition? (Meditation will occure between pulls if you're less than required hp)
	;Meditation is used by Monks and Disciples
	DoWeHaveMeditation:Set[FALSE]
	;Use Meditation if I am not afk or not worried about agro allowing high Jin and faster kills
	WeMeditate:Set[Meditation]
	;Use ${FeignDeath} if I am worried about agro but at the cost of low Jin
	;WeMeditate:Set[Feign Death III]

	;Feign Death
	;Feign Death is an attempt to fool an agressor into thinking you are dead so they will stop attacking you.
	DoWeHaveFD:Set[FALSE]
	FeignDeath:Set[Feign Death II]
	FeignDeathAt:Set[30]

	;Con Check. How many DOTs on the PC are you willing to fight, else you will use Feign Death. Suggest 2 for solo
	ConCheck:Set[3]

	;Added code && (${Me.TargetHealth}>${FightOnAt}) so that if the fight is close I will not FD. Lower to Feign even if close
	FightOnAt:Set[30]

	;Pet
	DoWeHavePet:Set[FALSE]
	PetSpellName:Set[null]
	PetHeal:Set[null]
	PetHealAt:Set[40]

	;Pet buffs
	DoWeHavePetBuffs:Set[FALSE]
	PetBuff1:Set[null]
	PetBuff2:Set[null]
	PetBuff3:Set[null]
	PetBuff4:Set[null]
	PetBuff5:Set[null]

	;Pull spell/ability (can be any spell or ranged attack, uses this to pull, duh)
	Ranged_Pull_Ability:Set[Eaon's Blasting Bellow I]
	Ranged_Pull_Followup:Set[Ranged Attack]
	Ranged_Pull_Backup:Set[Auto Attack]

	Melee_Pull_Ability:Set[Eaon's Blasting Bellow I]
	Melee_Pull_Followup:Set[Ranged Attack]
	Melee_Pull_Backup:Set[Auto Attack]

	;Do you use Food and if so what is the name
	EatForHealth:Set[FALSE]
	;Or
	EatForEnergy:Set[FALSE]
	;will eat if your Energy is less-than RequiredEnergy
	;YourFood:Set[Shiny Red Apple]
	YourFood:Set[Block of Cheese]
	;YourFood:Set[Loaf of Honey Bread]
	;YourFood:Set[Hard Boiled Egg]
	EatForHlthAt:Set[80]
	;will eat if less than this variable

	;Set the required amounts of HP, End, Energy, Jin and Max Range. You'll med/heal to these amounts between fights (must be a number, not null)
	RequiredHP:Set[80]
	RequiredEndurance:Set[70]
	RequiredEnergy:Set[80]

	;Check Jin for Monks and Disciples (set to zero if you are not one of these classes
	RequiredJin:Set[0]

	;Below put your Max Pull Range minus 3. Exp: my monks MaxPullRange is 20-3=17 (because you may walk backward out of pulling range)
	MaxPullRange:Set[22]
	MinPullRange:Set[19]

	MaxMeleeRange:Set[5]
	MinMeleeRange:Set[2]


	;SprintSpeed is a percentage of Max VGSprint. I Set mine to 60 as that is about as fast as my class can run with his best buff. 100 is as fast as a Bard.
	SprintSpeed:Set[100]

	;Set of min and max level mob to pull. Current set to pull anything thats Green to Blue.
	MinLevel:Set[${Me.Level}-8]
	MaxLevel:Set[${Me.Level}+2]

	;this setting tells the character how far he can go from a waypoint before he must Return to it. 7500 = 75m
	AllowedRoaming:Set[1500]

	;this setting tells the character how far he can look from where he is standing now for something to pull. 80 = 80m
	PullDistance:Set[45]

	;this setting tell the character how close he can be before agroing or how close two mobs can be to pull without agroing. 13 = 13m
	MobAgroRange:Set[20]

	;Addchecking, setting this to FALSE will make the script skip all add checking routines.
	AddChecking:Set[TRUE]

	;TotallyAFK abilities, set these things if you'll be totally afk.
	TotallyAFK:Set[FALSE]
	AFKAbility:Set[Meditation]
	AFKNote:Set[Half AFK watching Matrix.  I might miss a tell or 2]

	;Harvest type, what type of item do you want to harvest if harvesting is turned on from the UI (list below not all-inclusive)
	;HarvestType:Set[Dry]
	HarvestType:Set[Dry]

	;2nd Harvest Typein beta (not functional in this script)
	;HarvestType2:Set[Slate]

	/* !!!!! I got tired of maintain 2 sets of code so this statement checks if the user is Denthan !!!!! */
	IamDenthan:Set[FALSE]

	;====================================END OF REQUIRED CHANGES==============================


	StartingXP:Set[${Me.XP}]
	CurrentXP:Set[${Me.XP}]

	Tank:Set[${Me.DTarget.Name}]
	TankID:Set[${Me.DTarget.ID}]

	call DebugIt "D. Initialized..."
}


