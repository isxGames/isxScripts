;********************************************
/* Add item to the Quests list */
;********************************************
atom(global) AddQuestNPCs(string aName)
{
	if ( ${aName.Length} > 1 )
	{

			LavishSettings[VGA_Quests].FindSet[QuestNPCs]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveQuestNPCs(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		QuestNPCs.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildQuestNPCs()
{
	variable iterator Iterator
	QuestNPCs:GetSettingIterator[Iterator]
	UIElement[QuestNPCsList@QuestsCFrm@Quests@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[QuestNPCsList@QuestsCFrm@Quests@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
function FindQuestList(string aName)
{
	if ( ${aName.Length} > 1 ) && ${Pawn[${aName}].Distance} < 10
	{
		Pawn[${aName}]:Target
		call CheckPosition
		variable int Dint
		Dint:Set[1]
		UIElement[cmbQuestList@QuestsCFrm@Quests@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems

		Pawn[${Me.Target}]:DoubleClick
		wait 10
		Do
		{
		UIElement[cmbQuestList@QuestsCFrm@Quests@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Dialog[General,${Dint}]}]
		}
		while ${Dint:Inc} <= ${Dialog[General].ResponseCount} 
	}
}
atom(global) AddQuests(string aNPC, string aName)
{
	if ( ${aName.Length} > 1 && ${aName.NotEqual[NULL]} )
	{
		LavishSettings[VGA_Quests].FindSet[Quests]:AddSetting[${aName}, ${aName}]
		if ${aName.Right[${Math.Calc[6]}].Equal["group)"]}
			{
			LavishSettings[VGA_Quests].FindSet[Quests]:AddSetting[${aName}, ${aName.Left[${Math.Calc[${aName.Length}-8]}]}]
			}
		if ${aName.Right[${Math.Calc[6]}].Equal["(solo)"]}
			{
			LavishSettings[VGA_Quests].FindSet[Quests]:AddSetting[${aName}, ${aName.Left[${Math.Calc[${aName.Length}-6]}]}]
			}
		LavishSettings[VGA_Quests].FindSet[Quests].FindSetting[${aName}]:AddAttribute["NPC",${aNPC}]
	}
	else
	{
		return
	}
}
atom(global) RemoveQuests(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Quests].FindSet[Quests].FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildQuests(string aNPC)
{
	variable iterator Iterator
	Quests:GetSettingIterator[Iterator]
	UIElement[QuestsList@QuestsCFrm@Quests@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		if ${LavishSettings[VGA_Quests].FindSet[Quests].FindSetting[${Iterator.Key}].FindAttribute[NPC].String.Equal["${aNPC}"]}
			{
			UIElement[QuestsList@QuestsCFrm@Quests@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
			}
		Iterator:Next
	}
}
