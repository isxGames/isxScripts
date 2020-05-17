;*************************************************************
;Defiler.iss
;version 20120503a
;by Pygar
;
;20120503a
; Curse cures are no longer restricted to self or one other.  If curse cures are selected it will cure in group curses if they exist.
; Added Heroic Tree Abilities
; General healing improvements:
;  Defiler far more likely to prioritize curing group over spaming wards on MT
;	 Defiler far more likely to use group heals when needed
;
;20090625a
;by CaPilot
;Modifed Logic for cure curse  Two options added to UI, Cure Curse (self) and Cure Curse (others)
;If healer has chosen to cure curse self, it will always cure itself first.  If anything is selected
;in the dropdown for Cure Curse(others) that char will be cured first only if the healer has not been
;cursed first.
;
;20090616a
; TSO AA updates and GU52
;
;20080513a
; * Complete re-write of all heal and curing logic.  Cures will be greatly prioritized durring epic battles.
; * Heal and cure checks should all be much less overhead and provide performance boosts for the bot
;
;20070503a
; Toggle Pet Use
; Toggle Combat Rez
;	Added health check to cure routine
; Added Toggle for Innitiating HO
;
;20070404a
; Updated for latest eq2bot
;
;20061201a
; Fixed Cyrstalize Spirit line
; implemented EoF Mastery attacks
; implemented Turgur's Spirit Sight
; implemented Vampire Theft Of Vitality
; Implemented AA Cannibalize
; Implemented AA Hexation
; Implemented AA Soul Ward
; Fixed a bug with AE healing group members out of zone
; Fixed a bug with curing uncurable afflictions
; The defiler will now use spiritual circle more often
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20120503
	;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare CureMode bool script 1
	declare CureCurseMode bool script 0
	declare MaelstromMode bool script 0
	declare KeepWardUp bool script
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare Stance int script 1
	declare AnnounceMode bool script 1
	
	declare BuffNoxious bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffStrength bool script FALSE
	declare BuffWaterBreathing bool script FALSE
	declare BuffProcGroupMember string script
	declare BuffHorrorGroupMember string script
	declare BuffAlacrityGroupMember string script
	declare CureCurseGroupMember string script
	declare DefilerDebugMode bool script FALSE
	

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	CureCurseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseMode,FALSE]}]
	CombatRez:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Rez,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	KeepWardUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepWardUp,FALSE]}]
	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	MaelstromMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Maelstrom Mode,FALSE]}]
	Stance:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Stance,]}]
	AnnounceMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[AnnounceMode,FALSE]}]

	BuffNoxious:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffNoxious,TRUE]}]
	BuffStrength:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffStrength,TRUE]}]
	BuffMitigation:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMitigation,TRUE]}]
	BuffWaterBreathing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffWaterBreathing,FALSE]}]
	BuffProcGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProcGroupMember,]}]
	BuffHorrorGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHorrorGroupMember,]}]
	BuffAlacrityGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAlacrityGroupMember,]}]
	CureCurseGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseGroupMember,]}]

	;; Set this to TRUE, as desired, for testing
	;DefilerDebugMode:Set[TRUE]
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
		
		if ${CureMode}
			call CheckCures
		
		if ${Me.Power}>85 && ${KeepWardUp}
			call CheckWards


	}

	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+15000]})
	{
		ISXEQ2:ClearAbilitiesCache 
		
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}	
	
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[BuffPower]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[BuffProc]
	PreSpellRange[3,1]:Set[41]

	PreAction[4]:Set[BuffNoxious]
	PreSpellRange[4,1]:Set[23]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[281]
	PreSpellRange[5,2]:Set[283]

	PreAction[6]:Set[SpiritCompanion]
	PreSpellRange[6,1]:Set[385]

	PreAction[7]:Set[AA_Immunities]
	PreSpellRange[7,1]:Set[383]

	PreAction[8]:Set[AA_RitualisticAggression]
	PreSpellRange[8,1]:Set[396]
	PreSpellRange[8,2]:Set[397]

	PreAction[9]:Set[AA_InfectiveBites]
	PreSpellRange[9,1]:Set[394]

	PreAction[10]:Set[AA_Coagulate]
	PreSpellRange[10,1]:Set[395]

	PreAction[11]:Set[BuffHorror]
	PreSpellRange[11,1]:Set[40]

	PreAction[12]:Set[BuffMitigation]
	PreSpellRange[12,1]:Set[21]

	PreAction[13]:Set[BuffStrength]
	PreSpellRange[13,1]:Set[20]

	PreAction[14]:Set[BuffWaterBreathing]
	PreSpellRange[14,1]:Set[280]

	PreAction[15]:Set[AA_Stance]
	PreSpellRange[15,1]:Set[503]
	PreSpellRange[15,2]:Set[502]

	PreAction[16]:Set[BuffTribalSpirit]
	PreSpellRange[16,1]:Set[509]

}

