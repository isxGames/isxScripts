




;===================================================
;===         Catch target death                 ====
;===================================================
atom(script) PawnStatusChange(string ChangeType, int64 PawnID, string PawnName)
{
	variable filepath EventFilePath = "${Script.CurrentDirectory}/Saves"
	mkdir "${EventFilePath}"
	redirect -append "${EventFilePath}/Event-PawnStatusChange.txt" echo "[${Time}][PawnStatusChange] [ID=${PawnID}][${ChangeType}][Name=${PawnName}]"

	if ${PawnID}==${LastTargetID} && ${ChangeType.Equal[NowDead]}
	{
		TotalKills:Inc
		EchoIt "[AlertEvent] Invalid Target - Blacklisting ${Me.Target.Name}"
		EchoIt "Total Kills = ${TotalKills}"
		vgecho "Total Kills = ${TotalKills}"
	}
}

;===================================================
;===         Monitor Status Alerts              ====
;===================================================
atom(script) AlertEvent(string Text, int ChannelNumber)
{
	variable filepath EventFilePath = "${Script.CurrentDirectory}/Saves"
	mkdir "${EventFilePath}"
	redirect -append "${EventFilePath}/Event-Alert.txt" echo "[${Time}][AlertEvent] ${Text}"

	if ${ChannelNumber}==2
	{
		if ${Text.Find[You died.]}
		{
			EchoIt "[AlertEvent] ----  You died ----"
			for (i:Set[0]; ${i:Inc}<=${VG.PawnCount}; i:Inc)
			{
				if ${Pawn[${i}].Distance}<30
				{
					EchoIt "[${i}][Distance=${Pawn[${i}].Distance}][${Pawn[${i}].Type}] ${Pawn[${i}].Name}"
				}
			}
		}
	}
	

	if ${ChannelNumber}==42
	{
		if ${Text.Find[Returning you to the nearest outpost...]}
		{
			EchoIt "[AlertEvent] Teleported to Altar"
			doCamp:Set[TRUE]
		}
	}
	
	if ${ChannelNumber}==22
	{
		if ${Text.Find[Invalid target]}
		{
			EchoIt "[AlertEvent] Invalid Target - Blacklisting ${Me.Target.Name}"
			BlackListTarget:Set[${Me.Target.ID},${Me.Target.ID}]
			VGExecute "/cleartargets"
		}
	}
}



;===================================================
;===             Monitor Chat                   ====
;===================================================
atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	variable filepath EventFilePath = "${Script.CurrentDirectory}/Saves"
	mkdir "${EventFilePath}"
	redirect -append "${EventFilePath}/Event-Chat.txt" echo "[${Time}][ChatEvent] ${Text}"


	if ${ChannelNumber}==0
	{
		if ${Text.Find[Server is shutting down]}
		{
			EchoIt "[ChatEvent] SERVER SHUTDOWN"
			doCamp:Set[TRUE]
		}
	}
	
	if ${ChannelNumber}==39
	{
		if ${Text.Find[servers will be coming down]}
		{
			EchoIt "[ChatEvent] SERVER SHUTDOWN"
			doCamp:Set[TRUE]
		}
	}

	if ${ChannelNumber}==42
	{
		if ${Text.Find[Returning you to the nearest outpost...]}
		{
			EchoIt "[ChatEvent] Teleported to Altar"
			doCamp:Set[TRUE]
		}
	}

	if ${ChannelNumber}==0 || ${ChannelNumber}==1
	{
		if ${Text.Find["You are not wielding the proper weapon type to use that ability"]}
		{
			EchoIt "[ChatEvent] Unable to use Ra'Jin Flare - No Shurikens in inventory"
			doRangedWeapon:Set[FALSE]
		}

		if ${Text.Find["no line of sight to your target"]} || ${Text.Find[You can't see your target]}
		{
			if ${doHunt}
			{
				EchoIt "[ChatEvent] Face issue chatevent fired, facing target"
				face ${Math.Calc[${Pawn[id,${Me.Target.ID}].HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
				NoLineOfSight:Set[TRUE]
			}
		}
	}
}


;===================================================
;===          Monitor Combat                    ====
;===================================================
atom(script) CombatEvent(string Text, string ChannelNumber, string ChannelName)
{
	variable filepath EventFilePath = "${Script.CurrentDirectory}/Saves"
	mkdir "${EventFilePath}"
	redirect -append "${DebugFilePath}/Event-Combat.txt" echo "[${Time}][CombatEvent] ${Text}"

	if ${ChannelNumber}==42
	{
		if ${Text.Find[Returning you to the nearest outpost...]}
		{
			EchoIt "[CombatEvent] Teleported to Altar"
			doCamp:Set[TRUE]
		}
	}

	if ${ChannelNumber}==0 || ${ChannelNumber}==1
	{
		if ${Text.Find["You are not wielding the proper weapon type to use that ability"]}
		{
			EchoIt "[CombatEvent] Unable to use Ra'Jin Flare - No Shurikens in inventory"
			doRangedWeapon:Set[FALSE]
		}

		if ${Text.Find["no line of sight to your target"]} || ${Text.Find[You can't see your target]}
		{
			if ${doHunt}
			{
				EchoIt "[CombatEvent] Face issue chatevent fired, facing target"
				face ${Math.Calc[${Pawn[id,${Me.Target.ID}].HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
				NoLineOfSight:Set[TRUE]
			}
		}
	}
}

