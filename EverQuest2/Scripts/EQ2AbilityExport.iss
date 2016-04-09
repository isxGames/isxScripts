/************************************************
**Created by HotShot**
*Verison 1.08*
*Date: 05/11/09


**Commands**
run SpellExport		**Exports ALL spells, including Tradeskills/Abilities/Spells/Combat Arts
	Args:	HELP	**Displays these options
		NT	**No Tradeskill abilities
		TO	**Tradeskill abilities only
		NP  	**No Passive Abilities
		ADD	**Adds to the existing file
	 	NEW	**Creates a new file
		Settings**Exports using Settings instead of Attributes **DO NOT USE**

Verison 1.08 updates:
Added "ADD" and "NEW". If "ADD" is an option, it will open the existing file, load it, then update any spells then save it. This will allow easy adding of spells if you respec or have more than 1 of a class.
Added No Args will now use the predefined "default" of: NT NP ADD


Verison 1.06 updates:
Removed Examine and esc - since it wasn't doing anything

Verison 1.05 updates:
Pygar added NP for no passive abilities
Added Examine to avoid NULLs

Verison 1.04 updates:
Removed the NULLsCounter since it repeats for NULLs. Was giving wrong error messages.

Verison 1.03 updates:
Removed NULL message when some NULLS were missed

Verison 1.02 updates:
Changed int to int64
Changed from GetAbilities (used int) to NumAbilities
Added repeat for NULL abilities
**/

