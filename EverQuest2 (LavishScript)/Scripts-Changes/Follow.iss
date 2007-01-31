;-----------------------------------------------------------------------------------------------
; Follow.iss Version 1.00  Updated: 05/28/06
;
; Written by: Blazer
;
; Description:
; ------------
; Allows a character to follow someone with a set deviation and leash range
; Syntax: run follow <deviation> <leash>
;-----------------------------------------------------------------------------------------------

;============================================
;===                   Keyboard Configuration                 ====
;============================================
variable string MOVEFORWARD="num lock"
variable string QUIT=f7
;============================================

;============================================
;===                     Variable Declarations                  ====
;============================================
variable FollowObj Follow
variable index:point3f FollowPoints
variable(global) int FollowTask=1
variable int Deviation
variable int CurrentDeviation
variable string FollowTarget
variable float LastMasterX
variable float LastMasterZ
variable int NearestPoint
variable int LastFollowID
variable int checklag
;============================================


function main(string temptarg, int tempdev, int Leash)
{
	variable float MasterX
	variable float MasterZ
	variable int tempvar

	; Set the number of iterations before it determines its stuck
	checklag:Set[1]

	; Check Weight in case we are moving to slow
	if ${Math.Calc[${Me.Weight}/${Me.MaxWeight}*100]}>150
	{
		checklag:Set[3]
	}

	if !${Leash}
	{
		Leash:Set[6]
	}

	if !${tempdev}
	{
		tempdev:Set[3]
	}

	Deviation:Set[${Math.Rand[${Math.Calc[${tempdev}*2+1]}]:Dec[${tempdev}]}]
	CurrentDeviation:Set[${Deviation}]
	FollowTarget:Set[${temptarg}]

	Follow:Initialize

	if ${Math.Distance[${Me.X},${Me.Z},${Actor[${FollowTarget}].X},${Actor[${FollowTarget}].Z}]}<50 && ${Actor[${FollowTarget}](exists)}
	{
		if !${Me.IsMoving} && ${Math.Distance[${Me.X},${Me.Z},${Actor[${FollowTarget}].X},${Actor[${FollowTarget}].Z}]}>8
		{
			press "${MOVEFORWARD}"
			call Follow.FastMove ${Actor[${FollowTarget}].X} ${Actor[${FollowTarget}].Z} ${Leash}
			press "${MOVEFORWARD}"
			wait 4
		}
	}
	else
	{
		if !${FollowTarget.Length}
		{
			EQ2Echo Syntax: run follow [Person to follow] [Deviation] [Leash Range]
			EQ2Echo Example: run follow Blazer 3 5
			EQ2Echo This will follow Blazer with a max deviation left or right of 3, and be within 5 distance.
		}
		else
		{
			EQ2Echo ${FollowTarget} is not in the zone or too far away!
		}
		Script:End
	}

	if ${Me.IsMoving}
	{
		press "${MOVEFORWARD}"
		wait 4
	}

	mastertimer:Set[${Time.Timestamp}]

	do
	{
		while ${Math.Distance[${Me.X},${Me.Z},${Actor[${FollowTarget}].X},${Actor[${FollowTarget}].Z}]}>${Leash}
		{
			MasterX:Set[${Math.Calc[${Deviation}*${Math.Cos[-${Actor[${FollowTarget}].Heading}]}+${Actor[${FollowTarget}].X}]}]
			MasterZ:Set[${Math.Calc[${Deviation}*${Math.Sin[-${Actor[${FollowTarget}].Heading}]}+${Actor[${FollowTarget}].Z}]}]
			face ${MasterX} ${MasterZ}

			if !${Me.IsMoving}
			{
				press "${MOVEFORWARD}"
				wait 4
			}
			
			; Make sure we have Master Targetted
			if ${Target.ID}!=${Actor[${FollowTarget}].ID}
			{
				target ${FollowTarget}
			}

			call TaskStatus
			Follow:SaveMaster

			if !${Me.TargetLOS}
			{
				NearestPoint:Set[${Follow.FindNearestPoint}]
				do
				{
					Follow:SaveMaster
					; Iterate through each point and move to it
					call Follow.FastMove ${FollowPoints.Get[${NearestPoint}].X} ${FollowPoints.Get[${NearestPoint}].Z} 2
					if ${Math.Distance[${Me.X},${Me.Z},${Actor[${FollowTarget}].X},${Actor[${FollowTarget}].Z}]}<=${Leash}
					{
						break
					}
				}
				while ${FollowPoints.Used}>=${NearestPoint:Inc} && !${Me.TargetLOS}
			}
		}

		Deviation:Set[${CurrentDeviation}]
		if ${FollowPoints.Used}>100
		{
			FollowPoints:Clear
			tempvar:Set[0]
			while ${tempvar:Inc}<(${FollowPoints.Used}-100)
			{
				FollowPoints:Remove[${tempvar}]
			}
			FollowPoints:Collapse
		}

		if ${Me.IsMoving}
		{
			press "${MOVEFORWARD}"
			wait 4
		}
	}
	while ${FollowTask}
}

