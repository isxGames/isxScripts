;-----------------------------------------------------------------------------------------------
; Craft.iss Version 9.5
;
; Originally written by Blazer in 2005 and maintained over the years by Hendrix, Valerian, Amadeus
; and CyberTech.
;-----------------------------------------------------------------------------------------------

#include "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss"
#include "${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Include/Search.iss"

/* Optional includes */
#includeoptional "${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss"
#includeoptional "${LavishScript.HomeDirectory}/Scripts/EQ2Common/MovementKeys.iss"

variable EQ2Craft Craft
variable string CraftVersion="9.5"
variable int QualityResult
variable string TSSpell[4,3]
variable string CurrentReactive
variable int CurrentQuality
variable int CurrentProgress
variable int CurrentDurability
variable bool roundstart
variable int counter
variable bool complete
variable int tempkey
variable bool firstpass
variable int timer
variable bool chktotdur
variable int TotalDurability
variable int ChangeinDur
variable int tempdur
variable filepath RecipePath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Recipe Data/"
variable filepath NavigationPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Navigational Paths/"
variable filepath UIPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/UI/"
variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Character Config/"
variable filepath QueuePath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Queues"
variable string configfile
variable string alternatefile
variable string skillsfile
variable string commonfile
variable string rafile
variable float MakeQty[2,200]
variable int MakeCnt[2]
variable string MakeName[2,200]
variable int64 MakeID[2,200]
variable string MakeKnowledge[2,200]
variable string MakeDevice[2,200]
variable int MakeQlt[2,200]
variable string MakeFuelName[2,200]
variable int MakeFuelCnt[2,200]
variable int MakeProduce[2,200]
variable int MakeLevel[2,200]
variable int xval
variable int xvar
variable string StatFuelNme[200]
variable int StatFuelCnt[200]
variable int StatFuelTot[200]
variable int fuelcnt
variable string StatResNme[200]
variable int StatResCnt[200]
variable int StatResTot[200]
variable int rescnt
variable string StatComNme[200]
variable int StatComCnt[200]
variable int StatComTot[200]
variable int comcnt
variable string StatCraftNme[200]
variable int StatCraftCnt[200,4]
variable int StatCraftTot[2,200]
variable int craftcnt
variable bool startrecipe
variable string MainRecipe
variable bool missval
variable int QOverride
variable string lastdevice
variable int crafttimer=${Time.Timestamp}
variable bool invupdate
variable bool SortLevel
variable int Level
variable bool Quality1
variable bool Quality2
variable bool Quality3
variable bool Quality4=TRUE
variable int QualityUI
variable float gaugelevel
variable bool CampOut=TRUE
variable bool fpassui=TRUE
variable int gaugefactor=1
variable string QueueList[250]
variable int QueueQty[250]
variable int queuecnt
variable bool ShowAllLists
variable bool CurrentStation
variable bool checkinv
variable string resourcefile
variable string writfile
variable string writcountfile
variable string globalfile
variable int RecipeListMin
variable int RecipeListMax
variable bool RecipeListRange
variable bool GuildPrivacy
variable bool GuildPrivacyAlways
variable bool SaveList
variable bool BuyCommon
variable bool BuyFuel
variable bool BuyHarvest
variable float MaxBuyPrice
variable bool NotEnoughCoin=FALSE
variable int CampTimer
variable int WritCount
variable int WritQty
variable int Tier
variable int WritLevel
variable bool endcraft
variable bool CampNow
variable bool resumecraft=TRUE
variable bool PromptResume=TRUE
variable bool MakeRare
variable settingsetref RecipeList
variable settingsetref Configuration
variable settingsetref Global
variable settingsetref CraftQueue
variable settingsetref LastSavedQueue
variable settingsetref TradeSkillType
variable settingsetref VendorBought
variable settingsetref QualityPrefix
variable settingsetref Harvests
variable settingsetref Rares
variable settingsetref WritRecipes
variable settingsetref WritCounts
variable settingsetref Wholesalers
variable iterator sIterator
variable index:string FailedRecipe
variable bool SecondaryTS
variable string SecondarySkill[4]
variable bool WaitforPower
variable int PowerRegen
variable bool AutoTransmute
variable bool StopCraftingAtSecondaryMaxLevel = false
variable bool ShowSTS
variable bool StandardFilter
variable bool ImbuedFilter
variable bool RareFilter
variable index:string ItemsCreated
variable int Durability[2,4]
variable int CraftDelay
variable float PathPrecision
variable bool WritTrigger
variable bool GotWrit
variable bool UpdateRecipeCount
variable int RecipeCount
variable int TotalQueued
variable bool EnableDebug
variable bool AllowWritSort
variable bool V1
variable bool V2
variable bool EchoInChat
variable bool NotMain
variable int LevelGained
variable bool CraftLite
variable EQ2Nav Nav
variable string AutoRunKey
variable string BackwardKey
variable string StrafeRightKey
variable string StrafeLeftKey
variable bool IsDecliningRaidInvites
variable bool IsDecliningTradeInvites
variable bool IsDecliningGroupInvites
variable collection:int ComponentQuantites
variable index:string RecipesInQueue
variable bool GuildPrivacySet
variable bool GuildPrivacySetting
variable bool DeclineInvites
variable string CmdLineQueue
variable bool EnableTTS
variable collection:bool WarnedResources
variable bool CraftLiteMode=FALSE
variable bool HideUI=FALSE
variable(global) _CraftInterface ICraft

;; Localization
variable string sLocalization
variable string RushOrder_GuildTag
variable string RushOrder_GuildTag2
variable string WorkOrder_GuildTag
variable string WorkOrder_GuildTag2
variable string Broker_GuildTag
variable string Broker_GuildTag2
variable string Wholesaler
variable string WritInitialConvo
variable string WorkOrderClipboard
variable string WorkOrdersDesk
variable string Desk
variable string StoveAndKeg
variable string SewingTableAndMannequin
variable string WoodworkingTable
variable string WorkBench
variable string ChemistryTable
variable string Forge
variable string EngravedDesk
variable string ElaborateTable
variable string GuildCraftingStation

variable int ROX
variable int ROY
variable int WOX
variable int WOY


; V1 == Verbose mode, we echo shit.
; V2 == Verbose debug mode, we echo more shit.
; EchoInChat == All error/echo goes to chat window, debug output always goes to console.

atom(script) ChatEcho(... Params)
{
   if !${Params.Size}
   {
	  return
   }
   if ${EchoInChat} && ${V1}
   {
	  eq2echo ${Params.Expand}
   }
   elseif ${V1}
   {
	  echo ${Params.Expand}
   }
}

atom(script) ErrorEcho(... Params)
{
   if !${Params.Size}
   {
	  return
   }
   if !${Quiet}
   {
      ChatEcho ${Params.Expand}
   }
}

atom(script) ChatSay(... Params)
{
	if !${Params.Used} || !${EnableTTS}
		return
	Debug:Echo["EQ2Craft::ChatSay '${Params.Expand}'"]
	if ${TTS.IsReady}
		speak "${Params.Expand}"
}

function ValidateRegions()
{
	variable set Regions
	variable int Counter
	variable int Instances = 3 /* TODO - Make this a configurable # script wide? Any reason? */

;
;	Future Work:
;		When (if) craft converts to a new nav, these regions should be placed inside
;		regiongroups.  This would significantly simplify finding the nearest work
;		area to a given point, and remove the hard-coded 3 position list.
;	-- CyberTech
;
	Regions:Add[RushOrder]
	Regions:Add[WorkOrder]
	Regions:Add[Wholesaler]
	Regions:Add[Broker]
	Regions:Add[Invoices]
	for (Counter:Set[1]; ${Counter} <= 3; Counter:Inc)
	{
		Regions:Add[Invoices ${Counter}]
		Regions:Add[Chemistry Table ${Counter}]
		Regions:Add[Work Bench ${Counter}]
		Regions:Add[Sewing Table & Mannequin ${Counter}]
		Regions:Add[Woodworking Table ${Counter}]
		Regions:Add[Stove & Keg ${Counter}]
		Regions:Add[Forge ${Counter}]
		Regions:Add[Engraved Desk ${Counter}]
	}

	Debug:Echo["EQ2Craft:: Validating Regions"]
	Debug:Echo["Not all regions are required. This is for debugging and informational purposes only."]
	variable iterator Region
	Regions:GetIterator[Region]
	Region:First
	do
	{
		if ${Nav.RegionExists[${Region.Value}]}
		{
			Debug:Echo["EQ2Craft::  Found: ${Region.Value} Path: ${Nav.AvailablePathToRegion[${Region.Value}]}"]
			; Have the bot navigate every known navpoint in alphabetical order at startup?
			#define TEST_NAVPATHS 0
			#if TEST_NAVPATHS
			Nav:MoveToRegion["${Region.Value}"]
			do
			{
				Nav:Pulse
				wait 0
			}
			while ${ISXEQ2(exists)} && ${Nav.Moving}
			#endif
		}
		else
		{
			Debug:Echo["EQ2Craft::  Missing: ${Region.Value}"]
		}
	}
	while ${Region:Next(exists)}
}

function SetLocalization()
{
	;; Note:  Be sure to search through the script for instances of ${sLocalization} for specific edits that will be required
	;;        that cannot be included in this function.
	;;
	;;        Also, if anything is not translated, it means that the translation was not provided and therefore will default to English.

	switch ${EQ2.ServerName}
	{
		case Storms
			;; NOTES:
			;;   1.  Almost all "vendors" on the French server have the same title prefix ("venduer"), so wholesaler names have to go in common.xml.  This is why
			;;       the "Wholesaler" variable is still in English.
			Debug:Echo["EQ2Craft:: Utilizing French Localization"]
			sLocalization:Set["French"]

			RushOrder_GuildTag:Set["ordres urgents"]
			RushOrder_GuildTag2:Set["Agent responsable des ordres urgents de perfectionnement"]
			WorkOrder_GuildTag:Set["ordres urgents"]
			WorkOrder_GuildTag2:Set["Agent responsable des ordres de missions de perfectionnement"]
			Broker_GuildTag:Set["N�gociant"]
			Broker_GuildTag2:Set["N�gociant de la salle de la guilde"]
			Wholesaler:Set["Wholesaler"]

			WritInitialConvo:Set["Je voudrais "]

			WorkOrderClipboard:Set["Porte-bloc de commandes"]
			WorkOrdersDesk:Set["Work Orders Desk"]
			Desk:Set["bureau"]

			StoveAndKeg:Set["Cuisini�re et baril"]
			SewingTableAndMannequin:Set["Table de couture avec un mannequin"]
			WoodworkingTable:Set["Table de travail du bois"]
			WorkBench:Set["Etabli"]
			ChemistryTable:Set["Table de chimie"]
			Forge:Set["Forge"]
			EngravedDesk:Set["Bureau poin�onn�"]
			break

		default
			sLocalization:Set["English"]

			RushOrder_GuildTag:Set["Rush Orders"]
			RushOrder_GuildTag2:Set["Tradeskill Rush Order Agent"]
			WorkOrder_GuildTag:Set["Work Orders"]
			WorkOrder_GuildTag2:Set["Tradeskill Writ Agent"]
			Broker_GuildTag:Set["Broker"]
			Broker_GuildTag2:Set["Guild World Market Broker"]
			Wholesaler:Set["Wholesaler"]

			WritInitialConvo:Set["I would like"]

			WorkOrderClipboard:Set["Work Order Clipboard"]
			WorkOrdersDesk:Set["Work Orders Desk"]
			Desk:Set["desk"]

			StoveAndKeg:Set["Stove & Keg"]
			SewingTableAndMannequin:Set["Sewing Table & Mannequin"]
			WoodworkingTable:Set["Woodworking Table"]
			WorkBench:Set["Work Bench"]
			ChemistryTable:Set["Chemistry Table"]
			Forge:Set["Forge"]
			EngravedDesk:Set["Engraved Desk"]
			break
	}
}

