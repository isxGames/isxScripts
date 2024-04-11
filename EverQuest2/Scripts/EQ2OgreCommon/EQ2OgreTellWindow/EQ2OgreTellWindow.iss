/** ***********Version: 1.01*********************
* 	***Created by Kannkor (HotShot)***	*
* Forwards tells via uplink 			*
* Pops up a new window and displays tells from	*
*	all uplink sessions			*
* Usage:Run EQ2OgreTellWindow -B-R		*
*	-B -- Means broadcast all tells through	*
*		the uplink			*
*	-R -- Means when tells come through the	*
*		uplink, displays them on screen	*
*	-N -- Means noise when tell received	*
*						*
*	Version 1.01 - Added sound option	*
*		- Sound file itself came from	*
*			eq2afkalarm		*
********************************************* **/

variable(global) int ConsoleTellWindow
variable string ChatAlarm="${LavishScript.HomeDirectory}/scripts/Eq2OgreCommon/Sounds/chatalarm.wav"
variable bool BroadcastTells=FALSE
variable bool ReceiveBroadcastTells=FALSE
variable bool PlayNoiseOnReceivedBroadCast=FALSE
function main(string Args)
{
	if ${Args.Length}==0
	{
		echo Usage: Run EQ2OgreTellWindow -b-r
		echo -B -- Means broadcast all tells through the uplink
		echo -R -- Means when tells come through the uplink, displays them on screen
		echo -N -- Means noise when tell received
		Script:End
	}
	if ${Args.Find[-b](exists)}
	{
		echo EQ2OgreTellWindow: Broadcasting tells to the uplink
		BroadcastTells:Set[TRUE]
	}
	
	if ${Args.Find[-r](exists)}
	{
		echo EQ2OgreTellWindow: Displaying tells broadcast from the uplink
		ReceiveBroadcastTells:Set[TRUE]
	}

	if ${Args.Find[-n](exists)}
	{
		echo EQ2OgreTellWindow: Playing a noise when tells received
		PlayNoiseOnReceivedBroadCast:Set[TRUE]
	}

	if !${BroadcastTells} && !${ReceiveBroadcastTells}
	{
		echo You must select to broadcast and/or Receive tells. Use "Run EQ2OgreTellWindow -B-R"
		Script:End
	}

	Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
	while 1
	{
		ExecuteQueued
		wait 10
	}	
}
atom(script) EQ2_onIncomingChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
	;Chat type 15=group, 16=raid, 28=tell, 8=say

	if ${ChatType}==28 && ${ChatTarget.Equal[${Me.Name}]} && ${BroadcastTells}
		relay all "Script[EQ2OgreTellWindow]:QueueCommand[call TellBroadcastReceived \"${Time}: ${Speaker} tells <${ChatTarget}>: ${Message}\"]"

}
function TellBroadcastReceived(string Message)
{
	if ${ReceiveBroadcastTells}
	{
		if !${UIElement[eq2ogretellwindowxml](exists)}
		{
			ui -reload -skin EQ2-Green "${LavishScript.HomeDirectory}/Scripts/EQ2OgreTellWindow/TellWindow.xml"
			wait 100 ${UIElement[eq2ogretellwindowxml](exists)}
		}
		if !${UIElement[eq2ogretellwindowxml](exists)}
		{
			echo Tell Window (xml) won't open. Report error: TellBroadcastreceived Error #1
			return
		}
		if !${UIElement[eq2ogretellwindowxml].Visible}
		{
			UIElement[eq2ogretellwindowxml]:Show
			wait 100 ${UIElement[eq2ogretellwindowxml].Visible}
		}
		if !${UIElement[eq2ogretellwindowxml].Visible}
		{
			echo Tell Window (xml) won't become visible. Report error: TellBroadcastreceived Error #2
			return
		}
		UIElement[${ConsoleTellWindow}]:Echo["${Message}"]
		if ${PlayNoiseOnReceivedBroadCast}
		{
			play "${ChatAlarm}"
		}
	}
}
atom atexit()
{
	if ${UIElement[eq2ogretellwindowxml](exists)}
		ui -unload "Scripts/EQ2OgreTellWindow/TellWindow.xml"
}