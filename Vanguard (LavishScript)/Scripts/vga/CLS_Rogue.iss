variable string ravage
variable string backstab
variable string bearscroll
variable string bearscrollbuff
variable bool dobearscroll
variable string catscroll
variable string catscrollbuff
variable bool docatscroll
variable string antihealdart
variable bool doantihealdart
variable string poison
variable string dopoison
variable string shank
variable string shiv
variable string elusivemark
variable string lethalstrikes
variable bool dolethalstrikes
variable string keeneye
variable string viciousstrike
variable string deadlystrike
variable string kneebreak
variable string ruin
variable string hemorrhage
variable string impale
variable string wickedstrike

;===================================================
;===        Lethal Strikes Timer                ====
;===================================================
objectdef LSTimer
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}
	member:uint TimeRemaining()
	{
		if ${Script.RunningTime}>=${EndTime}
		return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}
variable LSTimer LSTimer

objectdef Stalking
{
	member:bool Me()
	{
		If ${Me.Effect[Stalking I](exists)}
		return TRUE
		If ${Me.Effect[Stalking II](exists)}
		return TRUE
		If ${Me.Effect[Stalking III](exists)}
		return TRUE
		If ${Me.Effect[Stalking IV](exists)}
		return TRUE
		If ${Me.Effect[Stalking V](exists)}
		return TRUE
		If ${Me.Effect[Stalking VI](exists)}
		return TRUE
		Return FALSE
	}
}

