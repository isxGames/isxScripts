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
	
	;// Vitality Potions Checkbox
	if ${_ref.FindSetting[EnableVitalityPotionsCheckbox]}
		UIElement[${EnableVitalityPotionsCheckboxVar}]:SetChecked
	else
		UIElement[${EnableVitalityPotionsCheckbox}]:SetUnChecked
	
	;//	Experience Potions Checkbox
	if ${_ref.FindSetting[EnablePotionsCheckbox]}
		UIElement[${enablepotionscheckboxvar}]:SetChecked
	else
		UIElement[${EnablePotionsCheckbox}]:SetUnChecked	
		
	;// Level Limit Checkbox
	if ${_ref.FindSetting[EnableLevelLimitCheckbox]}
		UIElement[${EnableLevelLimitCheckboxVar}]:SetChecked
	else
		UIElement[${EnableLevelLimitCheckbox}]:SetUnChecked	
	
	;// Level Limit AA Text Entry
	if ${_ref.FindSetting[LevelAALimitVar](exists)}
	{
		LevelAALimitVar:Set[${_ref.FindSetting[LevelAALimitVar]}]
		UIElement[LevelAALimitEntry@Limits_Frame@bjxpbotsettings]:SetText[${_ref.FindSetting[LevelAALimitVar]}]
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
	
	;// ADV Experience Calculations Checkbox
	if ${_ref.FindSetting[EnableAdvXPCheckbox]}
		UIElement[${EnableAdvXPCheckboxvar}]:SetChecked
	else
		UIElement[${EnableAdvXPCheckbox}]:SetUnChecked
	
	;//	TS Experience Calculations Checkbox
	if ${_ref.FindSetting[EnableTSXPCheckbox]}
		UIElement[${EnableTSXPCheckboxvar}]:SetChecked
	else
		UIElement[${EnableTSXPCheckbox}]:SetUnChecked	
		
	;// AA Experience Calculations Checkbox
	if ${_ref.FindSetting[EnableAAXPCheckbox]}
		UIElement[${EnableAAXPCheckboxvar}]:SetChecked
	else
		UIElement[${EnableAAXPCheckbox}]:SetUnChecked	

}