function Class_Declaration()
{
 
}
 
function Buff_Init()
{
	PreAction[1]:Set[Single_Buff_Conc]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[Tank_Buff]
	PreSpellRange[3,1]:Set[40]
	PreSpellRange[3,2]:Set[41]

	PreAction[4]:Set[Group_Buff_Conc]
	PreSpellRange[4,1]:Set[20]
	PreSpellRange[4,2]:Set[23]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[280]
	PreSpellRange[5,2]:Set[282]

	PreAction[6]:Set[Resurrection]
	PreSpellRange[6,1]:Set[300]
	PreSpellRange[6,2]:Set[301]
}
 
function Combat_Init()
{
	Action[1]:Set[Slow_Debuff]
	MobHealth[1,1]:Set[30]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[50]

	Action[2]:Set[Curse]
	MobHealth[2,1]:Set[40]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[40]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[371]

	Action[3]:Set[Proc_Ward]
	MobHealth[3,1]:Set[40]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[40]
	Power[3,2]:Set[100]
	SpellRange[3,1]:Set[322]

	Action[4]:Set[Debuff]
	MobHealth[4,1]:Set[50]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[60]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[51]
	SpellRange[4,2]:Set[53]

	Action[5]:Set[Soul_Essence]
	MobHealth[5,1]:Set[50]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[323]

	Action[6]:Set[AoE]
	SpellRange[6,1]:Set[90]
	SpellRange[6,2]:Set[91]

	Action[7]:Set[Dot]
	MobHealth[7,1]:Set[50]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[60]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[70]
	SpellRange[7,2]:Set[71]

	Action[8]:Set[Damage_Debuff]
	MobHealth[8,1]:Set[50]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[60]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[80]
	SpellRange[8,2]:Set[81]

	Action[9]:Set[Nuke]
	Power[9,1]:Set[60]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[60]
}
 
function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]
}
 
function Buff_Routine(int xAction)
{
	call CheckHeals
	if ${Me.ToActor.Power}>85 && ${KeepReactive}
	{
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
	}

	switch ${PreAction[${xAction}]}
	{
		case Single_Buff_Conc
			if ${Me.UsedConc}<5
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			}

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
					case crusader
					case paladin
					case shadowknight
						if ${Me.Group[${tempgrp}].ID}!=${Actor[${MainAssist}].ID}
						{
							if ${Me.UsedConc}<5
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
							}
							return
						}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}

			if ${tempgrp}==${grpcnt}
			{
				if ${Me.UsedConc}<5
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
				}
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Tank_Buff 
			if ${Actor[${MainAssist}](exists)} 
			{ 
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${MainAssist}].ID} 
			} 
			break 

		case Group_Buff_Conc
			if ${Me.UsedConc}<5
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break

		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.Health}<=0 && ${Me.Group[${tempgrp}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		Default
			xAction:Set[20]
			break
	}
}
 
function Combat_Routine(int xAction)
{
	call CheckHeals

	if ${hurt} && !${MainTank}
	{
		return
	}

	switch ${Action[${xAction}]}
	{
		case Slow_Debuff
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
			{
				call CastSpellRange 303
			}

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

		case Curse
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					if ${Mob.Count}<3
					{
						call CastSpellRange ${SpellRange[${xAction},1]}
					}
				}
			}
			break

		case Proc_Ward
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					if ${Mob.Count}<3
					{
						call CastSpellRange ${SpellRange[${xAction},1]}
					}
				}
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

		case Soul_Essence
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckHealerMob
				if ${Return}
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break

		case AoE
			if ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Dot
		case Damage_Debuff
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

		case Nuke
			if !${Actor[NamedNPC,range,15](exists)}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
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
 
