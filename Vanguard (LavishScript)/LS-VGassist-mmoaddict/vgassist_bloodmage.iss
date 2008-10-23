


;********************************************
function bloodmage()
{
	if ${bmmeleetarg}
	{
	call bmmelee
	}
	if ${bmblasttarg}
	{
	call bmblast
	}
	if ${bmdottarg}
	{
	call bmdot
	}
	if ${bmcrittarg}
	{
	call bmcrit
	}
	if ${bmbloodtarg}
	{
	call bmblood
	}
}

;********************************************
function bmmelee()
{
	call assist
	call movetomelee
	while ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
		{
		Face
		VG:ExecBinding[movebackward]
		wait 1
		VG:ExecBinding[movebackward,release]
		}
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 7 && ${Me.TargetHealth} < ${mtotpct} && ${Me.Ability[${bmmeleeattack1}].IsReady} && ${Me.Endurance} > ${Me.Ability[${bmmeleeattack1}].EnduranceCost}
	{
	Me.Ability[${bmmeleeattack1}]:Use
	Call MeCasting
	}
}
;********************************************
function bmblast()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if ${Me.Ability[${bmblastattack1}].IsReady} && ${bmblastrot}==1
		{
		Me.Ability[${bmblastattack1}]:Use
		Call MeCasting
		bmblastrot:Set[2]
		if ${bmblastattack2.Length} < 2
			{
			bmblastrot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${bmblastattack2}].IsReady} && ${bmblastrot}==2
		{
		Me.Ability[${bmblastattack2}]:Use
		Call MeCasting
		bmblastrot:Set[3]
		if ${bmblastattack3.Length} < 2
			{
			bmblastrot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${bmblastattack3}].IsReady} && ${bmblastrot}==3
		{
		Me.Ability[${bmblastattack3}]:Use
		Call MeCasting
		bmblastrot:Set[1]
		}
		return
	}
	return
}
;********************************************
function bmblood()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if ${Me.Ability[${bmbloodattack1}].IsReady} && ${bmbloodrot}==1 
		{
		Me.Ability[${bmbloodattack1}]:Use
		Call MeCasting
		bmbloodrot:Set[2]
		if ${bmbloodattack2.Length} < 2
			{
			bmbloodrot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${bmbloodattack2}].IsReady} && ${bmbloodrot}==2
		{
		Me.Ability[${bmbloodattack2}]:Use
		Call MeCasting
		bmbloodrot:Set[3]
		if ${bmbloodattack3.Length} < 2
			{
			bmbloodrot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${bmbloodattack3}].IsReady} && ${bmbloodrot}==3
		{
		Me.Ability[${bmbloodattack3}]:Use
		Call MeCasting
		bmbloodrot:Set[1]
		}
		return
	}
	return
}
;********************************************
function bmdot()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if ${Me.TargetMyDebuff[${bmdotattack1}](exists)}
		{
		if ${Me.TargetMyDebuff[${bmdotattack2}](exists)}
			{
			if ${Me.TargetMyDebuff[${bmdotattack3}](exists)}
				{
				return
				}
			elseif ${Me.TargetHealth} > 30 && ${bmdotattack3.Length} > 2
				{
				Me.Ability[${bmdotattack3}]:Use
				Call MeCasting
				return
				}
			}
		elseif ${Me.TargetHealth} > 30 && ${bmdotattack2.Length} > 2
			{
			Me.Ability[${bmdotattack2}]:Use
			Call MeCasting
			return
			}
		}
	elseif ${Me.TargetHealth} > 30 && ${bmdotattack1.Length} > 2
		{
		Me.Ability[${bmdotattack1}]:Use
		Call MeCasting
		return
		}

	}
	return
}
;********************************************
function bmcrit()
{
		If ${Me.Ability[${bmcritattack1}].IsReady} && ${bmcrittarg}
			{
			Me.Ability[${bmcritattack1}]:Use
			Call MeCasting
			}
		elseIf ${Me.Ability[${bmcritattack2}].IsReady} && ${bmcritattack2.Length} > 2 && ${bmcrittarg}
			{
			Me.Ability[${bmcritattack2}]:Use
			call MeCasting
			}
		elseIf ${Me.Ability[${bmcritattack3}].IsReady} && ${bmcritattack2.Length} > 2 && ${bmcrittarg}
			{
			Me.Ability[${bmcritattack3}]:Use
			call MeCasting
			}

}

