
;-----------------------------------------------------------------------------------------------
; EQ2Track.iss Version 2.0 Updated: 09/05/08 by Valerian
;-----------------------------------------------------------------------------------------------
; EQ2 Track originally created by Equidis
; Rewritten by Valerian
;-----------------------------------------------------------------------------------------------

; ** Additional credits to Karye & Blazer: Some of the UI & Elements & Coding
; used were taken from previous version of EQ2BotCommand **

	variable bool filtersChanged
;-------------------------------------

;-------------------------------------
; General
;-------------------------------------

	variable bool Tracking
	variable string itemInfo
	variable bool TrackAggro
	variable string ReverseFilter
	variable int LevelMin
	variable int LevelMax
	
;-------------------------------------



function zoneWait()
{
	if ${EQ2.Zoning}
	{
		filtersChanged:Set[TRUE]
		do
		{
			waitframe
		}
		while ${EQ2.Zoning}
	}
}

objectdef TrackHelper
{
	member:bool CheckFilter(int ID)
	{
		if ${TrackAggro} && !${Actor[${ID}].IsAggro}
			return FALSE
		if ${LevelMin} == -1 || ${LevelMax} == -1
			return FALSE
		Level:Set[${Actor[${ID}].Level}]
		if ${Level} < ${LevelMin} || ${Level} > ${LevelMax}
			return FALSE
		if ${ReverseFilter.Equal[""]}
			return TRUE
		if ${itemInfo.Find[${ReverseFilter}]}
			return TRUE
		return FALSE
	}
	variable int Level
	method VerifyList()
	{
		if ${UIElement[TrackItems@EQ2 Track].SelectedItem(exists)} && !${Actor[${UIElement[TrackItems@EQ2 Track].SelectedItem.Value}](exists)}
		{
			eq2execute /waypoint_cancel
			UIElement[TrackItems@EQ2 Track].SelectedItem:Remove
		}
		variable int tcount
		tcount:Set[${UIElement[TrackItems@EQ2 Track].Items}]
		do
		{
			if !${Actor[${UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}].Value}](exists)}
			{
				UIElement[TrackItems@EQ2 Track].OrderedItem[${tcount}]:Remove
			}
		}
		while ${tcount:Dec[1]} > 0
	}
}
variable TrackHelper Tracker

function main()
{
	Event[EQ2_ActorSpawned]:AttachAtom[EQ2_ActorSpawned]
	Event[EQ2_ActorDespawned]:AttachAtom[EQ2_ActorDespawned]
	ui -reload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -reload -skin eq2skin "${LavishScript.HomeDirectory}/Scripts/EQ2Track/UI/EQ2Track.xml"
	RefreshList
	call CheckListTimer
	call RefreshWaypointTimer
	
	do
	{
		if ${QueuedCommands}
			ExecuteQueued
		waitframe
		
		call zoneWait
		if ${filtersChanged}
		{
			RefreshList
			filtersChanged:Set[FALSE]
		}
	}
	while 1

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
	ReverseFilter:Set[${UIElement[TrackFilter@EQ2 Track].Text}]
	
	UIElement[TrackItems@EQ2 Track]:ClearItems
	EQ2:CreateCustomActorArray
	tcount:Set[${EQ2.CustomActorArraySize}]
	do
	{
		itemInfo:Set[${CustomActor[${tcount}].Level} (${CustomActor[${tcount}].Type}) ${CustomActor[${tcount}].Name} ${CustomActor[${tcount}].Class} ${CustomActor[${tcount}].Distance}]
		if ${Tracker.CheckFilter[${CustomActor[${tcount}].ID}]}
			UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo},${CustomActor[${tcount}].ID}]
	}
	while ${tcount:Dec[1]} > 0
}

atom(script) EQ2_ActorSpawned(string ID, string Name, string Level, string ActorType)
{
	itemInfo:Set[${Level} (${ActorType}) ${Name} ${Actor[${ID}].Class} ${Actor[${ID}].Distance}]

	; check our filters.
	if ${Tracker.CheckFilter[${ID}]}
		UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo},${ID}]
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
		if (${UIElement[TrackItems@EQ2 Track].Item[${tcount}].Value} == ${ID})
			UIElement[TrackItems@EQ2 Track].Item[${tcount}]:Remove
		tcount:Dec[1]
	}
	while ${tcount}>0
}


function atexit()
{

	ui -unload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Track/UI/EQ2Track.xml"

}

