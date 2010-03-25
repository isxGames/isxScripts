;======================
/* Friends

	Usage
	____________________________________

	**Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Friends.iss"

	**In your script call the following object with these commands, or type this in the console

	Friends Methods(Things you can do)
		obj_friends:Add[Name of your Friend]
		obj_friends:Remove[Name of your Past Friend]
		obj_friends:Populate[fieldName@frameName@TabName@TabControlName@WindowName]
	
	Friends Members(Thing you can question)
		obj_friends.IsFriend[Name of your Friend]
	
	Notes
	____________________________________
	**  You dont need to know how an object works to use it.  
	**  Objects are bits of code that perform specific functions.
	**  This function specifically Adds and Removes People from a Friend List 


	Credits
	____________________________________
 	*  Created by mmoaddict
	*  Special Thanks to Amadeus and Lax for all their work
	
*/
;======================

objectdef obj_friends
{
	;======================
	/* Object Variables */
	;======================

	variable settingsetref Friends_ssr

;===================================================
;===       Methods/Members to be Used           ====
;===================================================

	method Add(string FriendName)
	{
		if ( ${FriendName.Length} > 1 )
			{
			echo adding ${FriendName}
			This:LS
			LavishSettings[Friends].FindSet[FriendsList]:AddSetting[${FriendName}, ${FriendName}]
			This:XMLSave
			}
			
	}
	method Remove(string NoLongerFriendName)
	{
		if ( ${NoLongerFriendName.Length} > 1 )
			{
			This:LS
			Friends_ssr.FindSetting[${NoLongerFriendName}]:Remove
			This:XMLSave
			}
	}

	method Populate(string UIElementXML)
	{
		This:LS

		variable iterator Iter
		Friends_ssr:GetSettingIterator[Iter]
		UIElement[${UIElementXML}]:ClearItems
		while ( ${Iter.Key(exists)} )
			{
			UIElement[${UIElementXML}]:AddItem[${Iter.Key}]
			Iter:Next
			}

	}
	member:bool IsFriend(string QueryName)
	{
		This:LS

		variable iterator Iter
		Friends_ssr:GetSettingIterator[Iter]
		UIElement[${UIElementXML}]:ClearItems
		while ( ${Iter.Key(exists)} )
			{
			if ${QueryName.Equal[${Iter.Key}]}
				return TRUE
			Iter:Next
			}
		return FALSE

	}



;===================================================
;===          DO NOT USE THESE ROUTINES         ====
;===================================================


	;============================
	/*      LavishSettings     */
	;============================
	method LS()
	{
		LavishSettings[Friends]:Clear
		LavishSettings:AddSet[Friends]
		LavishSettings[Friends]:AddSet[FriendsList]
		LavishSettings[Friends]:Import[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_Friends.xml]	
		Friends_ssr:Set[${LavishSettings[Friends].FindSet[FriendsList]}]
	}

	;============================
	/*  Save Variables to XML  */
	;============================
	method XMLSave()
	{
		LavishSettings[Friends]:Export[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_Friends.xml]
	}

}

variable(global) obj_friends obj_friends