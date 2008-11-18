;*************************************************************
;Illusionist.iss
;version 20081013
;by pygar
;
;20080730a (Amadeus)
; * So many changes over the past few months it is not even funny
; * Latest change:  Added the ability to use a "Runed Guard of the Sel'Nok" to the script.  You can indicate whether or not
;   to use it via the UI.
;
;20080323a (Amadeus)
; * Moved "Focus" buff to the combat routines.  It is a short duration buff and should only be used during combat when the
;   target is over 80% health.
;
;20070725a
; Minor changes to adjust for AA tweaks in game.
;
;20070504a
; Added Cure Arcane Routine
; Allies used only on aggro now or solo
; Intelligent use of Time Compression and Illusionary Arm
; Manaflow on lowest member if under 60 power and illusionist over 30 health
;
;20070404a
;	Updated for latest eq2bot
;	Fixed bugs in AA release
;	Updated Master Strikes
;	Tweaks to mezing to prevent over aggressive behavior
;
;20070201a
;Added Support for KoS and EoF AA
;Updated and Optomized for EQ2Bot 2.5.2
;Added Toggle for Initiating HO's
;
;Initial Release
;Limited AA support:  Currently only Mana Flow implemented
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20081013
	;;;;

	call EQ2BotLib_Init

	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Buffs]
	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[Buffs]:Move[4]
	ui -load -parent "Buffs@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "EQ2Bot/UI/${Me.SubClass}_Buffs.xml"

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
	declare UseRunedGuardItem bool script FALSE
	declare BuffEmpathicAura bool script FALSE
	declare BuffEmpathicSoothing bool script FALSE
	declare UseIlluminate bool script FALSE
	declare BlinkMode bool script FALSE
	declare HaveMythical bool script FALSE
	declare LastSpellCast int script 0
	declare InPostDeathRoutine bool script FALSE
	declare IllyCasterBuffsOn collection:string script
	declare IllyDPSBuffsOn collection:string script
	declare MakePetWhileInCombat bool script TRUE
	declare SpamSpells bool script FALSE
	declare Custom custom_overrides script

	BuffAspect:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAspect,FALSE]}]
	BuffRune:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffRune,FALSE]}]
	BuffPowerRegen:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffPowerRegen,TRUE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	Makepet:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Makepet,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	BuffTime_Compression:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffTime_Compression,]}]
	BuffIllusory_Arm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffIllusory_Arm,]}]
	DPSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[DPSMode,TRUE]}]
	UltraDPSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UltraDPSMode,FALSE]}]
	SummonImpOfRo:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Summon Imp of Ro,FALSE]}]
	UseTouchOfEmpathy:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseTouchOfEmpathy,FALSE]}]
	UseDoppleganger:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDoppleganger,FALSE]}]
	UseRunedGuardItem:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseRunedGuardItem,FALSE]}]
	BuffEmpathicAura:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEmpathicAura,FALSE]}]
	BuffEmpathicSoothing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEmpathicSoothing,FALSE]}]
	UseIlluminate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseIlluminate,FALSE]}]
	BlinkMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BlinkMode,FALSE]}]
	MakePetWhileInCombat:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MakePetWhileInCombat,TRUE]}]
	SpamSpells:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[SpamSpells,FALSE]}]

	NoEQ2BotStance:Set[TRUE]

	Event[EQ2_FinishedZoning]:AttachAtom[Illusionist_FinishedZoning]
	
	if (${Me.Equipment[Mirage Star](exists)} && ${Me.Equipment[1].Tier.Equal[MYTHICAL]}) || (${Me.Inventory[Mirage Star](exists)} && ${Me.Inventory[Mirage Star].Tier.Equal[MYTHICAL]})
		HaveMythical:Set[TRUE]
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

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		call CheckHeals
		call RefreshPower
		call CheckSKFD
	
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
							if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
							{
								;Debug:Echo["Casting ''Prismatic'"]
								call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
								LastSpellCast:Set[72]
								return
							}
							else
								echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
						}
						else
						{
							;Debug:Echo["Casting ''Prismatic'"]
							call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
							LastSpellCast:Set[72]
							return
						}
					}
				}
			}
		}
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
	;;
	;;;;;;;;;;;;;;;;;;;
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

	PreAction[3]:Set[MakePet]
	PreSpellRange[3,1]:Set[355]

	;haste
	PreAction[4]:Set[Melee_Buff]
	PreSpellRange[4,1]:Set[35]

	; ie, dynamism
	PreAction[5]:Set[Caster_Buff]
	PreSpellRange[5,1]:Set[40]

	PreAction[6]:Set[Rune]
	PreSpellRange[6,1]:Set[20]

	PreAction[7]:Set[Clarity]
	PreSpellRange[7,1]:Set[22]

	PreAction[8]:Set[AA_Empathic_Aura]
	PreSpellRange[8,1]:Set[391]

	PreAction[9]:Set[AA_Empathic_Soothing]
	PreSpellRange[9,1]:Set[392]

	PreAction[10]:Set[AA_Time_Compression]
	PreSpellRange[10,1]:Set[393]

	PreAction[11]:Set[AA_Illusory_Arm]
	PreSpellRange[11,1]:Set[394]

	PreAction[12]:Set[SummonImpOfRoBuff]
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

	;; Encounter DOT   (RENAME)
	Action[3]:Set[Ego]
	SpellRange[3,1]:Set[91]

	;; Slow recast, Encounter DOT
	Action[4]:Set[Shower]
	SpellRange[4,1]:Set[388]

	;; Stifle over time, and NUKE
	Action[5]:Set[Silence]
	SpellRange[5,1]:Set[260]

	;; Master Strike
	MobHealth[6,1]:Set[20]
	MobHealth[6,2]:Set[100]
	Action[6]:Set[Master_Strike]

	;; Construct
	Action[7]:Set[Constructs]
	SpellRange[7,1]:Set[51]

	;;;;;;;;;;;;;;;;; STUNS ;;;;;;;;;;;;;;;;;

	;; Group Encounter fast casting Stun
	Action[8]:Set[AEStun]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[191]

	;; Single Target Stun (longer duration)
	Action[9]:Set[Stun]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	SpellRange[9,1]:Set[190]

	;;;;;;;;;;;;;;;;; UTILITY ;;;;;;;;;;;;;;;;;

	;; Savante
	Action[10]:Set[Savante]
	MobHealth[10,1]:Set[20]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[389]

	;; Mana Shroud
	;;; NOTE: This is handled in RefreshPower()

	;; Power Drain -> Group
	Action[11]:Set[Gaze]
	MobHealth[11,1]:Set[1]
	MobHealth[11,2]:Set[40]
	SpellRange[11,1]:Set[90]

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

	;Debug:Echo["Buff_Routine(${PreSpellRange[${xAction},1]}:${SpellType[${PreSpellRange[${xAction},1]}]})"]
	;CurrentAction:Set[Buff Routine :: ${PreAction[${xAction}]} (${xAction})]

	if (!${InPostDeathRoutine} && !${CheckingBuffsOnce})
	{
		call CheckHeals
		call RefreshPower
		call CheckSKFD
	
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
							if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
							{
								;Debug:Echo["Casting ''Prismatic'"]
								call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
								LastSpellCast:Set[72]
								return
							}
							else
								echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
						}
						else
						{
							;Debug:Echo["Casting ''Prismatic'"]
							call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
							LastSpellCast:Set[72]
							return
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
				if (!${MakePetWhileInCombat} && ${Me.ToActor.InCombatMode})
					break
				; needs to be equipped for the pet conc thing.
				if (${HaveMythical} && ${Me.Equipment[Mirage Star](exists)}) || (${Math.Calc[${Me.MaxConc}-${Me.UsedConc}]} >= 3)
				{
					if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]}
						wait 1
						if (${Me.Ability[${SpellType[382]}].IsReady})
							call CastSpellRange 382 0 0 0 ${Me.Pet.ID} 0 0 0 1
					}
				}
			}
			break
	
		case Melee_Buff
			Counter:Set[1]
			tempvar:Set[1]
	
			;; If we have mythical, just cast on self since it is a group buff
			if (${HaveMythical})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID} 0 0 1 0 0
				break
			}
	
			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
							{
								IllyDPSBuffsOn:Set[${Me.Maintained[${Counter}].Target.ID},${Me.Maintained[${Counter}].Target.Name}]
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						if ${Actor[${ActorID}].Type.Equal[PC]} 
						{
							if (${Me.Group[${BuffTarget.Token[1,:]}](exists)} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
								{
									if (!${IllyDPSBuffsOn.Element[${ActorID}](exists)})
									{
										call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
									}
									;else
									;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already MeleeDPS buffed!"]													
								}
							}
						}
						else
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								if (!${IllyDPSBuffsOn.Element[${ActorID}](exists)})
								{
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
								}
								;else
								;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already MeleeDPS buffed!"]				
							}	
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
	
		case Caster_Buff
			Counter:Set[1]
			tempvar:Set[1]
			IllyCasterBuffsOn:Clear
	
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
			
			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						if ${Actor[${ActorID}].Type.Equal[PC]}
						{
							if (${Me.Group[${BuffTarget.Token[1,:]}](exists)} || ${Me.Raid[${BuffTarget.Token[1,:]}](exists)} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
								{
									if (!${IllyCasterBuffsOn.Element[${ActorID}](exists)})
									{
										call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
									}
									;else
									;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already CasterDPS buffed!"]									
								}
							}
						}
						else
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								if (!${IllyCasterBuffsOn.Element[${ActorID}](exists)})
								{
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
								}
								;else
								;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already CasterDPS buffed!"]	
							}	
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
	
		case AA_Time_Compression
			BuffTarget:Set[${UIElement[cbBuffTime_Compression@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${BuffTarget.Equal["No one"]}
				break
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if (${Me.Group[${BuffTarget.Token[1,:]}](exists)})
					{
						if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
				}
			}
			break
	
		case AA_Illusory_Arm
			BuffTarget:Set[${UIElement[cbBuffIllusory_Arm@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${BuffTarget.Equal["No one"]}
				break
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if (${Me.Group[${BuffTarget.Token[1,:]}](exists)})
					{
						if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
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
	
		case AA_Empathic_Soothing
			if ${BuffEmpathicSoothing}
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
	; Cure Arcane
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		LastSpellCast:Set[210]
	}			
	
	;; Cast Beam if it is ready
	if (${Me.Ability[${SpellType[60]}].IsReady})
	{
		LastSpellCast:Set[60]
		call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
	}
	elseif (${LastSpellCast} != 60)
	{
		;Debug:Echo["EQ2Bot-Debug:: LastSpellCast: ${LastSpellCast}"]
		if (${Me.Ability[${SpellType[60]}].TimeUntilReady} <= 1)	
		{		
			LastSpellCast:Set[60]
			call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1 0 1
		}
	}
	
	; Cure Arcane
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		LastSpellCast:Set[210]
	}	
	
	call ProcessTriggers		
}
	
	

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, int TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;
	declare BuffTarget string local

	call VerifyTarget ${TargetID}
	if !${Return}
		return -1
		
	call CheckCastBeam


	;; Prismatic Proc
	;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
	if !${MainTank} || ${AutoMelee}
	{
		if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
		{
			if ${Actor[${KillTarget}].Health} > 2
			{
				if ${Me.Ability[${SpellType[72]}].IsReady}
				{
					BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
					if !${BuffTarget.Equal["No one"]}
					{
						;Debug:Echo["${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}"]
						if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
						{
							LastSpellCast:Set[72]
							call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1 0
							call CheckCastBeam
						}
						else
							echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
					}
					else
					{
						LastSpellCast:Set[72]
						call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1 0
						call CheckCastBeam
					}
				}
			}
		}
	}

	call VerifyTarget ${TargetID}
	if !${Return}
		return -1

	; Fast casting DoT
	if (${Me.Ability[${SpellType[80]}].IsReady})
	{
		LastSpellCast:Set[80]
		call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
		call CheckCastBeam
	}

	call VerifyTarget ${TargetID}
	if !${Return}
		return -1

	if ${AutoMelee} && ${DoCallCheckPosition}
	{
		if ${MainTank}
			call CheckPosition 1 0
		else
			call CheckPosition 1 1
		DoCallCheckPosition:Set[FALSE]
	}
	

	LastSpellCast:Set[${start}]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}

	; Cure Arcane
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		LastSpellCast:Set[210]
	}		
	return ${Return}
}

