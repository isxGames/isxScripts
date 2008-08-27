;*************************************************************
;Illusionist.iss
;version 20080323a
;by pygar
;
;20080723
; * Mythical Support
; * Tandem on Raid Friend
; * Raid/Group DPS Tuning
;	* SOLO AT YOUR OWN RISK
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

	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Buffs]
	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[Buffs]:Move[4]
	ui -load -parent "Buffs@EQ2Bot Tabs@EQ2 Bot" "EQ2Bot/UI/${Me.SubClass}_Buffs.xml"

	call EQ2BotLib_Init

	declare MezzMode bool script FALSE
	declare MeleeMode bool script FALSE
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

	BuffAspect:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAspect,FALSE]}]
	BuffRune:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffRune,FALSE]}]
	BuffPowerRegen:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPowerRegen,TRUE]}]
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	MeleeMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MeleeMode,FALSE]}]
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
	CurrentAction:Set[Buff Routine :: ${PreAction[${xAction}]} (${xAction})]

	call CheckHeals
	call RefreshPower
	call CheckSKFD

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
			if (${Me.Equipment[Mirage Star](exists)} && ${Me.Equipment[1].Tier.Equal[MYTHICAL]})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
				break
			}
			elseif (${Me.Inventory[Mirage Star](exists)} && ${Me.Inventory[Mirage Star].Tier.Equal[MYTHICAL]})
			{
    	    variable string PrimarySlotItem
    	    variable uint TimeBeforeEquip
    	    PrimarySlotItem:Set[${Me.Equipment[1]}]
    	    TimeBeforeEquip:Set[${Time.Timestamp}]

    	    Me.Inventory["Mirage Star"]:Equip
    	    wait 3
    	    Me.Equipment["Mirage Star"]:Use
    	    wait 1
    	    do
    	    {
    	        waitframe
    	    }
        	while (${Me.CastingSpell} || (${Math.Calc64[${Time.Timestamp}-${TimeBeforeEquip}]} <= 2))
    	    Me.Inventory[${PrimarySlotItem}]:Equip
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

function Combat_Routine(int xAction)
{
	declare BuffTarget string local
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[1]

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

	if ${MezzMode}
	{
		CurrentAction:Set[Combat: Checking Mezzes]
		call Mezmerise_Targets
		spellthreshold:Set[1]
	}

	if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
		return CombatComplete

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

	; Doppleganger
	if (${UseDoppleganger} && !${MainTank} && ${Me.Group} > 1) && ${Actor[${MainTankPC}].Health}<60
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
							spellsused:Inc
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
							spellsused:Inc
						}
						break
				}
			}
		}
	}

	if ${MeleeMode}
	{
		if !${Me.AutoAttackOn}
			eq2execute /toggleautoattack

		call CheckPosition 1 ${Actor[${KillTarget}].IsEpic}

	}

	;; Chronosiphoning (Always cast this when it is ready!
	if (${Me.Ability[${SpellType[385]}].IsReady})
		call CastSpellIlly 385 0 0 0 ${KillTarget} 0 0 0 1

	;Daunted
	if ${spellsused}<=${spellthreshold} && ${Actor[${KillTarget}].IsEpic} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)}
	{
		call CastSpellIlly 50 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}


	;;; AoE Checks
	if ${Mob.Count}>1 && ${Actor[${KillTarget}].EncounterSize}>1
	{
		if ${Me.Ability[${SpellType[388]}].IsReady}
		{
			call CastSpellIlly 388 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[90]}].IsReady}
		{
			call CastSpellIlly 91 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[91]}].IsReady}
		{
			call CastSpellIlly 90 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	; Fast Nuke (beam) ...cast every time it's ready!
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady}
	{
		call CastSpellIlly 60 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	; Pessimism
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[80]}].IsReady}
	{
		call CastSpellIlly 80 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	; BrainClot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)}
	{
		call CastSpellIlly 70 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	; Shower even if single target
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellIlly 388 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	; Illuminate
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[387]}].IsReady}
	{
		call CastSpellIlly 387 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Lesion
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[61]}].IsReady}
	{
		call CastSpellIlly 61 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	;;;; Master Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[Master's Strike].IsReady}
	{
		;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
		;;;;;;;;;;
		if (!${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)})
		{
			Target ${KillTarget}
			Me.Ability[Master's Strike]:Use
			spellsused:Inc
		}
	}
	;Spellblade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[398]}](exists)} && ${Me.Ability[${SpellType[398]}].IsReady} && ${Actor[${KillTarget}].Distance} <= 7
	{
		call CastSpellIlly 398 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	;Counterblade
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[399]}](exists)} && ${Me.Ability[${SpellType[399]}].IsReady} && ${Actor[${KillTarget}].Distance} <= 7
	{
		call CastSpellIlly 399 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	;; If we have the skill 'Nullifying Staff' and the mob is within range
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[396]}](exists)} && ${Me.Ability[${SpellType[396]}].IsReady} && ${Actor[${KillTarget}].Distance} <= 7
	{
		call CastSpellIlly 396 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	;WithDrawl
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[190]}].IsReady} && !${Me.Maintained[${SpellType[190]}](exists)}
	{
		call CastSpellIlly 190 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	; Brilliance
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[23]}].IsReady} && !${Me.Maintained[${SpellType[23]}](exists)}
	{
		call CastSpellIlly 23 0 0 0 ${KillTarget} 0 0 0 1
		spellsused:Inc
	}
	; Shocker
	if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
	{
		Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
	}
	;Contruct
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[51]}].IsReady}
	{
		call CastSpellIlly 51 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Savante
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[389]}].IsReady}
	{
		call CastSpellIlly 389 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;; Check Group members to see if anyone needs 'Touch of Empathy'
	if ${spellsused}<=${spellthreshold} && ${UseTouchOfEmpathy} && ${Me.Group} > 1
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
						spellsused:Inc
						break
				}
			}
		}
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	if ${DoHOs}
		objHeroicOp:DoHO

	return CombatComplete

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
		call CastSpellRange 357

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
		{
			Target ${KillTarget}
		}
	}

	if ${grpcnt} > 1
	{
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
			while ${temphl:Inc}<=${Me.GroupCount}
		}
}
function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE


	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if ${Actor[exactname,${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} || ${Actor[exactname,${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}

			tempvar:Set[1]
			aggrogrp:Set[FALSE]

			;check if its agro on a group member or group member's pet
			if ${Me.GroupCount}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=${Me.GroupCount}
			}

			tempvar:Set[1]
			;check if its agro on a raid member or raid member's pet
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
				while ${tempvar:Inc}<=${Me.Raid}
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

function CastSpellIlly(int start, int finish, int xvar1, int xvar2, int TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained)
{
	; Adornment Proc
	if !${Me.Maintained[${SpellType[72]}](exists)} && ${Actor[PC,ExactName,${MainTankPC}].Distance}<=20
	{
		call CastSpellRange 72 0 0 0 ${Actor[PC,ExactName,${MainTankPC}].ID}
	}

	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained}
}
