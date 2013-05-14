;===================================================
;===          BUFF AREA SUBROUTINE              ====
;===================================================

;; must redefine these setting references
variable settingsetref TriggerBuffs
variable settingsetref BuffOnly

function main(bool CheckForBuff=TRUE)
{

	;-------------------------------------------
	;; define our variable used in this script
	;-------------------------------------------
	variable int i
	variable string temp
	variable int TotalPawns
	variable collection:int HasBuff
	variable index:pawn CurrentPawns
	variable index:string PC
	variable iterator Iterator
	variable iterator Iterator2
	variable bool WeBuffed
	variable bool Okay2Buff
	variable string buff

	;-------------------------------------------
	;; dim our button
	;-------------------------------------------
	UIElement[BuffArea@BuffBot@DPS@Tools]:SetAlpha[0.75]
	
	;-------------------------------------------
	;; DPS data should already exists so just update our settings reference
	;-------------------------------------------
	TriggerBuffs:Set[${LavishSettings[DPS].FindSet[TriggerBuffs-${Me.FName}].GUID}]
	BuffOnly:Set[${LavishSettings[DPS].FindSet[BuffOnly-${Me.FName}].GUID}]
	
	;-------------------------------------------
	; Cycle through all PC in area and add them to our list to be buffed
	;-------------------------------------------
	TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	for (i:Set[1] ;  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<25 && ${TotalPawns}>0 ; i:Inc)
	{
		if ${CurrentPawns.Get[${i}].Type.Equal[Me]} || ${CurrentPawns.Get[${i}].Type.Equal[PC]} || ${CurrentPawns.Get[${i}].Type.Equal[Group Member]}
		{
			if ${CurrentPawns.Get[${i}].HaveLineOfSightTo}
			{
				PC:Insert[${CurrentPawns.Get[${i}].Name}]
				EchoIt2 "*Adding ${CurrentPawns.Get[${i}].Name}"
			}
		}
	}

	;-------------------------------------------
	; Cycle through the identified PC's and buff them
	;-------------------------------------------
	for (i:Set[1] ; ${PC[${i}](exists)} ; i:Inc)
	{
		;; set temp to the PC we want to buff
		temp:Set[${PC[${i}]}]
		if !${Pawn[exactname,${temp}](exists)}
		{
			continue
		}

		;-------------------------------------------
		;; check to see if PC exists, within buffing range, and we can see them
		;-------------------------------------------
		if ${Pawn[exactname,${temp}](exists)} && ${Pawn[exactname,${temp}].Distance}<25 && ${Pawn[exactname,${temp}].HaveLineOfSightTo}
		{
			;; set our flag
			Okay2Buff:Set[FALSE]

			;; set our Iterator to BuffOnly
			BuffOnly:GetSettingIterator[Iterator]

			;; if nothing is in the buffonly list then might as well we buff everyone
			if !${Iterator.Key(exists)}
			{
				Okay2Buff:Set[TRUE]
			}
			
			;; cycle through all our BuffOnly checking if they exist by name or by guild
			while ${Iterator.Key(exists)}
			{
				if ${Pawn[exactname,${temp}].Name.Find[${Iterator.Key}]} || ${Pawn[exactname,${temp}].Title.Find[${Iterator.Key}]}
				{
					Okay2Buff:Set[TRUE]
				}
				Iterator:Next
			}
				
			
			;-------------------------------------------
			;; Let's Buff the PC if its okay to buff them
			;-------------------------------------------
			if ${Okay2Buff}
			{
				;; clear this variable
				HasBuff:Clear
				
				;-------------------------------------------
				;; Identify what buffs PC has by targeting them offensively
				;-------------------------------------------
				if ${CheckForBuff}
				{
					;; we cannot target offensive our self
					if !${temp.Find[${Me.FName}]}
					{
						VGExecute "/targetoffensive ${temp}"
						wait 15 ${Me.Target.Name.Find[${temp}]} && ${Me.Target.Level}>0
						wait 5
					}
					
					;; set our Iterator to TriggerBuffs
					TriggerBuffs:GetSettingIterator[Iterator]

					;; cycle through all our trigger buffs
					while ${Iterator.Key(exists)}
					{
						;; check the PC for the buff and add it to the HasBuff variable
						if ${Me.TargetBuff[${Iterator.Key}](exists)} || (${temp.Find[${Me.FName}]} && ${Me.Effect[${Iterator.Key}](exists)})
						{
							HasBuff:Set[${Iterator.Key},${Iterator.Key}]
						}
						Iterator:Next
					}
				}
			
				;-------------------------------------------
				;; Now set the PC as defensive Target so we can buff them
				;-------------------------------------------
				VGExecute "/cleartargets"
				wait 3
				Pawn[exactname,${temp}]:Target
				wait 10 ${Me.DTarget.Name.Find[${temp}]} && ${Me.DTarget.Level}>0
				waitframe
				
				;; if our DTarget matches the PC
				if ${Me.DTarget.Name.Find[${temp}]}
				{
					;; set out Iterator to TriggerBuffs
					TriggerBuffs:GetSettingIterator[Iterator]
						
					;; set our flag to we have not buffed anyone
					WeBuffed:Set[FALSE]
								
					;; cycle through all our trigger buffs to ensure we casted them
					while ${Iterator.Key(exists)}
					{
						if !${Me.DTarget(exists)} || ${Me.DTarget.Distance}>25
							break
						if !${ToolBuff.AreWeReady}
						{
							while !${ToolBuff.AreWeReady} && ${Me.DTarget(exists)} && ${Me.DTarget.Distance}<25
								wait frame
							wait 3
						}
			
						;buff:Set[${Me.Ability[${Iterator.Key}].Restrictions}]
						;buff:Set[${buff.Right[${Math.Calc[${buff.Length}-20]}]}]
									
						;-------------------------------------------
						;; cast the buff
						;-------------------------------------------
						if ${Me.Ability[${Iterator.Key}].IsReady} && !${HasBuff.Element[${Iterator.Key}](exists)} && ${Math.Calc[${Me.DTarget.Level}+15]}>=${Me.Ability[${Iterator.Key}].LevelGranted}
						{
							call UseAbility2 "${Iterator.Key}"
							if ${Return}
							{
								WeBuffed:Set[TRUE]
							}
						}
						Iterator:Next
					}
								
					;; announce we buffed someone
					if ${WeBuffed}
					{
						EchoIt2 "Buffed:  ${temp}"
						vgecho "Buffed:  ${temp}"
						waitframe
					}
				}
			}
		}
	}
	
	;; clear our veribles and undim our button
	PC:Clear
	HasBuff:Clear
	UIElement[BuffArea@BuffBot@DPS@Tools]:SetAlpha[1]
	VGExecute "/cleartargets"
	wait 3
}


