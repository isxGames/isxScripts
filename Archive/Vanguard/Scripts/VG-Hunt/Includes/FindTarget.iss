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
		return

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	if ${Distance} == 0
		Distance:Set[100]

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
		;; we do not want to retarget same target twice
		if ${BlackListTarget.Element[${CurrentPawns.Get[${i}].ID}](exists)}
			continue

		;; check if we want to hunt for AggroNPC and/or NPC
		CorrectType:Set[FALSE]
		if ${doNPC} && ${CurrentPawns.Get[${i}].Type.Equal[NPC]}
			CorrectType:Set[TRUE]
		if ${doAggroNPC} && ${CurrentPawns.Get[${i}].Type.Equal[AggroNPC]}
			CorrectType:Set[TRUE]
		if !${CorrectType}
			continue

		;; we only want targets we can see
		if ${doCheckLineOfSight}
		{
			if !${Pawn[id,${CurrentPawns.Get[${i}].ID}].HaveLineOfSightTo} || !${CurrentPawns.Get[${i}].HaveLineOfSightTo}
				continue
		}

		;; most likely this target is fighting someone else
		if ${Pawn[id,${CurrentPawns.Get[${i}].ID}].CombatState}>0
			continue

		;; find a target that is within our level range
		if ${CurrentPawns.Get[${i}].Level}<${MinimumLevel} || ${CurrentPawns.Get[${i}].Level}>${MaximumLevel}
			continue

		;echo "[${i}] [${CurrentPawns.Get[${i}].Distance.Int}] [${CurrentPawns.Get[${i}].Name}]"

		;; set our target
		Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
		wait 20 ${Me.TargetAsEncounter.Difficulty(exists)}

		;; check difficulty of our target
		if ${Me.TargetAsEncounter.Difficulty}>${DifficultyLevel}
		{
				BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
				VGExecute "/cleartargets"
				wait 20 !${Me.TargetAsEncounter.Difficulty(exists)}
				continue
		}

		;; Double-Check our LoS
		if ${doCheckLineOfSight} && !${Me.Target.HaveLineOfSightTo}
		{
			vgecho Cleared target
			VGExecute "/cleartargets"
			waitframe
			if ${Me.Pet(exists)}
			{
				VGExecute /minions backoff
				waitframe
				VGExecute /pet backoff
			}
			wait 20 !${Me.TargetAsEncounter.Difficulty(exists)}
			continue
		}
		vgecho "[Level=${Me.Target.Level}][Difficulty=${Me.TargetAsEncounter.Difficulty}][LoS=${Me.Target.HaveLineOfSightTo}][Name=${Me.Target.Name}]"
		return
	}
}