atom(script) UpdateTotal()
{
	variable int xvar
	variable int xval
	TotalQueued:Set[0]
	xvar:Set[2]
	do
	{
		xval:Set[${MakeCnt[${xvar}]}]
		do
		{
			if ${MakeCnt[${xvar}]} && ${MakeQty[${xvar},${xval}]}>0 && ${MakeName[${xvar},${xval}].Length}
			{
				TotalQueued:Inc
			}
		}
		while ${xval:Dec}>0
	}
	while ${xvar:Dec}>0
}
function main(... recipeFavourite)
{
	variable int tempvar
	variable string tmplist
	variable int frcount
	variable bool skipwait
	variable bool foundfavourite
	variable int tcount
	variable string guildtag
	variable int j = 1
	variable bool craftingready
	variable string craftingknowledge
	variable string craftingrecipe
	variable int argIndex=1
	variable int Timer = 1

	Script:DisableDebugging
	Debug:SetFilename["${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Craft_Debug.txt"]

	if !${ISXEQ2.IsReady}
	{
		ErrorEcho "ISXEQ2 has not been loaded! Ending Craft..."
		Script:End
	}

	ChatEcho "---------------------------"
	ChatEcho "EQ2Craft:: Initializing..."
	
	ISXEQ2:SetCustomVariable[SRO,0]
	ISXEQ2:ClearAbilitiesCache

	if (!${Me.Recipe[1](exists)})
	{
		ChatEcho "EQ2Craft:: Opening Recipe Book to Retrieve Data from Server"
		EQ2Execute /toggletradeskills
		wait 50
		EQ2Execute /toggletradeskills
	}

	checkinv:Set[TRUE]

	CmdLineQueue:Set[]

	while ${argIndex} <= ${recipeFavourite.Used}
	{
		switch ${recipeFavourite[${argIndex}]}
		{
		case -vv
			V2:Set[TRUE]
		case -debug
			EnableDebug:Set[TRUE]
			Debug:Enable
			break
		case -sort
			AllowWritSort:Set[TRUE]
			break
		case -v
			V1:Set[TRUE]
			break
		case -q
			Quiet:Set[TRUE]
			break
		case -chat
			Verbose:Set[TRUE]
			break
		case -start
			startrecipe:Set[TRUE]
			break
		case -load
			skipwait:Set[TRUE]
			break
		case -lite
			CraftLiteMode:Set[TRUE]
			break
		case -hideui
			HideUI:Set[TRUE]
			break
		case -buffer
		case -script
			break
		default
			CmdLineQueue:Set[${CmdLineQueue} ${recipeFavourite[${argIndex}]}]
		}
		argIndex:Inc
	}

	if ${CmdLineQueue.Length} == 0
	{
		skipwait:Set[FALSE]
		startrecipe:Set[FALSE]
	}
	elseif !${skipwait} /* Should only be false at this point if -load was NOT used. */
	{
		skipwait:Set[TRUE]
		startrecipe:Set[TRUE]
	}

	;;;;;;;;;;;;
	;; Load Navigation System
	Nav:UseLSO[FALSE]
	Nav:LoadMap
	Nav.SmartDestinationDetection:Set[FALSE]
	Nav.BackupTime:Set[3]
	Nav.StrafeTime:Set[3]
	;;;;;;;;;;;;

	;;;;;;;;;;;;
	;; Set Localization
	call SetLocalization
	;;;;;;;;;;;;

	Craft:InitConfig
	Craft:CheckThresholds
	Craft:CheckGUIFiles
	Craft:InitTriggers
	Craft:InitEvents

	;; Decline invitations
	Craft:DoIgnores[TRUE]

	call ValidateRegions

	GuildPrivacySetting:Set[${Me.GuildPrivacyOn}]
	if ${GuildPrivacyAlways}
	{
		if !${GuildPrivacySetting}
		{
			GuildPrivacySet:Set[TRUE]
			eq2execute "guild event_privacy true"
		}
	}
	ChatEcho "EQ2Craft:: Initialization complete"
	ChatEcho "---------------------------"
	if ${EnableDebug}
	{
		ChatEcho DEBUGGING ENABLED!
	}

	squelch module -add lsmtts

	if ${skipwait} /* Queue specified on cmdline, need to validate. */
	{
		if !${Craft.LoadAndValidateQueue[${CmdLineQueue}]}
		{
			ErrorEcho Recipe Favourite [${CmdLineQueue}] NOT FOUND!
			Script:End
		}
	}

	checkinv:Set[TRUE]

	if ${CraftLiteMode}
	{
		Craft:SetMode[lite]
		UIElement[Main Frame@Craft Selection]:Hide
		UIElement[Craft Selection]:Minimize
		UIElement[CraftLite@Titlebar@Craft Selection]:SetText[Craft Full]
	}

	if ${HideUI}
		UIElement[Craft Selection]:Hide

	while 1
	{
		if ${invupdate}
		{
			wait 2
			call CheckInventory
			Craft:InitGUI
			invupdate:Set[FALSE]
		}

		do
		{
			roundstart:Set[FALSE]
			Call ProcessTriggers
			call CheckInventory
			Craft:InitGUI

			if ${CraftLite}
			{
				Craft:EnableReactions
			}
			while ${CraftLite}
			{
				waitframe
				call ProcessTriggers
				if ${complete}
				{
					Debug:Echo["CRAFT DETECTED COMPLETE -- clearing."]
					wait 10
					ItemsCreated:Clear
					complete:Set[FALSE]
					roundstart:Set[FALSE]
				}
				if ${roundstart} && !${craftingready}
				{
				; Need to initialize our variables here.
				; Knowledge var, TSSpell var
					Debug:Echo[Round started, but we're not ready.]
					if ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,Tradeskills.TabPages.Craft.Create.RecipeName](exists)}
					{
						craftingrecipe:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,Tradeskills.TabPages.Craft.Create.RecipeName].GetProperty[LocalText]}]
						craftingknowledge:Set[${Me.Recipe[${craftingrecipe}].Knowledge}]
						TSSpell[1,1]:Set["${LavishSettings[Skills].FindSet[${craftingknowledge}].FindSetting[1 1]}"]
						TSSpell[1,2]:Set["${LavishSettings[Skills].FindSet[${craftingknowledge}].FindSetting[1 2]}"]
						TSSpell[1,3]:Set["${LavishSettings[Skills].FindSet[${craftingknowledge}].FindSetting[1 3]}"]
						TSSpell[2,1]:Set["${LavishSettings[Skills].FindSet[${craftingknowledge}].FindSetting[2 1]}"]
						TSSpell[2,2]:Set["${LavishSettings[Skills].FindSet[${craftingknowledge}].FindSetting[2 2]}"]
						TSSpell[2,3]:Set["${LavishSettings[Skills].FindSet[${craftingknowledge}].FindSetting[2 3]}"]
						craftingready:Set[TRUE]
						CurrentQuality:Set[0]
						chktotdur:Set[TRUE]
						Debug:Echo[CraftLite Vars set!]
						Debug:Echo[TSSpell[1,1\]: ${TSSpell[1,1]} Knowledge: ${craftingknowledge}]
					}
				}
				if ${roundstart} && ${craftingready}
				{
					Debug:Echo[CraftLite Starting to craft!]
					while ${CurrentQuality}<4 && ${CraftLite} && ${craftingready} && !${complete}
					{
						call ProcessTriggers
						if ${roundstart} && ${CurrentQuality}<4
						{
							; Cancel ALL TS Buffs first if there are any on the maintained window still
							Craft:CancelBuffs
							wait 3

							roundstart:Set[FALSE]
							timer:Set[${Time.Timestamp}]

							if ${chktotdur}
							{
								TotalDurability:Set[${Math.Calc[${CurrentDurability}-${ChangeinDur}]}]
								chktotdur:Set[FALSE]
							}

							; Lets check if we need to counter the reaction
							counter:Set[${LavishSettings[Reaction Arts].FindSet[${craftingknowledge}].FindSetting[${CurrentReactive},0]}]
							tempdur:Set[((${CurrentDurability}/${TotalDurability}*100)-80)/20*100]

							if ${counter}
							{
								if ${tempdur}>${Durability[2,2]}
								{
									call CastReaction 1 ${counter}
								}
								else
								{
									call CastReaction 2 ${counter}
								}

								if ${counter}==1
								{
									if ${tempdur}>${Durability[2,2]}
									{
										call CastReaction 1 2
									}
									else
									{
										call CastReaction 2 2
									}

									if ${tempdur}<${Durability[2,1]} && ${Me.Power}/${Me.MaxPower}*100>${Durability[2,3]}
									{
										call CastReaction 2 3
									}
								}

								if ${counter}==2
								{
									if ${tempdur}>${Durability[2,2]}
									{
										call CastReaction 1 1
									}
									else
									{
										call CastReaction 2 1
									}

									if ${tempdur}<${Durability[2,1]} && ${Me.Power}/${Me.MaxPower}*100>${Durability[2,3]}
									{
										call CastReaction 2 3
									}
								}
								if ${counter}==3
								{
									if ${tempdur}>${Durability[2,2]}
									{
										call CastReaction 1 1
										call CastReaction 1 2
									}
									else
									{
										call CastReaction 2 1
										call CastReaction 2 2
									}
								}
							}
							else
							{
								; Check if its a special reactive
								if ${CurrentReactive.Length}
								{
									EQ2Echo [${Time.Date} ${Time}] Unknown Reaction Art - ${CurrentReactive}...Knowledge - ${craftingknowledge}\n >> UnknownReactionArts.txt

									;wait ${Math.Calc[${counter}*2]}
									call ProcessArts
								}
								else
								{
									call ProcessArts
								}
							}
						}
						waitframe
					}
					craftingready:Set[FALSE]
					roundstart:Set[FALSE]
					ItemsCreated:Clear
				}
				craftingready:Set[FALSE]
				roundstart:Set[FALSE]
				ItemsCreated:Clear
			}
			Craft:DisableReactions

			craftingready:Set[FALSE]
			roundstart:Set[FALSE]
			ItemsCreated:Clear
			complete:Set[FALSE]

			call CheckLevelGained

			if (${EQ2.Zoning} != 0)
			{
				do
				{
					wait 50
				}
				while (${EQ2.Zoning} != 0)
				wait 50
			}

			if ${invupdate}
			{
				wait 2
				call CheckInventory
				Craft:InitGUI
				invupdate:Set[FALSE]
			}

			if ${skipwait} /* If we get here, we've got a commandline queue loaded into our CraftQueue set. */
			{
				UIElement[Craft Selection].FindUsableChild[Craft Main,tabcontrol].Tab[2]:Select
				Craft:LoadRecipeList /* Will be used to "convert" the CraftQueue set to our internal queue */
				call ProcessQueue
				skipwait:Set[FALSE]
			}

			if ${ISXEQ2.GetCustomVariable[SRO,bool]} || ${ISXEQ2.GetCustomVariable[SWO,bool]}
			{
				if ${GuildPrivacy}
				{
					if !${GuildPrivacySet}
					{
						GuildPrivacySetting:Set[${Me.GuildPrivacyOn}]
						if !${GuildPrivacySetting}
						{
							GuildPrivacySet:Set[TRUE]
							eq2execute "guild event_privacy true"
						}
					}
				}

				startrecipe:Set[TRUE]
				UIElement[Craft Selection].FindUsableChild[Craft Main,tabcontrol].Tab[1]:Select
				WritCount:Set[${UIElement[Craft Selection].FindUsableChild[NumWrits,text].Text}]
				WritQty:Set[${UIElement[Craft Selection].FindUsableChild[Writ Qty,textentry].Text}]
				;; "Tier" is really "select option" for writ choices...bad name
				Tier:Set[${UIElement[Tier@Writs@Craft Main@Main Frame@Craft Selection].Text}]

				Configuration.FindSetting[How many Writs to create per craft session?]:Set[${WritCount}]
				Configuration.FindSetting[How many Recipes per Writ?]:Set[${WritQty}]
				Configuration.FindSetting[Which Writ Tier to use?]:Set[${Tier}]
				LavishSettings[Craft Config File]:Export[${configfile}]
				if ${ISXEQ2:GetCustomVariable["CWC",int]}<0
					ISXEQ2:SetCustomVariable[CWC,5]
				UIElement[Craft Selection].FindUsableChild[Writs Remaining,text]:SetText["${ISXEQ2.GetCustomVariable["CWC",int]} Writs remaining"]
				GotWrit:Set[FALSE]
				call GetWrit
			}

			if ${FailedRecipe.Used}
			{
				UIElement[Craft Selection].FindUsableChild[Start Crafting,commandbutton]:Hide
				UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Hide
				UIElement[Craft Selection].FindUsableChild[Add Recipe,commandbutton]:Hide
				UIElement[Craft Selection].FindUsableChild[Process Recipe,variablegauge]:Show
				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:Show

				if ${WritTrigger}
				{
					ChatEcho "EQ2Craft:: Processing Writ Recipes..."
				}
				else
				{
					ChatEcho "EQ2Craft:: Processing Failed Recipes again..."
				}

				tempvar:Set[0]
				while ${tempvar:Inc}<5
				{
					if ${Quality${tempvar}}
					{
						while ${FailedRecipe.Used}
						{
							gaugelevel:Set[0.05]
							gaugefactor:Set[1]
							frcount:Set[${FailedRecipe.Used}]
							MainRecipe:Set[${Arg[1,${FailedRecipe.Get[${frcount}]}]}]
							gaugelevel:Set[0.1]
							if !${Me.Recipe[${MainRecipe}](exists)}
							{
								ErrorEcho "EQ2Craft:: Check your recipe book.  You either do not have a recipe for '${MainRecipe}', or (if you're doing writs) it is named differently than what EQ2Craft has extracted from the Writ and needs to be added to the CustomWrits.xml file."
								Script:End
							}

							gaugelevel:Set[0.2]
							if (!${Me.Recipe[${MainRecipe}].IsRecipeInfoAvailable})
							{
								gaugelevel:Set[0.3]
								Timer:Set[0]
								do
								{
									waitframe
									;; It is OK to use waitframe here because the "IsRecipeInfoAvailable" will simple return
									;; FALSE while the details acquisition thread is still running.   In other words, it
									;; will not spam the server.
								}
								while (!${Me.Recipe[${MainRecipe}].IsRecipeInfoAvailable} && ${Timer:Inc} < 1500)
								gaugelevel:Set[0.4]
							}
							gaugelevel:Set[0.5]

							if ${Arg[3,${FailedRecipe.Get[${frcount}]}]}
							{
								NotMain:Set[TRUE]
							}
							else
							{
								NotMain:Set[FALSE]
							}
							Craft:ProcessRecipe[${MainRecipe},${tempvar},${Arg[2,${FailedRecipe.Get[${frcount}]}]}]
							gaugelevel:Set[0.6]
							Craft:CalculateComponents
							gaugelevel:Set[0.7]
							;call CheckInventory
							gaugelevel:Set[0.8]
							Craft:InitGUI
							gaugelevel:Set[0.9]
							if (${FailedRecipe.Used} == 1)
								FailedRecipe:Clear
							else
							{
								FailedRecipe:Remove[${frcount}]
								FailedRecipe:Collapse
							}
							gaugelevel:Set[1]
						}
					}
				}

				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:SetText[Processing Inventory...]
				call CheckInventory
				wait 2
				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:SetText[Updating Quantities...]
				wait 1
				Craft:InitGUI

				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:SetText[Currently Processing Recipe..]

				; Close any remaining Examine Windows
				while ${EQ2UIPage[Examine,MainHUD].Child[Text,ExamineRecipe.InfoPage.Name].GetProperty[LocalText](exists)}
				{
					EQ2Execute /close_top_window
					wait 5
				}

				UIElement[Craft Selection].FindUsableChild[Process Recipe,variablegauge]:Hide
				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:Hide
				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:SetText[Currently Processing Recipe..]
				UIElement[Craft Selection].FindUsableChild[Start Crafting,commandbutton]:Show
				UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Show
				UIElement[Craft Selection].FindUsableChild[Add Recipe,commandbutton]:Show
			}
		}
		while !${startrecipe}

		UIElement[Craft Selection].FindUsableChild[Start Crafting,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Hide
		MaxBuyPrice:Set[${UIElement[Craft Selection].FindUsableChild[Max Buy Price,textentry].Text}]
		Configuration.FindSetting[Specify the MAXIMUM price for purchasing Resources]:Set[${MaxBuyPrice}]
		LavishSettings[Craft Config File]:Export[${configfile}]

		if (${Zone.ShortName.Find[qey]} > 0)
		{
			if ${BuyHarvest}
			{
				call BuyHarvests
			}

			if ${BuyCommon} || ${BuyFuel}
			{
				call BuyComponents
			}
		}
		else
		{
			if ${BuyCommon} || ${BuyFuel}
			{
				call BuyComponents
			}

			if ${BuyHarvest}
			{
				call BuyHarvests
			}
		}

		if ${SaveList}
		{
			tempvar:Set[0]
			CraftQueue:Clear
			while ${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Item[${tempvar:Inc}](exists)}
			{
				tmplist:Set[${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Item[${tempvar}]}]
				CraftQueue:AddSetting[${tmplist.Token[1,|]},${tmplist.Token[2,|]}]
			}
			CraftQueue:Export[${QueuePath}/${Me.TSSubClass}-Last_Crafted_Queue.xml]
			CraftQueue:Clear
		}

		CampTimer:Set[${UIElement[Craft Selection].FindUsableChild[Camp Timer,textentry].Text}]
		Configuration.FindSetting[Camp out after a specified time has elapsed for a crafting session?]:Set[${CampTimer}]
		PowerRegen:Set[${UIElement[Craft Selection].FindUsableChild[Power Regen,textentry].Text}]
		Configuration.FindSetting[Amount of Power to Regenerate before crafting a recipe?]:Set[${PowerRegen}]
		CraftDelay:Set[${UIElement[Craft Selection].FindUsableChild[Craft Delay,textentry].Text}]
		PathPrecision:Set[${UIElement[Craft Selection].FindUsableChild[Path Precision,textentry].Text}]
		Configuration.FindSetting[Time to wait between combines?]:Set[${CraftDelay}]
		Configuration.FindSetting[Pather Precision]:Set[${PathPrecision}]

		LavishSettings[Craft Config File]:Export[${configfile}]

		UIElement[Craft Selection].FindChild[Main Frame]:Hide
		UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Hide:SetZOrder[notalwaysontop]
		UIElement[Craft Selection].FindChild[crafting Frame]:Show:SetZOrder[alwaysontop]
		UIElement[Craft Selection].FindUsableChild[Quit Button,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Pause Button,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Camp Now,checkbox]:Show
		Craft:ProgressGUI

		checkinv:Set[FALSE]
		UpdateTotal
		xvar:Set[2]
		do
		{
			xval:Set[${MakeCnt[${xvar}]}]
			do
			{
				if ${MakeCnt[${xvar}]} && ${MakeQty[${xvar},${xval}]}>0 && ${MakeName[${xvar},${xval}].Length}
				{
					MakeRare:Set[FALSE]
					Craft:InitCraftSkills[${xvar},${xval}]
					if !${CurrentStation}
						call MovetoDevice "${MakeDevice[${xvar},${xval}]}" ${Math.Rand[3]:Inc}
					else
						ChatEcho "EQ2Craft:: 'Use current TARGETTED station' option selected -- not moving."

					if ${MakeName[${xvar},${xval}].Find[Adept III]} || ${This.SearchPartialRare[${MakeName[${xvar},${xval}]}]} || ${MakeName[${xvar},${xval}].Left[6].Equal[Imbued]} || ${MakeName[${xvar},${xval}].Left[7].Equal[Blessed]}
						MakeRare:Set[TRUE]
					TotalQueued:Dec
					call Craft ${MakeID[${xvar},${xval}]} ${MakeQty[${xvar},${xval}].Ceil} ${MakeQlt[${xvar},${xval}]} ${xvar} ${xval}
					wait 10
				}
			}
			while ${xval:Dec}>0
		}
		while ${xvar:Dec}>0

		if ${GotWrit}
		{
			if ${RewardWindow(exists)}
			{
				wait 5
				RewardWindow:AcceptReward
			}
			Craft:ClearAllRecipes[0]

			UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Hide
			UIElement[Craft Selection].FindUsableChild[Camp Now,checkbox]:Hide
			UIElement[Craft Selection].FindUsableChild[Pause Button,commandbutton]:Hide
			UIElement[Craft Selection].FindUsableChild[Quit Button,commandbutton]:Hide
			UIElement[Craft Selection].FindChild[crafting Frame]:Hide
			UIElement[Craft Selection].FindChild[Main Frame]:Show:SetZOrder[movetop]
			UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Show:SetZOrder[alwaysontop]:SetZOrder[movetop]
			UIElement[Craft Selection].FindUsableChild[Craft Main,tabcontrol].Tab[4]:Select


			if ${ISXEQ2.GetCustomVariable[SRO,bool]}
			{
				call MovetoDevice "RushOrder"
				wait 1
				if (${Target.ID} <= 0)
					Actor[xzrange,10,yrange,2,guild,"Rush Orders"]:DoTarget
			}
			else
			{
				call MovetoDevice "WorkOrder"
				wait 1
				if (${Target.ID} <= 0)
					Actor[xzrange,10,yrange,2,guild,"Work Orders"]:DoTarget
			}

			wait 5
			Target:DoFace
			wait 2
			;EQ2Execute /apply_verb ${Target.ID} hail
			Target:DoubleClick

			wait 15
			wait 100 ${RewardWindow(exists)}
			wait 15
			if (${RewardWindow(exists)})
			{
			   RewardWindow:AcceptReward
			   wait 15
			}

			call CheckLevelGained

			;EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			;wait 10

			WritTrigger:Set[FALSE]
			GotWrit:Set[FALSE]
			UpdateRecipeCount:Set[FALSE]
			FailedRecipe:Clear

			if (${ISXEQ2.GetCustomVariable["CWC",int]} < 1)
			{
				startrecipe:Set[FALSE]
				ISXEQ2:SetCustomVariable[SRO,0]
				ISXEQ2:SetCustomVariable[SWO,0]

				ChatEcho "EQ2Craft:: No more Writs to Make!"
				ChatSay "Writ session complete."
				ISXEQ2:SetCustomVariable[CWC,-1]
				UIElement[Craft Selection].FindUsableChild[Writs Remaining,text]:SetText[""]
				UIElement[Craft Selection].FindUsableChild[Create Work Order,commandbutton]:Show
				UIElement[Craft Selection].FindUsableChild[Create Rush Order,commandbutton]:Show
				UIElement[CraftLite@Titlebar@Craft Selection]:Show

				;; If "GuildPrivacyAlways" then this will be handled elsewhere
				if !${GuildPrivacyAlways} && ${GuildPrivacy}
				{
					if ${Me.GuildPrivacyOn} && !${GuildPrivacySetting}
					{
						eq2execute "guild event_privacy false"
						GuildPrivacySet:Set[FALSE]
					}
				}
			}
			else
			{
				ChatEcho "EQ2Craft:: Remaining Writs to Make: ${ISXEQ2.GetCustomVariable["CWC",int]}"
				if ${ISXEQ2.GetCustomVariable["CWC",int]}>1
					ChatSay "There are ${ISXEQ2.GetCustomVariable["CWC",int]} writs remaining."
				else
					ChatSay "There is 1, writ remaining."
				UIElement[Craft Selection].FindUsableChild[Writs Remaining,text]:SetText["${ISXEQ2.GetCustomVariable["CWC",int]} Writs remaining"]
			}
		}
		else
		{
			;ANNOUNCE IS BROKEN announce "Recipe has been made!" 5 3
			ChatSay "Craft session complete."

			if (${Math.Calc64[${Time.Timestamp}-${crafttimer}]}>${Math.Calc64[${CampTimer}*60]} && ${CampOut}) || ${CampNow}
			{
				wait 600
				EQ2Execute /camp desktop
				Script:End
			}

			startrecipe:Set[FALSE]
			lastdevice:Set[]

			UIElement[Craft Selection].FindUsableChild[Camp Now,checkbox]:Hide
			UIElement[Craft Selection].FindUsableChild[Pause Button,commandbutton]:Hide
			UIElement[Craft Selection].FindUsableChild[Quit Button,commandbutton]:Hide
			UIElement[Craft Selection].FindChild[crafting Frame]:Hide
			UIElement[Craft Selection].FindChild[Main Frame]:Show:SetZOrder[movetop]
			UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Show:SetZOrder[alwaysontop]:SetZOrder[movetop]
			UIElement[CraftLite@Titlebar@Craft Selection]:Show

			Craft:ClearAllRecipes[0]
			ComponentQuantites:Clear
			RecipesInQueue:Clear
			FailedRecipe:Clear
		}
	}

	Craft:DoIgnores[FALSE]
	if ${GuildPrivacy} || ${GuildPrivacyAlways}
	{
		if ${GuildPrivacySet} && ${Me.GuildPrivacyOn} && !${GuildPrivacySetting}
		{
			eq2execute "guild event_privacy false"
			GuildPrivacySet:Set[FALSE]
		}
	}
}
objectdef __QueuedRecipe
{
	variable float MakeQty[2,200]
	variable int MakeCnt[2]
	variable string MakeName[2,200]
	variable int64 MakeID[2,200]
	variable string MakeKnowledge[2,200]
	variable string MakeDevice[2,200]
	variable int MakeQlt[2,200]
	variable string MakeFuelName[2,200]
	variable int MakeFuelCnt[2,200]
	variable int MakeProduce[2,200]
	variable int MakeLevel[2,200]

}

function AcceptQuest()
{
	if (${RewardWindow.Child[text,Title].GetProperty[localtext].Find["New Quest"]})
	{
		if (${EQ2UIPage[PopUp,RewardPack].Child[button,RewardPack.ButtonComposite.Accept](exists)})
			EQ2UIPage[PopUp,RewardPack].Child[button,RewardPack.ButtonComposite.Accept]:LeftClick
		else
			EQ2UIPage[PopUp,RewardPack].Child[button,RewardPack.Accept]:LeftClick
	}
	else
		echo "\arERROR\ax - RewardWindow expected to have title of 'New Quest!' but was actually '${RewardWindow.Child[text,Title].GetProperty[localtext]}'"
}

function GetWrit()
{
	variable int tcount
	variable string guildtag

	UIElement[Craft Selection].FindUsableChild[Create Work Order,commandbutton]:Hide
	UIElement[Craft Selection].FindUsableChild[Create Rush Order,commandbutton]:Hide
	UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Show:SetZOrder[alwaysontop]:SetZOrder[movetop]
	if ${ISXEQ2.GetCustomVariable[SRO,bool]}
	{
		call MovetoDevice "RushOrder"
		guildtag:Set[Rush Orders]
		wait 2
		if (${Target.ID} <= 0)
			Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}]:DoTarget
	}
	else
	{
		call MovetoDevice "WorkOrder"
		guildtag:Set[Work Orders]
		wait 2
		if (${Target.ID} <= 0)
			Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}]:DoTarget
	}

	if (${Target.ID} <= 0)
	{
		ErrorEcho "EQ2Craft:: There was a problem obtaining a writ (No Target) -- ending script."
		Script:End
	}

	Quality1:Set[FALSE]
	Quality2:Set[FALSE]
	Quality3:Set[FALSE]
	Quality4:Set[TRUE]

	wait 2

	wait 5
	;EQ2Execute /apply_verb ${Target.ID} hail
	Target:DoubleClick
	wait 15
	if !${EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1].GetProperty[LocalText].Left[12].Equal[${WritInitialConvo}]}
	{
		EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
		wait 6
		;EQ2Execute /apply_verb ${Target.ID} hail
		Target:DoubleClick
		wait 15
	;	Amadeus needs to reset NumChildren when it closes
	}

	;;; This should not happen..but just in case...
	if ${Tier} <= 0
		Tier:Set[1]

	EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${Tier}]:LeftClick
	wait 10
	if ${RewardWindow(exists)}
		call AcceptQuest
	else
		wait 40
	if ${RewardWindow(exists)}
		call AcceptQuest
	else
	{
		ErrorEcho "EQ2Craft:: There was a problem obtaining a writ quest -- ending script."
		Script:End
	}

	wait 15
	EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
	wait 15
	EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
	wait 6

	; Move to Invoice Desk
	call MovetoDevice "Invoices"
	wait 5
	; TODO - Expand the exists check below to check for other specific desk names, before falling back to desk substring
	if ${Actor[xzrange,10,${WorkOrderClipboard}].Name(exists)}
		Actor[${WorkOrderClipboard}]:DoubleClick
	elseif ${Actor[xzrange,10,${WorkOrdersDesk}].Name(exists)}
		Actor[${WorkOrdersDesk}]:DoubleClick
	else
		Actor[${Desk}]:DoubleClick
	wait 20
	wait 30 !${Me.CastingSpell}
	FlushQueued

	if !${ReplyDialog(exists)}
		call WaitForResume "Unable to find order clipboard or desk (are 'Invoices 1-3' NavPoints defined?) Click Resume to continue"

	; Pick the first option available to us in the replydialog window
	ReplyDialog:Choose[1]
	wait 8

	EQ2Execute /close_top_window

	WritTrigger:Set[TRUE]
	wait 100 ${GotWrit}

	if ${WritLevel} == 0
		ErrorEcho "EQ2Craft:: WritLevel was zero.  This is bad.  Try again and let Amadeus know if it continues."

	call ProcessTriggers
}

function Create(int qresult)
{
}

function Craft(int64 xrecipe, int repeats, int qresult, int var1, int var2)
{
	variable int tempvar=1
	variable int tempvar2
	variable string pText
	variable int sep1
	variable int sep2
	variable int sep3
	variable int currentqty
	variable int maxqty
	variable int j = 1
	variable bool FoundRecipeBook

	call CheckLevelGained

	if ${RewardWindow(exists)}
	{
		wait 5
		RewardWindow:AcceptReward
	}

	if ${MakeRare}
	{
		tempvar2:Set[2]
	}
	else
	{
		tempvar2:Set[1]
	}

	firstpass:Set[TRUE]
	missval:Set[FALSE]
	QualityResult:Set[${qresult}]

	if ${EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Recipes](exists)}
	{
		EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Recipes]:LeftClick
	}

	if ${WaitforPower}
	{
		if ${Me.Power}/${Me.MaxPower}*100<${PowerRegen}
		{
			ChatEcho Waiting for Power to Regenerate to ${PowerRegen}%
		}

		while ${Me.Power}/${Me.MaxPower}*100<${PowerRegen}
		{
			waitframe
		}
	}

	EQ2Execute /createfromrecipe ${xrecipe}
	wait 15
	wait ${Math.Calc[${CraftDelay}*10]}
	call Begin

	if ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,TradeSkills.TabPages.Craft.prepare.summarypage.pccount].GetProperty[LocalText](exists)}
	{
		if ${Craft.CheckPageStuck}
		{
			call Cancel
			missval:Set[TRUE]
			Craft:UpdateProgress[${var1},${var2}]
			return
		}
	}

	do
	{
		; Check Power
		if ${WaitforPower} && !${firstpass}
		{
			if ${Me.Power}/${Me.MaxPower}*100<${PowerRegen}
			{
				ChatEcho Waiting for Power to Regenerate to ${PowerRegen}%
			}

			while ${Me.Power}/${Me.MaxPower}*100<${PowerRegen}
			{
				waitframe
			}
		}

		complete:Set[FALSE]
		ItemsCreated:Clear

		if !${firstpass}
		{
			wait ${Math.Calc[${CraftDelay}*10]}

			; Repeat the Craft Process
			call Repeat

			if ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,TradeSkills.TabPages.Craft.prepare.summarypage.pccount].GetProperty[LocalText](exists)}
			{
				if ${Craft.CheckPageStuck}
				{
					call Cancel
					missval:Set[TRUE]
					Craft:UpdateProgress[${var1},${var2}]
					return
				}
			}
			call Begin
		}

		; Crafting has Begun
		; Call the first set of reaction arts
		FlushQueued
		roundstart:Set[FALSE]

		call InitialRound

		timer:Set[${Time.Timestamp}]
		chktotdur:Set[TRUE]
		CurrentQuality:Set[0]

		while ${CurrentQuality}<${QualityResult}
		{
			if ${roundstart} && !${complete}
			{
				; Cancel ALL TS Buffs first if there are any on the maintained window still
				Craft:CancelBuffs
				wait 3

				roundstart:Set[FALSE]
				timer:Set[${Time.Timestamp}]

				if ${chktotdur}
				{
					TotalDurability:Set[${Math.Calc[${CurrentDurability}-${ChangeinDur}]}]
					chktotdur:Set[FALSE]
				}

				; Check if the recipe is Tinkering or Adorning first
				;if ${MakeKnowledge[${var1},${var2}].Equal[Tinkering]} || ${MakeKnowledge[${var1},${var2}].Equal[Adorning]}
				;{
				;	call ProcessSecondaryArts
				;	continue
				;}

				; Lets check if we need to counter the reaction
				counter:Set[${LavishSettings[Reaction Arts].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[${CurrentReactive},0]}]
				tempdur:Set[((${CurrentDurability}/${TotalDurability}*100)-80)/20*100]

				if ${counter}
				{
					if ${tempdur}>${Durability[${tempvar2},2]}
					{
						call CastReaction 1 ${counter}
					}
					else
					{
						call CastReaction 2 ${counter}
					}

					if ${counter}==1
					{
						if ${tempdur}>${Durability[${tempvar2},2]}
						{
							call CastReaction 1 2
						}
						else
						{
							call CastReaction 2 2
						}

						if ${tempdur}<${Durability[${tempvar2},1]} && ${Me.Power}/${Me.MaxPower}*100>${Durability[${tempvar2},3]}
						{
							call CastReaction 2 3
						}
					}

					if ${counter}==2
					{
						if ${tempdur}>${Durability[${tempvar2},2]}
						{
							call CastReaction 1 1
						}
						else
						{
							call CastReaction 2 1
						}

						if ${tempdur}<${Durability[${tempvar2},1]} && ${Me.Power}/${Me.MaxPower}*100>${Durability[${tempvar2},3]}
						{
							call CastReaction 2 3
						}
					}
					if ${counter}==3
					{
						if ${tempdur}>${Durability[${tempvar2},2]}
						{
							call CastReaction 1 1
							call CastReaction 1 2
						}
						else
						{
							call CastReaction 2 1
							call CastReaction 2 2
						}

					}
				}
				else
				{
					; Check if its a special reactive
					if ${CurrentReactive.Length}
					{
						EQ2Echo [${Time.Date} ${Time}] Unknown Reaction Art - ${CurrentReactive}...Knowledge - ${MakeKnowledge[${var1},${var2}]}\n >> UnknownReactionArts.txt

						;wait ${Math.Calc[${counter}*2]}
						call ProcessArts
					}
					else
					{
						call ProcessArts
					}
				}
			}

			if ${complete}
			{
				break
			}

			if ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,TradeSkills.TabPages.Craft.prepare.summarypage.pccount].GetProperty[LocalText](exists)}
			{
				if ${Craft.CheckPageStuck}
				{
					missval:Set[TRUE]
					break
				}
			}

			if ${Time.Timestamp}-${timer}>30
			{
				break
			}
		}

		Craft:UpdateProgress[${var1},${var2}]

		if ${missval}
		{
			return
		}

		; Quality has been Achieved, lets stop the craft process
		if !${complete} && ${CurrentQuality}
		{
			EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Stop]:LeftClick
			wait 15
		}

		CurrentQuality:Set[0]
		firstpass:Set[FALSE]

		if ${complete}
		{
			while ${ItemsCreated.Used}
			{
				wait 50 ${Me.Inventory[${ItemsCreated.Get[${ItemsCreated.Used}]}](exists)}
				if ${AutoTransmute} && ${Me.Inventory[${ItemsCreated.Get[${ItemsCreated.Used}]}].ToItemInfo.Tier.Equal[MASTERCRAFTED]}
				{
					wait 40
					Me.Inventory[${ItemsCreated.Get[${ItemsCreated.Used}]}]:Transmute
					wait 200 ${RewardWindow(exists)}
					RewardWindow:AcceptReward
				}

				ItemsCreated:Remove[${ItemsCreated.Used}]
				ItemsCreated:Collapse
			}
		}

		if ${thisbuttonpaused}
		{
			while ${thisbuttonpaused}
			{
				waitframe
			}

			lastdevice:Set[]

			if !${CurrentStation}
			{
				call MovetoDevice "${MakeDevice[${var1},${var2}]}" ${Math.Rand[3]:Inc}
			}
		}

		if ${endcraft}
		{
			Craft:DisableReactions
			Script:End
		}
	}
	while ${tempvar:Inc}<=${repeats}
	firstpass:Set[TRUE]

	Craft:DisableReactions
	call CheckLevelGained
}

