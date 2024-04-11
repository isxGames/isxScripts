;*************************************************************
; Fury
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20200507
	;;;;

	declare DebuffMode bool script
	declare AoEMode bool script
	declare CureMode bool script
	declare CureCurseSelfMode bool script 0
	declare CureCurseOthersMode bool script 0
	declare InfusionMode bool script
	declare KeepReactiveUp bool script
	declare BuffEel bool script 1
	declare MeleeAAAttacksMode bool script 0
	declare BuffThorns bool script 1
	declare VortexMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare KeepMTHOTUp bool script 0
	declare KeepGroupHOTUp bool script 0
	declare RaidHealMode bool script 0
	declare ShiftForm int script 1
	declare PactOfNature string script
	declare AnimalForm string script
	declare SpamHealMode bool script 0
	declare UseWrathOfNature bool script 0
	declare UseMythicalOn string script
	declare HaveAbility_TunaresGrace bool script FALSE
	declare HaveAbility_AnimalForm bool script FALSE
	declare MaxHealthModified int script 0
	declare CheckCuresTimer uint script 0

	declare VimBuffsOnSet bool script FALSE
	declare VimBuffsOn collection:string script
	declare BuffBatGroupMember string script
	declare BuffSavageryGroupMember string script
	declare CureCurseGroupMember string script
	declare BuffSpirit bool script FALSE
	declare BuffHunt bool script FALSE
	declare BuffMask bool script FALSE
	declare PrimaryHealer bool script TRUE
	declare FuryDebugMode bool script FALSE
	declare CastTortoiseShell bool script FALSE
	declare CastTortoiseShellCaller string script 

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init
	
	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Buffs]
	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[Buffs]:Move[4]
	ui -load -parent "Buffs@EQ2Bot Tabs@EQ2 Bot" -skin EQ2-Green "${PATH_UI}/${Me.SubClass}_Buffs.xml"
	
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	CureCurseSelfMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseSelfMode,FALSE]}]
	CureCurseOthersMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseOthersMode,FALSE]}]
	InfusionMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[InfusionMode,FALSE]}]
	MeleeAAAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MeleeAAAttacksMode,FALSE]}]
	BuffThorns:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Thorns,FALSE]}]
	VortexMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Vortex,FALSE]}]
	KeepReactiveUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepReactiveUp,FALSE]}]
	CombatRez:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Rez,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	KeepMTHOTUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepMTHOTUp,FALSE]}]
	KeepGroupHOTUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepGroupHOTUp,FALSE]}]
	RaidHealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Raid Heals,FALSE]}]
	UseWrathOfNature:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseWrathOfNature,FALSE]}]
	UseMythicalOn:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseMythicalOn,"No One"]}]
	PrimaryHealer:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PrimaryHealer,TRUE]}]

	BuffBatGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffBatGroupMember,]}]
	BuffSavageryGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSavageryGroupMember,]}]
	BuffSpirit:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSpirit,TRUE]}]
	BuffHunt:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHunt,TRUE]}]
	BuffMask:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMask,TRUE]}]
	BuffEel:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEel,FALSE]}]
	ShiftForm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ShiftForm,]}]
	PactOfNature:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PactOfNature,]}]
	AnimalForm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[AnimalForm,]}]
	SpamHealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[SpamHealMode,]}]
	CureCurseGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseGroupMember,]}]
	NoEQ2BotStance:Set[TRUE]
	CastTortoiseShellCaller:Set[""]

	Event[EQ2_FinishedZoning]:AttachAtom[Fury_FinishedZoning]
	
	;;; Optimizations to avoid having to check if an ability exists all of the time
	if (${Me.Ability[Tunare's Grace](exists)})
		HaveAbility_TunaresGrace:Set[TRUE]	
	if (${Me.Ability[Animal Form](exists)})
		HaveAbility_AnimalForm:Set[TRUE]
		
	;; If we're NOT the primary healer (based on the checkbox in the UI), then we don't need to heal as much
	if ${PrimaryHealer}
		MaxHealthModified:Set[100]
	else
		MaxHealthModified:Set[80]
		
	;; Set these to TRUE, as desired, for testing
	;Debug:Enable
	;FuryDebugMode:Set[TRUE]
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
	variable bool CastSpeedBuff = FALSE

	;; check this at least every 0.5 seconds, after bot has been started.
	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		if ${Actor[${MainTankID}].InCombatMode}
		{
			if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
			{
				;Debug:Echo["Pulse() -- Stopping autofollow"]		
				EQ2Execute /stopfollow
				AutoFollowingMA:Set[FALSE]
				waitframe
			}
		}

		call CheckCuresAndHeals

		if ${Me.Power}>85
			call CheckPreAndChainHOTs

		if (${Zone.Name.Find[Unrest]} > 0)
		{
			if (${Me.Speed} < 10 && !${Me.InCombat} && !${Me.InCombatMode})
			{
				call AmIInvis "Fury-Pulse()"
				if (${Return.Equal[FALSE]})
					CastSpeedBuff:Set[TRUE]
			}
		}
		else
		{
			;; (Note:  25 is with the Journeyman's Boots of Adventure, 35 is with HQ boots on top of that)
			if ((${Me.Speed} == 10 || ${Me.Speed} == 25 || ${Me.Speed} == 35) && !${Me.InCombat} && !${Me.InCombatMode})
			{
				call AmIInvis "Fury-Pulse()"
				if (${Return.Equal[FALSE]})
					CastSpeedBuff:Set[TRUE]
			}
		}

		if (${CastSpeedBuff})
			call SpiritOfTheWolf

		;;;; Use Tortoise Shell
		;; This variable is intended to be set by a 'controller' script.  In other words, the tank character might issue a command that would
		;; instigate the fury's "controller" script to set this variable to TRUE in order to have the fury cast Tortoise Shell immediately.  
		;; The syntax to use would be: 
		;;		Script[EQ2Bot].VariableScope.CastTortoiseShellCaller:Set[WHO_CALLED_NAME]    (if you want the script to send the player a /tell)
		;;		Script[EQ2Bot].VariableScope.CastTortoiseShell:Set[TRUE]
		;;		
		;; Note:  This will typically be handled in _CastSpellRange or Combat_Routine; it's included here primarily for testing and documentation
		;; purposes
		if (${CastTortoiseShell})
			call TortoiseShell

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following routines are only called once.  They just need to wait until specific conditions have occurred
	;;;;;;
	;; Wait to populate Lucidity buffs listbox until after in a group of at least 3.  (Can be manually updated any time via UI.)
	if (!${VimBuffsOnSet} && (${Me.Group} > 2 || ${Me.Raid} > 2))
	{
		VimBuffsOnSet:Set[TRUE]
		Script[EQ2Bot].VariableScope.EQ2Bot:RefreshList["lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot",BuffVim,1,1,0]
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}

function Class_Shutdown()
{
	Event[EQ2_FinishedZoning]:DetachAtom[Fury_FinishedZoning]
}

function Buff_Init()
{
	PreAction[1]:Set[DoCheckRezzes]

	PreAction[2]:Set[BuffThorns]
	PreSpellRange[2,1]:Set[40]

	PreAction[3]:Set[Self_Buff]
	PreSpellRange[3,1]:Set[25]

	PreAction[4]:Set[BuffEel]
	PreSpellRange[4,1]:Set[280]

	PreAction[5]:Set[BuffVim]
	PreSpellRange[5,1]:Set[36]

	PreAction[6]:Set[BuffSpirit]
	PreSpellRange[6,1]:Set[21]

	PreAction[7]:Set[BuffHunt]
	PreSpellRange[7,1]:Set[20]

	PreAction[8]:Set[BuffMask]
	PreSpellRange[8,1]:Set[23]

	;PreAction[x]:Set[SOW]
	;PreSpellRange[x,1]:Set[31]

	PreAction[9]:Set[BuffBat]
	PreSpellRange[9,1]:Set[35]

	PreAction[10]:Set[BuffSavagery]
	PreSpellRange[10,1]:Set[38]

	PreAction[11]:Set[AA_Infusion]
	PreSpellRange[11,1]:Set[391]

	PreAction[12]:Set[AA_Shapeshift]
	PreSpellRange[12,1]:Set[396]
	PreSpellRange[12,2]:Set[397]
	PreSpellRange[12,3]:Set[398]

	PreAction[13]:Set[BuffPactOfNature]
	PreSpellRange[13,1]:Set[399]

	PreAction[14]:Set[BuffMythical]
	
	PreAction[15]:Set[BuffCastingExpertise]
	PreSpellRange[15,1]:Set[384]
}

function Combat_Init()
{
}

function PostCombat_Init()
{
	PostAction[1]:Set[AutoFollowTank]
	PostAction[2]:Set[CheckForCures]
	PostAction[3]:Set[Resurrection]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare ActorID uint local
	variable int temp

	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
		;if (${Me.GroupCount} > 1)
		;	call CastSpell "Favor of the Phoenix" 4278308521 0 1 1
		InitialBuffsDone:Set[TRUE]
	}

	if ${Groupwiped}
	{
		Call HandleGroupWiped
		Groupwiped:Set[False]
	}

	if ${ShardMode}
		call Shard

  	if ${xAction}== 1 || ${xAction} == 10
		call CheckCuresAndHeals

	if ${Me.Power}>85
		call CheckPreAndChainHOTs

  	;call CheckSKFD
  
	switch ${PreAction[${xAction}]}
	{
		case DoCheckRezzes
			call CheckRezzes
			break

		case BuffThorns
			if ${MainTank} || (${BuffThorns} && ${Actor[${MainTankID}].Name(exists)})
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankID}].ID}
			}
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
			break
		case AA_Infusion
		    if ${InfusionMode}
		    {
    			if (${Me.Ability["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)})
    			{
    				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
    					call CastSpellRange ${PreSpellRange[${xAction},1]}
    			}
    		}
    		else
			{
			    if (${Me.Ability["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)})
			    {
			        if ${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
				        Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
				}
			}
			break
		case Self_Buff
			if (${Me.Ability["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)})
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_Shapeshift
			if (${Me.Ability["${SpellType[${PreSpellRange[${xAction},${ShiftForm}]}]}"](exists)})
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},${ShiftForm}]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${ShiftForm}]}
			}
			break
		case BuffEel
			if ${BuffEel}
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
			}
			break
		case BuffVim
			Counter:Set[1]
			tempvar:Set[1]
			VimBuffsOn:Clear

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal["${SpellType[${PreSpellRange[${xAction},1]}]}"]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								VimBuffsOn:Set[${Me.Maintained[${Counter}].Target.ID},${Me.Maintained[${Counter}].Target.Name}]
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}

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
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						if ${Actor[${ActorID}].Type.Equal[PC]}
						{
							if (${Me.Group[${BuffTarget.Token[1,:]}].InZone} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability["${SpellType[${PreSpellRange[${xAction},1]}]}"].ToAbilityInfo.Range} || !${NoAutoMovement})
								{
									if (!${VimBuffsOn.Element[${ActorID}](exists)})
									{
										call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
									}
									;else
									;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already Vim buffed!"]
								}
							}
						}
						else
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability["${SpellType[${PreSpellRange[${xAction},1]}]}"].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								if (!${VimBuffsOn.Element[${ActorID}](exists)})
								{
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
								}
								;else
								;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already Vim buffed!"]
							}
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffVim@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case BuffHunt
			if ${BuffHunt}
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
			break
		case BuffSpirit
			if ${BuffSpirit}
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
			break
		case BuffMask
			if ${BuffMask}
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
				break

		case BuffMythical
			BuffTarget:Set[${UIElement[cbUseMythicalOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${BuffTarget.Equal[No One]}
				break

			if ${Me.Maintained["Wrath's Blessing"].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				break
			else
				Me.Maintained["Wrath's Blessing"]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
			{
				if ${Me.CastingSpell}
				{
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 2
				}

				if !${Me.Equipment[Wrath of Nature].IsReady}
					break

				if (${Me.Group[${BuffTarget.Token[1,:]}].InZone} || ${Me.Raid[${BuffTarget.Token[1,:]}].InZone})
				{
					Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}]:DoTarget
					wait 2
					Me.Equipment[Wrath of Nature]:Use
					wait 2
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 1
				}
			}
			break

		case BuffBat                 
			BuffTarget:Set[${UIElement[cbBuffBatGroupMember@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				break
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel

			if ${BuffTarget.Token[2,:].Equal[Me]}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			elseif ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)} && ${Me.Group[${BuffTarget.Token[1,:]}].InZone}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
			
		case BuffSavagery
			BuffTarget:Set[${UIElement[cbBuffSavageryGroupMember@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				break
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)} 
			{
				if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Type.Equal[Me]} || ${Me.Group[${BuffTarget.Token[1,:]}].InZone})
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
			}
			break
			
		case BuffPactOfNature
			if !${Me.Ability[Pact of Nature](exists)}
				break

			BuffTarget:Set[${UIElement[PactOfNature@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				break
			else
				Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)} && ${Me.Group[${BuffTarget.Token[1,:]}].InZone}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
			break
			
		case BuffCastingExpertise
			if (${Me.Ability["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)})
			{
				if !${Me.Maintained["${SpellType[${PreSpellRange[${xAction},1]}]}"](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
			
		Default
			return "Buff Complete"
	}
	call ProcessTriggers
}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, uint TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	;; Notes:
	;; - For Fury, this function is utilized throughout the Combat_Routine to make sure that we are making desired checks before any spell cast
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;
	
	variable int iReturn
	variable uint MTHealthThreshold

	if (${PrimaryHealer})
		MTHealthThreshold:Set[70]
	else
		MTHealthThreshold:Set[40]

	;; Rebirth
	if (${Me.IsDead} && ${Me.Ability[${SpellType[390]}].IsReady})
	{
		call CastSpellRange 390 0 0 0 ${Me.ID}
		do
		{
			waitframe
		}
		while ${Me.IsDead}

		call HealMe ${MaxHealthModified}
	}
	;call CheckEmergencyHeals

	if (${TargetID} != ${Me.ID} && !${Actor[${TargetID}].Type.Equal[PC]})
	{
		call VerifyTarget ${TargetID} "Fury-_CastSpellRange-${SpellType[${start}]}"
		if ${Return.Equal[FALSE]}
			return CombatComplete
	}

	if ${FuryDebugMode}
		Debug:Echo["\atFury:_CastSpellRange()\ax -- Casting ${SpellType[${start}]}..."]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	iReturn:Set[${Return}]
	
	if (!${SpamHealMode} && ${Me.InCombat} && ${Me.InCombatMode})
	{
		if (${Actor[${MainTankID}].Health(exists)} && ${Actor[${MainTankID}].Health} >= ${MTHealthThreshold})
		{
			;; Thunderbolt
			if (${Me.Ability[${SpellType[60]}].IsReady} && ${Me.Power} > 40 && ${Actor[${KillTarget}].Health} > 20)
			{
				call VerifyTarget ${KillTarget} "Fury-_CastSpellRange-Thunderbolt"
				if ${Return.Equal[FALSE]}
					return CombatComplete
				if ${FuryDebugMode}
					Debug:Echo["\atFury:_CastSpellRange()\ax - Casting Thunderbolt..."]
				call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete						
			}	
		}
	}

	;;;; Use Tortoise Shell
	;; This variable is intended to be set by a 'controller' script.  In other words, the tank character might issue a command that would
	;; instigate the fury's "controller" script to set this variable to TRUE in order to have the fury cast Tortoise Shell immediately.  
	;; The syntax to use would be:
	;;		Script[EQ2Bot].VariableScope.CastTortoiseShellCaller:Set[WHO_CALLED_NAME]    (if you want the script to send the player a /tell)
	;;		Script[EQ2Bot].VariableScope.CastTortoiseShell:Set[TRUE]
	if (${CastTortoiseShell})
		call TortoiseShell
	
	;if ${FuryDebugMode}
	;	Debug:Echo["\atFury:_CastSpellRange()\ax -- COMPLETE (returning ${iReturn})"]
	return ${iReturn}
}

function Combat_Routine(int xAction)
{
	declare TankToTargetDistance float local
	declare BuffTarget string local

	if ${FuryDebugMode}
		Debug:Echo["\atFury:Combat_Routine(\ax\ay${xAction}\ax\at)\ax"]

	;;;; Use Tortoise Shell
	;; This variable is intended to be set by a 'controller' script.  In other words, the tank character might issue a command that would
	;; instigate the fury's "controller" script to set this variable to TRUE in order to have the fury cast Tortoise Shell immediately.  
	;; The syntax to use would be:
	;;		Script[EQ2Bot].VariableScope.CastTortoiseShellCaller:Set[WHO_CALLED_NAME]    (if you want the script to send the player a /tell)
	;;		Script[EQ2Bot].VariableScope.CastTortoiseShell:Set[TRUE]
	if (${CastTortoiseShell})
		call TortoiseShell

	if (!${Actor[${KillTarget}].Name(exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0 || ${KillTarget} == 0)
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - FINISHED (Returning 'CombatComplete') [1]"]		
		return CombatComplete
	}

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoCallCheckPosition}
	{
		TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
		Debug:Echo["Combat_Routine()::TankToTargetDistance: ${TankToTargetDistance}"]

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
		elseif (${TankToTargetDistance} > 12)
		{
			if ${Actor[${MainTankID}].Name(exists)}
			{
				Debug:Echo["Out of Range :: Moving to within 15m of tank"]
				call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 15 1 1
			}
		}
		DoCallCheckPosition:Set[FALSE]
	}

	;; Spam Heal Tank Mode
	if (${SpamHealMode} || (${Actor[${KillTarget}].IsEpic} > 0 && ${Me.Raid} == 0)
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - 'Spam Heal Tank Mode' enabled.  Chain Healing"]
		call SpamHealTank	
		return CombatComplete
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Animal Form
	;; (If an 'animal form' target is selected in the UI, then we should cast it 
	;;  whenever the spell is ready.)
	if (${HaveAbility_AnimalForm})
	{
		if (${Me.Group} > 1 || ${Me.Raid} > 1)
		{
			if ${Actor[${MainTankID}].InCombatMode}
			{
				if (${Me.Ability[${SpellType[386]}].IsReady} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} > 20))
				{
					BuffTarget:Set[${UIElement[AnimalForm@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
					if !${BuffTarget.Equal["No one"]}
					{
						if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
						{
							if ${FuryDebugMode}
								Debug:Echo["Combat_Routine() -- Casting Animal Form on '${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name}' (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID})"]
							call _CastSpellRange 386 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
						}
						else
							echo "ERROR3: Animal Form target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]} (${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}), does not exist!"
					}
				}
			}
		}
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Primary Healer
	;; - If serving as a primary healer, the combat routine involves fewer spells in the rotation and we ignore ${xAction}
	if (${PrimaryHealer})
	{
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Is this still necessary?
		;call CheckSKFD

		;; Is this still necessary?
		call RefreshPower
		if ${ShardMode}
			call Shard

		;; Fae Fire
		if (!${Actor[${KillTarget}].IsSolo} && ${Me.Ability[${SpellType[157]}].IsReady} && ${Me.Power} > 40 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 80))
		{
			call VerifyTarget ${KillTarget} "Fury-Combat_Routine-FaeFire"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange start=157 TargetID=0 IgnoreMaintained=1
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after Fae Fire (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}	
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Porcupine
		if (!${Actor[${KillTarget}].IsSolo} && ${Me.Ability[${SpellType[360]}].IsReady} && ${Me.Power} > 40 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 50))
		{
			call VerifyTarget ${KillTarget} "Fury-Combat_Routine-Porcupine"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange start=360 TargetID=0 IgnoreMaintained=1
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after Porcupine (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}
		elseif (${Me.Power} < 40 && ${Me.Maintained[${SpellType[360]}](exists)})
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Cancelling Porcupine due to low power"]
			Me.Maintained[${SpellType[360]}]:Cancel
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Maddening Swarm, Death Swarm, Intimidation
		call CheckDebuffs
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckDebuffs (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Start HOs (if applicable)
		if (${StartHO})
		{
			if (!${EQ2.HOWindowActive} && ${Me.InCombat})
			{
				call _CastSpellRange 304
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["Combat_Routine() - Exiting (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				} 
			} 			
		}

		;; Feast
		if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 50 && ${Me.Power} > 40)
		{
			if (${Me.Ability[${SpellType[312]}].IsReady} && !${Me.Maintained[${SpellType[312]}](exists)})
			{
				call _CastSpellRange 312 0 0 0 ${KillTarget}
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Feast (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}					
			}
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Thunderbolt
		if (${Me.Ability[${SpellType[60]}].IsReady} && ${Me.Power} > 40 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 20))
		{
			call _CastSpellRange 60 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after Thunderbolt (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}	
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Tempest
		if (${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)} && ${Me.Power} > 40 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 25))
		{
			call _CastSpellRange 70 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Tempest (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}					
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Master's Smite
		if (${Me.Ability[id,817383112].IsReady} && ${Mob.CheckActor[${KillTarget}]} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 20))
		{
			call VerifyTarget ${KillTarget} "Fury-Combat_Routine-MastersSmite"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange AbilityID=817383112 TargetID=${KillTarget} IgnoreMaintained=1
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Master's Smite (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}	
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		if (${AoEMode})
		{
			;; Ball Lightning 
			if (${Me.Level} >= 70 && ${Me.Ability[${SpellType[97]}].IsReady} && ${Me.Power} > 50 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 40))
			{
				call _CastSpellRange 97
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atCombat_Routine()\ax - Exiting after Ball Lightning (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
			}
			call CheckCuresAndHeals
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}

			;; Call of Storms
			if (${Me.Level} >= 65 && ${Me.Ability[${SpellType[96]}].IsReady} && ${Me.Power} > 50 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 40))
			{
				call _CastSpellRange 96
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atCombat_Routine()\ax - Exiting after Call of Storms (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
			}
			call CheckCuresAndHeals
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}

			;; Ring of Fire
			if (${Me.Level} >= 55 && ${Me.Ability[${SpellType[95]}].IsReady} && ${Me.Power} > 50 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 50))
			{
				call _CastSpellRange 95
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atCombat_Routine()\ax - Exiting after Ring of Fire (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
			}
			call CheckCuresAndHeals
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}

		;; Starnova
		if (!${Actor[${KillTarget}].IsSolo} && ${Me.Ability[${SpellType[90]}].IsReady} && ${Me.Power} > 60 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 50))
		{
			call _CastSpellRange 90 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Starnova (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}					
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Wrath of Nature
		if (${UseWrathOfNature} && !${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 40 && ${Me.Ability[${SpellType[379]}].IsReady})
		{
			call _CastSpellRange 379 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Wrath of Nature (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}					
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;;; End Combat Routine when ${PrimaryHealer} == TRUE
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - FINISHED (Returning 'CombatComplete') [END]"]		
		return CombatComplete
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; NOT Primary Healer
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Is this still necessary?
	;call CheckSKFD

	;; Is this still necessary?
	call RefreshPower
	if ${ShardMode}
		call Shard

	;; Start HOs (if applicable)
  	if (${StartHO})
  	{
  		if (!${EQ2.HOWindowActive} && ${Me.InCombat})
  		{
  			call _CastSpellRange 304
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			} 
		} 			
  	}

	;; Fae Fire
	if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 55 && ${Me.Ability[${SpellType[157]}].IsReady} && ${Me.Power} > 10)
	{
		call _CastSpellRange 157
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after Fae Fire (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}	
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Porcupine
	if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 40 && ${Me.Ability[${SpellType[360]}].IsReady} && ${Me.Power} > 10)
	{
		call _CastSpellRange 360
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after Porcupine (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}
	elseif (${Me.Power} < 10 && ${Me.Maintained[${SpellType[360]}](exists)})
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Cancelling Porcupine due to low power"]
		Me.Maintained[${SpellType[360]}]:Cancel
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Maddening Swarm, Death Swarm, Intimidation
	call CheckDebuffs
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckDebuffs (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Feast
	if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 45 && ${Me.Power} > 15)
	{
		if (${Me.Ability[${SpellType[312]}].IsReady} && !${Me.Maintained[${SpellType[312]}](exists)})
		{
			call _CastSpellRange 312 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Feast (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}					
		}
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Thunderbolt
	if (${Me.Ability[${SpellType[60]}].IsReady} && ${Me.Power} > 15 && ${Actor[${KillTarget}].Health} >= 15)
	{
		call _CastSpellRange 60 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after Thunderbolt (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}	
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Tempest
	if (${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)} && ${Me.Power} > 15 && ${Actor[${KillTarget}].Health} >= 20)
	{
		call _CastSpellRange 70 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Tempest (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}					
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Master's Smite
	if (${Me.Ability[id,817383112].IsReady} && ${Mob.CheckActor[${KillTarget}]} && ${Actor[${KillTarget}].Health} >= 20)
	{
		call VerifyTarget ${KillTarget} "Fury-Combat_Routine-MastersSmite"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange AbilityID=817383112 TargetID=${KillTarget} IgnoreMaintained=1
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Master's Smite (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}	
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;;;;;;;;;;;;;;;;;;;;;;;;

	;; Vortex
	if (${VortexMode} && ${Me.Ability[${SpellType[395]}].IsReady} && ${Me.Power} > 15)
	{
		call _CastSpellRange 395 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Vortex (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}					
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	if (${AoEMode})
	{
		;; Ball Lightning 
		if (${Me.Level} >= 70 && ${Me.Ability[${SpellType[97]}].IsReady} && ${Me.Power} > 20 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 40))
		{
			call _CastSpellRange 97
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atCombat_Routine()\ax - Exiting after Ball Lightning (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Call of Storms
		if (${Me.Level} >= 65 && ${Me.Ability[${SpellType[96]}].IsReady} && ${Me.Power} > 20 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 40))
		{
			call _CastSpellRange 96
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atCombat_Routine()\ax - Exiting after Call of Storms (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}

		;; Ring of Fire
		if (${Me.Level} >= 55 && ${Me.Ability[${SpellType[95]}].IsReady} && ${Me.Power} > 20 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 50))
		{
			call _CastSpellRange 95
			if ${Return.Equal[CombatComplete]}
			{
				if ${FuryDebugMode}
					Debug:Echo["\atCombat_Routine()\ax - Exiting after Ring of Fire (Target no longer valid: CombatComplete)"]
				return CombatComplete						
			}
		}
		call CheckCuresAndHeals
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}
	}

	;; Starnova
	if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 30 && ${Me.Ability[${SpellType[90]}].IsReady} && ${Me.Power} > 15)
	{
		call _CastSpellRange 90 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Starnova (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}					
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}

	;; Wrath of Nature
	if (${UseWrathOfNature} && !${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} >= 40 && ${Me.Ability[${SpellType[379]}].IsReady} && ${Me.Power} > 15)
	{
		call _CastSpellRange 379 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after casting Wrath of Nature (Target no longer valid: CombatComplete)"]
			return CombatComplete						
		}					
	}
	call CheckCuresAndHeals
	if ${Return.Equal[CombatComplete]}
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Combat_Routine()\ax - Exiting after CheckCuresAndHeals (Target no longer valid: CombatComplete)"]
		return CombatComplete						
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;if ${FuryDebugMode}
	;	Debug:Echo["Combat_Routine() -- FINISHED (Returning 'CombatComplete') [END]"]		
	return CombatComplete
}

function CheckDebuffs()
{
	variable bool Continue = TRUE
	if (!${DebuffMode})
		return 0

	if (${Actor[${KillTarget}].IsEpic} && ${Me.Power} > 55 && ${Actor[${KillTarget}].Health} >= 10)
	{
		if (${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)})
		{
			if (${Me.Power} > 45 || !${PrimaryHealer})
			{
				call VerifyTarget ${KillTarget} "Fury-CheckDebuffs-DeathSwarm"
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=51 TargetID=${KillTarget} IgnoreMaintained=1
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atFury:CheckDebuffs()\ax -- Exiting after casting Death Swarm (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				Continue:Set[FALSE]		
			}
		}
		if (${Continue} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)} && ${Actor[${KillTarget}].Health} >= 10)
		{
			if (${Me.Power} > 45 || !${PrimaryHealer})
			{
				call VerifyTarget ${KillTarget} "Fury-CheckDebuffs-Intimidation"
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=50 TargetID=${KillTarget} IgnoreMaintained=1
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atFury:CheckDebuffs()\ax -- Exiting after casting Intimidation (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}	
				Continue:Set[FALSE]		
			}		
		}
		if (${Continue} && ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)} && ${Actor[${KillTarget}].Health} >= 10)
		{
			if (${Me.Power} > 45 || !${PrimaryHealer})
			{
				call VerifyTarget ${KillTarget} "Fury-CheckDebuffs-MaddeningSwarm"
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=52 TargetID=${KillTarget} IgnoreMaintained=1
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atFury:CheckDebuffs()\ax -- Exiting after casting Maddening Swarm (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				Continue:Set[FALSE]					
			}			
		}
	}
	elseif (${Actor[${KillTarget}].IsHeroic} && ${Me.Power} > 40 && ${Actor[${KillTarget}].Health} >= 20)
	{
		;; Fast-casting encounter debuff that should be used always
		if (${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)})
		{
			if (${Me.Power} > 45 || !${PrimaryHealer})
			{
				call VerifyTarget ${KillTarget} "Fury-CheckDebuffs-MaddeningSwarm"
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=52 TargetID=${KillTarget} IgnoreMaintained=1
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atFury:CheckDebuffs()\ax -- Exiting after casting Maddening Swarm (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				Continue:Set[FALSE]				
			}			
		}
		if (${Continue} && ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)} && ${Actor[${KillTarget}].Health} >= 20)
		{
			if (${Me.Power} > 45 || !${PrimaryHealer})
			{
				if ${FuryDebugMode}
					Debug:Echo["\atFury:CheckDebuffs()\ax -- Casting Defense debuff (Death Swarm) on Heroic mob"] 
				call _CastSpellRange 51 0 0 0 ${KillTarget}
				if ${Return.Equal[CombatComplete]}
				{
					if ${FuryDebugMode}
						Debug:Echo["\atFury:CheckDebuffs()\ax -- Exiting after casting Death Swarm (Target no longer valid: CombatComplete)"]
					return CombatComplete						
				}
				Continue:Set[FALSE]		
			}
		}				
	}

	return OK
}

function Post_Combat_Routine(int xAction)
{
    declare tempgrp int local 1

	TellTank:Set[FALSE]

	if ${FuryDebugMode}
		Debug:Echo["Post_Combat_Routine() -- STARTING..."]

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
		    if !${Me.InCombatMode} || ${CombatRez}
		    {
    			tempgrp:Set[1]
    			do
    			{
    				if (${Me.Group[${tempgrp}].InZone} && ${Me.Group[${tempgrp}].IsDead})
    				{
    					if (${Me.InRaid} && ${Me.Ability[${SpellType[380]}].IsReady})
    					{
    						call _CastSpellRange 380 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    					}
    					elseif ${Me.Ability[${SpellType[300]}].IsReady}
    					{
    						call _CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    					}
    					elseif ${Me.Ability[${SpellType[301]}].IsReady}
    					{
    						call _CastSpellRange 301 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    					}
    					elseif ${Me.Ability[${SpellType[302]}].IsReady}
    					{
    						call _CastSpellRange 302 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5

    					}
    					else
    					{
    						call _CastSpellRange 303 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    					}
    				}
    			}
    			while ${tempgrp:Inc}<=${Me.GroupCount}
    		}
			break
		case CheckForCures
			;Debug:Echo["Checking if Cures are needed post combat..."]
			if ${Me.InCombatMode}
    			call CheckCures 1
    		else
    		  call CheckCures 0
			break
		case AutoFollowTank
			if ${AutoFollowMode}
				ExecuteAtom AutoFollowTank
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function RefreshPower()
{
    if ${Me.Level} < 75
    {
    	if ${Me.InCombat} && ${Me.Power}<65  && ${Me.Health}>25
    		call UseItem "Helm of the Scaleborn"

    	if ${Me.InCombat} && ${Me.Power}<45
    		call UseItem "Spiritise Censer"

    	if ${Me.InCombat} && ${Me.Power}<15
    		call UseItem "Stein of the Everling Lord"
	}


}

function Have_Aggro()
{
	if ${FuryDebugMode}
		Debug:Echo["\atFury:Have_Aggro()\ax -- \ar I HAVE AGGRO!\ax"]

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC} ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if (!${MainTank} && ${Me.Group} > 1)
	{
		if ${Me.Inventory[Behavioral Modificatinator Stereopticon](exists)}
		{
			if (${Me.Inventory[Behavioral Modificatinator Stereopticon].IsReady})
			{
				Me.Inventory[Behavioral Modificatinator Stereopticon]:Use
				return
			}
		}
	}

	if (${Actor[${aggroid}].Distance} <= 10 && ${Me.Ability[${SpellType[180]}].IsReady})
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Have_Aggro()\ax -- \ay Casting Brambles on ${Actor[${aggroid}].Name}!"]
		call _CastSpellRange 180 0 0 0 ${aggroid}
	}
	else
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:Have_Aggro()\ax -- \ay${Actor[${aggroid}].Name} is too far away for Brambles... (${Actor[${aggroid}].Distance}m)"]
	}
}

function CheckCuresAndHeals()
{
	variable bool CombatComplete = FALSE
	variable string sReturn 

	;;;; Use Tortoise Shell
	;; This variable is intended to be set by a 'controller' script.  In other words, the tank character might issue a command that would
	;; instigate the fury's "controller" script to set this variable to TRUE in order to have the fury cast Tortoise Shell immediately.  
	;; The syntax to use would be:
	;;		Script[EQ2Bot].VariableScope.CastTortoiseShellCaller:Set[WHO_CALLED_NAME]    (if you want the script to send the player a /tell)
	;;		Script[EQ2Bot].VariableScope.CastTortoiseShell:Set[TRUE]

	;; Rebirth
	if (${Me.IsDead} && ${Me.Ability[${SpellType[390]}].IsReady})
	{
		call CastSpellRange 390 0 0 0 ${Me.ID}
		do
		{
			waitframe
		}
		while ${Me.IsDead}

		call HealMe ${MaxHealthModified}
	}
	else
	{
		if (${CastTortoiseShell})
			call TortoiseShell
	}

	if ${CureMode}
		call CheckCures

	if (!${CombatComplete})
	{
		;; Note:  CheckHeals also calls CheckPreAndChainHOTs
		call CheckHeals
	}

	if (${Me.InCombat} && ${Me.InCombatMode})
	{
		;; If our health is low, cast Brambles just to be safe.  Otherwise, check aggro
		if (${Me.Health} < 50)
		{
			call _CastSpellRange 180 0 0 0 ${KillTarget} 0 0 0 1
		}
		else
		{
			Mob:CheckMYAggro
			if ${haveaggro} && !${MainTank} && ${Actor[${aggroid}].Name(exists)}
			{
				call Have_Aggro ${aggroid}
				if ${UseCustomRoutines}
					call Custom__Have_Aggro ${aggroid}
			}
		}
	}

	return ${sReturn}
}

function CheckHeals()
{
	;;;;;
	;; This function should only be called by CheckCuresAndHeals().   All "checks" within the script should call CheckCuresAndHeals(), not CheckHeals()
	;;;;;
	variable int tempgrp = 1
	variable int temphl = 0
	variable int temph2 = 1
	variable int grpheal = 0
	variable int lowest = 0
	variable int raidlowest = 1
	variable int PetToHeal = 0
	variable bool MainTankExists = TRUE
	variable bool lowestset = FALSE
	variable int cGroupMemberID = 0
	variable int cGroupMemberHealth = 0
	variable int lGroupMemberHealth = 0
	variable float cGroupMemberDistance = 0
	variable string cGroupMemberClass
	variable bool cGroupMemberIsDead = FALSE
	variable float TankToTargetDistance
	
	;Debug:Echo["CheckHeals():: START...."]

	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0
	if ${DoCallCheckPosition}
	{
		if (${Actor[${KillTarget}].Name(exists)} && !${Actor[${KillTarget}].IsDead})
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			;Debug:Echo["EQ2Bot-CheckHeals():: TankToTargetDistance: ${TankToTargetDistance}"]
	
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
		}
		elseif (${Actor[${MainTankID}].Name(exists)} && ${Actor[${MainTankID}].Distance} > 15)
		{
			Debug:Echo["EQ2Bot-CheckHeals():: Out of Range :: Moving to within 15m of tank"]
			call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 15 1 1
		}
		DoCallCheckPosition:Set[FALSE]
	}

  	if !${Actor[${MainTankID}].Name(exists)}
  	{
		if (${MainTankID} > 0)
		{
			if (!${Me.Group[id,${MainTankID}](exists)})
				echo "Fury-CheckHeals() - ERROR MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"
			;elseif (!${Me.Group[id,${MainTankID}].InZone})
			;	echo "EQ2Bot-CheckHeals():: ERROR: MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"
		}
		MainTankExists:Set[FALSE]
  	}
  	else
      	MainTankExists:Set[TRUE]

	;Res the MT if they are dead
	if (!${Me.InCombatMode} || ${CombatRez})
	{
		if ${MainTankExists} && ${Actor[${MainTankID}].IsDead}
		{
			call CastSpellRange 300 0 1 1 ${MainTankID}
		}
	}
	
	call CheckPreAndChainHOTs

  	if (${MainTankExists})
	{
		if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 10]}
	    {
			Debug:Echo["EQ2Bot-CheckHeals():: MainTank Health low (${Actor[${MainTankID}].Health})"]
		    if ${Me.ID}==${MainTankID}
			    call HealMe ${MaxHealthModified}
		    else
			    call HealMT
	    }

	    ;Check My health after MT
      	if ${Me.ID}!=${MainTankID} && ${Me.Health} < ${Math.Calc[${MaxHealthModified} - 35]}
        	call HealMe ${MaxHealthModified}
	}
  	else
  	{
      	if ${Me.Health} < ${Math.Calc[${MaxHealthModified} - 15]}
			call HealMe ${MaxHealthModified}
  	}

  	if ${Me.GroupCount} > 1
  	{
		do
		{
			if (!${Me.Group[${temphl}].InZone} || !${Me.Group[${temphl}].Health(exists)})
			{
				;Debug:Echo["CheckHeals():: ${cGroupMemberID}:${Me.Group[${temphl}].Name} not in zone"]
				continue
			}

			;; Set some variables now:
			cGroupMemberID:Set[${Me.Group[${temphl}].ID}]
			;Debug:Echo["CheckHeals():: Checking GroupMember ( ${cGroupMemberID}:${Me.Group[${temphl}].Name} )"]

			; FIRST -- If group member has health below a certain threshold, heal them immediately
			if ${Me.Group[${temphl}].Health} < ${Math.Calc[${MaxHealthModified} - 40]} && !${Me.Group[${temphl}].IsDead}
			{
				Debug:Echo["CheckHeals():: ${cGroupMemberID}:${Me.Group[${temphl}].Name} health at ${Me.Group[${temphl}].Health} -- Casting ${SpellType[2]}"]
				if ${Me.Ability[${SpellType[2]}].IsReady}
				{
					call CastSpellRange 2 0 0 0 ${cGroupMemberID}
					continue
				}
			}

			;;;;;;;;
			;; Set variables now:
			cGroupMemberHealth:Set[${Me.Group[${temphl}].Health}]
			lGroupMemberHealth:Set[${Me.Group[${lowest}].Health}]
			cGroupMemberDistance:Set[${Me.Group[${temphl}].Distance}]
			cGroupMemberClass:Set[${Me.Group[${temphl}].Class}]
			cGroupMemberIsDead:Set[${Me.Group[${temphl}].IsDead}]
			;;
			;;;;;;;;

			if (${cGroupMemberHealth} < ${Math.Calc[${MaxHealthModified} - 0]} && !${cGroupMemberIsDead})
			{
				;Debug:Echo["CheckHeals():: ${cGroupMemberID}:${Me.Group[${temphl}].Name} health at ${Me.Group[${temphl}].Health} -- Checking in range for ${SpellType[1]}"]
				if ((${cGroupMemberHealth}<${lGroupMemberHealth} || !${lowestset}) && (${cGroupMemberDistance}<=${Me.Ability[${SpellType[1]}].ToAbilityInfo.Range}))
				{
					lowestset:Set[TRUE]
					lowest:Set[${temphl}]
					;Debug:Echo["CheckHeals():: ${cGroupMemberID}:${Me.Group[${temphl}].Name} health at ${Me.Group[${temphl}].Health} -- Setting 'lowest' to ${lowest}"]  
					;Debug:Echo["CheckHeals():  lowest: ${lowest} (lowestset: ${lowestset})"]
				}
			}

			;if (${cGroupMemberHealth} < ${Math.Calc[${MaxHealthModified} - 20]})
			;	Debug:Echo["TEST: cGroupMemberIsDead = ${cGroupMemberIsDead} || cGroupMemberHealth = ${cGroupMemberHealth} || Math.Calc[MaxHealthModified - 20] = ${Math.Calc[${MaxHealthModified} - 20]} || cGroupMemberDistance<=Me.Ability[SpellType[15]].ToAbilityInfo.Range = ${cGroupMemberDistance}<=${Me.Ability[${SpellType[15]}].ToAbilityInfo.Range}"]
			if !${cGroupMemberIsDead} && ${cGroupMemberHealth} < ${Math.Calc[${MaxHealthModified} - 20]} && ${cGroupMemberDistance}<=${Me.Ability[${SpellType[15]}].ToAbilityInfo.Range}
			{  
				grpheal:Inc
				Debug:Echo["CheckHeals():: ${cGroupMemberID}:${Me.Group[${temphl}].Name} health at ${Me.Group[${temphl}].Health} and within range of ${SpellType[15]} -- 'grpheal' now at ${grpheal}"]
			}

			if (${cGroupMemberClass.Equal[conjuror]}  || ${cGroupMemberClass.Equal[necromancer]} || ${cGroupMemberClass.Equal[coercer]})
			{
				if (${Me.Group[${temphl}].Pet.Health} < ${Math.Calc[${MaxHealthModified} - 40]} && !${Me.Group[${temphl}].Pet.IsDead})
					PetToHeal:Set[${Me.Group[${temphl}].Pet.ID}]
			}
			elseif (${cGroupMemberClass.Equal[illusionist]} && !${Me.InCombat})
			{
				if (${Me.Group[${temphl}].Pet.Health} < ${Math.Calc[${MaxHealthModified} - 40]} && !${Me.Group[${temphl}].Pet.IsDead})
					PetToHeal:Set[${Me.Group[${temphl}].Pet.ID}]
			}
		}
		while ${temphl:Inc} < ${Me.GroupCount}
	}

	if ${grpheal}>1
	{
		Debug:Echo["CheckHeals():: Calling GroupHeal()"]  
		call GroupHeal
	}

	;now lets heal individual groupmembers if needed
	if (${lowestset} && ${Me.Group[${lowest}].Health(exists)} && ${Me.Group[${lowest}].InZone} && !${Me.Group[${lowest}].IsDead})
	{
		if (${Me.Group[${lowest}].Health} < 80)
		  	Debug:Echo["${Me.Group[${lowest}]}'s health is lowest at ${Me.Group[${lowest}].Health}"]

		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].Health} < ${Math.Calc[${MaxHealthModified} - 35]} && ${Me.Group[${lowest}].Distance}<=${Me.Ability[${SpellType[2]}].ToAbilityInfo.Range}
		{
			Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<60) at ${Me.Group[${lowest}].Health} -- HEALING with ${SpellType[2]}"]
			if ${Me.Ability[${SpellType[2]}].IsReady}
			{
				call CastSpellRange 2 0 0 0 ${Me.Group[${lowest}].ID}
			}
		}

		if ${Me.Group[${lowest}].Health} < ${Math.Calc[${MaxHealthModified} - 25]} && ${Me.Group[${lowest}].Distance}<=${Me.Ability[${SpellType[7]}].ToAbilityInfo.Range}
		{
			if ${Me.Ability[${SpellType[7]}].IsReady}
			{
				Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<75) at ${Me.Group[${lowest}].Health} -- HEALING with ${SpellType[7]}"]
				call CastSpellRange 7 0 0 0 ${Me.Group[${lowest}].ID}
			}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
			{
				Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<75) at ${Me.Group[${lowest}].Health} -- HEALING with ${SpellType[1]}"]
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ID}
			}
			elseif ${Me.Ability[${SpellType[4]}].IsReady}
			{
				Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<75) at ${Me.Group[${lowest}].Health} -- HEALING with ${SpellType[4]}"]
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ID}
			}
		}
	}

	;RAID HEALS - Only check if in raid, raid heal mode on, maintank is green, I'm above 50, and a direct heal is available.  Otherwise don't waste time.
	if (${MainTankExists})
	{
    	if ${RaidHealMode} && ${Me.InRaid} && ${Me.Health} > ${Math.Calc[${MaxHealthModified} - 50]} && ${Actor[${MainTankID}].Health} > ${Math.Calc[${MaxHealthModified} - 30]} && (${Me.Ability[${SpellType[4]}].IsReady} || ${Me.Ability[${SpellType[1]}].IsReady})
    	{
    		do
    		{
    			if ${Me.Raid[${temph2}].Health(exists)} && ${Me.Raid[${temph2}].InZone} && ${Me.Raid[${temph2}].InZone}
    			{
    			    if ${Me.Raid[${temph2}].Name.NotEqual[${Me.Name}]}
    				{
      				    if ${Me.Raid[${temph2}].Health} < ${Math.Calc[${MaxHealthModified} - 0]} && !${Me.Raid[${temph2}].IsDead} && ${Me.Raid[${temph2}].Distance}<=${Me.Ability[${SpellType[1]}].ToAbilityInfo.Range}
          				{
          					if ${Me.Raid[${temph2}].Health} < ${Me.Raid[${raidlowest}].Health} || ${raidlowest}==0
          						raidlowest:Set[${temph2}]
          				}
    				}
    			}
    		}
    		while ${temph2:Inc}<= ${Me.Raid}

			if (${Me.Raid[${raidlowest}].InZone})
			{
				if ${Me.InCombat} && ${Me.Raid[${raidlowest}].Health(exists)} < ${Math.Calc[${MaxHealthModified} - 40]} && !${Me.Raid[${raidlowest}].IsDead} && ${Me.Raid[${raidlowest}].Distance}<=${Me.Ability[${SpellType[1]}].ToAbilityInfo.Range}
				{
					;Debug:Echo["Raid Lowest: ${Me.Raid[${raidlowest}].Name} -> ${Me.Raid[${raidlowest}].Health} health"]
					if ${Me.Ability[${SpellType[4]}].IsReady}
						call CastSpellRange 4 0 0 0 ${Me.Raid[${raidlowest}].ID}
					elseif ${Me.Ability[${SpellType[1]}].IsReady}
						call CastSpellRange 1 0 0 0 ${Me.Raid[${raidlowest}].ID}
				}
			}
    	}
    }

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}].Name(exists)} && ${Actor[${PetToHeal}].InCombatMode} && !${EpicMode} && !${Me.InRaid}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	if (${EpicMode} && ${CureMode})
		call CheckCures
		
	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].IsDead} && ${Me.Group[${temphl}].Distance}<=20
			{
				if !${Me.InCombat} && ${Me.Ability[${SpellType[380]}].IsReady}
					call CastSpellRange 380 0 0 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
				else
					call CastSpellRange 300 303 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}
	}

	;;;;;;;;;;;;;;;;;;;;;;;
	;; Spells that should be cast whenever they're ready (if we're in Offensive Mode)
	if (!${PrimaryHealer} && ${Me.Power} > 45 && ${Me.InCombat} && ${Me.InCombatMode} && ${Actor[${KillTarget}].Health} > 20)
	{
		if (${Actor[${MainTankID}].Health(exists)} && ${Actor[${MainTankID}].Health} > 70)
		{
			variable bool ContinueOffense = TRUE

			;; Death Swarm
			if (${Me.Ability[${SpellType[51]}].IsReady} && ${Actor[${KillTarget}].Health} > 35)
			{
				if (!${Me.Maintained[${SpellType[51]}](exists)})
				{
					if ${FuryDebugMode}
						Debug:Echo["CheckHeals() -- Routine Finished -- Casting Death Swarm on ${Actor[${KillTarget}].Name}..."]
					call _CastSpellRange 51 0 0 0 ${KillTarget} 0 0 0 1
					if (!${Return.Equal[CombatComplete]})
						ContinueOffense:Set[TRUE]
					else
						ContinueOffense:Set[FALSE]		
				}
				else
				{
					if ${FuryDebugMode}
						Debug:Echo["CheckHeals() -- Routine Finished -- ${Actor[${KillTarget}].Name} already has Death Swarm"]
				}
			}		

			;; Thunderbolt
			if (${ContinueOffense} && ${Me.Ability[${SpellType[60]}].IsReady})
			{
				if ${FuryDebugMode}
					Debug:Echo["CheckHeals() -- Routine Finished -- Casting Thunderbolt on ${Actor[${KillTarget}].Name}..."]
				call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
				if (!${Return.Equal[CombatComplete]})
					ContinueOffense:Set[TRUE]
				else
					ContinueOffense:Set[FALSE]		
			}	

		}
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;
}

