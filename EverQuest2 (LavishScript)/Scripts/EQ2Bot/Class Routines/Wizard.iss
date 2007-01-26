function Class_Declaration() 
{ 

} 

function Buff_Init() 
{ 
	PreAction[1]:Set[Self_Buff] 
	PreSpellRange[1,1]:Set[25] 
	PreSpellRange[1,2]:Set[26] 

	PreAction[2]:Set[Group_Buff] 
	PreSpellRange[2,1]:Set[20] 
	PreSpellRange[2,2]:Set[22] 

	PreAction[3]:Set[Melee_Buff]
	PreSpellRange[3,1]:Set[30]

	PreAction[4]:Set[Tank_Buff] 
	PreSpellRange[4,1]:Set[40] 
	PreSpellRange[4,2]:Set[42] 

	PreAction[5]:Set[Target_Buff]
	PreSpellRange[5,1]:Set[31]
}

function Combat_Init() 
{ 
	Action[1]:Set[Damage_Debuff] 
	MobHealth[1,1]:Set[40] 
	MobHealth[1,2]:Set[98] 
	Power[1,1]:Set[20] 
	Power[1,2]:Set[100] 
	SpellRange[1,1]:Set[80] 
	SpellRange[1,2]:Set[81] 

	Action[2]:Set[Combat_Buff] 
	SpellRange[2,1]:Set[155] 
	SpellRange[2,2]:Set[156] 

	Action[3]:Set[AoE] 
	SpellRange[3,1]:Set[90] 
	SpellRange[3,1]:Set[94] 

	Action[4]:Set[Special_Pet] 
	MobHealth[4,1]:Set[50] 
	MobHealth[4,2]:Set[100] 
	SpellRange[4,1]:Set[324]

	Action[5]:Set[Dot] 
	MobHealth[5,1]:Set[50] 
	MobHealth[5,2]:Set[98] 
	SpellRange[5,1]:Set[70] 
	SpellRange[5,2]:Set[74]

	Action[6]:Set[Stun] 
	SpellRange[6,1]:Set[190] 
	SpellRange[6,2]:Set[191]

	Action[7]:Set[Group_Combat_Buff] 
	SpellRange[7,1]:Set[157] 

	Action[8]:Set[Nuke_Attack] 
	SpellRange[8,1]:Set[60] 
	SpellRange[8,2]:Set[62] 

	Action[9]:Set[Stifle] 
	SpellRange[9,1]:Set[260] 
	SpellRange[9,2]:Set[261]

	Action[10]:Set[Self_Power]
	SpellRange[10,1]:Set[320]
	SpellRange[10,2]:Set[309]

	Action[11]:Set[Give_Power] 
	SpellRange[11,1]:Set[322] 
} 

function PostCombat_Init() 
{ 

} 

function Buff_Routine(int xAction) 
{
	switch ${PreAction[${xAction}]} 
	{ 
		case Self_Buff 
		case Group_Buff 
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Melee_Buff
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				switch ${Me.Group[${tempgrp}].Class}
				{
					case scout
					case rogue
					case swashbuckler
					case brigand
					case bard
					case troubador
					case dirge
					case predator
					case ranger
					case assassin
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
						return
				}
			}
			while ${tempgrp:Inc}<${grpcnt}

			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].Class.Equal[bruiser]} || ${Me.Group[${tempgrp}].Class.Equal[monk]}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
					return
				}
			}
			while ${tempgrp:Inc}<${grpcnt}

			if ${Actor[${MainAssist}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			}

			if ${MainTank}
			{
				EQ2Execute /target_none
			}
			break

		case Tank_Buff 
			if ${Actor[${MainAssist}](exists)}
			{ 
				call CastSpellRange 40 42 0 0 ${Actor[${MainAssist}].ID}
				if ${MainTank}
				{
					EQ2Execute /target_none
				}
			} 
			break

		case Target_Buff 
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Me.ID}
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
		case Damage_Debuff 
		case Dot
			if ${Mob.Count}<5
			{ 
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
				if ${Return.Equal[OK]} 
				{ 
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
					if ${Return.Equal[OK]} 
					{ 
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
					}
				} 
			} 
			break

		case Combat_Buff
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				switch ${Me.Group[${tempgrp}].Class}
				{
					case fighter
					case warrior
					case berserker
					case guardian
					case brawler
					case bruiser
					case monk
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${Me.Group[${tempgrp}].ID}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		case AoE 
			if ${Mob.Count}>2 
			{ 
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
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

		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case Group_Combat_Buff
			call CastSpellRange ${SpellRange[${xAction},1]}
			break

		case Nuke_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}

			call CastSpellRange 321
			; Deaggro Spell
			if !${MainTank}
			{
				call CastSpellRange 182
			}
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 
			break

		case Stifle
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 
			break

		case Self_Power
			if ${Me.ToActor.Power}<60 && ${Me.ToActor.Health}>85 && !${haveaggro}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}

			if ${Me.ToActor.Power}<80 && ${Me.ToActor.Health}>85 && !${haveaggro}
			{
				call CastSpellRange ${SpellRange[${xAction},2]}
			}
			break

		case Give_Power 
			if ${Me.ToActor.Health}>80 && !${haveaggro} 
			{
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
							if ${Me.Group[${tempgrp}].ToActor.Power}<70
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID} 
							}
					}
				}
				while ${tempgrp:Inc}<${grpcnt}
			}
			break

		Default 
			xAction:Set[20] 
			break
	}
}

function Post_Combat_Routine() 
{ 


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

function Lost_Aggro() 
{ 

} 

function MA_Lost_Aggro() 
{ 

} 
