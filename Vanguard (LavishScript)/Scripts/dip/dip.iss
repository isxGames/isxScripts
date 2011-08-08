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
Zandros, numerous updates and improvements... 14 July 2011
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
		Incite:Set[FALSE]
		Interview:Set[FALSE]
		Convince:Set[FALSE]
		Gossip:Set[FALSE]
		Entertain:Set[FALSE]
		Wins:Set[0]
		Losses:Set[0]
		InciteWins:Set[0]
		InciteLosses:Set[0]
		InterviewWins:Set[0]
		InterviewLosses:Set[0]
		ConvinceWins:Set[0]
		ConvinceLosses:Set[0]
		GossipWins:Set[0]
		GossipLosses:Set[0]
		EntertainWins:Set[0]
		EntertainLosses:Set[0]
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
		Incite:Set[FALSE]
		Interview:Set[FALSE]
		Convince:Set[FALSE]
		Gossip:Set[FALSE]
		Entertain:Set[FALSE]
		Wins:Set[0]
		Losses:Set[0]
		InciteWins:Set[0]
		InciteLosses:Set[0]
		InterviewWins:Set[0]
		InterviewLosses:Set[0]
		ConvinceWins:Set[0]
		ConvinceLosses:Set[0]
		GossipWins:Set[0]
		GossipLosses:Set[0]
		EntertainWins:Set[0]
		EntertainLosses:Set[0]
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
	variable bool Incite
	variable bool Interview
	variable bool Convince
	variable bool Gossip
	variable bool Entertain
	variable int Wins
	variable int Losses
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
variable(script) bool needNewNPC = FALSE
variable(global) index:string convTypes
variable(script) bool parleyDone = FALSE
variable(global) bool dipisMapping = FALSE
variable(global) bool dipisPaused = TRUE
variable(script) bool isMoving = FALSE
variable(script) bool isRunning = TRUE
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
variable(script) bool cardDelay = FALSE
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
variable int AngleDiff = 0
variable int AngleDiffAbs = 0
variable int LowestDipLevel = 0
variable int HighestDipLevel = 100
variable bool doChangeEquipment = FALSE

;Paths
variable filepath scriptPath = "${Script.CurrentDirectory}/"
variable filepath savePath = "${Script.CurrentDirectory}/Save/"
variable filepath VGPathsDir = "${Script.CurrentDirectory}/Paths/"
variable string UIFile = "${Script.CurrentDirectory}/dip.xml"
variable string UISkin = "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
variable string Output = "${Script.CurrentDirectory}/Save/Debug.txt"
variable string CurrentChunk 

;Debug setup
variable(script) bool debug = FALSE
variable(script) string returnvalue = "GOOD"

function main()
{
	;; Load ISXVG or exit script
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "VG:  Unable to load ISXVG, exiting dip script"
		endscript dip
	}
	
	;; wait until both chunk and self exists
	wait 50 ${Me.Chunk(exists)} && ${Me.FName(exists)}
	CurrentChunk:Set[${Me.Chunk}]
	
	;; Announce we started
	EchoIt "Diplomacy Started..."

	;; Create directories
	mkdir "${savePath}"
	mkdir "${VGPathsDir}"

	;; Delete our log file
	if ${savePath.FileExists[Debug.txt]}
	{
		;; delete our output file
		rm "${Output}"
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
	Event[OnFrame]:AttachAtom[OnFrame]

	call LoadSettings
	
	call dipnav.Initialize

	CurrentRegion:Set[${LNavRegion[${dipnav.CurrentRegionID}].Name}]
	LastRegion:Set[${LNavRegion[${dipnav.CurrentRegionID}].Name}]

	ui -reload "${UISkin}"
	ui -reload -skin VGSkin "${UIFile}"
	UIElement[HUD@Diplo]:Select
	UIElement[Diplo]:SetWidth[160]
	UIElement[Diplo]:SetHeight[80]
	call setupUI
	EchoIt "Paused"

	;Begin the never ending loop....
	while ${isRunning} && !${endScript}
	{
		if ${Me.Chunk(exists)} && ${Me.FName(exists)}
		{
			call GoDiploSomething
		}
	}
	
	if ${Me.Chunk(exists)} && ${Me.FName(exists)}
	{
		call SaveSettings
	}
	EchoIt "Diplomacy Ended..."
}	
	
function GoDiploSomething()
{
	;; have we chunked?  
	if !${CurrentChunk.Equal[${Me.Chunk}]}
	{
		;; we chunked
		EchoIt "We chunked from ${CurrentChunk} to ${Me.Chunk}"

		;; save our current settings
		EchoIt "Saving previous chunk data"
		call SaveSettings

		;; make sure we clear current NPC list
		dipClearNPCs
		
		;; update current chunk
		CurrentChunk:Set[${Me.Chunk}]
		
		;; load our new settings
		EchoIt "loading current chunk data"
		dipnav:LoadPaths
		CurrentRegion:Set[${LNavRegion[${dipnav.CurrentRegionID}].Name}]
		LastRegion:Set[${LNavRegion[${dipnav.CurrentRegionID}].Name}]
		call LoadSettings
		call setupUI
	}

	;; we do not want to continue if paused
	if ${dipisPaused}
	{
		return
	}
	
	;; we got ourselves an AggroNPC
	if ${Me.HealthPct}<75 || ${Me.Encounter}
	{
		EchoIt "Health=${Me.HealthPct}, Encounters=${Me.Encounter}, Target=${Me.Target.Name}"
		dipisPaused:Set[TRUE]
		return
	}

	if ${fullAuto}
	{
		;; go get a NPC to diplo and start a parlay
		if !${VG.IsInParlay}
		{
			call SelectNextNPC
			if ${curNPC}>0
			{
				call MoveToNPC
				call TargetNPC
				call StartParlay
			}
		}
	}
	
	;; always check to see if we need to change equipment
	if ${doChangeEquipment}
	{
		call ChangeEquipment
	}
	
	;; we are in a parlay so go play a card
	if ${VG.IsInParlay}
	{
		if !${dipisPaused} && ${ourTurn}
		{
			call DoParleyCard
			ourTurn:Set[FALSE]
		}
		;if !${dipisPaused} && ${Parlay.DialogPoints}==0 && !${Parlay.IsMyTurn} && ${Parlay.IsOpponentTurn} && !${ourTurn}
		if !${dipisPaused} && ${Parlay.DialogPoints}==0
		{
			wait 20 ${Me.IsLooting} || ${dipisPaused}
			if ${Loot} && ${Me.IsLooting}
			{
				Loot:LootAll
				waitframe
			}
			Parlay:Continue
			waitframe
			VGExecute /cleartargets
			wait 10 ${dipisPaused}
		}
	}
	else
	{
		;; make sure we set ourTurn on
		ourTurn:Set[TRUE]
	}
}

