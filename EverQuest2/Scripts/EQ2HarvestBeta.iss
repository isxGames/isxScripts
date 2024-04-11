;-----------------------------------------------------------------------------------------------
; EQ2Harvest.iss Version 2.0
;
; Written by: Blazer
; Updated: 08/21/06 by Syliac
; Updated: 03/06/06 by Pygar
; Updated: 04/16/07 by Cr4zyb4rd
; Updated  04/20/08 by Amadeus
; Updated  05/25/08 by Amadeus (v. 2.0)
;
;
; Description:
; ------------
; Automatically harvests specified nodes following a Navigational Path created with EQ2harvestpath.iss
; The Navigational file needs to consist of at least a Starting and Ending point with the labels
; defined when you run the script.

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss

variable EQ2Nav Nav
variable EQ2HarvestBot Harvest
variable filepath UIPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/UI/"
variable filepath CharPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/Character Config/"
variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/Harvest Config/"
variable string World
variable string ConfigFile
variable string HarvestFile
variable string HarvestName[9]
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
variable int FilterY
variable bool IntruderDetect
variable int IntruderAction
variable int blacklistcount
variable string BlackList[50]
variable int friendslistcount
variable string FriendsList[50]
variable int PathRoute
variable int NodeID
variable int NodeType
variable bool Harvesting
variable collection:string BadNodes
variable int HarvestStat[9]
variable int TotalStat
variable int ImbueStat
variable int RareStat
variable bool UseSprint=FALSE
variable bool StartHarvest=FALSE
variable bool PauseHarvest=FALSE
variable bool DestroyMeat=FALSE
variable string StartPoint
variable string FinishPoint
variable string CurrentAction="Waiting to Start..."
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
variable bool OnBadNode
variable string gNodeName
variable collection:string CollectiblesFound
variable collection:string LootWindowsProcessed
variable bool CheckingAggro
variable lnavregionref rStart
variable lnavregionref rFinish
variable lnavregionref NearestRegion
variable lnavregionref ZoneRegion

function main(string mode)
{
	variable bool MovingToFinish

	;Script:Squelch

	Harvest:Initialise
	Harvest:InitTriggersAndEvents

    ;;;;;;;;;;;;
	;; Load Navigation System and initialize variables
    Nav:LoadMap
    Nav.DirectMovingToTimer:Set[170]
    Nav.gPrecision:Set[5]
    Nav.SkipNavTime:Set[35]
    
    rStart:SetRegion[${StartPoint}]
    rFinish:SetRegion[${FinishPoint}]
	;;;;;;;;;;;;

	Harvest:LoadUI

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

        variable float DistToStart
        variable float DistToFinish
        DistToStart:Set[${Math.Distance[${Me.Loc},${rStart.CenterPoint}]}]
        DistToFinish:Set[${Math.Distance[${Me.Loc},${rFinish.CenterPoint}]}]
        echo "EQ2Harvest-DEBUG: DistToStart: ${DistToStart} -- DistToFinish: ${DistToFinish}"
        
		if ${PathRoute}==1
		{
		    if ${DistToStart} > ${DistToFinish}
		        call PathingRoutine ${StartPoint}
		    else
		        call PathingRoutine ${rFinish}
		    
		    break
		}
		elseif ${PathRoute} == 2
		{
		    if ${DistToStart} > ${DistToFinish}
		        call PathingRoutine ${StartPoint}
		    else
		        call PathingRoutine ${FinishPoint}
		        
		    PathRoute:Set[1]
		    continue
		}
		elseif ${PathRoute} == 3
		{
		    if ${DistToStart} > ${DistToFinish}
		    {
		        MovingToFinish:Set[FALSE]
		        call PathingRoutine ${StartPoint}
		    }
		    else
		    {
		        MovingToFinish:Set[TRUE]
		        call PathingRoutine ${FinishPoint}
		    }
		    
		    do
		    {
		        if ${MovingToFinish}
		        {
    		        MovingToFinish:Set[FALSE]
    		        call PathingRoutine ${StartPoint}
    		        call ProcessTriggers
    		        continue
		        } 
		        else
		        {
    		        MovingToFinish:Set[TRUE]
    		        call PathingRoutine ${FinishPoint}   
    		        call ProcessTriggers
		            continue
		        }
		    }
		    while ${ISXEQ2(exists)}
		    
            break
		}
		call ProcessTriggers
	}
	while ${PathRoute}<=3 && ${ISXEQ2(exists)}

	;ANNOUNCE IS BROKEN announce "Cleaning up Inventory before exiting..." 5 4
	call CheckInventory 10 "CleanUpOnExit"

	Script:End
}


