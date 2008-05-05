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

	declare AoEMode bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare MezzMode bool script FALSE
	declare Makepet bool script FALSE
	declare BuffAspect bool script FALSE
	declare BuffRune bool script FALSE
	declare BuffFocus bool script FALSE
	declare StartHO bool script 1
	declare DPSMode bool script 1
	declare SprintMode bool script 1

	call EQ2BotLib_Init

	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffAspect:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAspect,FALSE]}]
	BuffRune:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffRune,FALSE]}]
	BuffFocus:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffFocus,FALSE]}]
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	Makepet:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Makepet,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	BuffTime_Compression:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffTime_Compression,]}]
	BuffIllusory_Arm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffIllusory_Arm,]}]
	DPSMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[DPSMode,FALSE]}]
	SprintMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[SprintMode,FALSE]}]
	
	NoEQ2BotStance:Set[TRUE]

}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Aspect]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[DamageProc]
	PreSpellRange[3,1]:Set[40]

	PreAction[4]:Set[MakePet]
	PreSpellRange[4,1]:Set[355]

	;haste
	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[35]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[Rune]
	PreSpellRange[7,1]:Set[20]

	PreAction[8]:Set[Clarity]
	PreSpellRange[8,1]:Set[22]

	PreAction[10]:Set[AA_Empathic_Aura]
	PreSpellRange[10,1]:Set[391]

	PreAction[11]:Set[AA_Empathic_Soothing]
	PreSpellRange[11,1]:Set[392]

	PreAction[12]:Set[AA_Time_Compression]
	PreSpellRange[12,1]:Set[393]

	PreAction[13]:Set[AA_Illusory_Arm]
	PreSpellRange[13,1]:Set[394]
}

