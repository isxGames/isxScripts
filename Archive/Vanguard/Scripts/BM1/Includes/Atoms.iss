#define ALARM "${Script.CurrentDirectory}/ping.wav"


;===================================================
;===      ATOM - Continuously Check             ====
;===================================================
atom(script) OnFrame()
{
	;-------------------------------------------
	;; define our variables
	;-------------------------------------------
	variable int j
	variable int k
	variable int l
	variable string temp
	variable bool test


	;-------------------------------------------
	;; Shadow Rain is casted every 61 seconds so let's echo it
	;-------------------------------------------
	if ${doEchoShadowRain} && (${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextShadowRain}]}/1000]}>=51)
	{
		if ${Pawn[ExactName,LORD TALFYN](exists)}
		{
			vgecho "---SHADOW RAIN---"
			NextShadowRain:Set[${Math.Calc[${Script.RunningTime}-10000]}]
			VGExecute "/raid <Purple=>=== SHADOW RAIN IN 10 SECONDS ==="
		}
		else
		{
			EchoIt "Talfyn does not exist"
			doEchoShadowRain:Set[FALSE]
		}
	}

	;-------------------------------------------
	;; Update the UI
	;-------------------------------------------
	temp:Set[None]
	if !${doArcane}
	{
		temp:Set[Arcane]
	}
	if !${doPhysical}
	{
		temp:Set[Physical]
	}
	if !${doArcane} && !${doPhysical}
	{
		temp:Set[Arcane / Physical]
	}

	;; Main
	UIElement[Text-Status@BM1]:SetText[ Current Action:  ${PerformAction}]
	UIElement[Text-Immune@BM1]:SetText[ Target's Immunity:  ${temp}]
	if ${Me.Target(exists)}
	{
		UIElement[Text-TOT@BM1]:SetText[ Target's Target:  ${Me.ToT.Name}]
	}
	else
	{
		UIElement[Text-TOT@BM1]:SetText[ Target's Target:  None]
	}

	;; DPS
	DisplayDPS
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
;===================================================
atom(script) SetHighestAbility(string AbilityVariable, string AbilityName)
{
	declare L int local 8
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[8] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]
	AbilityLevels[9]:Set[IX]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	global "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Find highest Ability level - based upon current level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${Me.Level}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	global "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt " --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	global "None"
	return
}



;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][BM1]: ${aText}"
	}
}

;===================================================
;===       ATOM - PawnSpawned                   ====
;===================================================
atom(script) PawnSpawned(string aID, string aName, string aLevel, string aType)
{
	switch "${aName}"
	{

	case Sacrificial Beast
		if !${Me.InCombat}
		{
			SacrificialBeastSpawned:Set[TRUE]
		}
		break

	case Electric Spark
		Pawn[ExactName,Electric Spark]:Target
		break

	case Ulvari Warrior
		Pawn[ExactName,Ulvari Warrior]:Target
		break

	Default
		break
	}
}


;===================================================
;===           ATOM - DISPLAY DPS               ====
;===================================================
atom(script) DisplayDPS()
{
	;-------------------------------------------
	; Display DPS - Display our DPS and reset it
	;-------------------------------------------
	if ${ResetParse} && !${Me.InCombat} && ${Me.Encounter}==0
	{
		;; we do not want to reset if our target still has health remaining - we must have wiped aggro
		if ${Me.Target(exists)} && ${Me.TargetHealth}>0
		{
			return
		}

		EchoIt "DPS=${DPS}, Total Damage=${DamageDone}"
		vgecho "DPS=${DPS}, Total Damage=${DamageDone}"
		ResetParse:Set[FALSE]
		DPS:Set[0]
		DamageDone:Set[0]
	}
}


;===================================================
;===    ATOM - Parser to calculate DPS          ====
;===================================================
atom(script) CalculateDPS(string aText)
{
	;; Set start timer
	if !${ResetParse}
	{
		ResetParse:Set[TRUE]
		StartAttackTime:Set[${Script.RunningTime}]
	}

	;; Calculate and update DPS
	EndAttackTime:Set[${Script.RunningTime}]
	TimeFought:Set[${Math.Calc[${EndAttackTime}-${StartAttackTime}]}]
	if ${TimeFought}>999
	{
		DPS:Set[${Math.Calc[${DamageDone}/${Math.Calc[${TimeFought}/1000]}].Round}]
	}
	else
	{
		DPS:Set[${DamageDone}]
	}
	;EchoIt "DPS=${DPS}, Damage Done=${ParseDamage}, Total Damage=${DamageDone}"
}

