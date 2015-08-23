;------------------------------------------------------------------------------
; EQ2Track.iss Version 4.0
;------------------------------------------------------------------------------
; EQ2 Track originally created by Equidis
; Rewritten by Valerian in 2010
; Updated by Amadeus in 2015
;----------------------------------------
; ** Additional credits to Karye & Blazer: Some of the UI & Elements & Coding
; used were taken from previous version of EQ2BotCommand **
;------------------------------------------------------------------------------


;-------------------------------------
; Options
;--------
;;;
; Enable/Disable the tracking of Corpses (and will remove actors from list once they become a corpse)
variable bool TrackCorpses = FALSE
; Enable/Disable the inclusion of "Class" in the string that appears in the tracking window
variable bool IncludeClass = FALSE
; After zoning, check and load the first found tracking list that has a name equal to the current ${Zone.ShortName}
variable bool AutoLoadListsOnZoning = TRUE
;;;
;-------------------------------------


;-------------------------------------
; Script Variables
;-----------------
	variable bool TrackListCombo_executeOnSelect=FALSE
	variable bool Tracking
	variable string itemInfo
	variable bool TrackAggro
	variable string ReverseFilter[20]
	variable int NumReverseFilters=0
	variable int LevelMin
	variable int LevelMax
	variable int SortMethod=1
	variable bool ReverseSort=FALSE
	variable string CurrentList
	variable bool filtersChanged=FALSE
	variable bool SortChanged=FALSE
	variable settingsetref User
	variable int aID1
	variable int aID2
	variable int L1
	variable int L2
	variable float D1
	variable float D2
	variable string T1
	variable string T2
	variable collection:string BadActors
;-------------------------------------



objectdef _TrackInterface
{
	method ChangeFilters()
	{
		filtersChanged:Set[TRUE]
	}
	method ChangeSort()
	{
		SortChanged:Set[TRUE]
	}
	method AddFilter()
	{
		if ${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItems}
		{
			do
			{
				if ${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItems} > 1
					UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItem[1]:Remove
			}
			while ${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItems} > 1
			UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItem[1]:SetText[${UIElement[EQ2 Track].FindUsableChild[FilterEditing,textentry].Text}]
		}
		else
		{
			if ${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].Items} != 20
				UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox]:AddItem[${UIElement[EQ2 Track].FindUsableChild[FilterEditing,textentry].Text}]
		}
		This:ChangeFilters
	}
	method DelFilter()
	{
		if ${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItems}
		{
			do
			{
				UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItem[1]:Remove
			}
			while ${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].SelectedItems}
		}
		This:ChangeFilters
	}
	method ClearFilters()
	{
		UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox]:ClearItems
		This:ChangeFilters
	}
	method SaveList(bool UpdateComboList=TRUE)
	{
		variable string SetName
		variable int Counter=0
		SetName:Set[${UIElement[EQ2 Track].FindUsableChild[TrackListName,textentry].Text}]
		
		if (${SetName.Length} == 0 || ${SetName.Equal[NULL]})
		{
			echo "EQ2Track.ERROR:: Attempting to SaveList() an invalid list name:  '${SetName}'"
		}
		else
		{ /* Create set to store list */
			LavishSettings:AddSet[TrackList]
			LavishSettings[TrackList]:AddSet[${SetName}]
			while ${Counter:Inc}<=${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].Items}
			{
				LavishSettings[TrackList].FindSet[${SetName}]:AddSetting[${Counter},${UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox].Item[${Counter}].Text}]
			}
			LavishSettings[TrackList].FindSet[${SetName}]:Export[${LavishScript.HomeDirectory}/Scripts/EQ2Track/Saved Lists/${SetName}.xml]
			LavishSettings[TrackList]:Remove
		}
		if ${UpdateComboList}
			This:UpdateListCombo
			
		CurrentList:Set[${SetName}]
	}
	method UpdateListCombo()
	{
		variable filelist ListFiles
		variable int Count=0
		UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox]:ClearItems
		ListFiles:GetFiles[${LavishScript.HomeDirectory}/Scripts/EQ2Track/Saved Lists/\*.xml]
		while ${Count:Inc}<=${ListFiles.Files}
		{
			UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox]:AddItem[${ListFiles.File[${Count}].Filename.Left[-4]}]
		}
		if ${UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].Items}
		{
			UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox]:Sort:SelectItem[1]
		}
	}
	method LoadList()
	{
		This:LoadListByName[${UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].SelectedItem.Text}]
	}
	method LoadListByName(string SetName)
	{
		variable int Counter=0
		variable iterator iter
		
		UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox]:ClearItems
		if ${SetName.Length}
		{
			CurrentList:Set[${SetName}]
			LavishSettings:AddSet[TrackList]
			LavishSettings[TrackList]:AddSet[${SetName}]
			LavishSettings[TrackList].FindSet[${SetName}]:Import[${LavishScript.HomeDirectory}/Scripts/EQ2Track/Saved Lists/${SetName}.xml]
			LavishSettings[TrackList].FindSet[${SetName}]:GetSettingIterator[iter]
			
			if ${iter:First(exists)}
			{
				do
				{
					UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox]:AddItem[${iter.Value}]
				}
				while ${iter:Next(exists)}
			}
			LavishSettings[TrackList]:Remove
		}
		This:ChangeFilters
		UpdateSettings
	}
	method DeleteList()
	{
		variable string SetName
		SetName:Set[${UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].SelectedItem.Text}]
		if ${SetName.Length}
		{
			CurrentList:Set[]
			rm "${LavishScript.HomeDirectory}/Scripts/EQ2Track/Saved Lists/${SetName}.xml"
			This:UpdateListCombo
		}
		UpdateSettings
	}
	method MarkTargetAsBad()
	{
		if (!${Target(exists)})
			return
		
		if (${BadActors.Element[${Target.ID}](exists)})
		{
			;echo "EQ2Track.MarkTargetAsBad():: Your current Target ([${Target.ID}-${Target.Name}) has already been marked as 'bad' and is not being tracked."
			return
		}
		
		;echo "EQ2Track.MarkTargetAsBad():: Marking ([${Target.ID}-${Target.Name}) as 'bad'.  This actor will no longer be tracked."
		BadActors:Set[${Target.ID},${Target.Name}]
		eq2execute "/waypoint_cancel"
	}
}

