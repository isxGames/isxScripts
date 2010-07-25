;-------------------------------------------------------
; VG-BM.iss Version 1.0 Updated: 2010/05/13 by Zandros
;-------------------------------------------------------
;
;===================================================
;===              INCLUDES                      ====
;===================================================
;; Routines
#include ./VG-BM/Includes/AttackTarget.iss
#include ./VG-BM/Includes/AutoRepair.iss
#include ./VG-BM/Includes/Check4Immunites.iss
#include ./VG-BM/Includes/Follow.iss
#include ./VG-BM/Includes/HealWounded.iss
#include ./VG-BM/Includes/RemoveEnchantment.iss
#include ./VG-BM/Includes/ScanAreaToBuff.iss
#include ./VG-BM/Includes/FindGroupMembers.iss
;; Objects
#include ./VG-BM/Objects/Obj_Face.iss
#include ./VG-BM/Objects/Obj_Move.iss
;;#include ./VG-BM/Objects/Obj_Health.iss
;
;===================================================
;===               DEFINES                      ====
;===================================================
#define ALARM "${Script.CurrentDirectory}/ping.wav"
;
;===================================================
;===           DEFINE OUR OBJECTIVES            ====
;===================================================
variable obj_Face Face
variable obj_Move Move
;variable obj_Health Health
;
;===================================================
;===         VARIABLES USED BY UI               ====
;===================================================
variable bool isPaused = TRUE
variable bool isRunning = TRUE
variable string CurrentAction = "Loading Variables"
variable string TargetsTarget = "No Target"
;;Main
variable string Tank
variable string CombatForm
variable string NonCombatForm
variable bool doLifeTaps = TRUE
variable bool doDots = TRUE
variable bool doAE = FALSE
variable bool doVitalHeals = TRUE
variable bool doEnchantments = TRUE
variable bool doFaceSlow = TRUE
variable bool doLootAll = FALSE
variable bool doFullThrottle = TRUE
;;Attack
variable bool doDespoil = TRUE
variable bool doEntwiningVein = TRUE
variable bool doBloodthinner = TRUE
variable bool doBurstingCyst = FALSE
variable bool doUnionOfBlood = TRUE
variable bool doExplodingCyst = TRUE
variable bool doBloodLettingRitual = TRUE
variable bool doExsanguinate = TRUE
variable bool doBloodTribute = TRUE
variable bool doFleshRend = FALSE
variable bool doBloodSpray = FALSE
variable bool doScarletRitual = FALSE
variable bool doSeveringRitual = FALSE
variable int StartAttack = 99
;;Heal
variable int AttackHealRatio = 60
variable bool doHealGroupOnly = FALSE
;;Misc
variable bool doFollow = FALSE
variable string FollowName = "No name set"
variable int64 FollowID = 0
variable string StartFollowText
variable string StopFollowText
variable string KillLevitationText
variable string BuffEveryoneText
;;Stats
variable int ParseDamage = 0
variable int DPS = 0
variable int DamageDone = 0
variable int CRIT = 0
variable int EPIC = 0
variable int tdLifetaps = 0
variable int tdBurstingCyst = 0
variable int tdUnionOfBlood = 0
variable int tdExplodingCyst = 0
variable int tdBloodLettingRitual = 0
variable int tdSeveringRitual = 0
variable int tdScarletRitual = 0
variable int tdExsanguinate = 0
variable int tdBloodTribute = 0
variable int tdFleshRend = 0
variable int tdBloodSpray = 0
;;About
variable string Version = "1.0"
;; Other toggles
variable bool doBuffs = FALSE
variable bool doDissolve = TRUE
variable bool doMetamorphism = TRUE
variable bool doAcceptRez = TRUE
variable bool doAcceptGroupInvite = TRUE
;
;===================================================
;===       VARIABLES USED BY SCRIPT             ====
;===================================================
variable bool doEcho = TRUE
variable int i = 0
variable int low = 0
variable int GroupNumber = 0
variable int SpellCounter = 0
variable int StartAttackTime = 0
variable int EndAttackTime = 0
variable int TimeFought = 0
variable bool ResetParse = TRUE
variable bool doRepair = TRUE
variable bool doForm = TRUE
variable bool FURIOUS = FALSE
variable bool doCounters = TRUE
variable int LastDowntimeCall=${Script.RunningTime}
variable int NextUpdateDisplay = ${Script.RunningTime}
variable bool doDisEnchantDelay = FALSE
variable bool doTimedDeaggro = TRUE
;
;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	EchoIt "Started VG-BM Script"

	;; Set Tank based upon DTarget
	if !${Me.DTarget.ID(exists)}
	{
		Pawn[me]:Target
		wait 5
	}
	Tank:Set[${Me.DTarget.Name}]

	;; Load our Settings
	LoadXMLSettings	

	;; Reload the UI
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-BM.xml"

	wait 10

	;; Setup and Declare Abilities
	;; === CHAINS ===
	SetHighestAbility "Exsanguinate" "Exsanguinate"
	SetHighestAbility "BloodTribute" "Blood Tribute"
	SetHighestAbility "FleshRend" "Flesh Rend"
	SetHighestAbility "BloodSpray" "Blood Spray"
	;; === COUNTERS ===
	SetHighestAbility "Dissolve" "Dissolve"
	SetHighestAbility "Metamorphism" "Metamorphism"
	;; === DOTS ===
	SetHighestAbility "BurstingCyst" "Bursting Cyst"
	SetHighestAbility "UnionOfBlood" "Union of Blood"
	SetHighestAbility "ExplodingCyst" "Exploding Cyst"
	SetHighestAbility "BloodLettingRitual" "Blood Letting Ritual"
	;; === AE ===
	SetHighestAbility "SeveringRitual" "Severing Ritual"
	;; === LIFETAPS ===
	SetHighestAbility "Despoil" "Despoil"
	SetHighestAbility "EntwiningVein" "Entwining Vein"
	SetHighestAbility "Bloodthinner" "Bloodthinner"
	;; === NUKE/FINISHER ===
	SetHighestAbility "ScarletRitual" "Scarlet Ritual"
	;; === HEALS ===
	SetHighestAbility "InfuseHealth" "Infuse Health"
	SetHighestAbility "BloodGift" "Blood Gift"
	SetHighestAbility "PhysicalTransmutation" "Physical Transmutation"
	SetHighestAbility "RecoveringBurst" "Recovering Burst"
	SetHighestAbility "SuperiorRecoveringBurst" "Superior Recovering Burst"
	
	;; === HOTs ===
	SetHighestAbility "FleshMendersRitual" "Flesh Mender's Ritual"
	SetHighestAbility "TransfusionOfSerak" "Transfusion of Serak"
	;; === BUFFS ===
	SetHighestAbility "BloodFeast" "Blood Feast"
	SetHighestAbility "SeraksMantle" "Serak's Mantle"
	SetHighestAbility "HealthGraft" "Health Graft"
	SetHighestAbility "SeraksAugmentation" "Serak's Augmentation"
	SetHighestAbility "Vitalize" "Vitalize"
	SetHighestAbility "MentalInfusion" "Mental Infusion"
	SetHighestAbility "CerebralGraft" "Cerebral Graft"
	SetHighestAbility "LifeGraft" "Life Graft"
	SetHighestAbility "MentalStimulation" "Mental Stimulation"
	SetHighestAbility "Regeneration" "Regeneration"
	SetHighestAbility "FavorOfTheLifeGiver" "Favor of the Life Giver"
	SetHighestAbility "ConstructsAugmentation" "Construct's Augmentation"
	;; === MISC ===
	SetHighestAbility "MentalTransmutation" "Mental Transmutation"
	SetHighestAbility "LifeHusk" "Life Husk"
	SetHighestAbility "ShelteringRune" "Sheltering Rune"
	SetHighestAbility "StripEnchantment" "Strip Enchantment"
	SetHighestAbility "RitualOfAwakening" "Ritual of Awakening"
	SetHighestAbility "Numb" "Numb"
	
	;; Turn on our event monitors
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatText]
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	Event[OnFrame]:AttachAtom[UpdateDisplay]
	Event[VG_onGroupMemberCountChange]:AttachAtom[OnGroupMemberCountChange]
	Event[VG_onGroupMemberBooted]:AttachAtom[OnGroupMemberCountChange]
	Event[VG_onGroupMemberAdded]:AttachAtom[OnGroupMemberCountChange]
	Event[VG_onGroupJoined]:AttachAtom[OnGroupMemberCountChange]
	Event[VG_onGroupFormed]:AttachAtom[OnGroupMemberCountChange]
	Event[VG_onGroupDisbanded]:AttachAtom[OnGroupMemberCountChange]
	Event[VG_onGroupBooted]:AttachAtom[OnGroupMemberCountChange]

	if !${Me.Ability[${BloodSpray}](exists)}
	{
		doBloodSpray:Set[FALSE]
		UIElement[doBloodSpray@Attack@Tabs@VG-BM]:UnsetChecked
		UIElement[doBloodSpray@Attack@Tabs@VG-BM]:Hide
		UIElement[doFleshRend@Attack@Tabs@VG-BM]:Show

		;UIElement[doFleshRend@Attack@Tabs@VG-BM]:SetChecked
	}
	else
	{
		doFleshRend:Set[FALSE]
		UIElement[doFleshRend@Attack@Tabs@VG-BM]:UnsetChecked
		UIElement[doFleshRend@Attack@Tabs@VG-BM]:Hide
		UIElement[doBloodSpray@Attack@Tabs@VG-BM]:Show

		;UIElement[doBloodSpray@Attack@Tabs@VG-BM]:SetChecked
	}
	
	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		;; Wait until we are ready to cast and use an ability
		if ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			;; Update our current action
			if ${Me.IsCasting}
			{
				CurrentAction:Set[Casting ${Me.Casting}]
			}
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
			;LastDowntimeCall:Set[${Script.RunningTime}]
		}
		else
		{
			CurrentAction:Set[Waiting]
		}

		;; Execute any queued commands
		if ${QueuedCommands}
		{
			ExecuteQueued
			FlushQueued
		}

		;; Find our group members
		call FindGroupMembers	
		
		;; Take down that pesky POTA barrier
		call OpenPotaBarrier

		;; Be sure to switch out of incorrect form
		if !${Me.InCombat}
		{
			call ChangeForm
		}

		waitframe
		waitframe
		
		if !${isPaused} 
		{
			;; Important routines we want called at all times
			call CriticalRoutines

			;echo LastDowntimeCall=${LastDowntimeCall}, doFullThrottle=${doFullThrottle}
			
			;; Execute main routines
			if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${LastDowntimeCall}]}/1000]}>2 || ${doFullThrottle}
			{
				call MainRoutines
				LastDowntimeCall:Set[${Script.RunningTime}]
			}
		}
		else
		{
			wait 2
		}
	}
}

