;********************************************************************************
; Simple Defiler Script for Venril
;
; example: run venrildefiler Pygar
;	This will run the bot and treat the player 'Pygar' as MainTank
;********************************************************************************
variable int ToxicTimer=0
variable bool ToxicStarted=FALSE
variable int MTID

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


function main(string MT)
{
	if !${MT}
	{
		echo ERROR: No MainTank set - run venrildirge <MainTank>
		endscript
	}
	else
		MTID:Set[${Actor[pc,exactname,${MT}].ID}]
	do
	{
		if !${ToxicStarted}
		{
			call CheckDebuffs
			call DoPreHeals
			continue
		}
		call CheckDebuffs

		if ${Actor[Venril](exists)} && ${Actor[Venril].Health}<65 && ${Math.Calc64[${Time.Timestamp}-${ToxicTimer}]}<32
			call CheckPower

		ProcessTriggers()

		if ${Math.Calc64[${Time.Timestamp}-${ToxicTimer}]}<32
			call CheckCures ${MTID}

		call CheckDebuffs
		if !${Return} && ${Math.Calc64[${Time.Timestamp}-${ToxicTimer}]}<32 && ${Me.ToActor.Power}>44
			call DoHeals ${MTID}

		if ${Math.Calc64[${Time.Timestamp}-${ToxicTimer}]}<32
			call CheckCures ${MTID}

		call CheckDebuffs
		if !${Return} && ${Math.Calc64[${Time.Timestamp}-${ToxicTimer}]}<32 && ${Me.ToActor.Power}>42
			call DoDebuffs ${MTID}

		if ${Math.Calc64[${Time.Timestamp}-${ToxicTimer}]}>40
			echo Something is wrong, Timer over 40s!

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
		Me.Ability[Cure: Mail of Phantoms]:Use
		ToxicTimer:Set[${Time.Timestamp}]
		if !${ToxicStarted}
			ToxicStarted:Set[TRUE]
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
	if ${Me.Maintained[](exists)}
		Me.Maintained[]:Cancel


}

function RefreshPower()
{
	;AA Cannibalize
	if ${Me.ToActor.Power}<50  && ${Me.ToActor.Health}>30
	{
		Me.Ability[Cannibalize]:Use
		call CastPause
		call CheckDebuffs
	}


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

function CheckCures(int MTID)
{
	declare AffCnt int 0

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || ${Me.ToActor.IsRooted}
	{
		Me.Ability[Words of the Ancestors]:Use
		call CastPause
		AffCnt:Inc
	}


	if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0)
	{
		call CheckDebuffs
		eq2execute /useabilityonplayer Cure ${Me.Name}
		call CastPause
		AffCnt:Inc
	}

	if ${AffCnt}<2 && ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0)
	{
		call CheckDebuffs
		eq2execute /useabilityonplayer Cure ${Me.Name}
		call CastPause
		AffCnt:Inc
	}

	if ${AffCnt}<2
	{
		call CheckDebuffs
		call FindAfflicted
		if ${Return}>0
		{
			call CureGroupMember ${Return}
			AffCnt:Inc
		}
	}

	if ${AffCnt}<2
	{
		call CheckDebuffs
		call FindAfflicted
		if ${Return}>0
		{
			call CureGroupMember ${Return}
			AffCnt:Inc
		}
	}

}

function FindAfflicted()
{
	declare temphl int local 1
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflicted int local 0

	;check for single target cures
	do
	{
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<35
		{
			if ${Me.Group[${temphl}].Arcane}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

			if ${Me.Group[${temphl}].Noxious}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]

			if ${Me.Group[${temphl}].Elemental}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]

			if ${Me.Group[${temphl}].Trauma}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

			if ${tmpafflictions}>${mostafflictions}
			{
				mostafflictions:Set[${tmpafflictions}]
				mostafflicted:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead} || !${Me.Group[${gMember}].IsAfflicted}
		return

	if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
	{
		eq2execute /usabilityonplayer Cure ${Me.Group[${gMember}].ToActor.Name}
		call CastPause
	}
}