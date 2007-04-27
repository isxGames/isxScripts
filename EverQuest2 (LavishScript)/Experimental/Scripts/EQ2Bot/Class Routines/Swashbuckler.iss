;*****************************************************
;Swashbuckler.iss 20070426a
;by Pygar
; First Pass
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare OffenseMode bool script 1
	declare AoEMode bool script 0
	declare SnareMode bool script 0
  declare TankMode bool script 0
  declare AnnounceMode bool script 0
  declare BuffLunge bool script 0
	declare MaintainPoison bool script 1
	declare DebuffPoisonShort string script
	declare DammagePoisonShort string script
	declare UtilityPoisonShort string script
	declare StartHO bool script 1

	;POISON DECLERATIONS - Still Experimental, but is working for these 3 for me.
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DammagePoisonShort:Set[caustic poison]
	DebuffPoisonShort:Set[enfeebling poison]
	UtilityPoisonShort:Set[ignorant bliss]


	;Custom Equipment
	declare WeaponRapier string script
	declare WeaponSword string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare OffHand string script
	declare WeaponMain string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	SnareMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Snares,FALSE]}]
	TankMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Try to Tank,FALSE]}]
	BuffHateGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHateGroupMember,]}]
	HuricaneMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Huricane,TRUE]}]
	BuffLunge:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Lunge Reversal,FALSE]}]
	MaintainPoison:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MaintainPoison,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]


	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	WeaponRapier:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Rapier",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]


}

function Buff_Init()
{

	PreAction[1]:Set[Foot_Work]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Bravado]
	PreSpellRange[2,1]:Set[26]

	PreAction[3]:Set[Offensive_Stance]
	PreSpellRange[3,1]:Set[291]

	PreAction[4]:Set[Avoid]
	PreSpellRange[4,1]:Set[27]

	PreAction[5]:Set[Deffensive_Stance]
	PreSpellRange[5,1]:Set[292]

	PreAction[6]:Set[Poisons]

	PreAction[7]:Set[AA_Lunge_Reversal]
	PreSpellRange[7,1]:Set[415]

	PreAction[8]:Set[AA_Evasiveness]
	PreSpellRange[8,1]:Set[417]

	PreAction[9]:Set[Huricane]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[BuffHate]
	PreSpellRange[10,1]:Set[40]
}