;===================================================
;===           CRITICAL ROUTINES                ====
;===================================================
function CriticalRoutines()
{
	if ${Me.Target(exists)} && !${Me.Target.Type.Equal[Corpse]} && !${Me.Target.IsDead}
	{
		call TargetOnMe
		call RemoveEnchantment
		call HandleChains		
	}

	;; Clear our Target
	call ClearTargets
}

;===================================================
;=== CALLED ONCE EVERY SECOND AFTER ANY ACTIONS ====
;===================================================
function MainRoutines()
{
	;; Auto Accept Group Invites
	call GroupInviteAccept
	
	;; Follow our Tank
	call Follow

	;; Sweet, repair our equipment whether we need to or not
	call AutoRepair
	
	;; Update our current action
	CurrentAction:Set[Waiting]
	
;; ******************************************************************
;; *** We need to set our DTarget to group member with lowest health!
;; ******************************************************************

	;; use our info if we are not in a group
	if !${Me.IsGrouped}
	{
		GroupNumber:Set[0]
		low:Set[${Me.HealthPct}]
	}

	;; we are in a group so lets find the member with lowest health
	if ${Me.IsGrouped}
	{
		;; Set our variables
		GroupNumber:Set[0]
		low:Set[100]

		;; Scan only members identified in our group
		if ${doHealGroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
				{
					if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
					{
						if ${Group[${i}].Distance}<30 && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
						{
							GroupNumber:Set[${i}]
							low:Set[${Group[${i}].Health}]
						}
					}
				}
			}
		}

		;; Scan everyone
		if !${doHealGroupOnly}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
				{
					if ${Group[${i}].Distance}<30 && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
					{
						GroupNumber:Set[${i}]
						low:Set[${Group[${i}].Health}]
					}
				}
			}
		}
	}


	if ${GroupNumber}
	{
		if ${Group[${GroupNumber}].Health}<90
		{
			;; set DTarget to member with lowest health
			Pawn[id,${Group[${GroupNumber}].ID}]:Target
			wait 1
		}
		else
		{
			if ${Me.Target(exists)}
			{
				;; we are in a safe zone so set DTarget to our target's target
				VGExecute "/assistoffensive"
				waitframe
			}
		}
		
	}

	;; check to see if we need to do any vital heals
	if ${doVitalHeals}
	{
		if ${low}<${AttackHealRatio}
		{
			;vgecho [${Time}] Healing [#${GroupNumber}] ${Group[${GroupNumber}].Name}
			call HealWounded
			if ${Return}
			{
				return
			}
		}
	}

	;; Regenerate our Energy
	call RegenerateEnergy	
	if ${Return}
	{
		return
	}

	;; Attack our Target!
	call AttackTarget
}

