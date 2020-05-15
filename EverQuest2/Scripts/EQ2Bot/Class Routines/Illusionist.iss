;*************************************************************
;Illusionist.iss
;by pygar & Amadeus
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20121118
	;;;;

	call EQ2BotLib_Init

	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Buffs]
	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[Buffs]:Move[4]
	ui -load -parent "Buffs@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_UI}/${Me.SubClass}_Buffs.xml"

	declare IllyDebugMode bool script FALSE
	declare MezzMode bool script FALSE
	declare Makepet bool script FALSE
	declare BuffAspect bool script FALSE
	declare BuffRune bool script FALSE
	declare BuffPowerRegen bool script TRUE
	declare StartHO bool script TRUE
	declare DPSMode bool script TRUE
	declare UltraDPSMode bool script FALSE
	declare SummonImpOfRo bool script FALSE
	declare UseTouchOfEmpathy bool script FALSE
	declare UseDoppleganger bool script FALSE
	declare BuffEmpathicAura bool script FALSE
	declare BuffEmpathicBreeze bool script FALSE
	declare UseIlluminate bool script FALSE
	declare BlinkMode bool script FALSE
	declare HaveMythical bool script FALSE
	declare LastSpellCast int script 0
	declare InPostDeathRoutine bool script FALSE
	declare IllyCasterBuffsOnSet bool script FALSE
	declare IllyCasterBuffsOn collection:string script
	declare IllyDPSBuffsOnSet bool script FALSE
	declare IllyDPSBuffsOn collection:string script
	declare MakePetWhileInCombat bool script TRUE
	declare ChainStunMode bool script FALSE
	declare Custom custom_overrides script
	declare ManaFlowThreshold int script 60
	declare CureMode bool script FALSE
	declare StunMode bool script FALSE
	declare HaveAbility_TimeWarp bool script FALSE
	declare HaveAbility_PeaceOfMind bool script FALSE
	declare HaveAbility_Perpetuality bool script FALSE
	declare TimeWarpers collection:uint script
	declare UseChronosiphoning bool script FALSE
	declare UseNullifyingStaff bool script FALSE
	declare RefreshPowerTimer uint script 0
	declare FightingEpicMob bool script FALSE
	declare FightingHeroicMob bool script FALSE
	declare KillTargetCheck int script 0
	declare CureMagicIsInstantCast bool script FALSE
	declare CheckHealsTimer uint script 0
	
	BuffAspect:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAspect,FALSE]}]
	BuffRune:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffRune,FALSE]}]
	BuffPowerRegen:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffPowerRegen,TRUE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	Makepet:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Makepet,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	;BuffTime_Compression:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffTime_Compression,]}]
	;BuffIllusory_Arm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffIllusory_Arm,]}]
	;BuffArms_of_Imagination:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffArms_of_Imagination,]}]
	DPSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[DPSMode,TRUE]}]
	UltraDPSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UltraDPSMode,FALSE]}]
	SummonImpOfRo:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Summon Imp of Ro,FALSE]}]
	UseTouchOfEmpathy:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseTouchOfEmpathy,FALSE]}]
	UseDoppleganger:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDoppleganger,FALSE]}]
	BuffEmpathicAura:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEmpathicAura,FALSE]}]
	BuffEmpathicBreeze:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEmpathicBreeze,FALSE]}]
	UseIlluminate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseIlluminate,FALSE]}]
	BlinkMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BlinkMode,FALSE]}]
	MakePetWhileInCombat:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MakePetWhileInCombat,TRUE]}]
	ChainStunMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ChainStunMode,FALSE]}]
	ManaFlowThreshold:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ManaFlowThreshold,60]}]
	UIElement[EQ2 Bot].FindUsableChild[sldManaFlowThreshold,slider]:SetValue[${ManaFlowThreshold}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureMode,FALSE]}]
	StunMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[StunMode,FALSE]}]

	NoEQ2BotStance:Set[TRUE]

	Event[EQ2_FinishedZoning]:AttachAtom[Illusionist_FinishedZoning]

	if (${Me.Equipment[Mirage Star](exists)} && ${Me.Equipment[1].Tier.Equal[MYTHICAL]})
		HaveMythical:Set[TRUE]
	elseif ${Me.Maintained[Mirage Mastery](exists)}
		HaveMythical:Set[TRUE]
		
	;;; Optimizations to avoid having to check if an ability exists all of the time
	if (${Me.Ability[Time Warp](exists)})
		HaveAbility_TimeWarp:Set[TRUE]
	if !${Me.Ability[${SpellType[387]}](exists)}		
		UseIlluminate:Set[FALSE]
	if ${Me.Ability[${SpellType[385]}](exists)}		
		UseChronosiphoning:Set[TRUE]
	if ${Me.Ability[${SpellType[396]}](exists)}
		UseNullifyingStaff:Set[TRUE]
	if ${Me.Ability[${SpellType[383]}](exists)}
		HaveAbility_PeaceOfMind:Set[TRUE]
	if (${Me.Ability[Perpetuality](exists)} || ${Me.Ability[id,2869627733](exists)})
		HaveAbility_Perpetuality:Set[TRUE]
	if (${Me.Ability[Cure Magic](exists)})
	{
		do 
		{
			waitframe
		}
		while (!${Me.Ability[Cure Magic].IsAbilityInfoAvailable})

		if (${Me.Ability[Cure Magic].ToAbilityInfo.CastingTime} <= 0)
		{
			echo "[EQ2Bot-Illusionist] \ay Cure Magic is an Instant Cast Ability\ax"
			CureMagicIsInstantCast:Set[TRUE]
		}
	}
		
	;; Set this to TRUE, as desired, for testing
	Debug:Enable
	IllyDebugMode:Set[TRUE]
}

function Pulse()
{
	declare BuffTarget string local

	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;; Note:  If you need to pulse on more than one interval (e.g. some things every half second, other things every 4 seconds) you will
	;         need to create another variable similar to ClassPulseTimer for your other timers.
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

	;; check this at least every 1 seconds, after bot has been started.
	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+1000]})
	{
		; Check mezzmode
		if ${MezzMode}
			call Mezmerise_Targets

		; check heals/cures
		call CheckHeals

		; check power (It should not be necessary to call this function here.)
		;call RefreshPower

		;call CheckSKFD

		;; Prismatic Proc
		;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
		if !${MainTank} || ${AutoMelee}
		{
			if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
			{
				if ${Actor[${MainTankID}].InCombatMode}
				{
					if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
					{
						if ${IllyDebugMode}
							Debug:Echo["Pulse() -- Stopping autofollow"]		
						EQ2Execute /stopfollow
						AutoFollowingMA:Set[FALSE]
						waitframe
					}
					if ${Me.Ability[${SpellType[72]}].IsReady}
					{
						BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
						if !${BuffTarget.Equal["No one"]}
						{
							if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
							{
								call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
								LastSpellCast:Set[72]
								ClassPulseTimer:Set[${Script.RunningTime}]
								return
							}
							else
								echo "ERROR2: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]} (${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}),exactname]}, does not exist!"
						}
						else
						{
							call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
							LastSpellCast:Set[72]
							ClassPulseTimer:Set[${Script.RunningTime}]
							return
						}
					}
					call CastSomething	
				}
			}
		}
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; The following routines are only called once.  They just need to wait until specific conditions have occurred
	;;;;;;
	;; Wait to populate "haste" listbox until after in a group of at least 3.  (Can be manually updated any time via UI.)
	if (!${IllyDPSBuffsOnSet} && (${Me.Group} > 2 || ${Me.Raid} > 2))
	{
		IllyDPSBuffsOnSet:Set[TRUE]
		Script[EQ2Bot].VariableScope.EQ2Bot:RefreshList["lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot",BuffDPS,1,1,0]
	}

	;; Wait to populate "caster proc spell" listbox until after in a group of at least 3.  (Can be manually updated any time via UI.)
	if (!${IllyCasterBuffsOnSet} && (${Me.Group} > 2 || ${Me.Raid} > 2))
	{
		IllyCasterBuffsOnSet:Set[TRUE]
		Script[EQ2Bot].VariableScope.EQ2Bot:RefreshList["lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot",BuffCasterDPS,1,1,1]
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}

function Class_Shutdown()
{
	Event[EQ2_FinishedZoning]:DetachAtom[Illusionist_FinishedZoning]
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Aspect]
	PreSpellRange[2,1]:Set[21]

	;haste
	PreAction[3]:Set[Melee_Buff]
	PreSpellRange[3,1]:Set[35]

	; ie, dynamism
	PreAction[4]:Set[Caster_Buff]
	PreSpellRange[4,1]:Set[40]

	PreAction[5]:Set[Rune]
	PreSpellRange[5,1]:Set[20]

	PreAction[6]:Set[Clarity]
	PreSpellRange[6,1]:Set[22]
	
	PreAction[7]:Set[MakePet]
	PreSpellRange[7,1]:Set[355]

	PreAction[8]:Set[AA_Empathic_Aura]
	PreSpellRange[8,1]:Set[391]

	PreAction[9]:Set[AA_Empathic_Breeze]
	PreSpellRange[9,1]:Set[392]

	PreAction[10]:Set[AA_Time_Compression]
	PreSpellRange[10,1]:Set[393]

	PreAction[11]:Set[AA_Illusory_Arm]
	PreSpellRange[11,1]:Set[394]
	
	PreAction[12]:Set[AA_Arms_of_Imagination]
	PreSpellRange[12,1]:Set[505]	

	PreAction[13]:Set[SummonImpOfRoBuff]
}

function Combat_Init()
{
	;;;;;;;;;;;;;;;;; DPS ;;;;;;;;;;;;;;;;;

	;; Slow casting NUKE and DAZE
	Action[1]:Set[NukeDaze]
	SpellRange[1,1]:Set[61]

	;; Mental DOT
	Action[2]:Set[MindDoT]
	SpellRange[2,1]:Set[70]
	
	;; Theorems
	Action[3]:Set[Theorems]
	SpellRange[3,1]:Set[51]
	
	;; Master Strike
	MobHealth[4,1]:Set[20]
	MobHealth[4,2]:Set[100]
	SpellRange[4,1]:Set[501]
	Action[4]:Set[Master_Strike]

	;; Chromatic Storm
	Action[5]:Set[Storm]
	SpellRange[5,1]:Set[91]

	;; Slow recast, Encounter DOT
	Action[6]:Set[Shower]
	SpellRange[6,1]:Set[388]

	;; Stifle over time, and NUKE
	Action[7]:Set[Silence]
	SpellRange[7,1]:Set[260]


	;;;;;;;;;;;;;;;;; STUNS ;;;;;;;;;;;;;;;;;

	;; Group Encounter fast casting Stun
	;;; NOTE: This is handled in CheckStuns

	;; Single Target Stun (longer duration)
	;;; NOTE: This is handled in CheckStuns

	;;;;;;;;;;;;;;;;; UTILITY ;;;;;;;;;;;;;;;;;

	;; Savante
	;;; NOTE: This is handled in RefreshPower()

	;; Mana Shroud
	;;; NOTE: This is handled in RefreshPower()

	;; Power Drain -> Group
	;;; NOTE: This is handled in RefreshPower()

	;; Smite of Consistency
	MobHealth[8,1]:Set[0]
	MobHealth[8,1]:Set[100]
	SpellRange[8,1]:Set[400]
	Action[8]:Set[SmiteOfConsistency]

	;; Absorb Magic
	Action[9]:Set[AbsorbMagic]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	SpellRange[9,1]:Set[363]
}

