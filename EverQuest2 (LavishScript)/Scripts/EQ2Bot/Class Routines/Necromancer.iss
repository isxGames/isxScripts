;*************************************************************
;Necromancer.iss
;version 20070823a
;Initial Build
;by Pygar
;
;20070823a
; Dps tweaks, and spell list fixes.
;
;20070508a
;	Fixed undeclared var bug causing bot to lock up in stuck loop.
;
;20070504a
; Fixed ThermalShocker Use
; Added toggle for pet use
;
;20070226a
; Added Ruinous Heart to shard processing
; Bot responds to 'need heart' as well as 'need shard'
; Added Toggle for Lifeburn
;
;20070220a
; Fixed bug in cures
; Fixed a couple misc spell ID bugs in heals
; Verified it atleast runs
;
;20070219
; Casts Hearts on demand
; Uses Crystalized Shards
; Rezes Group AND Raid members
; Supports Ooze Pet
; Uses Lifeburn
; Full AA Support
; Toggle Cures
; Toggle Starting HO's
; Heals GroupMembers, GroupPets, and MainTank outside of group
; Intelegent Buff Selection
; Uses ThermalShocker if exists
; Uses FD and Cancels as needed
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20080408
  ;;;;

	declare PetType int script
	declare AoEMode bool script FALSE
	declare CureMode bool script FALSE
	declare StartHO bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffFavor bool script FALSE
	declare BuffLich bool script TRUE
	declare BuffMark bool script FALSE
	declare BuffCabalistCover bool script TRUE
	declare LifeburnMode bool script TRUE
	declare PetMode bool script TRUE
	declare DebuffMode bool script FALSE
	declare HealMode bool script TRUE

	declare ShardQueue queue:string script
	declare ShardRequestTimer int script ${Time.Timestamp}
	declare ShardType string script

	declare Undead_Army bool script TRUE
	declare Auto_Res bool script TRUE

	call EQ2BotLib_Init

	PetType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Pet Type,3]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	LifeburnMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Lifeburn,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cures,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffMark:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMark,FALSE]}]
	BuffFavor:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffFavor,FALSE]}]
	BuffLich:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffLich,TRUE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Debuffs,FALSE]}]
	HealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Heal Others,FALSE]}]
	Undead_Army:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Undead_Army, TRUE]}
	Auto_Res:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Auto Res, TRUE]}

	switch ${SpellType[360]}
	{
		case Dark Heart
			ShardType:Set["Dark Heart"]
			break
		case Default
			break
	}
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
		;check if we have a pet or a ooze not up
		if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[395]}](exists)} && ${PetMode}
		{
			call SummonPet
			waitframe
		}

		call RefreshPower
		call AnswerShardRequest
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[AA_Cabalists_Cover]
	PreSpellRange[1,1]:Set[393]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[Pet_Buff]
	PreSpellRange[3,1]:Set[45]
	PreSpellRange[3,2]:Set[46]

	PreAction[4]:Set[SeeInvis]
	PreSpellRange[4,1]:Set[30]

	PreAction[5]:Set[Buff_Shards]
	PreSpellRange[5,1]:Set[360]

	PreAction[6]:Set[Favor]
	PreSpellRange[6,1]:Set[20]

	PreAction[7]:Set[Mark]
	PreSpellRange[7,1]:Set[21]

	PreAction[8]:Set[Lich]
	PreSpellRange[8,1]:Set[27]
}

