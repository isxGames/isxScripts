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
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20080408
	;;;;

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
	Action[1]:Set[Nuke]
	MobHealth[1,1]:Set[1]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	Health[1,1]:Set[51]
	Health[1,2]:Set[100]
	SpellRange[1,1]:Set[60]

	Action[2]:Set[PBAoE]
	MobHealth[2,1]:Set[20]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[40]
	Power[2,2]:Set[100]
	Health[2,1]:Set[51]
	Health[2,2]:Set[100]
	SpellRange[2,1]:Set[95]
	SpellRange[2,2]:Set[97]

	Action[3]:Set[AoE]
	MobHealth[3,1]:Set[5]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[30]
	Power[3,2]:Set[100]
	Health[3,1]:Set[51]
	Health[3,2]:Set[100]
	SpellRange[3,1]:Set[90]

	Action[4]:Set[DoT2]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[30]
	Power[4,2]:Set[100]
	Health[4,1]:Set[51]
	Health[4,2]:Set[100]
	SpellRange[4,1]:Set[51]

	Action[5]:Set[Proc]
	MobHealth[5,1]:Set[30]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[40]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[157]

	Action[6]:Set[Mastery]
	MobHealth[6,1]:Set[20]
	MobHealth[6,2]:Set[100]

	Action[7]:Set[DoT]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[30]
	Power[7,2]:Set[100]
	Health[7,1]:Set[51]
	Health[7,2]:Set[100]
	SpellRange[7,1]:Set[70]

	Action[8]:Set[Feast]
	MobHealth[8,1]:Set[5]
	MobHealth[8,2]:Set[50]
	Power[8,1]:Set[30]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[312]

	Action[9]:Set[Storms]
	MobHealth[9,1]:Set[20]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[40]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[96]

	Action[10]:Set[AA_Thunderspike]
	MobHealth[10,1]:Set[10]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[40]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[383]

	Action[11]:Set[AA_Primordial_Strike]
	MobHealth[11,1]:Set[10]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[40]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[382]

	Action[12]:Set[AA_Nature_Blade]
	MobHealth[12,1]:Set[10]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[40]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[381]

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


	if ${Groupwiped}
	{
		Call HandleGroupWiped
		Groupwiped:Set[False]
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

	if ${xAction}==1
		call CheckHeals

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 2
	}

	if ${Me.ToActor.Power}>85
		call CheckHOTs

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
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}

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


	if !${Actor[id,${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
	    return CombatComplete

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]


	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${CureMode}
		call CheckCures

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
		call Shard

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
		if ${CureMode}
			call CheckCures

		call CheckHOTs
	}

	if (${VortexMode})
	{
		;echo "DEBUG: Checking Energy Vortex..."
		if (!${Target.IsSolo} && ${Target.Health} > 50)
		{
			;echo "DEBUG: SpellType[385]: ${SpellType[385]}"
			;echo "DEBUG: Energy Vortex -- Target is not solo...check"
			if ${Me.Ability[${SpellType[385]}].IsReady}
			{
				;echo "DEBUG: Energy Vortex -- Ability (${Me.Ability[${SpellType[385]}]})' is ready...check"
				if (${Target.EncounterSize} > 2 || ${Target.Difficulty} >= 2)
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

	;echo "DEBUG: Combat_Routine() -- Action: ${Action[${xAction}]} (xAction: ${xAction})"
	;echo "DEBUG: Combat_Routine() -- MainAssist: ${MainAssist}"

	switch ${Action[${xAction}]}
	{
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
			;the rest of the action list is melee attacks, escape out now if not enabled!
			if !${MeleeMode}
				return CombatComplete

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
			if ${OffenseMode} && ${UseMeleeProcSpells} && ${Me.GroupCount} > 1
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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
			if !${Target.IsEpic}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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

				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
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
			call CheckCures
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

	call CastSpellRange 180 0 0 0 ${aggroid}

}

function CheckHeals()
{
	declare tempgrp int local 1
	declare temphl int local 1
	declare temph2 int local 1
	declare grpheal int local 0
	declare lowest int local 0
	declare raidlowest int local 1
	declare PetToHeal int local 0
	declare MainTankID int local 0
	declare MainTankInGroup bool local 0

	MainTankID:Set[${Actor[pc,ExactName,${MainTankPC}].ID}]
	grpcnt:Set[${Me.GroupCount}]

	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Res the MT if they are dead
	if (!${Me.ToActor.InCombatMode} || ${CombatRez}) && ${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call CastSpellRange 300 0 1 1 ${MainTankID}

	call CheckHOTs

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{

			if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<${Me.Group[${lowest}].ToActor.Health} || ${lowest}==0
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ID}==${MainTankID}
				MainTankInGroup:Set[1]

			if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80
				grpheal:Inc

			if (${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]} || ${Me.Group[${temphl}].Class.Equal[coercer]})
			{
    			if (${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0)
    				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
			}

			if (${Me.Group[${temphl}].Class.Equal[illusionist]} && !${Me.InCombat})
			{
    			if (${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0)
    				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
			}

			if ${Me.Pet.Health}<60
				PetToHeal:Set[${Me.ToActor.Pet.ID}]
		}
	}
	while ${temphl:Inc}<=${grpcnt}

	if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
		grpheal:Inc

	if ${grpheal}>2
		call GroupHeal

	if ${Actor[${MainTankID}].Health}<90
	{
		if ${Me.ID}==${MainTankID}
			call HealMe
		else
			call HealMT ${MainTankID} ${MainTankInGroup}
	}

	;Check My health after MT
	if ${Me.ID}!=${MainTankID} && ${Me.ToActor.Health}<90
		call HealMe

	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].ToActor.Health}<50 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)}
			call CastSpellRange 2 0 0 0 ${Me.Group[${lowest}].ID}

		if ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)}
		{
			if ${Me.Ability[${SpellType[7]}].IsReady}
				call CastSpellRange 7 0 0 0 ${Me.Group[${lowest}].ID}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ID}
			else
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ID}
		}
	}

	;RAID HEALS - Only check if in raid, raid heal mode on, maintank is green, I'm above 50, and a direct heal is available.  Otherwise don't waste time.
	if ${RaidHealMode} && ${Me.InRaid} && ${Me.ToActor.Health}>50 && ${Actor[${MainTankID}].Health}>70 && (${Me.Ability[${SpellType[4]}].IsReady} || ${Me.Ability[${SpellType[1]}].IsReady})
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
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Actor[pc,exactname,${Me.Raid[${raidlowest}].Name}].ID}
		}
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[ExactName,${PetToHeal}](exists)} && ${Actor[ExactName,${PetToHeal}].InCombatMode} && !${EpicMode} && !${Me.InRaid}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	if ${EpicMode}
		call CheckCures

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		grpcnt:Set[${Me.GroupCount}]
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.IsDead}
				call CastSpellRange 300 303 0 0 ${Me.Group[${temphl}].ID} 1
		}
		while ${temphl:Inc}<${grpcnt}
	}
}

