
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

	;; Chains/Finishers are up so lets wait till their ready and use them
	while ${VG.InGlobalRecovery}>0 && (${Me.Ability[${Ruin}].TriggeredCountdown}>0 || ${Me.Ability[${Wrack}].TriggeredCountdown}>0 || ${Me.Ability[${SoulWrack}].TriggeredCountdown}>0)
	{
		waitframe
	}

	;; If health is low then Soul Wrack is 1st due to its healing
	if ${doWrack} && ${Me.EndurancePct}>=10 && ${Me.HealthPct}<50
	{
		call ExecuteChain "${SoulWrack}"
	}
	
	;; 1st - we want to increase hatred
	if ${doIncite} && ${Me.IsGrouped} && ${Me.HealthPct}>40 && ${Me.EndurancePct}>=10
	{
		call ExecuteChain "${Incite}"
		call ExecuteChain "${Inflame}"
		call ExecuteChain "${Superior Inflame}"
	}
	
	;; 2nd - make sure we restore some energy
	if ${doVileStrike} && !${Me.Effect[${Anguish}](exists)} && ${Me.EndurancePct}>=10
	{
		while ${VG.InGlobalRecovery}>0 && ${Me.Ability[${RavagingDarkness}].TimeRemaining}==0
		{
			waitframe
		}
		if ${Me.EnergyPct}<80
		{
			call ExecuteChain "${VileStrike}"
		}
		call ExecuteChain "${Anguish}"
	}
	
	;; 3rd - increase our block, damage, and AC
	if ${doShieldOfFear} && !${Me.Effect[${DarkBastion}](exists)} && ${Me.HealthPct}>40
	{
		call ExecuteChain "${ShieldOfFear}"
		call ExecuteChain "${DarkBastion}"
	}
	
	;; 4th - decrease target's damage and increases your damage
	if ${doHexOfIllOmen} && ${Me.HealthPct}>40
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
	if ${doWrack} && ${Me.EndurancePct}>=10 && ${Me.HealthPct}>40
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
	if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${Me.TargetBuff[Aura of Death](exists)} || ${Me.TargetBuff[Frightful Aura](exists)} || ${FURIOUS}
	{
		return
	}
	
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
