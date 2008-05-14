;*************************************************************
;Illusionist.iss
;version 20080323a
;by pygar
;
;20080323a (Amadeus)
; * Moved "Focus" buff to the combat routines.  It is a short duration buff and should only be used during combat when the
;   target is over 80% health.
;
;20070725a
; Minor changes to adjust for AA tweaks in game.
;
;20070504a
; Added Cure Arcane Routine
; Allies used only on aggro now or solo
; Intelligent use of Time Compression and Illusionary Arm
; Manaflow on lowest member if under 60 power and illusionist over 30 health
;
;20070404a
;	Updated for latest eq2bot
;	Fixed bugs in AA release
;	Updated Master Strikes
;	Tweaks to mezing to prevent over aggressive behavior
;
;20070201a
;Added Support for KoS and EoF AA
;Updated and Optomized for EQ2Bot 2.5.2
;Added Toggle for Initiating HO's
;
;Initial Release
;Limited AA support:  Currently only Mana Flow implemented
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 20080408
    ;;;;
    
	declare AoEMode bool script FALSE
	declare MezzMode bool script FALSE
	declare Makepet bool script FALSE
	declare BuffAspect bool script FALSE
	declare BuffRune bool script FALSE
	declare StartHO bool script 1
	declare DPSMode bool script 1
	declare SummonImpOfRo bool script 0
	
	call EQ2BotLib_Init

	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	BuffAspect:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAspect,FALSE]}]
	BuffRune:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffRune,FALSE]}]
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	Makepet:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Makepet,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	BuffTime_Compression:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffTime_Compression,]}]
	BuffIllusory_Arm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffIllusory_Arm,]}]
	DPSMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[DPSMode,FALSE]}]
	SummonImpOfRo:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Summon Imp of Ro,]}]
	    
	NoEQ2BotStance:Set[TRUE]

}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Aspect]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[MakePet]
	PreSpellRange[3,1]:Set[355]

	;haste
	PreAction[4]:Set[Melee_Buff]
	PreSpellRange[4,1]:Set[35]

    ; ie, dynamism
	PreAction[5]:Set[Caster_Buff]
	PreSpellRange[5,1]:Set[40]

	PreAction[6]:Set[Rune]
	PreSpellRange[6,1]:Set[20]

	PreAction[7]:Set[Clarity]
	PreSpellRange[7,1]:Set[22]

	PreAction[8]:Set[AA_Empathic_Aura]
	PreSpellRange[8,1]:Set[391]

	PreAction[9]:Set[AA_Empathic_Soothing]
	PreSpellRange[9,1]:Set[392]

	PreAction[10]:Set[AA_Time_Compression]
	PreSpellRange[10,1]:Set[393]

	PreAction[11]:Set[AA_Illusory_Arm]
	PreSpellRange[11,1]:Set[394]
	
	PreAction[12]:Set[SummonImpOfRoBuff]
}

function Combat_Init()
{
    ;;;;;;;;;;;;;;;;; DPS ;;;;;;;;;;;;;;;;;
    
    ;; Stifle over time, and NUKE
	Action[1]:Set[Silence]
	SpellRange[1,1]:Set[260]
	
    ;; Slow casting NUKE and DAZE
	Action[2]:Set[NukeDaze]
	SpellRange[2,1]:Set[61]
 
    ;; Mental DOT and arcane resistance debuff (fast casting)
	Action[3]:Set[Despair]
	SpellRange[3,1]:Set[80]

    ;; Mental DOT 
	Action[4]:Set[MindDoT]
	SpellRange[4,1]:Set[70]

    ;; Fast casting NUKE
	Action[5]:Set[Nuke]
	SpellRange[5,1]:Set[60]

    ;; Slow recast, Encounter DOT
	Action[6]:Set[Shower]
	SpellRange[6,1]:Set[388]

    ;; Fast casting NUKE (2nd time)
	Action[7]:Set[Nuke]
	SpellRange[7,1]:Set[60]

    ;; Encounter DOT   (RENAME)
	Action[8]:Set[Ego]
	SpellRange[8,2]:Set[91]

    ;; Master Strike
    Action[11]:Set[Master_Strike]

    ;; Construct
	Action[12]:Set[Constructs]
	SpellRange[12,1]:Set[51]


    ;;;;;;;;;;;;;;;;; STUNS ;;;;;;;;;;;;;;;;;

    ;; Group Encounter fast casting Stun
	Action[13]:Set[AEStun]
	MobHealth[13,1]:Set[1]
	MobHealth[13,2]:Set[100]
	SpellRange[13,1]:Set[191]

    ;; Single Target Stun (longer duration)
	Action[14]:Set[Stun]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]	
	SpellRange[14,1]:Set[190]

    ;;;;;;;;;;;;;;;;; UTILITY ;;;;;;;;;;;;;;;;;

    ;; Short Duration Buff .. adds INT, Focus, Disruption, etc.
	Action[15]:Set[Focus]
	MobHealth[15,1]:Set[20]
	MobHealth[15,2]:Set[100]
	SpellRange[15,1]:Set[23]

    ;; Savante
	Action[16]:Set[Savante]
	MobHealth[16,1]:Set[20]
	MobHealth[16,2]:Set[100]
	SpellRange[16,1]:Set[389]

    ;; Mana Shroud
	;;; NOTE: This is handled in RefreshPower()

    ;; Power Drain -> Group
	Action[17]:Set[Gaze]
	MobHealth[17,1]:Set[1]
	MobHealth[17,2]:Set[40]
	SpellRange[17,1]:Set[90]

}

