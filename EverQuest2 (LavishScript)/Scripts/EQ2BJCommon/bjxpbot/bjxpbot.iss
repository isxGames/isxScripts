;// BJ XP Bot
;// First Created:  June 22, 2011
;// Written By: bjcasey
;// Many thanks to Kannkor for a TON of coding help.

;// Auto Potion Consume Variables
variable int StartTimeHour
variable bool TimeLimitReachedBool
variable bool ADVLevelLimitReachedBool
variable bool AALevelLimitReachedBool
variable bool TSLevelLimitReachedBool
variable string ItemToUse=None
variable bool bPaused=${Paused}
variable(global) TimerObject timeuntilnextmilli
variable settingsetref BJXPBot_Settings
variable settingsetref _ref
variable filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"

function LoadSettings()
{
	;// Load Settings
	LavishSettings:AddSet[BJXPBot]
	LavishSettings[BJXPBot]:Clear
	LavishSettings[BJXPBot]:AddSet[BJXPBot_Settings]
	LavishSettings[BJXPBot]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"]
	_ref:Set[${LavishSettings.FindSet[BJXPBot]}]
}

function SaveSettings()
{
	echo Saving Settings
;// Checkboxes		
		;// Vitality Potions
		if ${UIElement[EnableVitalityPotionsCheckbox@Potions_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableVitalityPotionsCheckbox,TRUE]
		else
			_ref:AddSetting[EnableVitalityPotionsCheckbox,FALSE]
		;// Experience Potions
		if ${UIElement[EnablePotionsCheckbox@Potions_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnablePotionsCheckbox,TRUE]
		else
			_ref:AddSetting[EnablePotionsCheckbox,FALSE]	
		;// Time Limit Checkbox
		if ${UIElement[EnableTimeLimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableTimeLimitCheckbox,TRUE]
		else
			_ref:AddSetting[EnableTimeLimitCheckbox,FALSE]			
		;// ADV Level Limit Checkbox
		if ${UIElement[EnableADVLevelLimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableADVLevelLimitCheckbox,TRUE]
		else
			_ref:AddSetting[EnableADVLevelLimitCheckbox,FALSE]
		;// AA Level Limit Checkbox
		if ${UIElement[EnableAALevelLimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAALevelLimitCheckbox,TRUE]
		else
			_ref:AddSetting[EnableAALevelLimitCheckbox,FALSE]	
		;// Enable Sound Checkbox
		if ${UIElement[EnableSoundLimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableSoundLimitCheckboxVar,TRUE]
		else
			_ref:AddSetting[EnableSoundLimitCheckboxVar,FALSE]			
		;// Enable AA Slider Bar 1 Checkbox
		if ${UIElement[EnableAASliderBar1LimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAASliderBar1LimitCheckboxVar,TRUE]
		else
			_ref:AddSetting[EnableAASliderBar1LimitCheckboxVar,FALSE]
		;// Enable AA Slider Bar 2 Checkbox
		if ${UIElement[EnableAASliderBar2LimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAASliderBar2LimitCheckboxVar,TRUE]
		else
			_ref:AddSetting[EnableAASliderBar2LimitCheckboxVar,FALSE]	
		;// Enable Limit Dropbox Checkbox
		if ${UIElement[EnableLimitDropboxCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableLimitDropboxCheckboxVar,TRUE]
		else
			_ref:AddSetting[EnableLimitDropboxCheckboxVar,FALSE]	
		;// ADV Experience Calculations Checkbox
		if ${UIElement[EnableAdvXPCheckbox@Exp_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAdvXPCheckbox,TRUE]
		else
			_ref:AddSetting[EnableAdvXPCheckbox,FALSE]
		;// TS Experience Calculations Checkbox
		if ${UIElement[EnableTSXPCheckbox@Exp_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableTSXPCheckbox,TRUE]
		else
			_ref:AddSetting[EnableTSXPCheckbox,FALSE]
		;// AA Experience Calculations Checkbox
		if ${UIElement[EnableAAXPCheckbox@Exp_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAAXPCheckbox,TRUE]
		else
			_ref:AddSetting[EnableAAXPCheckbox,FALSE]
		;// Enable IRC Relay Checkbox
		if ${UIElement[EnableIRCRelayCheckbox@Statistics_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableIRCRelayCheckboxVar,TRUE]
		else
			_ref:AddSetting[EnableIRCRelayCheckboxVar,FALSE]
		;// Enable Self Revive
		if ${UIElement[EnableSelfReviveOptionsCheckbox@Setup_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableSelfReviveOptionsCheckboxVar,TRUE]
		else
			_ref:AddSetting[EnableSelfReviveOptionsCheckboxVar,FALSE]		
				
;// Text Entries		
		;// Level Limit AA
		_ref:AddSetting[LevelAALimitVar,${LevelAALimitVar}]
		;// Level Limit ADV
		_ref:AddSetting[LevelAdvLimitVar,${LevelAdvLimitVar}]
		;// Level Limit TS
		_ref:AddSetting[LevelTSLimitVar,${LevelTSLimitVar}]
		;// Time Limit
		_ref:AddSetting[UserEndTimeVar,${UserEndTimeVar}]	
		;// Current Max Adv Level
		_ref:AddSetting[CurrentMaxAdvLevelEntryVar,${CurrentMaxAdvLevelEntryVar}]
		;// Current Max AA Level
		_ref:AddSetting[CurrentMaxAALevelEntryVar,${CurrentMaxAALevelEntryVar}]
		;// Current Max TS Level
		_ref:AddSetting[CurrentMaxTSLevelEntryVar,${CurrentMaxTSLevelEntryVar}]
		;// AA Slider Bar 1 Limit Level
		_ref:AddSetting[EnableAASliderBar1LimitTextEntryVar,${EnableAASliderBar1LimitTextEntryVar}]
		;// AA Slider Bar 2 Limit Level
		_ref:AddSetting[EnableAASliderBar2LimitTextEntryVar,${EnableAASliderBar2LimitTextEntryVar}]
		;// IRC Server Textentry
		_ref:AddSetting[IRCServerTextEntryVar,${IRCServerTextEntryVar}]
		;// IRC Channel Textentry
		_ref:AddSetting[IRCChannelTextEntryVar,${IRCChannelTextEntryVar}]
		;// IRC Nickname Suffix Textentry
		_ref:AddSetting[IRCNicknameSuffixTextEntryVar,${IRCNicknameSuffixTextEntryVar}]

;// Comboboxes		
		;// Limit Reached Combobox
		_ref:AddSetting[LimitReachedComboBoxVar,${LimitReachedComboBoxVar}]	
		;// Powerleveler Combobox
		_ref:AddSetting[PowerlevelerComboBoxVar,${PowerlevelerComboBoxVar}]	
		;// Powerleveler Options Combobox
		_ref:AddSetting[PowerlevelerOptionsComboBoxVar,${PowerlevelerOptionsComboBoxVar}]	
		;// Self Revive Options Combobox
		_ref:AddSetting[SelfReviveOptionsComboBoxVar,${SelfReviveOptionsComboBoxVar}]
		
;// Listboxes
		;// Priority Potion List
		if ${_ref.FindSetting[PotionPriorityListBoxTextVar1](exists)}
		{
			while ${_ref.FindSetting[PotionPriorityListBoxTextVar${d_count}](exists)}
			{
				_ref.FindSetting[PotionPriorityListBoxTextVar${d_count}]:Remove
				d_count:Inc
			}	
			while ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items} > 0 && ${PotionCount} <= ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items}
			{
				_ref:AddSetting[PotionPriorityListBoxTextVar${p_count},${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}]
				PotionCount:Inc
				p_count:Inc
			}
		}
		else		
		{
			while ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items} > 0 && ${PotionCount} <= ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items}
			{
				_ref:AddSetting[PotionPriorityListBoxTextVar${p_count},${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}]
				PotionCount:Inc
				p_count:Inc
			}
		}
		
		LavishSettings[BJXPBot]:Export["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"]
		
	return	
}


function main()
{
	call LoadSettings
	
	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
	
	ExecuteQueued
	
	StartTimeHour:Set[${Time.Hour}]
	EnableConsumePotion:Set[1]
	PlaySoundBool:Set[1]
	PlayPLSoundBool:Set[1]
	TimeLimitReachedBool:Set[1]
	ADVLevelLimitReachedBool:Set[1]
	AALevelLimitReachedBool:Set[1]
	TSLevelLimitReachedBool:Set[1]
	PotionCount:Set[1]
	
	if ${UIElement[EnableVitalityPotionsCheckbox@Potions_Frame@bjxpbotsettings].Checked}
	{
		EnableConsumeVitalityPotion:Set[1]
	}
	else
	{
		EnableConsumeVitalityPotion:Set[0]
	}
	
	wait 10
	
	echo ${Time}: Starting Auto Xp Potion Script
	
	while 1
	{
	;// Conditions Check Loop
		while ${BJXPBotPause} == 0
		{
	;//echo ${Time}: Loop 1	
			Me:CreateCustomInventoryArray[nonbankonly]
		
			if ${CurrentMaxAdvLevelEntryVar} == NULL
			{
				echo ${Time}: Please enter the current EQ2 max ADV level.
				statusvar:Set["Please enter the current EQ2 max ADV level."]
				UIElement[${startclickervar}]:Show
				UIElement[${stopclickervar}]:Hide
				endscript xpcalclevel
				endscript bjxpbot
			}
			elseif ${CurrentMaxAALevelEntryVar} == NULL
			{
				echo ${Time}: Please enter the current EQ2 max AA level.
				statusvar:Set["Please enter the current EQ2 max AA level."]
				UIElement[${startclickervar}]:Show
				UIElement[${stopclickervar}]:Hide
				endscript xpcalclevel
				endscript bjxpbot
			}
			elseif ${CurrentMaxTSLevelEntryVar} == NULL
			{
				echo ${Time}: Please enter the current EQ2 max TS level.
				statusvar:Set["Please enter the current EQ2 max TS level."]
				UIElement[${startclickervar}]:Show
				UIElement[${stopclickervar}]:Hide
				endscript xpcalclevel
				endscript bjxpbot
			}
			elseif ${Me.Level} == ${CurrentMaxAdvLevelEntryVar} && ${Me.TotalEarnedAPs} == ${CurrentMaxAALevelEntryVar} && ${Me.TSLevel} == ${CurrentMaxTSLevelEntryVar}
			{
				UIElement[${startclickervar}]:Show
				statusvar:Set["You're already max level and max AA"]
				echo ${Time}: You're already max ADV level, TS level and max AA silly! Don't waste potions...
				endscript xpcalclevel
				endscript bjxpbot
			}
			elseif !${UIElement[${EnableAdvXPCheckboxvar}].Checked} && !${UIElement[${EnableTSXPCheckboxvar}].Checked} && !${UIElement[${EnableAAXPCheckboxvar}].Checked}
			{
				statusvar:Set["Please select a type of XP to track."]
				echo ${Time}: Please select a type of XP to track.
				if ${Script[xpcalclevel](exists)}
				{
					endscript xpcalclevel
				}
				UIElement[${startclickervar}]:Show
				UIElement[${stopclickervar}]:Hide
				endscript bjxpbot
			}
			elseif ${Me.Group[${PowerlevelerComboBoxVar}].ToActor.IsDead}
			{
				call PowerlevelerDead
			}
			elseif ${UIElement[${EnableSelfReviveOptionsCheckboxVar}].Checked} && ${Me.Health} <= 0
			{
				call SelfRevival
			}
			elseif ${UIElement[${EnableTimeLimitCheckboxVar}].Checked}
			{
				
				if ${StartTimeHour} == ${UserEndTimeVar}
				{	
					echo ${Time}: Your end time can't be equal to your current time.
					statusvar:Set["End time can't be equal to your current time."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot	
				}		
				elseif ${UserEndTimeVar} > 24
				{
					echo ${Time}: Please enter a valid end time.
					statusvar:Set["Please enter a valid end time."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				else
				{
					call ConsumeVitalityItem
					call ConsumePotion
					Break
				}					
			}
			elseif ${UIElement[${EnableADVLevelLimitCheckboxVar}].Checked}
			{
				if ${LevelAdvLimitVar} > ${CurrentMaxAdvLevelEntryVar}
				{
					echo ${Time}: Please enter a valid ADV limit.
					statusvar:Set["Please enter a valid ADV limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${LevelAdvLimitVar} == ${Me.Level}
				{
					echo ${Time}: Start ADV level can't equal ADV limit.
					statusvar:Set["Start ADV level can't equal ADV limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${LevelAdvLimitVar} < ${Me.Level}
				{
					echo ${Time}: Start ADV level can't be less than ADV limit.
					statusvar:Set["Start ADV level can't be less than ADV limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${UIElement[${EnableAASliderBar1LimitCheckboxVar}].Checked}
				{
					if ${EnableAASliderBar1LimitTextEntryVar} > 100
					{
						echo ${Time}: AA slider bar can't be more than 100.
						statusvar:Set["AA slider bar can't be more than 100."]
						UIElement[${startclickervar}]:Show
						UIElement[${stopclickervar}]:Hide
						endscript xpcalclevel
						endscript bjxpbot
					}
					else
					{
						call ConsumeVitalityItem
						call ConsumePotion
						Break
					}
				}
				elseif !${UIElement[${EnableAASliderBar1LimitCheckboxVar}].Checked} && !${UIElement[${EnableSoundLimitCheckboxVar}].Checked} && !${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
				{
					echo ${Time}: Please select a limit reached action.
					statusvar:Set["Please select a limit reached action."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				else
				{
					call ConsumeVitalityItem
					call ConsumePotion
					Break
				}
			}
			elseif ${UIElement[${EnableTSLevelLimitCheckboxVar}].Checked}
			{
				if ${LevelTSLimitVar} > ${CurrentMaxTSLevelEntryVar}
				{
					echo ${Time}: Please enter a valid TS limit.
					statusvar:Set["Please enter a valid TS limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${LevelTSLimitVar} == ${Me.TSLevel}
				{
					echo ${Time}: Start TS level can't equal TS limit.
					statusvar:Set["Start TS level can't equal TS limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${LevelTSLimitVar} < ${Me.TSLevel}
				{
					echo ${Time}: Start TS level can't be less than TS limit.
					statusvar:Set["Start TS level can't be less than TS limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif !${UIElement[${EnableSoundLimitCheckboxVar}].Checked} && !${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
				{
					echo ${Time}: Please select a limit reached action.
					statusvar:Set["Please select a limit reached action."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				else
				{
					call ConsumeVitalityItem
					call ConsumePotion
					Break
				}
			}
			elseif ${UIElement[${EnableAALevelLimitCheckboxVar}].Checked}
			{
				if ${LevelAALimitVar} > ${CurrentMaxAALevelEntryVar}
				{
					echo ${Time}: Please enter a valid AA limit.
					statusvar:Set["Please enter a valid AA limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${LevelAALimitVar} == ${Me.TotalEarnedAPs}
				{
					echo ${Time}: Start AA level can't equal AA limit.
					statusvar:Set["Start AA level can't equal AA limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${LevelAALimitVar} < ${Me.TotalEarnedAPs}
				{
					echo ${Time}: Start AA level can't be less than AA limit.
					statusvar:Set["Start AA level can't be less than AA limit."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				elseif ${UIElement[${EnableAASliderBar2LimitCheckboxVar}].Checked}
				{
					if ${EnableAASliderBar2LimitTextEntryVar} > 100
					{
						echo ${Time}: AA slider bar can't be more than 100.
						statusvar:Set["AA slider bar can't be more than 100."]
						UIElement[${startclickervar}]:Show
						UIElement[${stopclickervar}]:Hide
						endscript xpcalclevel
						endscript bjxpbot
					}
					else
					{
						call ConsumeVitalityItem
						call ConsumePotion
						Break
					}
				}
				elseif !${UIElement[${EnableAASliderBar1LimitCheckboxVar}].Checked} && !${UIElement[${EnableSoundLimitCheckboxVar}].Checked} && !${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
				{
					echo ${Time}: Please select a limit reached action.
					statusvar:Set["Please select a limit reached action."]
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
				else
				{
					call ConsumeVitalityItem
					call ConsumePotion
					Break
				}
			}
			else
			{
				call ConsumeVitalityItem
				call ConsumePotion
				Break
			}
		}

		
	;// Main Loop
		while ${BJXPBotPause} == 0
		{
	;// echo ${Time}: Loop 2
			Me:CreateCustomInventoryArray[nonbankonly]
			
			call xpcalclevelnexttime
			
			ExecuteQueued
			
			if ${Me.Group[${PowerlevelerComboBoxVar}].ToActor.IsDead}
			{
				call PowerlevelerDead
			}
			elseif ${UIElement[${EnableSelfReviveOptionsCheckboxVar}].Checked} && ${Me.Health} <= 0
			{
				call SelfRevival
			}
			elseif ${timeuntilnextmilli.TimeLeft} == 0
			{
				call ConsumePotion
			}
			elseif !${UIElement[${EnableAdvXPCheckboxvar}].Checked} && !${UIElement[${EnableTSXPCheckboxvar}].Checked} && !${UIElement[${EnableAAXPCheckboxvar}].Checked}
			{
				statusvar:Set["Please select a type of XP to track."]
				echo ${Time}: Please select a type of XP to track.
				if ${Script[xpcalclevel](exists)}
				{
					endscript xpcalclevel
				}
				UIElement[${startclickervar}]:Show
				UIElement[${stopclickervar}]:Hide
				endscript bjxpbot
			}
			else
			{
				if ${UIElement[${EnableTimeLimitCheckboxVar}].Checked} || ${UIElement[${EnableADVLevelLimitCheckboxVar}].Checked} || ${UIElement[${EnableAALevelLimitCheckboxVar}].Checked} || \
					${UIElement[${EnableTSLevelLimitCheckboxVar}].Checked}
				{
					if ${UIElement[${EnableTimeLimitCheckboxVar}].Checked}
					{
						call ConsumeVitalityItem
						call TimeLimitReached
					}
					elseif ${UIElement[${EnableADVLevelLimitCheckboxVar}].Checked}
					{	
						call ConsumeVitalityItem
						call LevelLimitReached
					}
					elseif ${UIElement[${EnableAALevelLimitCheckboxVar}].Checked}
					{
						call ConsumeVitalityItem
						call LevelLimitReached
					}
					elseif ${UIElement[${EnableTSLevelLimitCheckboxVar}].Checked}
					{
						call ConsumeVitalityItem
						call LevelLimitReached
					}
				}
				else
				{
	;//				echo ${Time}: Loop 2 - ExecuteQueued
					call ConsumeVitalityItem
					if ${timeuntilnextmilli.TimeLeft} == 0
					{
						call ConsumePotion
					}
					
				}
			}		
		}	
	}
}

function ConsumeVitalityItem()
{
	if ${EnableConsumeVitalityPotion} == 1
	{
		wait !${Me.InCombat} && !${Me.CastingSpell}
		
		if ${UIElement[${EnableVitalityPotionsCheckboxVar}].Checked}
		{						
			if ${Me.CustomInventory[Orb of Concentrated Memories](exists)}  && ${Me.CustomInventory[Orb of Concentrated Memories].IsReady} && ${Me.Vitality} == 0
			{
				echo ${Time}: Orb of Concentrated Memories Detected
				statusvar:Set["Orb of Concentrated Memories Detected"]
				if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
					Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
				wait 30
				ItemToUse:Set[Orb of Concentrated Memories]
				Me.Inventory[exactitem,${ItemToUse}]:Use
				wait 10
				if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Orb of Concentrated Memories](exists)}
				{	
					echo ${Time}: Orb of Concentrated Memories Consumed
					statusvar:Set["Orb of Concentrated Memories Consumed"]
					lastpotion:Set["Orb of Concentrated Memories"]
					lastpotiontime:Set[${Time}]
				}
				wait 30
				if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
					Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
			}		
			elseif ${Me.CustomInventory[Potion of Vitality](exists)} && ${Me.Vitality} == 0
			{
				echo ${Time}: Potion of Vitality Detected
				statusvar:Set["Potion of Vitality Detected"]
				if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
					Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
				wait 30
				ItemToUse:Set[Potion of Vitality]
				Me.Inventory[exactitem,${ItemToUse}]:Use
				wait 10
				if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Rested Mind and Body](exists)}
				{
					echo ${Time}: Potion of Vitality Consumed
					statusvar:Set["Potion of Vitality Consumed"]
					lastpotion:Set["Potion of Vitality"]
					lastpotiontime:Set[${Time}]
				}
				wait 30
				if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
					Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
			}
		}
	}
}

function ConsumePotion()
{
	if ${EnableConsumePotion} == 1
	{
		echo ${Time}: Consume Potion Function
	
		wait !${Me.InCombat} && !${Me.CastingSpell}
		
		if ${UIElement[${enablepotionscheckboxvar}].Checked}
		{							
			echo ${Time}:  Checking xp potions...
			statusvar:Set["Checking xp potions..."]
			wait 30
			
				echo ${Time}: Consume Xp Potion Attempt Starting...
				statusvar:Set["Consume XP Potion Attempt Starting..."]
				
				wait 30
			if ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items} > 0 && ${PotionCount} <= ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items}
			{
				if ${Me.CustomInventory[${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}](exists)}
				{
					echo ${Time}: ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Detected
					statusvar:Set["${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Detected"]
					if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
						Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
					wait 30
					ItemToUse:Set[${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}]
					Me.Inventory[exactitem,${ItemToUse}]:Use
					wait 10
					if ${Me.CastingSpell}
					{
						if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}](exists)} || \
							${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[an enlightened experience](exists)} || \
							${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)} || \
							${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a brilliant experience](exists)} || \
							${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Major Potion of the Advanced](exists)}
						{
							echo ${Time}: ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Consumed
							statusvar:Set["${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Consumed"]
							lastpotion:Set["${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}"]
							lastpotiontime:Set[${Time}]
														
							PotionSpellName:Set[${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}]
;//							echo PotionSpellName:Set[${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}]
;//							echo ${PotionSpellName}
							wait 110
							PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo ${PotionDuration}
							wait 30
							PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo ${PotionDuration}
							wait 30
							PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo ${PotionDuration}
							wait 30
							PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
;//							echo ${PotionDuration}
							timeuntilnextmilli:Set[${Math.Calc[(${PotionDuration}*1000)+90000]}]
;//							echo timeuntilnextmilli:Set[${Math.Calc[(${PotionDuration}*1000)+90000]}]
;//							echo ${timeuntilnextmilli}
						}
					}	
					wait 30
					if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
					{
						Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
					}	
				}
				else
				{
					PotionCount:Inc
					
					if ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items} > 0 && ${PotionCount} <= ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].Items}
					{
						if ${Me.CustomInventory[${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}](exists)}
						{
							echo ${Time}: ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Detected
							statusvar:Set["${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Detected"]
							if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
								Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
							wait 30
							ItemToUse:Set[${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}]
							Me.Inventory[exactitem,${ItemToUse}]:Use
							wait 10
							if ${Me.CastingSpell}
							{
								if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}](exists)} || \
									${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[an enlightened experience](exists)} || \
									${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)} || \
									${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a brilliant experience](exists)} || \
									${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Major Potion of the Advanced](exists)}
								{
									echo ${Time}: ${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Consumed
									statusvar:Set["${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]} Consumed"]
									lastpotion:Set["${UIElement[PotionPriorityListBox@Potions_Frame@bjxpbotsettings].OrderedItem[${PotionCount}]}"]
									lastpotiontime:Set[${Time}]
									
									PotionSpellName:Set[${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}]
		;//							echo PotionSpellName:Set[${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}]
		;//							echo ${PotionSpellName}
									wait 110
									PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo ${PotionDuration}
									wait 30
									PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo ${PotionDuration}
									wait 30
									PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo ${PotionDuration}
									wait 30
									PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo PotionDuration:Set[${Me.Effect[${PotionSpellName}].Duration}]
		;//							echo ${PotionDuration}
									timeuntilnextmilli:Set[${Math.Calc[(${PotionDuration}*1000)+90000]}]
		;//							echo timeuntilnextmilli:Set[${Math.Calc[(${PotionDuration}*1000)+90000]}]
		;//							echo ${timeuntilnextmilli}
								}
							}	
							wait 30
							if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
							{
								Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
							}	
						}
					}
					else
					{
						statusvar:Set["XP Potion script DISABLED. Calculating XP only."]
						lastpotion:Set["No XP potions detected in inventory."]
						lastpotiontime:Set[${Time}]						
						echo ${Time}: No XP potions detected in inventory.
						EnableConsumePotion:Set[0]
						PotionCount:Set[1]
						UIElement[${enablepotionscheckboxvar}]:UnsetChecked
					}
				}
			}
			else
			{
				statusvar:Set["XP Potion script DISABLED. Calculating XP only."]
				lastpotion:Set["No XP potions detected in inventory."]
				lastpotiontime:Set[${Time}]						
				echo ${Time}: No XP potions detected in inventory.
				EnableConsumePotion:Set[0]
				PotionCount:Set[1]
				UIElement[${enablepotionscheckboxvar}]:UnsetChecked
			}
			
			if ${EnableConsumePotion} == 1
			{
				statusvar:Set["Waiting for next attempt."]
				echo ${Time}: Waiting for next attempt.
			}	
		}
		else
		{
			statusvar:Set["XP Potion script DISABLED. Calculating XP only."]
			echo ${Time}: XP Potion script DISABLED. Calculating XP only.
			EnableConsumePotion:Set[0]
			PotionCount:Set[1]
			UIElement[${enablepotionscheckboxvar}]:UnsetChecked
		}
	}	
}

function LimitDropBoxReached()
{
	if ${LimitReachedComboBoxVar.Equal[Please choose...]}
	{
		echo Please choose an action to perform when any limit has been reached.
		statusvar:Set["Please choose an action to perform..."]
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
	elseif ${LimitReachedComboBoxVar.Equal[Leave group]}
	{
		echo ${Time}: A limit has been reached.  Leaving group.
		statusvar:Set["A limit has been reached. See console details."]
		eq2execute leavegroup
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
	elseif ${LimitReachedComboBoxVar.Equal[Camp to login screen]}
	{
		echo ${Time}: A limit has been reached.  Camping to login screen.
		statusvar:Set["A limit has been reached. See console details."]
		eq2execute camp login
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
	elseif ${LimitReachedComboBoxVar.Equal[Quit to login screen]}
	{
		echo ${Time}: A limit has been reached.  Quitting to login screen.
		statusvar:Set["A limit has been reached. See console details."]
		eq2execute quit login
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}		
	elseif ${LimitReachedComboBoxVar.Equal[Disable potion consumption]}
	{
		echo ${Time}: A limit has been reached. Disabling consumption of potions.  Experience calculations will continue.
		statusvar:Set["A limit has been reached. See console details."]
		UIElement[${EnableVitalityPotionsCheckbox}]:SetUnChecked
		UIElement[${EnablePotionsCheckbox}]:SetUnChecked
		if !${Script[xpcalclevel](exists)}
		{	
			runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjxpbot/xpcalclevel"
		}
		${EnableConsumePotion} == 0
	}		
	elseif ${LimitReachedComboBoxVar.Equal[End entire script]}
	{
		echo ${Time}: A limit has been reached. Ending entire script.
		statusvar:Set["A limit has been reached. See console details."]
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
}

function PlaySoundLimitEnabled()
{
	if ${PlaySoundBool} == 1
	{
		echo ${Time}:  Playing limit reached sound
		play "${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/bjxpbot/Sounds/ping.wav"
		PlaySoundBool:Set[0]
		
		if ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
		{
			call LimitDropBoxReached
		}
	}	
}

function TimeLimitReached()
{
	if ${UIElement[${EnableTimeLimitCheckboxVar}].Checked}
	{
		if ${UserEndTimeVar} <= 24
		{			
			if ${Time.Hour} == ${UserEndTimeVar}
			{
				if ${TimeLimitReachedBool} == 1
				{
				echo ${Time}: Time limit has been reached.
				statusvar:Set["Time limit has been reached."]
				TimeLimitReachedBool:Set[0]
				}
					
				if ${UIElement[${EnableSoundLimitCheckboxVar}].Checked}
				{
					call PlaySoundLimitEnabled
				}
				elseif ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
				{
					call LimitDropBoxReached
				}
			}		
		}
		else
		{
			if ${timeuntilnextmilli.TimeLeft} == 0
			{
				call ConsumePotion
			}
		}
	}
}

function LevelLimitReached()
{
	if ${UIElement[${EnableADVLevelLimitCheckboxVar}].Checked}
	{
		if ${Me.Level} >= ${LevelAdvLimitVar}
		{	
			if ${ADVLevelLimitReachedBool} == 1
			{
				echo ${Time}: ADV limit has been reached.
				statusvar:Set["ADV limit has been reached."]
				ADVLevelLimitReachedBool:Set[0]
			}	
			
			if ${UIElement[${EnableAASliderBar1LimitCheckboxVar}].Checked}
			{
				EQ2Execute "achievement_conversion ${EnableAASliderBar1LimitTextEntryVar}"
				if ${UIElement[${EnableSoundLimitCheckboxVar}].Checked}
				{
					call PlaySoundLimitEnabled
				}
				elseif ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
				{
					call LimitDropBoxReached
				}		
			}
			elseif ${UIElement[${EnableSoundLimitCheckboxVar}].Checked}
			{
				call PlaySoundLimitEnabled
			}
			elseif ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
			{
				call LimitDropBoxReached
			}		
		}
		else
		{
			if ${timeuntilnextmilli.TimeLeft} == 0
			{
				call ConsumePotion
			}
		}
	}
	elseif ${UIElement[${EnableAALevelLimitCheckboxVar}].Checked}
	{
		if ${Me.TotalEarnedAPs} >= ${LevelAALimitVar}
		{
			if ${AALevelLimitReachedBool} == 1
			{
				echo ${Time}: AA limit has been reached.
				statusvar:Set["AA limit has been reached."]
				AALevelLimitReachedBool:Set[0]
			}	
				
			if ${UIElement[${EnableAASliderBar2LimitCheckboxVar}].Checked}
			{
				EQ2Execute "achievement_conversion ${EnableAASliderBar2LimitTextEntryVar}"
				if ${UIElement[${EnableSoundLimitCheckboxVar}].Checked}
				{
					call PlaySoundLimitEnabled
				}
				elseif ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
				{
					call LimitDropBoxReached
				}
			}
			elseif ${UIElement[${EnableSoundLimitCheckboxVar}].Checked}
			{
				call PlaySoundLimitEnabled
			}
			elseif ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
			{
				call LimitDropBoxReached
			}
		}
		else
		{
			if ${timeuntilnextmilli.TimeLeft} == 0
			{
				call ConsumePotion
			}
		}
	}
	elseif ${UIElement[${EnableTSLevelLimitCheckboxVar}].Checked}
	{
		if ${Me.TSLevel} >= ${LevelTSLimitVar}
		{	
			if ${TSLevelLimitReachedBool} == 1
			{
				echo ${Time}: TS limit has been reached.
				statusvar:Set["TS limit has been reached."]
				TSLevelLimitReachedBool:Set[0]
			}	
			elseif ${UIElement[${EnableSoundLimitCheckboxVar}].Checked}
			{
				call PlaySoundLimitEnabled
			}
			elseif ${UIElement[${EnableLimitDropboxCheckboxVar}].Checked}
			{
				call LimitDropBoxReached
			}		
		}
		else
		{
			if ${timeuntilnextmilli.TimeLeft} == 0
			{
				call ConsumePotion
			}
		}
	}
}

function PowerlevelerDead()
{
	if ${PowerlevelerOptionsComboBoxVar.Equal[Please choose...]}
	{
		echo ${Time}: Your Powerleveler died, but you didn't set an action to perform.
		statusvar:Set["Your powerleveler died, but no action was set."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
	}
	elseif ${PowerlevelerOptionsComboBoxVar.Equal[Play a sound]}
	{
		if ${PlayPLSoundBool} == 1
		{
			echo ${Time}:  Your Powerleveler died. Playing a sound.
			statusvar:Set["Your Powerleveler died. Playing a sound."]
			lastpotion:Set["Time of death listed below"]
			lastpotiontime:Set[${Time}]
			play "${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/bjxpbot/Sounds/chatalarm.wav"
			PlayPLSoundBool:Set[0]
		}
	}
	elseif ${PowerlevelerOptionsComboBoxVar.Equal[Pause script]}
	{
		echo ${Time}: Your Powerleveler died. Pausing the script.
		statusvar:Set["Your Powerleveler died. Pausing the script."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
		BJXPBotPause:Set[1]
		echo ${Time}: BJXPBot PAUSED
		UIElement[${PauseBJXPBotVar}]:Hide
		UIElement[${ResumeBJXPBotVar}]:Show
		
	}
	elseif ${PowerlevelerOptionsComboBoxVar.Equal[Camp to login]}
	{
		echo ${Time}: Your Powerleveler died. Camping to login.
		statusvar:Set["Your Powerleveler died. Camping to login."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
		eq2execute camp login
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
	elseif ${PowerlevelerOptionsComboBoxVar.Equal[Quit to login]}
	{
		echo ${Time}: Your Powerleveler died. Quitting to login.
		statusvar:Set["Your Powerleveler died. Quitting to login."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
		eq2execute quit login
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
}

function SelfRevival()
{
	if ${SelfReviveOptionsComboBoxVar.Equal[Please choose...]}
	{
		echo ${Time}: You died, but you didn't set an action to perform.
		statusvar:Set["You died, but no action was set."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
	}
	elseif ${SelfReviveOptionsComboBoxVar.Equal[Wait for a res]}
	{
		echo ${Time}: You died. Waiting for a ressurection.
		statusvar:Set["You died. Waiting for a ressurection."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
	}
	elseif ${SelfReviveOptionsComboBoxVar.Equal[Revive]}
	{
		wait 30
		EQ2Execute "select_junction 0"
	}
	elseif ${SelfReviveOptionsComboBoxVar.Equal[Quit to login]}
	{
		echo ${Time}: You died. Quitting to login.
		statusvar:Set["You died. Quitting to login."]
		lastpotion:Set["Time of death listed below"]
		lastpotiontime:Set[${Time}]
		eq2execute quit login
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
}

function xpcalclevelnexttime()
{
;//		echo timeuntilnextmilli.TimeLeft: ${timeuntilnextmilli.TimeLeft}
		StartTimeNext:Set[${Math.Calc64[${timeuntilnextmilli.TimeLeft}/1000]}]
;//		echo StartTimeNext: ${StartTimeNext}
		DisplaySecondsNext:Set[${Math.Calc64[${StartTimeNext}%60]}]
;//		echo DisplaySecondsNext: ${DisplaySecondsNext}
		DisplayMinutesNext:Set[${Math.Calc64[${StartTimeNext}/60%60]}]
;//		echo DisplayMinutesNext: ${DisplayMinutesNext}
		DisplayHoursNext:Set[${Math.Calc64[${StartTimeNext}/60\\60]}]
}

atom(script) EQ2_onIncomingText(string Message)
{
	;Chat type 15=group, 16=raid, 28=tell, 8=say
	;echo ChatType: ${ChatType} - Message: ${Message} - Speaker: ${Speaker} - ChatTarget: ${ChatTarget} - SpeakerIsNPC: ${SpeakerIsNPC} - ChannelName: ${ChannelName}

	if ${Message.Find["You can only have one experience potion active at a time."](exists)}
		{
			echo Potion consumption failed due to an already existing active potion.
			timeuntilnextmilli:Set[600000]
		}
}

objectdef TimerObject
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}

	member:uint TimeLeft()
	{
		if ${Script.RunningTime}>=${EndTime}
			return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}


function atexit()
{
	echo ${Time}: Stopping Auto XP Potion Script
	call SaveSettings	
}