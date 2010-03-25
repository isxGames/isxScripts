;*************************************************************
;Coercer.iss
;version 20090616a
;by Pygar
;
;20090616a
;	Update for TSO AA and GU52
;
;20080515a Pygar
; * Complete retuning for class revamp.
;20070725a (pygar)
; Updated weapon swapping changes
; Fixed clarity buff loop (cheesy fix, I know)
;
; 20070427a
;	Fixed Mastery not to move to melee range
;	Fixed Clarity casting loop
;
; 20070404a
;	Updated for newest eq2bot
;	Concentration checks for some buffs
;	Updated Master Strike
;
;20061207a
;Implemented AA Thought Snap
;Implemented AA Manaward
;Implemented AA Tashiana
;Implemented AA Coercive Healing
;Added EoF mastery strikes
;Implemented Vampire Spell Sunbolt
;Implemented Crystalize Spirit Healing
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20090616

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare MezzMode bool script FALSE
	declare Charm bool script FALSE
	declare BuffInstigation bool script FALSE
	declare BuffSignet bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffCoerciveHealing bool script FALSE
	declare BuffHateGroupMember string script
	declare BuffCoerciveHealingGroupMember string script
	declare BuffManaward bool script
	declare DPSMode bool script 1
	declare TSMode bool script 1
	declare StartHO bool script 1

	declare CharmTarget int script

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffHateGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHateGroupMember,]}]
	BuffHate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHate,FALSE]}]
	BuffInstigation:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffInstigation,,FALSE]}]
	BuffSignet:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSignet,FALSE]}]
	BuffCoerciveHealing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffCoerciveHealing,FALSE]}]
	BuffCoerciveHealingGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffCoerciveHealingGroupMember,]}]
	BuffManaward:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffManaward,FALSE]}]
	DPSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[DPSMode,FALSE]}]
	TSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseTS,FALSE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	Charm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Charm,FALSE]}]
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
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	if ${MezzMode} && (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer2}+2000]})
	{
		CurrentAction:Set[Out of Combat Checking Mezzes]
		call Mezmerise_Targets
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer2:Set[${Script.RunningTime}]
	}

	if ${MezzMode} && (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer2}+5000]})
	{
		;;;; Cataclysmic Mind
		if ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[72]}](exists)} && ${Actor[${MainTank}].Target.Type.Equal[npc]}
		{
			eq2execute /useabilityonplayer ${Me.ToActor.Name} ${SpellType[72]}
		}
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Instigation]
	PreSpellRange[2,1]:Set[20]

	PreAction[3]:Set[Hate]
	PreSpellRange[3,1]:Set[40]

	PreAction[4]:Set[AntiHate]
	PreSpellRange[4,1]:Set[41]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[35]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[Signet]
	PreSpellRange[7,1]:Set[21]

	PreAction[8]:Set[Clarity]
	PreSpellRange[8,1]:Set[22]

	PreAction[9]:Set[AAEmpathic_Aura]
	PreSpellRange[9,1]:Set[384]

	PreAction[10]:Set[AACoerciveHealing]
	PreSpellRange[10,1]:Set[379]
}

