/*
FindTarget v1.1
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
call FindTarget					"Uses default parameters"
call FindTarget Corpse				"Finds Corpse"
call FindTarget NPC 50				"Finds NPC within 50m"
call FindTarget AggroNPC 50 3			"Finds AggroNPC within 50m and Difficulty of 3 or less"
call FindTarget AggroNPC 50 3 10 20		"Finds AggroNPC within 50m, Difficulty of 3 or less, Level within 10-20 range"

External Routines that must be in your program: None
*/

/* This variable is used to keep you from scanning the same mob twice */
variable collection:int64 TargetBlackList



;===================================================
;===          FindTarget Routine                ====
;===================================================
function FindTarget(string TargetType, int Distance, int ConCheck, int MinLevel, int MaxLevel)
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
	if ${TargetType.Length} <= 0
	TargetType:Set[AggroNPC]
	if ${Distance} == 0
	Distance:Set[100]
	if ${ConCheck} == 0
	ConCheck:Set[2]
	if ${MinLevel} == 0
	MinLevel:Set[${Math.Calc[${Me.Level} - 5].Int}]
	if ${MinLevel} < 1
	MinLevel:Set[1]
	if ${MaxLevel} == 0
	MaxLevel:Set[${Me.Level}]

	variable int i
	variable int closestpawndist = 10000
	variable string closestpawn
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
	for (i:Set[1];  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<${Distance} && ${i}<30;  i:Inc)
	{
		;; I want to echo only AggroNPC targets
		if ${CurrentPawns.Get[${i}].Type.Equal[AggroNPC]}
		{
			echo [${i}] Distance=${CurrentPawns.Get[${i}].Distance}, Type=${CurrentPawns.Get[${i}].Type}, Name=${CurrentPawns.Get[${i}].Name} 
		}
	
		;; get left of name
		leftofname:Set[${CurrentPawns.Get[${i}].Name.Left[6]}]

		;; set our variables to the pawn that is closest
		if ${CurrentPawns.Get[${i}].Distance} < ${closestpawndist} && ${CurrentPawns.Get[${i}].Type.Equal[AggroNPC]} && ${CurrentPawns.Get[${i}].Type.NotEqual[Corpse]} && !${CurrentPawns.Get[${i}].IsDead} && !${leftofname.Equal[corpse]}
		{
			closestpawndist:Set[${CurrentPawns.Get[${i}].Distance}]
			closestpawn:Set[${i}]
		}
	}

	echo [${closestpawn}] Closest AggroNPC nearest me is... Distance=${Pawn[${closestpawn}].Distance}, Type=${Pawn[${closestpawn}].Type}, Name=${Pawn[${closestpawn}].Name} 
	
	Pawn["${closestpawn}"]:Target
	wait 5

	;-------------------------------------------
	; Target is good to go
	;-------------------------------------------
	vgecho "VG: FindTarget - (${TargetType}) - ${Me.Target.Name}"
}