function Combat_Init()
{
	Action[1]:Set[Proc_Ward]
	MobHealth[1,1]:Set[25]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[1]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[322]

	Action[2]:Set[AoE1]
	SpellRange[2,1]:Set[90]

	Action[3]:Set[AoE2]
	SpellRange[3,1]:Set[91]

	Action[4]:Set[AARabies]
	SpellRange[4,1]:Set[352]

	Action[5]:Set[Mastery]

	Action[6]:Set[Fuliginous_Sphere]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[1]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[51]

	Action[7]:Set[Malaise]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[1]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[71]

	Action[8]:Set[Curse]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[1]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[384]

	Action[9]:Set[Imprecation]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[60]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[80]

	Action[10]:Set[TheftOfVitality]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[20]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[55]

	Action[11]:Set[ThermalShocker]

	Action[12]:Set[AA_CripplingBash]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	SpellRange[12,1]:Set[393]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]

}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare ActorID uint local

	declare temp int local

	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
		if (${Me.GroupCount} > 1)
			call CastSpellRange 313
		InitialBuffsDone:Set[TRUE]
	}

	if ${ShardMode}
		call Shard
	
	if ${CureMode}
		call CheckCures
	
	call CheckHeals
	

	if ${Me.Power}>85 && ${KeepWardUp}
		call CheckWards

	switch ${PreAction[${xAction}]}
	{
		case BuffPower
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
					if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].Name(exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						if ${Actor[${ActorID}].Type.Equal[PC]}
						{
							if (${Me.Group[${BuffTarget.Token[1,:]}].InZone} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
								{
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 0 0 2 0
								}
							}
						}
						else
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 0 0 2 0
							}
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case SpiritCompanion
			if ${PetMode} && !${Me.InCombat}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case AA_Stance
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${Stance}]}
			}
			break
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case BuffNoxious
			if ${BuffNoxious}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffMitigation
			if ${BuffMitigation}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffStrength
			if ${BuffStrength}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffWaterBreathing
			if ${BuffWaterBreathing}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffProc
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
			break
		case BuffHorror
			BuffTarget:Set[${UIElement[cbBuffHorrorGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case AA_Coagulate
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_Immunities
			if !${Me.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_RitualisticAggression
		case AA_RitualOfAbsolution
		case AA_InfectiveBites
		case BuffTribalSpirit
			if ${Me.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case SpecialVision
			if ${Me.Race.Equal[Euridite]}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare spellsused int local
	declare spellmax int local

	if (!${Actor[${KillTarget}].Name(exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0 || ${KillTarget} == 0)
		return CombatComplete

	spellmax:Set[2]
	spellsused:Set[0]

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}


	call PetAttack

	if ${CureMode}
		call CheckCures

	;Persist wards if selected.
	call CheckWards

	call CheckHeals

	;Maelstrom
	if ${MaelstromMode} && ${Me.Ability[${SpellType[317]}].IsReady}
	{
		call CastSpellRange 317 0 0 ${KillTarget}
		spellsused:Inc
	}

	call RefreshPower

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	;Cast Alacrity if available
	if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[398]}].IsReady}
	{
		BuffTarget:Set[${UIElement[cbBuffAlacrityGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

		if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
		{
			call CastSpellRange 398 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
			spellsused:Inc
		}
	}	

	if ${spellsused}>=${spellmax}
		return CombatComplete

	;Malicious Spirits
	if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[505]}].IsReady} && !${Me.Maintained[${SpellType[505]}](exists)}
	{
		call CastSpellRange 505 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}>=${spellmax}
		return CombatComplete
	call CheckGroupHealth 80

	;aoe checks
	;Avenging Ancesters
	if ${spellsused}<${spellmax} && ${Mob.Count}>2 && ${Me.Ability[${SpellType[506]}].IsReady} && !${Me.Maintained[${SpellType[506]}](exists)}
	{
		call CastSpellRange 506 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Defile
	if ${spellsused}<${spellmax} && ${Mob.Count}>2 && ${Me.Ability[${SpellType[506]}].IsReady} && !${Me.Maintained[${SpellType[506]}](exists)}
	{
		call CastSpellRange 506 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;nightmares
	if ${spellsused}<${spellmax} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[93]}].IsReady}
	{
		call CastSpellRange 93 0 0 0 ${KillTarget}
		spellsused:Inc
	}	
	;absolute corruption
	if ${spellsused}<${spellmax} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[90]}].IsReady}
	{
		call CastSpellRange 90 0 0 0 ${KillTarget}
		spellsused:Inc
	}	

	if ${spellsused}>=${spellmax}
		return CombatComplete
	call CheckGroupHealth 80


	if ${Return} && ${spellsused}<${spellmax} && ${DebuffMode} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsHeroic})
	{
		;Umbral Trap
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[54]}].IsReady} && !${Me.Maintained[${SpellType[54]}](exists)}
		{
			call CastSpellRange 54 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Bane of Warding
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[322]}].IsReady} && !${Me.Maintained[${SpellType[322]}](exists)}
		{
			call CastSpellRange 322 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Spiritwrath
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[511]}].IsReady}
		{
			call CastSpellRange 511 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Atrophy
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)}
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Abomination
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)}
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Abhorrent Seal
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[53]}].IsReady} && !${Me.Maintained[${SpellType[53]}](exists)}
		{
			call CastSpellRange 53 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Fuliginous Whip
		if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)} && ${OffenseMode}
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	if ${spellsused}>=${spellmax}
		return CombatComplete
	call CheckGroupHealth 80


	;keep Leg Bite up at all times if we have a pet
	if ${Me.Maintained[${SpellType[385]}](exists)}
		call CastSpellRange 388

	call VerifyTarget
	if ${Return.Equal[FALSE]}
	{
		if ${DefilerDebugMode}
			Debug:Echo["Combat_Routine() -- Exiting (Target no longer valid: CombatComplete)"]
		return CombatComplete
	}

	;Wrath
	if ${spellsused}<${spellmax} && ${Me.Ability[${SpellType[56]}].IsReady} && !${Me.Maintained[${SpellType[56]}](exists)}
	{
		call CastSpellRange 56 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	if ${Return} && ${spellsused}<${spellmax}
	{
		switch ${Action[${xAction}]}
		{
			case Curse
			case TheftOfVitality
					if ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case AA_CripplingBash
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${DebuffMode} && ${Me.Maintained[${SpellType[385]}](exists)}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Proc_Ward
			case Fuliginous_Sphere
				break
			case Malaise
			case Imprecation
				if ${OffenseMode} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case AoE1
			case AoE2
			case AARabies
				if ${AoEMode} && ${Mob.Count}>2 && ${OffenseMode}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Mastery
				if ${Me.Ability[Master's Smite].IsReady} && ${Actor[${KillTarget}].Name(exists)} && ${OffenseMode}
				{
					Target ${KillTarget}
					Me.Ability[Master's Smite]:Use
				}
				break
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				break
			default
				return CombatComplete
				break
		}
	}

  call CheckGroupHealth 80
	if ${spellsused}<${spellmax} && ${Return} && ${Me.Ability[${SpellType[382]}].IsReady} && !${Me.Maintained[${SpellType[382]}](exists)}
	{
		call CastSpellRange 382 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	call CheckGroupHealth 60
	if ${DoHOs} && ${Return}
		objHeroicOp:DoHO

}

function Post_Combat_Routine(int xAction)
{
	declare tempgrp int 1
	;Turn off Maelstrom so we can move
	if ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

	call CheckCures

	TellTank:Set[FALSE]

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].IsDead}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1 0 0 0 2 0
			}
			while ${tempgrp:Inc} <= ${Me.GroupCount}
			break
		default
			return PostCombatRoutineComplete
			break
	}
	call CheckHeals
}

