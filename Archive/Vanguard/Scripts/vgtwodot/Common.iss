;===================================================
;===               Do Dispell                   ====
;===================================================
function DeBuff()
{
	;-------------------------------------------
	; Return if we don't want to DeBuff/Dispell
	;-------------------------------------------
	if !${DoDeBuffs}
	return

	;-------------------------------------------
	; Must pass our checks
	;-------------------------------------------
	if !${Me.Target(exists)} || ${Me.Target.IsDead} || ${Me.TargetHealth}>0 || !${Me.Target.HaveLineOfSightTo} || !${Me.TargetBuff}
	return

	for ( i:Set[1] ; ${i}<=${Me.TargetBuff} ; i:Inc )
	{
		if ${Me.TargetBuff[${i}].Name.Find[Enchant]}
		{
			wait 25 ${Me.Ability[${DeBuff[1]}].IsReady}
			call UseAbility "${DeBuff[1]}"
			if !${Me.TargetBuff[${i}].Name.Find[Enchant]}
			vgecho "VG: Dispelling ${Me.TargetBuff[${i}].Name}
			;VGExecute "/group Dispelled ${Me.TargetBuff[${i}].Name}"
		}
	}
}


;===================================================
;===            Drowning Routine                ====
;===================================================
function Drowning()
{
	;-------------------------------------------
	; Return if system was halted or paused
	;-------------------------------------------
	if !${IsRunning} || ${IsPaused}
	return

	;-------------------------------------------
	; If we are drowning, then stop drowning
	;-------------------------------------------
	if ${Me.IsDrowning}
	{
		Status:Set[<< DROWNING >>]
		if ${Me.Inventory["Potion of Deep Breath"](exists)}
		{
			vgecho "VG: DROWNING - used Potion of Deep Breath"
			Me.Inventory[Potion of Deep Breath]:Use
			wait 10
		}
		if ${Me.Inventory["Aquamarine Focus"](exists)}
		{
			vgecho "VG: DROWNING - used Aquamarine Focus (ring)"
			Me.Inventory[Aquamarine Focus]:Use
			wait 10
		}
		call CheckAbilityCost "Boon of Boqobol"
		if ${Return}
		{
			vgecho "VG: DROWNING - casting Boon of Boqobol"
			Me.Ability[${ABILITY}]:Use
			wait 10
		}
		call CheckAbilityCost "Hollow Breath"
		if ${Return}
		{
			vgecho "VG: DROWNING - casting Hollow Breath"
			Me.Ability[${ABILITY}]:Use
			wait 10
		}
	}
}

;===================================================
;===    Lame Chains/Counters/Rescues Routine    ====
;===================================================
function ChainCounter()
{
	;-------------------------------------------
	; Return if system was halted or paused
	;-------------------------------------------
	if !${IsRunning} || ${IsPaused}
	return TRUE

	;-------------------------------------------
	; Lame counter catch all - VG has a bug with the counters so why not have VG execute them?  <grin>
	;-------------------------------------------
	VGExecute /reactionautocounter

	variable int i
	for (i:Set[1] ; ${Finishers[${i}].NotEqual[NULL]} ; i:Inc)
	{
		if ${Me.Ability["${Finishers[${i}]}"].IsReady}
		{
			Status:Set[Chains & Counters]
			call UseAbility "${Finishers[${i}]}"
		}
	}
}

;===================================================
;===  BuffUp Routine - not needed if in combat  ====
;===================================================
function BuffUp()
{
	;-------------------------------------------
	; Return if system was halted or paused
	;-------------------------------------------
	if !${IsRunning} || ${IsPaused}
	return TRUE

	if !${Me.InCombat} && ${Pawn[${Tank}].CombatState}==0 && ${Me.Encounter}==0
	{
		variable int i
		for (i:Set[1] ; ${Buffs[${i}].NotEqual[NULL]} ; i:Inc)
		{
			call UseBuffAbility "${Buffs[${i}]}"
			if ${Return}
			return TRUE
		}
	}
}

;===================================================
;===  BuffIt Routine - Only used in KeyBinding   ====
;===================================================
function BuffIt()
{
	;-------------------------------------------
	; Return if system was halted or paused
	;-------------------------------------------
	if !${IsRunning} || ${IsPaused}
	return TRUE

	Status:Set[Forcing Buffs]
	wait 5
	variable int i
	for (i:Set[1] ; ${Buffs[${i}].NotEqual[NULL]} ; i:Inc)
	{
		call ForceBuffAbility "${Buffs[${i}]}"
	}
}

;===================================================
;===         Find Target                        ====
;===================================================
function AssistTank()
{
	;-------------------------------------------
	; Return if system was halted or paused
	;-------------------------------------------
	if !${IsRunning} || ${IsPaused} || (${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.TargetHealth}>0 && ${Me.Target.HaveLineOfSightTo})
	return

	;-------------------------------------------
	; 1st, Assist Tank if in a group
	;-------------------------------------------
	if ${Me.IsGrouped} && ${Pawn[${Tank}].CombatState}>0 && ${Pawn[${Tank}].Distance}<25
	{
		Status:Set[Find Target - Assisting Tank]
		vgecho "VG: Assisting Tank - ${Tank}"
		VGExecute /assist "${Tank}"
	}

	;-------------------------------------------
	; 2nd, Go fetch an encounter if not in a group
	;-------------------------------------------
	if ${Me.Encounter}>0 && !${Me.IsGrouped}
	{
		Status:Set[Find Next Target - Encounter]
		vgecho "VG: Get Next encounter"
		Me.Encounter[1].ToPawn:Target
		wait 5
	}

	;-------------------------------------------
	; Lets face the target
	;-------------------------------------------
	if ${DoFaceSlow} && ${Me.Target(exists)} && !${Me.Target.IsDead} && ${Me.InCombat} && ${Pawn[${Tank}].CombatState}>0
	call facemob ${Me.Target.ID} 85
}


;===================================================
;===      GetHighestAbility Routine             ====
;===================================================
function GetHighestAbility(string AbilityName)
{
	declare L int local 20
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[20] string local

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
	AbilityLevels[11]:Set[XI]
	AbilityLevels[12]:Set[XII]
	AbilityLevels[13]:Set[XIII]
	AbilityLevels[14]:Set[XIV]
	AbilityLevels[15]:Set[XV]
	AbilityLevels[16]:Set[XVI]
	AbilityLevels[17]:Set[XVII]
	AbilityLevels[18]:Set[XVIII]
	AbilityLevels[19]:Set[XIX]
	AbilityLevels[20]:Set[XX]

	;-------------------------------------------
	; Return if Ability already exists
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)}
	return ${AbilityName}

	;-------------------------------------------
	; Find highest Ability level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)}
	return ${ABILITY}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	return "None"
}



