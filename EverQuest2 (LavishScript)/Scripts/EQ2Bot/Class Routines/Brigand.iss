;*****************************************************
;Brigand.iss 20070822a
;by Pygar
;
;20070822a
; Fixed some typo's in spell list
; Removed Weapon Swapping
; Fixed feign on agro
; Fixed some range checks, should increase dps when combat is initiated when out of range.
;
;20070725a
; Fixed weapon swapping for new aa requirements,
; Adjusted announcement code
; Tweaked DPS Buff selections
; General fixes
;
;20070508a
; Fixed some old bugs brought back from consolidating versions.
;
;20070504a
; Source files diveraged, attempt to consolidate them back to single script
; May have introduced old bugs again, but fixed many.
;
;
; Final Tuning / AA configuration
; I believe this version represents the best a brigand can be botted
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare OffenseMode bool script 1
	declare DebuffMode bool script 0
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
	declare PetMode bool script 1

	;POISON DECLERATIONS - Still Experimental, but is working for these 3 for me.
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DammagePoisonShort:Set[caustic poison]
	DebuffPoisonShort:Set[enfeebling poison]
	UtilityPoisonShort:Set[ignorant bliss]

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	SnareMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Snares,FALSE]}]
	TankMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Try to Tank,FALSE]}]
	AnnounceMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Announce Debuffs,FALSE]}]
	BuffLunge:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Lunge Reversal,FALSE]}]
	MaintainPoison:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MaintainPoison,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

}

function Buff_Init()
{

	PreAction[1]:Set[Street_Smarts]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Reflexes]
	PreSpellRange[2,1]:Set[318]

	PreAction[3]:Set[Offensive_Stance]
	PreSpellRange[3,1]:Set[291]

	PreAction[4]:Set[Confound]
	PreSpellRange[4,1]:Set[27]

	PreAction[5]:Set[Deffensive_Stance]
	PreSpellRange[5,1]:Set[292]

	PreAction[6]:Set[Poisons]

	PreAction[7]:Set[AA_Lunge_Reversal]
	PreSpellRange[7,1]:Set[395]

	PreAction[8]:Set[AA_Evasiveness]
	PreSpellRange[8,1]:Set[397]
}

function Combat_Init()
{

	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[95]

	Action[2]:Set[AA_WalkthePlank]
	SpellRange[2,1]:Set[385]

	Action[3]:Set[Rear_Attack1]
	SpellRange[3,1]:Set[103]

	Action[4]:Set[Rear_Attack2]
	SpellRange[4,1]:Set[102]

	Action[5]:Set[Rear_Attack3]
	SpellRange[5,1]:Set[101]

	Action[6]:Set[Rear_Attack4]
	SpellRange[6,1]:Set[100]

	Action[7]:Set[Mastery]

	Action[8]:Set[DoubleUp]
	SpellRange[8,1]:Set[319]

	Action[9]:Set[Flank_Attack1]
	SpellRange[9,1]:Set[110]

	Action[10]:Set[Flank_Attack2]
	SpellRange[10,1]:Set[111]

	Action[11]:Set[BandofThugs]
	MobHealth[11,1]:Set[50]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[386]

	Action[12]:Set[Taunt]
	Power[12,1]:Set[20]
	Power[12,2]:Set[100]
	MobHealth[12,1]:Set[10]
	MobHealth[12,2]:Set[100]
	SpellRange[12,1]:Set[160]
	SpellRange[12,2]:Set[389]

	Action[13]:Set[Melee_Attack1]
	Power[13,1]:Set[20]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[150]

	Action[14]:Set[Melee_Attack2]
	Power[14,1]:Set[20]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[151]

	Action[15]:Set[Melee_Attack3]
	Power[15,1]:Set[20]
	Power[15,2]:Set[100]
	SpellRange[15,1]:Set[152]

	Action[16]:Set[Melee_Attack4]
	Power[16,1]:Set[20]
	Power[16,2]:Set[100]
	SpellRange[16,1]:Set[153]

	Action[17]:Set[Melee_Attack5]
	Power[17,1]:Set[20]
	Power[17,2]:Set[100]
	SpellRange[6,1]:Set[154]

	Action[18]:Set[Snare]
	Power[18,1]:Set[60]
	Power[18,2]:Set[100]
	SpellRange[18,1]:Set[235]
	SpellRange[18,2]:Set[238]

	Action[19]:Set[AA_Torporous]
	SpellRange[19,1]:Set[381]

	Action[20]:Set[AA_Traumatic]
	SpellRange[20,1]:Set[382]

	Action[21]:Set[AA_BootDagger]
	SpellRange[21,1]:Set[386]

	Action[22]:Set[Front_Attack]
	SpellRange[22,1]:Set[120]

	Action[23]:Set[Debuff]
	Power[23,1]:Set[20]
	Power[23,2]:Set[100]
	SpellRange[23,1]:Set[50]

	Action[24]:Set[Lower_Agro]
	Power[24,1]:Set[40]
	Power[24,2]:Set[100]
	SpellRange[24,1]:Set[185]

	Action[25]:Set[Trickery]
	SpellRange[25,1]:Set[357]

	Action[26]:Set[Stun]
	Power[26,1]:Set[20]
	Power[26,2]:Set[100]
	SpellRange[26,1]:Set[190]
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
		case Street_Smarts
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Reflexes
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

		case Confound
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
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		Default
			xAction:Set[40]
			break
	}

}

