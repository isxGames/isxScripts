;*************************************************************
;Fury.iss 20080417a
;version
;
;20080417a
; * Tweaked cure and MT heal code to be a bit more 'raid' friendly.  The fury should recover from Spike damage to MT better.
;
;20080416a
; * Added a UI option (and code) for "Summon Imp of Ro" for those that follow Solosek Ro and want to maintain that buff.
;
;20080410a
; * Fixed "Buff Spirit of the Bat" to work on the fury him/herself if so set
;
;20080405a
; * Modified heal routine to check for Me.Group[0] (which should be the Fury him/herself)
; * Optimized the heal routine a bit
;
;20080323a
; * Fury will no longer cast any offensive spells if his/her health is under 51%
; * Fury will now cast "Favor of the Phoenix" when "Start EQ2Bot" is first pressed and after
;   full group wipes.
; * Fury will now CheckHeals() before initiating a HO each round
; * Fury will now no longer cast an offensive spell on an NPC that is currently mezzed (using the CheckForMez() function)
; * Added an option to the UI to choose whether or not to cast "Melee Proc Spells" (such as Fae Fire)
;
;20070725a
; Fixed running into combat range un-necesarily
;	Added a toggle for Combat Range AAs to enable or disable thier use.
;
;20070504a
; Tweaked Heal Code
; Updated Group Cures to check target health and group health before casting cures
;	Misc small fixes
;
;20070404a
;	Updated for latest eq2bot
;
;20070226a
; Full support for KoS and EoF AA lines
; Toggle of incombat rez
; Toggle of initiating HO
; Added Missing Spells (Carnal Mask, Maddening Swarm, Barbarous Intimidation)
; Fixed bug in Storms Usage
; Fixed a bug in UI file
;
;20070201a
; Intelligent Casting of Int Buffs
; Crystalized Shard usage added to checkheals
; Fixed Curing of uncurables
; Added toggle for buffing Thorns on MA (raid stacking contention with other furies/wardens)
; Optomized Storms/Ring of fire when selected
; Added AA Lines
; Optomized DPS
;
;20061130a
; Tweaked Rez, fixed some spell list errors.  Hacked buff canceling
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{

	declare OffenseMode bool script
	declare DebuffMode bool script
	declare AoEMode bool script
	declare PBAoEMode bool script
	declare CureMode bool script
	declare StormsMode bool script
	declare KeepReactiveUp bool script
	declare BuffEel bool script 1
	declare MeleeMode bool script 1
	declare BuffThorns bool script 1
	declare VortexMode bool script 1
	declare CombatRez bool script 1
	declare UseMeleeProcSpells bool script 1
	declare StartHO bool script 1
	declare KeepMTHOTUp bool script 0
	declare KeepGroupHOTUp bool script 0
	declare RaidHealMode bool script 1
	declare ShiftForm int script 1
	declare SummonImpOfRo bool script 0

	declare BuffBatGroupMember string script
	declare BuffSavageryGroupMember string script
	declare BuffSpirit bool script FALSE
	declare BuffHunt bool script FALSE
	declare BuffMask bool script FALSE

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	StormsMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Call of Storms,FALSE]}]
	MeleeMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Melee,FALSE]}]
	BuffThorns:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Thorns,FALSE]}]
	VortexMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Vortex,FALSE]}]
	KeepReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepReactiveUp,FALSE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	UseMeleeProcSpells:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Melee Proc Spells,FALSE]}]
	KeepMTHOTUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepMTHOTUp,FALSE]}]
	KeepGroupHOTUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepGroupHOTUp,FALSE]}]
	RaidHealMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Raid Heals,TRUE]}]

	BuffBatGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBatGroupMember,]}]
	BuffSavageryGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSavageryGroupMember,]}]
	BuffSpirit:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSpirit,TRUE]}]
	BuffHunt:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHunt,TRUE]}]
	BuffMask:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffMask,TRUE]}]
	BuffEel:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffEel,FALSE]}]
	ShiftForm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[ShiftForm,]}]
	SummonImpOfRo:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Summon Imp of Ro,]}]

	NoEQ2BotStance:Set[TRUE]

}

function Buff_Init()
{

	PreAction[1]:Set[BuffThorns]
	PreSpellRange[1,1]:Set[40]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[BuffEel]
	PreSpellRange[3,1]:Set[280]

	PreAction[4]:Set[BuffVim]
	PreSpellRange[4,1]:Set[36]

	PreAction[5]:Set[BuffSpirit]
	PreSpellRange[5,1]:Set[21]

	PreAction[6]:Set[BuffHunt]
	PreSpellRange[6,1]:Set[20]

	PreAction[7]:Set[BuffMask]
	PreSpellRange[7,1]:Set[23]

	PreAction[8]:Set[SOW]
	PreSpellRange[8,1]:Set[31]

	PreAction[9]:Set[BuffBat]
	PreSpellRange[9,1]:Set[35]

	PreAction[10]:Set[BuffSavagery]
	PreSpellRange[10,1]:Set[38]

	PreAction[11]:Set[AA_Rebirth]
	PreSpellRange[11,1]:Set[390]

	PreAction[12]:Set[AA_Infusion]
	PreSpellRange[12,1]:Set[391]

	PreAction[13]:Set[AA_Shapeshift]
	PreSpellRange[13,1]:Set[396]
	PreSpellRange[13,2]:Set[397]
	PreSpellRange[13,3]:Set[398]

	PreAction[14]:Set[SummonImpOfRoBuff]
}

