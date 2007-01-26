function main(param1)
{
	declare xmlpath string script "./XML/"
 
	if ${param1.Equal[add]}
	{
		do
		{
			InputBox "What Item Is Vendor Junk?"
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
	SettingXML["./XML/VendorJunkConfig.xml"].Set[Vendor Junk]:Set["${junkname}",Sell]

	announce "\\#FF6E6ENew Junk { ${junkname} } Added" 1 2

	SettingXML["./XML/VendorJunkConfig.xml"]:Save
}

function sellshit()
{
	variable int tempvar=1
		
	Actor[nokillnpc]:DoTarget
	wait 1
	Target:DoFace
	wait 1
	Target:DoubleClick
	wait 1	

	Do
	{	
		Do
		{	
	  	Me.Merchandise[${SettingXML[./XML/VendorJunkConfig.xml].Set[Vendor Junk].Key[${tempvar}]}]:Sell
		}
		while ${Me.Merchandise[${SettingXML[./XML/VendorJunkConfig.xml].Set[Vendor Junk].Key[${tempvar}]}](exists)}
	}
	while ${tempvar:Inc} <= ${SettingXML[./XML/VendorJunkConfig.xml].Set[Vendor Junk].Keys}
	
	announce "\You have sold Junk" 1 2
	press ESC
	press ESC
	press ESC
}

function atexit()
{
	SettingXML["./XML/VendorJunkConfig.xml"]:Save
		SettingXML["./XML/VendorJunkConfig.xml"]:Unload
}