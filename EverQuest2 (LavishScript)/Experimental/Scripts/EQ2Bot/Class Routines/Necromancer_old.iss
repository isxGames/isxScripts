;*************************************************************
;Necromancer.iss
;version 20060626b
;by Syliac adapted from Karye Conj.
;*************************************************************

#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"

function Class_Declaration()
{

	declare PetType int script
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffDamageShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffCabalistCover bool script TRUE
	
	declare EmberSeedBuffs int script 0
	
	declare ShardType string script
	
	;Custom Equipment
	declare WeaponStaff string script 
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script
	
	call EQ2BotLib_Init
	
	AddTrigger ShardRequest "\\aPC @*@ @*@:@sender@\\/a tells@*@need heart please@*@"

	

	PetType:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Pet Type,3]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	BuffDamageShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Damage Shield,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Staff",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]		
	
	switch ${SpellType[360]}
	{

		case Splinterd Heart
			ShardType:Set["Splintered Heart"]
			break
		case Dark Heart
			ShardType:Set["Dark Heart"]
			break
			
		case Sacrificial Heart
			ShardType:Set["Sacrificial Heart"]
			break
					
	}
}

function Buff_Init()
{
	PreAction[1]:Set[AA_Cabalists_Cover]
	PreSpellRange[1,1]:Set[384]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[Group_Buff]
	PreSpellRange[3,1]:Set[20]
	PreSpellRange[3,2]:Set[21]

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

	PreAction[9]:Set[AA_GeneralPetBuffs]
	PreSpellRange[9,1]:Set[386]
	PreSpellRange[9,2]:Set[388]
	
	PreAction[10]:Set[AA_FighterPetBuffs]
	PreSpellRange[10,1]:Set[390]
	PreSpellRange[10,2]:Set[391]
	
	PreAction[11]:Set[AA_MagePetBuffs]
	PreSpellRange[11,1]:Set[392]
	PreSpellRange[11,2]:Set[393]
	
	PreAction[12]:Set[AA_ScoutPetBuffs]
	PreSpellRange[12,1]:Set[389]
	
	PreAction[13]:Set[AA_Minions_Warding]
	PreSpellRange[13,1]:Set[385]	
	
	
		
	
}

function Combat_Init()
{
		
	Action[1]:Set[Stun]
	SpellRange[1,1]:Set[190]
	
	Action[2]:Set[Pet_Dot1]
	SpellRange[2,1]:Set[329]

	Action[3]:Set[Dot]
	SpellRange[3,1]:Set[71]
	
	Action[4]:Set[Dot2]
	if ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed} 
	{
		MobHealth[4,1]:Set[1] 
		MobHealth[4,2]:Set[100] 
	}
	else
	{
		MobHealth[4,1]:Set[50] 
		MobHealth[4,2]:Set[100]
	}
	SpellRange[4,1]:Set[235]

	Action[5]:Set[AoE1]
	SpellRange[5,1]:Set[90]
	
	Action[6]:Set[Pet_Dot2]
	if ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed} 
	{
		MobHealth[6,1]:Set[1] 
		MobHealth[6,2]:Set[100] 
	}
	else
	{
		MobHealth[6,1]:Set[50] 
		MobHealth[6,2]:Set[100]
	}
	SpellRange[6,1]:Set[330]
	
	Action[7]:Set[AoE_PB]
	SpellRange[7,1]:Set[95]
	
	Action[10]:Set[AoE2]
	SpellRange[10,2]:Set[91]
	
	Action[11]:Set[Master_Strike]

	Action[12]:Set[Nuke_Attack]
	SpellRange[12,1]:Set[63]
	
	Action[13]:Set[NukeDot]
	SpellRange[13,1]:Set[61]
	
}