function Have_Aggro(int aggroid)
{
	if ${Me.Health}<50 || ${Actor[${aggroid}].IsEpic}
	{
		if  ${Me.Ability[${SpellType[180]}].IsReady}
			call CastSpellRange 180 0 0 0 ${aggroid}
		elseif ${Me.Ability[${SpellType[181]}].IsReady}
			call CastSpellRange 181 0 0 0 ${aggroid}	
	}
}

function RefreshPower()
{
	;AA Cannibalize
	if ${Me.Power}<45  && ${Me.Health}>50
	{
		call CastSpellRange 387
		call CastSpellRange 381
	}

	;Forced Canabalize
	if ${Me.Power}<85 && ${Me.InCombat}  && !${Actor[${KillTarget}].Name.Upper.Find[DRUSELLA]} && !${Actor[${KillTarget}].Name.Upper.Find[VENRIL SATHIR]}
		call CastSpellRange 72 0 0 0 ${KillTarget}
}

function CheckHealerMob()
{
	variable index:actor Actors
	variable iterator ActorIterator

	EQ2:QueryActors[Actors, (Type =- "NPC" || Type =- "NamedNPC") && Distance <= 15]
	Actors:GetIterator[ActorIterator]

	if ${ActorIterator:First(exists)}
	{
		do
		{
			if ${Mob.ValidActor[${ActorIterator.Value.ID}]}
			{
				switch ${ActorIterator.Value.Class}
				{
					case templar
					case inquisitor
					case fury
					case warden
					case defiler
					case mystic
						return TRUE
				}
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	return FALSE
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	if ${Actor[ExactName,PC,${MainTankPC}].IsDead} && ${Actor[ExactName,PC,${MainTankPC}].Name(exists)} && ${CombatRez}
		call 300 301 1 0 ${Actor[ExactName,PC,${MainTankPC}].ID} 1 0 0 0 2 0
}

function CheckCures()
{
	variable int i = 1
	declare grpcure int local 0
	declare Affcnt int local 0
	declare CureTarget string local
	
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0
	
	
	;check for group cures, if it is ready and we are in a large enough group
	if (${Me.GroupCount} > 1)
	{
		if ${Me.Ability[${SpellType[220]}].IsReady}
		{
			Debug:Echo["CheckCures() - Mail of Souls READY!"]
  		if (${Me.IsAfflicted}) && (${Me.Noxious}>0 || ${Me.Arcane}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0)
  		{
  			Debug:Echo["I am afflicted. [${Me.IsAfflicted} - ${Me.Arcane}]"]
  			grpcure:Inc
  		}

			do
			{
					
				if (${Me.Group[${i}].InZone} && ${Me.Group[${i}].Health(exists)} && ${Me.Group[${i}].IsAfflicted} && ${Me.Group[${i}].Distance} <= 40)
				{
					if ${Me.Group[${i}].Noxious}>0 || ${Me.Group[${i}].Arcane}>0 || ${Me.Group[${i}].Elemental}>0 || ${Me.Group[${i}].Trauma}>0
					{
						Debug:Echo["Group member ${i}. ${Me.Group[${i}].Name} (${Me.Group[${i}].Name}) is afflicted.  [${Me.Group[${i}].IsAfflicted} - ${Me.Group[${i}].Distance}]"]
						grpcure:Inc
					}
				}
			}
			while ${i:Inc} <= ${Me.GroupCount}  	
		
			if ${grpcure} > 2
			{
				Debug:Echo["DEBUG:: grpcure at ${grpcure} casting Mail of Souls"]
				call CastSpellRange 220 0 0 0 ${Me.ID} 0 0 0 0 1 0
				wait 5
				if ${AnnounceMode} && ${Me.CastingSpell}
				{
					eq2execute gsay Group Cure Now!
				}
				while ${Me.CastingSpell}
				{
					waitframe
				}	
			}
	  }
	}
	
	;Cure Ourselves first
  if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
		call CureMe


	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	while ${Affcnt:Inc}<7 && ${Me.Health}>10 
	{
		call CheckCurse
		if ${Return}>0
			call CureGroupMember ${Return}
			
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;epicmode is set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;Cure Ourselves first
	  if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
			call CureMe

		;healself if needed
		if ${Me.Health}>30
			call HealMe

		;Check MT health and heal him if needed
		if ${Actor[${MainTankID}].Health}<25
		{
			if ${MainTankID}==${Me.ID}
				call HealMe
			else
				call HealMT
		}
	}

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
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].Health(exists)} && ${Me.Group[${temphl}].Distance}<=35
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

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CheckCurse()
{
	declare temphl int local 1
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflicted int local 0


	if ${CureCurseMode} || !${Me.Ability[${SpellType[211]}].IsReady}
		return 0
	
	;check for single target cures
	do
	{
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].Health(exists)} && ${Me.Group[${temphl}].Distance}<=35
		{
			if ${Me.Group[${temphl}].Cursed}
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+1]}]

			if ${tmpafflictions}>${mostafflictions}
			{
				mostafflictions:Set[${tmpafflictions}]
				mostafflicted:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc} <= ${Me.GroupCount}

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CureMe()
{
	declare AffCnt int 0
	declare CureCnt int 0

	;check if we are not in control, and use control cure if needed
	if !${Me.CanTurn} || ${Me.IsRooted}
		call CastSpellRange 326

	if !${Me.IsAfflicted}
		return

	if ${Me.Cursed} && ${CureCurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	while ${CureCnt:Inc}<4 && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0)
	{
		if ${Me.Arcane}>0
		{
			AffCnt:Set[${Me.Arcane}]
			call CastSpellRange 210 0 0 0 ${Me.ID} 0 0 0 0 1 0
			wait 5

			;if we tried to cure and it failed to work, we might be charmed, use control cure
			if ${Me.Arcane}==${AffCnt}
				call CastSpellRange 326 0 0 0 ${KillTarget} 0 0 0 0 1 0
		}

		if  ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID} 0 0 0 0 1 0
			wait 5
		}

		if ${Me.Health}<30 && ${EpicMode}
			call HealMe
	}
}

