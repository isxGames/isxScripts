#define ALARM "${Script.CurrentDirectory}/Sounds/ping.wav"

;===================================================
;===    ATOM - Always Check Routines            ====
;===================================================
atom(script) SHA_AlwaysCheck()
{
	;;;;;;;;;;
	;; Update the display that shows the Target's Target
	if ${Me.Target(exists)}
	{
		temp:Set[${Me.ToT.Name}]
		if ${temp.Equal[NULL]}
			TargetsTarget:Set[No Target]
		else
			TargetsTarget:Set[${Me.ToT.Name}]
	}

	if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextAction}]}/1000]} > .3
	{
		if ${Me.XP}>${lastXP}
		{
			;TotalKills:Set[${TotalKills}+1]
			;lastXP:Set[${Me.XP}]
			;timeCheck:Set[${Math.Calc[${Script.RunningTime}/1000/60/60]}]
			;tempXPHour:Set[${Math.Calc[(${Me.XP} - ${startXP}) / ${timeCheck}]}]
			;TotalKillsHour:Set[${Math.Calc[${TotalKills} / ${timeCheck}]}]
			;echo [${Time}] "TotalKills=${TotalKills}, XP/Hour=${tempXPHour}, TotalXP=${Math.Calc[${Me.XP} - ${startXP}]}"
		}

		if ${doLoot} && ${Me.IsLooting}
		{
			Loot:LootAll
			NextAction:Set[${Script.RunningTime}]
			return
		}
		
		if !${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead} || ${Me.Target.Distance}>=5
		{
			;; Turn off auto-attack if target is not a resource
			if !${Me.Target.Type.Equal[Resource]} && ${Me.Ability[Auto Attack].Toggled}
			{
				;EchoIt "Turning off Melee Attacks"
				;Me.Ability[Auto Attack]:Use
				;NextAction:Set[${Math.Calc[${Script.RunningTime}+2000]}]
				;return
			}
		}

		if !${Me.Target(exists)}
		{
			if ${doLoot} && ${Pawn[Corpse,range,5](exists)} && ${Pawn[Corpse,range,5].ContainsLoot}
			{
				Pawn[Corpse,range,5]:Target
				NextAction:Set[${Script.RunningTime}]
				return
			}
			
			if ${Pawn[Tombstone,range,20](exists)}
			{
				VGExecute "/targetmynearestcorpse"
				NextAction:Set[${Script.RunningTime}]
				return
			}
		}

		if ${Me.Target(exists)}
		{
			if ${Check.AreWeReady}
			{
				if ${doMelee} && ${Me.Ability[${ThroatRip}].IsReady} && ${Me.Ability[${ThroatRip}].TriggeredCountdown}>0 && ${Me.Ability[${ThroatRip}].EnduranceCost}<${Me.Endurance}
				{
					EchoIt "[${Time}] Crit: ${ThroatRip}"
					;Me.Form[${MeleeForm}]:ChangeTo
					Me.Ability[${ThroatRip}]:Use
					NextAction:Set[${Script.RunningTime}]
					return
				}
				if ${doMelee} && ${Me.Ability[${SpearoftheAncestors}].IsReady} && ${Me.Ability[${SpearoftheAncestors}].TriggeredCountdown}>0 && ${Me.Ability[${SpearoftheAncestors}].EnduranceCost}<${Me.Endurance} && ${Me.Endurance}<50
				{
					EchoIt "[${Time}] Crit: ${SpearoftheAncestors}"
					Me.Form[${MeleeForm}]:ChangeTo
					Me.Ability[${SpearoftheAncestors}]:Use
					NextAction:Set[${Script.RunningTime}]
				}
				if ${doMelee} && ${Me.Ability[${FistoftheEarth}].IsReady} && ${Me.Ability[${FistoftheEarth}].TriggeredCountdown}>0 && ${Me.Ability[${FistoftheEarth}].EnduranceCost}<${Me.Endurance}
				{
					EchoIt "[${Time}] Crit: ${FistoftheEarth}"
					;Me.Form[${MeleeForm}]:ChangeTo
					Me.Ability[${FistoftheEarth}]:Use
					NextAction:Set[${Script.RunningTime}]
				}
				if ${doCold} && ${Me.Ability[${GelidBlast}].IsReady} && ${Me.Ability[${GelidBlast}].TriggeredCountdown}>0 && ${Me.Ability[${GelidBlast}].EnergyCost}<${Me.Energy}
				{
					EchoIt "[${Time}] Crit: ${GelidBlast}"
					;Me.Form[${SpellForm}]:ChangeTo
					Me.Ability[${GelidBlast}]:Use
					NextAction:Set[${Script.RunningTime}]
				}
				if ${doSpiritual} && ${Me.Ability[${UmbraBurst}].IsReady} && ${Me.Ability[${UmbraBurst}].TriggeredCountdown}>0 && ${Me.Ability[${UmbraBurst}].EnergyCost}<${Me.Energy}
				{
					EchoIt "[${Time}] Crit: ${UmbraBurst}"
					;Me.Form[${SpellForm}]:ChangeTo
					Me.Ability[${UmbraBurst}]:Use
					NextAction:Set[${Script.RunningTime}]
				}
			}

			if ${Me.Target.Name.Find[Tombstone]} && ${Me.Target.Name.Find[${Me}]}
			{
				VGExecute "/corpsedrag"
				VGExecute "/lootall"
				NextAction:Set[${Script.RunningTime}]
				return
			}
		
			if ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead}
			{
				if ${doLoot}
				{
					if ${Me.Target.ContainsLoot}
					{
						if ${Me.Target.Distance}<5
							VGExecute "/lootall"
						NextAction:Set[${Script.RunningTime}]
						return
					}
					VGExecute /cleartargets
				}
				NextAction:Set[${Script.RunningTime}]
				return
			}
		}
		
		variable string temp = ${Journal[Quest].CurrentDisplayed}
		if ${temp.Find["Willful Enemies of the Var"]}
		{
			Journal[Quest].CurrentDisplayed:Accept
			NextAction:Set[${Math.Calc[${Script.RunningTime}+2000]}]
			return
		}
	}
}


