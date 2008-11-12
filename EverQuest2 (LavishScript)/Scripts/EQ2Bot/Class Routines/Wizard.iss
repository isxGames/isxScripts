;*************************************************************
;Wizard.iss
;version 20070921a
;by Pygar
;
;20070921a
; New casting Order for better dps
;	Pet Use Toggle
;	Cure Use Toggle
; Removed Depricated Code
; Fixed some Spell Key assignments
;
;20070514a
; Fixed a combat spell key error preventing use of Immoliation line
;
;20061207a
; Added Crystalized Spirit
; Fixed AoE Checks
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
	declare BuffAccordShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffRadianceProc collection:string script
	declare BuffAmplify bool script FALSE
	declare BuffSeal bool script FALSE
	declare CastCures bool script FALSE
	declare PetMode bool script TRUE
	declare StartHO bool script FALSE

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	CastCures:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Cures,TRUE]}]
	BuffAccordShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Accord Shield,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffAmplify:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAmplify,,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	BuffSeal:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSeal,FALSE]}]

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

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		call CheckHeals
		call RefreshPower
	}


	
	; Do not remove/change
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

	PreAction[2]:Set[BuffAmplify]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[BuffSeal]
	PreSpellRange[3,1]:Set[20]

	PreAction[4]:Set[Tank_Buff]
	PreSpellRange[4,1]:Set[40]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[31]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[AA_Ward_Sages]
	PreSpellRange[7,1]:Set[386]
}