function PathingRoutine(string Dest)
{
    variable bool harvested
    variable lnavregionref rDestination
    rDestination:SetRegion[${Dest}]
    
    if !${rDestination(exists)}
    {
		echo "EQ2Harvest:: There was no valid path found!"
		echo "EQ2Harvest:: Check '${Nav.Mapper.ZonesDir}${Nav.Mapper.ZoneText}' or '${Nav.Mapper.ZonesDir}${Nav.Mapper.ZoneText}.xml' that it includes a Start and Finish point."

		Script:End
	}        
    
    
    echo "EQ2Harvest-Debug::-> Moving to ${Dest}"
    Nav:MoveToRegion["${Dest}"]    
    do
    {
        Nav:Pulse
    	call CheckAggro
    	call CheckTimer
    
    	harvested:Set[FALSE]
		if ${UseSprint} && ${Me.Power} > 80
		{
			EQ2Execute /useability Sprint
		}
        
        ZoneRegion:SetRegion[${LNavRegion[${Nav.Mapper.ZoneText}]}]
    	NearestRegion:SetRegion[${ZoneRegion.NearestChild[${Me.Loc}]}]
        NodeID:Set[${Harvest.Node[${Me.Loc}]}]
        echo "${NodeID}"
        if (${NodeID} > 0)
        {
            echo "EQ2Harvest-Debug:: Node Found! (${Actor[${NodeID}]})"
            Harvesting:Set[TRUE]
			do
			{
				call CheckAggro
				call CheckTimer

				CurrentAction:Set[Found Node: ${Actor[${NodeID}].Name}]

				if !${Harvest.PCDetected}
				{
					if ${UseSprint} && ${Me.Power} > 80
					{
						EQ2Execute /useability Sprint
					}
					
					if (${Actor[${NodeID}].Name.Equal[?]} || ${Actor[${NodeID}].Name.Equal[!]})
					{
					    Nav.DestinationPrecision:Set[3]
					    Nav:MoveToLocNoMapping[${Actor[${NodeID}].Loc}]
					    echo "EQ2Harvest-Debug:: Moving to within ${Nav.DestinationPrecision}m of ${Actor[${NodeID}]}"
					    do
					    {
					        Nav:Pulse
					        wait 0.5
					        call ProcessTriggers
					    }
					    while ${ISXEQ2(exists)} && ${Nav.MeMoving} 
					    Nav.DestinationPrecision:Set[5]
					    echo "EQ2Harvest-Debug:: Move complete..."
					}
					else
					{
					    echo "EQ2Harvest-Debug:: Moving to within ${Nav.DestinationPrecision}m of ${Actor[${NodeID}]}"
					    Nav:MoveToLocNoMapping[${Actor[${NodeID}].Loc}]
					    do
					    {
					        Nav:Pulse
					        wait 0.5
					        call ProcessTriggers
					    }
					    while ${ISXEQ2(exists)} && ${Nav.MeMoving} 
					    echo "EQ2Harvest-Debug:: Move complete..."
					}


					; even with the above it still jumps the gun every so often...lag?
					wait 1

					if ${UseSprint}
					{
						Me.Maintained[Sprint]:Cancel
					}

                    echo "EQ2Harvest-Debug:: Harvesting..."
					call Harvest
					harvested:Set[TRUE]

					if !${IntruderAction} && ${IntruderStatus}==1 && ${IntruderDetect}
					{
						isintruder:Set[TRUE]
						do
						{
							call CheckAggro
							call CheckTimer
						}
						while ${isintruder}

						if ${Me.IsAFK}
						{
							EQ2Execute /afk
							wait 10
						}
					}
				}
				
                ZoneRegion:SetRegion[${LNavRegion[${Nav.Mapper.ZoneText}]}]
    		    NearestRegion:SetRegion[${ZoneRegion.NearestChild[${Me.Loc}]}]				
				NodeID:Set[${Harvest.Node[${Me.Loc}]}]
				if (${NodeID} == 0)
				{
				    Harvesting:Set[FALSE]
				    break
				}
			}
			while ${Harvesting}
			echo "EQ2Harvest-Debug:: Harvesting complete..."
	    }
        
        if ${harvested}
        {
            if ${Nav.NearestRegionDistance[${rDestination.CenterPoint}]} > 50
            {
                echo "EQ2Harvest-Debug:: The nearest mapped point from your current location is ${Nav.NearestRegionDistance[${rDestination.CenterPoint}]}m away.  More mapping data is needed for this zone."
                Nav:StopRunning
                endscript EQ2Harvest
                return
            }
            
    		ZoneRegion:SetRegion[${LNavRegion[${Nav.Mapper.ZoneText}]}]
    		NearestRegion:SetRegion[${ZoneRegion.NearestChild[${Me.Loc}]}]
    		if ${Me.CheckCollision[${NearestRegion.CenterPoint}]}
    		{
    		    Nav:StopRunning   
    		    echo "EQ2Harvest:: The nearest mapped point (${NearestRegion.CenterPoint}) is only ${Nav.NearestRegionDistance[${rDestination.CenterPoint}]}m away; however, there is an obstacle in the way.  More mapping data or manual editing of the map file is required."]
                endscript EQ2Harvest
                return
    		}
		
            echo "EQ2Harvest-Debug:: Moving to nearest mapped point."
            Nav:MoveToNearestRegion[${rDestination.CenterPoint}]
            do
            {
                Nav:Pulse
                wait 0.5 
                call ProcessTriggers
            }
            while ${ISXEQ2(exists)} && ${Nav.MeMoving} 
            echo "EQ2Harvest-Debug:: Move complete..."
            echo "EQ2Harvest-Debug::-> Moving to ${Dest}"
            Nav:MoveToRegion["${Dest}"]     
            Nav:Pulse           
            continue
        }
        else
        {
            Nav:Pulse
            wait 0.5
            call ProcessTriggers         
        }
        echo "EQ2Harvest-Debug:: Distance to ${Dest}: ${Math.Distance[${Me.Loc},${rDestination.CenterPoint}]}"
    }
    while ${Math.Distance[${Me.Loc},${rDestination.CenterPoint}]} >= 5 && ${Nav.MeMoving}
    echo "EQ2Harvest-Debug:: Reached Destination (${Dest})"
}

