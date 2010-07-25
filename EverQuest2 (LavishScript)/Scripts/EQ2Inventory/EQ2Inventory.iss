;EQ2Broker v2
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
variable bool RunDepot=TRUE
variable bool RunJunk=TRUE
variable bool RunDestroy=TRUE
variable bool SlotFull=FALSE
variable bool SkipItem=FALSE
variable bool DepotItemsPlaced=FALSE
;=================================
;Setting references
;=================================
variable settingsetref Junk
variable settingsetref Destroy
variable settingsetref Custom
variable settingsetref Depot
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
	Debug:Enable
	declare EQ2InvInterface _EQ2InvInterface global
	call InitializeSettings

	Event[EQ2_onIncomingText]:AttachAtom[GetText]

	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
	wait 1

	UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
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
	Root:AddSet[Depot]
	Root:AddSet[DeleteMeats]
	Root:AddSet[Fertilizer]
	Root:AddSet[Harvests]
	Root:AddSet[StatusItems]
	Root:AddSet[UserSettings]

	Junk:Set[${Root.FindSet[Junk]}]
	Destroy:Set[${Root.FindSet[Destroy]}]
	Custom:Set[${Root.FindSet[Custom]}]
	Depot:Set[${Root.FindSet[Depot]}]
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

	UserSettings:AddSet[General Settings]
	genset:Set[${UserSettings.FindSet[General Settings]}]

	; These are the setting sets we want to save. The script can modify these.
	Settings:SetFilename[${Junk},./ScriptConfig/Junk.xml]
	Settings:SetFilename[${Destroy},./ScriptConfig/Destroy.xml]
	Settings:SetFilename[${Custom},./ScriptConfig/CustomItems.xml]
	Settings:SetFilename[${Depot},./ScriptConfig/SupplyDepotList.xml]
	Settings:SetFilename[${UserSettings},./CharConfig/${Me.Name}.xml]

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
	Settings:AddSetting[GathererHireling,${genset},GathererHireling,0]
	Settings:AddSetting[HunterHireling,${genset},HunterHireling,0]
	Settings:AddSetting[MinerHireling,${genset},MinerHireling,0]
	Settings:AddSetting[GathererTierNumber,${genset},GathererTierNumber,1]
	Settings:AddSetting[HunterTierNumber,${genset},HunterTierNumber,1]
	Settings:AddSetting[MinerTierNumber,${genset},MinerTierNumber,1]
	Settings:AddSetting[UseHarvestDepot,${genset},UseHarvestDepot,1]
	Settings:AddSetting[Examine,${genset},Examine,0]
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
	EQ2:CreateCustomActorArray[byDist,15]
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

	for (i:Set[1];${i}<=8;i:Inc)
	{
		call CheckFocus
		Me:CreateCustomInventoryArray[nonbankonly]

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
			if ${Me.CustomInventory[ExactName,${iter.Key}].Quantity} > 0
			{
				call AddLog "Adding ${Me.CustomInventory[${iter.Key}].Quantity} ${iter.Key} to Broker" FF11CCFF
				Me.CustomInventory[ExactName,${iter.Key}]:AddToConsignment[${Me.CustomInventory[ExactName,${iter.Key}].Quantity},${Container},${Me.Vending[${Container}].Consignment[${iter.Key}].SerialNumber}]
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

	for (i:Set[1];${i}<=8;i:Inc)
	{
		call CheckFocus
		Me:CreateCustomInventoryArray[nonbankonly]

		if ${UIElement[EQ2Inventory].FindUsableChild[CHarvestT${i},checkbox].Checked}
		{
			call PlaceItemsFromSet ${Harvests.FindSet[SCHarvestT${i}]} ${CHBox}
		}
	}
}


function PlaceCollection()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call AddLog "**Checking Previously Collected Collections**"	FFFF00FF
	Do
	{
		if ${UIElement[Collections@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked} && ${Me.CustomInventory[${ArrayPosition}].IsCollectible} && ${Me.CustomInventory[${ArrayPosition}].AlreadyCollected}
			{
				Do
				{
					call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to Broker" FF11CCFF
					Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}].Quantity},${CLBox},${Me.Vending[${CLBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
					wait ${Math.Rand[30]:Inc[20]}
				}
				while ${Me.CustomInventory[${ArrayPosition}].Name(exists)} && ${Me.CustomInventory[${ArrayPosition}].Name.Length}>4
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize}
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
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	call CheckFocus
	wait 5
	Do
	{

		if ${Me.CustomInventory[${ArrayPosition}].Type.Equal[${ItemType}]}
			if ${Me.CustomInventory[${ArrayPosition}].Class[1].Name.Equal[${ClassName}]}
				if ${Me.CustomInventory[${ArrayPosition}].Name.Find[${NameFilter1}]} || ${Me.CustomInventory[${ArrayPosition}].Name.Find[${NameFilter2}]} || ${Me.CustomInventory[${ArrayPosition}].Name.Find[${NameFilter3}]}
				{
					call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to broker" FF11CCFF
					Me.CustomInventory[ExactName,${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${ArrayPosition}].Quantity},${UseBox},${Me.Vending[${UseBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
					wait ${Math.Rand[30]:Inc[20]}
				}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunBroker}
}

function PlaceStatusItems()
{
	call CheckFocus
	call AddLog "**Checking Status Items List**" FFFF00FF

	variable int i

	for (i:Set[1];${i}<=8;i:Inc)
	{
		call CheckFocus
		Me:CreateCustomInventoryArray[nonbankonly]

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
		Me:CreateCustomInventoryArray[nonbankonly]

		if ${UIElement[EQ2Inventory].FindUsableChild[FertT${i},checkbox].Checked}
		{
			call PlaceItemsFromSet ${Fertilizer.FindSet[FertT${i}]} ${FertBox}
		}
	}
}

function PlaceLoreAndLegend()
{
	variable int ArrayPosition=1
	NameFilter1:Set[could be studied to learn]
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call CheckFocus
	call AddLog "**Checking Lore & Legend Items**" FFFF00FF
	if ${UIElement[LoreAndLegend@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
		{
			Do
			{
				if ${Me.CustomInventory[${ArrayPosition}].Description.Find[${NameFilter1}]}
				{
						call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to Broker" FF11CCFF
						echo DEBUG: Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}].Quantity},${LLBox},${Me.Vending[${LLBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
						Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}].Quantity},${LLBox},${Me.Vending[${LLBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
						wait ${Math.Rand[30]:Inc[20]}
				}
			}
			while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunBroker}
		}
}

function PlaceCustom()
{
	call CheckFocus
	call AddLog "**Checking Custom Items List**" FFFF00FF
	Me:CreateCustomInventoryArray[nonbankonly]

	call PlaceItemsFromSet ${CustomItems.FindSet[CustomItems].GUID} ${CustBox}
}

function DestroyItems()
{
	RunDestroy:Set[TRUE]
	wait 5
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Destroy v2 By Syliac**" FF00FF00
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call AddSellLog "**Destroying Items**" FFFF00FF
	wait 5
	variable iterator iter
	Destroy.FindSet[Destroy]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		do
		{
			if ${Me.CustomInventory[ExactName,${iter.Key}].Quantity} > 0
			{
				call AddSellLog "Destroying  ${Me.CustomInventory[${iter.Key}].Quantity}  ${Me.CustomInventory[${iter.Key}]}" FFFF0000
				Me.CustomInventory[${iter.Key}]:Destroy[${Me.CustomInventory[${iter.Key}].Quantity}]
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

	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00
	EQ2:CreateCustomActorArray[byDist,15]
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
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 10
	call AddSellLog "**Selling Junk Items**" FFFF00FF
	variable iterator iter
	Junk.FindSet[Junk]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		do
		{			
			if ${Me.CustomInventory[${iter.Key}].Quantity} >= 1 && ${iter.Key.NotEqual[NULL]} && ${Me.Merchandise[${iter.Key}].IsForSale}
			{
				do
				{
					Debug:Echo["${iter.Key}"]
					Debug:Echo["Selling ${Me.Merchandise[${iter.Key}]}"]
					call AddSellLog "Selling ${Me.CustomInventory[${iter.Key}].Quantity}  ${Me.Merchandise[${iter.Key}]}" FF11CCFF
					Me.Merchandise[${iter.Key}]:Sell[${Me.CustomInventory[${iter.Key}].Quantity}]
					wait 15
				}
				while ${Me.CustomInventory[ExactName,${iter.Key}].Quantity} > 0 
			}
		}
		while ${iter:Next(exists)} && ${RunJunk}
	}

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
	variable int ArrayPosition=1
	NameFilter1:Set[awarded a great amount of status]
	UIElement[SellItemList@EQ2junk@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00
	Actor[nokillnpc]:DoTarget
	wait 5
	Target:DoFace
	wait 5
	Target:DoubleClick
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 20
	call AddSellLog "**Selling Status Items to Status Vendor**" FFFF00FF

	Do
	{
		if ${Me.CustomInventory[${ArrayPosition}].Description.Find[${NameFilter1}]}
		{
			call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
			Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
		}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk}
	call AddSellLog "**Status Items Sold to Status Vendor**" FFFF00FF

	press ESC
	press ESC
	press ESC
}

function SellTreasured()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	Do
	{
		if ${Me.CustomInventory[${ArrayPosition}].Tier.Equal[TREASURED]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
						wait 15
					}
				}
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk}
}

function SellHandcrafted()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	Do
	{
	  	if ${Me.CustomInventory[${ArrayPosition}].Tier.Equal[HANDCRAFTED]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
						wait 15
					}
				}
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk}
}

function SellUncommon()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	Do
	{
	  	if ${Me.CustomInventory[${ArrayPosition}].Tier.Equal[UNCOMMON]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
						wait 15
					}
				}
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk}
}
function SellAdeptI()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5

	Do
	{
		if ${Me.CustomInventory[${ArrayPosition}].Name.Find[(Adept)]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale} && ${RunJunk}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell
						wait ${Math.Rand[30]:Inc[20]}
					}
				}
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk}
}

