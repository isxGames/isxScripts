variable settingsetref Settings
variable(global) settingsetref _ref
variable(global) filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJAuction/Saved Settings/BJAuctionSettings.xml"

function LoadSettings()
{
	;// Load Saved Settings
	LavishSettings:AddSet[BJAuction]
	LavishSettings[BJAuction]:Clear
	LavishSettings[BJAuction]:AddSet[Settings]
	LavishSettings[BJAuction]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJAuction/Saved Settings/BJAuctionSettings.xml"]
	_ref:Set[${LavishSettings.FindSet[BJAuction]}]
}

function SaveSettings()
{
	;// Save Settings
	
	;// Channel Name
		_ref:AddSetting[BJChannelName,${BJChannelName}]
	;// Starting Bid
		_ref:AddSetting[StartBidTextEntry,${StartBidTextEntry}]
	;// Optional Text
		_ref:AddSetting[OptionalTextEntryVar,${OptionalTextEntryVar}]
	;// Going Once Text
		_ref:AddSetting[GoingOncePhraseTextEntryVar,${GoingOncePhraseTextEntryVar}]
	;// Going Twice Text
		_ref:AddSetting[GoingTwicePhraseTextEntryVar,${GoingTwicePhraseTextEntryVar}]
	;// Going Sold Text
		_ref:AddSetting[GoingSoldPhraseTextEntryVar,${GoingSoldPhraseTextEntryVar}]		
		
	;// Selling Phrase Combobox
		_ref:AddSetting[SellingTypeVar,${SellingTypeVar}]
	;// Bid Type Combobox
		_ref:AddSetting[BidTypeVar,${BidTypeVar}]
	
	;// Optional Text Checkbox
	if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
		_ref:AddSetting[EnableOptionalTextCheckbox,TRUE]
	else
		_ref:AddSetting[EnableOptionalTextCheckbox,FALSE]
		
	LavishSettings[BJAuction]:Export["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJAuction/Saved Settings/BJAuctionSettings.xml"]
	echo ${Time}: Settings Saved.
	return
}

function main()
{
	call LoadSettings
	
	call Auction
	
	while 1
	{
		call RunningTimer
		
		if ${QueuedCommands}
			ExecuteQueued
	}
	waitframe
}

