;********************************************
function Disciple_DownTime()
{

}
;********************************************
function Disciple_PreCombat()
{

}
;********************************************
function Disciple_Opener()
{
	Endowment:Set[None]
	EndowmentStep:Set[0]
}
;********************************************
function Disciple_Combat()
{
	call checkabilitytocast "Immortal Jade Dragon"
	if ${Return}
	{
		Me.Form[Immortal Jade Dragon]:ChangeTo
	}
	if (!${Me.Effect[Endowment of Mastery](exists)}) && (${Endowment.Equal[None]} || ${Endowment.Equal[Mastery]})
	{
		if ${EndowmentStep} == 0
		{
			call checkabilitytocast "Soul Cutter VI"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "Soul Cutter VI" "Attack" "Both"
				Endowment:Set[Mastery]
				EndowmentStep:Set[1]
			}
		}
		if ${EndowmentStep} == 1
		{
			call checkabilitytocast "Void Hand VII"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "Void Hand VII" "Attack" "Both"
				EndowmentStep:Set[2]
			}
		}
		if ${EndowmentStep} == 2
		{
			call checkabilitytocast "Knife Hand IV"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "Knife Hand IV" "Attack" "Both"
				Endowment:Set[None]
				EndowmentStep:Set[0]
				return
			}
		}
	}
	if (!${Me.Effect[Endowment of Enmity](exists)}) && (${Endowment.Equal[None]} || ${Endowment.Equal[Enmity]})
	{
		if ${EndowmentStep} == 0
		{
			call checkabilitytocast "Cyclone Kick V"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "Cyclone Kick V" "Attack" "Both"
				Endowment:Set[Enmity]
				EndowmentStep:Set[1]
			}
		}
		if ${EndowmentStep} == 1
		{
			call checkabilitytocast "Ra'Jin Flare III"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "Ra'Jin Flare III" "Attack" "Both"
				Endowment:Set[None]
				EndowmentStep:Set[0]
				return
			}
		}
	}
	if ${Me.Stat[Adventuring,Jin]} > 18 && ${fight.ShouldIAttack}
	{
		call checkabilitytocast "Purity"
		if ${Return}
		{
			Pawn[${tankpawn}]:Target
			wait 3
			call executeability "Purity" "Buff" "Neither"
			return
		}
	}
	if !${Me.Effect[Petal Splits Earth](exists)} && ${fight.ShouldIAttack}
	{
		call checkabilitytocast "Petal Splits Earth"
		if ${Return}
		{
			call executeability "Petal Splits Earth" "Attack" "Both"
			return
		}
	}
	if !${Me.Effect[White Lotus Strike III](exists)} && ${fight.ShouldIAttack}
	{
		call checkabilitytocast "White Lotus Strike III"
		if ${Return}
		{
			call executeability "White Lotus Strike III" "Attack" "Both"
			return
		}
	}
	if ${Me.Ability[Baiting Strike  IV].IsReady}
	{
		call checkabilitytocast "Baiting Strike  IV"
		if ${Return}
		{
			Pawn[${tankpawn}]:Target
			wait 3
			call executeability "Baiting Strike  IV" "Attack" "Both"
			return
		}
	}
	if !${Me.TargetDebuff[Blooming Ridge Hand IV](exists)} && ${fight.ShouldIAttack}
	{
		call checkabilitytocast "Blooming Ridge Hand IV"
		if ${Return}
		{
			call executeability "Blooming Ridge Hand IV" "Attack" "Both"
			return
		}
	}
	call checkabilitytocast "Touch of Discord VI"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Touch of Discord VI" "Attack" "Both"
		return
	}
	call checkabilitytocast "Fist of Discord I"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Fist of Discord I" "Attack" "Both"
		return
	}
	if ${Me.Stat[Adventuring,Jin]} > 13
	{
		if ${fight.ShouldIAttack} && !${Me.TargetDebuff[Touch of Ox III](exists)}
		{
			call checkabilitytocast "Touch of Ox III"
			if ${Return}
			{
				call executeability "Touch of Ox III" "Attack" "Both"
				return
			}
		}
		if ${fight.ShouldIAttack} && !${Me.TargetDebuff[Touch of Woe V](exists)}
		{
			call checkabilitytocast "Touch of Woe V"
			if ${Return}
			{
				call executeability "Touch of Woe V" "Attack" "Both"
				return
			}
		}
		if ${fight.ShouldIAttack}
		{
			call checkabilitytocast "Cyclone Kick V"
			if ${Return}
			{
				call executeability "Cyclone Kick V" "Attack" "Both"
				return
			}
		}
	}

	if ${Me.DTargetHealth} < 90 && ${Me.Ability[Blessed Whirl].IsReady} && ${fight.ShouldIAttack}
	{
		call checkabilitytocast "Blessed Whirl"
		if ${Return}
		{
			call executeability "Blessed Whirl" "Attack" "Both"
			return
		}
	}
	if ${fight.ShouldIAttack}
	{
		call checkabilitytocast "Void Hand VII"
		if ${Return}
		{
			call executeability "Void Hand VII" "Attack" "Both"
			return
		}
	}
}
;********************************************
function Disciple_Emergency()
{

}
;********************************************
function Disciple_PostCombat()
{

}
;********************************************
function Disciple_PostCasting()
{
	if !${Me.Effect[Inner Light VI](exists)} && ${Me.Stat[Adventuring,Jin]} > 4 && ${fight.ShouldIAttack}
	{
		actionlog "Need Inner Light"

		call checkabilitytocast "Inner Light VI"
		if ${Return} && ${fight.ShouldIAttack}
		{
			call executeability "Inner Light VI" "Attack" "Both"
		}
	}
}
;********************************************
function Disciple_Burst()
{
	call checkabilitytocast "Inner Light VI"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Inner Light VI" "Buff" "Neither"
	}
	Me.Form[Celestial Tiger]:ChangeTo
	call checkabilitytocast "Clarity"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Clarity" "Buff" "Neither"
	}
	call checkabilitytocast "Touch of Discord VI"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Touch of Discord VI" "Attack" "Both"
	}
	call checkabilitytocast "Fist of Discord I"
	if ${Return} && ${fight.ShouldIAttack}
	{
		call executeability "Fist of Discord I" "Attack" "Both"
		return
	}
	call checkabilitytocast "Cyclone Kick V"
	if ${Return}
	{
		call executeability "Cyclone Kick V" "Attack" "Both"
		return
	}
	DoBurstNow:Set[FALSE]
}

objectdef LifeTimer
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}
	member:uint TimeLeft()
	{
		if ${Script.RunningTime}>=${EndTime}
		return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}
variable LifeTimer LifeTimer





