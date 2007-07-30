;*************************************************************
;Conjuror.iss
;version 20070725a
;various fixes
;by karye
;updated by pygar
;
;20070725a
; Updated for new AA changes
;
;20070504a
; Toggle PetMode
;
;20070404a
;	updated for latest eq2bot
;	updated master strike
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{

	declare PetType int script
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffDamageShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffEmberSeed collection:string script
	declare BuffSeal bool script FALSE
	declare BuffEscutcheon bool script FALSE
	declare BuffCabalistCover bool script TRUE
	declare PetMode bool script 1

	declare ShardQueue queue:string script
	declare ShardRequestTimer int script ${Time.Timestamp}
	declare ShardType string script

	;Custom Equipment
	declare WeaponStaff string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script

	declare EquipmentChangeTimer int script ${Time.Timestamp}

	call EQ2BotLib_Init

	AddTrigger QueueShardRequest "\\aPC @*@ @*@:@sender@\\/a tells@*@shard please@*@"
	AddTrigger DequeueShardRequest "Target already has a conjurer essence item!"


	PetType:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Pet Type,3]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	BuffDamageShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Damage Shield,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffEscutcheon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffEscutcheon,,FALSE]}]
	BuffSeal:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSeal,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Staff",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]

	switch ${SpellType[360]}
	{

		case Splinter of Essence
		case Sliver of Essence
			ShardType:Set["Sliver of Essence"]
			break

		case Shard of Essence
			ShardType:Set["Shard of Essence"]
			break

		case Scintilla of Essence
			ShardType:Set["Scintilla of Essence"]
			break

	}
}

function Buff_Init()
{
	PreAction[1]:Set[AA_Cabalists_Cover]
	PreSpellRange[1,1]:Set[384]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[4]:Set[Pet_Buff]
	PreSpellRange[4,1]:Set[45]

	PreAction[5]:Set[Tank_Buff]
	PreSpellRange[5,1]:Set[40]

	PreAction[6]:Set[Melee_Buff]
	PreSpellRange[6,1]:Set[35]

	PreAction[7]:Set[SeeInvis]
	PreSpellRange[7,1]:Set[30]

	PreAction[8]:Set[Buff_Shards]
	PreSpellRange[8,1]:Set[360]

	PreAction[9]:Set[AA_Minions_Warding]
	PreSpellRange[9,1]:Set[385]

	PreAction[10]:Set[Seal]
	PreSpellRange[10,1]:Set[20]

	PreAction[11]:Set[Escutcheon]
	PreSpellRange[11,1]:Set[21]

	PreAction[12]:Set[AA_Bubble]
	PreSpellRange[12,1]:Set[377]

	PreAction[13]:Set[AA_Unabate]
	PreSpellRange[13,1]:Set[376]
}

function Combat_Init()
{


	Action[1]:Set[Combat_Buff]
	MobHealth[1,1]:Set[1]
	MobHealth[1,2]:Set[100]
	SpellRange[1,1]:Set[397]

	Action[2]:Set[Dot1]
	SpellRange[2,1]:Set[73]

	Action[3]:Set[Plane_Shift]
	SpellRange[3,1]:Set[399]

	Action[4]:Set[Special_Pet1]
	MobHealth[4,1]:Set[30]
	MobHealth[4,2]:Set[100]
	SpellRange[4,1]:Set[329]

	Action[5]:Set[AoE1]
	SpellRange[5,1]:Set[90]

	Action[6]:Set[Special_Pet2]
	MobHealth[6,1]:Set[30]
	MobHealth[6,2]:Set[100]
	SpellRange[6,1]:Set[330]

	Action[7]:Set[Nuke]
	MobHealth[7,1]:Set[0]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[61]

	Action[8]:Set[AoE_PB]
	SpellRange[8,1]:Set[95]

	Action[9]:Set[AoE2]
	SpellRange[9,1]:Set[91]

	Action[10]:Set[Sunbolt]
	SpellRange[10,1]:Set[62]

	Action[11]:Set[Master_Strike]

	Action[12]:Set[Stun]
	SpellRange[12,1]:Set[190]

	Action[13]:Set[AA_Animated_Dagger]
	MobHealth[13,1]:Set[30]
	MobHealth[13,2]:Set[100]
	SpellRange[13,1]:Set[380]

	Action[14]:Set[Dot2]
	MobHealth[14,1]:Set[20]
	MobHealth[14,2]:Set[100]
	SpellRange[14,1]:Set[72]



}

