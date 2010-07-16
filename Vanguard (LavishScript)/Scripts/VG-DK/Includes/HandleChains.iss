
variable int WaitOnChains=${Script.RunningTime}


;===================================================
;===      ATOM - CATCH THEM Chains!             ====
;===================================================
atom(script) HandleChains()
{
	;; return if we do not want to do chains
	if !${doChains}
	{
		return
	}
	
	; Return if target is Furious or Furious Rage
	if ${Me.TargetBuff[Furious](exists)} || ${Me.Effect[Furious Rage](exists)} || ${FURIOUS} 
	{ 
		return
	}
	
	;; Allow 1/5th a second to pass by before handling any chains
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${WaitOnChains}]}/1000]}<.2
	{
		return
	}
	
	;; 1st - we want to increase hatred
	if ${doIncite} && ${Me.IsGrouped}
	{
		call ExecuteChain "${Incite}" 2
		call ExecuteChain "${Inflame}" 2
		call ExecuteChain "${Superior Inflame}" 2
	}
	
	;; 2nd - make sure we restore some energy
	if ${doVileStrike} && !${Me.Effect[${Anguish}](exists)} 
	{
		if ${Me.EnergyPct}<80
		{
			call ExecuteChain "${VileStrike}" 4
			call ExecuteChain "${Anguish}" 4
		}
	}
	
	;; 3rd - increase our block, damage, and AC
	if ${doShieldOfFear} && !${Me.Effect[${DarkBastion}](exists)} 
	{
		call ExecuteChain "${ShieldOfFear}" 3
		call ExecuteChain "${DarkBastion}" 3
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
				WaitOnChains:Set[${Script.RunningTime}]
				;wait 4
				;while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
				;{
				;	waitframe
				;}
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
				WaitOnChains:Set[${Script.RunningTime}]
				;wait 4
				;while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
				;{
				;	waitframe
				;}
			}
		}
	}

	;; 5th - +400% weapon damage
	if ${doWrack}
	{
		call ExecuteChain "${SoulWrack}" 5
		call ExecuteChain "${Wrack}" 5
		call ExecuteChain "${Ruin}" 5
	}
}
;===================================================
;===       Execute Chain/Combo                  ====
;===================================================
function ExecuteChain(string Chain, int ReactionNumber)
{
	if ${Me.Ability[${Chain}].IsReady}
	{
		if ${Me.Ability[${Chain}].TimeRemaining}==0 && ${Me.Ability[${Chain}].TriggeredCountdown}>0
		{
			;; Check if mob is immune
			call Check4Immunites "${Chain}"
			if !${Return}
			{
				CurrentAction:Set[Chain - ${Chain}]
				EchoIt "Chain - ${Chain}"
				Me.Ability[${Chain}]:Use
				;VGExecute "/reactionchain ${ReactionNumber}"
				;wait 4
				;while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
				;{
				;	waitframe
				;}
				WaitOnChains:Set[${Script.RunningTime}]
				
			}
		}
	}
}
