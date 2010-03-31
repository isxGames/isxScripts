;======================
/* Timers

	Usage
	____________________________________

	**Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Timers.iss"

	**In your script call the following object with these commands, or type this in the console

	Timers Methods(Things you can do)
		obj_timer:Add["Name of Timer" "Time in 1/10 Seconds"]
		obj_timer:Remove[Name of Timer]
		obj_timer:ClearAllTimers
		
  Timers Members(Things you can question of Timers)	
		obj_timer.TimeRemaining["Name of Timer"]

	
	Notes
	____________________________________
	**  You dont need to know how an object works to use it.  
	**  Objects are bits of code that perform specific functions.
	**  This function specifically Creates Timers for you
	**  You should clear all timers at the beginning and end of your script


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
			echo adding ${Script.Filename} ${TimerName} ${Script.RunningTime} ${TimeSet} ${Math.Calc[(${TimeSet} + ${Script.RunningTime}]}
			This:LS
			LavishSettings[Timers].FindSet[TimersList]:AddSetting[${TimerName}, ${Math.Calc[(${TimeSet} + ${Script.RunningTime}]}]
			This:XMLSave
			}
			
	}
	method Remove(string TimerName)
	{
		if ( ${TimerName.Length} > 1 )
			{
			This:LS
			Timers_ssr.FindSetting[${TimerName}]:Remove
			This:XMLSave
			}
	}
	method ClearAllTimers()
	{
  	This:LS
  	variable iterator Iter
		Timers_ssr:GetSettingIterator[Iter]
		Iter:First
		while ( ${Iter.Key(exists)} )
			{
      Timers_ssr.FindSetting[${Iter.Key}]:Remove
			Iter:Next
			}
		This:XMLSave
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
		LavishSettings[Timers]:Clear
		LavishSettings:AddSet[Timers]
		LavishSettings[Timers]:AddSet[TimersList]
		LavishSettings[Timers]:Import[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_Timers_${Script.Filename}_${Me.FName}.xml]	
		Timers_ssr:Set[${LavishSettings[Timers].FindSet[TimersList]}]
	}

	;============================
	/*  Save Variables to XML  */
	;============================
	method XMLSave()
	{
		LavishSettings[Timers]:Export[${LavishScript.CurrentDirectory}/scripts/vg_objects/save/Obj_Timers_${Script.Filename}_${Me.FName}.xml]
	}

}



variable(global) obj_timer obj_timer