function HealMe(int maxHealthModified)
{
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.Health} < ${Math.Calc[${maxHealthModified} - 30]} && ${Me.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.Health} < ${Math.Calc[${maxHealthModified} - 50]}
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.ID}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.ID}
		}
	}

	if ${Me.Health} < ${Math.Calc[${maxHealthModified} - 40]}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${Me.ID}
	}

	if ${Me.Health} < ${Math.Calc[${maxHealthModified} - 15]}
	{
		if !${EpicMode} || (${haveaggro} && ${Me.InCombatMode})
		{
			if ${Me.Ability[${SpellType[7]}].IsReady}
				call CastSpellRange 7 0 0 0 ${Me.ID}
		}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.ID}
		}
	}
}

function HealMT()
{
	variable bool MTInMyGroup = FALSE

	if (${Me.Group[id,${MainTankID}](exists)})
		MTInMyGroup:Set[TRUE]

	Debug:Echo["HealMT():: START... (MT Health at ${Actor[${MainTankID}].Health}) [MTInMyGroup: ${MTInMyGroup}]"]

	if (!${Actor[${MainTankID}].Name(exists)})
	{
		Debug:Echo["HealMT():: MainTank doesn't exist!"]
		return
	}
		
	if (${Actor[${MainTankID}].IsDead})
	{
		Debug:Echo["HealMT():: MainTank is Dead!"]
		return
	}
	
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 55]}
	{
		Debug:Echo["HealMT():: Calling Emergency Heal! (MT Health at ${Actor[${MainTankID}].Health})"]
		call EmergencyHeal ${MainTankID}
	}

	;Frey Check
	if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 45]} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[2]}].ToAbilityInfo.Range}
	{
		Debug:Echo["HealMT():: Casting ${SpellType[2]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		if ${Me.Ability[${SpellType[2]}].IsReady}
			call CastSpellRange 2 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 35]} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[1]}].ToAbilityInfo.Range}
	{
		Debug:Echo["HealMT():: Casting ${SpellType[1]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${MainTankID}
	}
	if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 25]} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[4]}].ToAbilityInfo.Range}
	{
		Debug:Echo["HealMT():: Casting ${SpellType[4]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		if ${Me.Ability[${SpellType[4]}].IsReady}
			call CastSpellRange 4 0 0 0 ${MainTankID}
	}

	;MAINTANK HEALS
	; Use regens first, then Patch Heals
	if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 10]}
	{
		if ${Me.Ability[${SpellType[7]}].IsReady} && ${Me.Maintained[${SpellType[7]}].Target.ID} != ${MainTankID} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[7]}].ToAbilityInfo.Range}
		{
			Debug:Echo["HealMT():: Casting ${SpellType[7]}... (MT Health at ${Actor[${MainTankID}].Health})"]
			call CastSpellRange 7 0 0 0 ${MainTankID}
		}
		elseif ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)} && ${MTInMyGroup}
		{
			Debug:Echo["HealMT():: Casting ${SpellType[15]}... (MT Health at ${Actor[${MainTankID}].Health})"]
			call CastSpellRange 15
		}
	}

	Debug:Echo["HealMT():: END..."]
}

