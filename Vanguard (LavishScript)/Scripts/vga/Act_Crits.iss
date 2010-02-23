;*************************************************************
function functAOECrits()
{
	variable iterator anIter
	debuglog "Running AOE Crits"
		AOECrits:GetSettingIterator[anIter]
		anIter:First
	
		while ( ${anIter.Key(exists)} )
		{
			;; Check next AOE Crit if not ready
			if ${Me.Ability[${anIter.Value}].TimeRemaining}>0 || ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
				continue

			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			
			call checkabilitytocast "${anIter.Value}"
			if ${Return}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	return
}

;*************************************************************
function functBuffCrits()
{
	variable iterator anIter
	debuglog "Running Buff Crits"
		BuffCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			;; Check next Buff Crit if not ready
			if ${Me.Ability[${anIter.Value}].TimeRemaining}>0 || ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
			{
				anIter:Next
				continue
			}

			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.Effect[${anIter.Value}](exists)}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	return
}
;*************************************************************
function functDotCrits()
{
	variable iterator anIter
	
	debuglog "Running Dot Crits"
		DotCrits:GetSettingIterator[anIter]
		anIter:First
	
		while ( ${anIter.Key(exists)} )
		{
			;; Check next DOT Crit if not ready
			if ${Me.Ability[${anIter.Value}].TimeRemaining}>0 || ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
			{
				anIter:Next
				continue
			}

			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.TargetDebuff[${anIter.Value}](exists)}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	return
}
;*************************************************************

;; Amadeus ssys "This function has some odd logic in it..."
function functCounterAttacks()
{
	variable iterator anIter
	
	debuglog "Running Counter Attacks"
		CounterAttack:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{

			;; Check next Counters if not ready
			if ${Me.Ability[${anIter.Value}].TimeRemaining}>0 || ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
			{
				anIter:Next
				continue
			}
		
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
				if ${Return} 
					call executeability "${anIter.Value}" "counter" "Both"
			}
			anIter:Next
			if !${fight.ShouldIAttack} 
			return
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
		
		CombatCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			;; Check next Combat Crit if not ready
			if ${Me.Ability[${anIter.Value}].TimeRemaining}>0 || ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
			{
				anIter:Next
				continue
			}

			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return			
			
			
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

