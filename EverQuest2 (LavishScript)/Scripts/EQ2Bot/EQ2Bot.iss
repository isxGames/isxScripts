;-----------------------------------------------------------------------------------------------
; EQ2Bot.iss Version 2.7.23 Updated: 02/03/2010 by Pygar
;
; See /InnerSpace/Scripts/EQ2Bot/EQ2BotRelease_Notes.txt for changes
;-----------------------------------------------------------------------------------------------
;
/* 	These can't be used during preprocessing (#includes, etc), not even if #defined -
	they are instantiated here for use inside functions, and to keep an easy list of paths.

	Note that Script.CurrentDirectory is NOT initialized during preprocessing, so we can't use that
	during #includes to get to the right path.  This means we're limited to loading the Script.Filename,
	which in most cases will be eq2bot (from run eq2bot/eq2bot).  Hopefully Lax will fix this in a future
	innerspace build, and if so, all paths of the form:
		${LavishScript.HomeDirectory}/Scripts/${Script.Filename}
	should be updated to
		${Script.CurrentDirectory}

	Which will enable side-by-side installation of dev and stable branches (scripts/eq2bot and scripts/eq2botdev)

	-- CyberTech
*/
variable string PATH_EQ2COMMON = "${LavishScript.HomeDirectory}/Scripts/EQ2Common"
variable string PATH_CLASS_ROUTINES = "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines"
variable string PATH_CHARACTER_CONFIG = "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Character Config"
variable string PATH_UI = "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/UI"
variable string PATH_SPELL_LIST = "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Spell List"

;
;===================================================
;===        Version Checking             ====
;===================================================
;;; /EQ2Bot/Class Routines ONLY here
;;; The spell list and GUI files for each class should be handled within the initialization of each class file.
;;; The main script, EQ2BotLib, and the primary GUI files are included in the isxeq2 patcher.
variable int Latest_AssassinVersion = 20090622
variable int Latest_BerserkerVersion = 20090616
variable int Latest_BrigandVersion = 20090618
variable int Latest_BruiserVersion = 20090623
variable int Latest_CoercerVersion = 20090616
variable int Latest_ConjurerVersion = 20090623
variable int Latest_DefilerVersion = 20090616
variable int Latest_DirgeVersion = 20090711
variable int Latest_FuryVersion = 20100130
variable int Latest_GuardianVersion = 20090616
variable int Latest_IllusionistVersion = 20090622
variable int Latest_InquisitorVersion = 20090622
variable int Latest_MonkVersion = 20090622
variable int Latest_MysticVersion = 0
variable int Latest_NecromancerVersion = 0
variable int Latest_PaladinVersion = 20090623
variable int Latest_RangerVersion = 0
variable int Latest_ShadownightVersion = 20100130
variable int Latest_SwashbucklerVersion = 20090616
variable int Latest_TemplarVersion = 20090616
variable int Latest_TroubadorVersion = 20090619
variable int Latest_WardenVersion = 20090703
variable int Latest_WarlockVersion = 20090622
variable int Latest_WizardVersion = 20090622
;===================================================
;===        Keyboard Configuration              ====
;===================================================
#includeoptional ${LavishScript.HomeDirectory}/Scripts/EQ2Common/MovementKeys.iss
#ifndef _MOVE_KEYS_
variable string forward=w
variable string backward=s
variable string strafeleft=q
variable string straferight=e
#endif /* _MOVE_KEYS_ */
;===================================================
;===           Constant Declarations            ====
;===================================================
#define RANGE_CLOSE 1
#define RANGE_MAX 2
#define RANGE_RANGED 3
#define QUADRANT_ANY 0
#define QUADRANT_BEHIND 1
#define QUADRANT_FRONT 2
#define QUADRANT_FLANK 3
#define QUADRANT_BEHIND_FLANK 4
#define QUADRANT_FRONT_FLANK 5
;===================================================
;===           Custom Variables                 ====
;===================================================
variable int quickwait=1
variable int shortwait=5
variable int longwait=10
;===================================================
;===           Variable Declarations            ====
;===================================================
variable EQ2BotObj EQ2Bot
variable ActorCheck Mob
variable(global) bool CurrentTask=TRUE
variable(global) int FollowTask
variable bool IgnoreEpic
variable bool IgnoreNamed
variable bool IgnoreHeroic
variable bool IgnoreRedCon
variable bool IgnoreOrangeCon
variable bool IgnoreYellowCon
variable bool IgnoreWhiteCon
variable bool IgnoreBlueCon
variable bool IgnoreGreenCon
variable bool IgnoreGreyCon
variable string spellfile
variable string charfile
variable string SpellType[600]
variable int AssistHP
variable string MainAssist
variable uint MainAssistID
variable string MainTankPC
variable uint MainTankID
variable bool MainAssistMe=FALSE
variable string OriginalMA
variable string OriginalMT
variable bool AutoSwitch
variable bool AutoMelee
variable bool AutoPull
variable bool PullOnlySoloMobs
variable bool AutoLoot
variable bool LootCorpses
variable bool LootAll
variable uint KillTarget
variable string Follow
variable string PreAction[40]
variable int PreMobHealth[40,2]
variable int PrePower[40,2]
variable int PreSpellRange[40,5]
variable string Action[40]
variable int MobHealth[40,2]
variable int Power[40,2]
variable int Health[40,2]
variable int SpellRange[40,10]
variable string PostAction[20]
variable int PostSpellRange[20,5]
variable string _PreAction[40]
variable int _PreMobHealth[40,2]
variable int _PrePower[40,2]
variable int _PreSpellRange[40,5]
variable string _Action[40]
variable int _MobHealth[40,2]
variable int _Power[40,2]
variable int _Health[40,2]
variable int _SpellRange[40,10]
variable string _PostAction[20]
variable bool stealth=FALSE
variable bool direction=TRUE
variable float targetheading
variable bool disablebehind=FALSE
variable bool disablefront=FALSE
variable uint movetimer
variable bool isstuck=FALSE
variable bool MainTank=FALSE
variable float HomeX
variable float HomeZ
variable int obstaclecount
variable int LootX
variable int LootY
variable int PathIndex
variable float WPX
variable float WPY
variable float WPZ
variable string NearestPoint
variable bool checkfollow=FALSE
variable string PullSpell
variable int PullRange
variable int ScanRange
variable bool engagetarget=FALSE
variable bool islooting=FALSE
variable int CurrentPull
variable bool pathdirection=0
variable bool movingtowp
variable bool pulling
variable int stuckcntMa
variable int grpcnt
variable bool movinghome
variable bool haveaggro=FALSE
variable bool shwlootwdw
variable bool hurt
variable int currenthealth[5]
variable int changehealth[5]
variable int oldhealth[5]
variable int healthtimer[5]
variable int chgcnt[5]
variable int tempgrp
variable uint chktimer
variable uint starttimer=${Time.Timestamp}
variable bool avoidhate
variable bool lostaggro
variable uint aggroid
variable bool usemanastone
variable uint mstimer=${Time.Timestamp}
variable int StartLevel=${Me.Level}
variable int StartAP=${Me.TotalEarnedAPs}
variable bool PullNonAggro
variable bool checkadds
variable bool DCDirection=TRUE
variable string Harvesting
variable bool PauseBot=FALSE
variable bool StartBot=FALSE
variable bool CloseUI
variable int PowerCheck
variable int HealthCheck
variable float PositionHeading
variable bool PullWithBow
variable bool LoreConfirm
variable bool NoTradeConfirm
variable bool LootPrevCollectedShineys
variable bool CheckPriestPower
variable int LootWndCount
variable int LootDecline
variable bool NoEQ2BotStance=0
variable int wipe
variable int together
variable int wipegroup
variable bool WipeRevive
variable string PullType
variable string LootMethod
variable int MARange
variable string CurrentAction
variable bool GroupWiped
variable bool InitialBuffsDone
variable int EngageDistance
variable(script) collection:string ActorsLooted
variable(script) collection:string DoNotPullList
variable(script) collection:string TempDoNotPullList
variable(script) int TempDoNotPullListTimer
variable(script) collection:string InvalidMasteryTargets
variable(script) bool IsMoving
variable bool UseCustomRoutines=FALSE
variable int gRtnCtr=1
variable string GainedXPString
variable string LastQueuedAbility
variable int LastCastTarget
variable int OORThreshold
variable bool CheckingBuffsOnce
variable uint BuffRoutinesTimer = 0
variable int BuffRoutinesTimerInterval = 5000
variable uint OutOfCombatRoutinesTimer = 0
variable int OutOfCombatRoutinesTimerInterval = 1000
variable uint AggroDetectionTimer = 0
variable int AggroDetectionTimerInterval = 500
variable uint ClassPulseTimer = 0
variable uint ClassPulseTimer2 = 0
variable uint ClassPulseTimer3 = 0
variable uint ClassPulseTimer4 = 0
variable bool IsReady = FALSE
variable bool NoAutoMovementInCombat
variable bool NoAutoMovement
variable settingsetref CharacterSet
variable settingsetref SpellSet
variable bool DoNoCombat

;===================================================
;===          AutoAttack Timing                 ====
;===================================================
variable float PrimaryDelay
variable float LastAutoAttack
variable(global) float TimeUntilNextAutoAttack
variable float RunningTimeInSeconds
variable bool AutoAttackReady

;===================================================
;===          Lavish Navigation                 ====
;===================================================
variable filepath ConfigPath = "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Navigational Paths/"
variable Navigation EQ2Nav
variable lnavregionref Region
variable string	CurrentRegion
variable string LastRegion
variable bool StartNav
variable lnavpath CurrentPath
variable dijkstrapathfinder PathFinder
variable int BoxWidth
variable int CampCount
variable int PullCount
variable lnavregionref PullPoint
variable bool CampNav=TRUE
variable int RegionCount
variable bool IsFinish
variable string POIList[50]
variable bool POIInclude[50]
variable int POICount
variable int CurrentPOI=1
variable bool NoEligibleTarget
variable bool NoAtExit
;===========================================================
; Define the PathType
; 0 = Manual Movement
; 1 = Minimum Movement - Home Point Set
; 2 = Camp - Follow Small Nav Path with multiple Pull Points
; 3 = Dungeon Crawl - Follow Nav Path: Start to Finish
; 4 = Auto Hunting - Pull nearby Mobs within a Maximum Range
;===========================================================
variable int PathType



#if ${ISXEQ2(exists)} && ${ISXEQ2.IsReady}
	#include ${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/${Me.SubClass}.iss
	#includeoptional ${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Character Config/${Me.Name}.iss
	#includeoptional ${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/${Me.SubClass}_StrRes.iss
#endif

/* do we really need this? I don't find any reference to the mobcheck object in this script. */
/* (note) This was included from moveto.iss, and this include replaces that include. */
/* (note) This may actually be used by eq2botlib.iss, in which case the include should be moved there. */
#ifndef _MobCheck_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/MobCheck.iss"
#endif

#ifndef _PositionUtils_
	#define _IncludePositionUtils_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/PositionUtils.iss"
#endif

#include EQ2Common/Debug.iss



