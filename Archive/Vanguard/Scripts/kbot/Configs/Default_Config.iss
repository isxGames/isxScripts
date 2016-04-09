;================================================
function SetupAbilities()
{
	call DebugIt "D. Initializing..."

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

	;Meditation is used by Monks and Disciples
	;Use Meditation if I am not afk or not worried about agro allowing high Jin and faster kills
	meditateSpell:Set[Meditation]
	;Use Feign Death if I am worried about agro but at the cost of low Jin
	;meditateSpell:Set[Feign Death III]

	;Feign Death
	;Feign Death is an attempt to fool an agressor into thinking you are dead so they will stop attacking you.
	DoWeHaveFD:Set[FALSE]
	FeignDeath:Set[Feign Death II]
	FeignDeathAt:Set[30]
	;Added code && (${Me.TargetHealth}>${FightOnAt}) so that if the fight is close I will not FD.
	;Lower to Feign even if close
	FightOnAt:Set[30]

	;Check Jin for Monks and Disciples (set to zero if you are not one of these classes
	RequiredJin:Set[0]

	;TotallyAFK abilities, set these things if you'll be totally afk.
	TotallyAFK:Set[FALSE]
	AFKAbility:Set[Meditation]
	AFKNote:Set[Half AFK watching Matrix.  I might miss a tell or 2]


	;====================================END OF REQUIRED CHANGES==============================

	call DebugIt "D. Initialized..."
}


