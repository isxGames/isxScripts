;****************************************
;Original Version 20060705a
;by Karye
;Current Version 20082404a
;by Wired203
;
;MIGRATED TO LGUI2 - 2025-10-23 (Amadeus)
;****************************************
#include ${LavishScript.HomeDirectory}/Scripts/EQ2Common/MovementKeys.iss
#include ${LavishScript.HomeDirectory}/Scripts/LGUI2Scaling.iss

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
variable string UplinkButtonState="red"
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

atom(script) Shutdown()
{
	call SaveSettings
	Script:End
}

function main()
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;; GUI Scaling
	;; EQ2BotCommander comes with a GUI window.  If you need to increase or decrease the size of the window (and the elements within) simply change 
	;; the uiScale variable below.  For example, to make everything twice as large, set it to 2.0.  To make everything half as large, set to 0.5
	variable float uiScale = 1.0

	;; Do not edit below this line
	if (!${uiScale.Equal[1.0]})
	{
		; Preprocess JSON to scale all dimensions
		if ${DebugScaling}
			echo Preprocessing UI with ${uiScale}x scale factor...

		; Call the scaling function directly with absolute paths
		call ScaleUIJson "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.json" "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander_Scaled.json" ${uiScale}

		; Load the scaled LGUI2 package
		LGUI2:LoadPackageFile["${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander_Scaled.json"]
	}
	else
		LGUI2:LoadPackageFile["${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.json"]
	;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Wait for window to initialize
	wait 10 ${LGUI2.Element[EQ2BotCommander.Window](exists)}

	call LoadSettings
	call StartUplink

	while 1
	{
		if !${QueuedCommands}
			WaitFrame
		else
			ExecuteQueued
	}
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

	; Load window position (if previously saved)
	variable int WindowX
	variable int WindowY
	WindowX:Set[${Config.FindSetting[WindowX,-1]}]
	WindowY:Set[${Config.FindSetting[WindowY,-1]}]

	; Apply saved window position (only if valid values were saved)
	if ${WindowX} >= 0 && ${WindowY} >= 0
	{
		LGUI2.Element[EQ2BotCommander.Window]:SetLocation[${WindowX}, ${WindowY}]
	}

	if ${UplinkCheck1}
	{
		LGUI2.Element[Misc.UplinkCheck1]:SetChecked[TRUE]
	}
	if ${UplinkCheck2}
	{
		LGUI2.Element[Misc.UplinkCheck2]:SetChecked[TRUE]
	}
	if ${UplinkCheck3}
	{
		LGUI2.Element[Misc.UplinkCheck3]:SetChecked[TRUE]
	}
		LGUI2.Element[Misc.UplinkPC1]:SetText[${UplinkPC1}]
		LGUI2.Element[Misc.UplinkPC2]:SetText[${UplinkPC2}]
		LGUI2.Element[Misc.UplinkPC3]:SetText[${UplinkPC3}]
		LGUI2.Element[Misc.UplinkPort1]:SetText[${UplinkPort1}]
		LGUI2.Element[Misc.UplinkPort2]:SetText[${UplinkPort2}]
		LGUI2.Element[Misc.UplinkPort3]:SetText[${UplinkPort3}]

return
}

function CheckBoxPush()
{
	if ${LGUI2.Element[Misc.UplinkCheck1].Checked}
	{
		LGUI2.Element[Misc.UplinkPC1]:FireEventHandler[setEnabled]
		LGUI2.Element[Misc.UplinkPort1]:FireEventHandler[setEnabled]
		UplinkCheck1:Set[TRUE]
	}
	else
	{
		LGUI2.Element[Misc.UplinkPC1]:FireEventHandler[setDisabled]
		LGUI2.Element[Misc.UplinkPort1]:FireEventHandler[setDisabled]
		UplinkCheck1:Set[FALSE]
	}
	if ${LGUI2.Element[Misc.UplinkCheck2].Checked}
	{
		LGUI2.Element[Misc.UplinkPC2]:FireEventHandler[setEnabled]
		LGUI2.Element[Misc.UplinkPort2]:FireEventHandler[setEnabled]
		UplinkCheck2:Set[TRUE]
	}
	else
	{
		LGUI2.Element[Misc.UplinkPC2]:FireEventHandler[setDisabled]
		LGUI2.Element[Misc.UplinkPort2]:FireEventHandler[setDisabled]
		UplinkCheck2:Set[FALSE]
	}
	if ${LGUI2.Element[Misc.UplinkCheck3].Checked}
	{
		LGUI2.Element[Misc.UplinkPC3]:FireEventHandler[setEnabled]
		LGUI2.Element[Misc.UplinkPort3]:FireEventHandler[setEnabled]
		UplinkCheck3:Set[TRUE]
	}
	else
	{
		LGUI2.Element[Misc.UplinkPC3]:FireEventHandler[setDisabled]
		LGUI2.Element[Misc.UplinkPort3]:FireEventHandler[setDisabled]
		UplinkCheck3:Set[FALSE]
	}

	; Update button color based on checkbox state
	if ${LGUI2.Element[Misc.UplinkCheck1].Checked} || ${LGUI2.Element[Misc.UplinkCheck2].Checked} || ${LGUI2.Element[Misc.UplinkCheck3].Checked}
	{
		UplinkButtonState:Set["green"]
		LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setGreen]
	}
	else
	{
		UplinkButtonState:Set["red"]
		LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setRed]
	}

	return
}