function PostCombat_Init()
{
	;PostAction[1]:Set[]
	;PostSpellRange[1,1]:Set[]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare ActorID uint local
	declare InternalBuffCounter int local
	
	;echo "DEBUG:: Buff_Routine(${PreSpellRange[${xAction},1]}:${SpellType[${PreSpellRange[${xAction},1]}]})"
	;CurrentAction:Set[Buff Routine :: ${PreAction[${xAction}]} (${xAction})]

	if (!${DoNoCombat})
	{
		if (!${InPostDeathRoutine} && !${CheckingBuffsOnce})
		{
			call CheckHeals
			call RefreshPower
			;call CheckSKFD
	
			;; Prismatic Proc
			;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
			if !${MainTank} || ${AutoMelee}
			{
				if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
				{
					if ${Actor[${MainTankID}].InCombatMode}
					{
						if ${Me.Ability[${SpellType[72]}].IsReady}
						{
							BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
							if !${BuffTarget.Equal["No one"]}
							{
								if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
								{
									call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
									LastSpellCast:Set[72]
									return
								}
								else
									echo "ERROR3: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]} (${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}), does not exist!"
							}
							else
							{
								call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
								LastSpellCast:Set[72]
								return
							}
						}
					}
				}
			}
		}
	}
	
	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID} 0 0 1 0 0
			break

		case Clarity
			if ${BuffPowerRegen}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID} 0 0 1 0 0
			}
			break

		case Rune
			if ${Math.Calc[${Me.MaxConc}-${Me.UsedConc}]} < 1
				break
			if ${BuffRune}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID} 0 0 1 0 0
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break

		case Aspect
			if ${Math.Calc[${Me.MaxConc}-${Me.UsedConc}]} < 1
				break
			if ${BuffAspect}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID} 0 0 1 0 0
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break

		case MakePet
			if ${Makepet}
			{
				if (!${MakePetWhileInCombat} && ${Me.InCombatMode})
				{
					break
				}

				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]}
					wait 2
					if (${Me.Ability[${SpellType[382]}].IsReady})
						call CastSpellRange 382 0 0 0 ${Me.Pet.ID} 0 0 0 1
				}
			}
			break

		case Melee_Buff
			Counter:Set[1]
			tempvar:Set[1]

			;; If we have mythical, just cast on self since it is a group buff
			if (${HaveMythical})
			{
				;; ONLY if we have someone selected. Mythical Illy vs Mythical Illy sucks.
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID} 0 0 1 0 0
				break
			}

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			InternalBuffCounter:Set[0]
			IllyDPSBuffsOn:Clear
			;echo "Debug.RAPIDITY::  IllyDPSBuffsOn.Used: ${IllyDPSBuffsOn.Used}"
			do
			{
				;echo "Debug.RAPIDITY:: Checking current maintained buffs... ${Counter} of ${Me.CountMaintained}"
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;echo "Debug.RAPIDITY:: - Found Maintained buff: ${Me.Maintained[${Counter}].Name}"
					;iterate through the members to buff
					if ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						;echo "Debug.RAPIDITY:: -- ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems} recipients are selected"
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
							;echo "Debug.RAPIDITY:: --- ${BuffTarget}.  Checking ${Me.Maintained[${Counter}].Target.ID} against ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}" 
							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
							{
								;echo "Debug.RAPIDITY:: ---- adding ${Me.Maintained[${Counter}].Target.ID},${Me.Maintained[${Counter}].Target.Name} to IllyDPSBuffsOn"
								IllyDPSBuffsOn:Set[${Me.Maintained[${Counter}].Target.ID},${Me.Maintained[${Counter}].Target.Name}]
								BuffMember:Set[OK]
								InternalBuffCounter:Inc
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							;echo "Debug.RAPIDITY:: -- No match.. cancelling"
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						;echo "Debug.RAPIDITY:: -- No one is currently selected to be receiving this buff ...cancelling"
						Me.Maintained[${Counter}]:Cancel
					}
				}
			}
			while ${Counter:Inc}<=${Me.CountMaintained}

			;echo "Debug.RAPIDITY:: ${InternalBuffCounter} players are buffed (${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems} should be, according to the UI)"
			if (${InternalBuffCounter} == ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems})
			{
				;echo "Debug.RAPIDITY:: No players need buffed ...breaking."
				break
			}

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				;echo "Debug.RAPIDITY:: ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems} selected" 
				do
				{
					BuffTarget:Set[${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					;echo "Debug.RAPIDITY:: - BuffTarget: ${BuffTarget} (Counter: ${Counter})"
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						;echo "Debug.RAPIDITY:: -- ActorID: ${ActorID}"
						if ${Actor[${ActorID}].Type.Equal[PC]}
						{
							;echo "Debug.RAPIDITY:: --- Actor is 'PC'"
							if (${Me.Group[${BuffTarget.Token[1,:]}].InZone} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								;echo "Debug.RAPIDITY:: --- Actor is in Group"
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
								{
									;echo "Debug.RAPIDITY:: --- Actor distance: ${Actor[${ActorID}].Distance} (within ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range})"
									if (!${IllyDPSBuffsOn.Element[${ActorID}](exists)})
									{
										;echo "Debug.RAPIDITY:: ---- Casting RAPIDITY" 
										call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
									}
								}
							}
						}
						else
						{
							;echo "Debug.RAPIDITY:: --- Actor is *NOT* a 'PC'"
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								;echo "Debug.RAPIDITY:: --- Actor distance: ${Actor[${ActorID}].Distance} (within ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range})"
								if (!${IllyDPSBuffsOn.Element[${ActorID}](exists)})
								{
									;echo "Debug.RAPIDITY:: ---- Casting RAPIDITY" 
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
								}
							}
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case Caster_Buff
			if ${Me.Level} < 35
				break
			
			Counter:Set[1]
			tempvar:Set[1]
			IllyCasterBuffsOn:Clear
			InternalBuffCounter:Set[0]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
							{
								IllyCasterBuffsOn:Set[${Me.Maintained[${Counter}].Target.ID},${Me.Maintained[${Counter}].Target.Name}]
								BuffMember:Set[OK]
								InternalBuffCounter:Inc
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintained target so cancel it
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
			
			;echo "Debug.Synergism:: ${InternalBuffCounter} players are buffed (${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems} should be, according to the UI"
			if (${InternalBuffCounter} == ${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems})
			{
				;echo "Debug.Synergism:: No players need buffed ...breaking."
				break
			}
			

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						if ${Actor[${ActorID}].Type.Equal[PC]}
						{
							if (${Me.Group[${BuffTarget.Token[1,:]}].InZone} || ${Me.Raid[${BuffTarget.Token[1,:]}].InZone} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
								{
									if (!${IllyCasterBuffsOn.Element[${ActorID}](exists)})
									{
										call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
									}
								}
							}
						}
						else
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								if (!${IllyCasterBuffsOn.Element[${ActorID}](exists)})
								{
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
								}
							}
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case AA_Time_Compression
			BuffTarget:Set[${UIElement[cbBuffTime_Compression@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if (${BuffTarget.Equal["No one"]} || ${BuffTarget.Equal["N/A"]})
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				break
			}

			if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID} == ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID})
				break
			else
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
					wait 2
				}
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if (${Me.Group[${BuffTarget.Token[1,:]}].InZone})
					{
						if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
				}
			}
			break

		case AA_Illusory_Arm
			BuffTarget:Set[${UIElement[cbBuffIllusory_Arm@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if (${BuffTarget.Equal["No one"]} || ${BuffTarget.Equal["N/A"]})
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				break
			}
			
			if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID} == ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID})
				break
			else
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
					wait 2
				}
			}
			
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if (${Me.Group[${BuffTarget.Token[1,:]}].InZone})
					{
						if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
				}
			}
			break
			
		case AA_Arms_of_Imagination
			BuffTarget:Set[${UIElement[cbBuffArms_of_Imagination@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if (${BuffTarget.Equal["No one"]} || ${BuffTarget.Equal["N/A"]})
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				break
			}
			
			if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID} == ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID})
				break
			else
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
					wait 2
				}
			}
			
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if (${Me.Group[${BuffTarget.Token[1,:]}].InZone})
					{
						if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
				}
			}
			break			

		case AA_Empathic_Aura
			if ${BuffEmpathicAura}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID} 0 0 1 0 0
					wait 5
				}
			}
			break

		case AA_Empathic_Breeze
			if ${BuffEmpathicBreeze}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID} 0 0 1 0 0
					wait 5
				}
			}
			break

		case SummonImpOfRoBuff
			if (${SummonImpOfRo})
			{
				if !${Me.Maintained["Summon: Imp of Ro"](exists)}
					call CastSpell "Summon: Imp of Ro"
			}
			break

		default
			return BuffComplete
	}
}

function CheckCastBeam()
{
	variable int spellsused
	
	; Cure Arcane
	if (${Me.Arcane} >= 1 || ${Me.Elemental} >= 1 || ${Me.Noxious} >= 1 || ${Me.Trauma} >= 1)
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		LastSpellCast:Set[210]
		spellsused:Inc
	}

	;; Cast Beam if it is ready
	if (${Me.Ability[${SpellType[60]}].IsReady})
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return CombatComplete
		LastSpellCast:Set[60]
		call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
		return ${spellsused}
	}
	elseif (${LastSpellCast} != 60)
	{
		if ${IllyDebugMode}
			Debug:Echo["EQ2Bot-Debug:: LastSpellCast: ${LastSpellCast}"]
		if (${Me.Ability[${SpellType[60]}].TimeUntilReady} <= 1)
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			LastSpellCast:Set[60]
			call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1 0 1
			spellsused:Inc
			return ${spellsused}
		}
	}
	
	call ProcessTriggers
	return 0
}

/* This function will be called between every spell or spell group regardless of
   DPS or UltraDPS mode. */
