;===================================================
;===       DO NOT ATTACK SUB-ROUTINE            ====
;===================================================
function DoNotAttack()
{
	call MeleeAttackOff
	variable int i = ${HealCheck}
	HealCheck:Set[90]
	call VitalHeals
	HealCheck:Set[${i}]
}

;===================================================
;===       MELEE ATTACKS OFF SUB-ROUTINE        ====
;===================================================
function MeleeAttackOff()
{
	if ${GV[bool,bIsAutoAttacking]} || ${Me.Ability[Auto Attack].Toggled}
	{
		;; Turn off auto-attack if target is not a resource
		if !${Me.Target.Type.Equal[Resource]}
		{
			Me.Ability[Auto Attack]:Use
			wait 10 !${GV[bool,bIsAutoAttacking]} && !${Me.Ability[Auto Attack].Toggled}
		}
	}
}

;===================================================
;===       MELEE ATTACKS ON SUB-ROUTINE        ====
;===================================================
function MeleeAttackOn()
{
	;; Make sure target is within range
	if ${doMeleeAttacks}
	{
		if ${Me.InCombat} && ${Me.Target(exists)} && ${Me.Target.Distance}<5 && !${Me.Target.IsDead} && (${Me.Target.Type.Find[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}) && ${Me.TargetHealth}<=${StartAttack}
		{
			if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${isFurious}
			{
				call MeleeAttackOff
				if !${Me.TargetBuff[Furious](exists)}
				{
					isFurious:Set[FALSE]
				}
			}
			elseif ${Me.Effect[Devout Foeman I](exists)} || ${Me.Effect[Devout Foeman II](exists)} || ${Me.Effect[Devout Foeman III](exists)}
			{
				call MeleeAttackOff
			}
			elseif ${Me.TargetBuff[Rust Shield](exists)} || ${Me.Effect[Mark of Verbs](exists)} || ${Me.TargetBuff[Charge Imminent](exists)}
			{
				call MeleeAttackOff
			}
			elseif ${Me.TargetBuff[Major Disease: Fire Advocate](exists)}
			{
				call MeleeAttackOff
			}
			else
			{
				;; Turn on auto-attack
				if !${GV[bool,bIsAutoAttacking]} || !${Me.Ability[Auto Attack].Toggled}
				{
					Me.Ability[Auto Attack]:Use
					wait 10 ${GV[bool,bIsAutoAttacking]} && ${Me.Ability[Auto Attack].Toggled}
				}
				return
			}
		}
	}
	call MeleeAttackOff
}

;===================================================
;===       TARGET ON ME SUB-ROUTINE             ====
;===================================================
function TargetOnMe()
{
	;; put up our 9 second immunity buff
	call UseAbility "${LifeHusk}"
	if ${Return}
	{
		vgecho "IMMUNITY: Target On Me"
		wait 1
	}
}

;===================================================
;===       ATTACK TARGET SUB-ROUTINE            ====
;===   This handles all damage to the target    ====
;===================================================
function AttackTarget()
{
	;-------------------------------------------
	; PAUSE... only if health reports NULL or 0
	;-------------------------------------------
	if ${Me.TargetHealth}<1
	{
		wait 5
	}

	;-------------------------------------------
	; WAIT - Allow time for target to set so we can get the name
	;-------------------------------------------
	if !${Me.Target(exists)}
	{
		vgecho "CAUGHT NO TARGET"
		return
	}

	;-------------------------------------------
	; MELEE ATTACKS - start attacking if in range
	;-------------------------------------------
	call MeleeAttackOn

	;-------------------------------------------
	; TARGET BEHIND US - Let's face the target!
	;-------------------------------------------
	if ${doFace}
	{
		call CalculateAngles
		if ${AngleDiffAbs}>=45
		{
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
		}
	}

	;-------------------------------------------
	; CRIT CHAIN
	;-------------------------------------------
	call CritFinishers

	;-------------------------------------------
	; TARGET ON ME?
	;-------------------------------------------
	if ${Me.InCombat} && ${Me.IsGrouped}
	{
		if ${Me.Ability[${LifeHusk}].IsReady}
		{
			;; check if target is on me
			if ${Me.ToT.Name.Find[${Me.FName}](exists)}
			{
				if ${Me.Inventory[Vial of Blood](exists)}
				{
					call TargetOnMe
				}
			}
		}
	}
	
	;-------------------------------------------
	; SET ALL ABILITIES TO ON
	;-------------------------------------------
	doAE:Set[FALSE]
	doWeakness:Set[TRUE]
	doClickies:Set[TRUE]
	doDissolve:Set[TRUE]
	doMetamorphism:Set[TRUE]
	doExsanguinate:Set[TRUE]
	doBloodTribute:Set[TRUE]
	doFleshRend:Set[TRUE]
	doBloodSpray:Set[TRUE]
	doDespoil:Set[TRUE]
	doEntwiningVein:Set[TRUE]
	doBloodthinner:Set[TRUE]
	doBurstingCyst:Set[TRUE]
	doUnionOfBlood:Set[TRUE]
	doExplodingCyst:Set[TRUE]
	doBloodLettingRitual:Set[TRUE]
	doScarletRitual:Set[TRUE]
	doSeveringRitual:Set[TRUE]

	;-------------------------------------------
	; PREDEFINED SETTINGS FOR EACH TARGET
	;-------------------------------------------
	switch "${Me.Target.Name}"
	{
		case Belzane
			if !${doPhysical} || (${Me.TargetMyDebuff[${UnionOfBlood}](exists)} && ${Me.TargetMyDebuff[${UnionOfBlood}](exists)} && ${Me.TargetMyDebuff[${BloodLettingRitual}](exists)})
			{
				;; totally experimental - I plowed through Arcane but damaged it and healed self
				call UseAbility "${Despoil}"
				if ${Return}
				{
					return
				}
			}
			break
	
		case Corrupted Essence
			;; do not hit this target!
			call MeleeAttackOff
			return

		case Zyxil
			while ${Me.Encounter[1].Name.Find[Abomination]}
			{
				;; priority to AE all these targets
				if ${Me.Ability[${BloodThief}].IsReady} && ${Me.HealthPct}>0
				{
					wait 5 ${Me.Ability[${BloodThief}].IsReady}
					call UseAbility "${BloodThief}"
					if ${Return}
					{
						vgecho "AE - Blood Thief"
						wait 1
					}
				}
			}
			break


		case SI'UMR-LI THE HARBRINGER
			;; Slim-jim "must counter devastation"
			wait 20 ${Me.TargetCasting.Equal[Devastation]}
			if ${Me.TargetCasting.Equal[Devastation]}
			{
				vgecho "== DEVASTATION =="
				while ${Me.TargetCasting.Equal[Devastation]}
				{
					VGExecute "/reactionautocounter"
					wait 1
				}
			}
			break

		case Varaduuk the Gatekeeper
			break

		case Ulvari Transcender
			doRemoveHate:Set[FALSE]
			break

		case Ulvari Eclipser
			doRemoveHate:Set[FALSE]
			break

		case ATARAXIS THE DEVOURER
			;; Chaos Chicken
			break

		case Pantheon Doomseer
			;; Spawn of ATARAXIS
			break

		case Corrupted Deathweaver
			;; Spawn of ATARAXIS
			break

		case Ascenden Arcanist
			;; Spawn of ATARAXIS
			break

		case Ascended Evoker
			;; Spawn of ATARAXIS
			break

		case Wicked Xerklin
			;; Spawn of ATARAXIS
			break

		case Xerklin Servitor
			;; Spawn of ATARAXIS
			break

		case ZASEH THE WISE
			;; Order Chicken
			break

		case Ascended Guardian
			;; Spawn of ZASEH
			break

		case Ascended Crusader
			;; Spawn of ZASEH
			break

		case Pantheon Radiant Mage
			;; Spawn of ZASEH
			break

		case Purified Spellweaver
			;; Spawn of ZASEH
			break

		case Purified Lifeweaver
			;; Spawn of ZASEH
			break

		case Arch Magus Zodifin
			;; This stays up for 5 seconds for everyone to use Band of Reflection
			if ${Me.TargetCasting.Equal[Planar Destruction]}
			{
				i:set[0]
				VGExecute "/raid <Red=> ZODIFIN is casting:<Yellow=> Planar Destruction"
				while ${i}<=5
				{
					i:Inc
					VGExecute "/raid <Red=> REFLECT COUNTDOWN: <Yellow=> ${i}"
					if ${Me.Inventory[Band of Reflection].IsReady} && ${Me.Target.Distance}<25 && ${i}>=3
					{
						vgecho "Planar Destruction - Using Band of Reflection"
						Me.Inventory[Band of Reflection]:Use
					}
					wait 10
					if ${Me.TargetCasting.Equal[Planar Destruction]}
					{
						vgecho "Zodifin is still casting"
					}
				}
				if ${Me.TargetCasting.Equal[Planar Destruction]}
				{
					vgecho "Zodifin is still casting and we finished 5sec warning"
				}
			}
			call VitalHeals
			return

		case FENGROT FOULBREATH
			break

		case Spawn of Krigus
			break

		case Giant Earth Worm
			doAE:Set[FALSE]
			break

		case Terracotta Statue
			doAE:Set[FALSE]
			break

		case Rabid Rat
			doAE:Set[FALSE]
			break

		case Arch Magus Shendu
			doAE:Set[TRUE]
			if ${Me.TargetBuff[Arcane Shield](exists)}
			{
				doArcane:Set[FALSE]
			}
			break


		case Arachnidon Sunshine
			call MeleeAttackOn
			if ${Me.TargetHealth}<22
			{
				doArcane:Set[FALSE]
				doPhysical:Set[FALSE]
				doCounters:Set[FALSE]
				doRemoveHate:Set[FALSE]
				call VitalHeals
				return
			}
			break

		case SUMMONER NIMAA
			break

		case SUMMONER RINIPIN
			;; use 'Shattering Hammer' to remove 'Stone Encasement'
			if ${Me.Effect[Stone Encasement](exists)}
			{
				vgecho "<Red=>I AM STONED"
				if ${Me.Inventory[Shattering Hammer](exists)} && ${Me.Inventory[Shattering Hammer].IsReady}
				{
					EchoIt "Used Shattering Hammer to remove Stone Encasement"
					Me.Inventory[Shattering Hammer]:Use
					wait 5
				}
				wait 20
			}
			break

		case SUMMONER PHYSIK
			;; we do not want to burn Summoner Physik too fast
			;; so no dots if health is 20% or lower
			if ${Me.TargetHealth}<23
			{
				doDots:Set[FALSE]
			}
			break

		case Electric Spark
			;; we want to burn the spawned Electric Spark
			doDots:Set[FALSE]
			StartAttack:Set[100]
			break

		case VARKING
			while !${Me.TargetCasting.Equal[None]}
			{
				call MeleeAttackOn
			}
			if ${Me.TargetHealth}<=21
			{
				;; we do not want to miss a counter so do heals only
				call VitalHeals
				return
			}
			break

		case Frozen Soul Devourer
			;; Cold Only - Use this single-handed weapon
			if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker].CurrentEquipSlot.Equal[Primary Hand]}
			{
				Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Use
				call GlobalRecovery
				return
			}
			else
			{
				if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker](exists)}
				{
					Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Equip[Primary Hand]
					call GlobalRecovery
					return
				}
			}
			return

		case Flaming Soul Devourer
			;; Fire Only - Use this single-handed weapon
			if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker].CurrentEquipSlot.Equal[Primary Hand]}
			{
				Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Use
				call GlobalRecovery
				return
			}
			else
			{
				if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker](exists)}
				{
					Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Equip[Primary Hand]
					call GlobalRecovery
					return
				}
			}
			return

		case Credulous Cadaver
			;; turn off attacks and return
			call MeleeAttackOff
			call VitalHeals
			return

		case Ancient Warden
			call MeleeAttackOff
			;; Use highest most damaging -clickie-
			if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker].CurrentEquipSlot.Equal[Primary Hand]}
			{
				Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Use
				call GlobalRecovery
				return
			}
			else
			{
				if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker](exists)}
				{
					Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Equip[Primary Hand]
					call GlobalRecovery
					return
				}
			}
			return

		case Undying Arcanist
			while !${Me.TargetCasting.Equal[None]}
			{
				call MeleeAttackOn
			}
			if ${Me.TargetBuff[Shielding](exists)}
			{
				return
			}
			doAE:Set[FALSE]
			break

		case Blasphemous Mysticant
			while !${Me.TargetCasting.Equal[None]}
			{
				call MeleeAttackOn
			}
			if ${Me.TargetBuff[Umbral Barrier](exists)}
			{
				call MeleeAttackOn
				return
			}
			break

		case Decaying Soul Thief
			break

		case DRESLA
			doAE:Set[FALSE]
			break

		case Wyvern Hatchling
			;; Do not attack if DRESLA exists
			if ${Pawn[ExactName,DRESLA](exists)}
			{
				call MeleeAttackOff
				Pawn[ExactName,DRESLA]:Target
				wait 3
				call CalculateAngles
				if ${AngleDiffAbs} >= 85
				{
					Pawn[ExactName,DRESLA]:Face
				}
				return
			}
			break

		case Apprentice Dejre
			;; bounces you all over the room so keep facing him! (stand east and west)
			Me.Target:Face
			break

		case Apprentice Ednies
			;; (stand outside)
			Me.Target:Face
			break

		case Apprentice Amat
			;; bounces you all over the room so keep facing him
			Me.Target:Face
			break

		case Apprentice Manai
			;; bounces you all over the room so keep facing him
			Me.Target:Face
			break

		case KOTASOTH
			break

		case Officer Masuke Whitewind
			break

		case VAHSREN THE LIBRARIAN
			break

		case LORD TALFYN
			if ${Me.Effect[Petrify](exists)}
			{
				return
			}
			if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker].CurrentEquipSlot.Equal[Primary Hand]}
			{
				Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Use
				call GlobalRecovery
				return
			}
			else
			{
				if ${Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker](exists)}
				{
					Me.Inventory[Flawless Scholar's Renewed Rod of the Evoker]:Equip[Primary Hand]
					call GlobalRecovery
					return
				}
			}
			call MeleeAttackOn
			if ${Me.Effect[True Curse of the Vampire](exists)}
			{
				call VampireAbilities
				return
			}
			break

		case Gregoras the Watcher
			if ${Me.Effect[Petrify](exists)}
			{
				return
			}
			call MeleeAttackOn
			if ${Me.Effect[True Curse of the Vampire](exists)}
			{
				call VampireAbilities
				return
			}
			break

		case Prince Julian
			if ${Me.Effect[Petrify](exists)}
			{
				return
			}
			call MeleeAttackOn
			if ${Me.Effect[True Curse of the Vampire](exists)}
			{
				call VampireAbilities
				return
			}
			break

		case Lady Serra
			if ${Me.Effect[Petrify](exists)}
			{
				return
			}
			call MeleeAttackOn
			if ${Me.Effect[True Curse of the Vampire](exists)}
			{
				call VampireAbilities
				return
			}
			break

		case Servant
			if ${Me.TargetBuff[Vampiric Embrace](exists)}
			{
				if ${Me.ToT.Name.Find[${Me.FName}](exists)}
				{
					if ${Me.Inventory[Vile Poison](exists)}
					{
						if ${Me.Inventory[Vile Poison].IsReady}
						{
							Me.Inventory[Vile Poison]:Use
							wait 10
						}
					}
				}
				return
			}
			break

		case Minion of Darkness
			if ${Me.Effect[Petrify](exists)}
			{
				return
			}
			call MeleeAttackOn
			if ${Me.Effect[True Curse of the Vampire](exists)}
			{
				call VampireAbilities
				return
			}
			break

		case Umbral Syndicate Captain
			doDots:Set[FALSE]
			break

		case Umbral Syndicate Enforcer
			doDots:Set[FALSE]
			break

		case Umbral Syndicate Warlock
			doDots:Set[FALSE]
			break

		case GUAR
			doRemoveHate:Set[FALSE]
			break

		case Arch Magus Teraxes
			;; he does a lot of damage so stay in this form
			;; halt all attacks
			if ${Me.TargetBuff[Major Enchantment: Ulvari Flame](exists)}
			{
				call MeleeAttackOff
				return
			}
			doRemoveHate:Set[FALSE]
			break

		Default
			break
	}

	;-------------------------------------------
	; LOWER HATE
	;-------------------------------------------
	if ${Me.InCombat} && ${Me.IsGrouped}
	{
		if ${doRemoveHate}
		{
			;; lower aggro if current target is hitting me
			if ${Me.ToT.Name.Find[${Me.FName}](exists)}
			{
				call UseAbility "${Numb}"
				if ${Return}
				{
					vgecho "DeAggro: ${Me.Target.Name}"
					wait 1
				}
			}
		}
	}

	
	;===========================================
	;===========================================
	; DAMAGING ABILITIES AND ATTACKS BELOW HERE
	;===========================================
	;===========================================

	;-------------------------------------------
	; USE ABILITIES
	;-------------------------------------------
	if !${UseAbilities}
	{
		return
	}

	;-------------------------------------------
	; CLICKIES - Use them if we got them
	;-------------------------------------------
	if ${doArcane}
	{
		;if ${Me.Inventory[Imperial Arch Magi Ring].IsReady} && ${Me.Target.Distance}<15
		;{
		;	Me.Inventory[Imperial Arch Magi Ring]:Use
		;	call GlobalRecovery
		;	return
		;}
	}

	if ${Me.HealthPct}>80
	{
		;-------------------------------------------
		; USE OUR WAND OF ULVARI
		;-------------------------------------------
		if ${Me.Ability[Ulvari Burst].IsReady}
		{
			call UseAbility "Ulvari Burst"
		}
		;-------------------------------------------
		; Establish Blood Feast - Get 10% of damage from allies returned back to me as health
		;-------------------------------------------
		if ${doBloodFeast} && ${Me.Ability[${BloodFeast}](exists)} && !${Me.Effect[${BloodFeast}](exists)}
		{
			call UseAbility "${BloodFeast}"
		}
		elseif !${doBloodFeast} && ${Me.Ability[${BloodFeast}](exists)} && ${Me.Effect[${BloodFeast}](exists)}
		{
			call UseAbility "${BloodFeast}"
		}
		;-------------------------------------------
		; Establish Ritual of Awakening - +20% spell haste
		;-------------------------------------------
		if ${Me.BloodUnion}>2 && ${Me.Ability[${RitualOfAwakening}](exists)} && !${Me.Effect[${RitualOfAwakening}](exists)}
		{
			call UseAbility "${RitualOfAwakening}"
		}
	}

	;-------------------------------------------
	; DOTS - Physical type damage
	;-------------------------------------------
	if ${doPhysical} && ${doDots}
	{
		SafeToDPS:Set[FALSE]
		if ${Me.IsGrouped}
		{
			if ${GET.LifetapThisID}==0
			{
				SafeToDPS:Set[TRUE]
			}
		}
		else
		{
			;; check if my health is above the CheckHealth level
			if ${Me.HealthPct}>=${HealCheck}
			{
				SafeToDPS:Set[TRUE]
			}
		}

		if ${SafeToDPS}
		{
			if ${Me.Ability[${ExplodingCyst}].IsReady}
			{
				if !${Me.TargetMyDebuff[${ExplodingCyst}](exists)}
				{
					if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
					{
						Me.Form["Focus of Gelenia"]:ChangeTo
						wait .5
					}
					call UseAbility "${ExplodingCyst}"
					if ${Return}
					{
						return
					}
				}
			}
			else
			{
				if ${Me.Ability[${BurstingCyst}].IsReady}
				{
					if !${Me.TargetMyDebuff[${BurstingCyst}](exists)}
					{
						if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
						{
							Me.Form["Focus of Gelenia"]:ChangeTo
							wait .5
						}
						call UseAbility "${BurstingCyst}"
						if ${Return}
						{
							return
						}
					}
				}
			}
			if ${Me.Ability[${UnionOfBlood}].IsReady}
			{
				if !${Me.TargetMyDebuff[${UnionOfBlood}](exists)}
				{
					if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
					{
						Me.Form["Focus of Gelenia"]:ChangeTo
						wait .5
					}
					call UseAbility "${UnionOfBlood}"
					if ${Return}
					{
						return
					}
				}
			}
			if ${Me.Ability[${BloodLettingRitual}].IsReady}
			{
				if !${Me.TargetMyDebuff[${BloodLettingRitual}](exists)}
				{
					if ${Me.Ability[${BloodLettingRitual}].BloodUnionRequired} <= ${Me.BloodUnion}
					{
						if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
						{
							Me.Form["Focus of Gelenia"]:ChangeTo
							wait .5
						}
						call UseAbility "${BloodLettingRitual}"
						if ${Return}
						{
							return
						}
					}
				}
			}
		}
	}

	;-------------------------------------------
	; SEVERING RITUAL - AE Dot
	;-------------------------------------------
	if ${doArcane} && ${doDots} && !${Me.TargetBuff[Furious](exists)}
	{
		if !${Me.TargetMyDebuff[${SeveringRitual}](exists)}
		{
			if ${Me.Ability[${SeveringRitual}].IsReady}
			{
				if ${Me.BloodUnion} > 4
				{
					if (${Me.Ability[${Bloodthinner}](exists)} && ${Me.TargetMyDebuff[${Bloodthinner}](exists)}) || !${Me.Ability[${Bloodthinner}](exists)}
					{
						if !${Pawn[AggroNPC,NPC,from,target,radius,15,notid,${Me.Target.ID}](exists)}
						{
							if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
							{
								Me.Form["Focus of Gelenia"]:ChangeTo
								wait .5
							}
							call UseAbility "${SeveringRitual}"
							if ${Return}
							{
								return
							}
						}
					}
				}
			}
		}
	}

	;-------------------------------------------
	; LIFETAP - pure life tap
	;-------------------------------------------
	if ${doArcane} && ${doLifeTaps} && !${Me.TargetBuff[Furious](exists)}
	{
		;; Use lifetap if ability is ready
		if ${Me.Ability[${Bloodthinner}].IsReady} || ${Me.Ability[${EntwiningVein}].IsReady} || ${Me.Ability[${Despoil}].IsReady}
		{
			;-------------------------------------------
			; FIRST - Set your DTarget for Bloodthinner and Entwining Vein
			;-------------------------------------------
			if ${doTankOnly}
			{
				;; Lifetap the tank only
				if !${Me.DTarget.Name.Find[${Tank}]}
				{
					Pawn[name,${Tank}]:Target
					wait 1
				}
			}
			elseif ${Me.IsGrouped}
			{
				;; set variable to whom we want to lifetap

				LifeTapGroupNumber:Set[${GET.LifetapThisID}]
				;vgecho [LifeTapGroupNumber=${LifeTapGroupNumber}][${Group[${LifeTapGroupNumber}].Name}]
				if ${LifeTapGroupNumber}
				{
					;; set DTarget to member with lowest health
					if ${Group[${LifeTapGroupNumber}].ID}!=${Me.DTarget.ID}
					{
						Pawn[id,${Group[${LifeTapGroupNumber}].ID}]:Target
						wait 1
					}
				}
				else
				{
					;; Nobody is wounded, set DTarget to target's target if tank does not exist
					if !${Pawn[name,${Tank}](exists)}
					{
						;; we are in a safe zone so set DTarget to our target's target
						VGExecute "/assistoffensive"
						wait 1
					}
					else
					{
						;; otherwise, target the tank!
						if !${Me.DTarget.Name.Find[${Tank}]}
						{
							Pawn[name,${Tank}]:Target
							wait 1
						}
					}
				}
			}
			elseif !${Me.IsGrouped}
			{
				Pawn[Me]:Target
				wait 3
			}

			;-------------------------------------------
			; SECOND - Use Bloodthinner to lower resistances
			;-------------------------------------------
			if !${Me.TargetMyDebuff[$(Bloodthinner}](exists)}
			{
				if ${Me.Ability[${Bloodthinner}].IsReady}
				{
					if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
					{
						Me.Form["Focus of Gelenia"]:ChangeTo
						wait .5
					}
					call UseAbility "${Bloodthinner}"
					if ${Return}
					{
						return
					}
				}
			}

			;-------------------------------------------
			; THIRD - Use Entwining Vein if DTarget is not me
			;-------------------------------------------
			if ${Me.IsGrouped}
			{
				if !${Me.FName.Equal[${Me.DTarget.Name}]}
				{
					if	${Me.Ability[${EntwiningVein}].IsReady}
					{
						if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
						{
							Me.Form["Focus of Gelenia"]:ChangeTo
							wait .5
						}
						call UseAbility "${EntwiningVein}"
						if ${Return}
						{
							return
						}
					}
				}
			}

			;-------------------------------------------
			; FORTH - Use Despoil on myself, no need to set DTarget
			;-------------------------------------------
			; lifetap mob hoping it will heal me and generate a crit
			if ${Me.Ability[${Despoil}].IsReady}
			{
				if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
				{
					Me.Form["Focus of Gelenia"]:ChangeTo
					wait .5
				}
				call UseAbility "${Despoil}"
				if ${Return}
				{
					return
				}
			}
		}
	}
}