function SelectNextNPC()
{
	;; we do not want to continue if paused
	if ${dipisPaused}
	{
		return
	}

	;; cycle through until we find a NPC
	while ${curNPC}<20
	{
		curNPC:Inc
		;; we got found one so return
		if !${dipNPCs[${curNPC}].Name.Equal["Empty"]}
		{
			EchoIt "NPC Selected: [${curNPC}] ${dipNPCs[${curNPC}].Name}"
			;; this is here to allow time for the parlays to reset
			wait 20 ${dipisPaused}
			return
		}
	}
	;; reset our current NPC counter
	if ${curNPC}>=20
	{
		curNPC:Set[0]
	}

}

function MoveToNPC()
{
	;; move only to valid NPC
	if !${dipisPaused} && ${curNPC} && !${dipNPCs[${curNPC}].Name.Equal["Empty"]}
	{
		;; move closer if NPC's last location
		if !${dipisPaused}
		{
			;; set our return value to GOOD and we are moving
			returnvalue:Set[GOOD]
			isMoving:Set[TRUE]
			
			;; attempt to update ID incase VG reset all IDs
			if !${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)}
			{
				if ${Pawn[exactname,${dipNPCs[${curNPC}].Name}](exists)}
				{
					dipNPCs[${curNPC}].ID:Set[${Pawn[exactname,${dipNPCs[${curNPC}].Name}].ID}]
					dipNPCs[${curNPC}].NameID:Set[${dipNPCs[${curNPC}].Name} - ${dipNPCs[${curNPC}].ID}]
				}
			}
			
			;; move to NPC if we can target
			if ${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)}
			{
				if ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance}>=8
				{
					EchoIt "Starting movement routine of current pawn location with a distance of ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance}"
					call dipnav.MovetoTargetID "${dipNPCs[${curNPC}].ID}" TRUE
					returnvalue:Set[${Return}]
					if ${returnvalue.Equal[NO MAP]}
					{
						;; we will manually move closer to target if already in range
						if ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance}>=8 && ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance}<15
						{
							if ${Pawn[id,${dipNPCs[${curNPC}].ID}].HaveLineOfSightTo}
							{
								EchoIt "Manually moving to target"
								call FaceTarget
								isMoving:Set[FALSE]
								VG:ExecBinding[moveforward]
								do
								{
									face ${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo}
									if ${endScript}
									{
										VG:ExecBinding[moveforward, release]
										isMoving:Set[FALSE]
										return
									}
								}
								while ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance} > 8
								VG:ExecBinding[moveforward, release]
								EchoIt "Successful move to ${dipNPCs[${curNPC}].Name}"
								return
							}
						}
						;; make sure we get on the map
						call dipnav.MoveToMappedArea
						VG:ExecBinding[moveforward, release]
						call dipnav.MovetoTargetID "${dipNPCs[${curNPC}].ID}" TRUE
						returnvalue:Set[${Return}]
					}
				}
			}
			;; move to last known XYZ location if we can not target the NPC
			elseif !${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)}
			{
				EchoIt "Starting movement routine via last known XYZ location with distance of ${Math.Distance[${Me.X},${Me.Y},${dipNPCs[${curNPC}].X},${dipNPCs[${curNPC}].Y}]}"
				call dipnav.MovetoXYZ ${dipNPCs[${curNPC}].X} ${dipNPCs[${curNPC}].Y} ${dipNPCs[${curNPC}].Z}
				returnvalue:Set[${Return}]
				if ${returnvalue.Equal[NO MAP]}
				{
					;; make sure we get on the map
					call dipnav.MoveToMappedArea
					VG:ExecBinding[moveforward, release]
					call dipnav.MovetoTargetID "${dipNPCs[${curNPC}].ID}" TRUE
					returnvalue:Set[${Return}]
				}
			}
			
			;; NPC might have moved so let's try moving closer
			if ${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)} && ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance}>=8
			{
				EchoIt "Starting movement routine of current pawn location with a distance of ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance}"
				call dipnav.MovetoTargetID "${dipNPCs[${curNPC}].ID}" TRUE
				returnvalue:Set[${Return}]
				if ${returnvalue.Equal[NO MAP]}
				{
					;; make sure we get on the map
					call dipnav.MoveToMappedArea
					VG:ExecBinding[moveforward, release]
					call dipnav.MovetoTargetID "${dipNPCs[${curNPC}].ID}" TRUE
					returnvalue:Set[${Return}]
				}
			}
			
			;; We reached our destination
			if ${returnvalue.Equal[END]}
			{
				EchoIt "Successful move to ${dipNPCs[${curNPC}].Name}"
			}
			elseif ${returnvalue.Equal[NO MAP]}
			{
				vgecho "Not on map"
				EchoIt "Not on mapped area, moving back to map"
				call dipnav.MoveToMappedArea
				VG:ExecBinding[moveforward, release]
			}
			else
			{
				EchoIt "Movement succeeded - Return Value = ${returnvalue}"
			}
			isMoving:Set[FALSE]
		}
	}
}

