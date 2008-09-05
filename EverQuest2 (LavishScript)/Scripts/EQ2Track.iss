
;-----------------------------------------------------------------------------------------------
; EQ2Track.iss Version 1.0.2a Updated: 05/11/08 by Equidis
;-----------------------------------------------------------------------------------------------
; EQ2 Track Created by Equidis
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

objectdef Filters
{
	member:bool Check(int ID)
	{
		if ${UIElement[TrackAggro@EQ2 Track].Checked} && !${Actor[id,${ID}].IsAggro}
			return FALSE
		if ${UIElement[TrackMinLevel@EQ2 Track].Text.Equal[""]} || ${UIElement[TrackMaxLevel@EQ2 Track].Text.Equal[""]}
			return FALSE
		Level:Set[${Actor[id,${ID}].Level}]
		if ${Level}!=0 && ((${Level} < ${UIElement[TrackMinLevel@EQ2 Track].Text}) || (${Level} > ${UIElement[TrackMaxLevel@EQ2 Track].Text}))
			return FALSE
		if ${UIElement[TrackFilter@EQ2 Track].Text.Equal[""]}
			return TRUE
		if ${itemInfo.Find[${UIElement[TrackFilter@EQ2 Track].Text}]}
			return TRUE
		return FALSE
	}
	variable int Level
}
variable Filters Filter

function main()
{
	Event[EQ2_ActorSpawned]:AttachAtom[EQ2_ActorSpawned]
	Event[EQ2_ActorDespawned]:AttachAtom[EQ2_ActorDespawned]
	ui -reload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -reload -skin eq2skin "${LavishScript.HomeDirectory}/Scripts/EQ2Track/UI/EQ2Track.xml"
	RefreshList
	
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

atom(script) RefreshList()
{
	variable int tcount
	UIElement[TrackItems@EQ2 Track]:ClearItems
	EQ2:CreateCustomActorArray
	tcount:Set[${EQ2.CustomActorArraySize}]
	do
	{
		itemInfo:Set[${CustomActor[${tcount}].Level} (${CustomActor[${tcount}].Type}) ${CustomActor[${tcount}].Name} ${CustomActor[${tcount}].Class} ${CustomActor[${tcount}].Distance}]
		if ${Filter.Check[${CustomActor[${tcount}].ID}]}
			UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo},${CustomActor[${tcount}].ID}]
	}
	while ${tcount:Dec[1]} > 0
}

atom(script) EQ2_ActorSpawned(string ID, string Name, string Level, string ActorType)
{
	itemInfo:Set[${Level} (${ActorType}) ${Name} ${Actor[id,${ID}].Class} ${Actor[id,${ID}].Distance}]

	; check our filters.
	if ${Filter.Check[${ID}]}
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

