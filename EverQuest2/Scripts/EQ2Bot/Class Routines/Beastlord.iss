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
	if !${Me.Pet(exists)} && ${PetMode}
		call SummonPet
	;check if we are changing pets 
	if ${Me.Pet(exists)} && ${PetMode} && ${ChangePet}!=${PetType}
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
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${PetShrink} && ${Me.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			Elseif ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && !${PetShrink}
			{
				 Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel				
			}
		break
		case Invs_Warder
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${PetInvs} && ${Me.Pet(exists)}
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

	echo Combat Use = ${CombatUse}

	spellsused:Set[0]
	; This is how many Spells it will cast per Combat Routine Call
	spellthreshold:Set[${CombatUse}]

	; Check for Pet
	if !${Me.Pet(exists)} && ${PetMode}
		call SummonPet	

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
	}	
	
	if ${Me.Pet(exists)} && !${Me.Pet.InCombatMode}
	{
		EQ2Execute /pet attack
	}

 	call Primals
	call Advantages 		 
 
 	if ${Actor[${KillTarget}](exists)} && ${Me.InCombatMode} && ${Me.Pet.InCombatMode}
 	{
		;;;;PBAOE
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Mob.Count}>2 && ${Me.Ability[${SpellType[394]}].IsReady}
		{
			call CastSpellRange 394 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages
		}

		;;;;Rush
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[151]}].IsReady} 
		{
			call CastSpellRange 151 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 
		}	

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1

		;;;;Growl
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[397]}].IsReady} 
		{
			call CastSpellRange 397 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 	
		}				
		
		;;;;Spinechiller Blood
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[152]}].IsReady} 
		{
			call CastSpellRange 152 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 	
		}	

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1

		;;; Master Strike		
		if  ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)} && !${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID})
		{
			call CheckPosition 1 1 ${KillTarget}
			Me.Ability[Sinister Strike]:Use
			wait 5
			spellsused:Inc
			call Advantages 
		}

		;;;;Primal Consumption
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[396]}].IsReady} &&!${Me.Maintained[${SpellType[396]}](exists)}
		{
			call CastSpellRange 396
			spellsused:Inc
			call Advantages 	
		}	

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1

		;;;;Evasive Manuevors
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[395]}].IsReady} 
		{
			call CastSpellRange 395 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 	
		}			

		;;;;Elnakii's Swipe
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[390]}].IsReady} 
		{
			call CastSpellRange 390 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 	
		}		

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1


		;;;;;Glacial Lance
		;if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[61]}].IsReady} &&!${Me.Maintained[${SpellType[61]}](exists)}
		;{
		;	call CastSpellRange 61 0 2 1 ${KillTarget}
		;	spellsused:Inc
		;	call Advantages 
		;}

		;;;;Quick Swipe
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[150]}].IsReady} 
		{
			call CastSpellRange 150 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 	
		}			

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1

		
		;;;;Sharpened Claws
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[153]}].IsReady} 
		{
			call CastSpellRange 153 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages
		}	

		;;;;BoneChiller Venom
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[394]}].IsReady} 
		{
			call CastSpellRange 394 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages 
		}	

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1

		;;;;Blindside
		if ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[100]}].IsReady} 
		{
			call CastSpellRange 100 0 0 0 ${KillTarget}
			spellsused:Inc
			call Advantages
		}	

		;;; Evade
		if !${MainTank} && ${spellsused}<${spellthreshold} && ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[185]}].IsReady}
		{
			call CastSpellRange 185 0 0 0 ${aggroid}
			spellsused:Inc
		}

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
	if ${Me.Pet.Health}<70 && ${Me.Pet(exists)}
		call CastSpellRange 391

	call CommonHeals 70
}

function Advantages()
{
	if ${Me.Ability[${SpellType[401]}].IsReady} || ${Me.Ability[${SpellType[402]}].IsReady} || ${Me.Ability[${SpellType[403]}].IsReady} || ${Me.Ability[${SpellType[404]}].IsReady} || ${Me.Ability[${SpellType[431]}].IsReady} || ${Me.Ability[${SpellType[435]}].IsReady}
	{
		;continue
	}
	else
	{
		echo No Advantages ready
		return 0
	}
	
	if ${Me.GetGameData[Self.SavageryLevel].Label}>=${PrimalUse}
		call Primals

	;buff advantage gain if not at target savagery
	if ${Me.GetGameData[Self.SavageryLevel].Label}<=${PrimalUse} && ${Me.Ability[${SpellType[392]}].IsReady}
		call CastSpellRange 392
		
	declare counter int local
 ;; Loop for Advantages both Offensive and Defensive 
	if ${Me.Pet(exists)} && ${Actor[${KillTarget}].Type.Equal[NPC]}
	{
		if ${Me.Maintained[Spiritual Stance](exists)}
		{
			counter:Set[432]
			do
			{
				if ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[${counter}]}].IsReady} && !${Me.Maintained[${SpellType[${counter}]}](exists)} && ${Me.Health}>=60 && ${FightType}!=1
				{
					call CastSpellRange ${counter} 0 0 0 ${KillTarget}
					wait 2
			  }
			  Elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[434]}].IsReady} && !${Me.Maintained[${SpellType[434]}](exists)}  && ${Me.Health}<60 || ${Me.Ability[${SpellType[434]}].IsReady} && !${Me.Maintained[${SpellType[434]}](exists)} && ${FightType}==1
			 	{
					call CastSpellRange 434 0 0 0 ${KillTarget}
					wait 2
				}
				Elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[431]}].IsReady} && ${Me.Health}<40 || ${Me.Ability[${SpellType[431]}].IsReady} && ${FightType}==1 || ${Me.Ability[${SpellType[435]}].IsReady} && ${Me.Health}<40 || ${Me.Ability[${SpellType[435]}].IsReady} && ${FightType}==1
			 	{
			 		if ${Me.Ability[${SpellType[403]}].IsReady}
						call CastSpellRange 431 0 0 0 ${KillTarget}
					if ${Me.Ability[${SpellType[405]}].IsReady}
						call CastSpellRange 435 0 0 0 ${KillTarget}
				}
			}
			while ${counter:Inc}<439
		}
		if ${Me.Maintained[Feral Stance](exists)}
		{
			if ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[402]}].IsReady} && !${Me.Maintained[${SpellType[402]}](exists)}
			{
				echo cast Advantage ${SpellType[402]}
				call CastSpellRange 402 0 1 0 ${KillTarget}
			}
			elseif ${Actor[${KillTarget}](exists)} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[404]}].IsReady}
			{
				echo cast Advantage ${SpellType[404]}
				call CastSpellRange 404 0 1 0 ${KillTarget}
			}
			elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[401]}].IsReady}
			{
				echo cast Advantage ${SpellType[401]}
				call CastSpellRange 401 0 1 1 ${KillTarget}
			}
			elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[403]}].IsReady}
			{
				echo cast Advantage ${SpellType[404]}
				call CastSpellRange 403 0 1 1 ${KillTarget}
			}
		}	
	}	
	return 1
}

