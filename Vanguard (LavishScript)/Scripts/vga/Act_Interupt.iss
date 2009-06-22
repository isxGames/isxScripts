
;********************************************
function ManualPause()
{
	while ${doPause}
		wait 1
}
;********************************************
function TurnOffAttackfunct()
{
	If ${doTurnOffAttack} 
	{
		variable iterator Iterator
		TurnOffAttack:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.TargetBuff[${Iterator.Key}](exists)}
			{
				if ${Me.IsCasting}
				{
					vgexecute /stopcasting
				}
				if ${Me.Ability[Auto Attack].Toggled}
					Me.Ability[Auto Attack]:Use
				if ${Me.Ability[{FD}](exists)}
					Me.Ability[${FD}]:Use
				while ${Me.TargetBuff[${Iterator.Key}](exists)}
				{
					wait 5
					if ${ClassRole.healer}
						call Healcheck
				}
			}
			Iterator:Next
		}
	return
	}
	if ${doFurious}
	{
	if ${mobisfurious}
		{
		if ${Me.IsCasting}
			{
			vgexecute /stopcasting
			}
		if ${Me.Ability[Auto Attack].Toggled}
			{
			Me.Ability[Auto Attack]:Use
			}
		wait 10	
		if ${ClassRole.healer}
			{
			call Healcheck
			}
		wait 10
		while ${Me.TargetBuff[Furious}](exists)}
			{
			wait 5
			if ${ClassRole.healer}
				call Healcheck
			}		
		}
	}

} 
;********************************************
function counteringfunct()
{
	If !${Me.TargetCasting.Equal[None]} && ${doCounter}
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
				while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
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
	if ${doClickies}
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
}
;********************************************
function dispellfunct()
{
	
	if ${doDispell} && ${Me.TargetBuff} > 0
	{
		variable iterator Iterator
		Dispell:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
		{
			while ${Me.TargetBuff[${Iterator.Key}](exists)}
			{
				while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
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
	
	if ${doStancePush} && ${ClassRole.stancepusher}
		{
		variable iterator Iterator
		StancePush:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
				while ${Me.TargetBuff[${Iterator.Key}](exists)}
				{
				while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
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