function CheckNonDps(... Args)
{
	variable int spellsused

	; check heals/cures
	call CheckHeals
	
	if ${ChainStunMode}
		call ChainStunMez
	
	; Check mezzmode
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	; AA Bewilderment -- Use whenever it's up. It casts fast anyway.
	if ${Me.Ability[id,3903537279].IsReady}
	{
		if ${KillTarget}
		{
			if ${Actor[${MainTankID}].InCombatMode}
			{
				call VerifyTarget ${KillTarget}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange AbilityID=3903537279 TargetID=${KillTarget} IgnoreMaintained=1
				spellsused:Inc
			}
		}
	}

	; Check stunmode
	if ${StunMode}
	{
		if ${KillTarget} && !${Actor[${KillTarget}].IsEpic}
		{
			;; TODO -- double check these later
			if (${Me.Level} > 20 || !${Actor[${KillTarget}].IsSolo})
			{
				if (${Me.Group} <= 2 || (${Me.Group} > 2 && ${Actor[${MainTankID}].Health} <= 50))
				{
					if ${Me.Ability[${SpellType[190]}].IsReady} && ${Me.Maintained[${SpellType[191]}].Target.ID} != ${KillTarget}
					{
						if ${Me.Maintained[${SpellType[190]}].Target.ID} != ${KillTarget}
						{
							call VerifyTarget ${KillTarget}
							if ${Return.Equal[FALSE]}
								return CombatComplete
							call CastSpellRange TargetID=${KillTarget} start=190 ignoremaintained=1
							spellsused:Inc
						}
					}
					elseif ${Me.Ability[${SpellType[191]}].IsReady} && ${Me.Maintained[${SpellType[190]}].Target.ID} != ${KillTarget}
					{
						if ${Me.Maintained[${SpellType[191]}].Target.ID} != ${KillTarget}
						{
							call VerifyTarget ${KillTarget}
							if ${Return.Equal[FALSE]}
								return CombatComplete
							call CastSpellRange TargetID=${KillTarget} start=191 ignoremaintained=1
							spellsused:Inc
						}
					}
				}
			}
		}
		return ${spellsused}
	}

	; check power
	call RefreshPower
}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, uint TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	declare BuffTarget string local
	variable float TankToTargetDistance
	variable bool bReturn

	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;

	;; Check to make sure the target is valid FIRST and then use the ability this function was called for before anything else
	call VerifyTarget ${TargetID} "TRUE" "Illusionist-_CastSpellRange"
	if ${Return.Equal[FALSE]}
		return CombatComplete

	;; Cast the spell we wanted to cast originally before doing anything else
	LastSpellCast:Set[${start}]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	bReturn:Set[${Int[${Return}]}]

	if (${DoNoCombat})
		return ${bReturn}
		
	if ${ChainStunMode}
	{
		call ChainStunMez
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
		
	if ${DoCallCheckPosition}
	{
		TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
		if ${IllyDebugMode}
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
			if ${IllyDebugMode}
				Debug:Echo["_CastSpellRange():: Out of Range - Moving to within 20m of tank"]
			call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 20 1 1
		}
		DoCallCheckPosition:Set[FALSE]
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	if (!${MainTank} || ${AutoMelee})
	{
		if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
		{
			if ${Actor[${KillTarget}].Health} > 35
			{
				if ${UseIlluminate}
				{
					if (${Me.Ability[${SpellType[387]}].IsReady})
					{
						call VerifyTarget ${KillTarget}
						if ${Return.Equal[FALSE]}
							return CombatComplete
						call CastSpellRange 387 0 0 0 ${KillTarget} 0 0 0 1
						LastSpellCast:Set[387]
					}
				}
				;; Chronosiphoning (Always cast this when it is ready!)
				if (${UseChronosiphoning} && ${Me.Ability[${SpellType[385]}].IsReady})
				{
					call CheckActorForEffect ${KillTarget} 654 -1
					if ${Return.Equal[FALSE]}
					{
						call VerifyTarget ${KillTarget}
						if ${Return.Equal[FALSE]}
							return CombatComplete
						call CastSpellRange 385 0 0 0 ${KillTarget} 0 0 0 1
						LastSpellCast:Set[385]
					}
				}
				;; 'Nullifying Staff' and the mob is within range
				if ${UseNullifyingStaff}
				{
					if (${Me.Ability[${SpellType[396]}].IsReady})
					{
						if (${Actor[${KillTarget}].Distance2D} < ${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[396]}].ToAbilityInfo.MaxRange}]})
						{
							call VerifyTarget ${KillTarget}
							if ${Return.Equal[FALSE]}
								return CombatComplete
							call CastSpellRange 396 0 0 0 ${KillTarget} 0 0 0 1
							LastSpellCast:Set[396]
							spellsused:Inc
							if !${AutoMelee}
							{
								if ${Me.AutoAttackOn}
									EQ2Execute /toggleautoattack
							}
						}
					}
				}
			}
			if ${Actor[${KillTarget}].Health} > 5
			{
				if ${Me.Ability[${SpellType[72]}].IsReady}
				{
					BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
					if !${BuffTarget.Equal["No one"]}
					{
						if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
						{
							call VerifyTarget ${KillTarget}
							if ${Return.Equal[FALSE]}
								return CombatComplete
							call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
							LastSpellCast:Set[72]
							call CheckCastBeam
							if ${Return.Equal[CombatComplete]}
								return CombatComplete
						}
						else
							echo "ERROR1: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]} (${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}), does not exist!"
					}
					else
					{
						call VerifyTarget ${KillTarget}
						if ${Return.Equal[FALSE]}
							return CombatComplete
						call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
						LastSpellCast:Set[72]
						call CheckCastBeam
						if ${Return.Equal[CombatComplete]}
							return CombatComplete
					}
				}
			}
		}
	}

	; check power every 3 times this function is called (otherwise it affects performance since this function is called so often)
	if (${RefreshPowerTimer} > 2)
	{
		if ${IllyDebugMode}
			Debug:Echo["_CastSpellRange() -- calling RefreshPower()"]
		call RefreshPower
		RefreshPowerTimer:Set[0]
	}
	else
		RefreshPowerTimer:Inc

	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
		return CombatComplete

	; Fast casting DoT
	if (${Me.Ability[${SpellType[80]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 476 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			LastSpellCast:Set[80]
			call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
		}
		call CheckCastBeam
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	
	;; "Time Warp" (and/or any other skills that are dependent upon whether a mob is heroic, epic, or solo.
	if ${FightingEpicMob} || ${FightingHeroicMob}
	{
		if (${HaveAbility_TimeWarp})
		{
			if ${Me.Ability[time warp].IsReady}
			{
				if (${Actor[${KillTarget}].Health} > 20)
					call DoTheTimeWarp
			}
		}
	}
	else
	{		
		if (${HaveAbility_TimeWarp} && ${Me.Group} == 1)
		{
			if ${Me.Ability[time warp].IsReady}
			{
				if (${Actor[${KillTarget}].Health} > 50)
					call DoTheTimeWarp
			}
		}			
	}

	; Cure Arcane
	if (${Me.Arcane} >= 1 || ${Me.Elemental} >= 1 || ${Me.Noxious} >= 1 || ${Me.Trauma} >= 1)
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		LastSpellCast:Set[210]
	}
	return ${bReturn}
}

function Combat_Routine(int xAction)
{
	declare BuffTarget string local
	declare spellsused int local
	declare DoShortTermBuffs bool local
	declare TankToTargetDistance float local
	spellsused:Set[0]
	
	if ${IllyDebugMode}
		Debug:Echo["Combat_Routine(${xAction}) called"]

	if (!${Actor[${KillTarget}].Name(exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0 || ${KillTarget} == 0)
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [1]"]
		return CombatComplete
	}

	if ${InPostDeathRoutine} || ${CheckingBuffsOnce}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (In PostDeathRoutine or CheckingBuffsOnce) [2]"]
		return
	}

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Stopping autofollow"]		
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if (${Me.Pet.Name(exists)})
	{
		if (${Me.Pet.Target.ID} != ${KillTarget} || !${Me.Pet.InCombatMode})
		{
			Actor[${KillTarget}]:DoTarget
			wait 2
			EQ2Execute /pet attack
		}
	}

	if ${ChainStunMode}
	{
		; Entrance
		if (${Me.Ability[${SpellType[352]}].IsReady})
		{
			LastSpellCast:Set[352]
			call _CastSpellRange 352 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [3]"]
				return CombatComplete
			}
		}
		; Bewilderment
		if (${Me.Ability[${SpellType[191]}].IsReady})
		{
			LastSpellCast:Set[191]
			call _CastSpellRange 191 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [4]"]
				return CombatComplete
			}
		}
		; Paranoia
		;; TODO -- double check these later
		if (${Me.Level} > 20 || !${Actor[${KillTarget}].IsSolo})
		{
			if (${Me.Group} <= 2 || (${Me.Group} > 2 && ${Actor[${MainTankID}].Health} <= 50))
			{
				if (${Me.Ability[${SpellType[190]}].IsReady})
				{
					LastSpellCast:Set[190]
					call _CastSpellRange 190 0 0 0 ${KillTarget} 0 0 0 1
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [5]"]
						return CombatComplete
					}
				}
			}
		}
		; Regalia
		if (${Me.Ability[${SpellType[92]}].IsReady})
		{
			LastSpellCast:Set[92]
			call _CastSpellRange 92 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [6]"]
				return CombatComplete
			}
		}
		; Entrance
		if (${Me.Ability[${SpellType[352]}].IsReady})
		{
			LastSpellCast:Set[352]
			call _CastSpellRange 352 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [7]"]
				return CombatComplete
			}
		}
	}	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;; Set some local variables... ;;;;
	FightingEpicMob:Set[FALSE]
	FightingHeroicMob:Set[FALSE]
	if ${Actor[${KillTarget}].IsEpic}
		FightingEpicMob:Set[TRUE]
	elseif ${Actor[${KillTarget}].IsHeroic}
		FightingHeroicMob:Set[TRUE]
	if ${FightingEpicMob}
	{
		if (${Actor[${KillTarget}].Health} > 20)
			DoShortTermBuffs:Set[TRUE]
		else
			DoShortTermBuffs:Set[FALSE]
	}
	elseif ${FightingHeroicMob}
	{
		if (${Actor[${KillTarget}].Health} > 50)
			DoShortTermBuffs:Set[TRUE]
		else
			DoShortTermBuffs:Set[FALSE]		
	}
	else
	{		
		if ${Actor[${KillTarget}].Health} > 75
			DoShortTermBuffs:Set[TRUE]
		else
			DoShortTermBuffs:Set[FALSE]		
	}
	;echo "TEST: FightingEpicMob: ${FightingEpicMob} -- FightingHeroicMob: ${FightingHeroicMob} -- DoShortTermBuffs: ${DoShortTermBuffs}"
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Aggro Control...  [TODO:  Move to new function and mimic Fury's routine]
	if (${Actor[${KillTarget}].Target.ID} == ${Me.ID} && !${MainTank})
	{
		if (${Me.Health} < 70)
		{
			if ${Me.Ability["Phase"].IsReady}
			{
				if ${IllyDebugMode}
					Debug:Echo["Casting 'Phase' on ${Actor[${KillTarget}].Name}!"]
				call _CastSpellRange 357 0 0 0 ${aggroid} 0 0 0 1
				LastSpellCast:Set[357]
				spellsused:Inc
			}
			elseif ${Me.Ability["Blink"].IsReady} && ${BlinkMode}
			{
				if ${IllyDebugMode}
					Debug:Echo["Casting 'Blink'!"]
				call _CastSpellRange 358 0 0 0 ${Me.ID} 0 0 0 1
				LastSpellCast:Set[358]
				spellsused:Inc
			}
		}
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]

	if ${DoHOs}
		objHeroicOp:DoHO

	if ${StartHO}
	{
		if !${EQ2.HOWindowActive} && ${Me.InCombatMode}
		{
			call CastSpellRange 303
			LastSpellCast:Set[303]
			spellsused:Inc
		}
	}
	

	call CheckNonDps
	if ${Return.Equal[CombatComplete]}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [8]"]
		return CombatComplete
	}
	else
		spellsused:Inc[${Int[${Return}]}]

	;; Add back later...(TODO)
		;call CheckSKFD

	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
	
	call DoShortTermBuffs ${DoShortTermBuffs}
	if ${Return.Equal[CombatComplete]}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [9]"]
		return CombatComplete
	}
	else
		spellsused:Inc[${Int[${Return}]}]

	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
	
	if ${StunMode}
	{
		call CheckStuns
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [11]"]
			return CombatComplete
		}
		else
			spellsused:Inc[${Int[${Return}]}]		
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
	

	if (${KillTargetCheck} != ${KillTarget})
	{
		KillTargetCheck:Set[${KillTarget}]
		call DoInitialSpellLineup ${FightingEpicMob} ${FightingHeroicMob}
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [13]"]
			return CombatComplete
		}
		else
			spellsused:Inc[${Int[${Return}]}]
		if (${KillTarget} != ${KillTargetCheck})
		{
			if ${IllyDebugMode}
				Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [14]"]
			return CombatComplete
		}
	}
	else
	{
		call CheckCastBeam
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [15]"]
			return CombatComplete
		}
		else
			spellsused:Inc[${Int[${Return}]}]
	}
	
	if (${KillTarget} != ${KillTargetCheck})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [17]"]
		return CombatComplete
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
	
	if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
	{
		if ${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]}
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			if ${IllyDebugMode}
				Debug:Echo["Combat_Routine():: TankToTargetDistance: ${TankToTargetDistance}"]

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

	call CheckNonDps
	if ${Return.Equal[CombatComplete]}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [18]"]
		return CombatComplete
	}
	else
		spellsused:Inc[${Int[${Return}]}]
		
	if (${KillTarget} != ${KillTargetCheck})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [20]"]
		return CombatComplete
	}
	
	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [21]"]
		return CombatComplete
	}
	else
		spellsused:Inc[${Int[${Return}]}]

	if (${UseDoppleganger} && !${MainTank} && ${Me.Group} > 1)
	{
		if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 50)
		{
			if ${Me.Ability[Doppleganger].IsReady}
			{
				switch ${Actor[${KillTarget}].ConColor}
				{
					case Red
					case Orange
					case Yellow
						if (${Actor[${KillTarget}].EncounterSize} > 2 || ${Actor[${KillTarget}].Difficulty} >= 2)
						{
							;echo "EQ2Bot-DEBUG: Casting 'Doppleganger' on ${MainTankPC}"
							eq2execute /useabilityonplayer ${MainTankPC} "Doppleganger"
							wait 1
							do
							{
								waitframe
							}
							while ${Me.CastingSpell}
						}
						break
					default
						if (${FightingEpicMob} || ${Actor[${KillTarget}].IsNamed})
						{
							;echo "EQ2Bot-DEBUG: Casting 'Doppleganger' on ${MainTankPC}"
							eq2execute /useabilityonplayer ${MainTankPC} "Doppleganger"
							wait 1
							do
							{
								waitframe
							}
							while ${Me.CastingSpell}
						}
						break
				}
			}
		}
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	;; Check Group members to see if anyone needs 'Touch of Empathy'
	if ${UseTouchOfEmpathy} && ${Me.Group} > 1
	{
		if ${Me.Ability["Touch of Empathy"].IsReady}
		{
			variable string TargetsTarget = ${Actor[${KillTarget}].Target.Name}
			variable string TargetsTargetClass = ${Actor[PC,${TargetsTarget},exactname].Class}
			if (!${TargetsTarget.Equal[${MainTankPC}]} && ${Actor[pc,${TargetsTarget},exactname].Name(exists)} && ${Me.Group[${TargetsTarget}].InZone})
			{
				switch ${TargetsTargetClass}
				{
				case Paladin
				case Shadowknight
				case Brawler
				case Bruiser
				case Guardian
				case Berserker
					break

				default
					;echo "EQ2Bot-DEBUG: Casting 'Touch of Empathy' on ${TargetsTarget}"
					eq2execute /useabilityonplayer ${TargetsTarget} "Touch of Empathy"
					wait 3
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					break
				}
			}
		}
	}

	if (${KillTarget} != ${KillTargetCheck})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [23]"]
		return CombatComplete
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	;; 'Nullifying Staff' and the mob is within range
	if ${UseNullifyingStaff}
	{
		if (${Me.Ability[${SpellType[396]}].IsReady})
		{
			if (${Actor[${KillTarget}].Distance2D} < ${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[396]}].ToAbilityInfo.MaxRange}]})
			{
				call _CastSpellRange 396 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [24]"]
					return CombatComplete
				}
				LastSpellCast:Set[396]
				spellsused:Inc
				if !${AutoMelee}
				{
					if ${Me.AutoAttackOn}
						EQ2Execute /toggleautoattack
				}
			}
		}
	}

	if (${KillTarget} != ${KillTargetCheck})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [26]"]
		return CombatComplete
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	;; Melee Debuff (Dismay) -- only for Epic mobs for now
	if ${Me.Power} > 40
	{
		if ${FightingEpicMob}
		{
			if ${Me.Ability[${SpellType[50]}](exists)}
			{
				call CheckActorForEffect ${KillTarget} 265 315
				if ${Return.Equal[FALSE]}
				{	
					if (${Me.Ability[${SpellType[50]}].IsReady})
					{
						call _CastSpellRange 50 0 0 0 ${KillTarget} 0 0 0 1
						if ${Return.Equal[CombatComplete]}
						{
							if ${IllyDebugMode}
								Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [27]"]
							return CombatComplete						
						}
						LastSpellCast:Set[50]
						spellsused:Inc
					}
				}
			}
		}
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	;; If Target is Epic, be sure that the Daze Debuff (Aneurysm) is being used as often as possible, but only once we have casted our initial spells.)  (This is the slow casting Nuke.)
	if ${FightingEpicMob}
	{
		if ${Me.Ability[${SpellType[61]}](exists)}
		{
			if (${Me.Ability[${SpellType[61]}].IsReady})
			{
				call _CastSpellRange 61 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [28]"]
					return CombatComplete				
				}
				LastSpellCast:Set[61]
				spellsused:Inc
			}
		}
	}

	call CheckNonDps
	if ${Return.Equal[CombatComplete]}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [29]"]
		return CombatComplete
	}
	else
		spellsused:Inc[${Int[${Return}]}]
		

	if (${KillTarget} != ${KillTargetCheck})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [31]"]
		return CombatComplete
	}

	; check heals/cures
	call CheckHeals
	
	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [32]"]
		return CombatComplete
	}
	else
		spellsused:Inc[${Int[${Return}]}]
	
	if (${KillTarget} != ${KillTargetCheck})
	{
		if ${IllyDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target changed: CombatComplete) [34]"]
		return CombatComplete
	}
		
	if ${IllyDebugMode}
		Debug:Echo["Combat_Routine() -- Entering Switch (${xAction}: ${Action[${xAction}]})"]
	switch ${Action[${xAction}]}
	{
		;; Straight Nukes
		case Silence
			;; This spell is definately not worth it for epic fights.  They are immune to the silence and the dps from it is crap
			if !${FightingEpicMob}
			{
				if (${Me.Ability[${SpellType[260]}].IsReady})
				{
					call _CastSpellRange 260 0 0 0 ${KillTarget} 0 0 0 1
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [35]"]
						return CombatComplete					
					}
					spellsused:Inc
				}
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [37]"]
					return CombatComplete
				}
			}
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}
			break

		;; Aneurysm
		case NukeDaze
			if (${Me.Ability[${SpellType[61]}].IsReady})
			{
				call _CastSpellRange 61 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [38]"]
					return CombatComplete				
				}
				spellsused:Inc
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [40]"]
					return CombatComplete
				}
			}
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}			
			break
			
		;; Single Target DoTs
		case MindDoT
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
				break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckActorForEffect ${KillTarget} 168 315
				if ${Return.Equal[FALSE]}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [41]"]
						return CombatComplete					
					}
					spellsused:Inc
					if (${Me.Ability[${SpellType[80]}].IsReady})
					{
						call CheckActorForEffect ${KillTarget} 476 315
						if ${Return.Equal[FALSE]}
						{
							call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
							if ${Return.Equal[CombatComplete]}
							{
								if ${IllyDebugMode}
									Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [42]"]
								return CombatComplete						
							}
							spellsused:Inc
						}
					}
				}
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [44]"]
					return CombatComplete
				}
			}		
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}			
			break

		;; TODO (Why does this break without a cast?)
		case Shower
			break

		;; Chromatic Storm
		case Storm
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
				break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckActorForEffect ${KillTarget} 169 312
				if ${Return.Equal[FALSE]}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [45]"]
						return CombatComplete					
					}
					spellsused:Inc
				}
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [46]"]
					return CombatComplete
				}
			}
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}			
			break

		case Master_Strike
			if (${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5)
			{
				if ${spellsused} < 1 && !${MezzMode}
				{
					call CastSomething			
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [47]"]
						return CombatComplete
					}
				}	
				if ${MezzMode}
				{
					call Mezmerise_Targets
					if (${Return.Equal[CombatComplete]})
						return CombatComplete
				}			
				break
			}

			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [48]"]
						return CombatComplete					
					}
					spellsused:Inc
				}
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [49]"]
					return CombatComplete
				}
			}	
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}
			break
			
		case SmiteOfConsistency
			if (${Me.Level} < 20 && ${Actor[${KillTarget}].Distance2D} <= 5)
			{
				if (${Me.Ability[${SpellType[400]}].IsReady})
				{
					call _CastSpellRange 400 0 0 0 ${KillTarget} 0 0 0 1
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [50]"]
						return CombatComplete				
					}
					spellsused:Inc
				}
				if ${spellsused} < 1 && !${MezzMode}
				{
					call CastSomething			
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [52]"]
						return CombatComplete
					}
				}
				if ${MezzMode}
				{
					call Mezmerise_Targets
					if (${Return.Equal[CombatComplete]})
						return CombatComplete
				}	
			}	
			break
		
		case Theorems
			;if ${UltraDPSMode}
			;{
			;	call CastSomething		
			;	if ${Return.Equal[CombatComplete]}
			;	{
			;		if ${IllyDebugMode}
			;			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [53]"]
			;		return CombatComplete
			;	}					
			;	if ${MezzMode}
			;	{
			;		call Mezmerise_Targets
			;		if (${Return.Equal[CombatComplete]})
			;			return CombatComplete
			;	}
			;	break
			;}
			if ${Me.Level} < 32
				break
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 30
				break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckActorForEffect ${KillTarget} 218 315
				if ${Return.Equal[FALSE]}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					if ${Return.Equal[CombatComplete]}
					{
						if ${IllyDebugMode}
							Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [54]"]
						return CombatComplete				
					}
					spellsused:Inc
				}
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [55]"]
					return CombatComplete
				}
			}			
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}
			break

		case AbsorbMagic
			; TODO -- what logic should dictate when this should be used?  It used to be "Dispel Magic", now it is "Absorb Magic".
			break
			
			if !${UltraDPSMode}
			{
				call _CastSpellRange ${SpellRange[${xAction},1]}
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [56]"]
					return CombatComplete				
				}
				spellsused:Inc
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [57]"]
					return CombatComplete
				}
			}	
			if ${MezzMode}
			{
				call Mezmerise_Targets
				if (${Return.Equal[CombatComplete]})
					return CombatComplete
			}				
			break
			
		default
			if (${Me.Ability[${SpellType[60]}].IsReady})
			{
				call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete) [58]"]
					return CombatComplete				
				}
				spellsused:Inc
			}
			if ${spellsused} < 1 && !${MezzMode}
			{
				call CastSomething			
				if ${Return.Equal[CombatComplete]}
				{
					if ${IllyDebugMode}
						Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [59]"]
					return CombatComplete
				}
			}	
			if ${MezzMode}
				call Mezmerise_Targets
			return CombatComplete
	}

	if !${MezzMode}
	{
		if ${spellsused} < 1
		{
			call CastSomething			
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid per CastSomething(): CombatComplete) [60]"]
				return CombatComplete
			}
		}	
	}
	if ${MezzMode}
		call Mezmerise_Targets

	if ${IllyDebugMode}
	{
		Debug:Echo["Combat_Routine() -- Exiting Switch (${Action[${xAction}]}) (spellsused: ${spellsused})"]
		Debug:Echo["Combat_Routine() -- Completed (spellsused: ${spellsused})"]
	}
}

