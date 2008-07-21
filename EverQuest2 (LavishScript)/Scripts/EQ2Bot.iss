;-----------------------------------------------------------------------------------------------
; EQ2Bot.iss Version 2.7.2a Updated: 04/25/08 by Pygar
;
; See /InnerSpace/Scripts/EQ2Bot/EQ2BotRelease_Notes.txt for changes
;-----------------------------------------------------------------------------------------------
;===================================================
;===        Version Checking             ====
;===================================================
;;; /EQ2Bot/Class Routines ONLY here
;;; The spell list and GUI files for each class should be handled within the initialization of each class file.
;;; The main script, EQ2BotLib, and the primary GUI files are included in the isxeq2 patcher.
variable int Latest_AssassinVersion = 0
variable int Latest_BerserkerVersion = 0
variable int Latest_BrigandVersion = 0
variable int Latest_BruiserVersion = 0
variable int Latest_CoercerVersion = 0
variable int Latest_ConjurerVersion = 0
variable int Latest_DefilerVersion = 0
variable int Latest_DirgeVersion = 0
variable int Latest_FuryVersion = 0
variable int Latest_GuardianVersion = 0
variable int Latest_IllusionistVersion = 20080517
variable int Latest_InquisitorVersion = 0
variable int Latest_MonkVersion = 0
variable int Latest_MysticVersion = 0
variable int Latest_NecromancerVersion = 0
variable int Latest_PaladinVersion = 0
variable int Latest_RangerVersion = 0
variable int Latest_ShadownightVersion = 0
variable int Latest_SwashbucklerVersion = 0
variable int Latest_TemplarVersion = 0
variable int Latest_TroubadorVersion = 0
variable int Latest_WardenVersion = 0
variable int Latest_WarlockVersion = 0
variable int Latest_WizardVersion = 0
;===================================================
;===        Keyboard Configuration              ====
;===================================================
variable string forward=w
variable string backward=s
variable string strafeleft=q
variable string straferight=e
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
variable filepath mainpath="${LavishScript.HomeDirectory}/Scripts/"
variable string spellfile
variable string charfile
variable string SpellType[400]
variable int AssistHP
variable string MainAssist
variable string MainTankPC
variable bool MainAssistMe=FALSE
variable string OriginalMA
variable string OriginalMT
variable bool AutoSwitch
variable bool AutoMelee
variable bool AutoPull
variable bool PullOnlySoloMobs
variable bool AutoLoot
variable bool LootAll
variable int KillTarget
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
variable int movetimer
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
variable int stuckcnt
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
variable int chktimer
variable int starttimer=${Time.Timestamp}
variable bool avoidhate
variable bool lostaggro
variable int aggroid
variable bool usemanastone
variable int mstimer=${Time.Timestamp}
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
;===================================================
;===          Lavish Navigation                 ====
;===================================================
variable filepath ConfigPath = "${LavishScript.CurrentDirectory}/Scripts/EQ2Bot/Navigational Paths/"
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
variable bool NoMovement=FALSE
variable int RegionCount
variable bool IsFinish
variable string POIList[50]
variable bool POIInclude[50]
variable int POICount
variable int CurrentPOI=1
;===========================================================
; Define the PathType
; 0 = Manual Movement
; 1 = Minimum Movement - Home Point Set
; 2 = Camp - Follow Small Nav Path with multiple Pull Points
; 3 = Dungeon Crawl - Follow Nav Path: Start to Finish
; 4 = Auto Hunting - Pull nearby Mobs within a Maximum Range
;===========================================================
variable int PathType
;AutoFollow Variables
;variable bool AutoFollowMode=FALSE
;variable bool AutoFollowingMA=FALSE
;variable string AutoFollowee

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/${Me.SubClass}.iss
#include ${LavishScript.HomeDirectory}/Scripts/moveto.iss
#includeoptional ${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/${Me.Name}.iss

function main()
{
	variable int tempvar
	variable int tempvar1
	variable int tempvar2
	variable string tempnme
	variable bool MobDetected
	declare LastWindow string script

	if !${ISXEQ2.IsReady}
	{
		echo ISXEQ2 has not been loaded!  EQ2Bot can not run without it.  Good Bye!
		Script:End
	}

	Turbo 50

	;Script:Squelch
	;Script:EnableProfiling

	CurrentAction:Set["* Initializing EQ2Bot..."]
	echo "---------"
	echo "* Initializing EQ2Bot..."

	;;;;;;;;;;;;;;;;;
	;;;; Set strings used in UI
	;;;
	if (${Me.Level} < 80)
		GainedXPString:Set[Gained XP:  ${Math.Calc[(${Me.Exp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100)].Precision[1]} ( ${Math.Calc[((${Me.Exp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100))/(((${Time.Timestamp}+1)-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetInt[StartTime]})/3600)].Precision[2]} / hr)]
	else
			GainedXPString:Set[Gained APExp:  ${Math.Calc[(${Me.APExp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100)].Precision[1]} ( ${Math.Calc[((${Me.APExp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100))/(((${Time.Timestamp}+1)-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetInt[StartTime]})/3600)].Precision[2]} / hr)]
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
		;echo "Main Loop: Test-${Time.Timestamp}"
		;;;;;;;;;;;;;;;;;
		;;;; Set strings used in UI.  They are set here in order to make for custom strings based upon level, etc.  Also, any ${} called in the UI is accessed
		;;;; EVERY frame.  By moving things here, we can reduce the number of times things are called, increasing efficiency (when desired.)
		;;;
		if (${Me.Level} < 80)
			GainedXPString:Set[Gained XP:  ${Math.Calc[(${Me.Exp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100)].Precision[1]} ( ${Math.Calc[((${Me.Exp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartXP]})+((${Me.Level}-${Script[eq2bot].Variable[StartLevel]})*100))/(((${Time.Timestamp}+1)-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetInt[StartTime]})/3600)].Precision[2]} / hr)]
		else
			GainedXPString:Set[Gained APExp:  ${Math.Calc[(${Me.APExp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100)].Precision[1]} ( ${Math.Calc[((${Me.APExp}-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetFloat[StartAPXP]})+((${Me.TotalEarnedAPs}-${Script[eq2bot].Variable[StartAP]})*100))/(((${Time.Timestamp}+1)-${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings].GetInt[StartTime]})/3600)].Precision[2]} / hr)]
		;;;
		;;;;;;;;;;;;;;;;;

		if ${EQ2.Zoning}
		{
			KillTarget:Set[]
			do
			{
				wait 10
			}
			while ${EQ2.Zoning}

			wait 20
			if ${AutoFollowingMA(exists)}
				AutoFollowingMA:Set[FALSE]
		}

		if !${StartBot}
		{
			KillTarget:Set[]
			do
			{
				wait 10
			}
			while !${StartBot}
		}

		if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
		{
			if ${Math.Calc64[${Time.Timestamp}-${mstimer}]}>70
			{
				Me.Inventory[ExactName,ManaStone]:Use
				mstimer:Set[${Time.Timestamp}]
			}
		}

		;;;;;;;;;;;;;;
		;;; Pre-Combat Routines Loop (ie, Buff Routine, etc.)
		;;;;;;;;;;;;;;
		gRtnCtr:Set[1]
		do
		{
			;echo "Pre-Combat Routines Loop: Test - ${gRtnCtr}"

			; For dungeon crawl and not pulling, then follow the nav path instead of using follow.
			if ${PathType}==3 && !${AutoPull}
			{
				if ${Actor[ExactName,${MainAssist}](exists)}
				{
					target ${Actor[ExactName,${MainAssist}]}
					wait 10 ${Target.ID}==${Actor[ExactName,${MainAssist}].ID}
				}

				; Need to make sure we are close to the puller. Assume Puller is Main Tank for Dungeon Crawl.
				if !${Me.TargetLOS} && ${Target.Distance}>10
					call MovetoMaster
				elseif ${Target.Distance}>10
					call FastMove ${Actor[ExactName,${MainAssist}].X} ${Actor[ExactName,${MainAssist}].Z} ${Math.Rand[3]:Inc[3]}
			}

			if !${MainTank}
			{
				if (${Actor[ExactName,${MainAssist}].Target.Type.Equal[NPC]} || ${Actor[ExactName,${MainAssist}].Target.Type.Equal[NamedNPC]}) && ${Actor[ExactName,${MainAssist}].Target.InCombatMode}
					KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]

				; Add additional check to see if Mob is in Camp (assume radius of 25) OR MainTank is within designated range
				if ${KillTarget}
				{
					if ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead}
					{
						if (${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead})
						{
							if (${Mob.Detect} || ${Actor[ExactName,${MainAssist}].Distance}<${MARange})
							{
								if ${Mob.Target[${KillTarget}]}
									call Combat
							}
							;else
								;echo "DEBUG: if ({Mob.Detect} || {Actor[ExactName,{MainAssist}].Distance}<{MARange})"
						}
						;else
							;echo "DEBUG: if ({Actor[{KillTarget}].Health}<={AssistHP} && !{Actor[{KillTarget}].IsDead})"
					}
					else
						KillTarget:Set[0]
				}
			}

			;; This used to be duplicated in Combat(); however, now it just appears here (as I think it should be)
			if ${PathType}==4 && ${MainTank}
			{
				if ${Me.InCombat} && ${Mob.Detect}
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
						variable int AggroMob
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

			if !${MobDetected} || (${MainTank} && ${Me.GroupCount}!=1) || ${KillTarget}
			{
				if ${KillTarget} && ${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead} && ${Actor[${KillTarget},radius,35](exists)}
				{
					if ${Mob.Target[${KillTarget}]}
					{
						gRtnCtr:Set[40]
						if !${Me.InCombat}
								CurrentAction:Set["Idle..."]
						break
					}
				}

				;;;;;;;;;
				;;;;; Call the buff routine from the class file
				;;;;;;;;;
				call Buff_Routine ${gRtnCtr}
				if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
				{
					; end after this round
					gRtnCtr:Set[40]
					if !${Me.InCombat}
						CurrentAction:Set["Idle..."]
					break
				}

				;disable autoattack if not in combat
				if (${Me.AutoAttackOn} && !${Mob.Detect})
					EQ2Execute /toggleautoattack
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
					if ${KillTarget} && ${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead} && ${Actor[${KillTarget},radius,35](exists)}
					{
						if ${Mob.Target[${KillTarget}]}
						{
							gRtnCtr:Set[40]
							if !${Me.InCombat}
								CurrentAction:Set["Idle..."]
							break
						}
					}

					call Custom__Buff_Routine ${gRtnCtr}

					if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
					{
						gRtnCtr:Set[40]
						if !${Me.InCombat}
							CurrentAction:Set["Idle..."]
						break
					}
				}
				while ${gRtnCtr:Inc} <= 40
			}
		}
		;;;;;;;;;;;;;;
		;;; END Pre-Combat Routines Loop (ie, Buff Routine, etc.)
		;;;;;;;;;;;;;;


		if ${AutoLoot}
			call CheckLoot

		if ${AutoPull} && !${Me.InCombat}
		{
			;echo "AutoPull Loop: Test-${Time.Timestamp}"
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

			if ${Mob.Detect} || ${Me.Ability[${PullSpell}].IsReady} || ${PullType.Equal[Pet Pull]} || ${PullType.Equal[Bow Pull]}
			{
				if (${Me.ToActor.Power}>=${PowerCheck} && ${Me.ToActor.Health}>=${HealthCheck})
				{
					if ${PathType}==4 && !${Me.InCombat}
					{
						if ${EQ2Bot.PriestPower}
						{
							call Pull any
							if ${engagetarget}
							{
								wait 10
								if ${Mob.Target[${Target.ID}]}
								{
									;echo "DEBUG:: Calling Combat(1) within AutoPull Loop: Test-${Time.Timestamp}"
									call Combat
									;echo "DEBUG:: Ending Combat(1) within AutoPull Loop: Test-${Time.Timestamp}"
								}
							}
						}
					}
					else
					{
						if ${Mob.Target[${Target.ID}]} && !${Target.IsDead} && ${Target.InCombatMode} && ${Target.Distance}<8
						{
							;echo "Calling Combat(2) within AutoPull Loop: Test-${Time.Timestamp}"
							call Combat
						}
						else
						{
							variable int AggroNPC
							AggroNPC:Set[${Mob.NearestAggro}]
							if ${AggroNPC} > 0
							{
								if ${Mob.ValidActor[${AggroNPC}]}
								{
									target ${AggroNPC}
									;echo "Calling Combat(3) within AutoPull Loop: Test-${Time.Timestamp}"
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
										;echo "Calling Combat(4) within AutoPull Loop: Test-${Time.Timestamp}"
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
								;echo "Calling Combat(5) within AutoPull Loop: Test-${Time.Timestamp}"
								call Combat
							}
						}
					}
				}
			}
		;echo "END AutoPull Loop: Test-${Time.Timestamp}"
		}
		call ProcessTriggers

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
					variable int AgressiveNPC
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
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		; Check if we have leveled and reset XP Calculations in UI
		if ${Me.Level} < 80
		{
			if ${Me.Level} > ${StartLevel} && !${CloseUI}
			{
				SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartXP",${Me.Exp}]:Save
				SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartTime",${Time.Timestamp}]:Save
			}
		}
		else
		{
			if ${Me.TotalEarnedAPs} > ${StartAP} && !${CloseUI}
			{
				SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartAPXP",${Me.APExp}]:Save
				SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartTime",${Time.Timestamp}]:Save
			}
		}

		; Check if we have leveled and reload spells
		if ${Me.Level}>${StartLevel} && ${Me.Level}<80
		{
			EQ2Bot:Init_Config
			call Buff_Init
			call Combat_Init
			call PostCombat_Init
			StartLevel:Set[${Me.Level}]
		}

		if (${Actor[ExactName,${MainAssist}].IsDead} && !${MainTank}) || (${MainAssist.NotEqual[${OriginalMA}]} && ${Actor[exactname,${OriginalMA}].IsDead})
			EQ2Bot:MainAssist_Dead

		if (${Actor[exactname,${MainTankPC}].IsDead} && !${MainTank}) || (${MainTankPC.NotEqual[${OriginalMT}]} && ${Actor[exactname,${OriginalMT}].IsDead})
			EQ2Bot:MainTank_Dead

		call ProcessTriggers
	}
	while ${CurrentTask}
}