function HealMe()
{
	;ME HEALS
	; if i have summoned a defiler crystal use that to heal first
	if !${Me.CastingSpell} && ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.Health}<70 && ${Me.InCombatMode}
	{
		Me.Inventory[Crystallized Spirit]:Use
		wait 5
	}

	if ${Me.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 387
				call CastSpellRange 1 0 0 0 ${Me.ID} 0 0 0 0 2 0
			}
			else
			{
				call CastSpellRange 387
				call CastSpellRange 4 0 0 0 ${Me.ID} 0 0 0 0 2 0
			}
		}
	}

	if ${Me.Health}<85
	{
		call CastSpellRange 387
		call CastSpellRange 4 0 0 0 ${Me.ID} 0 0 0 0 2 0
	}
}

function CheckHeals()
{
	declare tempgrp int local 1
	declare temphl int local 1
	declare grpheal int local 0
	declare lowest int local 0
	declare PetToHeal int local 0
	declare MainTankID int local 0
	declare MainTankInGroup bool local 0
  declare MainTankExists bool local 1

	if ${Me.Name.Equal[${MainTankPC}]}
		MainTankID:Set[${Me.ID}]
	else
		MainTankID:Set[${Actor[PC,ExactName,${MainTankPC}].ID}]

  if !${Actor[${MainTankID}].Name(exists)}
  {
    echo "EQ2Bot-CheckHeals() -- MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"
    MainTankExists:Set[FALSE]
  }
  else
    MainTankExists:Set[TRUE]
    
	;Persist wards if selected.
	call CheckWards

  if ${Me.GroupCount} > 1
  {
		do
		{
			if ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].Health(exists)}
			{
				if ${Me.Group[${temphl}].Health}<100 && !${Me.Group[${temphl}].IsDead}
				{
					if (${Me.Group[${temphl}].Health}<${Me.Group[${lowest}].Health} || ${lowest}==0) && ${Me.Group[${temphl}].Distance}<=${Me.Ability[${SpellType[1]}].ToAbilityInfo.Range}
						lowest:Set[${temphl}]
				}

				if ${Me.Group[${temphl}].ID}==${MainTankID}
					MainTankInGroup:Set[1]

				if !${Me.Group[${temphl}].IsDead} && ${Me.Group[${temphl}].Health}<80 && ${Me.Group[${temphl}].Distance}<=30
					grpheal:Inc

				if ${Me.Group[${temphl}].Pet.Health}<60 && ${Me.Group[${temphl}].Pet.Health}>0 && !${EpicMode}
					PetToHeal:Set[${Me.Group[${temphl}].Pet.ID}

				if ${Me.Pet.Health}<60 && !${EpicMode}
					PetToHeal:Set[${Me.Pet.ID}]
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		if ${Me.Health}<80 && !${Me.IsDead}
			grpheal:Inc
	}

  if (${MainTankExists})
  {
  	if ${Actor[${MainTankID}].Health}<75
  	{
  		if ${Me.ID}==${MainTankID}
  			call HealMe
  		else
  			call HealMT ${MainTankID} ${MainTankInGroup}
  	}

  	;Check My health after MT
    if ${Me.ID}!=${MainTankID} && ${Me.Health}<25
	    call HealMe
  }


	if ${PetMode} && ${grpheal}>1 && ${Me.Ability[${SpellType[16]}].IsReady} || (${EpicMode} && ${Me.InCombat})
		call CastSpellRange 16

	if ${grpheal}>1
	{
		call GroupHeal
		if ${Return}
			return
	}
	
	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		if ${Me.Group[${lowest}].Health}<80
			call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].Health(exists)} && ${Me.Group[${lowest}].Health}<50 && !${Me.Group[${lowest}].IsDead} && ${Me.Group[${lowest}].InZone} && ${Me.Group[${lowest}].Distance}<=35
			call CastSpellRange 387

		if ${Me.Group[${lowest}].Health(exists)} && ${Me.Group[${lowest}].Health}<70 && !${Me.Group[${lowest}].IsDead} && ${Me.Group[${lowest}].InZone} && ${Me.Group[${lowest}].Distance}<=35
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ID} 0 0 0 0 2 0
			elseif ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ID} 0 0 0 0 2 0
			elseif ${Me.Ability[${SpellType[10]}].IsReady}
				call CastSpellRange 10 0 0 0 ${Me.Group[${lowest}].ID} 0 0 0 0 2 0
		}
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}].Name(exists)} && ${Actor[${PetToHeal}].InCombatMode} && ${Actor[${PetToHeal}].Distance}<=${Me.Ability[${SpellType[4]}].ToAbilityInfo.Range}
		call CastSpellRange 4 0 0 0 ${PetToHeal} 0 0 0 0 2 0

	if ${EpicMode}
		call CheckCures

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].IsDead} && ${Me.Group[${temphl}].Health(exists)} && ${Me.Group[${temphl}].Distance}<=20
			{
				if !${Me.InCombat} && ${Me.Ability[${SpellType[500]}].IsReady}
					call CastSpellRange 500 0 0 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
				elseif ${Me.Ability[${SpellType[304]}].IsReady}
					call CastSpellRange 304 0 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
				elseif ${Me.Ability[${SpellType[301]}].IsReady}
					call CastSpellRange 301 0 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
				elseif ${Me.Ability[${SpellType[300]}].IsReady}
					call CastSpellRange 300 0 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}
	}
}

