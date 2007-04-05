;-----------------------------------------------------------------------------------------------
; EQ2Harvest.iss Version 1.2.03
;
; Written by: Blazer
; Updated: 08/21/06 by Syliac
; Updated: 03/06/06 by Pygar
; Updated: 04/02/07 by Cr4zyb4rd (mostly cleanup)
;
;
; Description:
; ------------
; Automatically harvests specified nodes following a Navigational Path created with EQ2harvestpath.iss
; The Navigational file needs to consist of at least a Starting and Ending point with the labels
; defined when you run the script.

#include moveto.iss

;=====================================
;====== Keyboard Configuration =======
;=====================================
; see moveto.iss

variable EQ2HarvestBot Harvest
variable filepath NavigationPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/Navigational Paths/"
variable filepath UIPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/UI/"
variable filepath CharPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/Character Config/"
variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/Harvest Config/"
variable string World
variable string NavFile
variable string ConfigFile
variable string HarvestFile
variable string HarvestName[9]
variable string HarvestTool[9]
variable bool HarvestNode[9]
variable string NodeName[9]
variable int DestroyNode[9]
variable int MaxRoaming
variable string KeepCollectName[100]
variable int KeepCollectCount[100]
variable int KeepCollectCurrent[100]
variable int collectcount
variable int HarvestTime
variable bool TimerOn
variable int StartTimer=0
variable int HowtoQuit
variable int DestroyBatch
variable int BatchCount
variable int HarvestClose
variable bool IntruderDetect
variable int IntruderAction
variable int blacklistcount
variable string BlackList[50]
variable int friendslistcount
variable string FriendsList[50]
variable int PathIndex
variable int PathRoute
variable string NearestPoint
variable bool PathDirection
variable int NodeID
variable int NodeType
variable bool Harvesting
variable int BadNode[50]
variable int HarvestStat[9]
variable int TotalStat
variable int ImbueStat
variable int RareStat
variable bool StartHarvest=FALSE
variable bool PauseHarvest=FALSE
variable bool DestroyMeat=FALSE
variable string StartPoint
variable string FinishPoint
variable string CurrentAction="Waiting to Start..."
variable float WPX
variable float WPZ
variable int KeepResource
variable string ResourceName[40]
variable int ResourceCount[40]
variable int rescnt
variable int stackcount
variable int itotal
variable int ItemID[200]
variable int ItemCount[200]
variable int lowestcnt
variable int lowestid
variable int checklag=2000
variable int NodeDelay
variable bool stillstuck
variable int PointCount
variable int PlotDistance=10
variable float LastX
variable float LastY
variable float LastZ
variable string CurrentLabel



