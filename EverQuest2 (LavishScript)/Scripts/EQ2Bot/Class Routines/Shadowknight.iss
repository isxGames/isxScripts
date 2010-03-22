;*************************************************************
;Shadowknight.iss
;version 20100317
;by Pygar
;
;20100317
; * Major overhaul of Combat_Routine() -- should be much better.
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20100317
	;;;;

	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare StartHO bool script 1
	declare UseReaver bool script TRUE
	declare UseBattleLeadershipAABuff bool script FALSE
	declare UseFearlessMoraleAABuff bool script FALSE
	declare UseDeathMarch bool script FALSE
	declare UseMastersRage bool script TRUE
	declare HasMythical bool script FALSE
	declare InPostDeathRoutine bool script FALSE
	declare NumNPCs int script
	declare DoAEs bool script 
	declare UseUnholyHunger bool script TRUE
	declare UseUnholyStrength bool script TRUE
	declare AlwaysUseAEs bool script FALSE

	declare BuffArmamentMember string script
	declare BuffTacticsGroupMember string script

	call EQ2BotLib_Init

	FullAutoMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Full Auto Mode,FALSE]}]
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDefensiveStance,TRUE]}]
	OffensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseOffensiveStance,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	UseReaver:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseReaver,TRUE]}]
	UseBattleLeadershipAABuff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseBattleLeadershipAABuff,FALSE]}]
	UseFearlessMoraleAABuff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseFearlessMoraleAABuff,FALSE]}]
	UseDeathMarch:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDeathMarch,FALSE]}]
	UseMastersRage:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseMastersRage,TRUE]}]
	UseUnholyHunger:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseUnholyHunger,TRUE]}]
	UseUnholyStrength:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseUnholyStrength,TRUE]}]
	AlwaysUseAEs:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[AlwaysUseAEs,FALSE]}]


	BuffArmamentMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffArmamentMember,]}]
	BuffTacticsGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffTacticsGroupMember,]}]

	if ${Me.Level} < 58
		UIElement[UseDeathMarch@Class@EQ2Bot Tabs@EQ2 Bot]:ToggleVisible

	if ${Me.Equipment[Sedition, Sword of the Bloodmoon](exists)}
		HasMythical:Set[TRUE]

	Event[EQ2_FinishedZoning]:AttachAtom[Shadowknight_FinishedZoning]
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


	;; This has to be set WITHIN any 'if' block that uses the timer.
	;ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
	Event[EQ2_FinishedZoning]:DetachAtom[Shadowknight_FinishedZoning]
}


function Buff_Init()
{
   PreAction[1]:Set[Armament_Target]
   PreSpellRange[1,1]:Set[30]

   PreAction[2]:Set[Self_Buff1]
   PreSpellRange[2,1]:Set[25]

   PreAction[3]:Set[Self_Buff2]
   PreSpellRange[3,1]:Set[26]

   PreAction[4]:Set[Group_Buff1]
   PreSpellRange[4,1]:Set[20]

   PreAction[5]:Set[Group_Buff2]
   PreSpellRange[5,1]:Set[21]

   PreAction[6]:Set[Tactics_Target]
   PreSpellRange[6,1]:Set[31]

   PreAction[7]:Set[OffensiveMode]
   PreSpellRange[7,1]:Set[290]

   PreAction[8]:Set[DefensiveMode]
   PreSpellRange[8,1]:Set[295]

   PreAction[9]:Set[Reaver]
   PreSpellRange[9,1]:Set[334]

   PreAction[10]:Set[BattleLeadershipAABuff]
   PreSpellRange[10,1]:Set[336]

   PreAction[11]:Set[FearlessMoraleAABuff]
   PreSpellRange[11,1]:Set[337]

   PreAction[12]:Set[Bloodletter]
   PreSpellRange[12,1]:Set[331]

   PreAction[13]:Set[AuraOfLeadershipAABuff]
   PreSpellRange[13,1]:Set[341]
   
   PreAction[14]:Set[Trample]
   PreSpellRange[14,1]:Set[342]
   
   PreAction[15]:Set[CShout]
   PreSpellRange[15,1]:Set[345]   
}

function Combat_Init()
{
	;; This is no longer used
	return
}

