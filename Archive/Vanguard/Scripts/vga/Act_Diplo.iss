function AssistDiplo()
{
	if ${Me.Target(exists)} && ${Me.Target.Distance} < 10 && !${Me.Target.Type.Equal[AggroNPC]} && !${VG.IsInParlay}
	{
		call CheckPosition
		variable iterator Iterator
		Diplo:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			if ${LavishSettings[VGA_Diplo].FindSet[Diplo].FindSetting[${Iterator.Key}].FindAttribute[NPC].String.Equal[${Me.Target}]}
			{
				echo ${LavishSettings[VGA_Diplo].FindSet[Diplo].FindSetting[${Iterator.Key}].FindAttribute[NPC].String.Equal[${Me.Target}]} ${Iterator.Key} ${Me.Target}
				if ${Dialog[General].ResponseCount}==0
				{
					VGExecute /Hail
					wait 5

				}
				variable int CivicINT
				CivicINT:Set[1]
				do
				{
					if ${Dialog[General,${CivicINT}].Text.Find[${Iterator.Value}](exists)}
					{
						call PresenceNeeded
						echo Equipping Gear: ${Return}
						obj_diplogear:Load[${Return}]
						Dialog[General,${CivicINT}]:Select
						wait 5
						OurTurn:Set[TRUE]
						While ${VG.IsInParlay}
						{
							if ${OurTurn}
							{
								call DoParleyCard
							}
							if (!${Parlay.DialogPoints})
							{
								Parlay:Continue
								Loot:LootAll
								OurTurn:Set[TRUE]
								wait 2400
							}
						}
						wait 3
						MouseTo 772,653
						wait 5
						MouseClick -hold left
						wait 2
						MouseClick -release left
					}
					CivicINT:Inc
				}
				while ${Dialog[General, ${CivicINT}](exists)}
			}

			Iterator:Next


		}
	}
}
function RemoveLowLevelDiplo()
{
	variable int i
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		if ${Me.Inventory[${i}].Type.Equal[Miscellaneous]}
		{
			if ${Me.Inventory[${i}].Name.Find[Plots]} > 0 || ${Me.Inventory[${i}].Name.Find[Blackmail]} > 0 || ${Me.Inventory[${i}].Name.Find[Arcana]} > 0 || ${Me.Inventory[${i}].Name.Find[Trends]} > 0
			{
				if ${Me.Inventory[${i}].Description.Find[Crude]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[Significant]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[This significant]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[Some significant]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[Essential]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[This essential]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[Vital]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
				if ${Me.Inventory[${i}].Description.Find[This Vital]} == 1
				{
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
				}
			}
		}
	}
}

function DoParleyCard()
{
	if (!${Parlay.DialogPoints})
	{
		Parlay:Continue
		Loot:LootAll
	}
	variable int card = 1
	variable int ratemax = 0
	variable int rate
	variable int cardplay = 0

	while ${card} <= ${Strategy}
	{
		call IsPlayable ${card}
		;call IsPlayable $Strategy[${card}]
		if ${Return}
		{
			call RateCard ${card}
			rate:Set[${Return}]

			;echo "Card ${card} rate is:  ${rate}"
			if ${rate} > ${ratemax}
			{
				cardplay:Set[${card}]
				ratemax:Set[${rate}]
			}
		}
		card:Inc
	}

	if ${cardplay} > 0
	{
		;echo "Play:  ${Strategy[${cardplay}].Name}"
		Strategy[${cardplay}]:Play
		OurTurn:Set[FALSE]
	}
	else
	{
		;echo "Listen"
		Parlay:Listen
		OurTurn:Set[FALSE]
	}
}

