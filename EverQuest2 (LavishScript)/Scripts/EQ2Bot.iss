;-----------------------------------------------------------------------------------------------
; EQ2Bot.iss Version 2.7.1d Updated: 03/22/08 by Amadeus
;
;2.7.1d
; * Added a 'Health' case to the CheckCondition function (see Fury.iss (Combat_Init() and Combat_Routines()) for examples)
; * Removed some scripting that was causing crashes in the onLootWindowAppeared atom
; * Added a 'GroupWiped' variable (bool) that is set to TRUE whenever "Revive on Group Wipes" is checked and your entire
;   group wipes.  This variable can be checked in the class file at any point and should be reset to FALSE after any desired
;   action has been taken.  See Fury.iss (Buff_Routine()) for example.
; * Added a 'InitialBuffsDone' scriptwide variable (bool) that is set initially set to FALSE.  This is to allow for specific class
;   files to cast buffs (or any other spells) when the script is first run (ie, to give out rez feathers.)  See Fury.iss (Buff_Routine()) for example.
;
;2.7.1c
; Adjusted for new IsDead member of Actor.  This will fix false positives on death checks due to coagulate and other unconcious health buffs.
;	Adjusted MA_Dead and MT_Dead functions
; Adjusted LostAggro - Now fires with the ID of the mob that is lost, it no longer switched the MT's killtarget to the add.  This should allow
;	for mezing to be more effective, and allow for more control of how to react to aggro loss in the Lost_aggro() function in individual class files.
;
;2.7.1b
; Minor tweaks to AcceptWindow code
;
;2.7.1 (Pygar)
; Updated Lootwindow to fire on isxeq2 events rather than triggers
;	Update LootWindow to process on current window ID, this should allow for processing more than one window at a time now.
;
;2.7.0 (Blazer)
; You can now set Points of Interest for Dungeon Crawl Mode (This will help with moving to designated points that you want your bots to pass through)
; POI's can be re-arranged in priority order (top being first) by clicking and dragging the selection in the listbox.
; POI's can be excluded as well.
; Fixed MoveToMaster
; Added a Main Assist Range. This will ensure your group members dont engage a target unless the Main Assist is within this set range.
;
;2.6.1 (Pygar)
; Using new Loot Events
; New Pull code for Pet / Bow / Spell
; Pull Tweaks
;
;2.6.0 (Blazer)
;Pathing is now done with LavishNav
;
; Description:
; ------------
; Automated BOT for any class.
; Syntax: run eq2bot
;-----------------------------------------------------------------------------------------------
;===================================================
;===        Keyboard Configuration              ====
;===================================================
variable string forward=w
variable string backward=s
variable string strafeleft=q
variable string straferight=e
variable string endbot=f11
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
variable bool Following
variable int Deviation
variable int Leash
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
variable bool LootConfirm
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
variable int BadActor[50]
variable bool GroupWiped
variable bool InitialBuffsDone
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


