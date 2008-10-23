function pali()
  {
	call shieldfoc
	if ${palmaintanking}
	{
		While ${Me.InCombat} && ${Me.HealthPct}>0 && !${Me.Target.Type.Equal[CORPSE]} && !${Me.Target.Type.Equal[Resource]}
        	{
		if ${hgrp1}
		{
		call checkgrpmem1
		}
		if ${hgrp2}
		{
		call checkgrpmem2
		}
		if ${hgrp3}
		{
		call checkgrpmem3
		}
		if ${hgrp4}
		{
		call checkgrpmem4
		}
		if ${hgrp5}
		{
		call checkgrpmem5
		}
		if ${hgrp6}
		{
		call checkgrpmem6
		}
		call controlmob
		call palidot
		call palicrit
		call palicounter
		call palicombatbuffs
		call palifight
		call palisolveyourownproblems
        	}
	}
	elseif ${palassisting}
	{
		While ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
        	{
		if ${hgrp1}
		{
		call checkgrpmem1
		}
		if ${hgrp2}
		{
		call checkgrpmem2
		}
		if ${hgrp3}
		{
		call checkgrpmem3
		}
		if ${hgrp4}
		{
		call checkgrpmem4
		}
		if ${hgrp5}
		{
		call checkgrpmem5
		}
		if ${hgrp6}
		{
		call checkgrpmem6
		}
		call palidot
		call palicrit
		call palicounter
		call palicombatbuffs
		call palifight
		call palisolveyourownproblems
        	}
	}
  }