function GroupHeal()
{	
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	if ${Me.Ability[${SpellType[11]}].IsReady}
		call CastSpellRange 11

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	elseif ${Me.Ability[${SpellType[15]}].IsReady}
		call CastSpellRange 15
}

function EmergencyHeal(uint healtarget)
{
	Debug:Echo["EmergencyHeal():: START ... (healing ${Actor[${healtarget}].Name})"]

	;death prevention (Feral Tenacity)
	if ${Me.Ability[${SpellType[316]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[${healtarget}].Name}].InZone})
	{
		Debug:Echo["EmergencyHeal():: Casting ${SpellType[316]}..."]
		call CastSpellRange 316 0 0 0 ${healtarget}
	}

	; Sylvan Touch
	if ${Me.Ability[${SpellType[8]}].IsReady}
	{
		Debug:Echo["EmergencyHeal():: Casting ${SpellType[8]}..."]
		call CastSpellRange 8 0 0 0 ${healtarget}
	}
	; Feral Pulse
	elseif ${Me.Ability[${SpellType[16]}].IsReady}
	{
		Debug:Echo["EmergencyHeal():: Casting ${SpellType[16]}..."]
		call CastSpellRange 16 0 0 0 ${healtarget}
	}
}

function SpamHealTank()
{
	variable bool MTInMyGroup = FALSE
	variable int WaitCounter = 0

	if (${Me.Group[id,${MainTankID}](exists)})
		MTInMyGroup:Set[TRUE]

	Debug:Echo["SpamHealTank():: START... (MT Health at ${Actor[${MainTankID}].Health}) [MTInMyGroup: ${MTInMyGroup}]"]

	if (!${Actor[${MainTankID}].Name(exists)})
	{
		Debug:Echo["SpamHealTank():: MainTank doesn't exist!"]
		return
	}
		
	if (${Actor[${MainTankID}].IsDead})
	{
		Debug:Echo["SpamHealTank():: MainTank is Dead!"]
		return
	}

	;; Distance check, but only if we're only in a group and not in a raid
	if (${Actor[${MainTankID}].Distance} >= 20 && ${Me.Raid} == 0)
	{
		Debug:Echo["SpamHealTank():: \arMainTank is too far away! [${Actor[${MainTankID}].Distnace}]\ax"]
		eq2execute /tell ${Actor[${MainTankID}].Name} "You're too far away to heal!   Please move closer"
		do
		{
			wait 5
			WaitCounter:Inc[5]
			if (${WaitCounter} > 50)
				return
		}
		while (${Actor[${MainTankID}].Distnace} >= 20)
		eq2execute /tell ${Actor[${MainTankID}].Name} "Thanks!"
	}
	
	; Make sure we don't die....
	call HealMe 100 

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health} < 50
	{
		Debug:Echo["SpamHealTank():: Calling Emergency Heal! (MT Health at ${Actor[${MainTankID}].Health})"]
		call EmergencyHeal ${MainTankID}
	}

	;Back Into The Frey
	if ${Actor[${MainTankID}].Health} < 80 && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[2]}].ToAbilityInfo.Range}
	{
		Debug:Echo["SpamHealTank():: Casting ${SpellType[2]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		if ${Me.Ability[${SpellType[2]}].IsReady}
			call CastSpellRange 2 0 0 0 ${MainTankID}
	}
	;Nature's Elixir
	if ${Actor[${MainTankID}].Health} < 85 && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[1]}].ToAbilityInfo.Range}
	{
		Debug:Echo["SpamHealTank():: Casting ${SpellType[1]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${MainTankID}
	}
	;Nature's Salve
	if ${Actor[${MainTankID}].Health} < 95 && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[4]}].ToAbilityInfo.Range}
	{
		Debug:Echo["SpamHealTank():: Casting ${SpellType[4]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		if ${Me.Ability[${SpellType[4]}].IsReady}
			call CastSpellRange 4 0 0 0 ${MainTankID}
	}

	;; Porcupine
	if (!${Actor[${KillTarget}].IsSolo} && ${Me.Ability[${SpellType[360]}].IsReady} && ${Me.Power} > 40 && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Health} >= 50))
	{
		call VerifyTarget ${KillTarget} "Fury-SpamHealTank-Porcupine"
		if ${Return.Equal[FALSE]}
			return
		call CastSpellRange start=360 TargetID=0 IgnoreMaintained=1
		if ${Return.Equal[CombatComplete]}
		{
			if ${FuryDebugMode}
				Debug:Echo["\atFury:SpamHealTank()\ax - Exiting after Porcupine (Target no longer valid: CombatComplete)"]
			return						
		}
	}
	elseif (${Me.Power} < 40 && ${Me.Maintained[${SpellType[360]}](exists)})
	{
		if ${FuryDebugMode}
			Debug:Echo["\atFury:SpamHealTank()\ax - Cancelling Porcupine due to low power"]
		Me.Maintained[${SpellType[360]}]:Cancel
	}

	;;;;;
	;; Keep up regens
	; Regrowth
	if ${Me.Ability[${SpellType[7]}].IsReady} && ${Me.Maintained[${SpellType[7]}].Target.ID} != ${MainTankID} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[7]}].ToAbilityInfo.Range}
	{
		Debug:Echo["SpamHealTank():: Casting ${SpellType[7]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		call CastSpellRange 7 0 0 0 ${MainTankID}
	}
	; Autumn's Kiss
	elseif ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)} && ${MTInMyGroup}
	{
		Debug:Echo["SpamHealTank():: Casting ${SpellType[15]}... (MT Health at ${Actor[${MainTankID}].Health})"]
		call CastSpellRange 15
	}

	Debug:Echo["SpamHealTank():: END..."]
}

