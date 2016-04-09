;===================================================
;===       NON-COMBAT HEAL SUB-ROUTINE          ====
;===================================================
function VitalHeals()
{
	if ${doVitalHeals}
	{
		if ${Me.Effect[Muting Darkness](exists)}
		{
			return
		}
		if ${Me.IsGrouped}
		{
			;-------------------------------------------
			; GROUP HEALS
			;-------------------------------------------
			if ${Me.Ability[${RecoveringBurst}](exists)} && ${Me.Ability[${RecoveringBurst}].TimeRemaining}==0
			{
				if ${TotalWounded}
				{
					if ${doArcane}
					{
						EchoIt "Blood Tribute (Heal): Reamining=${Me.Ability[${BloodTribute}].TimeRemaining}, CountDown=${Me.Ability[${BloodTribute}].TriggeredCountdown}, Ready=${Me.Ability[${BloodTribute}].IsReady}"
						;-------------------------------------------
						; USE OUR AE CRIT HEAL IF IT IS UP
						;-------------------------------------------
						while ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0
						{
							;; crit that heals group members near me
							if ${Me.Ability[${BloodTribute}].TimeRemaining}==0
							{
								;; change to DPS form
								if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
								{
									Me.Form["Focus of Gelenia"]:ChangeTo
									wait .5
								}
								;; Use our crit heal
								call UseAbility "${BloodTribute}"
								if ${Return}
								{
									wait 5
									return
								}
							}
						}
					}
				}

				;; scan the group, 3 or more wounded
				if ${TotalWounded}>=3
				{
					;-------------------------------------------
					; USE BIGGEST GROUP HEAL IF WE GOT IT
					;-------------------------------------------
					if ${Me.Ability[${SuperiorRecoveringBurst}](exists)}
					{
						if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
						{
							Me.Form["Sanguine Focus"]:ChangeTo
							wait .5
						}
						wait 5 ${Me.Ability[${SuperiorRecoveringBurst}].IsReady}
						call UseAbility "${SuperiorRecoveringBurst}"
						if ${Return}
						{
							wait 10
							return
						}
					}
					;-------------------------------------------
					; USE GROUP HEAL IF WE GOT IT
					;-------------------------------------------
					if ${Me.Ability[${RecoveringBurst}](exists)}
					{
						if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
						{
							Me.Form["Sanguine Focus"]:ChangeTo
							wait .5
						}
						wait 5 ${Me.Ability[${RecoveringBurst}].IsReady}
						call UseAbility "${RecoveringBurst}"
						if ${Return}
						{
							wait 10
							return
						}
					}
				}
			}

			;-------------------------------------------
			; VITAL HEALS
			;-------------------------------------------

			;; save who needs healing
			variable int TempNumber = ${GET.HealThisID}

			;-------------------------------------------
			; SET DTARGET TO PLAYER WITH LOWEST HEALTH
			;-------------------------------------------
			if ${Group[${TempNumber}].Health}<${HealCheck} && ${TempNumber}>0
			{
				EchoIt "Healing [${TempNumber}] ${Group[${TempNumber}].Name}, Health = ${Group[${TempNumber}].Health}"

				;; set DTarget to member with lowest health
				if ${Group[${TempNumber}].ID}!=${Me.DTarget.ID}
				{
					Pawn[id,${Group[${TempNumber}].ID}]:Target
					wait 5 ${Group[${TempNumber}].ID}==${Me.DTarget.ID}
				}

				;-------------------------------------------
				; Are we healing our self?
				;-------------------------------------------
				if ${Me.FName.Equal[${Me.DTarget.Name}]}
				{
					; use Conduct if it is up
					if ${Me.Ability[${Conduct}](exists)} && ${Me.Ability[${Conduct}].TimeRemaining}==0
					{
						if ${Me.Ability[${Conduct}].IsReady}
						{
							EchoIt "Using ${Conduct} to heal self"
							call UseAbility "${Conduct}"
							if ${Return}
							{
								; attempt to get a HOT up
								if ${Me.Ability[${TransfusionOfSerak}].TimeRemaining}==0
								{
									EchoIt "Using HOT to heal self"
									if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
									{
										Me.Form["Sanguine Focus"]:ChangeTo
										wait .5
									}
									wait 5 ${Me.Ability[${TransfusionOfSerak}].IsReady}
									call UseAbility "${TransfusionOfSerak}"
								}
								return
							}
						}
					}
					; 1.5 second small heal... this is for me
					if ${Me.Ability[${InfuseHealth}].TimeRemaining}==0
					{
						if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
						{
							Me.Form["Sanguine Focus"]:ChangeTo
							wait .5
						}
						wait 5 ${Me.Ability[${InfuseHealth}].IsReady}
						call UseAbility "${InfuseHealth}"
						if ${Return}
						{
							; attempt to get a HOT up
							if ${Me.Ability[${TransfusionOfSerak}].TimeRemaining}==0
							{
								EchoIt "Using HOT to heal self"
								if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
								{
									Me.Form["Sanguine Focus"]:ChangeTo
									wait .5
								}
								wait 5 ${Me.Ability[${TransfusionOfSerak}].IsReady}
								call UseAbility "${TransfusionOfSerak}"
							}
							return
						}
					}
					; use berries as a backup plan, must be on your HOTBAR
					if ${Me.Inventory[Great Roseberries](exists)}
					{
						wait 10 ${Me.Inventory[Great Roseberries].IsReady}
						if ${Me.Inventory[Great Roseberries].IsReady}
						{
							EchoIt "Consumed Great Roseberries to gain health"
							Me.Inventory[Great Roseberries]:Use
							call GlobalRecovery
							return
						}
					}
					return
				}

				;-------------------------------------------
				;; Are we healing someone other than myself?
				;-------------------------------------------
				if !${Me.FName.Equal[${Me.DTarget.Name}]}
				{
					; 3 second big heal... do squishies really need it?
					if ${Me.Ability[${BloodGift}].TimeRemaining}==0
					{
						if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
						{
							Me.Form["Sanguine Focus"]:ChangeTo
							wait .5
						}
						wait 5 ${Me.Ability[${BloodGift}].IsReady}
						call UseAbility "${BloodGift}"
						if ${Return}
						{
							; attempt to get a HOT up
							if ${Me.Ability[${TransfusionOfSerak}].TimeRemaining}==0
							{
								EchoIt "Using HOT to heal ${Me.DTarget.Name}"
								if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
								{
									Me.Form["Sanguine Focus"]:ChangeTo
									wait .5
								}
								wait 5 ${Me.Ability[${TransfusionOfSerak}].IsReady}
								call UseAbility "${TransfusionOfSerak}"
							}
							return
						}
					}
					return
				}
			}
			return
		}
		else
		{
			;-------------------------------------------
			; NOT IN GROUP, Recheck our health, is it low?
			;-------------------------------------------
			if ${Me.HealthPct}<${HealCheck}
			{
				;; Target myself
				if !${Me.FName.Equal[${Me.DTarget.Name}]}
				{
					Pawn[Me]:Target
					wait 5
				}

				;; Are we healing our self?
				if ${Me.FName.Equal[${Me.DTarget.Name}]}
				{
					; use Conduct if it is up
					if ${Me.Ability[${Conduct}](exists)} && ${Me.Ability[${Conduct}].TimeRemaining}==0
					{
						if ${Me.Ability[${Conduct}].IsReady}
						{
							EchoIt "Using ${Conduct} to heal self"
							call UseAbility "${Conduct}"
							if ${Return}
							{
								; attempt to get a HOT up
								if ${Me.Ability[${TransfusionOfSerak}].TimeRemaining}==0
								{
									EchoIt "Using HOT to heal self at ${Me.HealthPct}"
									if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
									{
										Me.Form["Sanguine Focus"]:ChangeTo
										wait .5
									}
									wait 5 ${Me.Ability[${TransfusionOfSerak}].IsReady}
									call UseAbility "${TransfusionOfSerak}"
								}
								return
							}
						}
					}
					; 1.5 second small heal... this is for me
					if ${Me.Ability[${InfuseHealth}].TimeRemaining}==0
					{
						if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
						{
							Me.Form["Sanguine Focus"]:ChangeTo
							wait .5
						}
						EchoIt "Casting Fast heal on self at ${Me.HealthPct}"
						wait 5 ${Me.Ability[${InfuseHealth}].IsReady}
						call UseAbility "${InfuseHealth}"
						if ${Return}
						{
							; attempt to get a HOT up
							if ${Me.Ability[${TransfusionOfSerak}].TimeRemaining}==0
							{
								EchoIt "Using HOT to heal self at ${Me.HealthPct}"
								if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]}
								{
									Me.Form["Sanguine Focus"]:ChangeTo
									wait .5
								}
								wait 5 ${Me.Ability[${TransfusionOfSerak}].IsReady}
								call UseAbility "${TransfusionOfSerak}"
							}
							return
						}
					}
					; use berries as a backup plan
					if ${Me.Inventory[Great Roseberries](exists)}
					{
						wait 10 ${Me.Inventory[Great Roseberries].IsReady}
						if ${Me.Inventory[Great Roseberries].IsReady}
						{
							EchoIt "Consumed Great Roseberries to gain health"
							wait 1
							Me.Inventory[Great Roseberries]:Use
							call GlobalRecovery
						}
					}
				}
			}
		}
	}
}


