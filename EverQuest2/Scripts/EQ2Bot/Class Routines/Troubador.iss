;*****************************************************
;Troubador.iss 20090619a
;by Pygar
;
;Significant updates/fixes/etc. by Amadeus in May 2020
;
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20200528
  ;;;;

	declare OffenseMode bool script 1
	declare DebuffMode bool script 0
	declare DebuffMitMode bool script 1
	declare FullDebuffNamed bool script 1
	declare AoEMode bool script 0
	declare MezzMode bool script 0
	declare BowAttacksMode bool script 0
	declare RangedAttackMode bool script 0

	declare BuffDefense bool script FALSE
	declare BuffPower bool script FALSE
	declare BuffArcane bool script FALSE
	declare BuffElemental bool script FALSE
	declare BuffHaste bool script FALSE
	declare BuffHealth bool script FALSE
	declare BuffReflection bool script FALSE
	declare BuffAria bool script FALSE
	declare BuffStats bool script FALSE
	declare BuffCasting bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffSelf bool script FALSE
	declare BuffDKTM bool script FALSE
	declare BuffDexSonata bool script FALSE
	declare Charm bool script FALSE
	declare JestersCapRotationListBoxSet bool script FALSE
	declare TroubDebugMode bool script FALSE

	;Initialized by UI
	declare BuffJesterCapTimers collection:int script
	declare BuffJesterCapIterator iterator script
	declare BuffJesterCapMember int script 1

	declare mezTarget1 int script
	declare mezTarget2 int script
	declare CharmTarget int script
	declare BuffTarget string script

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	DebuffMitMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Mit Debuff Spells,TRUE]}]
	FullDebuffNamedMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Named Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	Charm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Charm,FALSE]}]
	BowAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]

	BuffDefense:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Defense","FALSE"]}]
	BuffPower:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Power","FALSE"]}]
	BuffArcane:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Arcane","FALSE"]}]
	BuffElemental:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Elemental","FALSE"]}]
	BuffHaste:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Haste","FALSE"]}]
	BuffHealth:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Health","FALSE"]}]
	BuffReflection:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Reflection","FALSE"]}]
	BuffAria:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Aria","FALSE"]}]
	BuffStats:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Stats","FALSE"]}]
	BuffCasting:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Casting","FALSE"]}]
	BuffHate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Hate","FALSE"]}]
	BuffSelf:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Self","FALSE"]}]
	BuffDKTM:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff DKTM","FALSE"]}]
	BuffDexSonata:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff DexSonata","FALSE"]}]

	PosionCureItem:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Poison Cure Item","Antivenom Hypo Bracer"]}]
	BuffJesterCap:GetIterator[BuffJesterCapIterator]

	;; Set these to TRUE, as desired, for testing
	;Debug:Enable
	;TroubDebugMode:Set[TRUE]
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	if (${StartBot} && ${DoNoCombat})
		return

	;; check this at least every 0.5 seconds
	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
		{
			call CastSpellRange 388
			wait 5
			if ${Me.Maintained[${SpellType[388]}](exists)}
			{
				eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
				BDStatus:Set[0]
			}
		}

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following routines are only called once.  They just need to wait until specific conditions have occurred
	;;;;;;
	;; Wait to populate "Jester's Cap" listbox until after in a group of at least 3.  (Can be manually updated any time via UI.)
	if (!${JestersCapRotationListBoxSet} && (${Me.Group} > 2 || ${Me.Raid} > 2))
	{
		JestersCapRotationListBoxSet:Set[TRUE]
		Script[EQ2Bot].VariableScope.EQ2Bot:RefreshList["lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot",BuffJesterCap,1,0,1]
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Buff_AAAllegro]
	PreSpellRange[1,1]:Set[390]

	;; Graceful Avoidance
	PreAction[2]:Set[Buff_Defense]
	PreSpellRange[2,1]:Set[31]

	;; Bria's Inspiring Ballad
	PreAction[3]:Set[Buff_Power]
	PreSpellRange[3,1]:Set[21]

	PreAction[4]:Set[Buff_AADontKillTheMessenger]
	PreSpellRange[4,1]:Set[395]

	PreAction[5]:Set[Buff_AAHarmonization]
	PreSpellRange[5,1]:Set[383]

	PreAction[6]:Set[Buff_AAResonance]
	PreSpellRange[6,1]:Set[382]

	PreAction[7]:Set[Selos]
	PreSpellRange[7,1]:Set[381]

	;; Requiem of Reflection
	PreAction[8]:Set[Buff_Reflection]
	PreSpellRange[8,1]:Set[26]

	;; Aria of Magic
	PreAction[9]:Set[Buff_Aria]
	PreSpellRange[9,1]:Set[27]

	;; Raxxyl's Rousing Tune
	PreAction[10]:Set[Buff_Stats]
	PreSpellRange[10,1]:Set[28]

	;; Song of Magic
	PreAction[11]:Set[Buff_Casting]
	PreSpellRange[11,1]:Set[29]

	PreAction[12]:Set[Buff_AAHeroicStoryTelling]
	PreSpellRange[12,1]:Set[404]

	;; Alin's Serene Serenade
	PreAction[13]:Set[Buff_Hate]
	PreSpellRange[13,1]:Set[30]

	;; Arcane Symphony
	PreAction[14]:Set[Buff_Arcane]
	PreSpellRange[14,1]:Set[22]

	;; Elemental Concerto 
	PreAction[15]:Set[Buff_Elemental]
	PreSpellRange[15,1]:Set[23]

	;; Allegretto
	PreAction[16]:Set[Buff_Haste]
	PreSpellRange[16,1]:Set[24]

	PreAction[17]:Set[Buff_AAFortissimo]
	PreSpellRange[17,1]:Set[398]

	;; Daelis' Dance of Blades
	PreAction[18]:Set[Buff_Self]
	PreSpellRange[18,1]:Set[20]

	PreAction[19]:Set[Buff_AADexSonata]
	PreSpellRange[19,1]:Set[403]

	PreAction[20]:Set[Buff_AAUpTempo]
	PreSpellRange[20,1]:Set[402]

	;; Rejuvenating Celebration
	PreAction[21]:Set[Buff_Health]
	PreSpellRange[21,1]:Set[25]
	
	PreAction[22]:Set[Mamba]
	PreSpellRange[22,1]:Set[410]

}

