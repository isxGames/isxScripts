/**
Version 1.05 - Kannkor
	Updated to work with new ISXEQ2
EQ2OgreTransmute Version 1.04 - Kannkor
-Updated Mastercrafted to work with MASTERCRAFTED LEGENDARY
EQ2OgreTransmute Version 1.03 - Kannkor
-Removed IsReserved check
EQ2OgreTransmute Version 1.02 - Kannkor
-Updated for no cast time
EQ2OgreTransmute Version 1.01 - Kannkor
-Fixed Typo (Update -> UpdateInfo)
Use the interface to selection options. 
Usage: "Run ogre transmute"

**/


#include "${LavishScript.HomeDirectory}/Scripts/eq2ogrecommon/EQ2OgreBagManager.inc"
variable int VarCopy
variable bool Transmuted=FALSE
variable int ItemsTransmuted=0
function main(bool SkipChecks=FALSE)
{
	Event[EQ2_onRewardWindowAppeared]:AttachAtom[EQ2_onRewardWindowAppeared]

	variable int ContainerCounter=0
	variable int x=0
	variable int LoopCounter
	;When this script is ran initially, it creates the inventory, some of which are NULL. Wait 1 second and get an update.

	while ${LoopCounter:Inc} <=1
	{
		wait 10
		OgreBagInfoOb:UpdateInfo
		ContainerCounter:Set[0]
		x:Set[0]
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
				Me.Inventory[id,${VarCopy}]:Initialize
				wait 30 ${Me.Inventory[id,${VarCopy}].IsInitialized}
				;// if ${Me.Inventory[id,${VarCopy}].Name.Equal[NULL]}
				;// 	wait 5
				;// Lets eliminate items that can't be transmuted period. Removed || ${Me.Inventory[id,${VarCopy}].IsReserved} since it didn't work
				;// Removed Ornate - because the drops from PQs are ornate. || ${Me.Inventory[id,${VarCopy}].Ornate}
				if ${Me.Inventory[id,${VarCopy}].NoValue} || ${Me.Inventory[id,${VarCopy}].Level}<=0  
					continue

				if !${SkipChecks} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[TREASURED]} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[Mastercrafted Legendary]} && \
					!${Me.Inventory[id,${VarCopy}].Tier.Equal[Legendary]} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[Fabled]} && !${Me.Inventory[id,${VarCopy}].Tier.Equal[mastercrafted]}
					continue

				;Lets eliminate items that can't be transmuted based on the UI selection
				if ${Me.Inventory[id,${VarCopy}].Tier.Equal[TREASURED]} &&  !${UIElement[${EQ2OgreTransmuteTreasuredID}].Checked}
					continue

				if ${Me.Inventory[id,${VarCopy}].Tier.Equal[Legendary]} &&  !${UIElement[${EQ2OgreTransmuteLegendaryID}].Checked}
					continue

				if ${Me.Inventory[id,${VarCopy}].Tier.Equal[Fabled]} &&  !${UIElement[${EQ2OgreTransmuteFabledID}].Checked}
					continue

				if ( ${Me.Inventory[id,${VarCopy}].Tier.Equal[mastercrafted]} ||  ${Me.Inventory[id,${VarCopy}].Tier.Equal[mastercrafted legendary]} ) &&  !${UIElement[${EQ2OgreTransmuteMasterCraftedID}].Checked}
					continue

				if ${Me.Inventory[id,${VarCopy}].Level} < ${Int[${UIElement[${TEBoxEQ2OgreTransmuteMinLevelID}].Text}]} || ${Me.Inventory[id,${VarCopy}].Level} > ${Int[${UIElement[${TEBoxEQ2OgreTransmuteMaxLevelID}].Text}]}
					continue

				if ${Me.Inventory[id,${VarCopy}].Quantity} > 1 && !${Me.Inventory[id,${VarCopy}].Name.Find["(adept)"](exists)} && !${Me.Inventory[id,${VarCopy}].Name.Find["transmutation stone"](exists)} && !${Me.Inventory[id,${VarCopy}].Name.Find["(expert)"](exists)} && !${Me.Inventory[id,${VarCopy}].Name.Find["(master)"](exists)}
					continue
				if ${Me.Inventory[id,${VarCopy}](exists)}
				{
					if ${Me.Inventory[id,${VarCopy}].Quantity} > 1
						x:Dec
					call TransmuteIt ${VarCopy}
				}
				else
					echo Report this: {Me.Inventory[id,${VarCopy}](exists)} failed ( ${Me.Inventory[id,${VarCopy}](exists)} ). This shouldn't be possible unless you moved/sold/deleted items.
			}
		}
	}
	if !${Transmuted}
		echo You either have no items to transmute in the selected cointainers, or your inventory items were not detected. Try re-running the script to detect.
}

function TransmuteIt(int ItemID)
{
	Transmuted:Set[TRUE]
	echo Transmuting.. ${Me.Inventory[id,${ItemID}].Name}.
	if ${ISXEQ2.Version} > 20150507.0001
	{
		;// New way, ISXEQ2 Version 20150507.001 or newer.
		Me.Ability[id, 3943362837]:Use
		wait 5
		if !${EQ2.ReadyToRefineTransmuteOrSalvage}
		{
			wait 5
			if !${EQ2.ReadyToRefineTransmuteOrSalvage}
				echo ${Time}: OgreTransmute - Tried to use Transmute ability, but it didn't work. Maybe extreme latency? Waiting 5 seconds and letting it continue.
			wait 50
		}
		Me.Inventory[id,${ItemID}]:Transmute
		ItemsTransmuted:Inc
		wait 20
	}
	else
	{
		;// Old way, ISXEQ2 Version 20150507.001 or older.
		Me.Inventory[id,${ItemID}]:Transmute
		wait 25
	}
}
atom EQ2_onRewardWindowAppeared()
{
	RewardWindow:Receive
}
atom atexit()
{
	UIElement[${CmdEQ2OgreTransmuteStopID}]:Hide
	UIElement[${CmdEQ2OgreTransmuteStartID}]:Show
	echo EQ2Ogre Transmute completed. ${Me.Name} transmuted ${ItemsTransmuted} items.
	oc EQ2Ogre Transmute completed. ${Me.Name} transmuted ${ItemsTransmuted} items.
}