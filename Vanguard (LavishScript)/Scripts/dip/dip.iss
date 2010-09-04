/*  An automated diplomacy script.

By: Eris

Credits:
Lax, for the fine product we call innerspace.
Amadeus, for another fine product, ISXVG.
Xeon, for the movement code stolen from vgcraftbot.
Gavkra, for the inspiration, the initial RateCard, DoParleyCard, and IsPlayable functions.
Chayce, for the rewrite of the RateCard function.
mmoaddict, continuation of project 4_22_2010
Zandros, updated to work with targets with same name and cleaned up some coding... 26 July 2010
*/

#include "${Script.CurrentDirectory}/Includes/dip-bnavobjects.iss
#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_DiploGear.iss"

objectdef npclist
{
	method Initialize()
	{
		Name:Set["Empty"]
		NameID:Set["Empty"]
		ID:Set[0]
		X:Set[0]
		Y:Set[0]
		Z:Set[0]
		red:Set[FALSE]
		green:Set[FALSE]
		blue:Set[FALSE]
		yellow:Set[FALSE]
		TotalWins:Set[0]
		TotalLosses:Set[0]
		InciteWins:Set[0]
		InciteLosses:Set[0]
		InterviewWins:Set[0]
		InterviewLosses:Set[0]
		ConvinceWins:Set[0]
		ConvinceLosses:Set[0]
		GossipWins:Set[0]
		GossipLosses:Set[0]
		EntertainWins:Set[0]
	}

	method Clear()
	{
		Name:Set["Empty"]
		NameID:Set["Empty"]
		ID:Set[0]
		X:Set[0]
		Y:Set[0]
		Z:Set[0]
		red:Set[FALSE]
		green:Set[FALSE]
		blue:Set[FALSE]
		yellow:Set[FALSE]
		TotalWins:Set[0]
		TotalLosses:Set[0]
		InciteWins:Set[0]
		InciteLosses:Set[0]
		InterviewWins:Set[0]
		InterviewLosses:Set[0]
		ConvinceWins:Set[0]
		ConvinceLosses:Set[0]
		GossipWins:Set[0]
		GossipLosses:Set[0]
		EntertainWins:Set[0]
	}

	variable string Name
	variable string NameID
	variable int64 ID
	variable float X
	variable float Y
	variable float Z
	variable bool red
	variable bool green
	variable bool blue
	variable bool yellow
	variable int TotalWins
	variable int TotalLosses
	variable int InciteWins
	variable int InciteLosses
	variable int InterviewWins
	variable int InterviewLosses
	variable int ConvinceWins
	variable int ConvinceLosses
	variable int GossipWins
	variable int GossipLosses
	variable int EntertainWins
	variable int EntertainLosses
}

variable settingsetref setDipNPC
variable settingsetref setDipTypes
variable settingsetref setDipGeneral
variable iterator itDipNPC
variable iterator itDipTypes
variable iterator itDipGen
variable bnav dipnav
variable(script) bool starting = FALSE
variable(script) bool needNewNPC = FALSE
variable(global) index:string convTypes
variable(script) bool parleyDone = FALSE
variable(global) bool dipisMapping = FALSE
variable(global) bool dipisPaused = TRUE
variable(script) bool isMoving = FALSE
variable(script) int curNPC = 0
variable(global) string CurrentRegion
variable(global) string LastRegion
variable int bpathindex
variable lnavpath mypath
variable astarpathfinder PathFinder
variable lnavconnection CurrentConnection
variable int movePrecision = 100
variable int objPrecision = 3
variable int maxWorkDist = 3
variable(script) int wins
variable(script) int losses
variable(script) int Incitewins
variable(script) int Incitelosses
variable(script) int Interviewwins
variable(script) int Interviewlosses
variable(script) int Convincewins
variable(script) int Convincelosses
variable(script) int Gossipwins
variable(script) int Gossiplosses
variable(script) int Entertainwins
variable(script) int Entertainlosses
variable(script) bool endScript = FALSE
variable(script) bool fullAuto = TRUE
variable(script) bool boolFace = TRUE
variable(script) int brokeCount = 0
variable(script) int maxWait
variable(script) int minWait
variable(script) bool ourTurn = FALSE
variable(script) bool cardDelay
variable(script) npclist dipNPCs[20]
variable(script) string currentParleyType
variable(script) int presDomestic = 0
variable(script) int presSoldier = 0
variable(script) int presCrafter = 0
variable(script) int presClergy = 0
variable(script) int presAcademic = 0
variable(script) int presMerchant = 0
variable(script) int presNoble = 0
variable(script) int presOutsider = 0

;Paths
variable filepath scriptPath = "${Script.CurrentDirectory}/"
variable filepath savePath = "${Script.CurrentDirectory}/Save/"
variable filepath VGPathsDir = "${Script.CurrentDirectory}/Paths/"
variable string UIFile = "${Script.CurrentDirectory}/dip.xml"
variable string UISkin = "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
variable string Output = "${Script.CurrentDirectory}/Save/Debug.txt"

