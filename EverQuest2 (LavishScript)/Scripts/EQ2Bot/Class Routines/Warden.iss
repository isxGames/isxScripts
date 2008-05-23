;*************************************************************
;Warden.iss
;version 20070725a
; by Pygar
;
;20070725a
; Updates for AA weapon requirement changes
;
;20070514a
; Fixed a rez loop issue
; optomized me heals
; will cancel Genesis and Duststorm after fight or when needed.
;
;20070503a
; Fized Combat Rez check to all rezes
; Added toggle for Pet usage
; Fixed Heal routine for Maintankpc
; Tweaked heal routine heavily
;	Added group heal check to cure loop
; Added epic check to root and snare calls
; Added support for Nature Walk AA ability
;	Fixed numerous spellkey issues
;
;20070201a
;Combat Rez is now a toggle
;Initiating HO's is now a toggle
;Added KoS and EoF AA line
;Added support for combat CA line
;Tweaked DPS
;Upgraded for EQ2Bot 2.5.2
;
;
;20061130a
; Fixed some spellKey and buffing bugs
; Also removed from debugging that was still active.
; Also fixed rezing loop
;
; 20071222a
; Improved Cure Routine
; Improvied Heal Routine
; Added Genesis Support
; Fixed Offensive mode toggles to preserver power for heals
; Added SoW
; Fixed Curing uncurable effects
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20080408
  ;;;;

	declare OffenseMode bool script
	declare AoEMode bool script
	declare CureMode bool script
	declare GenesisMode bool script
	declare InfusionMode bool script
	declare KeepReactiveUp bool script
	declare UseCAs bool script 1
	declare MeleeMode bool script 1
	declare BuffThorns bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare PetMode bool script 1
	declare KeepMTHOTUp bool script 0
	declare KeepGroupHOTUp bool script 0
	declare RaidHealMode bool script 1
  declare ShiftForm int script 1

	declare BuffBatGroupMember string script
	declare BuffInstinctGroupMember string script
	declare BuffSporesGroupMember string script
	declare BuffVigorGroupMember string script
	declare BuffBoon string script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	GenesisMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Genesis,FALSE]}]
	InfusionMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[InfusionMode,FALSE]}]
	KeepReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepReactiveUp,FALSE]}]
	UseCAs:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseCAs,FALSE]}]
	MeleeMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Melee,FALSE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	BuffThorns:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Thorns,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]
	KeepMTHOTUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepMTHOTUp,FALSE]}]
	KeepGroupHOTUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepGroupHOTUp,FALSE]}]
	RaidHealMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Raid Heals,TRUE]}]
	ShiftForm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[ShiftForm,]}]

	BuffBatGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBatGroupMember,]}]
	BuffInstinctGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffInstinctGroupMember,]}]
	BuffSporesGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSporesGroupMember,]}]
	BuffVigorGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffVigorGroupMember,]}]
	BuffBoon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBoon,FALSE]}]

}

function Buff_Init()
{
	PreAction[1]:Set[BuffThorns]
	PreSpellRange[1,1]:Set[40]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[394]

	PreAction[3]:Set[BuffBoon]
	PreSpellRange[3,1]:Set[280]

	PreAction[4]:Set[BuffVigor]
	PreSpellRange[4,1]:Set[36]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[20]
	PreSpellRange[5,2]:Set[21]
	PreSpellRange[5,3]:Set[23]

	PreAction[6]:Set[SOW]
	PreSpellRange[6,1]:Set[31]

	PreAction[7]:Set[BuffBat]
	PreSpellRange[7,1]:Set[35]

	PreAction[8]:Set[BuffInstinct]
	PreSpellRange[8,1]:Set[38]

	PreAction[9]:Set[BuffSpores]
	PreSpellRange[9,1]:Set[37]

	PreAction[10]:Set[AA_Rebirth]
	PreSpellRange[10,1]:Set[380]

	PreAction[11]:Set[AA_Infusion]
	PreSpellRange[11,1]:Set[391]

	PreAction[12]:Set[AA_Force_of_Nature]
	PreSpellRange[12,1]:Set[393]

	PreAction[13]:Set[AA_Nature_Walk]
	PreSpellRange[13,1]:Set[392]

	PreAction[14]:Set[AA_Shapeshift]
	PreSpellRange[14,1]:Set[396]
	PreSpellRange[14,2]:Set[397]
	PreSpellRange[14,3]:Set[398]
}

