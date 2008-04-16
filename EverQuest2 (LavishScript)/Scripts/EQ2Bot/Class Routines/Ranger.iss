;Ranger.iss 20070117a by Karye

;TODO Some EoF AAs
;TODO Stream of Arrows
;TODO SNiper SHot
;TODO Hawk Dive
;TODO Thorny Trap

#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"

function Class_Declaration()
{
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BowAttacksMode bool script TRUE
	declare RangedAttackMode bool script TRUE
	declare SurroundingAttacksMode bool Script FALSE

	declare WeaponSword string script
	declare WeaponRapier string script
	declare WeaponSpear string script
	declare WeaponDagger string script
	declare WeaponMain string script
	declare OffHand string script
	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	BowAttacksMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Ranged Attacks Only,FALSE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	SurroundingAttacksMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Surrounding Attacks,FALSE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponRapier:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Rapier",""]}]
	WeaponSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Spear",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]

}
function Buff_Init()
{
	PreAction[1]:Set[Reconnoiter]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Hunters_Instinct]
	PreSpellRange[2,1]:Set[26]

	PreAction[3]:Set[AA_Surrounding_Attacks]
	PreSpellRange[3,1]:Set[396]

	PreAction[4]:Set[AA_Neurotoxic_Coating]
	PreSpellRange[4,1]:Set[391]
}

function Combat_Init()
{

	Action[1]:Set[Bounty]
	SpellRange[1,1]:Set[400]

	Action[2]:Set[Wounding_Arrow]
	SpellRange[2,1]:Set[252]

	Action[3]:Set[Mastery]

	Action[4]:Set[AA_Bladed_Opening]
	SpellRange[4,1]:Set[399]

	Action[5]:Set[Pounce]
	SpellRange[5,1]:Set[95]

	Action[6]:Set[Storm_of_Arrows]
	SpellRange[6,1]:Set[90]

	Action[7]:Set[AA_Spinning_Spear]
	SpellRange[7,1]:Set[397]

	Action[8]:Set[Hidden_Shot]
	SpellRange[8,1]:Set[260]

	Action[9]:Set[Triple_Shot]
	SpellRange[9,1]:Set[251]

	Action[10]:Set[Shadow_Leap]
	SpellRange[10,1]:Set[135]

	Action[11]:Set[Back_Fire]
	SpellRange[11,1]:Set[255]

	Action[12]:Set[Trick_Shot]
	SpellRange[12,1]:Set[253]

	Action[13]:Set[Miracle_Shot]
	SpellRange[13,1]:Set[254]

	Action[14]:Set[Ensnare]
	MobHealth[14,1]:Set[5]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[5]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[235]

	Action[15]:Set[Double_Shot]
	SpellRange[15,1]:Set[250]

	Action[16]:Set[Bleeding_Cut]
	SpellRange[16,1]:Set[70]

	Action[17]:Set[Stalker_Strike]
	SpellRange[17,1]:Set[130]

	Action[18]:Set[Rip]
	SpellRange[18,1]:Set[153]

	Action[19]:Set[AA_Point_Blank_Shot]
	SpellRange[19,1]:Set[398]

	Action[20]:Set[AA_Poison_Combination]
	SpellRange[20,1]:Set[392]

	Action[21]:Set[Lunge]
	SpellRange[21,1]:Set[122]

	Action[22]:Set[Strike]
	SpellRange[22,1]:Set[150]

	Action[23]:Set[Leg_Shot]
	SpellRange[23,1]:Set[259]

	Action[24]:Set[Trap]
	MobHealth[24,1]:Set[5]
	MobHealth[24,2]:Set[100]
	Power[24,1]:Set[5]
	Power[24,2]:Set[100]
	SpellRange[24,1]:Set[50]

	Action[25]:Set[AA_Placting_Strike]
	SpellRange[25,1]:Set[394]




}

function PostCombat_Init()
{

	PostAction[1]:Set[Summon_Arrows]
	PostSpellRange[1,1]:Set[310]

	PostAction[2]:Set[AA_Intoxication]
	PostSpellRange[2,1]:Set[390]

	PostAction[3]:Set[BuffPoison]

}