function CheckAggro()
{
    CheckingAggro:Set[TRUE]
	;Stop Moving and pause if we have aggro
	if ${MobCheck.Detect}
	{
		CurrentAction:Set[Aggro Detected Pausing...]
		Nav:StopRunning
		if ${UseSprint}
		{
			Me.Maintained[Sprint]:Cancel
		}

		CurrentAction:Set[Waiting till aggro gone, and over 90 health...]
		do
		{
			wait 3
		}
		while ${MobCheck.Detect} || ${Me.Health}<90

		CurrentAction:Set[Checking For Loot...]

		if ${Actor[chest,radius,15].Name(exists)} || ${Actor[corpse,radius,15].Name(exists)}
		{
			CurrentAction:Set[Loot nearby waiting 5 seconds...]
			wait 50
		}
		CurrentAction:Set[Resuming Harvest...]
		CheckingAggro:Set[FALSE]
		Return "RESOLVED"
	}
	CheckingAggro:Set[FALSE]
	return SUCCESS
}


function CheckTimer()
{
	if ${TimerOn} && ${Math.Calc64[${HarvestTime}-(${Time.Timestamp}-${StartTimer})/60]} < 0
	{
		wait 20
		if ${HowtoQuit}
		{
			timed 100 EQ2Execute /camp desktop
		}

		;ANNOUNCE IS BROKEN announce "Timer expired. Cleaning up inventory before exiting..." 5 4
		call CheckInventory 10 "CleanUpOnExit"

		Script:End
	}
}

