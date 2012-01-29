objectdef theDebug
{
	variable time NextPulse
	variable int PulseIntervalInSeconds = 2
	
	method Initialize()
	{
		Event[EVENT_ONFRAME]:AttachAtom[This:Pulse]
	}
	method Shutdown()
	{
		LavishSettings[WreckingDebug]:Export[Debug/WreckingDebug.xml]
		LavishSettings[WreckingDebug]:Remove
		Event[EVENT_ONFRAME]:DetachAtom[This:Pulse]
	}
	
	method Pulse()
	{
	    if ${Time.Timestamp} >= ${This.NextPulse.Timestamp}
		{
    		This.NextPulse:Set[${Time.Timestamp}]
    		This.NextPulse.Second:Inc[${This.PulseIntervalInSeconds}]
    		This.NextPulse:Update
			
			if ${EntityWatch} && INSPACE
				This:GetEntities
			if ${EntityWatch} && !INSPACE
				This:GetItems
		}
	}
	
	member Runtime()
	{
		DeclareVariable RunTime float ${Math.Calc[${Script.RunningTime}/1000/60]}
		DeclareVariable Hours string ${Math.Calc[(${RunTime}/60)%60].Int.LeadingZeroes[2]}
		DeclareVariable Minutes string ${Math.Calc[${RunTime}%60].Int.LeadingZeroes[2]}
		DeclareVariable Seconds string ${Math.Calc[(${RunTime}*60)%60].Int.LeadingZeroes[2]}
		return "${Hours}:${Minutes}:${Seconds}"
	}
	
	method Spew(string Message, string curState, bool WasError)
	{
		State:Set[${curState}]
		variable string Tmp
		if ${WasError}
			Tmp:Set["ERROR - "]
		else
			Tmp:Set["DEBUG - "]
		Tmp:Concat["${curState} - ${Message}"]
		if ${ShowDebug}
		{
			LavishSettings:AddSet[WreckingDebug]
			LavishSettings[WreckingDebug]:AddSetting["${MessageCount}", "${Tmp}"]
			LavishSettings[WreckingDebug].FindSetting["${MessageCount}"]:AddAttribute[State,"${State}"]
			LavishSettings[WreckingDebug].FindSetting["${MessageCount}"]:AddAttribute[RunTime,"${This.Runtime}"]	
			UIElement[StatusConsole@Main@WreckingTabControl@WreckingBot]:Echo["${This.Runtime} - ${Tmp}"]
		}
		elseif ${WasError}
		{
			LavishSettings:AddSet[WreckingDebug]
			LavishSettings[WreckingDebug]:AddSetting["${MessageCount}", "${Tmp}"]
			LavishSettings[WreckingDebug].FindSetting["${MessageCount}"]:AddAttribute[State,"${State}"]
			LavishSettings[WreckingDebug].FindSetting["${MessageCount}"]:AddAttribute[RunTime,"${This.Runtime}"]	
			UIElement[StatusConsole@Main@WreckingTabControl@WreckingBot]:Echo["${This.Runtime} - ${Tmp}"]
		}
		else
			UIElement[StatusConsole@Main@WreckingTabControl@WreckingBot]:Echo["${This.Runtime} - ${State}"]
		
		MessageCount:Inc
	}
	
	method GetEntities()
	{
		variable settingsetref EntityListingA
		variable settingsetref EntityListingB
		variable settingsetref EntityCat
		variable settingsetref EntityGroup
		variable string Category
		variable string Group
		variable string TypeName
		variable int CatID
		variable int GroupID
		variable int TypeID
		variable int Bounty
		variable index:entity MyScan
		variable iterator Iter
		variable bool Changed = FALSE

		LavishSettings:AddSet[EntityListA]
		LavishSettings:AddSet[EntityListB]
		LavishSettings[EntityListA]:Import[Debug/EntityListingA.xml]
		LavishSettings[EntityListB]:Import[Debug/EntityListingB.xml]
		EntityListingA:Set[${LavishSettings.FindSet[EntityListA]}]
		EntityListingB:Set[${LavishSettings.FindSet[EntityListB]}]
		EVE:QueryEntities[MyScan]
		MyScan:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Category:Set[${Iter.Value.Category}]
			Group:Set[${Iter.Value.Group}]
			TypeName:Set[${Iter.Value.Type}]
			CatID:Set[${Iter.Value.CategoryID}]
			GroupID:Set[${Iter.Value.GroupID}]
			TypeID:Set[${Iter.Value.TypeID}]
			
			Bounty:Set[${Iter.Value.Bounty}]
			
			if ${Category.Find[Null]} > 0 || ${Group.Find[Null]} > 0 || ${Type.Find[Null]} > 0 || ${CatID} == 0 || ${GroupID} == 0 || ${TypeID} == 0
				continue
			
			if !${EntityListingA.FindSet[${Category}](exists)}
			{
				EntityListingA:AddSet["${Category}"]
				EntityListingA:Sort
				EntityListingA.FindSet[${Category}]:AddAttribute[CatID,${CatID}]
			}
			EntityCat:Set[${EntityListingA.FindSet[${Category}]}]
			if !${EntityCat.FindSet[${Group}](exists)}
			{
				EntityCat:AddSet["${Group}"]
				EntityCat:Sort
				EntityCat.FindSet[${Group}]:AddAttribute[GroupID,${GroupID}]
			}
			EntityGroup:Set[${EntityCat.FindSet[${Group}]}]
			if !${EntityGroup.FindSetting[${TypeName}](exists)}
			{
				echo Found - Cat-${Category}, Gr-${Group}, Type-${TypeName}
				EntityGroup:AddSetting["${TypeName}", ${TypeID}]
				if ${Bounty} > 0
					EntityGroup.FindSetting[${TypeName}]:AddAttribute[Bounty,${Bounty}]
				EntityGroup:Sort
				Changed:Set[TRUE]
			}
			if !${EntityListingB.FindSetting[${TypeName}](exists)}
			{
				EntityListingB:AddSetting["${TypeName}", ${TypeID}]
				EntityListingB.FindSetting[${TypeName}]:AddAttribute[Group,${Group}]
				EntityListingB.FindSetting[${TypeName}]:AddAttribute[GroupID,${GroupID}]
				EntityListingB.FindSetting[${TypeName}]:AddAttribute[Category,${Category}]
				EntityListingB.FindSetting[${TypeName}]:AddAttribute[CategoryID,${CatID}]
			}
		}
		while ${Iter:Next(exists)}
		if ${Changed}
		{
			EntityListingB:Sort
			LavishSettings[EntityListA]:Export[Debug/EntityListingA.xml]
			LavishSettings[EntityListB]:Export[Debug/EntityListingB.xml]
		}
		LavishSettings[EntityListA]:Remove
		LavishSettings[EntityListB]:Remove
	}
	
	method GetItems()
	{
		variable settingsetref ItemListingA
		variable settingsetref ItemListingB
		variable settingsetref ItemCat
		variable settingsetref ItemGroup
		variable string Category
		variable string Group
		variable string TypeName
		variable int CatID
		variable int GroupID
		variable int TypeID
		variable index:item MyScan
		variable iterator Iter
		variable bool Changed = FALSE

		LavishSettings:AddSet[ItemListA]
		LavishSettings:AddSet[ItemListB]
		LavishSettings[ItemListA]:Import[Debug/ItemListingA.xml]
		LavishSettings[ItemListB]:Import[Debug/ItemListingB.xml]
		ItemListingA:Set[${LavishSettings.FindSet[ItemListA]}]
		ItemListingB:Set[${LavishSettings.FindSet[ItemListB]}]
		Me.Station:GetHangarItems[MyScan]
		MyScan:GetIterator[Iter]
		if ${Iter:First(exists)}
		do
		{
			Category:Set[${Iter.Value.Category}]
			Group:Set[${Iter.Value.Group}]
			TypeName:Set[${Iter.Value.Type}]
			CatID:Set[${Iter.Value.CategoryID}]
			GroupID:Set[${Iter.Value.GroupID}]
			TypeID:Set[${Iter.Value.TypeID}]
			
			if ${Category.Find[Null]} > 0 || ${Group.Find[Null]} > 0 || ${Type.Find[Null]} > 0 || ${CatID} == 0 || ${GroupID} == 0 || ${TypeID} == 0
				continue
			
			if !${ItemListingA.FindSet[${Category}](exists)}
			{
				ItemListingA:AddSet["${Category}"]
				ItemListingA:Sort
				ItemListingA.FindSet[${Category}]:AddAttribute[CatID,${CatID}]
			}
			ItemCat:Set[${ItemListingA.FindSet[${Category}]}]
			if !${ItemCat.FindSet[${Group}](exists)}
			{
				ItemCat:AddSet["${Group}"]
				ItemCat:Sort
				ItemCat.FindSet[${Group}]:AddAttribute[GroupID,${GroupID}]
			}
			ItemGroup:Set[${ItemCat.FindSet[${Group}]}]
			if !${ItemGroup.FindSetting[${TypeName}](exists)}
			{
				echo Found - Cat-${Category}, Gr-${Group}, Type-${TypeName}
				ItemGroup:AddSetting["${TypeName}", ${TypeID}]
				ItemGroup:Sort
				Changed:Set[TRUE]
			}
			if !${ItemListingB.FindSetting[${TypeName}](exists)}
			{
				ItemListingB:AddSetting["${TypeName}", ${TypeID}]
				ItemListingB.FindSetting[${TypeName}]:AddAttribute[Group,${Group}]
				ItemListingB.FindSetting[${TypeName}]:AddAttribute[GroupID,${GroupID}]
				ItemListingB.FindSetting[${TypeName}]:AddAttribute[Category,${Category}]
				ItemListingB.FindSetting[${TypeName}]:AddAttribute[CategoryID,${CatID}]
			}
		}
		while ${Iter:Next(exists)}
		if ${Changed}
		{
			ItemListingB:Sort
			LavishSettings[ItemListA]:Export[Debug/ItemListingA.xml]
			LavishSettings[ItemListB]:Export[Debug/ItemListingB.xml]
		}
		LavishSettings[ItemListA]:Remove
		LavishSettings[ItemListB]:Remove
	}
}