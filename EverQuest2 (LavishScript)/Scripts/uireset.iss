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
}
