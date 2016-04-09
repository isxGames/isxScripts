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
	; Let's find our group members
	;-------------------------------------------
	if ${doEcho}
	{
		echo "[${Time}][VG:BM] --> -------------------------------------"
		echo "[${Time}][VG:BM] --> FindGroupMembers: Finding Group Members and Tank"
	}
	call CheckGroupMember 1
	call CheckGroupMember 2
	call CheckGroupMember 3
	call CheckGroupMember 4
	call CheckGroupMember 5
	call CheckGroupMember 6
	
	;-------------------------------------------
	; Let's add our tank
	;-------------------------------------------
	Pawn[name,${Tank}]:Target
	call CheckGroupMember 7
	
	;-------------------------------------------
	; Let's not repeat this until we are ready to do so
	;-------------------------------------------
	doCheckForMembers:Set[FALSE]
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
	waitframe
	if ${Me.DTarget(exists)}
	{
		if ${doEcho} && ${GN}<7
			echo "[${Time}][VG:BM] --> FindGroupMembers: Group Member[${GN}]= ${Me.DTarget.Name}"
		if ${doEcho} && ${GN}>=7
			echo "[${Time}][VG:BM] --> FindGroupMembers: Tank= ${Me.DTarget.Name}"

		GroupMemberList:Set["${Me.DTarget.Name.Token[1," "]}", ${Me.DTarget.ID}]
	}
	if !${Me.DTarget(exists)}
	{
		if ${doEcho} && ${GN}<7
			echo "[${Time}][VG:BM] --> FindGroupMembers: Group Member[${GN}]= does not exist"
		if ${doEcho} && ${GN}>=7
			echo "[${Time}][VG:BM] --> FindGroupMembers: Tank [${Tank}]= does not exist"
	}
}

;; If there is a change then set flag to TRUE
;; It will not catch when a person moves from one group to another
;; Be sure to toggle this everytime you set a tank
atom(script) OnGroupMemberCountChange()
{
	doCheckForMembers:Set[TRUE]
}

