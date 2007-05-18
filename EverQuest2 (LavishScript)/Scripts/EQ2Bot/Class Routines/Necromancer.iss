;*************************************************************
;Necromancer.iss
;version 20070508a
;Initial Build
;by Pygar
;
;20070508a
;	Fixed undeclared var bug causing bot to lock up in stuck loop.
;
;20070504a
; Fixed ThermalShocker Use
; Added toggle for pet use
;
; 20070226a
; Added Ruinous Heart to shard processing
; Bot responds to 'need heart' as well as 'need shard'
; Added Toggle for Lifeburn
;
; 20070220a
; Fixed bug in cures
; Fixed a couple misc spell ID bugs in heals
; Verified it atleast runs
;
; 20070219
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
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{

	declare PetType int script
	declare AoEMode bool script FALSE
	declare CureMode bool script FALSE
	declare StartHO bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffFavor bool script FALSE
	declare BuffMark bool script FALSE
	declare BuffCabalistCover bool script TRUE
	declare LifeburnMode bool script TRUE
	declare PetMode bool script TRUE

	declare ShardQueue queue:string script
	declare ShardRequestTimer int script ${Time.Timestamp}
	declare ShardType string script

	;Custom Equipment
	declare WeaponStaff string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script

	declare EquipmentChangeTimer int script ${Time.Timestamp}

	call EQ2BotLib_Init

	AddTrigger QueueHeartRequest "\\aPC @*@ @*@:@sender@\\/a tells@*@heart please@*@"
	AddTrigger QueueShardRequest "\\aPC @*@ @*@:@sender@\\/a tells@*@shard please@*@"
	AddTrigger DequeueShardRequest "Target already has a necromancer heart item!"


	PetType:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Pet Type,3]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	LifeburnMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Lifeburn,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cures,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffMark:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffMark,FALSE]}]
	BuffFavor:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffFavor,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Staff",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]

	switch ${SpellType[360]}
	{
		case Splintered Heart
			ShardType:Set["Splintered Heart"]
			break
		case Dark Heart
			ShardType:Set["Dark Heart"]
			break
		case Sacrificial Heart
			ShardType:Set["Sacrificial Heart"]
			break
		case Ruinous Heart
			ShardType:Set["Ruinous Heart"]
			break
		case Default
			break
	}
}

function Buff_Init()
{
	PreAction[1]:Set[AA_Cabalists_Cover]
	PreSpellRange[1,1]:Set[393]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]
	PreSpellRange[2,3]:Set[27]

	PreAction[3]:Set[Pet_Buff]
	PreSpellRange[3,1]:Set[45]
	PreSpellRange[3,2]:Set[46]

	PreAction[4]:Set[SeeInvis]
	PreSpellRange[4,1]:Set[30]

	PreAction[5]:Set[Buff_Shards]
	PreSpellRange[5,1]:Set[360]

	PreAction[6]:Set[AA_GeneralPetBuffs]
	PreSpellRange[6,1]:Set[390]
	PreSpellRange[6,2]:Set[391]
	PreSpellRange[6,3]:Set[392]

	PreAction[7]:Set[AA_FighterPetBuffs]
	PreSpellRange[7,1]:Set[381]
	PreSpellRange[7,2]:Set[382]
	PreSpellRange[7,3]:Set[383]

	PreAction[8]:Set[AA_MagePetBuffs]
	PreSpellRange[8,1]:Set[386]
	PreSpellRange[8,2]:Set[387]
	PreSpellRange[8,3]:Set[388]

	PreAction[9]:Set[AA_ScoutPetBuffs]
	PreSpellRange[9,1]:Set[376]

	PreAction[10]:Set[Favor]
	PreSpellRange[10,1]:Set[20]

	PreAction[11]:Set[Mark]
	PreSpellRange[11,1]:Set[21]
}

