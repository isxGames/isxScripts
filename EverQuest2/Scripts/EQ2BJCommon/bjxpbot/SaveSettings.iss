variable settingsetref BJXPBot_Settings
variable settingsetref _ref
variable filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"

function main()
{
	;// Load Settings
	LavishSettings:AddSet[BJXPBot]
	LavishSettings[BJXPBot]:Clear
	LavishSettings[BJXPBot]:AddSet[BJXPBot_Settings]
	LavishSettings[BJXPBot]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"]
	_ref:Set[${LavishSettings.FindSet[BJXPBot]}]

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