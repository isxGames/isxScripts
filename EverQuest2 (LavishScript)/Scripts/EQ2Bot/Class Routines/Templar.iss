;*************************************************************
;templar.iss
;version 20080515a
;by Pygar
;paypal - pygar@happyhacker.com
;
;20080515a
; * Updated Heal Routines
;	* New Cure Logic
; * Cure Curse now configured
;20080207a
; Initial Release
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20080515
  ;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
 	declare AoEMode bool script 0
 	declare CureMode bool script 0
	declare CurseMode bool script 1
 	declare FocusedMode bool script 0
 	declare PreHealMode bool script 0
	declare KeepReactiveUp bool script 0
	declare KeepGroupReactiveUp bool script 0
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare MeleeMode bool script 1
	declare YaulpMode bool script 1
	declare ShieldAllyMode bool script 0
	declare HolyShieldMode bool script 0
	declare ManaCureMode bool script 0
	declare BuffCourage bool script
	declare BuffSymbol bool script
	declare RaidHealMode bool script
	declare Stance int script 1

	declare BuffWaterBreathing bool script FALSE
	declare BuffGloryGroupMember string script
	declare BuffBennedictionGroupMember string script
	declare BuffPraetorateGroupMember string script
 	declare BuffShieldAllyGroupMember string script
	declare HolyShieldGroupMember string script
	declare ManaCureGroupMember string script
	declare tempMH string script

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	CurseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Curse Spells,FALSE]}]
	FocusedMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Focused Mode,FALSE]}]
	PreHealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PreHeal Mode,FALSE]}]
	KeepReactiveUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepReactiveUp,FALSE]}]
	KeepGroupReactiveUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepGroupReactiveUp,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	CombatRez:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Rez,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	MeleeMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MeleeMode,FALSE]}]
	YaulpMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[YaulpMode,FALSE]}]
	ShieldAllyMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ShieldAllyMode,FALSE]}]
	HolyShieldMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[HolyShieldMode,FALSE]}]
	ManaCureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ManaCureMode,FALSE]}]
	BuffCourage:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffCourage,FALSE]}]
	BuffSymbol:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSymbol,FALSE]}]
	RaidHealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[RaidHealMode,FALSE]}]
	Stance:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Stance,]}]

	BuffWaterBreathing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffWaterBreathing,FALSE]}]
	BuffGloryGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffGloryGroupMember,]}]
	BuffBennedictionGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffBennedictionGroupMember,]}]
	BuffPraetorateGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffPraetorateGroupMember,]}]
	BuffShieldAllyGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffShieldAllyGroupMember,]}]
	HolyShieldGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[HolyShieldGroupMember,]}]
	ManaCureGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ManaCureGroupMember,]}]
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

		if ${Me.ToActor.Power}>85 && ${PreHealMode}
		{
			if ${KeepReactiveUp}
				call CastSpellRange 7 0 0 0 ${Actor[PC,ExactName,${MainTankPC}].ID}
			if ${KeepGroupReactiveUp}
				call CastSpellRange 15
		}

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[BuffRedoubt]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[BuffGlory]
	PreSpellRange[2,1]:Set[38]

	PreAction[3]:Set[Bennediction]
	PreSpellRange[3,1]:Set[39]

	PreAction[4]:Set[Praetorate]
	PreSpellRange[4,1]:Set[36]

	PreAction[5]:Set[Blessings]
	PreSpellRange[5,1]:Set[392]

	PreAction[6]:Set[ShieldAlly]
	PreSpellRange[6,1]:Set[383]

	PreAction[7]:Set[ManaCure]
	PreSpellRange[7,1]:Set[394]

	PreAction[8]:Set[WaterBreathing]
	PreSpellRange[8,1]:Set[22]

	PreAction[9]:Set[BuffCourage]
	PreSpellRange[9,1]:Set[20]

	PreAction[10]:Set[BuffSymbol]
	PreSpellRange[10,1]:Set[21]

	PreAction[11]:Set[AA_Stance]
	PreSpellRange[11,1]:Set[501]
	PreSpellRange[11,2]:Set[502]
}

