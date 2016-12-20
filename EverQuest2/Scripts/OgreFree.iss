;OgreFree is a derivative of the Ogre scripts made by Kannkor.
;Currently Depot, Hireling, and Transmute/Salvage/Refine have been updated/rebuilt. 
function main()
{

	if !${ISXEQ2(exists)}
	{
		ext isxeq2
	}

	wait 100 ${Display.FPS}>1

	if !${ISXEQ2.IsReady}
	{
		wait 200 ${ISXEQ2.IsReady}
		wait 40
		if !${ISXEQ2.IsReady}
		{
			echo ISXEQ2 is reporting NOT being ready. All functions of this script require ISXEQ2. Please load ISXEQ2 and run the script again.
			Script:End
		}
	}

	echo OgreFree does not use the arguments that Ogre does. Scripts are run via the GUI. -IDBurner

	;Skin here so we don't have to make sure everything is skinned in scripts..
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	;Open the portal UI - I have moved everything to needing the portal
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2OgreFree/OgrePortal/OgrePortalXML.xml"

	;Add Transmute Plugin to the Portal
	UIElement[OgreFree Tabs@OgrePortalXML]:AddTab[Transmute]
	UIElement[OgreFree Tabs@OgrePortalXML].Tab[2]:Move[2]
	ui -load -parent "Transmute@OgreFree Tabs@OgrePortalXML" -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2OgreFree/OgreTransmute/EQ2OgreTransmuteXML.xml"

	;Add Depot Plugin to the Portal
	UIElement[OgreFree Tabs@OgrePortalXML]:AddTab[Depot]
	UIElement[OgreFree Tabs@OgrePortalXML].Tab[3]:Move[3]
	ui -load -parent "Depot@OgreFree Tabs@OgrePortalXML" -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2OgreFree/OgreDepot/OgreDepotXML.xml"

	;Add Extras Plugin to the Portal
	UIElement[OgreFree Tabs@OgrePortalXML]:AddTab[Options]
	UIElement[OgreFree Tabs@OgrePortalXML].Tab[4]:Move[4]
	ui -load -parent "Options@OgreFree Tabs@OgrePortalXML" -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2OgreFree/OgrePortal/ExtraOptions.xml"

}