;===================================================
;===     ATOM - Load Variables from XML         ====
;===================================================
atom(script) LoadXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-DK_SSR
	
	;;Load Lavish Settings 
	LavishSettings[VG-DK]:Clear
	LavishSettings:AddSet[VG-DK]
	LavishSettings[VG-DK]:AddSet[MySettings]
	LavishSettings[VG-DK]:Import[${savePath}/MySettings.xml]	
	VG-DK_SSR:Set[${LavishSettings[VG-DK].FindSet[MySettings]}]

	;;Set values for MySettings
	CombatForm:Set[${VG-DK_SSR.FindSetting[CombatForm,"Armor of Darkness"]}]
	NonCombatForm:Set[${VG-DK_SSR.FindSetting[NonCombatForm,"Armor of Darkness"]}]
	doFace:Set[${VG-DK_SSR.FindSetting[doFace,TRUE]}]
	doMove:Set[${VG-DK_SSR.FindSetting[doMove,FALSE]}]
	doAutoAssist:Set[${VG-DK_SSR.FindSetting[doAutoAssist,TRUE]}]
	doAutoRez:Set[${VG-DK_SSR.FindSetting[doAutoRez,TRUE]}]
	doAutoRepair:Set[${VG-DK_SSR.FindSetting[doAutoRepair,TRUE]}]
	doConsumables:Set[${VG-DK_SSR.FindSetting[doConsumables,FALSE]}]
	doSprint:Set[${VG-DK_SSR.FindSetting[doSprint,FALSE]}]
	Speed:Set[${VG-DK_SSR.FindSetting[Speed,100]}]
	doCancelBuffs:Set[${VG-DK_SSR.FindSetting[doCancelBuffs,TRUE]}]
	doPhysical:Set[${VG-DK_SSR.FindSetting[doPhysical,TRUE]}]
	doSpiritual:Set[${VG-DK_SSR.FindSetting[doSpiritual,TRUE]}]
	doRanged:Set[${VG-DK_SSR.FindSetting[doRanged,TRUE]}]
	doMelee:Set[${VG-DK_SSR.FindSetting[doMelee,TRUE]}]
	doSound:Set[${VG-DK_SSR.FindSetting[doSound,TRUE]}]
	doShadowStep:Set[${VG-DK_SSR.FindSetting[doShadowStep,TRUE]}]
	doHatred:Set[${VG-DK_SSR.FindSetting[doHatred,TRUE]}]
	doRescues:Set[${VG-DK_SSR.FindSetting[doRescues,TRUE]}]
	doCounters:Set[${VG-DK_SSR.FindSetting[doCounters,TRUE]}]
	doChains:Set[${VG-DK_SSR.FindSetting[doChains,TRUE]}]
	doMisc:Set[${VG-DK_SSR.FindSetting[doMisc,TRUE]}]
	doDreadfulVisage:Set[${VG-DK_SSR.FindSetting[doDreadfulVisage,TRUE]}]
	doDespoil:Set[${VG-DK_SSR.FindSetting[doDespoil,TRUE]}]
	doAbyssalChains:Set[${VG-DK_SSR.FindSetting[doAbyssalChains,TRUE]}]
	doDeBuff:Set[${VG-DK_SSR.FindSetting[doDeBuff,TRUE]}]

	doRetaliate:Set[${VG-DK_SSR.FindSetting[doRetaliate,TRUE]}]
	doVengeance:Set[${VG-DK_SSR.FindSetting[doVengeance,TRUE]}]
	doSeethingHatred:Set[${VG-DK_SSR.FindSetting[doSeethingHatred,TRUE]}]
	doScourge:Set[${VG-DK_SSR.FindSetting[doScourge,TRUE]}]
	doNexusOfHatred:Set[${VG-DK_SSR.FindSetting[doNexusOfHatred,TRUE]}]
	doHexOfIllOmen:Set[${VG-DK_SSR.FindSetting[doHexOfIllOmen,TRUE]}]
	doIncite:Set[${VG-DK_SSR.FindSetting[doIncite,TRUE]}]
	doShieldOfFear:Set[${VG-DK_SSR.FindSetting[doShieldOfFear,TRUE]}]
	doVileStrike:Set[${VG-DK_SSR.FindSetting[doVileStrike,TRUE]}]
	doWrack:Set[${VG-DK_SSR.FindSetting[doWrack,TRUE]}]
	doProvoke:Set[${VG-DK_SSR.FindSetting[doProvoke,TRUE]}]
	doTorture:Set[${VG-DK_SSR.FindSetting[doTorture,TRUE]}]
	doBlackWind:Set[${VG-DK_SSR.FindSetting[doBlackWind,TRUE]}]
	doScytheOfDoom:Set[${VG-DK_SSR.FindSetting[doScytheOfDoom,TRUE]}]
	doVexingStrike:Set[${VG-DK_SSR.FindSetting[doVexingStrike,TRUE]}]
	doMalice:Set[${VG-DK_SSR.FindSetting[doMalice,TRUE]}]
	doMutilate:Set[${VG-DK_SSR.FindSetting[doMutilate,TRUE]}]
	doRavagingDarkness:Set[${VG-DK_SSR.FindSetting[doRavagingDarkness,TRUE]}]
	doSlay:Set[${VG-DK_SSR.FindSetting[doSlay,TRUE]}]
	doBacklash:Set[${VG-DK_SSR.FindSetting[doBacklash,TRUE]}]
	doLoot:Set[${VG-DK_SSR.FindSetting[doLoot,TRUE]}]
	LootDelay:Set[${VG-DK_SSR.FindSetting[LootDelay,"0"]}]
	doRaidLoot:Set[${VG-DK_SSR.FindSetting[doRaidLoot,FALSE]}]
	doLootOnly:Set[${VG-DK_SSR.FindSetting[doLootOnly,FALSE]}]
	LootOnly:Set[${VG-DK_SSR.FindSetting[LootOnly,""]}]
	doLootEcho:Set[${VG-DK_SSR.FindSetting[doLootEcho,TRUE]}]
	doLootInCombat:Set[${VG-DK_SSR.FindSetting[doLootInCombat,TRUE]}]
	MobMinLevel:Set[${VG-DK_SSR.FindSetting[MobMinLevel,"0"]}]
	MobMaxLevel:Set[${VG-DK_SSR.FindSetting[MobMaxLevel,"0"]}]
	ConCheck:Set[${VG-DK_SSR.FindSetting[ConCheck,"0"]}]
	Distance:Set[${VG-DK_SSR.FindSetting[Distance,"100"]}]
}
;===================================================
;===      ATOM - Save Variables to XML          ====
;===================================================
atom(script) SaveXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-DK_SSR

	;; Load Lavish Settings 
	LavishSettings[VG-DK]:Clear
	LavishSettings:AddSet[VG-DK]
	LavishSettings[VG-DK]:AddSet[MySettings]
	LavishSettings[VG-DK]:Import[${savePath}/MySettings.xml]	
	VG-DK_SSR:Set[${LavishSettings[VG-DK].FindSet[MySettings]}]

	;; Save MySettings
	VG-DK_SSR:AddSetting[CombatForm,${CombatForm}]
	VG-DK_SSR:AddSetting[NonCombatForm,${NonCombatForm}]
	VG-DK_SSR:AddSetting[doFace,${doFace}]
	VG-DK_SSR:AddSetting[doMove,${doMove}]
	VG-DK_SSR:AddSetting[doAutoAssist,${doAutoAssist}]
	VG-DK_SSR:AddSetting[doAutoRez,${doAutoRez}]
	VG-DK_SSR:AddSetting[doAutoRepair,${doAutoRepair}]
	VG-DK_SSR:AddSetting[doConsumables,${doConsumables}]
	VG-DK_SSR:AddSetting[doSprint,${doSprint}]
	VG-DK_SSR:AddSetting[Speed,${Speed}]
	VG-DK_SSR:AddSetting[doCancelBuffs,${doCancelBuffs}]
	VG-DK_SSR:AddSetting[doPhysical,${doPhysical}]
	VG-DK_SSR:AddSetting[doSpiritual,${doSpiritual}]
	VG-DK_SSR:AddSetting[doRanged,${doRanged}]
	VG-DK_SSR:AddSetting[doMelee,${doMelee}]
	VG-DK_SSR:AddSetting[doSound,${doSound}]
	VG-DK_SSR:AddSetting[doShadowStep,${doShadowStep}]
	VG-DK_SSR:AddSetting[doRescues,${doRescues}]
	VG-DK_SSR:AddSetting[doCounters,${doCounters}]
	VG-DK_SSR:AddSetting[doChains,${doChains}]
	VG-DK_SSR:AddSetting[doMisc,${doMisc}]
	VG-DK_SSR:AddSetting[doDreadfulVisage,${doDreadfulVisage}]
	VG-DK_SSR:AddSetting[doDespoil,${doDespoil}]
	VG-DK_SSR:AddSetting[doDeBuff,${doDeBuff}]
	VG-DK_SSR:AddSetting[doHatred,${doHatred}]
	VG-DK_SSR:AddSetting[doRetaliate,${doRetaliate}]
	VG-DK_SSR:AddSetting[doVengeance,${doVengeance}]
	VG-DK_SSR:AddSetting[doSeethingHatred,${doSeethingHatred}]
	VG-DK_SSR:AddSetting[doScourge,${doScourge}]
	VG-DK_SSR:AddSetting[doNexusOfHatred,${doNexusOfHatred}]
	VG-DK_SSR:AddSetting[doHexOfIllOmen,${doHexOfIllOmen}]
	VG-DK_SSR:AddSetting[doIncite,${doIncite}]
	VG-DK_SSR:AddSetting[doShieldOfFear,${doShieldOfFear}]
	VG-DK_SSR:AddSetting[doVileStrike,${doVileStrike}]
	VG-DK_SSR:AddSetting[doWrack,${doWrack}]
	VG-DK_SSR:AddSetting[doProvoke,${doProvoke}]
	VG-DK_SSR:AddSetting[doTorture,${doTorture}]
	VG-DK_SSR:AddSetting[doBlackWind,${doBlackWind}]
	VG-DK_SSR:AddSetting[doScytheOfDoom,${doScytheOfDoom}]
	VG-DK_SSR:AddSetting[doVexingStrike,${doVexingStrike}]
	VG-DK_SSR:AddSetting[doMalice,${doMalice}]
	VG-DK_SSR:AddSetting[doMutilate,${doMutilate}]
	VG-DK_SSR:AddSetting[doRavagingDarkness,${doRavagingDarkness}]
	VG-DK_SSR:AddSetting[doSlay,${doSlay}]
	VG-DK_SSR:AddSetting[doBacklash,${doBacklash}]
	VG-DK_SSR:AddSetting[doLoot,${doLoot}]
	VG-DK_SSR:AddSetting[LootDelay,${LootDelay}]
	VG-DK_SSR:AddSetting[doRaidLoot,${doRaidLoot}]
	VG-DK_SSR:AddSetting[doLootOnly,${doLootOnly}]
	VG-DK_SSR:AddSetting[LootOnly,${LootOnly}]
	VG-DK_SSR:AddSetting[doLootEcho,${doLootEcho}]
	VG-DK_SSR:AddSetting[doLootInCombat,${doLootInCombat}]
	VG-DK_SSR:AddSetting[MobMinLevel,${MobMinLevel}]
	VG-DK_SSR:AddSetting[MobMaxLevel,${MobMaxLevel}]
	VG-DK_SSR:AddSetting[ConCheck,${ConCheck}]
	VG-DK_SSR:AddSetting[Distance,${Distance}]

	;; Save to file
	LavishSettings[VG-DK]:Export[${savePath}/MySettings.xml]
}
