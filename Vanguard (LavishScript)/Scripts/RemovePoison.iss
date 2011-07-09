variable string CastThis = "Wardship of Krigus"
;variable string CastThis = "Purge II"

variable string IfChatMessage = "Poison"
variable string IfCombatMessage = "Poison:"

variable bool isRunning = TRUE
variable string ShortName = "First"
variable string LongName = "First Last"
variable int x = 0

;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;-------------------------------------------
	; Load ISXVG or exit script
	;-------------------------------------------
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "Unable to load ISXVG, exiting script"
		endscript RemovePoison
	}
	wait 30 ${Me.Chunk(exists)}
	vgecho "Started RemovePoison Script"

	;-------------------------------------------
	; Start our chat monitors
	;-------------------------------------------
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatMessage]
	Event[VG_OnIncomingText]:AttachAtom[ChatMessage]

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		;; a command was stored so lets execute it
		if ${Me.Health} && ${QueuedCommands}
		{
			ExecuteQueued
		}
		
		;; wait one second
		wait 10
	}
}

;===================================================
;===     ATOM - CALLED AT END OF SCRIPT         ====
;===================================================
function atexit()
{
	vgecho "Stopped RemovePoison Script"
}

;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatMessage(string aText, string ChannelNumber, string ChannelName)
{
	;; Group, Raid, and Tells
	if (${ChannelNumber}==8 || ${ChannelNumber}==9 || ${ChannelNumber}==11 || ${ChannelNumber}==15) && ${aText.Find[${IfChatMessage}]}
	{
		LongName:Set[${aText.Token[2,">"].Token[1,"<"]}]
		ShortName:Set[${LongName.Token[1," "]}]
		echo [${ChannelNumber}] ${aText}
		echo ShortName=${ShortName}, LongName=${LongName}
		Script[RemovePoison]:QueueCommand[call RemovePoisons]
	}
}

;===================================================
;===    ATOM - Monitor Combat Text Messages     ====
;===================================================
atom CombatMessage(string aText, int aType)
{
	;; CHECK FOR POISON - for now, just echo it
	if ${aText.Find[${IfCombatMessage}]}
	{
		echo "[${aType}] Detected Poison:  ${aText}"
	}
}

;===================================================
;===       REMOVE POISONS SUB-ROUTINE           ====
;===================================================
function RemovePoisons()
{
	;; check for global cooldown
	call GlobalRecovery
	
	;; check for casting
	call MeIsCasting

	;; does person exist?
	if ${Pawn[name,${ShortName}](exists)}
	{
		;; is withing range?
		if ${Pawn[name,${ShortName}].Distance}<25
		{
			;; can we see them?
			if ${Pawn[name,${ShortName}].HaveLineOfSightTo}
			{
				Pawn[name,${ShortName}]:Target
				waitframe
				call UseAbility "${CastThis}"
				if ${Return}
				{
					vgecho "Removed Poison on ${ShortName}"
				}
			}
		}
	}
}

;===================================================
;===              USE AN ABILITY                ====
;===  called from within AttackTarget routine   ====
;===================================================
function:bool UseAbility(string ABILITY)
{
	;-------------------------------------------
	; return if ability does not exist
	;-------------------------------------------
	if !${Me.Ability[${ABILITY}](exists)}
	{
		vgecho "${ABILITY} does not exist"
		return FALSE
	}

	;-------------------------------------------
	; make sure ability is ready
	;-------------------------------------------
	call GlobalRecovery
	call MeIsCasting
	
	;-------------------------------------------
	; execute ability only if it is ready
	;-------------------------------------------
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; return if we do not have enough energy
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			vgecho "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		
		;; return if the target is outside our range
		if !${Me.Ability[${ABILITY}].TargetInRange} && !${Me.Ability[${ABILITY}].TargetType.Equal[Self]}
		{
			vgecho "Target not in range for ${ABILITY}"
			return FALSE
		}
		
		;; now execute the ability
		vgecho "Used ${ABILITY}"
		Me.Ability[${ABILITY}]:Use
		wait 3

		;; loop this while checking for crits and furious
		while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
		
		;; say we executed ability successfully
		return TRUE
	}
	;; say we did not execute the ability
	return FALSE
}

;===================================================
;===       GLOBAL RECOVERY SUB-ROUTINE          ====
;===================================================
function GlobalRecovery()
{
	while ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
	}
}

;===================================================
;===       I AM CASTING SUB-ROUTINE             ====
;===================================================
function MeIsCasting()
{
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
	}
}

