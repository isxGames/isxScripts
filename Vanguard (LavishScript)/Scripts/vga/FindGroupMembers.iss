/*
FindGroupMembers v1.0
by:  mmoAddict and Zandros, 12 NOV 2009

Special thanks to mmoAddict for figuring this out!

Description:
Find the name of group members within your group and put them in a collection variable
And add in the Tank as well.

Usage:
Call this whenever there is a change in your group

Example:
call FindGroupMembers
if ${GroupMemberList.Element[Name](exists)}
echo "Is a group Member"

External Routines that must be in your program: None
*/

;; Toggle this On/Off
variable bool doCheckForMembers=TRUE
variable bool doEcho=TRUE

;; Our collection variable of group members
variable collection:int GroupMemberList

;===================================================
;===         FindGoupMembers Routine            ====
;===================================================
function FindGroupMembers()
{
	;-------------------------------------------
	; Pass our check - Flag is controlled by Events or setting the Tank
	;-------------------------------------------
	if !${doCheckForMembers}
	return

	;-------------------------------------------
	; Clear our collection variable
	;-------------------------------------------
	GroupMemberList:Clear

	;-------------------------------------------
	; Clear VGA gui window
	;-------------------------------------------
	UIElement[GroupMemberList@HealPctCFrm@HealPct@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:ClearItems

	;-------------------------------------------
	; Let's find our group members
	;-------------------------------------------
	if ${doEcho}
	{
		echo "[${Time}][VG:VGA] --> ---------------------------------------"
		echo "[${Time}][VG:VGA] --> FindGroupMembers: Finding Group Members"
	}
	call CheckGroupMember 1
	call CheckGroupMember 2
	call CheckGroupMember 3
	call CheckGroupMember 4
	call CheckGroupMember 5
	call CheckGroupMember 6

	;-------------------------------------------
	; Let's add our tank -- mmo can add this back if needed
	;-------------------------------------------
	;Pawn[name,${tankpawn}]:Target
	;call CheckGroupMember 7

	;-------------------------------------------
	; Let's not repeat this until we are ready to do so
	;-------------------------------------------
	doCheckForMembers:Set[FALSE]

	;-------------------------------------------
	; Let's show how quickly we can populate vga with our found group members
	;-------------------------------------------
	variable int i
	RaidGroupCount:Set[0]
	for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
	{
		if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
		{
			RaidGroupCount:Inc
			RaidGroup[${RaidGroupCount}]:Set[${i}]
			Grplog " ${RaidGroupCount}    (${RaidGroup[1]})   ${Group[${i}].ToPawn.Name}"
		}
	}
	Grplog "***${RaidGroupCount} People In Your Group***"
	echo "[${Time}][VG:VGA] --> ---------------------------------------"

}

;; Find and place group member into the collection variable
function CheckGroupMember(int GN)
{
	variable string PCName

	if ${GN}<7
	{
		VGExecute /cleartargets
		VGExecute "/targetgroupmember ${GN}"
	}
	;; adjust this for a longer wait as needed
	waitframe
	if ${Me.DTarget(exists)}
	{
		if ${doEcho} && ${GN}<7
		echo "[${Time}][VG:VGA] --> FindGroupMembers: Group Member[${GN}]= ${Me.DTarget.Name}"
		if ${doEcho} && ${GN}>=7
		echo "[${Time}][VG:VGA] --> FindGroupMembers: Tank= ${Me.DTarget.Name}"

		GroupMemberList:Set["${Me.DTarget.Name.Token[1," "]}", ${Me.DTarget.ID}]
	}
	if !${Me.DTarget(exists)}
	{
		if ${doEcho} && ${GN}<7
		echo "[${Time}][VG:VGA] --> FindGroupMembers: Group Member[${GN}]= does not exist"
		if ${doEcho} && ${GN}>=7
		echo "[${Time}][VG:VGA] --> FindGroupMembers: Tank [${tankpawn}]= does not exist"
	}
}

;; If there is a change then set flag to TRUE
;; It will not catch when a person moves from one group to another
;; Be sure to toggle this everytime you set a tank
atom(script) OnGroupMemberCountChange()
{
	doCheckForMembers:Set[TRUE]
}



/*
UIElement[GroupMemberList@HealPctCFrm@HealPct@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:ClearItems
if ${Group.Count} < 7
{
Grplog "You are Not In A Raid"
return
}
variable string LastTargetedGrpMember
variable int i
Grplog "Grp#(Raid#) Name"
VGExecute "/targetgroupmember 1"
wait 3
RaidGroupCount:Set[1]
LastTargetedGrpMember:Set[${Me.DTarget.Name}]
for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
{
if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
{
RaidGroup[1]:Set[${i}]
Grplog " 1    (${RaidGroup[1]})   ${Group[${i}].ToPawn.Name}"
}
}

VGExecute "/targetgroupmember 2"
wait 3
if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
{
Grplog "***${RaidGroupCount} In Your Group***"
return
}
RaidGroupCount:Set[2]
LastTargetedGrpMember:Set[${Me.DTarget.Name}]
for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
{
if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
{
RaidGroup[2]:Set[${i}]
Grplog " 2    (${RaidGroup[2]})   ${Group[${i}].ToPawn.Name}"
}
}
VGExecute "/targetgroupmember 3"
wait 3
if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
{
Grplog "***${RaidGroupCount} In Your Group***"
return
}
RaidGroupCount:Set[3]
LastTargetedGrpMember:Set[${Me.DTarget.Name}]
for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
{
if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
{
RaidGroup[3]:Set[${i}]
Grplog " 3    (${RaidGroup[3]})   ${Group[${i}].ToPawn.Name}"
}
}
VGExecute "/targetgroupmember 4"
wait 3
if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
{
Grplog "***${RaidGroupCount} In Your Group***"
return
}
RaidGroupCount:Set[4]
LastTargetedGrpMember:Set[${Me.DTarget.Name}]
for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
{
if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
{
RaidGroup[4]:Set[${i}]
Grplog " 4    (${RaidGroup[4]})   ${Group[${i}].ToPawn.Name}"
}
}
VGExecute "/targetgroupmember 5"
wait 3
if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
{
Grplog "***${RaidGroupCount} In Your Group***"
return
}
RaidGroupCount:Set[5]
LastTargetedGrpMember:Set[${Me.DTarget.Name}]
for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
{
if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
{
RaidGroup[5]:Set[${i}]
Grplog " 5    (${RaidGroup[5]})   ${Group[${i}].ToPawn.Name}"
}
}
VGExecute "/targetgroupmember 6"
wait 3
if ${Me.DTarget.Name.Equal[${LastTargetedGrpMember}]}
{
Grplog "***${RaidGroupCount} In Your Group***"
return
}
RaidGroupCount:Set[6]
LastTargetedGrpMember:Set[${Me.DTarget.Name}]
for (i:Set[1] ; ${i}<=${Group.Count} ; i:Inc)
{
if ${Me.DTarget.Name.Equal[${Group[${i}].ToPawn.Name}]}
{
RaidGroup[6]:Set[${i}]
Grplog " 6    (${RaidGroup[6]})   ${Group[${i}].ToPawn.Name}"
}
}
Grplog "***${RaidGroupCount} People In Your Group***"
*/



