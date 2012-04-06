variable(global) settingsetref BJXPBot_Settings
variable(global) settingsetref _ref
variable(global) filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"

function main()
{
	;// Load UI
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjxpbot/UI/bjxpbotXML.xml"
	
;// Load Saved Settings
	LavishSettings:AddSet[BJXPBot]
	LavishSettings[BJXPBot]:Clear
	LavishSettings[BJXPBot]:AddSet[BJXPBot_Settings]
	LavishSettings[BJXPBot]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"]
	_ref:Set[${LavishSettings.FindSet[BJXPBot]}]

;// Checkboxes	
	;// Sound Limit Checkbox
	if ${_ref.FindSetting[EnableSoundLimitCheckboxVar]}
		UIElement[${EnableSoundLimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableSoundLimitCheckboxVar}]:UnsetChecked
	;// AA Slider Bar 1 Limit Checkbox
	if ${_ref.FindSetting[EnableAASliderBar1LimitCheckboxVar]}
		UIElement[${EnableAASliderBar1LimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableAASliderBar1LimitCheckboxVar}]:UnsetChecked
	;// AA Slider Bar 2 Limit Checkbox
	if ${_ref.FindSetting[EnableAASliderBar2LimitCheckboxVar]}
		UIElement[${EnableAASliderBar2LimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableAASliderBar2LimitCheckboxVar}]:UnsetChecked
	;// Dropbox Limit Checkbox
	if ${_ref.FindSetting[EnableLimitDropboxCheckboxVar]}
		UIElement[${EnableLimitDropboxCheckboxVar}]:SetChecked
	else
		UIElement[${EnableLimitDropboxCheckboxVar}]:UnsetChecked	
	;// Vitality Potions Checkbox
	if ${_ref.FindSetting[EnableVitalityPotionsCheckbox]}
		UIElement[${EnableVitalityPotionsCheckboxVar}]:SetChecked
	else
		UIElement[${EnableVitalityPotionsCheckbox}]:UnsetChecked
	
	;//	Experience Potions Checkbox
	if ${_ref.FindSetting[EnablePotionsCheckbox]}
		UIElement[${enablepotionscheckboxvar}]:SetChecked
	else
		UIElement[${EnablePotionsCheckbox}]:UnsetChecked

	;// Time Limit Checkbox
	if ${_ref.FindSetting[EnableTimeLimitCheckbox]}
		UIElement[${EnableTimeLimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableTimeLimitCheckbox}]:UnsetChecked			
		
	;// ADV Level Limit Checkbox
	if ${_ref.FindSetting[EnableADVLevelLimitCheckbox]}
		UIElement[${EnableADVLevelLimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableADVLevelLimitCheckboxVar}]:UnsetChecked	
		
	;// AA Level Limit Checkbox
	if ${_ref.FindSetting[EnableAALevelLimitCheckbox]}
		UIElement[${EnableAALevelLimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableAALevelLimitCheckboxVar}]:UnsetChecked	
	;// ADV Experience Calculations Checkbox
	if ${_ref.FindSetting[EnableAdvXPCheckbox]}
		UIElement[${EnableAdvXPCheckboxvar}]:SetChecked
	else
		UIElement[${EnableAdvXPCheckbox}]:UnsetChecked
	
	;//	TS Experience Calculations Checkbox
	if ${_ref.FindSetting[EnableTSXPCheckbox]}
		UIElement[${EnableTSXPCheckboxvar}]:SetChecked
	else
		UIElement[${EnableTSXPCheckbox}]:UnsetChecked	
		
	;// AA Experience Calculations Checkbox
	if ${_ref.FindSetting[EnableAAXPCheckbox]}
		UIElement[${EnableAAXPCheckboxvar}]:SetChecked
	else
		UIElement[${EnableAAXPCheckbox}]:UnsetChecked
	;// Enable IRC Relay Checkbox
	if ${_ref.FindSetting[EnableIRCRelayCheckboxVar]}
		UIElement[${EnableIRCRelayCheckboxVar}]:SetChecked
	else
		UIElement[${EnableIRCRelayCheckboxVar}]:UnsetChecked		
		
;// Text Entries	
	;// AA Slider Bar 1 Text Entry
	if ${_ref.FindSetting[EnableAASliderBar1LimitTextEntryVar](exists)}
	{
		EnableAASliderBar1LimitTextEntryVar:Set[${_ref.FindSetting[EnableAASliderBar1LimitTextEntryVar]}]
		UIElement[EnableAASliderBar1LimitTextEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[EnableAASliderBar1LimitTextEntryVar]}]
	}
	;// AA Slider Bar 2 Text Entry
	if ${_ref.FindSetting[EnableAASliderBar2LimitTextEntryVar](exists)}
	{
		EnableAASliderBar2LimitTextEntryVar:Set[${_ref.FindSetting[EnableAASliderBar2LimitTextEntryVar]}]
		UIElement[EnableAASliderBar2LimitTextEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[EnableAASliderBar2LimitTextEntryVar]}]
	}
	;// Level Limit TS Text Entry
	if ${_ref.FindSetting[LevelTSLimitVar](exists)}
	{
		LevelTSLimitVar:Set[${_ref.FindSetting[LevelTSLimitVar]}]
		UIElement[LevelTSLimitEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[LevelTSLimitVar]}]
	}	
	;// Level Limit AA Text Entry
	if ${_ref.FindSetting[LevelAALimitVar](exists)}
	{
		LevelAALimitVar:Set[${_ref.FindSetting[LevelAALimitVar]}]
		UIElement[LevelAALimitEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[LevelAALimitVar]}]
	}
	;// Current Max Adv Level Text Entry
	if ${_ref.FindSetting[CurrentMaxAdvLevelEntryVar](exists)}
	{
		CurrentMaxAdvLevelEntryVar:Set[${_ref.FindSetting[CurrentMaxAdvLevelEntryVar]}]
		UIElement[CurrentMaxAdvLevelEntry@Setup_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[CurrentMaxAdvLevelEntryVar]}]
	}	
	;// Current Max AA Level Text Entry
	if ${_ref.FindSetting[CurrentMaxAALevelEntryVar](exists)}
	{
		CurrentMaxAALevelEntryVar:Set[${_ref.FindSetting[CurrentMaxAALevelEntryVar]}]
		UIElement[CurrentMaxAALevelEntry@Setup_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[CurrentMaxAALevelEntryVar]}]
	}	
	;// Current Max TS Level Text Entry
	if ${_ref.FindSetting[CurrentMaxTSLevelEntryVar](exists)}
	{
		CurrentMaxTSLevelEntryVar:Set[${_ref.FindSetting[CurrentMaxTSLevelEntryVar]}]
		UIElement[CurrentMaxTSLevelEntry@Setup_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[CurrentMaxTSLevelEntryVar]}]
	}
	;// Level Limit ADV Text Entry
	if ${_ref.FindSetting[LevelAdvLimitVar](exists)}
	{
		LevelAdvLimitVar:Set[${_ref.FindSetting[LevelAdvLimitVar]}]
		UIElement[LevelAdvLimitEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[LevelAdvLimitVar]}]
	}	
	;// Time Limit Text Entry
	if ${_ref.FindSetting[UserEndTimeVar](exists)}
	{
		UserEndTimeVar:Set[${_ref.FindSetting[UserEndTimeVar]}]
		UIElement[UserEndTimeEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[UserEndTimeVar]}]
	}	
	else
	{
		UserEndTimeVar:Set[0]
		UIElement[UserEndTimeEntry@Limits_Frame@bjxpbotsettings]:SetText[0]
	}	
	;// IRC Server Text Entry
	if ${_ref.FindSetting[IRCServerTextEntryVar](exists)}
	{
		IRCServerTextEntryVar:Set[${_ref.FindSetting[IRCServerTextEntryVar]}]
		UIElement[IRCServerTextEntry@Statistics_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[IRCServerTextEntryVar]}]
	}	
	;// IRC Channel Text Entry
	if ${_ref.FindSetting[IRCChannelTextEntryVar](exists)}
	{
		IRCChannelTextEntryVar:Set[${_ref.FindSetting[IRCChannelTextEntryVar]}]
		UIElement[IRCChannelTextEntry@Statistics_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[IRCChannelTextEntryVar]}]
	}	
	;// IRC Nickname Suffix Text Entry
	if ${_ref.FindSetting[IRCNicknameSuffixTextEntryVar](exists)}
	{
		IRCNicknameSuffixTextEntryVar:Set[${_ref.FindSetting[IRCNicknameSuffixTextEntryVar]}]
		UIElement[IRCNicknameSuffixTextEntry@Statistics_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[IRCNicknameSuffixTextEntryVar]}]
	}	
	
;// Comboboxes		
	;// Limit Reached Combobox Value
	if ${_ref.FindSetting[LimitReachedComboBoxVar](exists)}
	{
		LimitReachedComboBoxVar:Set[${_ref.FindSetting[LimitReachedComboBoxVar]}]
		UIElement[LimitReachedComboBox@Limits_Frame@bjxpbotsettings]:SetSelection[${UIElement[LimitReachedComboBox@Limits_Frame@bjxpbotsettings].ItemByText[${_ref.FindSetting[LimitReachedComboBoxVar]}].ID}]
	}


}