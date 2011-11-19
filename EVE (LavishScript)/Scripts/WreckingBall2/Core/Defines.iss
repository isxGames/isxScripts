#define CARGOPCT					${Math.Calc[(${MyShip.UsedCargoCapacity}/${MyShip.CargoCapacity}) * 100]}
#define CARGOWINDOW					${EVEWindow[MyShipCargo](exists)}
#define ITEMSWINDOW					${EVEWindow[hangarFloor](exists)}
#define LOOTWINDOW					${If[${EVEWindow[ByCaption,Floating](exists)} || ${EVEWindow[ByCaption,Wreck](exists)},TRUE,FALSE]}

#define SHIELD						${MyShip.GetShieldPct}
#define ARMOR						${MyShip.GetArmorPct}
#define HULL						${MyShip.GetHullPct}
#define CAPACITOR					${MyShip.CapacitorPct}

#define TARGETING					${Me.GetTargeting}
#define TARGETS						${Me.GetTargets}
#define TARGETEDBY					${Me.GetTargetedBy}
#define TARGETINGRANGE				${MyShip.MaxTargetRange}
#define ALLTARGETS					${Math.Calc[${Me.GetTargeting} + ${Me.GetTargets}]}
#define MAXTARGETS					${If[${Me.MaxLockedTargets} < ${MyShip.MaxLockedTargets},${Me.MaxLockedTargets},${MyShip.MaxLockedTargets}]}
#define LOOTRANGE					2300

#define INSPACE						${Me.InSpace}
#define SOLARSYSTEM					${Me.SolarSystemID}
#define WAYPOINTS					${EVE.GetWaypoints}
#define AUTOPILOTON					${Me.AutoPilotOn}
#define SHIPMODE					${Me.ToEntity.Mode}
#define WARPING						3
#define APPROACHLEFT				${Me.ToEntity.Approaching.Distance}
#define WARPRANGE					150000

;;;;;;;;;;;;;;;;;;;;;;;;;;;		Entities
#define ENTCATCELESTIAL				2
#define ENTGROUPWRECK 				186
#define ENTGROUPCARGO 				12
#define ENTGROUPACCELGATE			366
#define ENTGROUPSTATION				15
#define ENTTYPEASTEROIDBELT			15

;;;;;;;;;;;;;;;;;;;;;;;;;;;		Items
#define ITMGROUPSALVAGER			1122
#define ITMGROUPTRACTOR				650
#define ITMGROUPAFTERBURNER			46
#define ITMGROUPMICROWARPDRIVE		46
#define ITMGROUPSENSORBOOSTER		212
#define ITMGROUPCLOAKINGUNIT		330
#define ITMGROUPMININGLASER			9999999
#define ITMGROUPSHIELDBOOSTER		40


;;;;;;;;;;;;;;;;;;;;;;;;;;;		Others
#define SLOWQ						${Math.Calc[${Slow}/4]}
#define SLOWH						${Math.Calc[${Slow}/2]}
#define SLOW						${Slow}
#define SLOW2						${Math.Calc[${Slow}*2]}
#define SLOW5						${Math.Calc[${Slow}*5]}

;#define EVENT_ONFRAME OnFrame
#define EVENT_ONFRAME				ISXEVE_onFrame