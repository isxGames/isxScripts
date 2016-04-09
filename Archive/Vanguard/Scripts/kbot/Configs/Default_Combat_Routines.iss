
;================================================
function BuffUp()
{
	;call DebugIt "You are in function BuffUp"

	; Feign Death... don't buff while pretending we are dead
	if ${DoWeHaveFD} && ${Me.Effect[${FeignDeath}](exists)}
	return

	;Make sure pet is up
	if !${Me.HavePet} && ${doSummonPet}
	{
		;Cast Pet
		Me.Ability[${summonPetSpell}]:Use
		call DebugIt " -- D. BuffUp Calling Pet: ${Me.Ability[${summonPetSpell}]}"
		call MeCasting
	}

	variable iterator anIter

	setConfig.FindSet[Buffs]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;If our buff is gone, or has less than 60 seconds, rebuff
		if !${Me.Effect[${anIter.Key}](exists)} && ${Me.Effect[${anIter.Key}].TimeRemaining} <= 60
		{
			Pawn[me]:Target
			Me.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. BuffUp: ${Me.Ability[${anIter.Key}]}"
			call MeCasting
			wait 5
		}
		anIter:Next
	}
}

;================================================
function ToggleBuffs()
{

	; Feign Death... don't buff while pretending we are dead
	if ${DoWeHaveFD} && ${Me.Effect[${FeignDeath}](exists)}
	return

	variable iterator anIter

	setConfig.FindSet[ToggleBuffs]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;This is a toggled buff with no timer. If it doesn't exist cast it
		if !${Me.Effect[${anIter.Key}](exists)}
		{
			Me.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. ToggleBuffs: ${Me.Ability[${anIter.Key}]}"
			call MeCasting
			wait 5
		}
		anIter:Next
	}

}

;================================================
function:bool CombatBuffsUp()
{
	if ${Me.TargetHealth} < 30
	return FALSE

	variable iterator anIter

	setConfig.FindSet[CombatBuffs]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;This is a toggled buff with no timer. If it doesn't exist cast it
		if ${Me.Ability[${anIter.Key}].IsReady} && !${Me.Effect[${anIter.Key}](exists)}
		{
			Me.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. CombatBuffsUp: ${Me.Ability[${anIter.Key}]}"
			call MeCasting
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}

;================================================
function:bool SnareMob()
{
	if !${useSnareAttack}
	return FALSE

	call CheckAbilCost "${snareAttack}"
	if ${Return} && ${Me.Ability[${snareAttack}].IsReady} && !${Me.TargetMyDebuff[${snareAttack}](exists)} && ${Me.TargetHealth} > 30
	{
		Face ${Me.Target.X} ${Me.Target.Y}
		;cast snare
		Me.Ability[${snareAttack}]:Use
		call DebugIt " -- D. SnareMob: ${Me.Ability[${snareAttack}]}"
		call MeCasting
		return TRUE
	}
	return FALSE
}

;================================================
function:bool MeleeAttack()
{
	variable bool attackUsed = FALSE

	if ${Me.Target.IsDead}
	return FALSE

	; Save at least 10% Endurance for Emergency use
	if ${Me.EndurancePct} < 10
	return FALSE

	;call DebugIt "D. Check to see if we have Melee attacks"

	variable iterator anIter

	setConfig.FindSet[MeleeAttacks]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;call DebugIt "D. AttackSub ${anIter.Key}, rdy ${Me.Ability[${anIter.Key}].IsReady}"
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady}
		{
			call DebugIt " -- D. Using Melee attack: ${Me.Ability[${anIter.Key}]}"
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			attackUsed:Set[TRUE]
			call MeCasting
			wait 3
			break
		}
		anIter:Next
	}

	return ${attackUsed}
}