function AddToDepot()
{
	variable string TestString
	variable int Drop
	RunDepot:Set[TRUE]
	SkipItem:Set[FALSE]
	SlotFull:Set[FALSE]
	wait 5
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory]:ClearItems
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call AddDepotLog "**Adding Items to Supply Depot**" FFFF00FF
	wait 5
	variable iterator iter
	Depot.FindSet[Supplys]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		do
		{
			Drop:Set[1]
			SkipItem:Set[FALSE]
			SlotFull:Set[FALSE]
			while (${Drop}>0) && ${RunDepot} && !${SkipItem} && !${SlotFull}
			{
				if (${iter.Key.Length} <= 4)
					break

				TestString:Set[${Me.CustomInventory[${iter.Key}]}]
				if ${TestString.Find[{n}]}
				{
					Drop:Set[${Me.CustomInventory[${iter.Key}].Quantity}]
					TestString:Set[${TestString.Token[2,}].Token[1,{]}]
					echo Found {n} -- TestString: ${TestString}
				}
				else
					Drop:Set[${Me.CustomInventory[ExactName,${iter.Key}].Quantity}]


				if (${Drop} < 1)
					break

				echo DEBUG EQ2Depot Drop: ${Drop} Item Name: ${Me.CustomInventory[${iter.Key}]} Key: ${iter.Key}

				call AddDepotLog "Adding ${Me.CustomInventory[${iter.Key}].Quantity}  ${TestString}"
				Me.CustomInventory[${iter.Key}]:AddToDepot[${Actor[depot].ID}]
				wait ${Math.Rand[30]:Inc[20]}

				if ${SlotFull}
					{
						call AddDepotLog "---Slot ${TestString} Max QTY!!---" FFFF0000
					}
				if ${SkipItem}
				{
					call AddDepotLog "---Skipping item will not add to depot properly!!---" FFFF0000
				}
			}
		}
		while ${iter:Next(exists)} && ${RunDepot}
		DepotItemsPlaced:Set[TRUE]
	}

	if ${RunDepot}
	{
		call AddDepotLog "**Items Added to Supply Depot**" FFFF00FF
	}
	else
	{
		call AddDepotLog "**EQ2Depot Canceled!**" FFFF00FF
	}
}


