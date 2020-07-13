;*************************************************************
;Warlock.iss
;version 20090622a
;by Pygar
;
;20200528
;	Fixes and Updates by Amadeus
;
;20090622
;	Updated for TSO and GU52
;
;20080415a
; DPS Tweaks
;
;20071004a
; Weaponswap entirely removed
; DebuffMode Added
; DotMode Added
; Significant dps tweeks
;
;20061012a
; Initial Build
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


;; in terms of single target priority it should be something like aura of pain > apoc > dark pyre > acid > dark siphoning > distortion > encase > abso > cataclysm


function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20200528
	;;;;

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare DebuffMode bool script FALSE
	declare DoTMode bool script TRUE
	declare BuffTank bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffVenemousProc collection:string script
	declare BuffBoon bool script FALSE
	declare BuffPact bool script FALSE
	declare PetMode bool script 1
	declare CastCures bool script FALSE
	declare StartHO bool script FALSE
	declare FocusMode bool script TRUE
	declare PetForm int script 1
	declare WarlockDebugMode bool script FALSE
	declare BuffVenemousProcOnSet bool script FALSE
	declare CheckHealsTimer uint script 0

	;Custom Equipment
	declare PoisonCureItem string script

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	DoTMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast DoT Spells,TRUE]}]
	BuffTank:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Tank,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffBoon:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffBoon,,FALSE]}]
	BuffPact:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffPact,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	CastCures:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Cures,TRUE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	FocusMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Focused Casting,TRUE]}]
	PetForm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PetForm,]}]

	;; Set these to TRUE, as desired, for testing
	;Debug:Enable
	;WarlockDebugMode:Set[TRUE]
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

	;; check this at least every 1 seconds
	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+1000]})
	{
		; check heals/cures
		call CheckHeals

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following routines are only called once.  They just need to wait until specific conditions have occurred
	;;;;;;
	;; Wait to populate Grasp of Bertoxxulous buffs listbox until after in a group of at least 3.  (Can be manually updated any time via UI.)
	if (!${BuffVenemousProcOnSet} && (${Me.Group} > 2 || ${Me.Raid} > 2))
	{
		BuffVenemousProcOnSet:Set[TRUE]
		Script[EQ2Bot].VariableScope.EQ2Bot:RefreshList["lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot",BuffVenemousProc,1,1,0]
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff1]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Self_Buff2]
	PreSpellRange[2,1]:Set[27]

	;; Aspect of Darkness
	PreAction[3]:Set[BuffBoon]
	PreSpellRange[3,1]:Set[21]

	;; Dark Pact
	PreAction[4]:Set[BuffPact]
	PreSpellRange[4,1]:Set[20]

	PreAction[5]:Set[Tank_Buff1]
	PreSpellRange[5,1]:Set[40]

	PreAction[6]:Set[Tank_Buff2]
	PreSpellRange[6,1]:Set[41]

	PreAction[7]:Set[Melee_Buff]
	PreSpellRange[7,1]:Set[31]

	PreAction[8]:Set[SeeInvis]
	PreSpellRange[8,1]:Set[30]

	PreAction[9]:Set[AA_Ward_Sages]
	PreSpellRange[9,1]:Set[386]

	PreAction[10]:Set[AA_Pet1]
	PreSpellRange[10,1]:Set[382]

	PreAction[11]:Set[AA_Pet2]
	PreSpellRange[11,1]:Set[383]

	PreAction[12]:Set[AA_Pet3]
	PreSpellRange[12,1]:Set[384]

	PreAction[13]:Set[DeityPet]

	PreAction[14]:Set[Propagation]
	PreSpellRange[14,1]:Set[391]

}

function Combat_Init()
{
}

