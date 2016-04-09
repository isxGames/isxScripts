;-----------------------------------------------------------------------------------------------
; EQ2Pather.iss Version 1.8  Updated: 07/30/06 
; by Syliac
; Written by: Blazer 
;
; Revision History
; ----------------
; v1.8 - * Fixed the xml path.
;
; v1.7 - * Fixed some minor bugs.
;
; v1.6 - * Fixed declaration of global variables so they are deleted when script ends.
;	 * 'run eq2pather combat' is used to plot a nav path to work with eq2bot.
;
; v1.5 - * Several code changes.
;	 * You Can now move to a point if in Auto mode. This allows for more complex navigational points
;	 to be created. As an example, you can plot points till you get to some intersection.
;	 Label that point to say 'Intersection 1' then continue plotting your points till you get to some 
;	 other specific location. Press F4, and type in 'Intersection 1'. This will move you back there
;	 without plotting additional points. You can then continue plotting points on another route.
;
; v1.4 - * Points created with a label will have a note added as 'keypoint'. This will allow
; 	 us to list key points in any navigational file easily.
;
; v1.3 - * Added an automatic navigational plotter.
;	 example; type 'run eq2pather auto 30' will automatically plot a point if you have moved
;	 more than 30 yards from the last plotted point. 
;	 If you dont specify a distance, then it defaults to 20.
;	 You can at any time plot additional points or a point with a name.
;	 You can also change the current distance to something else while the script is running.
;
; v1.0 - * Initial Release
;-----------------------------------------------------------------------------------------------

#include moveto.iss

#define ADDPOINT f1
#define ADDNAMEPOINT f2
#define SAVEPOINTS f3
#define LASTPOINT f4
#define CLEARNAVFILE f5
#define CHANGEDIST f6
#define CAMP f7
#define PULL f8
#define QUIT f11

