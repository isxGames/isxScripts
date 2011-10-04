;===================================================
;===          BUFF AREA SUBROUTINE              ====
;===================================================
function main()
{
	PerformAction:Set[BuffArea]
	UIElement[BuffArea@BM1]:SetAlpha[0.5]

	variable int i
	variable string temp
	variable int TotalPawns
	variable index:pawn CurrentPawns
	variable index:string PC
	
	variable bool ConstructsAugmentationBuff = FALSE
	variable bool FavorOfTheLifeGiverBuff = FALSE
	variable bool SeraksAmplificationBuff = FALSE
	variable bool InspiritBuff = FALSE
	variable bool LifeGraftBuff = FALSE
	variable bool MentalStimulationBuff = FALSE
	variable bool AcceleratedRegenerationBuff = FALSE
	variable bool CerebralGraftBuff = FALSE
	variable bool HealthGraftBuff = FALSE
	variable bool MentalInfusionBuff = FALSE
	variable bool SeraksAugmentationBuff = FALSE
	variable bool SeraksMantleBuff = FALSE
	variable bool VitalizeBuff = FALSE
	variable bool RegenerationBuff = FALSE
	
	SetHighestAbility2 "ConstructsAugmentation" "Construct's Augmentation"
	SetHighestAbility2 "FavorOfTheLifeGiver" "Favor of the Life Giver"
	SetHighestAbility2 "SeraksAmplification" "Serak's Amplification"
	SetHighestAbility2 "Inspirit" "Inspirit"
	SetHighestAbility2 "LifeGraft" "Life Graft"
	SetHighestAbility2 "MentalStimulation" "Mental Stimulation"
	SetHighestAbility2 "AcceleratedRegeneration" "Accelerated Regeneration"
	SetHighestAbility2 "CerebralGraft" "Cerebral Graft"
	SetHighestAbility2 "HealthGraft" "Health Graft"
	SetHighestAbility2 "MentalInfusion" "Mental Infusion"
	SetHighestAbility2 "SeraksAugmentation" "Serak's Augmentation"
	SetHighestAbility2 "SeraksMantle" "Serak's Mantle"
	SetHighestAbility2 "Vitalize" "Vitalize"
	SetHighestAbility2 "Regeneration" "Regeneration"

	;-------------------------------------------
	; Buffing self will buff my group (less buffing to do)
	;-------------------------------------------
	Pawn[Me]:Target
	do
	{
		waitframe
	}
	while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
	
	if ${Me.Ability[${ConstructsAugmentation}](exists)}
	{
		call UseAbility2 "${ConstructsAugmentation}"
	}
	else
	{
		call UseAbility2 "${SeraksMantle}"
		
		if ${Me.Ability[${FavorOfTheLifeGiver}](exists)}
		{
			call UseAbility2 "${FavorOfTheLifeGiver}"
		}
		else
		{
			call UseAbility2 "${SeraksAmplification}"
			if ${Return}
			{
				SeraksAugmentationBuff:Set[TRUE]
			}
			call UseAbility2 "${Inspirit}"
			if ${Return}
			{
				VitalizeBuff:Set[TRUE]
			}
			call UseAbility2 "${LifeGraft}"
			if ${Return}
			{
				HealthGraftBuff:Set[TRUE]
			}
			call UseAbility2 "${MentalStimulation}"
			if ${Return}
			{
				MentalInfusionBuff:Set[TRUE]
			}
			call UseAbility2 "${AcceleratedRegeneration}"
			call UseAbility2 "${CerebralGraft}"
			if !${HealthGraftBuff}
			{
				call UseAbility2 "${HealthGraft}"
			}
			if !${MentalInfusionBuff}
			{
				call UseAbility2 "${MentalInfusion}"
			}
			if !${SeraksAugmentationBuff}
			{
				call UseAbility2 "${SeraksAugmentation}"
			}
			if !${VitalizeBuff}
			{
				call UseAbility2 "${Vitalize}"
			}
		}
	}

	;-------------------------------------------
	; Populate our CurrentPawns variable
	;-------------------------------------------
	TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	
	;-------------------------------------------
	; Cycle through all PC in area and add them to our list to be buffed
	;-------------------------------------------
	for (i:Set[1] ;  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<25 ; i:Inc)
	{
		if ${CurrentPawns.Get[${i}].Type.Equal[Me]} || ${CurrentPawns.Get[${i}].Type.Equal[PC]} || ${CurrentPawns.Get[${i}].Type.Equal[Group Member]}
		{
			if ${CurrentPawns.Get[${i}].HaveLineOfSightTo} && ${CurrentPawns.Get[${i}].Level}>43
			{
				PC:Insert[${CurrentPawns.Get[${i}].Name}]
				EchoIt2 "*Adding ${CurrentPawns.Get[${i}].Name}"
			}
		}
	}

	;-------------------------------------------
	; Cycle through all PC and buff them
	;-------------------------------------------
	for (i:Set[1] ; ${PC[${i}](exists)} ; i:Inc)
	{
		temp:Set[${PC[${i}]}]
		if !${Pawn[exactname,${temp}](exists)}
		{
			continue
		}

		EchoIt2 "[${i}] Checking buffs on ${temp}"
		
		;; Offensive target our PC
		VGExecute "/targetoffensive ${temp}"
		wait 15 ${Me.TargetBuff[${ConstructsAugmentation}](exists)}

		;-------------------------------------------
		; IDENTIFY ALL POSSIBLE BUFFS ON TARGET
		;-------------------------------------------
		if ${Me.TargetBuff[${ConstructsAugmentation}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${ConstructsAugmentation}](exists)})
		{
			VGExecute "/cleartargets"
			wait 15 !${Me.TargetBuff[${ConstructsAugmentation}](exists)}
			continue
		}
		if ${Me.TargetBuff[Serak's Amplification](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[Serak's Amplification](exists)})
		{
			SeraksAmplificationBuff:Set[TRUE]
			SeraksAugmentationBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[Inspirit](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[Inspirit](exists)})
		{
			InspiritBuff:Set[TRUE]
			VitalizeBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[Life Graft](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[Life Graft](exists)})
		{
			LifeGraftBuff:Set[TRUE]
			HealthGraftBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[Mental Stimulation](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[Mental Stimulation](exists)})
		{
			MentalStimulationBuff:Set[TRUE]
			MentalInfusionBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[Accelerated Regeneration](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[Accelerated Regeneration](exists)})
		{
			AcceleratedRegenerationBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[${CerebralGraft}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${CerebralGraft}](exists)})
		{
			CerebralGraftBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[${SeraksMantle}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${SeraksMantle}](exists)})
		{
			SeraksMantleBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[${HealthGraft}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${HealthGraft}](exists)})
		{
			HealthGraftBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[${MentalInfusion}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${MentalInfusion}](exists)})
		{
			MentalInfusionBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[${SeraksAugmentation}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${SeraksAugmentation}](exists)})
		{
			SeraksAugmentationBuff:Set[TRUE]
		}
		if ${Me.TargetBuff[${Vitalize}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${Vitalize}](exists)})
		{
			Vitalize:Set[TRUE]
		}
		if ${Me.TargetBuff[${Regeneration}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${Regeneration}](exists)})
		{
			RegenerationBuff:Set[TRUE]
		}
		
		;-------------------------------------------
		; SET DTARGET TO THE ONE WHO WE WANT TO BUFF
		;-------------------------------------------
		Pawn[exactname,${temp}]:Target
		wait 5 ${Me.DTarget.Name.Find[${temp}]}
		
		;-------------------------------------------
		;; CAST CONSTRUCT BUFF
		;-------------------------------------------
		if ${Me.Target.Level}>=44 || (${temp.Find[${Me.FName}]} && ${Me.Level}>=44)
		{
			if ${Me.Ability[${ConstructsAugmentation}](exists)}
			{
				Pawn[exactname,${temp}]:Target
				wait 5 ${Me.DTarget.Name.Find[${temp}]}
				call UseAbility2 "${ConstructsAugmentation}"
				if ${Return}
				{
					EchoIt2 "[${i}] Buffed: ${Me.DTarget.Name}"
				}
				VGExecute "/cleartargets"
				wait 3
				continue
			}
		}

		;-------------------------------------------
		;; CAST ALL-IN-ONE BUFF
		;-------------------------------------------
		if ${Me.Target.Level}>=35 || (${temp.Find[${Me.FName}]} && ${Me.Level}>=35)
		{
			if ${Me.Ability[${FavorOfTheLifeGiver}](exists)}
			{
				;; cast the buff if it does not exist
				;echo !${SeraksMantleBuff} || !${SeraksAmplificationBuff} || !${InspiritBuff} || !${LifeGraftBuff} || !${MentalStimulationBuff} || !${AcceleratedRegenerationBuff} || !${CerebralGraftBuff}
				if !${SeraksMantleBuff} || !${SeraksAmplificationBuff} || !${InspiritBuff} || !${LifeGraftBuff} || !${MentalStimulationBuff} || !${AcceleratedRegenerationBuff} || !${CerebralGraftBuff}
				{
					Pawn[exactname,${temp}]:Target
					wait 5 ${Me.DTarget.Name.Find[${temp}]}
					call UseAbility2 "${SeraksMantle}"
					call UseAbility2 "${FavorOfTheLifeGiver}"
					if ${Return}
					{
						EchoIt2 "[${i}] Buffed: ${Me.DTarget.Name}"
					}
				}
				VGExecute "/cleartargets"
				wait 3
				continue
			}
		}
		
		;-------------------------------------------
		; CAST REMAINING BUFFS
		;-------------------------------------------
		if !${SeraksAmplificationBuff}
		{
			call UseAbility2 "${SeraksAmplification}"
			SeraksAugmentationBuff:Set[TRUE]
		}
		if !${InspiritBuff}
		{
			call UseAbility2 "${Inspirit}"
			VitalizeBuff:Set[TRUE]
		}
		if !${LifeGraftBuff}
		{
			call UseAbility2 "${LifeGraft}"
			HealthGraftBuff:Set[TRUE]
		}
		if !${MentalStimulationBuff}
		{
			call UseAbility2 "${MentalStimulation}"
			MentalInfusionBuff:Set[TRUE]
		}
		if !${AcceleratedRegenerationBuff}
		{
			call UseAbility2 "${AcceleratedRegeneration}"
			AcceleratedRegenerationBuff:Set[TRUE]
		}
		if !${CerebralGraftBuff}
		{
			call UseAbility2 "${CerebralGraft}"
			CerebralGraftBuff:Set[TRUE]
		}
		if !${SeraksMantleBuff}
		{
			call UseAbility2 "${SeraksMantle}"
			SeraksMantleBuff:Set[TRUE]
		}
		if !${HealthGraftBuff}
		{
			call UseAbility2 "${HealthGraft}"
		}
		if !${MentalInfusionBuff}
		{
			call UseAbility2 "${MentalInfusion}"
		}
		if !${SeraksAugmentationBuff}
		{
			call UseAbility2 "${SeraksAugmentation}"
		}
		if !${VitalizeBuff}
		{
			call UseAbility2 "${Vitalize}"
		}
	}
	
	PC:Clear
	UIElement[BuffArea@BM1]:SetAlpha[1]
}

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
;===================================================
atom(script) SetHighestAbility2(string AbilityVariable, string AbilityName)
{
	declare L int local 8
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[8] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]
	AbilityLevels[9]:Set[IX]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		;EchoIt2 " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Find highest Ability level - based upon current level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${Me.Level}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		;EchoIt2 " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	;EchoIt2 " --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	script "None"
	return
}

;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt2(string aText)
{
	echo "[${Time}][BM1]: ${aText}"
}

;===================================================
;===              USE AN ABILITY                ====
;===  called from within AttackTarget routine   ====
;===================================================
function:bool UseAbility2(string ABILITY)
{
	;-------------------------------------------
	; return if ability does not exist
	;-------------------------------------------
	if !${Me.Ability[${ABILITY}](exists)} || ${Me.Ability[${ABILITY}].LevelGranted}>${Me.Level}
	{
		;EchoIt2 "${ABILITY} does not exist"
		return FALSE
	}

	;-------------------------------------------
	; execute ability only if it is ready
	;-------------------------------------------
	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; return if we do not have enough energy
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt2 "Not enought Energy for ${ABILITY}"
			return FALSE
		}

		;; allow time for the ability to become ready
		wait 5 ${Me.Ability[${ABILITY}].IsReady}
		
		;; now execute the ability
		EchoIt2 "Used ${ABILITY}"
		Me.Ability[${ABILITY}]:Use
		wait 5

		;; loop this while checking for crits and furious
		while ${Me.IsCasting} || ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}

		;; say we executed ability successfully
		return TRUE
	}
	;; say we did not execute the ability
	return FALSE
}
