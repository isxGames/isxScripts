;// Words of Pure Magic Clicker Script
;// Last Updated: July 15, 2011
;// Written By: bjcasey
;// Thanks to Macker for the ReplyDialog syntax.

variable int timeuntilnext

variable(global) TimerObject timeuntilnextmilli

function main()
{
			
	echo ${Time}: Starting Script
	
	if ${UserEndTimeVar} <= 24
	{
		if ${Time.Hour} == ${UserEndTimeVar}
		{
			echo ${Time}: Your end time can't be equal to your current time.
			statusvar:Set["End time can't be equal to your current time."]
			UIElement[${timerunningvar}]:Hide
			UIElement[${timerunningvar2}]:Show
			UIElement[${StartClicker}]:Show
			UIElement[${StopClicker}]:Hide
			endscript bjmagic
		}
		while ${Time.Hour} != ${UserEndTimeVar}
		{

	;// Test time below
	;//		timeuntilnext:Set[100]
		
	;// Real time below
			timeuntilnext:Set[${Math.Rand[300000]:Inc[600000]}]
		
	;// 300000 = 5 Minutes
	;// 600000 = 10 Minutes
	;// Time range is 10 Minutes to 15 Minutes.
		
			timeuntilnextmilli:Set[${timeuntilnext}]
			
			echo ${Time}: Attempt number ${Count} to click shrine
			
			if ${Actor[special,"Druzaic Shrine"].Name(exists)} && ${Actor[special,"Druzaic Shrine"].Distance} <= 10
			{
			
				EQ2execute "/apply_verb ${Actor[druzaic shrine].ID} inspect"
			
				wait 30
			
				ReplyDialog:Choose[1]
			
				wait 30
			
				ReplyDialog:Choose[1]
				
				wait 30
				
				echo ${Time}: Shrine clicked
				statusvar:Set["Shrine clicked."]
				wait 30
				
				UIElement[${timerunningvar}]:Hide
				UIElement[${timerunningvar2}]:Show
				UIElement[${startclickervar}]:Show
				UIElement[${stopclickervar}]:Hide
				endscript bjmagic
				
			}

			if !${Actor[special,"Druzaic Shrine"].Name(exists)} || ${Actor[special,"Druzaic Shrine"].Distance} > 10
			{
				echo ${Time}: Shrine not detected.
				echo ${Time}: Waiting [${Math.Calc[(${timeuntilnextmilli.TimeLeft}/1000)/60].Centi}] minutes before next attempt.
				statusvar:Set["Waiting for next attempt."]
				wait ${Math.Calc[${timeuntilnext}/100]}
				count:Inc
			}
		}
	}
	else
	{
		echo ${Time}: Please enter a valid end time.
		statusvar:Set["Please enter a valid end time."]
		UIElement[${timerunningvar}]:Hide
		UIElement[${timerunningvar2}]:Show
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript bjmagic
	}	
	
}

objectdef TimerObject
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}

	member:uint TimeLeft()
	{
		if ${Script.RunningTime}>=${EndTime}
			return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}		

function atexit()
{
	UIElement[${timerunningvar}]:Hide
	UIElement[${timerunningvar2}]:Show
	UIElement[${startclickervar}]:Show
	UIElement[${stopclickervar}]:Hide
	echo ${Time}: Stopping Script

	
}