function main(string LoginModifer, string CharToLogin, string Arg3)
{
	
	if ${LoginModifer.Equal[?]} || ${LoginModifer.Equal[help]}
	{
		echo ****Commands and Arguments***
		echo All commands are run "run Ogre <command> <Args>"
		echo Run Ogre -- Loads the bot
		echo Run Ogre toonname -- Loads the toon and loads Ogrebot
		echo Run Ogre login toonname -- Runs a seperate login script that loads the toon but does NOT load the bot
		echo Run Ogre up | uplink -- Loads the uplink
		echo Run Ogre Spell | SpellExport -- Runs the spellexport
		echo Run Ogre Move <string location> | Movement <string location> -- Runs movement script with the arg of location using lavishnav
		echo Run Ogre Broker | B -- Runs the broker pricing bot
		echo Run Ogre Tell -- Loads the Uplink tell window. Note: This is built into Ogrebot already. This Command is a standalone version.
		echo Run Ogre Map | Mapper -- Runs the LavishNav mapper. Remember to SAVE before you zone!
		echo Run Ogre Hire <tier> | Hireling <tier> -- Runs the hireling script for Guild Hunter/Gatherer/Miner - Default tier is 8
		echo Run Ogre HireG <tier> | HirelingGroup <tier> -- Runs the script for using multiple hirelings - Default tier is 8
		echo Run Ogre Depot -- Runs the Depot script
		echo Run Ogre End <Loadcommand> -- Any script that doesn't have an interface can be ended the same way it is run.
		echo                         -- Example: "Run Ogre hire" runs the hireling, "run Ogre end hire" ends the hireling script
		return
	}
	elseif ${LoginModifer.Equal[up]} || ${LoginModifer.Equal[uplink]}
	{
		runscript eq2Ogrebot/up
		return
	}
	elseif ${LoginModifer.Equal[Spell]} || ${LoginModifer.Equal[SpellExport]}
	{
		runscript eq2ogrebot/spellexport
		return
	}
	elseif ${LoginModifer.Equal[tell]} || ${LoginModifer.Equal[tellwindow]}
	{
		if ${Script[eq2ogretellwindow](exists)}
		{
			Script[eq2ogretellwindow]:End
			wait 50 !${Script[eq2ogretellwindow](exists)}
		}
		runscript eq2ogretellwindow "${CharToLogin}"
		return
	}
	elseif ${LoginModifer.Equal[Move]} || ${LoginModifer.Equal[Movement]}
	{
		runscript eq2ogrecommon/OgreMove "${CharToLogin}"
		return
	}
	elseif ${LoginModifer.Equal[r]} || ${LoginModifer.Equal[radar]}
	{
		runscript eq2ogrebot/r "${CharToLogin}"
		return
	}
	elseif ${LoginModifer.Equal[b]} || ${LoginModifer.Equal[Broker]}
	{
		runscript eq2ogrebot/Extras/BrokerPricer
		return
	}
	elseif ${LoginModifer.Equal[map]} || ${LoginModifer.Equal[mapper]}
	{
		runscript eq2ogrecommon/eq2ogrenavcreator
		return
	}
	elseif ${LoginModifer.Equal[hire]} || ${LoginModifer.Equal[hireling]}
	{
		runscript eq2ogrecommon/ogrehireling/eq2ogrehireling "${CharToLogin}" "${Arg3}"
		return
	}
	elseif ${LoginModifer.Equal[hireg]} || ${LoginModifer.Equal[hirelinggroup]}
	{
		runscript eq2ogrecommon/ogrehireling/eq2ogrehirelingGroup "${CharToLogin}" "${Arg3}"
		return
	}
	elseif ${LoginModifer.Equal[depot]}
	{
		runscript eq2ogrecommon/EQ2OgreDepot "${CharToLogin}"
		return
	}
	elseif ${LoginModifer.Equal[end]}
	{
		if ${Script[eq2ogrehireling](exists)} && ( ${CharToLogin.Equal[hire]} || ${CharToLogin.Equal[hireling]} )
			endscript eq2ogrehireling
		elseif ${Script[eq2ogrehirelingGroup](exists)} && ( ${CharToLogin.Equal[hireg]} || ${CharToLogin.Equal[hirelinggroup]} )
		{
			endscript eq2ogrehirelingGroup
			if ${Script[eq2ogrehireling](exists)}
				endscript eq2ogrehireling
		}
		elseif ${Script[BrokerPricer](exists)} && ( ${CharToLogin.Equal[b]} || ${CharToLogin.Equal[brokerbot]} )
			endscript BrokerPricer
		elseif ${Script[eq2ogretellwindow](exists)} && ( ${CharToLogin.Equal[tell]} || ${CharToLogin.Equal[tellwindow]} )
			endscript eq2ogretellwindow
		elseif ${Script[OgreMove](exists)} && ( ${CharToLogin.Equal[move]} || ${CharToLogin.Equal[movement]} )
			endscript OgreMove
		return
	}
	elseif ${LoginModifer.Equal[login]}
	{
		if ${Script[loginonly](exists)}
		{
			Script[loginonly]:End
			wait 50 !${Script[loginonly](exists)}
		}
		runscript eq2ogrecommon/loginonly "${LoginModifer}" "${CharToLogin}"
		return
	}
	if ${Script[ui](exists)}
	{
		Script[ui]:End
		wait 50 !${Script[ui](exists)}
	}
	runscript eq2Ogrebot/ui "${LoginModifer}" "${CharToLogin}"
}