function ReapplyUplinkButtonColor()
{
	if ${UplinkButtonState.Equal["green"]}
	{
		LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setGreen]
	}
	else
	{
		LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setRed]
	}
}

function StartUplink()
{
	call CheckBoxPush
		if ${UplinkRunning}==FALSE
			{
			if ${LGUI2.Element[Misc.UplinkCheck1].Checked} || ${LGUI2.Element[Misc.UplinkCheck2].Checked} || ${LGUI2.Element[Misc.UplinkCheck3].Checked}
			{
				LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setGreen]
			}
			else
			{
				LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setRed]
			}

			if ${LGUI2.Element[Misc.UplinkCheck1].Checked}
			{
				Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC1].Text} ${LGUI2.Element[Misc.UplinkPort1].Text}
				Uplink RemoteUplink -Connect ${LGUI2.Element[Misc.UplinkPC1].Text} ${LGUI2.Element[Misc.UplinkPort1].Text}
			}
			else
			{
				Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC1].Text} ${LGUI2.Element[Misc.UplinkPort1].Text}
			}

			if ${LGUI2.Element[Misc.UplinkCheck2].Checked}
			{
				Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC2].Text} ${LGUI2.Element[Misc.UplinkPort2].Text}
				Uplink RemoteUplink -Connect ${LGUI2.Element[Misc.UplinkPC2].Text} ${LGUI2.Element[Misc.UplinkPort2].Text}
			}
			else
			{
				Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC2].Text} ${LGUI2.Element[Misc.UplinkPort2].Text}
			}

			if ${LGUI2.Element[Misc.UplinkCheck3].Checked}
			{
				Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC3].Text} ${LGUI2.Element[Misc.UplinkPort3].Text}
				Uplink RemoteUplink -Connect ${LGUI2.Element[Misc.UplinkPC3].Text} ${LGUI2.Element[Misc.UplinkPort3].Text}
			}
			else
			{
				Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC3].Text} ${LGUI2.Element[Misc.UplinkPort3].Text}
			}
			UplinkRunning:Set[TRUE]
		}
		else
		{
			Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC1].Text} ${LGUI2.Element[Misc.UplinkPort1].Text}
			Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC2].Text} ${LGUI2.Element[Misc.UplinkPort2].Text}
			Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC3].Text} ${LGUI2.Element[Misc.UplinkPort3].Text}
			LGUI2.Element[Misc.StartUplinkButton]:FireEventHandler[setRed]
			UplinkRunning:Set[FALSE]
		}

}

function FollowToggle()
{
	if ${Following} == FALSE
	{
		Following:Set[TRUE]
		LGUI2.Element[Main.Follow]:FireEventHandler[setGreen]
		Relay "all other" Script[EQ2Bot]:ExecuteAtom[AutoFollowTank]
	}
	else
	{
		Following:Set[FALSE]
		LGUI2.Element[Main.Follow]:FireEventHandler[setRed]
		Relay "all other" Script[EQ2Bot]:ExecuteAtom[StopAutoFollowing]
	}
}

function ReapplyFollowButtonColor()
{
	if ${Following}
	{
		LGUI2.Element[Main.Follow]:FireEventHandler[setGreen]
	}
	else
	{
		LGUI2.Element[Main.Follow]:FireEventHandler[setRed]
	}
}

