;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[VGA]:Clear
	LavishSettings[VGA_Mobs]:Clear
	LavishSettings[VGA_General]:Clear
	LavishSettings[VGA_Quests]:Clear
	LavishSettings[VGA_Diplo]:Clear
	LavishSettings:AddSet[VGA]
	LavishSettings:AddSet[VGA_Mobs]
	LavishSettings:AddSet[VGA_General]
	LavishSettings:AddSet[VGA_Quests]
	LavishSettings:AddSet[VGA_Diplo]

	LavishSettings[VGA]:AddSet[Healers]
	LavishSettings[VGA]:AddSet[Utility]
	LavishSettings[VGA]:AddSet[OpeningSpellSequence]
	LavishSettings[VGA]:AddSet[CombatSpellSequence]
	LavishSettings[VGA]:AddSet[AOESpell]
	LavishSettings[VGA]:AddSet[DotSpell]
	LavishSettings[VGA]:AddSet[DebuffSpell]
	LavishSettings[VGA]:AddSet[Spell]
	LavishSettings[VGA]:AddSet[OpeningMeleeSequence]
	LavishSettings[VGA]:AddSet[CombatMeleeSequence]
	LavishSettings[VGA]:AddSet[AOEMelee]
	LavishSettings[VGA]:AddSet[DotMelee]
	LavishSettings[VGA]:AddSet[DebuffMelee]
	LavishSettings[VGA]:AddSet[Melee]
	LavishSettings[VGA]:AddSet[AOECrits]
	LavishSettings[VGA]:AddSet[DotCrits]
	LavishSettings[VGA]:AddSet[BuffCrits]
	LavishSettings[VGA]:AddSet[CombatCrits]
	LavishSettings[VGA]:AddSet[Clickies]
	LavishSettings[VGA]:AddSet[Counter]
	LavishSettings[VGA]:AddSet[Dispell]
	LavishSettings[VGA]:AddSet[StancePush]
	LavishSettings[VGA]:AddSet[TurnOffAttack]
	LavishSettings[VGA]:AddSet[TurnOffDuringBuff]
	LavishSettings[VGA]:AddSet[Crits]
	LavishSettings[VGA]:AddSet[CounterAttack]
	LavishSettings[VGA]:AddSet[Evade]
	LavishSettings[VGA]:AddSet[Evade1]
	LavishSettings[VGA]:AddSet[Evade2]
	LavishSettings[VGA]:AddSet[Buff]
	LavishSettings[VGA]:AddSet[IceA]
	LavishSettings[VGA]:AddSet[FireA]
	LavishSettings[VGA]:AddSet[SpiritualA]
	LavishSettings[VGA]:AddSet[PhysicalA]
	LavishSettings[VGA]:AddSet[ArcaneA]
	LavishSettings[VGA]:AddSet[Triggers]
	LavishSettings[VGA]:AddSet[UseAbilT1]
	LavishSettings[VGA]:AddSet[UseItemsT1]
	LavishSettings[VGA]:AddSet[MobDeBuffT1]
	LavishSettings[VGA]:AddSet[BuffT1]
	LavishSettings[VGA]:AddSet[AbilReadyT1]
	LavishSettings[VGA]:AddSet[Class]
	LavishSettings[VGA]:AddSet[Rescue]
	LavishSettings[VGA]:AddSet[ForceRescue]
	LavishSettings[VGA]:AddSet[HealSequence]
	LavishSettings[VGA]:AddSet[EmergencyHealSequence]
	LavishSettings[VGA]:AddSet[DiploEquipment]

	LavishSettings[VGA_Mobs]:AddSet[Ice]
	LavishSettings[VGA_Mobs]:AddSet[Fire]
	LavishSettings[VGA_Mobs]:AddSet[Spiritual]
	LavishSettings[VGA_Mobs]:AddSet[Physical]
	LavishSettings[VGA_Mobs]:AddSet[Arcane]

	LavishSettings[VGA_General]:AddSet[BW]
	LavishSettings[VGA_General]:AddSet[DBW]
	LavishSettings[VGA_General]:AddSet[TBW]
	LavishSettings[VGA_General]:AddSet[Sell]	
	LavishSettings[VGA_General]:AddSet[Trash]
	LavishSettings[VGA_General]:AddSet[Interactions]	
	LavishSettings[VGA_General]:AddSet[Friends]

	LavishSettings[VGA_Quests]:AddSet[QuestNPCs]
	LavishSettings[VGA_Quests]:AddSet[Quests]

	LavishSettings[VGA_Diplo]:AddSet[DiploNPCs]
	LavishSettings[VGA_Diplo]:AddSet[Diplo]

	LavishSettings[VGA]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/${Me.FName}.xml]
	LavishSettings[VGA_Mobs]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Mobs.xml]
	LavishSettings[VGA_General]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_General.xml]
	LavishSettings[VGA_Quests]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Quests.xml]
	LavishSettings[VGA_Diplo]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Diplo.xml]

	call LavishLoad
}
;===================================================
;===               Healer Lavish Load           ====
;===================================================
function LavishLoad()
{
	HealerSR:Set[${LavishSettings[VGA].FindSet[Healers]}]
	Buff:Set[${LavishSettings[VGA].FindSet[Buff]}]
	LazyBuff:Set[${HealerSR.FindSetting[LazyBuff]}]
	ResStone:Set[${HealerSR.FindSetting[ResStone]}]
	CombatRes:Set[${HealerSR.FindSetting[CombatRes]}]
	NonCombatRes:Set[${HealerSR.FindSetting[NonCombatRes]}]
	HotHeal:Set[${HealerSR.FindSetting[HotHeal]}]
	InstantHeal:Set[${HealerSR.FindSetting[InstantHeal]}]
	InstantHeal2:Set[${HealerSR.FindSetting[InstantHeal2]}]
	SmallHeal:Set[${HealerSR.FindSetting[SmallHeal]}]
	BigHeal:Set[${HealerSR.FindSetting[BigHeal]}]
	InstantGroupHeal:Set[${HealerSR.FindSetting[InstantGroupHeal]}]
	GroupHeal:Set[${HealerSR.FindSetting[GroupHeal]}]

	variable int i
	for (i:Set[1] ; ${i}<=24 ; i:Inc)
		{
		hgrp[${i}]:Set[${HealerSR.FindSetting[hgrp${i}]}]
		ghpctgrp[${i}]:Set[${HealerSR.FindSetting[ghpctgrp${i}]}]
		ighpctgrp[${i}]:Set[${HealerSR.FindSetting[ighpctgrp${i}]}]
		hhpctgrp[${i}]:Set[${HealerSR.FindSetting[hhpctgrp${i}]}]
		fhpctgrp[${i}]:Set[${HealerSR.FindSetting[fhpctgrp${i}]}]
		hpctgrp[${i}]:Set[${HealerSR.FindSetting[hpctgrp${i}]}]
		bhpctgrp[${i}]:Set[${HealerSR.FindSetting[bhpctgrp${i}]}]
		}

	doCombatStance:Set[${HealerSR.FindSetting[doCombatStance]}]
	doNonCombatStance:Set[${HealerSR.FindSetting[doNonCombatStance]}]
	CombatStance:Set[${HealerSR.FindSetting[CombatStance]}]
	NonCombatStance:Set[${HealerSR.FindSetting[NonCombatStance]}]
	ClickieForce:Set[${HealerSR.FindSetting[ClickieForce]}]	
 	 doClickieForce:Set[${HealerSR.FindSetting[doClickieForce]}]	
  	doRestoreSpecial:Set[${HealerSR.FindSetting[doRestoreSpecial]}]	
  	RestoreSpecialint:Set[${HealerSR.FindSetting[RestoreSpecialint]}]	
  	RestoreSpecial:Set[${HealerSR.FindSetting[RestoreSpecial]}]	
	DoByPassVGAHeals:Set[${HealerSR.FindSetting[DoByPassVGAHeals]}]	
	TankHealPct:Set[${HealerSR.FindSetting[TankHealPct,${TankHealPct}]}]
	TankEmerHealPct:Set[${HealerSR.FindSetting[TankEmerHealPct,${TankEmerHealPct}]}]
	MedHealPct:Set[${HealerSR.FindSetting[MedHealPct,${MedHealPct}]}]
	MedEmerHealPct:Set[${HealerSR.FindSetting[MedEmerHealPct,${MedEmerHealPct}]}]
	SquishyHealPct:Set[${HealerSR.FindSetting[SquishyHealPct,${SquishyHealPct}]}]
	SquishyEmerHealPct:Set[${HealerSR.FindSetting[SquishyEmerHealPct,${SquishyEmerHealPct}]}]
	kiss:Set[${HealerSR.FindSetting[kiss,${kiss}]}]
	HealCrit1:Set[${HealerSR.FindSetting[HealCrit1,${HealCrit1}]}]
	HealCrit2:Set[${HealerSR.FindSetting[HealCrit2,${HealCrit2}]}]
	InstantHotHeal1:Set[${HealerSR.FindSetting[InstantHotHeal1,${InstantHotHeal1}]}]
	InstantHotHeal2:Set[${HealerSR.FindSetting[InstantHotHeal2,${InstantHotHeal2}]}]
	TapSoloHeal:Set[${HealerSR.FindSetting[TapSoloHeal,${TapSoloHeal}]}]

	DoResInCombat:Set[${HealerSR.FindSetting[DoResInCombat,${DoResInCombat}]}]
	DoResNotInCombat:Set[${HealerSR.FindSetting[DoResNotInCombat,${DoResNotInCombat}]}]
	DoResRaid:Set[${HealerSR.FindSetting[DoResRaid,${DoResRaid}]}]

	;===================================================
	;===              Diplo Equipment Load          ====
	;===================================================
	DiploEquipmentSR:Set[${LavishSettings[VGA].FindSet[DiploEquipment]}]
	variable int di
	for (di:Set[1] ; ${di}<=8 ; di:Inc)
		{
		DiploLeftEar[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploLeftEar${di}]}]
		DiploRightEar[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploRightEar${di}]}]
		DiploFace[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploFace${di}]}]
		DiploCloak[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploCloak${di}]}]
		DiploNeck[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploNeck${di}]}]
		DiploShoulder[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploShoulder${di}]}]
		DiploWrist[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploWrist${di}]}]
		DiploChest[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploChest${di}]}]
		DiploHands[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploHands${di}]}]
		DiploHeld[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploHeld${di}]}]
		DiploBelt[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploBelt${di}]}]
		DiploBoots[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploBoots${di}]}]
		DiploLeftRing[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploLeftRing${di}]}]
		DiploRightRing[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploRightRing${di}]}]
		DiploLegs[${di}]:Set[${DiploEquipmentSR.FindSetting[DiploLegs${di}]}]
		}
	;===================================================
	;===                  Utility Load              ====
	;===================================================
	UtilitySR:Set[${LavishSettings[VGA].FindSet[Utility]}]
	doassistpawn:Set[${UtilitySR.FindSetting[doassistpawn]}]
	dofollowpawn:Set[${UtilitySR.FindSetting[dofollowpawn]}]
	followpawndist:Set[${UtilitySR.FindSetting[followpawndist]}]
	MoveToTargetPct:Set[${UtilitySR.FindSetting[MoveToTargetPct]}]
	doMoveToTarget:Set[${UtilitySR.FindSetting[doMoveToTarget]}]
	doFaceTarget:Set[${UtilitySR.FindSetting[doFaceTarget]}]
	DoLoot:Set[${UtilitySR.FindSetting[DoLoot]}]
	AssistBattlePct:Set[${UtilitySR.FindSetting[AssistBattlePct]}]
	SlowHeals:Set[${UtilitySR.FindSetting[SlowHeals]}]
	doParser:Set[${UtilitySR.FindSetting[doParser]}]
	doDebug:Set[${UtilitySR.FindSetting[doDebug]}]
	doActionLog:Set[${UtilitySR.FindSetting[doActionLog]}]
	doSell:Set[${UtilitySR.FindSetting[doSell]}]
	doTrash:Set[${UtilitySR.FindSetting[doTrash]}]
	Sell:Set[${LavishSettings[VGA_General].FindSet[Sell]}]
	Trash:Set[${LavishSettings[VGA_General].FindSet[Trash]}]
	DoChainsASAP:Set[${UtilitySR.FindSetting[FALSE,FALSE]}]
	DoCountersASAP:Set[${UtilitySR.FindSetting[FALSE,FALSE]}]
	DoMount:Set[${UtilitySR.FindSetting[DoMount,FALSE]}]
	DoShiftingImage:Set[${UtilitySR.FindSetting[DoShiftingImage,FALSE]}]
	ShiftingImage:Set[${UtilitySR.FindSetting[ShiftingImage,TRUE]}]
	DoAutoAcceptGroupInvite:Set[${UtilitySR.FindSetting[DoAutoAcceptGroupInvite,TRUE]}]
	DoLooseTarget:Set[${UtilitySR.FindSetting[DoLooseTarget,${DoLooseTarget}]}]
	AssistEncounter:Set[${UtilitySR.FindSetting[AssistEncounter,${AssistEncounter}]}]
	DoFollowInCombat:Set[${UtilitySR.FindSetting[DoFollowInCombat,${DoFollowInCombat}]}]
	doAutoSell:Set[${UtilitySR.FindSetting[doAutoSell,${doAutoSell}]}]
	doHarvest:Set[${UtilitySR.FindSetting[doHarvest,${doHarvest}]}]
	DoLootOnly:Set[${UtilitySR.FindSetting[DoLootOnly,${DoLootOnly}]}]
	LootOnly:Set[${UtilitySR.FindSetting[LootOnly,${LootOnly}]}]
	LootDelay:Set[${UtilitySR.FindSetting[LootDelay,${LootDelay}]}]
	DoNaturalFollow:Set[${UtilitySR.FindSetting[DoNaturalFollow,${DoNaturalFollow}]}]	

	DoClassDownTime:Set[${UtilitySR.FindSetting[DoClassDownTime,${DoClassDownTime}]}]
	DoClassPreCombat:Set[${UtilitySR.FindSetting[DoClassPreCombat,${DoClassPreCombat}]}]	
	DoClassOpener:Set[${UtilitySR.FindSetting[DoClassOpener,${DoClassOpener}]}]
	DoClassCombat:Set[${UtilitySR.FindSetting[DoClassCombat,${DoClassCombat}]}]	
	DoClassPostCombat:Set[${UtilitySR.FindSetting[DoClassPostCombat,${DoClassPostCombat}]}]
	DoClassEmergency:Set[${UtilitySR.FindSetting[DoClassEmergency,${DoClassEmergency}]}]	
	DoClassPostCasting:Set[${UtilitySR.FindSetting[DoClassPostCasting,${DoClassPostCasting}]}]
	DoClassBurst:Set[${UtilitySR.FindSetting[DoClassBurst,${DoClassBurst}]}]

	DoAttackPositionFront:Set[${UtilitySR.FindSetting[DoAttackPositionFront,${DoAttackPositionFront}]}]
	DoAttackPositionLeft:Set[${UtilitySR.FindSetting[DoAttackPositionLeft,${DoAttackPositionLeft}]}]
	DoAttackPositionRight:Set[${UtilitySR.FindSetting[DoAttackPositionRight,${DoAttackPositionRight}]}]
	DoAttackPositionBack:Set[${UtilitySR.FindSetting[DoAttackPositionBack,${DoAttackPositionBack}]}]
	DoAttackPosition:Set[${UtilitySR.FindSetting[DoAttackPosition,${DoAttackPosition}]}]
	DoPopCrates:Set[${UtilitySR.FindSetting[DoPopCrates,${DoPopCrates}]}]
	DoDiplo:Set[${UtilitySR.FindSetting[DoDiplo,${DoDiplo}]}]
	DiploToggle:Set[${UtilitySR.FindSetting[DiploToggle,${DiploToggle}]}]
	DoRemoveLowDiplo:Set[${UtilitySR.FindSetting[DoRemoveLowDiplo,${DoRemoveLowDiplo}]}]
	LootToggle:Set[${UtilitySR.FindSetting[LootToggle,${LootToggle}]}]
	DoDiploToggle:Set[${UtilitySR.FindSetting[DoDiploToggle,${DoDiploToggle}]}]
	DoLootToggle:Set[${UtilitySR.FindSetting[DoLootToggle,${DoLootToggle}]}]
	Friends:Set[${LavishSettings[VGA_General].FindSet[Friends]}]

	DoAcceptRes:Set[${UtilitySR.FindSetting[DoAcceptRes,${DoAcceptRes}]}]
	Speed:Set[${UtilitySR.FindSetting[Speed,${Speed}]}]
	DoAutoResCombat:Set[${UtilitySR.FindSetting[DoAutoResCombat,${DoAutoResCombat}]}]
	DoAutoResNoCombat:Set[${UtilitySR.FindSetting[DoAutoResNoCombat,${DoAutoResNoCombat}]}]

	DoChargeFollow:Set[${UtilitySR.FindSetting[DoChargeFollow,${DoChargeFollow}]}]
	;===================================================
	;===                  Spells Load               ====
	;===================================================
	OpeningSpellSequence:Set[${LavishSettings[VGA].FindSet[OpeningSpellSequence]}]
	CombatSpellSequence:Set[${LavishSettings[VGA].FindSet[CombatSpellSequence]}]
	AOESpell:Set[${LavishSettings[VGA].FindSet[AOESpell]}]
	DotSpell:Set[${LavishSettings[VGA].FindSet[DotSpell]}]
	DebuffSpell:Set[${LavishSettings[VGA].FindSet[DebuffSpell]}]
	SpellSR:Set[${LavishSettings[VGA].FindSet[Spell]}]
	
	doOpeningSeqSpell:Set[${SpellSR.FindSetting[doOpeningSeqSpell]}]
	doCritsDuringOpeningSeqSpell:Set[${SpellSR.FindSetting[doCritsDuringOpeningSeqSpell]}]
	doCombatSeqSpell:Set[${SpellSR.FindSetting[doCombatSeqSpell]}]
	doAOESpell:Set[${SpellSR.FindSetting[doAOESpell]}]
	doDotSpell:Set[${SpellSR.FindSetting[doDotSpell]}]
	doDebuffSpell:Set[${SpellSR.FindSetting[doDebuffSpell]}]
	DispellSpell:Set[${SpellSR.FindSetting[DispellSpell]}]
	PushStanceSpell:Set[${SpellSR.FindSetting[PushStanceSpell]}]
	CounterSpell1:Set[${SpellSR.FindSetting[CounterSpell1]}]
	CounterSpell2:Set[${SpellSR.FindSetting[CounterSpell2]}]
	doSlowAttacks:Set[${SpellSR.FindSetting[doSlowAttacks]}]
	SlowAttacks:Set[${SpellSR.FindSetting[SlowAttacks]}]
	
	;===================================================
	;===                  Mobs Load                 ====
	;===================================================
	Ice:Set[${LavishSettings[VGA_Mobs].FindSet[Ice]}]
	Fire:Set[${LavishSettings[VGA_Mobs].FindSet[Fire]}]
	Spiritual:Set[${LavishSettings[VGA_Mobs].FindSet[Spiritual]}]
	Physical:Set[${LavishSettings[VGA_Mobs].FindSet[Physical]}]
	Arcane:Set[${LavishSettings[VGA_Mobs].FindSet[Arcane]}]
	
	;===================================================
	;===                  Melee Load                ====
	;===================================================
	OpeningMeleeSequence:Set[${LavishSettings[VGA].FindSet[OpeningMeleeSequence]}]
	CombatMeleeSequence:Set[${LavishSettings[VGA].FindSet[CombatMeleeSequence]}]
	AOEMelee:Set[${LavishSettings[VGA].FindSet[AOEMelee]}]
	DotMelee:Set[${LavishSettings[VGA].FindSet[DotMelee]}]
	DebuffMelee:Set[${LavishSettings[VGA].FindSet[DebuffMelee]}]
	Melee:Set[${LavishSettings[VGA].FindSet[Melee]}]
	
	doOpeningSeqMelee:Set[${Melee.FindSetting[doOpeningSeqMelee]}]
	doCritsDuringOpeningSeqMelee:Set[${Melee.FindSetting[doCritsDuringOpeningSeqMelee]}]
	doCombatSeqMelee:Set[${Melee.FindSetting[doCombatSeqMelee]}]
	doAOEMelee:Set[${Melee.FindSetting[doAOEMelee]}]
	doDotMelee:Set[${Melee.FindSetting[doDotMelee]}]
	doDebuffMelee:Set[${Melee.FindSetting[doDebuffMelee]}]
	doKillingBlow:Set[${Melee.FindSetting[doKillingBlow]}]
	KillingBlow:Set[${Melee.FindSetting[KillingBlow]}]	
	;===================================================
	;===                  Evade Load                ====
	;===================================================
	Evade1:Set[${LavishSettings[VGA].FindSet[Evade1]}]
	Evade2:Set[${LavishSettings[VGA].FindSet[Evade2]}]
	Evade:Set[${LavishSettings[VGA].FindSet[Evade]}]
	Rescue:Set[${LavishSettings[VGA].FindSet[Rescue]}]
	ForceRescue:Set[${LavishSettings[VGA].FindSet[ForceRescue]}]
	
	agropush:Set[${Evade.FindSetting[agropush]}]
	doPushAgro:Set[${Evade.FindSetting[doPushAgro]}]
	doRescue:Set[${Evade.FindSetting[doRescue]}]
	doInvoln1:Set[${Evade.FindSetting[doInvoln1]}]
	doInvoln2:Set[${Evade.FindSetting[doInvoln2]}]
	doEvade1:Set[${Evade.FindSetting[doEvade1]}]
	doEvade2:Set[${Evade.FindSetting[doEvade2]}]
	doFD:Set[${Evade.FindSetting[doFD]}]
	FDPct:Set[${Evade.FindSetting[FDPct]}]
	Involn1Pct:Set[${Evade.FindSetting[Involn1Pct]}]
	Involn2Pct:Set[${Evade.FindSetting[Involn2Pct]}]
	FD:Set[${Evade.FindSetting[FD]}]
	Involn1:Set[${Evade.FindSetting[Involn1]}]
	Involn2:Set[${Evade.FindSetting[Involn2]}]
	HealerSR:Set[${LavishSettings[VGA].FindSet[Healers]}]
	
	;===================================================
	;===                  Crits Load                ====
	;===================================================
	AOECrits:Set[${LavishSettings[VGA].FindSet[AOECrits]}]
	BuffCrits:Set[${LavishSettings[VGA].FindSet[BuffCrits]}]
	DotCrits:Set[${LavishSettings[VGA].FindSet[DotCrits]}]
	CombatCrits:Set[${LavishSettings[VGA].FindSet[CombatCrits]}]
	CounterAttack:Set[${LavishSettings[VGA].FindSet[CounterAttack]}]
	Crits:Set[${LavishSettings[VGA].FindSet[Crits]}]
	
	doCombatCrits:Set[${Crits.FindSetting[doCombatCrits]}]
	doBuffCrits:Set[${Crits.FindSetting[doBuffCrits]}]
	doDotCrits:Set[${Crits.FindSetting[doDotCrits]}]
	doAOECrits:Set[${Crits.FindSetting[doAOECrits]}]
	doCounterAttack:Set[${Crits.FindSetting[doCounterAttack]}]
	
	;===================================================
	;===            Combat Main Load                ====
	;===================================================
	Clickies:Set[${LavishSettings[VGA].FindSet[Clickies]}]
	Dispell:Set[${LavishSettings[VGA].FindSet[Dispell]}]
	StancePush:Set[${LavishSettings[VGA].FindSet[StancePush]}]
	TurnOffAttack:Set[${LavishSettings[VGA].FindSet[TurnOffAttack]}]
	TurnOffDuringBuff:Set[${LavishSettings[VGA].FindSet[TurnOffDuringBuff]}]
	Counter:Set[${LavishSettings[VGA].FindSet[Counter]}]
	
	doClickies:Set[${SpellSR.FindSetting[doClickies]}]
	doDispell:Set[${SpellSR.FindSetting[doDispell]}]
	doStancePush:Set[${SpellSR.FindSetting[doStancePush]}]
	doTurnOffAttack:Set[${SpellSR.FindSetting[doTurnOffAttack]}]
	doCounter:Set[${SpellSR.FindSetting[doCounter]}]
	doFurious:Set[${SpellSR.FindSetting[doFurious]}]
	
	;===================================================
	;===              Abilities Load                ====
	;===================================================
	IceA:Set[${LavishSettings[VGA].FindSet[IceA]}]
	FireA:Set[${LavishSettings[VGA].FindSet[FireA]}]
	SpiritualA:Set[${LavishSettings[VGA].FindSet[SpiritualA]}]
	PhysicalA:Set[${LavishSettings[VGA].FindSet[PhysicalA]}]
	ArcaneA:Set[${LavishSettings[VGA].FindSet[ArcaneA]}]
	
	
	;===================================================
	;===              BuffWatch Load                ====
	;===================================================
	TBW:Set[${LavishSettings[VGA_General].FindSet[TBW]}]
	DBW:Set[${LavishSettings[VGA_General].FindSet[DBW]}]
	BW:Set[${LavishSettings[VGA_General].FindSet[BW]}]
	
	;===================================================
	;===            Interactions   Load             ====
	;===================================================
	Interactions:Set[${LavishSettings[VGA_General].FindSet[Interactions]}]
	doRequestBuffs[1]:Set[${Interactions.FindSetting[doRequestBuffs1,${doRequestBuffs1}]}]
	RequestBuff[1]:Set[${Interactions.FindSetting[RequestBuff1,${RequestBuff1}]}]
	RequestBuffPlayer[1]:Set[${Interactions.FindSetting[RequestBuffPlayer1,${RequestBuffPlayer[1]}]}]
	TellRequestBuffPlayer[1]:Set[${Interactions.FindSetting[TellRequestBuffPlayer1,${TellRequestBuffPlayer1}]}]
	doRequestBuffs[2]:Set[${Interactions.FindSetting[doRequestBuffs2,${doRequestBuffs2}]}]
	RequestBuff[2]:Set[${Interactions.FindSetting[RequestBuff2,${RequestBuff2}]}]
	RequestBuffPlayer[2]:Set[${Interactions.FindSetting[RequestBuffPlayer2,${RequestBuffPlayer2}]}]
	TellRequestBuffPlayer[2]:Set[${Interactions.FindSetting[TellRequestBuffPlayer2,${TellRequestBuffPlayer2}]}]
	doRequestBuffs[3]:Set[${Interactions.FindSetting[doRequestBuffs3,${doRequestBuffs3}]}]
	RequestBuff[3]:Set[${Interactions.FindSetting[RequestBuff3,${RequestBuff3}]}]
	RequestBuffPlayer[3]:Set[${Interactions.FindSetting[RequestBuffPlayer3,${RequestBuffPlayer3}]}]
	TellRequestBuffPlayer[3]:Set[${Interactions.FindSetting[TellRequestBuffPlayer3,${TellRequestBuffPlayer3}]}]
	doRequestBuffs[4]:Set[${Interactions.FindSetting[doRequestBuffs4,${doRequestBuffs4}]}]
	RequestBuff[4]:Set[${Interactions.FindSetting[RequestBuff4,${RequestBuff4}]}]
	RequestBuffPlayer[4]:Set[${Interactions.FindSetting[RequestBuffPlayer4,${RequestBuffPlayer4}]}]
	TellRequestBuffPlayer[4]:Set[${Interactions.FindSetting[TellRequestBuffPlayer4,${TellRequestBuffPlayer4}]}]
	doRequestItems[1]:Set[${Interactions.FindSetting[doRequestItems1,${doRequestItems1}]}]
	RequestItems[1]:Set[${Interactions.FindSetting[RequestItems1,${RequestItems1}]}]
	RequestItemsPlayer[1]:Set[${Interactions.FindSetting[RequestItemsPlayer1,${RequestItemsPlayer1}]}]
	TellRequestItemsPlayer[1]:Set[${Interactions.FindSetting[TellRequestItemsPlayer1,${TellRequestItemsPlayer1}]}]
	doRequestItems[2]:Set[${Interactions.FindSetting[doRequestItems2,${doRequestItems2}]}]
	RequestItems[2]:Set[${Interactions.FindSetting[RequestItems2,${RequestItems2}]}]
	RequestItemsPlayer[2]:Set[${Interactions.FindSetting[RequestItemsPlayer2,${RequestItemsPlayer2}]}]
	TellRequestItemsPlayer[2]:Set[${Interactions.FindSetting[TellRequestItemsPlayer2,${TellRequestItemsPlayer2}]}]
	DoStopFollow:Set[${Interactions.FindSetting[DoStopFollow,${DoStopFollow}]}]
	StopFollowtxt:Set[${Interactions.FindSetting[StopFollowtxt,${StopFollowtxt}]}]
	DoStartFollow:Set[${Interactions.FindSetting[DoStartFollow,${DoStartFollow}]}]
	StartFollowtxt:Set[${Interactions.FindSetting[StartFollowtxt,${StartFollowtxt}]}]
	DoKillLevitate:Set[${Interactions.FindSetting[DoKillLevitate,${DoKillLevitate}]}]
	KillingLevitate:Set[${Interactions.FindSetting[KillingLevitate,${KillingLevitate}]}]
	DoReassistTank:Set[${Interactions.FindSetting[DoReassistTank,${DoReassistTank}]}]
	ReassistingTank:Set[${Interactions.FindSetting[ReassistingTank,${ReassistingTank}]}]
	DoPause:Set[${Interactions.FindSetting[DoPause,${DoPause}]}]
	Pausetxt:Set[${Interactions.FindSetting[Pausetxt,${Pausetxt}]}]
	DoBuffage:Set[${Interactions.FindSetting[DoBuffage,${DoBuffage}]}]
	Buffagetxt:Set[${Interactions.FindSetting[Buffagetxt,${Buffagetxt}]}]
	DoResume:Set[${Interactions.FindSetting[DoResume,${DoResume}]}]
	Resumetxt:Set[${Interactions.FindSetting[Resumetxt,${Resumetxt}]}]
	DoBurstCall:Set[${Interactions.FindSetting[DoBurstCall,${DoBurstCall}]}]
	BurstCalltxt:Set[${Interactions.FindSetting[BurstCalltxt,${BurstCalltxt}]}]
	
	Class:Set[${LavishSettings[VGA].FindSet[Class]}]
	switch ${Me.Class}
	{
		case Bard
			PrimaryWeapon:Set[${Class.FindSetting[PrimaryWeapon,${PrimaryWeapon}]}]
			SecondaryWeapon:Set[${Class.FindSetting[SecondaryWeapon,${SecondaryWeapon}]}]
			FightSong:Set[${Class.FindSetting[FightSong,${FightSong}]}]
			RunSong:Set[${Class.FindSetting[RunSong,${RunSong}]}]
			Drum:Set[${Class.FindSetting[Drum,${Drum}]}]
			break
			
		case Blood Mage
			BMHealthToEnergySpell:Set[${Class.FindSetting[BMHealthToEnergySpell,${BMHealthToEnergySpell}]}]
			BMBloodUnionDumpDPSSpell:Set[${Class.FindSetting[BMBloodUnionDumpDPSSpell,${BMBloodUnionDumpDPSSpell}]}]
			BMSingleTargetLifeTap1:Set[${Class.FindSetting[BMSingleTargetLifeTap1,${BMSingleTargetLifeTap1}]}]
			BMSingleTargetLifeTap2:Set[${Class.FindSetting[BMSingleTargetLifeTap2,${BMSingleTargetLifeTap2}]}]
			BMBloodUnionSingleTargetHOT:Set[${Class.FindSetting[BMBloodUnionSingleTargetHOT,${BMBloodUnionSingleTargetHOT}]}]
			break
	}
	;===================================================
	;===                 Quests   Load              ====
	;===================================================
	
	QuestNPCs:Set[${LavishSettings[VGA_Quests].FindSet[QuestNPCs]}]
	Quests:Set[${LavishSettings[VGA_Quests].FindSet[Quests]}]
	;===================================================
	;===                 Diplo   Load               ====
	;===================================================
	
	DiploNPCs:Set[${LavishSettings[VGA_Diplo].FindSet[DiploNPCs]}]
	Diplo:Set[${LavishSettings[VGA_Diplo].FindSet[Diplo]}]
}