function main(string Args)
{
	variable int tempvar
	variable int tempvar1
	variable int tempvar2
	variable string tempnme
	variable bool MobDetected
	declare LastWindow string script
	variable uint AggroMob

	if ${Args.Find[debug]}
	{
		echo Enabling Debug
		Debug:Enable
	}
	else
	{
		echo Debuging Disabled
		Debug:Disable
	}
	
	; Added as Part of the AutoAttack Timing Code
	LastAutoAttack:Set[${Script.RunningTime}/1000]

	if !${ISXEQ2(exists)}
	{
		Debug:Echo["ISXEQ2 has not been loaded!  EQ2Bot can not run without it.  Good Bye!"]
		NoAtExit:Set[TRUE]
		return
	}
	elseif !${ISXEQ2.IsReady}
	{
		Debug:Echo["ISXEQ2 is not yet ready -- you must wait until the authentication and patching sequences have completed before running EQ2Bot."]
		NoAtExit:Set[TRUE]
		return
	}
	elseif (${EQ2.Zoning} != 0)
	{
		Debug:Echo["You cannot start EQ2Bot while zoning.  Wait until you have finished zoning, and then try again."]
		NoAtExit:Set[TRUE]
		return
	}

	Turbo 50

	;Script:Squelch
	;Script:EnableProfiling

	CurrentAction:Set["* Initializing EQ2Bot..."]
	echo "---------"
	echo "* Initializing EQ2Bot..."

	EQ2Bot:Init_Settings

	;;;;;;;;;;;;;;;;;
	;;;; Set strings used in UI
	;;;
	if (${Me.Level} < 90)
		GainedXPString:Set[Gained XP:  ${Math.Calc[(${Me.Exp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100)].Precision[1]} ( ${Math.Calc[((${Me.Exp}-${CharacterSet.FindSet[Temporary Settings]:AddSetting[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100))/(((${Time.Timestamp}+1)-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartTime]})/3600)].Precision[2]} / hr)]
	elseif ${Me.TotalEarnedAPs} < 250
		GainedXPString:Set[Gained APExp:  ${Math.Calc[(${Me.APExp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100)].Precision[1]} ( ${Math.Calc[((${Me.APExp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100))/(((${Time.Timestamp}+1)-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartTime]})/3600)].Precision[2]} / hr)]
	else
		GainedXPString:Set[Gained XP:  N/A]
	;;;
	;;;;;;;;;;;;;;;;;

	EQ2Bot:Init_Config
	EQ2Bot:Init_Events
	EQ2Bot:Init_Triggers
	EQ2Bot:Init_Character
	EQ2Bot:Init_UI
	EQ2Nav:Initialise
	call CheckAbilities ${Me.SubClass}

	call Class_Declaration
	call CheckManaStone

	#ifdef __USING_CUSTOM_ROUTINES__
		echo "* Utilizing Custom Routines via ${Me.Name}.iss"
		call Custom__Initialization
		UseCustomRoutines:Set[TRUE]
	#endif

	echo "...Initialization Complete."
	echo "* EQ2Bot Ready!"
	echo "---------"
	IsReady:Set[TRUE]
	CurrentAction:Set["Idle..."]

	do
	{
		waitframe
		call ProcessTriggers
		EQ2Nav:UpdateNavGUI
		if ${StartNav}
		{
			EQ2Nav:AutoBox
			EQ2Nav:ConnectRegions
		}
	}
	while !${StartBot}

	; These are called from within the individual class file used
	call Buff_Init
	call Combat_Init
	call PostCombat_Init

	;; If using CustomRoutines...
	if ${UseCustomRoutines}
	{
		call Custom__Buff_Init
		call Custom__Combat_Init
		call Custom__PostCombat_Init
	}


	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Hide
	do
	{
		;Debug:Echo["Main Loop: Test-${Time.Timestamp}"]
		;;;;;;;;;;;;;;;;;
		;;;; Set strings used in UI.  They are set here in order to make for custom strings based upon level, etc.  Also, any ${} called in the UI is accessed
		;;;; EVERY frame.  By moving things here, we can reduce the number of times things are called, increasing efficiency (when desired.)
		;;;
		if (${Me.Level} < 90)
			GainedXPString:Set[Gained XP:  ${Math.Calc[(${Me.Exp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100)].Precision[1]} ( ${Math.Calc[((${Me.Exp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100))/(((${Time.Timestamp}+1)-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartTime]})/3600)].Precision[2]} / hr)]
		elseif ${Me.TotalEarnedAPs} < 250
			GainedXPString:Set[Gained APExp:  ${Math.Calc[(${Me.APExp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100)].Precision[1]} ( ${Math.Calc[((${Me.APExp}-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100))/(((${Time.Timestamp}+1)-${CharacterSet.FindSet[Temporary Settings].FindSetting[StartTime]})/3600)].Precision[2]} / hr)]
		else
			GainedXPString:Set[Gained XP:  N/A]
		;;;
		;;;;;;;;;;;;;;;;;

		if (${EQ2.Zoning} != 0)
		{
			KillTarget:Set[]
			do
			{
				wait 5
			}
			while (${EQ2.Zoning} != 0)

			wait 15
			if ${AutoFollowingMA(exists)}
				AutoFollowingMA:Set[FALSE]
		}

		if !${StartBot}
		{
			KillTarget:Set[]
			do
			{
				wait 5
				call ProcessTriggers
			}
			while !${StartBot}
		}

		;;;;;;;;;;;;;;
		;; If DoNoCombat is TRUE, then the bot should avoid calling Combat() or any related functions.
		if (${EQ2.OnBattleground} && ${BG_NoCombat})	
			DoNoCombat:Set[TRUE]
		else
			DoNoCombat:Set[FALSE]
		;;
		;;;;;;;;;;;;;;
		
		;Debug:Echo["main() -- DoNoCombat: ${DoNoCombat} (${EQ2.OnBattleground} - ${BG_NoCombat})"]
		
		if ${Me.ToActor.IsDead}
		{
			KillTarget:Set[]
			CurrentAction:Set[Dead -- Waiting...]
			do
			{
				wait 2
				call ProcessTriggers
			}
			while (${Me.ToActor.IsDead} || ${EQ2.Zoning} != 0)

			wait 15
			if ${AutoFollowingMA(exists)}
				AutoFollowingMA:Set[FALSE]
			CurrentAction:Set[Performing PostDeath Routine...]
			;; call PostDeathRoutine(), which exists in each class file
			call PostDeathRoutine
			CurrentAction:Set[Idle...]
		}

		if (${usemanastone})
		{
			if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)}
			{
				if ${Math.Calc64[${Time.Timestamp}-${mstimer}]}>70
				{
					Me.Inventory[ExactName,ManaStone]:Use
					mstimer:Set[${Time.Timestamp}]
					wait 2
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
				}
			}
		}

		call Pulse

		;;;;
		;; Only do the Buff Routines Loop every x second(s)
		;;;;
		if (${BuffRoutinesTimer} == 0 || ${Script.RunningTime} >= ${Math.Calc64[${BuffRoutinesTimer}+${BuffRoutinesTimerInterval}]})
		{
			;Debug:Echo["${Script.RunningTime} -- Performing Buff & Out-of-Combat Routines"]
			;;;;;;;;;;;;;;
			;;; Pre-Combat Routines Loop (ie, Buff Routine, etc.)
			;;;;;;;;;;;;;;
			if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
			{
				ExecuteAtom AutoFollowTank
				wait 5
			}
			ExecuteAtom CheckStuck

			;;;;;;
			;; Make sure that MainAssistID and/or MainTankID are still valid (ie, IDs sometimes change on zoning...)
			if !${Actor[${MainTankID}](exists)}
			{
				if ${Actor[exactname,${MainTankPC}](exists)}
				{
					MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]
				}
			}
			if !${Actor[${MainAssistID}](exists)}
			{
				if ${Actor[exactname,${MainAssist}](exists)}
				{
					MainAssistID:Set[${Actor[exactname,${MainAssist}].ID}]
				}
			}
			;;
			;;;;;


			gRtnCtr:Set[1]
			do
			{
				if (${EQ2.Zoning} != 0)
				{
					KillTarget:Set[]
					do
					{
						wait 5
					}
					while (${EQ2.Zoning} != 0)
		
					wait 15
					if ${AutoFollowingMA(exists)}
						AutoFollowingMA:Set[FALSE]
				}				
				
				;Debug:Echo["Pre-Combat Routines Loop: Test - ${gRtnCtr}"]

				if (!${DoNoCombat})
				{
					; For dungeon crawl and not pulling, then follow the nav path instead of using follow.
					if ${PathType}==3 && !${AutoPull}
					{
						if ${Actor[${MainAssistID}](exists)}
						{
							target ${Actor[${MainAssistID}]}
							wait 10 ${Target.ID}==${MainAssistID}
						}
	
						; Need to make sure we are close to the puller. Assume Puller is Main Tank for Dungeon Crawl.
						if !${Me.TargetLOS} && ${Target.Distance}>10
							call MovetoMaster
						elseif ${Target.Distance}>10
							call FastMove ${Actor[${MainAssistID}].X} ${Actor[${MainAssistID}].Z} ${Math.Rand[3]:Inc[3]}
					}
	
					if !${MainTank}
					{
						if (${Actor[${MainAssistID}].Target.Type.Equal[NPC]} || ${Actor[${MainAssistID}].Target.Type.Equal[NamedNPC]}) && ${Actor[${MainAssistID}].Target.InCombatMode}
							KillTarget:Set[${Actor[${MainAssistID}].Target.ID}]
	
						; Add additional check to see if Mob is in Camp OR MainTank is within designated range
						if ${KillTarget}
						{
							if ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead}
							{
								if (${Actor[${KillTarget}].Health} <= ${AssistHP} && !${Actor[${KillTarget}].IsDead})
								{
									if (${Mob.Detect} || ${Actor[${MainAssistID}].Distance} < ${MARange})
									{
										if ${Mob.Target[${KillTarget}]}
											call Combat
									}
									else
									{
										KillTarget:Set[0]
										;Debug:Echo[" if ({Mob.Detect} || {Actor[ExactName,{MainAssist}].Distance}<{MARange})"]
									}
								}
								else
								{
									KillTarget:Set[0]
									;Debug:Echo[" if ({Actor[{KillTarget}].Health}<={AssistHP} && !{Actor[{KillTarget}].IsDead})"]
								}
							}
							else
								KillTarget:Set[0]
						}
					}

					;; This used to be duplicated in Combat(); however, now it just appears here (as I think it should be)
					if ${PathType}==4 && ${MainTank}
					{
						if ${Me.ToActor.InCombatMode} && ${Mob.Detect}
						{
							call Pull any
							if ${engagetarget}
								call Combat
						}
					}
					
					MobDetected:Set[${Mob.Detect}]
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;;
					;this should force the tank to react to any aggro, regardless
					if ${MobDetected} && ${MainTank} && !${Me.IsMoving}
					{
						do
						{
							if ${Mob.Target[${Target.ID}]} && !${Target.IsDead}
							{
								KillTarget:Set[${Target.ID}]
								call Combat
							}
							else
							{
								AggroMob:Set[${Mob.NearestAggro}]
								if ${AggroMob} > 0
								{
									if ${KillTarget} != ${AggroMob}
									{
										CurrentAction:Set["Targetting Nearest Aggro Mob"]
										echo "EQ2Bot:: Targetting Nearest Aggro Mob"
										KillTarget:Set[${AggroMob}]
									}
									target ${AggroMob}
									call Combat
								}
							}
							MobDetected:Set[${Mob.Detect}]
						}
						while ${MobDetected}
					}
					;;
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				}

				if !${MobDetected} || (${MainTank} && ${Me.Group}!=1) || ${KillTarget}
				{
					if (!${DoNoCombat})
					{
						if ${Actor[${KillTarget}](exists)} && ${Actor[${KillTarget}].Health} <= ${AssistHP} && ${Actor[${KillTarget}].Distance} <= 35
						{
							if ${Mob.Target[${KillTarget}]}
							{
								gRtnCtr:Set[40]
								if !${Me.ToActor.InCombatMode}
									CurrentAction:Set["Idle..."]
								break
							}
						}
					}
					if !${Me.ToActor.IsDead}
					{
						;;;;;;;;;
						;;;;; Call the buff routine from the class file
						;;;;;;;;;
						call Buff_Routine ${gRtnCtr}
						if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
						{
							; end after this round
							gRtnCtr:Set[40]
							if !${Me.ToActor.InCombatMode}
								CurrentAction:Set["Idle..."]
							break
						}
					}
					else
					{
						gRtnCtr:Set[40]
						CurrentAction:Set["Dead..."]
						break
					}

					;disable autoattack if not in combat
					if (!${DoNoCombat})
					{
						if ${MainTank}
						{
							if (${Me.AutoAttackOn} && !${Mob.Detect})
								EQ2Execute /toggleautoattack
						}
						else
						{
							if !${Actor[${MainTankID}].InCombatMode} && ${Me.AutoAttackOn}
								EQ2Execute /toggleautoattack
						}
					}
				}
			}
			while ${gRtnCtr:Inc}<=40

			if !${MobDetected} || (${MainTank} && ${Me.GroupCount}!=1) || ${KillTarget}
			{
				if (${UseCustomRoutines})
				{
					gRtnCtr:Set[1]
					do
					{
						if (!${DoNoCombat})
						{
							if ${Actor[${KillTarget}](exists)} && ${Actor[${KillTarget}].Health} <= ${AssistHP} && !${Actor[${KillTarget}].IsDead} && ${Actor[${KillTarget}].Distance} <= 35
							{
								if ${Mob.Target[${KillTarget}]}
								{
									gRtnCtr:Set[40]
									if !${Me.ToActor.InCombatMode}
										CurrentAction:Set["Idle..."]
									break
								}
							}
						}
						call Custom__Buff_Routine ${gRtnCtr}
						if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
						{
							gRtnCtr:Set[40]
							if !${Me.ToActor.InCombatMode}
								CurrentAction:Set["Idle..."]
							break
						}
					}
					while ${gRtnCtr:Inc} <= 40
				}
			}

			BuffRoutinesTimer:Set[${Script.RunningTime}]
			OutOfCombatRoutinesTimer:Set[${Script.RunningTime}]
		}
		elseif (${Script.RunningTime} >= ${Math.Calc64[${OutOfCombatRoutinesTimer}+${OutOfCombatRoutinesTimerInterval}]})
		{
			;Debug:Echo["${Script.RunningTime} -- Performing Out-of-Combat Routines"]
			;;;;;;;;;;;;;;
			;;; Pre-Combat Routines  (NO Buff Loop)
			;;;;;;;;;;;;;;

			if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
			{
				ExecuteAtom AutoFollowTank
				wait 5
			}
			ExecuteAtom CheckStuck

			;;;;;;
			;; Make sure that MainAssistID and/or MainTankID are still valid (ie, IDs sometimes change on zoning...)
			if !${Actor[${MainTankID}](exists)}
			{
				if ${Actor[exactname,${MainTankPC}](exists)}
				{
					MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]
				}
			}
			if !${Actor[${MainAssistID}](exists)}
			{
				if ${Actor[exactname,${MainAssist}](exists)}
				{
					MainAssistID:Set[${Actor[exactname,${MainAssist}].ID}]
				}
			}
			;;
			;;;;;

			; For dungeon crawl and not pulling, then follow the nav path instead of using follow.
			if ${PathType}==3 && !${AutoPull}
			{
				if ${Actor[${MainAssistID}](exists)}
				{
					target ${Actor[${MainAssistID}]}
					wait 10 ${Target.ID}==${MainAssistID}
				}

				; Need to make sure we are close to the puller. Assume Puller is Main Tank for Dungeon Crawl.
				if !${Me.TargetLOS} && ${Target.Distance}>10
					call MovetoMaster
				elseif ${Target.Distance}>10
					call FastMove ${Actor[${MainAssistID}].X} ${Actor[${MainAssistID}].Z} ${Math.Rand[3]:Inc[3]}
			}

			if (!${DoNoCombat})
			{
				if !${MainTank}
				{
					if (${Actor[${MainAssistID}].Target.Type.Equal[NPC]} || ${Actor[${MainAssistID}].Target.Type.Equal[NamedNPC]}) && ${Actor[${MainAssistID}].Target.InCombatMode}
						KillTarget:Set[${Actor[${MainAssistID}].Target.ID}]
	
					; Add additional check to see if Mob is in Camp OR MainTank is within designated range
					if ${KillTarget}
					{
						if ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead}
						{
							if (${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead})
							{
								if (${Mob.Detect} || ${Actor[${MainAssistID}].Distance}<${MARange})
								{
									if ${Mob.Target[${KillTarget}]}
										call Combat
								}
								else
								{
									KillTarget:Set[0]
									;Debug:Echo[" if ({Mob.Detect} || {Actor[ExactName,{MainAssist}].Distance}<{MARange})"]
								}
							}
							else
							{
								KillTarget:Set[0]
								;Debug:Echo[" if ({Actor[{KillTarget}].Health}<={AssistHP} && !{Actor[{KillTarget}].IsDead})"]
							}
						}
						else
							KillTarget:Set[0]
					}
				}
	
				;; This used to be duplicated in Combat(); however, now it just appears here (as I think it should be)
				if ${PathType}==4 && ${MainTank}
				{
					if ${Me.ToActor.InCombatMode} && ${Mob.Detect}
					{
						call Pull any
						if ${engagetarget}
							call Combat
					}
				}
	
				MobDetected:Set[${Mob.Detect}]
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;;
				;this should force the tank to react to any aggro, regardless
				if ${MobDetected} && ${MainTank} && !${Me.IsMoving}
				{
					do
					{
						if ${Mob.Target[${Target.ID}]} && !${Target.IsDead}
						{
							KillTarget:Set[${Target.ID}]
							call Combat
						}
						else
						{
							AggroMob:Set[${Mob.NearestAggro}]
							if ${AggroMob} > 0
							{
								if ${KillTarget} != ${AggroMob}
								{
									CurrentAction:Set["Targetting Nearest Aggro Mob"]
									echo "EQ2Bot:: Targetting Nearest Aggro Mob"
									KillTarget:Set[${AggroMob}]
								}
								target ${AggroMob}
								call Combat
							}
						}
						MobDetected:Set[${Mob.Detect}]
					}
					while ${MobDetected}
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
			
			if !${MobDetected} || (${MainTank} && ${Me.GroupCount}!=1) || ${KillTarget}
			{
				if (!${DoNoCombat})
				{
					if ${Actor[${KillTarget}](exists)} && ${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead} && ${Actor[${KillTarget}].Distance} <= 35
					{
						if ${Mob.Target[${KillTarget}]}
						{
							if !${Me.ToActor.InCombatMode}
								CurrentAction:Set["Idle..."]
						}
					}
				}
				;disable autoattack if not in combat
				if ${MainTank}
				{
					if (${Me.AutoAttackOn} && !${Mob.Detect})
						EQ2Execute /toggleautoattack
				}
				else
				{
					if !${Actor[${MainTankID}].InCombatMode} && ${Me.AutoAttackOn}
						EQ2Execute /toggleautoattack
				}
			}

			;; Misc. Checks
			if (${Actor[${MainAssistID}].IsDead} && !${MainTank}) || (${MainAssist.NotEqual[${OriginalMA}]} && ${Actor[exactname,${OriginalMA}].IsDead})
				EQ2Bot:MainAssist_Dead

			if (${Actor[${MainTankID}].IsDead} && !${MainTank}) || (${MainTankPC.NotEqual[${OriginalMT}]} && ${Actor[exactname,${OriginalMT}].IsDead})
				EQ2Bot:MainTank_Dead

			OutOfCombatRoutinesTimer:Set[${Script.RunningTime}]
		}

		;reset MT if it has changed
		if ${MainTankPC.NotEqual[${OriginalMT}]} && ${Actor[exactname,pc,${OriginalMT}](exists)} && ${Actor[exactname,pc,${OriginalMT}].Health}>80
		{
			MainTankID:Set[${Actor[exactname,pc,${OriginalMT}].ID}]
			MainTankPC:Set[${OriginalMT}]
			Debug:Echo["${Script.RunningTime} -- Maintank Reset to UI Selection (${MainTankPC} - ID: ${MainTankID})"]
		}

		;;;;;;;;;;;;;;
		;;; END Pre-Combat Routines Loop (ie, Buff Routine, etc.)
		;;;;;;;;;;;;;;


		if ${AutoLoot}  && ${Me.ToActor.Health}>=${HealthCheck}
			call CheckLoot

		if ${AutoPull} && !${Me.ToActor.InCombatMode}
		{
			;Debug:Echo["AutoPull Loop: Test-${Time.Timestamp}"]
			if ${PathType}==2 && (${Me.Ability[${PullSpell}].IsReady} || ${PullType.Equal[Pet Pull]} || ${PullType.Equal[Bow Pull]}) && ${Me.ToActor.Power}>${PowerCheck} && ${Me.ToActor.Health}>${HealthCheck} && ${EQ2Bot.PriestPower}
			{
				PullPoint:SetRegion[${EQ2Bot.ScanWaypoints}]
				if ${PullPoint}
				{
					pulling:Set[TRUE]
					call MovetoWP ${PullPoint}
					EQ2Execute /target_none

					; Make sure we are close to our home point before we begin combat
					if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>5
					{
						pulling:Set[TRUE]
						call MovetoWP ${LNavRegionGroup[Camp].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
						pulling:Set[FALSE]
					}
				}
			}
			elseif ${PathType}==3 && (${Me.Ability[${PullSpell}].IsReady} || ${PullType.Equal[Pet Pull]} || ${PullType.Equal[Bow Pull]}) && ${Me.ToActor.Power}>${PowerCheck} && ${Me.ToActor.Health}>${HealthCheck} && ${AutoPull} && ${EQ2Bot.PriestPower}
			{
				pulling:Set[TRUE]
				if ${CurrentPOI}==1
					call MovetoWP ${LNavRegionGroup[Start].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
				elseif ${CurrentPOI}==${Math.Calc[${POICount}+2]}
					call MovetoWP ${LNavRegionGroup[Finish].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
				else
					call MovetoWP ${LNavRegion[${POIList[${CurrentPOI}]}]}

				EQ2Execute /target_none
			}

			if (!${DoNoCombat})
			{
				if ${Mob.Detect} || ${Me.Ability[${PullSpell}].IsReady} || ${PullType.Equal[Pet Pull]} || ${PullType.Equal[Bow Pull]}
				{
					if (${Me.ToActor.Power}>=${PowerCheck} && ${Me.ToActor.Health}>=${HealthCheck})
					{
						if ${PathType}==4 && !${Me.ToActor.InCombatMode}
						{
							if ${EQ2Bot.PriestPower}
							{
								call Pull any
								if ${engagetarget}
								{
									wait 10
									if ${Mob.Target[${Target.ID}]}
									{
										;Debug:Echo[": Calling Combat(1) within AutoPull Loop: Test-${Time.Timestamp}"]
										call Combat
										;Debug:Echo[": Ending Combat(1) within AutoPull Loop: Test-${Time.Timestamp}"]
									}
								}
							}
						}
						else
						{
							if ${Mob.Target[${Target.ID}]} && !${Target.IsDead} && ${Target.InCombatMode} && ${Target.Distance}<8
							{
								;Debug:Echo["Calling Combat(2) within AutoPull Loop: Test-${Time.Timestamp}"]
								call Combat
							}
							else
							{
								variable uint AggroNPC
								AggroNPC:Set[${Mob.NearestAggro}]
								if ${AggroNPC} > 0
								{
									if ${Mob.ValidActor[${AggroNPC}]}
									{
										target ${AggroNPC}
										;Debug:Echo["Calling Combat(3) within AutoPull Loop: Test-${Time.Timestamp}"]
										call Combat
									}
								}
								else
								{
									if ${EQ2Bot.PriestPower}
									{
										EQ2Execute /target_none
										call Pull any
										if ${engagetarget}
										{
											;Debug:Echo["Calling Combat(4) within AutoPull Loop: Test-${Time.Timestamp}"]
											call Combat
										}
									}
								}
							}
	
							if ${EQ2Bot.PriestPower} || ${Mob.Detect}
							{
								EQ2Execute /target_none
								call Pull any
								if ${engagetarget}
								{
									;Debug:Echo["Calling Combat(5) within AutoPull Loop: Test-${Time.Timestamp}"]
									call Combat
								}
							}
						}
					}
				}
			;Debug:Echo["END AutoPull Loop: Test-${Time.Timestamp}"]
			}
		}
		
		call ProcessTriggers

		if (!${DoNoCombat})
		{
			if (${Script.RunningTime} >= ${Math.Calc64[${AggroDetectionTimer}+${AggroDetectionTimerInterval}]})
			{
				;Debug:Echo["${Script.RunningTime} -- Performing Aggro Detection Routines"]
				MobDetected:Set[${Mob.Detect}]
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;;;; This is repeated here for instances where the MT is the same as the MA
				;;
				if ${MobDetected} && ${MainTank} && !${Me.IsMoving}
				{
					do
					{
						if ${Mob.Target[${Target.ID}]} && !${Target.IsDead}
						{
							KillTarget:Set[${Target.ID}]
							call Combat
						}
						else
						{
							variable uint AgressiveNPC
							AgressiveNPC:Set[${Mob.NearestAggro}]
							if ${AgressiveNPC} > 0
							{
								CurrentAction:Set["Targetting Nearest Aggro Mob"]
								echo "EQ2Bot:: Targetting Nearest Aggro Mob"
								KillTarget:Set[${AgressiveNPC}]
								target ${AgressiveNPC}
								call Combat
							}
						}
						MobDetected:Set[${Mob.Detect}]
					}
					while ${MobDetected}
				}
				AggroDetectionTimer:Set[${Script.RunningTime}]
	
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				;; pvp / duels
				;;
				;; TO DO:
				;; To work, we need to change CastSpell() so that when pvp, it uses "Ability[]:Use" rather
				;; than /useabilityonplayer (which only works for beneficial abilities).  Otherwise, uncommenting
				;; this WILL make pvp combat work.
				;if ${MainTank} && ${Target(exists)}
				;{
				;	if ${Target.Type.Equal[PC]}
				;	{
				;		if ${Target.InCombatMode} && ${Me.ToActor.InCombatMode} && ${Target.Target.ID} == ${Me.ID}
				;		{
				;			KillTarget:Set[${Target.ID}]
				;			call Combat 1
				;		}
				;	}
				;}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
				if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
				{
					ExecuteAtom AutoFollowTank
					wait 5
				}
				;;
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			}
		}
		
		; Check if we have leveled and reset XP Calculations in UI
		if ${Me.Level} < 90
		{
			if ${Me.Level} > ${StartLevel} && !${CloseUI}
			{
				CharacterSet.FindSet[Temporary Settings]:AddSetting["StartXP",${Me.Exp}]
				CharacterSet.FindSet[Temporary Settings]:AddSetting["StartTime",${Time.Timestamp}]
			}
		}
		;;;; This is not proper logic...does not seem to work correctly if you ding AA...TO DO:  Redo.
		;elseif ${Me.TotalEarnedAPs} < 200
		;{
		;	if ${Me.TotalEarnedAPs} > ${StartAP} && !${CloseUI}
		;	{
		;		CharacterSet.FindSet[Temporary Settings]:AddSetting["StartAPXP",${Me.APExp}]
		;		CharacterSet.FindSet[Temporary Settings]:AddSetting["StartTime",${Time.Timestamp}]
		;	}
		;}

		; Check if we have leveled and reload spells
		if ${Me.Level}>${StartLevel} && ${Me.Level}<90
		{
			EQ2Bot:Init_Config
			call Buff_Init
			call Combat_Init
			call PostCombat_Init
			StartLevel:Set[${Me.Level}]
		}

		call ProcessTriggers
	}
	while ${CurrentTask}

}

function CalcAutoAttackTimer()
{

	if !${AutoAttackReady}
	{
		PrimaryDelay:Set[${EQ2DataSourceContainer[GameData].GetDynamicData[Stats.Primary_Delay].ShortLabel}]
		RunningTimeInSeconds:Set[${Script.RunningTime}/1000]
		TimeUntilNextAutoAttack:Set[${PrimaryDelay}-(${RunningTimeInSeconds}-${LastAutoAttack})]
	}

	if ${TimeUntilNextAutoAttack} < 0 && !${AutoAttackReady}
	{
		;echo AutoAttackReady: TRUE
		AutoAttackReady:Set[TRUE]
	}
}

function CheckManaStone()
{
	variable int tempvar
	;Me.Equipment[Exactname,"Manastone"]:UnEquip

	Me:CreateCustomInventoryArray[nonbankonly]

	do
	{
		if ${Me.CustomInventory[${tempvar}].Name.Equal[Manastone]}
		{
			usemanastone:Set[TRUE]
			return
		}
	}
	while ${tempvar:Inc}<=${Me.CustomInventoryArraySize}

	usemanastone:Set[FALSE]
}

function CastSpellRange(... Args)
{
	;; This format still works.
	;; function CastSpellRange(int start, int finish, int xvar1, int xvar2, uint TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, int CastSpellWhen, bool IgnoreIsReady)

	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;; - If the parameters of this function are altered, then the corresponding function needs to be altered in: Illusionist.iss
	;;
	;;	CastSpellNow changed to CastSpellWhen
	;;	CastSpellWhen:
	;;		0 = Queue Spell
	;;		1 = Cast Immediately
	;;		2 = Cast When Current Queue Complete
	;;;;;;;

	variable int start=-99
	variable int finish=0
	variable int xvar1=0
	variable int xvar2=0
	variable uint TargetID=0
	variable int notall=0
	variable int refreshtimer=0
	variable bool castwhilemoving=0
	variable bool IgnoreMaintained=0
	variable int CastSpellWhen=0
	variable bool IgnoreIsReady=0
	variable uint AbilityID=0
	variable string AbilityName

	variable int count=0
	variable int test=${Args[1]}
	if ${test}>0
	{
		switch ${Args.Size}
		{
			case 11
				IgnoreIsReady:Set[${Args[11]}]
			case 10
				CastSpellWhen:Set[${Args[10]}]
			case 9
				IgnoreMaintained:Set[${Args[9]}]
			case 8
				castwhilemoving:Set[${Args[8]}]
			case 7
				refreshtimer:Set[${Args[7]}]
			case 6
				notall:Set[${Args[6]}]
			case 5
				TargetID:Set[${Args[5]}]
			case 4
				xvar2:Set[${Args[4]}]
			case 3
				xvar1:Set[${Args[3]}]
			case 2
				finish:Set[${Args[2]}]
			case 1
				start:Set[${Args[1]}]
				break
			case 0
				return -1
		}
	}
	else
	{
		while ${count:Inc}<=${Args.Size}
		{
			if ${Args[${count}].Token[1,=].Equal[start]}
				start:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[finish]}
				finish:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[range]}
				xvar1:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[quadrant]}
				xvar2:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[TargetID]}
				TargetID:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[notall]}
				notall:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[refreshtimer]}
				refreshtimer:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[castwhilemoving]}
				castwhilemoving:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[IgnoreMaintained]}
				IgnoreMaintained:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[CastSpellWhen]}
				CastSpellWhen:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[IgnoreIsReady]}
				IgnoreIsReady:Set[${Args[${count}].Token[2,=]}]
			elseif ${Args[${count}].Token[1,=].Equal[AbilityID]}
				AbilityID:Set[${Args[${count}].Token[2,=]}]
		}

		if (${start} > 0 && ${AbilityID} > 0)
		{
			Debug:Echo["CastSpellRange() -- BAD SYNTAX:  You must use *either* 'start' or 'AbilityID', not both!"]
			return -1
		}
	}


	variable bool fndspell
	variable int tempvar
	variable uint originaltarget
	tempvar:Set[${start}]

	if ${tempvar} <= 0 && ${AbilityID} <= 0
	{
		Debug:Echo["CastSpellRange() -- BAD SYNTAX:  'start' or 'AbilityID' must be greater than zero."]
		return -1
	}


	;Debug:Echo["CastSpellRange(${tempvar}::${SpellType[${tempvar}]})"]

	;if out of combat and invis, lets not break it
	if !${Me.ToActor.InCombatMode}
	{
		call AmIInvis "CastSpellRange()"
		if ${Return.Equal[TRUE]}
			return -1
	}

	;if we are moving and we can't cast while moving, lets not cast...
	if ${Me.IsMoving} && !${castwhilemoving}
	{
		;Debug:Echo["CastSpellRange() -- I'm moving and castwhilemoving is set to FALSE"]
		return -1
	}

	;if a target was specified, and we can't find it, lets not try to cast
	if ${TargetID}>0 && !${Actor[${TargetID}](exists)}
	{
		;Debug:Echo["CastSpellRange() -- TargetID was greater than zero; however, it doesn't exist!"]
		return -1
	}

	;if casting on killtarget, lets make sure it is still valid and find new one if needed
	if ${TargetID} && ${TargetID}==${KillTarget}
	{
		call VerifyTarget ${TargetID}
		if ${Return.Equal[FALSE]}
		{
			;Debug:Echo["CastSpellRange() -- TargetID was the same was KillTarget; however, VerifyTarget() reported it as invalid"]
			return -1
		}
	}


	do
	{
		if ${tempvar} > 0
		{
			AbilityName:Set[${SpellType[${tempvar}]}]
			AbilityID:Set[${Me.Ability[${AbilityName}].ID}]
		}
		else
			AbilityName:Set[${Me.Ability[id,${AbilityID}].Name}]

		;; This should never happen..but just in case...
		if ${AbilityID} <= 0
			AbilityID:Set[${Me.Ability[${AbilityName}].ID}]

		;Debug:Echo["CastSpellRange() -- AbilityID: ${AbilityID} -- AbilityName: ${AbilityName}"]

		if ${AbilityName.Length}
		{
			;if not ready, we can't cast it
			if !${IgnoreIsReady} && !${Me.Ability[id,${AbilityID}].IsReady}
				break

			;lets make sure the target doesn't already have the spell
			if ${TargetID}
			{
				fndspell:Set[FALSE]
				if !${IgnoreMaintained}
				{
					tempgrp:Set[1]
					do
					{
						if ${Me.Maintained[${tempgrp}].Name.Equal[${AbilityName}]} && ${Me.Maintained[${tempgrp}].Target.ID}==${TargetID} && (${Me.Maintained[${tempgrp}].Duration}>${refreshtimer} || ${Me.Maintained[${tempgrp}].Duration}==-1)
						{
							fndspell:Set[TRUE]
							break
						}
					}
					while ${tempgrp:Inc}<=${Me.CountMaintained}
				}

				if !${fndspell}
				{
					; if no range is passed, lets make sure we're not out of range and adjust
					if !${xvar1} && ${Me.Ability[id,${AbilityID}].MaxRange}>0 && ${Actor[${TargetID}].Distance}>${Position.GetSpellMaxRange[${TargetID},0,${Me.Ability[id,${AbilityID}].MaxRange}]}
					{
						;lets not move beyond defined threshold
						if ${Math.Calc64[${Actor[${TargetID}].Distance} - ${Position.GetSpellMaxRange[${TargetID},0,${Me.Ability[id,${AbilityID}].MaxRange}]}]}<${OORThreshold}
						{
							;echo DEBUG::CastSpellRange - OOR detected, Distance to mob - ${Actor[${TargetID}].Distance}, Distance to MaxRange ${Position.GetSpellMaxRange[${TargetID},0,${Me.Ability[id,${AbilityID}].MaxRange}]}, Ability = ${AbilityName}/${AbilityID}
							call CheckPosition 2 ${xvar2} ${TargetID} ${tempvar} ${castwhilemoving}
						}
					}
					elseif ${xvar1} || ${xvar2}
					{
						;echo DEBUG::CastSpellRange - Position check: Range - ${xvar1} Position - ${xvar2} Target - ${TargetID} Ability - ${tempvar}
						call CheckPosition ${xvar1} ${xvar2} ${TargetID} ${tempvar} ${castwhilemoving}
					}
					if ${Target(exists)}
						originaltarget:Set[${Target.ID}]
				}
				else
					continue
			}

			;We need to see if we're already casting and we've been given a castspellwhen directive
			if ${Me.CastingSpell} && ${CastSpellWhen}
			{
				;Immediate Cast Directive!
				if ${CastSpellWhen}==1
					call CastSpellNOW "${AbilityName}" ${AbilityID} ${TargetID} ${castwhilemoving}
				else
				{
					;lets wait for current cast to end
					while ${Me.CastingSpell}
					{
						wait 2
					}
					; now cast
					call CastSpell "${AbilityName}" ${AbilityID} ${TargetID} ${castwhilemoving}
				}
			}
			else
			{
				;if we're casting the same spell that was already queued, we need to wait till it finishes
				if ${AbilityName.Equal[${LastQueuedAbility}]} && ${Me.CastingSpell}
				{
					;lets wait for current cast to end
					while ${Me.CastingSpell}
					{
						wait 2
					}
					; now cast
					call CastSpell "${AbilityName}" ${AbilityID} ${TargetID} ${castwhilemoving}
				}
				;if current spell target is the same as last spell target, we can queue otherwise wait till complete
				elseif ${TargetID}==${LastCastTarget}
					call CastSpell "${AbilityName}" ${AbilityID} ${TargetID} ${castwhilemoving}
				else
				{
					;lets wait for current cast to end
					while ${Me.CastingSpell}
					{
						wait 2
					}
					; now cast
					call CastSpell "${AbilityName}" ${AbilityID} ${TargetID} ${castwhilemoving}
				}
			}

			;reset to orriginal target - do we really need to do this?
			if ${Actor[${originaltarget}](exists)} && ${Target.ID}!=${originaltarget}
			{
				target ${originaltarget}
				wait 10 ${Target.ID}==${originaltarget}
			}

			LastCastTarget:Set[${TargetID}]

			if ${notall}==1
				return -1
		}

		if !${finish}
			return ${Me.Ability[id,${AbilityID}].TimeUntilReady}

	}
	while ${tempvar:Inc}<=${finish}

	return ${Me.Ability[id,${AbilityID}].TimeUntilReady}
}


function CastSpellNOW(string spell, int spellid, uint TargetID, bool castwhilemoving)
{
	;echo CastSpellNow ${spell}
	variable int Counter

	if !${spellid}
		spellid:Set[${Me.Ability[${spell}].ID}]

	if !${Me.ToActor.InCombatMode}
	{
		call AmIInvis "CastSpellNOW()"
		if ${Return.Equal[TRUE]}
			return
	}

	if ${Me.IsMoving} && !${castwhilemoving}
		return

	;; Stop casting whatever is casting
	if ${Me.CastingSpell}
	{
		do
		{
			eq2execute /cancel_spellcast
			wait 3
		}
		while ${Me.CastingSpell}
	}

	if !${Me.Ability[id,${spellid}].IsReady}
		return

	if !${Actor[${TargetID}].Type.Equal[Me]}
	{
		if ${TargetID} && ${Target.ID}!=${TargetID} && ${TargetID}!=${Target.Target.ID} && !${Actor[${TargetID}].Type.Equal[PC]}
		{
			;Debug:Echo["EQ2Bot-Debug:: Target.ID != TargetID && TargetID != Target.Target.ID && !Actor[TargetID].Type.Equal[PC] --> Returning"]
			Actor[${TargetID}]:DoTarget
			wait 10 ${Target.ID}==${TargetID}
		}
	}

	CurrentAction:Set[Casting NOW '${spell}']

	;; Disallow some abilities that are named the same as crafting abilities.
	;; 1. Agitate (CraftingID: 601887089 -- Fury Spell ID: 1287322154)
	if (${Me.Ability[${spell}].ID} == 601887089)
	{
		spellid:Set[1287322154]
		Me.Ability[id,1287322154]:Use
	}
	else
	{
		if ${Actor[${TargetID}].Type.Equal[PC]} || ${Actor[${TargetID}].Type.Equal[Me]}
			eq2execute /useabilityonplayer ${Actor[${TargetID}].Name} "${spell}"
		else
			Me.Ability[id,${spellid}]:Use
	}
	wait 2
	; reducing this too much will cause problems ... 4 seems to be a sweet spot
	wait 2 ${Me.CastingSpell}

	;removed queuing, this is CASTNOW function, we want the thing to really cast!
	while ${Me.CastingSpell}
	{
		wait 1
	}

	return SUCCESS
}

