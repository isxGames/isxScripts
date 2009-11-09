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
	; Routine if Poisoned or Diseased
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
	; Let's assist Tank if Tank is in combat
	;-------------------------------------------
	if ${Pawn[${Tank}].CombatState}>0 && ${Pawn[${Tank}].Distance}<25
	{
		if !${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 5
		}
		VGExecute /assist "${Tank}"
		call AttackTarget
	}

	;-------------------------------------------
	; Let's assist Tank if we have an Encounter
	;-------------------------------------------
	if !${Me.IsGrouped} && ${Me.Encounter}>0
	{
		if !${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 5
		}
		VGExecute /assist "${Tank}"
		call AttackTarget
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