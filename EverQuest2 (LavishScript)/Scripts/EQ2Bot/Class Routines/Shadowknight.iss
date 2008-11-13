;*************************************************************
;Shadowknight.iss
;version 20070130a
;by Pygar
;
;20070130a
;Fixed range checks on taunts
;Improved lost agro function
;Updated for eq2bot 2.5.2
;Minor Fixes
;Added Crystalized Spirit use.
;
;20061110b-exp
;experimental build based upon feedback from Akku
;
;20061110a
;Fixed Crash on Agro Loss
;Fixed PBAoE Spells to fire properly now
;Fixed Melee nukes / dots to work now (Coil, HT, and Fetid Strike were unreliable)
;
;20061103a
;First Public Release
;
; FIXED: PBAoE should work, No crash on agro loss, Will use Coil and HT now
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 20080408
    ;;;;

	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare StartHO bool script 1
	declare PetMode bool script 1
	declare UseReaver bool script TRUE
	declare UseSiphonHateWhenNotMT bool script FALSE
	declare UseBattleLeadershipAABuff bool script FALSE
	declare UseFearlessMoraleAABuff bool script FALSE
	declare UseDeathMarch bool script FALSE
	declare UseMastersRage bool script TRUE
	declare HasMythical bool script FALSE
	declare InPostDeathRoutine bool script FALSE

	declare BuffArmamentMember string script
	declare BuffTacticsGroupMember string script

	call EQ2BotLib_Init

	FullAutoMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Full Auto Mode,FALSE]}]
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDefensiveStance,TRUE]}]
	OffensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseOffensiveStance,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	UseReaver:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseReaver,TRUE]}]
	UseSiphonHateWhenNotMT:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseSiphonHateWhenNotMT,FALSE]}]
	UseBattleLeadershipAABuff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseBattleLeadershipAABuff,FALSE]}]
	UseFearlessMoraleAABuff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseFearlessMoraleAABuff,FALSE]}]
	UseDeathMarch:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDeathMarch,FALSE]}]
	UseMastersRage:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseMastersRage,TRUE]}]


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


	; Do not remove/change
	ClassPulseTimer:Set[${Script.RunningTime}]
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
   
   ; Removed in TSO
   PreAction[14]:Set[SiphonHate]
   PreSpellRange[14,1]:Set[335]  

}

