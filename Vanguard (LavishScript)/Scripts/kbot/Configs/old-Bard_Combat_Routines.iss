







;================================================
function CombatBuffsUp()
{
	if "${HowManyInCombatBuffs}==0"
	Return

	if "${Me.Ability[${CombatBuff1}].IsReady} && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth} >30"
	{
		Me.Ability[${CombatBuff1}]:Use
		call MeCasting
	}

	if "${HowManyInCombatBuffs}<2"
	Return

	if "${Me.Ability[${CombatBuff2}].IsReady} && !${Me.Effect[${CombatBuff2}](exists)} && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth} >30"
	{
		Me.Ability[${CombatBuff2}]:Use
		call MeCasting
	}

	if "${HowManyInCombatBuffs}<3"
	Return

	if "${Me.Ability[${CombatBuff3}].IsReady} && !${Me.Effect[${CombatBuff3}](exists)}  && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth} >30 && !${Me.Effect[${CombatBuff4}](exists)}"
	{
		Me.Ability[${CombatBuff3}]:Use
		call MeCasting
	}

	if "${HowManyInCombatBuffs}<4"
	Return

	if "${Me.Ability[${CombatBuff4}].IsReady} && !${Me.Effect[${CombatBuff4}](exists)}  && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth} >30 && !${Me.Effect[${CombatBuff3}](exists)}"
	{
		Me.Ability[${CombatBuff4}]:Use
		call MeCasting
	}

	if "${HowManyInCombatBuffs}<5"
	Return

	if "${Me.Ability[${CombatBuff5}].IsReady} && !${Me.Effect[${CombatBuff5}](exists)}  && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth} >30"
	{
		Me.Ability[${CombatBuff5}]:Use
		call MeCasting
	}

	if "${HowManyInCombatBuffs}<6"
	Return

	if "${Me.Ability[${CombatBuff6}].IsReady} && !${Me.Effect[${CombatBuff6}](exists)}  && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth} >30"
	{
		Me.Ability[${CombatBuff6}]:Use
		call MeCasting
	}
}

/* Code used by Denthan */
/*
{
if "${HowManyInCombatBuffs}==0"
return

if "${Me.Ability[${CombatBuff1}].IsReady} && !${Me.Effect[${CombatBuff1}](exists)} && ${Me.TargetHealth}>30"

{
Me.Ability[${CombatBuff1}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<2"
return

;if "${Me.Ability[${CombatBuff2}].IsReady} && !${Me.Effect[${CombatBuff2}](exists)} && ${Me.TargetHealth}>30 && !${Me.Effect[${CombatBuff3}](exists)} && !${Me.Effect[${CombatBuff4}](exists)} && !${Me.Effect[${CombatBuff5}](exists)} && ${Me.TargetAsEncounter.Difficulty}==3"
if "${Me.Ability[${CombatBuff2}].IsReady} && !${Me.Effect[${CombatBuff2}](exists)} && ${Me.TargetHealth}>30 && !${Me.Effect[${CombatBuff3}](exists)} && !${Me.Effect[${CombatBuff4}](exists)} && !${Me.Effect[${CombatBuff5}](exists)}"
{
Me.Ability[${CombatBuff2}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<3"
return

;if "${Me.Ability[${CombatBuff3}].IsReady} && !${Me.Effect[${CombatBuff3}](exists)} && ${Me.TargetHealth}>30 && !${Me.Effect[${CombatBuff2}](exists)} && !${Me.Effect[${CombatBuff4}](exists)} && !${Me.Effect[${CombatBuff5}](exists)} && ${Me.TargetAsEncounter.Difficulty}==3"
if "${Me.Ability[${CombatBuff3}].IsReady} && !${Me.Effect[${CombatBuff3}](exists)} && ${Me.TargetHealth}>30 && !${Me.Effect[${CombatBuff2}](exists)} && !${Me.Effect[${CombatBuff4}](exists)} && !${Me.Effect[${CombatBuff5}](exists)}"
{
Me.Ability[${CombatBuff3}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<4"
return

if "${Me.Ability[${CombatBuff4}].IsReady} && !${Me.Effect[${CombatBuff4}](exists)}  && ${Me.TargetHealth}>30 && !${Me.Effect[${CombatBuff2}](exists)} && !${Me.Effect[${CombatBuff3}](exists)} && !${Me.Effect[${CombatBuff5}](exists)}"
{
Me.Ability[${CombatBuff4}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<5"
return

if "${Me.Ability[${CombatBuff5}].IsReady} && !${Me.Effect[${CombatBuff5}](exists)}  && ${Me.TargetHealth}>30 && !${Me.Effect[${CombatBuff2}](exists)} && !${Me.Effect[${CombatBuff3}](exists)} && !${Me.Effect[${CombatBuff4}](exists)}"
{
Me.Ability[${CombatBuff5}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<6"
return

if "${Me.Ability[${CombatBuff6}].IsReady} && !${Me.Effect[${CombatBuff6}](exists)}  && ${Me.TargetHealth}>30"
{
Me.Ability[${CombatBuff6}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<7"
return

if "${Me.Ability[${CombatBuff7}].IsReady} && !${Me.Effect[${CombatBuff7}](exists)}  && ${Me.TargetHealth}>30"
{
Me.Ability[${CombatBuff7}]:Use
call MeCasting
}

if "${HowManyInCombatBuffs}<8"
return

if "${Me.Ability[${CombatBuff8}].IsReady} && !${Me.Effect[${CombatBuff8}](exists)}  && ${Me.TargetHealth}>30"
{
Me.Ability[${CombatBuff8}]:Use
call MeCasting
}
}
*/

