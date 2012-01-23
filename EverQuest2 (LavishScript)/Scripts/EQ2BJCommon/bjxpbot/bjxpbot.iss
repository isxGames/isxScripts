;// BJ XP Bot
;// First Created:  June 22, 2011
;// Written By: bjcasey
;// Many thanks to Kannkor for a TON of coding help.

;// Auto Potion Consume Variables
variable string ItemToUse=None
variable bool bPaused=${Paused}
variable int timeuntilnext
variable(global) TimerObject timeuntilnextmilli
variable settingsetref BJXPBot_Settings
variable settingsetref _ref
variable filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"



function main()
{
	;// Load Settings
	LavishSettings:AddSet[BJXPBot]
	LavishSettings[BJXPBot]:Clear
	LavishSettings[BJXPBot]:AddSet[BJXPBot_Settings]
	LavishSettings[BJXPBot]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"]
	_ref:Set[${LavishSettings.FindSet[BJXPBot]}]
	
	;// Start of Auto Potion Consume		

		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
		
	if ${UserEndTimeVar} <= 24
	{
		if ${Time.Hour} == ${UserEndTimeVar}
		{
			echo ${Time}: Your end time can't be equal to your current time.
			statusvar:Set["End time can't be equal to your current time."]
			UIElement[${timerunningvar}]:Hide
			UIElement[${timerunningvar2}]:Show
			UIElement[${startclickervar}]:Show
			UIElement[${stopclickervar}]:Hide
			endscript xpcalclevel
			endscript bjxpbot
		}
		echo ${Time}: Starting Auto Xp Potion Script
		
		while ${Time.Hour} != ${UserEndTimeVar}
		{
			Me:CreateCustomInventoryArray[nonbankonly]
			
			timeuntilnext:Set[${Math.Rand[300000]:Inc[600000]}]
		
			;// 300000 = 5 Minutes
			;// 600000 = 10 Minutes
			;// Time range is 10 Minutes to 15 Minutes.
		
			timeuntilnextmilli:Set[${timeuntilnext}]
			
			if ${UIElement[${EnableLevelLimitCheckboxVar}].Checked}
			{	
				if ${Me.Level} >= ${LevelAdvLimitVar} || ${Me.TotalEarnedAPs} >= ${LevelAALimitVar}
				{
					echo ${Time}: Level limit reached.
					statusvar:Set["Level limit reached."]
					UIElement[${timerunningvar}]:Hide
					UIElement[${timerunningvar2}]:Show
					UIElement[${startclickervar}]:Show
					UIElement[${stopclickervar}]:Hide
					endscript xpcalclevel
					endscript bjxpbot
				}
			}		
					if ${Me.Level} != 90 || ${Me.TotalEarnedAPs} != 320
					{	
						wait !${Me.InCombat} && !${Me.CastingSpell}
						
						if ${UIElement[${EnableVitalityPotionsCheckboxVar}].Checked}
						{						
							echo ${Time}: Checking Vitality
							statusvar:Set["Checking Vitality"]
							wait 30
							if ${Me.CustomInventory[Orb of Concentrated Memories](exists)}  && ${Me.CustomInventory[Orb of Concentrated Memories].IsReady} && ${Me.Vitality} == 0
							{
								echo ${Time}: Orb of Concentrated Memories Detected
								statusvar:Set["Orb of Concentrated Memories Detected"]
								if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
									Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								wait 30
								ItemToUse:Set[Orb of Concentrated Memories]
								Me.Inventory[exactitem,${ItemToUse}]:Use
								wait 10
								if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Orb of Concentrated Memories](exists)}
								{	
									echo ${Time}: Orb of Concentrated Memories Consumed
									statusvar:Set["Orb of Concentrated Memories Consumed"]
									lastpotion:Set["Orb of Concentrated Memories"]
									lastpotiontime:Set[${Time}]
								}
								wait 30
								if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
									Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
							}		
							elseif ${Me.CustomInventory[Potion of Vitality](exists)}  && ${Me.Vitality} == 0
							{
								echo ${Time}: Potion of Vitality Detected
								statusvar:Set["Potion of Vitality Detected"]
								if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
									Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								wait 30
								ItemToUse:Set[Potion of Vitality]
								Me.Inventory[exactitem,${ItemToUse}]:Use
								wait 10
								if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Rested Mind and Body](exists)}
								{
									echo ${Time}: Potion of Vitality Consumed
									statusvar:Set["Potion of Vitality Consumed"]
									lastpotion:Set["Potion of Vitality"]
									lastpotiontime:Set[${Time}]
								}
								wait 30
								if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
									Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
							}
						}			
						if ${UIElement[${enablepotionscheckboxvar}].Checked}
						{							
							if 	${Me.CustomInventory[Superior Potion of the Advanced](exists)} || ${Me.CustomInventory[Potion of the Prodigal](exists)} || ${Me.CustomInventory[Drink of the Wise](exists)} || \
								${Me.CustomInventory[EQII Fortune League Experience Potion](exists)} || ${Me.CustomInventory[Draught of the Wise](exists)} || ${Me.CustomInventory[Draft of the Wise](exists)} || \
								${Me.CustomInventory[Draft of the Skilled](exists)} || ${Me.CustomInventory[Draft of the Sage](exists)} || ${Me.CustomInventory[Flask of Advancement I](exists)} || \
								${Me.CustomInventory[Superior Draught of the Brilliant](exists)} || ${Me.CustomInventory[Greater Potion of the Advanced](exists)}
							{
								echo ${Time}: Consume Xp Potion Attempt Starting...
								statusvar:Set["Consume XP Potion Attempt Starting..."]
								
								wait 30

								if ${Me.CustomInventory[Draft of the Sage](exists)}
								{
									echo ${Time}: Draft of the Sage Detected
									statusvar:Set["Drink of the Sage Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Draft of the Sage]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[an enlightened experience](exists)}
									{
										echo ${Time}: Draft of the Sage Consumed
										statusvar:Set["Drink of the Sage Consumed"]
										lastpotion:Set["Draft of the Sage"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
								elseif ${Me.CustomInventory[Draft of the Wise](exists)}
								{
									echo ${Time}: Draft of the Wise Detected
									statusvar:Set["Draft of the Wise Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Draft of the Wise]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)}
									{
										echo ${Time}: Draft of the Wise Consumed
										statusvar:Set["Draft of the Wise Consumed"]
										lastpotion:Set["Draft of the Wise"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}	
								elseif ${Me.CustomInventory[Potion of the Prodigal](exists)}
								{
									echo ${Time}: Potion of the Prodigal Detected
									statusvar:Set["Potion of the Prodigal Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Potion of the Prodigal]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)}
									{
										echo ${Time}: Potion of the Prodigal Consumed
										statusvar:Set["Potion of the Prodigal Consumed"]
										lastpotion:Set["Potion of the Prodigal"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
								elseif ${Me.CustomInventory[EQII Fortune League Experience Potion](exists)}
								{
									echo ${Time}: EQII Fortune League Experience Potion Detected
									statusvar:Set["EQII Fortune League Experience Potion Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[EQII Fortune League Experience Potion]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[EQII Fortune League Experience Potion](exists)}
									{
										echo ${Time}: EQII Fortune League Experience Potion Consumed
										statusvar:Set["EQII Fortune League Experience Potion Consumed"]
										lastpotion:Set["EQII Fortune League Experience Potion"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}						
								elseif ${Me.CustomInventory[Superior Draught of the Brilliant](exists)}
								{
									echo ${Time}: Superior Draught of the Brilliant Detected
									statusvar:Set["Superior Draught of the Brilliant Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Superior Draught of the Brilliant]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a brilliant experience](exists)}
									{
										echo ${Time}: Superior Draught of the Brilliant Consumed
										statusvar:Set["Superior Draught of the Brilliant Consumed"]
										lastpotion:Set["Superior Draught of the Brilliant"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
								elseif ${Me.CustomInventory[Superior Potion of the Advanced](exists)}
								{
									echo ${Time}: Superior Potion of the Advanced Detected
									statusvar:Set["Superior Potion of the Advanced Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Superior Potion of the Advanced]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Superior Potion of the Advanced](exists)}
									{	
										echo ${Time}: Superior Potion of the Advanced Consumed
										statusvar:Set["Superior Potion of the Advanced Consumed"]
										lastpotion:Set["Superior Potion of the Advanced"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
								elseif ${Me.CustomInventory[Greater Potion of the Advanced](exists)}
								{
									echo ${Time}: Greater Potion of the Advanced Detected
									statusvar:Set["Greater Potion of the Advanced Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Greater Potion of the Advanced]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Major Potion of the Advanced](exists)}
									{
										echo ${Time}: Greater Potion of the Advanced Consumed
										statusvar:Set["Greater Potion of the Advanced Consumed"]
										lastpotion:Set["Greater Potion of the Advanced"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
								elseif ${Me.CustomInventory[Draught of the Wise](exists)}
								{
									echo ${Time}: Draught of the Wise Detected
									statusvar:Set["Draught of the Wise Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Draught of the Wise]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)}
									{
										echo ${Time}: Draught of the Wise Consumed
										statusvar:Set["Draught of the Wise Consumed"]
										lastpotion:Set["Draught of the Wise"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}						
								elseif ${Me.CustomInventory[Drink of the Wise](exists)}
								{
									echo ${Time}: Drink of the Wise Detected
									statusvar:Set["Drink of the Wise Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Drink of the Wise]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)}
									{
										echo ${Time}: Drink of the Wise Consumed
										statusvar:Set["Drink of the Wise Consumed"]
										lastpotion:Set["Drink of the Wise"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}		
								elseif ${Me.CustomInventory[Draft of the Skilled](exists)}
								{
									echo ${Time}: Draft of the Skilled Detected
									statusvar:Set["Draft of the Skilled Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Draft of the Skilled]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[a blessed experience](exists)}
									{
										echo ${Time}: Draft of the Skilled Consumed
										statusvar:Set["Draft of the Skilled Consumed"]
										lastpotion:Set["Draft of the Skilled"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
								elseif ${Me.CustomInventory[Flask of Advancement I](exists)}
								{
									echo ${Time}: Flask of Advancement I Detected
									statusvar:Set["Flask of Advancement I Detected"]
									if ${Script[${OgreBotScriptName}](exists)} && !${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
									wait 30
									ItemToUse:Set[Flask of Advancement I]
									Me.Inventory[exactitem,${ItemToUse}]:Use
									wait 10
									if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Find[Flask of Advancement I](exists)}
									{
										echo ${Time}: Flask of Advancement I Consumed
										statusvar:Set["Flask of Advancement I Consumed"]
										lastpotion:Set["Flask of Advancement I"]
										lastpotiontime:Set[${Time}]
									}
									wait 30
									if ${Script[Buffer:OgreBot](exists)} && ${b_OB_Paused}
										Script[${OgreBotScriptName}]:ExecuteAtom[TogglePause]
								}
							} 
							else
							{
								statusvar:Set["Potion script DISABLED. Calculating XP only."]
								lastpotion:Set["No potions detected in inventory."]
								lastpotiontime:Set[${Time}]						
								echo ${Time}: No potions detected in inventory.
																
								if !${UIElement[${EnableAdvXPCheckboxvar}].Checked} && !${UIElement[${EnableTSXPCheckboxvar}].Checked} && !${UIElement[${EnableAAXPCheckboxvar}].Checked}
								{
									statusvar:Set["Please select a type of XP to track."]
									echo ${Time}: Please select a type of XP to track.
									if ${Script[xpcalclevel](exists)}
									{
										endscript xpcalclevel
									}
									UIElement[${startclickervar}]:Show
									UIElement[${stopclickervar}]:Hide
									endscript bjxpbot
								}	
								else
								{	
									endscript bjxpbot
								}	
							}
							
							statusvar:Set["Waiting for next attempt."]
							wait ${Math.Calc[${timeuntilnext}/100]}
						}
						else
						{
							statusvar:Set["Potion script DISABLED. Calculating XP only."]
							if !${UIElement[${EnableAdvXPCheckboxvar}].Checked} && !${UIElement[${EnableTSXPCheckboxvar}].Checked} && !${UIElement[${EnableAAXPCheckboxvar}].Checked}
								{
									statusvar:Set["Please select a type of XP to track."]
									echo ${Time}: Please select a type of XP to track.
									if ${Script[xpcalclevel](exists)}
									{
										endscript xpcalclevel
									}
									UIElement[${startclickervar}]:Show
									UIElement[${stopclickervar}]:Hide
									endscript bjxpbot
								}	
								else
								{	
									endscript bjxpbot
								}
						}	
					}
					else
					{
						UIElement[${startclickervar}]:Show
						statusvar:Set["You're already max level and max AA"]
						echo ${Time}: You're already max level and max AA silly! Don't waste potions...
						endscript xpcalclevel
						endscript bjxpbot
					}
		}	
		
	}
	else
	{
		echo ${Time}: Please enter a valid end time.
		statusvar:Set["Please enter a valid end time."]
		UIElement[${timerunningvar}]:Hide
		UIElement[${timerunningvar2}]:Show
		UIElement[${startclickervar}]:Show
		UIElement[${stopclickervar}]:Hide
		endscript xpcalclevel
		endscript bjxpbot
	}
	
}

function SaveSettings()
{
		echo Saving Settings
		;// Vitality Potions
		if ${UIElement[EnableVitalityPotionsCheckbox@Potions_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableVitalityPotionsCheckbox,TRUE]
		else
			_ref:AddSetting[EnableVitalityPotionsCheckbox,FALSE]
			
		;// Experience Potions
		if ${UIElement[EnablePotionsCheckbox@Potions_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnablePotionsCheckbox,TRUE]
		else
			_ref:AddSetting[EnablePotionsCheckbox,FALSE]	
		
		;// Level Limit Checkbox
		if ${UIElement[EnableLevelLimitCheckbox@Limits_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableLevelLimitCheckbox,TRUE]
		else
			_ref:AddSetting[EnableLevelLimitCheckbox,FALSE]	

		;// Level Limit AA
		_ref:AddSetting[LevelAALimitVar,${LevelAALimitVar}]
		
		;// Level Limit ADV
		_ref:AddSetting[LevelAdvLimitVar,${LevelAdvLimitVar}]		
		
		;// Time Limit
		_ref:AddSetting[UserEndTimeVar,${UserEndTimeVar}]	

		;// ADV Experience Calculations Checkbox
		if ${UIElement[EnableAdvXPCheckbox@Exp_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAdvXPCheckbox,TRUE]
		else
			_ref:AddSetting[EnableAdvXPCheckbox,FALSE]

		;// TS Experience Calculations Checkbox
		if ${UIElement[EnableTSXPCheckbox@Exp_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableTSXPCheckbox,TRUE]
		else
			_ref:AddSetting[EnableTSXPCheckbox,FALSE]

		;// AA Experience Calculations Checkbox
		if ${UIElement[EnableAAXPCheckbox@Exp_Frame@bjxpbotsettings].Checked}
			_ref:AddSetting[EnableAAXPCheckbox,TRUE]
		else
			_ref:AddSetting[EnableAAXPCheckbox,FALSE]			

		LavishSettings[BJXPBot]:Export["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJXPBot/Character Config/${EQ2.ServerName}_${Me.Name}_BJXPBotSettings.xml"]
return
}

atom(script) EQ2_onIncomingText(string Message)
{
	;Chat type 15=group, 16=raid, 28=tell, 8=say
	;echo ChatType: ${ChatType} - Message: ${Message} - Speaker: ${Speaker} - ChatTarget: ${ChatTarget} - SpeakerIsNPC: ${SpeakerIsNPC} - ChannelName: ${ChannelName}

	if ${Message.Find["You can only have one experience potion active at a time."](exists)}
		{
			echo Potion consumption failed due to an already existing active potion.
		}
}

objectdef TimerObject
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}

	member:uint TimeLeft()
	{
		if ${Script.RunningTime}>=${EndTime}
			return 0
		return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
}	

function atexit()
{
	UIElement[${timerunningvar}]:Hide
	UIElement[${timerunningvar2}]:Show
	echo ${Time}: Stopping Script
	call SaveSettings	
}