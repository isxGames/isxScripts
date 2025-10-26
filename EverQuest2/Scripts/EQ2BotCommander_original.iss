;****************************************
;Original Version 20060705a
;by Karye
;Current Version 20082404a
;by Wired203
;
;****************************************
#include ${LavishScript.HomeDirectory}/Scripts/EQ2Common/MovementKeys.iss

variable bool Questor=FALSE
variable bool Following=FALSE
variable bool EQ2BotRunning=FALSE
variable bool Pause=FALSE
variable bool afkalarm=FALSE
variable bool Disarm=FALSE
variable bool MezOn=FALSE
variable bool PreHeals=FALSE
variable bool ShadowOn=FALSE
variable bool MentorOn=FALSE
variable bool UplinkRunning=FALSE
variable settingsetref Config
variable filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/EQ2BotCommanderSettings.xml"
variable bool UplinkCheck1=FALSE
variable bool UplinkCheck2=FALSE
variable bool UplinkCheck3=FALSE
variable string UplinkPC1
variable string UplinkPC2
variable string UplinkPC3
variable string UplinkPort1
variable string UplinkPort2
variable string UplinkPort3

function main()
{


	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/EQ2-Green/EQ2-Green.xml"
	ui -reload -skin EQ2-Green "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.xml"
	call LoadSettings
	call StartUplink
	
	  do
	  {
	    if !${QueuedCommands}
	      WaitFrame
	    else
	      ExecuteQueued
	  }
	  while 1

}

function LoadSettings()
{
	LavishSettings:AddSet[EQ2BotCommander]
	LavishSettings[EQ2BotCommander]:Clear
	LavishSettings[EQ2BotCommander]:AddSet[Config]
	Config:Set[${LavishSettings[EQ2BotCommander].FindSet[Config]}]
	LavishSettings[EQ2BotCommander]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/EQ2BotCommanderSettings.xml"]

	UplinkCheck1:Set[${Config.FindSetting[UplinkCheck1,FALSE]}]
	UplinkCheck2:Set[${Config.FindSetting[UplinkCheck2,FALSE]}]
	UplinkCheck3:Set[${Config.FindSetting[UplinkCheck3,FALSE]}]
	UplinkPC1:Set[${Config.FindSetting[UplinkPC1,PCNAME]}]
	UplinkPC2:Set[${Config.FindSetting[UplinkPC2,PCNAME]}]
	UplinkPC3:Set[${Config.FindSetting[UplinkPC3,PCNAME]}]
	UplinkPort1:Set[${Config.FindSetting[UplinkPort1,10101]}]
	UplinkPort2:Set[${Config.FindSetting[UplinkPort2,10101]}]
	UplinkPort3:Set[${Config.FindSetting[UplinkPort3,10101]}]
	
	if ${UplinkCheck1}
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck1]:SetChecked
	}
	if ${UplinkCheck2}
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck2]:SetChecked
	}
	if ${UplinkCheck3}
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck3]:SetChecked
	}
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1]:SetText[${UplinkPC1}]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2]:SetText[${UplinkPC2}]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3]:SetText[${UplinkPC3}]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1]:SetText[${UplinkPort1}]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2]:SetText[${UplinkPort2}]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3]:SetText[${UplinkPort3}]
	
return
}

function CheckBoxPush()
{
	if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck1].Checked}
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1]:SetAlpha[1]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1]:SetAlpha[1]
		UplinkCheck1:Set[TRUE]
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1]:SetAlpha[0.1]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1]:SetAlpha[0.1]
		UplinkCheck1:Set[FALSE]
	}
	if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck2].Checked}
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2]:SetAlpha[1]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2]:SetAlpha[1]
		UplinkCheck2:Set[TRUE]
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2]:SetAlpha[0.1]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2]:SetAlpha[0.1]
		UplinkCheck2:Set[FALSE]
	}
	if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck3].Checked}
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3]:SetAlpha[1]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3]:SetAlpha[1]
		UplinkCheck3:Set[TRUE]
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3]:SetAlpha[0.1]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3]:SetAlpha[0.1]
		UplinkCheck3:Set[FALSE]
	}
	return
}