function Combat_Init()
{
	Action[1]:Set[DrawingSouls]
	SpellRange[1,1]:Set[375]

	Action[2]:Set[AA_Magic_Leash]
	MobHealth[2,1]:Set[1]
	MobHealth[2,2]:Set[100]
	SpellRange[2,1]:Set[385]

	Action[3]:Set[Shockwave]
	MobHealth[3,1]:Set[1]
	MobHealth[3,2]:Set[100]
	SpellRange[3,1]:Set[380]

	Action[4]:Set[AA_Animist_Bond]
	MobHealth[4,1]:Set[50]
	MobHealth[4,2]:Set[100]
	SpellRange[4,1]:Set[371]

	Action[5]:Set[AoE]
	SpellRange[5,1]:Set[90]

	Action[6]:Set[Cloud]
	SpellRange[6,1]:Set[95]

	Action[7]:Set[Stench_Pet]
	MobHealth[7,1]:Set[30]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[329]

	Action[8]:Set[Debuff1]
	SpellRange[8,1]:Set[50]

	Action[9]:Set[Debuff3]
	SpellRange[9,1]:Set[52]

	Action[10]:Set[Dot1]
	MobHealth[10,1]:Set[5]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[72]

	Action[11]:Set[Dot2]
	MobHealth[11,1]:Set[5]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[71]

	Action[12]:Set[Debuff2]
	SpellRange[12,1]:Set[51]

	Action[13]:Set[Dot3]
	MobHealth[13,1]:Set[0]
	MobHealth[13,2]:Set[100]
	SpellRange[13,1]:Set[70]

	Action[14]:Set[AA_Lifeburn]
	SpellRange[14,1]:Set[375]

	Action[15]:Set[Rat_Pet]
	MobHealth[15,1]:Set[30]
	MobHealth[15,2]:Set[100]
	SpellRange[15,1]:Set[330]

	Action[16]:Set[LifeTap]
	MobHealth[16,1]:Set[0]
	MobHealth[16,2]:Set[100]
	SpellRange[16,1]:Set[60]

	Action[17]:Set[UndeadTide]
	MobHealth[17,1]:Set[0]
	MobHealth[17,2]:Set[100]
	SpellRange[17,1]:Set[60]

	Action[18]:Set[Master_Strike]

	Action[19]:Set[Bat_Pet]
	MobHealth[19,1]:Set[30]
	MobHealth[19,2]:Set[100]
	SpellRange[19,1]:Set[331]

	Action[20]:Set[AA_Animated_Dagger]
	MobHealth[20,1]:Set[30]
	MobHealth[20,2]:Set[100]
	SpellRange[20,1]:Set[332]

	Action[21]:Set[ThermalShocker]

}

function PostCombat_Init()
{
	PostAction[1]:Set[AA_Possessed_Minion]
	PostSpellRange[1,1]:Set[398]

	PostAction[2]:Set[LoadDefaultEquipment]

}

