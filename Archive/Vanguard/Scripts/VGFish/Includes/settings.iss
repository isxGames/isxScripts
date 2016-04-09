;===================================================
;===          LoadSettings Routine              ====
;===================================================
function LoadSettings()
{
	echo "[${Time}] --> Loading VGFish Settings"

	;-------------------------------------------
	; 1st - Declare Variables
	;-------------------------------------------
	declare	setConfig		settingsetref 	script
	declare	SetCombo		settingsetref 	script
	declare	General			settingsetref 	script
	declare	itConfig		iterator		script
	declare	itCombo			iterator		script
	declare	itGeneral		iterator		script
	declare TimerRecast		int 			script 	${LavishScript.RunningTime}
	declare TimerTroll		int 			script 	${LavishScript.RunningTime}


	;-------------------------------------------
	; 2nd - Clear our LavishSettings
	;-------------------------------------------
	LavishSettings[VGFish]:Clear
	setConfig:Clear
	SetCombo:Clear
	setGeneral:Clear

	;-------------------------------------------
	; 3rd - Set our LavishSettings
	;-------------------------------------------
	LavishSettings:AddSet[VGFish]
	LavishSettings[VGFish]:AddSet[Config]
	LavishSettings[VGFish]:AddSet[Combo]
	LavishSettings[VGFish]:AddSet[General]

	;-------------------------------------------
	; 4th - Import our saved file
	;-------------------------------------------
	LavishSettings[VGFish]:Import[${LavishScript.CurrentDirectory}/scripts/VGFish/Save/${Me.FName}.xml]

	;-------------------------------------------
	; 5th - Define SetRefs
	;-------------------------------------------
	setConfig:Set[${LavishSettings[VGFish].FindSet[Config].GUID}]
	SetCombo:Set[${LavishSettings[VGFish].FindSet[Combo].GUID}]
	General:Set[${LavishSettings[VGFish].FindSet[General].GUID}]

	;-------------------------------------------
	; Clear our UI ListBoxes and ObjDef: Fishes
	;-------------------------------------------
	;ClearFishList

	;-------------------------------------------
	; Load our Settings into ObjDef: Fishes
	;-------------------------------------------
	SetCombo:GetSettingIterator[itCombo]
	if ${itCombo:First(exists)}
	{
		do
		{
			call FindFirstAvailableFishSlot
			Fishes[${Return}].Name:Set[${itCombo.Value}]
			Fishes[${Return}].Combo1:Set[${SetCombo.FindSet[${itCombo.Value}].FindSetting[Combo1].String}]
			Fishes[${Return}].Combo2:Set[${SetCombo.FindSet[${itCombo.Value}].FindSetting[Combo2].String}]
			Fishes[${Return}].Combo3:Set[${SetCombo.FindSet[${itCombo.Value}].FindSetting[Combo3].String}]
			Fishes[${Return}].Combo4:Set[${SetCombo.FindSet[${itCombo.Value}].FindSetting[Combo4].String}]
		}
		while ${itCombo:Next(exists)}
	}

	;*********************Add MMOAddict***********************
	;-------------------------------------------
	; Load our General Settings by MMOAddict
	;-------------------------------------------
	DoTriggerDistance:Set[${General.FindSetting[DoTriggerDistance,FALSE]}]
	DoFishHeading:Set[${General.FindSetting[DoFishHeading,FALSE]}]
	DoOverideDetectMove:Set[${General.FindSetting[DoOverideDetectMove,FALSE]}]
	DoFindFish:Set[${General.FindSetting[DoFindFish,FALSE]}]
	DoCastLine:Set[${General.FindSetting[DoCastLine,FALSE]}]
	DoShortenCast:Set[${General.FindSetting[DoShortenCast,TRUE]}]
	DoTrollLine:Set[${General.FindSetting[DoTrollLine,TRUE]}]
	DoReleaseNone:Set[${General.FindSetting[DoReleaseNone,TRUE]}]
	DoReleaseUnknown:Set[${General.FindSetting[DoReleaseUnknown,FALSE]}]
	DoAutoBait:Set[${General.FindSetting[DoAutoBait,FALSE]}]
	DoFishingPole:Set[${General.FindSetting[DoFishingPole,FALSE]}]
	DoDebug:Set[${General.FindSetting[DoDebug,FALSE]}]
	MinFindFish:Set[${General.FindSetting[MinFindFish,5]}]
	MaxFindFish:Set[${General.FindSetting[MaxFindFish,50]}]
	ShortenCastDelay:Set[${General.FindSetting[ShortenCastDelay,120]}]
	TrollLineTimes:Set[${General.FindSetting[TrollLineTimes,10]}]
	TrollLineWaitTime:Set[${General.FindSetting[TrollLineWaitTime,7]}]
	Bait:Set[${General.FindSetting[Bait,Boiles]}]
	ForwardMinAngle:Set[${General.FindSetting[ForwardMinAngle,0]}]
	ForwardMaxAngle:Set[${General.FindSetting[ForwardMaxAngle,0]}]
	Forward2MinAngle:Set[${General.FindSetting[Forward2MinAngle,0]}]
	Forward2MaxAngle:Set[${General.FindSetting[Forward2MaxAngle,0]}]
	BackwardMinAngle:Set[${General.FindSetting[BackwardMinAngle,0]}]
	BackwardMaxAngle:Set[${General.FindSetting[BackwardMaxAngle,0]}]
	LeftMinAngle:Set[${General.FindSetting[LeftMinAngle,0]}]
	LeftMaxAngle:Set[${General.FindSetting[LeftMaxAngle,0]}]
	RightMinAngle:Set[${General.FindSetting[RightMinAngle,0]}]
	RightMaxAngle:Set[${General.FindSetting[RightMaxAngle,0]}]
	FishMoveDistance:Set[${General.FindSetting[FishMoveDistance,2]}]
	FishingPole:Set[${General.FindSetting[FishingPole,Old Fishing Pole, Help]}]
	TriggerDistanceOveride:Set[${General.FindSetting[TriggerDistanceOveride,2]}]
	DoReleaseNone:Set[${General.FindSetting[DoReleaseNone,TRUE]}]
	DoReleaseKnown:Set[${General.FindSetting[DoReleaseKnown,FALSE]}]
	ComboSetA:Set[${General.FindSetting[ComboSetA,TRUE]}]
	ComboSetB:Set[${General.FindSetting[ComboSetB,FALSE]}]
	ComboSetC:Set[${General.FindSetting[ComboSetC,FALSE]}]
	ComboSetD:Set[${General.FindSetting[ComboSetD,FALSE]}]

	
	;*********************End MMOAddict***********************
	DoLogFishMovement:Set[${General.FindSetting[DoLogFishMovement,FALSE]}]
}

