;===================================================
;===               Healer Lavish Save           ====
;===================================================
function LavishSave()
{
	HealerSR:AddSetting[LazyBuff,${LazyBuff}]
	HealerSR:AddSetting[ResStone,${ResStone}]
	HealerSR:AddSetting[CombatRes,${CombatRes}]
	HealerSR:AddSetting[NonCombatRes,${NonCombatRes}]
	HealerSR:AddSetting[HotHeal,${HotHeal}]
	HealerSR:AddSetting[InstantHeal,${InstantHeal}]
	HealerSR:AddSetting[InstantHeal2,${InstantHeal2}]
	HealerSR:AddSetting[SmallHeal,${SmallHeal}]
	HealerSR:AddSetting[BigHeal,${BigHeal}]
	HealerSR:AddSetting[InstantGroupHeal,${InstantGroupHeal}]
	HealerSR:AddSetting[GroupHeal,${GroupHeal}]
	variable int i
	for (i:Set[1] ; ${i}<=24 ; i:Inc)
		{
		HealerSR:AddSetting[hgrp${i},${hgrp[${i}]}]
		HealerSR:AddSetting[fhpctgrp${i},${fhpctgrp[${i}]}]
		HealerSR:AddSetting[hhpctgrp${i},${hhpctgrp[${i}]}]
		HealerSR:AddSetting[ghpctgrp${i},${ghpctgrp[${i}]}]
		HealerSR:AddSetting[ghpctgrp24,${ghpctgrp[24]}]
		HealerSR:AddSetting[ighpctgrp${i},${ighpctgrp[${i}]}]
		HealerSR:AddSetting[hpctgrp${i},${hpctgrp[${i}]}]
		HealerSR:AddSetting[bhpctgrp${i},${bhpctgrp[${i}]}]
		}



	HealerSR:AddSetting[doCombatStance,${doCombatStance}]	
	HealerSR:AddSetting[doNonCombatStance,${doNonCombatStance}]	
	HealerSR:AddSetting[CombatStance,${CombatStance}]	
	HealerSR:AddSetting[NonCombatStance,${NonCombatStance}]	
  HealerSR:AddSetting[ClickieForce,${ClickieForce}]	
  HealerSR:AddSetting[doRestoreSpecial,${doRestoreSpecial}]	
  HealerSR:AddSetting[RestoreSpecial,${RestoreSpecial}]	
  HealerSR:AddSetting[RestoreSpecialint,${RestoreSpecialint}]	
  HealerSR:AddSetting[doClickieForce,${doClickieForce}]	
  HealerSR:AddSetting[DoByPassVGAHeals,${DoByPassVGAHeals}]	
HealerSR:AddSetting[TankHealPct,${TankHealPct}]
HealerSR:AddSetting[TankEmerHealPct,${TankEmerHealPct}]
HealerSR:AddSetting[MedHealPct,${MedHealPct}]
HealerSR:AddSetting[MedEmerHealPct,${MedEmerHealPct}]
HealerSR:AddSetting[SquishyHealPct,${SquishyHealPct}]
HealerSR:AddSetting[SquishyEmerHealPct,${SquishyEmerHealPct}]

HealerSR:AddSetting[kiss,${kiss}]
HealerSR:AddSetting[HealCrit1,${HealCrit1}]
HealerSR:AddSetting[HealCrit2,${HealCrit2}]
HealerSR:AddSetting[InstantHotHeal1,${InstantHotHeal1}]
HealerSR:AddSetting[InstantHotHeal2,${InstantHotHeal2}]
HealerSR:AddSetting[TapSoloHeal,${TapSoloHeal}]

HealerSR:AddSetting[DoResInCombat,${DoResInCombat}]
HealerSR:AddSetting[DoResNotInCombat,${DoResNotInCombat}]
HealerSR:AddSetting[DoResRaid,${DoResRaid}]

	;===================================================
	;===                  Utility Save              ====
	;===================================================
	UtilitySR:AddSetting[doassistpawn,${doassistpawn}]
	UtilitySR:AddSetting[dofollowpawn,${dofollowpawn}]
	UtilitySR:AddSetting[followpawndist,${followpawndist}]
	UtilitySR:AddSetting[MoveToTargetPct,${MoveToTargetPct}]
	UtilitySR:AddSetting[doMoveToTarget,${doMoveToTarget}]
	UtilitySR:AddSetting[doFaceTarget,${doFaceTarget}]
	UtilitySR:AddSetting[AssistBattlePct,${AssistBattlePct}]
	UtilitySR:AddSetting[SlowHeals,${SlowHeals}]
	UtilitySR:AddSetting[doDebug,${doDebug}]
	UtilitySR:AddSetting[doParser,${doParser}]
	UtilitySR:AddSetting[doActionLog,${doActionLog}]
	UtilitySR:AddSetting[doSell,${doSell}]
	UtilitySR:AddSetting[doTrash,${doTrash}]
	UtilitySR:AddSetting[DoLoot,${DoLoot}]
	UtilitySR:AddSetting[DoCountersASAP,${DoCountersASAP}]
	UtilitySR:AddSetting[DoChainsASAP,${DoChainsASAP}]
	UtilitySR:AddSetting[DoMount,${DoMount}]
	UtilitySR:AddSetting[DoShiftingImage,${DoShiftingImage}]
	UtilitySR:AddSetting[ShiftingImage,${ShiftingImage}]	
	UtilitySR:AddSetting[DoAutoAcceptGroupInvite,${DoAutoAcceptGroupInvite}]
	UtilitySR:AddSetting[DoLooseTarget,${DoLooseTarget}]
	UtilitySR:AddSetting[AssistEncounter,${AssistEncounter}]	
	UtilitySR:AddSetting[DoFollowInCombat,${DoFollowInCombat}]	
	UtilitySR:AddSetting[doAutoSell,${doAutoSell}]
	UtilitySR:AddSetting[doHarvest,${doHarvest}]
	UtilitySR:AddSetting[DoLootOnly,${DoLootOnly}]
	UtilitySR:AddSetting[LootOnly,${LootOnly}]
	UtilitySR:AddSetting[LootDelay,${LootDelay}]

	UtilitySR:AddSetting[DoClassDownTime,${DoClassDownTime}]
	UtilitySR:AddSetting[DoClassPreCombat,${DoClassPreCombat}]
	UtilitySR:AddSetting[DoClassOpener,${DoClassOpener}]
	UtilitySR:AddSetting[DoClassCombat,${DoClassCombat}]
	UtilitySR:AddSetting[DoClassPostCombat,${DoClassPostCombat}]
	UtilitySR:AddSetting[DoClassEmergency,${DoClassEmergency}]
	UtilitySR:AddSetting[DoClassPostCasting,${DoClassPostCasting}]
	UtilitySR:AddSetting[DoClassBurst,${DoClassBurst}]
	UtilitySR:AddSetting[DoChargeFollow,${DoChargeFollow}]

	UtilitySR:AddSetting[DoAttackPositionFront,${DoAttackPositionFront}]
	UtilitySR:AddSetting[DoAttackPositionLeft,${DoAttackPositionLeft}]
	UtilitySR:AddSetting[DoAttackPositionRight,${DoAttackPositionRight}]
	UtilitySR:AddSetting[DoAttackPositionBack,${DoAttackPositionBack}]
	UtilitySR:AddSetting[DoAttackPosition,${DoAttackPosition}]
	UtilitySR:AddSetting[DoPopCrates,${DoPopCrates}]

	UtilitySR:AddSetting[DoAcceptRes,${DoAcceptRes}]
	UtilitySR:AddSetting[DoAutoResCombat,${DoAutoResCombat}]
	UtilitySR:AddSetting[DoAutoResNoCombat,${DoAutoResNoCombat}]
	UtilitySR:AddSetting[Speed,${Speed}]
	UtilitySR:AddSetting[DoDiplo,${DoDiplo}]
	UtilitySR:AddSetting[DiploToggle,${DiploToggle}]
	UtilitySR:AddSetting[LootToggle,${LootToggle}]
	UtilitySR:AddSetting[DoDiploToggle,${DoDiploToggle}]
	UtilitySR:AddSetting[DoLootToggle,${DoLootToggle}]
	UtilitySR:AddSetting[DoRemoveLowDiplo,${DoRemoveLowDiplo}]
	UtilitySR:AddSetting[DoNaturalFollow,${DoNaturalFollow}]

	;===================================================
	;===                  Spells Save               ====
	;===================================================
	SpellSR:AddSetting[doOpeningSeqSpell,${doOpeningSeqSpell}]
	SpellSR:AddSetting[doCritsDuringOpeningSeqSpell,${doCritsDuringOpeningSeqSpell}]
	SpellSR:AddSetting[doCombatSeqSpell,${doCombatSeqSpell}]
	SpellSR:AddSetting[doAOESpell,${doAOESpell}]
	SpellSR:AddSetting[doDotSpell,${doDotSpell}]
	SpellSR:AddSetting[DispellSpell,${DispellSpell}]
	SpellSR:AddSetting[PushStanceSpell,${PushStanceSpell}]
	SpellSR:AddSetting[CounterSpell1,${CounterSpell1}]
	SpellSR:AddSetting[CounterSpell2,${CounterSpell2}]
	SpellSR:AddSetting[doDebuffSpell,${doDebuffSpell}]
	SpellSR:AddSetting[doSlowAttacks,${doSlowAttacks}]
	SpellSR:AddSetting[SlowAttacks,${SlowAttacks}]

	;===================================================
	;===             Diplo Equipment Save           ====
	;===================================================
	variable int di
	for (di:Set[1] ; ${di}<=8 ; di:Inc)
		{
		DiploEquipmentSR:AddSetting[DiploLeftEar${di},${DiploLeftEar${di}}]
		DiploEquipmentSR:AddSetting[DiploRightEar${di},${DiploRightEar${di}}]
		DiploEquipmentSR:AddSetting[DiploFace${di},${DiploFace${di}}]
		DiploEquipmentSR:AddSetting[DiploCloak${di},${DiploCloak${di}}]
		DiploEquipmentSR:AddSetting[DiploNeck${di},${DiploNeck${di}}]
		DiploEquipmentSR:AddSetting[DiploShoulder${di},${DiploShoulder${di}}]
		DiploEquipmentSR:AddSetting[DiploWrist${di},${DiploWrist${di}}]
		DiploEquipmentSR:AddSetting[DiploChest${di},${DiploChest${di}}]
		DiploEquipmentSR:AddSetting[DiploHands${di},${DiploHands${di}}]
		DiploEquipmentSR:AddSetting[DiploHeld${di},${DiploHeld${di}}]
		DiploEquipmentSR:AddSetting[DiploBelt${di},${DiploBelt${di}}]
		DiploEquipmentSR:AddSetting[DiploBoots${di},${DiploBoots${di}}]
		DiploEquipmentSR:AddSetting[DiploLeftRing${di},${DiploLeftRing${di}}]
		DiploEquipmentSR:AddSetting[DiploRightRing${di},${DiploRightRing${di}}]
		DiploEquipmentSR:AddSetting[DiploLegs${di},${DiploLegs${di}}]
		}

	;===================================================
	;===                  Melee Save                ====
	;===================================================
	Melee:AddSetting[doOpeningSeqMelee,${doOpeningSeqMelee}]
	Melee:AddSetting[doCritsDuringOpeningSeqMelee,${doCritsDuringOpeningSeqMelee}]
	Melee:AddSetting[doCombatSeqMelee,${doCombatSeqMelee}]
	Melee:AddSetting[doAOEMelee,${doAOEMelee}]
	Melee:AddSetting[doDotMelee,${doDotMelee}]
	Melee:AddSetting[doDebuffMelee,${doDebuffMelee}]
	Melee:AddSetting[doKillingBlow,${doKillingBlow}]
	Melee:AddSetting[KillingBlow,${KillingBlow}]	
	;===================================================
	;===                  Evade Save                ====
	;===================================================
	Evade:AddSetting[doInvoln1,${doInvoln1}]
	Evade:AddSetting[doInvoln2,${doInvoln2}]
	Evade:AddSetting[doEvade1,${doEvade1}]
	Evade:AddSetting[doEvade2,${doEvade2}]
	Evade:AddSetting[doFD,${doFD}]
	Evade:AddSetting[FDPct,${FDPct}]
	Evade:AddSetting[Involn1Pct,${Involn1Pct}]
	Evade:AddSetting[Involn2Pct,${Involn2Pct}]
	Evade:AddSetting[FD,${FD}]
	Evade:AddSetting[Involn1,${Involn1}]
	Evade:AddSetting[Involn2,${Involn2}]
	Evade:AddSetting[doRescue,${doRescue}]
	Evade:AddSetting[doPushAgro,${doPushAgro}]
	Evade:AddSetting[agropush,${agropush}]
	
	;===================================================
	;===                  Crits Save                ====
	;===================================================
	Crits:AddSetting[doCombatCrits,${doCombatCrits}]
	Crits:AddSetting[doBuffCrits,${doBuffCrits}]
	Crits:AddSetting[doDotCrits,${doDotCrits}]
	Crits:AddSetting[doAOECrits,${doAOECrits}]
	Crits:AddSetting[doCounterAttack,${doCounterAttack}]
	
	;===================================================
	;===            Combat Main Save                ====
	;===================================================
	SpellSR:AddSetting[doClickies,${doClickies}]
	SpellSR:AddSetting[doDispell,${doDispell}]
	SpellSR:AddSetting[doStancePush,${doStancePush}]
	SpellSR:AddSetting[doTurnOffAttack,${doTurnOffAttack}]
	SpellSR:AddSetting[doTurnOffDuringBuff,${doTurnOffDuringBuff}]
	SpellSR:AddSetting[doCounter,${doCounter}]
	SpellSR:AddSetting[doFurious,${doFurious}]

	;===================================================
	;===              Interaction Save              ====
	;===================================================
	Interactions:AddSetting[doRequestBuffs1,${doRequestBuffs[1]}]
	Interactions:AddSetting[RequestBuff1,${RequestBuff[1]}]
	Interactions:AddSetting[RequestBuffPlayer1,${RequestBuffPlayer[1]}]
	Interactions:AddSetting[TellRequestBuffPlayer1,${TellRequestBuffPlayer[1]}]
	Interactions:AddSetting[doRequestBuffs2,${doRequestBuffs[2]}]
	Interactions:AddSetting[RequestBuffs2,${RequestBuffs[2]}]
	Interactions:AddSetting[RequestBuffPlayer2,${RequestBuffPlayer[2]}]
	Interactions:AddSetting[TellRequestBuffPlayer2,${TellRequestBuffPlayer[2]}]
	Interactions:AddSetting[doRequestBuffs3,${doRequestBuffs[3]}]
	Interactions:AddSetting[RequestBuffs3,${RequestBuffs[3]}]
	Interactions:AddSetting[RequestBuffPlayer3,${RequestBuffPlayer[3]}]
	Interactions:AddSetting[TellRequestBuffPlayer3,${TellRequestBuffPlayer[3]}]
	Interactions:AddSetting[doRequestBuffs4,${doRequestBuffs[4]}]
	Interactions:AddSetting[RequestBuffs4,${RequestBuffs[4]}]
	Interactions:AddSetting[RequestBuffPlayer4,${RequestBuffPlayer[4]}]
	Interactions:AddSetting[TellRequestBuffPlayer4,${TellRequestBuffPlayer[4]}]
	Interactions:AddSetting[doRequestItems1,${doRequestItems[1]}]
	Interactions:AddSetting[RequestItems1,${RequestItems[1]}]
	Interactions:AddSetting[RequestItemsPlayer1,${RequestItemsPlayer[1]}]
	Interactions:AddSetting[TellRequestItemsPlayer1,${TellRequestItemsPlayer[1]}]
	Interactions:AddSetting[doRequestItems2,${doRequestItems[2]}]
	Interactions:AddSetting[RequestItems2,${RequestItems[2]}]
	Interactions:AddSetting[RequestItemsPlayer2,${RequestItemsPlayer[2]}]
	Interactions:AddSetting[TellRequestItemsPlayer2,${TellRequestItemsPlayer[2]}]
	Interactions:AddSetting[DoStopFollow,${DoStopFollow}]
	Interactions:AddSetting[StopFollowtxt,${StopFollowtxt}]
	Interactions:AddSetting[DoStartFollow,${DoStartFollow}]
	Interactions:AddSetting[StartFollowtxt,${StartFollowtxt}]
	Interactions:AddSetting[DoKillLevitate,${DoKillLevitate}]
	Interactions:AddSetting[KillingLevitate,${KillingLevitate}]
	Interactions:AddSetting[DoReassistTank,${DoReassistTank}]
	Interactions:AddSetting[ReassistingTank,${ReassistingTank}]
	Interactions:AddSetting[DoPause,${DoPause}]
	Interactions:AddSetting[Pausetxt,${Pausetxt}]
	Interactions:AddSetting[DoResume,${DoResume}]
	Interactions:AddSetting[Resumetxt,${Resumetxt}]
	Interactions:AddSetting[DoBuffage,${DoBuffage}]
	Interactions:AddSetting[Buffagetxt,${Buffagetxt}]
	Interactions:AddSetting[DoBurstCall,${DoBurstCall}]
	Interactions:AddSetting[BurstCalltxt,${BurstCalltxt}]
	
	switch ${Me.Class}
	{
		case Bard
			Class:AddSetting[PrimaryWeapon,${PrimaryWeapon}]
			Class:AddSetting[SecondaryWeapon,${SecondaryWeapon}]
			Class:AddSetting[FightSong,${FightSong}]
			Class:AddSetting[RunSong,${RunSong}]
			Class:AddSetting[Drum,${Drum}]
			break
			
		case Blood Mage
			Class:AddSetting[BMHealthToEnergySpell,${BMHealthToEnergySpell}]	
			Class:AddSetting[BMBloodUnionDumpDPSSpell,${BMBloodUnionDumpDPSSpell}]	
			Class:AddSetting[BMSingleTargetLifeTap1,${BMSingleTargetLifeTap1}]	
			Class:AddSetting[BMSingleTargetLifeTap2,${BMSingleTargetLifeTap2}]	
			Class:AddSetting[BMBloodUnionSingleTargetHOT,${BMBloodUnionSingleTargetHOT}]	
			break
	}
	
	;; Now, save it to file(s)
	LavishSettings[VGA]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/${Me.FName}.xml]
	LavishSettings[VGA_Mobs]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Mobs.xml]
	LavishSettings[VGA_General]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_General.xml]
	LavishSettings[VGA_Quests]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Quests.xml]
	LavishSettings[VGA_Diplo]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Diplo.xml]
	LavishSettings[Interactions]:Export[${LavishScript.CurrentDirectory}/scripts/VGA/Save/Interact.xml]

}
