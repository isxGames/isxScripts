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
		return
	}

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	if ${Distance} == 0
	{
		Distance:Set[100]
	}

	variable int i
	variable string leftofname
	variable bool CorrectType

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
		;; check if we want to hunt for AggroNPC and/or NPC
		CorrectType:Set[FALSE]
		if ${doNPC} && ${CurrentPawns.Get[${i}].Type.Equal[NPC]}
			CorrectType:Set[TRUE]
		if ${doAggroNPC} && ${CurrentPawns.Get[${i}].Type.Equal[AggroNPC]}
			CorrectType:Set[TRUE]
		if !${CorrectType}
			continue

		;; we do not want to retarget same target twice
		if ${BlackListTarget.Element[${CurrentPawns.Get[${i}].ID}](exists)}
			continue

		;; find a target that is within our level range
		if ${CurrentPawns.Get[${i}].Level}<${MinimumLevel} || ${CurrentPawns.Get[${i}].Level}>${MaximumLevel}
			continue

		;; most likely this target is fighting someone else
		if ${Pawn[id,${CurrentPawns.Get[${i}].ID}].CombatState}>0
			continue

		;; we only want targets we can see
		if ${doCheckLineOfSight}
		{
			;vgecho HaveLineOfSightTo=${CurrentPawns.Get[${i}].HaveLineOfSightTo}/${Pawn[id,${CurrentPawns.Get[${i}].ID}].HaveLineOfSightTo}
			if !${Pawn[id,${CurrentPawns.Get[${i}].ID}].HaveLineOfSightTo} || !${CurrentPawns.Get[${i}].HaveLineOfSightTo}
				continue
		}

		;echo [${i}] [${CurrentPawns.Get[${i}].Distance.Int}] [${CurrentPawns.Get[${i}].Name}]

		;; get left of name
		leftofname:Set[${CurrentPawns.Get[${i}].Name.Left[6]}]

		if !${leftofname.Equal[corpse]}
		{
			;; set our variables to the pawn that is closest
			if ${CurrentPawns.Get[${i}].Type.Equal[AggroNPC]} || ${CurrentPawns.Get[${i}].Type.Equal[NPC]}
			{
				;; let's target the AggroNPC
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 7 ${Me.Target.ID}==${CurrentPawns.Get[${i}].ID}

				;; Say we found a target
				if ${Me.Target.HaveLineOfSightTo}
					EchoIt "FindTarget - (${Me.Target.Type}/HaveLineOfSight) - ${Me.Target.Name}"
				else
					EchoIt "FindTarget - (${Me.Target.Type}) - ${Me.Target.Name}"
				return
			}
		}
	}
}


