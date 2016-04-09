

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
		MessageBox " Configuration version does not match EQ2AFKAlarm version, \n resetting user configs to defaults... \n"

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
	Script_Version:Set[${Settings.FindSetting[Script_Version,FALSE]}]
	
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
	
	LavishSettings[EQ2AFKAlarm]:Export[${ConfigFile}]
}
