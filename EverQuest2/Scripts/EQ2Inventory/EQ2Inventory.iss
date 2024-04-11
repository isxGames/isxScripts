;EQ2Broker v3 08.26.2011
;By Syliac
#include EQ2Common/SettingManager.iss
#include EQ2Common/Debug.iss
;=================================
;Consignment Box Variables
;=================================
variable int TSBox
variable int SBBox
variable int CLBox
variable int CHBox
variable int RHBox
variable int LLBox
variable int FertBox
variable int StatBox
variable int CustBox
variable int UseBox
;=================================
;Item Variables
;=================================
variable string ClassName
variable string TradeClass
variable string BookTradeClass
variable string ItemType
variable string NameFilter1
variable string NameFilter2
variable string NameFilter3
;=================================
;Run Variables
;=================================
variable bool RunBroker=TRUE
variable bool RunJunk=TRUE
variable bool RunDestroy=TRUE
variable bool SlotFull=FALSE
variable bool SkipItem=FALSE
variable bool DepotItemsPlaced=FALSE
variable bool TradeFinished=FALSE
;=================================
;Setting references
;=================================
variable settingsetref Junk
variable settingsetref Destroy
variable settingsetref Custom
variable settingsetref Trade
variable settingsetref DeleteMeats
variable settingsetref Fertilizer
variable settingsetref Harvests
variable settingsetref StatusItems
variable settingsetref UserSettings
variable settingsetref Root
variable _Settings Settings
;=================================
objectdef _EQ2InvInterface
{
	member:string GetSetting(string Setting)
	{
		return ${Settings.GetSetting[${Setting}]}
	}
	method SetSetting(string Setting, string Value)
	{
		Settings:SetSetting[${Setting},${Value}]
		Settings:SaveSettings
	}
}
function main()
{
	;Debug:Enable
	declare EQ2InvInterface _EQ2InvInterface global
	call InitializeSettings

	Event[EQ2_onIncomingText]:AttachAtom[GetText]

	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/EQ2-Green/EQ2-Green.xml"
	ui -reload -skin EQ2-Green "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
	wait 5

	while 1
	{
		while ${QueuedCommands}
			ExecuteQueued

		waitframe
	}
}

