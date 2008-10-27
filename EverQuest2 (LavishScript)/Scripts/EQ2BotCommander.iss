;****************************************
;Version 20060705a
;by Karye
;****************************************
variable string uplink1=ComputerName1Here
variable string uplink2=ComputerName2Here
variable string uplink3=ComputerName3Here

function main()
{
	
	if ${Session.NotEqual[${Me.Name}]}
	{
		squelch uplink name ${Me.Name}
	}
	
	Uplink RemoteUplink -disconnect ${uplink1}
	Uplink RemoteUplink -disconnect ${uplink2}
	Uplink RemoteUplink -disconnect ${uplink3}
	
	
	Uplink RemoteUplink -Connect ${uplink1}
	Uplink RemoteUplink -Connect ${uplink2}
	Uplink RemoteUplink -Connect ${uplink3}
	
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.xml"
	
	  do
	  {
	    if !${QueuedCommands}
	      WaitFrame
	    else
	      ExecuteQueued
	  }
	  while 1

}


function atexit()
{
	EQ2Echo Ending EQ2BotCommander!
	
	Uplink RemoteUplink -Disconnect ${uplink1}
	Uplink RemoteUplink -Disconnect ${uplink2}
	Uplink RemoteUplink -Disconnect ${uplink3}
	
	ui -unload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.xml"

}