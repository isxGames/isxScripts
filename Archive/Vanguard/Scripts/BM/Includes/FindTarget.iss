/*
FindTarget v1.2
by:  Zandros, 27 Jan 2009

Description:
Find a certain type of mob (AggroNPC, NPC, Corpse) with whatever optional parameters you pass it and targets it

Optional parameters:
MobType = Type of Mob (AggroNPC, NPC, Corpse) (default is AggroNPC)
Distance = How far you want to scan (default is 35)
ConCheck = How difficult you want the mob to be (default is 2)
MinLevel = Minimum Level of the Target (default is 5 lvls below current level)
MaxLevel = Maximum level of the Target (default is current level)

Examples: 
call FindTarget							"Uses default parameters"
call FindTarget Corpse					"Finds Corpse"
call FindTarget NPC 50					"Finds NPC within 50m"
call FindTarget AggroNPC 50 3			"Finds AggroNPC within 50m and Difficulty of 3 or less"
call FindTarget AggroNPC 50 3 10 20		"Finds AggroNPC within 50m, Difficulty of 3 or less, Level within 10-20 range"

External Routines that must be in your program: None
*/

/* This variable is used to keep you from scanning the same mob twice */
variable collection:int64 TargetBlackList
variable bool doClearTargets=FALSE

;===================================================
;===          FindTarget Routine                ====
;===================================================
function FindTarget(string TargetType, int Distance, int ConCheck, int MinLevel, int MaxLevel)
{
	;-------------------------------------------
	; Return if we have a target
	;-------------------------------------------
	if ${Me.Target(exists)}
	return FALSE

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	if ${TargetType.Length} <= 0 
		TargetType:Set[AggroNPC]
	if ${Distance} == 0
		Distance:Set[25]
	if ${ConCheck} == 0
		ConCheck:Set[2]
	if ${MinLevel} == 0
		MinLevel:Set[${Math.Calc[${Me.Level} - 5].Int}]
	if ${MinLevel} < 1
		MinLevel:Set[1]
	if ${MaxLevel} == 0
		MaxLevel:Set[${Me.Level}]
	
	variable int i

	;-------------------------------------------
	; Let's find us a target
	;-------------------------------------------
	for (i:Set[1] ; ${i}<=${VG.PawnCount} && ${Pawn[${i}].Distance}<${Distance} ; i:Inc)
	{
		;-------------------------------------------
		; Find our Target Type
		;-------------------------------------------
		if ${Pawn[${i}].Type.Equal[${TargetType}]}
		{
			;-------------------------------------------
			; Exclude things we don't want
			;-------------------------------------------
			if ${TargetBlackList.Element[${Pawn[${i}].ID}](exists)} || !${Pawn[${i}].HaveLineOfSightTo}
				continue

			;-------------------------------------------
			; Time saver check - no need to look for beyond our range
			;-------------------------------------------
			;if (${Pawn[${i}].Distance.Int}>${Distance}
			if ${Pawn[${i}].Distance.Int}>${Distance}
				break

			;-------------------------------------------
			; Must pass our first check
			;-------------------------------------------
			if (${Pawn[${i}].Level}<${MinLevel} || ${Pawn[${i}].Level}>${MaxLevel}) && !${TargetType.Find[Corpse]}
				continue

			;-------------------------------------------
			; Must pass our second check
			;-------------------------------------------
			if ${TargetType.Equal[Corpse]} && !${Pawn[${i}].IsHarvestable} && ${Pawn[${i}].ContainsLoot}
			{
				if ${doEcho}
					echo "[${Time}][VG:BM] --> FindTarget: (${TargetType}) - ${Pawn[${i}].Name} - Contains Loot= ${Pawn[${i}].ContainsLoot}"
				continue
			}

			;-------------------------------------------
			; BlackList the target from future scans
			;-------------------------------------------
			if !${TargetBlackList.Element[${Pawn[${i}].ID}](exists)}
				TargetBlackList:Set[${Pawn[${i}].ID}, ${Pawn[${i}].ID}]

			;-------------------------------------------
			; Let's target what we found
			;-------------------------------------------
			Pawn[${i}]:Target
			wait 10

			;-------------------------------------------
			; Must pass our second check
			;-------------------------------------------
			if (${Me.Target.Owner(exists)} && !${Me.Target.OwnedByMe}) || (${Me.TargetAsEncounter.Difficulty}>${ConCheck} && !${Me.Target.Type.Equal[Corpse]})
			{
				VGExecute /cleartargets
				wait 5
				continue
			}

			;-------------------------------------------
			; Target is good to go
			;-------------------------------------------
			if ${doEcho}
				echo "[${Time}][VG:BM] --> FindTarget: (${TargetType}) - ${Me.Target.Name}"
			break
		}
	}
	;; Clear our collections every 5 min
	if ${doClearTargets}
	{
		TargetBlackList:Clear
		TimedCommand 300 Script[BM].Variable[doClearTargets]:Set[TRUE]
		doClearTargets:Set[FALSE]
	}
}
