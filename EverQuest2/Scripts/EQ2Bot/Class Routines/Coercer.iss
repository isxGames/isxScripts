;*************************************************************
;by Pygar
;Removed much of the retardedness the script gained lately.  
;Added Manaflow for raid targets
;Added missing AA abilities
;Fixed ManaWard
;General DPS enhancements
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20110727

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare MezzMode bool script FALSE
	declare Charm bool script FALSE
	declare BuffInstigation bool script FALSE
	declare Breeze bool script FALSE	
	declare BuffSignet bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffCoerciveHealing bool script FALSE
	declare ManaFlow bool script FALSE	
	declare BuffHateGroupMember string script
	declare BuffCoerciveHealingGroupMember string script
	declare BuffManaward bool script
	declare DPSMode bool script 1
	declare NullifyStaff bool script 1
	declare TSMode bool script 1
	declare StartHO bool script 1
	declare Mythical bool script FALSE
	declare DestructiveMind bool script FALSE	
	declare PuppetMaster bool script FALSE	

	;Initialized by UI
	declare BuffDMindTimers collection:int script
	declare BuffDMindIterator iterator script
	declare BuffDMindMember int script 1
	
	declare CharmTarget int script

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffHateGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHateGroupMember,]}]
	BuffHate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHate,FALSE]}]
	BuffInstigation:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffInstigation,,FALSE]}]
	BuffSignet:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSignet,FALSE]}]
	Breeze:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Breeze,FALSE]}]	
	BuffCoerciveHealing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffCoerciveHealing,FALSE]}]
	BuffCoerciveHealingGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffCoerciveHealingGroupMember,]}]
	BuffManaward:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffManaward,FALSE]}]
	DPSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[DPSMode,FALSE]}]
	NullifyStaff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[NullifyStaff,FALSE]}]
	ManaFlow:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ManaFlow,FALSE]}]		
	TSMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseTS,FALSE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	Charm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Charm,FALSE]}]
	Mythical:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mythical,FALSE]}]	
	DestructiveMind:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[DestructiveMind,FALSE]}]
	PuppetMaster:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PuppetMaster,FALSE]}]		
		
	BuffJesterCap:GetIterator[BuffJesterCapIterator]
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		call CheckHeals
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	if ${MezzMode} && (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer2}+2000]})
	{
		CurrentAction:Set[Out of Combat Checking Mezzes]
		call Mezmerise_Targets
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer2:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Instigation]
	PreSpellRange[2,1]:Set[20]

	PreAction[3]:Set[Hate]
	PreSpellRange[3,1]:Set[40]

	PreAction[4]:Set[AntiHate]
	PreSpellRange[4,1]:Set[41]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[35]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[Signet]
	PreSpellRange[7,1]:Set[21]

	PreAction[8]:Set[Clarity]
	PreSpellRange[8,1]:Set[22]

	PreAction[9]:Set[AAEmpathic_Aura]
	PreSpellRange[9,1]:Set[384]

	PreAction[10]:Set[AACoerciveHealing]
	PreSpellRange[10,1]:Set[379]
}

function Combat_Init()
{

}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