function MovetoDevice(string devicename, int devicenum)
{
	variable int tmprnd
	variable int tcount
	variable int doorheading
	variable string ToTargetName
	variable iterator Iterator
	variable bool InGuildHall = FALSE

	;; Localized Device Name
	variable string ldevicename

	if (${Zone.ShortName.Find[guildhall]} > 0)
		InGuildHall:Set[TRUE]

	CurrentStatus:Set["Moving to device: ${devicename} ${devicenum}"]

	switch ${devicename}
	{
		case Stove and Keg
			devicename:Set["Stove & Keg"]
			ldevicename:Set[${StoveAndKeg}]
			break

		case Loom
			devicename:Set["Sewing Table & Mannequin"]
			ldevicename:Set[${SewingTableAndMannequin}]
			break

		case Sawhorse
			devicename:Set["Woodworking Table"]
			ldevicename:Set[${WoodworkingTable}]
			break

		case Work Bench
		case Workbench
			devicename:Set["Work Bench"]
			ldevicename:Set[${WorkBench}]
			break

		case Chemistry Table
		case ChemistryTable
			devicename:Set["Chemistry Table"]
			ldevicename:Set[${ChemistryTable}]
			break

		case Forge
			devicename:Set["Forge"]
			ldevicename:Set[${Forge}]
			break

		case Engraved Desk
		case EngravedDesk
			devicename:Set["Engraved Desk"]
			ldevicename:Set[${EngravedDesk}]
			break

		case Wholesaler
		case Rushorder
		case Workorder
		case Broker
		case Invoices
			break

		default
			ldevicename:Set[${devicename}]
			break
	}

	if ${lastdevice.Equal[${devicename}]}
		return

	if ${devicename.Equal[Rushorder]}
	{
		;; TS Instances  (For English Servers, ${RushOrder_GuildTag} == "Rush Orders")
		if ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}].ID}"
			if ${Target.Guild.Equal[${RushOrder_GuildTag}]}
				face
			wait 10
			if (${Target.ID} <= 0)
			{
				ErrorEcho "EQ2Craft:: Unable to target Rush Order Agent (in TS Instance) -- ending script."
				Script:End
			}
			lastdevice:Set[Rushorder]
			return
		}
		;; Guildhalls   (For English Servers, ${RushOrder_GuildTag2} == "Tradeskill Rush Order Agent")
		elseif ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}].ID}"
			if ${Target.Guild.Equal[${RushOrder_GuildTag2}]}
				face
			wait 10
			if (${Target.ID} <= 0)
			{
				ErrorEcho "EQ2Craft:: Unable to target Rush Order Agent (in Guildhall) -- ending script."
				Script:End
			}
			lastdevice:Set[Rushorder]
			return
		}
	}
	elseif ${devicename.Equal[Workorder]}
	{
		;; TS Instances  (For English Servers, ${WorkOrder_GuildTag} == "Work Orders")
		if ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}].ID}"
			if ${Target.Guild.Equal[${WorkOrder_GuildTag}]}
				face
			wait 10
			if (${Target.ID} <= 0)
			{
				ErrorEcho "EQ2Craft:: Unable to target Work Order Agent (in Guildhall) -- ending script."
				Script:End
			}
			lastdevice:Set[Workorder]
			return
		}
		;; Guildhalls   (For English Servers, ${WorkOrder_GuildTag2} == "Tradeskill Writ Agent")
		if ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}].ID}"
			if ${Target.Guild.Equal[${WorkOrder_GuildTag2}]}
				face
			wait 10
			if (${Target.ID} <= 0)
			{
				ErrorEcho "EQ2Craft:: Unable to target Work Order Agent (in Guildhall) -- ending script."
				Script:End
			}
			lastdevice:Set[Workorder]
			return
		}
	}
	elseif ${devicename.Equal[Broker]}
	{
		;; TS Instances  (For English Servers, ${Broker_GuildTag} == "Broker")
		if ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}].ID}"
			if ${Target.Guild.Equal[${Broker_GuildTag}]}
				face
			wait 10
			if (${Target.ID} <= 0)
			{
				ErrorEcho "EQ2Craft:: Unable to target Broker (in TS Instance) -- ending script."
				Script:End
			}
			lastdevice:Set[Broker]
			if (${Target.Distance} > 7)
			{
				press "${Nav.AUTORUN}"
				do
				{
					waitframe
				}
				while ${Target.Distance} > 7
				wait 1
				press "${Nav.AUTORUN}"
				wait 2
			}
			return
		}
		;; Guild Halls  (For English Servers, ${Broker_GuildTag2} == "Guild World Market Broker")
		elseif ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}].ID}"
			if ${Target.Guild.Equal[${Broker_GuildTag2}]}
				face
			wait 10
			if (${Target.ID} <= 0)
			{
				ErrorEcho "EQ2Craft:: Unable to target Broker (in Guildhall) -- ending script."
				Script:End
			}
			lastdevice:Set[Broker]
			if (${Target.Distance} > 7)
			{
				press "${Nav.AUTORUN}"
				do
				{
					waitframe
				}
				while ${Target.Distance} > 7
				wait 1
				press "${Nav.AUTORUN}"
				wait 2
			}
			return
		}
		;;;
		; Hack for using craft in Paineel Commons
		elseif ${Actor[xzrange,10,yrange,2,"Raml'iut"].Name(exists)} && ${Actor[xzrange,10,yrange,2,"Raml'iut"].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,"Raml'iut"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,Raml'iut].ID}"
			if ${Target.Name.Equal["Raml'iut"]}
				face
			wait 10
			lastdevice:Set[Broker]
			if (${Target.Distance} > 7)
			{
				press "${Nav.AUTORUN}"
				do
				{
					waitframe
				}
				while ${Target.Distance} > 7
				wait 1
				press "${Nav.AUTORUN}"
				wait 2
			}
			return
		}
	}
	elseif ${devicename.Equal[Wholesaler]}
	{
		if ${Actor[xzrange,10,yrange,2,${Wholesaler}].Name(exists)} && !${Me.CheckCollision[${Actor[xzrange,10,yrange,2,${Wholesaler}].Loc}]}
		{
			Actor[xzrange,10,yrange,2,${Wholesaler}]:DoTarget
			wait 10 ${Target.ID}==${Actor[xzrange,10,yrange,2,${Wholesaler}].ID}
			face
			wait 10
			lastdevice:Set[Wholesaler]
			return
		}

		Wholesalers:GetSettingIterator[Iterator]
		if ${Iterator:First(exists)}
		{
			do
			{
				if ${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Iterator.Key}].Type.Equal[NoKill NPC]} &&  !${Me.CheckCollision[${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Loc}]}
				{
					Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"]:DoTarget
					wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].ID}"
					face
					wait 10
					lastdevice:Set[Wholesaler]
					return
				}
			}
			while ${Iterator:Next(exists)}
		}
	}
	elseif ${devicename.Equal[Invoices]}
	{
		if ${Actor[xzrange,10,${WorkOrderClipboard}].Name(exists)} && ${Actor[xzrange,10,${WorkOrderClipboard}].Type.Equal[NoKill NPC]}
		{
			face "${WorkOrderClipboard}"
			lastdevice:Set[${devicename}]
			return
		}
		elseif ${Actor[xzrange,10,${WorkOrdersDesk}].Name(exists)} && ${Actor[xzrange,10,${WorkOrdersDesk}].Type.Equal[NoKill NPC]}
		{
			face "${WorkOrdersDesk}"
			lastdevice:Set[${devicename}]
			return
		}
		; No invoices available nearby, find the closest and use it
		devicenum:Set[${Nav.ClosestRegionToPoint[${Me.X}, ${Me.Y}, ${Me.Z}, "Invoices", "Invoices 1", "Invoices 2", "Invoices 3", "Invoices 4", "Invoices 5"].Token[2, " "]}]
	}
	elseif ${Actor[${ldevicename},xzrange,${DistToTable},yrange,2].Name(exists)}
	{
		if ${InGuildHall}
		{
			;; French is such a pain in the ass...
			if ${sLocalization.Equal["French"]}
			{
				if ${ldevicename.Equal["Table de couture avec un mannequin"]}
					ElaborateTable:Set["Table de couture �labor� avec un mannequin"]
				elseif ${ldevicename.Equal["Bureau poin�onn�"]}
					ElaborateTable:Set["Bureau poin�onn� �labor�"]
				elseif ${ldevicename.Equal["Cuisini�re et baril"]}
					ElaborateTable:Set["Cuisini�re et baril �labor�s"]
				elseif ${ldevicename.Equal["Etabli"]}
					ElaborateTable:Set["Etabli �labor�"]
				else
					ElaborateTable:Set["${ldevicename} �labor�e"]
			}
			else
				ElaborateTable:Set["Elaborate ${ldevicename}"]

			;; NEW ;;
			if (${ldevicename.Equal["Work Bench"]} || ${devicename.Equal["Work Bench"]})
				GuildCraftingStation:Set["Guild Crafting Station: Workbench"]
			elseif (${ldevicename.Equal["Sewing Table & Mannequin"]} || ${devicename.Equal["Sewing Table & Mannequin"]})
				GuildCraftingStation:Set["Guild Crafting Station: Loom"]
			else
				GuildCraftingStation:Set["Guild Crafting Station: ${ldevicename}"]

			if (!${Actor[ExactName,${ElaborateTable},xzrange,${DistToTable},yrange,2].CheckCollision})
			{
				Actor[ExactName,${ElaborateTable}]:DoTarget
				wait 10 "${Target.ID}==${Actor[ExactName,${ElaborateTable}].ID}"
				if ${Target.Name.Equal[${ElaborateTable}]}
				{
					face
				}
				wait 10
				lastdevice:Set[${ldevicename}]
				return
			}
			elseif (!${Actor[ExactName,${GuildCraftingStation},xzrange,${DistToTable},yrange,2].CheckCollision})
			{
				Actor[ExactName,${GuildCraftingStation}]:DoTarget
				wait 10 "${Target.ID}==${Actor[ExactName,${GuildCraftingStation}].ID}"
				if ${Target.Name.Equal[${GuildCraftingStation}]}
				{
					face
				}
				wait 10
				lastdevice:Set[${ldevicename}]
				return
			}
			elseif (!${Actor[ExactName,${ldevicename},xzrange,${DistToTable},yrange,2].CheckCollision})
			{	/* New achievement tables, no elaborate prefix, Q4 quality. */
				Actor[ExactName,${ldevicename}]:DoTarget
				wait 10 "${Target.ID}==${Actor[ExactName,Elaborate ${ldevicename}].ID}"
				if ${Target.Name.Equal[${ldevicename}]}
				{
					face
				}
				wait 10
				lastdevice:Set[${ldevicename}]
				return
			}
		}
		elseif (!${Actor[${ldevicename},xzrange,${DistToTable},yrange,2].CheckCollision})
		{
			Actor[ExactName,${ldevicename}]:DoTarget
			wait 10 "${Target.ID}==${Actor[${ldevicename}].ID}"
			if ${Target.Name.Equal[${ldevicename}]}
			{
				face
			}
			wait 10
			lastdevice:Set[${ldevicename}]
			return
		}

	}

	if ${EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Recipes](exists)}
	{
		EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Recipes]:LeftClick
		wait 20
		EQ2Execute /hide_window TradeSkills.TradeSkills
	}
	else
	{
		call Cancel
	}

	Nav.gPrecision:Set[1]
	Nav.DestinationPrecision:Set[2]

	if ${Zone.ShortName.Find[tradeskill]}
		Nav.DestinationPrecision:Set[3]

	if ${devicenum}
	{
		ChatEcho "EQ2Craft:: Moving To Device: '${devicename} ${devicenum}'"
		if ${Nav.RegionExists[${devicename} ${devicenum}]}
			Nav:MoveToRegion["${devicename} ${devicenum}"]
		else
			Debug:Echo[NAV WARNING: Missing region: ${devicename} ${devicenum}]
	}
	else
	{
		if ${Nav.RegionExists[${devicename}]}
			Nav:MoveToRegion["${devicename}"]
		else
			Debug:Echo[NAV WARNING: Missing region: ${devicename}]
	}

	;;;;;;;;;;;;;;;;;;
	;;
	do
	{
		Nav:Pulse
		wait 0
	}
	while ${ISXEQ2(exists)} && ${Nav.Moving}
	;;
	;;;;;;;;;;;;;;;;;;

	;;; Just in case....
	waitframe
	call StopRunning
	waitframe

	switch ${devicename}
	{
		case Rushorder
			;if ${Zone.ShortName.Equal[qey_tradeskill01]}
			;{
			;    press -hold "${Nav.STRAFERIGHT}"
			;	wait ${Math.Rand[5]:Inc}
			;    press -release "${Nav.STRAFERIGHT}"
			;}
			;; TS Instances  (For English Servers, ${RushOrder_GuildTag} == "Rush Orders")
			if ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag}].ID}"
				if ${Target.Guild.Equal[${RushOrder_GuildTag}]}
					face
				wait 10
				if (${Target.ID} <= 0)
				{
					ErrorEcho "EQ2Craft:: Unable to target Rush Order Agent (in TS Instance) after moving -- ending script."
					Script:End
				}
				lastdevice:Set[Rushorder]
			}
			;; Guildhalls   (For English Servers, ${RushOrder_GuildTag2} == "Tradeskill Rush Order Agent")
			elseif ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${RushOrder_GuildTag2}].ID}"
				if ${Target.Guild.Equal[${RushOrder_GuildTag2}]}
					face
				wait 10
				if (${Target.ID} <= 0)
				{
					ErrorEcho "EQ2Craft:: Unable to target Rush Order Agent (in Guildhall) after moving -- ending script."
					Script:End
				}
				lastdevice:Set[Rushorder]
			}
			break
		case Workorder
			;; TS Instances  (For English Servers, ${WorkOrder_GuildTag} == "Work Orders")
			if ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag}].ID}"
				if ${Target.Guild.Equal[${WorkOrder_GuildTag}]}
					face
				wait 10
				if (${Target.ID} <= 0)
				{
					ErrorEcho "EQ2Craft:: Unable to target Work Order Agent (in Guildhall) -- ending script."
					Script:End
				}
				lastdevice:Set[Workorder]
			}
			;; Guildhalls   (For English Servers, ${WorkOrder_GuildTag2} == "Tradeskill Writ Agent")
			if ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${WorkOrder_GuildTag2}].ID}"
				if ${Target.Guild.Equal[${WorkOrder_GuildTag2}]}
					face
				wait 10
				if (${Target.ID} <= 0)
				{
					ErrorEcho "EQ2Craft:: Unable to target Work Order Agent (in Guildhall) -- ending script."
					Script:End
				}
				lastdevice:Set[Workorder]
			}
			break
		case Broker
			;; TS Instances  (For English Servers, ${Broker_GuildTag} == "Broker")
			if ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag}].ID}"
				if ${Target.Guild.Equal[${Broker_GuildTag}]}
					face
				wait 10
				if (${Target.ID} <= 0)
				{
					ErrorEcho "EQ2Craft:: Unable to target Broker (in TS Instance) -- ending script."
					Script:End
				}
				lastdevice:Set[Broker]
				if (${Target.Distance} > 7)
				{
					press "${Nav.AUTORUN}"
					do
					{
						waitframe
					}
					while ${Target.Distance} > 7
					wait 1
					press "${Nav.AUTORUN}"
					wait 2
				}
			}
			;; Guild Halls  (For English Servers, ${Broker_GuildTag2} == "Guild World Market Broker")
			elseif ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,${Broker_GuildTag2}].ID}"
				if ${Target.Guild.Equal[${Broker_GuildTag2}]}
					face
				wait 10
				if (${Target.ID} <= 0)
				{
					ErrorEcho "EQ2Craft:: Unable to target Broker (in Guildhall) -- ending script."
					Script:End
				}
				lastdevice:Set[Broker]
				if (${Target.Distance} > 7)
				{
					press "${Nav.AUTORUN}"
					do
					{
						waitframe
					}
					while ${Target.Distance} > 7
					wait 1
					press "${Nav.AUTORUN}"
					wait 2
				}
			}
			;;;
			; Hack for using craft in Paineel Commons
			elseif ${Actor[xzrange,10,yrange,2,"Raml'iut"].Name(exists)} && ${Actor[xzrange,10,yrange,2,"Raml'iut"].Type.Equal[NoKill NPC]}
			{
				Actor[xzrange,15,yrange,2,"Raml'iut"]:DoTarget
				wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,Raml'iut].ID}"
				face
				wait 2
			}
			break
		case Wholesaler
			; coming down those stairs blows...
			wait 4
			if ${Actor[xzrange,10,yrange,2,${Wholesaler}].Name(exists)}
			{
				Actor[xzrange,10,yrange,2,${Wholesaler}]:DoTarget
				wait 10 ${Target.ID}==${Actor[xzrange,10,yrange,2,${Wholesaler}].ID}
				face
			}
			else
			{
				Wholesalers:GetSettingIterator[Iterator]
				if ${Iterator:First(exists)}
				{
					do
					{
						Debug:Echo[Wholesaler Iterator key = ${Iterator.Key}]
						if ${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Iterator.Key}].Type.Equal[NoKill NPC]}
						{
							Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"]:DoTarget
							wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].ID}"
							break
						}
					}
					while ${Iterator:Next(exists)}
				}
			}
			face
			wait 2
			if (${lastdevice.Equal[Broker]} || ${lastdevice.Equal[Rushorder]} || ${lastdevice.Equal[Workorder]})
			{
				if ${Zone.ShortName.Equal[qey_tradeskill01]}
				{
					if ${Me.Speed} < 50
					{
						press -hold "${Nav.STRAFELEFT}"
						wait ${Math.Calc[4-${Me.Speed}/100*4]}
						press -release "${Nav.STRAFELEFT}"
						wait 1
						press -hold "${Nav.MOVEFOWARD}"
						wait ${Math.Calc[5-${Me.Speed}/100*5]}
						press -release "${Nav.MOVEFORWARD}"
						wait 1
					}
				}
			}
			wait 1
			face
			wait 1
			break
		case Invoices
			if ${Actor[xzrange,10,${WorkOrderClipboard}].Name(exists)}
			{
				face "${WorkOrderClipboard}"
				lastdevice:Set[${devicename}]
			}
			elseif ${Actor[xzrange,10,${WorkOrdersDesk}].Name(exists)}
			{
				face "${WorkOrdersDesk}"
				lastdevice:Set[${devicename}]
			}
			break
		default
			if ${InGuildHall}
			{
				;; French is such a pain in the ass...
				if ${sLocalization.Equal["French"]}
				{
					if ${ldevicename.Equal["Table de couture avec un mannequin"]}
						ElaborateTable:Set["Table de couture �labor� avec un mannequin"]
					elseif ${ldevicename.Equal["Bureau poin�onn�"]}
						ElaborateTable:Set["Bureau poin�onn� �labor�"]
					elseif ${ldevicename.Equal["Cuisini�re et baril"]}
						ElaborateTable:Set["Cuisini�re et baril �labor�s"]
					elseif ${ldevicename.Equal["Etabli"]}
						ElaborateTable:Set["Etabli �labor�"]
					else
						ElaborateTable:Set["${devicename} �labor�e"]
				}
				else
					ElaborateTable:Set["Elaborate ${devicename}"]

				;; NEW ;;
				if (${ldevicename.Equal["Work Bench"]} || ${devicename.Equal["Work Bench"]})
					GuildCraftingStation:Set["Guild Crafting Station: Workbench"]
				elseif (${ldevicename.Equal["Sewing Table & Mannequin"]} || ${devicename.Equal["Sewing Table & Mannequin"]})
					GuildCraftingStation:Set["Guild Crafting Station: Loom"]
				else
					GuildCraftingStation:Set["Guild Crafting Station: ${ldevicename}"]

				Actor[ExactName,${ElaborateTable}]:DoTarget
				wait 10 "${Target.ID}==${Actor[ExactName,${ElaborateTable}].ID}"

				if !${Target.Name.Equal[${ElaborateTable}]}
				{
					Actor[ExactName,${ldevicename}]:DoTarget
					wait 10 "${Target.ID}==${Actor[ExactName,${ldevicename}].ID}"
				}
				else
				{
					Actor[ExactName,${GuildCraftingStation}]:DoTarget
					wait 10 "${Target.ID}==${Actor[ExactName,${GuildCraftingStation}].ID}"
					if !${Target.Name.Equal[${GuildCraftingStation}]}
					{
						Actor[ExactName,${GuildCraftingStation}]:DoTarget
						wait 10 "${Target.ID}==${Actor[ExactName,${GuildCraftingStation}].ID}"
					}
				}
			}
			else
			{
				Actor[${ldevicename}]:DoTarget
				wait 10 "${Target.ID}==${Actor[${ldevicename}].ID}"
				if !${Target.Name.Equal[${ldevicename}]}
				{
					Actor[ExactName,${ldevicename}]:DoTarget
					wait 10 "${Target.ID}==${Actor[ExactName,${ldevicename}].ID}"
				}
			}
			face
			wait 2
			break
	}
	lastdevice:Set[${devicename}]

	if (${Target.CheckCollision})
		ChatEcho "EQ2Craft:: Collision detected between you and ${Target} -- Handle it?? ..does it matter??"

	waitframe

	if ${Me.IsMoving}
	{
		call StopRunning
		waitframe
	}

	/* No need for perfect precision when dealing with NPC "devices". Only be precise on tradeskill units. */
	/* I know it's a bit odd to have 2 switches for the same thing, but this is actually a cleaner way to do this. */
	switch ${devicename}
	{
		case Wholesaler
		case Workorder
		case Rushorder
		case Broker
		case Invoices
			break
		default
			/* Reversed these. Now if we somehow overshoot "move away," we will have a chance to get closer. */
			if (${Target.Distance} < ${Nav.DestinationPrecision} - 1 && ${Target.Type.Equal[Tradeskill Unit]})
			{
				press -hold "${Nav.MOVEBACKWARD}"
				do
				{
					waitframe
				}
				while ${Target.Distance} < ${Nav.DestinationPrecision} -1
				press -release "${Nav.MOVEBACKWARD}"
				waitframe
				; just in case...
				press -release "${Nav.MOVEBACKWARD}"
				waitframe
			}
			if (${Target.Distance} > ${Nav.DestinationPrecision} + 1 )
			{
				press "${Nav.AUTORUN}"
				do
				{
					waitframe
				}
				while ${Target.Distance} > ${Nav.DestinationPrecision} +1

				waitframe
				call StopRunning
			}
	}
	;;; Just in case....
	if (${Me.IsMoving})
		call StopRunning
	wait 1
}

function ProcessArts()
{
	variable int tempvar

	tempkey:Set[1]
	tempdur:Set[((${CurrentDurability}/${TotalDurability}*100)-80)/20*100]

	if ${MakeRare}
	{
		tempvar:Set[2]
	}
	else
	{
		tempvar:Set[1]
	}

	if ${tempdur}>${Durability[${tempvar},2]}
	{
		call ProgressCombo
	}
	else
	{
		call DurabilityCombo
	}
}

function ProcessSecondaryArts()
{
	variable int temppower

	tempdur:Set[${CurrentDurability}/${TotalDurability}*100]
	temppower:Set[${Me.Power}/${Me.MaxPower}*100]

	; Determine which Power Buff to cast
	if ${tempdur}>90 && ${CurrentQuality}==3 && ${temppower}>40
	{
		call CastSecondaryReaction 3
	}
	elseif ${tempdur}>85
	{
		call CastSecondaryReaction 1
	}

	; Determine which Durability Buff to cast
	if (${tempdur}<95 && ${temppower}>20) || ${temppower}>80
	{
		call CastSecondaryReaction 4
	}
	else
	{
		call CastSecondaryReaction 2
	}
}

function CastSecondaryReaction(int xability)
{
	do
	{
		if ${roundstart}
		{
			return
		}
	}
	while !${Me.Ability[${SecondarySkill[${xability}]}].IsReady}

	Me.Ability[${SecondarySkill[${xability}]}]:Use
}