function CastSpell(string spell, uint spellid, uint TargetID, bool castwhilemoving, bool WaitWhileCasting)
{
	;echo CastSpell ${spell}
	variable int Counter
	variable float TimeOut
	;Debug:Echo["EQ2Bot-Debug:: CastSpell('${spell}',${spellid},${TargetID},${castwhilemoving},${WaitWhileCasting})"]
	;Debug:Echo["EQ2Bot-Debug:: LastQueuedAbility: ${LastQueuedAbility}"]
	;Debug:Echo["EQ2Bot-Debug:: ${spell} ready?  ${Me.Ability[${spell}].IsReady}"]
	;Debug:Echo["EQ2Bot-Debug:: castwhilemoving: ${castwhilemoving} - WaitWhileCasting: ${WaitWhileCasting}"]
	;Debug:Echo["EQ2Bot-Debug:: ------------------------------------------------"]

	if !${spellid}
		spellid:Set[${Me.Ability[${spell}].ID}]


	call ProcessTriggers

	;return if trying to cast currently queued ability
	if (${Me.ToActor.InCombatMode} && ${spell.Equal[${LastQueuedAbility}]} && ${Me.CastingSpell})
	{
		;Debug:Echo["EQ2Bot-Debug:: spell == LastQueuedAbility && Me.CastingSpell && Me.ToActor.InCombatMode --> Returning"]
		LastQueuedAbility:Set[]
		return
	}

	;return if invis and not in combat - we don't want to break invis out of combat
	if !${Me.ToActor.InCombatMode}
	{
		call AmIInvis "CastSpell()"
		if ${Return.Equal[TRUE]}
			return
	}

	;return if we are moving and this spell requires no movement
	if ${Me.IsMoving} && !${castwhilemoving}
	{
		;Debug:Echo["EQ2Bot-Debug:: Me.IsMoving is ${Me.IsMoving} and this spell should not be cast while moving."]
		LastQueuedAbility:Set[${spell}]
		return
	}

	if !${Actor[${TargetID}].Type.Equal[Me]}
	{
		if ${TargetID} && ${Target.ID}!=${TargetID} && ${TargetID}!=${Target.Target.ID} && !${Actor[${TargetID}].Type.Equal[PC]}
		{
			;Debug:Echo["EQ2Bot-Debug:: Target.ID != TargetID && TargetID != Target.Target.ID && !Actor[TargetID].Type.Equal[PC] --> Returning"]
			Actor[${TargetID}]:DoTarget
			wait 10 ${Target.ID}==${TargetID}
		}
	}

	;Debug:Echo["EQ2Bot-Debug:: Queueing '${spell}'"]
	CurrentAction:Set[Queueing '${spell}']

	;; Disallow some abilities that are named the same as crafting abilities.
	;; 1. Agitate (CraftingID: 601887089 -- Fury Spell ID: 1287322154)
	if (${Me.Ability[${spell}].ID} == 601887089)
	{
		spellid:Set[1287322154]
		Me.Ability[id,1287322154]:Use
	}
	else
	{
		if ${Actor[${TargetID}].Type.Equal[PC]} || ${Actor[${TargetID}].Type.Equal[Me]}
			eq2execute /useabilityonplayer ${Actor[${TargetID}].Name} "${spell}"
		else
			Me.Ability[id,${spellid}]:Use
	}


	;; this is ghetto ..but required
	wait 4
	if (!${Me.Ability[id,${spellid}].IsQueued})
		wait 4

	if (${Me.Ability[id,${spellid}].CastingTime} < .6)
	{
		;Debug:Echo["EQ2Bot-Debug:: ${spell}'s CastingTime < .6 (${Me.Ability[id,${spellid}].CastingTime}) --> Returning"]
		LastQueuedAbility:Set[${spell}]
		return
	}
	elseif (${Me.Ability[id,${spellid}].CastingTime} <= 7)
	{
		; if we're not casting a spell and the current spell is not queued, then we have a problem
		if !${Me.Ability[id,${spellid}].IsQueued} && !${Me.CastingSpell}
		{
			;echo "DEBUG:: CastSpell() -- Nothing is queued and we're not currently casting a spell.  Restting cache and trying again."
			ISXEQ2:ClearAbilitiesCache
			if (${Me.Ability[${spell}].ID} == 601887089)
			{
				spellid:Set[1287322154]
				Me.Ability[id,1287322154]:Use
			}
			else
			{
				if ${Actor[${TargetID}].Type.Equal[PC]} || ${Actor[${TargetID}].Type.Equal[Me]}
					eq2execute /useabilityonplayer ${Actor[${TargetID}].Name} "${spell}"
				else
					Me.Ability[id,${spellid}]:Use
			}
			;; this is ghetto ..but required
			wait 4
			if (!${Me.Ability[id,${spellid}].IsQueued})
				wait 4
			if (${Me.Ability[id,${spellid}].CastingTime} < .6)
			{
				;Debug:Echo["EQ2Bot-Debug:: ${spell}'s CastingTime < .6 (${Me.Ability[id,${spellid}].CastingTime}) --> Returning"]
				LastQueuedAbility:Set[${spell}]
				return
			}
			elseif (${Me.Ability[id,${spellid}].CastingTime} > 7 || ${WaitWhileCasting})
			{
				wait 4
				;; Long casting spells such as pets, diety pets, etc.. are a pain -- this is a decent solution to those few abilities that take
				;; more than 7 seconds to cast.
				if (${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${LastQueuedAbility}]})
				{
					do
					{
						CurrentAction:Set["Waiting for '${LastQueuedAbility}' to finish casting..."]
						waitframe
					}
					while ${Me.CastingSpell}
					wait 5
				}
		
				if (${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${spell}]})
				{
					do
					{
						CurrentAction:Set[Casting '${spell}']
						waitframe
					}
					while ${Me.CastingSpell}
					wait 2
					return
				}
			}
		}
	}
	elseif (${Me.Ability[id,${spellid}].CastingTime} > 7 || ${WaitWhileCasting})
	{
		wait 4
		; if we're not casting a spell and the current spell is not queued, then we have a problem
		if !${Me.Ability[id,${spellid}].IsQueued} && !${Me.CastingSpell}
		{
			;echo "DEBUG:: CastSpell() -- Nothing is queued and we're not currently casting a spell.  Restting cache and trying again."
			ISXEQ2:ClearAbilitiesCache
			if (${Me.Ability[${spell}].ID} == 601887089)
			{
				spellid:Set[1287322154]
				Me.Ability[id,1287322154]:Use
			}
			else
			{
				if ${Actor[${TargetID}].Type.Equal[PC]} || ${Actor[${TargetID}].Type.Equal[Me]}
					eq2execute /useabilityonplayer ${Actor[${TargetID}].Name} "${spell}"
				else
					Me.Ability[id,${spellid}]:Use
			}
			;; this is ghetto ..but required
			wait 4
			if (!${Me.Ability[id,${spellid}].IsQueued})
				wait 4
			if (${Me.Ability[id,${spellid}].CastingTime} < .6)
			{
				;Debug:Echo["EQ2Bot-Debug:: ${spell}'s CastingTime < .6 (${Me.Ability[id,${spellid}].CastingTime}) --> Returning"]
				LastQueuedAbility:Set[${spell}]
				return
			}
			elseif (${Me.Ability[id,${spellid}].CastingTime} > 7 || ${WaitWhileCasting})
			{
				wait 4
				;; Long casting spells such as pets, diety pets, etc.. are a pain -- this is a decent solution to those few abilities that take
				;; more than 7 seconds to cast.
				if (${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${LastQueuedAbility}]})
				{
					do
					{
						CurrentAction:Set["Waiting for '${LastQueuedAbility}' to finish casting..."]
						waitframe
					}
					while ${Me.CastingSpell}
					wait 5
				}
		
				if (${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${spell}]})
				{
					do
					{
						CurrentAction:Set[Casting '${spell}']
						waitframe
					}
					while ${Me.CastingSpell}
					wait 2
					return
				}
			}
		}
		else
		{
			;; Long casting spells such as pets, diety pets, etc.. are a pain -- this is a decent solution to those few abilities that take
			;; more than 7 seconds to cast.
			if (${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${LastQueuedAbility}]})
			{
				do
				{
					CurrentAction:Set["Waiting for '${LastQueuedAbility}' to finish casting..."]
					waitframe
				}
				while ${Me.CastingSpell}
				wait 5
			}
	
			if (${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${spell}]})
			{
				do
				{
					CurrentAction:Set[Casting '${spell}']
					waitframe
				}
				while ${Me.CastingSpell}
				wait 2
				return
			}
		}
	}

	;Debug:Echo["EQ2Bot-Debug:: Queuing: ${spell}"]
	;Debug:Echo["EQ2Bot-Debug:: Me.CastingSpell: ${Me.CastingSpell}"]
	;Debug:Echo["EQ2Bot-Debug:: Spells.Casting (GameData): ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}"]


	if (${Me.CastingSpell} && !${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${spell}]})
	{
		Counter:Set[0]
		;Debug:Echo["EQ2Bot-Debug:: ---${spell} Queued ... waiting for '${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}' to finish casting..."]
		CurrentAction:Set[---${spell} Queued ... waiting for '${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}' to finish casting...]
		TimeOut:Set[${Math.Calc[${Me.Ability[${LastQueuedAbility}].CastingTime}*10]}]
		do
		{
			wait 2
			Counter:Inc[5]

			if (${Counter} > ${TimeOut})
				break

			if ${Counter} == 10 || ${Counter} == 20 || ${Counter} == 30 || ${Counter} == 40
			{
				call VerifyTarget ${TargetID}
				if ${Return.Equal[FALSE]}
				{
					CurrentAction:Set[]
					LastQueuedAbility:Set[${spell}]
					return
				}
			}

			if ${Counter} >= 50 && ${Me.ToActor.InCombatMode}
			{
				echo "EQ2Bot-Debug:: ---Timed out waiting for ${spell} to cast....(${Math.Calc[${Me.Ability[${LastQueuedAbility}].CastingTime}*10]})"
				CurrentAction:Set[]
				return
			}
			elseif !${Me.ToActor.InCombatMode} && ${Counter} > 100
			{
				echo "EQ2Bot-Debug:: ---Timed out waiting for ${spell} to cast....(${Math.Calc[${Me.Ability[${LastQueuedAbility}].CastingTime}*10]})"
				CurrentAction:Set[]
				return
			}
			;Debug:Echo["EQ2Bot-Debug:: Waiting..."]
		}
		while (${Me.CastingSpell} && !${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${spell}]})
	}

	Counter:Set[0]
	if (!${LastQueuedAbility.Equal[${spell}]})
	{
		if (${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${LastQueuedAbility}]})
		{
			;Debug:Echo["EQ2Bot-Debug:: ---Waiting for ${spell} to cast"]
			CurrentAction:Set[---Waiting for ${spell} to cast]
			TimeOut:Set[${Math.Calc[${Me.Ability[${LastQueuedAbility}].CastingTime}*10]}]
			;Debug:Echo["TimeOut: ${TimeOut}"]
			do
			{
				wait 2
				Counter:Inc[2]

				if (${Counter} > ${Math.Calc[${TimeOut}+2]})
				{
					Me.Ability[id,${spellid}]:Use
					break
				}

				if ${Counter} == 10 || ${Counter} == 20 || ${Counter} == 30 || ${Counter} == 40
				{
					call VerifyTarget ${TargetID}
					if ${Return.Equal[FALSE]}
					{
						CurrentAction:Set[]
						return
					}
				}

				if ${Counter} >= 50 && ${Me.ToActor.InCombatMode}
				{
					echo "EQ2Bot-Debug:: ---Timed out waiting for ${spell} to cast....(${Math.Calc[${Me.Ability[${LastQueuedAbility}].CastingTime}*10]})"
					CurrentAction:Set[]
					return
				}
				elseif !${Me.ToActor.InCombatMode} && ${Counter} > 100
				{
					echo "EQ2Bot-Debug:: ---Timed out waiting for ${spell} to cast....(${Math.Calc[${Me.Ability[${LastQueuedAbility}].CastingTime}*10]})"
					CurrentAction:Set[]
					return
				}
				;Debug:Echo["EQ2Bot-Debug:: Waiting..."]
				CurrentAction:Set[---Waiting for ${spell} to cast]
			}
			while (${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${LastQueuedAbility}]})
		}
	}

	wait 2

	; This will go off on really fast casting spells....Used just for debugging purposes....
	if !${Me.CastingSpell}
	{
		;Debug:Echo["EQ2Bot-Debug:: We should be casting a spell now, but we're not!?"]
		;Debug:Echo["EQ2Bot-Debug:: Me.Ability[${spell}].IsQueued} == ${Me.Ability[${spell}].IsQueued}"]
		;Debug:Echo["EQ2Bot-Debug:: EQ2DataSourceContainerGameData].GetDynamicData[Spells.Casting].ShortLabel == ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel}"]
		wait 2
	}

	LastQueuedAbility:Set[${spell}]
	CurrentAction:Set[Casting '${spell}']
	;Debug:Echo["EQ2Bot-Debug:: Casting Spell -- END CastSpell()"]
	;Debug:Echo["EQ2Bot-Debug:: --------------"]

	return SUCCESS
}

function Combat(bool PVP=0)
{
	variable int tempvar
	variable bool ContinueCombat
	variable float TankToTargetDistance

	movinghome:Set[FALSE]
	avoidhate:Set[FALSE]
	
	if (${DoNoCombat})
	{
		KillTarget:Set[0]
		return
	}
	
	;Debug:Echo["Combat() - Me.ToActor.WhoFollowing: ${Me.ToActor.WhoFollowing}"]
	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)} && !${Me.IsMoving})
	{
		;Debug:Echo["Combat() - Stopping Autofollow"]
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 2
	}	
	
	if !${Actor[${KillTarget}](exists)}
		return

	if ${Me.ToActor.IsDead}
		return
		
	FollowTask:Set[2]
	; Make sure we are still not moving when we enter combat
	if (${Me.IsMoving} && !${NoAutoMovement})
	{
		press -release ${forward}
		press -release ${backward}
		wait 20 !${Me.IsMoving}
	}


	target ${KillTarget}
	wait 2

	if ${MainTank}
		face ${Target.X} ${Target.Z}

	if ${MainTank} && !${Target(exists)}
		return

	UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
	do
	{
		if !${MainTank}
		{
			if !${Actor[${KillTarget}](exists)}
				echo "EQ2Bot:: KillTarget did not exist in Combat() routine ... how did that happen?"
			else
				target ${KillTarget}
		}

		if ${ContinueCombat}
		{
			ContinueCombat:Set[FALSE]

			target ${KillTarget}
			wait 1

			if ${MainTank}
				face ${Target.X} ${Target.Z}
		}

		if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead}
		{
			EQ2Execute /target_none
			KillTarget:Set[0]
			break
		}

		if ${Me.ToActor.IsDead}
			return

		do
		{
			;Hmmm....
			if !${Actor[${KillTarget}].InCombatMode}
				break

			while ${Actor[${KillTarget}].Distance} > ${MARange}
			{
				wait 5
				if !${Actor[${KillTarget}](exists)}
					break
				call ProcessTriggers
			}

			if !${Actor[${KillTarget}](exists)}
			{
				EQ2Execute /target_none
				KillTarget:Set[0]
				break
			}

			;face ${Target.X} ${Target.Y} ${Target.Z}

			if (${Mob.ValidActor[${KillTarget}]} || ${PVP})
			{
				gRtnCtr:Set[1]
				do
				{
					call ProcessTriggers

					;if ${PathType}==4 && ${MainTank}
					;	call ScanAdds

					if ${MainTank}
					{
						Target ${KillTarget}
						waitframe

						if ${Actor[${KillTarget}].Target.ID}==${Me.ID}
							call CheckMTAggro
						else
						{
							call Lost_Aggro ${KillTarget}
							if ${UseCustomRoutines}
								call Custom__Lost_Aggro ${KillTarget}
						}
					}
					else
					{
						Mob:CheckMYAggro

						if ${Actor[${MainAssistID}].IsDead}
						{
							EQ2Bot:MainAssist_Dead
							break
						}

						if ${Actor[${MainTankID}].IsDead}
						{
							EQ2Bot:MainTank_Dead
							break
						}

						if ${haveaggro} && !${MainTank} && ${Actor[${aggroid}](exists)}
						{
							call Have_Aggro ${aggroid}
							if ${UseCustomRoutines}
								call Custom__Have_Aggro ${aggroid}
						}
					}

					do
					{
						waitframe
						call ProcessTriggers
					}
					while ${MainTank} && ${Actor[${KillTarget}].Target.ID} == ${Me.ID} && ${Actor[${KillTarget}].Distance} > ${MARange}

					if !${Me.AutoAttackOn} && ${AutoMelee}
						EQ2Execute /toggleautoattack

					call Combat_Routine ${gRtnCtr}
					if ${Return.Equal[CombatComplete]}
					{
						isstuck:Set[FALSE]
						if !${Me.ToActor.InCombatMode}
							CurrentAction:Set["Idle..."]
						gRtnCtr:Set[40]
					}

					if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead}
					{
						EQ2Execute /target_none
						KillTarget:Set[0]
						break
					}

					if !${NoAutoMovementInCombat} || !${NoAutoMovement}
					{
						if ${AutoMelee} && !${MainTank}
						{
							;check valid rear position
							if ((${Math.Calc64[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>-65 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<65) || (${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>305 || ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<-305)) && ${Actor[${KillTarget}].Distance}<5
							{
								;we're behind and in range
							}
							;check right flank
							elseif ((${Math.Calc64[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>-295)) && ${Actor[${KillTarget}].Distance}<5
							{
								;we're right flank and in range
							}
							;check left flank
							elseif ((${Math.Calc64[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<295)) && ${Actor[${KillTarget}].Distance}<5
							{
								;we're left flank and in range
							}
							elseif ${Actor[${KillTarget}].Target.ID}==${Me.ID}
							{
								;we have aggro, move to the maintank
								call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 1
								wait 2
								do
								{
									waitframe
									call ProcessTriggers
								}
								while (${IsMoving} || ${Me.IsMoving})
							}
							else
							{
								if ${MainTank}
									call CheckPosition 1 0 ${KillTarget} 0 1
								else
								{
									TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
									;echo "Combat()-DEBUG:: TankToTargetDistance: ${TankToTargetDistance}"
									if (${TankToTargetDistance} <= 7.5)
									{
											call CheckPosition 1 1 ${KillTarget} 0 0
									}
								}
							}
						}
						elseif ${Actor[${KillTarget}].Distance}>40 || ${Actor[${MainTankID}].Distance}>40
						{
							call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 25
							wait 2
							do
							{
								waitframe
								call ProcessTriggers
							}
							while (${IsMoving} || ${Me.IsMoving})
						}
					}

					if ${Me.ToActor.Power}<55 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
					{
						if ${Math.Calc64[${Time.Timestamp}-${mstimer}]}>70
						{
							Me.Inventory[ExactName,ManaStone]:Use
							mstimer:Set[${Time.Timestamp}]
							wait 2
							do
							{
								waitframe
							}
							while ${Me.CastingSpell}
						}
					}

					if ${AutoSwitch} && !${MainTank} && (${Actor[${KillTarget}].Health}>30 || ${Me.Raid}) && (${Actor[${MainAssistID}].Target.Type.Equal[NPC]} || ${Actor[${MainAssistID}].Target.Type.Equal[NamedNPC]}) && ${Actor[${MainAssistID}].Target.InCombatMode}
					{
						variable uint ActorID
						ActorID:Set[${Actor[${MainAssistID}].Target.ID}]
						if ${Mob.ValidActor[${ActorID}]}
						{
							KillTarget:Set[${ActorID}]
							target ${KillTarget}
						}
					}
					call ProcessTriggers
				}
				while ${gRtnCtr:Inc}<=40 && ${Mob.ValidActor[${KillTarget}]}
			}
			else
				break

			;;;;
			;;;; Custom Combat Routines (per character)
			;;;;
			if (${UseCustomRoutines} && ${Mob.ValidActor[${KillTarget}]})
			{
				gRtnCtr:Set[1]
				do
				{
					call ProcessTriggers

					if ${PathType}==4 && ${MainTank}
						call ScanAdds

					if ${MainTank}
					{
						if ${Target.Target.ID}==${Me.ID}
							call CheckMTAggro
						else
							call Custom__Lost_Aggro ${Target.ID}
					}
					else
					{
						Mob:CheckMYAggro

						if ${Actor[${MainAssistID}].IsDead}
						{
							EQ2Bot:MainAssist_Dead
							break
						}

						if ${Actor[${MainTankID}].IsDead}
						{
							EQ2Bot:MainTank_Dead
							break
						}

						if ${haveaggro} && !${MainTank} && ${Actor[${aggroid}].Name(exists)}
							call Custom__Have_Aggro
					}

					call Custom__Combat_Routine ${gRtnCtr}
					if ${Return.Equal[CombatComplete]}
					{
						if !${Me.ToActor.InCombatMode}
							CurrentAction:Set["Idle..."]
						gRtnCtr:Set[40]
					}

					if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
					{
						if ${Math.Calc64[${Time.Timestamp}-${mstimer}]}>70
						{
							Me.Inventory[ExactName,ManaStone]:Use
							mstimer:Set[${Time.Timestamp}]
							wait 2
							do
							{
								waitframe
							}
							while ${Me.CastingSpell}
						}
					}

					if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead}
					{
						EQ2Execute /target_none
						KillTarget:Set[0]
						break
					}

					if ${AutoSwitch} && !${MainTank} && (${Actor[${KillTarget}].Health}>30 || ${Me.Raid}) && (${Actor[${MainAssistID}].Target.Type.Equal[NPC]} || ${Actor[${MainAssistID}].Target.Type.Equal[NamedNPC]}) && ${Actor[${MainAssistID}].Target.InCombatMode}
					{
						ActorID:Set[${Actor[${MainAssistID}].Target.ID}]
						if ${Mob.ValidActor[${ActorID}]}
						{
							KillTarget:Set[${ActorID}]
							target ${KillTarget}
						}
					}
					call ProcessTriggers
				}
				while ${gRtnCtr:Inc}<=40 && ${Mob.ValidActor[${KillTarget}]}
			}
			;;;; END Combat_Routine Loop ;;;;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			if !${CurrentTask}
				Script:End

			if !${Actor[${KillTarget}](exists)}
			{
				EQ2Execute /target_none
				KillTarget:Set[0]
				break
			}
			if ${Me.ToActor.IsDead}
			{
				EQ2Execute /target_none
				break
			}
			call ProcessTriggers
		}
		while ((!${Actor[${KillTarget}].IsDead} && ${Mob.ValidActor[${KillTarget}]}) || ${PVP})
		;;; END LOOP DEALING WITH CURRENT TARGET ;;;;;;

		disablebehind:Set[FALSE]
		disablefront:Set[FALSE]

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Target New Mob (if applicable)
		;;
		if !${MainTank} && ${Actor[${MainAssistID}](exists)}
		{
			if ${Mob.Detect}
				wait 50 ${Actor[${MainAssistID}].Target(exists)}

			if ((${Actor[${MainAssistID}].Target(exists)} && ${Mob.ValidActor[${Actor[${MainAssistID}].Target.ID}]}) || ${PVP})
			{
				KillTarget:Set[${Actor[${MainAssistID}].Target.ID}]
				Actor[${KillTarget}]:DoTarget
				;Actor[${KillTarget}]:DoFace
				wait 10 ${Target.ID}==${TargetID}
				ContinueCombat:Set[TRUE]
				continue
			}
			else
				break
		}
		elseif ${MainTank} && !${Me.IsMoving}
		{
			if ${Mob.Detect}
			{
				variable uint AggroMob
				AggroMob:Set[${Mob.NearestAggro}]

				if ${AggroMob} > 0
				{
					if ${KillTarget} != ${AggroMob}
					{
						CurrentAction:Set["Targetting Nearest Aggro Mob and continuing combat"]
						echo "EQ2Bot-Combat():: Targetting Nearest Aggro Mob and continuing combat"
						KillTarget:Set[${AggroMob}]
					}
					target ${AggroMob}
					Actor[${KillTarget}]:DoFace
					ContinueCombat:Set[TRUE]
				}
			}
		}

		if ${Me.ToActor.IsDead}
		{
			EQ2Execute /target_none
			break
		}
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		call ProcessTriggers
	}
	while ${Me.ToActor.InCombatMode} || ${ContinueCombat}

	UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Hide

	avoidhate:Set[FALSE]
	checkadds:Set[FALSE]

	gRtnCtr:Set[1]
	do
	{
		call Post_Combat_Routine ${gRtnCtr}
		if ${Return.Equal[PostCombatRoutineComplete]}
		{
			if !${Me.ToActor.InCombatMode}
				CurrentAction:Set["Idle..."]
			gRtnCtr:Set[20]
		}
	}
	while ${gRtnCtr:Inc}<=20

	if ${UseCustomRoutines}
	{
		gRtnCtr:Set[1]
		do
		{
			call Custom__Post_Combat_Routine ${gRtnCtr}
			if ${Return.Equal[PostCombatRoutineComplete]}
			{
				if !${Me.ToActor.InCombatMode}
					CurrentAction:Set["Idle..."]
				gRtnCtr:Set[20]
			}
		}
		while ${gRtnCtr:Inc}<=20
	}

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack



	;Debug:Echo["Calling CheckLootNoMove()"]
	call CheckLootNoMove

	if ${PathType} == 1
	{
		if (!${NoAutoMovementInCombat} || ${NoAutoMovement})
		{
			if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>4
			{
				movinghome:Set[TRUE]
				wait ${Math.Rand[10]} ${Mob.Detect}
				call FastMove ${HomeX} ${HomeZ} 4
				do
				{
					waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
				face ${Math.Rand[45]:Inc[315]}
			}
		}
	}

	if ${MainAssist.NotEqual[${OriginalMA}]} && !${MainTank}
		EQ2Bot:MainAssist_Dead

	if ${MainTankPC.NotEqual[${OriginalMT}]} && !${MainTank}
		EQ2Bot:MainTank_Dead

	if ${PathType} == 4
	{
		if (!${NoAutoMovementInCombat} || !${NoAutoMovement})
		{
			if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>${ScanRange}
			{
				face ${HomeX} ${HomeZ}
				wait ${Math.Rand[10]} ${Mob.Detect}

				tempvar:Set[${Math.Rand[30]:Dec[15]}]
				WPX:Set[${Math.Calc[${tempvar}*${Math.Cos[${Me.Heading}]}-20*${Math.Sin[${Me.Heading}]}+${Me.X}]}]
				WPZ:Set[${Math.Calc[-20*${Math.Cos[${Me.Heading}]}+${tempvar}*${Math.Sin[${Me.Heading}]}+${Me.Z}]}]

				call FastMove ${WPX} ${WPZ} 4
				do
				{
					waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
			}
		}
	}
}

function GetBehind()
{
	variable float X
	variable float Z

	X:Set[${Math.Calc[-4*${Math.Sin[-${Actor[${KillTarget}].Heading}]}+${Actor[${KillTarget}].X}]}]
	Z:Set[${Math.Calc[4*${Math.Cos[-${Actor[${KillTarget}].Heading}]}+${Actor[${KillTarget}].Z}]}]

	call FastMove ${X} ${Z} 4
	if ${Return.Equal[STUCK]}
	{
		disablebehind:Set[TRUE]

		call FastMove ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z} 6
	}

	if ${Actor[${KillTarget}](exists)} && (${KillTarget}!=${Me.ID})
		face ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z}

}

function GetToFlank(int extended)
{
	variable float X
	variable float Z
	variable int tempdir

	if ${direction}
	{
		tempdir:Set[-1]
		if ${extended}
		{
			tempdir:Dec[1]
		}
	}
	else
	{
		tempdir:Set[1]
		if ${extended}
		{
			tempdir:Inc[1]
		}
	}

	X:Set[${Math.Calc[${tempdir}*${Math.Cos[-${Actor[${KillTarget}].Heading}]}+${Actor[${KillTarget}].X}]}]
	Z:Set[${Math.Calc[${tempdir}*${Math.Sin[-${Actor[${KillTarget}].Heading}]}+${Actor[${KillTarget}].Z}]}]

	call FastMove ${X} ${Z} 3
	if ${Return.Equal[STUCK]}
	{
		disablebehind:Set[TRUE]
		call FastMove ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z} 5
	}

	if ${Actor[${KillTarget}](exists)} && (${KillTarget}!=${Me.ID})
		face ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z}
}

function GetinFront()
{
	variable float X
	variable float Z

	;; if you are not the tank, then you should assume the tank is already in front of the mob and move to the TANK instead of the KillTarget
	if ${MainTank}
	{
		X:Set[${Math.Calc[-3*${Math.Sin[${Actor[${KillTarget}].Heading}]}+${Actor[${KillTarget}].X}]}]
		Z:Set[${Math.Calc[-3*${Math.Cos[${Actor[${KillTarget}].Heading}]}+${Actor[${KillTarget}].Z}]}]
	}
	else
	{
		X:Set[${Math.Calc[-3*${Math.Sin[${Actor[${MainTankID}].Heading}]}+${Actor[${MainTankID}].X}]}]
		Z:Set[${Math.Calc[-3*${Math.Cos[${Actor[${MainTankID}].Heading}]}+${Actor[${MainTankID}].Z}]}]
	}
	call FastMove ${X} ${Z} 3
	if ${Return.Equal[STUCK]}
	{
		disablefront:Set[TRUE]
		call FastMove ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z} 5
	}

	if ${Actor[${KillTarget}](exists)} && (${KillTarget}!=${Me.ID})
		face ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z}

	;removing cause this seems stupid
	;wait 4
}