function Combat_Init()
{
	Action[1]:Set[Nuke1]
	MobHealth[1,1]:Set[1]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[60]


	Action[2]:Set[Nuke2]
	MobHealth[2,1]:Set[1]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[30]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[61]

	Action[3]:Set[Mastery]

	Action[4]:Set[AoE]
	MobHealth[4,1]:Set[11]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[40]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[90]

	Action[5]:Set[DoT]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[30]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[70]

	Action[6]:Set[Grove]
	MobHealth[6,1]:Set[50]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[30]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[330]

	Action[7]:Set[Ally]
	MobHealth[7,1]:Set[50]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[30]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[329]

	Action[8]:Set[AA_Thunderspike]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[40]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[383]

	Action[9]:Set[AA_Nature_Blade]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[40]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[381]

	Action[10]:Set[AA_Primordial_Strike]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[40]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[382]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	variable int temp

	if ${Groupwiped}
	{
		Call HandleGroupWiped
		Groupwiped:Set[False]
	}

	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
		if (${Me.GroupCount} > 1)
			call CastSpell "Favor of the Phoenix"
		InitialBuffsDone:Set[TRUE]
	}

	ExecuteAtom CheckStuck

	if ${ShardMode}
		call Shard

	if ${xAction}==1
		call CheckHeals

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
    ExecuteAtom AutoFollowTank
		wait 5
	}

	if ${Me.ToActor.Power}>85
		call CheckHOTs

	switch ${PreAction[${xAction}]}
	{
		case BuffThorns
			if ${MainTank} || (${BuffThorns} && ${Actor[exactname,${MainTankPC}](exists)})
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankPC}].ID}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			call CastSpellRange ${PreSpellRange[${xAction},2]}
			break
		case AA_Shapeshift
			call CastSpellRange ${PreSpellRange[${xAction},${ShiftForm}]}
			break
		case BuffBoon
			if ${BuffBoon}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffVigor
			BuffTarget:Set[${UIElement[cbBuffVigorGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Group[${Actor[exactname,${BuffTarget.Token[1,:]}].Name}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}

			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]} 0 0
			break
		case SOW
			;Me:InitializeEffects
			;if ${Me.ToActor.NumEffects}<15 && !${Me.Effect[Spirit of the Wolf](exists)}
			;{
			;	call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			;	wait 40
			;	;buff the group
			;	tempvar:Set[1]
			;	do
			;	{
			;		if ${Me.Group[${tempvar}].ToActor.Distance}<15
			;		{
			;			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
			;			wait 40
			;		}
			;	}
			;	while ${tempvar:Inc}<${Me.GroupCount} && !${Me.InCombat}
			;}
			break
		case BuffBat
			BuffTarget:Set[${UIElement[cbBuffBatGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case BuffInstinct
			BuffTarget:Set[${UIElement[cbBuffInstinctGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Actor[exactname,${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case BuffSpores
			BuffTarget:Set[${UIElement[cbBuffSporesGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Actor[exactname,${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case AA_Infusion
			if !${InfusionMode}
				break
		case AA_Nature_Walk
		case AA_Force_of_Nature
		case AA_Rebirth
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}

			break
		Default
			Return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare counter int local 1

	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		wait 5
	}


	if ${CureMode}
		call CheckCures

	call CheckHeals


	if ${DoHOs} && ${OffenseMode}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 305
	}

	call RefreshPower

	if ${ShardMode}
		call Shard

	if ${UseCAs} && ${Target.Distance}>4
	{
		call CheckPosition 1 ${Target.IsEpic}
		if !${Me.AutoAttackOn}
		{
			EQ2Execute /toggleautoattack
		}
	}

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 75
	if ${Return}
	{
		;echo Offensive - ${OffenseMode}
		switch ${Action[${xAction}]}
		{
			case Nuke1
			case Nuke2
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${UseCAs}
								call CastSpellRange 385 386 1 0 ${KillTarget}
							else
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break
			case AoE
				if ${OffenseMode} && ${AoEMode} && ${Mob.Count}>=2
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${UseCAs}
								call CastSpellRange 389 0 1 0 ${KillTarget} 0 0 1
							else
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}

				}
				break
			case AA_Thunderspike
			case AA_Primordial_Strike
			case AA_Nature_Blade
				if !${MeleeMode}
					return CombatComplete

				if ${OffenseMode} && ${MeleeMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
							}
						}
					}
				}
				break
			case DoT
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${UseCAs}
								call CastSpellRange 387 0 1 0 ${KillTarget} 0 0 1
							else
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break

			case Ally
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && ${OffenseMode}  && ${PetMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break

			case Grove
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && ${PetMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break

			case Mastery
				if ${OffenseMode} || ${DebuffMode}
				{
					;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
					;;;;;;;;;;
					if (${InvalidMasteryTargets.Element[${Target.ID}](exists)})
							break
					;;;;;;;;;;;
					if ${Me.Ability[Master's Smite].IsReady}
					{
						Target ${KillTarget}
						Me.Ability[Master's Smite]:Use
					}
				}
				break

			Default
				return CombatComplete
				break
		}
	}
	call CheckHOTs
}

function Post_Combat_Routine(int xAction)
{

	TellTank:Set[FALSE]

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	;cancel Genesis if up
	if ${Me.Maintained[${SpellType[9]}](exists)}
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}

	;cancel Duststorm if up
	if ${Me.Maintained[${SpellType[365]}](exists)}
	{
		Me.Maintained[${SpellType[365]}]:Cancel
	}


	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.IsDead}
				{
					call CastSpellRange 300 303 0 0 ${Me.Group[${tempgrp}].ID} 1
					wait 5
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function RefreshPower()
{

	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
	{
		call UseItem "Helm of the Scaleborn"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

}

function Have_Aggro(int aggroid)
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	call CastSpellRange 180 0 0 0 ${aggroid}
}

function CheckHeals()
{
	declare tempgrp int local 1
	declare temphl int local 1
	declare temph2 int local 1
	declare grpheal int local 0
	declare lowest int local 0
	declare raidlowest int local 1
	declare PetToHeal int local 0
	declare MainTankID int local 0
	declare MainTankInGroup bool local 0

	MainTankID:Set[${Actor[pc,ExactName,${MainTankPC}].ID}]
	grpcnt:Set[${Me.GroupCount}]

	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Res the MT if they are dead
	if (!${Me.ToActor.InCombatMode} || ${CombatRez}) && ${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call CastSpellRange 300 0 1 1 ${MainTankID}

	call CheckHOTs

	if ${EpicMode} && ${Me.InCombat} && ${PetMode}
		call CastSpellRange 330 331 0 0 ${KillTarget}


	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{
			if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<${Me.Group[${lowest}].ToActor.Health} || ${lowest}==0
					lowest:Set[${temphl}]
			}

			if ${Me.Group[${temphl}].ID}==${MainTankID}
				MainTankInGroup:Set[1]

			if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80
				grpheal:Inc

			if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}

			if ${Me.ToActor.Pet.Health}<60
				PetToHeal:Set[${Me.ToActor.Pet.ID}]
		}
	}
	while ${temphl:Inc}<=${grpcnt}

	if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
		grpheal:Inc

	if ${grpheal}>2
		call GroupHeal

	if ${Actor[${MainTankID}].Health}<90
	{
		if ${Me.ID}==${MainTankID}
			call HealMe
		else
			call HealMT ${MainTankID} ${MainTankInGroup}
	}


	;Check My health after MT
	if ${Me.ID}!=${MainTankID} && ${Me.ToActor.Health}<80
		call HealMe

	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)}
		{
			if ${Me.Ability[${SpellType[7]}].IsReady}
				call CastSpellRange 7 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			else
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
	}



	;RAID HEALS - Only check if in raid, raid heal mode on, maintank is green, I'm above 50, and a direct heal is available.  Otherwise don't waste time.
	if ${RaidHealMode} && ${Me.InRaid} && ${Me.ToActor.Health}>50 && ${Actor[${MainTankID}].Health}>70 && (${Me.Ability[${SpellType[4]}].IsReady} || ${Me.Ability[${SpellType[1]}].IsReady})
	{
		do
		{
			if ${Actor[pc,exactname,${Me.Raid[${temph2}].Name}](exists)}
			{
				if !${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].Name.Equal[${Me.Name}]} && !${Me.Group[${Actor[pc,exactname,${Me.Raid[${temph2}].Name}]}].ID(exists)}
				{
					if ${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].Health} < 100 && !${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].IsDead} && ${Me.Raid[${temph2}](exists)}
					{
						if ${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].Health} < ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].Health}
							raidlowest:Set[${temph2}]
					}
				}
			}
		}
		while ${temph2:Inc}<=24

		if ${Me.InCombat} && ${Actor[exactname,${Me.Raid[${raidlowest}].Name}](exists)} && ${Actor[exactname,${Me.Raid[${raidlowest}].Name}].Health} < 60 && !${Actor[exactname,${Me.Raid[${temph2}].Name}].IsDead}
		{
			;echo Raid Lowest: ${Me.Raid[${raidlowest}].Name} -> ${Actor[exactname,${Me.Raid[${raidlowest}].Name}].Health} health
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
		}
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[ExactName,${PetToHeal}](exists)} && ${Actor[ExactName,${PetToHeal}].InCombatMode} && !${EpicMode} && !${Me.InRaid}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	if ${EpicMode}
		call CheckCures

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		grpcnt:Set[${Me.GroupCount}]
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.IsDead}
				call CastSpellRange 300 303 0 0 ${Me.Group[${temphl}].ID} 1
		}
		while ${temphl:Inc}<${grpcnt}
	}
}