function Combat_Init()
{
}

function PostCombat_Init()
{
}

function Buff_Routine(int xAction)
{
	call ActionChecks
	call CheckHeals

	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}
	}

	switch ${PreAction[${xAction}]}
	{
		case Buff_AAUpTempo
			BuffTarget:Set[${UIElement[cbBuff_AAUpTempo@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2

			break
		case Buff_AADexSonata
			if ${BuffDexSonata}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Defense
			if ${BuffDefense}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Power
			if ${BuffPower}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Arcane
			if ${BuffArcane}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Elemental
			if ${BuffElemental}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Haste
			if ${BuffHaste}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Health
			if ${BuffHealth}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Reflection
			if ${BuffReflection}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Aria
			if ${BuffAria}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Stats
			if ${BuffStats}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Casting
			if ${BuffCasting}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Hate
			if ${BuffHate}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Self
			if ${BuffSelf}
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break

		case Buff_AAAllegro
		case Selos
		case Buff_AAHarmonization
		case Buff_AAFortissimo
		case Buff_AAResonance
		case Buff_AADontKillTheMessenger
		case Buff_AAHeroicStoryTelling
		case Mamba
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		Default
			return Buff Complete
			break
	}

}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, uint TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	variable float TankToTargetDistance
	variable int iReturn

	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;

	;; Check to make sure the target is valid FIRST and then use the ability this function was called for before anything else
	if (${TargetID} > 0 && ${TargetID} != ${Me.ID} && !${Actor[${TargetID}].Type.Equal[PC]})
	{
		call VerifyTarget ${TargetID} "Troubadour-_CastSpellRange-${SpellType[${start}]}"
		if ${Return.Equal[FALSE]}
			return CombatComplete
	}

	;; Cast the spell we wanted to cast originally before doing anything else
	if ${TroubDebugMode}
		Debug:Echo["\atTroubadour:_CastSpellRange()\ax -- Casting ${SpellType[${start}]}..."]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	iReturn:Set[${Int[${Return}]}]

	if (${DoNoCombat})
		return ${iReturn}
		
	;if ${DoCallCheckPosition}
	;{
	;	TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
	;	if ${TroubDebugMode}
	;		Debug:Echo["_CastSpellRange()::TankToTargetDistance: ${TankToTargetDistance}"]
;
	;	if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
	;	{
	;		if ${MainTank}
	;			call CheckPosition 1 0
	;		else
	;		{
	;			if (${TankToTargetDistance} <= 7.5)
	;			{
	;				if ${Actor[${KillTarget}].IsEpic}
	;					call CheckPosition 1 1
	;				else
	;					call CheckPosition 1 0
	;			}
	;		}
	;	}
	;	elseif (${Actor[${MainTankID}].Name(exists)} && ${Actor[${MainTankID}].Distance} > 20)
	;	{
	;		if ${TroubDebugMode}
	;			Debug:Echo["_CastSpellRange():: Out of Range - Moving to within 20m of tank"]
	;		call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 20 1 1
	;	}
	;	DoCallCheckPosition:Set[FALSE]
	;}

	return ${iReturn}
}

function Combat_Routine(int xAction)
{
	declare tempvar int local
	declare DebuffCnt int  0
	declare range int 0
	declare TankToTargetDistance float local
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[1]

	if ${TroubDebugMode}
		Debug:Echo["Combat_Routine(${xAction}) called"]

	if (!${Actor[${KillTarget}].Name(exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0 || ${KillTarget} == 0)
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [1]"]
		return CombatComplete
	}

	if ${InPostDeathRoutine} || ${CheckingBuffsOnce}
	{
		if ${TroubDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (In PostDeathRoutine or CheckingBuffsOnce) [2]"]
		return
	}

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		if ${TroubDebugMode}
			Debug:Echo["Combat_Routine() -- Stopping autofollow"]		
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${RangedAttackMode}
		range:Set[2]
	elseif ${BowAttacksMode}
		range:Set[3]

	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call VerifyTarget ${KillTarget} "Troubadour-Combat_Routine-BladeDance"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 388
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}
	}

	CurrentAction:Set[Combat Checking Power]
	call RefreshPower

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${DoHOs}
		call CastSpellRange 303

	if ${MezzMode}
		call Mezmerise_Targets

	if ${Charm}
		call DoCharm

	call PetAttack

	call DoJesterCap

	; PoTM
	if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[155]}](exists)} && ${Me.Ability[${SpellType[155]}].IsReady} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
	{
		call _CastSpellRange 155 0 ${range} 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 
		spellsused:Inc
	}

	call CheckHeals

	if (${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement})
	{
		if ${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]}
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine():: TankToTargetDistance: ${TankToTargetDistance}"]

			if ${MainTank}
				call CheckPosition 1 0 ${KillTarget} 0 0 "Troubadour-Combat_Routine()"
			else
			{
				if (${TankToTargetDistance} <= 10)
				{
					if ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed}
						call CheckPosition 1 1 ${KillTarget} 0 0 "Troubadour-Combat_Routine()"
					else
						call CheckPosition 1 0 ${KillTarget} 0 0 "Troubadour-Combat_Routine()"
				}
			}
		}
	}


	;if !${NoAutoMovementInCombat} || !${NoAutoMovement}
	;{
		;; TODO:  Use profiling to see if this might slow things down.   It shouldn't, but if it does, could change Position.GetMeleeMaxRange
		;;        to a constant value like 8
	;	if (${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]})
	;	{
	;		if (${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]} <= 10)
	;		{
	;			;; Note:  "call CheckPosition 1 1 ${KillTarget} 0 0" would put the Troubadour BEHIND the target.  The version below
	;			;;        simply moves the Troubadour within melee range of the target at any angle.
	;			call CheckPosition 1 0 ${KillTarget} 0 0 "Troubadour-Combat_Routine()"
	;		}
	;	}
	;}

  	;Rhythym Blade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[397]}].IsReady} && !${Me.Maintained[${SpellType[397]}](exists)}
	{
		call _CastSpellRange 397 0 1 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 		
		spellsused:Inc
	}

  	;Cadence of Destruction
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[406]}].IsReady} && !${Me.Maintained[${SpellType[406]}](exists)}
	{
		call VerifyTarget ${KillTarget} "Troubadour-Combat_Routine-CadenceOfDestruction"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 406	
		spellsused:Inc
	}
	
  	;Victorious Concerto
	if ${spellsused}<=${spellthreshold} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}) && ${Me.Ability[${SpellType[407]}].IsReady} && !${Me.Maintained[${SpellType[407]}](exists)}
	{
		call VerifyTarget ${KillTarget} "Troubadour-Combat_Routine-Victorious Concerto"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 407 
		spellsused:Inc
	}

  	;Rhythmic Overture
	if ${spellsused}<=${spellthreshold} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}) && ${Me.Ability[${SpellType[408]}].IsReady} && !${Me.Maintained[${SpellType[408]}](exists)}
	{
		call VerifyTarget ${KillTarget} "Troubadour-Combat_Routine-Rhythmic Overture"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 408 
		spellsused:Inc
	}

  	;Painful Lamentation
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)}
	{
		call _CastSpellRange 92 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

  	;Perfect Shrill
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady} && !${Me.Maintained[${SpellType[60]}](exists)}
	{
		call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

  	;Thunderous Overature
	if ${spellsused}<=${spellthreshold} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[61]}].IsReady} && !${Me.Maintained[${SpellType[61]}](exists)}
	{
		call _CastSpellRange 61 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

  	;reverberation
	if ${spellsused}<=${spellthreshold} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[405]}].IsReady} && !${Me.Maintained[${SpellType[405]}](exists)}
	{
		call _CastSpellRange 405 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

	if ${spellsused}<=${spellthreshold} && ${DebuffMitMode} || (${FullDebuffNamed} && ${Actor[ID,${KillTarget}].Type.Equal[NamedNPC]})
	{
		if !${Me.Maintained[${SpellType[57]}](exists)} && ${Me.Ability[${SpellType[57]}].IsReady}
		{
			call _CastSpellRange 57 0 ${range} 0 ${KillTarget} 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${TroubDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			} 				
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[51]}](exists)} && ${Me.Ability[${SpellType[51]}].IsReady} && !${RangedAttackMode}
		{
			call _CastSpellRange 51 0 1 0 ${KillTarget} 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${TroubDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			} 				
			spellsused:Inc
		}
	}

	if ${spellsused}<=${spellthreshold} && (${DebuffMode} || (${FullDebuffNamed} && ${Actor[ID,${KillTarget}].Type.Equal[NamedNPC]})
	{
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[55]}](exists)} && ${Me.Ability[${SpellType[55]}].IsReady}
		{
			call _CastSpellRange 55 0 ${range} 0 ${KillTarget} 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${TroubDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			} 				
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[56]}](exists)} && ${Me.Ability[${SpellType[56]}].IsReady}
		{
			call _CastSpellRange 56 0 ${range} 0 ${KillTarget} 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${TroubDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			} 				
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[58]}](exists)} && ${Me.Ability[${SpellType[58]}].IsReady}
		{
			call _CastSpellRange 58 0 ${range} 0 ${KillTarget} 0 0 0
			if ${Return.Equal[CombatComplete]}
			{
				if ${TroubDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			} 				
			spellsused:Inc
		}
	}

  	;Tap Essence
	if ${spellsused}<=${spellthreshold} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[62]}].IsReady} && !${Me.Maintained[${SpellType[62]}](exists)}
	{
		call _CastSpellRange 62 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

	call ActionChecks

	if ${DoHOs}
		objHeroicOp:DoHO

  	;Ceremonial Blade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady} && !${Me.Maintained[${SpellType[151]}](exists)}
	{
		call _CastSpellRange 151 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}

  	;Night Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[391]}].IsReady} && !${Me.Maintained[${SpellType[391]}](exists)}
	{
		;eq2execute useability Bump    ;; ??
		call _CastSpellRange 130 0 1 1 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}

	; Sinister Strike
	if (${spellsused}<=${spellthreshold} && ${Me.Ability[id,1142797896].IsReady} && ${Mob.CheckActor[${KillTarget}]} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 20))
	{
		call VerifyTarget ${KillTarget} "Troubadour-Combat_Routine-SinisterStrike"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		;call CheckPosition 1 1
		call CastSpellRange AbilityID=1142797896 TargetID=${KillTarget} IgnoreMaintained=1
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atTroubadour:Combat_Routine()\ax - Exiting after casting Sinister Strike (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}	
	}

  	;Evasive Manuevors
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[401]}].IsReady} && !${Me.Maintained[${SpellType[401]}](exists)}
	{
		call _CastSpellRange 401 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}

  	;Singing Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[250]}].IsReady} && !${Me.Maintained[${SpellType[250]}](exists)}
	{
		call _CastSpellRange 250 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}

  	;Turn Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[387]}].IsReady} && !${Me.Maintained[${SpellType[387]}](exists)}
	{
		call _CastSpellRange 387 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}

  	;Dancing Blade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[110]}].IsReady} && !${Me.Maintained[${SpellType[110]}](exists)}
	{
		call _CastSpellRange 110 0 1 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}

  	;Sandras Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady} && !${Me.Maintained[${SpellType[152]}](exists)}
	{
		call _CastSpellRange 152 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}
	
  	;Vexing Verses
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)}
	{
		call _CastSpellRange 50 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

  	;Mesenger
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[505]}].IsReady} && !${Me.Maintained[${SpellType[505]}](exists)}
	{
		call _CastSpellRange 505 0 0 0 ${KillTarget} 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${TroubDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 			
		spellsused:Inc
	}	

	return CombatComplete
}

