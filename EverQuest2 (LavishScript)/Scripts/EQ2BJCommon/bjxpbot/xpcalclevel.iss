;// XP Calculations Variables
variable int gainedlevel
variable int startlevel
variable int currentlevel
variable float startxp
variable float currentxp
variable float gainedxp

variable int gainedAAlevel
variable int startAAlevel
variable int currentAAlevel
variable float startAAxp
variable float currentAAxp
variable float gainedAAxp

variable int gainedTSlevel
variable int startTSlevel
variable int currentTSlevel
variable float startTSxp
variable float currentTSxp
variable float gainedTSxp

function main()
{
	statusvar:Set["Checking which type of xp to track."]
	echo ${Time}: Checking which type of xp to track.

	totalxp:Set[0]
	totalxp1:Set[0]
	totalAAxp:Set[0]
	totalAAxp1:Set[0]
	totalTSxp:Set[0]
	totalTSxp1:Set[0]
	
	if ${UIElement[${EnableAdvXPCheckboxvar}].Checked}
	{
		UIElement[${TSVitalityTextVar}]:Hide
		UIElement[${VitalityTextVar}]:Show
		UIElement[${ADVXpCalcText2Var}]:Hide
		UIElement[${ADVXpCalcText1Var}]:Show	
		UIElement[${ADVXPCalcPerHourText2Var}]:Hide
		UIElement[${ADVXPCalcPerHourText1Var}]:Show 
		
		if ${UIElement[${EnableAAXPCheckboxvar}].Checked}
		{
			UIElement[${AAXpCalcText2Var}]:Hide
			UIElement[${AAXpCalcText1Var}]:Show	
			UIElement[${AAXPCalcPerHourText2Var}]:Hide
			UIElement[${AAXPCalcPerHourText1Var}]:Show 	
		}	
	}
	if ${UIElement[${EnableTSXPCheckboxvar}].Checked}
	{
		UIElement[${TSVitalityTextVar}]:Show
		UIElement[${VitalityTextVar}]:Hide
		UIElement[${TSXpCalcText2Var}]:Hide
		UIElement[${TSXpCalcText1Var}]:Show	
		UIElement[${TSXPCalcPerHourText2Var}]:Hide
		UIElement[${TSXPCalcPerHourText1Var}]:Show	
	}
	if ${UIElement[${EnableAAXPCheckboxvar}].Checked}
	{
		UIElement[${TSVitalityTextVar}]:Hide
		UIElement[${VitalityTextVar}]:Show
		UIElement[${AAXpCalcText2Var}]:Hide
		UIElement[${AAXpCalcText1Var}]:Show	
		UIElement[${AAXPCalcPerHourText2Var}]:Hide
		UIElement[${AAXPCalcPerHourText1Var}]:Show  	
	}
	
	startlevel:Set[${Me.Level}]
	startxp:Set[${Me.Exp}]
	startAAlevel:Set[${Me.TotalEarnedAPs}]
	startAAxp:Set[${Me.APExp}]
	startTSlevel:Set[${Me.TSLevel}]
	startTSxp:Set[${Me.TSExp}]
	
	while 1
	{
		while ${BJXPBotPause} == 0
		{
			call xpcalcleveltimer
		
			if ${UIElement[${EnableAdvXPCheckboxvar}].Checked}
			{
				call ADVXPCalculations 
				
				if ${UIElement[${EnableAAXPCheckboxvar}].Checked}
				{
				call AAXPCalculations 	
				}	
			}
			if ${UIElement[${EnableTSXPCheckboxvar}].Checked}
			{
				call TSXPCalculations 	
			}
			if ${UIElement[${EnableAAXPCheckboxvar}].Checked}
			{
				call AAXPCalculations 	
			}	
		}
	}	
}

