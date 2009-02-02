
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
	}
} 
;********************************************
function counteringfunct()
{
	If !${Me.TargetCasting.Equal[None]}
	{
		actionlog "Mob is Casting ${Me.TargetCasting}"
	}
	If !${Me.TargetCasting.Equal[None]} && ${doCounter} && ${ClassRole.caster}
	{
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
				if ${Me.Ability[${counterspell1}].IsReady}
					{
					call executeability "${CounterSpell1}" "attack" "Neither"
					}
				elseif ${Me.Ability[${counterspell2}].IsReady}
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
			Me.Inventory[${Interator.Key}]:Use
			Iterator:Next
			}
		}
}
;********************************************
function dispellfunct()
{
	
	if ${doDispell} && ${Me.TargetBuff} > 0
	{
		variable int buffint
		buffint:Set[0]
		while ( ${buffint} < ${Me.TargetBuff} )
		{
			variable iterator Iterator
			Dispell:GetSettingIterator[Iterator]
			while ( ${Iterator.Key(exists)} )
			{
				while ${Me.TargetBuff[${buffint}].Name.Find[${Iterator.Key}]}
				{
					while !${Me.Ability[${DispellSpell}].IsReady}
						wait 1
					if ${Me.Ability[${DispellSpell}].IsReady}
						call executeability "${DispellSpell}" "attack" "Neither"
				}
			Iterator:Next
			}

		buffint:Inc
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
				if ${Me.Ability[${PushStanceSpell}].IsReady}
					call executeability "${PushStanceSpell}" "attack" "Neither"
				}
			Iterator:Next
			}
		}
	
}