function CheckManaStone()
{
	variable int tempvar
	Me.Equipment[Exactname,"Manastone"]:UnEquip

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

function CastSpellRange(int start, int finish, int xvar1, int xvar2, int TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained)
{
	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;

	variable bool fndspell
	variable int tempvar=${start}
	variable int originaltarget

	;echo "DEBUG: CastSpellRange(${tempvar}::${SpellType[${tempvar}]})"

	if !${Me.InCombat}
	{
		call AmIInvis "CastSpellRange()"
		if ${Return.Equal[TRUE]}
			return -1
	}

	if ${Me.IsMoving} && !${castwhilemoving}
		return -1

	if ${TargetID}>0 && !${Actor[id,${TargetID}](exists)}
		return -1

	do
	{
		if ${SpellType[${tempvar}].Length}
		{
			if ${Me.Ability[${SpellType[${tempvar}]}].IsReady}
			{
				if ${TargetID}
				{
					fndspell:Set[FALSE]
					if !${IgnoreMaintained}
					{
						tempgrp:Set[1]
						do
						{
							if ${Me.Maintained[${tempgrp}].Name.Equal[${SpellType[${tempvar}]}]} && ${Me.Maintained[${tempgrp}].Target.ID}==${TargetID} && (${Me.Maintained[${tempgrp}].Duration}>${refreshtimer} || ${Me.Maintained[${tempgrp}].Duration}==-1)
							{
								fndspell:Set[TRUE]
								break
							}
						}
						while ${tempgrp:Inc}<=${Me.CountMaintained}
					}

					if !${fndspell}
					{
						if !${Actor[${TargetID}](exists)}
								return -1

						if ${Actor[${TargetID}].Distance}>35
								return -1

						if ${xvar1} || ${xvar2}
							call CheckPosition ${xvar1} ${xvar2}

						if ${Target(exists)}
							originaltarget:Set[${Target.ID}]

						if ${TargetID} > 0
						{
							if !(${TargetID}==${Target.ID}) && !(${TargetID}==${Target.Target.ID} && ${Target.Type.Equal[NPC]})
							{
								if ${Actor[id,${TargetID}](exists)}
								{
									target ${TargetID}
									wait 10 ${Target.ID}==${TargetID}
								}
							}
						}

						call CastSpell "${SpellType[${tempvar}]}" ${tempvar} ${castwhilemoving}

						if ${Actor[${originaltarget}](exists)}
						{
							target ${originaltarget}
							wait 10 ${Target.ID}==${originaltarget}
						}

						if ${notall}==1
						{
							return -1
						}
					}
				}
				else
				{
					if !${Me.Maintained[${SpellType[${tempvar}]}](exists)} || (${Me.Maintained[${SpellType[${tempvar}]}].Duration}<${refreshtimer} && ${Me.Maintained[${SpellType[${tempvar}]}].Duration}!=-1)
					{
						if ${xvar1} || ${xvar2}
						{
							call CheckPosition ${xvar1} ${xvar2}
						}

						call CastSpell "${SpellType[${tempvar}]}" ${tempvar} ${castwhilemoving}

						if ${notall}==1
						{
							return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
						}
					}
				}
			}
		}

		if !${finish}
		{
			return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
		}
	}
	while ${tempvar:Inc}<=${finish}

	return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
}

function CastSpell(string spell, int spellid, bool castwhilemoving)
{
	if !${Me.InCombat}
	{
		call AmIInvis "CastSpell()"
		if ${Return.Equal[TRUE]}
			return
	}

	if ${Me.IsMoving} && !${castwhilemoving}
		return

	CurrentAction:Set[Casting '${spell}']

	;; Disallow some abilities that are named the same as crafting abilities.
	;; 1. Agitate (CraftingID: 601887089 -- Fury Spell ID: 1287322154)
	if (${Me.Ability[${spell}].ID} == 601887089)
		Me.Ability[id,1287322154]:Use
	else
		Me.Ability[${spell}]:Use

	; need a slight weight here for Me.CastingSpell to initiate
	wait 1

	if !${castwhilemoving}
	{
		;if spells are being interupted do to movement
		;increase the wait below slightly. Default=2
		wait 5
	}

	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	return SUCCESS
}

function Combat()
{
	variable int tempvar
	variable bool ContinueCombat

	movinghome:Set[FALSE]
	avoidhate:Set[FALSE]

	if !${Actor[${KillTarget}](exists)}
		return

	FollowTask:Set[2]
	; Make sure we are still not moving when we enter combat
	if ${Me.IsMoving}
	{
		press -release ${forward}
		press -release ${backward}
		wait 20 !${Me.IsMoving}
	}

	if !${Target(exists)}
	{
		target ${KillTarget}
		wait 2
		if !${Target(exists)}
			return
	}

	if ${Target.ID}!=${Me.ID} && ${Target(exists)}
		face ${Target.X} ${Target.Z}

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
			if !${Target(exists)}
			{
				target ${KillTarget}
				wait 1
				face ${Target.X} ${Target.Z}
			}
			elseif ${Target.ID}!=${Me.ID}
				face ${Target.X} ${Target.Z}
		}

		if !${Target(exists)} || !${Actor[${KillTarget}](exists)}
			break

		do
		{
			;these checks should be done before calling combat, once called, combat should insue, regardless.
			if !${Actor[${Target.ID}].InCombatMode}
				break

			while ${Actor[${KillTarget}].Distance} > ${MARange}
			{
				wait 5
				if !${Target(exists)} || !${Actor[${KillTarget}](exists)}
						break
				call ProcessTriggers
			}

			if !${Target(exists)} || !${Actor[${KillTarget}](exists)}
				break

			;face ${Target.X} ${Target.Y} ${Target.Z}

			if (${Mob.ValidActor[${KillTarget}]})
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

						if ${Target.Target.ID}==${Me.ID}
							call CheckMTAggro
						else
						{
							call Lost_Aggro ${Target.ID}
							if ${UseCustomRoutines}
								call Custom__Lost_Aggro ${Target.ID}
						}
					}
					else
					{
						Mob:CheckMYAggro

						if ${Actor[ExactName,${MainAssist}].IsDead}
						{
							EQ2Bot:MainAssist_Dead
							break
						}

						if ${Actor[exactname,${MainTankPC}].IsDead}
						{
							EQ2Bot:MainTank_Dead
							break
						}
					}

					if ${haveaggro} && !${MainTank} && ${Actor[${aggroid}].Name(exists)}
					{
						call Have_Aggro
						if ${UseCustomRoutines}
						call Custom__Have_Aggro
					}

					do
					{
						waitframe
					}
					while ${MainTank} && ${Target.Target.ID} == ${Me.ID} && ${Target.Distance} > ${MARange}

					call Combat_Routine ${gRtnCtr}
					if ${Return.Equal[CombatComplete]}
					{
						if !${Me.InCombat}
							CurrentAction:Set["Idle..."]
						gRtnCtr:Set[40]
					}

					if !${Me.AutoAttackOn} && ${AutoMelee}
						EQ2Execute /toggleautoattack

					if ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
					{
						EQ2Execute /target_none
						break
					}

					if ${AutoMelee} && !${MainTank}
					{
						;check valid rear position
						if ((${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>-65 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<65) || (${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>305 || ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<-305)) && ${Actor[${KillTarget}].Distance}<6
						{
							;we're behind and in range
						}
						;check right flank
						elseif ((${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>-295)) && ${Actor[${KillTarget}].Distance}<6
						{
							;we're right flank and in range
						}
						;check left flank
						elseif ((${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Actor[${KillTarget}].Heading}-${Me.Heading}]}<295)) && ${Actor[${KillTarget}].Distance}<6
						{
							;we're left flank and in range
						}
						elseif ${Actor[${KillTarget}].Target.ID}==${Me.ID}
						{
							;we have aggro, move to the maintank
							call FastMove ${Actor[exactname,${MainTankPC}].X} ${Actor[exactname,${MainTankPC}].Z} 1
							do
							{
								waitframe
							}
							while (${IsMoving} || ${Me.IsMoving})
						}
						else
						{
							call CheckPosition 1 ${Target.IsEpic}
						}
					}
					elseif ${Actor[${KillTarget}].Distance}>40 || ${Actor[exactname,${MainTankPC}].Distance}>40
					{
						call FastMove ${Actor[exactname,${MainTankPC}].X} ${Actor[exactname,${MainTankPC}].Z} 25
						do
						{
							waitframe
						}
						while (${IsMoving} || ${Me.IsMoving})
					}

					if ${Me.ToActor.Power}<55 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
					{
						if ${Math.Calc64[${Time.Timestamp}-${mstimer}]}>70
						{
							Me.Inventory[ExactName,ManaStone]:Use
							mstimer:Set[${Time.Timestamp}]
						}
					}

					if ${AutoSwitch} && !${MainTank} && ${Actor[${KillTarget}].Health}>30 && (${Actor[ExactName,${MainAssist}].Target.Type.Equal[NPC]} || ${Actor[ExactName,${MainAssist}].Target.Type.Equal[NamedNPC]}) && ${Actor[ExactName,${MainAssist}].Target.InCombatMode}
					{
						variable int ActorID
						ActorID:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
						if ${Mob.ValidActor[${ActorID}]}
						{
							KillTarget:Set[${ActorID}]
							target ${KillTarget}
							call ProcessTriggers
						}
					}
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
						{
							call Lost_Aggro ${Target.ID}
							if ${UseCustomRoutines}
							call Custom__Lost_Aggro ${Target.ID}
						}
					}
					else
					{
						Mob:CheckMYAggro

						if ${Actor[ExactName,${MainAssist}].IsDead}
						{
							EQ2Bot:MainAssist_Dead
							break
						}

						if ${Actor[exactname,${MainTankPC}].IsDead}
						{
							EQ2Bot:MainTank_Dead
							break
						}
					}

					call Custom__Combat_Routine ${gRtnCtr}
					if ${Return.Equal[CombatComplete]}
					{
						if !${Me.InCombat}
							CurrentAction:Set["Idle..."]
						gRtnCtr:Set[40]
					}

					if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
					{
						if ${Math.Calc64[${Time.Timestamp}-${mstimer}]}>70
						{
							Me.Inventory[ExactName,ManaStone]:Use
							mstimer:Set[${Time.Timestamp}]
						}
					}

					if ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
					{
						EQ2Execute /target_none
						break
					}

					if ${AutoSwitch} && !${MainTank} && ${Target.Health}>30 && (${Actor[ExactName,${MainAssist}].Target.Type.Equal[NPC]} || ${Actor[ExactName,${MainAssist}].Target.Type.Equal[NamedNPC]}) && ${Actor[ExactName,${MainAssist}].Target.InCombatMode}
					{
						ActorID:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
						if ${Mob.ValidActor[${ActorID}]}
						{
							KillTarget:Set[${ActorID}]
							target ${KillTarget}
							call ProcessTriggers
						}
					}
				}
				while ${gRtnCtr:Inc}<=40 && ${Mob.ValidActor[${KillTarget}]}
			}
			;;;; END Combat_Routine Loop ;;;;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			if !${CurrentTask}
				Script:End

			if (${Actor[${KillTarget}].IsDead} && !${MainTank}) || (${Target.IsDead} && ${MainTank} && (${Actor[${KillTarget}].Type.Equal[NPC]} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].Type.Equal[Corpse]}))
				break

			call ProcessTriggers
		}
		while ((${Actor[${KillTarget}](exists)} && !${MainTank}) || (${Target(exists)} && ${MainTank})) && !${Actor[${KillTarget}].IsDead} && ${Mob.ValidActor[${KillTarget}]}
		;;; END LOOP DEALING WITH CURRENT TARGET ;;;;;;

		disablebehind:Set[FALSE]
		disablefront:Set[FALSE]

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; Target New Mob (if applicable)
		;;
		if !${MainTank} && ${Actor[ExactName,${MainAssist}](exists)}
		{
			if ${Mob.Detect}
				wait 50 ${Actor[ExactName,${MainAssist}].Target(exists)}

			if ${Actor[ExactName,${MainAssist}].Target(exists)} && ${Mob.ValidActor[${Actor[ExactName,${MainAssist}].Target.ID}]}
			{
				KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
				Actor[${KillTarget}]:DoTarget
				Actor[${KillTarget}]:DoFace
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
				variable int AggroMob
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
		;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	}
	while ${Me.InCombat} || ${ContinueCombat}

	UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Hide

	avoidhate:Set[FALSE]
	checkadds:Set[FALSE]

	gRtnCtr:Set[1]
	do
	{
		call Post_Combat_Routine ${gRtnCtr}
		if ${Return.Equal[PostCombatRoutineComplete]}
		{
			if !${Me.InCombat}
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
				if !${Me.InCombat}
					CurrentAction:Set["Idle..."]
				gRtnCtr:Set[20]
			}
		}
		while ${gRtnCtr:Inc}<=20
	}

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack


	if ${AutoLoot} && ${Me.ToActor.Health} >= (${HealthCheck}-10)
	{
		;echo "DEBUG: Calling CheckLootNoMove()"
		call CheckLootNoMove
	}

	if ${PathType}==1
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

	if ${MainAssist.NotEqual[${OriginalMA}]} && !${MainTank}
		EQ2Bot:MainAssist_Dead

	if ${MainTankPC.NotEqual[${OriginalMT}]} && !${MainTank}
		EQ2Bot:MainTank_Dead

	if ${PathType}==4
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