function Buff_Routine(int xAction)
{

	call CheckHeals
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	;check if we have a pet or a hydromancy not up
	if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[395]}](exists)} && ${PetMode}
	{
		call SummonPet
		waitframe
	}


	call RefreshPower
	call AnswerShardRequest

	ExecuteAtom CheckStuck

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
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
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case Favor
			if ${BuffFavor}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Mark
			if ${BuffMark}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Pet_Buff
			if ${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[395]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		case AA_FighterPetBuffs
			if ${Me.Maintained[${SpellType[357]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			}
			break
		case AA_MagePetBuffs
			if ${Me.Maintained[${SpellType[356]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			}
			break
		case AA_ScoutPetBuffs
			if ${Me.Maintained[${SpellType[355]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_GeneralPetBuffs
			if ${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[379]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			}
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
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
					}

				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break

		case Buff_Shards
			if !${Me.Inventory[${ShardType}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			}
			break

		Default
			xAction:Set[40]
			break
	}
}

function Combat_Routine(int xAction)
{
	variable int Counter

	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	call CheckHeals

	;check if we have a pet or a hydromancy not up
	if !${Me.ToActor.Pet(exists)} || !${Me.Maintained[${SpellType[395]}](exists)}
	{
		call SummonPet
	}

	if ${Me.ToActor.Pet(exists)} || !${Me.Maintained[${SpellType[395]}](exists)}
	{
		ExecuteAtom PetAttack
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	call RefreshPower
	call AnswerShardRequest

	;Keep Consumption Up
	if ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 351
	}

	;keep distracting strike up if we have a scout pet
	if ${Me.Maintained[${SpellType[355]}](exists)}
	{
		call CastSpellRange 375
	}

	;keep  Magic Leash up if we have a mage pet
	if ${Me.Maintained[${SpellType[356]}](exists)}
	{
		call CastSpellRange 385
	}

	;Need some Logic for the soul uses here

	switch ${Action[${xAction}]}
	{


		case AA_Animated_Dagger
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					if ${Me.Equipment[1].Name.Equal[${WeaponDagger}]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
					elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
					{
						Me.Inventory[${WeaponDagger}]:Equip
						EquipmentChangeTimer:Set[${Time.Timestamp}]
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
			}
			break

		case Stench_Pet
			if ${AoEMode} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

				}
			}
			break

		case Bat_Pet
		case Rat_Pet
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${PetMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case UndeadTide
			if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic} && ${Me.ToActor.Pet(exists)} && ${PetMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case AA_Lifeburn
			if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic} && ${Me.ToActor.Pet(exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${LifeburnMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Cloud
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break

		case Shockwave
			if ${AoEMode} && ${Me.ToActor.Pet(exists)}  && ${Me.Maintained[${SpellType[357]}](exists)}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

			}
			break

		case AoE
			if ${AoEMode}
			{
				if ${Mob.Count}>1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case DrawingSouls
		case LifeTap
		case Debuff1
		case Debuff2
		case Debuff3
			call CastSpellRange ${SpellRange[${xAction},1]}
			break

		case Dot1
		case Dot2
		case Dot3
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case AA_Magic_Leash
		case AA_Animist_Bond
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
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
			{
				Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
			}
			break

		Default
			xAction:Set[40]
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
		case AA_Possessed_Minion
			;check if we are possessed minion and cancel
			if ${Me.Race.Equal[Unknown]}
			{
				Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case default
			xAction:Set[20]
			break
	}


}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if ${aggroid}
	{
		;Cast Fear
		call CastSpellRange 350 0 0 0 ${aggroid}
	}

	if ${Me.InCombat} && ${Me.ToActor.Health}<40
	{
			   call CastSpellRange 349
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
	{
		call CastSpellRange 326
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<80 && ${Me.Health}>80 && !${Me.ToActor.Pet.IsAggro}
	{
		call CastSpellRange 325
	}

	;Necro Heart
	if ${Me.Power}<80 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
	{
		Me.Inventory[${ShardType}]:Use
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<20
	{
		call UseItem "Dracomancer Gloves"
	}

	if ${Me.ToActor.Pet.Health}>50 && ${Me.ToActor.Power}<20
	{
		call CastSpellRange 326
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45 && ${Me.Health}>20
	{
		call CastSpellRange 325
	}


	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

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
	if ${Actor[${MainTankPC}].Health}==-99 && ${Actor[${MainTankPC}](exists)}
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{

			if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>-99
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

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<80
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

			if ${Me.Group[${temphl}].Name.Equal[${MainAssist}]}
			{
				MTinMyGroup:Set[TRUE]
			}
		}

	}
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
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
				if ${Me.Equipment[1].Name.Equal[${WeaponStaff}]}
				{
					call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2 && ${Me.Ability[${SpellType[396]}].IsReady}
				{
					Me.Inventory[${WeaponStaff}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
				}

				if ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
				}
			}
		}
	}

	;MAINTANK HEALS
	if ${Actor[${MainAssist}].Health}<60 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
			call CastSpellRange 4 0 0 0 ${Actor[${MainAssist}].ID}
	}

	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Equipment[1].Name.Equal[${WeaponStaff}]}
		{
			call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
		}
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2 && ${Me.Ability[${SpellType[396]}].IsReady}
		{
			Me.Inventory[${WeaponStaff}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
		}

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<70 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ID}!=${Me.ID}
	{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}

	}

	;PET HEALS (other)
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)}
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
		if ${Me.Group[${tempgrp}].ToActor.Health}==-99
		{
			call CastSpellRange 300 0 0 0 ${Me.Group[${tempgrp}].ID} 1
		}
	}
	while ${tempgrp:Inc}<${grpcnt}

	if ${Me.InRaid}
	{
		;Res Fallen RAID members only if in range
		grpcnt:Set[${Me.RaidCount}]
		tempraid:Set[1]
		do
		{
			if ${RaidMember[${tempraid}].Health}==-99
			{
				call CastSpellRange 300 0 1 0 ${Actor[exactname,${RaidMember[${tempraid}].Name}].ID} 1
			}
		}
		while ${tempraid:Inc}<=24
	}

	;My Pet Heals
	if ${Me.ToActor.Pet.Health}<70 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 1
	}

	if ${Me.ToActor.Pet.Health}<40 && ${Me.ToActor.Pet(exists)} && ${Me.ToActor.Health}>40
	{
		call CastSpellRange 4 0 0 0 ${Me.Pet.ID}
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
		if  ${Me.Group[${gMember}].Arcane}>0 && !${Me.Group[${gMember}].ToActor.Effect[Revived Sickness](exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
		}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3 && ${Me.Group[${gMember}].ToActor(exists)}
}

function QueueHeartRequest(string line, string sender)
{
	if ${Actor[${sender}](exists)}
	{
		ShardQueue:Queue[${sender}]
	}
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
				call CastSpellRange 360 0 0 0 ${Actor[${ShardQueue.Peek}].ID}
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
;1=Scout,2=Mage,3=Fighter; 4=hydromancer
	PetEngage:Set[FALSE]

	if ${PetMode}
	{
		switch ${PetType}
		{
			case 1
				call CastSpellRange 355
				break

			case 2
				call CastSpellRange 356
				break

			case 3
				call CastSpellRange 357
				break

			case 4
				call CastSpellRange 379
				break

			case default
				call CastSpellRange 395
				break
		}
		BuffCabalistCover:Set[TRUE]
	}
}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal["${WeaponMain}"]}
	{
		Me.Inventory["${WeaponMain}"]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal["${OffHand}"]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory["${OffHand}"]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}