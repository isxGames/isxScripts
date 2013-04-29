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
	
		;; Spirit's Bountiful Blessing
		if ${Me.Ability["Spirit's Bountiful Blessing"](exists)} && ${LEVEL}>=40
		{
			wait 1
			if ${CheckForBuff}
			{
				SpellList:Set["Spirit's Bountiful Blessing", ${Me.TargetBuff["Spirit's Bountiful Blessing"](exists)}]
				;; these are Rakurr's Buffs
				SpellList:Set["Rakurr's Gift of Grace", ${Me.TargetBuff["Rakurr's Gift of Grace"](exists)}]
				SpellList:Set["Rakurr's Gift of Speed", ${Me.TargetBuff["Rakurr's Gift of Speed"](exists)}]
				SpellList:Set["Boon of Rakurr", ${Me.TargetBuff["Boon of Rakurr"](exists)}]
				;; these are Tuurgin's buffs
				SpellList:Set["${WarmthoftheGreatBear}", ${Me.TargetBuff["${WarmthoftheGreatBear}"](exists)}]
				SpellList:Set["${TuurginsGiftofFury}", ${Me.TargetBuff["${TuurginsGiftofFury}"](exists)}]
				SpellList:Set["${SuperiorTuurginsVigor}", ${Me.TargetBuff["${SuperiorTuurginsVigor}"](exists)}]
				SpellList:Set["${BoonofTuurgin}", ${Me.TargetBuff["${BoonofTuurgin}"](exists)}]
			}
			else
			{
				SpellList:Set["Spirit's Bountiful Blessing", FALSE]
				;; these are Rakurr's Buffs
				SpellList:Set["Rakurr's Gift of Grace", FALSE]
				SpellList:Set["Rakurr's Gift of Speed", FALSE]
				SpellList:Set["Boon of Rakurr", FALSE]
				;; these are Tuurgin's buffs
				SpellList:Set["${WarmthoftheGreatBear}", FALSE]
				SpellList:Set["${TuurginsGiftofFury}", FALSE]
				SpellList:Set["${SuperiorTuurginsVigor}", FALSE]
				SpellList:Set["${BoonofTuurgin}", FALSE]
			}
		}
		;; Favor of the Hunter	
		elseif ${Me.Ability[Favor of the Hunter](exists)} && !${Me.TargetBuff["Spirit's Bountiful Blessing"](exists)} && ${LEVEL}>=35
		{
			SpellList:Set["Favor of the Hunter", FALSE]
		}
		else
		{	
			;; Lesser Buffs
			doLesserBuff:Set[TRUE]
			if ${CheckForBuff}
			{
				if ${Me.TargetBuff["Spirit's Bountiful Blessing"](exists)}
					doLesserBuff:Set[FALSE]
				if ${Me.TargetBuff[Gift of Boqobol](exists)}
					doLesserBuff:Set[FALSE]
				if ${Me.TargetBuff[Gift of the Oracle](exists)}
					doLesserBuff:Set[FALSE]
				if ${Me.TargetBuff[Infusion of Spirit](exists)}
					doLesserBuff:Set[FALSE]
			}
				
			if ${doLesserBuff}
			{
				if ${CheckForBuff}
				{
					;; ==========   RAKURR BUFFS   ==========
					if ${Me.Ability[${RakurrsGiftofGrace}](exists)} && ${LEVEL}>=35
					{
						SpellList:Set["${RakurrsGiftofGrace}", ${Me.TargetBuff[${RakurrsGiftofGrace}](exists)}]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "Rakurr's Grace"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					}
					if ${Me.Ability[${RakurrsGiftofSpeed}](exists)} && ${LEVEL}>=35
					{
						SpellList:Set["${RakurrsGiftofSpeed}", ${Me.TargetBuff[${RakurrsGiftofSpeed}](exists)}]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "Speed of Rakurr"
						if ${Me.Ability[${Return}](exists)}
						{
							SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
						}
						else
						{
							call FindHighestLevel ${LEVEL} "Spirit of Rakurr"
							if ${Me.Ability[${Return}](exists)}
								SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
						}
					}
					call FindHighestLevel ${LEVEL} "Boon of Rakurr"
						SpellList:Set["${Return}", ${Me.TargetBuff["Boon of Rakurr"](exists)}]
					
					
					;; ==========   TUURGIN BUFFS   ==========
					if ${Me.Ability[${WarmthoftheGreatBear}](exists)} && ${LEVEL}>=35
					{
						SpellList:Set["${WarmthoftheGreatBear}", ${Me.TargetBuff[${WarmthoftheGreatBear}](exists)}]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "${CoatoftheGreatBear}"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					}
					if ${Me.Ability[${TuurginsGiftofFury}](exists)} && ${LEVEL}>=35
					{
						SpellList:Set["${TuurginsGiftofFury}", ${Me.TargetBuff[${TuurginsGiftofFury}](exists)}]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "${RageofTuurgin}"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					}
					if ${Me.Ability[${SuperiorTuurginsVigor}](exists)} && ${LEVEL}>=35
					{
						SpellList:Set["${SuperiorTuurginsVigor}", ${Me.TargetBuff[${SuperiorTuurginsVigor}](exists)}]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "${TuurginsVigor}"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					}
					call FindHighestLevel ${LEVEL} "Boon of Tuurgin"
						SpellList:Set["${Return}", ${Me.TargetBuff["Boon of Turgin"](exists)}]
					
					
					;; ==========   ALL TOTEM BUFFS   ==========
					call FindHighestLevel ${LEVEL} "Boon of Boqobol"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					call FindHighestLevel ${LEVEL} "Infusion"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					call FindHighestLevel ${LEVEL} "Oracle's Sight"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
					call FindHighestLevel ${LEVEL} "Boon of Bosrid"
						SpellList:Set[${Return}, ${Me.TargetBuff[${Return}](exists)}]
				}
				else
				{
					;; ==========   RAKURR BUFFS   ==========
					if ${Me.Ability[${RakurrsGiftofGrace}](exists)}
					{
						SpellList:Set["${RakurrsGiftofGrace}", FALSE]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "Rakurr's Grace"
						SpellList:Set[${Return}, FALSE]
					}
					if ${Me.Ability[${RakurrsGiftofSpeed}](exists)}
					{
						SpellList:Set["${RakurrsGiftofSpeed}", FALSE]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "Speed of Rakurr"
						if ${Me.Ability[${Return}](exists)}
						{
							SpellList:Set[${Return}, FALSE]
						}
						else
						{
							call FindHighestLevel ${LEVEL} "Spirit of Rakurr"
							if ${Me.Ability[${Return}](exists)}
								SpellList:Set[${Return}, FALSE]
						}
					}
					call FindHighestLevel ${LEVEL} "Boon of Rakurr"
						SpellList:Set["${Return}", FALSE]
						
					;; ==========   TUURGIN BUFFS   ==========
					if ${Me.Ability[${WarmthoftheGreatBear}](exists)}
					{
						SpellList:Set["${WarmthoftheGreatBear}", FALSE]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "${CoatoftheGreatBear}"
						SpellList:Set[${Return}, FALSE]
					}
					if ${Me.Ability[${TuurginsGiftofFury}](exists)}
					{
						SpellList:Set["${TuurginsGiftofFury}", FALSE]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "${RageofTuurgin}"
						SpellList:Set[${Return}, FALSE]
					}
					if ${Me.Ability[${SuperiorTuurginsVigor}](exists)}
					{
						SpellList:Set["${SuperiorTuurginsVigor}", FALSE]
					}
					else
					{
						call FindHighestLevel ${LEVEL} "${TuurginsVigor}"
						SpellList:Set[${Return}, FALSE]
					}
					call FindHighestLevel ${LEVEL} "Boon of Tuurgin"
						SpellList:Set["${Return}", FALSE]
						
					;; ==========   ALL TOTEM BUFFS   ==========
					call FindHighestLevel ${LEVEL} "Boon of Boqobol"
						SpellList:Set[${Return}, FALSE]
					call FindHighestLevel ${LEVEL} "Infusion"
						SpellList:Set[${Return}, FALSE]
					call FindHighestLevel ${LEVEL} "Oracle's Sight"
						SpellList:Set[${Return}, FALSE]
					call FindHighestLevel ${LEVEL} "Boon of Bosrid"
						SpellList:Set[${Return}, FALSE]
					call FindHighestLevel ${LEVEL} "Life Ward"
						SpellList:Set[${Return}, FALSE]
				}
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
