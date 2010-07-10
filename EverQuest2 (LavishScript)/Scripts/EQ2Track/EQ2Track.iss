
;------------------------------------------------------------------------------
; EQ2Track.iss Version 3.1 Updated: 01/22/10 by Valerian
;------------------------------------------------------------------------------
; EQ2 Track originally created by Equidis
; Rewritten by Valerian
;------------------------------------------------------------------------------

; ** Additional credits to Karye & Blazer: Some of the UI & Elements & Coding
; used were taken from previous version of EQ2BotCommand **


/* -------------------------------------------------------------------------
   01/12/10 v3.0 
      - Updated to allow saving and loading of filter lists.
      - Added "Clr" button to filter controls to clear current filters.
      - Cleaned up Script<->UI interface.
   01/22/10 v3.1
      - Added ability to specify saved filter list on command line.
   ------------------------------------------------------------------------- */


	variable bool filtersChanged
	variable bool SortChanged
;-------------------------------------

;-------------------------------------
; General
;-------------------------------------

	variable bool Tracking
	variable string itemInfo
	variable bool TrackAggro
	variable string ReverseFilter[20]
	;variable string ReverseFilter
	variable int NumReverseFilters=0
	variable int LevelMin
	variable int LevelMax
	variable int SortMethod=1
	variable bool ReverseSort=FALSE
	
	variable settingsetref User
	
	variable int aID1
	variable int aID2
	variable int L1
	variable int L2
	variable float D1
	variable float D2
	variable string T1
	variable string T2
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
	method SaveList()
	{
		variable string SetName
		variable int Counter=0
		SetName:Set[${UIElement[EQ2 Track].FindUsableChild[TrackListName,textentry].Text}]
		if ${SetName.Length}
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
		This:UpdateListCombo
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
		variable string SetName
		variable int Counter=0
		variable iterator iter
		This:LoadListByName[${UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].SelectedItem.Text}]
	}
	method LoadListByName(string SetName)
	{
		variable int Counter=0
		variable iterator iter
		UIElement[EQ2 Track].FindUsableChild[FiltersList,listbox]:ClearItems
		if ${SetName.Length}
		{
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
	}
	method DeleteList()
	{
		variable string SetName
		SetName:Set[${UIElement[EQ2 Track].FindUsableChild[TrackListCombo,combobox].SelectedItem.Text}]
		if ${SetName.Length}
		{
			rm "${LavishScript.HomeDirectory}/Scripts/EQ2Track/Saved Lists/${SetName}.xml"
			This:UpdateListCombo
		}
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
	variable int Level
	method VerifyList()
	{
		EQ2:CreateCustomActorArray
		if ${UIElement[TrackItems@EQ2 Track].SelectedItem(exists)} && !${CustomActor[ID,${UIElement[TrackItems@EQ2 Track].SelectedItem.Value}](exists)}
		{
			eq2execute /waypoint_cancel
			UIElement[TrackItems@EQ2 Track].SelectedItem:Remove
		}
		variable int tcount
		variable int aID
		tcount:Set[${UIElement[TrackItems@EQ2 Track].Items}]
		do
		{
			aID:Set[${UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}].Value}]
			if !${CustomActor[id,${aID}](exists)}
			{
				UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:Remove
			}
			else
			{
				UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:SetText[${CustomActor[ID,${aID}].Level} (${CustomActor[ID,${aID}].Type}) ${CustomActor[ID,${aID}].Name} ${CustomActor[ID,${aID}].Class} ${CustomActor[ID,${aID}].Distance.Centi}]
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
	LavishSettings:AddSet[EQ2Track]
	LavishSettings[EQ2Track]:AddSet[Users]
	LavishSettings[EQ2Track].FindSet[Users]:AddSet[${Me.Name}]
	User:Set[${LavishSettings[EQ2Track].FindSet[Users].FindSet[${Me.Name}]}]
	User:AddSet[ReverseFilters]
	User:Import["${Script.CurrentDirectory}/Character Config/${Me.Name}_Settings.xml"]
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${Script.CurrentDirectory}/UI/EQ2Track.xml"

	if ${Args.Used}
	{
		TrackInterface:LoadListByName[${Args.Expand}]
	}

/*	variable bool TrackAggro
	;variable string ReverseFilter[20]
	variable string ReverseFilter
	variable int NumReverseFilters
	variable int LevelMin
	variable int LevelMax
	variable int SortMethod=1
	variable bool ReverseSort=FALSE
*/
	
		
	TrackAggro:Set[${User.FindSetting[TrackAggro,FALSE]}]
	LevelMin:Set[${User.FindSetting[LevelMin,0]}]
	LevelMax:Set[${User.FindSetting[LevelMax,90]}]
	SortMethod:Set[${User.FindSetting[SortMethod,1]}]
	ReverseSort:Set[${User.FindSetting[ReverseSort,FALSE]}]

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
	UpdateSettings
	if ${Tracking}
		return
	Tracking:Set[TRUE]
	variable int tcount

	UIElement[TrackItems@EQ2 Track]:ClearItems
	EQ2:CreateCustomActorArray
	tcount:Set[${EQ2.CustomActorArraySize}]
	do
	{
		itemInfo:Set[${CustomActor[${tcount}].Level} (${CustomActor[${tcount}].Type}) ${CustomActor[${tcount}].Name} ${CustomActor[${tcount}].Class} ${CustomActor[${tcount}].Distance.Centi}]
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

atom(script) EQ2_ActorSpawned(string ID, string Name, string Level, string ActorType)
{
	itemInfo:Set[${Level} (${ActorType}) ${Name} ${Actor[${ID}].Class} ${Actor[${ID}].Distance.Centi}]

	; check our filters.
	if ${Tracker.CheckFilter[${ID}]}
		UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo},${ID}]:Sort[TrackSort]
	; if this actor matches our filters, add it to the tracking window
	
}

atom(script) EQ2_ActorDespawned(string ID, string Name)
{
	RemoveActorByID ${ID}
}

atom(script) RemoveActorByID(int ID)
{
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

}

