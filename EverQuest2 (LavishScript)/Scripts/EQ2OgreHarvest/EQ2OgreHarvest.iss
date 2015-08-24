variable string EQOHVersion=Beta 1.009
variable settingsetref User

/**
*********EQ2OgreHarvest***Please note this script is in BETA************

This is merely a shell UI that loads the injectable. This harvest bot was designed to be loaded into other scripts. This is the standalone version.
**/

variable(global) int EQ2OgreHarvestTabControl

function main()
{
	echo EQ2OgreHarvest Bot -- Version ${EQOHVersion}
	echo "Please note this script is in BETA.  Make suggestions and report bugs on the forums."

	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/EQ2OgreHarvestShellXML.xml"

	runscript "${LavishScript.HomeDirectory}/Scripts/eq2ogreharvest/InjectTab" ${EQ2OgreHarvestTabControl} 1

	;; We cannot apply any settings from the XML file until the UI is fully loaded.  This usually happens very quickly, but does take a couple of frames
	do
	{
		waitframe
	}
	while !${EQ2OgreHarvestLoaded}
	LoadXMLSettings

	do
	{
		if ${EQ2OgreHarvestOptionsChanged}
		{
			UpdateXMLSettings
			EQ2OgreHarvestOptionsChanged:Set[FALSE]
		}
	}
	while ${EQ2OgreHarvestLoaded}	
}

atom(script) LoadXMLSettings()
{
	LavishSettings:AddSet[EQ2OgreHarvest]
	LavishSettings[EQ2OgreHarvest]:AddSet[Users]
	LavishSettings[EQ2OgreHarvest].FindSet[Users]:AddSet[${Me.Name}]
	User:Set[${LavishSettings[EQ2OgreHarvest].FindSet[Users].FindSet[${Me.Name}]}]
	User:Import["${Script.CurrentDirectory}/Character Config/${Me.Name}-${EQ2.ServerName}.xml"]
	
	if (${User.FindSetting[chkboxOre,TRUE]})
		UIElement[${ChkBoxOreID}]:SetChecked
	if (${User.FindSetting[chkboxGems,TRUE]})
		UIElement[${ChkBoxGemsID}]:SetChecked
	if (${User.FindSetting[chkboxWood,TRUE]})
		UIElement[${ChkBoxWoodID}]:SetChecked
	if (${User.FindSetting[chkboxRoots,TRUE]})
		UIElement[${ChkBoxRootsID}]:SetChecked
	if (${User.FindSetting[chkboxDens,TRUE]})
		UIElement[${ChkBoxDensID}]:SetChecked
	if (${User.FindSetting[chkboxShrubs,TRUE]})
		UIElement[${ChkBoxShrubsID}]:SetChecked
	if (${User.FindSetting[chkboxFish,FALSE]})
		UIElement[${ChkBoxFishID}]:SetChecked
	if (${User.FindSetting[chkboxCollectibleQ,FALSE]})
		UIElement[${ChkBoxCollectibleQID}]:SetChecked
	if (${User.FindSetting[chkboxCollectibleE,FALSE]})
		UIElement[${ChkBoxCollectibleEID}]:SetChecked
		
	if (${User.FindSetting[chkboxPathMode,TRUE]})
		UIElement[${ChkBoxPathModeID}]:SetChecked
	if (${User.FindSetting[chkboxLoopPathMode,TRUE]})
		UIElement[${ChkBoxLoopPathModeID}]:SetChecked
		
	if (${User.FindSetting[RoamMode,TRUE]})
		UIElement[${ChkBoxRoamModeID}]:SetChecked
	UIElement[${TEBoxRoamDistanceID}]:SetText[${User.FindSetting[RoamDistance,"75"]}]
	
	if (${User.FindSetting[TetherMode,FALSE]})
		UIElement[${ChkBoxTetherModeID}]:SetChecked
	UIElement[${TEBoxTetherDistanceID}]:SetText[${User.FindSetting[TetherDistance,"200"]}]
	
	if (${User.FindSetting[chkboxSkillUpOnlyMode,FALSE]})
		UIElement[${ChkBoxSkillUpOnlyModeID}]:SetChecked
	if (${User.FindSetting[chkboxNoiseOnExit,FALSE]})
		UIElement[${ChkBoxNoiseOnExitID}]:SetChecked
}

