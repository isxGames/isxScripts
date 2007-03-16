#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"

function Class_Declaration()
{
	call EQ2BotLib_Init

	declare WeaponMain string script	
	declare OffHand string script
	declare EquipmentChangeTimer int script	

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,""]}]
	
	
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
	MobHealth[2,1]:Set[20]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[20]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[50]
	SpellRange[2,2]:Set[59]

	Action[3]:Set[Stun]
	SpellRange[3,1]:Set[190]
	SpellRange[3,2]:Set[191]

	Action[4]:Set[Behind_Attack]
	SpellRange[4,1]:Set[100]
	SpellRange[4,2]:Set[104]

	Action[5]:Set[Damage_Debuff]
	SpellRange[5,1]:Set[80]
	SpellRange[5,2]:Set[84]
	
	Action[6]:Set[Melee_Attack]
	SpellRange[6,1]:Set[150]
	SpellRange[6,2]:Set[154]

	Action[7]:Set[AoE]
	SpellRange[7,1]:Set[95]
	SpellRange[7,2]:Set[96]

	Action[8]:Set[Flank_Attack]
	SpellRange[8,1]:Set[120]
	SpellRange[8,2]:Set[122]

	Action[9]:Set[Offense_Attack]
	SpellRange[9,1]:Set[303]
	SpellRange[9,2]:Set[305]

	Action[10]:Set[Lower_Hate]
	SpellRange[10,1]:Set[181]
	SpellRange[10,2]:Set[183]

	Action[12]:Set[Front_Attack]
	SpellRange[12,1]:Set[110]
	SpellRange[12,2]:Set[114]

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

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
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
			if ${Actor[${KillTarget},radius,2].Target.Name.Equal[${MainAssist}]} && ${Actor[${KillTarget}].Type.Equal[NPC]}
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
			xAction:Set[20]
			break
	}
}

function Combat_Routine(int xAction)
{

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow

	}

	if ${ShardMode}
	{
	
		Call Shard
	}	

	
	objHeroicOp:DoHO
		
	if !${EQ2.HOWindowActive} && ${Me.InCombat} && !${stealth}
	{
		call CastSpellRange 303	
	}


	

	switch ${Action[${xAction}]}
	{
		case Stealth_Attack
			echo stealth ${stealth} ************
			if ${stealth}
			{
				
				call CastSpellRange ${SpellRange[${xAction},1]} 1 1 ${KillTarget}
				stealth:Set[FALSE]

				call CastSpellRange 346
			}
			break
                 

		case Debuff
			echo debuff ***********
			;call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			;if ${Return.Equal[OK]}
			;{
				;call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				;if ${Return.Equal[OK]}
				;{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget}
				;}
			;}


			break
		case Damage_Debuff
			echo damage_debuff **********
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 1 ${KillTarget}
			break
		
			
		case Behind_Attack
			echo behind **************
			if !${disablebehind}
			{
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 1 ${KillTarget}
			}
			break

		case Melee_Attack
			echo melee ***************
			call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget}
			break

		case Flank_Attack
			echo flank **************
			if !${disablebehind} && ${Me.Ability[${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}].IsReady}
			{
				
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 1 ${KillTarget}
				waitframe
			}
			break

		case Offense_Attack
			echo offense *************
			if !${MainTank}
			{
			
				call CastCARange ${SpellRange[${xAction},1]} 1 3 ${KillTarget} 1 0 ${KillTarget}
			}
			break

		case Stun
			echo stun *************

			call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget}
			break

		case Lower_Hate
			echo lower hate **************
			if !${MainTank}
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget}
					if ${Me.AutoAttackOn}
					{
						EQ2Execute /toggleautoattack
					}
					wait 5
					call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget}
				}
			}
			break

		case AoE
			echo AOE *************
			if ${Mob.Count}>2
			{
				
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget}
			}
			break
		
		case Front_Attack
			echo Front_Attack *************
			{
			
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 2 ${KillTarget}
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

function CastCARange(int start, int finish, int xvar1, int xvar2, int targettobuff, int notall, int refreshtimer)
{
	variable bool fndspell
	variable int tempvar=${start}
	variable int originaltarget

	if ${Me.ToActor.Power}<5
	{
		return -1
	}

	do
	{
		if ${SpellType[${tempvar}].Length}
		{
			
			if ${Me.Ability[${SpellType[${tempvar}]}].IsReady}
			{
				if ${targettobuff}
				{
					fndspell:Set[FALSE]
					tempgrp:Set[1]
					do
					{
						if ${Me.Maintained[${tempgrp}].Name.Equal[${SpellType[${tempvar}]}]} && ${Me.Maintained[${tempgrp}].Target.ID}==${targettobuff} && (${Me.Maintained[${tempgrp}].Duration}>${refreshtimer} || ${Me.Maintained[${tempgrp}].Duration}==-1)
						{
							fndspell:Set[TRUE]
							break
						}
					}
					while ${tempgrp:Inc}<=${Me.CountMaintained}

					if !${fndspell}
					{
						if !${Actor[${targettobuff}](exists)} || ${Actor[${targettobuff}].Distance}>35
						{
							return -1
						}

						if ${xvar1} || ${xvar2}
						{
							;need less anal checkposition to keep from running around like an epilepic monkey
							call CheckPosition ${xvar1} ${xvar2}
						}

						if ${Target(exists)}
						{
							originaltarget:Set[${Target.ID}]
						}

						if ${targettobuff(exists)}
						{
							if !(${targettobuff}==${Target.ID}) && !(${targettobuff}==${Target.Target.ID} && ${Target.Type.Equal[NPC]}) 
							{
								target ${targettobuff}
								wait 10 ${Target.ID}==${targettobuff}
							}
						}

						call CastCA "${SpellType[${tempvar}]}" ${tempvar}

						if ${Actor[${originaltarget}](exists)}
						{
							target ${originaltarget}
							wait 10 ${Target.ID}==${originaltarget}
						}

						if ${notall}==1
						{
							return -1
						}
					}
				}
				else
				{
					if !${Me.Maintained[${SpellType[${tempvar}]}](exists)} || (${Me.Maintained[${SpellType[${tempvar}]}].Duration}<${refreshtimer} && ${Me.Maintained[${SpellType[${tempvar}]}].Duration}!=-1)
					{
						if ${xvar1} || ${xvar2}
						{
							call CheckPosition ${xvar1} ${xvar2}
						}

						call CastCA "${SpellType[${tempvar}]}" ${tempvar}

						if ${notall}==1
						{
							return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
						}
					}
				}
			}
		}

		if !${finish}
		{
			return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
		}
	}
	while ${tempvar:Inc}<=${finish}

	return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
}

function CastCA(string spell, int spellid)
{
	echo ${spell} 	
	Me.Ability[${spell}]:Use
	
	do
	{
		WaitFor "Fizzled!" "Interrupted!" "Too far away" "Can't see target" "Not during combat" "Would not take effect" "resisted" "No eligible target" "Not an enemy" "Target is not alive" 1

	}
	while ${WaitFor}==1 || ${WaitFor}==2

	switch ${WaitFor}
	{
		
		case 3
			return TOOFARAWAY

		case 4
			return CANTSEETARGET

		case 5
			return NOTDURINGCOMBAT

		case 6
			return NOTTAKEEFFECT

		case 7
			return RESISTED

		case 8
			return NOELIGIBLETARGET

		case 9
			return NOTENEMY

		case 10
			return TARGETNOTALIVE
	}
	
	do
	{
		waitframe
	}
	while ${Me.CastingSpell}
	
	return SUCCESS
}