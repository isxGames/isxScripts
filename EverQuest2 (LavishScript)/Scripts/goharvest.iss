
#ifndef _moveto_
	#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"
#endif


variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/GoHarvest/"

variable filepath HarvestFile="${ConfigPath}Harvest.xml"


variable bool HarvestNode[9]=TRUE
variable bool HBlocked[2]=FALSE
variable bool pauseharvest=TRUE

variable GoHarvestBot GoHarvest
variable int scan=150
variable int HID
variable bool BadNode=FALSE
variable collection:string BadNodes

variable settingsetref harvest
variable settingsetref harvesttype

function main()
{
	GoHarvest:Init
	GoHarvest:InitTriggersAndEvents
	GoHarvest:LoadUI
	
	While 1
	{
		do
		{
			ExecuteQueued
			waitframe
		}
		while ${pauseharvest}
		scan:Set[${UIElement[GoHarvest].FindChild[GUITabs].FindChild[Harvest].FindChild[ScanArea].Text}]
		if ${scan} <0 || ${scan} > 300
		{
			scan:Set[150]
		}
		Echo Scanning ${scan} units
		call startharvest ${scan}
	}
}

function startharvest(int scan)
{
	variable int harvestcount
	variable int harvestloop
	variable string actorname

	variable int tempvar
	While 1
	{
		if ${pauseharvest}
		{
			break
		}
		if !${Me.InCombat}
		{
			EQ2:CreateCustomActorArray[byDist,${scan}]
			harvestloop:Set[1]
			harvestcount:Set[${EQ2.CustomActorArraySize}]
			do
			{
				if ${CustomActor[${harvestloop}](exists)}
				{
					actorname:Set[${CustomActor[${harvestloop}]}]
					if ${CustomActor[${harvestloop}].Type.Equal[resource]} && !${actorname.Equal[NULL]}
					{
						tempvar:Set[1]
						do
						{
							if ${HarvestNode[${tempvar}]}
							{
								call checknodename ${tempvar} "${actorname}"
								if ${Return}
								{
									if ${CustomActor[${harvestloop}](exists)}
									{
										HID:Set[${CustomActor[${harvestloop}].ID}]
										if !${BadNodes.Element[${CustomActor[${harvestloop}].ID}](exists)}
										{
											BadNode:Set[FALSE]
											call harvestnode
											if !${Return.Equal["STUCK"]}
											{
												EQ2:CreateCustomActorArray[byDist,${scan}]
												waitframe
												harvestloop:Set[1]
												harvestcount:Set[${EQ2.CustomActorArraySize}]
											}
										}
									}
									break
								}
							}
						}
						while ${tempvar:Inc} <=9
					}
				}
				if ${pauseharvest} || ${Me.InCombat}
				break
			}
			while ${harvestloop:Inc} <= ${harvestcount}
		}
	}
}

function checknodename(int tempvar, string actorname)
{
	variable string match
	harvesttype:Set[${LavishSettings[goharvest].FindSet[${tempvar}]}]
	match:Set[${harvesttype.FindSetting[${actorname}]}]
	if !${match.Equal[NULL]}
	{
		 Return TRUE
	}
	Return FALSE
}

function harvestnode()
{
	variable int hitcount
	if !${Me.InCombat}
	{
		; check node is not too high or too low (avoids running off islands etc)
		if ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]} <= 30
		{
			call checkPC ${HID}
			if ${Return}
			{
				return STUCK
			}

			; check route to node
			if !${Me.InCombat}
			{
				Echo checking route to ->  ${HID} : ${Actor[${HID}]}
				;  check area around the node
				call LOScircle TRUE ${Actor[${HID}].X} ${Math.Calc[${Actor[${HID}].Y}+2]} ${Actor[${HID}].Z} 30
				
				if ${Return.Equal["STUCK"]}
				{
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
				{
					Return
				}
				
;				echo Distance to node is ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]}
				 if ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]} > 5
				{
					echo Distance to node is ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]}
					GoHarvest:SetBadNode[${HID}]  
					BadNode:Set[TRUE]
					return STUCK
				}
				
				Actor[${HID}]:DoTarget
				wait 5
				hitcount:Set[0]
				; while the target exists
				while ${Target(exists)} && ${hitcount:Inc} <50
				{
					do
					{
						waitframe
					}
					while ${Me.InCombat}
					waitframe
					Target:DoubleClick
					wait 20
					if ${BadNode}
					{
						return STUCK
					}
					while ${Me.CastingSpell}
					waitframe
				}
			}
		}
	}
}

function checkPC()
{
	variable int PCloop=1
	do
	{
		if ${CustomActor[${PCloop}].Type.Equal[PC]} && !${CustomActor[${PCloop}].Name.Equal[${Me.Name}]}
		{
			if !${Me.Group[${CustomActor[${PCloop}].Name}](exists)}
			{
				if ${Math.Distance[${Actor[${HID}].X},${CustomActor[${PCloop}].X}]} <= 7 && ${Math.Distance[${Actor[${HID}].Z},${CustomActor[${PCloop}].Z}]} <= 7
				{
					; non-grouped PC near a node - ignore it and move on
					Echo Someone at that node - ignore
					return TRUE
				}
			}
		}
	}
	while ${PCloop:Inc} <= ${EQ2.CustomActorArraySize}
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
					; check to see if mid-point is available
					if !${EQ2.CheckCollision[${Me.X},${Me.Y},${Me.Z},${px},${CY},${pz}]}
					{	
						; check to see if there is LOS from that mid-loc to the node
						if !${EQ2.CheckCollision[${px},${CY},${pz},${CX},${CY},${CZ}]} && ${Actor[${HID}](exists)}
						{

							; check nobody at that node
							call checkPC ${HID}
							if ${Return}
							{
								return STUCK
							}

							Echo Moving to ${CX},${CZ} via ${px},${pz}
							call moveto ${px} ${pz} 2 0 3 1
							waitframe
							
							; check still nobody at that node
							call checkPC ${HID}
							if ${Return}
							{
								return STUCK
							}
							if (${Actor[${HID}].Name.Equal[?]} || ${Actor[${HID}].Name.Equal[!]})
							{
							    	call moveto ${CX} ${CZ} 3 0 3 1
							}
							else
							{
								call moveto ${CX} ${CZ} 4 0 3 1
							}
							Return THERE
						}
					}
					else
					{
						; Route via that angle is blocked , stop checking along that line.
						HBlocked[${cloop}]:Set[TRUE]
					}
				}
			}
			while ${cloop:Inc}<=2
			
			; if both > and < angles from node are blocked then no point looking further along those routes
			; exit loop and increase angles
			if ${HBlocked[1]} && ${HBlocked[2]} 
			{
				break
			}
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
		ui -reload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
		ui -reload "${ConfigPath}GoHarvestUI.xml"
		return
	}
	method SetBadNode(string badnodeid)
	{
	    	echo  Adding (${badnodeid},${Actor[id,${badnodeid}].Name}) to the BadNodes list
		BadNodes:Set[${badnodeid},${Actor[id,${badnodeid}].Name}]

		echo BadNodes now has ${BadNodes.Used} nodes in it.	    
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
	ui -unload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
	ui -unload "${ConfigPath}GoHarvestUI.xml"
}

atom(script) EQ2_onIncomingText(string Text)
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
			GoHarvest:SetBadNode[${HID}]  
			BadNode:Set[TRUE]
		}
	}
}