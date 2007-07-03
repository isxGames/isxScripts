;-----------------------------------------------------------------------------------------------
; Harvest.iss Version 3.4  Updated: 09/17/05
;
; Written by: Blazer
;
; Description:
; ------------
; Automatically harvests specified nodes following a Navigational Path created with EQ2Pather.iss
; The Navigational file needs to consist of at least a Starting and Ending point with the labels
; defined when you run the script.
;
; Revision History
; ----------------
; v3.4 - * Modified the path to the filenames from the last IS release.
;
; v3.3 - * Some minor fixes applied.
;
; v3.2 - * Fixed the way variables are declared now, since the last IS update.
;
; v3.1 - * Few minor fixes to Bot Police Detection.
;
; v3.0 - * Bot Police Detection!
;	   You can enable or disable this option in the config file. It is set to disabled by default.
;	   If the bot finds that someone has been following you within the last 10 minutes then it will take
;	   appropriate action. If they are on your Friends List, then no action will be taken.
;	   If he is on your Black List or if he has been on your tail within 10 mins of the last 5 nodes
;	   you harvested, then one of 2 things will happen.
;	   1) You will go afk, and then just wait till he is out of sight (50 Range) for at least 1 minute.
;						or
;	   2) YOu will continue to follow your nav path only, ignoring all harvest nodes till he is out of
;	      sight for at least 1 minute.
;	   Option 2) is set by default. The Black List and Friends list can be modified in the config file.
;
; v2.6 - * Announcement trigger fixed to work with the latest isxeq2.
;
; v2.5 - * More fixes.
;	 * Harvesting nodes has less delay now between harvests.
;	 * Modified some of the moveto routines.
;
; v2.4 - * Some minor bug fixes.
;
; v2.3 - * Fixed Huds to work with the last IS update.
;
; v2.2 - * Movement of the bot is now a lot smoother. It will now only ever stop moving if it either
;	   reaches a node or it gets stuck and needs to back up. Make sure you get moveto.iss v1.7
;	   or higher.
; v2.1 - * The bot will now be able to more thoroughly harvest any nodes that are close to him.
;	   There is a new setting which will set how close a node can be to the bot, to harvest it,
;	   regardless if its outside the roaming range.
;	 * Pressing your end key (F11) to end the script will now clean up the inventory as well from
;	   what you had just harvested, based on your configuration settings.
; v2.0 - * Configuration settings have now been moved to '.\Scripts\XML\HarvestConfig.xml'
;	   If the file does not exist, it will be created. If it doesnt contain a particular setting
;	   then it will be added to the config file with a default setting. This will allow for
;	   future releases without modifying your custom settings.
;	   You can generally set 0 for NO, or 1 for YES, similiar to how the settings were set before.
;	 * Destroy functionality has now been added.
;	   - You can specify which nodes to destroy in the config file.
;	   This value will actually indicate how many of that resource type you want to keep. If there are
;	   more than 1 type of resource from the same node, then it will keep that many for each
;	   resource. If you put 0, then it wont keep any. This value is defaulted to 999.
;	   - You can also include specific resources that you want to keep as well, which will override
;	   the values set above.
;	   - You can specify what you want to keep for collectibles, for example enchanted bones.
;	   It will do partial matching, so if you just specify 'bone', it will keep all collectibles that
;	   have the word 'bone' in it for how ever many you want.
;	   - You can have up to 50 items to keep in the config file for either the resource or collectible.
;	   - You can specify how many resources you want to harvest, before it destroys that batch.
;	   The default is set to 200. So after you have harvested 200 resources, it will clean up your
;	   inventory, keeping resources based on your settings. This avoids doing continous destroying,
;	   and instead, will do it in batches.
;	 * Added a Timer in the config file to set how long you want to harvest, before ending the script.
;	   Enter a value in minutes. e.g 180 would indicate 3 hours of harvesting.
;	   Leaving this value at 0, will disable the timer. Default is set to 0.
;	 * You can indicate how you want to exit, when the script ends.
;	   0 - Will just end the script and do nothing
;	   1 - Will camp out to the desktop (This is the default value).
;	 * All the configuration files (XML) will now be located in .\scripts\xml
;	 * Added -reset. Type in 'run harvest -reset' and this will clear the config file to the default
;	   settings. If this is your first time running this version, you should run it with the -reset
;	   option and modify any settings you need.
;	 * More code tweaks and fixes.
;
; v1.5 - * If your bot is trying to get to a resource node, but gets stuck, and moves to the nearest
;	   waypoint, then tries to get to that node again, it will be marked bad now, so it wont loop.
;	 * Made some tweaks, due to the fix for location updates.
;
; v1.4 - * Added '-list' to view a list of key points in the navigational file, which can be used
;	   as starting or finish points. e.g run eq2pather -list. This will only work with
;	   navigational files created with EQ2Pather v1.4 or higher.
;	 * Fixed the PC Detection to work better.
;
; v1.3 - * Added Oakmyst to the zone list.
;	 * Added Cove of Decay to the zone list.
;	 * You can now exit out of the script by pressing F11. This will happen after the last
;	   harvest. F11 can be set to something else if you like (see below).
;	 * HudX and Hudy can be changed, if you want the HUD displayed elswhere on the screen.
;	 * Modified some of the code to use /target (since its fixed) and Actor TLO.
;	 * Fixed a bug with ending the script properly if your really stuck.
;	 * It will no longer matter where you run the script from, whether it be the finish point
;	   or any other point, as long as you have a starting and ending point defined in the
;	   navigation file, and it matches what you are using when you run the script.
;	 * PC detection added. If there is a PC player within 10 yards of the node you want to
;	   harvest, it will ignore it. This check is done before moving to the node.
;	 * It will now harvest decrepit bones in Commonlands or Antonica. This will be included
;	   under Other harvests. Strange Black Ore is also added to Other Harvests.
;	 * It will now harvest the closest nodes first.
;
; v1.2 - * Added a Hud to view statistics.
;	 * Added rivervale to the zone list.
;	 * You can now specify the Start and Finish as command line parameters instead.
;	   e.g run harvest Start Bridge
;	 * Fixed several bugs.
;
; v1.1 - * Automatically detects the nodes to harvest, based on the zone you are currently in.
;	   Works with the following zones; Antonica, Commanlands, Thundering Steppes, Neriak, Zek,
;	   Enchanted Lands, Feerrott, Everfrost and Lavastorm.
;	 * You now only need to specify what node type to harvest.
;	 * Roaming is now defined for each zone in Harvest.xml. If you need to harvest areas like
;	   Lavastorm, then you should set the roaming to say 40, but include more nav points.
;	   This will ensure more coverage, and less chances of getting stuck or falling in lava:)
;	 * If you get stuck 3 times in the same spot, it will now attempt to locate the nearest
; 	   nav point and re-calculate the nav path. If you still get stuck, then it will end
;	   the script.
;
; v1.0 - * Initial Release.
;
; To Do List:
; -----------
; - Aggro detection on mobs.
;-----------------------------------------------------------------------------------------------