function Combat_Init()
{

	Action[1]:Set[Shower]
	MobHealth[1,1]:Set[30]
	MobHealth[1,2]:Set[100]
	SpellRange[1,1]:Set[388]

	Action[2]:Set[AA_Illuminate]
	MobHealth[2,1]:Set[30]
	MobHealth[2,2]:Set[100]
	SpellRange[2,1]:Set[387]

	Action[3]:Set[SpellShield]
	MobHealth[3,1]:Set[30]
	MobHealth[3,2]:Set[100]
	SpellRange[3,1]:Set[361]

	Action[4]:Set[Gaze]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[40]
	SpellRange[4,1]:Set[90]

	Action[5]:Set[Ego]
	SpellRange[5,2]:Set[91]

	Action[6]:Set[Master_Strike]

	Action[7]:Set[Despair]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[80]

	Action[8]:Set[AA_Chronosiphoning]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[385]

	Action[9]:Set[Discord]
	MobHealth[9,1]:Set[40]
	MobHealth[9,2]:Set[100]
	SpellRange[9,1]:Set[72]

	Action[10]:Set[MindDoT]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[70]

	Action[11]:Set[Constructs]
	MobHealth[11,1]:Set[40]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[51]

	Action[12]:Set[Nuke]
	SpellRange[12,1]:Set[60]

	Action[13]:Set[Stun]
	SpellRange[13,1]:Set[190]

	Action[14]:Set[Silence]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	SpellRange[14,1]:Set[260]

	Action[15]:Set[AEStun]
	MobHealth[15,1]:Set[1]
	MobHealth[15,2]:Set[100]
	SpellRange[15,1]:Set[191]

	Action[16]:Set[Daze]
	MobHealth[16,1]:Set[1]
	MobHealth[16,2]:Set[100]
	SpellRange[16,1]:Set[260]

	;Was ProcStun
	Action[17]:Set[IllusAllies]
	MobHealth[17,1]:Set[60]
	MobHealth[17,2]:Set[100]
	SpellRange[17,1]:Set[192]

	Action[18]:Set[Focus]
	MobHealth[18,1]:Set[80]
	MobHealth[18,2]:Set[100]
	SpellRange[18,1]:Set[23]

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

	if ${SprintMode} && ${Me.ToActor.Power}>30 && !${Me.Maintained[${SpellType[333]}](exists)}
		call CastSpellRange 333
	elseif ${Me.Maintained[${SpellType[333]}](exists)} && ${Me.ToActor.Power}<35
		Me.Maintained[${SpellType[333]}]:Cancel

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
			if ${BuffRune}
			{
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    				call CastSpellRange ${PreSpellRange[${xAction},1]}				    
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Aspect
			if ${BuffAspect}
			{
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    				call CastSpellRange ${PreSpellRange[${xAction},1]}		
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case MakePet
			if ${Makepet} && ${Me.UsedConc}<3
			{
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    				call CastSpellRange ${PreSpellRange[${xAction},1]}		
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

		case SeeInvis
			if ${BuffSeeInvis}
			{
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ToActor.ID}

				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
					}

				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case AA_Time_Compression
			BuffTarget:Set[${UIElement[cbBuffTime_Compression@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case AA_Illusory_Arm		
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
		default
			return BuffComplete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare spellsused int local
	spellsused:Set[0]

	CurrentAction:Set[Combat ${xAction}]

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${SprintMode} && ${Me.ToActor.Power}>30 && !${Me.Maintained[${SpellType[333]}](exists)}
	{
		call CastSpellRange 333
	}
	elseif ${Me.Maintained[${SpellType[333]}](exists)} && ${Me.ToActor.Power}<35
	{
		Me.Maintained[${SpellType[333]}]:Cancel
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
	}

	call PetAttack

	call CheckHeals

	if ${ShardMode}
	{
		call Shard
	}

	call RefreshPower


	;chronsphioning AA. we should always try to keep this spell up
	if ${Me.Ability[${SpellType[385]}](exists)}
	{
	    if (${Me.Ability[${SpellType[385]}].IsReady})
		    call CastSpellRange 385 0 0 0 ${KillTarget}
	}

	;make sure killtarget is always Melee debuffed (unless I am the tank)
	;; TO DO ..redo this!
	if ${Target.IsEpic}
    	call CastSpellRange 50 0 0 0 ${KillTarget}

	;make sure Psychic Asailant debuff / stun always on.
	call CastSpellRange 61 0 0 0 ${KillTarget}


	if ${DPSMode}
	{

		if ${Me.Ability[${SpellType[387]}].IsReady}
		{
			call CastSpellRange 387 0 0 0 ${KillTarget}
		}

		if ${Me.Ability[${SpellType[60]}].IsReady}
		{
			call CastSpellRange 60 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)} && ${spellsused}<4
		{
			call CastSpellRange 70 0 0 0 ${KillTarget}
			spellsused:Inc
		}

        if ${Target.Type.Equal[PC]}
        {
    		if ${Me.Ability[${SpellType[72]}].IsReady} && ${spellsused}<4
    		{
    			call CastSpellRange 72 0 0 0 ${KillTarget}
    			spellsused:Inc
    		}
	    }

		if ${Me.Ability[${SpellType[80]}].IsReady} && !${Me.Maintained[${SpellType[80]}](exists)} && ${spellsused}<4
		{
			call CastSpellRange 80 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[91]}].IsReady} && ${spellsused}<4
		{
			call CastSpellRange 91 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[388]}].IsReady} && !${Me.Maintained[${SpellType[388]}](exists)} && ${spellsused}<4
		{
			call CastSpellRange 388 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[90]}].IsReady} && !${Me.Maintained[${SpellType[90]}](exists)} && ${spellsused}<4
		{
			call CastSpellRange 90 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[95]}].IsReady} && ${PBAoEMode} && ${spellsused}<4
		{
			call CastSpellRange 95 0 1 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[51]}].IsReady} && ${spellsused}<3
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			spellsused:Inc
		}

	}
	else
	{
		switch ${Action[${xAction}]}
		{

			case AA_Illuminate
				if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Mob.Count}>1
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break
            case AA_Chronosiphoning
			    ; This is now being called earlier in the combat routine to make sure that it's always up.
				;if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
				;{
				;	call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				;	if ${Return.Equal[OK]}
				;	{
				;		if ${Mob.Count}>1
				;		{
				;			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				;		}
				;	}
				;}
				break
    		case Focus
    			if ${BuffFocus}
    				call CastSpellRange ${PreSpellRange[${xAction},1]}
    			else
    				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
    			break
			case Gaze
			case Shower
			case Ego
			case AEStun
				if ${AoEMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Mob.Count}>1
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break
			case SpellShield
			case Despair
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break

			case Discord        
			;; TO DO
			    if (${Target.Type.Equal[PC]})
			    {
    				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
    				if ${Return.Equal[OK]}
    				{
    					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
    				}
			    }
				break			
			
			case MindDoT
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break

			case Constructs
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break

			case Master_Strike
				if ${OffenseMode} || ${DebuffMode}
				{
					if ${Me.Ability[Master's Strike].IsReady}
					{
						Target ${KillTarget}
						Me.Ability[Master's Strike]:Use
					}
				}
				break

			case IllusAllies
				if !${Me.Grouped}
				{
				    if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    {
				        if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
        					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
        			}
				}
				break
			case Nuke
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Stun
			case Silence
			case Daze
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break

			default
				return CombatComplete
				break
		}
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
	if ${Me.Power}<40
	{
		call Shard
	}

	;Transference line out of Combat
	if ${Me.ToActor.Health}>60 && ${Me.ToActor.Power}<70 && !${Me.InCombat}
	{
		call CastSpellRange 309
	}

	;Transference Line in Combat
	if ${Me.ToActor.Health}>60 && ${Me.ToActor.Power}<50
	{
		call CastSpellRange 309
	}

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
	{
		call CastSpellRange 360 0 0 0 ${Me.Group[${MemberLowestPower}].ToActor.ID}
	}

	;Mana Cloak the group if the Main Tank is low on power
	if ${Actor[${MainTankPC}].Power} < 20 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].Distance}<50  && ${Actor[${MainTankPC}].InCombatMode}
	{
		call CastSpellRange 354
		call CastSpellRange 389
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

