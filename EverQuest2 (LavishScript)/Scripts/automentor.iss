;
; automentor.iss by primalz
; v0.20090418.02
;
; periodically check and re-mentor target as needed
; usage: RunScript automentor.iss TOON
;

variable int scantime=600

function main(string mtarget)
{
	Echo [${Time}] automentor: loaded
	while 2
	{
		if ${Actor[${mtarget}](exists)} && !${Actor[${mtarget}].Name.Equal[${Me}]} && ${Me.EffectiveLevel} > ${Actor[pc,exactname,${mtarget}].Level} && !${Me.InCombat}
		{
			Echo [${Time}] automentor:  mentoring ${mtarget}
			EQ2Execute apply_verb ${Actor[pc,exactname,${mtarget}].ID} mentor
		}
		;Echo [${Time}] automentor: sleeping ${Math.Calc64[${scantime}/10]}s
		wait ${scantime}
	}
}

function atexit()
{
	Echo [${Time}] automentor: unloaded
}