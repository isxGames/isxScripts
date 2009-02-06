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
variable settingsetref Class

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

variable string HotHeal
variable string InstantHeal
variable string SmallHeal
variable string BigHeal
variable string InstantGroupHeal
variable string GroupHeal
variable string LazyBuff
variable string ResStone
variable string CombatRes
variable string NonCombatRes

variable bool healrefresh = TRUE

;===================================================
;===               Main VGA Variables           ====
;===================================================

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
;===================================================
;===             Main Combat Variables          ====
;===================================================

variable bool doTurnOffAttack
variable bool doDispell
variable bool doStancePush
variable bool doClickies
variable bool doCounter

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

;===================================================
;===                 Melee Variables            ====
;===================================================
variable bool doOpeningSeqMelee
variable bool doCritsDuringOpeningSeqMelee
variable bool doCombatSeqMelee
variable bool doAOEMelee
variable bool doDotMelee
variable bool doDebuffMelee

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
;===                 Triggers Variables           ====
;===================================================

variable string doTrigger1
variable string doWeaknessT1
variable string WeaknessT1
variable string doCritsT1
variable string CritsT1
variable string doHealthT1
variable string MinHealthT1
variable string MaxHealthT1
variable string doAbilReadyT1
variable string doIncTextT1
variable string IncTextT1
variable string doBuffT1
variable string doMobDeBuffT1
variable string doMobBuffT1
variable string MobBuffT1
variable string doSpecialT1
variable string SpecialT1
variable string doLoseAgroT1
variable string doGainAgroT1
variable string doOtherAgroT1
variable string doSwapStanceT1
variable string SwapStanceT1
variable string doSwitchSongsT1
variable string SwitchSongsT1
variable string doSwapWeaponsT1
variable string SWPrimaryT1
variable string SWSecondaryT1
variable string doUseItemsT1
variable string doUseAbilT1
variable string LastSongT1
variable string LastPrimaryT1
variable string LastSecondaryT1
variable string LastStanceT1

;===================================================
;===                 Bard Variables             ====
;===================================================
variable string PrimaryWeapon
variable string SecondaryWeapon
variable string FightSong
variable string RunSong
variable string Drum



