;======================
/* Sell List

	Usage
	____________________________________

	**Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Sell.iss"

	**In your script call the following object with these commands, or type this in the console

	Friends Methods(Things you can do)
		obj_sell:Add[Name of Item to Sell]
		obj_sell:Remove[Name of Item]
		obj_sell:Populate[fieldName@frameName@TabName@TabControlName@WindowName]
		obj_sell:Sell
	
	Notes
	____________________________________
	**  You dont need to know how an object works to use it.  
	**  Objects are bits of code that perform specific functions.
	**  This function specifically Sells items from your inventory to a Merchant


	Credits
	____________________________________
 	*  Created by mmoaddict
	*  Special Thanks to Amadeus and Lax for all their work
	
*/
;======================

objectdef obj_sell
{
	;======================
	/* Object Variables */
	;======================

	variable settingsetref sell_ssr

;===================================================
;===       Methods/Members to be Used           ====
;===================================================

	method Add(string ItemName)
	{
		if ( ${ItemName.Length} > 1 )
			{
			This:LS
			LavishSettings[sell].FindSet[sellList]:AddSetting[${ItemName}, ${ItemName}]
			This:XMLSave
			}
			
	}
	method Remove(string ItemName)
	{
		if ( ${ItemName.Length} > 1 )
			{
			This:LS
			sell_ssr.FindSetting[${ItemName}]:Remove
			This:XMLSave
			}
	}

	method Populate(string UIElementXML)
	{
		This:LS

		variable iterator Iter
		sell_ssr:GetSettingIterator[Iter]
		UIElement[${UIElementXML}]:ClearItems
		while ( ${Iter.Key(exists)} )
			{
			UIElement[${UIElementXML}]:AddItem[${Iter.Key}]
			Iter:Next
			}

	}
	method Sell()
	{
		variable int i
	  for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
		{
		This:LS
		  variable iterator Itera
	   	sell_ssr:GetSettingIterator[Itera]
	   	while ( ${Itera.Key(exists)} )
			  {
	      if ${Me.Inventory[${i}].Name.Equal[${Itera.Key}]}
	                {
              		Me.Inventory[${i}]:Sell[${Me.Inventory[${i}].Quantity}]
              		}
			  Itera:Next
			  }

		}
		


	}




;===================================================
;===          DO NOT USE THESE ROUTINES         ====
;===================================================


	;============================
	/*      LavishSettings     */
	;============================
	method LS()
	{
		LavishSettings[sell]:Clear
		LavishSettings:AddSet[sell]
		LavishSettings[sell]:AddSet[sellList]
		LavishSettings[sell]:Import[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_sell.xml]	
		sell_ssr:Set[${LavishSettings[sell].FindSet[sellList]}]
	}

	;============================
	/*  Save Variables to XML  */
	;============================
	method XMLSave()
	{
		LavishSettings[sell]:Export[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_sell.xml]
	}

}

variable(global) obj_sell obj_sell