;================================================
function SnareMob()
{
	if "!${DoWeWantToSnare}"
	Return

	if "${Me.TargetHealth}<${SnareAt} && ${Me.Ability[${Snare}].IsReady} && ${Me.Energy}>${Me.Ability[${Snare}].EnergyCost} && !${Me.TargetMyDebuff[${Snare}](exists)} && ${Me.TargetHealth}>3"
	{
		;cast snare
		Me.Ability[${Snare}]:Use
		call MeCasting
	}
}
;================================================
function MeleeAttack()
{
	if "${HowManyMelee}==0"
	Return

	call DebugIt "D. Check to see if we have melee attacks ${HowManyMelee}"

	call DoEvents
	call CheckForChain
	call Finishers

	declare CurrentAttack string local

	If "${CurrentMelee}==1"
	CurrentAttack:Set[${Melee1}]

	If "${CurrentMelee}==2"
	CurrentAttack:Set[${Melee2}]

	If "${CurrentMelee}==3"
	CurrentAttack:Set[${Melee3}]

	If "${CurrentMelee}==4"
	CurrentAttack:Set[${Melee4}]

	If "${CurrentMelee}==5"
	CurrentAttack:Set[${Melee5}]

	If "${CurrentMelee}==6"
	CurrentAttack:Set[${Melee6}]

	If "${CurrentMelee}==7"
	CurrentAttack:Set[${Melee7}]


	CurrentMelee:Set[${CurrentMelee}+1]
	If "${CurrentMelee}>${HowManyMelee}"
	CurrentMelee:Set[1]

	if "${Me.Ability[${CurrentAttack}].EnduranceCost}>${Me.Endurance}"
	Return

	call DebugIt "D. AttackSub ${CurrentAttack}, rdy ${Me.Ability[${CurrentAttack}].IsReady}"
	if "${Me.Ability[${CurrentAttack}].IsReady} && ${Me.Target.ID(exists)}"
	{
		face
		Me.Ability[${CurrentAttack}]:Use
		call MeCasting
		wait 3
	}


	if "(${Me.TargetHealth}>20) && ${AddChecking}"
	{
		call AvoidAdds  ${MobAgroRange}
	}


	call DoEvents
	call CheckForChain
	call Finishers
}


