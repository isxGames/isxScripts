;********************************************
function Psionicist_DownTime()
{

}
;********************************************
function Psionicist_PreCombat()
{

}
;********************************************
function Psionicist_Opener()
{

}
;********************************************
function Psionicist_Combat()
{

	;-------------------------------------------
	; Get our Regen Dots up
	;-------------------------------------------
	if ${Me.EnergyPct}<60 && (!${Me.TargetMyDebuff[Compression Sphere VIII](exists)} || !${Me.TargetMyDebuff[Psychic Schism IV](exists)}) && !${Me.Target.Name.Equal[VAHSREN THE LIBRARIAN]}
	{
		;; Manage 1st Regen Dot
		if !${Me.TargetMyDebuff[Compression Sphere VIII](exists)}
		{
			if !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
			{
				Me.Form["Concentration: Thought Thief"]:ChangeTo
				wait 3
			}

			call checkabilitytocast "Compression Sphere VIII"
			if ${Return}
			{
				call executeability "Compression Sphere VIII" "attack" "Both"
			}
		}

		;; Manage 2nd Regen Dot
		if !${Me.TargetMyDebuff[Psychic Schism IV](exists)}
		{
			if !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
			{
				Me.Form["Concentration: Thought Thief"]:ChangeTo
				wait 3
			}

			call checkabilitytocast "Psychic Schism IV"
			if ${Return}
			{
				call executeability "Psychic Schism IV" "attack" "Both"
			}
		}
		call changeformstance
	}

	;-------------------------------------------
	; Got our Regen Dot up and blast target for fast energy
	; FIX -- What if target is immune to mind altering effects such as VAHSREN THE LIBRARIAN?
	;-------------------------------------------
	if ${Me.EnergyPct}<30 && !${Me.Target.Name.Equal[VAHSREN THE LIBRARIAN]}
	{
		if !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
		{
			Me.Form["Concentration: Thought Thief"]:ChangeTo
			wait 3
		}
		while ${Me.EnergyPct}<80 && ${Me.Target(exists)} && !${Me.Target.IsDead}
		{
			if ${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
			{
				;; Manage 1st Regen Dot
				if !${Me.TargetMyDebuff[Compression Sphere VIII](exists)}
				{
					call checkabilitytocast "Compression Sphere VIII"
					if ${Return}
					{
						call executeability "Compression Sphere VIII" "attack" "Both"
					}
				}

				;; Manage 2nd Regen Dot
				if !${Me.TargetMyDebuff[Psychic Schism IV](exists)}
				{
					call checkabilitytocast "Psychic Schism IV"
					if ${Return}
					{
						call executeability "Psychic Schism IV" "attack" "Both"
					}
				}

				;; Mental Blast for regen
				call executeability "Mental Blast V" "attack" "Both"
				call executeability "Mental Blast I" "attack" "Both"

				;; Wait till ability finish casting
				while ${VG.InGlobalRecovery}>0 || ${Me.IsCasting}
				{
					waitframe
				}
			}
		}
		call changeformstance
	}
}
;********************************************
function Psionicist_Emergency()
{

}
;********************************************
function Psionicist_PostCombat()
{

}
;********************************************
function Psionicist_PostCasting()
{

}
;********************************************
function Psionicist_Burst()
{
	DoBurstNow:Set[FALSE]
}


