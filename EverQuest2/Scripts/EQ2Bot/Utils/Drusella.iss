#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss"

;; Script is called from within EQ2Bot once Drusella is engaged.
function main()
{
	variable uint KillTarget = ${Script[EQ2Bot].Variable[KillTarget]}
	variable uint WaitCounter = 0
	variable bool Waiting = FALSE
	variable bool DisabledDoppleganger = FALSE

	;; Comment this to disable debug echos throughout
	Debug:Enable

	Debug:Echo["\at<Drusella>\ax Drusella Engaged (KillTarget: ${KillTarget})"]

	if (${Me.SubClass.Equal[illusionist]})
	{
		if (${Script[EQ2Bot].Variable[UseDoppleganger]})
		{
			Script[EQ2Bot].Variable[UseDoppleganger]:Set[FALSE]	
			DisabledDoppleganger:Set[TRUE]
			Debug:Echo["\at<Drusella>\ax - Illusionist 'Doppelganger' ability use disabled for this fight."]
		}
	}

	do
	{
		;; Drusella's Necromantic Aura
		if (${Actor[${KillTarget}].AbilityCastingID.Equal[1580204470]})
		{
			Waiting:Set[TRUE]
			Debug:Echo["\at<Drusella>\ax - Drusella is casting her Necromantic Aura; ending all combat actions..."]
			EQ2Execute /cancel_spellcast
			wait 2
			EQ2Execute /cancel_spellcast
			wait 2
			EQ2Execute /clearabilityqueue
			wait 2
			EQ2Execute /clearabilityqueue
			wait 2
			EQ2Execute /pet backoff
			wait 2
			EQ2Execute /pet backoff
			wait 1
			EQ2Execute /autoattack 0
			wait 5
			EQ2Execute /setauto 3
			do
			{
				wait 5
				Debug:Echo["\at<Drusella>\ax --- Waiting...[${WaitCounter:Inc[5]}]"]
				EQ2Execute /autoattack 0
			}
			while (${Actor[${KillTarget}].AbilityCastingID.Equal[1580204470]})
			wait 20
			Waiting:Set[FALSE]
		}

		;;;;
		;; Drusella's Necromantic Aura has MainIconID of 259 and BackDropIconID of 33085
		;; Lich has a MainIconID of 240 and BackDropIconID of 33085
		;; **She always has one of these two abilities as Effect[1]**
		if (${Actor[${KillTarget}].Effect[1].MainIconID.Equal[259]})
		{
			Waiting:Set[TRUE]
			WaitCounter:Set[0]
			do
			{
				call CheckHeals ${KillTarget}
				wait 5
				Debug:Echo["\at<Drusella>\ax ---- Waiting for Drusella's Necromantic Aura to end [${WaitCounter:Inc[5]}]..."]
				EQ2Execute /autoattack 0
			}
			while (${Actor[${KillTarget}].Effect[1].MainIconID.Equal[259]})
			Waiting:Set[FALSE]
		}

		KillTarget:Set[${Script[EQ2Bot].Variable[KillTarget]}]
		waitframe
	}
	while (${Script[EQ2Bot](exists)} && ${Actor[${KillTarget}].Name.Equal[Drusella Sathir]} && !${Actor[${KillTarget}].IsDead} && ${Zone.RoomID.Equal[822072897]})

	wait 10
	EQ2Execute /setauto 0

	if (${DisabledDoppleganger})
	{
		Script[EQ2Bot].Variable[UseDoppleganger]:Set[TRUE]
		Debug:Echo["\at<Drusella>\ax - Illusionist 'Doppelganger' re-enabled."]
	}	

	Debug:Echo["\at<Drusella>\ax Drusella defeated."]
}

function CheckHeals(uint KillTarget)
{
	variable uint WaitCounter

	;; TODO: Add routines for all classes as desired.
	switch (${Me.SubClass})
	{
		Debug:Echo["\at<Drusella>\ax \aoTEMP: ${Me.SubClass}\ax"]

		case fury
		{
			Debug:Echo["\at<Drusella>\ax \ao...FURY...\ax"]
			;; Group heals should be enough to keep tank up during Necromatic Aura
			if (${Me.Ability[Feral Pulse].IsReady})
			{
				EQ2Execute /useability Feral Pulse
				wait 5
			}
			if (!${Actor[${KillTarget}].Effect[1].MainIconID.Equal[259]})
				return
			if (${Me.Ability[Autumn's kiss].IsReady})
			{
				EQ2Execute /useability Autumn's Kiss
				wait 5
				WaitCounter:Set[0]
				do
				{
					wait 1
				}
				while (${Me.CastingSpell} && ${WaitCounter:Inc[1]} < 25)
			}
			if (!${Actor[${KillTarget}].Effect[1].MainIconID.Equal[259]})
				return
			if (${Me.Ability[Untamed Regeneration].IsReady})
			{
				EQ2Execute /useability Untamed Regeneration
				wait 5
				WaitCounter:Set[0]
				do
				{
					waitframe
				}
				while (${Me.CastingSpell} && ${WaitCounter:Inc[1]} < 15)
			}
		}
		default
			return
	}

	return
}