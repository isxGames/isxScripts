;
; The FindAction routine is designed to identify
; actions we want to perform by priority.  There
; are no waits or pauses because all we are doing
; here is setting a variable "PerformAction".
;
; IMPORTANT - must make sure you are able to execute
; the action else it will get caught in a loop.  Example,
; no berries to remove poison so don't set the PerformAction
; to remove the poison.  Do the checks here!
;
;===================================================
;===      FINDACTION - SUBROUTINE               ====
;===================================================
atom(script) FindAction()
{
	;-------------------------------------------
	;; define our variables we will use in this atom
	;-------------------------------------------
	variable int j
	variable int k
	variable int l
	variable int temp
	
	;-------------------------------------------
	; WE CHUNKED - handles pausing when we chunked
	;-------------------------------------------
	if !${CurrentChunk.Equal[${Me.Chunk}]}
	{
		PerformAction:Set[WeChunked]
		return
	}

	;-------------------------------------------
	; WE ARE DEAD - we do not want to do anything
	;-------------------------------------------
	if !${Me.Health}
	{
		PerformAction:Set[WeAreDead]
		return
	}
		
	;-------------------------------------------
	; PAUSED - we do not want to do anything or when we are dancing
	;-------------------------------------------
	if ${isPaused} || ${Me.Effect[Boogey!](exists)} || ${Me.Effect[Invulnerability Login Effect](exists)}
	{
		PerformAction:Set[Paused]
		return
	}

	;-------------------------------------------
	; FIND GROUP MEMBERS - updates who are group members are
	;-------------------------------------------
	if ${doFindGroupMembers}
	{
		PerformAction:Set[FindGroupMembers]
		return
	}

	;-------------------------------------------
	; DELAYCHECK - do this every half a second
	;-------------------------------------------
	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextDelayCheck}]}/1000]}>1
	{
		; reset next delay check
		NextDelayCheck:Set[${Script.RunningTime}]
		
		;-------------------------------------------
		; FOLLOW TANK - always follow the tank at all times!
		;-------------------------------------------
		if ${doFollow}
		{
			if !${Me.FName.Find[${Tank}]}
			{
				if ${Pawn[name,${Tank}](exists)}
				{
					if ${Pawn[name,${Tank}].Distance}>${FollowDistance2} && ${Pawn[name,${Tank}].Distance}<45
					{
						PerformAction:Set[FollowTank]
						return
					}
				}
			}
		}
		
		;-------------------------------------------
		; ASSIST TANK - always assist when tank is in combat
		;-------------------------------------------
		if ${doAssist}
		{
			if !${Me.FName.Find[${Tank}]}
			{
				if ${Pawn[name,${Tank}](exists)}
				{
					;; assist the tank only if the tank is in combat and less than 50 meters away
					if ${Pawn[name,${Tank}].CombatState}>0 && ${Pawn[name,${Tank}].Distance}<=50
					{
						;; assist tank only if we are not in combat, target is dead, or we do not have a target
						if !${Me.Target(exists)}
						{
							PerformAction:Set[AssistTank]
							return
						}
					}
				}
			}
		}
	
		;-------------------------------------------
		; TARGET IS DEAD - (turn off autoattack, loot, and clear target)
		;-------------------------------------------
		if ${Me.Target(exists)}
		{
			if ${Me.Target.IsDead} || ${Me.Target.Type.Equal[Corpse]}
			{
				PerformAction:Set[TargetIsDead]
				return
			}
		}

	;-------------------------------------------
	; SILENCED - No Spell Casting
	;-------------------------------------------
	if ${Me.Effect[Silence](exists)}
	{
		PerformAction:Set[Default]
		return
	}
	if ${Me.Effect[Mezmerize](exists)}
	{
		PerformAction:Set[Default]
		return
	}

	;-------------------------------------------
	; STRIP ENCHANTMENTS - perform once every other second
	;-------------------------------------------
	if ${doStripEnchantments}
	{
		if ${Me.Target(exists)}
		{
			if ${Me.Ability[${StripEnchantment}].IsReady} && ${Me.Target.HaveLineOfSightTo}
			{
				; loop through all target buffs finding confirmed enchantment we can stip
				for (l:Set[1] ; ${l}<=${Me.TargetBuff} ; l:Inc)
				{
					;; Remove Enchantments
					if ${Me.TargetBuff[${l}].Name.Find[Enchantment]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Dark Celerity
					elseif ${Me.TargetBuff[${l}].Name.Find[Dark Celerity]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Vigor
					elseif ${Me.TargetBuff[${l}].Name.Find[Vigor]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Thick Skin
					elseif ${Me.TargetBuff[${l}].Name.Find[Thick Skin]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Lightning Barrier
					elseif ${Me.TargetBuff[${l}].Name.Find[Lightning]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Chaos Shield
					elseif ${Me.TargetBuff[${l}].Name.Find[Chaos]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Annulment Field
					elseif ${Me.TargetBuff[${l}].Name.Find[Annulment]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Touch of Fire
					elseif ${Me.TargetBuff[${l}].Name.Find[Touch of Fire]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Touch of Fire
					elseif ${Me.TargetBuff[${l}].Name.Find[Holy Armor]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
					;; Remove Touch of Fire
					elseif ${Me.TargetBuff[${l}].Name.Find[Rust Shield]}
					{
						vgecho "<Purple=>Stripping: <Yellow=>${Me.TargetBuff[${l}].Name}"
						StripThisEnchantment:Set[${Me.TargetBuff[${l}].Name}]
						PerformAction:Set[RemoveEnchantment]
						return
					}
				}
			}

			;-------------------------------------------
			; REMOVE POISONS
			;-------------------------------------------
			if ${Me.Effect[Noxious Bite](exists)}
			{
				if ${Me.Inventory[Great Sageberries](exists)} && ${Me.Inventory[Great Sageberries].IsReady}
				{
					vgecho "Noxious Bite - ${Me.Effect[Noxious Bite].Description}"
					PerformAction:Set[RemovePoison]
					return
				}
			}
			;; cycle through all effects searching for those that have key word of "Poison"
			for (l:Set[1] ; ${l}<=${Me.Effect.Count} ; l:Inc)
			{
				if ${Me.Effect[${l}].Name.Find[Poison:]} || ${RemovePoison}
				{
					;; we want to save this 
					redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Poisoned.txt" echo "[${Time}][${Me.Target.Name}][Beneficial=${Me.Effect[${l}].IsBeneficial}][Detrimental=${Me.Effect[${l}].IsDetrimental}][${Me.Effect[${l}].Name}]"
					if ${Me.Inventory[Great Sageberries](exists)} && ${Me.Inventory[Great Sageberries].IsReady}
					{
						PerformAction:Set[RemovePoison]
						return
					}
				}
			}
		}
	}
	}
			
	;-------------------------------------------
	; SILENCED - No Spell Casting
	;-------------------------------------------
	if ${Me.Effect[Silence](exists)}
	{
		PerformAction:Set[Default]
		return
	}
	if ${Me.Effect[Mezmerize](exists)}
	{
		PerformAction:Set[Default]
		return
	}

	;-------------------------------------------
	; REGAIN ENERGY - canabalize my health for energy
	;-------------------------------------------
	if ${Me.EnergyPct}<80 && ${Me.HealthPct}>80
	{
		if ${Me.Ability[${MentalTransmutation}].IsReady}
		{
			PerformAction:Set[RegainEnergy]
			return
		}
		if ${Me.EnergyPct}<40 && ${Me.Inventory[Large Mottleberries](exists)}
		{
			if ${Me.Inventory[Large Mottleberries].IsReady}
			{
				PerformAction:Set[RegainEnergy]
				return
			}
		}
	}

	;-------------------------------------------
	; VITAL HEALS - use our slow heals
	;-------------------------------------------
	if ${doVitalHeals}
	{
		;; check to see if we need to use our slow heal
		if ${GET.HealThisID} || ${Me.HealthPct}<${HealCheck}
		{
			PerformAction:Set[VitalHeals]
			return
		}
		;; check for group heals
		TotalWounded:Set[${GET.TotalGroupWounded}]
		if ${TotalWounded}>=3
		{
			PerformAction:Set[VitalHeals]
			return
		}
	}
	
	;-------------------------------------------
	; ATTACK TARGET - we will use Dots and Lifetaps
	;-------------------------------------------
	if ${OkayToAttack}
	{
		if ${Me.Target(exists)}
		{
			if ${Me.TargetHealth}<=${StartAttack}
			{
				if ${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}
				{
					if ${Me.Target.Distance}<30 && ${Me.Target.HaveLineOfSightTo} && !${Me.Target.IsDead}
					{
						if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextAttackCheck}]}/100]}>=${DelayAttack}
						{
							PerformAction:Set[AttackTarget]
							return
						}
					}
				}
			}
		}
	}
	
	;-------------------------------------------
	; BUFF REQUESTS - buff anyone that says "buff"
	;-------------------------------------------
	if ${BuffRequest}
	{
		if ${Pawn[${PCName}](exists)}
		{
			if ${Pawn[${PCName}].Distance}<25 && ${Me.Ability[${ConstructsAugmentation}].IsReady}
			{
				PerformAction:Set[BuffRequests]
				return
			}
		}
	}
	
	;-------------------------------------------
	; BUFF AREA - check everyone's buffs and buff them
	;-------------------------------------------
	if ${doBuffArea}
	{
		PerformAction:Set[BuffArea]
		return
	}

	;-------------------------------------------
	; DEFAULT - do nothing
	;-------------------------------------------
	PerformAction:Set[Default]
}

	