;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt2(string aText)
{
	echo "[${Time}][Tools]: ${aText}"
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
		EchoIt2 "${ABILITY} does not exist"
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

		;; now execute the ability
		Me.Ability[${ABILITY}]:Use
		
		wait 2 !${ToolBuff.AreWeReady}
		if !${ToolBuff.AreWeReady}
		{
			while !${ToolBuff.AreWeReady}
				wait frame
			wait 3
		}

		;; say we executed ability successfully
		return TRUE
	}
	;; say we did not execute the ability
	return FALSE
}

objectdef Obj_Commands
{
	;; identify the Passive Ability
	variable string PassiveAbility = "Racial Inheritance:"

	;; initialize when objectdef is created
	method Initialize()
	{
		variable int i
		for (i:Set[1] ; ${Me.Ability[${i}](exists)} ; i:Inc)
		{
			if ${Me.Ability[${i}].Name.Find[Racial Inheritance:]}
				This.PassiveAbility:Set[${Me.Ability[${i}].Name}]
		}
	}

	;; called when script is shut down
	method Shutdown()
	{
	}

	;; external command
	member:bool AreWeReady()
	{
		if ${Me.Ability[${This.PassiveAbility}].IsReady}
			return TRUE
		return FALSE
	}
	
	member:bool AreWeEating()
	{
		variable int i
		for (i:Set[1]; ${Me.Effect[${i}](exists)}; i:Inc)
		{
			if ${Me.Effect[${i}].IsBeneficial}
			{
				if ${Me.Effect[${i}].Description.Find[Health:]} && ${Me.Effect[${i}].Description.Find[Energy:]} && ${Me.Effect[${i}].Description.Find[over]} && ${Me.Effect[${i}].Description.Find[seconds]}
					return TRUE
			}
		}
		return FALSE
	}
}
variable(global) Obj_Commands ToolBuff