; **************************
function checkgrpmem1()
{
	if ${rhgrp1} && ${Group[1].Health} > 0
		{
		if ${Group[1].Health} < ${rhgrp1pct} && ${Group[1].Health} > ${rhgrp1pct2} && ${Me.Ability[${succor}].IsReady}
			{
			Pawn[${Group[1]}]:Target
			wait 2
			Me.Ability[${succor}]:Use
			call MeCasting
			}
		}
	if ${fhgrp1} && ${Group[1].Health} > 0
		{
		if ${Group[1].Health} < ${fhgrp1pct} && ${Group[1].Health} > ${fhgrp1pct2} && ${Me.Ability[${LayingonofHands}].IsReady}
			{
			Pawn[${Group[1]}]:Target
			wait 2
			Me.Ability[${LayingonofHands}]:Use
			call MeCasting
			}
		}
	if ${bhgrp1} && ${Group[1].Health} > 0
		{
		if ${Group[1].Health} < ${bhgrp1pct} && ${Group[1].Health} > ${bhgrp1pct2} 
			{
			Pawn[${Group[1]}]:Target
			call palrescue
			}
		}
	if ${Pawn[${Group[1]}].IsDead} && !${Me.InCombat} && ${Group[1].Distance} < 20 && ${paliautores}
		{ 
			Pawn[${Group[1]}]:Target
			wait 2
			Me.Ability[${PrayerofLife}]:Use
			Call MeCasting
			return
		}
}
; **************************
function checkgrpmem2()
{
	if ${rhgrp2} && ${Group[2].Health} > 0
		{
		if ${Group[2].Health} < ${rhgrp2pct} && ${Group[2].Health} > ${rhgrp2pct2} && ${Me.Ability[${succor}].IsReady}
			{
			Pawn[${Group[2]}]:Target
			wait 2
			Me.Ability[${succor}]:Use
			call MeCasting
			}
		}
	if ${fhgrp2} && ${Group[2].Health} > 0
		{
		if ${Group[2].Health} < ${fhgrp2pct} && ${Group[2].Health} > ${fhgrp2pct2} && ${Me.Ability[${LayingonofHands}].IsReady}
			{
			Pawn[${Group[2]}]:Target
			wait 2
			Me.Ability[${LayingonofHands}]:Use
			call MeCasting
			}
		}
	if ${bhgrp2} && ${Group[2].Health} > 0
		{
		if ${Group[2].Health} < ${bhgrp2pct} && ${Group[2].Health} > ${bhgrp2pct2} 
			{
			Pawn[${Group[2]}]:Target
			call palrescue
			}
		}
	if ${Pawn[${Group[2]}].IsDead} && !${Me.InCombat} && ${Group[2].Distance} < 20 && ${paliautores}
		{ 
			Pawn[${Group[2]}]:Target
			wait 2
			Me.Ability[${PrayerofLife}]:Use
			Call MeCasting
			return
		}
}
; **************************
function checkgrpmem3()
{
	if ${rhgrp3} && ${Group[3].Health} > 0
		{
		if ${Group[3].Health} < ${rhgrp3pct} && ${Group[3].Health} > ${rhgrp3pct2} && ${Me.Ability[${succor}].IsReady}
			{
			Pawn[${Group[3]}]:Target
			wait 2
			Me.Ability[${succor}]:Use
			call MeCasting
			}
		}
	if ${fhgrp3} && ${Group[3].Health} > 0
		{
		if ${Group[3].Health} < ${fhgrp3pct} && ${Group[3].Health} > ${fhgrp3pct2} && ${Me.Ability[${LayingonofHands}].IsReady}
			{
			Pawn[${Group[3]}]:Target
			wait 2
			Me.Ability[${LayingonofHands}]:Use
			call MeCasting
			}
		}
	if ${bhgrp3} && ${Group[3].Health} > 0
		{
		if ${Group[3].Health} < ${bhgrp3pct} && ${Group[3].Health} > ${bhgrp3pct2} 
			{
			Pawn[${Group[3]}]:Target
			call palrescue
			}
		}
	if ${Pawn[${Group[3]}].IsDead} && !${Me.InCombat} && ${Group[3].Distance} < 20 && ${paliautores}
		{ 
			Pawn[${Group[3]}]:Target
			wait 2
			Me.Ability[${PrayerofLife}]:Use
			Call MeCasting
			return
		}
}
function checkgrpmem4()
{
	if ${rhgrp4} && ${Group[4].Health} > 0
		{
		if ${Group[4].Health} < ${rhgrp4pct} && ${Group[4].Health} > ${rhgrp4pct2} && ${Me.Ability[${succor}].IsReady}
			{
			Pawn[${Group[4]}]:Target
			wait 2
			Me.Ability[${succor}]:Use
			call MeCasting
			}
		}
	if ${fhgrp4} && ${Group[4].Health} > 0
		{
		if ${Group[4].Health} < ${fhgrp4pct} && ${Group[4].Health} > ${fhgrp4pct2} && ${Me.Ability[${LayingonofHands}].IsReady}
			{
			Pawn[${Group[4]}]:Target
			wait 2
			Me.Ability[${LayingonofHands}]:Use
			call MeCasting
			}
		}
	if ${bhgrp4} && ${Group[4].Health} > 0
		{
		if ${Group[4].Health} < ${bhgrp4pct} && ${Group[4].Health} > ${bhgrp4pct2} 
			{
			Pawn[${Group[4]}]:Target
			call palrescue
			}
		}
	if ${Pawn[${Group[4]}].IsDead} && !${Me.InCombat} && ${Group[4].Distance} < 20 && ${paliautores}
		{ 
			Pawn[${Group[4]}]:Target
			wait 2
			Me.Ability[${PrayerofLife}]:Use
			Call MeCasting
			return
		}
}
function checkgrpmem5()
{
	if ${rhgrp5} && ${Group[5].Health} > 0
		{
		if ${Group[5].Health} < ${rhgrp5pct} && ${Group[5].Health} > ${rhgrp5pct2} && ${Me.Ability[${succor}].IsReady}
			{
			Pawn[${Group[5]}]:Target
			wait 2
			Me.Ability[${succor}]:Use
			call MeCasting
			}
		}
	if ${fhgrp5} && ${Group[5].Health} > 0
		{
		if ${Group[5].Health} < ${fhgrp5pct} && ${Group[5].Health} > ${fhgrp5pct2} && ${Me.Ability[${LayingonofHands}].IsReady}
			{
			Pawn[${Group[5]}]:Target
			wait 2
			Me.Ability[${LayingonofHands}]:Use
			call MeCasting
			}
		}
	if ${bhgrp5} && ${Group[5].Health} > 0
		{
		if ${Group[5].Health} < ${bhgrp5pct} && ${Group[5].Health} > ${bhgrp5pct2} 
			{
			Pawn[${Group[5]}]:Target
			call palrescue
			}
		}
	if ${Pawn[${Group[5]}].IsDead} && !${Me.InCombat} && ${Group[5].Distance} < 20 && ${paliautores}
		{ 
			Pawn[${Group[5]}]:Target
			wait 2
			Me.Ability[${PrayerofLife}]:Use
			Call MeCasting
			return
		}
}
function checkgrpmem6()
{
	if ${rhgrp6} && ${Group[6].Health} > 0
		{
		if ${Group[6].Health} < ${rhgrp6pct} && ${Group[6].Health} > ${rhgrp6pct2} && ${Me.Ability[${succor}].IsReady}
			{
			Pawn[${Group[6]}]:Target
			wait 2
			Me.Ability[${succor}]:Use
			call MeCasting
			}
		}
	if ${fhgrp6} && ${Group[6].Health} > 0
		{
		if ${Group[6].Health} < ${fhgrp6pct} && ${Group[6].Health} > ${fhgrp6pct2} && ${Me.Ability[${LayingonofHands}].IsReady}
			{
			Pawn[${Group[6]}]:Target
			wait 2
			Me.Ability[${LayingonofHands}]:Use
			call MeCasting
			}
		}
	if ${bhgrp6} && ${Group[6].Health} > 0
		{
		if ${Group[6].Health} < ${bhgrp6pct} && ${Group[6].Health} > ${bhgrp6pct2} 
			{
			Pawn[${Group[6]}]:Target
			call palrescue
			}
		}
	if ${Pawn[${Group[6]}].IsDead} && !${Me.InCombat} && ${Group[6].Distance} < 20 && ${paliautores}
		{ 
			Pawn[${Group[6]}]:Target
			wait 2
			Me.Ability[${PrayerofLife}]:Use
			Call MeCasting
			return
		}
}
; **************************
function palrescue()
{
	if ${Me.Ability[{Entwine}].IsReady}
	{
	Me.Ability[${Entwine}]:Use
	Call MeCasting
	return
	}
	elseif ${palimaxhate}
	{
		if ${Me.Ability[{Contrition}].IsReady}
		{
		Me.Ability[{Contrition}]:Use
		Call MeCasting
		return
		}
		if ${Me.Ability[{ProtectorsFury}].IsReady}
		{
		Me.Ability[{ProtectorsFury}]:Use
		Call MeCasting
		return
		}
	}
	elseif ${palimaxdps}
	{
		if ${Me.Ability[{ProtectorsFury}].IsReady}
		{
		Me.Ability[{ProtectorsFury}]:Use
		Call MeCasting
		return
		}
		elseif ${Me.Ability[{Contrition}].IsReady}
		{
		Me.Ability[{Contrition}]:Use
		Call MeCasting
		return
		}
		
	}
	
}
; **************************
function controlmob()
{
	if ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Target.Distance} < 6 
	{
	Pawn[${Me.TargetOfTarget}]:Target
	wait 5
	if ${Me.Ability[{Entwine}].IsReady}
		{
		Me.Ability[${Entwine}]:Use
		Call MeCasting
		return
		}
	elseif ${palimaxhate}
		{
		if ${Me.Ability[{Contrition}].IsReady}
		{
		Me.Ability[{Contrition}]:Use
		Call MeCasting
		return
		}
		if ${Me.Ability[{ProtectorsFury}].IsReady}
		{
		Me.Ability[{ProtectorsFury}]:Use
		Call MeCasting
		return
		}
		}
	elseif ${palimaxdps}
		{
		if ${Me.Ability[{ProtectorsFury}].IsReady}
		{
		Me.Ability[{ProtectorsFury}]:Use
		Call MeCasting
		return
		}
		elseif ${Me.Ability[{Contrition}].IsReady}
		{
		Me.Ability[{Contrition}]:Use
		Call MeCasting
		return
		}
		}
	}
	
}
; **************************
function shieldfoc()
{
	if ${shieldfocus.Length} > 4 && !${Me.InCombat} && !${Me.Effect[${shieldfocus}](exists)} 
		{
		Me.Ability[${shieldfocus}]:Use
		call MeCasting
		}
	if ${palistance.Length} > 4 && !${Me.InCombat} && !${Me.Effect[${palistance}](exists)} && ${Me.Form[${palistance}].IsReady}
		{
		Me.Form[${palistance}]:ChangeTo
		call MeCasting
		}
	if ${boonfocus.Length} > 4 && !${Me.InCombat} && !${Me.Effect[${boonfocus}](exists)} && ${Me.Ability[${boonfocus}].IsReady}
		{
		Me.Ability[${boonfocus}]:Use
		call MeCasting
		}
	if ${Me.Stat[Adventuring,Virtue Points]} < 2 && ${Me.Ability[${RighteousSupplication}].IsReady}
		{
		Me.Ability[${RighteousSupplication}]:Use
		call MeCasting
		}
	
}
; **************************
; ** Melee Combat Routine **
; **************************

