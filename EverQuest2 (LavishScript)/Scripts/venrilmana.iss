;********************************************************************************
; Venril Power Manager
;
; example: run venrilmana
;********************************************************************************
#macro ProcessTriggers()
if "${QueuedCommands}"
{
	do
	{
		 ExecuteQueued
	}
	while "${QueuedCommands}"
}
#endmac

variable int BotOn

function main()
{
	BotOn:Set[1]

	do
	{
		if ${Me.Maintained[Sprint](exists)}
			Me.Maintained[Sprint]:Cancel

		if ${Me.ToActor.Power}<40 && ${BotOn}
		{
			Script[EQ2Bot]:Pause
			BotOn:Set[0]
		}

		if ${Me.ToActor.Power}>43 && !${BotOn}
		{
			Script[EQ2Bot]:Resume
			BotOn:Set[1]
		}

		call CheckDebuffs
		call CheckPower
		ProcessTriggers()
		waitframe
	}
	while 1
}

function CheckPower()
{
	call CheckDebuffs

	if ${Me.ToActor.Power}>58
	{
		Me.Ability[Sprint]:Use
		wait 5 ${Me.Maintained[Sprint](exists)}

		Me.Maintained[Sprint]:Cancel
		return 1
	}

	if ${Me.ToActor.Power}<=42
	{
		while ${Me.ToActor.Power}<=42
		{
			call CheckDebuffs
			if !${Return}
				call RefreshPower
		}
		return 1
	}
}

function CheckDebuffs()
{
	Me:InitializeEffects

	if ${Me.IsAfflicted} && ${Me.Noxious}>0 && ${Me.Effect[detrimental,Toxic Infusion](exists)}
	{
		Me.Inventory["Expert's Noxious Remedy"]:Use
		call CastPause
	}

	if ${Me.Effect[detrimental,Mana Sacrifice](exists)}
	{
		call CancelMaintained
		Script[EQ2Bot]:Pause
		BotOn:Set[0]

		while ${Me.Effect[detrimental,Mana Sacrifice](exists)}
		{
			waitframe
			if ${Me.ToActor.Power}>60
				press 1
		}

		if ${Me.ToActor.Power)>43
		{
			Script[EQ2Bot]:Resume
			BotOn:Set[1]
		}

		return 1
	}
	return 0
}

function CancelMaintained()
{
	;need list of power over time buffs to cancel
	if ${Me.Maintained[Chimes of Blades](exists)}
		Me.Maintained[Chimes of Blades]:Cancel

	if ${Me.Maintained[Scream of Blood](exists)}
		Me.Maintained[Scream of Blood]:Cancel

}

function RefreshPower()
{
	;manastone
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory[ExactName,ManaStone].IsReady}
	{
		Me.Inventory[ExactName,ManaStone]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;conj shard
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Scale of Essence"].IsReady}
	{
		Me.Inventory["Scale of Essence"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;necro heart
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Darkness Heart"].IsReady}
	{
		Me.Inventory["Darkness Heart"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Rare Mana Regen Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Expert's Essence of Clarity"].IsReady}
	{
		Me.Inventory["Expert's Essence of Clarity"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Mana Regen Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Dedicated Essence of Clarity"].IsReady}
	{
		Me.Inventory["Dedicated Essence of Clarity"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Rare Mana Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Expert's Essence of Power"].IsReady}
	{
		Me.Inventory["Expert's Essence of Power"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Mana Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Dedicated Essence of Power"].IsReady}
	{
		Me.Inventory["Dedicated Essence of Power"]:Use
		call CastPause
		call CheckDebuffs
		return
	}
}

function CastPause()
{
		wait 2
		while ${Me.CastingSpell}
		{
			waitframe
		}
}

