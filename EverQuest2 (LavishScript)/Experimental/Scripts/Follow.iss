;EQ2Follow.iss
;use: Run EQ2Follow <character to follow> <distance>
;must put name of Character in and distance defaults to 5


#define MOVEFORWARD "num lock"
#define TURNLEFT "a"
#define TURNRIGHT "d"

function main(string temptarg, int leash)
{
	declare MyPoint point3f script
	declare NewPointX float script
	declare NewPointZ float script
	declare RandAngle float script
	declare Run float script
	declare Rise float script
	declare ftarget string script
	declare FollowTSarget string script
	declare run int 1
	declare ActorHeading float script
	declare ActorX float script
	declare ActorZ float script
	declare grpcnt int script
	declare tempgrp int script
	declare CollisionDistance float script
	declare RandomXValue float script
	declare RandomZValue float script
	declare RandomOffsetValue int script
	declare Angle float script
	declare MobRise float script
	declare MobRun float script
	declare Dist float script
	declare AbsAngle float script
	declare RandStopValue int script
	declare AngDebug bool = True
	declare NewHeading float script
	declare maxRight float script
	declare maxLeft float script
	declare Quadrant int script

  if !${leash}
  {
		leash:Set[5]
  }

	ftarget:Set[${temptarg}]
	FollowTarget:Set[${temptarg}]
	grpcnt:Set[${Me.GroupCount}
	RandomXValue:Set[${Math.Rand[6]}]
	RandomZValue:Set[${Math.Rand[6]}]
	RandomOffsetValue:Set[${Math.Rand[3]}]

	do
	{
		do
		{
			if ${Actor[${ftarget}].IsRunning} || ${Actor[${ftarget}].IsWalking} || ${Actor[${ftarget}].IsSprinting}
			{
				if !${Me.IsMoving}
				{
					press MOVEFORWARD
				}

				ActorHeading:Set[${Actor[${ftarget}].Heading}]

				if ${ActorHeading} >= 360
        {
					ActorHeading:Set[${Math.Calc[${ActorHeading} - 360]}]
				}

				ActorX:Set[${Actor[${ftarget}].X}]
				ActorZ:Set[${Actor[${ftarget}].Z}]

				call Angle_Math ${ActorHeading}

				NewPointX:Set[${Math.Calc[${ActorX} + ${Rise}]}]
				NewPointZ:Set[${Math.Calc[${ActorZ} + ${Run}]}]

				switch ${RandomOffsetValue}
				{
					case 0
						NewPointX:Set[${Math.Calc[${NewPointX} + ${RandomXValue}]}]
						NewPointZ:Set[${Math.Calc[${NewPointZ} + ${RandomZValue}]}]
						face ${NewPointX} ${NewPointZ}
						echo 0 x->${NewPointX} z->${NewPointZ}
						break

					case 1
						face ${NewPointX} ${NewPointZ}
						echo 1 x->${NewPointX} z->${NewPointZ}
						break

					case 2
						NewPointX:Set[${Math.Calc[${NewPointX} - ${RandomXValue}]}]
						NewPointZ:Set[${Math.Calc[${NewPointZ} - ${RandomZValue}]}]
						face ${NewPointX} ${NewPointZ}
						echo 2 x->${NewPointX} z->${NewPointZ}
						break
				}
			}
			else
			{
				wait 5
				break
			}
		}
    while ${Actor[${ftarget}].IsRunning} || ${Actor[${ftarget}].IsWalking} || ${Actor[${ftarget}].IsSprinting}||${Actor[${ftarget}].IsBackingUp} || ${Actor[${ftarget}].IsStrafingLeft} || ${Actor[${ftarget}].IsStrafingRight}||${Math.Distance[${Me.X},${Me.Z},${Actor[${ftarget}].X},${Actor[${ftarget}].Z}]}>${leash}

		if ${Me.IsMoving}
		{
			RandStopValue:Set[${Math.Rand[2]}]
			wait ${RandStopValue}
			press MOVEFORWARD
			wait 20 !${Me.IsMoving}
		}
	}
	while ${run} < 2
  ;while ${FollowTask}
}

 function Angle_Math(float Angle)
{
	Run:Set[${Math.Calc[${Math.Sin[${Angle}]}*3]}]
	Rise:Set[${Math.Calc[${Math.Cos[${Angle}]}*3]}]
}

function atexit()
{
	squelch bind -delete QuitFollow
	FollowTask:Set[0]
	EQ2Echo No longer following ${FollowTarget}!
	if ${Me.IsMoving}
	{
		press MOVEFORWARD
	}
}