;===================================================
;===          TARGET ON ME                      ====
;===================================================
function TargetOnMe()
{
	if ${Me.IsGrouped}
	{
		if ${Me.ToT.Name.Find[${Me.FName}]}
		{
			if ${Me.Target.Distance}<10
			{
				if ${Me.ToT.Name.Find[${Me.FName}]}
				{
					;; get our barrier up!
					if !${Me.Effect[${LifeHusk}](exists)}
					{
						call UseAbility "${LifeHusk}"
						if ${Return}
						{
							vgecho "Casted Life Husk"
							return
						}
					}
					
					;; get our secondary barrier up if need be
					if !${Me.Effect[${LifeHusk}](exists)} && !${Me.Effect[${ShelteringRune}](exists)}
					{
						call UseAbility "${ShelteringRune}"
						if ${Return}
						{
							vgecho "Casted Sheltering Rune"
							return
						}
					}
				}
			}
		}
	}
}
		
;===================================================
;===          Regenerate Energy                ====
;===================================================
function:bool RegenerateEnergy()
{
	if ${Me.EnergyPct}<80 && ${Me.HealthPct}>80
	{
		wait 5 ${Me.Ability["Torch"].IsReady}
		call UseAbility "${MentalTransmutation}"
		if ${Return}
		{
			return TRUE
		}
	}
	return FALSE
}	

;===================================================
;===          GROUP INVITE ACCEPT               ====
;===================================================
function GroupInviteAccept()
{
	if ${Me.GroupInvitePending}
	{
		if ${doAcceptGroupInvite}
		{
			vgexecute /groupacceptinvite
		}
	}
} 

;===================================================
;===     CALLED ROUTINE VIA ATOM - BUMP         ====
;===================================================
function OpenDoor()
{
	VG:ExecBinding[UseDoorEtc]
}