;================================================
function:bool RangedAttack()
{
	variable bool attackUsed = FALSE

	if ${Me.Target.IsDead}
	return

	variable iterator anIter

	setConfig.FindSet[RangedAttacks]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;call DebugIt "D. AttackSub ${anIter.Key}, rdy ${Me.Ability[${anIter.Key}].IsReady}"
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady}
		{
			call DebugIt " -- D. Using Ranged attack: ${Me.Ability[${anIter.Key}]}"
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			attackUsed:Set[TRUE]
			call MeCasting
			wait 3
			break
		}
		anIter:Next
	}

	;if (${Me.TargetHealth} > 20) && ${doAddChecking}
	;{
	;	call AvoidAdds  ${MobAgroRange}
	;}

	return ${attackUsed}
}


;================================================
function:bool DoTs()
{

	variable iterator anIter

	; Save at least 5% Energy for Emergency use
	if ${Me.EnergyPct} < 5
	return

	setConfig.FindSet[DotAttacks]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;call DebugIt "D. DoT Sub ${anIter.Key}, rdy ${Me.Ability[${anIter.Key}].IsReady}, Already dotted ${Me.TargetMyDebuff[${anIter.Key}](exists)}"
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady} && !${Me.TargetMyDebuff[${anIter.Key}](exists)}
		{
			call DebugIt " -- D. Using DoTs: ${Me.Ability[${anIter.Key}]}"
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			call MeCasting
			wait 3
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}

;================================================
function:bool Nukes()
{
	variable iterator anIter

	; Save at least 5% Energy for Emergency use
	if ${Me.EnergyPct} < 5
	return

	setConfig.FindSet[NukeAttacks]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;call DebugIt "D. Nuke Sub ${anIter.Key}, rdy ${Me.Ability[${anIter.Key}].IsReady}, Already Nuketed ${Me.TargetMyDebuff[${CurrentNukeName}](exists)}"
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady}
		{
			call DebugIt " -- D. Using Nuke: ${Me.Ability[${anIter.Key}]}"
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			call MeCasting
			wait 3
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}

;================================================
function CheckForPetAttacks()
{
	;call DebugIt "D. Check to see if we have any Pet Attacks active"

	;Make sure pet is up
	if !${Me.HavePet}
	return

	;This sub is ran after initiating any combat ability, this will use Pet Attacks if they're up
	if !${Me.Target.ID(exists)}
	return

	VGExecute "/pet attack"
	VGExecute "/minions attack"

	variable iterator anIter

	setConfig.FindSet[PetAttacks]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;-----if my pet is within melee range (<=5)------
		;if ${Math.Calc[${Math.Distance["${Me.Pet.ToPawn.Location}","${Me.Target.Location.}"]}/100]} <= 5
		;{

		;Pet Attacks -- Do they always cost Endurance?
		;if ${Me.Pet.Ability[${anIter.Key}].IsReady} && ${Me.InCombat} && ${Me.Ability[${anIter.Key}].EnduranceCost} < ${Me.Endurance}
		if ${Me.Pet.Ability[${anIter.Key}].IsReady}
		{
			Me.Pet.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. Pet Attack: ${Me.Ability[${anIter.Key}]}"
			return
		}
		anIter:Next
	}
}

;================================================
function:bool CheckForChain()
{
	;call DebugIt "D. Check to see if we have chains active"

	;This sub is ran after initiating any combat ability, this will use Chains if they're up
	if !${Me.Target.ID(exists)}
	return FALSE

	variable iterator anIter

	setConfig.FindSet[Chains]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;Chains
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady} && ${Me.InCombat}
		{
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. Chain: ${Me.Ability[${anIter.Key}]}"
			call MeCasting
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}

;================================================
function CheckForCounter()
{
	;call DebugIt "D. Check to see if we have Counter active"

	;This sub is ran after initiating any combat ability, this will use Counters if they're up
	if !${Me.Target.ID(exists)}
	return FALSE

	variable iterator anIter

	setConfig.FindSet[Counters]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;Counters
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady} && ${Me.InCombat}
		{
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. Counter: ${Me.Ability[${anIter.Key}]}"
			call MeCasting
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}

