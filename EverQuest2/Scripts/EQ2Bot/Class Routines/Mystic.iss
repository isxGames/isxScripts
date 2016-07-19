;*************************************************************
;Mystic.iss 20070725a
;version
;
;20070725a
; Minor AA weapon change tweaks
;
;20070503a (LostOne)
;Defiler Orginal by karye & updated by pygar
;ported to Mystic by LostOne

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20080408
	;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare CureMode bool script 0
	declare CureCurseSelfMode bool script 0
	declare CureCurseOthersMode bool script 0
	declare OberonMode bool script 0
	declare TorporMode bool script 0
	declare KeepWardUp bool script 0
	declare KeepMTWardUp bool script 0
	declare KeepGroupWardUp bool script 1
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare MeleeMode bool script 1
	
	declare BuffNoxious bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffStrength bool script FALSE
	declare BuffWaterBreathing bool script FALSE
	declare BuffProcGroupMember string script
	declare BuffAvatarGroupMember string script
	declare BuffAncestryGroupMember string script
	declare BuffImmunities bool script TRUE
	declare BuffCoagulate bool script TRUE
	declare CureCurseGroupMember string script

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	CureCurseSelfMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseSelfMode,FALSE]}]
	CureCurseOthersMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseOthersMode,FALSE]}]
	OberonMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Oberon Mode,FALSE]}]
	TorporMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Torpor Mode,FALSE]}]
	KeepWardUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepWardUp,FALSE]}]
	KeepMTWardUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepMTWardUp,FALSE]}]
	KeepGroupWardUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepGroupWardUp,TRUE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	CombatRez:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Rez,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	MeleeMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MeleeMode,FALSE]}]

	BuffNoxious:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffNoxious,TRUE]}]
	BuffMitigation:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMitigation,TRUE]}]
	BuffStrength:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffStrength,TRUE]}]
	BuffImmunities:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffImmunities,TRUE]}]
	BuffCoagulate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffCoagulate,TRUE]}]
	BuffWaterBreathing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffWaterBreathing,FALSE]}]
	BuffProcGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProcGroupMember,]}]
	BuffAvatarGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAvatarGroupMember,]}]
	BuffAncestryGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAncestryGroupMember,]}]
	CureCurseGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[CureCurseGroupMember,]}]
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
		call CheckWards
		call CheckHeals

		if ${Me.Power}>85 && ${KeepWardUp}
		{
			call CastSpellRange 15
			call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		;; This has to be set within any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{

	PreAction[1]:Set[BuffPower]
	PreSpellRange[1,1]:Set[20]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[BuffNoxious]
	PreSpellRange[3,1]:Set[31]

	PreAction[4]:Set[BuffAvatar]
	PreSpellRange[4,1]:Set[22]

	PreAction[5]:Set[BuffMitigation]
	PreSpellRange[5,1]:Set[30]

	PreAction[6]:Set[BuffStrength]
	PreSpellRange[6,1]:Set[32]

	PreAction[7]:Set[BuffWaterBreathing]
	PreSpellRange[7,1]:Set[33]

	PreAction[8]:Set[SpiritCompanion]
	PreSpellRange[8,1]:Set[360]

	PreAction[9]:Set[AA_AuraOfHaste]
	PreSpellRange[9,1]:Set[362]

	PreAction[10]:Set[AA_AuraOfWarding]
	PreSpellRange[10,1]:Set[363]

	PreAction[11]:Set[AA_Immunities]
	PreSpellRange[11,1]:Set[375]

	PreAction[12]:Set[AA_Coagulate]
	PreSpellRange[12,1]:Set[368]

	PreAction[13]:Set[BuffAncestry]
	PreSpellRange[13,1]:Set[378]

}

function Combat_Init()
{
	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[90]
	SpellRange[1,1]:Set[383]

	Action[2]:Set[Mastery]
	SpellRange[2,1]:Set[304]

	Action[3]:Set[AARabies]
	SpellRange[3,1]:Set[352]

	Action[4]:Set[Fever]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[1]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[82]
	SpellRange[4,2]:Set[382]

	Action[5]:Set[ChillingWinds]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[60]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[80]
	SpellRange[5,2]:Set[381]

	Action[6]:Set[AA_Phalanx]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	SpellRange[6,1]:Set[365]

	Action[7]:Set[UmbralTrap]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[54]

	Action[8]:Set[AA_CripplingBash]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[366]

	Action[9]:Set[Cold_Flame]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[1]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[81]

	Action[10]:Set[ThermalShocker]

	Action[11]:Set[Slothful_Spirit]
	Power[11,1]:Set[1]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[83]
	
	Action[12]:Set[Debuff_Strength]
	SpellRange[12,1]:Set[51]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]

	PostAction[2]:Set[LoadDefaultEquipment]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	variable int temp
	
	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
		if (${Me.GroupCount} > 1)
		{
			call CastSpellRange 313
			InitialBuffsDone:Set[TRUE]
	  }
	}

	if ${ShardMode}
		call Shard

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
					;continue of pc is out of your group
					if ${BuffTarget.Token[2,:].Equal[PC]} && !${Me.Group[${Actor[id,${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}].Name}](exists)}
						continue

					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case SpiritCompanion
			if ${PetMode} && !${Me.InCombat}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Self_Buff
		case AA_WeaponMastery
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_Coagulate
		if ${BuffCoagulate}
			call CastSpellRange ${PreSpellRange[${xAction},1]}
		else
			Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
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
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffWaterBreathing
			if ${BuffWaterBreathing}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffAvatar
			BuffTarget:Set[${UIElement[cbBuffAvatarGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				;break of pc is out of your group
				if ${BuffTarget.Token[2,:].Equal[PC]} && !${Me.Group[${Actor[id,${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}].Name}](exists)}
					break

				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case BuffAncestry
			BuffTarget:Set[${UIElement[cbBuffAncestryGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				;break of pc is out of your group
				if ${BuffTarget.Token[2,:].Equal[PC]} && !${Me.Group[${Actor[id,${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}].Name}](exists)}
					break

				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Resurrection
			temp:Set[1]
			do
			{
				if ${Me.Group[${temp}].Health}==-99 && ${Me.Group[${temp}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 1 0 ${Me.Group[${temp}].ID} 1
			}
			while ${temp:Inc}<${Me.GroupCount}
			break
		case AA_Immunities
			if ${BuffImmunities}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AA_AuraOfHaste
			if !${Me.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_SpiritualForesight
		case AA_RitualOfAbsolution
		case AA_AuraOfWarding
			if ${Me.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare spellsused int local

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	call CheckGroupHealth 60
	if ${DoHOs} && ${Return}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	call PetAttack
	call CheckWards
	call CheckHeals
	call RefreshPower

	;bolster MT
	if !${Me.Maintained[${SpellType[21]}](exists)} && ${Me.Ability[${SpellType[21]}].IsReady}
		call CastSpellRange 21 0 0 0 ${Actor[${MainTankPC}].ID} 1
		
		;Cast Alacrity if available
	if ${Me.Ability[${SpellType[372]}].IsReady}
	{
		BuffTarget:Set[${UIElement[cbBuffAlacrityGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

		if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			call CastSpellRange 398 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
	}

	;keep Leg Bite up at all times if we have a pet
	if ${Me.Maintained[${SpellType[360]}](exists)}
		call CastSpellRange 360

	if ${OberonMode}
	{
		call CheckGroupHealth 60

		if !${Return} && ${Me.Maintained[${SpellType[317]}](exists)}
			Me.Maintained[${SpellType[317]}]:Cancel
	}
	elseif ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

	call CheckGroupHealth 60
	if ${Return} && ${DebuffMode}
	{
		;enfeeble
		if ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)}
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;haze
		if ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[53]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;mourning soul
		if ${Me.Ability[${SpellType[53]}].IsReady} && !${Me.Maintained[${SpellType[53]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 53 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;lethargy
		if ${Me.Ability[${SpellType[55]}].IsReady} && !${Me.Maintained[${SpellType[55]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 55 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;umbral trap
		if ${Me.Ability[${SpellType[54]}].IsReady} && !${Me.Maintained[${SpellType[54]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 54 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	switch ${Action[${xAction}]}
	{
		case Slothful_Spirit *need combat
		case AA_CripplingBash
			;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
			if ${MeleeMode} && ${Me.Maintained[${SpellType[360]}](exists)}
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
		case Fever
		case ChillingWinds
		case Cold_Flame
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{      
						if ${MeleeMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
							call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget}
						else
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
			}
			break
			
		case Debuff_Strength
			if ${Me.Ability[${SpellType[xAction]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case AARabies
			if ${AoEMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
			
		case Mastery
		;;;; Master Strike
		if ${Me.Ability[Master's Strike].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			Target ${KillTarget}
			Me.Ability[Master's Strike]:Use
		}	
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

function Post_Combat_Routine(int xAction)
{
	declare tempgrp int 1
	;Turn off Oberon so we can move
	if ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

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
				if ${Me.Group[${tempgrp}].Health}==-99
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
			}
			while ${tempgrp:Inc} <= ${Me.GroupCount}
			break
		case LoadDefaultEquipment
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
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if !${MainTank}
	{
		;Try AE mez hate reduction
		call CastSpellRange 180
	}



}
function RefreshPower()
{

	call Shard 60

}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0
	declare MTinMyGroup bool local FALSE

	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	;Cancel Oberon if up and tank dieing
	if ${Me.Maintained[${SpellType[317]}](exists)} && (${Actor[${MainTankPC}].Health}<30 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}) && ${Me.Power} >20 || !${OberonMode}
		Me.Maintained[${SpellType[317]}]:Cancel

	;Res the MT if they are dead
	if ${Actor[PC,${MainTankPC}].Health}==-99 && ${Actor[PC,${MainTankPC}](exists)} && ${CombatRez}
		call CastSpellRange 300 0 0 0 ${Actor[${MainTankPC}].ID}

	do
	{
		if ${Me.Group[${temphl}](exists)}
		{

			if ${Me.Group[${temphl}].Health}==-99 && !${Me.InCombat}
				call CastSpellRange 300 301 1 0 ${Me.Group[${temphl}].ID} 1

			if ${Me.Group[${temphl}].Health}<100 && ${Me.Group[${temphl}].Health}>-99
			{
				if ${Me.Group[${temphl}].Health}<=${Me.Group[${lowest}].Health}
					lowest:Set[${temphl}]
			}

			if ${Me.Group[${temphl}].IsAfflicted}
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

			if ${Me.Group[${temphl}].Health}>-99 && ${Me.Group[${temphl}].Health}<80
				grpheal:Inc

			if ${Me.Group[${temphl}].Noxious}>0 || ${Me.Group[${temphl}].Trauma}>0
				grpcure:Inc

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].Pet.Health}<60 && ${Me.Group[${temphl}].Pet.Health}>0
					PetToHeal:Set[${Me.Group[${temphl}].Pet.ID}
			}

			if ${Me.Pet.Health}<60
				PetToHeal:Set[${Me.Pet.ID}]

			if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
				MTinMyGroup:Set[TRUE]
		}
	}
	while ${temphl:Inc} <= ${Me.GroupCount}

	if ${Me.Health}<80 && ${Me.Health}>-99
		grpheal:Inc

	if ${Me.Noxious}>0 || ${Me.Trauma}>0
		grpcure:Inc

	;CURES
	
	declare CureTarget string local
	
	
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0
	
	; Check if curse curing on others is enabled it if is find out who we are to cure and do it.
	if ${CureCurseOthersEnabled}
	{
		CureTarget:Set[${CureCurseGroupMember}]

		if  !${Me.Raid} > 0 
			{
				if ${Me.Group[${CureTarget.Token[1,:]}].Cursed}
				{
					call CastSpellRange 211 0 0 0 ${Me.Group[${CureTarget.Token[1,:]}].ID} 0 0 0 0 1 0
				}
			}
			else
			{
					if ${Me.Raid[${CureTarget.Token[1,:]}].Cursed}
				{
					call CastSpellRange 211 0 0 0 ${Me.Raid[${CureTarget.Token[1,:]}].ID} 0 0 0 0 1 0
				}
			}
	}
	
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 220
		;fire off group noxious ward
		call CastSpellRange 17
	}

	if ${Me.IsAfflicted} && ${CureMode}
		call CureMe

	call CheckGroupHealth 30
	if ${mostafflicted} && ${CureMode} && ${Return}
		call CureGroupMember ${mostafflicted}

	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].Health}>-99 && ${Me.Group[${lowest}](exists)}
		call EmergencyHeal ${Actor[${MainTankPC}].ID}

	;ME HEALS
	if ${Me.Health}<=${Me.Group[${lowest}].Health} && ${Me.Group[${lowest}](exists)}
	{
		if ${Me.Health}<85
		{
			if ${haveaggro} && ${Me.InCombatMode}
				call CastSpellRange 7 0 0 0 ${Me.ID}
			else
				call CastSpellRange 4 0 0 0 ${Me.ID}
		}

		if ${Me.Health}<25
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
	}

	;MAINTANK HEALS
	if ${Actor[${MainTankPC}].Health} <90 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99
	{
		if !${KeepMTWardUp}
			call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}

		if !${KeepGroupWardUp} && ${MTinMyGroup}
			call CastSpellRange 15

		if ${OberonMode} && ${MTinMyGroup} && ${Me.Ability[${SpellType[317]}].IsReady} && ${Actor[${MainTankPC}].ID}!=${Me.ID} && ${Me.Power}<40
			call CastSpellRange 317 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	if ${Actor[${MainTankPC}].Health} <90 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)}
		call CastSpellRange 1 0 0 0 ${Actor[${MainTankPC}].ID}

	if ${Actor[${MainTankPC}].Health} <60 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${KillTarget}].IsEpic} && ${TorporMode}
		call CastSpellRange 8 0 0 0 ${Actor[${MainTankPC}].ID}

	;GROUP HEALS
	if ${grpheal}>=2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
			call CastSpellRange 10
		elseif ${Me.Ability[${SpellType[15]}].IsReady} && !${KeepGroupWardUp}
			call CastSpellRange 15

		; Cast shadowy attendant
		if ${PetMode}
			call CastSpellRange 16
	}

	if ${Me.Group[${lowest}].Health}<80 && ${Me.Group[${lowest}].Health}>-99 && ${Me.Group[${lowest}](exists)}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ID}
		else
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ID}
		hurt:Set[TRUE]
	}

	if ${Me.Group[${lowest}].Health}<60 && ${Me.Group[${lowest}].Health}>-99 && ${Me.Group[${lowest}](exists)} && ${TorporMode}
		call CastSpellRange 8 0 0 0 ${Me.Group[${lowest}].ID}

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)}
	{
		if ${Actor[${PetToHeal}].InCombatMode}
			call CastSpellRange 7 0 0 0 ${PetToHeal}
		else
			call CastSpellRange 1 0 0 0 ${PetToHeal}
	}

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		tempgrp:Set[1]
		do
		{
			if ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].IsDead} && ${Me.Group[${tempgrp}].Distance}<=20
			{
				if !${Me.InCombat} && ${Me.Ability[${SpellType[500]}].IsReady}
					call CastSpellRange 500 0 0 0 ${Me.Group[${tempgrp}].ID} 1 0 0 0 2 0
				else
					call CastSpellRange 300 301 1 0 ${Me.Group[${tempgrp}].ID} 1 0 0 0 2 0
			}
		}
		while ${tempgrp:Inc} <= ${Me.GroupCount}
	}

}

function CheckWards()
{

	;===============================================;
	;First off, lets make sure the MT has a ward on	;
	;Loop through maintained spells, find a ward	;
	;===============================================;
	declare tempvar int local 1
	declare ward1 int local 0
	declare grpward int local 0
	ward1:Set[0]
	grpward:Set[0]
	if ${Me.InCombat} || ${Actor[exactname,${MainTankPC}].InCombatMode}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]}&&${Me.Maintained[${tempvar}].Target.ID}==${Actor[${MainTankPC}].ID}
			{
				;===============================================;
				;Set the var Ward1 if ward is still present	;
				;===============================================;
				;echo Ward is present.
				ward1:Set[1]
				break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group ward Present
				grpward:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${KeepMTWardUp}
		{
			if ${ward1}==0&&${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
				ward1:Set[1]
			}
		}

		if ${KeepGroupWardUp}
		{
			if ${grpward}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
				call CastSpellRange 15
		}

		;=======================================================================;
		;  Next, See if ward2 needs to be used (Long recast, emergency ward     ;
		;=======================================================================;
		if ${Actor[${MainTankPC}].Health}<30
			call CastSpellRange 8 0 0 0 ${Actor[${MainTankPC}].ID}
	}
}

function EmergencyHeal(int healtarget)
{

	;Use Eidolic Savior (single target group only)
	if ${Me.Ability[${SpellType[338]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
		call CastSpellRange 338 0 0 0 ${healtarget}

	;Use Eidolic Ward if ready else use Wards of the Eidolon
	if ${Me.Ability[${SpellType[335]}].IsReady}
		call CastSpellRange 335 0 0 0 ${healtarget}
	elseif ${Me.Ability[${SpellType[334]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
		call CastSpellRange 334 0 0 0 ${healtarget}
		
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

}

function CheckHealerMob()
{
	declare tcount int local 2

	EQ2:CreateCustomActorArray[byDist,15]
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]}
		{
			switch ${CustomActor[${tcount}].Class}
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
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

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
	variable int MainTankID
	MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]

  	if (${Actor[${MainTankID}](exists)} && ${CombatRez})
  	{
    	if (${Actor[${MainTankID}].IsDead})
			call CastSpellRange 300 301 1 0 ${MainTankID} 1
	}
}

function CureMe()
{
	
	; Check to see if Healer needs cured of the curse and cure it first.
	if ${Me.Cursed} && ${CureCurseSelfMode}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0
	
	if ${Me.Arcane}>0
	{
		call CastSpellRange 326

		if ${Me.Arcane}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID}
			return
		}
	}

	if  ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		return
	}
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local

	if (${gMember} == 0)
	{
			call CureMe
			return
	}


	tmpcure:Set[0]
	if !${Me.Group[${gMember}](exists)}
		return

	do
	{
		;first use Ancient Balm if up (single target cure all)
		call CastSpellRange 214 0 0 0 ${Me.Group[${gMember}].ID}

		if  ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3 && ${Me.Group[${gMember}](exists)}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}