;===================================================
;===       DROP POTA BARRIER                    ====
;===================================================
function OpenPotaBarrier()
{
	;;  - drop that Pota barrier!
	if ${Pawn[Kheolim's Barrier](exists)}
	{
		if ${Pawn[Kheolim's Barrier].Distance}<3
		{
			Pawn[Kheolim's Barrier]:DoubleClick
		}
	}
}

;===================================================
;===       CHANGE TO CORRECT FORM               ====
;===================================================
function ChangeForm()
{
	if !${Me.InCombat} && !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
	{
		while !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
		{
			if ${doForm} && !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
			{
				Me.Form[${NonCombatForm}]:ChangeTo
				TimedCommand 20 Script[VG-BM].Variable[doForm]:Set[TRUE]
				doForm:Set[FALSE]
			}
		}
		EchoIt "** New Form = ${Me.CurrentForm.Name}"
	}
	;; Ensure we are in combat form
	if ${Me.InCombat} && !${Me.CurrentForm.Name.Equal[${CombatForm}]}
	{
		while !${Me.CurrentForm.Name.Equal[${CombatForm}]}
		{
			if ${doForm} && !${Me.CurrentForm.Name.Equal[${CombatForm}]}
			{
				Me.Form[${CombatForm}]:ChangeTo
				TimedCommand 20 Script[VG-BM].Variable[doForm]:Set[TRUE]
				doForm:Set[FALSE]
			}
		}
		EchoIt "** New Form = ${Me.CurrentForm.Name}"
	}
}

;===================================================
;===            HANDLE CHAINS                   ====
;===================================================
function:bool HandleChains()
{

	;-------------------------------------------
	; Return if not in Combat
	;-------------------------------------------
	if !${Me.InCombat}
	{
		return
	}

	;-------------------------------------------
	; Do our Chains - Toggle doDots for DPS
	;-------------------------------------------
	if ${low}>80
	{
		if ${doExsanguinate}
		{
			wait 1 ${Me.Ability[${Exsanguinate}].IsReady}
			if ${Me.Ability[${Exsanguinate}].TriggeredCountdown}>0 && !${Me.TargetMyDebuff[${Exsanguinate}](exists)} && ${Me.Ability[${Exsanguinate}].IsReady}
			{
				;while ${Me.Ability[${Exsanguinate}].TriggeredCountdown}>0 && !${Me.Ability[${Exsanguinate}].IsReady}
				;{
				;	waitframe
				;}
				CurrentAction:Set[Chain ${Exsanguinate}]
				
				call UseAbility "${Exsanguinate}"
				if ${Return}
				{
					return
				}
			}
		}

		if ${doBloodSpray}
		{
			wait 1 ${Me.Ability[${BloodSpray}].IsReady}
			if ${Me.Ability[${BloodSpray}].TriggeredCountdown}>0 && !${Me.TargetMyDebuff[${BloodSpray}](exists)} && ${Me.Ability[${BloodSpray}].IsReady}
			{
				;while ${Me.Ability[${BloodSpray}].TriggeredCountdown}>0 && !${Me.Ability[${BloodSpray}].IsReady}
				;{
				;	waitframe
				;}
				CurrentAction:Set[Chain ${BloodSpray}]
				
				call UseAbility "${BloodSpray}"
				if ${Return}
				{
					return
				}
			}
		}

		if ${doFleshRend}
		{
			wait 1 ${Me.Ability[${FleshRend}].IsReady}
			if ${Me.Ability[${FleshRend}].TriggeredCountdown}>0 && !${Me.TargetMyDebuff[${FleshRend}](exists)}
			{
				;while ${Me.Ability[${FleshRend}].TriggeredCountdown}>0 && !${Me.Ability[${FleshRend}].IsReady}
				;{
				;	waitframe
				;}
				CurrentAction:Set[Chain ${FleshRend}]

				call UseAbility "${FleshRend}"
				if ${Return}
				{
					return
				}
			}
		}
	}

	;; Healing Crit is up... 
	if ${doBloodTribute}
	{
		;wait 5 ${Me.Ability[${BloodTribute}].TriggeredCountdown}
		if ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0
		{
			while ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0 && !${Me.Ability[${BloodTribute}].IsReady}
			{
				waitframe
			}
			
			while ${Me.IsGrouped} && ${Me.Target(exists)} && ${Me.Ability[${BloodTribute}].TriggeredCountdown}>2 && !${doDots}
			{
				low:Set[90]
				GroupNumber:Set[0]
				for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
				{
					if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
					{
						if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
						{
							if ${Group[${i}].Distance}<30 && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								GroupNumber:Set[${i}]
								low:Set[${Group[${i}].Health}]
							}
						}
					}
				}
				if ${GroupNumber} && ${Group[${GroupNumber}].Health}<90
				{
					vgecho [${Time}] Blood Tribute [#${GroupNumber}] [${Group[${GroupNumber}].Health}] ${Group[${GroupNumber}].Name}
					break
				}
			}

			CurrentAction:Set[Chain ${BloodTribute}]

			call UseAbility "${BloodTribute}"
			if ${Return}
			{
				return
			}
		}
	}
}

;===================================================
;===       CLEAR TARGET IF TARGET IS DEAD       ====
;===================================================
function ClearTargets()
{
	if ${Me.Target(exists)}
	{
		;; loot everything
		if ${doLootAll}
		{
			if ${Me.TargetHealth}<5
			{
				call LootAll
			}
		}

		;; execute only if target is a corpse
		if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.IsDead}
		{
			;; Stop melee attacks
			if ${GV[bool,bIsAutoAttacking]}
			{
				Me.Ability[Auto Attack]:Use
			}

			;; looting??
			while ${Me.IsLooting}
			{
				CurrentAction:Set[Looting]
				waitframe
			}
			
			;; harvesting??
			while ${GV[bool,bHarvesting]} && ${Me.Target(exists)}
			{
				CurrentAction:Set[Harvesting]
				waitframe
			}
			
			;; loot everything
			if ${doLootAll}
			{
				call LootAll
			}
			
			;; clear target
			CurrentAction:Set[Clearing Targets]
			VGExecute "/cleartargets"
			call ChangeForm
			EchoIt "---------------------------------"

			;; wait long enough
			wait 5
			
			;; update stats
			FURIOUS:Set[FALSE]
			SpellCounter:Set[0]
		}
	}
	else
	{
		;; update display
		TargetsTarget:Set[No Target]
		TargetImmunity:Set[No Target]
	}

}

;===================================================
;===              LOOT ALL ON CORPSE            ====
;===================================================
function LootAll()
{
	if ${Me.Target.Distance}>4
		return

	CurrentAction:Set[Looting]
	EchoIt "Looting: ${Me.Target.Name}"

	;	if ${Me.Target(exists)}
	;		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4

	;; Start Loot Window
	Loot:BeginLooting
	if ${VG.FPS}<10
	{
		wait 2
	}
	else
	{
		wait 1
	}

	if !${Loot.NumItems}
		wait 2
			
	;; Begin Looting
	if ${Loot.NumItems}
	{
		;; Try looting 1 item at a time
		variable int a
		for ( a:Set[1] ; ${a}<=${Loot.NumItems} ; a:Inc )
		{
			EchoIt "*Looting ${Loot.Item[${a}]}"
			Loot.Item[${a}]:Loot
		}
			
		;; Then loot everything
		Loot:LootAll
	}

	;; End Looting
	if ${Me.IsLooting}
	{
		Loot:EndLooting
	}

	;; Loot whatever
	;VGExecute /loot
}

;===================================================
;===              USE AN ABILITY                ====
;===================================================
function:bool UseAbility(string ABILITY, TEXT=" ")
{
	;; does ability exist?
	if !${Me.Ability[${ABILITY}](exists)}
	{
		EchoIt "${ABILITY} does not exist"
		return FALSE
	}
	
	CurrentAction:Set[Not Ready]
	wait 10 ${Me.Ability[${ABILITY}].IsReady}
	CurrentAction:Set[Waiting]

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; Check if mob is immune
		call Check4Immunites "${ABILITY}"
		if ${Return}
		{
			EchoIt "Immune to ${ABILITY}"
			return FALSE
		}
	
		;; is mob immune or healed by ability
		;;if ${LearnedImmunitiesList.Element["${Me.Target.Name}"].Equal[${ABILITY}]}
		;;	return FALSE

		;; does ability exist in my buff?
		;if ${Me.Effect[${ABILITY}](exists)}
		;{
		;	return FALSE
		;}
	
		;; are we waiting to use ability?
		if ${Me.Ability[${ABILITY}].TimeRemaining}>0
		{
			EchoIt "TimeRemaining - ${ABILITY}"
			return FALSE
		}
	
		;; do we have energy to use ability?
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		
		;; Check if we got enough BloodUinion
		if ${Me.Ability[${ABILITY}].BloodUnionRequired} > ${Me.BloodUnion}
		{
			return FALSE
		}
		
		;; is target in range?
		if !${Me.Ability[${ABILITY}].TargetInRange}
		{
			EchoIt "Target not in range for ${ABILITY}"
			return FALSE
		}
		
		;; Face our target!
		if ${doFaceSlow}
		{
			if ${Me.Target(exists)} && ${Pawn[name,${Tank}].CombatState}>0 && ${Me.Target.Distance}<30
			{
				Face:Pawn[${Me.Target.ID}]
			}
		}
		
		;; execute ability
		EchoIt "UseAbility - ${ABILITY} ${TEXT}"
		CurrentAction:Set[Casting ${ABILITY}]
		Me.Ability[${ABILITY}]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
		return TRUE
	}
	return FALSE
}		

;===================================================
;===  Scan area for my tombstone and loot it    ====
;===================================================
function LootMyTombstone()
{
	;; Accept that rez
	VGExecute "/rezaccept"

	;; allow time to relocate after accepting rez
	wait 20
	
	;; clear our target
	VGExecute "/cleartargets"
	wait 5 !${Me.Target(exists)}
	
	;; target our nearest corpse
	VGExecute "/targetmynearestcorpse"
	wait 20 ${Me.Target(exists)}
	
	;; drag it closer if we are still out of range
	if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<21
	{
		VGExecute "/corpsedrag"
		wait 10 ${Me.Target.Distance}<=5
	}
	
	;; loot our tombstone and clear our target
	VGExecute "/lootall"
	VGExecute "/cleartargets"
	wait 5 !${Me.Target(exists)}
	
	EchoIt "Looted my tombstone"
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;===================================================
;===     ATOM - CALLED AT END OF SCRIPT         ====
;===================================================
function atexit()
{
	;; Save our Settings
	SaveXMLSettings	

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/VG-BM.xml"
	
	;; Say we are done
	EchoIt "Stopped VG-BM Script"
}

;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][VG-BM]: ${aText}"
	}
}

;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{	
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}

;===================================================
;===    ATOM - OPEN A DOOR THAT YOU BUMPED      ====
;===================================================
atom Bump(string aObstacleActorName, float fX_Offset, float fY_Offset, float fZ_Offset)
{
	if (${aObstacleActorName.Find[Mover]})
	{
		Script[VG-BM]:QueueCommand[call OpenDoor]
	}
}

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
;===================================================
atom(script) SetHighestAbility(string AbilityVariable, string AbilityName)
{
	declare L int local 9
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[9] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]
	AbilityLevels[9]:Set[IX]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Find highest Ability level - based upon current level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${Me.Level}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt " --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	script "None"
	return
}