;===================================================
;===  ATOM - Monitor Status Alerts              ====
;===================================================
atom(script) SHA_AlertEvent(string Text, int ChannelNumber)
{
	EchoIt "[AlertChannel=${ChannelNumber}] ${Text}"
	if ${ChannelNumber}==22
	{
		if ${Text.Find[Can't be used in combat.]}
		{
			if !${Me.Target(exists)}
				VGExecute "/cleartargets"
		}
		
		;if ${Text.Find[No Target]}
		;	Me.Ability[Auto Attack]:Use
		
		if ${Text.Find[Can't see target]}
			NoLineOfSight:Set[TRUE]
	
		if ${Text.Find[Invalid target]}
			VGExecute "/cleartargets"
	}
}


;===================================================
;===  ATOM - Monitor Chat & Combat Messages     ====
;===================================================
atom(script) SHA_ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	;EchoIt "[${ChannelNumber}] ${aText}"

	;; Sound the alert if we received a Ready Check
	if ${aText.Find[You have received a raid ready check.]}
	{
		EchoIt [${ChannelNumber}] ${aText}
		PlaySound ALARM
	}
	
	;; Unable to harvest so stop melle attacks and clear our target
	if ${aText.Find["You do not have enough skill to begin harvesting this resource"]}
	{
		EchoIt [${ChannelNumber}] ${aText}
		VGExecute /cleartargets
	}

	;; jump to appropriate chat channel
	switch "${ChannelNumber}"
	{
		case 0
			if ${aText.Equal[Your target is dead.]}
				VGExecute "/cleartargets"
			if ${aText.Find[Your target is not valid to attack.]}
				Me.Ability[Auto Attack]:Use
			;if ${aText.Find[You don't have a target.]}
			;	Me.Ability[Auto Attack]:Use
			if ${aText.Find[You can't attack with that type of weapon.]}
				Me.Ability[Auto Attack]:Use
			if ${aText.Find["no line of sight to your target"]} || ${aText.Find[You can't see your target]}
				NoLineOfSight:Set[TRUE]
			if ${aText.Find["You are not wielding the proper weapon type to use that ability"]}
			{
				doRangedAttack:Set[FALSE]
				UIElement[doRangedAttack@Main@Tabs@VG-Shaman]:UnsetChecked
			}
			break
			
		case 7
			if ${aText.Find[becomes FURIOUS]} && ${aText.Find[${Me.Target.Name}]}
			{
				if ${GV[bool,bIsAutoAttacking]}
					Me.Ability[Auto Attack]:Use
			}
			break

		case 26
			;; this may be different for each class
			if ${aText.Find[and it is dispersed!]}
			{
				variable string bText
				bText:Set[${aText.Mid[${aText.Find['s ]},${aText.Length}]}]
				bText:Set[${bText.Left[${Math.Calc[${bText.Length}-21]}]}]
				bText:Set[${bText.Right[${Math.Calc[${bText.Length}-3]}]}]
				vgecho "<Purple=>COUNTERED: <Yellow=>${bText}"
			}
			break
			
		case 27
			if ${aText.Find[Slow effect!]}
				doLethargy:Set[FALSE]
			break

		case 28
			if ${aText.Find[You sit]}
				doAreWeSitting:Set[TRUE]
			break

		case 32
			if ${aText.Find[is trying to resurrect you with]}
				VGExecute "/rezaccept"
			break

		case 42
			if ${aText.Find[No one but you seems to think you're dead.]}
				VGExecute "/Stand"
			if ${aText.Find[You cannot use that item like that.]}
			{
				doUseWeapon:Set[FALSE]
				UIElement[doUseWeapon@Main@Tabs@VG-Shaman]:UnsetChecked
			}
			break
			
		Default
			break
	}
}

;===================================================
;===       ATOM - PawnSpawned                   ====
;===================================================
atom(script) SHA_PawnSpawned(string aID, string aName, string aLevel, string aType)
{
	if (${aType.Equal[NPC]} || !${aType(exists)}) && ${aLevel}==1
	{
		if ${aName.Length}==1
		{
			Pawn[NPC,exactname,"${aName}"]:Target
			EchoIt "[${aID}], lvl=[${aLevel}], type=[${aType}], name=[${aName}], target=[${Me.Target.Name}], distance=${Me.Target.Distance}"
			PlaySound ALARM
		}
	}
}