function HealMT(int MTID, int MTInMyGroup)
{
	;Phantasmal Barrier
	if ${Me.Ability[${SpellType[510]}].IsReady} && ${Actor[${MTID}].Health}<50
	{
		eq2execute useability Phantasmal Barrier
	}
		
	;DeathWard Check
	if ${Actor[${MTID}].Health}<50 && !${Actor[${MTID}].IsDead} && ${Actor[${MTID}].Name(exists)} && ${Actor[${MTID}].Distance}<=${Me.Ability[${SpellType[8]}].ToAbilityInfo.Range}
		call CastSpellRange 8 0 0 0 ${MTID} 0 0 0 0 1 0

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MTID}].Health}<30 && !${Actor[${MTID}].IsDead} && ${Actor[${MTID}].Name(exists)}
		call EmergencyHeal ${MTID}

	if ${Actor[${MTID}].Health}<50 && ${Me.Ability[${SpellType[1]}].IsReady} && ${Actor[${MTID}].Name(exists)} && ${Actor[${MTID}].Distance}<=35
	{
		call CastSpellRange 387
		call CastSpellRange 1 0 0 0 ${KillTarget} 0 0 0 0 2 0
	}


	;MAINTANK HEALS
	if ${Actor[${MTID}].Health}<75 && !${Actor[${MTID}].IsDead} && ${Actor[${MTID}].Name(exists)} && ${Actor[${MTID}].Distance}<=40
	{
		call CastSpellRange 387
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${MTID} 0 0 0 0 2 0
		else
			call CastSpellRange 4 0 0 0 ${MTID} 0 0 0 0 2 0
	}
		
}