function PostCombat_Init()
{
	;PostAction[1]:Set[]
	;PostSpellRange[1,1]:Set[]

	PostAction[1]:Set[LoadDefaultEquipment]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

    ;echo "Buff_Routine(${PreSpellRange[${xAction},1]}:${SpellType[${PreSpellRange[${xAction},1]}]})"
	call CheckHeals

	if !${DPSMode}
		call RefreshPower

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 5
	}

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}	
			break

		case Clarity
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}		
			break
		case Rune
		    if ${Math.Calc[${Me.MaxConc}-${Me.UsedConc}]} < 1
		        break		
			if ${BuffRune}
			{
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    				call CastSpellRange ${PreSpellRange[${xAction},1]}				    
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Aspect
		    if ${Math.Calc[${Me.MaxConc}-${Me.UsedConc}]} < 1
		        break
			if ${BuffAspect}
			{
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    				call CastSpellRange ${PreSpellRange[${xAction},1]}		
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case MakePet
			if ${Makepet} && ${Math.Calc[${Me.MaxConc}-${Me.UsedConc}]} >= 3
			{
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    			{
    				call CastSpellRange ${PreSpellRange[${xAction},1]}		
    			    wait 1
    			    ;; Shrink pets...
        			if ${Me.Ability["Shrink Servant"].IsReady}
        			{
        				Me.Ability["Shrink Servant"]:Use
        				do
        				{
        				    waitframe
        				}
        				while ${Me.CastingSpell}
        				wait 1						
        			}
    			}
			}
			break
		case Melee_Buff
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}

			}
			while ${Counter:Inc}<=${Me.CountMaintained}


			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case Caster_Buff
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffCasterDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffCasterDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffCasterDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}

			}
			while ${Counter:Inc}<=${Me.CountMaintained}


			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffCasterDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffCasterDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffCasterDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break


		case AA_Time_Compression
			BuffTarget:Set[${UIElement[cbBuffTime_Compression@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${BuffTarget.Equal["No one"]}
			    break
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case AA_Illusory_Arm	
			if ${BuffTarget.Equal["No one"]}
			    break			
			BuffTarget:Set[${UIElement[cbBuffIllusory_Arm@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case AA_Empathic_Aura
		case AA_Empathic_Soothing
		    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    			{
    				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
    				wait 5
    			}
    		}
			break
		case SummonImpOfRoBuff
			if (${SummonImpOfRo})
			{
				if !${Me.Maintained["Summon: Imp of Ro"](exists)}
					call CastSpell "Summon: Imp of Ro"
			}
			break			
		default
			return BuffComplete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare spellsused int local
	spellsused:Set[0]

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
		EQ2Execute /stopfollow

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

    ;; TO DO (Revamp)
	if ${MezzMode}
		call Mezmerise_Targets

    if ${Me.Pet(exists)} && !${Me.Pet.InCombatMode}
    	call PetAttack

	call CheckHeals

	if ${ShardMode}
		call Shard

	call RefreshPower


	;; Chronosiphoning (Always cast this when it is ready!
	if ${Me.Ability[${SpellType[385]}](exists)}
	{
	    if (${Me.Ability[${SpellType[385]}].IsReady})
		    call CastSpellRange 385 0 0 0 ${KillTarget}
	}
	
	;; If we have the skill 'Nullifying Staff' and the mob is within range
	if ${Me.Ability[${SpellType[396]}](exists)}
	{
	    if (${Actor[id,${KillTarget}].Distance} <= 5)
	    {
    	    if (${Me.Ability[${SpellType[396]}].IsReady})
    	    {
    		    call CastSpellRange 396 0 0 0 ${KillTarget}
				if ${Me.AutoAttackOn} && !${AutoMelee}
					EQ2Execute /toggleautoattack	
    		}
    	}
	}
	
    ;; Melee Debuff -- only for Epic mobs for now
	if ${Actor[id,${KillTarget}].IsEpic}
	{
    	if ${Me.Ability[${SpellType[50]}](exists)}
    	{
    	    if (${Me.Ability[${SpellType[50]}].IsReady})
    		    call CastSpellRange 50 0 0 0 ${KillTarget}
    	}	
    }

    ;; If Target is Epic, be sure that the Daze Debuff is being used as often as possible.  (This is the slow casting Nuke.)
	if ${Actor[id,${KillTarget}].IsEpic}
	{
    	if ${Me.Ability[${SpellType[61]}](exists)}
    	{
    	    if (${Me.Ability[${SpellType[61]}].IsReady})
    		    call CastSpellRange 61 0 0 0 ${KillTarget}
    	}	
    }

    ;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
    if !${MainTank} && ${Me.Group} > 1
    {
    	if ${Me.Ability[${SpellType[72]}].IsReady}
    	    call CastSpellRange 72 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
    }
     
	switch ${Action[${xAction}]}
	{
	    ;; Straight Nukes
        case Silence
        case Nuke
        case NukeDaze      
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
			
        ;; Single Target DoTs
        case Despair
        case MindDoT
            ;echo "DEBUG::  ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) called"
            if ${Actor[id,${KillTarget}].IsSolo} && ${Actor[id,${KillTarget}].Health} < 5
            {
                ;echo "DEBUG:: Health of Target: ${Actor[id,${KillTarget}].Health}
                break
            }
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
			    ;echo "DEBUG:: ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) ready..."
			    if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
			    {
			        ;echo "DEBUG:: Casting ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]})"
			        call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			    }
			}
			;else
			   ;echo "DEBUG:: ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) isn't ready..."
			break
        
        ;; Group Encounter DoTs
        case Shower
        case Ego
            if ${Actor[id,${KillTarget}].IsSolo} && ${Actor[id,${KillTarget}].Health} < 30
                break   
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
			    if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
			        call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
        
		case Master_Strike
            if ${Actor[id,${KillTarget}].IsSolo} && ${Actor[id,${KillTarget}].Health} < 10
                break		
		    ;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
		    ;;;;;;;;;;
		    if (${InvalidMasteryTargets.Element[${KillTarget}](exists)})
		        break
		    ;;;;;;;;;;;				    
			if ${Me.Ability["Master's Strike"].IsReady}
			{
				Target ${KillTarget}
				Me.Ability["Master's Strike"]:Use
				do
				{
				    waitframe
				}
				while ${Me.CastingSpell}
				wait 1						
			}
			break        
        
        case Constructs
            if ${Actor[id,${KillTarget}].IsSolo} && ${Actor[id,${KillTarget}].Health} < 30
            {
                ;; if we are in DPS Mode, then skip past Stuns
                if ${DPSMode}
                {
                    gRtnCtr:Set[15]
                    return
                }
                break
            }
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			    call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

            ;; if we are in DPS Mode, then skip past Stuns
            if ${DPSMode}
            {
                gRtnCtr:Set[15]
                return			
            }
            break

        case AEStun
        case Stun
            if ${DPSMode}
                break
            if ${Actor[id,${KillTarget}].IsSolo} && ${Actor[id,${KillTarget}].Health} < 40 && ${Me.ToActor.Health} > 50
                break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break


        case Focus
        case Savante   
        case Gaze
            if ${DPSMode} && ${Actor[id,${KillTarget}].IsSolo}
                return CombatComplete
            if ${Actor[id,${KillTarget}].IsSolo} && ${Me.Group} > 1
                return CombatComplete
            elseif ${Actor[id,${KillTarget}].IsSolo} && ${Actor[id,${KillTarget}].Health} < 70
                return CombatComplete
            elseif ${Actor[id,${KillTarget}].IsHeroic} && ${Actor[id,${KillTarget}].Health} < 50
                return CombatComplete
            elseif ${Actor[id,${KillTarget}].IsEpic} && ${Actor[id,${KillTarget}].Health} < 15
                return CombatComplete                
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			    call CastSpellRange ${SpellRange[${xAction},1]}
			break
            
		default
			return CombatComplete
			break
	}
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	switch ${PostAction[${xAction}]}
	{

		case LoadDefaultEquipment
			ExecuteAtom LoadEquipmentSet "Default"
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{
    ;;;;
    ;; The logic here needs to be reviewed ..do we really want to do these things?
    ;;;;
    
    if (!${MainTank} && ${Me.Group} > 1)
    {
        if ${Me.Inventory[Behavioral Modificatinator Stereopticon](exists)}
        {
            if (${Me.Inventory[Behavioral Modificatinator Stereopticon].IsReady})
            {
                Me.Inventory[Behavioral Modificatinator Stereopticon]:Use
                return
            }
        }
    }

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

    ; Illusory Allies	
    if (!${Me.Grouped})
    {
        if ${Me.Ability["Illusory Allies"](exists)}
        {
            if ${Me.Ability["Illusory Allies"].IsReady}
    			call CastSpellRange 192 0 0 0 ${Actor[${aggroid}].ID}
    	}
    }

	;Phase
	if (!${Me.Grouped})
    	call CastSpellRange 361

	if ${Actor[${aggroid}].Distance} < 5
	{
		call CastSpellRange 357
	}

}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{
	if ${Me.Ability[${SpellType[386]}].IsReady}
	{
		call CastSpellRange 386 0 0 0 ${KillTarget}
	}

}

function MA_Dead()
{

}

function Cancel_Root()
{

}

function RefreshPower()
{
	declare tempvar int local
	declare MemberLowestPower int local
	;Spiritise Censer
	if !${Swapping} && ${Me.Inventory[Spirtise Censer](exists)}
	{
		OriginalItem:Set[${Me.Equipment[Secondary].Name}]
		ItemToBeEquipped:Set[Spirtise Censer]
		call Swap
		Me.Equipment[Spirtise Censer]:Use
	}

	;Conjuror Shard
	if ${Me.Power} < 40
	{
		call Shard
	}

	;Transference line out of Combat
	if ${Me.ToActor.Health}>30 && ${Me.ToActor.Power}<80 && !${Me.InCombat}
		call CastSpellRange 309

	;Transference Line in Combat
	if ${Me.ToActor.Health}>30 && ${Me.ToActor.Power}<50
		call CastSpellRange 309

    if ${Me.Group} > 1
    {
    	;Mana Flow the lowest group member
    	tempvar:Set[1]
    	MemberLowestPower:Set[1]
    	do
    	{
    		if ${Me.Group[${tempvar}].ToActor.Power}<60 && ${Me.Group[${tempvar}].ToActor.Distance}<30 && ${Me.Group[${tempvar}].ToActor(exists)}
    		{
    			if ${Me.Group[${tempvar}].ToActor.Power}<=${Me.Group[${MemberLowestPower}].ToActor.Power}
    			{
    				MemberLowestPower:Set[${tempvar}]
    			}
    		}
    	}
    	while ${tempvar:Inc}<${Me.GroupCount}
    
    	if ${Me.Grouped}  && ${Me.Group[${MemberLowestPower}].ToActor.Power}<60 && ${Me.Group[${MemberLowestPower}].ToActor.Distance}<30  && ${Me.ToActor.Health}>30 && ${Me.Group[${MemberLowestPower}].ToActor(exists)}
    		call CastSpellRange 360 0 0 0 ${Me.Group[${MemberLowestPower}].ToActor.ID}
	}

	;Mana Cloak the group if the Main Tank is low on power
	if ${Actor[${MainTankPC}].Power} < 20 && ${Actor[${MainTankPC}].Distance}<50  && ${Actor[${MainTankPC}].InCombatMode}
	{
		call CastSpellRange 354
        ;; Savant is now called in the main routine
	}
}

function CheckHeals()
{
	call UseCrystallizedSpirit 60

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	; Cure Arcane Me
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}
	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane}>=1 && ${Me.Group[${temphl}].ToActor(exists)}
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}


}
function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} || ${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}

			tempvar:Set[1]
			aggrogrp:Set[FALSE]

			;check if its agro on a group member or group member's pet
			if ${grpcnt}>1
			{
				do
				{

					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			;check if its agro on a raid member or raid member's pet
			if ${Me.InRaid}
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Actor[exactname,${Me.Raid[$tempvar}].Name}].ID} || (${CustomActor[${tcount}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].Pet.ID}
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=24
			}
			;check if its agro on me
			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
			{
				aggrogrp:Set[TRUE]
			}

			;if i have a mob charmed check if its agro on my charmed pet
			if ${Me.Maintained[${SpellType[351]}](exists)}
			{
				if ${CustomActor[${tcount}].Target.IsMyPet}
				{
					aggrogrp:Set[TRUE]
				}
			}

			if ${aggrogrp}
			{

				if ${Me.AutoAttackOn}
				{
					eq2execute /toggleautoattack
				}

				if ${Me.RangedAutoAttackOn}
				{
					eq2execute /togglerangedattack
				}

				;try to AE mezz first and check if its not single target mezzed
				if !${CustomActor[${tcount}].Effect[${SpellType[352]}](exists)}
				{
					call CastSpellRange 353 0 0 0 ${CustomActor[${tcount}].ID}
				}

				;if the actor is not AE Mezzed then single target Mezz
				if !${CustomActor[${tcount}].Effect[${SpellType}[353]](exists)}
				{
					call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 10
				}
				else
				{
					call CastSpellRange 92 0 0 0 ${CustomActor[${tcount}].ID} 0 10
				}
				aggrogrp:Set[FALSE]
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${KillTarget}](exists)} && ${Actor[${KillTarget}].Health}>1
	{
		Target ${KillTarget}
		wait 20 ${Me.ToActor.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
	}
}