function GetBehind()
{
	variable float X
	variable float Z

	X:Set[${Math.Calc[-4*${Math.Sin[-${Target.Heading}]}+${Target.X}]}]
	Z:Set[${Math.Calc[4*${Math.Cos[-${Target.Heading}]}+${Target.Z}]}]

	call FastMove ${X} ${Z} 4
	if ${Return.Equal[STUCK]}
	{
		disablebehind:Set[TRUE]
		call FastMove ${Target.X} ${Target.Z} 6
	}

	if ${Target(exists)} && (${Target.ID}!=${Me.ID})
		face ${Target.X} ${Target.Z}

}

function GetToFlank(int extended)
{
	variable float X
	variable float Z
	variable int tempdir

	if ${direction}
	{
		tempdir:Set[-3]
		if ${extended}
		{
			tempdir:Dec[3]
		}
	}
	else
	{
		tempdir:Set[3]
		if ${extended}
		{
			tempdir:Inc[3]
		}
	}

	X:Set[${Math.Calc[${tempdir}*${Math.Cos[-${Target.Heading}]}+${Target.X}]}]
	Z:Set[${Math.Calc[${tempdir}*${Math.Sin[-${Target.Heading}]}+${Target.Z}]}]

	call FastMove ${X} ${Z} 3
	if ${Return.Equal[STUCK]}
	{
		disablebehind:Set[TRUE]
		call FastMove ${Target.X} ${Target.Z} 5
	}

	if ${Target(exists)} && (${Target.ID}!=${Me.ID})
		face ${Target.X} ${Target.Z}
}

