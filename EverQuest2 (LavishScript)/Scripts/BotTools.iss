/*******************************************************************
BotTools v.0.01
	By Mandrake


Example: 
	#include ${LavishScript.HomeDirectory}/Scripts/BotTools.iss
		function Class_Declaration()
		{
			Declare Tools BotTools script
		}

		function somewhereelse
		{
			if ${Actor[${Tools.LowestHealth}](exists)}
			{
			call CastSpellRange 1 0 0 0 ${Actor[${Tools.LowestHealth}].ID}
			}
		}



Members:

LowestHealth
	- Returns the actorID of the groupmember with lowest HP
		- Later expand to include raid as a param
LowestPower
	- Same as above
ArcheType
	- Returns the archetype of the actor (broken in isxeq2)


---- Following are temporarly removed
*BuffTimer(ActorID, SpellName)
	-Returns the time left on a timer set with SetBuffTimer
		- For use on non-maintained buffs like Sow, Spirit Shards
*SetBuffTimer
	-Initiates a timer object
*DelBuffTimer
	-Destroys the timer object
*GroupChanges
	-Will return ActorID of new group members since last update
*UpdateGroup
	-Sets the groupchanges object
********************************************************************/



objectdef BotTools
{
	member:int LowestHealth()
	{
	variable int lowest=${Me.ID}
	variable int tmpgrp=1
	variable int grpcnt=${Me.GroupCount}
		do
		{
		;===============================================;
		;Loop through the group, pick the lowest one	;
		;===============================================;
			if ${Me.Group[${tmpgrp}].ToActor.Health}<=${Actor[${lowest}].Health} && ${Me.Group[${tmpgrp}].ToActor.Health}<100 && ${Me.Group[${tmpgrp}].ToActor.Health}>0 && ${Me.Group[${tmpgrp}](exists)}
			{
			lowest:Set[${Me.Group[${tmpgrp}].ID}]
			}
		}
		While ${tmpgrp:Inc}<${grpcnt}
		Return ${lowest}
	}
	member:int LowestPower()
	{
	variable int lowest=${Me.ID}
	variable int tmpgrp=1
	variable int grpcnt=${Me.GroupCount}
		do
		{
		;===============================================;
		;Loop through the group, pick the lowest one	;
		;===============================================;
			if ${Me.Group[${tmpgrp}].ToActor.Power}<=${Actor[${lowest}].Power} && ${Me.Group[${tmpgrp}].ToActor.Power}<100 && ${Me.Group[${tmpgrp}].ToActor.Power}>0 && ${Me.Group[${tmpgrp}](exists)}
			{
			lowest:Set[${Me.Group[${tmpgrp}].ID}]
			}
		}
		While ${tmpgrp:Inc}<${grpcnt}
		Return ${lowest}
	}

	member:string ArcheType(int ActorID)
	{
		switch ${Actor[${ActorID}].Class}
		{
			case gaurdian
			case berserker
			case bruiser
			case monk
			case shadowknight
			case paladin
				return fighter
			case fury
			case templar
			case mystic
			case defiler
			case warden
			case inquisitor
				return priest
			case brigand
			case swashbuckler
			case ranger
			case dirge
			case troubador
			case assassin
				return scout
			case coercer
			case illusionist
			case conjuror
			case wizard
			case necromancer
			case warlock
				return mage
			case default
				return unknown
		}
	}

}

