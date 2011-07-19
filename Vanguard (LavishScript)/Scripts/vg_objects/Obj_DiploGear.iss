;======================
/* Diplo Gear

	Usage
	____________________________________

	**Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_DiploGear.iss"

	**In your script call the following object with these commands, or type this in the console

	Loading Gear(It will automatically put the saved set of gear on your toon)
		obj_diplogear:Load[Merchants]
		obj_diplogear:Load[Academics]
		obj_diplogear:Load[Outsiders]
		obj_diplogear:Load[Domestics]
		obj_diplogear:Load[Soldiers]
		obj_diplogear:Load[Nobles]
		obj_diplogear:Load[Craftsmen]
		obj_diplogear:Load[Clergy]
	
	Saving Gear(Manually Put the Gear you want to save on your toon)
		obj_diplogear:Save[Merchants]
		obj_diplogear:Save[Academics]
		obj_diplogear:Save[Outsiders]
		obj_diplogear:Save[Domestics]
		obj_diplogear:Save[Soldiers]
		obj_diplogear:Save[Nobles]
		obj_diplogear:Save[Craftsmen]
		obj_diplogear:Save[Clergy]
	
	Notes
	____________________________________
	**  You dont need to know how an object works to use it.  
	**  Objects are bits of code that perform specific functions.
	**  This function specifically loads and saves sets of diplomacy gear 
	**  You can switch Diplomacy sets quickly either from a script or from the console
	**  You have to Save a gear set before you can Load it!

	Credits
	____________________________________
 	*  Created by mmoaddict
	*  Special Thanks to Amadeus and Lax for all their work
	
*/
;======================

