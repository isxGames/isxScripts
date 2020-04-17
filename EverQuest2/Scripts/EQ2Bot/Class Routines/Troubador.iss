;*****************************************************
;Troubador.iss 20090619a
;by Pygar
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20090619
  ;;;;

	declare OffenseMode bool script 1
	declare DebuffMode bool script 0
	declare DebuffMitMode bool script 1
	declare FullDebuffNamed bool script 1
	declare AoEMode bool script 0
	declare MezzMode bool script 0
	declare BowAttacksMode bool script 0
	declare RangedAttackMode bool script 0

	declare BuffDefense bool script FALSE
	declare BuffPower bool script FALSE
	declare BuffArcane bool script FALSE
	declare BuffElemental bool script FALSE
	declare BuffHaste bool script FALSE
	declare BuffHealth bool script FALSE
	declare BuffReflection bool script FALSE
	declare BuffAria bool script FALSE
	declare BuffStamina bool script FALSE
	declare BuffCasting bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffSelf bool script FALSE
	declare BuffDKTM bool script FALSE
	declare BuffDexSonata bool script FALSE
	declare Charm bool script FALSE

	;Initialized by UI
	declare BuffJesterCapTimers collection:int script
	declare BuffJesterCapIterator iterator script
	declare BuffJesterCapMember int script 1

	declare mezTarget1 int script
	declare mezTarget2 int script
	declare CharmTarget int script
	declare BuffTarget string script

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	DebuffMitMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Mit Debuff Spells,TRUE]}]
	FullDebuffNamedMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Named Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	Charm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Charm,FALSE]}]
	BowAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]

	BuffDefense:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Defense","FALSE"]}]
	BuffPower:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Power","FALSE"]}]
	BuffArcane:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Arcane","FALSE"]}]
	BuffElemental:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Elemental","FALSE"]}]
	BuffHaste:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Haste","FALSE"]}]
	BuffHealth:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Health","FALSE"]}]
	BuffReflection:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Reflection","FALSE"]}]
	BuffAria:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Aria","FALSE"]}]
	BuffStamina:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Stamina","FALSE"]}]
	BuffCasting:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Casting","FALSE"]}]
	BuffHate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Hate","FALSE"]}]
	BuffSelf:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Self","FALSE"]}]
	BuffDKTM:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff DKTM","FALSE"]}]
	BuffDexSonata:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff DexSonata","FALSE"]}]

	PosionCureItem:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Poison Cure Item","Antivenom Hypo Bracer"]}]
	BuffJesterCap:GetIterator[BuffJesterCapIterator]
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	;; check this at least every 0.5 seconds
	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
		{
			call CastSpellRange 388
			wait 5
			if ${Me.Maintained[${SpellType[388]}](exists)}
			{
				eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
				BDStatus:Set[0]
			}
		}

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Buff_AAAllegro]
	PreSpellRange[1,1]:Set[390]

	PreAction[2]:Set[Buff_Defense]
	PreSpellRange[2,1]:Set[31]

	PreAction[3]:Set[Buff_Power]
	PreSpellRange[3,1]:Set[21]

	PreAction[4]:Set[Buff_AADontKillTheMessenger]
	PreSpellRange[4,1]:Set[395]

	PreAction[5]:Set[Buff_AAHarmonization]
	PreSpellRange[5,1]:Set[383]

	PreAction[6]:Set[Buff_AAResonance]
	PreSpellRange[6,1]:Set[382]

	PreAction[7]:Set[Selos]
	PreSpellRange[7,1]:Set[381]

	PreAction[8]:Set[Buff_Reflection]
	PreSpellRange[8,1]:Set[26]

	PreAction[9]:Set[Buff_Aria]
	PreSpellRange[9,1]:Set[27]

	PreAction[10]:Set[Buff_Stamina]
	PreSpellRange[10,1]:Set[28]

	PreAction[11]:Set[Buff_Casting]
	PreSpellRange[11,1]:Set[29]

	PreAction[12]:Set[Buff_AAHeroicStoryTelling]
	PreSpellRange[12,1]:Set[404]

	PreAction[13]:Set[Buff_Hate]
	PreSpellRange[13,1]:Set[30]

	PreAction[14]:Set[Buff_Arcane]
	PreSpellRange[14,1]:Set[22]

	PreAction[15]:Set[Buff_Elemental]
	PreSpellRange[15,1]:Set[23]

	PreAction[16]:Set[Buff_Haste]
	PreSpellRange[16,1]:Set[24]

	PreAction[17]:Set[Buff_AAFortissimo]
	PreSpellRange[17,1]:Set[398]

	PreAction[18]:Set[Buff_Self]
	PreSpellRange[18,1]:Set[20]

	PreAction[19]:Set[Buff_AADexSonata]
	PreSpellRange[19,1]:Set[403]

	PreAction[20]:Set[Buff_AAUpTempo]
	PreSpellRange[20,1]:Set[402]

	PreAction[21]:Set[Buff_Health]
	PreSpellRange[21,1]:Set[25]
	
	PreAction[22]:Set[Mamba]
	PreSpellRange[22,1]:Set[410]

}

