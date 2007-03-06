;*************************************************************
;Coercer.iss
;version 20061011a
;by karye
;Fixed a bug with Buff settings not saving after zoning/restarting EQ2Bot
;Fixed a bug with ManaFlow and Channel if group members are not in zone
;*************************************************************

#includeoptional "\\Athena\innerspace\Scripts\EQ2Bot\Class Routines\EQ2BotLib.iss"

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare MezzMode bool script FALSE
	declare Charm bool script FALSE
	declare BuffInstigation bool script FALSE
	declare BuffSignet bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffHateGroupMember string script
	
	declare CharmTarget int script
	
	;Custom Equipment
	declare WeaponStaff string script 
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script
	declare OffHand string script
	
	call EQ2BotLib_Init


	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffHateGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHateGroupMember,]}]
	BuffHate:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHate,FALSE]}]
	BuffInstigation:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffInstigation,,FALSE]}]
	BuffSignet:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSignet,FALSE]}]
	
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	Charm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Charm,FALSE]}]
	
	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	WeaponStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Staff",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]		

}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Instigation]
	PreSpellRange[2,1]:Set[20]
	
	PreAction[3]:Set[Hate]
	PreSpellRange[3,1]:Set[40]
	
	PreAction[4]:Set[AntiHate]
	PreSpellRange[4,1]:Set[41]
	
	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[35]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]
	
	PreAction[7]:Set[Signet]
	PreSpellRange[7,1]:Set[21]
	
	PreAction[8]:Set[Clarity]
	PreSpellRange[8,1]:Set[22]
}

function Combat_Init()
{

		
	Action[2]:Set[AoE_PB]
	SpellRange[2,1]:Set[95]
	
	Action[3]:Set[Lash]
	MobHealth[3,1]:Set[60] 
	MobHealth[3,2]:Set[100] 
	SpellRange[3,1]:Set[92]
	
	Action[4]:Set[Gaze]
	MobHealth[4,1]:Set[1] 
	MobHealth[4,2]:Set[40] 
	SpellRange[4,1]:Set[90]
	
	Action[5]:Set[Ego]
	SpellRange[5,2]:Set[91]

	Action[6]:Set[Master_Strike]

	Action[7]:Set[Despair]
	MobHealth[7,1]:Set[1] 
	MobHealth[7,2]:Set[100] 	
	SpellRange[7,1]:Set[80]


	Action[9]:Set[Mind]
	MobHealth[9,1]:Set[40] 
	MobHealth[9,2]:Set[100] 	
	SpellRange[9,1]:Set[72]
	
	Action[10]:Set[Anguish]
	MobHealth[10,1]:Set[1] 
	MobHealth[10,2]:Set[100] 
	SpellRange[10,1]:Set[70]

	
	Action[11]:Set[Thoughts]
	MobHealth[11,1]:Set[40] 
	MobHealth[11,2]:Set[100] 
	SpellRange[11,1]:Set[51]
	
	Action[12]:Set[Nuke]
	SpellRange[12,1]:Set[60]
		
	Action[13]:Set[Stun]
	SpellRange[13,1]:Set[190]	
		
	Action[14]:Set[Silence]
	MobHealth[14,1]:Set[1] 
	MobHealth[14,2]:Set[100] 
	SpellRange[14,1]:Set[260]

	Action[15]:Set[AEStun]
	MobHealth[15,1]:Set[1] 
	MobHealth[15,2]:Set[100] 
	SpellRange[15,1]:Set[191]
	
	Action[16]:Set[Daze]
	MobHealth[16,1]:Set[1] 
	MobHealth[16,2]:Set[100] 
	SpellRange[16,1]:Set[260]
	
	Action[17]:Set[ProcStun]
	MobHealth[17,1]:Set[1] 
	MobHealth[17,2]:Set[100] 
	SpellRange[17,1]:Set[192]	
	
}

