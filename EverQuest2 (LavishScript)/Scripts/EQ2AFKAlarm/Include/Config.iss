


function config_load()
{
	SettingXML[${ConfigFile}]:Unload

	declare testVersion string local ${SettingXML[${ConfigFile}].Set[Config].GetString[Script_Version]}

	if ${testVersion.NotEqual[${EQ2AFKAlarm_version}]} || ${EQ2AFKAlarm_version_devel}
	{
		MessageBox " Configuration version does not match EQ2AFKAlarm version, \n resetting user configs to defaults... \n"

		SettingXML[${ConfigFile}]:RemoveSet[Config]
	}

	Logging:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[Logging,TRUE]}]
	TriggerSays:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[TriggerSays,FALSE]}]
	TriggerTells:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[TriggerTells,FALSE]}]
	TriggerGroup:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[TriggerGroup,FALSE]}]
	TriggerRaid:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[TriggerRaid,FALSE]}]
	TriggerGuild:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[TriggerGuild,FALSE]}]
	TriggerOfficer:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[TriggerOfficer,FALSE]}]
	Script_Version:Set[${SettingXML[${ConfigFile}].Set[Config].GetString[Script_Version,FALSE]}]
}

function config_save()
{
	SettingXML[${ConfigFile}].Set[Config]:Set[Script_Version,${EQ2AFKAlarm_version}]

	SettingXML[${ConfigFile}].Set[Config]:Set[Logging,${Logging}]
	SettingXML[${ConfigFile}].Set[Config]:Set[TriggerSays,${TriggerSays}]
	SettingXML[${ConfigFile}].Set[Config]:Set[TriggerTells,${TriggerTells}]
	SettingXML[${ConfigFile}].Set[Config]:Set[TriggerGroup,${TriggerGroup}]
	SettingXML[${ConfigFile}].Set[Config]:Set[TriggerRaid,${TriggerRaid}]
	SettingXML[${ConfigFile}].Set[Config]:Set[TriggerGuild,${TriggerGuild}]
	SettingXML[${ConfigFile}].Set[Config]:Set[TriggerOfficer,${TriggerOfficer}]
		
	SettingXML[${ConfigFile}]:Save
}