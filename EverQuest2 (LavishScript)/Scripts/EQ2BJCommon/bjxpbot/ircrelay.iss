variable float startexp=${Me.APExp}
variable int starttime=${Time.Timestamp}

function main()
{
	call IRC_Init ${IRCServerTextEntryVar} ${Me.SubClass}_${IRCNicknameSuffixTextEntryVar}
	call IRC_Connect
	call IRC_JoinChannel ${IRCChannelTextEntryVar}
	variable string message
	
	while (1)
	{
		wait ${Math.Rand[50]:Inc[3000]}
		message:Set[EXP: ${Me.Level} at ${Me.Exp}   -------   AA: ${Me.TotalEarnedAPs} at ${Me.APExp}% with ${Math.Calc[((${Me.APExp} - ${startexp}) / (${Time.Timestamp} - ${starttime})) * 3600]} % per hour]
		call IRC_SendPM ${IRCChannelTextEntryVar} "${message}"
		echo ${message}
	}
}

function atexit()
{
	call IRC_Shutdown
}

variable float VERSION = 2.0


/*
 * ISXIM Irc Library

 * This is intended to be included with scripts that use ISXIM.
 *
 * It assumes that you will only connect to one server with one nick
 * per inclusion of this file.  (Multiple channels are OK.)
 *
 */
 
 
/* -------------------- Global Variables ----------------------- */
variable string IRC_Server
variable string IRC_Nick
variable string IRC_NickPassword

variable int RegisteredChannelRetryAttempts = 0

variable bool IRC_Initialized = FALSE
variable bool QuietMode = TRUE




/* -------------------- Functions ------------------------------ */

function IRC_Init(string Server, string Nick, string NickPassword)
{
	ext -require isxim
	wait 100 ${IM(exists)}
	if !${IM(exists)}
	{
		echo "[${Time}] --> Unable to load ISXIM -- IRC module will not be used.
		return
	}
	
	IRC_Server:Set[${Server}]
	IRC_Nick:Set[${Nick}]
	IRC_NickPassword:Set[${NickPassword}]
	
	if (${IRC_Server.Length} <= 0 || ${IRC_Nick.Length} <= 0)
	{
		echo "IRC:: IRC_Init() called with an empty 'Server' or 'Nick' argument."
		return
	}
	
    Event[IRC_ReceivedChannelMsg]:AttachAtom[IRC_ReceivedChannelMsg]	
    Event[IRC_ReceivedPrivateMsg]:AttachAtom[IRC_ReceivedPrivateMsg]
    Event[IRC_TopicSet]:AttachAtom[IRC_TopicSet]
    Event[IRC_NickChanged]:AttachAtom[IRC_NickChanged]
    Event[IRC_KickedFromChannel]:AttachAtom[IRC_KickedFromChannel]	
    Event[IRC_ReceivedCTCP]:AttachAtom[IRC_ReceivedCTCP]	
    Event[IRC_PRIVMSGErrorResponse]:AttachAtom[IRC_PRIVMSGErrorResponse]	
    Event[IRC_JOINErrorResponse]:AttachAtom[IRC_JOINErrorResponse]	
    Event[IRC_NickTypeChange]:AttachAtom[IRC_NickTypeChange]
    Event[IRC_NickJoinedChannel]:AttachAtom[IRC_NickJoinedChannel]
    Event[IRC_NickLeftChannel]:AttachAtom[IRC_NickLeftChannel]
    Event[IRC_NickQuit]:AttachAtom[IRC_NickQuit]
    Event[IRC_ReceivedEmote]:AttachAtom[IRC_ReceivedEmote]
    Event[IRC_ChannelModeChange]:AttachAtom[IRC_ChannelModeChange]
    Event[IRC_AddChannelBan]:AttachAtom[IRC_AddChannelBan]
    Event[IRC_RemoveChannelBan]:AttachAtom[IRC_RemoveChannelBan]
    Event[IRC_UnhandledEvent]:AttachAtom[IRC_UnhandledEvent]	

	if ${QuietMode}
		IM:QuietMode[on]
	else
		IM:QuietMode[off]

	IRC_Initialized:Set[TRUE]
	return
}