function ToggleRunEQ2Bot()
{
	if ${EQ2BotRunning} == FALSE
	{
		EQ2BotRunning:Set[TRUE]
		; Button color changes from RED to GREEN to indicate active state
		; (LGUI2 limitation: Button text cannot be changed dynamically)
		LGUI2.Element[Main.RunEQ2Bot]:FireEventHandler[setGreen]
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
		; Button color changes from GREEN to RED to indicate inactive state
		LGUI2.Element[Main.RunEQ2Bot]:FireEventHandler[setRed]
		Relay all EndScript EQ2Bot
		Pause:Set[FALSE]
		LGUI2.Element[Main.StartEQ2Bot]:FireEventHandler[setRed]
		Following:Set[FALSE]
		LGUI2.Element[Main.Follow]:FireEventHandler[setRed]
		LGUI2.Element[Main.Mezmode]:FireEventHandler[setRed]
	}
}

function ReapplyRunEQ2BotButtonColor()
{
	if ${EQ2BotRunning}
		LGUI2.Element[Main.RunEQ2Bot]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Main.RunEQ2Bot]:FireEventHandler[setRed]
}

function StartPauseEQ2Bot()
{
	if ${Pause} == FALSE
	{
		Pause:Set[TRUE]
		LGUI2.Element[Main.StartEQ2Bot]:FireEventHandler[setRed]
		Relay all ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
	}
	else
	{
		Pause:Set[FALSE]
		LGUI2.Element[Main.StartEQ2Bot]:FireEventHandler[setGreen]
		Relay all ScriptScript[EQ2Bot]:QueueCommand[call ResumeBot]
		Relay all "Press ${forward}"
		Relay all "Press ${strafeleft}"
	}
}

function ReapplyStartEQ2BotButtonColor()
{
	if ${Pause}
		LGUI2.Element[Main.StartEQ2Bot]:FireEventHandler[setRed]
	else
		LGUI2.Element[Main.StartEQ2Bot]:FireEventHandler[setGreen]
}

function ToggleQuestor()
{
	if ${Questor} == FALSE
	{
		LGUI2.Element[Main.EQ2Quest]:FireEventHandler[setGreen]
		Questor:Set[TRUE]
		Relay all RunScript EQ2Quest
	}
	else
	{
		LGUI2.Element[Main.EQ2Quest]:FireEventHandler[setRed]
		Questor:Set[FALSE]
		Relay all EndScript EQ2Quest
	}
}

function ReapplyEQ2QuestButtonColor()
{
	if ${Questor}
		LGUI2.Element[Main.EQ2Quest]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Main.EQ2Quest]:FireEventHandler[setRed]
}

function afktoggle()
{
	if ${afkalarm} == FALSE
	{
		LGUI2.Element[Main.EQ2AFKAlarm]:FireEventHandler[setGreen]
		afkalarm:Set[TRUE]
		Relay all RunScript EQ2AFKAlarm
	}
	else
	{
		LGUI2.Element[Main.EQ2AFKAlarm]:FireEventHandler[setRed]
		afkalarm:Set[FALSE]
		Relay all EndScript EQ2AFKAlarm
	}
}

function ReapplyEQ2AFKAlarmButtonColor()
{
	if ${afkalarm}
		LGUI2.Element[Main.EQ2AFKAlarm]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Main.EQ2AFKAlarm]:FireEventHandler[setRed]
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
		LGUI2.Element[Main.AutoDisarm]:FireEventHandler[setGreen]
		Disarm:Set[TRUE]
		Relay all RunScript AutoDisarm
	}
	else
	{
		LGUI2.Element[Main.AutoDisarm]:FireEventHandler[setRed]
		Disarm:Set[FALSE]
		Relay all EndScript AutoDisarm
	}
}

function ReapplyAutoDisarmButtonColor()
{
	if ${Disarm}
		LGUI2.Element[Main.AutoDisarm]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Main.AutoDisarm]:FireEventHandler[setRed]
}

function Revive()
{
Relay all EQ2Execute "select_junction 0"
}

function MezM()
{
	if ${MezOn} == FALSE
	{
		LGUI2.Element[Main.Mezmode]:FireEventHandler[setGreen]
		MezOn:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.MezzMode:Set[TRUE]
	}
	else
	{
		LGUI2.Element[Main.Mezmode]:FireEventHandler[setRed]
		MezOn:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.MezzMode:Set[FALSE]
	}
}

function ReapplyMezmodeButtonColor()
{
	if ${MezOn}
		LGUI2.Element[Main.Mezmode]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Main.Mezmode]:FireEventHandler[setRed]
}