function StartUplink()
{
	call CheckBoxPush
		if ${UplinkRunning}==FALSE
			{
			if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck1].Checked} || ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck2].Checked} || ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck3].Checked}
			{
				UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[StartUplinkButton].Font:SetColor[FF32CD32]
			}
			else
			{
				UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[StartUplinkButton].Font:SetColor[FFFF0000]	
			}

			if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck1].Checked}
			{
				Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1].Text}
				Uplink RemoteUplink -Connect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1].Text}
			}
			else
			{
				Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1].Text}
			}
	
			if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck2].Checked}
			{
				Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2].Text}
				Uplink RemoteUplink -Connect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2].Text}
			}
			else
			{
				Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2].Text}
			}
	
			if ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkCheck3].Checked}
			{
				Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3].Text}
				Uplink RemoteUplink -Connect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3].Text}
			}
			else
			{
				Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3].Text}
			}
			UplinkRunning:Set[TRUE]
		}
		else
		{
			Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1].Text}
			Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2].Text}
			Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3].Text}
			UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[StartUplinkButton].Font:SetColor[FFFF0000]	
			UplinkRunning:Set[FALSE]
		}
		
}

function FollowToggle()
{
	if ${Following} == FALSE
	{
		Following:Set[TRUE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Follow].Font:SetColor[FF32CD32]
		Relay "all other" Script[EQ2Bot]:ExecuteAtom[AutoFollowTank]
	}
	else
	{
		Following:Set[FALSE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Follow].Font:SetColor[FFFF0000]
		Relay "all other" Script[EQ2Bot]:ExecuteAtom[StopAutoFollowing]
	}
}

function ToggleRunEQ2Bot()
{
	if ${EQ2BotRunning} == FALSE
	{
		EQ2BotRunning:Set[TRUE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[RunEQ2Bot]:SetText[End EQ2BOT]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[RunEQ2Bot].Font:SetColor[FF32CD32]
		Relay all RunScript EQ2Bot/EQ2Bot
		wait 20
		Relay all "UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,button]:LeftClick"
		Pause:Set[TRUE]
		wait 10
		Relay all "UIElement[EQ2 Bot].FindUsableChild[Minimize,button]:LeftClick"
	}
	else
	{
		EQ2BotRunning:Set[FALSE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[RunEQ2Bot]:SetText[Run EQ2BOT]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[RunEQ2Bot].Font:SetColor[FFFF0000]
		Relay all EndScript EQ2Bot
		Pause:Set[FALSE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[StartEQ2Bot].Font:SetColor[FFFF0000]
		Following:Set[FALSE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Follow].Font:SetColor[FFFF0000]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Mezmode].Font:SetColor[FFFF0000]
	}
}

function StartPauseEQ2Bot()
{
	if ${Pause} == FALSE
	{
		Pause:Set[TRUE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[StartEQ2Bot].Font:SetColor[FFFF0000]
		Relay all ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
	}
	else
	{
		Pause:Set[FALSE]
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[StartEQ2Bot].Font:SetColor[FF32CD32]
		Relay all ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
		Relay all "Press ${forward}"
		Relay all "Press ${strafeleft}"
	}

}

function ToggleQuestor()
{
	if ${Questor} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[EQ2Quest].Font:SetColor[FF32CD32]
		Questor:Set[TRUE]
		Relay all RunScript EQ2Quest
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[EQ2Quest].Font:SetColor[FFFF0000]
		Questor:Set[FALSE]
		Relay all EndScript EQ2Quest
	}
}

function afktoggle()
{
	if ${afkalarm} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[EQ2AFKAlarm].Font:SetColor[FF32CD32]
		afkalarm:Set[TRUE]
		Relay all RunScript EQ2AFKAlarm
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[EQ2AFKAlarm].Font:SetColor[FFFF0000]
		afkalarm:Set[FALSE]
		Relay all EndScript EQ2AFKAlarm
	}
}

function InviteTarget()
{
	eq2execute /invite ${Target}
	wait 20
	relay "all other" eq2execute acceptinvite
}

function HailT()
{
	relay "all other" eq2execute /target ${Target}
	wait 10
	relay "all other" eq2execute /Hail
}

function AutoDis()
{
	if ${Disarm} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[AutoDisarm].Font:SetColor[FF32CD32]
		Disarm:Set[TRUE]
		Relay all RunScript AutoDisarm
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[AutoDisarm].Font:SetColor[FFFF0000]
		Disarm:Set[FALSE]
		Relay all EndScript AutoDisarm
	}

}

