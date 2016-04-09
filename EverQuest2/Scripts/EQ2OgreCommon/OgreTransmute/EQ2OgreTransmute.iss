/**
EQ2OgreTransmute Version 1.01 - Kannkor
-Fixed Typo (Update -> UpdateInfo)
Use the interface to selection options. 
Usage: "Run ogre transmute"

**/


#include "${LavishScript.HomeDirectory}/Scripts/eq2ogrecommon/EQ2OgreBagManager.inc"
variable int VarCopy
variable bool Transmuted=FALSE

function main()
{
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

			;Lets eliminate items that can't be transmuted period.
			if ${Me.Inventory[id,${VarCopy}].NoValue} || ${Me.Inventory[id,${VarCopy}].Level}<=0 || ${Me.Inventory[id,${VarCopy}].IsReserved} || ${Me.Inventory[id,${VarCopy}].Ornate}
				continue

			if !${Me.Inventory[id,${VarCopy}].Tier.Equal[TREASURED]} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[Legendary]} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[Fabled]} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[mastercrafted]}
				continue

			;Lets eliminate items that can't be transmuted based on the UI selection
			if ${Me.Inventory[id,${VarCopy}].Tier.Equal[TREASURED]} &&  !${UIElement[${EQ2OgreTransmuteTreasuredID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].Tier.Equal[Legendary]} &&  !${UIElement[${EQ2OgreTransmuteLegendaryID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].Tier.Equal[Fabled]} &&  !${UIElement[${EQ2OgreTransmuteFabledID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].Tier.Equal[mastercrafted]} &&  !${UIElement[${EQ2OgreTransmuteMasterCraftedID}].Checked}
				continue

			if ${Me.Inventory[id,${VarCopy}].Level} < ${Int[${UIElement[${TEBoxEQ2OgreTransmuteMinLevelID}].Text}]} || ${Me.Inventory[id,${VarCopy}].Level} > ${Int[${UIElement[${TEBoxEQ2OgreTransmuteMaxLevelID}].Text}]}
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
		echo You either have no items to transmute in the selected cointainers, or your inventory items were not detected. Try re-running the script to detect.
}

function TransmuteIt(int ItemID)
{
	Transmuted:Set[TRUE]
	echo Transmuting.. ${Me.Inventory[id,${ItemID}].Name}.
	Me.Inventory[id,${ItemID}]:Transmute
	wait 20 ${Me.CastingSpell}
	while ${Me.CastingSpell}
		wait 5

	wait 5
}
atom EQ2_onRewardWindowAppeared()
{
	RewardWindow:Receive
}
atom atexit()
{
	UIElement[${CmdEQ2OgreTransmuteStopID}]:Hide
	UIElement[${CmdEQ2OgreTransmuteStartID}]:Show
	echo EQ2Ogre Transmute completed.
}