function Auction()
{
	if ${BJChannelName.NotEqual[ ]} && ${SellingTypeVar.NotEqual["Please Choose..."]} && ${BidTypeVar.NotEqual["Please Choose..."]} && ${StartBidTextEntry.NotEqual[ ]} && ${item1Linkvar.NotEqual[None]}
	{
		if ${Item2Linkvar.Equal[None]}
		{
			if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
			{
				eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} ${BidTypeVar}: ${StartBidTextEntry} ${OptionalTextEntryVar}
				statusvar:Set["Auction sent to channel ${BJChannelName}."]
				wait 30
				statusvar:Set["Idle..."]
			}
			else
			{
				eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} ${BidTypeVar}: ${StartBidTextEntry}
				statusvar:Set["Auction sent to channel ${BJChannelName}."]
				wait 30
				statusvar:Set["Idle..."]
			
			}
		}
		elseif ${Item2Linkvar.NotEqual[None]}
		{
			if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
			{
				eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} ${Item2Linkvar} ${BidTypeVar}: ${StartBidTextEntry} ${OptionalTextEntryVar}
				statusvar:Set["Auction sent to channel ${BJChannelName}."]
				wait 30
				statusvar:Set["Idle..."]
			}
			else
			{
				eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} ${Item2Linkvar} ${BidTypeVar}: ${StartBidTextEntry}
				statusvar:Set["Auction sent to channel ${BJChannelName}."]
				wait 30
				statusvar:Set["Idle..."]
			
			}
		}
	}	
	else
	{
		if ${BJChannelName.Equal[ ]}
		{
			echo Please enter a valid channel name.
			statusvar:Set["Please enter a valid channel name."]
			UIElement[${startbuttonvar}]:Show
			UIElement[${stopbuttonvar}]:Hide
			UIElement[${updatebuttonvar}]:Hide
			if ${Script[bjauction](exists)}
			{	
				endscript bjauction
			}
		}
		elseif ${SellingTypeVar.Equal["Please Choose..."]}
		{
			echo Please select a selling phrase.
			statusvar:Set["Please select a selling phrase."]
			UIElement[${startbuttonvar}]:Show
			UIElement[${stopbuttonvar}]:Hide
			UIElement[${updatebuttonvar}]:Hide
			if ${Script[bjauction](exists)}
			{	
				endscript bjauction
			}
		}
		elseif ${BidTypeVar.Equal["Please Choose..."]}
		{
			echo Please select a bid type.
			statusvar:Set["Please select a bid type."]
			UIElement[${startbuttonvar}]:Show
			UIElement[${stopbuttonvar}]:Hide
			UIElement[${updatebuttonvar}]:Hide
			if ${Script[bjauction](exists)}
			{	
				endscript bjauction
			}
		}
		elseif ${StartBidTextEntry.Equal[ ]}
		{
			echo Please enter a bid amount.
			statusvar:Set["Please enter a bid amount."]
			UIElement[${startbuttonvar}]:Show
			UIElement[${stopbuttonvar}]:Hide
			UIElement[${updatebuttonvar}]:Hide
			if ${Script[bjauction](exists)}
			{	
				endscript bjauction
			}
		}
		elseif ${item1Linkvar.Equal[None]}
		{
			echo Please set item 1.
			statusvar:Set["Please set item 1."]
			UIElement[${startbuttonvar}]:Show
			UIElement[${stopbuttonvar}]:Hide
			UIElement[${updatebuttonvar}]:Hide
			if ${Script[bjauction](exists)}
			{	
				endscript bjauction
			}
		}
	}
}

function Update()
{
	if ${UIElement[EnableStartBidCheckbox@bjauctionbot].Checked}
	{
		if ${BJChannelName.NotEqual[ ]} && ${SellingTypeVar.NotEqual["Please Choose..."]} && ${BidTypeVar.NotEqual["Please Choose..."]} && ${StartBidTextEntry.NotEqual[ ]} && ${Item1BidTextEntryVar.NotEqual[ ]}
		{	
			if ${Item2Linkvar.Equal[None]}
			{
				if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${BidTypeVar}: ${StartBidTextEntry} ${OptionalTextEntryVar}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]
				}
				else
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${BidTypeVar}: ${StartBidTextEntry}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]
				}	
			}
			elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.NotEqual[ ]}
			{
				if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry} ${BidTypeVar}: ${StartBidTextEntry} ${OptionalTextEntryVar}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]
				}
				else
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry} ${BidTypeVar}: ${StartBidTextEntry}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]				
				}
			}
			elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.Equal[ ]}
			{
				echo Please enter a bid value for item 2.
				statusvar:Set["Please enter a bid value for item 2."]
			}	
		}
		else
		{
			if ${BJChannelName.Equal[ ]}
			{
				echo Please enter a valid channel name.
				statusvar:Set["Please enter a valid channel name."]
			}
			elseif ${SellingTypeVar.Equal["Please Choose..."]}
			{
				echo Please select a selling phrase.
				statusvar:Set["Please select a selling phrase."]
			}
			elseif ${BidTypeVar.Equal["Please Choose..."]}
			{
				echo Please select a bid type.
				statusvar:Set["Please select a bid type."]
			}
			elseif ${StartBidTextEntry.Equal[ ]}
			{
				echo Please enter a bid amount.
				statusvar:Set["Please enter a bid amount."]
			}
			elseif ${Item1BidTextEntryVar.Equal[ ]}
			{
				echo Please enter a bid amount for item 1.
				statusvar:Set["Please enter a bid amount for item 1."]
			}
		}
	}
	else
	{
		if ${BJChannelName.NotEqual[ ]} && ${SellingTypeVar.NotEqual["Please Choose..."]} && ${Item1BidTextEntryVar.NotEqual[ ]}
		{	
			if ${Item2Linkvar.Equal[None]}
			{
				if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${OptionalTextEntryVar}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]
				}
				else
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]				
				}
			}
			elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.NotEqual[ ]}
			{
				if ${UIElement[EnableOptionalTextCheckbox@bjauctionbot].Checked}
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry} ${OptionalTextEntryVar}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]
				}
				else
				{
					eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry}
					statusvar:Set["Update sent to channel ${BJChannelName}."]
					wait 30
					statusvar:Set["Idle..."]
				
				}
			}
			elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.Equal[ ]}
			{
				echo Please enter a bid value for item 2.
				statusvar:Set["Please enter a bid value for item 2."]
			}	
		}
		else
		{
			if ${BJChannelName.Equal[ ]}
			{
				echo Please enter a valid channel name.
				statusvar:Set["Please enter a valid channel name."]
			}
			elseif ${SellingTypeVar.Equal["Please Choose..."]}
			{
				echo Please select a selling phrase.
				statusvar:Set["Please select a selling phrase."]
			}
			elseif ${Item1BidTextEntryVar.Equal[ ]}
			{
				echo Please enter a bid amount for item 1.
				statusvar:Set["Please enter a bid amount for item 1."]
			}
		}
	}
}

