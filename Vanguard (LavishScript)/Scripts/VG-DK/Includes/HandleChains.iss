
;===================================================
;===         CHAINS & FINISHERS                 ====
;===================================================
function HandleChains()
{
	;; return if we do not want to do chains
	if !${doChains}
	{
		return
	}

	; Return if target is Furious, Furious Rage, or Aura of Death
	if ${Me.TargetBuff[Furious](exists)} || ${Me.Effect[Furious Rage](exists)} || ${Me.Effect[Aura of Death](exists)} || ${FURIOUS} 
	{ 
		return
	}
	
	;; 1st - we want to increase hatred
	if ${doIncite} && ${Me.IsGrouped}
	{
		call ExecuteChain "${Incite}"
		call ExecuteChain "${Inflame}"
		call ExecuteChain "${Superior Inflame}"
	}
	
	;; 2nd - make sure we restore some energy
	if ${doVileStrike} && !${Me.Effect[${Anguish}](exists)} 
	{
		if ${Me.EnergyPct}<80
		{
			call ExecuteChain "${VileStrike}"
		}
			call ExecuteChain "${Anguish}"
	}
	
	;; 3rd - increase our block, damage, and AC
	if ${doShieldOfFear} && !${Me.Effect[${DarkBastion}](exists)} 
	{
		call ExecuteChain "${ShieldOfFear}"
		call ExecuteChain "${DarkBastion}"
	}
	
	;; 4th - decrease target's damage and increases your damage
	;if ${doHexOfIllOmen} && !${Me.Effect[${HexOfImpendingDoom}](exists)}
	if ${doHexOfIllOmen}
	{
		if ${Me.Ability[${HexOfIllOmen}].IsReady}
		{
			;; Check if mob is immune
			call Check4Immunites "${HexOfIllOmen}"
			if !${Return}
			{
				CurrentAction:Set[Chain - ${HexOfIllOmen}]
				EchoIt "Chain - ${HexOfIllOmen}"
				Me.Ability[${HexOfIllOmen}]:Use
				VGExecute "/reactionchain 1"
				wait 3
			}
		}
		if ${Me.Ability[${HexOfImpendingDoom}].IsReady}
		{
			;; Check if mob is immune
			call Check4Immunites "${HexOfIllOmen}"
			if !${Return}
			{
				CurrentAction:Set[Chain - ${HexOfImpendingDoom}]
				EchoIt "Chain - ${HexOfImpendingDoom}"
				Me.Ability[${HexOfImpendingDoom}]:Use
				VGExecute "/reactionchain 1"
				wait 3
			}
		}
	}

	;; 5th - +400% weapon damage
	if ${doWrack}
	{
		call ExecuteChain "${SoulWrack}"
		call ExecuteChain "${Wrack}"
		call ExecuteChain "${Ruin}"
	}
}
;===================================================
;===       Execute Chain/Combo                  ====
;===================================================
function ExecuteChain(string ChainFinisher)
{
	if ${Me.Ability[${ChainFinisher}].IsReady}
	{
		if ${Me.Ability[${ChainFinisher}].TimeRemaining}==0 && ${Me.Ability[${ChainFinisher}].TriggeredCountdown}>0
		{
			;; Check if mob is immune
			call Check4Immunites "${ChainFinisher}"
			if !${Return}
			{
				CurrentAction:Set[ChainFinisher - ${ChainFinisher}]
				EchoIt "ChainFinisher - ${ChainFinisher}"
				Me.Ability[${ChainFinisher}]:Use
				wait 3
			}
		}
	}
}
