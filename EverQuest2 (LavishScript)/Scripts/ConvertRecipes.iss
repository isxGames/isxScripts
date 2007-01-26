function main()
{
	declare tempvar int script
	declare xmlpath string script "./XML/"
	declare recipefile string script
	declare outrecipefile string script
	declare RecipeName string script
	declare RecipeID string script
	declare Process string script
	declare Level string script
	declare Knowledge string script
	declare Device string script
	declare PrimaryComponent string script
	declare BuildComp1 string script
	declare BuildComp2 string script
	declare BuildComp3 string script
	declare BuildComp4 string script
	declare FuelComponent string script
	declare Produce string script
	declare norecipe bool script

	Script:Squelch

	call Convert Alchemist
	call Convert Armorer
	call Convert Carpenter
	call Convert Jeweler
	call Convert Provisioner
	call Convert Sage
	call Convert Tailor
	call Convert Weaponsmith
	call Convert Woodworker
	call Convert Alternate
}

function Convert(string rfile)
{
	recipefile:Set[${xmlpath}NewCraft${rfile}.xml]
	norecipe:Set[FALSE]

	XMLSetting -load "${recipefile}"
	XMLSetting -load "${outrecipefile}"

	tempvar:Set[1]
	do
	{
		RecipeName:Set[${SettingXML[${recipefile}].Set[${tempvar}].Name}]

		if ${RecipeName.Equal[NULL]}
		{
			continue
		}

		call CheckData "${RecipeName}"
		RecipeName:Set[${Return}]

		RecipeID:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[RecipeID]}]
		Process:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[Process]}]
		Level:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[Level]}]
		Knowledge:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[Knowledge]}]
		Device:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[Device]}]

		Switch "${Device}"
		{
			case Loom
				Device:Set[Sewing Table & Mannequin]
				break

			case Keg
			case Stove and Keg
				Device:Set[Stove & Keg]
				break

			case Sawhorse
				Device:Set[Woodworking Table]
				break
		}

		PrimaryComponent:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[PrimaryComponent]}]

		call CheckData "${PrimaryComponent}"
		PrimaryComponent:Set[${Return}]

		BuildComp1:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[BuildComp1]}]

		call CheckData "${BuildComp1.Right[-2]}"
		BuildComp1:Set[${BuildComp1.Left[1]} ${Return}]

		BuildComp2:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[BuildComp2]}]

		if ${BuildComp2.NotEqual[NULL]}
		{
			call CheckData "${BuildComp2.Right[-2]}"
			BuildComp2:Set[${BuildComp2.Left[1]} ${Return}]
		}

		BuildComp3:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[BuildComp3]}]

		if ${BuildComp3.NotEqual[NULL]}
		{
			call CheckData "${BuildComp3.Right[-2]}"
			BuildComp3:Set[${BuildComp3.Left[1]} ${Return}]
		}

		BuildComp4:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[BuildComp4]}]

		if ${BuildComp4.NotEqual[NULL]}
		{
			call CheckData "${BuildComp4.Right[-2]}"
			BuildComp4:Set[${BuildComp4.Left[1]} ${Return}]
		}

		FuelComponent:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[FuelComponent]}]
		Produce:Set[${SettingXML[${recipefile}].Set[${tempvar}].GetString[Produce]}]

		Switch "${Knowledge}"
		{
			case Alchemy
				outrecipefile:Set[${xmlpath}xCraftAlchemist.xml]
				break

			case Heavy Armoring
				outrecipefile:Set[${xmlpath}xCraftArmorer.xml]
				break

			case Craftsmanship
				outrecipefile:Set[${xmlpath}xCraftCarpenter.xml]
				break

			case Runecraft
				outrecipefile:Set[${xmlpath}xCraftJeweler.xml]
				break

			case Culinary
				outrecipefile:Set[${xmlpath}xCraftProvisioner.xml]
				break

			case Arcana
				outrecipefile:Set[${xmlpath}xCraftSage.xml]
				break

			case Light Armoring
				outrecipefile:Set[${xmlpath}xCraftTailor.xml]
				break

			case Weaponry
				outrecipefile:Set[${xmlpath}xCraftWeaponsmith.xml]
				break

			case Woodworking
				outrecipefile:Set[${xmlpath}xCraftWoodworker.xml]
				break

			case Apothecary
			case Timbercraft
			case Geomancy
			case Weaving
				outrecipefile:Set[${xmlpath}xCraftAlternate.xml]
				break

			Default
				echo Unknown: ${Knowledge}
				norecipe:Set[TRUE]
				break
		}

		if ${noerecipe}
		{
			norecipe:Set[FALSE]
			continue
		}

		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[RecipeID,${RecipeID}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[Process,${Process}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[Level,${Level}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[Knowledge,${Knowledge}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[Device,${Device}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[PrimaryComponent,${PrimaryComponent}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[BuildComp1,${BuildComp1}]
		if ${BuildComp2.NotEqual[NULL]}
		{
			SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[BuildComp2,${BuildComp2}]
		}
		if ${BuildComp3.NotEqual[NULL]}
		{
			SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[BuildComp3,${BuildComp3}]
		}
		if ${BuildComp4.NotEqual[NULL]}
		{
			SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[BuildComp4,${BuildComp4}]
		}
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[FuelComponent,${FuelComponent}]
		SettingXML[${outrecipefile}].Set[${RecipeName}]:Set[Produce,${Produce}]

		SettingXML[${outrecipefile}]:Save
	}
	while ${tempvar:Inc}<=${SettingXML[${recipefile}].Sets}

	XMLSetting -Unload "${recipefile}"
	XMLSetting -Unload "${outrecipefile}"
}

function CheckData(string data)
{
	if ${data.Equal[Refined Sandalwood]}
	{
		return "Sandalwood Lumber"
	}

	if ${data.Equal[Refined Unodecanoid]}
	{
		return "Unodecanoid Reagent"
	}

	if ${data.Equal[Refined Indium]}
	{
		return "Indium Bar"
	}

	if ${data.Equal[Refined Cobalt]}
	{
		return "Cobalt Bar"
	}

	if ${data.Equal[Refined Beryllium]}
	{
		return "Beryllium Bar"
	}

	if ${data.Equal[Refined Nacre]}
	{
		return "Nacre Gem"
	}

	if ${data.Equal[Raw Succulent]}
	{
		return "Succulent Roots"
	}

	if ${data.Equal[Raw Sandalwood]}
	{
		return "Severed Sandalwood"
	}

	if ${data.Equal[Raw Succulent or Sandalwood]} 
	{
		return "Severed Sandalwood"
	}

	if ${data.Equal[Raw Succulent Root or Sandalwood]} 
	{
		return "Severed Sandalwood"
	}

	if ${data.Equal[Raw Succulent or Sandcloth]}
	{
		return "Severed Sandalwood"
	}

	if ${data.Equal[Raw Beryllium or Nacre]}
	{
		return "Rough Nacre"
	}

	if ${data.Equal[Raw Beryllium]}
	{
		return "Beryllium Cluster"
	}

	if ${data.Equal[Raw Nacre]}
	{
		return "Rough Nacre"
	}

	if ${data.Equal[Raw Indium]}
	{
		return "Indium Cluster"
	}

	if ${data.Equal[Generic Sandcloth Pattern]}
	{
		return "Sandcloth Pattern"
	}

	if ${data.Equal[Unodecanoid Loam]}
	{
		return "Solidified Unodecanoid Loam"
	}

	if ${data.Equal[Refined Stonehide Leather]}
	{
		return "Stretch of Stonehide Leather"
	}

	if ${data.Equal[Refined Sandcloth Thread]}
	{
		return "Sandcloth Thread"
	}

	if ${data.Equal[Duoduodecanoid reagent]}
	{
		return "Duodecanoid Reagent"
	}

	if ${data.Equal[Planed Sandalwood]}
	{
		return "Planed Sandalwood Lumber"
	}

	if ${data.Equal[Raw Sandalwood Material or Succulent]}
	{
		return "Severed Sandalwood"
	}

	if ${data.Equal[Refined Cambric Thread]}
	{
		return "Cambric Thread"
	}

	if ${data.Equal[Raw Figwart or Cambric]}
	{
		return "Saguaro Roots"
	}

	return ${data}
}

function atexit()
{
	EQ2Echo Finished processing!
}