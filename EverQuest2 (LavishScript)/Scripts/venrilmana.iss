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
		
		call CheckPower
		ProcessTriggers()
		call CheckDebuffs

		waitframe
	}
	while 1
}

function CheckPower()
{


	if ${Me.ToActor.Power}>60
	{
		Me.Ability[Sprint]:Use
		wait 2

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
	;conj shard
	if ${Me.ToActor.Power}<=50 && ${Me.Inventory["Scale of Essence"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Scale of Essence"]:Use
		call CastPause
		call CheckDebuffs
	}

	;necro heart
	if ${Me.ToActor.Power}<=50 && ${Me.Inventory["Darkness Heart"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Darkness Heart"]:Use
		call CastPause
		call CheckDebuffs
	}

	;manastone
	if ${Me.ToActor.Power}<=55 && ${Me.Inventory[ExactName,ManaStone].IsReady}
	{
		Me.Inventory[ExactName,ManaStone]:Use
		call CastPause
		call CheckDebuffs
	}

	;Rare Mana Regen Potion
	if ${Me.ToActor.Power}<=45 && ${Me.Inventory["Expert's Essence of Clarity"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Expert's Essence of Clarity"]:Use
		call CastPause
		call CheckDebuffs
	}

	;Mana Regen Potion
	if ${Me.ToActor.Power}<=45 && ${Me.Inventory["Dedicated Essence of Clarity"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Dedicated Essence of Clarity"]:Use
		call CastPause
		call CheckDebuffs
	}

	;Rare Mana Potion
	if ${Me.ToActor.Power}<=45 && ${Me.Inventory["Expert's Essence of Power"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Expert's Essence of Power"]:Use
		call CastPause
		call CheckDebuffs
	}

	;Mana Potion
	if ${Me.ToActor.Power}<=45 && ${Me.Inventory["Dedicated Essence of Power"].IsReady} && ${Me.InCombat}
	{
		Me.Inventory["Dedicated Essence of Power"]:Use
		call CastPause
		call CheckDebuffs
	}
}

function CastPause()
{
		wait 0.3
		while ${Me.CastingSpell}
		{
			waitframe
		}
}