function CastSomething()
{
	declare BuffTarget string local

	;; If this function is called, it is because we went through the combat routine without casting any spells.
	;; This function is intended to cast SOMETHING in order to keep "Perpetuality" going.

	if (!${HaveAbility_Perpetuality})
	{
		echo "CastSomething() -- We do not have Perpetuality; so, no reason to process this function."
		return
	}

	if ${ChainStunMode}
	{
		call ChainStunMez
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
		return CombatComplete

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; Things we should be checking EVERY time
	;; Prismatic Proc
	;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
	if !${MainTank} || ${AutoMelee}
	{
		if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
		{
			if ${Actor[${KillTarget}].Health} > 35
			{
				if ${UseIlluminate}
				{
					if (${Me.Ability[${SpellType[387]}].IsReady})
					{
						call VerifyTarget ${KillTarget}
						if ${Return.Equal[FALSE]}
							return "CombatComplete"
						call CastSpellRange 387 0 0 0 ${KillTarget} 0 0 0 1
						LastSpellCast:Set[387]
						call CheckCastBeam
						if ${Return.Equal[CombatComplete]}
							return CombatComplete
					}
				}
				;; Chronosiphoning (Always cast this when it is ready!)
				if (${UseChronosiphoning} && ${Me.Ability[${SpellType[385]}].IsReady})
				{
					call CheckActorForEffect ${KillTarget} 654 -1
					if ${Return.Equal[FALSE]}
					{
						call VerifyTarget ${KillTarget}
						if ${Return.Equal[FALSE]}
							return "CombatComplete"
						call CastSpellRange 385 0 0 0 ${KillTarget} 0 0 0 1
						LastSpellCast:Set[385]
					}
					call CheckCastBeam
					if ${Return.Equal[CombatComplete]}
						return CombatComplete
				}
				;; 'Nullifying Staff' and the mob is within range
				if ${UseNullifyingStaff}
				{
					if (${Me.Ability[${SpellType[396]}].IsReady})
					{
						if (${Actor[${KillTarget}].Distance2D} < ${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[396]}].ToAbilityInfo.MaxRange}]})
						{
							call VerifyTarget ${KillTarget}
							if ${Return.Equal[FALSE]}
								return "CombatComplete"
							call CastSpellRange 396 0 0 0 ${KillTarget} 0 0 0 1
							LastSpellCast:Set[396]
							spellsused:Inc
							if !${AutoMelee}
							{
								if ${Me.AutoAttackOn}
									EQ2Execute /toggleautoattack
							}
							call CheckCastBeam
							if ${Return.Equal[CombatComplete]}
								return CombatComplete
						}
					}
				}
			}
			if ${Actor[${KillTarget}].Health} > 5
			{
				if ${Me.Ability[${SpellType[72]}].IsReady}
				{
					BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
					if !${BuffTarget.Equal["No one"]}
					{
						if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
						{
							call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
							LastSpellCast:Set[72]
							call CheckCastBeam
							if ${Return.Equal[CombatComplete]}
								return CombatComplete
							else
								return
						}
						else
							echo "ERROR1: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]} (${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}), does not exist!"
					}
					else
					{
						call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
						LastSpellCast:Set[72]
						call CheckCastBeam
						if ${Return.Equal[CombatComplete]}
							return CombatComplete
						else
							return
					}
				}
			}
		}
	}

	; Master's Strike
	if (${Me.Ability[${SpellType[501]}].IsReady})
	{
		call CheckCondition MobHealth 20 100
		if ${Return.Equal[OK]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return "CombatComplete"
			call CastSpellRange 501 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete
			}
			LastSpellCast:Set[501]
			return
		}
	}

	; Nightmare
	if (${Me.Ability[${SpellType[80]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 476 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return "CombatComplete"
			call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete
			}
			LastSpellCast:Set[80]
			return
		}
	}

	; Brainburst
	if (${Me.Ability[${SpellType[70]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 168 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return "CombatComplete"
			call CastSpellRange 70 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete
			}		
			LastSpellCast:Set[70]
			return
		}
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Theorems
	if (${Me.Ability[${SpellType[51]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 218 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return "CombatComplete"
			call CastSpellRange 51 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete
			}		
			return
		}
	}

	; fast-casting encounter stun
	if (${Me.Ability[${SpellType[191]}].IsReady})
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return "CombatComplete"
		call CastSpellRange 191 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete
		}
		LastSpellCast:Set[191]
		return
	}

	; melee debuff
	if (${Me.Ability[${SpellType[50]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 265 315
		if ${Return.Equal[FALSE]}
		{	
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return "CombatComplete"
			call CastSpellRange 50 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete
			}
			LastSpellCast:Set[50]
			return
		}
	}

	; extract mana
	if (${Me.Power} < 65 && ${Me.Ability[${SpellType[309]}].IsReady})
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return "CombatComplete"
		call CastSpellRange 309 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete
		}
		LastSpellCast:Set[309]
		return
	}
	
	; Smite of Consistency
	if (${Me.Level} < 20)
	{
		if (${Me.Ability[${SpellType[400]}].IsReady})
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return "CombatComplete"
			call CastSpellRange 400 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
			{
				if ${IllyDebugMode}
					Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
				return CombatComplete
			}
			LastSpellCast:Set[400]
			return
		}
	}

	; root (Disabling for now...Aug. 2015)   TODO -- Root logic!
	;if (${Me.Ability[${SpellType[230]}].IsReady})
	;{
	;	call VerifyTarget ${KillTarget}
	;	if ${Return.Equal[FALSE]}
	;		return "CombatComplete"
	;	call CastSpellRange 230 0 0 0 ${KillTarget} 0 0 0 1
	;	if ${Return.Equal[CombatComplete]}
	;	{
	;		if ${IllyDebugMode}
	;			Debug:Echo["CastSomething() -- Exiting (Target no longer valid: CombatComplete)"]
	;		return CombatComplete
	;	}
	;	LastSpellCast:Set[230]
	;	return
	;}
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]
	CheckHealsTimer:Set[0]

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
	}
}

