;*************************************************************
;Guardian.iss 20070404a
;version
;by Pygar
;
;20070404a
;	Updated for latest eq2bot
;
;
;20061101a
;	initial build
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare DragoonsCycloneMode bool Script FALSE

	declare BuffAvoidanceGroupMember string script
	declare BuffSentinelGroupMember string script
	declare BuffDeagroGroupMember string script

	declare WeaponHammer string script
	declare WeaponSword string script
	declare WeaponSpear string script
	declare TowerShield string script
	declare WeaponAxe string script
	declare WeaponMain string script
	declare OffHand string script
	declare EquipmentChangeTimer int script


	call EQ2BotLib_Init

	FullAutoMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Full Auto Mode,FALSE]}]
	TauntMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Defensive Spells,TRUE]}]
	OffensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DragoonsCycloneMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Dragoons Cyclone,FALSE]}]

	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]

	BuffAvoidanceGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAvoidanceGroupMember,]}]
	BuffSentinelGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSentinelGroupMember,]}]
	BuffDeagroGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffDeagroMember,]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	WeaponHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Hammer",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Spear",""]}]
	TowerShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["TowerShield",""]}]
	WeaponAxe:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Axe",""]}]

}


function Buff_Init()
{
   PreAction[1]:Set[Avoidance_Target]
   PreSpellRange[1,1]:Set[30]

   PreAction[2]:Set[Self_Buff]
   PreSpellRange[2,1]:Set[25]
   PreSpellRange[2,2]:Set[26]

   PreAction[3]:Set[Group_Buff]
   PreSpellRange[3,1]:Set[20]
   PreSpellRange[3,2]:Set[21]
   PreSpellRange[3,3]:Set[22]

   PreAction[4]:Set[AA_DragoonsCyclone]
   PreSpellRange[4,1]:Set[29]

   PreAction[5]:Set[Sentinel_Target]
   PreSpellRange[5,1]:Set[31]

   PreAction[6]:Set[Deagro_Target]
   PreSpellRange[6,1]:Set[32]

}

function Combat_Init()
{
   Action[1]:Set[AoE_Taunt]
   SpellRange[1,1]:Set[170]
   SpellRange[1,2]:Set[171]

   Action[2]:Set[Taunt1]
   SpellRange[2,1]:Set[160]

   Action[3]:Set[Taunt2]
   SpellRange[3,1]:Set[161]

   Action[4]:Set[Combat_Buff1]
   SpellRange[4,1]:Set[155]

   Action[5]:Set[Combat_Buff2]
   SpellRange[5,1]:Set[156]

   Action[6]:Set[AoE]
   Power[6,1]:Set[20]
   Power[6,2]:Set[100]
   SpellRange[6,1]:Set[95]

   Action[7]:Set[AoE2]
   Power[7,1]:Set[20]
   Power[7,2]:Set[100]
   SpellRange[7,1]:Set[96]

   Action[8]:Set[PBAoE]
   Power[8,1]:Set[20]
   Power[8,2]:Set[100]
   SpellRange[8,1]:Set[172]

   Action[9]:Set[Damage_Debuff]
   MobHealth[9,1]:Set[5]
   MobHealth[9,2]:Set[100]
   Power[9,1]:Set[20]
   Power[9,2]:Set[100]
   SpellRange[9,1]:Set[80]
   SpellRange[9,2]:Set[81]
   SpellRange[9,3]:Set[82]

   Action[10]:Set[Melee_Attack]
   Power[10,1]:Set[5]
   Power[10,2]:Set[100]
   SpellRange[10,1]:Set[150]
   SpellRange[10,2]:Set[151]
   SpellRange[10,3]:Set[152]
   SpellRange[10,4]:Set[153]
   SpellRange[10,5]:Set[154]

   Action[12]:Set[Shield_Attack]
   Power[12,1]:Set[5]
   Power[12,2]:Set[100]
   SpellRange[12,1]:Set[240]

   Action[13]:Set[Belly_Smash]
   Power[13,1]:Set[5]
   Power[13,2]:Set[100]
   SpellRange[13,1]:Set[400]

   Action[14]:Set[ThermalShocker]

}

