variable(script) int MaxTargets
variable(script) int MaxTargetRange
variable(script) index:entity TargetedBy
variable(script) index:entity Targets
variable(script) int64 TargetThisID
variable(script) index:entity Targeting
variable(script) int MaxTargeting
variable(script) bool Found

function main(... Args)
{
  variable int Iterator = 1
  variable int i = 1
  variable int j = 1
  variable int k = 1
  NumTargetsToMaintain:Set[0]
  Found:Set[FALSE]
 
  if !${ISXEVE(exists)}
  {
    echo "- ISXEVE must be loaded to use this script."
    return
  }
  do
  {
    waitframe
  }
  while !${ISXEVE.IsReady}
  
  
  
  ; 'Args' is an array ... arrays are static.  Copying to an index just in case we have a desire at some point to add/remove elements.
  if ${Args.Size} > 0
  {
    do
    {
      ; As of now, this script should only have one argument:  the number of targets to maintain
      MaxTargets:Set[${Args[${Iterator}]}]
    }
    while ${Iterator:Inc} <= ${Args.Size}
  }
	
	
  if (${MaxTargets} <= 0)
  {
    MaxTargets:Set[${Me.Ship.MaxLockedTargets}]
    wait 5
  }
  MaxTargetRange:Set[${Me.Ship.MaxTargetRange}]	
  MaxTargeting:Set[${Math.Calc[${MaxTargets}-1]}]
  echo " \n \n \n** EVE 'Target Daemon' Script by Amadeus ** \n \n"
  echo "- Maintaining ${MaxTargets} hostile targets."
  echo "- Max targetting range for this ship is ${MaxTargetRange} meters."
  echo "- Max number of entites to target simultaneously: ${MaxTargeting}"
  echo "- Daemon now running..."

  do
  {
    if ${Me.InStation}
      continue
    Me.GetTargets[Targets]
    if (${Targets.Used} >= ${MaxTargets})
      continue  
  	
    ; don't target too many at the same time...
    Me:GetTargeting[Targeting]
    if (${Targeting.Used} >= ${MaxTargeting})				
    {
      echo "-- Targeting ${Targeting.Used} already -- waiting..."
      wait 5
      continue	
    }
  	  
    Me:GetTargetedBy[TargetedBy]
    if (${TargetedBy.Used} > 0)
    {
      ;echo "- ${TargetedBy.Used} hostiles found within range that are currently targeting you..."
      i:Set[1]
      TargetThisID:Set[0]
      if (${TargetedBy.Used} > 0)
      {
        do
        {
          if (${TargetedBy.Get[${i}].Distance} > ${MaxTargetRange})
            continue
		  				
          Me.GetTargets[Targets]
          if (${Targets.Used} >= ${MaxTargets})
            continue  
				  		
          k:Set[1]
          Found:Set[FALSE]
          if (${Me.TargetCount} > 0)
          {
            do
            {
              if (${Targets.Get[${k}].ID.Equal[${TargetedBy.Get[${i}].ID}]})
              {
                Found:Set[TRUE]
                break
              }
            }
            while ${k:Inc} <= ${Me.TargetCount}
          }		  				
          if (${Found})
            continue	
          	
          if (${TargetThisID} == 0)
          {
            TargetThisID:Set[${TargetedBy.Get[${i}].ID}]
            continue
          }
		  			
          if (${Entity[${TargetThisID}].Distance} > ${TargetedBy.Get[${i}].Distance})
          {
            Targeting:Clear
            Me:GetTargeting[Targeting]
            j:Set[1]
            Found:Set[FALSE]
            if (${Targeting.Used} > 0)
            {
              do
              {
                if (${Targeting.Get[${j}].ID.Equal[${TargetedBy.Get[${i}].ID}]})
                {
                  Found:Set[TRUE]
                  break
                }
              }
              while ${j:Inc} <= ${Targeting.Used}
            }
		  				 
            if !${Found}
            {
              TargetThisID:Set[${TargetedBy.Get[${i}].ID}]
              continue
            }
          }
        }
        while ${i:Inc} <= ${Me.TargetedByCount}
      }
  		
  		
      Targeting:Clear
      Me:GetTargeting[Targeting]	
      j:Set[1]
      Found:Set[FALSE]
      if (${Targeting.Used} > 0)
      {
        do
        {
          if (${Targeting.Get[${j}].ID.Equal[${TargetThisID}]})
          {
            Found:Set[TRUE]
            break
          }
        }
        while ${j:Inc} <= ${Targeting.Used}
      }
			 				 	
      if !${Found}
      {			 	
        if (!${TargetThisID.Equal[${Me.ToEntity.ID}]})
        {	
          ; CategoryID 11 = "Entity"
          if (${Entity[${TargetThisID}].CategoryID} == 11)
          {
            Entity[${TargetThisID}]:LockTarget
            echo "-- Targeting: ${Entity[${TargetThisID}].Name}..."
            wait 5
          }
        }
      }  		
    }
    else
    {
      ;echo "- No hostile entities present that are currently targetting you."
    }
    wait 15
    TargetedBy:Clear
  }
  while ${ISXEVE(exists)}

  echo "Script Ended."
  return
}