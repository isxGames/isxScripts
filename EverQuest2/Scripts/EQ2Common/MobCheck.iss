
;-----------------------------------------------------------------------------------------------
; MobCheck.iss Version 1.0.0  Updated: 04/10/07
;
; Written by: Pygar
; Borrowed Heavily from EQ2Bot
;
; Purpose:  Instantiates an object for checking mobs around you and thier current
;						 action state vs you and your group or raid.
;
; Members:
;			AggroGroup	- Check if mob is aggro on Raid, group, or pet only, doesn't check agro on Me
;			Count			- returns count of mobs engaged in combat near you.  Includes mobs engaged to
;										other pcs/groups
;			Detect			-	returns true if you, group, raidmember, or pets have agro from mob in range
;			Target			-	Returns true if the Actor passed is agro and targeting you,group, or raid
;
; Methods:
;			CheckMYAggro-	(bool) returns true if you, group, pets, or raid have aggro from any mob in range

; Revision History
; ----------------
; v2.1.02

#define _MobCheck_

variable int EncounterMatrix[20,20]
variable int AggroMatrix[100]
variable int TargetID
objectdef mobcheck
{
	; Check if mob is aggro on Raid, group, or pet only, doesn't check agro on Me
	member:bool AggroGroup(int actorid)
	{
		variable int tempvar

		if !${Actor[${actorid}].Target(exists)}
			return FALSE

		if ${Me.GroupCount}>1
		{
			; Check if mob is aggro on group or pet
			tempvar:Set[1]
			do
			{
				if (${Actor[${actorid}].Target.ID}==${Me.Group[${tempvar}].ID} && ${Me.Group[${tempvar}].Name(exists)}) || ${Actor[${actorid}].Target.ID}==${Me.Group[${tempvar}].PetID}
				{
					return TRUE
				}
			}
			while ${tempvar:Inc}<${Me.GroupCount}

			; Check if mob is aggro on raid or pet
			if ${Me.InRaid}
			{
				tempvar:Set[1]
				do
				{
					if (${Actor[${actorid}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].ID} && ${Me.Raid[${tempvar}].Name(exists)}) || ${Actor[${actorid}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].Pet.ID}
					{
						return TRUE
					}
				}
				while ${tempvar:Inc}<24
			}
		}

		if ${Actor[MyPet].Name(exists)} && ${Actor[${actorid}].Target.ID}==${Actor[MyPet].ID}
		{
			return TRUE
		}
		return FALSE
	}

	;returns count of mobs engaged in combat near you.  Includes mobs not engaged to other pcs/groups
	member:int Count()
	{
		variable index:actor Actors
		variable iterator ActorIterator
		variable int mobcount

		EQ2:QueryActors[Actors, (Type =- "NPC" || Type =- "NamedNPC") && Distance <= 15]
		Actors:GetIterator[ActorIterator]

		if ${ActorIterator:First(exists)}
		{
			do
			{	
				if ${This.ValidActor[${ActorIterator.Value.ID}]} && ${ActorIterator.Value.InCombatMode}
				{
					mobcount:Inc
				}
			}
			while ${ActorIterator:Next(exists)}
		}

		return ${mobcount}
	}

	;returns true if you, group, raidmember, or pets have agro from mob in range
	member:bool Detect()
	{
		variable index:actor Actors
		variable iterator ActorIterator

		EQ2:QueryActors[Actors, (Type =- "NPC" || Type =- "NamedNPC") && Distance <= 15]
		Actors:GetIterator[ActorIterator]

		if ${ActorIterator:First(exists)}
		{
			do
			{	
				if ${ActorIterator.Value.InCombatMode}
				{
					if ${ActorIterator.Value.Target.ID}==${Me.ID}
					{
						return TRUE
					}

					if ${This.AggroGroup[${ActorIterator.Value.ID}]}
					{
						return TRUE
					}
				}
			}
			while ${ActorIterator:Next(exists)}
		}

		return FALSE
	}

	member:bool Target(int targetid)
	{
		if !${Actor[${targetid}].InCombatMode}
		{
			return FALSE
		}

		if ${This.AggroGroup[${targetid}]} || ${Actor[${targetid}].Target.ID}==${Me.ID}
		{
			return TRUE
		}

		return FALSE
	}

	method CheckMYAggro()
	{
		variable index:actor Actors
		variable iterator ActorIterator
		haveaggro:Set[FALSE]

		EQ2:QueryActors[Actors, (Type =- "NPC" || Type =- "NamedNPC") && Distance <= 15]
		Actors:GetIterator[ActorIterator]

		if ${ActorIterator:First(exists)}
		{
			do
			{	
				if ${This.ValidActor[${ActorIterator.Value.ID}]} && ${ActorIterator.Value.Target.ID}==${Me.ID} && ${ActorIterator.Value.InCombatMode}
				{
					haveaggro:Set[TRUE]
					aggroid:Set[${ActorIterator.Value.ID}]
					return
				}
			}
			while ${ActorIterator:Next(exists)}
		}
	}

	method ClearAggroMatrix()
	{
		variable int tempvar=0

		while ${tempvar:Inc}<=100
		{
			AggroMatrix[${tempvar}]:Set[0]
		}
	}

	method ClearEncounterMatrix()
	{
		variable int tempvar=0
		variable int tempvar2=0

		while ${tempvar:Inc}<=20
		{
			tempvar2:Set[0]
			while ${tempvar2:Inc}<=20
			{
				EncounterMatrix[${tempvar},${tempvar2}]:Set[0]
			}
		}
	}
}

;Instantiate the object
variable mobcheck MobCheck
