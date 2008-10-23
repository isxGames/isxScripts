


;********************************************
function bardi()
{
	call sing
	if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct} && ${Me.Inventory[${bardweapon1}].CurrentEquipSlot.Equal[Primary Hand]}
		{
		call bardfinish
		call bardmelee
		call barddot
		call bardmeleedot
		call bardbuffs
		;call bardagro

		}
}

;********************************************
function sing()
{
	if ${Pawn[${assistMember1}].CombatState} > 0 && (${usemeleesong} || ${usecombatmixsong}) && ${Me.EnergyPct} > 10 && !${Me.Effect[${myname}'s Bard Song - "${bardmeleesong}"](exists)} && !${Me.Effect[${myname}'s Bard Song - "${bardcombatmixsong}"](exists)}
	{
     	 	If !${Me.Inventory[${bardweapon1}].CurrentEquipSlot.Equal[Primary Hand]}
       		{
        	Me.Inventory[${bardweapon1}]:Equip[Primary Hand]
        	Waitframe
        	}
      		If !${Me.Inventory[${bardweapon2}].CurrentEquipSlot.Equal[Secondary Hand]}
        	{
         	Me.Inventory[${bardweapon2}]:Equip[Secondary Hand]
         	Waitframe
        	}
		if ${usemeleesong} && ${Me.EnergyPct} > 30
		{
		Songs[${bardmeleesong}]:Perform
		}
		if ${usecombatmixsong} && ${Me.EnergyPct} > 30
		{
		Songs[${bardcombatmixsong}]:Perform
		}
	}
	if ${Pawn[${assistMember1}].CombatState} > 0 && (${usecastersong}) && ${Me.EnergyPct} > 30 && !${healerlow} && !${Me.Effect[${myname}'s Bard Song - "${bardcastersong}"](exists)} 
	{
     	 	If ${Me.Inventory[${Horn}].CurrentEquipSlot.Equal[None]}
              	{
               	Wait 10
               	Me.Inventory[${Horn}]:Equip
		wait 3
   		Songs[${bardcastersong}]:Perform
		}
	}
	;elseif ${Pawn[${assistMember1}].CombatState} > 0 && (${Me.EnergyPct} < 30 || ${healerlow}) && !${Me.Effect[${myname}'s Bard Song - "${bardenergysong}"](exists)}
	;{
	;	If ${Me.Inventory[${Horn}].CurrentEquipSlot.Equal[None]}
         ;     	{
        ;       	Wait 10
        ;       	Me.Inventory[${Horn}]:Equip
	;	wait 3
   	;	Songs[${bardenergysong}]:Perform
	;	}
	;}
	;elseif ${Pawn[${assistMember1}].CombatState} < 1 && !${healerlow} && !${Me.Effect[${myname}'s Bard Song - "${bardrunsong}"](exists)}
	;{
	;	If ${Me.Inventory[${Drum}].CurrentEquipSlot.Equal[None]}
        ;     	{
        ;       	Wait 10
        ;       	Me.Inventory[${Drum}]:Equip
	;	wait 3
   	;	Songs[${bardrunsong}]:Perform
	;	}
	;}
	;elseif ${Pawn[${assistMember1}].CombatState} < 1 && ${healerlow} && !${Me.Effect[${myname}'s Bard Song - "${bardenergysong}"](exists)}
	;{
	;	If ${Me.Inventory[${Horn}].CurrentEquipSlot.Equal[None]}
        ;      	{
        ;       	Wait 10
        ;       	Me.Inventory[${Horn}]:Equip
	;	wait 3
   	;	Songs[${bardenergysong}]:Perform
	;	}
	;}
}
;********************************************
function bardmelee()
{
	
	if ${Me.Inventory[${bardweapon1}].CurrentEquipSlot.Equal[Primary Hand]}
	{
	VGExecute /stand
	call assist
	call movetomelee
	call facemob
	if ${Me.Ability[${bardcrit1}].IsReady} 
		{
		Me.Ability[${bardcrit1}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardcrit2}].IsReady}
		{
		Me.Ability[${bardcrit2}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardcrit3}].IsReady} 
		{
		Me.Ability[${bardcrit3}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardcrit4}].IsReady} 
		{
		Me.Ability[${bardcrit4}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardcrit5}].IsReady} 
		{
		Me.Ability[${bardcrit5}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardmelee1}].IsReady}
		{
		Me.Ability[${bardmelee1}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardmelee2}].IsReady}
		{
		Me.Ability[${bardmelee2}]:Use
		Call MeCasting
		return
		}
	if ${Me.Ability[${bardmelee1}].IsReady} && ${Me.TargetHealth} > 30 && ${Me.TargetHealth} < 75
		{
		Me.Ability[${bardforcecrit}]:Use
		wait 5
		Me.Ability[${bardmelee1}]:Use
		Call MeCasting
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
function barddot()
  {
	if !${Me.TargetDebuff[${barddot1}](exists)} && ${Me.Ability[${barddot1}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${barddot1}]:Use
	Call MeCasting
	return
	}
	if !${Me.TargetDebuff[${barddot2}](exists)} && ${Me.Ability[${barddot2}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${barddot2}]:Use
	Call MeCasting
	Return
	}
	if !${Me.TargetDebuff[${barddot3}](exists)} && ${Me.Ability[${barddot3}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${barddot3}]:Use
	Call MeCasting
	Return
	}
	if !${Me.TargetDebuff[${barddot4}](exists)} && ${Me.Ability[${barddot4}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${barddot4}]:Use
	Call MeCasting
	Return
	}
  }
;********************************************
function bardmeleedot()
  {
	if !${Me.TargetDebuff[${bardmeleedot1}](exists)} && ${Me.Ability[${bardmeleedot1}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15 && ${Me.Inventory[${bardweapon1}].CurrentEquipSlot.Equal[Primary Hand]}
	{
	Me.Ability[${bardmeleedot1}]:Use
	Call MeCasting
	return
	}
	if !${Me.TargetDebuff[${bardmeleedot2}](exists)} && ${Me.Ability[${bardmeleedot2}].IsReady} && ${Me.TargetHealth} < 99 && ${Me.TargetHealth} > 15
	{
	Me.Ability[${bardmeleedot2}]:Use
	Call MeCasting
	return
	}
	
  }
;********************************************
function bardbuffs()
  {
	if !${Me.Effect[Humming Blade VII](exists)}
	{
	Me.Ability[Humming Blade VII]:Use
	return
	}
	if ${Me.InCombat} && !${Me.Effect[${bardcombatbuff1}]} && ${Me.Ability[${bardcombatbuff1}].IsReady} && ${Me.TargetHealth} > 30 && ${Me.TargetHealth} < 75
		{
		Me.Ability[${bardcombatbuff}]:Use
		Call MeCasting
		return
		}	
}
;********************************************
function bardagro()
{ 
	while ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} !${Me.Ability[${barddeagro2}].IsReady} 
	{
	Me.Ability[${barddeagro2}]:Use
	call MeCasting
	}
	if ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && ${Me.Ability[${barddeagro}].IsReady} 
	{
	Me.Ability[${barddeagro}]:Use
	call MeCasting
	while ${myname.Equal[${Pawn[${Me.TargetOfTarget}]}]} && !${Me.Ability[${barddeagro}].IsReady} 
		{
		wait 1
		}
	}
	return
}
;********************************************
function bardfinish()
{ 
	if ${Me.Ability[${bardfinisher}].IsReady} && ${Me.TargetHealth} < 20
		{
		Me.Ability[${bardfinisher}]:Use
		Call MeCasting
		return
		}
}




