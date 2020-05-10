;***************************************************************
;Followharvest by Pygar
; v 0.2
;
;Purpose:
;This is a harvest script designed to be run on a bot that is on autofollow.  This script will
;scan for nearby nodes (distance set with maxrange var), and if there is nothing agro closer than
;a resource node, it will move to it and harvest it.  It will not harvest while moving.  It onl
;scans when movement stops.  As such, I recommend a very short scanrange.
;
;Note:
;This is totally alpha and needs testing...
;
; SYNTAX:
; run followharvest <FollowTarget> <maxroam>
;
; EXAMPLE
; run followharvest Amadeus 10
;
;***************************************************************


;includes moveto if its not already included
#ifndef _moveto_
	#include "${LavishScript.HomeDirectory}/Scripts/moveto.iss"
#endif

;Set some script wide vars / declares
variable int triggerCheckTimer=5

function main(string FollowMember, int MaxRange)
{
	variable index:actor Actors
	variable iterator ActorIterator

	do
	{
		if !${Me.InCombat} && !${Me.IsMoving}
		{
			EQ2:QueryActors[Actors, Distance <= ${MaxRange}]
			Actors:GetIterator[ActorIterator]
			;echo scanning actors

			if ${ActorIterator:First(exists)}
			{
				do
				{	
					echo nearest actor is ${ActorIterator.Value.Name}
					;if the nearest actor is a resource, harvest it
					if ${ActorIterator.Value.Type.Equal[resource]}
					{
						if
						{
							echo ${ActorIterator.Value.Name} is a pc or pet and nearer than a resource, ending harvest
							continue
						}

						ActorIterator.Value:DoFace
						call moveto ${ActorIterator.Value.X} ${ActorIterator.Value.Z} 5 0 3 1

						if ${return.equal[stuck]}
						{
							continue
						}

						ActorIterator.Value:DoTarget
						echo found a resource - harvesting ${ActorIterator.Value.Name}

						hcount:Set[0]
						do
						{
							if ${Target.ID}==${ActorIterator.Value.ID}
							{
								call DoHarvest ${ActorIterator.Value.ID}
							}
						}
						while (${ActorIterator.Value.ID(exists)} && ${ActorIterator.Value.Distance}<6) || ${hcount:Inc}<6

					}
					elseif ${ActorIterator.Value.Target.ID}==${Actor[${FollowMember}].ID}
					{
						;echo ${ActorIterator.Value.Name} is agro on follower, ignore it.
					}
					elseif ${ActorIterator.Value.ID}==${Actor[${FollowMember}].ID} || ${ActorIterator.Value.ID}==${Me.ID}
					{
						;echo ${ActorIterator.Value.Name} is me or follower
					}
					elseif ${ActorIterator.Value.Type.Equal[PC]} || ${ActorIterator.Value.Type.Equal[Pet]}
					{
						;echo ${ActorIterator.Value.Name} is not a resource ignoring
					}
					else
					{
						;echo nearest actor is not a resource, pc, or pet it is ${ActorIterator.Value.Name}
						call ResumeFollow ${FollowMember}
						break
					}
				}
				while ${ActorIterator:Next(exists)} && ${Actor[pc,${FollowMember}].Distance}<${MaxRange}
			}
		}
		waitframe
		call ResumeFollow ${FollowMember}
	}
	;THIS MAKES THE FUNCTION  LOOP ENDLESSLY
	while 0 < 1
}


;A generic harvest spam macro, non-bots use this as an easy harvest all hotkey
function DoHarvest(int NodeID)
{
	if ${Target.Type.Equal[resource]}
	{
		EQ2Execute /useability Mining
		EQ2Execute /useability Trapping
		EQ2Execute /useability Gathering
		EQ2Execute /useability Foresting
		EQ2Execute /useability Fishing
		EQ2Execute /useability Collecting
	}

	wait 2
	wait 50 !${Me.CastingSpell}

}

function ResumeFollow(string fMember)
{
	if ${Me.WhoFollowingID}<1 && ${Me.GroupCount}
	{
		Actor[pc,${fMember}]:DoFace
		echo /follow ${Actor[pc,${fMember}].Name}
		EQ2Execute /follow ${Actor[pc,${fMember}].Name}
	}
}


