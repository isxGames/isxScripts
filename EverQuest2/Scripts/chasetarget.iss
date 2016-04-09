
; This script will chase the tanks target...
; Note: To end the script u must endscript chasetarget!!!!
; Otherwise ure gonna be chasey chasey all day :)

; By Equidis



;/////////////////////////////////////////
; To use this, you must designate the Tank Name in the command:
;/////////////////////////////////////////

;  run chasetarget "Tanktastic" TRUE

;/////////////////////////////////////////



; TRUE means to return to the tank when the tank's 
; target no longer exists, or if the tank escapes the target

variable string forward=w
variable string backward=s
variable string strafeleft=a
variable string straferight=d

function main(string tankName, bool ReturnToTank) 
{ 
call FastMove ${tankName} ${ReturnToTank}
}

function FastMove(string tankName, bool ReturnToTank)
{


	; INTERACTIVE FOLLOWING SYSTEM WILL AUTO UPDATE THE TARGETS X Y Z AND RANGE
	variable float Z
	variable float X
	variable int range

	variable float xDist
	variable float SaveDist
	variable int xTimer
	variable int toWhoID
		
	range:Set[6]
	
	if ${ReturnToTank}
	{
	toWhoID:Set[${Actor[${tankName}].ID}]	
	}
	else
	{
	toWhoID:Set[${Actor[${tankName}].Target.ID}]	
	}

	X:Set[${Actor[${toWhoID}].X}]
	Z:Set[${Actor[${toWhoID}].Z}]
	SavDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]
	
	face ${X} ${Z}

	press -hold ${forward}

	xTimer:Set[${Time.Timestamp}]
	echo Chasing ${Actor[${toWhoID}].Name}
	do
	{
	if !${Me.IsMoving}
	{
	press -hold ${forward}
	}
	if ${ReturnToTank}
	{
	toWhoID:Set[${Actor[${tankName}].ID}]	
	}
	else
	{
	toWhoID:Set[${Actor[${tankName}].Target.ID}]	
	}

if ${toWhoID} <= 0
{
press -release ${forward}
break
}
	X:Set[${Actor[${toWhoID}].X}]
	Z:Set[${Actor[${toWhoID}].Z}]

		face ${X} ${Z}

		xDist:Set[${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}]


	}
	while ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]} > ${range}

if ${ReturnToTank}
{
eq2execute /follow ${tankName}
}

		press -release ${forward}

}
