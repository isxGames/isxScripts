;********************************************************************************
; Simple Dirge Script for Venril
;
; example: run venrildirge Pygar
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
		if ${Actor[Venril](exists)} && ${Actor[Venril].Health}<65
			call CheckPower
		ProcessTriggers()
		call CheckDebuffs
		if !${Return}
			call DoAttack ${MA}
		waitframe
	}
	while 1
}

function CheckPower()
{
	if !${Actor[Venril](exists)} || ${Actor[Venril].Health}>=65
		return 1

	if ${Me.ToActor.Power}>60 && ${Actor[Venril].Health}<=65
	{
		Me.Ability[Sprint]:Use
		wait 0.3
		while ${Me.ToActor.Power}>60 && ${Me.Ability[Sprint](exists)}
		{
			waitframe
		}
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

function DoAttack(string MA)
{
	if !${Actor[Venril](exists)}
		return	

	declare CastCnt int 0
	declare movecnt int 0
	;check power
	call RefreshPower

	;recheck debuffs
	call CheckDebuffs
	if ${Me.ToActor.Power}<=42 || ${Return}
		return

	eq2execute /assist ${MA}
	face Venril

	if ${Actor[Venril].Distance}>10
	{
		press -hold w
		do
		{
			face Venril
			waitframe
		}
		while ${movecnt:Inc}<30 && ${Me.Noxious}<1 && ${Me.Arcane}<1 && ${Actor[Venril].Distance}>10
		press -release w
	}

	;we're good to use one abilitiy
	;CoB Check
	if ${Me.Ability[Chimes of Blades].IsReady}
	{
		Me.Ability[Chimes of Blades]:Use
		call CastPause
		return
	}

	;Scream of Blood
	if ${Me.Ability[Scream of Blood].IsReady} && ${Me.Ability[Shroud].IsReady} && ${Actor[Venril].Distance}>10
	{
		Me.Ability[Shroud]:Use
		call CastPause
		Me.Ability[Scream of Blood]:Use
		call CastPause
		return
	}

	;Shriek Blade
	if ${Me.Ability[Shriek Blade].IsReady}
	{
		Me.Ability[Shriek Blade]:Use
		call CastPause
		return
	}

	;Deprivating Shot
	if ${Me.Ability[Deprivating Shot].IsReady}
	{
		Me.Ability[Deprivating Shot]:Use
		call CastPause
		return
	}

	;Siphon Blade
	if ${Me.Ability[Siphon Blade].IsReady}
	{
		Me.Ability[Siphon Blade]:Use
		call CastPause
		return
	}

	;Rhyming Curse
	if ${Me.Ability[Rhyming Curse].IsReady}
	{
		Me.Ability[Rhyming Curse]:Use
		call CastPause
		return
	}

	;Grim Strike
	if ${Me.Ability[Grim Strike].IsReady} && ${Me.Ability[Shroud].IsReady} && ${Actor[Venril].Distance}>10
	{
		Me.Ability[Shroud]:Use
		call CastPause
		Me.Ability[Grim Strike]:Use
		call CastPause
		return
	}

}

