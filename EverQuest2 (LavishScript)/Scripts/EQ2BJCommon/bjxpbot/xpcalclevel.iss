;// XP Calculations Variables
variable int gainedlevel
variable int startlevel
variable int currentlevel
variable float startxp
variable float currentxp
variable float gainedxp
variable(global) float totalxp1
variable(global) float totalxp
variable(global) float timerunninghour

function main()
{
	if ${UIElement[${EnableAdvXPCheckboxvar}].Checked}
	{
		if ${UIElement[${EnableAdvXPCalcDebugCheckboxvar}].Checked}
		{	
			;// Start of XP Calculations Debug
			;// Start of XP Calculations
		startlevel:Set[${Me.Level}]
		startxp:Set[${Me.Exp}]
		
		while 1
		{
			waitframe
						
			currentlevel:Set[${Me.Level}]
			timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]
			
			if ${startlevel} < ${currentlevel}
			{

				echo ${Time}: Code1
				echo ${Time}: timerunninghour: ${timerunninghour}
				echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
				echo ${Time}: Math runningtime: ${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo totalxp: ${totalxp}
				echo totalxp1: ${totalxp1}
				currentxp:Set[${Me.Exp}]
				gainedlevel:Set[${Math.Calc[${currentlevel}-${startlevel}]}]
				totalxp:Set[${Math.Calc[(${gainedlevel}*100)-100+${currentxp}+${totalxp1}]}]
				UIElement[${XpCalc2}]:Show
				UIElement[${XpCalc}]:Hide	
				UIElement[${XpCalcPerHour2}]:Show
				UIElement[${XpCalcPerHour}]:Hide				
			}
			elseif ${startlevel} == ${currentlevel}
			{

				echo ${Time}: Code2
				echo ${Time}: timerunninghour: ${timerunninghour}
				echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
				echo ${Time}: Math runningtime: ${Math.Calc[((((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo currentxp:Set[${Me.Exp}]
				echo startxp: ${startxp}
				echo gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
				echo totalxp: ${totalxp}
				echo totalxp1: ${totalxp1}
				echo totalxp1:Set[${gainedxp}]
				currentxp:Set[${Me.Exp}]
				gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
				totalxp1:Set[${gainedxp}]
			}	
		}	
		}	
		
		;// Start of XP Calculations
		startlevel:Set[${Me.Level}]
		startxp:Set[${Me.Exp}]
		
		while 1
		{
			waitframe
						
			currentlevel:Set[${Me.Level}]
			timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]
			
			if ${startlevel} < ${currentlevel}
			{

			/*	echo ${Time}: Code1
				echo ${Time}: timerunninghour: ${timerunninghour}
				echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
				echo ${Time}: Math runningtime: ${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo totalxp: ${totalxp}
				echo totalxp1: ${totalxp1}
			*/	currentxp:Set[${Me.Exp}]
				gainedlevel:Set[${Math.Calc[${currentlevel}-${startlevel}]}]
				totalxp:Set[${Math.Calc[(${gainedlevel}*100)-100+${currentxp}+${totalxp1}]}]
				UIElement[${XpCalc2}]:Show
				UIElement[${XpCalc}]:Hide	
				UIElement[${XpCalcPerHour2}]:Show
				UIElement[${XpCalcPerHour}]:Hide				
			}
			elseif ${startlevel} == ${currentlevel}
			{

			/*	echo ${Time}: Code2
				echo ${Time}: timerunninghour: ${timerunninghour}
				echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
				echo ${Time}: Math runningtime: ${Math.Calc[((((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo currentxp:Set[${Me.Exp}]
				echo startxp: ${startxp}
				echo gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
				echo totalxp: ${totalxp}
				echo totalxp1: ${totalxp1}
				echo totalxp1:Set[${gainedxp}]
			*/	currentxp:Set[${Me.Exp}]
				gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
				totalxp1:Set[${gainedxp}]
			}	
		}	
	}
	if ${UIElement[${EnableAAXPCheckboxvar}].Checked}
	{
		if ${UIElement[${EnableAAXPCalcDebugCheckboxVar}].Checked}
		{
			;// Start of AAXP Calculations Debugging
			startlevel:Set[${Me.TotalEarnedAPs}]
			startxp:Set[${Me.APExp}]
			
			while ${Time.Hour} != ${UserEndTimeVar}
			{
				waitframe
							
				currentlevel:Set[${Me.TotalEarnedAPs}]
				timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]
				
				if ${startlevel} < ${currentlevel}
				{

					echo ${Time}: Code1
					echo ${Time}: timerunninghour: ${timerunninghour}
					echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
					echo ${Time}: Math runningtime: ${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
					echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
					echo totalxp: ${totalxp}
					echo totalxp1: ${totalxp1}
					currentxp:Set[${Me.APExp}]
					gainedlevel:Set[${Math.Calc[${currentlevel}-${startlevel}]}]
					totalxp:Set[${Math.Calc[(${gainedlevel}*100)-100+${currentxp}+${totalxp1}]}]
					UIElement[${XpCalc2}]:Show
					UIElement[${XpCalc}]:Hide	
					UIElement[${XpCalcPerHour2}]:Show
					UIElement[${XpCalcPerHour}]:Hide				
				}
				elseif ${startlevel} == ${currentlevel}
				{

					echo ${Time}: Code2
					echo ${Time}: timerunninghour: ${timerunninghour}
					echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
					echo ${Time}: Math runningtime: ${Math.Calc[((((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
					echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
					echo currentxp:Set[${Me.Exp}]
					echo startxp: ${startxp}
					echo gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
					echo totalxp: ${totalxp}
					echo totalxp1: ${totalxp1}
					echo totalxp1:Set[${gainedxp}]
					currentxp:Set[${Me.APExp}]
					gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
					totalxp1:Set[${gainedxp}]
				}	
			}
		}		
		;// Start of AAXP Calculations
		startlevel:Set[${Me.TotalEarnedAPs}]
		startxp:Set[${Me.APExp}]
		
		while ${Time.Hour} != ${UserEndTimeVar}
		{
			waitframe
						
			currentlevel:Set[${Me.TotalEarnedAPs}]
			timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]
			
			if ${startlevel} < ${currentlevel}
			{

			/*	echo ${Time}: Code1
				echo ${Time}: timerunninghour: ${timerunninghour}
				echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
				echo ${Time}: Math runningtime: ${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo totalxp: ${totalxp}
				echo totalxp1: ${totalxp1}
			*/	currentxp:Set[${Me.APExp}]
				gainedlevel:Set[${Math.Calc[${currentlevel}-${startlevel}]}]
				totalxp:Set[${Math.Calc[(${gainedlevel}*100)-100+${currentxp}+${totalxp1}]}]
				UIElement[${XpCalc2}]:Show
				UIElement[${XpCalc}]:Hide	
				UIElement[${XpCalcPerHour2}]:Show
				UIElement[${XpCalcPerHour}]:Hide				
			}
			elseif ${startlevel} == ${currentlevel}
			{

			/*	echo ${Time}: Code2
				echo ${Time}: timerunninghour: ${timerunninghour}
				echo ${Time}: RunningTime: ${Script[xpcalclevel].RunningTime}
				echo ${Time}: Math runningtime: ${Math.Calc[((((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo ${Time}: Math totalxp1/Time: ${Math.Calc[${totalxp1}/(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}
				echo currentxp:Set[${Me.Exp}]
				echo startxp: ${startxp}
				echo gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
				echo totalxp: ${totalxp}
				echo totalxp1: ${totalxp1}
				echo totalxp1:Set[${gainedxp}]
			*/	currentxp:Set[${Me.APExp}]
				gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
				totalxp1:Set[${gainedxp}]
			}	
		}	
	}	
}


function atexit()
{
	echo ${Time}: Stopping XP Calc Script
	endscript xpcalclevel
}	