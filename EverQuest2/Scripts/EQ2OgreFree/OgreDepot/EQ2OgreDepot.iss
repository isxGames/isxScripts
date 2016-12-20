/**
Version 2.00
Written by: IDBurner (Originally Borrowed by Kannkor, heavily modified to a new script)

By default, this deposits Raws (normal resources) only. If you wish to deposit RARES, you need to use the Rare arg.
Example: Run ogre depot rare

**/

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss
#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"

variable int OptionCounter = 0
variable settingsetref setEQ2DepotInfo
variable string chkBox

function main(string TypeToDeposit=all)
{
	;Because this script is passed a parm no matter what, if it's blank, we need to re-setup ${TypeToDeposit}
	;If nothing valid was passed, default will be All. 
	if ${TypeToDeposit.Equal[common]} || ${TypeToDeposit.Equal[treasured]} || ${TypeToDeposit.Equal[rare]} || ${TypeToDeposit.Equal[legendary]} || ${TypeToDeposit.Equal[fabled]}
	{
	}
	else
		TypeToDeposit:Set[all]

	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]

	variable string ResourceConfigFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreFree/DepotInfo.xml"
	LavishSettings[DepotInfo]:Clear
	LavishSettings:AddSet[DepotInfo]
	LavishSettings[DepotInfo]:Import[${ResourceConfigFile}]
	LavishSettings[DepotInfo]:AddSet[EQ2DepotInfo]
	setEQ2DepotInfo:Set[${LavishSettings[DepotInfo].FindSet[EQ2DepotInfo]}]

	variable iterator SettingIterator
	setEQ2DepotInfo:GetSettingIterator[SettingIterator]
	if ${SettingIterator:First(exists)}
	{
		do
	  	{
		  	chkBox:Set[${setEQ2DepotInfo.FindSetting["${SettingIterator.Key}"].FindAttribute[ChkBox].String}]
		  	
		  	if ${Actor[${SettingIterator.Key}](exists)} && ${setEQ2DepotInfo.FindSetting[${SettingIterator.Key}].FindAttribute[Options].String.Equal[Full]} && ${UIElement[${chkBox}].Checked}
		  	{

				Face "${SettingIterator.Key}"
				Actor[${SettingIterator.Key}]:DoTarget
				if ${UIElement[${MoveToID}].Checked}
				{
					call moveto ${Actor[${SettingIterator.Key}].X} ${Actor[${SettingIterator.Key}].Z} 5 0 3 1
				}
				Actor[${SettingIterator.Key}]:DoubleClick
				wait 10

				echo Depositing Harvest Type ${TypeToDeposit.Upper}

				if ${TypeToDeposit.Equal[all]}
				{
					OptionCounter:Set[0]
				}
				elseif ${TypeToDeposit.Equal[common]}
				{
					OptionCounter:Set[1]
				}
				elseif ${TypeToDeposit.Equal[treasured]}
				{
					OptionCounter:Set[2]
				}
				elseif ${TypeToDeposit.Equal[rare]}
				{
					OptionCounter:Set[3]
				}
				elseif ${TypeToDeposit.Equal[legendary]}
				{
					OptionCounter:Set[4]
				}
				elseif ${TypeToDeposit.Equal[fabled]}
				{
					OptionCounter:Set[5]
				}

				EQ2UIPage[Inventory,Container].Child[Dropdownbox,Container.TabPages.Items.TierSelector]:Set[${OptionCounter}]
				wait 10
				EQ2UIPage[Inventory,Container].Child[button,Container.TabPages.Items.CommandDepositAll]:LeftClick
				wait 10
				EQ2UIPage[Inventory,Container].Child[button,Container.WindowFrame.Close]:LeftClick
				wait 10
		    }

		    if  ${Actor[${SettingIterator.Key}](exists)} && ${setEQ2DepotInfo.FindSetting[${SettingIterator.Key}].FindAttribute[Options].String.Equal[One]} && ${UIElement[${chkBox}].Checked}
			{
				echo Targeting ${SettingIterator.Key}
				Actor[${SettingIterator.Key}]:DoTarget
				if ${UIElement[${MoveToID}].Checked}
				{
					call moveto ${Actor[${SettingIterator.Key}].X} ${Actor[${SettingIterator.Key}].Z} 5 0 3 1
				}
				Actor[${SettingIterator.Key}]:DoubleClick
				wait 10

				EQ2UIPage[Inventory,Container].Child[button,Container.TabPages.Items.CommandDepositAll]:LeftClick
				wait 10
				EQ2UIPage[Inventory,Container].Child[button,Container.WindowFrame.Close]:LeftClick
				wait 10
			}
	  	}
	  while ${SettingIterator:Next(exists)}
	}
	else
		echo No Depot Selections Have Been Made.

	echo script done
}
