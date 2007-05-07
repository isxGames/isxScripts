;*************************************************************
;Warlock.iss
;version 20061012a
;by Pygar
; Initial Build
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare DebuffMode bool script FALSE
	declare DoTMode bool script TRUE
	declare BuffVielShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffVenemousProc collection:string script
	declare BuffBoon bool script FALSE
	declare BuffPact bool script FALSE
	declare PetMode bool script 1

	;Custom Equipment
	declare WeaponStaff string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script

	declare EquipmentChangeTimer int script ${Time.Timestamp}

	call EQ2BotLib_Init

	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	DoTMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast DoT Spells,TRUE]}]
	BuffVielShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Veil Shield,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffBoon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBoon,,FALSE]}]
	BuffPact:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPact,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Staff",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]

}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[26]
	PreSpellRange[1,3]:Set[27]

	PreAction[2]:Set[BuffBoon]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[BuffPact]
	PreSpellRange[3,1]:Set[20]

	PreAction[4]:Set[Tank_Buff]
	PreSpellRange[4,1]:Set[40]
	PreSpellRange[4,2]:Set[41]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[31]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]
}

function Combat_Init()
{
	Action[1]:Set[Combat_Buff]
	MobHealth[1,1]:Set[50]
	MobHealth[1,2]:Set[100]
	SpellRange[1,1]:Set[330]

	Action[2]:Set[AoE_Debuffs]
	SpellRange[2,1]:Set[55]
	SpellRange[2,2]:Set[56]
	SpellRange[2,3]:Set[57]

	Action[3]:Set[Debuffs]
	SpellRange[3,1]:Set[50]
	SpellRange[3,2]:Set[51]
	SpellRange[3,3]:Set[52]

	Action[4]:Set[Special_Pet]
	MobHealth[4,1]:Set[60]
	MobHealth[4,2]:Set[100]
	SpellRange[4,1]:Set[324]

	Action[5]:Set[AoE_DoT]
	MobHealth[5,1]:Set[30]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[94]

	Action[6]:Set[AoE_Nuke]
	SpellRange[6,1]:Set[90]
	SpellRange[6,2]:Set[91]
	SpellRange[6,3]:Set[92]

	Action[7]:Set[Dot]
	MobHealth[7,1]:Set[20]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[70]
	SpellRange[7,2]:Set[71]
	SpellRange[7,3]:Set[72]

	Action[8]:Set[AoE_PB]
	SpellRange[8,1]:Set[95]

	Action[9]:Set[AoE_Root]
	SpellRange[9,1]:Set[231]

	Action[10]:Set[Root]
	SpellRange[10,1]:Set[230]

	Action[11]:Set[Nuke]
	SpellRange[11,1]:Set[60]
	SpellRange[11,2]:Set[61]
	SpellRange[11,3]:Set[62]
	SpellRange[11,4]:Set[63]

	Action[12]:Set[Master_Strike]

}

function PostCombat_Init()
{

	PostAction[1]:Set[LoadDefaultEquipment]
	avoidhate:Set[FALSE]
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
	}

	if ${ShardMode}
	{
		call Shard
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
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case BuffBoon
			if ${BuffBoon}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffPact
			if ${BuffPact}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Tank_Buff
			BuffTarget:Set[${UIElement[cbBuffVielShieldGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}]:Cancel
			}

			if ${BuffVielShield}
			{

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
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
					if ${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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

	if ${DoHOs} && ${StartHO}
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

	switch ${Action[${xAction}]}
	{

		case Special_Pet
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${PetMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case AoE_PB
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break

		case Combat_Buff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case AoE_Debuffs
			if ${AoEMode} && ${DebuffMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}

			}
			break

		case Debuffs
			if ${DebuffMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
			}
			break

		case AoE_DoT
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 4
			}
			break

		case AoE_Nuke
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
			}
			break

		case Master_Strike
			if ${Me.Ability[Master's Smite].IsReady}
			{
				Target ${KillTarget}
				Me.Ability[Master's Smite]:Use
			}

		case Dot
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
			}
			break

		case Nuke
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},4]} 0 0 ${KillTarget}
			break
		case Root
		case AoE_Root
			break
		Default
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
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if ${Me.Ability[${SpellRange[181]}].IsReady}
	{
		call CastSpellRange 180
	}
	else
	{
		call CastSpellRange 181
	}

	if ${Me.Ability[${SpellRange[231]}].IsReady}
	{
		call CastSpellRange 231
	}
	else
	{
		call CastSpellRange 230
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
		press -hold ${backward}
		wait 3
		press -release ${backward}
		avoidhate:Set[TRUE]
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

function RefreshPower()
{



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

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call CastSpellRange 309
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<35
	{
		call CastSpellRange 333
	}
}

function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	; Cure Arcane Me
	if ${Me.Arcane}
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}

	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane} && ${Me.Group[${temphl}].ToActor(exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}


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