;-----------------------------------------------------------------------------------------------
; autodisarm.iss - V1.0
; 
; 	By Tyric
; 	Updated: 12/20/2006
; 
; Description:
; ------------
; Disarms any chests that you walk near automatically and will optionally auto open them.
;
; See settable options for other features
; 
;-----------------------------------------------------------------------------------------------

/*
 * BEGIN USER SETTABLE OPTIONS
 */
variable(script) bool AUTO_OPEN=TRUE								/* set to TRUE to open chests after disarming 				 			*/
variable(script) int SCAN_DISTANCE=20								/* the default distance the script will scan for chests        			*/
variable(script) int SCAN_INTERVAL=1								/* the interval in seconds that the script will do the scan    			*/
variable(script) bool OUTPUT_TO_EQ2=FALSE							/* set to FALSE if you just want info to go to console		   			*/
variable(script) bool OPEN_WHEN_RAIDING=FALSE						/* set to TRUE if you want to open chests while in a raid      			*/
variable(script) bool CREATE_WAYPOINTS=TRUE							/* set to TRUE if you want to waypoints to be created to distant chests	*/
variable(script) string END_SCRIPT_KEY=f11

/* 
 * END USER SETTABLE OPTIONS
 */
 
variable(script) string VERSION="1.0"								/* DO NOT CHANGE */
variable(script) int disarm_count=0									/* DO NOT CHANGE */
variable(script) bool DEBUG_MODE=FALSE								/* for debugging */
variable(script) ChestInfo CHESTINFOARRAY[10]						/* Setup an array to store id's to check against so we don't continually */
																	/* barrage the client/server with apply_verb commands. 				 	 */

objectdef ChestInfo
{
	variable int iChestID
	variable bool bWaypoint
	variable bool bDisarmed	
	
	method Initialize()
	{
		iChestID:Set[-1]
		bWaypoint:Set[FALSE]
		bDisarmed:Set[FALSE]
	}
	method SetDisarmed(bool in_value)
	{
		bDisarmed:Set[${in_value}]
	}
	method SetWaypoint(bool in_value)
	{
		bWaypoint:Set[${in_value}]
	}
	method SetID(int in_id) 
	{
		iChestID:Set[${in_id}]
	}
	member:string ToText()
	{
		return "ChestInfo ID='${iChestID}' Disarmed='${bDisarmed}' Waypoint='${bWaypoint}'"
	} 
	member ID=${iChestID}
	member Waypoint=${bWaypoint}
	member Disarmed=${bDisarmed}
}

function main(int in_distance)  
{  
	variable int wait_secs
	variable int scan_dist
	variable int icount
	
	wait_secs:Set[${SCAN_INTERVAL}*20]

	if !${in_distance <= ${SCAN_DISTANCE}}
		scan_dist:Set[${SCAN_DISTANCE}]
	else
		scan_dist:Set[${in_distance}]
	
	call AnnounceAutoDisarmStartup

	call CheckScriptRequirements

	if ${Return}==FALSE
		return	

	squelch bind EndAutoDisarm ${END_SCRIPT_KEY} "Script[autodisarm]:End"
	AddTrigger OnChestDisarmed "You disarm the trap on@*@"
	AddTrigger OnChestDisarmFailed "You failed to disarm the trap on@*@"

	do 
	{
		if !${QueuedCommands} 
		{
			Wait ${wait_secs}
			
			call ScanForChestsToDisarm ${scan_dist}
			if ${Return} == TRUE
			{
				for (icount:Set[1] ; ${icount}<=${CHESTINFOARRAY.Size} ; icount:Inc)
				{
					if ${CHESTINFOARRAY[${icount}].ID} == -1
						continue
					
					if ${CREATE_WAYPOINTS} == TRUE
						call AttemptWaypointToChest ${icount}
						
					call AttemptDisarmChest ${icount}
				}
			}
		}
		else
			ExecuteQueued
	}
	while ${ISXEQ2(exists)}
}

