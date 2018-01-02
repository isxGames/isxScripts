; This script will scan all top-level UI elements and reset all windows not included in
; the IS Default UI to their xml-defined locations.


function main()
{
	variable string elementname = ${UIElement[screen].Children}
	while (${UIElement[${elementname}](exists)})
	{
		if ${UIElement[${elementname}].Type.Equal[window]}
		{
			if ${elementname.NotEqual[console]} && ${elementname.NotEqual[window selector]}
			{
				echo Resetting ${elementname}...
				UIElement[${elementname}]:Reset
			}
		}
		elementname:Set[${UIElement[${elementname}].Next}]
	}
	
}