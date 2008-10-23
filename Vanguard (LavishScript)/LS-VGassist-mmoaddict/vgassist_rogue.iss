


;********************************************
function rog()
{
	call rgopener
	call rgmelee
	call stealth
	call rgcausecrit
	call rgcounter
	call rgenergy
	call rgcrit
	call rgcombatretreat
	call rgfinisher
	; call rgsmoker
	call scrollbuff
}
;********************************************
function rgopener()
{
	if !${Me.InCombat} && ${Pawn[${assistMember1}].Distance} < 11 && ${Pawn[${assistMember1}].CombatState} > 0 && ${Me.TargetHealth} < ${mtotpct}  && ${Me.TargetHealth} > 0
		{
		Wait 20
		Me.Ability[${SmokeTrick}]:Use
		wait 5
		Me.Ability[${Ravage}]:Use
		wait 5
		call movetoobject ${Pawn[${Me.Target}].ID} 4 0
		while ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
				{
					Face
					VG:ExecBinding[movebackward]
					wait 1
					VG:ExecBinding[movebackward,release]
				}
		call MeCasting
		call rgcrit
		}
	return
}
;********************************************
function scrollbuff()
{
	if !${Me.InCombat} && !${Me.Effect[${dexbuff}](exists)} 
		{
		Me.Inventory[${dexscroll}]:Use
		call MeCasting
		}
	if !${Me.InCombat} && !${Me.Effect[${strbuff}](exists)} 
		{
		Me.Inventory[${strscroll}]:Use
		call MeCasting
		}
	if !${Me.InCombat} && !${Me.Effect[${poison}](exists)} 
		{
		Me.Inventory[${poison}]:Use
		call MeCasting
		}
	return
}
;********************************************
function rgsmoker()
{
	if ${Me.InCombat} && ${Pawn[${assistMember1}].CombatState} > 0 && !${Me.Effect[Stalking I](exists)} && ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]} && !${Me.Ability[${Stalk}].IsReady}
	{
	Me.Ability[${SmokeBomb}]:Use
	wait 5
	Me.Ability[${SmokeTrick}]:Use
	wait 5
	if !${Me.Effect[Stalking I](exists)}
		{
		Me.Ability[${Backstab}]:Use
		}
	call MeCasting
	}
	return
}
;********************************************
function rgcounter()
{
	if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Target(exists)} && ${Me.TargetHealth} > 15
	{
		if ${Me.Ability[${Drub}].IsReady}
		{
		Me.Ability[${Drub}]:Use
		call MeCasting
		}
	if ${Me.Ability[${Ploy}].IsReady} && ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Target(exists)} && ${Me.TargetHealth} > 15
		{
		echo he is attacking me
		Me.Ability[${Ploy}]:Use
		call MeCasting
		Me.Ability[${Fade}]:Use
		call MeCasting
			if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]}
			{
			VGExecute /assist ${assistMember1}
			wait 1
			Me.Ability[${SmokeTrick}]:Use
			wait 5
			Me.Ability[${TrickAttack}]:Use
			call MeCasting
				if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${Flee}].IsReady}
				{
				Me.Ability[${Flee}]:Use
				call MeCasting
				
					if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${Deter}].IsReady}
					{
					Me.Ability[${Deter}]:Use
					call MeCasting
						if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${BlindingFlash}].IsReady}
						{
						Me.Ability[${BlindingFlash}]:Use
						call MeCasting
						}
					}
						
					elseif ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${ElusiveMark}].IsReady}
					{
					Me.Ability[${ElusiveMark}]:Use
					call MeCasting
						if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${BlindingFlash}].IsReady}
						{
						Me.Ability[${BlindingFlash}]:Use
						call MeCasting
						}
					}
				}
			}
		}
	elseif !${Me.Ability[${Ploy}].IsReady} && ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Target(exists)} && ${Me.TargetHealth} > 15
		{
		VGExecute /assist ${assistMember1}
		wait 1
		Me.Ability[${SmokeTrick}]:Use
		wait 5
		Me.Ability[${TrickAttack}]:Use
		call MeCasting
			if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${Flee}].IsReady}
				{
				Me.Ability[${Flee}]:Use
				call MeCasting
				
					if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${Deter}].IsReady}
					{
					Me.Ability[${Deter}]:Use
					call MeCasting
						if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${BlindingFlash}].IsReady}
						{
						Me.Ability[${BlindingFlash}]:Use
						call MeCasting
						}
					}
					elseif ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${ElusiveMark}].IsReady}
					{
					Me.Ability[${ElusiveMark}]:Use
					call MeCasting
						if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${BlindingFlash}].IsReady}
						{
						Me.Ability[${BlindingFlash}]:Use
						call MeCasting
						}
					}
				}
		}
	}
	return
}
;********************************************
function rgcombatretreat()
{
	VGExecute /assist ${assistMember1}
	wait 1
	if ${Me.DTargetHealth} < 1 && ${Me.Ability[${Flee}].IsReady}
	{
	Me.Ability[${Flee}]:Use
	wait 5
	Paused:Set[True]
	}
}
;********************************************
function rgcausecrit()
{
	if ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${Blindside}].IsReady} && ${Me.Ability[${Backstab}].IsReady} && ${Me.TargetHealth} > 30 && ${Me.TargetHealth} < 80
		{
		Me.Ability[${Blindside}]:Use
		call MeCasting
		Me.Ability[${Backstab}]:Use
		call MeCasting
		call rgcrit
		}
	if ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${Quickblade}].IsReady} && ${Me.Energy} > 345 && ${Me.Ability[${Backstab}].IsReady} && ${Me.TargetHealth} > 30 && ${Me.TargetHealth} < 80
		{
		Me.Ability[${Quickblade}]:Use
		call MeCasting
		Me.Ability[${Backstab}]:Use
		call MeCasting
		call rgcrit
		}
	return
}
;********************************************
function rgenergy()
{
	if ${Me.InCombat} && ${Me.EndurancePct} < 50 && ${Me.TargetHealth} < 90 && ${Me.TargetHealth} > 20 && ${Me.EnergyPct} > 40 && !${Me.Effect[${Relentless}](exists)} && ${Me.Ability[${Relentless}].IsReady}
		{
		Me.Ability[${Relentless}]:Use
		call MeCasting
		}
	elseif ${Me.InCombat} && ${Me.TargetHealth} > 10 && ${Me.TargetHealth} < 95 && ${Me.EnergyPct} > 60 && !${Me.Effect[${LethalStrikes}](exists)}
		{
		Me.Ability[${LethalStrikes}]:Use
		wait 2
		}
	elseif (${Me.InCombat} && ${Me.TargetHealth} < 10 && ${Me.Effect[${LethalStrikes}](exists)}) || (!${Me.InCombat} && ${Me.Effect[${LethalStrikes}](exists)})
		{
		Me.Ability[${LethalStrikes}]:Use
		wait 2
		}
	elseif ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${KeenEye}].IsReady} && ${Me.EnergyPct} > 40 && ${Me.TargetHealth} > 30 && ${Me.TargetHealth} < 80
		{
		Me.Ability[${KeenEye}]:Use
		call MeCasting
		}
	return
}
;********************************************
function stealth()
{
	if ${Pawn[${assistMember1}].IsMounted} && ${Me.Effect[Stalking I](exists)}
	{
	Me.Ability[${Stalk}]:Use
	}
	
	if !${Me.InCombat} && !${Me.Effect[Stalking I](exists)} && !${Pawn[${assistMember1}].IsMounted} && !${Me.Effect[${ourbard}'s Bard Song - "${bardrunsong}"](exists)}
	{
	Me.Ability[${Stalk}]:Use
	}
	if !${Me.InCombat} && ${Me.Effect[Stalking I](exists)}  && ${Me.Effect[${ourbard}'s Bard Song - "${bardrunsong}"](exists)}
	{
	Me.Ability[${Stalk}]:Use
	}
	if ${Pawn[${myname}].IsMounted} && ${Me.Effect[Stalking I](exists)}		
	{
	Me.Ability[${Stalk}]:Use
	}
	

	return
}
;********************************************
function rgfinisher()
{
	if ${Me.TargetHealth} < 20 && ${Me.Ability[${FatalStroke}].IsReady} && ${Me.InCombat}
		{
		Me.Ability[${FatalStroke}]:Use
		call MeCasting
		call rgcrit
		}
	return
}
;********************************************
function rgmelee()
{
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct} && ${Pawn[${assistMember1}].CombatState} > 0 && ${Me.InCombat}
	{
	VGExecute /stand
	call assist
	call movetomelee
	call facemob
	if ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
		{
		while ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
				{
					Face
					VG:ExecBinding[movebackward]
					wait 1
					VG:ExecBinding[movebackward,release]
				}
		}
	
	elseif ${Me.Ability[${Lacerate}].IsReady} && !${Me.TargetDebuff[${Lacerate}](exists)} 
		{
		Me.Ability[${Lacerate}]:Use
		call MeCasting
		call rgcrit
		return
		}
	elseif ${Me.Ability[${eviscerate}].IsReady} 
		{
		Me.Ability[${eviscerate}]:Use
		call MeCasting
		call rgcrit
		return
		}
	elseif ${Me.Ability[${Backstab}].IsReady} 
		{
		Me.Ability[${Backstab}]:Use
		call MeCasting
		call rgcrit
		return
		}
	elseif ${Me.Ability[${TrickAttack}].IsReady} && ${Me.EndurancePct} > 20
		{
		Me.Ability[${TrickAttack}]:Use
		call MeCasting
		call rgcrit
		return
		}
	elseif ${Me.Ability[${WickedStrike}].IsReady} && ${Me.EndurancePct} > 20
		{
		Me.Ability[${WickedStrike}]:Use
		call MeCasting
		call rgcrit
		return
		}
	}
	elseif ${Pawn[${Me.Target}].Distance} < 1  && ${Me.InCombat} && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25
	{
		call assist
		call movetomelee
		call facemob
	}
	return
}


;********************************************
function rgcrit()
{
		if !${Me.TargetDebuff[${Hemorrhage}](exists)} && ${Me.Ability[${Hemorrhage}].IsReady}
		{
		Me.Ability[${Hemorrhage}]:Use
		call MeCasting
		if ${Me.Ability[${Impale}].IsReady}
			{
			Me.Ability[${Impale}]:Use
			call MeCasting
			}
		elseif !${Me.Ability[${Impale}].IsReady}
			{
			return
			}
		Me.Ability[${TrickAttack}]:Use
		}
		elseIf ${Me.Ability[${Shank}].IsReady} && ${myname.NotEqual[${Pawn[${Me.TargetOfTarget}]}]}
		{
			Me.Ability[${Shank}]:Use
			call MeCasting
			if ${Me.Ability[${Shiv}].IsReady}
				{
				Me.Ability[${Shiv}]:Use
				call MeCasting
				}
			elseif !${Me.Ability[${Shiv}].IsReady}
				{
				return
				}
			VGExecute /assist ${assistMember1}
			wait 1
			Me.Ability[${TrickAttack}]:Use
			call MeCasting
		}
		elseIf ${Me.Ability[${ViciousStrike}].IsReady}
		{
			Me.Ability[${ViciousStrike}]:Use
			call MeCasting
			if ${Me.Ability[${DeadlyStrike}].IsReady}
				{
				Me.Ability[${DeadlyStrike}]:Use
				call MeCasting
				}
			elseif !${Me.Ability[${DeadlyStrike}].IsReady}
				{
				return
				}
			VGExecute /assist ${assistMember1}
			wait 1
			Me.Ability[${TrickAttack}]:Use
			call MeCasting
		}
		
}



