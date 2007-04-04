;EQ2Follow.iss
;use: Run EQ2Follow <character to follow> <distance>
;must put name of Character in and distance defaults to 5


#define MOVEFORWARD "num lock"
#define TURNLEFT "a"
#define TURNRIGHT "d"

function main(string temptarg, int leash)
{

	declare NewPointX float script 
	declare NewPointZ float script
	declare RandAngle float script
	declare Run float script
	declare Rise float script
	declare ftarget string script
	declare run int 1
	declare ActorHeading float script
	declare ActorX float script
	declare ActorZ float script
		
	
		if !${leash}
	{
		leash:Set[5]
	}
	
	echo starting
	
	ftarget:Set[${temptarg}]
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
				
				if ${ActorHeading} > 360
				{
					ActorHeading:Set[${Math.Calc[${ActorHeading} - 360]}]
				}
				
				ActorX:Set[${Actor[${ftarget}].X}]
				ActorZ:Set[${Actor[${ftarget}].Z}]
			
				echo actorheading -> ${ActorHeading}
				echo actorx - > ${ActorX}  actorz ->${ActorZ}
				
				Run:Set[${Math.Calc[${Math.Sin[${ActorHeading}]}*3]}]
				Rise:Set[${Math.Calc[${Math.Cos[${ActorHeading}]}*3s]}]
				
				echo Run->${Run} Rise-> ${Rise} 
		
				NewPointX:Set[${Math.Calc[${ActorX} + ${Rise}]}]
				NewPointZ:Set[${Math.Calc[${ActorZ} + ${Run}]}]
		
				echo x ->${NewPointX} z->${NewPointZ}
				
				face ${NewPointX} ${NewPointZ}
				
			}
			else
			{
				break
			}
			
		
		}
		while ${Actor[${ftarget}].IsRunning} || ${Actor[${ftarget}].IsWalking} || ${Actor[${ftarget}].IsSprinting} ||${Actor[${ftarget}].IsBackingUp} || ${Actor[${ftarget}].IsStrafingLeft} || ${Actor[${ftarget}].IsStrafingRight}

		if ${Me.IsMoving}
		{
			press MOVEFORWARD
			wait 20 !${Me.IsMoving}
			
		}
	
	}
	while ${run} < 2
			
}