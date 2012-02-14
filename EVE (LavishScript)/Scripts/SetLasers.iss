variable(script) int LasersCount
variable(script) int AmmoCount
variable(script) index:item Ammo
variable(script) index:module AllModules
variable(script) index:module Lasers
variable(script) bool DoActivate

function GetModulesInformation()
{
  variable int k = 1
  Lasers:Clear
  AllModules:Clear
  DoActivate:Set[FALSE]

  ;; Determine the modules at our disposal
  echo "- Acquiring Information about your ship's modules..."
  Me.Ship:GetModules[AllModules]
  if (${AllModules.Used} <= 0)
  {
    echo ERROR -- Your ship does not appear to have any modules
    return
  }
  do
  {
    if (${AllModules.Get[${k}].UsesFrequencyCrystals})			
    {
      if (${AllModules.Get[${k}].IsOnline})
      {
        ;echo "Adding ${AllModules.Get[${k}].ToItem.Name} to 'Lasers'"
        Lasers:Insert[${AllModules.Get[${k}]}]
      }
    }	
  }
  while ${k:Inc} <= ${AllModules.Used}
	
  LasersCount:Set[${Lasers.Used}]
  echo "- Your ship has ${LasersCount} Laser(s)."

  return
}

function main(... Args)
{
  variable int i = 1
  variable int j = 1
  variable int Iterator = 1
  variable string CrystalName = ""
  
  Ammo:Clear
  
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
  
  echo " \n \n \n** EVE 'Set Lasers' Script by Amadeus ** \n \n"
  
  ; 'Args' is an array ... arrays are static.  Copying to an index just in case we have a desire at some point to add/remove elements.
  if ${Args.Size} > 0
  {
    do
    {
      if (${Args[${Iterator}].Equal[-ACTIVATE]} || ${Args[${Iterator}].Equal[-activate]} || ${Args[${Iterator}].Equal[-act]} || ${Args[${Iterator}].Equal[-ACT]})
      {
        DoActivate:Set[TRUE]			
      }
      else
      {
        ; As of now, this script should only have one argument other than option flags:  the name of the crystals to insert
        CrystalName:Set[${Args[${Iterator}]}]
      }
    }
    while ${Iterator:Inc} <= ${Args.Size}
  }

  if (${CrystalName.Length} <= 0)
  {
    echo "- Syntax:  'run SetLasers CRYSTALNAME'"
    echo "-          'run SetLasers -activate CRYSTALNAME'   [will activate/reactivate the lasers after the crystals are swapped]"
    return
  }  
  
  call GetModulesInformation
  
  if ${LasersCount} <= 0
  {
    echo "- Your ship does not appear to have any lasers!"
    echo "- Script Ended."
    return
  }
  
  echo "- Deactivating all lasers..."
  j:Set[1]
  do
  {
    if (${Lasers.Get[${j}].IsActive} && !${Lasers.Get[${j}].IsDeactivating})
    {
      echo "-- Deactivating: ${j}. ${Lasers.Get[${j}].ToItem.Name}"
      Lasers.Get[${j}]:Click
      wait 2
    }	
    wait 1
  }
  while (${j:Inc} <= ${LasersCount})
	
  echo "- Verifying that all lasers are deactivated..."
  j:Set[1]
  do
  {
    if (${Lasers.Get[${j}].IsDeactivating})
    {
      echo "-- Waiting..."
      wait 10
    }	
  }
  while (${j:Inc} <= ${LasersCount})	
	
  echo "- Verifying that all lasers are deactivated (Second Pass)..."
  j:Set[1]
  do
  {
    if (${Lasers.Get[${j}].IsDeactivating})
    {
      echo "-- Waiting..."
      wait 10
    }	
  }
  while (${j:Inc} <= ${LasersCount})		

  echo "- Changing crystals..."
  j:Set[1]
  do
  {
    if (!${Lasers.Get[${j}].IsDeactivating} && !${Lasers.Get[${j}].IsActive})
    {
    	Ammo:Clear
    	Lasers.Get[${j}]:GetAvailableAmmo[Ammo]
      AmmoCount:Set[${Ammo.Used}]
      ;echo "-- ${AmmoCount} crystals available for ${Lasers.Get[${j}].ToItem.Name}..."
      i:Set[1]
      do
      {
        if (${Ammo.Get[${i}].Name.Find[${CrystalName}]} > 0)
        {
          echo "-- Loading ${Lasers.Get[${j}].ToItem.Name} with ${Ammo.Get[${i}].Name}"
          Lasers.Get[${j}]:ChangeAmmo[${Ammo.Get[${i}].ID},1]
          wait 10
          break
        }
      }
      while ${i:Inc} <= ${AmmoCount}
    }	
  }
  while (${j:Inc} <= ${LasersCount})	 


  if ${DoActivate}
  {
    echo "- Waiting for ammo change to finish..."
    j:Set[1]
    do
    {
      if (${Lasers.Get[${j}].IsChangingAmmo})
      {
        wait 15
      }	
    }
    while (${j:Inc} <= ${LasersCount})	    	
  	
    echo "- Activating all lasers..."
    j:Set[1]
    do
    {
      if (!${Lasers.Get[${j}].IsActive})
      {
        Lasers.Get[${j}]:Click
        wait 5
      }	
    }
    while (${j:Inc} <= ${LasersCount})	  	
  }

  echo "- Finished"
  return
}
