function PauseScript()
{
		while ${doPause}
			wait 1
		while ${Pawn[Me].IsDead}
			wait 1
		while ${Me.HealthPct} == 0
			wait 1
}
;********************************************
function loot()
{
	if ${DoLoot} && ${Group.Count} < 7
	{
	variable int iCount

	; We are still in combat!
	if ${Me.InCombat} || ${Me.Encounter} > 0
	{
		return 
	}
	wait 5
	iCount:Set[1]
	; Cycle through all the Pawns and find some corpses to Loot and Skin
	do
	{
		if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < 10 && ${Pawn[${iCount}].ContainsLoot}
			{
			Pawn[${iCount}]:Target
			wait 5
			call movetoobject ${Pawn[${Me.Target}].ID} 4 0
			VGExecute "/lootall"
			waitframe
			VGExecute "/cleartargets"
			}
	}	
	while ${iCount:Inc} < ${VG.PawnCount}
	}
}
;********************************************
function executeability(string x_ability, string x_type, string CP)
{
	call mobresist "${x_ability}"
	if ${Return}
	{
	debuglog "Casting ${x_ability}"
	if ${Me.Ability[${x_ability}].IsReady}
	{
		Me.Ability[${x_ability}]:Use
		if ${x_type.Equal[Heal]}
			{
			actionlog "${x_ability} ${Me.DTarget}"
			call MeCasting ${CP}
			return
			}
		if ${x_type.Equal[attack]}
			{
			actionlog "${x_ability} ${Me.Target}"
			call MeCasting ${CP}
			return
			}
		if ${x_type.Equal[buff]}
			{
			actionlog "${x_ability} ${Me.DTarget} BUFF"
			call MeCasting ${CP}
			return
			}	
	}
	if !${Me.Ability[${x_ability}].IsReady} 
		debuglog "${Me.Ability[${x_ability}]} Not Ready ${Me.Ability[${x_ability}].TimeRemaining} Sec."
		return 
	}
	return

}

;********************************************
function:bool checkabilitytocast(string aName)
{
	debuglog "Checking ${aName}"
	if ${Me.Ability[${abilString}].EnergyCost(exists)} && ${Me.Ability[${abilString}].EnergyCost} == 0 && ${Me.Ability[${abilString}].EnduranceCost(exists)} && ${Me.Ability[${abilString}].EnduranceCost} == 0
		{
		debuglog "Has No Ability Cost DO IT "
		return TRUE
		}
	if ${Me.Ability[${aName}].EnergyCost} > ${Me.Energy}
		{
		debuglog "Not Enough Energy for ${aName}"
		return FALSE
		}
	if ${Me.Ability[${aName}].EnduranceCost} > ${Me.Endurance} 
		{
		debuglog "Not Enough Endurance for ${aName}"
		return FALSE
		}	
	if ${Me.Ability[${aName}].JinCost} > ${Me.Stat[Adventuring,Jin]} 
		{
		debuglog "Not Enough Jin for ${aName}"
		return FALSE
		}
	if ${Me.Ability[${aName}].VirtuePointsCost} > ${Me.Stat[Adventuring,Virtue Points]} 
		{
		debuglog "Not Enough Virtue for ${aName}"
		return FALSE
		}
	if ${Me.Ability[${aName}].PhenomenaPointsCost} > ${Me.Stat[Adventuring,Phenomena Points]} 
		{
		debuglog "Not Enough Phenomena for ${aName}"
		return FALSE
		}
	if ${Me.Ability[${aName}].SpecialPointsCost} > ${Me.Stat[Adventuring,Special Points]} 
		{
		debuglog "Not Enough Special for ${aName}"
		return FALSE
		}
	if ${Me.Ability[${aName}].TimeRemaining} > 0
		{
		debuglog "TimeRemaining Must wait ${Me.Ability[${aName}].TimeRemaining} "
		return FALSE
		}

	debuglog "Whatever Do IT"
	return TRUE

}
;********************************************
atom(script) NeedBuffs() 
{
	GroupNeedsBuffs:Set[TRUE]
} 
;********************************************
function CheckPosition()
{
	call assistpawn
	call facemob
	call MoveToTarget
}
;********************************************
function assistpawn()
{
	if ${doassistpawn} 
	{
	if ${Pawn[${assistpawn}].Distance} < 50 && ${Pawn[${assistpawn}](exists)}
		{
		VGExecute /assist ${assistpawn}
		}
	}
	return
}
;********************************************
function facemob()
{
	if ${doFaceTarget}
	{
	call assistpawn
	if ${Me.Target.ID(exists)}
		{
		face ${Me.Target.X} ${Me.Target.Y}
		}
	}
	return

}
;********************************************     
function TooClose()
{
	call facemob
	if ${Pawn[{Me.Target}].Distance} < 1 && ${Pawn[{Me.Target}](exists)}
		{
		VG:ExecBinding[movebackward]
		wait 1
		VG:ExecBinding[movebackward,release]
		return
		}
	return
}
;********************************************     
function followpawn()
{
	if ${dofollowpawn}
	{
	if ${Pawn[${followpawn}].Distance} > ${followpawndist} && ${Pawn[${followpawn}].Distance} < 50 && ${Pawn[${followpawn}](exists)}
		{
		call movetoobject ${Pawn[${followpawn}].ID} ${followpawndist} 0
		}
	}
	return
}