function main(string Args)
{
	if ${Args.Length}==0
	{
		echo Using default settings: NT NP ADD (No Tradeskill, No Passive, Add to existing file). Use "Run SpellExport help" for more options
		Args:Set[NT NP ADD]
	}
	if ${Args.Find[help]}
	{
		echo **Commands**
		echo run SpellExport		**Exports ALL spells, including Tradeskills/Abilities/Spells/Combat Arts
		echo  Args:	NT	**No Tradeskill abilities
		echo    TO	**Tradeskill abilities only
		echo    NP  **No Passive Abilities
		echo 	ADD	**Adds to the existing file
		echo 	NEW	**Creates a new file
		echo    Settings**Exports using Settings instead of Attributes **DO NOT USE**
		echo	***Defaults are: NT NP ADD***
		return
	}

	;variable string ConfigFile="${Script.CurrentDirectory}/${Me.SubClass}_SpellExport.xml"
	variable string ConfigFile="${Script.CurrentDirectory}/eq2_spell_lists/${Me.SubClass}_SpellExport.xml"

	;Clear then Load LavishSettings to make sure it's clean.
	LavishSettings[SpellInformation]:Clear
	LavishSettings:AddSet[SpellInformation]


	;If we are to ADD to the existing file instead of create a new one - load the information
	if ${Args.Find[ADD]}
	{
		LavishSettings[SpellInformation]:Import[${ConfigFile}]
	}

	LavishSettings[SpellInformation]:AddSet[${Me.SubClass}]
	variable settingsetref setSpell
	setSpell:Set[${LavishSettings[SpellInformation].FindSet[${Me.SubClass}]}]

	;variable index:ability SpellStorage
	echo Counting Spells in spell book... ${Me.NumAbilities}

	variable int SpellCounter=0
	variable int64 CurrentSpellID
	variable string CurrentSpellName
	variable int NULLsSkipped=0
	variable string WhatToReturn
	variable int aa
	variable int64 LastSpellID=0

	while ${SpellCounter:Inc}<=${Me.NumAbilities}
	{
		CurrentSpellID:Set[${Me.Ability[${SpellCounter}].ID}]
		LastSpellID:Set[${CurrentSpellID}]

		;Avoid spamming the server... Only 1 spell per second
		;Me.Ability[${CurrentSpellID}]:Examine
		wait 7.5

		CurrentSpellName:Set[${Me.Ability[id,${CurrentSpellID}].Name}]

		if ${Args.Find[NT]} && ${Me.Ability[id,${CurrentSpellID}].SpellBookType}==3
		{
			echo Skipping Tradeskill ability: ${CurrentSpellName} - ID: ${CurrentSpellID}
			continue
		}

		if ${Args.Find[NP]} && ${Me.Ability[id,${CurrentSpellID}].SpellBookType}==4
		{
			echo Skipping Passive ability: ${CurrentSpellName} - ID: ${CurrentSpellID}
			continue
		}

		if ${Args.Find[TO]} && ${Me.Ability[id,${CurrentSpellID}].SpellBookType}!=3
		{
			echo Skipping non-Tradeskill ability: ${CurrentSpellName} - ID: ${CurrentSpellID}
			continue
		}

		if ${CurrentSpellName.Equal[NULL]} || !${Me.Ability[id,${CurrentSpellID}](exists)}
		{
			echo Repeating NULL Ability: #${SpellCounter}/${Me.NumAbilities}... Coming up as:${CurrentSpellName} - ID: ${CurrentSpellID}
			SpellCounter:Dec
			continue
		}
		echo Adding Ability#: ${SpellCounter}/${Me.NumAbilities}... ${CurrentSpellName} - ID: ${CurrentSpellID}

		if !${Args.Find[Settings]}
		{
			setSpell:AddSetting[${CurrentSpellName},${CurrentSpellName}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[ID,${CurrentSpellID}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[Description,${Me.Ability[id,${CurrentSpellID}].Description}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[HealthCost,${Me.Ability[id,${CurrentSpellID}].HealthCost}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[PowerCost,${Me.Ability[id,${CurrentSpellID}].PowerCost}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[ConcentrationCost,${Me.Ability[id,${CurrentSpellID}].ConcentrationCost}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[MainIconID,${Me.Ability[id,${CurrentSpellID}].MainIconID}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[CastingTime,${Me.Ability[id,${CurrentSpellID}].CastingTime}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[RecoveryTime,${Me.Ability[id,${CurrentSpellID}].RecoveryTime}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[RecastTime,${Me.Ability[id,${CurrentSpellID}].RecastTime}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[MaxDuration,${Me.Ability[id,${CurrentSpellID}].MaxDuration}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[NumClasses,${Me.Ability[id,${CurrentSpellID}].NumClasses}]

			aa:Set[0]
			WhatToReturn:Set[]
			while ${aa:Inc}<=${Me.Ability[id,${CurrentSpellID}].NumEffects}
			{
				;Adding each Description line
				setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[EffectDesc${aa},${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc}]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[Flanking or behind](exists)}
					WhatToReturn:Set[${WhatToReturn}FLANKING*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[you must be sneaking](exists)} || ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[you must be in stealth](exists)} || ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[you must be stealthed to use this](exists)}
					WhatToReturn:Set[${WhatToReturn}SNEAKING*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[must be behind](exists)}
					WhatToReturn:Set[${WhatToReturn}BEHIND*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[does not affect epic](exists)}
					WhatToReturn:Set[${WhatToReturn}NOEPIC*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[if weapon equipped in ranged](exists)}
					WhatToReturn:Set[${WhatToReturn}RANGED*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[if shield equipped in secondary](exists)}
					WhatToReturn:Set[${WhatToReturn}SHIELD*]
			}
			;Adding a new line which can be read by scripts instead of cycling the descriptions. If it doesn't exist, it means there are none of the restrictions from above
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[DescRestrictions,${WhatToReturn}]

			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[Class,${Me.Ability[id,${CurrentSpellID}].Class}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[NumEffects,${Me.Ability[id,${CurrentSpellID}].NumEffects}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[BackDropIconID,${Me.Ability[id,${CurrentSpellID}].BackDropIconID}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[HealthCostPerTick,${Me.Ability[id,${CurrentSpellID}].HealthCostPerTick}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[PowerCostPerTick,${Me.Ability[id,${CurrentSpellID}].PowerCostPerTick}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[MaxAOETargets,${Me.Ability[id,${CurrentSpellID}].MaxAOETargets}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[DoesNotExpire,${Me.Ability[id,${CurrentSpellID}].DoesNotExpire}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[GroupRestricted,${Me.Ability[id,${CurrentSpellID}].GroupRestricted}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[AllowRaid,${Me.Ability[id,${CurrentSpellID}].AllowRaid}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[EffectRadius,${Me.Ability[id,${CurrentSpellID}].EffectRadius}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[TargetType,${Me.Ability[id,${CurrentSpellID}].TargetType}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[SpellBookType,${Me.Ability[id,${CurrentSpellID}].SpellBookType}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[MinRange,${Me.Ability[id,${CurrentSpellID}].MinRange}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[MaxRange,${Me.Ability[id,${CurrentSpellID}].MaxRange}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[Range,${Me.Ability[id,${CurrentSpellID}].Range}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[Tier,${Me.Ability[id,${CurrentSpellID}].Tier}]
			setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[Level,${Me.Ability[id,${CurrentSpellID}].Class[1].Level}]
			
			;setSpell.FindSetting[${CurrentSpellName}]:AddAttribute[]

		}
		elseif ${Args.Find[Settings]}
		{
			setSpell:AddSet[${CurrentSpellName}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[ID,${CurrentSpellID}]
			;setSpell.FindSet[${CurrentSpellName}]:SetAttribute[1,abc]
			;setSpell:SetAttribute[2,def]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[Description,${Me.Ability[id,${CurrentSpellID}].Description}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[Tier,${Me.Ability[id,${CurrentSpellID}].Tier}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[HealthCost,${Me.Ability[id,${CurrentSpellID}].HealthCost}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[PowerCost,${Me.Ability[id,${CurrentSpellID}].PowerCost}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[ConcentrationCost,${Me.Ability[id,${CurrentSpellID}].ConcentrationCost}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[MainIconID,${Me.Ability[id,${CurrentSpellID}].MainIconID}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[CastingTime,${Me.Ability[id,${CurrentSpellID}].CastingTime}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[RecoveryTime,${Me.Ability[id,${CurrentSpellID}].RecoveryTime}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[RecastTime,${Me.Ability[id,${CurrentSpellID}].RecastTime}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[MaxDuration,${Me.Ability[id,${CurrentSpellID}].MaxDuration}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[NumClasses,${Me.Ability[id,${CurrentSpellID}].NumClasses}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[Class,${Me.Ability[id,${CurrentSpellID}].Class}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[NumEffects,${Me.Ability[id,${CurrentSpellID}].NumEffects}]
			WhatToReturn:Set[]
			aa:Set[0]
			while ${aa:Inc}<=${Me.Ability[id,${CurrentSpellID}].NumEffects}
			{
				;Adding each Description line
				setSpell.FindSet[${CurrentSpellName}]:AddSetting[EffectDesc${aa},${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc}]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[Flanking or behind](exists)}
					WhatToReturn:Set[${WhatToReturn}FLANKING*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[you must be sneaking](exists)} || ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[you must be in stealth](exists)} || ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[you must be stealthed to use this](exists)}
					WhatToReturn:Set[${WhatToReturn}SNEAKING*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[must be behind](exists)}
					WhatToReturn:Set[${WhatToReturn}BEHIND*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[does not affect epic](exists)}
					WhatToReturn:Set[${WhatToReturn}NOEPIC*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[if weapon equipped in ranged](exists)}
					WhatToReturn:Set[${WhatToReturn}RANGED*]
				if ${Me.Ability[id,${CurrentSpellID}].Effect[${aa}].Desc.Find[if shield equipped in secondary](exists)}
					WhatToReturn:Set[${WhatToReturn}SHIELD*]
			}
			;Adding a new line which can be read by scripts instead of cycling the descriptions. If it doesn't exist, it means there are none of the restrictions from above
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[DescRestrictions,${WhatToReturn}]

			setSpell.FindSet[${CurrentSpellName}]:AddSetting[BackDropIconID,${Me.Ability[id,${CurrentSpellID}].BackDropIconID}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[HealthCostPerTick,${Me.Ability[id,${CurrentSpellID}].HealthCostPerTick}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[PowerCostPerTick,${Me.Ability[id,${CurrentSpellID}].PowerCostPerTick}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[MaxAOETargets,${Me.Ability[id,${CurrentSpellID}].MaxAOETargets}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[DoesNotExpire,${Me.Ability[id,${CurrentSpellID}].DoesNotExpire}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[GroupRestricted,${Me.Ability[id,${CurrentSpellID}].GroupRestricted}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[AllowRaid,${Me.Ability[id,${CurrentSpellID}].AllowRaid}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[EffectRadius,${Me.Ability[id,${CurrentSpellID}].EffectRadius}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[TargetType,${Me.Ability[id,${CurrentSpellID}].TargetType}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[SpellBookType,${Me.Ability[id,${CurrentSpellID}].SpellBookType}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[MinRange,${Me.Ability[id,${CurrentSpellID}].MinRange}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[MaxRange,${Me.Ability[id,${CurrentSpellID}].MaxRange}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[Range,${Me.Ability[id,${CurrentSpellID}].Range}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[Tier,${Me.Ability[id,${CurrentSpellID}].Tier}]
			setSpell.FindSet[${CurrentSpellName}]:AddSetting[Level,${Me.Ability[id,${CurrentSpellID}].Class[1].Level}]
			
			;setSpell.FindSet[${CurrentSpellName}]:AddSetting[,${Me.Ability[id,${CurrentSpellID}].ID}]
		}
		;press esc
	}
	if ${NULLsSkipped}==${Me.NumAbilities}
	{
		echo All abilities came up as NULL. Re-run script
		return
	}

	LavishSettings[SpellInformation]:Export["${ConfigFile}"]
	LavishSettings[SpellInformation]:Clear
	echo Save completed to file: ${ConfigFile}
}
