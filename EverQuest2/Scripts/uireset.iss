function main()
{
	;; LGUI1
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

	;; LGUI2
	;; LGUI2 windows don't have a Reset method and don't track their source package files
	;; We can only list windows that have been moved/resized from their JSON defaults
	;; Users must manually specify package files to reset
	echo "Discovering LGUI2 windows with custom placement..."

	variable collection:string lgui2WindowsFound
	variable string lgui2ElementName
	lgui2ElementName:Set["${LGUI2.Layer[base].Screen.FirstChild.Name}"]

	while ${lgui2ElementName.Length} > 0
	{
		if ${LGUI2.Element[${lgui2ElementName}](exists)}
		{
			;; Check if this is a window element
			variable string elementType
			elementType:Set["${LGUI2.Element[${lgui2ElementName}](type)}"]

			if ${elementType.Equal["lgui2window"]}
			{
				;; Check if window has StorePlacement (means it's been moved/resized)
				if ${LGUI2.Element[${lgui2ElementName}].StorePlacement(exists)}
				{
					lgui2WindowsFound:Set["${lgui2ElementName}","${lgui2ElementName}"]
					echo "- Found LGUI2 window: \ay${lgui2ElementName}\ax"
					echo "-- Position: ${LGUI2.Element[${lgui2ElementName}].StorePlacement}"
				}
			}

			;; Move to next sibling
			lgui2ElementName:Set["${LGUI2.Element[${lgui2ElementName}].NextSibling.Name}"]
		}
		else
		{
			break
		}
	}

	;; Check if we found any windows
	variable iterator windowIterator
	lgui2WindowsFound:GetIterator[windowIterator]

	if ${windowIterator:First(exists)}
	{
		echo "======="
		echo "==> LGUI2 windows cannot be automatically reset."
		echo "==> To reset a window, destroy it and reload its package file:"
		echo "==>     \agLGUI2.Element[WindowName]:Destroy\ax"
		echo "==>     \agLGUI2:LoadPackageFile[\"path/to/package.json\"]\ax"
		echo "======="
	}
	else
	{
		echo "-No LGUI2 windows with custom placement found."
	}

	echo "LGUI2 discovery complete!"
}