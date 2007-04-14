;EQ2Follow.iss
;use: Run EQ2Follow <character to follow> <distance>
;must put name of Character in and distance defaults to 6
;Thanks to Cr4zyB4rd for the help


#define MOVEFORWARD "num lock"
#define TURNLEFT "a"
#define TURNRIGHT "d"

variable float Rise
variable float Run

 
function main(string ftarget, int leash)
{

	variable float NewPointX
	variable float NewPointZ
	variable float ActorHeading
	variable float RandomXValue =${Math.Rand[6]}
	variable float RandomZValue =${Math.Rand[6]}
	
	turbo 150
	
	if !${leash}
	{
		leash:Set[6]
	}

	while TRUE
	{
		if ${Math.Distance[${Me.X},${Me.Z},${Actor[${ftarget}].X},${Actor[${ftarget}].Z}]}>${Math.Calc[${leash}+1]}
		{
			if !${Me.IsMoving}
			{
				press MOVEFORWARD
				wait 5
		
			}
			
			ActorHeading:Set[${Actor[${ftarget}].Heading}]
			
			if ${ActorHeading} >= 360
			{
				ActorHeading:Set[${Math.Calc[${ActorHeading} - 360]}]
			}
				
			call Angle_Math ${ActorHeading}
				
			NewPointX:Set[${Math.Calc[${Actor[${ftarget}].X} + ${Rise}]}]
			NewPointZ:Set[${Math.Calc[${Actor[${ftarget}].Z} + ${Run}]}]
				
			;face ${NewPointX} ${NewPointZ}
			;wait 3
	
			call Angle_Math ${Math.Rand[360]}

			NewPointX:Set[${Math.Calc[${NewPointX} - ${Rise}]}]
			NewPointZ:Set[${Math.Calc[${NewPointZ} - ${Run}]}]
			face ${NewPointX} ${NewPointZ}
			wait 3
			
		
		}	
		else
		{
			if ${Me.IsMoving}
			{

				wait ${Math.Rand[4]}
				press MOVEFORWARD
				wait 20 !${Me.IsMoving}

			}
	
		}

	
	}
		
}
function Angle_Math(float Angle)
{

	Run:Set[${Math.Calc[${Math.Sin[${Angle}]}*3]}]
	Rise:Set[${Math.Calc[${Math.Cos[${Angle}]}*3]}]
	

}


function atexit()
{
		
	if ${Me.IsMoving}
	{
		press MOVEFORWARD
	}

}