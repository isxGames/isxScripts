;
; automentor.iss by primalz
; v0.20090418.02
;
; periodically check and re-mentor target as needed
; usage: RunScript automentor.iss TOON
;
; EDIT by Valerian: Verifies target string on startup, if invalid or blank, will automentor lowest level
;                   group member currently in zone.

variable int scantime=100
variable string LowestMember
variable string Mentored
variable int LowestLevel=0

function main(string mtarget)
{
	variable int GrpCount
	variable bool AutoLowest = FALSE
	if ${mtarget.Length} == 0 || ${mtarget.Equal[NULL]} /* No target specified, go into auto-lowest mode */
	{
		AutoLowest:Set[TRUE]
	}

	Echo [${Time}] automentor: loaded. Target: ${If[${AutoLowest},Lowest Groupmember,${mtarget}]}

	while 2
	{
		if !${AutoLowest}
		{
			if ${Actor[${mtarget}].Name(exists)} && !${Actor[${mtarget}].Name.Equal[${Me}]} && ${Me.EffectiveLevel} > ${Actor[pc,exactname,${mtarget}].Level} && !${Me.InCombat}
			{
				Echo [${Time}] automentor:  mentoring ${mtarget}
				EQ2Execute apply_verb ${Actor[pc,exactname,${mtarget}].ID} mentor
				Mentored:Set[${mtarget}]
			}
			;Echo [${Time}] automentor: sleeping ${Math.Calc64[${scantime}/10]}s
			wait ${scantime}
		}
		else
		{
			if ${LowestLevel} != 0  /* Should only be 0 the first time through */
			{
				;Echo [${Time}] automentor: sleeping ${Math.Calc64[${scantime}/10]}s
				wait ${scantime}
			}
			/* Find lowest group member currently in zone */
			LowestMember:Set[]
			LowestLevel:Set[100] /* For future expansion */
			for (GrpCount:Set[1] ; ${GrpCount} < ${Me.GroupCount} ; GrpCount:Inc)
			{
				if ${Me.Group[${GrpCount}].ZoneName.NotEqual["${Zone.Name}"]}
					continue

				if ${Me.Group[${GrpCount}].Level} < ${LowestLevel}
				{
					LowestMember:Set[${Me.Group[${GrpCount}].Name}]
					LowestLevel:Set[${Me.Group[${GrpCount}].Level}]
				}
			}
			/* LowestMember and LowestLevel have been set at this point. Need to see if we have to
			   un/rementor. */

			if ${LowestMember.Equal[${Me.Name}]} || ${LowestLevel} == ${Me.Level}
				continue

			if ${LowestMember.Equal[${Mentored}]} && ${Me.EffectiveLevel} == ${LowestLevel}
				continue

			/* At this point, we know we need to mentor, or change our mentor. */
			/* First we need to see if we're already mentored, and unmentor if neccessary. */

			if ${Me.EffectiveLevel} != ${Me.Level} /* I'm mentored */
			{
				if ${Actor[pc,exactname,${Mentored}].Name(exists)}
				{
					eq2execute /apply_verb ${Actor[pc,exactname,${Mentored}].ID} stop mentoring
					Echo [${Time}] automentor:  Unmentoring ${Mentored}
				}
				else /* Our current mentored target is unavailable to unmentor (different zone?) */
					continue /* We can't do anything else. at this point. */
			}
			
			/* At this point, we are not mentored. Time to mentor! */

			if ${Actor[pc,exactname,${LowestMember}].Name(exists)} && !${Me.InCombat}
			{
				eq2execute /apply_verb ${Actor[pc,exactname,${LowestMember}].ID} mentor
				Echo [${Time}] automentor:  mentoring ${LowestMember}
				Mentored:Set[${LowestMember}]
			}
		}
		;Echo [${Time}] automentor: sleeping ${Math.Calc64[${scantime}/10]}s
		wait ${scantime}
	}
}

function atexit()
{
	if ${Me.Level} != ${Me.EffectiveLevel} /* We're still mentored. Attempt to unmentor */
	{
		if ${Actor[pc,exactname,${Mentored}].Name(exists)}
		{
			eq2execute /apply_verb ${Actor[pc,exactname,${Mentored}].ID} stop mentoring
			Echo [${Time}] automentor:  Unmentoring ${Mentored}
		}
		/* If our current mentored target is unavailable to unmentor (different zone?) we can't do anything.*/
	}

	Echo [${Time}] automentor: unloaded
}