function GoingOnce()
{
	if ${BJChannelName.NotEqual[ ]} && ${SellingTypeVar.NotEqual["Please Choose..."]} && ${Item1BidTextEntryVar.NotEqual[ ]} && ${GoingOncePhraseTextEntryVar.NotEqual[ ]}
	{	
		if ${Item2Linkvar.Equal[None]}
		{
			eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${GoingOncePhraseTextEntryVar}
			statusvar:Set["Update sent to channel ${BJChannelName}."]
			wait 30
			statusvar:Set["Idle..."]
		}
		elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.NotEqual[ ]}
		{
			eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry} ${GoingOncePhraseTextEntryVar}
			statusvar:Set["Update sent to channel ${BJChannelName}."]
			wait 30
			statusvar:Set["Idle..."]
		}
		elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.Equal[ ]}
		{
			echo Please enter a bid value for item 2.
			statusvar:Set["Please enter a bid value for item 2."]
		}	
	}
	else
	{
		if ${BJChannelName.Equal[ ]}
		{
			echo Please enter a valid channel name.
			statusvar:Set["Please enter a valid channel name."]
		}
		elseif ${SellingTypeVar.Equal["Please Choose..."]}
		{
			echo Please select a selling phrase.
			statusvar:Set["Please select a selling phrase."]
		}
		elseif ${Item1BidTextEntryVar.Equal[ ]}
		{
			echo Please enter a bid amount for item 1.
			statusvar:Set["Please enter a bid amount for item 1."]
		}
		elseif ${GoingOncePhraseTextEntryVar.Equal[ ]}
		{
			echo Please enter a custom Going Once phrase.
			statusvar:Set["Please enter a custom Going Once phrase."]
		}
	}
}