function main(string mode)
{
	variable bool firstpass=TRUE
	variable int tempvar
	variable string labelname

	;Script:Squelch

	Harvest:Initialise
	Harvest:InitTriggers

	World:Set[${Zone.ShortName}]
	Navigation -reset
	Navigation -load "${NavFile}"

	Harvest:LoadUI

	do
	{
		if ${Navigation.World[${Zone.ShortName}].Point[${tempvar}].Note.Equal[keypoint]}
		{
			labelname:Set[${Navigation.World[${Zone.ShortName}].Point[${tempvar}].Name}]
			if ${labelname.NotEqual[${StartPoint}]}
			{
				UIElement[Start Location@Options@EQ2Harvest Tabs@Harvest]:AddItem[${labelname}]
			}

			if ${labelname.NotEqual[${FinishPoint}]}
			{
				UIElement[Finish Location@Options@EQ2Harvest Tabs@Harvest]:AddItem[${labelname}]
			}
		}
	}
	while ${tempvar:Inc}<=${Navigation.World[${Zone.ShortName}].LastID}

	if ${mode.Equal[start]}
	{
		StartHarvest:Set[TRUE]
		PauseHarvest:Set[TRUE]
		UIElement[Start Harvest@Main@EQ2Harvest Tabs@Harvest]:SetText[Pause Harvesting]
	}

	do
	{
		waitframe
		ExecuteQueued
	}
	while !${StartHarvest}

	StartTimer:Set[${Time.Timestamp}]

	do
	{
		call CheckAggro

		NavPath:Clear
		PathIndex:Set[1]

		if ${PathRoute}==1
		{
			NearestPoint:Set[${Navigation.World[${World}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

			if ${NearestPoint.Equal[${FinishPoint}]}
			{
				NavPath "${World}" "${FinishPoint}" "${StartPoint}"
			}
			else
			{
				NavPath "${World}" "${NearestPoint}" "${FinishPoint}"
				PathDirection:Set[TRUE]
			}

			call PathingRoutine
			PathRoute:Set[4]
			continue
		}
		else
		{
			if ${firstpass}
			{
				NearestPoint:Set[${Navigation.World[${World}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

				if ${NearestPoint.Equal[${FinishPoint}]}
				{
					NavPath "${World}" "${FinishPoint}" "${StartPoint}"
				}
				else
				{
					NavPath "${World}" "${NearestPoint}" "${FinishPoint}"
					PathDirection:Set[!${PathDirection}]
				}
				call PathingRoutine
				firstpass:Set[FALSE]
			}
			else
			{
				NearestPoint:Set[${Navigation.World[${World}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
				NavPath "${World}" "${FinishPoint}" "${StartPoint}"
				PathDirection:Set[!${PathDirection}]

				call PathingRoutine
				firstpass:Set[FALSE]

				if ${PathRoute}==2
				{
					break
				}
			}
		}
	}
	while ${PathRoute}<=3

	announce "Cleaning up Inventory before exiting..." 5 4
	call checkinventory 10 "CleanUpOnExit"

	Script:End
}

function PathingRoutine()
{
	variable bool harvested

	; If we have a valid path then begin harvesting.
	if ${NavPath.Points}
	{
		do
		{
			call CheckAggro

			harvested:Set[FALSE]

			; Move to next Waypoint
			WPX:Set[${NavPath.Point[${PathIndex}].X}]
			WPZ:Set[${NavPath.Point[${PathIndex}].Z}]

			CurrentAction:Set[Moving through Nav Points...]

			call moveto ${WPX} ${WPZ} 5 1 3 1

			; Check to see if we are stuck getting to the node
			if ${Return.Equal[STUCK]}
			{
				call StuckState
				continue
			}

			do
			{
				call CheckAggro

				Harvesting:Set[FALSE]
				NodeID:Set[${Harvest.Node}]

				if ${NodeID}
				{
					CurrentAction:Set[Found Node ${Actor[${NodeID}].Name}]
					Harvesting:Set[TRUE]
					if ${IntruderAction} && ${IntruderStatus}==1 && ${IntruderDetect}
					{
						call AvoidAction
					}
					else
					{
						if !${Harvest.PCDetected}
						{
							call moveto ${Actor[${NodeID}].X} ${Actor[${NodeID}].Z} 5 0 3 1

							; Check to see if we are stuck getting to the node
							if ${Return.Equal[STUCK]}
							{
								Harvest:SetBadNode[${NodeID}]
								call StuckState
								continue
							}

							while ${Me.IsMoving}
							{
								waitframe
							}
							; even with the above it still jumps the gun every so often...lag?
							wait 1

							call Harvest
							harvested:Set[TRUE]

							if !${IntruderAction} && ${IntruderStatus}==1 && ${IntruderDetect}
							{
								isintruder:Set[TRUE]
								do
								{
									call CheckAggro
									call AvoidAction
									call checkkeys
								}
								while ${isintruder}

								if ${Me.ToActor.IsAFK}
								{
									EQ2Execute /afk
									wait 10
								}
							}
						}
					}
				}
			}
			while ${Harvesting}

			if ${harvested}
			{
				echo moving to closest waypoint
				NavPath:Clear
				NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
				if ${PathDirection}
				{
					if ${NearestPoint.Equal[${FinishPoint}]}
					{
						NavPath "${World}" "${FinishPoint}" "${StartPoint}"
					}
					else
					{
						NavPath "${World}" "${NearestPoint}" "${FinishPoint}"
					}
				}
				else
				{
					if ${NearestPoint.Equal[${StartPoint}]}
					{
						NavPath "${World}" "${StartPoint}" "${FinishPoint}"
					}
					else
					{
						NavPath "${World}" "${NearestPoint}" "${StartPoint}"
					}
				}
				PathIndex:Set[0]
			}
		}
		while ${PathIndex:Inc}<=${NavPath.Points}
	}
	else
	{
		EQ2Echo There was no valid path found!
		EQ2Echo Check ${NavFile} that it includes a Start and Finish point.

		Script:End
	}
}

function CheckAggro()
{
	;Stop Moving and pause if we have aggro
	if ${MobAggro.Detect}
	{
		CurrentAction:Set[Aggro Detected Pausing...]
		;if ${Me.IsMoving}
		;{
		;	CurrentAction:Set[Halting Movement...]
		;	call StopRunning
		;}

		CurrentAction:Set[Waiting till aggro gone, and over 90 health...]
		do
		{
			wait 30
		}
		while ${MobAggro.Detect} || ${Me.ToActor.Health}<90

		CurrentAction:Set[Checking For Loot...]

		EQ2:CreateCustomActorArray[byDist,15]

		if ${CustomActor[chest,radius,15](exists)} || ${CustomActor[corpse,radius,15](exists)}
		{
			CurrentAction:Set[Loot nearby waiting 5 seconds...]
			wait 50
		}
		CurrentAction:Set[Resuming Harvest...]
		;Not sure we should resume movement here, but figure more movement is better
		call StartRunning
	}
}

function StuckState()
{
	stillstuck:Set[TRUE]
	CurrentAction:Set[We are stuck...]
	NavPath:Clear

	; Re-create the nav path and move to the nearest navpoint
	NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

	if ${PathDirection}
	{
		NavPath "${World}" "${NearestPoint}" "${FinishPoint}"
	}
	else
	{
		NavPath "${World}" "${NearestPoint}" "${StartPoint}"
	}

	WPX:Set[${NavPath.Point[1].X}]
	WPZ:Set[${NavPath.Point[1].Z}]
	call moveto ${WPX} ${WPZ} 5 1 3 1

	; Are we still Stuck?
	if ${Return.Equal[STUCK]}
	{
		; Looks like we are stuck again. end script...
		EQ2Echo We are stuck! Ending script...
		if ${HowtoQuit}
		{
			timed 100 EQ2Execute /camp desktop
		}

		announce "Cleaning up Inventory before exiting..." 5 4
		;call checkinventory 10 "CleanUpOnExit"

		Script:End
	}
	else
	{
		PathIndex:Set[1]
	}
	stillstuck:Set[FALSE]
}


function checkkeys()
{
	if "${checkend(bool)}"
	{
		announce "Cleaning up Inventory before exiting..." 5 4
		call checkinventory 10 "CleanUpOnExit"

		Script:End
	}

	if "${Math.Calc[${Time.Timestamp}-${timer}]}>${Math.Calc[${timerval}*60]} && ${timerval}"
	{
		wait 20
		if ${howtoquit}
		{
			timed 100 EQ2Execute /camp desktop
		}

		announce "Cleaning up Inventory before exiting..." 5 4
		call checkinventory 10 "CleanUpOnExit"

		Script:End
	}
}

function InvalidNode(string Line)
{
	; This node is not harvestable so label it bad
	badnodedetected:Set[1]
}

function InventoryFull(string Line)
{
	; End the script since we have no more room to harvest
	EQ2Echo Ending script because our Inventory is FULL!!
	wait 20
	if ${HowtoQuit}
	{
		timed 100 EQ2Execute /camp desktop
	}

	announce "Cleaning up Inventory before exiting..." 5 4
	call checkinventory 10 "CleanUpOnExit"

	Script:End
}

function GMDetected(string Line)
{
	; Close the InnerSpace session completely!
	EQ2Echo ${Line} > GMDetected.txt
	wait 50
	Exit
}

function ProcessTriggers()
{
	if !${StartHarvest}
	{
		CurrentAction:Set[Waiting to Resume...]
		while !${StartHarvest}
		{
			waitframe
		}
	}
	if ${QueuedCommands}
	{
		do
		{
			ExecuteQueued
		}
		while ${QueuedCommands}
	}
}

function Harvest()
{
	variable int delay
	variable int savetime
	variable int waittime

	;intrcheck:Set[0]

	target ${NodeID}
	wait 5 ${Target.ID}==${NodeID}

	;call SwapEnhancer "${HarvestTool[${closestCount}]}"

	do
	{
		call CheckAggro
		CurrentAction:Set[Harvesting ${Actor[${NodeID}].Name}]

		if ${HarvestTool[${NodeType}].Equal["Trapping"]}
			{
			Me.Inventory[Sandalwood Trap]:Equip
			}
		if ${HarvestTool[${NodeType}].Equal["Mining"]}
			{
			Me.Inventory[Sandalwood Pick]:Equip
			}
		if ${HarvestTool[${NodeType}].Equal["Gathering"]}
			{
			Me.Inventory[Sandalwood Shovel]:Equip
			}
		if ${HarvestTool[${NodeType}].Equal["Foresting"]}
			{
			; Shears seem to stack with saw (but not shovel) but we have to have both slots free
			; for auto-equip to work.
			Me.Equipment[Sandalwood Pick]:UnEquip
			Me.Equipment[Sandalwood Shovel]:UnEquip
			Me.Equipment[Sandalwood Trap]:UnEquip
			Me.Inventory[Sandalwood Saw]:Equip
			Me.Inventory[Miscalibrated Automated Shears]:Equip
			}
		if ${HarvestTool[${NodeType}].Equal["Fishing"]}
			{
			Me.Inventory[Sandalwood Fishing Pole]:Equip
			}

		EQ2Execute /useability ${HarvestTool[${NodeType}]}

		WaitFor "Too far away" "Interrupted!" "Can't see target" "You cannot @*@" 30

		if ${WaitFor}
		{
			Harvest:SetBadNode[${NodeID}]
			return
		}

		call ProcessTriggers

		wait 50 !${Me.CastingSpell}
		wait 5

		if !${intrcheck} && ${intrdetect}
		{
			call CheckIntruder
			intrcheck:Set[1]
		}

		call ProcessTriggers
	}
	while ${Target.ID}==${NodeID}

	if ${NodeDelay}
	{
		delay:Set[${Math.Rand[${NodeDelay}]}]
		savetime:Set[${Time.Timestamp}]
		do
		{
			call CheckAggro
			waittime:Set[${Math.Calc[(${delay}+${savetime})-${Time.Timestamp}]}]
			CurrentAction:Set[Waiting ${waittime} seconds for Random delay]
			wait 5
		}
		while ${waittime}
	}
}

function CheckInventory(string destroyname, int number)
{
	variable int tempvar
	variable int totalitemdest
	variable int tempvar2
	variable int slotchk
	variable int contchk
	variable int brkcnt

	if ${destroyname.NotEqual[CleanUpOnExit]}
	{
		Harvest:AddItem[${destroyname},${number}]
	}

	if ${BatchCount}>=${DestroyBatch} || ${destroyname.Equal[CleanUpOnExit]}
	{
		if ${destroyname.NotEqual[CleanUpOnExit]}
		{
			CurrentAction:Set[Cleaning up Inventory...]
		}

		wait 20
		tempvar:Set[1]
		do
		{
			Me:CreateCustomInventoryArray[nonbankonly]
			wait 5
			Harvest:SearchInventory[${ResourceName[${tempvar}]}]
			totalitemdest:Set[${Math.Calc[${itotal}-${ResourceCount[${tempvar}]}]}]

			if ${totalitemdest}>0
			{
				do
				{
					Harvest:FindLowest
					if ${lowestcnt}<=${totalitemdest}
					{
						if ${ItemID[${lowestid}]}
						{
							Me.CustomInventory[${ItemID[${lowestid}]}]:Destroy
							wait 4
							totalitemdest:Dec[${lowestcnt}]
							ItemCount[${lowestid}]:Set[0]
						}
					}
					else
					{
						slotchk:Set[${Me.CustomInventory[${ItemID[${lowestid}]}].Slot}]
						contchk:Set[${Me.CustomInventory[${ItemID[${lowestid}]}].InContainerID}]
						brkcnt:Set[1]
						Me.CustomInventory[${ItemID[${lowestid}]}]:Move[NextFreeNonBank,${totalitemdest}]
						do
						{
							wait 2
							Me:CreateCustomInventoryArray[nonbankonly]
							if ${brkcnt:Inc}>20
							{
								brkcnt:Set[0]
								EQ2Echo Unable to move a Resource: ${Me.CustomInventory[${tempvar}].Name}\n >> HarvestError.txt
								break
							}
						}
						while ${Me.CustomInventory[${tempvar}].Slot}==${slotchk} && ${Me.CustomInventory[${tempvar}].InContainerID}==${contchk}

						tempvar2:Set[1]
						if ${brkcnt}
						{
							do
							{
								if ${Me.CustomInventory[${tempvar2}].Name.Equal[${ResourceName[${tempvar}]}]} && ${Me.CustomInventory[${tempvar2}].Quantity}==${totalitemdest}
								{
									wait 2
									Me.CustomInventory[${tempvar2}]:Destroy
									wait 4
									break
								}
							}
							while ${tempvar2:Inc}<=${Me.CustomInventoryArraySize}
							break
						}
					}
				}
				while ${totalitemdest}>0
			}
		}
		while ${tempvar:Inc}<=${rescnt}

		BatchCount:Set[0]
		rescnt:Set[0]
	}
}

function DestroyItem(string destroyname)
{
	variable int slotchk
	variable int contchk
	variable int brkcnt
	variable int tempvar
	variable int tempvar2
	echo need to detroy item
	wait 20
	tempvar:Set[1]
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 4
	do
	{
		if ${Me.CustomInventory[${tempvar}].Name.Equal[${destroyname}]}
		{
			slotchk:Set[${Me.CustomInventory[${tempvar}].Slot}]
			contchk:Set[${Me.CustomInventory[${tempvar}].InContainerID}]
			brkcnt:Set[1]
			tempvar2:Set[1]
			Me.CustomInventory[${tempvar}]:Move[NextFreeNonBank,1]
			do
			{
				wait 4
				Me:CreateCustomInventoryArray[nonbankonly]
				wait 4
				if ${brkcnt:Inc}>20
				{
					brkcnt:Set[0]
					EQ2Echo Unable to move a Collect: ${Me.CustomInventory[${tempvar}].Name}\n >> HarvestError.txt
					return
				}
			}
			while ${Me.CustomInventory[${tempvar}].Slot}==${slotchk} && ${Me.CustomInventory[${tempvar}].InContainerID}==${contchk}

			do
			{
				if ${Me.CustomInventory[${tempvar2}].Name.Equal[${destroyname}]} && ${Me.CustomInventory[${tempvar2}].Quantity}==1
				{
					wait 2
					Me.CustomInventory[${tempvar2}]:Destroy
					return
				}
			}
			while ${tempvar2:Inc}<=${Me.CustomInventoryArraySize}
		}
	}
	while ${tempvar:Inc}<=${Me.CustomInventoryArraySize}
}

function InitHarvestEnhancer()
{
	variable int TempEnhance1=0
	variable int TempEnhance2=1
	variable int TempEnhance3
	Me:CreateCustomInventoryArray[nonbankonly]
	OriginalCharm:Set[${Me.Equipment[19].ID}]

	if ${Me.Level} == 70
		TempEnhance3:Set[69]
	else
		TempEnhance3:Set[${Me.Level}]

	Do
	{
		Do
		{
			If ${Me.CustomInventory[${SettingXML[${harvestfile}].Set[Harvest Enhancer].GetString["${TempEnhance1},${TempEnhance2}"]}](exists)}
				HarvestEnhancer[${TempEnhance2}]:Set[${SettingXML[${harvestfile}].Set[Harvest Enhancer].GetString["${TempEnhance1},${TempEnhance2}"]}]
			elseif !${HarvestEnhancer[${TempEnhance2}].Length}
				HarvestEnhancer[${TempEnhance2}]:Set[NULL]
		}
		while ${TempEnhance2:Inc} <= 5

		TempEnhance2:Set[1]

	}
	while ${TempEnhance1:Inc} <= ${Math.Calc[${TempEnhance3}/10].Int}

	TempEnhance2:Set[1]
	do
	{
		if ${HarvestEnhancer[${TempEnhance2}](exists)}
		{
			UsedEnhancer:Set[TRUE]
			echo ${HarvestEnhancer[${TempEnhance2}]}
		}
	}
	while ${TempEnhance2:Inc} <= 5

}

function UpdateKeep(int keep)
{
	if ${DestroyNode[${keep}]}
	{
		InputBox "How many ${HarvestName[${keep}]} do you want to Keep?" ${DestroyNode[${keep}]}
	}
	else
	{
		InputBox "How many ${HarvestName[${keep}]} do you want to Keep?"
	}

	DestroyNode[${keep}]:Set[${UserInput}]
	SettingXML[${ConfigFile}].Set[Keep how many resources from each node?]:Set[${HarvestName[${keep}]},${DestroyNode[${keep}]}]
	SettingXML[${ConfigFile}]:Save

	if ${DestroyNode[${keep}]}
	{
		UIElement[${HarvestName[${keep}]} Status@Main@EQ2Harvest Tabs@Harvest]:SetText[(Keep: ${DestroyNode[${keep}]})]
	}
	else
	{
		UIElement[${HarvestName[${node}]} Status@Main@EQ2Harvest Tabs@Harvest]:SetText[(Destroy: All)]
	}
}

function Harvested(string Line, string action, int number, string result)
{
	HarvestStat[${NodeType}]:Inc[${number}]

	if ${NodeType}<=7
	{
		TotalStat:Inc[${number}]
		BatchCount:Inc[${number}]
		call CheckInventory "${result}" ${number}
	}
}

objectdef EQ2HarvestBot
{
	method Initialise()
	{
		variable int tempvar

		NavFile:Set[${NavigationPath}${Zone.ShortName}.xml]
		ConfigFile:Set[${CharPath}${Me.Name}.xml]
		HarvestFile:Set[${ConfigPath}Harvest.xml]

		HarvestName[1]:Set[Ore]
		HarvestName[2]:Set[Stone]
		HarvestName[3]:Set[Wood]
		HarvestName[4]:Set[Roots]
		HarvestName[5]:Set[Pelts]
		HarvestName[6]:Set[Shrubs]
		HarvestName[7]:Set[Fish]
		HarvestName[8]:Set[Collectibles(?)]
		HarvestName[9]:Set[Collectibles(!)]

		HarvestTool[1]:Set[Mining]
		HarvestTool[2]:Set[Mining]
		HarvestTool[3]:Set[Foresting]
		HarvestTool[4]:Set[Gathering]
		HarvestTool[5]:Set[Trapping]
		HarvestTool[6]:Set[Gathering]
		HarvestTool[7]:Set[Fishing]
		HarvestTool[8]:Set[Collecting]
		HarvestTool[9]:Set[Collecting]

		tempvar:Set[1]
		do
		{
			HarvestNode[${tempvar}]:Set[${SettingXML[${ConfigFile}].Set[What Nodes to Harvest?].GetString[${HarvestName[${tempvar}]},TRUE]}]
		}
		while ${tempvar:Inc}<=9

		tempvar:Set[1]
		do
		{
			NodeName[${tempvar}]:Set[${SettingXML[${HarvestFile}].Set[${Zone.ShortName}].GetString[${tempvar}]}]
		}
		while ${tempvar:Inc}<=7

		NodeName[8]:Set[?]
		NodeName[9]:Set[!]

		tempvar:Set[1]
		do
		{
			DestroyNode[${tempvar}]:Set[${SettingXML[${ConfigFile}].Set[Keep how many resources from each node?].GetInt[${HarvestName[${tempvar}]},500]}]
		}
		while ${tempvar:Inc}<=9

		collectcount:Set[${SettingXML[${ConfigFile}].Set[COLLECTIBLE name you want to keep and how many].Keys}]

		tempvar:Set[1]
		do
		{
			KeepCollectName[${tempvar}]:Set[${SettingXML[${ConfigFile}].Set[COLLECTIBLE name you want to keep and how many].Key[${tempvar}]}]
			KeepCollectCount[${tempvar}]:Set[${SettingXML[${ConfigFile}].Set[COLLECTIBLE name you want to keep and how many].GetInt[${KeepCollectName[${tempvar}]}]}]
		}
		while ${tempvar:Inc}<=${collectcount}

		;Pathroute is defined as follows
		;1 - Navigational path from the nearest point to the End Point.
		;2 - Navigational path from the nearest point to the End Point and back to the Start Point.
		;3 - Navigational path from the nearest point and then loops to the End Point and back to the Start Point.
		PathRoute:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetInt["Pathing Route (1=1 way, 2=To and Back, 3=Continous loop",3]}]

		HarvestTime:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetInt[Harvest Timer,120]}]
		TimerOn:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetString[Is Harvest Timer On?,FALSE]}]
		HowtoQuit:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetInt[0-end script or 1-Camp to desktop,1]}]
		DestroyBatch:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetInt[Nodes to Harvest before Destroying?,200]}]
		IntruderDetect:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetString[Do you want to detect for BOT POLICE following YOU?,FALSE]}]
		IntruderAction:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetInt[If intruder detected - Stand there (0) or (1) keep moving till he goes?,1]}]
		NodeDelay:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetInt[Maximum Random Delay between Nodes?,0]}]
		DestroyMeat:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetString[Destroy All Meat?,FALSE]}]
		blacklistcount:Set[${SettingXML[${ConfigFile}].Set[Bot Police Detection - BLACK LIST].Keys}]

		tempvar:Set[1]
		do
		{
			BlackList[${tempvar}]:Set[${SettingXML[${ConfigFile}].Set[Bot Police Detection - BLACK LIST].GetString[${tempvar}]}]
		}
		while "${tempvar:Inc}<=${blacklistcount}"

		friendslistcount:Set[${SettingXML[${ConfigFile}].Set[Bot Police Detection - FRIENDS LIST].Keys}]

		tempvar:Set[1]
		do
		{
			FriendsList[${tempvar}]:Set[${SettingXML[${ConfigFile}].Set[Bot Police Detection - FRIENDS LIST].GetString[${tempvar}]}]
		}
		while "${tempvar:Inc}<=${friendslistcount}"

		MaxRoaming:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetInt[Roaming Value,80]}]
		HarvestClose:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetInt[Distance for the bot to move outside the max roaming range?,15]}]
		StartPoint:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetString[Starting Point,Start]}]
		FinishPoint:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetString[Finishing Point,Finish]}]

		SettingXML[${ConfigFile}]:Save

		; Check Weight in case we are moving to slow
		if ${Math.Calc[${Me.Weight}/${Me.MaxWeight}*100]}>150
		{
			checklag:Set[2]
		}
	}

	method InitTriggers()
	{
		; Add our trigger for nodes that are too far away or cannot harvest from.
		AddTrigger InvalidNode "@*@You cannot@*@"

		; Add trigger for inventory full
		AddTrigger InventoryFull "@*@inventory is currently full."

		; Add GM/CS TELL triggers
		;AddTrigger GMDetected "@*@GM.@*@tells you@*@"
		;AddTrigger GMDetected "@*@CS.@*@tells you@*@"
		;AddTrigger GMDetected "\\aPC @*@ @*@:@sender@\\/a tells you@*@GM@*@"

		; Add Harvest triggers
		AddTrigger Harvested "Announcement::You have @action@:\n@number@ @result@"
		AddTrigger Harvest:Rare "Announcement::Rare item found!\n@rare@"
		AddTrigger Harvest:Collectible "Announcement::Collectible found!\n@result@"
	}

	method LoadUI()
	{
		ui -reload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
		ui -reload "${UIPath}HarvestGUI.xml"
	}

	member:int Node()
	{
		variable int tempvar
		variable int tcount=1
		variable int nodecnt

		tempvar:Set[1]
		EQ2:CreateCustomActorArray[byDist]

		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
		{
			tempvar:Set[0]
			while ${tempvar:Inc}<=9
			{
				if ${CustomActor[${tcount}].Name.Equal[${NodeName[${tempvar}]}]} && ${CustomActor[${tcount}].Type.Equal[resource]} && ${HarvestNode[${tempvar}]}
				{
					; Check Distance and Roaming Distance is within range.
					if ${Math.Distance[${CustomActor[${tcount}].X},${CustomActor[${tcount}].Z},${WPX},${WPZ}]}<${MaxRoaming} || ${Math.Distance[${CustomActor[${tcount}].X},${CustomActor[${tcount}].Z},${Me.X},${Me.Z}]}<${HarvestClose}
					{
						; Check if its not a Bad Node
						nodecnt:Set[0]
						while ${nodecnt:Inc}<=50
						{
							if !${BadNode[${nodecnt}]}
							{
								NodeType:Set[${tempvar}]
								return ${CustomActor[${tcount}].ID}
							}

							if ${CustomActor[${tcount}].ID}==${BadNode[${nodecnt}]}
							{
								break
							}
						}

					}
				}
			}
		}
		return 0
	}

	member:bool PCDetected()
	{
		variable int tcount=1

		EQ2:CreateCustomActorArray[byDist]

		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
		{
			if ${CustomActor[${tcount}].Type.Equal[PC]}
			{
				if ${Math.Distance[${CustomActor[${tcount}].X},${CustomActor[${tcount}].Z},${Actor[${NodeID}].X},${Actor[${NodeID}].Z}]}<20
				{
					This:SetBadNode[${NodeID}]
					return TRUE
				}
			}
		}

		return FALSE
	}

	method SetBadNode(string badnodeid)
	{
		variable int tempvar

		if !${BadNode[50]}
		{
			while ${tempvar:Inc}<=50
			{
				if !${BadNode[${tempvar}]}
				{
					BadNode[${tempvar}]:Set[${badnodeid}]
					return
				}
			}
		}
		else
		{
			while ${tempvar:Inc}<=50
			{
				BadNode[${tempvar}]:Set[0]
			}
		}

		BadNode[1]:Set[${badnodeid}]
	}

	method Rare(string Line, string rare)
	{
		if ${rare.Find[Glowing]} || ${rare.Find[Sparkling]} || ${rare.Find[Glimmering]} || ${rare.Find[Luminous]} || ${rare.Find[Lambent]} || ${rare.Find[Scintillating]}
		{
			ImbueStat:Inc
		}
		else
		{
			RareStat:Inc
		}
	}

