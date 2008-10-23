function sorcy()
{
	if !${useaegroup}
		{
   		call sorcfull
		call gather
		call sorcamplify
		call awkgettingattacked
		}
	if ${useaegroup}
		{
   		call aegrp
		call gather
		call sorcamplify
		call awkgettingattacked
		}
}
;********************************************
;********************************************
function aegrp()
{
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
		If ${Me.Ability[${SeradonsFallingStar}].IsReady} && ${useice}
			{
			Me.Ability[${Freeze}]:Use
			Call MeCasting
			call countcast
			Me.Ability[${SeradonsFallingStar}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			call sorccrit
			}
		If ${Me.Ability[${BlindingFire}].IsReady} && ${usefire}
			{
			Me.Ability[${Char}]:Use
			Call MeCasting
			call countcast
			Call critical
			Me.Ability[${BlindingFire}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			}

		If ${Me.Ability[${ShockingGrasp}].IsReady} && ${usearcane} && ${Me.EndurancePct} > 60
			{
			Me.Ability[${ShockingGrasp}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			} 
		If ${Me.Ability[${ChaosVolley}].IsReady} && ${usearcane}
			{
			Me.Ability[${ChaosVolley}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			} 
		If ${Me.Ability[${FlameSpear}].IsReady} && ${usefire}
			{
			Me.Ability[${FlameSpear}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			call sorccrit
			}
	}
}
;********************************************
function sorcfull()
{
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
		If ${Me.Ability[${Mimic}].IsReady}  || ${Me.Ability[${Incinerate}].IsReady} || ${Me.Ability[${InidriasInferno}].IsReady}
			{
			call sorccrit
			}
		If ${Me.Ability[${SeradonsFallingStar}].IsReady} && ${useice}
			{
			Me.Ability[${SeradonsFallingStar}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			call sorccrit
			}
		If ${Me.Ability[${Char}].IsReady} && ${usefire}
			{
			Me.Ability[${Char}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			call sorccrit
			}
		If ${Me.Ability[${TaqmirsBolts}].IsReady} && ${usearcane} && ${Me.Endurance} > 60
			{
			Me.Ability[${TaqmirsBolts}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			} 
		If ${Me.Ability[${ChaosVolley}].IsReady} && ${usearcane}
			{
			Me.Ability[${ChaosVolley}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			} 
	}
}
;********************************************
function sorcamplify()
{
	if ${useamplify}
	{
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 20 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < 70 && ${Me.InCombat} && ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]} && (${Me.Ability[${AmplifyDestruction}].IsReady} || ${Me.Ability[${AmplifyEfficiency}].IsReady})
	{
		If ${Me.Ability[${SeradonsFallingStar}].IsReady} && ${useice} 
			{
			If ${Me.Ability[${AmplifyDestruction}].IsReady}
				{
				Me.Ability[${AmplifyDestruction}]:Use
				Call MeCasting
				}
			ElseIf ${Me.Ability[${AmplifyEfficiency}].IsReady}
				{
				Me.Ability[${AmplifyEfficiency}]:Use
				Call MeCasting
				}	
			
			Me.Ability[${SeradonsFallingStar}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			call sorccrit
			}
		If ${Me.Ability[${ChaosVolley}].IsReady} && ${usearcane}
			{
			If ${Me.Ability[${AmplifyDestruction}].IsReady}
				{
				Me.Ability[${AmplifyDestruction}]:Use
				Call MeCasting
				}
			ElseIf ${Me.Ability[${AmplifyEfficiency}].IsReady}
				{
				Me.Ability[${AmplifyEfficiency}]:Use
				Call MeCasting
				}	
			Me.Ability[${ChaosVolley}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			} 
		If ${Me.Ability[${Char}].IsReady} && ${usefire}
			{
			Me.Ability[${Char}]:Use
			Call MeCasting
			call countcast
			If ${Me.Ability[${AmplifyDestruction}].IsReady}
				{
				Me.Ability[${AmplifyDestruction}]:Use
				Call MeCasting
				}
			ElseIf ${Me.Ability[${AmplifyEfficiency}].IsReady}
				{
				Me.Ability[${AmplifyEfficiency}]:Use
				Call MeCasting
				}	
			Me.Ability[${Char}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			Call sorccrit
			}
		
	}
	}
}
;********************************************
function awkgettingattacked()
{ 
	while ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${usesorcforget} && !${Me.Ability[${Forget}].IsReady} 
	{
	wait 1
	}
	if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${usesorcforget} && ${Me.Ability[${Forget}].IsReady} 
	{
	Me.Ability[${Forget}]:Use
	call MeCasting
	while ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${usesorcforget} && !${Me.Ability[${Forget}].IsReady} 
		{
		wait 1
		}
	}
	return
}
;********************************************
function countcast()
{
	waitframe
  	if ${usesorcforget} && ${Me.Ability[${Forget}].IsReady} 
	{
	sorccountcast:Set[${sorccountcast} + 1]
	if ${sorccountcast} > ${sorcforgetnumber}
	{
	Me.Ability[${Forget}]:Use
	call MeCasting
	sorccountcast:Set[0]
	}
	return
	}
}
;********************************************
function gather()
{
	If ${Me.Ability[${GatherEnergy}].IsReady} && ${Me.InCombat} && ${Me.Endurance}<60 && ${Me.EnergyPct} < 10
		{
		While ${Me.Endurance} < 70
			{
			wait 1
			}
		}
	
	If ${Me.Ability[${GatherEnergy}].IsReady} && ${Me.InCombat} && ${Me.Endurance}>60 && ${Me.EnergyPct} < 10
			{
			Me.Ability[${GatherEnergy}]:Use
			while ${Me.Endurance} > 10 || ${Me.EnergyPct} < 80
			{		
			wait 1
			}
			} 
}
;********************************************
function sorcslowmedown()
{
  If ${usesorcslowcasting} && ${sorcslowcastingspeed} > 0
   {
    wait ${sorcslowcastingspeed}
   }
  return
}
;********************************************
function sorccrit()
{
	If ${Me.Ability[${Mimic}].IsReady}
		{
		Me.Ability[${Mimic}]:Use
		Call MeCasting
		call sorcslowmedown
		call countcast
		}
	If ${Me.Ability[${InidriasInferno}].IsReady}
			{
			Me.Ability[${InidriasInferno}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			}
	If ${Me.Ability[${Incinerate}].IsReady}  && ${usefire}
		{
		Me.Ability[${Incinerate}]:Use
		Call MeCasting
		call sorcslowmedown
		call countcast
			If ${Me.Ability[${InidriasInferno}].IsReady}
			{
			Me.Ability[${InidriasInferno}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			}
		}
	If ${Me.Ability[${ColdWave}].IsReady}  && (${usearea} || ${useaegroup})
		{
		Me.Ability[${ColdWave}]:Use
		Call MeCasting
		call sorcslowmedown
		call countcast
			If ${Me.Ability[${InidriasFrigidBlast}].IsReady}
			{
			Me.Ability[${InidriasFrigidBlast}]:Use
			Call MeCasting
			call sorcslowmedown
			call countcast
			}
		}
}