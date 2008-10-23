

objectdef vgassist_Settings inherits vgassist_Config
  {
   method Initialize()
	   {
	    Echo Inializing Configurating FileSystem
	     
	    declare CF	              filepath     script "${Script.CurrentDirectory}/xml/${Script.Filename}_Config_File.xml"
	    declare Main_Container    string	   script ${Script.Filename}

	    This:Initialize_Settings
           }	
	
   method Shutdown()
	   {
	    Echo Shutting Down Configuration File System
	    
	    ;; This:Save
		  
		  ;; LavishSettings[${Main_Container}]:Export[${CF}]
	   }
	
   method Initialize_Settings()
	   {

              LavishSettings:AddSet[${Main_Container}]
      
              LavishSettings[${Main_Container}]:Clear

	      LavishSettings[${Main_Container}]:AddSet[PhysicalPawns]
	      declare PhysicalPawns 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[PhysicalPawns]}

	      LavishSettings[${Main_Container}]:AddSet[ArcanePawns]
	      declare ArcanePawns 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[ArcanePawns]}

	      LavishSettings[${Main_Container}]:AddSet[IcePawns]
	      declare IcePawns 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[IcePawns]}

	      LavishSettings[${Main_Container}]:AddSet[FirePawns]
	      declare FirePawns 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[FirePawns]}

	      LavishSettings[${Main_Container}]:AddSet[SpiritualPawns]
	      declare SpiritualPawns 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[SpiritualPawns]}

	      LavishSettings[${Main_Container}]:AddSet[CounterSpells]
	      declare CounterSpells 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[CounterSpells]}

	      LavishSettings[${Main_Container}]:AddSet[DispellSpells]
	      declare DispellSpells 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[DispellSpells]}
		
              LavishSettings[${Main_Container}]:AddSet[options]
              declare options 	settingsetref script ${LavishSettings[${Main_Container}].FindSet[options]}

              This:Initialize_vgassist
	   }

 
   method Add_Set(string Set)
	   {
		  if !${LavishSettings["${Main_Container}"].FindSet[${Set}](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[${Set}]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[CounterSpells](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[CounterSpells]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[DispellSpells](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[DispellSpells]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[PhysicalPawns](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[PhysicalPawns]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[ArcanePawns](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[ArcanePawns]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[IcePawns](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[IcePawns]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[FirePawns](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[FirePawns]
		    }
		  if !${LavishSettings["${Main_Container}"].FindSet[SpiritualPawns](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[SpiritualPawns]
		    }
	   }

   method Set_Setting(string Container, string Setting, string Value)
	   {
		  if !${LavishSettings["${Main_Container}"].FindSet[${Container}](exists)}
		    {
		     Echo Set Setting: ${Container} in ${Main_Container}
		     LavishSettings["${Main_Container}"]:AddSet[${Container}]
		    }
		  LavishSettings["${Main_Container}"].FindSet[${Container}].FindSetting[${Setting},0]:Set[${Value}]
	   }

   member Get_Setting(string Container, string Setting, string Value = NULL)
	   {
	 	  if !${LavishSettings["${Main_Container}"].FindSet[${Container}](exists)}
		    {
			   LavishSettings["${Main_Container}"]:AddSet[${Container}]
		    }
		  return ${LavishSettings["${Main_Container}"].FindSet[${Container}].FindSetting[${Setting},${Value}]}
	   } 	
  }

  variable(script) vgassist_Settings Settings

; *Fold*

objectdef vgassist_Config
  {
   method Initialize_vgassist()
     {
       
     } 	
   method Load()
     {
      Echo Loading Config Files
      
      ;; Settings:AddSetting[]

		  LavishSettings[${Main_Container}]:Import[${CF}]
	
	assistm:Set[${options.FindSetting[assistm,${assistm}]}]
        facem:Set[${options.FindSetting[facem,${facem}]}]
	
	movetot:Set[${options.FindSetting[movetot,${movetot}]}]
	mtotpct:Set[${options.FindSetting[mtotpct,${mtotpct}]}]
        aharv:Set[${options.FindSetting[aharv,${aharv}]}]
	mountup:Set[${options.FindSetting[mountup,${mountup}]}]
        
        lootit:Set[${options.FindSetting[lootit,${lootit}]}]
        restandfood:Set[${options.FindSetting[restandfood,${restandfood}]}]
	autogroup:Set[${options.FindSetting[autogroup,${autogroup}]}]
	autotrade:Set[${options.FindSetting[autotrade,${autotrade}]}]

	plmember1:Set[${options.FindSetting[plmember1,${plmember1}]}]
	plmember2:Set[${options.FindSetting[plmember2,${plmember2}]}]
	plmember3:Set[${options.FindSetting[plmember3,${plmember3}]}]
	plmember4:Set[${options.FindSetting[plmember4,${plmember4}]}]
	plmember5:Set[${options.FindSetting[plmember5,${plmember5}]}]
	plmember6:Set[${options.FindSetting[plmember6,${plmember6}]}]
	plmode:Set[${options.FindSetting[plmode,${plmode}]}]
	pldebuff1:Set[${options.FindSetting[pldebuff1,${pldebuff1}]}]
	pldebuff2:Set[${options.FindSetting[pldebuff2,${pldebuff2}]}]
	pldebuff:Set[${options.FindSetting[pldebuff,${pldebuff}]}]
	ourbard:Set[${options.FindSetting[ourbard,${ourbard}]}]

	clbigheal:Set[${options.FindSetting[clbigheal,${clbigheal}]}]
	clfastheal:Set[${options.FindSetting[clfastheal,${clfastheal}]}]
	clsmallheal:Set[${options.FindSetting[clsmallheal,${clsmallheal}]}]
	clmeleetarg:Set[${options.FindSetting[clmeleetarg,${clmeleetarg}]}]
	clmeleeattack1:Set[${options.FindSetting[clmeleeattack1,${clmeleeattack1}]}]
	clmeleeattack2:Set[${options.FindSetting[clmeleeattack2,${clmeleeattack2}]}]
	clmeleeattack3:Set[${options.FindSetting[clmeleeattack3,${clmeleeattack3}]}]
	clenergyattack1:Set[${options.FindSetting[clenergyattack1,${clenergyattack1}]}]
	clmeleebuff1:Set[${options.FindSetting[clmeleebuff1,${clmeleebuff1}]}]
	clmeleebuff2:Set[${options.FindSetting[clmeleebuff2,${clmeleebuff2}]}]
	clcritattack1:Set[${options.FindSetting[clcritattack1,${clcritattack1}]}]
	clcritattack2:Set[${options.FindSetting[clcritattack2,${clcritattack2}]}]
	clcritattack3:Set[${options.FindSetting[clcritattack3,${clcritattack3}]}]
	clcrit:Set[${options.FindSetting[clcrit,${clcrit}]}]
	clmeleebuff:Set[${options.FindSetting[clmeleebuff,${clmeleebuff}]}]

	discbigheal:Set[${options.FindSetting[discbigheal,${discbigheal}]}]
	discfastheal:Set[${options.FindSetting[discfastheal,${discfastheal}]}]
	discsmallheal:Set[${options.FindSetting[discsmallheal,${discsmallheal}]}]
	discmel:Set[${options.FindSetting[discmel,${discmel}]}]
	discmeleerot:Set[${options.FindSetting[discmeleerot,${discmeleerot}]}]
	discmeleeattack1:Set[${options.FindSetting[discmeleeattack1,${discmeleeattack1}]}]
	discmeleeattack2:Set[${options.FindSetting[discmeleeattack2,${discmeleeattack2}]}]
	discmeleeattack3:Set[${options.FindSetting[discmeleeattack3,${discmeleeattack3}]}]
	disccritattack1:Set[${options.FindSetting[disccritattack1,${disccritattack1}]}]
	disccritattack2:Set[${options.FindSetting[disccritattack2,${disccritattack2}]}]
	disccritattack3:Set[${options.FindSetting[disccritattack3,${disccritattack3}]}]
	discenergyattack1:Set[${options.FindSetting[discenergyattack1,${discenergyattack1}]}]
	discmeleebuff1:Set[${options.FindSetting[discmeleebuff1,${discmeleebuff1}]}]
	discmeleebuff2:Set[${options.FindSetting[discmeleebuff2,${discmeleebuff2}]}]
	disccrit:Set[${options.FindSetting[disccrit,${disccrit}]}]
	discmeleebuff:Set[${options.FindSetting[discmeleebuff,${discmeleebuff}]}]

	bmbigheal:Set[${options.FindSetting[bmbigheal,${bmbigheal}]}]
	bmfastheal:Set[${options.FindSetting[bmfastheal,${bmfastheal}]}]
	bmsmallheal:Set[${options.FindSetting[bmsmallheal,${bmsmallheal}]}]
	bmmeleetarg:Set[${options.FindSetting[bmmeleetarg,${bmmeleetarg}]}]
	bmmeleeattack1:Set[${options.FindSetting[bmmeleeattack1,${bmmeleeattack1}]}]
	bmblasttarg:Set[${options.FindSetting[bmblasttarg,${bmblasttarg}]}]
	bmblastattack1:Set[${options.FindSetting[bmblastattack1,${bmblastattack1}]}]
        bmblastattack2:Set[${options.FindSetting[bmblastattack2,${bmblastattack2}]}]
	bmblastattack3:Set[${options.FindSetting[bmblastattack3,${bmblastattack3}]}]
	bmdottarg:Set[${options.FindSetting[bmdottarg,${bmdottarg}]}]
	bmdotattack1:Set[${options.FindSetting[bmdotattack1,${bmdotattack1}]}]
        bmdotattack2:Set[${options.FindSetting[bmdotattack2,${bmdotattack2}]}]
	bmdotattack3:Set[${options.FindSetting[bmdotattack3,${bmdotattack3}]}]
	bmbloodtarg:Set[${options.FindSetting[bmbloodtarg,${bmbloodtarg}]}]
	bmbloodattack1:Set[${options.FindSetting[bmbloodattack1,${bmbloodattack1}]}]
        bmbloodattack2:Set[${options.FindSetting[bmbloodattack2,${bmbloodattack2}]}]
	bmbloodattack3:Set[${options.FindSetting[bmbloodattack3,${bmbloodattack3}]}]
	bmcrittarg:Set[${options.FindSetting[bmcrittarg,${bmcrittarg}]}]
	bmcritattack1:Set[${options.FindSetting[bmcritattack1,${bmcritattack1}]}]
        bmcritattack2:Set[${options.FindSetting[bmcritattack2,${bmcritattack2}]}]
	bmcritattack3:Set[${options.FindSetting[bmcritattack3,${bmcritattack3}]}]

	palmaintanking:Set[${options.FindSetting[palmaintanking,${palmaintanking}]}]
	palassisting:Set[${options.FindSetting[palassisting,${palassisting}]}]
	shieldfocus:Set[${options.FindSetting[shieldfocus,${shieldfocus}]}]
	usejudgment:Set[${options.FindSetting[usejudgment,${usejudgment}]}]
	judgmentfocus:Set[${options.FindSetting[judgmentfocus,${judgmentfocus}]}]
	palistance:Set[${options.FindSetting[palistance,${palistance}]}]
	palifightingundead:Set[${options.FindSetting[palifightingundead,${palifightingundead}]}]
	palifightinghealers:Set[${options.FindSetting[palifightinghealers,${palifightinghealers}]}]
	palimaxdps:Set[${options.FindSetting[palimaxdps,${palimaxdps}]}]
	palimaxhate:Set[${options.FindSetting[palimaxhate,${palimaxhate}]}]
	paliautores:Set[${options.FindSetting[paliautores,${paliautores}]}]
	paliautocounter:Set[${options.FindSetting[paliautocounter,${paliautocounter}]}]
	paliundeaddebuff:Set[${options.FindSetting[paliundeaddebuff,${paliundeaddebuff}]}]
	boonfocus:Set[${options.FindSetting[boonfocus,${boonfocus}]}]

	hgrp1:Set[${options.FindSetting[hgrp1,${hgrp1}]}]
	hgrp2:Set[${options.FindSetting[hgrp2,${hgrp2}]}]
	hgrp3:Set[${options.FindSetting[hgrp3,${hgrp3}]}]
	hgrp4:Set[${options.FindSetting[hgrp4,${hgrp4}]}]
	hgrp5:Set[${options.FindSetting[hgrp5,${hgrp5}]}]
	hgrp6:Set[${options.FindSetting[hgrp6,${hgrp6}]}]

	rhgrp1:Set[${options.FindSetting[rhgrp1,${rhgrp1}]}]
	rhgrp2:Set[${options.FindSetting[rhgrp2,${rhgrp2}]}]
	rhgrp3:Set[${options.FindSetting[rhgrp3,${rhgrp3}]}]
	rhgrp4:Set[${options.FindSetting[rhgrp4,${rhgrp4}]}]
	rhgrp5:Set[${options.FindSetting[rhgrp5,${rhgrp5}]}]
	rhgrp6:Set[${options.FindSetting[rhgrp6,${rhgrp6}]}]
     
	fhgrp1:Set[${options.FindSetting[fhgrp1,${fhgrp1}]}]
	fhgrp2:Set[${options.FindSetting[fhgrp2,${fhgrp2}]}]
	fhgrp3:Set[${options.FindSetting[fhgrp3,${fhgrp3}]}]
	fhgrp4:Set[${options.FindSetting[fhgrp4,${fhgrp4}]}]
	fhgrp5:Set[${options.FindSetting[fhgrp5,${fhgrp5}]}]
	fhgrp6:Set[${options.FindSetting[fhgrp6,${fhgrp6}]}]  

	bhgrp1:Set[${options.FindSetting[bhgrp1,${bhgrp1}]}]
	bhgrp2:Set[${options.FindSetting[bhgrp2,${bhgrp2}]}]
	bhgrp3:Set[${options.FindSetting[bhgrp3,${bhgrp3}]}]
	bhgrp4:Set[${options.FindSetting[bhgrp4,${bhgrp4}]}]
	bhgrp5:Set[${options.FindSetting[bhgrp5,${bhgrp5}]}]
	bhgrp6:Set[${options.FindSetting[bhgrp6,${bhgrp6}]}]

	mkattack1:Set[${options.FindSetting[mkattack1,${mkattack1}]}]
	mkattack2:Set[${options.FindSetting[mkattack2,${mkattack2}]}]
	mkattack3:Set[${options.FindSetting[mkattack3,${mkattack3}]}]
	mkagropush1:Set[${options.FindSetting[mkagropush1,${mkagropush1}]}]
	mkjin1:Set[${options.FindSetting[mkjin1,${mkjin1}]}]
	mkjin2:Set[${options.FindSetting[mkjin2,${mkjin2}]}]
	mkjin3:Set[${options.FindSetting[mkjin3,${mkjin3}]}]
	mkjinbuff1:Set[${options.FindSetting[mkjinbuff1,${mkjinbuff1}]}]
	mkjinbuff2:Set[${options.FindSetting[mkjinbuff2,${mkjinbuff2}]}]
	mkstance:Set[${options.FindSetting[mkstance,${mkstance}]}]
	mkaum:Set[${options.FindSetting[mkaum,${mkaum}]}]
	mksecret:Set[${options.FindSetting[mksecret,${mksecret}]}]
	mkfeign:Set[${options.FindSetting[mkfeign,${mkfeign}]}]
	mkfd:Set[${options.FindSetting[mkfd,${mkfd}]}]
	mkattack:Set[${options.FindSetting[mkattack,${mkattack}]}]

	rhgrp1pct:Set[${options.FindSetting[rhgrp1pct,${rhgrp1pct}]}]
	rhgrp2pct:Set[${options.FindSetting[rhgrp2pct,${rhgrp2pct}]}]
	rhgrp3pct:Set[${options.FindSetting[rhgrp3pct,${rhgrp3pct}]}]
	rhgrp4pct:Set[${options.FindSetting[rhgrp4pct,${rhgrp4pct}]}]
	rhgrp5pct:Set[${options.FindSetting[rhgrp5pct,${rhgrp5pct}]}]
	rhgrp6pct:Set[${options.FindSetting[rhgrp6pct,${rhgrp6pct}]}]
     
	fhgrp1pct:Set[${options.FindSetting[fhgrp1pct,${fhgrp1pct}]}]
	fhgrp2pct:Set[${options.FindSetting[fhgrp2pct,${fhgrp2pct}]}]
	fhgrp3pct:Set[${options.FindSetting[fhgrp3pct,${fhgrp3pct}]}]
	fhgrp4pct:Set[${options.FindSetting[fhgrp4pct,${fhgrp4pct}]}]
	fhgrp5pct:Set[${options.FindSetting[fhgrp5pct,${fhgrp5pct}]}]
	fhgrp6pct:Set[${options.FindSetting[fhgrp6pct,${fhgrp6pct}]}]  

	bhgrp1pct:Set[${options.FindSetting[bhgrp1pct,${bhgrp1pct}]}]
	bhgrp2pct:Set[${options.FindSetting[bhgrp2pct,${bhgrp2pct}]}]
	bhgrp3pct:Set[${options.FindSetting[bhgrp3pct,${bhgrp3pct}]}]
	bhgrp4pct:Set[${options.FindSetting[bhgrp4pct,${bhgrp4pct}]}]
	bhgrp5pct:Set[${options.FindSetting[bhgrp5pct,${bhgrp5pct}]}]
	bhgrp6pct:Set[${options.FindSetting[bhgrp6pct,${bhgrp6pct}]}]

	rhgrp1pct2:Set[${options.FindSetting[rhgrp1pct2,${rhgrp1pct2}]}]
	rhgrp2pct2:Set[${options.FindSetting[rhgrp2pct2,${rhgrp2pct2}]}]
	rhgrp3pct2:Set[${options.FindSetting[rhgrp3pct2,${rhgrp3pct2}]}]
	rhgrp4pct2:Set[${options.FindSetting[rhgrp4pct2,${rhgrp4pct2}]}]
	rhgrp5pct2:Set[${options.FindSetting[rhgrp5pct2,${rhgrp5pct2}]}]
	rhgrp6pct2:Set[${options.FindSetting[rhgrp6pct2,${rhgrp6pct2}]}]
     
	fhgrp1pct2:Set[${options.FindSetting[fhgrp1pct2,${fhgrp1pct2}]}]
	fhgrp2pct2:Set[${options.FindSetting[fhgrp2pct2,${fhgrp2pct2}]}]
	fhgrp3pct2:Set[${options.FindSetting[fhgrp3pct2,${fhgrp3pct2}]}]
	fhgrp4pct2:Set[${options.FindSetting[fhgrp4pct2,${fhgrp4pct2}]}]
	fhgrp5pct2:Set[${options.FindSetting[fhgrp5pct2,${fhgrp5pct2}]}]
	fhgrp6pct2:Set[${options.FindSetting[fhgrp6pct2,${fhgrp6pct2}]}]  

	bhgrp1pct2:Set[${options.FindSetting[bhgrp1pct2,${bhgrp1pct2}]}]
	bhgrp2pct2:Set[${options.FindSetting[bhgrp2pct2,${bhgrp2pct2}]}]
	bhgrp3pct2:Set[${options.FindSetting[bhgrp3pct2,${bhgrp3pct2}]}]
	bhgrp4pct2:Set[${options.FindSetting[bhgrp4pct2,${bhgrp4pct2}]}]
	bhgrp5pct2:Set[${options.FindSetting[bhgrp5pct2,${bhgrp5pct2}]}]
	bhgrp6pct2:Set[${options.FindSetting[bhgrp6pct2,${bhgrp6pct2}]}]

	shbigheal:Set[${options.FindSetting[shbigheal,${shbigheal}]}]
	shfastheal:Set[${options.FindSetting[shfastheal,${shfastheal}]}]
	shsmallheal:Set[${options.FindSetting[shsmallheal,${shsmallheal}]}]
	shdottarg:Set[${options.FindSetting[shdottarg,${shdottarg}]}]
	shdotattack1:Set[${options.FindSetting[shdotattack1,${shdotattack1}]}]
	shdotattack2:Set[${options.FindSetting[shdotattack2,${shdotattack2}]}]
	shdotattack3:Set[${options.FindSetting[shdotattack3,${shdotattack3}]}]
	shdotattack4:Set[${options.FindSetting[shdotattack4,${shdotattack4}]}]
	shblasttarg:Set[${options.FindSetting[shblasttarg,${shblasttarg}]}]
	shblastattack1:Set[${options.FindSetting[shblastattack1,${shblastattack1}]}]
	shblastattack2:Set[${options.FindSetting[shblastattack2,${shblastattack2}]}]
	shslowattack1:Set[${options.FindSetting[shslowattack1,${shslowattack1}]}]
	shslowtarg:Set[${options.FindSetting[shslowtarg,${shslowtarg}]}]
	shcann:Set[${options.FindSetting[shcann,${shcann}]}]
	shsmcann:Set[${options.FindSetting[shsmcann,${shsmcann}]}]
	shbigcann:Set[${options.FindSetting[shbigcann,${shbigcann}]}]
	shcrittarg:Set[${options.FindSetting[shcrittarg,${shcrittarg}]}]
	shcritattack1:Set[${options.FindSetting[shcritattack1,${shcritattack1}]}]
	shcritattack2:Set[${options.FindSetting[shcritattack2,${shcritattack2}]}]
	shcritattack3:Set[${options.FindSetting[shcritattack3,${shcritattack3}]}]
	shcritattack4:Set[${options.FindSetting[shcritattack4,${shcritattack4}]}]

	usecombatmixsong:Set[${options.FindSetting[usecombatmixsong,${usecombatmixsong}]}]
	usecastersong:Set[${options.FindSetting[usecastersong,${usecastersong}]}]
	usemeleesong:Set[${options.FindSetting[usemeleesong,${usemeleesong}]}]
	bardmeleesong:Set[${options.FindSetting[bardmeleesong,${bardmeleesong}]}]
	bardenergysong:Set[${options.FindSetting[bardenergysong,${bardenergysong}]}]
	bardrunsong:Set[${options.FindSetting[bardrunsong,${bardrunsong}]}]
	bardcastersong:Set[${options.FindSetting[bardcastersong,${bardcastersong}]}]
	bardcombatmixsong:Set[${options.FindSetting[bardcombatmixsong,${bardcombatmixsong}]}]
	bardweapon1:Set[${options.FindSetting[bardweapon1,${bardweapon1}]}]
	bardweapon2:Set[${options.FindSetting[bardweapon2,${bardweapon2}]}]
	Drum:Set[${options.FindSetting[Drum,${Drum}]}]
	Lute:Set[${options.FindSetting[Lute,${Lute}]}]
	Horn:Set[${options.FindSetting[Horn,${Horn}]}]
	Flute:Set[${options.FindSetting[Flute,${Flute}]}]

        Use_Dbuff:Set[${options.FindSetting[Use_Dbuff,${Use_Dbuff}]}]
        Use_Counter:Set[${options.FindSetting[Use_Counter,${Use_Counter}]}]
        Use_Chains:Set[${options.FindSetting[Use_Chains,${Use_Chains}]}]
	
	Use_Minions:Set[${options.FindSetting[Use_Minions,${Use_Minions}]}]
	Use_Pet:Set[${options.FindSetting[Use_Pet,${Use_Pet}]}]
        CorpseSearch:Set[${options.FindSetting[CorpseSearch,${CorpseSearch}]}]

        Light_DPS:Set[${options.FindSetting[Light_DPS,${Light_DPS}]}]
        Use_Heal:Set[${options.FindSetting[Use_Heal,${Use_Heal}]}]
        dots:Set[${options.FindSetting[dots,${Use_DoT}]}]
        nukes:Set[${options.FindSetting[nukes,${Use_DD}]}]
 
        Dot1:Set[${options.FindSetting[Dot1,${Dot1}]}]
        Dot2:Set[${options.FindSetting[Dot2,${Dot2}]}]
        Dot3:Set[${options.FindSetting[Dot3,${Dot3}]}]
        Dot4:Set[${options.FindSetting[Dot4,${Dot4}]}]

        Nuke1:Set[${options.FindSetting[Nuke1,${Nuke1}]}]
        Nuke2:Set[${options.FindSetting[Nuke2,${Nuke2}]}]

        Heal1:Set[${options.FindSetting[Heal1,${Heal1}]}]

        Debuff1:Set[${options.FindSetting[Debuff1,${Debuff1}]}]
        Debuff2:Set[${options.FindSetting[Debuff2,${Debuff2}]}]

        MinionType1:Set[${options.FindSetting[MinionType1,${MinionType1}]}]
        MinionType2:Set[${options.FindSetting[MinionType2,${MinionType2}]}]

        WeaponMain:Set[${options.FindSetting[WeaponMain,${WeaponMain}]}]
        WeaponSeconday:Set[${options.FindSetting[WeaponSecondary,${WeaponSecondary}]}]

	counterall:Set[${options.FindSetting[counterall,${counterall}]}]
	counterselected:Set[${options.FindSetting[counterselected,${counterselected}]}]
	DispellSelected:Set[${options.FindSetting[DispellSelected,${DispellSelected}]}]

	usearcane:Set[${options.FindSetting[usearcane,${usearcane}]}]
	useice:Set[${options.FindSetting[useice,${useice}]}]
	usefire:Set[${options.FindSetting[usefire,${usefire}]}]
	usearea:Set[${options.FindSetting[usearea,${usearea}]}]
	useaegroup:Set[${options.FindSetting[useaegroup,${useaegroup}]}]
	useamplify:Set[${options.FindSetting[useamplify,${useamplify}]}]
	usesorcslowcasting:Set[${options.FindSetting[usesorcslowcasting,${usesorcslowcasting}]}]
	usesorcforget:Set[${options.FindSetting[usesorcforget,${usesorcforget}]}]
	sorcslowcastingspeed:Set[${options.FindSetting[sorcslowcastingspeed,${sorcslowcastingspeed}]}]
	sorcforgetnumber:Set[${options.FindSetting[sorcforgetnumber,${sorcforgetnumber}]}]

     }
  
   method Save()
     {
      Echo Saving Config Files
      
      ;; Settings:AddSetting[]
	
	options:AddSetting[assistm,${assistm}]
        options:AddSetting[facem,${facem}]

	options:AddSetting[movetot,${movetot}]
        options:AddSetting[mtotpct,${mtotpct}]
        options:AddSetting[aharv,${aharv}]
        
        options:AddSetting[Use_Dbuff,${Use_Dbuff}]
        options:AddSetting[assistm,${assistm}]
	options:AddSetting[mountup,${mountup}]
        
        options:AddSetting[lootit,${lootit}]
        options:AddSetting[restandfood,${restandfood}]
	options:AddSetting[autogroup,${autogroup}]
	options:AddSetting[autotrade,${autotrade}]

	options:AddSetting[plmember1,${plmember1}]
	options:AddSetting[plmember2,${plmember2}]
	options:AddSetting[plmember3,${plmember3}]
	options:AddSetting[plmember4,${plmember4}]
	options:AddSetting[plmember5,${plmember5}]
	options:AddSetting[plmember6,${plmember6}]
	options:AddSetting[plmode,${plmode}]
	options:AddSetting[pldebuff1,${pldebuff1}]
	options:AddSetting[pldebuff2,${pldebuff2}]
	options:AddSetting[pldebuff,${pldebuff}]

	options:AddSetting[usecombatmixsong,${usecombatmixsong}]
	options:AddSetting[usecastersong,${usecastersong}]
	options:AddSetting[usemeleesong,${usemeleesong}]
	options:AddSetting[bardmeleesong,${bardmeleesong}]
	options:AddSetting[bardenergysong,${bardenergysong}]
	options:AddSetting[bardrunsong,${bardrunsong}]
	options:AddSetting[bardcastersong,${bardcastersong}]
	options:AddSetting[bardcombatmixsong,${bardcombatmixsong}]
	options:AddSetting[bardweapon1,${bardweapon1}]
	options:AddSetting[bardweapon2,${bardweapon2}]
	options:AddSetting[Drum,${Drum}]
	options:AddSetting[Lute,${Lute}]
	options:AddSetting[Horn,${Horn}]
	options:AddSetting[Flute,${Flute}]

	options:AddSetting[clbigheal,${clbigheal}]
        options:AddSetting[clfastheal,${clfastheal}]
	options:AddSetting[clsmallheal,${clsmallheal}]
	options:AddSetting[clmeleetarg,${clmeleetarg}]
	options:AddSetting[clmeleeattack1,${clmeleeattack1}]
	options:AddSetting[clmeleeattack2,${clmeleeattack2}]
	options:AddSetting[clmeleeattack3,${clmeleeattack3}]
	options:AddSetting[clenergyattack1,${clenergyattack1}]
	options:AddSetting[clmeleebuff1,${clmeleebuff1}]
	options:AddSetting[clmeleebuff2,${clmeleebuff2}]
	options:AddSetting[clcritattack1,${clcritattack1}]
	options:AddSetting[clcritattack2,${clcritattack2}]
	options:AddSetting[clcritattack3,${clcritattack3}]
	options:AddSetting[clcrit,${clcrit}]
	options:AddSetting[clmeleebuff,${clmeleebuff}]

	options:AddSetting[mkattack1,${mkattack1}]
	options:AddSetting[mkattack2,${mkattack2}]
	options:AddSetting[mkattack3,${mkattack3}]
	options:AddSetting[mkagropush1,${mkagropush1}]
	options:AddSetting[mkjin1,${mkjin1}]
	options:AddSetting[mkjin2,${mkjin2}]
	options:AddSetting[mkjin3,${mkjin3}]
	options:AddSetting[mkjinbuff1,${mkjinbuff1}]
	options:AddSetting[mkjinbuff2,${mkjinbuff2}]
	options:AddSetting[mkstance,${mkstance}]
	options:AddSetting[mkaum,${mkaum}]
	options:AddSetting[mksecret,${mksecret}]
	options:AddSetting[mkfeign,${mkfeign}]
	options:AddSetting[mkfd,${mkfd}]
	options:AddSetting[mkattack,${mkattack}]
	
	options:AddSetting[discbigheal,${discbigheal}]
	options:AddSetting[discfastheal,${discfastheal}]
	options:AddSetting[discsmallheal,${discsmallheal}]
	options:AddSetting[discmel,${discmel}]
	options:AddSetting[discmeleerot,${discmeleerot}]
	options:AddSetting[discmeleeattack1,${discmeleeattack1}]
	options:AddSetting[discmeleeattack2,${discmeleeattack2}]
	options:AddSetting[discmeleeattack3,${discmeleeattack3}]
	options:AddSetting[disccritattack1,${disccritattack1}]
	options:AddSetting[disccritattack2,${disccritattack2}]
	options:AddSetting[disccritattack3,${disccritattack3}]
	options:AddSetting[discenergyattack1,${discenergyattack1}]
	options:AddSetting[discmeleebuff1,${discmeleebuff1}]
	options:AddSetting[discmeleebuff2,${discmeleebuff2}]
	options:AddSetting[disccrit,${disccrit}]
	options:AddSetting[discmeleebuff,${discmeleebuff}]

	options:AddSetting[bmbigheal,${bmbigheal}]
        options:AddSetting[bmfastheal,${bmfastheal}]
	options:AddSetting[bmsmallheal,${bmsmallheal}]
	options:AddSetting[bmmeleetarg,${bmmeleetarg}]
	options:AddSetting[bmmeleeattack1,${bmmeleeattack1}]
	options:AddSetting[bmblasttarg,${bmblasttarg}]
	options:AddSetting[bmblastattack1,${bmblastattack1}]
	options:AddSetting[bmblastattack2,${bmblastattack2}]
	options:AddSetting[bmblastattack3,${bmblastattack3}]
	options:AddSetting[bmdottarg,${bmdottarg}]
	options:AddSetting[bmdotattack1,${bmdotattack1}]
	options:AddSetting[bmdotattack2,${bmdotattack2}]
	options:AddSetting[bmdotattack3,${bmdotattack3}]
	options:AddSetting[bmbloodtarg,${bmbloodtarg}]
	options:AddSetting[bmbloodattack1,${bmbloodattack1}]
	options:AddSetting[bmbloodattack2,${bmbloodattack2}]
	options:AddSetting[bmbloodattack3,${bmbloodattack3}]
	options:AddSetting[bmcrittarg,${bmcrittarg}]
	options:AddSetting[bmcritattack1,${bmcritattack1}]
	options:AddSetting[bmcritattack2,${bmcritattack2}]
	options:AddSetting[bmcritattack3,${bmcritattack3}]

	options:AddSetting[palmaintanking,${palmaintanking}]
	options:AddSetting[palassisting,${palassisting}]
	options:AddSetting[shieldfocus,${shieldfocus}]
	options:AddSetting[usejudgment,${usejudgment}]
	options:AddSetting[judgmentfocus,${judgmentfocus}]
	options:AddSetting[palistance,${palistance}]
	options:AddSetting[palifightingundead,${palifightingundead}]
	options:AddSetting[palifightinghealers,${palifightinghealers}]
	options:AddSetting[palimaxdps,${palimaxdps}]
	options:AddSetting[palimaxhate,${palimaxhate}]
	options:AddSetting[paliautores,${paliautores}]
	options:AddSetting[paliautocounter,${paliautocounter}]
	options:AddSetting[paliundeaddebuff,${paliundeaddebuff}]
	options:AddSetting[boonfocus,${boonfocus}]

	options:AddSetting[hgrp1,${hgrp1}]
	options:AddSetting[hgrp2,${hgrp2}]
	options:AddSetting[hgrp3,${hgrp3}]
	options:AddSetting[hgrp4,${hgrp4}]
	options:AddSetting[hgrp5,${hgrp5}]
	options:AddSetting[hgrp6,${hgrp6}]

	options:AddSetting[rhgrp1,${rhgrp1}]
	options:AddSetting[rhgrp2,${rhgrp2}]
	options:AddSetting[rhgrp3,${rhgrp3}]
	options:AddSetting[rhgrp4,${rhgrp4}]
	options:AddSetting[rhgrp5,${rhgrp5}]
	options:AddSetting[rhgrp6,${rhgrp6}]

	options:AddSetting[fhgrp1,${fhgrp1}]
	options:AddSetting[fhgrp2,${fhgrp2}]
	options:AddSetting[fhgrp3,${fhgrp3}]
	options:AddSetting[fhgrp4,${fhgrp4}]
	options:AddSetting[fhgrp5,${fhgrp5}]
	options:AddSetting[fhgrp6,${fhgrp6}]

	options:AddSetting[bhgrp1,${bhgrp1}]
	options:AddSetting[bhgrp2,${bhgrp2}]
	options:AddSetting[bhgrp3,${bhgrp3}]
	options:AddSetting[bhgrp4,${bhgrp4}]
	options:AddSetting[bhgrp5,${bhgrp5}]
	options:AddSetting[bhgrp6,${bhgrp6}]

	options:AddSetting[rhgrp1pct,${rhgrp1pct}]
	options:AddSetting[rhgrp2pct,${rhgrp2pct}]
	options:AddSetting[rhgrp3pct,${rhgrp3pct}]
	options:AddSetting[rhgrp4pct,${rhgrp4pct}]
	options:AddSetting[rhgrp5pct,${rhgrp5pct}]
	options:AddSetting[rhgrp6pct,${rhgrp6pct}]

	options:AddSetting[fhgrp1pct,${fhgrp1pct}]
	options:AddSetting[fhgrp2pct,${fhgrp2pct}]
	options:AddSetting[fhgrp3pct,${fhgrp3pct}]
	options:AddSetting[fhgrp4pct,${fhgrp4pct}]
	options:AddSetting[fhgrp5pct,${fhgrp5pct}]
	options:AddSetting[fhgrp6pct,${fhgrp6pct}]

	options:AddSetting[bhgrp1pct,${bhgrp1pct}]
	options:AddSetting[bhgrp2pct,${bhgrp2pct}]
	options:AddSetting[bhgrp3pct,${bhgrp3pct}]
	options:AddSetting[bhgrp4pct,${bhgrp4pct}]
	options:AddSetting[bhgrp5pct,${bhgrp5pct}]
	options:AddSetting[bhgrp6pct,${bhgrp6pct}]

	options:AddSetting[rhgrp1pct2,${rhgrp1pct2}]
	options:AddSetting[rhgrp2pct2,${rhgrp2pct2}]
	options:AddSetting[rhgrp3pct2,${rhgrp3pct2}]
	options:AddSetting[rhgrp4pct2,${rhgrp4pct2}]
	options:AddSetting[rhgrp5pct2,${rhgrp5pct2}]
	options:AddSetting[rhgrp6pct2,${rhgrp6pct2}]

	options:AddSetting[fhgrp1pct2,${fhgrp1pct2}]
	options:AddSetting[fhgrp2pct2,${fhgrp2pct2}]
	options:AddSetting[fhgrp3pct2,${fhgrp3pct2}]
	options:AddSetting[fhgrp4pct2,${fhgrp4pct2}]
	options:AddSetting[fhgrp5pct2,${fhgrp5pct2}]
	options:AddSetting[fhgrp6pct2,${fhgrp6pct2}]

	options:AddSetting[bhgrp1pct2,${bhgrp1pct2}]
	options:AddSetting[bhgrp2pct2,${bhgrp2pct2}]
	options:AddSetting[bhgrp3pct2,${bhgrp3pct2}]
	options:AddSetting[bhgrp4pct2,${bhgrp4pct2}]
	options:AddSetting[bhgrp5pct2,${bhgrp5pct2}]
	options:AddSetting[bhgrp6pct2,${bhgrp6pct2}]

	options:AddSetting[shbigheal,${shbigheal}]
	options:AddSetting[shfastheal,${shfastheal}]
	options:AddSetting[shsmallheal,${shsmallheal}]
	options:AddSetting[shdottarg,${shdottarg}]
	options:AddSetting[shdotattack1,${shdotattack1}]
	options:AddSetting[shdotattack2,${shdotattack2}]
	options:AddSetting[shdotattack3,${shdotattack3}]
	options:AddSetting[shdotattack4,${shdotattack4}]
	options:AddSetting[shblasttarg,${shblasttarg}]
	options:AddSetting[shblastattack1,${shblastattack1}]
	options:AddSetting[shblastattack2,${shblastattack2}]
	options:AddSetting[shslowattack1,${shslowattack1}]
	options:AddSetting[shslowtarg,${shslowtarg}]
	options:AddSetting[shcann,${shcann}]
	options:AddSetting[shsmcann,${shsmcann}]
	options:AddSetting[shbigcann,${shbigcann}]
	options:AddSetting[shcrittarg,${shcrittarg}]
	options:AddSetting[shcritattack1,${shcritattack1}]
	options:AddSetting[shcritattack2,${shcritattack2}]
	options:AddSetting[shcritattack3,${shcritattack3}]
	options:AddSetting[shcritattack4,${shcritattack4}]
	options:AddSetting[ourbard,${ourbard}]


        options:AddSetting[Use_Dbuff,${Use_Dbuff}]
        options:AddSetting[Use_Counter,${Use_Counter}]
        options:AddSetting[Use_Chains,${Use_Chains}]

	options:AddSetting[Use_Minions,${Use_Minions}]
        options:AddSetting[Use_Pet,${Use_Pet}]
        options:AddSetting[CorpseSearch,${CorpseSearch}]
        
        options:AddSetting[Light_DPS,${Light_DPS}]
        options:AddSetting[Use_Heal,${Use_Heal}]
        options:AddSetting[dots,${Use_DoT}]
        options:AddSetting[nukes,${Use_DD}]

        options:AddSetting[Dot1,${Dot1}]
        options:AddSetting[Dot2,${Dot2}]
        options:AddSetting[Dot3,${Dot3}]
        options:AddSetting[Dot4,${Dot4}]

        options:AddSetting[Nuke1,${Nuke1}]
        options:AddSetting[Nuke2,${Nuke2}]

        options:AddSetting[Heal1,${Heal1}]

        options:AddSetting[Debuff1,${Debuff1}]
        options:AddSetting[Debuff2,${Debuff2}]

        options:AddSetting[MinionType1,${MinionType1}]
        options:AddSetting[MinionType2,${MinionType2}]

        options:AddSetting[WeaponMain,${WeaponMain}]
        options:AddSetting[WeaponSecondary,${WeaponSecondary}]
	
        options:AddSetting[counterall,${counterall}]
	options:AddSetting[counterselected,${counterselected}]
	options:AddSetting[DispellSelected,${DispellSelected}]

	options:AddSetting[usearcane,${usearcane}]
	options:AddSetting[useice,${useice}]
	options:AddSetting[usefire,${usefire}]
	options:AddSetting[usearea,${usearea}]
	options:AddSetting[useaegroup,${useaegroup}]
	options:AddSetting[useamplify,${useamplify}]
	options:AddSetting[usesorcslowcasting,${usesorcslowcasting}]
	options:AddSetting[usesorcforget,${usesorcforget}]
	options:AddSetting[sorcslowcastingspeed,${sorcslowcastingspeed}]
	options:AddSetting[sorcforgetnumber,${sorcforgetnumber}]

      ;; Save to File
		  LavishSettings[${Main_Container}]:Export[${CF}]
     }
  
  }
   
 variable vgassist_Config vgassist_Config 

 ; *Fold*
;********************************************
/* Add item to the Dispell list */
;********************************************
atom(global) AddDispellSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DispellSpells:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDispellSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DispellSpells.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDispellList()
{
        echo building Dispell List
	variable iterator Iterator
	DispellSpells:GetSettingIterator[Iterator]
	UIElement[DispellList@MainCasterFrame@MainCaster@SubCaster@CasterFrame@Caster@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DispellList@MainCasterFrame@MainCaster@SubCaster@CasterFrame@Caster@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}  
;********************************************
function dispellfunct()
{
	
	if ${DispellSelected}
		{
		variable iterator Iterator
		DispellSpells:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
				if ${Me.TargetBuff[${Iterator.Key}](exists)}
				{
				echo "OMG Dispell ${Iterator.Key}"
					if ${Me.Ability[${dispell1}].IsReady}
					{
					Me.Ability[${dispell1}]:Use
					call MeCasting
					}
				}
			Iterator:Next
			}
		}
	
} 
;********************************************
/* Add item to the Counter list */
;********************************************
atom(global) AddcounterSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		CounterSpells:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveCounterSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		CounterSpells.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildCounterList()
{
        echo building
	variable iterator Iterator
	CounterSpells:GetSettingIterator[Iterator]
	UIElement[ItemsList@MainCasterFrame@MainCaster@SubCaster@CasterFrame@Caster@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ItemsList@MainCasterFrame@MainCaster@SubCaster@CasterFrame@Caster@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
;********************************************
/* Add item to the Physical Pawns */
;********************************************
atom(global) AddPhysicalPawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		PhysicalPawns:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemovePhysicalPawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		PhysicalPawns.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildPhysicalPawns()
{
        echo building Physical Pawn List
	variable iterator Iterator
	PhysicalPawns:GetSettingIterator[Iterator]
	UIElement[PhysicalPList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PhysicalPList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
;********************************************
/* Add item to the Arcane Pawns */
;********************************************
atom(global) AddArcanePawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		ArcanePawns:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveArcanePawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		ArcanePawns.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildArcanePawns()
{
        echo building Arcane Pawn List
	variable iterator Iterator
	ArcanePawns:GetSettingIterator[Iterator]
	UIElement[ArcanePList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ArcanePList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
;********************************************
/* Add item to the Ice Pawns */
;********************************************
atom(global) AddIcePawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		IcePawns:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveIcePawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		IcePawns.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildIcePawns()
{
        echo building Ice Pawn List
	variable iterator Iterator
	IcePawns:GetSettingIterator[Iterator]
	UIElement[IcePList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[IcePList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
;********************************************
/* Add item to the Fire Pawns */
;********************************************
atom(global) AddFirePawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		FirePawns:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveFirePawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		FirePawns.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildFirePawns()
{
        echo building Fire Pawn List
	variable iterator Iterator
	FirePawns:GetSettingIterator[Iterator]
	UIElement[FirePList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FirePList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
;********************************************
/* Add item to the Spiritual Pawns */
;********************************************
atom(global) AddSpiritualPawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		SpiritualPawns:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveSpiritualPawns(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		SpiritualPawns.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildSpiritualPawns()
{
        echo building Spiritual Pawn List
	variable iterator Iterator
	SpiritualPawns:GetSettingIterator[Iterator]
	UIElement[SpiritualPList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[SpiritualPList@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 

;********************************************
function counteringfunct()
{
	If ${nonecasting.NotEqual[${Me.TargetCasting}]}
	{
	mobcasting:Set[${Me.TargetCasting}]
	echo "Mob is Casting ${mobcasting}"
	if ${counterall} && ${nonecasting.NotEqual[${Me.TargetCasting}]}
		{
		echo Stopping all Casts
		if ${Me.Ability[${counterspell1}].IsReady}
		{
		Me.Ability[${counterspell1}]:Use
		call MeCasting
		}
		if ${Me.Ability[${counterspell2}].IsReady}
		{
		Me.Ability[${counterspell2}]:Use
		call MeCasting
		}
		}
	if ${counterselected} && ${nonecasting.NotEqual[${Me.TargetCasting}]}
		{
		variable iterator Iterator
		CounterSpells:GetSettingIterator[Iterator]
		while ( ${Iterator.Key(exists)} )
			{
				if ${mobcasting.Equal[${Iterator.Key}]}
				{
				echo OMG Counter it
				Me.Ability[${counterspell1}]:Use
				wait 1
					if ${Me.Ability[${counterspell1}].IsReady}
					{
					Me.Ability[${counterspell1}]:Use
					call MeCasting
					}
					if ${Me.Ability[${counterspell2}].IsReady}
					{
					Me.Ability[${counterspell2}]:Use
					call MeCasting
					}
				}
			Iterator:Next
			}
		}
	}
} 
;********************************************
function timeFormat(int vTime)
{
	declare sTime string local "" 
	
	sTime:Set[${Math.Calc[(${vTime}/1000/60/60)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${vTime}/1000/60)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${vTime}/1000)%60].Int.LeadingZeroes[2]}]
	
	return ${sTime}
}

; *Fold*