function Combat_Init()
{

	Action[1]:Set[PBAoE]
	MobHealth[1,1]:Set[20]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[40]
	Power[1,2]:Set[100]
	Health[1,1]:Set[51]
	Health[1,2]:Set[100]
	SpellRange[1,1]:Set[95]
	SpellRange[1,2]:Set[97]

	Action[2]:Set[AoE]
	MobHealth[2,1]:Set[5]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[30]
	Power[2,2]:Set[100]
	Health[2,1]:Set[51]
	Health[2,2]:Set[100]
	SpellRange[2,1]:Set[90]

	Action[3]:Set[Nuke]
	MobHealth[3,1]:Set[1]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[30]
	Power[3,2]:Set[100]
	Health[3,1]:Set[51]
	Health[3,2]:Set[100]
	SpellRange[3,1]:Set[60]

	Action[4]:Set[Storms]
	MobHealth[4,1]:Set[20]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[40]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[96]

	Action[5]:Set[Mastery]

	Action[6]:Set[AA_Nature_Blade]
	MobHealth[6,1]:Set[10]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[40]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[381]

	Action[7]:Set[AA_Primordial_Strike]
	MobHealth[7,1]:Set[10]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[40]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[382]

	Action[8]:Set[AA_Thunderspike]
	MobHealth[8,1]:Set[10]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[40]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[383]

	Action[9]:Set[DoT]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	Health[9,1]:Set[51]
	Health[9,2]:Set[100]
	SpellRange[9,1]:Set[70]

	Action[10]:Set[Proc]
	MobHealth[10,1]:Set[30]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[40]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[157]

	Action[11]:Set[Feast]
	MobHealth[11,1]:Set[5]
	MobHealth[11,2]:Set[50]
	Power[11,1]:Set[30]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[312]

	Action[12]:Set[Debuff]
	MobHealth[12,1]:Set[20]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[30]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[50]
	SpellRange[12,2]:Set[51]
	SpellRange[12,3]:Set[52]

	Action[13]:Set[Snare]
	MobHealth[13,1]:Set[20]
	MobHealth[13,2]:Set[100]
	Power[13,1]:Set[30]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[235]

	Action[14]:Set[DoT2]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[30]
	Power[14,2]:Set[100]
	Health[14,1]:Set[51]
	Health[14,2]:Set[100]
	SpellRange[14,1]:Set[51]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostAction[2]:Set[CheckForCures]
	PostAction[3]:Set[AutoFollowTank]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	variable int temp

    ExecuteAtom CheckStuck

	if ${GroupWiped}
	{
	    call HandleGroupWiped
	    GroupWiped:Set[FALSE]
	}

	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
	    if (${Me.GroupCount} > 1)
	        call CastSpell "Favor of the Phoenix"
	    InitialBuffsDone:Set[TRUE]
	}

	if ${ShardMode}
		call Shard

	call CheckHeals

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 2
	}

    if (${KeepReactiveUp})
    {
    	if (${Me.ToActor.Power} > 85)
    	{
    		if !${Me.Maintained[${SpellType[11]}](exists)}
    			call CastSpellRange 11

    		call CastSpellRange 15
    		call CastSpellRange 7 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
    	}
    }

	switch ${PreAction[${xAction}]}
	{
		case BuffThorns
			if ${MainTank} || (${BuffThorns} && ${Actor[exactname,${MainTankPC}](exists)})
			{
			    if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Self_Buff
		case AA_Rebirth
		case AA_Infusion
            if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
		    {
		        if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    			    call CastSpellRange ${PreSpellRange[${xAction},1]}
    		}
    		break
		case AA_Shapeshift
		    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
		    {
		        if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    			    call CastSpellRange ${PreSpellRange[${xAction},${ShiftForm}]}
    		}
    		break
		case BuffEel
			if ${BuffEel}
			{
			    if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffVim
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
					if ${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if ${Me.Group[${Actor[exactname,${BuffTarget.Token[1,:]}].Name}](exists)} || ${Actor[exactname,${BuffTarget.Token[1,:]}].ID}==${Me.ID}
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case BuffHunt
			if ${BuffHunt}
			{
			    if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffSpirit
			if ${BuffSpirit}
			{
			    if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffMask
			if ${BuffMask}
			{
			    if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
        	break
		case SOW
			;Me.ToActor:InitializeEffects
			;if ${Me.ToActor.NumEffects}<15  && !${Me.Effect[Spirit of the Wolf](exists)}
			;{
			;	call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			;	wait 40
			;	;buff the group
			;	tempvar:Set[1]
			;	do
			;	{
			;		if ${Me.Group[${tempvar}].ToActor.Distance}<25
			;		{
			;			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
			;			wait 40
			;		}
			;	}
			;	while ${tempvar:Inc}<${Me.GroupCount}
			;}
			break
		case BuffBat
			BuffTarget:Set[${UIElement[cbBuffBatGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			    break

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

            if ${BuffTarget.Token[2,:].Equal[Me]}
                call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
            elseif ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Group[${Actor[exactname,${BuffTarget.Token[1,:]}].Name}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case BuffSavagery
			BuffTarget:Set[${UIElement[cbBuffSavageryGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			    break

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Group[${Actor[exactname,${BuffTarget.Token[1,:]}].Name}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case SummonImpOfRoBuff
		    if (${SummonImpOfRo})
		    {
		        if !${Me.Maintained["Summon: Imp of Ro"](exists)}
    		        call CastSpell "Summon: Imp of Ro"
    		}
		    break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare DebuffCnt int  0

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	call CheckHeals
	call RefreshPower

	if (${StartHO})
	{
   	    if (!${EQ2.HOWindowActive} && ${Me.InCombat})
   	    {
  		    call CastSpellRange 304
   	    }
	}

	if ${ShardMode}
	{
		call Shard
	}

	;if named epic, maintain debuffs
	if (${DebuffMode})
	{
    if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].IsNamed} && ${Me.ToActor.Power}>30
    {
    	if !${Me.Maintained[${SpellType[50]}](exists)} && ${Me.Ability[${SpellType[50]}].IsReady}
    	{
    		call CastSpellRange 50 0 0 0 ${KillTarget}
    		DebuffCnt:Inc
    	}
    	if !${Me.Maintained[${SpellType[51]}](exists)} && ${Me.Ability[${SpellType[51]}].IsReady} && ${DebuffCnt}<1
    	{
    		call CastSpellRange 51 0 0 0 ${KillTarget}
    		DebuffCnt:Inc
    	}
    	if !${Me.Maintained[${SpellType[52]}](exists)} && ${Me.Ability[${SpellType[52]}].IsReady} && ${DebuffCnt}<1
    	{
    		call CastSpellRange 52 0 0 0 ${KillTarget}
    		DebuffCnt:Inc
    	}
    }
	}

	;if we cast a debuff, check heals again before continue
	if (${DebuffCnt} > 0)
	{
		call CheckHeals
	}

	if (${VortexMode})
    {
        ;echo "DEBUG: Checking Energy Vortex..."
        if (!${Target.IsSolo})
        {
            ;echo "DEBUG: SpellType[385]: ${SpellType[385]}"
            ;echo "DEBUG: Energy Vortex -- Target is not solo...check"
            if ${Me.Ability[${SpellType[385]}].IsReady}
            {
                ;echo "DEBUG: Energy Vortex -- Ability (${Me.Ability[${SpellType[385]}]})' is ready...check"
                if (${Target.EncounterSize} > 2 || ${Target.Difficulty} >= 2)
                {
                    if (${Target.Health} > 50)
                    {
                        switch ${Target.ConColor}
                        {
                            case Red
                            case Orange
                            case Yellow
                            case White
                            case Blue
                                Me.Ability[${SpellType[385]}]:Use
                                wait 2
                                break
                            default
                                if (${Target.IsEpic} || ${Target.IsNamed})
                                {
                                    Me.Ability[${SpellType[385]}]:Use
                                    wait 2
                                }
                                break
                        }
                    }
                }
            }
        }
	}

    ;echo "DEBUG: Combat_Routine() -- Action: ${Action[${xAction}]} (xAction: ${xAction})"
    ;echo "DEBUG: Combat_Routine() -- MainAssist: ${MainAssist}"

	switch ${Action[${xAction}]}
	{
		case Debuff
			;need to check if each spell is maintained before recasting
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
						if !${Me.Maintained[${SpellType[${SpellRange[${xAction},2]}]}](exists)}
						{
							call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget}
						}
						if !${Me.Maintained[${SpellType[${SpellRange[${xAction},3]}]}](exists)}
						{
							call CastSpellRange ${SpellRange[${xAction},3]} 0 0 0 ${KillTarget}
						}
					}
				}
			}
			break

		case Nuke
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
				    call CheckCondition Health ${Health[${xAction},1]} ${Health[${xAction},2]}
				    if ${Return.Equal[OK]}
				    {
    					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    					if ${Return.Equal[OK]}
    					{
    						call CheckForMez "Fury Nuke"
    						if ${Return.Equal[FALSE]}
        						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
        				    else
        				        call ReacquireTargetFromMA
    					}
    				}
				}
			}
			break
		case AA_Thunderspike
			if ${OffenseMode} && ${MeleeMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
						}
					}
				}
			}
			break
		case AoE
			if ${OffenseMode} && ${AoEMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
				    call CheckCondition Health ${Health[${xAction},1]} ${Health[${xAction},2]}
				    if ${Return.Equal[OK]}
				    {
    					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    					if ${Return.Equal[OK]}
    					{
    						call CheckForMez "Fury AoE"
    						if ${Return.Equal[FALSE]}
        						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
        				    else
        				        call ReacquireTargetFromMA
    					}
    				}
				}
			}
			break
		case Proc
			if ${OffenseMode}
			{
			    if ${UseMeleeProcSpells}
			    {
    				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
    				if ${Return.Equal[OK]}
    				{
    					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    					if ${Return.Equal[OK]}
    					{
    						if ${Me.GroupCount} > 1
    						{
    							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
    						}
    					}
    				}
			    }
			}
			break
		case DoT
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
				    call CheckCondition Health ${Health[${xAction},1]} ${Health[${xAction},2]}
				    if ${Return.Equal[OK]}
				    {
    					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    					if ${Return.Equal[OK]}
    					{
    						call CheckForMez "Fury DoT"
    						if ${Return.Equal[FALSE]}
        						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
        				    else
        				        call ReacquireTargetFromMA
    					}
    				}
				}
			}
			break
		case DoT2
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
				    call CheckCondition Health ${Health[${xAction},1]} ${Health[${xAction},2]}
				    if ${Return.Equal[OK]}
				    {
    					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    					if ${Return.Equal[OK]}
    					{
    						call CheckForMez "Fury DoT2"
    						if ${Return.Equal[FALSE]}
        						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
        				    else
        				        call ReacquireTargetFromMA
    					}
    				}
				}
			}
			break
		case AA_Primordial_Strike
		case AA_Nature_Blade
			if ${OffenseMode} && ${MeleeMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					}
				}
			}
			break
		case PBAoE
			if ${PBAoEMode} && ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
				    call CheckCondition Health ${Health[${xAction},1]} ${Health[${xAction},2]}
				    if ${Return.Equal[OK]}
				    {
    					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    					if ${Return.Equal[OK]}
    					{
    						call CheckForMez "Fury PBoE"
    						if ${Return.Equal[FALSE]}
        					{
        					    call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
    						    call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget}
    					    }
        				    else
        				        call ReacquireTargetFromMA
    					}
    				}
				}
			}
			break
		case Snare
		case Feast
			if ${DebuffMode} && !${Target.IsEpic}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Mob.Count}>1
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}

			}
			break

		case Mastery
			if ${OffenseMode} || ${DebuffMode}
			{
			    ;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
			    ;;;;;;;;;;
			    if (${InvalidMasteryTargets.Element[${Target.ID}](exists)})
			        break
			    ;;;;;;;;;;;

			    call CheckForMez "Fury Mastery"
			    if ${Return.Equal[FALSE]}
			    {
    				if ${Me.Ability[Master's Smite].IsReady}
    				{
    					Target ${KillTarget}
    					Me.Ability[Master's Smite]:Use
    					do
    					{
    					    waitframe
    					}
    					while ${Me.CastingSpell}
    					wait 1
    				}
    			}
    			else
    			    call ReacquireTargetFromMA
			}
			break

		case Storms
			;need to add disable to heal routine to prevent stun lock
			if ${StormsMode} && ${Mob.Count}>=2
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckForMez "Fury Storms"
						if ${Return.Equal[FALSE]}
    						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
    				    else
    				        call ReacquireTargetFromMA
					}
				}
			}
			break
		default
			return CombatComplete
			break
	}


	if ${DoHOs}
	{
	    call CheckGroupHealth 60
	    if ${Return}
    		objHeroicOp:DoHO
	}
}

