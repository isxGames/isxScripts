#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"

function Class_Declaration()
{
	
	declare WeaponMain string script	
	declare OffHand string script
	declare EquipmentChangeTimer int script	

	call EQ2BotLib_Init

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[29]

	PreAction[2]:Set[Group_Buff]
	PreSpellRange[2,1]:Set[20]
	PreSpellRange[2,2]:Set[24]

	PreAction[3]:Set[Tank_Buff]
	PreSpellRange[3,1]:Set[40]
	PreSpellRange[3,2]:Set[49]

	PreAction[4]:Set[Stealth]
	PreSpellRange[4,1]:Set[201]

	PreAction[5]:Set[Fight_Stance]
	PreSpellRange[5,1]:Set[290]
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
	SpellRange[2,2]:Set[59]

	Action[3]:Set[Behind_Attack]
	SpellRange[3,1]:Set[100]
	SpellRange[3,2]:Set[104]

	Action[4]:Set[Damage_Debuff]
	SpellRange[4,1]:Set[80]
	SpellRange[4,2]:Set[84]
	
	Action[5]:Set[Melee_Attack]
	SpellRange[5,1]:Set[150]
	SpellRange[5,2]:Set[154]

	Action[6]:Set[Dot]
	SpellRange[6,1]:Set[70]
	SpellRange[6,2]:Set[74]

	Action[7]:Set[Flank_Attack]
	SpellRange[7,1]:Set[120]
	SpellRange[7,2]:Set[122]

	Action[8]:Set[Offense_Attack]
	SpellRange[8,1]:Set[303]
	SpellRange[8,2]:Set[305]

	Action[9]:Set[Lower_Hate]
	SpellRange[9,1]:Set[181]
	SpellRange[9,2]:Set[182]

	Action[10]:Set[AoE]
	SpellRange[10,1]:Set[90]
	SpellRange[10,2]:Set[92]

	Action[11]:Set[Stun]
	SpellRange[11,1]:Set[190]
	SpellRange[11,2]:Set[191]

}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	call WeaponChange

	if ${ShardMode}
	{
		
		call Shard
	}


	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
	
		case Tank_Buff
		
			if ${Actor[${MainAssist}](exists)}
			{
			    call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${MainAssist}].ID}
			}
			break

		case Stealth
			if ${Actor[${KillTarget},radius,10].Target.Name.Equal[${MainAssist}]} && ${Actor[${KillTarget}].Type.Equal[NPC]}
			{
				if ${following}
				{
					FollowTask:Set[2]
				}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 1
				stealth:Set[TRUE]
			}
			break

		Default
			xAction:Set[10]
			break
	}
}

function Combat_Routine(int xAction)
{
	if ${DoHOs}
	{
		
		objHeroicOp:DoHO
	}
	
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	switch ${Action[${xAction}]}
	{
		case Stealth_Attack
			if ${stealth}
			{
				face ${Target.X} ${Target.Z}
				waitframe
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
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
				}
			}


			break
		case Damage_Debuff
			
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			break
		
			
		case Behind_Attack
			if !${disablebehind}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 1
			}
			break

		case Melee_Attack
			
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
			break

		case Flank_Attack
			if !${disablebehind}
			{
				
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 3
				waitframe
			}
			break

		case Offense_Attack
			if !${MainTank}
			{
			
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1
			}
			break

		case Stun
			

			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
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

		case Lower_Hate
			if !${MainTank}
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
					if ${Me.AutoAttackOn}
					{
						EQ2Execute /toggleautoattack
					}
					wait 5
					call CastSpellRange ${SpellRange[${xAction},2]}
				}
			}
			break

		case AoE
			
			if ${Return}>2
			{
				
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1
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
		call CastSpellRange 200
	}
	elseif ${Me.Maintained[${SpellType[200]}](exists)}
	{
		Me.Maintained[${SpellType[200]}]:Cancel
	}

	if !${homepoint}
	{
		return
	}

	if !${avoidhate} && !${Me.Maintained[${SpellType[180]}](exists)} && ${Actor[${aggroid}].Distance}<5
	{
	
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

function Cancel_Root()
{

}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}	

	;equip off hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal[${OffHand}]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory[${OffHand}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}
