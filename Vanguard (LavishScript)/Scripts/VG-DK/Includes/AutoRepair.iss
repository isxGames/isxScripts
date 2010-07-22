;===================================================
;===         AUTO REPAIR EQUIPMENT              ====
;===================================================
function AutoRepair()
{
	if ${Me.InCombat}
	{
		return
	}

	if ${doUseRepairStone}
	{
		if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<50
		{
			if ${Me.Inventory[Repair Stone](exists)}
			{
				Me.Inventory[Repair Stone]:Use
				wait 5
			}
		}
		TimedCommand 600 Script[VG-DK].Variable[doUseRepairStone]:Set[TRUE]
		doUseRepairStone:Set[FALSE]
	}

	;; Essence of Replenishment
	if ${Pawn[Essence of Replenishment](exists)}
	{
		if ${doAutoRepair}
		{
			if ${Pawn[Essence of Replenishment].Distance}<5
			{
				if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
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
					}
				}
			}
		}
		TimedCommand 150 Script[VG-DK].Variable[doAutoRepair]:Set[TRUE]
		doAutoRepair:Set[FALSE]
	}

	;; Merchant Djinn
	if ${Pawn[Merchant Djinn](exists)}
	{
		if ${doAutoRepair}
		{
			if ${Pawn[Merchant Djinn].Distance}<5
			{
				if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
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
					}
				}
			}
		}
		TimedCommand 150 Script[VG-DK].Variable[doAutoRepair]:Set[TRUE]
		doAutoRepair:Set[FALSE]
	}

	;; Reparitron 5703
	if ${Pawn[Reparitron 5703](exists)}
	{
		if ${doAutoRepair}
		{
			if ${Pawn[Reparitron 5703].Distance}<5
			{
				if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
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
					}
				}
			}
		}
		TimedCommand 150 Script[VG-DK].Variable[doAutoRepair]:Set[TRUE]
		doAutoRepair:Set[FALSE]
	}
	
	;; Merchant
	if ${Me.Target.Type.Equal[Merchant]}
	{
		if ${doAutoRepair}
		{
			if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
			{
				Merchant:Begin[Repair]
				wait 3
				Merchant:RepairAll
				Merchant:End
				vgecho Repaired equipment
				VGExecute "/cleartargets"
			}
		}
		TimedCommand 150 Script[VG-DK].Variable[doAutoRepair]:Set[TRUE]
		doAutoRepair:Set[FALSE]
	}
}