function TargetNPC()
{
	;; if the NPC is nearby then let's target it
	if !${dipisPaused} && ${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)}
	{
		EchoIt "Targeting ${dipNPCs[${curNPC}].NameID}"
		Pawn[id,${dipNPCs[${curNPC}].ID}]:Target
		wait 5
		call FaceTarget
	}
}

function StartParlay()
{
	;; return if we have no target or script is paused
	if ${dipisPaused} || !${Me.Target(exists)} || ${Me.Target.Distance}>=10
	{
		return
	}

	;; start a parlay
	if ${Me.Target.HaveLineOfSightTo}
	{
		EchoIt "Selecting parley from ${Me.Target.Name}"
		ourTurn:Set[TRUE]
		call SelectParlay 
	}
}

function ChangeEquipment()
{
	if ${doChangeEquipment}
	{
		call PresenceNeeded
		returnvalue:Set[${Return}]
		EchoIt "Equiping gear for: ${returnvalue}"
		call obj_diplogear.Load2 "${returnvalue}"
		EchoIt "Equiped gear: ${returnvalue}"
		EchoIt "ReAssessing ${Me.Target.Name}"
		Parlay:AssessTarget
		wait 7
		doChangeEquipment:Set[FALSE]
	}
}

atom(script) OnFrame()
{
	if (${dipisMapping})
	{
		dipnav:AutoBox
		dipnav:ConnectOnMove
	}
}


