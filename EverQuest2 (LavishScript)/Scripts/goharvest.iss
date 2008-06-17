
#ifndef _moveto_
	#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"
#endif
variable int harvestcount
variable int harvestloop
variable string actorname

variable filepath ConfigPath="${LavishScript.HomeDirectory}/Scripts/EQ2Harvest/Harvest Config/"
variable bool HarvestNode[7]
variable string NodeName[7]
variable string HarvestFile
variable GoHarvestBot GoHarvest


function main(int scan, string h0, string h1, string h2, string h3)
{
	GoHarvest:Init
	GoHarvest:InitTriggersAndEvents
	
	if ${h3.Length} > 0
	{
		 call startharvest ${scan} "${h0} ${h1} ${h2} ${h3}"
	}
	elseif ${h2.Length} > 0
	{
		 call startharvest ${scan} "${h0} ${h1} ${h2}"
	}
	elseif ${h1.Length} > 0
	{
		call startharvest  ${scan} "${h0} ${h1}"
	}
	else
	{
		call startharvest  ${scan} "${h0}"
	}
}

function startharvest(int scan, string h1)
{
	if ${h1.Length} >0
	{
		Echo Looking for "${h1}"
	}
	else
	{
		Echo harvesting all nodes
	}
	
	While 1
	{
		if !${Me.InCombat}
		{
			harvestloop:Set[1]
			EQ2:CreateCustomActorArray[byDist,${scan}]
			harvestcount:Set[${EQ2.CustomActorArraySize}]
			do
			{
				actorname:Set[${CustomActor[${harvestloop}]}]
				if ${h1.Length} > 0
				{
					if ${actorname.Equal["${h1}"]} 
					{
						call harvestnode ${CustomActor[${harvestloop}].ID} ${h0}
						if !${Return.Equal["STUCK"]}
						{
							break
						}
					}
				}
				elseif ${CustomActor[${harvestloop}].Type.Equal[resource]}
				{
					call checknode "${actorname}"
					if ${Return}
					{
						call harvestnode ${CustomActor[${harvestloop}].ID} ${h0}
					}
				}
			}
			while ${harvestloop:Inc} <= ${harvestcount}
		}
	}
}

function harvestnode(int HID)
{
	variable int hitcount

	if ${Math.Distance[${Actor[${HID}].Y},${Me.Y}]} <= 30
	{
		call checkPC ${HID}
		if ${Return}
		{
			return
		}
		if ${EQ2.CheckCollision[${Me.X},${Me.Y},${Me.Z},${Actor[${HID}].X},${Math.Calc[${Actor[${HID}].Y}+2]},${Actor[${HID}].Z}]}
		{
			Echo checking alternative route to ->  ${HID} : ${Actor[${HID}]}
			call LOScircle ${Actor[${HID}].X} ${Math.Calc[${Actor[${HID}].Y}+2]} ${Actor[${HID}].Z}
			call checkPC ${HID}
			if ${Return}
			{
				return
			}

		}
		else
		{
			echo Moving to ->  ${HID} : ${Actor[${HID}]}
			call moveto ${Actor[${HID}].X} ${Actor[${HID}].Z} 5 0 3 1
		}
		if ${Return.Equal["STUCK"]}
		{
			return STUCK
		}
		else 
		{
			call checkPC ${HID}
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
				while ${Me.CastingSpell}
				waitframe
			}
		}
	}
}

function checkPC(int HID)
{
	variable int PCloop=1
	do
	{
		waitframe
		if ${CustomActor[${PCloop}].Type.Equal[PC]}
		{
			if ${Math.Distance[${Actor[${HID}].X},${CustomActor[${PCloop}].X}]} <= 7 && ${Math.Distance[${Actor[${HID}].Z},${CustomActor[${PCloop}].Z}]} <= 7
			{
				; PC near a node - ignore it and move on
				Echo Someone at that node - ignore
				return TRUE
			}
		}
	}
	while ${PCloop:Inc} <= ${EQ2.CustomActorArraySize}
	return FALSE
}

function LOScircle(float CX, float CY, float CZ)
{
	
	; angle of the point on the circle
	variable int circleangle=1
	
	; x and z location of the point on the circumfrence
	variable float px
	variable float pz
	
	; radius of the circle
	variable int cradius=2
	
	do
	{
		do
		{
			; get the X,Z point on the circle
			px:Set[${Math.Calc[${cradius} * ${Math.Cos[${circleangle}]}]}]
			pz:Set[${Math.Calc[${cradius} * ${Math.Sin[${circleangle}]}]}]

			; Add it to the character location to give the mid-loc
			px:Inc[${Me.X}]
			pz:Inc[${Me.Z}]
			
			; check to see if the mid-loc being checked is not blocked also
			
			if !${EQ2.CheckCollision[${Me.X},${Me.Y},${Me.Z},${px},${CY},${pz}]}
			{
				; check to see if there is LOS from that mid-loc to the node
				if !${EQ2.CheckCollision[${px},${CY},${pz},${CX},${CY},${CZ}]}
				{
					call moveto ${px} ${pz} 5 1 3 1
					waitframe
					call moveto ${CX} ${CZ} 5 0 3 1
					Return THERE
				}
				
			}
		}
		; move 5 degree angle along circumfrence
		while ${circleangle:Inc[5]} <=359
		circleangle:Set[1]
	}
	; increase the size of the circle
	while ${cradius:Inc} <=100
	return STUCK
}

function checknode(actorname)
{
	variable int tempvar=1
	do
	{
		if ${actorname.Equal[${NodeName[${tempvar}]}]}
		{
			Return TRUE
		}
	}
	while ${tempvar:Inc} <=7
	Return FALSE
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
			Echo ${NodeName[${tempvar}]}
		}
		while ${tempvar:Inc}<=7

	}

	method InitTriggersAndEvents()
	{
		Event[EQ2_onLootWindowAppeared]:AttachAtom[EQ2_onLootWindowAppeared]
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
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
