function LavishEventLoad()
{
	LavishScript:RegisterEvent[VG_OnIncomingCombatText]
	Event[VG_OnIncomingCombatText]:AttachAtom[VG_OnIncomingCombatText]
	LavishScript:RegisterEvent[VG_onGroupMemberAdded]
	Event[VG_onGroupMemberAdded]:AttachAtom[NeedBuffs]
	LavishScript:RegisterEvent[VG_onGroupMemberDeath]
	Event[VG_onGroupMemberDeath]:AttachAtom[NeedBuffs]
	LavishScript:RegisterEvent[VG_onPawnStatusChange]
	Event[VG_onPawnStatusChange]:AttachAtom[VG_onPawnStatusChange]
;	LavishScript:RegisterEvent[VG_onItemCanUseUpdated]
;	Event[VG_onItemCanUseUpdated]:AttachAtom[VG_onItemCanUseUpdated]
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
		ParseDamage:Set[${aText.Mid[${aText.Find[for]},${aText.Length}].Token[2,r].Token[1,d]}]
		}
}