objectdef obj_diplogear
{
	;======================
	/* Object Variables */
	;======================
	variable string DiploLeftEar
	variable string DiploRightEar
	variable string DiploFace
	variable string DiploCloak
	variable string DiploNeck
	variable string DiploShoulders
	variable string DiploWrist
	variable string DiploChest
	variable string DiploHands
	variable string DiploHeld
	variable string DiploBelt
	variable string DiploBoots
	variable string DiploLeftRing
	variable string DiploRightRing
	variable string DiploLegs

	variable settingsetref GearSet_ssr

;===================================================
;===           Methods to be Used               ====
;===================================================

	method Load(string Presence, bool debug)
	{
		call ConvertPresence "${Presence}"
		if ${Return} > 0
			{
			This:EquipGear[${Return}]
			}
			
	}
	function Load2(string Presence, bool debug)
	{
		call ConvertPresence "${Presence}"
		if ${Return} > 0
			{
			call This.EquipGear2 "${Return}"
			}
			
	}
	method Save(string Presence, bool debug)
	{
		call ConvertPresence "${Presence}"
		if ${Return} > 0
			{ 
			This:XMLSave[${Return}]
			}
	}

;===================================================
;===          DO NOT USE THESE ROUTINES         ====
;===================================================


	;============================
	/*      Equip Gear Loaded  */
	;============================
	method EquipGear(int di, bool debug)
	{
		; Slow it down, we are crashing
		Turbo 20
	
		This:XMLLoad[${di}]
	
		;Unequip Gear On
		;------------------

		Me.Inventory[CurrentEquipSlot, Diplomacy Left Ear]:Unequip
		Me.Inventory[CurrentEquipSlot, Diplomacy Right Ear]:Unequip
		Me.Inventory[CurrentEquipSlot, Diplomacy Left Finger]:Unequip
		Me.Inventory[CurrentEquipSlot, Diplomacy Right Finger]:Unequip

		;Equip Desired Gear
		;------------------
		
		;Account for Same Name and ID Earrings
		;-------------------------------------

		if ${DiploLeftEar.Equal[${DiploRightEar}]}
			{
			variable int i
			for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
				{
					if ${Me.Inventory[${i}].Name.Equal[${DiploLeftEar}]}
						{
						Me.Inventory[${i}]:Equip
						i:Inc
						}
					if ${Me.Inventory[${i}].Name.Equal[${DiploRightEar}]} 
						{
						Me.Inventory[${i}]:Equip
						}
				}
			}
			
		if ${DiploLeftEar.NotEqual[${DiploRightEar}]}
			{
			Me.Inventory[${DiploLeftEar}]:Equip
			Me.Inventory[${DiploRightEar}]:Equip	
			}	

		;Account for Same Name and ID Rings
		;-------------------------------------
		
		if ${DiploLeftRing.Equal[${DiploRightRing}]}
			{
			variable int ri
			for (ri:Set[1] ; ${ri}<=${Me.Inventory} ; ri:Inc)
				{
					if ${Me.Inventory[${ri}].Name.Equal[${DiploLeftRing}]}
						{
						Me.Inventory[${ri}]:Equip
						i:Inc
						}
					if ${Me.Inventory[${ri}].Name.Equal[${DiploRightRing}]} 
						{
						Me.Inventory[${ri}]:Equip
						}
				}
			}
			
		if ${DiploLeftRing.NotEqual[${DiploRightRing}]}
			{
			Me.Inventory[${DiploLeftRing}]:Equip
			Me.Inventory[${DiploRightRing}]:Equip	
			}

		;Load All Other Gear
		;-------------------------------------

		Me.Inventory[${DiploFace}]:Equip
		Me.Inventory[${DiploCloak}]:Equip
		Me.Inventory[${DiploNeck}]:Equip
		Me.Inventory[${DiploShoulders}]:Equip
		Me.Inventory[${DiploWrist}]:Equip
		Me.Inventory[${DiploChest}]:Equip
		Me.Inventory[${DiploHands}]:Equip
		Me.Inventory[${DiploHeld}]:Equip
		Me.Inventory[${DiploBelt}]:Equip
		Me.Inventory[${DiploBoots}]:Equip
		Me.Inventory[${DiploLegs}]:Equip
		
		;; Back to normal speed
		Turbo 75
	}

	;============================
	/*   Equip Gear Loaded     */
	;============================
	function EquipGear2(int di, bool debug)
	{
		; Slow it down, we are crashing
		Turbo 20
	
		This:XMLLoad[${di}]
	
		;Unequip Gear On
		;------------------

		Me.Inventory[CurrentEquipSlot, Diplomacy Left Ear]:Unequip
		Me.Inventory[CurrentEquipSlot, Diplomacy Right Ear]:Unequip
		Me.Inventory[CurrentEquipSlot, Diplomacy Left Finger]:Unequip
		Me.Inventory[CurrentEquipSlot, Diplomacy Right Finger]:Unequip
		waitframe
		
		;Equip Desired Gear
		;------------------
		
		;Account for Same Name and ID Earrings
		;-------------------------------------

		if ${DiploLeftEar.Equal[${DiploRightEar}]}
			{
			variable int i
			for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
				{
					if ${Me.Inventory[${i}].Name.Equal[${DiploLeftEar}]}
						{
						Me.Inventory[${i}]:Equip
						i:Inc
						}
					if ${Me.Inventory[${i}].Name.Equal[${DiploRightEar}]} 
						{
						Me.Inventory[${i}]:Equip
						}
				}
			}
			
		if ${DiploLeftEar.NotEqual[${DiploRightEar}]}
			{
			Me.Inventory[${DiploLeftEar}]:Equip
			Me.Inventory[${DiploRightEar}]:Equip	
			}	
			
		;Account for Same Name and ID Rings
		;-------------------------------------
		
		if ${DiploLeftRing.Equal[${DiploRightRing}]}
			{
			variable int ri
			for (ri:Set[1] ; ${ri}<=${Me.Inventory} ; ri:Inc)
				{
					if ${Me.Inventory[${ri}].Name.Equal[${DiploLeftRing}]}
						{
						Me.Inventory[${ri}]:Equip
						i:Inc
						}
					if ${Me.Inventory[${ri}].Name.Equal[${DiploRightRing}]} 
						{
						Me.Inventory[${ri}]:Equip
						}
				}
			}
			
		if ${DiploLeftRing.NotEqual[${DiploRightRing}]}
			{
			Me.Inventory[${DiploLeftRing}]:Equip
			Me.Inventory[${DiploRightRing}]:Equip	
			}
			

		;Load All Other Gear
		;-------------------------------------

		waitframe
		Me.Inventory[${DiploFace}]:Equip
		Me.Inventory[${DiploCloak}]:Equip
		Me.Inventory[${DiploNeck}]:Equip
		Me.Inventory[${DiploShoulders}]:Equip
		Me.Inventory[${DiploWrist}]:Equip
		Me.Inventory[${DiploChest}]:Equip
		Me.Inventory[${DiploHands}]:Equip
		Me.Inventory[${DiploHeld}]:Equip
		Me.Inventory[${DiploBelt}]:Equip
		Me.Inventory[${DiploBoots}]:Equip
		Me.Inventory[${DiploLegs}]:Equip
		waitframe
		
		;; Back to normal speed
		Turbo 75
	}
	
	
	;============================
	/* Load Variables From XML */
	;============================
	method XMLLoad(int di, bool debug)
	{
		;Load Lavish Settings 

		This:LS

		;Set values for the Gearset Desired

		DiploLeftEar:Set[${GearSet_ssr.FindSetting[DiploLeftEar_${di}]}]
		DiploRightEar:Set[${GearSet_ssr.FindSetting[DiploRightEar_${di}]}]
		DiploFace:Set[${GearSet_ssr.FindSetting[DiploFace_${di}]}]
		DiploCloak:Set[${GearSet_ssr.FindSetting[DiploCloak_${di}]}]
		DiploNeck:Set[${GearSet_ssr.FindSetting[DiploNeck_${di}]}]
		DiploShoulders:Set[${GearSet_ssr.FindSetting[DiploShoulder_${di}]}]
		DiploWrist:Set[${GearSet_ssr.FindSetting[DiploWrist_${di}]}]
		DiploChest:Set[${GearSet_ssr.FindSetting[DiploChest_${di}]}]
		DiploHands:Set[${GearSet_ssr.FindSetting[DiploHands_${di}]}]
		DiploHeld:Set[${GearSet_ssr.FindSetting[DiploHeld_${di}]}]
		DiploBelt:Set[${GearSet_ssr.FindSetting[DiploBelt_${di}]}]
		DiploBoots:Set[${GearSet_ssr.FindSetting[DiploBoots_${di}]}]
		DiploLeftRing:Set[${GearSet_ssr.FindSetting[DiploLeftRing_${di}]}]
		DiploRightRing:Set[${GearSet_ssr.FindSetting[DiploRightRing_${di}]}]
		DiploLegs:Set[${GearSet_ssr.FindSetting[DiploLegs_${di}]}]
	
	}

	;============================
	/*      LavishSettings     */
	;============================
	method LS()
	{
		LavishSettings[DiploGear]:Clear
		LavishSettings:AddSet[DiploGear]
		LavishSettings[DiploGear]:AddSet[GearSet]
		LavishSettings[DiploGear]:Import[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_DiploGear_${Me.FName}.xml]	
		GearSet_ssr:Set[${LavishSettings[DiploGear].FindSet[GearSet]}]
	}
	method SSR()
	{
		
	}

	;============================
	/*  Save Variables to XML  */
	;============================
	method XMLSave(int di, bool debug)
	{
		;Load Lavish Settings 

		This:LS

		;Save my Current Gear to Desired Gear Set

		GearSet_ssr:AddSetting[DiploLeftEar_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Left Ear]}]
		GearSet_ssr:AddSetting[DiploRightEar_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Right Ear]}]
		GearSet_ssr:AddSetting[DiploFace_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Head]}]
		GearSet_ssr:AddSetting[DiploCloak_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Cloak]}]
		GearSet_ssr:AddSetting[DiploNeck_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Neck]}]
		GearSet_ssr:AddSetting[DiploShoulder_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Shoulder]}]
		GearSet_ssr:AddSetting[DiploWrist_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Wrists]}]
		GearSet_ssr:AddSetting[DiploChest_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Chest]}]
		GearSet_ssr:AddSetting[DiploHands_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Hands]}]
		GearSet_ssr:AddSetting[DiploHeld_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Held Item]}]
		GearSet_ssr:AddSetting[DiploBelt_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Waist]}]
		GearSet_ssr:AddSetting[DiploBoots_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Feet]}]
		GearSet_ssr:AddSetting[DiploLeftRing_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Left Finger]}]
		GearSet_ssr:AddSetting[DiploRightRing_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Right Finger]}]
		GearSet_ssr:AddSetting[DiploLegs_${di},${Me.Inventory[CurrentEquipSlot, Diplomacy Legs]}]

		LavishSettings[DiploGear]:Export[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_DiploGear_${Me.FName}.xml]

	}

}