function Have_Aggro()
{
	;if ${Actor[${aggroid}].Name.Find["Master P"]}
	;	return

	;; Use this whenver we have aggro...regardless  (de-aggro "Bewilderment")
	;if ${Me.Ability[id,3903537279].IsReady}
	;{
	;	announce "I have aggro...\n\\#FF6E6EUsing Bewilderment!" 3 1
	;	call CastSpellRange AbilityID=3903537279 TargetID=${aggroid} IgnoreMaintained=1
	;	return
	;}

	;; Aggro Control...
	if (${Me.Health} < 70 && ${Actor[${KillTarget}].Target.ID} == ${Me.ID})
	{
		if ${Me.Ability["Sever Hate"].IsReady}
		{
			call CastSpellRange 506 0 0 0 ${Me.ID} 0 0 0 1
			LastSpellCast:Set[506]
			call CheckCastBeam
			if ${Return.Equal[CombatComplete]}
				return CombatComplete			
			else
				return
		}
		elseif ${Me.Ability["Phase"].IsReady}
		{
			call CastSpellRange 357 0 0 0 ${aggroid} 0 0 0 1
			LastSpellCast:Set[357]
			call CheckCastBeam
			if ${Return.Equal[CombatComplete]}
				return CombatComplete			
			else
				return
		}
		elseif ${Me.Ability["Blink"].IsReady} && ${BlinkMode}
		{
			call CastSpellRange 358 0 0 0 ${Me.ID} 0 0 0 1
			LastSpellCast:Set[358]
			call CheckCastBeam
			if ${Return.Equal[CombatComplete]}
				return CombatComplete			
			else
				return
		}
	}

	; Illusory Allies
	if (!${Me.Grouped})
	{
		if ${Me.Ability["Illusory Allies"](exists)}
		{
			if ${Me.Ability["Illusory Allies"].IsReady}
			{
				call CastSpellRange 192 0 0 0 ${aggroid} 0 0 0 1
				LastSpellCast:Set[192]
				return
			}
		}
	}
}

function Lost_Aggro()
{
}

function MA_Lost_Aggro()
{
	if ${Me.Ability[${SpellType[386]}].IsReady}
	{
		call _CastSpellRange 386 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["MA_Lost_Aggro() -- Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete
		}
		LastSpellCast:Set[386]
	}
}

function MA_Dead()
{
}

function Cancel_Root()
{
}

