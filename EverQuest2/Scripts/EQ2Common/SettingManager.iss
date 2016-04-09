/* SettingManager.iss
 * Written by: Valerian
 * Provides objects for maintaining settings.
 * Should be used as collection:_Setting.
 *
 * *NOTE* _Settings object has not been tested.
 *
 */
#ifndef __SettingManager
#define __SettingManager

objectdef _Setting
{
	variable string SettingName
	variable string CurrentValue
	variable string DefaultValue
	variable settingsetref Set
	
	method Initialize(settingsetref SSR, string SName, string D)
	{
		SettingName:Set[${SName}]
		DefaultValue:Set[${D}]
		Set:Set[${SSR}]
		CurrentValue:Set[${SSR.FindSetting[${SName},${D}]}]
	}
	method Reset()
	{
		CurrentValue:Set[${DefaultValue}]
		Set:AddSetting[${SettingName},${DefaultValue}]
	}
	method Set(string V)
	{
		CurrentValue:Set[${V}]
		Set:AddSetting[${SettingName},${V}]
	}
	member Value()
	{
		return ${CurrentValue}
	}
}

objectdef _Settings
{
	variable collection:string SetFilenames
	variable collection:_Setting Setts
	
	method Initialize(string SSR, string Filename)
	{
		if ${SSR.Length}
			SetFilenames:Set[${SSR},${Filename}]
	}
	method SetFilename(string SSR, string Filename)
	{
		if ${SSR.Length}
			SetFilenames:Set[${SSR},${Filename}]
	}
	method SaveSettings(string SSR)
	{
		variable settingsetref S
		if ${SetFilenames.Element[${SSR}](exists)}
		{
			S:Set[${SSR}]
			S:Export[${SetFilenames.Element[${SSR}]}]
		}
		else
		{
			; Need to iterate through all SSRs in the collection with filenames.
			if (${SetFilenames.FirstKey(exists)})
			{
				do
				{
					S:Set[${SetFilenames.CurrentKey}]
					S:Export[${SetFilenames.CurrentValue}]
				}
				while ${SetFilenames.NextKey(exists)}
			}
		}
	}
	method LoadSettings(string SSR)
	{
		variable settingsetref S
		if ${SetFilenames.Element[${SSR}](exists)}
		{
			S:Set[${SSR}]
			S:Import[${SetFilenames.Element[${SSR}]}]
		}
		else
		{
			if (${SetFilenames.FirstKey(exists)})
			{
				do
				{
					S:Set[${SetFilenames.CurrentKey}]
					S:Import[${SetFilenames.CurrentValue}]
				}
				while ${SetFilenames.NextKey(exists)}
			}
		}
	}
	method AddSetting(string SettingName, settingsetref SSR, string SettingText, string DefaultValue)
	{
		Setts:Set[${SettingName},${SSR},${SettingText},${DefaultValue}]
	}
	member:string GetSetting(string Setting)
	{
		return ${Setts.Element[${Setting}].Value}
	}
	method SetSetting(string Setting, string Value)
	{
		Setts.Element[${Setting}]:Set[${Value}]
		This:SaveSettings
	}
}
#endif /* __SettingManager */
