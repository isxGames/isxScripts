function main()
{
	variable string elementname = ${UIElement[screen].Children}
	while (${UIElement[${elementname}](exists)})
	{
		if ${UIElement[${elementname}].Type.Equal[window]}
		{
			if ${elementname.NotEqual[console] && ${elementname.NotEqual[window selector]}
			{
				echo Resetting ${elementname}...
				UIElement[${elementname}]:Reset
			}
		}
		elementname:Set[${UIElement[${elementname}].Next}]
	}
	
}