function GroupHeal()
{
	declare grphealcast int local 0
	call CastSpellRange 387

	if ${Me.Ability[${SpellType[504]}].IsReady}
	{
		call CastSpellRange 504 0 0 0 ${KillTarget} 0 0 0 0 2 0
		grphealcast:Inc
	}
	elseif ${Me.Ability[${SpellType[10]}].IsReady}
	{
		call CastSpellRange 10 0 0 0 ${KillTarget} 0 0 0 0 2 0
		grphealcast:Inc
	}
	elseif ${Me.Ability[${SpellType[507]}].IsReady}
	{
		call CastSpellRange 507 0 0 0 ${KillTarget} 0 0 0 0 2 0
		grphealcast:Inc
	}
	elseif ${Me.Ability[${SpellType[508]}].IsReady}
	{
		call CastSpellRange 508 0 0 0 ${KillTarget} 0 0 0 0 2 0
	}
	else
	{
		call CastSpellRange 15 0 0 0 ${KillTarget} 0 0 0 0 2 0
	}
	
	return ${grphealcast}
	
}

function EmergencyHeal(int healtarget)
{
	;Soul Ward
	if ${Me.ID}!=${healtarget}
	call CastSpellRange 380 0 0 0 ${healtarget} 0 0 0 0 1 0

	;if we cast soulward exit emergency heal
	if ${Me.Maintained[${SpellType[380]}](exists)}
		return

	;Phantasmal Barrier
	if ${Me.Ability[${SpellType[510]}].IsReady}
	{
		eq2execute useability Phantasmal Barrier
		call GroupHeal
	}
	
	;Avenger Death Save
	call CastSpellRange 338 0 0 0 ${healtarget} 0 0 0 0 1 0

	if ${Me.Ability[${SpellType[335]}].IsReady}
		call CastSpellRange 335 0 0 0 ${healtarget} 0 0 0 0 1 0
	else
		call CastSpellRange 334 0 0 0 ${healtarget} 0 0 0 0 1 0
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].InZone} || ${Me.Group[${gMember}].IsDead} || !${Me.Group[${gMember}].Health(exists)} && !${Me.Group[${gMember}].IsAfflicted} || ${Me.Group[${gMember}].Distance}>${Me.Ability[${SpellType[210]}].ToAbilityInfo.Range}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}].InZone} && !${Me.Group[${gMember}].IsDead} && ${Me.Group[${gMember}].Health(exists)}
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID} 0 0 0 0 ${EpicMode}
			wait 2
		}
	}
}

function CheckWards()
{

	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]

	if ${KeepWardUp}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID}==${Actor[PC,ExactName,${MainTankPC}].ID}
			{
				;echo Single ward is Present on MT
				hot1:Set[1]
				break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group ward is Present
				grphot:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${hot1}==0 && ${Me.CurrentPower}>${Me.Ability[${SpellType[7]}].ToAbilityInfo.PowerCost}
		{
			call CastSpellRange 7 0 0 0 ${Actor[PC,ExactName,${MainTankPC}].ID} 0 0 0 0 2 0
			hot1:Set[1]
		}

		if ${grphot}==0 && ${Me.CurrentPower}>${Me.Ability[${SpellType[15]}].ToAbilityInfo.PowerCost}
			call CastSpellRange 15
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}