;================================================
function:bool CheckForRescue()
{
	;call DebugIt "D. Check to see if we have Rescues active"

	;This sub is ran after initiating any combat ability, this will use Rescues if they're up
	if !${Me.Target.ID(exists)}
	return FALSE

	variable iterator anIter

	setConfig.FindSet[Rescues]:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;Chains
		call CheckAbilCost "${anIter.Key}"
		if ${Return} && ${Me.Ability[${anIter.Key}].IsReady} && ${Me.InCombat}
		{
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${anIter.Key}]:Use
			call DebugIt " -- D. Rescue: ${Me.Ability[${anIter.Key}]}"
			call MeCasting
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}


;====== DK Combo Attack Sequence ================================
function DKComboAttack()
{
	;First check DKCombo1
	call CheckAbilCost "${DKCombo1}"
	if ${Return} && ${Me.Ability[${DKCombo1}].IsReady}
	{
		; Then check DKCombo2
		call CheckAbilCost "${DKCombo2}"
		if ${Return} && ${Me.Ability[${DKCombo2}].IsReady}
		{
			;call DebugIt "D. Using DK Combo Attack 1"
			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${DKCombo1}]:Use
			call DebugIt " -- D. DK Combo Attack 1: ${Me.Ability[${DKCombo1}]}"
			call MeCasting

			Face ${Me.Target.X} ${Me.Target.Y}
			Me.Ability[${DKCombo2}]:Use
			call DebugIt " -- D. DK Combo Attack 2: ${Me.Ability[${DKCombo2}]}"
			call MeCasting

			return TRUE
		}
	}
	return FALSE
}


;================================================
function Finishers()
{
	;Finishers
	call CheckAbilCost "${finishAttack}"
	if ${useFinishAttack} && ${Return} && ${Me.Ability[${finishAttack}].IsReady}
	{
		;call DebugIt "D. Using Finisher attack"
		Face ${Me.Target.X} ${Me.Target.Y}
		Me.Ability[${finishAttack}]:Use
		call DebugIt " -- D. Finish Attack: ${Me.Ability[${finishAttack}]}"
		call MeCasting
	}
}

;================================================
function Canni()
{
	if ${DoWeHaveCanni} && ${Me.HealthPct} > ${CanniHPAt} && ${Me.EnergyPct} < ${CanniEgAt}
	{
		call DebugIt "D. In Canni"
		;Cast Canni
		Pawn[me]:Target
		Me.Ability[${Canni}]:Use
		call DebugIt " -- D. Finish Attack: ${Me.Ability[${Canni}]}"
		call MeCasting
	}
}

;================================================
function:bool CombatHeal()
{

	if ${useFastHeal} && ${Me.HealthPct} < ${fastHealPct} && ${Me.Ability[${fastHeal}].IsReady}
	{
		;cast big heal
		Pawn[me]:Target
		Me.Ability[${fastHeal}]:Use
		call DebugIt ". CombatHeal with health at: ${Me.HealthPct}"
		call DebugIt ".  CombatHeal Fast heal: ${Me.Ability[${fastHeal}]} "
		;call MeCasting
		return TRUE
	}

	if ${useBigHeal} && ${Me.HealthPct} < ${bigHealPct} && ${Me.Ability[${bigHeal}].IsReady}
	{
		;cast big heal
		Pawn[me]:Target
		Me.Ability[${bigHeal}]:Use
		call DebugIt ". CombatHeal with health at: ${Me.HealthPct}"
		call DebugIt ".  CombatHeal Big heal: ${Me.Ability[${bigHeal}]} "
		call MeCasting
		return TRUE
	}

	if ${useSmallHeal} && ${Me.HealthPct} < ${smallHealPct} && ${Me.Ability[${smallHeal}].IsReady}
	{
		;cast small heal
		Pawn[me]:Target
		Me.Ability[${smallHeal}]:Use
		call DebugIt ". CombatHeal with health at: ${Me.HealthPct}"
		call DebugIt ".  CombatHeal Small heal: ${Me.Ability[${smallHeal}]} "
		call MeCasting
		return TRUE
	}

	if !${Me.HavePet}
	return FALSE

	if ${Me.Pet.Health} < ${petHealPct} && ${Me.Ability[${petHeal}].IsReady}
	{
		;cast pet heal
		Pawn[pet]:Target
		Me.Ability[${petHeal}]:Use
		call DebugIt ".  CombatHeal PET heal "
		call MeCasting
	}

	return FALSE
}

