variable int TotalHarvest = 20

variable int QJ = ${Me.Inventory[Quickening Symbiote].Quantity}
variable int VIT = ${Me.Inventory[Vitalizing Symbiote].Quantity}
variable int FRENZY = ${Me.Inventory[Frenzied Symbiote].Quantity}
variable int VialOfBlood = ${Me.Inventory[Vial of Blood].Quantity}
variable int TwitchingMuscle = ${Me.Inventory[Twitching Muscle].Quantity}
variable int QuiveringBrain = ${Me.Inventory[Quivering Brain].Quantity}
variable int StillBeatingheart = ${Me.Inventory[Still Beating Heart].Quantity}

function main()
{
	call StartRoutine ${TotalHarvest}
	
	vgecho QJ=${QJ}
	waitframe
	vgecho VIT=${VIT}
	waitframe
	vgecho FRENZY=${FRENZY}
	waitframe
	vgecho VialOfBlood=${VialOfBlood}
	waitframe
	vgecho TwitchingMuscle=${TwitchingMuscle}
	waitframe
	vgecho QuiveringBrain=${QuiveringBrain}
	waitframe
	vgecho StillBeatingheart=${StillBeatingheart}
	waitframe

/*	
	;; the following will not assemble correctly.  It will repeat the previous one regardless of added ingredients

	if ${VIT}<=50 && ${VialOfBlood}>2
	{
		vgecho Crafting VITALIZE
		waitframe
		VGExecute /assemblyaddingredient \"Vial of Blood\" \"3\"
		wait 5
		VGExecute /assemble \"Vitalizing Symbiote\"
		wait 5
		
		while ${GV[bool,bAssembling]}
		{
			wait 5
		}
		
		; Wait a second then loot
		wait 10
		Loot:LootAll
		waitframe
	}

	if ${FRENZY}<=50 && ${VialOfBlood} && ${QuiveringBrain} && ${TwitchingMuscle}
	{
		vgecho Crafting FRENZY
		waitframe
		VGExecute /assemblyaddingredient \"Vial of Blood\"
		wait 5
		VGExecute /assemblyaddingredient \"Twitching Muscle\"
		wait 5
		VGExecute /assemblyaddingredient \"Quivering Brain\"
		wait 5
		VGExecute /assemble \"Frenzied Symbiote\"
		wait 5
		
		while ${GV[bool,bAssembling]}
		{
			wait 5
		}
		
		; Wait a second then loot
		wait 10
		Loot:LootAll
		waitframe
	}
	

	if ${QJ}<=50 && ${VialOfBlood} && ${QuiveringBrain} && ${StillBeatingheart} && ${TwitchingMuscle}
	{
		vgecho Crafting QJ
		waitframe
		VGExecute /assemblyaddingredient \"Quivering Brain\"
		wait 5
		VGExecute /assemblyaddingredient \"Still Beating Heart\"
		wait 5
		VGExecute /assemblyaddingredient \"Twitching Muscle\"
		wait 5
		VGExecute /assemblyaddingredient \"Vial of Blood\"
		wait 5
		VGExecute /assemble \"Quickening Symbiote\"
		wait 5
		
		while ${GV[bool,bAssembling]}
		{
			wait 5
		}
		
		; Wait a second then loot
		wait 10
		Loot:LootAll
		waitframe
	}
		
*/	
	
}

function StartRoutine(int Symbiotes=5)
{
	Pawn[ExactName,Sacrificial Beast]:Target
	wait 5
	
	Pawn[ExactName,Great Statue of Arakorr]:Target
	wait 5
	
	if !${Me.Target.Name.Equal[Sacrificial Beast]} && !${Me.Target.Name.Equal[Great statue of Arakorr]}
	{
		return
	}
	
	face ${Me.Target.Name}

	;; Loop this endef
	while 1
	{
		if (!${Me.Target.Name.Equal[Sacrificial Beast]} && !${Me.Target.Name.Equal[Great statue of Arakorr]}) || ${Me.Target.IsDead} || ${Me.Target.Type.Equal[Corpse]}
		{
			return
		}
	
		;; Catch till ready
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}

		;; Start our harvesting
		if (${Me.Target.Name.Equal[Sacrificial Beast]} || ${Me.Target.Name.Equal[Great statue of Arakorr]}) && ${Me.TargetHealth}>0
		{
			;; Cast appropriate ability
			call Harvest ${Symbiotes}
			
			;; Check for loot
			call Loot
		}
	}

}

function Harvest(int Symbiotes)
{
	if !${Me.CurrentForm.Name.Equal[Sanguine Focus]}
	{
		Me.Form[Sanguine Focus]:ChangeTo
		wait 25 
	}

	if  ${Me.Ability[Grim Harvest].TimeRemaining}>2
	{
		return
	}

	; Blood Vials
	if ${Me.Inventory[Vial of Blood].Quantity}<${Symbiotes} && ${Me.HealthPct}>=99
	{
		Me.Ability[Siphon Blood]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
			
		Pawn[me]:Target
		if ${Me.Ability[Transfusion of Serak III].IsReady}
		{
			Me.Ability[Transfusion of Serak III]:Use
			wait 5
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
		}
		return
	}
	
	;; Twitching Muscle
	if ${Me.Inventory[Twitching Muscle].Quantity}<${Symbiotes}
	{
		Me.Ability[Constrict III]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
			
		Me.Ability[Grim Harvest]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
		return
	}
	
	;; Quivering Brain
	if ${Me.Inventory[Quivering Brain].Quantity}<${Symbiotes}
	{
		Me.Ability[Bursting Cyst I]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
			
		Me.Ability[Grim Harvest]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
		return
	}
	
	;; Still Beating Heart
	if ${Me.Inventory[Still Beating Heart].Quantity}<${Symbiotes}
	{
		Me.Ability[Union of Blood I]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
			
		Me.Ability[Grim Harvest]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
		return
	}
	
	;; Pulsating Stomach
	if ${Me.Inventory[Pulsating Stomach].Quantity}<${Symbiotes}
	{
		Me.Ability[Blood Letting Ritual I]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
			
		Me.Ability[Grim Harvest]:Use
		wait 5
		while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			waitframe
		}
		return
	}
}

function atexit()
{
}


function Loot()
{
	wait 10
	;; Quick, loot the target
	if ${Me.Target(exists)} && ${Me.Target.Distance}<6
	{
		if ${Me.IsLooting}
		{
			Loot:LootAll
			wait 5
			if ${Me.IsLooting}
			{
				Loot:EndLooting
				wait 5
			}
		}
	}
}