function Primals()
{
	;use Savage Blaze to raise savagery
	if ${Me.GetGameData[Self.SavageryLevel].Label}>=${Math.Calc[${PrimalUse}-2]} && ${Me.GetGameData[Self.SavageryLevel].Label}<=${PrimalUse} && ${Me.Ability[${SpellType[399]}].IsReady} && !${Me.Maintained[${SpellType[399]}](exists)}
	{
		call CastSpellRange 399
		echo Blaze
	}
	;dump function if savagery not high enough
	if ${Me.GetGameData[Self.SavageryLevel].Label}<${PrimalUse}
	{
		echo Not enough Savagery
		echo ${Me.GetGameData[Self.SavageryLevel].Label}<=${PrimalUse}
		return 0
	}
	else
	{
		echo Min Savagery Needed - Proceed to primals
	}
	
	;Savagery Freeze
	if ${Actor[${KillTarget}](exists)} && (${Actor[${KillTarget}].Health}>50 || ${Actor[${KillTarget}].IsEpic}) && ${Me.GetGameData[Self.SavageryLevel].Label}>=${PrimalUse} && ${Me.Ability[${SpellType[480]}].IsReady} && !${Me.Maintained[${SpellType[480]}](exists)}
	{
		echo Savagery Freeze
		call CastSpellRange 480
	}

	;Primal Assault
	if ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[398]}].IsReady} && (${Actor[${KillTarget}].Health}>50 || ${Actor[${KillTarget}].IsEpic})
	{
		echo Primal Assault
		call CastSpellRange 398
	}
		
	declare counter int local
	;; Loop for Primals both Offensive and Defensive
	if ${Me.Pet(exists)}
	{
		if ${Me.Maintained[Spiritual Stance](exists)}
		{
			counter:Set[441]
			do
			{			
				if ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[${counter}]}].IsReady} && !${Me.Maintained[${SpellType[${counter}]}](exists)} && ${Me.GetGameData[Self.SavageryLevel].Label}>=${Math.Calc[${PrimalUse}-1]}
				{
					call CastSpellRange ${counter} 0 0 0 ${KillTarget}
			  }
			  elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[${counter}]}].IsReady} && ${Me.Health}<=50
			 	{
					call CastSpellRange ${counter} 0 0 0 ${KillTarget}
				}			
			}
			while ${Actor[${KillTarget}](exists)} && ${counter:Inc}<447
		}
		elseif ${Me.Maintained[Feral Stance](exists)}
		{
			do
			{
				counter:Set[0]
				if ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[411]}].IsReady} && !${Me.Maintained[${SpellType[411]}](exists)}
				{
					echo cast Primal ${SpellType[411]}
					call CastSpellRange 411 0 1 0 ${KillTarget}
					counter:Inc
				}
				elseif ${Actor[${KillTarget}](exists)} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[414]}].IsReady}
				{
					echo cast Advantage ${SpellType[414]}
					call CastSpellRange 414 0 1 0 ${KillTarget}
					counter:Inc
				}
				elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[412]}].IsReady}
				{
					echo cast Advantage ${SpellType[412]}
					call CastSpellRange 412 0 1 1 ${KillTarget}
					counter:Inc
				}
				elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[413]}].IsReady}
				{
					echo cast Advantage ${SpellType[413]}
					call CastSpellRange 413 0 1 1 ${KillTarget}
					counter:Inc
				}
				elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[415]}].IsReady}
				{
					echo cast Advantage ${SpellType[415]}
					call CastSpellRange 415 0 1 1 ${KillTarget}
					counter:Inc
				}				
				elseif ${Actor[${KillTarget}](exists)} && ${Me.Ability[${SpellType[416]}].IsReady}
				{
					echo cast Advantage ${SpellType[416]}
					call CastSpellRange 416 0 1 1 ${KillTarget}
					counter:Inc
				}				

				if ${counter}>0
					call Advantages  
			}
			while ${Actor[${KillTarget}](exists)} && ${Me.GetGameData[Self.SavageryLevel].Label}>=${PrimalUse}
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
			call CastSpellRange 460 
			echo casting ${SpellType[460]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 2
			call CastSpellRange 461 
			echo casting ${SpellType[461]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 3
			call CastSpellRange 462 
			echo casting ${SpellType[462]}
			ChangePet:Set[${PetType}]
			wait 50 
			break
		case 4
			call CastSpellRange 463 
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