function PostCombat_Init()
{
	return
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare ActorID uint local
	variable int temp

	if (!${InPostDeathRoutine} || !${CheckingBuffsOnce})
	{
		if ${ShardMode}
			call Shard
	}

	switch ${PreAction[${xAction}]}
	{
		case Armament_Target
			BuffTarget:Set[${UIElement[cbBuffArmamentGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID} != ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
				else
					break
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if ${Me.InRaid}
					{
						if (${Me.Raid[${BuffTarget.Token[1,:]}](exists)})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
					else
					{
						if (${Me.Group[${BuffTarget.Token[1,:]}](exists)})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
						wait 2
					}
				}
			}
			break

		case OffensiveMode
		    if ${OffensiveMode}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
		    }
		    else
		    {
    			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

		case DefensiveMode
		    if ${DefensiveMode}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
		    }
		    else
		    {
    			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

		case Self_Buff1
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		  	call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			break

		case Self_Buff2
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		  	call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			break


		case Group_Buff1
			if ${UseUnholyHunger}
			{
				if (!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Zone.ShortName.Find[venril]} <= 0)
			  	call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case Group_Buff2
			if ${UseUnholyStrength}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			  	call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break


		case Tactics_Target
			BuffTarget:Set[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID} != ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
				else
					break
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if ${Me.InRaid}
					{
						if (${Me.Raid[${BuffTarget.Token[1,:]}](exists)})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
					else
					{
						if (${Me.Group[${BuffTarget.Token[1,:]}](exists)})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
						wait 2
					}
				}
			}
			break

		case Reaver
		    if ${UseReaver}
		    {
					if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
			     	call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
		    }
		    else
		    {
		        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		            Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

	    case BattleLeadershipAABuff
		    if ${UseBattleLeadershipAABuff}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
		    }
		    else
		    {
		        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		            Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

	    case FearlessMoraleAABuff
		    if ${UseFearlessMoraleAABuff}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
		    }
		    else
		    {
		        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		            Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

		case AuraOfLeadershipAABuff
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			    }
			}
		  break
		  
		case Trample
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			    }
			}
		  break

		case CShout
			if (${MainTank})
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
				{
					if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    {
					    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
				    }
				}
			}
		  break		  

		case Bloodletter
		  if ${Me.Level} < 80
		  	break
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
			    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
			        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			}
			break

		Default
			return BuffComplete
	}

}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, int TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	variable bool bReturn
	variable string sReturn

	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;

	if (${Me.ToActor.IsRooted} || !${Me.ToActor.CanTurn})
	{
    if ${Me.Ability[${SpellType[339]}].IsReady}
    {
      ;ANNOUNCE IS BROKEN announce "I am either frozen, rooted, stunned or charmed...\n\\#FF6E6EUsing Aura of the Crusader!" 3 1
      call CastSpellRange 339 0 0 0 ${Me.ToActor.ID} 0 0 0 1
    }
	}

	if ${TargetID} != ${Me.ToActor.ID}
	{
		call VerifyTarget ${TargetID}
		if !${Return}
			return CombatComplete		
	}
	else
	{
		call VerifyTarget
		if !${Return}
		{
			bReturn:Set[TRUE]
			sReturn:Set[CombatComplete]
		}
	}


	;; we should actually cast the spell we wanted to cast originally before doing anything else
	LastSpellCast:Set[${start}]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	if ${bReturn}
		return ${sReturn}
	else
		bReturn:Set[${Return}]


	;; Anything else we want to do should go here...

	return ${bReturn}
}