function Combat_Init()
{

	Action[1]:Set[Melee_Attack1]
	SpellRange[1,1]:Set[150]

	Action[3]:Set[Rear_Attack1]
	SpellRange[3,1]:Set[101]

	Action[2]:Set[Debuff1]
	Power[2,1]:Set[20]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[191]

	Action[3]:Set[AoE1]
	SpellRange[3,1]:Set[95]

	Action[4]:Set[AoE2]
	SpellRange[4,1]:Set[96]

	Action[5]:Set[AA_WalkthePlank]
	SpellRange[5,1]:Set[405]

	Action[6]:Set[Rear_Attack2]
	SpellRange[6,1]:Set[100]

	Action[7]:Set[Debuff2]
	Power[7,1]:Set[20]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[190]

	Action[8]:Set[Mastery]

	Action[9]:Set[Flank_Attack1]
	SpellRange[9,1]:Set[110]

	Action[10]:Set[Flank_Attack2]
	SpellRange[10,1]:Set[111]

	Action[11]:Set[Taunt]
	Power[11,1]:Set[20]
	Power[11,2]:Set[100]
	MobHealth[11,1]:Set[10]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[160]

	Action[12]:Set[Front_Attack]
	SpellRange[12,1]:Set[120]

	Action[13]:Set[Melee_Attack2]
	SpellRange[13,1]:Set[151]

	Action[14]:Set[Melee_Attack3]
	SpellRange[14,1]:Set[152]

	Action[15]:Set[Melee_Attack4]
	SpellRange[15,1]:Set[153]

	Action[16]:Set[Melee_Attack5]
	SpellRange[16,1]:Set[154]

	Action[17]:Set[Melee_Attack6]
	SpellRange[17,1]:Set[149]

	Action[18]:Set[Snare]
	Power[18,1]:Set[60]
	Power[18,2]:Set[100]
	SpellRange[18,1]:Set[235]

	Action[19]:Set[AA_Torporous]
	SpellRange[19,1]:Set[381]

	Action[20]:Set[AA_Traumatic]
	SpellRange[20,1]:Set[382]

	Action[21]:Set[AA_BootDagger]
	SpellRange[21,1]:Set[387]

}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare BuffTarget string local
	Call ActionChecks

	ExecuteAtom CheckStuck

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}
	switch ${PreAction[${xAction}]}
	{
		case Foot_Work
		case Bravado
		case AA_Evasiveness
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Offensive_Stance
			if ${OffenseMode} || !${TankMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Avoid
			if ${OffenseMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 33
			}
			if !${OffenseMode}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Deffensive_Stance
			if ${TankMode} && !${OffenseMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Poisons
			if ${MaintainPoison}
			{
				Me:CreateCustomInventoryArray[nonbankonly]
				if !${Me.Maintained[${DammagePoisonShort}](exists)} && ${Me.CustomInventory[${DammagePoisonShort}](exists)}
				{
					Me.CustomInventory[${DammagePoisonShort}]:Use
				}

				if !${Me.Maintained[${DebuffPoisonShort}](exists)} && ${Me.CustomInventory[${DebuffPoisonShort}](exists)}
				{
					Me.CustomInventory[${DebuffPoisonShort}]:Use
				}

				if !${Me.Maintained[${UtilityPoisonShort}](exists)} && ${Me.CustomInventory[${UtilityPoisonShort}](exists)}
				{
					Me.CustomInventory[${UtilityPoisonShort}]:Use
				}
			}
			break
		case AA_Lunge_Reversal
			if ${BuffLunge}
			{
				call CastCARange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Huricane
			if ${HuricaneMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
		case BuffHate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		Default
			xAction:Set[40]
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

	call WeaponChange

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	Call ActionChecks


	;if stealthed, use ambush
	if !${MainTank} && ${Me.ToActor.IsStealthed} && ${Me.Ability[${SpellType[130]}].IsReady}
	{
		call CastSpellRange 130 0 1 0 ${KillTarget} 0 0 1
	}

	;use best debuffs on target if epic
	if ${Actor[${KillTarget}].IsEpic}
	{
		if ${Me.Ability[${SpellType[150]}].IsReady}
		{
			call CastSpellRange 150 0 0 0 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[191]}].IsReady}
		{
			call CastSpellRange 191 0 0 0 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[381]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			if ${Me.Equipment[1].Name.Equal[${WeaponSword}]}
			{
				call CastSpellRange 381 0 1 1 ${KillTarget} 0 0 1
			}
			elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
			{
				Me.Inventory[${WeaponSword}]:Equip
				EquipmentChangeTimer:Set[${Time.Timestamp}]
				call CastSpellRange 381 0 1 1 ${KillTarget} 0 0 1
			}
		}

		if ${Me.Ability[${SpellType[382]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			if ${Me.Equipment[1].Name.Equal[${WeaponSword}]}
			{
				call CastSpellRange 382 0 1 1 ${KillTarget} 0 0 1
			}
			elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
			{
				Me.Inventory[${WeaponSword}]:Equip
				EquipmentChangeTimer:Set[${Time.Timestamp}]
				call CastSpellRange 382 0 1 1 ${KillTarget} 0 0 1
			}
		}

		if ${Me.Ability[${SpellType[101]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 101 0 1 1 ${KillTarget} 0 0 1
		}
	}

	;if heroic and over 80% health, use dps buffs
	if ${Actor[${KillTarget}].IsHeroic}
	{
		call CheckCondition MobHealth 80 100
		if ${Return.Equal[OK]}
		{
			if ${Me.Ability[${SpellType[155]}].IsReady}
			{
				call CastSpellRange 155 158 0 0 ${KillTarget} 0 0 1
			}
		}
	}

	;if heroic and under 80% health use dps run
	if ${Actor[${KillTarget}].IsHeroic} &&  ${Actor[${KillTarget}].Health}<80
	{
		if ${Me.Ability[${SpellType[157]}].IsReady}
		{
			call CastSpellRange 155 158 1 0 ${KillTarget} 0 0 1
			wait 30
			call CastSpellRange 151 0 1 0 ${KillTarget} 0 0 1
			wait 30
			call CastSpellRange 153 0 1 0 ${KillTarget} 0 0 1
			wait 40
		}
	}


	switch ${Action[${xAction}]}
	{
		case Melee_Attack1
		case Melee_Attack2
		case Melee_Attack3
		case Melee_Attack4
		case Melee_Attack5
		case Melee_Attack6
			call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AoE1
		case AoE2
			if ${AoEMode} && ${Mob.Count}>=2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		case Snare
			if ${SnareMode}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
				}
			}
			break
		case Rear_Attack1
		case Rear_Attack2
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			elseif ${Target.Target.ID}!=${Me.ID}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
			}
			break
		case Mastery
			if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
			{
				if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
					call CheckPosition 1 1
					Me.Ability[Sinister Strike]:Use
				}
			}
			break
		case AA_WalkthePlank
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${Me.Equipment[1].Name.Equal[${WeaponRapier}]}
				{
					call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponRapier}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}

			}
			break
		case AA_Torporous
		case AA_Traumatic
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${Me.Equipment[1].Name.Equal[${WeaponSword}]}
				{
					call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponSword}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}

			}
			break
		case AA_BootDagger
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${Me.Equipment[1].Name.Equal[${WeaponDagger}]}
				{
					call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponDagger}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}

			}
			break

		case Flank_Attack1
		case Flank_Attack2
			;check valid rear position
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			;check right flank
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			;check left flank
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			elseif ${Target.Target.ID}!=${Me.ID}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget}
			}
		case Debuff
		case Taunt
			if ${TankMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			break
		case Front_Attack
			;check right flank
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			;check left flank
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			;check front
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>125 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<235) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-235 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-125)
			{

			}
			elseif ${Target.Target.ID}!=${Me.ID}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget}
			}
			else
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 2 ${KillTarget}
			}
			break

		case Stun
			if !${Target.IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		default
			xAction:Set[40]
			break
	}
}

function Post_Combat_Routine()
{
	if ${Me.Maintained[Stealth](exists)}
	{
		Me.Maintained[Stealth]:Cancel
	}
}

function Have_Aggro()
{

	echo I have agro from ${agroid}
	if ${OffenseMode} && ${Me.Ability[${SpellType[388]}].IsReady} && ${agroid}>0
	{
		;Feign
		call CastSpellRange 388 0 1 0 ${agroid} 0 0 1
	}
	elseif ${agroid}>0
	{
		if ${Me.Ability[${SpellType[185]}].IsReady}
		{
			;agro dump
			call CastSpellRange 185 0 1 0 ${agroid} 0 0 1
		}
		else
		{
			call CastSpellRange 181 0 1 0 ${agroid} 0 0 1
		}

	}
}

function Lost_Aggro()
{
	if ${Target.Target.ID}!=${Me.ID}
	{
		if ${TankMode}
		{
			call CastSpellRange 100 101 1 1 ${KillTarget} 0 0 1
			call CastSpellRange 160 0 1 0 ${KillTarget} 0 0 1
		}
	}

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
function CheckHeals()
{

}

function ActionChecks()
{
	call UseCrystallizedSpirit 60

	if ${ShardMode}
	{
		call Shard
	}
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