function PostCombat_Init()
{
	PostAction[1]:Set[Blazing_Avatar]
	PostSpellRange[1,1]:Set[71]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	
	if !${Me.ToActor.Pet(exists)}
	{
		call SummonPet
	}
	call CheckHeals
	call RefreshPower
	
	ExecuteAtom CheckStuck
	
	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}
			
	switch ${PreAction[${xAction}]}
	{
		case AA_Minions_Warding
		case AA_Cabalists_Cover
			if ${BuffCabalistCover}
			{
				
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				BuffCabalistCover:Set[FALSE]
			}
			break
			
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case No_Conc_Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Pet_Buff
			if ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		case AA_FighterPetBuffs
			if ${Me.Maintained[${SpellType[357]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		case AA_MagePetBuffs
			if ${Me.Maintained[${SpellType[356]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		case AA_ScoutPetBuffs
			if ${Me.Maintained[${SpellType[355]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_GeneralPetBuffs
			if ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break	
			
		case Tank_Buff
			if ${BuffDamageShield}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTank}].ID}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel	
			}
			break
		
		case Melee_Buff
		
			call Buff_Count ${PreSpellRange[${xAction},1]}
			EmberSeedBuffs:Set[${Return}]
			if ${EmberSeedBuffs}<2
			{
			
				; if we have a scout or fighter pet buff it first
				if ${Me.Maintained[${SpellType[355]}](exists)} || ${Me.Maintained[${SpellType[357]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ToActor.Pet.ID}
					call Buff_Count ${PreSpellRange[${xAction},1]}
					EmberSeedBuffs:Set[${Return}]
				}

				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
					{
						;if we are grouped with the Main Tank buff them next
						if ${Me.Group[${tempvar}].ToActor.ID}==${Actor[${MainTank}].ID}
						{
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
							call Buff_Count ${PreSpellRange[${xAction},1]}
							EmberSeedBuffs:Set[${Return}]
							
						}

						; use the remaining conc slots on any melee in the group
						switch ${Me.Group[${tempvar}].ToActor.Class}
						{
							case dirge
							case troubador
							case assassin
							case swashbuckler
							case brigand
							case berserker
							case guardian
							case bruiser
							case monk
							case paladin
							case shadowknight
							case ranger
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
								call Buff_Count ${PreSpellRange[${xAction},1]}
								EmberSeedBuffs:Set[${Return}]
								break
							case Default
								break
						}
					}
				}
				while ${tempvar:Inc}<${Me.GroupCount} && ${EmberSeedBuffs}<2
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
	if !${Me.ToActor.Pet(exists)}
	{
		call SummonPet
	}
	
	
	
	
	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
	}
	
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}
		
	call CheckHeals
	
	call RefreshPower
	
	;keep  Magic Leash up if we have a mage pet
	if ${Me.Maintained[${SpellType[356]}](exists)}
	{
		call CastSpellRange 397
	}	
	
	
	switch ${Action[${xAction}]}
	{

	case Stun
	call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
	break
	
		case AA_Animated_Dagger
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
			if ${Return.Equal[OK]} 
			{ 
				if ${Me.Equipment[1].Name.Equal[${WeaponDagger}]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponDagger}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			} 
			break			

		case Pet_Dot1
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		
		case Dot
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}			
			break	
		
		case Pet_Dot2
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		
			
		case AoE_PB
			if ${PBAoEMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break
		
		case Combat_Buff			
		case AoE1
			if ${AoEMode}
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
			
		case Dot2
		call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
		break
		
		case Master_Strike
			if ${Me.Ability[Orc Master's Strike].IsReady} || ${Me.Ability[Orc Master's Strike].IsReady}
			{
				Target ${KillTarget}
				;Me.Ability[Droag Master's Strike]:Use
				Me.Ability[Orc Master's Strike]:Use
				;Me.Ability[Gnoll Master's Strike]:Use
				;Me.Ability[Ghost Master's Strike]:Use
				Me.Ability[Skelleton Master's Strike]:Use
				;Me.Ability[Zombie Master's Strike]:Use
				;Me.Ability[Centaur Master's Strike]:Use
				Me.Ability[Giant Master's Strike]:Use
				Me.Ability[Treant Master's Strike]:Use
				;Me.Ability[Fairy Master's Strike]:Use
				;Me.Ability[Lizardman Master's Strike]:Use
				;Me.Ability[Goblin Master's Strike]:Use
				Me.Ability[Golem Master's Strike]:Use
				;Me.Ability[Bixie Master's Strike]:Use
				;Me.Ability[Cyclops Master's Strike]:Use
				;Me.Ability[Djinn Master's Strike]:Use
				;Me.Ability[Harpy Master's Strike]:Use
				;Me.Ability[Naga Master's Strike]:Use
				;Me.Ability[Aviak Master's Strike]:Use
				;Me.Ability[Beholder Master's Strike]:Use
				;Me.Ability[Ravasect Master's Strike]:Use
			}

		case Nuke_Attack
		call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
		break
		
		case NukeDot
		call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
		break
				
		Default
			xAction:Set[20]
			break
	}
ExecuteAtom PetAttack
}

function Post_Combat_Routine(int xAction)
{

	
	TellTank:Set[FALSE]
	
	switch ${PostAction[${xAction}]}
	{
		case Blazing_Avatar
			call CastSpellRange ${SpellRange[${xAction},1]}
			break
		
		case Default
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
	
	;Blazing Vigor line out of Combat
	if ${Me.ToActor.Pet.Health}>60 && ${Me.ToActor.Power}<70 && !${Me.ToActor.Pet.IsAggro} 
	{
			call CastSpellRange 309
	}
	
	;Blazing Vigor Line in Combat
	if ${Me.ToActor.Pet.Health}>50 && ${Me.ToActor.Power}<20 
	{
			call CastSpellRange 309
	}
	
	
}

function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]
		
	; Cure Arcane Me
	if ${Me.Arcane} && !${Me.ToActor.Effect[Revived Sickness](exists)}
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
		if ${Me.Equipment[1].Name.Equal[${WeaponStaff}]}
		{
			call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
		}
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
		{
			Me.Inventory[${WeaponStaff}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
		}
		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}		
	}
	
	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal[${Zone.Name}]}
		{
			;Cure Arcane GroupMember
			if ${Me.Group[${temphl}].Arcane} && !${Me.Group[${temphl}].ToActor.Effect[Revived Sickness](exists)}
			{
				call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}
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
				if ${Me.Equipment[1].Name.Equal[${WeaponStaff}]}
				{
					call CastSpellRange 396 0 0 0 ${Me.Group[${temphl}].ToActor.ID}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponStaff}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
				}
				
				if ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
				}				
			}
			;Check Group members
			if ${Me.Group[${temphl}].ToActor.Health}<50 && ${Me.Group[${temphl}].ToActor.Health}>-99
			{

				if ${Me.Equipment[1].Name.Equal[${WeaponStaff}]}
				{
					call CastSpellRange 396 0 0 0 ${Me.Group[${temphl}].ToActor.ID}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponStaff}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastSpellRange 396 0 0 0 ${Me.Group[${temphl}].ToActor.ID}
				}
				
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

			if (${Me.Group[${temphl}].ToActor.Health}<30 && ${Me.Group[${temphl}].ToActor.Health}>-99)  || (${Return} && ${Me.Group[${temphl}].ToActor.Power}<30)  && ${Me.ToActor.InCombat}
			{
				;TODO Add check for Intervention
				call CastSpellRange 361
				call SummonPet

			}
		}
	}
	while ${temphl:Inc}<${grpcnt}

	;================================
	;= Pet Heals                    =
	;================================
	
	if  ${Me.ToActor.Pet.Health}<80
	{
		call CastSpellRange 382
	}

	if ${Me.ToActor.Pet.Health}<70
	{
		call CastSpellRange 1
	}

	if ${Me.ToActor.Pet.Health}<40
	{
		call CastSpellRange 4
	}

	if ${Me.ToActor.Pet.Health}<30
	{
		call CastSpellRange 47
	}


}


function ShardRequest(string line, string sender)
{
	if ${Actor[${sender}](exists)} && ${Actor[${sender}].Distance}<10 
	{
		call CastSpellRange 360 0 0 0 ${Actor[${sender}].ID}
		
		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}
}



function SummonPet()
{
;1=Scout,2=Mage,3=Fighter
	PetEngage:Set[FALSE]
	
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
		
		case default
			call CastSpellRange 357
			break
	}
	BuffCabalistCover:Set[TRUE]
}