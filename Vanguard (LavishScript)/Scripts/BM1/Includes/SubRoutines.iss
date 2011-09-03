;
; The following subroutines are used whenever we
; have an action to perform.
;


;===================================================
;===           PAUSED SUBROUTINE                ====
;===================================================
function Paused()
{
	call MeleeAttackOff
	call SprintCheck
	if ${Me.HealthPct}<20
	{
		; 1.5 second small heal... this is for me
		if ${Me.Ability[${InfuseHealth}].TimeRemaining}==0
		{
			Pawn[Me]:Target
			if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
			{
				Me.Form["Sanguine Focus"]:ChangeTo
				wait .5
			}
			wait 5 ${Me.Ability[${InfuseHealth}].IsReady}
			call UseAbility "${InfuseHealth}"
			if ${Return}
			{
				; attempt to get a HOT up
				if ${Me.Ability[${TransfusionOfSerak}].TimeRemaining}==0
				{
					EchoIt "Using HOT to heal self"
					if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
					{
						Me.Form["Sanguine Focus"]:ChangeTo
						wait .5
					}
					wait 5 ${Me.Ability[${TransfusionOfSerak}].IsReady}
					call UseAbility "${TransfusionOfSerak}"
				}
			}
		}
	}
}

;===================================================
;===       WE ARE DEAD SUBROUTINE               ====
;===================================================
function WeAreDead()
{
	;; do nothing
	return
}

;===================================================
;===        QUEUED COMMANDS SUBROUTINE          ====
;===================================================
function QueuedCommand()
{
	;; a command was stored so lets execute it
	if ${Me.Health} && ${QueuedCommands}
	{
		ExecuteQueued
		FlushQueued
	}
}

;===================================================
;===        ASSIST TANK SUBROUTINE              ====
;===================================================
function AssistTank()
{
	;; try to target the tank's target
	if ${Pawn[name,${Tank}](exists)}
	{
		EchoIt "Assisting ${Tank}"
		VGExecute /cleartargets
		VGExecute "/assist ${Tank}"
		wait 10
	}
}

;===================================================
;===       REMOVE POISONS SUB-ROUTINE           ====
;===================================================
function RemovePoisons()
{
	;-------------------------------------------
	; Use item to remove a poison - this is also toggled by Combat Text
	;-------------------------------------------
	RemovePoison:Set[FALSE]
	if ${Me.Inventory[Great Sageberries](exists)}
	{
		;; make sure the item is on your hot bar else it will not work correctly
		wait 5 ${Me.Inventory[Great Sageberries].IsReady}

		;; check if you have the item and use it
		if ${Me.Inventory[Great Sageberries].IsReady}
		{
			EchoIt "Consumed Great Sageberries to remove a poison"
			wait 1
			Me.Inventory[Great Sageberries]:Use
			call GlobalRecovery
		}
		return
	}
	if ${Me.Ability[Cleansing Leech](exists)}
	{
		if ${Me.Ability[Cleansing Leech].IsReady}
		{
			if ${Me.Inventory[Cleansing Leech](exists)}
			{
				call UseAbility "Cleansing Leech"
			}
		}
		return
	}
}

;===================================================
;===      REMOVE ENCHANTMENTS SUB-ROUTINE       ====
;===================================================
function RemoveEnchantments()
{
	;-------------------------------------------
	; we do not know what enchantment will get removed so just remove something
	;-------------------------------------------
	;; wait up to half a second for the ability to be ready
	wait 5 ${Me.Ability[${StripEnchantment}].IsReady}

	;; execute the ability
	call UseAbility "${StripEnchantment}"

	;; check to see enchantment was removed
	wait 5 !${Me.TargetBuff[${StripThisEnchantment}](exists)}
	if !${Me.TargetBuff[${StripThisEnchantment}](exists)}
	{
		EchoIt "SUCCESSFULLY removed: ${StripThisEnchantment}"
		vgecho "<Purple=>SUCCESSFULLY removed: <Yellow=>${StripThisEnchantment}"
		return
	}
	return
}

;===================================================
;===        TARGET IS DEAD SUB-ROUTINE          ====
;===================================================
function TargetIsDead()
{
	;-------------------------------------------
	; TARGET IS DEAD/CORPSE LOOP
	;-------------------------------------------
	if ${Me.Target.IsDead} || ${Me.Target.Type.Equal[Corpse]}
	{
		call MeleeAttackOff
		isFurious:Set[FALSE]
		if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
		{
			Me.Form["Sanguine Focus"]:ChangeTo
			wait .5
		}
		if ${doLootAll}
		{
			Loot:BeginLooting
			wait 10 ${Loot.NumItems}

			if ${Loot.NumItems}
			{
				for ( i:Set[${Loot.NumItems}] ; ${i}>0 ; i:Dec )
				{
					Loot.Item[${i}]:Loot
				}
			}
			else
			{
				Loot:LootAll
			}
			wait 5 !${Me.IsLooting}
		}
		if !${Me.IsLooting}
		{
			VGExecute /cleartargets
		}
		wait 3

	}
}