function Combat_Init()
{

	Action[1]:Set[UndeadTide]
	MobHealth[1,1]:Set[10]
	MobHealth[1,2]:Set[100]
	SpellRange[1,1]:Set[353]

	Action[2]:Set[Stench_Pet]
	MobHealth[2,1]:Set[30]
	MobHealth[2,2]:Set[100]
	SpellRange[2,1]:Set[329]

	Action[3]:Set[Rat_Pet]
	MobHealth[3,1]:Set[30]
	MobHealth[3,2]:Set[100]
	SpellRange[3,1]:Set[330]

	Action[4]:Set[Bat_Pet]
	MobHealth[4,1]:Set[30]
	MobHealth[4,2]:Set[100]
	SpellRange[4,1]:Set[331]

	Action[5]:Set[AA_Animated_Dagger]
	MobHealth[5,1]:Set[30]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[332]

	Action[6]:Set[Dot3]
	MobHealth[6,1]:Set[0]
	MobHealth[6,2]:Set[100]
	SpellRange[6,1]:Set[70]

	Action[7]:Set[AA_Magic_Leash]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[385]

	Action[8]:Set[Shockwave]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[380]

	Action[9]:Set[AA_Animist_Bond]
	MobHealth[9,1]:Set[50]
	MobHealth[9,2]:Set[100]
	SpellRange[9,1]:Set[371]

	Action[10]:Set[AoE]
	SpellRange[10,1]:Set[90]

	Action[11]:Set[Cloud]
	SpellRange[11,1]:Set[95]

	Action[12]:Set[Debuff1]
	SpellRange[12,1]:Set[50]

	Action[13]:Set[Debuff3]
	SpellRange[13,1]:Set[52]

	Action[14]:Set[Dot1]
	MobHealth[14,1]:Set[5]
	MobHealth[14,2]:Set[100]
	SpellRange[14,1]:Set[72]

	Action[15]:Set[Dot2]
	MobHealth[15,1]:Set[5]
	MobHealth[15,2]:Set[100]
	SpellRange[15,1]:Set[71]

	Action[16]:Set[Debuff2]
	SpellRange[16,1]:Set[51]

	Action[17]:Set[DrawingSouls]
	SpellRange[17,1]:Set[310]
	SpellRange[17,2]:Set[315]

	Action[18]:Set[AA_Lifeburn]
	SpellRange[18,1]:Set[375]

	Action[19]:Set[ThermalShocker]

	Action[20]:Set[Master_Strike]

}

function PostCombat_Init()
{
	PostAction[1]:Set[AA_Possessed_Minion]
	PostSpellRange[1,1]:Set[398]

	PostAction[2]:Set[LoadDefaultEquipment]

}

