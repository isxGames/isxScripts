function main()
{
	while 1
	{
		StartTime:Set[${Math.Calc64[${Script.RunningTime}/1000]}]
		DisplaySeconds:Set[${Math.Calc64[${StartTime}%60]}]
		DisplayMinutes:Set[${Math.Calc64[${StartTime}/60%60]}]
		DisplayHours:Set[${Math.Calc64[${StartTime}/60\\60]}]
;;		echo ${DisplayHours.LeadingZeroes[2]}:${DisplayMinutes.LeadingZeroes[2]}:${DisplaySeconds.LeadingZeroes[2]}
	}
	waitframe
}