function:int RateCard(int card)
{
	variable int infscale = 10
	variable int gainscale = 6
	variable int givescalered = 4
	variable int givescalegreen = 4
	variable int givescaleblue = 4
	variable int givescaleyellow = 4
	variable int rate
	variable int infl = ${Strategy[${card}].InfluenceMax}
	variable int dp = ${Strategy[${card}].DemandGained}
	variable int dm = ${Strategy[${card}].DemandGiven}
	variable int rp = ${Strategy[${card}].ReasonGained}
	variable int rm = ${Strategy[${card}].ReasonGiven}
	variable int ip = ${Strategy[${card}].InspireGained}
	variable int im = ${Strategy[${card}].InspireGiven}
	variable int fp = ${Strategy[${card}].FlatterGained}
	variable int fm = ${Strategy[${card}].FlatterGiven}
	variable int inflmax = ${Math.Calc[10 - ${Parlay.Status}]}

	;  ###############check for what we dont want to give
	if ${dipNPCs[${curNPC}].red}
	{
		givescalered:Set[18]
	}
	if ${dipNPCs[${curNPC}].green}
	{
		givescalegreen:Set[18]
	}
	if ${dipNPCs[${curNPC}].blue}
	{
		givescaleblue:Set[18]
	}
	if ${dipNPCs[${curNPC}].yellow}
	{
		givescaleyellow:Set[18]
	}
	; ############### If winning by 5 or greater worry more about whats given.
	if ${inflmax} < 6
	{
		givescalered:Set[${Math.Calc[${givescalered}*2]}]
		givescaleblue:Set[${Math.Calc[${givescaleblue}*2]}]
		givescalegreen:Set[${Math.Calc[${givescalegreen}*2]}]
		givescaleyellow:Set[${Math.Calc[${givescaleyellow}*2]}]
		gainscale:Set[${Math.Calc[${gainscale}*2]}]
		;echo infmax ${inflmax}
	}
	if ${infl} > ${inflmax}
	{
		infl:Set[${inflmax}]

	}
	;echo bleh!
	;echo ${dipNPCs[${curNPC}].red} ${dipNPCs[${curNPC}].green} ${dipNPCs[${curNPC}].blue} ${dipNPCs[${curNPC}].yellow}
	;echo ${iter}
	; ##########################If using a rebutal, calculate how much it really takes away.
	if ${dm} < 0 && ${Math.Calc[${dm} + ${Parlay.OpponentDemand}/10]} < 0
	{
		dm:Set[${Math.Calc[ 0 - ${Parlay.OpponentDemand}/10]}]
		;echo dm is ${dm}
	}
	if ${rm} < 0 && ${Math.Calc[${rm} + ${Parlay.OpponentReason}/10]} < 0
	{
		rm:Set[${Math.Calc[ 0 - ${Parlay.OpponentReason}/10]}]
		;echo rm is ${rm}
	}
	if ${im} < 0 && ${Math.Calc[${im} + ${Parlay.OpponentInspire}/10]} < 0
	{
		im:Set[${Math.Calc[ 0 - ${Parlay.OpponentInspire}/10]}]
		;echo im is ${im}
	}
	if ${fm} < 0 && ${Math.Calc[${fm} + ${Parlay.OpponentFlatter}/10]} < 0
	{
		fm:Set[${Math.Calc[ 0 - ${Parlay.OpponentFlatter}/10]}]
		;echo fm is ${fm}
	}
	;Check if flooding mana

	if ${Parlay.Demand}>40
	{
		dp:Set[${Math.Calc[${dp}\3]}]
		;echo Halfing Demand ${dp}
	}
	if ${Parlay.Reason}>40
	{
		rp:Set[${Math.Calc[${rp}\3]}]
		;echo Halfing Reason ${rp}
	}
	if ${Parlay.Inspire}>40
	{
		ip:Set[${Math.Calc[${ip}\3]}]
		;echo Halfing Inspiration ${ip}
	}
	if ${Parlay.Flatter}>40
	{
		fp:Set[${Math.Calc[${fp}\3]}]
		;echo halfing Flatter ${fp}
	}
	;If given negative things which you dont have sets to zero
	if ${dp} < 0 && ${Math.Calc[${dp} + ${Parlay.Demand}/10]} < 0
	{
		dp:Set[${Math.Calc[ 0 - ${Parlay.Demand}/10]}]

	}
	if ${rp} < 0 && ${Math.Calc[${rp} + ${Parlay.Reason}/10]} < 0
	{
		rp:Set[${Math.Calc[ 0 - ${Parlay.Reason}/10]}]

	}
	if ${ip} < 0 && ${Math.Calc[${ip} + ${Parlay.Inspire}/10]} < 0
	{
		ip:Set[${Math.Calc[ 0 - ${Parlay.Inspire}/10]}]

	}
	if ${fp} < 0 && ${Math.Calc[${fp} + ${Parlay.Flatter}/10]} < 0
	{
		fp:Set[${Math.Calc[ 0 - ${Parlay.Flatter}/10]}]

	}
	rate:Set[${Math.Calc[${infl} * ${infscale}]}]
	if !${Parlay.DemandDisabled}
	{
		rate:Set[${Math.Calc[${rate}+${dp}*${gainscale}-${dm}*${givescalered}]}]
	}
	if !${Parlay.ReasonDisabled}
	{
		rate:Set[${Math.Calc[${rate}+${rp}*${gainscale}-${rm}*${givescalegreen}]}]
	}
	if !${Parlay.InspireDisabled}
	{
		rate:Set[${Math.Calc[${rate}+${ip}*${gainscale}-${im}*${givescaleblue}]}]
	}
	if !${Parlay.FlatterDisabled}
	{
		rate:Set[${Math.Calc[${rate}+${fp}*${gainscale}-${fm}*${givescaleyellow}]}]
	}

	return "${rate}"
}
function:bool IsPlayable(int card)
{
	variable int reason = ${Math.Calc[${Parlay.Reason}/10]}
	variable int inspire = ${Math.Calc[${Parlay.Inspire}/10]}
	variable int flatter = ${Math.Calc[${Parlay.Flatter}/10]}
	variable int demand = ${Math.Calc[${Parlay.Demand}/10]}

	;echo "Card cost:  ${Strategy[${card}].DemandCost} ${Strategy[${card}].ReasonCost} ${Strategy[${card}].InspireCost} ${Strategy[${card}].FlatterCost}"
	;echo "         :  ${demand} ${reason} ${inspire} ${flatter}"

	if ${Strategy[${card}].RoundsToRefresh} > 0
	{
		return "FALSE"
	}

	if ${Strategy[${card}].ReasonCost} <= ${reason} && ${Strategy[${card}].InspireCost} <= ${inspire} && ${Strategy[${card}].FlatterCost} <= ${flatter} && ${Strategy[${card}].DemandCost} <= ${demand}
	{
		return "TRUE"
	}
	return "FALSE"
}
atom(global) OnParlayOppTurnEnd()
{
	OurTurn:Set[TRUE]
}

