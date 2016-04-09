;Examine.iss
;
;This script will open an examine window on detrimental effects as they happen.
;
variable(script) collection:string RecentDebuffs

function main()
{
	variable int count
	variable int examineTimer
	do
	{
		Me:InitializeEffects

		if ${Me.CountEffects[detrimental]}
		{
			count:Set[0]
			do
			{
				if !${RecentDebuffs.Element[${Me.Effect[detrimental,${count}].Name}](exists)}
				{
					Me.Effect[detrimental,${count}]:Examine
					RecentDebuffs:Set[${Me.Effect[detrimental,${count}].Name},${Me.Effect[detrimental,${count}].Description}]
					examineTimer:Set[${Time.Timestamp}]
					wait 1
				}
			}
			while ${count:Inc}<=${Me.CountEffects[detrimental]}
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