if !${InitialBuffsDone}
{
	echo Starting eq2bot and starting one time initilization

	if !${Me.Maintained[${SpellType[42]}](exists)}
		call CastSpellRange 42

	InitialBuffsDone:Set[TRUE]		
}

	;;;; Cast Myth on MT
	if ${Mythical} && !${Me.Maintained[Siren's Stare](exists)}
	{
		Actor[pc,ExactName,${MainTankPC}]:DoTarget
		wait 12 ${Target.ID}==${Actor[pc,ExactName,${MainTankPC}].ID}
		Me.Equipment[ExactName,Eye of the Siren]:Use
		wait 12	
	}

	;;;; Pre-Buff Destructive Mind
	if ${DestructiveMind} && ${Me.Ability[${SpellType[72]}].IsReady}
	{
		call DoDMind
	}

	CurrentAction:Set[Buffing ${xAction}]

	call CheckHeals

	switch ${PreAction[${xAction}]}
	{

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case AAEmpathic_Aura
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break		
		case Clarity
			if ${Breeze}
			;if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 20
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel			
			break
		case Signet
			if ${BuffSignet}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Instigation
			if ${BuffInstigation}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Hate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${BuffHate} && ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AACoerciveHealing
			BuffTarget:Set[${UIElement[cbBuffHealGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${BuffCoerciveHealing} && ${Actor[${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AntiHate
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}
			}
			while ${Counter:Inc}<=${Me.CountMaintained}


			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if ${Me.UsedConc}<5
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffAntiHate@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case Melee_Buff
			Counter:Set[1]
			tempvar:Set[1]
			
			;if we have the improved velocity buff we need only buff ourselves
			if ${Me.Ability[Increased Velocity](exists)} && ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0 && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} 
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
				break
			}
			elseif ${Me.Ability[Increased Velocity](exists)}
			{
				break
			}
			
			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}
			}
			while ${Counter:Inc}<=${Me.CountMaintained}

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if ${Me.UsedConc}<5
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case SeeInvis
			if ${BuffSeeInvis}
			{
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
					

				;;;Removing for now (...do we really want to mess with buffing the group with SeeInvis?)
				;if (${Me.GroupCount} > 1)
				;{
				;	tempvar:Set[1]
				;	do
				;	{
				;		if ${Me.Group[${tempvar}].Distance}<15
				;			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ID}
				;	}
				;	while ${tempvar:Inc}<${Me.GroupCount}
				;}
			}
			break
		default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[3]

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}
	
	if ${MezzMode}
	{
		CurrentAction:Set[Combat Checking Mezzes]
		spellthreshold:Set[1]
		call Mezmerise_Targets
	}

	if ${Charm}
	{
		CurrentAction:Set[Combat Checking Charms]
		spellthreshold:Set[1]
		call DoCharm
	}

	if ${TSMode}
	{
		CurrentAction:Set[Combat Checking ThoughtSnap]
		call DoAmnesia
	}
	
	if ${Me.Pet(exists)} && !${Me.Pet.InCombatMode}
		call PetAttack

	if !${Me.Pet(exists)} && ${Me.Ability[${SpellType[392]}].IsReady}
	{
		call CastSpellRange 392 0 0 0 ${KillTarget}	
		spellsused:Inc
		return 1
	}	

	;;;; Buff Destructive Mind
	if ${Me.Ability[${SpellType[72]}].IsReady} && ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[72]}](exists)}
	{
		call DoDMind
		spellsused:Inc
	}

	;;;; Make sure Mind's Eye is buffed, note: this is a 10 min buff.
	if !${Me.Maintained[${SpellType[42]}](exists)} && ${Me.Ability[${SpellType[42]}].IsReady}
	{
		call CastSpellRange 42	
		spellsused:Inc
	}
	
	;;;; Check the tank and see if he needs agro from multiple mob pull
	;;;; Coercive Shout
	if ${Me.Ability[${SpellType[509]}].IsReady} && ${Actor[${KillTarget}].Target}!=${Actor[${MainTankID}].ID} && ${Actor[${MainTankID}].Target}==${Actor[${KillTarget}].ID}
	{
		call CastSpellRange 509 0 0 0 ${MainTank}	
		spellsused:Inc
	}

	if ${ManaFlow}
	{		
		CurrentAction:Set[Combat Checking Power]
		call RefreshPower
	}	

	call CheckHeals
	call CommonHeals 70
		
	if ${DoHOs} && ${Mob.CheckActor[${KillTarget}]} && ${spellsused}<=${spellthreshold} 
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO} && ${Mob.CheckActor[${KillTarget}]}
		call CastSpellRange 303

	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1
		
	;;;; BEGIN Spell Casting Routine
	;;;; First check if there are multiple mobs on the pull and let's stun them so we can mez them if needed
	;;;;Stupefy
	if ${spellsused}<=${spellthreshold} && ${MezzMode} && ${Mob.Count}>1 && ${Me.Ability[${SpellType[191]}].IsReady} && !${Me.Maintained[${SpellType[191]}](exists)}
	{
		call CastSpellRange 191 0 0 0 ${KillTarget}
		spellsused:Inc
	}	
	;;;; Tashani
	if ${spellsused}<=${spellthreshold} && (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Me.Ability[${SpellType[377]}].IsReady}
	{
		call CastSpellRange 377 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Chronosiphon
	if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${spellsused}<=${spellthreshold} && !${Me.Maintained[${SpellType[382]}](exists)} && ${Me.Ability[${SpellType[382]}].IsReady}
	{
		call CastSpellRange 382 0 0 0 ${KillTarget}
		spellsused:Inc		
	}
	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1	
	;;;; Obliterated Psyche
	if ${spellsused}<=${spellthreshold} && ${DPSMode} && ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)}
	{
		call CastSpellRange 50 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Hostage
	if ${spellsused}<=${spellthreshold} && ${Me.Grouped} && ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)}
	{
		call CastSpellRange 71 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;;Psychic Trauma
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[504]}].IsReady} && !${Me.Maintained[${SpellType[504]}](exists)}
	{
		call CastSpellRange 504 0 0 0 ${KillTarget}
		spellsused:Inc
	}	
	;;;;Spell Curse
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)}
	{
		call CastSpellRange 92 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;;Sever Hate
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[386]}].IsReady} && !${Me.Maintained[${SpellType[386]}](exists)}
	{
		call CastSpellRange 386 0 0 0 ${Me.ID}
		spellsused:Inc
	}	
	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1	
	;;;;Bewilderment
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[500]}].IsReady}
	{
		call CastSpellRange 500 0 0 0 ${KillTarget}
		spellsused:Inc
	}	
	;;;; Asylum
	if ${spellsused}<=${spellthreshold} && ${Me.Power}>55 && ${Me.Ability[${SpellType[80]}].IsReady} && !${Me.Maintained[${SpellType[80]}](exists)}
	{
		call CastSpellRange 80 0 0 0 ${KillTarget}
		spellsused:Inc
	}		
	;;;; Brainshock
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[70]}].IsReady} && !${Me.Maintained[${SpellType[70]}](exists)}
	{
		call CastSpellRange 70 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Master Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[Master's Strike].IsReady} && ${Mob.CheckActor[${KillTarget}]}
	{
		Target ${KillTarget}
		Me.Ability[Master's Strike]:Use
		spellsused:Inc
	}							
	;;;; Nullify Staff
	if ${spellsused}<=${spellthreshold} && ${NullifyStaff} && ${Me.Ability[${SpellType[389]}].IsReady} && !${Me.Maintained[${SpellType[389]}](exists)}
	{
		call CastSpellRange 389 0 1 0 ${KillTarget}
	}	
	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1	
	;;;; Hemorrhage
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady} && !${Me.Maintained[${SpellType[60]}](exists)}
	{
		call CastSpellRange 60 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;;Shock Wave
	if ${spellsused}<=${spellthreshold} && ${PBAoEMode} && !${MezzMode} && ${Me.Ability[${SpellType[95]}].IsReady} && !${Me.Maintained[${SpellType[95]}](exists)} && ${Actor[${KillTarget}].Distance}<11
	{
		call CastSpellRange 95 0 1 0 ${KillTarget}
		spellsused:Inc
	}	
	;;;; Absolute Silence
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[260]}].IsReady} && !${Me.Maintained[${SpellType[260]}](exists)}
	{
		call CastSpellRange 260 0 0 0 ${KillTarget}
		spellsused:Inc
	}		
	;;;;Ego Melt
	if ${spellsused}<=${spellthreshold} && ${AoEMode} && !${MezzMode} && ${Me.Ability[${SpellType[91]}].IsReady} && !${Me.Maintained[${SpellType[91]}](exists)}
	{
		call CastSpellRange 91 0 0 0 ${KillTarget}
		spellsused:Inc
	}	
	;Dump out if threshold met
	if ${spellsused}>=${spellthreshold}
		return 1	
	;;;;Simple Minds
	if ${spellsused}<=${spellthreshold} && ${AoEMode} && !${MezzMode} && ${Me.Ability[${SpellType[90]}].IsReady} && !${Me.Maintained[${SpellType[90]}](exists)}
	{
		call CastSpellRange 90 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; PuppetMaster 
	if ${spellsused}<=${spellthreshold} && ${PuppetMaster} && ${Actor[${KillTarget}].Health}>=35  && ${Me.Ability[${SpellType[391]}].IsReady}
	{
		CurrentAction:Set[PuppetMaster]	
		call CastSpellRange 391 0 0 0 ${KillTarget}
	}
	;;;;Medusa Gaze
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[190]}].IsReady} && !${Me.Maintained[${SpellType[190]}](exists)}
	{
		call CastSpellRange 190 0 0 0 ${KillTarget}
		spellsused:Inc
	}		
	;;;;Mindbend
	if ${spellsused}<=${spellthreshold} && !${Actor[${KillTarget}].IsEpic} && ${Me.Ability[${SpellType[192]}].IsReady} && !${Me.Maintained[${SpellType[192]}](exists)}
	{
		call CastSpellRange 192 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;;;; Piece of Mind after mob has been beat on a bit
	if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}<90
	{
		Me:InitializeEffects

		while ${Me.InitializingEffects}
			wait 2

		;don't PoM if PoM is up
		if !${Me.Effect[beneficial,${SpellType[501]}](exists)} && ${Me.Ability[${SpellType[501]}].IsReady}
		{
			CurrentAction:Set[Piece of Mind]
			call CastSpellRange 501
			;eq2execute /p "PoM is active!"
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]

	CurrentAction:Set[Post Combat ${xAction}]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{
	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}
	;Blink
	if ${Me.Ability[${SpellType[180]}].IsReady}
		call CastSpellRange 180 0 0 0 ${aggroid}
	elseif ${Me.Ability[${SpellType[181]}].IsReady}
		call CastSpellRange 181 0 0 0 ${aggroid}
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{

}

function Cancel_Root()
{

}

function RefreshPower()
{
	declare tempvar int local
	declare MemberLowestPower int local

	if ${Me.Power}<10 && ${Me.Health}>60 && ${Me.Inventory[${Manastone}](exists)} && ${Me.Inventory[${Manastone}].IsReady}
		Me.Inventory[${Manastone}]:Use

	if ${ShardMode}
		call Shard 10

	;Transference line out of Combat
	if ${Me.Health}>60 && ${Me.Power}<50 && !${Me.InCombat}
		call CastSpellRange 309

	;Transference Line in Combat
	if ${Me.Health}>10 && ${Me.Power}<20
		call CastSpellRange 309

	;;;; Mana Flow
	if ${Me.Raid} && ${Me.Ability[${SpellType[390]}].IsReady}
	{
		tempvar:Set[0]
		MemberLowestPower:Set[0]
		
		do
		{
   		if ${Me.Raid[${tempvar}](exists)} && ${Me.Raid[${tempvar}](exists)}
   		{
   		  if ${Me.Raid[${tempvar}].Name.NotEqual[${Me.Name}]}
   			{
					if ${Me.Raid[${tempvar}].Power}<95 && !${Me.Raid[${tempvar}].IsDead} && ${Me.Raid[${tempvar}].Distance}<=${Me.Ability[${SpellType[390]}].Range}
    			{
    				if (${Me.Raid[${tempvar}].Power} < ${Me.Raid[${MemberLowestPower}].Health}) || ${MemberLowestPower}==0
    					MemberLowestPower:Set[${tempvar}]
    			}   				
   			}
   		}		
		}
		while ${tempvar:Inc}<=24

		if ${Me.Raid[${MemberLowestPower}](exists)} && ${Me.Raid[${MemberLowestPower}].Distance}<30
		{	
			call CastSpellRange 390 0 0 0 ${Me.Raid[${raidlowest}].ID}
			eq2execute em Flow to ${Me.Raid[${raidlowest}].Name}
		}
	}
	
	if ${Me.Grouped}
	{
		;Mana Flow the lowest group member
		tempvar:Set[1]
		MemberLowestPower:Set[0]
		do
		{
			if ${Me.Group[${tempvar}].Power}<55 && ${Me.Group[${tempvar}].Distance}<30 && ${Me.Group[${tempvar}](exists)}
			{
				if ${Me.Group[${tempvar}].Power}<=${Me.Group[${MemberLowestPower}].Power}
					MemberLowestPower:Set[${tempvar}]
			}
		}
		while ${tempvar:Inc}<${Me.GroupCount}


		if ${Me.Group[${MemberLowestPower}](exists)} && ${Me.Group[${MemberLowestPower}].Power}<65 && ${Me.Group[${MemberLowestPower}].Distance}<30 && ${Me.Ability[${SpellType[390]}].IsReady}
		{
			
			if ${Me.Group[${MemberLowestPower}].ID} > 0
			{
				eq2execute em Flow to ${Me.Group[${MemberLowestPower}].Name}
				call CastSpellRange 390 0 0 0 ${Me.Group[${MemberLowestPower}].ID}	
			}
		}
	}
		
	;;;; Canbalize Thoughts
	if ${Me.InCombat} && ${Me.Power}<20
		call CastSpellRange 51 0 0 0 ${KillTarget}
			
	;Channel if group member is below 20 and we are in combat and manaflow isnt ready and it isn't the MT
	if ${Me.InCombat} && ${Me.Grouped} && ${Me.Group[${MemberLowestPower}](exists)} && ${Me.Group[${MemberLowestPower}].Power}<30 && ${Me.Group[${MemberLowestPower}].Distance}<50
	{
	if  ${Me.Group[${MemberLowestPower}].ID}!=${Actor[pc,ExactName,${MainTankPC}].ID}
		call CastSpellRange 310
	}

	;Mana Cloak the group if the Main Tank is low on power
	if ${Actor[${MainTankPC}].Power}<50 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].Distance}<50  && ${Actor[${MainTankPC}].InCombatMode}
		call CastSpellRange 354

}