;Debug setup
variable(script) bool debug = TRUE

function main()
{
	;; Announce we started
	Echo "[${Time}] Diplomacy Started..."

	;; Create directories
	mkdir "${savePath}"
	mkdir "${VGPathsDir}"

	;; Delete our log file
	if ${savePath.FileExists[Debug.txt]}
	{
		;; delete our output file
		rm "${Output}"
	}

	if ( !${ISXVG.IsReady(exists)} )
	{
		ext isxvg
	}
	if ( !${ISXVG.IsReady} )
	{
		echo "VGC: ISXVG Not loaded or updating... Waiting..."

		while !${ISXVG.IsReady}
		wait 10

		echo "VGC: ISXVG done updating... will now continue"
	}

	;;Load Lavish Settings
	LavishSettings[diplo]:Clear
	LavishSettings:AddSet[diplo]
	LavishSettings[diplo]:AddSet[NPCs-${Me.FName}]
	LavishSettings[diplo]:AddSet[ConvTypes-${Me.FName}]
	LavishSettings[diplo]:AddSet[General-${Me.FName}]
	
	if ${Script.CurrentDirectory.FileExists[Dip-Settings.xml]}
	{
		LavishSettings[diplo]:Import[${Script.CurrentDirectory}/Dip-Settings.xml]
		rm "${Script.CurrentDirectory}/Dip-Settings.xml"
	}
	else
	{
		LavishSettings[diplo]:Import[${savePath}Dip-Settings.xml]
	}

	setDipNPC:Set[${LavishSettings[diplo].FindSet[NPCs-${Me.FName}].GUID}]
	setDipTypes:Set[${LavishSettings[diplo].FindSet[ConvTypes-${Me.FName}].GUID}]
	setDipGeneral:Set[${LavishSettings[diplo].FindSet[General-${Me.FName}].GUID}]

	;; Start our event monitors
	Event[VG_OnParlayOppTurnEnd]:AttachAtom[OnParlayOppTurnEnd]
	Event[VG_OnParlayBegin]:AttachAtom[OnParlayBegin]
	Event[VG_OnParlaySuccess]:AttachAtom[OnParlaySuccess]
	Event[VG_OnParlayLost]:AttachAtom[OnParlayLost]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]

	call LoadSettings
	call dipnav.Initialize

	CurrentRegion:Set[${LNavRegion[${dipnav.CurrentRegionID}].Name}]
	LastRegion:Set[${LNavRegion[${dipnav.CurrentRegionID}].Name}]

	ui -reload "${UISkin}"
	ui -reload -skin VGSkin "${UIFile}"
	call setupUI
	if ${debug}
	Redirect -append "${Output}" echo "${Time}: Script starting..."
	;Begin the never ending loop....
	while 1
	{
		;waitframe
	
		if !${isMoving}
		{
			wait 5
		}
		else
		{
			waitframe
		}
		if (${endScript})
		{
			break
		}
		if (${dipisMapping})
		{
			dipnav:AutoBox
			dipnav:ConnectOnMove
		}
		if (!${dipisPaused})
		{
			if (${fullAuto})
			{
				if (${isMoving})
				{
					if ${VG.IsInParlay}
					{
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: Movement called while in Parley"
						}
						if (!${Parlay.DialogPoints})
						{
							if ${debug}
							{
								Redirect -append "${Output}" echo "${Time}: Movement called while in Parley, but Parley is actually over.
							}
							Parlay:Continue
							if ${Loot}
							Loot:LootAll
						}
						else
						{
							if ${debug}
							{
								Redirect -append "${Output}" echo "${Time}: Parley is not over. Target: ${Me.Target.Name} Parley: ${Parlay.DialogPoints} VG.IsInParlay: ${VG.IsInParlay} IsMoving: ${isMoving}"
							}
							echo Something bad has happened: Target: ${Me.Target.Name} Parley: ${Parlay.DialogPoints} VG.IsInParlay: ${VG.IsInParlay} IsMoving: ${isMoving}
						}
					}
					else
					{
						variable string returnvalue = "GOOD"
						
						;; Move to last known XYZ location if we can't find via pawn
						if !${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)} && ${Math.Distance[${Me.X},${Me.Y},${dipNPCs[${curNPC}].X},${dipNPCs[${curNPC}].Y}]}>500
						{
							;vgecho [${curNPC}]  ${dipNPCs[${curNPC}].Name}
							if ${debug}
							{
								Redirect -append "${Output}" echo "${Time}: Starting movement routine via last known XYZ location with distance of ${Math.Distance[${Me.X},${Me.Y},${dipNPCs[${curNPC}].X},${dipNPCs[${curNPC}].Y}]}"
							}
							call dipnav.MovetoXYZ ${dipNPCs[${curNPC}].X} ${dipNPCs[${curNPC}].Y} ${dipNPCs[${curNPC}].Z}
							returnvalue:Set[${Return}]
						}
						
						;; Move to pawns current location
						if ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance} > 5
						{
							;vgecho [${curNPC}]* ${dipNPCs[${curNPC}].Name}
							if ${debug}
							{
								Redirect -append "${Output}" echo "${Time}: Starting movement routine of current pawn location with a distance of ${Me.Target.Distance}"
							}
							call dipnav.MovetoTargetID "${dipNPCs[${curNPC}].ID}" TRUE
							returnvalue:Set[${Return}]
						}
						
						;; We reached our destination
						if (${returnvalue.Equal[END]})
						{
							isMoving:Set[FALSE]
							if (${boolFace})
							{
								if (${Me.Heading} + 70 > ${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo} || ${Me.Heading} - 70 < ${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo})
								{
								}
								else
								{
									face ${Math.Calc[${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo}+${Math.Rand[10]}-${Math.Rand[14]}]}
								}
							}
						}
						elseif (${returnvalue.Equal[NO MAP]})
						{
							if ${debug}
							{
								Redirect -append "${Output}" echo "${Time}: Not on mapped area, moving back to map"
							}
							call dipnav.MoveToMappedArea
							VG:ExecBinding[moveforward, release]
						}
						else
						{
							if ${debug}
							{
								Redirect -append "${Output}" echo "${Time}: Movement succeeded"
							}
							isMoving:Set[FALSE]
						}
						
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: New Target is ${dipNPCs[${curNPC}].NameID}"
						}
						;; Target NPC when we are within range
						if ${Math.Distance[${Me.X},${Me.Y},${dipNPCs[${curNPC}].X},${dipNPCs[${curNPC}].Y}]}<=800
						{
							Pawn[id,${dipNPCs[${curNPC}].ID}]:Target
							wait 5
						}
					}
				}
				else
				{
					if (${parleyDone})
					{
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: A parley was successfuly completed."
						}
						wait 10
						if ${Loot}
						{
							Loot:LootAll
						}
						Parlay:Continue
						parleyDone:Toggle
					}
					if (!${VG.IsInParlay} && !${needNewNPC})
					{
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: Selecting parley from ${dipNPCs[${curNPC}].Name}"
						}
						call SelectParlay
					}
					if (${needNewNPC})
					{
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: Selecting a new NPC."
						}
						;wait 5
						if (${VG.IsInParlay})
						{
							needNewNPC:Set[FALSE]
						}
						else
						{
							while 1
							{
								curNPC:Inc
								if (${curNPC} >= 21)
								curNPC:Set[1]
								if (!${dipNPCs[${curNPC}].Name.Equal["Empty"]})
								{
									if ${debug}
									{
										Redirect -append "${Output}" echo "${Time}: NPC Selected: ${dipNPCs[${curNPC}].Name}"
									}
									break
								}
							}

							;; Clear our target, we are done with this NPC
							if ${Me.Target(exists)}
							{
								;; We are done so close the parlay window if one is open
								Parlay:Farewell
								VGExecute /cleartargets
								wait 20
							}

							isMoving:Set[TRUE]
							needNewNPC:Set[FALSE]
						}
					}
					if (${ourTurn})
					{
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: It is our turn, playing card..."
						}
						if (${cardDelay})
						{
							wait ${Math.Rand[${maxWait}-${minWait}]:Inc[${minWait}]}
							ourTurn:Set[FALSE]
							call DoParleyCard
						}
						else
						{
							call DoParleyCard
							ourTurn:Set[FALSE]
						}
					}
					if (${starting})
					{
						if ${debug}
						{
							Redirect -append "${Output}" echo "${Time}: The Parley has begun."
						}
						wait 5
						call DoParleyCard
						starting:Toggle
					}
				}
			}
			if (!${fullAuto})
			{
				if (${ourTurn})
				{
					if ${debug}
					{
						Redirect -append "${Output}" echo "${Time}: It is our turn, playing card..."
					}
					if (${cardDelay})
					{
						wait ${Math.Rand[${maxWait}-${minWait}]:Inc[${minWait}]}
						ourTurn:Set[FALSE]
						call DoParleyCard
					}
					else
					{
						call DoParleyCard
						ourTurn:Set[FALSE]
					}
				}
				if (${starting})
				{
					if ${debug}
					{
						Redirect -append "${Output}" echo "${Time}: The Parley has begun."
					}
					wait 5
					call DoParleyCard
					starting:Toggle
				}
				if (${parleyDone})
				{
					if ${debug}
					{
						Redirect -append "${Output}" echo "${Time}: A parley was successfully completed."
					}
					wait 10
					if ${Loot}
					{
						Loot:LootAll
					}
					Parlay:Continue
					parleyDone:Toggle
				}
			}
		}
	}
	call SaveSettings
	echo "[${Time}] Diplomacy Finished..."
}