function Buff_Routine(int xAction)
{

	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	;check if we have a pet or a ooze not up
	if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[395]}](exists)} && ${PetMode}
	{
		call SummonPet
		waitframe
	}

	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
		if (${Me.GroupCount} > 1)
			call CastSpellRange 361
		InitialBuffsDone:Set[TRUE]
	}


	switch ${PreAction[${xAction}]}
	{
		case AA_Cabalists_Cover
			if ${BuffCabalistCover} && !${Me.Maintained[${SpellType[395]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				BuffCabalistCover:Set[FALSE]
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case Favor
			if ${BuffFavor}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Lich
			if ${BuffLich}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Mark
			if ${BuffMark}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break

		case Pet_Buff
			if ${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[395]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case SeeInvis
			if ${BuffSeeInvis}
			{
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ToActor.ID}

				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case Buff_Shards
			if !${Me.Inventory[${ShardType}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			break
		Default
			return BuffComplete
			break
	}
}

function Combat_Routine(int xAction)
{
	variable int Counter
	declare spellsused int local
	spellsused:Set[0]

	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${Me.ToActor.Pet(exists)}
		call PetAttack

	if ${Me.Ability[${SpellType[450]}].IsReady}
		Me.Ability[${SpellType[450]}]:Use

	;maintain dots if target is heroic, or greater
	if ${Actor[${KillTarget}].IsEpic} || (${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].IsNamed})
	{
		if ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)}
		{
			call CastSpellRange 70 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[60]}].IsReady}
		{
			call CastSpellRange 60 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[90]}].IsReady} && !${Me.Maintained[${SpellType[90]}](exists)} && ${Mob.Count}>1 && ${Target.EncounterSize}>1 && ${AoEMode} && ${spellsused}<3
		{
			call CastSpellRange 90 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[401]}].IsReady} && !${Me.Maintained[${SpellType[401]}](exists)} && ${spellsused}<3
		{
			call CastSpellRange 401 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)} && ${spellsused}<3
		{
			call CastSpellRange 71 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[329]}].IsReady} && !${Me.Maintained[${SpellType[329]}](exists)} && ${spellsused}<3
		{
			call CastSpellRange 329 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[330]}].IsReady} && !${Me.Maintained[${SpellType[330]}](exists)} && ${spellsused}<3
		{
			call CastSpellRange 330 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[331]}].IsReady} && !${Me.Maintained[${SpellType[331]}](exists)} && ${spellsused}<3
		{
			call CastSpellRange 331 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${Me.Ability[${SpellType[332]}].IsReady} && !${Me.Maintained[${SpellType[332]}](exists)} && ${spellsused}<3
		{
			call CastSpellRange 332 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	;pets

	call CommonHeals
	call CommonPower
	if ${UsePotions}
		call CheckCures

	;check if we have a pet or a ooze not up
	if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[395]}](exists)} && ${PetMode}
		call SummonPet

	call CheckHeals

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	call RefreshPower
	call AnswerShardRequest

	;Keep Consumption Up
	if ${Me.ToActor.Pet(exists)}
		call CastSpellRange 351

	;keep distracting strike up if we have a scout pet
	if ${Me.Maintained[${SpellType[355]}](exists)}
		call CastSpellRange 375

	;keep  Magic Leash up if we have a mage pet
	if ${Me.Maintained[${SpellType[356]}](exists)}
		call CastSpellRange 385

	switch ${Action[${xAction}]}
	{

		case AA_Animated_Dagger
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case Stench_Pet
			if ${AoEMode} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case Bat_Pet
		case Rat_Pet
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${PetMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case UndeadTide
			if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Me.ToActor.Pet(exists)} && ${PetMode} && ${Undead_Army}
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case AA_Lifeburn
			if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Me.ToActor.Pet(exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${LifeburnMode}
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case Cloud
			if ${PBAoEMode} && ${Mob.Count}>1
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			break
		case Shockwave
			if ${AoEMode} && ${Me.ToActor.Pet(exists)}  && ${Me.Maintained[${SpellType[357]}](exists)}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case AoE
			if ${AoEMode}
			{
				if ${Mob.Count}>1
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case DrawingSouls
			call CheckEssense
			if ${Return.Equal[STACKFOUND]}
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
		case Debuff1
		case Debuff2
		case Debuff3
			if ${DebuffMode}
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case Dot2
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && !${Actor[${KillTarget}].IsEpic} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Dot1
		case Dot3
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case AA_Magic_Leash
		case AA_Animist_Bond
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Master_Strike
			if ${Me.Ability[Master's Strike].IsReady} && ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
				Me.Ability[Master's Strike]:Use
			}
			break
		case ThermalShocker
			if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
			break
		Default
			return CombatComplete
			break
	}

}

function Post_Combat_Routine(int xAction)
{

	TellTank:Set[FALSE]

	switch ${PostAction[${xAction}]}
	{

		case LoadDefaultEquipment
			ExecuteAtom LoadEquipmentSet "Default"
			break
		case AA_Possessed_Minion
			;check if we are possessed minion and cancel
			if ${Me.Race.Equal[Unknown]}
				Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			break
		default
			return PostCombatRoutineComplete
			break
	}


}

function Have_Aggro(int aggroid)
{

	if ${Me.ToActor.InCombatMode} && (${Me.ToActor.Health}<70 || ${Actor[${aggroid}].IsEpic})
	{
		call CastSpellRange 349
		wait 10
	}

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if ${Actor[${aggroid}].Target.ID}==${Me.ID}
	{
		;Cast Fear
		call CastSpellRange 350 0 0 0 ${aggroid}
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

	if ${Me.ToActor.Pet.Health}>60 && ${Me.ToActor.Power}<70 && !${Me.ToActor.Pet.IsAggro}
		call CastSpellRange 326

	if ${Me.InCombat} && ${Me.ToActor.Power}<80 && ${Me.Health}>80 && !${Me.ToActor.Pet.IsAggro}
		call CastSpellRange 325

	;Necro Heart
	if ${Me.ToActor.Power}<80 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
		Me.Inventory[${ShardType}]:Use

	if ${Me.ToActor.Pet.Health}>50 && ${Me.ToActor.Power}<20
		call CastSpellRange 326

	if ${Me.InCombat} && ${Me.ToActor.Power}<45 && ${Me.Health}>20
		call CastSpellRange 325

	call Shard 60
}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0
	declare MTinMyGroup bool local FALSE
	declare tempraid int local 0

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]


	;cancel lich if FD
	if ${Me.Effect[Deathly Pallor](exists)}
	{
		Me.Maintained[${SpellType[27]}]:Cancel
	}


	;cancel FD when safe
	if ${Me.ToActor.Health}>60 && ${Me.Effect[Deathly Pallor](exists)}
	{
		Me.Effect[Deathly Pallor]:Cancel
	}

	;Res the MT if they are dead
	if ${Actor[${MainTankPC}].IsDead} && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].Distance}<25
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	if ${HealMode}
	{
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)}
			{

				if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
				{
					if ${Me.Group[${temphl}].ToActor.Health} < ${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${temphl}].ToActor.ID}!=${Me.ID}
					{
						lowest:Set[${temphl}]
					}
				}

				if ${Me.Group[${temphl}].IsAfflicted}
				{
					if ${Me.Group[${temphl}].Arcane}>0
					{
						tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]
					}

					if ${tmpafflictions}>${mostafflictions}
					{
						mostafflictions:Set[${tmpafflictions}]
						mostafflicted:Set[${temphl}]
					}
				}

				if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80
				{
					grpheal:Inc
				}

				if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
				{
					if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
					{
						PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
					}
				}

				if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
				{
					MTinMyGroup:Set[TRUE]
				}
			}

		}
		while ${temphl:Inc}<${grpcnt}
	}

	if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
	{
		grpheal:Inc
	}


	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}

	if ${mostafflicted} && ${CureMode}
	{
		call CureGroupMember ${mostafflicted}
	}


	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)} || ${Me.ID}==${Actor[${MainTankPC}].ID}
	{
		if ${Me.ToActor.Health}<75
		{
			if ${Me.Ability[${SpellType[60]}].IsReady} && ${Me.InCombat}
			{
				call CastSpellRange 60 0 0 0 ${Target.ID}
			}
			else
			{
				call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}

				if ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
				}
			}
		}
	}

	if ${HealMode}
	{
		;MAINTANK HEALS
		if ${Actor[${MainTankPC}].Health}<60 && !${Actor[${MainTankPC}].IsDead} && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
		{
				call CastSpellRange 4 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}

	;GROUP HEALS
	if ${grpheal}>2 && ${HealMode}
	{
		call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ID}!=${Me.ID} && ${HealMode}
	{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
	}

	;PET HEALS (other)
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)} && ${HealMode}
	{
		if ${Actor[${PetToHeal}].InCombatMode}
		{
			call CastSpellRange 4 0 0 0 ${PetToHeal}
		}
	}

	;Res Fallen Groupmembers only if in range
	grpcnt:Set[${Me.GroupCount}]
	tempgrp:Set[1]
	do
	{
		if ${Me.Group[${tempgrp}].ToActor.IsDead} && ${Me.Ability[${SpellType[300]}].IsReady} && ${Auto_Res} && ${Me.Group[${tempgrp}].ToActor.Distance}<25
		{
			call CastSpellRange 300 0 0 0 ${Me.Group[${tempgrp}].ID} 1
		}
	}
	while ${tempgrp:Inc}<${grpcnt} && ${Me.Ability[${SpellType[300]}].IsReady} && ${Auto_Res}

	if ${Me.InRaid} && ${Me.Ability[${SpellType[300]}].IsReady} && ${Auto_Res}
	{
		;Res Fallen RAID members only if in range
		grpcnt:Set[${Me.RaidCount}]
		tempraid:Set[1]
		do
		{
			if  ${Actor[pc,exactname,${RaidMember[${tempraid}].Name}].IsDead} && ${Me.Ability[${SpellType[300]}].IsReady} && ${Actor[pc,exactname,${RaidMember[${tempraid}].Name}].Distance}<25
			{
				call CastSpellRange 300 0 0 0 ${Actor[exactname,${RaidMember[${tempraid}].Name}].ID} 1
			}
		}
		while ${tempraid:Inc}<=24 && ${Me.Ability[${SpellType[300]}].IsReady}
	}

	;My Pet Heals
	if ${Me.ToActor.Pet.Health}<70 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 1
	}

	if ${Me.ToActor.Pet.Health}<40 && ${Me.ToActor.Pet(exists)} && ${Me.ToActor.Health}>40
	{
		call CastSpellRange 4 0 0 0 ${Me.ToActor.Pet.ID}
	}
}