function IRC_Shutdown()
{
	if !${IM(exists)}
		return
		
    Event[IRC_ReceivedChannelMsg]:DetachAtom[IRC_ReceivedChannelMsg]	
    Event[IRC_ReceivedPrivateMsg]:DetachAtom[IRC_ReceivedPrivateMsg]
    Event[IRC_TopicSet]:DetachAtom[IRC_TopicSet]
    Event[IRC_NickChanged]:DetachAtom[IRC_NickChanged]
    Event[IRC_KickedFromChannel]:DetachAtom[IRC_KickedFromChannel]	
    Event[IRC_ReceivedCTCP]:DetachAtom[IRC_ReceivedCTCP]	
    Event[IRC_PRIVMSGErrorResponse]:DetachAtom[IRC_PRIVMSGErrorResponse]	
    Event[IRC_JOINErrorResponse]:DetachAtom[IRC_JOINErrorResponse]	    
    Event[IRC_NickTypeChange]:DetachAtom[IRC_NickTypeChange]
    Event[IRC_NickJoinedChannel]:DetachAtom[IRC_NickJoinedChannel]
    Event[IRC_NickLeftChannel]:DetachAtom[IRC_NickLeftChannel]    
    Event[IRC_NickQuit]:DetachAtom[IRC_NickQuit]
    Event[IRC_ReceivedEmote]:DetachAtom[IRC_ReceivedEmote]
    Event[IRC_ChannelModeChange]:DetachAtom[IRC_ChannelModeChange]
    Event[IRC_AddChannelBan]:DetachAtom[IRC_AddChannelBan]
    Event[IRC_RemoveChannelBan]:DetachAtom[IRC_RemoveChannelBan]
    Event[IRC_UnhandledEvent]:DetachAtom[IRC_UnhandledEvent]  	
    
    
    if ${IRCUser[${IRC_Nick}](exists)}
    {
    	IRCUser[${IRC_Nick}]:Disconnect
    }
    return
}

function IRC_Connect(string ServerPort, string ServerPassword)
{
	if !${IM(exists)} && !${IRC_Initialized}
		return
	
	if (${ServerPort.Length} > 0 && ${ServerPassword.Length} > 0)
		IRC:Connect[${IRC_Server},${IRC_Nick},${ServerPort},${ServerPassword}]
	elseif (${ServerPort.Length} > 0)
		IRC:Connect[${IRC_Server},${IRC_Nick},${ServerPort}]
	else
		IRC:Connect[${IRC_Server},${IRC_Nick}]
		
	wait 4
	wait 100 !${IRC.IsConnecting}
	
	return
}
	
function IRC_JoinChannel(string ChannelName, string sKey)
{
	if !${IM(exists)} || !${IRCUser[${IRC_Nick}](exists)} || !${IRC_Initialized}
		return
	
	if (${sKey.Length} > 0)
		IRCUser[${IRC_Nick}]:Join[${ChannelName},${sKey}]
	else		
		IRCUser[${IRC_Nick}]:Join[${ChannelName}]
	wait 25

	return
}	
	
function IRC_SendPM(string To, string Message)
{
	if !${IM(exists)} || !${IRCUser[${IRC_Nick}](exists)} || !${IRC_Initialized}
		return
	
	IRCUser[${IRC_Nick}]:PM[${To},${Message}]	
	
	return
}

function IRC_SendNotice(string To, string Message)
{
	if !${IM(exists)} || !${IRCUser[${IRC_Nick}](exists)} || !${IRC_Initialized}
		return
	
	IRCUser[${IRC_Nick}]:Notice[${To},${Message}]
	
	return
}

function IRC_Emote(string To, string Message)
{
	if !${IM(exists)} || !${IRCUser[${IRC_Nick}](exists)} || !${IRC_Initialized}
		return
	
	IRCUser[${IRC_Nick}]:Emote[${To},${Message}]
	
	return
}