function HealMe()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<75
		call CastSpellRange 331

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID} 1
		else
		{
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.ID}
			else
				call CastSpellRange 1 0 0 0 ${Me.ID}
		}
	}

	if ${Me.ToActor.Health}<60
	{
		if ${haveaggro} && ${Me.ToActor.InCombatMode}
			call CastSpellRange 7 0 0 0 ${Me.ID}
		else
			call CastSpellRange 1 0 0 0 ${Me.ID}
	}

	if ${Me.ToActor.Health}<40
		call CastSpellRange 4 0 0 0 ${Me.ID}
}

function HealMT(int MainTankID, int MTInMyGroup)
{
	;cancel Genesis if up and tank dieing
	if ${Me.Maintained[${SpellType[9]}](exists)} && (${Actor[${MainTankPC}].Health}<30 && !${Actor[${MainTankPC}].IsDead} && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}) || (!${GenesisMode} && ${Me.ToActor.Power}>10)
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}
	elseif ${Me.Maintained[${SpellType[9]}](exists)} && ${GenesisMode}
	{
		return
	}

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call EmergencyHeal ${MainTankID} ${MTInMyGroup}

	;cast genesis if needed
	if ${Me.Ability[${SpellType[9]}].IsReady} && ${Actor[${MainTankPC}](exists)} && ${MTinMyGroup} && ${Actor[${MainTankPC}].ID}!=${Me.ID} && ${Actor[${MainTankPC}].Health}<70 && !${Actor[${MainTankPC}].IsDead}
	{
		if ${Me.ToActor.Power}<10
		{
			call CastSpellRange 9 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		elseif ${GenesisMode} && ${Actor[${MainTankPC}].Health}<60
		{
			call CastSpellRange 9 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}

	if ${Actor[${MainTankID}].Health}<50 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)} && ${EpicMode}
	{
		call CastSpellRange 4 0 0 0 ${MainTankID}
	}

	;MAINTANK HEALS
	; Use regens first, then Patch Heals
	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)} && ${MTInMyGroup} && ${EpicMode}
		{
			call CastSpellRange 15
		}
		elseif ${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Maintained[${SpellType[7]}].Target.ID}==${Actor[${MainTankPC}].ID}
			call CastSpellRange 7 0 0 0 ${MainTankID}

		;we should check for other druid in raid here, but oh well.
		if ${Me.Ability[${SpellType[7]}].IsReady} && ${EpicMode} && !${Me.Maintained[${SpellType[7]}].Target.ID}==${Actor[${MainTankPC}].ID}
			call CastSpellRange 7 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<60 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
	{
		call CastSpellRange 1 0 0 0 ${MainTankID}
	}

}

