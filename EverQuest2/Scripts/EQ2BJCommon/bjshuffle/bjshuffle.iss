variable int facedirectionscout
variable int facedirectionscoutpredator
variable int facedirectionscoutrogue
variable int facedirectionscoutbard
variable int facedirectionscoutanimalist
variable int facedirectionmage
variable int facedirectionmagesorceror
variable int facedirectionmageenchanter
variable int facedirectionmagesummoner
variable int facedirectionpriest
variable int facedirectionpriestdruid
variable int facedirectionpriestshaman
variable int facedirectionpriestcleric

variable float InitialHeading
variable point3f InitialLocation
variable int MaxDistance=4

function main()
{
	echo "Starting bjshuffle v. 1.01"
;// Get variable numbers

	facedirectionscout:Set[${Math.Rand[65]:Inc[45]}]
	facedirectionmage:Set[${Math.Rand[155]:Inc[45]}]
	facedirectionpriest:Set[${Math.Rand[290]:Inc[45]}]
	
	InitialHeading:Set[${Me.Heading}]
	InitialLocation:Set[${Me.Loc}]
	
;// Start movement
	
	if ${Me.Archetype.Equal[Scout]}
	{
		if ${Me.Class.Equal[rogue]}
		{
			facedirectionscoutrogue:Set[${Math.Calc[${facedirectionscout}+10]}]
			face ${facedirectionscoutrogue}
		}
		if ${Me.Class.Equal[predator]}
		{
			facedirectionscoutpredator:Set[${Math.Calc[${facedirectionscout}+20]}]
			face ${facedirectionscoutpredator}
		}
		if ${Me.Class.Equal[bard]}
		{
			facedirectionscoutbard:Set[${Math.Calc[${facedirectionscout}-20]}]
			face ${facedirectionscoutbard}
		}
		if ${Me.Class.Equal[animalist]}
		{
			facedirectionscoutanimalist:Set[${Math.Calc[${facedirectionscout}-10]}]
			face ${facedirectionscoutanimalist}
		}
		eq2press -hold w
		wait 4
		eq2press -release w
		wait 5
		if ${Math.Distance[${Me.Loc},${InitialLocation}]} > ${MaxDistance}
		{
			while ${Math.Distance[${Me.Loc},${InitialLocation}]} > ${MaxDistance}
			{
				face ${InitialLocation.X} ${InitialLocation.Z}
				eq2press -hold w
			}
			eq2press -release w
		}
		face ${InitialHeading}
		if ${Me.Class.Equal[bard]}
		{
			face ${InitialLocation.X} ${InitialLocation.Z}
		}
	}
	elseif ${Me.Archetype.Equal[Mage]}
	{
		if ${Me.Class.Equal[sorceror]} || ${Me.Class.Equal[summoner]}
		{
			if ${Me.Class.Equal[sorceror]}
			{
				facedirectionscoutrogue:Set[${Math.Calc[${facedirectionmage}+10]}]
				face ${facedirectionmagesorceror}
			}
			
			if ${Me.Class.Equal[summoner]}
			{
				facedirectionscoutbard:Set[${Math.Calc[${facedirectionmage}-20]}]
				face ${facedirectionmagesummoner}
			}
			eq2press -hold w
			wait 5
			eq2press -release w
			wait 5
		}
		else
		{
			if ${Me.Class.Equal[enchanter]}
			{
				facedirectionscoutpredator:Set[${Math.Calc[${facedirectionmage}+20]}]
				face ${facedirectionmageenchanter}
			}
			eq2press -hold w
			wait 2
			eq2press -release w
			wait 5
		}
		if ${Math.Distance[${Me.Loc},${InitialLocation}]} > ${MaxDistance}
		{
			while ${Math.Distance[${Me.Loc},${InitialLocation}]} > ${MaxDistance}
			{
				face ${InitialLocation.X} ${InitialLocation.Z}
				eq2press -hold w
			}
			eq2press -release w
		}
		face ${InitialHeading}
	}
	elseif ${Me.Archetype.Equal[Priest]}
	{
		if ${Me.Class.Equal[druid]}
		{
			facedirectionpriestdruid:Set[${Math.Calc[${facedirectionpriest}+10]}]
			face ${facedirectionpriestdruid}
		}
		if ${Me.Class.Equal[shaman]}
		{
			facedirectionpriestshaman:Set[${Math.Calc[${facedirectionpriest}+20]}]
			face ${facedirectionpriestshaman}
		}
		if ${Me.Class.Equal[cleric]}
		{
			facedirectionpriestcleric:Set[${Math.Calc[${facedirectionpriest}-20]}]
			face ${facedirectionpriestcleric}
		}
		eq2press -hold w
		wait 3
		eq2press -release w
		wait 5
		if ${Me.Class.Equal[druid]}
		{
			facedirectionpriestdruid:Set[${Math.Calc[${facedirectionpriest}+30]}]
			face ${facedirectionpriestdruid}
		}
		if ${Me.Class.Equal[shaman]}
		{
			facedirectionpriestshaman:Set[${Math.Calc[${facedirectionpriest}+40]}]
			face ${facedirectionpriestshaman}
		}
		if ${Me.Class.Equal[cleric]}
		{
			facedirectionpriestcleric:Set[${Math.Calc[${facedirectionpriest}]}]
			face ${facedirectionpriestcleric}
		}
		eq2press -hold w
		wait 3
		eq2press -release w
		wait 5
		if ${Math.Distance[${Me.Loc},${InitialLocation}]} > ${MaxDistance}
		{
			while ${Math.Distance[${Me.Loc},${InitialLocation}]} > ${MaxDistance}
			{
				face ${InitialLocation.X} ${InitialLocation.Z}
				eq2press -hold w
			}
			eq2press -release w
		}
		face ${InitialHeading}
	}
}

function atexit()
{
	echo "Ending bjshuffle script..."
}