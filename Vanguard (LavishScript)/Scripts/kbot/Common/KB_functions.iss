

; ***********************************************
; **  **
; ***********************************************
function lootCorpse()
{
	if !${Me.Target(exists)}
	{
		return
	}

	if ${CorpseBlackList.Element[${Me.Target.ID}](exists)}
	{
		return
	}

	;Move to the corpse if you're not close
	if ${Me.Target.Distance} >= 5
	{
		call movetoobject ${Me.Target.ID} 4 0
	}

	CorpseBlackList:Set[${Me.Target.ID},${Me.Target.ID}]

	if ${doLootCorpses}
	{
		call DebugIt ".  Looting ${Me.Target}"
		Me.Target:LootAll
		wait 5
		
		VGExecute /cleartargets
		wait 5


/*
		Me.Target:Loot
		wait 5
		
		call DebugIt ".  Looting (${Loot.NumItems}) ${Me.Target}"
		
		if ${Loot.NumItems}
		{
			if ${onlyGoodLoot}
			{
				variable int iCount
				for (iCount:Set[${Loot.NumItems}] ; ${iCount} > 0 ; iCount:Dec)
				{
					call DebugIt ".   Item ${Loot.Item[${iCount}].Name}: ${Loot.Item[${iCount}].Type}"
					if ${Loot.Item[${iCount}].Type.Find[Weapon]} || ${Loot.Item[${iCount}].Type.Find[Armor]} || ${Loot.Item[${iCount}].Type.Find[Shield]} || ${Loot.Item[${iCount}].Rarity.Find[Rare]} || ${Loot.Item[${iCount}].Rarity.Find[Heroic]}
					{
						Loot.Item[${iCount}]:Loot
					}
				}
				wait 5
				Loot:EndLooting
			}
			else
			{
				Loot:LootAll
				wait 5
			}
		}
*/
	}
}

; ***********************************************
; **  **
; ***********************************************
function skinCorpse()
{
	if !${Me.Target(exists)}
	{
		return
	}

	if ${HarvestBlackList.Element[${Me.Target.ID}](exists)}
	{
		return
	}

	if ${doSkinMobs} && ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.IsHarvestable} && ${Me.Target.Distance} < 10 && !${Me.Target.Name.Find[remains]}
	{

		HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]

		;Move to the corpse if you're not close
		if ${Me.Target.Distance} > 5
		{
			call movetoobject ${Me.Target.ID} 5 0
		}

		call DebugIt ".   Harvesting Corpse"
		VGExecute /autoattack

		wait 20

		; Now wait for the Harvesting to finish
		while ${GV[bool,bHarvesting]} && (${Me.HealthPct} > 80)
		{
			wait 5
		}

		wait 10

		; Then loot!
		if ${doLootCorpses}
		Me.Target:LootAll

		LastCorpseID:Set[${Me.Target.ID}]

		VGExecute /cleartargets

	}
}
; begin add by cj
function:bool Necropsy()
{
	if !${doNecropsy} || ${NecropsyBlackList.Element[${Me.Target.ID}](exists)}
	{
		return TRUE
	}

	variable int64 curTargetID = ${Me.Target.ID}

	if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.Distance} < 25 && !${Me.Target.Name.Find[remains]}
	{
		call DebugIt ".         in Necropsy"
		VGExecute "/stand"

		wait 1

		NecropsyBlackList:Set[${Me.Target.ID},${Me.Target.ID}]

		Pawn[ID,${curTargetID}]:Target
		wait 1

		Me.Ability["${necropsyAbility}"]:Use
		wait 5 ${Me.IsCasting}

		while ${Me.IsCasting}
		{
			if ${Me.Target.ID} != ${curTargetID}
			{
				call DebugIt  ".      in Necropsy -- Target ID Changed ${Me.Target.ID} , retargeting ${curTargetID}"
				Pawn[ID,${curTargetID}]:Target
			}
			wait 1
		}
		do
		{
			wait 5
			Loot:LootAll
		}
		while ${GV[bool,LootIsLooting]}

		if !${doGetMinions} && !${doGetEnergy}
		{
			LastCorpseID:Set[${Me.Target.ID}]
		}
	}
	return TRUE
}