function SelectParlay()
{
	call FaceTarget
	EchoIt "Assessing: ${Me.Target.Name}"
	Parlay:AssessTarget[${dipNPCs[${curNPC}].NameID}]
	wait 7
	variable int selectedConv = 0
	variable int convOptions = 1
	variable int i = 1
	variable string genorciv
	variable int diplevel
	while ${convOptions} <= ${Dialog[General].ResponseCount} && !${selectedConv}
	{
		currentParleyType:Set[Unknown]
		diplevel:Set[${Dialog[General,${convOptions}].Text.Mid[${Dialog[General,${convOptions}].Text.Find[dkblue>]},${Dialog[General,${convOptions}].Text.Length}].Token[2,>].Token[1,<]}]

		;echo "General[${convOptions}], curNPC=${curNPC}/${dipNPCs[${curNPC}].Name}"
		;echo "DipLevel=${diplevel}, Incite=${dipNPCs[${curNPC}].Incite}, Interview=${dipNPCs[${curNPC}].Interview}, Convine=${dipNPCs[${curNPC}].Convince}, Gossip=${dipNPCs[${curNPC}].Gossip}, Entertain=${dipNPCs[${curNPC}].Entertain}"
		
		i:Set[1]
		do
		{
			if ${diplevel}>=${LowestDipLevel} && ${diplevel}<=${HighestDipLevel}
			{
				;;if ${Dialog[General,${convOptions}].Text.Find[>${convTypes[${i}]}]}
				if ${dipNPCs[${curNPC}].Incite} && ${Dialog[General,${convOptions}].Text.Find[>Incite]}
				{
					genorciv:Set[General]
					selectedConv:Set[${convOptions}]
					currentParleyType:Set[Incite]
					break
				}
				if ${dipNPCs[${curNPC}].Interview} && ${Dialog[General,${convOptions}].Text.Find[>Interview]}
				{
					genorciv:Set[General]
					selectedConv:Set[${convOptions}]
					currentParleyType:Set[Interview]
					break
				}
				if ${dipNPCs[${curNPC}].Convince} && ${Dialog[General,${convOptions}].Text.Find[>Convince]}
				{
					genorciv:Set[General]
					selectedConv:Set[${convOptions}]
					currentParleyType:Set[Convince]
					break
				}
				if ${dipNPCs[${curNPC}].Gossip} && ${Dialog[General,${convOptions}].Text.Find[>Gossip]}
				{
					genorciv:Set[General]
					selectedConv:Set[${convOptions}]
					currentParleyType:Set[Gossip]
					break
				}
				if ${dipNPCs[${curNPC}].Entertain} && ${Dialog[General,${convOptions}].Text.Find[>Entertain]}
				{
					genorciv:Set[General]
					selectedConv:Set[${convOptions}]
					currentParleyType:Set[Entertain]
					break
				}
			}
			i:Inc
		}
		while (${convTypes[${i}](exists)})
		convOptions:Inc
	}
	if !${selectedConv}
	{
		convOptions:Set[1]
		while ${convOptions} <= ${Dialog[Civic Diplomacy].ResponseCount} && !${selectedConv}
		{
			currentParleyType:Set[Unknown]
			diplevel:Set[${Dialog[Civic Diplomacy,${convOptions}].Text.Mid[${Dialog[Civic Diplomacy,${convOptions}].Text.Find[dkblue>]},${Dialog[Civic Diplomacy,${convOptions}].Text.Length}].Token[2,>].Token[1,<]}]

			;echo "Civic Diplomacy[${convOptions}], curNPC=${curNPC}/${dipNPCs[${curNPC}].Incite}"
			;echo "DipLevel=${diplevel}, Incite=${dipNPCs[${curNPC}].Incite}, Interview=${dipNPCs[${curNPC}].Interview}, Convine=${dipNPCs[${curNPC}].Convince}, Gossip=${dipNPCs[${curNPC}].Gossip}, Entertain=${dipNPCs[${curNPC}].Entertain}"

			diplevel:Set[${Dialog[Civic Diplomacy,${convOptions}].Text.Mid[${Dialog[Civic Diplomacy,${convOptions}].Text.Find[dkblue>]},${Dialog[Civic Diplomacy,${convOptions}].Text.Length}].Token[2,>].Token[1,<]}]
			i:Set[1]
			do
			{
				if ${diplevel}>=${LowestDipLevel} && ${diplevel}<=${HighestDipLevel}
				{
					;;if ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>${convTypes[${i}]}]}
					if ${dipNPCs[${curNPC}].Incite} && ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>Incite]}
					{
						genorciv:Set[Civic Diplomacy]
						selectedConv:Set[${convOptions}]
						currentParleyType:Set[Incite]
						break
					}
					if ${dipNPCs[${curNPC}].Interview} && ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>Interview]}
					{
						genorciv:Set[Civic Diplomacy]
						selectedConv:Set[${convOptions}]
						currentParleyType:Set[Interview]
						break
					}
					if ${dipNPCs[${curNPC}].Convince} && ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>Convince]}
					{
						genorciv:Set[Civic Diplomacy]
						selectedConv:Set[${convOptions}]
						currentParleyType:Set[Convince]
						break
					}
					if ${dipNPCs[${curNPC}].Gossip} && ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>Gossip]}
					{
						genorciv:Set[Civic Diplomacy]
						selectedConv:Set[${convOptions}]
						currentParleyType:Set[Gossip]
						break
					}
					if ${dipNPCs[${curNPC}].Entertain} && ${Dialog[Civic Diplomacy,${convOptions}].Text.Find[>Entertain]}
					{
						genorciv:Set[Civic Diplomacy]
						selectedConv:Set[${convOptions}]
						currentParleyType:Set[Entertain]
						break
					}
				}
				i:Inc
			}
			while ${convTypes[${i}](exists)}
			convOptions:Inc
		}
	}
	if (${selectedConv})
	{
		if ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance} > 9
		{
			EchoIt "Backup movement code called."
			
			VG:ExecBinding[moveforward]
			do
			{
				face ${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo}
				if ${endScript}
				{
					VG:ExecBinding[moveforward, release]
					return
				}
			}
			while ${Pawn[id,${dipNPCs[${curNPC}].ID}].Distance} > 9
			VG:ExecBinding[moveforward, release]
		}
		else
		{
			variable string temp
			temp:Set[${Dialog[${genorciv},${selectedConv}].PresenceRequiredType}]
			temp:Set[${temp.Left[${Math.Calc[${temp.Find[Presence]}-2]}]}]
			if !${Me.Stat[Diplomacy,${temp}]}
			{
				temp:Set[${temp}s]
			}
			
			EchoIt "Parlay = ${Dialog[${genorciv},${selectedConv}].Text.Left[${Math.Calc[${Dialog[${genorciv},${selectedConv}].Text.Find[<nl>]}-2]}]}"
			EchoIt "Expression = ${currentParleyType}"
			EchoIt "Presence Type = ${temp}"
			EchoIt "Presence Need = ${Dialog[${genorciv},${selectedConv}].PresenceRequired}"
			EchoIt "Presence Have = ${Me.Stat[Diplomacy,${temp}]}"
			
			doChangeEquipment:Set[TRUE]
			call ChangeEquipment
			
			;; start the parlay if we have enough presence
			if ${Dialog[${genorciv},${selectedConv}].PresenceRequired} <= ${Me.Stat[Diplomacy,${temp}]}
			{
				Dialog[${genorciv},${selectedConv}]:Select
				EchoIt "Selecting ${genorciv}: ${selectedConv} ${currentParleyType}"
				wait 50 ${VG.IsInParlay} || ${dipisPaused}
			}
			elseif ${Dialog[${genorciv},${selectedConv}].PresenceRequired} > ${Me.Stat[Diplomacy,${temp}]}
			{
				EchoIt "You do not have enough presence to parlay with"
			}
		}
	}
	else
	{
		EchoIt "No Available parleys"
		EchoIt "==============================="
		needNewNPC:Toggle
		;; this is here to reduce the running between two NPCs
		wait 75 ${dipisPaused}
	}
}