function CureGroupMember(int gMember)
{
	variable int tmpcure = 0

	echo "\atCureGroupMember(\ax\ay${gMember}\ax\at)\ax"
	;Debug:Echo["CureGroupMember(${gMember})"]

	if !${Me.Group[${gMember}].InZone} || ${Me.Group[${gMember}].IsDead} || !${Me.Group[${gMember}].IsAfflicted} || !${Me.Group[${gMember}].Health(exists)} || ${Me.Group[${gMember}].Health} < 0 || ${Me.Group[${gMember}].Distance}>=${Me.Ability[${SpellType[210]}].ToAbilityInfo.Range}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}](exists)} && !${Me.Group[${gMember}].IsDead}
	{
		if (${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0)
		{
		    Debug:Echo["Curing ${Me.Group[${gMember}]} (${Me.Group[${gMember}].ID})"]
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 5
		}
	}
}

function CureMe()
{
	variable int CureCnt = 0

	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0
	
	if !${Me.IsAfflicted}
		return

	;check if we are not in control, and use control cure if needed
	if !${Me.CanTurn} || !${Me.IsRooted}
		call CastSpellRange 289

	while (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0) && ${CureCnt:Inc}<4
	{
		Debug:Echo["Curing ME (${Me.ID})"]
		call CastSpellRange 210 0 0 0 ${Me.ID}

		if ${Me.Health} < ${Math.Calc[${MaxHealthModified} - 70]} && ${EpicMode}
			call HealMe ${MaxHealthModified}
	}

}

