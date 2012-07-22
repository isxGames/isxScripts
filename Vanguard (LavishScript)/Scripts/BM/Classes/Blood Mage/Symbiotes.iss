/*
	Symbiotes v1.0 - Pass out symbiotes based upon received tells
	
Note to self: We really need to fix this so that the same person can't request twice

*/

;; This is updated by the event handle
variable bool SymbioteRequest = FALSE
variable string PCName
variable string PCNameFull
variable string Symbiote
;variable bool doSymbiotes = TRUE

;-------------------------------------------
; Call this from your script to handle any symbiote requests
;-------------------------------------------
function SymbioteRequest()
{
	;; Return if we are not processing Symbiote Requests
	if !${doSymbiotes}
		return

	;; Set temp variables
	variable int i = ${Math.Rand[5]}
	variable string PCName2
	variable string Symbiote2

	;; loop this for as long as there is a request
	while ${SymbioteRequest}
	{
		;; Backup our information 
		PCName2:Set[${PCName}]
		Symbiote2:Set[${Symbiote}]

		;; Symbiote request is now set to off 
		SymbioteRequest:Set[FALSE]

		;; Make sure we have the ability
		if !${Me.Ability[${Symbiote2}](exists)}
			return
		
		;; Check if within distance
		if ${Pawn[${PCName2}].Distance}<25
		{
			;; Target the requestor
			Pawn[${PCName2}]:Target
			wait 5
			waitframe
			
			;; Make sure our DTarget is requestor
			if ${Me.DTarget.Name.Find[${PCName2}]}
			{
				;; Wait to ensure ready to cast symbiote
				while !${Me.Ability[${Symbiote2}].IsReady} || !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting} || ${VG.InGlobalRecovery}>0 || ${GV[bool,bHarvesting]}
				{
					waitframe
				}

				;; Cast the Symbiote
				Me.Ability[${Symbiote2}]:Use
				wait 30

				;; Wait to ensure ready to cast symbiote
				while !${Me.Ability[${Symbiote2}].IsReady} || !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting} || ${VG.InGlobalRecovery}>0 || ${GV[bool,bHarvesting]}
				{
					waitframe
				}
				if ${i}<=1
					TimedCommand 25 VGExecute "/tell ${PCName2} There ya go :)"
				if ${i}==2
					TimedCommand 25 VGExecute "/tell ${PCName2} There ya go... :D"
				if ${i}==3
					TimedCommand 25 VGExecute "/tell ${PCName2} Did ya get it?"
				if ${i}==4
					TimedCommand 25 VGExecute "/tell ${PCName2} Done :)"
				if ${i}>=5
					TimedCommand 25 VGExecute "/tell ${PCName2} :)"
			
				if ${doEcho}
					echo "[${Time}][VG:BM] --> Symbiotes: Successfully casted ${Symbiote2} on ${PCName2}"
			}
		}
	}
}


/*
;-------------------------------------------
; ChatEvent - Used to monitor messages
;-------------------------------------------
atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	;; Tells, group, guild only
	if ${ChannelNumber}==15 || ${ChannelNumber}==8 || ${ChannelNumber}==11
	{
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

		if (${Text.Find["vitalizing"]} || ${Text.Find["vitalize"]})
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Vitalizing Symbiote]
		}

		if (${Text.Find["conduct"]} || ${Text.Find["conducive"]})
		{
			SymbioteRequest:Set[TRUE]
			PCNameFull:Set[${Text.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[Conducive Symbiote]
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
*/
