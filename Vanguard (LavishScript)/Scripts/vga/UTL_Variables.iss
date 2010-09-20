;===================================================
;===               LavishSettings               ====
;===================================================

variable settingsetref HealerSR
variable settingsetref UtilitySR
variable settingsetref OpeningSpellSequence
variable settingsetref CombatSpellSequence
variable settingsetref AOESpell
variable settingsetref DotSpell
variable settingsetref DebuffSpell
variable settingsetref SpellSR
variable settingsetref OpeningMeleeSequence
variable settingsetref CombatMeleeSequence
variable settingsetref AOEMelee
variable settingsetref DotMelee
variable settingsetref DebuffMelee
variable settingsetref Melee
variable settingsetref AOECrits
variable settingsetref BuffCrits
variable settingsetref DotCrits
variable settingsetref CombatCrits
variable settingsetref CounterAttack
variable settingsetref Clickies
variable settingsetref Dispell
variable settingsetref StancePush
variable settingsetref Counter
variable settingsetref TurnOffAttack
variable settingsetref Crits
variable settingsetref Evade
variable settingsetref Evade1
variable settingsetref Evade2
variable settingsetref Buff
variable settingsetref IceA
variable settingsetref FireA
variable settingsetref SpiritualA
variable settingsetref PhysicalA
variable settingsetref ArcaneA
variable settingsetref Ice
variable settingsetref Fire
variable settingsetref Spiritual
variable settingsetref Physical
variable settingsetref Arcane
variable settingsetref BW
variable settingsetref DBW
variable settingsetref TBW
variable settingsetref Triggers
variable settingsetref UseAbilT1
variable settingsetref UseItemsT1
variable settingsetref MobDeBuffT1
variable settingsetref BuffT1
variable settingsetref AbilReadyT1
variable settingsetref Sell
variable settingsetref Trash
variable settingsetref Class
variable settingsetref Rescue
variable settingsetref ForceRescue
variable settingsetref Interactions
variable settingsetref TurnOffDuringBuff
variable settingsetref Friends
variable settingsetref QuestNPCs
variable settingsetref Quests
variable settingsetref DiploNPCs
variable settingsetref Diplo

variable settingsetref HealSequence
variable settingsetref EmergencyHealSequence

;===================================================
;===               Group Member Names, etc      ====
;===================================================
variable(global) string GrpMemberNames[24]
variable(global) string GrpMemberClassType[24]
variable(global) int RaidGroup[6]
variable int RaidGroupCount

;===================================================
;===               Heal Variables               ====
;===================================================

variable bool hgrp[24] 
variable int fhpctgrp[24] = 30
variable int hpctgrp[24] = 50
variable int bhpctgrp[24] = 75
variable int hhpctgrp[24] = 85
variable int ighpctgrp[24] = 40
variable int ghpctgrp[24] = 70
variable int TankHealPct = 70
variable int TankEmerHealPct = 35
variable int MedHealPct = 80
variable int MedEmerHealPct = 50
variable int SquishyHealPct = 80
variable int SquishyEmerHealPct = 50

variable string HotHeal
variable string InstantHeal
variable string InstantHeal2
variable string InstantHotHeal1
variable string InstantHotHeal2
variable string TapSoloHeal
variable string SmallHeal
variable string BigHeal
variable string InstantGroupHeal
variable string GroupHeal
variable string LazyBuff
variable string ResStone
variable string CombatRes
variable string NonCombatRes
variable int Speed
variable string Endowment
variable int EndowmentStep

variable bool healrefresh = TRUE

variable bool doCombatStance
variable bool doNonCombatStance
variable string CombatStance
variable string NonCombatStance
variable string ClickieForce
variable string doClickieForce
variable string RestoreSpecial
variable bool doRestoreSpecial
variable int RestoreSpecialint
variable string kiss
variable string HealCrit1
variable string HealCrit2

variable bool DoByPassVGAHeals
variable int HOTReady[24]
variable bool usedAbility
variable bool DoResInCombat
variable bool DoResNotInCombat
variable bool DoResRaid

;===================================================
;===               Main VGA Variables           ====
;===================================================

variable string tankpawn
variable string assistpawn 
variable string followpawn
variable bool doassistpawn
variable bool DoHideShowLog
variable bool dofollowpawn
variable int followpawndist
variable int MoveToTargetPct
variable bool doMoveToTarget
variable bool doFaceTarget
variable int AssistBattlePct
variable bool doDeBug
variable bool doActionLog
variable bool doParser
variable bool GroupNeedsBuffs = FALSE
variable bool RaidNeedsBuffs = FALSE
variable int SlowHeals
variable string MyClass

variable string lastattack = "None"
variable bool newattack
variable int StartAttackTime
variable int EndAttackTime
variable int LastAbilityExecutedTime
variable string ParseAbility
variable int ParseDamage
variable int DamageDone
variable int ParseCount = 0
variable bool doSell
variable uint LastDowntimeCall = 0
variable bool DoLoot
variable bool DoMount
variable bool DoShiftingImage
variable string ShiftingImage
variable bool DoAutoAcceptGroupInvite
variable bool DoLooseTarget
variable int AssistEncounter
variable bool doTrash
variable bool DoFollowInCombat
variable bool doAutoSell
variable bool doHarvest
variable bool DoLootOnly
variable string LootOnly
variable bool DoRaidLoot
variable int LootDelay
variable bool DoDiplo = TRUE
variable bool OurTurn = TRUE
variable string LootToggle
variable string DiploToggle
variable bool DoDiploToggle
variable bool DoLootToggle
variable bool DoNaturalFollow

