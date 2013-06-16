variable string OutputFile = ${Script.CurrentDirectory}/AbilityDump_${Me.FName}.txt
variable int i

function main()
{
	echo [${Me.Class}]
	echo "Dumping Physical"
	redirect "${OutputFile}" echo "=============PHYSICAL TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Physical]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Arcane"
	redirect -append "${OutputFile}" echo "=============ARCANE TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Arcane]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Fire"
	redirect -append "${OutputFile}" echo "=============FIRE  TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Fire]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Ice"
	redirect -append "${OutputFile}" echo "=============ICE TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Ice]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Cold"
	redirect -append "${OutputFile}" echo "=============COLD TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Cold]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Mental"
	redirect -append "${OutputFile}" echo "=============MENTAL TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Mental]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Spiritual"
	redirect -append "${OutputFile}" echo "=============SPIRITUAL TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Spiritual]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Melee"
	redirect -append "${OutputFile}" echo "=============MELEE TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Melee]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Spell"
	redirect -append "${OutputFile}" echo "=============SPELL TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Spell]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Finishers"
	redirect -append "${OutputFile}" echo "=============FINISHER TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Finish]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Totem"
	redirect -append "${OutputFile}" echo "=============TOTEMIC TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].School.Find[Totem]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Combat Art"
	redirect -append "${OutputFile}" echo "=============COMBAT ART ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].Type.Find[Combat Art]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, TargetType=${Me.Ability[${i}].TargetType}"
		}
	}

	echo "Dumping Offensive"
	redirect -append "${OutputFile}" echo "=============OFFENSIVE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].TargetType.Find[Offensive]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, Type=${Me.Ability[${i}].Type}"
		}
	}

	echo "Dumping Forms"
	redirect -append "${OutputFile}" echo "================FORMS==================="
	for (i:Set[1] ; ${i}<=${Me.Form} ; i:Inc)
	{
		redirect -append "${OutputFile}" echo "Name=[${Me.Form[${i}].Name}]"
		redirect -append "${OutputFile}" echo "--Description=[${Me.Form[${i}].Description}]"
	}

	echo "Dumping Group"
	redirect -append "${OutputFile}" echo "=============GROUP ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].TargetType.Find[Group]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, Type=${Me.Ability[${i}].Type}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping HATE"
	redirect -append "${OutputFile}" echo "=============HATE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].Description.Find[hate]} || ${Me.Ability[${i}].Description.Find[hatred]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, Type=${Me.Ability[${i}].Type}, School=${Me.Ability[${i}].School}"
		}
	}

	
	echo "Dumping All Others"
	redirect -append "${OutputFile}" echo "=============ALL OTHER TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if !${Me.Ability[${i}].School.Find[Physical]} && !${Me.Ability[${i}].School.Find[Spiritual]} && !${Me.Ability[${i}].School.Find[Arcane]} && !${Me.Ability[${i}].School.Find[Fire]} && !${Me.Ability[${i}].School.Find[Ice]} && !${Me.Ability[${i}].School.Find[Cold]} && !${Me.Ability[${i}].School.Find[Mental]} && !${Me.Ability[${i}].School.Find[Melee]} && !${Me.Ability[${i}].School.Find[Spell]} && !${Me.Ability[${i}].School.Find[Totem]} && !${Me.Ability[${i}].School.Find[Finish]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}, Type=${Me.Ability[${i}].Type} TargetType=${Me.Ability[${i}].TargetType}"
		}
	}

	echo "Dumping Ability Info"
	redirect -append "${OutputFile}" echo "=============ABILITY INFORMATION=============="
	

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		redirect -append "${OutputFile}" echo "Name=[${Me.Ability[${i}].Name}]"
		redirect -append "${OutputFile}" echo "--LevelGranted=[${Me.Ability[${i}].LevelGranted}]"
		redirect -append "${OutputFile}" echo "--School=${Me.Ability[${i}].School}"
		redirect -append "${OutputFile}" echo "--Type=[${Me.Ability[${i}].Type}]"
		redirect -append "${OutputFile}" echo "--TargetType=[${Me.Ability[${i}].TargetType}]"
		redirect -append "${OutputFile}" echo "--Range=[${Me.Ability[${i}].Range}]"
		redirect -append "${OutputFile}" echo "--CastTime=[${Me.Ability[${i}].CastTime}]"
		redirect -append "${OutputFile}" echo "--IsOffensive=[${Me.Ability[${i}].IsOffensive}]"
		redirect -append "${OutputFile}" echo "--IsChain=[${Me.Ability[${i}].IsChain}]"
		redirect -append "${OutputFile}" echo "--IsCounter=[${Me.Ability[${i}].IsCounter}]"
		redirect -append "${OutputFile}" echo "--IsRescue=[${Me.Ability[${i}].IsRescue}]"
		redirect -append "${OutputFile}" echo "--EnergyCost=[${Me.Ability[${i}].EnergyCost}]"
		redirect -append "${OutputFile}" echo "--EnduranceCost=[${Me.Ability[${i}].EnduranceCost}]"
		redirect -append "${OutputFile}" echo "--HealthCost=[${Me.Ability[${i}].HealthCost}]"
		redirect -append "${OutputFile}" echo "--Requirements=[${Me.Ability[${i}].Requirements}]"
		redirect -append "${OutputFile}" echo "--Description=[${Me.Ability[${i}].Description}]"
		redirect -append "${OutputFile}" echo " "
	}
	
	echo "Report generated... look in Script folder for AbilityDump_${Me.FName}.txt"
}