function PostCombat_Init()
{

	PostAction[1]:Set[AutoFollowTank]
	avoidhate:Set[FALSE]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	call CheckHeals
	call RefreshPower

	;echo "\at<Warlock-Buff_Routine>\ao ${xAction}"

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff1
		case Self_Buff2
			if ((!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}) && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case BuffBoon
			if ${BuffBoon}
			{
				if ((!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}) && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffPact
			if ${BuffPact}
			{
				if ((!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}) && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Tank_Buff1
		case Tank_Buff2
			BuffTarget:Set[${UIElement[cbBuffTankGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if (!${BuffTank} || !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}]:Cancel
				}
			}
			else
			{
				if ${BuffTank}
				{
					if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					}
				}
				else
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
			}
			break
		case Melee_Buff
			;;;;;
			;; TODO:   This routine works perfectly, but should probably be rewritten to be more efficient
			;;;;;
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}

			}
			while ${Counter:Inc}<=${Me.CountMaintained}

			Counter:Set[1]
			variable int Counter2 = 1
			variable bool Continue = TRUE
			variable uint BuffTargetID = 0
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					Continue:Set[TRUE]
					BuffTarget:Set[${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					BuffTargetID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}]
					;echo "BuffTarget: '${BuffTarget}' -- BuffTargetID: '${BuffTargetID}'"
					do
					{
						if ${Me.Maintained[${Counter2}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
						{
							;echo "Buff.${Counter2} Target is '${Me.Maintained[${Counter2}].Target.Name}'"
							;;; For some strange reason, checking Target.ID against BuffTargetID isn't always reliable -- but checking both ID and Name seems to do the trick
							if (${Me.Maintained[${Counter2}].Target.ID}==${BuffTargetID} || ${Me.Maintained[${Counter2}].Target.Name.Equal[${BuffTarget}]})
							{
								Continue:Set[FALSE]
								;echo "Continue is FALSE"
								break
							}
						}
					}
					while ${Counter2:Inc}<=${Me.CountMaintained}

					if (${Continue})
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${BuffTargetID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case SeeInvis
			if ${BuffSeeInvis}
			{
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}

				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ID}
					}

				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case AA_Ward_Sages
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && (!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}))
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case AA_Pet1
		case AA_Pet2
		case AA_Pet3
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				{
					if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
						call CastSpellRange ${PreSpellRange[${xAction},${PetForm}]}
				}
			}
			break
		case DeityPet
			call SummonDeityPet
			break
		case Propagation
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && (!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}))
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
		if ${WarlockDebugMode}
			Debug:Echo["\atWarlock:_CastSpellRange(${SpellType[${start}]})\ax Verifying Target - ${TargetID} '${Actor[${TargetID}].Name}''"]
		call VerifyTarget ${TargetID} "Warlock-_CastSpellRange-${SpellType[${start}]} (1)"
		if ${Return.Equal[FALSE]}
			return CombatComplete
	}
	else
	{
		if (${Me.InCombat} && ${KillTarget} > 0)
		{
			if ${WarlockDebugMode}
				Debug:Echo["\atWarlock:_CastSpellRange(${SpellType[${start}]})\ax Verifying KillTarget - ${KillTarget} '${Actor[${KillTarget}].Name}''"]
			call VerifyTarget ${KillTarget} "Warlock-_CastSpellRange-${SpellType[${start}]} (2)"
			if ${Return.Equal[FALSE]}
				return CombatComplete
		}
	}

	;; Cast the spell we wanted to cast originally before doing anything else
	if ${WarlockDebugMode}
		Debug:Echo["\atWarlock:_CastSpellRange(${SpellType[${start}]})\ax Casting ${SpellType[${start}]}..."]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	iReturn:Set[${Int[${Return}]}]

	if (${DoNoCombat})
		return ${iReturn}
		
	if ${DoCallCheckPosition}
	{
		TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
		if ${WarlockDebugMode}
			Debug:Echo["_CastSpellRange()::TankToTargetDistance: ${TankToTargetDistance}"]

		if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
		{
			if ${MainTank}
				call CheckPosition 1 0
			else
			{
				if (${TankToTargetDistance} <= 7.5)
				{
					if ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed}
						call CheckPosition 1 1
					else
						call CheckPosition 1 0
				}
			}
		}
		elseif (${Actor[${MainTankID}].Name(exists)} && ${Actor[${MainTankID}].Distance} > 20)
		{
			if ${WarlockDebugMode}
				Debug:Echo["_CastSpellRange():: Out of Range - Moving to within 20m of tank"]
			call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 20 1 1
		}
		DoCallCheckPosition:Set[FALSE]
	}

	return ${iReturn}
}