function GroupHeal()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	else
		call CastSpellRange 15

	call CastSpellRange 331
	call CastSpellRange 330
}

function EmergencyHeal(int healtarget, int MTInMyGroup)
{
	;death prevention
	if ${Me.Ability[${SpellType[316]}].IsReady} && ${MTInMyGroup}
		call CastSpellRange 317 0 0 0 ${healtarget}
	else
		call CastSpellRange 316 0 0 0 ${healtarget}

	;emergency heals
	if ${Me.Ability[${SpellType[16]}].IsReady} && ${MTInMyGroup}
		call CastSpellRange 16 0 0 0 ${healtarget}
	else
		call CastSpellRange 8 0 0 0 ${healtarget}
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 2
		}
	}
}

function CureMe()
{
	declare CureCnt int local 0

	if !${Me.IsAfflicted}
		return

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	while (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0) && ${CureCnt:Inc}<5
	{
		if ${Me.Ability[${SpellType[214]}].IsReady}
		{
			call CastSpellRange 214 0 0 0 ${Me.ID}
			wait 2
		}

		if ${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID}
			wait 2
		}

		if ${Me.ToActor.Health}<30 && ${EpicMode}
			call CastSpellRange 7 0 0 0 ${Me.ID}
	}

}

function CheckCures()
{
	declare temphl int local 1
	declare grpcure int local 0

	grpcnt:Set[${Me.GroupCount}]

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount}>3
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Trauma}>0
				grpcure:Inc

			if ${Me.Elemental}>0
				grpcure:Inc
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<35
			{
				if ${Me.Group[${temphl}].Trauma}>0
					grpcure:Inc

				if ${Me.Group[${temphl}].Elemental}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc}<${grpcnt}

		;Use group cure if more than 3 afflictions will be removed
		if ${grpcure}>3
		{
			call CastSpellRange 220

			;would be better to time this 10s after casting group cure
			call CastSpellRange 399

			;would be better to time this 25s after casting group cure
			call CastSpellRange 363

		}

	}

	;Cure Ourselves first
	call CureMe

	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	do
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
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
				call HealMT ${MainTankID} ${MainTankInGroup}
		}

		;epicmode is set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

	}
	while ${Me.ToActor.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
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
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<35
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
	while ${temphl:Inc}<${grpcnt}

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CheckHOTs()
{

	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]

	if ((${Me.InCombat} || ${Actor[exactname,${MainTankPC}].InCombatMode}) && (${KeepMTHOTUp} || ${KeepGroupHOTUp})) || (${KeepReactiveUp} && ${Me.ToActor.Power}>85)
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID}==${Actor[exactname,${MainTankPC}].ID}
			{
				;echo Single HoT is Present on MT
				hot1:Set[1]
				break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group HoT is Present
				grphot:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if (${Me.InCombat} && ${KeepMTHOTUp}) || ${KeepReactiveUp}
		{
			if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				call CastSpellRange 7 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
				hot1:Set[1]
			}
		}

		if (${Me.InCombat} && ${KeepGroupHOTUp}) || ${KeepReactiveUp}
		{
			if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
				call CastSpellRange 15
		}
	}
}

function HandleGroupWiped()
{
		;;; There was a full group wipe and now we are rebuffing

		;assume that someone used a feather
		if (${Me.GroupCount} > 1)
		{
			Me.Ability[Favor of the Phoenix]:Use
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
			wait 1
		}

		return OK
}


function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	if ${Actor[${MainTankPC}].IsDead} && ${Actor[${MainTankPC}](exists)} && ${CombatRez} && ${Actor[${MainTankPC}].Distance}<30
		call CastSpellRange 303 0 1 0 ${MainTankPC} 1
}

function Cancel_Root()
{

}