function Post_Combat_Routine(int xAction)
{
	mezTarget1:Set[0]
	mezTarget2:Set[0]
	CharmTarget:Set[0]

	;turn off percisions of the maestro
	if ${Me.Maintained[${SpellType[155]}](exists)}
	{
		Me.Maintained[${SpellType[155]}]:Cancel
	}

	;cancel stealth
	if ${Me.Effect[Shroud](exists)} || ${Me.Maintained[Shroud](exists)}
	{
		Me.Maintained[Shroud]:Cancel
	}

	;reset rangedattack in case it was modified by joust call.
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}

}

function Have_Aggro()
{

	;if ${Me.AutoAttackOn}
	;{
	;	EQ2Execute /toggleautoattack
	;}

	;Cast evade if we get agro from the MT

	if ${agroid}==${KillTarget}
	{
		;evade
		call CastSpellRange 180 0 0 0 ${agroid}
	}

}

function RefreshPower()
{
	declare tempvar int local
	declare MemberLowestPower int local

	if ${Me.Power}<10 && ${Me.Health}>60 && ${Me.Inventory[${Manastone}](exists)} && ${Me.Inventory[${Manastone}].Location.Equal[Inventory]} && ${Me.Inventory[${Manastone}].IsReady}
		Me.Inventory[${Manastone}]:Use

	if ${ShardMode}
		call Shard 10

	;;;; Energizing Ballad
	if ${Me.Raid} && ${Me.Ability[${SpellType[409]}].IsReady}
	{
		tempvar:Set[0]
		MemberLowestPower:Set[0]
		
		do
		{
   		if ${Me.Raid[${tempvar}].InZone} && ${Me.Raid[${tempvar}].Health(exists)}
   		{
   		  if ${Me.Raid[${tempvar}].Name.NotEqual[${Me.Name}]}
   			{
					if ${Me.Raid[${tempvar}].Power}<25 && !${Me.Raid[${tempvar}].IsDead} && ${Me.Raid[${tempvar}].Distance}<=${Me.Ability[${SpellType[409]}].ToAbilityInfo.Range}
    			{
    				if (${Me.Raid[${tempvar}].Power} < ${Me.Raid[${MemberLowestPower}].Health}) || ${MemberLowestPower}==0
    					MemberLowestPower:Set[${tempvar}]
    			}   				
   			}
   		}		
		}
		while ${tempvar:Inc}<=24

		if ${Me.Raid[${MemberLowestPower}].InZone} && ${Me.Raid[${MemberLowestPower}].Distance}<30 && ${Me.Raid[${MemberLowestPower}].Health(exists)}
		{	
			call CastSpellRange 390 0 0 0 ${Me.Raid[${raidlowest}].ID}
			eq2execute em Energizing Ballad to ${Me.Raid[${MemberLowestPower}].Name}
		}
	}
	
	if ${Me.Grouped}
	{
		;Mana Flow the lowest group member
		tempvar:Set[1]
		MemberLowestPower:Set[0]
		do
		{
			if ${Me.Group[${tempvar}].Power}<25 && ${Me.Group[${tempvar}].Distance}<30 && ${Me.Group[${tempvar}].InZone} && ${Me.Group[${tempvar}].Power(exists)}
			{
				if ${Me.Group[${tempvar}].Power}<=${Me.Group[${MemberLowestPower}].Power}
					MemberLowestPower:Set[${tempvar}]
			}
		}
		while ${tempvar:Inc}<${Me.GroupCount}


		if ${Me.Group[${MemberLowestPower}].InZone} && ${Me.Group[${MemberLowestPower}].Power}<25 && ${Me.Group[${MemberLowestPower}].Distance}<30 && ${Me.Ability[${SpellType[409]}].IsReady} && ${Me.Group[${MemberLowestPower}].Power(exists)}
		{
			call CastSpellRange 409 0 0 0 ${Me.Group[${MemberLowestPower}].ID}	
			if ${Me.Group[${MemberLowestPower}].InZone}	&& ${Me.Group[${MemberLowestPower}].Power(exists)}
				eq2execute em Energizing Ballad to ${Me.Group[${MemberLowestPower}].Name}	
		}
	}
		
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{

}

function Cancel_Root()
{

}
function CheckHeals()
{
		call UseCrystallizedSpirit 60
}

function ActionChecks()
{
	if ${ShardMode}
	{
		call Shard
	}
}

function Mezmerise_Targets()
{
	variable index:actor Actors
	variable iterator ActorIterator
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]

	EQ2:QueryActors[Actors, Type =- "NPC" && Distance <= 15]
	Actors:GetIterator[ActorIterator]

	if ${ActorIterator:First(exists)}
	{
		do
		{
			if (${ActorIterator.Value.Name(exists)} && !${ActorIterator.Value.IsLocked} && !${ActorIterator.Value.IsEpic})
			{
				if ${ActorIterator.Value.ID}==${mezTarget1} || ${ActorIterator.Value.ID}==${mezTarget2} || ${Actor[${MainTankPC}].Target.ID}==${ActorIterator.Value.ID}
				{
					continue
				}

				if ${Mob.Target[${ActorIterator.Value.ID}]}
				{

					if ${Me.AutoAttackOn}
					{
						eq2execute /toggleautoattack
					}

					if ${Me.RangedAutoAttackOn}
					{
						eq2execute /togglerangedattack
					}

					;shut off aria so encounter debuffs dont break mezz
					;if ${Me.Maintained[${SpellType[27]}](exists)}
					;{
					;	Me.Maintained[${SpellType[27]}]:Cancel
					;}

					call CastSpellRange 352 0 0 0 ${ActorIterator.Value.ID} 0 15
				}
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	if ${Actor[${KillTarget}].Name(exists)} && !${Actor[${KillTarget}].IsDead} && ${Mob.Detect}
	{
		Target ${KillTarget}
		wait 20 ${Me.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
		KillTarget:Set[]
	}
}

function DoCharm()
{
	variable index:actor Actors
	variable iterator ActorIterator
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	if ${Me.Maintained[${SpellType[351]}](exists)}
	{
		return
	}

	grpcnt:Set[${Me.GroupCount}]

	EQ2:QueryActors[Actors, Type =- "NPC" && Distance <= 15]
	Actors:GetIterator[ActorIterator]

	if ${ActorIterator:First(exists)}
	{
		do
		{
			if (${ActorIterator.Value.Name(exists)} && !${ActorIterator.Value.IsLocked} && !${ActorIterator.Value.IsEpic})
			{
				if ${Actor[${MainAssist}].Target.ID}==${ActorIterator.Value.ID}
				{
					continue
				}

				if ${Mob.Target[${ActorIterator.Value.ID}]}
				{
					CharmTarget:Set[${ActorIterator.Value.ID}]
					break
				}
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	if ${Actor[${CharmTarget}].Name(exists)} && ${CharmTarget}!=${mezTarget1} && ${CharmTarget}!=${mezTarget2} && ${Actor[${MainAssist}].Target.ID}!=${CharmTarget} && ${aggrogrp}
	{
		call CastSpellRange 351 0 0 0 ${CharmTarget}

		if ${Actor[${KillTarget}].Name(exists)} && (${Me.Maintained[${SpellType[351]}].Target.ID}!=${KillTarget}) && ${Me.Maintained[${SpellType[351]}](exists)} && !${Actor[${KillTarget}].IsDead}
		{
			call PetAttack
		}
		else
		{
			EQ2Execute /target_none
		}
	}
}

function Cure()
{
}

function DoJesterCap()
{
	variable string JCActor=${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${BuffJesterCapMember}].Text}

	if !${Me.Ability[${SpellType[156]}].IsReady}
		return

	if ${Me.Maintained[${SpellType[156]}](exists)}
		return

	if ${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}==0
		return

	Me:RequestEffectsInfo

	;if I don't have potm on me, and it is ready, and I can be jcapped, jcap myself and cast potm
	if !${Me.Effect[beneficial,${SpellType[155]}](exists)} && ${Me.Ability[${SpellType[155]}].IsReady}
	{
		if ${Math.Calc[${Time.Timestamp} - ${BuffJesterCapTimers.Element[${Me.Name}]}]}>120
		{
			call CastSpellRange 156 0 0 0 ${Me.ID}

			BuffJesterCapTimers:Set[${Me.Name}, ${Time.Timestamp}]
			BuffJesterCapMember:Inc

			call CastSpellRange 155 0 0 0 ${Me.ID}
		}
		return
	}

	if ${Actor[${JCActor.Token[2,:]},${JCActor.Token[1,:]}].Distance}<${Position.GetSpellMaxRange[${TID},0,${Me.Ability[${SpellType[156]}].ToAbilityInfo.Range}]}
	{
		;Jester Cap immunity is 2 mins so make sure we havn't cast on this Actor in the past 120 seconds
		if ${Math.Calc[${Time.Timestamp} - ${BuffJesterCapTimers.Element[${JCActor}]}]}>120
		{
			EQ2Execute /useabilityonplayer ${JCActor.Token[1,:]} ${SpellType[156]}
			wait 5

			while ${Me.CastingSpell}
				wait 1

			if ${Me.Maintained[${SpellType[156]}](exists)}
			{
				eq2execute /tell ${JCActor.Token[1,:]} "You've been J-Capped!"
				;if we successfully cast Jester Cap, Add/Update the collection with the current timestamp
				BuffJesterCapTimers:Set[${JCActor}, ${Time.Timestamp}]
				BuffJesterCapMember:Inc
			}
		}
		else
		{
			;they still have immunity so advance to next
			BuffJesterCapMember:Inc
		}
	}
	else
	{
		;they are further than jester cap range so advance to next
		BuffJesterCapMember:Inc
	}

	;we have gone through everyone in the list so start back at the begining
	if ${BuffJesterCapMember}>${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
		BuffJesterCapMember:Set[1]

}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}