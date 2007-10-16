;*********************************************
; GetAbilities.iss
; Ability Harvester
;
; Purely experimental code for now.
;
;	Instructions:
;		For best results, page thru all abilities in
;		knowledge book before starting script.
;*********************************************

variable string Ability_File = "${LavishScript.HomeDirectory}/scripts/xml/Abilities.xml"
variable settingsetref BaseRef
variable abilityobj AbObj
variable string CurrentAction
variable string CurrentSet

function main()
{
	variable int tempvar=0

	echo Initializing...
	AbObj:Init_Config

	echo Searching Abilities...
	do
	{
		call GetAbilityData ${tempvar}
	}
	while ${tempvar:Inc}<=${Me.NumAbilities}

	echo Saving Results....
	AbObj:Save

	echo Quiting
	AbObj:Shutdown
}

function GetAbilityData(int ID)
{

	Me.Ability[${ID}]:Examine
	wait 20

	switch ${Me.Ability[${ID}].SpellBookType}
	{
		case 0 ;tradeskill
			CurrentSet:Set[TradeSkill]
			break

		case 1 ;combat
			CurrentSet:Set[Combat]
			break

		case 2 ;general
			CurrentSet:Set[General]
			break

		case 3 ;spells
			CurrentSet:Set[Spells]
			break

		default
			CurrentSet:Set[WTF]
			break
	}

	AbObj:StoreAbilityData[${CurrentSet},${Me.Ability[${ID}].ID}]

	press esc

}

function StoreAbilityData (int Set, int AbilityID)
{
	variable int tempvar=0

	${Set}:AddSetting[ID,${Me.Ability[${AbilityID}].ID}]
	${Set}:AddSetting[Name,${Me.Ability[${AbilityID}].Name}]
	${Set}:AddSetting[Description,${Me.Ability[${AbilityID}].Description}]
	${Set}:AddSetting[Tier,${Me.Ability[${AbilityID}].Tier}]
	${Set}:AddSetting[HealthCost,${Me.Ability[${AbilityID}].HealthCost}]
	${Set}:AddSetting[PowerCost,${Me.Ability[${AbilityID}].PowerCost}]
	${Set}:AddSetting[ConcentrationCost,${Me.Ability[${AbilityID}].ConcentrationCost}]
	${Set}:AddSetting[MainIconID,${Me.Ability[${AbilityID}].MainIconID}]
	${Set}:AddSetting[HOIconID,${Me.Ability[${AbilityID}].HOIconID}]
	${Set}:AddSetting[CastingTime,${Me.Ability[${AbilityID}].CastingTime}]
	${Set}:AddSetting[RecoveryTime,${Me.Ability[${AbilityID}].RecoveryTime}]
	${Set}:AddSetting[RecastTime,${Me.Ability[${AbilityID}].RecastTime}]
	${Set}:AddSetting[MaxDuration,${Me.Ability[${AbilityID}].MaxDuration}]
	${Set}:AddSetting[BackDropIconID,${Me.Ability[${AbilityID}].BackDropIconID}]
	${Set}:AddSetting[HealthCostPerTick,${Me.Ability[${AbilityID}].HealthCostPerTick}]
	${Set}:AddSetting[PowerCostPerTick,${Me.Ability[${AbilityID}].PowerCostPerTick}]
	${Set}:AddSetting[MaxAOETargets,${Me.Ability[${AbilityID}].MaxAOETargets}]
	${Set}:AddSetting[DoesNotExpire,${Me.Ability[${AbilityID}].DoesNotExpire}]
	${Set}:AddSetting[GroupRestricted,${Me.Ability[${AbilityID}].GroupRestricted}]
	${Set}:AddSetting[AllowRaid,${Me.Ability[${AbilityID}].AllowRaid}]
	${Set}:AddSetting[EffectRadius,${Me.Ability[${AbilityID}].EffectRadius}]
	${Set}:AddSetting[TargetType,${Me.Ability[${AbilityID}].TargetType}]
	${Set}:AddSetting[SpellBookType,${Me.Ability[${AbilityID}].SpellBookType}]
	${Set}:AddSetting[NumEffects,${Me.Ability[${AbilityID}].NumEffects}]
	do
	{
		${Set}:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}]Effect[${tempvar}.PercentSuccess}]
		${Set}:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}]Effect[${tempvar}.Indentation}]
		${Set}:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}]Effect[${tempvar}.Desciption}]
	}
	while ${tempvar:Inc}<=${Me.Ability[${AbilityID}].NumEffects}

}

