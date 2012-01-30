variable(script) int Counter

function atexit()
{
 	echo "EVE 'Go To Bookmark' Script -- Ended"
	return
}

function main(string Destination)
{
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
  
	if !${EVE.Bookmark[${Destination}](exists)}
	{  
		echo "The 'Destination' bookmark was not found."
		return
	}
  
  echo " \n \n \n** EVE 'Go To Bookmark' Script by Amadeus ** \n \n"

 	if (${Me.InStation})
 	{
   	echo "- Undocking from station..."
   	EVE:Execute[CmdExitStation]	
   	wait 150
   	Counter:Set[0]
   	if (${Me.InStation})
   	{
   		do
   		{
   			wait 20
   			Counter:Inc[20]
	   		if (${Counter} > 300)
	   		{
	   		  echo "- Undocking atttempt failed ... trying again." 
	   			EVE:Execute[CmdExitStation]
	   			Counter:Set[0]
	   		}   			
   		}
   		while (${Me.InStation} || !${EVEWindow[Local](exists)} || !${Me.InStation(exists)})
   	}
   	wait 5
  }
	if (!${EVE.Bookmark[${Destination}](exists)})
	{
		do
		{
			wait 20
		}
		while (!${EVE.Bookmark[${Destination}](exists)})	   
	}	  
 
 	if (!${EVE.Bookmark[${Destination}].SolarSystemID.Equal[${Me.SolarSystemID}]})
 	{
  	echo "- Setting autopilot destination: ${EVE.Bookmark[${Destination}]}"
		EVE.Bookmark[${Destination}]:SetDestination
		wait 5
		echo "- Activating autopilot and waiting until arrival..."
		EVE:Execute[CmdToggleAutopilot]
		do
		{
		   wait 50
		   if !${Me.AutoPilotOn(exists)}
		   {
		     do
		     {
		        wait 5
		     }
		     while !${Me.AutoPilotOn(exists)}
		   }
		}
		while ${Me.AutoPilotOn}
		wait 20
		do
		{
		   wait 10
		}
		while !${Me.ToEntity.IsCloaked}
		wait 5
	}
	
	echo "- Warping to destination"	   
	EVE.Bookmark[${Destination}]:WarpTo
	wait 120
	do
	{
		wait 20
	}
	while (${Me.ToEntity.Mode} == 3)	
	wait 20
	
	if ${EVE.Bookmark[${Destination}].ToEntity(exists)}
	{
		echo "- Docking with destination station"
		if (${EVE.Bookmark[${Destination}].ToEntity.CategoryID} == 3)
		{
			EVE.Bookmark[${Destination}].ToEntity:Approach
			do
			{
				wait 20
			}
			while (${EVE.Bookmark[${Destination}].ToEntity.Distance} > 50)
			
			EVE.Bookmark[${Destination}].ToEntity:Dock			
			Counter:Set[0]
			do
			{
			   wait 20
			   Counter:Inc[20]
			   if (${Counter} > 200)
			   {
			      echo " - Docking atttempt failed ... trying again."
			      EVE.Bookmark[${Destination}].ToEntity:Dock	
			      Counter:Set[0]
			   }
			}
			while (!${Me.InStation})					
		}
	}
	wait 20
		
  echo "Script Ended.
  return
}
