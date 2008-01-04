;*****************************************************
;Assassin.iss  20070725a
;by Pygar
;
;
;20070725a
;	Did an old version make it to svn?
; Fixed LOTS - AA's work now, concealment and vanish work now
;	Cleaned up weapon change for new AA requirements
;	General fixes
;
; 20070404a
; Updated for latest eq2bot functionality
; Added Poison Usage - Must edit iss file for names if you want to use other then enfeebling, caustic, and turgur
; Fixed Mastery Usage
; Fixed charging to pulls
; Fixed issue with haveaggro
;
; 20061229a
; Added Toggle for using range attacks
; Moved makeshift to normal CA as it has min range of 0
; Added AA support
; Added Offhand and WeaponSpear support for AA and gear swap
; Needs ammo check for ranged?
;
; 20061229b
; Fixed some bad isready calls
;
; 20061229c
; Added missing weaponchange function
;
; 20061229d
; Removed a few calls that were causing an IS crash bug.  Lax looking into it
;
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare UseRangeMode bool script 0
	declare SurroundingAttacksMode bool Script FALSE

	;Custom Equipment
	declare PoisonCureItem string script
	declare BuffShadowsGroupMember string script
	declare BuffPoisonGroupMember string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	UseRangeMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Range Arts,FALSE]}]
	BuffShadowsGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffShadowsGroupMember,]}]
	BuffPoisonGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPoisonGroupMember,]}]
	SurroundingAttacksMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Surrounding Attacks,FALSE]}]

	;POISON DECLERATIONS - Still Experimental, but is working for these 3 for me.
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DammagePoisonShort:Set[caustic poison]
	DebuffPoisonShort:Set[enfeebling poison]
	UtilityPoisonShort:Set[ignorant bliss]

}

function Buff_Init()
{
	PreAction[1]:Set[Villany]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Focus]
	PreSpellRange[2,1]:Set[27]

	PreAction[3]:Set[Pathfinding]
	PreSpellRange[3,1]:Set[302]

	PreAction[4]:Set[Apply_Poison]
	PreSpellRange[4,1]:Set[387]

	PreAction[5]:Set[Shadows]
	PreSpellRange[5,1]:Set[356]

	PreAction[6]:Set[AA_Neurotoxic_Coating]
	PreSpellRange[6,1]:Set[389]

	PreAction[7]:Set[AA_Surrounding_Attacks]
	PreSpellRange[7,1]:Set[384]

	PreAction[8]:Set[Poisons]

}

function Combat_Init()
{

	Action[1]:Set[Debuff]
	MobHealth[1,1]:Set[20]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[20]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[50]
	SpellRange[1,2]:Set[51]
	SpellRange[1,3]:Set[52]

	Action[2]:Set[AA_Bladed_Opening]
	SpellRange[2,1]:Set[381]
	MobHealth[2,1]:Set[80]
	MobHealth[2,2]:Set[100]

	Action[3]:Set[Melee_Attack]
	SpellRange[3,1]:Set[150]

	Action[4]:Set[DoT]
	MobHealth[4,1]:Set[20]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[20]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[71]
	SpellRange[4,2]:Set[70]

	Action[5]:Set[Concealment]
	MobHealth[5,1]:Set[20]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[359]
	SpellRange[5,2]:Set[130]
	SpellRange[5,3]:Set[131]
	SpellRange[5,4]:Set[132]
	SpellRange[5,5]:Set[133]
	SpellRange[5,6]:Set[135]
	SpellRange[5,7]:Set[96]
	SpellRange[5,8]:Set[95]

	Action[6]:Set[Mastery]

	Action[7]:Set[Finishing_Blow]
	SpellRange[7,1]:Set[360]

	Action[8]:Set[Vanish]
	MobHealth[8,1]:Set[20]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[358]
	SpellRange[8,2]:Set[130]
	SpellRange[8,3]:Set[131]
	SpellRange[8,4]:Set[132]
	SpellRange[8,5]:Set[133]
	SpellRange[8,6]:Set[135]
	SpellRange[8,7]:Set[96]
	SpellRange[8,8]:Set[95]

	Action[9]:Set[Shrouded_Attack]
	SpellRange[9,1]:Set[186]

	Action[10]:Set[Cripple]
	SpellRange[10,1]:Set[110]

	Action[11]:Set[Combat_Buff]
	MobHealth[11,1]:Set[50]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[155]

	Action[12]:Set[Stalk]
	SpellRange[12,1]:Set[185]

	Action[13]:Set[Makeshift]
	SpellRange[13,1]:Set[250]
	SpellRange[13,2]:Set[382]

	Action[14]:Set[Range_Rear]
	SpellRange[14,1]:Set[251]
	SpellRange[15,2]:Set[256]
	SpellRange[16,3]:Set[257]

	Action[17]:Set[Stun]
	SpellRange[17,1]:Set[190]

	Action[18]:Set[Evade]
	SpellRange[18,1]:Set[185]

	Action[19]:Set[AA_Spinning_Spear]
	SpellRange[19,1]:Set[383]

	Action[20]:Set[AA_Frontload]
	SpellRange[20,1]:Set[390]
	MobHealth[20,1]:Set[40]
	MobHealth[20,2]:Set[100]

	Action[21]:Set[AA_Intoxication]
	SpellRange[21,1]:Set[392]
}


