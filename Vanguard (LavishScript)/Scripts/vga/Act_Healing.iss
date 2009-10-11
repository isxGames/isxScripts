;===================================================
;===     Class Specific Pre Heal Check         ====
;===================================================

function ClassSpecificPreHealCheck()
{
	switch ${Me.Class}
	{
		case Blood Mage
			call BM_PreHealRoutine
			break
			
		default
			break
	}	
}

function Healcheck()
{
	;; If you want to avoid calling this function at all (ie, if the class specific function determines that everyone is max health -- then
	;; you can return "HEALSDONE" to avoid running the rest of this function and further optimize the script.
	call ClassSpecificPreHealCheck
	if ${Return.Equal[HEALSDONE]}
		return
	

	if ${ClassRole.healer}
	{
		;;  Group Healing by Type Forward
		if ${Group.Count} > 1 && ${Group.Count} < 7
		{
		call CheckGroupDamage
		}

	}
}
		

;******************************Change forms/Stances***********************
function changeformstance()
{
	if ${fight.IShouldAttack} && ${doCombatStance} && !${Me.Effect[{CombatStance}](exists)}
		{
		Me.Form[${CombatStance}]:ChangeTo
		}
	if !${fight.IShouldAttack} && ${doNonCombatStance} && !${Me.Effect[{NonCombatStance}](exists)}
		{
		Me.Form[${NonCombatStance}]:ChangeTo
		}	
}
 


;******************************Hot Timers and IsReady Timers***********************
function SetupHOTTimer()
{
	variable int GroupNumber

	if ${Me.IsGrouped}
	{
		for ( GroupNumber:Set[1] ; ${Group[${GroupNumber}].ID(exists)} ; GroupNumber:Inc )
		{
			HOTReady[${GroupNumber}]:Set[${LavishScript.RunningTime}]
		}
	}
}

function:bool CanApplyHOT(string HealAbility, int GroupNumber)
{
	;if !${Me.IsGrouped} || !${Me.Ability[${HealAbility}].IsReady}
	;	return
	
	if ${LavishScript.RunningTime}<${HOTReady[${GroupNumber}]}
		return FALSE
		
	return TRUE
}

function:bool SaveHOTTime(string HealAbility, int GroupNumber)
{
	;Me.Ability[${HealAbility}]:Use

	variable int DelaySeconds
	
	if ${HealAbility.Find[Alleviate]}
		DelaySeconds:Set[17]
	elseif ${HealAbility.Find[Kiss of Heaven]}
		DelaySeconds:Set[31]
	else
		DelaySeconds:Set[1]

	HOTReady[${GroupNumber}]:Set[${Math.Calc[${LavishScript.RunningTime}+(1000*${DelaySeconds})]}]

	wait 3
	
	return TRUE
}
