function main(string LoginModifer, string c_status)
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
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/EQ2-Green/EQ2-Green.xml"

	if ${LoginModifer.Equal[?]} || ${LoginModifer.Equal[help]}
	{
		echo ****Commands and Arguments***
		echo All commands are run "run Bj <command> <Args>"
		echo Run BJ BJMagic -- Loads the Words of Pure Magic Shrine Clicker
		echo Run BJ BJXPBot	--	Loads the Auto XP Potion Script
		echo Run BJ BJHammarmund -- Loads the scripted movement for the trio fight in Temple of Rallos Zek
		echo Run BJ BJCure -- Loads the script that forces OgreBot to interrupt whatever it is casting in order to cast a cure
		echo Run BJ BJAuction -- Loads the script that assists in auction of loot
		echo Run BJ BJShuffle -- Loads the script that shuffles your toons around so they are not all standing in one spot
		echo Run BJ BJLooter -- Loads the script that will move to corpses or chests to loot them
		echo Run BJ BJInventory -- Loads the script that manages the selling and trading of looted goods
		echo                         -- Example: "Run Bj bjmagic" runs the clicker script, "run Bj end bjmagic" ends the clicker script
		return
	}
	elseif ${LoginModifer.Equal[bjmagic]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjmagic/bjmagicSHELL.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjxpbot]} || ${LoginModifer.Equal[xpbot]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjxpbot/bjxpbotSHELL.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjhammarmund]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/private/hammarmund/hammarmund.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjcure]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/private/bjcure/bjcureSHELL.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjidolhm]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/private/bjidolhm/bjidolhmSHELL.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjdecorin]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/private/bjdecorin/bjdecorin.iss"
		return
	}	
	elseif ${LoginModifer.Equal[bjauction]} || ${LoginModifer.Equal[auction]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjauction/bjauctionSHELL.iss"
		return
	}		
	elseif ${LoginModifer.Equal[bjshuffle]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjshuffle/bjshuffleSHELL.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjpetdance]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/private/bjpetdance/bjpetdance.iss"
		return
	}	
	elseif ${LoginModifer.Equal[bjlooter]} || ${LoginModifer.Equal[looter]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjlooter/bjlooterSHELL.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjinventory]} || ${LoginModifer.Equal[inventory]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjinventory/bjinventory.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjguildhall]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/private/bjguildhall/bjguildhall.iss"
		return
	}
	elseif ${LoginModifer.Equal[reet]}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/reet.iss"
		return
	}
	elseif ${LoginModifer.Equal[bjfood]}
	{
		runscript eq2bjcommon/private/bjfood/bjfood ${c_status}
		return
	}
	
	
	elseif ${LoginModifer.Equal[end]}
	{
		if ${Script[bjmagic](exists)}
			endscript bjmagic
	}
}	