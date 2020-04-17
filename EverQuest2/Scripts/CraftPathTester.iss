;#include moveto.iss
#include "${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss"

variable string World
variable float WPX
variable float WPZ
variable int pathindex
variable string NearestPoint
variable int retrycnt
variable filepath NavigationPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Navigational Paths/"
variable settingsetref Wholesalers
variable settingsetref Configuration
variable EQ2Nav Nav
variable string AutoRunKey
variable string BackwardKey
variable string StrafeRightKey
variable string StrafeLeftKey

variable string CurrentStatus
variable string SecondaryStatus

function main()
{
	Nav:UseLSO[FALSE]
	Nav:LoadMap
	Nav.SmartDestinationDetection:Set[FALSE]
	Nav.BackupTime:Set[3]
	Nav.StrafeTime:Set[3]

	LavishSettings:AddSet[Common File]
	LavishSettings[Common File]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Recipe Data/Common.xml"]
	LavishSettings:AddSet[Craft Config File]
	LavishSettings[Craft Config File]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Character Config/${Me.Name}.xml"]
	Configuration:Set[${LavishSettings[Craft Config File].FindSet[General Options]}]
	Wholesalers:Set[${LavishSettings[Common File].FindSet[Wholesalers]}]

	Nav.AUTORUN:Set[${Configuration.FindSetting[AutoRun Key,"num lock"]}]
	Nav.MOVEBACKWARD:Set[${Configuration.FindSetting[Backwards Key,"s"]}]
	Nav.STRAFELEFT:Set[${Configuration.FindSetting[StrafeRight Key,"e"]}]
	Nav.STRAFERIGHT:Set[${Configuration.FindSetting[StrafeLeft Key,"q"]}]

	ui -reload interface/skins/eq2/eq2.xml
    ui -reload -skin eq2 scripts/EQ2Craft/UI/CraftPath.xml
    
    do
    {
        if ${QueuedCommands}
            ExecuteQueued
    }
    while 1
}

function QueuedMoveTo(... Params)
{
    variable string devicename
    variable int devicenum
    variable int paramcount
	variable float DestPrec
    paramcount:Set[${Params.Size}]
    while ${paramcount}>0
    {
        devicename:Set[${Params[${paramcount}]} ${devicename}]
        paramcount:Dec
    }
    CurrentStatus:Set["Moving to ${devicename}"]
    DestPrec:Set[${Nav.DestinationPrecision}]
    Nav.DestinationPrecision:Set[1]

    Nav:MoveToRegion["${devicename}"]


    ;;;;;;;;;;;;;;;;;;
    ;;
    do
    {
	    Nav:Pulse
	    wait 0.5
    }
    while ${ISXEQ2(exists)} && ${Nav.Moving}
    ;;
    ;;;;;;;;;;;;;;;;;;
	
    ;;; Just in case....
    waitframe
    call StopRunning
    waitframe
    Nav.DestinationPrecision:Set[1]
    FlushQueued
    CurrentStatus:Set["Arrived at ${devicename}"]
}

function CheckAll()
{
    redirect craftpathtest.txt echo CRAFT PATH TEST FOR ${Zone.ShortName}
	call CheckDevice "Broker"
	call CheckDevice "RushOrder"
	call CheckDevice "Chemistry Table" 1
	call CheckDevice "Engraved Desk" 1
	call CheckDevice "Forge" 1
	call CheckDevice "Sewing Table & Mannequin" 1
	call CheckDevice "Stove & Keg" 1
	call CheckDevice "Woodworking Table" 1
	call CheckDevice "Work Bench" 1
	call CheckDevice "Engraved Desk" 2
	call CheckDevice "Sewing Table & Mannequin" 2
	call CheckDevice "Forge" 2
	call CheckDevice "Chemistry Table" 2
	call CheckDevice "Stove & Keg" 2
	call CheckDevice "Work Bench" 2
	call CheckDevice "Woodworking Table" 2
	call CheckDevice "WorkOrder"
	call CheckDevice "Forge" 3
	call CheckDevice "Engraved Desk" 3
	call CheckDevice "Sewing Table & Mannequin" 3
	call CheckDevice "Work Bench" 3
	call CheckDevice "Stove & Keg" 3
	call CheckDevice "Woodworking Table" 3
	call CheckDevice "Chemistry Table" 3
	call CheckDevice "Wholesaler"
	CurrentStatus:Set["Full path check complete."]
    FlushQueued
}

