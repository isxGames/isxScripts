#include "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreMapController.inc"
function main(string ExecuteCommand)
{
	call ${ExecuteCommand}
	while ${QueuedCommands}
		ExecuteQueued
}

function RefreshNavPaths()
{
	;Clear out the combobox
	UIElement[${CboBoxOHAddNavPathID}]:ClearItems
	UIElement[${CboBoxOHAddNavPathID}]:ClearSelection

	variable lnavregionref NavRef

	OgreMapControllerOb:LoadMap[${Zone}]

	NavRef:SetRegion[${LavishNav.FindRegion[${Zone}].Children}]
	while ${NavRef.Region(exists)}
	{
		if ${NavRef.Unique}
		{
			UIElement[${CboBoxOHAddNavPathID}]:AddItem[${NavRef.Name}]
		}
		NavRef:SetRegion[${NavRef.Next}]
	}

	OgreMapControllerOb:UnLoadMap[${Zone}]
	UIElement[${CmdOHRefreshNavPathsID}]:SetText[Refresh list]
}

variable string OHConfigFile
variable settingsetref setOHConfig
variable string xmlOHNavPaths
variable settingsetref setOHNavPaths

function OHNavPathInit()
{
	OHConfigFile:Set["${LavishScript.HomeDirectory}/scripts/eq2ogreharvest/OgreHarvestPaths/OgreHarvestPath_${Zone}.xml"]
	LavishSettings[OgreHarvest1]:Clear
	LavishSettings:AddSet[OgreHarvest1]
	LavishSettings[OgreHarvest1]:AddSet[${Zone}]
}
function OHSaveNavPath()
{
	call OHNavPathInit
	setOHNavPaths:Set[${LavishSettings[OgreHarvest1].FindSet[${Zone}]}]
	variable int OHCounter=0
	while ${OHCounter:Inc}<=${UIElement[${LstBoxOHNavPathsID}].Items}
	{
		setOHNavPaths:AddSetting[NavPath${OHCounter},${UIElement[${LstBoxOHNavPathsID}].Item[${OHCounter}]}]
	}
	LavishSettings[OgreHarvest1]:Export["${OHConfigFile}"]
	echo Saved Nav Points
	UIElement[${CmdOHSavePathID}]:SetText[Save]
}
function OHLoadNavPath()
{
	call OHNavPathInit
	LavishSettings[OgreHarvest1]:Import["${OHConfigFile}"]
	setOHNavPaths:Set[${LavishSettings[OgreHarvest1].FindSet[${Zone}]}]
	variable int OHCounter=0
	UIElement[${LstBoxOHNavPathsID}]:ClearItems
	variable iterator Iterator
	setOHNavPaths:GetSettingIterator[Iterator]

	if !${Iterator:First(exists)}
	{
		echo No Nav points found.
		UIElement[${CmdOHLoadPathID}]:SetText[Load]
		return
	}

	do
	{
		UIElement[${LstBoxOHNavPathsID}]:AddItem[${Iterator.Value},None]
	}
	while ${Iterator:Next(exists)}
	echo Loaded Nav Points
	UIElement[${CmdOHLoadPathID}]:SetText[Load]
}