function:bool getEnergy()
{
	if !${doGetEnergy} || ${getManaorMinionBlackList.Element[${Me.Target.ID}](exists)}
	{
		return TRUE
	}

	if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.Distance} < 25 && !${Me.Target.Name.Find[remains]}
	{
		call DebugIt ".         in getManaorMinion"
		getManaorMinionBlackList:Set[${Me.Target.ID},${Me.Target.ID}]

		Me.Ability["${vileAbility}"]:Use
		wait 1
		call MeCasting
	}
	LastCorpseID:Set[${Me.Target.ID}]
	return TRUE
}

function:bool getMinions()
{
	if (!${doGetMinions}) || ${getManaorMinionBlackList.Element[${Me.Target.ID}](exists)}
	{
		return TRUE
	}

	if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.Distance} < 25 && !${Me.Target.Name.Find[remains]}
	{
		call DebugIt ".         in getMinion"
		getManaorMinionBlackList:Set[${Me.Target.ID},${Me.Target.ID}]

		if ${lastMinion.Equal[NONE]} || ${lastMinion.Equal["${minionAbility2}"]} || ${minionAbility2.Equal[NONE]}
		{
			Me.Ability["${minionAbility1}"]:Use
			lastMinion:Set["${minionAbility1}"]
		}
		elseif ${lastMinion.Equal["${minionAbility1}"]} && !${minionAbility2.Equal[NONE]}
		{
			Me.Ability["${minionAbility2}"]:Use
			lastMinion:Set["${minionAbility2}"]
		}
		wait 1
		call MeCasting
	}
	LastCorpseID:Set[${Me.Target.ID}]
	return TRUE
}

; end add by cj
; ***********************************************
; **  **
; ***********************************************
function Harvest()
{

	if ${Me.Target.ID(exists)} && ${doHarvest} && ${Me.Target.Type.Equal[Resource]}
	{
		if ${HarvestBlackList.Element[${Me.Target.ID}](exists)}
		{
			return
		}

		; Check for Agro Mobs or other dangers
		;call AreWeSafe
		;if !${Return}
		;{
		;	call DebugIt ". Harvest:  Harvesting area NOT safe"
		;	HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
		;	return
		;}

		call DebugIt ". Harvest:   Harvesting Resource: ${Me.Target.Name}"
		VGExecute /autoattack
		wait 20

		isHarvesting:Set[TRUE]

		; Now wait for the Harvesting to finish
		while ${GV[bool,bHarvesting]} && ${Me.HealthPct} > 80 && ${Me.Encounter}==0 && !${Me.Target.ContainsLoot}
		{
			wait 5
		}
		isHarvesting:Set[FALSE]

		if ${Me.Encounter}==0
		{
			HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
			wait 10

			; Then loot!
			Me.Target:LootAll
		}
		VGExecute /cleartargets
	}
}


; ***********************************************
; **  **
; ***********************************************
function UseFoodsDrinks()
{
	variable int iCount = 0
	variable iterator anIter

	if ${justAte}
	{
		return
	}

	if ${doUseFood} && (${Me.HealthPct} < ${restFoodPct} || ${Me.EnergyPct} < ${restFoodPct}) && !${Me.Effect[${FeignDeath}](exists)}
	{
		call DebugIt ".Starting UseFoodsDrinks function"

		while ${Me.Inventory[${iCount:Inc}].Name(exists)}
		{
			setConfig.FindSet[Food]:GetSettingIterator[anIter]
			anIter:First

			while ${anIter.Key(exists)}
			{
				if ${Me.Inventory[${iCount}].Name.Equal[${anIter.Key}]}
				{
					call DebugIt ". Using: ${Me.Inventory[${iCount}].Name}"
					Me.Inventory[${iCount}]:Use
					justAte:Set[TRUE]
					return
				}
				anIter:Next
			}
		}
	}
}

; ***********************************************
; **  See if Forage is availabe and get some!  **
; ***********************************************
function ForageCheck()
{
	if ${Me.Ability[Forage].IsReady}
	{
		call DebugIt ".  ForageCheck called"
		Me.Ability[Forage]:Use
		call MeCasting
		wait 5 ${Loot.NumItems}
		Loot:LootAll
		wait 5
		if ${Me.IsLooting}
		Loot:EndLooting
	}

	if ${doArrowAssemble}
	call AssembleArrows "${arrowName}"
}

