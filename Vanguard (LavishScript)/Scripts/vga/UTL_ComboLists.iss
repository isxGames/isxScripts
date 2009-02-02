;===================================================
;===            Populate Combo Lists            ====
;===================================================
function PopulateComboLists()
{
	variable int i
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		;===================================================
		;===                 Spell Types                ====
		;===================================================
	 	UIElement[FireACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[IceACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[SpiritualACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[PhysicalACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[ArcaneACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]

		;===================================================
		;===                 Melee Types                ====
		;===================================================
		UIElement[OpeningMeleeSequenceCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CombatMeleeSequenceCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[AOEMeleeCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[DotMeleeCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[DebuffMeleeCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]

		;===================================================
		;===                Evade Types                 ====
		;===================================================
		UIElement[Evade1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[Evade2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[Involn1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[Involn2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[FDCombo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]

			;===================================================
			;===                Chain Types                 ====
			;===================================================
			if ${Me.Ability[${i}].IsChain}
			{
			UIElement[CombatCritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[DotCritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[BuffCritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[AOECritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[CounterAttackCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			}

			;===================================================
			;===                Heal  Types                 ====
			;===================================================
			if ${Me.Ability[${i}].Type.Equal[Spell]}
			{
			UIElement[BuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[hotsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[instantgrouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			}

		;===================================================
		;===             Main Combat Types              ====
		;===================================================
		UIElement[DispellCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[PushStanceCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CounterSpell1Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CounterSpell2Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}

	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		;===================================================
		;===             Clickies Inventory             ====
		;===================================================
		if (${Me.Inventory[${i}].Name(exists)})
		{
			UIElement[ClickiesCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		}
	}
		
}