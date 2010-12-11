;-----------------------------------------------------------------------------------------------
; EQ2Bot.iss Stub for Moving to subdir -- CyberTech
;

function main(string Args)
{
	echo "Please note: EQ2Bot has moved from scripts/eq2bot.iss to scripts/eq2bot/eq2bot.iss"
	echo "Newer versions of ISXEQ2 will automatically convert 'run eq2bot' to 'run eq2bot/eq2bot'"
	echo "--"
	echo "Renaming Scripts\EQ2Bot.iss to Scripts\EQ2Bot.iss.moved"

	; This will generate an error, but execute the rename.
	rename "${LavishScript.HomeDirectory}/Scripts/EQ2Bot.iss" "${LavishScript.HomeDirectory}/Scripts/EQ2Bot.iss.moved"
	TimedCommand 20 "run eq2bot/eq2bot ${Args}"
	echo "Please wait..."
}