function Combat_Init()
{
   Action[1]:Set[AA_Swiftaxe]
   MobHealth[1,1]:Set[1]
   MobHealth[1,2]:Set[100]
   SpellRange[1,1]:Set[381]

   Action[2]:Set[Taunt]
   SpellRange[2,1]:Set[160]

   ;; For now, I want to cast PBAoE_3 early in the fight (ie, Tap Veins) as it gives health on termination
   Action[3]:Set[PBAoE_3]
   MobHealth[3,1]:Set[50]
   MobHealth[3,2]:Set[100]
   SpellRange[3,1]:Set[98]

   Action[4]:Set[AA_Legionnaire_Smite]

   ;; nuke + dot
   Action[5]:Set[DDAttack_1]
   Power[5,1]:Set[5]
   Power[5,2]:Set[100]
   SpellRange[5,1]:Set[60]

   Action[6]:Set[PBAoE_1]
   Power[6,1]:Set[10]
   Power[6,2]:Set[100]
   SpellRange[6,1]:Set[96]

   ;; Level 35 or higher
   Action[7]:Set[PBAoE_2]
   Power[7,1]:Set[10]
   Power[7,2]:Set[100]
   SpellRange[7,1]:Set[97]

   ;; Level 55 or higher
   Action[8]:Set[PBAoE_3]
   Power[8,1]:Set[10]
   Power[8,2]:Set[100]
   SpellRange[8,1]:Set[98]


   ;; Level 65 or higher
   Action[9]:Set[PBAoE_4]
   Power[9,1]:Set[10]
   Power[9,2]:Set[100]
   SpellRange[9,1]:Set[99]

   Action[10]:Set[PBAoE_5]
   Power[10,1]:Set[10]
   Power[10,2]:Set[100]
   SpellRange[10,1]:Set[95]


   ;; nuke + lifetap
   Action[11]:Set[DDAttack_2]
   Power[11,1]:Set[5]
   Power[11,2]:Set[100]
   SpellRange[11,1]:Set[153]

   ;; nuke + dot
   Action[12]:Set[DDAttack_3]
   Power[12,1]:Set[5]
   Power[12,2]:Set[100]
   SpellRange[12,1]:Set[150]

    ;; Nuke + **wis debuff**
   Action[13]:Set[DDAttack_4]
   Power[13,1]:Set[5]
   Power[13,2]:Set[100]
   SpellRange[13,1]:Set[152]

   ;; Nuke + damage on termination
   Action[14]:Set[DDAttack_5]
   Power[14,1]:Set[5]
   Power[14,2]:Set[100]
   SpellRange[14,1]:Set[61]

   ;; "Boot" (knockdown)
   Action[15]:Set[DDAttack_6]
   Power[15,1]:Set[5]
   Power[15,2]:Set[100]
   SpellRange[15,1]:Set[151]

   ;; Pure Nuke
   Action[16]:Set[DDAttack_7]
   Power[16,1]:Set[5]
   Power[16,2]:Set[100]
   SpellRange[16,1]:Set[62]

   ;; Level 40 and higher
   Action[17]:Set[DDAttack_8]
   Power[17,1]:Set[5]
   Power[17,2]:Set[100]
   SpellRange[17,1]:Set[154]

   ;; NOTE:  "63" is Harm touch

   ; Level 50+
   Action[18]:Set[Mist]
   MobHealth[18,1]:Set[10]
   MobHealth[18,2]:Set[100]
   Power[18,1]:Set[20]
   Power[18,2]:Set[100]
   SpellRange[18,1]:Set[55]

   Action[19]:Set[Shield_Attack]
   Power[19,1]:Set[5]
   Power[19,2]:Set[100]
   SpellRange[19,1]:Set[240]

   Action[20]:Set[Pet]
   MobHealth[20,1]:Set[50]
   MobHealth[20,2]:Set[100]
   SpellRange[20,1]:Set[45]

}

