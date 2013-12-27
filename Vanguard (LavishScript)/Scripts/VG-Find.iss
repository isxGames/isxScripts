;;
;; Find
;;
;; Quick little routine that will allow you to find
;; targets by their name and/or title
;;
;; Written by Zandros on 26 Dec 2013
;;

variable bool doFindTarget = TRUE
variable bool doFindTitle = FALSE
variable bool doPause = TRUE
variable string FindTarget = ""
variable string FindTitle = ""
variable int i = 0

function main(string GivenName)
{
	FindTarget:Set["${GivenName}"]

	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-Find.xml"
	
	while ${Me(exists)}
		call Find
}

function Find()
{
	if ${doPause} || ${Me.Target(exists)}
		return

	variable int TotalPawns
	variable index:pawn CurrentPawns
	TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]

	for (i:Set[1] ; ${i}<${TotalPawns} && !${Me.InCombat} && ${Me.Encounter}==0 ; i:Inc)
	{
		if ${doFindTarget}
		{
			if ${CurrentPawns.Get[${i}].Name.Find[${FindTarget}]}
			{
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 3
				return
			}
		}
		if ${doFindTitle}
		{
			if ${CurrentPawns.Get[${i}].Title.Find[${FindTitle}]}
			{
				Pawn[id,${CurrentPawns.Get[${i}].ID}]:Target
				wait 3
				return
			}
		}
	}
	wait 10 !${Me.Target(exists)}
}