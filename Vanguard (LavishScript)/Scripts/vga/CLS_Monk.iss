;********************************************
function Monk_DownTime()
{
	If !${Me.Effect[Aum Ti](exists)}
	{
	call checkabilitytocast "Aum Ti"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Aum Ti" "Buff" "Neither"
			}
	}
	If !${Me.Effect[Enlightenment](exists)}
	{
	call checkabilitytocast "Enlightenment"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Enlightenment" "Buff" "Neither"
			}
	}
	If !${Me.Effect[Iron Resolve VI](exists)}
	{
	call checkabilitytocast "Iron Resolve VI"
			if ${Return} && ${fight.ShouldIAttack}
			{ 
			call executeability "Iron Resolve VI" "Buff" "Neither"
			}
	}
	If ${Me.Effect[Slap Hands](exists)}
	{
	call checkabilitytocast "Slap Hands"
			if ${Return} && ${fight.ShouldIAttack}
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
	call Monk_Boost
		
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