function Combat_Routine(int xAction)
{
	declare BuffTarget string local
	declare spellsused int local
	spellsused:Set[0]

	if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
		return CombatComplete

	if ${InPostDeathRoutine} || ${CheckingBuffsOnce}
		return

	;; Aggro Control...
	if (${Actor[${KillTarget}].Target.ID} == ${Me.ID} && !${MainTank})
	{
	    if ${Me.Ability[id,3903537279].IsReady}
	    {
	        announce "I have aggro...\n\\#FF6E6EUsing Bewilderment!" 3 1
	        call CastSpellRange AbilityID=3903537279 TargetID=${aggroid} IgnoreMaintained=1
	        spellsused:Inc
	    }
		elseif (${Me.ToActor.Health} < 70)
		{
			if ${Me.Ability["Phase"].IsReady}
			{
				Debug:Echo["Casting 'Phase' on ${Actor[${KillTarget}].Name}!"]
				call CastSpellRange 357 0 0 0 ${aggroid} 0 0 0 1
				LastSpellCast:Set[357]
				spellsused:Inc
			}
			elseif ${Me.Ability["Blink"].IsReady} && ${BlinkMode}
			{
				Debug:Echo["Casting 'Blink'!"]
				call CastSpellRange 358 0 0 0 ${Me.ID} 0 0 0 1
				LastSpellCast:Set[358]
				spellsused:Inc
			}
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;; Check for "Runed Guard of the Sel'Nok" ;;;;
	if (${UseRunedGuardItem})
	{
		if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 10)
		{
			if ${Me.Equipment["Runed Guard of the Sel'Nok"](exists)}
			{
				if ${Me.Equipment["Runed Guard of the Sel'Nok"].IsReady}
				{
					CurrentAction:Set[Using: Runed Guard of the Sel'Nok]
					Me.Equipment["Runed Guard of the Sel'Nok"]:Use
					wait 1
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 1
				}
			}
			elseif ${Me.Inventory["Runed Guard of the Sel'Nok"](exists)}
			{
				if ${Me.Inventory["Runed Guard of the Sel'Nok"].IsReady}
				{
					CurrentAction:Set[Using: Runed Guard of the Sel'Nok]
					variable string SecondarySlotItem
					variable uint TimeBeforeEquip
					SecondarySlotItem:Set[${Me.Equipment[Secondary]}]
					TimeBeforeEquip:Set[${Time.Timestamp}]

					Me.Inventory["Runed Guard of the Sel'Nok"]:Equip
					wait 3
					Me.Equipment["Runed Guard of the Sel'Nok"]:Use
					wait 1
					do
					{
						waitframe
					}
					while (${Me.CastingSpell} || (${Math.Calc64[${Time.Timestamp}-${TimeBeforeEquip}]} <= 2))
					Me.Inventory[${SecondarySlotItem}]:Equip
				}
			}
		}
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoHOs}
		objHeroicOp:DoHO

	if ${StartHO}
	{
		if !${EQ2.HOWindowActive} && ${Me.InCombat}
		{
			call CastSpellRange 303
			LastSpellCast:Set[303]
		}
	}

	;; TO DO (Revamp)
	if ${MezzMode}
		call Mezmerise_Targets

	if ${Me.Pet(exists)}
	{
		if (${Me.Pet.Target.ID} != ${KillTarget} || !${Me.Pet.InCombatMode})
			call PetAttack 1
	}
	
	call CheckHeals

	if ${ShardMode}
		call Shard

	if !${UltraDPSMode}
		call RefreshPower

	;; Add back later...(TODO)
		;call CheckSKFD

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	if ${AutoMelee} && !${NoAutoMovement}
	{
		if ${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]}
		{
			if ${Actor[${KillTarget}].IsEpic}
				call CheckPosition 1 1 ${KillTarget}
			else
			{
				switch ${Actor[${KillTarget}].ConColor}
				{
					case Green
					case Grey
						Debug:Echo["Calling CheckPosition(1 0)"]
						call CheckPosition 1 0 ${KillTarget}
						break
					Default
						Debug:Echo["Calling CheckPosition(1 1)"]
						call CheckPosition 1 1 ${KillTarget}
						break
				}
			}
		}
	}

	;; Illuminate
	if ${UseIlluminate}
	{
		if ${Me.Ability[${SpellType[387]}](exists)}
		{
			if (${Me.Ability[${SpellType[387]}].IsReady})
			{
				call CastSpellRange 387 0 0 0 ${KillTarget} 0 0 0 1
				LastSpellCast:Set[387]
				spellsused:Inc
			}
		}
	}

	call VerifyTarget
	if !${Return}
		return CombatComplete

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	;; Chronosiphoning (Always cast this when it is ready!
	if ${Me.Ability[${SpellType[385]}](exists)}
	{
		if (${Me.Ability[${SpellType[385]}].IsReady})
		{
			call CastSpellRange 385 0 0 0 ${KillTarget} 0 0 0 1
			LastSpellCast:Set[385]
			spellsused:Inc
		}
	}

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	; Fast Nuke (beam) ...cast every time it's ready!
	call CheckCastBeam

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	;; Short Duration Buff .. adds INT, Focus, Disruption, etc. (cast any time it's ready)  (else cast a short casting spell to kick up rapidity)
	if (${Me.Ability[${SpellType[23]}].IsReady})
	{
		call CastSpellRange 23 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[23]
		spellsused:Inc
	}
	else
	{
		;; Short Duration Buff .. adds proc to group members for 20 seconds (Peace of Mind)
		if (${Me.Ability[${SpellType[383]}].IsReady})
		{
			call CastSpellRange 383 0 0 0 ${KillTarget} 0 0 0 1
			LastSpellCast:Set[383]
			spellsused:Inc
		}
	}

	call VerifyTarget
	if !${Return}
		return CombatComplete

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	; Mental DOT and arcane resistance debuff (fast casting - "Despair") ...cast every time it's ready!
	;;; The rest of this block is basically to insure that all DoTs are loaded and things are primed at the
	;;; beginning of the fight.
	if (${Me.Ability[${SpellType[80]}].IsReady})
	{
		call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc

		if ${MezzMode}
			call Mezmerise_Targets

		call VerifyTarget
		if !${Return}
			return CombatComplete

		ExecuteQueued Mezmerise_Targets
		FlushQueued Mezmerise_Targets

		if !${Me.Maintained[${SpellType[70]}](exists)}
		{
			if (${Me.Ability[${SpellType[70]}].IsReady})
			{
				call _CastSpellRange 70 0 0 0 ${KillTarget} 0 0 0 1
				spellsused:Inc
			}
		}
		ExecuteQueued Mezmerise_Targets
		FlushQueued Mezmerise_Targets

		if (${Me.Ability[${SpellType[60]}].IsReady})
		{
			call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
			spellsused:Inc
		}
		call VerifyTarget
		if !${Return}
			return CombatComplete

		ExecuteQueued Mezmerise_Targets
		FlushQueued Mezmerise_Targets

		if !${Me.Maintained[${SpellType[91]}](exists)}
		{
			if (${Me.Ability[${SpellType[91]}].IsReady})
			{
				call _CastSpellRange 91 0 0 0 ${KillTarget} 0 0 0 1
				spellsused:Inc
			}
		}

		call VerifyTarget
		if !${Return}
			return CombatComplete

		ExecuteQueued Mezmerise_Targets
		FlushQueued Mezmerise_Targets

		if (${Me.Ability[${SpellType[60]}].IsReady})
		{
			call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
			spellsused:Inc
		}

		if ${MezzMode}
			call Mezmerise_Targets

		call VerifyTarget
		if !${Return}
			return CombatComplete

		ExecuteQueued Mezmerise_Targets
		FlushQueued Mezmerise_Targets

		if !${Me.Maintained[${SpellType[388]}](exists)}
		{
			if (${Me.Ability[${SpellType[388]}].IsReady})
			{
				call _CastSpellRange 388 0 0 0 ${KillTarget} 0 0 0 1
				spellsused:Inc
			}
		}
		ExecuteQueued Mezmerise_Targets
		FlushQueued Mezmerise_Targets

		if (${Me.Ability[${SpellType[60]}].IsReady})
		{
			call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
			spellsused:Inc
		}

		call VerifyTarget
		if !${Return}
			return CombatComplete
	}

	if ${MezzMode}
		call Mezmerise_Targets

	call VerifyTarget
	if !${Return}
		return CombatComplete

	if (${UseDoppleganger} && !${MainTank} && ${Me.Group} > 1)
	{
		;Debug:Echo["Checking Doppleganger..."]
		if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 50)
		{
			if ${Me.Ability[Doppleganger].IsReady}
			{
				switch ${Target.ConColor}
				{
				case Red
				case Orange
				case Yellow
					if (${Actor[${KillTarget}].EncounterSize} > 2 || ${Actor[${KillTarget}].Difficulty} >= 2)
					{
						echo "EQ2Bot-DEBUG: Casting 'Doppleganger' on ${MainTankPC}"
						eq2execute /useabilityonplaye ${MainTankPC} "Doppleganger"
						wait 1
						do
						{
							waitframe
						}
						while ${Me.CastingSpell}
					}
					break
				default
					if (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed})
					{
						echo "EQ2Bot-DEBUG: Casting 'Doppleganger' on ${MainTankPC}"
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

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	;; Check Group members to see if anyone needs 'Touch of Empathy'
	if ${UseTouchOfEmpathy} && ${Me.Group} > 1
	{
		if ${Me.Ability["Touch of Empathy"].IsReady}
		{
			variable string TargetsTarget = ${Actor[${KillTarget}].Target.Name}
			variable string TargetsTargetClass = ${Actor[PC,${TargetsTarget},exactname].Class}
			if (!${TargetsTarget.Equal[${MainTankPC}]} && ${Actor[pc,${TargetsTarget},exactname](exists)} && ${Me.Group[${TargetsTarget}](exists)})
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
					echo "EQ2Bot-DEBUG: Casting 'Touch of Empathy' on ${TargetsTarget}"
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

	call VerifyTarget
	if !${Return}
		return CombatComplete

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	;; If we have the skill 'Nullifying Staff' and the mob is within range
	if ${Me.Ability[${SpellType[396]}](exists)}
	{
		if (${Actor[${KillTarget}].Distance} < 5)
		{
			if (${Me.Ability[${SpellType[396]}].IsReady})
			{
				call CastSpellRange 396 0 0 0 ${KillTarget} 0 0 0 1
				LastSpellCast:Set[396]
				spellsused:Inc
				if !${AutoMelee}
				{
					if ${Me.AutoAttackOn}
						EQ2Execute /toggleautoattack
				}
				call CheckCastBeam
			}
		}
	}

	call VerifyTarget
	if !${Return}
		return CombatComplete

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	;; Melee Debuff -- only for Epic mobs for now
	if ${Me.ToActor.Power} > 40
	{
		if ${Actor[${KillTarget}].IsEpic}
		{
			if ${Me.Ability[${SpellType[50]}](exists)}
			{
				if !${Me.Maintained[${SpellType[50]}](exists)}
				{
					if (${Me.Ability[${SpellType[50]}].IsReady})
					{
						call CastSpellRange 50 0 0 0 ${KillTarget} 0 0 0 1
						LastSpellCast:Set[50]
						spellsused:Inc
						call CheckCastBeam
					}
				}
			}
		}
	}

	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets

	;; If Target is Epic, be sure that the Daze Debuff is being used as often as possible, but only once we have casted our initial spells.)  (This is the slow casting Nuke.)
	if ${Actor[${KillTarget}].IsEpic}
	{
		if ${Me.Ability[${SpellType[61]}](exists)}
		{
			if (${Me.Ability[${SpellType[61]}].IsReady})
			{
				call CastSpellRange 61 0 0 0 ${KillTarget} 0 0 0 1
				LastSpellCast:Set[61]
				spellsused:Inc
				call CheckCastBeam
			}
		}
	}

	if ${MezzMode}
		call Mezmerise_Targets

	call VerifyTarget
	if !${Return}
		return CombatComplete


	; Cure Arcane
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		LastSpellCast:Set[210]
	}	

	;Debug:Echo["Entering Switch (${Action[${xAction}]})"]
	switch ${Action[${xAction}]}
	{
		;; Straight Nukes
		case Silence
			;; This spell is just too slow to cast and typically does about 40 dps over an entire fight ..it is just not worth it.
			;if !${DPSMode} && !${UltraDPSMode}
			;{
				if (${Me.Ability[${SpellType[260]}].IsReady})
				{
					call _CastSpellRange 260 0 0 0 ${KillTarget} 0 0 0 1
					spellsused:Inc
				}
			;}
			call VerifyTarget
			if !${Return}
				return CombatComplete
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		case NukeDaze
			if (${Me.Ability[${SpellType[61]}].IsReady})
			{
				call _CastSpellRange 61 0 0 0 ${KillTarget} 0 0 0 1
				spellsused:Inc
			}
			call VerifyTarget
			if !${Return}
				return CombatComplete
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		;; Single Target DoTs
		case MindDoT
			;Debug:Echo[" ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) called"]
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
			{
				;Debug:Echo["Health of Target: ${Actor[${KillTarget}].Health}
				break
			}
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				;;; For now, let's try casting this every time it's ready. More testing needed to see if this is
				;;; detrimental to dps and/or power usage
	
				;if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				;{
					;Debug:Echo["Casting ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]})"]
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
					spellsused:Inc
					if (${Me.Ability[${SpellType[80]}].IsReady})
					{
						call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
						spellsused:Inc
					}
					call VerifyTarget
					if !${Return}
						return CombatComplete
				;}
			}
			;else
				;   Debug:Echo["${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) isn't ready..."]
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		;; Group Encounter DoTs
		case Shower
		case Ego
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
				break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				;if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				;{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
					spellsused:Inc
				;}
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		case Master_Strike
			if (${Me.Ability[${SpellType[60]}].IsReady})
			{
				call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
				LastSpellCast:Set[60]
				spellsused:Inc
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
				break
			;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
			;;;;;;;;;;
			if (${InvalidMasteryTargets.Element[${KillTarget}](exists)})
				break
			;;;;;;;;;;;
	
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				if ${Me.Ability["Master's Strike"].IsReady}
				{
					Target ${KillTarget}
					Me.Ability["Master's Strike"]:Use
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					spellsused:Inc
					wait 1
				}
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		case Constructs
			if ${UltraDPSMode}
			{
				;; Always set to one less than the index of the next ability you want to have run (it is incremented on the loop)
				gRtnCtr:Set[11]
				break
			}
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 30
				break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				spellsused:Inc
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		case AEStun
		case Stun
			if ${UltraDPSMode}
			{
				;; Always set to one less than the index of the next ability you want to have run (it is incremented on the loop)
				gRtnCtr:Set[11]
				break
			}
			if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 40 && ${Me.ToActor.Health} > 50
				break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					spellsused:Inc
				}
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		case Savante
			if ${Me.ToActor.Power} > 50
				break
			if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].IsNamed}
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]}
					spellsused:Inc
				}
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		case Gaze
			if ${Me.ToActor.Power} > 50
			{
				if ${spellsused} < 1 && !${MezzMode}
				call CastSomething
				return CombatComplete
			}
			if ${UltraDPSMode} && ${Actor[${KillTarget}].IsSolo}
			{
				if ${spellsused} < 1 && !${MezzMode}
					call CastSomething
				return CombatComplete
			}
			if ${DPSMode} && ${Actor[${KillTarget}].IsSolo}
			{
				if ${spellsused} < 1 && !${MezzMode}
					call CastSomething
				return CombatComplete
			}
			if ${Actor[${KillTarget}].IsSolo} && ${Me.Group} > 1
			{
				if ${spellsused} < 1 && !${MezzMode}
					call CastSomething
				return CombatComplete
			}
			elseif ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 70
			{
				if ${spellsused} < 1 && !${MezzMode}
					call CastSomething
				return CombatComplete
			}
			elseif ${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].Health} < 50
			{
				if ${spellsused} < 1 && !${MezzMode}
					call CastSomething
				return CombatComplete
			}
			elseif ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health} < 15
			{
				if ${spellsused} < 1 && !${MezzMode}
					call CastSomething
				return CombatComplete
			}
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call _CastSpellRange ${SpellRange[${xAction},1]}
				spellsused:Inc
			}
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			break
	
		default
			if (${Me.Ability[${SpellType[60]}].IsReady})
			{
				call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1
				spellsused:Inc
			}
			if (${spellsused} < 1) && !${MezzMode}
				call CastSomething
			ExecuteQueued Mezmerise_Targets
			FlushQueued Mezmerise_Targets
			return CombatComplete
	}

	if !${MezzMode}
	{
		if (${spellsused} < 1)
			call CastSomething
	}
	ExecuteQueued Mezmerise_Targets
	FlushQueued Mezmerise_Targets
	;Debug:Echo["Exiting Switch (${Action[${xAction}]}) (spellsused: ${spellsused})"]
}