function CheckHeals()
{

	call CommonHeals 70

	if ${Actor[${MainTankPC}].Health}<20 && ${Me.Ability[${SpellType[378]}].IsReady}
	{
		call CastSpellRange 378 0 0 0 ${Actor[${MainTankPC}].ID}
		eq2execute em ManaWard on ${Actor[${MainTankPC}].Name}
	}
	
	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	; Cure Arcane Me
	if ${Me.Arcane}>0
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
	}

	if ${DPSMode}
		return 1

	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}](exists)}
				Target ${KillTarget}
		}
	}
	while ${temphl:Inc}<${grpcnt}		
		
}

function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	EQ2:CreateCustomActorArray[byDist,25]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			;if its the kill target skip it
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} || ${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]

			;check if its agro on a group member or group member's pet
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].Pet.ID} && ${Me.Group[${tempvar}].Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			;check if its agro on a raid member or raid member's pet
			if ${Me.InRaid}
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].ID}  || (${CustomActor[${tcount}].Target.ID}==${Actor[exactname,${Me.Raid[${tempvar}].Name}].Pet.ID})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=24
			}
			;check if its agro on me
			if ${CustomActor[${tcount}].Target.ID}==${Me.ID} || ${CustomActor[${tcount}].Target.IsMyPet}
				aggrogrp:Set[TRUE]

			if ${aggrogrp}
			{
				if ${Me.AutoAttackOn}
					eq2execute /toggleautoattack

				if ${Me.RangedAutoAttackOn}
					eq2execute /togglerangedattack

				;try to AE mezz first and check if its not single target mezzed
				if !${CustomActor[${tcount}].Effect[${SpellType[352]}](exists)}
					call CastSpellRange 353 0 0 0 ${CustomActor[${tcount}].ID}

				;if the actor is not AE Mezzed then single target Mezz
				if !${CustomActor[${tcount}].Effect[${SpellType}[353]](exists)}
					call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 10

				aggrogrp:Set[FALSE]
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead} && ${Mob.Detect}
	{
		Target ${KillTarget}
		wait 20 ${Me.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
		KillTarget:Set[]
	}
}

