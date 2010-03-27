;======================
/* Friends

	Usage
	____________________________________

	**Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Trash.iss"

	**In your script call the following object with these commands, or type this in the console

	Friends Methods(Things you can do)
		obj_trash:Add[Name of your Friend]
		obj_trash:Remove[Name of your Past Friend]
		obj_trash:Populate[fieldName@frameName@TabName@TabControlName@WindowName]
		obj_trash:Destroy
	
	Notes
	____________________________________
	**  You dont need to know how an object works to use it.  
	**  Objects are bits of code that perform specific functions.
	**  This function specifically Destroys trash items from your inventory


	Credits
	____________________________________
 	*  Created by mmoaddict
	*  Special Thanks to Amadeus and Lax for all their work
	
*/
;======================

objectdef obj_trash
{
	;======================
	/* Object Variables */
	;======================

	variable settingsetref Trash_ssr

;===================================================
;===       Methods/Members to be Used           ====
;===================================================

	method Add(string ItemName)
	{
		if ( ${ItemName.Length} > 1 )
			{
			echo adding ${ItemName}
			This:LS
			LavishSettings[Trash].FindSet[TrashList]:AddSetting[${ItemName}, ${ItemName}]
			This:XMLSave
			}
			
	}
	method Remove(string ItemName)
	{
		if ( ${ItemName.Length} > 1 )
			{
			This:LS
			ItemName_ssr.FindSetting[${ItemName}]:Remove
			This:XMLSave
			}
	}

	method Populate(string UIElementXML)
	{
		This:LS

		variable iterator Iter
		Trash_ssr:GetSettingIterator[Iter]
		UIElement[${UIElementXML}]:ClearItems
		while ( ${Iter.Key(exists)} )
			{
			UIElement[${UIElementXML}]:AddItem[${Iter.Key}]
			Iter:Next
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
		LavishSettings[Trash]:Clear
		LavishSettings:AddSet[Trash]
		LavishSettings[Trash]:AddSet[TrashList]
		LavishSettings[Trash]:Import[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_Trash.xml]	
		Trash_ssr:Set[${LavishSettings[Trash].FindSet[TrashList]}]
	}

	;============================
	/*  Save Variables to XML  */
	;============================
	method XMLSave()
	{
		LavishSettings[Trash]:Export[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_Trash.xml]
	}

}

variable(global) obj_trash obj_trash
