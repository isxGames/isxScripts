;********************************************
function Monk_DownTime()
{
	If !${Me.Effect[Aum Kor](exists)}
	{
	call checkabilitytocast "Aum Kor"
			if ${Return} 
			{ 
			call executeability "Aum Kor" "Buff" "Neither"
			}
	}
	If !${Me.Effect[Enlightenment](exists)}
	{
	call checkabilitytocast "Enlightenment"
			if ${Return} 
			{ 
			call executeability "Enlightenment" "Buff" "Neither"
			}
	}
	If !${Me.Effect[Iron Resolve VI](exists)}
	{
	call checkabilitytocast "Iron Resolve VI"
			if ${Return} 
			{ 
			call executeability "Iron Resolve VI" "Buff" "Neither"
			}
	}
	If ${Me.Effect[Slap Hands](exists)}
	{
	call checkabilitytocast "Slap Hands"
			if ${Return} 
			{ 
			call executeability "Slap Hands" "Buff" "Neither"
			}
	}
}
;********************************************
function Monk_PreCombat()
{

}
;********************************************
function Monk_Opener()
{

}
;********************************************
function Monk_Combat()
{
	if ${Me.TargetHealth} < 70
		call Monk_Boost
	if ${Me.Ability[Three Finger Strike].IsReady}
		{
		call checkabilitytocast "Three Finger Strike"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Three Finger Strike" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Hammer Fist].IsReady}
		{
		call checkabilitytocast "Hammer Fist"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Hammer Fist" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Palm Explodes the Heart].IsReady}
		{
		call checkabilitytocast "Palm Explodes the Heart"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Palm Explodes the Heart" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Thousand Fists IV].IsReady}
		{
		call checkabilitytocast "Thousand Fists IV"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Thousand Fists IV" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Thundering Fists III].IsReady}
		{
		call checkabilitytocast "Thousand Fists IV"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Thousand Fists IV" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Legendary Fists].IsReady}
		{
		call checkabilitytocast "Legendary Fists"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Legendary Fists" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Fists of Transcendence].IsReady}
		{
		call checkabilitytocast "Fists of Transcendence"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Fists of Transcendence" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Impossible Drunken Palm II].IsReady}
		{
		call checkabilitytocast "Impossible Drunken Palm II"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Impossible Drunken Palm II" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Drunken Arms of the Cyclone II].IsReady}
		{
		call checkabilitytocast "Drunken Arms of the Cyclone II"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Drunken Arms of the Cyclone II" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Flying Kick V].IsReady}
		{
		call checkabilitytocast "Flying Kick V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Flying Kick V" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Kick of the Heavens III].IsReady}
		{
		call checkabilitytocast "Kick of the Heavens III"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Kick of the Heavens III" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Spinning Fists III].IsReady}
		{
		call checkabilitytocast "Spinning Fists III"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Spinning Fists III" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Superior Crescent Kick].IsReady}
		{
		call checkabilitytocast "Superior Crescent Kick"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Superior Crescent Kick" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Staggering Punch V].IsReady}
		{
		call checkabilitytocast "Staggering Punch V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Staggering Punch V" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Ashen Hand VII].IsReady} && ${Me.Stat[Adventuring,Jin]} > 16
		{
		call checkabilitytocast "Ashen Hand VII"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Ashen Hand VII" "Attack" "Both"
			return
			}
		}
	if ${Me.Ability[Boundless Fist VII].IsReady} 
		{
		call checkabilitytocast "Boundless Fist VII"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Boundless Fist VII" "Attack" "Both"
			return
			}
		}			
}
;********************************************
function Monk_Emergency()
{
	If ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]}
		{
		call checkabilitytocast "Magnificent Drunken Stagger"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Magnificent Drunken Stagger" "Buff" "Neither"
			return
			}
		}
	If ${Me.ToPawn.Name.Equal[${Me.TargetOfTarget}]} && !${Me.Effect[Magnificent Drunken Stagger](exists)}
		{
		call checkabilitytocast "Reed in the Wind III"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Reed in the Wind III" "Buff" "Neither"
			return
			}
		}
	If ${Me.HealthPct} < 50
	{
	call checkabilitytocast "Iron Skin"
			if ${Return} && ${fight.ShouldIAttack}
			{
			call executeability "Iron Skin" "Buff" "Neither"
			return
			}
	call checkabilitytocast "Ignore Pain V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Ignore Pain V" "Buff" "Neither"
			return
			}

	}
}
;********************************************
function Monk_PostCombat()
{

}
;********************************************
function Monk_PostCasting()
{
	call Monk_Boost
 	if (${AttackPosition.TargetAngle} > 45 || ${Me.Target.Distance} > 4) && ${Me.InCombat}
     	   {
	   call checkabilitytocast "Storm Stride"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Storm Stride" "Buff" "Neither"
			IsFollowing:Set[FALSE]
			return
			}
	   }
}
;********************************************
function Monk_Burst()
{

}
function Monk_Boost()
{
	if ${Me.Ability[Three Finger Strike].IsReady}
		{
		call checkabilitytocast "Jin Surge V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Jin Surge V" "Buff" "Neither"
			}
		call checkabilitytocast "Secret of Transcendence II"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Secret of Transcendence II" "Buff" "Neither"
			}
		call checkabilitytocast "Fists of Celerity"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Fists of Celerity" "Buff" "Neither"
			}
		call checkabilitytocast "Quickening Jolt"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Quickening Jolt" "Buff" "Neither"
			}

		}
	if ${Me.Ability[Thousand Fists IV].IsReady}
		{
		call checkabilitytocast "Jin Surge V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Jin Surge V" "Buff" "Neither"
			}
		}
	if ${Me.Ability[Impossible Drunken Palm II].IsReady}
		{
		call checkabilitytocast "Jin Surge V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Jin Surge V" "Buff" "Neither"
			}
		}
	if ${Me.Ability[Flying Kick V].IsReady}
		{
		call checkabilitytocast "Jin Surge V"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Jin Surge V" "Buff" "Neither"
			}
		}
}