method Collectible(string Line, string result)
{
	variable int tempvar

	tempvar:Set[${This.SearchItems[${result}]}]

	if ${tempvar}
	{
		if ${KeepCollectCurrent[${tempvar}]}<${KeepCollectCount[${tempvar}]}
		{
			HarvestStat[${NodeType}]:Inc
			KeepCollectCurrent[${tempvar}]:Inc

			if ${HarvestStat[${NodeType}]}>=${DestroyNode[${NodeType}]} && ${DestroyNode[${NodeType}]}
			{
				HarvestNode[${NodeType}]:Set[FALSE]
			}
		}
		else
		{
			call DestroyItem "${result}"
		}
	}
	else
	{
		if !${DestroyNode[${NodeType}]}
		{
			call DestroyItem "${result}"
		}
		else
		{
			HarvestStat[${NodeType}]:Inc
			if ${HarvestStat[${NodeType}]}>=${DestroyNode[${NodeType}]} && ${DestroyNode[${NodeType}]}
			{
				HarvestNode[${NodeType}]:Set[FALSE]
			}
		}
	}
}

	method SearchItems(string itemsearch)
	{
		variable int tempvar

		while ${tempvar:Inc}<=${collectcount}
		{
			if ${itemsearch.Find[${KeepCollectName[${tempvar}]}]}
			{
				return ${tempvar}
			}
		}
		return 0
	}

	method UpdateDestroy(int destroy)
	{
		DestroyNode[${destroy}]:Set[0]
		SettingXML[${ConfigFile}].Set[Keep how many resources from each node?]:Set[${HarvestName[${destroy}]},0]
		SettingXML[${ConfigFile}]:Save
		UIElement[${HarvestName[${destroy}]} Status@Main@EQ2Harvest Tabs@Harvest]:SetText[(Destroy: All)]
	}

	method CheckStatus(int node)
	{
		if ${DestroyNode[${node}]}
		{
			UIElement[${HarvestName[${node}]} Status@Main@EQ2Harvest Tabs@Harvest]:SetText[(Keep: ${DestroyNode[${node}]})]
		}
		else
		{
			UIElement[${HarvestName[${node}]} Status@Main@EQ2Harvest Tabs@Harvest]:SetText[(Destroy: All)]
		}
	}

	method AddItem(string itemname,int quantity)
	{
		variable int tempvar

		KeepResource:Set[${SettingXML[${ConfigFile}].Set[RESOURCE name you want to keep and how many].GetInt[${itemname}]}]

		tempvar:Set[1]
		do
		{
			if ${itemname.Equal[${ResourceName[${tempvar}]}]}
			{
				return
			}
		}
		while ${tempvar:Inc}<=${rescnt}

		rescnt:Inc
		ResourceName[${rescnt}]:Set[${itemname}]
		ResourceCount[${rescnt}]:Set[${KeepResource}]

		if !${ResourceCount[${rescnt}]}
		{
			if ${DestroyMeat} && ${NodeType}==5 && ${itemname.Right[5].Equal[" meat"]}
			{
				ResourceCount[${rescnt}]:Set[0]
			}
			else
			{
				ResourceCount[${rescnt}]:Set[${DestroyNode[${NodeType}]}]
			}
		}
	}

	method SearchInventory(string itemsearch)
	{
		variable int xvar

		xvar:Set[1]
		itotal:Set[0]
		stackcount:Set[0]
		do
		{
			if ${Me.CustomInventory[${xvar}].Name.Equal[${itemsearch}]}
			{
				stackcount:Inc
				ItemID[${stackcount}]:Set[${xvar}]
				ItemCount[${stackcount}]:Set[${Me.CustomInventory[${xvar}].Quantity}]
				itotal:Inc[${Me.CustomInventory[${xvar}].Quantity}]
			}
		}
		while ${xvar:Inc}<=${Me.CustomInventoryArraySize}
	}

	method FindLowest()
	{
		variable int xvar

		lowestcnt:Set[${ItemCount[1]}]
		lowestid:Set[1]
		xvar:Set[0]
		do
		{
			if ${stackcount}>1
			{
				if ${ItemCount[${xvar}]} && ${ItemCount[${xvar}]}<=${lowestcnt}
				{
					lowestcnt:Set[${ItemCount[${xvar}]}]
					lowestid:Set[${xvar}]
				}
			}
		}
		while ${xvar:Inc}<=${stackcount}
	}
}


atom atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
	ui -unload "${UIPath}HarvestGUI.xml"

	SettingXML[${ConfigFile}]:Unload
	SettingXML[${HarvestFile}]:Unload

	press -hold MOVEBACKWARD
	wait 3
	press -release MOVEBACKWARD
}


