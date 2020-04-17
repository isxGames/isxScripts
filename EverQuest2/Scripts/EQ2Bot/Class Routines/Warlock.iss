;*************************************************************
;Warlock.iss
;version 20090622a
;by Pygar
;
;20090622
;	Updated for TSO and GU52
;
;20080415a
; DPS Tweaks
;
;20071004a
; Weaponswap entirely removed
; DebuffMode Added
; DotMode Added
; Significant dps tweeks
;
;20061012a
; Initial Build
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090622
	;;;;

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare DebuffMode bool script FALSE
	declare DoTMode bool script TRUE
	declare BuffVielShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffVenemousProc collection:string script
	declare BuffBoon bool script FALSE
	declare BuffPact bool script FALSE
	declare PetMode bool script 1
	declare CastCures bool script FALSE
	declare StartHO bool script FALSE
	declare FocusMode bool script TRUE
	declare PetForm int script 1

	;Custom Equipment
	declare PoisonCureItem string script

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	DoTMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast DoT Spells,TRUE]}]
	BuffVielShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Veil Shield,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffBoon:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffBoon,,FALSE]}]
	BuffPact:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffPact,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	CastCures:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Cures,TRUE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	FocusMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Focused Casting,TRUE]}]
	PetForm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PetForm,]}]

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
	ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[26]
	PreSpellRange[1,3]:Set[27]

	PreAction[2]:Set[BuffBoon]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[BuffPact]
	PreSpellRange[3,1]:Set[20]

	PreAction[4]:Set[Tank_Buff]
	PreSpellRange[4,1]:Set[40]
	PreSpellRange[4,2]:Set[41]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[31]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[AA_Ward_Sages]
	PreSpellRange[7,1]:Set[386]

	PreAction[8]:Set[AA_Pet]
	PreSpellRange[8,1]:Set[382]
	PreSpellRange[8,2]:Set[383]
	PreSpellRange[8,3]:Set[384]

	PreAction[9]:Set[DeityPet]

}

function Combat_Init()
{
	Action[1]:Set[AoE_Debuff1]
	SpellRange[1,1]:Set[57]

	Action[2]:Set[Special_Pet]
	MobHealth[2,1]:Set[60]
	MobHealth[2,2]:Set[100]
	SpellRange[2,1]:Set[324]

	Action[3]:Set[Void]
	SpellRange[3,1]:Set[50]

	Action[5]:Set[Combat_Buff]
	MobHealth[5,1]:Set[50]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[330]

	Action[6]:Set[DoT1]
	SpellRange[6,1]:Set[70]

	Action[7]:Set[AoE_DoT]
	MobHealth[7,1]:Set[30]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[94]

	;AOE ONLY
	Action[8]:Set[AoE_Nuke1]
	SpellRange[8,1]:Set[91]

	;AOE ONLY
	Action[9]:Set[AoE_PB]
	SpellRange[9,1]:Set[95]

	;AOE ONLY
	Action[10]:Set[Nullify]
	SpellRange[10,1]:Set[181]

	;AOE ONLY
	Action[11]:Set[Caress]
	SpellRange[11,1]:Set[180]

	;AOE ONLY
	Action[12]:Set[AoE_PB2]
	SpellRange[12,1]:Set[96]

	;AOE ONLY
	Action[13]:Set[AoE_PB]
	SpellRange[13,1]:Set[95]

	;AOE ONLY
	Action[14]:Set[AoE_Concussive]
	SpellRange[14,1]:Set[328]

	;AOE ONLY
	Action[15]:Set[Void]
	SpellRange[15,1]:Set[50]

	;AOE ONLY and more than 2
	Action[16]:Set[AoE_Nuke2]
	SpellRange[16,3]:Set[92]

	;AOE ONLY
	Action[17]:Set[AoE_PB]
	SpellRange[17,1]:Set[95]

	Action[18]:Set[Master_Strike]

	Action[19]:Set[Nuke1]
	SpellRange[19,1]:Set[61]

	Action[20]:Set[DoT2]
	SpellRange[20,1]:Set[71]

	Action[21]:Set[DoT3]
	SpellRange[21,1]:Set[72]

	Action[22]:Set[Nuke2]
	SpellRange[22,1]:Set[62]

	Action[23]:Set[Nuke3]
	SpellRange[23,1]:Set[64]

	Action[24]:Set[Nuke4]
	SpellRange[24,1]:Set[63]

	Action[25]:Set[Nuke2]
	SpellRange[25,1]:Set[62]

	Action[26]:Set[Nuke3]
	SpellRange[26,1]:Set[64]

	Action[27]:Set[Nuke4]
	SpellRange[27,1]:Set[63]

	Action[28]:Set[Nuke2]
	SpellRange[28,1]:Set[62]

	Action[29]:Set[Nuke3]
	SpellRange[29,1]:Set[64]

	Action[30]:Set[Nuke4]
	SpellRange[30,1]:Set[63]

	Action[31]:Set[Nuke2]
	SpellRange[31,1]:Set[62]

	Action[32]:Set[Nuke3]
	SpellRange[32,1]:Set[64]

	Action[33]:Set[Nuke4]
	SpellRange[33,1]:Set[63]

}

