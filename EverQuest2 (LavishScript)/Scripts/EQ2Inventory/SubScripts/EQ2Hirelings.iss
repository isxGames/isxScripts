variable int GathererTier
variable int HunterTier
variable int MinerTier
variable int StartTime
variable int StopTime
variable int RunTime
variable int TripCount
variable bool RunHirelings=TRUE

function main()
{
	RunTime:Set[${Time.Timestamp}]
		TripCount:Set[0]
	UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Sending Hirelings to Harvest.]
	
	do
	{
		GathererTier:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[EQ2Hirelings].GetString[GathererTierNumber]}]
		HunterTier:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[EQ2Hirelings].GetString[HunterTierNumber]}]
		MinerTier:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[EQ2Hirelings].GetString[MinerTierNumber]}]
	
		if ${UIElement[GathererHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Gatherer"]:DoTarget
			wait 10
			Actor[guild,"Guild Gatherer"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${GathererTier}]:LeftClick
			wait 10
		}
		if ${UIElement[HunterHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Hunter"]:DoTarget
			wait 10
			Actor[guild,"Guild Hunter"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${HunterTier}]:LeftClick
			wait 10
		}
		if ${UIElement[MinerHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Miner"]:DoTarget
			wait 10
			Actor[guild,"Guild Miner"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${MinerTier}]:LeftClick
			wait 10
		}
		StartTime:Set[${Time.Timestamp}]
		wait 5
		StopTime:Set[${Math.Calc64[${StartTime}+7260]}]
		wait 5
		UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Waiting for Hirelings to Return.]
		wait 5
		do
		{
			UIElement[RuntimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[${Math.Calc[(${Time.Timestamp}-${RunTime})/60].Precision[2]} min.]
		 	UIElement[WaittimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[${Math.Calc[(${StopTime}-${Time.Timestamp})/60].Precision[2]} min.]
			
			if !${RunHirelings}
			{
				UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
				UIElement[RuntimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[ ]
				UIElement[WaittimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[ ]	
				wait 5
				EndScript EQ2Hirelings
			}
			if !${Script[EQ2Inventory](exists)}
			{
				echo EQ2Inventory Exited Ending Hirelings
				EndScript EQ2Hirelings
			}
		}
		while ${Math.Calc64[(${StopTime}-${Time.Timestamp}]} > 0 && ${RunHirelings} && ${Script[EQ2Inventory](exists)}
		
		if !${RunHirelings}
		{
			UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
			UIElement[RuntimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[ ]
		 	UIElement[WaittimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[ ]	
			wait 5
			EndScript EQ2Hirelings
		}
		
		if ${UIElement[GathererHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Gatherer"]:DoTarget
			wait 10
			Actor[guild,"Guild Gatherer"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			wait 10
		}
		if ${UIElement[HunterHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Hunter"]:DoTarget
			wait 10
			Actor[guild,"Guild Hunter"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			wait 10
		}
		if ${UIElement[MinerHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Miner"]:DoTarget
			wait 10
			Actor[guild,"Guild Miner"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			wait 10
		}
		TripCount:Inc
		wait 5
		UIElement[TripText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[${TripCount}]
		
		if ${UIElement[UseHarvestDepot@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Adding Items to Supply Depot.]
			wait 5
			Script[eq2inventory]:QueueCommand[call AddToDepot]
		}
		UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Sending Hirelings to Harvest.]
		wait 5
	}
	while ${RunHirelings}
	wait 5
	UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
}