function PostCombat_Init()
{
   PostAction[1]:Set[Cancel_Root]
   PostSpellRange[1,1]:Set[172]

   PostAction[2]:Set[AA_BindWound]
   PostSpellRange[2,1]:Set[398]

   PostAction[3]:Set[AA_AccelterationStrike]
   PostSpellRange[3,1]:Set[399]

}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	variable int temp

	call WeaponChange

	if ${ShardMode}
	{
		call Shard
	}

	switch ${PreAction[${xAction}]}
	{

		case Avoidance_Target
			BuffTarget:Set[${UIElement[cbBuffAvoidanceGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case AA_DragoonsCyclone
			if ${DragoonsCycloneMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Sentinel_Target
			BuffTarget:Set[${UIElement[cbBuffSentinelGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Deagro_Target
			BuffTarget:Set[${UIElement[cbBuffDeagroGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
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
			xAction:Set[20]
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

	;The following till FullAuto could be nested in FullAuto, but I think bot control of these abilities is better
	call CheckHeals

	if ${Me.ToActor.Health}<60
	{
		call CastSpellRange 156
	}

	if ${Me.ToActor.Health}<40
	{
		call CastSpellRange 155
	}

	if ${Me.ToActor.Health}<20
	{
		if ${Me.Equipment[2].Name.Equal[${TowerShield}]}
		{
			call CastSpellRange 322 0 1 0 ${KillTarget}
		}
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
		{
			Me.Inventory[${TowerShield}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 322 0 1 0 ${KillTarget}
		}
	}

	;echo in combat
	if ${FullAutoMode}
	{

		switch ${Action[${xAction}]}
		{

			case Taunt1
				if ${TauntMode}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				break

			case Taunt2
				if ${TauntMode} && ${OffensiveMode}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				break

			case AoE_Taunt
				if ${TauntMode} && ${Mob.Count}>1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget} 0 0 1
				}
				break

			case Damage_Debuff
				if ${OffensiveMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 1 0 ${KillTarget} 0 0 1
						}
					}
				}
				break

			case AoE2
				if ${OffensiveMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${Mob.Count}>2
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Me.Equipment[1].Name.Equal[${WeaponSpear}]}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
						}
						elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
						{
							Me.Inventory[${WeaponSpear}]:Equip
							EquipmentChangeTimer:Set[${Time.Timestamp}]
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
						}
					}
				}
				break
			case AoE
				if ${AoEMode} && ${Mob.Count}>2
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
				break
			case PBAoE
				if ${PBAoEMode} && ${Mob.Count}>3
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
				break
			case Melee_Attack
				if ${OffensiveMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},5]} 1 0 ${KillTarget} 0 0 1
					}
				}
				break

			case Shield_Attack
				if ${OffensiveMode}
				{
					If ${Me.Equipment[Secondary].Type.Equal[Shield]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
						}
					}
				}
				break

			case Belly_Smash
				if ${OffensiveMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Me.Equipment[1].Name.Equal[${WeaponHammer}]}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
						}
						elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
						{
							Me.Inventory[${WeaponHammer}]:Equip
							EquipmentChangeTimer:Set[${Time.Timestamp}]
							call CastSpellRange 240 0 1 0 ${KillTarget}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
						}
					}
				}
				break
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				}
				break
			case default
				;xAction:Set[20]
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{

		case Cancel_Root
			 if ${Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}](exists)}
			 {
			    Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			 }
			break

		case AA_AccelterationStrike
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
			{
				if ${Me.Equipment[1].Name.Equal[${WeaponSword}]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponSword}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastSpellRange ${SpellRange[${xAction},1]}
				}
			}
			break

		case AA_BindWound
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PostSpellRange[${xAction},1]}
			}
			break

		case Default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{

}

function Lost_Aggro(int mobid)
{
	if ${FullAutoMode}
	{
		if ${TauntMode}
		{
			;intercept damage on the person now with agro
			call CastSpellRange 270
			;Use Reinforcement to get back to top of agro tree else use taunts
			if ${Me.Ability[${SpellType[321]}].IsReady}
			{
				call CastSpellRange 321
			}
			else
			{
				call CastSpellRange 160 161
			}


			;use rescue if new agro target is under 65 health
			if ${Me.ToActor.Target.Target.Health}<65
			{
				call CastSpellRange 320 0 0 0 ${mobid}
			}
		}
	}
}

function MA_Lost_Aggro()
{


}

function MA_Dead()
{
	MainTank:Set[TRUE]
	MainTankPC:Set[${Me.Name}]
	KillTarget:Set[]
}

function Cancel_Root()
{

}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare MTinMyGroup bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	if ${Me.Ability[${SpellType[316]}].IsReady} || ${Me.Ability[${SpellType[271]}].IsReady}
	{
		do
		{
			if ${Me.Group[${temphl}].ZoneName.Equal["${Zone.Name}"]}
			{

				if ${Me.Group[${temphl}].ToActor.Health} < 100 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor(exists)}
				{
					if ${Me.Group[${temphl}].ToActor.Health} < ${Me.Group[${lowest}].ToActor.Health}
					{
						lowest:Set[${temphl}]
					}
				}

				if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<60
				{
					grpheal:Inc
				}

				if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
				{
					MTinMyGroup:Set[TRUE]
				}
			}

		}
		while ${temphl:Inc}<${grpcnt}
	}
	;MAINTANK EMERGENCY Mitigation
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call CastSpellRange 317
		call CastSpellRange 155 156
	}

	;GROUP HEALS
	if ${grpheal}>1
	{
		if ${Me.Ability[${SpellType[316]}].IsReady}
		{
			call CastSpellRange 316
		}
		if ${Me.Ability[${SpellType[271]}].IsReady}
		{
			call CastSpellRange 271
		}
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