function RefreshPower()
{
	;; Note:  For now, we are calling this function, regardless of whether ${UltraDPSMode} is TRUE or not.  This is changed for SF because of the
	;;        new situation where power is a major issue.  In the future, we might want to return this function when ${UltraDPSMode} is TRUE or 
	;;        else provide more logic here to handle ${UltraDPSMode} in a way so that we are not killing our DPS by being overly concerned about 
	;;        power.   For the moment, I think the way it is working now is the best option.
	
	if (${Me.InCombatMode} && ${IllyDebugMode})
		Debug:Echo["RefreshPower()"]
	
	declare tempvar int local
	declare MemberLowestPower int local
	call CommonPower
	
	;Spiritise Censer
	if ${Me.Level} < 75
	{
		if !${Swapping} && ${Me.Inventory[Spirtise Censer](exists)}
		{
			OriginalItem:Set[${Me.Equipment[Secondary].Name}]
			ItemToBeEquipped:Set[Spirtise Censer]
			call Swap
			Me.Equipment[Spirtise Censer]:Use
		}
	}

	;Extract Mana
	if (${Me.Power}<80 && ${Me.Ability[${SpellType[309]}].IsReady})
	{
		if (!${Me.InCombatMode})
		{
			call CastSpellRange 309
			LastSpellCast:Set[309]
		}
		elseif (${Me.Power}<55)
		{
			call CastSpellRange 309
			LastSpellCast:Set[309]
		}
	}

	if ${Me.Ability[${SpellType[360]}].IsReady}
	{
		if ${Me.Group} > 1 && ${ManaFlowThreshold} > 0
		{
			if ${Me.Power} > 45
			{
				;Mana Flow the lowest group member
				tempvar:Set[1]
				MemberLowestPower:Set[1]
				do
				{
					if (${Me.Group[${tempvar}].InZone} && ${Me.Group[${tempvar}].Power(exists)} && ${Me.Group[${tempvar}].Power}<60 && ${Me.Group[${tempvar}].Distance}<30)
					{
						if ${Me.Group[${tempvar}].Power}<=${Me.Group[${MemberLowestPower}].Power}
						{
							if !${Me.Group[${MemberLowestPower}].IsDead}
								MemberLowestPower:Set[${tempvar}]
						}
					}
				}
				while ${tempvar:Inc} < ${Me.GroupCount}
	
				if (${Me.InCombatMode} && ${IllyDebugMode})
					Debug:Echo["- Checking Mana Flow (lowest: ${MemberLowestPower}, ${Me.Group[${MemberLowestPower}].Power} vs. ${ManaFlowThreshold})"]
				if (${Me.Group[${MemberLowestPower}].InZone} && ${Me.Group[${MemberLowestPower}].Power(exists)})
				{
					if (${Me.Group[${MemberLowestPower}].Power} < ${ManaFlowThreshold} && ${Me.Group[${MemberLowestPower}].Distance} < 30  && ${Me.Health} > 30)
					{
						call CastSpellRange 360 0 0 0 ${Me.Group[${MemberLowestPower}].ID}
						LastSpellCast:Set[360]
					}
				}
			}
		}
	}

	;Mana Cloak the group if the Main Tank is low on power
	if (${Me.Ability[${SpellType[354]}].IsReady} && ${Me.InCombatMode})
	{
		if ${Me.Group[${MainTankPC}].InZone}
		{
			if ${IllyDebugMode}
				Debug:Echo["- Checking Mana Cloak"]
			if ${Actor[${MainTankID}].Power} < 60 && ${Actor[${MainTankID}].Distance}<50  && ${Actor[${MainTankID}].InCombatMode}
			{
				call CastSpellRange 354
				LastSpellCast:Set[354]
			}
		}
	}
	
	if (${Me.InCombatMode})
	{
		if ${Me.Ability[${SpellType[389]}].IsReady}
		{
			if ${IllyDebugMode}
				Debug:Echo["- Checking Savante"]
			if ${Me.Group} > 1
			{
				if ${Me.Power} > 25
				{
					; if anyone is below 60% power -- savante
					tempvar:Set[1]
					do
					{
						if ${Me.Group[${tempvar}].Power}<60
						{
							call CastSpellRange 389
							break
						}
					}
					while ${tempvar:Inc} < ${Me.GroupCount}
				}
			}
			else
			{
				if ${Me.Power} < 50
				{
					call CastSpellRange 389
				}
			}
		}
		if ${Me.Ability[${SpellType[90]}].IsReady}
		{
			if ${IllyDebugMode}
				Debug:Echo["- Checking Manatap 1"]
			if (${Actor[${KillTarget}].IsSolo})
			{
				;; return since ManaTap is the last thing in this function
				if (${UltraDPSMode} || ${DPSMode} || ${Me.Group} > 1 || ${Actor[${KillTarget}].Health} < 70)
					return
			}
			if ${Me.Power} > 5
			{
				if ${Me.Group} > 1
				{
					if ${IllyDebugMode}
						Debug:Echo["- Checking Manatap 2"]
					; if anyone is below 80% power -- Manatap
					tempvar:Set[1]
					do
					{
						if ${Me.Group[${tempvar}].Power}<80
						{
							call CastSpellRange 90 0 0 0 ${KillTarget} 0 0 0 1
						}
					}
					while ${tempvar:Inc} < ${Me.GroupCount}
				}
				elseif ${Me.Power} < 60
				{
					call CastSpellRange 90 0 0 0 ${KillTarget} 0 0 0 1
				}
			}
		}
	}
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
	
	if ${CureMode} || ${EpicMode}
		DoCures:Set[TRUE]
	elseif !${DPSMode} && !${UltraDPSMode}
		DoCures:Set[TRUE]
	else
		DoCures:Set[FALSE]

	if !${UltraDPSMode} || ${EpicMode}
	{
		; This routine will use 'Crystallized Spirits', the Fury 'Pact of Nature' ability (if applicable), etc...
		; CommonHeals also uses cure potions, if required and enabled. Would rather use potions and save cure arcane
		; for groupmates who need it -- especially since common cure potions are same as old rares.
		call CommonHeals 60
	}

	if (${DoCures} && ${Me.Ability[${SpellType[210]}].IsReady})
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
					if (${CureMagicIsInstantCast})
					{
						if ${Me.CastingSpell}
						{
							if (${Me.CastingSpell})
							{
								do
								{
									eq2execute /cancel_spellcast
									wait 3
								}
								while ${Me.CastingSpell}
							}
						}
						wait 2
						eq2execute /useabilityonplayer ${Me.Name} Cure Magic
						wait 5
						if (${Me.Group[${temphl}].Arcane} >= 1 || ${Me.Group[${temphl}].Elemental} >= 1 || ${Me.Group[${temphl}].Noxious} >= 1 || ${Me.Group[${temphl}].Trauma} >= 1)
						{
							if ${Me.CastingSpell}
							{
								if (${Me.CastingSpell})
								{
									do
									{
										eq2execute /cancel_spellcast
										wait 3
									}
									while ${Me.CastingSpell}
								}
							}
							wait 5
							eq2execute /useabilityonplayer ${Me.Name} Cure Magic
							wait 2
						}
					}
					else
						call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}
					LastSpellCast:Set[210]
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

objectdef _meztargets
{
	variable bool IsAoeMezzed=0
	variable bool IsShortMezzed=0
	variable bool IsLongMezzed=0
	variable bool IsMyMez=0
	variable bool NeedRemez=0

	member:bool IsMezzed()
	{
		if ${This.IsAoeMezzed} || ${This.IsShortMezzed} || ${This.IsLongMezzed}
			return TRUE
		return FALSE
	}

	member:bool IsMultiMezzed()
	{
		if ${Math.Calc[${This.IsAoeMezzed} + ${This.IsShortMezzed} + ${This.IsLongMezzed} - 1]}>0
			return TRUE
		return FALSE
	}

	method Initialize()
	{
	}
}

