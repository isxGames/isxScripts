/*

HarvestAssist v1.0
by:  Zandros, 27 Jan 2009

Description:
Find a harvestable node and harvest it

Optional parameters:  None

Examples:
call HarvestAssist

External Routines that must be in your program:
variable bool doAutoAssist (turns autoassist on/off)

*/

;===================================================
;===            Harvest Routine                 ====
;===================================================
function HarvestAssist()
{
	;; Return if we do not want to initiate harvesting
	if !${doAutoAssist}
	{
		return
	}

	variable int i = 0

	;-------------------------------------------
	; If we are in a group then scan all group members
	; to determine if we will assist in harvesting
	;-------------------------------------------
	if ${Me.IsGrouped}
	{
		;; Let's go find someone who is harvesting nearby
		if !${Me.Target(exists)}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Pawn[id,${Group[${i}].ID}].CombatState}>0 && ${Pawn[id,${Group[${i}].ID}].Distance}<5
				{
					vgecho "Harvest Assist"
					CurrentAction:Set[HarvestAssist ${Group[${i}].Name}]
					VGExecute "/cleartargets"
					VGExecute "/assist ${Group[${i}].Name}"
					
			
					;; Must wait a tad bit!
					wait 5
					break
				}
			}
		}
	}
	
	;-------------------------------------------
	; If we have a target, then attempt to harvest it
	;-------------------------------------------
	variable string leftofname
	leftofname:Set[${Me.Target.Name.Left[6]}]
	if "(${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<5 && ${Me.ToPawn.CombatState}==0 && !${leftofname.Equal[remain]}"
	{
		vgecho "Initiate Harvesting"
		VGExecute /autoattack
		wait 10
	}

	;-------------------------------------------
	; Turn off harvesting if we are no longer harvesting
	;-------------------------------------------
	if !${GV[bool,bHarvesting]} && ${Me.Ability[Auto Attack].Toggled}
	{
		vgecho "Stop Harvesting"
		VGExecute /autoattack
		VGExecute "/cleartargets"
		wait 10
	}	
}