;===================================================
;===    ATOM - Monitor Combat Text Messages     ====
;===================================================
atom CombatText(string aText, int aType)
{
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Combat-All.txt" echo "[${Time}][${aType}][(${Me.TargetHealth})${Me.Target.Name}][${aText}]"
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Combat-${aType}.txt" echo "[${Time}][${aType}][(${Me.TargetHealth})${Me.Target.Name}][${aText}]"

	;if ${aText.Find[hits]} && ${aText.Find[Hypno]}
	;{
	;	redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Hypno-Hit.txt" echo "[${Time}][${aType}][(${Me.TargetHealth})${Me.Target.Name}][${aText}]"
	;}
	;if ${aText.Find[misses]} && ${aText.Find[Hypno]}
	;{
	;	redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Hypno-Hit.txt" echo "[${Time}][${aType}][(${Me.TargetHealth})${Me.Target.Name}][${aText}]"
	;}


	;; 81=target attacks group member
	if ${aType}==81
	{
		;; SUMMONER YERK
		if ${aText.Find[Ice Compression]} && ${aText.Find[YERK]}
		{
			variable string bText = "${aText}"
			bText:Set[${bText.Right[${Math.Calc[${bText.Length}-56]}]}]
			bText:Set[${bText.Left[${Math.Calc[${bText.Length}-1]}]}]
			Pawn[name,${bText}]:Target
			vgecho "<Blue=>${bText} is FROZEN!"
		}
		;; Arch Magus Zodifin
		;if ${aText.Find[Planar Curse: Zodiac]}
		;{
		;	variable string yText = "${aText}"
		;	;yText:Set[Nexus Portal's <highlight>Planar Curse: Zodiac</color> deals <highlight>1863</color> planar damage to Thundercloud.]
		;	yText:Set[${yText.Mid[${yText.Find[</color> planar damage to]},${yText.Length}].Token[2,>].Token[1,.]}]
		;	yText:Set[${yText.Right[${Math.Calc[${yText.Length}-17]}]}]
		;	vgecho "<Blue=>[${yText}]"
		;}
	}

	;; 30=target attacks me
	if ${aType}==30
	{
		;; SUMMONER YERK hits me
		if ${aText.Find[Ice Compression]} && ${aText.Find[YERK]}
		{
			Pawn[Me]:Target
			VGExecute "/raid <Purple=>${Me.FName} is FROZEN"
		}
	}

	;-------------------------------------------
	; DAMAGE DONE - Used to total how much damage we did
	;-------------------------------------------
	if ${aType}==26
	{
		if !${aText.Find[damage to You]} && !${aText.Find[healing for]}
		{
			;; if any damage is done then we want to make sure we reset any immunities
			;; when the target is no longer the same target
			call ResetImmunities

			;if ${aText.Find[additional <]}
			;{
			;	;; Update our total damage - Critical and Epic
			;	ParseDamage:Set[${aText.Mid[${aText.Find[additional <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			;	DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			;	CalculateDPS "${aText}"
			;	return
			;}
			if ${aText.Find[for <]}
			{
				;; Update our total damage - Nukes and Melee
				ParseDamage:Set[${aText.Mid[${aText.Find[for <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
				DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
				CalculateDPS "${aText}"
				return
			}
			if ${aText.Find[deals <]}
			{
				;; Update our total damage - DOTS
				ParseDamage:Set[${aText.Mid[${aText.Find[deals <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
				DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
				CalculateDPS "${aText}"
				return
			}
			if ${aText.Find[draw <]}
			{
				;; Update our total damage
				ParseDamage:Set[${aText.Mid[${aText.Find[draw <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
				DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
				CalculateDPS "${aText}"
				return
			}
			if ${aText.Find[damage shield]}
			{
				;; Update our total damage
				ParseDamage:Set[${aText.Mid[${aText.Find[for]},${aText.Length}].Token[2,r].Token[1,d]}]
				DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
				CalculateDPS "${aText}"
				return
			}
		}
	}

	;-------------------------------------------
	; IMMUNITIES - toggle abilities on/off if we heal the target
	;-------------------------------------------
	if ( ${aType}==26 || ${aType}==28 ) && ${aText.Find[absorbs your]} && ${aText.Find[healing for]}
	{
		variable string ImmunityType = "UNKNOWN"

		;; Arcane - Crit
		if ${aText.Find[Entwining]}
		{
			ImmunityType:Set[ARCANE]
			doArcane:Set[FALSE]
		}
		;; Arcane - Lifetap
		elseif ${aText.Find[Despoil]}
		{
			ImmunityType:Set[ARCANE]
			doArcane:Set[FALSE]
		}
		;; Arcane - Lifetap
		elseif ${aText.Find[Bloodthinner]}
		{
			ImmunityType:Set[ARCANE]
			doArcane:Set[FALSE]
		}
		;; Arcane - Heal Crit
		elseif ${aText.Find[Tribute]}
		{
			ImmunityType:Set[ARCANE]
			doArcane:Set[FALSE]
		}
		;; Physical - Crit
		elseif ${aText.Find[Blood Spray]}
		{
			ImmunityType:Set[PHYSICAL]
			doPhysical:Set[FALSE]
		}
		;; Physical - Crit
		elseif ${aText.Find[Exsanguinate]}
		{
			ImmunityType:Set[PHYSICAL]
			doPhysical:Set[FALSE]
		}
		;; Physical - Dot
		elseif ${aText.Find[Exploding]}
		{
			ImmunityType:Set[PHYSICAL]
			doPhysical:Set[FALSE]
		}
		;; Physical - Dot
		elseif ${aText.Find[Union]}
		{
			ImmunityType:Set[PHYSICAL]
			doPhysical:Set[FALSE]
		}
		;; Physical - Dot
		elseif ${aText.Find[Letting]}
		{
			ImmunityType:Set[PHYSICAL]
			doPhysical:Set[FALSE]
		}

		;; Create the Save directory incase it doesn't exist
		variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/Parse"
		mkdir "${savePath}"

		;; dump to file
		redirect -append "${savePath}/LearnedImmunities.txt" echo "[${Time}][${aType}][${Me.Target.Name}][${ImmunityType}][${aText.Token[2,">"].Token[1,"<"]}] -- [${aText}]"

		;; display the info
		echo ${Me.Target.Name} absorbed/healed/immune to ${aText.Token[2,">"].Token[1,"<"]}
		vgecho "Immune: ${ImmunityType} - ${aText.Token[2,">"].Token[1,"<"]} - ${Me.Target.Name}"
	}

	;-------------------------------------------
	; LORD TALFYN'S - Shadow Rain
	;-------------------------------------------
	if ${aType}==82 && ${aText.Find[Shadow Rain]}
	{
		;; constantly update the timer whenever Shadow Rain is casted
		NextShadowRain:Set[${Script.RunningTime}]
		doEchoShadowRain:Set[TRUE]
	}
}

variable string PCName
variable string PCNameFull
variable string Symbiote
variable bool BuffRequest = FALSE

;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	;echo "[${ChannelNumber}] ${aText}"
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Chat-All.txt" echo "[${Time}][${ChannelNumber}][${aText}]"
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/Parse/Chat-${ChannelNumber}.txt" echo "[${Time}][${ChannelNumber}][(${Me.TargetHealth})${Me.Target.Name}][${aText}]"

	if ${ChannelNumber}==0 && ${aText.Find[You can't attack with that type of weapon.]}
	{
		EchoIt "[${ChannelNumber}a]${aText}"
		doMeleeAttacks:Set[FALSE]
		UIElement[doMeleeAttacks@Main@Tabs@BM1]:UnsetChecked
		vgecho "Melee Off - can't attack with that weapon"
	}


	if ${aText.Find[You have received a raid ready check.]}
	{
		EchoIt "[${ChannelNumber}] ${aText}"
		PlaySound ALARM
	}
	
	if !${Me.InCombat}
	{
		if ${ChannelNumber}==8 || ${ChannelNumber}==9 || ${ChannelNumber}==11 || ${ChannelNumber}==15 || ${ChannelNumber}==17
		{
			if ${aText.Find[buff]}
			{
				PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
				PCName:Set[${PCNameFull.Token[1," "]}]
				BuffRequestList:Set["${PCName}", "Buff"]
				BuffRequest:Set[TRUE]
				;vgecho [${ChannelNumber}] ${aText}
				;vgecho PCName=${PCName}, PCNameFull=${PCNameFull}
			}

			;; 11 = guild
			if (${ChannelNumber}==11 || ${ChannelNumber}==15) && (${aText.Find[named]} || ${aText.Find[name run]})
			{
				EchoIt "[${ChannelNumber}a]${aText}"
				PlaySound ALARM
			}

			;; 15 = tells, Ping us on tells or anything with our name in it
			if ${ChannelNumber}==15 && ${aText.Find[From ]}
			{
				EchoIt "[${ChannelNumber}b]${aText}"
				PlaySound ALARM
			}
		}
	}

	;; display successful counters
	if ${ChannelNumber}==26
	{
		if ${aText.Find[and it is dispersed!]}
		{
			variable string bText = "${aText}"
			bText:Set[${aText.Mid[${aText.Find['s ]},${aText.Length}]}]
			bText:Set[${bText.Left[${Math.Calc[${bText.Length}-21]}]}]
			bText:Set[${bText.Right[${Math.Calc[${bText.Length}-3]}]}]
			vgecho "<Purple=>COUNTERED: <Yellow=>${bText}"
		}
	}

	;; Echo when target is FURIOUS
	if ${ChannelNumber}==7
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			if ${aText.Find[becomes FURIOUS]}
			{
				vgecho "FURIOUS - STOP ATTACKING"
				isFurious:Set[TRUE]
			}
			if ${aText.Find[is no longer FURIOUS]}
			{
				vgecho "FURIOUS - RESUME ATTACKING"
				isFurious:Set[FALSE]
			}
		}
	}

	;; Accept Rez
	if ${ChannelNumber}==32
	{
		if ${aText.Find[is trying to resurrect you with]}
		{
			doAcceptRez:Set[TRUE]
		}
	}

	;; Check for any Symbiote Requests
	if ${ChannelNumber}==8 || ${ChannelNumber}==11 || ${ChannelNumber}==15 || ${ChannelNumber}==17
	{
		if ${aText.Find["conduc"]}
		{
			PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[${ConduciveSymbiote}]
			SymbioteRequestList:Set["${PCName}", "${Symbiote}"]
			doSymbioteRequest:Set[TRUE]
		}

		if ${aText.Find["frenz"]} || ${aText.Find["fenz"]}
		{
			PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[${FrenziedSymbiote}]
			SymbioteRequestList:Set["${PCName}", "${Symbiote}"]
			doSymbioteRequest:Set[TRUE]
		}

		if ${aText.Find["QJ"]}
		{
			PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[${QuickeningSymbiote}]
			SymbioteRequestList:Set["${PCName}", "${Symbiote}"]
			doSymbioteRequest:Set[TRUE]
		}

		if ${aText.Find["vitalizing"]} || ${aText.Find["VS"]} || ${aText.Find["VIT"]}
		{
			if !${aText.Find["invit"]}
			{
				PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
				PCName:Set[${PCNameFull.Token[1," "]}]
				Symbiote:Set[${VitalizingSymbiote}]
				SymbioteRequestList:Set["${PCName}", "${Symbiote}"]
				doSymbioteRequest:Set[TRUE]
			}
		}
		
		if ${aText.Find["plated"]}
		{
			PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[${PlatedSymbiote}]
			SymbioteRequestList:Set["${PCName}", "${Symbiote}"]
			doSymbioteRequest:Set[TRUE]
		}

		if ${aText.Find["renew"]}
		{
			PCNameFull:Set[${aText.Token[2,">"].Token[1,"<"]}]
			PCName:Set[${PCNameFull.Token[1," "]}]
			Symbiote:Set[${RenewingSymbiote}]
			SymbioteRequestList:Set["${PCName}", "${Symbiote}"]
			doSymbioteRequest:Set[TRUE]
		}
	}
}

;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}
variable string PerformAction = Default
variable string LastAction = Default

;-------------------------------------------
; This happens when we bump into an obstacle
;-------------------------------------------
atom Bump(string Object)
{
	if (${Object.Find[Mover]})
	{
		VG:ExecBinding[UseDoorEtc]
	}
}