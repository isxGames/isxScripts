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

	;ANNOUNCE IS BROKEN announce "\\#FF6E6EProtected item { ${junkname} } Added" 1 2

	SettingXML["./XML/sellall.xml"]:Save
}

function sellshit()
{
	variable int tempvar=1
	variable int tempvar2=1
	variable bool sell=TRUE
		
	Actor[nokillnpc]:DoTarget
	wait 1
	Target:DoFace
	wait 1
	Target:DoubleClick
	wait 1	

	;ANNOUNCE IS BROKEN announce "making inventory array" 1 1
	Me:CreateCustomInventoryArray[nonbankonly]

	do
	{
		do
		{	

			; if the current item is on the list, set to not sell.
			if ${Me.CustomInventory[${tempvar2}].Name.Equal[${SettingXML[./XML/sellall.xml].Set[Vendor Junk].Key[${tempvar}]}]}
			{
			 sell:Set[FALSE]
			}
		} 
		while ${tempvar:Inc} <= ${SettingXML[./XML/sellall.xml].Set[Vendor Junk].Keys}
		;check next item in xml list.

		
		;if not on protected list, sell the item
		if ${sell}
		{
			Me.Merchandise[${Me.CustomInventory[${tempvar2}].Name}]:Sell
			
			if ${Me.CustomInventory[${tempvar2}].NoValue}
			{
			Me.CustomInventory[${tempvar2}]:Destroy
			}


		}

		; setup for next item
		sell:Set[TRUE]
		; tempvar is for the xml file, so we will start it from beginning for next item
		tempvar:Set[1]

	}
	while "${tempvar2:Inc}<=${Me.CustomInventoryArraySize}"
	;check next item in inventory

	;ANNOUNCE IS BROKEN announce "\You have sold Junk" 1 2
	press ESC
	press ESC
	press ESC
}

function atexit()
{
	SettingXML["./XML/sellall.xml"]:Save
		SettingXML["./XML/sellall.xml"]:Unload
}