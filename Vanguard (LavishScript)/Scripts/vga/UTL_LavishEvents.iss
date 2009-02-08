function LavishEventLoad()
{
	Event[VG_OnIncomingCombatText]:AttachAtom[VG_OnIncomingCombatText]
	Event[VG_onPawnStatusChange]:AttachAtom[VG_onPawnStatusChange]
	Event[VG_onCombatReaction]:AttachAtom[VG_onCombatReaction]
	Event[VG_onGroupMemberCountChange]:AttachAtom[VG_onGroupMemberCountChange]
	Event[VG_onGroupDisbanded]:AttachAtom[VG_onGroupDisbanded]
	Event[VG_onGroupFormed]:AttachAtom[VG_onGroupFormed]
	Event[VG_onGroupBooted]:AttachAtom[VG_onGroupBooted]
	Event[VG_onGroupMemberAdded]:AttachAtom[NeedBuffs]
	Event[VG_onGroupMemberBooted]:AttachAtom[VG_onGroupMemberBooted]
	Event[VG_onGroupMemberDeath]:AttachAtom[NeedBuffs]
	
	;Event[VG_onItemCanUseUpdated]:AttachAtom[VG_onItemCanUseUpdated]
}
/*atom VG_onItemCanUseUpdated(string ItemName, int ItemID, string IsNowReady)
{
	;If ${fight.ShouldIAttack}
	;{
	echo "${ItemName} Updated"
	if ${doClickies}
		{
		variable iterator Iterator
		Clickies:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
			echo "Checking ${Iterator.Key} against ${ItemName} which ${IsNowReady}"
			if ${Me.Inventory[${Iterator.Key}].Equal[${ItemName}]} && ${IsNowReady}
			{
				Me.Inventory[${Iterator.Key}]:Use
				actionlog "Using Item ${Iterator.Key}"
				Iterator:Next
			}
			if !${Me.Inventory[${Iterator.Key}].Equal[${ItemName}]} || !${IsNowReady}
				Iterator:Next
			}
		}
	;}
}
*/
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
		CounterReactionAbilityID:Set[${iAbilityID}]
		return
	}
	elseif ${aType.Equal[Chain]}
	{
		ChainReactionReady:Set[TRUE]
		ChainReactionTimer:Set[${Math.Calc64[${Time.Timestamp}+${fTimer}]}]
		ChainReactionPawnID:Set[${iPawnID}]
		ChainReactionAbilityID:Set[${iAbilityID}]
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

atom VG_onGroupMemberCountChange()
{
	call PopulateGroupMemberNames
}

atom VG_onGroupDisbanded()
{
	call PopulateGroupMemberNames
}

atom VG_onGroupFormed()
{
	call PopulateGroupMemberNames
}

atom VG_onGroupBooted()
{
	call PopulateGroupMemberNames	
}

atom VG_onGroupMemberBooted()
{
	call PopulateGroupMemberNames	
}