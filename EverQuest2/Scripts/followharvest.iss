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

	variable int tcount=0
	variable int hcount=0
	do
	{

		if !${Me.InCombat} && !${Me.IsMoving}
		{
			tcount:Set[1]
			EQ2:CreateCustomActorArray[byDist,${MaxRange}]
			;echo scanning actors

			while ${tcount:Inc}<${EQ2.CustomActorArraySize} && ${Actor[pc,${FollowMember}].Distance}<${MaxRange}
			{
				echo nearest actor is ${CustomActor[${tcount}].Name}
				;if the nearest actor is a resource, harvest it
				if ${CustomActor[${tcount}].Type.Equal[resource]}
				{
					if
					{
						echo ${CustomActor[${tcount}].Name} is a pc or pet and nearer than a resource, ending harvest
						continue
					}

					CustomActor[${tcount}]:DoFace
					call moveto ${CustomActor[${tcount}].X} ${CustomActor[${tcount}].Z} 5 0 3 1

					if ${return.equal[stuck]}
					{
						continue
					}

					CustomActor[${tcount}]:DoTarget
					echo found a resource - harvesting ${CustomActor[${tcount}].Name}

					hcount:Set[0]
					do
					{
						if ${Target.ID}==${CustomActor[${tcount}].ID}
						{
							call DoHarvest ${CustomActor[${tcount}].ID}
						}
					}
					while (${CustomActor[${tcount}].ID(exists)} && ${CustomActor[${tcount}].Distance}<6) || ${hcount:Inc}<6

				}
				elseif ${CustomActor[${tcount}].Target.ID}==${Actor[${FollowMember}].ID}
				{
					;echo ${CustomActor[${tcount}].Name} is agro on follower, ignore it.
				}
				elseif ${CustomActor[${tcount}].ID}==${Actor[${FollowMember}].ID} || ${CustomActor[${tcount}].ID}==${Me.ID}
				{
					;echo ${CustomActor[${tcount}].Name} is me or follower
				}
				elseif ${CustomActor[${tcount}].Type.Equal[PC]} || ${CustomActor[${tcount}].Type.Equal[Pet]}
				{
					;echo ${CustomActor[${tcount}].Name} is not a resource ignoring
				}
				else
				{
					;echo nearest actor is not a resource, pc, or pet it is ${CustomActor[${tcount}].Name}
					call ResumeFollow ${FollowMember}
					tcount:Set[${EQ2.CustomActorArraySize}]
				}
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


