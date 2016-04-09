variable string TestString
variable string LootString
variable int LootCheck
variable string NameString
variable string MaxLootString
variable string MinLootString
variable string TextLine

function main()
{
	echo echo Loot Helper Started-------------------------------------
	call LoadUI
	Event[EQ2_onIncomingText]:AttachAtom[GetText]

	do
	{
		waitframe
	}
	while 1
}

function AddRoll(string textline, string colour)
{
	UIElement[LootLog@LootHelperUI]:AddItem[${textline},1,${colour}]
}

atom GetText(string LootRoll)
{
	if ${LootRoll.Find["Random:"]}
		{
				TestString:Set[${LootRoll}]
				NameString:Set[${TestString.Token[2," "]}]
				LootCheck:Set[${TestString.Token[14," "].Token[1,!]}]
				if ${LootCheck} < 100
				{
					LootString:Set[0${LootCheck}]
				}
				else
				{
					LootString:Set[${LootCheck}]
				}
				MinLootString:Set[${TestString.Token[5," "]}]	
				MaxLootString:Set[${TestString.Token[7," "]}]
				TextLine:Set["${LootString} ${NameString} ${MinLootString} to ${MaxLootString}"]
				call AddRoll "${TextLine}"	
		}
}

function LoadUI()
{
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/LootHelper/UI/LootHelperUI.xml"
}	
function atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Scripts/LootHelper/UI/LootHelperUI.xml"
	echo Loot Helper Closed-------------------------------------
}