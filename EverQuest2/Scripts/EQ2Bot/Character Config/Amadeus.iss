;*************************************************************
;Amadeus.iss
;;;
;;; This is an example of how you would utilize a custom script file to be used with EQ2Bot.  The name of this file should be ${Me.Name}.iss
;;;
;;; If you want to call anything from this file within your class routine files or EQ2Bot.iss, then you would just check to see if
;;; ${UseCustomRoutines} is TRUE (See EQ2Bot.iss for examples)
;;;

#define __USING_CUSTOM_ROUTINES__

;; This function is called when EQ2Bot is initialized
function Custom__Initialization()
{
}

function Custom__Buff_Init()
{
   _PreAction[1]:Set[MySelfBuff]
   _PreSpellRange[1,1]:Set[30]

   _PreAction[2]:Set[MyGroupBuffs]
   _PreSpellRange[2,1]:Set[25]
   _PreSpellRange[2,2]:Set[26]
}

function Custom__Combat_Init()
{
   _Action[1]:Set[Nukes]
   _SpellRange[1,1]:Set[170]
   _SpellRange[1,2]:Set[171]

   _Action[2]:Set[Taunt]
   _SpellRange[2,1]:Set[160]
}

function Custom__PostCombat_Init()
{
   _PostAction[1]:Set[AA_BindWound]
   _PostSpellRange[1,1]:Set[172]
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; From this point forward, the same system should work almost exactly as it does with the Class Files 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function Custom__Buff_Routine(int xAction)
{
    
    return Buff Complete
    ;; If you are using the switch below, then remove the 'return' line above and this comment.
    ;;;;;;
	switch ${_PreAction[${xAction}]}
	{

		default
			return Buff Complete
			break
	}
}

function Custom__Combat_Routine(int xAction)
{
    
    
    return CombatComplete
    ;; If you are using the switch below, then remove the 'return' line above and this comment.
    ;;;;;;
	switch ${_Action[${xAction}]}
	{
		default
			return CombatComplete
			break
	}
}

function Custom__Post_Combat_Routine(int xAction)
{
    
    return PostCombatRoutineComplete
    ;; If you are using the switch below, then remove the 'return' line above and this comment.
    ;;;;;;
	switch ${_PostAction[${xAction}]}
	{
	    
		default
			return PostCombatRoutineComplete
			break
	}
}

function Custom__Have_Aggro()
{
}

function Custom__Lost_Aggro(int mobid)
{
}