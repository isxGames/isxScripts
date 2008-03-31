;*************************************************************
;Paladin.iss
;version 20061201
;by Ownagejoo using all of Kayres Great scripts
;
;
;
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{

	declare TauntMode bool script TRUE
	declare HealerMode bool script FALSE
	declare Start_HO bool script FALSE

	declare BuffProcGroupMember string script
	declare Secondary_Assist string script

	;Custom Equipment
	declare WeaponMain string script
	declare OffHand string script
	declare OneHandedSword string script
	declare TwoHandedSword string script
	declare Shield string script
	declare Axe string script

	declare EquipmentChangeTimer int script


	call EQ2BotLib_Init

	;XML setup for Weapons
	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["OffHand",""]}]
	OneHandedSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OneHandedSword,]}]
	TwoHandedSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedSword,]}]
	Shield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Shield,]}]
	Axe:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Axe,]}]


	;XML Setup for clickbox options
	TauntMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Taunt Mode,TRUE]}]
	HealerMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[HealerMode,FALSE]}]
	Start_HO:Set{${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start_HO,FALSE]}]
	Use_Consecrate:Set{${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use_Consecrate,FALSE]}]

	BuffProcGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffProcGroupMember,]}]
	Secondary_Assist:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Secondary Assist,]}]


}

function Buff_Init()
{
		 PreAction[1]:Set[Protect_Target]
		 PreSpellRange[1,1]:Set[30]

		 PreAction[2]:Set[Self_Buff]
		 PreSpellRange[2,1]:Set[25]
		 PreSpellRange[2,2]:Set[27]

		 PreAction[3]:Set[Group_Buff]
		 PreSpellRange[3,1]:Set[20]
		 PreSpellRange[3,2]:Set[21]

		 PreAction[4]:Set[SA_Buff]
		 PreSpellRange[4,1]:Set[386]
}