function InitialRound()
{
	tempkey:Set[1]
	do
	{
		call CastReaction 1 ${tempkey}
	}
	while ${tempkey:Inc}<=3
}

function ProgressCombo()
{
	variable int tempvar
	if ${MakeRare}
	{
		tempvar:Set[2]
	}
	else
	{
		tempvar:Set[1]
	}

	do
	{
		call CastReaction 1 ${tempkey}
	}
	while ${tempkey:Inc}<=2

	if ${tempdur}<${Durability[${tempvar},1]} && ${Me.Power}/${Me.MaxPower}*100>${Durability[${tempvar},3]}
	{
		call CastReaction 2 3
	}
	elseif ${Me.Power}/${Me.MaxPower}*100>${Durability[${tempvar},3]}
	{
		call CastReaction 1 3
	}
}

function DurabilityCombo()
{
	variable int tempvar
	if ${MakeRare}
	{
		tempvar:Set[2]
	}
	else
	{
		tempvar:Set[1]
	}

	do
	{
		call CastReaction 2 ${tempkey}
	}
	while ${tempkey:Inc}<=2

	if ${tempdur}<${Durability[${tempvar},2]} && ${Me.Power}/${Me.MaxPower}*100>${Durability[${tempvar},3]}
	{
		call CastReaction 2 3
	}
}

function BalanceCombo()
{
	variable int tempvar
	if ${MakeRare}
	{
		tempvar:Set[2]
	}
	else
	{
		tempvar:Set[1]
	}

	if ${Math.Rand[100]}>50
	{
		call CastReaction 1 1
		call CastReaction 2 2
	}
	else
	{
		call CastReaction 2 1
		call CastReaction 1 2
	}

	if ${Me.Power}/${Me.MaxPower}*100>${Durability[${tempvar},3]}
	{
		call CastReaction ${Math.Rand[2]:Inc} 3
	}
}

function Begin()
{
	; ${EQ2UIPage[Tradeskills,Tradeskills].Child[DropDownBox,Tradeskills.TabPages.Craft.Prepare.SummaryPage.QtyDropdown]}
	; ${EQ2UIPage[mainhud,guild].Child[DropDownBox,Guild.MainTabPage.MembersPage.ShowMemberSelection].Type}
	wait 10
	EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Prepare.SummaryPage.BeginButton]:LeftClick
	wait 15 "${EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Stop](exists)}"
	wait 5
	Craft:EnableReactions
}

function Repeat()
{
	wait 15
	EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Create.Repeat]:LeftClick
	wait 15 "${EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Prepare.SummaryPage.BeginButton](exists)}"
	wait 10
}

function Cancel()
{
	wait 20
	EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.TabPages.Craft.Prepare.SummaryPage.CancelButton]:LeftClick
	wait 20
	EQ2Execute /hide_window TradeSkills.TradeSkills
	Craft:DisableReactions
}

function CastReaction(int xability, int xtimer)
{
	variable uint skilltimer=${Script.RunningTime}

	do
	{
		if ${roundstart}
		{
			return
		}

		if ${Script.RunningTime}-${skilltimer}>${xtimer}*1900
		{
			return
		}
	}
	while !${Me.Ability[${TSSpell[${xability},${xtimer}]}].IsReady}

	Me.Ability[${TSSpell[${xability},${xtimer}]}]:Use

	wait 5 ${Me.Maintained[${TSSpell[${xability},${xtimer}]}](exists)}
}

function ProcessQueue()
{
	variable int tempvar
	variable int tempvar2
	variable string tmpqueue

	Craft:ClearAllRecipes[1]

	UIElement[Craft Selection].FindUsableChild[Submit Button,commandbutton]:Hide
	UIElement[Craft Selection].FindUsableChild[Save Recipe Queue,commandbutton]:Hide
	UIElement[Craft Selection].FindUsableChild[Clear Recipe Queue,commandbutton]:Hide
	UIElement[Craft Selection].FindUsableChild[List Recipe,variablegauge]:Show
	UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:Show

	tempvar:Set[0]
	while ${tempvar:Inc}<=${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Items}
	{
		UIElement[Craft Selection].FindUsableChild[Craft List,listbox].OrderedItem[${tempvar}]:SetTextColor[FF22FF22]
		tmpqueue:Set[${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].OrderedItem[${tempvar}]}]
		QueueList[${tempvar}]:Set[${tmpqueue.Token[1,|]}]
		QueueQty[${tempvar}]:Set[${tmpqueue.Token[2,|]}]
	}

	tempvar:Set[0]

	queuecnt:Set[${Math.Calc[${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Items}]}]

	while ${tempvar:Inc}<=${queuecnt}
	{
		tmpqueue:Set[${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].OrderedItem[${tempvar}]}]
		QueueList[${tempvar}]:Set[${tmpqueue.Token[1,|]}]
		QueueQty[${tempvar}]:Set[${tmpqueue.Token[2,|]}]

		UIElement[Craft Selection].FindUsableChild[Craft List,listbox].OrderedItem[${tempvar}]:SetTextColor[FF22FF22]
		UIElement[Craft Selection].FindUsableChild[Craft List,listbox].OrderedItem[${tempvar}]:SetTextColor[FFFF5F00]
		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:SetText[Processing ${tempvar} of ${queuecnt} Recipes..]
		gaugelevel:Set[0.05]
		gaugefactor:Set[1]

		QOverride:Set[4]

		tempvar2:Set[0]
		while ${tempvar2:Inc}<5
		{
			if ${Quality${tempvar2}}
			{
				MainRecipe:Set[${QueueList[${tempvar}]}]
				gaugelevel:Set[0.2]
				Craft:ProcessRecipe[${MainRecipe},${tempvar2},${QueueQty[${tempvar}]}]
				Craft:CalculateComponents
				gaugelevel:Set[0.9]
				;call CheckInventory
				gaugelevel:Set[1]
				break
			}
		}
	}

	UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:SetText[Processing inventory...]

	call CheckInventory
	wait 2

	UIElement[Craft Selection].FindUsableChild[List Recipe,variablegauge]:Hide
	UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:Hide
	UIElement[Craft Selection].FindUsableChild[Submit Button,commandbutton]:Show
	UIElement[Craft Selection].FindUsableChild[Save Recipe Queue,commandbutton]:Show
	UIElement[Craft Selection].FindUsableChild[Clear Recipe Queue,commandbutton]:Show
	UIElement[Craft Selection].FindUsableChild[Crafting List Frame,frame]:Hide
	UIElement[Craft Selection].FindUsableChild[Craft Main,tabcontrol].Tab[1]:Select
	UIElement[Craft Selection].FindUsableChild[Start Crafting,commandbutton]:Show
	UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Show
	wait 1
	Craft:InitGUI
	thisbuttonsubmit:Set[0]
}

function SaveQueueList()
{
	InputBox "Enter a name for this Recipe Queue List"
	Craft:SaveQueue[${UserInput}]
}

function ProcessTriggers()
{
	if !${checkinv}
	{
		FlushQueued Craft:InventoryUpdate
	}

	if ${QueuedCommands}
	{
		do
		{
			FlushQueued ISXEQ2:SetCustomVariable
			FlushQueued ISXEQ2.GetCustomVariable
			ExecuteQueued
		}
		while ${QueuedCommands}
	}
}

function BuyComponents()
{
	variable int tcount=1
	variable int xvar
	variable int buyqty
	variable int stackmaximum
	variable int stackcount
	variable int stackremaining
	variable int tempvar

	if !(${BuyCommon} && ${Craft.PurchaseCommon}) && !(${BuyFuel} && ${Craft.PurchaseFuel})
	{
		return
	}

	call MovetoDevice "Wholesaler"
	; Moveto should do the targetting and facing now
	wait 5

	if (${Target.ID} <= 0)
	{
		Wholesalers:GetSettingIterator[Iterator]
		if ${Iterator:First(exists)}
		{
			do
			{
				if ${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Iterator.Key}].Type.Equal[NoKill NPC]}
				{
					Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"]:DoTarget
					wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].ID}"
					face
					wait 10
					lastdevice:Set[Wholesaler]
					return
				}
			}
			while ${Iterator:Next(exists)}
		}
	}

	Target:DoubleClick
	wait 10

	if ${BuyCommon}
	{
		xvar:Set[0]
		while ${xvar:Inc}<=${comcnt}
		{
			buyqty:Set[${Math.Calc[${StatComCnt[${xvar}]}-${StatComTot[${xvar}]}]}]
			stackmaximum:Set[${VendorBought.FindSetting[${StatComNme[${xvar}]}]}]
			stackcount:Set[${Math.Abs[${buyqty}/${stackmaximum}]}]
			stackremaining:Set[${Math.Calc[${buyqty}-(${stackmaximum}*${stackcount})]}]

			if ${buyqty}
			{
				tempvar:Set[0]
				while ${tempvar:Inc}<=${stackcount}
				{
					MerchantWindow.MerchantInventory[${StatComNme[${xvar}]}]:Buy[${stackmaximum}]
					wait 10
					call CheckInventory
					Craft:InitGUI
				}

				if ${stackremaining}
				{
					MerchantWindow.MerchantInventory[${StatComNme[${xvar}]}]:Buy[${stackremaining}]
					wait 10
					call CheckInventory
					Craft:InitGUI
				}
			}
		}

		wait 15
		call CheckInventory
		Craft:InitGUI
		if ${NotEnoughCoin}
		{
			NotEnoughCoin:Set[FALSE]
			call WaitForResume "Not all COMMONS have been bought. Click Resume Crafting."
		}
	}

	if ${BuyFuel}
	{
		xvar:Set[0]
		while ${xvar:Inc}<=${fuelcnt}
		{
			buyqty:Set[${StatFuelCnt[${xvar}]}-${StatFuelTot[${xvar}]}]
			stackmaximum:Set[200]
			stackcount:Set[${Math.Abs[${buyqty}/${stackmaximum}]}]
			stackremaining:Set[${buyqty}-(${stackmaximum}*${stackcount})]

			if ${buyqty}
			{
				tempvar:Set[0]
				while ${tempvar:Inc}<=${stackcount}
				{
					MerchantWindow.MerchantInventory[${StatFuelNme[${xvar}]}]:Buy[${stackmaximum}]
					wait 10
					call CheckInventory
					Craft:InitGUI
				}

				if ${stackremaining}
				{
					MerchantWindow.MerchantInventory[${StatFuelNme[${xvar}]}]:Buy[${stackremaining}]
					wait 10
					call CheckInventory
					Craft:InitGUI
				}
			}
		}

		wait 15
		call CheckInventory
		Craft:InitGUI
		if ${NotEnoughCoin}
		{
			NotEnoughCoin:Set[FALSE]
			call WaitForResume "Not all FUELS have been bought. Click Resume Crafting."
		}
	}

	wait 10

	EQ2UIPage[Inventory,Merchant].Child[button,Merchant.WindowFrame.Close]:LeftClick
	;For FetishUI
	EQ2UIPage[Inventory,Merchant].Child[button,Merchant.WC_CloseButton]:LeftClick
}

function BuyHarvests()
{
	variable int tcount=1
	variable int xvar=1
	variable int buyqty
	variable int tempvar1
	variable int tempvar2
	variable int Attempts = 0
	variable int CurrentQuantity

	if !${Craft.PurchaseHarvest}
		return

	call MovetoDevice "Broker"
	; Moveto should do the targetting and facing now

	if (${Target.ID} <= 0)
		Actor[xzrange,15,yrange,2,guild,${Broker_GuildTag}]:DoTarget
	waitframe

	if (${Target.Distance} > 7)
	{
		press "${Nav.AUTORUN}"
		do
		{
			waitframe
		}
		while ${Target.Distance} > 7
		wait 1
		press "${Nav.AUTORUN}"
		wait 2
	}

	Target:DoubleClick
	wait 5

	xvar:Set[1]
	do
	{
		buyqty:Set[${Math.Calc[${StatResCnt[${xvar}]}-${StatResTot[${xvar}]}]}]
		if ${buyqty}
		{
			wait 10
			broker name "${StatResNme[${xvar}]}" Sort ByPriceAsc MaxPrice ${Math.Calc[${MaxBuyPrice}*100]}
			wait 20
			wait 30 ${BrokerWindow.SearchResult[1](exists)}

			if ${BrokerWindow.NumSearchResults}
			{
				tempvar1:Set[1]
				do
				{
					if !${buyqty}
						break

					if ${tempvar1}>1
					{
						BrokerWindow:GotoSearchPage[${tempvar1}]
						wait 20
						wait 30 ${BrokerWindow.SearchResult[1](exists)}
					}

					tempvar2:Set[1]
					do
					{
						if !${buyqty}
							break

						if ${BrokerWindow.SearchResult[${tempvar2}].Name.Equal[${StatResNme[${xvar}]}]}
						{
							while ${buyqty}>0
							{
								if ${buyqty}<=${BrokerWindow.SearchResult[${tempvar2}].Quantity}
								{
									if ${buyqty}>200
									{
				            			CurrentQuantity:Set[${BrokerWindow.SearchResult[${tempvar2}].Quantity}]
										buyqty:Dec[200]
										BrokerWindow.SearchResult[${tempvar2}]:Buy[200]
										wait 200 ${BrokerWindow.SearchResult[${tempvar2}].Quantity} != ${CurrentQuantity}
										call CheckInventory
										Craft:InitGUI
									}
									else
									{
										CurrentQuantity:Set[${BrokerWindow.SearchResult[${tempvar2}].Quantity}]
										BrokerWindow.SearchResult[${tempvar2}]:Buy[${buyqty}]
										wait 200 ${BrokerWindow.SearchResult[${tempvar2}].Quantity} != ${CurrentQuantity}
										buyqty:Set[0]
										call CheckInventory
										Craft:InitGUI
									}
									break
								}
								else
								{
									if ${buyqty}>200
									{
				            			CurrentQuantity:Set[${BrokerWindow.SearchResult[${tempvar2}].Quantity}]
										buyqty:Dec[200]
										BrokerWindow.SearchResult[${tempvar2}]:Buy[200]
										wait 200 ${BrokerWindow.SearchResult[${tempvar2}].Quantity} != ${CurrentQuantity}
										call CheckInventory
										Craft:InitGUI
									}
									else
									{
										CurrentQuantity:Set[${BrokerWindow.SearchResult[${tempvar2}].Quantity}]
										BrokerWindow.SearchResult[${tempvar2}]:Buy[${CurrentQuantity}]
										wait 200 ${BrokerWindow.SearchResult[${tempvar2}].Quantity} != ${CurrentQuantity}
										buyqty:Dec[${CurrentQuantity}]
										call CheckInventory
										Craft:InitGUI
									}
									break
								}
							}
						}
					}
					while ${tempvar2:Inc}<=${BrokerWindow.NumSearchResults}
				}
				while ${tempvar1:Inc}<=${BrokerWindow.TotalSearchPages}
			}
		}
		; CheckInventory() should be called after each purchase above -- now we check again to see if we are ok ...we will make 3 attempts before giving up.
		buyqty:Set[${Math.Calc[${StatResCnt[${xvar}]}-${StatResTot[${xvar}]}]}]
		if (${buyqty} <= 0 || ${Attempts} >= 3)
		{
			if ${Attempts} >= 3
			{
				ChatEcho "EQ2Craft:: Attempted to buy '${StatResNme[${xvar}]}' from broker three times -- giving up."
				ChatEcho "EQ2Craft:: This is often caused by not having the mouse over the location where the broker window appears when running Craft."
				ChatEcho "EQ2Craft:: (Users are also encouraged to have plenty of harvestables on-hand to avoid having to buy them from the broker at all.)"
			}
			Attempts:Set[0]
			xvar:Inc
			continue
		}
		else
		{
			Attempts:Inc
			continue
		}
	}
	while ${xvar}<=${rescnt}

	wait 5
	call CheckInventory
	Craft:InitGUI
	wait 10

	if ${PromptResume}
	{
		xvar:Set[1]
		do
		{
			buyqty:Set[${Math.Calc[${StatResCnt[${xvar}]}-${StatResTot[${xvar}]}]}]
			if ${buyqty}
			{
				call WaitForResume "Not all HARVESTS have been bought. Click Resume Crafting."
				break
			}
		}
		while ${xvar:Inc}<=${rescnt}
	}

	EQ2UIPage[Inventory,Market].Child[button,Market.WindowFrame.Close]:LeftClick
	EQ2UIPage[Inventory,Market].Child[button,Market.WC_CloseButton]:LeftClick
}

function WaitForResume(string ResumeMsg)
{
	resumecraft:Set[FALSE]

	ErrorEcho "${ResumeMsg}"
	UIElement[Craft Selection].FindUsableChild[Resume Crafting,commandbutton]:Show
	UIElement[Craft Selection].FindUsableChild[Resume Label,text]:SetText["${ResumeMsg}"]:Show

	checkinv:Set[TRUE]
	do
	{
		call ProcessTriggers
		if (${EQ2.Zoning} != 0)
		{
			do
			{
				wait 20
			}
			while (${EQ2.Zoning} != 0)
			wait 20
		}

		if ${invupdate}
		{
			wait 4
			call CheckInventory
			Craft:InitGUI
			invupdate:Set[FALSE]
		}
	}
	while !${resumecraft}

	UIElement[Craft Selection].FindUsableChild[Resume Crafting,commandbutton]:Hide
	UIElement[Craft Selection].FindUsableChild[Resume Label,text]:Hide
}

atom atexit()
{
	declare tempvar int local

	if !${ISXEQ2.IsReady}
	{
		return
	}

	if ${Me.IsMoving}
		press ${Nav.MOVEBACKWARD}

	LavishSettings[Craft Config File].FindSet[General Options]:Sort
	LavishSettings[Craft Config File]:Export[${configfile}]
	LavishSettings[Craft Config File]:Clear
	LavishSettings[Common File]:Clear
	LavishSettings[Resource File]:Clear
	LavishSettings[Skills]:Clear
	LavishSettings[Reaction Arts]:Clear
	LavishSettings[Writ File]:Clear
	LavishSettings[WritCount File]:Clear

	ui -unload "${UIPath}CraftGUI.xml"

	Event[EQ2_onQuestUpdate]:DetachAtom[EQ2_onQuestUpdate]
	Event[EQ2_onChoiceWindowAppeared]:DetachAtom[EQ2_onChoiceWindowAppeared]
	Craft:DisableReactions /* safe due to keeping internal var for attached/detatched */
	Event[EQ2_onInventoryUpdate]:DetachAtom[EQ2_onInventoryUpdate]
	Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]
	Event[EQ2_onQuestOffered]:DetachAtom[EQ2_onQuestOffered]

	deletevariable ICraft

	Craft:DoIgnores[FALSE]

	if ${GuildPrivacy} || ${GuildPrivacyAlways}
	{
		if ${GuildPrivacySet} && ${Me.GuildPrivacyOn} && !${GuildPrivacySetting}
			eq2execute "guild event_privacy false"
	}
}

objectdef _CraftInterface
{
	member:string Version()
	{
		return ${CraftVersion}
	}
	member:int TotalQueued()
	{
		return ${TotalQueued}
	}
	method StartRO()
	{
		if (${UIElement[Craft Selection].FindUsableChild[Create Rush Order,commandbutton].MouseOver} && !(${Mouse.X} == ${ROX} && ${Mouse.Y} == ${ROY}))
		{
			ROX:Set[${Mouse.X}]
			ROY:Set[${Mouse.Y}]
			Global:AddSetting[NavSettings,"${ROX}|${ROY}|${WOX}|${WOY}"]
			Global:Export[${globalfile}]
			UIElement[CraftLite@Titlebar@Craft Selection]:Hide
			ISXEQ2:SetCustomVariable[SRO,1]
		}
		else
		{
			; getting rid of the error message for now...
			Script:End
		}
	}
	method StartWO()
	{
		if (${UIElement[Craft Selection].FindUsableChild[Create Work Order,commandbutton].MouseOver} && !(${Mouse.X} == ${WOX} && ${Mouse.Y} == ${WOY}))
		{
			WOX:Set[${Mouse.X}]
			WOY:Set[${Mouse.Y}]
			Global:AddSetting[NavSettings,"${ROX}|${ROY}|${WOX}|${WOY}"]
			Global:Export[${globalfile}]
			UIElement[CraftLite@Titlebar@Craft Selection]:Hide
		}
		else
		{
			; getting rid of the error message for now...
			Script:End
		}
	}
	method SetKeys()
	{
		if (${UIElement[Craft Selection].FindUsableChild[TEAutoRunKey,textentry](exists)} && !${UIElement[Craft Selection].FindUsableChild[TEAutoRunKey,textentry].Text.Equal[NULL]})
			AutoRunKey:Set[${UIElement[Craft Selection].FindUsableChild[TEAutoRunKey,textentry].Text}]
		else
		{
			AutoRunKey:Set[${Global.FindSetting[AutoRun Key,"num lock"]}]
			if (${AutoRunKey.Equal[NULL]})
				AutoRunKey:Set["num lock"]
		}

		if (${UIElement[Craft Selection].FindUsableChild[TEBackwardKey,textentry].Text(exists)} && !${UIElement[Craft Selection].FindUsableChild[TEBackwardKey,textentry].Text.Equal[NULL]})
			BackwardKey:Set[${UIElement[Craft Selection].FindUsableChild[TEBackwardKey,textentry].Text}]
		else
		{
			BackwardKey:Set[${Global.FindSetting[Backwards Key,"s"]}]
			if (${BackwardKey.Equal[NULL]})
				BackwardKey:Set["s"]
		}

		if (${UIElement[Craft Selection].FindUsableChild[TEStrafeRightKey,textentry](exists)} && !${UIElement[Craft Selection].FindUsableChild[TEStrafeRightKey,textentry].Text.Equal[NULL]})
			StrafeRightKey:Set[${UIElement[Craft Selection].FindUsableChild[TEStrafeRightKey,textentry].Text}]
		else
		{
			StrafeRightKey:Set[${Global.FindSetting[StrafeRight Key,"e"]}]
			if (${StrafeRightKey.Equal[NULL]})
				StrafeRightKey:Set["e"]
		}

		if (${UIElement[Craft Selection].FindUsableChild[TEStrafeLeftKey,textentry].Text(exists)} && !${UIElement[Craft Selection].FindUsableChild[TEStrafeLeftKey,textentry].Text.Equal[NULL]})
			StrafeLeftKey:Set[${UIElement[Craft Selection].FindUsableChild[TEStrafeLeftKey,textentry].Text}]
		else
		{
			StrafeLeftKey:Set[${Global.FindSetting[StrafeLeft Key,"q"]}]
			if (${StrafeLeftKey.Equal[NULL]})
				StrafeLeftKey:Set["q"]
		}

		;echo "ICraft::SetKeys() -- '${AutoRunKey}' - '${BackwardKey}' - '${StrafeRightKey}' - '${StrafeLeftKey}'"

		Craft:UpdateNavKeys
		Global:AddSetting[AutoRun Key,${AutoRunKey}]
		Global:AddSetting[Backwards Key,${BackwardKey}]
		Global:AddSetting[StrafeRight Key,${StrafeRightKey}]
		Global:AddSetting[StrafeLeft Key,${StrafeLeftKey}]
		Global:Export[${globalfile}]
	}
	variable _CraftSearch Search
}