variable Stalking Stalking
;********************************************
function Rogue_DownTime()
{
	if ${dopoison} && ${Me.Inventory[${poison}](exists)} && !${Me.Effect[${poison}](exists)}
	{
		Me.Inventory[${poison}]:Use
		wait 10
	}

	return
}
;********************************************
function Rogue_PreCombat()
{

}
;********************************************
function Rogue_Opener()
{
	if ${dobearscroll} && ${Me.Inventory[${bearscroll}](exists)} && !${Me.Effect[${bearscrollbuff}](exists)}
	Me.Inventory[${bearscroll}]:Use
	if ${docatscroll} && ${Me.Inventory[${catscroll}](exists)} && !${Me.Effect[${catscrollbuff}](exists)}
	Me.Inventory[${catscroll}]:Use
	if ${doantihealdart} && ${Me.Inventory[${antihealdart}](exists)} && !${Me.TargetDebuff[${antihealdart}](exists)} && ${Me.Target.Distance} < 11
	Me.Inventory[${antihealdart}]:Use
	if ${dolethalstrikes} && ${LSTimer.TimeRemaining} < 1 && !${Me.Effect[${lethalstrikes}](exists)} && ${Me.EnergyPct} > 30
	{
		Me.Ability[${lethalstrikes}]:Use
		LSTimer:Set[3000]
	}
	if ${Me.Ability[Stalk].IsReady} && !${Stalking.Me} && !${Me.InCombat}
	{
		Me.Ability[Stalk]:Use
	}
	call checkabilitytocast "Shroud of Shadow"
	if ${Return} && !${Me.Effect[Stalking VI](exists)}
	{
		call executeability "Shroud of Shadow" "attack" "While"
	}
	if (${AttackPosition.TargetAngle} > 45 || ${Me.Target.Distance} > 4) && ${Me.Inventory[Flash Powder](exists)} && !${Me.InCombat}
	{
		call checkabilitytocast "Smoke Trick"
		if ${Return}
		{


			if ${Me.Ability[Kidney Puncture].IsReady}
			{
				call executeability "Smoke Trick" "attack" "Neither"
				call executeability "Kidney Puncture"
				IsFollowing:Set[FALSE]
				return
			}
			if ${Me.Ability[${backstab}].IsReady}
			{
				call executeability "Smoke Trick" "attack" "Neither"
				call executeability "${backstab}"
				IsFollowing:Set[FALSE]
				return
			}
			if ${Me.Ability[${wickedstrike}].IsReady}
			{
				call executeability "Smoke Trick" "attack" "Neither"
				call executeability "${wickedstrike}"
				IsFollowing:Set[FALSE]
				return
			}
		}
	}
	If ${AttackPosition.TargetAngle} < 45 && ${Me.Target.Distance} < 5
	{


		if ${Me.Ability[Kidney Puncture].IsReady}
		{
			call executeability "Smoke Trick" "attack" "Neither"
			call executeability "Kidney Puncture"
			IsFollowing:Set[FALSE]
			return
		}
		if ${Me.Ability[${backstab}].IsReady}
		{
			call executeability "Smoke Trick" "attack" "Neither"
			call executeability "${backstab}"
			IsFollowing:Set[FALSE]
			return
		}
	}


}
;********************************************
function Rogue_Combat()
{
	if ${Me.EnergyPct} > 50 && ${Me.EndurancePct} < 50
	{
		call checkabilitytocast "Relentless"
		if ${Return}
		{
			call executeability "Relentless" "attack" "Both"
			return
		}
	}
	if ${Me.TargetHealth} < 25
	{
		call checkabilitytocast "Clout"
		if ${Return}
		{
			call executeability "Clout" "attack" "Both"
			return
		}
	}



	call checkabilitytocast "${kneebreak}"
	if ${Return}
	{
		call executeability "${kneebreak}" "attack" "Both"
		return
	}
	call checkabilitytocast "Kidney Puncture"
	if ${Return}
	{
		call executeability "Kidney Puncture" "attack" "Both"
		return
	}
	call checkabilitytocast "Blindside"
	if ${Return}
	{
		call executeability "Blindside" "attack" "Both"
		return
	}
	if !${Me.TargetDebuff[${hemorrhage}](exists)} && ${Me.Ability[${hemmorage}].IsReady}
	{
		call executeability "${hemorrhage}" "attack" "Both"
		return
	}
	if !${Me.TargetDebuff[${impale}](exists)} && ${Me.Ability[${hemmorage}].IsReady}
	{
		call executeability "${impale}" "attack" "Both"
		return
	}

	call checkabilitytocast "${deadlystrike}"
	if ${Return}
	{
		call executeability "${deadlystrike}" "attack" "Both"
		return
	}

	call checkabilitytocast "${viciousstrike}"
	if ${Return}
	{
		call executeability "${viciousstrike}" "attack" "Both"
		return
	}
	call checkabilitytocast "${wickedstrike}"
	if ${Return}
	{
		call executeability "${wickedstrike}" "attack" "Both"
		return
	}
	if !${Me.TargetDebuff[${ruin}](exists)} && ${Me.Ability[${ruin}].IsReady}
	{
		call executeability "${ruin}" "attack" "Both"
		return
	}

}
;********************************************
function Rogue_Emergency()
{

	if ${Me.InCombat} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]} && (!${Me.Inventory[Flash Powder](exists)}) && ${Me.Inventory[Dazzling Flechette](exists)} && ${Me.Inventory[Dazzling Flechette].IsReady}
	{
		Me.Inventory[Dazzling Flechette]:Use
	}
	if ${Me.InCombat} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]} && (!${Me.Inventory[Flash Powder](exists)} || !${Me.Inventory[Dazzling Flechette](exists)} || !${Me.Inventory[Dazzling Flechette].IsReady})
	{
		call checkabilitytocast "${elusivemark}"
		if ${Return} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
		{
			call executeability "{elusivemark}" "evade" "Neither"
		}
		call checkabilitytocast "Deter"
		if ${Return} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
		{
			call executeability "Deter" "evade" "Neither"
		}
	}
}
;********************************************
function Rogue_PostCombat()
{

}
;********************************************
function Rogue_PostCasting()
{
	if (${AttackPosition.TargetAngle} > 45 || ${Me.Target.Distance} > 4) && ${Me.Inventory[Flash Powder](exists)} && ${Me.InCombat}
	{
		call trickem
		return
	}

	if ${dolethalstrikes} && ${LSTimer.TimeRemaining} < 1 && !${Me.Effect[Bloodlust](exists)} && !${Me.Effect[${lethalstrikes}](exists)} && ${Me.EnergyPct} > 30
	{
		Me.Ability[${lethalstrikes}]:Use
		LSTimer:Set[3000]
	}
	if ${dolethalstrikes} && ${LSTimer.TimeRemaining} < 1 && ${Me.Effect[${lethalstrikes}](exists)} && ${Me.EnergyPct} < 30
	{
		Me.Ability[${lethalstrikes}]:Use
		LSTimer:Set[3000]
	}
}
;********************************************
function trickem()
{
	call checkabilitytocast "Smoke Trick"
	if ${Return}
	{
		call checkabilitytocast "Kidney Puncture"
		if ${Return}
		{
			call executeability "Smoke Trick" "attack" "Neither"
			call executeability "Kidney Puncture"
			IsFollowing:Set[FALSE]
			return
		}
		call checkabilitytocast "${backstab}"
		if ${Return}
		{
			call executeability "Smoke Trick" "attack" "Neither"
			call executeability "${backstab}"
			IsFollowing:Set[FALSE]
			return
		}
		call checkabilitytocast "${wickedstrike}"
		if ${Return}
		{
			call executeability "Smoke Trick" "attack" "Neither"
			call executeability "${wickedstrike}"
			IsFollowing:Set[FALSE]
			return
		}
	}
}
;********************************************
function Rogue_Burst()
{
	call checkabilitytocast "Quickening Jolt"
	if ${Return} && ${fight.ShouldIAttack}
	{
		Me.Ability["Quickening Jolt"]:Use
	}
	if ${Me.InCombat} && ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]} && ${Me.Ability[Escape].IsReady} && ${Me.Inventory[Flash Powder](exists)}
	{
		Me.Ability[Blinding Flash]:Use
		Me.Ability[Escape]:Use
		Me.Ability[Smoke Bomb]:Use
		Me.Ability[Stalk]:Use
		call trickem
	}
	if ${Me.Ability[Vital Strikes].IsReady}
	Me.Ability[Vital Strikes]:Use
	if ${Me.Ability[${keeneye}].IsReady}
	Me.Ability[${keeneye}]:Use
	if ${Me.Ability[Quickblade].IsReady}
	Me.Ability[Quickblade]:Use
	if !${Me.Effect[${lethalstrikes}](exists)}
	{
		Me.Ability[${lethalstrikes}]:Use
		LSTimer:Set[3000]
	}

	call checkabilitytocast "Eviscerate"
	if ${Return}
	{

		call executeability "Eviscerate" "attack" "Both"
		return
	}
	call checkabilitytocast "${shiv}"
	if ${Return}
	{
		call executeability "${shiv}" "attack" "Both"
		return
	}
	call checkabilitytocast "${shank}"
	if ${Return}
	{
		call executeability "${shank}" "attack" "Both"
		return
	}

	DoBurstNow:Set[FALSE]
}


