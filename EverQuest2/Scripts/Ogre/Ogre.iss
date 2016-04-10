function main(string LoginModifer, string CharToLogin, string Arg3)
{
	if !${ISXEQ2(exists)}
	{
		ext isxeq2
	}

	wait 100 ${Display.FPS}>1

	if !${ISXEQ2.IsReady}
	{
		wait 200 ${ISXEQ2.IsReady}
		wait 40
		if !${ISXEQ2.IsReady}
		{
			echo ISXEQ2 is reporting NOT being ready. All functions of this script require ISXEQ2. Please load ISXEQ2 and run the script again.
			Script:End
		}
	}

	;Skin here so we don't have to make sure everything is skinned in scripts..
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"

	if ${LoginModifer.Equal[?]} || ${LoginModifer.Equal[help]}
	{
		echo ****Commands and Arguments***
		echo All commands are run "run Ogre <command> <Args>"
		echo Run Ogre -- Loads the Adventure bot
		echo ***Loads Ogre portal unless you have access you have Ogrebot (not public), then it loads the bot
		echo Run Ogre OP -- Loads Ogre Portal UI
		echo Run Ogre toonname -- Loads the toon and loads Ogrebot
		echo Run Ogre login toonname -- Runs a seperate login script that loads the toon but does NOT load the bot
		echo Run Ogre up | uplink || OgreMCP || MCP -- Loads OgreMCP (Previously known as Uplink)
		echo Run Ogre Move <string location> | Movement <string location> -- Runs movement script with the arg of location using lavishnav
		echo Run Ogre Tell -- Loads the Uplink tell window. Note: This is built into Ogrebot already. This Command is a standalone version.
		echo Run Ogre Map | Mapper -- Runs the LavishNav mapper. Remember to SAVE before you zone!
		echo Run Ogre Hire <tier> | Hireling <tier> -- Runs the hireling script for Guild Hunter/Gatherer/Miner - Default tier is 8
		echo Run Ogre HireG <tier> | HirelingGroup <tier> -- Runs the script for using multiple hirelings - Default tier is 8
		echo Run Ogre Depot -- Runs the Depot script
		echo Run Ogre Harvest -- Runs EQ2OgreHarvest
		echo Run Ogre Transmute -- Loads the Transmute UI
		echo Run Ogre Reset | Zone -- Loads the Zone reset UI
		echo Run Ogre OSA | OnScreen -- Loads the On-screen-Assistant (OSA)
		echo Run Ogre End <Loadcommand> -- Any script that doesn't have an interface can be ended the same way it is run. "All" will end all Ogre scripts that use the End command.
		echo                         -- Example: "Run Ogre hire" runs the hireling, "run Ogre end hire" ends the hireling script
		return
	}
	elseif ${LoginModifer.Equal[OP]}
	{
		ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/eq2ogrecommon/OgrePortal/OgrePortalXML.xml"
		return
	}
	elseif ${LoginModifer.Equal[OSA]} || ${LoginModifer.Equal[OnScreen]}
	{
		if ${Script[Eq2OgreOnScreenAssistant](exists)}
		{
			endscript eq2ogreonscreenassistant
			wait 5
		}
		runscript eq2Ogrecommon/ogreOnScreenAssistant/eq2ogreOnScreenAssistant
		return
	}
	elseif ${LoginModifer.Equal[harvest]}
	{
		runscript eq2Ogrecommon/eq2Ogreharvest/eq2ogreharvest
		return
	}
	elseif ${LoginModifer.Equal[transmute]}
	{
		runscript eq2Ogrecommon/ogretransmute/eq2ogretransmuteshell
		return
	}
	elseif ${LoginModifer.Equal[Reset]} || ${LoginModifer.Equal[Zone]}
	{
		ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/eq2ogrecommon/OgreZoneReset/EQ2OgreZoneResetXML.xml"
		;runscript eq2Ogrecommon/ogretransmute/eq2ogretransmuteshell
		return
	}
	elseif ${LoginModifer.Equal[tell]} || ${LoginModifer.Equal[tellwindow]}
	{
		if ${Script[eq2ogretellwindow](exists)}
		{
			Script[eq2ogretellwindow]:End
			wait 50 !${Script[eq2ogretellwindow](exists)}
		}
		run eq2Ogrecommon/eq2ogretellwindow "${CharToLogin}"
		return
	}
	elseif ${LoginModifer.Equal[Move]} || ${LoginModifer.Equal[Movement]}
	{
		runscript eq2ogrecommon/OgreMove "${CharToLogin}"
		return
	}
	elseif ${LoginModifer.Equal[map]} || ${LoginModifer.Equal[mapper]}
	{
		runscript eq2ogrecommon/eq2ogrenavcreator
		return
	}
	elseif ${LoginModifer.Equal[hire]} || ${LoginModifer.Equal[hireling]}
	{
		runscript eq2ogrecommon/ogrehireling/eq2ogrehireling ${CharToLogin} ${Arg3}
		return
	}
	elseif ${LoginModifer.Equal[hireg]} || ${LoginModifer.Equal[hirelinggroup]}
	{
		runscript eq2ogrecommon/ogrehireling/eq2ogrehirelingGroup ${CharToLogin} ${Arg3}
		return
	}
	elseif ${LoginModifer.Equal[depot]}
	{
		runscript eq2ogrecommon/EQ2OgreDepot ${CharToLogin}
		return
	}
	elseif ${LoginModifer.Equal[end]}
	{
		if ${Script[eq2ogrehireling](exists)} && ( ${CharToLogin.Equal[hire]} || ${CharToLogin.Equal[hireling]} || ${CharToLogin.Equal[all]} )
			endscript eq2ogrehireling
		if ${Script[eq2ogrehirelingGroup](exists)} && ( ${CharToLogin.Equal[hireg]} || ${CharToLogin.Equal[hirelinggroup]} || ${CharToLogin.Equal[all]} )
		{
			endscript eq2ogrehirelingGroup
			if ${Script[eq2ogrehireling](exists)}
				endscript eq2ogrehireling
		}
		if ${Script[Eq2OgreOnScreenAssistant](exists)} && ( ${CharToLogin.Equal[OSA]} || ${CharToLogin.Equal[OnScreen]}  || ${CharToLogin.Equal[all]} )
			endscript eq2ogreonscreenassistant
		if ${Script[BrokerPricer](exists)} && ( ${CharToLogin.Equal[b]} || ${CharToLogin.Equal[brokerbot]}  || ${CharToLogin.Equal[all]} )
			endscript BrokerPricer
		if ${Script[eq2ogretellwindow](exists)} && ( ${CharToLogin.Equal[tell]} || ${CharToLogin.Equal[tellwindow]}  || ${CharToLogin.Equal[all]} )
			endscript eq2ogretellwindow
		if ${Script[OgreMove](exists)} && ( ${CharToLogin.Equal[move]} || ${CharToLogin.Equal[movement]}  || ${CharToLogin.Equal[all]} )
			endscript OgreMove
		if ${CharToLogin.Equal[zone]} || ${CharToLogin.Equal[reset]}  || ${CharToLogin.Equal[all]}
		{
			if ${UIElement[eq2OgreZoneResetXML](exists)}
				ui -unload scripts\\EQ2OgreCommon\\OgreZoneReset\\EQ2OgreZoneResetXML.XML
			if ${Script[EQ2OgreZoneReset](exists)}
				endscript EQ2OgreZoneReset
			if ${Script[EQ2OgreZoneResetController](exists)}
				endscript EQ2OgreZoneResetController
			if ${Script[EQ2OgreZoneResetXMLCall](exists)}
				endscript EQ2OgreZoneResetXMLCall
		}
		if ${CharToLogin.Equal[transmute]} || ${CharToLogin.Equal[all]}
		{
			if ${UIElement[eq2OgreTransmuteXML](exists)}
				ui -unload scripts\\EQ2OgreCommon\\OgreTransmute\\eq2OgreTransmuteXML.xml
			if ${Script[EQ2OgreTransmute]}
				endscript EQ2OgreTransmute
		}
		if ${CharToLogin.Equal[harvest]} || ${CharToLogin.Equal[all]}
		{
			if ${UIElement[eq2OgreHarvestShell](exists)}
				ui -unload scripts\\EQ2OgreHarvest\\EQ2OgreHarvestShellXML.xml
			if ${Script[EQ2OgreHarvestMain]}
				endscript EQ2OgreHarvestMain
		}
		if ${Script[eq2ogrenavcreator](exists)} && ( ${CharToLogin.Equal[map]} || ${CharToLogin.Equal[mapper]} || ${CharToLogin.Equal[all]} )
			endscript eq2ogrenavcreator

		if ${Script[eq2OgreDepot](exists)} && (${CharToLogin.Equal[depot]} || ${CharToLogin.Equal[all]})
			endscript EQ2OgreDepot
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
	
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/eq2ogrecommon/OgrePortal/OgrePortalXML.xml"
	return
}