function SelectParlay()
{
	Parlay:AssessTarget[${Target}]
	wait 5
	variable int selectedConv = 0
	variable int convOptions = 1
	variable int i = 1
	variable string genorciv
	while (${convOptions} <= ${Dialog[General].ResponseCount} && !${selectedConv})
	{
		i:Set[1]
		do
		{
			if ${Dialog[General,${convOptions}].Text.Find[>${convTypes[${i}]}]}
			{
				genorciv:Set[General]
				selectedConv:Set[${convOptions}]
				currentParleyType:Set[${convTypes[${i}]}]
				break
			}
			i:Inc
		}
		while (${convTypes[${i}](exists)})
		convOptions:Inc
	}
	if (!${selectedConv})
	{
		convOptions:Set[1]
		while (${convOptions} <= ${Dialog[Civic Diplomacy].ResponseCount} && !${selectedConv})
		{
			i:Set[1]
			do
			{
				if ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>${convTypes[${i}]}]}
				{
					genorciv:Set[Civic Diplomacy]
					selectedConv:Set[${convOptions}]
					currentParleyType:Set[${convTypes[${i}]}]
					break
				}
				i:Inc
			}
			while (${convTypes[${i}](exists)})
			convOptions:Inc
		}
	}
	if (${selectedConv})
	{
		if ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance} > 5
		{
			face ${Math.Calc[${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
			echo Moving the bad way
			if ${debug}
			{
				Redirect -append "${Output}" echo "${Time}: Backup movement code called."
			}
			VG:ExecBinding[moveforward]
			do
			{
				wait 2
				if ${endScript}
				{
					break
				}
			}
			while (${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance} > 5)
			VG:ExecBinding[moveforward, release]
		}
		else
		{
			echo Presence Needed : ${Dialog[Civic Diplomacy,1].PresenceRequiredType}
			call PresenceNeeded
			echo Equipping Gear: ${Return}
			wait 5
			obj_diplogear:Load[${Return}]
			wait 5
			Dialog[${genorciv},${selectedConv}]:Select

			if ${debug}
			{
				Redirect -append "${Output}" echo "${Time}: Selecting ${genorciv}: ${selectedConv} ${currentParleyType}"
			}
		}
	}
	else
	{
		if ${debug}
		{
			Redirect -append "${Output}" echo "${Time}: No Available parleys, setting 'needNewNPC'"
		}
		needNewNPC:Toggle
	}
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

function DoParleyCard()
{
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
	}
	else
	{
		;echo "Listen"
		Parlay:Listen
	}
}

function DebugOut(string Message)
{
	;echo ${Message}
}

function atexit()
{
	ui -unload "${UIFile}"
	ui -unload "${UISkin}"
}

function setupUI()
{
	UIElement[Diplo]:SetWidth[160]
	UIElement[Diplo]:SetHeight[80]
	UIElement[HUD@Diplo]:Select
	variable int i = 1
	do
	{
		UIElement[${convTypes[${i}]}@Options@DipTabs@Diplo]:SetChecked
		i:Inc
	}
	while ${convTypes[${i}](exists)}
	i:Set[1]
	do
	{
		if !${dipNPCs[${i}].Name.Equal[Empty]}
		{
			UIElement[NPCList@Options@DipTabs@Diplo]:AddItem["${dipNPCs[${i}].NameID}"]
		}
		i:Inc
	}
	while (${i} < 20)
	if ${boolFace}
	{
		UIElement[Face@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[Face@Options@DipTabs@Diplo]:UnsetChecked
	}
	if ${fullAuto}
	{
		UIElement[FullAuto@Options@DipTabs@Diplo]:Show
		UIElement[SemiAuto@Options@DipTabs@Diplo]:Hide
		UIElement[diplogearLoad@Options@DipTabs@Diplo]:Hide
	}
	else
	{
		UIElement[FullAuto@Options@DipTabs@Diplo]:Hide
		UIElement[SemiAuto@Options@DipTabs@Diplo]:Show
		UIElement[diplogearLoad@Options@DipTabs@Diplo]:Show
	}
	UIElement[MinDelay@Options@DipTabs@Diplo]:SetValue[${minWait}]
	UIElement[MaxDelay@Options@DipTabs@Diplo]:SetValue[${maxWait}]
	if ${cardDelay}
	{
		UIElement[MinDelayL@Options@DipTabs@Diplo]:Show
		UIElement[MaxDelayL@Options@DipTabs@Diplo]:Show
		UIElement[MinDelayV@Options@DipTabs@Diplo]:Show
		UIElement[MaxDelayV@Options@DipTabs@Diplo]:Show
		UIElement[MinDelay@Options@DipTabs@Diplo]:Show
		UIElement[MaxDelay@Options@DipTabs@Diplo]:Show
		UIElement[CardDelay@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[MinDelayV@Options@DipTabs@Diplo]:Hide
		UIElement[MaxDelayV@Options@DipTabs@Diplo]:Hide
		UIElement[MinDelayL@Options@DipTabs@Diplo]:Hide
		UIElement[MaxDelayL@Options@DipTabs@Diplo]:Hide
		UIElement[MinDelay@Options@DipTabs@Diplo]:Hide
		UIElement[MaxDelay@Options@DipTabs@Diplo]:Hide
		UIElement[CardDelay@Options@DipTabs@Diplo]:UnsetChecked
	}
	if ${debug}
	{
		UIElement[SpitVariables@Options@DipTabs@Diplo]:Show
	}
}

function SaveSettings()
{
	setDipNPC:Clear
	setDipTypes:Clear
	
	setDipNPC:AddSet[${Me.Chunk}]
	setDipNPC.FindSet[${Me.Chunk}]:AddSet[NPCs]
	
	variable int i = 1
	do
	{
		if (!${dipNPCs[${i}].NameID.Equal["Empty"]})
		{
			setDipNPC[${Me.Chunk}]:AddSetting[${i}, "${dipNPCs[${i}].NameID}"]
			setDipNPC[${Me.Chunk}]:AddSet[${dipNPCs[${i}].NameID}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Name, ${dipNPCs[${i}].Name}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[ID, ${dipNPCs[${i}].ID}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[X, ${dipNPCs[${i}].X}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Y, ${dipNPCs[${i}].Y}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Z, ${dipNPCs[${i}].Z}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[red, ${dipNPCs[${i}].red}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[green, ${dipNPCs[${i}].green}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[blue, ${dipNPCs[${i}].blue}]
			setDipNPC[${Me.Chunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[yellow, ${dipNPCs[${i}].yellow}]
		}
		i:Inc
	}
	while (${i} < 20)

	i:Set[1]
	do
	{
		if ${convTypes[${i}](exists)}
		{
			setDipTypes:AddSetting[${i}, "${convTypes[${i}]}"]
		}
		i:Inc
	}
	while (${convTypes[${i}](exists)})

	setDipGeneral:AddSetting[Face, ${boolFace}]
	setDipGeneral:AddSetting[fullAuto, ${fullAuto}]
	setDipGeneral:AddSetting[cardDelay, ${cardDelay}]
	setDipGeneral:AddSetting[minWait, ${minWait}]
	setDipGeneral:AddSetting[maxWait, ${maxWait}]
	LavishSettings[diplo]:Export[${savePath}Dip-Settings.xml]
}

function LoadSettings()
{
	dipClearNPCs
	setDipNPC[${Me.Chunk}]:GetSettingIterator[itDipNPC]
	if ${itDipNPC:First(exists)}
	{
		do
		{
			call FindFirstAvailableNPCSlot
			if ${Return}
			{
				dipNPCs[${Return}].NameID:Set[${itDipNPC.Value}]
				dipNPCs[${Return}].Name:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[Name].String}]
				dipNPCs[${Return}].ID:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[ID].String}]
				dipNPCs[${Return}].X:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[X].String}]
				dipNPCs[${Return}].Y:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[Y].String}]
				dipNPCs[${Return}].Z:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[Z].String}]
				dipNPCs[${Return}].red:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[red].String}]
				dipNPCs[${Return}].green:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[green].String}]
				dipNPCs[${Return}].blue:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[blue].String}]
				dipNPCs[${Return}].yellow:Set[${setDipNPC[${Me.Chunk}].FindSet[${itDipNPC.Value}].FindSetting[yellow].String}]
			}
		}
		while ${itDipNPC:Next(exists)}
	}
	setDipTypes:GetSettingIterator[itDipTypes]
	if ${itDipTypes:First(exists)}
	{
		do
		{
			convTypes:Insert[${itDipTypes.Value}]
		}
		while ${itDipTypes:Next(exists)}
	}
	setDipGeneral:GetSettingIterator[itDipGen]
	if ${itDipGen:First(exists)}
	{
		do
		{
			if (${itDipGen.Key.Equal[Face]})
			{
				boolFace:Set[${itDipGen.Value}]
			}
			if (${itDipGen.Key.Equal[fullAuto]})
			{
				fullAuto:Set[${itDipGen.Value}]
			}
			if (${itDipGen.Key.Equal[cardDelay]})
			{
				cardDelay:Set[${itDipGen.Value}]
			}
			if (${itDipGen.Key.Equal[minWait]})
			{
				minWait:Set[${itDipGen.Value}]
			}
			if (${itDipGen.Key.Equal[maxWait]})
			{
				maxWait:Set[${itDipGen.Value}]
			}
		}
		while (${itDipGen:Next(exists)})
	}
}