function CheckDevice(string devicename, int devicenum)
{
	call MovetoDevice "${devicename}" ${devicenum}
	if !${devicenum}
	{
		;target nokillnpc
		;wait 5
		redirect -append craftpathtest.txt echo ${devicename} (${Target.Name} <${Target.Guild}>): ${Math.Distance[${Target.X},${Target.Z},${Me.X},${Me.Z}]}
        CurrentStatus:Set["${devicename} (${Target.Name} <${Target.Guild}>): ${Math.Distance[${Target.X},${Target.Z},${Me.X},${Me.Z}]}"]
	}	
	else 
	{
		redirect -append craftpathtest.txt echo ${devicename} (${devicenum}): ${Math.Distance[${Target.X},${Target.Z},${Me.X},${Me.Z}]}
        CurrentStatus:Set["${devicename} (${devicenum}): ${Math.Distance[${Target.X},${Target.Z},${Me.X},${Me.Z}]}"]
	}
	wait 50
}


function MovetoDevice(string devicename, int devicenum)
{
	variable int tmprnd
	variable int tcount
	variable int doorheading
	variable string ToTargetName
	variable iterator Iterator
	
	echo "EQ2Craft-Debug:: MoveToDevice(${devicename},${devicenum})"
    CurrentStatus:Set["Moving to device: ${devicename} ${devicenum}"]

	switch ${devicename}
	{
		case Stove and Keg
			devicename:Set["Stove & Keg"]
			break

		case Loom
			devicename:Set["Sewing Table & Mannequin"]
			break
			
		case Sawhorse
			devicename:Set["Woodworking Table"]
			break
			
		case Wholesaler
		case Rushorder
		case Workorder
		case Broker
			break
						
		default
			break
	}
	
	if ${lastdevice.Equal[${devicename}]}
		return

	if ${devicename.Equal[Rushorder]}
	{
		if ${Actor[xzrange,10,yrange,2,guild,"Rush Orders"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,"Rush Orders"].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,"Rush Orders"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,Rush Orders].ID}"
			if ${Target.Guild.Equal["Rush Orders"]}
			   face
			wait 10
			lastdevice:Set[Rushorder]   		
			return
		}       
	} 
	elseif ${devicename.Equal[Workorder]}
	{
		if ${Actor[xzrange,10,yrange,2,guild,"Work Orders"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,"Work Orders"].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,"Work Orders"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,Work Orders].ID}"
			if ${Target.Guild.Equal["Work Orders"]}
			   face
			wait 10
			lastdevice:Set[Workorder]
			return
		}       
	}  
	elseif ${devicename.Equal[Broker]}
	{
		if ${Actor[xzrange,10,yrange,2,guild,"Broker"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,"Broker"].Type.Equal[NoKill NPC]}
		{
			Actor[xzrange,10,yrange,2,guild,"Broker"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,Broker].ID}"
			if ${Target.Guild.Equal["Broker"]}
			   face
			wait 10
			lastdevice:Set[Broker]
			if (${Target.Distance} > 7)
			{
				press "${Nav.AUTORUN}"
				do
				{
					waitframe
				}
				while ${Target.Distance} > 7
				wait 1
				press "${Nav.AUTORUN}"
				wait 2
			}       		
			return
		}       
	}  
	elseif ${devicename.Equal[Wholesaler]}
	{
		if ${Actor[xzrange,10,yrange,2,"Wholesaler"].Name(exists)} && !${Me.CheckCollision[${Actor[xzrange,10,yrange,2,"Wholesaler"].Loc}]}
		{
			Actor[xzrange,10,yrange,2,"Wholesaler"]:DoTarget
			wait 10 ${Target.ID}==${Actor[xzrange,10,yrange,2,"Wholesaler"].ID}
			face
			wait 10
			lastdevice:Set[Wholesaler]
			return
		}
		
		Wholesalers:GetSettingIterator[Iterator]
		if ${Iterator:First(exists)}
		{
			do
			{
				if ${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Iterator.Key}].Type.Equal[NoKill NPC]} &&  && !${Me.CheckCollision[${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Loc}]}
				{
					Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"]:DoTarget
					wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].ID}"
					face
					wait 10
					lastdevice:Set[Wholesaler]
					return
				}
			}
			while ${Iterator:Next(exists)}
		}
	}
	elseif ${Actor[${devicename},xzrange,6,yrange,2].Name(exists)}
	{
		if (!${Actor[${devicename},xzrange,6,yrange,2].CheckCollision})
		{
			Actor[ExactName,${devicename}]:DoTarget
			wait 10 "${Target.ID}==${Actor[${devicename}].ID}"
			if ${Target.Name.Equal[${devicename}]}
			{
			   face
			}
			wait 10
			lastdevice:Set[${devicename}]
			return
		}
	}

	if ${EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.Create.Recipes](exists)}
	{
		EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.Create.Recipes]:LeftClick
		wait 20
		EQ2Execute /hide_window TradeSkills.TradeSkills
	}
	else
	{
		call Cancel
	}
	
	;if (${Zone.ShortName.Equal[fprt_tradeskill01]})
	;{
		Nav.gPrecision:Set[1]
		Nav.DestinationPrecision:Set[3]
	;}
	
	if ${Zone.ShortName.Equal[neriak]}
		Nav.DestinationPrecision:Set[2]

	if ${devicenum}
	{
		echo "EQ2Craft:: Moving To Device: '${devicename} ${devicenum}'"
		Nav:MoveToRegion["${devicename} ${devicenum}"]
	}
	else
		Nav:MoveToRegion["${devicename}"]


	;;;;;;;;;;;;;;;;;;
	;;
	do
	{
		Nav:Pulse
		wait 0.5
	}
	while ${ISXEQ2(exists)} && ${Nav.Moving}
	;;
	;;;;;;;;;;;;;;;;;;
	
	;;; Just in case....
	waitframe
	call StopRunning
	waitframe


	switch ${devicename}
	{
		case Rushorder
			;if ${Zone.ShortName.Equal[qey_tradeskill01]}
			;{
			;    press -hold "${Nav.STRAFERIGHT}"
			;	wait ${Math.Rand[5]:Inc}
			;    press -release "${Nav.STRAFERIGHT}" 
			;}           
			Actor[xzrange,15,yrange,2,guild,"Rush Orders"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"Rush Orders"].ID}"
			face
			wait 2
			break
		case Workorder
			Actor[xzrange,15,yrange,2,guild,"Work Orders"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"Work Orders"].ID}"
			face    
			wait 2        
			break
		case Broker
			Actor[xzrange,15,yrange,2,guild,"Broker"]:DoTarget
			wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"Broker"].ID}"
			face  
			wait 2          
			break
		case Wholesaler
			; coming down those stairs blows...
			wait 4
			if ${Actor[xzrange,10,yrange,2,"Wholesaler"].Name(exists)}
			{
				Actor[xzrange,10,yrange,2,"Wholesaler"]:DoTarget
				wait 10 ${Target.ID}==${Actor[xzrange,10,yrange,2,"Wholesaler"].ID}
				face
			}
			else
			{
				Wholesalers:GetSettingIterator[Iterator]
				if ${Iterator:First(exists)}
				{
					do
					{
						echo EQ2Craft-DEBUG:: Wholesaler Iterator key = ${Iterator.Key}
						if ${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].Name(exists)} && ${Actor[xzrange,10,yrange,2,guild,${Iterator.Key}].Type.Equal[NoKill NPC]}
						{
							Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"]:DoTarget
							wait 10 "${Target.ID}==${Actor[xzrange,10,yrange,2,guild,"${Iterator.Key}"].ID}"
							break
						}
					}
					while ${Iterator:Next(exists)}
				}
			}
			face
			wait 2
			if (${lastdevice.Equal[Broker]} || ${lastdevice.Equal[Rushorder]} || ${lastdevice.Equal[Workorder]})
			{
				if ${Zone.ShortName.Equal[qey_tradeskill01]}
				{
					if ${Me.Speed} < 50
					{
						press -hold "${Nav.STRAFELEFT}"
						wait ${Math.Calc[4-${Me.Speed}/100*4]}
						press -release "${Nav.STRAFELEFT}" 
						wait 1
						press -hold "${Nav.MOVEFOWARD}
						wait ${Math.Calc[5-${Me.Speed}/100*5]}
						press -release "${Nav.MOVEFORWARD}"
						wait 1
					}
				}
			}
			wait 1
			face
			wait 1 
			break
		default
			Actor[${devicename}]:DoTarget
			wait 10 "${Target.ID}==${Actor[${devicename}].ID}"
			face
			wait 2