function CheckPosition(int rangetype, int quadrant, uint TID=${KillTarget},int AbilityID, bool castwhilemoving)
{
	; rangetype (1=close, 2=max range, 3=bow shooting)
	; quadrant (0=anywhere, 1=behind, 2=front, 3=flank, 4=rear or flank, 5=front or flank)

	Debug:Echo["CheckPosition(${rangetype},${quadrant},${TID},${AbilityID},${castwhilemoving})"]

	variable float minrange
	variable float maxrange
	variable float destangle
	variable point3f destpoint
	variable point3f destminpoint
	variable point3f destmaxpoint
	variable uint xTimer
	variable int MoveCount
	xTimer:Set[${Script.RunningTime}]

	if ${NoAutoMovement}
	{
		Debug:Echo["CheckPosition() :: NoAutoMovement ON"]
		return
	}

	;if we can't move, we can't move
	if ${Me.ToActor.Speed}<-50 || ${Me.ToActor.IsRooted}
	{
		Debug:Echo["CheckPosition() :: We are rooted or have 0 movement speed."]
		return
	}

	if (${Me.ToActor.InCombatMode} || ${Actor[${MainTankID}].InCombatMode})
	{
		if ${NoAutoMovementInCombat}
		{
			Debug:Echo["CheckPosition() :: NoAutoMovementInCombat ON"]
			return
		}
		;Bad idea, what if we are checking position to cast in combat rez?
		;if (!${Actor[${TID}](exists)} || ${Actor[${TID}].IsDead})
		;{
		;	Debug:Echo["CheckPosition() :: In combat, but current Target does not exist and/or is dead."]
		;	return
		;}
	}

	;lets wait if we're currently casting and we don't want to interupt
	if ${Me.CastingSpell} && !${MainTank} && !${castwhilemoving}
	{
		while ${Me.CastingSpell}
		{
			;echo DEBUG::CheckPostion - waiting on spell
			waitframe
		}
	}

	switch ${rangetype}
	{
		case NULL
		case 0
			if ${AutoMelee}
			{
				minrange:Set[.1]
				maxrange:Set[${Position.GetMeleeMaxRange[${TID}]}]
			}
			else
			{
				minrange:Set[.1]
				maxrange:Set[${Position.GetMeleeMaxRange[${TID}]}]
			}
			break
		case 1
			minrange:Set[.1]
			maxrange:Set[${Position.GetMeleeMaxRange[${TID}]}]
			break
		case 2
			if ${AutoMelee}
			{
				minrange:Set[.1]
				maxrange:Set[${Position.GetMeleeMaxRange[${TID}]}]
			}
			else
			{
				minrange:Set[4]
				maxrange:Set[${Position.GetSpellMaxRange[${TID},0,${Me.Ability[${SpellType[${AbilityID}]}].MaxRange}]}]
			}
			break
		case 3
			minrange:Set[${Math.Calc[${Me.Equipment[Ranged].MinRange}]}+.75+${Position.GetBaseMaxRange[${TID}]}]}]
			if ${Me.Equipment[Ranged].Type.Equal[Weapon]}
				maxrange:Set[${Position.GetSpellMaxRange[${TID},${Me.Equipment[Ranged].Range}]}]
			else
				maxrange:Set[${Position.GetSpellMaxRange[${TID}]}]
			break
	}

	if ${Actor[${KillTarget}].Target.ID}==${Me.ID} && ${Actor[${KillTarget}].Target.ID}==${TID} && ${AutoMelee}
	{
		minrange:Set[0]
		maxrange:Set[${Position.GetMeleeMaxRange[${TID}]}]
	}

	if ${disablebehind} && (${quadrant}==1 || ${quadrant}==3 || ${quadrant}==4)
		quadrant:Set[5]

	;echo DEBUG:: CheckPosition - tid ${TID} -rangetype ${rangetype} - minrange ${minrange} - maxrange ${maxrange} - quadrant ${quadrant}
	switch ${quadrant}
	{
		case 0
			destangle:Set[]
			break
		case 1
			destangle:Set[180]
			break
		case 2
			destangle:Set[0]
			break
		case 3
			destangle:Set[90]
			break
		case 4
			destangle:Set[180]
			break
		case 5
			destangle:Set[0]
			break
	}

	if ${PathType}==2
	{
		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>5 && ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}<10 && ${Me.ToActor.InCombatMode} && !${lostaggro}
		{
			if ${Me.CastingSpell} && !${MainTank} && !${castwhilemoving}
			{
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
			}

			call FastMove ${HomeX} ${HomeZ} 3
			return
		}
	}


	;
	; ok which point is closer our min range or max range, will vary depending on our vector to mob
	; we now use Position object for this
	;
	destpoint:Set[${Position.FindDestPoint[${TID},${minrange},${maxrange},${destangle}]}]


	;
	;if distance over 75, its probably not safe to fastmove
	;
	if ${Math.Distance[${Me.ToActor.Loc},${destpoint}]}>75
		return TOOFARAWAY

	;
	; if we're as close as we need to be lets just strafe
	;
	if ${Actor[${TID}].Distance2D}<${maxrange} && ${Actor[${TID}].Distance2D}>${minrange}
	{
		if ${quadrant}
		{
			;echo DEBUG:: CheckPosition Already Close to target, Checking Quadrant
			call CheckQuadrant ${TID} ${quadrant}
		}
		;verify distance and return
		if ${Actor[${TID}].Distance2D}<${maxrange} && ${Actor[${TID}].Distance2D}>${minrange}
		{	
			if ${TID}
				face ${Actor[${TID}].X} ${Actor[${TID}].Z}
			return ${Return}
		}
	}

	;
	;now lets first make sure we're not already there; is this really needed given previous check?!?
	;
	;if ${Math.Distance[${Me.ToActor.Loc},${destpoint}]}<3
	;{
	;	echo DEBUG::CheckPosition -
	;	call CheckQuadrant ${TID} ${quadrant}
	;	return ${Return}
	;}

	;
	;if we didn't return already, we're too far away
	;

	;if melee is on we'll face the target if its killtarget
	if ${Actor[${TID}](exists)} && ${KillTarget}==${TID} && ${Me.AutoAttackOn}
	{
		;echo DEBUG::CheckPosition - Facing KillTarget
		face ${Actor[${TID}].X} ${Actor[${TID}].Z}
	}


	;we'll loop over movement checks until we are there, or we've looped 3 times.
	do
	{
		;lets check if our destination has changed significantly, if so update it
		if ${Math.Distance[${destpoint},${Position.FindDestPoint[${TID},${minrange},${maxrange},${destangle}]}]}>4
			destpoint:Set[${Position.FindDestPoint[${TID},${minrange},${maxrange},${destangle}]}]

		;echo DEBUG::CheckPosition - Currently not stuck, attempting FastMove to destination
		call FastMove ${destpoint.X} ${destpoint.Z} 2

	}
	while ${MoveCount:Inc}<4 && !${isstuck} && (${Actor[${TID}].Distance2D}<${maxrange} && ${Actor[${TID}].Distance2D}>${minrange})


	;
	;check quadrant due to fastmove precision
	;
	if ${quadrant}
		call CheckQuadrant ${TID} ${quadrant}

	;
	;Final Positioning Tweaks
	;
	if ${AutoMelee} && ${Actor[${TID}].Distance}<15 && ${Actor[${TID}].Distance}>${maxrange}
	{
		xTimer:Set[${Script.RunningTime}]
		Actor[${TID}]:DoFace
		press -hold ${forward}
		do
		{
			Actor[${TID}]:DoFace
			wait 1
		}
		while ${Actor[${TID}](exists)} && ${Actor[${TID}].Distance}>${maxrange} && ((${Script.RunningTime}-${xTimer}) < 5000)
		press -release ${forward}
	}

	if !${AutoMelee} && ${rangetype}>1 && ${Actor[${TID}].Distance}<${minrange}
	{
		xTimer:Set[${Script.RunningTime}]
		Actor[${TID}]:DoFace
		press -hold ${backward}
		do
		{
			Actor[${TID}]:DoFace
			wait 1
		}
		while ${Actor[${TID}](exists)} && ${Actor[${TID}].Distance}<${minrange} && ((${Script.RunningTime}-${xTimer}) < 5000)

		press -release ${backward}
	}

	if !${AutoMelee} && ${rangetype}>1 && ${Actor[${TID}].Distance}>${maxrange}
	{
		xTimer:Set[${Script.RunningTime}]
		Actor[${TID}]:DoFace
		press -hold ${forward}
		do
		{
			Actor[${TID}]:DoFace
			wait 1
		}
		while ${Actor[${TID}](exists)} && ${Actor[${TID}].Distance}>${maxrange} && ((${Script.RunningTime}-${xTimer}) < 5000)

		press -release ${forward}
	}

	;extra release calls just in case something ended unexpectedly
	press -release ${forward}
	press -release ${backward}
	press -release ${straferight}
	press -release ${strafeleft}
	face ${Actor[${TID}].X} ${Actor[${TID}].Z}
}

function CheckQuadrant(uint TID, int quadrant)
{
	; quadrant (0=anywhere, 1=behind, 2=front, 3=flank, 4=rear or flank, 5=front or flank)
	variable string side
	variable float targetaspect

	side:Set[${Position.Side[${TID}]}]
	targetaspect:Set[${Position.Angle[${TID}]}]

	if ${NoAutoMovement}
	{
		Debug:Echo["CheckQuadrant() :: NoAutoMovement ON"]
		return
	}

	;; CheckQuadrant() should only be called in combat, so 'in combat' checks should not be necessary
	if ${NoAutoMovementInCombat}
	{
		Debug:Echo["CheckQuadrant() :: NoAutoMovementInCombat ON"]
		return
	}
	if (!${Actor[${TID}](exists)} || ${Actor[${TID}].IsDead})
	{
		Debug:Echo["CheckQuadrant() :: Current Target does not exist and/or is dead."]
		return
	}

	;we're in range, lets verify quadrant in case fudge factor placed us on wrong side.
	switch ${quadrant}
	{
		case 0
			return
			break
		case 1
			if ${targetaspect}>0 && ${targetaspect}<45
			{
				Debug:Echo[CheckQuadrant - Checking Rear and we are Rear - ${targetaspect}]
				return
			}
			else
			{
				if ${side.Equal[right]}
				{
					Debug:Echo[Quadrant 1 Right Side Strafing to 30]
					call StrafeToLeft ${TID} 30
				}
				else
				{
					Debug:Echo[Quadrant 1 Left Side Strafing to 30]
					call StrafeToRight ${TID} 30
				}
				return
			}
			break
		case 2
			if ${targetaspect}>135 && ${targetaspect}<=180
			{
				Debug:Echo[CheckQuadrant - Checking Front and we are Front - ${targetaspect}]
				return
			}
			else
			{
				if ${side.Equal[right]}
				{
					Debug:Echo[Quadrant 2 Right Side Strafing to 150]
					call StrafeToRight ${TID} 150
				}
				else
				{
					Debug:Echo[Quadrant 2 Left Side Strafing to 150]
					call StrafeToLeft ${TID} 150
				}
				return
			}
			break
		case 3
			if ${targetaspect}>45 && ${targetaspect}<135
			{
				Debug:Echo[CheckQuadrant - Checking Flank and we are Flank - ${targetaspect}]
				return
			}
			else
			{
				if ${side.Equal[right]}
				{
					if ${targetaspect}>45
					{
						Debug:Echo[Quadrant 3 Right Side Strafing to 120]
						call StrafeToLeft ${TID} 120
					}
					if ${targetaspect}<135
					{
						Debug:Echo[Quadrant 3 Right Side Strafing to 60]
						call StrafeToRight ${TID} 60
					}
				}
				else
				{
					if ${targetaspect}>45
					{
						Debug:Echo[Quadrant 3 Left Side Strafing to 120]
						call StrafeToRight ${TID} 120
					}
					if ${targetaspect}<135
					{
						Debug:Echo[Quadrant 3 Left Side Strafing to 60]
						call StrafeToLeft ${TID} 60
					}
				}
				return
			}
			break
		case 4
			if ${targetaspect}>0 && ${targetaspect}<135
			{
				Debug:Echo[CheckQuadrant - Checking Rear or Flank and we are GOOD - ${targetaspect}]
				return
			}
			else
			{
				if ${side.Equal[right]}
				{
					Debug:Echo[Quadrant 4 Right Side Strafing to 80]
					call StrafeToLeft ${TID} 80
				}
				else
				{
					Debug:Echo[Quadrant 4 Right Side Strafing to 80]
					call StrafeToRight ${TID} 80
				}
				return
			}
			break
		case 5
			if ${targetaspect}>45 && ${targetaspect}<180
			{
				Debug:Echo[CheckQuadrant - Checking Front or Flank and we are GOOD - ${targetaspect}]
				return
			}
			else
			{
				if ${side.Equal[right]}
				{
					Debug:Echo[Quadrant 5 Right Side Strafing to 105]
					call StrafeToRight ${TID} 105
				}
				else
				{
					Debug:Echo[Quadrant 5 Left Side Strafing to 105]
					call StrafeToLeft ${TID} 105
				}
				return
			}
			break
		case default
			return
			break
	}

}

function StrafeToLeft(uint TID, float destangle)
{
	variable uint xTimer
	xTimer:Set[${Script.RunningTime}]
	variable int movingforward
	variable int startdistance
	variable int lastange

	if ${NoAutoMovement}
	{
		Debug:Echo["StrafeToLeft() :: NoAutoMovement ON"]
		return
	}

	if (${Me.ToActor.InCombatMode} || ${Actor[${MainTankID}].InCombatMode})
	{
		if ${NoAutoMovementInCombat}
		{
			Debug:Echo["StrafeToLeft() :: NoAutoMovementInCombat ON"]
			return
		}
		if (!${Actor[${TID}](exists)} || ${Actor[${TID}].IsDead})
		{
			Debug:Echo["StrafeToLeft() :: In combat, but current KillTarget does not exist and/or is dead."]
			return
		}
	}

	startdistance:Set[${Actor[${TID}].Distance}]

	;if we're stuck lets try moving to MT first.
	if ${isstuck}
	{
		;set stuckstate to off
		isstuck:Set[FALSE]
		;attempt move
		call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 4
		;if move to tank also returned stuck, we really stuck
		if ${isstuck}
			return STUCK
	}

	press -hold ${strafeleft}

	if ${Position.Side[${TID}].Equal[right]}
	{
		do
		{
			lastange:Set[${Position.Angle[${TID}]}]
			;Debug:Echo[Strafing to LEFT from RIGHT Side]
			;Debug:Echo[${Actor[${TID}](exists)} && ${Position.Angle[${TID}]}>${destangle} && ((${Script.RunningTime}-${xTimer}) < 5000)]
			if ${movingforward} && ${Actor[${TID}].Distance}<${startdistance}
			{
				press -release ${forward}
				movingfoward:Set[FALSE]
			}

			Actor[${TID}]:DoFace
			wait 1

			if ${Actor[${TID}].Distance}>${Math.Calc64[${startdistance}+1]}
			{
				press -hold ${forward}
				movingforward:Set[TRUE]
			}
		}
		while ${Actor[${TID}](exists)} && !${Actor[${TID}].IsDead} && ${Position.Angle[${TID}]}>${destangle} && ((${Script.RunningTime}-${xTimer}) < 5000)

		if ${movingforward}
		{
			press -release ${forward}
			movingfoward:Set[FALSE]
		}

		if ${Position.Angle[${TID}]}>${destangle}
		{
			Debug:Echo[Stuck While Strafing Left]
			isstuck:Set[TRUE]
		}
	}
	else
	{
		do
		{
			lastange:Set[${Position.Angle[${TID}]}]
			;Debug:Echo[ Strafing to LEFT from LEFT Side]
			;Debug:Echo[ ${Actor[${TID}](exists)} && ${Position.Angle[${TID}]}<${destangle} && ((${Script.RunningTime}-${xTimer}) < 5000)]
			if ${movingforward} && ${Actor[${TID}].Distance}<${startdistance}
			{
				press -release ${forward}
				movingfoward:Set[FALSE]
			}

			Actor[${TID}]:DoFace
			wait 1

			if ${Actor[${TID}].Distance}>${Math.Calc64[${startdistance}+1]}
			{
				press -hold ${forward}
				movingforward:Set[TRUE]
			}
		}
		while ${Actor[${TID}](exists)} && !${Actor[${TID}].IsDead} && ${Position.Angle[${TID}]}<${destangle} && ((${Script.RunningTime}-${xTimer}) < 5000)

		if ${Position.Angle[${TID}]}<${destangle}
		{
			Debug:Echo[Stuck While Strafing Left]
			isstuck:Set[TRUE]
		}
	}

	press -release ${strafeleft}
	press -release ${forward}
	Actor[${TID}]:DoFace
}

function StrafeToRight(uint TID, float destangle)
{
	variable uint xTimer
	xTimer:Set[${Script.RunningTime}]
	variable int movingforward
	variable int startdistance

	if ${NoAutoMovement}
	{
		Debug:Echo["StrafeToRight() :: NoAutoMovement ON"]
		return
	}

	if (${Me.ToActor.InCombatMode} || ${Actor[${MainTankID}].InCombatMode})
	{
		if ${NoAutoMovementInCombat}
		{
			Debug:Echo["StrafeToRight() :: NoAutoMovementInCombat ON"]
			return
		}
		if (!${Actor[${TID}](exists)} || ${Actor[${TID}].IsDead})
		{
			Debug:Echo["StrafeToRight() :: In combat, but current KillTarget does not exist and/or is dead."]
			return
		}
	}

	startdistance:Set[${Actor[${TID}].Distance}]

	;if we're stuck lets try moving to MT first.
	if ${isstuck}
	{
		;set stuckstate to off
		isstuck:Set[FALSE]

		;attempt move to tank
		call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 4

		;if move to tank also returned stuck, we really stuck
		if ${isstuck}
			return STUCK
	}

	press -hold ${straferight}

	if ${Position.Side[${TID}].Equal[right]}
	{
		do
		{
			;Debug:Echo[ Strafing to RIGHT from RIGHT Side]
			;Debug:Echo[ ${TID} ${Actor[${TID}].Name} ${Position.Angle[${TID}]}<${destangle}]
			if ${movingforward} && ${Actor[${TID}].Distance}<${startdistance}
			{
				press -release ${forward}
				movingfoward:Set[FALSE]
			}

			Actor[${TID}]:DoFace
			wait 1

			if ${Actor[${TID}].Distance}>${Math.Calc64[${startdistance}+1]}
			{
				press -hold ${forward}
				movingforward:Set[TRUE]
			}
		}
		while ${Actor[${TID}](exists)} && !${Actor[${TID}].IsDead} && ${Position.Angle[${TID}]}<${destangle} && ((${Script.RunningTime}-${xTimer}) < 5000)


		if ${Position.Angle[${TID}]}<${destangle}
		{
			Debug:Echo[ Stuck While Strafing Right]
			isstuck:Set[TRUE]
		}
	}
	else
	{
		do
		{
			;Debug:Echo[ Strafing to RIGHT from LEFT Side]
			;Debug:Echo[ ${TID} ${Actor[${TID}].Name} ${Position.Angle[${TID}]}>${destangle}]
			if ${movingforward} && ${Actor[${TID}].Distance}<${startdistance}
			{
				press -release ${forward}
				movingfoward:Set[FALSE]
			}

			Actor[${TID}]:DoFace
			wait 1

			if ${Actor[${TID}].Distance}>${Math.Calc64[${startdistance}+1]}
			{
				press -hold ${forward}
				movingforward:Set[TRUE]
			}
		}
		while ${Actor[${TID}](exists)} && !${Actor[${TID}].IsDead} && ${Position.Angle[${TID}]}>${destangle} && ((${Script.RunningTime}-${xTimer}) < 5000)

		if ${Position.Angle[${TID}]}>${destangle}
		{
			Debug:Echo[ DEBUG:: Stuck While Strafing Right]
			isstuck:Set[TRUE]
		}
	}

	press -release ${straferight}
	press -release ${forward}
	Actor[${TID}]:DoFace
}

function CheckCondition(string xType, int xvar1, int xvar2)
{
	switch ${xType}
	{
		case MobHealth
			if ${Actor[${KillTarget}].Health}>=${xvar1} && ${Actor[${KillTarget}].Health}<=${xvar2}
				return "OK"
			else
				return "FAIL"
			break

		case Power
			if ${Me.ToActor.Power}>=${xvar1} && ${Me.ToActor.Power}<=${xvar2}
				return "OK"
			else
				return "FAIL"
			break

		case Health
			if ${Me.ToActor.Health}>=${xvar1} && ${Me.ToActor.Health}<=${xvar2}
				return "OK"
			else
			{
				;Debug:Echo["Not Casting Spell due to my health being too low!"]
				return "FAIL"
			}
			break
	}
}

