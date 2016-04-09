/******************************************************************
**                       Gear Equip/UnEquip                      **
**                          By: Hendrix                          **
**                           Version 1                           **
******************************************************************/

variable int tempcount
variable string xmlpath="./XML/"
variable string bodypart[20]
variable string gearset
variable string gearcheck
variable collection:string equiplast

function main()
{
	ui -reload "${LavishScript.HomeDirectory}/Interface/Skins/EQ2/EQ2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/UI/gearUIstart.xml"
	bodypart[1]:Set[Head]
	bodypart[2]:Set[Cloak]
	bodypart[3]:Set[Chest]
	bodypart[4]:Set[Shoulders]
	bodypart[5]:Set[Forearms]
	bodypart[6]:Set[Hands]
	bodypart[7]:Set[Waist]
	bodypart[8]:Set[Legs]
	bodypart[9]:Set[Feet]
	bodypart[10]:Set[Neck]
	bodypart[11]:Set[Ear]
	bodypart[12]:Set[Ear2]
	bodypart[13]:Set[LRing]
	bodypart[14]:Set[RRing]
	bodypart[15]:Set[LWrist]
	bodypart[16]:Set[RWrist]
	bodypart[17]:Set[Primary]
	bodypart[18]:Set[Secondary]
	bodypart[19]:Set[Ranged]
;--------------------------------------------------------
	if ${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[Primary].GetString[${bodypart[1]},helm].Equal[helm]}
	   call createlist
	call populate start
	do
	{
		gearcheck:Set[${UIElement[gear list@gearmain].SelectedItem.Text}]

		if ${QueuedCommands}
		   ExecuteQueued

		if ${gearcheck.Equal[${gearset}]}
		   UIElement[equip@gearmain]:SetText[Unequip Gear]
		else
		   UIElement[equip@gearmain]:SetText[Equip Gear]
		waitframe
	}
	while 1
}

function creategear(string tempvar1)
{
	tempcount:Set[1]
	If !${tempvar1.Equal[NULL]}
	{
		Do
		{
			SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${tempvar1}]:Set[${bodypart[${tempcount}]},${Me.Equipment[${bodypart[${tempcount}]}]}]
			waitframe
		}
		while ${tempcount:Inc} < 20
		SettingXML[${xmlpath}gear.xml]:Save
		call populate
	}
}

function gearequip()
{
	tempcount:Set[1]
	Do
	{
		if !${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${gearset}].GetString[${bodypart[${tempcount}]}].Equal[NULL]}
		{
			Me.Inventory[${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${gearset}].GetString[${bodypart[${tempcount}]}]}]:Equip
			wait 20 ${Me.Equipment[${bodypart[${tempcount}]}](exists)}
			if ${Me.Equipment[${bodypart[${tempcount}]}].Name.NotEqual[${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${gearset}].GetString[${bodypart[${tempcount}]}]}]}
			{
				equiplast:Set["${bodypart[${tempcount}]}","${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${gearset}].GetString[${bodypart[${tempcount}]}]}"]
				Me.Equipment[${bodypart[${tempcount}]}]:UnEquip
			}
		
			if "${equiplast.FirstKey(exists)}"
			{
				Do
				{
					Me.Inventory[${equiplast.CurrentValue}]:Equip
					wait 5
				}
				while "${equiplast.NextKey(exists)}"
			}
		}
	}
	while ${tempcount:Inc} < 20
}

function gearunequip()
{
	tempcount:Set[1]
	Do
	{
		Me.Equipment[${bodypart[${tempcount}]}]:UnEquip
		wait 20 !${Me.Equipment[${bodypart[${tempcount}]}](exists)}
	}
	while ${tempcount:Inc} < 20
}

function populate(string tempvar1)
{
	if ${tempvar1.Equal[start]}
	{
		UIElement[gearlist@gearstart]:ClearItems
		tempcount:Set[1]
		do
		{
			UIElement[gearlist@gearstart]:AddItem[${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${tempcount}]}]
		}
		while ${tempcount:Inc} <= ${SettingXML[${xmlpath}gear.xml].Set[${Me}].Sets}

		UIElement[gearlist@gearstart]:AddItem[Naked]
	}
	else
	{
	UIElement[gear list@gearmain]:ClearItems
	tempcount:Set[1]
	do
	{
		UIElement[gear list@gearmain]:AddItem[${SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${tempcount}]}]
	}
	while ${tempcount:Inc} <= ${SettingXML[${xmlpath}gear.xml].Set[${Me}].Sets}
	}
}

function gearchange()
{
	gearcheck:Set[${UIElement[gear list@gearmain].SelectedItem.Text}]
	if ${gearcheck.Equal[${gearset}]}
	{
		call gearunequip
		gearset:Set[Naked]
	}
	elseif ${gearset.Equal[Naked]}
	{
		gearset:Set[${UIElement[gear list@gearmain].SelectedItem.Text}]
		call gearequip
	}
	else
	{
		call gearunequip
		gearset:Set[${UIElement[gear list@gearmain].SelectedItem.Text}]
		call gearequip
	}
}

function createlist()
{
	InputBox "Please enter the name of the new gear list."
	call creategear "${UserInput}"
}

function updategear()
{
	call creategear "${UIElement[gear list@gearmain].SelectedItem.Text}"
}

function listdestroy()
{
	eq2echo destroying list
	gearcheck:Set[${UIElement[gear list@gearmain].SelectedItem.Text}]
	SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${gearcheck}]:Clear
	SettingXML[${xmlpath}gear.xml]:Save
	SettingXML[${xmlpath}gear.xml].Set[${Me}].Set[${gearcheck}]:Unload
	call populate
}

function startup()
{
	gearset:Set[${UIElement[gearlist@gearstart].SelectedItem.Text}]
	ui -reload -skin eq2 "${LavishScript.CurrentDirectory}/Scripts/UI/gearUI.xml"
	call populate
}

function atexit()
{
	ui -unload "${LavishScript.CurrentDirectory}/Scripts/UI/gearUI.xml"
	ui -unload "${LavishScript.CurrentDirectory}/Scripts/UI/gearUIstart.xml"
}