;===================================================
;===       CRIT/FINISH SUB-ROUTINE              ====
;===   called by AttackTarget and UseAbility    ====
;===================================================
function CritFinishers()
{
	;; return if we do not want to use any crits
	if !${doCrits}
	{
		return
	}

	;; return if no crits
	if ${Me.Ability[${BloodTribute}].TriggeredCountdown}==0
	{
		return
	}
	
	;; wait until our crit is ready - no crit will be missed
	;while ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0 && ${Me.Ability[${BloodTribute}].TimeRemaining}>0
	;{
	;	wait .1
	;}

	;; Echo our crit status
	EchoIt "Blood Tribute - Reamining=${Me.Ability[${BloodTribute}].TimeRemaining}, CountDown=${Me.Ability[${BloodTribute}].TriggeredCountdown}, Ready=${Me.Ability[${BloodTribute}].IsReady}"
	EchoIt "Blood Spray   - Reamining=${Me.Ability[${BloodSpray}].TimeRemaining}, CountDown=${Me.Ability[${BloodSpray}].TriggeredCountdown}, Ready=${Me.Ability[${BloodSpray}].IsReady}"
	EchoIt "Exsanguinate  - Remaining=${Me.Ability[${Exsanguinate}].TimeRemaining}, CountDown=${Me.Ability[${Exsanguinate}].TriggeredCountdown}, Ready=${Me.Ability[${Exsanguinate}].IsReady}"

	if ${doArcane}
	{
		;; change to DPS form
		if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
		{
			Me.Form["Focus of Gelenia"]:ChangeTo
			wait .5
		}

		; wait till someone is hurt before using the crit heal
		if ${doCritWait}
		{
			HealNow:Set[FALSE]

			;; loop this until someone's health drops below the HealCheck
			while !${HealNow} && ${Me.Ability[${BloodTribute}].TriggeredCountdown}>2
			{
				for (i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc)
				{
					;; catch the Tank's Group Number incase the Tank is not in the group
					if ${Tank.Find[${Group[${i}].Name}]}
					{
						h:Set[${i}]
					}

					;; check only those players within 10 meters of me
					if ${Group[${i}].Distance}<=10
					{
						if ${GROUP1.Find[${Group[${i}].Name}]}
						{
							if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								EchoIt [${Group[${i}].Health.Int}] ${Group[${i}].Name}
								HealNow:Set[TRUE]
								break
							}
						}
						elseif ${GROUP2.Find[${Group[${i}].Name}]}
						{
							if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								EchoIt [${Group[${i}].Health.Int}] ${Group[${i}].Name}
								HealNow:Set[TRUE]
								break
							}
						}
						elseif ${GROUP3.Find[${Group[${i}].Name}]}
						{
							if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								EchoIt [${Group[${i}].Health.Int}] ${Group[${i}].Name}
								HealNow:Set[TRUE]
								break
							}
						}
						elseif ${GROUP4.Find[${Group[${i}].Name}]}
						{
							if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								EchoIt [${Group[${i}].Health.Int}] ${Group[${i}].Name}
								HealNow:Set[TRUE]
								break
							}
						}
						elseif ${GROUP5.Find[${Group[${i}].Name}]}
						{
							if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								EchoIt [${Group[${i}].Health.Int}] ${Group[${i}].Name}
								HealNow:Set[TRUE]
								break
							}
						}
						elseif ${GROUP6.Find[${Group[${i}].Name}]}
						{
							if ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${i}].Name}].HaveLineOfSightTo}
							{
								EchoIt [${Group[${i}].Health.Int}] ${Group[${i}].Name}
								HealNow:Set[TRUE]
								break
							}
						}
					}
				}

				;; if the above finished looping then check the Tank's health... chances are the Tank is not in the group
				if !${HealNow} && ${Group[${h}].Health}>0 && ${Group[${h}].Health}<${LifeTapCheck} && ${Pawn[name,${Group[${h}].Name}].HaveLineOfSightTo}
				{
					EchoIt Aborting Crit Heal Wait because Tank is not in group and is wounded - [${Group[${h}].Health.Int}] ${Group[${h}].Name}
					HealNow:Set[TRUE]
					;return
				}
			}
			;; Use our crit heal
			call UseAbility "${BloodTribute}"
			return
		}
	}

	if ${doPhysical}
	{
		if ${doDots} && !${doCritHealOnly} && ${Me.TargetCasting.Equal[None]}
		{
			SafeToDPS:Set[FALSE]
			if ${Me.IsGrouped}
			{
				if !${GET.LifetapThisID}
				{
					SafeToDPS:Set[TRUE]
				}
			}
			else
			{
				;; check if my health is above the CheckHealth level
				if ${Me.HealthPct}>=${HealCheck}
				{
					SafeToDPS:Set[TRUE]
				}
			}

			if ${SafeToDPS}
			{
				;; change to DPS form
				if !${Me.CurrentForm.Name.Equal["Focus of Gelenia"]}
				{
					Me.Form["Focus of Gelenia"]:ChangeTo
					wait .5
				}

				;; most damaging CRIT
				call UseAbility "${BloodSpray}"
				if ${Return}
				{
					return
				}

				;; most damaging CRIT
				call UseAbility "${FleshRend}"
				if ${Return}
				{
					return
				}

				;; crit that deals damage over time
				call UseAbility "${Exsanguinate}"
				if ${Return}
				{
					return
				}
			}
		}
	}

	if ${doArcane}
	{
		call UseAbility "${BloodTribute}"
	}
}

