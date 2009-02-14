function PauseScript()
{
	while (${doPause} || ${Me.ToPawn.IsDead} || ${Me.HealthPct} == 0)
	{
		waitframe
	}
}
;********************************************
function lootit()
{
	;; if there are no corpses around...then why bother.
	if !${Pawn[Corpse](exists)}
		return
	
	if ${DoLoot} && ${Group.Count} < 7 && (!${Me.InCombat} || ${Me.Encounter} > 0)
	{
		variable int iCount
		iCount:Set[1]
		; Cycle through all the Pawns and find some corpses to Loot and Skin
		do
		{
			if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < 10 && ${Pawn[${iCount}].ContainsLoot}
			{
				Pawn[${iCount}]:Target
				wait 5
				call movetoobject ${Me.Target.ID} 4 0
				VGExecute "/lootall"
				waitframe
				VGExecute "/cleartargets"
			}
		}	
		while ${iCount:Inc} <= ${VG.PawnCount}
	}
}
;********************************************
function executeability(string x_ability, string x_type, string CP)
{
	variable int64 CurrentTargetID
	variable bool DoIt = FALSE
	
	;; Auto Counter...
	if ${DoCountersASAP} && ${CounterReactionReady}
	{
		if (${Time.Timestamp} <= ${CounterReactionTimer})
		{
			CurrentTargetID:Set[${Me.Target.ID}]
			if ${Me.Target.ID} != ${CounterReactionPawnID}
			{
				Pawn[id,${CounterReactionPawnID}]:Target
				wait 2
			}
			if ${Me.Ability[id,${CounterReactionAbilityID}].IsReady}
			{
				echo "VGA: Casting Counterspell '${Me.Ability[id,${CounterReactionAbilityID}].Name}'!"
				Me.Ability[id,${CounterReactionAbilityID}]:Use
				wait 3
			}
			if ${Me.Target.ID} != ${CurrentTargetID}
			{
				Pawn[id,${CurrentTargetID}]:Target
				wait 2
			}
		}
		CounterReactionReady:Set[FALSE]
	}
	
	;; Auto Chains
	if ${DoChainsASAP} && ${ChainReactionReady}
	{
		if (${Time.Timestamp} <= ${ChainReactionTimer})
		{
			CurrentTargetID:Set[${Me.Target.ID}]
			if ${Me.Target.ID} != ${ChainReactionPawnID}
			{
				Pawn[id,${ChainReactionPawnID}]:Target
				wait 2
			}
			if ${Me.Ability[id,${ChainReactionAbilityID}].IsReady}
			{
				echo "VGA: Casting Chain '${Me.Ability[id,${ChainReactionAbilityID}].Name}'!"
				Me.Ability[id,${ChainReactionAbilityID}]:Use
				wait 3
			}
			if ${Me.Target.ID} != ${CurrentTargetID}
			{
				Pawn[id,${CurrentTargetID}]:Target
				wait 2
			}
		}
		ChainReactionReady:Set[FALSE]
	}
	
	
	switch ${x_type}
	{
		case Heal
			DoIt:Set[TRUE]
			break
			
		case attack		
			call mobresist "${x_ability}"
			if ${Return}
				DoIt:Set[TRUE]

		case buff
			DoIt:Set[TRUE]
			break
			
		case evade
			call mobresist "${x_ability}"
			if ${Return}
				DoIt:Set[TRUE]
			break
			
		case utility
			DoIt:Set[TRUE]
			break
			
		case NoCheck
			DoIt:Set[TRUE]
			break
			
		default
			DoIt:Set[TRUE]
			break
	}

	if ${DoIt}
	{
		debuglog "Casting ${x_ability}"
		if ${Me.Ability[${x_ability}].IsReady}
		{
			Me.Ability[${x_ability}]:Use
			
			switch ${x_type}
			{
				case Heal
					actionlog "${x_ability} ${Me.DTarget}"
					call MeCasting ${CP}
					return
					
				case attack		
					actionlog "${x_ability} ${Me.Target}"
					call MeCasting ${CP}
					return
		
				case buff
					actionlog "${x_ability} ${Me.DTarget} BUFF"
					call MeCasting ${CP}
					return
					
				case evade
					actionlog "${x_ability} ${Me.DTarget} EVADE"
					call MeCasting ${CP}
					return
				
				case utility
					actionlog "${x_ability} ${Me.DTarget} UTILITY"
					call MeCasting ${CP}
					return
					
				case Lifetap
					actionlog "${x_ability} ${Me.DTarget} LIFETAP"
					call MeCasting ${CP}
					return
							
				default
					call MeCasting ${CP}
					return
			}			
		}
		else
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
		debuglog "TimeRemaining Must wait ${Me.Ability[${aName}].TimeRemaining}"
		return FALSE
	}
	if !${Me.Ability[${aName}].IsReady}
	{
		debuglog "'${aName}' is not ready!"
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
	call targettank
}
;********************************************
function targettank()
{
	if (${Pawn[exactname,${tankpawn}](exists)} && !${Me.FName.Equal[${tankpawn}]} && ${Pawn[exactname,${tankpawn}].Distance} < 50)
	{
		VGExecute /targetauto ${tankpawn}
	}
	return
}
;********************************************
function assistpawn()
{
	if ${doassistpawn} 
	{
		if (${Pawn[exactname,${assistpawn}](exists)} && ${Pawn[exactname,${assistpawn}].CombatState} != 0 && ${Pawn[exactname,${assistpawn}].Distance} < 50)
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
	if ${Me.Target(exists)} && ${Me.Target.Distance} < 1
	{
		VG:ExecBinding[movebackward]
		wait 2
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
		if (${Pawn[exactname,${followpawn}](exists)} && ${Pawn[exactname,${followpawn}].Distance} > ${followpawndist} && ${Pawn[exactname,${followpawn}].Distance} < 50)
		{
			call movetoobject ${Pawn[exactname,${followpawn}].ID} ${followpawndist} 0
		}
	}
	return
}

; *********************
; **  Pause Routines **
; *********************
function Pause(float delay)
{
	declare DelayTimer int local ${Math.Calc[${LavishScript.RunningTime}+(1000*${delay})]}

   	while ${LavishScript.RunningTime}<${DelayTimer}
 	{
		waitframe 
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
		}
		elseif ${CP.Equal[Neither]} || ${CP.Equal[Post]}
		{
		}
		
		waitframe
	}

	while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
	{
		waitframe
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
		if ${fight.ShouldIAttack} && ${Me.Target.Distance} > 4
		{
			actionlog "Moving to Melee"
			call movetoobject ${Me.Target.ID} 4 1
			call TooClose
			return
		}
	}
	return
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
	 	if ${Script.RunningTime}>=${EndTime}
	    	return 0
	 	return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
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
	 	if ${Script.RunningTime}>=${EndTime}
	    	return 0
	 	return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
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
	 	if ${Script.RunningTime}>=${EndTime}
	    	return 0
	 	return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
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