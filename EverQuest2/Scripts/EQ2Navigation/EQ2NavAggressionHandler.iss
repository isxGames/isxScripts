
;-----------------------------------------------------------------------------------------------
; EQ2NavAggressionHandler.iss based on MobCheck.iss Version 1.0.0 by Pygar
;
; Written by: Pygar
; Borrowed Heavily from EQ2Bot
;
; Purpose:  Instantiates an object for checking mobs around you and thier current
;						 action state vs you and your group or raid.
;
; Members:
;			AggroGroup 	- Check if mob is aggro on Raid, group, or pet only, doesn't check agro on Me
;		  Count 		 	- returns count of mobs engaged in combat near you.  Includes mobs engaged to
;								 	 	other pcs/groups
;			Detect			-	returns true if you, group, raidmember, or pets have agro from mob in range
;			Target			-	Returns true if the Actor passed is agro and targeting you,group, or raid
;
; Methods:
;			CheckMYAggro-	(bool) returns true if you, group, pets, or raid have aggro from any mob in range

; Revision History
; ----------------
; v2.1.02

#ifndef _MobCheck_
#define _MobCheck_

;Instantiate the object
variable MobCheck MobCheck
variable int EncounterMatrix[20,20]
variable int AggroMatrix[100]

objectdef MobCheck
{
	; Check if mob is aggro on Raid, group, or pet only, doesn't check agro on Me
	member:bool AggroGroup(int actorid)
	{
		variable int tempvar

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
		variable int tcount=2
		variable int mobcount

		if !${Actor[NPC,range,15].Name(exists)} && !(${Actor[NamedNPC,range,15].Name(exists)} && !${IgnoreNamed})
		{
			return 0
		}

		EQ2:CreateCustomActorArray[byDist,15]
		do
		{
			if ${This.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].InCombatMode}
			{
				mobcount:Inc
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

		return ${mobcount}
	}

	;returns true if you, group, raidmember, or pets have agro from mob in range
	member:bool Detect()
	{
		variable int tcount=2

		if !${Actor[NPC,range,15].Name(exists)} && !(${Actor[NamedNPC,range,15].Name(exists)}
		{
			return FALSE
		}

		EQ2:CreateCustomActorArray[byDist,15]
		do
		{
			if ${CustomActor[${tcount}].InCombatMode}
			{
				if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
				{
					return TRUE
				}

				if ${This.AggroGroup[${CustomActor[${tcount}].ID}]}
				{
					return TRUE
				}
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

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
		variable int tcount=2
		haveaggro:Set[FALSE]

		if !${Actor[NPC,range,15].Name(exists)} && !(${Actor[NamedNPC,range,15].Name(exists)} && !${IgnoreNamed})
		{
			return
		}

		EQ2:CreateCustomActorArray[byDist,15]
		do
		{
			if ${This.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target.ID}==${Me.ID} && ${CustomActor[${tcount}].InCombatMode}
			{
				haveaggro:Set[TRUE]
				aggroid:Set[${CustomActor[${tcount}].ID}]
				return
			}
		}
		while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
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
#endif /* _MobCheck_ */