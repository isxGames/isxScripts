
#include bohika/bobjects.iss
variable(global) bnav navi
function main()
{
	;variable bnav navi
	variable bool lso=FALSE
	declare loop bool global
	declare addmypoint bool global
	declare moveto bool global
	declare huntpoint bool global
	bind stopmap f1 "loop:Set[FALSE]"
	bind addnamed f2 "addmypoint:Set[TRUE]"
	bind move f10 "moveto:Set[TRUE]"
	bind huntpoint f3 "huntpoint:Set[TRUE]"

	loop:Set[TRUE]
	addmypoint:Set[FALSE]
	call navi.Initialize
	if !${Return}
	{
		echo Failed to initialize navigation, quitting script
		return
	} 
	do
	{
		if ${huntpoint}
		{
			navi:AddHuntPoint
			huntpoint:Set[FALSE]
		}
		
		if ${addmypoint}
		{
			InputBox "Point Name?"
			if ${UserInput.Length}
			{
			;	navi:AddWithConnections[200, ${UserInput}]
				navi:AddNamedPoint[${UserInput}]
			}
			addmypoint:Set[FALSE]
		}
		elseif ${moveto}
		{
			InputBox "Where To?"
			if ${UserInput.Length}
			{
				call navi.FindPath ${UserInput}
			}
			do
			{
				call navi.TakeNextHop
				if !${Return}
				{
					call navi.FindPath ${UserInput}
					if !${Return}
					{
						break
					}
				}
			}
			while ${bpathindex}<=${mypath.Hops} && ${Return}
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			moveto:Set[FALSE]
		}
		else
		{
			;navi:AutoByDistance[200]
			;navi:AutoMapSphere[1000]
			navi:AutoBox
		}
;		navi:ConnectOnMove
		waitframe
	}
	while ${loop}
;	if ${lso}
;	{
;		LNavRegion[${Me.Chunk}]:Export[-lso,${ConfigPath}/${Me.Chunk}.lso]
;		LNavRegion[${Me.Chunk}]:Remove
;		echo Exported to LSO
;		
;	}
;	else
;	{
;		LNavRegion[${Me.Chunk}]:Export[${ConfigPath}/${Me.Chunk}.xml]
;		LNavRegion[${Me.Chunk}]:Remove
;		echo Exported to XML
;	}
	navi:SavePaths
	bind -delete stopmap
	bind -delete addnamed
	bind -delete move

}
function atexit()
{
	;Script has been ended, release the movement keys
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	endscript Connector

}