function Pull(string npcclass)
{
	variable int tcount=1
	variable int tempvar
	variable bool aggrogrp=FALSE
	variable uint ThisActorID
	variable uint ThisActorTargetID
	variable bool bContinue=FALSE
	variable point3f interceptpoint
	variable float timedelay

	;; This variable must be set before anything is done in this function
	engagetarget:Set[FALSE]

	if !${AutoPull}
		return 0

	;; If we are already in combat...why are we pulling? Cause sometimes we pull nearest mob when group member enters combat?
	if ${Mob.Detect}
	{	
		Mob:CheckMYAggro

		if ${haveaggro} && ${Actor[${aggroid}](exists)}
		{
			KillTarget:Set[${aggroid}]
			call Combat 
			return ${aggroid}
		}	
	}
	
	
	if !${Actor[NPC,range,${ScanRange}](exists)} && !(${Actor[NamedNPC,range,${ScanRange}](exists)} && !${IgnoreNamed})
		return 0

	if ${PullType.Equal[Pet Pull]}
	{
		if !${Me.Pet(exists)}
			return 0
	}

	CurrentAction:Set["Beginning pull routine..."]

	;; Clear the TempDoNotPullList every 5 minutes
	if (${TempDoNotPullListTimer} < ${Math.Calc64[${Time.Timestamp}-300]})
	{
		TempDoNotPullListTimer:Set[${Time.Timestamp}]
		if ${TempDoNotPullList.Used} > 0
		{
			Debug:Echo["Clearing TempDoNotPullList (5 minute mark)"]
			TempDoNotPullList:Clear
		}
	}

	EQ2:CreateCustomActorArray[byDist,${ScanRange},npc]
	do
	{
		ThisActorID:Set[${CustomActor[${tcount}].ID}]
		ThisActorTargetID:Set[${CustomActor[${tcount}].Target.ID}]

		if (${TempDoNotPullList.Element[${ThisActorID}](exists)} && ${Actor[${ThisActorID}].Target.ID}!=${Me.ID})
		{
			;Debug:Echo["Actor (ID: ${actorid}) is in the TempDoNotPullList -- skipping..."]
			continue
		}

		if (${IgnoreHeroic} && !${CustomActor[${tcount}].IsSolo})
			continue

		if (${DoNotPullList.Element[${ThisActorID}](exists)})
		{
			Debug:Echo["${CustomActor[${tcount}]} (ID: ${ThisActorID}) is in the DoNotPullList -- skipping..."]
			continue
		}

		if ${Mob.ValidActor[${ThisActorID}]}
		{
			if ${Mob.AggroGroup[${ThisActorID}]}
				aggrogrp:Set[TRUE]

			if !${CustomActor[${tcount}].IsAggro}
			{
				if !${aggrogrp} && ${ThisActorTargetID}!=${Me.ID} && !${Me.ToActor.InCombatMode} && (${Me.ToActor.Power}<75 || ${Me.ToActor.Health}<90) && !${CustomActor[${tcount}].InCombatMode}
					continue

				if !${aggrogrp} && ${ThisActorTargetID}!=${Me.ID} && ${Me.ToActor.InCombatMode} && !${CustomActor[${tcount}].InCombatMode}
					continue

				if !${aggrogrp} && ${ThisActorTargetID}!=${Me.ID} && !${PullNonAggro}
					continue
			}

			if ${checkadds} && !${aggrogrp} && ${ThisActorTargetID}!=${Me.ID}
				continue

			if ${CustomActor[${tcount}].Y} < ${Math.Calc64[${Me.Y}-10]}
				continue

			if ${CustomActor[${tcount}].Y} > ${Math.Calc64[${Me.Y}+10]}
				continue

			target ${ThisActorID}

			wait 20 ${ThisActorID}==${Target.ID}

			wait 20 ${Target(exists)}

			if (${ThisActorID}!=${Target.ID})
				continue

			;;; Note: I do not know what the fuck ${pulling} is used for or about (Amadeus)
			;Debug:Echo["PathType: ${PathType} - PullRange: ${PullRange} - pulling: ${pulling} - ScanRange: ${ScanRange}"]
			if (${PathType}==4)
			{
				if (${PullType.Equal[Spell or CA Pull]})
				{
					if ${Target.Distance} > ${Math.Calc[${Me.Ability[${PullSpell}].Range}-4]}
					{
						;Debug:Echo["Moving within range for your pull spell or combat art..."]
						call FastMove ${Target.X} ${Target.Z} ${Math.Calc[${Me.Ability[${PullSpell}].Range}-4]}
					}
					;; Check again....stupid moving mobs...
					if ${Target.Distance} > ${Me.Ability[${PullSpell}].Range}
					{
						;Debug:Echo["Moving within range for your pull spell or combat art..."]
						call FastMove ${Target.X} ${Target.Z} ${Math.Calc[${Me.Ability[${PullSpell}].Range}-2]}
					}
				}
				elseif (${PullType.Equal[Bow Pull]})
				{
					if ${Target.Distance} > ${Me.Equipment[ranged].Range}
					{
						;Debug:Echo["Moving within range for your bow..."]
						call FastMove ${Target.X} ${Target.Z} ${Me.Equipment[ranged].Range}
					}
				}
			}
			if ((${PathType}==2 || ${PathType}==3 && ${pulling}) || ${PathType}==4) && ${Target.Distance}>${PullRange} && ${Target.Distance}<${ScanRange}
			{
				;Debug:Echo["Moving within Range..."]
				call FastMove ${Target.X} ${Target.Z} ${PullRange}
			}
			elseif ${PathType}==1 && ${Target.Distance}>${PullRange} && ${Target.Distance}<${ScanRange}
			{
				;Debug:Echo["Moving within Range..."]
				call FastMove ${Target.X} ${Target.Z} ${PullRange}
			}

			wait 2

			if (${PathType} > 0 && !${PullType.Equal[Pet Pull]})
			{
				CurrentAction:Set["Checking LOS/Collision..."]
				;Debug:Echo["Checking LOS/Collision"]
				if ${Target.CheckCollision}
				{
					if !${Me.TargetLOS} && ${Target.CheckCollision}
					{
						Debug:Echo["Adding (${Target.ID},${Target.Name}) to the TempDoNotPullList (unabled to attack it - No LOS or Collision Detected)"]
						TempDoNotPullList:Set[${Target.ID},${Target.Name}]

						Debug:Echo["TempDoNotPullList now has ${TempDoNotPullList.Used} actors in it."]
						continue
					}
				}
			}

			if (${Me.IsMoving} && !${NoAutoMovement})
			{
				press -release ${forward}
				wait 20 !${Me.IsMoving}
			}

			;Debug:Echo["Pulling! (PullType: ${PullType})"]
			if ${PullType.Equal[Bow Pull]} && ${Target.Distance}>6
			{
				CurrentAction:Set[Pulling ${Target} (with bow)]
				; Use Bow to pull
				EQ2Execute /togglerangedattack
				wait 50 ${CustomActor[${tcount}].InCombatMode}
				if ${CustomActor[${tcount}].InCombatMode}
				{
					if ${Target(exists)} && !${pulling} && (${Me.ID}!=${Target.ID})
						face ${Target.X} ${Target.Z}

					if ${Target(exists)}
					{
							KillTarget:Set[${Target.ID}]
						engagetarget:Set[TRUE]
						return ${Target.ID}
					}
					else
					{
						if ${Me.ToActor.InCombatMode}
							EQ2Execute /togglerangedattack
						continue
					}
				}

				if ${Me.ToActor.InCombatMode}
					EQ2Execute /togglerangedattack

				continue
			}
			elseif ${PullType.Equal[Pet Pull]}
			{
				CurrentAction:Set[Pulling ${Target} (with pet)]
				variable uint AggroMob

				;; This should not happen...but just in case
				if !${Target(exists)}
						continue

				EQ2Execute /pet attack
				WaitFor "You may not order your pet to attack the selected or implied target." 30

				if "${WaitFor}==1"
				{
					echo "EQ2Bot-Pull():: Not allowed to use pet to attack this target"
					wait 1
					Debug:Echo["Adding (${Target.ID},${Target.Name}) to the TempDoNotPullList (unabled to attack it - No LOS or Collision Detected)"]
					TempDoNotPullList:Set[${Target.ID},${Target.Name}]

					Debug:Echo["TempDoNotPullList now has ${TempDoNotPullList.Used} actors in it."]
					eq2execute /pet backoff
					eq2execute target_none
					continue
				}
				else
				{
					CurrentAction:Set[Sending Pet in for attack...]
					;Debug:Echo["EQ2Bot-Pull():: Sending Pet in for attack..."]
					variable uint StartTime = ${Script.RunningTime}
					do
					{
						if (${Math.Calc64[${Script.RunningTime}-${StartTime}]} >= 20000)
						{
							echo "EQ2Bot-Pull():: Pet did not finish a pull within 20 seconds....moving on."
							eq2execute /pet backoff
							wait 1
							Debug:Echo["Adding (${Target.ID},${Target.Name}) to the TempDoNotPullList (Timeout while pulling)"]
							TempDoNotPullList:Set[${Target.ID},${Target.Name}]

							Debug:Echo["TempDoNotPullList now has ${TempDoNotPullList.Used} actors in it."]
							eq2execute target_none
							bContinue:Set[TRUE]
							CurrentAction:Set["Timeout while pulling -- moving on..."]
							break
						}
						Wait 5
						CurrentAction:Set["Waiting for Pet (${Me.Pet.Distance.Precision[1]}m)"]
						;Debug:Echo["EQ2Bot-Pull():: Waiting for Pet (${Me.Pet.Distance.Precision[1]}m)"]

						if !(${Target(exists)})
						{
							eq2execute /pet backoff
							eq2execute target_none
							bContinue:Set[TRUE]
							break
						}

						if !${Me.Pet(exists)}
							break

						;; if the pet's target is in combat mode and it's target is the pet
						if ${Me.Pet.Target.InCombatMode}
						{
								if ${Me.Pet.Target.Target.Name.Equal[${Me.Pet.Name}]}
										break
						}

						if ${MainTank}
						{
							if ${Mob.Detect}
							{
								AggroMob:Set[${Mob.NearestAggro}]
								if ${AggroMob} > 0
								{
									if ${Mob.ValidActor[${AggroMob}]}
									{
										CurrentAction:Set["Mob in camp -- starting combat."]
										echo "EQ2Bot-Pull(MainTank):: Mob in camp -- starting combat."
										KillTarget:Set[${AggroMob}]
										target ${AggroMob}
										wait 1
										face ${KillTarget}
										wait 1
										eq2execute /pet attack
										return ${AggroMob}
									}
								}
							}
						}
					}
					while !(${Target.Target(exists)})

					if ${bContinue}
					{
						bContinue:Set[FALSE]
						continue
					}

					if !${Target(exists)}
						continue

					if !${Me.Pet(exists)}
					{
						CurrentAction:Set["Pet has died -- mob should be in camp soon (starting combat)"]
						echo "EQ2Bot-Pull():: Pet has died -- mob should be in camp soon (starting combat)"
						KillTarget:Set[${Target.ID}]
						engagetarget:Set[TRUE]
						wait 5
						return ${Target.ID}
					}

					wait 1
					eq2execute /pet backoff
					wait 25 !${Me.Pet.InCombatMode}
					if ${Me.Pet.InCombatMode}
						eq2execute /pet backoff

					StartTime:Set[${Script.RunningTime}]

					do
					{
						if (${Math.Calc64[${Script.RunningTime}-${StartTime}]} >= 120000)
						{
							CurrentAction:Set["Pet did not finish a pull within 2 minutes....moving on."]
							echo "EQ2Bot-Pull():: Pet did not finish a pull within 2 minutes....moving on."
							eq2execute /pet backoff
							eq2execute target_none
							break
						}
						wait 5
						CurrentAction:Set["Waiting for ${Target} (${Target.Distance.Precision[1]}m)"]
						;Debug:Echo["EQ2Bot-Pull():: Waiting for ${Target} (${Target.Distance.Precision[1]}m)"]

						if ${MainTank}
						{
							if ${Mob.Detect}
							{
								AggroMob:Set[${Mob.NearestAggro}]
								if ${AggroMob} > 0
								{
									if ${Mob.ValidActor[${AggroMob}]}
									{
										CurrentAction:Set["Mob in camp -- starting combat."]
										echo "EQ2Bot-Pull(MainTank):: Mob in camp -- starting combat."
										KillTarget:Set[${AggroMob}]
										target ${AggroMob}
										wait 1
										eq2execute /pet attack
										return ${AggroMob}
									}
								}
							}
						}
					}
					while (((${Target.Distance} > ${MARange}) && (${Target.Target(exists)})) || !${Me.TargetLOS})

					if ${Target(exists)}
					{
						eq2execute /pet attack
						CurrentAction:Set["${Target} in camp -- starting combat."]
						echo "EQ2Bot-Pull():: ${Target} in camp -- starting combat."
						KillTarget:Set[${Target.ID}]
						engagetarget:Set[TRUE]
						return ${Target.ID}
					}
					else
						continue
				}
			}
			;;;; Otherwise, Using "PullSpell" ;;;;;;;;;;;;;
			CurrentAction:Set["Pulling ${Target.Name} with ${PullSpell}"]
			Me.Ability[${PullSpell}]:Use

			; Round up the wait time to ensure we're only sending an int to 'wait'
			;Debug:Echo["Waiting ${Math.Calc[${Me.Ability[${PullSpell}].CastingTime}*10].Ceil}ms for spell to cast"]
			CurrentAction:Set["Waiting ${Math.Calc[${Me.Ability[${PullSpell}].CastingTime}*10].Ceil}ms for spell to cast"]
			wait ${Math.Calc[${Me.Ability[${PullSpell}].CastingTime}*10].Ceil}

			while ${Me.CastingSpell}
			{
				wait 1
			}

			CurrentAction:Set["${Target} pulled using ${PullSpell}"]
			;Debug:Echo["Pulled...waiting for mob to come within range"]
			do
			{
				waitframe
			}
			while ${Target.Distance}>${MARange} && ${Target.Target.ID}==${Me.ID}

			if ${Target.Distance} > 5 && !${pulling} && ${PathType}!=2
			{
				if ${Target.Speed}
					timedelay:Set[${Math.Calc[${Target.Distance}/(${Target.Speed}+${Me.Speed}]}]
				else
					timedelay:Set[1]
					
				interceptpoint:Set[${Postion.PredictPointAtAngle[${Target.ID},180,${timedelay},3]}]
				if (${Target.Velocity.X} || ${Target.Velocity.Z}) && ${AutoMelee}
					call FastMove ${interceptpoint.X} ${interceptpoint.Z} 5
				elseif (${Target.Velocity.X} || ${Target.Velocity.Z}) && ${Target.Distance} > ${MARange}
					call FastMove ${interceptpoint.X} ${interceptpoint.Z} ${MARange}
				elseif ${AutoMelee}
					call FastMove ${Target.X} ${Target.Z} 5
				elseif  ${Target.Distance} > ${MARange}
					call FastMove ${Target.X} ${Target.Z} ${MARange}
			}

			if ${Target(exists)}
			{
				KillTarget:Set[${Target.ID}]
				engagetarget:Set[TRUE]
				return ${Target.ID}
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
	FlushQueued CantSeeTarget

	engagetarget:Set[FALSE]
	return 0
}

function CheckLootNoMove()
{
	variable int tcount=2
	variable int tmptimer

	if !${LootCorpses}
		return

	EQ2:CreateCustomActorArray[byDist,9]

	do
	{
		;Check if already looted
		if (${ActorsLooted.Element[${CustomActor[${tcount}].ID}](exists)})
		{
			;Debug:Echo["Sorry, I've already looted this actor... (${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name})"]
			continue
		}

		if ${CustomActor[${tcount}].Type.Equal[Corpse]}
		{
			CurrentAction:Set["Looting ${Actor[corpse].Name} (Corpse)"]
			Debug:Echo["Looting ${Actor[corpse].Name} (Corpse) [CheckLootNoMove()]"]
			EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} Loot"
			EQ2Bot:SetActorLooted[${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name}]
			wait 3
			call ProcessTriggers
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	islooting:Set[FALSE]
}

function CheckLoot()
{
	variable int tcount=2
	variable int tmptimer

	;; NOTE:  This function really should only be called when 'out of combat'.  Therefore, it is ok to move with
	;;        FastMove(), even if the user has selected NoAutoMovmement (since we assume they would want the character
	;;        to override that setting and move to corpses/chests when they checked the "Loot Corpses/Chests" box.

	if (!${AutoLoot})
		return

	islooting:Set[TRUE]
	if ${NoAutoMovement} 
		EQ2:CreateCustomActorArray[byDist,9]
	elseif ${ScanRange}<30
		EQ2:CreateCustomActorArray[byDist,${ScanRange}]
	else
		EQ2:CreateCustomActorArray[byDist,20]

	do
	{
		;Check if already looted
		if (${ActorsLooted.Element[${CustomActor[${tcount}].ID}](exists)})
		{
			;Debug:Echo["Sorry, I've already looted this actor... (${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name})"]
			continue
		}

		if ${CustomActor[${tcount}].Type.Equal[chest]}
		{
			CurrentAction:Set[Looting ${CustomActor[${tcount}].Name} (Chest) -- Distance: ${CustomActor[${tcount}].Distance}]
			Echo "DEBUG: Looting ${CustomActor[${tcount}].Name} (Chest) [CheckLoot()] -- Distance: ${CustomActor[${tcount}].Distance}"
			if (${CustomActor[${tcount}].Distance} > 4)
			{
				if (${AutoFollowMode})
				{
					;Debug:Echo["Stopping Autofollow..."]
					EQ2Execute /stopfollow
					wait 2
				}
				;Debug:Echo["Moving to ${CustomActor[${tcount}].X}, ${CustomActor[${tcount}].Z}  (Currently at ${Me.X}, ${Me.Z})"]
				call FastMove ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 2 1
				;ECHO "DEBUG: FastMove() returned '${Return}'"
				wait 2
				do
				{
					waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
				;Debug:Echo["Moving complete...now at ${Me.X}, ${Me.Z} (Distance to chest: ${CustomActor[${tcount}].Distance})"]
			}

			Actor[Chest]:DoubleClick
			EQ2Bot:SetActorLooted[${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name}]
			wait 3
			if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
			{
				ExecuteAtom AutoFollowTank
				wait 1
			}
			call ProcessTriggers
		}
		elseif ${CustomActor[${tcount}].Type.Equal[Corpse]} && ${LootCorpses}
		{
			CurrentAction:Set["Looting ${Actor[corpse].Name} (Corpse)"]
			Debug:Echo["Looting ${Actor[corpse].Name} (Corpse) [CheckLoot()]"]
			if (${CustomActor[${tcount}].Distance} > 10)
			{
				if (${AutoFollowMode})
				{
					;Debug:Echo["Stopping Autofollow..."]
					EQ2Execute /stopfollow
					wait 2
				}
				call FastMove ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 8 1
				do
				{
					waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
			}
			EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} Loot"
			EQ2Bot:SetActorLooted[${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name}]
			wait 3
			call ProcessTriggers
			if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
			{
				ExecuteAtom AutoFollowTank
				wait 1
			}
		}

		if !${CurrentTask}
		{
			islooting:Set[FALSE]
			Script:End
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	islooting:Set[FALSE]
}

function FastMove(float X, float Z, int range, bool IgnoreNoAutoMovement, bool IgnoreNoAutoMovementInCombat)
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; NOTE -- If you are calling this you will need to ensure that the character is not using AutoFollowMode (and/or turn it off appropriately)
	;;;         otherwise this function will move you and then you will just richocet back
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; to Turn off autofollow:
	;;  if (${AutoFollowMode})
	;;  {
	;;      Debug:Echo["Stopping Autofollow..."]
	;;	    EQ2Execute /stopfollow
	;;	    wait 2
	;;  }
	;;; To turn AutoFollow back on
	;;  if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	;;  {
	;;	    ExecuteAtom AutoFollowTank
	;;	    wait 2
	;;  }

	variable float xDist
	variable float SavDist=${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}
	variable int xTimer
	variable int MoveToRange
	variable bool IgnoreInCombatChecks

	if (${NoAutoMovement} && !${IgnoreNoAutoMovement})
	{
		Debug:Echo["FastMove() :: NoAutoMovement ON"]
		return "NOAUTOMOVEMENT"
	}

	if ${ScanRange} > 75
		MoveToRange:Set[${ScanRange}]
	else
		MoveToRange:Set[75]

	IsMoving:Set[TRUE]

	if (${islooting} || ${movingtowp} || ${movinghome})
		IgnoreInCombatChecks:Set[TRUE]
	else
		IgnoreInCombatChecks:Set[FALSE]

	if (!${IgnoreInCombatChecks})
	{
		if (${Me.ToActor.InCombatMode} || ${Actor[${MainTankID}].InCombatMode})
		{
			if ${NoAutoMovementInCombat} && !${IgnoreNoAutoMovementInCombat}
			{
				Debug:Echo["FastMove() :: NoAutoMovementInCombat ON"]
				IsMoving:Set[FALSE]
				return "NOAUTOMOVEMENTINCOMBAT"
			}
			if (!${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead})
			{
				IsMoving:Set[FALSE]
				return "TARGETDEAD"
			}
		}
	}

	if !${X} || !${Z}
	{
		IsMoving:Set[FALSE]
		return "INVALIDLOC1"
	}

	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${MoveToRange} && ${PathType}!=4
	{
		;Debug:Echo["In FastMove() -- Math.Distance[${Me.X},${Me.Z},${X},${Z}] > MoveToRange == ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]} > ${MoveToRange}"]
		IsMoving:Set[FALSE]
		return "INVALIDLOC2"
	}
	elseif ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${MoveToRange} && ${PathType}!=4
	{
		IsMoving:Set[FALSE]
		return "INVALIDLOC3"
	}

	face ${X} ${Z}

	if !${pulling}
	{
		press -release ${forward}
		wait 1
		press -hold ${forward}

		;Debug:Echo["Moving....  (WhoFollowing: ${Me.ToActor.WhoFollowing})"]
	}

	xTimer:Set[${Script.RunningTime}]
	;Debug:Echo["xTimer set to ${xTimer}"]

	do
	{
		xDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]

		if ${Math.Calc[${SavDist}-${xDist}]} < 0.8
		{
			if (${Script.RunningTime}-${xTimer}) > 500
			{
				press -hold ${strafeleft}
				wait 8
				press -release ${strafeleft}

				if ${Math.Calc[${SavDist}-${xDist}]} < 0.8
				{
					press -hold ${straferight}
					wait 8
					press -release ${straferight}
				}

				xDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]
				if ${Math.Calc[${SavDist}-${xDist}]} > 0.8
					continue

				;Debug:Echo["Script.RunningTime (${Script.RunningTime}) - xTimer (${xTimer}) is greater than 500 -- returning STUCK  (WhoFollowing: ${Me.ToActor.WhoFollowing})"]
				;Debug:Echo["Using Math.Calc64 value is ${Math.Calc64[${Script.RunningTime}-${xTimer}]}"]

				isstuck:Set[TRUE]
				if !${pulling}
				{
					press -release ${forward}
					wait 20 !${Me.IsMoving}
				}
				IsMoving:Set[FALSE]
				return "STUCK"
			}
		}
		else
		{
			xTimer:Set[${Script.RunningTime}]
			SavDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]
		}

		face ${X} ${Z}
	}
	while ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${range}

	if !${pulling}
	{
		press -release ${forward}
		wait 20 !${Me.IsMoving}
	}

	IsMoving:Set[FALSE]
	return "SUCCESS"
}

function MovetoWP(lnavregionref destination)
{
	variable index:lnavregionref CheckRegion

	PathIndex:Set[0]
	movingtowp:Set[TRUE]
	stuckcnt:Set[0]

	if ${PathType}==3
	{
		if ${CurrentPOI}==1
			CurrentAction:Set[Moving to Start]
		elseif ${CurrentPOI}==${Math.Calc[${POICount}+2]}
			CurrentAction:Set[Moving to Finish]
		else
			CurrentAction:Set[Moving to ${destination.Name}]
	}

	if ${EQ2Nav.FindPath[${destination}]}
	{
		if (${pulling} || ${PathType}==3) && !${Me.IsMoving}
		{
			face ${CurrentPath.Region[2].CenterPoint.X} ${CurrentPath.Region[2].CenterPoint.Y}
			wait 5
			press -hold ${forward}
			PositionHeading:Set[${Me.Heading}]
		}

		while ${PathIndex:Inc}<=${CurrentPath.Hops} && !${Mob.Detect}
		{
			; Move to next Waypoint
			WPX:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.X}]
			WPY:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.Y}]

			call FastMove ${WPX} ${WPY} 2

			if ${Return.Equal[STUCK]}
			{
				; can sort out later what to do with stuck problems
				stuckcnt:Inc

				; We might be stunned so lets wait 1 second
				wait 10

				if ${stuckcnt}>10 && ${Me.IsMoving}
					return "STUCK"

				if (${pulling} || ${PathType}==3) && !${Me.IsMoving}
					press -hold ${forward}
			}

			if ${PathType}==3
			{
				call Pull any
				if ${engagetarget}
				{
					if !${Mob.Detect}
					{
						engagetarget:Set[FALSE]
					}
					else
					{
						if ${Target(exists)} && (${Me.ID}!=${Target.ID})
							face ${Target.X} ${Target.Z}
					}
					pulling:Set[FALSE]
					return
				}
			}
			elseif ${pulling} && !${LNavRegionGroup[Camp].Contains[${destination}]}
			{
				call Pull any
				if ${engagetarget}
				{
					if !${Mob.Detect}
					{
						engagetarget:Set[FALSE]
					}
					else
					{
						call MovetoWP ${LNavRegionGroup[Camp].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
						if !${Mob.Detect}
						{
							engagetarget:Set[FALSE]
						}
						else
						{
							if ${Target(exists)} && (${Me.ID}!=${Target.ID})
								face ${Target.X} ${Target.Z}
						}
					}
					pulling:Set[FALSE]
					return
				}

				if ${PathIndex}==${CurrentPath.Hops}
				{
					call MovetoWP ${LNavRegionGroup[Camp].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
					wait 10

					if ${Target(exists)} && (${Me.ID}!=${Target.ID})
						face ${Target.X} ${Target.Z}

					pulling:Set[FALSE]
					return
				}
			}
		}

		if (${pulling} || ${PathType}==3) && ${Me.IsMoving}
		{
			press -release ${forward}
			wait 20 !${Me.IsMoving}
		}
	}

	if ${PathType}==3
	{
		if ${CurrentPOI}==1
		{
			DCDirection:Set[TRUE]
		}
		elseif ${CurrentPOI}==${Math.Calc[${POICount}+2]}
		{
			DCDirection:Set[FALSE]
		}

		do
		{
			if ${DCDirection}
			{
				CurrentPOI:Inc
			}
			else
			{
				CurrentPOI:Dec
			}
		}
		while !${POIInclude[${CurrentPOI}]}
	}

	movingtowp:Set[FALSE]
}

function MovetoMaster()
{
	if ${NoAutoMovement}
		return


	if ${EQ2Nav.FindPath[${EQ2Nav.FindClosestRegion[${Actor[${MainAssistID}].X},${Actor[${MainAssistID}].Z},${Actor[${MainAssistID}].Y}].FQN}]}
	{
		CurrentAction:Set[Moving Closer to Main Aasist]
		movingtowp:Set[TRUE]
		pulling:Set[TRUE]

		press -hold ${forward}

		while ${PathIndex:Inc}<=${CurrentPath.Hops} && !${Mob.Detect}
		{
			WPX:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.X}]
			WPY:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.Y}]

			call FastMove ${WPX} ${WPY} 2
		}

		if ${Me.IsMoving}
			press -release ${forward}

		movetowp:Set[FALSE]
	}
}

function ProcessTriggers()
{
	while ${QueuedCommands}
	{
		ExecuteQueued
	}
}