;===================================================
;===          VAMPIRE SUB-ROUTINE               ====
;===================================================
variable bool useVampireClaws = FALSE
function VampireAbilities()
{
	;; return if we are not in vampire form
	if !${Me.Effect[True Curse of the Vampire](exists)}
	{
		echo "Not in Vampire Mode"
		return
	}

	while ${Me.IsCasting}
	{
		waitframe
	}
	

	;; reset vampire claws
	if ${Me.Target.Distance}>10
	{
		useVampireClaws:Set[FALSE]
	}
	
	echo useVampireClaws=${useVampireClaws}

	;; go heal someone if their health is low
	for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
	{
		if ${Group[${i}].Distance}<30 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<60
		{
			Pawn[id,${Group[${i}].ID}]:Target
			wait 10 ${Me.Ability[Vampire: Vampiric Symbiosis].IsReady}

			if ${Me.Ability[Vampire: Vampiric Symbiosis].IsReady}
			{
				;; wait so that checking inventory will not crash
				wait 2
				if ${Me.Inventory[Blood of the KDQ].Quantity}>=2
				{
					vgecho "Healing:  ${Group[${i}].Name}"
					wait 1
					Me.Ability[Vampire: Vampiric Symbiosis]:Use
					wait 10
					return
				}
			}
		}
	}

	;; Spam this until it times out
	if ${useVampireClaws} && ${Me.Ability[Vampire: Claw].IsReady}
	{
		vgecho "Using Claw"
		wait 1
		Me.Ability[Vampire: Claw]:Use
		wait 3
		return
	}

	;; lower the cooldown timer of the Claw, must be within 3 meters
	if ${Me.Target.Distance}<=3
	{
		;; wait so that checking inventory will not crash
		wait 3
		if ${Me.Inventory[Blood of the KDQ].Quantity}>=2
		{
			;; both must be ready so we don't use this again
			if ${Me.Ability[Vampire: Blood Lust].IsReady} && ${Me.Ability[Vampire: Claw].IsReady}
			{
				vgecho "Blood Lust!"
				wait 1
				Me.Ability[Vampire: Blood Lust]:Use
				useVampireClaws:Set[TRUE]
				wait 3
				return
			}
		}
	}
}



