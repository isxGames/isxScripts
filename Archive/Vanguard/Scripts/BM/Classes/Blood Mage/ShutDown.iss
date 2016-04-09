/* MUST HAVE - ShutDown */

function ShutDown()
{
	;; Remove any events
	Event[VG_onAlertText]:DetachAtom[InvisabilityEvent]

	;; Remove our Keybinding
	bind -delete ATTACK
}
