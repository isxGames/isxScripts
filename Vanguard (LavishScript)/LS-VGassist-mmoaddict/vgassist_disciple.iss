


;********************************************
function disciple()
{
	While ${discplmode}
        {
	call Dist_Check
        call discmeleeb
	call heals
        }
	if ${discmel}
	{
	call discmelee
	}
	if ${disccrit}
	{
	call disccritical
	}
	if ${discmeleebuff}
	{
	call discmeleeb
	}
	call discpowerback
}
;********************************************
function discpowerback()
{
  if ${Me.Stat[Adventuring,Jin]} > 17 && ${Me.EnergyPct} < 70 && !${Me.InCombat} && ${Me.Ability[Sun and Moon Discipline IV].IsReady}
	{
	Me.Ability[Sun and Moon Discipline IV]:Use
	Call MeCasting
	}
  if ${Me.Stat[Adventuring,Jin]} > 6 && ${Me.EnergyPct} < 40 && ${Me.Ability[Sun and Moon Discipline IV].IsReady}
	{
	Me.Ability[Sun and Moon Discipline IV]:Use
	Call MeCasting
	}

}
;********************************************
function heals()
{
   Pawn[${assistMember1}]:Target
	wait 5
   if ${Me.DTargetHealth}<60
   {
    Me.Ability[${bigheal}]:Use
    Call MeCasting
   }
   if ${Me.HealthPct}<70
   {
    Pawn[me]:Target
    Me.Ability[${smallheal}]:Use
    Call MeCasting
   }

}
;********************************************
function disccritical()
{
		If ${Me.Ability[${disccritattack1}].IsReady} && ${disccrit}
			{
			Me.Ability[${disccritattack1}]:Use
			call MeCasting
			}
		elseIf ${Me.Ability[${disccritattack2}].IsReady} && ${disccritattack2.Length} > 2 && ${disccrit}
			{
			Me.Ability[${disccritattack2}]:Use
			call MeCasting
			}
		elseIf ${Me.Ability[${disccritattack3}].IsReady} && ${disccritattack3.Length} > 2 && ${disccrit}
			{
			Me.Ability[${disccritattack3}]:Use
			call MeCasting
			}

}
;********************************************
function discmeleeb()
{
		Pawn[${assistMember1}]:Target
		wait 2
		if !${Me.Effect[${discmeleebuff1}](exists)} && ${Me.Stat[Adventuring,Jin]} > 2
			{
			Me.Ability[${discmeleebuff1}]:Use
			wait 3
			Me.Ability[${discmeleebuff2}]:Use
			call MeCasting
			}
		
		

}
;********************************************
function discmelee()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if ${Me.Stat[Adventuring,Jin]} > ${Me.Ability[${discenergyattack1}].JinCost} && ${Me.Ability[${discenergyattack1}].IsReady} && ${Me.EnergyPct} <80
		{
		Me.Ability[${discenergyattack1}]:Use
		call MeCasting
		call clcritical
		}
	if ${Me.Ability[${discmeleeattack1}].IsReady} && ${discmeleerot}==1
		{
		Me.Ability[${discmeleeattack1}]:Use
		bmblastrot:Set[2]
		call MeCasting
		call clcritical
		if ${discmeleeattack2.Length} < 2
			{
			clmeleerot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${discmeleeattack2}].IsReady} && ${discmeleerot}==2
		{
		Me.Ability[${discmeleeattack2}]:Use
		clmeleerot:Set[3]
		call MeCasting
		call clcritical
		if ${discmeleeattack3.Length} < 2
			{
			clmeleerot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${discmeleeattack3}].IsReady} && ${discmeleerot}==3
		{
		Me.Ability[${discmeleeattack3}]:Use
		clmeleerot:Set[1]
		call MeCasting
		call clcritical
		}
		return
	}
	return
}


