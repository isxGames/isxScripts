
#ifndef _moveto_
	#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"
#endif

#ifndef _golavnav_
	#include "${LavishScript.HomeDirectory}/Scripts/GoHarvest/golavnav.iss"
#endif

variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/GoHarvest/"

variable filepath HarvestFile="${ConfigPath}Harvest.xml"


variable bool HarvestNode[10]=TRUE
variable bool HBlocked[2]=FALSE
variable bool pauseharvest=TRUE
variable bool StrictLos=TRUE
variable bool Mapping=FALSE
variable bool MaxDistance=FALSE
variable bool NoSkill=FALSE

variable GoHarvestBot GoHarvest
variable int scan=150
variable int HID
variable int NodeType
variable bool BadNode=FALSE
variable collection:string BadNodes
variable float SX
variable float SZ

variable settingsetref harvest
variable settingsetref harvesttype

variable string MiscNode
variable string World=${Zone.ShortName}
variable filepath NavFile=${ConfigPath}${World}.xml
variable string Region
variable string Container

function main()
{
	GoHarvest:Init
	GoHarvest:InitMap
	GoHarvest:InitTriggersAndEvents
	GoHarvest:LoadUI
	
	While 1
	{
		do
		{
			ExecuteQueued
			waitframe

			If ${Mapping}
				call AutoBox 2

		}
		while ${pauseharvest}|| ${Me.Health}<90
		scan:Set[${UIElement[GoHarvest].FindChild[GUITabs].FindChild[Harvest].FindChild[ScanArea].Text}]

		if ${scan} <0 || ${scan} > 300
			scan:Set[150]

		Echo Scanning ${scan} units
		call startharvest ${scan}
	}
}

function startharvest(int scan)
{
	variable int harvestcount
	variable index:actor Actors
	variable iterator ActorIterator
	variable string actorname

	variable int tempvar
	
	SX:Set[${Me.X}]
	SZ:Set[${Me.Z}]
	
	While 1
	{
		if ${pauseharvest}
		{
			break
		}
		if !${Me.InCombat} && ${Me.Health}>90
		{
			if ${MaxDistance}
			{
				EQ2:QueryActors[Actors, Type =- "Resource" && Distance <= ${Math.Calc[${scan}*2]}]
			}
			else
			{
				EQ2:QueryActors[Actors, Type =- "Resource" && Distance <= ${scan}]
			}

			Actors:GetIterator[ActorIterator]
			harvestcount:Set[${Actors.Used}]

			if ${ActorIterator:First(exists)}
			{
				do
				{	
					if ${ActorIterator.Value.Name(exists)}
					{
						actorname:Set[${ActorIterator.Value.Name}]
						tempvar:Set[1]
						do
						{
							if ${MaxDistance} 
							{
								if ${Math.Distance[${ActorIterator.Value.X},${SX}]} > ${scan} || ${Math.Distance[${ActorIterator.Value.Z},${SZ}]} > ${scan}
								{
									break
								}
								else
								{
									UIElement[XDistance@Harvest@GUITabs@GoHarvest]:SetText[${Math.Distance[${ActorIterator.Value.X},${SX}]}]
									UIElement[ZDistance@Harvest@GUITabs@GoHarvest]:SetText[${Math.Distance[${ActorIterator.Value.Z},${SZ}]}]
								}
							}
							if ${HarvestNode[${tempvar}]}
							{
								call checknodename ${tempvar} "${actorname}"
								if ${Return}
								{
									if ${ActorIterator.Value.Name(exists)}
									{
										HID:Set[${ActorIterator.Value.ID}]
										if !${BadNodes.Element[${ActorIterator.Value.ID}].Name(exists)}
										{
											BadNode:Set[FALSE]
											call harvestnode
											if !${Return.Equal["STUCK"]}
											{
												if ${MaxDistance}
												{
													EQ2:QueryActors[Actors, Type =- "Resource" && Distance <= ${Math.Calc[${scan}*2]}]
												}
												else
												{
													EQ2:QueryActors[Actors, Type =- "Resource" && Distance <= ${scan}]
												}
												waitframe
												Actors:GetIterator[ActorIterator]
												harvestcount:Set[${Actors.Used}]
												if ${ActorIterator:First(exists)}
													continue
												else
													break
											}
										}
									}
									break
								}
							}
						}
						while ${tempvar:Inc} <=10
					}
					if ${pauseharvest} || ${Me.InCombat} || ${Me.Health}<90
					break
				}
				while ${ActorIterator:Next(exists)}
			}
		}
	}
}

