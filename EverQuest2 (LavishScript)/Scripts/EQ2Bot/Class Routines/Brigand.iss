;*****************************************************
;Brigand.iss 20061019a
;by Pygar, much adapted from Kayre
; Initial attempt
; Testing CA Spell casting (allowing movement)
; Need to add AA support
; Need to add checkposition calls to CastCARange only when CastCA returns out of position
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare SnareMode bool script 0     
        declare TankMode bool script 0


	;Custom Equipment
	declare WeaponRapier string script 
	declare WeaponSword string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script
	
	declare EquipmentChangeTimer int script	
	
	call EQ2BotLib_Init
		
	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	SnareMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Snares,FALSE]}]
	TankMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Try to Tank,FALSE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponRapier:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Rapier",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]	

}

function Buff_Init()
{
;echo buff init
	PreAction[1]:Set[Street_Smarts]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Reflexes]
	PreSpellRange[2,1]:Set[318]

	PreAction[3]:Set[Pathfinding]
	PreSpellRange[3,1]:Set[302]
	
	PreAction[5]:Set[Offensive_Stance]
	PreSpellRange[5,1]:Set[290]
	
	PreAction[7]:Set[Confound]
	PreSpellRange[7,1]:Set[27]

	PreAction[8]:Set[Deffensive_Stance]
	PreSpellRange[8,1]:Set[295]	
}

function Combat_Init()
{

	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[95]
	
	Action[2]:Set[Melee_Attack]
	SpellRange[2,1]:Set[150]
	SpellRange[2,2]:Set[151]
	SpellRange[2,3]:Set[152]
	SpellRange[2,4]:Set[153]
	SpellRange[2,5]:Set[154]
	
	Action[3]:Set[Snare]
	SpellRange[3,1]:Set[235]
	SpellRange[3,2]:Set[238]

	Action[4]:Set[Back_Attack]
	SpellRange[4,1]:Set[103]
	SpellRange[4,2]:Set[102]
	SpellRange[4,3]:Set[101]
	SpellRange[4,4]:Set[100]
	
	Action[5]:Set[Mastery]
	
	Action[6]:Set[DoubleUp]
	SpellRange[6,1]:Set[319]
	
	Action[7]:Set[Flank_Attack]
	SpellRange[7,1]:Set[110]
	SpellRange[7,1]:Set[111]
	
	Action[8]:Set[Debuff]
	SpellRange[8,1]:Set[50]	
	
	Action[9]:Set[Stealth_Attack]
	SpellRange[9,1]:Set[185]
	SpellRange[9,2]:Set[150]
	
	Action[10]:Set[Trickery]
	SpellRange[10,1]:Set[387]	
	
	Action[11]:Set[BandofThugs]
	SpellRange[11,1]:Set[386]

	Action[12]:Set[Taunt]
	SpellRange[12,1]:Set[160]
	
	Action[13]:Set[Combat_Buff]
	SpellRange[13,1]:Set[155]
	SpellRange[13,2]:Set[156]
	
	Action[14]:Set[Front_Attack]
	SpellRange[14,1]:Set[120]

	Action[15]:Set[Stun]
	SpellRange[15,1]:Set[190]	

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
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Pathfinding
			;included in eq2bot now
			break
		case Offensive_Stance
			;removed as eq2bot seems to override what we cast
			;if ${OffenseMode}
			;{
			;	call CastSpellRange ${PreSpellRange[${xAction},1]}
			;}
			;else
			;{
			;	Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			;}
			break

		case Confound
			if ${OffenseMode} 
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Deffensive_Stance
			;removed as eq2bot seems to override what we cast
			;if ${TankMode} && !${OffenseMode}
			;{
			;	call CastSpellRange ${PreSpellRange[${xAction},1]}
			;}
			;else
			;{
			;	Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			;}
			break		
		Default
			xAction:Set[20]
			break
	}

}

