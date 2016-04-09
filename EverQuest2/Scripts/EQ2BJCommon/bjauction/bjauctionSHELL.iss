variable(global) settingsetref Settings
variable(global) settingsetref _ref
variable(global) filepath ConfigFile="${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJAuction/Saved Settings/BJAuctionSettings.xml"
									 
function main()
{
	;// Load UI
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/eq2bjcommon/bjauction/UI/bjauctionXML.xml"
	
	;// Load Saved Settings
	LavishSettings:AddSet[BJAuction]
	LavishSettings[BJAuction]:Clear
	LavishSettings[BJAuction]:AddSet[Settings]
	LavishSettings[BJAuction]:Import["${LavishScript.HomeDirectory}/Scripts/EQ2BJCommon/BJAuction/Saved Settings/BJAuctionSettings.xml"]
	_ref:Set[${LavishSettings.FindSet[BJAuction]}]
	
	;// Channel Name
	if ${_ref.FindSetting[BJChannelName](exists)}
	{
		BJChannelName:Set[${_ref.FindSetting[BJChannelName]}]
		UIElement[ChatChannel@bjauctionbot]:SetText[${_ref.FindSetting[BJChannelName]}]
	}
	
	;// Starting Bid
	if ${_ref.FindSetting[StartBidTextEntry](exists)}
	{
		StartBidTextEntry:Set[${_ref.FindSetting[StartBidTextEntry]}]
		UIElement[StartBidTextEntry@bjauctionbot]:SetText[${_ref.FindSetting[StartBidTextEntry]}]
	}
	
	;// Optional Text
	if ${_ref.FindSetting[OptionalTextEntryVar](exists)}
	{
		OptionalTextEntryVar:Set[${_ref.FindSetting[OptionalTextEntryVar]}]
		UIElement[OptionalTextEntry@bjauctionbot]:SetText[${_ref.FindSetting[OptionalTextEntryVar]}]
	}
	
	;// Going Once Text
	if ${_ref.FindSetting[GoingOncePhraseTextEntryVar](exists)}
	{
		GoingOncePhraseTextEntryVar:Set[${_ref.FindSetting[GoingOncePhraseTextEntryVar]}]
		UIElement[GoingOncePhraseTextEntry@Settings_Frame@bjauctionsettings]:SetText[${_ref.FindSetting[GoingOncePhraseTextEntryVar]}]
	}	
	
	;// Going Twice Text
	if ${_ref.FindSetting[GoingTwicePhraseTextEntryVar](exists)}
	{
		GoingTwicePhraseTextEntryVar:Set[${_ref.FindSetting[GoingTwicePhraseTextEntryVar]}]
		UIElement[GoingTwicePhraseTextEntry@Settings_Frame@bjauctionsettings]:SetText[${_ref.FindSetting[GoingTwicePhraseTextEntryVar]}]
	}	
	
	;// Going Sold Text
	if ${_ref.FindSetting[GoingSoldPhraseTextEntryVar](exists)}
	{
		GoingSoldPhraseTextEntryVar:Set[${_ref.FindSetting[GoingSoldPhraseTextEntryVar]}]
		UIElement[GoingSoldPhraseTextEntry@Settings_Frame@bjauctionsettings]:SetText[${_ref.FindSetting[GoingSoldPhraseTextEntryVar]}]
	}	
	
	;// Selling Phrase Combobox
	if ${_ref.FindSetting[SellingTypeVar](exists)}
	{
		SellingTypeVar:Set[${_ref.FindSetting[SellingTypeVar]}]
		UIElement[SellingTypeComboBox@bjauctionbot]:SetSelection[${UIElement[SellingTypeComboBox@bjauctionbot].ItemByText[${_ref.FindSetting[SellingTypeVar]}].ID}]
	}
	;// Bid Type Combobox
	if ${_ref.FindSetting[BidTypeVar](exists)}
	{
		BidTypeVar:Set[${_ref.FindSetting[BidTypeVar]}]
		UIElement[BidTypeComboBox@bjauctionbot]:SetSelection[${UIElement[BidTypeComboBox@bjauctionbot].ItemByText[${_ref.FindSetting[BidTypeVar]}].ID}]
	}	
	;//	Optional Text Checkbox
	if ${_ref.FindSetting[EnableOptionalTextCheckbox]}
	{	
		UIElement[${EnableOptionalTextCheckboxVar}]:SetChecked
	}	
	else
	{
		UIElement[${EnableOptionalTextCheckboxVar}]:UnsetChecked
	}	
}

