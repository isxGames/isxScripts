;======================
/* Timers

	Usage
	____________________________________

	**Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Timers.iss"

	**In your script call the following object with these commands, or type this in the console

		Timers Methods(Things you can do)
		obj_timer:Add["Name of Timer" "Time in 1/1000 Seconds"]
		obj_timer:Remove[Name of Timer]
		obj_timer:Clear

		Timers Members(Things you can question of Timers)
		obj_timer.TimeRemaining["Name of Timer"]


	Notes
	____________________________________
	**  You dont need to know how an object works to use it.
	**  Objects are bits of code that perform specific functions.
	**  This function specifically Creates Timers for you
	**  You should Clear Timers at the end of your script


	Credits
	____________________________________
	*  Created by mmoaddict
	*  Special Thanks to Amadeus and Lax for all their work

*/
;======================
variable settingsetref Timers_ssr

objectdef obj_timer
{
	;======================
	/* Object Variables */
	;======================



	;===================================================
	;===       Methods/Members to be Used           ====
	;===================================================

	method Add(string TimerName, int TimeSet)
	{
		if ( ${TimerName.Length} > 1 && ${TimeSet} > 1)
		{
			This:LS
			LavishSettings[Timers].FindSet[${Script.Filename}_${Me.FName}]:AddSetting[${TimerName}, ${Math.Calc[(${TimeSet} + ${Script.RunningTime}]}]
		}

	}
	method Remove(string TimerName)
	{
		if ( ${TimerName.Length} > 1 )
		{
			This:LS
			Timers_ssr.FindSetting[${TimerName}]:Remove
		}
	}
	method Clear()
	{
		LavishSettings[Timers].FindSet[${Script.Filename}_${Me.FName}]:Clear
	}
	member:uint TimeRemaining(string TimerName)
	{
		This:LS
		variable iterator Iter
		Timers_ssr:GetSettingIterator[Iter]
		Iter:First
		while ( ${Iter.Key(exists)} )
		{
			if ${Iter.Key.Equal[${TimerName}]}
			{
				if ${Script.RunningTime}>=${Iter.Value}
				return 0
				return ${Math.Calc[${Iter.Value}-${Script.RunningTime}]}
			}
			Iter:Next
		}
		return 0
	}

	;===================================================
	;===          DO NOT USE THESE ROUTINES         ====
	;===================================================


	;============================
	/*      LavishSettings     */
	;============================
	method LS()
	{
		LavishSettings:AddSet[Timers]
		LavishSettings[Timers]:AddSet[${Script.Filename}_${Me.FName}]
		Timers_ssr:Set[${LavishSettings[Timers].FindSet[${Script.Filename}_${Me.FName}]}]
	}


}



variable(global) obj_timer obj_timer


