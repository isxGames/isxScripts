/*
FindTarget v1.1
by:  Zandros, 27 Jan 2009

Description:
Find a mob that is AggroNPC

Optional parameters: Distance

External Routines that must be in your program: None
*/

;===================================================
;===          FindTarget Routine                ====
;===================================================
function FindTarget(int Distance)
{
	;-------------------------------------------
	; Return if we have a target
	;-------------------------------------------
	if ${Me.Target(exists)}
	{
		return FALSE
	}

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	TargetType:Set[AggroNPC]
	if ${Distance} == 0
	{
		Distance:Set[100]
	}
	
	variable int i
	variable string leftofname
	
	variable int TotalPawns
	variable index:pawn CurrentPawns
	
	;-------------------------------------------
	; Populate our CurrentPawns variable
	;-------------------------------------------
	TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	
	;-------------------------------------------
	; Cycle through 30 nearest Pawns in area that are AggroNPC
	;-------------------------------------------
	for (i:Set[1];  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<${Distance};  i:Inc)
	{
		;; we only want targets we can see
		if ${doCheckLineOfSight}
		{
			if !${Pawn[id,${CurrentPawns.Get[${i}].ID}].HaveLineOfSightTo}
			{
				continue
			}
		}

		;; get left of name
		leftofname:Set[${CurrentPawns.Get[${i}].Name.Left[6]}]

		;; set our variables to the pawn that is closest
		if ${CurrentPawns.Get[${i}].Type.Equal[AggroNPC]} && !${leftofname.Equal[corpse]}
		{
			;; let's target the AggroNPC
			Pawn["${i}"]:Target
			wait 5 ${Me.Target(exists)}

			;; Say we found a target
			vgecho "FindTarget - (${Me.Target.Name}) - ${Me.Target.Name}"
			return
		}
	}
}


