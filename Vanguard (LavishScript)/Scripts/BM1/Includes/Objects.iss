;===================================================
;===      OBJECTDEF - commands we created       ====
;===================================================

variable GET GET

objectdef GET
{
	;-------------------------------------------
	; HealThisID - returns back the Group Number of the person with Lowest health
	;-------------------------------------------
	member:int HealThisID()
	{
		;; set our variables
		variable int GN
		variable int Low = ${HealCheck}
		HealGroupNumber:Set[0]

		if ${Me.IsGrouped}
		{
			if !${doHealGroupOnly}
			{
				for (GN:Set[1] ; ${Group[${GN}].ID(exists)} ; GN:Inc)
				{
					;; Always set this for use later on
					if ${Tank.Find[${Group[${GN}].Name}]}
					{
						TankGN:Set[${GN}]
					}

					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<30
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									HealGroupNumber:Set[${GN}]
								}
							}
						}
					}
				}
				return ${HealGroupNumber}
			}

			if ${doHealGroupOnly}
			{
				for (GN:Set[1] ; ${Group[${GN}].ID(exists)} ; GN:Inc)
				{
					if ${Tank.Find[${Group[${GN}].Name}]}
					{
						;; always set this so we can check the Tanks's health if not in the group
						TankGN:Set[${GN}]

						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
					elseif ${GROUP1.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
					elseif ${GROUP2.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
					elseif ${GROUP3.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
					elseif ${GROUP4.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
					elseif ${GROUP5.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
					elseif ${GROUP6.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; We only want to check we have line of sight to player
								if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
								{
									;; Finally, check only is they are within range
									if ${Group[${GN}].Distance}<30
									{
										;; update Lowest setting
										Low:Set[${Group[${GN}].Health}]
										HealGroupNumber:Set[${GN}]
									}
								}
							}
						}
					}
				}
			}
		}
		;; return the value of HealGroupNumber
		return ${HealGroupNumber}
	}

	;-------------------------------------------
	; LifetapThisID - returns back the Group Number of the person with Lowest health
	;-------------------------------------------
	member:int LifetapThisID()
	{
		;; set our variables
		variable int GN
		variable int Low = ${LifeTapCheck}
		LifeTapGroupNumber:Set[0]
		variable int distance = 1500

		if ${Me.IsGrouped}
		{
			if !${doHealGroupOnly}
			{
				for (GN:Set[1] ; ${Group[${GN}].ID(exists)} ; GN:Inc)
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; we can lifetap from far away and we don't need to be able to see the play
							if ${Group[${GN}].Distance}<=${distance}
							{
								LifeTapGroupNumber:Set[${GN}]
								Low:Set[${Group[${GN}].Health}]
							}
						}
					}
				}
				return ${LifeTapGroupNumber}
			}

			if ${doHealGroupOnly}
			{
				for (GN:Set[1] ; ${Group[${GN}].ID(exists)} ; GN:Inc)
				{
					if ${Tank.Find[${Group[${GN}].Name}]}
					{
						;; always set this so we can check the Tanks's health if not in the group
						TankGN:Set[${GN}]

						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
					elseif ${GROUP1.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
					elseif ${GROUP2.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
					elseif ${GROUP3.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
					elseif ${GROUP4.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
					elseif ${GROUP5.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
					elseif ${GROUP6.Find[${Group[${GN}].Name}]}
					{
						;; We only want to check players with health > 0
						if ${Group[${GN}].Health}>0
						{
							;; We only want to check players beLow Lowest health setting
							if ${Group[${GN}].Health}<${Low}
							{
								;; we can lifetap from far away and we don't need to be able to see the play
								if ${Group[${GN}].Distance}<=${distance}
								{
									LifeTapGroupNumber:Set[${GN}]
									Low:Set[${Group[${GN}].Health}]
								}
							}
						}
					}
				}
			}
		}
		;; return the value of LifeTapGroupNumber
		return ${LifeTapGroupNumber}
	}

	;-------------------------------------------
	; TotalGroupWounded - returns back true or false if we need to heal the whole group
	;-------------------------------------------
	member:int TotalGroupWounded()
	{
		;; set our variables
		variable int GN
		variable int Low = ${LifeTapCheck}
		TotalWounded:Set[0]
		variable int distance = 10

		if ${Me.IsGrouped}
		{
			for (GN:Set[1] ; ${Group[${GN}].ID(exists)} ; GN:Inc)
			{
				if ${GROUP1.Find[${Group[${GN}].Name}]}
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<${distance}
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									TotalWounded:Inc
								}
							}
						}
					}
				}
				elseif ${GROUP2.Find[${Group[${GN}].Name}]}
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<${distance}
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									TotalWounded:Inc
								}
							}
						}
					}
				}
				elseif ${GROUP3.Find[${Group[${GN}].Name}]}
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<${distance}
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									TotalWounded:Inc
								}
							}
						}
					}
				}
				elseif ${GROUP4.Find[${Group[${GN}].Name}]}
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<${distance}
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									TotalWounded:Inc
								}
							}
						}
					}
				}
				elseif ${GROUP5.Find[${Group[${GN}].Name}]}
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<${distance}
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									TotalWounded:Inc
								}
							}
						}
					}
				}
				elseif ${GROUP6.Find[${Group[${GN}].Name}]}
				{
					;; We only want to check players with health > 0
					if ${Group[${GN}].Health}>0
					{
						;; We only want to check players beLow Lowest health setting
						if ${Group[${GN}].Health}<${Low}
						{
							;; We only want to check we have line of sight to player
							if ${Pawn[name,${Group[${GN}].Name}].HaveLineOfSightTo}
							{
								;; Finally, check only is they are within range
								if ${Group[${GN}].Distance}<${distance}
								{
									;; update Lowest setting
									Low:Set[${Group[${GN}].Health}]
									TotalWounded:Inc
								}
							}
						}
					}
				}
			}
		}
		else
		{
			;; we are not in a group
			if ${Me.HealthPct}<=${LifeTapCheck}
			{
				TotalWounded:Inc
			}
		}

		;; return the value of TotalWounded
		return ${TotalWounded}
	}
}


