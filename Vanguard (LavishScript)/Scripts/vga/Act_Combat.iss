objectdef fight
{
	member:bool ShouldIAttack()
	{
		if ${Group.Count} < 2 && ${Me.Target(exists)} && ${Me.TargetHealth} > 0 && !${Me.Target.IsDead} && ${Me.Target.HaveLineOfSightTo} && ${Me.ToPawn.CombatState} == 1 && !${Me.Target.Type.Equal[Corpse]}
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
		elseif ${Group.Count} > 1 && ${Me.TargetHealth} < ${AssistBattlePct} && !${Me.Target.IsDead} && !${Me.Target.Type.Equal[Corpse]}
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
		elseif ${Group.Count} > 1 && ${${tankpawn}.Equal[${Me}]} && ${Me.ToPawn.CombatState} == 1 && !${Me.Target.IsDead} && !${Me.Target.Type.Equal[Corpse]}
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
	variable iterator Iterator
	
	debuglog "Running Opening Spell Sequence"
	if ${newattack} && ${doOpeningSeqSpell}
	{
		call CheckPosition
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
				
			call CheckPosition
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
	if !${newattack} && ${doCombatSeqSpell}
	{

		call CheckPosition
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
			
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return}
			{
				call executeability "${Iterator.Value}" "attack" "Both"
			}
			Iterator:Next
		}
	}
	return
}

;*************************************************************
function AOESpell()
{
	variable iterator Iterator	
	
	debuglog "Running AOESpell"
	if !${newattack} && ${doAOESpell} && ${fight.ShouldIAttack} 
	{
		call TooClose
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
			
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return}
			{
				call executeability "${Iterator.Value}" "attack" "Both"

				return
			}
			Iterator:Next
		}
	}
	return
}
;*************************************************************
function DebuffSpells()
{
	variable iterator Iterator
	
	debuglog "Running Debuff Spell Sequence"
	if ${doDebuffSpell}
	{
		if !${newattack} && ${fight.ShouldIAttack}
		{
			call CheckPosition
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
				
				call CheckPosition
				call checkabilitytocast "${Iterator.Value}"	
				if ${Return} && !${Me.TargetDebuff[${Iterator.Value}](exists)}
				{
					call executeability "${Iterator.Value}" "attack" "Both"
	
					return
				}
				Iterator:Next
			}
		}
	}
	return
}
;*************************************************************
function DotSpells()
{
	variable iterator Iterator
	
	debuglog "Running Dot Spell Sequence"
	if ${doDotSpell}
	{
		if !${newattack} && ${fight.ShouldIAttack} 
		{
			call CheckPosition
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
				
				call CheckPosition
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
			
		}
	}
	return
}
;*************************************************************
function OpeningMeleeSequence()
{
	variable iterator Iterator
	
	debuglog "Running Opening Melee Sequence"
	if ${newattack} && ${doOpeningSeqMelee} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
		cleardebug
		actionlog "Attacking ${Me.Target} (Melee)"
		call MoveToTarget
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
			
			call CheckPosition
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
}

;*************************************************************
function CombatMeleeSequence()
{
	variable iterator Iterator
	
	debuglog "Running Combat Melee Sequence"
	if !${newattack} && ${doCombatSeqMelee} && ${fight.ShouldIAttack}
	{
		call CheckPosition
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
			
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return}
			{
				call executeability "${Iterator.Value}" "attack" "Both"
			}
			Iterator:Next
		}
	}
	return
}

;*************************************************************
function AOEMelee()
{
	variable iterator Iterator
	
	debuglog "Running AOEMelee"
	if !${newattack} && ${doAOEMelee} && ${fight.ShouldIAttack} 
	{
		call CheckPosition
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
			
			call CheckPosition
			call checkabilitytocast "${Iterator.Value}"	
			if ${Return}
			{
				call executeability "${Iterator.Value}" "attack" "Both"

				return
			}
			Iterator:Next
		}
	}
	return
}
;*************************************************************
function DebuffMelee()
{
	variable iterator Iterator
	
	debuglog "Running Debuff Spell Sequence"
	if ${doDebuffMelee}
	{
		if !${newattack} && ${fight.ShouldIAttack} 
		{
			call CheckPosition
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
				
				call CheckPosition
				call checkabilitytocast "${Iterator.Value}"	
				if ${Return} && !${Me.TargetDebuff[${Iterator.Value}](exists)}
				{
					call executeability "${Iterator.Value}" "attack" "Both"
	
					return
				}
				Iterator:Next
			}
		}
	}
	return
}
;*************************************************************
function DotMelee()
{
	variable iterator Iterator
	
	debuglog "Running Dot Melee Sequence"
	if ${doDotMelee}
	{
		if !${newattack} && ${fight.ShouldIAttack} 
		{
			call CheckPosition
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
				
				call CheckPosition
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
			
		}
	}
	return
}

;*************************************************************
function functAOECrits()
{
	variable iterator anIter
	
	debuglog "Running AOE Crits"
	if ${doAOECrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		AOECrits:GetSettingIterator[anIter]
		anIter:First
	
		while ( ${anIter.Key(exists)} )
		{
			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	}
	return
}

;*************************************************************
function functBuffCrits()
{
	variable iterator anIter
	
	debuglog "Running Buff Crits"
	if ${doBuffCrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		BuffCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.Effect[${anIter.Value}](exists)}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	}
	return
}
;*************************************************************
function functDotCrits()
{
	variable iterator anIter
	
	debuglog "Running Dot Crits"
	if ${doDotCrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		DotCrits:GetSettingIterator[anIter]
		anIter:First
	
		while ( ${anIter.Key(exists)} )
		{
			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.TargetDebuff[${anIter.Value}](exists)}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	}
	return
}
;*************************************************************

;; Amadeus ssys "This function has some odd logic in it..."
function counterattack()
{
	variable iterator anIter
	
	debuglog "Running Counter Attacks"
	if ${doCounterAttack} && ${fight.ShouldIAttack}
	{
		call CheckPosition
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
	variable iterator anIter
	
	debuglog "Running Combat Crits"
	if ${doCombatCrits} && ${fight.ShouldIAttack}
	{
		call CheckPosition
		CombatCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return			
			
			call CheckPosition
			call checkabilitytocast "${anIter.Value}"
			if ${Return}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	}
	return
}