;===================================================
;===           LoadXML Routine                  ====
;===================================================
function LoadXML()
{
	;-------------------------------------------
	; Populate FishListBox
	;-------------------------------------------
	variable int i
	for (i:Set[1] ; ${i}<=50 ; i:Inc)
	{
		if !${Fishes[${i}].Name.Equal[Empty]}
		{
			UIElement[FishListBox@Combo@FishTabs@VGFish]:AddItem["${Fishes[${i}].Name}"]
		}
	}

	;-------------------------------------------
	; Populate FishingPoleComboBox and BaitComboBox - MMOAddict
	;-------------------------------------------
	variable int rCount
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		UIElement[BaitComboBox@Options@FishTabs@VGFish]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[FishingPoleComboBox@Options@FishTabs@VGFish]:AddItem[${Me.Inventory[${i}].Name}]
	}

	;-------------------------------------------
	; Select Bait - MMOAddict
	;-------------------------------------------
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[BaitComboBox@Options@FishTabs@VGFish].Items}
	{
		if ${UIElement[BaitComboBox@Options@FishTabs@VGFish].Item[${rCount}].Text.Equal[${Bait}]}
			UIElement[BaitComboBox@Options@FishTabs@VGFish]:SelectItem[${rCount}]
	}

	;-------------------------------------------
	; Select FishingPole - MMOAddict
	;-------------------------------------------
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[FishingPoleComboBox@Options@FishTabs@VGFish].Items}
	{
		if ${UIElement[FishingPoleComboBox@Options@FishTabs@VGFish].Item[${rCount}].Text.Equal[${FishingPole}]}
			UIElement[FishingPoleComboBox@Options@FishTabs@VGFish]:SelectItem[${rCount}]
	}
}


