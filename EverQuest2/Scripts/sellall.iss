function main(param1)
{
	declare xmlpath string script "./XML/"
 
	if ${param1.Equal[add]}
	{
		do
		{
			InputBox "What Item Is NOT Vendor Junk?"
			if ${UserInput(exists)}
				call addjunk "${UserInput}"
		}
		while ${UserInput(exists)}
	}
	
	if ${param1.Equal[sell]}
		call sellshit
}

function addjunk(string junkname)
{
	SettingXML["./XML/sellall.xml"].Set[Vendor Junk]:Set["${junkname}",Sell]
	SettingXML["./XML/sellall.xml"]:Save
}

function sellshit()
{
	variable index:item Items
	variable iterator ItemIterator
	variable int tempvar=1
	variable bool sell=TRUE
		
	Actor[nokillnpc]:DoTarget
	wait 1
	Target:DoFace
	wait 1
	Target:DoubleClick
	wait 1	

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${ItemIterator:First(exists)}
	{
		do
		{
			do
			{	
				; if the current item is on the list, set to not sell.
				if ${ItemIterator.Value.Name.Equal[${SettingXML[./XML/sellall.xml].Set[Vendor Junk].Key[${tempvar}]}]}
				{
				sell:Set[FALSE]
				}
			} 
			while ${tempvar:Inc} <= ${SettingXML[./XML/sellall.xml].Set[Vendor Junk].Keys}
			;check next item in xml list.

			
			;if not on protected list, sell the item
			if ${sell}
			{
				MerchantWindow.MyInventory[${ItemIterator.Value.Name}]:Sell
				
				if ${ItemIterator.Value.NoValue}
				{
				ItemIterator.Value:Destroy
				}
			}

			; setup for next item
			sell:Set[TRUE]
			; tempvar is for the xml file, so we will start it from beginning for next item
			tempvar:Set[1]
		}
		while ${ItemIterator:Next(exists)}
	}

	press ESC
	press ESC
	press ESC
}

function atexit()
{
	SettingXML["./XML/sellall.xml"]:Save
	SettingXML["./XML/sellall.xml"]:Unload
}