;***************************************************************
;Followharvest by Pygar
; v 0.1
;
;Purpose:
;This is a harvest script designed to be run on a bot that is on autofollow.  This script will
;scan for nearby nodes (distance set with maxrange var), and if there is nothing agro closer than
;a resource node, it will move to it and harvest it.  It will not harvest while moving.  It onl
;scans when movement stops.  As such, I recommend a very short scanrange.
;
;Note:
;This is totally alpha and needs testing...
;***************************************************************





;includes moveto if its not already included
#ifndef _moveto_
	#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"
#endif

;Set some script wide vars / declares
;Max roam distance for getting a node
variable int Maxrange=15
declare triggerCheckTimer int script 5

function main()
{

	variable int tcount=0
	variable int hcount=0
	do
	{

		if !${Me.InCombat} && !${Me.IsMoving}
		{
			tcount:Set[0]
			EQ2:CreateCustomActorArray[byDist,${MaxRange}]
			echo scanning actors

			while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
			{
				;if the nearest actor is a resource, harvest it
				if ${CustomActor[${tcount}].Type.Equal[resource]} || ${CustomActor[${tcount}].Type.Equal[PC]} || ${CustomActor[${tcount}].Type.Equal[Pet]}
				{
					echo nearest actor is ${CustomActor[${tcount}].Name}

					if ${CustomActor[${tcount}].Type.Equal[PC]} || ${CustomActor[${tcount}].Type.Equal[Pet]}
					{
						echo ${CustomActor[${tcount}].Name} is a pc or pet and nearer than a resource, ending harvest
						continue
					}

					CustomActor[${tcount}]:DoFace
					call moveto ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 5 0 3 1
					CustomActor[${tcount}]:DoTarget
					echo found a resource - harvesting ${CustomActor[${tcount}].Name}

					hcount:Set[0]
					do
					{

						call DoHarvest ${CustomActor[${tcount}].ID}
					}
					while ${CustomActor[${tcount}].ID(exists)} ${hcount}<6

				}
				else
				{
					echo nearest actor is not a resource, pc, or pet it is ${CustomActor[${tcount}].Name}
					if ${Me.ToActor.WhoFollowingID}<1 && ${Me.GroupCount}
					{
						Me.Group[1].ToActor:DoFace
						echo /follow ${Me.Group[1].ToActor.Name}
						EQ2Execute /follow ${Me.Group[1].ToActor.Name}
					}
					tcount:Set[${EQ2.CustomActorArraySize}]
				}
			}
		}
		waitframe
	}
	;THIS MAKES THE FUNCTION  LOOP ENDLESSLY
	while 0 < 1
}


;A generic harvest spam macro, non-bots use this as an easy harvest all hotkey
function DoHarvest(int NodeID)
{
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		EQ2Execute /useability Mining
		EQ2Execute /useability Trapping
		EQ2Execute /useability Gathering
		EQ2Execute /useability Foresting
		EQ2Execute /useability Fishing
	}

	wait 2
	wait 50 !${Me.CastingSpell}

}


