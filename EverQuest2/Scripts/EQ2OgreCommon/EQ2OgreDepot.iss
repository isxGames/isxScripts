/**
Version 1.06
Written by: Kannkor

Version 1.06 - Kannkor
Updated to use all types of depots. Completely changed all the parameters that get passed.

Version 1.05 - Kannkor
Added "mute" and "dust" and "all" tags. Mute does transmutes (manas/infusions etc), all does manas, mutes, rares, raws.

Version 1.04
-Added no more unique check

Note: EQ2OgreDepotResourceInformation is NEVER cleared from the current session incase the user us using that information with the Ogre Harvest bot. Information is cleared with EQ2OgreHarvest or when the session is closed.

By default, this deposits Raws (normal resources) only. If you wish to deposit RARES, you need to use the Rare arg.
Example: Run ogre depot rare

**/
variable string CurrentResource=None
variable collection:string FullResources
variable Object_HarvestDepot HarvestDepot
variable Object_AmmoDepot AmmoDepot
variable Object_GenericDepot WhiteAdornmentDepot="Adornment Depot"
variable Object_GenericDepot LoreLegendDepot="Lore & Legend Depot"
variable Object_GenericDepot FoodDrinkDepot="Food & Drink Depot"
variable Object_GenericDepot CollectibleDepot="Collectible Depot"
variable Object_GenericDepot FuelDepot="Fuel Depot"
variable Object_GenericDepot SpellDepot="Scroll Depot"

