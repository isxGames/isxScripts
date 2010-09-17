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

}
;********************************************
function Disciple_Combat()
{

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

 if ${Me.Ability[Endowment of Enmity](exists)} && !${Me.Effect[Endowment of Enmity](exists)} && ${Me.Stat[Adventuring,Jin]} > 4 && ${fight.ShouldIAttack}
 {
 actionlog "Need Endowment of Enmity"
		call checkabilitytocast "Cyclone Kick V"
			if ${Return} && ${fight.ShouldIAttack}
			{
			call executeability "Cyclone Kick V" "Attack" "Both"
			}
		call checkabilitytocast "Ra'Jin Flare III"
			if ${Return} && ${fight.ShouldIAttack}
			{
			call executeability "Ra'Jin Flare III" "Attack" "Both"
			}
 }

 if ${Me.Ability[Endowment of Life](exists)} && ${LifeTimer.TimeLeft} == 0 && ${fight.ShouldIAttack}
 {
 actionlog "Need Endowment of Life on Tank"
 VGExecute /targetauto ${tankpawn}
		call checkabilitytocast "${TapSoloHeal}"
			if ${Return} && ${fight.ShouldIAttack}
			{
			call executeability "${TapSoloHeal}" "Heal" "neither"
				call checkabilitytocast "Cyclone Kick V"
					if ${Return} && ${fight.ShouldIAttack}
					{
					call executeability "Cyclone Kick V" "Attack" "Both"
					call checkabilitytocast "Void Hand VII"
						if ${Return} && ${fight.ShouldIAttack}
						{
						call executeability "Void Hand VII" "Attack" "Both"
						LifeTimer:Set[120000]
						}
					}
			}

		
  }
}
;********************************************
function Disciple_Burst()
{

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

objectdef PurityTimer
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
variable PurityTimer PurityTimer