function ADVXPCalculations()
{
	currentlevel:Set[${Me.Level}]
	timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]
	
	if ${startlevel} < ${currentlevel}
	{
		currentxp:Set[${Me.Exp}]
		gainedlevel:Set[${Math.Calc[${currentlevel}-${startlevel}]}]
		totalxp:Set[${Math.Calc[(${gainedlevel}*100)-100+${currentxp}+${totalxp1}]}]
		call ADVXPCalculationsFormat
		UIElement[${ADVXpCalcText2Var}]:Show
		UIElement[${ADVXpCalcText1Var}]:Hide	
		UIElement[${ADVXPCalcPerHourText2Var}]:Show
		UIElement[${ADVXPCalcPerHourText1Var}]:Hide				
	}
	elseif ${startlevel} == ${currentlevel}
	{
		currentxp:Set[${Me.Exp}]
		gainedxp:Set[${Math.Calc[${currentxp}-${startxp}]}]
		totalxp1:Set[${gainedxp}]
		call ADVXPCalculationsFormat
	}
}

function AAXPCalculations()
{
	currentAAlevel:Set[${Me.TotalEarnedAPs}]
	timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]
	
	if ${startAAlevel} < ${currentAAlevel}
	{
		currentAAxp:Set[${Me.APExp}]
		gainedAAlevel:Set[${Math.Calc[${currentAAlevel}-${startAAlevel}]}]
		totalAAxp:Set[${Math.Calc[(${gainedAAlevel}*100)-100+${currentAAxp}+${totalAAxp1}]}]
		call AAXPCalculationsFormat
		UIElement[${AAXpCalcText2Var}]:Show
		UIElement[${AAXpCalcText1Var}]:Hide	
		UIElement[${AAXPCalcPerHourText2Var}]:Show
		UIElement[${AAXPCalcPerHourText1Var}]:Hide				
	}
	elseif ${startAAlevel} == ${currentAAlevel}
	{
		currentAAxp:Set[${Me.APExp}]
		gainedAAxp:Set[${Math.Calc[${currentAAxp}-${startAAxp}]}]
		totalAAxp1:Set[${gainedAAxp}]
		call AAXPCalculationsFormat
	}	
}

function TSXPCalculations()
{
	currentTSlevel:Set[${Me.TSLevel}]
	timerunninghour:Set[${Math.Calc[(((${Script[xpcalclevel].RunningTime}/1000)/60/60))].Milli}]

	if ${startTSlevel} < ${currentTSlevel}
	{
		currentTSxp:Set[${Me.TSExp}]
		gainedTSlevel:Set[${Math.Calc[${currentTSlevel}-${startTSlevel}]}]
		totalTSxp:Set[${Math.Calc[(${gainedTSlevel}*100)-100+${currentTSxp}+${totalTSxp1}]}]
		call TSXPCalculationsFormat
		UIElement[${TSXpCalcText2Var}]:Show
		UIElement[${TSXpCalcText1Var}]:Hide	
		UIElement[${TSXPCalcPerHourText2Var}]:Show
		UIElement[${TSXPCalcPerHourText1Var}]:Hide				
	}
	elseif ${startTSlevel} == ${currentTSlevel}
	{
		currentTSxp:Set[${Me.TSExp}]
		gainedTSxp:Set[${Math.Calc[${currentTSxp}-${startTSxp}]}]
		totalTSxp1:Set[${gainedTSxp}]
		call TSXPCalculationsFormat
	}
}

