;TargetEffects.iss
;
;This script will open an examine window on target effects as they happen.
;
variable(script) collection:string RecentDebuffs

function main()
{
	variable int count
	variable int examineTimer
	do
	{

		if ${Target.NumEffects}>0
		{
			count:Set[0]
			do
			{
				if !${RecentDebuffs.Element[${Target.Effect[${count}].Name}](exists)}
				{
					echo ${Target.Effect[${count}].Name} - ${Target.Effect[${count}].Description}
					Actor[${Target.ID}].Effect[${count}]:Examine
					RecentDebuffs:Set[${Target.Effect[${count}].Name},${Target.Effect[${count}].Description}]
					examineTimer:Set[${Time.Timestamp}]
					wait 1
				}
			}
			while ${count:Inc}<=${Target.NumEffects}
		}
		wait 5
		if (${examineTimer}<${Math.Calc64[${Time.Timestamp}-300]})
		{
			examineTimer:Set[${Time.Timestamp}]
			if ${RecentDebuffs.Used} > 0
			{
				RecentDebuffs:Clear
			}
		}
	}
	while 1
}