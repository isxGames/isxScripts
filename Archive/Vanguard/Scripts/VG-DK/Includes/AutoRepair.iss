;===================================================
;===         AUTO REPAIR EQUIPMENT              ====
;===================================================
function AutoRepair()
{
	if ${Me.InCombat} || ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead}
	{
		return
	}
	
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${RepairTimer}]}/1000]}>300 
	{
		RecentlyRepaired:Set[FALSE]
		RepairTimer:Set[${Script.RunningTime}]

		if ${Me.Inventory[Repair Stone](exists)}
		{
			variable bool test = FALSE
			if ${Me.Inventory[CurrentEquipSlot,Hand].Durability}<80
				test:Set[TRUE]
			waitframe
			if ${Me.Inventory[CurrentEquipSlot,Harvesting Chest].Durability}<60
				test:Set[TRUE]
			waitframe
			if ${Me.Inventory[CurrentEquipSlot,Crafting Chest].Durability}<60
				test:Set[TRUE]
			waitframe
			if ${Me.Inventory[CurrentEquipSlot,Diplomacy Chest].Durability}<60
				test:Set[TRUE]
			waitframe

			if ${test}
			{
				vgecho "Popped a Repair Stone"
				Me.Inventory[Repair Stone]:Use
				wait 5
			}
		}
	}
	
	;; Return if we have recently repaired our equipment
	if ${RecentlyRepaired}
		return

	;; Essence of Replenishment
	if ${Pawn[Essence of Replenishment](exists)}
	{
		if ${Pawn[Essence of Replenishment].Distance}<5
		{
			Pawn[Essence of Replenishment]:Target
			wait 10 ${Me.Target.Name.Find[Replenishment]}
			if ${Me.Target.Name.Find[Replenishment]}
			{
				Merchant:Begin[Repair]
				wait 3
				Merchant:RepairAll
				Merchant:End
				vgecho Repaired equipment
				VGExecute "/cleartargets"
				RecentlyRepaired:Set[TRUE]
			}
		}
	}

	;; Merchant Djinn
	if ${Pawn[Merchant Djinn](exists)}
	{
		if ${Pawn[Merchant Djinn].Distance}<5
		{
			Pawn[Merchant Djinn]:Target
			wait 10 ${Me.Target.Name.Find[Merchant Djinn]}
			if ${Me.Target.Name.Find[Merchant Djinn]}
			{
				Merchant:Begin[Repair]
				wait 3
				Merchant:RepairAll
				Merchant:End
				vgecho Repaired equipment
				VGExecute "/cleartargets"
				RecentlyRepaired:Set[TRUE]
			}
		}
	}

	;; Reparitron 5703
	if ${Pawn[Reparitron 5703](exists)}
	{
		if ${Pawn[Reparitron 5703].Distance}<5
		{
			Pawn[Reparitron 5703]:Target
			wait 10 ${Me.Target.Name.Find[Reparitron 5703]}
			if ${Me.Target.Name.Find[Reparitron 5703]}
			{
				Merchant:Begin[Repair]
				wait 3
				Merchant:RepairAll
				Merchant:End
				vgecho Repaired equipment
				VGExecute "/cleartargets"
				RecentlyRepaired:Set[TRUE]
			}
		}
	}
	
	;; Merchant
	if ${Me.Target.Type.Equal[Merchant]}
	{
		Merchant:Begin[Repair]
		wait 2
		Merchant:RepairAll
		Merchant:End
		vgecho Repaired equipment
		VGExecute "/cleartargets"
		RecentlyRepaired:Set[TRUE]
	}
}