objectdef abilityobj
{
	method Init_Config()
	{
		CurrentAction:Set[Initializing....]

		LavishSettings[Abilities]:Clear
		LavishSettings:AddSet[Abilities]
		LavishSettings[Abilities]:AddSet[${Me.SubClass}]
		LavishSettings[${Me.SubClass}]:AddSet[Spells]
		LavishSettings[${Me.SubClass}]:AddSet[General]
		LavishSettings[${Me.SubClass}]:AddSet[Combat]
		LavishSettings[${Me.SubClass}]:AddSet[TradeSkill]

		LavishSettings[Abilities]:Import[${Ability_File}]

		CurrentAction:Set[Initialized]
	}

	method Shutdown()
	{
		This:Save[]
		LabishSettings[Abilities]:Clear
	}

	method Save()
	{
		LabishSettings[Abilities]:Export[${Ability_File}]
	}

	method StoreAbilityData(int Set, int AbilityID)
	{
		variable int tempvar=0

		${Set}:AddSetting[ID,${Me.Ability[${AbilityID}].ID}]
		${Set}:AddSetting[Name,${Me.Ability[${AbilityID}].Name}]
		${Set}:AddSetting[Description,${Me.Ability[${AbilityID}].Description}]
		${Set}:AddSetting[Tier,${Me.Ability[${AbilityID}].Tier}]
		${Set}:AddSetting[HealthCost,${Me.Ability[${AbilityID}].HealthCost}]
		${Set}:AddSetting[PowerCost,${Me.Ability[${AbilityID}].PowerCost}]
		${Set}:AddSetting[ConcentrationCost,${Me.Ability[${AbilityID}].ConcentrationCost}]
		${Set}:AddSetting[MainIconID,${Me.Ability[${AbilityID}].MainIconID}]
		${Set}:AddSetting[HOIconID,${Me.Ability[${AbilityID}].HOIconID}]
		${Set}:AddSetting[CastingTime,${Me.Ability[${AbilityID}].CastingTime}]
		${Set}:AddSetting[RecoveryTime,${Me.Ability[${AbilityID}].RecoveryTime}]
		${Set}:AddSetting[RecastTime,${Me.Ability[${AbilityID}].RecastTime}]
		${Set}:AddSetting[MaxDuration,${Me.Ability[${AbilityID}].MaxDuration}]
		${Set}:AddSetting[BackDropIconID,${Me.Ability[${AbilityID}].BackDropIconID}]
		${Set}:AddSetting[HealthCostPerTick,${Me.Ability[${AbilityID}].HealthCostPerTick}]
		${Set}:AddSetting[PowerCostPerTick,${Me.Ability[${AbilityID}].PowerCostPerTick}]
		${Set}:AddSetting[MaxAOETargets,${Me.Ability[${AbilityID}].MaxAOETargets}]
		${Set}:AddSetting[DoesNotExpire,${Me.Ability[${AbilityID}].DoesNotExpire}]
		${Set}:AddSetting[GroupRestricted,${Me.Ability[${AbilityID}].GroupRestricted}]
		${Set}:AddSetting[AllowRaid,${Me.Ability[${AbilityID}].AllowRaid}]
		${Set}:AddSetting[EffectRadius,${Me.Ability[${AbilityID}].EffectRadius}]
		${Set}:AddSetting[TargetType,${Me.Ability[${AbilityID}].TargetType}]
		${Set}:AddSetting[SpellBookType,${Me.Ability[${AbilityID}].SpellBookType}]
		${Set}:AddSetting[NumEffects,${Me.Ability[${AbilityID}].NumEffects}]
		do
		{
			${Set}:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}]Effect[${tempvar}.PercentSuccess}]
			${Set}:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}]Effect[${tempvar}.Indentation}]
			${Set}:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}]Effect[${tempvar}.Desciption}]
		}
		while ${tempvar:Inc}<=${Me.Ability[${AbilityID}].NumEffects}

	}

}