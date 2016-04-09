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
variable settingsetref MyClass
variable abilityobj AbObj
variable string CurrentAction
variable string CurrentSet

function main()
{
	variable int tempvar=1

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

function GetAbilityData(int tempKey)
{

	echo Fetching Ability ${tempKey}
	Me.Ability[${tempKey}]:Examine
	wait 10

	switch ${Me.Ability[${tempKey}].SpellBookType}
	{
		case 0
			CurrentSet:Set[Spells]
			break

		case 1
			CurrentSet:Set[Combat]
			break

		case 2
			CurrentSet:Set[General]
			break

		case 3
			CurrentSet:Set[TradeSkill]
			break

		case 4
			CurrentSet:Set[Passive]
			break

		default
			CurrentSet:Set[WTF]
			break
	}


	AbObj:StoreAbilityData[${CurrentSet},${tempKey}]

	press esc

}

objectdef abilityobj
{
	method Init_Config()
	{
		CurrentAction:Set[Initializing....]

		LavishSettings[Abilities]:Clear
		LavishSettings:AddSet[Abilities]
		LavishSettings[Abilities]:AddSet[${Me.SubClass}]

		MyClass:Set[${LavishSettings[Abilities].FindSet[${Me.SubClass}]}]
		MyClass:AddSet[Spells]
		MyClass:AddSet[General]
		MyClass:AddSet[Combat]
		MyClass:AddSet[TradeSkill]
		MyClass:AddSet[Passive]
		MyClass:AddSet[WTF]

		LavishSettings[Abilities]:Import[${Ability_File}]

		CurrentAction:Set[Initialized]
	}

	method Shutdown()
	{
		This:Save[]
		;LavishSettings[Abilities]:Clear
	}

	method Save()
	{
		LavishSettings[Abilities]:Export[${Ability_File}]
	}

	method StoreAbilityData(string AbSet, int AbilityID)
	{
		variable int tempvar=1
		variable settingsetref ThisSet

		;echo ${AbSet} , ${AbilityID}

		LavishSettings[Abilities].FindSet[${Me.SubClass}].FindSet[${AbSet}]:AddSet[${Me.Ability[${AbilityID}].Name}]
		;echo LavishSettings[Abilities].FindSet[${Me.SubClass}].FindSet[${AbSet}]:AddSet[${Me.Ability[${AbilityID}].Name}]

		ThisSet:Set[${LavishSettings[Abilities].FindSet[${Me.SubClass}].FindSet[${AbSet}].FindSet[${Me.Ability[${AbilityID}].Name}]}]
		;echo ${ThisSet.GUID}


		ThisSet:AddSetting[ID,${AbilityID}]
		ThisSet:AddSetting[Name,${Me.Ability[${AbilityID}].Name}]
		ThisSet:AddSetting[Description,${Me.Ability[${AbilityID}].Description}]
		ThisSet:AddSetting[Tier,${Me.Ability[${AbilityID}].Tier}]
		ThisSet:AddSetting[HealthCost,${Me.Ability[${AbilityID}].HealthCost}]
		ThisSet:AddSetting[PowerCost,${Me.Ability[${AbilityID}].PowerCost}]
		ThisSet:AddSetting[ConcentrationCost,${Me.Ability[${AbilityID}].ConcentrationCost}]
		ThisSet:AddSetting[MainIconID,${Me.Ability[${AbilityID}].MainIconID}]
		ThisSet:AddSetting[HOIconID,${Me.Ability[${AbilityID}].HOIconID}]
		ThisSet:AddSetting[CastingTime,${Me.Ability[${AbilityID}].CastingTime}]
		ThisSet:AddSetting[RecoveryTime,${Me.Ability[${AbilityID}].RecoveryTime}]
		ThisSet:AddSetting[RecastTime,${Me.Ability[${AbilityID}].RecastTime}]
		ThisSet:AddSetting[MaxDuration,${Me.Ability[${AbilityID}].MaxDuration}]
		ThisSet:AddSetting[BackDropIconID,${Me.Ability[${AbilityID}].BackDropIconID}]
		ThisSet:AddSetting[HealthCostPerTick,${Me.Ability[${AbilityID}].HealthCostPerTick}]
		ThisSet:AddSetting[PowerCostPerTick,${Me.Ability[${AbilityID}].PowerCostPerTick}]
		ThisSet:AddSetting[MaxAOETargets,${Me.Ability[${AbilityID}].MaxAOETargets}]
		ThisSet:AddSetting[DoesNotExpire,${Me.Ability[${AbilityID}].DoesNotExpire}]
		ThisSet:AddSetting[GroupRestricted,${Me.Ability[${AbilityID}].GroupRestricted}]
		ThisSet:AddSetting[AllowRaid,${Me.Ability[${AbilityID}].AllowRaid}]
		ThisSet:AddSetting[EffectRadius,${Me.Ability[${AbilityID}].EffectRadius}]
		ThisSet:AddSetting[TargetType,${Me.Ability[${AbilityID}].TargetType}]
		ThisSet:AddSetting[SpellBookType,${Me.Ability[${AbilityID}].SpellBookType}]
		ThisSet:AddSetting[NumEffects,${Me.Ability[${AbilityID}].NumEffects}]

		if ${Me.Ability[${AbilityID}].NumEffects}
		{
			do
			{
				ThisSet:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}].Effect[${tempvar}].PercentSuccess}]
				ThisSet:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}].Effect[${tempvar}].Indentation}]
				ThisSet:AddSetting[NumEffects${tempvar},${Me.Ability[${AbilityID}].Effect[${tempvar}].Description}]
			}
			while ${tempvar:Inc}<=${Me.Ability[${AbilityID}].NumEffects}
		}
	}

}