function IamDead(string Line)
{
	variable uint deathtimer=${Time.Timestamp}
	KillTarget:Set[]
	grpcnt:Set[${Me.GroupCount}]
	tempgrp:Set[1]

	together:Set[1]

	CurrentAction:Set["You have been killed"]
	echo "You have been killed"

	if ${WipeRevive}
	{
		if ${Me.GroupCount} == 1
		{
			echo "IamDead():: no group, resetting"
			EQ2Execute "select_junction 0"
			do
			{
				waitframe
			}
			while (${EQ2.Zoning} != 0)
			KillTarget:Set[]
			wait 15
			if ${AutoFollowingMA(exists)}
				AutoFollowingMA:Set[FALSE]
			CurrentAction:Set[Performing PostDeath Routine...]
			;; call PostDeathRoutine(), which exists in each class file
			call PostDeathRoutine
			CurrentAction:Set[Idle...]
			return
		}
		else
		{
			do
			{
				wipe:Set[1]
				wipegroup:Set[0]
				do
				{
					if ${Me.Group[${wipegroup}](exists)} && ${Me.Group[${wipegroup}].ToActor.IsDead}
					{
						wipe:Inc
						echo ${Me.Group[${wipegroup}]} has died.
						echo "There are now" ${wipe} "dead group members. (" ${grpcnt} " Total)"
					}
					wait 10
				}
				while ${wipegroup:Inc}<=${Me.GroupCount}

				if ${wipe}==${grpcnt}
				{
					CurrentAction:Set["Everyone is dead, waiting 10 seconds to revive"]
					echo "Everyone is dead, waiting 10 seconds to revive"
					GroupWiped:Set[TRUE]
					wait 100
					EQ2Execute "select_junction 0"
					do
					{
						waitframe
					}
					while (${EQ2.Zoning} != 0)
					KillTarget:Set[]
					wait 100
					echo "reloading config"
					EQ2Bot:Init_Config
					wait 50
					if ${MainTank} && ( ${PathType}==3 || ${PathType}==2 )
					{
						echo "I am Main Tank, moving to START"
						wait 500
						call MovetoWP ${Navigation.World[${Zone.ShortName}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}
						wait 50
					}
					else
					{
						EQ2Execute "/follow ${MainTankPC}"
					}

					echo Waiting for group to reform
					together:Set[1]
					do
					{
						tempgrp:Set[1]
						do
						{
							if ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.Distance}<25
							{
								echo ${Me.Group[${tempgrp}]} "has arrived"
								together:Inc
								echo "There are now " ${together} " ready group members (" ${grpcnt} " Total)"
							}
						}
						while ${tempgrp:Inc}<=${grpcnt}
						wait 10
					}
					while ${together}<${grpcnt}
					echo "Everyone is here"
					if ${MainTank}
					{
						CurrentAction:Set["I am Main Tank, waiting 60 seconds for group buffing"]
						echo "I am Main Tank, waiting 60 seconds for group buffing"
						wait 600
					}
					else
					{
						echo "Not Main Tank, restarting in 5 seconds"
						wait 50
					}
				}
			}
			while ${Me.ToActor.IsDead}
			echo "Ready to continue fighting!"
		}
	}
	else
	{
		KillTarget:Set[]
		CurrentAction:Set["You have been killed..."]
		do
		{
			wait 2
			call ProcessTriggers
			if ${Math.Calc64[${Time.Timestamp}-${deathtimer}]}>5000
				Exit
		}
		while (${Me.ToActor.IsDead} || ${EQ2.Zoning} != 0)

		wait 15
		if ${AutoFollowingMA(exists)}
			AutoFollowingMA:Set[FALSE]
		CurrentAction:Set[Performing PostDeath Routine...]
		;; call PostDeathRoutine(), which exists in each class file
		call PostDeathRoutine
		CurrentAction:Set[Idle...]
	}
}

function LoreItem(string Line)
{
	if ${ID.Equal[${LastWindow}]}
	{
		switch ${LootWindow.Type}
		{
			case Free For All
			case Lottery
				LootWindow:DeclineLotto
				return
			case Need Before Greed
				LootWindow:DeclineNBG
				return
			case Unknown
			Default
				echo "EQ2Bot(LoreItem):: Unknown LootWindow Type found: ${LootWindow[${ID}].Type}"
				return
		}
	}
}

function LootWindowBusy(string Line)
{
	if ${ID.Equal[${LastWindow}]}
	{
		switch ${LootWindow.Type}
		{
				case Free For All
			case Lottery
				LootWindow:DeclineLotto
							return
			case Need Before Greed
				LootWindow:DeclineNBG
				return
			case Unknown
			Default
				echo "EQ2Bot(LootWindowBusy):: Unknown LootWindow Type found: ${LootWindow[${ID}].Type}"
				return
		}
	}
}

function InventoryFull(string Line)
{
	;; Is this necessary? ..if so, should use "EQ2Execute /togglebags" instead I think.
	;EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick

	LootMethod:Set[Decline]
}


