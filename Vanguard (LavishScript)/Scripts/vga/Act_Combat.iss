objectdef fight
{
	member:bool ShouldIAttack()
	{
		if ${Group.Count} < 2 && ${Me.ToPawn.CombatState} == 1 && ${Me.Target(exists)} && ${Me.TargetHealth} > 0 && !${Me.Target.IsDead} && ${Me.Target.HaveLineOfSightTo}
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
		if ${Group.Count} > 1 && (${Me.TargetHealth} < ${AssistBattlePct} && ${Me.TargetHealth} > 0 && !${Me.Target.IsDead}) || (${Me.TargetHealth} < ${AssistBattlePct} && ${Me.ToPawn.CombatState} == 1) && ${Me.TargetHealth} > 0 && !${Me.Target.IsDead}
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

 if ${Me.HavePet} && ${fight.ShouldIAttack}
        {
          VGExecute /pet attack
          VGExecute /minion attack
	}
}

;*************************************************************
function OpeningSpellSequence()
{
	debuglog "Running Opening Spell Sequence"
	if ${newattack} && ${doOpeningSeqSpell} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		cleardebug
		actionlog "Attacking ${Me.Target} (Spells)"
		Iterator:First
		variable iterator Iterator
		OpeningSpellSequence:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				call executeability "${Iterator.Value}" "attack" "While"
				Iterator:Next	
				}
			elseif !${Me.Ability[${Iterator.Value}].IsReady} || && !${fight.ShouldIAttack}
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
	debuglog "Running Combat Spell Sequence"
	if !${newattack} && ${doCombatSeqSpell} && ${fight.ShouldIAttack} 
	{

		call CheckPosition
		variable iterator Iterator
		CombatSpellSequence:GetSettingIterator[Iterator]

		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${Iterator.Value}" "attack" "Both"
			}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
	}
	return
}

;*************************************************************
function AOESpell()
{
	debuglog "Running AOESpell"
	if !${newattack} && ${doAOESpell} && ${fight.ShouldIAttack} 
	{
		call TooClose
		variable iterator Iterator
		AOESpell:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				call executeability "${Iterator.Value}" "attack" "Both"

				return
				}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
	}
	return
}
;*************************************************************
function DebuffSpells()
{
	debuglog "Running Debuff Spell Sequence"
	if ${doDebuffSpell}
	{
	if !${newattack} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		variable iterator Iterator
		DebuffSpell:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && !${Me.TargetDebuff[${Iterator.Value}](exists)} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				call executeability "${Iterator.Value}" "attack" "Both"

				return
				}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
	}
	}
	return
}
;*************************************************************
function DotSpells()
{
	debuglog "Running Dot Spell Sequence"
	if ${doDotSpell}
	{
	if !${newattack} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
		variable iterator Iterator
		DotSpell:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			debuglog "Checking ${Iterator.Value}"
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && !${Me.Effect[${Iterator.Value}](exists)} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				debuglog "Should Cast ${Iterator.Value}"
				call executeability "${Iterator.Value}" "attack" "Both"

				return
				}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
		
	}
	}
	return
}
;*************************************************************
function OpeningMeleeSequence()
{
	debuglog "Running Opening Melee Sequence"
	if ${newattack} && ${doOpeningSeqMelee} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
		cleardebug
		actionlog "Attacking ${Me.Target} (Melee)"
		call MoveToTarget
		Iterator:First
		variable iterator Iterator
		OpeningMeleeSequence:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				call executeability "${Iterator.Value}" "attack" "While"
				Iterator:Next	
				}
			if !${Me.Ability[${Iterator.Value}].IsReady} || !${fight.ShouldIAttack}
				Iterator:Next	
		}
		newattack:Set[FALSE]
		actionlog "Entering Main Combat"
		return
	}
}

;*************************************************************
function CombatMeleeSequence()
{
	debuglog "Running Combat Melee Sequence"
	if !${newattack} && ${doCombatSeqMelee} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		variable iterator Iterator
		CombatMeleeSequence:GetSettingIterator[Iterator]

		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${Iterator.Value}" "attack" "Both"
			}
			Iterator:Next
			if !${fight.ShouldIAttack} 
				return
		}
	}
	return
}