function Post_Combat_Routine(int xAction)
{

	TellTank:Set[FALSE]

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.Health}==-99
				{
					if ${Me.Ability[${SpellType[300]}].IsReady}
					{
						call CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
					elseif ${Me.Ability[${SpellType[301]}].IsReady}
					{
						call CastSpellRange 301 0 1 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
					elseif ${Me.Ability[${SpellType[302]}].IsReady}
					{
						call CastSpellRange 302 0 1 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
					else
					{
						call CastSpellRange 303 0 1 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break
        case CheckForCures
            ;echo "DEBUG: Checking if Cures are needed post combat..."
            call Check_Cures
            break
        case AutoFollowTank
        	if ${AutoFollowMode}
        		ExecuteAtom AutoFollowTank
        	break
		default
			return PostCombatRoutineComplete
			break
	}
}

function RefreshPower()
{
	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
		call UseItem "Helm of the Scaleborn"

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
		call UseItem "Spiritise Censer"

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
		call UseItem "Stein of the Everling Lord"
}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	call CastSpellRange 180 0 0 0 ${aggroid}

}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0
	declare MTinMyGroup bool local FALSE
	declare tempgrp int local 0

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[0]
	grpcure:Set[0]
	lowest:Set[0]
	;Raid Stuff
	declare HealUsed bool local FALSE
	declare temph2 int local
	declare raidlowest int local 0
	temph2:Set[1]
	raidlowest:Set[1]
	HealUsed:Set[FALSE]


    ;;;; Rez MainTank if he/she is dead
	if ${Actor[exactname,${MainTankPC}].IsDead} && ${Actor[exactname,${MainTankPC}](exists)} && (${CombatRez} || !${Me.InCombat})
		call CastSpellRange 300 0 1 0 ${Actor[exactname,${MainTankPC}].ID}

  if (${grpcnt} > 1)
  {
  	do
    {
    	if ${Me.Group[${temphl}].ToActor(exists)}
    	{

    		if ${Me.Group[${temphl}].ToActor.Health} < 100 && ${Me.Group[${temphl}].ToActor.Health} > -99
     		{
     			if ${Me.Group[${temphl}].ToActor.Health} < ${Me.Group[${lowest}].ToActor.Health}
     				lowest:Set[${temphl}]
     		}

    		if ${CureMode}
    		{
         	if (${temphl} == 0)
         	{
           	echo checking self
           	if ${Me.IsAfflicted}
         		{
           		;we'll always cure ourselves first, we need mostafficted to be the next cure target if any
           		;Me checks trimmed to only check for grpcure counters
           		if ${Me.Noxious}>0
           			grpcure:Inc

           		if ${Me.Elemental}>0
           			grpcure:Inc

       			}
         	}
    			else
          {
           	echo checking groupmember ${temphl}
           	if ${Me.Group[${temphl}].IsAfflicted}
            {
             	echo GroupMember ${temphl} is Afflicted...
 							echo groupmember ${temphl} has ${Me.Group[${temphl}].Arcane} Arcane Afflictions
             	echo groupmember ${temphl} has ${Me.Group[${temphl}].Noxious} Noxious Afflictions
             	echo groupmember ${temphl} has ${Me.Group[${temphl}].Elemental} Elemental Afflictions
             	echo groupmember ${temphl} has ${Me.Group[${temphl}].Trauma} Trauma Afflictions

             	if ${Me.Group[${temphl}].Arcane}>0
               	tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

            	if ${Me.Group[${temphl}].Noxious}>0
              {
               	grpcure:Inc
                tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]
              }

              if ${Me.Group[${temphl}].Elemental}>0
              {
               	grpcure:Inc
                tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]
              }

           		if ${Me.Group[${temphl}].Trauma}>0
           			tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

           		echo Groupmember ${temphl} Afflictions - ${tmpafflictions} :: MostAfflictions ${mostafflictions}
           		if ${tmpafflictions}>${mostafflictions}
           		{
           			echo setting mostafflictions - ${tmpafflictions} :: mostafflicted - ${temphl}
           			mostafflictions:Set[${tmpafflictions}]
           			mostafflicted:Set[${temphl}]
           		}
           	}
          }
     		}

     		if ${Me.Group[${temphl}].ToActor.Health} > -99 && ${Me.Group[${temphl}].ToActor.Health} < 80
     			grpheal:Inc

     		if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]} || ${Me.Group[${temphl}].Class.Equal[illusionist]}
     		{
     			if ${Me.Group[${temphl}].ToActor.Pet.Health} < 60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
     				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
     		}

     		if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
     			MTinMyGroup:Set[TRUE]
     	}
    }
    while ${temphl:Inc} <= ${grpcnt}
  }

	echo Cure Check complete - Mostafflicted - ${mostafflicted} :: Afflictions - ${mostafflictions}
	;CURES
	if (${CureMode})
	{
		;group cure first if needed
	  if ${grpcure}>2
      call CastSpellRange 220

	  ;Always cure self first, else we may not live to cure others
	  if ${Me.IsAfflicted}
	     call CureMe

	  ;Cure most afflicted
	  if ${mostafflicted}
    {
      echo GroupMember ${mostafflicted} Needs Cure
      call CheckGroupHealth 30
     	if ${Return}
 			{
    		echo Calling CureGroupMember on ${mostafflicted}
    		call CureGroupMember ${mostafflicted}
      }
      else
      {
      	echo GroupHealth Low, casting heal before cure
      	call CastSpellRange 10
      	echo Calling CureGroupMember on ${mostafflicted}
       	call CureGroupMember ${mostafflicted}
      }
    }
  }

	;MAINTANK EMERGENCY HEAL
	if (${grpcnt} > 1)
	{
    if ${Actor[exactname,${MainTankPC}](exists)} && ${Actor[exactname,${MainTankPC}].ID} != ${Me.ID} && ${Actor[exactname,${MainTankPC}].Health}<30 && !${Actor[exactname,${MainTankPC}].IsDead}
    {
 	    call EmergencyHeal ${Actor[exactname,${MainTankPC}].ID}
 	    HealUsed:Set[TRUE]
    }
  }

	; Self heals (note:  Self is also included in group heals now .. so we're only concerned about emergencies)
    variable int LowestGroupMemberHealth = 100
    if (${Me.Group[${lowest}].ToActor(exists)})
  	    LowestGroupMemberHealth:Set[${Me.Group[${lowest}].ToActor.Health}]

    if (${Me.ToActor.Health} <= ${LowestGroupMemberHealth})
    {
		if ${Me.ToActor.Health} < 25
		{
      ;echo "DEBUG: Healing Me (Me.ToActor.Health: ${Me.ToActor.Health} < LowestGroupMemberHealth: ${LowestGroupMemberHealth})"
			if ${haveaggro}
			{
				call EmergencyHeal ${Me.ID}
				HealUsed:Set[TRUE]
			}
			else
			{
				if ${Me.Ability[${SpellType[1]}].IsReady}
				{
					call CastSpellRange 1 0 0 0 ${Me.ID}
					HealUsed:Set[TRUE]
				}
				else
				{
					call CastSpellRange 4 0 0 0 ${Me.ID}
					HealUsed:Set[TRUE]
				}
			}
		}
		elseif ${Me.ToActor.Health} < 50
		{
			;echo "DEBUG: Healing Me (Me.ToActor.Health: ${Me.ToActor.Health} < LowestGroupMemberHealth: ${LowestGroupMemberHealth})"
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 1 0 0 0 ${Me.ID}
				HealUsed:Set[TRUE]
			}
			else
			{
				call CastSpellRange 4 0 0 0 ${Me.ID}
				HealUsed:Set[TRUE]
			}
		}
		elseif ${Me.ToActor.Health} < 80
		{
	    ;echo "DEBUG: Healing Me (Me.ToActor.Health: ${Me.ToActor.Health} < LowestGroupMemberHealth: ${LowestGroupMemberHealth})"
			if ${haveaggro}
			{
				call CastSpellRange 7 0 0 0 ${Me.ID}
				HealUsed:Set[TRUE]
			}
			else
			{
				if ${Me.Ability[${SpellType[1]}].IsReady}
				{
					call CastSpellRange 1 0 0 0 ${Me.ID}
					HealUsed:Set[TRUE]
				}
				else
				{
					call CastSpellRange 4 0 0 0 ${Me.ID}
					HealUsed:Set[TRUE]
				}
			}
		}
	}

    call CheckHOTs

  ;;;;
	;;MAINTANK HEALS
	if ${Actor[exactname,${MainTankPC}](exists)} && ${Actor[exactname,${MainTankPC}].ID}!=${Me.ID} && !${Actor[exactname,${MainTankPC}].IsDead}
	{
		variable int MainTankHealth = 100
		MainTankHealth:Set[${Actor[exactname,${MainTankPC}].Health}]

	  ;we want to continue casting, if under 50, and frey doesn't get them over 50, we need to cast 4,
	  ;if still under 75 we need to cast 1, etc.  The point is to check the health after the triggered heal is cast,
	  ;if we're still not healthy enough, to keep casting heals.  It turns into chain casts, but thats whats needed
	  ;sometimes on spike damage.  If we like, we could not cast additional heals if target !epic and Healused is true.
	  ;Also, no need to keep healing if the tank died.
	  if (${Actor[exactname,${MainTankPC}].Health} <= 50  && !${Actor[exactname,${MainTankPC}].IsDead})
	  {
     	;echo "DEBUG: Healing Main Tank() (MainTankHealth: ${MainTankHealth})"
      if ${Me.Ability[${SpellType[2]}].IsReady}
     	{
     		call CastSpellRange 2 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
     		HealUsed:Set[TRUE]
     	}
     	elseif (${MTinMyGroup})
      {
       	call CastSpellRange 10
       	HealUsed:Set[TRUE]
      }
	  }

	  if (${Actor[exactname,${MainTankPC}].Health} <= 60 && !${Actor[exactname,${MainTankPC}].IsDead})
	  {
			;echo "DEBUG: Healing Main Tank() (MainTankHealth: ${MainTankHealth})"
			call CastSpellRange 4 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
			HealUsed:Set[TRUE]
    }

    if (${Actor[exactname,${MainTankPC}].Health} <= 75 && !${Actor[exactname,${MainTankPC}].IsDead})
    {
	    ;echo "DEBUG: Healing Main Tank() (MainTankHealth: ${MainTankHealth})"
	    call CastSpellRange 1 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
	    HealUsed:Set[TRUE]
    }

    if (${Actor[exactname,${MainTankPC}].Health} <= 90 && !${Actor[exactname,${MainTankPC}].IsDead})
    {
      ;echo "DEBUG: Healing Main Tank() (MainTankHealth: ${MainTankHealth})"
	    if !${KeepMTHOTUp} && !${Me.InRaid} && ${Me.Ability[${SpellType[7]}].IsReady}
	    {
		    call CastSpellRange 7 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
		    HealUsed:Set[TRUE]
	    }
	    elseif !${KeepGroupHOTUp} && ${MTinMyGroup}
	    {
		    call CastSpellRange 15 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
		    HealUsed:Set[TRUE]
	    }
    }
  }
  call CheckHOTs


	;GROUP HEALS
	if ${grpheal} > 2
	{
	  ;echo "DEBUG: Healing Group: (grpheal: ${grpheal})"

		;use hibernation if not already up
		if !${Me.Maintained[${SpellType[11]}](exists)}
		{
			call CastSpellRange 11
			HealUsed:Set[TRUE]
		}

		;use group HoT or group direct
		if ${Me.Ability[${SpellType[15]}].IsReady} && !${KeepGroupHOTUp}
		{
			call CastSpellRange 15
			HealUsed:Set[TRUE]
		}
		else
		{
			call CastSpellRange 10
			HealUsed:Set[TRUE]
		}
	}

  ;;;; Heal Group Lowest
  if (${Me.Group[${lowest}].ToActor(exists)} && !${Me.Group[${lowest}].ToActor.IsDead})
  {
  	variable int GroupMemberHealth = 100
    GroupMemberHealth:Set[${Me.Group[${lowest}].ToActor.Health}]

    if (${GroupMemberHealth} <= 55)
    {
    	;echo "DEBUG: Healing Group Lowest: (GroupMemberHealth: ${GroupMemberHealth}) :: ${Me.Group[${lowest}]}"
      if ${Me.Ability[${SpellType[2]}].IsReady}
      {
      	call CastSpellRange 2 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
        HealUsed:Set[TRUE]
      }
      else
      {
      	if ${Me.Ability[${SpellType[4]}].IsReady}
      	{
      		call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
      		HealUsed:Set[TRUE]
      	}
      	else
      	{
      		call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
      		HealUsed:Set[TRUE]
      	}
      }
    }
  	elseif (${GroupMemberHealth} <= 75)
    {
    	;echo "DEBUG: Healing Group Lowest: (GroupMemberHealth: ${GroupMemberHealth}) :: ${Me.Group[${lowest}]}"
    	if ${Me.Ability[${SpellType[4]}].IsReady}
    	{
    		call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
    		HealUsed:Set[TRUE]
    	}
    	else
    	{
    		call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
    		HealUsed:Set[TRUE]
    	}
    }
	}

	;RAID HEALS
	if ${Me.InRaid}
	{
   	if ${RaidHealMode} && ${Me.ToActor.Health}>25 && ${Actor[exactname,${MainTankPC}].Health}>70 && !${HealUsed}
   	{
   		do
   		{
   			if ${Actor[pc,exactname,${Me.Raid[${temph2}].Name}](exists)}
   			{
   				if !${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].Name.Equal[${Me.Name}]} && !${Me.Group[${Actor[pc,exactname,${Me.Raid[${temph2}].Name}]}].ID(exists)}
   				{
   					if ${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].Health} < 100 && !${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].IsDead} && ${Me.Raid[${temph2}](exists)}
   					{
   						if ${Actor[pc,exactname,${Me.Raid[${temph2}].Name}].Health} < ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].Health}
   							raidlowest:Set[${temph2}]
   					}
   				}
   			}
   		}
   		while ${temph2:Inc}<=24

   		if ${Me.InCombat} && ${Actor[exactname,${Me.Raid[${raidlowest}].Name}](exists)} && ${Actor[exactname,${Me.Raid[${raidlowest}].Name}].Health} < 60 && !${Actor[exactname,${Me.Raid[${temph2}].Name}].IsDead}
   		{
   			;echo Raid Lowest: ${Me.Raid[${raidlowest}].Name} -> ${Actor[exactname,${Me.Raid[${raidlowest}].Name}].Health} health
   			if ${Me.Ability[${SpellType[2]}].IsReady} && ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].Health} < 50
   				call CastSpellRange 2 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
   			elseif ${Me.Ability[${SpellType[4]}].IsReady}
   				call CastSpellRange 4 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
   			elseif ${Me.Ability[${SpellType[1]}].IsReady}
   				call CastSpellRange 1 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
   			elseif ${Me.Ability[${SpellType[7]}].IsReady} && !${KeepMTHOTUp} && ${Me.ToActor.Power}>50
   				call CastSpellRange 7 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
   		}
   	}
  }

	;PET HEALS
	if (!${Me.InRaid})
	{
		if (${PetToHeal})
	  {
	  	;echo "DEBUG: Healing Pet (PetToHeal): ${PetToHeal})"
      if (${Actor[${PetToHeal}](exists)})
      {
     		if ${Actor[${PetToHeal}].InCombatMode}
     			call CastSpellRange 7 0 0 0 ${PetToHeal}
     		else
     			call CastSpellRange 1 0 0 0 ${PetToHeal}
      }
    }
	}

	if ${CombatRez} || !${Me.InCombat}
	{
		;Res Fallen Groupmembers only if in range
		grpcnt:Set[${Me.GroupCount}]
		tempgrp:Set[0]
		do
		{
			if ${Me.Group[${tempgrp}].ToActor.IsDead}
			{
				if ${Me.Ability[${SpellType[300]}].IsReady}
					call CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				elseif ${Me.Ability[${SpellType[301]}].IsReady}
					call CastSpellRange 301 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				elseif ${Me.Ability[${SpellType[302]}].IsReady}
					call CastSpellRange 302 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				else
					call CastSpellRange 303 0 1 0 ${Me.Group[${tempgrp}].ID} 1
			}
		}
		while ${tempgrp:Inc}<${grpcnt}
	}
}

