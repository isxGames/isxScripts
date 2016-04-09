/*
Check4Immunites v1.0
by:  Zandros, 22 APR 2010

Description:
Return TRUE or FALSE if target is immune to a type of ability you are about to use.
Also, scan events if you healed a mob and stop attacking with that ability

parameters:
ABILITY = Any ability (spell) you are about to use

Example Code:
call MobImmune "Union of Blood I"
if ${Return}
"mob is immune"

External Routines that must be in your program:  None
*/

/* Toggle this on or off in your scripts to overide */
variable bool doSpiritual = TRUE
variable bool doPhysical = TRUE

variable collection:string Immune2Physical
variable collection:string Immune2Spiritual

variable string TargetImmunity
variable bool doSetupImmunities = TRUE

;===================================================
;===      Known Mobs with Immunities            ====
;===================================================
function:bool Check4Immunites(string ABILITY="SKIP")
{
	variable string temp = "None"

	if ${doSetupImmunities}
	{
		;; We only want to setup once
		doSetupImmunities:Set[FALSE]
	
		;; I do not know of any mobs that are immune to Spiritual
		Immune2Spiritual:Clear
		Immune2Spiritual:Set["Ancient Gorger","Ancient Gorger"]

		;; mobs that are immune to Physical	
		Immune2Physical:Clear
		Immune2Physical:Set["Enraged Death Hound","Enraged Death Hound"]
		Immune2Physical:Set["Lesser Flarehound","Lesser Flarehound"]
		Immune2Physical:Set["Lixirikin","Lixirikin"]
		Immune2Physical:Set["Nathrix","Nathrix"]
		Immune2Physical:Set["Shonaka","Shonaka"]
		Immune2Physical:Set["Wisil","Wisil"]
		Immune2Physical:Set["Filtha","Filtha"]
		Immune2Physical:Set["Apprentice Manai","Apprentice Manai"]
		Immune2Physical:Set["SILIUSAURUS","SILIUSAURUS"]
		Immune2Physical:Set["SUMMONER RINIPIN","SUMMONER RINIPIN"]
		Immune2Physical:Set["ARCHON TRAVIX","ARCHON TRAVIX"]
		Immune2Physical:Set["Earthen Marauder","Earthen Marauder"]
		Immune2Physical:Set["Earthen Resonator","Earthen Resonator"]
		Immune2Physical:Set["Cartheon Devourer","Cartheon Devourer"]
		Immune2Physical:Set["Earth Elemental","Earth Elemental"]
		Immune2Physical:Set["Rock Elemental","Rock Elemental"]
		Immune2Physical:Set["Cartheon Soulslasher","Cartheon Soulslasher"]
		Immune2Physical:Set["Cartheon Abomination","Cartheon Abomination"]
		Immune2Physical:Set["Glowing Infineum","Glowing Infineum"]
		Immune2Physical:Set["Living Infineum","Living Infineum"]
		Immune2Physical:Set["Spawn of Infineum","Spawn of Infineum"]
		Immune2Physical:Set["Myconid Fungal Ravager","Myconid Fungal Ravager"]
		Immune2Physical:Set["Xakrin Sage","Xakrin Sage"]
		Immune2Physical:Set["Xakrin Razorclaw","Xakrin Razorclaw"]
		Immune2Physical:Set["Hound of Rahz","Hound of Rahz"]
		Immune2Physical:Set["Ancient Juggernaut","Ancient Juggernaut"]
		Immune2Physical:Set["Mechanized Pyromaniac","Mechanized Pyromaniac"]
		Immune2Physical:Set["Xakrin Razarclaw","Xakrin Razarclaw"]
		Immune2Physical:Set["Assaulting Death Hound","Assaulting Death Hound"]
		Immune2Physical:Set["Blood-crazed Ettercap","Blood-crazed Ettercap"]
		Immune2Physical:Set["Earth Elemental","Earth Elemental"]
		Immune2Physical:Set["Untrenz","Untrenz"]
		Immune2Physical:Set["Xakrin Mindripper","Xakrin Mindripper"]
		;Afrit mobs
		Immune2Physical:Set["Flarehound","Flarehound"]
		Immune2Physical:Set["Flarehound Watcher","Flarehound Watcher"]
		Immune2Physical:Set["Nefarious Titan","Nefarious Titan"]
		Immune2Physical:Set["Nefarious Elemental","Nefarious Elemental"]
		Immune2Physical:Set["Enraged Convocation","Enraged Convocation"]
	}

	;; Return FALSE if no target
	if !${Me.Target(exists)}
	{
		TargetImmunity:Set[No Target]
		return FALSE
	}

	if ${Immune2Arcane.Element["${Me.Target.Name}"](exists)} || ${Me.TargetBuff[Electric Form](exists)}
	{
		temp:Set[ARCANE]
	}
	
	if ${Immune2Physical.Element["${Me.Target.Name}"](exists)} || ${Me.TargetBuff[Earth Form](exists)}
	{
		if ${temp.Equal[None]}
		{
			temp:Set[PHYSICAL]
		}
		else
		{
			temp:Set[${temp}, PHYSICAL]
		}
	}

	if ${Immune2Spiritual.Element["${Me.Target.Name}"](exists)}
	{
		if ${temp.Equal[None]}
		{
			temp:Set[SPIRITUAL]
		}
		else
		{
			temp:Set[${temp}, SPIRITUAL]
		}
	}

	;; Update out display
	TargetImmunity:Set[${temp}]

	;; Check our passed ability
	if !${ABILITY.Equal[SKIP]}
	{
		if ${Me.Ability[${ABILITY}].School.Find[Spiritual]} || ${Me.Ability[${ABILITY}].Description.Find[Spiritual]}
		{	
			if ${TargetImmunity.Find[SPIRITUAL]} || !${doSpiritual}
			{
				return TRUE
			}
		}
		if ${Me.Ability[${ABILITY}].School.Find[Physical]} || ${Me.Ability[${ABILITY}].Description.Find[Physical]}
		{
			if ${TargetImmunity.Find[PHYSICAL]} || !${doPhysical} || ${Me.TargetBuff[Earth Form](exists)}
			{
				return TRUE
			}
		}
	}
	return FALSE
}
	

