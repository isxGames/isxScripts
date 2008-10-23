


;********************************************
function cleric()
{
	if ${clmeleetarg}
	{
	call clmelee
	}
	if ${clcrit}
	{
	call clcritical
	}
	if ${clmeleebuff}
	{
	call clmeleeb
	}
}

;********************************************
function clcritical()
{
		If ${Me.Ability[${clcritattack1}].IsReady} && ${clcrit}
			{
			Me.Ability[${clcritattack1}]:Use
			call MeCasting
			}
		elseIf ${Me.Ability[${clcritattack2}].IsReady} && ${clcritattack2.Length} > 2 && ${clcrit}
			{
			Me.Ability[${clcritattack2}]:Use
			call MeCasting
			}
		elseIf ${Me.Ability[${clcritattack3}].IsReady} && ${clcritattack3.Length} > 2 && ${clcrit}
			{
			Me.Ability[${clcritattack3}]:Use
			call MeCasting
			}

}
;********************************************
function clmeleeb()
{
		if ${Me.Effect[${clmeleebuff1}](exists)}
			{
			if ${Me.Effect[${clmeleebuff2}](exists)}
				{
				return
				}
			elseIf ${Me.Ability[${clmeleebuff2}].IsReady} && ${Me.InCombat} && ${Me.TargetHealth} > 40 && ${clmeleebuff2.Length} > 2  
				{
				Me.Ability[${clmeleebuff2}]:Use
				call MeCasting
				}	
			}
		elseIf ${Me.Ability[${clmeleebuff1}].IsReady} && ${Me.InCombat} && ${Me.TargetHealth} > 40
			{
			Me.Ability[${clmeleebuff1}]:Use
			call MeCasting
			}
		
		

}
;********************************************
function clmelee()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if ${Me.Ability[${clenergyattack1}].IsReady} && ${Me.EnergyPct} <80
		{
		Me.Ability[${clenergyattack1}]:Use
		call MeCasting
		call clcritical
		}
	if ${Me.Ability[${clmeleeattack1}].IsReady} && ${clmeleerot}==1
		{
		Me.Ability[${clmeleeattack1}]:Use
		call MeCasting
		bmblastrot:Set[2]
		call clcritical
		if ${clmeleeattack2.Length} < 2
			{
			clmeleerot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${clmeleeattack2}].IsReady} && ${clmeleerot}==2
		{
		Me.Ability[${clmeleeattack2}]:Use
		call MeCasting
		clmeleerot:Set[3]
		call clcritical
		if ${clmeleeattack3.Length} < 2
			{
			clmeleerot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${clmeleeattack3}].IsReady} && ${clmeleerot}==3
		{
		Me.Ability[${clmeleeattack3}]:Use
		call MeCasting
		clmeleerot:Set[1]
		call clcritical
		}
		return
	}
	return
}