;===================================================
;===     ATOM - Load Variables from XML         ====
;===================================================
atom(script) LoadXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-BM/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-BM_SSR
	
	;;Load Lavish Settings 
	LavishSettings[VG-BM]:Clear
	LavishSettings:AddSet[VG-BM]
	LavishSettings[VG-BM]:AddSet[MySettings]
	LavishSettings[VG-BM]:Import[${savePath}/MySettings.xml]	
	VG-BM_SSR:Set[${LavishSettings[VG-BM].FindSet[MySettings]}]

	
	;;Set values for MySettings
	StartAttack:Set[${VG-BM_SSR.FindSetting[StartAttack,99]}]
	doLifeTaps:Set[${VG-BM_SSR.FindSetting[doLifeTaps,TRUE]}]
	doDots:Set[${VG-BM_SSR.FindSetting[doDots,FALSE]}]
	doAE:Set[${VG-BM_SSR.FindSetting[doAE,FALSE]}]
	doBuffs:Set[${VG-BM_SSR.FindSetting[doBuffs,FALSE]}]
	doFaceSlow:Set[${VG-BM_SSR.FindSetting[doFaceSlow,TRUE]}]
	doLootAll:Set[${VG-BM_SSR.FindSetting[doLootAll,FALSE]}]
	doEnchantments:Set[${VG-BM_SSR.FindSetting[doEnchantments,FALSE]}]
	doVitalHeals:Set[${VG-BM_SSR.FindSetting[doVitalHeals,TRUE]}]
	doFullThrottle:Set[${VG-BM_SSR.FindSetting[doFullThrottle,TRUE]}]
	
	doExsanguinate:Set[${VG-BM_SSR.FindSetting[doExsanguinate,TRUE]}]
	doBloodTribute:Set[${VG-BM_SSR.FindSetting[doBloodTribute,TRUE]}]
	doFleshRend:Set[${VG-BM_SSR.FindSetting[doFleshRend,TRUE]}]
	doBloodSpray:Set[${VG-BM_SSR.FindSetting[doBloodSpray,TRUE]}]
	doDissolve:Set[${VG-BM_SSR.FindSetting[doDissolve,TRUE]}]
	doMetamorphism:Set[${VG-BM_SSR.FindSetting[doMetamorphism,TRUE]}]

	doBurstingCyst:Set[${VG-BM_SSR.FindSetting[doBurstingCyst,FALSE]}]
	doUnionOfBlood:Set[${VG-BM_SSR.FindSetting[doUnionOfBlood,TRUE]}]
	doExplodingCyst:Set[${VG-BM_SSR.FindSetting[doExplodingCyst,TRUE]}]
	doBloodLettingRitual:Set[${VG-BM_SSR.FindSetting[doBloodLettingRitual,TRUE]}]

	doSeveringRitual:Set[${VG-BM_SSR.FindSetting[doSeveringRitual,FALSE]}]

	doDespoil:Set[${VG-BM_SSR.FindSetting[doDespoil,TRUE]}]
	doEntwiningVein:Set[${VG-BM_SSR.FindSetting[doEntwiningVein,TRUE]}]
	doBloodthinner:Set[${VG-BM_SSR.FindSetting[doBloodthinner,TRUE]}]

	doScarletRitual:Set[${VG-BM_SSR.FindSetting[doScarletRitual,FALSE]}]
	
	StartFollowText:Set[${VG-BM_SSR.FindSetting[StartFollowText,""]}]
	StopFollowText:Set[${VG-BM_SSR.FindSetting[StopFollowText,""]}]
	KillLevitationText:Set[${VG-BM_SSR.FindSetting[KillLevitationText,""]}]
	BuffEveryoneText:Set[${VG-BM_SSR.FindSetting[BuffEveryoneText,""]}]
}