function EmergencyHeal(int healtarget)
{
	;death prevention
	if ${Me.Ability[${SpellType[316]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
		call CastSpellRange 316 0 0 0 ${healtarget}

	;emergency heals
	if ${Me.Ability[${SpellType[8]}].IsReady}
		call CastSpellRange 8 0 0 0 ${healtarget}

	if ${Me.Ability[${SpellType[16]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
		call CastSpellRange 16 0 0 0 ${healtarget}
}

function CheckHOTs()
{

	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]
	if ${Me.InCombat} || ${Actor[exactname,${MainTankPC}].InCombatMode}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID}==${Actor[exactname,${MainTankPC}].ID}
			{
				;echo Single HoT is Present on MT
				hot1:Set[1]
				break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group HoT is Present
				grphot:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${KeepMTHOTUp}
		{
			if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				call CastSpellRange 7 0 0 0 ${Actor[exactname,${MainTankPC}].ID}
				hot1:Set[1]
			}
		}

		if ${KeepGroupHOTUp}
		{
			if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
				call CastSpellRange 15
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

	if ${Actor[exactname,${MainTankPC}].IsDead} && ${Actor[exactname,${MainTankPC}](exists)} && ${CombatRez}
	{
		if ${Me.Ability[${SpellType[300]}].IsReady}
			call CastSpellRange 300 0 1 0 ${MainTankPC} 1
		elseif ${Me.Ability[${SpellType[301]}].IsReady}
			call CastSpellRange 301 0 1 0 ${MainTankPC} 1
    	elseif ${Me.Ability[${SpellType[302]}].IsReady}
			call CastSpellRange 302 0 1 0 ${MainTankPC} 1
		else
			call CastSpellRange 303 0 1 0 ${MainTankPC} 1
	}
}

function Cancel_Root()
{

}

function Check_Cures()
{
	declare temphl int local
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0

	grpcnt:Set[${Me.GroupCount}]

	temphl:Set[0]
	grpcure:Set[0]

	;echo "DEBUG: Check_Cures() -- grpcnt ${grpcnt}"

    if (${grpcnt} > 1)
    {
    	do
    	{
    		if ${Me.Group[${temphl}].ToActor(exists)}
    		{
    		  ;echo "DEBUG: Check_Cures(${temphl}) -- Group Member Exists [${Me.Group[${temphl}].ToActor}]"
    			if (${temph1} == 0)
    			{
        			if ${Me.IsAfflicted}
        		    {
        				if ${Me.Arcane}>0
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Arcane}]}]

        				if ${Me.Noxious}>0
        				{
        				    grpcure:Inc
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Noxious}]}]
        				}

        				if ${Me.Elemental}>0
        				{
        				    grpcure:Inc
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Elemental}]}]
        				}

        				if ${Me.Trauma}>0
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Trauma}]}]
	   			    }
    			}
    			else
    			{
    			    if ${Me.Group[${temphl}].IsAfflicted}
        			{
      			    ;echo "DEBUG: Check_Cures(): ${Me.Group[${temphl}]} IS afflicted..."
      			    ;echo "DEBUG: Check_Cures(): group member #${temphl} Arcane: ${Me.Group[${temphl}].Arcane}"
      			    ;echo "DEBUG: Check_Cures(): group member #${temphl} Noxious: ${Me.Group[${temphl}].Noxious}"
      			    ;echo "DEBUG: Check_Cures(): group member #${temphl} Elemental: ${Me.Group[${temphl}].Elemental}"
      			    ;echo "DEBUG: Check_Cures(): group member #${temphl} Trauma: ${Me.Group[${temphl}].Trauma}"
        				if ${Me.Group[${temphl}].Arcane}>0
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

        				if ${Me.Group[${temphl}].Noxious}>0
        				{
        				    grpcure:Inc
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]
        				}

        				if ${Me.Group[${temphl}].Elemental}>0
        				{
        				    grpcure:Inc
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]
        				}

        				if ${Me.Group[${temphl}].Trauma}>0
        					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

        				;echo "DEBUG: Check_Cures(): tmpafflicions: ${tmpafflictions}"
        				;echo "DEBUG: Check_Cures() -- grpcure: ${grpcure} :: mostafflicted: ${mostafflicted}"

        				if ${tmpafflictions} > ${mostafflictions}
        				{
        					mostafflictions:Set[${tmpafflictions}]
        					mostafflicted:Set[${temphl}]
        				}
        			}
        		}
    		}
    	}
    	while ${temphl:Inc} <= ${grpcnt}
    }

	;echo "DEBUG: Check_Cures(END) -- grpcure: ${grpcure} :: mostafflicted: ${mostafflicted}"

	;;;;;;;;;;;;;;;;;;;;;;;
	;;Do The Cure(s)
	if (${grpcure} > 1)
		call CastSpellRange 220

	if ${Me.IsAfflicted}
		call CureMe


	if ${mostafflicted}
	{
		call CheckGroupHealth 30
		if ${Return}
			call CureGroupMember ${mostafflicted}
		else
		{
			call CastSpellRange 10
			call CureGroupMember ${mostafflicted}
		}
	}
}