/* -------------------- Event Handlers ------------------------- */
atom(script) IRC_ReceivedNotice(string User, string From, string To, string Message)
{
	; This event is fired every time that an IRCUser that you have connected
	; receives a NOTICE.  You can do anything fancy you want with this, but,
	; for now, we're just going to echo it to the console window.
	  
	; Deal with Nickserv:  
	if (${From.Equal[Nickserv]})
	{
		if (${Message.Find[This nickname is registered and protected]})
		{
		  	if (${To.Equal[${IRC_Nick}]})
		     	IRCUser[${IRC_Nick}]:PM[Nickserv,"identify ${IRC_NickPassword}"]
			
		  	return
		}
		elseif (${Message.Find[Password accepted]})
		{
			echo "IRC:: [${To}] Identify with Nickserv successful"
			
			; if this was an attempt to register the nick after having been
			; denied access to a channel, we want to indicate that it was
			; successful by resetting the number of attempts to zero
			if (${RegisteredChannelRetryAttempts} > 0)
				RegisteredChannelRetryAttempts:Set[0]
			return
		}
		elseif (${Message.Find[Password incorrect]})
		{
		  	echo "IRC:: [${To}] Incorrect password while attempting to identify ${To} with Nickserv"
		 	return
		}
		elseif (${Message.Find[Password authentication required]})
		{
			echo "IRC:: [${To}] Password authentication is required before you can issue commands to Nickserv"
			return
		}
		elseif (${Message.Find[nick, type]})
		{
		 	; Junk message we don't need to see
		 	return
		}
		elseif (${Message.Find[please choose a different]})
		{
			; Junk message we don't need to see
			return
		}
	}
	  
	if (${Message.Find[DCC Send]})
	{
	  	; This is handled by the CTCP event -- I am not sure why clients send both
	  	; a NOTICE and a CTCP when they're dcc'ing files
	  	return
	}	  
	elseif (${Message.Find[DCC Chat]})
	{
		; This is handled by the CTCP event -- I'm not sure why clients send both
	  	; a NOTICE and a CTCP when they're dcc'ing files
	  	return
	}	  	  
	
}

atom(script) IRC_ReceivedChannelMsg(string User, string Channel, string From, string Message)
{
	; This event is fired every time that an IRCUser that you have connected
	; receives a Channel Message.  You can do anything fancy you want with this, 
	; but, for now, we're just going to echo it to the console window.
}

atom(script) IRC_ReceivedPrivateMsg(string User, string From, string To, string Message)
{
	; This event is fired every time that an IRCUser that you have connected
	; receives a Private Message.  You can do anything fancy you want with this, 
	; but, for now, we're just going to echo it to the console window.
	
	; NOTE: ${User} should always be the same as ${To} in this instance.  However, it is
	;       included for continuity's sake.
	  
}

atom(script) IRC_ReceivedEmote(string User, string From, string To, string Message)
{
	; This event is fired every time that an IRCUser recognizes an "emote"
	; from another user.  Please note that ${To} is typically a 'channel' 
	; in this event.
	  
}

atom(script) IRC_ReceivedCTCP(string User, string From, string To, string Message)
{
	; This event is fired every time that an IRCUser that you have connected
	; receives a CTCP request.
	; IMPORTANT:  ISXIM handles all of these requests for you, so this
	;             event is only here to let you know that it occured.
	  
}

atom(script) IRC_TopicSet(string User, string Channel, string NewTopic, string TopicSetBy)
{
	; This event is fired every time that someone changes the topic of a channel
	; of which one of your IRCUser connections is a part.  You can do anything 
	; fancy you want with this, but, for now, we're just going to echo it to the 
	; console window.
	  
}

atom(script) IRC_NickChanged(string User, string OldNick, string NewNick)
{
	; This event is fired every time that someone changes their NICK in a channel
	; of which one of your IRCUser connections is a part.  You can do anything 
	; fancy you want with this, but, for now, we're just going to echo it to the 
	; console window.
	  
}

atom(script) IRC_KickedFromChannel(string User, string Channel, string WhoKicked, string KickedBy, string Reason)
{
	; This event is fired every time that one of your IRCUsers are kicked from a 
	; channel.  You can do anything fancy you want to do with this, but, for now, we're
	; just going to echo the information to the console window
		
		
	; Auto rejoin! :)
	if ${WhoKicked.Equal[${IRCNick}]}
		IRCUser[${IRCNick}]:Join[${Channel}]
}

atom(script) IRC_NickJoinedChannel(string User, string Channel, string WhoJoined)
{
	; This event is fired every time that someone joins a channel other than 
	; the IRCUser.
	  
}

atom(script) IRC_NickLeftChannel(string User, string Channel, string WhoLeft)
{
	; This event is fired every time that someone leaves a channel other than
	; the IRCUser.  This event is NOT fired when someone (or yourself) is KICKED
		
}

atom(script) IRC_NickQuit(string User, string Channel, string Nick, string Reason)
{
	; This event is fired every time that someone QUITS the server

}

