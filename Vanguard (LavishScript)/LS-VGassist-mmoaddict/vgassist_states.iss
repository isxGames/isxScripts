function vgstates()
{
	if ${Me.InCombat}
	{
	UIElement[mecombat@MainStatesFrame@Char_States@SubStats@StatsFrame@Stats@ABot@vgassist]:SetChecked
	}
	if !${Me.InCombat}
	{
	UIElement[mecombat@MainStatesFrame@Char_States@SubStats@StatsFrame@Stats@ABot@vgassist]:UnsetChecked
	}
}