;EQ2Follow.iss
;by: Ownagejoo
;use: Run EQ2Follow <character to follow> <distance>
;must put name of Character in and distance defaults to 6
;Thanks to Cr4zyB4rd for the help


#define MOVEFORWARD "num lock"
#define QUIT f7
#define DEFAULT_LEASH_DISTANCE 6
#define DEFAULT_NOISE 6
#define LEASH_FUDGE_FACTOR 3
#define MAIN_LOOP_TIMER 2

variable float Rise
variable float Run


function main(string ftarget, int leash=DEFAULT_LEASH_DISTANCE , int noise=DEFAULT_NOISE)
{

	variable float NewPointX
	variable float NewPointZ
	variable float ActorHeading
	variable bool pausestate = FALSE
	variable bool waittomove = FALSE

	squelch bind quit "QUIT" "FollowTask:Set[0]"


        if !${ftarget.Length}

        {
		eq2echo "Syntax: run eq2follow <character name> [distance] [noise]"
                eq2echo "Where <character name> specifies the name of the character to follow,"
                eq2echo "[distance](optional) is the minimum distance to trigger movement,"
                eq2echo "and [noise](optional) is the amount of randomness to add to motion."

        }

	FollowTask:Set[1]

	do
	{
		call TaskStatus

		if ${Math.Distance[${Me.X},${Me.Z},${Actor[${ftarget}].X},${Actor[${ftarget}].Z}]}>${Math.Calc[${leash}+LEASH_FUDGE_FACTOR]}
		{

			call TaskStatus

			ActorHeading:Set[${Actor[${ftarget}].Heading}]

			if ${ActorHeading} >= 360
			{
				ActorHeading:Set[${Math.Calc[${ActorHeading} - 360]}]
			}

			call Angle_Math ${ActorHeading}

			NewPointX:Set[${Math.Calc[${Actor[${ftarget}].X} + ${Rise}]}]
			NewPointZ:Set[${Math.Calc[${Actor[${ftarget}].Z} + ${Run}]}]

			face ${NewPointX} ${NewPointZ}


			call Angle_Math ${Math.Rand[360]}

			NewPointX:Set[${Math.Calc[${NewPointX} - ${Rise}]}]
			NewPointZ:Set[${Math.Calc[${NewPointZ} - ${Run}]}]
			face ${NewPointX} ${NewPointZ}

			FollowTask:Set[3]

			if !${Me.IsMoving}
			{
				press MOVEFORWARD
				wait 5

			}

			wait ${Math.Calc[MAIN_LOOP_TIMER + ${Math.Rand[${noise}]}]}
		}
		else
		{
			if ${Me.IsMoving}
			{

				wait ${Math.Rand[${noise}]}
				press MOVEFORWARD
				wait 20 !${Me.IsMoving}

			}

		}

		FollowTask:Set[1]
		call TaskStatus


		if !${Actor[${ftarget}](exists)}
		{

			if ${Me.IsMoving}
			{
				press MOVEFORWARD
				wait 4
			}

			do
			{
				waitframe
			}
			while !${Actor[${ftarget}].ID} || ${EQ2.Zoning}

			do
			{
				waitframe
			}
			while !${Actor[${ftarget}].ID}


		}



	}
	while ${FollowTask}

}
function Angle_Math(float Angle)
{

	Run:Set[${Math.Calc[${Math.Sin[${Angle}]}*3]}]
	Rise:Set[${Math.Calc[${Math.Cos[${Angle}]}*3]}]


}

function TaskStatus()
{

	if ${FollowTask}==2
	{
		if ${Me.IsMoving}
		{
			press MOVEFORWARD
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
			press MOVEFORWARD
			wait 4
		}
		Script:End
	}
}

function atexit()
{

	if ${Me.IsMoving}
	{
		press MOVEFORWARD
	}

}