variable string OutputFile = ${Script.CurrentDirectory}/AbilityType_${Me.FName}.txt
variable int i

function main()
{
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
		if ${Me.Ability[${i}].School.Find[Ice]} || ${Me.Ability[${i}].School.Find[Cold]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Mental"
	redirect -append "${OutputFile}" echo "=============Mental TYPE ABILITIES================"
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

	echo "Dumping All Others"
	redirect -append "${OutputFile}" echo "=============ALL OTHER TYPE ABILITIES================"
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if !${Me.Ability[${i}].School.Find[Physical]} && !${Me.Ability[${i}].School.Find[Spiritual]} && !${Me.Ability[${i}].School.Find[Arcane]} && !${Me.Ability[${i}].School.Find[Fire]} && !${Me.Ability[${i}].School.Find[Ice]} && !${Me.Ability[${i}].School.Find[Cold]} && !${Me.Ability[${i}].School.Find[Mental]}
		{
			redirect -append "${OutputFile}" echo "Name=${Me.Ability[${i}].Name}, Range=${Me.Ability[${i}].Range}, School=${Me.Ability[${i}].School}"
		}
	}

	echo "Dumping Equipment"
	redirect -append "${OutputFile}" echo "=============EQUIPMENT STATUS================"
	for (i:Set[1] ; ${Me.Inventory[${i}].Name(exists)} ; i:Inc)
	{
		redirect -append "${OutputFile}" echo "Item Name=${Me.Inventory[${i}].Name}"

		redirect -append "${OutputFile}" echo "---Item Type=${Me.Inventory[${i}].Type}"
		redirect -append "${OutputFile}" echo "---Item Quantity=${Me.Inventory[${i}].Quantity}"
		redirect -append "${OutputFile}" echo "---Durability=${Me.Inventory[${i}].Durability}"
		redirect -append "${OutputFile}" echo "---Slot Equiped On=${Me.Inventory[${i}].CurrentEquipSlot}"
		redirect -append "${OutputFile}" echo "---Description=${Me.Inventory[${i}].Description}"
		redirect -append "${OutputFile}" echo "---MiscDescription=${Me.Inventory[${i}].MiscDescription}"
		redirect -append "${OutputFile}" echo "---InContainer=${Me.Inventory[${Me.Inventory[${i}].Name}].InContainer.Name}"
		redirect -append "${OutputFile}" echo "---Keyword1=${Me.Inventory[${i}].Keyword1}"
		redirect -append "${OutputFile}" echo "---Keyword2=${Me.Inventory[${i}].Keyword2}"
	}

	echo "Report generated... look in Script folder for AbilityType_${Me.FName}.txt"
}