#include moveto.iss

function main(string start, string end)
{
	declare filename string script
	declare NearestPoint string script
	declare World string script
	declare StartPoint string script
	declare EndPoint string script
	declare pathindex int script
	declare pathroute int script
	declare CurrentNodeX float script
	declare CurrentNodeZ float script
	declare CurrentNodeName string script
	declare CurrentNodeID int script
	declare PCID int script
	declare maxroaming int script
	declare tempvar int script
	declare tempvar2 int script
	declare tempvar3 int script
	declare tempvar4 int script
	declare BadNode[4] int script
	declare badnodecount int script 0
	declare HarvestNode[10] string script
	declare HarvestTool[10] string script
	declare HarvestType[20] bool script
	declare foundnode bool script 0
	declare badnodedetected bool script 0
	declare justharvested bool script FALSE
	declare nodecount int script 0
	declare nodedistWP float script 0
	declare nodedistME float script 0
	declare WPX float script
	declare WPZ float script
	declare temppass int script 0
	declare pathdirection bool script 0
	declare displaystats bool script
	declare HudX int script
	declare HudY int script
	declare harveststat[20] int global 0
	declare harvestname[20] string global
	declare tempval int script 0
	declare endkey string script
	declare checkend int global 0
	declare closestDist float script
	declare closestX float script
	declare closestZ float script
	declare closestName string global
	declare closestID int script
	declare closestCount int script
	declare totalharvest int global 0
	declare totaldestroy int global 0
	declare destroynode[10] int script
	declare destroybatch int global
	declare keepcollnme[50] string script
	declare keepcollcnt[50] int script 0
	declare keepcollcur[50] int script 0
	declare keepcomm[50] string script
	declare keepspec int script
	declare keepnode[10] int script
	declare itemcount int script 0
	declare timer int script 0
	declare timerval int script 0
	declare xmlpath string script "./XML/"
	declare configfile string script
	declare harvestfile string script
	declare dnnamecnt int script 0
	declare oldnamecnt int script 0
	declare dnnamearr[30] string script
	declare dncount[30] int script 0
	declare dnfound bool script
	declare howtoquit int script
	declare collectcnt int script 0
	declare resetconf bool script FALSE
	declare foundcnt[200] int script
	declare foundid[200] int script
	declare stackcnt int script
	declare itotal int script
	declare lowestcnt int script
	declare lowestid int script
	declare totalitemdest int script
	declare harvestclose int script
	declare tempchk1 int script
	declare tempchk2 int script
	declare brkcnt int script
	declare harvestcnt int script
	declare FriendsList[50] string script
	declare nFriendsList int script
	declare BlackList[50] string script
	declare nBlackList int script
	declare IntruderList[50] string script
	declare IntruderCount[50] int script
	declare IntruderTimer[50] int script
	declare nIntruderCount int script
	declare intrdetect int script
	declare intraction int script
	declare intrstatus int script
	declare intrcheck int script
	declare isintruder bool script FALSE
	declare intrtimer int script

	;-------------
	; Main Script
	;-------------

	extension -require isxeq2

	; This will harvest Decrepit Bones (in commonlands or Antonica)
	HarvestType[10]:Set[1]

	; These are for Imbue Stones and Rares
	HarvestType[19]:Set[1]
	HarvestType[20]:Set[1]

	filename:Set[${xmlpath}EQ2Navigation_${Zone.ShortName}.xml]
	configfile:Set[${xmlpath}HarvestConfig.xml]
	harvestfile:Set[${xmlpath}Harvest.xml]

	if !${start.Length}
	{
		echo "Syntax: run harvest -reset | -list | <start> <finish>"
		echo "Where <start> and <finish> are the optional starting and ending point names used in the navigation file."
		echo "-reset is used to clear and reset the config file to default settings."
		echo "-list is used to list key points that were labeled in your navigation file with eq2pather v1.3 or higher."
		echo "Any key points can be used as the starting and ending point names as well."
		echo Using "Start" as the first point name
		StartPoint:Set[Start]
	}
	else
	{
		if "${start.Equal[-list]}"
		{
			resetconf:Set[1]
			tempvar:Set[1]
			squelch Navigation -load ${filename}
			do
			{
				if "${Navigation.World[${Zone.ShortName}].Point[${tempvar}].Note.Equal[keypoint]}"
				{
					EQ2Echo ${Navigation.World[${Zone.ShortName}].Point[${tempvar}].Name}
				}
			}
			while "${tempvar:Inc}<=${Navigation.World[${Zone.ShortName}].LastID}"
			Script:End
		}
		else
		if "${start.Equal[-reset]}"
		{
			resetconf:Set[1]
			SettingXML[${configfile}]:Clear
			call InitHarvest
			call InitConfig
			EQ2Echo ***Harvest Configuration file has been reset to the default settings***
			EQ2Echo You can now modify the settings in '${configfile}'
			Script:End
		}
		else
		{
			StartPoint:Set[${start}]
		}
	}
	if !${end.Length}
	{
		echo Using "Finish" as the last point name
		EndPoint:Set[Finish]
	}
	else
	{
		EndPoint:Set[${end}]
	}

	call InitHarvest

	call InitConfig

	call InitTriggers

	execute squelch HUD -Add FunctionKey1 ${HudX},${HudY} "${endkey} - This will end your harvesting session."

	if ${displaystats}
	{
		call InitHud
	}

	World:Set[${Zone.ShortName}]

	squelch Navigation -reset
	squelch Navigation -load ${filename}

	do
	{
		NavPath:Clear
		pathindex:Set[1]

		if "${pathroute}==1"
		{
			NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

			if "${NearestPoint.Equal[${EndPoint}]}"
			{
				squelch NavPath "${World}" "${EndPoint}" "${StartPoint}"
			}
			else
			{
				squelch NavPath "${World}" "${NearestPoint}" "${EndPoint}"
				pathdirection:Set[1]
			}

			call PathingRoutine
			pathroute:Set[4]
			continue
		}
		else
		{
			if "!${temppass(bool)}"
			{
				NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

				if "${NearestPoint.Equal[${EndPoint}]}"
				{
					squelch NavPath "${World}" "${EndPoint}" "${StartPoint}"
				}
				else
				{
					squelch NavPath "${World}" "${NearestPoint}" "${EndPoint}"
					pathdirection:Set[!${pathdirection}]
				}

				call PathingRoutine
				temppass:Set[1]
			}
			else
			{
				NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
				squelch NavPath "${World}" "${EndPoint}" "${StartPoint}"

				pathdirection:Set[!${pathdirection}]

				call PathingRoutine
				temppass:Set[0]

				if "${pathroute}==2"
				{
					pathroute:Set[4]
				}
				continue
			}
		}
	}
	while "${pathroute}<=3"

	Script:End
}