function InventoryFull(string Line)
{
	; End the script since we have no more room to harvest
	echo Ending script because our Inventory is FULL!!
	wait 20
	if ${HowtoQuit}
	{
		timed 100 EQ2Execute /camp desktop
	}

	;ANNOUNCE IS BROKEN announce "Cleaning up Inventory before exiting..." 5 4
	call CheckInventory 10 "CleanUpOnExit"

	Script:End
}

function GMDetected(string Line)
{
	; Close the InnerSpace session completely!
	echo ${Line} > GMDetected.txt
	wait 50
	Exit
}

function ProcessTriggers()
{
    variable string PreviousAction
    PreviousAction:Set[${CurrentAction}]
    
	if !${StartHarvest}
	{
		CurrentAction:Set[Waiting to Resume...]
		while !${StartHarvest}
		{
			waitframe
		}
		CurrentAction:Set[${PreviousAction}]
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

	do
	{
		call CheckAggro
		CurrentAction:Set[Harvesting: ${Actor[${NodeID}].Name}]

        if (${Target.ID} != ${NodeID})
            target ${NodeID}
            
        if ${Target(exists)}
        {
            if ${Target.Distance} > 5
            {
                face ${Target}
                wait 2
                Nav:MoveToLocNoMapping[${Target.Loc},5]
        		do
        		{
        		    wait 0.5
        		    Nav:Pulse
        		    call ProcessTriggers
        		}
        		while ${Nav.MeMoving}
        		
        		waitframe
        		Nav:StopRunning
            }
        }
        Actor[${NodeID}]:DoubleClick
        gNodeName:Set[${Actor[id,${NodeID}].Name}]
        wait 20
        if (${OnBadNode})
        {
            OnBadNode:Set[FALSE]
            return PROBLEM
        }
		call ProcessTriggers

		do
		{
		    ;echo "waiting..."
		    waitframe
		}
		while (${Me.CastingSpell})
		wait 5

		if !${intrcheck} && ${intrdetect}
		{
			call CheckIntruder
			intrcheck:Set[1]
		}

		call ProcessTriggers
	}
	while ${Actor[id,${NodeID}].Name(exists)}

	if ${NodeDelay}
	{
		delay:Set[${Math.Rand[${NodeDelay}]}]
		savetime:Set[${Time.Timestamp}]
		do
		{
			call CheckAggro
			waittime:Set[${Math.Calc64[(${delay}+${savetime})-${Time.Timestamp}]}]
			CurrentAction:Set[Waiting ${waittime} seconds for Random delay]
			wait 5
		}
		while ${waittime} > 0
	}
	
	return OK
}

;;;;;;;;
;; CustomInventory (and related routines) are removed from ISXEQ2. All functionality can be done with queries 
;; (see http://forge.isxgames.com/projects/isxeq2/knowledgebase/articles/40).   This routine was written using
;; CustomInventory in a very convoluted way, so it will have to be completely revamped/reworked.
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
								echo Unable to move a Resource: ${Me.CustomInventory[${tempvar}].Name}\n >> HarvestError.txt
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

;;;;;;;;
;; CustomInventory (and related routines) are removed from ISXEQ2. All functionality can be done with queries 
;; (see http://forge.isxgames.com/projects/isxeq2/knowledgebase/articles/40).   This routine will have to be 
;; revamped/reworked.
function DestroyItem(string destroyname)
{
	variable int slotchk
	variable int contchk
	variable int brkcnt
	variable int tempvar
	variable int tempvar2
	echo need to detroy item
	;wait 20
	tempvar:Set[1]
	Me:CreateCustomInventoryArray[nonbankonly]
	;wait 4
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
					echo Unable to move a Collect: ${Me.CustomInventory[${tempvar}].Name}\n >> HarvestError.txt
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
	; clearly, "a" or "an" will == 0   :)
    if (${number} == 0)
        number:Set[1]

 	if ${result.Find[Glowing]} || ${result.Find[Sparkling]} || ${result.Find[Glimmering]} || ${result.Find[Luminous]} || ${result.Find[Lambent]} || ${result.Find[Scintillating]} || ${result.Find[Smoldering]}
 	{
 		executeatom Harvest:Rare "${Line}" "${result}"
	 	return
 	}

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
		UseSprint:Set[${SettingXML[${ConfigFile}].Set[General Settings].GetString[Sprint between nodes?,FALSE]}]
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
		FilterY:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetInt[What distance along Y axis should the bot ignore nodes?,30]}]
		StartPoint:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetString[Starting Point,Start]}]
		FinishPoint:Set[${SettingXML[${ConfigFile}].Set[${Zone.ShortName}].GetString[Finishing Point,Finish]}]

		SettingXML[${ConfigFile}]:Save

		; Check Weight in case we are moving to slow
		if ${Math.Calc[${Me.Weight}/${Me.MaxWeight}*100]}>150
		{
			checklag:Set[2]
		}
	}

	method InitTriggersAndEvents()
	{
		; Add trigger for inventory full
		AddTrigger InventoryFull "@*@inventory is currently full."

		; Add GM/CS TELL triggers
		;AddTrigger GMDetected "@*@GM.@*@tells you@*@"
		;AddTrigger GMDetected "@*@CS.@*@tells you@*@"
		;AddTrigger GMDetected "\\aPC @*@ @*@:@sender@\\/a tells you@*@GM@*@"

		; Add Harvest triggers
		AddTrigger Harvested "Announcement::You have @action@:\n@number@ @result@"
		AddTrigger Harvest:Rare "Announcement::Rare item found!\n@rare@"
		
		Event[EQ2_onLootWindowAppeared]:AttachAtom[EQ2_onLootWindowAppeared]
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
	}

	method LoadUI()
	{
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/EQ2-Green/EQ2-Green.xml"
		ui -reload -skin EQ2-Green "${UIPath}HarvestGUI.xml"
	}

	member:int Node(float lastWP_X, float lastWP_Y, float lastWP_Z)
	{
		variable int tempvar
		variable index:actor Actors
		variable iterator ActorIterator

		tempvar:Set[1]
		EQ2:QueryActors[Actors, Type =- "Resource"]
		Actors:GetIterator[ActorIterator]

		if ${ActorIterator:First(exists)}
		{
			do
			{	
				tempvar:Set[0]
				while ${tempvar:Inc} <= 9
				{
					if ${ActorIterator.Value.Name.Equal[${NodeName[${tempvar}]}]} && ${HarvestNode[${tempvar}]}
					{
						; Check Distance and Roaming Distance is within range.
						;echo "EQ2Harvest-Debug:: Distance to nearest mapped area: ${Math.Distance[${ActorIterator.Value.X},${ActorIterator.Value.Z},${NearestRegion.CenterPoint.X},${NearestRegion.CenterPoint.Z}]}"
						if ${Math.Distance[${ActorIterator.Value.Y},${Me.Y}]}<${FilterY} && (${Math.Distance[${ActorIterator.Value.X},${ActorIterator.Value.Z},${NearestRegion.CenterPoint.X},${NearestRegion.CenterPoint.Z}]}<${MaxRoaming} || ${Math.Distance[${ActorIterator.Value.X},${ActorIterator.Value.Z},${Me.X},${Me.Z}]}<${HarvestClose})
						{
							; Check to make sure it is not a bad node
							if (${BadNodes.Element[${ActorIterator.Value.ID}].Name(exists)})
								break		
							; make sure that it is close enough to our mapped zone
							if ${Math.Distance[${ActorIterator.Value.Y},${lastWP_Y}]}<${FilterY} && (${Math.Distance[${ActorIterator.Value.X},${ActorIterator.Value.Z},${NearestRegion.CenterPoint.X},${NearestRegion.CenterPoint.Z}]}<${MaxRoaming} || ${Math.Distance[${ActorIterator.Value.X},${ActorIterator.Value.Z},${lastWP_X},${lastWP_Z}]}<${HarvestClose})
							{
								NodeType:Set[${tempvar}]
								return ${ActorIterator.Value.ID}						    						    
							}
							else
							{
								echo "DEBUG: '${ActorIterator.Value.Name}' was too far away from the mapped zone...we'll come back to it I'm sure"
								break
							}
						}
					}
				}
			}
			while ${ActorIterator:Next(exists)}
		}

		return 0
	}

	member:bool PCDetected()
	{
		variable index:actor Actors
		variable iterator ActorIterator

		EQ2:QueryActors[Actors, Type =- "PC"]
		Actors:GetIterator[ActorIterator]

		if ${ActorIterator:First(exists)}
		{
			do
			{	
				if ${Math.Distance[${ActorIterator.Value.X},${ActorIterator.Value.Z},${Actor[${NodeID}].X},${Actor[${NodeID}].Z}]}<20
				{
					if (!${Me.Group[${ActorIterator.Value.Name}].Name(exists)})
					{
						echo "DEBUG: A player (${ActorIterator.Value.Name}) was detected within 20 meters...adding destination to BadNodes"
						This:SetBadNode[${NodeID}]
						return TRUE
					}
				}
			}
			while ${ActorIterator:Next(exists)}
		}

		return FALSE
	}

	method SetBadNode(string badnodeid)
	{
	    echo "DEBUG: Adding (${badnodeid},${Actor[id,${badnodeid}].Name}) to the BadNodes list"
		BadNodes:Set[${badnodeid},${Actor[id,${badnodeid}].Name}]

		echo "DEBUG: BadNodes now has ${BadNodes.Used} nodes in it."	    
	}

	method Rare(string Line, string rare)
	{
		if ${rare.Find[Glowing]} || ${rare.Find[Sparkling]} || ${rare.Find[Glimmering]} || ${rare.Find[Luminous]} || ${rare.Find[Lambent]} || ${rare.Find[Scintillating]} || ${rare.Find[Smoldering]}
			ImbueStat:Inc
		else
			RareStat:Inc
	}

    method CollectibleFound(string sName)
    {
        echo "DEBUG: Collectible Found('${sName}')"
        
    	variable int tempvar
    
    	tempvar:Set[${This.SearchItems[${sName}]}]
    
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
    			call DestroyItem "${sName}"
    		}
    	}
    	else
    	{
    		if !${DestroyNode[${NodeType}]}
    		{
    			call DestroyItem "${sName}"
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
		variable index:item Items
		variable iterator ItemIterator

		Me:QueryInventory[Items, Location == "Inventory"]
		Items:GetIterator[ItemIterator]

		itotal:Set[0]
		stackcount:Set[0]
		if ${ItemIterator:First(exists)}
		{
			do
			{
				if ${ItemIterator.Value.Name.Equal[${itemsearch}]}
				{
					stackcount:Inc
					ItemID[${stackcount}]:Set[${xvar}]
					ItemCount[${stackcount}]:Set[${ItemIterator.Value.Quantity}]
					itotal:Inc[${ItemIterator.Value.Quantity}]
				}
			}
			while ${ItemIterator:Next(exists)}
		}
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
	;ANNOUNCE IS BROKEN announce "Cleaning up Inventory before exiting..." 5 4
	call CheckInventory 10 "CleanUpOnExit"    
    
	ui -unload "${UIPath}HarvestGUI.xml"

	SettingXML[${ConfigFile}]:Unload
	SettingXML[${HarvestFile}]:Unload

    Nav:StopRunning    	

	Event[EQ2_onLootWindowAppeared]:DetachAtom[EQ2_onLootWindowAppeared]
	Event[EQ2_onChoiceWindowAppeared]:DetachAtom[EQ2_onChoiceWindowAppeared]
	Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]
}


