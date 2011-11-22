#define CARGOPCT					${Math.Calc[(${MyShip.UsedCargoCapacity}/${MyShip.CargoCapacity}) * 100]}
#define CARGOREMAINING				${Math.Calc[${MyShip.CargoCapacity} - ${MyShip.UsedCargoCapacity}]}

#define SHIELD						${MyShip.ShieldPct}
#define ARMOR						${MyShip.ArmorPct}
#define HULL						${MyShip.HullPct}
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
#define APPROACHLEFT				${Me.ToEntity.Approaching.Distance}
#define WARPRANGE					150000

;;;;; Entity.Mode Modes
#define INVULNERABLE				0
#define APPROACHING					1
;#define KEEPINGATRANGE				1
#define STOPPING					2
#define WARPING						3
#define ORBITING					4

;;;;;;;;;;;;;;;;;;;;;;;;;;;		Entities
#define ENTCATCELESTIAL				2
#define ENTCATASTEROID				25
#define ENTCATENTITY				11

#define ENTGROUPWRECK 				186
#define ENTGROUPCARGO 				12
#define ENTGROUPACCELGATE			366
#define ENTGROUPSTATION				15

#define ENTTYPEASTEROIDBELT			15

;;;;;;;;;;;;;;;;;;;;;;;;;;;		Items
#define ITMCATASTEROID				25

#define ITMGROUPSALVAGER			1122
#define ITMGROUPTRACTOR				650
#define ITMGROUPAFTERBURNER			46
#define ITMGROUPMICROWARPDRIVE		46
#define ITMGROUPSENSORBOOSTER		212
#define ITMGROUPCLOAKINGUNIT		330
#define ITMGROUPMININGLASER			483
#define ITMGROUPSHIELDBOOSTER		40

#define ITMGROUPCOMBATDRONE		100
#define ITMGROUPMININGDRONE		101


;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Windows
#define AGENTWINDOW					${EVEWindow[ByCaption,Agent Conversation](exists)}
#define CARGOWINDOW					${EVEWindow[MyShipCargo](exists)}
#define ITEMSWINDOW					${EVEWindow[hangarFloor](exists)}
#define LOOTWINDOW					${If[${EVEWindow[ByCaption,Floating](exists)} || ${EVEWindow[ByCaption,Wreck](exists)},TRUE,FALSE]}


;;;;;;;;;;;;;;;;;;;;;;;;;;;		Others
#define SLOWQ						${Math.Calc[${Slow}/4]}
#define SLOWH						${Math.Calc[${Slow}/2]}
#define SLOW						${Slow}
#define SLOW2						${Math.Calc[${Slow}*2]}
#define SLOW5						${Math.Calc[${Slow}*5]}

;#define EVENT_ONFRAME OnFrame
#define EVENT_ONFRAME				ISXEVE_onFrame