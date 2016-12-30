/**
EQ2OgreTransmute Version 1.01 - Kannkor (update by IDBurner)
Use the interface to selection options. 
Usage: "Run ogre transmute"

**/

#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreFree/EQ2OgreBagManager.inc"
variable int VarCopy
variable bool Transmuted=FALSE
variable string useMethod=Transmute

function main(string methodType=Transmute)
{
	useMethod:Set[${methodType}]

	Event[EQ2_onRewardWindowAppeared]:AttachAtom[EQ2_onRewardWindowAppeared]

	variable int ContainerCounter=0
	variable int x=0

	;When this script is ran initially, it creates the inventory, some of which are NULL. Wait 1 second and get an update.
	wait 10
	OgreBagInfoOb:UpdateInfo
	wait 10
	OgreBagInfoOb:UpdateInfo

	while ${ContainerCounter:Inc}<=6
	{
		if !${UIElement[${EQ2OgreTransmuteBox${ContainerCounter}ID}].Checked}
		{
			echo Skipping Container #${ContainerCounter} since it is not checked.
			continue
		}

		x:Set[0]
		while ${x:Inc}<=${OgreBagInfoOb.BagSize[${ContainerCounter}]}
		{
			VarCopy:Set[${OgreBagInfoOb.BagContents[${ContainerCounter},${x}]}]

			;If the item is refinable we go straight to TransmuteIt. There may be a few treasured items in game that match this check and are not Rare harvest. - IDBurner
			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.NoValue} && ${useMethod.Equal[Refine]} && ${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[TREASURED]} && ${Me.Inventory[id,${VarCopy}](exists)}
			{
				call TransmuteIt ${VarCopy}
			}

			;We will use the above function to run our Refine as it is a bit more specific thant transmuting or salvaging. If I find a cleaner way I will update it - IDBurner
			if ${useMethod.Equal[Refine]}
				continue

			;Lets eliminate items that can't be transmuted period.
			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.NoValue} || ${Me.Inventory[id,${VarCopy}].ToItemInfo.Level}<=0 || ${Me.Inventory[id,${VarCopy}].ToItemInfo.Ornate}
				continue

			if !${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[TREASURED]} && !${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[Legendary]} && !${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[Fabled]} && !${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[mastercrafted]} 
				continue

			;Lets eliminate items that can't be transmuted based on the UI selection
			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[TREASURED]} &&  !${UIElement[${EQ2OgreTransmuteTreasuredID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[Legendary]} &&  !${UIElement[${EQ2OgreTransmuteLegendaryID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[Fabled]} &&  !${UIElement[${EQ2OgreTransmuteFabledID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.Tier.Equal[mastercrafted]} &&  !${UIElement[${EQ2OgreTransmuteMasterCraftedID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].ToItemInfo.Level} < ${Int[${UIElement[${TEBoxEQ2OgreTransmuteMinLevelID}].Text}]} || ${Me.Inventory[id,${VarCopy}].ToItemInfo.Level} > ${Int[${UIElement[${TEBoxEQ2OgreTransmuteMaxLevelID}].Text}]}
				continue

			if ${Me.Inventory[id,${VarCopy}](exists)}
			{
				call TransmuteIt ${VarCopy}
			}
			else
				echo Report this: {Me.Inventory[id,${VarCopy}](exists)} failed ( ${Me.Inventory[id,${VarCopy}](exists)} ). This shouldn't be possible unless you moved/sold/deleted items.
		}
	}
	if !${Transmuted}
		echo You either have no items to transmute/salvage/refine in the selected cointainers, or your inventory items were not detected. Try re-running the script to detect.
}

function TransmuteIt(int ItemID)
{
	Transmuted:Set[TRUE]

	;Transmutes the selected items - Updated:IDBurner
	if ${useMethod.Equal[Transmute]}
	{
		echo Transmuting.. ${Me.Inventory[id,${ItemID}].Name}.
		Me.Ability[id, 3943362837]:Use
		wait 10
		Me.Inventory[id,${ItemID}]:Transmute
		wait 20 ${Me.CastingSpell}
		while ${Me.CastingSpell}
			wait 5
	}

	;Salvages the selected items - Added:IDBurner
	if ${useMethod.Equal[Salvage]}
	{
		echo Salvaging.. ${Me.Inventory[id,${ItemID}].Name}.
		Me.Ability[id, 2266640201]:Use
		wait 10
		Me.Inventory[id,${ItemID}]:Salvage
		wait 20 ${Me.CastingSpell}
		while ${Me.CastingSpell}
			wait 5
	}

	;Refines the selected items - Added:IDBurner
	if ${useMethod.Equal[Refine]}
	{
		echo Refining.. ${Me.Inventory[id,${ItemID}].Name}.
		Me.Ability[id, 427735786]:Use
		wait 10
		Me.Inventory[id,${ItemID}]:Refine
		wait 20 ${Me.CastingSpell}
		while ${Me.CastingSpell}
			wait 5
	}

	wait 5
}
atom EQ2_onRewardWindowAppeared()
{
	RewardWindow:Receive
}
atom atexit()
{
	UIElement[${CmdEQ2OgreStopID}]:Hide
	UIElement[${CmdEQ2OgreTransmuteStartID}]:Show
	UIElement[${CmdEQ2OgreSalvageStartID}]:Show
	UIElement[${CmdEQ2OgreRefineStartID}]:Show
	echo EQ2Ogre Transmute/Salvage/Refine completed.
}