atom(script) EQ2_onIncomingText(string Text)
{
	if (${Text.Find["too far away"]} > 0)
	{
	    if (${Actor[id,${NodeID}].Type.Equal[Resource]} && !${Me.InCombat})
	    {
	        echo "DEBUG: Node is 'too far away'...adding to BadNodes"
    	    Harvest:SetBadNode[${NodeID}]
    	    OnBadNode:Set[TRUE]
    	}
	}
	;elseif (${Text.Find["Interrupted!"]} > 0)
	;{
	    ;if (${Actor[id,${NodeID}].Type.Equal[Resource]} && !${Me.InCombat})
	    ;{	  
	        ;;; This shouldn't happen anyway, and it's causing problems with running eq2harvest with eq2bot
    	    ;echo "DEBUG: We were 'Interupted!'...adding to BadNodes"
    	    ;Harvest:SetBadNode[${NodeID}]
    	    ;OnBadNode:Set[TRUE]
    	;}
	;}	
	elseif (${Text.Find["Can't see target"]} > 0)
	{
	    if (${Actor[id,${NodeID}].Type.Equal[Resource]} && !${Me.InCombat})
	    {	    
    	    echo "DEBUG: Received 'Cant see target' message...adding to BadNodes"
    	    Harvest:SetBadNode[${NodeID}]
    	    OnBadNode:Set[TRUE]
    	}
	}
	elseif (${Text.Find["You cannot "]} > 0)
	{
	    if (${Actor[id,${NodeID}].Type.Equal[Resource]} && !${Me.InCombat})
	    {
            echo "DEBUG: Received 'You cannot ...' message...adding to BadNodes"
    	    Harvest:SetBadNode[${NodeID}]   
    	    OnBadNode:Set[TRUE]
    	}
	}					
}