function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.Health}<=0 && ${Me.Group[${tempgrp}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		Default
			xAction:Set[20]
			break
	}
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
 
function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	do
	{
		currenthealth[${temphl}]:Set[${Me.Group[${temphl}].ToActor.Health}]
		changehealth[${temphl}]:Set[${Math.Calc[${oldhealth[${temphl}]}-${currenthealth[${temphl}]}]}]
		oldhealth[${temphl}]:Set[${currenthealth[${temphl}]}]

		if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>0 && ${Me.Group[${temphl}](exists)}
		{
			if "${Me.Group[${temphl}].ToActor.Health}<=${If[${Me.Group[${lowest}].ToActor.Health},${Me.Group[${lowest}].ToActor.Health},100]}"
			{
				lowest:Set[${temphl}]
			}
		}

		if ${Me.Group[${temphl}].ToActor.Health}>50 && ${Me.Group[${temphl}].ToActor.Health}<75
		{
			grpheal:Inc
		}

		if ${Me.Group[${temphl}].ToActor.Health}>85
		{
			chgcnt[${temphl}]:Set[0]
			healthtimer[${temphl}]:Set[${Time.Timestamp}]
		}
	}
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<75 && ${Me.ToActor.Health}>50
	{
		grpheal:Inc
	}

	if ${grpheal}>2
	{
		call CastSpellRange 10
		call CastSpellRange 15
		return
	}

	if ${Actor[${MainAssist}].Health}<80 && !${Me.InCombat}
	{
		call CastSpellRange 4 5 0 0 ${Actor[${MainAssist}].ID} 1
		return
	}

	if ${Me.ToActor.Health}<=${If[${Me.Group[${lowest}].ToActor.Health},${Me.Group[${lowest}].ToActor.Health},100]}
	{
		if ${Me.ToActor.Health}<70		
		{
			if ${haveaggro}
			{
				call EmergencyHeal ${Me.ID}
			}
			else
			{
				if ${Me.Ability[${SpellType[1]}].IsReady}
				{
					call CastSpellRange 1 2 0 0 ${Me.ID} 1
				}
				else
				{
					call CastSpellRange 4 5 0 0 ${Me.ID} 1
				}
			}
			hurt:Set[TRUE]
		}
		else
		{
			if ${Me.ToActor.Health}<80
			{
				if ${haveaggro}
				{
					call CastSpellRange 7 8 0 0 ${Me.ID} 1
				}
				else
				{
					call CastSpellRange 4 5 0 0 ${Me.ID} 1
				}
			}
		}
		return
	}

	if !${lowest}
	{
		return
	}

	if ${Me.Group[${lowest}].ToActor.Health}<40
	{
		call CastSpellRange 324 0 0 0 ${Me.Group[${lowest}].ID}

		if ${Me.Ability[${SpellType[321]}].IsReady}
		{
			call CastSpellRange 321 0 0 0 ${Me.Group[${lowest}].ID}
		}
		elseif ${Me.Ability[${SpellType[320]}].IsReady}
		{
			call CastSpellRange 320 0 0 0 ${Me.Group[${lowest}].ID}
		}
		hurt:Set[TRUE]
	}

	if ${Me.Group[${lowest}].ToActor.Health}<80 && ${changehealth[${lowest}]}>25
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 2 0 0 ${Me.Group[${lowest}].ID} 1
			wait 5
			if ${Me.Group[${lowest}].ToActor.Health}<70
			{
				call CastSpellRange 4 5 0 0 ${Me.Group[${lowest}].ID} 1
			}
		}
		else
		{
			call CastSpellRange 4 5 0 0 ${Me.Group[${lowest}].ID} 1
		}
		hurt:Set[TRUE]
	}
 
	if ${Me.Group[${lowest}].ToActor.Health}<70 && ${Math.Calc[${Time.Timestamp}-${healthtimer[${lowest}]}]}>6 && ${Me.InCombat} && ${Me.Group[${lowest}].ToActor.Distance}<20
	{
		if !${Me.Ability[${SpellType[15]}].IsReady}
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 4 5 0 0 ${Me.Group[${lowest}].ID} 1
			}
			else
			{
				call CastSpellRange 1 2 0 0 ${Me.Group[${lowest}].ID} 1
			}
		}
		else
		{
			call CastSpellRange 15
		}
		hurt:Set[TRUE]
	}

	if ${changehealth[${lowest}]}>0 || ${Me.Group[${lowest}].ToActor.Health}<65
	{
		chgcnt[${lowest}]:Inc
		if ${Me.Group[${lowest}].ToActor.Health}<60 && ${changehealth[${lowest}]}>20
		{
			call EmergencyHeal ${Me.Group[${lowest}].ID}
			hurt:Set[TRUE]
			return
		}

		if ${Me.Group[${lowest}].ToActor.Health}<55
		{
			call CastSpellRange 7 8 0 0 ${Me.Group[${lowest}].ID} 1

			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 1 2 0 0 ${Me.Group[${lowest}].ID} 1
			}
			else
			{
				call CastSpellRange 4 5 0 0 ${Me.Group[${lowest}].ID} 1
			}
			hurt:Set[TRUE]
		}

		if ${chgcnt[${lowest}]}<3
		{
			return
		}

		if ${Me.Group[${lowest}].ToActor.Health}<80
		{
			call CastSpellRange 7 8 0 0 ${Me.Group[${lowest}].ID} 1
		}
	}
	else
	{
		if ${Math.Calc[${Time.Timestamp}-${healthtimer[${lowest}]}]}>5 && ${Math.Calc[${Time.Timestamp}-${healthtimer[${lowest}]}]}<60 && ${Me.Group[${lowest}].ToActor.Health}<80 && ${Me.Group[${lowest}].ToActor.Health}>0
		{
			tempgrp:Set[1]
			do
			{
				if ${Me.Maintained[${tempgrp}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempgrp}].Target.ID}==${Me.Group[${lowest}].ID} || ${Me.Maintained[${SpellType[15]}](exists)}
				{
					return
				}
			}
			while ${tempgrp:Inc}<=${Me.CountMaintained}

			call CastSpellRange 1 2 0 0 ${Me.Group[${lowest}].ID} 1
			return
		}

		if ${Math.Calc[${Time.Timestamp}-${healthtimer[${lowest}]}]}>20 && ${Math.Calc[${Time.Timestamp}-${healthtimer[${lowest}]}]}<60 && ${Me.Group[${lowest}].ToActor.Health}<80 && ${Me.Group[${lowest}].ToActor.Health}>0
		{
			call CastSpellRange 4 5 0 0 ${Me.Group[${lowest}].ID} 1
		}
	}
}