function Combat_Init()
{
	Action[1]:Set[AoE]
	SpellRange[1,1]:Set[90]

	Action[2]:Set[Involuntary]
	SpellRange[2,1]:Set[52]

	Action[3]:Set[Reverence]
	SpellRange[3,1]:Set[155]

	Action[4]:Set[Hammer]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[50]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[230]

	Action[5]:Set[Stun]
	MobHealth[5,1]:Set[10]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[30]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[56]

	Action[6]:Set[Melee1]
	Power[6,1]:Set[30]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[386]

	Action[7]:Set[Melee3]
	Power[7,1]:Set[30]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[380]

	Action[8]:Set[Dot1]
	MobHealth[8,1]:Set[10]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[30]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[70]

	Action[9]:Set[Melee2]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[382]

	Action[10]:Set[Dot2]
	MobHealth[10,1]:Set[10]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[30]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[71]

	Action[11]:Set[Turn_Undead]
	MobHealth[11,1]:Set[10]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[20]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[388]

	Action[12]:Set[Divine_Castigation]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[20]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[390]

	Action[13]:Set[Mastery]
	SpellRange[13,1]:Set[360]

	Action[14]:Set[DD1]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[20]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[60]

	Action[15]:Set[DD2]
	MobHealth[15,1]:Set[1]
	MobHealth[15,2]:Set[100]
	Power[15,1]:Set[20]
	Power[15,2]:Set[100]
	SpellRange[15,1]:Set[61]

	Action[16]:Set[Ammending]
	MobHealth[16,1]:Set[10]
	MobHealth[16,2]:Set[30]
	Power[16,1]:Set[1]
	Power[16,2]:Set[100]
	SpellRange[16,1]:Set[312]

	Action[17]:Set[ThermalShocker]
}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]
	PostSpellRange[1,3]:Set[302]
	PostSpellRange[1,4]:Set[303]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	declare temp int local

	switch ${PreAction[${xAction}]}
	{
		case BuffRedoubt
			Counter:Set[1]
			tempvar:Set[1]

			if !${Me.Equipment[The Impact of the Sacrosanct](exists)} && !${Me.Inventory[The Impact of the Sacrosanct](exists)}
			{
				;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
				do
				{
					BuffMember:Set[]
					;check if the maintained buff is of the spell type we are buffing
					if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
					{
						;iterate through the members to buff
						if ${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
						{
							tempvar:Set[1]
							do
							{
								BuffTarget:Set[${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
								if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
								{
									BuffMember:Set[OK]
									break
								}
							}
							while ${tempvar:Inc}<=${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
				if ${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
				{
					do
					{
						BuffTarget:Set[${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					}
					while ${Counter:Inc}<=${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
				}
			}
			else
			{
				; we have the templar mythical so using different logic for this buff
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					if !${Me.Equipment[The Impact of the Sacrosanct](exists)} && !${Me.Maintained[Impenetrable Faith](exists)}
					{
						tempMH:Set[${Me.Equipment[Primary].Name}]
						waitframe
						Me.Inventory[The Impact of the Sacrosanct]:Equip
						waitframe
						call CastSpellRange ${PreSpellRange[${xAction},1]}
						waitframe
						Me.Inventory[${tempMH}]:Equip
					}
					else
						call CastSpellRange ${PreSpellRange[${xAction},1]}
				}
			}
			break
		case AA_Stance
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${Stance}]}
			}
			break
		case BuffCourage
			if ${BuffCourage}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffSymbol
			if ${BuffSymbol}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case WaterBreathing
			if ${BuffWaterBreathing}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffGlory
			BuffTarget:Set[${UIElement[cbBuffGloryGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case Bennediction
			BuffTarget:Set[${UIElement[cbBuffBennedictionGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case Praetorate
			BuffTarget:Set[${UIElement[cbBuffPraetorateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case ShieldAlly
			if ${ShieldAllyMode}
			{
				BuffTarget:Set[${UIElement[cbBuffShieldAllyGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case ManaCure
			if ${ManaCureMode}
			{
				BuffTarget:Set[${UIElement[cbManaCureGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Blessings
		case Group_Buff
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

	spellsused:Set[0]
	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${YaulpMode} && !${Me.Maintained[${SpellType[385]}](exists)}
		call CastSpellRange 385
	elseif !${YaulpMode} && ${Me.Maintained[${SpellType[385]}](exists)}
		Me.Maintained[${SpellType[385]}]:Cancel

	if ${Me.Pet(exists)}
		call PetAttack

	if ${CureMode}
		call CheckCures

	call CheckHeals

	if ${DebuffMode} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsHeroic})
	{
		;Divine Recovery first if up
		if ${Me.Ability[${SpellType[390]}].IsReady} && !${Me.Maintained[${SpellType[390]}](exists)}
		{
			call CastSpellRange 391 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)} && ${spellsused}<1
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)} && ${spellsused}<1
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)} && ${spellsused}<1
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}


	if ${FocusedMode}
	{
		call CheckGroupHealth 60

		if ${Return}
			call CastSpellRange 9
		elseif ${Me.Maintained[${SpellType[9]}](exists)}
			Me.Maintained[${SpellType[9]}]:Cancel
	}
	elseif ${Me.Maintained[${SpellType[9]}](exists)}
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}

	call RefreshPower

	if ${ShardMode}
		call Shard

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 50
	if ${Return}
	{

		call CheckGroupHealth 60
		if ${DoHOs} && ${Return}
			objHeroicOp:DoHO

		if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
			call CastSpellRange 333

		if ${MeleeMode} && ${Actor[${KillTaget}].Distance}>4
			call CheckPosition 1 ${Actor[${KillTarget}].IsEpic}

		switch ${Action[${xAction}]}
		{
			case Ammending
			case DD1
			case DD2
			case Divine_Castigation
			case Turn_Undead
			case Stun
			case Dot1
			case Dot2
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${OffenseMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case Hammer
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${OffenseMode} && ${PetMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case Melee1
			case Melee2
			case Melee3
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${MeleeMode} && ${OffenseMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
				}
				break
			case Reverence
				if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Involuntary
				echo Involuntary Cast ${SpellRange[${xAction},1]}
				if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case AoE
				if ${AoEMode} && ${OffenseMode} && ${Mob.Count}>2
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Mastery
				;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
				if (${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)})
						break

				if ${Me.Ability[Master's Smite].IsReady} && ${Actor[${KillTarget}](exists)} && ${OffenseMode}
					Me.Ability[Master's Smite]:Use
				break
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady} && ${OffenseMode}
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				break
			default
				return CombatComplete
				break
		}

	}
}

function Post_Combat_Routine(int xAction)
{
    declare tempgrp int 1

	;Turn off Focused so we can move
	if ${Me.Maintained[${SpellType[9]}](exists)}
		Me.Maintained[${SpellType[9]}]:Cancel

	TellTank:Set[FALSE]

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.IsDead}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
			}
			while ${tempgrp:Inc} <= ${Me.GroupCount}
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro(int aggroid)
{
	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if !${MainTank}
		call CastSpellRange 180

}

function RefreshPower()
{
	if ${Me.InCombat} && ${Me.ToActor.Power}<45
		call UseItem "Spiritise Censer"

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
		call UseItem "Stein of the Everling Lord"
}

function CheckCures()
{
	declare temphl int local 1
	declare grpcure int local 0
	declare Affcnt int local 0

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount}>2
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Arcane}>0 || ${Me.Trauma}>0
				grpcure:Inc
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<${Me.Ability[${SpellType[210]}].Range}
			{
				if ${Me.Group[${temphl}].Arcane}>0 || ${Me.Group[${temphl}].Trauma}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		if ${grpcure}>2
		{
			call CastSpellRange 220
			call CastSpellRange 221
		}
	}

	;Cure Ourselves first
  if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
		call CureMe

	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	while ${Affcnt:Inc}<7 && ${Me.ToActor.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;epicmode is set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;break if we need heals
		call CheckGroupHealth 30
		if !${Return}
			break

		;Check MT health and heal him if needed
		if ${Actor[pc,ExactName,${MainTankPC}].Health}<50
		{
			if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID}
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
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[210]}].Range}
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

function CureMe()
{
	declare AffCnt int 0
	declare CureCnt int 0

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || ${Me.ToActor.IsRooted}
		call CastSpellRange 381

	if !${Me.IsAfflicted}
		return

	if ${Me.Cursed} && ${CurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	while ${CureCnt:Inc}<4 && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0)
	{
		if ${Me.Arcane}>0
		{
			AffCnt:Set[${Me.Arcane}]
			call CastSpellRange 210 0 0 0 ${Me.ID} 0 0 0 0 1 0
			wait 2

			;if we tried to cure and it failed to work, we might be charmed, use control cure
			if ${Me.Arcane}==${AffCnt}
				call CastSpellRange 222 0 0 0 ${KillTarget} 0 0 0 0 1 0
		}

		if ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID} 0 0 0 0 1 0
			wait 2
		}

		if ${Me.ToActor.Health}<30 && ${EpicMode}
			call HealMe
	}

}

function HealMe()
{
	if ${Me.Cursed} && ${CurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;ME HEALS
	; if i have summoned a defiler crystal use that to heal first
	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.ID}
			else
				call CastSpellRange 4 0 0 0 ${Me.ID}
		}
	}

	if ${Me.ToActor.Health}<75
	{
		if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID} && ${Me.ToActor.InCombatMode}
			call CastSpellRange 7 0 0 0 ${Me.ID}
		else
			call CastSpellRange 4 0 0 0 ${Me.ID}
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
		MainTankID:Set[${Actor[pc,ExactName,${MainTankPC}].ID}]

  if !${Actor[${MainTankID}](exists)}
  {
	  echo "EQ2Bot-CheckHeals() -- MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"
    MainTankExists:Set[FALSE]
  }
  else
  	MainTankExists:Set[TRUE]


	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed} && ${CurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Res the MT if they are dead
	if (${MainTankExists})
	{
    if (!${Me.ToActor.InCombatMode} || ${CombatRez}) && ${Actor[${MainTankID}].IsDead}
    	call CastSpellRange 300 0 1 1 ${MainTankID}

    if ${Actor[${MainTankID}].Health}<50 && ${Me.Ability[${SpellType[4]}].IsReady}
    	call CastSpellRange 4 0 0 0 ${MainTankID}
  }

	call CheckReactives

  if ${Me.GroupCount} > 1
  {
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
				{
					if (${Me.Group[${temphl}].ToActor.Health}<${Me.Group[${lowest}].ToActor.Health} || ${lowest}==0) && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
						lowest:Set[${temphl}]
				}

				if ${Me.Group[${temphl}].ID}==${MainTankID}
					MainTankInGroup:Set[1]

				if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80
					grpheal:Inc

				if (${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}) && ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}

				if ${Me.ToActor.Pet.Health}<60
					PetToHeal:Set[${Me.ToActor.Pet.ID}]
			}
		}
		while ${temphl:Inc}<=${Me.GroupCount}

		if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
			grpheal:Inc

		if ${grpheal}>2
			call GroupHeal
	}

  if (${MainTankExists})
  {
  	if ${Actor[${MainTankID}].Health}<90
  	{
  		if ${Me.ID}==${MainTankID}
  			call HealMe
  		else
  			call HealMT ${MainTankID} ${MainTankInGroup}
  	}

  	;Check My health after MT
    if ${Me.ID}!=${MainTankID} && ${Me.ToActor.Health}<50
	    call HealMe
  }
  else
  {
    if ${Me.ToActor.Health}<60
        call HealMe
  }

	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
		{
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			else
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
	}

	if ${EpicMode}
		call CheckCures

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)} && ${Actor[${PetToHeal}].InCombatMode} && !${EpicMode}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Distance}<=20
			{
				if !${Me.InCombat} && ${Me.Ability[${SpellType[500]}].IsReady}
					call CastSpellRange 500 0 0 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
				else
					call CastSpellRange 300 303 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}
	}
}

function HealMT(int MainTankID, int MTInMyGroup)
{
	if ${Me.Cursed} && ${CurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call EmergencyHeal ${MainTankID}

	if ${Actor[${MainTankID}].Health}<50 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)} && !${Me.Equipment[The Impact of the Sacrosanct].IsReady}
	{
		Actor[${MainTankID}]:DoTarget
		wait 2
		Me.Equipment[The Impact of the Sacrosanct]:Use
		wait 2
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
		wait 1
	}

	;MAINTANK HEALS
	if ${Actor[${MainTankID}].Health}<60 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[2]}].IsReady}
			call CastSpellRange 2 0 0 0 ${MainTankID}
		else
			call CastSpellRange 4 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<70 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if !${Me.Maintained[${SpellType[7]}](exists)} && ${Me.Ability[${SpellType[7]}].IsReady}
			call CastSpellRange 7 0 0 0 ${MainTankID}
		elseif !${Me.Maintained[${SpellType[15]}](exists)} && ${Me.Ability[${SpellType[15]}].IsReady}
			call CastSpellRange 15 0 0 0 ${MainTankID}

		if ${Me.Ability[${SpellType[1]}].IsReady} && ${Actor[${MainTankID}].Health}<70
			call CastSpellRange 1 0 0 0 ${MainTankID}
		elseif ${Me.Ability[${SpellType[4]}].IsReady} && ${Actor[${MainTankID}].Health}<70
			call CastSpellRange 4 0 0 0 ${MainTankID}
		elseif ${Me.Ability[${SpellType[2]}].IsReady} && ${Actor[${MainTankID}].Health}<70
			call CastSpellRange 2 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${MTInMyGroup} && ${EpicMode} && ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)}
		{
			call CastSpellRange 15
		}
		elseif !${Me.Maintained[${SpellType[7]}](exists)}
			call CastSpellRange 7 0 0 0 ${MainTankID}

		if ${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Maintained[${SpellType[7]}](exists)} && ${EpicMode}
			call CastSpellRange 7 0 0 0 ${MainTankID}
	}
}

