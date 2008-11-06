;*************************************************************
;Warlock.iss
;version 20080415a
;by Pygar
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
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 20080408
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

	;Custom Equipment
	declare PoisonCureItem string script

	call EQ2BotLib_Init

	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	DoTMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast DoT Spells,TRUE]}]
	BuffVielShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Veil Shield,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffBoon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBoon,,FALSE]}]
	BuffPact:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPact,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]
	CastCures:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Cures,TRUE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	FocusMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Focused Casting,TRUE]}]
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

	Action[4]:Set[AoE_Debuff3]
	SpellRange[4,1]:Set[55]

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

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 5
	}

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

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
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


	AutoFollowingMA:Set[FALSE]

	;Actions 8-17 are for encounters only, we want to skip them if solo mobs.
	if ${xAction}>7 && ${Mob.Count}==1 && ${Target.EncounterSize}==1
	{
		xAction:Inc[10]
	}
	else
	{
		if ${xAction}>18
		{
			return Combat Complete
		}
	}

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if ${StartHO} && !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	if ${CastCures}
	{
		call CheckHeals
	}

	if ${FocusMode} && ${Me.Ability[${SpellType[387]}].IsReady}
	{
		call CastSpellRange 387 0 0 0 ${KillTarget}
	}

	;Ice if solo  or ^^^ and between 30 and 80.
	if ((${Actor[${KillTarget}].Difficulty}<3) || (${Actor[${KillTarget}].Difficulty}==3 && ${Actor[${KillTarget}].Health}>30 && ${Actor[${KillTarget}].Health}<80))
	{
		;Encounter Priority
		if ${Actor[${KillTarget}].EncounterSize}>1 && ${Mob.Count}>1
		{
			if ${Me.Ability[${SpellType[97]}].IsReady}
			{
				call CastSpellRange 97 0 0 0 ${KillTarget}
				pricast:Inc
			}
			if ${Me.Ability[${SpellType[330]}].IsReady}
			{
				call CastSpellRange 330 0 0 0 ${KillTarget}
				pricast:Inc
			}
			if ${Me.Ability[${SpellType[91]}].IsReady} && ${pricast}<2
			{
				call CastSpellRange 385
				call CastSpellRange 91 0 0 0 ${KillTarget}
				pricast:Inc
			}
			if ${Me.Ability[${SpellType[92]}].IsReady} && ${pricast}<2
			{
				call CastSpellRange 385
				call CastSpellRange 92 0 0 0 ${KillTarget}
				pricast:Inc
			}
		}
		else
		{
			if ${Me.Ability[${SpellType[61]}].IsReady}
			{
				call CastSpellRange 61 0 0 0 ${KillTarget}
				pricast:Inc
			}
			if ${Me.Ability[${SpellType[63]}].IsReady}
			{
				call CastSpellRange 385
				call CastSpellRange 63 0 0 0 ${KillTarget}
				pricast:Inc
			}
			if ${Me.Ability[${SpellType[62]}].IsReady} && ${pricast}<2
			{
				call CastSpellRange 62 0 0 0 ${KillTarget}
				pricast:Inc
			}
		}
	}

	call UseCrystallizedSpirit 60
	call RefreshPower

	if ${DebuffMode}
	{
		if ${Me.Ability[${SpellType[57]}].IsReady} && !${Me.Maintained[${SpellType[57]}](exists)}
		{
			call CastSpellRange 57 0 0 0 ${KillTarget}
			debuffused:Inc
		}

		if ${Me.Ability[${SpellType[50]}].IsReady} && !${debuffused} && !${Me.Maintained[${SpellType[50]}](exists)}
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
			debuffused:Inc
		}

		if ${Me.Ability[${SpellType[51]}].IsReady} && !${debuffused} && !${Me.Maintained[${SpellType[51]}](exists)}
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			debuffused:Inc
		}

		if ${Me.Ability[${SpellType[52]}].IsReady} && !${debuffused} && !${Me.Maintained[${SpellType[52]}](exists)}
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			debuffused:Inc
		}
	}

	if ${DotMode} && ${xAction}>17
	{
		if ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)}
		{
			call CastSpellRange 70 0 0 0 ${KillTarget}
			dotused:Inc
		}

		if ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)} && !${dotused}
		{
			call CastSpellRange 71 0 0 0 ${KillTarget}
			dotused:Inc
		}

		if ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)} && !${dotused}
		{
			call CastSpellRange 72 0 0 0 ${KillTarget}
			dotused:Inc
		}
	}

	switch ${Action[${xAction}]}
	{

		case Special_Pet
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} && ${PetMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case AoE_PB
		case AoE_PB2
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		case Nuke1
			if ${Me.Ability[${SpellType[385]}].IsReady}
			{
				call CastSpellRange 385
			}
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case DoT1
		case DoT2
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case Void
		case Nuke2
		case Nuke3
		case Nuke4
		case AoE_Debuff1
		case AoE_Debuff3
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break

		case Nullify
		case Caress
		case AoE_Concussive
		case AoE_Debuff2
			if ${AoEMode} && ${Mob.Count}>1 && ${Target.EncounterSize}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case AoE_DoT
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} || ${Actor[${KillTarget}].IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 4
			}
			break

		case Combat_Buff
		case Apoc
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]} || ${Actor[${KillTarget}].IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 4
			}
			break

		case AoE_Nuke1
			if ${Mob.Count}>1 && ${Target.EncounterSize}>1 && ${AoEMode}
			{
				if ${Me.Ability[${SpellType[385]}].IsReady}
				{
					call CastSpellRange 385
				}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case AoE_Nuke2
			if ${Mob.Count}>1 && ${Target.EncounterSize}>1 && ${AoEMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case Master_Strike
	    ;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
	    ;;;;;;;;;;
	    if (${InvalidMasteryTargets.Element[${Target.ID}](exists)})
	        break
	    ;;;;;;;;;;;
			if ${Me.Ability[Master's Smite].IsReady}
			{
				Me.Ability[Master's Smite]:Use
			}
			break

		case Concussive
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break

		case Root
		case AoE_Root
			break
		Default
			return CombatComplete
			break
	}

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

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<20
	{
		call UseItem "Dracomancer Gloves"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call CastSpellRange 309
	}

	;This should be cast on ally?
	;if ${Me.InCombat} && ${Me.ToActor.Power}<15
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

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}

	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane}>0 && ${Me.Group[${temphl}].ToActor(exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}](exists)}
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