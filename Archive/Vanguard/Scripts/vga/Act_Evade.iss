
;********************************************
function checkFD()
{

	if ${Me.HealthPct} < ${FDPct} && !${Me.Effect[${FD}](exists)}
	{
		if !${Me.Ability[${FD}].IsReady}
		wait 1
		call executeability "${FD}" "evade" "Post"
		IsFollowing:Set[FALSE]
		while ${Me.HealthPct} < ${FDPct}
		wait 20
		if ${Me.HealthPct} > ${FDPct}
		VGExecute /stand
	}
	return
}
;********************************************
function checkinvoln1()
{

	if ${Me.HealthPct} < ${Involn1Pct} && !${Me.Effect[${Involn1}](exists)} && !${Me.Effect[${Involn2}](exists)} && !${Me.Effect[${FD}](exists)}
	{
		if ${Me.IsCasting}
		vgexecute /stopcasting
		call checkabilitytocast "${Involn1}"
		if ${Return}
		call executeability "${Involn1}" "evade" "Post"
	}
	return
}
;********************************************
function checkinvoln2()
{
	if ${Me.HealthPct} < ${Involn2Pct} && !${Me.Effect[${Involn1}](exists)} && !${Me.Effect[${Involn2}](exists)} && !${Me.Effect[${FD}](exists)}
	{
		if ${Me.IsCasting}
		vgexecute /stopcasting
		call checkabilitytocast "${Involn2}"
		if ${Return}
		call executeability "${Involn2}" "evade" "Post"
	}
	return
}
;********************************************
function pushagrototank()
{
	if !${tankpawn.Equal[${Me.TargetOfTarget}]} && ${fight.ShouldIAttack}  && ${Group.Count} > 1
	{
		VGExecute /targetauto ${tankpawn}
		waitframe
		call checkabilitytocast "${agropush}"
		if ${Return} && ${Me.Ability[${agropush}].IsReady} && ${fight.ShouldIAttack}
		{
			call executeability "${agropush}" "evade" "Post"
		}
	}
	return
}
;********************************************
function rescue()
{
	if ${Pawn[exactname,${tankpawn}](exists)} && ${Group.Count} > 1
	{
		if ${doRescue} && !${tankpawn.Equal[${Me.TargetOfTarget}]} && ${fight.ShouldIAttack}
		{
			;echo "Rescue ${doRescue} Mob on ${Me.TargetOfTarget} I should fight ${fight.ShouldIAttack} "
			VGExecute "/assistoffensive"
			if ${Me.DTarget.Distance} > 4
			{
				call CheckPosition
			}
			face ${Me.Target.X} ${Me.Target.Y}
			waitframe
			;echo "My DTarget is ${Me.DTarget}"
			variable iterator Iterator
			Rescue:GetSettingIterator[Iterator]
			while ( ${Iterator.Key(exists)} )
			{
				;echo "Checking ability to cast ${Iterator.Key}"
				call checkabilitytocast "${Iterator.Value}"
				;echo "Ability to cast  ${Iterator.Key} was ${Return} and it isREADY ${Me.Ability[${Iterator.Value}].IsReady}"
				if ${Return} && ${Me.Ability[${Iterator.Value}].IsReady} && ${fight.ShouldIAttack} && !${tankpawn.Equal[${Me.TargetOfTarget}]}
				{
					call executeability "${Iterator.Value}" "evade" "Post"
					;echo "Rescueing ${Me.DTarget} with ${Iterator.Value}"
				}
				if !${tankpawn.Equal[${Me.TargetOfTarget}]}
				{
					GroupMember[${Me.TargetOfTarget}]:Target
					;echo "${Me.DTarget} is still agro going to Next Ability"
				}
				if ${tankpawn.Equal[${Me.TargetOfTarget}]}
				{
					;echo "Mob is on Me ${Me.TargetOfTarget}"
					return
				}
				Iterator:Next
			}
			if !${tankpawn.Equal[${Me.TargetOfTarget}]} && ${doClickieForce}
			{
				if ${Me.Inventory[${ClickieForce}].IsReady}
				{
					waitframe
					Me.Inventory[${ClickieForce}]:Use
					waitframe
					Me.Inventory[${ClickieForce}]:Use
				}
			}
			if !${tankpawn.Equal[${Me.TargetOfTarget}]}
			{
				;echo "Non Force Abilities didnt work.. doing force target"
				VGExecute "/assistoffensive"
				waitframe
				;echo "Targeted on ${Me.TargetOfTarget}"
				if !${Me.TargetBuff["Immunity: Force Target"](exists)}
				{
					;echo "Mob is not immuned to Force Target"
					variable iterator FTIterator
					ForceRescue:GetSettingIterator[FTIterator]
					while ( ${FTIterator.Key(exists)} )
					{
						call checkabilitytocast "${FTIterator.Value}"
						if ${Return} && ${Me.Ability[${FTIterator.Value}].IsReady} && ${fight.ShouldIAttack} && !${tankpawn.Equal[${Me.TargetOfTarget}]}
						{
							call executeability "${FTIterator.Value}" "evade" "Post"
							;echo "Forcing Mob to Target me with ${FTIterator.Value}"
						}
						if !${tankpawn.Equal[${Me.TargetOfTarget}]}
						{
							Pawn[${Me.TargetOfTarget}]:Target
							;echo "FOrce Target FAILED? Jesus Man"
						}
						if ${tankpawn.Equal[${Me.TargetOfTarget}]}
						{
							;echo "Ok I have agro"
							return
						}
						FTIterator:Next
					}

				}

			}
		}
		if (!${Me.FName.Equal[${tankpawn}]} && !${Me.DTarget.Name.Equal[${tankpawn}]})
		VGExecute /targetauto ${tankpawn}
	}

	return
}
;********************************************
function checkevade1()
{
	if ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
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
	if ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
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