; *********************
; **  Pause Routines **
; *********************
function Pause(float delay)
  {
   Declare DelayTimer int local ${Math.Calc[${LavishScript.RunningTime}+(1000*${delay})]}

   While ${LavishScript.RunningTime}<${DelayTimer}
     {
      Waitframe 
     }
  }
; ***********************************************
function MeCasting(string CP)
{
	wait 3
	debuglog "Waiting After Cast"
	;Sub to wait till casting is complete before running the next command
	while ${Me.IsCasting}
		{
			if ${CP.Equal[While]} || ${CP.Equal[Both]}
				{
				call EmergencyActions
				wait 1
				}
			elseif ${CP.Equal[Neither]} || ${CP.Equal[Post]}
				{
				wait 1
				}
		}

	while "${VG.InGlobalRecovery}"
	{
		wait 1
	}

	while ${Me.ToPawn.IsStunned}
	{
		wait 1
	}

	while !${Me.Ability[Torch].IsReady}
	{
		wait 1
	}

	if ${Me.Target.IsDead} || ${Me.TargetHealth} == 0
	{
		lastattack:Set[None]
		newattack:Set[TRUE]
	}
	if ${x_type.Equal[Heal]}
		HealTimer:Set[${SlowHeals}]
	if ${doSlowAttacks}
		wait ${SlowAttacks}
	debuglog "Done Waiting, Continue Fighting"
	if ${CP.Equal[Both]} || ${CP.Equal[Post]}
		{
		call PostCastingActions
		}
	return
}

;********************************************
function MoveToTarget()
{
	if ${doMoveToTarget}
	{
		call facemob
		call assistpawn
		if ${fight.ShouldIAttack} && ${Pawn[${Me.Target}].Distance} > 4
		{
			actionlog "Moving to Melee"
			call movetoobject ${Pawn[${Me.Target}].ID} 4 1
			call TooClose
			return
		}
	}
	return
}
;=================================================
function LoadUtility()
{

}
;=================================================
function SaveUtility()
{

}




; ******************
; ** Timer Object **
; ******************
objectdef Timer
{
  variable uint EndTime
 
  method Set(uint Milliseconds)
  {
     EndTime:Set[${Milliseconds}+${Script.RunningTime}]
  }
  member:uint TimeLeft()
  {
     If ${Script.RunningTime}>=${EndTime}
        Return 0
     Return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
  }
} 

variable Timer Timer

function MH_Clock()
{
   ;MH_Timer:Set[1234]
   ;Note: Above time is in ms - so the above is 1.234 seconds
   echo ${MH_Timer.TimeLeft}ms remaining
   Wait 99999 !${MH_Timer.TimeLeft}
   echo Time's up!
}
atom ParseLog(string aText) 
{
	if ${doParser}
	{
	UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${aText}]
	}
}
atom actionlog(string aText) 
{
	if ${doActionLog}
	{
	UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${aText}]
	}
}
atom debuglog(string aText) 
{
	if ${doDeBug}
	{
	UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${aText}]
	}
}


objectdef HealTimer
{
  variable uint EndTime
 
  method Set(uint Milliseconds)
  {
     EndTime:Set[${Milliseconds}+${Script.RunningTime}]
  }
  member:uint TimeLeft()
  {
     If ${Script.RunningTime}>=${EndTime}
        Return 0
     Return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
  }
} 
variable HealTimer HealTimer

objectdef BuffTimer
{
  variable uint EndTime
 
  method Set(uint Milliseconds)
  {
     EndTime:Set[${Milliseconds}+${Script.RunningTime}]
  }
  member:uint TimeLeft()
  {
     If ${Script.RunningTime}>=${EndTime}
        Return 0
     Return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
  }
} 
variable BuffTimer BuffTimer
;*********************************
atom cleardebug()
{
	UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	if ${ParseCount}<7
	{
	ParseCount:Inc
	}
	if ${ParseCount}>6
	{
	UIElement[ParseList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	ParseCount:Set[0]
	}
	
	
}