
function main()
{
	while 1
	{
		ExecuteQueued
		Me:CreateCustomInventoryArray[nonbankonly]
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
	variable int ArrayPosition=0
	UIElement[FullInventoryListBox@Potions_Frame@bjxpbotsettings]:ClearItems
	call AddItemtoInvList 

	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize}
	{
		if !${Me.CustomInventory[${ArrayPosition}].IsContainer} 
		{
			if ${Me.CustomInventory[${ArrayPosition}].InInventory}
			{
				if ${Me.CustomInventory[${ArrayPosition}].Heirloom} || ${Me.CustomInventory[${ArrayPosition}].NoTrade}
				{
					if ${Me.CustomInventory[${ArrayPosition}].NoValue}
					{
						call AddItemtoInvList "${Me.CustomInventory[${ArrayPosition}].Name}"
					}	
				}	
		  	}
		}
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