function TaskStatus()
{
	if ${FollowTask}==2
	{
		if ${Me.IsMoving}
		{
			press "${MOVEFORWARD}"
			wait 4
		}

		pausestate:Set[TRUE]

		do
		{
			waitframe
		}
		while ${FollowTask}==2

		pausestate:Set[FALSE]
	}

	if ${FollowTask}==0
	{
		if ${Me.IsMoving}
		{
			press "${MOVEFORWARD}"
			wait 4
		}
		Script:End
	}
}

function atexit()
{
	squelch bind -delete QuitFollow
	FollowTask:Set[0]
	EQ2Echo No longer following ${FollowTarget}!
	if ${Me.IsMoving}
	{
		press "${MOVEFORWARD}"
	}
}

objectdef FollowObj
{
	method Initialize()
	{
		squelch bind QuitFollow ${QUIT} "Script[Follow]:End"
		LastFollowID:Set[${FollowPoints.Insert[${Actor[${FollowTarget}].X},${Actor[${FollowTarget}].Y},${Actor[${FollowTarget}].Z}]}
	}

	method SaveMaster()
	{
		variable float SaveMasterX
		variable float SaveMasterZ

		if !${Actor[${FollowTarget}](exists)}
		{
			;Master is dead or zoned
			return
		}

		SaveMasterX:Set[${Actor[${FollowTarget}].X}]
		SaveMasterZ:Set[${Actor[${FollowTarget}].Z}]

		if ${Math.Distance[${LastMasterX},${LastMasterZ},${SaveMasterX},${SaveMasterZ}]}>2
		{
			LastFollowID:Set[${FollowPoints.Insert[${SaveMasterX},${Actor[${FollowTarget}].Y},${SaveMasterZ}]}]
			LastMasterX:Set[${SaveMasterX}]
			LastMasterZ:Set[${SaveMasterZ}]
		}
	}

	member:int FindNearestPoint()
	{
		variable float shortestdistance=50
		variable float currentdistance
		variable int shortestID
		variable int tempvar

		shortestID:Set[1]
		do
		{
			currentdistance:Set[${Math.Distance[${Me.X},${Me.Z},${FollowPoints.Get[${tempvar}].X},${FollowPoints.Get[${tempvar}].Z}]}]
			if ${currentdistance}<${shortestdistance}
			{
				shortestdistance:Set[${currentdistance}]
				shortestID:Set[${tempvar}]
			}
		}
		while ${FollowPoints.Used}>=${tempvar:Inc}
		return ${shortestID}
	}

	function FastMove(float X, float Z, int range)
	{
		variable float xDist
		variable float SavDist=${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}
		variable int xTimer
		variable float DeviationX
		variable float DeviationZ

		DeviationX:Set[${Math.Calc[${Deviation}*${Math.Cos[-${Me.Heading}]}+${X}]}]
		DeviationZ:Set[${Math.Calc[${Deviation}*${Math.Sin[-${Me.Heading}]}+${Z}]}]

		if !${DeviationX} || !${DeviationZ}
		{
			return
		}

		; Make sure we are moving
		if !${Me.IsMoving}
		{
			press "${MOVEFORWARD}"
		}

		face ${DeviationX} ${DeviationZ}

		xTimer:Set[${Time.Timestamp}]

		do
		{
			call TaskStatus
			This:SaveMaster

			xDist:Set[${Math.Distance[${Me.X},${Me.Z},${DeviationX},${DeviationZ}]}]

			if ${xDist}>50
			{
				; Assume the distance to next point is invalid so might have to do something here.

			}

			if ${Math.Calc[${SavDist}-${xDist}]}<0.2
			{
				if ${Math.Calc[${Time.Timestamp}-${xTimer}]}>${checklag}
				{
					if ${NearestPoint}>3
					{
						NearestPoint:Dec[3]
					}
					Deviation:Set[0]
					return
				}
			}
			else
			{
				xTimer:Set[${Time.Timestamp}]
				SavDist:Set[${Math.Distance[${Me.X},${Me.Z},${DeviationX},${DeviationZ}]}]
			}

			face ${DeviationX} ${DeviationZ}
		}
		while ${Math.Distance[${Me.X},${Me.Z},${DeviationX},${DeviationZ}]}>${range}
	}
}