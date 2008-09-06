;*************************************************************
;Illusionist.iss
;version 20080323a
;by pygar
;
;20080730a (Amadeus)
; * So many changes over the past few months it is not even funny
; * Latest change:  Added the ability to use a "Runed Guard of the Sel'Nok" to the script.  You can indicate whether or not
;   to use it via the UI.
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
    declare ClassFileVersion int script 20080517
    ;;;;
    
	call EQ2BotLib_Init    
    
    UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Buffs]
    UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[Buffs]:Move[4]
    ui -load -parent "Buffs@EQ2Bot Tabs@EQ2 Bot" "EQ2Bot/UI/${Me.SubClass}_Buffs.xml"
    
	declare MezzMode bool script FALSE
	declare Makepet bool script FALSE
	declare BuffAspect bool script FALSE
	declare BuffRune bool script FALSE
	declare BuffPowerRegen bool script TRUE
	declare StartHO bool script TRUE
	declare DPSMode bool script TRUE
	declare UltraDPSMode bool script FALSE
	declare SummonImpOfRo bool script FALSE
	declare UseTouchOfEmpathy bool script FALSE
	declare UseDoppleganger bool script FALSE
	declare UseRunedGuardItem bool script FALSE
	declare BuffEmpathicAura bool script FALSE
	declare BuffEmpathicSoothing bool script FALSE
	declare UseIlluminate bool script FALSE
	

	BuffAspect:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAspect,FALSE]}]
	BuffRune:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffRune,FALSE]}]
	BuffPowerRegen:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPowerRegen,TRUE]}]
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	Makepet:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Makepet,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	BuffTime_Compression:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffTime_Compression,]}]
	BuffIllusory_Arm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffIllusory_Arm,]}]
	DPSMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[DPSMode,TRUE]}]
	UltraDPSMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UltraDPSMode,FALSE]}]
	SummonImpOfRo:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Summon Imp of Ro,FALSE]}]
	UseTouchOfEmpathy:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseTouchOfEmpathy,FALSE]}]
	UseDoppleganger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseDoppleganger,FALSE]}]
	UseRunedGuardItem:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseRunedGuardItem,FALSE]}]
	BuffEmpathicAura:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffEmpathicAura,FALSE]}]
	BuffEmpathicSoothing:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffEmpathicSoothing,FALSE]}]   
	UseIlluminate:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseIlluminate,FALSE]}]   
	    
	NoEQ2BotStance:Set[TRUE]
	
	Event[EQ2_FinishedZoning]:AttachAtom[Illusionist_FinishedZoning]  
}