function DoCharm()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	if ${Me.Maintained[${SpellType[351]}](exists)} || ${Me.UsedConc}>2
		return

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && !${CustomActor[${tcount}].IsEpic} && ${CustomActor[${tcount}].Target(exists)}
		{
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID} && ${grpcnt}>1
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].Pet.ID} && ${Me.Group[${tempvar}].Pet(exists)})
					{
						aggrogrp:Set[TRUE]
						break
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
				aggrogrp:Set[TRUE]

			if ${aggrogrp} && (${CustomActor[${tcount}].Difficulty}>=0) && (${CustomActor[${tcount}].Difficulty}<=3)
			{
				CharmTarget:Set[${CustomActor[${tcount}].ID}]
				break
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${CharmTarget}](exists)}
	{
		call CastSpellRange 351 0 0 0 ${CharmTarget}

		if ${Actor[${KillTarget}](exists)} && (${Me.Maintained[${SpellType[351]}].Target.ID}!=${KillTarget}) && ${Me.Maintained[${SpellType[351]}](exists)} && !${Actor[${KillTarget}].IsDead}
			call PetAttack
		else
			EQ2Execute /target_none
	}
}
function DoDMind()
{
	variable string DMActor=${UIElement[lbDMind@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${BuffDMindMember}].Text}

	if !${Me.Ability[${SpellType[72]}].IsReady}
		return

	if ${UIElement[lbDMind@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}==0
		return

	if ${Actor[${DMActor.Token[2,:]},${DMActor.Token[1,:]}].Distance}<${Position.GetSpellMaxRange[${TID},0,${Me.Ability[${SpellType[72]}].Range}]}
	{
		EQ2Execute /useabilityonplayer ${DMActor.Token[1,:]} ${SpellType[72]}
		wait 5
		while ${Me.CastingSpell}
		wait 1
		BuffDMindMember:Inc
	}
	else
	{
		BuffDMindMember:Inc
	}

	;We have gone through everyone in the list so start back at the begining
	if ${BuffDMindMember}>${UIElement[lbDMind@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
		BuffDMindMember:Set[1]
}

function DoAmnesia()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,35]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{
			if (${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID}) || (${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID})
				continue

			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].Pet.ID} && ${Me.Group[${tempvar}].Pet(exists)})
					{
						call IsFighter ${Me.Group[${tempvar}].ID}
						if ${Return} || ${Me.Group[${tempvar}].Name.Equal[${MainAssist}]}
							continue
						else
						{
							aggrogrp:Set[TRUE]
							break
						}
					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}  && !${MainTank}
				aggrogrp:Set[TRUE]

			if ${aggrogrp}
			{
				;;;; Coercive Shout
				if ${Me.Ability[${SpellType[509]}].IsReady}
				{
					call CastSpellRange 509 0 0 0 ${MainTank}	
				}
				;Try AA Thought Snap next if we have it
				if ${Me.Ability[${SpellType[376]}].IsReady}
					call CastSpellRange 376 0 0 0 ${CustomActor[${tcount}].ID}
				elseif ${Me.Ability[${SpellType[383]}].IsReady}
					call CastSpellRange 383 0 0 0 ${KillTarget}
				else
					call CastSpellRange 193 0 0 0 ${CustomActor[${tcount}].ID}
				return
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}