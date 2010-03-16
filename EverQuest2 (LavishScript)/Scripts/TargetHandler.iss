function main()
{
	declare ltarget uint local
	declare ltank uint local
	do
	{
		ltarget:Set[${Script[EQ2Bot].Variable[KillTarget]}]
		ltankpc:Set[${Script[EQ2Bot].Variable[MainTankPC]}]
		
		if !${ltarget} && ${Actor[pc,${ltankpc}].InCombatMode} && (${Actor[pc,${ltankpc}].Target(exists)} && ${Actor[pc,${ltankpc}].Target}!=${Actor[pc,${ltankpc}].ID})
		{
			echo targetcheck - no killtarget and tank is targeting something
			${Script[EQ2Bot].Variable[KillTarget]:Set[${Actor[pc,${ltankpc}].Target.ID}]
		}
		elseif ${Actor[pc,${ltarget}].Health}<=0
		{
			${Script[EQ2Bot].Variable[KillTarget]:Set[${Actor[pc,${ltankpc}].Target.ID}]
		}
		wait 5
	}
	while ${Script[EQ2Bot](exists)}

	echo Eq2bot is no longer running, killtarget handler must be restarted after eq2bot is running	
}