function Class_Shutdown()
{
    Event[EQ2_FinishedZoning]:DetachAtom[Illusionist_FinishedZoning]  
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
    
    ;; Slow casting NUKE and DAZE
	Action[1]:Set[NukeDaze]
	SpellRange[1,1]:Set[61]        
    
    ;; Mental DOT 
	Action[2]:Set[MindDoT]
	SpellRange[2,1]:Set[70]	    
    
    ;; Encounter DOT   (RENAME)
	Action[3]:Set[Ego]
	SpellRange[3,1]:Set[91]
	
    ;; Slow recast, Encounter DOT
	Action[4]:Set[Shower]
	SpellRange[4,1]:Set[388]
	
    ;; Stifle over time, and NUKE
	Action[5]:Set[Silence]
	SpellRange[5,1]:Set[260]	

    ;; Master Strike
	MobHealth[6,1]:Set[20]
	MobHealth[6,2]:Set[100]    
    Action[6]:Set[Master_Strike]

    ;; Construct
	Action[7]:Set[Constructs]
	SpellRange[7,1]:Set[51]


    ;;;;;;;;;;;;;;;;; STUNS ;;;;;;;;;;;;;;;;;

    ;; Group Encounter fast casting Stun
	Action[8]:Set[AEStun]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[191]

    ;; Single Target Stun (longer duration)
	Action[9]:Set[Stun]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]	
	SpellRange[9,1]:Set[190]

    ;;;;;;;;;;;;;;;;; UTILITY ;;;;;;;;;;;;;;;;;

    ;; Savante
	Action[10]:Set[Savante]
	MobHealth[10,1]:Set[20]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[389]

    ;; Mana Shroud
	;;; NOTE: This is handled in RefreshPower()

    ;; Power Drain -> Group
	Action[11]:Set[Gaze]
	MobHealth[11,1]:Set[1]
	MobHealth[11,2]:Set[40]
	SpellRange[11,1]:Set[90]

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
    ;CurrentAction:Set[Buff Routine :: ${PreAction[${xAction}]} (${xAction})]
   
    call CheckHeals
    call RefreshPower
    call CheckSKFD

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 5
	}
	
    ;; Prismatic Proc
    ;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
    if !${MainTank} || ${AutoMelee}
    {
        if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
        {
            if ${Actor[${MainTankPC},exactname].InCombatMode}
            {
            	if ${Me.Ability[${SpellType[72]}].IsReady}
            	{
        			BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
        			if !${BuffTarget.Equal["No one"]}
        			{
        			    if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
            			{
            			    echo "DEBUG:: Casting ''Prismatic'"
            			    call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1 
            			    return
            			}
            			else
            			    echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
                    }      
                    else
                    {
                        echo "DEBUG:: Casting ''Prismatic'"
                        call CastSpellRange 72 0 0 0 ${Actor[${MainTankPC},exactname].ID} 0 0 0 1 
                        return
                    }
            	}
        	}
        }
    } 	

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}	
			break

		case Clarity
		    if ${BuffPowerRegen}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
	    			call CastSpellRange ${PreSpellRange[${xAction},1]}		
	    	}
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

			;; If we have mythical, just cast on self since it is a group buff
			if (${Me.Equipment[Mirage Star](exists)} && ${Me.Equipment[1].Tier.Equal[MYTHICAL]}) || (${Me.Inventory[Mirage Star](exists)} && ${Me.Inventory[Mirage Star].Tier.Equal[MYTHICAL]})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}

				break
			}

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)})
					{
					    if (${Me.Group[${BuffTarget.Token[1,:]}](exists)} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
            			    call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
            		}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
					if ${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)})
					{
					    if (${Me.Group[${BuffTarget.Token[1,:]}](exists)} || ${Me.Raid[${BuffTarget.Token[1,:]}](exists)} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
        					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
        			}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffCasterDPS@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break


		case AA_Time_Compression
			BuffTarget:Set[${UIElement[cbBuffTime_Compression@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${BuffTarget.Equal["No one"]}
			    break
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
			    if (${Me.Group[${BuffTarget.Token[1,:]}](exists)})
    				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
    		}
			break
		case AA_Illusory_Arm	
		    BuffTarget:Set[${UIElement[cbBuffIllusory_Arm@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
		    if ${BuffTarget.Equal["No one"]}
			    break			
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
			    if (${Me.Group[${BuffTarget.Token[1,:]}](exists)})
    				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
    		}
			break
		case AA_Empathic_Aura
		    if ${BuffEmpathicAura}
		    {
    		    if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    			{
    				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
    				wait 5
    			}
        	}
			break		
		case AA_Empathic_Soothing
		    if ${BuffEmpathicSoothing}
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
	}
}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, int TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained)
{
	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;
	declare BuffTarget string local
    
    ; Fast Nuke (beam) ...cast every time it is ready!
    if (${Me.Ability[${SpellType[60]}].IsReady})
	    call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1    	
    
    ;; Prismatic Proc
    ;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
    if !${MainTank} || ${AutoMelee}
    {
        if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
        {
            if ${Actor[${KillTarget}].Health} > 2
            {
            	if ${Me.Ability[${SpellType[72]}].IsReady}
            	{
        			BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
        			if !${BuffTarget.Equal["No one"]}
        			{
        			    ;echo "DEBUG: ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}"
            			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
            			    call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1 
            			else
            			    echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
                    }      
                    else
                        call CastSpellRange 72 0 0 0 ${Actor[${MainTankPC},exactname].ID} 0 0 0 1 
            	}
        	}
        }
    } 
    
    ; Fast casting DoT
    if (${Me.Ability[${SpellType[80]}].IsReady})
	    call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1    	
	    
	
	if ${AutoMelee} && ${DoCallCheckPosition}
	{
		if ${MainTank}
		    call CheckPosition 1 0
		else
		    call CheckPosition 1 1
		DoCallCheckPosition:Set[FALSE]
	}	    
     
    call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained}
    return ${Return}
}

function Combat_Routine(int xAction)
{
	declare BuffTarget string local    
	declare spellsused int local
	spellsused:Set[0]
	declare MainTankID uint local
	MainTankID:Set[${Actor[pc,exactname,${MainTankPC}].ID}]
	
	if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
	    return CombatComplete
	    
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;; Check for "Runed Guard of the Sel'Nok" ;;;;
	if (${UseRunedGuardItem})
	{
    	if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 10)
    	{
        	if ${Me.Equipment["Runed Guard of the Sel'Nok"](exists)}
        	{
        	    if ${Me.Equipment["Runed Guard of the Sel'Nok"].IsReady}
        	    {
        	        CurrentAction:Set[Using: Runed Guard of the Sel'Nok]
        	        Me.Equipment["Runed Guard of the Sel'Nok"]:Use
            	    wait 1
            	    do
            	    {
            	        waitframe
            	    }
            	    while ${Me.CastingSpell}
            	    wait 1
            	}	        
        	}
        	elseif ${Me.Inventory["Runed Guard of the Sel'Nok"](exists)}
        	{
        	    if ${Me.Inventory["Runed Guard of the Sel'Nok"].IsReady}
        	    {
        	        CurrentAction:Set[Using: Runed Guard of the Sel'Nok]
            	    variable string SecondarySlotItem
            	    variable uint TimeBeforeEquip
            	    SecondarySlotItem:Set[${Me.Equipment[Secondary]}]
            	    TimeBeforeEquip:Set[${Time.Timestamp}]
            	    
            	    Me.Inventory["Runed Guard of the Sel'Nok"]:Equip
            	    wait 3
            	    Me.Equipment["Runed Guard of the Sel'Nok"]:Use
            	    wait 1
            	    do
            	    {
            	        waitframe
            	    }
                	while (${Me.CastingSpell} || (${Math.Calc64[${Time.Timestamp}-${TimeBeforeEquip}]} <= 2))
            	    Me.Inventory[${SecondarySlotItem}]:Equip
            	}
        	}    
        }
    }
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
	    

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoHOs}
		objHeroicOp:DoHO

    if ${StartHO}
    {
    	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	    	call CastSpellRange 303
    }
    
    ;; TO DO (Revamp)
	if ${MezzMode}
		call Mezmerise_Targets

    if ${Me.Pet(exists)} && !${Me.Pet.InCombatMode}
    	call PetAttack

    if !${DPSMode} && !${UltraDPSMode}
    	call CheckHeals

	if ${ShardMode}
		call Shard

    if !${UltraDPSMode}
    	call RefreshPower
    elseif ${Me.ToActor.Power} < 20
        call RefreshPower
    	
    ;; Add back later...(TODO)
    ;call CheckSKFD
    
    
    if ${AutoMelee} && !${NoAutoMovement}
    {
        if ${Actor[${KillTarget}].Distance} > 3.5
        {
            switch ${Actor[${KillTarget}].ConColor}
            {
                case Green
                case Grey
                    echo "DEBUG:: Calling CheckPosition(1 0)"
                    call CheckPosition 1 0
                    break
                Default
                    echo "DEBUG:: Calling CheckPosition(1 1)"
                    call CheckPosition 1 1
                    break
            }
        }
    }    
    
	;; Illuminate
	if ${UseIlluminate}
	{
    	if ${Me.Ability[${SpellType[387]}](exists)}
    	{
    	    if (${Me.Ability[${SpellType[387]}].IsReady})
    	    {
    		    call CastSpellRange 387 0 0 0 ${KillTarget} 0 0 0 1
    		    spellsused:Inc
    		}
    	}
    }

	;; Chronosiphoning (Always cast this when it is ready!
	if ${Me.Ability[${SpellType[385]}](exists)}
	{
	    if (${Me.Ability[${SpellType[385]}].IsReady})
	    {
		    call CastSpellRange 385 0 0 0 ${KillTarget} 0 0 0 1
		    spellsused:Inc
		}
	}
	
    ; Fast Nuke (beam) ...cast every time it's ready!
    if (${Me.Ability[${SpellType[60]}].IsReady})
    {
	    call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1    	
	    spellsused:Inc
	}
	    
	;; Short Duration Buff .. adds INT, Focus, Disruption, etc. (cast any time it's ready)  (else cast a short casting spell to kick up rapidity)
    if (${Me.Ability[${SpellType[23]}].IsReady})
    {
	    call CastSpellRange 23 0 0 0 ${KillTarget} 0 0 0 1 	    
	    spellsused:Inc
	}
	   
    ; Mental DOT and arcane resistance debuff (fast casting - "Despair") ...cast every time it's ready! 
    ;;; The rest of this block is basically to insure that all DoTs are loaded and things are primed at the
    ;;; beginning of the fight.
    if (${Me.Ability[${SpellType[80]}].IsReady})
    {
	    call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1   
	    spellsused:Inc
	    
	    if ${MezzMode}
	        call Mezmerise_Targets
	     	 
	    if !${Me.Maintained[${SpellType[70]}](exists)}   
	    {
    	    if (${Me.Ability[${SpellType[70]}].IsReady})
    	    {
	            call _CastSpellRange 70 0 0 0 ${KillTarget} 0 0 0 1  
	            spellsused:Inc
	        }
	    }
        if (${Me.Ability[${SpellType[60]}].IsReady})
        {
	        call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1    	
	        spellsused:Inc
	    }
	        	    
	    if !${Me.Maintained[${SpellType[91]}](exists)}   
	    {
    	    if (${Me.Ability[${SpellType[91]}].IsReady})
    	    {
	            call _CastSpellRange 91 0 0 0 ${KillTarget} 0 0 0 1 
	            spellsused:Inc 
	        }
	    }	
	    if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
	        return CombatComplete	    
        if (${Me.Ability[${SpellType[60]}].IsReady})
        {
	        call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1   
	        spellsused:Inc
	    }
	    
	    if ${MezzMode}
	        call Mezmerise_Targets
	        
	    if !${Me.Maintained[${SpellType[388]}](exists)}   
	    {
    	   if (${Me.Ability[${SpellType[388]}].IsReady})
    	   {
	            call _CastSpellRange 388 0 0 0 ${KillTarget} 0 0 0 1  
	            spellsused:Inc
	       }
	    }	
        if (${Me.Ability[${SpellType[60]}].IsReady})
        {
	        call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1  
	        spellsused:Inc
	    }
	    if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
	        return CombatComplete	 		    	     
	}
	
	if ${MezzMode}
	    call Mezmerise_Targets
	
	    
    if (${UseDoppleganger} && !${MainTank} && ${Me.Group} > 1)
	{
		;echo "DEBUG: Checking Doppleganger..."
		if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 50)
		{
			if ${Me.Ability[Doppleganger].IsReady}
			{
				switch ${Target.ConColor}
				{
					case Red
					case Orange
					case Yellow
						if (${Actor[${KillTarget}].EncounterSize} > 2 || ${Actor[${KillTarget}].Difficulty} >= 2)
						{
                            echo "EQ2Bot-DEBUG: Casting 'Doppleganger' on ${MainTankPC}"
                            eq2execute /useabilityonplaye ${MainTankPC} "Doppleganger"
                            wait 1
                            do
                            {
                                waitframe
                            }
                            while ${Me.CastingSpell}
						}
						break
					default
						if (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed})
						{
                            echo "EQ2Bot-DEBUG: Casting 'Doppleganger' on ${MainTankPC}"
                            eq2execute /useabilityonplayer ${MainTankPC} "Doppleganger"
                            wait 1
                            do
                            {
                                waitframe
                            }
                            while ${Me.CastingSpell}
						}
						break
				}
			}
		}
	}

    ;; Check Group members to see if anyone needs 'Touch of Empathy'
    if ${UseTouchOfEmpathy} && ${Me.Group} > 1
    {
        if ${Me.Ability["Touch of Empathy"].IsReady}
        {
            variable string TargetsTarget = ${Actor[${KillTarget}].Target.Name}
            variable string TargetsTargetClass = ${Actor[PC,${TargetsTarget},exactname].Class}
            if (!${TargetsTarget.Equal[${MainTankPC}]} && ${Actor[pc,${TargetsTarget},exactname](exists)} && ${Me.Group[${TargetsTarget}](exists)})
            {
                switch ${TargetsTargetClass}
                {
                    case Paladin
                    case Shadowknight
                    case Brawler
                    case Bruiser
                    case Guardian
                    case Berzerker
                        break
                        
                    default
                        echo "EQ2Bot-DEBUG: Casting 'Touch of Empathy' on ${TargetsTarget}"
                        eq2execute /useabilityonplayer ${TargetsTarget} "Touch of Empathy"
                        wait 3
                        do
                        {
                            waitframe
                        }
                        while ${Me.CastingSpell}
                        break
                }
            }
        }
    }
    
	;; If we have the skill 'Nullifying Staff' and the mob is within range
	if ${Me.Ability[${SpellType[396]}](exists)}
	{
	    if (${Actor[${KillTarget}].Distance} < 5)
	    {
    	    if (${Me.Ability[${SpellType[396]}].IsReady})
    	    {
    		    call CastSpellRange 396 0 0 0 ${KillTarget} 0 0 0 1
    		    spellsused:Inc
				if ${Me.AutoAttackOn}
					EQ2Execute /toggleautoattack	
    		}
    	}
	}
	
    ;; Melee Debuff -- only for Epic mobs for now
    if ${Me.ToActor.Power} > 40
    {
    	if ${Actor[${KillTarget}].IsEpic}
    	{
        	if ${Me.Ability[${SpellType[50]}](exists)}
        	{
        	    if !${Me.Maintained[${SpellType[50]}](exists)}
        	    {
            	    if (${Me.Ability[${SpellType[50]}].IsReady})
            	    {
            		    call CastSpellRange 50 0 0 0 ${KillTarget} 0 0 0 1
            		    spellsused:Inc
            		}
        		}
        	}	
        }
    }

    ;; If Target is Epic, be sure that the Daze Debuff is being used as often as possible, but only once we have casted our initial spells.)  (This is the slow casting Nuke.)	
	if ${Actor[${KillTarget}].IsEpic}
	{
        if ${Me.Ability[${SpellType[61]}](exists)}
    	{
    	    if (${Me.Ability[${SpellType[61]}].IsReady})
    	    {
    		    call CastSpellRange 61 0 0 0 ${KillTarget} 0 0 0 1
    		    spellsused:Inc
    		}
    	}	
    }
    
    if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
        return CombatComplete		    

	if ${MezzMode}
	    call Mezmerise_Targets


    ;echo "DEBUG:: Entering Switch (${Action[${xAction}]})"
	switch ${Action[${xAction}]}
	{
	    ;; Straight Nukes
        case Silence
        	;; This spell is just too slow to cast and typically does about 40 dps over an entire fight ..it is just not worth it.
        	;if !${DPSMode} && !${UltraDPSMode}
        	;{
                if (${Me.Ability[${SpellType[260]}].IsReady})
                {
    	            call _CastSpellRange 260 0 0 0 ${KillTarget} 0 0 0 1    
    	            spellsused:Inc
    	        }
	        ;}
    	    if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
    	        return CombatComplete		            		              	            	            
			break        
        
        case NukeDaze    
            if (${Me.Ability[${SpellType[61]}].IsReady})
            {
	            call _CastSpellRange 61 0 0 0 ${KillTarget} 0 0 0 1    
	            spellsused:Inc
	        }
    	    if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
    	        return CombatComplete		            		              	            	            
			break
			
        ;; Single Target DoTs
        case MindDoT   
            ;echo "DEBUG::  ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) called"
            if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
            {
                ;echo "DEBUG:: Health of Target: ${Actor[${KillTarget}].Health}
                break
            }
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
			    ;;; For now, let's try casting this every time it's ready. More testing needed to see if this is 
			    ;;; detrimental to dps and/or power usage
			   
			    ;if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
			    ;{
			        ;echo "DEBUG:: Casting ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]})"
			        call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
			        spellsused:Inc
                    if (${Me.Ability[${SpellType[80]}].IsReady})
			        {
	                    call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1  
	                    spellsused:Inc
	                }
            	    if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
            	        return CombatComplete			                    
			    ;}
			}
			;else
			;   echo "DEBUG:: ${SpellType[${SpellRange[${xAction},1]}]} (${SpellRange[${xAction},1]}) isn't ready..."
			break
			             
        ;; Group Encounter DoTs
        case Shower
        case Ego
            if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
                break   
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
			    ;if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
			        call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 1
			        spellsused:Inc
			}
			break
        
		case Master_Strike
            if (${Me.Ability[${SpellType[60]}].IsReady})
            {
        	    call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1    		
        	    spellsused:Inc
        	}
            if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 5
                break		
		    ;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
		    ;;;;;;;;;;
		    if (${InvalidMasteryTargets.Element[${KillTarget}](exists)})
		        break
		    ;;;;;;;;;;;		
		    
		    call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{		    
    			if ${Me.Ability["Master's Strike"].IsReady}
    			{
    				Target ${KillTarget}
    				Me.Ability["Master's Strike"]:Use
    				do
    				{
    				    waitframe
    				}
    				while ${Me.CastingSpell}
    				spellsused:Inc
    				wait 1						
    			}
    		}
			break        
        
        case Constructs
            if ${UltraDPSMode}
            {
                ;; Always set to one less than the index of the next ability you want to have run (it is incremented on the loop)
                gRtnCtr:Set[11]
                break
            }        
            if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 30
                break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
			    call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			    spellsused:Inc
			}
            break

        case AEStun
        case Stun
            if ${UltraDPSMode}
            {
                ;; Always set to one less than the index of the next ability you want to have run (it is incremented on the loop)
                gRtnCtr:Set[11]
                break
            }    
            if ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 40 && ${Me.ToActor.Health} > 50
                break
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					spellsused:Inc
				}
			}
			break
			        
        case Savante 
            if ${Me.ToActor.Power} > 50
                break 
            if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].IsNamed}
            {
    			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
    			{
	    		    call _CastSpellRange ${SpellRange[${xAction},1]}
	    		    spellsused:Inc
	    		}
	    	}
			break
			
        case Gaze
            if ${Me.ToActor.Power} > 50
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }  
            if ${UltraDPSMode} && ${Actor[${KillTarget}].IsSolo}
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }  
            if ${DPSMode} && ${Actor[${KillTarget}].IsSolo}
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }  
            if ${Actor[${KillTarget}].IsSolo} && ${Me.Group} > 1
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }  
            elseif ${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} < 70
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }  
            elseif ${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].Health} < 50
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }  
            elseif ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health} < 15
            {
            	if ${spellsused} < 1 && !${MezzMode}
            	    call CastSomething                
                return CombatComplete    
            }              
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
			    call _CastSpellRange ${SpellRange[${xAction},1]}
			    spellsused:Inc
			}
			break
            
		default
            if (${Me.Ability[${SpellType[60]}].IsReady})
            {
        	    call _CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1    		
        	    spellsused:Inc
        	}
        	if (${spellsused} < 1) && !${MezzMode}
        	    call CastSomething
			return CombatComplete
	}
	
	if !${MezzMode}
	{
    	if (${spellsused} < 1) 
    	    call CastSomething	
	}
	;echo "DEBUG:: Exiting Switch (${Action[${xAction}]}) (spellsused: ${spellsused})"
}

