
;===================================================
;===          REMOVE ENCHANTMENTS               ====
;===================================================
function RemoveEnchantment()
{
	;; return if we do not want to remove enchantments
	if !${doEnchantments} || ${doDisEnchantDelay}
	{
		return
	}
	
	;; return if target does not have any buffs
	if !${Me.TargetBuff}
	{
		return
	}

	;; don't even bother if target is outside our range
	if ${Me.Target.Distance}>25
	{
		return
	}

	variable int i
	variable string Temp
	variable bool do = FALSE
	
	;; find removable enchantments
	for ( i:Set[1] ; ${i}<=${Me.TargetBuff} ; i:Inc )
	{
		;; Remove Enchantments
		if ${Me.TargetBuff[${i}].Name.Find[Enchantment]}
		{
			do:Set[TRUE]
			Temp:Set[${Me.TargetBuff[${i}]}]
		}
		;; Remove Thick Skin
		elseif ${Me.TargetBuff[${i}].Name.Find[Thick Skin]}
		{
			do:Set[TRUE]
			Temp:Set[${Me.TargetBuff[${i}]}]
		}
		;; Remove Lightning Barrier
		elseif ${Me.TargetBuff[${i}].Name.Find[Lightning]}
		{
			do:Set[TRUE]
		}
		;; Remove Chaos Shield
		elseif ${Me.TargetBuff[${i}].Name.Find[Chaos]}
		{
			do:Set[TRUE]
			Temp:Set[${Me.TargetBuff[${i}]}]
		}
		;; Remove Annulment Field
		elseif ${Me.TargetBuff[${i}].Name.Find[Annulment]}
		{
			do:Set[TRUE]
			Temp:Set[${Me.TargetBuff[${i}]}]
		}
		else
		{
			continue
		}

		;; attempt to remove enchantment
		if ${do}
		{
			;; 1st try
			wait 10 ${Me.Ability[${StripEnchantment}].IsReady}
			if ${Me.Ability[${StripEnchantment}].IsReady}
			{
				CurrentAction:Set[Casting ${StripEnchantment}]
				Me.Ability[${StripEnchantment}]:Use
				wait 3
				while ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
				{
					waitframe
				}
			}
			wait 5 !${Me.TargetBuff[${Temp}](exists)}
			if !${Me.TargetBuff[${Temp}](exists)}
			{
				EchoIt "RemoveEnchantment:  SUCCESSFULLY removed: ${Temp}"
				return
			}

			;; 2nd Try
			wait 10 ${Me.Ability[${StripEnchantment}].IsReady}
			if ${Me.Ability[${StripEnchantment}].IsReady}
			{
				Me.Ability[${StripEnchantment}]:Use
				wait 3
				while ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
				{
					waitframe
				}
			}
			wait 5 !${Me.TargetBuff[${Temp}](exists)}
			if !${Me.TargetBuff[${Temp}](exists)}
			{
				EchoIt "RemoveEnchantment:  SUCCESSFULLY removed: ${Temp}"
				break
			}
		}
	}

	;; Don't try again until 10 seconds have passed
	TimedCommand 100 Script[VG-BM].Variable[doDisEnchantDelay]:Set[FALSE]
	doDisEnchantDelay:Set[TRUE]
}