atom(script) EQ2_onChoiceWindowAppeared()
{
    ;; if EQ2Bot is running, let IT handle this...
    if (${Script[EQ2Bot](exists)})
        return    
    
	if ${ChoiceWindow.Text.Find[No-Trade]}
        ChoiceWindow:DoChoice1

	return
}

atom(script) EQ2_onLootWindowAppeared(int ID)
{    
    if (${LootWindowsProcessed.Element[${ID}](exists)})    
        return
    
    
    ; deal with collectibles
    if (${gNodeName.Equal[?]} || ${gNodeName.Equal[!]})
    {
        ;echo "EQ2Harvest-Debug:: LootWindow ${ID} contains a collectible!"
        Harvest:CollectibleFound[${LootWindow[${ID}].Item[1].Name}] 
    }
    
    ;; if EQ2Bot is running, let IT handle actual looting
    if (${Script[EQ2Bot](exists)})
    {
        LootWindowsProcessed:Set[${ID},${gNodeName}]
        return
    }    
    
    ;; Now do the actual looting
    if ${LootWindow.Type.Equal[Lottery]}
    {
        LootWindowsProcessed:Set[${ID},${gNodeName}]
        LootWindow:RequestAll
        return
    }
    elseif ${LootWindow.Type.Equal[Need Before Greed]}
    {
        LootWindowsProcessed:Set[${ID},${gNodeName}]
        LootWindow:SelectGreed
        return
    }
    else
    {
        LootWindowsProcessed:Set[${ID},${gNodeName}]
        LootWindow:LootItem[1]
        return
    }
}