; ************************
; ** Arrows into Quiver **
; ************************
function LoadArrows()
{
	; First, find an Equipped Case or Quiver
	variable int iCount = 1
	variable int caseIndex = 0

	do
	{
		if ${Me.Inventory[${iCount}].CurrentEquipSlot.Find[Ammo]} && ${Me.Inventory[${iCount}].NumSlotsOpen} > 0
		{
			caseIndex:Set[${Me.Inventory[${iCount}].Index}]
			call DebugIt ". LoadArrows: Found Ammo case ${caseIndex}"
			break
		}
	}
	while (${iCount:Inc} <= ${Me.Inventory})

	if ${caseIndex} == 0
	{
		; Either no open slots to load arrows, or no case
		return
	}

	iCount:Set[1]
	do
	{
		if ${Me.Inventory[${iCount}].Name.Find[arrow]}
		{
			if ${Me.Inventory[${iCount}].InContainer(exists)} && ${Me.Inventory[${iCount}].InContainer.Index} == ${caseIndex}
			{
				continue
			}
			call DebugIt ".  Move Arrow: ${Me.Inventory[${iCount}].Name}"
			Me.Inventory[${iCount}]:PutInContainer[${caseIndex}]
			wait 5
			break
		}
	}
	while (${iCount:Inc} <= ${Me.Inventory})

}

; ***********************************************
; **  **
; ***********************************************
function AssembleArrows(string aName)
{
/*
	/assemblyaddingredient "Pristine Chicken Feather"
	/assemblyaddingredient "Chipped Shards"
	/assemblyaddingredient "Flimsy Reed"
	/assemble
	
	Crude Warden's Arrow/Bolt Components
	bolt- Shortened Flimsey Reed
	- Flimsey Reed
	- Pristine Chicken Feather
	- Jagged Rock
	
	Plain Warden's Arrow/Bolt Components
	bolt- Shortened Straight Stick
	- Straight Stick
	- Hawk Feather
	- Sharped Obsidian
	
	Polished Warden's Arrow/Bolt Components
	bolt- Shoftened Hollow Bird Bone
	- Hollow Bird Bone
	- Cockatrice Feather
	- Viper Fang
	
	Honed Warden's Arrow/Bolt Components
	bolt- Shortened Brownie Walking Stick
	- Brownie Walking Stick
	- Roc Feather
	- Meteorite Shard
	
	Precision Warden's Arrow/Bolt Components
	bolt- Shortened Treant Finger
	- Treant Finger
	- Phoenix Feather
	- Wyvern Stinger
	
*/

	; First, check to see if we have all the required ingredients
	; ExactName,
	if ${Me.Inventory[ExactName,Pristine Chicken Feather](exists)} && ${Me.Inventory[ExactName,Chipped Shards](exists)} && ${Me.Inventory[ExactName,Flimsy Reed](exists)}
	{
		call DebugIt ".  AssembleArrows: Crude Warden's Arrow"

		VGExecute /assemblyaddingredient \"Pristine Chicken Feather\"
		wait 5
		VGExecute /assemblyaddingredient \"Chipped Shards\"
		wait 5
		VGExecute /assemblyaddingredient \"Flimsy Reed\"
		wait 5
		VGExecute /assemble
		wait 5
	}
	elseif ${Me.Inventory[ExactName,Hawk Feather](exists)} && ${Me.Inventory[ExactName,Sharpened Obsidian](exists)} && ${Me.Inventory[ExactName,Straight Stick](exists)}
	{
		call DebugIt ". AssembleArrows: Plain Warden's Arrow"

		VGExecute /assemblyaddingredient \"Hawk Feather\"
		wait 5
		VGExecute /assemblyaddingredient \"Sharpened Obsidian\"
		wait 5
		VGExecute /assemblyaddingredient \"Straight Stick\"
		wait 5
		VGExecute /assemble
		wait 5
	}
	elseif ${Me.Inventory[ExactName,Cockatrice Feather](exists)} && ${Me.Inventory[ExactName,Viper Fang](exists)} && ${Me.Inventory[ExactName,Hollow Bird Bone](exists)}
	{
		call DebugIt ". AssembleArrows: Polished Warden's Arrow"

		VGExecute /assemblyaddingredient \"Cockatrice Feather\"
		wait 5
		VGExecute /assemblyaddingredient \"Viper Fang\"
		wait 5
		VGExecute /assemblyaddingredient \"Hollow Bird Bone\"
		wait 5
		VGExecute /assemble
		wait 5
	}
	elseif ${Me.Inventory[ExactName,Roc Feather](exists)} && ${Me.Inventory[ExactName,Meteorite Shard](exists)} && ${Me.Inventory[ExactName,Brownie Walking Stick](exists)}
	{
		call DebugIt ". AssembleArrows: Honed Warden's Arrow"

		VGExecute /assemblyaddingredient \"Roc Feather\"
		wait 5
		VGExecute /assemblyaddingredient \"Meteorite Shard\"
		wait 5
		VGExecute /assemblyaddingredient \"Brownie Walking Stick\"
		wait 5
		VGExecute /assemble
		wait 5
	}
	elseif ${Me.Inventory[ExactName,Phoenix Feather](exists)} && ${Me.Inventory[ExactName,Wyvern Stinger](exists)} && ${Me.Inventory[ExactName,Treant Finger](exists)}
	{
		call DebugIt ". AssembleArrows: Precision Warden's Arrow"

		VGExecute /assemblyaddingredient \"Phoenix Feather\"
		wait 5
		VGExecute /assemblyaddingredient \"Wyvern Stinger\"
		wait 5
		VGExecute /assemblyaddingredient \"Treant Finger\"
		wait 5
		VGExecute /assemble
		wait 5
	}
	else
	{
		; Nothing in our Inventory to make arrows with!
		return
	}

	while ${GV[bool,bAssembling]}
	{
		wait 5
	}
	
	; Wait a second then loot
	wait 10
	Loot:LootAll

}

