/* MUST HAVE - NOT IN COMBAT */
function NotInCombat()
{
	;-------------------------------------------
	; Return if in combat
	;-------------------------------------------
	if ${Me.InCombat} || ${isPaused}
		return

	if ${Me.Effect[Group Illusion: Kobold](exists)}
	{
		Me.Effect[Group Illusion: Kobold]:Remove
		wait 5
	}
	
	;-------------------------------------------
	; Turn FURIOUS off
	;-------------------------------------------
	FURIOUS:Set[FALSE]

	;-------------------------------------------
	; Change forms
	;-------------------------------------------
	if !${Me.CurrentForm.Name.Equal[Sanguine Focus]} && (${Me.HealthPct}<=${AttackHealRatio} || ${Me.Target.IsDead})
	{
		if ${doEcho}
			echo "[${Time}][VG:BM] --> Form: Sanguine Focus"
		Me.Form[Sanguine Focus]:ChangeTo
		wait 25
	}

	;-------------------------------------------
	; Routine to update our display of any immunities
	;-------------------------------------------
	call FindGroupMembers

	;-------------------------------------------
	; Routine if Poisoned or Diseased - will not aggro mob
	;-------------------------------------------
	call DisEnchant
	if ${Return}
		return

	;-------------------------------------------
	; Regenerate our mana
	;-------------------------------------------
	call RegenMana
	if ${Return}
		return

	;-------------------------------------------
	; Check & Rebuff
	;-------------------------------------------
	call Buffs
	if ${Return}
		return
		
	;-------------------------------------------
	; Let's assist Tank if Tank is in combat or we have an Encounter
	;-------------------------------------------
	if ${Me.Encounter}>0 || ${Pawn[${Tank}].CombatState}>0
	{
		if ${Pawn[${Tank}].CombatState}>0 && ${Pawn[${Tank}].Distance}<25
		{
			VGExecute /assist "${Tank}"
			wait 10 ${Me.Target(exists)}
		}
		if !${Me.Target(exists)} && ${Me.Encounter}>0
		{
			Me.Encounter[1].ToPawn:Target
			wait 10 ${Me.Target(exists)}
		}
		if ${Me.Target(exists)}
		{
			if !${Me.IsGrouped}
				call AttackTarget
			if ${Me.IsGrouped} && ${Me.TargetHealth}<${StartAttack}
				call AttackTarget
		}
	}

	;-------------------------------------------
	; Find lowest member's health 
	;-------------------------------------------
	call FindLowestHealth

	;-------------------------------------------
	; If target's health is below AttackHealRatio then heal it
	;-------------------------------------------
	if (${low}<${AttackHealRatio} || ${Me.HealthPct}<80) && (${Group[${gn}].Distance}<25 || !${Me.IsGrouped})
	{
		call HealDTarget
		if ${Return}
			return
	}

	;-------------------------------------------
	; Heal whomever health is in this range
	;-------------------------------------------
	if ${low}>${AttackHealRatio} && ${low}<90
	{
		if !${Me.IsGrouped}
			Pawn[me]:Target
		if ${Me.IsGrouped}
			Pawn[id,${Group[${gn}].ID}]:Target

		call UseAbility "${TransfusionOfSerak}" "Sanguine Focus"
		if ${Return}
			return
	}
	
	;-------------------------------------------
	; Handle any Symbiote Requests estaablished by the Event Handler
	;-------------------------------------------
	call SymbioteRequest
	
	;-------------------------------------------
	; Ensure we have enough blood vials in inventory
	;-------------------------------------------
	call CheckBloodVials
	if ${Return}
		return

	;-------------------------------------------
	; Maintain invisibility if we are invisible
	;-------------------------------------------
	call Translucence
	if ${Return}
		return
		
	;-------------------------------------------
	; Update our status to "Waiting"
	;-------------------------------------------
	Status:Set[Waiting]
}