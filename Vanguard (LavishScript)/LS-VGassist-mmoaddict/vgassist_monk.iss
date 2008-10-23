


;********************************************
function monky()
{
	while ${Me.Effect[Feign Death III](exists)}
	{
	wait 1
	}
	
	call pushag
	call mkmelee
	call jinbuff
	call jinattack
	; call medup
	call mkcrit

	
}
;********************************************
function mkmelee()
{
	
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	VGExecute /stand
	call assist
	call movetomelee
	call facemob
	if !${Me.TargetDebuff[Feet of the Fire Dragon IV](exists)}
		{
		Me.Ability[Feet of the Fire Dragon IV]:Use
		call MeCasting
		call mkcrit
		}
	if ${Me.Ability[Crescent Kick VI].IsReady}
		{
		Me.Ability[Crescent Kick VI]:Use
		call MeCasting
		call mkcrit
		}
	if ${Me.Ability[Boundless Fist VII].IsReady}
		{
		Me.Ability[Boundless Fist VII]:Use
		call MeCasting
		call mkcrit
		}
	}
	elseif ${Pawn[${Me.Target}].Distance} < 2  && ${Me.InCombat} && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25
	{
		VGExecute /stand
		call assist
		call movetomelee
		call facemob
	}
	return
	
}
;********************************************
function jinbuff()
{
	
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	VGExecute /stand
	call assist
	call movetomelee
	call facemob
	if !${Me.Effect[Iron Hand VI](exists)} && ${Me.Ability[Iron Hand VI].IsReady}
		{
		Me.Ability[Iron Hand VI]:Use
		call MeCasting
		}
	if !${Me.Effect[Secret of Flames VI](exists)} && ${Me.Ability[Secret of Flames VI].IsReady}
		{
		Me.Ability[Secret of Flames VI]:Use
		call MeCasting
		}
	if ${Me.Ability[Fists of Celerity].IsReady}
		{
		Me.Ability[Fists of Celerity]:Use
		call MeCasting
		call mkcrit
		}
	}
	return
}
;********************************************
function jinattack()
{
	
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	VGExecute /stand
	call assist
	call movetomelee
	call facemob
	if ${Me.Ability[Dragon's Rage III].IsReady}
		{
		Me.Ability[Dragon's Rage III]:Use
		call MeCasting
		call mkcrit
		return
		}
	if ${Me.Ability[Cloud Dragon's Ruse III].IsReady}
		{
		Me.Ability[Cloud Dragon's Ruse III]:Use
		call MeCasting
		call mkcrit
		return
		}
	if ${Me.Ability[Ashen Hand VII].IsReady}
		{
		Me.Ability[Ashen Hand VII]:Use
		call MeCasting
		call mkcrit
		return
		}
	}
	return
}
;********************************************
function pushag()
{
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	VGExecute /stand
	call assist
	call movetomelee
	call facemob
	if ${Me.Ability[Goading Slap IV].IsReady}
		{
		Pawn[${assistMember1}]:Target
		wait 2
		Me.Ability[Goading Slap IV]:Use
		call MeCasting
		call mkcrit
		}
	}
	return
}
;********************************************
function medup()
{
	if ${Pawn[${assistMember1}].CombatState} < 1 && !${Me.InCombat} && !${autofollow} && !${Me.Effect[Meditation](exists)}
	{
	Me.Ability[Meditation]:Use
	wait 2
	}
	return
}
;********************************************
function mkcrit()
{
		If ${Me.Ability[Three Finger Strike].IsReady}
			{
			Me.Ability[Three Finger Strike]:Use
			call MeCasting
			}
		If ${Me.Ability[Hammer Fist].IsReady}
			{
			Me.Ability[Hammer Fist]:Use
			call MeCasting
			}
		If ${Me.Ability[Palm Explodes the Heart].IsReady}
			{
			Me.Ability[Palm Explodes the Heart]:Use
			call MeCasting
			}	
		If ${Me.Ability[Thousand Fists IV].IsReady}
			{
			Me.Ability[Thousand Fists IV]:Use
			call MeCasting
			}
		If ${Me.Ability[Thundering Fists III].IsReady}
			{
			Me.Ability[Thundering Fists III]:Use
			call MeCasting
			}
		If ${Me.Ability[Gouging Dragon Claw II].IsReady}
			{
			Me.Ability[Gouging Dragon Claw II]:Use
			call MeCasting
			}
		If ${Me.Ability[Sundering Dragon Claw II].IsReady}
			{
			Me.Ability[Sundering Dragon Claw II]:Use
			call MeCasting
			}
		If ${Me.Ability[Flying Kick V].IsReady}
			{
			Me.Ability[Flying Kick V]:Use
			call MeCasting
			}
		If ${Me.Ability[Kick of the Heavens III].IsReady}
			{
			Me.Ability[Kick of the Heavens III]:Use
			call MeCasting
			}
}



