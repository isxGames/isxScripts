/*
HarvestIt v1.4
by:  Zandros, 27 Jan 2009

Description:
Returns TRUE or FALSE if we have harvested (skinned) a corpse

Optional parameters:
Distance = How far you want to scan (default is 5)

Examples Code: 
call HarvestIt				"Uses default parameters"
call HarvestIt 50				"Finds a Corpse within 50m"

External Routines that must be in your program:  FindTarget, Loot, MoveCloser

Variables to use in your program:
variable string Status				"Use this in your routines to echo what is happening"
*/

/* Toggle this on or off in your scripts */
;variable bool doHarvest = TRUE
;variable bool doSkin = TRUE
variable int HarvestRange = 10

;===================================================
;===          HarvestIt Routine                 ====
;===================================================
function:bool HarvestIt(int Distance)
{
	;-------------------------------------------
	; return if we do not want to harvest
	;-------------------------------------------
	if !${GV[bool,bHarvesting]}
	{
		if ${Me.InCombat}
			return FALSE

		if !${doHarvest} && !${doSkin}
			return FALSE

		if (${Me.Target.Type.Equal[Corpse]} || ${Me.Target.Type.Equal[Resource]}) && ${doHarvest}
		{
			call Harvesting ${Distance} 7
			return ${Return}
		}
			
		if (${Me.Target.Type.Equal[Corpse]} || !${Me.Target(exists)}) && ${doSkin}
		{
			call Harvesting ${Distance}
			return ${Return}
		}
			
		return FALSE
	}
}

function:bool Harvesting(int Distance)
{	
	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	if ${Distance} == 0
		Distance:Set[5]

	;-------------------------------------------
	; Find me a Corpse if target doesn't exist
	;-------------------------------------------
	if !${Me.Target(exists)} && ${doSkin}
	{
		waitframe
		call FindTarget Corpse ${Distance}
	}

	;-------------------------------------------
	; No target means no harvesting
	;-------------------------------------------
	if !${Me.Target(exists)}
		return FALSE

	;-------------------------------------------
	; Loot it if it contains loot
	;-------------------------------------------
	if ${Me.Target.ContainsLoot}
		call Loot

	;-------------------------------------------
	; Must pass our checks
	;-------------------------------------------
	if !${Me.Target.IsHarvestable} || ${Me.Target.Name.Find[remains]} 
		return FALSE
		
	;-------------------------------------------
	; Do this if we are not currently harvesting
	;-------------------------------------------
	if !${GV[bool,bHarvesting]}
	{
		;-------------------------------------------
		; Move Closer to target
		;-------------------------------------------
		if ${Me.Target(exists)}
		{
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
		}
			
		;-------------------------------------------
		; Loot it if it contains loot
		;-------------------------------------------
		if ${Me.Target.ContainsLoot}
			call Loot

		;-------------------------------------------
		; Start the Harvesting Process
		;-------------------------------------------
		VGExecute /autoattack
		wait 10
	}

	;-------------------------------------------
	; Echo that we are harvesting
	;-------------------------------------------
	if ${doEcho}
		echo "[${Time}][VG:BM] --> Harvesting: ${Me.Target.Name}, Type=${Me.Target.Type}"

	;-------------------------------------------
	; Now wait for the harvesting to finish
	;-------------------------------------------
	while ${GV[bool,bHarvesting]} && !${GV[bool,IsHarvestingDone]} && ${Me.Encounter}==0 && (${Me.Target.Type.Equal[Corpse]} || ${Me.Target.Type.Equal[Resource]})
	{
		Status:Set[Harvesting ${Me.Target.Name}]
		wait 5
	}

	;-------------------------------------------
	; Must wait for the system to update after harvesting
	;-------------------------------------------
	wait 5

	;-------------------------------------------
	; Close that annoying harvesting window by force clicking close button (You gonna have to move the window to the cursor)
	;-------------------------------------------
	if ${GV[bool,bHarvesting]}
	{
		Mouse:SetPosition[973,411]
		wait 2
		Mouse:LeftClick
		wait 2
		Mouse:ReleaseLeft
	}

	;-------------------------------------------
	; As long as we don't have an encounter, manually leftclick certain locations for rare harvests
	;-------------------------------------------
	if ${Me.Encounter}==0
	{
		if ${GV[bool,bHarvesting]} && ${GV[bool,IsHarvestingDone]}
		{
			Mouse:SetPosition[800,645]
			wait 30
			Mouse:LeftClick
			wait 5
			Mouse:ReleaseLeft
			wait 5
		}
	}

	;-------------------------------------------
	; Time to loot the corpse!
	;-------------------------------------------
	call Loot

	;-------------------------------------------
	; Let's clear our targets
	;-------------------------------------------
	;VGExecute /cleartargets
	;wait 5

	;-------------------------------------------
	; Consolidate our looted resources
	;-------------------------------------------
	call ConsolidateResources

	return TRUE
}

;===================================================
;===      ConsolidateResources Routine          ====
;===================================================
function ConsolidateResources()
{
	variable int i
	i:Set[0]
	while (${Me.Inventory[${i:Inc}].Name(exists)} )
	{
		if ${Me.Inventory[${i}].Type.Equal[Resource]} && ${Me.Inventory[${i}].Quantity}>20
		{
			if ${doEcho}
				echo "[${Time}][VG:BM] --> Consolidate: Consolidating ${Me.Inventory[${i}]}"
			Me.Inventory[${i}]:StartConvert
			wait waitframe
			Mouse:SetPosition[638,436]
			wait 3
			Mouse:LeftClick
			wait 3
			Mouse:ReleaseLeft
			wait 3
		}
	}
}


