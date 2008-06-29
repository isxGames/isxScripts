
#ifndef _moveto_
	#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"
#endif


variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/GoHarvest/"

variable bool HarvestNode[9]=TRUE
variable bool pauseharvest=TRUE

variable string NodeName[9]
variable string HarvestFile
variable GoHarvestBot GoHarvest
variable int scan=150
variable int HID
variable bool BadNode=FALSE
variable int BadNodeNo

function main()
{
	GoHarvest:Init
	GoHarvest:InitTriggersAndEvents
	GoHarvest:LoadUI
	While 1
	{
		do
		{
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
								if ${actorname.Equal[${NodeName[${tempvar}]}]}
								{
									if ${CustomActor[${harvestloop}](exists)}
									{
										HID:Set[${CustomActor[${harvestloop}].ID}]
										if !${BadNode} || (${BadNode} && ${HID} != ${BadNodeNo})
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
				return
			}
			if !${EQ2.CheckCollision[${Me.X},${Me.Y},${Me.Z},${Actor[${HID}].X},${Math.Calc[${Actor[${HID}].Y}+2]},${Actor[${HID}].Z}]}
			{
				if !${Me.InCombat}
				{

					echo Moving to ->  ${HID} : ${Actor[${HID}]}
		
					if (${Actor[${HID}].Name.Equal[?]} || ${Actor[${HID}].Name.Equal[!]})
					{
					    	call moveto ${Actor[${HID}].X} ${Actor[${HID}].Z} 3 0 3 1
					}
					else
					{
						call moveto ${Actor[${HID}].X} ${Actor[${HID}].Z} 5 0 3 1
					}
				}
				else
				{
					Return
				}
			}
			else
			{
				if !${Me.InCombat}
				{
					Echo checking alternative route to ->  ${HID} : ${Actor[${HID}]}
					;  check area around the node
					call LOScircle TRUE ${Actor[${HID}].X} ${Math.Calc[${Actor[${HID}].Y}+2]} ${Actor[${HID}].Z}
					
					if ${Return.Equal["STUCK"]}
					{
						;  check area around the character
						call LOScircle FALSE ${Actor[${HID}].X} ${Math.Calc[${Actor[${HID}].Y}+2]} ${Actor[${HID}].Z}
					}
				}
				else
				{
					Return
				}
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
					return
				}
				Actor[${HID}]:DoTarget
				wait 5
				hitcount:Set[0]
				; while the target exists
				while ${Target(exists)} && ${hitcount:Inc} <50
				{
					waitframe
					Target:DoubleClick
					waitframe
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

function LOScircle(bool node,float CX, float CY, float CZ)
{
	
	; variable used to calculate angle around circumfrence
	variable int counter

	; angle of the point on the circle
	variable int cx

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

		cx:Set[${HeadingTo[${Me.X},${Me.Y},${Me.Z},${CX},${CY},${CZ}]}]
	}
	else
	{
		Echo Checking area around character
		cx:Set[${HeadingTo[${CX},${CY},${CZ},${Me.X},${Me.Y},${Me.Z}]}]
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
				if ${cloop} == 1
				{
					; check clockwise from point along circumfrence from node/char
					tx:Set[${Math.Calc[${cx}+(5*${counter})]}]
					
					if ${tx} > 360
						tx:Dec[360]
				}
				else
				{
					; otherwise check anti-clockwise along circumfrence from node/char
					tx:Set[${Math.Calc[${cx}-(5*${counter})]}]
				
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
						Echo Moving to ${CX},${CZ} via ${px},${pz}
						call moveto ${px} ${pz} 2 1 3 1
						waitframe
						call checkPC ${HID}
						if ${Return}
						{
							return
						}
						if (${Actor[${HID}].Name.Equal[?]} || ${Actor[${HID}].Name.Equal[!]})
						{
						    	call moveto ${CX} ${CZ} 3 0 3 1
						}
						else
						{
							call moveto ${CX} ${CZ} 5 0 3 1
						}
						Return THERE
					}
				}
			}
			while ${cloop:Inc}<=2
		}
		; Expand the circle
		while ${cr:Inc[1]} <=50
	}
	; add 1 shift (5 degrees)
	while ${counter:Inc} <= 34
	; all angles all distances checked - no LOS
	return STUCK
}

objectdef GoHarvestBot
{
	method Init()
	{
		variable int tempvar
		HarvestFile:Set[${ConfigPath}Harvest.xml]


		tempvar:Set[1]
		do
		{
			NodeName[${tempvar}]:Set[${SettingXML[${HarvestFile}].Set[${Zone.ShortName}].GetString[${tempvar}]}]
		}
		while ${tempvar:Inc}<=7
		NodeName[8]:Set["?"]
		NodeName[9]:Set["!"]

	}

	method InitTriggersAndEvents()
	{
		Event[EQ2_onLootWindowAppeared]:AttachAtom[EQ2_onLootWindowAppeared]
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
	}

	method LoadUI()
	{
		; Load the UI Parts
		;
		ui -reload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
		ui -reload "${ConfigPath}GoHarvestUI.xml"
		return
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
			BadNode:Set[TRUE]
			BadNodeNo:Set[${HID}]
		}
	}
	elseif (${Text.Find["Can't see target"]} > 0)  && !${BadNode}
	{
		if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
		{
			echo "Received 'Cant see target' message..."
			BadNode:Set[TRUE]
			BadNodeNo:Set[${HID}]
		}
	}
	elseif ${Text.Find["You cannot "]} > 0 && !${BadNode}
	{
	    if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
			{
			echo " Received 'You cannot ...' message..."
			BadNode:Set[TRUE]
			BadNodeNo:Set[${HID}]
		}
	}	
	elseif (${Text.Find["Your target is already in use"]} > 0)  && !${BadNode}
	{
		if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
		{
			echo "Received 'Your target is already in use by someone else' message..."
			BadNode:Set[TRUE]
			BadNodeNo:Set[${HID}]
		}
	}
	elseif (${Text.Find["not enough skill"]} > 0)  && !${BadNode}
	{
		if ${Actor[id,${HID}].Type.Equal[Resource]} && !${Me.InCombat}
		{
			echo "Received 'You do not have enough skill' message..."
			BadNode:Set[TRUE]
			BadNodeNo:Set[${HID}]
		}
	}
}