function main(string mode, int parm2)
{
	declare filename string script
	declare pointcount int global
	declare lastpoint string global " "
	declare displayLP string global " "
	declare nearestpoint string global " "
	declare CurrentTask int global 0
	declare pathindex int local 0
	declare modetype int script 0
	declare HudX int script
	declare HudY int script
	declare LastX float global 0
	declare LastY float global 0
	declare LastZ float global 0
	declare plotdist int global 20
	declare CurrentPL string global " "
	declare xmlpathH string script "./EQ2Harvest/Navigational Paths/"
	declare xmlpathC string script "./EQ2Bot/Navigational Paths/"
	declare configfile string script
	declare CurrentCamp int global 0
	declare CurrentPull int global 0

	Script:Squelch

	; Set the default location of the HUD
	HudX:Set[5]
	HudY:Set[55]

	plotdist:Set[${parm2}]

	if !${mode.Length} 
	{
		echo "Syntax: run eq2pather <auto|combat> <distance>"
		echo "Where <auto> specifies EQ2Pather to automatically plot co-ordiantes when you exceed 20 yards from the last point."
		echo "If you dont specify <auto> or <combat> then it will run in manual mode (i.e you need to press a key to plot each co-ordinate)."
		echo "<distance> is an optional paramater, if you want the distance to be something other than 20."
		echo "<combat> is used in conjunction with EQ2Bot.iss. Default distance is set to 5"
	}
	else
	{
		if ${mode.Equal[combat]}
		{
			modetype:Set[2]
		}
		else
		{
			modetype:Set[1]
		}
	}

	if !${plotdist}
	{
		if ${mode.Equal[combat]}
		{
			plotdist:Set[2]
		}
		else
		{
			plotdist:Set[20]
		}
	}

	if ${mode.Equal[combat]}
	{
		filename:Set[${xmlpathC}${Zone.ShortName}.xml]
	}
	else
	{
		filename:Set[${xmlpathH}${Zone.ShortName}.xml]
	}

	Navigation -reset
	Navigation -load "${filename}"
	pointcount:Set[${Navigation.World[${Zone.ShortName}].Points}]

	EQ2Echo ${filename} Loaded!

	bind addpoint "ADDPOINT" "CurrentTask:Set[1]"
	bind addnamepoint "ADDNAMEPOINT" "CurrentTask:Set[2]"
	bind savepoints "SAVEPOINTS" "CurrentTask:Set[3]"
	bind gotolastpoint "LASTPOINT" "CurrentTask:Set[4]"
	bind changedist "CHANGEDIST" "CurrentTask:Set[6]"
	bind clearnavfile "CLEARNAVFILE" "CurrentTask:Set[5]"
	bind camp "CAMP" "CurrentTask:Set[7]"
	bind pull "PULL" "CurrentTask:Set[8]"
	bind quit "QUIT" "CurrentTask:Set[9]"

	if ${modetype}
	{
		HUD -add NavMode ${HudX},${HudY} "Navigation Mode: Auto (Distance: \${plotdist})"
	}
	else
	{
		HUD -add NavMode ${HudX},${HudY} "Navigation Mode: Manual"
	}
	HUD -add FunctionKey1 ${HudX},${HudY:Inc[15]} "ADDPOINT - Adds a Navigational Point."
	HUD -add FunctionKey2 ${HudX},${HudY:Inc[15]} "ADDNAMEPOINT - Adds a Navigational Point with a Label you specify."
	HUD -add FunctionKey3 ${HudX},${HudY:Inc[15]} "SAVEPOINTS - Saves ALL Navigational Points."
	HUD -add FunctionKey4 ${HudX},${HudY:Inc[15]} "LASTPOINT - Moves you to a specified Navigational Point."
	HUD -add FunctionKey5 ${HudX},${HudY:Inc[15]} "CLEARNAVFILE - Clears the Navigational file."
	if ${modetype}
	{	
		HUD -add FunctionKey6 ${HudX},${HudY:Inc[15]} "CHANGEDIST - Specify a new distance value to use between plotted points."
		LastX:Set[${Me.X}]
		LastY:Set[${Me.Y}]
		LastZ:Set[${Me.Z}]
	}
	if ${modetype}==2
	{
		HUD -add FunctionKey7 ${HudX},${HudY:Inc[15]} "CAMP - Labels the current point as Camp \${Math.Calc[${CurrentCamp}+1].Int}"
		HUD -add FunctionKey8 ${HudX},${HudY:Inc[15]} "PULL - Labels the current point as Pull \${Math.Calc[${CurrentPull}+1].Int}"
	}
	HUD -add FunctionKey11 ${HudX},${HudY:Inc[15]} "QUIT - Exit EQ2Pather"
	HUD -add NavPointStatus ${HudX},${HudY:Inc[30]} "Last Nav Point Added: \${CurrentPL} [\${LastX}(x) \${LastY}(y) \${LastZ}(z)]" 
	HUD -add NavConnectStatus ${HudX},${HudY:Inc[15]} "Last Connection: \${displayLP} to \${CurrentPL}"
	HUD -add NavCountStatus ${HudX},${HudY:Inc[15]} "Total Number of Points Used: \${pointcount}"
	HUDSet NavPointStatus -c FFFF00
	HUDSet NavConnectStatus -c FFFF00
	HUDSet NavCountStatus -c FFFF00

	if ${pointcount}==0
	{
		CurrentTask:Set[2]
	}

	Do
	{
		if ${modetype}
		{
			call AutoPlotPoint
		}

		switch ${CurrentTask} 
		{ 
			case 1
				CurrentTask:Set[0]
				pointcount:Inc
				call addpoint ${Zone.ShortName}_${pointcount}
				;ANNOUNCE IS BROKEN announce "\\#FF6E6ENavigational Point Added" 1 2
				break
			case 2
				CurrentTask:Set[0]
				InputBox "What name do you want to give this NavPoint?"
				if ${UserInput.Length}
				{
					pointcount:Inc
					call addpoint "${UserInput}" 1
					;ANNOUNCE IS BROKEN announce "\\#FF6E6ENavigational Point Added" 1 2
				}
				break
			case 3
				CurrentTask:Set[0]
				call SaveNavPoints
				;ANNOUNCE IS BROKEN announce "Navigational Points have been Saved" 1 3
				break
			case 4
				CurrentTask:Set[0]
				nearestpoint:Set[${Navigation.World[${Zone.ShortName}].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]
				InputBox "What Navigational Point do you want to move to?"
				NavPath "${Zone.ShortName}" "${nearestpoint}" "${UserInput}"
				if ${NavPath.Points}>0
				{
					pathindex:Set[1]
					do
					{
						call moveto ${NavPath.Point[${pathindex}].X} ${NavPath.Point[${pathindex}].Z} 2
					}
					while ${pathindex:Inc}<=${NavPath.Points}

					LastX:Set[${Me.X}]
					LastY:Set[${Me.Y}]
					LastZ:Set[${Me.Z}]
					displayLP:Set[${UserInput}]
					lastpoint:Set[${UserInput}]
				}
				else
				{
					EQ2Echo No valid path found
				}
				break
			case 5
				CurrentTask:Set[0]
				MessageBox -yesno "Are you sure you want to erase ALL nav points?"
				if ${UserInput.Equal[Yes]}
				{
					Navigation -reset
					Navigation -dump "${filename}"
					pointcount:Set[0]
					EQ2Echo Navigational File: ${filename} is now CLEARED!
				}
				CurrentCamp:Set[0]
				CurrentPull:Set[0]
				break
			case 6
				CurrentTask:Set[0]
				InputBox "What would you like the new distance from the last plotted point to be?"
				if ${UserInput(exists)}
				{
					plotdist:Set[${UserInput}]
				}
				else
				{
					plotdist:Set[20]
				}
				break
			case 7
				CurrentTask:Set[0]
				pointcount:Inc
				CurrentCamp:Inc
				call addpoint "Camp ${CurrentCamp}"
				;ANNOUNCE IS BROKEN announce "\\#FF6E6ENavigational Point Added" 1 2
				break

			case 8
				CurrentTask:Set[0]
				pointcount:Inc
				CurrentPull:Inc
				call addpoint "Pull ${CurrentPull}"
				;ANNOUNCE IS BROKEN announce "\\#FF6E6ENavigational Point Added" 1 2
				break

			case 9
				CurrentTask:Set[10]
				break
		}
		waitframe
	}
	while ${CurrentTask}<10

	Script:End
}

function addpoint(string PointLabel, int notereq)
{
	CurrentPL:Set[${PointLabel}]

	LastX:Set[${Me.X}]
	LastY:Set[${Me.Y}]
	LastZ:Set[${Me.Z}]

	NavPoint -set "${Zone.ShortName}" "${CurrentPL}" ${LastX} ${LastY} ${LastZ}

	if ${notereq}
	{
		Navigation.World[${Zone.ShortName}].Point[${PointLabel}]:SetNote[keypoint]
		NavPoint -set "${Zone.ShortName}" "${PointLabel}" ${LastX} ${LastY} ${LastZ} "keypoint"
	}

	if ${Navigation.World[${Zone.ShortName}].Points}>1
	{
		NavPoint -connect -bidirectional "${Zone.ShortName}" "${lastpoint}" "${CurrentPL}"
	}

	displayLP:Set[${lastpoint}]
	lastpoint:Set[${CurrentPL}]
}

function SaveNavPoints()
{
	EQ2Echo Saving ${pointcount} Nagivational Points.
	Navigation -dump "${filename}"
}

function AutoPlotPoint()
{
	if ${Math.Distance[${Me.X},${Me.Z},${LastX},${LastZ}]}>${plotdist}
	{
		pointcount:Inc
		call addpoint "${Zone.ShortName}_${pointcount}"
	}
}

function atexit()
{
	Navigation -reset

	bind -delete addpoint 
	bind -delete addnamepoint
	bind -delete savepoints 
	bind -delete clearnavfile
	bind -delete quit
	bind -delete changedist
	bind -delete camp
	bind -delete pull
	HUD -remove FunctionKey6
	bind -delete gotolastpoint
	HUD -remove FunctionKey4
	HUD -remove NavMode
	HUD -remove FunctionKey1
	HUD -remove FunctionKey2
	squelch	HUD -remove FunctionKey3
	HUD -remove FunctionKey5
	HUD -remove FunctionKey7
	HUD -remove FunctionKey8
	HUD -remove FunctionKey11
	HUD -remove NavPointStatus
	HUD -remove NavCOnnectStatus
	HUD -remove NavCountStatus

	DeleteVariable pointcount
	DeleteVariable lastpoint
	DeleteVariable displayLP
	DeleteVariable nearestpoint
	DeleteVariable CurrentTask
	DeleteVariable LastX
	DeleteVariable LastY
	DeleteVariable LastZ
	DeleteVariable plotdist
	DeleteVariable CurrentPL
	DeleteVariable CurrentCamp
	DeleteVariable CurrentPull
}
