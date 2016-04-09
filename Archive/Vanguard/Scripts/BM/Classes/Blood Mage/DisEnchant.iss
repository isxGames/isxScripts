/* BLOOD MAGE DISENCHANT

Description:  Removes enchantments and recasting times are
super quick.  The best way for now is after disenchanting
check to see if enchantment is gone.  If it is not then
stop trying until there is change in total enchantments.
*/  

;; Establish our variables
variable int LastTargetBuff = 0
variable bool DisEnchanted = TRUE
;variable bool doDisEnchant = TRUE

/* DISENCHANT */
function:bool DisEnchant()
{
	;; Return if we are not DisEnchanting
	if !${doDisEnchant} || !${Me.Ability[${StripEnchantment}](exists)} || ${Me.Target.Distance}>25
		return

	;; Set our variables
	variable int i
	variable string TEST2
	variable int TotalEnchantments = ${Me.TargetBuff}

	;; Rest variable if no enchantments on target
	if ${Me.TargetBuff}==0 || ${Me.TargetBuff}<${LastTargetBuff}
	{
		DisEnchanted:Set[TRUE]
		LastTargetBuff:Set[${Me.TargetBuff}]
	}
		
	;; DisEnchant if target gets a new buff
	if ${DisEnchanted} && ${Me.TargetBuff}>${LastTargetBuff}
	{
		; Check for FURIOUS and remove any Enchantments
		for ( i:Set[1] ; ${i}<=${Me.TargetBuff} ; i:Inc )
		{
			;; Check next buff if not Greater Enchantment
			if !${Me.TargetBuff[${i}].Name.Find[Enchant]} 
				continue

			;; Save this to check later on
			TEST2:Set[${Me.TargetBuff[${i}]}]

			wait 15 ${Me.Ability["${StripEnchantment}"].IsReady}
			
			;; Use the Ability
			call UseAbility "${StripEnchantment}"
			wait 5 ${VG.InGlobalRecovery}>0 || ${Me.IsCasting}

			;; Wait till Enchantment is gone
			wait 20 !${Me.TargetBuff[${TEST2}](exists)}

			;; Check to see if we failed to remove the enchantment
			if ${Me.TargetBuff[${TEST2}](exists)}
			{
				;; Try again
				wait 15 ${Me.Ability["${StripEnchantment}"].IsReady}
				call UseAbility "${StripEnchantment}"
				wait 5 ${VG.InGlobalRecovery}>0 || ${Me.IsCasting}

				;; Wait till Enchantment is gone
				wait 20 !${Me.TargetBuff[${TEST2}](exists)}

				;; Check one more time 
				if ${Me.TargetBuff[${TEST2}](exists)}
				{
					if ${doEcho}
						echo "[${Time}][VG:BM] --> DisEnchant:  FAILED to Disenchant: ${TEST2}"
					DisEnchanted:Set[FALSE]
				}
			}

			;; Check to see if we successfully removed the enchantment
			if !${Me.TargetBuff[${TEST2}](exists)}
			{
				if ${doEcho}
					echo "[${Time}][VG:BM] --> DisEnchant:  SUCCESSFUL Disenchant: ${TEST2}"
				LastTargetBuff:Set[${Me.TargetBuff}]
				DisEnchanted:Set[TRUE]
				return TRUE
			}
		}
	}
	;; Update our variable
	LastTargetBuff:Set[${Me.TargetBuff}]
	return FALSE
	
	;-------------------------------------------
	; No need to cure anything if we already are curing
	;-------------------------------------------
	if ${Me.Effect["Cleansing Leech"](exists)}
		return FALSE

	;-------------------------------------------
	; Check for POISONs and DISEASEs - Need to work on this routine
	;-------------------------------------------
	for ( i:Set[1] ; ${Me.Effect[${i}].Name(exists)}; i:Inc )
	{
		if ${Me.Effect[${i}].Name.Find[Poison]} || ${Me.Effect[${i}].Name.Find[Disease]}
		{
			;echo "[${Time}][VG:BM] --> Cleansing Leech - ${Me.Effect[${i}].Name}"

			;-------------------------------------------
			; Ensure we target our self and wait till ready
			;-------------------------------------------
			;Pawn[me]:Target
			;wait 3
			;while ${VG.InGlobalRecovery}>0
			;	waitframe
			;
			;Me.Ability[Cleansing Leech]:Use
			;return 40
		}
	}
	return FALSE
}
