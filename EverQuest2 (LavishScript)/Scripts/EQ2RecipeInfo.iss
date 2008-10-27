;---------------------------------------
;version 1.1
;Written by: southrngurl and cr4zyb4rd
;
;Changelog 1.1 - Fixed a small bug preventing component searches from working
;---Description--
;Generates text file containing recipe details
;User defines types of recipes and level range, as well file name using the UI 
variable filepath UIPath="${LavishScript.HomeDirectory}/Scripts/UI/"
variable bool StartProcessing=FALSE
variable bool match
variable int RecipeCount
variable string FileName


function main()
{
	variable int i
	;file name will be CharacterName_recipes.txt and will output to scripts folder,if unchanged in UI
	FileName:Set["${Me.Name}_recipes.txt"]
	; Open up the recipe window initially.  That loads up most of the recipe information
	EQ2Execute /toggletradeskills
	wait 10
	EQ2Execute /toggletradeskills
	;Intialize the UI
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/EQ2.xml"
	ui -reload -skin eq2 "${UIPath}EQ2RecipeInfoGUI.xml"
	;Loop that does not end so that more than one batch may be run
	while 1
	{
		;Waits for user to make selections and press Start
		while !${StartProcessing}
		{
					wait 5
		}
		;Resetting two variables to original state when running more than one batch
		StartProcessing:Set[FALSE]
		RecipeCount:Set[0]
		;Get file name set by user
		FileName:Set[${UIElement[FileName@RecipeSelector@RecipeInfo].Text}]
		;this will start a new file or overwrite the existing
		redirect ${If[${UIElement[Append@RecipeSelector@RecipeInfo].Checked},"-append ",]}${FileName} echo Total Number of Recipes: ${Me.NumRecipes}\n-----\n
		;Sets the range for the progress slider
		UIElement[RecipeProgressGauge@Progress@RecipeInfo]:SetRange[${Me.NumRecipes}]
		i:Set[0]
		while ${i:Inc} <= ${Me.NumRecipes}
		{
			;Sets value for progress slider
			UIElement[RecipeProgressGauge@Progress@RecipeInfo]:SetValue[${i}]
			;Checks Levels set in UI against recipe level in book
			if ${Me.Recipe[${i}].Level}<${UIElement[RiMinLevel@RecipeSelector@RecipeInfo].Text} || ${Me.Recipe[${i}].Level}>${UIElement[RiMaxLevel@RecipeSelector@RecipeInfo].Text}
				continue
			;Checks for the type of recipe as selected by user, and restarts the loop if conditions not met
			switch "TRUE"
			{
				variablecase ${UIElement[PresetCheckBox@RecipeSelector@RecipeInfo].Checked}
					switch ${UIElement[Preset Combobox@RecipeSelector@RecipeInfo].SelectedItem.Order}
					{
						case 0
							break
						case 1
							if !${Me.Recipe[${i}].Name.Lower.Find[adept]}
								continue
							break
						case 2
							if !(!${Me.Recipe[${i}].Name.Lower.Find[hex doll]} && ${Me.Recipe[${i}].Name.Lower.Find[imbue]})
								continue
							break
						case 3
							if !${Me.Recipe[${i}].Name.Lower.Find[hex doll]}
								continue
							break
					}
					break
				variablecase ${UIElement[CustomCheckbox@RecipeSelector@RecipeInfo].Checked}
					if !${Me.Recipe[${i}].Name.Lower.Find[${UIElement[CustomText@RecipeSelector@RecipeInfo].Text}]}
							continue
						break
				variablecase ${UIElement[PrimaryComponentCheckbox@RecipeSelector@RecipeInfo].Checked}
					while (${Me.Recipe[${i}].PrimaryComponent.Length} == 0)
					{
						Me.Recipe[${i}]:Examine
						wait 3
						EQ2Execute /close_top_window
						EQ2Execute /close_top_window
						wait 3
					}				
					if !${Me.Recipe[${i}].PrimaryComponent.Lower.Find[UIElement[PrimaryComponentText@RecipeSelector@RecipeInfo].Text]}
						continue
					break	
			}
			while (${Me.Recipe[${i}].PrimaryComponent.Length} == 0)
			{
				Me.Recipe[${i}]:Examine
				wait 3
				EQ2Execute /close_top_window
				EQ2Execute /close_top_window
				wait 3
			}
			redirect -append ${FileName} echo Recipe #${i}: ${Me.Recipe[${i}].Name}
			call HandleMember ${i} Level
			call HandleMember ${i} Description
			call HandleMember ${i} Device
			call HandleMember ${i} RecipeBook
			call HandleMember ${i} Technique
			call HandleMember ${i} Knowledge
			call HandleMember ${i} PrimaryComponent
			call HandleMember ${i} BuildComponent1
			call HandleMember ${i} BuildComponent2
			call HandleMember ${i} BuildComponent3
			call HandleMember ${i} BuildComponent4
			call HandleMember ${i} Fuel
			redirect -append ${FileName} echo \n\n
			RecipeCount:Inc
		}
		redirect -append ${FileName} echo Total Matching Recipes Found ${RecipeCount}\n
		announce "Pizza Ready!" 3 3
		UIElement[RecipeSelector@RecipeInfo]:ToggleVisible
		UIElement[Progress@RecipeInfo]:ToggleVisible
		UIElement[Done@RecipeSelector@RecipeInfo]:Show			
	}
}
function HandleMember(int i, string myMember)
{
	if ${UIElement[${myMember}@RecipeSelector@RecipeInfo].Checked}
		squelch redirect -append ${FileName} echo ${myMember}: ${Me.Recipe[${i}].${myMember}}${If[${Me.Recipe[${i}].${myMember}.Quantity}, (Quantity: ${Me.Recipe[${i}].${myMember}.Quantity}),]}
}
atom atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
	ui -unload "${UIPath}EQ2RecipeInfoGUI.xml"
}