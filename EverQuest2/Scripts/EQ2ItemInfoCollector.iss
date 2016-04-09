atom(script) EQ2_ExamineItemWindowAppeared(string ItemName, string WindowID)
{
	  ; This event is fired every time that a an item examine window appears on
	  ; the UI.  In other words, this event should fire every time that you 'examine'
	  ; an item.
	  
	  variable string FileName = "../Extensions/eq2ItemInfoDatabase.txt"
	  variable int ClassesCount = 1
	  variable int EquipSlotsCount = 1
	  variable int EffectsCount = 1
	  variable int StringsCount = 1
	  variable string Buffer = ""
	  
		redirect -append ${FileName} echo Name: ${ExamineItemWindow[${WindowID}].ToItem.Name}  
		if (${ExamineItemWindow[${WindowID}].ToItem.Level} > 0)
		    redirect -append ${FileName} echo Level: ${ExamineItemWindow[${WindowID}].ToItem.Level}  
		if (${ExamineItemWindow[${WindowID}].ToItem.Weight} > 0)
		    redirect -append ${FileName} echo Weight: ${ExamineItemWindow[${WindowID}].ToItem.Weight}  
		redirect -append ${FileName} echo ID: ${ExamineItemWindow[${WindowID}].ToItem.ID}  
	  redirect -append ${FileName} echo Tier: ${ExamineItemWindow[${WindowID}].ToItem.Tier}  
	  if (${ExamineItemWindow[${WindowID}].ToItem.Description.Length} > 0)
     	  redirect -append ${FileName} echo Description: ${ExamineItemWindow[${WindowID}].ToItem.Description}  
    if (${ExamineItemWindow[${WindowID}].ToItem.Crafter.Length} > 0)
    	  redirect -append ${FileName} echo Crafter: ${ExamineItemWindow[${WindowID}].ToItem.Crafter}  
	  if (${ExamineItemWindow[${WindowID}].ToItem.WeightReduction} > 0)
    	  redirect -append ${FileName} echo Weight Reduction: ${ExamineItemWindow[${WindowID}].ToItem.WeightReduction}  
    if (${ExamineItemWindow[${WindowID}].ToItem.RentStatusReduction(exists)})
    	  redirect -append ${FileName} echo Rent Status Reduction: ${ExamineItemWindow[${WindowID}].ToItem.RentStatusReduction}  
	  redirect -append ${FileName} echo Condition: ${ExamineItemWindow[${WindowID}].ToItem.Condition}%  
		if (${ExamineItemWindow[${WindowID}].ToItem.Charges(exists)})
			  redirect -append ${FileName} echo Charges: ${ExamineItemWindow[${WindowID}].ToItem.Charges}  
		if (${ExamineItemWindow[${WindowID}].ToItem.MaxCharges(exists)})
			  redirect -append ${FileName} echo Max Charges: ${ExamineItemWindow[${WindowID}].ToItem.MaxCharges}  
	  
	  ; Type Specific Information
	  redirect -append ${FileName} echo Type: ${ExamineItemWindow[${WindowID}].ToItem.Type}  
	  if (${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Weapon"]})
	  {
	  	 	redirect -append ${FileName} echo Damage Rating: ${ExamineItemWindow[${WindowID}].ToItem.DamageRating}  
	  	 	redirect -append ${FileName} echo My Minimum Damage: ${ExamineItemWindow[${WindowID}].ToItem.MyMinDamage}  
	  	 	redirect -append ${FileName} echo My Maximum Damage: ${ExamineItemWindow[${WindowID}].ToItem.MyMaxDamage}  
	  	 	redirect -append ${FileName} echo Base Minimum Damage: ${ExamineItemWindow[${WindowID}].ToItem.BaseMinDamage}  
	  	 	redirect -append ${FileName} echo Base Maximum Damage: ${ExamineItemWindow[${WindowID}].ToItem.BaseMaxDamage}  
	  	 	redirect -append ${FileName} echo Mastery Minimum Damage: ${ExamineItemWindow[${WindowID}].ToItem.MasteryMinDamage}  
	  	 	redirect -append ${FileName} echo Mastery Maximum Damage: ${ExamineItemWindow[${WindowID}].ToItem.MasteryMaxDamage}  
	  	 	redirect -append ${FileName} echo Delay: ${ExamineItemWindow[${WindowID}].ToItem.Delay}  
	  	 	if (${ExamineItemWindow[${WindowID}].ToItem.Range(exists)})
			  	 	redirect -append ${FileName} echo Range: ${ExamineItemWindow[${WindowID}].ToItem.Range}  
			  if (${ExamineItemWindow[${WindowID}].ToItem.ShieldFactor(exists)})
			  	 	redirect -append ${FileName} echo ShieldFactor: ${ExamineItemWindow[${WindowID}].ToItem.ShieldFactor}  
			  if (${ExamineItemWindow[${WindowID}].ToItem.MaxShieldFactor(exists)})
			  	 	redirect -append ${FileName} echo MaxShieldFactor: ${ExamineItemWindow[${WindowID}].ToItem.MaxShieldFactor}  
	  	 	redirect -append ${FileName} echo Wield Style: ${ExamineItemWindow[${WindowID}].ToItem.WieldStyle}  
	  	 	redirect -append ${FileName} echo SubType: ${ExamineItemWindow[${WindowID}].ToItem.SubType}  
	  	 	redirect -append ${FileName} echo Damage Type: ${ExamineItemWindow[${WindowID}].ToItem.DamageType}  
	  	 	redirect -append ${FileName} echo Damage Verb: ${ExamineItemWindow[${WindowID}].ToItem.DamageVerbType}   	 	
	 	}
	 	if (${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Armor"]})
	 	{
	 			redirect -append ${FileName} echo Mitigation: ${ExamineItemWindow[${WindowID}].ToItem.Mitigation}  
	 			redirect -append ${FileName} echo Maximum Mitigation: ${ExamineItemWindow[${WindowID}].ToItem.MaxMitigation}  
	 	}
	 	if (${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Container"]})
	 	{
	 			redirect -append ${FileName} echo Label: ${ExamineItemWindow[${WindowID}].ToItem.Label}  
	 			redirect -append ${FileName} echo Number Slots: ${ExamineItemWindow[${WindowID}].ToItem.NumSlots}  
	  }
	  if (${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Drink"]} || ${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Food"]})
	  {
	  	  redirect -append ${FileName} echo Duration: ${ExamineItemWindow[${WindowID}].ToItem.Duration}  
	  	  redirect -append ${FileName} echo Satiation: ${ExamineItemWindow[${WindowID}].ToItem.Satiation}  
	  	  redirect -append ${FileName} echo Level: ${ExamineItemWindow[${WindowID}].ToItem.Level}  
	  }
	  if (${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Activateable"]})
	  {
	  		redirect -append ${FileName} echo Duration: ${ExamineItemWindow[${WindowID}].ToItem.Duration}  
	  		redirect -append ${FileName} echo Casting Time: ${ExamineItemWindow[${WindowID}].ToItem.CastingTime}  
	  		redirect -append ${FileName} echo Recovery Time: ${ExamineItemWindow[${WindowID}].ToItem.RecoveryTime}  
	  		redirect -append ${FileName} echo Recast Time: ${ExamineItemWindow[${WindowID}].ToItem.RecastTime}  
	  }
	  
	  ; Equip Slots
	  Buffer:Concat["Equipable Slots: "] 
	  do
	  {
	  	 Buffer:Concat["${ExamineItemWindow[${WindowID}].ToItem.EquipSlot[${EquipSlotsCount}]} "]
	  }
	  while ${EquipSlotsCount:Inc} <= ${ExamineItemWindow[${WindowID}].ToItem.NumEquipSlots}
		redirect -append ${FileName} echo ${Buffer}
		Buffer:Set[""]
			  
	  ; Classes that can use the item:
	  Buffer:Concat["Classes: "] 
	  do
	  {
	  	 Buffer:Concat["${ExamineItemWindow[${WindowID}].ToItem.Class[${ClassesCount}].Name}(${ExamineItemWindow[${WindowID}].ToItem.Class[${ClassesCount}].Level}) "]
	  }
	 	while ${ClassesCount:Inc} <= ${ExamineItemWindow[${WindowID}].ToItem.NumClasses}
		redirect -append ${FileName} echo ${Buffer}
		Buffer:Set[""]

	  ; Booleans/Flags
	  if (!${ExamineItemWindow[${WindowID}].ToItem.Type.Find["Item"](exists)})
	  {
	     	Buffer:Concat["\nFlags: "] 
	  		if ${ExamineItemWindow[${WindowID}].ToItem.Artifact}
   				Buffer:Concat["Artifact "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.Attuneable}
   				Buffer:Concat["Attuneable "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.Attuned}
   	  		Buffer:Concat["Attuned "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.Lore}
   	  		Buffer:Concat["Lore "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.NoDestroy}
   	  		Buffer:Concat["NoDestroy "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.NoTrade}
   	  		Buffer:Concat["NoTrade "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.NoValue}
   	  		Buffer:Concat["NoValue "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.NoZone}
   	  		Buffer:Concat["NoZone "] 
   			if ${ExamineItemWindow[${WindowID}].ToItem.Temporary}
   	  		Buffer:Concat["Temporary "] 
   	 }
		redirect -append ${FileName} echo ${Buffer}
		Buffer:Set[""]   	 

   	; Modifiers
	  redirect -append ${FileName} echo "\nModifiers:"  
	  redirect -append ${FileName} echo "-------" 
   	if (${ExamineItemWindow[${WindowID}].ToItem.Agility} > 0)
   	   redirect -append ${FileName} echo Agility +${ExamineItemWindow[${WindowID}].ToItem.Agility}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Agility} < 0)
   	   redirect -append ${FileName} echo Agility ${ExamineItemWindow[${WindowID}].ToItem.Agility}  
   	if (${ExamineItemWindow[${WindowID}].ToItem.Crushing} > 0)
   	   redirect -append ${FileName} echo Crushing +${ExamineItemWindow[${WindowID}].ToItem.Crushing}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Crushing} < 0)
   	   redirect -append ${FileName} echo Crushing ${ExamineItemWindow[${WindowID}].ToItem.Crushing}    
   	if (${ExamineItemWindow[${WindowID}].ToItem.Defense} > 0)
   	   redirect -append ${FileName} echo Defense +${ExamineItemWindow[${WindowID}].ToItem.Defense}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Defense} < 0)
   	   redirect -append ${FileName} echo Defense ${ExamineItemWindow[${WindowID}].ToItem.Defense}     	   
   	if (${ExamineItemWindow[${WindowID}].ToItem.Deflection} > 0)
   	   redirect -append ${FileName} echo Deflection +${ExamineItemWindow[${WindowID}].ToItem.Deflection}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Deflection} < 0)
   	   redirect -append ${FileName} echo Deflection ${ExamineItemWindow[${WindowID}].ToItem.Deflection}    	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.Disruption} > 0)
   	   redirect -append ${FileName} echo Disruption +${ExamineItemWindow[${WindowID}].ToItem.Disruption}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Disruption} < 0)
   	   redirect -append ${FileName} echo Disruption ${ExamineItemWindow[${WindowID}].ToItem.Disruption}  
   	if (${ExamineItemWindow[${WindowID}].ToItem.Focus} > 0)
   	   redirect -append ${FileName} echo Focus +${ExamineItemWindow[${WindowID}].ToItem.Focus}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Focus} < 0)
   	   redirect -append ${FileName} echo Focus ${ExamineItemWindow[${WindowID}].ToItem.Focus}     	     
   	if (${ExamineItemWindow[${WindowID}].ToItem.Health} > 0)
   	   redirect -append ${FileName} echo Health +${ExamineItemWindow[${WindowID}].ToItem.Health}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Health} < 0)
   	   redirect -append ${FileName} echo Health ${ExamineItemWindow[${WindowID}].ToItem.Health}     	     
   	if (${ExamineItemWindow[${WindowID}].ToItem.Intelligence} > 0)
   	   redirect -append ${FileName} echo Intelligence +${ExamineItemWindow[${WindowID}].ToItem.Intelligence}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Intelligence} < 0)
   	   redirect -append ${FileName} echo Intelligence ${ExamineItemWindow[${WindowID}].ToItem.Intelligence}     	     
   	if (${ExamineItemWindow[${WindowID}].ToItem.Ministration} > 0)
   	   redirect -append ${FileName} echo Ministration +${ExamineItemWindow[${WindowID}].ToItem.Ministration}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Ministration} < 0)
   	   redirect -append ${FileName} echo Ministration ${ExamineItemWindow[${WindowID}].ToItem.Ministration}     	     
   	if (${ExamineItemWindow[${WindowID}].ToItem.Ordination} > 0)
   	   redirect -append ${FileName} echo Ordination +${ExamineItemWindow[${WindowID}].ToItem.Ordination}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Ordination} < 0)
   	   redirect -append ${FileName} echo Ordination ${ExamineItemWindow[${WindowID}].ToItem.Ordination}     	     
   	if (${ExamineItemWindow[${WindowID}].ToItem.Parry} > 0)
   	   redirect -append ${FileName} echo Parry +${ExamineItemWindow[${WindowID}].ToItem.Parry}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Parry} < 0)
   	   redirect -append ${FileName} echo Parry ${ExamineItemWindow[${WindowID}].ToItem.Parry}     	       	   	
   	if (${ExamineItemWindow[${WindowID}].ToItem.Piercing} > 0)
   	   redirect -append ${FileName} echo Piercing +${ExamineItemWindow[${WindowID}].ToItem.Piercing}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Piercing} < 0)
   	   redirect -append ${FileName} echo Piercing ${ExamineItemWindow[${WindowID}].ToItem.Piercing}     	     
   	if (${ExamineItemWindow[${WindowID}].ToItem.Power} > 0)
   	   redirect -append ${FileName} echo Power +${ExamineItemWindow[${WindowID}].ToItem.Power}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Power} < 0)
   	   redirect -append ${FileName} echo Power ${ExamineItemWindow[${WindowID}].ToItem.Power}     	        
   	if (${ExamineItemWindow[${WindowID}].ToItem.Slashing} > 0)
   	   redirect -append ${FileName} echo Slashing +${ExamineItemWindow[${WindowID}].ToItem.Slashing}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Slashing} < 0)
   	   redirect -append ${FileName} echo Slashing ${ExamineItemWindow[${WindowID}].ToItem.Slashing}     	       	   
   	if (${ExamineItemWindow[${WindowID}].ToItem.Stamina} > 0)
   	   redirect -append ${FileName} echo Stamina +${ExamineItemWindow[${WindowID}].ToItem.Stamina}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Stamina} < 0)
   	   redirect -append ${FileName} echo Stamina ${ExamineItemWindow[${WindowID}].ToItem.Stamina}     	   
   	if (${ExamineItemWindow[${WindowID}].ToItem.Strength} > 0)
   	   redirect -append ${FileName} echo Strength +${ExamineItemWindow[${WindowID}].ToItem.Strength}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Strength} < 0)
   	   redirect -append ${FileName} echo Strength ${ExamineItemWindow[${WindowID}].ToItem.Strength}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.Subjugation} > 0)
   	   redirect -append ${FileName} echo Subjugation +${ExamineItemWindow[${WindowID}].ToItem.Subjugation}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Subjugation} < 0)
   	   redirect -append ${FileName} echo Subjugation ${ExamineItemWindow[${WindowID}].ToItem.Subjugation}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.Wisdom} > 0)
   	   redirect -append ${FileName} echo Wisdom +${ExamineItemWindow[${WindowID}].ToItem.Wisdom}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.Wisdom} < 0)
   	   redirect -append ${FileName} echo Wisdom ${ExamineItemWindow[${WindowID}].ToItem.Wisdom}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsCold} > 0)
   	   redirect -append ${FileName} echo vsCold +${ExamineItemWindow[${WindowID}].ToItem.vsCold}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsCold} < 0)
   	   redirect -append ${FileName} echo vsCold ${ExamineItemWindow[${WindowID}].ToItem.vsCold}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsCrushing} > 0)
   	   redirect -append ${FileName} echo vsCrushing +${ExamineItemWindow[${WindowID}].ToItem.vsCrushing}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsCrushing} < 0)
   	   redirect -append ${FileName} echo vsCrushing ${ExamineItemWindow[${WindowID}].ToItem.vsCrushing}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsDisease} > 0)
   	   redirect -append ${FileName} echo vsDisease +${ExamineItemWindow[${WindowID}].ToItem.vsDisease}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsDisease} < 0)
   	   redirect -append ${FileName} echo vsDisease ${ExamineItemWindow[${WindowID}].ToItem.vsDisease}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsDivine} > 0)
   	   redirect -append ${FileName} echo vsDivine +${ExamineItemWindow[${WindowID}].ToItem.vsDivine}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsDivine} < 0)
   	   redirect -append ${FileName} echo vsDivine ${ExamineItemWindow[${WindowID}].ToItem.vsDivine}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsDrowning} > 0)
   	   redirect -append ${FileName} echo vsDrowning +${ExamineItemWindow[${WindowID}].ToItem.vsDrowning}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsDrowning} < 0)
   	   redirect -append ${FileName} echo vsDrowning ${ExamineItemWindow[${WindowID}].ToItem.vsDrowning}     	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsFalling} > 0)
   	   redirect -append ${FileName} echo vsFalling +${ExamineItemWindow[${WindowID}].ToItem.vsFalling}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsFalling} < 0)
   	   redirect -append ${FileName} echo vsFalling ${ExamineItemWindow[${WindowID}].ToItem.vsFalling}     	    	      	      	      	         	      	      	      	     	      	      	      	      	      	      	      	    	      	   	  
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsHeat} > 0)
   	   redirect -append ${FileName} echo vsHeat +${ExamineItemWindow[${WindowID}].ToItem.vsHeat}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsHeat} < 0)
   	   redirect -append ${FileName} echo vsHeat ${ExamineItemWindow[${WindowID}].ToItem.vsHeat}     	
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsMagic} > 0)
   	   redirect -append ${FileName} echo vsMagic +${ExamineItemWindow[${WindowID}].ToItem.vsMagic}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsMagic} < 0)
   	   redirect -append ${FileName} echo vsMagic ${ExamineItemWindow[${WindowID}].ToItem.vsMagic}     	
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsMental} > 0)
   	   redirect -append ${FileName} echo vsMental +${ExamineItemWindow[${WindowID}].ToItem.vsMental}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsMental} < 0)
   	   redirect -append ${FileName} echo vsMental ${ExamineItemWindow[${WindowID}].ToItem.vsMental}     	
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsPainAndSuffering} > 0)
   	   redirect -append ${FileName} echo vsPainAndSuffering +${ExamineItemWindow[${WindowID}].ToItem.vsPainAndSuffering}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsPainAndSuffering} < 0)
   	   redirect -append ${FileName} echo vsPainAndSuffering ${ExamineItemWindow[${WindowID}].ToItem.vsPainAndSuffering}     	
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsPiercing} > 0)
   	   redirect -append ${FileName} echo vsPiercing +${ExamineItemWindow[${WindowID}].ToItem.vsPiercing}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsPiercing} < 0)
   	   redirect -append ${FileName} echo vsPiercing ${ExamineItemWindow[${WindowID}].ToItem.vsPiercing}     
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsPoison} > 0)
   	   redirect -append ${FileName} echo vsPoison +${ExamineItemWindow[${WindowID}].ToItem.vsPoison}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsPoison} < 0)
   	   redirect -append ${FileName} echo vsPoison ${ExamineItemWindow[${WindowID}].ToItem.vsPoison}        	 
   	if (${ExamineItemWindow[${WindowID}].ToItem.vsSlashing} > 0)
   	   redirect -append ${FileName} echo vsSlashing +${ExamineItemWindow[${WindowID}].ToItem.vsSlashing}  
   	elseif (${ExamineItemWindow[${WindowID}].ToItem.vsSlashing} < 0)
   	   redirect -append ${FileName} echo vsSlashing ${ExamineItemWindow[${WindowID}].ToItem.vsSlashing}          	        	      	      	      	   
	  
	  
	  ; Effects
	  if (${ExamineItemWindow[${WindowID}].ToItem.NumEffects} > 0)
	  {
	  	redirect -append ${FileName} echo "\nEffects:"  
	 		redirect -append ${FileName} echo "-------" 
	  	do
	  	{
	  		if (${ExamineItemWindow[${WindowID}].ToItem.EffectDescription[${EffectsCount}].Length} > 0)
		  		redirect -append ${FileName} echo ${EffectsCount}. ${ExamineItemWindow[${WindowID}].ToItem.EffectName[${EffectsCount}]}: ${ExamineItemWindow[${WindowID}].ToItem.EffectDescription[${EffectsCount}]}  
		 	 	else
		    	redirect -append ${FileName} echo ${EffectsCount}. ${ExamineItemWindow[${WindowID}].ToItem.EffectName[${EffectsCount}]}  
	  	}
	  	while ${EffectsCount:Inc} <= ${ExamineItemWindow[${WindowID}].ToItem.NumEffects}  
	  }
	  
	  ; Miscellaneous Examine Item Window strings
	  redirect -append ${FileName} echo "\nExamine Window Strings:"  
	  redirect -append ${FileName} echo "-------" 	  
	  do
	  {
	  	if (${ExamineItemWindow[${WindowID}].TextVector[${StringsCount}].Label.Length} > 0)
	  			redirect -append ${FileName} echo ${StringsCount}. ${ExamineItemWindow[${WindowID}].TextVector[${StringsCount}].Label}  
	  }
	  while ${StringsCount:Inc} <= ${ExamineItemWindow[${WindowID}].TextVector}  	  
	  
	  ; End
	  redirect -append ${FileName} echo "\n\n----------------------------------------------\n\n" 
}

function main()
{
	  ; If isxEQ2 isn't loaded, then no reason to run this script.
	  if (!${ISXEQ2(exists)})
	  	return
	  	
	  ;Initialize/Attach the event Atoms that we defined previously
		Event[EQ2_ExamineItemWindowAppeared]:AttachAtom[EQ2_ExamineItemWindowAppeared]



		;Tell the user that the script has initialized and is running!
		echo "isxEQ2 item information collection daemon initialized."
	
	  ; This bit of scripting tells the script to "waitframe" over and
	  ; over while ${ISXEQ2(exists)}.  In other words, as long as the 
	  ; extension is loaded.
	  ;
	  ; If you want to stop the script, simply issue the command
	  ; "endscript *"
	  ; or
	  ; "endscript <scriptname>"
		do 
		{
				waitframe
		}
		while ${ISXEQ2(exists)}
	
	  ;We're done with the script, so let's detach all of the event atoms
		Event[EQ2_ExamineItemWindowAppeared]:DetachAtom[EQ2_ExamineItemWindowAppeared]

    
    ;Send a final message telling the user that the script has ended
  	echo "isxEQ2 item information collection daemon deactivated."
}