;================================================
function DoTs()
{
	if "${HowManyDoTs}==0"
	Return

	call DebugIt "D. Check to see if we have DoTs ${HowManyDoTs}"

	declare CurrentDoTName string local

	If "${CurrentDoT}==1"
	CurrentDoTName:Set[${DoT1}]

	If "${CurrentDoT}==2"
	CurrentDoTName:Set[${DoT2}]

	If "${CurrentDoT}==3"
	CurrentDoTName:Set[${DoT3}]

	If "${CurrentDoT}==4"
	CurrentDoTName:Set[${DoT4}]

	If "${CurrentDoT}==5"
	CurrentDoTName:Set[${DoT5}]

	If "${CurrentDoT}==6"
	CurrentDoTName:Set[${DoT6}]

	If "${CurrentDoT}==7"
	CurrentDoTName:Set[${DoT7}]


	CurrentDoT:Set[${CurrentDoT}+1]
	If "${CurrentDoT}>${HowManyDoTs}"
	CurrentDoT:Set[1]


	if "${Me.Ability[${CurrentDoTName}].EnergyCost}>${Me.Energy}"
	Return

	call DebugIt "D. DoT Sub ${CurrentDoTName}, rdy ${Me.Ability[${CurrentDoTName}].IsReady}, Already dotted ${Me.TargetMyDebuff[${CurrentDoTName}](exists)}"

	if "${Me.Ability[${CurrentDoTName}].IsReady} && ${Me.Target.ID(exists)} && !${Me.TargetMyDebuff[${CurrentDoTName}](exists)}"
	{
		face
		Me.Ability[${CurrentDoTName}]:Use
		call MeCasting
		wait 3
	}

	if "(${Me.TargetHealth}>20) && ${AddChecking}"
	{
		call AvoidAdds  ${MobAgroRange}
	}

	call DoEvents
	call CheckForChain
	call Finishers
}

;================================================
function Nukes()
{
	if "${HowManyNukes}==0"
	Return

	call DebugIt "D. Check to see if we have Nukes ${HowManyNukes}"

	declare CurrentNukeName string local

	If "${CurrentNuke}==1"
	CurrentNukeName:Set[${Nuke1}]

	If "${CurrentNuke}==2"
	CurrentNukeName:Set[${Nuke2}]

	If "${CurrentNuke}==3"
	CurrentNukeName:Set[${Nuke3}]

	If "${CurrentNuke}==4"
	CurrentNukeName:Set[${Nuke4}]

	If "${CurrentNuke}==5"
	CurrentNukeName:Set[${Nuke5}]

	If "${CurrentNuke}==6"
	CurrentNukeName:Set[${Nuke6}]

	If "${CurrentNuke}==7"
	CurrentNukeName:Set[${Nuke7}]


	CurrentNuke:Set[${CurrentNuke}+1]
	If "${CurrentNuke}>${HowManyNukes}"
	CurrentNuke:Set[1]


	if "${Me.Ability[${CurrentNukeName}].EnergyCost}>${Me.Energy}"
	Return

	call DebugIt "D. Nuke Sub ${CurrentNukeName}, rdy ${Me.Ability[${CurrentNukeName}].IsReady}, Already Nuketed ${Me.TargetMyDebuff[${CurrentNukeName}](exists)}"
	if "${Me.Ability[${CurrentNukeName}].IsReady} && ${Me.Target.ID(exists)} && !${Me.TargetMyDebuff[${CurrentNukeName}](exists)}"
	{
		face
		Me.Ability[${CurrentNukeName}]:Use
		call MeCasting
		wait 3
	}

	if "(${Me.TargetHealth}>20) && ${AddChecking}"
	{
		call AvoidAdds  ${MobAgroRange}
	}


	call DoEvents
	call CheckForChain
	call Finishers
}

;================================================
function CheckForChain()
{
	if "${HowManyChains}==0"
	Return

	call DebugIt "D. Check to see if we have chain attacks ${HowManyChains}"

	;This sub is ran after initiating any combat ability, this will use Chains if they're up
	if "!${Me.Target.ID(exists)}"
	Return

	;Chains
	;if "${Me.Ability[${Chain1}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain1}].EnduranceCost}<=${Me.Endurance} && ${Me.TargetAsEncounter.Difficulty}==3"
	if "${Me.Ability[${Chain1}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain1}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain1}]:Use
		call MeCasting
	}

	if "${HowManyChains}<2"
	Return

	if "${Me.Ability[${Chain2}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain2}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain2}]:Use
		call MeCasting
	}

	if "${HowManyChains}<3"
	Return

	if "${Me.Ability[${Chain3}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain3}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain3}]:Use
		call MeCasting
	}

	if "${HowManyChains}<4"
	Return

	if "${Me.Ability[${Chain4}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain4}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain4}]:Use
		call MeCasting
	}

	if "${HowManyChains}<5"
	Return

	if "${Me.Ability[${Chain5}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain5}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain5}]:Use
		call MeCasting
	}

	if "${HowManyChains}<6"
	Return

	if "${Me.Ability[${Chain6}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain6}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain6}]:Use
		call MeCasting
	}

	if "${HowManyChains}<7"
	Return

	if "${Me.Ability[${Chain7}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain7}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain7}]:Use
		call MeCasting
	}

	if "${HowManyChains}<8"
	Return

	if "${Me.Ability[${Chain8}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain8}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain8}]:Use
		call MeCasting
	}

	if "${HowManyChains}<9"
	Return

	if "${Me.Ability[${Chain9}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Chain9}].EnduranceCost}<=${Me.Endurance}"
	{
		Me.Ability[${Chain9}]:Use
		call MeCasting
	}
}

