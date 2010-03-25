;*************************************************************
;Wizard.iss
;version 20090622a
;by Pygar
;
;20090622
;	Updated for TSO and GU52
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
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090622
	;;;;

	declare AoEMode bool script FALSE
	declare RaysMode bool script FALSE
	declare PreBuffShield bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffAccordShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffRadianceProc collection:string script
	declare BuffAmplify bool script FALSE
	declare BuffSeal bool script FALSE
	declare CastCures bool script FALSE
	declare PetMode bool script TRUE
	declare StartHO bool script FALSE
	declare PetForm int script 1

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	RaysMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Rays,TRUE]}]
	PreBuffShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PreBuffShield,TRUE]}]
	CastCures:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Cures,TRUE]}]
	BuffAccordShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Accord Shield,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffAmplify:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAmplify,,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	BuffSeal:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSeal,FALSE]}]
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


	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+7000]}) && !${Me.IsMoving}
	{
		if ${PreBuffShield}
			call CastSpellRange 355 0 0 0 ${Actor[pc,exactname,${MainTankPC}].ID}

		call CheckHeals
		call RefreshPower

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
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

	PreAction[8]:Set[AA_Pet]
	PreSpellRange[8,1]:Set[382]
	PreSpellRange[8,2]:Set[383]
	PreSpellRange[8,3]:Set[384]

	PreAction[9]:Set[DeityPet]
}

function Combat_Init()
{
 ;scratched for priority casting

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
	declare spellsused int local
	declare shapesused int local
	declare spellthreshold int local

	spellsused:Set[0]
	shapeused:Set[0]
	spellthreshold:Set[3]

	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	if ${CureMode}
		call CheckHeals

	call RefreshPower
	call UseCrystallizedSpirit 60

	;Use Protofire
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[324]}].IsReady}
	{
		call CastSpellRange 324 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Use Furnace
	if ${spellsused}<=${spellthreshold} && ${PBAoEMode} && ${Me.Ability[${SpellType[95]}].IsReady}
	{
		call CastSpellRange 95 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Use FireShape if chain available
	if ${Me.Ability[${SpellType[387]}].IsReady} && ${Me.Ability[${SpellType[361]}].IsReady} && !${Me.Maintained[${SpellType[388]}](exists)}
	{
		call CastSpellRange 387
		call CastSpellRange 361
		shapeused:Set[1]
	}

	;Use Iceshape if Fireshape wasn't used and chain available
	if !${shapeused} && ${Me.Ability[${SpellType[388]}].IsReady} && ${Me.Ability[${SpellType[360]}].IsReady} && !${Me.Maintained[${SpellType[387]}](exists)}
	{
		call CastSpellRange 387
		call CastSpellRange 360
		shapeused:Set[1]
	}

	;Ice Spears
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[73]}].IsReady} && !${Me.Maintained[${SpellType[73]}](exists)}
	{
		call CastSpellRange 73 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	if ${AoEMode} && ${Mob.Count}>2
	{
		;Solar Wind
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[91]}].IsReady}
		{
			call CastSpellRange 91 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Exothermicity
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[96]}].IsReady}
		{
			call CastSpellRange 96 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Storm of Lightning
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[92]}].IsReady}
		{
			call CastSpellRange 92 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	;Surging Tempest
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)}
	{
		call CastSpellRange 70 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;fusion
	if ${PBAoEMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[94]}].IsReady}
	{
		if ${Me.Ability[${SpellType[385]}].IsReady}
			call CastSpellRange 385
		call CastSpellRange 94 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Ice Nova
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady}
	{
		if ${Me.Ability[${SpellType[385]}].IsReady}
			call CastSpellRange 385
		call CastSpellRange 60 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Bewilderment
	if ${PBAoEMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[505]}].IsReady}
	{
		call CastSpellRange 505 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;;;; Master Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[Master's Strike].IsReady} && ${Mob.CheckActor[${KillTarget}]}
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

	;Rays
	if ${RaysMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[500]}].IsReady}
	{
		call CastSpellRange 500 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Hailstorm
	if ${PBAoEMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[508]}].IsReady}
	{
		if ${Me.Ability[${SpellType[385]}].IsReady}
			call CastSpellRange 385
		call CastSpellRange 508 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Ball of Lava
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[62]}].IsReady}
	{
		call CastSpellRange 62 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Thunderclap
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[506]}].IsReady}
	{
		call CastSpellRange 506 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Immolation
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)}
	{
		call CastSpellRange 71 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Magma Chamber
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[181]}].IsReady} && !${Me.Maintained[${SpellType[181]}](exists)}
	{
		call CastSpellRange 181 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Solar Flare
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[63]}].IsReady}
	{
		call CastSpellRange 63 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;Ro's Coil
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[72]}](exists)}
	{
		call CastSpellRange 72 0 0 0 ${KillTarget}
		spellsused:Inc
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