;===================================================
;===    Automatically learn a mob resistance    ====
;===================================================
atom VG_OnIncomingCombatText(string aText, int aType)
{

	if ${Me.Target.Name.Find[Unstable]}
		return


	if ${aText.Find[immune]}
		echo (${aType}) -- ${aText}


	if ${aType} == 28 && ${aText.Find[${Me.Target.Name}]} && (${aText.Find[heals]} || ${aText.Find[immune]})
	{
		;; We want to update our immunity display
		doCheckImmunities:Set[TRUE]

		;; Add target and type to Learned Immunities list
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Arcane]} || ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].Description.Find[Arcane]}
		{
			LearnedImmunitiesList:Set["${Me.Target.Name}", "Arcane"]
			call PlaySound ALARM
			echo ${Me.Target.Name} is immune/healed to ${aText.Token[2,">"].Token[1,"<"]} (Arcane)
			vgecho ${aText.Token[2,">"].Token[1,"<"]} (Arcane)
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Physical]} || ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].Description.Find[Physical]}
		{
			LearnedImmunitiesList:Set["${Me.Target.Name}", "Physical"]
			call PlaySound ALARM
			echo ${Me.Target.Name} is immune/healed to ${aText.Token[2,">"].Token[1,"<"]} (Physical)
			vgecho ${aText.Token[2,">"].Token[1,"<"]} (Physical)
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Spiritual]} || ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].Description.Find[Spiritual]}
		{
			LearnedImmunitiesList:Set["${Me.Target.Name}", "Spiritual"]
			call PlaySound ALARM
			echo ${Me.Target.Name} is immune/healed to ${aText.Token[2,">"].Token[1,"<"]} (Spiritual)
			vgecho ${aText.Token[2,">"].Token[1,"<"]} (Spiritual)
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Fire]} || ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].Description.Find[Fire]}
		{
			LearnedImmunitiesList:Set["${Me.Target.Name}", "Fire"]
			call PlaySound ALARM
			echo ${Me.Target.Name} is immune/healed to ${aText.Token[2,">"].Token[1,"<"]} (Fire)
			vgecho ${aText.Token[2,">"].Token[1,"<"]} (Fire)
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Ice]} || ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].Description.Find[Ice]}
		{
			LearnedImmunitiesList:Set["${Me.Target.Name}", "Ice"]
			call PlaySound ALARM
			echo ${Me.Target.Name} is immune/healed to ${aText.Token[2,">"].Token[1,"<"]} (Ice)
			vgecho ${aText.Token[2,">"].Token[1,"<"]} (Ice)
		}
		if ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].School.Find[Cold]} || ${Me.Ability[${aText.Token[2,">"].Token[1,"<"]}].Description.Find[Cold]}
		{
			LearnedImmunitiesList:Set["${Me.Target.Name}", "Cold"]
			call PlaySound ALARM
			echo ${Me.Target.Name} is immune/healed to ${aText.Token[2,">"].Token[1,"<"]} (Cold)
			vgecho ${aText.Token[2,">"].Token[1,"<"]} (Cold)
		}
	}
}

