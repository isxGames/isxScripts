function Class_Declaration()
{

}

function Buff_Init()
{
	PreAction[1]:Set[Protect_Target]
	PreSpellRange[1,1]:Set[30]
	PreSpellRange[1,2]:Set[32]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[29]

	PreAction[3]:Set[Group_Buff]
	PreSpellRange[3,1]:Set[20]
	PreSpellRange[3,2]:Set[24]

	PreAction[4]:Set[Shield_Ally]
	PreSpellRange[4,1]:Set[322]
}

function Combat_Init()
{
	Action[1]:Set[Combat_Buff]
	SpellRange[1,1]:Set[155]
	SpellRange[1,2]:Set[156]

	Action[2]:Set[Taunt]
	SpellRange[2,1]:Set[160]
	SpellRange[2,2]:Set[161]

	Action[3]:Set[AoE_Taunt]
	SpellRange[3,1]:Set[170]
	SpellRange[3,2]:Set[171]

	Action[4]:Set[Root_Taunt]
	MobHealth[4,1]:Set[20]
	MobHealth[4,2]:Set[98]
	SpellRange[4,1]:Set[325]

	Action[5]:Set[Increase_Defense]
	SpellRange[5,1]:Set[321]

	Action[6]:Set[Damage_Debuff]
	MobHealth[6,1]:Set[40]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[40]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[80]
	SpellRange[6,2]:Set[82]

	Action[7]:Set[Power_Drain_Attack]
	MobHealth[7,1]:Set[50]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[50]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[140]

	Action[8]:Set[Melee_Attack]
	Power[8,1]:Set[50]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[150]
	SpellRange[8,2]:Set[154]
	
	Action[9]:Set[AoE_All]
	Power[9,1]:Set[50]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[95]

	Action[10]:Set[Shield_Attack]
	Power[10,1]:Set[50]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[240]

	Action[11]:Set[Guardian_Sphere]
	SpellRange[11,1]:Set[275]

	Action[12]:Set[Sentry_Watch]
	SpellRange[12,1]:Set[322]
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	switch ${PreAction[${xAction}]}
	{
		case Protect_Target
			if ${EQ2Bot.ProtectHealer}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${EQ2Bot.ProtectHealer}
			}
			break

		case Shield_Ally
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				if ${EQ2Bot.ProtectHealer}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${EQ2Bot.ProtectHealer}
				}
			}
			break

		case Self_Buff
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
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
		case Combat_Buff
		case Taunt
			if ${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case AoE_Taunt
			if ${MainTank}
			{
				if ${Mob.Count}>1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
				}
			}
			break

		case Root_Taunt
			if ${MainTank}
			{
				if !${lostaggro}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]}
					}
				}
			}
			break

		case Increase_Defense
		case Guardian_Sphere
			if ${MainTank}
			{
				if ${Math.Calc[${Me.Health}/${Me.MaxHealth}*100]}<40
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break

		case Damage_Debuff
		case Power_Drain_Attack
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
				}
			}
			break

		case Melee_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}

			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case AoE_All
			if ${Mob.Count}>2
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break

		case Shield_Attack
			if ${Me.Equipment[secondary].Type.Equal[Shield]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break

		case Sentry_Watch
			grpcnt:Set[${Me.GroupCount}]
			tempvar:Set[1]
			do
			{
				if ${Me.Group[${tempvar}].Health}<25
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 ${Me.Group[${tempvar}].ID}
					break
				}
			}
			while ${tempvar:Inc}<${grpcnt}
			break

		Default
			xAction:Set[20]
			break
	}
}

function Post_Combat_Routine(int xAction)
{

}

function Have_Aggro()
{
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
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

function Lost_Aggro(int mobid)
{
	call CastSpellRange 170 171

	if ${Me.Ability[${SpellType[270]}].IsReady}
	{
		call CastSpellRange 270 0 0 0 ${mobid}
	}
	elseif ${Me.Ability[${SpellType[275]}].IsReady}
	{
		call CastSpellRange 275 0 0 0 ${mobid}
	}
	elseif ${Me.Ability[${SpellType[320]}].IsReady}
	{
		call CastSpellRange 320 0 0 0 ${mobid}
	}
}

function MA_Lost_Aggro()
{



}

function MA_Dead()
{
	MainTank:Set[TRUE]
	MainAssist:Set[${Me.Name}]
	KillTarget:Set[]
}