function CureMe()
{
	if  ${Me.Arcane}>0 && !${Me.ToActor.Effect[Revived Sickness](exists)}
	{
		if ${Me.Arcane} && !${Me.ToActor.Effect[Revived Sickness](exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.ID}
			return
		}
	}
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local

	tmpcure:Set[0]
	if !${Me.Group[${gMember}].ZoneName.Equal["${Zone.Name}"]}
	{
		return
	}

	do
	{
		if ${Me.Group[${gMember}].Arcane}>0 && !${Me.Group[${gMember}].ToActor.Effect[Revived Sickness](exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
		}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3 && ${Me.Group[${gMember}].ToActor(exists)}
}

function QueueShardRequest(string line, string sender)
{
	if ${Actor[${sender}](exists)}
	{
		ShardQueue:Queue[${sender}]
	}
}

function AnswerShardRequest()
{
	if ${Actor[${ShardQueue.Peek}](exists)}
	{
		if ${Actor[${ShardQueue.Peek}].Distance}<10  && !${Me.IsMoving}  &&  ${Me.Ability[${SpellType[360]}].IsReady}
		{
			if ${Time.Timestamp}-${ShardRequestTimer}>2
			{
				if !${Me.InCombat} && ${Me.ToActor.Power}>80 && ${Me.Ability[${SpellType[361]}].IsReady}
				{
					call CastSpellRange 361 0 0 0 ${Actor[pc,exactname,${ShardQueue.Peek}].ID}
				}
				else
				{
					call CastSpellRange 360 0 0 0 ${Actor[pc,exactname,${ShardQueue.Peek}].ID}
				}
				ShardRequestTimer:Set[${Time.Timestamp}]
			}

			if ${Return}
			{
				ShardQueue:Dequeue
			}
		}
	}
}

function DequeueShardRequest(string line)
{
	if ${ShardQueue.Peek(exists)}
	{
		ShardQueue:Dequeue
	}
}

function SummonPet()
{
;1=Scout,2=Mage,3=Fighter; 4=ooze
	PetEngage:Set[FALSE]

	if ${PetMode}
	{
		switch ${PetType}
		{
			case 1
				call CastSpellRange 355
				break

			case 2
				if ${Me.Equipment[ExactName,"Vazaelle, the Mad"].IsReady}
				{
					call UseItem "Vazaelle, the Mad"
				}
				else
				{
					call CastSpellRange 356
				}
				break

			case 3
				call CastSpellRange 357
				break

			case 4
				call CastSpellRange 395
				break

			case default
				call CastSpellRange 356
				break
		}
		BuffCabalistCover:Set[TRUE]

		if ${PetGuard}
		{
			EQ2Execute /pet preserve_self
			EQ2Execute /pet preserve_master
		}else{
			EQ2Execute /pet backoff
		}
	}
}


function CheckEssense()
{
	;keeps 1 stack of anguish and destroys the next stack
	variable int Counter=1
	variable bool StackFound=FALSE
	Me:CreateCustomInventoryArray[nonbankonly]
	do
	{
		if ${Me.CustomInventory[${Counter}].Name.Equal[essence of anguish]}
		{
			if ${StackFound}
			{
				;we already have a stack so destroy this one and return
				return STACKFOUND
			}
			else
			{
				StackFound:Set[TRUE]
			}
		}
	}
	while ${Counter:Inc}<=${Me.CustomInventoryArraySize}

	return NOSTACK
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}