function main()
{
	;ext -require isxeq2
	variable int tempvar
	variable int tempvar1
	variable int tempvar2
	variable string tempnme
	declare LastWindow string script

	if !${ISXEQ2.IsReady}
	{
		echo ISXEQ2 has not been loaded!  EQ2Bot can not run without it.  Good Bye!
		Script:End
	}

	Turbo 50

	;Script:Squelch
	;Script:EnableProfiling

	EQ2Bot:Init_Config
	EQ2Bot:Init_Triggers
	EQ2Bot:Init_Character
	EQ2Bot:Init_UI
	EQ2Nav:Initialise

	call Class_Declaration
	call CheckManaStone

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

	; The following 3 scripts are Initialized which are customizable
	call Buff_Init
	call Combat_Init
	call PostCombat_Init

	do
	{
		if ${EQ2.Zoning}
		{
			KillTarget:Set[]
			do
			{
				wait 50
			}
			while ${EQ2.Zoning}
			wait 50
			;need to move this var to script scope
			;AutoFollowingMA:Set[FALSE]
		}

		if !${StartBot}
		{
			KillTarget:Set[]
			do
			{
				wait 50
			}
			while !${StartBot}
		}

		if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
		{
			if ${Math.Calc[${Time.Timestamp}-${mstimer}]}>70
			{
				Me.Inventory[ExactName,ManaStone]:Use
				mstimer:Set[${Time.Timestamp}]
			}
		}

		;Process Pre-Combat Scripts
		tempvar:Set[1]
		do
		{
			do
			{
				waitframe
			}
			while ${Following} && ${FollowTask}==3

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
				{
					call MovetoMaster
				}
				elseif ${Target.Distance}>10
				{
					call FastMove ${Actor[ExactName,${MainAssist}].X} ${Actor[ExactName,${MainAssist}].Z} ${Math.Rand[3]:Inc[3]}
				}
			}

			if !${MainTank}
			{
				if (${Actor[ExactName,${MainAssist}].Target.Type.Equal[NPC]} || ${Actor[ExactName,${MainAssist}].Target.Type.Equal[NamedNPC]}) && ${Actor[ExactName,${MainAssist}].Target.InCombatMode}
				{
					KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
				}

				if ${Following}
				{
					if ${Mob.Target[${KillTarget}]}
					{
						FollowTask:Set[2]
						WaitFor ${Script[EQ2Follow].Variable[pausestate]} 30
						if ${AutoMelee}
						{
							call FastMove ${Actor[ExactName,${MainAssist}].X} ${Actor[ExactName,${MainAssist}].Z} ${Math.Rand[5]:Inc[5]}
						}
						else
						{
							call FastMove ${Actor[ExactName,${MainAssist}].X} ${Actor[ExactName,${MainAssist}].Z} 10
						}

						if ${Me.IsMoving}
						{
							press -release ${forward}
							wait 20 !${Me.IsMoving}
						}
						FollowTask:Set[1]
					}
				}

				; Add additional check to see if Mob is in Camp (assume radius of 15) OR MainTank is within designated range
				if ${KillTarget} && ${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead} && (${Mob.Detect} || ${Actor[ExactName,${MainAssist}].Distance}<${MARange})
				{
					if ${Mob.Target[${KillTarget}]}
					{
						call Combat
					}
				}
			}

			if ${PathType}==4 && ${MainTank}
			{
				if ${Me.InCombat} && ${Mob.Detect}
				{
					call Pull any
					if ${engagetarget}
					{
						call Combat
					}
				}
				else
				{
					if ${Me.ToActor.Power}<${PowerCheck} || ${Me.ToActor.Health}<${HealthCheck}
					{
						call ScanAdds
					}
				}
			}

			;this should force the tank to react to any aggro, regardless
			if ${Mob.Detect} && ${MainTank} && !${Me.IsMoving}
			{
				if ${Mob.Target[${Target.ID}]} && !${Target.IsDead}
				{
					call Combat
				}
				else
				{
					if ${Mob.NearestAggro}
					{
						target ${Mob.NearestAggro}
						call Combat
					}
				}
			}

			; Do Pre-Combat Script if there is no mob nearby
			if !${Mob.Detect} || (${MainTank} && ${Me.GroupCount}!=1) || ${KillTarget}
			{
				if ${KillTarget} && ${Actor[${KillTarget}].Health}<=${AssistHP} && !${Actor[${KillTarget}].IsDead} && ${Actor[${KillTarget},radius,35](exists)}
				{
					if ${Mob.Target[${KillTarget}]}
					{
						tempvar:Set[40]
					}
				}

				call Buff_Routine ${tempvar}
				if ${Return.Equal[Buff Complete]}
				{
					tempvar:Set[40]
				}

				;disable autoattack if not in combat
				if ${tempvar}<40 && ${Me.AutoAttackOn} && !${Mob.Detect}
				{
					EQ2Execute /toggleautoattack
				}

				;allow class file to set a var to override eq2bot stance / pet casting
				if !${NoEQ2BotStance}
				{
					switch ${Me.Archetype}
					{
						case scout
							if ${MainTank} && ${Me.GroupCount}!=1
							{
								if ${Me.Maintained[${SpellType[290]}](exists)}
								{
									Me.Maintained[${SpellType[290]}]:Cancel
								}
								call CastSpellRange 295 0 0 0 0 0 0 1
							}
							else
							{
								if ${Me.Maintained[${SpellType[295]}](exists)}
								{
									Me.Maintained[${SpellType[295]}]:Cancel
								}

								call CastSpellRange 290 0 0 0 0 0 0 1
							}

							if !${Me.Effect[Pathfinding](exists)}
							{
								call CastSpellRange 302 0 0 0 0 0 0 1
							}
							break

						case fighter
							if ${MainTank} && ${Me.GroupCount}!=1
							{
								if ${Me.Maintained[${SpellType[290]}](exists)}
								{
									Me.Maintained[${SpellType[290]}]:Cancel
								}
								call CastSpellRange 295 0 0 0 0 0 0 1
							}
							else
							{
								if ${Me.Maintained[${SpellType[295]}](exists)}
								{
									Me.Maintained[${SpellType[295]}]:Cancel
								}
								call CastSpellRange 290 0 0 0 0 0 0 1
							}
							break
						case mage
							if (${MainTank} && ${Actor[MyPet](exists)}) || ${Actor[MyPet].ID}==${Actor[exactname,${Maintank}].ID}
							{
								if ${Me.Maintained[${SpellType[290]}](exists)}
								{
									Me.Maintained[${SpellType[290]}]:Cancel
								}
								call CastSpellRange 295
							}
							elseif ${Actor[MyPet](exists)}
							{
								if ${Me.Maintained[${SpellType[295]}](exists)}
								{
									Me.Maintained[${SpellType[295]}]:Cancel
								}

								call CastSpellRange 290
							}
							break

						case priest
							break
						case default
							break
					}
				}

			}
		}
		while ${tempvar:Inc}<=40

		if ${AutoLoot}
		{
			call CheckLoot
		}

		if ${AutoPull}
		{
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
				{
					call MovetoWP ${LNavRegionGroup[Start].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
				}
				elseif ${CurrentPOI}==${Math.Calc[${POICount}+2]}
				{
					call MovetoWP ${LNavRegionGroup[Finish].NearestRegion[${Me.X},${Me.Z},${Me.Y}].ID}
				}
				else
				{
					call MovetoWP ${LNavRegion[${POIList[${CurrentPOI}]}]}
				}

				EQ2Execute /target_none
			}

			if ${Mob.Detect} || ((${Me.Ability[${PullSpell}].IsReady} || ${PullType.Equal[Pet Pull]} || ${PullType.Equal[Bow Pull]}) && ${Me.ToActor.Power}>${PowerCheck} && ${Me.ToActor.Health}>${HealthCheck})
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
								call Combat
							}
						}
					}
				}
				else
				{
					if ${Mob.Target[${Target.ID}]} && !${Target.IsDead} && ${Target.InCombatMode} && ${Target.Distance}<8
					{
						call Combat
					}
					else
					{
						if ${Mob.NearestAggro}
						{
							target ${Mob.NearestAggro}
							call Combat
						}
						else
						{
							if ${EQ2Bot.PriestPower}
							{
								EQ2Execute /target_none
								call Pull any
								if ${engagetarget}
								{
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
							call Combat
						}
					}
				}
			}
		}
		call ProcessTriggers

		; Check if we have leveled and reset XP Calculations in UI
		if ${Me.Level}>${StartLevel} && !${CloseUI}
		{
			SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartXP",${Me.Exp}]:Save
			SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartTime",${Time.Timestamp}]:Save
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

		if (${Actor[ExactName,${MainAssist}].IsDead} && !${MainTank}) || (${MainAssist.NotEqual[${OriginalMA}]} && ${Actor[${OriginalMA}].IsDead})
		{
			EQ2Bot:MainAssist_Dead
		}

		if (${Actor[${MainTankPC}].IsDead} && !${MainTank}) || (${MainTankPC.NotEqual[${OriginalMT}]} && ${Actor[${OriginalMT}].IsDead})
		{
			EQ2Bot:MainTank_Dead
		}

		; Check that we are close to MainAssist if we are following and not in combat
		if ${Following} && ${Actor[ExactName,${MainAssist}].Distance}>10 && ${Script[EQ2Follow].Variable[pausestate]} && !${Mob.Detect}
		{
			FollowTask:Set[1]
			wait 20
		}

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

function CastSpellRange(int start, int finish, int xvar1, int xvar2, int targettobuff, int notall, int refreshtimer, bool castwhilemoving)
{
	variable bool fndspell
	variable int tempvar=${start}
	variable int originaltarget


	if ${Me.IsMoving} && !${castwhilemoving}
	{
		return -1
	}

	if ${targettobuff}>0 && !${Actor[${targettobuff}](exists)}
	{
		return -1
	}

	do
	{
		if ${SpellType[${tempvar}].Length}
		{

			if ${Me.Ability[${SpellType[${tempvar}]}].IsReady}
			{
				if ${targettobuff}
				{
					fndspell:Set[FALSE]
					tempgrp:Set[1]
					do
					{
						if ${Me.Maintained[${tempgrp}].Name.Equal[${SpellType[${tempvar}]}]} && ${Me.Maintained[${tempgrp}].Target.ID}==${targettobuff} && (${Me.Maintained[${tempgrp}].Duration}>${refreshtimer} || ${Me.Maintained[${tempgrp}].Duration}==-1)
						{
							fndspell:Set[TRUE]
							break
						}
					}
					while ${tempgrp:Inc}<=${Me.CountMaintained}

					if !${fndspell}
					{
						if !${Actor[${targettobuff}](exists)} || ${Actor[${targettobuff}].Distance}>35
						{
							return -1
						}

						if ${xvar1} || ${xvar2}
						{
							call CheckPosition ${xvar1} ${xvar2}
						}

						if ${Target(exists)}
						{
							originaltarget:Set[${Target.ID}]
						}

						if ${targettobuff(exists)}
						{
							if !(${targettobuff}==${Target.ID}) && !(${targettobuff}==${Target.Target.ID} && ${Target.Type.Equal[NPC]})
							{
								target ${targettobuff}
								wait 10 ${Target.ID}==${targettobuff}
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

	if ${Me.IsMoving} && !${castwhilemoving}
	{
		return
	}

	CurrentAction:Set[Casting ${spell}]
	Me.Ability[${spell}]:Use

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
	variable int EngageDistance

	movinghome:Set[FALSE]
	avoidhate:Set[FALSE]
	FollowTask:Set[2]
	EngageDistance:Set[20]

	; Make sure we are still not moving when we enter combat
	if ${Me.IsMoving}
	{
		press -release ${forward}
		press -release ${backward}
		wait 20 !${Me.IsMoving}
	}

	do
	{
		if !${MainTank}
		{
			target ${KillTarget}
		}

		if ${Target.ID}!=${Me.ID} && ${Target(exists)}
		{
			face ${Target.X} ${Target.Z}

		}

		do
		{
			;these checks should be done before calling combat, once called, combat should insue, regardless.
			if !${Actor[${Target.ID}].InCombatMode}
			{
				break
			}

			if ${Target.ID}!=${Me.ID} && ${Target(exists)}
			{
				face ${Target.X} ${Target.Z}

			}

			tempvar:Set[1]
			do
			{
				call ProcessTriggers

				if ${PathType}==4 && ${MainTank}
				{
					call ScanAdds
				}

				if ${MainTank}
				{
					if ${Target.Target.ID}==${Me.ID}
					{
						call CheckMTAggro
					}
					else
					{
						call Lost_Aggro ${Target.ID}
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

					if ${Actor[${MainTankPC}].IsDead}
					{
						EQ2Bot:MainTank_Dead
						break
					}
				}

				if ${haveaggro} && !${MainTank} && ${Actor[${aggroid}].Name(exists)}
				{
					call Have_Aggro
				}

				switch ${Me.Archetype}
				{
					case fighter
					case scout
						EngageDistance:Set[9]
						break
					case mage
					case priest
					case default
						EngageDistance:Set[35]
				}

				do
				{
					waitframe
				}
				while ${MainTank} && ${Target.Target.ID}==${Me.ID} && ${Target.Distance}>${EngageDistance}

				call Combat_Routine ${tempvar}

				if ${Return.Equal[CombatComplete]}
				{
					tempvar:Set[40]
				}

				if !${Me.AutoAttackOn} && ${AutoMelee}
				{
					EQ2Execute /toggleautoattack
				}

				if ${AutoMelee} && !${MainTank}
				{
					;check valid rear position
					if ((${Math.Calc[${Target.Heading}-${Me.Heading}]}>-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<65) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>305 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-305)) && ${Target.Distance}<6
					{
						;we're behind and in range
					}
					;check right flank
					elseif ((${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)) && ${Target.Distance}<6
					{
						;we're right flank and in range
					}
					;check left flank
					elseif ((${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)) && ${Target.Distance}<6
					{
						;we're left flank and in range
					}
					elseif ${Target.Target.ID}==${Me.ID}
					{
						;we have aggro, move to the maintank
						call FastMove ${Actor[${MainTankPC}].X} ${Actor[${MainTankPC}].Z} 1
					}
					else
					{
						call CheckPosition 1 ${Target.IsEpic}
					}
				}
				elseif ${Target.Distance}>40 || ${Actor[${MainTankPC}].Distance}>40
				{
					call FastMove ${Actor[${MainTankPC}].X} ${Actor[${MainTankPC}].Z} 25
				}

				if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>80 && ${Me.Inventory[ExactName,ManaStone](exists)} && ${usemanastone}
				{
					if ${Math.Calc[${Time.Timestamp}-${mstimer}]}>70
					{
						Me.Inventory[ExactName,ManaStone]:Use
						mstimer:Set[${Time.Timestamp}]
					}
				}

				if ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
				{
					EQ2execute "/apply_verb ${Actor[${KillTarget}].ID} loot"
					break
				}

				if ${AutoSwitch} && !${MainTank} && ${Target.Health}>30 && (${Actor[ExactName,${MainAssist}].Target.Type.Equal[NPC]} || ${Actor[ExactName,${MainAssist}].Target.Type.Equal[NamedNPC]}) && ${Actor[ExactName,${MainAssist}].Target.InCombatMode}
				{
					if ${Mob.ValidActor[${Actor[ExactName,${MainAssist}].Target.ID}]}
					{
						KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
						target ${KillTarget}
						call ProcessTriggers
					}
				}
			}
			while ${tempvar:Inc}<=40

			if !${CurrentTask}
			{
				Script:End
			}

			if (${Actor[${KillTarget}].IsDead} && !${MainTank}) || (${Target.IsDead} && ${MainTank} && (${Actor[${KillTarget}].Type.Equal[NPC]} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].Type.Equal[Corpse]}))
			{
				break
			}

			call ProcessTriggers
		}
		while ((${Actor[${KillTarget}](exists)} && !${MainTank}) || (${Target(exists)} && ${MainTank})) && !${Actor[${KillTarget}].IsDead} && ${Mob.ValidActor[${KillTarget}]}

		disablebehind:Set[FALSE]
		disablefront:Set[FALSE]

		if !${MainTank}
		{
			if ${Mob.Detect}
			{
				wait 50 ${Actor[ExactName,${MainAssist}].Target(exists)}
			}

			if ${Actor[ExactName,${MainAssist}].Target(exists)} && ${Mob.ValidActor[${Actor[ExactName,${MainAssist}].Target.ID}]}
			{
				KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
				continue
			}
			else
			{
				break
			}
		}

		if ${AutoPull} || ${MainTank}
		{
			checkadds:Set[TRUE]

			call Pull any
			if ${engagetarget}
			{
				continue
			}
		}
	}
	while ${Me.InCombat}

	avoidhate:Set[FALSE]
	checkadds:Set[FALSE]

	tempvar:Set[1]
	do
	{
		call Post_Combat_Routine ${tempvar}
	}
	while ${tempvar:Inc}<=20

	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	if ${AutoLoot}
	{
		do
		{
			if ${Mob.Detect}
			{
				break
			}

			if ${Me.ToActor.Health}>=(${HealthCheck}-10)
			{
				call CheckLoot
				break
			}

			if ${PathType}==4 && ${MainTank} && ${Me.ToActor.Health}>=(${HealthCheck}-10)
			{
				call CheckLoot
				call ScanAdds
			}

			if (${Following} && ${Actor[ExactName,${MainAssist}].Distance}>15) || ${Me.ToActor.Health}>(${HealthCheck}-10)
			{
				break
				eq2execute /follow ${Actor[ExactName,${MainAssist}].Name}
			}

			call ProcessTriggers
		}
		while 1
	}

	if ${PathType}==1
	{
		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>4
		{
			movinghome:Set[TRUE]
			wait ${Math.Rand[10]} ${Mob.Detect}
			call FastMove ${HomeX} ${HomeZ} 4
			face ${Math.Rand[45]:Inc[315]}
		}
	}

	if ${Following}
	{
		FollowTask:Set[1]
		wait 20
	}

	if ${MainAssist.NotEqual[${OriginalMA}]} && !${MainTank}
	{
		EQ2Bot:MainAssist_Dead
	}

	if ${MainTankPC.NotEqual[${OriginalMT}]} && !${MainTank}
	{
		EQ2Bot:MainTank_Dead
	}
	if ${PathType}==4
	{
		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>${ScanRange}
		{
			face ${HomeX} ${HomeZ}
			wait ${Math.Rand[10]} ${Mob.Detect}

			tempvar:Set[${Math.Rand[30]:Dec[15]}]
			WPX:Set[${Math.Calc[${tempvar}*${Math.Cos[${Me.Heading}]}-20*${Math.Sin[${Me.Heading}]}+${Me.X}]}]
			WPZ:Set[${Math.Calc[-20*${Math.Cos[${Me.Heading}]}+${tempvar}*${Math.Sin[${Me.Heading}]}+${Me.Z}]}]

			call FastMove ${WPX} ${WPZ} 2
		}
	}
}

function GetBehind()
{
	variable float X
	variable float Z

	X:Set[${Math.Calc[-4*${Math.Sin[-${Target.Heading}]}+${Target.X}]}]
	Z:Set[${Math.Calc[4*${Math.Cos[-${Target.Heading}]}+${Target.Z}]}]

	call FastMove ${X} ${Z} 2
	if ${Return.Equal[STUCK]}
	{
		disablebehind:Set[TRUE]
		call FastMove ${Target.X} ${Target.Z} 3
	}

	if ${Target(exists)} && (${Target.ID}!=${Me.ID})
	{
		face ${Target.X} ${Target.Z}
	}

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

	call FastMove ${X} ${Z} 1
	if ${Return.Equal[STUCK]}
	{
		disablebehind:Set[TRUE]
		call FastMove ${Target.X} ${Target.Z} 3
	}

	if ${Target(exists)} && (${Target.ID}!=${Me.ID})
	{
		face ${Target.X} ${Target.Z}
	}
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
		call FastMove ${Target.X} ${Target.Z} 3
	}

	if ${Target(exists)} && (${Target.ID}!=${Me.ID})
	{
		face ${Target.X} ${Target.Z}
	}
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
	{
		return
	}

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
			{

				maxrange:Set[${Me.Equipment[Ranged].Range}]
			}
			else
			{
				maxrange:Set[35]
			}
			break
	}

	if ${Target.Target.ID}==${Me.ID} && ${AutoMelee}
	{
		minrange:Set[0]
		maxrange:Set[4]
	}

	if ${haveaggro}
	{
		position:Set[2]
	}

	if ${disablebehind} && (${position}==1 || ${position}==3)
	{
		position:Set[0]
	}

	if !${MainTank}
	{
		if ${Math.Distance[${Actor[ExactName,${MainAssist}].X},${Actor[ExactName,${MainAssist}].Z},${Target.X},${Target.Z}]}>8 && !${Following}
		{
			return
		}
	}
	elseif ${PathType}==2
	{
		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}<8 && ${Me.InCombat} && !${lostaggro} && ${Target.Distance}>10
		{
			return
		}

		if ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}>5 && ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}<10 && ${Me.InCombat} && !${lostaggro}
		{
			call FastMove ${HomeX} ${HomeZ} 3
			return
		}
	}

	if ${Target.Distance}>${maxrange} && ${Target.Distance}<35 && ${PathType}!=2 && !${isstuck}
	{
		if ${Target(exists)} && (${Me.ID}!=${Target.ID})
		{
			face ${Target.X} ${Target.Z}
		}

		call FastMove ${Target.X} ${Target.Z} ${maxrange}

	}

	if ${Target.Distance}<${minrange} && ${Target(exists)} && (${Me.ID}!=${Target.ID}) && (${rangetype}==1 || ${rangetype}==3)
	{
		movetimer:Set[${Time.Timestamp}]
		press -hold ${backward}
		do
		{
			if ${Target(exists)} && (${Me.ID}!=${Target.ID})
			{
				face ${Target.X} ${Target.Z}
			}

			if ${Math.Calc[${Time.Timestamp}-${movetimer}]}>2
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
		{
			face ${Target.X} ${Target.Z}
		}
	}

	if ${position}
	{
		switch ${position}
		{
			case 1
				; Behind arc is 60 degree arc. Using 50 degree arc to allow for error
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				{
					return
				}
				else
				{
					call GetBehind
				}
				break
			case 2

				; Frontal Arc is 120 degree arc. Using 110 to allow for error
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>125 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<235) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-235 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-125)
				{
					return
				}
				else
				{
					call GetinFront
				}
				break
			case 3
				; Using 80 degree flank arc between front and rear arcs with 5 degree error on front and back of the arc
				;check if we are on the left flank
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
				{
					return
				}

				;check if we are at the right flank
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
				{
					return
				}

				;note parameter for GetToflank is null for right, 1 for left

				;check if we are on the left side of the mob, if so move to the left flank
				if ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-180 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<0
				{
					call GetToFlank 1
				}
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
			if ${Target.Health}>=${xvar1} && ${Target.Health}<=${xvar2}
			{
				return "OK"
			}
			else
			{
				return "FAIL"
			}
			break

		case Power
			if ${Me.ToActor.Power}>=${xvar1} && ${Me.ToActor.Power}<=${xvar2}
			{
				return "OK"
			}
			else
			{
				return "FAIL"
			}
			break

		case Health
			if ${Me.ToActor.Health}>=${xvar1} && ${Me.ToActor.Health}<=${xvar2}
			{
				return "OK"
			}
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
	variable bool chktarget
	variable int tempvar
	variable bool aggrogrp=FALSE

	engagetarget:Set[FALSE]

	if !${Actor[NPC,range,${ScanRange}](exists)} && !(${Actor[NamedNPC,range,${ScanRange}](exists)} && !${IgnoreNamed})
	{
		return
	}

	EQ2:CreateCustomActorArray[byDist,${ScanRange}]
	do
	{
		chktarget:Set[FALSE]
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]}
		{
			if ${Mob.AggroGroup[${CustomActor[${tcount}].ID}]}
			{
				aggrogrp:Set[TRUE]
			}

			if !${CustomActor[${tcount}].IsAggro}
			{

				if !${aggrogrp} && ${CustomActor[${tcount}].Target.ID}!=${Me.ID} && !${Me.InCombat} && (${Me.ToActor.Power}<75 || ${Me.ToActor.Health}<90) && !${CustomActor[${tcount}].InCombatMode}
				{
					continue
				}

				if !${aggrogrp} && ${CustomActor[${tcount}].Target.ID}!=${Me.ID} && ${Me.InCombat} && !${CustomActor[${tcount}].InCombatMode}
				{
					continue
				}

				if !${aggrogrp} && ${CustomActor[${tcount}].Target.ID}!=${Me.ID} && !${PullNonAggro}
				{
					continue
				}
			}

			if ${checkadds} && !${aggrogrp} && ${CustomActor[${tcount}].Target.ID}!=${Me.ID}
			{
				continue
			}

			chktarget:Set[TRUE]

			if ${chktarget}
			{
				target ${CustomActor[${tcount}].ID}

				wait 10 ${CustomActor[${tcount}].ID}==${Target.ID}
				wait 10 ${Me.TargetLOS}

				;echo check if in range
				if ((${PathType}==2 || ${PathType}==3 && ${pulling}) || ${PathType}==4) && ${Target.Distance}>${PullRange} && ${Target.Distance}<${ScanRange}
				{
					;echo Move to target Range!
					call FastMove ${Target.X} ${Target.Z} ${PullRange}
				}

				if ${PathType}==1 && ${Target.Distance}>${PullRange} && ${Target.Distance}<${ScanRange}
				{
					;echo Move to target Range!
					call FastMove ${Target.X} ${Target.Z} ${PullRange}
				}

				if ${Me.IsMoving}
				{
					press -release ${forward}
					wait 20 !${Me.IsMoving}
				}

				; Use pull spell
				if ${PullType.Equal[Bow Pull]} && ${Target.Distance}>6
				{
					; Use Bow to pull
					EQ2Execute /togglerangedattack
					wait 50 ${CustomActor[${tcount}].InCombatMode}
					if ${CustomActor[${tcount}].InCombatMode}
					{
						KillTarget:Set[${Target.ID}]
						if ${Target(exists)} && !${pulling} && (${Me.ID}!=${Target.ID})
						{
							face ${Target.X} ${Target.Z}
						}
						engagetarget:Set[TRUE]
					}
					if ${Me.InCombat}
					{
						EQ2Execute /togglerangedattack
					}
					break
				}
				elseif ${PullType.Equal[Pet Pull]}
				{
					; Use Pet to pull
					EQ2Execute /pet attack
					wait 200 ${Me.ToActor.InCombatMode}
					if ${Me.ToActor.InCombatMode}
					{
						KillTarget:Set[${Target.ID}]
						EQ2Execute /pet backoff
						wait 300 ${CustomActor[${tcount}].Distance}<10
						EQ2Execute /pet attack
						if ${PetGuard}
						{
							EQ2Execute /pet preserve_self
							EQ2Execute /pet preserve_master
						}
						if ${Target(exists)} && !${pulling} && (${Me.ID}!=${Target.ID})
						{
							face ${Target.X} ${Target.Z}
						}
						engagetarget:Set[TRUE]
					}
					break
				}
				else
				{
					call CastSpell "${PullSpell}"
				}

				if (${Return.Equal[CANTSEETARGET]} || ${Return.Equal[TOOFARAWAY]}) && ${pulling} && !${Me.InCombat} && !${CustomActor[${tcount}].InCombatMode}
				{
					;randomly pick a direction
					if ${Math.Rand[10]}>5
					{
						press -hold STRAFELEFT
						wait ${Math.Rand[40]}
						press -release STRAFELEFT
					}
					else
					{
						press -hold STRAFERIGHT
						wait ${Math.Rand[40]}
						press -release STRAFERIGHT
					}
					call FastMove ${Target.X} ${Target.Z} 15
					EQ2Execute /target_none
				}
				else
				{
					if ${Return.Equal[TOOFARAWAY]} && ${Math.Distance[${Me.X},${Me.Z},${HomeX},${HomeZ}]}<8 && ${PathType}==2
					{
						call FastMove ${Target.X} ${Target.Z} 3
					}
					elseif ${Return.Equal[CANTSEETARGET]} || ${Return.Equal[TOOFARAWAY]}
					{
						aggrogrp:Set[FALSE]
						if ${Me.GroupCount}>1
						{
							tempvar:Set[1]
							do
							{
								if ${Target.Target.ID}==${Me.Group[${tempvar}].ID} && ${Me.Group[${tempvar}](exists)}
								{
									aggrogrp:Set[TRUE]
									break
								}
							}
							while ${tempvar:Inc}<${Me.GroupCount}
						}

						if !${aggrogrp} && ${Target.Target.ID}!=${Me.ID}
						{
							if ${PathType}==4
							{
								if ${Return.Equal[CANTSEETARGET]}
								{
									EQ2Execute /target_none
									continue
								}

								if ${AutoMelee}
								{
									call FastMove ${Target.X} ${Target.Z} 10
								}
								else
								{
									call FastMove ${Target.X} ${Target.Z} 20
								}

								if ${Return.Equal[STUCK]}
								{
									EQ2Execute /target_none
									continue
								}
							}
							else
							{
								continue
							}
						}

						if ${PathType}==4 && ${Target.Distance}>15
						{
							if ${AutoMelee}
							{
								call FastMove ${Target.X} ${Target.Z} 4
							}
							else
							{
								call FastMove ${Target.X} ${Target.Z} 10
							}
							if ${Return.Equal[STUCK]}
							{
								EQ2Execute /target_none
								continue
							}
						}
					}


					do
					{
						waitframe
					}
					while ${Target.Distance}>10 && ${Target.Target.ID}==${Me.ID} && ${Target.ID}==${KillTarget}


					if ${Target.Distance}>10 && !${pulling} && ${PathType}!=2
					{
						if ${AutoMelee}
						{
							call FastMove ${Target.X} ${Target.Z} 5
						}
						elseif ${Target.Distance}>20
						{
							call FastMove ${Target.X} ${Target.Z} 20
						}

						if ${Return.Equal[STUCK]}
						{
							EQ2Execute /target_none
							continue
						}
					}

					KillTarget:Set[${Target.ID}]
					if ${Target(exists)} && !${pulling} && (${Me.ID}!=${Target.ID})
					{
						face ${Target.X} ${Target.Z}
					}
					engagetarget:Set[TRUE]
					break
				}
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
	FlushQueued CantSeeTarget
}

function CheckLoot()
{
	variable int tcount=2
	variable int tmptimer
	variable int actorcnt=0
	variable int skipcnt=0

	islooting:Set[TRUE]
	;think this is legacy, removing
	;wait 10
	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		;Check if already looted
		skipcnt:Set[0]
		actorcnt:Set[0]
		while ${actorcnt:Inc}<=50
		{
			if ${BadActor[${actorcnt}]} && ${CustomActor[${tcount}].ID}==${BadActor[${actorcnt}]}
			{
				skipcnt:Set[1]
			}
		}

		if ${CustomActor[${tcount}].Type.Equal[chest]} && !${skipcnt}
		{
			Echo Looting ${CustomActor[${tcount}].Name}
			call FastMove ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 1
			switch ${Me.SubClass}
			{
				case dirge
				case troubador
				case swashbuckler
				case brigand
				case ranger
				case assassin
					Echo disarming trap on ${CustomActor[${tcount}].ID}
					EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} disarm"
					waitframe
					break
				case default
					break
			}
			Actor[Chest]:DoubleClick
			if !${Return.Equal[TOOFARAWAY]}
			{
				EQ2Bot:SetBadActor[${CustomActor[${tcount}].ID}]
			}
			wait 5
			call ProcessTriggers
		}
		else
		{
			if ${CustomActor[${tcount}].Type.Equal[Corpse]} && !${skipcnt}
			{
				Echo Looting ${Actor[corpse].Name}
				call FastMove ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 1
				EQ2execute "/apply_verb ${CustomActor[${tcount}].ID} loot"
				EQ2Bot:SetBadActor[${CustomActor[${tcount}].ID}]
				waitframe
				call ProcessTriggers
			}
		}

		if !${CurrentTask}
		{
			Script:End
		}

		if ${CustomActor[${tcount}].IsAggro} || ${Me.InCombat} || !${AutoLoot}
		{
			return
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
	islooting:Set[FALSE]
}

function FastMove(float X, float Z, int range)
{
	variable float xDist
	variable float SavDist=${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}
	variable int xTimer

	if !${Target(exists)} && !${islooting} && !${movingtowp} && !${movinghome} && ${Me.InCombat}
	{
		return "TARGETDEAD"
	}

	if ${NoMovement}
	{
		return "NOMOVEMENT"
	}

	if !${X} || !${Z}
	{
		return "INVALIDLOC"
	}

	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${ScanRange} && !${Following} && ${PathType}!=4
	{
		return "INVALIDLOC"
	}
	elseif ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>50 && ${PathType}!=4
	{
		return "INVALIDLOC"
	}

	face ${X} ${Z}

	if !${pulling}
	{
		press -hold ${forward}
	}

	xTimer:Set[${Script.RunningTime}]

	do
	{
		xDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]

		if ${Math.Calc[${SavDist}-${xDist}]}<0.8
		{
			if (${Script.RunningTime}-${xTimer})>500
			{
				isstuck:Set[TRUE]
				if !${pulling}
				{
					press -release ${forward}
					wait 20 !${Me.IsMoving}
				}
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
		{
			CurrentAction:Set[Moving to Start]
		}
		elseif ${CurrentPOI}==${Math.Calc[${POICount}+2]}
		{
			CurrentAction:Set[Moving to Finish]
		}
		else
		{
			CurrentAction:Set[Moving to ${destination.Name}]
		}
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
				{
					return "STUCK"
				}

				if (${pulling} || ${PathType}==3) && !${Me.IsMoving}
				{
					press -hold ${forward}
				}
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
						{
							face ${Target.X} ${Target.Z}
						}
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
							{
								face ${Target.X} ${Target.Z}
							}
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
					{
						face ${Target.X} ${Target.Z}
					}
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
		{
			press -release ${forward}
		}

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
		;KillTarget:Set[]
		wait 300
	}
	elseif ${WipeRevive}
	{
		do
		{
			wipe:Set[1]
			wipegroup:Set[1]
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
			if ${Math.Calc[${Time.Timestamp}-${deathtimer}]}>5000
			{
				Exit
			}
		}
		while ${Me.ToActor.Health}<1
	}
}

function LoreItem(string Line)
{
		EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
}

function LootWindowBusy(string Line)
{
		EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
}

function InventoryFull(string Line)
{
	EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick

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
		{
			face ${Target.X} ${Target.Z}
		}
	}

	lostaggro:Set[FALSE]

	if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
	{
		return "NOAGGRO"
	}

	newtarget:Set[${Target.ID}]

	EQ2:CreateCustomActorArray[byDist,15]
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode}
		{
			if ${Math.Calc[${CustomActor[${tcount}].Health}+1]}<${Actor[${newtarget}].Health} && ${Actor[${newtarget}](exists)}
			{
				newtarget:Set[${CustomActor[${tcount}].ID}]
			}

			if ${CustomActor[${tcount}].Target.ID}!=${Me.ID}
			{
				if !${Mob.AggroGroup[${CustomActor[${tcount}].ID}]}
				{
					continue
				}

				;this seems wrong, trying a change
				;KillTarget:Set[${CustomActor[${tcount}].ID}]
				;target ${KillTarget}
				;wait 10 ${Target.ID}==${KillTarget}
				;
				;if ${Target(exists)} && (${Me.ID}!=${Target.ID})
				;{
				;	face ${Target.X} ${Target.Z}
				;}

				call Lost_Aggro ${CustomActor[${tcount}].ID}
				lostaggro:Set[TRUE]
				return
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	;again this seems wrong
	if ${Actor[${newtarget}](exists)}
	{
		KillTarget:Set[${newtarget}]
		target ${KillTarget}

		wait 10 ${Target.ID}==${KillTarget}

		if ${Target(exists)} && (${Me.ID}!=${Target.ID})
		{
			face ${Target.X} ${Target.Z}
		}
	}
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

atom(script) LootWDw(string ID)
{
	declare i int local
	variable int tmpcnt=0
	variable int deccnt=0

	if ${ID.Equal[${LastWindow}]}
	{
		EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
		return
	}


	if ${LootMethod.Equal[Accept]}
	{
		if !${LootConfirm}
		{
			do
			{
				if (${LootWindow[${ID}].Item[${tmpcnt}].Lore} || ${LootWindow[${ID}].Item[${tmpcnt}].NoTrade})
				{
					deccnt:Inc
				}
			}
			while ${tmpcnt:Inc}<=${LootWindow[${ID}].NumItems}
		}
	}
	elseif ${LootMethod.Equal[Decline]}
	{
		deccnt:Inc
	}

	LastWindow:Set[${ID}]

	if ${LootMethod.Equal[Idle]}
	{
		return
	}

	if (${deccnt} && !${LootMethod.Equal[Idle]}) || ${LootMethod.Equal[Decline]}
	{
		EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
		return
	}

	switch ${LootWindow[${ID}].Type}
	{
		case Lottery
			if ${deccnt}
			{
				LootWindow[${ID}]:DeclineLotto
			}
			else
			{
				LootWindow[${ID}]:RequestAll
			}
			break
		case Free For All
			if ${deccnt}
			{
				EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
			}
			else
			{
				LootWindow[${ID}]:LootAll
			}
			break
		case Need Before Greed
			if ${deccnt}
			{
				EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
			}
			else
			{
				LootWindow[${ID}]:SelectGreed
			}
			break
		case Unknown
		Default
			EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
	}

	;if window is still open, close it
	;if ${EQ2UIPage[Inventory,Loot].Child[text,Loot.LottoTimerDisplay].Label}>0 && ${EQ2UIPage[Inventory,Loot].Child[text,Loot.LottoTimerDisplay].Label}<60 && ${LootWindow[${ID}].Item[1].Name(exists)}
	;{
	;	EQ2UIPage[Inventory,Loot].Child[button,Loot.WindowFrame.Close]:LeftClick
	;}
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

			press -hold ${backward}
			wait 5
			press -release ${backward}
			wait 20 !${Me.IsMoving}
			return
		}
	}
}


function BotFollow(string Line, string FollowTarget)
{
	variable string tempTarget

	if ${FollowTarget.Equal[me]}
	{
		tempTarget:Set[${MainAssist}]
	}
	else
	{
		tempTarget:Set[${FollowTarget}]
	}

	if !${Actor[${tempTarget},radius,30].ID}
	{
		Echo ${tempTarget} is out of range or does not exist.
	}
	else
	{
		if ${Script[EQ2Follow](exists)}
		{
			Script[EQ2Follow].Variable[ftarget]:Set[${tempTarget}]
			Script[EQ2Follow]:QueueCommand[call ResetPoints]
		}
		if ${tempTarget.Length} && !${Script[EQ2Follow](exists)}
		{
			run eq2follow 1 "${tempTarget}"
			Following:Set[TRUE]
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
	EQ2Execute /${doCommand}
}

function BotTell(string line, string tellSender, string tellMessage)
{
	uplink relay ${MasterSession} "EQ2Echo ${tellSender} tells ${Me.Name}, ${tellMessage}"
}

function BotAutoMeleeOn()
{
	AutoMelee:Set[TRUE]
}

function BotAutoMeleeOff()
{
	AutoMelee:Set[FALSE]

	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}
}

function BotCastTarget(string line, string Spell, string castTarget)
{
	variable string tempTarget

	if ${castTarget.Equal[me]}
	{
		tempTarget:Set[${MainAssist}]
	}
	else
	{
		tempTarget:Set[${castTarget}]
	}
	target ${tempTarget}
	wait 2
	call CastSpell "${Spell}"
}

function StartBot()
{
	variable int tempvar1
	variable int tempvar2

	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Temporary Settings]:Set["StartXP",${Me.Exp}]:Save
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
	}

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


	if !${PathType} && ${Following}
	{
		if ${Script[EQ2Follow](exists)}
		{
			Script[EQ2Follow]:End
			wait 10
		}
		run eq2follow "${Follow}" ${Leash} ${Deviation}
	}
	else
	{
		Following:Set[FALSE]
	}

	StartBot:Set[TRUE]
}

function PauseBot()
{
	PauseBot:Set[TRUE]
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Show

	do
	{
		waitframe
		call ProcessTriggers
	}
	while ${PauseBot}
}

function ResumeBot()
{
	PauseBot:Set[FALSE]
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Show
}

function StopBot()
{
	UIElement[EQ2 Bot].FindUsableChild[Stop EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Resume EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pause EQ2Bot,commandbutton]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Combat Frame,frame]:Hide
	UIElement[EQ2 Bot].FindUsableChild[Pathing Frame,frame]:Show
	UIElement[EQ2 Bot].FindUsableChild[Start EQ2Bot,commandbutton]:Show
}


objectdef ActorCheck
{
	;returns true for valid targets
	member:bool ValidActor(int actorid)
	{
		switch ${Actor[${actorid}].Type}
		{
			case NPC
				break

			case NamedNPC
				if ${IgnoreNamed}
				{
					return FALSE
				}
				break

			case PC
				return FALSE

			Default
				return FALSE
		}

		switch ${Actor[${actorid}].ConColor}
		{
			case Yellow
				if ${IgnoreYellowCon}
				{
					return FALSE
				}
				break

			case White
				if ${IgnoreWhiteCon}
				{
					return FALSE
				}
				break

			case Blue
				if ${IgnoreBlueCon}
				{
					return FALSE
				}
				break

			case Green
				if ${IgnoreGreenCon}
				{
					return FALSE
				}
				break

			case Orange
				if ${IgnoreOrangeCon}
				{
					return FALSE
				}
				break

			case Red
				if ${IgnoreRedCon}
				{
					return FALSE
				}
				break

			case Grey
				if ${IgnoreGreyCon}
				{
					return FALSE
				}
				break

			Default
				return FALSE
		}

		;checks if mob is too far above or below us
		if ${Me.Y}+10<${Actor[${actorid}].Y} || ${Me.Y}-10>${Actor[${actorid}].Y}
		{
			return FALSE
		}

		if ${Actor[${actorid}].IsLocked}
		{
			return FALSE
		}

		if ${Actor[${actorid}].IsHeroic} && ${IgnoreHeroic}
		{
			return FALSE
		}

		if ${Actor[${actorid}].IsEpic} && ${IgnoreEpic}
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

	member:bool CheckActor(int actorid)
	{
		switch ${Actor[${actorid}].Type}
		{
			case NPC
				break

			case NamedNPC
				if ${IgnoreNamed}
				{
					return FALSE
				}
				break

			case PC
				return FALSE

			Default
				return FALSE
		}

		;checks if mob is too far above or below us
		if ${Me.Y}+10<${Actor[${actorid}].Y} || ${Me.Y}-10>${Actor[${actorid}].Y}
		{
			return FALSE
		}

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
			tempvar:Set[1]
			do
			{
				if (${Actor[${actorid}].Target.ID}==${Me.Group[${tempvar}].ID} && ${Me.Group[${tempvar}](exists)}) || (${Actor[${actorid}].Target.ID}==${Me.Group[${tempvar}].ToActor.PetID} && ${Me.Group[${tempvar}].ToActor.PetID(exists)})
				{
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
					if (${Actor[${actorid}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].ID} && ${Me.Raid[${tempvar}](exists)})
					{
						;echo aggro detected on raid
						return TRUE
					}
				}
				while ${tempvar:Inc}<24
			}
		}

		if ${Actor[MyPet](exists)} && ${Actor[${actorid}].Target.ID}==${Actor[MyPet].ID}
		{
			return TRUE
		}

		if ${Actor[${actorid}].Target.ID}==${Me.ID} && ${Actor[${actorid}].InCombatMode}
		{
			return TRUE
		}

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
	member:bool Detect()
	{
		variable int tcount=2

		if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
		{
			return FALSE
		}

		EQ2:CreateCustomActorArray[byDist,15]
		do
		{
			if ${This.CheckActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode}
			{
				if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
				{
					return TRUE
				}

				if ${This.AggroGroup[${CustomActor[${tcount}].ID}]}
				{
					return TRUE
				}
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

		return FALSE
	}

	member:bool Target(int targetid)
	{
		if !${Actor[${targetid}].InCombatMode}
		{
			return FALSE
		}

		if ${This.AggroGroup[${targetid}]} || ${Actor[${targetid}].Target.ID}==${Me.ID}
		{
			return TRUE
		}

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

		if ${Me.GroupCount}>1 || ${Me.InRaid}
		{
			;echo Check if mob is a pet of my group
			tempvar:Set[1]
			do
			{
				if ${Me.Group[${tempvar}](exists)} && ${Actor[${actorid}].ID}==${Me.Group[${tempvar}].ToActor.Pet.ID}
				{
					return TRUE
				}
			}
			while ${tempvar:Inc}<${Me.GroupCount}

			;echo Check if mob is a pet of my raid
			if ${Me.InRaid}
			{
				;echo checking aggro on raid
				tempvar:Set[1]
				do
				{
					if (${Me.Raid[${tempvar}](exists)} && ${Actor[${actorid}].ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].Pet.ID})
					{
						;echo actor is pet of raid
						return TRUE
					}
				}
				while ${tempvar:Inc}<24
			}
		}

		if ${Actor[${actorid}](exists)} && ${Actor[${actorid}].ID}==${Me.ToActor.Pet.ID}
		{
			return TRUE
		}

		return false
	}

	method CheckMYAggro()
	{
		variable int tcount=2
		haveaggro:Set[FALSE]

		if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && !${IgnoreNamed})
		{
			return
		}

		EQ2:CreateCustomActorArray[byDist,15]
		do
		{
			if ${This.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target.ID}==${Me.ID} && ${CustomActor[${tcount}].InCombatMode}
			{
				if ${CustomActor[${tcount}].ID}
				{
					haveaggro:Set[TRUE]
					aggroid:Set[${CustomActor[${tcount}].ID}]
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
				break

			case fighter
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,TRUE]}]
				break

			case priest
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,FALSE]}]
				break

			case mage
				AutoMelee:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Melee,FALSE]}]
				break
		}

		MainTank:Set[${SettingXML[${charfile}].Set[General Settings].GetString[I am the Main Tank?,FALSE]}]
		MainAssistMe:Set[${SettingXML[${charfile}].Set[General Settings].GetString[I am the Main Assist?,FALSE]}]

		if ${MainTank}
		{
			SettingXML[${charfile}].Set[General Settings]:Set[Who is the Main Tank?,${Me.Name}]:Save
		}

		if ${MainAssistMe}
		{
			SettingXML[${charfile}].Set[General Settings]:Set[Who is the Main Assist?,${Me.Name}]:Save
		}

		MainAssist:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Who is the Main Assist?,${Me.Name}]}]
		MainTankPC:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Who is the Main Tank?,${Me.Name}]}]
		AutoSwitch:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Switch Targets when Main Assist Switches?,TRUE]}]
		AutoLoot:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Loot Corpses and open Treasure Chests?,FALSE]}]
		LootAll:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Accept Loot Automatically?,TRUE]}]
		LootMethod:Set[${SettingXML[${charfile}].Set[General Settings].GetString[LootMethod,Accept]}]
		AutoPull:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Auto Pull,FALSE]}]
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
		Follow:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Who are we following?,${MainAssist}]}]
		Deviation:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What is our Deviation for following?,1]}]
		Leash:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What is our Leash Range?,3]}]
		PathType:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[What Path Type (0-4)?,0]}]
		CloseUI:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Close the UI after starting EQ2Bot?,FALSE]}]
		MasterSession:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Master IS Session,Master.is1]}]
		LootConfirm:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Do you want to Loot Lore or No Trade Items?,TRUE]}]
		CheckPriestPower:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Check if Priest has Power in the Group?,TRUE]}]
		WipeRevive:Set[${SettingXML[${charfile}].Set[General Settings].GetString[Revive on Group Wipe?,FALSE]}]
		BoxWidth:Set[${SettingXML[${charfile}].Set[General Settings].GetInt[Navigation: Size of Box?,4]}]

		if ${PullWithBow}
		{
			if !${Me.Equipment[ammo](exists)} || !${Me.Equipment[ranged](exists)}
			{
				PullWithBow:Set[FALSE]
			}
			else
			{
				PullRange:Set[25]
			}
		}

		SettingXML[${charfile}]:Save
	}

	method Init_Config()
	{
		bind EndBot ${endbot} "Script[EQ2Bot]:End"
		spellfile:Set[${mainpath}EQ2Bot/Spell List/${Me.SubClass}.xml]
		This:CheckSpells[${Me.SubClass}]
		Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
		Event[EQ2_onLootWindowAppeared]:AttachAtom[LootWdw]
	}

	method CheckSpells(string class)
	{
		variable int keycount
		variable int templvl=1
		variable string tempnme
		variable int tempvar=1
		variable string spellname

		keycount:Set[${SettingXML[${spellfile}].Set[${class}].Keys}]
		do
		{
			tempnme:Set["${SettingXML[${spellfile}].Set[${class}].Key[${tempvar}]}"]

			templvl:Set[${Arg[1,${tempnme}]}]

			if ${templvl}>${Me.Level}
			{
				return
			}

			spellname:Set[${SettingXML[${spellfile}].Set[${class}].GetString["${tempnme}"]}]
			if !${Me.Ability[${spellname}](exists)} && ${spellname.Length}
			{
				echo Are you missing spell: ${spellname}
			}

			SpellType[${Arg[2,${tempnme}]}]:Set[${spellname}]
		}
		while ${tempvar:Inc}<=${keycount}
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
		variable int tempvar=1

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
						if ${Me.Raid[${tempgrp}].MaxHealth}>${highesthp}
						{
							highesthp:Set[${Me.Raid[${tempgrp}].MaxHealth}]
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
		variable int tempvar=1

		if !${CheckPriestPower}
		{
			return TRUE
		}

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

	method SetBadActor(string badactorid)
	{
		variable int tempvar=0

		tempvar:Set[0]

		if !${BadActor[50]}
		{
			while ${tempvar:Inc}<=50
			{
				if !${BadActor[${tempvar}]}
				{
					BadActor[${tempvar}]:Set[${badactorid}]
					return
				}
			}
		}
		else
		{
			while ${tempvar:Inc}<=50
			{
				BadActor[${tempvar}]:Set[0]
			}
		}

		BadActor[1]:Set[${badactorid}]
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
			echo New Zone Created!
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
				{
					UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetTextColor[FF22FF22]:AddItem[${POIList[${Index}]} (INCLUDED)]
				}
				else
				{
					UIElement[POI List@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetTextColor[FFFF0000]:AddItem[${POIList[${Index}]} (EXCLUDED)]
				}
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
			{
				UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to continue creating Pull Regions]
			}
			else
			{
				UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to create a new Camp and begin pathing]
			}
		}
		else
		{
			UIElement[Warning Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			UIElement[Camp Count@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			UIElement[Pull Count@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide

			if ${LNavRegionGroup[Start].RegionsWithin[StartRegion,99999,${Me.X},${Me.Z},${Me.Y}]}
			{
				if !${IsFinish}
				{
					UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to continue creating Regions]
				}

				if !${StartNav} && !${LNavRegionGroup[Start].Contains[${This.CurrentRegion}]}
				{
					UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
				}
				else
				{
					UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
				}
			}
			else
			{
				UIElement[Start Text@Navigation@EQ2Bot Tabs@EQ2 Bot]:SetText[Click Start Pather to create a new Start location and begin pathing]
				UIElement[Move Start@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
			}
		}

		if !${StartNav} && ${RegionCount}>0
		{
			UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Show
		}
		else
		{
			UIElement[Clear Path@Navigation@EQ2Bot Tabs@EQ2 Bot]:Hide
		}
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
		{
			LNavRegionGroup[${name}]:Add[${This.CurrentRegion}]
		}
	}

	member:bool ShouldConnect(lnavregionref regionA, lnavregionref regionB)
	{
  	if ${regionA.ID}==${regionB.ID}
		{
			return FALSE
		}

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
		{
			LNavRegion[${LNavRegion[${name}].Parent.Name}]:Connect[${name}]
		}

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
		{
			return TRUE
		}

		return FALSE
	}

	member:lnavregionref FindClosestRegion(float x, float y, float z)
	{
		variable lnavregionref Container

		Container:SetRegion[${This.CurrentRegion.BestContainer[${x},${y},${z}]}]

		if !${Container.Type.Equal[Universe]}
		{
			return ${Container}
		}

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
		{
			press -release ${forward}
		}

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
		{
			press -release ${forward}
		}

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
		{
			EQ2Nav:AutoBox[Start]
		}

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
		return
	}

	if ${ChoiceWindow.Text.Find[thoughtstone]}
	{
		ChoiceWindow:DoChoice1
		return
	}

	if ${ChoiceWindow.Text.Find[Lore]} || ${ChoiceWindow.Text.Find[No-Trade]} && ${Me.ToActor.Health}>1
	{
		if ${LootConfirm}
		{
			ChoiceWindow:DoChoice1
		}
		elseif !${LootMethod.Equal[Idle]}
		{
			ChoiceWindow:DoChoice2
		}
	}
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
	SettingXML[${charfile}]:Unload
	SettingXML[${spellfile}]:Unload

	ui -unload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/eq2bot.xml"

	if ${Following}
	{
		FollowTask:Set[0]
	}

	squelch bind -delete EndBot

	DeleteVariable CurrentTask

	Event[EQ2_onChoiceWindowAppeared]:DetachAtom[EQ2_onChoiceWindowAppeared]
	Event[EQ2_onLootWindowAppeared]:DetachAtom[LootWdw]

	press -release ${forward}
	press -release ${backward}
	press -release ${strafeleft}
	press -release ${straferight}
}
