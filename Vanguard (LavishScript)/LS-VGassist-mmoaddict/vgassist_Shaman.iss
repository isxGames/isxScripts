


;********************************************
function shaman()
{
	While ${shplmode}
        {
	call Dist_Check
        call shsl
	call shplheal
        }
	if ${shcann}
	{
	call shgetener
	}
	if ${shblasttarg}
	{
	call shbl
	}
	if ${shdottarg}
	{
	call shdot
	}
	if ${shcrittarg}
	{
	call shcrit
	}
	if ${shslowtarg}
	{
	call shsl
	}
}
;********************************************
function shplheal()
{  
   Pawn[${assistMember1}]:Target
	wait 10
   if ${Me.DTargetHealth}<60
   {
    Me.Ability[${bigheal}]:Use
    wait 20
   }
   if ${Me.HealthPct}<70
   {
    Pawn[me]:Target
    Me.Ability[${smallheal}]:Use
    wait 20
   }
   if !${Me.Effect[Bosrid's Gift III](exists)}
	{
	Me.Ability[Bosrid's Gift III]:Use
	}
   if ${Me.DTargetHealth}>99 && ${Me.EnergyPct} < 80
   {   
	Me.Ability[${shsmcann}]:Use
   	 wait 30
      
   }
}
;********************************************
function shgetener()
{
	
	if ${Me.EnergyPct}<50 && ${Me.HealthPct}>85 && ${Me.Ability[${shbigcann}].IsReady} && ${Me.InCombat}
   		{
		Me.Ability[${shbigcann}]:Use
   		Call MeCasting
		return
		}
	if ${Me.EnergyPct}<80 && ${Me.HealthPct}>65 && ${Me.Ability[${shbigcann}].IsReady} && ${Me.InCombat}
   		{
		Me.Ability[${shsmcann}]:Use
   		Call MeCasting
		return
		}
	if ${Me.EnergyPct}<80 && ${Me.HealthPct}>65 && ${Me.Ability[${shbigcann}].IsReady} && !${Me.InCombat}
   		{
		Me.Ability[${shsmcann}]:Use
   		Call MeCasting
		return
		}
	if !${Me.Effect[Bosrid's Gift IV](exists)}
		{
		Me.Ability[Bosrid's Gift IV]:Use
		Call MeCasting
		return
		}
}
;********************************************
function shbl()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if ${Me.Ability[${shblastattack1}].IsReady} && ${shblastrot}==1
		{
		Me.Ability[${shblastattack1}]:Use
		shblastrot:Set[2]
		Call MeCasting
		if ${shblastattack2.Length} < 2
			{
			shblastrot:Set[1]
			}
		return
		}
	elseif ${Me.Ability[${shblastattack2}].IsReady} && ${shblastrot}==2
		{
		Me.Ability[${shblastattack2}]:Use
		shblastrot:Set[1]
		Call MeCasting
		return
		}
	}
	return
}

;********************************************
function shdot()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if !${Me.TargetDebuff[${shdotattack1}](exists)}
		{
		Me.Ability[${shdotattack1}]:Use
		Call MeCasting
		return
		}
	if !${Me.TargetDebuff[${shdotattack2}](exists)}
		{
		Me.Ability[${shdotattack2}]:Use
		Call MeCasting
		return
		}
	if !${Me.TargetDebuff[${shdotattack3}](exists)}
		{
		Me.Ability[${shdotattack3}]:Use
		Call MeCasting
		return
		}
	}
	
}
;********************************************
function shsl()
{
	call assist
	call movetomelee
	call facemob
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct}
	{
	if !${Me.TargetDebuff[${shslowattack1}](exists)}
		{
		Me.Ability[${shslowattack1}]:Use
		Call MeCasting
		return
		}
	}
	return
}
;********************************************
function shcrit()
{
		If ${Me.Ability[${shcritattack1}].IsReady} && ${shcrittarg}
			{
			Me.Ability[${shcritattack1}]:Use
			call MeCasting
			}
		If ${Me.Ability[${shcritattack2}].IsReady} && ${shcritattack2.Length} > 2 && ${shcrittarg}
			{
			Me.Ability[${shcritattack2}]:Use
			call MeCasting
			}
		If ${Me.Ability[${shcritattack3}].IsReady} && ${shcritattack3.Length} > 2 && ${shcrittarg}
			{
			Me.Ability[${shcritattack3}]:Use
			call MeCasting
			}
		If ${Me.Ability[${shcritattack4}].IsReady} && ${shcritattack4.Length} > 2 && ${shcrittarg}
			{
			Me.Ability[${shcritattack4}]:Use
			call MeCasting
			}

}