/*
variable int rCount
call DebugIt "VG:BuildAssemblyList called"

if !${Assembly(exists)}
return

rCount:Set[0]

while ${rCount:Inc} <= ${Assembly.RecipeCount}
{
if ! ${Assembly.Recipe[${rCount}](exists)}
{
continue
}

;call DebugOut "VG:BuildRecipeList: ${Refining.Recipe[${rCount}].Name}"
UIElement[RecipeSelectCombo@Recipe@Craft Main@CraftBot]:AddItem[${Assembly.Recipe[${rCount}].Name}]
if ${Assembly.Recipe[${rCount}].Name.Equal[${recipeName}]}
UIElement[RecipeSelectCombo@Recipe@Craft Main@CraftBot]:SelectItem[${rCount}]
}

*/



; ************************
; ** Manage Add routine **
; ************************
function Manage_Adds()
{
	call DebugIt ".Adds:  Deciding what to do "
	if ${Use_Mez}
	{
	}

	if ${Use_Charm}
	{
	}

	if ${RLG}
	{
		call RLG
	}
}

; **********************************
; **  Blacklist Reset - 5 Min **
; **********************************
function ClearBlacklist()
{
	if ${doClearBlacklist}
	{
		TimedCommand 3000 ClearBlacklist:Clear
		doClearBlacklist:Set[FALSE]
		TimedCommand 3010 doClearBlacklist:Set[TRUE]
	}
}

; *********************
; ** Run Like a Girl **
; *********************
function RLG()
{
	variable point3f pathLoc
	variable int aLoop=1
	variable string aReturn
	variable string sPname

	call DebugIt ".Running like a Little Girl !!"

	do
	{
		aLoop:Inc

		echo ". RLG cleartargets"
		VGExecute /cleartargets

		call DebugIt "..RLG: Moving to Safe_Point"

		pathLoc:Set[${setPath.FindSet[${Me.Chunk}].FindSetting[Safe_Point]}]
		call bNavi.FindClosestPoint ${pathLoc.X} ${pathLoc.Y} ${pathLoc.Z}
		wait 3
		sPname:Set[${Return}]

		if ${sPname(exists)} && !${sPname.Equal[NULL]}
		{
			call DebugIt "...RLG: Moving to Safe_Point via ${sPname}"

			call bNavi.MovetoWP "${sPname}" FALSE
			aReturn:Set[${Return}]
		}
		else
		{
			aLoop:Set[100]
		}
	}
	while (!${aReturn.Equal[END]} && ${aLoop}<3)

	if ${aLoop} >= 3
	{
		call DebugIt "....RLG: No Paths found: Moving to Safe_Point directly"

		if ${pathLoc.X} == 0 || ${pathLoc.Y} == 0
		{
			echo ".   RLG: Error, move to pathLoc.X is ZERO!"
			return FALSE
		}
		call moveto ${pathLoc.X} ${pathLoc.Y} 100 FALSE
	}
}