function Combat_Routine(int xAction)
{
  declare BuffTarget string local
	declare TankToTargetDistance float local

	if ${DoHOs}
	objHeroicOp:DoHO

  if ${StartHO}
  {
  	if !${EQ2.HOWindowActive}
  		call CastSpellRange 303
  }


	if !${NoAutoMovementInCombat} && !${NoAutoMovement} && ${AutoMelee}
	{
		if ${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]}
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			Debug:Echo["Combat_Routine():: TankToTargetDistance: ${TankToTargetDistance}"]

			if (${MainTank} || ${TankToTargetDistance} <= 7.5)
				call CheckPosition 1 0 ${KillTarget}
		}
	}

  ;; uncomment for venril fight
  ;if (${Zone.ShortName.Find[venril]} > 0)
  ;{
  ;	if (${Me.ToActor.Power} <= 47)
  ;	{
  ;		do
  ;		{
  ;			waitframe
  ;		}
  ;		while ${Me.ToActor.Power} < 49
  ;	}
  ;}

	if (${Me.ToActor.IsRooted} || !${Me.ToActor.CanTurn})
	{
    if ${Me.Ability[${SpellType[339]}].IsReady}
    {
      ;ANNOUNCE IS BROKEN announce "I am either frozen, rooted, stunned or charmed...\n\\#FF6E6EUsing Aura of the Crusader!" 3 1
      call CastSpellRange 339 0 0 0 ${Me.ToActor.ID} 0 0 0 1
    }
	}

	;; AE Taunt and Debuff
  if ${PBAoEMode}
  {
    if ${MainTank}
    {
	    if (${Me.Ability[${SpellType[170]}].IsReady})
	    {
	    	 call _CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
  		   if ${Return.Equal[CombatComplete]}
  		   	return CombatComplete
    	}
    }
  }
	
	DoAEs:Set[FALSE]
	if ${PBAoEMode}
	{
		if ${AlwaysUseAEs}
			DoAEs:Set[TRUE]
		else
		{
		  EQ2:CreateCustomActorArray[ByDist,12,npc]
		  NumNPCs:Set[${EQ2.CustomActorArraySize}]
		  DoAEs:Set[FALSE]
		  if ${NumNPCs} > 2
		  	DoAEs:Set[TRUE]
		  elseif ${Actor[${KillTarget}].IsEpic}
		  	DoAEs:Set[TRUE]
		  elseif ${Actor[${KillTarget}].IsHeroic}
		  {
		  	if ${Actor[${KillTarget}].Difficulty} >= 2
		  	{
					switch ${Actor[${KillTarget}].ConColor}
					{
						case Red
						case Orange
						case Yellow
						case White
							DoAEs:Set[TRUE]
							break
						default
							break
					}
				}
			}
		}
	}
	
	
  ;; DeathMarch
  if (${UseDeathMarch} && ${Me.Ability[${SpellType[312]}].IsReady})
  {
		call _CastSpellRange 312 0 0 0 ${Me.ToActor.ID} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
  }
	
  if ${DoAEs}
  {
  	;; AE Taunt
    if (${Me.Ability[${SpellType[340]}].IsReady})
    {
    	;Debug:Echo["${SpellType[340]}..."]
	    call _CastSpellRange 340 0 0 0 ${Me.ToActor.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}  
    
	  ;; MIST -- should be casted after AE taunt at the beginning of the fight  (Physical damage mit debuff)
    if (${Me.Ability[${SpellType[55]}].IsReady})
    {	
      call _CastSpellRange 55 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
  	}   	
  	;; Grave Sacrament
    if (${Me.Ability[${SpellType[45]}].IsReady})
    {
    	;Debug:Echo["${SpellType[45]}..."]
	    call _CastSpellRange 45 0 0 0 ${Me.ToActor.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}    	
  	;; Tap Veins
    if (${Me.Ability[${SpellType[98]}].IsReady})
    {
    	;Debug:Echo["${SpellType[98]}..."]
	    call _CastSpellRange 98 0 0 0 ${Me.ToActor.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
		;; Lance
		if ${Me.Ability[${SpellType[347]}](exists)}
		{
			;Debug:Echo["${SpellType[347]}..."]
			if (${Me.Ability[${SpellType[347]}].IsReady})
			{
				call _CastSpellRange 347 0 0 0 ${Me.ToActor.ID} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
		;hammer ground stun
		if !${Actor[${KillTarget}].IsEpic}
		{
			if (${Me.Ability[${SpellType[505]}].IsReady})
	    {
		    call _CastSpellRange 505 0 0 0 ${Me.ToActor.ID} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
		if ${NumNPCs} > 4
		{
			;; Pestilence
			if (${Me.Ability[${SpellType[99]}].IsReady})
			{					
				;Debug:Echo["${SpellType[99]}..."]
				call _CastSpellRange 99 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
		;; Doom Judgement
		if (${Me.Ability[${SpellType[97]}].IsReady})
		{
			;Debug:Echo["${SpellType[97]}..."]
			call _CastSpellRange 97 0 0 0 ${Me.ToActor.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
		;; Death Cloud
		if (${Me.Ability[${SpellType[95]}].IsReady})
		{
			;Debug:Echo["${SpellType[95]}..."]
			call _CastSpellRange 95 0 0 0 ${Me.ToActor.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}			
		;; Unending Agony
		if (${Me.Ability[${SpellType[96]}].IsReady})
		{
			;Debug:Echo["${SpellType[96]}..."]
			call _CastSpellRange 96 0 0 0 ${Me.ToActor.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}						
			
    ;; Self Reverse DS (with life tap proc)
  	if ${Me.Ability[${SpellType[7]}].IsReady}
  	{
	    if ${MainTank}
	    {
  	    call _CastSpellRange 7 0 0 0 ${Me.ToActor.ID} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
    	}
	    else
	    {
  	    call _CastSpellRange 7 0 0 0 ${MainTankID} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
    	}
		}
  }	
  
	;Essence Siphon
	if ${Me.Ability[${SpellType[503]}].IsReady}
	{
		call _CastSpellRange 503 0 0 0 ${KillTarget}	0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	
	;; Divine Aura
	if ${Me.ToActor.Health}<25 && ${Me.Ability[${SpellType[502]}].IsReady}
		call CastSpellRange 502 

	;; SK's Furor
	if ${Me.ToActor.Health}<=20 && ${Me.Ability[${SpellType[507]}].IsReady}
		call CastSpellRange 507


	;; build aggro
  if ${MainTank}
  {
  	;; Always try to cast fast casting Combat Arts aftewards to gain aggro (if tank)
    if (${Me.Ability[${SpellType[152]}].IsReady})
    {
      call _CastSpellRange 152 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
    }
    if (${Me.Ability[${SpellType[151]}].IsReady})
    {
      call _CastSpellRange 151 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
    }
		; shield bash
    if (${Me.Ability[${SpellType[240]}].IsReady})
    {
	    call _CastSpellRange 240 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
		; taunt
		if (${Me.Ability[${SpellType[160]}].IsReady})
    {
	    call _CastSpellRange 160 0 0 0 ${KillTarget}
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
  }
  else
  {
    if !${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 90
    {
	    if (${Me.Ability[${SpellType[170]}].IsReady})
	    {
		    call _CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
  	}
  }
	
	;; Siphon Strength (Always cast this when it is ready!)
  if (${Me.Ability[${SpellType[80]}].IsReady})
  {
    call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}

  ;;;;;
	;;; Quick Spells for aggro
	; Hateful Slam (shield bash)
  if (${Me.Ability[${SpellType[240]}].IsReady})
  {
    call _CastSpellRange 240 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	; Insidious Whisper
	if (${MainTank} && ${Me.Ability[${SpellType[160]}].IsReady})
  {
    call _CastSpellRange 160 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	; kick
	if (${Me.Ability[${SpellType[151]}].IsReady})
  {
    call _CastSpellRange 151 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;;
	;;;;

  ;; Cast 5-Proc Damage Shield every time it is ready (And as long as we are fighting non-solo mobs)
  CurrentAction:Set[Combat :: Checking 'Damage Shield']
  if !${Actor[${KillTarget}].IsSolo}
  {
    if ${Actor[${KillTarget}].Health} > 25
    {
      BuffTarget:Set[${UIElement[cbBuffDSGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
      if ${Actor[${KillTarget}].Target.Name.Equal[${BuffTarget.Token[1,:]}]}
      {
        if !${Me.Maintained[${SpellType[7]}](exists)}
        {
        	if ${Me.Ability[${SpellType[7]}].IsReady}
        	{
        		if !${BuffTarget.Equal["No one"]}
        		{
      		    CurrentAction:Set[Combat :: Casting 'Damage Shield']
      		    ;Debug:Echo["${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}"]
      				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
      				{
      			    call CastSpellRange 7 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1
      				}
      				else
      			    echo "ERROR: Damage Shield proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
          	}
          	;; If set to "no one" we assume they do not want to use this spell.
        	}
        }
      }
    }
  }

	call CommonHeals 60
  call CheckGroupOrRaidAggro
  call CheckPower

  ;call CheckHeals

  ; If Kerran, use Physical Mitigation Debuff on Epic Mobs or Heroics that are yellow/orange/red cons
  if ${Me.Race.Equal[Kerran]}
  {
    if ${Actor[${KillTarget}].IsEpic}
    {
			if ${Me.Ability[Claw].IsReady}
			{
				Target ${KillTarget}
				Me.Ability[Claw]:Use
				wait 1
				do
				{
				    waitframe
				}
				while ${Me.CastingSpell}
				wait 1
			}
		}
    elseif ${Actor[${KillTarget}].IsHeroic}
    {
   		if ${Actor[${KillTarget}].Difficulty} > 2
    	{
				if ${Me.Ability[Claw].IsReady}
				{
					Target ${KillTarget}
					Me.Ability[Claw]:Use
					wait 1
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 1
				}
    	}
 		}
  }

  if ${UseMastersRage}
  {
    ;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
    ;;;;;;;;;;
    if (!${InvalidMasteryTargets.Element[${KillTarget}](exists)})
    {
  		if ${Me.Ability["Master's Rage"].IsReady}
  		{
  			Target ${KillTarget}
  			Me.Ability["Master's Rage"]:Use
  			do
  			{
  			 	waitframe
  			}
  			while ${Me.CastingSpell}
  			wait 1
  		}
  	}
  }

  ;; Combat Leadership AA
  ;; NOTE:  Removing this for now -- I do not think it is worth the effort...
	;if ${Me.Ability[${SpellType[333]}](exists)}
	;{
	;    if (${Me.Ability[${SpellType[333]}].IsReady} && ${Zone.ShortName.Find[venril]} <= 0)
	;    {
	;	    call CastSpellRange 333 0 0 0 ${Me.ID}
	;	}
	;}
	
	
	;;;; DPS Lineup
	;; Devour Vitae
	if (${Me.Ability[${SpellType[153]}].IsReady})
  {
    call _CastSpellRange 153 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}	
	;; Mana Sieve
	if (${Me.Ability[${SpellType[81]}].IsReady})
  {
    call _CastSpellRange 81 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}			
	;; Siphon Strike
	if (${Me.Ability[${SpellType[61]}].IsReady})
  {
    call _CastSpellRange 61 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Shadow Coil
	if (${Me.Ability[${SpellType[60]}].IsReady})
  {
    call _CastSpellRange 60 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Dreadful Wrath
	if (${Me.Ability[${SpellType[154]}].IsReady})
  {
    call _CastSpellRange 154 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}	
	;; Malice
	if (${Me.Ability[${SpellType[62]}].IsReady})
  {
    call _CastSpellRange 62 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Painbringer
	if (${Me.Ability[${SpellType[150]}].IsReady})
  {
    call _CastSpellRange 150 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Soulrend
	if (${Me.Ability[${SpellType[151]}].IsReady})
  {
    call _CastSpellRange 151 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	
	CurrentAction:Set[Combat :: CombatComplete]
	return CombatComplete
}

function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function CheckGroupOrRaidAggro()
{
  declare MobTargetID int local
	variable int Counter = 1

  ;if !${Me.Ability[${SpellType[270]}].IsReady} && !${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Ability[${SpellType[160]}].IsReady}
	;	return 0

  ;; For now, do not do anything automatically when we are not maintank
  if (!${MainTank})
		return 0
	        
	;; The Custom Actor array and "NumNPCs" variable should be set before calling this function
	;EQ2:CreateCustomActorArray[byDist,10,npc]
	;NumNPCs:Set[${EQ2.CustomActorArraySize}]

	do
	{
	    if (!${CustomActor[${Counter}].IsSolo} || ${NumNPCs} > 2)
	    {
	        if (${CustomActor[${Counter}].Target(exists)} && !${CustomActor[${Counter}].Target.Name.Equal[${MainTankPC}]})
	        {
	            if ${Me.InRaid}
	            {
            	    if (${Me.Raid[${CustomActor[${Counter}].Target.Name}](exists)})
            	    {
        	            if (!${CustomActor[${Counter}].Target.Name.Equal[${MainTankPC}]})
        	            {
        	                MobTargetID:Set[${CustomActor[${Counter}].Target.ID}]
        	                call IsFighterOrScout ${MobTargetID}
        	                if (${Return.Equal[FALSE]} && ${MobTargetID} != ${Me.ID})
        	                {
        	                    ;Debug:Echo["Return = FALSE - CustomActor[${Counter}].Target.Health: ${CustomActor[${Counter}].Target.Health}"]
            	                if ${Actor[${MobTargetID}].Health} < 85
            	                {
            	                	if (${HasMythical})
            	                	{
            	                		if (${Me.Equipment[Sedition, Sword of the Bloodmoon].IsReady})
            	                		{
            	                			;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EUsing Mythical!" 3 1
                	                    	echo "EQ2Bot-DEBUG: Using Mythical on ${Actor[${MobTargetID}]}!"
            	                			CustomActor[${Counter}]:DoTarget
            	                			wait 2
            	                			Me.Equipment[Sedition, Sword of the Bloodmoon]:Use
            	                			wait 5
            	                			return 1
            	                		}
            	                	}
                	                if ${Me.Ability[${SpellType[320]}].IsReady}
                	                {
                	                    ;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ERescuing!" 3 1
                	                    echo "EQ2Bot-DEBUG: Rescuing ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 320 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	                elseif ${Me.Ability[${SpellType[338]}].IsReady}
                	                {
                	                    ;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ESneering!" 3 1
                	                    echo "EQ2Bot-DEBUG: Sneering ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 338 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	                elseif ${Me.Ability[${SpellType[330]}].IsReady}
                	                {
                	                    ;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EFeigning ${CustomActor[${Counter}].Target}!" 3 1
                	                    echo "EQ2Bot-DEBUG: Feigning ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 330 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
            	                }
            	                if ${Me.Ability[${SpellType[270]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Casting 'Intercept' (line) on ${Actor[${MobTargetID}]}"
            	                    call CastSpellRange 270 0 0 0 ${MobTargetID} 0 0 0 1
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
            	                    return 1
            	                }
            	                if ${Me.Ability[${SpellType[160]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Taunting ${CustomActor[${Counter}]}"
            	                    call CastSpellRange 160 0 0 0 ${CustomActor[${Counter}].ID} 0 0 0 1
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
            	                    return 1
            	                }
            	                if !${Me.Maintained[${SpellType[240]}](exists)}
            	                {
                	                if ${Me.Ability[${SpellType[240]}].IsReady}
                	                {
                	                    echo "EQ2Bot-DEBUG: Casting 'Knock Down' (line) on ${CustomActor[${Counter}]}"
                	                    call CastSpellRange 240 0 0 0 ${CustomActor[${Counter}].ID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	            }
                	        }
        	                return 0
        	            }
    	            }
	            }
	            else
	            {
            	    if (${Me.Group[${CustomActor[${Counter}].Target.Name}](exists)})
            	    {
            	        echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is ${CustomActor[${Counter}].Target.Name} (MainTankPC is ${MainTankPC})"
        	            if (!${CustomActor[${Counter}].Target.Name.Equal[${MainTankPC}]})
        	            {
        	                MobTargetID:Set[${CustomActor[${Counter}].Target.ID}]
        	                call IsFighterOrScout ${MobTargetID}
        	                if (${Return.Equal[FALSE]} && ${MobTargetID} != ${Me.ID})
        	                {
        	                    ;Debug:Echo["Return = FALSE - CustomActor[${Counter}].Target.Health: ${CustomActor[${Counter}].Target.Health}"]
            	                if ${Actor[${MobTargetID}].Health} < 80
            	                {
            	                	if (${HasMythical})
            	                	{
            	                		if (${Me.Equipment[Sedition, Sword of the Bloodmoon].IsReady})
            	                		{
            	                			;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EUsing Mythical!" 3 1
                	                    	echo "EQ2Bot-DEBUG: Using Mythical on ${Actor[${MobTargetID}]}!"
            	                			CustomActor[${Counter}]:DoTarget
            	                			wait 2
            	                			Me.Equipment[Sedition, Sword of the Bloodmoon]:Use
            	                			wait 5
            	                			return 1
            	                		}
            	                	}
                	                if ${Me.Ability[${SpellType[320]}].IsReady}
                	                {
                	                    ;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ERescuing!" 3 1
                	                    echo "EQ2Bot-DEBUG: Rescuing ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 320 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	                elseif ${Me.Ability[${SpellType[338]}].IsReady}
                	                {
                	                    ;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ESneering!" 3 1
                	                    echo "EQ2Bot-DEBUG: Sneering ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 338 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	                elseif ${Me.Ability[${SpellType[330]}].IsReady}
                	                {
                	                    ;ANNOUNCE IS BROKEN announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EFeigning ${CustomActor[${Counter}].Target}!" 3 1
                	                    echo "EQ2Bot-DEBUG: Feigning ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 330 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
            	                }
            	                if ${Me.Ability[${SpellType[270]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Casting 'Intercept' (line) on ${Actor[${MobTargetID}]}"
            	                    call CastSpellRange 270 0 0 0 ${MobTargetID} 0 0 0 1
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
            	                    return 1
            	                }
            	                if ${Me.Ability[${SpellType[160]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Taunting ${CustomActor[${Counter}]}"
            	                    call CastSpellRange 160 0 0 0 ${CustomActor[${Counter}].ID} 0 0 0 1
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
            	                    return 1
            	                }
            	                if !${Me.Maintained[${SpellType[240]}](exists)}
            	                {
                	                if ${Me.Ability[${SpellType[240]}].IsReady}
                	                {
                	                    echo "EQ2Bot-DEBUG: Casting 'Knock Down' (line) on ${CustomActor[${Counter}]}"
                	                    call CastSpellRange 240 0 0 0 ${CustomActor[${Counter}].ID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	            }
                	        }
        	                return 0
        	            }
    	            }
    	        }
	        }
	    }
	}
	while ${Counter:Inc}<=${EQ2.CustomActorArraySize}

	return 0
}

function FeignDeath()
{
  if ${Me.Ability[${SpellType[330]}].IsReady}
  {
    CurrentAction:Set[Casting Feign Death!]
    call CastSpellRange 330 0 0 0 ${Me.ToActor.ID} 0 0 0 1
  }
}

function HarmTouch()
{
  ;; Cast Harmtouch on current KillTarget
  if ${Me.Ability[${SpellType[63]}].IsReady}
  {
 		CurrentAction:Set[Combat :: Casting Harm Touch!]
    call CastSpellRange 63 0 0 0 ${KillTarget} 0 0 0 1
	}
}

function Have_Aggro()
{
}

function Lost_Aggro(int mobid)
{
  ;; This is now handled in CheckGroupOrRaidAggro()
  EQ2:CreateCustomActorArray[byDist,10,npc]
  NumNPCs:Set[${EQ2.CustomActorArraySize}]
  call CheckGroupOrRaidAggro
  return
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
	;this was moved to CommonHeals in EQ2BotLib
}

function CheckPower()
{
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed
	variable int i
	InPostDeathRoutine:Set[TRUE]

	;;;;;;;;;;;;;;;
	;; Do Buffs before anything else if NOT MainTank
	if !${MainTank}
	{
		i:Set[1]
		do
		{
			call Buff_Routine ${i}
			if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
				break
			call ProcessTriggers
			wait 2
		}
		while ${i:Inc}<=40

		if (${UseCustomRoutines})
		{
			i:Set[1]
			do
			{
				call Custom__Buff_Routine ${i}
				if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
					break
			}
			while ${i:Inc} <= 40
		}
		;;
		;;;;;;;;;;;;;;;
	}
	;; TODO:  Otherwise just do our really fast casting buffs!  (ie, stance, etc.)

	InPostDeathRoutine:Set[FALSE]
	return
}

atom(script) Shadowknight_FinishedZoning(string TimeInSeconds)
{
	if ${KillTarget} && ${Actor[${KillTarget}](exists)}
	{
		if !${Actor[${KillTarget}].InCombatMode}
			KillTarget:Set[0]
	}
}