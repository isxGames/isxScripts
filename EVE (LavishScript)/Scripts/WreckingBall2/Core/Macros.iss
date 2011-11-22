;;;;;;;; Stupid Math.Calc
#macro ADD(a,b)
  ${Math.Calc[a+b]}
#endmac


#macro SUBTRACT(a,b)
  ${Math.Calc[a-b]}
#endmac


#macro MULTIPLY(a,b)
  ${Math.Calc[a*b]}
#endmac


#macro DIVIDE(a,b)
  ${Math.Calc[a/b]}
#endmac


#macro RANDOM(a,b)
  ${Math.Rand[b]:Inc[a]}
#endmac


;;;; EVE Executables

#macro UNDOCK()
	EVE:Execute[CmdExitStation]
#endmac


#macro OPENHANGAR()
	EVE:Execute[OpenHangarFloor]
#endmac


#macro OPENCARGO()
	EVE:Execute[OpenCargoHoldOfActiveShip]
#endmac


#macro AUTOPILOT()
	EVE:Execute[CmdToggleAutopilot]
#endmac


#macro STOPSHIP()
	EVE:Execute[CmdStopShip]
#endmac


#macro STACKCARGOITEMS()
	MyShip:StackAllCargo
#endmac


;;;;;;;;;;;;drones
#macro DRONESLAUNCH(a)
EVE:LaunchDrones[a]
#endmac


#macro DRONESMINE(a)
EVE:DronesMineRepeatedly[a]
#endmac


#macro DRONESRETURN(a)
EVE:DronesReturnToDroneBay[a]
#endmac


#macro DRONESATTACK(a)
EVE:DronesEngageMyTarget[a]
#endmac


;;;;;; Ship

#macro MODACTIVATED(a)
	${If[${MyShip.Module[a].IsActive} || ${MyShip.Module[a].IsDeactivating},TRUE,FALSE]}
#endmac


#macro MODNOTACTIVATED(a)
	${If[${MyShip.Module[a].IsActive} || ${MyShip.Module[a].IsDeactivating},0,1]}
#endmac


#macro MODACTIVE(a)
	${MyShip.Module[a].IsActive}
#endmac


#macro MODDEACTIVATING(a)
	${MyShip.Module[a].IsDeactivating}
#endmac


#macro MODNAME(a)
	${MyShip.Module[a].ToItem.Name}
#endmac


#macro MODCURRENTCHARGES(a)
	${MyShip.Module[a].CurrentCharges}
#endmac


#macro MODMAXCHARGES(a)
	${MyShip.Module[a].MaxCharges}
#endmac


#macro MODRELOADING(a)
	${MyShip.Module[a].IsReloadingAmmo}
#endmac


#macro MODWAITING(a)
	${MyShip.Module[a].IsWaitingForActiveTarget}
#endmac


#macro MODCLICK(a)
	MyShip.Module[a]:Click
#endmac


#macro MODRELOAD(a,b)
	MyShip.Module[a]:ChangeAmmo[b,MODMAXCHARGES(a)]
#endmac


;;;;;; Bookmarks

#macro BMLABEL(a)
	${EVE.Bookmark[a].Label}
#endmac


#macro BMGROUPID(a)
	${EVE.Bookmark[a].ToEntity.GroupID}
#endmac


#macro BMSYSTEM(a)
	${EVE.Bookmark[a].SolarSystemID}
#endmac


#macro BMDISTANCE(a)
	${EVE.Bookmark[a].ToEntity.Distance}
#endmac


#macro BMWARP(a)
	EVE.Bookmark[a]:WarpTo
#endmac


#macro BMAPPROACH(a)
	EVE.Bookmark[a]:Approach
#endmac


#macro BMDOCK(a)
	EVE.Bookmark[a].ToEntity:Dock
#endmac


#macro BMSETDEST(a)
	Universe[BMSYSTEM(a)]:SetDestination
#endmac


#macro BMREMOVE(a)
	EVE.Bookmark[a]:Remove
#endmac



;;;;;;; Entities

#macro ENTID(a)
	${Entity[a].ID}
#endmac



#macro ENTEXISTS(a)
	${Entity[a](exists)}
#endmac


#macro ENTNAME(a)
	${Entity[a].Name}
#endmac


#macro ENTGROUP(a)
	${Entity[a].GroupID}
#endmac


#macro ENTMODE(a)
	${Entity[a].Mode}
#endmac


#macro ENTVELOCITY(a)
	${Entity[a].Velocity}
#endmac


#macro ENTDISTANCE(a)
	${Entity[a].Distance}
#endmac


#macro ENTHASBEENLOCKED(a)
	${If[${Entity[a].IsLockedTarget} || ${Entity[a].BeingTargeted}, TRUE, FALSE]}
#endmac


#macro ENTISTARGET(a)
	${Entity[a].IsActiveTarget}
#endmac


#macro LOOTRIGHTS(a)
	${Entity[a].HaveLootRights}
#endmac


#macro WRECKEMPTY(a)
	${Entity[a].IsWreckEmpty}
#endmac


#macro LOOTCAPTION(a)
	${If[ENTGROUP(a) == ENTGROUPWRECK, Wreck, Floating]}
#endmac


#macro OPENLOOT(a)
	Entity[a]:OpenCargo
#endmac


#macro CLOSELOOT(a)
	Entity[a]:CloseCargo
#endmac


#macro APPROACH(a)
	Entity[a]:Approach
#endmac


#macro ORBIT(a,b)
	Entity[a]:Orbit[b]
#endmac


#macro KEEPRANGE(a,b)
	Entity[a]:KeepAtRange[b]
#endmac


#macro LOCK(a)
	Entity[a]:LockTarget
#endmac


#macro TARGET(a)
	Entity[a]:MakeActiveTarget
#endmac


#macro WARPTO(a)
	Entity[a]:WarpTo
#endmac