function CureMe()
{
	echo CureMe!
	if  ${Me.Arcane}>0
		call CastSpellRange 213 0 0 0 ${Me.ID}

	if  ${Me.Noxious}>0
		call CastSpellRange 210 0 0 0 ${Me.ID}

	if  ${Me.Elemental}>0
		call CastSpellRange 212 0 0 0 ${Me.ID}

	if  ${Me.Trauma}>0
		call CastSpellRange 211 0 0 0 ${Me.ID}
}

function CureGroupMember(int gMember)
{
	echo CureGroupMember ${gMember}
	declare tmpcure int local

	if (${gMember} == 0)
	{
	    call CureMe
	    return
	}


	tmpcure:Set[0]
	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.Distance}>25
	  return

  do
	{
		call CheckGroupHealth 50
		if !${Return}
		{
			call CastSpellRange 10
		}

		if ${Me.Group[${gMember}].ToActor.Health}<25
			call CastSpellRange 4 0 0 0 ${Me.Group[${gMember}].ID}

		if  ${Me.Group[${gMember}].Arcane}>0
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}

		if  ${Me.Group[${gMember}].Noxious}>0
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}

		if  ${Me.Group[${gMember}].Elemental}>0
			call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}

		if  ${Me.Group[${gMember}].Trauma}>0
			call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${tmpcure:Inc} < 3
}

function HandleGroupWiped()
{
    ;;; There was a full group wipe and now we are rebuffing

    ;assume that someone used a feather
    if (${Me.GroupCount} > 1)
    {
      Me.Ability[Favor of the Phoenix]:Use
    	do
    	{
    	  waitframe
    	}
    	while ${Me.CastingSpell}
    	wait 1
    }

    return OK
}