function checknodename(int tempvar, string actorname)
{
	variable string match
	variable string miscnode=${UIElement[MiscNode@Harvest@GUITabs@GoHarvest].Text}
	
	if ${tempvar} == 10 && ${actorname.Equal[${miscnode}]}
	{
		Return TRUE
	}
	else
	{
		harvesttype:Set[${LavishSettings[goharvest].FindSet[${tempvar}]}]
		match:Set[${harvesttype.FindSetting[${actorname}]}]

		if !${match.Equal[NULL]}
		{
			NodeType:Set[${tempvar}]
			Return TRUE
		}
	}

	Return FALSE
}

function harvestnode()
{
	if !${Me.InCombat}
	{
		; check node is not too high or too low (avoids running off islands etc)
		if ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]} <= 30
		{
			call checkPC ${HID}
			if ${Return}
				return STUCK

			if ${Math.Distance[${Actor[${HID}].X},${Me.X}]} <= 4 && ${Math.Distance[${Actor[${HID}].Z},${Me.Z}]} <=4
			{
				call checkPC

				if ${Return}
					Return STUCK

				Actor[${HID}]:DoTarget
				wait 5
				call hitnode ${HID}
			}
			else
			{
				; check route to node
				if !${Me.InCombat}
				{
					Echo checking route to ->  ${HID} : ${Actor[${HID}]}
					;  check area around the node
					call LOScircle TRUE ${Actor[${HID}].X} ${Math.Calc[${Actor[${HID}].Y}+2]} ${Actor[${HID}].Z} 30
					
					if ${Return.Equal["STUCK"]}
					{
						Return STUCK
						;  check area around the character
						call LOScircle FALSE ${Actor[${HID}].X} ${Math.Calc[${Actor[${HID}].Y}+2]} ${Actor[${HID}].Z} 30
					}

				}
				else
				{
					Return
				}
		
				if ${Return.Equal["STUCK"]}
				{
					return STUCK
				}
				else 
				{
					call checkPC
					if ${Return}
						Return
					
;					echo Distance to node is ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]}
					 if ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]} > 5
					{
						echo Distance to node is ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]}
						GoHarvest:SetBadNode[${HID}]  
						BadNode:Set[TRUE]
						return STUCK
					}
					
					Actor[${HID}]:DoTarget
					wait 5
					call hitnode ${HID}
				}
			}
		}
	}
}

function hitnode(float HID)
{
	variable int hitcount
	hitcount:Set[0]
	; while the target exists
	do
	{
		; Make sure not in combat
		do
		{
			waitframe
		}
		while ${Me.InCombat}
		
		waitframe
		Target:DoubleClick
		wait 20
		
		if ${NoSkill}
		{
			NoSkill:Set[FALSE]
			HarvestNode[${NodeType}]:Set[FALSE]
			UIElement[${NodeType}@Harvest@GUITabs@GoHarvest]:UnsetChecked
		}
		
		if ${BadNode}
			return STUCK
		
		while ${Me.CastingSpell}
			waitframe
	}
	while ${Target(exists)} && ${hitcount:Inc} <50
}