function:int FindNameInNPCList(string SearchName)
{
	variable int i = 1
	do
	{
		if ${dipNPCs[${i}].NameID.Equal[${SearchName}]}
		{
			return ${i}
		}
		i:Inc
	}
	while (${i} < 21)
	return 0
}

function:int FindFirstAvailableNPCSlot()
{
	variable int i = 1
	do
	{
		if ${dipNPCs[${i}].Name.Equal["Empty"]} || ${dipNPCs[${i}].NameID.Equal["Empty"]} || ${dipNPCs[${i}].ID}==0
		{
			return ${i}
		}
		i:Inc
	}
	while (${i} < 21)
	echo No available slots to add NPCs!
	return 0
}

;Atom Definitions....

atom(global) UpdateStats()
{
	if (${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem(exists)})
	{
		call FindNameInNPCList "${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
		UIElement[SelectedNPCOverallWins@DiploStats]:SetText[Selected NPC Overall Wins: ${Math.Calc[${dipNPCs[${Return}].InciteWins}+${dipNPCs[${Return}].InterviewWins}+${dipNPCs[${Return}].ConvinceWins}+${dipNPCs[${Return}].GossipWins}+${dipNPCs[${Return}].EntertainWins}].Int}]
		UIElement[SelectedNPCOverallLosses@DiploStats]:SetText[Selected NPC Overall Losses: ${Math.Calc[${dipNPCs[${Return}].InciteLosses}+${dipNPCs[${Return}].InterviewLosses}+${dipNPCs[${Return}].ConvinceLosses}+${dipNPCs[${Return}].GossipLosses}+${dipNPCs[${Return}].EntertainLosses}].Int}]
		UIElement[SelectedNPCInciteWins@DiploStats]:SetText[Selected NPC Incite Wins: ${dipNPCs[${Return}].InciteWins}]
		UIElement[SelectedNPCInciteLosses@DiploStats]:SetText[Selected NPC Incite Losses: ${dipNPCs[${Return}].InciteLosses}]
		UIElement[SelectedNPCInterviewWins@DiploStats]:SetText[Selected NPC Interview Wins: ${dipNPCs[${Return}].InterviewWins}]
		UIElement[SelectedNPCInterviewLosses@DiploStats]:SetText[Selected NPC Interview Losses: ${dipNPCs[${Return}].InterviewLosses}]
		UIElement[SelectedNPCConvinceWins@DiploStats]:SetText[Selected NPC Convince Wins: ${dipNPCs[${Return}].ConvinceWins}]
		UIElement[SelectedNPCConvinceLosses@DiploStats]:SetText[Selected NPC Convince Losses: ${dipNPCs[${Return}].ConvinceLosses}]
		UIElement[SelectedNPCGossipWins@DiploStats]:SetText[Selected NPC Gossip Wins: ${dipNPCs[${Return}].GossipWins}]
		UIElement[SelectedNPCGossipLosses@DiploStats]:SetText[Selected NPC Gossip Losses: ${dipNPCs[${Return}].GossipLosses}]
		UIElement[SelectedNPCEntertainWins@DiploStats]:SetText[Selected NPC Entertain Wins: ${dipNPCs[${Return}].EntertainWins}]
		UIElement[SelectedNPCEntertainLosses@DiploStats]:SetText[Selected NPC Entertain Losses: ${dipNPCs[${Return}].EntertainLosses}]
	}
}