;===================================================
;===      SaveSettings Routine                  ====
;===================================================
function SaveSettings()
{
	echo "[${Time}] --> Saving Fishing Settings"

	;-------------------------------------------
	; Clear our LavishSettings
	;-------------------------------------------
	setConfig:Clear
	SetCombo:Clear
	General:Clear

	;-------------------------------------------
	; Rebuild our LavishSettings (This is what we are saving!)

	;-------------------------------------------
	;setConfig - None for now

	;setGeneral
	;*********************Add MMOAddict***********************
	General:AddSetting[DoOverideDetectMove,${DoOverideDetectMove}]
	General:AddSetting[DoFindFish,${DoFindFish}]
	General:AddSetting[DoCastLine,${DoCastLine}]
	General:AddSetting[DoShortenCast,${DoShortenCast}]
	General:AddSetting[DoTrollLine,${DoTrollLine}]
	General:AddSetting[DoFishingPole,${DoFishingPole}]
	General:AddSetting[DoReleaseUnknown,${DoReleaseUnknown}]
	General:AddSetting[DoAutoBait,${DoAutoBait}]
	General:AddSetting[DoDebug,${DoDebug}]
	General:AddSetting[MinFindFish,${MinFindFish}]
	General:AddSetting[MaxFindFish,${MaxFindFish}]
	General:AddSetting[ShortenCastDelay,${ShortenCastDelay}]
	General:AddSetting[TrollLineTimes,${TrollLineTimes}]
	General:AddSetting[TrollLineWaitTime,${TrollLineWaitTime}]
	General:AddSetting[Bait,${Bait}]
	General:AddSetting[ForwardMinAngle,${ForwardMinAngle}]
	General:AddSetting[ForwardMaxAngle,${ForwardMaxAngle}]
	General:AddSetting[Forward2MinAngle,${Forward2MinAngle}]
	General:AddSetting[Forward2MaxAngle,${Forward2MaxAngle}]
	General:AddSetting[BackwardMinAngle,${BackwardMinAngle}]
	General:AddSetting[BackwardMaxAngle,${BackwardMaxAngle}]
	General:AddSetting[LeftMinAngle,${LeftMinAngle}]
	General:AddSetting[LeftMaxAngle,${LeftMaxAngle}]
	General:AddSetting[RightMinAngle,${RightMinAngle}]
	General:AddSetting[RightMaxAngle,${RightMaxAngle}]
	General:AddSetting[FishMoveDistance,${FishMoveDistance}]
	General:AddSetting[FishingPole,${FishingPole}]
	;*********************End MMOAddict***********************
	;*********************Add BSS*****************************
	General:AddSetting[DoReleaseNone,${DoReleaseNone}]
	General:AddSetting[DoReleaseKnown,${DoReleaseKnown}]
	General:AddSetting[ComboSetA,${ComboSetA}]
	General:AddSetting[ComboSetB,${ComboSetB}]
	General:AddSetting[ComboSetC,${ComboSetC}]
	General:AddSetting[ComboSetD,${ComboSetD}]
	;*********************End BSS*****************************
	General:AddSetting[DoTriggerDistance,${DoTriggerDistance}]
	General:AddSetting[DoFishHeading,${DoFishHeading}]
	General:AddSetting[DoLogFishMovement,${DoLogFishMovement}]
	General:AddSetting[TriggerDistanceOveride,${TriggerDistanceOveride}]

	;SetCombo
	variable int i
	i:Set[1]
	do
	{
		if (!${Fishes[${i}].Name.Equal["Empty"]})
		{
			SetCombo:AddSetting[${i}, "${Fishes[${i}].Name}"]
			SetCombo:AddSet[${Fishes[${i}].Name}]
			SetCombo.FindSet[${Fishes[${i}].Name}]:AddSetting[Combo1, ${Fishes[${i}].Combo1}]
			SetCombo.FindSet[${Fishes[${i}].Name}]:AddSetting[Combo2, ${Fishes[${i}].Combo2}]
			SetCombo.FindSet[${Fishes[${i}].Name}]:AddSetting[Combo3, ${Fishes[${i}].Combo3}]
			SetCombo.FindSet[${Fishes[${i}].Name}]:AddSetting[Combo4, ${Fishes[${i}].Combo4}]
		}
		i:Inc
	}
	while (${i} < 51)

	;-------------------------------------------
	; Export our LavishSettings
	;-------------------------------------------
	LavishSettings[VGFish]:Export[${LavishScript.CurrentDirectory}/scripts/VGFish/Save/${Me.FName}.xml]
}


;===================================================
;===================================================
;===    S U B - R O U T I N E S   B E L O W     ====
;===================================================
;===================================================

;===================================================
;===      FindNameInFishList Routine            ====
;===================================================
function:int FindNameInFishList(string SearchName)
{
	;-------------------------------------------
	; If found then return slot #, 0 if none
	;-------------------------------------------
	variable int i
	i:Set[1]
	do
	{
		if ${Fishes[${i}].Name.Equal[${SearchName}]}
		{
			return ${i}
		}
		i:Inc
	}
	while (${i} < 51)
	return 0
}

;===================================================
;===   FindFirstAvailableFishSlot Routine       ====
;===================================================
function:int FindFirstAvailableFishSlot()
{
	;-------------------------------------------
	; If found then return slot #, 0 if none
	;-------------------------------------------
	variable int i
	i:Set[1]
	do
	{
		if ${Fishes[${i}].Name.Equal["Empty"]}
		{
			return ${i}
		}
		i:Inc
	}
	while (${i} < 51)
	return 0
}