;===================================================
;===      ATOM - Save Variables to XML          ====
;===================================================
atom(script) SaveXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-BM/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-BM_SSR
	
	;; Load Lavish Settings 
	LavishSettings[VG-BM]:Clear
	LavishSettings:AddSet[VG-BM]
	LavishSettings[VG-BM]:AddSet[MySettings]
	LavishSettings[VG-BM]:Import[${savePath}/MySettings.xml]	
	VG-BM_SSR:Set[${LavishSettings[VG-BM].FindSet[MySettings]}]
	
	;; Save MySettings
	VG-BM_SSR:AddSetting[StartAttack,${StartAttack}]
	VG-BM_SSR:AddSetting[doLifeTaps,${doLifeTaps}]
	VG-BM_SSR:AddSetting[doDots,${doDots}]
	VG-BM_SSR:AddSetting[doAE,${doAE}]
	VG-BM_SSR:AddSetting[doBuffs,${doBuffs}]
	VG-BM_SSR:AddSetting[doFaceSlow,${doFaceSlow}]
	VG-BM_SSR:AddSetting[doLootAll,${doLootAll}]
	VG-BM_SSR:AddSetting[doEnchantments,${doEnchantments}]
	VG-BM_SSR:AddSetting[doVitalHeals,${doVitalHeals}]
	VG-BM_SSR:AddSetting[doFullThrottle,${doFullThrottle}]
	
	VG-BM_SSR:AddSetting[doExsanguinate,${doExsanguinate}]
	VG-BM_SSR:AddSetting[doBloodTribute,${doBloodTribute}]
	VG-BM_SSR:AddSetting[doFleshRend,${doFleshRend}]
	VG-BM_SSR:AddSetting[doBloodSpray,${doBloodSpray}]
	VG-BM_SSR:AddSetting[doDissolve,${doDissolve}]
	VG-BM_SSR:AddSetting[doMetamorphism,${doMetamorphism}]
	
	VG-BM_SSR:AddSetting[doBurstingCyst,${doBurstingCyst}]
	VG-BM_SSR:AddSetting[doUnionOfBlood,${doUnionOfBlood}]
	VG-BM_SSR:AddSetting[doExplodingCyst,${doExplodingCyst}]
	VG-BM_SSR:AddSetting[doBloodLettingRitual,${doBloodLettingRitual}]
	
	VG-BM_SSR:AddSetting[doSeveringRitual,${doSeveringRitual}]

	VG-BM_SSR:AddSetting[doDespoil,${doDespoil}]
	VG-BM_SSR:AddSetting[doEntwiningVein,${doEntwiningVein}]
	VG-BM_SSR:AddSetting[doBloodthinner,${doBloodthinner}]

	VG-BM_SSR:AddSetting[doScarletRitual,${doScarletRitual}]

	VG-BM_SSR:AddSetting[StartFollowText,${StartFollowText}]
	VG-BM_SSR:AddSetting[StopFollowText,${StopFollowText}]
	VG-BM_SSR:AddSetting[KillLevitationText,${KillLevitationText}]
	VG-BM_SSR:AddSetting[BuffEveryoneText,${BuffEveryoneText}]

	;; Save to file
	LavishSettings[VG-BM]:Export[${savePath}/MySettings.xml]
}


;===================================================
;===      ATOM - CATCH THEM COUNTERS!           ====
;===================================================
atom(script) Counters()
{
	if ${doCounters}
	{
		if ${Me.Ability[${Dissolve}].IsReady}
		{
			if ${Me.Ability[${Dissolve}].TimeRemaining}==0 || ${Me.Ability[${Dissolve}].TriggeredCountdown}>0
			{
				VGExecute "/reactioncounter 1"
				EchoIt "${Dissolve} COUNTERED ${Me.TargetCasting}"

				;; Set delay of 1 second
				TimedCommand 10 Script[VG-BM].Variable[doCounters]:Set[TRUE]
				doCounters:Set[FALSE]
				return
			}
		}
		if ${Me.Ability[${Metamorphism}].IsReady}
		{
			if ${Me.Ability[${Metamorphism}].TimeRemaining}==0 || ${Me.Ability[${Metamorphism}].TriggeredCountdown}>0
			{
				VGExecute "/reactioncounter 2"
				EchoIt "${Metamorphism} COUNTERED ${Me.TargetCasting}"

				;; Set delay of 1 second
				TimedCommand 10 Script[VG-BM].Variable[doCounters]:Set[TRUE]
				doCounters:Set[FALSE]
				return
			}
		}
	}
}

