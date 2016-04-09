variable(script) int TotalRedMessages = 0
objectdef obj_StatusUpdate
{


	method Initialize()
	{
	}
	
	method Shutdown()
	{
		LavishSettings[WreckingDebug]:Export[Debug/WreckingDebug.xml]
		LavishSettings[WreckingDebug]:Remove
	}

	member Runtime()
	{
		DeclareVariable RunTime float ${Math.Calc[${Script.RunningTime}/1000/60]}
		DeclareVariable Hours string ${Math.Calc[(${RunTime}/60)%60].Int.LeadingZeroes[2]}
		DeclareVariable Minutes string ${Math.Calc[${RunTime}%60].Int.LeadingZeroes[2]}
		DeclareVariable Seconds string ${Math.Calc[(${RunTime}*60)%60].Int.LeadingZeroes[2]}
		return "${Hours}:${Minutes}:${Seconds}"
	}

	method Green(string ConsoleMsg)
	{
		UIElement[StatusConsole@Main@WreckingTabControl@WreckingBot]:Echo["${This.Runtime} - ${ConsoleMsg}"]
		UIElement[StatusConsole@Missioner@WreckingTabControl@WreckingBot]:Echo["${This.Runtime} - ${ConsoleMsg}"]
	}

	method Yellow(string YellowStatusMsg)
	{
		variable int YellowTime = ${Script.RunningTime}
		TotalRedMessages:Inc
		if ${DebugOn}
		{
			LavishSettings:AddSet[WreckingDebug]
			LavishSettings[WreckingDebug]:AddSetting["${TotalRedMessages}-${YellowTime}", "${YellowStatusMsg}"]
			LavishSettings[WreckingDebug].FindSetting["${TotalRedMessages}-${YellowTime}"]:AddAttribute[Stage,"${BotCurrentState}"]
		}
	}
	
	method Red(string RedStatusMsg)
	{
		variable int RedTime = ${Script.RunningTime}
		TotalRedMessages:Inc
		LavishSettings:AddSet[WreckingDebug]
		LavishSettings[WreckingDebug]:AddSetting["${TotalRedMessages}-${RedTime}",ERROR "${RedStatusMsg}"]
		LavishSettings[WreckingDebug].FindSetting["${TotalRedMessages}-${RedTime}"]:AddAttribute[Stage,"${BotCurrentState}"]
	}

	function White()
	{
		variable settingsetref EntityListing
		variable settingsetref EntityCat
		variable settingsetref EntityGroup
		variable index:entity MyScan
		variable iterator Whites
		variable bool AlwaysOn = TRUE
		variable string Noid = "NULL"

		
		LavishSettings:AddSet[EntityList]
		LavishSettings[EntityList]:Import[EntityListing.xml]
		EntityListing:Set[${LavishSettings.FindSet[EntityList]}]
		EVE:DoGetEntities[MyScan]
		MyScan:GetIterator[Whites]
		if ${Whites:First(exists)}
		do
		{
			if !(${EntityListing.FindSet[${Whites.Value.Category}](exists)}) && ${Whites.Value.Category.Find[${Noid}]} < 1
			{
				EntityListing:AddSet["${Whites.Value.Category}"]
				EntityListing:Sort
				;EntityCat:Set[${EntityListing.FindSet[${Whites.Value.Category}]}]
				EntityListing.FindSet[${Whites.Value.Category}]:AddAttribute[CatID,${Whites.Value.CategoryID}]
				if ${EntityListing.FindSet[${Noid}](exists)}
					EntityListing.FindSet[${Noid}]:Clear
			}
			EntityCat:Set[${EntityListing.FindSet[${Whites.Value.Category}]}]
			;EntityCat:AddAttribute[CatID,${Whites.Value.CategoryID}]
			if !(${EntityCat.FindSet[${Whites.Value.Group}](exists)}) && ${Whites.Value.Group.Find[${Noid}]} < 1
			{
				EntityCat:AddSet["${Whites.Value.Group}"]
				EntityCat:Sort
				;EntityGroup:Set[${EntityCat.FindSet[${Whites.Value.Group}]}]
				EntityCat.FindSet[${Whites.Value.Group}]:AddAttribute[GroupID,${Whites.Value.GroupID}]
				if ${EntityCat.FindSet[${Noid}](exists)}
					EntityCat.FindSet[${Noid}]:Clear
			}
			EntityGroup:Set[${EntityCat.FindSet[${Whites.Value.Group}]}]
			;EntityGroup:AddAttribute[GroupID,${Whites.Value.GroupID}]
			if !(${EntityGroup.FindSetting[${Whites.Value.Type}](exists)} && ${Whites.Value.Type.Find[${Noid}]} < 1
			{
				EntityGroup:AddSetting[${Whites.Value.Type},""]
				EntityGroup.FindSetting[${Whites.Value.Type}]:AddAttribute[ID,${Whites.Value.TypeID}]
				EntityGroup:Sort
				echo --------========Found - Cat-${Whites.Value.Category}, Gr-${Whites.Value.Group}, Type-${Whites.Value.Type}
				if ${EntityGroup.FindSet[${Noid}](exists)}
					EntityGroup.FindSet[${Noid}]:Clear
			}
		}
		while ${Whites:Next(exists)}
		
		LavishSettings[EntityList]:Export[EntityListing.xml]
		LavishSettings[EntityList]:Remove
	}
}