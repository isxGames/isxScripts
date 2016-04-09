function BuffUp()
{
	;-------------------------------------------
	; Put your buffs you want to cast here
	;-------------------------------------------

	;; Only usable with a 2-handed weapon
	call CastBuff "${AnthaminesCharge}"

	;; you may only have one of these active at a time
	;call CastBuff "${SymbolOfDespair}"
	call CastBuff "${SymbolOfWrath}"
	
	if ${Me.InCombat}
	{
		call CastBuff "${DarkWard}"
		;call CastBuff "${HatredIncarnate}"
	}
}

;; CastBuff puts a small delay after a buff
function CastBuff(string ABILITY)
{
	if ${Me.Effect[${ABILITY}](exists)} 
		return

	call UseAbility "${ABILITY}"
	if ${Return}
		wait 30 ${Me.Effect[${ABILITY}](exists)}
}

