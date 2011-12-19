/**
Version 1.03
Written by: Kannkor

Note: EQ2OgreDepotResourceInformation is NEVER cleared from the current session incase the user us using that information with the Ogre Harvest bot. Information is cleared with EQ2OgreHarvest or when the session is closed.

By default, this deposits Raws (normal resources) only. If you wish to deposit RARES, you need to use the Rare arg.
Example: Run ogre depot rare

**/
variable string CurrentResource=None
variable collection:string FullResources
function main(string TypeToDeposit=Raw)
{
	;Because this script is passed an parm no matter what, if it's blank, we need to re-setup ${TypeToDeposit}
	;If nothing valid was passed, default will be Raw. 
	if ${TypeToDeposit.Equal[rare]}
	{
	}
	else
		TypeToDeposit:Set[Raw]

	variable bool FullCheck=TRUE
	call LoadResources
	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
	variable int xx=0
	Me:CreateCustomInventoryArray[nonbankonly]


	while ${xx:Inc} <= ${Me.CustomInventoryArraySize}
	{
		CurrentResource:Set[${Me.CustomInventory[${xx}].Name}]
		;echo ${Me.CustomInventory[${xx}].Name} - ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Type]} - ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
		if ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Type].String.Equal[${TypeToDeposit}]}
		{
			if ${FullCheck} && ${FullResources.Element[${CurrentResource}](exists)}
			{
			}
			else
			{
				echo Adding Raw to Depot: ${Me.CustomInventory[${xx}].Name} - Tier: ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
				;// Me.CustomInventory[${xx}]:AddToDepot[${Actor[nokillnpc,depot].ID}]
				Me.CustomInventory[${xx}]:AddToDepot[${Actor[Tradeskill Unit,depot].ID}]
				wait 10
			}
		}
	}
	echo script done
}
variable settingsetref setEQ2OgreDepotResourceInfo
function LoadResources()
{
	variable string ResourceConfigFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/EQ2OgreDepotResourceInformation.xml"
	;LavishSettings[EQ2OgreDepotResourceInformation]:Clear
	LavishSettings:AddSet[EQ2OgreDepotResourceInformation]
	LavishSettings[EQ2OgreDepotResourceInformation]:Import[${ResourceConfigFile}]
	LavishSettings[EQ2OgreDepotResourceInformation]:AddSet[EQ2OgreDepotResourceInfo]
	setEQ2OgreDepotResourceInfo:Set[${LavishSettings[EQ2OgreDepotResourceInformation].FindSet[EQ2OgreDepotResourceInfo]}]
}

atom EQ2_onIncomingText(string Message)
{
	if ${Message.Find["This container cannot hold any more of this item."]}
	{
		echo Adding ${CurrentResource} to the full list.
		FullResources:Set[${CurrentResource},${CurrentResource}]
	}
}