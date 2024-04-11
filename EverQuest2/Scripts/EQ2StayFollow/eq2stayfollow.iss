;---------------------------------------------------------------
; eq2stayfollow.iss Version 0.1 Updated: 01/15/10
;
; Written By: bjcasey
; Coaching By: Hendrix, OgreB and Kannkor
; Minor corrections, additions, and first SVN ver. by: Valerian
;
; Description:
; ------------
; Keeps characters on auto follow during or out of combat
; Syntax: run eq2stayfollow
;
; To Do List
; ----------
; Learn to spell check "Definitions" 
;
;----------------------------------------------------------------

; Variable Definitions
variable string followname
variable bool start

; Start of the main script
function main()
{
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/EQ2-Green/EQ2-Green.xml"
	ui -reload -skin EQ2-Green "${LavishScript.HomeDirectory}/Scripts/EQ2StayFollow/UI/EQ2StayFollow.xml"
	start:Set[FALSE]
	
	do
	{
		if (${start})
		{
			if (${Me.WhoFollowing(exists)})
			{
				wait 20
			}
			else
			{
				eq2execute follow ${followname}
							
				wait 20
			}
		}
	}
	while ${UIElement[EQ2StayFollow].Visible}
}

function atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2StayFollow/UI/EQ2StayFollow.xml"
}