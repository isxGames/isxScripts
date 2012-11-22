;*************************************************************
;Beastlord.iss
;version 20111211a
;alpha
;by Pygar
;
;*************************************************************
#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

; this script is the suck, someone port monk please (pygar)

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20111211a
  ;;;;
  
  declare FightType int script 0
  declare PrimalUse int script 1
  declare CombatUse int script 1
	declare ChangePet int script 0
	declare PetInvs bool script FALSE 
	declare PetShrink bool script FALSE
	declare PetType int script
	declare StanceType int script 1
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare PetMode bool script 1
	declare NoPetMode int script 0

	call EQ2BotLib_Init
	
	
	FightType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Fight Type,0]}]
	PrimalUse:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Primal Use,1]}]	
	CombatUse:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Use,2]}]
	PetInvs:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Invs Warder,FALSE]}]
	PetShrink:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Shrink Warder,FALSE]}]
	StanceType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Stance Type,3]}]
	ChangePet:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Pet Type,3]}]
	PetType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Pet Type,3]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	return 
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
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{

		call CheckHeals
		call RefreshPower

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
	return
}

function Class_Shutdown()
{
	return
}

function Buff_Init()
{
	PreAction[1]:Set[Pathfinding]
	PreSpellRange[1,1]:Set[302]

	PreAction[2]:Set[Chilling_Claws]
	PreSpellRange[2,1]:Set[25]
	
	PreAction[3]:Set[Savage_Ruin]
	PreSpellRange[3,1]:Set[30]
	
	PreAction[4]:Set[Summon:_Beloved_of_Bristlebane]
	PreSpellRange[4,1]:Set[31]	

	PreAction[5]:Set[Singular_Focus]
	PreSpellRange[5,1]:Set[32]

	PreAction[6]:Set[Shrink_Warder]
	PreSpellRange[6,1]:Set[321]
	
	PreAction[7]:Set[Invs_Warder]
	PreSpellRange[7,1]:Set[29]
	return
}

function Combat_Init()
{
	return
}

function PostCombat_Init()
{
	return
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare counter int local
	declare BuffMember string local
	declare BuffTarget string local

	;check if we have a pet up
	if !${Me.ToActor.Pet(exists)} && ${PetMode}
		call SummonPet
	;check if we are changing pets 
	if ${Me.ToActor.Pet(exists)} && ${PetMode} && ${ChangePet}!=${PetType}
	{
		Me.Maintained[${SpellType[${Math.Calc[459+${ChangePet}]}]}]:Cancel
		Wait 150
		call SummonPet
	}

	call CheckHeals
	call RefreshPower
	
	if ${PetMode} && !${Me.Maintained[Feral Stance](exists)} && ${StanceType}==1 || ${PetMode} && !${Me.Maintained[Spiritual Stance](exists)} && ${StanceType}==2
	{
		switch ${StanceType}
		{
			case 1
				Me.Maintained[Spiritual Stance]:Cancel
				Wait 30
				call CastSpellRange 290
				break
			case 2
				Me.Maintained[Feral Stance]:Cancel
				Wait 30
				call CastSpellRange 295
				break
			case default
				call CastSpellRange 290
				break				
		}
	}
	
	switch ${PreAction[${xAction}]}
	{
		case Pathfinding
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
		break
		case Chilling_Claws
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
		break		
		case Savage_Ruin
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
		break		
		case Summon:_Beloved_of_Bristlebane
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
		break
		case Singular_Focus
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
		break
		case Shrink_Warder
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${PetShrink} && ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			Elseif ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && !${PetShrink}
			{
				 Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel				
			}
		break
		case Invs_Warder
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${PetInvs} && ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			Elseif ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && !${PetInvs}
			{
				 Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel				
			}
		break
		Default
			return Buff Complete
		break
	}
	return
}