function PostCombat_Init()
{

	PostAction[1]:Set[AutoFollowTank]
	avoidhate:Set[FALSE]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	call CheckHeals
	call RefreshPower

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case BuffBoon
			if ${BuffBoon}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffPact
			if ${BuffPact}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Tank_Buff
			BuffTarget:Set[${UIElement[cbBuffVielShieldGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}]:Cancel
			}

			if ${BuffVielShield}
			{

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
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
					if ${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffVenemousProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case SeeInvis
			if ${BuffSeeInvis}
			{
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}

				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ID}
					}

				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case AA_Ward_Sages
			if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case AA_Pet
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${PetForm}]}
			}
			break
		case DeityPet
			call SummonDeityPet
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare dotused int local 0
	declare debuffused int local 0
	declare pricast int local 0

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoHOs}
		objHeroicOp:DoHO

	if ${StartHO} && !${EQ2.HOWindowActive} && ${Me.InCombat} && ${Me.Ability[${SpellType[303]}].IsReady}
		Me.Ability[${SpellType[303]}]:Use

	if ${CastCures}
		call CheckHeals

	call UseCrystallizedSpirit 60

	;---- Debuffs if they are selected ----
	if ${DebuffMode}
	{
		if ${Me.Ability[${SpellType[57]}].IsReady} && !${Me.Maintained[${SpellType[57]}](exists)}
		{
			call CastSpellRange 57 0 0 0 ${KillTarget}
			debuffused:Inc
			pricast:Inc
		}
		if !${debuffused} && ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)}
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			debuffused:Inc
			pricast:Inc
		}

		if !${debuffused} && ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)}
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			debuffused:Inc
			pricast:Inc
		}
		if ${Me.Ability[${SpellType[389]}].IsReady} && !${Me.Maintained[${SpellType[389]}](exists)}
		{
			call CastSpellRange 389 0 0 0 ${KillTarget}
			pricast:Inc
		}
	}


	;---- Short Term Buffs ----
	if ${Me.Ability[${SpellType[330]}].IsReady}
	{
		call CastSpellRange 330 0 0 0 ${KillTarget}
		pricast:Inc
	}


	;---- Heroic or better Short Term Buffs
	if ${Actor[${KillTarget}].Difficulty}>=3
	{
		;--- Focused Casting AA
		if ${FocusMode} && ${Me.Ability[${SpellType[387]}].IsReady}
			Me.Ability[${SpellType[387]}]:Use

		;--- Fury of Innoruk
		if ${Me.Ability[${SpellType[Fury of Innoruuk]}].IsReady}
			Me.Ability[${SpellType[Fury of Innoruuk]}]:Use

		if ${Me.Ability[${SpellType[55]}].IsReady} && ${pricast}<3 && !${Me.Maintained[${SpellType[55]}](exists)}
		{
			call CastSpellRange 55 0 0 0 ${KillTarget}
			pricast:Inc
		}
	}

	if ${pricast}>=3
		return

	;---- DPS Utility Spells ----
	;-------- Aura of Void
	if ${Me.Ability[${SpellType[50]}].IsReady} && ${pricast}<3 && !${Me.Maintained[${SpellType[50]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 50 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Nullify
	if ${Me.Ability[${SpellType[181]}].IsReady} && ${pricast}<3 && !${Me.Maintained[${SpellType[181]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 181 0 0 0 ${KillTarget}
		pricast:Inc
	}

	if ${pricast}>=3
		return

	;---- PBAoE's
	if ${PBAoEMode} && ${Mob.Count}>1
	{
		;-------- Upheaval
		if ${PBAoEMode} && ${pricast}<3 && ${Me.Ability[${SpellType[96]}].IsReady} && !${Me.Maintained[${SpellType[96]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 96 0 0 0 ${KillTarget}
			pricast:Inc
		}
		;-------- Acid Storm
		if ${PBAoEMode} && ${pricast}<3 && ${Mob.Count}>1 && ${Me.Ability[${SpellType[97]}].IsReady} && !${Me.Maintained[${SpellType[97]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 97 0 0 0 ${KillTarget}
			pricast:Inc
		}
		;-------- Cataclysm
		if ${PBAoEMode} && ${pricast}<3 && ${Mob.Count}>1 && ${Me.Ability[${SpellType[95]}].IsReady} && !${Me.Maintained[${SpellType[95]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 95 0 0 0 ${KillTarget}
			pricast:Inc
		}
		;-------- Static Discharge
		if ${PBAoEMode} && ${pricast}<3 && ${Mob.Count}>1 && ${Me.Ability[${SpellType[397]}].IsReady} && !${Me.Maintained[${SpellType[397]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 397 0 0 0 ${KillTarget}
			pricast:Inc
		}
	}

	if ${pricast}>=3
		return

	;---- Single Target Dots If enabled
	if ${DoTMode}
	{
		;-------- Netherbeast
		if ${pricast}<3 && ${Me.Ability[${SpellType[324]}].IsReady} && !${Me.Maintained[${SpellType[324]}](exists)} && ${Mob.CheckActor[${KillTarget}]} && ${PetMode}
		{
			call CastSpellRange 324 0 0 0 ${KillTarget}
			pricast:Inc
		}
		;-------- Blood Infestation
		if ${pricast}<3 && ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 70 0 0 0 ${KillTarget}
			pricast:Inc
		}
		;-------- Acid
		if ${pricast}<3 && ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[72]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 72 0 0 0 ${KillTarget}
			pricast:Inc
		}
	}

	if ${pricast}>=3
		return

	;---- Standard Spell order
	;-------- Armegeddon
	if ${pricast}<3 && ${Me.Ability[${SpellType[94]}].IsReady} && !${Me.Maintained[${SpellType[94]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 94 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Absolution
	if ${pricast}<3 && ${Me.Ability[${SpellType[91]}].IsReady} && !${Me.Maintained[${SpellType[91]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 91 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Concussive
	if ${pricast}<3 && ${Me.Ability[${SpellType[393]}].IsReady} && !${Me.Maintained[${SpellType[393]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 393 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Radiation
	if ${pricast}<3 && ${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 92 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Plaguebringer
	if ${pricast}<3 && ${Me.Ability[${SpellType[401]}].IsReady} && !${Me.Maintained[${SpellType[401]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 401 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Flames of Velious
	if ${pricast}<3 && ${Me.Ability[${SpellType[64]}].IsReady} && !${Me.Maintained[${SpellType[64]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 64 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Distortion
	if ${pricast}<3 && ${Me.Ability[${SpellType[61]}].IsReady} && !${Me.Maintained[${SpellType[61]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 61 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Bewilderment
	if ${pricast}<3 && ${Me.Ability[${SpellType[403]}].IsReady} && !${Me.Maintained[${SpellType[403]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 403 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Encase
	if ${pricast}<3 && ${Me.Ability[${SpellType[62]}].IsReady} && !${Me.Maintained[${SpellType[62]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 62 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Thunderclap
	if ${pricast}<3 && ${Me.Ability[${SpellType[402]}].IsReady} && !${Me.Maintained[${SpellType[402]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 402 0 0 0 ${KillTarget}
		pricast:Inc
	}
	;-------- Dissolve
	if ${pricast}<3 && ${Me.Ability[${SpellType[63]}].IsReady} && !${Me.Maintained[${SpellType[63]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 63 0 0 0 ${KillTarget}
		pricast:Inc
	}

	if ${pricast}>=3
		return

	call RefreshPower

}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	if ${Me.Maintained[${SpellType[387]}](exists)}
		Me.Maintained[${SpellType[387]}]:Cancel

	switch ${PostAction[${xAction}]}
	{
        case AutoFollowTank
         	if ${AutoFollowMode}
         	{
         		ExecuteAtom AutoFollowTank
         	}
         	break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if ${Me.Ability[${SpellRange[328]}].IsReady}
	{
		call CastSpellRange 328 0 0 0 ${Actor[${aggroid}].ID}
		return
	}

	if ${Me.Ability[${SpellRange[181]}].IsReady}
	{
		call CastSpellRange 180 0 0 0 ${Actor[${aggroid}].ID}
	}
	else
	{
		call CastSpellRange 181 0 0 0 ${Actor[${aggroid}].ID}
	}

	if ${Me.Ability[${SpellRange[231]}].IsReady}
	{
		call CastSpellRange 231 0 0 0 ${Actor[${aggroid}].ID}
	}
	else
	{
		call CastSpellRange 230 0 0 0 ${Actor[${aggroid}].ID}
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
		press -hold ${backward}
		wait 3
		press -release ${backward}
		avoidhate:Set[TRUE]
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

}

function Cancel_Root()
{

}

function RefreshPower()
{
	if ${ShardMode}
		call Shard

	if ${Me.InCombat} && ${Me.Power}<60
		call CastSpellRange 56 0 0 0 ${KillTarget}


	if ${Me.InCombat} && ${Me.Power}<5
		call CastSpellRange 309

	;This should be cast on ally?
	;if ${Me.InCombat} && ${Me.Power}<15
	;{
	;	call CastSpellRange 333
	;}
}

function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	; Cure Arcane Me
	if ${Me.Arcane}>0
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}

		if ${Actor[${KillTarget}].Name(exists)}
		{
			Target ${KillTarget}
		}
	}

	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane}>0 && ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].Health(exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}].Name(exists)}
			{
				Target ${KillTarget}
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}

}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}