function InitializeSettings()
{
	variable settingsetref genset
	LavishSettings:AddSet[EQ2Inventory]
	Root:Set[${LavishSettings.FindSet[EQ2Inventory]}]

	Root:AddSet[Junk]
	Root:AddSet[Destroy]
	Root:AddSet[Custom]
	Root:AddSet[Trade]
	Root:AddSet[DeleteMeats]
	Root:AddSet[Fertilizer]
	Root:AddSet[Harvests]
	Root:AddSet[StatusItems]
	Root:AddSet[UserSettings]

	Junk:Set[${Root.FindSet[Junk]}]
	Destroy:Set[${Root.FindSet[Destroy]}]
	Custom:Set[${Root.FindSet[Custom]}]
	Trade:Set[${Root.FindSet[Trade]}]
	DeleteMeats:Set[${Root.FindSet[DeleteMeats]}]
	Fertilizer:Set[${Root.FindSet[Fertilizer]}]
	Harvests:Set[${Root.FindSet[Harvests]}]
	StatusItems:Set[${Root.FindSet[StatusItems]}]
	UserSettings:Set[${Root.FindSet[UserSettings]}]

	; Load the static settings -- these will never be modified inside the script
	; so never need to be exported.
	DeleteMeats:Import[./ScriptConfig/DeleteMeats.xml]
	Fertilizer:Import[./ScriptConfig/Fertilizer.xml]
	Harvests:Import[./ScriptConfig/Harvests.xml]
	StatusItems:Import[./ScriptConfig/StatusItems.xml]
	Custom:Import[./ScriptConfig/CustomItems.xml]

	UserSettings:AddSet[General Settings]
	Trade:AddSet[Trade]
	genset:Set[${UserSettings.FindSet[General Settings]}]

	; These are the setting sets we want to save. The script can modify these.
	Settings:SetFilename[${Junk},./ScriptConfig/Junk.xml]
	Settings:SetFilename[${Destroy},./ScriptConfig/Destroy.xml]
	Settings:SetFilename[${Custom},./ScriptConfig/CustomItems.xml]
	Settings:SetFilename[${UserSettings},./CharConfig/${Me.Name}.xml]
	;***********************************************************************
	;Edit this if you dont want individual Trade Files
	Settings:SetFilename[${Trade},./ScriptConfig/${Me.Name}_TradeItems.xml]
	;***********************************************************************
	
	; this will load all the above settings.
	Settings:LoadSettings


	; **Creating Settings**
	; This sets up defaults for all the user settings
	Settings:AddSetting[RunMyPrices,${genset},RunMyPrices,1]
	Settings:AddSetting[ScanRares,${genset},ScanRares,1]
	Settings:AddSetting[ScanHarvests,${genset},ScanHarvests,1]
	Settings:AddSetting[ScanCollections,${genset},ScanCollections,1]
	Settings:AddSetting[ScanTradeskills,${genset},ScanTradeskills,1]
	Settings:AddSetting[ScanSpellBooks,${genset},ScanSpellBooks,1]
	Settings:AddSetting[ScanLoreAndLegend,${genset},ScanLoreAndLegend,1]
	Settings:AddSetting[ScanStatus,${genset},ScanStatus,1]
	Settings:AddSetting[ScanFertilizer,${genset},ScanFertilizer,1]
	Settings:AddSetting[ScanCustom,${genset},ScanCustom,1]
	Settings:AddSetting[Alchemist,${genset},Alchemist,1]
	Settings:AddSetting[Armorer,${genset},Armorer,1]
	Settings:AddSetting[Carpenter,${genset},Carpenter,1]
	Settings:AddSetting[Jeweler,${genset},Jeweler,1]
	Settings:AddSetting[Sage,${genset},Sage,1]
	Settings:AddSetting[Tailor,${genset},Tailor,1]
	Settings:AddSetting[Weaponsmith,${genset},Weaponsmith,1]
	Settings:AddSetting[Woodworker,${genset},Woodworker,1]
	Settings:AddSetting[Craftsman,${genset},Craftsman,1]
	Settings:AddSetting[Outfitter,${genset},Outfitter,1]
	Settings:AddSetting[Scholar,${genset},Scholar,1]
	Settings:AddSetting[Assassin,${genset},Assassin,1]
	Settings:AddSetting[Berserker,${genset},Berserker,1]
	Settings:AddSetting[Brigand,${genset},Brigand,1]
	Settings:AddSetting[Bruiser,${genset},Bruiser,1]
	Settings:AddSetting[Coercer,${genset},Coercer,1]
	Settings:AddSetting[Conjuror,${genset},Conjuror,1]
	Settings:AddSetting[Defiler,${genset},Defiler,1]
	Settings:AddSetting[Dirge,${genset},Dirge,1]
	Settings:AddSetting[Fury,${genset},Fury,1]
	Settings:AddSetting[Guardian,${genset},Guardian,1]
	Settings:AddSetting[Illusionist,${genset},Illusionist,1]
	Settings:AddSetting[Inquisitor,${genset},Inquisitor,1]
	Settings:AddSetting[Monk,${genset},Monk,1]
	Settings:AddSetting[Mystic,${genset},Mystic,1]
	Settings:AddSetting[Necromancer,${genset},Necromancer,1]
	Settings:AddSetting[Paladin,${genset},Paladin,1]
	Settings:AddSetting[Ranger,${genset},Ranger,1]
	Settings:AddSetting[Shadowknight,${genset},Shadowknight,1]
	Settings:AddSetting[Swashbuckler,${genset},Swashbuckler,1]
	Settings:AddSetting[Templar,${genset},Templar,1]
	Settings:AddSetting[Troubador,${genset},Troubador,1]
	Settings:AddSetting[Warden,${genset},Warden,1]
	Settings:AddSetting[Warlock,${genset},Warlock,1]
	Settings:AddSetting[Wizard,${genset},Wizard,1]
	Settings:AddSetting[AddCollections,${genset},AddCollections,1]
	Settings:AddSetting[LoreAndLegend,${genset},LoreAndLegend,1]
	Settings:AddSetting[AddCustomItems,${genset},AddCustomItems,1]
	Settings:AddSetting[CustomItemsBox,${genset},CustomItemsBox,1]
	Settings:AddSetting[CHarvestBox,${genset},CHarvestBox,1]
	Settings:AddSetting[DeleteMeat,${genset},DeleteMeat,1]
	Settings:AddSetting[CHarvestT1,${genset},CHarvestT1,1]
	Settings:AddSetting[CHarvestT2,${genset},CHarvestT2,1]
	Settings:AddSetting[CHarvestT3,${genset},CHarvestT3,1]
	Settings:AddSetting[CHarvestT4,${genset},CHarvestT4,1]
	Settings:AddSetting[CHarvestT5,${genset},CHarvestT5,1]
	Settings:AddSetting[CHarvestT6,${genset},CHarvestT6,1]
	Settings:AddSetting[CHarvestT7,${genset},CHarvestT7,1]
	Settings:AddSetting[CHarvestT8,${genset},CHarvestT8,1]
	Settings:AddSetting[CHarvestT9,${genset},CHarvestT9,1]
	Settings:AddSetting[CustomItemsBox,${genset},CustomItemsBox,1]
	Settings:AddSetting[RHarvestBox,${genset},RHarvestBox,1]
	Settings:AddSetting[RHarvestT1,${genset},RHarvestT1,1]
	Settings:AddSetting[RHarvestT2,${genset},RHarvestT2,1]
	Settings:AddSetting[RHarvestT3,${genset},RHarvestT3,1]
	Settings:AddSetting[RHarvestT4,${genset},RHarvestT4,1]
	Settings:AddSetting[RHarvestT5,${genset},RHarvestT5,1]
	Settings:AddSetting[RHarvestT6,${genset},RHarvestT6,1]
	Settings:AddSetting[RHarvestT7,${genset},RHarvestT7,1]
	Settings:AddSetting[RHarvestT8,${genset},RHarvestT8,1]
	Settings:AddSetting[RHarvestT9,${genset},RHarvestT9,1]
	Settings:AddSetting[StatusItemBox,${genset},StatusItemBox,1]
	Settings:AddSetting[StatusItemT1,${genset},StatusItemT1,1]
	Settings:AddSetting[StatusItemT2,${genset},StatusItemT2,1]
	Settings:AddSetting[StatusItemT3,${genset},StatusItemT3,1]
	Settings:AddSetting[StatusItemT4,${genset},StatusItemT4,1]
	Settings:AddSetting[StatusItemT5,${genset},StatusItemT5,1]
	Settings:AddSetting[StatusItemT6,${genset},StatusItemT6,1]
	Settings:AddSetting[StatusItemT7,${genset},StatusItemT7,1]
	Settings:AddSetting[StatusItemT8,${genset},StatusItemT8,1]
	Settings:AddSetting[FertilizerItemBox,${genset},FertilizerItemBox,1]
	Settings:AddSetting[FertT1,${genset},FertT1,1]
	Settings:AddSetting[FertT2,${genset},FertT2,1]
	Settings:AddSetting[FertT3,${genset},FertT3,1]
	Settings:AddSetting[FertT4,${genset},FertT4,1]
	Settings:AddSetting[FertT5,${genset},FertT5,1]
	Settings:AddSetting[FertT7,${genset},FertT7,1]
	Settings:AddSetting[CraftBoxNumber,${genset},CraftBoxNumber,1]
	Settings:AddSetting[ClassSpellBox,${genset},ClassSpellBox,1]
	Settings:AddSetting[CollectionsBox,${genset},CollectionsBox,1]
	Settings:AddSetting[CHarvestBox,${genset},CHarvestBox,1]
	Settings:AddSetting[RHarvestBox,${genset},RHarvestBox,1]
	Settings:AddSetting[LoreAndLegendBox,${genset},LoreAndLegendBox,1]
	Settings:AddSetting[FertilizerItemBox,${genset},FertilizerItemBox,1]
	Settings:AddSetting[StatusItemBox,${genset},StatusItemBox,1]
	Settings:AddSetting[CustomItemsBox,${genset},CustomItemsBox,1]
	Settings:AddSetting[StatusMerchant,${genset},StatusMerchant,0]
	Settings:AddSetting[SellTreasured,${genset},SellTreasured,0]
	Settings:AddSetting[SellAdeptI,${genset},SellAdeptI,0]
	Settings:AddSetting[SellHandCrafted,${genset},SellHandCrafted,0]
	Settings:AddSetting[SellUncommon,${genset},SellUncommon,0]
	Settings:AddSetting[Examine,${genset},Examine,0]
	Settings:AddSetting[Trade,${genset},Trade,1]
	; Settings:AddSetting[,${genset},,0]

	; **Saving Settings**
	; no sense in saving all the lists during initialization
	Settings:SaveSettings[${UserSettings}]
}