function PathingRoutine()
{
	; If we have a valid path then begin harvesting.
	if "${NavPath.Points}>0"
	{
		press MOVEFORWARD
		do
		{
			; Move to next Waypoint
			WPX:Set[${NavPath.Point[${pathindex}].X}]
			WPZ:Set[${NavPath.Point[${pathindex}].Z}]

			call moveto ${WPX} ${WPZ} 5 1

			; Check to see if we are stuck getting to the node
			if "${Return.Equal[STUCK]}"
			{
				call stuckstate
				continue
			}

			do
			{
				nodecount:Set[1]
				justharvested:Set[FALSE]
				call checkkeys

				closestDist:Set[9999]
				closestX:Set[0]
				closestZ:Set[0]
				closestName:Set[]
				closestID:Set[0]
				closestCount:Set[1]
				foundnode:Set[0]

				do
				{
					if "${HarvestType[${nodecount}](bool)}"
					{
						; Lets scan for the closest node first and get its co-ordinates
						CurrentNodeID:Set[${Actor[${HarvestNode[${nodecount}]},notid,${BadNode[1]},notid,${BadNode[2]},notid,${BadNode[3]},notid,${BadNode[4]}].ID}]

						if "${CurrentNodeID(bool)}"
						{
							CurrentNodeX:Set[${Actor[${CurrentNodeID}].X}]
							CurrentNodeZ:Set[${Actor[${CurrentNodeID}].Z}]
							CurrentNodeName:Set[${Actor[${CurrentNodeID}].Name}]

							nodedistWP:Set[${Math.Distance[${CurrentNodeX},${CurrentNodeZ},${WPX},${WPZ}]}]
							nodedistME:Set[${Math.Distance[${CurrentNodeX},${CurrentNodeZ},${Me.X},${Me.Z}]}]

							if "(${CurrentNodeName.Equal[${HarvestNode[${nodecount}]}]} && ${nodedistWP}<=${maxroaming}) || (${CurrentNodeName.Equal[${HarvestNode[${nodecount}]}]} && ${nodedistME}<=${harvestclose})"
							{

								foundnode:Set[1]

								; Check if node is invalid
								tempvar:Set[1]
								do
								{
									if "${CurrentNodeID}==${BadNode[${tempvar}]}"
									{
										foundnode:Set[0]
										break
									}
								}
								while "${tempvar:Inc}<=${badnodecount}"


								if "${closestDist}>${nodedistME} && ${foundnode}"
								{
									closestX:Set[${CurrentNodeX}]
									closestZ:Set[${CurrentNodeZ}]
									closestName:Set[${CurrentNodeName}]
									closestDist:Set[${nodedistME}]
									closestID:Set[${CurrentNodeID}]
									closestCount:Set[${nodecount}]
								}
							}
						}
					}
				}
				while "${nodecount:Inc}<=10"

				; Assume we found a harvestable node
				if ${foundnode}
				{
					if ${intraction} && ${intrstatus}==1 && ${intrdetect}
					{
						call AvoidAction
					}
					else
					{
						call PCDetect
						if "!${Return.Equal[DETECTED]}"
						{
							press MOVEFORWARD
							call moveto ${closestX} ${closestZ} 5

							; Check to see if we are stuck getting to the node
							if "${Return.Equal[STUCK]}"
							{
								call SetBadNode
								call stuckstate
								continue
							}
							call Harvesting

							if !${intraction} && ${intrstatus}==1 && ${intrdetect}
							{
								isintruder:Set[TRUE]
								do
								{
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
							press MOVEFORWARD
						}
					}
				}
			}
			while ${justharvested}
		}
		while "${pathindex:Inc}<=${NavPath.Points}"
		press MOVEFORWARD
	}
	else
	{
		EQ2Echo There was no valid path found!
		EQ2Echo Check ${filename} that it includes a Start and End point.
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
	if ${howtoquit}
	{
		timed 100 EQ2Execute /camp desktop
	}
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
	if "${QueuedCommands}"
	{
		do
		{
			ExecuteQueued
		}
		while "${QueuedCommands}"
	}
}

function Harvesting()
{
	; Lets try to harvest it

	; Check for PC's near the node just in case we missed them the first time around.
	call PCDetect
	if "!${Return.Equal[DETECTED]}"
	{
		call checkkeys
		intrcheck:Set[0]

		target ${closestID}
		wait 5 "${Target.ID}==${closestID}"
		harvestcnt:Set[0]

		do
		{
			call checkkeys
			if ${harvestcnt}>2
			{
				wait 20 !${Target.ID}
				if !${Target.ID}
				{
					break
				}
			}

			EQ2Execute /useability ${HarvestTool[${closestCount}]}
			wait 15

			call ProcessTriggers
			if ${badnodedetected}
			{
				call SetBadNode

				break
			}
			else
			{
				justharvested:Set[TRUE]
				if !${intrcheck} && ${intrdetect}
				{
					call CheckIntruder
					intrcheck:Set[1]
				}
				wait 60 !${Me.CastingSpell}

				; Catch the trigger for the current harvest to update the HUD
				if ${displaystats}
				{
					call ProcessTriggers
				}
			}
		}
		while ${Target.ID}

		if ${displaystats}
		{
			closestName:Set[]
		}
	}
}

function InitHarvest()
{
	tempvar:Set[1]
	harvestname[1]:Set[Ore]
	harvestname[2]:Set[Stone]
	harvestname[3]:Set[Wood]
	harvestname[4]:Set[Roots]
	harvestname[5]:Set[Pelts]
	harvestname[6]:Set[Shrubs]
	harvestname[7]:Set[Fungi]
	harvestname[8]:Set[Fish]
	harvestname[9]:Set[Collectibles]
	harvestname[10]:Set[Other]
	harvestname[19]:Set["Imbue Stones"]
	harvestname[20]:Set[Rares]

	if !${resetconf}
	{
		EQ2Echo The following nodes will be harvested...
	}

	; Define the nodes to be harvested from the Harvest.xml file
	do
	{
		if "${tempvar}<=9"
		{
			if "${tempvar}==6 || ${tempvar}==7 || ${tempvar}==8"
			{
				HarvestType[${tempvar}]:Set[${SettingXML[${configfile}].Set["What Node to Harvest? (0-Ignore or 1-Harvest)"].GetInt[${harvestname[${tempvar}]},0]}]
			}
			else
			{
				HarvestType[${tempvar}]:Set[${SettingXML[${configfile}].Set["What Node to Harvest? (0-Ignore or 1-Harvest)"].GetInt[${harvestname[${tempvar}]},1]}]
			}
		}

		if "${HarvestType[${tempvar}](bool)}"
		{
			if "${tempvar}==9"
			{
				HarvestNode[9]:Set[?]
			}
			else
			{
				HarvestNode[${tempvar}]:Set[${SettingXML[${harvestfile}].Set[${Zone.ShortName}].GetString[${tempvar}]}]
			}
			if "${HarvestNode[${tempvar}].NotEqual[NULL]}"
			{
				if !${resetconf}
				{
					EQ2Echo ${harvestname[${tempvar}]}: ${HarvestNode[${tempvar}]}
				}
			}
			else
			{
				HarvestNode[${tempvar}]:Set[Unknown]
				HarvestType[${tempvar}]:Set[0]
			}
		}
		else
		{
			HarvestNode[${tempvar}]:Set[Unknown]
		}
	}
	while "${tempvar:Inc}<=10"

	; Define the ability that is used to harvest each node
	; Note: Using the actual skillsets instead of the 'Use' key to limit use of keypresses.
	HarvestTool[1]:Set[Mining]
	HarvestTool[2]:Set[Mining]
	HarvestTool[3]:Set[Foresting]
	HarvestTool[4]:Set[Gathering]
	HarvestTool[5]:Set[Trapping]
	HarvestTool[6]:Set[Gathering]
	HarvestTool[7]:Set[Gathering]
	HarvestTool[8]:Set[Fishing]
	HarvestTool[9]:Set[Collecting]
	HarvestTool[10]:Set[Foresting]

	maxroaming:Set[${SettingXML[${configfile}].Set[Roaming Values].GetInt[${Zone.ShortName},80]}]
}

function InitTriggers()
{
	; Add our trigger for nodes that are too far away or cannot harvest from.
	AddTrigger InvalidNode "@*@Too far away@*@"
	AddTrigger InvalidNode "@*@You cannot@*@"

	; Add trigger for inventory full
	AddTrigger InventoryFull "@*@inventory is currently full."

	; Add GM/CS TELL triggers
	AddTrigger GMDetected "@*@GM.@*@tells you@*@"
	AddTrigger GMDetected "@*@CS.@*@tells you@*@"
	AddTrigger GMDetected "\\aPC @*@ @*@:@sender@\\/a tells you@*@GM@*@"

	if ${displaystats}
	{
		; Add Harvest triggers
		AddTrigger Harvested "Announcement::You have @action@:@result@"
		AddTrigger Harvested "Announcement::You have fi@action@hed@result@"
		AddTrigger Rare "Announcement::Rare item found!@rare@"
		AddTrigger Collectible "Announcement::Collectible found!@result@"
	}
	else
	{
		harvestcnt:Inc
	}
}

function InitHud()
{
	tempvar:Set[1]

	squelch HUD -Add Direction ${HudX},${HudY:Inc[30]} "Current Destination: \${NavPath.PointName[${NavPath.Points}]}"
	squelch HUD -Add CurrentHarvest ${HudX},${HudY:Inc[15]} "You are currently harvesting: \${closestName}"

	do
	{
		; Add the total HUD after the last common resource node.
		if "${tempvar}==9"
		{
			squelch HUD -Add Totals ${HudX},${HudY:Inc[15]} "Total number of Harvests: \${totalharvest} (Batch: \${totaldestroy}/\${destroybatch})"
			HUDSet Totals -c FFFF00
			HudY:Inc[15]
		}
		if "${HarvestType[${tempvar}]}"
		{
			if "${tempvar}<=9"
			{
				if "!${destroynode[${tempvar}]}"
				{
					squelch execute HUD -Add Stat${tempvar} ${HudX},${HudY:Inc[15]} "\\${harvestname[${tempvar}]}: \\${harveststat[${tempvar}]} *DESTROY*"
				}
				else
				{
					if "${destroynode[${tempvar}]}<500"
					{
						squelch execute HUD -Add Stat${tempvar} ${HudX},${HudY:Inc[15]} "\\${harvestname[${tempvar}]}: \\${harveststat[${tempvar}]} *Keep: \${destroynode[${tempvar}]}*"
					}
					else
					{
						squelch execute HUD -Add Stat${tempvar} ${HudX},${HudY:Inc[15]} "\\${harvestname[${tempvar}]}: \\${harveststat[${tempvar}]}"
					}
				}
			}
			else
			{
				squelch execute HUD -Add Stat${tempvar} ${HudX},${HudY:Inc[15]} "\\${harvestname[${tempvar}]}: \\${harveststat[${tempvar}]}"
			}
		}
		if "${tempvar}>18"
		{
			HUDSet Stat${tempvar} -c FF6E6E
		}
	}
	while "${tempvar:Inc}<=20"
}

function Harvested(string Line, string action, string result)
{
	harvestcnt:Inc
	tempval:Set[${SettingXML[${harvestfile}].Set["harvest list"].GetInt["${result.Right[-1]}"]}]

	if "${Harvested.Find[Glowing]} || ${Harvested.Find[Sparkling]} || ${Harvested.Find[Glimmering]} || ${Harvested.Find[Luminous]} || ${Harvested.Find[Lambent]}"
	{
		tempval:Set[19]
	}

	if !${tempval}
	{
		EQ2Echo Unknown Harvest: ${result} in ${harvestfile}\n >> UnknownHarvest.txt
	}
	else
	{
		harveststat[${tempval}]:Inc
	}
	if "${tempval}<=8"
	{
		totalharvest:Inc
		call checkinventory ${tempval} "${result.Right[-1]}"
	}
}

function Rare(string Line, string rare)
{
	harvestcnt:Inc
	harveststat[20]:Inc
}

function Collectible(string Line, string result)
{
	harvestcnt:Set[4]
	call SearchItems "${result}"

	if ${Return}
	{
		if "${keepcollcur[${Return}]}<${keepcollcnt[${Return}]}"
		{
			harveststat[9]:Inc
			keepcollcur[${Return}]:Inc

			if "${harveststat[9]}>=${destroynode[9]} && ${destroynode[9]}>0"
			{
				HarvestType[9]:Set[0]
			}
		}
		else
		{
			call DestroyItem "${result.Right[-1]}"
		}
	}
	else
	{
		if "!${destroynode[9]}"
		{
			call DestroyItem "${result.Right[-1]}"
		}
		else
		{
			harveststat[9]:Inc
			if "${harveststat[9]}>=${destroynode[9]} && ${destroynode[9]}>0"
			{
				HarvestType[9]:Set[0]
			}
		}
	}
}

function checkinventory(int dnode, string dname)
{
	if "!${dname.Equal[CleanUpOnExit]}"
	{
		keepspec:Set[${SettingXML[${configfile}].Set[RESOURCE name you want to keep and how many].GetInt[${dname}]}]
		totaldestroy:Inc
	}

	if "${destroynode[${dnode}]}<999 || ${keepspec}<999"
	{
		if "!${dname.Equal[CleanUpOnExit]}"
		{
			dnfound:Set[FALSE]

			tempvar:Set[1]
			do
			{
				if "${dname.Equal[${dnnamearr[${tempvar}]}]}"
				{
					dnfound:Set[TRUE]
					break
				}
			}
			while "${tempvar:Inc}<=${dnnamecnt}"

			if !${dnfound}
			{
				dnnamecnt:Inc
				dnnamearr[${dnnamecnt}]:Set[${dname}]
				dncount[${dnnamecnt}]:Set[${keepspec}]
				if !${dncount[${dnnamecnt}]}
				{
					dncount[${dnnamecnt}]:Set[${destroynode[${dnode}]}]
				}
			}
			oldnamecnt:Set[${dnnamecnt}]
		}
		else
		{
			dnnamecnt:Set[${oldnamecnt}]
		}

		if "${totaldestroy}>=${destroybatch} && ${dnnamecnt}>0"
		{
			if "!${dname.Equal[CleanUpOnExit]}"
			{
				announce "Cleaning up Inventory..." 5 4
			}

			wait 20
			tempvar:Set[1]
			do
			{
				Me:CreateCustomInventoryArray[nonbankonly]
				wait 2
				call CountInv "${dnnamearr[${tempvar}]}"
				totalitemdest:Set[${Math.Calc[${itotal}-${dncount[${tempvar}]}]}]
				if "${totalitemdest}>0"
				{
					do
					{
						call FindLowest

						if "${lowestcnt}<=${totalitemdest}"
						{
							if ${foundid[${lowestid}]}
							{
								Me.CustomInventory[${foundid[${lowestid}]}]:Destroy
								totalitemdest:Dec[${lowestcnt}]
								foundcnt[${lowestid}]:Set[0]
							}
						}
						else
						{
							tempchk1:Set[${Me.CustomInventory[${foundid[${lowestid}]}].Slot}]
							tempchk2:Set[${Me.CustomInventory[${foundid[${lowestid}]}].InContainerID}]
							brkcnt:Set[1]
							Me.CustomInventory[${foundid[${lowestid}]}]:Move[NextFreeNonBank,${totalitemdest}]
							do
							{
								wait 2
								Me:CreateCustomInventoryArray[nonbankonly]
								if "${brkcnt:Inc}>20"
								{
									brkcnt:Set[0]
									EQ2Echo Unable to move a Resource: ${Me.CustomInventory[${tempvar}].Name}\n >> HarvestError.txt
									break
								}
							}
							while "${Me.CustomInventory[${tempvar}].Slot}==${tempchk1} && ${Me.CustomInventory[${tempvar}].InContainerID}==${tempchk2}"

							tempvar2:Set[1]
							if ${brkcnt}
							{
								do
								{
									if "${Me.CustomInventory[${tempvar2}].Name.Equal[${dnnamearr[${tempvar}]}]} && ${Me.CustomInventory[${tempvar2}].Quantity}==${totalitemdest}"
									{
										wait 2
										Me.CustomInventory[${tempvar2}]:Destroy
										break
									}
								}
								while "${tempvar2:Inc}<=${Me.CustomInventoryArraySize}"
								break
							}
						}
					}
					while "${totalitemdest}>0"
				}
			}
			while "${tempvar:Inc}<=${dnnamecnt}"
			totaldestroy:Set[0]

			dnnamecnt:Set[0]
		}
	}
}

function FindLowest()
{
	declare xvar int local

	lowestcnt:Set[${foundcnt[1]}]
	lowestid:Set[1]
	xvar:Set[0]
	do
	{
		if ${stackcnt}>1
		{
			if "${foundcnt[${xvar}]} && ${foundcnt[${xvar}]}<=${lowestcnt}"
			{
				lowestcnt:Set[${foundcnt[${xvar}]}]
				lowestid:Set[${xvar}]
			}
		}
	}
	while ${xvar:Inc}<=${stackcnt}
}

function CountInv(string citem)
{
	declare xvar int local

	xvar:Set[1]
	itotal:Set[0]
	stackcnt:Set[0]

	do
	{
		if "${Me.CustomInventory[${xvar}].Name.Equal[${citem}]}"
		{
			stackcnt:Inc
			foundid[${stackcnt}]:Set[${xvar}]
			foundcnt[${stackcnt}]:Set[${Me.CustomInventory[${xvar}].Quantity}]
			itotal:Inc[${Me.CustomInventory[${xvar}].Quantity}]
		}
	}
	while "${xvar:Inc}<=${Me.CustomInventoryArraySize}"
}

function SearchItems(string pitemsearch)
{
	tempvar:Set[1]
	do
	{
		if "${pitemsearch.Find[${keepcollnme[${tempvar}]}]}"
		{
			return ${tempvar}
		}
	}
	while "${tempvar:Inc}<=${itemcount}"

	return 0
}

function DestroyItem(string pitemsearch)
{
	wait 20
	tempvar:Set[1]
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 2
	do
	{
		if "${Me.CustomInventory[${tempvar}].Name.Equal[${pitemsearch}]}"
		{
			tempchk1:Set[${Me.CustomInventory[${tempvar}].Slot}]
			tempchk2:Set[${Me.CustomInventory[${tempvar}].InContainerID}]
			brkcnt:Set[1]
			tempvar2:Set[1]
			Me.CustomInventory[${tempvar}]:Move[NextFreeNonBank,1]
			do
			{
				wait 2
				Me:CreateCustomInventoryArray[nonbankonly]
				if "${brkcnt:Inc}>20"
				{
					brkcnt:Set[0]
					EQ2Echo Unable to move a Collect: ${Me.CustomInventory[${tempvar}].Name}\n >> HarvestError.txt
					return
				}
			}
			while "${Me.CustomInventory[${tempvar}].Slot}==${tempchk1} && ${Me.CustomInventory[${tempvar}].InContainerID}==${tempchk2}"

			do
			{
				if "${Me.CustomInventory[${tempvar2}].Name.Equal[${pitemsearch}]} && ${Me.CustomInventory[${tempvar2}].Quantity}==1"
				{
					wait 2
					Me.CustomInventory[${tempvar2}]:Destroy
					return
				}
			}
			while "${tempvar2:Inc}<=${Me.CustomInventoryArraySize}"
		}
	}
	while "${tempvar:Inc}<=${Me.CustomInventoryArraySize}"
}

function atexit()
{
	if ${displaystats}
	{
		squelch HUD -remove CurrentHarvest
		squelch HUD -remove Direction
		squelch HUD -remove Totals
		squelch HUD -remove Stat1
		squelch HUD -remove Stat2
		squelch HUD -remove Stat3
		squelch HUD -remove Stat4
		squelch HUD -remove Stat5
		squelch HUD -remove Stat6
		squelch HUD -remove Stat7
		squelch HUD -remove Stat8
		squelch HUD -remove Stat9
		squelch HUD -remove Stat10
		squelch HUD -remove Stat19
		squelch HUD -remove Stat20
	}

	squelch HUD -remove FunctionKey1
	squelch bind -delete quit

	press MOVEBACKWARD

	totaldestroy:Set[${destroybatch}]
	destroynode[10]:Set[0]

	announce "Cleaning up Inventory before exiting..." 5 4
	call checkinventory 10 "CleanUpOnExit"

	if !${resetconf}
	{
		tempvar:Set[1]

		EQ2Echo Summary of Harvests is as follows...\n > "Harvest Summary.txt"

		do
		{
			if "${tempvar}==9"
			{
				EQ2Echo Total number of Harvests: ${totalharvest}\n >> "Harvest Summary.txt"
			}

			if "${harveststat[${tempvar}](bool)}"
			{
				EQ2Echo ${harvestname[${tempvar}]}: ${harveststat[${tempvar}]}\n >> "Harvest Summary.txt"
			}
		}
		while "${tempvar:Inc}<=20"
	}

	SettingXML[${configfile}]:Unload
	SettingXML[${harvestfile}]:Unload

	DeleteVariable harveststat
	DeleteVariable harvestname
	DeleteVariable checkend
	DeleteVariable closestName
	DeleteVariable totalharvest
	DeleteVariable totaldestroy
	DeleteVariable destroybatch
}

function checkkeys()
{
	if "${checkend(bool)}"
	{
		Script:End
	}

	if "${Math.Calc[${Time.Timestamp}-${timer}]}>${Math.Calc[${timerval}*60]} && ${timerval}"
	{
		wait 20
		if ${howtoquit}
		{
			timed 100 EQ2Execute /camp desktop
		}
		Script:End
	}
}

function PCDetect()
{
	; Check to see if there is any PC near it
	nodedistME:Set[${Math.Distance[${closestX},${closestZ},${Me.X},${Me.Z}]}]
	PCID:Set[${Actor[PC,radiusr,${Math.Calc[${nodedistME}-20]},${Math.Calc[${nodedistME}+20]}].ID}]

	if ${PCID}
	{
		if "${Math.Distance[${closestX},${closestZ},${Actor[${PCID}].X},${Actor[${PCID}].Z}]}<10"
		{
			call SetBadNode
			return "DETECTED"
		}
	}
	return "NOTDETECTED"
}

function SetBadNode()
{
	badnodedetected:Set[0]
	badnodecount:Inc
	if "${badnodecount}>4"
	{
		badnodecount:Set[1]
	}
	BadNode[${badnodecount}]:Set[${closestID}]
}

function InitConfig()
{
	tempvar:Set[1]
	do
	{
		destroynode[${tempvar}]:Set[${SettingXML[${configfile}].Set[Keep how many resources from each node?].GetInt[${harvestname[${tempvar}]},999]}]
	}
	while "${tempvar:Inc}<=9"

	if "!${SettingXML[${configfile}].Set[RESOURCE name you want to keep and how many].Keys}"
	{
		keepspec:Set[${SettingXML[${configfile}].Set[RESOURCE name you want to keep and how many].GetInt[insert resource name here,60]}]
	}

	itemcount:Set[${SettingXML[${configfile}].Set[COLLECTIBLE name you want to keep and how many].Keys}]
	if "!${itemcount}"
	{
		keepcollcnt[1]:Set[${SettingXML[${configfile}].Set[COLLECTIBLE name you want to keep and how many].GetInt[insert collectible name here,50]}]
	}
	else
	{
		tempvar:Set[1]
		do
		{
			keepcollnme[${tempvar}]:Set[${SettingXML[${configfile}].Set[COLLECTIBLE name you want to keep and how many].Key[${tempvar}]}]
			keepcollcnt[${tempvar}]:Set[${SettingXML[${configfile}].Set[COLLECTIBLE name you want to keep and how many].GetInt[${keepcollnme[${tempvar}]}]}]
		}
		while "${tempvar:Inc}<=${itemcount}"
	}

	; Pathroute is defined as follows
	; 1 - Navigational path from the nearest point to the End Point.
	; 2 - Navigational path from the nearest point to the End Point and back to the Start Point.
	; 3 - Navigational path from the nearest point and then loops to the End Point and back to the Start Point.
	pathroute:Set[${SettingXML[${configfile}].Set[General Settings].GetInt["Pathing Route (1=1 way, 2=To and Back, 3=Continous loop",3]}]
	displaystats:Set[${SettingXML[${configfile}].Set[General Settings].GetInt["Display Stats on HUD? (0=no or 1=yes)",1]}]
	endkey:Set[${SettingXML[${configfile}].Set[General Settings].GetString["Exit Script Function Key","F11"]}]
	squelch bind quit ${endkey} "checkend:Set[1]"

	; This sets the co-ordinates for where the HUD will be displayed.
	; You can move the mouse to where you want the HUD to be, and just 'echo $[Mouse.X} ${Mouse.Y}' on the console
	; to get the coordinates.
	HudX:Set[${SettingXML[${configfile}].Set[General Settings].GetInt["Hud Display at X Co-ordinate",5]}]
	HudY:Set[${SettingXML[${configfile}].Set[General Settings].GetInt["Hud Display at Y Co-ordinate",55]}]

	timerval:Set[${SettingXML[${configfile}].Set[General Settings].GetInt["Harvest Timer",0]}]
	if "${timerval}>0"
	{
		timer:Set[${Time.Timestamp}]
	}
	howtoquit:Set[${SettingXML[${configfile}].Set[General Settings].GetInt["0-end script or 1-Camp to desktop",1]}]
	destroybatch:Set[${SettingXML[${configfile}].Set[General Settings].GetInt[Nodes to Harvest before Destroying?,200]}]
	harvestclose:Set[${SettingXML[${configfile}].Set[General Settings].GetInt[Distance for the bot to move outside the max roaming range?,15]}]
	intrdetect:Set[${SettingXML[${configfile}].Set[General Settings].GetInt[Do you want to detect for BOT POLICE following YOU? (0=no or 1=yes),0]}]
	intraction:Set[${SettingXML[${configfile}].Set[General Settings].GetInt[If intruder detected - Stand there (0) or keep moving (1) till he goes?,1]}]

	nBlackList:Set[${SettingXML[${configfile}].Set[Bot Police Detection - BLACK LIST].Keys}]

	if !${nBlackList}
	{
		BlackList[1]:Set[${SettingXML[${configfile}].Set[Bot Police Detection - BLACK LIST].GetString[1,"Bot Police"]}]
	}
	else
	{
		tempvar:Set[1]
		do
		{
			BlackList[${tempvar}]:Set[${SettingXML[${configfile}].Set[Bot Police Detection - BLACK LIST].GetString[${tempvar}]}]
		}
		while "${tempvar:Inc}<=${nBlackList}"
	}

	nFriendsList:Set[${SettingXML[${configfile}].Set[Bot Police Detection - FRIENDS LIST].Keys}]
	if !${nFriendsList}
	{
		FriendsList[1]:Set[${SettingXML[${configfile}].Set[Bot Police Detection - FRIENDS LIST].GetString[1,"My Friend"]}]
	}
	else
	{
		tempvar:Set[1]
		do
		{
			FriendsList[${tempvar}]:Set[${SettingXML[${configfile}].Set[Bot Police Detection - FRIENDS LIST].GetString[${tempvar}]}]
		}
		while "${tempvar:Inc}<=${nFriendsList}"
	}

	SettingXML[${configfile}]:Save
}

function stuckstate()
{
	NavPath:Clear

	; Re-create the nav path and move to the nearest navpoint
	NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

	if ${pathdirection}
	{
		squelch NavPath "${World}" "${NearestPoint}" "${EndPoint}"
	}
	else
	{
		squelch NavPath "${World}" "${NearestPoint}" "${StartPoint}"
	}

	WPX:Set[${NavPath.Point[1].X}]
	WPZ:Set[${NavPath.Point[1].Z}]
	call moveto ${WPX} ${WPZ} 5

	; Are we still Stuck?
	if "${Return.Equal[STUCK]}"
	{
		; Looks like we are stuck again. end script...
		EQ2Echo We are stuck! Ending script...
		if ${howtoquit}
		{
			timed 100 EQ2Execute /camp desktop
		}
		Script:End
	}
	else
	{
		press MOVEFORWARD
		pathindex:Set[1]
	}
}

function CheckIntruder()
{
	declare tcount int local 1
	declare tmpcnt int local

	if !${Actor[PC,range,30].ID}
	{
		return
	}

	EQ2:CreateCustomActorArray[byDist,30]

	do
	{
		intrstatus:Set[0]
		if ${CustomActor[${tcount}].Type.Equal[PC]} && ${CustomActor[${tcount}].ID}
		{
			tmpcnt:Set[1]
			do
			{
				if "${CustomActor[${tcount}].Name.Equal[${FriendsList[${tmpcnt}]}]}"
				{
					intrstatus:Set[2]
					break
				}
			}
			while ${tmpcnt:Inc}<=${nFriendList}

			if ${intrstatus}
			{
				break
			}

			tmpcnt:Set[1]
			do
			{
				if "${CustomActor[${tcount}].Name.Equal[${BlackList[${tmpcnt}]}]}"
				{
					EQ2Echo Intruder Detected: ${BlackList[${tmpcnt}]}
					intrstatus:Set[1]
					return
				}
			}
			while ${tmpcnt:Inc}<=${nBlackList}

			if ${intrstatus}
			{
				continue
			}

			tmpcnt:Set[1]
			do
			{
				if "${CustomActor[${tcount}].Name.Equal[${IntruderList[${tmpcnt}]}]}"
				{
					if ${IntruderCount[${tmpcnt}]}>4
					{
						if ${Math.Calc[${Time.Timestamp}-${IntruderTimer[${tmpcnt}]}]}<600
						{
							nBlackList:Inc
							BlackList[${nBlackList}]:Set[${SettingXML[${configfile}].Set[Bot Police Detection - BLACK LIST].GetString[${nBlackList},${IntruderList[${tmpcnt}]}]}]
							SettingXML[${configfile}]:Save
							intrstatus:Set[1]
							EQ2Echo Intruder Detected and Black Listed: ${IntruderList[${tmpcnt}]}
							return
						}
						else
						{
							IntruderTimer[${tmpcnt}]:Set[${Time.Timestamp}]
							IntruderCount[${tmpcnt}]:Set[1]
							intrstatus:Set[3]
						}
					}
					else
					{
						IntruderCount[${tmpcnt}]:Inc
						intrstatus:Set[3]
					}
				}
			}
			while ${tmpcnt:Inc}<=${nIntruderList}

			if ${intrstatus}
			{
				continue
			}

			tmpcnt:Set[1]
			do
			{
				if ${Math.Calc[${Time.Timestamp}-${IntruderTimer[${tmpcnt}]}]}>600
				{
					IntruderList[${tmpcnt}]:Set[${CustomActor[${tcount}].Name}]
					IntruderTimer[${tmpcnt}]:Set[${Time.Timestamp}]
					IntruderCount[${tmpcnt}]:Set[1]
					intrstatus:Set[3]
					break
				}
			}
			while ${tmpcnt:Inc}<=${nIntruderList}

			if ${intrstatus}
			{
				continue
			}

			nIntruderList:Inc

			IntruderList[${nIntruderList}]:Set[${CustomActor[${tcount}].Name}]
			IntruderTimer[${nIntruderList}]:Set[${Time.Timestamp}]
			IntruderCount[${nIntruderList}]:Set[1]
			return
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}
}

function AvoidAction()
{
	declare tcount int local 1
	declare tmpcnt int local

	if !${Me.ToActor.IsAFK} && !${intraction}
	{
		EQ2Execute /afk
		wait 20
	}

	if ${Actor[PC,range,50].ID}
	{
		EQ2:CreateCustomActorArray[byDist]

		do
		{
			if ${CustomActor[${tcount}].Distance}>50
			{
				break
			}

			if ${CustomActor[${tcount}].Type.Equal[PC]} && ${CustomActor[${tcount}].ID}
			{
				tmpcnt:Set[1]
				do
				{
					if "${CustomActor[${tcount}].Name.Equal[${BlackList[${tmpcnt}]}]}"
					{
						intrtimer:Set[${Time.Timestamp}]
						closestName:Set["*** Intruder Detected: ${BlackList[${tmpcnt}]} ***"]
						break
					}
				}
				while ${tmpcnt:Inc}<=${nBlackList}
			}
		}
		while ${tcount:Inc}<${EQ2.CustomActorArraySize}
	}

	if ${Math.Calc[${Time.Timestamp}-${intrtimer}]}>60
	{
		isintruder:Set[FALSE]
		intrstatus:Set[0]
	}
}