function PreH()
{
	if ${PreHeals} == FALSE
	{
		LGUI2.Element[Main.PreHeal]:FireEventHandler[setGreen]
		PreHeals:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.KeepReactiveUp:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.KeepWardUp:Set[TRUE]
		Relay all Script[EQ2Bot].VariableScope.PreHealMode:Set[TRUE]
	}
	else
	{
		LGUI2.Element[Main.PreHeal]:FireEventHandler[setRed]
		PreHeals:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.KeepReactiveUp:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.KeepWardUp:Set[FALSE]
		Relay all Script[EQ2Bot].VariableScope.PreHealMode:Set[FALSE]
	}
}

function ReapplyPreHealButtonColor()
{
	if ${PreHeals}
		LGUI2.Element[Main.PreHeal]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Main.PreHeal]:FireEventHandler[setRed]
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
		LGUI2.Element[Misc.Shadow]:FireEventHandler[setGreen]
		ShadowOn:Set[TRUE]
		Relay "all other" RunScript Shadow ${Target} 2
	}
	else
	{
		LGUI2.Element[Misc.Shadow]:FireEventHandler[setRed]
		ShadowOn:Set[FALSE]
		Relay "all other" EndScript Shadow
	}
}

function ReapplyShadowButtonColor()
{
	if ${ShadowOn}
		LGUI2.Element[Misc.Shadow]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Misc.Shadow]:FireEventHandler[setRed]
}

function Mentor()
{
	if ${MentorOn} == FALSE
	{
		LGUI2.Element[Misc.Automentor]:FireEventHandler[setGreen]
		MentorOn:Set[TRUE]
		Relay all RunScript automentor ${Target}
	}
	else
	{
		LGUI2.Element[Misc.Automentor]:FireEventHandler[setRed]
		MentorOn:Set[FALSE]
		Relay all EndScript automentor
	}
}

function ReapplyAutomentorButtonColor()
{
	if ${MentorOn}
		LGUI2.Element[Misc.Automentor]:FireEventHandler[setGreen]
	else
		LGUI2.Element[Misc.Automentor]:FireEventHandler[setRed]
}

function SaveSettings()
{
		UplinkPC1:Set[${LGUI2.Element[Misc.UplinkPC1].Text}]
		UplinkPC2:Set[${LGUI2.Element[Misc.UplinkPC2].Text}]
		UplinkPC3:Set[${LGUI2.Element[Misc.UplinkPC3].Text}]
		UplinkPort1:Set[${LGUI2.Element[Misc.UplinkPort1].Text}]
		UplinkPort2:Set[${LGUI2.Element[Misc.UplinkPort2].Text}]
		UplinkPort3:Set[${LGUI2.Element[Misc.UplinkPort3].Text}]

		Config.FindSetting[UplinkCheck1]:Set[${UplinkCheck1}]
		Config.FindSetting[UplinkCheck2]:Set[${UplinkCheck2}]
		Config.FindSetting[UplinkCheck3]:Set[${UplinkCheck3}]
		Config.FindSetting[UplinkPC1]:Set[${UplinkPC1}]
		Config.FindSetting[UplinkPC2]:Set[${UplinkPC2}]
		Config.FindSetting[UplinkPC3]:Set[${UplinkPC3}]
		Config.FindSetting[UplinkPort1]:Set[${UplinkPort1}]
		Config.FindSetting[UplinkPort2]:Set[${UplinkPort2}]
		Config.FindSetting[UplinkPort3]:Set[${UplinkPort3}]

		; Save current window position
		Config.FindSetting[WindowX]:Set[${LGUI2.Element[EQ2BotCommander.Window].X}]
		Config.FindSetting[WindowY]:Set[${LGUI2.Element[EQ2BotCommander.Window].Y}]

		LavishSettings[EQ2BotCommander]:Export["${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/EQ2BotCommanderSettings.xml"]
return
}

function atexit()
{
	EQ2Echo Ending EQ2BotCommander!

	Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC1].Text} ${LGUI2.Element[Misc.UplinkPort1].Text}
	Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC2].Text} ${LGUI2.Element[Misc.UplinkPort2].Text}
	Uplink RemoteUplink -disconnect ${LGUI2.Element[Misc.UplinkPC3].Text} ${LGUI2.Element[Misc.UplinkPort3].Text}
	call SaveSettings

	; Unload LGUI2 package instead of LGUI1 XML
	LGUI2:UnloadPackageFile["${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/EQ2BotCommander.json"]

}
