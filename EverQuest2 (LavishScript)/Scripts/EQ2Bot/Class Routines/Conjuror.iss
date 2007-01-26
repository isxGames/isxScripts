function Class_Declaration()
{
	declare PetTarget int script
	declare PetEngage bool script
	addtrigger coh "@grpmember@ tells the group,\"i need a coh\""
	addtrigger coh "@grpmember@ tells the group,\"i need a coh\""
	addtrigger shard "@grpmember@ tells the group,\"i need a shard\""
	addtrigger shard "@grpmember@ tells the raid,\"i need a shard\""
}
 
function Buff_Init()
{
	PreAction[1]:Set[Summon_Pet]
	PreSpellRange[1,1]:Set[320]
	PreSpellRange[1,2]:Set[321]
	PreSpellRange[1,3]:Set[322]
	PreSpellRange[1,4]:Set[323]
 
	PreAction[2]:Set[Group_Buff]
	PreSpellRange[2,1]:Set[20]
	PreSpellRange[2,2]:Set[21]

	PreAction[3]:Set[Self_Buff]
	PreSpellRange[3,1]:Set[25]
 
	PreAction[4]:Set[Pet_Buff]
	PreSpellRange[4,1]:Set[45]
	PreSpellRange[4,2]:Set[290]
 
	PreAction[5]:Set[Tank_Buff]
	PreSpellRange[5,1]:Set[40]
 
	PreAction[6]:Set[DPS_Proc]
	PreSpellRange[6,1]:Set[327]
}
 
function Combat_Init()
{
	Action[1]:Set[Pet_Attack]
	PetEngage:Set[FALSE]
 
	Action[2]:Set[Special_Pet] 
	MobHealth[2,1]:Set[50] 
	MobHealth[2,2]:Set[100] 
	SpellRange[2,1]:Set[328]

	Action[3]:Set[Combat_Pet_DS]
	SpellRange[3,1]:Set[330]

	Action[4]:Set[AoE_PB]
	SpellRange[4,1]:Set[95]
 
	Action[5]:Set[Dot]
	MobHealth[5,1]:Set[50]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[70]
 
	Action[6]:Set[Nuke_Attack]
	SpellRange[6,1]:Set[60]

	Action[7]:Set[AoE]
	SpellRange[7,1]:Set[90]
	SpellRange[7,2]:Set[238]

	Action[8]:Set[Stun]
	SpellRange[8,1]:Set[190]
 
	Action[9]:Set[Heal_Pet]
	SpellRange[9,1]:Set[1]
 
	Action[10]:Set[Self_Power]
	SpellRange[10,1]:Set[309]

	Action[11]:Set[Sacrafice_Pet]
	SpellRange[11,1]:Set[324]

	Action[12]:Set[Combat_Pet_Defense]
	SpellRange[12,1]:Set[329]

	Action[13]:Set[Convert_Power]
	SpellRange[13,1]:Set[326]

	Action[14]:Set[Pet_Intervention]
	SpellRange[14,1]:Set[329]
}
 
function PostCombat_Init()
{
 
}
 
function Buff_Routine(int xAction)
{
	switch ${PreAction[${xAction}]}
	{
		case Summon_Pet
			if ${MainTank}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			elseif ${SpellType[${PreSpellRange[${xAction},4]}].Length}
			{
				call CastSpellRange ${PreSpellRange[${xAction},4]}
			}
			elseif ${SpellType[${PreSpellRange[${xAction},3]}].Length}
			{
				call CastSpellRange ${PreSpellRange[${xAction},3]}
			}
			elseif ${SpellType[${PreSpellRange[${xAction},2]}].Length}
			{
				call CastSpellRange ${PreSpellRange[${xAction},2]}
			}
			break
 
		case Self_Buff
		case Group_Buff
		case No_Conc_Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
 
		case Pet_Buff
			if ${Actor[MyPet](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
 
		case Tank_Buff 
			if ${Actor[${MainAssist}](exists)} 
			{ 
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${MainAssist}].ID} 
			} 
			break 

		case DPS_Proc
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				switch ${Me.Group[${tempgrp}].Class}
				{
					case swashbuckler
					case brigand
					case troubador
					case dirge
					case monk
					case bruiser
					case ranger
					case assassin
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
						return
				}
			}
			while ${tempgrp:Inc}<${grpcnt}

			if ${tempgrp}==${grpcnt}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			}
			break

		Default
			xAction:Set[20]
			break
	}
}
 
