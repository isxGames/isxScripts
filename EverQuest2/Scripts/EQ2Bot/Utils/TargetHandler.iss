#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss"

function main()
{
	;; Comment this to disable debug echos throughout
	Debug:Enable

	declare ltarget uint local
	declare ltankID unit local
	declare ltanktargetID uint local
	do
	{
		ltarget:Set[${Script[EQ2Bot].Variable[KillTarget]}]
		ltankID:Set[${Script[EQ2Bot].Variable[MainTankID]}]
		ltanktargetID:Set[${Actor[${ltankID}].Target.ID}]
		
		if !${ltarget}
		{
			if (${ltanktargetID} != ${ltankID} && ${Actor[${ltankID}].InCombatMode} && (${Actor[${ltankID}].Target(exists)})
			{
				Debug:Echo["TargetHandler:: TargetCheck - no killtarget and tank is targeting something (1) [ltarget: ${ltarget}, ltankID: ${ltankID}, tank's target ID: ${ltanktargetID})"]
				Script[EQ2Bot].VariableScope.KillTarget:Set[${ltanktargetID}]
				;Debug:Echo["TargetHandler:: KillTarget is ${Script[EQ2Bot].Variable[KillTarget]} (Should be: ${ltanktargetID})"]
			}
		}
		else
		{
		  if ${Actor[${ltarget}](exists)}
		  {
				if (${Actor[${ltarget}].Health}<=0)
				{
					if (${ltanktargetID} != ${ltankID} && ${Actor[${ltankID}].InCombatMode} && ${Actor[${ltankID}].Target(exists)})
					{
						Debug:Echo["TargetHandler:: TargetCheck - no killtarget and tank is targeting something (2)"]
						Script[EQ2Bot].VariableScope.KillTarget:Set[${Actor[${ltanktargetID}]
						;Debug:Echo["TargetHandler:: KillTarget is ${Script[EQ2Bot].Variable[KillTarget]} (Should be: ${ltanktargetID})"]
					}
				}
		  }
		  else
		  {
				if (${ltanktargetID} != ${ltankID} && ${Actor[${ltankID}].InCombatMode} && ${Actor[${ltankID}].Target(exists)})
				{
					Debug:Echo["TargetHandler:: TargetCheck - KillTarget doesn't exist -- setting to MT's target"]
					Script[EQ2Bot].VariableScope.KillTarget:Set[${ltanktargetID}]
					;Debug:Echo["TargetHandler:: KillTarget is ${Script[EQ2Bot].Variable[KillTarget]} (Should be: ${Actor[${ltanktargetID})"]
				}
		  }
		}
		
		;echo waiting some
		wait 4
	}
	while ${Script[EQ2Bot](exists)}

	Debug:Echo["Eq2bot is no longer running, killtarget handler must be restarted after eq2bot is running"]
}