atom(script) OnParlayBegin()
{
	;echo "Begin"
	;call DoParleyCard
	if ${debug}
	{
		Redirect -append "${Output}" echo "${Time}: Parley Begin event fired."
	}
	if (!${dipisPaused})
	{
		starting:Toggle
	}
}

atom(script) OnParlayOppTurnEnd()
{
	if ${debug}
	{
		Redirect -append "${Output}" echo "${Time}: Event for oppturnend fired."
	}
	ourTurn:Set[TRUE]
}

atom(script) OnParlaySuccess()
{
	if ${debug}
	{
		Redirect -append "${Output}" echo "${Time}: Event for parleysuccess fired"
	}
	wins:Inc
	dipNPCs[${curNPC}].${currentParleyType}Wins:Inc
	${currentParleyType}wins:Inc
	UpdateStats
	parleyDone:Toggle
}

atom(script) OnParlayLost()
{
	if ${debug}
	{
		Redirect -append "${Output}" echo "${Time}: Event for parley lost fired"
	}
	losses:Inc
	dipNPCs[${curNPC}].${currentParleyType}Losses:Inc
	${currentParleyType}losses:Inc
	UpdateStats
	parleyDone:Toggle
}

atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	if (${Text.Find["You need at least a diplomacy level of"]})
	{
		if ${debug}
		{
			Redirect -append "${Output}" echo "${Time}: Too low a level, next NPC"
		}
		needNewNPC:Set[TRUE]
	}
	if (${Text.Find["Your turn is already in progress."]})
	{
		if ${debug}
		{
			Redirect -append "${Output}" echo "${Time}: Waiting for 'ourturn' timer to expire... "
		}
		starting:Toggle
	}
	if (${Text.Find["no line of sight to your target"]})
	{
		if ${debug}
		{
			Redirect -append "${Output}" echo "${Time}: Face issue chatevent fired, facing target"
		}
		face ${Math.Calc[${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
		starting:Toggle
	}
	if (${Text.Find["Presence has increased"]})
	{
		if ${debug}
		{
			Redirect -append "${Output}" echo "${Time}: Presence increase"
		}
		if (${Text.Find["Domestic"]})
		{
			presDomestic:Inc
		}
		if (${Text.Find["Soldier"]})
		{
			presSoldier:Inc
		}
		if (${Text.Find["Crafter"]})
		{
			presCrafter:Inc
		}
		if (${Text.Find["Clergy"]})
		{
			presClergy:Inc
		}
		if (${Text.Find["Academic"]})
		{
			presAcademic:Inc
		}
		if (${Text.Find["Merchant"]})
		{
			presMerchant:Inc
		}
		if (${Text.Find["Noble"]})
		{
			presNoble:Inc
		}
		if (${Text.Find["Outsider"]})
		{
			presOutsider:Inc
		}
	}
}

atom(global) dipMap()
{
	if !${dipisMapping}
	{
		dipisMapping:Set[TRUE]
		UIElement[Diplo].FindChild[DipTabs].FindChild[Options].FindChild[Mapping]:SetChecked
	}
	else
	{
		dipisMapping:Set[FALSE]
		UIElement[Diplo].FindChild[DipTabs].FindChild[Options].FindChild[Mapping]:UnsetChecked
		dipnav:SavePaths
	}
}

atom(global) dipUnpause()
{
	dipisPaused:Set[FALSE]
}

atom(global) dipStart()
{
	dipisPaused:Set[FALSE]
	if (!${VG.IsInParlay})
	{
		needNewNPC:Set[TRUE]
	}
}

atom(global) dipPause()
{
	dipisPaused:Set[TRUE]
	isMoving:Set[FALSE]
	VG:ExecBinding[moveforward,release]
}

atom(global) DipEnd()
{
	if ${debug}
	{
		Redirect -append "${Output}" echo "${Time}: DipEnd atom called."
	}
	endScript:Set[TRUE]
	isMoving:Set[FALSE]
	VG:ExecBinding[moveforward,release]
	
}

atom(global) toggleFace()
{
	if !${boolFace}
	{
		boolFace:Set[TRUE]
		UIElement[Diplo].FindChild[DipTabs].FindChild[Options].FindChild[Face]:SetChecked
	}
	else
	{
		boolFace:Set[FALSE]
		UIElement[Diplo].FindChild[DipTabs].FindChild[Options].FindChild[Face]:UnsetChecked
	}
}

atom(global) dipAuto()
{
	if !${fullAuto}
	{
		UIElement[FullAuto@Options@DipTabs@Diplo]:Show
		UIElement[diplogearLoad@Options@DipTabs@Diplo]:Hide
		fullAuto:Set[TRUE]
	}
	else
	{
		UIElement[SemiAuto@Options@DipTabs@Diplo]:Show
		UIElement[diplogearLoad@Options@DipTabs@Diplo]:Show
		fullAuto:Set[FALSE]
	}
}

atom(global) dipClearNPCs()
{
	variable int i = 1
	do
	{
		dipNPCs[${i}]:Clear
		i:Inc
	}
	while (${i} < 21)
	UIElement[NPCList@Options@DipTabs@Diplo]:ClearItems
}

atom(global) dipAddTarget()
{
	call FindNameInNPCList "${Me.Target.Name} - ${Me.Target.ID}"
	if (!${Return})
	{
		call FindFirstAvailableNPCSlot
		dipNPCs[${Return}].Name:Set[${Me.Target.Name}]
		dipNPCs[${Return}].NameID:Set[${Me.Target.Name} - ${Me.Target.ID}]
		dipNPCs[${Return}].ID:Set[${Me.Target.ID}]
		dipNPCs[${Return}].X:Set[${Me.Target.X}]
		dipNPCs[${Return}].Y:Set[${Me.Target.Y}]
		dipNPCs[${Return}].Z:Set[${Me.Target.Z}]
		if (!${UIElement[NPCList@Options@DipTabs@Diplo].ItemByText[${Me.Target.Name} - ${Me.Target.ID}]})
		{
			UIElement[NPCList@Options@DipTabs@Diplo]:AddItem[${Me.Target.Name} - ${Me.Target.ID}]
		}
	}
}

;; Is this called????
atom(global) dipAddName(string Name)
{
	call FindNameInNPCList "${Name}"
	if (!${Return})
	{
		call FindFirstAvailableNPCSlot
		dipNPCs[${Return}].Name:Set[${Name}]
		if (!${UIElement[NPCList@Options@DipTabs@Diplo].ItemByText[${UIElement[AddNPCText@Options@DipTabs@Diplo].Text}]})
		{
			UIElement[NPCList@Options@DipTabs@Diplo]:AddItem[${Name}]
		}
	}
}

atom(global) dipRemoveFromList()
{
	variable int i = 1
	do
	{
		if (${dipNPCs[${i}].Name.Equal[${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}]})
		{
			dipNPCs[${i}]:Clear
			break
		}
		i:Inc
	}
	while (${i} < 21)

	i:Set[1]
	if (${UIElement[NPCList@Options@DipTabs@Diplo].Items} == 1)
	{
		UIElement[NPCList@Options@DipTabs@Diplo]:ClearItems
	}
	else
	{
		do
		{
			if ${UIElement[NPCList@Options@DipTabs@Diplo].Item[${i}].Text.Equal[${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}]}
			{
				UIElement[NPCList@Options@DipTabs@Diplo]:RemoveItem[${i}]
				break
			}
			i:Inc
		}
		while (${UIElement[NPCList@Options@DipTabs@Diplo].Item[${i}](exists)})
	}
}

atom(global) colorToggle(string Color)
{
	call FindNameInNPCList "${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
	if (${dipNPCs[${Return}].${Color}})
	{
		dipNPCs[${Return}].${Color}:Set[FALSE]
	}
	else
	{
		dipNPCs[${Return}].${Color}:Set[TRUE]
	}
}

atom(global) colorBoxesSet()
{
	call FindNameInNPCList "${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
	if (${dipNPCs[${Return}].red})
	{
		UIElement[red@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[red@Options@DipTabs@Diplo]:UnsetChecked
	}
	if (${dipNPCs[${Return}].green})
	{
		UIElement[green@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[green@Options@DipTabs@Diplo]:UnsetChecked
	}
	if (${dipNPCs[${Return}].blue})
	{
		UIElement[blue@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[blue@Options@DipTabs@Diplo]:UnsetChecked
	}
	if (${dipNPCs[${Return}].yellow})
	{
		UIElement[yellow@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[yellow@Options@DipTabs@Diplo]:UnsetChecked
	}
}

atom(global) carddelayToggle()
{
	if (${cardDelay})
	{
		cardDelay:Set[FALSE]
		UIElement[MinDelayV@Options@DipTabs@Diplo]:Hide
		UIElement[MaxDelayV@Options@DipTabs@Diplo]:Hide
		UIElement[MinDelayL@Options@DipTabs@Diplo]:Hide
		UIElement[MaxDelayL@Options@DipTabs@Diplo]:Hide
		UIElement[MinDelay@Options@DipTabs@Diplo]:Hide
		UIElement[MaxDelay@Options@DipTabs@Diplo]:Hide
		UIElement[CardDelay@Options@DipTabs@Diplo]:UnsetChecked
	}
	else
	{
		cardDelay:Set[TRUE]
		UIElement[MinDelayL@Options@DipTabs@Diplo]:Show
		UIElement[MaxDelayL@Options@DipTabs@Diplo]:Show
		UIElement[MinDelayV@Options@DipTabs@Diplo]:Show
		UIElement[MaxDelayV@Options@DipTabs@Diplo]:Show
		UIElement[MinDelay@Options@DipTabs@Diplo]:Show
		UIElement[MaxDelay@Options@DipTabs@Diplo]:Show
		UIElement[CardDelay@Options@DipTabs@Diplo]:SetChecked
	}
}


atom(global) SpitVariables()
{
	Redirect -append "${Output}" echo "${Time}: Variable Dump"
	Redirect -append "${Output}" echo "starting: ${starting} ## needNewNPC: ${needNewNPC} ## parleyDone: ${parleyDone} ## dipisMapping: ${dipisMapping}"
	Redirect -append "${Output}" echo "dipisPaused: ${dipisPaused} ## isMoving ${isMoving} ## curNPC ${curNPC} ## endScript: ${endScript} ## fullAuto: ${fullAuto}"
	Redirect -append "${Output}" echo "boolFace: ${boolFace} ## maxwait: ${maxWait} ## minWait: ${minWait} ## ourTurn: ${ourTurn} ## cardDelay ${cardDelay}"
	Redirect -append "${Output}" echo "currentParleyType: ${currentParleyType} ## InParley: ${VG.IsInParlay} ## DialogPoints: ${Parlay.DialogPoints}"
}

atom(global) delayChange(string Delay)
{
	if (${Delay.Equal[Min]})
	{
		if (${UIElement[MinDelay@Options@DipTabs@Diplo].Value} >= ${UIElement[MaxDelay@Options@DipTabs@Diplo].Value} && ${UIElement[MaxDelay@Options@DipTabs@Diplo].Value} != 0)
		{
			UIElement[MinDelay@Options@DipTabs@Diplo]:SetValue[${Math.Calc[${UIElement[MaxDelay@Options@DipTabs@Diplo].Value}-1]}]
		}
		minWait:Set[${UIElement[MinDelay@Options@DipTabs@Diplo].Value}]
	}
	else
	{
		if (${UIElement[MaxDelay@Options@DipTabs@Diplo].Value} <= ${UIElement[MinDelay@Options@DipTabs@Diplo].Value})
		{
			UIElement[MaxDelay@Options@DipTabs@Diplo]:SetValue[${Math.Calc[${UIElement[MinDelay@Options@DipTabs@Diplo].Value}+1]}]
		}
		maxWait:Set[${UIElement[MaxDelay@Options@DipTabs@Diplo].Value}]
	}
}