function Combat_Init()
{

}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	call ActionChecks
	call CheckHeals

	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}
	}

	switch ${PreAction[${xAction}]}
	{
		case Buff_AAUpTempo
			BuffTarget:Set[${UIElement[cbBuff_AAUpTempo@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2

			break
		case Buff_AADexSonata
			if ${BuffDexSonata}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Defense
			if ${BuffDefense}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Power
			if ${BuffPower}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Arcane
			if ${BuffArcane}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Elemental
			if ${BuffElemental}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Haste
			if ${BuffHaste}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Health
			if ${BuffHealth}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Reflection
			if ${BuffReflection}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Aria
			if ${BuffAria}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Stamina
			if ${BuffStamina}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Casting
			if ${BuffCasting}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Hate
			if ${BuffHate}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Self
			if ${BuffSelf}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break

		case Buff_AAAllegro
		case Selos
		case Buff_AAHarmonization
		case Buff_AAFortissimo
		case Buff_AAResonance
		case Buff_AADontKillTheMessenger
		case Buff_AAHeroicStoryTelling
		case Mamba
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		Default
			return Buff Complete
			break
	}

}

function Combat_Routine(int xAction)
{
	declare tempvar int local
	declare DebuffCnt int  0
	declare range int 0

	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[1]


	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${RangedAttackMode}
		range:Set[2]
	elseif ${BowAttacksMode}
		range:Set[3]


	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}
	}

	CurrentAction:Set[Combat Checking Power]
	call RefreshPower

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${DoHOs}
		call CastSpellRange 303

	if ${MezzMode}
		call Mezmerise_Targets

	if ${Charm}
		call DoCharm

	call PetAttack

	call DoJesterCap

	; PoTM
	if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[155]}](exists)} && ${Me.Ability[${SpellType[155]}].IsReady} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
	{
		call CastSpellRange 155 0 ${range} 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

	call CheckHeals

  ;Rhythym Blade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[397]}].IsReady} && !${Me.Maintained[${SpellType[397]}](exists)}
	{
		call CastSpellRange 397 0 1 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

  ;Cadence of Destruction
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[406]}].IsReady} && !${Me.Maintained[${SpellType[406]}](exists)}
	{
		call CastSpellRange 406 
		spellsused:Inc
	}
	
	;;;; Need VC here	
  ;Victorious Concerto
	if ${spellsused}<=${spellthreshold} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}) && ${Me.Ability[${SpellType[407]}].IsReady} && !${Me.Maintained[${SpellType[407]}](exists)}
	{
		call CastSpellRange 407 
		spellsused:Inc
	}

  ;Victorious Concerto
	if ${spellsused}<=${spellthreshold} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}) && ${Me.Ability[${SpellType[408]}].IsReady} && !${Me.Maintained[${SpellType[408]}](exists)}
	{
		call CastSpellRange 408 
		spellsused:Inc
	}

  ;Painful Lamentation
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)}
	{
		call CastSpellRange 92 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	

  ;Perfect Shrill
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady} && !${Me.Maintained[${SpellType[60]}](exists)}
	{
		call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	

  ;Thunderous Overature
	if ${spellsused}<=${spellthreshold} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[61]}].IsReady} && !${Me.Maintained[${SpellType[61]}](exists)}
	{
		call CastSpellRange 61 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	
  ;reverberation
	if ${spellsused}<=${spellthreshold} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[405]}].IsReady} && !${Me.Maintained[${SpellType[405]}](exists)}
	{
		call CastSpellRange 405 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	


	if ${spellsused}<=${spellthreshold} && ${DebuffMitMode} || (${FullDebuffNamed} && ${Actor[ID,${KillTarget}].Type.Equal[NamedNPC]})
	{
		if !${Me.Maintained[${SpellType[57]}](exists)} && ${Me.Ability[${SpellType[57]}].IsReady}
		{
			call CastSpellRange 57 0 ${range} 0 ${KillTarget} 0 0 1
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[51]}](exists)} && ${Me.Ability[${SpellType[51]}].IsReady} && !${RangedAttackMode}
		{
			call CastSpellRange 51 0 1 0 ${KillTarget} 0 0 1
			spellsused:Inc
		}
	}

	if ${spellsused}<=${spellthreshold} && (${DebuffMode} || (${FullDebuffNamed} && ${Actor[ID,${KillTarget}].Type.Equal[NamedNPC]})
	{
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[55]}](exists)} && ${Me.Ability[${SpellType[55]}].IsReady}
		{
			call CastSpellRange 55 0 ${range} 0 ${KillTarget} 0 0 1
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[56]}](exists)} && ${Me.Ability[${SpellType[56]}].IsReady}
		{
			call CastSpellRange 56 0 ${range} 0 ${KillTarget} 0 0 1
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[58]}](exists)} && ${Me.Ability[${SpellType[58]}].IsReady}
		{
			call CastSpellRange 58 0 ${range} 0 ${KillTarget} 0 0 0
			spellsused:Inc
		}
	}

  ;Tap Essence
	if ${spellsused}<=${spellthreshold} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[62]}].IsReady} && !${Me.Maintained[${SpellType[62]}](exists)}
	{
		call CastSpellRange 62 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	

	call ActionChecks

	if ${DoHOs}
		objHeroicOp:DoHO

  ;Ceremonial Blade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady} && !${Me.Maintained[${SpellType[151]}](exists)}
	{
		call CastSpellRange 151 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

  ;Night Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[391]}].IsReady} && !${Me.Maintained[${SpellType[391]}](exists)}
	{
		eq2execute useability Bump
		call CastSpellRange 130 0 1 1 ${KillTarget} 0 0 1
		spellsused:Inc
	}

	; Master Strike
	if  ${spellsused}<=${spellthreshold} && ${Me.Ability[Sinister Strike].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		Target ${KillTarget}
		call CheckPosition 1 1
		Me.Ability[Sinister Strike]:Use
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
		wait 1
	}

  ;Evasive Manuevors
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[401]}].IsReady} && !${Me.Maintained[${SpellType[401]}](exists)}
	{
		call CastSpellRange 401 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

  ;Singing Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[250]}].IsReady} && !${Me.Maintained[${SpellType[250]}](exists)}
	{
		call CastSpellRange 250 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

  ;Turn Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[387]}].IsReady} && !${Me.Maintained[${SpellType[387]}](exists)}
	{
		call CastSpellRange 387 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

  ;Dancing Blade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[110]}].IsReady} && !${Me.Maintained[${SpellType[110]}](exists)}
	{
		call CastSpellRange 110 0 1 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}

  ;Sandras Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady} && !${Me.Maintained[${SpellType[152]}](exists)}
	{
		call CastSpellRange 152 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}
	
  ;Vexing Verses
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)}
	{
		call CastSpellRange 50 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	

  ;Mesenger
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[505]}].IsReady} && !${Me.Maintained[${SpellType[505]}](exists)}
	{
		call CastSpellRange 505 0 0 0 ${KillTarget} 0 0 1
		spellsused:Inc
	}	

			return CombatComplete
		


}