objectdef EQ2Craft
{
	variable bool AtomAttached=FALSE
	method EnableReactions()
	{
		if !${AtomAttached}
		{
			Event[EQ2_onCraftRoundResult]:AttachAtom[EQ2_onCraftRoundResult]
			AtomAttached:Set[TRUE]
		}
	}
	method DisableReactions()
	{
		if ${AtomAttached}
		{
			Event[EQ2_onCraftRoundResult]:DetachAtom[EQ2_onCraftRoundResult]
			AtomAttached:Set[FALSE]
		}
	}
	method InitConfig()
	{
		variable int tempvar
		variable int templevel=1

		configfile:Set[${ConfigPath}${Me.Name}.xml]
		skillsfile:Set[${RecipePath}Skills.xml]
		rafile:Set[${RecipePath}ReactionArts.xml]
		commonfile:Set[${RecipePath}Common.xml]
		resourcefile:Set[${RecipePath}Resources.xml]
		writfile:Set[${RecipePath}CustomWrits.xml]
		writcountfile:Set[${RecipePath}WritCounts.xml]
		globalfile:Set[${ConfigPath}GlobalSettings.xml]

		LavishSettings:AddSet[Craft Config File]
		LavishSettings[Craft Config File]:Clear

		LavishSettings[Craft Config File]:AddSet[General Options]
		;LavishSettings[Craft Config File]:AddSet[Recipe Favourites]
		;LavishSettings[Craft Config File].FindSet[Recipe Favourites]:AddSet[Last Saved Queue List]
		LavishSettings:AddSet[Skills]
		LavishSettings:AddSet[Reaction Arts]
		LavishSettings:AddSet[Common File]
		LavishSettings:AddSet[Resource File]
		LavishSettings:AddSet[Writ File]
		LavishSettings:AddSet[WritCount File]
		LavishSettings:AddSet[CraftQueue]
		LavishSettings:AddSet[CraftGlobal]
		LavishSettings[CraftGlobal]:Clear

		LavishSettings[Craft Config File]:Import[${configfile}]
		LavishSettings[Common File]:Import[${commonfile}]
		LavishSettings[Resource File]:Import[${resourcefile}]
		LavishSettings[Skills]:Import[${skillsfile}]
		LavishSettings[Reaction Arts]:Import[${rafile}]
		LavishSettings[Writ File]:Import[${writfile}]
		if ${AllowWritSort}
		{
			LavishSettings[Writ File].FindSet[Custom Writ Names]:Sort
			LavishSettings[Writ File]:Export[${writfile}]
		}
		LavishSettings[WritCount File]:Import[${writcountfile}]
		LavishSettings[CraftGlobal]:Import[${globalfile}]

		Configuration:Set[${LavishSettings[Craft Config File].FindSet[General Options]}]
		Global:Set[${LavishSettings[CraftGlobal]}]
		RecipeFavourites:Set[${LavishSettings[Craft Config File].FindSet[Recipe Favourites]}]
		LastSavedQueue:Set[${RecipeFavourites.FindSet[Last Saved Queue List]}]
		Harvests:Set[${LavishSettings[Resource File].FindSet[Harvest List]}]
		TradeSkillType:Set[${LavishSettings[Common File].FindSet[Tradeskill Type]}]
		VendorBought:Set[${LavishSettings[Common File].FindSet[List of Vendor bought Components]}]
		QualityPrefix:Set[${LavishSettings[Common File].FindSet[Quality Prefixes]}]
		Rares:Set[${LavishSettings[Common File].FindSet[List of Rares]}]
		WritRecipes:Set[${LavishSettings[Writ File].FindSet[Custom Writ Names]}]
		WritCounts:Set[${LavishSettings[WritCount File].FindSet[Writ Counts]}]
		Wholesalers:Set[${LavishSettings[Common File].FindSet[Wholesalers]}]
		CraftQueue:Set[${LavishSettings[CraftQueue]}]

		SortLevel:Set[${Configuration.FindSetting[Default Sort Order by Name?,TRUE]}]
		CampOut:Set[${Configuration.FindSetting[Camp out after a 2+ hour Session once crafting has finished?,TRUE]}]
		CampNow:Set[${Configuration.FindSetting[Camp out after Craft Session is complete?,FALSE]}]
		CampTimer:Set[${Configuration.FindSetting[Camp out after a specified time has elapsed for a crafting session?,120]}]
		ShowAllLists:Set[${Configuration.FindSetting[Display entire shopping list?,FALSE]}]
		CurrentStation:Set[${Configuration.FindSetting[Use the current TARGETTED Station only?,FALSE]}]
		SaveList:Set[${Configuration.FindSetting[Save Recipe List when Crafting Begins?,TRUE]}]
		BuyCommon:Set[${Configuration.FindSetting[Buy ALL Vendor bought components automatically?,FALSE]}]
		BuyFuel:Set[${Configuration.FindSetting[Buy ALL FUEL components automatically?,FALSE]}]
		BuyHarvest:Set[${Configuration.FindSetting[Buy ALL Harvests from Broker automatically?,FALSE]}]
		MaxBuyPrice:Set[${Configuration.FindSetting[Specify the MAXIMUM price for purchasing Resources,5]}]
		WritCount:Set[${Configuration.FindSetting[How many Writs to create per craft session?,25]}]
		WritQty:Set[${Configuration.FindSetting[How many Recipes per Writ?,10]}]
		Tier:Set[${Configuration.FindSetting[Which Writ Tier to use?,1]}]
		PromptResume:Set[${Configuration.FindSetting[Prompt Resume Crafting when buying Harvests?,TRUE]}]
		SecondaryTS:Set[${Configuration.FindSetting[Show only Secondary Tradeskill Recipes?,FALSE]}]
		StandardFilter:Set[${Configuration.FindSetting[Show All Standard Recipes?,TRUE]}]
		ImbuedFilter:Set[${Configuration.FindSetting[Show All Imbued Recipes?,TRUE]}]
		RareFilter:Set[${Configuration.FindSetting[Show All Rare Recipes?,TRUE]}]
		WaitforPower:Set[${Configuration.FindSetting[Wait for Power to Regenerate before crafting a recipe?,FALSE]}]
		PowerRegen:Set[${Configuration.FindSetting[Amount of Power to Regenerate before crafting a recipe?,80]}]
		CraftDelay:Set[${Configuration.FindSetting[Time to wait between combines?,0]}]
		PathPrecision:Set[${Configuration.FindSetting[Pather Precision,1.5]}]
		DeclineInvites:Set[${Configuration.FindSetting[Decline Invites,TRUE]}]
		EnableTTS:Set[${Configuration.FindSetting[Enable TTS,FALSE]}]

		if !${Global.FindSetting[NavSettings](exists)} /* hasn't been transitioned yet */
		{
			Global:AddSetting[NavSettings,"0|0|0|0"]
			if ${Configuration.FindSetting[AutoRun Key](exists)}
			{ /* If we have an AutoRun key in the old config, assume they are accurate. */
				Global:AddSetting[AutoRun Key,${Configuration.FindSetting[AutoRun Key]}]
				Global:AddSetting[Backwards Key,${Configuration.FindSetting[Backwards Key]}]
				Global:AddSetting[StrafeRight Key,${Configuration.FindSetting[StrafeRight Key]}]
				Global:AddSetting[StrafeLeft Key,${Configuration.FindSetting[StrafeLeft Key]}]
				Configuration.FindSetting[AutoRun Key]:Remove
				Configuration.FindSetting[Backwards Key]:Remove
				Configuration.FindSetting[StrafeRight Key]:Remove
				Configuration.FindSetting[StrafeLeft Key]:Remove
			}
		}
		else /* We should init our "NavSettings" variables */
		{
			variable string VAR
			VAR:Set[${Global.FindSetting[NavSettings]}]
			ROX:Set[${VAR.Token[1,|]}]
			ROY:Set[${VAR.Token[2,|]}]
			WOX:Set[${VAR.Token[3,|]}]
			WOY:Set[${VAR.Token[4,|]}]
		}

		;; Movement
		#ifdef _MOVE_KEYS_
		if _MOVE_KEYS_ >= 2
		{
			AutoRunKey:Set[${Global.FindSetting[AutoRun Key,${autorun}]}]
			BackwardKey:Set[${Global.FindSetting[Backwards Key,${backward}]}]
			StrafeRightKey:Set[${Global.FindSetting[StrafeRight Key,${straferight}]}]
			StrafeLeftKey:Set[${Global.FindSetting[StrafeLeft Key,${strafeleft}]}]
		}
		else
		;#else
		;if 1
		#endif
		{
			AutoRunKey:Set[${Global.FindSetting[AutoRun Key,"num lock"]}]
			BackwardKey:Set[${Global.FindSetting[Backwards Key,"s"]}]
			StrafeRightKey:Set[${Global.FindSetting[StrafeRight Key,"e"]}]
			StrafeLeftKey:Set[${Global.FindSetting[StrafeLeft Key,"q"]}]
		}
		This:UpdateNavKeys

		Durability[1,1]:Set[${Configuration.FindSetting[Durability Threshold for Standard Quality 1?,110]}]
		Durability[1,2]:Set[${Configuration.FindSetting[Durability Threshold for Standard Quality 2?,90]}]
		Durability[1,3]:Set[${Configuration.FindSetting[Durability Threshold for Standard Quality 3?,30]}]
		Durability[1,4]:Set[${Configuration.FindSetting[Durability Threshold for Standard Quality 4?,0]}]
		Durability[2,1]:Set[${Configuration.FindSetting[Durability Threshold for Rare Quality 1?,110]}]
		Durability[2,2]:Set[${Configuration.FindSetting[Durability Threshold for Rare Quality 2?,90]}]
		Durability[2,3]:Set[${Configuration.FindSetting[Durability Threshold for Rare Quality 3?,30]}]
		Durability[2,4]:Set[${Configuration.FindSetting[Durability Threshold for Rare Quality 4?,0]}]

		ui -reload "${LavishScript.HomeDirectory}/Interface/Skins/EQ2/EQ2.xml"
		ui -reload -skin EQ2 "${UIPath}CraftGUI.xml"

		;fix our height if it bugged out from craft lite
		if ${UIElement[Craft Selection].Height}<=20 && !${CraftLite}
			UIElement[Craft Selection]:SetHeight[420]

		UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:ClearItems
		UIElement[Craft Selection].FindUsableChild[Quantity Value,textentry]:SetText[1]
		UIElement[Craft Selection].FindUsableChild[Level Value,textentry]:SetText[${Me.TSLevel}]
		UIElement[Craft Selection].FindUsableChild[Qty Level Value,textentry]:SetText[1]

		RecipeListMin:Set[${Configuration.FindSetting[Recipe List Minimum Range,1]}]
		RecipeListMax:Set[${Configuration.FindSetting[Recipe List Maximum Range,${Me.TSLevel}]}]
		RecipeListRange:Set[${Configuration.FindSetting[Save Recipe List Range?,TRUE]}]
		GuildPrivacy:Set[${Configuration.FindSetting[GuildPrivacy,FALSE]}]
		GuildPrivacyAlways:Set[${Configuration.FindSetting[GuildPrivacyAlways,FALSE]}]

		if !${RecipeListRange}
		{
			if ${RecipeListMax}==1
			{
				tempvar:Set[0]
				while ${tempvar:Inc}<=${Me.NumRecipes}
				{
					if ${Me.Recipe[${tempvar}].Level}>=${RecipeListMin}
					{
						if ${Me.Recipe[${tempvar}].Level}>${templevel}
						{
							templevel:Set[${Me.Recipe[${tempvar}].Level}]
						}
					}
				}

				RecipeListMax:Set[${templevel}]
				if (${StandardFilter} && !${SecondaryTS})
				{
					if ${RecipeListMax} > ${Me.TSLevel}
						RecipeListMax:Set[${Me.TSLevel}]
				}
			}

			if ${RecipeListMax} > 10 && ${RecipeListMin} == 1
				RecipeListMin:Set[${Math.Calc[${RecipeListMax}-10]}]
		}

		UIElement[Craft Selection].FindUsableChild[Level Min,textentry]:SetText[${RecipeListMin}]
		UIElement[Craft Selection].FindUsableChild[Level Max,textentry]:SetText[${RecipeListMax}]

		UIElement[Craft Selection].FindUsableChild[Power Regen,textentry]:SetText[${PowerRegen}]
		UIElement[Craft Selection].FindUsableChild[Camp Timer,textentry]:SetText[${CampTimer}]
		UIElement[Craft Selection].FindUsableChild[Max Buy Price,textentry]:SetText[${MaxBuyPrice}]
		UIElement[Craft Selection].FindUsableChild[Writ Count,textentry]:SetText[${WritCount}]
		UIElement[Craft Selection].FindUsableChild[Writ Qty,textentry]:SetText[${WritQty}]
		UIElement[Craft Selection].FindUsableChild[Tier,textentry]:SetText[${Tier}]
		UIElement[Craft Selection].FindUsableChild[Craft Delay,textentry]:SetText[${CraftDelay}]
		UIElement[Craft Selection].FindUsableChild[Path Precision,textentry]:SetText[${PathPrecision}]

		if ${SortLevel}
		{
			This:SortbyName
		}
		else
		{
			This:SortbyLevel
		}

		if !${QueuePath.PathExists}
			mkdir "${QueuePath.Path}"

		This:ConvertRecipeFavorites

		LavishSettings[Craft Config File]:Export[${configfile}]
		Global:Export[${globalfile}]

		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:ClearItems

		This:PopulateFavorites[${Me.TSSubClass}]

		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:SetSortType[text]:Sort
		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox].ItemByText[Last Saved Queue List]:Select

		Craft:RefreshList

		ISXEQ2:SetCustomVariable[CWC,${WritCount}]

		IsDecliningRaidInvites:Set[${Me.IsDecliningRaidInvites}]
		IsDecliningTradeInvites:Set[${Me.IsDecliningTradeInvites}]
		IsDecliningGroupInvites:Set[${Me.IsDecliningGroupInvites}]
		ICraft.Search:InitSearchWindow
	}

	method UpdateNavKeys()
	{
		Nav.AUTORUN:Set[${AutoRunKey}]
		Nav.MOVEBACKWARD:Set[${BackwardKey}]
		Nav.STRAFELEFT:Set[${StrafeLeftKey}]
		Nav.STRAFERIGHT:Set[${StrafeRightKey}]
	}

	method DoIgnores(bool On)
	{
		if ${DeclineInvites} && ${On}
		{
			IsDecliningRaidInvites:Set[${Me.IsDecliningRaidInvites}]
			IsDecliningTradeInvites:Set[${Me.IsDecliningTradeInvites}]
			IsDecliningGroupInvites:Set[${Me.IsDecliningGroupInvites}]

			if !${IsDecliningRaidInvites}
			{
				EQ2Execute "decline_raids true"
			}
			if !${IsDecliningTradeInvites}
			{
				EQ2Execute "decline_trades true"
			}
			if !${IsDecliningGroupInvites}
			{
				EQ2Execute "decline_groups true"
			}
		}
		elseif (${DeclineInvites} && !${On}) || !${DeclineInvites}
		{
			if !${Me.IsDecliningRaidInvites} && ${IsDecliningRaidInvites}
				EQ2Execute "/decline_raids true"
			elseif ${Me.IsDecliningRaidInvites} && !${IsDecliningRaidInvites}
				EQ2Execute "/decline_raids false"
			if !${Me.IsDecliningTradeInvites} && ${IsDecliningTradeInvites}
				EQ2Execute "/decline_trades true"
			elseif ${Me.IsDecliningTradeInvites} && !${IsDecliningTradeInvites}
				EQ2Execute "/decline_trades false"
			if !${Me.IsDecliningGroupInvites} && ${IsDecliningGroupInvites}
				EQ2Execute "/decline_groups true"
			elseif ${Me.IsDecliningGroupInvites} && !${IsDecliningGroupInvites}
				EQ2Execute "/decline_groups false"
		}
	}

	method InitCraftSkills(int var1, int var2)
	{
		variable int temp1
		variable int temp2
		variable int temp3
		variable int temp4
		variable int templevel
		variable string crafttype
		variable bool useskill

		; TSSpell[<1=Progress & 2=Durability>,<type>] Where type refers to
		; Type 1: 1=+Progress -Durability, 2=+Progress -Success, 3=+Progress -Power
		; Type 2: 1=+Durability -Progress, 2=+Durability -Success, 3=+Durability -Power

		TSSpell[1,1]:Set["${LavishSettings[Skills].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[1 1]}"]
		TSSpell[1,2]:Set["${LavishSettings[Skills].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[1 2]}"]
		TSSpell[1,3]:Set["${LavishSettings[Skills].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[1 3]}"]
		TSSpell[2,1]:Set["${LavishSettings[Skills].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[2 1]}"]
		TSSpell[2,2]:Set["${LavishSettings[Skills].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[2 2]}"]
		TSSpell[2,3]:Set["${LavishSettings[Skills].FindSet[${MakeKnowledge[${var1},${var2}]}].FindSetting[2 3]}"]

		return
	}

	method SortbyName()
	{
		UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:SetSortType[text]:Sort
		UIElement[Craft Selection].FindUsableChild[Recipe List,combobox].OrderedItem[1]:Select
		UIElement[Sort Name@Recipes@Craft Main@Main Frame@Craft Selection]:SetChecked
		UIElement[Sort Level@Recipes@Craft Main@Main Frame@Craft Selection]:UnsetChecked
		SortLevel:Set[TRUE]
		Configuration.FindSetting[Default Sort Order by Name?]:Set[${SortLevel}]
		LavishSettings[Craft Config File]:Export[${configfile}]
	}

	method SortbyLevel()
	{
		UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:SetSortType[valuereverse]:Sort
		UIElement[Craft Selection].FindUsableChild[Recipe List,combobox].OrderedItem[1]:Select
		UIElement[Sort Name@Recipes@Craft Main@Main Frame@Craft Selection]:UnsetChecked
		UIElement[Sort Level@Recipes@Craft Main@Main Frame@Craft Selection]:SetChecked
		SortLevel:Set[FALSE]
		Configuration.FindSetting[Default Sort Order by Name?]:Set[${SortLevel}]
		LavishSettings[Craft Config File]:Export[${configfile}]
	}

	method CheckGUIFiles()
	{
		variable filepath FP1="${LavishScript.HomeDirectory}/Interface/Skins/EQ2/"
		variable filepath FP2="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/UI/"
		variable filepath FP3="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Recipe Data/"

		if !${FP1.FileExists[EQ2.xml]}
		{
			ErrorEcho The EQ2 Skin file could not be found in ${FP1}
			ErrorEcho Please check the directory for "EQ2.xml"
			Script:End
		}

		if !${FP2.FileExists[CraftGUI.XML]}
		{
			ErrorEcho The CraftGUI.XML file could not be found in ${FP2}
			ErrorEcho Please check the directory for "CraftGUI.XML"
			Script:End
		}

		if !${FP3.FileExists[Common.xml]}
		{
			ErrorEcho The Common.xml file could not be found in ${FP3}
			ErrorEcho Please check the directory for "Common.xml"
			Script:End
		}

		if !${FP3.FileExists[ReactionArts.xml]}
		{
			ErrorEcho The ReactionArts.xml file could not be found in ${FP3}
			ErrorEcho Please check the directory for "ReactionArts.xml"
			Script:End
		}

		if !${FP3.FileExists[Resources.xml]}
		{
			ErrorEcho The Resources.xml file could not be found in ${FP3}
			ErrorEcho Please check the directory for "Resources.xml"
			Script:End
		}

		if !${FP3.FileExists[Skills.xml]}
		{
			ErrorEcho The Skills.xml file could not be found in ${FP3}
			ErrorEcho Please check the directory for "Skills.xml"
			Script:End
		}
	}

	method InitTriggers()
	{
		AddTrigger Craft:Completed "You created @*@:@itemcreated@\\/a."
		AddTrigger Craft:InvalidComponents "The components you selected are invalid. Trade skill process halted."
	}

	method InitEvents()
	{
		Event[EQ2_onQuestUpdate]:AttachAtom[EQ2_onQuestUpdate]
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onInventoryUpdate]:AttachAtom[EQ2_onInventoryUpdate]
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
		Event[EQ2_onQuestOffered]:AttachAtom[EQ2_onQuestOffered]
	}

	member:bool LoadAndValidateQueue(string Filename)
	{
		variable filepath FP=""
		CraftQueue:Clear

		if !${Filename.Find[.xml]}
			Filename:Concat[.xml]
		if ${Filename.Find[/]} /* Absolute path */
		{
			if !${FP.FileExists[${Filename}]}
				return FALSE
		}
		if ${QueuePath.FileExists[${Filename}]}
		{
			Filename:Set[${QueuePath}/${Filename}]
		}
		elseif ${QueuePath.FileExists[${Me.TSSubClass}-${Filename}]}
		{
			Filename:Set[${QueuePath}/${Me.TSSubClass}-${Filename}]
		}
		else
			return FALSE

		CraftQueue:Import[${Filename}]
		if ${CraftQueue.Children(exists)}
			return TRUE
		CraftQueue:Clear
		return FALSE
	}

	method ConvertRecipeFavorites()
	{
		variable settingsetref oldsets
		variable iterator sIter
		if ${LavishSettings[Craft Config File].FindSet[Recipe Favourites](exists)}
			oldsets:Set[${LavishSettings[Craft Config File].FindSet[Recipe Favourites]}]
		else
			return
		oldsets:GetSetIterator[sIter]

		if ${sIter:First(exists)}
		{
			do
			{
				ChatEcho Exporting: ${QueuePath.Path}/${Me.TSSubClass}-${sIter.Value.Name}.xml
				sIter.Value:Export[${QueuePath}/${Me.TSSubClass}-${sIter.Value.Name}.xml]
			}
			while ${sIter:Next(exists)}
		}
		LavishSettings[Craft Config File].FindSet[Recipe Favourites]:Remove
	}

	method PopulateFavorites(string sClass) /* Subclass, or "ALL" */
	{
		variable string selection=${UIElement[Craft Selection].FindUsableChild[Favourites List,combobox].SelectedItem}
		variable filelist files
		variable string cleanfile
		variable int iter=0

		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:ClearItems
		if ${sClass.Equal[ALL]}
			files:GetFiles[${QueuePath}\\*.xml]
		else
			files:GetFiles[${QueuePath}/${sClass}-*.xml]
		while ${iter:Inc}<=${files.Files}
		{
			if ${sClass.Equal[ALL]}
				cleanfile:Set[${files.File[${iter}].Filename.Left[-4]}]
			else
				cleanfile:Set[${files.File[${iter}].Filename.Left[-4].Right[-${Math.Calc[${sClass.Length}+1]}]}]

			UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:AddItem[${cleanfile}]
		}
		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:SetSortType[text]:Sort
		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox].ItemByText[${selection}]:Select
	}

	method InvalidComponents(string Line)
	{
		call Begin
	}

	method Completed(string Line, string itemcreated)
	{
		complete:Set[TRUE]
		chktotdur:Set[TRUE]
		roundstart:Set[TRUE]
		ItemsCreated:Insert[${itemcreated}]
	}

	method InitGUI(bool ForceUpdate=FALSE)
	{
		variable int tempvar1
		variable int tempvar2
		variable string listboxcolor
		variable int uicounter
		variable index:int ResNeed
		variable index:int ComNeed
		variable index:int FuelNeed

		;UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Show:SetZOrder[alwaysontop]:SetZOrder[movetop]

		switch ${UIElement[Craft Selection].FindUsableChild[Craft Main,tabcontrol].SelectedTab.Name}
		{
			case Recipes
				UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Show:SetZOrder[alwaysontop]:SetZOrder[movetop]
				UIElement[Craft Selection].FindUsableChild[Crafting List Frame,frame]:Hide:SetZOrder[notalwaysontop]:SetZOrder[movedown]
				break
			case Options
			case Writs
			case About
				UIElement[Craft Selection].FindUsableChild[Harvest Frame,frame]:Hide:SetZOrder[notalwaysontop]:SetZOrder[movedown]
				UIElement[Craft Selection].FindUsableChild[Crafting List Frame,frame]:Hide:SetZOrder[notalwaysontop]:SetZOrder[movedown]
		}

		thisharvestframe:Set[TRUE]

		;UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox]:AddItem[ ]

		xvar:Set[0]
		while ${xvar:Inc}<=${rescnt}
		{
			if ${StatResTot[${xvar}]}<${StatResCnt[${xvar}]} || ${ShowAllLists}
				ResNeed:Insert[${xvar}]
		}
		xvar:Set[0]
		while ${xvar:Inc}<=${comcnt}
		{
			if ${StatComTot[${xvar}]}<${StatComCnt[${xvar}]} || ${ShowAllLists}
				ComNeed:Insert[${xvar}]
		}
		xvar:Set[0]
		while ${xvar:Inc}<=${fuelcnt}
		{
			if ${StatFuelTot[${xvar}]}<${StatFuelCnt[${xvar}]} || ${ShowAllLists}
				FuelNeed:Insert[${xvar}]
		}
		xvar:Set[1]
		uicounter:Set[0]
		if ${ResNeed.Used}!=${UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox].Items} || ${ForceUpdate}
		{
			UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox]:ClearItems
			do
			{
				if ${ResNeed.Used}
				{
					if ${StatResTot[${ResNeed[${xvar}]}]}<${StatResCnt[${ResNeed[${xvar}]}]}
					{
						listboxcolor:Set[FFFF0000]
					}
					else
					{
						listboxcolor:Set[FF22FF22]
					}

					UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox]:SetTextColor[${listboxcolor}]:AddItem[${StatResNme[${ResNeed[${xvar}]}]}| ${StatResTot[${ResNeed[${xvar}]}]}/${StatResCnt[${ResNeed[${xvar}]}]}]
				}
			}
			while ${xvar:Inc}<=${ResNeed.Used}
		}
		else
		{
			while ${uicounter:Inc}<=${UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox].Items} && ${ResNeed.Used}
			{
				xvar:Set[1]
				do
				{
					if ${UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox].OrderedItem[${uicounter}].Text.Token[1,|].Equal[${StatResNme[${ResNeed[${xvar}]}]}]}
					{
						if ${StatResTot[${ResNeed[${xvar}]}]}<${StatResCnt[${ResNeed[${xvar}]}]}
						{
							listboxcolor:Set[FFFF0000]
						}
						else
						{
							listboxcolor:Set[FF22FF22]
						}
						UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox].OrderedItem[${uicounter}]:SetTextColor[${listboxcolor}]:SetText[${StatResNme[${ResNeed[${xvar}]}]}| ${StatResTot[${ResNeed[${xvar}]}]}/${StatResCnt[${ResNeed[${xvar}]}]}]
						xvar:Set[${ResNeed.Used}]
					}
				}
				while ${xvar:Inc}<=${ResNeed.Used}
			}
		}
		;UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox]:AddItem[ ]
		xvar:Set[1]
		uicounter:Set[0]
		if ${ComNeed.Used}!=${UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox].Items} || ${ForceUpdate}
		{
			UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox]:ClearItems
			do
			{
				if ${ComNeed.Used}
				{
					if ${StatComTot[${ComNeed[${xvar}]}]}<${StatComCnt[${ComNeed[${xvar}]}]}
					{
						listboxcolor:Set[FFFF0000]
					}
					else
					{
						listboxcolor:Set[FF22FF22]
					}

					UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox]:SetTextColor[${listboxcolor}]:AddItem[${StatComNme[${ComNeed[${xvar}]}]}| ${StatComTot[${ComNeed[${xvar}]}]}/${StatComCnt[${ComNeed[${xvar}]}]}]
				}
			}
			while ${xvar:Inc}<=${ComNeed.Used}
		}
		else
		{
			while ${uicounter:Inc}<=${UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox].Items} && ${ComNeed.Used}
			{
				xvar:Set[1]
				do
				{
					if ${UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox].OrderedItem[${uicounter}].Text.Token[1,|].Equal[${StatComNme[${ComNeed[${xvar}]}]}]}
					{
						if ${StatComTot[${ComNeed[${xvar}]}]}<${StatComCnt[${ComNeed[${xvar}]}]}
						{
							listboxcolor:Set[FFFF0000]
						}
						else
						{
							listboxcolor:Set[FF22FF22]
						}
						UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox].OrderedItem[${uicounter}]:SetTextColor[${listboxcolor}]:SetText[${StatComNme[${ComNeed[${xvar}]}]}| ${StatComTot[${ComNeed[${xvar}]}]}/${StatComCnt[${ComNeed[${xvar}]}]}]
						xvar:Set[${ComNeed.Used}]
					}
				}
				while ${xvar:Inc}<=${ComNeed.Used}
			}
		}

		;UIElement[Craft Selection].FindUsableChild[Fuel List,listbox]:AddItem[ ]
		xvar:Set[1]
		uicounter:Set[0]
		if ${FuelNeed.Used}!=${UIElement[Craft Selection].FindUsableChild[Fuel List,listbox].Items} || ${ForceUpdate}
		{
			UIElement[Craft Selection].FindUsableChild[Fuel List,listbox]:ClearItems
			do
			{
				if ${FuelNeed.Used}
				{
					if ${StatFuelTot[${FuelNeed[${xvar}]}]}<${StatFuelCnt[${FuelNeed[${xvar}]}]}
					{
						listboxcolor:Set[FFFF0000]
					}
					else
					{
						listboxcolor:Set[FF22FF22]
					}

					UIElement[Craft Selection].FindUsableChild[Fuel List,listbox]:SetTextColor[${listboxcolor}]:AddItem[${StatFuelNme[${FuelNeed[${xvar}]}]}| ${StatFuelTot[${FuelNeed[${xvar}]}]}/${StatFuelCnt[${FuelNeed[${xvar}]}]}]
				}
			}
			while ${xvar:Inc}<=${FuelNeed.Used}
		}
		else
		{
			while ${uicounter:Inc}<=${UIElement[Craft Selection].FindUsableChild[Fuel List,listbox].Items} && ${FuelNeed.Used}
			{
				xvar:Set[1]
				do
				{
					if ${UIElement[Craft Selection].FindUsableChild[Fuel List,listbox].OrderedItem[${uicounter}].Text.Token[1,|].Equal[${StatFuelNme[${FuelNeed[${xvar}]}]}]}
					{
						if ${StatFuelTot[${FuelNeed[${xvar}]}]}<${StatFuelCnt[${FuelNeed[${xvar}]}]}
						{
							listboxcolor:Set[FFFF0000]
						}
						else
						{
							listboxcolor:Set[FF22FF22]
						}
						UIElement[Craft Selection].FindUsableChild[Fuel List,listbox].OrderedItem[${uicounter}]:SetTextColor[${listboxcolor}]:SetText[${StatFuelNme[${FuelNeed[${xvar}]}]}| ${StatFuelTot[${FuelNeed[${xvar}]}]}/${StatFuelCnt[${FuelNeed[${xvar}]}]}]
						xvar:Set[${FuelNeed.Used}]
					}
				}
				while ${xvar:Inc}<=${FuelNeed.Used}
			}
		}

		;UIElement[Craft Selection].FindUsableChild[Crafted List,listbox]:AddItem[ ]
		if ${UIElement[Craft Selection].FindUsableChild[Crafted List,listbox].Items} != ${Math.Calc[${MakeCnt[1]}+${MakeCnt[2]}+${MakeCnt[3]}+${MakeCnt[4]}]}
		{
		UIElement[Craft Selection].FindUsableChild[Crafted List,listbox]:ClearItems

			tempvar1:Set[4]
			do
			{
				tempvar2:Set[${MakeCnt[${tempvar1}]}]
				do
				{
					if ${MakeQty[${tempvar1},${tempvar2}]}>0 && ${MakeName[${tempvar1},${tempvar2}].Length}
					{
						if ${MainRecipe.Equal[${MakeName[${tempvar1},${tempvar2}]}]}
						{
							listboxcolor:Set[FFFFFF00]
						}
						else
						{
							listboxcolor:Set[FF22FF22]
						}
						UIElement[Craft Selection].FindUsableChild[Crafted List,listbox]:SetTextColor[${listboxcolor}]:AddItem[${MakeName[${tempvar1},${tempvar2}]} (Q|${MakeQlt[${tempvar1},${tempvar2}]})| ${Math.Calc[${MakeQty[${tempvar1},${tempvar2}]}*${MakeProduce[${tempvar1},${tempvar2}]}].Ceil}]
					}
				}
				while ${tempvar2:Dec}>0
			}
			while ${tempvar1:Dec}>0
		}
	}

	method CalculateComponents()
	{
		variable int tempvar1
		variable int tempvar2
		variable int tempvar3
		variable bool fuelfnd
		variable bool craftfnd

		tempvar1:Set[0]
		while ${tempvar1:Inc}<=100
		{
			StatFuelCnt[${tempvar1}]:Set[0]
			StatFuelTot[${tempvar1}]:Set[0]
		}

		tempvar1:Set[2]
		do
		{
			tempvar2:Set[${MakeCnt[${tempvar1}]}]
			do
			{
				if ${MakeCnt[${tempvar1}]} && ${MakeQty[${tempvar1},${tempvar2}]}>0
				{
					fuelfnd:Set[FALSE]
					tempvar3:Set[1]
					do
					{
						if ${MakeFuelName[${tempvar1},${tempvar2}].Equal[${StatFuelNme[${tempvar3}]}]}
						{
							StatFuelCnt[${tempvar3}]:Inc[${Math.Calc[${MakeQty[${tempvar1},${tempvar2}].Ceil}*${MakeFuelCnt[${tempvar1},${tempvar2}]}]}]
							fuelfnd:Set[TRUE]
							break
						}
					}
					while ${tempvar3:Inc}<=${fuelcnt}

					if !${fuelfnd} && ${MakeFuelName[${tempvar1},${tempvar2}].Length}
					{
						fuelcnt:Inc
						StatFuelNme[${fuelcnt}]:Set[${MakeFuelName[${tempvar1},${tempvar2}]}]
						StatFuelCnt[${fuelcnt}]:Inc[${Math.Calc[${MakeQty[${tempvar1},${tempvar2}].Ceil}*${MakeFuelCnt[${tempvar1},${tempvar2}]}]}]
					}
				}
			}
			while ${tempvar2:Dec}>0
		}
		while ${tempvar1:Dec}>0
	}

	method SetMode(string Mode)
	{
		switch ${Mode}
		{
			case normal
				CraftLite:Set[0]
				Craft:DoIgnores[TRUE]
				break
			case lite
				Craft:DoIgnores[FALSE]
				CraftLite:Set[1]
				break
		}
	}

	method ProcessPartialInventory(string itemsearch, int partial)
	{
		variable index:item Items
		variable iterator ItemIterator
		variable string tempstr
		variable int tmpprefix

		Me:QueryInventory[Items, Location == "Inventory"]
		Items:GetIterator[ItemIterator]

		if ${ItemIterator:First(exists)}
		{
			do
			{
				tempstr:Set[${ItemIterator.Value.Name}]

				if ${tempstr.Equal[${itemsearch}]}
				{
					if ${tempstr.Find[arrow]} || ${tempstr.Find[scraps]} || ${tempstr.Find[totem]}
					{
						tmpprefix:Set[4]
					}
					else
					{
						tmpprefix:Set[3]
					}
					StatCraftCnt[${partial},${tmpprefix}]:Inc[${ItemIterator.Value.Quantity}]
					StatCraftNme[${partial}]:Set[${itemsearch}]
				}
				else
				{
					if ${tempstr.Right[${itemsearch.Length}].Equal[${itemsearch}]}
					{
						QualityPrefix:GetSettingIterator[sIterator]
						if ${sIterator:First(exists)}
						{
							do
							{
								if ${tempstr.Left[${sIterator.Key.Length}].Equal[${sIterator.Key}]}
								{
									if ${Math.Calc[${sIterator.Key.Length}+${itemsearch.Length}+1]}==${tempstr.Length}
									{
										tmpprefix:Set[${sIterator.Value}]
									}
								}
							}
							while ${sIterator:Next(exists)}
						}

						if ${tmpprefix}
						{
							StatCraftCnt[${partial},${tmpprefix}]:Inc[${ItemIterator.Value.Quantity}]
							StatCraftNme[${partial}]:Set[${itemsearch}]
						}
					}
				}
			}
			while ${ItemIterator:Next(exists)}
		}
	}

	member:float CalculateCraft(string tempname, int tempqlt, int tempproc, int tempid, int tempprod)
	{
		variable int tempvar1
		variable int tempvar2
		variable bool craftfnd
		variable float subtotal

		craftfnd:Set[FALSE]
		tempvar1:Set[1]
		do
		{
			if ${tempname.Equal[${StatCraftNme[${tempvar1}]}]}
			{
				craftfnd:Set[TRUE]
				break
			}
		}
		while ${tempvar1:Inc}<=${craftcnt}

		if !${craftfnd}
		{
			craftcnt:Inc
			tempvar1:Set[${craftcnt}]
			This:ProcessPartialInventory[${tempname},${craftcnt}]
		}

		tempvar2:Set[4]
		do
		{
			if ${Math.Calc[${MakeQty[${tempproc},${tempid}]}*${tempprod}].Ceil}<${StatCraftCnt[${tempvar1},${tempvar2}]}
			{
				StatCraftCnt[${tempvar1},${tempvar2}]:Dec[${Math.Calc[${MakeQty[${tempproc},${tempid}]}*${tempprod}].Ceil}]
				subtotal:Inc[${Math.Calc[${MakeQty[${tempproc},${tempid}]}*${tempprod}].Ceil}]
				MakeQty[${tempproc},${tempid}]:Set[0]
			}
			else
			{
				MakeQty[${tempproc},${tempid}]:Dec[${Math.Calc[${StatCraftCnt[${tempvar1},${tempvar2}]}/${tempprod}]}]
				subtotal:Inc[${StatCraftCnt[${tempvar1},${tempvar2}]}]
				StatCraftCnt[${tempvar1},${tempvar2}]:Set[0]
			}
		}
		while ${tempqlt}<=${tempvar2:Dec}
		return ${subtotal}
	}

	method ProgressGUI(int var1, int var2)
	{
		variable int tempvar1
		variable int tempvar2
		variable string listboxcolor
		variable bool chgnext=FALSE

		UIElement[Craft Selection].FindUsableChild[Process List,listbox]:ClearItems
		UIElement[Craft Selection].FindUsableChild[Process List,listbox]:AddItem[ ]
		UIElement[Craft Selection].FindUsableChild[Process List,listbox]:AddItem[ ]

		tempvar1:Set[2]
		do
		{
			tempvar2:Set[${MakeCnt[${tempvar1}]}]
			do
			{
				if ${MakeQty[${tempvar1},${tempvar2}]}>0 && ${MakeName[${tempvar1},${tempvar2}].Length}
				{
					if ${fpassui}
					{
						listboxcolor:Set[FFFF5F00]
						fpassui:Set[FALSE]
					}
					else
					{
						listboxcolor:Set[FF22FF22]
					}

					if ${chgnext}
					{
						listboxcolor:Set[FFFF5F00]
						chgnext:Set[FALSE]
					}
					else
					{
						if ${var1}==${tempvar1} && ${var2}==${tempvar2}
						{
							listboxcolor:Set[FFFF5F00]

							if  ${StatCraftTot[${tempvar1},${tempvar2}]}==${MakeQty[${tempvar1},${tempvar2}].Ceil} || ${missval}
							{
								listboxcolor:Set[FF22FF22]
								chgnext:Set[TRUE]
							}
						}
					}
					UIElement[Craft Selection].FindUsableChild[Process List,listbox]:SetTextColor[${listboxcolor}]:AddItem[${MakeName[${tempvar1},${tempvar2}]} (Q|${MakeQlt[${tempvar1},${tempvar2}]})| ${StatCraftTot[${tempvar1},${tempvar2}]}\/${MakeQty[${tempvar1},${tempvar2}].Ceil}]
				}
			}
			while ${tempvar2:Dec}>0
		}
		while ${tempvar1:Dec}>0
	}

	member:bool CheckPageStuck()
	{
		variable string TempLabel
		variable int TempTotal
		variable int TempCount

		TempLabel:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,TradeSkills.TabPages.Craft.prepare.summarypage.pccount].GetProperty[LocalText]}]
		TempTotal:Set[${TempLabel.Token[2,/]}]
		TempCount:Set[${TempLabel.Token[1,/]}]

		if ${TempTotal}
		{
			if ${TempCount}<${TempTotal}
			{
				return TRUE
			}
		}

		variable int Cnt
		for (Cnt:Set[1]; ${Cnt} <= 4; Cnt:Inc)
		{
			TempLabel:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,TradeSkills.TabPages.Craft.prepare.summarypage.BCCount${Cnt}].GetProperty[LocalText]}]
			TempTotal:Set[${TempLabel.Token[2,/]}]
			TempCount:Set[${TempLabel.Token[1,/]}]

			if ${TempTotal}
			{
				if ${TempCount}<${TempTotal}
				{
					return TRUE
				}
			}
		}

		TempLabel:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,TradeSkills.TabPages.Craft.prepare.summarypage.FuelCount].GetProperty[LocalText]}]
		TempTotal:Set[${TempLabel.Token[2,/]}]
		TempCount:Set[${TempLabel.Token[1,/]}]

		if ${TempTotal}
		{
			if ${TempCount}<${TempTotal}
			{
				return TRUE
			}
		}

		return FALSE
	}

	method UpdateProgress(int var1, int var2)
	{
		if !${missval}
		{
			StatCraftTot[${var1},${var2}]:Inc
		}
		This:ProgressGUI[${var1},${var2}]
	}

	member:string ValidateRecipe(string RecipeName)
	{
		variable int tcount
		variable string MsgBox
		Returning:Set[${RecipeName}]
		if ${Me.Recipe[${RecipeName}](exists)}
			return

		; Check Writ Recipes First
		; Check for prefixes used and extract them
		QualityPrefix:GetSettingIterator[sIterator]
		if ${sIterator:First(exists)}
		{
			do
			{
				if ${RecipeName.Left[${sIterator.Key.Length}].Equal[${sIterator.Key}]}
				{
					if ${Me.Recipe[${RecipeName.Right[-${sIterator.Key.Length}]}](exists)}
					{
						Returning:Set[${RecipeName.Right[-${sIterator.Key.Length}]}]
						return
					}
				}
			}
			while ${sIterator:Next(exists)}
		}

		; Search for a custom writ name
		WritRecipes:GetSettingIterator[sIterator]
		if ${sIterator:First(exists)}
		{
			do
			{
				if ${RecipeName.Equal[${sIterator.Key}]}
				{
					Returning:Set[${sIterator.Value}]
					return
				}
			}
			while ${sIterator:Next(exists)}
		}

		if ${Me.Recipe[${RecipeName.Replace[(,"",),""]}](exists)}
		{
			Returning:Set[${RecipeName.Replace[(,"",),""]}]
			return
		}

		if ${Me.TSClass.Equal[scholar]} && ${RecipeName.Find[Journeyman]}
		{
			if ${RecipeName.Right[12].Equal[(Journeyman)]}
			{
				if ${Me.Recipe[Essence of ${RecipeName}](exists)}
				{
					Returning:Set[Essence of ${RecipeName}]
					return
				}
				if ${Me.Recipe[Rune of ${RecipeName}](exists)}
				{
					Returning:Set[Rune of ${RecipeName}]
					return
				}
			}
			tcount:Set[13]
			do
			{
				if ${Me.Recipe[${RecipeName.Right[-${tcount}]} (Journeyman)](exists)}
				{
					Returning:Set[${RecipeName.Right[-${tcount}]} (Journeyman)]
					return
				}
				if ${Me.Recipe[Essence of ${RecipeName.Right[-${tcount}]} (Journeyman)](exists)}
				{
					Returning:Set[Essence of ${RecipeName.Right[-${tcount}]} (Journeyman)]
					return
				}
				if ${Me.Recipe[Rune of ${RecipeName.Right[-${tcount}]} (Journeyman)](exists)}
				{
					Returning:Set[Rune of ${RecipeName.Right[-${tcount}]} (Journeyman)]
					return
				}
			}
			while ${tcount:Inc}<17
		}

		if ${Me.Recipe[${RecipeName}s](exists)}
		{
			Returning:Set[${RecipeName}s]
			return
		}

		if ${Me.Recipe[${RecipeName.Left[-1]}](exists)}
		{
			Returning:Set[${RecipeName.Left[-1]}]
			return
		}

		if ${Me.Recipe[${RecipeName.Right[-9]}](exists)}
			Returning:Set[${RecipeName.Right[-9]}]
		elseif ${Me.Recipe[${RecipeName.Right[-16]}](exists)}
			Returning:Set[${RecipeName.Right[-16]}]
		elseif ${Me.Recipe[${RecipeName.Right[-18]}](exists)}
			Returning:Set[${RecipeName.Right[-18]}]

		if ${Me.Recipe[${Returning}](exists)}
			return

		Returning:Set[${RecipeName}]
		; Check Pristine
		if ${RecipeName.Left[8].Equal[Pristine]}
		{
			Returning:Set[${RecipeName.Right[-8]}]
			if ${Me.Recipe[${Returning}](exists)}
				return
		}

		; Check Forged
		if ${Returning.Left[6].Equal[Forged]}
		{
			Returning:Set[${RecipeName.Right[-6]}]
			if ${Me.Recipe[${Returning}](exists)}
				return
		}

		; Check Conditioned
		if ${RecipeName.Left[11].Equal[Conditioned]}
		{
			Returning:Set[${RecipeName.Right[-11]}]
			if ${Me.Recipe[${Returning}](exists)}
				return
		}

		; Check Tailored
		if ${RecipeName.Left[8].Equal[Tailored]}
		{
			Returning:Set[${RecipeName.Right[-8]}]
			if ${Me.Recipe[${Returning}](exists)}
				return
		}
		; and finally, we'll iterate through and check for provisioner writs.
		tcount:Set[2]
		Returning:Set[${RecipeName}]
		while ${Returning.Length}
		{
			;Debug:Echo["PROVIE LOOP: Returning = ${Returning}"]
			if ${Me.Recipe[${Returning}](exists)}
				return
			if ${Me.Recipe[${Returning}s](exists)}
			{
				Returning:Set[${Returning}s]
				return
			}
			if ${Me.Recipe[${Returning.Left[-1]}](exists)}
			{
				Returning:Set[${Returning.Left[-1]}]
				return
			}
			if ${Returning.Find[" "]}
				Returning:Set[${Returning.Right[-${Returning.Find[" "]}]}]
			else
				Returning:Set[""]
		}

		if ${UIElement[messagebox](exists)}
		{
			MsgBox:Set["${UIElement[messagebox].FindChild[text].Text}"]
			UIElement[messagebox]:Destroy
			MsgBox:Set["${MsgBox}\nUnable to find valid recipe for ${RecipeName}"]
		}
		else
		{
			MsgBox:Set[Unable to find valid recipe for ${RecipeName}]
		}

		Debug:Echo["Opening messagebox: \n${MsgBox}"]
		messagebox -ok "${MsgBox}"
		return NULL
	}

	method ProcessRecipe(string RecipeName, int pQuality, int totQuantity)
	{
		variable uint recipeid
		variable string primarycomponent
		variable int produce
		variable int tempval
		variable int tempqlt
		variable int searchid
		variable string tmpbld
		variable string tmpres
		variable string recipefile
		variable int processtype
		variable int rescomquantity
		variable int tempvar
		variable bool prefix

		if ${gaugelevel}<0.8
		{
			gaugelevel:Inc[${Math.Calc[0.02/${gaugefactor}]}]
		}

		if !${RecipeName.Length} || ${RecipeName.Equal[NULL]}
		{
			return
		}

		if !${MainRecipe.Equal[${RecipeName}]} && ${QOverride}==4
		{
			pQuality:Set[4]
		}

		if ${RecipeName.Find[loam]} || ${RecipeName.Find[arrow]} || ${RecipeName.Find[scraps]} || ${RecipeName.Find[totem]}
		{
			pQuality:Set[4]
		}

		RecipeName:Set[${Craft.ValidateRecipe[${RecipeName}]}]
		if ${RecipeName.Equal[NULL]}
			return
		recipeid:Set[${Me.Recipe[${RecipeName}].ID}]

		primarycomponent:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.Name}]
		; Lets see if its a Imbued Type recipe and assign it as processtype=1
		; Default processtype=2

		if ${RecipeName.Find[Imbued]} || ${RecipeName.Find[Blessed]}
		{
			; Need to verify its a Imbued recipe by looking at the prefix.
			; BULLSHIT. If the left of the recipe says "Imbued" or "Blessed" and the primary component
			; isn't a raw, it's a fucking imbue.
			if !${Harvests.FindSetting[${primarycomponent}](exists)}
				processtype:Set[1]
			else
				processtype:Set[2]

		}
		else
		{
			processtype:Set[2]
		}

		; Verify that recipe data has been loaded before processing recipe.
		if ${primarycomponent.Equal[NULL]} || ${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent1.Name.Equal[NULL]}
		{
			if !${MainRecipe.Equal[${RecipeName}]}
			{
				FailedRecipe:Insert["${RecipeName},${totQuantity},TRUE"]
			}
			else
			{
				FailedRecipe:Insert["${RecipeName},${totQuantity},FALSE"]
			}
			return
		}

		; Assume Produce is 1 for now.
		produce:Set[1]

		if ${produce}>1
		{
			tempqlt:Set[4]
		}
		else
		{
			produce:Set[1]
			tempqlt:Set[${pQuality}]
		}

		; Process Main Recipe
		searchid:Set[${This.SearchRecipe[${recipeid},${tempqlt},${processtype}]}]
		if !${searchid}
		{
			MakeCnt[${processtype}]:Inc
			searchid:Set[${MakeCnt[${processtype}]}]
		}

		MakeName[${processtype},${searchid}]:Set[${RecipeName}]
		MakeID[${processtype},${searchid}]:Set[${recipeid}]
		MakeLevel[${processtype},${searchid}]:Set[${Me.Recipe[${RecipeName}].Level}]
		MakeKnowledge[${processtype},${searchid}]:Set[${Me.Recipe[${RecipeName}].Knowledge}]
		MakeDevice[${processtype},${searchid}]:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.Device}]
		MakeQty[${processtype},${searchid}]:Inc[${Math.Calc[${totQuantity}/${produce}]}]
		MakeFuelName[${processtype},${searchid}]:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.Name}]
		MakeFuelCnt[${processtype},${searchid}]:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.Quantity}]
		MakeProduce[${processtype},${searchid}]:Set[${produce}]

		RecipesInQueue:Insert[${RecipeName}]

		;; Adding Fuel Count to ComponentQuantities
		ComponentQuantites:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.Name},${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.QuantityOnHand}]

		if ${produce}>1
		{
			MakeQlt[${processtype},${searchid}]:Set[4]
			rescomquantity:Set[${totQuantity}]
			totQuantity:Set[${Math.Calc[${totQuantity}/${produce}].Ceil}]
		}
		else
		{
			rescomquantity:Set[${totQuantity}]
			MakeQlt[${processtype},${searchid}]:Set[${pQuality}]
		}

		if !${MainRecipe.Equal[${RecipeName}]} || ${NotMain}
		{
			totQuantity:Dec[${This.CalculateCraft[${MakeName[${processtype},${searchid}]},${MakeQlt[${processtype},${searchid}]},${processtype},${searchid},${produce}]}]
		}

		; Process Primary Component
		ComponentQuantites:Set[${primarycomponent},${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.QuantityOnHand}]
		if ${processtype}==2
		{
			tmpres:Set[${Harvests.FindSetting[${primarycomponent}]}]
			if ${tmpres.Length} && ${tmpres.NotEqual[NULL]}
			{
				This:AddResource[${tmpres},${Math.Calc[${rescomquantity}/${produce}]}]
				ComponentQuantites:Set[${tmpres},${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.QuantityOnHand}]
			}
			elseif ${Me.Recipe[${RecipeName}].Knowledge.Equal[Adorning]}
			{
				This:AddResource[${primarycomponent},${Math.Calc[${rescomquantity}/${produce}]}]
				ComponentQuantites:Set[${primarycomponent},${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.QuantityOnHand}]
			}
			else
			{
				if ${primarycomponent.Length} && ${primarycomponent.NotEqual[NULL]}
				{
					if !${WarnedResources[${primarycomponent}]}
					{
						WarnedResources:Set[${primarycomponent},TRUE]
						MessageBox -ok "WARNING! Unable to find \n\n${primarycomponent} \n\nin Resources.xml\n"
					}
				}
			}
		}
		else
		{
			This:ProcessRecipe[${primarycomponent},${pQuality},${totQuantity}]
		}

		; Process the Build Components
		tempval:Set[1]
		do
		{
			tmpbld:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.Name}]
			if ${This.SearchCommon[${tmpbld}]}
			{
				if ${tmpbld.Equal[Liquid]}
				{
					tmpbld:Set[Aerated Mineral Water]
				}
				This:AddCommon[${tmpbld},${Math.Calc[${rescomquantity}/${produce}*${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.Quantity}]}]
				ComponentQuantites:Set[${tmpbld},${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}]
			}
			else
			{
				tmpres:Set[${Harvests.FindSetting[${tmpbld}]}]
				if ${tmpres.Length} && ${tmpres.NotEqual[NULL]}
				{
					if ${This.SearchCommon[${tmpres}]}
					{
						This:AddCommon[${tmpres},${Math.Calc[${rescomquantity}/${produce}*${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.Quantity}]}]
						ComponentQuantites:Set[${tmpres},${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}]
					}
					else
					{
						This:AddResource[${tmpres},${Math.Calc[${rescomquantity}/${produce}*${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.Quantity}]}]
						ComponentQuantites:Set[${tmpres},${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}]
					}
				}
				elseif ${Me.Recipe[${RecipeName}].Knowledge.Equal[Adorning]}
				{
					This:AddResource[${tmpbld},${Math.Calc[${rescomquantity}/${produce}*${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.Quantity}]}]
					ComponentQuantites:Set[${tmpbld},${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}]
				}
				else
				{
					if ${tmpbld.Length} && ${tmpbld.NotEqual[N/A]} && ${tmpbld.NotEqual[NULL]}
					{
						if !${WarnedResources[${tmpbld}]}
						{
							WarnedResources:Set[${tmpbld},TRUE]
							MessageBox -ok "WARNING! Unable to find \n\n${tmpbld} \n\nin Resources.xml\n"
						}
					}
				}
			}
			tmpbld:Set[]
		}
		while ${tempval:Inc}<=4

		NotMain:Set[FALSE]
	}

	member:int SearchRecipe(string recipeid, int pQlt, int process)
	{
		variable int tempvar=1

		do
		{
			if ${MakeID[${process},${tempvar}]}==${recipeid} && ${MakeQlt[${process},${tempvar}]}==${pQlt}
			{
				return ${tempvar}
			}
		}
		while ${tempvar:Inc}<=${MakeCnt[${process}]}
		return 0
	}

	member:bool SearchCommon(string chkbuildcomp)
	{
		if ${VendorBought.FindSetting[${chkbuildcomp}]}
		{
			return TRUE
		}
		return FALSE
	}

	member:bool SearchRare(string rarecomp)
	{
		Rares:GetSettingIterator[sIterator]
		if ${sIterator:First(exists)}
		{
			do
			{
				if ${rarecomp.Find[${sIterator.Key}]}
				{
					return TRUE
				}
			}
			while ${sIterator:Next(exists)}
		}
	}

	member:bool SearchPartialRare(string rarecomp)
	{
		Rares:GetSettingIterator[sIterator]
		if ${sIterator:First(exists)}
		{
			do
			{
				if ${rarecomp.Find[${sIterator.Value}]}
				{
					return TRUE
				}
			}
			while ${sIterator:Next(exists)}
		}
		return FALSE
	}

	method AddResource(string resource, int resqty)
	{
		variable bool resfnd
		variable int tempvar

		resfnd:Set[FALSE]
		tempvar:Set[1]
		do
		{
			if ${resource.Equal["${StatResNme[${tempvar}]}"]}
			{
				StatResCnt[${tempvar}]:Inc[${resqty}]
				resfnd:Set[TRUE]
				break
			}
		}
		while ${tempvar:Inc}<=${rescnt}

		if !${resfnd}
		{
			rescnt:Inc
			StatResNme[${rescnt}]:Set[${resource}]
			StatResCnt[${rescnt}]:Inc[${resqty}]
		}
	}

	method AddCommon(string common, int comqty)
	{
		variable bool comfnd
		variable int tempvar

		comfnd:Set[FALSE]
		tempvar:Set[1]
		do
		{
			if ${common.Equal[${StatComNme[${tempvar}]}]}
			{
				StatComCnt[${tempvar}]:Inc[${comqty}]
				comfnd:Set[TRUE]
				break
			}
		}
		while ${tempvar:Inc}<=${rescnt}

		if !${comfnd}
		{
			comcnt:Inc
			StatComNme[${comcnt}]:Set[${common}]
			StatComCnt[${comcnt}]:Inc[${comqty}]
		}
	}

	method AddRecipe()
	{
		variable int tempvar

		UIElement[Craft Selection].FindUsableChild[Start Crafting,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Hide
		UIElement[Craft Selection].FindUsableChild[Process Recipe,variablegauge]:Show
		UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:Show

		gaugelevel:Set[0.05]
		gaugefactor:Set[1]

		QOverride:Set[4]

		MainRecipe:Set["${UIElement[Craft Selection].FindUsableChild[Recipe List,combobox].SelectedItem.Text}"]
		MainRecipe:Set[${MainRecipe.Token[1,[]}]

		tempvar:Set[0]
		while ${tempvar:Inc}<5
		{
			if ${Quality${tempvar}}
			{
				gaugelevel:Set[0.1]
				This:AddtoRecipeList[${MainRecipe},${UIElement[Craft Selection].FindUsableChild[Quantity Value,textentry].Text}]
				gaugelevel:Set[0.3]
				This:ProcessRecipe[${MainRecipe},${tempvar},${UIElement[Craft Selection].FindUsableChild[Quantity Value,textentry].Text}]
				This:CalculateComponents
				gaugelevel:Set[0.9]
				call CheckInventory
				gaugelevel:Set[1]
				This:InitGUI
				thisbuttondisabled:Set[0]
				UIElement[Craft Selection].FindUsableChild[Process Recipe,variablegauge]:Hide
				UIElement[Craft Selection].FindUsableChild[Gauge Label,text]:Hide
				UIElement[Craft Selection].FindUsableChild[Start Crafting,commandbutton]:Show
				UIElement[Craft Selection].FindUsableChild[Save List,commandcheckbox]:Show
				UIElement[Craft Selection].FindUsableChild[Add Recipe,commandbutton]:Show
				return
			}
		}
	}

	method RefreshList()
	{
		variable int tempvar
		UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:ClearItems
		RecipeListMin:Set[${UIElement[Craft Selection].FindUsableChild[Level Min,textentry].Text}]
		RecipeListMax:Set[${UIElement[Craft Selection].FindUsableChild[Level Max,textentry].Text}]

		if ${RecipeListRange}
		{
			Configuration.FindSetting[Recipe List Minimum Range]:Set[${RecipeListMin}]
			Configuration.FindSetting[Recipe List Maximum Range]:Set[${RecipeListMax}]
			LavishSettings[Craft Config File]:Export[${configfile}]
		}

		tempvar:Set[0]
		ShowSTS:Set[FALSE]
		while ${tempvar:Inc}<=${Me.NumRecipes}
		{
			if ${Me.Recipe[${tempvar}].Level}>=${RecipeListMin} && ${Me.Recipe[${tempvar}].Level}<=${RecipeListMax}
			{
				if ${Me.Recipe[${tempvar}].Knowledge.Equal[Tinkering]} || ${Me.Recipe[${tempvar}].Knowledge.Equal[Adorning]}
				{
					if !${ShowSTS}
					{
						UIElement[Craft Selection].FindUsableChild[Secondary Tradeskill,Checkbox]:SetText[${Me.Recipe[${tempvar}].Knowledge}]
						UIElement[Craft Selection].FindUsableChild[Secondary Tradeskill,Checkbox]:Show
						ShowSTS:Set[TRUE]
					}
					if ${SecondaryTS}
					{
						UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:AddItem[${Me.Recipe[${tempvar}].Name} \[${Me.Recipe[${tempvar}].Level}\],${Me.Recipe[${tempvar}].Level}]
					}
					continue
				}

				if ${Me.Recipe[${tempvar}].Name.Find[Adept III]} || ${This.SearchPartialRare[${Me.Recipe[${tempvar}].Name}]}
				{
					if ${RareFilter}
					{
						UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:AddItem[${Me.Recipe[${tempvar}].Name} \[${Me.Recipe[${tempvar}].Level}\],${Me.Recipe[${tempvar}].Level}]
					}
					continue
				}

				if ${Me.Recipe[${tempvar}].Name.Left[6].Equal[Imbued]} || ${Me.Recipe[${tempvar}].Name.Left[7].Equal[Blessed]}
				{
					if ${ImbuedFilter}
					{
						UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:AddItem[${Me.Recipe[${tempvar}].Name} \[${Me.Recipe[${tempvar}].Level}\],${Me.Recipe[${tempvar}].Level}]
					}
					continue
				}

				if ${StandardFilter}
				{
					UIElement[Craft Selection].FindUsableChild[Recipe List,combobox]:AddItem[${Me.Recipe[${tempvar}].Name} \[${Me.Recipe[${tempvar}].Level}\],${Me.Recipe[${tempvar}].Level}]
				}
			}
		}

		if !${ShowSTS}
			UIElement[Craft Selection].FindUsableChild[Secondary Tradeskill,Checkbox]:Hide

		if ${SortLevel}
		{
			This:SortbyName
		}
		else
		{
			This:SortbyLevel
		}

		thisbuttonrefresh:Set[0]
	}

	method ClearAllRecipes(int rskip)
	{
		variable int tempvar1
		variable int tempvar2

		gaugelevel:Set[0.1]

		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:SetText[Clearing the Recipe Queue..]
		UIElement[Craft Selection].FindUsableChild[Submit Button,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[Save Recipe Queue,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[Clear Recipe Queue,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[List Recipe,variablegauge]:Show
		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:Show

		fuelcnt:Set[0]
		rescnt:Set[0]
		comcnt:Set[0]
		craftcnt:Set[0]
		queuecnt:Set[0]

		tempvar1:Set[0]
		while ${tempvar1:Inc}<=4
		{
			MakeCnt[${tempvar1}]:Set[0]
			tempvar2:Set[0]
			while ${tempvar2:Inc}<=100
			{
				MakeQty[${tempvar1},${tempvar2}]:Set[0]
				MakeName[${tempvar1},${tempvar2}]:Set[]
				MakeID[${tempvar1},${tempvar2}]:Set[0]
				MakeLevel[${tempvar1},${tempvar2}]:Set[0]
				MakeKnowledge[${tempvar1},${tempvar2}]:Set[]
				MakeDevice[${tempvar1},${tempvar2}]:Set[]
				MakeQlt[${tempvar1},${tempvar2}]:Set[0]
				MakeFuelName[${tempvar1},${tempvar2}]:Set[]
				MakeFuelCnt[${tempvar1},${tempvar2}]:Set[0]
				MakeProduce[${tempvar1},${tempvar2}]:Set[0]
				StatCraftCnt[${tempvar2},${tempvar1}]:Set[0]
				StatCraftTot[${tempvar1},${tempvar2}]:Set[0]

				if ${tempvar1}==1
				{
					StatFuelNme[${tempvar2}]:Set[]
					StatResNme[${tempvar2}]:Set[]
					StatComNme[${tempvar2}]:Set[]
					StatCraftNme[${tempvar2}]:Set[]
					StatFuelCnt[${tempvar2}]:Set[0]
					StatFuelTot[${tempvar2}]:Set[0]
					StatResCnt[${tempvar2}]:Set[0]
					StatResTot[${tempvar2}]:Set[0]
					StatComCnt[${tempvar2}]:Set[0]
					StatComTot[${tempvar2}]:Set[0]
				}

				if ${gaugelevel}<1
				{
					gaugelevel:Inc[0.0025]
				}
			}
		}

		UIElement[Craft Selection].FindUsableChild[Harvest Resource List,listbox]:ClearItems
		UIElement[Craft Selection].FindUsableChild[Vendor Bought List,listbox]:ClearItems
		UIElement[Craft Selection].FindUsableChild[Fuel List,listbox]:ClearItems
		UIElement[Craft Selection].FindUsableChild[Crafted List,listbox]:ClearItems

		if !${rskip}
		{
			UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:ClearItems
		}

		thisbuttonlist:Set[0]

		UIElement[Craft Selection].FindUsableChild[List Recipe,variablegauge]:Hide
		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:Hide
		UIElement[Craft Selection].FindUsableChild[Submit Button,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Save Recipe Queue,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Clear Recipe Queue,commandbutton]:Show

		RecipesInQueue:Clear
		ComponentQuantities:Clear
	}

	method AddtoRecipeList(string xRecipe,int xQuantity)
	{
		variable bool recpfnd
		variable int tempvar

		tempvar:Set[1]
		do
		{
			if ${xRecipe.Equal[${QueueList[${tempvar}]}]}
			{
				QueueQty[${tempvar}]:Inc[${xQuantity}]
				recpfnd:Set[TRUE]
				break
			}
		}
		while ${tempvar:Inc}<=${queuecnt}

		if !${recpfnd}
		{
			queuecnt:Inc
			QueueList[${queuecnt}]:Set[${xRecipe}]
			QueueQty[${queuecnt}]:Set[${xQuantity}]
		}

		UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:ClearItems
		;UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:AddItem[ ]
		tempvar:Set[1]
		do
		{
			if ${queuecnt}
			{
				UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:SetTextColor[FFFF5F00]:AddItem[${QueueList[${tempvar}]}| ${QueueQty[${tempvar}]}]
			}
		}
		while ${tempvar:Inc}<=${queuecnt}
	}

	method LoadRecipeList()
	{
		variable int tempvar

		This:LoadQueue

		if !${queuecnt}
		{
			return
		}

		UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:ClearItems
		;UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:AddItem[ ]
		tempvar:Set[1]
		do
		{
			UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:SetTextColor[FFFF5F00]:AddItem[${QueueList[${tempvar}]}| ${QueueQty[${tempvar}]}]
		}
		while ${tempvar:Inc}<=${queuecnt}
	}

	method RemoveRecipe()
	{
		while ${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].SelectedItems}
		{
			UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:RemoveItem[${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].SelectedItem[1].ID}]
		}
	}

	method LoadQueue(string Filename)
	{
		variable iterator sIter
		if !${CraftQueue.Children(exists)}
		{
			if !${This.LoadAndValidateQueue[${UIElement[Craft Selection].FindUsableChild[Favourites List,combobox].SelectedItem.Text}]}
				return
		}
		CraftQueue:GetSettingIterator[sIter]
		if ${sIter:First(exists)}
		{
			do
			{
				queuecnt:Inc
				QueueList[${queuecnt}]:Set[${sIter.Key}]
				QueueQty[${queuecnt}]:Set[${sIter.Value}]
			}
			while ${sIter:Next(exists)}
		}
		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:SetSortType[text]:Sort
		CraftQueue:Clear
	}

	method SaveQueue(string listname)
	{
		variable int tempvar=0
		variable string tmplist
		CraftQueue:Clear

		while ${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Item[${tempvar:Inc}](exists)}
		{
			tmplist:Set[${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Item[${tempvar}]}]
			CraftQueue:AddSetting[${tmplist.Token[1,|]},${tmplist.Token[2,|]}]
		}

		CraftQueue:Export[${QueuePath}/${Me.TSSubClass}-${listname}.xml]

		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:ClearItems

		This:PopulateFavorites[${Me.TSSubClass}]

		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox]:SetSortType[text]:Sort
		UIElement[Craft Selection].FindUsableChild[Favourites List,combobox].ItemByText[Last Saved Queue List]:Select
		CraftQueue:Clear
	}

	member:bool PurchaseCommon()
	{
		variable int xvar

		xvar:Set[1]
		do
		{
			if ${Math.Calc[${StatComCnt[${xvar}]}-${StatComTot[${xvar}]}]}
			{
				return TRUE
			}
		}
		while ${xvar:Inc}<=${comcnt}
		return FALSE
	}

	member:bool PurchaseFuel()
	{
		variable int xvar

		xvar:Set[1]
		do
		{
			if ${Math.Calc[${StatFuelCnt[${xvar}]}-${StatFuelTot[${xvar}]}]}
			{
				return TRUE
			}
		}
		while ${xvar:Inc}<=${fuelcnt}
		return FALSE
	}

	member:bool PurchaseHarvest()
	{
		variable int xvar

		xvar:Set[1]
		do
		{
			if ${Math.Calc[${StatResCnt[${xvar}]}-${StatResTot[${xvar}]}]}
			{
				return TRUE
			}
		}
		while ${xvar:Inc}<=${rescnt}
		return FALSE
	}

	method LoadLevel()
	{
		variable int tempvar
		variable int tempvar2
		variable int tmplevel
		variable string tmprfile
		variable string tmpknowledge
		variable bool addcurrentrecipe

		gaugelevel:Set[0]

		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:SetText[Currently Retrieving Recipes..]
		UIElement[Craft Selection].FindUsableChild[Submit Button,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[Save Recipe Queue,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[Clear Recipe Queue,commandbutton]:Hide
		UIElement[Craft Selection].FindUsableChild[List Recipe,variablegauge]:Show
		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:Show

		if !${UIElement[Craft Selection].FindUsableChild[Craft List,listbox].Item[1](exists)}
		{
			;UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:AddItem[ ]
		}

		tempvar:Set[0]
		while ${tempvar:Inc}<=${Me.NumRecipes}
		{
			tmplevel:Set[${UIElement[Craft Selection].FindUsableChild[Level Value,textentry].Text}]
			addcurrentrecipe:Set[FALSE]

			if ${Me.Recipe[${tempvar}].Level}==${tmplevel}
			{
				if ${Me.Recipe[${tempvar}].Knowledge.Equal[Tinkering]} || ${Me.Recipe[${tempvar}].Knowledge.Equal[Adorning]}
				{
					if !${SecondaryTS}
					{
						continue
					}
					addcurrentrecipe:Set[TRUE]
				}

				if ${Me.Recipe[${tempvar}].Name.Find[Adept III]} || ${This.SearchPartialRare[${Me.Recipe[${tempvar}].Name}]}
				{
					if !${RareFilter}
					{
						continue
					}
					addcurrentrecipe:Set[TRUE]
				}

				if ${Me.Recipe[${tempvar}].Name.Left[6].Equal[Imbued]} || ${Me.Recipe[${tempvar}].Name.Left[7].Equal[Blessed]}
				{
					if !${ImbuedFilter}
					{
						continue
					}
					addcurrentrecipe:Set[TRUE]
				}

				if !${StandardFilter} && !${addcurrentrecipe}
				{
					continue
				}

				if ${gaugelevel}<0.9
				{
					gaugelevel:Inc[0.05]
				}
				else
				{
					gaugelevel:Set[0.05]
				}

				queuecnt:Inc
				QueueList[${queuecnt}]:Set[${Me.Recipe[${tempvar}].Name}]
				QueueQty[${queuecnt}]:Set[${UIElement[Craft Selection].FindUsableChild[Qty Level Value,textentry].Text}]
				UIElement[Craft Selection].FindUsableChild[Craft List,listbox]:SetTextColor[FFFF5F00]:AddItem[${Me.Recipe[${tempvar}].Name}| ${UIElement[Craft Selection].FindUsableChild[Qty Level Value,textentry].Text}]
			}
		}

		gaugelevel:Set[1]

		UIElement[Craft Selection].FindUsableChild[List Recipe,variablegauge]:Hide
		UIElement[Craft Selection].FindUsableChild[Gauge List Label,text]:Hide
		UIElement[Craft Selection].FindUsableChild[Submit Button,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Save Recipe Queue,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Clear Recipe Queue,commandbutton]:Show
		UIElement[Craft Selection].FindUsableChild[Add Level,commandbutton]:Show

		thisbuttonadd:Set[0]
	}

	method CancelBuffs()
	{
		variable int tempvar
		variable int art1
		variable int art2
		variable int art3

		while ${tempvar:Inc}<=${Me.CountMaintained}
		{
			art1:Set[0]
			while ${art1:Inc}<=2
			{
				art2:Set[0]
				while ${art2:Inc}<=3
				{
					if ${Me.Maintained[${tempvar}].Name.Equal[${TSSpell[${art1},${art2}]}]}
					{
						Me.Maintained[${tempvar}]:Cancel
					}
				}
			}

			art3:Set[0]
			while ${art3:Inc}<=4
			{
				if ${Me.Maintained[${tempvar}].Name.Equal[${SecondarySkill[${art3}]}]}
				{
					Me.Maintained[${tempvar}]:Cancel
				}
			}
		}
	}

	method SaveThreshold()
	{
		variable int tempvar

		while ${tempvar:Inc}<=4
		{
			Durability[1,${tempvar}]:Set[${UIElement[Craft Selection].FindUsableChild[Standard Quality${tempvar},textentry].Text}]
			Durability[2,${tempvar}]:Set[${UIElement[Craft Selection].FindUsableChild[Rare Quality${tempvar},textentry].Text}]
			Configuration.FindSetting[Durability Threshold for Standard Quality ${tempvar}?]:Set[${Durability[1,${tempvar}]}]
			Configuration.FindSetting[Durability Threshold for Rare Quality ${tempvar}?]:Set[${Durability[2,${tempvar}]}]
		}
		LavishSettings[Craft Config File]:Export[${configfile}]
	}

	method CheckThresholds()
	{
		variable int tempvar

		;; Check just a couple of values to see if this is the first time that craft has been used.
		if ${Durability[1,1]} == 0  || ${Durability[1,3]} == 0
		{
			This:ResetThreshold
			This:SaveThreshold
			return
		}
		else
		{
			while ${tempvar:Inc}<=4
			{
				UIElement[Craft Selection].FindUsableChild[Standard Quality${tempvar},textentry]:SetText[${Durability[1,${tempvar}]}]
				UIElement[Craft Selection].FindUsableChild[Rare Quality${tempvar},textentry]:SetText[${Durability[2,${tempvar}]}]
			}
		}
	}

	method ResetThreshold()
	{
		variable int tempvar

		Durability[1,1]:Set[110]
		Durability[1,2]:Set[90]
		Durability[1,3]:Set[30]
		Durability[1,4]:Set[0]
		Durability[2,1]:Set[110]
		Durability[2,2]:Set[90]
		Durability[2,3]:Set[30]
		Durability[2,4]:Set[0]

		while ${tempvar:Inc}<=4
		{
			UIElement[Craft Selection].FindUsableChild[Standard Quality${tempvar},textentry]:SetText[${Durability[1,${tempvar}]}]
			UIElement[Craft Selection].FindUsableChild[Rare Quality${tempvar},textentry]:SetText[${Durability[2,${tempvar}]}]
		}
	}
}

atom(script) EQ2_onCraftRoundResult()
{
	CurrentReactive:Set[${Crafting.Message}]
	CurrentQuality:Set[${Crafting.Quality}]
	CurrentProgress:Set[${Crafting.Progress}]
	CurrentDurability:Set[${Crafting.Durability}]
	ChangeinDur:Set[${Crafting.DurabilityMod}]
	roundstart:Set[TRUE]
	if ${Crafting.Message.Find[Innovation]}
		ChatSay "Encountered a rare reaction!"
}

atom(script) EQ2_onQuestOffered(string sName, string sDescription, int iLevel, int iStatusReward)
{
	; If you are running craft...assume that any quest recieved is a writ (at least, if we are doing writs anyway)

	if ${EnableDebug}
	{
		Debug:Echo[QUEST OFFER RECEIVED]
		Debug:Echo["NAME: ${sName}"]
		Debug:Echo["DESCRIPTION: ${sDescription}"]
		Debug:Echo["LEVEL: ${iLevel} STATUSREWARD: ${iStatusReward}"]
	}

	WritLevel:Set[${iLevel}]
}

atom(script) EQ2_onIncomingText(string Text)
{
	if (${Text.Find["Your tradeskill level is now"]} > 0)
	{
		LevelGained:Set[${Text.Right[3].Left[2]}]
	}

	if (${Text.Find["Not enough coin."]} > 0)
	{
		NotEnoughCoin:Set[TRUE]
	}

	if ${StopCraftingAtSecondaryMaxLevel}
	{
		if (${Text.Find["Tinkering"]} > 0 || ${Text.Find["Adorning"]} > 0)
		{
			variable string Numbers = ${Text.Token[2,(]}
			variable string CurrentSkill = ${Numbers.Token[1,/]}
			variable string MaxSkill = ${Numbers.Token[2,/].Left[3]}

			if ${CurrentSkill} == ${MaxSkill}
			{
				ChatEcho "EQ2Craft:: Your secondary tradeskill level has reached ${CurrentSkill}/${MaxSkill} -- ending script!"
				Script:End
			}
		}
	}
}

atom(script) EQ2_onInventoryUpdate()
{
	invupdate:Set[TRUE]
}

atom UpdateSettings()
{
	Configuration.FindSetting[Camp out after a 2+ hour Session once crafting has finished?]:Set[${CampOut}]
	Configuration.FindSetting[Display entire shopping list?]:Set[${ShowAllLists}]
	Configuration.FindSetting[Use the current TARGETTED Station only?]:Set[${CurrentStation}]
	Configuration.FindSetting[Save Recipe List when Crafting Begins?]:Set[${SaveList}]
	Configuration.FindSetting[Buy ALL Vendor bought components automatically?]:Set[${BuyCommon}]
	Configuration.FindSetting[Buy ALL FUEL components automatically?]:Set[${BuyFuel}]
	Configuration.FindSetting[Buy ALL Harvests from Broker automatically?]:Set[${BuyHarvest}]
	Configuration.FindSetting[Prompt Resume Crafting when buying Harvests?]:Set[${PromptResume}]
	Configuration.FindSetting[Camp out after Craft Session is complete?]:Set[${CampNow}]
	Configuration.FindSetting[Show only Secondary Tradeskill Recipes?]:Set[${SecondaryTS}]
	Configuration.FindSetting[Show All Standard Recipes?]:Set[${StandardFilter}]
	Configuration.FindSetting[Show All Imbued Recipes?]:Set[${ImbuedFilter}]
	Configuration.FindSetting[Show All Rare Recipes?]:Set[${RareFilter}]
	Configuration.FindSetting[Wait for Power to Regenerate before crafting a recipe?]:Set[${WaitforPower}]
	Configuration.FindSetting[Save Recipe List Range?]:Set[${RecipeListRange}]
	Configuration.FindSetting[GuildPrivacy]:Set[${GuildPrivacy}]
	Configuration.FindSetting[GuildPrivacyAlways]:Set[${GuildPrivacyAlways}]
	Configuration.FindSetting[Decline Invites]:Set[${DeclineInvites}]
	Configuration.FindSetting[Enable TTS]:Set[${EnableTTS}]

	if ${RecipeListRange}
	{
		Configuration.FindSetting[Recipe List Minimum Range]:Set[${RecipeListMin}]
		Configuration.FindSetting[Recipe List Maximum Range]:Set[${RecipeListMax}]
	}
	else
	{
		Configuration.FindSetting[Recipe List Minimum Range]:Set[1]
		Configuration.FindSetting[Recipe List Maximum Range]:Set[1]
	}

	LavishSettings[Craft Config File]:Export[${configfile}]

	if ${GuildPrivacyAlways} && !${GuildPrivacySet}
	{
		if !${GuildPrivacySetting}
		{
			GuildPrivacySet:Set[TRUE]
			eq2execute "guild event_privacy true"
		}
	}
	if !${GuildPrivacyAlways} && ${GuildPrivacySet}
	{
		GuildPrivacySet:Set[FALSE]
		eq2execute "guild event_privacy false"
	}
}

atom(script) EQ2_onQuestUpdate(string ID, string Name, string CurrentZone, string Category, string Description, ... ProgressText)
{
	variable int i=3
	variable int tempvar
	variable string pText
	variable string CheckString
	variable string RecipeName
	variable bool CaseCheck
	variable string Quantities

	; Check to see if we are actually doing writs before we update anything
	if !${ISXEQ2.GetCustomVariable[SRO,bool]} && !${ISXEQ2.GetCustomVariable[SWO,bool]}
	{
		return
	}

	if ${GotWrit}
	{
		UpdateRecipeCount:Set[TRUE]
		return
	}

	if !${WritTrigger} && ${ProgressText.Size}<3
	{
		return
	}

	if ${EnableDebug}
	{
		Debug:Echo[QUEST UPDATE RECEIVED]
		Debug:Echo["ID: ${ID}"]
		Debug:Echo["Name: ${Name}"]
		Debug:Echo["Current Zone: ${CurrentZone}"]
		Debug:Echo["Category: ${Category}"]
		Debug:Echo["Description: ${Description}"]

		do
		{
			Debug:Log["Progress Text: ${ProgressText[${i}]}"]
		}
		while ${i:Inc} <= ${ProgressText.Size}
	}

	i:Set[3]
	RecipeCount:Set[0]
	do
	{
		tempvar:Set[1]
		pText:Set[${ProgressText[${i}]}]
		CheckString:Set[""]
		CaseCheck:Set[FALSE]
		if ${pText.Left[17].Equal[I need to create:]}
			RecipeName:Set[${pText.Right[-17]}]
		elseif ${pText.Left[14].Equal[I must create:]}
			RecipeName:Set[${pText.Right[-14]}]
		elseif ${pText.Find[(Journeyman)]} /* Spell or ability. */
			RecipeName:Set[${pText.Right[-17]}]
		elseif ${pText.Left[18].Equal[I need to create a]}
			RecipeName:Set[${pText.Right[-19].Left[-1]}]
		elseif ${Me.TSSubClass.Equal[provisioner]}
			RecipeName:Set[${pText.Right[-10].Left[-1]}]
		else
			RecipeName:Set[${pText.Right[-16].Left[-1]}]

		CheckString:Set[${Craft.ValidateRecipe[${RecipeName}]}]
		if ${EnableDebug}
		{
			if !${CheckString.Equal[NULL]}
				Debug:Log["Extracted Recipe Name: ${CheckString}"]
			else
				Debug:Log["UNABLE to extract recipe from ${RecipeName}"]
		}
		if !${CheckString.Equal[NULL]}
			RecipeName:Set[${CheckString}]

		FailedRecipe:Insert["${RecipeName},${WritQty}"]
	}
	while ${i:Inc} <= ${ProgressText.Size}

	; Note:  WritLevel is now set in EQ2_onQuestOffered(); however, just in case it is bogus...use old method
	if (${WritLevel} > ${Me.TSLevel} || ${WritLevel} <= 0)
	{
		Debug:Echo["Warning: Using old method to determine writ level, previous writ level was ${WritLevel}"]
		if (${Me.TSLevel}%10>=0 && ${Me.TSLevel}%10<4 && (${Tier}==1 || ${Tier}==4)) || (${Me.TSLevel}%10>=4 && ${Me.TSLevel}%10<9 && ${Tier}==2) || (${Me.TSLevel}%10==9 && ${Tier}==3)
		{
			WritLevel:Set[${Math.Calc[${Me.TSLevel}-(${Me.TSLevel}%10)]}]
			if (${Tier}==4)
				WritLevel:Dec[10]
			if (${Me.TSLevel}==90 && ${Tier}==1)
				WritLevel:Set[89]
		}
		elseif (${Me.TSLevel}%10>=4 && ${Me.TSLevel}%10<9 && (${Tier}==1 || ${Tier}==4)) || (${Me.TSLevel}%10==9 && ${Tier}==2) || (${Me.TSLevel}%10>=0 && ${Me.TSLevel}%10<4 && ${Tier}==3)
		{
			WritLevel:Set[${Math.Calc[${Me.TSLevel}-(${Me.TSLevel}%10)+4]}]
			if (${Tier}>=3)
				WritLevel:Dec[10]
		}
		elseif (${Me.TSLevel}%10==9 && (${Tier}==1 || ${Tier}==4)) || (${Me.TSLevel}%10>=0 && ${Me.TSLevel}%10<4 && ${Tier}==2) || (${Me.TSLevel}%10>=4 && ${Me.TSLevel}%10<9 && ${Tier}==3)
		{
			WritLevel:Set[${Math.Calc[${Me.TSLevel}-(${Me.TSLevel}%10)+9]}]
			if (${Tier}>=2)
				WritLevel:Dec[10]
		}
		Debug:Echo["Determined Writ Level as ${WritLevel}"]
	}

	RecipeCount:Set[${FailedRecipe.Used}]
	Quantities:Set["${WritCounts.FindSet[${Me.TSSubClass}].FindSetting[${WritLevel}].String}"]

	if ${Math.Calc[${Arg[1,${Quantities}]}]}==0
	{
		ErrorEcho "EQ2Craft:: Please edit the WritCounts.xml file to set the writ quantities for level ${WritLevel} under ${Me.TSSubClass}."
		ErrorEcho "EQ2Craft:: Ending Script"
		QueueCommand call ErrorExit "Please edit the WritCounts.xml file to set the writ quantities for level ${WritLevel} under ${Me.TSSubClass}."
	}
	do
	{
		if (${ISXEQ2.GetCustomVariable[SWO,bool]})
		{
			FailedRecipe:Set[${RecipeCount},${Arg[1,${FailedRecipe.Get[${RecipeCount}]}]}\,${Math.Calc[${Arg[${RecipeCount},${Quantities}]}*2]}]
		}
		if (${ISXEQ2.GetCustomVariable[SRO,bool]})
		{
			FailedRecipe:Set[${RecipeCount},${Arg[1,${FailedRecipe.Get[${RecipeCount}]}]}\,${Arg[${RecipeCount},${Quantities}]}]
		}
	}
	while ${RecipeCount:Dec} > 0

	RecipeCount:Set[${FailedRecipe.Used}]

	GotWrit:Set[TRUE]
}

atom EQ2_onChoiceWindowAppeared()
{
	;; I do not think we are using this at all!
	;; Used only for auto-transmute. -- Valerian

	if !${ChoiceWindow.Text.GetProperty[LocalText].Find[Are you sure you want to transmute the]}
		return
	if ${ChoiceWindow.Choice1.Find[Accept]}
		ChoiceWindow:DoChoice1
}

function ErrorExit(string Error)
{
	messagebox -skin eq2 "${Error}"
	Script:End
}

function CheckInventory()
{
	variable int xvar=1
	variable int tmpReturn
	variable bool UpdatedQtys=FALSE

	if (${rescnt} > 0)
	{
		do
		{
			call CheckComponentQuantities "${StatResNme[${xvar}]}"
			if (${Return} < ${StatResCnt[${xvar}]})
			{
				if !${UpdatedQtys}
				{
					call CheckComponentQuantities "${StatResNme[${xvar}]}" 1
					UpdatedQtys:Set[TRUE]
				}
				StatResTot[${xvar}]:Set[${Return}]
			}
			else
				StatResTot[${xvar}]:Set[${Return}]

			if ${StatResTot[${xvar}]}>=${StatResCnt[${xvar}]}
			{
				StatResTot[${xvar}]:Set[${StatResCnt[${xvar}]}]
			}
		}
		while ${xvar:Inc}<=${rescnt}
	}

	if (${comcnt} > 0)
	{
		xvar:Set[1]
		do
		{
			call CheckComponentQuantities "${StatComNme[${xvar}]}"
			if (${Return} < ${StatComCnt[${xvar}]})
			{
				if !${UpdatedQtys}
				{
					call CheckComponentQuantities "${StatComNme[${xvar}]}" 1
					UpdatedQtys:Set[TRUE]
				}
				StatComTot[${xvar}]:Set[${Return}]
			}
			else
				StatComTot[${xvar}]:Set[${Return}]

			if ${StatComTot[${xvar}]}>=${StatComCnt[${xvar}]}
			{
				StatComTot[${xvar}]:Set[${StatComCnt[${xvar}]}]
			}
		}
		while ${xvar:Inc}<=${comcnt}
	}

	if (${fuelcnt} > 0)
	{
		xvar:Set[1]
		do
		{
			call CheckComponentQuantities "${StatFuelNme[${xvar}]}"
			if (${Return} < ${StatFuelCnt[${xvar}]})
			{
				if !${UpdatedQtys}
				{
					call CheckComponentQuantities "${StatFuelNme[${xvar}]}" 1
					UpdatedQtys:Set[TRUE]
				}
				StatFuelTot[${xvar}]:Set[${Return}]
			}
			else
				StatFuelTot[${xvar}]:Set[${Return}]

			if ${StatFuelTot[${xvar}]}>=${StatFuelCnt[${xvar}]}
			{
				StatFuelTot[${xvar}]:Set[${StatFuelCnt[${xvar}]}]
			}
		}
		while ${xvar:Inc}<=${fuelcnt}
	}
}

function UpdateComponentQuantities()
{
	variable string RecipeName
	variable int i = 1
	variable string primarycomponent
	variable string tmpres
	variable string tmpbld
	variable int tempval
	variable int Counter

	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	do
	{
		RecipeName:Set[${RecipesInQueue.Get[${i}]}]
		if (!${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.Name(exists)})
		{
			Debug:Echo["EQ2Craft:: UpdateComponentQuantities() - '${RecipeName} fuel was not available"]
			return FALSE
			;Counter:Set[0]
			;do
			;{
			;	waitframe
			;	Counter:Inc
			;	if ${Counter} > 1000
			;		break
			;}
			;while !${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.Name(exists)}
		}
		;; Adding Fuel Count to ComponentQuantities
		UpdateComponent "${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.Name}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.Fuel.QuantityOnHand}


		; Process the Build Components
		tempval:Set[1]
		do
		{
			if (!${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}(exists)})
			{
				Debug:Echo["EQ2Craft:: UpdateComponentQuantities() - '${RecipeName} buildcomponent was not available"]
				return FALSE
				;Counter:Set[0]
				;do
				;{
				;	waitframe
				;	Counter:Inc
				;	if ${Counter} > 1000
				;		break
				;}
				;while !${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}(exists)}
			}
			tmpbld:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.Name}]
			if ${This.SearchCommon[${tmpbld}]}
			{
				if ${tmpbld.Equal[Liquid]}
				{
					tmpbld:Set[Aerated Mineral Water]
				}
				UpdateComponent "${tmpbld}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}
			}
			else
			{
				tmpres:Set[${Harvests.FindSetting[${tmpbld}]}]
				if ${tmpres.Length} && ${tmpres.NotEqual[NULL]}
				{
					if ${This.SearchCommon[${tmpres}]}
					{
						UpdateComponent "${tmpres}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}
					}
					else
					{
						if ${tmpres.Equal[Liquid]}
						{
							tmpres:Set[Aerated Mineral Water]
						}
						UpdateComponent "${tmpres}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}
					}
				}
				elseif ${Me.Recipe[${RecipeName}].Knowledge.Equal[Adorning]}
				{
					UpdateComponent "${tmpbld}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.BuildComponent${tempval}.QuantityOnHand}
				}
				else
				{
					if ${tmpbld.Length} && ${tmpbld.NotEqual[N/A]} && ${tmpbld.NotEqual[NULL]}
					{
						if !${WarnedResources[${tmpbld}]}
						{
							WarnedResources:Set[${tmpbld},TRUE]
							MessageBox -ok "WARNING! Unable to find \n\n${tmpbld} \n\nin Resources.xml\n"
						}
					}
				}
			}
			tmpbld:Set[]
		}
		while ${tempval:Inc}<=4
	}
	while ${i:Inc} <= ${RecipesInQueue.Used}


	; Now process the Primary Components to ensure that our quantities are correct
	i:Set[1]
	do
	{
		; Process Primary Component
		if (!${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent(exists)})
		{
			Debug:Echo["EQ2Craft:: UpdateComponentQuantities() - '${RecipeName} primarycomponent was not available"]
			return FALSE
			;Counter:Set[0]
			;do
			;{
			;	waitframe
			;	Counter:Inc
			;	if ${Counter} > 1000
			;		break
			;}
			;while !${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent(exists)}
		}
		primarycomponent:Set[${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.Name}]
		UpdateComponent "${primarycomponent}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.QuantityOnHand}

		tmpres:Set[${Harvests.FindSetting[${primarycomponent}]}]
		if ${tmpres.Length} && ${tmpres.NotEqual[NULL]}
		{
			UpdateComponent "${tmpres}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.QuantityOnHand}
		}
		elseif ${Me.Recipe[${RecipeName}].Knowledge.Equal[Adorning]}
		{
			UpdateComponent "${primarycomponent}" ${Me.Recipe[${RecipeName}].ToRecipeInfo.PrimaryComponent.QuantityOnHand}
		}
	}
	while ${i:Inc} <= ${RecipesInQueue.Used}
	;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	return TRUE
}