function PostCombat_Init()
{
	PostAction[1]:Set[AA_Possessed_Minion]
	PostSpellRange[1,1]:Set[398]

	PostAction[2]:Set[LoadDefaultEquipment]

}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	;check if we have a pet or a hydromancy not up
	if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[379]}](exists)} && ${PetMode}
	{
		call SummonPet
		waitframe
	}

	call CheckHeals
	call RefreshPower
	call AnswerShardRequest

	ExecuteAtom CheckStuck

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

	switch ${PreAction[${xAction}]}
	{
		case AA_Minions_Warding
		case AA_Cabalists_Cover
			if ${BuffCabalistCover} && !${Me.Maintained[${SpellType[379]}](exists)}
			{

				call CastSpellRange ${PreSpellRange[${xAction},1]}
				BuffCabalistCover:Set[FALSE]
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Seal
			if ${BuffSeal}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Escutcheon
			if ${BuffEscutcheon}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case No_Conc_Group_Buff
		case AA_Unabate
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Pet_Buff
		case AA_Bubble
			if ${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[379]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		case Tank_Buff
			BuffTarget:Set[${UIElement[cbBuffDamageShieldGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${BuffDamageShield}
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
					if ${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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

		case Buff_Shards
			if !${Me.Inventory[${ShardType}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			}
			break


		Default
			xAction:Set[40]
			break
	}
}

function Combat_Routine(int xAction)
{

	variable int Counter

	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	;check if we have a pet or a hydromancy not up
	if !${Me.ToActor.Pet(exists)} || !${Me.Maintained[${SpellType[379]}](exists)} && ${PetMode}
	{
		call SummonPet
	}

	if ${Me.ToActor.Pet(exists)} && ${PetMode}
	{
		ExecuteAtom PetAttack
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}


	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	call CheckHeals
	call RefreshPower
	call AnswerShardRequest

	;keep blazing Avatar up at all times
	if ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 71
	}

	;keep distracting strike up if we have a scout pet
	if ${Me.Maintained[${SpellType[355]}](exists)}
	{
		call CastSpellRange 383
	}

	;keep  Magic Leash up if we have a mage pet
	if ${Me.Maintained[${SpellType[356]}](exists)}
	{
		call CastSpellRange 397
	}


	switch ${Action[${xAction}]}
	{


		case AA_Animated_Dagger
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case Special_Pet2
			if ${AoEMode} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case Special_Pet1
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${PetMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case Plane_Shift
			if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case AoE_PB
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break

		case Combat_Buff
		case AoE1
			if ${AoEMode} && (${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[379]}](exists)})
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

			}
			break

		case AoE2
			if ${AoEMode}
			{
				if ${Mob.Count}>1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case Dot1
			call CastSpellRange ${SpellRange[${xAction},1]}
			break

		case Dot2
		case Nuke
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case Blazing_Avatar
			call CastSpellRange ${PostSpellRange[${xAction},1]}
			break
		case Master_Strike
			if ${Me.Ability[Master Strike].IsReady} && ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
				Me.Ability[Master Strike]:Use
			}
			break
		case Sunbolt
		case Nuke_Attack
		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		Default
			xAction:Set[40]
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
		case AA_Possessed_Minion
			;check if we are possessed minion and cancel
			if ${Me.Race.Equal[Unknown]}
			{
				Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			}
			break
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

	;Buff Stoneskin
	call CastSpellRange 180
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

	;Blazing Vigor line out of Combat
	if ${Me.ToActor.Pet.Health}>60 && ${Me.ToActor.Power}<70 && !${Me.ToActor.Pet.IsAggro}
	{
			call CastSpellRange 309
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}

	;Conjuror Shard
	if ${Me.Power}<40 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
	{
		Me.Inventory[${ShardType}]:Use
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<20
	{
		call UseItem "Dracomancer Gloves"
	}

	;Blazing Vigor Line in Combat
	if ${Me.ToActor.Pet.Health}>50 && ${Me.ToActor.Power}<20
	{
			call CastSpellRange 309
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

}

function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	; Cure Arcane Me
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}
	;================================
	;= Animist Transference Check
	;================================
	;Check ME first,
	if ${Me.ToActor.Health}<60
	{
		call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
		;stoneskins AA
		call CastSpellRange 378

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}

	do
	{
			; Cure Arcane
			if ${Me.Group[${temphl}].Arcane}>=1 && ${Me.Group[${temphl}].ToActor(exists)}
			{
				call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}

				if ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
				}
			}

			;Check Group members
			if ${Me.Group[${temphl}].ToActor.Health}<50 && ${Me.Group[${temphl}].ToActor.Health}>-99 && && ${Me.Group[${temphl}].ToActor(exists)}
			{
				call CastSpellRange 396 0 0 0 ${Me.Group[${temphl}].ToActor.ID}

				;Stoneskins AA
				call CastSpellRange 378

				;EQ2Echo healing ${Me.Group[${temphl}].ToActor.Name}

				if ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
				}

			}

			;================================
			;= Expiation Check
			;================================
			call IsHealer ${Me.Group[${temphl}].ID}

			if (${Me.Group[${temphl}].ToActor.Health}<30 && ${Me.Group[${temphl}].ToActor.Health}>0)  || (${Return} && ${Me.Group[${temphl}].ToActor.Power}<30 && ${Me.Group[${temphl}].ToActor.Power}>0) && ${Me.Group[${temphl}].ToActor.InCombatMode} && ${Me.Group[${temphl}].ToActor(exists)} && ${PetMode}
			{
				;TODO Add check for Intervention
				;Cast AA Animist Bond so damage from expiation is to power not the pets health
				call CastSpellRange 382
				;Cast Expiation
				call CastSpellRange 361
				call SummonPet

			}
	}
	while ${temphl:Inc}<${grpcnt}

	;================================
	;= Pet Heals                    =
	;================================

	;Animist Bond AA check
	if  ${Me.ToActor.Pet.Health}<50 && ${Me.ToActor.Pet.Power}>30 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 382
	}

	if ${Me.ToActor.Pet.Health}<70 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 1
	}

	if ${Me.ToActor.Pet.Health}<40 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 4
	}

	if ${Me.ToActor.Pet.Health}<30 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 47
	}

	call UseCrystallizedSpirit 60

}