function zoneWait()
{
	if ${EQ2.Zoning}
	{
		UIElement[TrackItems@EQ2 Track]:ClearItems
		do
		{
			if !${UIElement[EQ2 Track].Visible} /* Element hidden, i.e. close button pressed. */
				Script:End
			waitframe
		}
		while ${EQ2.Zoning}
	}
}

objectdef TrackHelper
{
	variable int tcount
	variable int Level
	
	member:bool CheckFilter(int ID)
	{
		if ${TrackAggro} && !${Actor[${ID}].IsAggro}
			return FALSE
		if ${LevelMin} == -1 || ${LevelMax} == -1
			return FALSE
		Level:Set[${Actor[${ID}].Level}]
		if ${Level} < ${LevelMin} || ${Level} > ${LevelMax}
			return FALSE
		if ${NumReverseFilters} == 0
			return FALSE
		tcount:Set[${NumReverseFilters}]
		do
		{
			if ${itemInfo.Find[${ReverseFilter[${tcount}]}]}
				return TRUE
		}
		while ${tcount:Dec[1]} > 0

		return FALSE
	}
	
	method VerifyList()
	{
		variable int tcount
		variable int aID
		variable bool ActorHasNoLevelOrClass
		variable string ClassString
		variable string LevelString
		variable string TypeString
		variable string HealthString
		
		EQ2:CreateCustomActorArray
		if ${UIElement[TrackItems@EQ2 Track].SelectedItem(exists)} && !${CustomActor[ID,${UIElement[TrackItems@EQ2 Track].SelectedItem.Value}](exists)}
		{
			eq2execute /waypoint_cancel
			UIElement[TrackItems@EQ2 Track].SelectedItem:Remove
		}
		tcount:Set[${UIElement[TrackItems@EQ2 Track].Items}]
		do
		{
			aID:Set[${UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}].Value}]
			if (!${CustomActor[id,${aID}](exists)} || ${BadActors.Element[${aID}](exists)})
			{
				UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:Remove
			}
			else
			{
				;; TODO:  Add more types here
				if (${CustomActor[id,${aID}].Type.Equal[resource]}) 
					ActorHasNoLevelOrClass:Set[TRUE]
				else
					ActorHasNoLevelOrClass:Set[FALSE]
					
				if (!${TrackCorpses} && ${CustomActor[id,${aID}].Type.Equal[Corpse]})
					UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:Remove
				elseif (${BadActors.Element[${aID}](exists)})
					UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:Remove
				else
				{
					if (!${ActorHasNoLevelOrClass} && ${IncludeClass} )
						ClassString:Set[${CustomActor[ID,${aID}].Class}]
					else
						ClassString:Set[]
						
					if (${ActorHasNoLevelOrClass})
					{
						LevelString:Set[]
						TypeString:Set[(${CustomActor[ID,${aID}].Type})]
						HealthString:Set[]
						
					}
					else
					{
						LevelString:Set[(${CustomActor[ID,${aID}].Level})]
						TypeString:Set[]
						HealthString:Set[(${CustomActor[ID,${aID}].Health}%)]
					}
						
					UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:SetText[${LevelString} ${TypeString} ${CustomActor[ID,${aID}].Name} ${HealthString} ${ClassString} ${CustomActor[ID,${aID}].Distance.Centi} ${CustomActor[ID,${aID}].HeadingTo["AsString"]}]
				}
			}
		}
		while ${tcount:Dec[1]} > 0
		UIElement[TrackItems@EQ2 Track]:Sort[TrackSort]
	}
}