function Combat_Init()
{
		 Action[1]:Set[Taunt]
		 SpellRange[1,1]:Set[160]
		 SpellRange[1,2]:Set[161]

		 Action[2]:Set[AA_SwiftAxe]
		 SpellRange[2,1]:Set[389]

		 Action[3]:Set[Combat_Buff]
		 SpellRange[3,1]:Set[155]
		 SpellRange[3,2]:Set[156]

		 Action[4]:Set[AoE_Taunt]
		 SpellRange[4,1]:Set[170]
		 SpellRange[4,2]:Set[171]

		 Action[5]:Set[Melee_Attack]
		 Power[5,1]:Set[25]
		 Power[5,2]:Set[100]
		 SpellRange[5,1]:Set[150]
		 SpellRange[5,2]:Set[154]

		 Action[6]:Set[Nuke_Attack]
		 Power[6,1]:Set[25]
		 Power[6,2]:Set[100]
		 SpellRange[6,1]:Set[60]
		 SpellRange[6,2]:Set[62]

		 Action[7]:Set[Two_Hand_Attack]
		 Power[7,1]:Set[25]
		 Power[7,2]:Set[100]
		 SpellRange[7,1]:Set[245]
		 SpellRange[7,2]:Set[247]

		 Action[8]:Set[Stun]
		 SpellRange[8,1]:Set[190]
		 SpellRange[8,2]:Set[192]

		 Action[9]:Set[Dot]
		 Power[9,1]:Set[50]
		 Power[9,2]:Set[100]
		 SpellRange[9,1]:Set[70]
		 SpellRange[9,2]:Set[72]

		 Action[10]:Set[AoE_All]
		 Power[10,1]:Set[25]
		 Power[10,2]:Set[100]
		 SpellRange[10,1]:Set[90]
		 SpellRange[10,2]:Set[96]

		 Action[11]:Set[Consencrate]
		 Power[11,1]:Set[25]
		 Power[11,2]:Set[100]
		 SpellRange[11,1]:Set[387]

		 Action[12]:Set[AA_SwiftAxe]
		 SpellRange[12,1]:Set[389]
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare BuffMember string local
	declare BuffTarget string local

	call WeaponChange

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

	if ${ShardMode}
	{
		call Shard
	}

	switch ${PreAction[${xAction}]}
	{

		case Protect_Target
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

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
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case SA_Buff
			if !${MainTank}
			{
				BuffTarget:Set[${UIElement[cbSecondary_Assist@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				{
					;Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				break
			}
			else
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
			}

			break

		Default
		xAction:Set[10]
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

	echo ${Start_HO}
	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${Start_HO}
	{
		call CastSpellRange 303
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
	}

	switch ${Action[${xAction}]}
	{
		case Stun
			if ${Me.ToActor.Health}<60
			{
				if ${Me.Equipment[secondary].Type.Equal[Shield]}
				{
					call CastSpellRange 191
					call CastSpellRange 190
					if ${HealerMode}
			     		{
			     			call CheckHeals
			     		}
			    		else
			     		{

						call MeHeals

			     		}
				}
				else
				{

					call CastSpellRange 190
					if ${HealerMode}
			     		{
			     			call CheckHeals
			     		}
			    		else
			     		{

						call MeHeals

			     		}
				}

			}
			else
			{
				if ${Me.Equipment[secondary].Type.Equal[Shield]}
				{
					call CastSpellRange 191
					call CastSpellRange 190

				}
				else
				{
					call CastSpellRange 190

				}
			}

		case Taunt
			if ${MainTank} && ${TauntMode}
			{

				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Combat_Buff
			if ${MainTank}
			{

			   if ${Target(exists)} && ${Target.Health}>5
		           {

			     call CastSpellRange 155
			     if ${HealerMode}
			     {
			     	call CheckHeals
			     }
			     else
			     {
				call MeHeals

			     }
			   }
		        }
			break

		case AoE_Taunt
		if ${MainTank} && ${TauntMode}
			{

			    		if ${Mob.Count}>1
			    		{
								call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			    		}
			}
			break

		case AA_SwiftAxe
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break

		case Melee_Attack
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{

				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}

			}
			break

		case Two_Hand_Attack
			if ${Me.Equipment[primary].WieldStyle.Equal[Two-Handed]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{

			    		call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
				}
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

		case Nuke_Attack
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{
			    call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
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

	if !${homepoint}
	{
	    return
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
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

function Lost_Aggro(int mobid)
{

    if ${Target(exists)} && ${Target.Health} > 5
    {

	call CastSpellRange 160 161

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

function Cancel_Root()
{

}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal[${Zone.Name}]}
		{

			if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}](exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health}
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<80
			{
				grpheal:Inc
			}

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
				{
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
				}
			}
		}

	}
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
	{
		grpheal:Inc
	}

	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainAssist}]} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call EmergencyHeal ${Actor[${MainAssist}].ID}
	}

	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<40
		{
			if ${haveaggro}
			{
				call EmergencyHeal ${Me.ID}
			}
			else
			{
				if ${Me.Ability[${SpellType[1]}].IsReady}
				{
					call CastSpellRange 1 0 0 0 ${Me.ID}
				}
				else
				{
					call CastSpellRange 4 0 0 0 ${Me.ID}
				}
			}
			hurt:Set[TRUE]
		}

	}
	;MAINTANK HEALS
	if ${Actor[${MainAssist}].Health} <90 && ${Actor[${MainAssist}].Health} >-99 && ${Actor[${MainAssist}](exists)}
	{
		call CastSpellRange 4 0 0 0 ${Actor[${MainAssist}].ID}
	}

	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
		{
			call CastSpellRange 10
		}

	}

	if ${Me.Group[${lowest}].ToActor.Health}<80 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady} && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}

		}
		else
		{
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}

		hurt:Set[TRUE]
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)}
	{
		call CastSpellRange 4 0 0 0 ${PetToHeal}
	}



}

function MeHeals()
{
	if ${Me.ToActor.Health}<40 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<25
		{
				eq2execute /group GET READY TO EVAC I AM ABOUT TO DIE
				call EmergencyHeal ${Me.ID}
		}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 1 0 0 0 ${Me.ID}
			}
			else
			{
				call CastSpellRange 4 0 0 0 ${Me.ID}
			}
		}
			hurt:Set[TRUE]
	}
}

function EmergencyHeal(int healtarget)
{
	if ${Me.Ability[${SpellType[387]}].IsReady}
	{
		call CastSpellRange 387 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 1 0 0 0 ${healtarget}
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
