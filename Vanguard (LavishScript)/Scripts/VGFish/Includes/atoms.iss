;-------------------------------------------
; This is called to exit the script
;-------------------------------------------
atom(global) FishEnd()
{
	isRunning:Set[FALSE]
}

;-------------------------------------------
; Add the Fish to our UI and ObjDef: Fishes
;-------------------------------------------
atom(global) AddFishToList()
{
	;-------------------------------------------
	; Find Fish's slot or Available slot
	;-------------------------------------------
	call FindNameInFishList "${FishName}"
	if (!${Return})
	{
		call FindFirstAvailableFishSlot
		if (!${Return})
		{
			;nothing available!
			return 0
		}
	}

	;-------------------------------------------
	; Remove entry from FishListBox
	;-------------------------------------------
	variable int i
	i:Set[1]
	do
	{
		if ${UIElement[FishListBox@Combo@FishTabs@Fishing].Item[${i}].Text.Equal[${FishName}]}
		{
			UIElement[FishListBox@Combo@FishTabs@Fishing]:RemoveItem[${i}]
			break
		}
		i:Inc
	}
	while (${UIElement[FishListBox@Combo@FishTabs@Fishing].Item[${i}](exists)})

	;-------------------------------------------
	; Add entry to FishListBox
	;-------------------------------------------
	UIElement[FishListBox@Combo@FishTabs@Fishing]:AddItem[${FishName}]

	;-------------------------------------------
	; Store entry into our ObjDef: Fishes
	;-------------------------------------------
	Fishes[${Return}].Name:Set[${FishName}]
	Fishes[${Return}].Combo1:Set[${Combo1}]
	Fishes[${Return}].Combo2:Set[${Combo2}]
	Fishes[${Return}].Combo3:Set[${Combo3}]
	Fishes[${Return}].Combo4:Set[${Combo4}]
}

;-------------------------------------------
; remove the Fish from our UI and ObjDef: Fishes
;-------------------------------------------
atom(global) RemoveFishFromList()
{
	;-------------------------------------------
	; Clear entry in our ObjDef: Fishes
	;-------------------------------------------
	variable int i
	i:Set[1]
	do
	{
		if (${Fishes[${i}].Name.Equal[${UIElement[FishListBox@Combo@FishTabs@Fishing].SelectedItem}]})
		{
			Fishes[${i}]:Clear
			break
		}
		i:Inc
	}
	while (${i} < 51)

	;-------------------------------------------
	; Remove entry from FishListBox
	;-------------------------------------------
	i:Set[1]
	if (${UIElement[FishListBox@Combo@FishTabs@Fishing].Items} == 1)
	{
		UIElement[FishListBox@Combo@FishTabs@Fishing]:ClearItems
	}
	else
	{
		do
		{
			if ${UIElement[FishListBox@Combo@FishTabs@Fishing].Item[${i}].Text.Equal[${UIElement[FishListBox@Combo@FishTabs@Fishing].SelectedItem}]}
			{
				UIElement[FishListBox@Combo@FishTabs@Fishing]:RemoveItem[${i}]
				break
			}
			i:Inc
		}
		while (${UIElement[FishListBox@Combo@FishTabs@Fishing].Item[${i}](exists)})
	}
}

;-------------------------------------------
; Clear all entries in both UI and ObjDef: Fishes
;-------------------------------------------
atom(global) ClearFishList()
{
	;-------------------------------------------
	; Clear all slots in our ObjDef: Fishes
	;-------------------------------------------
	variable int i
	i:Set[1]
	do
	{
		Fishes[${i}]:Clear
		i:Inc
	}
	while (${i} < 51)

	;-------------------------------------------
	; Clear entries in our FishListBox
	;-------------------------------------------
	UIElement[FishListBox@Combo@FishTabs@Fishing]:ClearItems
}

;-------------------------------------------
; Update Combo data everytime a fish is selected in our FishlistBox
;-------------------------------------------
atom(global) UpdateInput()
{
	;-------------------------------------------
	; This is called every time a fish is selected in our FishListBox
	;-------------------------------------------
	if (${UIElement[FishListBox@Combo@FishTabs@Fishing].SelectedItem(exists)})
	{
		call FindNameInFishList "${UIElement[FishListBox@Combo@FishTabs@Fishing].SelectedItem}"
		;-------------------------------------------
		; Update our input variables
		;-------------------------------------------
		FishName:Set[${Fishes[${Return}].Name}]
		Combo1:Set[${Fishes[${Return}].Combo1}]
		Combo2:Set[${Fishes[${Return}].Combo2}]
		Combo3:Set[${Fishes[${Return}].Combo3}]
		Combo4:Set[${Fishes[${Return}].Combo4}]
		Combo:Set[${Combo1}${Combo2}${Combo3}${Combo4}]

		;-------------------------------------------
		; Update our input display in UI
		;-------------------------------------------
		UIElement[FishName@Combo@FishTabs@Fishing]:SetText[${Fishes[${Return}].Name}]
		UIElement[Combo1@Combo@FishTabs@Fishing]:SetText[${Fishes[${Return}].Combo1}]
		UIElement[Combo2@Combo@FishTabs@Fishing]:SetText[${Fishes[${Return}].Combo2}]
		UIElement[Combo3@Combo@FishTabs@Fishing]:SetText[${Fishes[${Return}].Combo3}]
		UIElement[Combo4@Combo@FishTabs@Fishing]:SetText[${Fishes[${Return}].Combo4}]
	}
}

;-------------------------------------------
; Save our log to FName-log.txt
;-------------------------------------------
atom(global) savelog()
{
	;-------------------------------------------
	; Dumps the Log to FName.txt
	;-------------------------------------------
	variable int i
	i:Set[1]
	if (${UIElement[DebugListBox@Logs@FishTabs@Fishing].Items} > 0)
	{
		actionlog "Log saved to ${Me.FName}-Log.txt"
		actionlog "------------------------------------"
		do
		{
			Redirect -append "${LavishScript.CurrentDirectory}/scripts/Fishing/Save/${Me.FName}-Log.txt" echo "${UIElement[DebugListBox@Logs@FishTabs@Fishing].Item[${i}]}"
			i:Inc
		}
		while (${UIElement[DebugListBox@Logs@FishTabs@Fishing].Item[${i}](exists)})
	}
	;-------------------------------------------
	; Clear the log
	;-------------------------------------------
	clearlog
}
;-------------------------------------------
; Clear our DebugListBox - MMOAddict
;-------------------------------------------
atom(global) clearlog()
{
	UIElement[DebugListBox@Logs@FishTabs@Fishing]:ClearItems
	UIElement[DebugListBox@Logs@FishTabs@Fishing]:AddItem[" "]
}

;-------------------------------------------
; Add action info to our log - MMOAddict
;-------------------------------------------
atom(global) actionlog(string aText)
{
	UIElement[DebugListBox@Logs@FishTabs@Fishing]:AddItem[${Time} -- ${aText}]
}

;-------------------------------------------
; Add action info to our log - Zandros
;-------------------------------------------
atom(global) movelog(string aText)
{
	if ${DoLogFishMovement}
	{
		UIElement[DebugListBox@Logs@FishTabs@Fishing]:AddItem[${Time} -- ${aText}]
	}
}

;-------------------------------------------
; Add debug info to our log - MMOAddict
;-------------------------------------------
atom(global) debuglog(string aText)
{
	if ${DoDebug}
	{
		UIElement[DebugListBox@Logs@FishTabs@Fishing]:AddItem[${Time} -- ${aText}]
	}
}