function CheckCures(int InCombat=1)
{
	variable int i = 0
	variable int grpcure = 0
	variable int Affcnt = 0
	variable string CureTarget 
	variable float TankToTargetDistance
	variable bool MTInMyGroup = FALSE
	if (${Me.Group[id,${MainTankID}](exists)})
		MTInMyGroup:Set[TRUE]
	
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0	
	
	if (!${CureMode})
		return

	;; If Main Tank is in my group, and their health is < 55%, then skip cures for now.  (This may require additional logic for specific fights/zones.)
	if (${MTInMyGroup} && ${Actor[${MainTankID}].Health} < 55)
		return
	
	if ${DoCallCheckPosition}
	{
		if (${Actor[${KillTarget}].Name(exists)} && !${Actor[${KillTarget}].IsDead})
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			;Debug:Echo["CheckCures()::TankToTargetDistance: ${TankToTargetDistance}"]
	
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
		}
		elseif (${Actor[${MainTankID}].Name(exists)} && ${Actor[${MainTankID}].Distance} > 15)
		{
			Debug:Echo["Out of Range :: Moving to within 15m of tank"]
			call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 15 1 1
		}
		DoCallCheckPosition:Set[FALSE]
	}  
  
	; Check if curse curing on others is enabled it if is find out who we are to cure and do it.
	if !${CureCurseGroupMember.Equal[No One]}
	{
		CureTarget:Set[${CureCurseGroupMember.Token[1,:]}]
		Debug:Echo["CheckCures() - CureTarget for Curse; '${CureTarget}'"]
		if ${Me.Raid} > 0 
		{
			if ${Me.Raid[${CureTarget}].Cursed}
			{
				if ${Me.Ability[${SpellType[211]}].IsReady}
				{
					call CastSpellRange 211 0 0 0 ${Me.Raid[${CureTarget}].ID} 0 0 0 0 1 0
					wait 5
					while ${Me.CastingSpell}
					{
						if !${Me.Raid[${CureTarget}].Cursed}
						{
							press esc
							break
						}
						waitframe
					}	
				}
			}			
		}
		else
		{
			if ${Me.Group[${CureTarget}].Cursed}
			{
				Debug:Echo["CheckCures() - ${CureTarget} is CURSED -- curing."]
				if ${Me.Ability[${SpellType[211]}].IsReady}
				{
					call CastSpellRange 211 0 0 0 ${Me.Group[${CureTarget}].ID} 0 0 0 0 1 0
					wait 5
					while ${Me.CastingSpell}
					{
						if !${Me.Group[${CureTarget}].Cursed}
						{
							press esc
							break
						}
						waitframe
					}	
				}
			}
		}
	} 
  
	;; We need a throttle on this.  Obviously the client is not updating fast enough and we end up curing twice for the same thing (group cures especially.)  For now, we'll say 3 seconds.
	;; CheckCuresTimer should be set to ${Time.Timestamp} every time a group cure is cast throughout this function.  We'll leave single cures alone..for now.
	if (${Time.Timestamp} <= ${Math.Calc64[${CheckCuresTimer}+3]})
	{
		;Debug:Echo["Waiting for at least 3 seconds before checking cures again..."]
		return
	}
  
	if ( (${Me.GroupCount} > 1) && (${HaveAbility_TunaresGrace} || ${Me.Ability[${SpellType[220]}].IsReady}))
  	{
		i:Set[0]
		do
		{
			if (${Me.Group[${i}].Arcane} == -1 || ${Me.Group[${i}].Elemental} == -1)
				continue
				
			if (${Me.Group[${i}].InZone} && ${Me.Group[${i}].IsAfflicted} && ${Me.Group[${i}].Distance} <= 25)
			{
				;Debug:Echo["Group member ${i}. ${Me.Group[${i}].Name} (${Me.Group[${i}].Name}) is afflicted.  [${Me.Group[${i}].IsAfflicted} - ${Me.Group[${i}].Distance}]"]
				grpcure:Inc
			}
		}
		while ${i:Inc} <= ${Me.GroupCount}  	
	
		if ${grpcure} > 0
		{
			if (${HaveAbility_TunaresGrace} && ${Me.Ability[${SpellType[385]}].IsReady})
			{
				Debug:Echo["DEBUG:: grpcure at ${grpcure} casting Tunare's Grace"]
				call CastSpellRange 385 0 0 0 ${Me.ID} 0 0 0 0 1 0
				wait 5
				while ${Me.CastingSpell}
				{
					waitframe
				}	
			}
			elseif (${Me.Ability[${SpellType[220]}].IsReady})
			{
				echo "\aoDEBUG\ax:: \aygrpcure at ${grpcure} casting Abolishment\ax"
				Debug:Echo["DEBUG:: grpcure at ${grpcure} casting Abolishment"]
				call CastSpellRange 220 0 0 0 ${Me.ID} 0 0 0 0 1 0
				wait 5
				while ${Me.CastingSpell}
				{
					waitframe
				}	
			}
			;;;;; This is what we would do if we wanted to keep checking for cures after doing the "group cure"
			;wait 5
			;call FindAfflicted
			;if ${Return} <= 0
			;   return		
			CheckCuresTimer:Set[${Time.Timestamp}]					
			return
		}
		else
		{
			CheckCuresTimer:Set[${Time.Timestamp}]	
			return 		; if grpcure is 1 or less, then we shouldn't need to do anything else other than curses..which we already did
		}
	}	
  	
	if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
		call CureMe

	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	while ${Affcnt:Inc}<7 && ${Me.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;epicmode is not set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;Cure Ourselves first
	  	if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
			call CureMe

		;Check MT health and heal him if needed
		if ${Actor[${MainTankID}].Health} < ${Math.Calc[${MaxHealthModified} - 50]}
		{
			if ${MainTankID}==${Me.ID}
				call HealMe ${MaxHealthModified}
			else
				call HealMT
		}

		;check if we need heals
		call CheckGroupHealth 50
		if !${Return}
			break
	}

	CheckCuresTimer:Set[${Time.Timestamp}]	
	return
}