atom GetText(string DepotItemFull)
{
	if ${DepotItemFull.Find["This container cannot hold any more of this item."]}
		{
				SlotFull:Set[TRUE]
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

function DepotList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Depot Item List*******" FFFF00FF
	variable iterator iter
	Depot.FindSet[Supplys]:GetSettingIterator[iter]
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

	Me:CreateCustomInventoryArray[nonbankonly]

	variable iterator iter
	DeleteMeats.FindSet[Meats]:GetSettingIterator[iter]
	if (${iter:First(exists)})
	{
		Do
		{
			if ${Me.CustomInventory[${iter.Key}].Quantity} > 0
			{
				call AddLog "Deleting  ${Me.CustomInventory[${iter.Key}].Quantity}  ${Me.CustomInventory[${iter.Key}]}" FFFF0000
				Me.CustomInventory[${iter.Key}]:Destroy[${Me.CustomInventory[${iter.Key}].Quantity}]
				wait 15
			}
		}
		while ${iter:Next(exists)}
	}
}

function EQ2Hirelings()
{
	RunScript EQ2Inventory/SubScripts/EQ2Hirelings
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

function AddDepot()
{
	noop ${Depot.FindSet[Supplys].FindSetting[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Save]}
	Settings:SaveSettings[${Depot}]
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

function RemoveDepot()
{
	Depot.FindSet[Supplys].FindSetting[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]:Remove
	Settings:SaveSettings[${Depot}]
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
	variable int ArrayPosition=1
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory]:ClearItems
	Me:CreateCustomInventoryArray[nonbankonly]
	call AddInvList "**Creating Inventory List ${Me.CustomInventoryArraySize} Items**" FFFF00FF

	Do
	{
		if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
		{
			if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
			{
				if ${Me.CustomInventory[${ArrayPosition}].InInventory}
					call AddInvList "${Me.CustomInventory[${ArrayPosition}].Name}"
			}
	  }
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize}
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

function AddDepotLog(string textline, string colour)
{
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}
function AddOverDepotLog(string textline, string colour)
{
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
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