function GetinFront()
{
	variable float X
	variable float Z

	X:Set[${Math.Calc[-3*${Math.Sin[${Target.Heading}]}+${Target.X}]}]
	Z:Set[${Math.Calc[-3*${Math.Cos[${Target.Heading}]}+${Target.Z}]}]

	call FastMove ${X} ${Z} 3
	if ${Return.Equal[STUCK]}
	{
		disablefront:Set[TRUE]
		call FastMove ${Target.X} ${Target.Z} 5
	}

	if ${Target(exists)} && (${Target.ID}!=${Me.ID})
		face ${Target.X} ${Target.Z}

	;removing cause this seems stupid
	;wait 4
}


function CheckPosition(int rangetype, int position)
{
	; rangetype (1=close, 2=max range, 3=bow shooting)
	; position (0=anywhere, 1=behind, 2=front, 3=flank)

	variable float minrange
	variable float maxrange

	if !${Target(exists)} || ${NoMovement}
		return

	switch ${rangetype}
	{
		case NULL
		case 0
			if ${AutoMelee}
			{
				minrange:Set[0]
				maxrange:Set[3]
			}
			else
			{
				minrange:Set[0]
				maxrange:Set[35]
			}
			break
		case 1
			minrange:Set[1]
			maxrange:Set[3]
			break
		case 2
			if ${AutoMelee}
			{
				minrange:Set[0]
				maxrange:Set[3]
			}
			else
			{
				minrange:Set[0]
				maxrange:Set[35]
			}
			break
		case 3
			minrange:Set[5.5]
			if ${Me.Equipment[Ranged].Type.Equal[Weapon]}
				maxrange:Set[${Me.Equipment[Ranged].Range}]
			else
				maxrange:Set[35]
			break
	}

	if ${Target.Target.ID}==${Me.ID} && ${AutoMelee}
	{
		minrange:Set[0]
		maxrange:Set[4]
	}

	if ${haveaggro}
		position:Set[2]

	if ${disablebehind} && (${position}==1 || ${position}==3)
		position:Set[0]

	if !${MainTank}
	{
		;I don't think this is a good idea.  We're ignoring position checks when people get knocked back... Changing from 8 to MARange
		;it is also not good with new mob AI's that 'range' fight.
		if ${Math.Distance[${Actor[ExactName,${MainAssist}].X},${Actor[ExactName,${MainAssist}].Z},${Target.X},${Target.Z}]}>${MARange}
			return
	}
	elseif ${PathType}==2
	{
		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}<8 && ${Me.InCombat} && !${lostaggro} && ${Target.Distance}>10
			return

		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>5 && ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}<10 && ${Me.InCombat} && !${lostaggro}
		{
			call FastMove ${HomeX} ${HomeZ} 3
			return
		}
	}

	if ${Target.Distance}>${maxrange} && ${Target.Distance}<45 && ${PathType}!=2 && !${isstuck}
	{
		if ${Target(exists)} && (${Me.ID}!=${Target.ID})
			face ${Target.X} ${Target.Z}

		call FastMove ${Target.X} ${Target.Z} ${maxrange}
	}

	if ${Target.Distance}<${minrange} && ${Target(exists)} && (${Me.ID}!=${Target.ID}) && (${rangetype}==1 || ${rangetype}==3)
	{
		movetimer:Set[${Time.Timestamp}]
		press -release ${forward}
		wait 1
		press -hold ${backward}

		do
		{
			if ${Target(exists)} && (${Me.ID}!=${Target.ID})
				face ${Target.X} ${Target.Z}

			if ${Math.Calc64[${Time.Timestamp}-${movetimer}]}>2
			{
				isstuck:Set[TRUE]
				break
			}
		}
		while ${Target.Distance}<${minrange} && ${Target(exists)}

		press -release ${backward}
		wait 20 !${Me.IsMoving}
	}

	if ${AutoMelee} && ${Target.Distance}>4.5 && (${Me.ID}!=${Target.ID})
	{
		call FastMove ${Target.X} ${Target.Z} 3

		if ${Target(exists)} && (${Me.ID}!=${Target.ID})
			face ${Target.X} ${Target.Z}
	}

	if ${position}
	{
		switch ${position}
		{
			case 1
				; Behind arc is 60 degree arc. Using 50 degree arc to allow for error
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
					return
				else
					call GetBehind
				break
			case 2

				; Frontal Arc is 120 degree arc. Using 110 to allow for error
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>125 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<235) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-235 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-125)
					return
				else
					call GetinFront
				break
			case 3
				; Using 80 degree flank arc between front and rear arcs with 5 degree error on front and back of the arc
				;check if we are on the left flank
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
					return

				;check if we are at the right flank
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
					return

				;note parameter for GetToflank is null for right, 1 for left

				;check if we are on the left side of the mob, if so move to the left flank
				if ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-180 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<0
					call GetToFlank 1
				else
				{
					; we must be on the right side of the mob so move to the right flank
					call GetToFlank
				}
				break
			case default
				break
		}
	}
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
				;echo "DEBUG: Not Casting Spell due to my health being too low!"
				return "FAIL"
			}
			break
	}
}