atom UpdateComponent(string CompName, int AmtOnHand)
{
	if (${ComponentQuantites[${CompName}](exists)})
	{
		if ${AmtOnHand} != ${ComponentQuantites[${CompName}]}
		{
			ComponentQuantites:Set[${CompName},${AmtOnHand}]
		}
		if ${AmtOnHand} == 0
		{
			ComponentQuantities:Erase[${CompName}]
		}
	}
	elseif (${AmtOnHand} > 0)
	{
		ComponentQuantites:Set[${CompName},${AmtOnHand}]
	}
}

function CheckComponentQuantities(string itemsearch, bool DoFullSearch)
{
	if ${itemsearch.Length} <= 0
		return 0

	if ${DoFullSearch}
	{
		do
		{
			call UpdateComponentQuantities
		}
		while ${Return.Equal[FALSE]}
	}

	if ${itemsearch.Equal[Liquid]}
	{
		if (${ComponentQuantites.Element[Aerated Mineral Water](exists)})
		{
			if ${ComponentQuantites.Element[Aerated Mineral Water]} > 0
			{
				return ${ComponentQuantites.Element[Aerated Mineral Water]}
			}
		}
		elseif (${ComponentQuantites.Element[Distilled Water](exists)})
		{
			if ${ComponentQuantites.Element[Distilled Water]} > 0
			{
				return ${ComponentQuantites.Element[Distilled Water]}
			}
		}
	}
	elseif ${itemsearch.Find[Material]}
	{
		if (${ComponentQuantites.Element[${itemsearch.Token[1," "]} Material](exists)})
		{
			if ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Material]} > 0
			{
				return ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Material]}
			}
		}
		elseif (${ComponentQuantites.Element[${itemsearch.Token[1," "]} Stone](exists)})
		{
			if ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Stone]} > 0
			{
				return ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Stone]}
			}
		}
		elseif (${ComponentQuantites.Element[${itemsearch.Token[1," "]} Tooth](exists)})
		{
			if ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Tooth]} > 0
			{
				return ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Tooth]}
			}
		}
		elseif (${ComponentQuantites.Element[${itemsearch.Token[1," "]} Flower](exists)})
		{
			if ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Flower]} > 0
			{
				return ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Flower]}
			}
		}
		elseif (${ComponentQuantites.Element[${itemsearch.Token[1," "]} Fish Scale](exists)})
		{
			if ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Fish Scale]} > 0
			{
				return ${ComponentQuantites.Element[${itemsearch.Token[1," "]} Fish Scale]}
			}
		}
	}
	else
	{
		if (${ComponentQuantites.Element[${itemsearch}](exists)})
		{
			if ${ComponentQuantites.Element[${itemsearch}]} > 0
			{
				return ${ComponentQuantites.Element[${itemsearch}]}
			}
		}
	}


	return 0
}

