/*
Translucence v1.1
by:  Zandros, 17 Oct 2009

Description:  Maintains invisibility 

parameters:  None

Example Code:  Run 
call Translucence

External Routines that must be in your program:  
	Start Event:  Event[VG_onAlertText]:AttachAtom[TranslucenceEvent]
	Close Event:  Event[VG_onAlertText]:DetachAtom[TranslucenceEvent]

*/

/* This is controlled by the event handler */
variable bool InvisWearOff = FALSE

/* Adjust this to your invisibility ability */
variable string InvisAbility = "Translucence"

/* Call this constantly from within your routine */
function:bool Translucence()
{
	if ${Me.Effect[${InvisAbility}](exists)} && ${Me.Effect[${InvisAbility}].TimeRemaining} < 30 && ${Me.Ability[${InvisAbility}].IsReady} && !${GV[bool,bHarvesting]}
	{
		Pawn[me]:Target
		if ${doEcho}
			echo "[${Time}][VG:BM] --> Translucence: ${InvisAbility}"
		Me.Ability[${InvisAbility}]:Use
		wait 10 ${VG.InGlobalRecovery}>0 || ${Me.IsCasting}
		return TRUE
	}

	/* This requires the event handler to be running */
	if ${InvisWearOff} && ${Me.Effect[${InvisAbility}](exists)} && ${Me.Ability[${InvisAbility}].IsReady} && !${GV[bool,bHarvesting]}
	{
		Pawn[me]:Target
		if ${doEcho}
			echo "[${Time}][VG:BM] --> Translucence: ${InvisAbility}"
		Me.Ability[${InvisAbility}]:Use
		wait 10 ${VG.InGlobalRecovery}>0 || ${Me.IsCasting}
		InvisWearOff:Set[FALSE]
		return TRUE
	}
	return FALSE
}

/* Our invisibility event handler */
atom(script) InvisabilityEvent(string Text)
{
	if ${Text.Find["Your invisibility spell is about to wear off!"]}
	{
		InvisWearOff:Set[TRUE]
	}
}