function HealMe()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.ID}
			else
				call CastSpellRange 1 0 0 0 ${Me.ID}
		}
	}

	if ${Me.ToActor.Health}<65
	{
		if !${EpicMode} || (${haveaggro} && ${Me.ToActor.InCombatMode})
			call CastSpellRange 7 0 0 0 ${Me.ID}
		else
			call CastSpellRange 1 0 0 0 ${Me.ID}
	}

	if ${Me.ToActor.Health}<40
		call CastSpellRange 1 0 0 0 ${Me.ID}
}

function HealMT(int MainTankID, int MTInMyGroup)
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Frey Check
	if ${Actor[${MainTankID}].Health}<50 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
	{
		call CastSpellRange 2 0 0 0 ${MainTankID}
	}

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call EmergencyHeal ${MainTankID} ${MTInMyGroup}

	;MAINTANK HEALS
	; Use regens first, then Patch Heals
	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)} && ${MTInMyGroup} && ${EpicMode}
		{
			call CastSpellRange 15
			if ${EpicMode}
				call CheckCures
		}
		elseif ${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Maintained[${SpellType[7]}].Target.ID}==${Actor[${MainTankPC}].ID}
			call CastSpellRange 7 0 0 0 ${MainTankID}

		if ${Me.Ability[${SpellType[7]}].IsReady} && ${EpicMode}
			call CastSpellRange 7 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<60 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
	{
		call CastSpellRange 1 0 0 0 ${MainTankID}
	}
}

function GroupHeal()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	call CastSpellRange 11

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	else
		call CastSpellRange 15
}

function EmergencyHeal(int healtarget)
{
	;death prevention
	if ${Me.Ability[${SpellType[316]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
		call CastSpellRange 316 0 0 0 ${healtarget}

	;emergency heals
	if ${Me.Ability[${SpellType[8]}].IsReady}
		call CastSpellRange 8 0 0 0 ${healtarget}
	else
		call CastSpellRange 16 0 0 0 ${healtarget}

}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead}
		return

	do
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 2
		}
		tmpcure:Inc
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
}

function CureMe()
{
	declare CureCnt int local 0

	if !${Me.IsAfflicted}
		return

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || !${Me.ToActor.IsRooted}
		call CastSpellRange 289

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	do
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}


		if ${Me.ToActor.Health}<30 && ${EpicMode}
			call HealMe
	}
	while (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0) && ${CureCnt:Inc}<5
}

function CheckCures()
{
	declare temphl int local 1
	declare grpcure int local 0

	grpcnt:Set[${Me.GroupCount}]

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount}>3
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Noxious}>0
				grpcure:Inc

			if ${Me.Elemental}>0
				grpcure:Inc
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<35
			{
				if ${Me.Group[${temphl}].Noxious}>0
					grpcure:Inc

				if ${Me.Group[${temphl}].Elemental}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc}<${grpcnt}

		;Use group cure if more than 3 afflictions will be removed
		if ${grpcure}>3
			call CastSpellRange 220
	}

	;Cure Ourselves first
	call CureMe

	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	do
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;epicmode is not set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;Check MT health and heal him if needed
		if ${Actor[pc,ExactName,${MainTankPC}].Health}<50
		{
			if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID}
				call HealMe
			else
				call HealMT
		}

		;check if we need heals
		call CheckGroupHealth 50
		if !${Return}
			break

	}
	while ${Me.ToActor.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
}

function FindAfflicted()
{
	declare temphl int local 1
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflicted int local 0

	;check for single target cures
	do
	{
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<35
		{
			if ${Me.Group[${temphl}].Arcane}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

			if ${Me.Group[${temphl}].Noxious}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]

			if ${Me.Group[${temphl}].Elemental}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]

			if ${Me.Group[${temphl}].Trauma}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

			if ${tmpafflictions}>${mostafflictions}
			{
				mostafflictions:Set[${tmpafflictions}]
				mostafflicted:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CheckHOTs()
{

	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]

	if ((${Me.InCombat} || ${Actor[exactname,${MainTankPC}].InCombatMode}) && (${KeepMTHOTUp} || ${KeepGroupHOTUp})) || (${KeepReactiveUp} && ${Me.ToActor.Power}>85)
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

	if ${KeepReactiveUp} && !${Me.Maintained[${SpellType[11]}](exists)}
		call CastSpellRange 11

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
		call CastSpellRange 300 303 1 0 ${MainTankPC} 1

}

function Cancel_Root()
{

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