function(global):int ConvertPresence(string Presence)
{
		switch ${Presence}
			{
			case 1
				Return 1
			case Merchants
				Return 1
			case 2
				Return 2
			case Academics
				Return 2
			case 3
				Return 3
			case Outsiders
				Return 3
			case 4
				Return 4
			case Domestics
				Return 4
			case 5
				Return 5
			case Soldiers
				Return 5
			case 6
				Return 6
			case Nobles
				Return 6
			case 7
				Return 7
			case Craftsmen
				Return 7
			case 8
				Return 8
			case Clergy
				Return 8
			default
				Return 0
			}
}
function(global):string PresenceNeeded()
{
	variable int i
	for (i:Set[1] ; ${i}<=${Dialog[Civic Diplomacy].ResponseCount} ; i:Inc)
	{
		if ${Dialog[Civic Diplomacy,${i}].PresenceRequiredType(exists)}
		{
			switch ${Dialog[Civic Diplomacy,${i}].PresenceRequiredType}
			{
				case Academic Presence
					Return Academics
				case Merchant Presence
					Return Merchants
				case Outsider Presence
					Return Outsiders
				case Domestic Presence
					Return Domestics
				case Soldier Presence
					Return Soldiers
				case Noble Presence
					Return Nobles
				case Craftsmen Presence
					Return Craftsmen
				case Crafter Presence
					Return Craftsmen
				case Clergy Presence
					Return Clergy			
				Default
					Return PresenceNotFound
			}
		}
	}
	for (i:Set[1] ; ${i}<=${Dialog[General].ResponseCount} ; i:Inc)
	{
		if ${Dialog[General,${i}].PresenceRequiredType(exists)}
		{
			switch ${Dialog[General,${i}].PresenceRequiredType}
			{
				case Academic Presence
					Return Academics
				case Merchant Presence
					Return Merchants
				case Outsider Presence
					Return Outsiders
				case Domestic Presence
					Return Domestics
				case Soldier Presence
					Return Soldiers
				case Noble Presence
					Return Nobles
				case Craftsmen Presence
					Return Craftsmen
				case Crafter Presence
					Return Craftsmen
				case Clergy Presence
					Return Clergy			
				Default
					Return PresenceNotFound
			}
		}
	}
}

variable(global) obj_diplogear obj_diplogear