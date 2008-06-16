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

	declare BuffArmamentMember string script
	declare BuffTacticsGroupMember string script

	declare WeaponHammer string script
	declare WeaponSword string script
	declare WeaponSpear string script
	declare WeaponTwohanded string script
	declare WeaponAxe string script
	declare WeaponMain string script
	declare OffHand string script
	declare EquipmentChangeTimer int script


	call EQ2BotLib_Init

	FullAutoMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Full Auto Mode,FALSE]}]
	TauntMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseDefensiveStance,TRUE]}]
	OffensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseOffensiveStance,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

	BuffArmamentMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffArmamentMember,]}]
	BuffTacticsGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffTacticsGroupMember,]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	WeaponHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Hammer",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Spear",""]}]
	WeaponTwohanded:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Twohanded",""]}]
	WeaponAxe:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Axe",""]}]

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

}

function Combat_Init()
{
   Action[1]:Set[AA_Swiftaxe]
   MobHealth[1,1]:Set[1]
   MobHealth[1,2]:Set[100]
   SpellRange[1,1]:Set[381]
   
   Action[2]:Set[Taunt]
   SpellRange[2,1]:Set[160]
   
   Action[3]:Set[AoE_Taunt]
   SpellRange[3,1]:Set[170]

   Action[4]:Set[AA_Legionnaire_Smite]
   
   ;; nuke + dot
   Action[5]:Set[DDAttack_1]
   Power[5,1]:Set[5]
   Power[5,2]:Set[100]
   SpellRange[5,1]:Set[60]
   
   Action[6]:Set[PBAoE_1]
   Power[6,1]:Set[20]
   Power[6,2]:Set[100]
   SpellRange[6,1]:Set[96]
   
   Action[7]:Set[PBAoE_2]
   Power[7,1]:Set[20]
   Power[7,2]:Set[100]
   SpellRange[7,1]:Set[95]
   
   ;; Level 35 or higher
   Action[8]:Set[PBAoE_3]
   Power[8,1]:Set[20]
   Power[8,2]:Set[100]
   SpellRange[8,1]:Set[97]   
   
   ;; Level 55 or higher
   Action[9]:Set[PBAoE_4]
   Power[9,1]:Set[20]
   Power[9,2]:Set[100]
   SpellRange[9,1]:Set[98]   
   
   ;; Level 65 or higher
   Action[10]:Set[PBAoE_5]
   Power[10,1]:Set[20]
   Power[10,2]:Set[100]
   SpellRange[10,1]:Set[99]   
   
   ;; Level 40 and higher
   Action[11]:Set[DDAttack_8]
   Power[11,1]:Set[5]
   Power[11,2]:Set[100]
   SpellRange[11,1]:Set[154]      
    
   ;; nuke + lifetap
   Action[12]:Set[DDAttack_2]
   Power[12,1]:Set[5]
   Power[12,2]:Set[100]
   SpellRange[12,1]:Set[153]
  
   ;; nuke + dot 
   Action[13]:Set[DDAttack_3]
   Power[13,1]:Set[5]
   Power[13,2]:Set[100]
   SpellRange[13,1]:Set[150]
   
    ;; Nuke + wis debuff
   Action[14]:Set[DDAttack_4]
   Power[14,1]:Set[5]
   Power[14,2]:Set[100]
   SpellRange[14,1]:Set[152]

   ;; Nuke + damage on termination
   Action[15]:Set[DDAttack_5]
   Power[15,1]:Set[5]
   Power[15,2]:Set[100]
   SpellRange[15,1]:Set[61]
   
   ;; "Boot" (knockdown)
   Action[16]:Set[DDAttack_6]
   Power[16,1]:Set[5]
   Power[16,2]:Set[100]
   SpellRange[16,1]:Set[151]
   
   ;; Pure Nuke
   Action[17]:Set[DDAttack_7]
   Power[17,1]:Set[5]
   Power[17,2]:Set[100]
   SpellRange[17,1]:Set[62]   
   
   

   ;; NOTE:  "63" is Harm touch
    
   ; Level 50+
   Action[18]:Set[Mist]
   MobHealth[18,1]:Set[50]
   MobHealth[18,2]:Set[100]
   Power[18,1]:Set[20]
   Power[18,2]:Set[100]
   SpellRange[18,1]:Set[55]

   Action[19]:Set[Damage_Debuff]
   MobHealth[19,1]:Set[5]
   MobHealth[19,2]:Set[100]
   Power[19,1]:Set[20]
   Power[19,2]:Set[100]
   SpellRange[19,1]:Set[81]

   Action[20]:Set[Shield_Attack]
   Power[20,1]:Set[5]
   Power[20,2]:Set[100]
   SpellRange[20,1]:Set[240]

   Action[21]:Set[Pet]
   MobHealth[21,1]:Set[50]
   MobHealth[21,2]:Set[100]
   SpellRange[21,1]:Set[45]

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
	variable int temp

	call WeaponChange

	if ${ShardMode}
	{
		call Shard
	}

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

	switch ${PreAction[${xAction}]}
	{

		case Armament_Target
			BuffTarget:Set[${UIElement[cbBuffArmamentGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 1
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
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		        call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
			
		case Group_Buff2
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		        call CastSpellRange ${PreSpellRange[${xAction},1]}	
			break			


		case Tactics_Target
			BuffTarget:Set[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 1
			}
			break
		Default
			return BuffComplete
	}

}

function Combat_Routine(int xAction)
{
	call WeaponChange

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}
    
    if ${StartHO}
    {
    	if !${EQ2.HOWindowActive}
    	{
    		call CastSpellRange 303
    	}
    }
    
	;; Draw Strength (Always cast this when it is ready!
	if !${Me.Maintained[${SpellType[80]}](exists)}
	{
    	if ${Me.Ability[${SpellType[80]}](exists)}
    	{
    	    if (${Me.Ability[${SpellType[80]}].IsReady})
    		    call CastSpellRange 80 0 0 0 ${KillTarget}
    	}   
    } 

	;The following till FullAuto could be nested in FullAuto, but I think bot control of these abilities is better
	call UseCrystallizedSpirit 60

    call CheckGroupOrRaidAggro

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]
	
	switch ${Action[${xAction}]}
	{
		case Taunt
		case AoE_Taunt
			if ${TauntMode}
			{
    			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
    			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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
    			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
			
			
        case PBAoE_1
        case PBAoE_2
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
    			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break			
			
		case AA_Legionnaire_Smite
		    if (${Me.Ability["Legionnaire's Smite"](exists)})
		    {
    			if ${Me.Ability["Legionnaire's Smite"].IsReady}
    			    call CastSpellRange "Legionnaire's Smite" 0 0 0 ${KillTarget}		
    		}    
        
        case PBAoE_3
            if ${Me.Level} >= 35
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
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
    			}
			}
			break
        
        case PBAoE_4
            if ${Me.Level} >= 55
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
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
    			}
			}
			break  

        case PBAoE_5
            if ${Me.Level} >= 65
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
        			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
    			}
			}
			break  
			
			
		case Damage_Debuff
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
		
		case Mist
			if ${Me.Level} >= 50
			{
				if ${Mob.Count}>1
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
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
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
			}
			break

		case AA_Swiftaxe
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
			}
			break
			
		case Pet
		    if (${PetMode})
		    {
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			;; "Pet" is the last thing in the routine ...so, return CombatComplete
			return CombatComplete		
			
		default
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
    
    if !${Me.Ability[${SpellType[270]}].IsReady} && !${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Ability[${SpellType[160]}].IsReady}
        return
        
    
	variable int Counter = 1

	EQ2:CreateCustomActorArray[byDist,10]   
    
	do
	{
	    if (${CustomActor[${Counter}].Type.Find[NPC]} && !${CustomActor[${Counter}].IsSolo})
	    {
	        if (${CustomActor[${Counter}].Target(exists)} && !${CustomActor[${Counter}].Target.Name.Equal[${MainTankPC}]})
	        {
	            if ${Me.InRaid}
	            {
            	    if (${Me.Raid[${CustomActor[${Counter}].Target.Name}](exists)})
            	    {
        	            if (!${CustomActor[${Counter}].Target.Name.Equal[${Me.Name}]})
        	            {
        	                if ${Me.Group[${CustomActor[${Counter}].Target.Name}].ToActor.Health} < 60
        	                {
            	                if ${Me.Ability[${SpellType[320]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Rescuing ${CustomActor[${Counter}].Target}!"
            	                    call CastSpellRange 320 0 0 0 ${CustomActor[${Counter}].ID}
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
            	                }          	                
        	                }        	                
        	                if ${Me.Ability[${SpellType[270]}].IsReady}
        	                {
        	                    echo "EQ2Bot-DEBUG: Casting 'Intercept' (line) on ${CustomActor[${Counter}].Target}"
        	                    call CastSpellRange 270 0 0 0 ${CustomActor[${Counter}].Target.ID}     	                    
        	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
        	                }  
        	                if ${Me.Ability[${SpellType[160]}].IsReady}
        	                {
        	                    echo "EQ2Bot-DEBUG: Taunting ${CustomActor[${Counter}]}"
        	                    call CastSpellRange 160 0 0 0 ${CustomActor[${Counter}].ID}      	                    
        	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
        	                }            	                          
        	                if !${Me.Maintained[${SpellType[7]}](exists)}
        	                {
            	                if ${Me.Ability[${SpellType[7]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Casting 'Infernal Pact' (line) on ${CustomActor[${Counter}].Target}"
            	                    call CastSpellRange 7 0 0 0 ${CustomActor[${Counter}].Target.ID}
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
            	                }          	                
            	            }
        	                return
        	            }
    	            }    
	            }
	            else
	            {
            	    if (${Me.Group[${CustomActor[${Counter}].Target.Name}](exists)})
            	    {
            	        echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is ${CustomActor[${Counter}].Target.Name} (MainTankPC is ${MainTankPC})"
        	            if (!${CustomActor[${Counter}].Target.Name.Equal[${Me.Name}]})
        	            {
        	                if ${Me.Group[${CustomActor[${Counter}].Target.Name}].ToActor.Health} < 60
        	                {
            	                if ${Me.Ability[${SpellType[320]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Rescuing ${CustomActor[${Counter}].Target}!"
            	                    call CastSpellRange 320 0 0 0 ${CustomActor[${Counter}].ID}
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
            	                }  
        	                }
        	                if ${Me.Ability[${SpellType[270]}].IsReady}
        	                {
        	                    echo "EQ2Bot-DEBUG: Casting 'Intercept' (line) on ${CustomActor[${Counter}].Target}"
        	                    call CastSpellRange 270 0 0 0 ${CustomActor[${Counter}].Target.ID}     	                    
        	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
        	                }   
        	                if ${Me.Ability[${SpellType[160]}].IsReady}
        	                {
        	                    echo "EQ2Bot-DEBUG: Taunting ${CustomActor[${Counter}]}"
        	                    call CastSpellRange 160 0 0 0 ${CustomActor[${Counter}].ID}    	  
        	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}"                   
        	                }         	                         
        	                if !${Me.Maintained[${SpellType[7]}](exists)}
        	                {
            	                if ${Me.Ability[${SpellType[7]}].IsReady}
            	                {
            	                    echo "EQ2Bot-DEBUG: Casting 'Infernal Pact' (line) on ${CustomActor[${Counter}].Target}"
            	                    call CastSpellRange 7 0 0 0 ${CustomActor[${Counter}].Target.ID}
            	                    echo "EQ2Bot-DEBUG: ${CustomActor[${Counter}]}'s target is now ${CustomActor[${Counter}].Target.Name}" 
            	                }  	                
            	            }
        	                return
        	            }
    	            }
    	        }
	        }
	    }
	}
	while ${Counter:Inc}<=${EQ2.CustomActorArraySize}
}

function Have_Aggro()
{

}

function Lost_Aggro(int mobid)
{
    ;; This is now handled in CheckGroupOrRaidAggro()
    return
    
    if ${MainTank}
    {
    	if ${Me.ToActor.Power}>5
    	{
    		if ${TauntMode}
    		{
    			;intercept damage on the person now with agro
    			call CastSpellRange 7 0 1 0 ${mobid} 0 0 1
    			call CastSpellRange 270 0 1 0 ${mobid} 0 0 1
    			call CastSpellRange 160 0 1 0 ${mobid} 0 0 1
    
    
    
    			;use rescue if new agro target is under 65 health
    			if ${Me.ToActor.Target.Target.Health}<65
    			{
    				call CastSpellRange 320 0 1 0 ${mobid} 0 0 1
    			}
    		}
    	}
    }
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

