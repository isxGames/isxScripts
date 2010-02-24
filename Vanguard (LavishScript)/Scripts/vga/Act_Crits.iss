;*************************************************************
function functAOECrits()
{
	variable iterator anIter
	debuglog "Running AOE Crits"
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
			
			
			call checkabilitytocast "${anIter.Value}" 
			if ${Return} && ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
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
			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.Effect[${anIter.Value}](exists)} && ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
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
			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return
			
			
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && !${Me.TargetDebuff[${anIter.Value}](exists)} && ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
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
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
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
				if ${Return} && ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0 
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

			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack} 
				return			
			
			
			call checkabilitytocast "${anIter.Value}"
			if ${Return} && ${Me.Ability[${anIter.Value}].TriggeredCountdown}==0
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	}
	return
}

