

variable settingsetref Settings

function config_load()
{
	variable string testVersion
	LavishSettings:AddSet[EQ2AFKAlarm]
	LavishSettings[EQ2AFKAlarm]:Clear
	LavishSettings[EQ2AFKAlarm]:AddSet[Config]
	LavishSettings[EQ2AFKAlarm]:Import[${ConfigFile}]
	Settings:Set[${LavishSettings[EQ2AFKAlarm].FindSet[Config]}]
	testVersion:Set[${Settings.FindSetting[Script_Version]}]

	if ${testVersion.NotEqual[${EQ2AFKAlarm_version}]} || ${EQ2AFKAlarm_version_devel}
	{
		call ShowMessageBox "EQ2AFKAlarm - Config Reset" "Configuration version does not match EQ2AFKAlarm version.\n\nResetting user configs to defaults..."

		Settings:Clear
	}

	Log.IsEnabled:Set[${Settings.FindSetting[Logging,TRUE]}]
	TriggerSays:Set[${Settings.FindSetting[TriggerSays,FALSE]}]
	TriggerTells:Set[${Settings.FindSetting[TriggerTells,FALSE]}]
	TriggerGroup:Set[${Settings.FindSetting[TriggerGroup,FALSE]}]
	TriggerRaid:Set[${Settings.FindSetting[TriggerRaid,FALSE]}]
	TriggerGuild:Set[${Settings.FindSetting[TriggerGuild,FALSE]}]
	TriggerOfficer:Set[${Settings.FindSetting[TriggerOfficer,FALSE]}]
	TTSSays:Set[${Settings.FindSetting[TTSSays,FALSE]}]
	TTSTells:Set[${Settings.FindSetting[TTSTells,FALSE]}]
	TTSGroup:Set[${Settings.FindSetting[TTSGroup,FALSE]}]
	TTSRaid:Set[${Settings.FindSetting[TTSRaid,FALSE]}]
	TTSGuild:Set[${Settings.FindSetting[TTSGuild,FALSE]}]
	TTSOfficer:Set[${Settings.FindSetting[TTSOfficer,FALSE]}]
	DisplayConsole:Set[${Settings.FindSetting[DisplayConsole,FALSE]}]
	Script_Version:Set[${Settings.FindSetting[Script_Version,FALSE]}]

	; Load window positions (use -1 as default for "not set")
	variable int MainWindowX
	variable int MainWindowY
	variable int ConfigWindowX
	variable int ConfigWindowY
	variable int ConsoleWindowX
	variable int ConsoleWindowY

	MainWindowX:Set[${Settings.FindSetting[MainWindowX,-1]}]
	MainWindowY:Set[${Settings.FindSetting[MainWindowY,-1]}]
	ConfigWindowX:Set[${Settings.FindSetting[ConfigWindowX,-1]}]
	ConfigWindowY:Set[${Settings.FindSetting[ConfigWindowY,-1]}]
	ConsoleWindowX:Set[${Settings.FindSetting[ConsoleWindowX,-1]}]
	ConsoleWindowY:Set[${Settings.FindSetting[ConsoleWindowY,-1]}]

	; Apply saved main window position (only if previously saved)
	if ${MainWindowX} >= 0 && ${MainWindowY} >= 0
	{
		LGUI2.Element[EQ2AFKAlarm.Window]:SetLocation[${MainWindowX}, ${MainWindowY}]
	}

	; Apply saved console window position (only if previously saved)
	if ${ConsoleWindowX} >= 0 && ${ConsoleWindowY} >= 0
	{
		LGUI2.Element[EQ2AFKAlarm Console]:SetLocation[${ConsoleWindowX}, ${ConsoleWindowY}]
	}

	; Note: Config window position is applied when window loads (see ApplyConfigWindowPosition function)

}

function ApplyConfigWindowPosition()
{
	; Load saved config window position
	variable int ConfigWindowX
	variable int ConfigWindowY

	ConfigWindowX:Set[${Settings.FindSetting[ConfigWindowX,-1]}]
	ConfigWindowY:Set[${Settings.FindSetting[ConfigWindowY,-1]}]

	; Apply saved config window position (only if previously saved)
	if ${ConfigWindowX} >= 0 && ${ConfigWindowY} >= 0
	{
		LGUI2.Element[EQ2AFKAlarm Config.Window]:SetLocation[${ConfigWindowX}, ${ConfigWindowY}]
	}

	; Show the config window (it starts hidden to prevent jumping)
	LGUI2.Element[EQ2AFKAlarm Config.Window]:SetVisibility[visible]

	return
}

function SaveConfigWindowPosition()
{
	; Save config window position immediately (called when window closes)
	if ${LGUI2.Element[EQ2AFKAlarm Config.Window](exists)}
	{
		Settings:AddSetting[ConfigWindowX,${LGUI2.Element[EQ2AFKAlarm Config.Window].X}]
		Settings:AddSetting[ConfigWindowY,${LGUI2.Element[EQ2AFKAlarm Config.Window].Y}]
		LavishSettings[EQ2AFKAlarm]:Export[${ConfigFile}]
	}

	return
}

function config_save()
{
	Settings:AddSetting[Script_Version,${EQ2AFKAlarm_version}]

	Settings:AddSetting[Logging,${Log.Enabled}]
	Settings:AddSetting[TriggerSays,${TriggerSays}]
	Settings:AddSetting[TriggerTells,${TriggerTells}]
	Settings:AddSetting[TriggerGroup,${TriggerGroup}]
	Settings:AddSetting[TriggerRaid,${TriggerRaid}]
	Settings:AddSetting[TriggerGuild,${TriggerGuild}]
	Settings:AddSetting[TriggerOfficer,${TriggerOfficer}]
	Settings:AddSetting[TTSSays,${TTSSays}]
	Settings:AddSetting[TTSTells,${TTSTells}]
	Settings:AddSetting[TTSGroup,${TTSGroup}]
	Settings:AddSetting[TTSRaid,${TTSRaid}]
	Settings:AddSetting[TTSGuild,${TTSGuild}]
	Settings:AddSetting[TTSOfficer,${TTSOfficer}]
	Settings:AddSetting[DisplayConsole,${DisplayConsole}]

	; Save window positions
	if ${LGUI2.Element[EQ2AFKAlarm.Window](exists)}
	{
		Settings:AddSetting[MainWindowX,${LGUI2.Element[EQ2AFKAlarm.Window].X}]
		Settings:AddSetting[MainWindowY,${LGUI2.Element[EQ2AFKAlarm.Window].Y}]
	}

	; Save config window position if it's open (script ending while config window is open)
	if ${LGUI2.Element[EQ2AFKAlarm Config.Window](exists)}
	{
		Settings:AddSetting[ConfigWindowX,${LGUI2.Element[EQ2AFKAlarm Config.Window].X}]
		Settings:AddSetting[ConfigWindowY,${LGUI2.Element[EQ2AFKAlarm Config.Window].Y}]
	}
	; If config window was closed normally, position was already saved by SaveConfigWindowPosition()

	; Save console window position if it exists (whether visible or hidden)
	if ${LGUI2.Element[EQ2AFKAlarm Console](exists)}
	{
		Settings:AddSetting[ConsoleWindowX,${LGUI2.Element[EQ2AFKAlarm Console].X}]
		Settings:AddSetting[ConsoleWindowY,${LGUI2.Element[EQ2AFKAlarm Console].Y}]
	}

	LavishSettings[EQ2AFKAlarm]:Export[${ConfigFile}]
}
