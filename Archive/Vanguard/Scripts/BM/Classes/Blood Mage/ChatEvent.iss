/* CHAT EVENT MONITOR 

Description:  This is a MUST for every class 
because it is called from the main routine.  This is
where you want to monitor and act on key words
*/  

/* MUST HAVE - CHATEVENT USED TO MONITOR MESSAGES*/
atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	;; Snap to face target 
	if (${Text.Find["no line of sight to your target"]})
	{
		if ${doFace} && ${Me.Target(exists)}
		{
			face ${Math.Calc[${Me.Target.HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
		}
	}

	;; Clear target if lacking harvesting skill
	if (${Text.Find["You do not have enough skill to begin harvesting this resource"]})
	{
		if ${Me.Target(exists)}
			VGExecute /cleartargets
	}

	;; Check if target is no longer FURIOUS
	if ${Text.Find[is no longer FURIOUS]} && ${ChannelNumber}==7
	{
		if ${Me.Target(exists)} && ${Text.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			echo "Delay=${DELAY}, Health=${Me.TargetHealth}, FURIOUS = START ATTACKS"
			FURIOUS:Set[FALSE]
		}
	}

	; Check if target went into FURIOUS - Has delays for notification
	if ${Text.Find[becomes FURIOUS]} && ${ChannelNumber}==7
	{
		if ${Me.Target(exists)} && ${Text.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			;; Turn on FURIOUS flag and stop attack
			FURIOUS:Set[TRUE]

			;; Turn off attacks!
			if ${GV[bool,bIsAutoAttacking]}
				Me.Ability[Auto Attack]:Use

			;; Randomize our DELAY
			variable int DELAY
			DELAY:Set[${Math.Rand[25]}]

			echo "Delay=${DELAY}, Health=${Me.TargetHealth}, FURIOUS = STOP ATTACKS"

			;; Announce FURIOUS is up
			if ${DELAY}>4 && ${Me.TargetHealth}<20 && ${Me.InCombat} && ${EchoFurious}
				TimedCommand ${DELAY} VGExecute "/group <Red=>FURIOUS<Yellow=> -- STOP ATTACKS!"
		}
	}
	
	;; Ping us on tells or anything with our name in it
	if ${Text.Find[From ]} && ${ChannelNumber}==15
	{
		call PlaySound ALARM
	}

	;; Ping us on tells or anything with our name in it
	if ${Text.Find[You have received a ready check]}
	{
		echo "[${Time}][BM] --> ChatEvent:  Received a Ready Check."
		call PlaySound WARNING
	}

	
	/*======== Everything below this line is stuff I use for my Blood Mage ========*/

	;; Check for any Symbiote Requests
	if ${ChannelNumber}==8 || ${ChannelNumber}==11 || ${ChannelNumber}==15
	{
		if ${Text.Find["conduct"]} || ${Text.Find["conducive"]}
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Conducive Symbiote]
		}

		if ${Text.Find["frenzy"]} || ${Text.Find["frenzied"]} || ${Text.Find["frenize"]}
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Frenzied Symbiote V]
		}

		if (${Text.Find["QJ"]})
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Quickening Symbiote]
		}

		if (${Text.Find["vitalizing"]})
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Vitalizing Symbiote]
		}
		
		if (${Text.Find["plated"]})
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Plated Symbiote IV]
		}

		if (${Text.Find["renew"]})
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Renewing Symbiote III]
		}

	}
}
/* MUST HAVE - CHATEVENT USED TO MONITOR MESSAGES*/
atom(script) IncomingCombatTextEvent(string Text)
{
	;; FROZEN
	if (${Text.Find["Ice Compression"]} && ${Text.Find["hits you"]})
	{
		echo "Ice Compression hit me!"
		VGExecute "/raid <Red=>I AM FROZEN - G1"  
		call PlaySound WARNING
	}

	;; STONED
	if (${Text.Find["Stone Encasement"]} && ${Text.Find["hits you"]})
	{
		echo "I got STONED!"
		VGExecute "/raid <Red=>I AM STONED - G1"  
		call PlaySound WARNING
	}
	/*======== Everything below this line is stuff I use for my Blood Mage ========*/
}