function Mezmerise_Targets()
{
	variable collection:_meztargets MezzTargets
	variable int Counter=1
	variable uint bufftgt
	variable uint originaltarget = ${Target.ID}
	variable index:actor Actors
	variable iterator ActorIterator
	declare tempvar int local
	declare aggrogrp bool local FALSE

	if (!${MezzMode})
		return

	; if we don't have a mez spell ready, no sense wasting time.
	if !${Me.Ability[${SpellType[353]}].IsReady} && !${Me.Ability[${SpellType[352]}].IsReady} && !${Me.Ability[${SpellType[92]}].IsReady}
		return

	;loop through all our maintained spells looking for mezzes
	do
	{
		bufftgt:Set[${Me.Maintained[${Counter}].Target.ID}]
		;check if the maintained buff is a mez
		if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[353]}]} /* AE Mez */
		{
			if !${MezzTargets.Element[${bufftgt}](exists)}
				MezzTargets:Set[${bufftgt},""]
			MezzTargets.Element[${bufftgt}].IsAoeMezzed:Set[TRUE]
			MezzTargets.Element[${bufftgt}].IsMyMez:Set[TRUE]
			if ${Me.Maintained[${Counter}].Duration} <=5
			{
				;check for multiple mezzes -- no need to remez if we've already hit him twice.
				if ${MezzTargets.Element[${bufftgt}].IsMultiMezzed}
					MezzTargets.Element[${bufftgt}].NeedRemez:Set[FALSE]
				else
					MezzTargets.Element[${bufftgt}].NeedRemez:Set[TRUE]
			}
		}
		if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[352]}]} /* Long Mez */
		{
			if !${MezzTargets.Element[${bufftgt}](exists)}
				MezzTargets:Set[${bufftgt},""]
			MezzTargets.Element[${bufftgt}].IsLongMezzed:Set[TRUE]
			MezzTargets.Element[${bufftgt}].IsMyMez:Set[TRUE]
			if ${Me.Maintained[${Counter}].Duration} <=5
			{
				;check for multiple mezzes -- no need to remez if we've already hit him twice.
				if ${MezzTargets.Element[${bufftgt}].IsMultiMezzed}
					MezzTargets.Element[${bufftgt}].NeedRemez:Set[FALSE]
				else
					MezzTargets.Element[${bufftgt}].NeedRemez:Set[TRUE]
			}
		}
		if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[92]}]} /* Short Mez */
		{
			if !${MezzTargets.Element[${bufftgt}](exists)}
				MezzTargets:Set[${bufftgt},""]
			MezzTargets.Element[${bufftgt}].IsShortMezzed:Set[TRUE]
			MezzTargets.Element[${bufftgt}].IsMyMez:Set[TRUE]
			if ${Me.Maintained[${Counter}].Duration} <=5
			{
				;check for multiple mezzes -- no need to remez if we've already hit him twice.
				if ${MezzTargets.Element[${bufftgt}].IsMultiMezzed}
					MezzTargets.Element[${bufftgt}].NeedRemez:Set[FALSE]
				else
					MezzTargets.Element[${bufftgt}].NeedRemez:Set[TRUE]
			}
		}
	}
	while ${Counter:Inc}<=${Me.CountMaintained}

	EQ2:QueryActors[Actors, Type =- "NPC" && Distance <= ${ScanRange}]
	Actors:GetIterator[ActorIterator]

	if ${ActorIterator:First(exists)}
	{
		do
		{
			if ${ActorIterator.Value.Type.Equal[NoKillNPC]}
				continue

			if ${Mob.ValidActor[${ActorIterator.Value.ID}]} && ${ActorIterator.Value.Target.Name(exists)}
			{
				;if its the kill target skip it
				if (${ActorIterator.Value.ID} == ${KillTarget})
					continue
				if ${Actor[${MainAssistID}].Target.ID}==${ActorIterator.Value.ID} || ${Actor[${MainTankID}].Target.ID}==${ActorIterator.Value.ID}
					continue

				;if it's an epic, skip it
				if ${ActorIterator.Value.IsEpic}
					continue

				tempvar:Set[1]
				aggrogrp:Set[FALSE]

				;check if its agro on a raid member or raid member's pet
				if ${Me.InRaid}
				{
					do
					{
						if ${ActorIterator.Value.Target.ID}==${Me.Raid[${tempvar}].ID} || (${ActorIterator.Value.Target.ID}==${Me.Raid[${tempvar}].Pet.ID})
						{
							aggrogrp:Set[TRUE]
							break
						}
					}
					while ${tempvar:Inc} <= ${Me.Raid}
				}
				elseif ${Me.GroupCount} > 1 /* check if its agro on a group member or group member's pet */
				{
					do
					{
						if ${ActorIterator.Value.Target.ID}==${Me.Group[${tempvar}].ID} || (${ActorIterator.Value.Target.ID}==${Me.Group[${tempvar}].Pet.ID} && ${Me.Group[${tempvar}].Pet.Name(exists)})
						{
							aggrogrp:Set[TRUE]
							break
						}
					}
					while ${tempvar:Inc} <= ${Me.GroupCount}
				}

				;check if its agro on me
				if ${ActorIterator.Value.Target.ID}==${Me.ID}
					aggrogrp:Set[TRUE]

				;if i have a mob charmed check if its agro on my charmed pet
				if ${Me.Maintained[${SpellType[351]}](exists)}
				{
					if ${ActorIterator.Value.Target.IsMyPet}
						aggrogrp:Set[TRUE]
				}

				if ${aggrogrp}
				{
					if !${MezzTargets.Element[${ActorIterator.Value.ID}](exists)}
						MezzTargets:Set[${ActorIterator.Value.ID},""]
					if ${MezzTargets.Element[${ActorIterator.Value.ID}].IsMezzed}
						continue
				}
				aggrogrp:Set[FALSE]
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	if ${MezzTargets.FirstKey(exists)}
	{
		; Need to loop through checking for remezzes first
		do
		{
			;Debug:Echo[MEZ TARGETS FOR ${Actor[${MezzTargets.CurrentKey}].ID}]
			;Debug:Echo[IsAoE: ${MezzTargets.CurrentValue.IsAoeMezzed}]
			;Debug:Echo[IsShort: ${MezzTargets.CurrentValue.IsShortMezzed}]
			;Debug:Echo[IsLong: ${MezzTargets.CurrentValue.IsLongMezzed}]
			;Debug:Echo[NeedRemez: ${MezzTargets.CurrentValue.NeedRemez}]
			;Debug:Echo[IsMezzed: ${MezzTargets.CurrentValue.IsMezzed}]
			;Debug:Echo[IsMultiMezzed: ${MezzTargets.CurrentValue.IsMultiMezzed}]

			if ${MezzTargets.CurrentValue.NeedRemez}
			{
				if ${Me.AutoAttackOn}
					eq2execute /toggleautoattack

				if ${Me.RangedAutoAttackOn}
					eq2execute /togglerangedattack

				if ${Me.Ability[${SpellType[352]}].IsReady}
				{
					call VerifyTarget ${MezzTargets.CurrentKey}
					if ${Return.Equal[FALSE]}
						return CombatComplete
					call CastSpellRange start=352 TargetID=${MezzTargets.CurrentKey} IgnoreMaintained=1
					LastSpellCast:Set[352]
					MezzTargets.CurrentValue.NeedRemez:Set[FALSE]
					MezzTargets.CurrentValue.IsLongMezzed:Set[TRUE]
				}
				elseif ${Me.Ability[${SpellType[353]}].IsReady}
				{
					call VerifyTarget ${MezzTargets.CurrentKey}
					if ${Return.Equal[FALSE]}
						return CombatComplete
					call CastSpellRange start=353 TargetID=${MezzTargets.CurrentKey} IgnoreMaintained=1
					LastSpellCast:Set[353]
					MezzTargets.CurrentValue.NeedRemez:Set[FALSE]
					MezzTargets.CurrentValue.IsAoeMezzed:Set[TRUE]
				}
				elseif ${Me.Ability[${SpellType[92]}].IsReady}
				{
					call VerifyTarget ${MezzTargets.CurrentKey}
					if ${Return.Equal[FALSE]}
						return CombatComplete
					call CastSpellRange start=92 TargetID=${MezzTargets.CurrentKey} IgnoreMaintained=1
					LastSpellCast:Set[92]
					MezzTargets.CurrentValue.NeedRemez:Set[FALSE]
					MezzTargets.CurrentValue.IsShortMezzed:Set[TRUE]
				}
			}
		}
		while ${MezzTargets.NextKey(exists)}
		noop ${MezzTargets.FirstKey}

		; and then loop through checking for non-mezzed targets, and mezzing as required.
		do
		{
			if ${MezzTargets.CurrentValue.IsMezzed}
				continue
			if ${Me.AutoAttackOn}
				eq2execute /toggleautoattack

			if ${Me.RangedAutoAttackOn}
				eq2execute /togglerangedattack

			Actor[${MezzTargets.CurrentKey}]:DoTarget
			wait 10 ${Target.ID}==${MezzTargets.CurrentKey}

			call CheckForMez
			if ${Return.Length}
				continue

			if ${Me.Ability[${SpellType[353]}].IsReady} /* AoE mez first */
			{
				call VerifyTarget ${MezzTargets.CurrentKey}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=353 TargetID=${MezzTargets.CurrentKey}
				LastSpellCast:Set[353]
			}
			elseif ${Me.Ability[${SpellType[352]}].IsReady} /* Long term mez second */
			{
				call VerifyTarget ${MezzTargets.CurrentKey}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=352 TargetID=${MezzTargets.CurrentKey}
				LastSpellCast:Set[352]
			}
			elseif ${Me.Ability[${SpellType[92]}].IsReady} /* Short term mez third */
			{
				call VerifyTarget ${MezzTargets.CurrentKey}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange start=92 TargetID=${MezzTargets.CurrentKey}
				LastSpellCast:Set[92]
			}
		}
		while ${MezzTargets.NextKey(exists)}
	}

	if ${Me.IsHated}
	{
		if ${Actor[${KillTarget}].Name(exists)} && ${Actor[${KillTarget}].Health}>1
		{
			Target ${KillTarget}
			wait 20 ${Target.ID}==${KillTarget}
		}
		else
		{
			EQ2Execute /target_none
			wait 20 !${Target.Name(exists)}
			KillTarget:Set[]
		}
	}
}

function CheckSKFD()
{
	;; This is not being called....for now.
	
	if !${Me.IsFD}
		return

	if !${Actor[${MainTankID}].Name(exists)}
		return

	if ${Actor[${MainTankID}].IsDead}
		return

	if ${Me.Health} < 20
		return

	call RemoveSKFD "Illusionist::CheckSKFD"
	return
}

atom(script) Illusionist_FinishedZoning(string TimeInSeconds)
{
	if ${KillTarget} && ${Actor[${KillTarget}].Name(exists)}
	{
		if !${Actor[${KillTarget}].InCombatMode}
			KillTarget:Set[0]
	}
}

function PostDeathRoutine()
{
	variable int i

	;; This function is called after a character has either revived or been rezzed
	InPostDeathRoutine:Set[TRUE]

	;; Auto-Follow
	if (${AutoFollowMode} && !${Me.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 5
	}

	;;;;;;;;;;;;;;;
	;; Do Buffs before anything else
	i:Set[1]
	do
	{
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
	;;
	;;;;;;;;;;;;;;;

	InPostDeathRoutine:Set[FALSE]
	return
}

function DoTheTimeWarp()
{
	declare BuffTarget string local
	declare ActorID uint local
	declare Counter uint local
	declare DoBreak bool local
	declare LastTimeWarp uint local
	
	DoBreak:Set[FALSE]
	ActorID:Set[0]
	Counter:Set[1]
	if ${UIElement[lbBuffTimeWarp@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
	{
		do
		{
			BuffTarget:Set[${UIElement[lbBuffTimeWarp@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
			ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
			;echo "DEBUG::DoTheTimeWarp() -- BuffTarget: ${BuffTarget}, ActorID: ${ActorID}"
			if (${ActorID} <= 0)
				continue
			switch ${Actor[${ActorID}].Type}
			{
				case PC
					;echo "DEBUG::DoTheTimeWarp() - Checking ${Actor[${ActorID}].Name}...1"
					if (!${Me.Group[${Actor[${ActorID}].Name}].InZone})
						break
				case Me
					;echo "DEBUG::DoTheTimeWarp() - Checking ${Actor[${ActorID}].Name}...2"
					if (${Actor[${ActorID}].IsDead})
						break
					;echo "DEBUG::DoTheTimeWarp() - Checking ${Actor[${ActorID}].Name}...3 (is ${Actor[${ActorID}].Distance} < ${Me.Ability[Time Warp].ToAbilityInfo.Range}?)"
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[Time Warp].ToAbilityInfo.Range} || !${NoAutoMovement})
					{
						LastTimeWarp:Set[${TimeWarpers.Element[${Actor[${ActorID}].Name}]}]
						;echo "DEBUG::DoTheTimeWarp() - Checking if ${Actor[${ActorID}].Name} is ready for Time Warp... (${LastTimeWarp} vs. ${Time.Timestamp})"
						
						if (${Time.Timestamp} > ${Math.Calc64[${LastTimeWarp}+135]})
						{
							;echo "DEBUG::DoTheTimeWarp() - Casting 'Time Warp' on ${Actor[${ActorID}].Name}"
							call CastSpellRange 504 0 0 0 ${ActorID} 0 0 1 0 0
							TimeWarpers:Set[${Actor[${ActorID}].Name},${Time.Timestamp}]
							ActorID:Set[0]
							DoBreak:Set[TRUE]	
						}
					}
					break
				
				default
					break
			}
			if ${DoBreak}
				break
		}
		while ${Counter:Inc}<=${UIElement[lbBuffTimeWarp@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
	}		
}

function DoShortTermBuffs(bool DoShortTermBuffs)
{
	variable int spellsused
	
	if ${IllyDebugMode}
		Debug:Echo["DoShortTermBuffs(${DoShortTermBuffs})"]
	
	;; Illuminate
	if ${DoShortTermBuffs} && ${UseIlluminate}
	{
		if (${Me.Ability[${SpellType[387]}].IsReady})
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 387 0 0 0 ${KillTarget} 0 0 0 1
			LastSpellCast:Set[387]
			spellsused:Inc
		}
	}
	;; Chronosiphoning
	if ${UseChronosiphoning}
	{
		if (${Me.Ability[${SpellType[385]}].IsReady})
		{
			call CheckActorForEffect ${KillTarget} 654 -1
			if ${Return.Equal[FALSE]}
			{
				call VerifyTarget ${KillTarget}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange 385 0 0 0 ${KillTarget} 0 0 0 1
				LastSpellCast:Set[385]
				spellsused:Inc
			}
		}
	}
	
	;; 'Nullifying Staff' and the mob is within range
	if ${UseNullifyingStaff}
	{
		if (${Me.Ability[${SpellType[396]}].IsReady})
		{
			if (${Actor[${KillTarget}].Distance2D} < ${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[396]}].ToAbilityInfo.MaxRange}]})
			{
				call VerifyTarget ${KillTarget}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				call CastSpellRange 396 0 0 0 ${KillTarget} 0 0 0 1
				LastSpellCast:Set[396]
				spellsused:Inc
				if !${AutoMelee}
				{
					if ${Me.AutoAttackOn}
						EQ2Execute /toggleautoattack
				}
			}
		}
	}
	
	if ${DoShortTermBuffs}
	{
		;; Short Duration Buff .. adds INT, Focus, Disruption, etc. (cast any time it's ready)
		if (${Me.Ability[${SpellType[23]}].IsReady})
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 23 0 0 0 ${KillTarget} 0 0 0 1
			LastSpellCast:Set[23]
			spellsused:Inc
		}
		
		;; Short Duration Buff .. adds proc to group members for 20 seconds (Peace of Mind)
		if (${HaveAbility_PeaceOfMind} && ${Me.Ability[${SpellType[383]}].IsReady})
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 383 0 0 0 ${KillTarget} 0 0 0 1
			LastSpellCast:Set[383]
			spellsused:Inc
		}

		;; Short Duration Buff .. adds proc to group members for 20 seconds (Destructive Rampage)
		if (${Me.Ability[${SpellType[503]}].IsReady})
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 503 0 0 0 ${KillTarget} 0 0 0 1
			LastSpellCast:Set[503]
			spellsused:Inc
		}
	}
	
	if ${IllyDebugMode}
		Debug:Echo["DoShortTermBuffs() -- Exiting (spellsused: ${spellsused})"]
	return ${spellsused}
}

function DoInitialSpellLineup(bool FightingEpicMob, bool FightingHeroicMob)
{
	variable int spellsused
	variable string BuffTarget
	
	;Debug:Echo["\at\[DoInitialiSpellLineup\]\ax Begin..."]
	
	if ${IllyDebugMode}
		Debug:Echo["\at\[DoInitialSpellLineup(${FightingEpicMob}, ${FightingHeroicMob})\]\ax Begin..."]
		
	;; Theorems
	if (${Me.Ability[${SpellType[51]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 218 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 51 0 0 0 ${KillTarget} 0 0 0 1
			if (${Return.Equal[-1]})
			{
				if ${IllyDebugMode}
					Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
				return ${spellsused}
			}		
			spellsused:Inc
		}
	}
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
		
	;; Ultraviolet Beam
	if (${Me.Ability[${SpellType[60]}].IsReady})
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
		if (${Return.Equal[-1]})
		{
			if ${IllyDebugMode}
				Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
			return ${spellsused}
		}		
		spellsused:Inc
	}

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
	
	;; Fast Casting DOT (Nightmare)
	if (${Me.Ability[${SpellType[80]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 476 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
			if (${Return.Equal[-1]})
			{
				if ${IllyDebugMode}
					Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
				return ${spellsused}
			}
			spellsused:Inc
		}
	}
	
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Prismatic Chaos
	if ${Me.Ability[${SpellType[72]}].IsReady}
	{
		BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
		if !${BuffTarget.Equal["No one"]}
		{
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
			{
				call VerifyTarget ${KillTarget}
				if ${Return.Equal[FALSE]}
					return CombatComplete
				if ${IllyDebugMode}
					Debug:Echo["Casting ''Prismatic Chaos'"]
				call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
				if (${Return.Equal[-1]})
				{
					if ${IllyDebugMode}
						Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
					return ${spellsused}
				}				
				LastSpellCast:Set[72]
				call CheckCastBeam
				if ${Return.Equal[CombatComplete]}
					return CombatComplete	
			}
			else
				echo "ERROR1: Prismatic Chaos target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]} (${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}), does not exist!"
		}
		else
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
			if (${Return.Equal[-1]})
			{
				if ${IllyDebugMode}
					Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
				return ${spellsused}
			}
			LastSpellCast:Set[72]
			call CheckCastBeam
			if ${Return.Equal[CombatComplete]}
				return CombatComplete	
		}
	}
	
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}	
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}
	
	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
		return CombatComplete	

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}	
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Brainburst
	if (${Me.Ability[${SpellType[70]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 168 315
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 70 0 0 0 ${KillTarget} 0 0 0 1
			if (${Return.Equal[-1]})
			{
				if ${IllyDebugMode}
					Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
				return ${spellsused}
			}			
			spellsused:Inc
		}
	}

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
		return CombatComplete	

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Chromatic Storm
	if (${Me.Ability[${SpellType[91]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 169 312
		if ${Return.Equal[FALSE]}
		{
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 91 0 0 0 ${KillTarget} 0 0 0 1
			if (${Return.Equal[-1]})
			{
				if ${IllyDebugMode}
					Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
				return ${spellsused}
			}			
			spellsused:Inc
		}
	}

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
		return CombatComplete	

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Chromatic Shower
	if (${Me.Ability[${SpellType[388]}].IsReady})
	{
		call CheckActorForEffect ${KillTarget} 266 312
		if ${Return.Equal[FALSE]}
		{	
			call VerifyTarget ${KillTarget}
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 388 0 0 0 ${KillTarget} 0 0 0 1
			if (${Return.Equal[-1]})
			{
				if ${IllyDebugMode}
					Debug:Echo["DoInitialSpellLineup() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
				return ${spellsused}
			}			
			spellsused:Inc
		}
	}
	
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	if ${MezzMode}
	{
		call Mezmerise_Targets
		if (${Return.Equal[CombatComplete]})
			return CombatComplete
	}

	call CheckCastBeam
	if ${Return.Equal[CombatComplete]}
		return CombatComplete	

	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["DoInitialSpellLineup() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; "Time Warp" (and/or any other skills that are dependent upon whether a mob is heroic, epic, or solo.
	if ${FightingEpicMob} || ${FightingHeroicMob}
	{
		if (${HaveAbility_TimeWarp})
		{
			if ${Me.Ability[time warp].IsReady}
			{
				if (${Actor[${KillTarget}].Health} > 20)
					call DoTheTimeWarp
			}
		}
	}
	else
	{		
		if (${HaveAbility_TimeWarp} && ${Me.Group} == 1)
		{
			if ${Me.Ability[time warp].IsReady}
			{
				if (${Actor[${KillTarget}].Health} > 50)
					call DoTheTimeWarp
			}
		}			
	}
	
	if ${IllyDebugMode}
		Debug:Echo["DoInitialSpellLineup() -- Exiting (spellsused: ${spellsused})"]
	return ${spellsused}
}

function CheckStuns()
{
	variable int spellsused
	
	if ${IllyDebugMode}	
		Debug:Echo["CheckStuns()"]
	
	;; TODO -- double check these later
	if (${Me.Level} < 20 && ${Actor[${KillTarget}].IsSolo})
		return
	elseif (${Me.Group} > 2 && ${Actor[${MainTankID}].Health} > 50)
		return

	;; Traditional setting...
	if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 40 && ${Me.Health} > 50
		return

	;; Stun 1 (Paranoia)
	if ${Me.Ability[${SpellType[190]}].IsReady}
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 190 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["CheckStuns() -- Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete				
		}	
		spellsused:Inc
	}
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["CheckStuns() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Beam
	if (${Me.Ability[${SpellType[60]}].IsReady})
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
		if (${Return.Equal[-1]})
		{
			if ${IllyDebugMode}
				Debug:Echo["CheckStuns() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
			return ${spellsused}
		}		
		spellsused:Inc
	}
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["CheckStuns() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Stun 2 (Bewilderment)
	if ${Me.Ability[${SpellType[191]}].IsReady}
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 191 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
		{
			if ${IllyDebugMode}
				Debug:Echo["CheckStuns() -- Exiting (Target no longer valid: CombatComplete)"]
			return CombatComplete				
		}	
		spellsused:Inc
	}
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["CheckStuns() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}
	
	;; Beam
	if (${Me.Ability[${SpellType[60]}].IsReady})
	{
		call VerifyTarget ${KillTarget}
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
		if (${Return.Equal[-1]})
		{
			if ${IllyDebugMode}
				Debug:Echo["CheckStuns() -- Exiting (CastSpellRange returned -1, KillTarget changed or not valid)"]
			return ${spellsused}
		}		
		spellsused:Inc
	}
	if ${KillTarget} != ${KillTargetCheck}
	{
		if ${IllyDebugMode}
			Debug:Echo["CheckStuns() -- Exiting (KillTarget has changed)"]
		return ${spellsused}
	}

	return ${spellsused}
}

objectdef custom_overrides
{
	method Spam()
	{
	}
}

function ChainStunMez()
{
	call VerifyTarget ${KillTarget}
	if ${Return.Equal[FALSE]}
		return CombatComplete

	; Entrance
	if (${Me.Ability[${SpellType[352]}].IsReady})
	{
		call CastSpellRange 352 0 0 0 ${KillTarget} 0 0 0 1
	}

	call VerifyTarget ${KillTarget}
	if ${Return.Equal[FALSE]}
		return CombatComplete

	; Bewilderment
	if (${Me.Ability[${SpellType[191]}].IsReady})
	{
		call CastSpellRange 191 0 0 0 ${KillTarget} 0 0 0 1
	}

	call VerifyTarget ${KillTarget}
	if ${Return.Equal[FALSE]}
		return CombatComplete

	; Paranoia
	if (${Me.Ability[${SpellType[190]}].IsReady})
	{
		call CastSpellRange 190 0 0 0 ${KillTarget} 0 0 0 1
	}

	call VerifyTarget ${KillTarget}
	if ${Return.Equal[FALSE]}
		return CombatComplete

	; Regalia
	if (${Me.Ability[${SpellType[92]}].IsReady})
	{
		call CastSpellRange 92 0 0 0 ${KillTarget} 0 0 0 1
	}

	call VerifyTarget ${KillTarget}
	if ${Return.Equal[FALSE]}
		return CombatComplete

	; Entrance
	if (${Me.Ability[${SpellType[352]}].IsReady})
	{
		call CastSpellRange 352 0 0 0 ${KillTarget} 0 0 0 1
	}
}	