variable TrackHelper Tracker

function main(... Args)
{
	declarevariable TrackInterface _TrackInterface global
	TrackListCombo_executeOnSelect:Set[FALSE]
	
	;;;;;;;;;;;;;;;;
	;;; IMPORTANT:   these two lines MUST be executed BEFORE loadings settings from XML
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${Script.CurrentDirectory}/UI/EQ2Track.xml"
	;;;;;;;;;;;;;;;;
	
	LavishSettings:AddSet[EQ2Track]
	LavishSettings[EQ2Track]:AddSet[Users]
	LavishSettings[EQ2Track].FindSet[Users]:AddSet[${Me.Name}]
	User:Set[${LavishSettings[EQ2Track].FindSet[Users].FindSet[${Me.Name}]}]
	User:AddSet[ReverseFilters]
	User:Import["${Script.CurrentDirectory}/Character Config/${Me.Name}_Settings.xml"]


	if ${Args.Used}
	{
		TrackInterface:LoadListByName[${Args.Expand}]
	}

	TrackAggro:Set[${User.FindSetting[TrackAggro,FALSE]}]
	LevelMin:Set[${User.FindSetting[LevelMin,0]}]
	LevelMax:Set[${User.FindSetting[LevelMax,100]}]
	SortMethod:Set[${User.FindSetting[SortMethod,1]}]
	ReverseSort:Set[${User.FindSetting[ReverseSort,FALSE]}]
	CurrentList:Set[${User.FindSetting[CurrentList,""]}]
	
	if ${TrackAggro}
		UIElement[TrackAggro@EQ2 Track]:SetChecked
	else
		UIElement[TrackAggro@EQ2 Track]:UnsetChecked
	UIElement[TrackMinLevel@EQ2 Track]:SetText[${LevelMin}]
	UIElement[TrackMaxLevel@EQ2 Track]:SetText[${LevelMax}]
	UIElement[TrackSort@EQ2 Track]:SetSelection[${SortMethod}]
	
	variable iterator SettingIterator
	User.FindSet[ReverseFilters]:GetSettingIterator[SettingIterator]
	NumReverseFilters:Set[0]
	if ${SettingIterator:First(exists)}
	{
		do
		{
			NumReverseFilters:Inc
			ReverseFilter[${NumReverseFilters}]:Set[${SettingIterator.Value}]
			UIElement[FiltersList@EQ2 Track]:AddItem[${ReverseFilter[${NumReverseFilters}]}]
		}
		while ${SettingIterator:Next(exists)}
	}
	
	RefreshList
	call CheckListTimer
	call RefreshWaypointTimer
	SortMethod:Set[${UIElement[TrackSort@EQ2 Track].Selection}]
	
	Event[EQ2_ActorSpawned]:AttachAtom[EQ2_ActorSpawned]
	Event[EQ2_ActorDespawned]:AttachAtom[EQ2_ActorDespawned]
	Event[EQ2_FinishedZoning]:AttachAtom[EQ2_FinishedZoning]
	
	if (${CurrentList.Length} > 0)
	{
		UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].ItemByText[${CurrentList}]:Select
	}
	
	TrackListCombo_executeOnSelect:Set[TRUE]
	do
	{
		if ${QueuedCommands}
			ExecuteQueued
		waitframe

		if !${UIElement[EQ2 Track].Visible} /* Element hidden, i.e. close button pressed. */
			Script:End

		call zoneWait
		if ${filtersChanged}
		{
			RefreshList
			filtersChanged:Set[FALSE]
		}
		if ${SortChanged}
		{
			SortMethod:Set[${UIElement[TrackSort@EQ2 Track].Selection}]
			ReverseSort:Set[FALSE]
			UIElement[TrackItems@EQ2 Track]:Sort[TrackSort]
			User.FindSetting[SortMethod]:Set[${SortMethod}]
			User.FindSetting[ReverseSort]:Set[${ReverseSort}]
			User:Export["${Script.CurrentDirectory}/Character Config/${Me.Name}_Settings.xml"]
			SortChanged:Set[FALSE]
		}
	}
	while 1
}

