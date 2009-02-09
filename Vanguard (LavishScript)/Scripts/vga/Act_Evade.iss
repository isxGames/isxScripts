
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
	if ${Pawn[${tankpawn}](exists)}
	{
	echo "I Exist as the tank"
	if ${doRescue} && !${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]} && ${fight.ShouldIAttack}
	{
		echo "Rescue ${doRescue} Mob on ${Me.TargetOfTarget} I should fight ${fight.ShouldIAttack} "
		Pawn[${Me.TargetOfTarget}]:Target
		waitframe
		echo "My DTarget is ${Me.DTarget}"
		variable iterator Iterator
		Rescue:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
			call checkabilitytocast "${Iterator.Value}"
			if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack} && !${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
				{	
				call executeability "${Iterator.Value}" "evade" "Neither"
				echo "Rescueing ${Me.DTarget} with ${Iterator.Value}"
				}
			if !${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
				Pawn[${Me.TargetOfTarget}]:Target
				echo "${Me.DTarget} is still agro} going to Next Ability"
				Iterator:Next
			if ${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
				echo "Mob is on Me ${Me.TargetOfTarget}"
				Return
			}
		if !${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
		{
		echo "Non Force Abilities didnt work.. doing force target"
		Pawn[${Me.TargetOfTarget}]:Target
		waitframe
		echo "Targeted on ${Me.TargetOfTarget}"
		If !${Me.TargetBuff["Immunity: Force Target"](exists)}
		{
		echo "Mob is not immuned to Force Target"
		variable iterator FRIterator
		ForceRescue:GetSettingIterator[FRIterator]
		while ( ${FRIterator.Key(exists)} )
			{
			call checkabilitytocast "${FRIterator.Value}"
			if ${Return} && ${Me.Ability[${FRIterator.Value}].IsReady} && ${fight.ShouldIAttack} && !${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
				{	
				call executeability "${FRIterator.Value}" "evade" "Neither"
				echo "Forcing Mob to Target me with ${FRIterator.Value}"
				}
			if !${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
				Pawn[${Me.TargetOfTarget}]:Target
				echo "FOrce Target FAILED? Jesus Man"
				Iterator:Next
			if ${Pawn[${tankpawn}].Name.Equal[${Me.TargetOfTarget}]}
				echo "Ok I have agro"
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