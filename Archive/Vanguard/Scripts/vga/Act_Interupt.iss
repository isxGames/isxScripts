
;*********************************************
function ManualPause()
{
	while ${doPause}
	wait 1
}
;********************************************
function:bool CheckFurious()
{
	while ${mobisfurious}
	{
		if ${Me.HavePet} || ${Me.HaveMinion}
		{
			VGExecute "/pet backoff"
		}
		call CheckPosition
		if ${Me.TargetHealth} > 20 && ${Me.Target.Name.NotEqual[Masuke Whitewind]}
		{
			actionlog "Furious Down Health too High"
			mobisfurious:Set[FALSE]
			wait 10
			return TRUE
		}
		if ${Me.Ability[Auto Attack].Toggled}
		{
			Me.Ability[Auto Attack]:Use
			wait 10
		}
		if ${Me.TargetHealth} == 0 || ${Me.Target.Type.Equal[Corpse]} || !${Me.Target(exists)} || ${Me.Target.IsDead}
		{
			actionlog "Furious Down Mob is Dead/Missing"
			mobisfurious:Set[FALSE]
			wait 10
			return TRUE
		}
		wait 12
		if ${ClassRole.healer}
		call Healcheck
		call StancePushfunct
	}
	if !${mobisfurious}
	return TRUE
}
;********************************************
function TurnOffAttackfunct()
{
	variable iterator Iterator
	TurnOffAttack:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		if ${Me.TargetBuff[${Iterator.Key}](exists)}
		{
			if ${Me.HavePet} || ${Me.HaveMinion}
			{
				VGExecute "/pet backoff"
			}

			if ${Me.Ability[Auto Attack].Toggled}
			Me.Ability[Auto Attack]:Use
			if ${Me.Ability[{FD}](exists)}
			Me.Ability[${FD}]:Use
			while ${Me.TargetBuff[${Iterator.Key}](exists)}
			{
				if ${Me.HavePet} || ${Me.HaveMinion}
				{
					VGExecute "/pet backoff"
				}
				call CheckPosition
				wait 5
				if ${ClassRole.healer}
				call Healcheck
				call StancePushfunct
			}
		}
		Iterator:Next
	}
}
;********************************************
function TurnOffDuringBuff()
{

	variable iterator Iterator
	TurnOffDuringBuff:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		if ${Me.Effect[${Iterator.Key}](exists)}
		{
			if ${Me.IsCasting}
			{
				vgexecute /stopcasting
			}

			if ${Me.Ability[Auto Attack].Toggled}
			Me.Ability[Auto Attack]:Use
			if ${Me.Ability[{FD}](exists)}
			Me.Ability[${FD}]:Use
			while ${Me.Effect[${Iterator.Key}](exists)}
			{
				if ${Me.HavePet}
				{
					VGExecute "/pet backoff"
				}
				call CheckPosition
				wait 5
				if ${ClassRole.healer}
				call Healcheck
				call StancePushfunct
			}
		}
		Iterator:Next
	}
}
;********************************************
function counteringfunct()
{
	If !${Me.TargetCasting.Equal[None]}
	{
		actionlog "Mob is Casting ${Me.TargetCasting}"
		variable iterator Iterator
		Counter:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.TargetCasting.Find[${Iterator.Key}]}
			{
				if ${Me.IsCasting}
				{
					vgexecute /stopcasting
				}
				while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned})
				{
					waitframe
				}
				if ${Me.Ability[${CounterSpell1}].IsReady}
				{
					call executeability "${CounterSpell1}" "attack" "Neither"
				}
				elseif ${Me.Ability[${CounterSpell2}].IsReady}
				{
					call executeability "${CounterSpell2}" "attack" "Neither"
				}
			}
			Iterator:Next
		}
	}
}
;********************************************
function clickiesfunct()
{
	variable iterator Iterator
	Clickies:GetSettingIterator[Iterator]
	while ( ${Iterator.Key(exists)} )
	{
		if ${Me.Inventory[${Iterator.Key}].IsReady}
		{
			waitframe
			Me.Inventory[${Iterator.Key}]:Use
			waitframe
			Me.Inventory[${Iterator.Key}]:Use
		}
		Iterator:Next
	}
}
;********************************************
function dispellfunct()
{

	if ${Me.TargetBuff} > 0
	{
		variable iterator Iterator
		Dispell:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			while ${Me.TargetBuff[${Iterator.Key}](exists)}
			{
				while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned})
				wait 1
				while !${Me.Ability[${DispellSpell}].IsReady}
				wait 1
				if ${Me.Ability[${DispellSpell}].IsReady}
				call executeability "${DispellSpell}" "attack" "Neither"
			}
			Iterator:Next

		}

	}

}
;********************************************
function StancePushfunct()
{
	if ${doStancePush}
	{
		variable iterator Iterator
		StancePush:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			while ${Me.TargetBuff[${Iterator.Key}](exists)}
			{
				while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned})
				{
					waitframe
				}
				if ${Me.Ability[${PushStanceSpell}].IsReady}
				call executeability "${PushStanceSpell}" "attack" "Neither"
			}
			Iterator:Next
		}
	}
}


