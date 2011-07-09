objectdef fight
{
	member:bool ShouldIAttack()
	{
		if ${Group.Count} < 2 && ${Me.Target(exists)} && ${Me.TargetHealth} > 0 && !${Me.Target.IsDead} && ${Me.Target.HaveLineOfSightTo} && ${Me.ToPawn.CombatState} == 1 && !${Me.Target.Type.Equal[Corpse]} && ${Me.TargetHealth} > 0
		{
			if ${lastattack.Equal[${Me.Target.ID}]}
			{
				return TRUE
			}
			if !${lastattack.Equal[${Me.Target.ID}]}
			{
				newattack:Set[TRUE]
				StartAttackTime:Set[${Script.RunningTime}]
				DamageDone:Set[0]
				lastattack:Set[${Me.Target.ID}]
				debuglog "I Should Attack"
				return TRUE
			}

		}
		elseif ${Group.Count} > 1 && ${Me.TargetHealth} <= ${AssistBattlePct} && !${Me.Target.IsDead} && !${Me.Target.Type.Equal[Corpse]} && ${Me.TargetHealth} > 0
		{
			if ${lastattack.Equal[${Me.Target.ID}]}
			{
				return TRUE
			}
			if !${lastattack.Equal[${Me.Target.ID}]}
			{
				newattack:Set[TRUE]
				lastattack:Set[${Me.Target.ID}]
				StartAttackTime:Set[${Script.RunningTime}]
				DamageDone:Set[0]
				debuglog "I Should Attack"
				return TRUE
			}
		}
		return FALSE
	}

}

variable fight fight
;*************************************************************
function SendInPets()
{
	if ${Me.HavePet} && ${fight.ShouldIAttack} || ${Me.HaveMinion} && ${fight.ShouldIAttack}
	{
		VGExecute /pet attack
		VGExecute /minion attack
	}
}

;*************************************************************
function OpeningSpellSequence()
{
	if ${doOpeningSeqSpell} && ${newattack}
	{
		variable iterator Iterator
		debuglog "Running Opening Spell Sequence"
		cleardebug
		actionlog "Attacking ${Me.Target} (Spells)"
		OpeningSpellSequence:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if (!${Me.Ability[${Iterator.Value}].IsReady})
			{
				Iterator:Next
				continue
			}
			if !${fight.ShouldIAttack}
			return
			call checkabilitytocast "${Iterator.Value}"
			if ${Return}
			{
				call executeability "${Iterator.Value}" "attack" "While"
			}
			Iterator:Next
		}
		if ${doOpeningSeqMelee}
		{
			call OpeningMeleeSequence
			return
		}
		if !${doOpeningSeqMelee}
		{
			newattack:Set[FALSE]
			actionlog "No Melee Opening SEQ.  Main Combat"
			return
		}
	}
	if !${doOpeningSeqSpell} && ${newattack}
	{
		if ${doOpeningSeqMelee} && ${newattack}
		{
			call OpeningMeleeSequence
			return
		}
		elseif !${doOpeningSeqMelee} && ${newattack}
		{
			newattack:Set[FALSE]
			cleardebug
			actionlog "No Opening SEQ.  Main Combat"
			return
		}
	}
}

;*************************************************************
function CombatSpellSequence()
{
	variable iterator Iterator
	debuglog "Running Combat Spell Sequence"
	CombatSpellSequence:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${Iterator.Value}"
		if ${Return}
		{
			call executeability "${Iterator.Value}" "attack" "Both"
		}
		Iterator:Next
	}
	return
}

;*************************************************************
function AOESpell()
{
	variable iterator Iterator
	debuglog "Running AOESpell"
	AOESpell:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${Iterator.Value}"
		if ${Return}
		{
			call executeability "${Iterator.Value}" "attack" "Both"

			return
		}
		Iterator:Next
	}
	return
}
;*************************************************************
function DebuffSpells()
{
	variable iterator Iterator
	debuglog "Running Debuff Spell Sequence"
	DebuffSpell:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return
		call checkabilitytocast "${Iterator.Value}"
		if ${Return} && !${Me.TargetDebuff[${Iterator.Value}](exists)}
		{
			call executeability "${Iterator.Value}" "attack" "Both"

			return
		}
		Iterator:Next
	}
	return
}
;*************************************************************
function DotSpells()
{
	variable iterator Iterator
	debuglog "Running Dot Spell Sequence"
	DotSpell:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		debuglog "Checking ${Iterator.Value}"
		call checkabilitytocast "${Iterator.Value}"
		if ${Return} && !${Me.Effect[${Iterator.Value}](exists)}
		{
			debuglog "Should Cast ${Iterator.Value}"
			call executeability "${Iterator.Value}" "attack" "Both"

			return
		}
		Iterator:Next
	}
	return
}
;*************************************************************
function KillingBlowAbility()
{
	if ${Me.TargetHealth} < 15
	{
		call checkabilitytocast "${KillingBlow}"
		if ${Return}
		{
			debuglog "Should Cast ${KillingBlow}"
			call executeability "${KillingBlow}" "attack" "Both"
		}
	}
	Return
}
;*************************************************************
function OpeningMeleeSequence()
{
	variable iterator Iterator
	debuglog "Running Opening Melee Sequence"
	actionlog "Attacking ${Me.Target} (Melee)"
	OpeningMeleeSequence:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${Iterator.Value}"
		if ${Return}
		{
			call executeability "${Iterator.Value}" "attack" "While"
		}
		Iterator:Next
	}
	newattack:Set[FALSE]
	actionlog "Entering Main Combat"
	return
}

;*************************************************************
function CombatMeleeSequence()
{
	variable iterator Iterator
	debuglog "Running Combat Melee Sequence"
	CombatMeleeSequence:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${Iterator.Value}"
		if ${Return}
		{
			call executeability "${Iterator.Value}" "attack" "Both"
		}
		Iterator:Next
	}
	return
}

;*************************************************************
function AOEMelee()
{
	variable iterator Iterator
	debuglog "Running AOEMelee"
	AOEMelee:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${Iterator.Value}"
		if ${Return}
		{
			call executeability "${Iterator.Value}" "attack" "Both"

			return
		}
		Iterator:Next
	}
	return
}
;*************************************************************
function DebuffMelee()
{
	variable iterator Iterator

	debuglog "Running Debuff Spell Sequence"
	DebuffMelee:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${Iterator.Value}"
		if ${Return} && !${Me.TargetDebuff[${Iterator.Value}](exists)}
		{
			call executeability "${Iterator.Value}" "attack" "Both"
			return
		}
		Iterator:Next
	}
	return
}
;*************************************************************
function DotMelee()
{
	variable iterator Iterator
	debuglog "Running Dot Melee Sequence"
	DotMelee:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if (!${Me.Ability[${Iterator.Value}].IsReady})
		{
			Iterator:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		debuglog "Checking ${Iterator.Value}"
		call checkabilitytocast "${Iterator.Value}"
		if ${Return} && !${Me.Effect[${Iterator.Value}](exists)}
		{
			debuglog "Should Cast ${Iterator.Value}"
			call executeability "${Iterator.Value}" "attack" "Both"

			return
		}
		Iterator:Next
	}
	return
}
;*************************************************************
function ToggleOffCombatBuffSpells()
{
	variable iterator Iterator
	debuglog "Running ToggleOffCombatBuffSpells Spell Sequence"
	if !${Me.InCombat}
	{
		DotSpell:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Ability[${Iterator.Value}].Toggled}
			{
				Me.Ability[${Iterator.Value}]:Use
			}
			Iterator:Next
		}
	}
	return
}