function Combat_Init()
{

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

	CurrentAction:Set[Buffing ${xAction}]

	call CheckHeals

	switch ${PreAction[${xAction}]}
	{

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case AAEmpathic_Aura
		case Clarity
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 20
			}
			break
		case Signet
			if ${BuffSignet}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Instigation
			if ${BuffInstigation}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Hate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${BuffHate} && ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AACoerciveHealing
			BuffTarget:Set[${UIElement[cbBuffHealGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${BuffCoerciveHealing} && ${Actor[${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AntiHate
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
					if ${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if ${Me.UsedConc}<5
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case Melee_Buff
			Counter:Set[1]
			tempvar:Set[1]
			
			;if we have the improved velocity buff we need only buff ourselves
			if ${Me.Ability[Increased Velocity](exists)} && ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0 && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} 
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
				break
			}
			elseif ${Me.Ability[Increased Velocity](exists)}
			{
				break
			}
			
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
					if ${Me.UsedConc}<5
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
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[3]

	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}
	
	if ${MezzMode}
	{
		CurrentAction:Set[Combat Checking Mezzes]
		call Mezmerise_Targets
		spellthreshold:Set[1]
	}

	if ${Charm}
	{
		CurrentAction:Set[Combat Checking Charms]
		call DoCharm
	}

	if ${TSMode}
	{
		CurrentAction:Set[Combat Checking ThoughtSnap]
		call DoAmnesia
	}

	if ${Me.Pet(exists)} && !${Me.Pet.InCombatMode}
		call PetAttack

	if !${DPSMode}
	{
		CurrentAction:Set[Combat Checking Cures]
		call CheckHeals
		spellthreshold:Set[5]
		call CastSpellRange 503 0 0 0 ${KillTarget}
	}

	call CommonHeals 70

	;;; Screw spell loops, priority casting
	;;;; Chronosiphon
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[382]}].IsReady}
	{
		call CastSpellRange 382 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Intellectual Remedy
	if ${Me.Ability[${SpellType[503]}].IsReady} && ${Actor[pc,exactname,${MainTankPC}].Health}<50 && ${Actor[${KillTarget}].Health}>10
	{
		call CastSpellRange 503 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Cataclysmic Mind
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[72]}](exists)}
	{
			eq2execute /useabilityonplayer ${Me.ToActor.Name} ${SpellType[72]}
			spellsused:Inc
	}

	;;; AoE Checks
	if ${Mob.Count}>1
	{
		if ${PBAoEMode} && ${Me.Ability[${SpellType[95]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 95 0 1 0 ${KillTarget}
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[90]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 90 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[91]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 91 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}


	;;;; Tashani
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[377]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 377 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Mental Debuff
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 50 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Hostage
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 71 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Lash
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 92 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; PuppetMaster
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[391]}].IsReady} && !${Me.Maintained[${SpellType[391]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 391 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Piece of Mind
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[501]}].IsReady} && !${Me.Maintained[${SpellType[501]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		Me:InitializeEffects

		while ${Me.InitializingEffects}
			wait 2

		;don't PoM if PoM is up
		if !${Me.Effect[beneficial,${SpellType[501]}](exists)}
		{
			call CastSpellRange 501 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	;;;; Bewilderment
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[500]}].IsReady} && !${Me.Maintained[${SpellType[500]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 500 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Daze
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[260]}].IsReady} && !${Me.Maintained[${SpellType[260]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 260 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Despair
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[80]}].IsReady} && !${Me.Maintained[${SpellType[80]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 80 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Anguish
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 70 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Nuke
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 60 0 0 0 ${KillTarget}
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
	;;;; Stun
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[190]}].IsReady} && !${Me.Maintained[${SpellType[190]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 190 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Sunbolt
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[62]}].IsReady} && !${Me.Maintained[${SpellType[62]}](exists)} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 62 0 0 0 ${KillTarget}
		spellsused:Inc
	}


	if ${DoHOs} && ${Mob.CheckActor[${KillTarget}]}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO} && ${Mob.CheckActor[${KillTarget}]}
		call CastSpellRange 303

	;make sure Mind's Eye is buffed, note: this is a 10 min buff.
	if !${Me.Maintained[${SpellType[42]}](exists)} && ${Me.Ability[${SpellType[42]}].IsReady}
		call CastSpellRange 42

	CurrentAction:Set[Combat Checking Power]
	call RefreshPower

	return CombatComplete
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	CurrentAction:Set[Post Combat ${xAction}]

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
	;AE Fear
	if ${PBAoEMode}
	{
		call CastSpellRange 181
	}
	;Blink
	;call CastSpellRange 180
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
	declare tempvar int local
	declare MemberLowestPower int local

	if ${ShardMode}
		call Shard 45

	;Transference line out of Combat
	if ${Me.ToActor.Health}>60 && ${Me.ToActor.Power}<50 && !${Me.InCombat}
		call CastSpellRange 309

	;Transference Line in Combat
	if ${Me.ToActor.Health}>60 && ${Me.ToActor.Power}<45
		call CastSpellRange 309

	if ${Me.Group}
	{
		;Mana Flow the lowest group member
		tempvar:Set[1]
		MemberLowestPower:Set[0]
		do
		{
			if ${Me.Group[${tempvar}].ToActor.Power}<45 && ${Me.Group[${tempvar}].ToActor.Distance}<30 && ${Me.Group[${tempvar}].ToActor(exists)}
			{
				if ${Me.Group[${tempvar}].ToActor.Power}<=${Me.Group[${MemberLowestPower}].ToActor.Power}
					MemberLowestPower:Set[${tempvar}]
			}

		}
		while ${tempvar:Inc}<${Me.GroupCount}

		if ${Me.Grouped} && ${Me.Group[${MemberLowestPower}].ToActor.Power}<45 && ${Me.Group[${MemberLowestPower}].ToActor.Distance}<30 && ${Me.ToActor.Health}>50 && ${Me.Group[${MemberLowestPower}].ToActor(exists)}
		{
			call CastSpellRange 390 0 0 0 ${Me.Group[${MemberLowestPower}].ToActor.ID}
		}

		;Channel if group member is below 20 and we are in combat
		if ${Me.Grouped}  && ${Me.Group[${MemberLowestPower}].ToActor.Power}<40 && ${Me.Group[${MemberLowestPower}].ToActor.Distance}<50  && ${Me.InCombat} && ${Me.Group[${MemberLowestPower}].ToActor(exists)}
			call CastSpellRange 310
	}

	;Mana Cloak the group if the Main Tank is low on power
	if ${Actor[${MainTankPC}].Power}<40 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].Distance}<50  && ${Actor[${MainTankPC}].InCombatMode}
		call CastSpellRange 354

}