atom(script) IRC_PRIVMSGErrorResponse(string User, string ErrorType, string To, string Response)
{
	; This event is fired whenever an IRCUser that you have connected receives an
	; error response while trying to send a PM.  
	; NOTE: The IRC protocol considers a message sent to a channel to be a "PM" to
	; that channel.
	  
	; Possible ${ErrorType} include: "NO_SUCH_NICKORCHANNEL", "NO_EXTERNAL_MSGS_ALLOWED"
	  
}
 
atom(script) IRC_JOINErrorResponse(string User, string ErrorType, string Channel, string Response)
{
	; This event is fired whenever an IRCUser that you have connected receives an
	; error response while trying to join a channel.  

	; Possible ${ErrorType} include: "BANNED", "MUST_BE_REGISTERED"

	if (${ErrorType.Equal[BANNED]})
	{
		return
	}
	elseif (${ErrorType.Equal[REQUIRES_KEY]})
	{
		return
	}
	elseif (${ErrorType.Equal[MUST_BE_REGISTERED]})
	{
		echo IRC:: [${User}] Received a message that we were not identified/registered.
		  
		; We will try and identify with nickserv and rejoin a total of 5 times before giving up.
		; This is necessary because sometimes the script will try and join a registered channel
		; before nickserv has a chance to acknowledge identification.  Again, this method is
		; not very elegant because the passwords are hardcoded; however, it proves the point.
		if (${RegisteredChannelRetryAttempts} <= 5)
		{
			echo IRC:: [${User}] Identifying with Nickserv now.
	  	
		  	if (${UserName.Equal[test1]})
		  	{
				IRCUser[${IRCNick}]:PM[Nickserv,"identify ${IRCNickPassword}"]
		  	}	
	  		IRCUser[${User}]:Join[${Channel}]
	  		RegisteredChannelRetryAttempts:Inc
			return
		}
	}
}

atom(script) IRC_AddChannelBan(string User, string Channel, string WhoSet, string Ban)
{
	; This event is fired whenever an IRCUser that you have connected receives a
	; message that a ban has been added to the channel.   ISXIM handles updating
	; the banlist for each channel, so this event is just here for notifying the 
	; user
	  
}

atom(script) IRC_RemoveChannelBan(string User, string Channel, string WhoSet, string Ban)
{
	; This event is fired whenever an IRCUser that you have connected receives a
	; message that a ban has been removed from a channel.   ISXIM handles updating
	; the banlist for each channel, so this event is just here for notifying the 
	; user
	  
}	

atom(script) IRC_UnhandledEvent(string User, string Command, string Param, string Rest)
{
	; This event is here to handle any events that are not handled otherwise by the
	; the extension.  There will probably be a lot of spam here, so you won't want to
	; echo everything.  The best thing to do is only use this event when there is something
	; that is happening with the client that you want added as a feature to ISXIM and need
	; the data to tell Amadeus.
	  
}
	
atom(script) IRC_NickTypeChange(string User, string Channel, string NickName, string NickType, string Toggle, string WhoSet)
{
	; This event is fired whenever an IRCUser that you have connected receives an
	; message that a nick has had their 'type' changed on a channel (ie, being set
	; as an OP)
	  
	; Possible ${NickType} include: "OWNER", "SOP", "OP", "HOP", "Voice", "Normal"
	; Possible ${Toggle} include: "TRUE, "FALSE"
	     	   	  
}
 
atom(script) IRC_ChannelModeChange(string User, string Channel, string ModeType, string Toggle, string WhoSet, string Extra)
{
	; This event is fired whenever an IRCUser that you have connected receives an
	; message that a channel has had its 'mode' changed.
	; NOTE:  This event will fire for every user that's in a channel!  So, if you
	;        have more than one user in a channel, you'll get duplicate messages :)
	
	; Possible ${ModeType} include: "PASSWORD", "LIMIT", "SECRET", "PRIVATE", "INVITEONLY",
	;                               "MODERATED", "NOEXTERNALMSGS", "ONLYOPSCHANGETOPIC", "REGISTERED",
	;                               "REGISTRATIONREQ", "NOCOLORSALLOWED"
	
	; Possible ${Toggle} include: "TRUE, "FALSE"
	
	; Possible ${Extra} include:  The "password" for the PASSWORD ${ModeType} and the "limit"
	;                             for the LIMIT ${ModeType}
	
}