function Combat_Routine(int xAction)
{
	variable int TargetDifficulty 
	variable bool TargetIsEpic = FALSE
	variable bool TargetIsNamed = FALSE
	variable int EncounterSize
	variable int WaitCounter = 0
	
	if ${WarlockDebugMode}
		Debug:Echo["Combat_Routine(${xAction}) called"]

	if (!${Actor[${KillTarget}].Name(exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0 || ${KillTarget} == 0)
	{
		if ${WarlockDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [1]"]
		return CombatComplete
	}

	if ${InPostDeathRoutine} || ${CheckingBuffsOnce}
	{
		if ${WarlockDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (In PostDeathRoutine or CheckingBuffsOnce) [2]"]
		return
	}

	if (${Actor[${KillTarget}].IsEpic} > 0)
		TargetIsEpic:Set[TRUE]
	if (${Actor[${KillTarget}].IsNamed})
		TargetIsNamed:Set[TRUE]
	TargetDifficulty:Set[${Actor[${KillTarget}].Difficulty}]
	if (${TargetIsEpic} && ${TargetDifficulty} < 3)
		TargetDifficulty:Set[3]
	EncounterSize:Set[${Actor[${KillTarget}].EncounterSize}]

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		if ${WarlockDebugMode}
			Debug:Echo["Combat_Routine() -- Stopping autofollow"]		
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoHOs}
		objHeroicOp:DoHO

	if ${StartHO} && !${EQ2.HOWindowActive} && ${Me.InCombat} && ${Me.Ability[${SpellType[303]}].IsReady}
		Me.Ability[${SpellType[303]}]:Use

	call CheckHeals

	;; Dark Siphoning, etc.
	call RefreshPower
	if (${Return.Equal[CombatComplete]})
		return CombatComplete

	;;;;;;;;;;;;;;;;;;;
	;; This Combat_Routine now works as a "prioritized list" of abilities rather than a sequence of abilities.
	;; The function will continue until it comes across an ability that is ready and for which the conditions
	;; are appropriate.
	;;;;;;;;;;;;;;;;;;;

	;; Gift of Bertoxxulous
	if (${Me.Ability[${SpellType[330]}].IsReady})
	{
		if (${TargetIsEpic} || ${Actor[${KillTarget}].Health} >= 30)
		{
			call _CastSpellRange 330 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;---- Netherealm
	if (${Me.Ability[${SpellType[55]}].IsReady} && !${Me.Maintained[${SpellType[55]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${Me.Group} <= 1)
		{
			if (${TargetIsEpic} || ${Actor[${KillTarget}].Health} >= 40)
			{
				call _CastSpellRange 55
				if ${Return.Equal[CombatComplete]}
				{
					if ${WarlockDebugMode}
						Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				else
					return
			}
		}
	}
	;; Curse of Darkness 
	if (${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)})
	{
		if (${TargetIsEpic} || ${Actor[${KillTarget}].Health} >= 45)
		{
			if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1)
			{
				call _CastSpellRange 52 0 0 0 ${KillTarget}
				if ${Return.Equal[CombatComplete]}
				{
					if ${WarlockDebugMode}
						Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				else
					return
			}
		}
	}

	;;;;
	;; TODO:   Add option on UI for toggling the use of this ability on/off.  The Range is just SO big that it's dangerous in difficult dungeons.
	;-------- Concussive Blast (AA) (AoE)
	;if (${PBAoEMode} && ${Me.Ability[${SpellType[393]}].IsReady})
	;{
	;	if (${TargetIsEpic} || ${TargetIsNamed} || ${Mob.Count[12]} > 1)
	;	{
	;		call _CastSpellRange 393 0 0 0 ${KillTarget}
	;		if ${Return.Equal[CombatComplete]}
	;		{
	;			if ${WarlockDebugMode}
	;				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
	;			return CombatComplete						
	;		}
	;		else
	;			return
	;	}
	;}


	;; Vacuum Field
	if (${DebuffMode} && ${Me.Ability[${SpellType[57]}].IsReady} && !${Me.Maintained[${SpellType[57]}](exists)})
	{
		if (${TargetIsEpic} || ${Actor[${KillTarget}].Health} >= 45)
		{
			if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1)
			{
				call _CastSpellRange 57 0 0 0 ${KillTarget}
				if ${Return.Equal[CombatComplete]}
				{
					if ${WarlockDebugMode}
						Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				else
					return
			}
		}
	}
	;--- "Focused Casting" AA
	if ${FocusMode} && ${TargetDifficulty} >= 3 && ${Me.Ability[${SpellType[387]}].IsReady}
	{
		call _CastSpellRange 387
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
		else
			return
	}
	;-------- Cataclysm
	if (${PBAoEMode} && ${Me.Ability[${SpellType[95]}].IsReady} && !${Me.Maintained[${SpellType[95]}](exists)})
	{
		if (${EncounterSize} > 1 || ${Mob.Count[12]} > 1)
		{
			call _CastSpellRange 95 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Apocalypse
	if (${Me.Ability[${SpellType[94]}].IsReady} && !${Me.Maintained[${SpellType[94]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1)
		{
			;; Use Catalyst and Freehand Sorcery before Apocalypse.   Both have the same recast timer, so should only need to check if Catalyst is ready.
			if (${Me.Ability[${SpellType[398]}].IsReady})
			{
				if ${Me.CastingSpell}
				{
					do
					{
						eq2execute /cancel_spellcast
						wait 3
					}
					while ${Me.CastingSpell}
				}
				wait 2
				eq2execute /useability ${SpellType[398]}
				wait 3
				eq2execute /useability ${SpellType[385]}
				wait 3
				if (${Me.Ability[${SpellType[398]}].IsReady} || ${Me.Ability[${SpellType[385]}].IsReady})
				{
					if ${Me.CastingSpell}
					{
						do
						{
							eq2execute /cancel_spellcast
							wait 3
						}
						while ${Me.CastingSpell}
					}
					wait 2
					eq2execute /useability ${SpellType[398]}
					wait 3
					eq2execute /useability ${SpellType[385]}
					wait 3
				}
			}
			call _CastSpellRange 94 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Absolution
	if (${Me.Ability[${SpellType[91]}].IsReady} && !${Me.Maintained[${SpellType[91]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1)
		{
			call _CastSpellRange 91 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Rift
	if (${PBAoEMode} && ${Me.Ability[${SpellType[96]}].IsReady} && !${Me.Maintained[${SpellType[96]}](exists)})
	{
		if (${TargetIsEpic} || ${TargetIsNamed} || ${Mob.Count[15]} > 1)
		{
			call _CastSpellRange 96 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Dark Nebula
	if (${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1)
		{
			call _CastSpellRange 92 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Aura of Void
	if (${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)} && ${TargetDifficulty} >= 3)
	{
		call _CastSpellRange 50 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		} 
		else
			return
	}
	;-------- Acid
	if (${DotMode} && ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[72]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1 || ${Actor[${KillTarget}].Health} > 20)
		{
			call _CastSpellRange 72 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Dark Pyre
	if (${DotMode} && ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1 || ${Actor[${KillTarget}].Health} > 20) 
		{
			call _CastSpellRange 71 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Distortion (single target dmg)
	if (${Me.Ability[${SpellType[61]}].IsReady})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1 || ${Actor[${KillTarget}].Health} > 5)
		{
			call _CastSpellRange 61 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Netherlord
	if (${DotMode} && ${Me.Ability[${SpellType[324]}].IsReady} && !${Me.Maintained[${SpellType[324]}](exists)})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1 || ${Actor[${KillTarget}].Health} > 20)
		{
			call _CastSpellRange 324 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Encase (single target dmg)
	if (${Me.Ability[${SpellType[62]}].IsReady})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1 || ${Actor[${KillTarget}].Health} > 5)
		{
			call _CastSpellRange 62 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Absolution (encounter dmg)
	if (${Me.Ability[${SpellType[91]}].IsReady})
	{
		if (${TargetDifficulty} >= 3 || ${EncounterSize} > 1 || ${Actor[${KillTarget}].Health} > 50)
		{
			call _CastSpellRange 91 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${WarlockDebugMode}
					Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}
	;-------- Master's Strike
	if (${Me.Ability[id,1410230263].IsReady})
	{
		if (${TargetDifficulty} >= 3 || ${Actor[${KillTarget}].Health} >= 20)
		{
			call VerifyTarget ${KillTarget} "Warlock-Combat_Routine-MastersStrike"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange AbilityID=1410230263 TargetID=${KillTarget} IgnoreMaintained=1
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atWarlock:Combat_Routine()\ax - Exiting after casting Master's Strike (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
			else
				return
		}
	}

	;;;;;;;;;;;;;
	;; Spells/Abilities not currently used in rotation:
	;; 1. Curse of Void          --  DebuffMode -> ${SpellType[51]}  (check Maintained)
	;; 2. Volatility             --  DebuffMode -> ${SpellType[389]} (check Maintained)        **** AA ABILITY (not chosen [yet]) ****
	;;
	;; 3. Nullify                --  DPS Utility Spell -> ${SpellType[181]}
	;;
	;; 4. Acid Storm             --  PBAoEMode -> ${SpellType[97]}                             **** STARTS AT LEVEL 80 ****
	;; 5. Static Discharge       --  PBAoEMode -> ${SpellType[397]}                            **** AA ABILITY (not chosen [yet]) ****
	;;
	;; 6. Dark Infestation       --  DoTMode -> ${SpellType[70]}
	;;
	;; 7. Plaguebringer          --  (single target dmg) -> ${SpellType[401]}                  **** AA ABILITY (not chosen [yet]) ****
	;; 8. Flames of Velious      --  (single target dmg) -> ${SpellType[64]}
	;; 9. Arcane Bewilderment   --  (single target dmg and threat dump) -> ${SpellType[403]}  **** AA ABILITY (not chosen [yet]) ****
	;; 10. Thunderclap           --  (single target dmg) -> ${SpellType[402]}                  **** AA ABILITY (not chosen [yet]) ****
	;; 11. Dissolve              --  (single target dmg) -> ${SpellType[63]}
	;;;;;;;;;;;;;

	return
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	if ${Me.Maintained[${SpellType[387]}](exists)}
		Me.Maintained[${SpellType[387]}]:Cancel

	switch ${PostAction[${xAction}]}
	{
        case AutoFollowTank
         	if ${AutoFollowMode}
         	{
         		ExecuteAtom AutoFollowTank
         	}
         	break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC} ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if ${Me.Ability[${SpellRange[328]}].IsReady}
	{
		call _CastSpellRange 328 0 0 0 ${Actor[${aggroid}].ID}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
		return
	}

	if ${Me.Ability[${SpellRange[181]}].IsReady}
	{
		call _CastSpellRange 180 0 0 0 ${Actor[${aggroid}].ID}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}
	else
	{
		call _CastSpellRange 181 0 0 0 ${Actor[${aggroid}].ID}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}

	if ${Me.Ability[${SpellRange[231]}].IsReady}
	{
		call _CastSpellRange 231 0 0 0 ${Actor[${aggroid}].ID}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}
	else
	{
		call _CastSpellRange 230 0 0 0 ${Actor[${aggroid}].ID}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
		press -hold ${backward}
		wait 3
		press -release ${backward}
		avoidhate:Set[TRUE]
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

function RefreshPower()
{
	variable int CurrentPowerPercent = ${Me.Power}

	if ${ShardMode}
		call Shard

	if (${CurrentPowerPercent} < 15 && ${Me.Ability[${SpellType[309]}].IsReady})
	{
		call CastSpellRange 309
	}

	if (${CurrentPowerPercent} < 60 && ${Me.Ability[${SpellType[56]}].IsReady})
	{
		call _CastSpellRange 56 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${WarlockDebugMode}
				Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}

	return
}

function CheckHeals()
{
	;; Call this function a maximum of one time each second while in combat mode.  Otherwise, a maximum of once every 5 seconds.
	if (${CheckHealsTimer} > 0)
	{
		if (${Me.InCombatMode})
		{
			if (${Time.SecondsSinceMidnight} <= ${Math.Calc[${CheckHealsTimer}+1]})
				return FALSE
		}
		else
		{
			if (${Time.SecondsSinceMidnight} <= ${Math.Calc[${CheckHealsTimer}+5]})
				return FALSE
		}
	}

	variable int temphl = 0
	variable bool DoCures
	variable bool bReturn
	bReturn:Set[FALSE]
	
	if ${CastCures} || ${EpicMode}
		DoCures:Set[TRUE]
	else
		DoCures:Set[FALSE]

	if (${DoCures} && ${Me.Ability[${SpellType[213]}].IsReady})
	{
		if (${Me.InCombatMode})
			echo "[${Time.SecondsSinceMidnight}]\ao Checking for Cures\ax"
		;;;;;;;;;;;;;
		;; Cure Magic
		do
		{
			if (${Me.Group[${temphl}].InZone} && !${Me.Group[${temphl}].IsDead})
			{
				if (${Me.InCombatMode})
					echo "[${Time.SecondsSinceMidnight}]\ao - Checking \ax\at${Me.Group[${temphl}].Name} (${Me.Group[${temphl}].Arcane}, ${Me.Group[${temphl}].Elemental}, ${Me.Group[${temphl}].Noxious}, ${Me.Group[${temphl}].Trauma})\ax"
				if (${Me.Group[${temphl}].Arcane} >= 1 || ${Me.Group[${temphl}].Elemental} >= 1 || ${Me.Group[${temphl}].Noxious} >= 1 || ${Me.Group[${temphl}].Trauma} >= 1)
				{
					if (${Me.InCombatMode})
						echo "[${Time.SecondsSinceMidnight}]\ay -- Curing ${Me.Group[${temphl}].Name}!\ax"
					
					call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}
					bReturn:Set[TRUE]
					wait 1

					if (${Actor[${KillTarget}].Name(exists)} && !${Actor[${KillTarget}].IsDead})
						Target ${KillTarget}
					break
				}
			}
		}
		while ${temphl:Inc} <= ${Me.Group}
	}
	CheckHealsTimer:Set[${Time.SecondsSinceMidnight}]
	return ${bReturn}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed
	CheckHealsTimer:Set[0]
	return
}