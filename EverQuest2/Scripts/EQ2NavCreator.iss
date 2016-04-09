;-----------------------------------------------------------------------------------------------
; EQ2NavCreator.iss Version 1  Updated: 04/28/2008
;
; Written by: Amadeus  (Based upon EQ2PatherLegacy.iss by Blazer)
;
; v1.0 - * Initial Release
;-----------------------------------------------------------------------------------------------

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss

#define ADDPOINT f1
#define ADDPOINTNOCOLLISION ALT+F1
#define ADDNAMEPOINT f2
#define ADDNAMEDPOINTNOCOLLISION ALT+F2
#define SAVEPOINTS f3
#define TOGGLELSO ALT+F3
#define TOGGLEREGIONTYPE CTRL+F3
#define SETSPHERERADIUS F5
#define QUIT f11

variable(global) string SaveMode 
variable(global) bool SaveAsLSO
variable(global) string RegionCreationType
variable(global) string CreationMode
variable(global) string SaveToFile
variable(global) EQ2Mapper Mapper
variable(global) int CurrentTask
variable(global) float SphereRadius
variable(script) int HudX
variable(script) int HudY
variable(script) bool AutoPlot
variable(script) bool NoCollision
variable(script) bool PointToPoint



function main(... Args)
{
    if !${ISXEQ2(exists)}
    {
        echo "EQ2NavCreator:: ISXEQ2 must be loaded to use this script."
        return
    }
    do
    {
        waitframe
    }
    while !${ISXEQ2.IsReady}

    ;; defaults (Save to config file?)
    SaveAsLSO:Set[FALSE]
    RegionCreationType:Set["Box"]
    SphereRadius:Set[3]
    
	Script:Squelch
	
	
	if ${Args.Size} > 0
	{
	    variable int Iterator = 1
		do
		{
			if (${Args[${Iterator}].Equal[-auto]} || ${Args[${Iterator}].Find[-auto]} > 0)
				AutoPlot:Set[TRUE]
		    elseif (${Args[${Iterator}].Equal[-nocollision]} || ${Args[${Iterator}].Find[-nocollision]} > 0)
		        NoCollision:Set[TRUE]
		    elseif (${Args[${Iterator}].Equal[-PtoP]} || ${Args[${Iterator}].Find[-PtoP]} > 0)
		        PointToPoint:Set[TRUE]
		    elseif (${Args[${Iterator}].Equal[-lso]} || ${Args[${Iterator}].Find[-lso]} > 0)
		        SaveAsLSO:Set[TRUE]
		    elseif (${Args[${Iterator}].Equal[-?]})
		    {
        	    echo "Syntax:> run EQ2NavCreator [flags]"
        	    echo "Flags:  -auto         Points are added automatically as you move through space"
        	    echo "        -PtoP         Point-to-Point Mode:  The Mapper assumes that every point you create is connectable with the last point created.
        	    echo "                                            Collision checks, etc. are then done for all other connections."
        	    echo "        -nocollision  No collision checks at all are made when connecting points.)"	
        	    echo "        -lso          Indicates to the script that it should attempt to load a zone file in LSO format first.  If none exists, it will"
        	    echo "                      look for an XML file before giving up.  (The default setting is to search for XML and then LSO before giving up.)"
        	    return  
		    }	        
			else
				echo "EQ2NavCreator:: '${Args[${Iterator}]}' is not a valid command line argument:  Ignoring..."
		}
		while ${Iterator:Inc} <= ${Args.Size}
	}


	; Set the default location of the HUD
	HudX:Set[230]
	HudY:Set[200]

	echo "---------------------------"
	echo "EQ2NavCreator:: Initializing."

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Deal with command-line options and set "CreationMode"
    if (${AutoPlot})
    {
        echo "EQ2NavCreator:: Auto Plot mode ACTIVE."
        CreationMode:Set["Automatic Plotting"]
    }
    else
        CreationMode:Set["Manual Plotting"]
    if (${PointToPoint})
    {
        echo "EQ2NavCreator:: Point-to-Point map creation ACTIVE."
        Mapper.PointToPointMode:Set[TRUE]
        CreationMode:Concat[", Point-To-Point"]
    }
    if (${NoCollision})
    {
        echo "EQ2NavCreator:: No Collision mode ACTIVE."
        Mapper.NoCollisionDetection:Set[TRUE]
        CreationMode:Concat[", No Collision"]
    }
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    if (${SaveAsLSO})
    {
        echo "EQ2NavCreator:: Using file: '${Zone.ShortName}' (LSO File Format)"
        SaveMode:Set["LSO"]
        Mapper.UseLSO:Set[TRUE]
        SaveToFile:Set["${Zone.ShortName}"]
    }
    else
    {
        echo "EQ2NavCreator:: Using file: '${Zone.ShortName}.xml'"
        SaveMode:Set["XML"]
        Mapper.UseLSO:Set[FALSE]
        SaveToFile:Set["${Zone.ShortName}.xml"]
    }
    
    
    Mapper.MapFileRegionsType:Set[${RegionCreationType}]
    Mapper:LoadMap	
	echo "EQ2NavCreator:: Initialization complete."
    echo "---------------------------"

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; BINDS
    bind addpoint "ADDPOINT" "CurrentTask:Set[1]"
    bind addpointnocollision "ADDPOINTNOCOLLISION" "CurrentTask:Set[2]"
	bind addnamepoint "ADDNAMEPOINT" "CurrentTask:Set[3]"
	bind addnamepointnocollision "ADDNAMEDPOINTNOCOLLISION" "CurrentTask:Set[4]"
	bind savepoints "SAVEPOINTS" "CurrentTask:Set[5]"
	bind quit "QUIT" "CurrentTask:Set[6]"
	bind togglelso "TOGGLELSO" "CurrentTask:Set[7]"
	bind togglergt "TOGGLEREGIONTYPE" "CurrentTask:Set[8]"
	bind dosetsphereradius "SETSPHERERADIUS" "CurrentTask:Set[9]"
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; HUD
    HUD -add FunctionKey1  ${HudX},${HudY:Inc[15]} "F1     - Add a Region at your current location"
    HUD -add FunctionKey1b ${HudX},${HudY:Inc[15]} "ALT+F1 - Add a Region at your current location (and connect with no collision tests)"
	HUD -add FunctionKey2  ${HudX},${HudY:Inc[15]} "F2     - Add a Region with a name (FQN) you specify."
	HUD -add FunctionKey2b ${HudX},${HudY:Inc[15]} "ALT+F2 - Add a Region with a name (FQN) you specify (and connect with no collision tests)"
	
	HUD -add FunctionKey3  ${HudX},${HudY:Inc[25]} "F3     - Save all Regions."
	HUD -add FunctionKey3b ${HudX},${HudY:Inc[15]} "ALT+F3 - Toggle Save Mode"
	HUD -add FunctionKey3c ${HudX},${HudY:Inc[15]} "CTL+F3 - Toggle Region Creation Type"
	
	HUD -add FunctionKey5  ${HudX},${HudY:Inc[25]} "F5     - Set Sphere creation radius" 
	
	HUD -add FunctionKey11 ${HudX},${HudY:Inc[25]} "F11    - Exit EQ2NavCreator (and save all regions)"
	
	
	HUD -add RegionCreation ${HudX},${HudY:Inc[50]} "Region Creation Type:        \${RegionCreationType}"
	HUD -add hCreationMode  ${HudX},${HudY:Inc[15]} "Creation Mode:               \${CreationMode}"
	HUD -add SaveModeStatus ${HudX},${HudY:Inc[15]} "Save Mode:                   \${SaveMode} (\${SaveToFile})"
	
	HUD -add NavPointStatus ${HudX},${HudY:Inc[50]} "Last Nav Point Added:        \${Mapper.LastRegionAdded_Name} [\${Mapper.LastRegionAdded_X.Precision[2]}(x) \${Mapper.LastRegionAdded_Y.Precision[2]}(y) \${Mapper.LastRegionAdded_Z.Precision[2]}(z)]"
	HUD -add NavCountStatus ${HudX},${HudY:Inc[15]} "Total Number of Points Used: \${Mapper.CurrentZone.ChildCount}"
	
	HUDSet NavPointStatus -c FFFF00
	HUDSet NavCountStatus -c FFFF00	
	HUDSet SaveModeStatus -c FFFF00
	HUDSet RegionCreation -c FFFF00
	HUDSet hCreationMode -c FFFF00
	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	if (${Mapper.CurrentZone.ChildCount} == 0 && ${AutoPlot})
		CurrentTask:Set[1]

	Do
	{
		switch ${CurrentTask}
		{
		    case 1
		        CurrentTask:Set[0]
		        if (${RegionCreationType.Equal[Box]})
    		        Mapper:PlotBoxFromPoint[${Me.ToActor.Loc}]
    		    elseif (${RegionCreationType.Equal[Point]})
    		        Mapper:PlotPoint[${Me.ToActor.Loc}]
    		    else
    		        Mapper:PlotSphereFromPoint[${Me.ToActor.Loc},${SphereRadius}]
		        break
		        
		    case 2
		        CurrentTask:Set[0]
		        Mapper.NoCollisionDetection:Set[TRUE]
		        if (${RegionCreationType.Equal[Box]})
    		        Mapper:PlotBoxFromPoint[${Me.ToActor.Loc}]
    		    elseif (${RegionCreationType.Equal[Point]})
    		        Mapper:PlotPoint[${Me.ToActor.Loc}]
    		    else
    		        Mapper:PlotSphereFromPoint[${Me.ToActor.Loc},${SphereRadius}]
		        Mapper.NoCollisionDetection:Set[FALSE]
		        break
		    
			case 3
				CurrentTask:Set[0]
				InputBox "What name do you want to give this NavPoint?"
				if ${UserInput.Length}
				{
    		        if (${RegionCreationType.Equal[Box]})
        		        Mapper:PlotBoxFromPoint[${Me.ToActor.Loc},${UserInput},TRUE]
        		    elseif (${RegionCreationType.Equal[Point]})
        		        Mapper:PlotPoint[${Me.ToActor.Loc},${UserInput}]
        		    else
        		        Mapper:PlotSphereFromPoint[${Me.ToActor.Loc},${SphereRadius},${UserInput},TRUE]				        
				}
				break
				
			case 4
				CurrentTask:Set[0]
				InputBox "What name do you want to give this NavPoint?"
				if ${UserInput.Length}
				{
				    Mapper.NoCollisionDetection:Set[TRUE]
    		        if (${RegionCreationType.Equal[Box]})
        		        Mapper:PlotBoxFromPoint[${Me.ToActor.Loc},${UserInput},TRUE]
        		    elseif (${RegionCreationType.Equal[Point]})
        		        Mapper:PlotPoint[${Me.ToActor.Loc},${UserInput}]
        		    else
        		        Mapper:PlotSphereFromPoint[${Me.ToActor.Loc},${SphereRadius},${UserInput},TRUE]	
        		    Mapper.NoCollisionDetection:Set[FALSE]
				}
				break
			    
			case 5
				CurrentTask:Set[0]
				Mapper:Save
				;ANNOUNCE IS BROKEN announce "Navigational Points have been Saved" 1 3
				break
				
			case 6
				CurrentTask:Set[99]
				break
				
			case 7
			    CurrentTask:Set[0]
			    if (${SaveAsLSO})
			    {
			        echo "EQ2NavCreator:: Now saving to file: '${Zone.ShortName}.xml'"
			        SaveAsLSO:Set[FALSE]
			        SaveMode:Set["XML"]
			        Mapper.UseLSO:Set[FALSE]
			        SaveToFile:Set["${Zone.ShortName}.xml"]
			    }
			    else
			    {
			        echo "EQ2NavCreator:: Now saving to file: '${Zone.ShortName}' (LSO File Format)"
			        SaveAsLSO:Set[TRUE]
			        SaveMode:Set["LSO"]
			        Mapper.UseLSO:Set[TRUE]
			        SaveToFile:Set["${Zone.ShortName}"]
			    }
			    break
			    
			case 8
			    CurrentTask:Set[0]
			    if ${RegionCreationType.Equal[Sphere]}
			    {
			        RegionCreationType:Set[Box]
			        Mapper.MapFileRegionsType:Set[Box]
			        break
			    }
			    elseif ${RegionCreationType.Equal[Box]}
			    {
			        RegionCreationType:Set[Point]
			        Mapper.MapFileRegionsType:Set[Point]
			        break
			    }
			    elseif ${RegionCreationType.Equal[Point]}
			    {
			        RegionCreationType:Set[Sphere]
			        Mapper.MapFileRegionsType:Set[Sphere]
			        break
			    }	
			    else
			        break
			        	
		    case 9
				CurrentTask:Set[0]
				InputBox "Please enter the radius you wish to use when creating map files utilizing the 'sphere' creation mode."
				if ${UserInput.Length}
				{
    		        SphereRadius:Set[${UserInput}]
    		        Mapper.DefaultSphereRadius:Set[${SphereRadius}]		
    		        echo "EQ2NavCreator:: Now using a sphere radius of ${SphereRadius}"
    		    }
				break		        		    
		}
		
		if (${AutoPlot})
    		Mapper:Pulse
		waitframe
	}
	while ${CurrentTask}<11

	Script:End
}

function atexit()
{
    Mapper:Save
    
    bind -delete addpoint
    bind -delete addpointnocollision
	bind -delete addnamepoint
	bind -delete addnamepointnocollision
	bind -delete savepoints
	bind -delete quit
	bind -delete togglelso
	bind -delete togglergt
	bind -delete dosetsphereradius

    HUD -remove FunctionKey1
    HUD -remove FunctionKey1b
	HUD -remove FunctionKey2
	HUD -remove FunctionKey2b
	HUD -remove FunctionKey3
	HUD -remove FunctionKey3b
	HUD -remove FunctionKey3c
	HUD -remove FunctionKey5
	HUD -remove FunctionKey11
	HUD -remove NavPointStatus
	HUD -remove NavCountStatus
	HUD -remove SaveModeStatus
	HUD -remove RegionCreation
	HUD -remove hCreationMode
}
