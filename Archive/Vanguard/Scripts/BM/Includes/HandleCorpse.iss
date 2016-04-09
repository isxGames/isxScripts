/* HandleCorpse v1.0 by Zandros, 27 Oct 2009

Description:
Simple routine to handle a corpse.  Right now,
it just clears the target if not harvesting, 
more to be added in future
*/

/* HANDLECORPSE */
function HandleCorpse()
{
	call HarvestIt ${HarvestRange}
	call Loot
	call ClearTarget
	call NewTarget
}

function Loot()
{
	;; Quick, loot the target
	if ${doLoot} && !${Me.IsGrouped} && ${Me.Target(exists)} && ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.Distance}<6
	{
		wait 5 ${GV[bool,bHarvesting]}
		if  ${GV[bool,bHarvesting]}
			return
	
		if ${doEcho}
			echo "[${Time}][VG:BM] --> Loot: ${Me.Target.Name}"
		VGExecute /loot
		wait 5 ${Me.IsLooting}
		if ${Loot.NumItems}
		{
			Loot:LootAll
			wait 5
		}
		if ${Me.IsLooting}
		{
			Loot:EndLooting
			wait 5
		}
		;VGExecute /hidewindow harvesting
		VGExecute /hidewindow bonus yield
		VGExecute /hidewindow depletion bonus yield 
		wait 5 !${Me.Target(exists)}
		waitframe
	}
}

function ClearTarget()
{
	;; Clear our target if its a corpse
	if ${Me.Target(exists)} && ${Me.Target.Type.Equal[Corpse]}
	{
		wait 7 ${GV[bool,bHarvesting]}
		if !${GV[bool,bHarvesting]}
		{
			if ${doEcho} && ${Me.Target(exists)}
				echo "[${Time}][VG:BM] --> ClearTarget: ${Me.Target.Name}"
			VGExecute /cleartargets
			waitframe
		}
	}
}

function NewTarget()
{
	;; Change targets if there are any encounters
	if !${Me.Target(exists)} && ${Me.Encounter}>0
	{
		if ${Pawn[${Tank}].CombatState}>0 && ${Pawn[${Tank}].Distance}<25
		{
			VGExecute /assist "${Tank}"
			wait 10 ${Me.Target(exists)}
		}
		if !${Me.Target(exists)} && ${Me.Encounter}>0
		{
			Me.Encounter[1].ToPawn:Target
			wait 10 ${Me.Target(exists)}
		}
		if ${doEcho} && ${Me.Target(exists)}
			echo "[${Time}][VG:BM] --> NewTarget: ${Me.Target.Name}"
	}
}