function Pull(string npcclass)
{
	variable int tcount=2
	variable int tempvar
	variable bool aggrogrp=FALSE
	variable int ThisActorID
	variable int ThisActorTargetID
	variable bool bContinue=FALSE

	;; This variable must be set before anything is done in this function
	engagetarget:Set[FALSE]

	if !${AutoPull}
		return 0

	;; If we are already in combat...why are we pulling? Cause sometimes we pull nearest mob when group member enters combat?
	if (${Me.InCombat})
		return 0

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
			echo "DEBUG: Clearing TempDoNotPullList (5 minute mark)"
			TempDoNotPullList:Clear
		}
	}

	EQ2:CreateCustomActorArray[byDist,${ScanRange}]
	do
	{
		ThisActorID:Set[${CustomActor[${tcount}].ID}]
		ThisActorTargetID:Set[${CustomActor[${tcount}].Target.ID}]

		if (${TempDoNotPullList.Element[${ThisActorID}](exists)} && ${Actor[${ThisActorID}].Target.ID}!=${Me.ID})
		{
			;echo "DEBUG: Actor (ID: ${actorid}) is in the TempDoNotPullList -- skipping..."
			continue
		}

		if (${IgnoreHeroic} && !${CustomActor[${tcount}].IsSolo})
			continue

		if (${DoNotPullList.Element[${ThisActorID}](exists)})
		{
			echo "DEBUG: ${CustomActor[${tcount}]} (ID: ${ThisActorID}) is in the DoNotPullList -- skipping..."
			continue
		}

		if ${Mob.ValidActor[${ThisActorID}]}
		{
			if ${Mob.AggroGroup[${ThisActorID}]}
				aggrogrp:Set[TRUE]

			if !${CustomActor[${tcount}].IsAggro}
			{
				if !${aggrogrp} && ${ThisActorTargetID}!=${Me.ID} && !${Me.InCombat} && (${Me.ToActor.Power}<75 || ${Me.ToActor.Health}<90) && !${CustomActor[${tcount}].InCombatMode}
					continue

				if !${aggrogrp} && ${ThisActorTargetID}!=${Me.ID} && ${Me.InCombat} && !${CustomActor[${tcount}].InCombatMode}
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
			;echo "DEBUG: PathType: ${PathType} - PullRange: ${PullRange} - pulling: ${pulling} - ScanRange: ${ScanRange}"
			if (${PathType}==4)
			{
				if (${PullType.Equal[Spell or CA Pull]})
				{
					if ${Target.Distance} > ${Math.Calc[${Me.Ability[${PullSpell}].Range}-4]}
					{
						;echo "DEBUG: Moving within range for your pull spell or combat art..."
						call FastMove ${Target.X} ${Target.Z} ${Math.Calc[${Me.Ability[${PullSpell}].Range}-4]}
					}
					;; Check again....stupid moving mobs...
					if ${Target.Distance} > ${Me.Ability[${PullSpell}].Range}
					{
						;echo "DEBUG: Moving within range for your pull spell or combat art..."
						call FastMove ${Target.X} ${Target.Z} ${Math.Calc[${Me.Ability[${PullSpell}].Range}-2]}
					}
				}
				elseif (${PullType.Equal[Bow Pull]})
				{
					if ${Target.Distance} > ${Me.Equipment[ranged].Range}
					{
						;echo "DEBUG: Moving within range for your bow..."
						call FastMove ${Target.X} ${Target.Z} ${Me.Equipment[ranged].Range}
					}
				}
			}
			if ((${PathType}==2 || ${PathType}==3 && ${pulling}) || ${PathType}==4) && ${Target.Distance}>${PullRange} && ${Target.Distance}<${ScanRange}
			{
				;echo "DEBUG: Moving within Range..."
				call FastMove ${Target.X} ${Target.Z} ${PullRange}
			}
			elseif ${PathType}==1 && ${Target.Distance}>${PullRange} && ${Target.Distance}<${ScanRange}
			{
				;echo "DEBUG: Moving within Range..."
				call FastMove ${Target.X} ${Target.Z} ${PullRange}
			}

			wait 2

			if (${PathType} > 0 && !${PullType.Equal[Pet Pull]})
			{
				CurrentAction:Set["Checking LOS/Collision..."]
				;echo "DEUBG: Checking LOS/Collision"
				if ${Target.CheckCollision}
				{
					if (!${Me.TargetLOS})
					{
						;; try strafing a bit to see if can get no collision/LOS
						press -hold MOVEBACKWARD
						wait 4
						press -release MOVEBACKWARD
						waitframe
						press -hold STRAFELEFT
						wait 10
						press -release STRAFELEFT
						waitframe
						if !${Me.TargetLOS} && ${Target.CheckCollision}
						{
							press -hold STRAFERIGHT
							wait 20
							press -release STRAFERIGHT
							waitframe
							if !${Me.TargetLOS} && ${Target.CheckCollision}
							{
								press -hold STRAFELEFT
								wait 10
								press -release STRAFELEFT
								waitframe
								if !${Me.TargetLOS} && ${Target.CheckCollision}
								{
									echo "DEBUG: Adding (${Target.ID},${Target.Name}) to the TempDoNotPullList (unabled to attack it - No LOS or Collision Detected)"
									TempDoNotPullList:Set[${Target.ID},${Target.Name}]

									echo "DEBUG: TempDoNotPullList now has ${TempDoNotPullList.Used} actors in it."
									continue
								}
							}
						}
					}
				}
			}

			if ${Me.IsMoving}
			{
				press -release ${forward}
				wait 20 !${Me.IsMoving}
			}

			;echo "DEUBG: Pulling! (PullType: ${PullType})"
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
						if ${Me.InCombat}
							EQ2Execute /togglerangedattack
						continue
					}
				}

				if ${Me.InCombat}
					EQ2Execute /togglerangedattack

				continue
			}
			elseif ${PullType.Equal[Pet Pull]}
			{
				CurrentAction:Set[Pulling ${Target} (with pet)]
				variable int AggroMob

				;; This should not happen...but just in case
				if !${Target(exists)}
						continue

				EQ2Execute /pet attack
				WaitFor "You may not order your pet to attack the selected or implied target." 30

				if "${WaitFor}==1"
				{
					echo "EQ2Bot-Pull():: Not allowed to use pet to attack this target"
					wait 1
					echo "DEBUG: Adding (${Target.ID},${Target.Name}) to the TempDoNotPullList (unabled to attack it - No LOS or Collision Detected)"
					TempDoNotPullList:Set[${Target.ID},${Target.Name}]

					echo "DEBUG: TempDoNotPullList now has ${TempDoNotPullList.Used} actors in it."
					eq2execute /pet backoff
					eq2execute target_none
					continue
				}
				else
				{
					face
					CurrentAction:Set[Sending Pet in for attack...]
					;echo "EQ2Bot-Pull():: Sending Pet in for attack..."
					variable int StartTime = ${Script.RunningTime}
					do
					{
						if (${Math.Calc64[${Script.RunningTime}-${StartTime}]} >= 20000)
						{
							echo "EQ2Bot-Pull():: Pet did not finish a pull within 20 seconds....moving on."
							eq2execute /pet backoff
							wait 1
							echo "DEBUG: Adding (${Target.ID},${Target.Name}) to the TempDoNotPullList (Timeout while pulling)"
							TempDoNotPullList:Set[${Target.ID},${Target.Name}]

							echo "DEBUG: TempDoNotPullList now has ${TempDoNotPullList.Used} actors in it."
							eq2execute target_none
							bContinue:Set[TRUE]
							CurrentAction:Set["Timeout while pulling -- moving on..."]
							break
						}
						Wait 5
						CurrentAction:Set["Waiting for Pet (${Me.Pet.Distance.Precision[1]}m)"]
						;echo "EQ2Bot-Pull():: Waiting for Pet (${Me.Pet.Distance.Precision[1]}m)"

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
										face
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
						;echo "EQ2Bot-Pull():: Waiting for ${Target} (${Target.Distance.Precision[1]}m)"

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
										face
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
						face
						wait 1
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

			call CastSpell "${PullSpell}"
			CurrentAction:Set["${Target} pulled using ${PullSpell}"]
			;echo "DEBUG: Pulled...waiting for mob to come within range"
			do
			{
				waitframe
			}
			while ${Target.Distance}>${MARange} && ${Target.Target.ID}==${Me.ID}

			if ${Target.Distance} > 5 && !${pulling} && ${PathType}!=2
			{
				if ${AutoMelee}
					call FastMove ${Target.X} ${Target.Z} 5
				elseif ${Target.Distance} > ${MARange}
					call FastMove ${Target.X} ${Target.Z} ${MARange}
			}

			if ${Target(exists)} && !${pulling} && (${Me.ID}!=${Target.ID})
				face ${Target.X} ${Target.Z}
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

	if (!${AutoLoot})
		return

	EQ2:CreateCustomActorArray[byDist,9]

	do
	{
		;Check if already looted
		if (${ActorsLooted.Element[${CustomActor[${tcount}].ID}](exists)})
		{
			;echo "Sorry, I've already looted this actor... (${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name})"
			continue
		}

		if ${CustomActor[${tcount}].Type.Equal[chest]}
		{
			Echo "DEBUG: Looting ${CustomActor[${tcount}].Name} (Chest) [CheckLootNoMove()] -- Distance: ${CustomActor[${tcount}].Distance}"
			if (${CustomActor[${tcount}].Distance} > 4)
				continue

			switch ${Me.SubClass}
			{
				case dirge
				case troubador
				case swashbuckler
				case brigand
				case ranger
				case assassin
					;Echo "DEBUG: disarming trap on ${CustomActor[${tcount}].ID}"
					EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} disarm"
					wait 2
					break
				case default
					break
			}
			Actor[Chest]:DoubleClick
			EQ2Bot:SetActorLooted[${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name}]
			wait 1
			call ProcessTriggers
		}
		elseif ${CustomActor[${tcount}].Type.Equal[Corpse]}
		{
			CurrentAction:Set["Looting ${Actor[corpse].Name} (Corpse)"]
			echo "DEBUG: Looting ${Actor[corpse].Name} (Corpse) [CheckLootNoMove()]"
			EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} loot"
			EQ2Bot:SetActorLooted[${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name}]
			wait 1
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

	if (!${AutoLoot})
		return

	islooting:Set[TRUE]
	;think this is legacy, removing
	;wait 10
	EQ2:CreateCustomActorArray[byDist,25]

	do
	{
		;Check if already looted
		if (${ActorsLooted.Element[${CustomActor[${tcount}].ID}](exists)})
		{
			;echo "Sorry, I've already looted this actor... (${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name})"
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
					;echo "DEBUG: Stopping Autofollow..."
					EQ2Execute /stopfollow
					wait 2
				}
				;echo "DEBUG: Moving to ${CustomActor[${tcount}].X}, ${CustomActor[${tcount}].Z}  (Currently at ${Me.X}, ${Me.Z})"
				call FastMove ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 2
				;ECHO "DEBUG: FastMove() returned '${Return}'"
				wait 2
				do
				{
					waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
				;echo "DEBUG: Moving complete...now at ${Me.X}, ${Me.Z} (Distance to chest: ${CustomActor[${tcount}].Distance})"
			}
			switch ${Me.SubClass}
			{
				case dirge
				case troubador
				case swashbuckler
				case brigand
				case ranger
				case assassin
					;Echo "DEBUG: disarming trap on ${CustomActor[${tcount}].ID}"
					EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} disarm"
					wait 2
					break
				case default
					break
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
		elseif ${CustomActor[${tcount}].Type.Equal[Corpse]}
		{
			CurrentAction:Set["Looting ${Actor[corpse].Name} (Corpse)"]
			echo "DEBUG: Looting ${Actor[corpse].Name} (Corpse) [CheckLoot()]"
			if (${CustomActor[${tcount}].Distance} > 10)
			{
				if (${AutoFollowMode})
				{
					;echo "DEBUG: Stopping Autofollow..."
					EQ2Execute /stopfollow
					wait 2
				}
				call FastMove ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 8
				do
				{
					waitframe
				}
				while (${IsMoving} || ${Me.IsMoving})
			}
			EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} loot"
			EQ2Bot:SetActorLooted[${CustomActor[${tcount}].ID},${CustomActor[${tcount}].Name}]
			wait 2
			call ProcessTriggers
			if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
			{
				ExecuteAtom AutoFollowTank
				wait 1
			}
		}

		if !${CurrentTask}
			Script:End
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	islooting:Set[FALSE]
}

function FastMove(float X, float Z, int range)
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; NOTE -- If you are calling this you will need to ensure that the character is not using AutoFollowMode (and/or turn it off appropriately)
	;;;         otherwise this function will move you and then you will just richocet back
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; to Turn off autofollow:
	;;  if (${AutoFollowMode})
	;;  {
	;;      echo "DEBUG: Stopping Autofollow..."
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

	IsMoving:Set[TRUE]

	if !${Target(exists)} && !${islooting} && !${movingtowp} && !${movinghome} && ${Me.InCombat}
	{
		IsMoving:Set[FALSE]
		return "TARGETDEAD"
	}

	if ${NoMovement}
	{
		IsMoving:Set[FALSE]
		return "NOMOVEMENT"
	}

	if !${X} || !${Z}
	{
		IsMoving:Set[FALSE]
		return "INVALIDLOC"
	}

	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${ScanRange} && ${PathType}!=4
	{
		IsMoving:Set[FALSE]
		return "INVALIDLOC"
	}
	elseif ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>50 && ${PathType}!=4
	{
		IsMoving:Set[FALSE]
		return "INVALIDLOC"
	}

	face ${X} ${Z}

	if !${pulling}
	{
		press -release ${forward}
		wait 1
		press -hold ${forward}

		;echo "DEBUG: Moving....  (WhoFollowing: ${Me.ToActor.WhoFollowing})"
	}

	xTimer:Set[${Script.RunningTime}]
	;echo "DEBUG: xTimer set to ${xTimer}"

	do
	{
		xDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]

		if ${Math.Calc[${SavDist}-${xDist}]} < 0.8
		{
			if (${Script.RunningTime}-${xTimer}) > 500
			{
				;echo "DEBUG: Script.RunningTime (${Script.RunningTime}) - xTimer (${xTimer}) is greater than 500 -- returning STUCK  (WhoFollowing: ${Me.ToActor.WhoFollowing})"
				;echo "DEBUG: Using Math.Calc64 value is ${Math.Calc64[${Script.RunningTime}-${xTimer}]}"
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

		while ${PathIndex:Inc}<=${CurrentPath.Hops}
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
	if ${EQ2Nav.FindPath[${EQ2Nav.FindClosestRegion[${Actor[ExactName,${MainAssist}].X},${Actor[ExactName,${MainAssist}].Z},${Actor[ExactName,${MainAssist}].Y}].FQN}]}
	{
		CurrentAction:Set[Moving Closer to Main Aasist]
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

function ProcessTriggers()
{
	while ${QueuedCommands}
	{
		ExecuteQueued
	}
}

function IamDead(string Line)
{
	variable int deathtimer=${Time.Timestamp}
	KillTarget:Set[]
	grpcnt:Set[${Me.GroupCount}]
	tempgrp:Set[1]

	together:Set[1]

	CurrentAction:Set["You have been killed"]
	echo "You have been killed"

	if ${Me.GroupCount}==1 && ${WipeRevive}
	{
		echo no group, resetting
		EQ2Execute "select_junction 0"
		do
		{
			waitframe
		}
		while ${EQ2.Zoning}
		KillTarget:Set[]
		wait 300
	}
	elseif ${WipeRevive}
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
			while ${wipegroup:Inc}<${Me.GroupCount}

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
				while ${EQ2.Zoning}
				;KillTarget:Set[]
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
					while ${tempgrp:Inc}<${grpcnt}
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
	else
	{
		do
		{
			if ${Math.Calc64[${Time.Timestamp}-${deathtimer}]}>5000
				Exit
		}
		while ${Me.ToActor.Health}<1
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

	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[General Settings]:Set[LootMethod,Accept]:Save
	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[General Settings]:Set[Auto Loot Corpses and open Treasure Chests?,FALSE]:Save
}


function CheckMTAggro()
{
	variable int tcount=2
	variable int tempvar
	variable int newtarget

	; If PathType is 2 make sure we are not to far away from home point first
	if ${PathType}==2 && ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>8
	{
		call FastMove ${HomeX} ${HomeZ} 4
		if ${Target(exists)} && (${Me.ID}!=${Target.ID})
			face ${Target.X} ${Target.Z}
	}

	lostaggro:Set[FALSE]

	if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
		return "NOAGGRO"

	newtarget:Set[${Target.ID}]

	EQ2:CreateCustomActorArray[byDist,15]
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
		variable int tcount=2
	variable float X
	variable float Z

	EQ2:CreateCustomActorArray[byDist,20]
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
	if (${Text.Find[You may not order your pet to attack]} > 0)
	{
		;; Make sure the list does not get too big
		if (${DoNotPullList.Used} > 100)
		{
				;echo "DEBUG: DoNotPullList too big (${DoNotPullList.Used} elements) -- Clearing..."
				DoNotPullList:Clear
		}
		if ${Target.ID}
		{
			echo "DEBUG: Adding (${Target.ID},${Target.Name}) to the DoNotPullList (unabled to attack it)"
			DoNotPullList:Set[${Target.ID},${Target.Name}]

			echo "DEBUG: DoNotPullList now has ${DoNotPullList.Used} actors in it."
		}
	}
	elseif (${Text.Find[This attack cannot be used on this type of creature]} > 0)
	{
		;; Make sure the list does not get too big
		if (${InvalidMasteryTargets.Used} > 100)
		{
			;echo "DEBUG: InvalidMasteryTargets list too big (${InvalidMasteryTargets.Used} elements) -- Clearing..."
			InvalidMasteryTargets:Clear
		}

		if ${Actor[${KillTarget}](exists)}
		{
			;echo "DEBUG: Adding (${Actor[${KillTarget}].ID},${Actor[${KillTarget}].Name}) to the InvalidMasteryTargets list"
			InvalidMasteryTargets:Set[${Actor[${KillTarget}].ID},${Actor[${KillTarget}].Name}]

			;echo "DEBUG: InvalidMasteryTargets now has ${InvalidMasteryTargets.Used} actors in it."
		}
	}
}

atom(script) LootWDw(string ID)
{
	declare i int local
	variable int tmpcnt=1
	variable int deccnt=0

	if ${ID.Equal[${LastWindow}]}
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


	if ${LootMethod.Equal[Accept]}
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
									echo "DEBUG: Item marked as collectible and I've already collected it -- declining! (${LootWindow[${ID}].Item[${tmpcnt}].Name})"
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
	elseif ${LootMethod.Equal[Idle]}
	{
			LastWindow:Set[${ID}]
		return
	}

	LastWindow:Set[${ID}]


	switch ${LootWindow[${ID}].Type}
	{
		case Lottery
			if ${deccnt}
				LootWindow[${ID}]:DeclineLotto
			else
				LootWindow[${ID}]:RequestAll
			break
		case Free For All
			if ${deccnt}
				LootWindow[${ID}]:DeclineLotto
			else
				LootWindow[${ID}]:LootAll
			break
		case Need Before Greed
			if ${deccnt}
				LootWindow:${ID}]:DeclineNBG
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
	if (${haveaggro} || ${MainTank}) && ${Me.InCombat}
	{
		if ${Target.Target.ID}==${Me.ID}
		{
			if ${Target(exists)} && (${Me.ID}!=${Target.ID})
			{
				face ${Target.X} ${Target.Z}
			}

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
				echo "DEBUG:: KillTarget now set to '${Target}' (ID: ${Target.ID}"
		}
		else
		{
				echo "DEBUG:: SetNewKillTarget() FAILED -- Target invalid."
				return FAILED
		}

		return OK
}

function ReacquireKillTargetFromMA()
{
		CurrentAction:Set[Reacquiring KillTarget from ${MainAssist} in 1 seconds...]
		wait 10

		if ${Actor[ExactName,${MainAssist}](exists)}
		{
				if ${Actor[ExactName,${MainAssist}].Target(exists)} && ${Actor[ExactName,${MainAssist}].Target.Type.Find[NPC]}
				{
						KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
						echo "DEBUG:: KillTarget now set to ${Actor[ExactName,${MainAssist}]}'s target: ${Actor[ExactName,${MainAssist}].Target} (ID: ${KillTarget})"
						return OK
				}
		}

		echo "DEBUG:: ReacquireKillTargetFromMA() FAILED"
		return FAILED
}

function StartBot()
{
	variable int tempvar1
	variable int tempvar2

	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartXP",${Me.Exp}]:Save
	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartAPXP",${Me.APExp}]:Save
	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartTime",${Time.Timestamp}]:Save

	if ${CloseUI}
	{
		ui -unload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
		ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/eq2bot.xml"
	}
	else
	{
		UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Hide
		UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Hide
		UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Show
		UIElement[EQ2 Bot].FindUsableChild[Stop EQ2Bot,commandbutton]:Show
		UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Show
		UIElement[EQ2 Bot].FindUsableChild[Set KillTarget,commandbutton]:Show
		UIElement[EQ2 Bot].FindUsableChild[Reacquire KillTarget,commandbutton]:Show
	}

	if ${Me.SubClass.Equal[shadowknight]}
				UIElement[EQ2 Bot].FindUsableChild[Feign Death,commandbutton]:Show


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
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Show
	UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Show
	UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Hide
		if ${Actor[exactname,${MainTankPC}].InCombatMode}
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
		if ${Me.InCombat}
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

		UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Hide
		CurrentAction:Set["Checking Buffs Once..."]

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

	if ${MainTank}
			UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
		elseif ${Actor[exactname,${MainTankPC}].InCombatMode}
				UIElement[EQ2 Bot].FindUsableChild[Check Buffs,commandbutton]:Show
		CurrentAction:Set["Waiting..."]
		return
}


objectdef ActorCheck
{
	;returns true for valid targets
	member:bool ValidActor(int actorid)
	{
			if !${Actor[id,${actorid}](exists)}
					return FALSE

			if ${Actor[id,${actorid}].IsDead}
					return FALSE

		switch ${Actor[${actorid}].Type}
		{
			case NPC
				break

			case NamedNPC
				if ${IgnoreNamed}
					return FALSE
				break

			case PC
				return FALSE

			case NoKill NPC
				return FALSE

				case Pet
						return FALSE

				case MyPet
						return FALSE

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
				return FALSE
		}

		;checks if mob is too far above or below us
		if ${Me.Y}+10<${Actor[${actorid}].Y} || ${Me.Y}-10>${Actor[${actorid}].Y}
		{
			;echo "DEBUG: Actor (ID: ${actorid} is too far above or below me"
			return FALSE
		}

		if ${Actor[${actorid}].IsLocked}
			return FALSE

		if ${Actor[${actorid}].IsHeroic} && ${IgnoreHeroic}
			return FALSE

		if ${Actor[${actorid}].IsEpic} && ${IgnoreEpic}
			return FALSE

		;actor is a charmed pet, ignore it
		if ${This.FriendlyPet[${actorid}]}
		{
				;echo "DEBUG: Actor (ID: ${actorid} is a friendly pet ...ignoring"
			return FALSE
		}

		if ${Target.ID} == ${actorid}
		{
				if !${Me.TargetLOS}
				{
						;echo "EQ2Bot-ValidActor():: No line of sight to ${Target}."
						return FALSE
				}

				if ${Target.Distance} > ${MARange}
				{
						;echo "EQ2Bot-ValidActor():: ${Target} is not within MARange (${MARange})"
						return FALSE
				}
			}

		return TRUE
	}

	member:bool CheckActor(int actorid)
	{
		switch ${Actor[${actorid}].Type}
		{
			case NPC
				break

			case NamedNPC
				if ${IgnoreNamed}
					return FALSE
				break

			case PC
				return FALSE

			case Pet
					return FALSE

			case MyPet
					return FALSE

			Default
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
			return FALSE
		}

		if ${This.FriendlyPet[${actorid}]}
		{
			;actor is a charmed pet, ignore it
			return FALSE
		}

		if ${Actor[${actorid}](exists)}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}

	; Check if mob is aggro on Raid, group, or pet only, doesn't check agro on Me
	member:bool AggroGroup(int actorid)
	{
		variable int tempvar

		if ${This.FriendlyPet[${actorid}]}
		{
			;actor is a charmed pet, ignore it
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
					if (${Actor[${actorid}].Target.ID} == ${Me.Group[${tempvar}].ID})
						return TRUE
				}
				if (${Me.Group[${tempvar}].ToActor.Pet.ID(exists)})
				{
					if (${Actor[${actorid}].Target.ID} == ${Me.Group[${tempvar}].ToActor.Pet.ID})
						return TRUE
				}
			}
			while ${tempvar:Inc}<${Me.GroupCount}

			; Check if mob is aggro on raid or pet
			if ${Me.InRaid}
			{
				;echo checking aggro on raid
				tempvar:Set[1]
				do
				{
					if (${Me.Raid[${tempvar}](exists)})
					{
						if (${Actor[${actorid}].Target.ID} == ${Me.Raid[${tempvar}].ID})
						{
							;echo aggro detected on raid
							return TRUE
						}
					}
				}
				while ${tempvar:Inc}<24
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
		variable int tcount=2
		variable int mobcount

		if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
		{
			return 0
		}

		EQ2:CreateCustomActorArray[byDist,15]
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
		variable int tcount=2

		if !${Actor[NPC,range,${iEngageDistance}](exists)} && !(${Actor[NamedNPC,range,${iEngageDistance}](exists)} && !${IgnoreNamed})
		{
			;echo "DEBUG: No NPCs within a range of ${iEngageDistance}m"
			return FALSE
		}

		EQ2:CreateCustomActorArray[byDist,${iEngageDistance}]
		;echo "DEBUG: Detect() -- ${EQ2.CustomActorArraySize} mobs within ${iEngageDistance} meters."
		do
		{
			if ${This.CheckActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode}
			{
				if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
					return TRUE

				if ${This.AggroGroup[${CustomActor[${tcount}].ID}]}
					return TRUE
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}


		;echo "DEBUG: No NPC was found within ${iEngageDistance} meters that was aggro to you or anyone in your group."
		return FALSE
	}

	member:bool Target(int targetid)
	{
		if !${Actor[${targetid}].InCombatMode}
			return FALSE

		if ${This.AggroGroup[${targetid}]} || ${Actor[${targetid}].Target.ID}==${Me.ID}
			return TRUE

		return FALSE
	}

	member:int NearestAggro()
	{
		variable int tcount=2

		if !${Actor[NPC,range,20](exists)} && !${Actor[NamedNPC,range,20](exists)}
		{
			return 0
		}

		EQ2:CreateCustomActorArray[byDist,20]
		do
		{
			if (${CustomActor[${tcount}].Type.Equal[PC]})
					continue

			if (${CustomActor[${tcount}].Target.ID}==${Me.ID} || ${This.AggroGroup[${CustomActor[${tcount}].ID}]}) && ${CustomActor[${tcount}].InCombatMode}
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

	member:bool FriendlyPet(int actorid)
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
			while ${tempvar:Inc}<${Me.GroupCount}
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
			while ${tempvar:Inc}<=24
		}

		if ${Actor[${actorid}](exists)} && ${actorid}==${Me.Pet.ID}
			return TRUE

		return false
	}

	method CheckMYAggro()
	{
		variable int tcount=2
		haveaggro:Set[FALSE]
		variable int ActorID

		if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
			return

		EQ2:CreateCustomActorArray[byDist,15]
		do
		{
			ActorID:Set[${CustomActor[${tcount}].ID}]

			if ${This.ValidActor[${ActorID}]} && ${CustomActor[${tcount}].Target.ID}==${Me.ID} && ${CustomActor[${tcount}].InCombatMode}
			{
				if ${ActorID}
				{
					haveaggro:Set[TRUE]
					aggroid:Set[${ActorID}]
					return
				}
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
	}
}

objectdef EQ2BotObj
{

	method Init_Character()
	{
		charfile:Set[${mainpath}EQ2Bot/Character Config/${Me.Name}.xml]

		switch ${Me.Archetype}
		{
			case scout
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,TRUE]}]
				EngageDistance:Set[9]
				break

			case fighter
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,TRUE]}]
				EngageDistance:Set[9]
				break

			case priest
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,FALSE]}]
				EngageDistance:Set[35]
				break

			case mage
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,FALSE]}]
				EngageDistance:Set[35]
				break
		}

		MainTank:Set[${SettingXML[${charfile}].Set[General Settings].GetString[I am the Main Tank?,FALSE]}]
		MainAssistMe:Set[${SettingXML[${charfile}].Set[General Settings].GetString[I am the Main Assist?,FALSE]}]

		if ${MainTank}
			SettingXML[${charfile}].Set[General Settings]:Set[Who is the Main Tank?,${Me.Name}]:Save

		if ${MainAssistMe}
			SettingXML[${charfile}].Set[General Settings]:Set[Who is the Main Assist?,${Me.Name}]:Save

		MainAssist:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Who is the Main Assist?,${Me.Name}]}]
		MainTankPC:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Who is the Main Tank?,${Me.Name}]}]
		AutoSwitch:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Switch Targets when Main Assist Switches?,TRUE]}]
		AutoLoot:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Loot Corpses and open Treasure Chests?,FALSE]}]
		LootAll:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Accept Loot Automatically?,TRUE]}]
		LootMethod:Set[${SettingXML[${charfile}].Set[General Settings].GetString[LootMethod,Accept]}]
		AutoPull:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Pull,FALSE]}]
		PullOnlySoloMobs:Set[${SettingXML[${charfile}].Set[General Settings].GetString[PullOnlySoloMobs,FALSE]}]
		PullSpell:Set[${SettingXML[${charfile}].Set[General Settings].GetString[What to use when PULLING?,SPELL]}]
		PullRange:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What RANGE to PULL from?,15]}]
		PullWithBow:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Pull with Bow (Ranged Attack)?,FALSE]}]
		ScanRange:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What RANGE to SCAN for Mobs?,20]}]
		MARange:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What RANGE to Engage from Main Assist?,15]}]
		PowerCheck:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[Minimum Power the puller will pull at?,80]}]
		HealthCheck:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[Minimum Health the puller will pull at?,90]}]
		IgnoreEpic:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Epic Encounters?,TRUE]}]
		IgnoreNamed:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Named Encounters?,TRUE]}]
		IgnoreHeroic:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Heroic Encounters?,FALSE]}]
		IgnoreRedCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Red Con Mobs?,TRUE]}]
		IgnoreOrangeCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Orange Con Mobs?,TRUE]}]
		IgnoreYellowCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Yellow Con Mobs?,FALSE]}]
		IgnoreWhiteCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore White Con Mobs?,FALSE]}]
		IgnoreBlueCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Blue Con Mobs?,FALSE]}]
		IgnoreGreenCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Green Con Mobs?,FALSE]}]
		IgnoreGreyCon:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Ignore Grey Con Mobs?,TRUE]}]
		PullNonAggro:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Pull Non Aggro Mobs?,TRUE]}]
		AssistHP:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[Assist and Engage in combat at what Health?,96]}]
		Following:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Are we following someone?,FALSE]}]
		PathType:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What Path Type (0-4)?,0]}]
		CloseUI:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Close the UI after starting EQ2Bot?,FALSE]}]
		MasterSession:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Master IS Session,Master.is1]}]
		CheckPriestPower:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Check if Priest has Power in the Group?,TRUE]}]
		WipeRevive:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Revive on Group Wipe?,FALSE]}]
		BoxWidth:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[Navigation: Size of Box?,4]}]
		LoreConfirm:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Loot Lore Items?,TRUE]}]
		NoTradeConfirm:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Loot NoTrade Items?,FALSE]}]
		LootPrevCollectedShineys:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to loot previously collected shineys?,FALSE]}]

		if ${PullWithBow}
		{
			if !${Me.Equipment[ammo](exists)} || !${Me.Equipment[ranged](exists)}
				PullWithBow:Set[FALSE]
			else
				PullRange:Set[25]
		}

		SettingXML[${charfile}]:Save
	}

	method Init_Config()
	{
		spellfile:Set[${mainpath}EQ2Bot/Spell List/${Me.SubClass}.xml]
	}

	method Init_Events()
	{
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onLootWindowAppeared]:AttachAtom[LootWdw]
		;Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
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
		ui -reload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
		ui -reload -skin eq2skin "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/eq2bot.xml"
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
		while ${tempvar:Inc}<${Me.GroupCount}

		return 0
	}

	method MainAssist_Dead()
	{
		if !${Actor[${OriginalMA}].IsDead} && ${Actor[${OriginalMA}](exists)}
		{
			MainAssist:Set[${OriginalMA}]
			KillTarget:Set[]
			Echo Switching back to the original MainAssist ${MainAssist}
			return
		}
		else
		{
			MainAssist:Set[${MainTankPC}]
		}
	}

	method MainTank_Dead()
	{
		variable int highesthp

		if !${Actor[${OriginalMT}].IsDead} && ${Actor[${OriginalMT}](exists)}
		{
			MainTank:Set[FALSE]
			MainTankPC:Set[${OriginalMT}]
			KillTarget:Set[]
			Echo Switching back to the original MainTank ${MainTankPC}
			return
		}

		if ${Me.Archetype.Equal[fighter]}
		{
			highesthp:Set[${Me.MaxHealth}]
			MainTank:Set[TRUE]
			MainTankPC:Set[${Me.Name}]
		}

		grpcnt:Set[${Me.GroupCount}]
		tempgrp:Set[0]
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
					}
			}
		}
		while ${tempgrp:Inc}<${grpcnt}

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
						}
				}
			}
			while ${tempgrp:Inc}<24
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
		while ${tempvar:Inc}<${Me.GroupCount}

		return TRUE
	}

	method SetActorLooted(int ActorID, string ActorName)
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

	keycount:Set[${SettingXML[${spellfile}].Set[${class}].Keys}]
	do
	{
		tempnme:Set["${SettingXML[${spellfile}].Set[${class}].Key[${tempvar}]}"]

		templvl:Set[${Arg[1,${tempnme}]}]

		if ${templvl} > ${Me.Level}
			continue

		spellname:Set[${SettingXML[${spellfile}].Set[${class}].GetString["${tempnme}"]}]

		;echo "DEBUG-CheckAbilities: spellname: ${spellname} -- tempnme: ${tempnme} -- templvl: ${templvl}  (Me.Level: ${Me.Level})"
		if (${spellname.Length})
		{
			if !${Me.Ability[${spellname}](exists)}
			{
				; We are only concerned about abilities that are AAs (ie, level 10) and abilities greater than 20 levels below us
				if (${templvl} == 10 || (${templvl} >= ${Math.Calc[${Me.Level}-15]}))
				{
					echo "Missing Ability: '${spellname}' (Level: ${templvl})"
					MissingAbilitiesCount:Inc
				}
				else
				{
					;echo "DEBUG: tempnme: ${tempnme}"
					;echo "DEBUG: Setting SpellType[${Arg[2,${tempnme}]}] to '${spellname}'"
					SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
				}
			}
			else
			{
				;echo "DEBUG: tempnme: ${tempnme}"
				;echo "DEBUG: Setting SpellType[${Arg[2,${tempnme}]}] to '${spellname}'"
				SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
			}
		}
	}
	while ${tempvar:Inc}<=${keycount}

	if (${MissingAbilitiesCount} > 3 && ${Me.Level} >= 10)
	{
		echo "------------"
		echo "You appear to be missing abilities.  Checking knowledge book and searching again..."
		wait 5
		EQ2Execute /toggleknowledge
		wait 5
		EQ2Execute /toggleknowledge
		MissingAbilitiesCount:Set[0]
		tempvar:Set[1]

		do
		{
			tempnme:Set["${SettingXML[${spellfile}].Set[${class}].Key[${tempvar}]}"]

			templvl:Set[${Arg[1,${tempnme}]}]

			if ${templvl} > ${Me.Level}
				continue

			spellname:Set[${SettingXML[${spellfile}].Set[${class}].GetString["${tempnme}"]}]
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
		while ${tempvar:Inc}<=${keycount}
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

		do
		{
			tempnme:Set["${SettingXML[${spellfile}].Set[${class}].Key[${tempvar}]}"]

			templvl:Set[${Arg[1,${tempnme}]}]

			if ${templvl} > ${Me.Level}
				continue

			spellname:Set[${SettingXML[${spellfile}].Set[${class}].GetString["${tempnme}"]}]
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
		while ${tempvar:Inc}<=${keycount}
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

		do
		{
			tempnme:Set["${SettingXML[${spellfile}].Set[${class}].Key[${tempvar}]}"]

			templvl:Set[${Arg[1,${tempnme}]}]

			if ${templvl} > ${Me.Level}
				continue

			spellname:Set[${SettingXML[${spellfile}].Set[${class}].GetString["${tempnme}"]}]
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
		while ${tempvar:Inc}<=${keycount}

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

		LavishNav:Clear
		UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:ClearItems

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
			;echo "DEBUG(Navigation): New Zone Created!"
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
	if ${ChoiceWindow.Text.Find[cast]} && ${Me.ToActor.Health}<1
	{
		ChoiceWindow:DoChoice1
		;KillTarget:Set[]
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
	CurrentTask:Set[FALSE]

	ui -unload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/eq2bot.xml"

	DeleteVariable CurrentTask

	Event[EQ2_onChoiceWindowAppeared]:DetachAtom[EQ2_onChoiceWindowAppeared]
	Event[EQ2_onLootWindowAppeared]:DetachAtom[LootWdw]
	;Event[EQ2_onIncomingChatText]:DetachAtom[EQ2_onIncomingChatText]
	Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]

	press -release ${forward}
	press -release ${backward}
	press -release ${strafeleft}
	press -release ${straferight}

	SettingXML[${charfile}]:Unload
	SettingXML[${spellfile}]:Unload
}
