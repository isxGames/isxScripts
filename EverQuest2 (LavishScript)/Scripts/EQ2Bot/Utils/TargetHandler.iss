#include EQ2Common/Debug.iss

function main()
{
	declare ltarget uint local
	declare ltankID unit local
	do
	{
		ltarget:Set[${Script[EQ2Bot].Variable[KillTarget]}]
		ltankID:Set[${Script[EQ2Bot].Variable[MainTankID]}]
		
		
		if !${ltarget} && ${Actor[${ltankID}].InCombatMode} && (${Actor[${ltankID}].Target(exists)} && ${Actor[${ltankID}].Target.ID} != ${ltankID})
		{
			Debug:Echo["TargetHandler:: TargetCheck - no killtarget and tank is targeting something 1"]
			Script[EQ2Bot].VariableScope.KillTarget:Set[${Actor[${ltankID}].Target.ID}]
		}
		elseif ${Actor[${ltarget}](exists)} && ${Actor[${ltarget}].Health}<=0
		{
			Debug:Echo["TargetHandler:: TargetCheck - no killtarget and tank is targeting something 2"]
			Script[EQ2Bot].VariableScope.KillTarget:Set[${Actor[${ltankID}].Target.ID}]
		}
		elseif !${Actor[${ltarget}](exists)}
		{
			if ${Actor[${ltankID}].Target(exists)} && ${Actor[${ltankID}].InCombatMode} && ${Actor[${ltankID}].Target.ID} != ${ltankID}
			{
				Debug:Echo["TargetHandler:: TargetCheck - KillTarget doesn't exist -- setting to MT's target"]
				Script[EQ2Bot].VariableScope.KillTarget:Set[${Actor[${ltankID}].Target.ID}]
			}
		}
		
		;echo waiting some
		wait 2
	}
	while ${Script[EQ2Bot](exists)}

	Debug:Echo["Eq2bot is no longer running, killtarget handler must be restarted after eq2bot is running"]
}