function CheckHeals()
{

	call CommonHeals 70

	if ${BuffManaward} && ${Me.InCombat}
		call CastSpellRange 378

}

function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	EQ2:CreateCustomActorArray[byDist,20]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} || ${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
				continue

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
					if ${CustomActor[${tcount}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].ID}  || (${CustomActor[${tcount}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].Pet.ID}
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=24
			}
			;check if its agro on me
			if ${CustomActor[${tcount}].Target.ID}==${Me.ID} || ${CustomActor[${tcount}].Target.IsMyPet}
				aggrogrp:Set[TRUE]

			if ${aggrogrp}
			{
				if ${Me.AutoAttackOn}
					eq2execute /toggleautoattack

				if ${Me.RangedAutoAttackOn}
					eq2execute /togglerangedattack

				;try to AE mezz first and check if its not single target mezzed
				if !${CustomActor[${tcount}].Effect[${SpellType[352]}](exists)}
					call CastSpellRange 353 0 0 0 ${CustomActor[${tcount}].ID}

				;if the actor is not AE Mezzed then single target Mezz
				if !${CustomActor[${tcount}].Effect[${SpellType}[353]](exists)}
					call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 10

				aggrogrp:Set[FALSE]
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead} && ${Mob.Detect}
	{
		Target ${KillTarget}
		wait 20 ${Me.ToActor.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
		KillTarget:Set[]
	}
}

function DoCharm()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	if ${Me.Maintained[${SpellType[351]}](exists)} || ${Me.UsedConc}>2
		return

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && !${CustomActor[${tcount}].IsEpic} && ${CustomActor[${tcount}].Target(exists)}
		{
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} && ${grpcnt}>1
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]
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

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
				aggrogrp:Set[TRUE]

			if ${aggrogrp} && (${CustomActor[${tcount}].Difficulty}>=0) && (${CustomActor[${tcount}].Difficulty}<=3)
			{
				CharmTarget:Set[${CustomActor[${tcount}].ID}]
				break
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${CharmTarget}](exists)}
	{
		call CastSpellRange 351 0 0 0 ${CharmTarget}

		if ${Actor[${KillTarget}](exists)} && (${Me.Maintained[${SpellType[351]}].Target.ID}!=${KillTarget}) && ${Me.Maintained[${SpellType[351]}](exists)} && !${Actor[${KillTarget}].IsDead}
			call PetAttack
		else
			EQ2Execute /target_none
	}
}

function DoAmnesia()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,35]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			if (${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID}) || (${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID})
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						call IsFighter ${Me.Group[${tempvar}].ID}
						if ${Return} || ${Me.Group[${tempvar}].Name.Equal[${MainAssist}]}
							continue
						else
						{
							aggrogrp:Set[TRUE]
							break
						}
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}  && !${MainTank}
				aggrogrp:Set[TRUE]

			if ${aggrogrp}
			{
				;Try AA Thought Snap first
				if ${Me.Ability[${SpellType[376]}].IsReady}
					call CastSpellRange 376 0 0 0 ${CustomActor[${tcount}].ID}
				elseif ${Me.Ability[${SpellType[384]}].IsReady}
					call CastSpellRange 382 0 0 0 ${KillTarget}
				else
					call CastSpellRange 193 0 0 0 ${CustomActor[${tcount}].ID}
				return
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}
}

function DestroyThoughtstones()
{
	;keeps 1 stack of thoughtstones and destroys the next stack
	variable int Counter=1
	variable bool StackFound=FALSE
	Me:CreateCustomInventoryArray[nonbankonly]
	do
	{
		if ${Me.CustomInventory[${Counter}].Name.Equal[thoughtstone]}
		{
			if ${StackFound}
			{
				;we already have a stack so destroy this one and return
				Me.CustomInventory[${Counter}]:Destroy
				return
			}
			else
				StackFound:Set[TRUE]
		}
	}
	while ${Counter:Inc}<=${Me.CustomInventoryArraySize}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}