function CheckMTAggro()
{
	variable int tcount=1
	variable int tempvar
	variable uint newtarget

	; If PathType is 2 make sure we are not to far away from home point first
	if ${PathType}==2 && ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>8
	{
		call FastMove ${HomeX} ${HomeZ} 4
		if ${Actor[${KillTarget}](exists)} && (${Me.ID}!=${KillTarget})
			face ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z}
	}

	lostaggro:Set[FALSE]

	if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
		return "NOAGGRO"

	newtarget:Set[${Target.ID}]

	EQ2:CreateCustomActorArray[byDist,15,npc]
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode}
		{
			if ${Math.Calc[${CustomActor[${tcount}].Health}+1]}<${Actor[${newtarget}].Health} && ${Actor[${newtarget}](exists)}
				newtarget:Set[${CustomActor[${tcount}].ID}]

			if ${CustomActor[${tcount}].Target.ID}!=${Me.ID}
			{
				if !${Mob.AggroGroup[${CustomActor[${tcount}].ID}]}
					continue

				call Lost_Aggro ${CustomActor[${tcount}].ID}
				if ${UseCustomRoutines}
					call Custom__Lost_Aggro ${CustomActor[${tcount}].ID}
				lostaggro:Set[TRUE]
				return
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
}

function ScanAdds()
{
	return
	;This needs to be redone completely.
	variable int tcount=1
	variable float X
	variable float Z

	if ${NoAutoMovementInCombat} || !${MainTank} || ${NoAutoMovement}
		return

	EQ2:CreateCustomActorArray[byDist,20,npc]
	do
	{
		; Check if there is an add approaching us and move away from it accordingly
		if (${CustomActor[${tcount}].Type.Equal[NPC]} || ${CustomActor[${tcount}].Type.Equal[NamedNPC]}) && ${Actor[${CustomActor[${tcount}].ID}](exists)} && !${CustomActor[${tcount}].IsLocked} && ${Math.Calc[${Me.Y}+10]}>=${CustomActor[${tcount}].Y} && ${Math.Calc[${Me.Y}-10]}<=${CustomActor[${tcount}].Y} && !${CustomActor[${tcount}].InCombatMode} && ${CustomActor[${tcount}].IsAggro}
		{
			if ${CustomActor[${tcount}].Target.ID}!=${Actor[MyPet].ID} || ${CustomActor[${tcount}].Target.ID}!=${Me.ID}
			{
				X:Set[${Math.Calc[-8*${Math.Sin[-${CustomActor[${tcount}].HeadingTo}]}+${Me.X}]}]
				Z:Set[${Math.Calc[8*${Math.Cos[-${CustomActor[${tcount}].HeadingTo}]}+${Me.Z}]}]
				call FastMove ${X} ${Z}  2
				do
				{
						waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
				if ${Return.Equal[STUCK]}
				{
					; Need to do something here? decide later
				}
				return
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
}

;atom(script) EQ2_onIncomingChatText(int ChatType, string sMessage, string Speaker, string sTarget, string SpeakerIsNPC, string ChannelName)
;{
;}

atom(script) EQ2_onIncomingText(string Text)
{
	; Added as part of the AutoAttack Timing Code
	; START -------------------------------------
	; -------------------------------------------

	if (${Text.Find[YOU hit ]} > 0 || ${Text.Find[YOU critically hit ]} > 0 || ${Text.Find[YOU double attack]} > 0 || ${Text.Find[YOU critically double attack]} > 0)
	{
		;echo AutoAttackReady: FALSE
		AutoAttackReady:Set[FALSE]
		LastAutoAttack:Set[${Script.RunningTime}/1000]
	}

	; END ---------------------------------------
	; -------------------------------------------

	if (${Text.Find[You may not order your pet to attack]} > 0)
	{
		;; Make sure the list does not get too big
		if (${DoNotPullList.Used} > 100)
		{
				;Debug:Echo["DoNotPullList too big (${DoNotPullList.Used} elements) -- Clearing..."]
				DoNotPullList:Clear
		}
		if ${Target.ID}
		{
			Debug:Echo["Adding (${Target.ID},${Target.Name}) to the DoNotPullList (unabled to attack it)"]
			DoNotPullList:Set[${Target.ID},${Target.Name}]

			Debug:Echo["DoNotPullList now has ${DoNotPullList.Used} actors in it."]
		}
	}
	elseif (${Text.Find[This attack cannot be used on this type of creature]} > 0)
	{
		;; Make sure the list does not get too big
		if (${InvalidMasteryTargets.Used} > 100)
		{
			;Debug:Echo["InvalidMasteryTargets list too big (${InvalidMasteryTargets.Used} elements) -- Clearing..."]
			InvalidMasteryTargets:Clear
		}

		if ${Actor[${KillTarget}](exists)}
		{
			;Debug:Echo["Adding (${Actor[${KillTarget}].ID},${Actor[${KillTarget}].Name}) to the InvalidMasteryTargets list"]
			InvalidMasteryTargets:Set[${Actor[${KillTarget}].ID},${Actor[${KillTarget}].Name}]

			;Debug:Echo["InvalidMasteryTargets now has ${InvalidMasteryTargets.Used} actors in it."]
		}
	}
	elseif (${Text.Find[Move closer!]} > 0)
	{
			;; This variable should be utilized in individual class files (see Illusionist.iss for example)
			DoCallCheckPosition:Set[TRUE]
	}
	elseif (${Text.Find[No Eligible Target]} > 0)
		NoEligibleTarget:Set[TRUE]
		;Debug:Echo["NO ELIGIBLE TARGET! ('${Text}')"]
	;elseif (${Text.Equal["Target is not alive"]})
	;	Debug:Echo["TARGET IS NOT ALIVE!"]


}

atom(script) EQ2_onIncomingChatText(int ChatType, string Message, string Speaker, string sTarget, string SpeakerIsNPC, string ChannelName)
{
		;Debug:Echo[" ChatType: ${ChatType} -- Speaker: ${Speaker} -- Target: ${sTarget} -- ChannelName: ${ChannelName} -- Message: ${Message}"]

	if (${Message.Find[Invis us please]} > 0)
	{
			if ${Me.Group[${Speaker}](exists)}
			{
					if (${Me.SubClass.Equal[Illusionist]} && ${Me.Level} >= 24)
					{
								eq2execute /useabilityonplayer ${Speaker} "Illusory Mask"
					}
					elseif (${Me.SubClass.Equal[Fury]} && ${Me.Level} >= 45)
					{
								eq2execute /useabilityonplayer ${Speaker} "Untamed Shroud"
					}
				}
		}
}

atom(script) LootWDw(string ID)
{
	if ${PauseBot} || !${StartBot}
		return

	;Debug:Echo["LootWDw(${ID}) -- (LastWindow: ${LastWindow})"]
	;Debug:Echo["LootWindow.Type: ${LootWindow[${ID}].Type}"]
	;Debug:Echo["LootWindow.Item[1]: ${LootWindow[${ID}].Item[1]}"]

	declare i int local
	variable int tmpcnt=1
	variable int deccnt=0

	;; accept some items regardless
	;Debug:Echo["LootWDw() - Item[1]: '${LootWindow[${ID}].Item[1].Name}'"]
	switch ${LootWindow[${ID}].Item[1].Name}
	{
		case Void Shard
		case Mark of Manaar
			run "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Utils/LootAll" ${ID} ${Math.Rand[30]:Inc[1]}
			return
		
		default
			break
	}

	if (${ID.Equal[${LastWindow}]})
	{
			switch ${LootWindow[${ID}].Type}
			{
				case Free For All
				case Lottery
					LootWindow[${ID}]:DeclineLotto
					return
				case Need Before Greed
					LootWindow[${ID}]:DeclineNBG
					return
				case Unknown
				Default
					echo "EQ2Bot:: Unknown LootWindow Type found: ${LootWindow[${ID}].Type}"
					return
			}
	}
	
	LastWindow:Set[${ID}]

	if (${LootMethod.Equal[Accept]})
	{
		do
		{
			if (${LootWindow[${ID}].Item[${tmpcnt}].Lore})
			{
				if !${LoreConfirm}
				{
					deccnt:Inc
					continue
				}
			}
			if (${LootWindow[${ID}].Item[${tmpcnt}].NoTrade})
			{
					; If we are running EQ2Harvest, then we will collect everything.
					if !${Script[EQ2harvest](exists)}
					{
						if !${NoTradeConfirm}
								deccnt:Inc
					}
			}
			if (!${LootPrevCollectedShineys})
			{
					if (${LootWindow[${ID}].Item[${tmpcnt}].IsCollectible})
					{
						if (${LootWindow[${ID}].Item[${tmpcnt}].AlreadyCollected} && ${Me.Group} > 1)
						{
								; If we are running EQ2Harvest, then we will collect everything.
								if !${Script[EQ2harvest](exists)}
								{
									Debug:Echo["Item marked as collectible and I've already collected it -- declining! (${LootWindow[${ID}].Item[${tmpcnt}].Name})"]
									deccnt:Inc
								}
						}
					}
				}
		}
		while ${tmpcnt:Inc}<=${LootWindow[${ID}].NumItems}
	}
	elseif ${LootMethod.Equal[Decline]}
	{
		deccnt:Inc[${LootWindow[${ID}].NumItems}]
	}
	elseif (${LootMethod.Equal[Idle]})
		return

	switch ${LootWindow[${ID}].Type}
	{
		case Lottery
			if ${LootThisAlways}
				LootWindow[${ID}]:RequestAll
			elseif ${deccnt}
				LootWindow[${ID}]:DeclineLotto
			else
				LootWindow[${ID}]:RequestAll
			break
		case Free For All
			if ${LootThisAlways}
				LootWindow[${ID}]:LootAll
			if ${deccnt}
				LootWindow[${ID}]:DeclineLotto
			else
				LootWindow[${ID}]:LootAll
			break
		case Need Before Greed
			if ${LootThisAlways}
				LootWindow[${ID}]:SelectNeed
			if ${deccnt}
				LootWindow[${ID}]:DeclineNBG
			else
				LootWindow[${ID}]:SelectGreed
			break
		case Unknown
		Default
			echo "EQ2Bot:: Unknown LootWindow Type found: ${LootWindow[${ID}].Type}"
			break
	}
}

function CantSeeTarget(string Line)
{
	if ${NoAutoMovement}
	{
		Debug:Echo["CantSeeTarget() :: NoAutoMovement ON"]
		return
	}

	if (${Me.ToActor.InCombatMode} || ${Actor[${MainTankID}].InCombatMode})
	{
		if ${NoAutoMovementInCombat}
		{
			Debug:Echo["CantSeeTarget() :: NoAutoMovementInCombat ON"]
			return
		}
		if (!${Actor[${TID}](exists)} || ${Actor[${TID}].IsDead})
		{
			Debug:Echo["CantSeeTarget() :: In combat, but current KillTarget does not exist and/or is dead."]
			return
		}
	}

	if (${haveaggro} || ${MainTank}) && ${Me.ToActor.InCombatMode}
	{
		if ${Target.Target.ID}==${Me.ID}
		{
			if ${Target(exists)} && (${Me.ID}!=${Target.ID})
				face ${Target.X} ${Target.Z}

			press -release ${forward}
			wait 1
			press -hold ${backward}
			wait 5
			press -release ${backward}
			wait 20 !${Me.IsMoving}
			return
		}
	}
}

function BotStop()
{
	FollowTask:Set[0]
	StartBot:Set[FALSE]

	UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Show
	UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Stop EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
}

function BotAbort()
{
	Script:End
}

function BotCommand(string line, string doCommand)
{
		if (${PauseBot} || !${StartBot})
				return

	EQ2Execute /${doCommand}
}

function BotTell(string line, string tellSender, string tellMessage)
{
	uplink relay ${MasterSession} "EQ2Echo ${tellSender} tells ${Me.Name}, ${tellMessage}"
}

function BotAutoMeleeOn()
{
		if (${PauseBot} || !${StartBot})
				return

	AutoMelee:Set[TRUE]
}

function BotAutoMeleeOff()
{
		if (${PauseBot} || !${StartBot})
				return

	AutoMelee:Set[FALSE]

	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}
}

function BotCastTarget(string line, string Spell, string castTarget)
{
	variable string tempTarget

		if (${PauseBot} || !${StartBot})
				return

	if ${castTarget.Equal[me]}
		tempTarget:Set[${MainAssist}]
	else
		tempTarget:Set[${castTarget}]

	target ${tempTarget}
	wait 2
	call CastSpell "${Spell}"
}

function SetNewKillTarget()
{
		CurrentAction:Set[Setting KillTarget to your current target in 3 seconds...]
		wait 10
		CurrentAction:Set[Setting KillTarget to your current target in 2 seconds...]
		wait 10
		CurrentAction:Set[Setting KillTarget to your current target in 1 seconds...]
		wait 10

		if ${Target(exists)} && ${Target.Type.Find[NPC]}
		{
			KillTarget:Set[${Target.ID}]
			Debug:Echo["KillTarget now set to '${Target}' (ID: ${Target.ID})"]
		}
		else
		{
			Debug:Echo["SetNewKillTarget() FAILED -- Target invalid."]
			return FAILED
		}

		return OK
}

function ReacquireKillTargetFromMA(int WaitTime=5)
{
	variable uint NextKillTarget
	if (${WaitTime} > 0)
	{
		CurrentAction:Set[Reacquiring KillTarget from ${MainAssist} in ${WaitTime}/10 seconds...]
		wait ${WaitTime}
	}

	if ${Actor[${MainAssistID}](exists)}
	{
		if !${Actor[${MainAssistID}].InCombatMode}
		{
			Debug:Echo["ReacquireKillTargetFromMA() -- [MainAssist is no longer in combat mode]"]
			KillTarget:Set[0]
			return FAILED
		}

		if ${Actor[${MainAssistID}].Target(exists)}
		{
			NextKillTarget:Set[${Actor[${MainAssistID}].Target.ID}]
			if (${NextKillTarget})
			{
				if ${Actor[${NextKillTarget}].Type.Find[NPC]} && !${Actor[${NextKillTarget}].IsDead}
				{
					KillTarget:Set[${NextKillTarget}]
					Debug:Echo["KillTarget now set to ${Actor[${MainAssistID}]}'s target: ${Actor[${KillTarget}]} (ID: ${KillTarget})"]
					return OK
				}
				else
				{
					Debug:Echo["ReacquireKillTargetFromMA() -- [MainAssist's target was not valid]"]
					return FAILED
				}
			}
			else
			{
				Debug:Echo["ReacquireKillTargetFromMA() -- [MainAssist's target ID was zero]"]
				return FAILED
			}
		}
		else
		{
			Debug:Echo["ReacquireKillTargetFromMA() -- [MainAssist does not currently have a target]"]
			return FAILED
		}
	}
	else
	{
		Debug:Echo["ReacquireKillTargetFromMA() -- [MainAssist doesn't exist!]"]
		return FAILED
	}

	Debug:Echo["ReacquireKillTargetFromMA() FAILED"]
	return FAILED
}

function VerifyTarget(uint TargetID=0)
{
		if !${TargetID}
		{
			if (!${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead})
			{
				if ${MainAssist.Equal[${Me.Name}]}
					return "FALSE"

				call ReacquireKillTargetFromMA 0
				if ${Return.Equal[FAILED]}
				{
					KillTarget:Set[0]
					return "FALSE"
				}
			}
		}
		else
		{
			if (${TargetID}==${KillTarget} && ${Actor[${KillTarget}].IsDead})
			{
				if ${MainAssist.Equal[${Me.Name}]}
					return "FALSE"

				call ReacquireKillTargetFromMA 0
				if ${Return.Equal[FAILED]}
				{
					KillTarget:Set[0]
					return "FALSE"
				}
			}
			elseif (!${Actor[${TargetID}](exists)} || ${Actor[${TargetID}].IsDead})
				return "FALSE"
		}

		return "TRUE"
}

function StartBot()
{
	variable int tempvar1
	variable int tempvar2

	CharacterSet.FindSet[Temporary Settings]:AddSetting["StartXP",${Me.Exp}]
	CharacterSet.FindSet[Temporary Settings]:AddSetting["StartAPXP",${Me.APExp}]
	CharacterSet.FindSet[Temporary Settings]:AddSetting["StartTime",${Time.Timestamp}]

	if ${CloseUI}
	{
		;This is stupid. Hide it, that will eliminate crashes when loading tabs etc.
		;Also possibility of setting up a keybind to show window again if needed.
		;ui -unload "${PATH_UI}/eq2bot.xml"
		UIElement[EQ2 Bot]:Hide
	}
	UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Show
	UIElement[EQ2 Bot].FindUsableChild[Stop EQ2Bot,commandbutton]:Show	
	UIElement[EQ2 Bot].FindUsableChild[Set KillTarget,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Reacquire KillTarget,commandbutton]:Show

		;; Any subclass that can "Feign Death" can be added here; however, be sure that you add a "function FeignDeath()"
		;; to the class file (see Shadowknight.iss class file for example)
	if ${Me.SubClass.Equal[shadowknight]}
				UIElement[EQ2 Bot].FindUsableChild[Feign Death,commandbutton]:Show

		;; Any subclass that can "Harm Touch" can be added here; however, be sure that you add a "function HarmTouch()"
		;; to the class file (see Shadowknight.iss class file for example)
	if ${Me.SubClass.Equal[shadowknight]}
				UIElement[EQ2 Bot].FindUsableChild[Harm Touch,commandbutton]:Show


	switch ${PathType}
	{
		case 0
			break

		case 1
			HomeX:Set[${Me.X}]
			HomeZ:Set[${Me.Z}]
			break

		case 2
			HomeX:Set[${Me.X}]
			HomeZ:Set[${Me.Z}]
			break

		case 3
			break

		case 4
			HomeX:Set[${Me.X}]
			HomeZ:Set[${Me.Z}]
			MainTank:Set[TRUE]
			break
	}

	; Need to move this so that its set when MainAssist changes.
	OriginalMA:Set[${MainAssist}]
	OriginalMT:Set[${MainTankPC}]

	UIElement[EQ2 Bot].FindUsableChild[Stop EQ2Bot,commandbutton]:Show
	if ${PauseBot}
	{
		UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Show
		UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	}
	else
	{
		UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Hide
		UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Show
	}
	UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Show
	UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Hide
	if ${Actor[${MainTankID}].InCombatMode}
		UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
	StartBot:Set[TRUE]
}

function PauseBot()
{
	PauseBot:Set[TRUE]
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Hide
	StartBot:Set[FALSE]
	do
	{
		waitframe
		call ProcessTriggers
	}
	while ${PauseBot}
	StartBot:Set[TRUE]
	PauseBot:Set[FALSE]
}

function ResumeBot()
{
	PauseBot:Set[FALSE]
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Show
	StartBot:Set[TRUE]
	if ${Me.ToActor.InCombatMode}
		UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
}

function StopBot()
{
	UIElement[EQ2 Bot].FindUsableChild[Stop EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Show
	UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Hide

	StartBot:Set[FALSE]
}

function CheckBuffsOnce()
{
	;;;
	;;; This should only be called while in combat.
	;;;
	variable int i
	CheckingBuffsOnce:Set[TRUE]

	UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Hide
	CurrentAction:Set["Checking Buffs Once..."]

	if ${Me.CastingSpell}
	{
		CurrentAction:Set["Waiting for ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel to finish casting..."]
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
		CurrentAction:Set["Checking Buffs Once..."]
	}

	if !${Me.ToActor.IsDead}
	{
		i:Set[1]
		do
		{
			;;;;;;;;;
			;;;;; Call the buff routine from the class file
			;;;;;;;;;
			call Buff_Routine ${i}
			if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
				break
			call ProcessTriggers
			wait 2
		}
		while ${i:Inc}<=40

		if (${UseCustomRoutines})
		{
			i:Set[1]
			do
			{
				call Custom__Buff_Routine ${i}
				if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
					break
			}
			while ${i:Inc} <= 40
		}
	}

	if ${MainTank}
		UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
	elseif ${Actor[${MainTankID}].InCombatMode}
		UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
	CurrentAction:Set["Waiting..."]
	CheckingBuffsOnce:Set[FALSE]
	return
}


objectdef ActorCheck
{
	;returns true for valid targets
	member:bool ValidActor(uint actorid)
	{
		if !${Actor[${actorid}](exists)}
		{
			Debug:Echo["ValidActor Return FALSE - Mob: ${Actor[${actorid}].Name} Does Not Exist"]
			return FALSE
		}

		if ${Actor[${actorid}].IsDead}
		{
			Debug:Echo["ValidActor Return FALSE - Mob: ${Actor[${actorid}].Name} IsDead"]
			return FALSE
		}
		
		switch ${Actor[${actorid}].Type}
		{
			case NPC
				break

			case NamedNPC
				if ${IgnoreNamed}
					return FALSE
				break

			Default
				return FALSE
		}

		switch ${Actor[${actorid}].ConColor}
		{
			case Yellow
				if ${IgnoreYellowCon}
					return FALSE
				break

			case White
				if ${IgnoreWhiteCon}
					return FALSE
				break

			case Blue
				if ${IgnoreBlueCon}
					return FALSE
				break

			case Green
				if ${IgnoreGreenCon}
					return FALSE
				break

			case Orange
				if ${IgnoreOrangeCon}
					return FALSE
				break

			case Red
				if ${IgnoreRedCon}
					return FALSE
				break

			case Grey
				if ${IgnoreGreyCon}
					return FALSE
				break

			Default
				Debug:Echo["ValidActor Return FALSE - Mob: ${Actor[${actorid}].Name} Type Does not Evaluate"]
				return FALSE
		}

		;checks if mob is too far above or below us
		;LEAVE THIS SHIT OUT!!! - PYGAR
		;if ${Me.Y}+10<${Actor[${actorid}].Y} || ${Me.Y}-10>${Actor[${actorid}].Y}
		;{
		;	;Debug:Echo["Actor (ID: ${actorid} is too far above or below me"]
		;	return FALSE
		;}

		if ${Actor[${actorid}].IsLocked}
		{	
			Debug:Echo["ValidActor Return FALSE - Mob: ${Actor[${actorid}].Name} is Locked"]
			return FALSE
		}
		
		if ${Actor[${actorid}].IsHeroic} && ${IgnoreHeroic}
			return FALSE

		if ${Actor[${actorid}].IsEpic} && ${IgnoreEpic}
			return FALSE

		;actor is a charmed pet, ignore it
		if ${This.FriendlyPet[${actorid}]}
		{
			Debug:Echo["ValidActor Return FALSE - Mob: ${Actor[${actorid}].Name} ID: ${actorid} is a friendly pet ...ignoring"]
			return FALSE
		}

		if ${Target.ID} == ${actorid}
		{
				if !${Me.TargetLOS}
				{
						Debug:Echo["EQ2Bot-ValidActor():: No line of sight to ${Target}."]
						return FALSE
				}

				if ${Target.Distance} > ${MARange}
				{
						Debug:Echo["EQ2Bot-ValidActor():: ${Target} is not within MARange (${MARange})"]
						return FALSE
				}
			}

		return TRUE
	}

	member:bool CheckActor(uint actorid)
	{
		if ${Actor[${actorid}].IsDead}
		{
			Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor IsDead."]
			return FALSE
		}

		switch ${Actor[${actorid}].Type}
		{
			case NPC
				break

			case NamedNPC
				if ${IgnoreNamed}
					return FALSE
				break

			case PC
				Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor is a PC."]
				return FALSE

			case Pet
				Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor is a PET."]	
				return FALSE

			case MyPet
				Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor is MyPet."]
				return FALSE

			Default
				Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor Type failed identification."]
				return FALSE
		}

		;checks if mob is too far above or below us
		;this ignores mobs in floors and gets us killed when the are aggro
		;if ${Me.Y}+10<${Actor[${actorid}].Y} || ${Me.Y}-10>${Actor[${actorid}].Y}
		;{
		;	return FALSE
		;}

		if ${Actor[${actorid}].IsLocked}
		{
			Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor IsLocked"]
			return FALSE
		}

		if ${This.FriendlyPet[${actorid}]}
		{
			Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor is a charmed pet, ignore it"]
			return FALSE
		}

		if ${Actor[${actorid}](exists)}
		{
			return TRUE
		}
		else
		{
			Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor doesn't exist"]
			return FALSE
		}
	}

	; Check if mob is aggro on Raid, group, or pet only, doesn't check agro on Me
	member:bool AggroGroup(uint actorid)
	{
		if ${Actor[${actorid}].IsDead}
		{
			Debug:Echo["EQ2Bot-AggroGroup(): Return False - Actor IsDead"]
			return FALSE
		}
		
		variable int tempvar

		if ${This.FriendlyPet[${actorid}]}
		{
			Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor is a charmed pet, ignore it"]
			return FALSE
		}

		if ${Actor[${actorid}].Type.Equal[PC]}
		{
			Debug:Echo["EQ2Bot-CheckActor(): Return False - Actor Type is PC"]
			return FALSE
		}

		if ${Me.GroupCount}>1 || ${Me.InRaid}
		{
			;echo Check if mob is aggro on group or pet
			tempvar:Set[0]
			do
			{
				if (${Me.Group[${tempvar}](exists)})
				{
					if ${Actor[${actorid}].ID} == ${Me.Group[${tempvar}].ID}
						return FALSE

					if (${Actor[${actorid}].Target.ID} == ${Me.Group[${tempvar}].ID})
						return TRUE
				}
				if (${Me.Group[${tempvar}].ToActor.Pet.ID(exists)})
				{
					if (${Actor[${actorid}].Target.ID} == ${Me.Group[${tempvar}].ToActor.Pet.ID})
						return TRUE
				}
			}
			while ${tempvar:Inc} <= ${Me.GroupCount}

			; Check if mob is aggro on raid or pet
			if ${Me.InRaid}
			{
				;echo checking aggro on raid
				tempvar:Set[1]
				do
				{
					if (${Me.Raid[${tempvar}](exists)})
					{
						if ${Actor[${actorid}].ID} == ${Me.Raid[${tempvar}].ID}
							return FALSE

						if (${Actor[${actorid}].Target.ID} == ${Me.Raid[${tempvar}].ID})
						{
							;echo aggro detected on raid
							return TRUE
						}
					}
				}
				while ${tempvar:Inc} <= ${Me.RaidCount}
			}
		}

		if ${Actor[MyPet](exists)} && ${Actor[${actorid}].Target.ID}==${Actor[MyPet].ID}
			return TRUE

		if ${Actor[${actorid}].Target.ID}==${Me.ID} && ${Actor[${actorid}].InCombatMode}
			return TRUE

		return FALSE
	}

	;returns count of mobs engaged in combat near you.  Includes mobs not engaged to other pcs/groups
	member:int Count()
	{
		variable int tcount=1
		variable int mobcount

		if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
		{
			return 0
		}

		EQ2:CreateCustomActorArray[byDist,15,npc]
		do
		{
			if ${This.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode}
			{
				mobcount:Inc
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

		return ${mobcount}
	}

	;returns true if you, group, raidmember, or pets have agro from mob in range
	member:bool Detect(int iEngageDistance=${ScanRange})
	{
		variable int tcount=1

		if !${Actor[NPC,range,${iEngageDistance}](exists)} && !(${Actor[NamedNPC,range,${iEngageDistance}](exists)} && !${IgnoreNamed})
		{
			Debug:Echo["No NPCs within a range of ${iEngageDistance}m"]
			return FALSE
		}

		EQ2:CreateCustomActorArray[byDist,${iEngageDistance},npc]
		Debug:Echo["Detect() -- ${EQ2.CustomActorArraySize} mobs within ${iEngageDistance} meters."]
		do
		{
			if ${This.CheckActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode} && !${CustomActor[${tcount}].IsDead}
			{
				if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
					return TRUE

				if ${This.AggroGroup[${CustomActor[${tcount}].ID}]}
					return TRUE
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}


		Debug:Echo["No NPC was found within ${iEngageDistance} meters that was aggro to you or anyone in your group."]
		return FALSE
	}

	member:bool Target(int targetid)
	{
		if !${Actor[${targetid}].InCombatMode}
		{
			Debug:Echo["EQ2Bot-Target(): Return False - Actor Not InCombatMode"]
			return FALSE
		}
		
		if ${This.AggroGroup[${targetid}]} || ${Actor[${targetid}].Target.ID}==${Me.ID}
			return TRUE

		Debug:Echo["EQ2Bot-Target(): Return False - Actor not AggroGroup"]
		return FALSE
	}

	member:int NearestAggro(int iEngageDistance=${ScanRange})
	{
		variable int tcount=1

		if !${Actor[NPC,range,${iEngageDistance}](exists)} && !${Actor[NamedNPC,range,${iEngageDistance}](exists)}
		{
			return 0
		}

		EQ2:CreateCustomActorArray[byDist,${iEngageDistance},npc]
		do
		{
				; this should not be necessary, but I will put it here anyway
				if ${CustomActor[${tcount}].IsDead}
						continue

			if (${CustomActor[${tcount}].Target.ID}==${Me.ID} || ${This.AggroGroup[${CustomActor[${tcount}].ID}]}) && ${CustomActor[${tcount}].InCombatMode} && ${This.CheckActor[${CustomActor[${tcount}].ID}]}
			{
				if ${CustomActor[${tcount}].ID}
				{
					return ${CustomActor[${tcount}].ID}
				}
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

		return 0
	}

	member:bool FriendlyPet(uint actorid)
	{
		variable int tempvar

		if (${Me.GroupCount} > 1)
		{
			;echo Check if mob is a pet of my group
			tempvar:Set[0]
			do
			{
				if (${Me.Group[${tempvar}](exists)} && ${actorid} == ${Me.Group[${tempvar}].ToActor.Pet.ID})
					return TRUE
			}
			while ${tempvar:Inc}<=${Me.GroupCount}
		}

		;echo Check if mob is a pet of my raid
		if (${Me.InRaid})
		{
			;echo checking aggro on raid
			tempvar:Set[1]
			do
			{
				if (${Me.Raid[${tempvar}](exists)} && ${actorid} == ${Actor[${Me.Raid[${tempvar}].ID}].Pet.ID})
						return TRUE
			}
			while ${tempvar:Inc}<=${Me.RaidCount}
		}

		if ${Actor[${actorid}](exists)} && ${actorid}==${Me.Pet.ID}
			return TRUE

		return false
	}

	method CheckMYAggro()
	{
		variable int tcount=1
		haveaggro:Set[FALSE]
		variable uint ActorID

		if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
			return

		EQ2:CreateCustomActorArray[byDist,15,npc]
		do
		{
			ActorID:Set[${CustomActor[${tcount}].ID}]

			if ${ActorID} > 0
			{
					if ${This.ValidActor[${ActorID}]} && ${CustomActor[${tcount}].Target.ID}==${Me.ID} && ${CustomActor[${tcount}].InCombatMode}
					{
						haveaggro:Set[TRUE]
						aggroid:Set[${ActorID}]
						return
					}
				}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

		haveaggro:Set[FALSE]
		return
	}
}

objectdef EQ2BotObj
{

	method Init_Settings()
	{
		charfile:Set[${PATH_CHARACTER_CONFIG}/${Me.Name}.xml]
		spellfile:Set[${PATH_SPELL_LIST}/${Me.SubClass}.xml]
		LavishSettings:AddSet[EQ2Bot]
		LavishSettings[EQ2Bot]:Clear
		LavishSettings[EQ2Bot]:AddSet[Spells]
		LavishSettings[EQ2Bot].FindSet[Spells]:Import[${spellfile}]
		LavishSettings[EQ2Bot]:AddSet[Character]
		LavishSettings[EQ2Bot].FindSet[Character]:Import[${charfile}]
		LavishSettings[EQ2Bot]:AddSet[Temporary Settings]
		SpellSet:Set[${LavishSettings[EQ2Bot].FindSet[Spells]}]
		CharacterSet:Set[${LavishSettings[EQ2Bot].FindSet[Character]}]
		CharacterSet:AddSet[Temporary Settings]

		This:Init_Character

	}

	method RefreshList(string ListFQN, string SettingSet, bool IncludeMe=1, bool IncludePets=1, bool IncludeRaid=0, bool IncludeNoOne=1)
	{
		variable int tmpvar
		variable iterator iter
		variable index:string PreviousSelection

		if !${UIElement[${ListFQN}].Type.Find[combobox]}
		{
			CharacterSet.FindSet[${Me.SubClass}].FindSet[${SettingSet}]:GetSettingIterator[iter]
			if ${iter:First(exists)}
			{
				do
				{
					PreviousSelection:Insert[${iter.Value}]
				}
				while ${iter:Next(exists)}
			}
		}
		else
		{
			PreviousSelection:Insert[${UIElement[${ListFQN}].SelectedItem.Text}]
		}

		tmpvar:Set[1]

		UIElement[${ListFQN}]:ClearItems

		if ${UIElement[${ListFQN}].Type.Find[combobox]}
		{
			if ${IncludeNoOne}
				UIElement[${ListFQN}]:AddItem[No One]

			;UIElement[${ListFQN}].ItemByValue[No One]:Select
		}

		if ${IncludeMe}
			UIElement[${ListFQN}]:AddItem[${Me.Name}:${Me.ToActor.Type}]

		if ${Me.ToActor.Pet(exists)} && ${IncludePets}
		{
			UIElement[${ListFQN}]:AddItem[${Me.ToActor.Pet}:${Me.ToActor.Pet.Type}, FF0000FF]
		}

		if ${Me.Raid} > 0 && ${IncludeRaid}
		{
			tmpvar:Set[1]
			do
			{
				if (${Me.Raid[${tmpvar}].Name.Equal[${Me.Name}]})
					continue

				if ${Me.Raid[${tmpvar}].ToActor(exists)}
				{
					UIElement[${ListFQN}]:AddItem[${Me.Raid[${tmpvar}].Name}:${Me.Raid[${tmpvar}].ToActor.Type}]
					if (${Me.Raid[${tmpvar}].Class.Equal[conjuror]} || ${Me.Raid[${tmpvar}].Class.Equal[necromancer]})  && ${Me.Raid[${tmpvar}].ToActor.Pet(exists)} && ${IncludePets}
						UIElement[${ListFQN}]:AddItem[${Me.Raid[${tmpvar}].ToActor.Pet}:${Me.Raid[${tmpvar}].ToActor.Pet.Type},FF0000FF]
					if (${Me.Raid[${tmpvar}].Class.Equal[mystic]} || ${Me.Raid[${tmpvar}].Class.Equal[defiler]})  && ${Me.Raid[${tmpvar}].ToActor.Pet(exists)} && ${IncludePets}
						UIElement[${ListFQN}]:AddItem[${Me.Raid[${tmpvar}].ToActor.Pet}:${Me.Raid[${tmpvar}].ToActor.Pet.Type},FF0000FF]
				}
			}
			while ${tmpvar:Inc} <= 24
		}
		elseif ${Me.Group} > 1
		{
			tmpvar:Set[1]
			do
			{
				if ${Me.Group[${tmpvar}].ToActor(exists)}
				{
					UIElement[${ListFQN}]:AddItem[${Me.Group[${tmpvar}].Name}:${Me.Group[${tmpvar}].ToActor.Type}]
					if (${Me.Group[${tmpvar}].Class.Equal[conjuror]} || ${Me.Group[${tmpvar}].Class.Equal[necromancer]}) && ${Me.Group[${tmpvar}].ToActor.Pet(exists)}
						UIElement[${ListFQN}]:AddItem[${Me.Group[${tmpvar}].ToActor.Pet}:${Me.Group[${tmpvar}].ToActor.Pet.Type},FF0000FF]
					if (${Me.Group[${tmpvar}].Class.Equal[mystic]} || ${Me.Group[${tmpvar}].Class.Equal[defiler]}) && ${Me.Group[${tmpvar}].ToActor.Pet(exists)}
						UIElement[${ListFQN}]:AddItem[${Me.Group[${tmpvar}].ToActor.Pet}:${Me.Group[${tmpvar}].ToActor.Pet.Type},FF0000FF]
				}
			}
			while ${tmpvar:Inc} <= ${Me.Group}
		}

		if ${UIElement[${ListFQN}].Type.Find[combobox]}
		{
			UIElement[${ListFQN}]:SetSelection[${UIElement[${ListFQN}].ItemByText[${PreviousSelection[1]}].ID}
		}
		else
		{
			tmpvar:Set[1]
			while ${PreviousSelection[${tmpvar}](exists)}
			{
				UIElement[${ListFQN}].ItemByText[${PreviousSelection[${tmpvar}]}]:Select
				tmpvar:Inc
			}
		}
	}

	method Save_Settings()
	{
		LavishSettings[EQ2Bot].FindSet[Character]:Export[${charfile}]
	}

	method Init_Character()
	{
		charfile:Set[${PATH_CHARACTER_CONFIG}/${Me.Name}.xml]
		CharacterSet:AddSet[General Settings]
		CharacterSet:AddSet[${Me.SubClass}]

		switch ${Me.Archetype}
		{
			case scout
				AutoMelee:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Melee,TRUE]}]
				EngageDistance:Set[9]
				break

			case fighter
				AutoMelee:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Melee,TRUE]}]
				EngageDistance:Set[9]
				break

			case priest
				AutoMelee:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Melee,FALSE]}]
				EngageDistance:Set[35]
				break

			case mage
				AutoMelee:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Melee,FALSE]}]
				EngageDistance:Set[35]
				break
		}

		MainTank:Set[${CharacterSet.FindSet[General Settings].FindSetting[I am the Main Tank?,FALSE]}]
		MainAssistMe:Set[${CharacterSet.FindSet[General Settings].FindSetting[I am the Main Assist?,FALSE]}]

		if ${MainTank}
			CharacterSet.FindSet[General Settings]:AddSetting[Who is the Main Tank?,${Me.Name}]
		if ${MainAssistMe}
			CharacterSet.FindSet[General Settings]:AddSetting[Who is the Main Assist?,${Me.Name}]

		MainAssist:Set[${CharacterSet.FindSet[General Settings].FindSetting[Who is the Main Assist?,${Me.Name}]}]
		MainAssistID:Set[${Actor[exactname,${MainAssist}].ID}]
		MainTankPC:Set[${CharacterSet.FindSet[General Settings].FindSetting[Who is the Main Tank?,${Me.Name}]}]
		MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]
		AutoSwitch:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Switch Targets when Main Assist Switches?,TRUE]}]
		AutoLoot:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Loot Corpses and open Treasure Chests?,FALSE]}]
		LootCorpses:Set[${CharacterSet.FindSet[General Settings].FindSetting[Loot Corpses?,TRUE]}]
		LootAll:Set[${CharacterSet.FindSet[General Settings].FindSetting[Accept Loot Automatically?,TRUE]}]
		LootMethod:Set[${CharacterSet.FindSet[General Settings].FindSetting[LootMethod,Accept]}]
		AutoPull:Set[${CharacterSet.FindSet[General Settings].FindSetting[Auto Pull,FALSE]}]
		PullOnlySoloMobs:Set[${CharacterSet.FindSet[General Settings].FindSetting[PullOnlySoloMobs,FALSE]}]
		PullSpell:Set[${CharacterSet.FindSet[General Settings].FindSetting[What to use when PULLING?,SPELL]}]
		PullRange:Set[${CharacterSet.FindSet[General Settings].FindSetting[What RANGE to PULL from?,15]}]
		PullWithBow:Set[${CharacterSet.FindSet[General Settings].FindSetting[Pull with Bow (Ranged Attack)?,FALSE]}]
		ScanRange:Set[${CharacterSet.FindSet[General Settings].FindSetting[What RANGE to SCAN for Mobs?,20]}]
		if ${ScanRange} > 50
		{
				echo "WARNING:  Your 'Maximum Scan Range' is currently set to ${ScanRange}, which is a fairly high number."
				echo "          If this works for you, great; however, be advised that it might result in a loss of FPS in"
				echo "          particular zones or situations."
		}
		MARange:Set[${CharacterSet.FindSet[General Settings].FindSetting[What RANGE to Engage from Main Assist?,15]}]
		PowerCheck:Set[${CharacterSet.FindSet[General Settings].FindSetting[Minimum Power the puller will pull at?,80]}]
		HealthCheck:Set[${CharacterSet.FindSet[General Settings].FindSetting[Minimum Health the puller will pull at?,90]}]
		IgnoreEpic:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Epic Encounters?,FALSE]}]
		IgnoreNamed:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Named Encounters?,FALSE]}]
		IgnoreHeroic:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Heroic Encounters?,FALSE]}]
		IgnoreRedCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Red Con Mobs?,FALSE]}]
		IgnoreOrangeCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Orange Con Mobs?,FALSE]}]
		IgnoreYellowCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Yellow Con Mobs?,FALSE]}]
		IgnoreWhiteCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore White Con Mobs?,FALSE]}]
		IgnoreBlueCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Blue Con Mobs?,FALSE]}]
		IgnoreGreenCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Green Con Mobs?,FALSE]}]
		IgnoreGreyCon:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Ignore Grey Con Mobs?,FALSE]}]
		PullNonAggro:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Pull Non Aggro Mobs?,TRUE]}]
		AssistHP:Set[${CharacterSet.FindSet[General Settings].FindSetting[Assist and Engage in combat at what Health?,96]}]
		OORThreshold:Set[${CharacterSet.FindSet[General Settings].FindSetting[Out of Range Reaction Distance,25]}]
		Following:Set[${CharacterSet.FindSet[General Settings].FindSetting[Are we following someone?,FALSE]}]
		PathType:Set[${CharacterSet.FindSet[General Settings].FindSetting[What Path Type (0-4)?,0]}]
		CloseUI:Set[${CharacterSet.FindSet[General Settings].FindSetting[Close the UI after starting EQ2Bot?,FALSE]}]
		MasterSession:Set[${CharacterSet.FindSet[General Settings].FindSetting[Master IS Session,Master.is1]}]
		CheckPriestPower:Set[${CharacterSet.FindSet[General Settings].FindSetting[Check if Priest has Power in the Group?,TRUE]}]
		WipeRevive:Set[${CharacterSet.FindSet[General Settings].FindSetting[Revive on Group Wipe?,FALSE]}]
		BoxWidth:Set[${CharacterSet.FindSet[General Settings].FindSetting[Navigation: Size of Box?,4]}]
		LoreConfirm:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Loot Lore Items?,TRUE]}]
		NoTradeConfirm:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to Loot NoTrade Items?,FALSE]}]
		LootPrevCollectedShineys:Set[${CharacterSet.FindSet[General Settings].FindSetting[Do you want to loot previously collected shineys?,FALSE]}]

		BuffRoutinesTimerInterval:Set[${CharacterSet.FindSet[General Settings].FindSetting[BuffRoutinesTimerInterval,4000]}]
		OutOfCombatRoutinesTimerInterval:Set[${CharacterSet.FindSet[General Settings].FindSetting[OutOfCombatRoutinesTimerInterval,1000]}]
		AggroDetectionTimerInterval:Set[${CharacterSet.FindSet[General Settings].FindSetting[AggroDetectionTimerInterval,500]}]

		if ${PullWithBow}
		{
			if !${Me.Equipment[ammo](exists)} || !${Me.Equipment[ranged](exists)}
				PullWithBow:Set[FALSE]
			else
				PullRange:Set[25]
		}
		This:Save_Settings
	}

	method Init_Config()
	{
		This:Init_Settings
	}

	method Init_Events()
	{
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onLootWindowAppeared]:AttachAtom[LootWdw]
		;Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
		Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
	}

	method Init_Triggers()
	{

		; General Triggers
		AddTrigger IamDead "@npc@ has killed you."
		AddTrigger LoreItem "@*@You cannot have more than one of any given LORE item."
		AddTrigger LootWindowBusy "@*@You are too busy to loot right now@*@"
		AddTrigger InventoryFull "@*@You cannot loot while your inventory is full"
		AddTrigger InventoryFull "You do not have enough space to loot@*@"
		AddTrigger CantSeeTarget "@*@Can't see target@*@"

		; Bot Triggers
		AddTrigger BotCastTarget "cast @Spell@ on @castTarget@"
		AddTrigger BotFollow "follow @followTarget@"
		AddTrigger BotStop "EQ2Bot stop"
		AddTrigger BotAbort "EQ2Bot end"
		AddTrigger BotAbort "It will take about 20 more seconds to prepare your camp."
		AddTrigger BotTell "@tellSender@ tells you,@tellMessage@"
		AddTrigger BotCommand "EQ2Bot /@doCommand@"
		AddTrigger BotAutoMeleeOn "EQ2Bot melee on"
		AddTrigger BotAutoMeleeOff "EQ2Bot melee off"
	}

	method Init_UI()
	{
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
		ui -reload -skin eq2 "${PATH_UI}/eq2bot.xml"
	}

	member:float ConvertAngle(float angle)
	{
		if ${angle}<-180
		{
			direction:Set[TRUE]
			return ${angle:Inc[360]}
		}

		if ${angle}>=-180 && ${angle}<1
		{
			direction:Set[FALSE]
			return ${Math.Abs[${angle}]}
		}

		if ${angle}>180
		{
			direction:Set[FALSE]
			return ${Math.Calc[360-${angle}]}
		}
		else
		{
			direction:Set[TRUE]
		}

		return ${angle}
	}

	member:lnavregionref ScanWaypoints()
	{
		variable index:lnavregionref PullRegions
		variable int tempvar
		variable int tcount

		PullCount:Set[${LNavRegionGroup[Pull].RegionsWithin[PullRegions,200,${Me.X},${Me.Z},${Me.Y}]}]

		EQ2:CreateCustomActorArray[byDist]

		while ${tempvar:Inc}<=${PullCount}
		{
			if ${EQ2Nav.FindPath[${PullRegions.Get[${tempvar}].FQN}]}
			{
				PathIndex:Set[0]
				while ${PathIndex:Inc}<=${CurrentPath.Hops}
				{
					WPX:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.X}]
					WPY:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.Y}]
					WPZ:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.Z}]

					tcount:Set[1]
					while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
					{
						if ${Math.Distance[${WPX},${WPY},${CustomActor[${tcount}].X},${CustomActor[${tcount}].Z}]}<${ScanRange}
						{
							if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]}
							{
								return ${PullRegions.Get[${tempvar}].ID}
							}
						}
					}
				}
			}
		}

		return 0
	}

	member:int ProtectHealer()
	{
		variable int tempvar=0

		do
		{
			switch ${Me.Group[${tempvar}].Class}
			{
				case priest
				case cleric
				case templar
				case inquisitor
				case druid
				case fury
				case warden
				case shaman
				case defiler
				case mystic
					return ${Me.Group[${tempvar}].ID}
			}
		}
		while ${tempvar:Inc}<=${Me.GroupCount}

		return 0
	}

	method MainAssist_Dead()
	{
		if !${Actor[${OriginalMA}].IsDead} && ${Actor[${OriginalMA}](exists)}
		{
			MainAssist:Set[${OriginalMA}]
			MainAssistID:Set[${Actor[exactname,${MainAssist}].ID}]
			KillTarget:Set[]
			Echo Switching back to the original MainAssist ${MainAssist}
			return
		}
		else
		{
			MainAssist:Set[${MainTankPC}]
			MainAssistID:Set[${Actor[exactname,${MainAssist}].ID}]
		}
	}

	method MainTank_Dead()
	{
		variable int highesthp

		if !${Actor[${OriginalMT}].IsDead} && ${Actor[${OriginalMT}](exists)}
		{
			MainTank:Set[FALSE]
			MainTankPC:Set[${OriginalMT}]
			MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]
			KillTarget:Set[]
			Echo Switching back to the original MainTank ${MainTankPC}
			return
		}

		if ${Me.Archetype.Equal[fighter]}
		{
			highesthp:Set[${Me.MaxHealth}]
			MainTank:Set[TRUE]
			MainTankPC:Set[${Me.Name}]
			MainTankID:Set[${Me.ID}]
		}

		grpcnt:Set[${Me.GroupCount}]

		; We really should check "ourself" (ie, start at zero); however, Group[0] is 'actortype' and doesn't have a MaxHitPoints member.
		tempgrp:Set[1]
		do
		{
			switch ${Me.Group[${tempgrp}].Class}
			{
				case berserker
				case guardian
				case bruiser
				case monk
				case paladin
				case shadowknight
					if ${Me.Group[${tempgrp}].MaxHitPoints}>${highesthp}
					{
						highesthp:Set[${Me.Group[${tempgrp}].MaxHitPoints}]
						MainTank:Set[FALSE]
						MainTankPC:Set[${Me.Group[${tempgrp}].Name}]
						MainTankID:Set[${Me.Group[${tempgrp}].ID}]
					}
			}
		}
		while ${tempgrp:Inc}<=${grpcnt}

		if ${Me.InRaid}
		{
			tempgrp:Set[1]
			do
			{
				switch ${Me.Raid[${tempgrp}].Class}
				{
					case berserker
					case guardian
					case bruiser
					case monk
					case paladin
					case shadowknight
						if ${Me.Raid[${tempgrp}].MaxHitPoints}>${highesthp}
						{
							highesthp:Set[${Me.Raid[${tempgrp}].MaxHitPoints}]
							MainTank:Set[FALSE]
							MainTankPC:Set[${Me.Raid[${tempgrp}].Name}]
							MainTankID:Set[${Me.Raid[${tempgrp}].ID}]
						}
				}
			}
			while ${tempgrp:Inc}<=${Me.RaidCount}
		}

		if ${highesthp}
		{
			Echo Setting MainTank to ${MainTankPC}
			return
		}

		if ${Me.Archetype.Equal[scout]}
		{
			highesthp:Set[${Me.MaxHealth}]
			MainTank:Set[TRUE]
			MainTankPC:Set[${Me.Name}]
			MainTankID:Set[${Me.ID}]
		}

		tempgrp:Set[1]
		do
		{
			switch ${Me.Group[${tempgrp}].Class}
			{
				case assassin
				case ranger
				case brigand
				case swashbuckler
				case dirge
				case troubador
					if ${Me.Group[${tempgrp}].MaxHitPoints}>${highesthp}
					{
						highesthp:Set[${Me.Group[${tempgrp}].MaxHitPoints}]
						MainTank:Set[FALSE]
						MainTankPC:Set[${Me.Group[${tempgrp}].Name}]
						MainTankID:Set[${Me.Group[${tempgrp}].ID}]
					}
			}
		}
		while ${tempgrp:Inc}<${grpcnt}

		if ${highesthp}
		{
			Echo Setting MainTank to ${MainTankPC}
			return
		}

		if ${Me.Archetype.Equal[mage]}
		{
			highesthp:Set[${Me.MaxHealth}]
			MainTank:Set[TRUE]
			MainTankPC:Set[${Me.Name}]
			MainTankID:Set[${Me.ID}]
		}

		tempgrp:Set[1]
		do
		{
			switch ${Me.Group[${tempgrp}].Class}
			{
				case conjuror
				case necromancer
				case warlock
				case wizard
				case coercer
				case illusionist
					if ${Me.Group[${tempgrp}].MaxHitPoints}>${highesthp}
					{
						highesthp:Set[${Me.Group[${tempgrp}].MaxHitPoints}]
						MainTank:Set[FALSE]
						MainTankPC:Set[${Me.Group[${tempgrp}].Name}]
						MainTankID:Set[${Me.Group[${tempgrp}].ID}]
					}
			}
		}
		while ${tempgrp:Inc}<${grpcnt}

		if ${highesthp}
		{
			Echo Setting MainTank to ${MainTankPC}
			return
		}

		if ${Me.Archetype.Equal[priest]}
		{
			highesthp:Set[${Me.MaxHealth}]
			MainTank:Set[TRUE]
			MainTankPC:Set[${Me.Name}]
			MainTankID:Set[${Me.ID}]
		}

		tempgrp:Set[1]
		do
		{
			switch ${Me.Group[${tempgrp}].Class}
			{
				case inquisitor
				case templar
				case fury
				case warden
				case defiler
				case mystic
					if ${Me.Group[${tempgrp}].MaxHitPoints}>${highesthp}
					{
						highesthp:Set[${Me.Group[${tempgrp}].MaxHitPoints}]
						MainTank:Set[FALSE]
						MainTankPC:Set[${Me.Group[${tempgrp}].Name}]
						MainTankID:Set[${Me.Group[${tempgrp}].ID}]
					}
			}
		}
		while ${tempgrp:Inc}<${grpcnt}

		if ${highesthp}
		{
			Echo Setting MainTank to ${MainTankPC}
			return
		}
	}

	member:bool PriestPower()
	{
		variable int tempvar=0

		if !${CheckPriestPower}
			return TRUE

		do
		{
			switch ${Me.Group[${tempvar}].Class}
			{
				case priest
				case cleric
				case templar
				case inquisitor
				case druid
				case fury
				case warden
				case shaman
				case defiler
				case mystic
					if ${Me.Group[${tempvar}].ToActor.Power}>80
					{
						return TRUE
					}
					return FALSE

				case default
					break
			}
		}
		while ${tempvar:Inc}<=${Me.GroupCount}

		return TRUE
	}

	method SetActorLooted(uint ActorID, string ActorName)
	{
		if (${ActorsLooted.Used} > 50)
			ActorsLooted:Clear

		ActorsLooted:Set[${ActorID},${ActorName}]
	}
}

