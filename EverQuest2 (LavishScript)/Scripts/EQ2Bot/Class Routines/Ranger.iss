function Class_Declaration()
{

}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[29]

	PreAction[2]:Set[Stealth]
	PreSpellRange[2,1]:Set[201]
}

function Combat_Init()
{
	Action[1]:Set[Ranged_Combat_Any]
	SpellRange[1,1]:Set[250]
	SpellRange[1,2]:Set[251]

	Action[2]:Set[Ranged_Combat_Flank]
	SpellRange[2,1]:Set[257]
	SpellRange[2,2]:Set[258]

	Action[3]:Set[Stealth_Attack]
	SpellRange[3,1]:Set[130]

	Action[4]:Set[Debuff]
	MobHealth[4,1]:Set[50]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[20]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[50]
	SpellRange[4,2]:Set[54]

	Action[5]:Set[Dot]
	SpellRange[5,1]:Set[70]
	SpellRange[5,2]:Set[74]

	Action[6]:Set[Special_Attack]
	SpellRange[6,1]:Set[320]
	SpellRange[6,2]:Set[135]
	SpellRange[6,3]:Set[130]

	Action[7]:Set[Special_Ranged_Attack]
	SpellRange[7,1]:Set[257]

	Action[8]:Set[Root_Attack]
	SpellRange[8,1]:Set[321]
	SpellRange[8,2]:Set[257]

	Action[9]:Set[Melee_Attack]
	SpellRange[9,1]:Set[150]
	SpellRange[9,2]:Set[154]

	Action[10]:Set[Deaggro_Attack]
	SpellRange[10,1]:Set[200]
	SpellRange[10,2]:Set[135]
	SpellRange[10,3]:Set[130]

	Action[11]:Set[Check_Arrows]
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Stealth
			if (!${Mob.Detect} || ${MainTank}) && !${Me.Maintained[${SpellType[201]}](exists)}
			{
				if ${following}
				{
					FollowTask:Set[2]
				}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
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
		case Ranged_Combat_Any
			if (${Target.Distance}>5.5 || !${MainTank}) && ${RangedCombat}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 3
			}
			break

		case Ranged_Combat_Flank
			if !${MainTank} && ${RangedCombat}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 3 3
			}
			break

		case Stealth_Attack
			if ${Me.Maintained[${SpellType[201]}](exists)}
			{
				face ${Target.X} ${Target.Z}
				wait 5
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1
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

		case Dot
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			break

		case Special_Attack
			if !${disablebehind} && !${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},2]} 0 1 3
				}
				else
				{
					call CastSpellRange ${SpellRange[${xAction},3]} 0 1
				}
			}
			elseif ${MainTank}
			{
				if ${Me.Ability[${SpellType[190]}].IsReady}
				{
					call CastSpellRange 190
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},2]} 0 1 3
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},3]} 0 1
					}
				}
			}
			break

		case Melee_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			break

		case Special_Ranged_Attack
			if !${disablebehind} && !${MainTank} && ${RangedCombat}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 3
			}
			elseif ${MainTank} && ${RangedCombat}
			{
				if ${Me.Ability[${SpellType[190]}].IsReady} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange 190
					call CastSpellRange ${SpellRange[${xAction},1]} 0 3 3
				}
			}
			break

		case Root_Attack
			call CastSpellRange ${SpellRange[${xAction},1]}
			if ${RangedCombat} && (${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)} || !${MainTank})
			{
				call CastSpellRange ${SpellRange[${xAction},2]} 0 3 3
			}
			break

		case Deaggro_Attack
			if !${disablebehind} && !${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},2]} 0 1 3
				}
				else
				{
					call CastSpellRange ${SpellRange[${xAction},3]} 0 1
				}
			}
			elseif ${MainTank}
			{
				if ${Me.Ability[${SpellType[190]}].IsReady}
				{
					call CastSpellRange 190
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},2]} 0 1 3
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},3]} 0 1
					}
				}
			}
			break

		case Check_Arrows
			if ${Me.Equipment[ammo](exists)} && ${Me.Equipment[ranged](exists)}
			{
				RangedCombat:Set[TRUE]
			}
			else
			{
				RangedCombat:Set[FALSE]
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
		call CastSpellRange 181
	}

	if !${homepoint}
	{
		return
	}

	if !${avoidhate} && !${Me.Maintained[${SpellType[180]}](exists)} && ${Actor[${aggroid}].Distance}<5
	{
		call NPCCount
		if ${Return}<3
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
