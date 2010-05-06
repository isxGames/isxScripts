variable string EQOHVersion=Beta 1.001
/**
*********EQ2OgreHarvest***Please note this script is in BETA************

This is merely a shell UI that loads the injectable. This harvest bot was designed to be loaded into other scripts. This is the standalone version.
**/

variable(global) int EQ2OgreHarvestTabControl

function main()
{
	echo EQ2OgreHarvest Bot -- Version ${EQOHVersion}
	echo Please note this script is in BETA. Remember to update frequently off the SVN to receive updates that improves and fixes bugs.
	echo Make suggestions and report bugs on the forums.

	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/EQ2OgreHarvestShellXML.xml"

	;Execute run "\"${LavishScript.HomeDirectory}/Scripts/eq2ogreharvest/InjectTab\" ${EQ2OgreHarvestTabControl} 1"
	runscript "${LavishScript.HomeDirectory}/Scripts/eq2ogreharvest/InjectTab" ${EQ2OgreHarvestTabControl} 1
}