function GroupHeal()
{
	if ${Me.Cursed} && ${CurseMode}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	else
		call CastSpellRange 15
}

function EmergencyHeal(int healtarget)
{
	if ${Me.Ability[${SpellType[401]}].IsReady}
	{
		call CastSpellRange 401 0 0 0 ${healtarget}
	}
	elseif ${Me.Ability[${SpellType[11]}].IsReady} && ${MTinMyGroup}
	{
		call CastSpellRange 11
		call CastSpellRange 16
	}
	elseif ${Me.Ability[${SpellType[8]}].IsReady}
	{
		call CastSpellRange 8 0 0 0 ${healtarget}
	}
	else
	{
		;Death Save
		call CastSpellRange 316 0 0 0 ${healtarget}
	}
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead} || !${Me.Group[${gMember}].IsAfflicted} || ${Me.Group[${gMember}].ToActor.Distance}>${Me.Ability[${SpellType[210]}].Range}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<6 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 2
		}
	}
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{
	if ${Me.Ability[${SpellType[392]}].IsReady}
		call CastSpellRange 393 0 0 0 ${KillTarget}
}

function MA_Dead()
{
	if ${Actor[ExactName,PC,${MainTankPC}].IsDead} && ${Actor[ExactName,PC,${MainTankPC}](exists)} && ${CombatRez}
		call 300 301 1 1 ${Actor[ExactName,PC,${MainTankPC}].ID} 1
}

function CheckReactives()
{
	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]

	if ${KeepReactiveUp} || ${KeepGroupReactiveUp} || ${PreHealMode}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID}==${Actor[pc,exactname,${MainTankPC}].ID}
			{
				;echo Single react is Present on MT
				hot1:Set[1]
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group react is Present
				grphot:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${KeepReactiveUp} || ${PreHealMode}
		{
			if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				call CastSpellRange 7 0 0 0 ${Actor[pc,exactname,${MainTankPC}].ID}
				hot1:Set[1]
			}
		}

		if ${KeepGroupReactiveUp} || ${PreHealMode}
		{
			if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
				call CastSpellRange 15
		}
		if !${Me.Maintained[${SpellType[2]}](exists)}
			call CastSpellRange 2
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}