;================================================
function Finishers()
{
	;Finishers
	if "${HowManyFinishers}==0"
	Return

	if "${Me.Ability[${Finisher1}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher1}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher1}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<2"
	Return

	if "${Me.Ability[${Finisher2}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher2}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher2}]:Use
		call MeCasting
	}
	if "${HowManyFinishers}<3"
	Return

	if "${Me.Ability[${Finisher3}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher3}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher3}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<4"
	Return

	if "${Me.Ability[${Finisher4}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher4}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher4}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<5"
	Return

	if "${Me.Ability[${Finisher5}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher5}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher5}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<6"
	Return

	if "${Me.Ability[${Finisher6}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher6}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher6}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<7"
	Return

	if "${Me.Ability[${Finisher7}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher7}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher7}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<8"
	Return

	if "${Me.Ability[${Finisher8}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher8}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher8}]:Use
		call MeCasting
	}

	if "${HowManyFinishers}<9"
	Return

	if "${Me.Ability[${Finisher9}].IsReady} && ${Me.InCombat} && ${Me.Ability[${Finisher9}].EnduranceCost}<${Me.Endurance}"
	{
		Me.Ability[${Finisher9}]:Use
		call MeCasting
	}
}

;================================================
function Canni()
{
	if "${DoWeHaveCanni} && ${Me.HealthPct}>${CanniHPAt} && ${Me.EnergyPct}<${CanniEgAt}"
	{
		call DebugIt "D. In Canni"
		;Cast Canni
		Pawn[me]:Target
		Me.Ability[${Canni}]:Use
		call MeCasting
	}
}
;================================================
function CombatHeal()
{
	if "${Me.DTarget.ID}!=${TankID}"
	{
		Pawn[id,${TankID}]:Target
	}

	if "${DoWeHaveEmergHeal} && ${Me.HealthPct}<${EmergHealAt} && ${Me.Ability[${EmergHeal}].IsReady}"
	{
		;cast big heal
		Pawn[me]:Target
		Me.Ability[${EmergHeal}]:Use
		call MeCasting
	}

	if "${DoWeHaveBigHeal} && ${Me.HealthPct}<${BigHealAt} && ${Me.Ability[${BigHeal}].IsReady}"
	{
		;cast big heal
		Pawn[me]:Target
		Me.Ability[${BigHeal}]:Use
		call MeCasting
	}

	if "${DoWeHaveMediumHeal} && ${Me.HealthPct}<${MediumHealAt} && ${Me.Ability[${MediumHeal}].IsReady}"
	{
		;cast medium heal
		Pawn[me]:Target
		Me.Ability[${MediumHeal}]:Use
		call MeCasting
	}

	if "${DoWeHaveSmallHeal} && ${Me.HealthPct}<${SmallHealAt} && ${Me.Ability[${SmallHeal}].IsReady}"
	{
		;cast small heal
		Pawn[me]:Target
		Me.Ability[${SmallHeal}]:Use
		call MeCasting
	}

	call FeigningDeath

	if "!${Me.HavePet}"
	Return

	if "${Me.Pet.Health}<${PetHealAt} && ${Me.Ability[${PetHeal}].IsReady}"
	{
		;cast pet heal
		Pawn[pet]:Target
		Me.Ability[${PetHeal}]:Use
		call MeCasting
	}
}

