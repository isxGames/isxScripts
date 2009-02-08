
;********************************************
function checkFD()
{
	if ${doFD}
		{
		if ${Me.HealthPct} < ${FDPct} && !${Me.Effect[${FD}](exists)}
			{
			if !${Me.Ability[${FD}].IsReady}
				wait 1
			call executeability "${FD}" "evade" "Post"
			while ${Me.HealthPct} < ${FDPct}
				wait 20
			}
			
		}
	return
}  
;********************************************
function checkinvoln1()
{
	if ${doInvoln1}
		{
		if ${Me.HealthPct} < ${Involn1Pct} && !${Me.Effect[${Involn1}](exists)} && !${Me.Effect[${Involn2}](exists)} && !${Me.Effect[${FD}](exists)}
			{
			if ${Me.IsCasting}
				vgexecute /stopcasting
			call checkabilitytocast "${Involn1}"
			if ${Return}
			call executeability "${Involn1}" "evade" "Post"
			}
		}
	return
} 
;********************************************
function checkinvoln2()
{
	if ${doInvoln2}
		{
		if ${Me.HealthPct} < ${Involn2Pct} && !${Me.Effect[${Involn1}](exists)} && !${Me.Effect[${Involn2}](exists)} && !${Me.Effect[${FD}](exists)}
			{
			if ${Me.IsCasting}
				vgexecute /stopcasting
			call checkabilitytocast "${Involn2}"
			if ${Return}
			call executeability "${Involn2}" "evade" "Post"
			}	
		}
	return
} 
;********************************************
function pushagrototank()
{
	if ${doPushAgro} && !${${tankpawn}.Equal[${Me.TargetOfTarget}]} && ${fight.ShouldIAttack}
		{
		Pawn[${tankpawn}]:Target
		waitframe
		call checkabilitytocast "${agropush}"
		if ${Return} && ${Me.Ability[${agropush}].IsReady} && ${fight.ShouldIAttack}
			call executeability "${Iterator.Value}" "evade" "Neither"
		}
	return	
}
;********************************************
function rescue()
{
	if ${pawn[${tankpawn}](exists)}
	{
	if ${doRescue} && !${${tankpawn}.Equal[${Me.TargetOfTarget}]} && ${fight.ShouldIAttack}
	{
		Pawn[${Me.TargetOfTarget}]:Target
		waitframe
		variable iterator Iterator
		Rescue:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
			call checkabilitytocast "${Iterator.Value}"
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack} && !${${tankpawn}.Equal[${Me.TargetOfTarget}]}
				{	
				call executeability "${Iterator.Value}" "evade" "Neither"
				}
			if !${${tankpawn}.Equal[${Me.TargetOfTarget}]}
				Pawn[${Me.TargetOfTarget}]:Target
				Iterator:Next
			if ${${tankpawn}.Equal[${Me.TargetOfTarget}]}
				Return
			}
		if !${${tankpawn}.Equal[${Me.TargetOfTarget}]}
		{
		Pawn[${Me.TargetOfTarget}]:Target
		waitframe
		If !${Me.TargetBuff.Equal[Immunity: Force Target](exists)}
		{
		variable iterator FRIterator
		ForceRescue:GetSettingIterator[FRIterator]
		while ( ${FRIterator.Key(exists)} )
			{
			call checkabilitytocast "${FRIterator.Value}"
			if ${Return} && ${Me.Ability[${FRIterator.Value}].IsReady} && ${fight.ShouldIAttack} && !${${tankpawn}.Equal[${Me.TargetOfTarget}]}
				{	
				call executeability "${FRIterator.Value}" "evade" "Neither"
				}
			if !${${tankpawn}.Equal[${Me.TargetOfTarget}]}
				Pawn[${Me.TargetOfTarget}]:Target
				Iterator:Next
			if ${${tankpawn}.Equal[${Me.TargetOfTarget}]}
				Return
			}
		}
		}
	}
	}
	return	
}
;********************************************
function checkevade1()
{
	if ${doEvade1} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
		{
		variable iterator Iterator
		Evade1:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
			if ${Me.IsCasting}
				vgexecute /stopcasting
			call checkabilitytocast "${Iterator.Value}"
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{	
				call executeability "${Iterator.Value}" "evade" "Neither"
				}
			Iterator:Next
			}
		}
	return	
}
;********************************************
function checkevade2()
{
	if ${doEvade2} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
		{
		variable iterator Iterator
		Evade2:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
			if ${Me.IsCasting}
				{
				vgexecute /stopcasting
				}
			call checkabilitytocast "${Iterator.Value}"
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack}
				{	
				call executeability "${Iterator.Value}" "evade" "Neither"
				}
			Iterator:Next
			}
		}
	return	
}