function PostCombat_Init()
{
	PreAction[1]:Set[Slip]
	PreSpellRange[1,1]:Set[202]
}

function Buff_Routine(int xAction)
{
	declare BuffTarget string local
	call ActionChecks


	ExecuteAtom CheckStuck

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}


	switch ${PreAction[${xAction}]}
	{
		case AA_Neurotoxic_Coating
		case Pathfinding
		case Focus
		case Villany
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Apply_Poison
			BuffTarget:Set[${UIElement[cbBuffPoisonGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break

		case Shadows
			BuffTarget:Set[${UIElement[cbBuffShadowsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break

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

	if ${Me.ToActor.IsStealthed}
	{
		call CastStealthAttack
	}

	;smokebomb check
	if ${Me.Ability[${SpellType[387]}].IsReady} && !${Me.ToActor.IsStealthed}
	{
		call CastSpellRange 387 0 1 1
		call CastStealthAttack
	}

	;Getaway check
	if ${Me.Ability[${SpellType[391]}].IsReady} && !${Me.ToActor.IsStealthed}
	{
		call CastSpellRange 391 0 1 1
		call CastStealthAttack
	}

	;Poison Combination Check disabled for now cause I can't seem to check if mob IsAfflicted by Noxious
	if ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388 0 1 1
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	Call ActionChecks

	switch ${Action[${xAction}]}
	{
		case Debuff
			if ${DebuffMode}
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

		case Makeshift
			call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget} 0 0 1
			break

		case AA_Intoxication
		case Evade
		case Stun
		case Cripple
		case Melee_Attack
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			break

		case DoT
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget} 0 0 1
				}
			}
			break

		case Vanish
		case Concealment
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				if ${AoEMode} && ${Mob.Count}>=2
				{
					call CastSpellRange ${SpellRange[${xAction},7]} ${SpellRange[${xAction},8]} 1 1 ${KillTarget} 0 0 1
				}
				call CastSpellRange ${SpellRange[${xAction},2]} ${SpellRange[${xAction},6]} 1 1 ${KillTarget} 0 0 1
			}
			break

		case Stalk
		case Shrouded_Attack
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 0 0 1
				call CastStealthAttack
			}
			break

		case Combat_Buff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			break

		case Range_Rear
			call CastSpellRange ${SpellRange[151]} 0 1 1 ${KillTarget} 0 0 1
			if ${UseRangeMode}
			{
				if ${Actor[${KillTarget}].Distance}<5
				{
					press -hold ${backward}
					wait 2
					press -release ${backward}
				}

				if !${Actor[${KillTarget}].Distance}>5
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
				}
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

		case AA_Bladed_Opening
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
			}
			break

		case AA_Spinning_Spear
			if ${AoEMode} && ${Mob.Count}>=2 && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		case AA_Frontload
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
			}
			break

		default
			xAction:Set[40]
			break
	}
}

function Post_Combat_Routine()
{
	switch ${Action[${xAction}]}
	{
		case Slip
			if !${Me.ToActor.IsStealthed}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{

	echo I have agro from ${aggroid}

	;agro dump
	call CastSpellRange 180 0 0 0 ${aggroid}
	call CastSpellRange 185 0 0 0 ${aggroid}
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{
	wait 20
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

function CastStealthAttack()
{
	if ${Me.Ability[${SpellType[96]}].IsReady} && ${AoEMode} && ${Mob.Count}>=2
	{
		call CastSpellRange 96 0 1 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[95]}].IsReady} && ${AoEMode} && ${Mob.Count}>=2
	{
		call CastSpellRange 95 0 1 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[131]}].IsReady}
	{
		call CastSpellRange 131 0 1 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[132]}].IsReady}
	{
		call CastSpellRange 132 0 1 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[130]}].IsReady}
	{
		call CastSpellRange 130 0 1 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[133]}].IsReady}
	{
		call CastSpellRange 133 0 1 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[135]}].IsReady}
	{
		call CastSpellRange 135 0 1 0 ${KillTarget}
	}

}

function ActionChecks()
{

	if ${ShardMode}
	{
		call Shard
	}

}


