function Class_Declaration()
{

}

function Buff_Init()
{
	PreAction[1]:Set[Group_Buff_Conc]
	PreSpellRange[1,1]:Set[20]
	PreSpellRange[1,2]:Set[24]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[29]

	PreAction[3]:Set[Stealth]
	PreSpellRange[3,1]:Set[201]
}

function Combat_Init()
{
	Action[1]:Set[Stealth_Attack]
	SpellRange[1,1]:Set[130]

	Action[2]:Set[Debuff]
	MobHealth[2,1]:Set[50]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[20]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[50]
	SpellRange[2,2]:Set[54]

	Action[3]:Set[Damage_Debuff]
	SpellRange[3,1]:Set[80]
	SpellRange[3,2]:Set[84]

	Action[4]:Set[AoE_Debuff]
	SpellRange[4,1]:Set[55]
	SpellRange[4,2]:Set[57]

	Action[5]:Set[Dot]
	SpellRange[5,1]:Set[70]
	SpellRange[5,2]:Set[74]

	Action[6]:Set[Melee_Attack]
	SpellRange[6,1]:Set[150]
	SpellRange[6,2]:Set[154]

	Action[7]:Set[Flank_Attack]
	SpellRange[7,1]:Set[110]
	SpellRange[7,2]:Set[112]

	Action[8]:Set[Stun]
	SpellRange[8,1]:Set[190]
	SpellRange[8,2]:Set[191]

	Action[9]:Set[Lower_Hate]
	SpellRange[9,1]:Set[181]

	Action[10]:Set[AoE]
	SpellRange[10,1]:Set[90]
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	switch ${PreAction[${xAction}]}
	{
		case Group_Buff_Conc
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
	
		case Stealth
			if ${MainTank}
			{
				call CheckNPC
				if !${Return}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]}
					stealth:Set[TRUE]
				}
			}
			else
			{
				if ${Actor[${KillTarget},radius,10].Target.Name.Equal[${MainAssist}]} && ${Actor[${KillTarget}].Type.Equal[NPC]}
				{
					if ${following}
					{
						FollowTask:Set[2]
					}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
					stealth:Set[TRUE]
				}
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
		case Stealth_Attack
			if ${stealth}
			{
				face ${Target.X} ${Target.Z}
				wait 5
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1
				stealth:Set[FALSE]
			}
			break

		case Debuff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break

		case Damage_Debuff
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case Dot
			if ${AutoMelee}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			}
			else
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 2
			}
			break

		case Melee_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			break

		case Flank_Attack
			if !${disablebehind} && !${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 3
			}
			elseif ${MainTank}
			{
				if ${Me.Ability[${SpellType[190]}].IsReady}
				{
					call CastSpellRange 190
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 3
				}
			}
			break

		case Stun
			if !${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			}
			break

		case Lower_Hate
			if !${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case AoE_Debuff
		case AoE
			if ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
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
	elseif ${Me.Maintained[${SpellType[180]}](exists)}
	{
		Me.Maintained[${SpellType[180]}]:Cancel
	}

	if !${homepoint}
	{
		return
	}

	if !${avoidhate} && !${Me.Maintained[${SpellType[180]}](exists)} && ${Actor[${aggroid}].Distance}<5
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

function MA_Dead()
{

}