/*			if ${Me.Speed} < 15
			{
				tmprnd:Set[${Math.Rand[90]}]
				variable int HoldCnt
				if ${tmprnd}<30
				{
					press -hold "${Nav.STRAFELEFT}"
					HoldCnt:Set[${Math.Rand[5]:Inc}]
					wait ${Math.Calc[${HoldCnt}-${Me.Speed}/100*${HoldCnt}]}
					press -release "${Nav.STRAFELEFT}"
				}
				elseif ${tmprnd}<60
				{
					press -hold "${Nav.STRAFERIGHT}"
					HoldCnt:Set[${Math.Rand[5]:Inc}]
					wait ${Math.Calc[${HoldCnt}-${Me.Speed}/100*${HoldCnt}]}
					press -release "${Nav.STRAFERIGHT}"
				}
				else
				{
					press "${Nav.AUTORUN}"
					HoldCnt:Set[${Math.Rand[3]:Inc}]
					wait ${Math.Calc[${HoldCnt}-${Me.Speed}/100*${HoldCnt}]}
					press "${Nav.AUTORUN}"
				}
				wait 2
			}
*/			break
	}
	lastdevice:Set[${devicename}]
	
	if (${Target.CheckCollision})
		echo "EQ2Craft:: Collision detected between you and ${Target} -- Handle it?? ..does it matter??"

	waitframe
	if ${Me.IsMoving}
	{
		call StopRunning
		waitframe
	}
	if (${Target.Distance} > 5)
	{
		press "${Nav.AUTORUN}"
		do
		{
			waitframe
		}
		while ${Target.Distance} > 5
		
		waitframe
		call StopRunning
	}
	if (${Target.Distance} < 3 && ${Target.Type.Equal[Tradeskill Unit]})
	{
		press -hold "${Nav.MOVEBACKWARD}"
		do
		{
			waitframe
		}
		while ${Target.Distance} < 3
		press -release "${Nav.MOVEBACKWARD}"
		waitframe
		; just in case...
		press -release "${Nav.MOVEBACKWARD}"
		waitframe
	}
	
	;;; Just in case....
	if (${Me.IsMoving})
		call StopRunning
	wait 1
}

function Cancel()
{
return
}
function StopRunning()
{
	press -hold "${Nav.MOVEBACKWARD}"
	waitframe
	press -release "${Nav.MOVEBACKWARD}"
}