;================================================
function FeigningDeath()
{
	;call DebugIt "You are in function FeigningDeath"
	if ${DoWeHaveFD} && ${Me.TargetAsEncounter.Difficulty}>${ConCheck} && ${Me.Ability[${FeignDeath}].IsReady} && ${Me.InCombat}
	{
		call runaway
		Me.Ability[${FeignDeath}]:Use
		wait 15
		Me.Form[${NeutralForm}]:ChangeTo
		call DebugIt "D. cleartargets 5 called"
		VGExecute /cleartargets
		return
	}

	if "${DoWeHaveFD} && ${Me.HealthPct}<${FeignDeathAt} && ${Me.Ability[${FeignDeath}].IsReady} && ${Me.InCombat} && (${Me.TargetHealth}>${FightOnAt}) || ${DoWeHaveFD} && ${Me.TargetAsEncounter.Difficulty}>${ConCheck} && !${Me.Effect[${FeignDeath}](exists)} && ${Me.InCombat} && ${Me.Ability[${FeignDeath}].IsReady} || ${Me.HealthPct}>${FeignDeathAt} && ${Me.Ability[${FeignDeath}].IsReady} && ${Me.InCombat} && ${Me.Effect[${FeignDeath}](exists)} || ${Me.Encounter}>0"
	{
		VGExecute "/cleartargets"
		Me.Ability[${FeignDeath}]:Use
		wait 15
		Me.Form[${NeutralForm}]:ChangeTo
		return
	}
}

;================================================
function BuffUp()
{
	;call DebugIt "You are in function BuffUp"
	;This sub keeps our buffs up
	;echo ...Checking Buffs...
	;Make sure pet is up

	if "${DoWeHaveFD} && ${Me.Effect[${FeignDeath}](exists)}"
	Return

	if "!${Me.HavePet}"
	{
		;Cast Pet
		Me.Ability[${PetSpellName}]:Use
		call MeCasting
	}

	if "${HowManyBuffs}==0"
	Return


	if ${IamDenthan}
	{
		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff1}](exists)} && ${Me.Stat["Adventuring","Jin"]}>6 && ${Me.HealthPct}>${EatForHlthAt} || ${Me.Effect[${Buff1}].TimeRemaining}<=60 && ${Me.Stat["Adventuring","Jin"]}>6 && ${Me.HealthPct}>${EatForHlthAt}"
		{
			Pawn[me]:Target
			VGExecute /stand
			Me.Ability[${Buff1}]:Use
			call MeCasting
		}

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff2}](exists)} && ${Me.Stat["Adventuring","Jin"]}>5 || ${Me.Effect[${Buff2}].TimeRemaining}<=60 && ${Me.Stat["Adventuring","Jin"]}>5"
		{
			Pawn[me]:Target
			Me.Ability[${Buff2}]:Use
			call MeCasting
		}
	}
	else
	{

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff1}](exists)} || ${Me.Effect[${Buff1}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff1}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<2"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff2}](exists)} || ${Me.Effect[${Buff2}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff2}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<3"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff3}](exists)} || ${Me.Effect[${Buff3}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff3}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<4"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff4}](exists)} || ${Me.Effect[${Buff4}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff4}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<5"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff5}](exists)} || ${Me.Effect[${Buff5}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff5}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<6"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff6}](exists)} || ${Me.Effect[${Buff6}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff6}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<7"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff7}](exists)} || ${Me.Effect[${Buff7}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff7}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<8"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff8}](exists)} || ${Me.Effect[${Buff8}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff8}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<9"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff9}](exists)} || ${Me.Effect[${Buff9}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff9}]:Use
			call MeCasting
		}

		if "${HowManyBuffs}<10"
		Return

		;If our buff is gone, or has less than 60 seconds, rebuff
		if "!${Me.Effect[${Buff10}](exists)} || ${Me.Effect[${Buff10}].TimeRemaining}<=60"
		{
			Pawn[me]:Target
			Me.Ability[${Buff10}]:Use
			call MeCasting
		}

	}
}