function FindAfflicted()
{
	declare temphl int local 1
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflicted int local 0

	;check for single target cures
	do
	{
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].Distance}<=${Me.Ability[${SpellType[210]}].ToAbilityInfo.Range}
		{
			if ${Me.Group[${temphl}].Arcane}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

			if ${Me.Group[${temphl}].Noxious}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]

			if ${Me.Group[${temphl}].Elemental}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]

			if ${Me.Group[${temphl}].Trauma}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

			if ${tmpafflictions}>${mostafflictions}
			{
				mostafflictions:Set[${tmpafflictions}]
				mostafflicted:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc} <= ${Me.GroupCount}

  ;Debug:Echo["FindAfflicted() returning ${mostafflicted}"]

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CheckPreAndChainHOTs()
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;
	;; This function does *NOTHING* unless one or more of the following options are selected in the UI:
	;; - Pre-HoT    		(Keep Heal over Time spells up and active, even when not in combat [both single target on MT as well as the group HoT abilities)
	;; - Chain HoT MT 		(Keep HoT abilities active on Main Tank [in combat only])
	;; - Chain HoT Group    (Keep HoT abilities active on group [in combat only])
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	variable int tempvar = 1
	variable int hot1 = 0
	variable int grphot = 0

	;if ${FuryDebugMode}
	;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax BEGIN"]

	if (${KeepMTHOTUp} && ${Actor[${MainTankID}].Name(exists)} && (${Me.InCombat} || ${Actor[${MainTankID}].InCombatMode}))
	{
		;if ${FuryDebugMode}
		;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax Chain HoT MT is selected"]

		tempvar:Set[1]
		do
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Checking for Regrowth (does ${Me.Maintained[${tempvar}].Name} Equal ${SpellType[7]} AND ${Me.Maintained[${tempvar}].Target.ID} == ${MainTankID})"]
			if (${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID} == ${MainTankID})
			{
				;if ${FuryDebugMode}
				;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax -- Regrowth active on MT"]
				if (${Me.Maintained[${tempvar}].Duration} > 1 && ${Me.Maintained[${tempvar}].Duration} < 20)
					hot1:Set[1]
				break
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${hot1} == 0 && ${Me.Ability[${SpellType[7]}].IsReady} && ${Me.CurrentPower} > ${Me.Ability[${SpellType[7]}].ToAbilityInfo.PowerCost} && ${Actor[${MainTankID}].Name(exists)}
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Casting Regrowth on MT"]
			call CastSpellRange 7 0 0 0 ${MainTankID} 0 0 1 1
			hot1:Set[1]
		}
	}
	if (${KeepGroupHOTUp} && (${Me.InCombat} || ${Actor[${MainTankID}].InCombatMode}))
	{
		;if ${FuryDebugMode}
		;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax Chain HoT Group is selected"]
		tempvar:Set[1]
		do
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Checking Autumn's Kiss"]
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;if ${FuryDebugMode}
				;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax -- Autumn's Kiss is ACTIVE"]
				grphot:Set[1]
				break
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${grphot}==0 && ${Me.Ability[${SpellType[15]}].IsReady} && ${Me.CurrentPower} > ${Me.Ability[${SpellType[15]}].ToAbilityInfo.PowerCost}
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Casting Autumn's Kiss"]
			call CastSpellRange 15 0 0 0 ${Me.ID} 0 0 1 1
		}
	}
	if (${KeepReactiveUp} && ${Me.Power} >= 55)
	{
		;if ${FuryDebugMode}
		;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax Pre-HoT is selected and power > 55%"]
		tempvar:Set[1]
		do
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Checking for Regrowth (does ${Me.Maintained[${tempvar}].Name} Equal ${SpellType[7]} AND ${Me.Maintained[${tempvar}].Target.ID} == ${MainTankID})"]
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID} == ${MainTankID}
			{
				;if ${FuryDebugMode}
				;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax -- Regrowth active on MT"]
				if (${Me.Maintained[${tempvar}].Duration} > 1 && ${Me.Maintained[${tempvar}].Duration} < 20)
					hot1:Set[1]
				if ${grphot} > 0
					break
				continue
			}
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Checking Autumn's Kiss"]
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;if ${FuryDebugMode}
				;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax -- Autumn's Kiss is ACTIVE"]
				grphot:Set[1]
				if ${hot1} > 0
					break
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${hot1} == 0 && ${Me.Ability[${SpellType[7]}].IsReady} && ${Me.CurrentPower} > ${Me.Ability[${SpellType[7]}].ToAbilityInfo.PowerCost} && ${Actor[${MainTankID}].Name(exists)}
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Casting Regrowth on MT"]
			call CastSpellRange 7 0 0 0 ${MainTankID} 0 0 1 1
		}

		if ${grphot} == 0 && ${Me.Ability[${SpellType[15]}].IsReady} && ${Me.CurrentPower} > ${Me.Ability[${SpellType[15]}].ToAbilityInfo.PowerCost}
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax - Casting Autumn's Kiss"]
			call CastSpellRange 15 0 0 0 ${Me.ID} 0 0 1 1
		}
	}

	if (${KeepMTHOTUp} || ${KeepGroupHOTUp} || ${KeepReactiveUp})
	{
		;; Hibernation
		if (!${Me.Maintained[${SpellType[11]}](exists)} && ${Me.Ability[${SpellType[11]}].IsReady})
		{
			;if ${FuryDebugMode}
			;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax Casting Hibernation on group"]			
			call CastSpellRange 11 0 0 0 ${Me.ID} 0 0 1 1
		}
	}

	;if ${FuryDebugMode}
	;	Debug:Echo["\at\[Fury:CheckPreAndChainHOTs()\]\ax END"]
}