variable bool DoClassDownTime
variable bool DoClassPreCombat
variable bool DoClassOpener
variable bool DoClassCombat
variable bool DoClassPostCombat
variable bool DoClassEmergency
variable bool DoClassPostCasting
variable bool DoClassBurst

variable bool DoChargeFollow

variable bool DoAttackPositionFront
variable bool DoAttackPositionLeft
variable bool DoAttackPositionRight
variable bool DoAttackPositionBack
variable bool DoAttackPosition
variable bool DoPopCrates

variable bool DoAcceptRes
variable bool DoAutoResCombat
variable bool DoAutoResNoCombat
variable bool IsFollowing
variable bool DoRemoveLowDiplo
;===================================================
;===             Main Combat Variables          ====
;===================================================

variable bool doTurnOffAttack
variable bool doFurious
variable bool doDispell
variable bool doStancePush
variable bool doClickies
variable bool doCounter
variable bool mobisfurious
variable bool doTurnOffDuringBuff

;===================================================
;===               Critical Variables           ====
;===================================================
variable bool doCombatCrits
variable bool doDotCrits
variable bool doBuffCrits
variable bool doAOECrits
variable bool doCounterAttack

;===================================================
;===                 Evade Variables            ====
;===================================================
variable bool doInvoln1
variable bool doInvoln2
variable bool doEvade1
variable bool doEvade2
variable bool doFD
variable int Involn1Pct
variable int Involn2Pct
variable int FDPct
variable string Involn1
variable string Involn2
variable string FD
variable bool doRescue
variable bool doPushAgro
variable string agropush

;===================================================
;===                 Melee Variables            ====
;===================================================
variable bool doOpeningSeqMelee
variable bool doCritsDuringOpeningSeqMelee
variable bool doCombatSeqMelee
variable bool doAOEMelee
variable bool doDotMelee
variable bool doDebuffMelee
variable bool doKillingBlow
variable string KillingBlow

;===================================================
;===                 Spells Variables           ====
;===================================================
variable bool doOpeningSeqSpell
variable bool doCritsDuringOpeningSeqSpell
variable bool doCombatSeqSpell
variable bool doAOESpell
variable bool doDotSpell
variable bool doDebuffSpell
variable string DispellSpell
variable string PushStanceSpell
variable string CounterSpell1
variable string CounterSpell2
variable bool doPause
variable bool doSlowAttacks
variable int SlowAttacks

;===================================================
;===             Combat Reaction Variables     ====
;===================================================
variable bool DoCountersASAP 
variable bool DoChainsASAP 

variable bool CounterReactionReady = FALSE
variable float64 CounterReactionTimer
variable int64 CounterReactionPawnID
variable index:uint CounterReactionAbilities

variable index:uint ChainReactionAbilities
variable bool ChainReactionReady = FALSE
variable float64 ChainReactionTimer
variable int64 ChainReactionPawnID

;===================================================
;===                 Bard Variables             ====
;===================================================
variable string PrimaryWeapon
variable string SecondaryWeapon
variable string FightSong
variable string RunSong
variable string Drum

;===================================================
;===                 Blood Mage Variables       ====
;===================================================
variable string BMHealthToEnergySpell
variable string BMBloodUnionDumpDPSSpell
variable string BMSingleTargetLifeTap1
variable string BMSingleTargetLifeTap2
variable string BMBloodUnionSingleTargetHOT

;===================================================
;===               Interaction Variables        ====
;===================================================
variable bool DoStopFollow
variable string StopFollowtxt
variable bool DoStartFollow
variable string StartFollowtxt
variable bool DoKillLevitate
variable string KillingLevitate
variable bool DoReassistTank
variable string ReassistingTank
variable bool DoPause
variable string Pausetxt
variable bool DoResume
variable string Resumetxt
variable bool DoBuffage
variable string Buffagetxt
variable bool DoBurstCall
variable string BurstCalltxt
variable bool DoBurstNow = FALSE
variable bool doRequestBuffs[4] 
variable string RequestBuff[4]
variable string RequestBuffPlayer[4]
variable string TellRequestBuffPlayer[4]
variable bool doRequestItems[2]
variable string RequestItems[2]
variable string RequestItemsPlayer[2]
variable string TellRequestItemsPlayer[2]

variable string DiploLeftEar[8]
variable string DiploRightEar[8]
variable string DiploFace[8]
variable string DiploCloak[8]
variable string DiploNeck[8]
variable string DiploShoulder[8]
variable string DiploWrist[8]
variable string DiploChest[8]
variable string DiploHands[8]
variable string DiploHeld[8]
variable string DiploBelt[8]
variable string DiploBoots[8]
variable string DiploLeftRing[8]
variable string DiploRightRing[8]
variable string DiploLegs[8]