function EmergencyHeal(int healtarget)
{
	switch ${Actor[${healtarget}].Class}
	{
		case templar
		case inquisitor
		case fury
		case warden
		case defiler
		case mystic
		case coercer
		case illusionist
		case warlock
		case wizard
		case conjuror
		case necromancer
			call CastSpellRange 7 8 0 0 ${healtarget} 1
			waitframe
			call CastSpellRange 1 2 0 0 ${healtarget} 1
			break
 
		Default
			call CastSpellRange 7 8 0 0 ${healtarget} 1
			waitframe
			call CastSpellRange 4 5 0 0 ${healtarget} 1
			waitframe
			call CastSpellRange 15
			break
	}

	if ${Actor[${healtarget}].Health}<50
	{
		call CastSpellRange 4 5 0 0 ${healtarget} 1
		call CastSpellRange 7 8 0 0 ${healtarget} 1
	}
}

function CheckHealerMob()
{
	declare tcount int local 2

	EQ2:CreateCustomActorArray[byDist,15]
	do
	{
		if (${CustomActor[${tcount}].Type.Equal[NPC]} || (${CustomActor[${tcount}].Type.Equal[NamedNPC]} && ${AttackNamed})) && ${Actor[${CustomActor[${tcount}].ID}](exists)} && !${CustomActor[${tcount}].IsLocked} && ${Math.Calc[${Me.Y}+10]}>=${CustomActor[${tcount}].Y} && ${Math.Calc[${Me.Y}-10]}<=${CustomActor[${tcount}].Y} && ${CustomActor[${tcount}].InCombatMode}
		{
			switch ${CustomActor[${tcount}].Class}
			{			
				case templar
				case inquisitor
				case fury
				case warden
				case defiler
				case mystic
					return TRUE
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	return FALSE
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
 