function QueueShardRequest(string line, string sender)
{
	if ${Actor[${sender}](exists)}
	{
		ShardQueue:Queue[${sender}]
	}
}

function AnswerShardRequest()
{
	if ${Actor[${ShardQueue.Peek}](exists)}
	{
		if ${Actor[${ShardQueue.Peek}].Distance}<10  && !${Me.IsMoving}  &&  ${Me.Ability[${SpellType[360]}].IsReady}
		{
			if ${Time.Timestamp}-${ShardRequestTimer}>2
			{
				call CastSpellRange 360 0 0 0 ${Actor[pc,exactname,${ShardQueue.Peek}].ID}
				ShardRequestTimer:Set[${Time.Timestamp}]
			}

			if ${Return}
			{
				ShardQueue:Dequeue
			}
		}
	}

}

function DequeueShardRequest(string line)
{
	if ${ShardQueue.Peek(exists)}
	{
		ShardQueue:Dequeue
	}
}

function SummonPet()
{
;1=Scout,2=Mage,3=Fighter; 4=hydromancer
	PetEngage:Set[FALSE]

	if ${PetMode}
	{
		switch ${PetType}
		{
			case 1
				call CastSpellRange 355
				break

			case 2
				call CastSpellRange 356
				break

			case 3
				call CastSpellRange 357
				break

			case 4
				call CastSpellRange 379
				break

			case default
				call CastSpellRange 357
				break
		}
		BuffCabalistCover:Set[TRUE]
	}
}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal["${WeaponMain}"]}
	{
		Me.Inventory["${WeaponMain}"]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal["${OffHand}"]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory["${OffHand}"]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}