function Combat_Init()
{

	Action[1]:Set[AoE_Nuke2]
	SpellRange[1,1]:Set[91]

	Action[2]:Set[AoE_Nuke3]
	SpellRange[2,1]:Set[92]

	Action[3]:Set[AoE_PB3]
	SpellRange[3,1]:Set[96]

	Action[4]:Set[AoE_PB1]
	SpellRange[4,1]:Set[94]

	Action[5]:Set[AoE_PB2]
	SpellRange[5,1]:Set[95]

	Action[6]:Set[Combat_DS]
	MobHealth[6,1]:Set[30]
	MobHealth[6,2]:Set[100]
	SpellRange[6,1]:Set[355]

	Action[7]:Set[Dot1]
	MobHealth[7,1]:Set[20]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[70]

	Action[8]:Set[Dot4]
	MobHealth[8,1]:Set[20]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[73]

	Action[9]:Set[Nuke4]
	SpellRange[9,1]:Set[63]

	Action[10]:Set[Dot3]
	MobHealth[10,1]:Set[20]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[72]

	Action[11]:Set[Special_Pet]
	MobHealth[11,1]:Set[50]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[324]

	Action[12]:Set[Nuke4]
	SpellRange[12,1]:Set[63]

	Action[13]:Set[Stun1]
	SpellRange[13,1]:Set[181]

	Action[14]:Set[Nuke1]
	SpellRange[14,1]:Set[60]

	Action[15]:Set[Master_Strike]

	Action[15]:Set[Nuke4]
	SpellRange[15,1]:Set[63]

	Action[16]:Set[Nuke3]
	SpellRange[16,1]:Set[62]

	Action[17]:Set[Stun2]
	SpellRange[17,1]:Set[180]

	Action[18]:Set[Nuke2]
	SpellRange[18,1]:Set[61]

	Action[19]:Set[Dot2]
	MobHealth[19,1]:Set[20]
	MobHealth[19,2]:Set[100]
	SpellRange[19,1]:Set[71]

	Action[20]:Set[Nuke4]
	SpellRange[20,1]:Set[63]

	Action[21]:Set[AoE_Nuke1]
	SpellRange[21,1]:Set[90]

	Action[22]:Set[Debuff2]
	SpellRange[22,1]:Set[50]

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

	call CheckHeals
	call RefreshPower

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case BuffAmplify
			if ${BuffAmplify}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffSeal
			if ${BuffSeal}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Tank_Buff
			BuffTarget:Set[${UIElement[cbBuffAccordShieldGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
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
					if ${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case SeeInvis
			if ${BuffSeeInvis}
			{
				; If group see invis (Snow-Filled Steps) is available, use that.
				if ${Me.Ability[${SpellType[354]}](exists)}
				{
					if ${Me.Ability[${SpellType[354]}].IsReady}
						call CastSpellRange 354
					break
				}
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
		case AA_Ward_Sages
			if ${Me.Ability[${SpellType[355]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}

		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{

	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	if ${CureMode}
	{
		call CheckHeals
	}
	call RefreshPower
	call UseCrystallizedSpirit 60

	;Ice Nova if solo and over 50% or ^^^ and between 30 and 80.
	if ((${Actor[${KillTarget}].Difficulty}<3 && ${Actor[${KillTarget}].Health}>50) || (${Actor[${KillTarget}].Difficulty}==3 && ${Actor[${KillTarget}].Health}>30 && ${Actor[${KillTarget}].Health}<80)) && ${Me.Ability[${SpellType[60]}].IsReady}
	{
		if ${Me.Ability[${SpellType[385]}].IsReady}
		{
			call CastSpellRange 385
		}
		call CastSpellRange 60 0 0 0 ${KillTarget}
	}

	;maintain combat buffs
	if ${Me.Ability[${SpellType[360]}].IsReady}
	{
		call CastSpellRange 360
	}
	if ${Me.Ability[${SpellType[361]}].IsReady}
	{
		call CastSpellRange 361
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
		case AoE_PB1
		case AoE_PB2
		case AoE_PB3
			if ${PBAoEMode} && ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break
		case Debuff1
		case Debuff2
			if ${DebuffMode} && ${PBAoEMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case AoE_Nuke1
		case AoE_Nuke2
		case AoE_Nuke3
			if ${AoEMode} && ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case Master_Strike
			if ${Me.Ability[Master's Smite].IsReady}
			{
				Target ${KillTarget}
				Me.Ability[Master's Smite]:Use
			}
		case Dot1
		case Dot2
		case Dot3
		case Dot4
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
			}
			break
		case Combat_DS
		case Nuke2
		case Nuke4
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Nuke3
		case Nuke1
			if ${Me.Ability[${SpellType[385]}].IsReady}
			{
				call CastSpellRange 385
			}
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Stun1
		case Stun2
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Root
			break
		Default
			return Combat Complete
			break
	}

}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]
	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if ${Me.Ability[${SpellRange[181]}].IsReady}
	{
		call CastSpellRange 181
	}
	else
	{
		call CastSpellRange 180
	}

	if ${Me.Ability[${SpellRange[230]}].IsReady} && ${Actor[${aggroid}].Distance}<5 && !${avoidhate}
	{
		call CastSpellRange 230 0 0 0 ${Actor[${aggroid}].ID}
		press -hold ${backward}
		wait 3
		press -release ${backward}
		avoidhate:Set[TRUE]
		call CastSpellRange 50 0 0 0 ${Actor[${aggroid}].ID}
		call CastSpellRange 90 0 0 0 ${Actor[${aggroid}].ID}
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
		call UseItem "Spiritise Censer"

	;Conjuror Shard
	if ${Me.ToActor.Power}<70 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
		Me.Inventory[${ShardType}]:Use

	if ${Me.InCombat} && ${Me.ToActor.Power}<20
		call UseItem "Dracomancer Gloves"

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
		call UseItem "Stein of the Everling Lord"

	if ${Me.ToActor.Power}<85 && ${Me.ToActor.Health}>20 && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
		call CastSpellRange 309

	if ${Me.ToActor.Power}<5
		call CastSpellRange 310
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
			Target ${KillTarget}
	}

	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane}>0
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}](exists)}
				Target ${KillTarget}
		}
	}
	while ${temphl:Inc}<${grpcnt}

}

function PostDeathRoutine()
{	
	;; This function is called after a character has either revived or been rezzed
	
	return
}