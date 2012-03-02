;-----------------------------------------------------------------------------------------------
; Obj_Yahoo - by Zandros
;
; Description - this file handles the Yahoo Instant Messenger
; --------------
; * automatically starts/ends all monitoring events
; * checks to see if ISXIM is present

;; variables used within your script
variable string YahooHandle = "Handle"
variable string YahooPassword = "Password"
variable string YahooSendToHandle = "Send messages to"
variable bool doYahooTells = "TRUE"
variable bool doYahooSays=TRUE
variable bool doYahooEmotes=TRUE
variable bool doYahooGM=TRUE

objectdef  Obj_YahooIM
{
	;; variables used by script
	variable bool doDebug = TRUE
	variable filepath FilePath = "${Script.CurrentDirectory}/Saves"
	variable bool Test = FALSE
	
	;;;;;;;;;;
	;; INITIALIZE - automatically called when objectdef is created
	method Initialize()
	{
		;; delete this file if it exists
		if ${FilePath.FileExists[/InstantMessenger.txt]}
		{
			rm "${This.FilePath}/InstantMessenger.txt"
		}

		;; if ISXIM isn't loaded then load it
		if !${IM(exists)}
		{
			ext -require ISXIM
		}
		
		;; we are bailing out if ISXIM isn't loaded
		if !${IM(exists)}
		{
			This:EchoIt["ISXIM could not be loaded... you may need to reinstall it."]
			vgecho "ISXIM could not be loaded... you may need to reinstall it."
			return
		}

		;; Now, since we're scripting ALL the events ...let's turn on QuietMode.  If you are
		;; debugging new scripts, or are having problems, be sure to turn it off so that 
		;; the extension will spew things to the console.  With QuietMode turned on, you won't
		;; see much of anything in the console.  If you want to avoid the initial spam of logging
		;; in and joining channels, then just move this line to earlier in this function.
		;; [on or off]
		IM:QuietMode[on]    

		;; Initialize/Attach the event Atoms that we defined previously
		Event[Yahoo_onSystemMessage]:AttachAtom[This:Yahoo_onSystemMessage]
		Event[Yahoo_onLoginResponse]:AttachAtom[This:Yahoo_onLoginResponse]	
		Event[Yahoo_onLogout]:AttachAtom[This:Yahoo_onLogout]
		Event[Yahoo_onIMReceived]:AttachAtom[This:Yahoo_onIMReceived]
		Event[Yahoo_onOfflineIMReceived]:AttachAtom[This:Yahoo_onOfflineIMReceived]
		Event[Yahoo_onTypingNotice]:AttachAtom[This:Yahoo_onTypingNotice]	
		Event[Yahoo_onPing]:AttachAtom[This:Yahoo_onPing]	
		Event[Yahoo_onStatusChanged]:AttachAtom[This:Yahoo_onStatusChanged]	
		Event[Yahoo_onErrorMessage]:AttachAtom[This:Yahoo_onErrorMessage]	
		Event[Yahoo_onBuzz]:AttachAtom[This:Yahoo_onBuzz]
		Event[VG_OnIncomingText]:AttachAtom[This:ChatEvent]	
		Event[VG_onAlertText]:AttachAtom[This:AlertEvent]
		Event[VG_OnPawnSpawned]:AttachAtom[This:PawnSpawned]

		This:EchoIt["Started Yahoo Instant Messenger"]
	}

	;;;;;;;;;;
	;; SHUTDOWN - automatically called when script is shutdown
	method Shutdown()
	{
		;; make sure we logout
		This:Logout
		
		;; We're done with the script, so let's detach all of the event atoms
		Event[Yahoo_onSystemMessage]:DetachAtom[This:Yahoo_onSystemMessage]
		Event[Yahoo_onLoginResponse]:DetachAtom[This:Yahoo_onLoginResponse]	
		Event[Yahoo_onLogout]:DetachAtom[This:Yahoo_onLogout]
		Event[Yahoo_onIMReceived]:DetachAtom[This:Yahoo_onIMReceived]
		Event[Yahoo_onOfflineIMReceived]:DetachAtom[This:Yahoo_onOfflineIMReceived]
		Event[Yahoo_onTypingNotice]:DetachAtom[This:Yahoo_onTypingNotice]	
		Event[Yahoo_onPing]:DetachAtom[This:Yahoo_onPing]	
		Event[Yahoo_onStatusChanged]:DetachAtom[This:Yahoo_onStatusChanged]	
		Event[Yahoo_onErrorMessage]:DetachAtom[This:Yahoo_onErrorMessage]	    
		Event[Yahoo_onBuzz]:DetachAtom[This:Yahoo_onBuzz]
		Event[VG_OnIncomingText]:DetachAtom[This:ChatEvent]	
		Event[VG_onAlertText]:DetachAtom[This:AlertEvent]
		Event[VG_OnPawnSpawned]:DetachAtom[This:PawnSpawned]
		This:EchoIt["Shutdown Yahoo Instant Messenger"]
	}

	;;;;;;;;;;
	;; DEBUG THIS - save and echo message to console
	method EchoIt(string aText)
	{
		if ${This.doDebug}
		{
			redirect -append "${This.FilePath}/InstantMessenger.txt" echo "[${Time}][YahooIM] '${aText}'"
			echo "[${Time}][YahooIM] '${aText}'"
		}
	}
	
	;;;;;;;;;;
	;; LOGIN - calling this will log into Yahoo Instant Messenger
	method Login()
	{
		if !${Yahoo.IsConnected}
		{
			This:EchoIt["Logging on:  ${YahooHandle}"]
			Yahoo:Login[${YahooHandle.Escape},${YahooPassword.Escape}]
		}
	}
	
	;;;;;;;;;;
	;; LOGOUT - calling this will log out of Yahoo Instant Messenger
	method Logout()
	{
		if ${Yahoo.IsConnected}
		{
			This:EchoIt["Logging out:  ${YahooHandle}"]
			Yahoo:Logout
		}
	}

	;;;;;;;;;;
	;; ALERT MESSAGES that are generated will come through here
	method AlertEvent(string Text, int ChannelNumber)
	{
		if ${ChannelNumber}==2
		{
			if ${Text.Find[You died.]}
			{
				Yahoo:IM[${YahooSendToHandle.Escape},"${Me.FName} just died!\nNearest AggroNPC=${Pawn[AggroNPC].Name}\nNearest PC=${Pawn[PC].Name} "]
				This:EchoIt["${Me.FName} just died! Nearest AggroNPC=${Pawn[AggroNPC].Name}, Nearest PC=${Pawn[PC].Name}"]
			}
		}
	}

	;;;;;;;;;;
	;; CHAT MESSAGES - any tells/says/emotes will come through here
	method ChatEvent(string Text, string ChannelNumber, string ChannelName)
	{
		;; TELLS
		if ${ChannelNumber}==15
		{
			if ${doYahooTells}
			{
				Yahoo:IM[${YahooSendToHandle.Escape},"[${Text.Escape}]"]
				This:EchoIt["${Text}"]
				return
			}
		}

		;; SAYS
		if ${ChannelNumber}==3
		{
			if ${doYahooSays}
			{
				Yahoo:IM[${YahooSendToHandle.Escape},"[${Text.Escape}]"]
				This:EchoIt["${Text}"]
				return
			}
		}
	
		;; EMOTES
		if ${ChannelNumber}==5
		{
			if ${doYahooEmotes}
			{
				Yahoo:IM[${YahooSendToHandle.Escape},"[${Text.Escape}]"]
				This:EchoIt["${Text}"]
				return
			}
		}
	
		;; SYSTEM MESSAGES
		if ${ChannelNumber}==0
		{
			if ${Text.Find[Server is shutting down]}
			{
				Yahoo:IM[${YahooSendToHandle.Escape},"[${Text.Escape}]"]
				This:EchoIt["${Text}"]
			}
		}
		
		;; BROAD CAST (serverwide / localserver)
		if ${ChannelNumber}==39 || ${ChannelNumber}==77
		{
			if ${Text.Find[servers will be coming down]}
			{
				Yahoo:IM[${YahooSendToHandle.Escape},"[${Text.Escape}]"]
				This:EchoIt["${Text}"]
			}
		}
	}

	;;;;;;;;;;
	;; PAWN SPAWNED - anything that spawns will show up here
	method PawnSpawned(string aID, string aName, string aLevel, string aType)
	{
		if ${Pawn[${aName}].Title.Find[Crimson Fellowship]} || ${Pawn[${aName}].Title.Find[Keepers of Telon]}
		{
			This:EchoIt["GM Spawned: [ID=${aID}][Name=${aName}][Level=${aLevel}][Type=${aType}]"]
			Yahoo:IM[${YahooSendToHandle.Escape},"GM just spawned ${Pawn[${aName}].Distance.Int} meters away\n${aName.Escape}"]
		}
	}

	;;;;;;;;;;
	;; LOGIN RESPONSE - Connected or not
	method Yahoo_onLoginResponse(string Response, string ErrorMsg)
	{
		; - Response can be either:  CONNECTED or ERROR
		; - ErrorMSg will be "N/A" if Response is "CONNECTED"

		if (${Response.Equal[CONNECTED]})
		{
			This:EchoIt["${YahooHandle} successfully logged into Yahoo Instant Messenger"]
			;Yahoo:IM[${YahooSendToHandle},"${YahooHandle} successfully logged into ISXIM"]
		}
		elseif (${Response.Equal[ERROR]})
		{
			This:EchoIt["${YahooHandle.Escape} failed to login.  Error: ${ErrorMsg}"]
		}
	}

	;;;;;;;;;;
	;; LOGOUT RESPONSE - all we are going to do is echo if we successfully logged out of ISXIM
	method Yahoo_onLogout()
	{
		This:EchoIt["${YahooHandle} successfully logged out of Yahoo Instant Messenger"]
	}

	;;;;;;;;;;
	;; IM RECEIVED - what are we going to do if we receive an instant message
	method Yahoo_onIMReceived(string From, string Message)
	{
		This:EchoIt["From ${From}, Message=${Message}"]
	
		;; This is here to protect others from sending commands to the script
		;; This is here to protect others from sending commands to the script
		if ${From.Equal[${YahooSendToHandle}]}
		{
			if "${Message.Left[1].Equal[?]}"
			{
				Yahoo:IM[${YahooSendToHandle},"Any VG command such as /laugh, /tell Someone Hello\n#XP - Level/XP\n#Status - InCombat/Health/Nearest targets/Total Kills\n#HuntOn - turn Hunting on\n#HuntOff - turn Hunting off\n#Camp - camp\n#BuffArea - buff everyone"]
				This:EchoIt["Help"]
			}
		
			if "${Message.Left[1].Equal[#]}"
			{
				variable string Command
				Command:Set[${Message.Right[-1]}]
				switch ${Command}
				{
					case XP
						Yahoo:IM[${YahooSendToHandle},"Level=${Me.Level} Exp=${Me.XP}"]
						This:EchoIt["Level=${Me.Level} Exp=${Me.XP}"]
						break
					case Status
						Yahoo:IM[${YahooSendToHandle},"InCombat=${Me.InCombat}\nHealth=${Me.HealthPct}\nNearest AgrroNPC=${Pawn[AggroNPC].Name}\nNearest PC=${Pawn[PC].Name}\nHunting=${doHunt}\nTotal Kills=${TotalKills}\nAverage Kills Per Hour=${KPH}"]
						This:EchoIt["InCombat=${Me.InCombat}\nHealth=${Me.HealthPct}\nNearest AgrroNPC=${Pawn[AggroNPC].Name}\nNearest PC=${Pawn[PC].Name}\nHunting=${doHunt}\nTotalKills=${TotalKills}"]
						break
					case HuntOn
						doHunt:Set[TRUE]
						Yahoo:IM[${YahooSendToHandle},"Hunting=${doHunt}"]
						This:EchoIt["Hunting=${doHunt}"]
						break
					case HuntOff
						doHunt:Set[FALSE]
						Yahoo:IM[${YahooSendToHandle},"Hunting=${doHunt}"]
						This:EchoIt["Hunting=${doHunt}"]
						break
					case Camp
						doCamp:Set[TRUE]
						Yahoo:IM[${YahooSendToHandle},"Camp after battle"]
						This:EchoIt["Camp after battle"]
						break
					case BuffArea
						doBuffArea:Set[TRUE]
						Yahoo:IM[${YahooSendToHandle},"buffing Area = ${doBuffArea}"]
						This:EchoIt["Buff Area"]
						break
					case Help
						Yahoo:IM[${YahooSendToHandle},"Any VG command such as /laugh, /tell Someone Hello\n#XP - Level/XP\n#Status - InCombat/Health/Nearest targets/Total Kills\n#HuntOn - turn Hunting on\n#HuntOff - turn Hunting off\n#Camp - camp\n#BuffArea - buff everyone"]
						This:EchoIt["Help"]
						break
					case Default
						break
				}
			}
			if "${Message.Left[1].Equal[/]}"
			{
				timedcommand 10 "VGExecute ${Message.Escape}"
			}
		}
	}

	;;;;;;;;;;
	;; IM RECEIVED (OFFLINE) - what are we going to do if we receive an instant message
	method Yahoo_onOfflineIMReceived(string From, string Message, string When)
	{
		This:EchoIt["From ${From}, Message=${Message}"]
	
		;; This is here to protect others from sending commands to the script
		if ${From.Equal[${YahooSendToHandle}]}
		{
			if "${Message.Left[1].Equal[?]}"
			{
				Yahoo:IM[${YahooSendToHandle},"Any VG command such as /laugh, /tell Someone Hello\n#XP - Level/XP\n#Status - InCombat/Health/Nearest targets/Total Kills\n#HuntOn - turn Hunting on\n#HuntOff - turn Hunting off\n#Camp - camp\n#BuffArea - buff everyone"]
				This:EchoIt["Help"]
			}
		
			if "${Message.Left[1].Equal[#]}"
			{
				variable string Command
				Command:Set[${Message.Right[-1]}]
				switch ${Command}
				{
					case XP
						Yahoo:IM[${YahooSendToHandle},"Level=${Me.Level} Exp=${Me.XP}"]
						This:EchoIt["Level=${Me.Level} Exp=${Me.XP}"]
						break
					case Status
						Yahoo:IM[${YahooSendToHandle},"InCombat=${Me.InCombat}\nHealth=${Me.HealthPct}\nNearest AgrroNPC=${Pawn[AggroNPC].Name}\nNearest PC=${Pawn[PC].Name}\nHunting=${doHunt}\nTotal Kills=${TotalKills}\nAverage Kills Per Hour=${KPH}"]
						This:EchoIt["InCombat=${Me.InCombat}\nHealth=${Me.HealthPct}\nNearest AgrroNPC=${Pawn[AggroNPC].Name}\nNearest PC=${Pawn[PC].Name}\nHunting=${doHunt}\nTotalKills=${TotalKills}"]
						break
					case HuntOn
						doHunt:Set[TRUE]
						Yahoo:IM[${YahooSendToHandle},"Hunting=${doHunt}"]
						This:EchoIt["Hunting=${doHunt}"]
						break
					case HuntOff
						doHunt:Set[FALSE]
						Yahoo:IM[${YahooSendToHandle},"Hunting=${doHunt}"]
						This:EchoIt["Hunting=${doHunt}"]
						break
					case Camp
						doCamp:Set[TRUE]
						Yahoo:IM[${YahooSendToHandle},"Camp after battle"]
						This:EchoIt["Camp after battle"]
						break
					case BuffArea
						doBuffArea:Set[TRUE]
						Yahoo:IM[${YahooSendToHandle},"buffing Area = ${doBuffArea}"]
						This:EchoIt["Buff Area"]
						break
					case Help
						Yahoo:IM[${YahooSendToHandle},"Any VG command such as /laugh, /tell Someone Hello\n#XP - Level/XP\n#Status - InCombat/Health/Nearest targets/Total Kills\n#HuntOn - turn Hunting on\n#HuntOff - turn Hunting off\n#Camp - camp\n#BuffArea - buff everyone"]
						This:EchoIt["Help"]
						break
					case Default
						break
				}
			}
			if "${Message.Left[1].Equal[/]}"
			{
				timedcommand 10 "VGExecute ${Message.Escape}"
			}
		}
	}

	method Yahoo_onSystemMessage(string Msg)
	{
		  echo "[Y!] System Message: ${Msg.Escape}"
	}

	method Yahoo_onTypingNotice(string Who)
	{
		echo "[Y!] ${Who.Escape} is typing..."
	}

	method Yahoo_onPing(string ErrorMsg)
	{
		; - ErrorMSg will be "N/A" if no error is associated with this ping.
		if !${ErrorMsg.Equal[N/A]}
		{
			echo "[Y!] Error on ping: '${ErrorMsg}'"
		}
	}

	method Yahoo_onStatusChanged(string Who, string Status)
	{
		; This event will fire once for every 'buddy' that's online when you first log in.
		echo "[Y!] ${Who}: '${Status.Escape}'"
	}

	method Yahoo_onErrorMessage(int ID, string Msg)
	{
		echo "[Y!] Error Message Received: ${Msg}"
	}

	method Yahoo_onBuzz(string From, string To, string When)
	{
		if (${When.Length} > 0)
		{
			echo "[Y!] ${From} has *BUZZED* ${To} [${When}]"
		}
		else
		{
			echo "[Y!] ${From} has *BUZZED* ${To}!"
		}
	}
}