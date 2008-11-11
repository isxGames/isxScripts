;*************************************************************
;Conjuror.iss
;version 20070725a
;various fixes
;by karye
;updated by pygar
;
;20070725a
; Updated for new AA changes
;
;20070504a
; Toggle PetMode
;
;20070404a
;	updated for latest eq2bot
;	updated master strike
;
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 20080408
    ;;;;

	declare PetType int script
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffDamageShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffEmberSeed collection:string script
	declare BuffSeal bool script FALSE
	declare BuffEscutcheon bool script FALSE
	declare BuffCabalistCover bool script TRUE
	declare PetMode bool script 1
	declare PetDefStance bool script 1

	declare ShardQueue queue:string script
	declare ShardRequestTimer int script ${Time.Timestamp}
	declare ShardType string script

	call EQ2BotLib_Init

	PetType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Pet Type,3]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	BuffDamageShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Damage Shield,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffEscutcheon:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEscutcheon,,FALSE]}]
	BuffSeal:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSeal,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	PetDefStance:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PetDefStance,TRUE]}]

	switch ${SpellType[360]}
	{
		case Splinter of Essence
		case Sliver of Essence
			ShardType:Set["Sliver of Essence"]
			break

		case Shard of Essence
			ShardType:Set["Shard of Essence"]
			break

		case Scintilla of Essence
			ShardType:Set["Scintilla of Essence"]
			break

		case Scale of Essence
			ShardType:Set["Scale of Essence"]
			break
	}
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
		;check if we have a pet or a hydromancy not up
		if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[379]}](exists)} && ${PetMode}
		{
			call SummonPet
			waitframe
		}
	
		call CheckHeals
		call RefreshPower
		call AnswerShardRequest
	}

	
	; Do not remove/change
	ClassPulseTimer:Set[${Script.RunningTime}]
}
function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[AA_Cabalists_Cover]
	PreSpellRange[1,1]:Set[384]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[Pet_Buff]
	PreSpellRange[3,1]:Set[45]

	PreAction[4]:Set[Tank_Buff]
	PreSpellRange[4,1]:Set[40]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[35]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[Buff_Shards]
	PreSpellRange[7,1]:Set[360]

	PreAction[8]:Set[AA_Minions_Warding]
	PreSpellRange[8,1]:Set[385]

	PreAction[9]:Set[Seal]
	PreSpellRange[9,1]:Set[20]

	PreAction[10]:Set[Escutcheon]
	PreSpellRange[10,1]:Set[21]

	PreAction[11]:Set[AA_Bubble]
	PreSpellRange[11,1]:Set[377]

	PreAction[12]:Set[AA_Unabate]
	PreSpellRange[12,1]:Set[376]
}

function Combat_Init()
{
	Action[1]:Set[Combat_Buff]
	MobHealth[1,1]:Set[1]
	MobHealth[1,2]:Set[100]
	SpellRange[1,1]:Set[397]

	Action[2]:Set[Dot1]
	SpellRange[2,1]:Set[73]

	Action[3]:Set[Converge]
	MobHealth[3,1]:Set[30]
	MobHealth[3,2]:Set[100]
	SpellRange[3,1]:Set[375]

	Action[4]:Set[Plane_Shift]
	SpellRange[4,1]:Set[399]

	Action[5]:Set[Special_Pet1]
	MobHealth[5,1]:Set[30]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[329]

	Action[6]:Set[AoE1]
	SpellRange[6,1]:Set[90]

	Action[7]:Set[Special_Pet2]
	MobHealth[7,1]:Set[30]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[330]

	Action[8]:Set[Nuke]
	MobHealth[8,1]:Set[0]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[61]

	Action[9]:Set[AoE_PB]
	SpellRange[9,1]:Set[95]

	Action[10]:Set[AoE2]
	SpellRange[10,1]:Set[91]

	Action[11]:Set[Sunbolt]
	SpellRange[11,1]:Set[62]

	Action[12]:Set[Master_Strike]

	Action[13]:Set[Stun]
	SpellRange[13,1]:Set[190]

	Action[14]:Set[AA_Animated_Dagger]
	MobHealth[14,1]:Set[30]
	MobHealth[14,2]:Set[100]
	SpellRange[14,1]:Set[380]

	Action[15]:Set[Dot2]
	MobHealth[15,1]:Set[20]
	MobHealth[15,2]:Set[100]
	SpellRange[15,1]:Set[72]

	Action[16]:Set[Special_Pet3]
	MobHealth[16,1]:Set[20]
	MobHealth[16,2]:Set[100]
	SpellRange[16,1]:Set[331]

}