function PlaceItems()
{
	TSBox:Set[${Settings.GetSetting[CraftBoxNumber]}]
	SBBox:Set[${Settings.GetSetting[ClassSpellBox]}]
	CLBox:Set[${Settings.GetSetting[CollectionsBox]}]
	CHBox:Set[${Settings.GetSetting[CHarvestBox]}]
	RHBox:Set[${Settings.GetSetting[RHarvestBox]}]
	LLBox:Set[${Settings.GetSetting[LoreAndLegendBox]}]
	FertBox:Set[${Settings.GetSetting[FertilizerItemBox]}]
	StatBox:Set[${Settings.GetSetting[StatusItemBox]}]
	CustBox:Set[${Settings.GetSetting[CustomItemsBox]}]
	RunBroker:Set[TRUE]
	wait 5
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory]:ClearItems
	call AddLog "**Starting EQ2Broker v3 By Syliac**" FF00FF00

	if ${Actor[guild,Guild World Market Broker](exists)}
	{
		Actor[guild,Guild World Market Broker]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}
	else
	{
		Actor[guild, Broker]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags

	call CheckFocus

	if ${UIElement[ScanRares@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceRare

	if ${UIElement[ScanHarvests@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceHarvest

	if ${UIElement[ScanCollections@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceCollection

	;if ${UIElement[ScanCollections@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
	;	call PlaceCollection

	if ${UIElement[ScanTradeskills@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceTradeskillBooks

	if ${UIElement[ScanSpellBooks@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceSpellBooks

	if ${UIElement[ScanLoreAndLegend@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceLoreAndLegend

	if ${UIElement[ScanStatus@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceStatusItems

	if ${UIElement[ScanFertilizer@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceFertilizer

	if ${UIElement[ScanCustom@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker}
		call PlaceCustom

	if ${RunBroker}
	{
		call ShutDown
	}
	else
	{
		call AddLog "**EQ2Broker Canceled!**" FF00FF00
	}
}

function PlaceRare()
{
	call AddLog "**Checking Rares List**" FFFF00FF
	variable int i

	for (i:Set[1];${i}<=9;i:Inc)
	{
		call CheckFocus

		if ${UIElement[EQ2Inventory].FindUsableChild[RHarvestT${i},checkbox].Checked}
		{
			call PlaceItemsFromSet ${Harvests.FindSet[SRHarvestT${i}]} ${RHBox}
		}
	}
}
function PlaceItemsFromSet(settingsetref SSR, int Container)
{
	variable iterator iter
	SSR:GetSettingIterator[iter]
	if (${iter:First(exists)}) && ${RunBroker}
	{
		do
		{
			if ${Me.Inventory[ExactName,${iter.Key}].Quantity} > 0
			{
				call AddLog "Adding ${Me.Inventory[${iter.Key}].Quantity} ${iter.Key} to Broker" FF11CCFF
				Me.Inventory[ExactName,${iter.Key}]:AddToConsignment[${Me.Inventory[ExactName,${iter.Key}].Quantity},${Container},${BrokerWindow.VendingContainer[${Container}].Consignment[${iter.Key}].SerialNumber}]
				wait ${Math.Rand[30]:Inc[20]}
			}
			call CheckFocus
		}
		while (${iter:Next(exists)}) && ${RunBroker}
	}
}



function PlaceHarvest()
{
	call CheckFocus
 	call AddLog "**Checking Harvests List**" FFFF00FF

	if ${UIElement[DeleteMeat@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
		call DeleteMeat

	variable int i

	for (i:Set[1];${i}<=9;i:Inc)
	{
		call CheckFocus
		if ${UIElement[EQ2Inventory].FindUsableChild[CHarvestT${i},checkbox].Checked}
		{
			call PlaceItemsFromSet ${Harvests.FindSet[CHarvestT${i}]} ${CHBox}
		}
	}
}


function PlaceCollection()
{
	variable index:item Items
	variable iterator ItemIterator

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${UIElement[Collections@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked} && ${ItemIterator.Value.IsCollectible} && ${ItemIterator.Value.AlreadyCollected}
			{
				do
				{
					call AddLog "Adding ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name} to Broker" FF11CCFF
					ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${CLBox},${BrokerWindow.VendingContainer[${CLBox}].Consignment[${ItemIterator.Value.Name}].SerialNumber}]
					wait ${Math.Rand[30]:Inc[20]}
				}
				while ${ItemIterator.Value.Name(exists)} && ${ItemIterator.Value.Name.Length}>4
			}
		}
		while ${ItemIterator:Next(exists)}
	}

	wait 5
	call AddLog "**Checking Previously Collected Collections**"	FFFF00FF
}

function PlaceTradeskillBooks()
{
	ItemType:Set[Item]
	NameFilter1:Set[Advanced]
	NameFilter2:Set[Enigma]
	NameFilter3:Set[Ancient]
	UseBox:Set[${TSBox}]
		call AddLog "**Checking Tradeskill Books**"	FFFF00FF

		if ${UIElement[Alchemist@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Alchemist]
				call PlaceBooks
			}
		if ${UIElement[Armorer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Armorer]
				call PlaceBooks
			}
		if ${UIElement[Carpenter@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Carpenter]
				call PlaceBooks
			}
		if ${UIElement[Jeweler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Jeweler]
				call PlaceBooks
			}
		if ${UIElement[Sage@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Sage]
				call PlaceBooks
			}
		if ${UIElement[Tailor@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Tailor]
				call PlaceBooks
			}
		if ${UIElement[Weaponsmith@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Weaponsmith]
				call PlaceBooks
			}
		if ${UIElement[Woodworker@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Woodworker]
				call PlaceBooks
			}
		if ${UIElement[Craftsman@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Craftsman]
				call PlaceBooks
			}
		if ${UIElement[Outfitter@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Outfitter]
				call PlaceBooks
			}
		if ${UIElement[Scholar@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Scholar]
				call PlaceBooks
			}
}

function PlaceSpellBooks()
{
	ItemType:Set[Item]
	NameFilter1:Set[(Adept)]
	NameFilter2:Set[(Master)]
	NameFilter3:Set[(Expert)]
	UseBox:Set[${SBBox}]
		call AddLog "**Checking Spell Books**" FFFF00FF

		if ${UIElement[Assassin@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Assassin]
				call PlaceBooks
			}
		if ${UIElement[Berserker@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Berserker]
				call PlaceBooks
			}
		if ${UIElement[Brigand@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Brigand]
				call PlaceBooks
			}
		if ${UIElement[Bruiser@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Bruiser]
				call PlaceBooks
			}
		if ${UIElement[Coercer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Coercer]
				call PlaceBooks
			}
		if ${UIElement[Conjuror@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Conjuror]
				call PlaceBooks
			}
		if ${UIElement[Defiler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Defiler]
				call PlaceBooks
			}
		if ${UIElement[Dirge@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Dirge]
				call PlaceBooks
			}
		if ${UIElement[Fury@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Fury]
				call PlaceBooks
			}
		if ${UIElement[Guardian@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Guardian]
				call PlaceBooks
			}
		if ${UIElement[Illusionist@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Illusionist]
				call PlaceBooks
			}
		if ${UIElement[Inquisitor@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Inquisitor]
				call PlaceBooks
			}
		if ${UIElement[Monk@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Monk]
				call PlaceBooks
			}
		if ${UIElement[Mystic@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Mystic]
				call PlaceBooks
			}
		if ${UIElement[Necromancer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Necromancer]
				call PlaceBooks
			}
		if ${UIElement[Paladin@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Paladin]
				call PlaceBooks
			}
		if ${UIElement[Ranger@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Ranger]
				call PlaceBooks
			}
		if ${UIElement[Shadowknight@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Shadowknight]
				call PlaceBooks
			}
		if ${UIElement[Swashbuckler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Swashbuckler]
				call PlaceBooks
			}
		if ${UIElement[Templar@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Templar]
				call PlaceBooks
			}
		if ${UIElement[Troubador@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Troubador]
				call PlaceBooks
			}
		if ${UIElement[Warden@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Warden]
				call PlaceBooks
			}
		if ${UIElement[Warlock@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Warlock]
				call PlaceBooks
			}
		if ${UIElement[Wizard@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Wizard]
				call PlaceBooks
			}
}

function PlaceBooks()
{
	variable index:item Items
	variable iterator ItemIterator

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.Type.Equal[${ItemType}]}
				if ${ItemIterator.Value.Class[1].Name.Equal[${ClassName}]}
					if ${ItemIterator.Value.Name.Find[${NameFilter1}]} || ${ItemIterator.Value.Name.Find[${NameFilter2}]} || ${ItemIterator.Value.Name.Find[${NameFilter3}]}
					{
						call AddLog "Adding ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name} to broker" FF11CCFF
						ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${UseBox},${BrokerWindow.VendingContainer[${UseBox}].Consignment[${ItemIterator.Value.Name}].SerialNumber}]
						wait ${Math.Rand[30]:Inc[20]}
					}
		}
		while ${ItemIterator:Next(exists)} && ${RunBroker}
	}

	call CheckFocus
	wait 5
}

function PlaceStatusItems()
{
	call CheckFocus
	call AddLog "**Checking Status Items List**" FFFF00FF

	variable int i

	for (i:Set[1];${i}<=8;i:Inc)
	{
		call CheckFocus

		if ${UIElement[EQ2Inventory].FindUsableChild[StatusItemT${i},checkbox].Checked}
		{
			call PlaceItemsFromSet ${StatusItems.FindSet[StatusT${i}]} ${StatBox}
		}
	}
}

function PlaceFertilizer()
{
	call CheckFocus
	call AddLog "**Checking Fertilizers List**" FFFF00FF

	variable int i

	for (i:Set[1];${i}<=7;i:Inc)
	{
		call CheckFocus

		if ${UIElement[EQ2Inventory].FindUsableChild[FertT${i},checkbox].Checked}
		{
			call PlaceItemsFromSet ${Fertilizer.FindSet[FertT${i}]} ${FertBox}
		}
	}
}

function PlaceLoreAndLegend()
{
	variable index:item Items
	variable iterator ItemIterator

	NameFilter1:Set[could be studied to learn]
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	wait 5
	call CheckFocus
	call AddLog "**Checking Lore & Legend Items**" FFFF00FF
	if ${UIElement[LoreAndLegend@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		if ${ItemIterator:First(exists)}
		{
			do
			{
				if ${ItemIterator.Value.Description.Find[${NameFilter1}]}
				{
					call AddLog "Adding ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name} to Broker" FF11CCFF
					echo DEBUG: ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${LLBox},${BrokerWindow.VendingContainer[${LLBox}].Consignment[${ItemIterator.Value.Name}].SerialNumber}]
					ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${LLBox},${BrokerWindow.VendingContainer[${LLBox}].Consignment[${ItemIterator.Value.Name}].SerialNumber}]
					wait ${Math.Rand[30]:Inc[20]}
				}
			}
			while ${ItemIterator:Next(exists)} && ${RunBroker}
		}
	}
}

function PlaceCustom()
{
	call CheckFocus
	call AddLog "**Checking Custom Items List**" FFFF00FF

	call PlaceItemsFromSet ${CustomItems.FindSet[CustomItems].GUID} ${CustBox}
}

function DestroyItems()
{
	RunDestroy:Set[TRUE]
	wait 5
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Destroy v2 By Syliac**" FF00FF00

	wait 5
	call AddSellLog "**Destroying Items**" FFFF00FF
	wait 5
	variable iterator iter
	Destroy.FindSet[Destroy]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		do
		{
			if ${Me.Inventory[ExactName,${iter.Key}].Quantity} > 0
			{
				call AddSellLog "Destroying  ${Me.Inventory[${iter.Key}].Quantity}  ${Me.Inventory[${iter.Key}]}" FFFF0000
				Me.Inventory[${iter.Key}]:Destroy[${Me.Inventory[${iter.Key}].Quantity}]
				wait ${Math.Rand[30]:Inc[20]}
			}
		}
		while ${iter:Next(exists)} && ${RunDestroy}
	}

	if ${RunDestroy}
	{
		call AddSellLog "**Items Destroyed**" FFFF00FF
	}
	else
	{
		call AddSellLog "**EQ2Destroy Canceled!**" FFFF00FF
	}
}

function VendorType()
{
	if ${UIElement[StatusMerchant@EQ2Junk@GUITabs@EQ2Inventory].Checked}
	{
		call SellStatus
	}
	else
	{
		call SellJunk
	}
}

function SellJunk()
{
	RunJunk:Set[TRUE]
	variable int JunkCount=0

	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00

	if ${Actor[guild,Guild Commodities Exporter](exists)}
	{
		Actor[guild,Guild Commodities Exporter]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}
	else
	{
		Actor[nokillnpc]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 15
	EQ2Execute /togglebags
	wait 10
	call AddSellLog "**Selling Junk Items**" FFFF00FF
	variable iterator iter
	Junk.FindSet[Junk]:GetSettingIterator[iter]
	do
	{
		if (${iter:First(exists)})
		{
			do
			{			
				if ${Me.Inventory[${iter.Key}].Quantity} >= 1 && ${iter.Key.NotEqual[NULL]} && ${MerchantWindow.MyInventory[${iter.Key}].IsForSale}
				{
					do
					{
						Debug:Echo["${iter.Key}"]
						Debug:Echo["Selling ${MerchantWindow.MyInventory[${iter.Key}]}"]
						call AddSellLog "Selling ${Me.Inventory[ExactName, ${iter.Key}].Quantity}  ${MerchantWindow.MyInventory[${iter.Key}]}" FF11CCFF
						MerchantWindow.MyInventory[${iter.Key}]:Sell[${Me.Inventory[ExactName, ${iter.Key}].Quantity}]
						wait 15
					}
					while ${Me.Inventory[ExactName,${iter.Key}].Quantity} > 0 
				}
			}
			while ${iter:Next(exists)} && ${RunJunk}
		}
	}	
	while ${JunkCount:Inc} >= 5	

	if ${UIElement[SellTreasured@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk}
	{
		call SellTreasured
	}

	if ${UIElement[SellAdeptI@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk}
	{
		call SellAdeptI
	}

	if ${UIElement[SellHandcrafted@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk}
	{
		call SellHandcrafted
	}

	if ${UIElement[SellUncommon@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk}
	{
		call SellUncommon
	}

	if ${RunJunk}
	{
		call AddSellLog "**Junk Items Sold**" FFFF00FF
	}
	else
	{
		call AddSellLog "**EQ2Junk Canceled!**" FFFF00FF
	}
	press ESC
	press ESC
	press ESC
}

function SellStatus()
{
	variable index:item Items
	variable iterator ItemIterator
	
	NameFilter1:Set[awarded a great amount of status]
	UIElement[SellItemList@EQ2junk@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00
	Actor[nokillnpc]:DoTarget
	wait 5
	Target:DoFace
	wait 5
	Target:DoubleClick
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	wait 10
	call AddSellLog "**Selling Status Items to Status Vendor**" FFFF00FF

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.Description.Find[${NameFilter1}]}
			{
				call AddSellLog "Selling ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name}"
				MerchantWindow.MyInventory[${ItemIterator.Value.Name}]:Sell[${ItemIterator.Value.Quantity}]
			}
		}
		while ${ItemIterator:Next(exists)}
	}

	call AddSellLog "**Status Items Sold to Status Vendor**" FFFF00FF

	press ESC
	press ESC
	press ESC
}

function SellTreasured()
{
	variable index:item Items
	variable iterator ItemIterator
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.Tier.Equal[TREASURED]} && ${MerchantWindow.MyInventory[${ItemIterator.Value.Name}].IsForSale}
			{
				if !${ItemIterator.Value.InNoSaleContainer}
				{
					if !${ItemIterator.Value.IsContainer}
					{
						call AddSellLog "Selling ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name}"
						MerchantWindow.MyInventory[${ItemIterator.Value.Name}]:Sell[${ItemIterator.Value.Quantity}]
						wait 15
					}
				}
			}
		}
		while ${ItemIterator:Next(exists)} && ${RunJunk}
	}
}

function SellHandcrafted()
{
	variable index:item Items
	variable iterator ItemIterator
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	wait 5

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.Tier.Equal[HANDCRAFTED]} && ${MerchantWindow.MyInventory[${ItemIterator.Value.Name}].IsForSale}
			{
				if !${ItemIterator.Value.InNoSaleContainer}
				{
					if !${ItemIterator.Value.IsContainer}
					{
						call AddSellLog "Selling ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name}"
						MerchantWindow.MyInventory[${ItemIterator.Value.Name}]:Sell[${ItemIterator.Value.Quantity}]
						wait 15
					}
				}
			}
		}
		while ${ItemIterator:Next(exists)} && ${RunJunk}
	}
}

function SellUncommon()
{
	variable index:item Items
	variable iterator ItemIterator
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	wait 5

	if ${ItemIterator:First(exists)}
	{
		do
		{
	  		if ${ItemIterator.Value.Tier.Equal[UNCOMMON]} && ${MerchantWindow.MyInventory[${ItemIterator.Value.Name}].IsForSale}
			{
				if !${ItemIterator.Value.InNoSaleContainer}
				{
					if !${ItemIterator.Value.IsContainer}
					{
						call AddSellLog "Selling ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name}"
						MerchantWindow.MyInventory[${ItemIterator.Value.Name}]:Sell[${ItemIterator.Value.Quantity}]
						wait 15
					}
				}
			}
		}
		while ${ItemIterator:Next(exists)} && ${RunJunk}
	}
}
function SellAdeptI()
{
	variable index:item Items
	variable iterator ItemIterator
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	wait 5

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.Name.Find[(Adept)]} && ${MerchantWindow.MyInventory[${ItemIterator.Value.Name}].IsForSale} && ${RunJunk}
			{
				if !${ItemIterator.Value.InNoSaleContainer}
				{
					if !${ItemIterator.Value.IsContainer}
					{
						call AddSellLog "Selling ${ItemIterator.Value.Quantity} ${ItemIterator.Value.Name}"
						MerchantWindow.MyInventory[${ItemIterator.Value.Name}]:Sell
						wait ${Math.Rand[30]:Inc[20]}
					}
				}
			}
		}
		while ${ItemIterator:Next(exists)} && ${RunJunk}
	}
}

function TradeItems()
{
	variable int i
	
	if !${Target(exists)}
	{
		echo ${Time}: You need a target to trade with.
		return
	}
	EQ2Execute "apply_verb ${Target.ID} Trade"
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 10
	UIElement[TradeItemList@Trade Items@GUITabs@EQ2Inventory]:ClearItems
	wait 10
	call AddTradeLog "**Starting to Trade Items**" FFFF00FF
	wait 30
	
		call TradeItemsFromSet ${Trade.FindSet[Trade]}
		
	wait 10
	EQ2Execute /accept_trade
	wait 30
	relay all EQ2Execute /accept_trade
	call AddTradeLog "**Finished Trading Items**" FFFF00FF
	TradeFinished:Set[TRUE]
}

function TradeItemsFromSet(settingsetref SSR)
{
	variable iterator iter
	variable int HowMany=12
	variable int iItemsTraded=0
	variable int TradeLoopCount=0
	SSR:GetSettingIterator[iter]
	while ${TradeLoopCount:Inc} <= 10
	{
		if (${iter:First(exists)})
		{
			do
			{
				while ${Me.Inventory[${iter.Key}].Quantity} > 0 && ${HowMany} > ${iItemsTraded}
				{
					do
					{
						call AddTradeLog "Adding ${Me.Inventory[${iter.Key}].Quantity} ${iter.Key} to Trade Window" FF11CCFF
						wait 10
						EQ2Execute /add_trade_item ${Math.Calc[${Me.Inventory[${iter.Key}].Index}-1]} ${iItemsTraded} ${Me.Inventory[${iter.Key}].Quantity}
						wait 5
						iItemsTraded:Inc
						wait 5
					}
					while (${iter:Next(exists)}) && ${Me.Inventory[${iter.Key}].Quantity} > 0 && ${HowMany} < ${iItemsTraded}
				}	
				if ${iItemsTraded} > 0
				{
					EQ2Execute /accept_trade
					wait 10
					relay all EQ2Execute /accept_trade 
					wait 20
					iItemsTraded:Set[0]
					EQ2Execute "apply_verb ${Target.ID} Trade"
				}
				
			}
			while (${iter:Next(exists)})
		}
	}	
}

function TradeList()
{
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Trade List*******" FFFF00FF
	variable iterator iter
	Trade.FindSet[Trade]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		Do
		{
			call AddRemoveList "${iter.Key}"
		}
		while ${iter:Next(exists)}
	}
}

function JunkList()
{
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Vendor Junk List*******" FFFF00FF
	variable iterator iter
	Junk.FindSet[Junk]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		Do
		{
			call AddRemoveList "${iter.Key}"
		}
		while ${iter:Next(exists)}
	}
}

function DestroyList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Destroy Item List*******" FFFF00FF
	variable iterator iter
	Destroy.FindSet[Destroy]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		Do
		{
			call AddRemoveList "${iter.Key}"
		}
		while ${iter:Next(exists)}
	}
}

function CustomList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Custom Item List*******" FFFF00FF
	variable iterator iter
	Custom.FindSet[CustomItems]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		Do
		{
			call AddRemoveList "${iter.Key}"
		}
		while ${iter:Next(exists)}
	}
}

function DeleteMeat()
{
	variable int KeyNum=1
	call AddLog "**Deleting Meats**" FFFF0000

	variable iterator iter
	DeleteMeats.FindSet[Meats]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		Do
		{
			if ${Me.Inventory[${iter.Key}].Quantity} > 0
			{
				call AddLog "Deleting  ${Me.Inventory[${iter.Key}].Quantity}  ${Me.Inventory[${iter.Key}]}" FFFF0000
				Me.Inventory[${iter.Key}]:Destroy[${Me.Inventory[${iter.Key}].Quantity}]
				wait 15
			}
		}
		while ${iter:Next(exists)}
	}
}

