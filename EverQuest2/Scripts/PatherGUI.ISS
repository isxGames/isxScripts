;-----------------------------------------------------------------------------------------------
; PatherGUI.iss Version 1.0  Updated: 04/20/07 
; Written by: cr4zyb4rd
;
; v1.0 - * Initial Release
;
; Description
; This file is to be included by other scripts.  InjectPatherTab creates a tab as a child of an
; existing TabControl, the FQN of which should be passed as the first argument.  The second
; argument specifies the directory to use for the zone-specific path files themselves.
; This is intended as a replacement for the existing EQ2Pather and EQ2Harvestpath scripts.
;-----------------------------------------------------------------------------------------------

#define _PATHERGUI_

variable(global) filepath PatherFilepath
variable(global) string PatherParent

variable string PatherGUI="${LavishScript.HomeDirectory}/Scripts/UI/PatherGUI.xml"

function InjectPatherTab(string InjectionPoint, string ConfigPath)
{
	PatherFilepath:Set[${ConfigPath}]
	PatherParent:Set[${InjectionPoint}]
	UIElement[${InjectionPoint}]:AddTab[Pather]
	ui -reload -parent "pather@${InjectionPoint}" -skin eq2 "${PatherGUI}"
}

; you don't really need to call this, as dangling children are destroyed when their parents are
; unloaded
function DestroyPatherTab()
{
	ui -unload ${PatherGUI}
}