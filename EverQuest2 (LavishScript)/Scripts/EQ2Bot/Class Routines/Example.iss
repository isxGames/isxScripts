;*************************************************************
;MyClass.iss
;version 20070404a
;by Pygar
;
;20070404a
;	Initial Build
;
;This script doesn't do anything, but is just an example of
;both required functions, and how to create custom functions.
;This also demonstrates common BotLib calls.
;*************************************************************

;Optional Includes for Function Libraries
#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 00000000
    ;;;;    
    
	;Declare Script Variables here
	declare AoEMode bool script FALSE

	;Initialize any function Libraries here
	call EQ2BotLib_Init

	;Load Values from Class UI Tab HEre
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
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
	;ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{
   PreAction[1]:Set[MySelfBuff]
   PreSpellRange[1,1]:Set[30]

   PreAction[2]:Set[MyGroupBuffs]
   PreSpellRange[2,1]:Set[25]
   PreSpellRange[2,2]:Set[26]

}

function Combat_Init()
{
   Action[1]:Set[Nukes]
   SpellRange[1,1]:Set[170]
   SpellRange[1,2]:Set[171]

   Action[2]:Set[Taunt]
   SpellRange[2,1]:Set[160]

   Action[3]:Set[AOE]
   SpellRange[3,1]:Set[161]

   Action[4]:Set[ThermalShocker]

}

function PostCombat_Init()
{
   PostAction[1]:Set[AA_BindWound]
   PostSpellRange[1,1]:Set[172]

}

function Buff_Routine(int xAction)
{
	;declare any local variables here (Incremental Vars, Loop Couts, targets, etc)
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	;This is an eq2botlib function to reset your equiped gear to the default config from when you started the bot
	call WeaponChange

	;this is an eq2botlib function that will consume a shard if needed, and if none exist request from the designated providor
	if ${ShardMode}
	{
		call Shard
	}

	;Preform Buff Actions
	switch ${PreAction[${xAction}]}
	{

		case MySelfBuff
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0
			break

		case MyGroupBuffs
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		Default
			Action:Set[40]
			break
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

	;Function Library Calls
	;This one will advance an HO if you have selected to participate in them
	if ${DoHOs}
	{

		objHeroicOp:DoHO
	}

	;Sampe code to start an HO if one isn't currently going
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	;Call local functions to the script file
	call CheckHeals

	;Add persistant checks you want the bot to do every round of combat, these are optional
	if ${Me.ToActor.Health}<60
	{
		call CastSpellRange 156
	}

	if ${Me.ToActor.Health}<40
	{
		call CastSpellRange 155
	}

	;Preform Combat Actions
	switch ${Action[${xAction}]}
	{

		case Nukes
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget}
			break

		case Taunt
			call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break

		case AOE
			if ${AoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		case ThermalShocker
			if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
			{
				Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
			}
			break
		case default
			Action:Set[40]
			break
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{

		case AA_BindWound
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PostSpellRange[${xAction},1]}
			}
			break

		case Default
			Action:Set[20]
			break
	}
}

function Have_Aggro()
{

}

function Lost_Aggro(int mobid)
{

}

function MA_Lost_Aggro()
{


}

function MA_Dead()
{
	MainTank:Set[TRUE]
	MainTankPC:Set[${Me.Name}]
	KillTarget:Set[]
}

function Cancel_Root()
{

}

;Sample Class File Local funciton
function CheckHeals()
{
	;Declare Local Variables
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare MTinMyGroup bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	;Function Library Calls
	;This one will check group health and use a defiler summoned spirit shard that heals group.
	call UseCrystallizedSpirit

	;Sample script to determin if a group heal is needed
	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal["${Zone.Name}"]}
		{

			if ${Me.Group[${temphl}].ToActor.Health} < 100 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor(exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health} < ${Me.Group[${lowest}].ToActor.Health}
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<60
			{
				grpheal:Inc
			}

			if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
			{
				MTinMyGroup:Set[TRUE]
			}
		}

	}
	while ${temphl:Inc}<${grpcnt}

	;If a group heal was determined, cast some spells
	if ${grpheal}>1
	{
		if ${Me.Ability[${SpellType[316]}].IsReady}
		{
			call CastSpellRange 316
		}
		if ${Me.Ability[${SpellType[271]}].IsReady}
		{
			call CastSpellRange 271
		}
	}

}

function PostDeathRoutine()
{	
	;; This function is called after a character has either revived or been rezzed
	
	return
}