function Buff_Routine(int xAction)
{

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

	call WeaponChange

	switch ${PreAction[${xAction}]}
	{
		case AA_Surrounding_Attacks
			if ${SurroundingAttacksMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Hunters_Instinct
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 1
			break
		case AA_Neurotoxic_Coating
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Reconnoiter
			if !${MainTank}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 1
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

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}
	;Always keep Honed Reflexes Buffed
	call CastSpellRange 158 0 0 0 0 0 0 1

	;Always keep Feral Instinct Buffed
	call CastSpellRange 156 0 0 0 0 0 0 1

	;Allways keep short combat buff up (take aim)
	;if we are using bow attacks or ranged only
	if ${BowAttacksMode} || ${RangedAttackMode}
	{
		call CastSpellRange 155 0 0 0 0 0 0 1
	}

	switch ${Action[${xAction}]}
	{
		case AA_Bladed_Opening
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case AA_Poison_Combination
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case AA_Spinning_Spear
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${PBAoEMode} && ${Mob.Count}>=2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case AA_Placting_Strike
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
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
		case Trap
			if ${DebuffMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			break

		case Ensnare
			if !${RangedAttackMode} && ${DebuffMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		case Rip
		case Lunge
		case Bleeding_Cut
		case Strike
			if !${RangedAttackMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		case Back_Fire
			if ${BowAttacksMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 1 ${KillTarget} 0 0 1
			}
			break
		case Bounty
			if ${Actor[${KillTarget}].ConColor.NotEqual[Green]} && ${Actor[${KillTarget}].ConColor.NotEqual[Grey]} && !${RangedAttackMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case Stalker_Strike
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${RangedAttackMode}
			{
				if !${Me.ToActor.IsStealthed}
				{
					call CastStealth

				}

				if ${Me.ToActor.IsStealthed}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 0 0 1
				}

			}
			break
		case Storm_of_Arrows
			if ${BowAttacksMode} && ${AoEMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
			}
			break
		case AA_Point_Blank_Shot
			if !${RangedAttackMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case Leg_Shot
		case Miracle_Shot
		case Triple_Shot
		case Trick_Shot
		case Double_Shot
		case Wounding_Arrow
			if ${BowAttacksMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
			}
			break
		case Hidden_Shot
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${BowAttacksMode}
			{
				if !${Me.ToActor.IsStealthed}
				{
					call CastStealth

				}

				if ${Me.ToActor.IsStealthed}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
				}

			}
			break
		case Shadow_Leap
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${RangedAttackMode}
			{
				if !${Me.ToActor.IsStealthed}
				{
					call CastStealth

				}

				if ${Me.ToActor.IsStealthed}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 0 0 1
				}

			}
			break
		case Pounce
			if ${PBAoEMode} && ${Mob.Count}>=2 && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${BowAttacksMode}
			{
				if !${Me.ToActor.IsStealthed}
				{
					call CastStealth

				}

				if ${Me.ToActor.IsStealthed}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget} 0 0 1
				}

			}
			break
		Default
			xAction:Set[40]
			break
		}
}

function Post_Combat_Routine(int xAction)
{


	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	;cancel stealth
	if ${Me.Maintained[Shroud](exists)}
	{
		Me.Maintained[Shroud]:Cancel
	}

	switch ${PostAction[${xAction}]}
	{

		case AA_Intoxication
		case Summon_Arrows
			call CastSpellRange ${PostSpellRange[${xAction},1]}
			break
		case BuffPoison
			if !${Me.Maintained[caustic poison](exists)}
			{
				Me.Inventory[Master's Caustic Poison]:Use
			}
			break
		default
			return PostCombatRoutineComplete
			break
	}


}

function Have_Aggro()
{
	;Turn on Parry AA Impenetrable
	if ${Me.ToActor.Health}<30
	{
		call CastSpellRange 395
	}

	if ${agroid}==${KillTarget}
	{
		;evade
		call CastSpellRange 180 0 0 0 ${agroid} 0 0 1
	}
	;TODO Hunting Hawk
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

function CastStealth()
{

	;sneak attack
	variable int Stealth1=320
	;stalk
	variable int Stealth2=185
	;stealth
	variable int Stealth3=201
	;AA_Smoke_Bomb
	variable int Stealth4=393

	if  ${Me.Ability[${SpellType[${Stealth1}]}].IsReady} && !${RangedAttackMode}
	{
		call CastSpellRange ${Stealth1} 0 1 1 ${KillTarget} 0 0 1
	}
	elseif ${Me.Ability[${SpellType[${Stealth4}]}].IsReady} && ${PBAoEMode}
	{
		call CastSpellRange ${Stealth4}
	}
	elseif ${Me.Ability[${SpellType[${Stealth2}]}].IsReady}
	{
		call CastSpellRange ${Stealth2} 0 0 0 ${KillTarget} 0 0 1
	}
	elseif ${Me.Ability[${SpellType[${Stealth3}]}].IsReady}
	{
		call CastSpellRange ${Stealth3} 0 0 0 0 0 0 1
	}

	wait 20 ${Me.ToActor.IsStealthed}
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