function CheckEmergencyHeals()
{
	Debug:Echo["CheckEmergencyHeals():: START..."]
	if (${Actor[${MainTankID}].Health} <= ${Math.Calc[${MaxHealthModified} - 60]})
	{
		Debug:Echo["CheckEmergencyHeals():: MainTank health at ${Actor[${MainTankID}].Health}.  Calling EmergencyHeal()"]
		call EmergencyHeal ${MainTankID}
		; Hibernate
		if ${Actor[${KillTarget}].IsEpic}
		{
			if ${Me.Power} > 55 && !${Me.Maintained[${SpellType[11]}](exists)}
				call CastSpellRange 11
		}
	}		
		
	if (${Me.Health} <= ${Math.Calc[${MaxHealthModified} - 50]})
	{
		Debug:Echo["CheckEmergencyHeals():: My health at ${Me.Health}.  Calling HealMe()"]
		call HealMe ${MaxHealthModified}
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
	if (${CombatRez} && ${Actor[${MainTankID}].Name(exists)})
	{
		if (${Actor[${MainTankID}].IsDead})
			call CastSpellRange 300 303 1 0 ${MainTankID} 1
	}
}

function Cancel_Root()
{
}

function HandleGroupWiped()
{
	;;; There was a full group wipe and now we are rebuffing

	return OK
}

function CheckSKFD()
{
	; This is not being used...for now

  if !${Me.IsFD}
      return

  if !${Actor[${MainTankID}].Name(exists)}
      return

  if ${Actor[${MainTankID}].IsDead}
      return

  if ${Me.Health} < 20
      return

  call RemoveSKFD "Fury::CheckSKFD"
  return
}

function PostDeathRoutine()
{
	;;;;;
	;; This function is called after a character has either revived or been rezzed
	;;;;;

	CheckCuresTimer:Set[0]

	;; Just in case the Fury was asked to cast Tortoise Shell, and died before being able to cast it.
	CastTortoiseShell:Set[FALSE]
	
	return
}

atom(script) Fury_FinishedZoning(string TimeInSeconds)
{
	if ${KillTarget} && ${Actor[${KillTarget}].Name(exists)}
	{
		if !${Actor[${KillTarget}].InCombatMode}
			KillTarget:Set[0]
	}
}

function CheckRezzes()
{
	variable int tempgrp

	if ${Me.InCombatMode} && !${CombatRez}
		return

	if ${Me.GroupCount}	<= 1
		return

	tempgrp:Set[1]
	do
	{
		if (${Me.Group[${tempgrp}].InZone} && ${Me.Group[${tempgrp}].IsDead})
		{
			if (${Me.InRaid} && ${Me.Ability[${SpellType[380]}].IsReady})
			{
				call CastSpellRange 380 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
			}
			elseif ${Me.Ability[${SpellType[300]}].IsReady}
			{
				call CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
			}
			elseif ${Me.Ability[${SpellType[301]}].IsReady}
			{
				call CastSpellRange 301 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
			}
			elseif ${Me.Ability[${SpellType[302]}].IsReady}
			{
				call CastSpellRange 302 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
			}
			else
			{
				call CastSpellRange 303 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
			}
		}
	}
	while ${tempgrp:Inc}<=${Me.GroupCount}

}

function TortoiseShell()
{
	if ${Me.Ability[id,4031903609].IsReady}
	{
		CurrentAction:Set[Combat :: Casting Tortoise Shell!]
		if ${FuryDebugMode}
			Debug:Echo["\at\[Fury:TortoiseShell\]\ax Casting \ayTortoise Shell\ax..."]

		call CastSpellNOW "Tortoise Shell" 4031903609 ${Me.ID} TRUE
	}

	wait 5
	if (!${Me.Ability[id,4031903609].IsReady})
	{
		if (${CastTortoiseShellCaller.Length} > 1)
		{
			eq2execute /tell ${CastTortoiseShellCaller} Tortoise Shell Active!
			CastTortoiseShellCaller:Set[""]
		}
		CastTortoiseShell:Set[FALSE]
	}
}

function SpiritOfTheWolf()
{
	variable uint TimerStart = ${Time.SecondsSinceMidnight}
	variable bool AllGroupInZone = FALSE
	variable uint GroupCounter = 1
	;; Cast Spirit of the Wolf after all group members have finished zoning, are alive, and are in range or 10 seconds, whichever comes first
	CurrentAction:Set[Checking 'Spirit of the Wolf']
	do
	{
		do
		{
			if (${Me.Group[${GroupCounter}].InZone} && !${Me.Group[${GroupCounter}].IsDead} && ${Me.Group[${GroupCounter}].Distance} <= 50)
				AllGroupInZone:Set[TRUE]
			else
				AllGroupInZone:Set[FALSE]
		}
		while ${GroupCounter:Inc} < ${Me.Group}

		if (${AllGroupInZone})
		{
			if ${FuryDebugMode}
				Debug:Echo["\at\[Fury:SpiritOfTheWolf\]\ax Casting \aySpirit of the Wolf\ax (all group members in zone, etc.)"]
			call CastSpell "Spirit of the Wolf" 2119211019 0 1 1
			wait 5
			return
		}

	}
	while (${Time.SecondsSinceMidnight} <= ${Math.Calc[${TimerStart}+10]})

	if ${FuryDebugMode}
		Debug:Echo["\at\[Fury:SpiritOfTheWolf\]\ax Casting \aySpirit of the Wolf\ax (waited 10 seconds...)"]
	call CastSpell "Spirit of the Wolf" 2119211019 0 1 1
	wait 5
	return
}