function PostCombat_Init()
{

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
			if (!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Zone.ShortName.Find[venril]} <= 0)
		        call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Group_Buff2
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		        call CastSpellRange ${PreSpellRange[${xAction},1]}
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
		        if ${Me.Maintained[Reaver](exists)}
		            Me.Maintained[Reaver]:Cancel
		    }
			break

		case SiphonHate
		    if !${Me.Ability[Siphon Hate](exists)}
		        break

		    if (${MainTank} || ${UseSiphonHateWhenNotMT})
		    {
    			if !${Me.Maintained[Siphon Hate](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
    		}
		    else
		    {
		        if ${Me.Maintained[Siphon Hate](exists)}
		            Me.Maintained[Siphon Hate]:Cancel
		    }
			break

	    case BattleLeadershipAABuff
		    if ${UseBattleLeadershipAABuff}
		    {
    			if !${Me.Maintained[Battle Leadership](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
		    }
		    else
		    {
		        if ${Me.Maintained[Battle Leadership](exists)}
		            Me.Maintained[Battle Leadership]:Cancel
		    }
			break

	    case FearlessMoraleAABuff
		    if ${UseFearlessMoraleAABuff}
		    {
    			if !${Me.Maintained[Fearless Morale](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
		    }
		    else
		    {
		        if ${Me.Maintained[Fearless Morale](exists)}
		            Me.Maintained[Fearless Morale]:Cancel
		    }
			break
			
		case AuraOfLeadershipAABuff
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[Fearless Morale](exists)}
			    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
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

function Combat_Routine(int xAction)
{
    declare BuffTarget string local
    declare NumNPCs int local
	declare spellsused int local
	spellsused:Set[0]

	if ${DoHOs}
		objHeroicOp:DoHO

    if ${StartHO}
    {
    	if !${EQ2.HOWindowActive}
    		call CastSpellRange 303
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
	        announce "I am either frozen, rooted, stunned or charmed...\n\\#FF6E6EUsing Aura of the Crusader!" 3 1
	        call CastSpellRange 339 0 0 0 ${Me.ID} 0 0 0 1
	    }
	}    
    

    EQ2:CreateCustomActorArray[ByDist,10,npc]
    NumNPCs:Set[${EQ2.CustomActorArraySize}]
    ;Debug:Echo["NumNPCs: ${NumNPCs}"]

    ; always cast when up (Disease Resist Reduction and Hate Builder (AE))  -- (AE TAUNT!)  -- NOTE:  For now, we cast this even if 'tauntmode' is off
    if ${PBAoEMode}
    {
        if ${MainTank}
        {
            CurrentAction:Set[Combat :: Taunting]
    	    if (${Me.Ability[${SpellType[170]}].IsReady})
    	    {
    	        if !${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 50
    	        {
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
        		elseif (${NumNPCs} > 1 && ${Actor[${KillTarget}].Health} > 50)
        		{
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
        	}
        	;; Always try to cast fast casting Combat Arts aftewards to gain aggro (if tank)
            if (${Me.Ability[${SpellType[152]}].IsReady})
            {
                call CastSpellRange 152 0 0 0 ${KillTarget} 0 0 0 1
                spellsused:Inc
            }
            if (${Me.Ability[${SpellType[151]}].IsReady})
            {
                call CastSpellRange 151 0 0 0 ${KillTarget} 0 0 0 1
                spellsused:Inc
            }

			; shield bash
		    if (${Me.Ability[${SpellType[240]}].IsReady})
		    {
			    call CastSpellRange 240 0 0 0 ${KillTarget}
			    spellsused:Inc
			}
			; taunt
			if (${MainTank} && ${Me.Ability[${SpellType[160]}].IsReady})
		    {
			    call CastSpellRange 160 0 0 0 ${KillTarget}
			    spellsused:Inc
			}

        }
        else
        {
            if !${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 90
            {
        	    if (${Me.Ability[${SpellType[170]}].IsReady})
        	    {
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
        	}
        	elseif (${NumNPCs} > 1 && ${Actor[${KillTarget}].Health} > 50)
        	{
        	    if (${Me.Ability[${SpellType[170]}].IsReady})
        	    {
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
        	}
        }
    }
    if ${NumNPCs} > 3
    {
        ;; DeathMarch
        if ${Me.Level} >= 58
        {
        	if !${Me.Maintained[${SpellType[312]}](exists)}
        	{
        	    if (${Me.Ability[${SpellType[312]}].IsReady})
        	    {
        		    call CastSpellRange 312 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
            }
        }
        ;; AE Life Tap
        ;waitframe
        if ${PBAoEMode}
        {
    	    if (${Me.Ability[${SpellType[98]}].IsReady})
    	    {
    		    call CastSpellRange 98 0 0 0 ${KillTarget} 0 0 0 1
    		    spellsused:Inc
    		}
    	}
        ;; Self Reverse DS (with life tap proc)
        if !${Me.Maintained[${SpellType[7]}](exists)}
        {
        	if ${Me.Ability[${SpellType[7]}].IsReady}
        	{
        	    if ${MainTank}
        	    {
            	    call CastSpellRange 7 0 0 0 ${Me.ToActor.ID} 0 0 0 1
            	    spellsused:Inc
            	}
        	    else
        	    {
            	    call CastSpellRange 7 0 0 0 ${MainTankID} 0 0 0 1
            	    spellsused:Inc
            	}
            }
        }
    }


    ;; MIST -- should be casted after AE taunt at the beginning of the fight  (Physical damage mit debuff)
    if ${Me.Level} >= 50 && ${PBAoEMode}
	{
	    if (!${Actor[${KillTarget}].IsSolo} || ${NumNPCs} > 1)
	    {
    	    if (${Actor[${KillTarget}].Health} > 70 || ${Actor[${KillTarget}].IsEpic})
    	    {
	            CurrentAction:Set[Combat :: Mist]
    	        if !${Me.Maintained[${SpellType[55]}](exists)}
    	        {
        	        if (${Me.Ability[${SpellType[55]}].IsReady})
        	        {
        		        call CastSpellRange 55 0 0 0 ${KillTarget} 0 0 0 1
        		        spellsused:Inc
        		    }
            	}
        	}
        }
	}

	;; Draw Strength (Always cast this when it is ready!)
	if (!${Actor[${KillTarget}].IsSolo} || ${NumNPCs} > 1)
	{
	    CurrentAction:Set[Combat :: Draw Strength]
    	if !${Me.Maintained[${SpellType[80]}](exists)}
    	{
        	if ${Me.Ability[${SpellType[80]}](exists)}
        	{
        	    if (${Me.Ability[${SpellType[80]}].IsReady})
        	    {
        		    call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
        	}
        }
    }

    ;;;;;
  	;;; Quick Spells for aggro
	; shield bash
    if (${Me.Ability[${SpellType[240]}].IsReady})
    {
	    call CastSpellRange 240 0 0 0 ${KillTarget}
	    spellsused:Inc
	}
	; taunt
	if (${MainTank} && ${Me.Ability[${SpellType[160]}].IsReady})
    {
	    call CastSpellRange 160 0 0 0 ${KillTarget}
	    spellsused:Inc
	}
	; kick
	if (${Me.Ability[${SpellType[151]}].IsReady})
    {
	    call CastSpellRange 151 0 0 0 ${KillTarget}
	    spellsused:Inc
	}
	;;
	;;;;

    ;; Death March
    if (${UseDeathMarch})
    {
    	if (${Me.Level} >= 58 && !${Actor[${KillTarget}].ConColor.Equal[Grey]})
    	{
            CurrentAction:Set[Combat :: Death March]
        	if !${Me.Maintained[${SpellType[312]}](exists)}
        	{
        	    if (${Me.Ability[${SpellType[312]}].IsReady})
        	    {
        		    call CastSpellRange 312 0 0 0 ${KillTarget} 0 0 0 1
        		    spellsused:Inc
        		}
            }
        }
    }

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
                			    spellsused:Inc
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
    spellsused:Inc[${Return}]

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
				spellsused:Inc
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
            if ${Actor[${KillTarget}].Level} > ${Me.Level}
            {
    			if ${Me.Ability[Claw].IsReady}
    			{
    				Target ${KillTarget}
    				Me.Ability[Claw]:Use
    				spellsused:Inc
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
    			spellsused:Inc
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
	;	    spellsused:Inc
	;	}
	;}

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]

	switch ${Action[${xAction}]}
	{
	    case Placeholder
	        break

		case Taunt
			if ${TauntMode}
			{
    			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
    			{
    			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
    			    spellsused:Inc
    			}
			}
			break

        case DDAttack_1
        case DDAttack_2
        case DDAttack_3
        case DDAttack_4
        case DDAttack_5
        case DDAttack_6
        case DDAttack_7
        case DDAttack_8
            call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
            if ${Return.Equal[OK]}
            {
                if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
                {
    			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
    			    spellsused:Inc
    			}
			}
			break


        case PBAoE_1
            if (${PBAoEMode})
            {
                if ${Actor[${KillTarget}].IsSolo}
                {
                    EQ2:CreateCustomActorArray[byDist,5,npc]
                    if ${EQ2.CustomActorArraySize} < 2
                        break
                }
                call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                if ${Return.Equal[OK]}
                {
                    if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
                    {
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
        			    spellsused:Inc
        			}
    			}
    		}
			break

        case PBAoE_2
            if (${PBAoEMode} && ${Me.Level} >= 35)
            {
                if ${Actor[${KillTarget}].IsSolo}
                {
                    EQ2:CreateCustomActorArray[byDist,5,npc]
                    if ${EQ2.CustomActorArraySize} < 2
                        break
                }
                call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                if ${Return.Equal[OK]}
                {
                    if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
                    {
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
        			    spellsused:Inc
        			}
    			}
    		}
			break

		case AA_Legionnaire_Smite
		    if ${Me.Level} > 50
		        break
		    if (${Me.Ability["Legionnaire's Smite"](exists)})
		    {
    			if ${Me.Ability["Legionnaire's Smite"].IsReady}
    			{
    			    call CastSpellRange 332 0 0 0 ${KillTarget} 0 0 0 1
    			    spellsused:Inc
    			}
    		}
    		break

        case PBAoE_3
            if (${PBAoEMode} && ${Me.Level} >= 55)
            {
                if ${Actor[${KillTarget}].IsSolo}
                {
                    EQ2:CreateCustomActorArray[byDist,5,npc]
                    if ${EQ2.CustomActorArraySize} < 2
                        break
                }
                call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                if ${Return.Equal[OK]}
                {
        			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
        			{
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
        			    spellsused:Inc
        			}
    			}
			}
			break

        case PBAoE_4
            if (${PBAoEMode} && ${Actor[${KillTarget}].EncounterSize} > 1 && ${Me.Level} >= 65)
            {
                if ${Actor[${KillTarget}].IsSolo}
                {
                    EQ2:CreateCustomActorArray[byDist,5,npc]
                    if ${EQ2.CustomActorArraySize} < 2
                        break
                }
                call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                if ${Return.Equal[OK]}
                {
        			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
        			{
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
        			    spellsused:Inc
        			}
    			}
			}
			break

        case PBAoE_5
            if (${PBAoEMode})
            {
                if ${Actor[${KillTarget}].IsSolo}
                {
                    EQ2:CreateCustomActorArray[byDist,5,npc]
                    if ${EQ2.CustomActorArraySize} < 2
                        break
                }
                call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                if ${Return.Equal[OK]}
                {
        			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
        			{
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
        			    spellsused:Inc
        			}
    			}
			}
			break

		case Shield_Attack
			If ${Me.Equipment[Secondary].Type.Equal[Shield]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1 1
					spellsused:Inc
				}
			}
			break

		case AA_Swiftaxe
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1 1
					spellsused:Inc
				}
			}
			break

		case Pet
		    if (${PetMode})
		    {
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
					spellsused:Inc
				}
			}
			;; "Pet" is the last thing in the routine ...so, return CombatComplete
			if (${spellsused} < 1)
				call CastSomething
			return CombatComplete

		default
			if (${spellsused} < 1)
				call CastSomething
			return CombatComplete
	}
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
    declare NumNPCs int local
    declare MobTargetID int local


    if !${Me.Ability[${SpellType[270]}].IsReady} && !${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Ability[${SpellType[160]}].IsReady}
        return 0


	variable int Counter = 1

    ;; This is now created in the Combat_Routine() each time it is called (and Combat_Routine() is the only function that calls THIS function)
	;EQ2:CreateCustomActorArray[byDist,10,npc]
    NumNPCs:Set[${EQ2.CustomActorArraySize}]

	do
	{
	    ;; For now, do not do anything automatically when we are not maintank
	    if (!${MainTank})
	        continue

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
            	                			announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EUsing Mythical!" 3 1
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
                	                    announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ERescuing!" 3 1
                	                    echo "EQ2Bot-DEBUG: Rescuing ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 320 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	                elseif ${Me.Ability[${SpellType[338]}].IsReady}
                	                {
                	                    announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ESneering!" 3 1
                	                    echo "EQ2Bot-DEBUG: Sneering ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 338 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }                	                
                	                elseif ${Me.Ability[${SpellType[330]}].IsReady}
                	                {
                	                    announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EFeigning ${CustomActor[${Counter}].Target}!" 3 1
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
            	                			announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EUsing Mythical!" 3 1
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
                	                    announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ERescuing!" 3 1
                	                    echo "EQ2Bot-DEBUG: Rescuing ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 320 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                }
                	                elseif ${Me.Ability[${SpellType[338]}].IsReady}
                	                {
                	                    announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6ESneering!" 3 1
                	                    echo "EQ2Bot-DEBUG: Sneering ${Actor[${MobTargetID}]}!"
                	                    call CastSpellRange 338 0 0 0 ${MobTargetID} 0 0 0 1
                	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"
                	                    return 1
                	                } 
                	                elseif ${Me.Ability[${SpellType[330]}].IsReady}
                	                {
                	                    announce "${Actor[${MobTargetID}]} has aggro (${Actor[${MobTargetID}].Health}% health)...\n\\#FF6E6EFeigning ${CustomActor[${Counter}].Target}!" 3 1
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
    if ${Me.ToActor.Power} < 50
    {
	    if (${Me.Ability[${SpellType[81]}].IsReady})
		    call CastSpellRange 81 0 0 0 ${KillTarget} 0 0 0 1
    }
}

function CastSomething()
{
	;; If this function is called, it is because we went through teh combat routine without casting any spells.
	;; This function is intended to cast SOMETHING in order to keep "Perputuality" going.

	;Debug:Echo["---"]
	;Debug:Echo["CastSomething() called."]


	; shield bash
    if (${Me.Ability[${SpellType[240]}].IsReady})
    {
	    call CastSpellRange 240 0 0 0 ${KillTarget}
	    return
	}
	; taunt
	if (${MainTank} && ${Me.Ability[${SpellType[160]}].IsReady})
    {
	    call CastSpellRange 160 0 0 0 ${KillTarget}
	    return
	}
	; kick
	if (${Me.Ability[${SpellType[151]}].IsReady})
    {
	    call CastSpellRange 151 0 0 0 ${KillTarget}
	    return
	}

	;; Combat Leadership AA
	;; NOTE:  Removing for now ..I do not think it is worth the effort
	;if (${Me.Ability[${SpellType[333]}](exists)} && ${Zone.ShortName.Find[venril]} <= 0)
	;{
	;    if (${Me.Ability[${SpellType[333]}].IsReady})
	;    {
	;	    call CastSpellRange 333 0 0 0 ${Me.ID}
	;	    return
	;	}
	;}



    if ${PBAoEMode}
    {
        if ${MainTank}
        {
            CurrentAction:Set[Combat :: Taunting]
    	    if (${Me.Ability[${SpellType[170]}].IsReady})
    	    {
    	        if ${Actor[${KillTarget}].Health} > 50
    	        {
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    return
        		}
        		elseif (${Actor[${KillTarget}].Health} > 50)
        		{
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    return
        		}
        	}
        	;; Always try to cast fast casting Combat Arts aftewards to gain aggro (if tank)
            if (${Me.Ability[${SpellType[152]}].IsReady})
            {
                call CastSpellRange 152 0 0 0 ${KillTarget} 0 0 0 1
                return
            }
            if (${Me.Ability[${SpellType[151]}].IsReady})
            {
                call CastSpellRange 151 0 0 0 ${KillTarget} 0 0 0 1
                return
            }
	        if (${Me.Ability[${SpellType[98]}].IsReady})
	        {
	    		call CastSpellRange 98 0 0 0 ${KillTarget} 0 0 0 1
	    		return
	    	}
        }
        else
        {
            if ${Actor[${KillTarget}].Health} < 90
            {
        	    if (${Me.Ability[${SpellType[170]}].IsReady})
        	    {
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    return
        		}
        	}
        	elseif (${Actor[${KillTarget}].Health} > 50)
        	{
        	    if (${Me.Ability[${SpellType[170]}].IsReady})
        	    {
        		    call CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
        		    return
        		}
        	}

            if (${Me.Ability[${SpellType[152]}].IsReady})
            {
                call CastSpellRange 152 0 0 0 ${KillTarget} 0 0 0 1
                return
            }
            if (${Me.Ability[${SpellType[151]}].IsReady})
            {
                call CastSpellRange 151 0 0 0 ${KillTarget} 0 0 0 1
                return
            }
	        if (${Me.Ability[${SpellType[98]}].IsReady})
	        {
	    		call CastSpellRange 98 0 0 0 ${KillTarget} 0 0 0 1
	    		return
	    	}
        }
    }
    else
    {
        if (${Me.Ability[${SpellType[152]}].IsReady})
        {
            call CastSpellRange 152 0 0 0 ${KillTarget} 0 0 0 1
            return
        }
        if (${Me.Ability[${SpellType[151]}].IsReady})
        {
            call CastSpellRange 151 0 0 0 ${KillTarget} 0 0 0 1
            return
        }
	}


	; pet
	if (${Me.Ability[${SpellType[45]}].IsReady})
    {
	    call CastSpellRange 45 0 0 0 ${KillTarget}
	    return
	}
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
	;; TODO:  Otherwise jsut do our really fast casting buffs!  (ie, stance, etc.)
	
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