function StopRunning()
{
	press -hold "${Nav.MOVEBACKWARD}"
	waitframe
	press -release "${Nav.MOVEBACKWARD}"
}

function CheckLevelGained()
{
	if (${LevelGained} > 20)
	{
		wait 50

		ChatEcho "EQ2Craft:: You have just gained a new tradeskill level!  Congratulations!"
		ChatSay "Congratulations! You are now a ${LevelGained} ${Me.TSSubClass}"
		ChatEcho "EQ2Craft:: Checking inventory for recipe books that need to be scribed"

		EQ2Execute /togglebags
		wait 25
		EQ2Execute /togglebags
		wait 10
		if (${Me.Inventory[${Me.TSSubClass} Essentials Volume ${LevelGained}](exists)})
		{
			Me.Inventory[${Me.TSSubClass} Essentials Volume ${LevelGained}]:Examine
			wait 10
			EQ2Execute /close_top_window
			wait 2
			Me.Inventory[${Me.TSSubClass} Essentials Volume ${LevelGained}]:Scribe
			ChatSay "Automatically scribing ${Me.TSSubClass} Essentials Volume ${LevelGained}"
			wait 2
		}
		else
			wait 5
		if (${Me.Inventory[Advanced ${Me.TSSubClass} Volume ${LevelGained}](exists)})
		{
			Me.Inventory[Advanced ${Me.TSSubClass} Volume ${LevelGained}]:Examine
			wait 10
			EQ2Execute /close_top_window
			wait 2
			Me.Inventory[Advanced ${Me.TSSubClass} Volume ${LevelGained}]:Scribe
			ChatSay "Automatically scribing Advanced ${Me.TSSubClass} Volume ${LevelGained}"
			wait 2
		}
		LevelGained:Set[0]
	}

}