function palidot()
  {
	if ${usejudgment} && !${Me.TargetDebuff[${judgmentfocus}](exists)} && ${Me.Ability[${judgmentfocus}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${judgmentfocus}]:Use
	Call MeCasting
	call palicrit
	}
	if ${palifightinghealers} && !${Me.TargetDebuff[${DenyLife}](exists)} && ${Me.Ability[${DenyLife}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${DenyLife}]:Use
	Call MeCasting
	call palicrit
	}
	
  }

function palicrit()
  {
	if ${palimaxhate}
	{
	if ${Me.Ability[${StrokeofConviction}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${StrokeofConviction}]:Use
	Call MeCasting
	if ${Me.Ability[${StrokeofFervor}].IsReady}
		{
		Me.Ability[${StrokeofFervor}]:Use
		Call MeCasting
		return
		}
	}
	elseif !${Me.Effect[${Strike of Gloriann}](exists)} && ${Me.Target.Distance} < 6 && ${Me.Ability[${StrikeofGloriann}].IsReady}
	{
	Me.Ability[${StrikeofGloriann}]:Use
	Call MeCasting
	return
	} 
	elseif (${palifightingundead} || ${Me.Effect[${paliundeaddebuff}](exists)}) && ${Me.Ability[${BladeofVolAnari}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${BladeofVolAnari}]:Use
	Call MeCasting
	if ${Me.Ability[${WrathofVolAnari}].IsReady}
		{
		Me.Ability[WrathofVolAnari]:Use
		Call MeCasting
		return
		}
	}
	elseif !${Me.Effect[${VothdarsMightyStrike}](exists)} && ${Me.Target.Distance} < 6 && ${Me.Ability[[${VothdarsMightyStrike}].IsReady}
	{
	Me.Ability[[${VothdarsMightyStrike}]:Use
	Call MeCasting
	return
	}	
	elseif ${Me.Ability[${HammerofValus}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${HammerofValus}]:Use
	Call MeCasting
	if ${Me.Ability[${MaulofValus}].IsReady}
		{
		Me.Ability[${MaulofValus}]:Use
		Call MeCasting
		return
		}
	}
	}
	
	if ${palimaxdps}
	{
	if (${palifightingundead} || ${Me.Effect[${paliundeaddebuff}](exists)}) && ${Me.Ability[${BladeofVolAnari}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${BladeofVolAnari}]:Use
	Call MeCasting
	if ${Me.Ability[${WrathofVolAnari}].IsReady}
		{
		Me.Ability[WrathofVolAnari]:Use
		Call MeCasting
		return
		}
	}
	elseif !${Me.Effect[${VothdarsMightyStrike}](exists)} && ${Me.Target.Distance} < 6 && ${Me.Ability[[${VothdarsMightyStrike}].IsReady}
	{
	Me.Ability[[${VothdarsMightyStrike}]:Use
	Call MeCasting
	return
	}	
	elseif ${Me.Ability[${HammerofValus}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${HammerofValus}]:Use
	Call MeCasting
	if ${Me.Ability[${MaulofValus}].IsReady}
		{
		Me.Ability[${MaulofValus}]:Use
		Call MeCasting
		return
		}
	}
	}
	
   }
function palicounter()
  {
	if ${palimaxhate}
	{
		if ${Me.Ability[${Retort}].IsReady} && ${Me.Target.Distance} < 6 
		{
		Me.Ability[${Retort}]:Use
		Call MeCasting
		Me.Ability[${Retribution}]:Use
		Call MeCasting
		return
		}
		if ${Me.Ability[${Retribution}].IsReady} && ${Me.Target.Distance} < 6 
		{
		Me.Ability[${Retribution}]:Use
		Call MeCasting
		return
		}
	}

	if ${palimaxdps}
	{
		if ${Me.Ability[${Retribution}].IsReady} && ${Me.Target.Distance} < 6 
		{
		Me.Ability[${Retribution}]:Use
		Call MeCasting
		return
		}
		if ${Me.Ability[${Retort}].IsReady} && ${Me.Target.Distance} < 6 
		{
		Me.Ability[${Retort}]:Use
		Call MeCasting
		return
		}
	}
	
   }

function palicombatbuffs()
{
	if !${Me.Effect[${SentinelsBlessing}](exists)} && ${Me.Target.Distance} < 6 && ${Me.Ability[${SentinelsBlessing}].IsReady}
		{
		Me.Ability[${SentinelsBlessing}]:Use
		Call MeCasting
		return
		}
	if !${Me.Effect[${ChampionsMight}](exists)} && ${Me.Target.Distance} < 6 && ${Me.Ability[${ChampionsMight}].IsReady}
		{
		Me.Ability[${ChampionsMight}]:Use
		Call MeCasting
		return
		}
}
function palifight()
{
	if ${palimaxhate}
	{
	if ${Me.TargetHealth} < 15 && ${Me.Ability[${Vanquish}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${Vanquish}]:Use
	Call MeCasting
	call palicrit
	}
	elseif ${Me.Ability[${CryofIllumination}].IsReady} && ${Me.EndurancePct} < 20 && ${Me.TargetHealth} > 30
	{
	Me.Ability[${CryofIllumination}]:Use
	Call MeCasting
	call palicrit
	}
	elseif ${Me.Ability[${Upbraid}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${Upbraid}]:Use
	Call MeCasting
	call palicrit
	}
	elseif ${Me.TargetHealth} > 15 && ${Me.TargetHealth} < 90 && ${Me.Ability[${MarshallingCry}].IsReady} && ${Me.Target.Distance} < 6
	{
	Me.Ability[${MarshallingCry}]:Use
	Call MeCasting
	call palicrit
	}
	elseif ${Me.Ability[${AegisStrike}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${AegisStrike}]:Use
	Call MeCasting
	call palicrit
	}
	elseif ${Me.Ability[${HammerofJudgment}].IsReady} 
	{
	Me.Ability[${HammerofJudgment}]:Use
	Call MeCasting
	call palicrit
	}
	elseif ${Me.Ability[${GuardiansAssault}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${GuardiansAssault}]:Use
	Call MeCasting
	call palicrit
	}

	elseif ${Me.Ability[${HolyStrike}].IsReady} 
	{
	Me.Ability[${HolyStrike}]:Use
	Call MeCasting
	call palicrit
	}
	}
}
function palisolveyourownproblems()
{
	If ${Me.HealthPct} < 20
	{
		if ${Me.Ability[${LayingonofHands}].IsReady} 
		{
		Pawn[Me]:Target
		Me.Ability[${LayingonofHands}]:Use
		}
		elseif ${Me.Ability[${BarrierofFaith}].IsReady}
		{
		Me.Ability[${BarrierofFaith}]:Use
		Call MeCasting
		}
		elseif ${Me.Ability[${FinalStand}].IsReady}
		{
		Me.Ability[${FinalStand}]:Use
		Call MeCasting
		}
		elseif ${Me.Ability[${DevoutFoeman}].IsReady}
		{
		Me.Ability[${DevoutFoeman}]:Use
		Call MeCasting
		}
		elseif ${Me.Ability[${CryofSolace}].IsReady}
		{
		Me.Ability[${CryofSolace}]:Use
		Call MeCasting
		}
	}
}