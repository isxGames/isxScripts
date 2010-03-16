#include EQ2Common/Debug.iss

function main()
{
	declare ltarget uint local
	declare ltankpc unit local
	do
	{
		ltarget:Set[${Script[EQ2Bot].Variable[KillTarget]}]
		ltankpc:Set[${Script[EQ2Bot].Variable[MainTankID]}]
		
		
		if !${ltarget} && ${Actor[pc,${ltankpc}].InCombatMode} && (${Actor[${ltankpc}].Target(exists)} && ${Actor[${ltankpc}].Target.ID}!=${ltankpc})
		{
			Debug:Echo[targetcheck - no killtarget and tank is targeting something 1]
			${Script[EQ2Bot].Variable[KillTarget]:Set[${Actor[${ltankpc}].Target.ID}]
		}
		elseif ${Actor[${ltarget}](exists)} && ${Actor[${ltarget}].Health}<=0
		{
			Debug:Echo[targetcheck - no killtarget and tank is targeting something 2]
			${Script[EQ2Bot].Variable[KillTarget]:Set[${Actor[${ltankpc}].Target.ID}]
		}
		elseif !${Actor[pc,${ltarget}](exists)}
		{
			if ${Actor[pc,${ltankpc}].Target(exists)} && ${Actor[${ltankpc}].Target.ID}!=${ltankpc}
			{
				Debug:Echo[targetcheck - target doesn't exist and setting it to mt's target]
				${Script[EQ2Bot].Variable[KillTarget]:Set[${Actor[${ltankpc}].Target.ID}]
			}
		}
		
		;echo waiting some
		wait 5
	}
	while ${Script[EQ2Bot](exists)}

	echo Eq2bot is no longer running, killtarget handler must be restarted after eq2bot is running	
}
