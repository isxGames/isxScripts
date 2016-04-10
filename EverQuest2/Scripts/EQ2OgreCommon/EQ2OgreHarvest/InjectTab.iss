;-----------------------------------------------------------------------------------------------
; 
;
; Description
; This file is to be called by other scripts.  It creates a tab as a child of an
; existing TabControl, the ID of which should be passed as the first argument.
; Second argument is which tab it will be moved too.
;-----------------------------------------------------------------------------------------------

variable string EQ2OgreHarvestInjectableXML="${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/EQ2OgreHarvestInjectableXML.xml"

;function InjectEQ2OgreHarvestTab(int InjectionPoint)
function main(int InjectionPoint,int MoveTabTo=2)
{
	UIElement[${InjectionPoint}]:AddTab[OHarvest]
	;echo "${UIElement[${InjectionPoint}].Tab[OHarvest].FullName}"
	ui -reload -parent "${UIElement[${InjectionPoint}].Tab[OHarvest].FullName}" -skin eq2 "${EQ2OgreHarvestInjectableXML}"
	UIElement[${InjectionPoint}].Tab[OHarvest]:Move[${MoveTabTo}]
}