atom(script) UpdateSettings()
{
	variable settingsetref filters
	TrackAggro:Set[${UIElement[TrackAggro@EQ2 Track].Checked}]
	if ${UIElement[TrackMinLevel@EQ2 Track].Text.Equal[""]}
	{
		LevelMin:Set[-1]
	}
	else
	{
		LevelMin:Set[${UIElement[TrackMinLevel@EQ2 Track].Text}]
	}
	if ${UIElement[TrackMaxLevel@EQ2 Track].Text.Equal[""]}
	{
		LevelMax:Set[-1]
	}
	else
	{
		LevelMax:Set[${UIElement[TrackMaxLevel@EQ2 Track].Text}]
	}

	User.FindSetting[TrackAggro]:Set[${TrackAggro}]
	User.FindSetting[LevelMin]:Set[${LevelMin}]
	User.FindSetting[LevelMax]:Set[${LevelMax}]
	
	User.FindSetting[CurrentList]:Set[${CurrentList}]
	
	variable iterator SettingIterator
	filters:Set[${User.FindSet[ReverseFilters]}]
	filters:Clear
	NumReverseFilters:Set[0]
	if ${UIElement[FiltersList@EQ2 Track].Items}
	{
		do
		{
			NumReverseFilters:Inc
			ReverseFilter[${NumReverseFilters}]:Set[${UIElement[FiltersList@EQ2 Track].OrderedItem[${NumReverseFilters}].Text}]
			filters:AddSetting[${NumReverseFilters},${ReverseFilter[${NumReverseFilters}]}]
		}
		while ${NumReverseFilters} < ${UIElement[FiltersList@EQ2 Track].Items}
	}
	User:Export["${Script.CurrentDirectory}/Character Config/${Me.Name}_Settings.xml"]

}

function CheckListTimer()
{
	Tracker:VerifyList
	timedcommand 20 Script[${Script.Filename}]:QueueCommand[call CheckListTimer]
}

function RefreshWaypointTimer()
{
	if ${UIElement[TrackItems@EQ2 Track].SelectedItem(exists)}
		eq2execute /waypoint ${Actor[${UIElement[TrackItems@EQ2 Track].SelectedItem.Value}].Loc}
	timedcommand 80 Script[${Script.Filename}]:QueueCommand[call RefreshWaypointTimer]
}

atom(script) RefreshList()
{
	variable int tcount
	variable bool ActorHasNoLevelOrClass
	variable string ClassString
	variable string LevelString
	variable string TypeString
	variable string HealthString
	
	UpdateSettings
	if ${Tracking}
		return
	Tracking:Set[TRUE]

	UIElement[TrackItems@EQ2 Track]:ClearItems
	EQ2:CreateCustomActorArray
	tcount:Set[${EQ2.CustomActorArraySize}]
	do
	{
		if (!${TrackCorpses} && ${CustomActor[${tcount}].Type.Equal[Corpse]})
		{
			continue
		}
			
		if ${BadActors.Element[${CustomActor[${tcount}].ID}](exists)}
		{
			continue
		}
			
		;; TODO:  Add more types here
		if (${CustomActor[${tcount}].Type.Equal[resource]})   
			ActorHasNoLevelOrClass:Set[TRUE]
		else
			ActorHasNoLevelOrClass:Set[FALSE]
			
		if (!${ActorHasNoLevelOrClass} && ${IncludeClass})
			ClassString:Set[${CustomActor[${tcount}].Class}]
		else
			ClassString:Set[]
			
		if (${ActorHasNoLevelOrClass})
		{
			LevelString:Set[]
			TypeString:Set[(${CustomActor[${tcount}].Type})]
			HealthString:Set[]
			
		}
		else
		{
			LevelString:Set[(${CustomActor[${tcount}].Level})]
			TypeString:Set[]
			HealthString:Set[(${CustomActor[${tcount}].Health}%)]
		}
			
		
		itemInfo:Set[${LevelString} ${TypeString} ${CustomActor[${tcount}].Name} ${HealthString} ${ClassString} ${CustomActor[${tcount}].Distance.Centi} ${CustomActor[${tcount}].HeadingTo["AsString"]}]
		if ${Tracker.CheckFilter[${CustomActor[${tcount}].ID}]}
			UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo},${CustomActor[${tcount}].ID}]
	}
	while ${tcount:Dec[1]} > 0
	UIElement[TrackItems@EQ2 Track]:Sort[TrackSort]
	
	Tracking:Set[FALSE]
}