atom(script) UpdateXMLSettings()
{
	variable bool SpewDebug = FALSE
	
	User.FindSetting[chkboxOre]:Set[${UIElement[${ChkBoxOreID}].Checked}]
	User.FindSetting[chkboxGems]:Set[${UIElement[${ChkBoxGemsID}].Checked}]
	User.FindSetting[chkboxWood]:Set[${UIElement[${ChkBoxWoodID}].Checked}]
	User.FindSetting[chkboxRoots]:Set[${UIElement[${ChkBoxRootsID}].Checked}]
	User.FindSetting[chkboxDens]:Set[${UIElement[${ChkBoxDensID}].Checked}]
	User.FindSetting[chkboxShrubs]:Set[${UIElement[${ChkBoxShrubsID}].Checked}]
	User.FindSetting[chkboxFish]:Set[${UIElement[${ChkBoxFishID}].Checked}]
	User.FindSetting[chkboxCollectibleQ]:Set[${UIElement[${ChkBoxCollectibleQID}].Checked}]
	User.FindSetting[chkboxCollectibleE]:Set[${UIElement[${ChkBoxCollectibleEID}].Checked}]
	
	User.FindSetting[chkboxPathMode]:Set[${UIElement[${ChkBoxPathModeID}].Checked}]
	User.FindSetting[chkboxLoopPathMode]:Set[${UIElement[${ChkBoxLoopPathModeID}].Checked}]
	
	User.FindSetting[RoamMode]:Set[${UIElement[${ChkBoxRoamModeID}].Checked}]
	User.FindSetting[RoamDistance]:Set[${UIElement[${TEBoxRoamDistanceID}].Text}]
	
	User.FindSetting[TetherMode]:Set[${UIElement[${ChkBoxTetherModeID}].Checked}]
	User.FindSetting[TetherDistance]:Set[${UIElement[${TEBoxTetherDistanceID}].Text}]
	
	User.FindSetting[chkboxSkillUpOnlyMode]:Set[${UIElement[${ChkBoxSkillUpOnlyModeID}].Checked}]
	User.FindSetting[chkboxNoiseOnExit]:Set[${UIElement[${ChkBoxNoiseOnExitID}].Checked}]
	
	User:Export["${Script.CurrentDirectory}/Character Config/${Me.Name}-${EQ2.ServerName}.xml"]
	
	if (${SpewDebug})
	{
		;;;;;;;;;;;;;;;;
		;; DEBUG SPEW ;;
		echo "[${Time}] EQ2OgreHarvest:: UpdateSettings called:
		echo "[${Time}] -- chkboxOre: ${User.FindSetting[chkboxOre]}"
		echo "[${Time}] -- chkboxGems: ${User.FindSetting[chkboxGems]}"
		echo "[${Time}] -- chkboxWood: ${User.FindSetting[chkboxWood]}"
		echo "[${Time}] -- chkboxRoots: ${User.FindSetting[chkboxRoots]}"
		echo "[${Time}] -- chkboxDens: ${User.FindSetting[chkboxDens]}"
		echo "[${Time}] -- chkboxShrubs: ${User.FindSetting[chkboxShrubs]}"
		echo "[${Time}] -- chkboxFish: ${User.FindSetting[chkboxFish]}"
		echo "[${Time}] -- chkboxCollectibleQ: ${User.FindSetting[chkboxCollectibleQ]}"
		echo "[${Time}] -- chkboxCollectibleE: ${User.FindSetting[chkboxCollectibleE]}"
		echo "[${Time}] --"
		echo "[${Time}] -- chkboxPathMode: ${User.FindSetting[chkboxPathMode]}"
		echo "[${Time}] -- chkboxLoopPathMode: ${User.FindSetting[chkboxLoopPathMode]}"
		echo "[${Time}] --"
		echo "[${Time}] -- RoamMode: ${User.FindSetting[RoamMode]}"
		echo "[${Time}] -- RoamDistance: ${User.FindSetting[RoamDistance]}"
		echo "[${Time}] --"
		echo "[${Time}] -- TetherMode: ${User.FindSetting[TetherMode]}"
		echo "[${Time}] -- TetherDistance: ${User.FindSetting[TetherDistance]}"
		echo "[${Time}] --"
		echo "[${Time}] -- chkboxSkillUpOnlyMode: ${User.FindSetting[chkboxSkillUpOnlyMode]}"
		echo "[${Time}] -- chkboxNoiseOnExit: ${User.FindSetting[chkboxNoiseOnExit]}"
		echo "[${Time}] Settings written to '${Script.CurrentDirectory}/Character Config/${Me.Name}-${EQ2.ServerName}.xml'"
		;;;;;;;;;;;;;;;;
	}
}