function:bool IsPlayable(int card)
{
	variable int reason = ${Math.Calc[${Parlay.Reason}/10]}
	variable int inspire = ${Math.Calc[${Parlay.Inspire}/10]}
	variable int flatter = ${Math.Calc[${Parlay.Flatter}/10]}
	variable int demand = ${Math.Calc[${Parlay.Demand}/10]}

	;echo "Card cost:  ${Strategy[${card}].DemandCost} ${Strategy[${card}].ReasonCost} ${Strategy[${card}].InspireCost} ${Strategy[${card}].FlatterCost}"
	;echo "Demand=${demand}, Reason=${reason}, Inspire=${inspire}, Flatter=${flatter}"

	if ${Strategy[${card}].RoundsToRefresh} > 0
	{
		return "FALSE"
	}
	
	;; we do not want 1st card laid down to be Id Personified
	if ${Strategy[${card}].Name.Equal[Id Personified]}
	{
		if ${reason}>2 && ${inspire}>2 && ${flatter}>2 && ${demand}>2
		{
			return "FALSE"
		}
		if ${reason}==0 && ${inspire}==0 && ${flatter}==0 && ${demand}==0
		{
			return "FALSE"
		}
	}
	
	;; if we are maxed then don't play any cards that can increase our score
	if ${Math.Calc[10 - ${Parlay.Status}]}==0
	{
		if ${Math.Calc[${Strategy[${card}].InfluenceMin} + ${Strategy[${card}].InfluenceMax}]}
		{
			return "FALSE"
		}
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
	
	variable int infl = ${Math.Calc[(${Strategy[${card}].InfluenceMin} + ${Strategy[${card}].InfluenceMax})/2]}
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
	; ############### If already maxed worry more about whats given.
	if ${inflmax} == 0
	{
		givescalered:Set[${Math.Calc[${givescalered}*2]}]
		givescaleblue:Set[${Math.Calc[${givescaleblue}*2]}]
		givescalegreen:Set[${Math.Calc[${givescalegreen}*2]}]
		givescaleyellow:Set[${Math.Calc[${givescaleyellow}*2]}]
		gainscale:Set[${Math.Calc[${gainscale}*2]}]
		;echo infmax ${inflmax}
	}

	; increase rating if we have a card that equal what we need to be maxed
	if ${infl} == ${inflmax}
	{
		givescalered:Set[${Math.Calc[${givescalered}*2]}]
		givescaleblue:Set[${Math.Calc[${givescaleblue}*2]}]
		givescalegreen:Set[${Math.Calc[${givescalegreen}*2]}]
		givescaleyellow:Set[${Math.Calc[${givescaleyellow}*2]}]
		gainscale:Set[${Math.Calc[${gainscale}*2]}]
		;echo infmax ${inflmax}
	}
	
	
	; ############### If winning by 5 or greater worry more about whats given.
	;if ${inflmax} < 6
	;{
	;	givescalered:Set[${Math.Calc[${givescalered}*2]}]
	;	givescaleblue:Set[${Math.Calc[${givescaleblue}*2]}]
	;	givescalegreen:Set[${Math.Calc[${givescalegreen}*2]}]
	;	givescaleyellow:Set[${Math.Calc[${givescaleyellow}*2]}]
	;	gainscale:Set[${Math.Calc[${gainscale}*2]}]
	;	;echo infmax ${inflmax}
	;}
	
	if ${infl} > ${inflmax}
	{
		infl:Set[${inflmax}]
	}
	
	;echo bleh!
	
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
			EchoIt "Card Rating: ${rate}, Card${card}: ${Strategy[${card}].Name}, InfluenceMax: ${Strategy[${card}].InfluenceMax}, InfluenceNeed: ${Math.Calc[10 - ${Parlay.Status}].Int}"
			if ${rate} > ${ratemax}
			{
				cardplay:Set[${card}]
				ratemax:Set[${rate}]
			}
		}
		card:Inc
	}
	
	;if ${cardplay}>0 && ${Parlay.Status}<10
	if ${cardplay}>0
	{
		EchoIt "Playing Card: ${Strategy[${cardplay}].Name}"
		Strategy[${cardplay}]:Play
	}
	else
	{
		;echo "Listen"
		call FaceTarget
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
	;UIElement[Diplo]:SetWidth[160]
	;UIElement[Diplo]:SetHeight[80]
	;UIElement[HUD@Diplo]:Select
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
	while ${i} < 20
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
	;; save our map if we are still mapping
	if ${dipisMapping}
	{
		dipnav:SavePaths
	}

	;setDipNPC:Clear
	setDipTypes:Clear
	
	setDipNPC[${CurrentChunk}]:Clear	
	setDipNPC:AddSet[${CurrentChunk}]
	setDipNPC.FindSet[${CurrentChunk}]:AddSet[NPCs]
	
	variable int i = 1
	do
	{
		if !${dipNPCs[${i}].NameID.Equal["Empty"]}
		{
			setDipNPC[${CurrentChunk}]:AddSetting[${i}, "${dipNPCs[${i}].NameID}"]
			setDipNPC[${CurrentChunk}]:AddSet[${dipNPCs[${i}].NameID}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Name, ${dipNPCs[${i}].Name}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[ID, ${dipNPCs[${i}].ID}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[X, ${dipNPCs[${i}].X}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Y, ${dipNPCs[${i}].Y}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Z, ${dipNPCs[${i}].Z}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[red, ${dipNPCs[${i}].red}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[green, ${dipNPCs[${i}].green}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[blue, ${dipNPCs[${i}].blue}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[yellow, ${dipNPCs[${i}].yellow}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Incite, ${dipNPCs[${i}].Incite}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Interview, ${dipNPCs[${i}].Interview}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Convince, ${dipNPCs[${i}].Convince}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Gossip, ${dipNPCs[${i}].Gossip}]
			setDipNPC[${CurrentChunk}].FindSet[${dipNPCs[${i}].NameID}]:AddSetting[Entertain, ${dipNPCs[${i}].Entertain}]
		}
		i:Inc
	}
	while ${i} < 20

	i:Set[1]
	do
	{
		if ${convTypes[${i}](exists)}
		{
			setDipTypes:AddSetting[${i}, "${convTypes[${i}]}"]
		}
		i:Inc
	}
	while ${convTypes[${i}](exists)}

	setDipGeneral:AddSetting[Face, ${boolFace}]
	setDipGeneral:AddSetting[fullAuto, ${fullAuto}]
	setDipGeneral:AddSetting[cardDelay, ${cardDelay}]
	setDipGeneral:AddSetting[minWait, ${minWait}]
	setDipGeneral:AddSetting[maxWait, ${maxWait}]
	setDipGeneral:AddSetting[LowestDipLevel, ${LowestDipLevel}]
	setDipGeneral:AddSetting[HighestDipLevel, ${HighestDipLevel}]
	LavishSettings[diplo]:Export[${savePath}Dip-Settings.xml]
}

function LoadSettings()
{
	setDipNPC[${CurrentChunk}]:GetSettingIterator[itDipNPC]
	
	if ${setDipNPC[${CurrentChunk}](exists)}
	{
		if ${itDipNPC:First(exists)}
		{
			do
			{
				call FindFirstAvailableNPCSlot
				if ${Return}
				{
					dipNPCs[${Return}].NameID:Set[${itDipNPC.Value}]
					dipNPCs[${Return}].Name:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Name].String}]
					dipNPCs[${Return}].ID:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[ID].String}]
					dipNPCs[${Return}].X:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[X].String}]
					dipNPCs[${Return}].Y:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Y].String}]
					dipNPCs[${Return}].Z:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Z].String}]
					dipNPCs[${Return}].red:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[red].String}]
					dipNPCs[${Return}].green:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[green].String}]
					dipNPCs[${Return}].blue:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[blue].String}]
					dipNPCs[${Return}].yellow:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[yellow].String}]
					dipNPCs[${Return}].Incite:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Incite].String}]
					dipNPCs[${Return}].Interview:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Interview].String}]
					dipNPCs[${Return}].Convince:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Convince].String}]
					dipNPCs[${Return}].Gossip:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Gossip].String}]
					dipNPCs[${Return}].Entertain:Set[${setDipNPC[${CurrentChunk}].FindSet[${itDipNPC.Value}].FindSetting[Entertain].String}]
				}
			}
			while ${itDipNPC:Next(exists)}
		}
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
			if (${itDipGen.Key.Equal[LowestDipLevel]})
			{
				LowestDipLevel:Set[${itDipGen.Value}]
			}
			if (${itDipGen.Key.Equal[HighestDipLevel]})
			{
				HighestDipLevel:Set[${itDipGen.Value}]
			}
		}
		while ${itDipGen:Next(exists)}
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
	while ${i} < 21
	;echo No available slots to add NPCs!
	return 0
}

