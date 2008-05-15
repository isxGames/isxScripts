
;-----------------------------------------------------------------------------------------------
; EQ2Track.iss Version 1.0.2a Updated: 05/11/08 by Equidis
;-----------------------------------------------------------------------------------------------
; EQ2 Track Created by Equidis
;-----------------------------------------------------------------------------------------------

; ** Additional credits to Karye & Blazer: Some of the UI & Elements & Coding
; used were taken from previous version of EQ2BotCommand **

;-------------------------------------
; Immunity Variables
;-------------------------------------

	variable bool bypassAggro
	variable bool triggerImmunity
	variable int immunityRemaining
	variable int startTimer
	variable int timerDiff

;-------------------------------------

;-------------------------------------
; Filter Variables
;-------------------------------------

	variable bool Aggro
	variable bool passedFilters[3]
	variable bool useFilters[3]
	variable string filterTypes[3]
	variable int minLevel
	variable int maxLevel
	variable string filter
	variable bool conditionsPassed

;-------------------------------------

;-------------------------------------
; General
;-------------------------------------

	variable bool Tracking
	variable bool addItemToList
	variable string itemInfo

;-------------------------------------



function zoneWait()
{
	if ${EQ2.Zoning}
	{
		do
		{
			wait 05
		}
		while ${EQ2.Zoning}

		triggerImmunity:Set[TRUE]
		immunityRemaining:Set[20]
		startTimer:Set[${Time.Timestamp}]
		timerDiff:Set[0]
	}
}



function main()
{
    ;-------------------------------------
    ; Initialize Filter Types
    ;-------------------------------------
    	passedFilters[1]:Set[FALSE]
    	passedFilters[2]:Set[FALSE]
    	passedFilters[3]:Set[FALSE]
    ;-------------------------------------
    
    
    triggerImmunity:Set[TRUE]
    immunityRemaining:Set[20]
    
    Tracking:Set[TRUE]
    
    ui -reload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
    ui -reload -skin eq2skin "${LavishScript.HomeDirectory}/Scripts/EQ2Track/UI/EQ2Track.xml"
    
    variable int tcount
    variable int ccount
    variable string searchType


    ;-------------------------------------
    ; Never-ending Loop
    ;-------------------------------------
    
    do
    {
        ;-------------------------------------
        ; byLevel Filtering Loader
        ;-------------------------------------
        
        minLevel:Set[${UIElement[TrackMinLevel@EQ2 Track].Text}]
        maxLevel:Set[${UIElement[TrackMaxLevel@EQ2 Track].Text}]
        
    	if ${minLevel} > 0 && ${maxLevel} > 0
    		useFilters[1]:Set[TRUE]
    	else
    		useFilters[1]:Set[FALSE]
        
        
        ;-------------------------------------
        ; byAggro Filtering Loader
        ;-------------------------------------
        
    	if ${UIElement[TrackAggro@EQ2 Track].Checked}
    		useFilters[2]:Set[TRUE]
    	else
    		useFilters[2]:Set[FALSE]
        
        ;------------------------------------------
        ; applyFilter Full Info Filtering Loader
        ;------------------------------------------
        
        filter:Set[${UIElement[TrackFilter@EQ2 Track].Text}]
        
    	if ${filter.Equal[NULL]} || ${filter.Length} <= 0
    		useFilters[3]:Set[FALSE]
    	else
    		useFilters[3]:Set[TRUE]
        

        ;------------------------------------------
        ;------------------------------------------
        ;------------------------------------------
        
        
        ;-------------------------------------
        ; Begin Looping through Tracked Items
        ;-------------------------------------
        tcount:Set[0]
        
        UIElement[TrackItems@EQ2 Track]:ClearItems
        
        EQ2:CreateCustomActorArray[byDist,300]
        do
        {
            if ${EQ2.Zoning}
                break
            
            itemInfo:Set[${CustomActor[${tcount}].Level}\t (${CustomActor[${tcount}].Type}) ${CustomActor[${tcount}].Name} ${CustomActor[${tcount}].Class} ${CustomActor[${tcount}].Distance}]
            
            ;------------------------------------------
            ; byLevel Filtering Procedure
            ;------------------------------------------	
            
            if ${useFilters[1]}
            {
            	if ${CustomActor[${tcount}].Level} > 0
            	{
            		if ${CustomActor[${tcount}].Level} > ${minLevel} && ${CustomActor[${tcount}].Level} < ${maxLevel}
            			passedFilters[1]:Set[TRUE]
            		else
            			passedFilters[1]:Set[FALSE]
            	}
            	else
            	{
            		; Actor has no level, automatically byPass level checking, and approve the item for listing
            		passedFilters[1]:Set[TRUE]
            	}
            }
            else
            	passedFilters[1]:Set[TRUE]
            
            ;------------------------------------------
            ; byAggro Filtering Procedure
            ;------------------------------------------	
            
            if ${useFilters[2]}
            {
            	if ${CustomActor[${tcount}].IsAggro} || ${bypassAggro}
            		passedFilters[2]:Set[TRUE]
            	else
            		passedFilters[2]:Set[FALSE]
            }
            else
            	passedFilters[2]:Set[TRUE]
            
            ;------------------------------------------
            ; type Filter Filtering Procedure
            ;------------------------------------------	
            if ${useFilters[3]}
            {
            	if ${itemInfo.Find[${filter}]}
            		passedFilters[3]:Set[TRUE]
            	else
            		passedFilters[3]:Set[FALSE]
            }
            else
            	passedFilters[3]:Set[TRUE]
            
            ;------------------------------------------
            ; Final Conditions Reviewed
            ;------------------------------------------	
            
            ccount:Set[1]
            conditionsPassed:Set[FALSE]
          
            do
            {
            	if ${passedFilters[${ccount}]}
            	{
            		; Condition Passed. 
            		conditionsPassed:Set[TRUE]
            	}
            	else	
            	{
            		; A condition has not passed.
            		conditionsPassed:Set[FALSE]
            		break
            	}
            }
            while ${ccount:Inc}<=3
            
            ;------------------------------------------
            ; If conditions are met....
            ;------------------------------------------
            if ${conditionsPassed}
            {
            	if ${CustomActor[${tcount}](exists)}
            	    UIElement[TrackItems@EQ2 Track]:AddItem[${itemInfo}]
            }
        }
        while ${tcount:Inc}<=${EQ2.CustomActorArraySize}
        
        
        ;------------------------------------------
        ;------------------------------------------
        ;------------------------------------------
        ;------------------------------------------
        
        call zoneWait
        
        ;------------------------------------------
        ; Immunity System
        ;------------------------------------------
        
        if ${triggerImmunity}
        {
            timerDiff:Set[${Time.Timestamp} - ${startTimer}]
        
        	if ${timerDiff} > ${immunityRemaining}
        	{
            	triggerImmunity:Set[FALSE]
            	; Return to Normal Tracking Conditions
            	bypassAggro:Set[FALSE]
        	}
        	else
        	{
        	    bypassAggro:Set[TRUE]
        	}
        }
        
        wait 30

    }
    while (${Tracking} && ${ISXEQ2(exists)})
}

function atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Track/UI/EQ2Track.xml"
}