atom(global):int TrackSort(int ID1, int ID2)
{
	if ${SortMethod} == 5
		return 0
	variable int RetVal=0
	aID1:Set[${UIElement[TrackItems@EQ2 Track].Item[${ID1}].Value}]
	aID2:Set[${UIElement[TrackItems@EQ2 Track].Item[${ID2}].Value}]
	/* Sorting:
		We'll use int values, from a dropdown, etc.
		1 = Distance (default)
		2 = Name
		3 = Level
		4 = Type
	*/
	switch ${SortMethod}
	{
		case 4
			T1:Set[${Actor[${aID1}].Type}]
			T2:Set[${Actor[${aID2}].Type}]
			RetVal:Set[${T1.Compare[${T2}]}]
			break
		case 2
			if !${RetVal}
				RetVal:Set[${Actor[${aID1}].Name.Compare[${Actor[${aID2}].Name}]}]
			break
		case 3
			if !${RetVal}
			{
				L1:Set[${Actor[${aID1}].Level}]
				L2:Set[${Actor[${aID2}].Level}]
				if ${L1} > ${L2}
					RetVal:Set[1]
				elseif ${L1} < ${L2}
					RetVal:Set[-1]
			}
			break
		case 1
			if !${RetVal}
			{
				D1:Set[${Actor[${aID1}].Distance}]
				D2:Set[${Actor[${aID2}].Distance}]
				if ${D1} > ${D2}
					RetVal:Set[1]
				elseif ${D1} < ${D2}
					RetVal:Set[-1]
			}
	}
	return ${RetVal}
}

atom(script) EQ2_FinishedZoning(string TimeInSeconds)
{
	variable filelist ListFiles
	variable int Count=0
	variable string ListName
	
	if !${AutoLoadListsOnZoning}
		return
		
	ListFiles:GetFiles[${LavishScript.HomeDirectory}/Scripts/EQ2Track/Saved Lists/\*.xml]
	while ${Count:Inc}<=${ListFiles.Files}
	{
		ListName:Set[${ListFiles.File[${Count}].Filename.Left[-4]}]
		
		;echo "EQ2Track.Debug:: Does '${Zone.ShortName}' == '${ListName}'"
		if ${Zone.ShortName.Equal[${ListName}]}
		{
			;echo "EQ2Track.Debug:: Loading ${ListName}"
			TrackInterface:LoadListByName[${ListName}]
			UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].ItemByText[${ListName}]:Select
			return
		}
	}
	
	return
}

atom(script) EQ2_ActorSpawned(string ID, string Name, string Level, string ActorType)
{
	variable bool ActorHasNoLevelOrClass
	variable string ClassString
	variable string LevelString
	variable string TypeString
	variable string HealthString
	
	if (!${TrackCorpses} && ${ActorType.Equal[Corpse]})
		return
		
	if (${BadActors.Element[${ID}](exists)})
		return
		
	;; TODO:  Add more types here
	if (${ActorType.Equal[resource]})   
		ActorHasNoLevelOrClass:Set[TRUE]
	else
		ActorHasNoLevelOrClass:Set[FALSE]

	if (!${ActorHasNoLevelOrClass} && ${IncludeClass})
		ClassString:Set[${Actor[${ID}].Class}]
	else
		ClassString:Set[]
		
	if (${ActorHasNoLevelOrClass})
	{
		LevelString:Set[]
		TypeString:Set[(${ActorType})]
		HealthString:Set[]
		
	}
	else
	{
		LevelString:Set[(${Level})]
		TypeString:Set[]
		HealthString:Set[(${Actor[${ID}].Health}%)]
	}

	itemInfo:Set[${LevelString} ${TypeString} ${Name} ${HealthString} ${ClassString} ${Actor[${ID}].Distance.Centi} ${Actor[${ID}].HeadingTo["AsString"]}]


	; check our filters.
	if ${Tracker.CheckFilter[${ID}]}
		UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo},${ID}]:Sort[TrackSort]
	; if this actor matches our filters, add it to the tracking window
	
}

atom(script) EQ2_ActorDespawned(string ID, string Name)
{
	if (${BadActors.Element[${ID}](exists)})
		return
	
	variable int tcount=${UIElement[TrackItems@EQ2 Track].Items}

	do
	{
		if (${UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}].Value} == ${ID})
			UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:Remove
		tcount:Dec[1]
	}
	while ${tcount}>0
}

function atexit()
{
	ui -unload "${Script.CurrentDirectory}/UI/EQ2Track.xml"
	eq2execute "/waypoint_cancel"
}