function Combat_Routine(int xAction)
{
	declare counter int local
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	; This is how many Spells it will cast per Combat Routine Call
	spellthreshold:Set[${CombatUse}]

	; Check for Pet
	if !${Me.ToActor.Pet(exists)} && ${PetMode}
		call SummonPet	

	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}	
	
	if ${Me.ToActor.Pet(exists)} && !${Me.ToActor.Pet.InCombatMode}
	{
		EQ2Execute /pet attack
		wait 5
	}

 	call Primals
 
 	if ${Me.ToActor.InCombatMode} && ${Me.ToActor.Pet.InCombatMode}
 	{
 		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 		
 		
		;;;;Spinechiller Blood
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady} 
		{
			call CastSpellRange 152 0 0 0 ${KillTarget}
			spellsused:Inc
			wait 5
		}	
		
 		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 		
		
		;;;;Sharpened Claws
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[153]}].IsReady} 
		{
			call CastSpellRange 153 0 0 0 ${KillTarget}
			spellsused:Inc
			wait 5
		}	
		
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 	
		
		;;;;Quick Swipe
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[150]}].IsReady} 
		{
			call CastSpellRange 150 0 0 0 ${KillTarget}
			spellsused:Inc
			wait 5
		}			
		
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 	
		
		;;;;Rush
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady} 
		{
			call CastSpellRange 151 0 0 0 ${KillTarget}
			spellsused:Inc
			wait 5
		}	
		
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 	
		
		;;;;Elnakii's Swipe
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[390]}].IsReady} 
		{
			call CastSpellRange 390 0 0 0 ${KillTarget}
			spellsused:Inc
			wait 5
		}		
		
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 	
		
		;;;;Buff Ralissj's Insight
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[392]}].IsReady} && !${Me.Maintained[${SpellType[392]}](exists)}
		{
			call CastSpellRange 392	
			spellsused:Inc
			wait 5
		}
		
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 	
		
		;;;;Glacial Lance
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[61]}].IsReady} &&!${Me.Maintained[${SpellType[61]}](exists)}
		{
			call CastSpellRange 61
			spellsused:Inc
			wait 5
		}
		
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 	
		
		;;;;Primal Consumption
		if ${spellsused}<${spellthreshold} && ${Me.Ability[${SpellType[396]}].IsReady} &&!${Me.Maintained[${SpellType[396]}](exists)}
		{
			call CastSpellRange 396
			spellsused:Inc
			wait 5
		}	
			
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 		
			
		;;;;PBAOE
		if ${spellsused}<${spellthreshold} && ${Mob.Count}>=1 && ${Me.Ability[${SpellType[394]}].IsReady} || ${Mob.Count}>2 && ${MainTank}
		{
			call CastSpellRange 394 0 0 0 ${KillTarget}
			spellsused:Inc
			wait 5
		}
	
		if ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[405]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
 			call Advantages 		
	
		if  ${spellsused}<${spellthreshold} && ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)} && !${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID})
		{
			call CheckPosition 1 1 ${KillTarget}
			Me.Ability[Sinister Strike]:Use
			wait 5
		}
	
		if !${MainTank} && ${spellsused}>=${spellthreshold}
		{
			call CastSpellRange 185 0 0 0 ${aggroid}
		}
		if !${MainTank} && ${spellsused}==${spellthreshold} || ${MainTank} && ${spellsused}<=${spellthreshold}
		{
			call CastSpellRange 395 0 0 0 ${aggroid}
		}
		
		wait 5
	
	}
	return
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
	return
}

function Have_Aggro()
{
	echo Aggro from ${aggroid}
	KillTaget:Set[${aggroid}]
	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if !${MainTank}
		call CastSpellRange 185 0 0 0 ${aggroid}
	return
}

function Lost_Aggro(int mobid)
{
	return
}

function MA_Lost_Aggro()
{
	return
}

function Cancel_Root()
{
	return
}

function RefreshPower()
{
	if ${Me.Power}<10 && ${Me.Inventory[${Manastone}](exists)} && ${Me.Inventory[${Manastone}].IsReady}
		Me.Inventory[${Manastone}]:Use

}

function CheckHeals()
{
	if ${Me.ToActor.Pet.Health}<70 && ${Me.ToActor.Pet(exists)}
		call CastSpellRange 391

	call CommonHeals 70
}

function Advantages()
{
	declare counter int local
 ;; Loop for Advantages both Offensive and Defensive 
	if ${Me.ToActor.Pet(exists)} && ${Actor[${KillTarget}].Type.Equal[NPC]}
	{
		if ${Me.Maintained[Spiritual Stance](exists)}
		{
			counter:Set[432]
			do
			{
				if ${Me.Ability[${SpellType[${counter}]}].IsReady} && !${Me.Maintained[${SpellType[${counter}]}](exists)} && ${Me.ToActor.Health}>=60 && ${FightType}!=1
				{
					call CastSpellRange ${counter} 1 0 0 ${KillTarget}
					wait 2
			  }
			  Elseif ${Me.Ability[${SpellType[434]}].IsReady} && !${Me.Maintained[${SpellType[434]}](exists)}  && ${Me.ToActor.Health}<60 || ${Me.Ability[${SpellType[434]}].IsReady} && !${Me.Maintained[${SpellType[434]}](exists)} && ${FightType}==1
			 	{
					call CastSpellRange 434 1 0 0 ${KillTarget}
					wait 2
				}
				Elseif ${Me.Ability[${SpellType[431]}].IsReady} && ${Me.ToActor.Health}<40 || ${Me.Ability[${SpellType[431]}].IsReady} && ${FightType}==1 || ${Me.Ability[${SpellType[435]}].IsReady} && ${Me.ToActor.Health}<40 || ${Me.Ability[${SpellType[435]}].IsReady} && ${FightType}==1
			 	{
			 		if ${Me.Ability[${SpellType[403]}].IsReady}
						call CastSpellRange 431 1 0 0 ${KillTarget}
					if ${Me.Ability[${SpellType[405]}].IsReady}
						call CastSpellRange 435 1 0 0 ${KillTarget}
					wait 2
				}
			}
			while ${counter:Inc}<439
		}
		if ${Me.Maintained[Feral Stance](exists)}
		{
			counter:Set[401]
			do
			{
				if ${Me.Ability[${SpellType[${counter}]}].IsReady} && !${Me.Maintained[${SpellType[${counter}]}](exists)} && ${Me.ToActor.Health}>=40 && ${FightType}!=1
				{
					call CastSpellRange ${counter} 1 0 0 ${KillTarget}
					wait 2
			  }
			  Elseif ${Me.Ability[${SpellType[403]}].IsReady} && ${Me.ToActor.Health}<40 || ${Me.Ability[${SpellType[403]}].IsReady} && ${FightType}==1 || ${Me.Ability[${SpellType[405]}].IsReady} && ${Me.ToActor.Health}<40 || ${Me.Ability[${SpellType[405]}].IsReady} && ${FightType}==1
			 	{
			 		if ${Me.Ability[${SpellType[403]}].IsReady}
						call CastSpellRange 403 1 0 0 ${KillTarget}
					if ${Me.Ability[${SpellType[405]}].IsReady}
						call CastSpellRange 405 1 0 0 ${KillTarget}
					
					wait 2
				}
			}
			while ${counter:Inc}<409
		}		
	}	
	return
}