;===================================================
;===        REGAIN ENERGY SUB-ROUTINE           ====
;===================================================
function RegainEnergy()
{
	;-------------------------------------------
	; REGEN ENERGY - Always try to sustain energy over time
	;-------------------------------------------
	if ${Me.EnergyPct}<=80 && ${Me.HealthPct}>=${HealCheck}
	{
		if ${Me.Ability[${MentalTransmutation}].TimeRemaining}==0
		{
			wait 5 ${Me.Ability[${MentalTransmutation}].IsReady}
			if ${Me.Ability[${MentalTransmutation}].IsReady}
			{
				EchoIt "Canabalized Health for Energy"
				Me.Ability[${MentalTransmutation}]:Use
				call GlobalRecovery
				return
			}
		}
		if ${Me.EnergyPct}<=40 && ${Me.Inventory[Large Mottleberries](exists)}
		{
			if ${Me.Inventory[Large Mottleberries].IsReady}
			{
				EchoIt "Consumed Large Mottleberries to gain energy"
				Me.Inventory[Large Mottleberries]:Use
				call GlobalRecovery
				return
			}
		}
	}
}

;===================================================
;===          WE CHUNKED SUB-ROUTINE            ====
;===       Global Cooldown after chunkng        ====
;===================================================
function WeChunked()
{
	;; have we chunked?
	while !${CurrentChunk.Equal[${Me.Chunk}]}
	{
		wait 5
		call GlobalRecovery
		CurrentChunk:Set[${Me.Chunk}]
	}
}


;===================================================
;===           SPRINT SUB-ROUTINE               ====
;===    always on unless we are on a mount      ====
;===================================================
function SprintCheck()
{
	if ${doSprint}
	{
		;; if we are casting then
		if ${Me.IsCasting}
		{
			if ${Me.Casting.Equal[Summon Mount]} || ${Me.Casting.Equal[Summon Hound]} || ${Me.Casting.Equal[Summon Unicorn]}
			{
				;; turn off sprinting
				if ${Me.IsSprinting}
				{
					Me:Sprint[${Speed}]
					EchoIt "Sprinting is OFF : ${Me.IsSprinting}"
					wait 10 !${Me.IsSprinting}
				}
				;; wait until we are done casting
				while ${Me.Casting.Equal[Summon Mount]} || ${Me.Casting.Equal[Summon Hound]}
				{
					wait 1
				}

				;; this wait fixes the speed
				wait 10
				return
			}
		}
		;; briefly pause if we chunked
		call WeChunked

		;; checking every other second saves on the FPS due to the Pawn check
		if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextSpeedCheck}]}/1000]}>=1
		{
			; reset speed check delay
			NextSpeedCheck:Set[${Script.RunningTime}]

			;; turn off sprinting
			if ${Pawn[me].IsMounted}
			{
				if ${Me.IsSprinting}
				{
					Me:Sprint[${Speed}]
					EchoIt "Sprinting is OFF : ${Me.IsSprinting}"
					wait 10 !${Me.IsSprinting}
					return
				}
			}
			;; turn on sprinting
			if !${Pawn[me].IsMounted}
			{
				if !${Me.IsSprinting}
				{
					Me:Sprint[${Speed}]
					EchoIt "Sprinting is ON : ${Me.IsSprinting}"
					wait 3
					return
				}
			}
		}
	}
	else
	{
		;; turn off sprinting
		if ${Me.IsSprinting}
		{
			Me:Sprint[${Speed}]
			EchoIt "Sprinting is OFF : ${Me.IsSprinting}"
			wait 10 !${Me.IsSprinting}
		}
	}
}

;===================================================
;===    COUNTER TARGET'S ABILITY SUBROUTINE     ====
;===================================================
function BuffRequests()
{
	VGExecute /cleartargets
	Pawn[${PCName}]:Target
	wait 3
	call UseAbility "${ConstructsAugmentation}"
	if ${Return}
	{
		BuffRequest:Set[FALSE]
		vgecho "Buffed ${PCName}"
	}
}

;===================================================
;===    COUNTER TARGET'S ABILITY SUBROUTINE     ====
;===================================================
function FindGroupMembers()
{
	doFindGroupMembers:Set[FALSE]
	if ${Me.IsGrouped}
	{
		for (i:Set[1]; ${i}<=6; i:Inc)
		{
			VGExecute /cleartargets
			VGExecute "/targetgroupmember ${i}"
			waitframe
			GROUP${i}:Set[${Me.DTarget.Name}]
			vgecho "GROUP${i} = ${GROUP${i}}"
		}
	}
}

;===================================================
;===      RESET IMMUNITIES SUB-ROUTINE          ====
;===================================================
function ResetImmunities()
{
	if ${Me.Target(exists)}
	{
		if ${LastTargetID}!=${Me.Target.ID}
		{
			;; update LastTargetID
			LastTargetID:Set[${Me.Target.ID}]

			;; reset these abilities
			doPhysical:Set[${UIElement[doPhysical@Main@Tabs@BM1].Checked}]
			doArcane:Set[${UIElement[doArcane@Main@Tabs@BM1].Checked}]
			doDots:Set[${UIElement[doDots@Main@Tabs@BM1].Checked}]
		}
	}
}