function CheckAbilities(string class)
{
	variable int keycount
	variable int templvl=1
	variable string tempnme
	variable int tempvar=1
	variable string spellname
	variable int MissingAbilitiesCount
	variable iterator SpellIterator
	SpellSet.FindSet[${class}]:GetSettingIterator[SpellIterator]

	if ${SpellIterator:First(exists)}
	{
		do
		{
			tempnme:Set["${SpellIterator.Key}"]

			templvl:Set[${Arg[1,${tempnme}]}]

			if ${templvl} > ${Me.Level}
				continue

			spellname:Set[${SpellIterator.Value}]

			;Debug:Echo["DEBUG-CheckAbilities: spellname: ${spellname} -- tempnme: ${tempnme} -- templvl: ${templvl}  (Me.Level: ${Me.Level})"]
			if (${spellname.Length})
			{
				if !${Me.Ability[${spellname}](exists)}
				{
					; We are only concerned about abilities that are greater than 15 levels below us
					if (${templvl} >= ${Math.Calc[${Me.Level}-15]})
					{
						echo "Missing Ability: '${spellname}' (Level: ${templvl})"
						MissingAbilitiesCount:Inc
					}
					else
					{
						;Debug:Echo["tempnme: ${tempnme}"]
						;Debug:Echo["Setting SpellType[${Arg[2,${tempnme}]}] to '${spellname}'"]
						SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
					}
				}
				else
				{
					;Debug:Echo["tempnme: ${tempnme}"]
					;Debug:Echo["Setting SpellType[${Arg[2,${tempnme}]}] to '${spellname}'"]
					SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
				}
			}
		}
		while ${SpellIterator:Next(exists)}
	}

	if (${MissingAbilitiesCount} > 0 && ${Me.Level} >= 10)
	{
		echo "------------"
		echo "You appear to be missing abilities.  Checking knowledge book and searching again..."
		wait 5
		EQ2Execute /toggleknowledge
		wait 5
		EQ2Execute /toggleknowledge
		MissingAbilitiesCount:Set[0]
		tempvar:Set[1]

		if ${SpellIterator:First(exists)}
		{
			do
			{
				tempnme:Set["${SpellIterator.Key}"]

				templvl:Set[${Arg[1,${tempnme}]}]

				if ${templvl} > ${Me.Level}
					continue

				spellname:Set[${SpellIterator.Value}]
				if (${spellname.Length})
				{
					if !${Me.Ability[${spellname}](exists)}
					{
						; This will avoid spamming with AA abilities (and besides, do we really care if we are missing an ability under level 10 or 20 levels below us?)
						; By this point the list should be accurate
						if (${templvl} > 10 && (${templvl} >= ${Math.Calc[${Me.Level}-15]}))
						{
							echo "Missing Ability: '${spellname}' (Level: ${templvl})"
							MissingAbilitiesCount:Inc
						}
						else
							SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
					}
					else
						SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
				}
			}
			while ${SpellIterator:Next(exists)}
		}
	}
	else
	{
		echo "Abilities Set."
		return
	}

	if (${MissingAbilitiesCount} > 6 && ${Me.Level} >= 10)
	{
		echo "------------"
		echo "You still appear to be missing abilities.  Checking knowledge book and searching again..."
		wait 20
		EQ2Execute /toggleknowledge
		wait 20
		EQ2Execute /toggleknowledge
		MissingAbilitiesCount:Set[0]
		tempvar:Set[1]

		if ${SpellIterator:First(exists)}
		{
			do
			{
				tempnme:Set["${SpellIterator.Key}"]

				templvl:Set[${Arg[1,${tempnme}]}]

				if ${templvl} > ${Me.Level}
					continue

				spellname:Set[${SpellIterator.Value}]
				if (${spellname.Length})
				{
					if !${Me.Ability[${spellname}](exists)}
					{
						; This will avoid spamming with AA abilities (and besides, do we really care if we are missing an ability under level 10 or 20 levels below us?)
						; By this point the list should be accurate
						if (${templvl} > 10 && (${templvl} >= ${Math.Calc[${Me.Level}-15]}))
						{
							echo "Missing Ability: '${spellname}' (Level: ${templvl})"
							MissingAbilitiesCount:Inc
						}
						else
							SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
					}
					else
						SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
				}
			}
			while ${SpellIterator:Next(exists)}
		}
	}
	else
	{
		echo "Much better -- abilities Set."
		return
	}

	if (${MissingAbilitiesCount} > 6 && ${Me.Level} >= 10)
	{
		echo "------------"
		echo "You STILL appear to be missing abilities.  Checking knowledge book and searching again..."
		wait 30
		EQ2Execute /toggleknowledge
		wait 30
		EQ2Execute /toggleknowledge
		MissingAbilitiesCount:Set[0]
		tempvar:Set[1]

		if ${SpellIterator:First(exists)}
		{
			do
			{
				tempnme:Set["${SpellIterator.Key}"]

				templvl:Set[${Arg[1,${tempnme}]}]

				if ${templvl} > ${Me.Level}
					continue

				spellname:Set[${SpellIterator.Value}]
				if (${spellname.Length})
				{
					if !${Me.Ability[${spellname}](exists)}
					{
						; This will avoid spamming with AA abilities (and besides, do we really care if we are missing an ability under level 10 or 20 levels below us?)
						; By this point the list should be accurate
						if (${templvl} > 10 && (${templvl} >= ${Math.Calc[${Me.Level}-15]}))
						{
							echo "Missing Ability: '${spellname}' (Level: ${templvl})"
							MissingAbilitiesCount:Inc
						}
						else
							SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
					}
					else
						SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
				}
			}
			while ${SpellIterator:Next(exists)}
		}

		if ${MissingAbilitiesCount} > 6
			echo "It appears that are missing more than 6 abilities for this character. If this is not an error, please ignore this message (and buy your skills!) -- otherwise, please restart EQ2Bot."
		else
			echo "Much better -- abilities Set."
		echo "------------"
	}
	else
	{
		echo "Much better -- abilities Set."
		return
	}
}

objectdef Navigation
{
	method Initialise()
	{
		variable index:lnavregionref CheckRegion
		variable index:lnavregionref CheckPOI
		variable int Index

		while ${Index:Inc}<=50
		{
			POIList[${Index}]:Set[]
			POIInclude[${Index}]:Set[0]
		}

		if ${ConfigPath.FileExists[${Zone.ShortName}.xml]}
		{
			LavishNav.Tree:Import[${ConfigPath}${Zone.ShortName}.xml]
			echo ${ConfigPath}${Zone.ShortName}.xml Loaded!
		}
		else
		{
			LavishNav.Tree:AddChild[universe,${Zone.Name},-unique]
			;Debug:Echo["DEBUG(Navigation): New Zone Created!"]
			UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		}

		if ${LNavRegionGroup[Start].RegionsWithin[CheckRegion,99999,${Me.X},${Me.Z},${Me.Y}]}
		{
			CampNav:Set[FALSE]
			UIElement[Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:UnsetChecked
			UIElement[Dungeon Crawl@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetChecked
			CheckFinish
			UIElement[Move Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		}
		else
		{
			CampNav:Set[TRUE]
			UIElement[Dungeon Crawl@Navigation@EQ2Bot Tabs@EQ2 Bot]:UnsetChecked
			UIElement[Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetChecked
		}

		POICount:Set[${LNavRegionGroup[POI].RegionsWithin[CheckPOI,99999,${Me.X},${Me.Z},${Me.Y}]}]
		POIList[1]:Set[Start]
		POIInclude[1]:Set[TRUE]
		POIList[${Math.Calc[${POICount}+2]}]:Set[Finish]
		POIInclude[${Math.Calc[${POICount}+2]}]:Set[TRUE]

		if ${POICount}
		{
			Index:Set[0]
			while ${CheckPOI.Get[${Index:Inc}](exists)}
			{
				POIList[${Math.Calc[${CheckPOI.Get[${Index}].Custom[Priority]}+1]}]:Set[${CheckPOI.Get[${Index}].FQN}]
				POIInclude[${Math.Calc[${CheckPOI.Get[${Index}].Custom[Priority]}+1]}]:Set[${CheckPOI.Get[${Index}].Custom[Inclusion]}]
			}

			Index:Set[1]
			while ${Index:Inc}<=${Math.Calc[${POICount}+1]}
			{
				if ${POIInclude[${Index}]}
					UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetTextColor[FF22FF22]:AddItem[${POIList[${Index}]} (INCLUDED)]
				else
					UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetTextColor[FFFF0000]:AddItem[${POIList[${Index}]} (EXCLUDED)]
			}
		}
	}

	method UpdateNavGUI()
	{
		if !${StartNav} && !${StartBot}
			return

		variable index:lnavregionref CampRegions
		variable index:lnavregionref PullRegions
		variable index:lnavregionref StartRegion

		RegionCount:Set[${LNavRegion[${Zone.Name}].ChildCount}]

		if ${CampNav}
		{
			UIElement[Finish Text 1@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			UIElement[Camp Count@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
			UIElement[Pull Count@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show

			CampCount:Set[${LNavRegionGroup[Camp].RegionsWithin[CampRegions,99999,${Me.X},${Me.Z},${Me.Y}]}]
			PullCount:Set[${LNavRegionGroup[Pull].RegionsWithin[PullRegions,99999,${Me.X},${Me.Z},${Me.Y}]}]

			if ${LNavRegionGroup[Camp].Contains[${This.CurrentRegion}]} || !${CampCount} || ${StartNav}
			{
				UIElement[Warning Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
				UIElement[Move Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			}
			else
			{
				UIElement[Warning Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
				UIElement[Move Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
			}

			if ${CampCount}>0
				UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to continue creating Pull Regions]
			else
				UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to create a new Camp and begin pathing]
		}
		else
		{
			UIElement[Warning Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			UIElement[Camp Count@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			UIElement[Pull Count@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide

			if ${LNavRegionGroup[Start].RegionsWithin[StartRegion,99999,${Me.X},${Me.Z},${Me.Y}]}
			{
				if !${IsFinish}
					UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to continue creating Regions]

				if !${StartNav} && !${LNavRegionGroup[Start].Contains[${This.CurrentRegion}]}
					UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
				else
					UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			}
			else
			{
				UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to create a new Start location and begin pathing]
				UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			}
		}

		if !${StartNav} && ${RegionCount}>0
			UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		else
			UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	}

	method AutoBox(string name)
	{
		Region:SetRegion[${LNavRegion[${Zone.Name}].BestContainer[${Me.X},${Me.Z},${Me.Y}].ID}]

		if ${Region.Type.Equal[Universe]}
		{
			Region:AddChild[box,"auto",-unique,${Math.Calc[${Me.X}-${BoxWidth}]},${Math.Calc[${Me.X}+${BoxWidth}]},${Math.Calc[${Me.Z}-${BoxWidth}]},${Math.Calc[${Me.Z}+${BoxWidth}]},${Math.Calc[${Me.Y}-${BoxWidth}]},${Math.Calc[${Me.Y}+${BoxWidth}]}]
			LNavRegion[${This.CurrentRegion}]:SetAllPointsValid[TRUE]
		}

		if ${name.Length}
			LNavRegionGroup[${name}]:Add[${This.CurrentRegion}]
	}

	member:bool ShouldConnect(lnavregionref regionA, lnavregionref regionB)
	{
		if ${regionA.ID}==${regionB.ID}
			return FALSE

		return TRUE
	}

	method ConnectRegions()
	{
		variable index:lnavregionref SurroundingRegions
		variable int RegionsFound
		variable int Index
		variable float DistanceToCheck

		Region:SetRegion[${This.CurrentRegion}]

		switch ${Region.Type}
		{
			case Box
				DistanceToCheck:Set[${BoxWidth}*0.8]
				break

			case point
				; Ignore Points as they are already handled
				break

			default
				echo Unknown Object Type ${Region.Type}
				return
				break
		}

		RegionsFound:Set[${LNavRegion[${Zone.Name}].DescendantsWithin[SurroundingRegions,${DistanceToCheck},${Region.CenterPoint}]}]

		if ${RegionsFound}>0
		{
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
			{
				if !${Region.GetConnection[${SurroundingRegions.Get[${Index}].FQN}](exists)}
				{
					if ${This.ShouldConnect[${Region.ID},${SurroundingRegions.Get[${Index}].ID}]}
					{
						Region:Connect[${SurroundingRegions.Get[${Index}].ID}]
						SurroundingRegions.Get[${Index}]:Connect[${Region.ID}]
					}
				}
			}
		}
	}

	member:lnavregionref CurrentRegion()
	{
		Region:SetRegion[${LNavRegion[${Zone.Name}].BestContainer[${Me.X},${Me.Z},${Me.Y}].ID}]
		return ${Region.ID}
	}

	method AddPoint(string name)
	{
		LNavRegion[${This.CurrentRegion}]:AddChild[point,${name},-unique,${Me.X},${Me.Z},${Me.Y}].ID]

		if !${LNavRegion[${name}].Parent.Type.Equal[Universe]}
			LNavRegion[${LNavRegion[${name}].Parent.Name}]:Connect[${name}]

		POICount:Inc
		LNavRegionGroup[POI]:Add[${This.CurrentRegion}]
		UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetTextColor[FF22FF22]:AddItem[${name} (INCLUDED)]
		LNavRegion[${This.CurrentRegion}]:SetCustom[Priority,${POICount}]
		LNavRegion[${This.CurrentRegion}]:SetCustom[Inclusion,TRUE]
	}

	member:bool FindPath(string destination)
	{
		variable lnavregionref closestpoint

		closestpoint:SetRegion[${This.FindClosestRegion[${Me.X},${Me.Z},${Me.Y}]}]
		PathIndex:Set[1]
		CurrentPath:Clear

		PathFinder:SelectPath[${closestpoint.FQN},${LNavRegion[${Zone.Name}].FindRegion[${destination}].FQN},CurrentPath]

		if ${CurrentPath.Hops}>0
			return TRUE

		return FALSE
	}

	member:lnavregionref FindClosestRegion(float x, float y, float z)
	{
		variable lnavregionref Container

		Container:SetRegion[${This.CurrentRegion.BestContainer[${x},${y},${z}]}]

		if !${Container.Type.Equal[Universe]}
			return ${Container}

		return ${Container.NearestChild[${x},${y},${z}]}
	}
}

function AddPullRegion()
{
	LNavRegionGroup[Pull]:Add[${EQ2Nav.CurrentRegion}]
	EQ2Nav:UpdateNavGUI
	call MoveToGroup Camp
}

function MoveToGroup(string gname)
{
	if ${NoAutoMovement}
		return

	if !${LNavRegionGroup[${gname}].Contains[${EQ2Nav.CurrentRegion}]} && ${LNavRegionGroup[${gname}].Contains[${EQ2Nav.FindClosestRegion[${Me.X},${Me.Z},${Me.Y}]}]}
	{
		movingtowp:Set[TRUE]
		pulling:Set[TRUE]

		press -hold ${forward}

		WPX:Set[${EQ2Nav.FindClosestRegion[${Me.X},${Me.Z},${Me.Y}].CenterPoint.X}]
		WPY:Set[${EQ2Nav.FindClosestRegion[${Me.X},${Me.Z},${Me.Y}].CenterPoint.Y}]

		call FastMove ${WPX} ${WPY} 2

		if ${Me.IsMoving}
			press -release ${forward}

		movetowp:Set[FALSE]
	}

	if ${EQ2Nav.FindPath[${LNavRegionGroup[${gname}].NearestRegion[${Me.X},${Me.Z},${Me.Y}].FQN}]}
	{
		movingtowp:Set[TRUE]
		pulling:Set[TRUE]

		press -hold ${forward}


		while ${PathIndex:Inc}<=${CurrentPath.Hops}
		{
			WPX:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.X}]
			WPY:Set[${CurrentPath.Region[${PathIndex}].CenterPoint.Y}]

			call FastMove ${WPX} ${WPY} 2
		}

		if ${Me.IsMoving}
			press -release ${forward}

		movetowp:Set[FALSE]
	}
}

atom StartPather()
{
	variable index:lnavregionref StartRegion

	UIElement[Dungeon Crawl@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Start Nav@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Move Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide

	if ${CampNav}
	{
		UIElement[Save Path Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		UIElement[End Path Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		CurrentRegion:Set[${EQ2Nav.CurrentRegion}]
		LastRegion:Set[${CurrentRegion}]
		EQ2Nav:AutoBox[Camp]
		UIElement[Add Pull Region@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		UIElement[Path Type@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Navigation for Camp Mode]
	}
	else
	{
		UIElement[Save Path DC@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		UIElement[End Path DC@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		UIElement[Add POI@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		CurrentRegion:Set[${EQ2Nav.CurrentRegion}]
		LastRegion:Set[${CurrentRegion}]

		if !${LNavRegionGroup[Start].RegionsWithin[StartRegion,99999,${Me.X},${Me.Z},${Me.Y}]}
			EQ2Nav:AutoBox[Start]

		UIElement[Path Type@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Navigation for Dungeon Crawl Mode]

		if ${IsFinish}
		{
			UIElement[Finish Text 2@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		}
		else
		{
			UIElement[Finish@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
			UIElement[Finish Text 1@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		}

		UIElement[Include@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		UIElement[Exclude@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	}

	UIElement[Path Type@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	StartNav:Set[TRUE]
	EQ2Nav:UpdateNavGUI
}

atom ClearPath()
{
	LavishNav:Clear
	UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:ClearItems
	IsFinish:Set[FALSE]
	LavishNav.Tree:AddChild[universe,${Zone.Name},-unique]
	UIElement[Start Nav@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	EQ2Nav:UpdateNavGUI
}

atom SavePath()
{
	variable int tempvar
	variable string selectpoi

	while ${UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].Item[${tempvar:Inc}](exists)}
	{
		selectpoi:Set[${UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].OrderedItem[${tempvar}]}]
		selectpoi:Set[${selectpoi.Token[1,(]}]
		LNavRegion[${Zone.Name}].FindRegion[${selectpoi}]:SetCustom[Priority,${tempvar}]
	}

	LNavRegion[${Zone.Name}]:Export[${ConfigPath}${Zone.ShortName}.xml]
	EndPath
}

atom EndPath()
{
	StartNav:Set[FALSE]

	UIElement[Add Pull Region@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Path Type@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Finish@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Include@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Exclude@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Finish Text 1@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Finish Text 2@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Dungeon Crawl@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	UIElement[Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	UIElement[Start Nav@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show

	if ${CampNav}
	{
		UIElement[End Path Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		UIElement[Save Path Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		UIElement[Move Camp@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	}
	else
	{
		UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		UIElement[Add POI@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		UIElement[End Path DC@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		UIElement[Save Path DC@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		CheckFinish
	}

	EQ2Nav:Initialise
}

atom CheckFinish()
{
	variable index:lnavregionref FinishRegion

	if ${LNavRegionGroup[Finish].RegionsWithin[FinishRegion,99999,${Me.X},${Me.Z},${Me.Y}]}
	{
		IsFinish:Set[TRUE]
		UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Finish Region Already exists!!]
		UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	}
	else
	{
		IsFinish:Set[FALSE]
		UIElement[Start Nav@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
	}

	EQ2Nav:UpdateNavGUI
}

atom CreateFinish()
{
	EQ2Nav:AutoBox[Finish]
	UIElement[Finish@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Finish Text 1@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
	UIElement[Finish Text 2@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
}

atom IncludePOI()
{
	variable string selectpoi

	if ${UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
	{
		selectpoi:Set[${UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
		selectpoi:Set[${selectpoi.Token[1,(]}]
		UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].SelectedItem:SetTextColor[FF22FF22]:SetText[${selectpoi} (INCLUDED)]
		LNavRegion[${Zone.Name}].FindRegion[${selectpoi}]:SetCustom[Inclusion,TRUE]
	}
}

atom ExcludePOI()
{
	variable string selectpoi

	if ${UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
	{
		selectpoi:Set[${UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
		selectpoi:Set[${selectpoi.Token[1,(]}]
		UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot].SelectedItem:SetTextColor[FFFF0000]:SetText[${selectpoi} (EXCLUDED)]
		LNavRegion[${Zone.Name}].FindRegion[${selectpoi}]:SetCustom[Inclusion,FALSE]
	}
}

atom(script) EQ2_onChoiceWindowAppeared()
{
	if ${PauseBot} || !${StartBot}
		return

	Debug:Echo["EQ2_onChoiceWindowAppeared -- '${ChoiceWindow.Text}'"]

	if ${ChoiceWindow.Text.Find[cast]} && ${Me.ToActor.Health}<1
	{
		ChoiceWindow:DoChoice1
		if ${KillTarget} && ${Actor[${KillTarget}](exists)}
		{
			if !${Actor[${KillTarget}].InCombatMode}
				KillTarget:Set[0]
		}
		InitialBuffsDone:Set[0]
		return
	}

	if ${ChoiceWindow.Text.Find[thoughtstone]}
	{
		ChoiceWindow:DoChoice1
		return
	}

	if ${ChoiceWindow.Text.Find[Lore]} && ${Me.ToActor.Health}>1
	{
		if ${LoreConfirm}
			ChoiceWindow:DoChoice1
		else
			ChoiceWindow:DoChoice2
		return
	}

	if ${ChoiceWindow.Text.Find[No-Trade]} && ${Me.ToActor.Health}>1
	{
		if ${NoTradeConfirm}
			ChoiceWindow:DoChoice1
		else
			ChoiceWindow:DoChoice2
		return
	}

	if ${ChoiceWindow.Text.Find[Heirloom]} && ${Me.ToActor.Health}>1
	{
		if ${NoTradeConfirm}
			ChoiceWindow:DoChoice1
		else
			ChoiceWindow:DoChoice2
		return
	}

	;ChoiceWindow:DoChoice2
	return
}

function AddPOI()
{
	InputBox "Name this Point of Interest!"
	if ${UserInput.Length}
	{
		EQ2Nav:AddPoint[${UserInput}]
	}
}

function atexit()
{
	Echo Ending EQ2Bot!

	if ${NoAtExit}
		return

	CurrentTask:Set[FALSE]
	call Class_Shutdown

	ui -unload "${PATH_UI}/eq2bot.xml"

	DeleteVariable CurrentTask

	Event[EQ2_onChoiceWindowAppeared]:DetachAtom[EQ2_onChoiceWindowAppeared]
	Event[EQ2_onLootWindowAppeared]:DetachAtom[LootWdw]
	Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]
	Event[EQ2_onIncomingChatText]:DetachAtom[EQ2_onIncomingChatText]

	press -release ${forward}
	press -release ${backward}
	press -release ${strafeleft}
	press -release ${straferight}


	LavishSettings[EQ2Bot]:Remove
}