function AddJunk()
{
	noop ${Junk.FindSet[Junk].FindSetting[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]}
	Settings:SaveSettings[${Junk}]
	Junk.FindSet[Junk]:Sort
	Settings:SaveSettings[${Junk}]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}
function AddTrade()
{
	noop ${Trade.FindSet[Trade].FindSetting[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]}
	Settings:SaveSettings[${Trade}]
	Trade.FindSet[Trade]:Sort
	Settings:SaveSettings[${Trade}]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}
function AddDestroy()
{
	noop ${Destroy.FindSet[Destroy].FindSetting[[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]}
	Settings:SaveSettings[${Destroy}]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function AddCustom()
{
	noop ${Custom.FindSet[CustomItems].FindSetting[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]}
	Settings:SaveSettings[${Custom}]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function RemoveJunk()
{
	Junk.FindSet[Junk].FindSetting[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]:Remove
	Settings:SaveSettings[${Junk}]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}
function RemoveTrade()
{
	Trade.FindSet[Trade].FindSetting[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]:Remove
	Settings:SaveSettings[${Trade}]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}
function RemoveDestroy()
{
	Destroy.FindSet[Destroy].FindSetting[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]:Remove
	Settings:SaveSettings[${Destroy}]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function RemoveCustom()
{
	Custom.FindSet[CustomItems].FindSetting[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]:Remove
	Settings:SaveSettings[${Custom}]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function InvList()
{
	call CreateInventorylist
	wait 5
	call CreateInventorylist
	wait 5
	call CreateInventorylist
}

function CreateInventorylist()
{
	variable index:item Items
	variable iterator ItemIterator
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory]:ClearItems
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	call AddInvList "**Creating Inventory List ${Items.Used} Items**" FFFF00FF

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if !${ItemIterator.Value.InNoSaleContainer}
			{
				if !${ItemIterator.Value.IsContainer}
				{
					if ${ItemIterator.Value.InInventory}
						call AddInvList "${ItemIterator.Value.Name}"
				}
			}
		}
		while ${ItemIterator:Next(exists)}
	}
}

function AddLog(string textline, string colour)
{
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}

function AddSellLog(string textline, string colour)
{
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}

function AddTradeLog(string textline, string colour)
{
	UIElement[TradeItemList@Trade Items@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[TradeItemList@Trade Items@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}

function AddInvList(string textline, string colour)
{
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
}

function AddRemoveList(string textline, string colour)
{
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
}

function CheckFocus()
{
	if !${EQ2UIPage[Inventory,Market].IsVisible}
	{
		call AddLog "EQ2Broker **Paused** Place Cursor over Broker" FFEECC00
		do
		{
			waitframe
		}
		while !${EQ2UIPage[Inventory,Market].IsVisible}
	}
	return
}


function ShutDown()
{
	press ESC
	press ESC
	press ESC
	call AddLog "**Ending EQ2Broker**" FF00FF00
	
	if ${UIElement[RunMyPrices@EQ2Broker@GUITabs@EQ2Inventory].Checked}
	{
		call AddLog "*****Starting MyPrices*****" FFEECC00
		wait 5
		run myprices/myprices.iss
		Wait 125

		UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[Start Scanning]:LeftClick
	}
}


function atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
	Settings:SaveSettings
	Root:Remove
}