;================================================
function ToggleBuffs()
{

	if "${HowManyToggleBuffs}==0"
	Return

	if "${Me.Effect[${FeignDeath}](exists)}"
	Return

	;This is a toggled buff with no timer. If it doesn't exist cast it
	if "!${Me.Effect[${ToggleBuff1}](exists)}"
	{
		Me.Ability[${ToggleBuff1}]:Use
		call MeCasting
	}

	if "${HowManyToggleBuffs}<2"
	Return

	;This is a toggled buff with no timer. If it doesn't exist cast it
	if "!${Me.Effect[${ToggleBuff2}](exists)}"
	{
		Me.Ability[${ToggleBuff2}]:Use
		call MeCasting
	}

	if "${HowManyToggleBuffs}<3"
	Return

	;This is a toggled buff with no timer. If it doesn't exist cast it
	if "!${Me.Effect[${ToggleBuff3}](exists)}"
	{
		Me.Ability[${ToggleBuff3}]:Use
		call MeCasting
	}

	if "${HowManyToggleBuffs}<4"
	Return

	;This is a toggled buff with no timer. If it doesn't exist cast it
	if "!${Me.Effect[${ToggleBuff4}](exists)}"
	{
		Me.Ability[${ToggleBuff4}]:Use
		call MeCasting
	}

	if "${HowManyToggleBuffs}<5"
	Return

	;This is a toggled buff with no timer. If it doesn't exist cast it
	if "!${Me.Effect[${ToggleBuff5}](exists)} && ${HowManyToggleBuffs}>=5"
	{
		Me.Ability[${ToggleBuff5}]:Use
		call MeCasting
	}

	;Make sure pet is up


}

;================================================
function UseMeditation()
{

	;If I meditate, require Jin and use feign death this will put me back in meditation when my health is high and not in agro.
	if "!${Me.Effect[${WeMeditate}](exists)} && ${Me.Ability[${WeMeditate}].IsReady} && ${Me.HealthPct}>=${RequiredHP} && ${Me.Effect[${FeignDeath}](exists)} && !${Me.InCombat}"
	{
		;Health is low, meaditate.
		Me.Ability[${WeMeditate}]:Use
		Return
	}

	;Meditation now with a Feign Death check
	if "${DoWeHaveMeditation}  && !${Me.Effect[${WeMeditate}](exists)}&& ${Me.Ability[${WeMeditate}].IsReady} && !${Me.Effect[${FeignDeath}](exists)}"
	{
		if "${Me.HealthPct}<${RequiredHP} || ${Me.Stat["Adventuring","Jin"]}<${RequiredJin}"
		{
			;Health is low, meaditate.
			;Food use, this works with Meditation but not casting heals
			call UseFoodsDrinks
			Me.Ability[${WeMeditate}]:Use
			call AvoidAdds 25

		}
	}
}

;================================================
function Forms()
{
	if ${DoWeHaveForms}
	{
		;if !${Me.CurrentForm.Name.Equal[${AttackForm}]} && ${Me.Form[${AttackForm}].IsReady} && !${Me.Effect[${WeMeditate}](exists)} && !${Me.Effect[${FeignDeath}](exists)} && ${Me.HealthPct}>${ChangeFormAt}
		if !${Me.CurrentForm.Name.Equal[${AttackForm}]} && !${Me.Effect[${WeMeditate}](exists)} && !${Me.Effect[${FeignDeath}](exists)} && ${Me.HealthPct}>${ChangeFormAt}
		{
			Me.Form[${AttackForm}]:ChangeTo
			Return
		}

		;if !${Me.CurrentForm.Name.Equal[${DefForm}]} && ${Me.Form[${DefForm}].IsReady} && !${Me.Effect[${WeMeditate}](exists)} && !${Me.Effect[${FeignDeath}](exists)} && ${Me.HealthPct}<${ChangeFormAt}
		if !${Me.CurrentForm.Name.Equal[${DefForm}]} && !${Me.Effect[${WeMeditate}](exists)} && !${Me.Effect[${FeignDeath}](exists)} && ${Me.HealthPct}<${ChangeFormAt}
		{
			Me.Form[${DefForm}]:ChangeTo
			Return
		}
		;elseif !${Me.CurrentForm.Name.Equal[${NeutralForm}]} && ${Me.Form[${NeutralForm}].IsReady} && ${Me.Effect[${WeMeditate}](exists)}
		elseif !${Me.CurrentForm.Name.Equal[${NeutralForm}]} && ${Me.Effect[${WeMeditate}](exists)}
		{
			Me.Form[${NeutralForm}]:ChangeTo

		}
	}
}


