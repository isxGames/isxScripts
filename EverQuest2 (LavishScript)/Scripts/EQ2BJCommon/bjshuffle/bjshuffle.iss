variable int facedirectionscout
variable int facedirectionmage
variable int facedirectionpriest

variable(global) point3f ShuffleHomePointLocation

function main()
{
	echo "Starting bjshuffle v. 1.00"
;// Get variable numbers

	facedirectionscout:Set[${Math.Rand[1000]:Inc[500]}]
	facedirectionmage:Set[${Math.Rand[500]:Inc[250]}]
	facedirectionpriest:Set[${Math.Rand[250]:Inc[0]}]
	
	ShuffleHomePointLocation:Set[${Me.ToActor.Loc}]
	
;// Start movement
	
	if ${Me.Archetype.Equal[Scout]}
	{
		wait 5
		face ${facedirectionscout}
		eq2press -hold w
		wait 5
		eq2press -release w
		wait 5
	}
	elseif ${Me.Archetype.Equal[Mage]}
	{
		wait 10
		face ${facedirectionmage}
		eq2press -hold w
		wait 10
		eq2press -release w
		wait 4
		face ${facedirectionpriest}
	}
	elseif ${Me.Archetype.Equal[Priest]}
	{
		wait 1
		face ${facedirectionpriest}
		eq2press -hold w
		wait 7
		eq2press -release w
		wait 1
		face ${ShuffleHomePointLocation.X} ${ShuffleHomePointLocation.Z}
	}
}

function atexit()
{
	echo "Ending bjshuffle script..."
}