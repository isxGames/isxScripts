function LavishEventLoad()
{
	Event[VG_OnIncomingCombatText]:AttachAtom[VG_OnIncomingCombatText]
	Event[VG_OnIncomingText]:AttachAtom[VG_OnIncomingText]
	Event[VG_onPawnStatusChange]:AttachAtom[VG_onPawnStatusChange]
	Event[VG_onCombatReaction]:AttachAtom[VG_onCombatReaction]
	Event[VG_onGroupMemberCountChange]:AttachAtom[VG_onGroupMemberCountChange]
	Event[VG_onGroupDisbanded]:AttachAtom[VG_onGroupDisbanded]
	Event[VG_onGroupFormed]:AttachAtom[VG_onGroupFormed]
	Event[VG_onGroupBooted]:AttachAtom[VG_onGroupBooted]
	Event[VG_onGroupMemberAdded]:AttachAtom[NeedBuffs]
	Event[VG_onGroupMemberBooted]:AttachAtom[VG_onGroupMemberBooted]
	Event[VG_onGroupMemberDeath]:AttachAtom[NeedBuffs]
	Event[VG_onPawnSpawned]:AttachAtom[VG_onPawnSpawned]

	;Event[VG_onItemCanUseUpdated]:AttachAtom[VG_onItemCanUseUpdated]
}
;===================================================
;===                 Interactions               ====
;===================================================
atom VG_OnIncomingText(string Text, string ChannelNumber, string ChannelName)
{
	if ${ChannelNumber.Equal[42]} && ${Text.Find[Your auto-follow target has moved too far away]}
		IsFollowing:Set[FALSE]
	if ${ChannelNumber.Equal[42]} && ${Text.Find[You have lost your auto-follow target]}
		IsFollowing:Set[FALSE]
	if ${DoReassistTank}
	{
		if ${ChannelNumber.Equal[8]} &&  ${Text.Find[${ReassistingTank}]}
		{
			VGExecute /TargetNextNPC

		}
	}
	if ${DoKillLevitate}
	{
		if ${ChannelNumber.Equal[8]} &&  ${Text.Find[${KillingLevitate}]}
		{
			Me.Effect[Gift of Alcipus]:Remove
			Me.Effect[Death March]:Remove
			Me.Effect[Briel's Trill of the Clouds]:Remove
			Me.Effect[Boon of Alcipus]:Remove
		}
	}
	if ${DoStartFollow}
	{
		if ${ChannelNumber.Equal[8]} &&  ${Text.Find[${StartFollowtxt}]}
		{
			dofollowpawn:Set[TRUE]
			UIElement[dofollowcheck@MainCFrm@MainT@MainSubTab@MainFrm@Main@ABot@vga_gui]:SetChecked
			if !${IsFollowing}
				{
				Pawn[${followpawn}]:Target
				VGExecute /follow ${followpawn}
				IsFollowing:Set[TRUE]
				}
		}
	}
	if ${DoStopFollow}
	{
		if ${ChannelNumber.Equal[8]} &&  ${Text.Find[${StopFollowtxt}]}
		{
			dofollowpawn:Set[FALSE]
			UIElement[dofollowcheck@MainCFrm@MainT@MainSubTab@MainFrm@Main@ABot@vga_gui]:UnsetChecked
			if ${IsFollowing}
				{
				VGExecute /follow ${followpawn}
				IsFollowing:Set[FALSE]
				}
		}
	}
	if ${doAutoSell}
	{
		if ${ChannelNumber.Equal[0]} &&  ${Text.Find[You sell]}
		{
			variable string FindSell
			FindSell:Set[${Text.Mid[9,${Math.Calc[${Text.Length}-9]}]}]
			if ( ${FindSell.Length} > 1 )
			{
				LavishSettings[VGA_General].FindSet[Sell]:AddSetting[${FindSell}, ${FindSell}]

			}
			else
			{
				return
			}
			variable iterator Iterator
			Sell:GetSettingIterator[Iterator]
			UIElement[SellList@SellFrm@Sell@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
			while ( ${Iterator.Key(exists)} )
			{
				UIElement[SellList@SellFrm@Sell@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
				Iterator:Next
			}
		}
	}
	if ${doFurious}
	{
		if ${Text.Find[becomes FURIOUS]}
		{
			actionlog "Mob is Furious"
			mobisfurious:Set[TRUE]
		}
		if ${Text.Find[no longer FURIOUS]}
		{
			actionlog "Mob Says Not Furious"
			mobisfurious:Set[FALSE]
		}
	}
	if ${DoAcceptRes} && ${ChannelNumber.Equal[32]} && ${Text.Find[is trying to resurrect you with]}
		{
		variable string who
		who:Set[${Text.Mid[1,${Math.Calc[${Text.Length}-${Math.Calc[${Text.Length}-${Text.Find[is ]}+2]}]}]}]
		call CheckFriend "${who}"
		if ${Return}
			{
			VGExecute /reza
			Script[VGA]:QueueCommand[call TSLoot]
			}
		}

}
atom VG_onPawnSpawned(string ChangeType, int64 PawnID, string PawnName)
{
	if ${DoRushTank}
	{
		call RushTank
	}
}
atom VG_onPawnStatusChange(string ChangeType, int64 PawnID, string PawnName)
{
	variable string IDPawn
	IDPawn:Set[${PawnID}]
	;echo "Pawn Status Change ${ChangeType}, ${PawnID}, ${Me.Target.ID}"
	if ${IDPawn.Equal[${Me.Target.ID}]} && ${ChangeType.Equal[NowDead]}
	{
		EndAttackTime:Set[${Script.RunningTime}]

		variable int TimeFought
		TimeFought:Set[${Math.Calc[${EndAttackTime}-${StartAttackTime}]}]
		ParseLog "---------------------------------------"
		ParseLog "Battle Duration ${Math.Calc[${TimeFought}/1000]} seconds"
		ParseLog "Damage: ${DamageDone} || DPS: ${Math.Calc[${DamageDone}/${Math.Calc[${TimeFought}/1000]}].Round}"
		ParseLog " "
		ParseLog " "
		UIElement[ParseList@MainCFrm@MainT@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem["DPS: ${Math.Calc[${DamageDone}/${Math.Calc[${TimeFought}/1000]}].Round} | Dmg: ${DamageDone}"]
		ParseCount:Inc
	}
}
atom VG_OnIncomingCombatText(string aText, int aType)
{
	;-----------------------------------------
	; Automatically learn a mob resistance
	;-----------------------------------------
	if ${aType} == 28 && ${aText.Find[${Me.Target.Name}]} && ${aText.Find[heals]}
	{
		;echo "${aText.Token[2,">"].Token[1,"<"]} healed ${Me.Target.Name}"
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Arcane]}
		{
			AddArcane "${Me.Target.Name}"
			BuildArcane
			Call LavishSave
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Physical]}
		{
			AddPhysical "${Me.Target.Name}"
			BuildPhysical
			Call LavishSave
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Spiritual]}
		{
			AddSpiritual "${Me.Target.Name}"
			BuildSpiritual
			Call LavishSave
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Fire]}
		{
			AddFire "${Me.Target.Name}"
			BuildFire
			Call LavishSave
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Ice]}
		{
			AddIce "${Me.Target.Name}"
			BuildIce
			Call LavishSave
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Cold]}
		{
			AddIce "${Me.Target.Name}"
			BuildIce
			Call LavishSave
		}
	}

	if ${doParser}
	{
		if ${aType} == 26 && !${aText.Find[damage to You]}
		{
			call Parser "${aText}"
		}
	}
}
function Parser(string aText)
{
	call TextSplitter "${aText}"
	ParseLog "${ParseAbility} | dmg ${ParseDamage} | time ${Math.Calc[${Script.RunningTime}/1000].Precision[3]}"
	DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
	;echo "${ParseAbility} || ${ParseDamage} || ${aText}"
}
function TextSplitter(string aText)
{
	if ${aText.Find[Asaya's Scorn]}
	{
		ParseAbility:Set[Asaya's Scorn]
		ParseDamage:Set[0]
	}
	if ${aText.Find[<blue>You wipe]}
	{
		ParseAbility:Set[Memory Wipe]
		ParseDamage:Set[0]
	}
	if ${aText.Find[You exploit]}
	{
		ParseAbility:Set[Exploit Bonus]
		ParseDamage:Set[0]
	}
	if ${aText.Find[Critical Hit]}
	{
		ParseAbility:Set[Critical Hit]
		if ${aText.Find[additional <highlight>]}
		{
			ParseDamage:Set[${aText.Mid[${aText.Find[an additional <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
		}
	}
	if ${aText.Find[Epic]}
	{
		ParseAbility:Set[Critical Hit]
		if ${aText.Find[additional <highlight>]}
		{
			ParseDamage:Set[${aText.Mid[${aText.Find[an additional <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
		}
	}

	if ${aText.Find[</color> deals]} || ${aText.Find[</color> hits]}
	{
		ParseAbility:Set[${aText.Token[2,">"].Token[1,"<"]}]
		if ${aText.Find[for <highlight>]}
		{
			ParseDamage:Set[${aText.Mid[${aText.Find[for <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
		}
		if ${aText.Find[deals <highlight>]}
		{
			ParseDamage:Set[${aText.Mid[${aText.Find[deals <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
		}
	}
	elseif ${aText.Find[damage shield]}
	{
		ParseAbility:Set["Damage Shield"]
		ParseDamage:Set[${aText.Mid[${aText.Find[for]}	,${aText.Length}].Token[2,r].Token[1,d]}]
	}
}



atom VG_onCombatReaction(string aType, int64 iPawnID, uint iAbilityID, float fTimer)
{
	;echo "VG_onCombatReaction(${aType},${iPawnID} (${Pawn[id,${iPawnID}].Name}),${iAbilityID} (${Me.Ability[id,${iAbilityID}].Name}),${fTimer})"

	if ${aType.Equal[Counter]}
	{
		CounterReactionReady:Set[TRUE]
		CounterReactionTimer:Set[${Math.Calc64[${Time.Timestamp}+${fTimer}]}]
		CounterReactionPawnID:Set[${iPawnID}]
		CounterReactionAbilities:Insert[${iAbilityID}]
		return
	}
	elseif ${aType.Equal[Chain]}
	{
		ChainReactionReady:Set[TRUE]
		ChainReactionTimer:Set[${Math.Calc64[${Time.Timestamp}+${fTimer}]}]
		ChainReactionPawnID:Set[${iPawnID}]
		ChainReactionAbilities:Insert[${iAbilityID}]
		return
	}
}

function PopulateGroupMemberNames()
{
	variable int i = 1
	variable int j = 2

	;; Always make 'Me' first
	GrpMemberNames[1]:Set[${Me.FName}]

	do
	{
		if ${Group[${i}](exists)}
		{
			if !${Group[${i}].Name.Equal[${Me.FName}]}
			{
				GrpMemberNames[${j}]:Set[${Group[${i}].Name}]
				;echo "VGA-Debug: PopulateGroupMemberNames() - ${i}. ${GrpMemberNames[${j}]}"
				j:Inc
			}
		}
		else
		{
			GrpMemberNames[${j}]:Set[Empty]
			j:Inc
		}
	}
	while ${i:Inc} <= 24

}

function PopulateGroupMemberClassType()
{
	variable int i = 1

	do
	{
		if ${Group[${i}](exists)}
		{
			if ${Group[${i}].Class.Equal[Warrior]} || ${Group[${i}].Class.Equal[Paladin]} || ${Group[${i}].Class.Equal[Dread Knight]}
			GrpMemberClassType[${i}]:Set[Tank]
			if ${Group[${i}].Class.Equal[Blood Mage]} || ${Group[${i}].Class.Equal[Sorcerer]} || ${Group[${i}].Class.Equal[Necromancer]} || ${Group[${i}].Class.Equal[Psionicist]} || ${Group[${i}].Class.Equal[Druid]}
			GrpMemberClassType[${i}]:Set[Squishy]
			if ${Group[${i}].Class.Equal[Ranger]} || ${Group[${i}].Class.Equal[Rogue]} || ${Group[${i}].Class.Equal[Monk]} || ${Group[${i}].Class.Equal[Bard]} || ${Group[${i}].Class.Equal[Cleric]} || ${Group[${i}].Class.Equal[Disciple]} || ${Group[${i}].Class.Equal[Shaman]}
			GrpMemberClassType[${i}]:Set[Medium]
		}
	}
	while ${i:Inc} <= 24

}
atom VG_onGroupMemberCountChange()
{
	call PopulateGroupMemberNames
	call PopulateGroupMemberClassType
}

atom VG_onGroupDisbanded()
{
	call PopulateGroupMemberNames
	call PopulateGroupMemberClassType
}

atom VG_onGroupFormed()
{
	call PopulateGroupMemberNames
	call PopulateGroupMemberClassType
}

atom VG_onGroupBooted()
{
	call PopulateGroupMemberNames
	call PopulateGroupMemberClassType
}

atom VG_onGroupMemberBooted()
{
	call PopulateGroupMemberNames
	call PopulateGroupMemberClassType
}