function Post_Combat_Routine(int xAction)
{
	mezTarget1:Set[0]
	mezTarget2:Set[0]
	CharmTarget:Set[0]

	;turn off percisions of the maestro
	if ${Me.Maintained[${SpellType[155]}](exists)}
	{
		Me.Maintained[${SpellType[155]}]:Cancel
	}

	;cancel stealth
	if ${Me.Effect[Shroud](exists)} || ${Me.Maintained[Shroud](exists)}
	{
		Me.Maintained[Shroud]:Cancel
	}

	;reset rangedattack in case it was modified by joust call.
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}

}

function Have_Aggro()
{

	;if ${Me.AutoAttackOn}
	;{
	;	EQ2Execute /toggleautoattack
	;}

	;Cast evade if we get agro from the MT

	if ${agroid}==${KillTarget}
	{
		;evade
		call CastSpellRange 180 0 0 0 ${agroid}
	}

}

function RefreshPower()
{
	declare tempvar int local
	declare MemberLowestPower int local

	if ${Me.Power}<10 && ${Me.Health}>60 && ${Me.Inventory[${Manastone}](exists)} && ${Me.Inventory[${Manastone}].Location.Equal[Inventory]} && ${Me.Inventory[${Manastone}].IsReady}
		Me.Inventory[${Manastone}]:Use

	if ${ShardMode}
		call Shard 10

	;;;; Energizing Ballad
	if ${Me.Raid} && ${Me.Ability[${SpellType[409]}].IsReady}
	{
		tempvar:Set[0]
		MemberLowestPower:Set[0]
		
		do
		{
   		if ${Me.Raid[${tempvar}].InZone} && ${Me.Raid[${tempvar}].Health(exists)}
   		{
   		  if ${Me.Raid[${tempvar}].Name.NotEqual[${Me.Name}]}
   			{
					if ${Me.Raid[${tempvar}].Power}<25 && !${Me.Raid[${tempvar}].IsDead} && ${Me.Raid[${tempvar}].Distance}<=${Me.Ability[${SpellType[409]}].ToAbilityInfo.Range}
    			{
    				if (${Me.Raid[${tempvar}].Power} < ${Me.Raid[${MemberLowestPower}].Health}) || ${MemberLowestPower}==0
    					MemberLowestPower:Set[${tempvar}]
    			}   				
   			}
   		}		
		}
		while ${tempvar:Inc}<=24

		if ${Me.Raid[${MemberLowestPower}].InZone} && ${Me.Raid[${MemberLowestPower}].Distance}<30 && ${Me.Raid[${MemberLowestPower}].Health(exists)}
		{	
			call CastSpellRange 390 0 0 0 ${Me.Raid[${raidlowest}].ID}
			eq2execute em Energizing Ballad to ${Me.Raid[${MemberLowestPower}].Name}
		}
	}
	
	if ${Me.Grouped}
	{
		;Mana Flow the lowest group member
		tempvar:Set[1]
		MemberLowestPower:Set[0]
		do
		{
			if ${Me.Group[${tempvar}].Power}<25 && ${Me.Group[${tempvar}].Distance}<30 && ${Me.Group[${tempvar}].InZone} && ${Me.Group[${tempvar}].Power(exists)}
			{
				if ${Me.Group[${tempvar}].Power}<=${Me.Group[${MemberLowestPower}].Power}
					MemberLowestPower:Set[${tempvar}]
			}
		}
		while ${tempvar:Inc}<${Me.GroupCount}


		if ${Me.Group[${MemberLowestPower}].InZone} && ${Me.Group[${MemberLowestPower}].Power}<25 && ${Me.Group[${MemberLowestPower}].Distance}<30 && ${Me.Ability[${SpellType[409]}].IsReady} && ${Me.Group[${MemberLowestPower}].Power(exists)}
		{
			call CastSpellRange 409 0 0 0 ${Me.Group[${MemberLowestPower}].ID}	
			if ${Me.Group[${MemberLowestPower}].InZone}	&& ${Me.Group[${MemberLowestPower}].Power(exists)}
				eq2execute em Energizing Ballad to ${Me.Group[${MemberLowestPower}].Name}	
		}
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
function CheckHeals()
{
		call UseCrystallizedSpirit 60
}

function ActionChecks()
{
	if ${ShardMode}
	{
		call Shard
	}
}


function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]


	EQ2:CreateCustomActorArray[byDist,15,npc]

	do
	{
		if (${CustomActor[${tcount}].Type.Equal[NPC]} || ${CustomActor[${tcount}].Type.Equal[NamedNPC]}) && ${CustomActor[${tcount}].Name(exists)} && !${CustomActor[${tcount}].IsLocked} && !${CustomActor[${tcount}].IsEpic}
		{
			if ${CustomActor[${tcount}].ID}==${mezTarget1} || ${CustomActor[${tcount}].ID}==${mezTarget2} || ${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}


			if ${Mob.Target[${CustomActor[${tcount}].ID}]}
			{

				if ${Me.AutoAttackOn}
				{
					eq2execute /toggleautoattack
				}

				if ${Me.RangedAutoAttackOn}
				{
					eq2execute /togglerangedattack
				}

				;shut off aria so encounter debuffs dont break mezz
				;if ${Me.Maintained[${SpellType[27]}](exists)}
				;{
				;	Me.Maintained[${SpellType[27]}]:Cancel
				;}

				call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 15
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${KillTarget}].Name(exists)} && !${Actor[${KillTarget}].IsDead} && ${Mob.Detect}
	{
		Target ${KillTarget}
		wait 20 ${Me.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
		KillTarget:Set[]
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

	EQ2:CreateCustomActorArray[npc,byDist,15]

	do
	{
		if (${CustomActor[${tcount}].Type.Equal[NPC]} || ${CustomActor[${tcount}].Type.Equal[NamedNPC]}) && ${CustomActor[${tcount}].Name(exists)} && !${CustomActor[${tcount}].IsLocked} && !${CustomActor[${tcount}].IsEpic}
		{

			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}


			if ${Mob.Target[${CustomActor[${tcount}].ID}]}
			{
				CharmTarget:Set[${CustomActor[${tcount}].ID}]
				break
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${CharmTarget}].Name(exists)} && ${CharmTarget}!=${mezTarget1} && ${CharmTarget}!=${mezTarget2} && ${Actor[${MainAssist}].Target.ID}!=${CharmTarget} && ${aggrogrp}
	{
		call CastSpellRange 351 0 0 0 ${CharmTarget}

		if ${Actor[${KillTarget}].Name(exists)} && (${Me.Maintained[${SpellType[351]}].Target.ID}!=${KillTarget}) && ${Me.Maintained[${SpellType[351]}](exists)} && !${Actor[${KillTarget}].IsDead}
		{
			call PetAttack
		}
		else
		{
			EQ2Execute /target_none
		}
	}
}




function Cure()
{

}

function DoJesterCap()
{
	variable string JCActor=${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${BuffJesterCapMember}].Text}

	if !${Me.Ability[${SpellType[156]}].IsReady}
		return

	if ${Me.Maintained[${SpellType[156]}](exists)}
		return

	if ${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}==0
		return

	Me:RequestEffectsInfo

	;if I don't have potm on me, and it is ready, and I can be jcapped, jcap myself and cast potm
	if !${Me.Effect[beneficial,${SpellType[155]}](exists)} && ${Me.Ability[${SpellType[155]}].IsReady}
	{
		if ${Math.Calc[${Time.Timestamp} - ${BuffJesterCapTimers.Element[${Me.Name}]}]}>120
		{
			call CastSpellRange 156 0 0 0 ${Me.ID}

			BuffJesterCapTimers:Set[${Me.Name}, ${Time.Timestamp}]
			BuffJesterCapMember:Inc

			call CastSpellRange 155 0 0 0 ${Me.ID}
		}
		return
	}

	if ${Actor[${JCActor.Token[2,:]},${JCActor.Token[1,:]}].Distance}<${Position.GetSpellMaxRange[${TID},0,${Me.Ability[${SpellType[156]}].ToAbilityInfo.Range}]}
	{
		;Jester Cap immunity is 2 mins so make sure we havn't cast on this Actor in the past 120 seconds
		if ${Math.Calc[${Time.Timestamp} - ${BuffJesterCapTimers.Element[${JCActor}]}]}>120
		{
			EQ2Execute /useabilityonplayer ${JCActor.Token[1,:]} ${SpellType[156]}
			wait 5

			while ${Me.CastingSpell}
				wait 1

			if ${Me.Maintained[${SpellType[156]}](exists)}
			{
				eq2execute /tell ${JCActor.Token[1,:]} "You've been J-Capped!"
				;if we successfully cast Jester Cap, Add/Update the collection with the current timestamp
				BuffJesterCapTimers:Set[${JCActor}, ${Time.Timestamp}]
				BuffJesterCapMember:Inc
			}
		}
		else
		{
			;they still have immunity so advance to next
			BuffJesterCapMember:Inc
		}
	}
	else
	{
		;they are further than jester cap range so advance to next
		BuffJesterCapMember:Inc
	}

	;we have gone through everyone in the list so start back at the begining
	if ${BuffJesterCapMember}>${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
		BuffJesterCapMember:Set[1]

}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}