function CastSomething()
{
    ;; If this function is called, it is because we went through teh combat routine without casting any spells.  
    ;; This function is intended to cast SOMETHING in order to keep "Perputuality" going.
    
    ;echo "DEBUG:: ---"
    ;echo "DEBUG:: CastSomething() called."
 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Things we should be checking EVERY time
    if (${Me.Ability[${SpellType[60]}].IsReady})
    {
        echo "DEBUG:: Casting 'Fast Nuke'"
	    call CastSpellRange 60 0 0 0 ${KillTarget} 0 0 0 1    	
	    return
	}
    ;; Prismatic Proc
    ;; Melee Short-term buff (3 procs dmg -- ie, Prismatic Chaos)
    if !${MainTank} || ${AutoMelee}
    {
        if (${Me.Group} > 1 || ${Me.Raid} > 1 || ${AutoMelee})
        {
            if ${Actor[${KillTarget}].Health} > 2
            {
            	if ${Me.Ability[${SpellType[72]}].IsReady}
            	{
        			BuffTarget:Set[${UIElement[cbBuffPrismOn@Buffs@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
        			if !${BuffTarget.Equal["No one"]}
        			{
        			    if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
            			{
            			    echo "DEBUG:: Casting ''Prismatic'"
            			    call CastSpellRange 72 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID} 0 0 0 1 
            			    return
            			}
            			else
            			    echo "ERROR: Prismatic proc target, ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname]}, does not exist!"
                    }      
                    else
                    {
                        echo "DEBUG:: Casting ''Prismatic'"
                        call CastSpellRange 72 0 0 0 ${Actor[${MainTankPC},exactname].ID} 0 0 0 1 
                        return
                    }
            	}
        	}
        }
    } 
    if (${Me.Ability[${SpellType[80]}].IsReady})
    {
        echo "DEBUG:: Casting 'Fast Casting DoT'"
	    call CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1    	
	    return
	}
    if (${Me.Ability[${SpellType[70]}].IsReady})
    {
        echo "DEBUG:: Casting 'Mind DoT'"
	    call CastSpellRange 70 0 0 0 ${KillTarget} 0 0 0 1    	
	    return
	}	
	;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	


    ;  contruct
    if (${Me.Ability[${SpellType[51]}].IsReady})
    {
        echo "DEBUG:: Casting 'Construct'"
	    call _CastSpellRange 51 0 0 0 ${KillTarget} 0 0 0 1            
	    return
	}
	;; AA Melee Ability (very fast casting -- low dmg
	if ${Me.Ability[Spellblade's Counter](exists)} && ${AutoMelee}
	{
	    if (${Me.Ability[Spellblade's Counter].IsReady})
	    {
	        echo "DEBUG:: Casting 'Melee AA Ability'"
	        Actor[${KillTarget}]:DoTarget
	        call CastSpell "Spellblade's Counter" 395 0
		    return
		}
	}
	; fast-casting encounter stun
    if (${Me.Ability[${SpellType[191]}].IsReady})
    {
        echo "DEBUG:: Casting 'Encounter Stun'"
	    call CastSpellRange 191 0 0 0 ${KillTarget} 0 0 0 1        
	    return
	} 
	; melee debuff
    if (${Me.Ability[${SpellType[50]}].IsReady})
    {
        echo "DEBUG:: Casting 'Melee Debuff'"
	    call CastSpellRange 50 0 0 0 ${KillTarget} 0 0 0 1            
	    return
	}
	; extract mana
    if (${Me.Ability[${SpellType[309]}].IsReady})
    {
        echo "DEBUG:: Casting 'Mana Recovery'"
	    call CastSpellRange 309 0 0 0 ${KillTarget} 0 0 0 1            
	    return
	}	
	; root
    if (${Me.Ability[${SpellType[230]}].IsReady})
    {
        echo "DEBUG:: Casting 'Root'"
	    call CastSpellRange 230 0 0 0 ${KillTarget} 0 0 0 1            
	    return
	}
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	switch ${PostAction[${xAction}]}
	{
		case LoadDefaultEquipment
		    if !${Me.ToActor.InCombatMode}
    			ExecuteAtom LoadEquipmentSet "Default"
			break
		default
			return PostCombatRoutineComplete
	}
}

function Have_Aggro()
{
    ;;;;
    ;; The logic here needs to be reviewed ..do we really want to do these things?
    ;;;;
    
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
	if (!${Me.Grouped} && ${Actor[${aggroid}].Distance} < 5
    	call CastSpellRange 357
}

function Lost_Aggro()
{
}

function MA_Lost_Aggro()
{
	if ${Me.Ability[${SpellType[386]}].IsReady}
		call CastSpellRange 386 0 0 0 ${KillTarget}
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
	if ${Me.Level} < 75
	{
    	if !${Swapping} && ${Me.Inventory[Spirtise Censer](exists)}
    	{
    		OriginalItem:Set[${Me.Equipment[Secondary].Name}]
    		ItemToBeEquipped:Set[Spirtise Censer]
    		call Swap
    		Me.Equipment[Spirtise Censer]:Use
    	}
    }

	;Transference line out of Combat
	if ${Me.ToActor.Health}>30 && ${Me.ToActor.Power}<80 && !${Me.InCombat}
		call CastSpellRange 309
	elseif ${Me.ToActor.Health}>30 && ${Me.ToActor.Power}<50
		call CastSpellRange 309

    if ${Me.Group} > 1
    {
    	if ${Me.ToActor.Power} < 40
    		call Shard        
        
        if ${Me.ToActor.Power} > 45
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
	}

	;Mana Cloak the group if the Main Tank is low on power
	if ${Me.InCombat} && ${Me.Group[${MainTankPC}](exists)}
	{
    	if ${Actor[pc,${MainTankPC},exactname].Power} < 20 && ${Actor[pc,${MainTankPC},exactname].Distance}<50  && ${Actor[pc,${MainTankPC},exactname].InCombatMode}
    	{
    		call CastSpellRange 354
            ;; Savant is now called in the main routine
    	}
    }
}

function CheckHeals()
{
	call UseCrystallizedSpirit 60

	declare temphl int local 1

	; Cure Arcane Me
	if ${Me.Arcane}>=1
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}

		if ${Actor[${KillTarget}](exists)}
			Target ${KillTarget}
	}
	
	if ${grpcnt} > 1
	{
    	do
    	{
    		; Cure Arcane
    		if ${Me.Group[${temphl}].ToActor(exists)}
    		{
        		if ${Me.Group[${temphl}].Arcane} >= 1
        		{
        			call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}
        
        			if ${Actor[${KillTarget}](exists)}
        				Target ${KillTarget}
        		}
        	}
    	}
    	while ${temphl:Inc} <= ${Me.GroupCount}
    }
}
function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE


	EQ2:CreateCustomActorArray[byDist,15,npc]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if (${CustomActor[${tcount}].ID} == ${KillTarget})
			    continue
			if ${Actor[exactname,${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} || ${Actor[exactname,${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]

			;check if its agro on a group member or group member's pet
			if ${Me.GroupCount} > 1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc} <= ${Me.GroupCount}
			}

			;check if its agro on a raid member or raid member's pet
			tempvar:Set[1]
			if ${Me.InRaid}
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Raid[$tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Raid[${tempvar}].ToActor.Pet.ID}
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc} <= ${Me.Raid}
			}
			;check if its agro on me
			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
				aggrogrp:Set[TRUE]

			;if i have a mob charmed check if its agro on my charmed pet
			if ${Me.Maintained[${SpellType[351]}](exists)}
			{
				if ${CustomActor[${tcount}].Target.IsMyPet}
					aggrogrp:Set[TRUE]
			}

			if ${aggrogrp}
			{
				if ${Me.AutoAttackOn}
					eq2execute /toggleautoattack

				if ${Me.RangedAutoAttackOn}
					eq2execute /togglerangedattack

				;try to AE mezz first and check if its not single target mezzed
				if !${CustomActor[${tcount}].Effect[${SpellType[352]}](exists)}
					call CastSpellRange 353 0 0 0 ${CustomActor[${tcount}].ID}

				;if the actor is not AE Mezzed then single target Mezz
				if !${CustomActor[${tcount}].Effect[${SpellType}[353]](exists)}
					call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 10
				else
					call CastSpellRange 92 0 0 0 ${CustomActor[${tcount}].ID} 0 10
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
		KillTarget:Set[]
	}
}

function CheckSKFD()
{
    if !${Me.ToActor.IsFD}
        return
         
    if !${Actor[exactname,${MainTankPC}](exists)}
        return
    
    if ${Actor[exactname,${MainTankPC}].IsDead}
        return
        
    if ${Me.ToActor.Health} < 20
        return
            
    call RemoveSKFD "Illusionist::CheckSKFD"
    return
}

atom(script) Illusionist_FinishedZoning(string TimeInSeconds)
{
   
}