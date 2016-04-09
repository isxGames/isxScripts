/*******************************************
*   EQ2CraftSearch By Noob536
*   
*   V. 2010.02.27
*   
*   EQ2CraftSearch allow you to search for recipies in craft
*   EQ2CraftSearch will search in whatever is in the Craft recipies dropdown menu
*   
*   Usage:
*   Use Crafts options to specify level range, rare, etc. then hit refresh
*   Search for All words or any in the string! 
*   Results will be in the Craft dropdown menu
*   
********************************************/

/****************************************************
 *  MODIFIED BY Valerian FOR INCLUSION INTO CRAFT.  *
 ****************************************************/
objectdef _CraftSearch
{
	variable int listID
	variable int searchStringID
	variable int resetButtonID

	method InitSearchWindow()
	{
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
		ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2Craft/UI/CraftSearch.xml"
		This.listID:Set[${UIElement[Craft Selection].FindUsableChild[Recipe List,combobox].ID}]
		This.resetButtonID:Set[${UIElement[Craft Selection].FindUsableChild[Refresh List,button].ID}]
		This.searchStringID:Set[${UIElement[CraftSearch].FindUsableChild[Search String,textentry].ID}]
	}
	method ToggleVisible()
	{
		UIElement[CraftSearch]:ToggleVisible
	}
	method Hide()
	{
		UIElement[CraftSearch]:Hide
	}
	method Show()
	{
		UIElement[CraftSearch]:Show
	}
	method Reset()
	{
		UIElement[${This.resetButtonID}]:LeftClick
		UIElement[${This.searchStringID}]:SetText[""]
	}
	method Search(string searchMode)
	{
		variable int i
		variable int j
		variable bool fail
		variable int numTokens
		variable string searchString
		variable int totalItems
		variable index:string itemList
		variable string itemText
		variable int itemValue
		variable collection:int foundItems

		searchString:Set[${UIElement[${This.searchStringID}].Text}]

		numTokens:Set[${searchString.Count[" "]}]
		numTokens:Inc
		totalItems:Set[${UIElement[${This.listID}].Items}]

		for( i:Set[1]; ${i} <= ${totalItems}; i:Inc )
		{
			itemText:Set["${UIElement[${This.listID}].Item[${i}].Text}"]
			itemValue:Set["${UIElement[${This.listID}].Item[${i}].Value}"]
			
			fail:Set[FALSE]
			for( j:Set[1]; ${j} <= ${numTokens}; j:Inc )
			{
				;Skip if noobs leave extra spaces
				if ${searchString.Token[${j}," "].Equal[""]}
					continue
				
				if ${searchMode.Equal[ALL]}
				{
					if !${itemText.Find[${searchString.Token[${j}," "]}]}
					{
						fail:Set[TRUE]
						continue
					}
				}
				if ${searchMode.Equal[ANY]}
				{
					if ${itemText.Find[${searchString.Token[${j}," "]}]}
					{
						foundItems:Set["${itemText}",${itemValue}]
						continue
					}
				}  
			}
			if ${searchMode.Equal[ALL]} && !${fail}
			{
				foundItems:Set["${itemText}",${itemValue}]
			}
		}
		UIElement[${This.listID}]:ClearItems
		if ${foundItems.FirstKey(exists)}
			{
				do
				{
					UIElement[${This.listID}]:AddItem["${foundItems.CurrentKey}","${foundItems.CurrentValue}"]
					
				}
				while "${foundItems.NextKey(exists)}"
			}
		
		if ${UIElement[${This.listID}].Items} > 0
			UIElement[${This.listID}]:SelectItem[1]
			
	}
	method Shutdown()
	{
		ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Craft/UI/CraftSearch.xml"
	}
}

