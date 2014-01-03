;===================================================
;===          BUFF AREA SUBROUTINE              ====
;===================================================

	variable int i
	variable string temp
	variable int TotalPawns
	variable index:pawn CurrentPawns
	variable index:string PC
	variable bool Saved_isPaused = ${Script[VG-Shaman].Variable[isPaused]}
	variable bool doLesserBuff = TRUE

	variable collection:bool SpellList

	#include ./VG-Shaman/Includes/Objects.iss
	variable(global) Obj_Commands SHA

	
function main()
{
	echo "[${Time}] Buff Area Started"
	if ${SHA.AreWeEating}
	{
		
		VGExecute "/stand"
		wait 10 !${SHA.AreWeEating}
	}

	UIElement[BuffArea@VG-Shaman]:SetAlpha[0.5]
	Script[VG-Shaman].Variable[isPaused]:Set[TRUE]

	;; casting this now ensures everyone in my group get's the buff
	Pawn[me]:Target
	wait 3
	if ${Me.Ability["Mass Spirit's Bountiful Blessing"](exists)}
		call UseAbility "Mass Spirit's Bountiful Blessing"
	if ${Me.Ability["Mass Boon of Turrgin"](exists)}
		call UseAbility "Mass Boon of Turrgin"
	
	;-------------------------------------------
	; Populate our CurrentPawns variable
	;-------------------------------------------
	TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	
	;-------------------------------------------
	; Cycle through all PC in area and add them to our list to be buffed
	;-------------------------------------------
	for (i:Set[1] ;  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<25 ; i:Inc)
	{
		if ${CurrentPawns.Get[${i}].Type.Equal[PC]} || ${CurrentPawns.Get[${i}].Type.Equal[Group Member]}
		{
			if ${CurrentPawns.Get[${i}].HaveLineOfSightTo}
				PC:Insert[${CurrentPawns.Get[${i}].Name}]
		}
	}

	;-------------------------------------------
	; Cycle through all PC and buff them
	;-------------------------------------------
	for (i:Set[1] ; ${PC[${i}](exists)} ; i:Inc)
	{
		temp:Set[${PC[${i}]}]
		if !${Pawn[exactname,${temp}](exists)}
			continue
		call CastBuffs TRUE "${temp}" ${Pawn[exactname,${temp}].Level}
	}
	
	call CastBuffs FALSE "${Me.FName}" ${Me.Level}

}
	
function atexit()
{
	UIElement[BuffArea@VG-Shaman]:SetAlpha[0.5]
	Script[VG-Shaman].Variable[isPaused]:Set[${Saved_isPaused}]	
	echo "[${Time}] Buff Area Ended"
}	

function CastBuffs(bool CheckForBuff, string Toon2Buff, int LEVEL)
{
	SpellList:Clear
	if ${Pawn[exactname,${Toon2Buff}](exists)} && ${Pawn[exactname,${Toon2Buff}].Distance}<25
	{
		if ${CheckForBuff}
		{
			;; Clear & Target as Offensive
			if ${Me.TargetAsEncounter.Difficulty(exists)}
			{
				VGExecute "/cleartargets"
				wait 3
			}
			VGExecute "/targetoffensive ${Toon2Buff}"
			wait 3
		}

		;; Mass Spirit's Bountiful Blessing
		if ${Me.Ability["Mass Spirit's Bountiful Blessing"](exists)} && ${LEVEL}>=40
		{
			wait 1
			if ${CheckForBuff}
			{
				SpellList:Set["Mass Spirit's Bountiful Blessing", ${Me.TargetBuff["Spirit's Bountiful Blessing"](exists)}]
				;; these are Rakurr's Buffs
				SpellList:Set["Mass Boon of Rakurr", ${Me.TargetBuff["Mass Boon of Rakurr"](exists)}]
				;; these are Tuurgin's buffs
				SpellList:Set["${MassBoonofTuurgin}", ${Me.TargetBuff["${MassBoonofTuurgin}"](exists)}]
			}
			else
			{
				SpellList:Set["Mass Spirit's Bountiful Blessing", FALSE]
				;; these are Rakurr's Buffs
				SpellList:Set["Mass Boon of Rakurr", FALSE]
				;; these are Tuurgin's buffs
				SpellList:Set["${MassBoonofTuurgin}", FALSE]
			}
		}
	
		if ${CheckForBuff}
		{
			;; ensure we clear target before buffing
			if ${Me.TargetAsEncounter.Difficulty(exists)}
			{
				VGExecute "/cleartargets"
				wait 3
			}
		}

		;; set DTarget to whom we want to buff
		Pawn[exactname,${Toon2Buff}]:Target
		wait 10 ${Toon2Buff.Find[${Me.DTarget.Name}]} && ${Me.DTarget.Level(exists)}

		;; Start buffing
		if "${SpellList.FirstKey(exists)}"
		{
			do
			{
				if !${SpellList.CurrentValue}
					call UseAbility "${SpellList.CurrentKey}"
			}
			while "${SpellList.NextKey(exists)}"
		}
		VGExecute "/cleartargets"
		wait 3
	}
}

function UseAbility(string ABILITY)
{
	
	if ${Pawn[exactname,${Me.DTarget.Name}].Distance}>${Me.Ability[${ABILITY}].Range}
		return
	if ${Me.ToPawn.IsStunned}
		return
	if ${Pawn[me].IsMounted}
		return
	if !${Me.Ability[${ABILITY}](exists)}
		return
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return
	if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance}
		return
	
	while !${SHA.AreWeReady}
	{
		while !${SHA.AreWeReady}
			waitframe
		wait 4
	}
	
	echo [${Time}] *Buffing: ${Me.DTarget.Name}(${Me.DTarget.Level}) -- ${ABILITY}
	
	Me.Ability[${ABILITY}]:Use
	wait 10
}

function:string FindHighestLevel(int LEVEL, string AbilityName)
{
	;; look for abilities that are 15 levels higher
	if ${LEVEL}<=${Me.Level}
		LEVEL:Inc[15]
	
	;; we cannot go over our level
	if ${LEVEL}>${Me.Level}
		LEVEL:Set[${Me.Level}]


	variable int L = 8

	variable string AbilityLevels[8]
	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]

	;; return if the ability already exists
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${AbilityName}].LevelGranted}<=${LEVEL}
		return "${AbilityName}"
		
	do
	{
		;; return the highest ability 
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${LEVEL}
			return "${AbilityName} ${AbilityLevels[${L}]}"
	}
	while (${L:Dec}>0)
	return "None"
}
