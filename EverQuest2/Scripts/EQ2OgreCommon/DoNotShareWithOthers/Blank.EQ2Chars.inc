;***********************
;Authorization, and auto login information for "Ogre" scripts.
;Created by Kannkor
;Authorization only requires Toonnames
;Auto-login requires all 4 fields to be filled out


;Variables are declared in main file
;variable string CharInfo[200,4]
;CharInfo[1,1] Will be char name
;CharInfo[1,2] Will be Password
;CharInfo[1,3] Will be Login Name
;CharInfo[1,4] Will be Server Name

function SetUpUplink()
{
	UplinkInfo[${UplinkCount:Inc}]:Set[Computername1]
	UplinkInfo[${UplinkCount:Inc}]:Set[computername2]
}

function SetUpChars()
{
variable int TempCounter=1
CharInfo[${TempCounter},1]:Set[ToonName]
CharInfo[${TempCounter},2]:Set[Password]
CharInfo[${TempCounter},3]:Set[LoginName]
CharInfo[${TempCounter},4]:Set[ServerName]
TempCounter:Inc
CharInfo[${TempCounter},1]:Set[ToonName]
CharInfo[${TempCounter},2]:Set[Password]
CharInfo[${TempCounter},3]:Set[LoginName]
CharInfo[${TempCounter},4]:Set[ServerName]

}