function main(... Args)
{
	if ${Args.Used} <= 0
	{
		echo ${Time}: OgreDepot: OgreDepot was recently revamped. It now accepts tons of different parameters.
		echo ${Time}: Previously, the default behaviour was depoting common harvesting materials.
		echo ${Time}: In the future, calling Ogre Depot with no parameters will open a UI. That UI doesn't exist yet.
		echo ${Time}: In 10 seconds, this script will set the parameters to "ogre depot -commons" which was equal to what was default prior.
		echo ${Time}: If a script is calling this via "Ogre depot", update the script to use "ogre depot -commons" or something else acceptable for you.
		wait 100
		HarvestDepot.Commons:Set[TRUE]
	}
	variable int i
	for(i:Set[1]; ${i} <= ${Args.Used}; i:Inc)
	{
		switch ${Args[${i}]}
		{
			case -kannkor
			case -k
				HarvestDepot.UseDepotAll:Set[TRUE]
				WhiteAdornmentDepot.UseDepotAll:Set[TRUE]
				LoreLegendDepot.UseDepotAll:Set[TRUE]
				CollectibleDepot.UseDepotAll:Set[TRUE]
				SpellDepot.UseDepotAll:Set[TRUE]
			break
			case -all
				HarvestDepot.Commons:Set[TRUE]
				HarvestDepot.Rares:Set[TRUE]
				HarvestDepot.Manas:Set[TRUE]
				HarvestDepot.Infusions:Set[TRUE]
				HarvestDepot.Powders:Set[TRUE]
				HarvestDepot.Fragments:Set[TRUE]
				AmmoDepot.Arrows:Set[TRUE]
				AmmoDepot.Shurikens:Set[TRUE]
			break
			case -allharvest
			case -allh
				HarvestDepot.Commons:Set[TRUE]
				HarvestDepot.Rares:Set[TRUE]
				HarvestDepot.Manas:Set[TRUE]
				HarvestDepot.Infusions:Set[TRUE]
				HarvestDepot.Powders:Set[TRUE]
				HarvestDepot.Fragments:Set[TRUE]
			break
			case -allammo
			case -alla
				AmmoDepot.Arrows:Set[TRUE]
				AmmoDepot.Shurikens:Set[TRUE]
			break
			case -depotall
			case -da
				HarvestDepot.UseDepotAll:Set[TRUE]
				WhiteAdornmentDepot.UseDepotAll:Set[TRUE]
				LoreLegendDepot.UseDepotAll:Set[TRUE]
				FoodDrinkDepot.UseDepotAll:Set[TRUE]
				CollectibleDepot.UseDepotAll:Set[TRUE]
				FuelDepot.UseDepotAll:Set[TRUE]
				SpellDepot.UseDepotAll:Set[TRUE]
			break
			case -harvestdepotall
			case -hda
				HarvestDepot.UseDepotAll:Set[TRUE]
			break
			case -commons
			case -c
				HarvestDepot.Commons:Set[TRUE]
			break
			case -ncommons
			case -nocommons
			case -nc
				HarvestDepot.Commons:Set[FALSE]
			break
			case -rares
			case -r
				HarvestDepot.Rares:Set[TRUE]
			break
			case -nrares
			case -norares
			case -nr
				HarvestDepot.Rares:Set[FALSE]
			break
			case -manas
			case -m
				HarvestDepot.Manas:Set[TRUE]
			break
			case -nmanas
			case -nomanas
			case -nm
				HarvestDepot.Manas:Set[FALSE]
			break
			case -infusions
			case -i
				HarvestDepot.Infusions:Set[TRUE]
			break
			case -ninfusions
			case -noinfusions
			case -ni
				HarvestDepot.Infusions:Set[FALSE]
			break
			case -powders
			case -p
				HarvestDepot.Powders:Set[TRUE]
			break
			case -npowders
			case -nopowders
			case -np
				HarvestDepot.Powders:Set[FALSE]
			break
			case -fragments
			case -frags
			case -f
				HarvestDepot.Fragments:Set[TRUE]
			break
			case -nfragments
			case -nfrags
			case -nofragments
			case -nofrags
			case -nf
				HarvestDepot.Fragments:Set[FALSE]
			break
			case -arrows
			case -a
				AmmoDepot.Arrows:Set[TRUE]
			break
			case -narrows
			case -noarrows
			case -na
				AmmoDepot.Arrows:Set[FALSE]
			break
			case -shurikens
			case -s
				AmmoDepot.Shurikens:Set[TRUE]
			break
			case -nshurikens
			case -noshurikens
			case -ns
				AmmoDepot.Shurikens:Set[FALSE]
			break
			case -ammodepotall
			case -ada
				AmmoDepot.UseDepotAll:Set[TRUE]
			break
			case -whiteadorndepotall
			case -wada
				WhiteAdornmentDepot.UseDepotAll:Set[TRUE]
			break
			case -lorelegenddepotall
			case -llda
				LoreLegendDepot.UseDepotAll:Set[TRUE]
			break
			case -fooddrinkdepotall
			case -fdda
				FoodDrinkDepot.UseDepotAll:Set[TRUE]
			break
			case -collectibledepotall
			case -cda
				CollectibleDepot.UseDepotAll:Set[TRUE]
			break
			case -fueldepotall
			case -fda
				FuelDepot.UseDepotAll:Set[TRUE]
			break
			case -spelldepotall
			case -sda
				SpellDepot.UseDepotAll:Set[TRUE]
			break
		}
	}

	if ${HarvestDepot.UseHarvestDepot}
	{
		call HarvestDepot.Depot
	}
	if ${AmmoDepot.UseAmmoDepot}
	{
		call AmmoDepot.Depot
	}
	if ${WhiteAdornmentDepot.UseDepot}
	{
		call WhiteAdornmentDepot.Depot
	}
	if ${LoreLegendDepot.UseDepot}
	{
		call LoreLegendDepot.Depot
	}
	if ${FoodDrinkDepot.UseDepot}
	{
		call FoodDrinkDepot.Depot
	}
	if ${CollectibleDepot.UseDepot}
	{
		call CollectibleDepot.Depot
	}
	if ${FuelDepot.UseDepot}
	{
		call FuelDepot.Depot
	}
	if ${SpellDepot.UseDepot}
	{
		call SpellDepot.Depot
	}
	echo Depoting finished.
}
objectdef Object_GenericDepot
{
	variable bool UseDepotAll
	variable string DepotName
	member:bool UseDepot()
	{
		;// Just checking to see if anything is checked
		if ${This.UseDepotAll}
			return TRUE
		return FALSE
	}
	method Initialize(string _DepotName)
	{
		This.DepotName:Set["${_DepotName}"]
	}
	function Depot()
	{
		variable int64 DepotID
		if ${Actor[special,${This.DepotName}].Name(exists)}
			DepotID:Set[${Actor[special,${This.DepotName}].ID}]
		else
		{
			echo ${Time}: OgreDepot: No depot found.
			wait 20
			return
		}
		if ${This.UseDepotAll}
		{
			call DepotAll ${DepotID}
			return
		}
	}
}
objectdef Object_AmmoDepot
{
	variable bool Shurikens
	variable bool Arrows
	variable bool UseDepotAll
	member:bool UseAmmoDepot()
	{
		;// Just checking to see if anything is checked
		if ${This.Shurikens} || ${This.Arrows} || ${This.UseDepotAll}
			return TRUE
		return FALSE
	}
	function Depot()
	{
		variable int64 DepotID
		if ${Actor[special,Ammo Depot].Name(exists)}
			DepotID:Set[${Actor[special,Ammo Depot].ID}]
		else
		{
			echo ${Time}: OgreDepot: No depot found.
			wait 20
			return
		}
		if ${This.UseDepotAll}
		{
			call DepotAll ${DepotID}
			return
		}
		;// This is not using the depot all button. Since all the aboves return, no reason for an else
		call LoadAmmoResources
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
		variable int xx=0
		Me:CreateCustomInventoryArray[nonbankonly]
		variable iterator _Iterator
		setEQ2OgreDepotAmmoInfo:GetSettingIterator[_Iterator]
		
		while ${xx:Inc} <= ${Me.CustomInventoryArraySize}
		{
			CurrentResource:Set["${Me.CustomInventory[${xx}].Name}"]
			;// echo ${Me.CustomInventory[${xx}].Name} - ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Type]} - ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
			;// if ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Type].String.Equal[${TypeToDeposit}]} || ( ${TypeToDeposit.Equal[all]} && ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}](exists)} )
			if ${FullResources.Element["${CurrentResource}"](exists)}
				continue
			;// Won't be an exact name match like harvests. Can use an iterator
			
			if ${_Iterator:First(exists)}
			{
				do
				{
					if ${CurrentResource.Find["${_Iterator.Key}"](exists)}
					{
						switch ${setEQ2OgreDepotAmmoInfo.FindSetting["${_Iterator.Key}"].FindAttribute[Type].String}
						{
							case arrow
								if ${This.Arrows}
								{
									echo Adding arrow to Depot: ${Me.CustomInventory[${xx}].Name}
									Me.CustomInventory[${xx}]:AddToDepot[${DepotID}]
									wait 5
								}
							break
							case shuriken
								if ${This.Shurikens}
								{
									echo Adding shuriken to Depot: ${Me.CustomInventory[${xx}].Name}
									Me.CustomInventory[${xx}]:AddToDepot[${DepotID}]
									wait 5
								}
							break
						}
						break
					}

				}
				while ${_Iterator:Next(exists)}
			}
		}
		Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]
	}
}
objectdef Object_HarvestDepot
{
	variable bool Commons
	variable bool Rares
	variable bool Manas
	variable bool Infusions
	variable bool Powders
	variable bool Fragments
	variable bool UseDepotAll

	member:bool UseHarvestDepot()
	{
		;// Just checking to see if anything is checked
		if ${This.Commons} || ${This.Rares} || ${This.Manas} || ${This.Infusions} || ${This.Powders} || ${This.Fragments} || ${This.UseDepotAll}
			return TRUE
		return FALSE
	}
	function Depot()
	{
		variable int64 DepotID
		if ${Actor[tradeskill unit,"Harvesting Supply Depot"].Name(exists)}
			DepotID:Set[${Actor[tradeskill unit,"Harvesting Supply Depot"].ID}]
		elseif ${Actor[special,"Tinkered Personal Harvest Depot"].Name(exists)}
			DepotID:Set[${Actor[special,"Tinkered Personal Harvest Depot"].ID}]
		elseif ${Actor[special,"Personal Harvest Depot (small)"].Name(exists)}
			DepotID:Set[${Actor[special,"Personal Harvest Depot (small)"].ID}]
		else
		{
			echo ${Time}: OgreDepot: No depot found.
			wait 20
			return
		}
		if ${This.UseDepotAll}
		{
			call DepotAll ${DepotID}
			return
		}
		;// This is not using the depot all button. Since all the aboves return, no reason for an else
		call LoadResources
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
		variable int xx=0
		Me:CreateCustomInventoryArray[nonbankonly]

		while ${xx:Inc} <= ${Me.CustomInventoryArraySize}
		{
			CurrentResource:Set["${Me.CustomInventory[${xx}].Name}"]
			;// echo ${Me.CustomInventory[${xx}].Name} - ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Type]} - ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
			;// if ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Type].String.Equal[${TypeToDeposit}]} || ( ${TypeToDeposit.Equal[all]} && ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}](exists)} )
			if ${FullResources.Element["${CurrentResource}"](exists)}
				continue
			switch ${setEQ2OgreDepotResourceInfo.FindSetting["${Me.CustomInventory[${xx}].Name}"].FindAttribute[Type].String}
			{
				case raw
					if ${This.Commons}
					{
						echo Adding Raw to Depot: ${Me.CustomInventory[${xx}].Name} - Tier: ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
						Me.CustomInventory[${xx}]:AddToDepot[${DepotID}]
						wait 5
					}
				break
				case rare
					if ${This.Rares}
					{
						echo Adding Rare to Depot: ${Me.CustomInventory[${xx}].Name} - Tier: ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
						Me.CustomInventory[${xx}]:AddToDepot[${DepotID}]
						wait 5
					}
				break
				case mute
					if ( ${Me.CustomInventory[${xx}].Name.Find[fragment](exists)} && ${This.Fragments} ) || \
						( ${Me.CustomInventory[${xx}].Name.Find[Powder](exists)} && ${This.Powders} ) || \
						( ${Me.CustomInventory[${xx}].Name.Find[Infusion](exists)} && ${This.Infusions} ) || \
						( ${Me.CustomInventory[${xx}].Name.Find[Mana](exists)} && ${This.Manas} ) 
					{
						echo Adding Mutable to Depot: ${Me.CustomInventory[${xx}].Name} - Tier: ${setEQ2OgreDepotResourceInfo.FindSetting[${Me.CustomInventory[${xx}].Name}].FindAttribute[Tier]}
						Me.CustomInventory[${xx}]:AddToDepot[${DepotID}]
						wait 5
					}
				break
			}
			
		}
		Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]
	}
}
function DepotAll(int64 DepotID)
{
	if ${Actor[id,${DepotID}].Distance} < 11.5
	{
		Actor[id,${DepotID}]:DoubleClick
		wait 20 ${ContainerWindow(exists)}
		wait 5
		;// Old way: EQ2UIPage[Inventory,Container].Child[button,Container.CommandDepositAll]:LeftClick
		;// CHANGE LINE ABOVE: EQ2UIPage[Inventory,Container].Child[button,Container.TabPages.Items.CommandDepositAll]:LeftClick
		EQ2UIPage[Inventory,Container].Child[button,Container.TabPages.Items.CommandDepositAll]:LeftClick
		echo ${Time} Using Deposit All.
		wait 20
		EQ2UIPage[Inventory,container].Child[button,Container.WindowFrame.Close]:LeftClick
		wait 5
	}
	else
	{
		echo ${Time}: Depot ( ${Actor[id,${DepotID}].Name} ) is out of range. ${Actor[id,${DepotID}].Distance} needs to be less than 11 meters.
	}
}

variable settingsetref setEQ2OgreDepotAmmoInfo
function LoadAmmoResources()
{
	variable string ResourceConfigFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/EQ2OgreDepotAmmoInformation.xml"
	;// LavishSettings[EQ2OgreDepotResourceInformation]:Clear
	LavishSettings:AddSet[EQ2OgreDepotAmmoInformation]
	LavishSettings[EQ2OgreDepotAmmoInformation]:Import[${ResourceConfigFile}]
	LavishSettings[EQ2OgreDepotAmmoInformation]:AddSet[EQ2OgreDepotResourceInfo]
	setEQ2OgreDepotAmmoInfo:Set[${LavishSettings[EQ2OgreDepotAmmoInformation].FindSet[EQ2OgreDepotAmmoInfo]}]
}
variable settingsetref setEQ2OgreDepotResourceInfo
function LoadResources()
{
	variable string ResourceConfigFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/EQ2OgreDepotResourceInformation.xml"
	;// LavishSettings[EQ2OgreDepotResourceInformation]:Clear
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
		if ${Message.Find["This container cannot hold any more unique items."]}
	{
		echo Cannot add ${CurrentResource} because the depot has no more room..
		FullResources:Set[${CurrentResource},${CurrentResource}]
	}
	
}