function PostCombat_Init()
{
	;PostAction[1]:Set[]
	;PostSpellRange[1,1]:Set[]
	
	PostAction[1]:Set[LoadDefaultEquipment]	
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	
	call CheckHeals
	call RefreshPower
	call DestroyThoughtstones
	ExecuteAtom CheckStuck
	
	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}
			
	switch ${PreAction[${xAction}]}
	{
			
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Clarity
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Signet
			if ${BuffSignet}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Instigation
			if ${BuffInstigation}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break			
		case Hate
			
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			
			
			if ${BuffHate}
			{

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case AntiHate
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{				

							BuffTarget:Set[${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
							
							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
							
							
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}
				
			}
			while ${Counter:Inc}<=${Me.CountMaintained} 			
			

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{				
					BuffTarget:Set[${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break		
		case Melee_Buff
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{				

							BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
							
							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
							
							
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}
				
			}
			while ${Counter:Inc}<=${Me.CountMaintained} 			
			

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{				
					BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break	

		case SeeInvis
			if ${BuffSeeInvis}
			{
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ToActor.ID}
				
				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
					}

				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break

		default
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
	
	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}
	
	;if !${EQ2.HOWindowActive} && ${Me.InCombat}
	;{
	;	call CastSpellRange 303
	;}
	
	if ${MezzMode}
	{
		call Mezmerise_Targets
	}
	
	if ${Charm}
	{
		call DoCharm
	}
	
	call DoAmnesia
	
	ExecuteAtom PetAttack
	
	call CheckHeals
	
	if ${ShardMode}
	{
		call Shard
	}
	
	call RefreshPower
	
	if !${Me.Maintained[${SpellType[]}](exists)}
	{
		
		call CastSpellRange X 0 0 0 ${KillTarget}
	}
	
	;chronsphioning AA. we should always try to keep this spell up
	if ${Me.Ability[${SpellType[382]}](exists)} && ${Me.Ability[${SpellType[382]}].IsReady}
	{
		;if we have a dual wield or a 1hander and nothing in our secondary we are good to go
		if (${Me.Equipment[1].WieldStyle.Find[Dual Wield]} || ${Me.Equipment[1].WieldStyle.Find[One-Handed]}) && !${Me.Equipment[2](exists)}
		{
			call CastSpellRange 382 0 0 0 ${KillTarget}
		}
		;if we have a dual wield or a 1hander but have something in our secondary well remove it
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2 && (${Me.Equipment[1].WieldStyle.Find[Dual Wield]} || ${Me.Equipment[1].WieldStyle.Find[One-Handed]}) && ${Me.Equipment[2](exists)}
		{
			Me.Equipment[2]:UnEquip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 382 0 0 0 ${KillTarget}
		}
		;if we have nothing in our primary or a 2 hander we will swap in the AA dagger which we assume to be 1h or dual weild
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2 && !${Me.Equipment[2](exists)}
		{
			Me.Inventory[${WeaponDagger}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 382 0 0 0 ${KillTarget}		
		}
	}
	
	;make sure killtarget is always Arcane debuffed
	call CastSpellRange 50 0 0 0 ${KillTarget}
	
	;make sure Convulsion procs are always on kill target for optimum dps
	call CastSpellRange 71 0 0 0 ${KillTarget}
	
	;make sure Mind's Eye is buffed, note: this is a 10 min buff.
	call CastSpellRange 42
	
	switch ${Action[${xAction}]}
	{
		
		case Lash			
		case Gaze
		case Ego
		case AEStun
			if ${AoEMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{			
					if ${Mob.Count}>1
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
			}
			break
			
		case Despair
		case Mind
		case Anguish
		case Thoughts
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break	

		case ProcStun
			if !${Actor[${KillTarget}].IsEpic}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break	
			
		case Master_Strike
			if ${Me.Ability[Gnoll Master's Strike].IsReady} || ${Me.Ability[Orc Master's Strike].IsReady}
			{
				if ${Actor[${KillTarget}](exists)}
				{
					Me.Ability[Droag Master's Strike]:Use
					Me.Ability[Orc Master's Strike]:Use
					;Me.Ability[Gnoll Master's Strike]:Use
					;Me.Ability[Ghost Master's Strike]:Use
					Me.Ability[Skeleton Master's Strike]:Use
					Me.Ability[Elemental Master's Strike]:Use
					;Me.Ability[Zombie Master's Strike]:Use
					;Me.Ability[Centaur Master's Strike]:Use
					Me.Ability[Giant Master's Strike]:Use
					;Me.Ability[Treant Master's Strike]:Use
					;Me.Ability[Fairy Master's Strike]:Use
					;Me.Ability[Lizardman Master's Strike]:Use
					;Me.Ability[Goblin Master's Strike]:Use
					Me.Ability[Golem Master's Strike]:Use
					;Me.Ability[Bixie Master's Strike]:Use
					Me.Ability[Cyclops Master's Strike]:Use
					;Me.Ability[Djinn Master's Strike]:Use
					;Me.Ability[Harpy Master's Strike]:Use
					;Me.Ability[Naga Master's Strike]:Use
					;Me.Ability[Aviak Master's Strike]:Use
					;Me.Ability[Beholder Master's Strike]:Use
					;Me.Ability[Ravasect Master's Strike]:Use
				}
			}

		case Nuke
		case Stun
		case Silence
		case Daze
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		
		case AoE_PB
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break			
		default
			xAction:Set[20]
			break
	}

}

function Post_Combat_Routine(int xAction)
{

	
	TellTank:Set[FALSE]
	

	
	switch ${PostAction[${xAction}]}
	{
		
		case LoadDefaultEquipment
			ExecuteAtom LoadEquipmentSet "Default"
		case default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{
		
	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}
	;AE Fear
	if ${PBAoEMode}
	{	
		call CastSpellRange 181
	}
	;Blink
	;call CastSpellRange 180
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

function RefreshPower()
{
	declare tempvar int local
	declare MemberLowestPower int local
	;Spiritise Censer
	if !${Swapping} && ${Me.Inventory[Spirtise Censer](exists)} 
	{
		OriginalItem:Set[${Me.Equipment[Secondary].Name}]
		ItemToBeEquipped:Set[Spirtise Censer]
		call Swap
		Me.Equipment[Spirtise Censer]:Use
	}
	
	;Conjuror Shard
	if ${Me.Power}<40 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
	{
		Me.Inventory[${ShardType}]:Use
	}
	
	;Transference line out of Combat
	if ${Me.ToActor.Health}>60 && ${Me.ToActor.Power}<70 && !${Me.InCombat} 
	{
			call CastSpellRange 309
	}
	
	;Transference Line in Combat
	if ${Me.ToActor.Health}>60 && ${Me.ToActor.Power}<50
	{
			call CastSpellRange 309
	}
	
	;Mana Flow the lowest group member
	tempvar:Set[1]
	MemberLowestPower:Set[0]
	do
	{
		if ${Me.Group[${tempvar}].ToActor.Power}<60 && ${Me.Group[${tempvar}].ToActor.Distance}<30 && ${Me.Group[${tempvar}].ToActor(exists)}
		{
			if ${Me.Group[${tempvar}].ToActor.Power}<=${Me.Group[${MemberLowestPower}].ToActor.Power}
			{
				MemberLowestPower:Set[${tempvar}]
			}
		}

	}
	while ${tempvar:Inc}<${Me.GroupCount}

	if ${Me.Grouped}  && ${Me.Group[${MemberLowestPower}].ToActor.Power}<60 && ${Me.Group[${MemberLowestPower}].ToActor.Distance}<30  && ${Me.ToActor.Health}>50 && ${Me.Group[${MemberLowestPower}].ToActor(exists)}
	{
		call CastSpellRange 390 0 0 0 ${Me.Group[${MemberLowestPower}].ToActor.ID}
	}
	
	;Channel if group member is below 20 and we are in combat
	if ${Me.Grouped}  && ${Me.Group[${MemberLowestPower}].ToActor.Power}<20 && ${Me.Group[${MemberLowestPower}].ToActor.Distance}<50  && ${Me.InCombat} && && ${Me.Group[${MemberLowestPower}].ToActor(exists)}
	{
		call CastSpellRange 310
	}
	
	;Mana Cloak the group if the Main Tank is low on power
	if ${Actor[${MainAssist}].Power}<15 && ${Actor[${MainAssist}](exists)} && ${Actor[${MainAssist}].Distance}<50  && ${Actor[${MainAssist}].InCombatMode}
	{
		call CastSpellRange 354
	}
}

function CheckHeals()
{


}
function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	
	EQ2:CreateCustomActorArray[byDist,15]	
	
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if ${KillTarget}==${CustomActor[${tcount}].ID}
			{
				continue
			}

			tempvar:Set[1]
			aggrogrp:Set[FALSE]

			;check if its agro on a group member or group member's pet
			if ${grpcnt}>1
			{
				do
				{
					
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}
			
			;check if its agro on a raid member or raid member's pet
			if ${Me.InRaid}
			{
				do
				{
					
					if ${CustomActor[${tcount}].Target.ID}==${Me.Raid[${tempvar}].ID}  || (${CustomActor[${tcount}].Target.ID}==${Me.Raid[${tempvar}].ToActor.Pet.ID}  && ${Me.Raid[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=24
			}
			;check if its agro on me
			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
			{
				aggrogrp:Set[TRUE]
			}
			
			;if i have a mob charmed check if its agro on my charmed pet
			if ${Me.Maintained[${SpellType[351]}](exists)}
			{
				if ${CustomActor[${tcount}].Target.IsMyPet}
				{
					aggrogrp:Set[TRUE]
				}
			}
			
			if ${aggrogrp}
			{

				if ${Me.AutoAttackOn}
				{
					eq2execute /toggleautoattack
				}

				if ${Me.RangedAutoAttackOn}
				{
					eq2execute /togglerangedattack
				}
				
				;try to AE mezz first and check if its not single target mezzed
				if !${CustomActor[${tcount}].Effect[${SpellType[352]}](exists)}
				{
					call CastSpellRange 353 0 0 0 ${CustomActor[${tcount}].ID}
				}
				
				;if the actor is not AE Mezzed then single target Mezz
				if !${CustomActor[${tcount}].Effect[${SpellType}[353]](exists)}
				{
					call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 10
				}
				
				aggrogrp:Set[FALSE]
				
			
			}
			

		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}
	
	if ${Actor[${KillTarget}](exists)}  && ${Actor[${KillTarget}].Health}>1
	{
		Target ${KillTarget}
		wait 20 ${Me.ToActor.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
	}
}

function DoCharm()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]
		
	if ${Me.Maintained[${SpellType[351]}](exists)}
	{

		return
	}
	
	grpcnt:Set[${Me.GroupCount}]
	
	EQ2:CreateCustomActorArray[byDist,15]
	
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && !${CustomActor[${tcount}].IsEpic} && ${CustomActor[${tcount}].Target(exists)}
		{
			
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}
			
			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
			{
				aggrogrp:Set[TRUE]
			}

			if ${aggrogrp} && (${CustomActor[${tcount}].Difficulty}>=1) && (${CustomActor[${tcount}].Difficulty}<=3)
			{

				CharmTarget:Set[${CustomActor[${tcount}].ID}]
				break
				
			}


		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}	
	
	if ${Actor[${CharmTarget}](exists)}
	{
		call CastSpellRange 351 0 0 0 ${CharmTarget}
		
		if ${Actor[${KillTarget}](exists)} && (${Me.Maintained[${SpellType[351]}].Target.ID}!=${KillTarget}) && ${Me.Maintained[${SpellType[351]}](exists)} && ${Actor[${KillTarget}].Health}>1
		{
			ExecuteAtom PetAttack
		}
		else
		{
			EQ2Execute /target_none
		}
		
	}
				
}

function DoAmnesia()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]
		
	grpcnt:Set[${Me.GroupCount}]
	
	EQ2:CreateCustomActorArray[byDist,35]
	
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			
			if (${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID}) || 
			{
				continue
			}
			
			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						call IsFighter ${Me.Group[${tempvar}].ID}
						if ${Return} || ${Me.Group[${tempvar}].Name.Equal[${MainAssist}]}
						{
							continue
						}
						else
						{
							aggrogrp:Set[TRUE]
							break
						}
						
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}  && !${MainTank}
			{
				aggrogrp:Set[TRUE]
			}

			if ${aggrogrp}
			{
				call CastSpellRange 193 0 0 0 ${CustomActor[${tcount}].ID}
				return

			}

		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}	
	

}

function DestroyThoughtstones()
{
	;keeps 1 stack of thoughtstones and destroys the next stack
	variable int Counter=1
	variable bool StackFound=FALSE
	Me:CreateCustomInventoryArray[nonbankonly]
	do
	{	
		if ${Me.CustomInventory[${Counter}].Name.Equal[thoughtstone]}
		{
			if ${StackFound}
			{
				;we already have a stack so destroy this one and return
				Me.CustomInventory[${Counter}]:Destroy
				return				
			}
			else
			{
				StackFound:Set[TRUE]	
			}
		}
	}
	while ${Counter:Inc}<=${Me.CustomInventoryArraySize}
}