function Combat_Routine(int xAction)
{	
;echo combat routine

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}
	
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastCARange 303
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
	
	if ${DebuffMode}
	{
		;always keep encounter debuffs refreshed
		call CastSpellRange 50 0 0 0 ${KillTarget}
	}
	
	if ${OffenseMode}
	{
		if ${Target.Target.ID}!=${Me.ID}
		{
			Call GetBehind
		}
		
		switch ${Action[${xAction}]}
		{
			case Stealth_Attack
				if ${Target.Target.ID}!=${Me.ID}
				{
					;only attack if already in stealth (from post combat or agro drop)
					if !${MainTank} && ${Me.ToActor.Effect[Shroud](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
					{
						;call CastCARange 200
						call CastCARange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget}
					}
					break
				}
			case Melee_Attack
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},5]} 0 0 ${KillTarget}
				break	
			case AoE2
			
			case AoE1
				if ${AoEMode} && ${Mob.Count}>=2 
				{
					call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break

			case Snare
				if ${SnareMode} 
				{
					if ${Mob.Count}>=2
					
					{
						call CastCARange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget}
					}
					else
					{
						call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break

			case Back_Attack
				if ${Target.Target.ID}!=${Me.ID}
				{
					if !${MainTank}
					{
						call CastCARange ${SpellRange[${xAction},4]} ${SpellRange[${xAction},1]} 1 1 ${KillTarget}
					}
				}
				break
				
			case Mastery
				if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
				{			
					if (${Me.Ability[Orc Master's Sinister Strike].IsReady} || ${Me.Ability[Gnoll Master's Sinister Strike].IsReady}) && ${Actor[${KillTarget}](exists)}
					{
						Target ${KillTarget}
						call CheckPosition 1 1

						;********* uncomment the sinister strikes you have *****************

						;Me.Ability[Orc Master's Sinister Strike]:Use
						Me.Ability[Gnoll Master's Sinister Strike]:Use
						;Me.Ability[Ghost Master's Sinister Strike]:Use
						;Me.Ability[Skeleton Master's Sinister Strike]:Use
						Me.Ability[Zombie Master's Sinister Strike]:Use
						;Me.Ability[Centaur Master's Sinister Strike]:Use
						Me.Ability[Giant Master's Sinister Strike]:Use
						;Me.Ability[Treant Master's Sinister Strike]:Use
						;Me.Ability[Elemental Master's Sinister Strike]:Use
						;Me.Ability[Fairy Master's Sinister Strike]:Use
						Me.Ability[Goblin Master's Sinister Strike]:Use
						Me.Ability[Golem Master's Sinister Strike]:Use
						;Me.Ability[Bixie Master's Sinister Strike]:Use
						Me.Ability[Cyclops Master's Sinister Strike]:Use
						;Me.Ability[Djinn Master's Sinister Strike]:Use
						;Me.Ability[Harpy Master's Sinister Strike]:Use
						;Me.Ability[Naga Master's Sinister Strike]:Use
						Me.Ability[Droag Master's Sinister Strike]:Use
						;Me.Ability[Aviak Master's Sinister Strike]:Use
						;Me.Ability[Beholder Master's Sinister Strike]:Use
						;Me.Ability[Ravasect Master's Sinister Strike]:Use

						;********* uncomment the sinister strikes you have *****************
					}
				}
				break
			
			case DoubleUp
				call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			
			case Flank_Attack
				if ${Target.Target.ID}!=${Me.ID}
				{
					call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},1]} 0 0 ${KillTarget}
					break
				}
			case Debuff
				break
			case Trickery
				break
			case BandofThugs
				call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Taunt
				break
			case Combat_Buff
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0
				break

			case Front_Attack
				;Need check here to use only if all other attack timers not ready
				;call CastCARange ${SpellRange[${xAction},1]} 0 1 2 ${KillTarget}
				break
				
			case Stun
				if !${Target.IsEpic}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break

			default
				xAction:Set[20]
				break
		}
	}
	;Designed for solo play.  Attempt stun + backstab, flip mob, etc.
	elseif !${OffenseMode} && !${TankMode}
	{
		if ${Me.Ability[Cheap Shot].IsReady}
		{
			;stun the mob
			Call CastCARange 190 0 1 0 ${KillTarget}
	
			;removed getbehind as it seemed to make it run more with it.	
			Call CastCARange 103 0 1 1 ${KillTarget}
		}
		;add support for walk the plank here
		
		switch ${Action[${xAction}]}
			{
				case Stealth_Attack
					break				
				case Melee_Attack
					call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},5]} 0 0 ${KillTarget}
					break	
				case AoE2
				
				case AoE1
					if ${AoEMode} && ${Mob.Count}>=2 
					{
						call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
					break
	
				case Snare
					if ${SnareMode} 
					{
						if ${Mob.Count}>=2
						
						{
							call CastCARange ${SpellRange[${xAction},3]} 0 0 0 ${KillTarget}
						}
						else
						{
							call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget}
						}
					}
					break
	
				case Back_Attack
					break
				case Mastery
					break
				case Front_Attack
					Call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					break				
				
				case DoubleUp
					call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					break
				
				case Flank_Attack
					break
				case Debuff
					break
				case Trickery
					call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}				
				case BandofThugs
					call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					break
				case Taunt
					break
				case Combat_Buff
					call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0
					break
					
				case Stun
					break
				default
					xAction:Set[20]
					break
		}
	}
	;Try to be a tank
	elseif !${OffenseMode} && ${TankMode}
	{
		call GetinFront
		
		switch ${Action[${xAction}]}
		{

			case Taunt
				call CastCARange ${SpellRange[${xAction},1]} 0 0 0
				break
				
			case Stealth_Attack
								
			case Melee_Attack
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},5]} 0 0 ${KillTarget}
				break	
				
			case AoE1
				if ${AoEMode} && ${Mob.Count}>=2 
				{
					call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
		
			case Snare
				if ${SnareMode} 
				{
					if ${Mob.Count}>=2
					{
						call CastCARange ${SpellRange[${xAction},3]} 0 0 0 ${KillTarget}
					}
					else
					{
						call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget}
					}
				}
				break
	
			case Back_Attack
				break
			case Mastery
				break
			case Front_Attack
				Call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break				
			
			case DoubleUp
				call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
				
			case Flank_Attack
				break
			case Debuff
				break
			case Trickery
				call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}				
				break
			case BandofThugs
				call CastCARange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break

			case Combat_Buff
				call CastCARange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0
				break
					
			case Stun
				if !${Target.IsEpic}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break

			default
				xAction:Set[20]
				break
		}		
	}
}

function Post_Combat_Routine()
{
	if ${Me.Maintained[Shroud](exists)}
	{
		Me.Maintained[Shroud]:Cancel
	}
}

function Have_Aggro()
{
	
	echo I have agro from ${agroid}
	if ${OffenseMode}
	{
		;Trickery
		call CastCARange 387 0 1 0 ${agroid}
		;agro dump
		call CastCARange 185 0 1 0 ${agroid}
	}
}

function Lost_Aggro()
{
	if ${Target.Target.ID}!=${Me.ID}
	{
		if ${MainTank}
		{
			call CastCARange 103 100 1 1 ${KillTarget}
			call CastCARange 160 0 0 0 ${KillTarget}
		}
	}
	
}

function MA_Lost_Aggro()
{
	
	;if tank lost agro, and I don't have agro, save the warlocks ass
	if !${KillTarget.Target.ID}==${Me.ID} 
	{
		call CastCARange 270 0 0 0 ${KillTarget}
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
	
	if ${ShardMode}
	{
		call Shard
	}
	
}

function CastCARange(int start, int finish, int xvar1, int xvar2, int targettobuff, int notall, int refreshtimer)
{
	variable bool fndspell
	variable int tempvar=${start}
	variable int originaltarget

	if ${Me.ToActor.Power}<5
	{
		return -1
	}

	do
	{
		if ${SpellType[${tempvar}].Length}
		{
			
			if ${Me.Ability[${SpellType[${tempvar}]}].IsReady}
			{
				if ${targettobuff}
				{
					fndspell:Set[FALSE]
					tempgrp:Set[1]
					do
					{
						if ${Me.Maintained[${tempgrp}].Name.Equal[${SpellType[${tempvar}]}]} && ${Me.Maintained[${tempgrp}].Target.ID}==${targettobuff} && (${Me.Maintained[${tempgrp}].Duration}>${refreshtimer} || ${Me.Maintained[${tempgrp}].Duration}==-1)
						{
							fndspell:Set[TRUE]
							break
						}
					}
					while ${tempgrp:Inc}<=${Me.CountMaintained}

					if !${fndspell}
					{
						if !${Actor[${targettobuff}](exists)} || ${Actor[${targettobuff}].Distance}>35
						{
							return -1
						}

						if ${xvar1} || ${xvar2}
						{
							;need less anal checkposition to keep from running around like an epilepic monkey
							call CheckPosition ${xvar1} ${xvar2}
						}

						if ${Target(exists)}
						{
							originaltarget:Set[${Target.ID}]
						}

						if ${targettobuff(exists)}
						{
							if !(${targettobuff}==${Target.ID}) && !(${targettobuff}==${Target.Target.ID} && ${Target.Type.Equal[NPC]}) 
							{
								target ${targettobuff}
								wait 10 ${Target.ID}==${targettobuff}
							}
						}

						call CastCA "${SpellType[${tempvar}]}" ${tempvar}

						if ${Actor[${originaltarget}](exists)}
						{
							target ${originaltarget}
							wait 10 ${Target.ID}==${originaltarget}
						}

						if ${notall}==1
						{
							return -1
						}
					}
				}
				else
				{
					if !${Me.Maintained[${SpellType[${tempvar}]}](exists)} || (${Me.Maintained[${SpellType[${tempvar}]}].Duration}<${refreshtimer} && ${Me.Maintained[${SpellType[${tempvar}]}].Duration}!=-1)
					{
						if ${xvar1} || ${xvar2}
						{
							call CheckPosition ${xvar1} ${xvar2}
						}

						call CastCA "${SpellType[${tempvar}]}" ${tempvar}

						if ${notall}==1
						{
							return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
						}
					}
				}
			}
		}

		if !${finish}
		{
			return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
		}
	}
	while ${tempvar:Inc}<=${finish}

	return ${Me.Ability[${SpellType[${tempvar}]}].TimeUntilReady}
}

function CastCA(string spell, int spellid)
{
		
	Me.Ability[${spell}]:Use
	
	do
	{
		WaitFor "Fizzled!" "Interrupted!" "Too far away" "Can't see target" "Not during combat" "Would not take effect" "resisted" "No eligible target" "Not an enemy" "Target is not alive" 1

	}
	while ${WaitFor}==1 || ${WaitFor}==2

	switch ${WaitFor}
	{
		
		case 3
			return TOOFARAWAY

		case 4
			return CANTSEETARGET

		case 5
			return NOTDURINGCOMBAT

		case 6
			return NOTTAKEEFFECT

		case 7
			return RESISTED

		case 8
			return NOELIGIBLETARGET

		case 9
			return NOTENEMY

		case 10
			return TARGETNOTALIVE
	}
	
	do
	{
		waitframe
	}
	while ${Me.CastingSpell}
	
	return SUCCESS
}