function Revive()
{
Relay all EQ2Execute "select_junction 0"
}

function MezM()
{
	if ${MezOn} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Mezmode].Font:SetColor[FF32CD32]
		MezOn:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.MezzMode:Set[TRUE]
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Mezmode].Font:SetColor[FFFF0000]
		MezOn:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.MezzMode:Set[FALSE]
	}
}

function PreH()
{
	if ${PreHeals} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Pre-Heal].Font:SetColor[FF32CD32]
		PreHeals:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.KeepReactiveUp:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.KeepWardUp:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.PreHealMode:Set[TRUE]
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Main].FindChild[Pre-Heal].Font:SetColor[FFFF0000]
		PreHeals:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.KeepReactiveUp:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.KeepWardUp:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.PreHealMode:Set[FALSE]
	}

}

function Gate()
{
	Relay all eq2execute useability Call of the Overlord
	Relay all eq2execute useability Call of Qeynos
	Relay all eq2execute useability Call of Kelethin
	Relay all eq2execute useability Call of Gorowyn
	Relay all eq2execute useability Call of Neriak
}

function ShadowToggle()
{
	if ${ShadowOn} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[Shadow].Font:SetColor[FF32CD32]
		ShadowOn:Set[TRUE]
		Relay "all other" RunScript Shadow ${Target} 2
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[Shadow].Font:SetColor[FFFF0000]
		ShadowOn:Set[FALSE]
		Relay "all other" EndScript Shadow
	}
}

function Mentor()
{
	if ${MentorOn} == FALSE
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[AutoMentor].Font:SetColor[FF32CD32]
		MentorOn:Set[TRUE]
		Relay all RunScript automentor ${Target}
	}
	else
	{
		UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[AutoMentor].Font:SetColor[FFFF0000]
		MentorOn:Set[FALSE]
		Relay all EndScript automentor
	}
}

function SaveSettings()
{
		UplinkPC1:Set[${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1].Text}]
		UplinkPC2:Set[${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2].Text}]
		UplinkPC3:Set[${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3].Text}]
		UplinkPort1:Set[${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1].Text}]
		UplinkPort2:Set[${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2].Text}]
		UplinkPort3:Set[${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3].Text}]
		
		Config.FindSetting[UplinkCheck1]:Set[${UplinkCheck1}]
		Config.FindSetting[UplinkCheck2]:Set[${UplinkCheck2}]
		Config.FindSetting[UplinkCheck3]:Set[${UplinkCheck3}]
		Config.FindSetting[UplinkPC1]:Set[${UplinkPC1}]
		Config.FindSetting[UplinkPC2]:Set[${UplinkPC2}]
		Config.FindSetting[UplinkPC3]:Set[${UplinkPC3}]
		Config.FindSetting[UplinkPort1]:Set[${UplinkPort1}]
		Config.FindSetting[UplinkPort2]:Set[${UplinkPort2}]
		Config.FindSetting[UplinkPort3]:Set[${UplinkPort3}]
		
		LavishSettings[EQ2BotCommander]:Export["${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/EQ2BotCommanderSettings.xml"]
return
}

function atexit()
{
	EQ2Echo Ending EQ2BotCommander!
	
	Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC1].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort1].Text}
	Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC2].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort2].Text}
	Uplink RemoteUplink -disconnect ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPC3].Text} ${UIElement[EQ2Bot Commander].FindChild[GUITabs].FindChild[Misc].FindChild[UplinkPort3].Text}
	call SaveSettings
	
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.xml"

}