function Primals()
{
	declare counter int local
	;; Loop for Primals both Offensive and Defensive
	if ${Me.ToActor.Pet(exists)} && ${Actor[${KillTarget}].Type.Equal[NPC]}
	{
		if ${Me.Maintained[Spiritual Stance](exists)}
		{
			counter:Set[441]
			do
			{			
				if ${Me.Ability[${SpellType[${counter}]}].IsReady} && !${Me.Maintained[${SpellType[${counter}]}](exists)} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Self.SavageryLevel].ShortLabel}>=${Math.Calc[${PrimalUse}-1]} && ${Me.ToActor.Health}>=50 
				{
					call CastSpellRange ${counter} 1 0 0 ${KillTarget}
					wait 2
			  }
			  Elseif ${Me.Ability[${SpellType[${counter}]}].IsReady} && ${Me.ToActor.Health}<=50
			 	{
					call CastSpellRange ${counter} 1 0 0 ${KillTarget}
					wait 2
				}			
			}
			while ${counter:Inc}<447
		}
		if ${Me.Maintained[Feral Stance](exists)}
		{
			counter:Set[411]
			do
			{
				if ${Me.Ability[${SpellType[${counter}]}].IsReady} && !${Me.Maintained[${SpellType[${counter}]}](exists)} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Self.SavageryLevel].ShortLabel}>=${PrimalUse} && ${Me.ToActor.Health}>=50 
				{
					call CastSpellRange ${counter} 1 0 0 ${KillTarget}
					wait 2
			  }
			  Elseif ${Me.Ability[${SpellType[${counter}]}].IsReady} && ${Me.ToActor.Health}<=50
			 	{
					call CastSpellRange ${counter} 1 0 0 ${KillTarget}
					wait 2
				}			  
			}
			while ${counter:Inc}<420
		}			
	}	
	return
}

function SummonPet()
{
	
; Summon Pet in Alpha Attack and Alpha Defense order 
	PetEngage:Set[FALSE]
	if ${PetMode} && ${Me.Ability[${SpellType[${Math.Calc[459+${PetType}]}]}].IsReady}
	{
		switch ${PetType}
		{
		case 1
			call CastSpellRange 460 1
			echo casting ${SpellType[460]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 2
			call CastSpellRange 461 1
			echo casting ${SpellType[461]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 3
			call CastSpellRange 462 1
			echo casting ${SpellType[462]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 4
			call CastSpellRange 463 1
			echo casting ${SpellType[463]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 5
			call CastSpellRange 464
			echo casting ${SpellType[464]}
			ChangePet:Set[${PetType}]
			wait 50 
			break	
		case 6
			call CastSpellRange 465
			echo casting ${SpellType[465]}
			ChangePet:Set[${PetType}]
			wait 50 
			break	
		case 7
			call CastSpellRange 466
			echo casting ${SpellType[466]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 8
			call CastSpellRange 467
			echo casting ${SpellType[467]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 9
			call CastSpellRange 468
			echo casting ${SpellType[468]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 10
			call CastSpellRange 469
			echo casting ${SpellType[469]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 11
			call CastSpellRange 470
			echo casting ${SpellType[470]}
			ChangePet:Set[${PetType}]
			wait 50 
			break	
		case 12
			call CastSpellRange 471
			echo casting ${SpellType[471]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 13
			call CastSpellRange 472
			echo casting ${SpellType[472]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 14
			call CastSpellRange 473
			echo casting ${SpellType[473]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 15
			call CastSpellRange 474
			echo casting ${SpellType[474]}
			ChangePet:Set[${PetType}]
			wait 50 
			break	
		case 16
			call CastSpellRange 475
			echo casting ${SpellType[475]}
			ChangePet:Set[${PetType}]
			wait 50 
			break					
		case default
			call CastSpellRange 460
			echo casting ${SpellType[460]}
			ChangePet:Set[1]
			wait 50 
			break
		}
	}
	return
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed
	return
}
