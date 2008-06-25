;********************************************************************************
; Simple Troub Script for Venril
;
; example: run venriltroub Pygar
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
	if !${MA}
	{
		echo ERROR: No MainAssist set - run venriltroub <MainAssist>
		endscript
	}

	do
	{
		if ${Actor[Venril](exists)} && ${Actor[Venril].Health}<65
			call CheckPower
		ProcessTriggers()
		call CheckDebuffs
		if !${Return}
			call DoAttack	${MA}
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

	if ${Me.Afflicted} && ${Me.Noxious}>0 && ${Me.Effect[detrimental,Toxic](exists)}
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
	if ${Me.Maintained[Perfection of the Maestro Check](exists)}
		Me.Maintained[Perfection of the Maestro Check]:Cancel

	if ${Me.Maintained[Chaos Anthem](exists)}
		Me.Maintained[Chaos Anthem]:Cancel

	if ${Me.Maintained[Draining Incursion](exists)}
		Me.Maintained[Draining Incursion]:Cancel

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

	if ${Actor[Venril].Distance}>20
	{
		press -hold w
		do
		{
			face Venril
			waitframe
		}
		while ${movecnt:Inc}<30 && ${Me.Noxious}<1 && ${Me.Arcane}<1 && ${Actor[Venril].Distance}>20
		press -release w
	}

	;we're good to use one abilitiy
	;Spell Rebuff
	if ${Me.Ability[Spell Rebuff].IsReady} && !${Me.Maintained[Spell Rebuff](exists)}
	{
		Me.Ability[Spell Rebuff]:Use
		call CastPause
		return
	}

	;Depressing Chant
	if ${Me.Ability[Depressing Chant].IsReady} && !${Me.Maintained[Depressing Chant](exists)}
	{
		Me.Ability[Depressing Chant]:Use
		call CastPause
		return
	}

	;Devigorating Discante
	if ${Me.Ability[Devigorating Discante].IsReady} && !${Me.Maintained[Devigorating Discante](exists)}
	{
		Me.Ability[Devigorating Discante]:Use
		call CastPause
		return
	}

	;Dispirited Processional
	if ${Me.Ability[Dispirited Processional].IsReady} && !${Me.Maintained[Dispirited Processional](exists)}
	{
		Me.Ability[Dispirited Processional]:Use
		call CastPause
		return
	}

	;Perfection of the Maestro Check
	if ${Me.Ability[Perfection of the Maestro].IsReady} && !${Me.Maintained[Perfection of the Maestro](exists)}
	{
		Me.Ability[Perfection of the Maestro]:Use
		call CastPause
		return
	}

	;Chaos Anthem
	if ${Me.Ability[Chaos Anthem].IsReady} && !${Me.Maintained[Chaos Anthem](exists)}
	{
		Me.Ability[Chaos Anthem]:Use
		call CastPause
		return
	}

	;Painful Lamentations
	if ${Me.Ability[Painful Lamentations].IsReady} && !${Me.Maintained[Painful Lamentations](exists)}
	{
		Me.Ability[Painful Lamentations]:Use
		call CastPause
		return
	}

	;Thunderous Overture
	if ${Me.Ability[Thunderous Overture].IsReady} && !${Me.Maintained[Thunderous Overture](exists)}
	{
		Me.Ability[Thunderous Overture]:Use
		call CastPause
		return
	}

	;Reverberating Shrill
	if ${Me.Ability[Reverberating Shrill].IsReady} && !${Me.Maintained[Reverberating Shrill](exists)}
	{
		Me.Ability[Reverberating Shrill]:Use
		call CastPause
		return
	}

	;Tap Essence
	if ${Me.Ability[Tap Essence].IsReady} && ${Me.ToActor.Power}<55 && !${Me.Maintained[Tap Essence](exists)}
	{
		Me.Ability[Tap Essence]:Use
		call CastPause
		return
	}

	;Draining Incursion
	if ${Me.Ability[Draining Incursion].IsReady} && !${Me.Maintained[Draining Incursion](exists)}
	{
		Me.Ability[Draining Incursion]:Use
		call CastPause
		return
	}

}

