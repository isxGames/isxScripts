;********************************************************************************
; Venril Power Manager
;
; example: run venrilmana Pygar
;	This will run the bot and treat the player 'Pygar' as MainAssist
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


function main(string MA)
{
	if ${MA.Equal[]}
	{
		echo ERROR: No MainAssist set - run venrildirge <MainAssist>
		endscript
	}

	do
	{
		if ${Me.Maintained[Sprint]}
			Me.Maintained[Sprint]:Cancel

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
		wait 5

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

	if ${Me.IsAfflicted} && ${Me.Noxious}>0 && ${Me.Effect[detrimental,Toxic](exists)}
	{
		Me.Inventory["Expert's Noxious Remedy"]:Use
		call CastPause
	}

	if ${Me.Effect[detrimental,Sacrifice](exists)}
	{
		call CancelMaintained

		while ${Me.Effect[detrimental,Sacrifice](exists)}
		{
			waitframe
			if ${Me.ToActor.Power}>60
				press 1
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
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Scale of Essence"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Scale of Essence"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;necro heart
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Darkness Heart"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Darkness Heart"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Rare Mana Regen Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Expert's Essence of Clarity"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Expert's Essence of Clarity"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Mana Regen Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Dedicated Essence of Clarity"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Dedicated Essence of Clarity"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Rare Mana Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Expert's Essence of Power"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Expert's Essence of Power"]:Use
		call CastPause
		call CheckDebuffs
		return
	}

	;Mana Potion
	if ${Me.ToActor.Power}<=40 && ${Me.Inventory["Dedicated Essence of Power"].IsReady} && ${Me.InCombat}
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