function Combat_Routine(int xAction)
{
	switch ${Action[${xAction}]}
	{
		case Pet_Attack
			if !${PetEngage}
			{
				EQ2Execute /pet attack
				PetEngage:Set[TRUE]
				PetTarget:Set[${Target.ID}]
			}
 
			if ${PetTarget}!=${Target.ID}
			{
				EQ2Execute /pet backoff
				EQ2Execute /pet attack
				PetTarget:Set[${Target.ID}]
				PetEngage:Set[TRUE]
			}
 			break
 
		case Special_Pet 
			if ${Mob.Count}<3 
			{ 
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
				if ${Return.Equal[OK]} 
				{ 
					call CastSpellRange ${SpellRange[${xAction},1]}
				} 
			} 
			break 
 
		case AoE_PB
		case AoE
			if ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Dot
			if ${Mob.Count}<3
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
				}
			}
			break
 
		case Nuke_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
 
		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]}
			break
 
		case Heal_Pet
			call CheckPetTanking
			if ${Return}
			{
				if ${Me.PetHealth}<70
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			else
			{
				if ${Me.PetHealth}<30 && ${Me.ToActor.Power}>60 
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break
 
		case Self_Power
			if !${MainTank} && ${Me.PetHealth}>60 && ${Me.ToActor.Power}<70 
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Sacrafice_Pet
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1] 
			do 
			{
				switch ${Me.Group[${tempgrp}].Class} 
				{ 
					case priest
					case cleric
					case templar
					case inquisitor
					case druid
					case fury
					case warden
					case shaman
					case defiler
					case mystic
						if ${Me.Group[${tempgrp}].ToActor.Health}<30
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID} 
						}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		case Combat_Pet_Defense
			call CheckPetTanking
			if ${Return}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Combat_Pet_DS
			call CastSpellRange ${SpellRange[${xAction},1]}
			break

		case Convert_Power
			call CheckPetTanking
			if ${Me.PetHealth}>50 && ${Me.ToActor.Power}<50 && !${Return}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Pet_Intervention
			call CheckPetTanking
			if ${Return}
			{
				if ${Me.PetHealth}<50
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			else
			{
				if ${Me.PetHealth}<20
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break
 
		Default
			xAction:Set[20]
			break
	}
}
 
function Post_Combat_Routine()
{
	PetEngage:Set[FALSE]
 
}
 
function Have_Aggro()
{
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}
 
	if ${Target.Target.ID}==${Me.ID}
	{
		call CastSpellRange 180
	}

	if !${homepoint}
	{
		return
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
		if ${Mob.Count}<3
		{
			press -hold ${backward}
			wait 3
			press -release ${backward}
			avoidhate:Set[TRUE]
		}
	}
}
 
function coh(string trigline, string grpmember)
{
	if ${Me.Level} < 52
		eq2execute /gsay I am only ${Me.Level}. I do not have Call of the Hero.
	else
	{
		target ${grpmember}
		eq2execute /gsay Casting Call of the Hero on ${grpmember}
		eq2execute usability "Call of the Hero"
	}
}
 
function shard(string trigline, string grpmember)
{
	target ${grpmember}
	do
	{
		face ${Target}
		if ${Target.Distance} > 10
			press -hold ${forward}
		else
			press -release ${forward}
	}
	while ${Target.Distance} > 10
 
	eq2execute /gsay Giving ${grpmember} a shard
	call CastSpell "${SpellType[312]}"
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
 
function CheckPetTanking()
{
	declare tcount int local 2
	declare petaggro bool local FALSE

	if !${Actor[NPC,range,15](exists)} && !(${Actor[NamedNPC,range,15](exists)} && ${AttackNamed})
	{
		return ${petaggro}
	}

	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		if (${CustomActor[${tcount}].Type.Equal[NPC]} || (${CustomActor[${tcount}].Type.Equal[NamedNPC]} && ${AttackNamed})) && ${Actor[${CustomActor[${tcount}].ID}](exists)} && !${CustomActor[${tcount}].IsLocked} && ${CustomActor[${tcount}].Target.ID}==${Actor[MyPet].ID} && ${Math.Calc[${Actor[MyPet].Y}+10]}>=${CustomActor[${tcount}].Y} && ${Math.Calc[${Actor[MyPet].Y}-10]}<=${CustomActor[${tcount}].Y} && ${CustomActor[${tcount}].InCombatMode}
		{
			petaggro:Set[TRUE]
			break
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	return ${petaggro}
}