;================================================
function FeigningDeath()
{
	;call DebugIt "You are in function FeigningDeath"
	if ${DoWeHaveFD} && ${Me.TargetAsEncounter.Difficulty}>${ConCheck} && ${Me.Ability[${FeignDeath}].IsReady} && ${Me.InCombat}
	{
		call runaway
		Me.Ability[${FeignDeath}]:Use
		wait 15
		Me.Form[${neutralFormName}]:ChangeTo
		call DebugIt "D. cleartargets 5 called"
		VGExecute /cleartargets
		return
	}

	if ${DoWeHaveFD} && ${Me.HealthPct}<${FeignDeathAt} && ${Me.Ability[${FeignDeath}].IsReady} && ${Me.InCombat} && (${Me.TargetHealth}>${FightOnAt}) || ${DoWeHaveFD} && ${Me.TargetAsEncounter.Difficulty}>${ConCheck} && !${Me.Effect[${FeignDeath}](exists)} && ${Me.InCombat} && ${Me.Ability[${FeignDeath}].IsReady} || ${Me.HealthPct}>${FeignDeathAt} && ${Me.Ability[${FeignDeath}].IsReady} && ${Me.InCombat} && ${Me.Effect[${FeignDeath}](exists)} || ${Me.Encounter}>0
	{
		VGExecute "/cleartargets"
		Me.Ability[${FeignDeath}]:Use
		wait 15
		Me.Form[${neutralFormName}]:ChangeTo
		return
	}
}

;================================================
function UseMeditation()
{
	;If I meditate, require Jin and use feign death this will put me back in meditation when my health is high and not in agro.
	if !${Me.Effect[${meditationSpell}](exists)} && ${Me.Ability[${meditationSpell}].IsReady} && ${Me.HealthPct} >= ${restHealthPct} && ${Me.Effect[${FeignDeath}](exists)} && !${Me.InCombat}
	{
		;Health is low, meaditate.
		Me.Ability[${meditationSpell}]:Use
		return
	}

	;Meditation now with a Feign Death check
	if ${doUseMeditation} && !${Me.Effect[${meditationSpell}](exists)}&& ${Me.Ability[${meditationSpell}].IsReady} && !${Me.Effect[${FeignDeath}](exists)}
	{
		if ${Me.HealthPct} < ${restHealthPct} || ${Me.Stat["Adventuring","Jin"]} < ${RequiredJin}
		{
			;Health is low, meaditate.
			Me.Ability[${meditationSpell}]:Use
		}
	}
}

;================================================
function Forms()
{
	if ${doUseForms}
	{
		;if !${Me.CurrentForm.Name.Equal[${formName}]} && ${Me.Form[${formName}].IsReady}
		if !${Me.CurrentForm.Name.Equal[${formName}]}
		{
			Me.Form[${formName}]:ChangeTo
			call DebugIt " -- D. Forms: ${Me.Form[${formName}]}"
			return
		}
	}
}

;================================================
function CombatForms()
{
	if ${doUseCombatForms}
	{
		;if !${Me.CurrentForm.Name.Equal[${attackFormName}]} && ${Me.Form[${attackFormName}].IsReady} && ${Me.HealthPct} > ${changeFormPct}
		if !${Me.CurrentForm.Name.Equal[${attackFormName}]} && ${Me.HealthPct} > ${changeFormPct}
		{
			wait 10
			call DebugIt ".CombatForm: attackForm: ${attackFormName}"
			Me.Form[${attackFormName}]:ChangeTo
			wait 10
			return
		}
		;elseif !${Me.CurrentForm.Name.Equal[${defenseFormName}]} && ${Me.Form[${defenseFormName}].IsReady} && ${Me.HealthPct} <= ${changeFormPct}
		elseif !${Me.CurrentForm.Name.Equal[${defenseFormName}]} && ${Me.HealthPct} <= ${changeFormPct}
		{
			wait 10
			call DebugIt ".CombatForm: defenseForm: ${defenseFormName}"
			Me.Form[${defenseFormName}]:ChangeTo
			wait 10
			return
		}
		;elseif !${Me.CurrentForm.Name.Equal[${neutralFormName}]} && ${Me.Form[${neutralFormName}].IsReady}
		;{
		;	call DebugIt ".CombatForm: neutralForm: ${neutralFormName}"
		;	Me.Form[${neutralFormName}]:ChangeTo
		;}
	}
}