function:bool ScanForChestsToDisarm(int in_distance)
{
	variable int tcount=1
	variable int tmprnd
	
	if !${Actor[Chest,range,${in_distance}](exists)}
	{
		return FALSE
	}
	
	EQ2:CreateCustomActorArray[byDist,${in_distance}]
	do
	{
		if !${CustomActor[${tcount}].IsChest}
			continue

		/* Check to see if this chest was already found */
		call GetChestInfo "${CustomActor[${tcount}].ID}"
		if ${Return} == -1
		{
			/* Found Unique Chest! Add to chestinfoarray for disarming	*/
 			call ChestInfoArrayPush ${CustomActor[${tcount}].ID}
		}
 	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
	return TRUE
}

function:bool AttemptWaypointToChest( int cInfoID ) 
{
	/* check if id is not -1 */
	if ${cInfoID} == -1
		return FALSE

	/* check if waypoint has already been created */
	if ${CHESTINFOARRAY[${cInfoID}].Waypoint} == TRUE
		return FALSE

	if ${Actor[${CHESTINFOARRAY[${cInfoID}].ID}].Distance}>=5
	{
		/* Set waypoint to chest */
		EQ2execute "/waypoint ${Actor[${CHESTINFOARRAY[${cInfoID}].ID}].X},${Actor[${CHESTINFOARRAY[${cInfoID}].ID}].Y},${Actor[${CHESTINFOARRAY[${cInfoID}].ID}].Z}"
		
		CHESTINFOARRAY[${cInfoID}]:SetWaypoint[TRUE] 	/* mark set so we don't do it again */
		return TRUE
	}
	return FALSE
}

function:bool AttemptDisarmChest( int cInfoID ) 
{
	/* check if id is not -1 */
	if ${cInfoID} == -1
		return FALSE
		
	/* check if chest has been disarmed already */
	if ${CHESTINFOARRAY[${cInfoID}].Disarmed} == TRUE
		return FALSE
		
	if ${Actor[${CHESTINFOARRAY[${cInfoID}].ID}].Distance}<=4
	{
		EQ2execute "/apply_verb ${CHESTINFOARRAY[${cInfoID}].ID} disarm"
		disarm_count:Inc
		
		if ${AUTO_OPEN}==TRUE 
		{
			if !${Me.InRaid} || (${Me.InRaid} && ${OPEN_WHEN_RAIDING})
			{
				call FuzzyNum 20
				wait ${Return}
				EQ2execute "/apply_verb ${CHESTINFOARRAY[${cInfoID}].ID} open"
				CHESTINFOARRAY[${cInfoID}]:SetDisarmed[TRUE]
			}
		}
		call PrintChestInfoArray
		return TRUE
	}
	return FALSE
}

; shifts all ids and inserts id at head of array
; last id is lost after this call
function ChestInfoArrayPush(int id) 
{
	variable int i
	
	for (i:Set[${CHESTINFOARRAY.Size}] ; ${i}>1 ; i:Dec)
	{
		CHESTINFOARRAY[${i-1}]:SetID[${CHESTINFOARRAY[${i}].ID}]
		CHESTINFOARRAY[${i-1}]:SetWaypoint[${CHESTINFOARRAY[${i}].Waypoint}]
		CHESTINFOARRAY[${i-1}]:SetDisarmed[${CHESTINFOARRAY[${i}].Disarmed}]
	}
	
	CHESTINFOARRAY[1]:SetID[${id}]
	CHESTINFOARRAY[1]:SetWaypoint[FALSE]
	CHESTINFOARRAY[1]:SetDisarmed[FALSE]
	call adAnnounce "Added Chest (${id}) to ChestInfoArray."
}

function:int GetChestInfo(int id) 
{
	variable int i=1
	
	for (i:Set[1] ; ${i}<=${CHESTINFOARRAY.Size} ; i:Inc)
	{
		if ${CHESTINFOARRAY[${i}].ID}==${id}
			return ${i}
	}
	return -1
}

function PrintChestInfoArray()
{
	call adAnnounce "CHESTINFOARRAY"
	call adAnnounce "--------------"
	variable int i=1

	for (i:Set[1] ; ${i}<=${CHESTINFOARRAY.Size} ; i:Inc)
	{
		call adAnnounce "${CHESTINFOARRAY[${i}].ToText}"
	}
	call adAnnounce "--------------"
}

function ClearDisarmedChests() 
{
	variable int i

	for (i:Set[1] ; ${i}<=${CHESTINFOARRAY.Size} ; i:Inc)
	{
		if ${CHESTINFOARRAY[${i}].Disarmed} == TRUE
		{
			CHESTINFOARRAY[${i}]:SetID[-1]
			CHESTINFOARRAY[${i}]:SetWaypoint[FALSE]
			CHESTINFOARRAY[${i}]:SetDisarmed[FALSE]
		}
	}
}

/* 
 * Add a little fuzziness to attempt to simulate a user
 * this function returns a random value X that is:
 * 10-value > X > 10+value
 */
function:int FuzzyNum(int value) 
{
	variable int fuzzy=0
	
	fuzzy:Set[(${Math.Rand[(${value}+10)]}+5)]
	return ${fuzzy}
}

function:bool CheckScriptRequirements()
{
	variable bool retval=FALSE

	call adAnnounce ${Me.SubClass}
	if ${ISXEQ2(exists)}==FALSE
	{
		retval:Set[FALSE]
		call adAnnounce "CheckScriptRequirements: ISXEQ2 extension required for this script."
	}		
	else
	{	
		switch ${Me.SubClass}	
		{
			case Assassin
			case Swashbuckler
			case Ranger
			case Brigand 
			case Dirge
			case Troubador
				retval:Set[TRUE]
				break
				
			default
				retval:Set[FALSE]
				call adAnnounce "CheckScriptRequirements: Non-scout class detected."
				break
		}
	}	
	return ${retval}
}

function OnChestDisarmed(string Line)
{
	call adAnnounce "AUTODISARM SUCCESS ::: ${Line}"
	call ClearDisarmedChests
}

function OnChestDisarmFailed(string Line)
{
	call adAnnounce "AUTODISARM SUCCESS ::: ${Line}"
	call ClearDisarmedChests
}

function AnnounceAutoDisarmStartup()
{
	ConsoleClear
	/* Tell the user that the script has initialized and is running! */
	call adAnnounce "***********************************************************"
	call adAnnounce "***                                                     ***"
	call adAnnounce "***              Autodisarm Version ${VERSION}                 ***"
	call adAnnounce "***              brought to you by Tyric                ***"
	call adAnnounce "***                                                     ***"
	call adAnnounce "***********************************************************"
	call adAnnounce "Hit ${END_SCRIPT_KEY} to end script."
	call adAnnounce "\n"
}

function adAnnounce( string line )
{
	if ${OUTPUT_TO_EQ2}
		EQ2Echo "AutoDisarm - ${line}"
	else
		echo "AutoDisarm:::${line}"
		
	if ${DEBUG_MODE}==TRUE
	{
		Redirect -append AutoDisarmDbg.txt echo "AutoDisarm:::${line}" 	
	}
}

function atexit()
{
	call adAnnounce "Script Ended.  Autodisarmed ${disarm_count} chests!"
	squelch bind -delete EndAutoDisarm
}