function GoingTwice()
{
	if ${BJChannelName.NotEqual[ ]} && ${SellingTypeVar.NotEqual["Please Choose..."]} && ${Item1BidTextEntryVar.NotEqual[ ]} && ${GoingTwicePhraseTextEntryVar.NotEqual[ ]}
	{	
		if ${Item2Linkvar.Equal[None]}
		{
			eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${GoingTwicePhraseTextEntryVar}
			statusvar:Set["Update sent to channel ${BJChannelName}."]
			wait 30
			statusvar:Set["Idle..."]
		}
		elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.NotEqual[ ]}
		{
			eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry} ${GoingTwicePhraseTextEntryVar}
			statusvar:Set["Update sent to channel ${BJChannelName}."]
			wait 30
			statusvar:Set["Idle..."]
		}
		elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.Equal[ ]}
		{
			echo Please enter a bid value for item 2.
			statusvar:Set["Please enter a bid value for item 2."]
		}	
	}
	else
	{
		if ${BJChannelName.Equal[ ]}
		{
			echo Please enter a valid channel name.
			statusvar:Set["Please enter a valid channel name."]
		}
		elseif ${SellingTypeVar.Equal["Please Choose..."]}
		{
			echo Please select a selling phrase.
			statusvar:Set["Please select a selling phrase."]
		}
		elseif ${Item1BidTextEntryVar.Equal[ ]}
		{
			echo Please enter a bid amount for item 1.
			statusvar:Set["Please enter a bid amount for item 1."]
		}
		elseif ${GoingTwicePhraseTextEntryVar.Equal[ ]}
		{
			echo Please enter a custom Going Twice phrase.
			statusvar:Set["Please enter a custom Going Twice phrase."]
		}		
	}
}

function GoingSold()
{
	if ${BJChannelName.NotEqual[ ]} && ${SellingTypeVar.NotEqual["Please Choose..."]} && ${Item1BidTextEntryVar.NotEqual[ ]} && ${GoingSoldPhraseTextEntryVar.NotEqual[ ]}
	{	
		if ${Item2Linkvar.Equal[None]}
		{
			eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${GoingSoldPhraseTextEntryVar}
			statusvar:Set["Update sent to channel ${BJChannelName}."]
			wait 30
			statusvar:Set["Idle..."]
		}
		elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.NotEqual[ ]}
		{
			eq2execute tellchannel ${BJChannelName} ${SellingTypeVar} ${item1Linkvar} @ ${Item1BidTextEntryVar} ${Item2Linkvar} @ ${Item2BidTextEntry} ${GoingSoldPhraseTextEntryVar}
			statusvar:Set["Update sent to channel ${BJChannelName}."]
			wait 30
			statusvar:Set["Idle..."]
		}
		elseif ${Item2Linkvar.NotEqual[None]} && ${Item2BidTextEntry.Equal[ ]}
		{
			echo Please enter a bid value for item 2.
			statusvar:Set["Please enter a bid value for item 2."]
		}	
	}
	else
	{
		if ${BJChannelName.Equal[ ]}
		{
			echo Please enter a valid channel name.
			statusvar:Set["Please enter a valid channel name."]
		}
		elseif ${SellingTypeVar.Equal["Please Choose..."]}
		{
			echo Please select a selling phrase.
			statusvar:Set["Please select a selling phrase."]
		}
		elseif ${Item1BidTextEntryVar.Equal[ ]}
		{
			echo Please enter a bid amount for item 1.
			statusvar:Set["Please enter a bid amount for item 1."]
		}
		elseif ${GoingSoldPhraseTextEntryVar.Equal[ ]}
		{
			echo Please enter a custom Sold phrase.
			statusvar:Set["Please enter a custom Sold phrase."]
		}		
	}
}

function RunningTimer()
{
		StartTimeRunning:Set[${Math.Calc64[${Script.RunningTime}/1000]}]
		DisplaySecondsRunning:Set[${Math.Calc64[${StartTimeRunning}%60]}]
		DisplayMinutesRunning:Set[${Math.Calc64[${StartTimeRunning}/60%60]}]
		DisplayHoursRunning:Set[${Math.Calc64[${StartTimeRunning}/60\\60]}]
;;		echo ${DisplayHours.LeadingZeroes[2]}:${DisplayMinutes.LeadingZeroes[2]}:${DisplaySeconds.LeadingZeroes[2]}
}

function atexit()
{
	call SaveSettings
	echo ${Time}: Stopping BJ Auction Bot
	if ${Script[bjauctiontimer](exists)}
	{	
		endscript bjauctiontimer
	} 
}