function Combat_Routine(int xAction)
{
	if !${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	Call ActionChecks

	;if stealthed, use ambush
	if !${MainTank} && ${Me.ToActor.IsStealthed} && ${Me.Ability[${SpellType[130]}].IsReady}
	{
		call CastSpellRange 130 0 1 0 ${KillTarget}
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	;use best debuffs on target if epic
	if ${Actor[${KillTarget}].IsEpic}
	{
		if ${Me.Ability[${SpellType[155]}].IsReady}
		{
			call CastSpellRange 155 0 1 0 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[156]}].IsReady}
		{
			call CastSpellRange 156 0 1 0 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[100]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 100 0 1 1 ${KillTarget} 0 0 1
			if ${AnnounceMode} && ${Me.Maintained[${SpellType[100]}](exists)}
			{
				EQ2Execute /g %t is Dispastched - All Resistances Severely lowered for 15s - Nuke Now
				EQ2Execute /raidsay %t is Dispastched - All Resistances Severely lowered for 15s - Nuke Now
			}
		}

		if ${Me.Ability[${SpellType[101]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 101 0 1 1 ${KillTarget} 0 0 1
		}
	}

	;if heroic and over 80% health, use dps buffs
	if (${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].Health}>80) || (${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}>20)
	{
		if ${Me.Ability[${SpellType[155]}].IsReady}
		{
			call CastSpellRange 155 0 1 0 ${KillTarget} 0 0 1
		}
		if ${Me.Ability[${SpellType[156]}].IsReady}
		{
			call CastSpellRange 156 0 1 0 ${KillTarget} 0 0 1
		}
	}

	if ${DebuffMode}
	{
		if ${Me.Ability[${SpellType[50]}].IsReady}
		{
			call CastSpellRange 50 0 1 0 ${KillTarget} 0 0 1
		}

		call CheckCondition MobHealth 80 100
		if ${Me.Ability[${SpellType[100]}].IsReady} && ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[100]}](exists)} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 100 0 1 1 ${KillTarget} 0 0 1
			if ${AnnounceMode} && ${Me.Maintained[${SpellType[100]}](exists)}
			{
				EQ2Execute /g %t is Dispastched - All Resistances Severely lowered for 15s - Nuke Now
				EQ2Execute /raidsay %t is Dispastched - All Resistances Severely lowered for 15s - Nuke Now
			}
		}

		call CheckCondition MobHealth 80 100
		if ${Me.Ability[${SpellType[101]}].IsReady} && ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[101]}](exists)}
		{
			call CastSpellRange 101 0 1 1 ${KillTarget} 0 0 1
		}
	}

	if ${OffenseMode}
	{
 		;This routine optomized for group dps role
		switch ${Action[${xAction}]}
		{
			case Melee_Attack1
			case Melee_Attack2
			case Melee_Attack3
			case Melee_Attack4
			case Melee_Attack5
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AoE1
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
						if ${Mob.Count}>=2
						{
							call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget} 0 0 1
						}
						else
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
						}
					}
				}
				break
			case Rear_Attack1
			case Rear_Attack2
			case Rear_Attack3
			case Rear_Attack4
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
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
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case AA_Torporous
			case AA_Traumatic
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case AA_BootDagger
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case DoubleUp
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				break
			case Flank_Attack1
			case Flank_Attack2
				;check valid rear position
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				;check right flank
				elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				;check left flank
				elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				elseif ${Target.Target.ID}!=${Me.ID}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget}
				}
			case Debuff
			case Trickery
			case Taunt
				break
			case BandofThugs
				call CheckCondition MobHealth ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]} && ${PetMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
				}
				break
			case Front_Attack
				;check right flank
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				;check left flank
				elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				;check front
				elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>125 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<235) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-235 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-125)
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
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
	;Designed for solo play.  Attempt stun + backstab, flip mob, etc.
	elseif !${OffenseMode} && !${TankMode}
	{
		if ${Me.Ability[Walk the Plank].IsReady} && ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead}
		{
				call CastSpellRange 385 0 1 0 ${KillTarget}
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				{
					call CastSpellRange 100 101 0 0 ${KillTarget} 0 0 1
				}
		}

		if ${Me.Ability[Cheap Shot].IsReady} && ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead}
		{
			;stun the mob
			Call CastSpellRange 190 0 1 0 ${KillTarget} 0 0 1

			if ${Me.Maintained[Cheap Shot](exists)} && ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead}
			{
				;check valid rear position
				if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				{
					call CastSpellRange 110 111 0 0 ${KillTarget} 0 0 1
				}
				;check right flank
				elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
				{
					call CastSpellRange 110 111 0 0 ${KillTarget} 0 0 1
				}
				;check left flank
				elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
				{
					call CastSpellRange 110 111 0 0 ${KillTarget} 0 0 1
				}
				else
				{
					call CastSpellRange 110 111 1 3 ${KillTarget}
				}
			}
		}

		switch ${Action[${xAction}]}
			{
				case AA_Torporous
				case AA_Traumatic
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					}
					break
				case AA_BootDagger
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					}
					break
				case Melee_Attack1
				case Melee_Attack2
				case Melee_Attack3
				case Melee_Attack4
				case Melee_Attack5
				case Front_Attack
				case DoubleUp
				case Trickery
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					break
				case AoE1
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
							if ${Mob.Count}>=2
							{
								call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget} 0 0 1
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
							}
						}
					}
					break
				case AA_WalkthePlank
				case Rear_Attack1
				case Rear_Attack2
				case Rear_Attack3
				case Rear_Attack4
				case Flank_Attack1
				case Flank_Attack2
				case Mastery
				case Debuff
				case Stun
				case Taunt
					break
				case BandofThugs
					call CheckCondition MobHealth ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]} && ${PetMode}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
					}
					break
				default
					xAction:Set[40]
					break
		}
	}
	;Try to be a tank
	elseif !${OffenseMode} && ${TankMode}
	{
		switch ${Action[${xAction}]}
		{

			case Taunt
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
						call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget} 0 0 1
					}
				}
				break
			case AA_Torporous
			case AA_Traumatic
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case AA_BootDagger
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case Melee_Attack1
			case Melee_Attack2
			case Melee_Attack3
			case Melee_Attack4
			case Melee_Attack5
			case Front_Attack
			case DoubleUp
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				break
			case AoE1
				if ${AoEMode} && ${Mob.Count}>=2
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case Snare
				if ${SnareMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Mob.Count}>=2
						{
							call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget} 0 0 1
						}
						else
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
						}
					}
				}
				break
			case Debuff
			case Rear_Attack1
			case Rear_Attack2
			case Rear_Attack3
			case Rear_Attack4
			case Mastery
			case Flank_Attack1
			case Flank_Attack2
				break
			case AA_WalkthePlank
				if ${Me.Ability[Walk the Plank].IsReady}
				{
						call CastSpellRange 385 0 1 0 ${KillTarget}
						if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
						{
							call CastSpellRange 100 101 0 0 ${KillTarget} 0 0 1
						}
				}
			case Trickery
				if ${Target.Target.ID}==${Me.ID}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case BandofThugs
				call CheckCondition MobHealth ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]} && ${PetMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
				}
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
	if ${OffenseMode} && ${Me.Ability[${SpellType[387]}].IsReady} && ${agroid}>0
	{
		;Trickery
		call CastSpellRange 387 0 1 0 ${agroid} 0 0 1
	}
	elseif ${agroid}>0
	{
		if ${Me.Ability[${SpellType[185]}].IsReady}
		{
			;agro dump
			call CastSpellRange 185 0 1 0 ${agroid} 0 0 1
		}
		elseif ${Me.Ability[${SpellType[387]}].IsReady}
		{
			;feign
			call CastSpellRange 387 0 1 0 ${agroid} 0 0 1
		}
		else
		{
			call CastSpellRange 181 0 1 0 ${agroid} 0 0 1
		}

	}
}

function Lost_Aggro(int mobid)
{
	if ${Actor${mobid}].Target.ID}!=${Me.ID}
	{

		call CastSpellRange 270 0 1 0 ${Actor[${mobid}].ID}

		if ${MainTank}
		{
			KillTarget:Set[${mobid}]
			target ${mobid}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 100 0 1 1 ${aggroid} 0 0 1
			}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 101 0 1 1 ${aggroid} 0 0 1
			}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 102 0 1 1 ${aggroid} 0 0 1
			}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 103 0 1 1 ${aggroid} 0 0 1
			}

			call CastSpellRange 160 0 1 0 ${aggroid} 0 0 1
		}
	}

}

function MA_Lost_Aggro()
{

	;if tank lost agro, and I don't have agro, save the warlocks ass
	if ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
	{
		call CastSpellRange 270 0 1 0 ${KillTarget} 0 0 1
	}
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


