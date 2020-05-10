
function main()
{
	while 1
	{
		ExecuteQueued
	}
	waitframe
}

function RefreshInventoryQueue()
{
	call RefreshInventory
	wait 10
	call RefreshInventory
	wait 10
	call RefreshInventory
}

function RefreshInventory()
{
	variable index:item Items
	variable iterator ItemIterator
	UIElement[FullInventoryListBox@Potions_Frame@bjxpbotsettings]:ClearItems
	call AddItemtoInvList 

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if !${ItemIterator.Value.IsContainer} 
			{
				if ${ItemIterator.Value.InInventory}
				{
					if ${ItemIterator.Value.Heirloom} || ${ItemIterator.Value.NoTrade}
					{
						if ${ItemIterator.Value.NoValue}
						{
							call AddItemtoInvList "${ItemIterator.Value.Name}"
						}	
					}	
				}
			}
		}
		while ${ItemIterator:Next(exists)}
	}
}
function AddItemtoInvList(string textline)
{
	UIElement[FullInventoryListBox@Potions_Frame@bjxpbotsettings]:AddItem[${textline}]
}

function SaveList()
{
	variable string SetName
	variable int Counter=0
	SetName:Set[${UIElement[SavePotionListTextEntry@Potions_Frame@bjxpbotsettings].Text}]
	if ${SetName.Length}
	{ 
		LavishSettings:AddSet[PotionListName]
		LavishSettings[PotionListName]:AddSet[${SetName}]
		while ${Counter:Inc}<=${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items}
		{
			LavishSettings[PotionListName].FindSet[${SetName}]:AddSetting[${Counter},${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${Counter}].Text}]
		}
		LavishSettings[PotionListName].FindSet[${SetName}]:Export[${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Potion Lists/${SetName}.xml]
		LavishSettings[PotionListName]:Remove
	}
	call UpdateListCombo
}
function UpdateListCombo()
{
	variable filelist ListFiles
	variable int Count=0
	UIElement[SavePotionListComboBox@Potions_Frame@bjxpbotsettings]:ClearItems
	ListFiles:GetFiles[${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Potion Lists/\*.xml]
	while ${Count:Inc}<=${ListFiles.Files}
	{
		UIElement[SavePotionListComboBox@Potions_Frame@bjxpbotsettings]:AddItem[${ListFiles.File[${Count}].Filename.Left[-4]}]
	}
	if ${UIElement[SavePotionListComboBox@Potions_Frame@bjxpbotsettings].Items}
	{
		UIElement[SavePotionListComboBox@Potions_Frame@bjxpbotsettings]:Sort:SelectItem[1]
	}
}
function LoadListByName(string SetName)
{
	variable int Counter=0
	variable iterator iter
	UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings]:ClearItems
	SetName:Set[${UIElement[SavePotionListComboBox@Potions_Frame@bjxpbotsettings].SelectedItem.Text}]
	if ${SetName.Length}
	{
		LavishSettings:AddSet[PotionListName]
		LavishSettings[PotionListName]:AddSet[${SetName}]
		LavishSettings[PotionListName].FindSet[${SetName}]:Import[${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Potion Lists/${SetName}.xml]
		LavishSettings[PotionListName].FindSet[${SetName}]:GetSettingIterator[iter]
		
		if ${iter:First(exists)}
		{
			do
			{
				UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings]:AddItem[${iter.Value}]
			}
			while ${iter:Next(exists)}
		}
		LavishSettings[PotionListName]:Remove
	}
}
function DeleteList()
{
	variable string SetName
	SetName:Set[${UIElement[SavePotionListComboBox@Potions_Frame@bjxpbotsettings].SelectedItem.Text}]
	if ${SetName.Length}
	{
		rm "${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Potion Lists/${SetName}.xml"
		call UpdateListCombo
	}
}

function atexit()
{

}
