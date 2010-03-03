function main()
{
	if ${UIElement[EQ2 Bot](exists)}
		UIElement[EQ2 Bot]:Reset
	if ${UIElement[Craft Selection](exists)}
		UIElement[Craft Selection]:Reset
	if ${UIElement[Radar Window](exists)}
		UIElement[Radar Window]:Reset
	if ${UIElement[Harvest](exists)}
		UIElement[Harvest]:Reset
	if ${UIElement[EQ2 Track](exists)}
		UIElement[EQ2 Track]:Reset
	if ${UIElement[EQ2AFKAlarm](exists)}
		UIElement[EQ2AFKAlarm]:Reset
	if ${UIElement[EQ2Inventory](exists)}
		UIElement[EQ2Inventory]:Reset
	if ${UIElement[CraftSearch](exists)}
		UIElement[CraftSearch]:Reset
	if ${UIElement[EQ2OgreTransmuteXML](exists)}
		UIElement[EQ2OgreTransmuteXML]:Reset
	if ${UIElement[EQ2OgreZoneResetXML](exists)}
		UIElement[EQ2OgreZoneResetXML]:Reset
	if ${UIElement[EQ2OgreHarvestShell](exists)}
		UIElement[EQ2OgreHarvestShell]:Reset
	if ${UIElement[EQ2OgreHarvestStatsXML](exists)}
		UIElement[EQ2OgreHarvestStatsXML]:Reset
}
