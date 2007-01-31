/*****************************************************************
Inventory Management -- By Mandrake

******************************************************************/

function main(param1, param2)
{
variable string xmlfile = ./inventory-${Me.Name}.xml
variable collection:string slots
	slots:Set[Head,0]
	slots:Set[Chest,1]
	slots:Set[Shoulders,2]
	slots:Set[Forearms,3]
	slots:Set[Hands,4]
	slots:Set[Waist,5]
	slots:Set[Legs,6]
	slots:Set[Feet,7]
	slots:Set[Primary,8]
	slots:Set[Secondary,9]
	slots:Set[Ranged,10]
	slots:Set[Neck,11]
	slots:Set[Ear,12]
	slots:Set[LRing,13]
	slots:Set[RRing,14]
	slots:Set[LWrist,15]
	slots:Set[RWrist,16]
	slots:Set[Activate1,17]
	slots:Set[Activate2,18]

	switch ${param1}
	{
	case strip
		if ${slots.FirstKey(exists)}
		{
			do
			{
				Me.Equipment[${slots.CurrentKey}]:UnEquip
				wait 1
			}
			while ${slots.NextKey(exists)}
		}
	break

	case save
		if ${slots.FirstKey(exists)}
		{
			do
			{
				SettingXML[${xmlfile}].Set[${param2}]:Set[${slots.CurrentKey},"${Me.Equipment[${slots.CurrentKey}].Name}"]
				echo saving ${slots.CurrentKey} -- ${Me.Equipment[${slots.CurrentKey}].Name}
			}
			while ${slots.NextKey(exists)}
			SettingXML[${xmlfile}]:Save
			SettingXML[${xmlfile}]:Unload
		}
	break

	case load
	if ${slots.FirstKey(exists)}
	{
		do
		{
			if !${Me.Equipment[${slots.CurrentKey}].Name.Equal[${SettingXML[${xmlfile}].Set[${param2}].GetString[${slots.CurrentKey}]}]}
			{
				echo Replace ${Me.Equipment[${slots.CurrentKey}]} with ${SettingXML[${xmlfile}].Set[${param2}].GetString[${slots.CurrentKey}]}
				Me.Inventory["${SettingXML[${xmlfile}].Set[${param2}].GetString[${slots.CurrentKey}]}"]:Equip
				wait 1
			}
		}
		while ${slots.NextKey(exists)}
	}
		
	break
	case max
	declare Counter int
	declare counter2 int
	declare best string
	Me:CreateCustomInventoryArray[nonbankonly]
	if ${slots.FirstKey(exists)}
	{
		do
		{
			echo Checking ${slots.CurrentKey}
			Counter:Set[1]
			do
			{
				counter2:Set[0]
				do
				{
					
					if ${Me.CustomInventory[${Counter}].EquipSlot[${counter2}].Equal[${slots.CurrentKey}]}&&${Me.CustomInventory[${Counter}].Condition}>=1
					{
					if ${Me.CustomInventory[${Counter}].Attuneable}&&!${Me.CustomInventory[${Counter}].Attuned}
						break
						echo --${Me.CustomInventory[${Counter}].Name} is Equipable, Attunable =${Me.CustomInventory[${Counter}].Attuneable}, Attuned=${Me.CustomInventory[${Counter}].Attuned}
						switch ${param2}
						{
						case divine
							if ${Me.CustomInventory[${Counter}].vsDivine} > ${Me.Equipment[${slots.CurrentKey}].vsDivine}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case int
							if ${Me.CustomInventory[${Counter}].Int} > ${Me.Equipment[${slots.CurrentKey}].Int}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case hp
							if ${Me.CustomInventory[${Counter}].Health} > ${Me.Equipment[${slots.CurrentKey}].Health}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case power
							if ${Me.CustomInventory[${Counter}].Power} > ${Me.Equipment[${slots.CurrentKey}].Power}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case magic
							if ${Me.CustomInventory[${Counter}].vsMagic} > ${Me.Equipment[${slots.CurrentKey}].vsMagic}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case sta
							if ${Me.CustomInventory[${Counter}].Sta} > ${Me.Equipment[${slots.CurrentKey}].Sta}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case agi
							if ${Me.CustomInventory[${Counter}].Agi} > ${Me.Equipment[${slots.CurrentKey}].Agi}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case str
							if ${Me.CustomInventory[${Counter}].Str} > ${Me.Equipment[${slots.CurrentKey}].Str}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case mental
							if ${Me.CustomInventory[${Counter}].vsMental} > ${Me.Equipment[${slots.CurrentKey}].vsMental}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case poison
							if ${Me.CustomInventory[${Counter}].vsPoison} > ${Me.Equipment[${slots.CurrentKey}].vsPoison}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break

						case disease
							if ${Me.CustomInventory[${Counter}].vsDisease} > ${Me.Equipment[${slots.CurrentKey}].vsDisease}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case heat
							if ${Me.CustomInventory[${Counter}].vsHeat} > ${Me.Equipment[${slots.CurrentKey}].vsHeat}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case cold
							if ${Me.CustomInventory[${Counter}].vsCold} > ${Me.Equipment[${slots.CurrentKey}].vsCold}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case wis
							if ${Me.CustomInventory[${Counter}].Wisdom} > ${Me.Equipment[${slots.CurrentKey}].Wisdom}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						case mit
							if ${Me.CustomInventory[${Counter}].Mitigation} > ${Me.Equipment[${slots.CurrentKey}].Mitigation}
							{
								Me.Equipment[${slots.CurrentKey}]:UnEquip
								wait 1
								Me.Inventory[${Me.CustomInventory[${Counter}].Name}]:Equip
							}
						break
						Default
						break
						}
					}
				}
				while ${counter2:Inc} <= ${Me.CustomInventory[${Counter}].NumEquipSlots}
				
			}
			while ${Counter:Inc}<=${Me.CustomInventoryArraySize}
		}
		while ${slots.NextKey(exists)}
	}
		
	break
	Default
		echo Nothing to do!
		echo Useage: 
		echo run equipment [load/save] [profilename]
		echo run equipment max [heat/cold/mit/wis/disease/poison/mental/agi/str/sta/int/magic/divine]
	break
	}
echo Done!

}