function PostCombat_Init()
{
	PostAction[1]:Set[AA_Possessed_Minion]
	PostSpellRange[1,1]:Set[398]

}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	;check if we have a pet or a hydromancy not up
	if !${Me.ToActor.Pet(exists)} && !${Me.Maintained[${SpellType[379]}](exists)} && ${PetMode}
	{
		call SummonPet
		waitframe
	}

	call CheckHeals
	call RefreshPower
	call AnswerShardRequest

	switch ${PreAction[${xAction}]}
	{
		case AA_Minions_Warding
		case AA_Cabalists_Cover
			if ${BuffCabalistCover} && !${Me.Maintained[${SpellType[379]}](exists)}
			{

				call CastSpellRange ${PreSpellRange[${xAction},1]}
				BuffCabalistCover:Set[FALSE]
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Seal
			if ${BuffSeal}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Escutcheon
			if ${BuffEscutcheon}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case AA_Unabate
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Pet_Buff
		case AA_Bubble
			if ${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[379]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		case Tank_Buff
			BuffTarget:Set[${UIElement[cbBuffDamageShieldGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${BuffDamageShield}
			{

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
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
					if ${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffEmberSeed@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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

		case Buff_Shards
			if !${Me.Inventory[${ShardType}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			}

			if ${Me.Inventory["Shard of Essence"](exists)}
			{
				ShardType:Set[Shard of Essence]
			}
			elseif ${Me.Inventory["Sliver of Essence"](exists)}
			{
				ShardType:Set[Sliver of Essence]
			}
			elseif  ${Me.Inventory["Scintilla of Essence"](exists)}
			{
				ShardType:Set[Scintilla of Essence]
			}
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{

	variable int Counter

	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	;check if we have a pet or a hydromancy not up
	if !${Me.ToActor.Pet(exists)} || !${Me.Maintained[${SpellType[379]}](exists)} && ${PetMode}
	{
		call SummonPet
	}

	if ${Me.ToActor.Pet(exists)} && ${PetMode}
	{
		call PetAttack
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}


	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	call CheckHeals
	call RefreshPower
	;call AnswerShardRequest

	;keep blazing Avatar up at all times
	if ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 71
	}

	;keep distracting strike up if we have a scout pet
	if ${Me.Maintained[${SpellType[355]}](exists)}
	{
		call CastSpellRange 383
	}

	;keep  Magic Leash up if we have a mage pet
	if ${Me.Maintained[${SpellType[356]}](exists)}
	{
		call CastSpellRange 397
	}

	if ${Me.Ability[${SpellType[60]}].IsReady}
	{
		call CastSpellRange 60 0 0 0 ${KillTarget}
	}

	switch ${Action[${xAction}]}
	{
		case Special_Pet2
			if ${AoEMode} && ${PetMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case converge
		case Special_Pet3
		case Special_Pet1
		case AA_Animated_Dagger
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if (${Return.Equal[OK]} || ${Actor[${KillTarget}].IsEpic}) && ${PetMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case Plane_Shift
			if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case AoE_PB
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break

		case Combat_Buff
		case AoE1
			if ${AoEMode} && (${Me.ToActor.Pet(exists)} || ${Me.Maintained[${SpellType[379]}](exists)})
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

			}
			break

		case AoE2
			if ${AoEMode}
			{
				if ${Mob.Count}>1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case Dot2
		case Nuke
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case Blazing_Avatar
			call CastSpellRange ${PostSpellRange[${xAction},1]}
			break
		case Master_Strike
			if ${Me.Ability[Master Strike].IsReady} && ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
				Me.Ability[Master Strike]:Use
			}
			break
		case Sunbolt
		case Dot1
		case Nuke_Attack
		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		Default
			return CombatComplete
			break
	}

}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	switch ${PostAction[${xAction}]}
	{

		case AA_Possessed_Minion
			;check if we are possessed minion and cancel
			if ${Me.Race.Equal[Unknown]}
			{
				Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
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
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	;Buff Stoneskin
	call CastSpellRange 180
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

	;Blazing Vigor line out of Combat
	if ${Me.ToActor.Pet.Health}>60 && ${Me.ToActor.Power}<70 && !${Me.ToActor.Pet.IsAggro}
	{
			call CastSpellRange 309
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}

	;Conjuror Shard
	if ${Me.Power}<40 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
	{
		Me.Inventory[${ShardType}]:Use
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<20
	{
		call UseItem "Dracomancer Gloves"
	}

	;Blazing Vigor Line in Combat
	if ${Me.ToActor.Pet.Health}>50 && ${Me.ToActor.Power}<20
	{
			call CastSpellRange 309
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

}

function CheckHeals()
{

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
	;================================
	;= Animist Transference Check
	;================================
	;Check ME first,
	if ${Me.ToActor.Health}<60
	{
		call CastSpellRange 396 0 0 0 ${Me.ToActor.ID}
		;stoneskins AA
		call CastSpellRange 378

		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}

;	do
;	{
;			; Cure Arcane
;			if ${Me.Group[${temphl}].Arcane}>=1 && ${Me.Group[${temphl}].ToActor(exists)}
;			{
;				call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}
;
;				if ${Actor[${KillTarget}](exists)}
;				{
;					Target ${KillTarget}
;				}
;			}
;
;			;Check Group members
;			;if ${Me.Group[${temphl}].ToActor.Health}<50 && ${Me.Group[${temphl}].ToActor.Health}>-99 && && ${Me.Group[${temphl}].ToActor(exists)}
;			{
;				call CastSpellRange 396 0 0 0 ${Me.Group[${temphl}].ToActor.ID}
;
;				;Stoneskins AA
;				call CastSpellRange 378
;
;				EQ2Echo healing ${Me.Group[${temphl}].ToActor.Name}
;
;				if ${Actor[${KillTarget}](exists)}
;				{
;					Target ${KillTarget}
;				}
;
;			}
;
;			;================================
;			;= Expiation Check
;			;================================
;			call IsHealer ${Me.Group[${temphl}].ID}
;
;			if (${Me.Group[${temphl}].ToActor.Health}<30 && ${Me.Group[${temphl}].ToActor.Health}>0)  || (${Return} && ${Me.Group[${temphl}].ToActor.Power}<30 && ${Me.Group[${temphl}].ToActor.Power}>0) && ${Me.Group[${temphl}].ToActor.InCombatMode} && ${Me.Group[${temphl}].ToActor(exists)} && ${PetMode}
;			{
;				;TODO Add check for Intervention
;				;Cast AA Animist Bond so damage from expiation is to power not the pets health
;				call CastSpellRange 382
;				;Cast Expiation
;				call CastSpellRange 361
;				call SummonPet
;
;			}
;	}
;	while ${temphl:Inc}<${grpcnt}

	;================================
	;= Pet Heals                    =
	;================================

	;Animist Bond AA check
	if  ${Me.ToActor.Pet.Health}<50 && ${Me.ToActor.Pet.Power}>30 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 382
	}

	if ${Me.ToActor.Pet.Health}<70 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 1
	}

	if ${Me.ToActor.Pet.Health}<40 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 4
	}

	if ${Me.ToActor.Pet.Health}<30 && ${Me.ToActor.Pet(exists)}
	{
		call CastSpellRange 47
	}

	call UseCrystallizedSpirit 60

}


function QueueShardRequest(string line, string sender)
{
	if ${Actor[${sender}](exists)}
	{
		ShardQueue:Queue[${sender}]
	}
}

function AnswerShardRequest()
{
	if ${Actor[${ShardQueue.Peek}](exists)}
	{
		if ${Actor[${ShardQueue.Peek}].Distance}<10  && !${Me.IsMoving}  &&  ${Me.Ability[${SpellType[360]}].IsReady}
		{
			if ${Time.Timestamp}-${ShardRequestTimer}>2
			{
				call CastSpellRange 360 0 0 0 ${Actor[pc,exactname,${ShardQueue.Peek}].ID}
				ShardRequestTimer:Set[${Time.Timestamp}]
			}

			if ${Return}
			{
				ShardQueue:Dequeue
			}
		}
	}

}

function DequeueShardRequest(string line)
{
	if ${ShardQueue.Peek(exists)}
	{
		ShardQueue:Dequeue
	}
}

function SummonPet()
{
;1=Scout,2=Mage,3=Fighter; 4=hydromancer
	PetEngage:Set[FALSE]

	if ${PetMode}
	{
		switch ${PetType}
		{
			case 1
				call CastSpellRange 355
				break

			case 2
				call CastSpellRange 356
				break

			case 3
				call CastSpellRange 357
				break

			case 4
				call CastSpellRange 379
				break

			case default
				call CastSpellRange 357
				break
		}
		BuffCabalistCover:Set[TRUE]

		if ${PetDefStance}
			call CastSpellRange 295
		else
			call CastSpellRange 290
	}
}

function PostDeathRoutine()
{	
	;; This function is called after a character has either revived or been rezzed
	
	return
}