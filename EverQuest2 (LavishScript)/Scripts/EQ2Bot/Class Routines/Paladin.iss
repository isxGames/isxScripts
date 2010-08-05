;*************************************************************
;Paladin.iss
;version 20090623
;
;20090623 (pygar)
;	Updated for GU52
;
;20061201
;	by Ownagejoo using all of Kayres Great scripts
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090623
	;;;;

	declare TauntMode bool script TRUE
	declare HealerMode bool script FALSE
	declare AoEMode bool script FALSE
	declare Start_HO bool script FALSE

	declare BuffProcGroupMember string script
	declare Secondary_Assist string script
	declare BuffAmendsGroupMember string script

	call EQ2BotLib_Init

	;XML Setup for clickbox options
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Taunt Mode,TRUE]}]
	HealerMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[HealerMode,FALSE]}]
	Start_HO:Set{${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start_HO,FALSE]}]
	Use_Consecrate:Set{${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use_Consecrate,FALSE]}]

	BuffProcGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProcGroupMember,]}]
	BuffAmendsGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAmendsGroupMember,]}]
	Secondary_Assist:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Secondary Assist,]}]
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

	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]}) && \
		${Me.Ability[${SpellType[155]}].IsReady} && \
		(!${Me.Maintained[${SpellType[155]}](exists)} || ${Me.Maintained[${SpellType[155]}].Duration} < ${Me.Ability[${SpellType[155]}].CastingTime})
	{
		;Debug:Echo["Casting PreWard"]
		call CastSpellRange 155 0 0 0 ${Actor[pc,exactname,${MainTankPC}].ID}
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	;; This has to be set WITHIN any 'if' block that uses the timer.
	;ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{
		 PreAction[1]:Set[Protect_Target]
		 PreSpellRange[1,1]:Set[30]

		 PreAction[2]:Set[Self_Buff]
		 PreSpellRange[2,1]:Set[25]
		 PreSpellRange[2,2]:Set[27]

		 PreAction[3]:Set[Group_Buff]
		 PreSpellRange[3,1]:Set[20]
		 PreSpellRange[3,2]:Set[21]

		 PreAction[4]:Set[SA_Buff]
		 PreSpellRange[4,1]:Set[386]

		 PreAction[5]:Set[AA_Leadership]
		 PreSpellRange[5,1]:Set[506]

		 PreAction[6]:Set[AA_Aura_Leadership]
		 PreSpellRange[6,1]:Set[507]

		 PreAction[7]:Set[AA_Fearless]
		 PreSpellRange[7,1]:Set[508]

		 PreAction[8]:Set[AA_Trample]
		 PreSpellRange[8,1]:Set[510]

		 PreAction[9]:Set[Amends]
		 PreSpellRange[9,1]:Set[35]
}

function Combat_Init()
{
		 Action[1]:Set[Taunt]
		 SpellRange[1,1]:Set[160]
		 SpellRange[1,2]:Set[161]

		 Action[2]:Set[AA_SwiftAxe]
		 SpellRange[2,1]:Set[389]

		 Action[3]:Set[Combat_Buff]
		 SpellRange[3,1]:Set[155]

		 Action[4]:Set[AoE_Taunt]
		 SpellRange[4,1]:Set[170]
		 SpellRange[4,2]:Set[171]

		 Action[5]:Set[Melee_Attack]
		 Power[5,1]:Set[25]
		 Power[5,2]:Set[100]
		 SpellRange[5,1]:Set[150]
		 SpellRange[5,2]:Set[154]

		 Action[6]:Set[Nuke_Attack]
		 Power[6,1]:Set[25]
		 Power[6,2]:Set[100]
		 SpellRange[6,1]:Set[60]
		 SpellRange[6,2]:Set[62]

		 Action[7]:Set[Two_Hand_Attack]
		 Power[7,1]:Set[25]
		 Power[7,2]:Set[100]
		 SpellRange[7,1]:Set[245]
		 SpellRange[7,2]:Set[247]

		 Action[8]:Set[Stun]
		 SpellRange[8,1]:Set[190]
		 SpellRange[8,2]:Set[192]

		 Action[9]:Set[Dot]
		 Power[9,1]:Set[50]
		 Power[9,2]:Set[100]
		 SpellRange[9,1]:Set[70]
		 SpellRange[9,2]:Set[72]

		 Action[10]:Set[AoE_All]
		 Power[10,1]:Set[25]
		 Power[10,2]:Set[100]
		 SpellRange[10,1]:Set[90]
		 SpellRange[10,2]:Set[96]

		 Action[11]:Set[Consencrate]
		 Power[11,1]:Set[25]
		 Power[11,2]:Set[100]
		 SpellRange[11,1]:Set[387]

		 Action[12]:Set[AA_SwiftAxe]
		 SpellRange[12,1]:Set[389]

		 Action[13]:Set[AA_LegionSmite]
		 SpellRange[13,1]:Set[501]

		 Action[14]:Set[AA_Joust]
		 SpellRange[14,1]:Set[509]

		 Action[15]:Set[AA_Lance]
		 SpellRange[15,1]:Set[511]

		 Action[16]:Set[AA_Smite_Evil]
		 SpellRange[16,1]:Set[515]

		 Action[17]:Set[AA_Doom_Judgement]
		 SpellRange[17,1]:Set[522]

		 Action[18]:Set[AA_Hammer_Ground]
		 SpellRange[18,1]:Set[524]
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare BuffMember string local
	declare BuffTarget string local

	if ${ShardMode}
		call Shard

	switch ${PreAction[${xAction}]}
	{
		case Amends
			BuffTarget:Set[${UIElement[cbBuffAmendsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case Protect_Target
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case AA_Trample
		case AA_Fearless
		case AA_Aura_Leadership
		case AA_Leadership
			if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case SA_Buff
			if !${MainTank}
			{
				BuffTarget:Set[${UIElement[cbSecondary_Assist@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					;Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				break
			}
			else
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			break

		default
		    return BuffComplete
	 }
}

function Combat_Routine(int xAction)
{
	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	call CommonHeals 70

	call MeHeals

	if ${HealerMode}
		call CheckHeals

	if ${DoHOs}
		objHeroicOp:DoHO

	;echo ${Start_HO}
	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${Start_HO}
		call CastSpellRange 303

	;group proc buff, always use if avail
	if ${Me.Ability[${SpellType[505]}].IsReady}
		call CastSpellRange 505 0 0 0 ${KillTarget}

	;Spell / CA Stoneskin  use if avail
	if ${Me.Ability[${SpellType[512]}].IsReady}
		call CastSpellRange 512 0 0 0 ${KillTarget}

	;use Castigate or Aura Self Cure
	if ${Me.IsAfflicted}
	{
		if ${AoEMode} && ${Me.Ability[${SpellType[523]}].IsReady}
			call CastSpellRange 523
		elseif ${Me.Ability[${SpellType[517]}].IsReady}
			call CastSpellRange 517
	}

	;use block
	if ${Me.ToActor.Health}<50 && ${Me.Ability[${SpellType[518]}].IsReady}
		call CastSpellRange 518

	;use cry if tank
	if ${TauntMode} && ${Me.Ability[${SpellType[519]}].IsReady}
		call CastSpellRange 519

	;use block
	if ${Me.ToActor.Health}<20 && ${Me.Ability[${SpellType[521]}].IsReady}
		call CastSpellRange 521

	switch ${Action[${xAction}]}
	{
		case Stun
		case Taunt
			if ${MainTank} && ${TauntMode}
			    call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
		case AoE_Taunt
		    if ${MainTank} && ${TauntMode}
			{
	    		if ${Mob.Count}>1
				    call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break
		case AoE_All
		case AA_Hammer_Ground
		case AA_Doom_Judgement
		case AA_Smite_Evil
			if ${AoEMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Combat_Buff
		case AA_Lance
		case AA_Joust
		case AA_LegionSmite
		case AA_SwiftAxe
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break

		case Melee_Attack
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case Two_Hand_Attack
			if ${Me.Equipment[primary].WieldStyle.Equal[Two-Handed]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
                    call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Nuke_Attack
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			    call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

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
	}
}

function Have_Aggro()
{
	if ${Me.AutoAttackOn}
	    EQ2Execute /toggleautoattack

	if !${homepoint}
	    return

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
	    if ${Return}<3
	    {
    		press -hold ${backward}
    		wait 3
    		press -release ${backward}
    		avoidhate:Set[TRUE]
	    }
	}
}

function Lost_Aggro(int mobid)
{
	if ${Me.Ability[${SpellType[525]}].IsReady}
    call CastSpellRange 525 0 0 0 ${mobid}
	elseif ${Me.Ability[${SpellType[516]}].IsReady}
    call CastSpellRange 516 0 0 0 ${mobid}
	elseif ${Me.Ability[${SpellType[161]}].IsReady}
    call CastSpellRange 161 0 0 0 ${mobid}
	elseif ${Me.Ability[${SpellType[526]}].IsReady}
    call CastSpellRange 526 0 0 0 ${mobid}

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
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0


	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal[${Zone.Name}]}
		{

			if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}](exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health}
					lowest:Set[${temphl}]
			}

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<80
				grpheal:Inc

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
			}
		}

	}
	while ${temphl:Inc} <= ${Me.GroupCount}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
		grpheal:Inc

	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainAssist}]} && ${Me.Group[${lowest}].ToActor(exists)}
		call EmergencyHeal ${Actor[${MainAssist}].ID}

	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<50
		{
			if ${haveaggro}
				call EmergencyHeal ${Me.ID}
			else
			{
				if ${Me.Ability[${SpellType[513]}].IsReady}
					call CastSpellRange 513 0 0 0 ${Me.ID}
				elseif ${Me.Ability[${SpellType[1]}].IsReady}
					call CastSpellRange 1 0 0 0 ${Me.ID}
				else
					call CastSpellRange 4 0 0 0 ${Me.ID}
			}
		}

	}
	;MAINTANK HEALS
	if ${Actor[${MainAssist}].Health} <90 && ${Actor[${MainAssist}].Health} >-99 && ${Actor[${MainAssist}](exists)}
		call CastSpellRange 4 0 0 0 ${Actor[${MainAssist}].ID}

	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
			call CastSpellRange 10
	}

	if ${Me.Group[${lowest}].ToActor.Health}<80 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[513]}].IsReady} && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
			call CastSpellRange 513 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		elseif ${Me.Ability[${SpellType[1]}].IsReady} && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		elseif && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}

	}
}

function MeHeals()
{
	if ${Me.ToActor.Health}<50
	{
		if ${Me.ToActor.Health}<25
			call EmergencyHeal ${Me.ID}

		if ${Me.Ability[${SpellType[513]}].IsReady}
			call CastSpellRange 513 0 0 0 ${Me.ID}
		elseif ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${Me.ID}
		else
			call CastSpellRange 4 0 0 0 ${Me.ID}
	}
}

function EmergencyHeal(int healtarget)
{
	if ${Me.Ability[${SpellType[387]}].IsReady}
		call CastSpellRange 387 0 0 0 ${healtarget}
	else
		call CastSpellRange 1 0 0 0 ${healtarget}
}



function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}