;Atom Definitions....

atom(global) UpdateStats()
{
	if ${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem(exists)}
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
	EchoIt "Parley Begin event fired"
}

atom(script) OnParlayOppTurnEnd()
{
	EchoIt "Event for oppturnend fired"
	ourTurn:Set[TRUE]
}

atom(script) OnParlaySuccess()
{
	EchoIt "Event for parley success fired"
	wins:Inc
	dipNPCs[${curNPC}].${currentParleyType}Wins:Inc
	if ${currentParleyType.Length} > 0
	{
		${currentParleyType}wins:Inc
	}
	UpdateStats
	parleyDone:Toggle
	Parlay:Farewell
}

atom(script) OnParlayLost()
{
	EchoIt "Event for parley lost fired"
	losses:Inc
	dipNPCs[${curNPC}].${currentParleyType}Losses:Inc
	if ${currentParleyType.Length} > 0
	{
		${currentParleyType}losses:Inc
	}
	UpdateStats
	parleyDone:Toggle
	Parlay:Farewell
}

atom(script) ChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	if ${Text.Find["You don't have enough presence"]}
	{
		doChangeEquipment:Set[TRUE]
	}
	if ${Text.Find["You need at least a diplomacy level of"]}
	{
		EchoIt "Too low a level, next NPC"
		needNewNPC:Set[TRUE]
	}
	if ${Text.Find["Your turn is already in progress."]}
	{
		EchoIt "Waiting for 'ourturn' timer to expire... "
	}
	if ${Text.Find["no line of sight to your target"]}
	{
		EchoIt "Face issue chatevent fired, facing target"
		face ${Math.Calc[${Pawn[id,${dipNPCs[${curNPC}].ID}].HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
	}
	if ${Text.Find["Presence has increased"]}
	{
		EchoIt "${Text}"
		if ${Text.Find["Domestic"]}
		{
			presDomestic:Inc
		}
		if ${Text.Find["Soldier"]}
		{
			presSoldier:Inc
		}
		if ${Text.Find["Crafter"]}
		{
			presCrafter:Inc
		}
		if ${Text.Find["Clergy"]}
		{
			presClergy:Inc
		}
		if ${Text.Find["Academic"]}
		{
			presAcademic:Inc
		}
		if ${Text.Find["Merchant"]}
		{
			presMerchant:Inc
		}
		if ${Text.Find["Noble"]}
		{
			presNoble:Inc
		}
		if ${Text.Find["Outsider"]}
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
	ourTurn:Set[TRUE]
	dipisPaused:Set[FALSE]
	EchoIt "Resumed"
}

atom(global) dipStart()
{
	dipisPaused:Set[FALSE]
	if (!${VG.IsInParlay})
	{
		needNewNPC:Set[TRUE]
	}
	ourTurn:Set[TRUE]
	EchoIt "Resumed"
}

atom(global) dipPause()
{
	dipisPaused:Set[TRUE]
	isMoving:Set[FALSE]
	VG:ExecBinding[moveforward,release]
	EchoIt "Paused"
}

atom(global) DipEnd()
{
	EchoIt "DipEnd atom called."
	dipisPaused:Set[TRUE]
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
	curNPC:Set[0]
	variable int i = 1
	do
	{
		dipNPCs[${i}]:Clear
		i:Inc
	}
	while ${i} < 21
	UIElement[NPCList@Options@DipTabs@Diplo]:ClearItems
}

atom(global) dipAddTarget()
{
	call FindNameInNPCList "${Me.Target.Name} - ${Me.Target.ID}"
	if !${Return}
	{
		call FindFirstAvailableNPCSlot
		dipNPCs[${Return}].Name:Set[${Me.Target.Name}]
		dipNPCs[${Return}].NameID:Set[${Me.Target.Name} - ${Me.Target.ID}]
		dipNPCs[${Return}].ID:Set[${Me.Target.ID}]
		dipNPCs[${Return}].X:Set[${Me.Target.X}]
		dipNPCs[${Return}].Y:Set[${Me.Target.Y}]
		dipNPCs[${Return}].Z:Set[${Me.Target.Z}]
		dipNPCs[${Return}].red:Set[FALSE]
		dipNPCs[${Return}].green:Set[FALSE]
		dipNPCs[${Return}].blue:Set[FALSE]
		dipNPCs[${Return}].yellow:Set[FALSE]
		dipNPCs[${Return}].Incite:Set[${UIElement[Incite@Options@DipTabs@Diplo].Checked}]
		dipNPCs[${Return}].Interview:Set[${UIElement[Interview@Options@DipTabs@Diplo].Checked}]
		dipNPCs[${Return}].Convince:Set[${UIElement[Convince@Options@DipTabs@Diplo].Checked}]
		dipNPCs[${Return}].Gossip:Set[${UIElement[Gossip@Options@DipTabs@Diplo].Checked}]
		dipNPCs[${Return}].Entertain:Set[${UIElement[Entertain@Options@DipTabs@Diplo].Checked}]
		if !${UIElement[NPCList@Options@DipTabs@Diplo].ItemByText[${Me.Target.Name} - ${Me.Target.ID}]}
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
		if !${UIElement[NPCList@Options@DipTabs@Diplo].ItemByText[${UIElement[AddNPCText@Options@DipTabs@Diplo].Text}]}
		{
			UIElement[NPCList@Options@DipTabs@Diplo]:AddItem[${Name}]
		}
	}
}

atom(global) dipRemoveFromList()
{
	EchoIt "Removing ${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
	variable int i = 1
	variable string temp1
	variable string temp2
	do
	{
		temp1:Set[${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}]
		temp2:Set[${dipNPCs[${i}].Name}]
		EchoIt "Temp2=${temp2}"
		if ${temp1.Find[${temp2}]}
		;if ${dipNPCs[${i}].Name.Equal[${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}]}
		{
			EchoIt "Removed from dipNPCs: ${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
			dipNPCs[${i}]:Clear
			break
		}
		i:Inc
	}
	while ${i} < 21

	i:Set[1]
	if ${UIElement[NPCList@Options@DipTabs@Diplo].Items} == 1
	{
		UIElement[NPCList@Options@DipTabs@Diplo]:ClearItems
	}
	else
	{
		do
		{
			temp1:Set[${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}]
			temp2:Set[${UIElement[NPCList@Options@DipTabs@Diplo].Item[${i}].Text}]
			if ${temp1.Equal[${temp2}]}
			{
				EchoIt "Removed from NPCList: ${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
				UIElement[NPCList@Options@DipTabs@Diplo]:RemoveItem[${i}]
				break
			}
			i:Inc
		}
		while ${UIElement[NPCList@Options@DipTabs@Diplo].Item[${i}](exists)}
	}
}

atom(global) colorToggle(string Color)
{
	call FindNameInNPCList "${UIElement[NPCList@Options@DipTabs@Diplo].SelectedItem}"
	if ${dipNPCs[${Return}].${Color}}
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
	if ${dipNPCs[${Return}].red}
	{
		UIElement[red@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[red@Options@DipTabs@Diplo]:UnsetChecked
	}
	if ${dipNPCs[${Return}].green}
	{
		UIElement[green@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[green@Options@DipTabs@Diplo]:UnsetChecked
	}
	if ${dipNPCs[${Return}].blue}
	{
		UIElement[blue@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[blue@Options@DipTabs@Diplo]:UnsetChecked
	}
	if ${dipNPCs[${Return}].yellow}
	{
		UIElement[yellow@Options@DipTabs@Diplo]:SetChecked
	}
	else
	{
		UIElement[yellow@Options@DipTabs@Diplo]:UnsetChecked
	}

	variable int i
	if ${dipNPCs[${Return}].Incite}
	{
		UIElement[Incite@Options@DipTabs@Diplo]:SetChecked
		convTypes:Insert[Incite]
	}
	else
	{
		UIElement[Incite@Options@DipTabs@Diplo]:UnsetChecked
		i:Set[1]
		do
		{
			if (${convTypes[${i}].Find[Incite]})
			{
				convTypes:Remove[${i}]
				convTypes:Collapse
			}
			i:Inc
		}
		while ${convTypes[${i}](exists)}
	}
	if ${dipNPCs[${Return}].Interview}
	{
		UIElement[Interview@Options@DipTabs@Diplo]:SetChecked
		convTypes:Insert[Interview]
	}
	else
	{
		UIElement[Interview@Options@DipTabs@Diplo]:UnsetChecked
		i:Set[1]
		do
		{
			if (${convTypes[${i}].Find[Interview]})
			{
				convTypes:Remove[${i}]
				convTypes:Collapse
			}
			i:Inc
		}
		while ${convTypes[${i}](exists)}
	}
	if ${dipNPCs[${Return}].Convince}
	{
		UIElement[Convince@Options@DipTabs@Diplo]:SetChecked
		convTypes:Insert[Convince]
	}
	else
	{
		UIElement[Convince@Options@DipTabs@Diplo]:UnsetChecked
		i:Set[1]
		do
		{
			if (${convTypes[${i}].Find[Convince]})
			{
				convTypes:Remove[${i}]
				convTypes:Collapse
			}
			i:Inc
		}
		while ${convTypes[${i}](exists)}
	}
	if ${dipNPCs[${Return}].Gossip}
	{
		UIElement[Gossip@Options@DipTabs@Diplo]:SetChecked
		convTypes:Insert[Gossip]
	}
	else
	{
		UIElement[Gossip@Options@DipTabs@Diplo]:UnsetChecked
		i:Set[1]
		do
		{
			if (${convTypes[${i}].Find[Gossip]})
			{
				convTypes:Remove[${i}]
				convTypes:Collapse
			}
			i:Inc
		}
		while ${convTypes[${i}](exists)}
	}
	if ${dipNPCs[${Return}].Entertain}
	{
		UIElement[Entertain@Options@DipTabs@Diplo]:SetChecked
		convTypes:Insert[Entertain]
	}
	else
	{
		UIElement[Entertain@Options@DipTabs@Diplo]:UnsetChecked
		i:Set[1]
		do
		{
			if (${convTypes[${i}].Find[Entertain]})
			{
				convTypes:Remove[${i}]
				convTypes:Collapse
			}
			i:Inc
		}
		while ${convTypes[${i}](exists)}
	}
}

atom(global) carddelayToggle()
{
	if ${cardDelay}
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
	EchoIt "Variable Dump"
	EchoIt "needNewNPC: ${needNewNPC} ## parleyDone: ${parleyDone} ## dipisMapping: ${dipisMapping}"
	EchoIt "dipisPaused: ${dipisPaused} ## isMoving ${isMoving} ## curNPC ${curNPC} ## endScript: ${endScript} ## fullAuto: ${fullAuto}"
	EchoIt "boolFace: ${boolFace} ## maxwait: ${maxWait} ## minWait: ${minWait} ## ourTurn: ${ourTurn} ## cardDelay ${cardDelay}"
	EchoIt "currentParleyType: ${currentParleyType} ## InParley: ${VG.IsInParlay} ## DialogPoints: ${Parlay.DialogPoints}"
}

atom(global) delayChange(string Delay)
{
	if ${Delay.Equal[Min]}
	{
		if ${UIElement[MinDelay@Options@DipTabs@Diplo].Value} >= ${UIElement[MaxDelay@Options@DipTabs@Diplo].Value} && ${UIElement[MaxDelay@Options@DipTabs@Diplo].Value} != 0
		{
			UIElement[MinDelay@Options@DipTabs@Diplo]:SetValue[${Math.Calc[${UIElement[MaxDelay@Options@DipTabs@Diplo].Value}-1]}]
		}
		minWait:Set[${UIElement[MinDelay@Options@DipTabs@Diplo].Value}]
	}
	else
	{
		if ${UIElement[MaxDelay@Options@DipTabs@Diplo].Value} <= ${UIElement[MinDelay@Options@DipTabs@Diplo].Value}
		{
			UIElement[MaxDelay@Options@DipTabs@Diplo]:SetValue[${Math.Calc[${UIElement[MinDelay@Options@DipTabs@Diplo].Value}+1]}]
		}
		maxWait:Set[${UIElement[MaxDelay@Options@DipTabs@Diplo].Value}]
	}
}

atom(script) EchoIt(string aText)
{
	if ${debug}
	{
		echo "[${Time}][Dip] ${aText}"
	}
	Redirect -append "${Output}" echo "[${Time}][Dip]: ${aText}"
}

function FaceTarget()
{
	variable int i = ${Math.Calc[20-${Math.Rand[40]}]}
	;; face only if target exists
	if ${boolFace} && ${Pawn[id,${dipNPCs[${curNPC}].ID}](exists)}
	{
		CalculateAngles
		if ${AngleDiffAbs} > 90
		{
			EchoIt "Facing within ${i} degrees of ${Me.Target.Name}"
			VG:ExecBinding[turnright,release]
			VG:ExecBinding[turnleft,release]
			if ${AngleDiff}>0
			{
				VG:ExecBinding[turnright]
				while ${AngleDiff} > ${i}
				{
					CalculateAngles
				}
				VG:ExecBinding[turnright,release]
				return
			}
			if ${AngleDiff}<0
			{
				VG:ExecBinding[turnleft]
				while ${AngleDiff} < ${i}
				{
					CalculateAngles
				}
				VG:ExecBinding[turnleft,release]
				return
			}
			VG:ExecBinding[turnright,release]
			VG:ExecBinding[turnleft,release]
		}
	}
}

atom(script) CalculateAngles()
{
	if ${Me.Target(exists)}
	{
		variable float temp1 = ${Math.Calc[${Me.Y} - ${Pawn[id,${dipNPCs[${curNPC}].ID}].Y}]}
		variable float temp2 = ${Math.Calc[${Me.X} - ${Pawn[id,${dipNPCs[${curNPC}].ID}].X}]}
		variable float result = ${Math.Calc[${Math.Atan[${temp1},${temp2}]} - 90]}
		
		result:Set[${Math.Calc[${result} + (${result} < 0) * 360]}]
		result:Set[${Math.Calc[${result} - ${Me.Heading}]}]
		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		AngleDiff:Set[${result}]
		AngleDiffAbs:Set[${Math.Abs[${result}]}]
	}
	else
	{
		AngleDiff:Set[0]
		AngleDiffAbs:Set[0]
	}
}