;*************************************************************
function AOEMelee()
{
	debuglog "Running AOEMelee"
	if !${newattack} && ${doAOEMelee} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
		variable iterator Iterator
		AOEMelee:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				call executeability "${Iterator.Value}" "attack" "Both"

				return
				}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
	}
	return
}
;*************************************************************
function DebuffMelee()
{
	debuglog "Running Debuff Spell Sequence"
	if ${doDebuffMelee}
	{
	if !${newattack} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
		variable iterator Iterator
		DebuffMelee:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && !${Me.TargetDebuff[${Iterator.Value}](exists)} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				call executeability "${Iterator.Value}" "attack" "Both"

				return
				}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
	}
	}
	return
}
;*************************************************************
function DotMelee()
{
	debuglog "Running Dot Melee Sequence"
	if ${doDotMelee}
	{
	if !${newattack} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
		variable iterator Iterator
		DotMelee:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			call CheckPosition
			debuglog "Checking ${Iterator.Value}"
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return} && !${Me.Effect[${Iterator.Value}](exists)} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{
				debuglog "Should Cast ${Iterator.Value}"
				call executeability "${Iterator.Value}" "attack" "Both"

				return
				}
			Iterator:Next
			if !${fight.ShouldIAttack} 
			return
		}
		
	}
	}
	return
}

;*************************************************************
function functAOECrits()
{
	debuglog "Running AOE Crits"
	if ${doAOECrits} && ${fight.ShouldIAttack}
	{
	call CheckPosition
	variable iterator anIter
	AOECrits:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
	call CheckPosition
	call checkabilitytocast "${anIter.Value}"
	if ${Return} && ${Me.Ability[${anIter.Value}].IsReady} && ${fight.ShouldIAttack}
		{
		call executeability "${anIter.Value}" "attack" "Both"
		}
	anIter:Next
	if !${fight.ShouldIAttack} 
	return
	}
	}
	return
}

;*************************************************************
function functBuffCrits()
{
	debuglog "Running Buff Crits"
	if ${doBuffCrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		variable iterator anIter
		BuffCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.Effect[${anIter.Value}](exists)} && ${Me.Ability[${anIter.Value}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
			if !${fight.ShouldIAttack} 
				return
		}
	}
	return
}
;*************************************************************
function functDotCrits()
{
	debuglog "Running Dot Crits"
	if ${doDotCrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		variable iterator anIter
		DotCrits:GetSettingIterator[anIter]
		anIter:First
	
		while ( ${anIter.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.TargetDebuff[${anIter.Value}](exists)} && ${Me.Ability[${anIter.Value}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
			if !${fight.ShouldIAttack} 
				return
		}
	}
	return
}
;*************************************************************
function counterattack()
{
	debuglog "Running Counter Attacks"
	if ${doCounterAttack} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		variable iterator anIter
		CounterAttack:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && ${Me.Ability[${anIter.Value}].IsReady} 
			{
				if ${Me.Effect[${anIter.Value}](exists)}
				{
					anIter:Next
				}
				if ${Me.TargetDebuff[${anIter.Value}](exists)}
				{
					anIter:Next
				}
				call checkabilitytocast "${anIter.Value}"
				if ${Return} && ${Me.Ability[${anIter.Value}].IsReady} && ${fight.ShouldIAttack} && ${Me.Ability[${anIter.Value}].TriggeredCountdown} == 0
					call executeability "${anIter.Value}" "counter" "Both"
			}
			anIter:Next
			if !${fight.ShouldIAttack} 
			return
		}
	}
	
	return
}
;*************************************************************
function functCombatCrits()
{
	debuglog "Running Combat Crits"
	if ${doCombatCrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		variable iterator anIter
		CombatCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && ${Me.Ability[${anIter.Value}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
			if !${fight.ShouldIAttack} 
				return
		}
	}
	return
}