;===================================================
;===      ATOM - UPDATE OUR GUI DISPLAY         ====
;===================================================
atom(script) UpdateDisplay()
{
	;; Update once half a second
	if (${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextUpdateDisplay}]}/1000]} < .5)
	{
		return
	}
	NextUpdateDisplay:Set[${Script.RunningTime}]
	
	;; things we want to do during combat
	if ${Me.InCombat} && !${Me.Target.IsDead}
	{
		;; Catch them Counters
		Counters
	}

	;; update Target of Target
	if ${Me.Target(exists)}
	{
		temp:Set[${Me.ToT.Name}]
		if ${temp.Equal[NULL]}
		{
			TargetsTarget:Set[No Target]
		}
		else
		{
			TargetsTarget:Set[${Me.ToT.Name}]
		}
	}
	
	;; Main
	UIElement[Text-Status@VG-BM]:SetText[ Current Action:  ${CurrentAction}]
	UIElement[Text-Immune@VG-BM]:SetText[ Target's Immunity:  ${TargetImmunity}]
	UIElement[Text-TOT@VG-BM]:SetText[ Target's Target:  ${TargetsTarget}]

	;; Stats - Parser
	;;if !${Me.InCombat} && ${Me.Encounter}==0 && (${Me.Target.CombatState}==0 || ${Me.TargetHealth}>99)
	if !${Me.InCombat} && ${Me.Target.CombatState}==0
	{
		ResetParse:Set[TRUE]
	}

	UIElement[DPS@Stats@Tabs@VG-BM]:SetText[Current DPS = ${DPS}]
	UIElement[TotalDamage@Stats@Tabs@VG-BM]:SetText[Total Damage = ${DamageDone}]
	UIElement[CRIT@Stats@Tabs@VG-BM]:SetText[CRIT = ${CRIT}]
	UIElement[EPIC@Stats@Tabs@VG-BM]:SetText[EPIC = ${EPIC}]

	UIElement[tdLifetaps@Stats@Tabs@VG-BM]:SetText[Lifetaps =           ${tdLifetaps}]

	UIElement[tdBurstingCyst@Stats@Tabs@VG-BM]:SetText[BurstingCyst =    ${tdBurstingCyst}]
	UIElement[tdUnionOfBlood@Stats@Tabs@VG-BM]:SetText[UnionOfBlood =   ${tdUnionOfBlood}]
	UIElement[tdExplodingCyst@Stats@Tabs@VG-BM]:SetText[ExplodingCyst =  ${tdExplodingCyst}]
	UIElement[tdBloodLettingRitual@Stats@Tabs@VG-BM]:SetText[BloodLetRitual = ${tdBloodLettingRitual}]

	UIElement[tdFleshRend@Stats@Tabs@VG-BM]:SetText[FleshRend =      ${tdFleshRend}]
	UIElement[tdBloodSpray@Stats@Tabs@VG-BM]:SetText[BloodSpray =    ${tdBloodSpray}]
	UIElement[tdBloodTribute@Stats@Tabs@VG-BM]:SetText[BloodTribute =  ${tdBloodTribute}]
	UIElement[tdExsanguinate@Stats@Tabs@VG-BM]:SetText[Exsanguinate = ${tdExsanguinate}]

	UIElement[tdScarletRitual@Stats@Tabs@VG-BM]:SetText[ScarletRitual =  ${tdScarletRitual}]

	UIElement[tdSeveringRitual@Stats@Tabs@VG-BM]:SetText[SeverRitual =    ${tdSeveringRitual}]

	variable int MS = 0
	variable int MIN = 0
	variable int SEC = 0
	variable int TIME = 0
		
	;; Calculate total milliseconds
	MS:Set[${Math.Calc[${EndAttackTime}-${StartAttackTime}]}]
	
	if ${MS}>0
	{
		;; Calculate total seconds
		TIME:Set[${Math.Calc[(${EndAttackTime}-${StartAttackTime})/1000]}]

		;; Calculate total minutes
		MIN:Set[${Math.Calc[${TIME}/60]}]

		;; Calculate our seconds
		SEC:Set[${Math.Calc[${TIME}%60].Int}]
	}

	UIElement[TotalTime@Stats@Tabs@VG-BM]:SetText["Total Time = ${MIN.LeadingZeroes[2]} minutes, ${SEC.LeadingZeroes[2]} seconds"]

	;; Misc
	UIElement[Follow Name@Misc@Tabs@VG-BM]:SetText[Follow:  ${FollowName}]
	UIElement[PushHateTo Name@Misc@Tabs@VG-BM]:SetText[PushHateTo:  ${PushHateTo}]
	UIElement[RemoveHateFrom Name@Misc@Tabs@VG-BM]:SetText[RemoveHateFrom:  ${RemoveHateFrom}]
	
	;; Update our immunity Display
	call Check4Immunites
}

;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	;; Snap to face target
	if (${aText.Find["no line of sight to your target"]})
	{
		if ${doFace} && ${Me.Target(exists)}
		{
			face ${Math.Calc[${Me.Target.HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
		}
	}

	;; Clear target if lacking harvesting skill
	if (${aText.Find["You do not have enough skill to begin harvesting this resource"]})
	{
		if ${Me.Target(exists)}
		VGExecute /cleartargets
	}

	;; Check if target is no longer FURIOUS
	if ${ChannelNumber}==7 && ${aText.Find[is no longer FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			vgecho "FURIOUS - RESUME ATTACKING"
			FURIOUS:Set[FALSE]
		}
	}

	; Check if target went into FURIOUS - Has delays for notification
	if ${ChannelNumber}==7 && ${aText.Find[becomes FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			;; Turn on FURIOUS flag and stop attack
			vgecho "FURIOUS -- STOP ATTACKS"
			FURIOUS:Set[TRUE]

			;; Turn off attacks!
			if ${GV[bool,bIsAutoAttacking]}
			{
				Me.Ability[Auto Attack]:Use
			}
		}
	}

	;; Accept Rez
	if ${ChannelNumber}==32 && ${doAcceptRez} && ${aText.Find[is trying to resurrect you with]}
	{
		Script[VG-BM]:QueueCommand[call LootMyTombstone]
	}

	
	;; Ping us on tells or anything with our name in it
	if ${ChannelNumber}==15 && ${aText.Find[From ]}
	{
		EchoIt "${aText}"
		PlaySound ALARM
	}

	if ${aText.Find[${StartFollowText}]}
	{
		doFollow:Set[TRUE]
		UIElement[doFollow@Main@Tabs@VG-BM]:SetChecked
	}
	
	if ${aText.Find[${StopFollowText}]}
	{
		doFollow:Set[FALSE]
		UIElement[doFollow@Main@Tabs@VG-BM]:UnsetChecked
	}

	;; ${ChannelNumber}==15
	if ${aText.Find[${KillLevitationText}]}
	{
		Me.Effect[Gift of Alcipus]:Remove
		Me.Effect[Death March]:Remove
		Me.Effect[Briel's Trill of the Clouds]:Remove
		Me.Effect[Boon of Alcipus]:Remove
		Me.Effect[Mind Over Body]:Remove
	}

	if ${aText.Find[${BuffEveryoneText}]}
	{
		Script[VG-BM]:QueueCommand[call ScanAreaToBuff]
	}
}

;===================================================
;===    ATOM - Monitor Combat Text Messages     ====
;===================================================
atom CombatText(string aText, int aType)
{
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/VG-BM/Save/CombatText.txt" echo "[${Time}][${aType}][${aText}]"
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/VG-BM/Save/CombatText${aType}.txt" echo "[${Time}][${aType}][${aText}]"

	;;if ${aText.Find[heals]} || ${aText.Find[healing]} || ${aText.Find[immune]}
	if ${aText.Find[healing for]} || ${aText.Find[absorbes your]}
	{
		if ${aText.Find[${Me.Target.Name}]}
		{

			PlaySound ALARM
		
			;; Create the Save directory incase it doesn't exist
			variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-BM/Save"
			mkdir "${savePath}"

			;; dump to file
			redirect -append "${savePath}/LearnedImmunities.txt" echo "[${Time}][${aType}][${Me.Target.Name}][${aText.Token[2,">"].Token[1,"<"]}] -- [${aText}]"

			;; display the info
			echo ${Me.Target.Name} absorbed/healed/immune to ${aText.Token[2,">"].Token[1,"<"]}
			vgecho Immune: ${aText.Token[2,">"].Token[1,"<"]}
		}
	}
	
	;; Handle curses
	if ${Text.Find["Major Curse:"]} || ${Text.Find["Greater Curse:"]}
	{
		if ${Me.IsGrouped}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Text.Find[${Group[${i}].Name}]}
				{
					RemoveCurseRequest:Set[TRUE]
					Cursed:Set[${Group[${i}].Name}]
					break
				}
			}
		}
		elseif ${Text.Find[${Me.FName}]}
		{
			RemoveCurseRequest:Set[TRUE]
			Cursed:Set[${Me.FName}]
		}
	}
	
	if ${aType} == 26 && !${aText.Find[damage to You]}
	{
		if ${aText.Find[additional <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[additional <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			if ${aText.Find[Epic]}
			{
				EPIC:Set[${Math.Calc[${EPIC}+${ParseDamage}]}]
			}
			if ${aText.Find[Critical Hit]}
			{
				CRIT:Set[${Math.Calc[${CRIT}+${ParseDamage}]}]
			}
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[for <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[for <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[deals <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[deals <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[draw <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[draw <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[damage shield]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[for]}	,${aText.Length}].Token[2,r].Token[1,d]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
	}
}

;===================================================
;===    ATOM - Parser to calculate DPS          ====
;===================================================
atom(script) CalculateDPS(string aText)
{
	;; Set start timer
	if ${ResetParse}
	{
		ResetParse:Set[FALSE]
		DPS:Set[0]
		DamageDone:Set[${ParseDamage}]
		CRIT:Set[0]
		EPIC:Set[0]
		StartAttackTime:Set[${Script.RunningTime}]

		tdExsanguinate:Set[0]
		tdBloodTribute:Set[0]
		tdFleshRend:Set[0]
		tdBloodSpray:Set[0]

		tdBurstingCyst:Set[0]
		tdUnionOfBlood:Set[0]
		tdExplodingCyst:Set[0]
		tdBloodLettingRitual:Set[0]

		tdScarletRitual:Set[0]
		tdSeveringRitual:Set[0]

		tdDespoil:Set[0]
		tdLifetaps:Set[0]
		tdBloodthinner:Set[0]
	}
	
	;; Calculate and update DPS
	EndAttackTime:Set[${Script.RunningTime}]
	TimeFought:Set[${Math.Calc[${EndAttackTime}-${StartAttackTime}]}]
	if ${TimeFought}>999
	{
		DPS:Set[${Math.Calc[${DamageDone}/${Math.Calc[${TimeFought}/1000]}].Round}]
	}
	else
	{
		DPS:Set[${DamageDone}]
	}
	
	if ${aText.Find[Exsanguinate]}
	{
		tdExsanguinate:Set[${Math.Calc[${tdExsanguinate}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Blood Tribute]}
	{
		tdBloodTribute:Set[${Math.Calc[${tdBloodTribute}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Flesh Rend]}
	{
		tdFleshRend:Set[${Math.Calc[${tdFleshRend}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Blood Spray]}
	{
		tdBloodSpray:Set[${Math.Calc[${tdBloodSpray}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Bursting Cyst]}
	{
		tdBurstingCyst:Set[${Math.Calc[${tdBurstingCyst}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Union of Blood]}
	{
		tdUnionOfBlood:Set[${Math.Calc[${tdUnionOfBlood}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Exploding Cyst]}
	{
		tdExplodingCyst:Set[${Math.Calc[${tdExplodingCyst}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Blood Letting Ritual]}
	{
		tdBloodLettingRitual:Set[${Math.Calc[${tdBloodLettingRitual}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Severing Ritual]}
	{
		tdSeveringRitual:Set[${Math.Calc[${tdSeveringRitual}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Scarlet Ritual]}
	{
		tdScarletRitual:Set[${Math.Calc[${tdScarletRitual}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Despoil]}
	{
		tdLifetaps:Set[${Math.Calc[${tdLifetaps}+${ParseDamage}]}]
	}
	elseif ${aText.Left[10].Find[draw <]}
	{
		tdLifetaps:Set[${Math.Calc[${tdLifetaps}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Bloodthinner]}
	{
		tdLifetaps:Set[${Math.Calc[${tdLifetaps}+${ParseDamage}]}]
		tdBloodthinner:Set[${Math.Calc[${tdBloodthinner}+${ParseDamage}]}]
	}
}
