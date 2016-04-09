;*************************************************************
;Valerian.iss
;;;
;;; This is an example of how you would utilize a custom script file to be used with EQ2Bot.  The name of this file should be ${Me.Name}.iss
;;;
;;; If you want to call anything from this file within your class routine files or EQ2Bot.iss, then you would just check to see if
;;; ${UseCustomRoutines} is TRUE (See EQ2Bot.iss for examples)
;;;

#define __USING_CUSTOM_ROUTINES__

/* This object inherits the object created in Illusionist.iss, and overrides the Spam method. */
objectdef my_overrides inherits custom_overrides
{
	method Spam(... Args)
	{
		switch ${Args[1]}
		{
			case Mana Flow
				/* Verify that we should be able to cast this before spamming it. */
				if ${Actor[${Args[2]}](exists)} && ${Actor[${Args[2]}].Distance2D}<${Position.GetSpellMaxRange[${Args[2]},0,30]} && !${Actor[${Args[2]}].CheckCollision} && !${Me.IsMoving}
				{
					eq2execute tell ${Actor[${Args[2]}].Name} Mana Incoming!
					/* tellchannel so we can get a good ACT timer if we so desire, and coordinate with other illies */
					eq2execute tellchannel ValerianSpam ManaFlow on == ${Actor[${Args[2]}].Name} ==
				}
				break
			default
				break
		}
	}
}

;; This function is called when EQ2Bot is initialized
function Custom__Initialization()
{
	/* This provides an example of loading a character-specific UI tab. */
/*
	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[${Me.Name}]
	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[${Me.Name}]:Move[1]
	ui -load -parent "${Me.Name}@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_CHARACTER_CONFIG}/${Me.Name}_UI.xml"
*/


	/* This is required to override the Illusionist's Custom variable/object type for Spam. */
	deletevariable Custom
	declarevariable Custom my_overrides script

}

function Custom__Buff_Init()
{
	_PreAction[1]:Set[Hover]
	_PreAction[2]:Set[Spellshield]
	_PreSpellRange[2,1]:Set[361]

}

function Custom__Combat_Init()
{
}

function Custom__PostCombat_Init()
{
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; From this point forward, the same system should work almost exactly as it does with the Class Files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function Custom__Buff_Routine(int xAction)
{
	switch ${_PreAction[${xAction}]}
	{
		case Hover /* Dark Elf racial slowfall ability. */
			call CastSpellRange AbilityID=${Me.Ability[Hover].ID} castwhilemoving=1
			break
		case SpellShield
			if !${Me.Maintained[${SpellType[${_PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange start=${_PreSpellRange[${xAction}]} TargetID=${Me.ID} castwhilemoving=1
			break

		default
			return Buff Complete
			break
	}
}

function Custom__Combat_Routine(int xAction)
{
	return CombatComplete
}

function Custom__Post_Combat_Routine(int xAction)
{
}

function Custom__Have_Aggro()
{
}

function Custom__Lost_Aggro(int mobid)
{
}