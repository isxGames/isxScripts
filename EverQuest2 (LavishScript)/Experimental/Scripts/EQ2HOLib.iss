;*************************************************************
;EQ2HOlib.iss
;version 200607020a
;added soldier's instinct
;fixed bug with Archaic Shackles
;fixed bug with Soldier's Gambit
;State 6 = Last advance wheel
;State 5 = Second advance wheel for 3 stage ho advances
;State 4 = Initial advance wheel
;State 3 = scout cant change wheel?
;State 1 = Wheel is being completed
;State 2 = expired or completed wheel
;state 0 = scout can change wheel? 
;
;
;States changed these are the new assumptions
;State 6 = Last advance wheel
;State 5 = Second advance wheel for 3 stage ho advances
;State 4 = Initial advance wheel
;State 3 = scout cant change wheel?
;State 1 = Wheel is being completed
;State 2 = HO in countdown
;state 0 = scout can change wheel? 
;
;Note all HOs have 10seconds to complete
;All HO buffs last 6 mins
;TODO: Add check if we have enough time to complete HO before we cast?
;TODO: Refresh HO Buffs?
;TODO: Prioritize HOs?
;*************************************************************
#define _EQ2HOLIB_

objectdef HeroicOp
{
	variable string ScoutCoin1
	variable string ScoutCoin2
	variable string ScoutDagger1
	variable string ScoutDagger2
	variable string ScoutCloak1
	variable string ScoutCloak2
	variable string ScoutMask1
	variable string ScoutMask2
	variable string ScoutBow1
	variable string ScoutBow2
	
	variable string MageStar1
	variable string MageStar2
	variable string MageLightning1
	variable string MageLightning2
	variable string MageFlame1
	variable string MageFlame2
	variable string MageStaff1
	variable string MageStaff2
	variable string MageWand1
	variable string MageWand2	
	
	variable string FighterHorn1
	variable string FighterHorn2
	variable string FighterBoot1
	variable string FighterBoot2
	variable string FighterArm1
	variable string FighterArm2
	variable string FighterFist1
	variable string FighterFist2
	variable string FighterSword1
	variable string FighterSword2
	
	variable string PriestHammer1
	variable string PriestHammer2
	variable string PriestChalice1
	variable string PriestChalice2
	variable string PriestMoon1
	variable string PriestMoon2
	variable string PriestHolySymbol1
	variable string PriestHolySymbol2
	variable string PriestEye1
	variable string PriestEye2

	variable string charfile="${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/${Me.Name}.xml"
	
	method Initialize()
	{
		
		switch ${Me.Archetype}
		{
			case fighter
				FighterSword1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterSword1,""]}]
				FighterSword2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterSword2,""]}]
				FighterHorn1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterHorn1,""]}]
				FighterHorn2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterHorn2,""]}]
				FighterBoot1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterBoot1,""]}]
				FighterBoot2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterBoot2,""]}]
				FighterArm1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterArm1,""]}]
				FighterArm2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterArm2,""]}]
				FighterFist1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterFist1,""]}]
				FighterFist2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterFist1,""]}]
				break

			case scout
				ScoutCoin1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCoin1,""]}]
				ScoutCoin2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCoin2,""]}]
				ScoutDagger1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutDagger1,""]}]
				ScoutDagger2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutDagger2,""]}]
				ScoutCloak1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCloak1,""]}]
				ScoutCloak2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCloak2,""]}]
				ScoutMask1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutMask1,""]}]
				ScoutMask2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutMask2,""]}]		
				ScoutBow1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutBow1,""]}]
				ScoutBow2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutBow2,""]}]					
				break

			case mage
				This.MageStar1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStar1,""]}]
				This.MageStar2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStar2,""]}]
				This.MageLightning1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageLightning1,""]}]
				This.MageLightning2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageLightning2,""]}]
				This.MageFlame1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageFlame1,""]}]
				This.MageFlame2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageFlame2,""]}]
				This.MageStaff1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStaff1,""]}]
				This.MageStaff2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStaff2,""]}]
				This.MageWand1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageWand1,""]}]
				This.MageWand2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageWand2,""]}]
				break

			case priest
				PriestHammer1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHammer1,""]}]
				PriestHammer2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHammer2,""]}]
				PriestChalice1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestChalice1,""]}]
				PriestChalice2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestChalice2,""]}]
				PriestMoon1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestMoon1,""]}]
				PriestMoon2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestMoon2,""]}]
				PriestEye1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestEye1,""]}]
				PriestEye2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestEye2,""]}]
				PriestHolySymbol1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHolySymbol1,""]}]
				PriestHolySymbol2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHolySymbol2,""]}]				
				break

			case default
				break

		}
	}

	method Shutdown()
	{
		CurentTask:Set[Shutdown]
	}
	
	member ToText()
	{
		return ${Me.Name}
	}
	
	method LoadUI()
	{
		UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[HOs]
			
		UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[6]:Move[3]
			
		ui -load -parent "HOs@EQ2Bot Tabs@EQ2 Bot" "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/${Me.Archetype}HOs.xml"
	}
	
	method DoHO()
	{
		;echo State: ${EQ2.HOWheelState}
		;echo Slot: ${EQ2.HOCurrentWheelSlot}
		;echo Advanced by:${This.LastManipulatorArchetype}
		;echo HO Name ${EQ2.HOName}
		;Make sure we have a target to cast on,
		
		Target ${Script[EQ2Bot].Variable[KillTarget]}
		
		;Beneficial spells will cast on the KillTarget's current target
		;Detrimentals will cast on the KillTarget
		;This is atomic so we dont need a wait check for the target
		;though the target could be dead by the time the HO advancement
		;or completion spell is cast
		
		
		
		if ${EQ2.HOWheelState}==0 || ${EQ2.HOWheelState}==1 || ${EQ2.HOWheelState}==6
		;State 0 = First wheel after HO intiation
		{
			switch ${This.LastManipulatorArchetype}
			{
				;Scout Intiated HO
				case scout
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							This:CastChalice
							break
						case fighter
							;Pritorizes horn over boot HO advancement. Horn is mostly taunts
							;For non tank fighters reverse boot and horn priority
							if ${Me.Ability[${FighterHorn1}].IsReady} || ${Me.Ability[${FighterHorn2}].IsReady}
							{
								This:CastHorn
							}
							elseif
							{
								This:CastBoot
							}
							break
						case mage
							break
						case default
							break
					}
				;Mage Initiated HO
				case mage
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							This:CastHammer
							break
						case fighter
							break
						case mage
							This:CastLightning
							break
						case default
							break
					}
				;Fighter initiated HO
				case fighter
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							;Priority is chalice which is most priest heals
							;Swap hammer and chalice prioirity for more damage
							;realated HOs
							if ${Me.Ability[${PriestChalice1}].IsReady} || ${Me.Ability[${PriestChalice2}].IsReady}
							{
								This:CastChalice
							}
							elseif
							{
								This:CastHammer
							}
							break
						case fighter
							This:CastSword
							break
						case mage
							;This HO advancement is not visible on the wheel.
							;It is a hidden 5th HO advancement choice from a fighter
							;Initiated HO
							This:CastLightning
							break
						case default
							break
					}
				;Priest Intiated HO
				case priest
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							This:CastHammer
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				case default
					break
					
			}

		}
		elseif ${EQ2.HOWheelState}==3
		;State 5 = Second wheel after HO intiation for 3 stage HO advancements
		{
			switch ${This.LastManipulatorArchetype}
			{
				;Scout Advanced HO
				case scout
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Mage Advanced HO
				case mage
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Fighter advanced HO
				case fighter
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							This:CastMoon
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Priest advanced HO
				case priest
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							This:CastLightning
							break
						case default
							break
					}
				case default
					break
					
			}

		}		
		elseif ${EQ2.HOWheelState}==5 && ${EQ2.HOName(exists)}
		;State 6 = Second wheel after HO intiation for 2 stage HO advancements
		{
			switch ${This.LastManipulatorArchetype}
			{
				;Scout Advanced HO
				case scout
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Mage Advanced HO
				case mage
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Fighter advanced HO
				case fighter
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							This:CastMoon
							break
						case fighter
							break
						case mage
							This:CastLightning
							break
						case default
							break
					}
				;Priest advanced HO
				case priest
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							;Three combos lead here so we will cast both
							;Moon->Fire
							;Chalice->Lightning
							;Hammer->lightning
							This:CastLightning
							This:CastFlame
							break
						case default
							break
					}
				case default
					break
					
			}

		}		
		elseif ${EQ2.HOWheelState}==5 || ${EQ2.HOWheelState}==4 || ${EQ2.HOWheelState}==2

		
		{
			switch ${EQ2.HOName}
			{

				;*****************************************************************
				;	Fighter Intiated HOs
				;*****************************************************************

				case Sky Cleave
				;Single Target Slashing DD
				case Crushing Anvil
				; Encounter AoE Crushing DD
				case Hero's Armor
				;Self Armor Buff
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}			
					break
				case Divine Blade
				;Single Target Divine DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					break
				case Crippling Shroud
				; Has a Chance to Slow Enemy Attack Speed When You Are Hit

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}				

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastMoon
					}
					break
				case  Chalice of Life
				;Group Instant Heal, Ward, & Health Regeneration

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				case Divine Nobility
				; Heal Over Time to a Group Memeber

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}				

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					break				
				case Archaic Ruin
				;Single Target Mental DD
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastEye
					}			
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastArm
					}				
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastFlame
					}				
					break
				case Thunder Slash
				;Single Target Divine, Magic, & Slashing DD (3 different hits)

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}			
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}				
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}				
					break
				case Ancient Wrath
				; Encounter AoE Long Duration Stun and DD

					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFlame
					}			
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastFist
					}				
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastHammer
					}				
					break
				case Luck's Bite
				;Single Target Piercing DD

					if ${Me.Archetype.Equal[scout]}
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastBoot
					}
					break				
				case Swindler's Gift
				;Group Attack Technique Buff (slashing, piercing, etc.)

					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastArm
					}
					break
				case Raging Sword
				;Powerful Slashing DD

					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastHorn
					}
					break
				case Ardent Challenge
				;Group Strength and Agility Buff (+10)

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastArm
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastMask
					}
					break			
				case Scholar's Insight
				; Self Attack Speed Buff

					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastHorn
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastLightning
					}
					break	
				case Storm of Ancients
				;Encounter AoE Magic DD

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break					
				case  Soldier's Instinct
				;Self Evocations and Disruptions Buff

					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFlame
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastArm
					}
					break
				case Arcane Salvation
				;Group Power Restoration
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}			
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastArm
					}				
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}				
					break				
				;*****************************************************************
				;	Scout Intiated HOs
				;*****************************************************************
				case Swindler's Luck
				;Self Attack Buff
				case Ringing Blow
				;Single Target Piercing DD
				case Bravo's Dance
				;Self Attack Speed Buff
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastDagger
					}
					break
				case Breaking Faith
				;Single Target Divine DD
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}				
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastEye
					}				
					break
				case Archaic Shackles
				;Encounter AoE Attack Speed Debuff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastHammer
					}				
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastDagger
					}				
					break			
				case Crucible of Life
				;Full Power and Health Replenishment & Healing Proc Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCoin
					}				
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastChalice
					}				
					break	

				case Verdant Trinity
				;Group Instant Heal
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastChalice
					}				
					break
				case Nature's Growth;
				;Group Regeneration
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastMask
					}			
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}				
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}				
					break
				case Capricious Strike
				;Single Target DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}			
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}				
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}				
					break
				case Shield of Ancients
				;Group Armor Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastHorn
					}				
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastMoon
					}				
					break
				case Trinity Divide
				;Encounter AoE Piercing DD
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}			
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastMask
					}				
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}				
					break
				case Soldier's Gambit
				;Single Target Magic DD
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}			
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}				
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}				
					break
				case Grand Proclamation
				;Group Increase Power Pool Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastMask
					}				
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastArm
					}				
					break			
				case Ancient's Embrace
				;Group Slashing Damage Shield Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCloak
					}				
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastArm
					}				
					break
				case Strength in Unity
				;Group STR, AGI, INT, WIS Buff (+10)
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastArm
					}			
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastChalice
					}				
					break
				case Ancient Demise
				;Encounter AoE Crushing DD
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastBoot
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCoin
					}				
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastLightning
					}				
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==3
					{
						This:CastHammer
					}			
					break
				case Tears of Luclin
				;Powerful Magic DD
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastBoot
					}			
					if ${Me.Archetype.Equal[scout]} 
					{
						This:CastDagger
					}				
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}				
					break
				case Past's Awakening
				;Massive DD & Full Group Health and Power Restoration
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFist
					}			
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastStar
					}				
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastCloak
					}				
					break			

				;*****************************************************************
				;	Mage Intiated HOs
				;*****************************************************************

				case Arcane Fury
				;Single Target Magic DD
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break			
				case Arcane Storm
				;Encounter Magic AoE DD
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}
					break
				case Arcane Enlightenment
				;Self Power Regeneration Buff
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastFlame
					}
					break
				case Arcane Chalice
				;Power Restoration
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastFlame
					}			
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}				
					break
				case Arcane Aegis
				;Power Restoration
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastFist
					}			
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}				
					break					
				case Suffocating Wrath
				;Encounter AoE Magic DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}			
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}				
					break
				case Ancient Crucible
				;Instant Health and Power Replenishment & Health and Power Regeneration
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastMoon
					}				
					break
				case Arcane Trickery
				;Single Target Magic DD & Magic and Piercing Mitigation Debuff
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastFlame
					}			
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}				
					break
				case Trickster's Grasp
				;Single Target Magic DoT
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFlame
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastDagger
					}				
					break
				case Shower of Daggers
				;Magic DD Proc Buff
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}				
					break
				case Resonating Cascade
				;Power Regeneration Buff
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastMask
					}			
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}				
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}				
					break
				case Celestial Bloom
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}			
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}	
					break
				case Luminary Fate
				;Grants power regeneration over time. 
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastDagger
					}			
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastEye
					}				
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastFlame
					}						
				;*****************************************************************
				;	Priest Intiated HOs
				;*****************************************************************			

				case Divine Judgement
				;Single Target Divine DD
				case Inspiring Piety
				;Single Target Divine DD & Self Inspirations Buff (+10)
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					break
				case Blessing of Faith
				;Self Buff That has a Chance to Replish Power When You Are Hit
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				case Piercing Faith
				;Single Target Piercing DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastMoon
					}			
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastCloak
					}				
					break
				case Divine Trickery
				;Single Target Divine DD & Divine and Piercing Mitigation Debuff
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastHammer
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCloak
					}				
					break
				case Faith's Bulwark
				;Group Armor Buff			
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastChalice
					}			
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCoin
					}				
					break
				case Fervent Quickening
				;Increases defense by 10 and periodically grants power to the player that completes the Heroic Opportunity
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastDagger
					}			
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastChalice
					}				
					break					
				case default
					echo ******UNKNOWN HO ${EQ2.HOName}*******
					break
			}
		}
	}
	;End Method HO	
	
	
	;*****************************************************************
	;	Fighter Methods
	;*****************************************************************
	
	method CastSword()
	{
		if ${Me.Ability[${FighterSword1}].IsReady}
		{
			Me.Ability[${FighterSword1}]:Use
		}
		elseif ${Me.Ability[${FighterSword2}].IsReady}
		{
			Me.Ability[${FighterSword2}]:Use
		}
	}
	method CastHorn()
	{
		if ${Me.Ability[${FighterHorn1}].IsReady}
		{
			Me.Ability[${FighterHorn1}]:Use
		}
		elseif ${Me.Ability[${FighterHorn2}].IsReady}
		{
			Me.Ability[${FighterHorn2}]:Use
		}
	}	
	method CastBoot()
	{
		if ${Me.Ability[${FighterBoot1}].IsReady}
		{
			Me.Ability[${FighterBoot1}]:Use
		}
		elseif ${Me.Ability[${FighterBoot2}].IsReady}
		{
			Me.Ability[${FighterBoot2}]:Use
		}
	}
	method CastFist()
	{
		if ${Me.Ability[${FighterFist1}].IsReady}
		{
			Me.Ability[${FighterFist1}]:Use
		}
		elseif ${Me.Ability[${FighterFist2}].IsReady}
		{
			Me.Ability[${FighterFist2}]:Use
		}
	}
	method CastArm()
	{
		if ${Me.Ability[${FighterArm1}].IsReady}
		{
			Me.Ability[${FighterArm1}]:Use
		}
		elseif ${Me.Ability[${FighterArm2}].IsReady}
		{
			Me.Ability[${FighterArm2}]:Use
		}
	}
	
	;*****************************************************************
	;	Scout Methods
	;*****************************************************************
	
	method CastCoin()
	{
		if ${Me.Ability[${ScoutCoin1}].IsReady}
		{
			Me.Ability[${ScoutCoin1}]:Use
		}
		elseif ${Me.Ability[${ScoutCoin2}].IsReady}
		{
			Me.Ability[${ScoutCoin2}]:Use
		}
	}	
	method CastDagger()
	{
		if ${Me.Ability[${ScoutDagger1}].IsReady}
		{
			Me.Ability[${ScoutDagger1}]:Use
		}
		elseif ${Me.Ability[${ScoutDagger2}].IsReady}
		{
			Me.Ability[${ScoutDagger2}]:Use
		}
	}
	method CastCloak()
	{
		if ${Me.Ability[${ScoutCloak1}].IsReady}
		{
			Me.Ability[${ScoutCloak1}]:Use
		}
		elseif ${Me.Ability[${ScoutCloak2}].IsReady}
		{
			Me.Ability[${ScoutCloak2}]:Use
		}
	}
	method CastBow()
	{
		if ${Me.Ability[${ScoutBow1}].IsReady}
		{
			Me.Ability[${ScoutBow1}]:Use
		}
		elseif ${Me.Ability[${ScoutBow2}].IsReady}
		{
			Me.Ability[${ScoutBow2}]:Use
		}
	}
	method CastMask()
	{
		if ${Me.Ability[${ScoutMask1}].IsReady}
		{
			Me.Ability[${ScoutMask1}]:Use
		}
		elseif ${Me.Ability[${ScoutMask2}].IsReady}
		{
			Me.Ability[${ScoutMask2}]:Use
		}
	}
	
	;*****************************************************************
	;	Mage Methods
	;*****************************************************************
	
	method CastStar()
	{
		if ${Me.Ability[${MageStar1}].IsReady}
		{
			Me.Ability[${MageStar1}]:Use
		}
		elseif ${Me.Ability[${MageStar2}].IsReady}
		{
			Me.Ability[${MageStar2}]:Use
		}
		
	}
	method CastLightning()
	{
		if ${Me.Ability[${MageLightning1}].IsReady}
		{
			Me.Ability[${MageLightning1}]:Use
		}
		elseif ${Me.Ability[${MageLightning2}].IsReady}
		{
			Me.Ability[${MageLightning2}]:Use
		}
	}
	method CastFlame()
	{
		if ${Me.Ability[${MageFlame1}].IsReady}
		{
			Me.Ability[${MageFlame1}]:Use
		}
		elseif ${Me.Ability[${MageFlame2}].IsReady}
		{
			Me.Ability[${MageFlame2}]:Use
		}
	}
	method CastStaff()
	{
		if ${Me.Ability[${MageStaff1}].IsReady}
		{
			Me.Ability[${MageStaff1}]:Use
		}
		elseif ${Me.Ability[${MageStaff2}].IsReady}
		{
			Me.Ability[${MageStaff2}]:Use
		}
	}
	method CastWand()
	{
		if ${Me.Ability[${MageWand1}].IsReady}
		{
			Me.Ability[${MageWand1}]:Use
		}
		elseif ${Me.Ability[${MageWand2}].IsReady}
		{
			Me.Ability[${MageWand2}]:Use
		}
	}
	
	;*****************************************************************
	;	Priest Methods
	;*****************************************************************
	
	method CastChalice()
	{
		if ${Me.Ability[${PriestChalice1}].IsReady}
		{
			Me.Ability[${PriestChalice1}]:Use
		}
		elseif ${Me.Ability[${PriestChalice2}].IsReady}
		{
			Me.Ability[${PriestChalice2}]:Use
		}
	}
	method CastHammer()
	{
		if ${Me.Ability[${PriestHammer1}].IsReady}
		{
			Me.Ability[${PriestHammer1}]:Use
		}
		elseif ${Me.Ability[${PriestHammer2}].IsReady}
		{
			Me.Ability[${PriestHammer2}]:Use
		}
	}
	method CastEye()
	{
		if ${Me.Ability[${PriestEye1}].IsReady}
		{
			Me.Ability[${PriestEye1}]:Use
		}
		elseif ${Me.Ability[${PriestEye2}].IsReady}
		{
			Me.Ability[${PriestEye2}]:Use
		}
	}
	method CastHolySymbol()
	{
		if ${Me.Ability[${PriestHolySymbol1}].IsReady}
		{
			Me.Ability[${PriestHolySymbol1}]:Use
		}
		elseif ${Me.Ability[${PriestHolySymbol2}].IsReady}
		{
			Me.Ability[${PriestHolySymbol2}]:Use
		}
	}
	method CastMoon()
	{
		if ${Me.Ability[${PriestMoon1}].IsReady}
		{
			Me.Ability[${PriestMoon1}]:Use
		}
		elseif ${Me.Ability[${PriestMoon2}].IsReady}
		{
			Me.Ability[${PriestMoon2}]:Use
		}
	}
	
	member LastManipulatorArchetype()
	{

		switch ${EQ2.HOLastManipulator.Class}
		{
			case defiler
			case mystic
			case warden
			case fury
			case inquisitor
			case templar
				return priest
				break
			case berserker
			case guardian
			case monk
			case bruiser
			case paladin
			case shadowknight
				return fighter
				break
			case conjuror
			case necromancer
			case coercer
			case illusionist
			case wizard
			case warlock
				return mage
				break
			case troubador
			case dirge
			case swashbuckler
			case brigand
			case ranger
			case assasin
				return scout
				break
			case default
				break
		}
		
	}
}