;begin add spud

;================================================
function PlayBardSong(string SongType)
{
	;If they don't have a song for combat  or a primary weapon defined I'm pretty much going to ignore songs
	; don't want to take the change of unequiping their weapons, etc. and getting them killed.
	If !${BardCombatSong.Equal[NONE]} && !${PrimaryWeapon.Equal[NONE]}
	{
		Switch "${SongType}"
		{
		Case Combat
			call PlayCombatSong
			break
		Case Travel
			call PlayTravelSong
			break
		Case Rest
			call PlayRestSong
			break
		}
	}
}

;================================================
function PlayCombatSong()
{
	variable int i
	if (${PrimaryWeapon.NotEqual[${Me.Inventory[CurrentEquipSlot,"Primary Hand"].Name}]}) || (${SecondaryWeapon.NotEqual[${Me.Inventory[CurrentEquipSlot,"Secondary Hand"].Name}]})
	{
		;first unequip any items
		call unequipbarditems
		Me.Inventory[ExactName,"${PrimaryWeapon}"]:Equip
		wait 10 ${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)}
		if ${PrimaryWeapon.Equal[${SecondaryWeapon}]}
		{
			;need to loop through and find this item that is 'not' in Primary Hand
			for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
			if (${SecondaryWeapon.Equal[${Me.Inventory[${i}].Name}]}) && (${String["Primary Hand"].NotEqual[${Me.Inventory[${i}].CurrentEquipSlot}]})
			{
				Me.Inventory[${i}]:Equip
				wait 10 ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
			}
		}
		else
		{
			Me.Inventory[ExactName,"${SecondaryWeapon}"]:Equip
			wait 10 ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
		}
	}

	;at this point proper weapons should be equipped, now play our song
	Songs[${BardCombatSong}]:Perform
}

;================================================
function PlayTravelSong()
{
	if (${BardTravelInstrument.NotEqual[${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}]})
	{
		;first unequip any items
		call unequipbarditems
		Me.Inventory[ExactName,"${BardTravelInstrument}"]:Equip
		wait 10 ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
	}

	;at this point proper weapons should be equipped, now play our song
	Songs[${BardTravelSong}]:Perform
}

;================================================
function PlayRestSong()
{
	if (${BardRestInstrument.NotEqual[${Me.Inventory[CurrentEquipSlot,"Two Hands"].Name}]})
	{
		;first unequip any items
		call unequipbarditems
		Me.Inventory[ExactName,"${BardRestInstrument}"]:Equip
		wait 10 ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
	}

	;at this point proper weapons should be equipped, now play our song
	Songs[${BardRestSong}]:Perform
}

;================================================
function unequipbarditems()
{
	if ${Me.Inventory[CurrentEquipSlot,"Two Hands"](exists)}
	{
		Me.Inventory[CurrentEquipSlot,"Two Hands"]:Unequip
		wait 2
	}
	if ${Me.Inventory[CurrentEquipSlot,"Primary Hand"](exists)}
	{
		Me.Inventory[CurrentEquipSlot,"Primary Hand"]:Unequip
		wait 2
	}
	if ${Me.Inventory[CurrentEquipSlot,"Secondary Hand"](exists)}
	{
		Me.Inventory[CurrentEquipSlot,"Secondary Hand"]:Unequip
		wait 2
	}

}

;end add spud

