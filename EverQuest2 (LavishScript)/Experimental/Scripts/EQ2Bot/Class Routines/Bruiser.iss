function Class_Declaration()
{

}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[26]

	PreAction[2]:Set[Group_Buff]
	PreSpellRange[2,1]:Set[22]

	PreAction[3]:Set[Combat_Buff]
	PreSpellRange[3,1]:Set[155]

	PreAction[4]:Set[Protect_Target]
	PreSpellRange[4,1]:Set[30]
	PreSpellRange[4,2]:Set[32]

	PreAction[5]:Set[Cure_Trauma]
	PreSpellRange[5,1]:Set[211]
}

function Combat_Init()
{
	Action[1]:Set[Combat_Buff]
	SpellRange[1,1]:Set[155]
	SpellRange[1,2]:Set[156]

	Action[2]:Set[Taunt]
	SpellRange[2,1]:Set[160]

	Action[3]:Set[Cure_Trauma]
	SpellRange[3,1]:Set[211]

	Action[4]:Set[Self_Heal]
	SpellRange[4,1]:Set[320]

	Action[5]:Set[DoT]
	SpellRange[5,1]:Set[70]
	SpellRange[5,2]:Set[71]

	Action[6]:Set[Stun]
	SpellRange[6,1]:Set[190]

	Action[7]:Set[Melee_Attack]
	SpellRange[7,1]:Set[150]
	SpellRange[7,2]:Set[154]

	Action[8]:Set[High_Attack]
	SpellRange[8,1]:Set[321]
	
	Action[9]:Set[AoE_All]
	SpellRange[9,1]:Set[95]
	SpellRange[9,2]:Set[96]

	Action[10]:Set[AoE]
	SpellRange[10,1]:Set[90]

	Action[11]:Set[Combat_Defense]
	SpellRange[11,1]:Set[307]
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

		case Group_Buff
		case Combat_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Protect_Target
			if ${EQ2Bot.ProtectHealer}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${EQ2Bot.ProtectHealer}
			}
			break

		case Cure_Trauma
			if ${Me.Trauma}
			{
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
		case Combat_Buff
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case Taunt
			if ${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Self_Heal
			if ${Me.ToActor.Health}<50
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Cure_Trauma
			if ${Me.Trauma}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case DoT
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]}
			break

		case Melee_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case High_Attack
			if ${Me.ToActor.Health}>60
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case AoE_All
		case AoE
			if ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Combat_Defense
			if !${lostaggro}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			elseif ${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
			{
				Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}]:Cancel
			}
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
	if ${Me.Maintained[${SpellType[307]}](exists)}
	{
		Me.Maintained[${SpellType[307]}]:Cancel
	}

	call CastSpellRange 170 171

	if ${Me.Ability[${SpellType[160]}].IsReady}
	{
		call CastSpellRange 160 0 0 0 ${mobid}
	}
	elseif ${Me.Ability[${SpellType[270]}].IsReady}
	{
		call CastSpellRange 270 0 0 0 ${mobid}
	}
	elseif ${Me.Ability[${SpellType[110]}].IsReady}
	{
		call CastSpellRange 110 0 1 3 ${mobid}
	}
	elseif ${Me.Ability[${SpellType[320]}].IsReady}
	{
		call CastSpellRange 320 0 0 0 ${mobid}
	}
	elseif ${Me.Ability[${SpellType[390]}].IsReady}
	{
		call CastSpellRange 323 0 0 0 ${mobid}
	}
}

function MA_Lost_Aggro()
{

}

function Cancel_Root()
{

}