function TSXPCalculationsFormat()
{
		DisplayTSPercent1:Set[${Math.Calc64[${totalTSxp1}%100]}]
		DisplayTSPercent:Set[${Math.Calc64[${totalTSxp}%100]}]
		DisplayTSLevels:Set[${Math.Calc[${totalTSxp}/100].Int}]
		
		if ${timerunninghour} > 0
		{	
			DisplayTSPercentPerHour:Set[${Math.Calc[(${totalTSxp}/${timerunninghour})%100]}]
			DisplayTSLevelsPerHour:Set[${Math.Calc[(${totalTSxp}/${timerunninghour})/100].Int}]
			DisplayTSPercentPerHour1:Set[${Math.Calc[(${totalTSxp1}/${timerunninghour})%100]}]
			DisplayTSLevelsPerHour1:Set[${Math.Calc[(${totalTSxp1}/${timerunninghour})/100].Int}]
		}	
;//		echo ${DisplayTSLevels.LeadingZeroes[3]}:${DisplayTSPercent.LeadingZeroes[2]}	
;//		echo ${DisplayTSLevelsPerHour.LeadingZeroes[3]}:${DisplayTSPercentPerHour.LeadingZeroes[2]}
}

function ADVXPCalculationsFormat()
{
		DisplayADVPercent1:Set[${Math.Calc64[${totalxp1}%100]}]
		DisplayADVPercent:Set[${Math.Calc64[${totalxp}%100]}]
		DisplayADVLevels:Set[${Math.Calc[${totalxp}/100].Int}]
		
		if ${timerunninghour} > 0
		{	
			DisplayADVPercentPerHour:Set[${Math.Calc[(${totalxp}/${timerunninghour})%100]}]
			DisplayADVLevelsPerHour:Set[${Math.Calc[(${totalxp}/${timerunninghour})/100].Int}]
			DisplayADVPercentPerHour1:Set[${Math.Calc[(${totalxp1}/${timerunninghour})%100]}]
			DisplayADVLevelsPerHour1:Set[${Math.Calc[(${totalxp1}/${timerunninghour})/100].Int}]
		}	
;//		echo ${DisplayADVLevels.LeadingZeroes[3]}:${DisplayADVPercent.LeadingZeroes[2]}	
;//		echo ${DisplayADVLevelsPerHour.LeadingZeroes[3]}:${DisplayADVPercentPerHour.LeadingZeroes[2]}
}

function AAXPCalculationsFormat()
{
		DisplayAAPercent1:Set[${Math.Calc64[${totalAAxp1}%100]}]
		DisplayAAPercent:Set[${Math.Calc64[${totalAAxp}%100]}]
		DisplayAALevels:Set[${Math.Calc[${totalAAxp}/100].Int}]
		
		if ${timerunninghour} > 0
		{	
			DisplayAAPercentPerHour:Set[${Math.Calc[(${totalAAxp}/${timerunninghour})%100]}]
			DisplayAALevelsPerHour:Set[${Math.Calc[(${totalAAxp}/${timerunninghour})/100].Int}]
			DisplayAAPercentPerHour1:Set[${Math.Calc[(${totalAAxp1}/${timerunninghour})%100]}]
			DisplayAALevelsPerHour1:Set[${Math.Calc[(${totalAAxp1}/${timerunninghour})/100].Int}]
		}	
;//		echo ${DisplayAALevels.LeadingZeroes[1]}:${DisplayAAPercent.LeadingZeroes[2]}	
;//		echo ${DisplayAALevelsPerHour.LeadingZeroes[2]}:${DisplayAAPercentPerHour.LeadingZeroes[2]}
}

function xpcalcleveltimer()
{
		StartTime:Set[${Math.Calc64[${Script.RunningTime}/1000]}]
		DisplaySeconds:Set[${Math.Calc64[${StartTime}%60]}]
		DisplayMinutes:Set[${Math.Calc64[${StartTime}/60%60]}]
		DisplayHours:Set[${Math.Calc64[${StartTime}/60\\60]}]
;//		echo ${DisplayHours.LeadingZeroes[2]}:${DisplayMinutes.LeadingZeroes[2]}:${DisplaySeconds.LeadingZeroes[2]}
}

function atexit()
{
	echo ${Time}: Stopping XP Calc Script
	if ${Script[ircrelay](exists)}	
		endscript ircrelay	
	if ${Script[lootedcoin](exists)}	
		endscript lootedcoin	
	endscript xpcalclevel
}	