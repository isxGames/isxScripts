;********************************************
/* Add item to the Diplo list */
;********************************************
atom(global) AddDiploNPCs(string aName)
{
	if ( ${aName.Length} > 1 )
	{

			LavishSettings[VGA_Diplo].FindSet[DiploNPCs]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDiploNPCs(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DiploNPCs.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDiploNPCs()
{
	variable iterator Iterator
	DiploNPCs:GetSettingIterator[Iterator]
	UIElement[DiploNPCsList@DiploCFrm@Diplo@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DiploNPCsList@DiploCFrm@Diplo@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
function FindDiploList(string aName)
{
	if ( ${aName.Length} > 1 ) && ${Pawn[${aName}].Distance} < 10
	{
		Pawn[${aName}]:Target
		call CheckPosition
		variable int Dint
		Dint:Set[1]
		UIElement[cmbDiploList@DiploCFrm@Diplo@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems

		Pawn[${Me.Target}]:DoubleClick
		wait 5
		if ${Dialog[Civic Diplomacy].ResponseCount} > 0
		Do
			{
			if !${Dialog[Civic Diplomacy,${Dint}].Text.Equal[General Options]}
				UIElement[cmbDiploList@DiploCFrm@Diplo@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Dialog[Civic Diplomacy,${Dint}].Text.Left[${Math.Calc[${Dialog[Civic Diplomacy,${Dint}].Text.Find[<nl>]}-2]}]}]
			}
		while ${Dint:Inc} <= ${Dialog[Civic Diplomacy].ResponseCount} 
	}
}
atom(global) AddDiplo(string aNPC, string aName)
{
	if ( ${aName.Length} > 1 && ${aName.NotEqual[NULL]} )
	{
		LavishSettings[VGA_Diplo].FindSet[Diplo]:AddSetting[${aName} ${aNPC}, ${aName}]
		LavishSettings[VGA_Diplo].FindSet[Diplo].FindSetting[${aName} ${aNPC}]:AddAttribute["NPC",${aNPC}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDiplo(string aNPC, string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Diplo].FindSet[Diplo].FindSetting[${aName} ${aNPC}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDiplo(string aNPC)
{
	variable iterator Iterator
	Diplo:GetSettingIterator[Iterator]
	UIElement[DiploList@DiploCFrm@Diplo@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		if ${LavishSettings[VGA_Diplo].FindSet[Diplo].FindSetting[${Iterator.Key}].FindAttribute[NPC].String.Equal["${aNPC}"]}
			{
			UIElement[DiploList@DiploCFrm@Diplo@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Value}]
			}
		Iterator:Next
	}
}