;===================================================
;===       GLOBAL RECOVERY SUB-ROUTINE          ====
;===================================================
function GlobalRecovery()
{
	wait 5
	while ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
	{
		call MeleeAttackOn
	}
}

;===================================================
;===       I AM CASTING SUB-ROUTINE             ====
;===================================================
function MeIsCasting()
{
	wait 5
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		call MeleeAttackOn
	}
}

;===================================================
;===       CALCULATE ANGLE SUB-ROUTINE          ====
;===================================================
function CalculateAngles()
{
	if ${Me.Target(exists)}
	{
		variable float temp1 = ${Math.Calc[${Me.Y} - ${Me.Target.Y}]}
		variable float temp2 = ${Math.Calc[${Me.X} - ${Me.Target.X}]}
		variable float result = ${Math.Calc[${Math.Atan[${temp1},${temp2}]} - 90]}

		result:Set[${Math.Calc[${result} + (${result} < 0) * 360]}]
		result:Set[${Math.Calc[${result} - ${Me.Heading}]}]
		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		AngleDiff:Set[${result}]
		AngleDiffAbs:Set[${Math.Abs[${result}]}]
	}
	else
	{
		AngleDiff:Set[0]
		AngleDiffAbs:Set[0]
	}
}

;===================================================
;===      CALCULATE THIS ANGLE SUB-ROUTINE      ====
;===================================================
function CalculateThisAngle(string TARGET)
{
	if ${Pawn[name,${TARGET}](exists)}
	{
		variable float temp1 = ${Math.Calc[${Me.Y} - ${Pawn[name,${TARGET}].Y}]}
		variable float temp2 = ${Math.Calc[${Me.X} - ${Pawn[name,${TARGET}].X}]}
		variable float result = ${Math.Calc[${Math.Atan[${temp1},${temp2}]} - 90]}

		result:Set[${Math.Calc[${result} + (${result} < 0) * 360]}]
		result:Set[${Math.Calc[${result} - ${Me.Heading}]}]
		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		AngleDiff:Set[${result}]
		AngleDiffAbs:Set[${Math.Abs[${result}]}]
	}
	else
	{
		AngleDiff:Set[0]
		AngleDiffAbs:Set[0]
	}
}

;===================================================
;===              USE AN ABILITY                ====
;===  called from within AttackTarget routine   ====
;===================================================
function:bool UseAbility(string ABILITY)
{
	;-------------------------------------------
	; return if ability does not exist
	;-------------------------------------------
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		;EchoIt "${ABILITY} does not exist"
		return FALSE
	}

	;-------------------------------------------
	; execute ability only if it is ready
	;-------------------------------------------
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; return if we do not have enough BloodUnion
		;if ${Me.Ability[${ABILITY}].BloodUnionRequired} > ${Me.BloodUnion}
		;{
		;	EchoIt "Not Enough Blood Union for ${ABILITY}, Required=${Me.Ability[${ABILITY}].BloodUnionRequired}, Have=${Me.BloodUnion}"
		;	return FALSE
		;}

		;; return if we do not have enough energy
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt "Not enought Energy for ${ABILITY}"
			return FALSE
		}

		;; return if the target is outside our range
		if !${Me.Ability[${ABILITY}].TargetInRange} && !${Me.Ability[${ABILITY}].TargetType.Equal[Self]}
		{
			EchoIt "Target not in range for ${ABILITY}"
			return FALSE
		}

		;; now execute the ability
		EchoIt "Used ${ABILITY}"
		Me.Ability[${ABILITY}]:Use
		wait 3

		;; loop this while checking for crits and furious
		while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
		{
			call MeleeAttackOn
		}
		wait 1

		;; make sure we double-check for any crits
		;call CritFinishers

		;; say we executed ability successfully
		return TRUE
	}
	;; say we did not execute the ability
	return FALSE
}

;===================================================
;===          FOLLOW TANK SUB-ROUTINE           ====
;===================================================
function FollowTank()
{
	if ${Pawn[name,${Tank}](exists)}
	{
		;; did target move out of rang?
		if ${Pawn[name,${Tank}].Distance}>=${FollowDistance2}
		{
			variable bool AreWeMoving = FALSE
			;; start moving until target is within range
			while !${isPaused} && ${Pawn[name,${Tank}](exists)} && ${Pawn[name,${Tank}].Distance}>=${FollowDistance1} && ${Pawn[name,${Tank}].Distance}<45
			{
				Pawn[name,${Tank}]:Face
				VG:ExecBinding[moveforward]
				AreWeMoving:Set[TRUE]
				wait .5
			}
			;; if we moved then we want to stop moving
			if ${AreWeMoving}
			{
				VG:ExecBinding[moveforward,release]
			}
		}
	}
}


