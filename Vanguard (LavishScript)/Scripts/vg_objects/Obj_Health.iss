;======================
/** Health

	Description:  Adds new variables that will assist you with determining who has lowest health

	Usage
	____________________________________

	**  Place the following line at the top of your .iss file
		#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Health.iss"

		Health.GroupNumber			Group Member number with lowest health
		Health.GroupName			Group Member name with lowest health
		Health.GroupHealth			Lowest health of the Group Member
		Health.TotalGroupWounded	Total wounded Group Members below 70% health

		Health.RaidNumber			Group Member in Raid with lowest health
		Health.RaidName				Group Member name in Raid with lowest health
		Health.RaidHealth			Lowest health of the Group Member in Raid
		Health.TotalRaidWounded		Total wounded Group Members in Raid below 70% health

	**  The following example will report true if the first name of player is in your group

		if ${Health.GroupMemberList.Element["Zandros"](exists)}
		return TRUE

	Notes
	____________________________________
	**  You dont need to know how an object works to use it.
	**  Objects are bits of code that perform specific functions.
	**  This function specifically creates new variables for you

	Credits
	____________________________________
	**  Created by Zandros
	**  Special Thanks to Amadeus and Lax for all their work

**/
;======================

variable(global) obj_Health Health

objectdef obj_Health
{
	;===================================================
	;===       User Variables                       ====
	;===================================================
	variable int GroupNumber
	variable string GroupName
	variable int GroupHealth
	variable int TotalGroupWounded

	variable int RaidNumber
	variable string RaidName
	variable int RaidHealth
	variable int TotalRaidWounded


	variable collection:int GroupMemberList


	;; System controlled variables
	variable int NextCalled = ${Script.RunningTime}
	variable int GroupMemberCount
	variable int CounterDelay

	;===================================================
	;===             User Routines                  ====
	;===================================================

	;; NONE


	;===================================================
	;===          DO NOT USE THESE ROUTINES         ====
	;===================================================
	method Initialize()
	{
		This.NextCalled:Set[0]
		This.CounterDelay:Set[0]
		This.GroupMemberCount:Set[0]
		Event[OnFrame]:AttachAtom[This:FindLowestHealth]
		Event[VG_onGroupMemberCountChange]:AttachAtom[This:ResetGroupCount]
		Event[VG_onGroupMemberBooted]:AttachAtom[This:ResetGroupCount]
		Event[VG_onGroupMemberAdded]:AttachAtom[This:ResetGroupCount]
		Event[VG_onGroupJoined]:AttachAtom[This:ResetGroupCount]
		Event[VG_onGroupFormed]:AttachAtom[This:ResetGroupCount]
		Event[VG_onGroupDisbanded]:AttachAtom[This:ResetGroupCount]
		Event[VG_onGroupBooted]:AttachAtom[This:ResetGroupCount]
		echo "[${Time}] Obj_Health Initialized"
	}

	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:FindLowestHealth]
		Event[VG_onGroupMemberCountChange]:DetachAtom[This:ResetGroupCount]
		Event[VG_onGroupMemberBooted]:DetachAtom[This:ResetGroupCount]
		Event[VG_onGroupMemberAdded]:DetachAtom[This:ResetGroupCount]
		Event[VG_onGroupJoined]:DetachAtom[This:ResetGroupCount]
		Event[VG_onGroupFormed]:DetachAtom[This:ResetGroupCount]
		Event[VG_onGroupDisbanded]:DetachAtom[This:ResetGroupCount]
		Event[VG_onGroupBooted]:DetachAtom[This:ResetGroupCount]
		echo "[${Time}] Obj_Health Shutdown"
	}

	method Reset()
	{
		This.GroupNumber:Set[0]
		This.GroupName:Set[]
		This.GroupHealth:Set[0]
		This.TotalGroupWounded:Set[0]

		This.RaidNumber:Set[0]
		This.RaidName:Set[]
		This.RaidHealth:Set[0]
		This.TotalRaidWounded:Set[0]

		This.NextCalled:Set[${Script.RunningTime}]
	}

	;-------------------------------------------
	; Find lowest member's health
	;-------------------------------------------
	method FindLowestHealth()
	{
		;; Go find a group member
		if ${This.GroupMemberCount}<7
		{
			This:FindGroupMembers
			return
		}

		;; Update once per half a second
		if (${Math.Calc[${Math.Calc[${Script.RunningTime}-${This.NextCalled}]}/1000]} < .5)
		{
			return
		}

		;; Reset our variables
		This:Reset

		;; NOT IN GROUP
		if !${Me.IsGrouped}
		{
			This.GroupHealth:Set[${Me.HealthPct}]
			This.GroupName:Set[${Me.FName}]

			if ${Me.HealthPct}<70
			{
				This.TotalGroupWounded:Inc
			}
			return
		}

		;; Setup our temp variables
		variable int i = 0
		variable int low = 90

		;; GROUP MEMBERS
		for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
		{
			if ${This.GroupMemberList.Element["${Group[${i}].Name}"](exists)}
			{
				if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
				{
					if ${Group[${i}].Distance}<=30 && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
					{
						This.GroupNumber:Set[${i}]
						This.GroupName:Set[${Group[${i}].Name}]
						This.GroupHealth:Set[${Group[${i}].Health}]
						if ${Group[${i}].Health}<70
						{
							This.TotalGroupWounded:Inc
						}
					}
				}
			}
		}

		;; Return if not enough members for a raid... hopefully, Amadeus will write a command to do this
		if ${Group.Count}<7
		{
			return
		}

		;; RAID MEMBERS
		low:Set[90]
		for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
		{
			if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
			{
				if ${Group[${i}].Distance}<=30 && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
				{
					This.RaidNumber:Set[${i}]
					This.RaidName:Set[${Group[${i}].Name}]
					This.RaidHealth:Set[${Group[${i}].Health}]
					if ${Group[${i}].Health}<70
					{
						This.TotalRaidWounded:Inc
					}
				}
			}
		}
	}

	;-------------------------------------------
	; Calling this will start the FindGroupMembers routine
	;-------------------------------------------
	method ResetGroupCount()
	{
		This.GroupMemberCount:Set[0]
		This.CounterDelay:Set[0]
	}

	;-------------------------------------------
	; Find group members and store them in our collection variable
	;-------------------------------------------
	method FindGroupMembers()
	{
		;-------------------------------------------
		; Initialize everything
		;-------------------------------------------
		if ${This.GroupMemberCount} == 0
		{
			This.GroupMemberList:Clear

			This.GroupMemberCount:Inc
			VGExecute /cleartargets
			VGExecute "/targetgroupmember ${This.GroupMemberCount}"

			echo "[${Time}][VG:ObjHealth] --> -------------------------------------"
			echo "[${Time}][VG:ObjHealth] --> FindGroupMembers: Finding Group Members"

			return
		}

		;-------------------------------------------
		; Return if we are done finding groupmembers
		;-------------------------------------------
		if ${This.GroupMemberCount} > 6
		{
			return
		}

		;-------------------------------------------
		; Increase this if your computer is VERY FAST!
		;-------------------------------------------
		if ${This.CounterDelay} < 1
		{
			This.CounterDelay:Inc
			return
		}
		This.CounterDelay:Set[0]


		;-------------------------------------------
		; We found a Group Member "hmmm, I bet you are wondering how"
		;-------------------------------------------
		if ${Me.DTarget(exists)}
		{
			This.GroupMemberList:Set["${Me.DTarget.Name.Token[1," "]}", ${Me.DTarget.ID}]
			echo "[${Time}][VG:ObjHealth] --> FindGroupMembers: Group Member[${This.GroupMemberCount}]= ${Me.DTarget.Name}"
			VGExecute /cleartargets
		}
		else
		{
			echo "[${Time}][VG:ObjHealth] --> FindGroupMembers: Group Member[${This.GroupMemberCount}]= does not exist"
		}

		;-------------------------------------------
		; target groupmember
		;-------------------------------------------
		This.GroupMemberCount:Inc
		VGExecute "/targetgroupmember ${This.GroupMemberCount}"
	}
}


