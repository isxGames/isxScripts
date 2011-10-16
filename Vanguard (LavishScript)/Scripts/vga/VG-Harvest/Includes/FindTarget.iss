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
variable int FindTargetTimer = ${Script.RunningTime}

;===================================================
;===          FindTarget Routine                ====
;===================================================
function:bool FindTarget(string TargetType, int Distance=15, int ConCheck=6, int MinLevel=0, int MaxLevel=60)
{
	;-------------------------------------------
	;; Clear our collections every 2 minutes
	;-------------------------------------------
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${FindTargetTimer}]}/1000]}>120
	{
		EchoIt "Clearing TargetBlackList"
		TargetBlackList:Clear
		FindTargetTimer:Set[${Script.RunningTime}]
	}

	;-------------------------------------------
	; Return if we have a target
	;-------------------------------------------
	if ${Me.Target(exists)}
		return TRUE

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
	variable int Dist
	variable string Obstacle
	Dist:Set[${Math.Calc[${Distance}*100].Int}]


	;-------------------------------------------
	; Let's find us a target
	;-------------------------------------------
	for (i:Set[1] ; ${i}<=${VG.PawnCount} && ${Pawn[${i}].Distance.Int}<${Distance} ; i:Inc)
	{
		;-------------------------------------------
		; Find our Target Type
		;-------------------------------------------
		if ${Pawn[${i}].Type.Equal[${TargetType}]}
		{
			;-------------------------------------------
			; Exclude things we don't want
			;-------------------------------------------
			if ${TargetBlackList.Element[${Pawn[${i}].ID}](exists)}
				continue

			;-------------------------------------------
			; Time saver check - no need to look for beyond our range
			;-------------------------------------------
			if ${Pawn[${i}].Distance.Int}>${Distance}
				break
			;if ${Math.Distance[${Pawn[${i}].X},${Pawn[${i}].Y},${HomeX},${HomeY}]}>${Dist}
			;	break

			;-------------------------------------------
			; Must pass our first check
			;-------------------------------------------
			if ${TargetType.Find[PC]} && (${Pawn[${i}].Level}<${MinLevel} || ${Pawn[${i}].Level}>${MaxLevel})
				continue

			;-------------------------------------------
			; Must pass our second check
			;-------------------------------------------
			if ${TargetType.Equal[Corpse]} && !${Pawn[${i}].IsHarvestable} && ${Pawn[${i}].ContainsLoot}
			{
				;if ${doEcho}
				;	echo "[${Time}][VG:EB] --> FindTarget2: (${TargetType}) - ${Pawn[${i}].Name} - Contains Loot= ${Pawn[${i}].ContainsLoot}"
				continue
			}

			;echo LOS=[${Pawn[${i}].HaveLineOfSightTo}], Obstacle=[${Pawn[${i}].CheckCollision[${Me.X},${Me.Y},${Me.Z}]}], Target=[${Pawn[${i}].Name}], Distance=[${Pawn[${i}].Distance}]
			
			;-------------------------------------------
			; Must pass our third check
			;-------------------------------------------
			;if !${Pawn[${i}].HaveLineOfSightTo} && ${doLineOfSight}
			if !${Pawn[${i}].HaveLineOfSightTo}
			{
				continue
				Obstacle:Set[${Pawn[${i}].CheckCollision[${Me.X},${Me.Y},${Me.Z}]}]
				if !${Obstacle.Equal[TerrainInfo0]}
				{
					;echo Obstacle=[${Obstacle}]
					;echo LOS=[${Pawn[${i}].HaveLineOfSightTo}], Obstacle=[${Pawn[${i}].CheckCollision[${Me.X},${Me.Y},${Me.Z}]}], Target=[${Pawn[${i}].Name}], Distance=[${Pawn[${i}].Distance}]
					;if ${doEcho}
					;{
					;	;echo "[${Time}][VG:EB] --> FindTarget: Obstacle between ${Pawn[${i}].Name} at ${Pawn[${i}].Distance} meters away"
					;}
					continue
				}
			}
			
			;wait 15

			;-------------------------------------------
			; Let's target what we found
			;-------------------------------------------
			Pawn[${i}]:Target
			wait 20 ${Me.Target(exists)}
			wait 10

			;-------------------------------------------
			; BlackList the target from future scans
			;-------------------------------------------
			if !${TargetBlackList.Element[${Me.Target.ID}](exists)}
				TargetBlackList:Set[${Me.Target.ID}, ${Me.Target.ID}]
				
			;vgecho ${Me.Target.Name}
			;vgecho Level=${Me.Target.Level}, Difficulty=${Me.TargetAsEncounter.Difficulty}
			;vgecho Owner=${Me.Target.Owner(exists)}, OwnedByMe=${Me.Target.OwnedByMe}
			
			;-------------------------------------------
			; Return if target is owned by somebody else
			;-------------------------------------------
			if ${Me.Target.Owner(exists)} && !${Me.Target.OwnedByMe}
			{
				EchoIt "FindTarget: ${Me.Target.Name} is owned by somebody else"
				VGExecute /cleartargets
				waitframe
				continue
			}

			;-------------------------------------------
			; Return if target is too difficult
			;-------------------------------------------
			;if ${Me.Target.Type.Find[PC]} && ${Me.Target.Owner(exists)} && !${Me.Target.OwnedByMe} && ${Me.TargetAsEncounter.Difficulty}>${ConCheck}
			if ${Me.TargetAsEncounter.Difficulty}>${ConCheck}
			{
				if ${Me.TargetAsEncounter.Difficulty}>${ConCheck} 
					EchoIt "FindTarget: Too Dificult - ${Me.Target.Name}, Level=${Me.Target.Level}, Difficulty=${Me.TargetAsEncounter.Difficulty}"
				VGExecute /cleartargets
				waitframe
				continue
			}
			
			;-------------------------------------------
			; We don't have a target... try again
			;-------------------------------------------
			if !${Me.Target(exists)}
			{
				continue
			}

			;-------------------------------------------
			; Target is good to go
			;-------------------------------------------
			EchoIt "FindTarget: (${TargetType}) - ${Me.Target.Name}, Level=${Me.Target.Level}, Difficulty=${Me.TargetAsEncounter.Difficulty}"
			return TRUE
		}
	}
	return FALSE
}