function checkPC()
{
	variable index:actor Actors
	variable iterator ActorIterator

	EQ2:QueryActors[Actors, Type =- "PC" && Distance <= 9]
	Actors:GetIterator[ActorIterator]

	if ${ActorIterator:First(exists)}
	{
		do
		{	
			if !${ActorIterator.Value.Name.Equal[${Me.Name}]}
			{
				if !${Me.Group[${ActorIterator.Value.Name}].Name(exists)}
				{
					if ${Math.Distance[${Actor[${HID}].X},${ActorIterator.Value.X}]} <= 7 && ${Math.Distance[${Actor[${HID}].Z},${ActorIterator.Value.Z}]} <= 7
					{
						; non-grouped PC near a node - ignore it and move on
						Echo Someone at that node - ignore
						return TRUE
					}
				}
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	return FALSE
}

function LOScircle(bool node,float CX, float CY, float CZ, int distancecheck)
{
	
	; variable used to calculate angle around circumfrence
	variable int counter

	; angle of the point on the circle
	variable float cx

	; temporary variable to calculate angle points on circumfrence
	variable int tx	
	
	; x and z location of the point on the circumfrence
	variable float px
	variable float pz

	; distance from point (node or char)
	variable float cr
	
	; loop control variable
	
	variable int cloop
	if ${node}
	{
		Echo Checking area around node
		cx:Set[${Actor[${HID}].HeadingTo}]
	}
	else
	{
		Echo Checking area around character
		cx:Set[${Actor[${HID}].HeadingTo}]
		cx:Inc[-180]
		if ${cx} <0
		{
			cx:Inc[360]
		}
	}
	
	; start at angle + 0 shift (Direct Line to item)
	counter:Set[0]
	do
	{
		; set initial distance of 2 units
		cr:Set[2]
		do
		{
			cloop:Set[1]
			do
			{
				if !${HBlocked[${cloop}]}
				{
					if ${cloop} == 1
					{
						; check clockwise from point along circumfrence from node/char
						tx:Set[${Math.Calc[${cx}+(2*${counter})]}]
						
						if ${tx} > 360
							tx:Dec[360]
					}
					else
					{
						; otherwise check anti-clockwise along circumfrence from node/char
						tx:Set[${Math.Calc[${cx}-(2*${counter})]}]
					
						if ${tx} < 0
							tx:Inc[360]
					}
					; calculate the x,y point on the circumfrence
					px:Set[${Math.Calc[${cr} * ${Math.Cos[${tx}]}]}]
					pz:Set[${Math.Calc[${cr} * ${Math.Sin[${tx}]}]}]
		
					if ${node}
					{
						; Add it to the node location to give the mid-loc
						px:Inc[${CX}]
						pz:Inc[${CZ}]
					}
					else
					{
						; Add it to the characters location to give the mid-loc
						px:Inc[${Me.X}]
						pz:Inc[${Me.Z}]
					}
					
					; make sure that mid-point isn't marked as 'bad'
					
					; check to make sure location hasn't been blocked by user
					call FindClosestPoint ${px} ${Me.Y} ${pz} 
											
					; Universe = no area set to blocked
					if ${Return.Equal[Universe]}
					{
						; check to see if mid-point is available
						if !${EQ2.CheckCollision[${Me.X},${Me.Y},${Me.Z},${px},${CY},${pz}]} || !${EQ2.CheckCollision[${Me.X},${Me.Y},${Me.Z},${px},${Math.Calc[${CY}+1]},${pz}]}
						{	
							if ${Actor[${HID}].Name(exists)}
							{
								; check to see if there is LOS from that mid-loc to the node
								if !${EQ2.CheckCollision[${px},${CY},${pz},${CX},${CY},${CZ}]} || !${EQ2.CheckCollision[${px},${CY},${pz},${CX},${Math.Calc[${CY}+1]},${CZ}]}
								{
		
									; check nobody at that node
									call checkPC ${HID}
									if ${Return}
										return STUCK
		
									Echo Moving to ${CX},${CZ} via ${px},${pz}
									call moveto ${px} ${pz} 2 0 3 1
									waitframe
									
									; check still nobody at that node
									call checkPC ${HID}
	
									if ${Return}
										return STUCK
										
										if (${Actor[${HID}].Name.Equal[?]} || ${Actor[${HID}].Name.Equal[!]})
										    	call moveto ${CX} ${CZ} 3 0 3 1
										else
											call moveto ${CX} ${CZ} 4 0 3 1
	
										Return THERE
								}
							}
						}
						else
						{
							; if setting for enforce Line Of Sight is ON then stop scanning along that line
							if ${StrictLos}
							{
								; Route via that angle is blocked , stop checking along that line.
								HBlocked[${cloop}]:Set[TRUE]
							}
						}
					}
					else
					{
						if ${StrictLos}
						{
							; Route via that angle is blocked , stop checking along that line.
							HBlocked[${cloop}]:Set[TRUE]
						}
					}
				}
			}
			while ${cloop:Inc}<=2
			
			; if both > and < angles from node are blocked then no point looking further along those routes
			; exit loop and increase angles
			if ${HBlocked[1]} && ${HBlocked[2]} 
				break
		}
		
		; Expand the length of the lines being checked
		while ${cr:Inc[1]} <=${distancecheck}
		
		; Reset blocked flags
		HBlocked[1]:Set[FALSE]
		HBlocked[2]:Set[FALSE]

	}
	; add 1 shift (2 degrees)
	while ${counter:Inc} <= 89
	; all angles all distances checked - no LOS
	return STUCK
}

function checkblocked()
{
	Declare nodedist float
	Declare nodeangle float
	
	nodedist:Set[${Actor[${HID}].Distance}]
	nodeangle:Set[${Actor[${HID}].HeadingTo}]
	
	echo node is ${nodedist} at angle ${nodeangle}
	Return FALSE

}


objectdef GoHarvestBot
{
	method Init()
	{
		LavishSettings:AddSet[goharvest]
		LavishSettings[goharvest]:Import[${HarvestFile}]
	}

	method InitTriggersAndEvents()
	{
		Event[EQ2_onLootWindowAppeared]:AttachAtom[EQ2_onLootWindowAppeared]
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
		; Harvest triggers
		; AddTrigger Harvested "Announcement::You have @action@:\n@number@ @result@"
		; AddTrigger Harvest:Rare "Announcement::Rare item found!\n@rare@"

	}

	method LoadUI()
	{
		; Load the UI Parts
		;
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/EQ2.xml"
		ui -reload -skin eq2 "${ConfigPath}GoHarvestUI.xml"
		return
	}
	method SetBadNode(string badnodeid)
	{
	    	echo  Adding (${badnodeid},${Actor[id,${badnodeid}].Name}) to the BadNodes list
		BadNodes:Set[${badnodeid},${Actor[id,${badnodeid}].Name}]

		echo BadNodes now has ${BadNodes.Used} nodes in it.	    
	}
	method InitMap()
	{
		LavishNav:Clear
		if ${ConfigPath.FileExists[${World}.xml]}
			{
				LavishNav.Tree:Import[${NavFile}]
				echo Loaded ${NavFile} with ${LNavRegion[${World}].ChildCount} children
			}
			else
			{
				echo Creating New Zone
				LavishNav.Tree:AddChild[universe,${World},-unique]
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
    ; deal with collectibles
    if (${gNodeName.Equal[?]} || ${gNodeName.Equal[!]})
        Harvest:CollectibleFound[${LootWindow[${ID}].Item[1].Name}] 
    
    ;; if EQ2Bot is running, let IT handle actual looting
    if (${Script[EQ2Bot](exists)})
        return
    
    
    ;; Now do the actual looting
    if ${LootWindow.Type.Equal[Lottery]}
    {
        LootWindow:RequestAll
        return
    }
    elseif ${LootWindow.Type.Equal[Need Before Greed]}
    {
        LootWindow:SelectGreed
        return
    }
    else
    {
        LootWindow:LootItem[1]
        return
    }
    
    
    return    
}

atom atexit()
{
	press -release MOVEFORWARD
	press -release MOVEBACKWARD
	press -release STRAFERIGHT
	press -release STRAFELEFT

	if !${ISXEQ2.IsReady}
	{
		return
	}
	ui -unload "${ConfigPath}GoHarvestUI.xml"
	
	call SavePaths
	LNavRegion[${World}]:Remove

}

atom(script) EQ2_onIncomingText(string Text)
{
	if !${Me.InCombat}
	{
		if ${Text.Find["too far away"]} > 0  && !${BadNode}
		{
			if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
			{
				echo "Node is 'too far away'..."
				GoHarvest:SetBadNode[${HID}]  
				BadNode:Set[TRUE]
			}
		}
		elseif (${Text.Find["Can't see target"]} > 0)  && !${BadNode}
		{
			if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
			{
				echo "Received 'Cant see target' message..."
				GoHarvest:SetBadNode[${HID}]  
				BadNode:Set[TRUE]
			}
		}
		elseif ${Text.Find["You cannot "]} > 0 && !${BadNode}
		{
		    if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
				{
				echo " Received 'You cannot ...' message..."
				GoHarvest:SetBadNode[${HID}]  
				BadNode:Set[TRUE]
			}
		}	
		elseif (${Text.Find["Your target is already in use"]} > 0)  && !${BadNode}
		{
			if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
			{
				echo "Received 'Your target is already in use by someone else' message..."
				GoHarvest:SetBadNode[${HID}]  
				BadNode:Set[TRUE]
			}
		}
		elseif (${Text.Find["not enough skill"]} > 0)  && !${BadNode}
		{
			if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
			{
				echo "Received 'You do not have enough skill' message..."
				NoSkill:Set[TRUE]
				GoHarvest:SetBadNode[${HID}]  
				BadNode:Set[TRUE]
			}
		}
}
}

function CheckAggro()
{
 	;Stop Moving and pause if we have aggro
	if ${MobCheck.Detect}
	{
		Echo Aggro Detected Pausing...
		call StopRunning

		Echo Waiting till aggro gone, and over 90 health...
		do
		{
			waitframe
		}
		while ${MobCheck.Detect} || ${Me.Health}<90

		if ${Actor[chest,radius,15].Name(exists)} || ${Actor[corpse,radius,15].Name(exists)}
		{
			Echo Loot nearby waiting 5 seconds...
			wait 50
		}
	}
}