function CastSomething()
{
	;; If this function is called, it is because we went through teh combat routine without casting any spells.
	;; This function is intended to cast SOMETHING in order to keep "Perputuality" going.

	;Debug:Echo["---"]
	;Debug:Echo["CastSomething() called."]

	call VerifyTarget
	if !${Return}
		return
		
	call CheckCastBeam		

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; Things we should be checking EVERY time
	;; Prismatic Proc
	;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
	if !${MainTank} || ${AutoMelee}
	{
		if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
		{
			if ${Actor[${KillTarget}].Health} > 2
			{
				if ${Me.Ability[${SpellType[72]}].IsReady}
				{
					BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
					if !${BuffTarget.Equal["No one"]}
					{
						if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
						{
							;Debug:Echo["Casting ''Prismatic'"]
							call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
							LastSpellCast:Set[72]
							call CheckCastBeam
							return
						}
						else
							echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
					}
					else
					{
						;Debug:Echo["Casting ''Prismatic'"]
						call CastSpellRange 72 0 0 0 ${MainTankID} 0 0 0 1
						LastSpellCast:Set[72]
						call CheckCastBeam
						return
					}
				}
			}
		}
	}

	if (${Me.Ability[${SpellType[80]}].IsReady})
	{
		;Debug:Echo["Casting 'Fast Casting DoT'"]
		call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[80]
		return
	}

	if (${Me.Ability[${SpellType[70]}].IsReady})
	{
		;Debug:Echo["Casting 'Mind DoT'"]
		call CastSpellRange 70 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[70]
		return
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;contruct
	if (${Me.Ability[${SpellType[51]}].IsReady})
	{
		;Debug:Echo["Casting 'Construct'"]
		call _CastSpellRange 51 0 0 0 ${KillTarget} 0 0 0 1
		return
	}

	;; AA Melee Ability (very fast casting -- low dmg
	if ${Me.Ability[Spellblade's Counter](exists)} && ${AutoMelee}
	{
		if (${Me.Ability[Spellblade's Counter].IsReady})
		{
			;Debug:Echo["Casting 'Melee AA Ability'"]
			Actor[${KillTarget}]:DoTarget
			call CastSpell "Spellblade's Counter" 395 ${KillTargeT} 0
			return
		}
	}

	; fast-casting encounter stun
	if (${Me.Ability[${SpellType[191]}].IsReady})
	{
		;Debug:Echo["Casting 'Encounter Stun'"]
		call CastSpellRange 191 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[191]
		return
	}

	; melee debuff
	if (${Me.Ability[${SpellType[50]}].IsReady})
	{
		;Debug:Echo["Casting 'Melee Debuff'"]
		call CastSpellRange 50 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[50]
		return
	}

	; extract mana
	if (${Me.Ability[${SpellType[309]}].IsReady})
	{
		;Debug:Echo["Casting 'Mana Recovery'"]
		call CastSpellRange 309 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[309]
		return
	}

	; root
	if (${Me.Ability[${SpellType[230]}].IsReady})
	{
		;Debug:Echo["Casting 'Root'"]
		call CastSpellRange 230 0 0 0 ${KillTarget} 0 0 0 1
		LastSpellCast:Set[230]
		return
	}
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

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
	if ${Actor[${aggroid}].Name.Find["Master P"]}
		return
		
	;; Use this whenver we have aggro...regardless  (de-aggro "Bewilderment")
    if ${Me.Ability[id,3903537279].IsReady}
    {
        announce "I have aggro...\n\\#FF6E6EUsing Bewilderment!" 3 1
        call CastSpellRange AbilityID=3903537279 TargetID=${aggroid} IgnoreMaintained=1
        return
    }
		
		
	;; Aggro Control...
	if (${Me.ToActor.Health} < 70 && ${Actor[${KillTarget}].Target.ID} == ${Me.ID})
	{
		if ${Me.Ability["Phase"].IsReady}
		{
			Debug:Echo["Casting 'Phase' on ${Actor[${KillTarget}].Name}!"]
			call CastSpellRange 357 0 0 0 ${aggroid} 0 0 0 1
			LastSpellCast:Set[357]
			call CheckCastBeam
			return
		}
		elseif ${Me.Ability["Blink"].IsReady} && ${BlinkMode}
		{
			Debug:Echo["Casting 'Blink'!"]
			call CastSpellRange 358 0 0 0 ${Me.ID} 0 0 0 1
			LastSpellCast:Set[358]
			call CheckCastBeam
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
		call CastSpellRange 386 0 0 0 ${KillTarget}
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
	declare tempvar int local
	declare MemberLowestPower int local

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

	;Transference line out of Combat
	if ${Me.ToActor.Health}>30 && ${Me.ToActor.Power}<80 && !${Me.InCombat}
	{
		call CastSpellRange 309
		LastSpellCast:Set[309]
	}
	elseif ${Me.ToActor.Health}>30 && ${Me.ToActor.Power}<50
	{
		call CastSpellRange 309
		LastSpellCast:Set[309]
		if ${Me.InCombat}
			call CheckCastBeam
	}

	if ${Me.Group} > 1
	{
		if ${Me.ToActor.Power} < 40
			call Shard

		if ${Me.ToActor.Power} > 45
		{
			;Mana Flow the lowest group member
			tempvar:Set[1]
			MemberLowestPower:Set[1]
			do
			{
				if ${Me.Group[${tempvar}].ToActor.Power}<60 && ${Me.Group[${tempvar}].ToActor.Distance}<30 && ${Me.Group[${tempvar}].ToActor(exists)}
				{
					if ${Me.Group[${tempvar}].ToActor.Power}<=${Me.Group[${MemberLowestPower}].ToActor.Power}
					{
						if !${Me.Group[${MemberLowestPower}].ToActor.IsDead}
							MemberLowestPower:Set[${tempvar}]
					}
				}
			}
			while ${tempvar:Inc}<${Me.GroupCount}

			if ${Me.Grouped}  && ${Me.Group[${MemberLowestPower}].ToActor.Power}<60 && ${Me.Group[${MemberLowestPower}].ToActor.Distance}<30  && ${Me.ToActor.Health}>30 && ${Me.Group[${MemberLowestPower}].ToActor(exists)}
			{
				call CastSpellRange 360 0 0 0 ${Me.Group[${MemberLowestPower}].ToActor.ID}
				if ${SpamSpells} 
					Custom:Spam[Mana Flow,${Me.Group[${MemberLowestPower}].ToActor.ID}]
				LastSpellCast:Set[360]
				if ${Me.InCombat}
					call CheckCastBeam
			}
		}
	}

	;Mana Cloak the group if the Main Tank is low on power
	if ${Me.InCombat} && ${Me.Group[${MainTankPC}](exists)}
	{
		if ${Actor[${MainTankID}].Power} < 20 && ${Actor[${MainTankID}].Distance}<50  && ${Actor[${MainTankID}].InCombatMode}
		{
			call CastSpellRange 354
			LastSpellCast:Set[354]
			call CheckCastBeam
			;; Savant is now called in the main routine
		}
	}
}

function CheckHeals()
{
	if !${DPSMode} && !${UltraDPSMode}
	{
		call UseCrystallizedSpirit 60
	
		declare temphl int local 1
	
		; Cure Arcane Me
		if ${Me.Arcane}>=1
		{
			call CastSpellRange 210 0 0 0 ${Me.ID}
			LastSpellCast:Set[210]
			
			if ${Actor[${KillTarget}](exists)}
				Target ${KillTarget}
		}
	
		if ${grpcnt} > 1
		{
			do
			{
				; Cure Arcane
				if ${Me.Group[${temphl}].ToActor(exists)}
				{
					if ${Me.Group[${temphl}].Arcane} >= 1
					{
						call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}
						LastSpellCast:Set[210]
	
						if ${Actor[${KillTarget}](exists)}
							Target ${KillTarget}
					}
				}
			}
			while ${temphl:Inc} <= ${Me.GroupCount}
		}
	}
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;
	if ${Me.Effect[Pact of Nature](exists)}
	{
		if !${Me.InRaid} && ${Actor[${MainTankID}].Health} < 60
		{
		    if (${Me.Ability[${SpellType[553]}].IsReady})
		    {
			    call CastSpellRange 553 0 0 0 ${MainTankID}
			    return
			}	
		}
		elseif !${Me.InRaid} && !${MainTank} && ${Me.ToActor.Health} < 75
		{
		    if (${Me.Ability[${SpellType[553]}].IsReady})
		    {
			    call CastSpellRange 553 0 0 0 ${MainTankID}
			    return
			}	
		}
		elseif ${Me.InRaid} && !${MainTank} && ${Me.ToActor.Health} < 35
		{
		    if (${Me.Ability[${SpellType[553]}].IsReady})
		    {
			    call CastSpellRange 553 0 0 0 ${MainTankID}
			    return
			}
		}
	}
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}

function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE


	EQ2:CreateCustomActorArray[byDist,15,npc]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if (${CustomActor[${tcount}].ID} == ${KillTarget})
			    continue
			if ${Actor[${MainAssistID}].Target.ID}==${CustomActor[${tcount}].ID} || ${Actor[${MainTankID}].Target.ID}==${CustomActor[${tcount}].ID}
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]

			;check if its agro on a group member or group member's pet
			if ${Me.GroupCount} > 1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc} <= ${Me.GroupCount}
			}

			;check if its agro on a raid member or raid member's pet
			tempvar:Set[1]
			if ${Me.InRaid}
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Raid[$tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Raid[${tempvar}].ToActor.Pet.ID}
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc} <= ${Me.Raid}
			}
			;check if its agro on me
			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
				aggrogrp:Set[TRUE]

			;if i have a mob charmed check if its agro on my charmed pet
			if ${Me.Maintained[${SpellType[351]}](exists)}
			{
				if ${CustomActor[${tcount}].Target.IsMyPet}
					aggrogrp:Set[TRUE]
			}

			if ${aggrogrp}
			{
				if ${Me.AutoAttackOn}
					eq2execute /toggleautoattack

				if ${Me.RangedAutoAttackOn}
					eq2execute /togglerangedattack

				;try to AE mezz first and check if its not single target mezzed
				if !${CustomActor[${tcount}].Effect[${SpellType[352]}](exists)}
				{
					call CastSpellRange 353 0 0 0 ${CustomActor[${tcount}].ID}
					LastSpellCast:Set[352]
				}

				;if the actor is not AE Mezzed then single target Mezz
				if !${CustomActor[${tcount}].Effect[${SpellType}[353]](exists)}
				{
					call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 10
					LastSpellCast:Set[352]
				}
				else
				{
					call CastSpellRange 92 0 0 0 ${CustomActor[${tcount}].ID} 0 10
					LastSpellCast:Set[92]
				}
				aggrogrp:Set[FALSE]
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${KillTarget}](exists)} && ${Actor[${KillTarget}].Health}>1
	{
		Target ${KillTarget}
		wait 20 ${Me.ToActor.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
		KillTarget:Set[]
	}
}

function CheckSKFD()
{
	if !${Me.ToActor.IsFD}
		return

	if !${Actor[${MainTankID}](exists)}
		return

	if ${Actor[${MainTankID}].IsDead}
		return

	if ${Me.ToActor.Health} < 20
		return

	call RemoveSKFD "Illusionist::CheckSKFD"
	return
}

atom(script) Illusionist_FinishedZoning(string TimeInSeconds)
{
	if ${KillTarget} && ${Actor[${KillTarget}](exists)}
	{
		if !${Actor[${KillTarget}].InCombatMode}
			KillTarget:Set[0]
	}
}

function PostDeathRoutine()
{	
	;; This function is called after a character has either revived or been rezzed
	InPostDeathRoutine:Set[TRUE]
	
	;; Auto-Follow
	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
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

objectdef custom_overrides
{
	method Spam()
	{
	}
}

