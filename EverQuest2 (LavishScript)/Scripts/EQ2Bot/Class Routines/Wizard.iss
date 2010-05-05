;*************************************************************
;Updated bob0builder
;
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090622
	;;;;

	declare AoEMode bool script FALSE
	declare RaysMode bool script FALSE
	declare PreBuffShield bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BuffAccordShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffRadianceProc collection:string script
	declare BuffAmplify bool script FALSE
	declare BuffSeal bool script FALSE
	declare CastCures bool script FALSE
	declare PetMode bool script TRUE
	declare StartHO bool script FALSE
	declare PetForm int script 1

	call EQ2BotLib_Init

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	RaysMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Rays,TRUE]}]
	PreBuffShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PreBuffShield,TRUE]}]
	CastCures:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Cures,TRUE]}]
	BuffAccordShield:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Accord Shield,FALSE]}]
	BuffSeeInvis:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff See Invis,TRUE]}]
	BuffAmplify:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAmplify,,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	BuffSeal:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSeal,FALSE]}]
	PetForm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PetForm,]}]

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


	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+7000]}) && !${Me.IsMoving}
	{
		if ${PreBuffShield}
			call CastSpellRange 355 0 0 0 ${Actor[pc,exactname,${MainTankPC}].ID}

		call CheckHeals
		call RefreshPower

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[BuffAmplify]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[BuffSeal]
	PreSpellRange[3,1]:Set[20]

	PreAction[4]:Set[Tank_Buff]
	PreSpellRange[4,1]:Set[40]

	PreAction[5]:Set[Melee_Buff]
	PreSpellRange[5,1]:Set[31]

	PreAction[6]:Set[SeeInvis]
	PreSpellRange[6,1]:Set[30]

	PreAction[7]:Set[AA_Ward_Sages]
	PreSpellRange[7,1]:Set[386]

	PreAction[8]:Set[AA_Pet]
	PreSpellRange[8,1]:Set[382]
	PreSpellRange[8,2]:Set[383]
	PreSpellRange[8,3]:Set[384]

	PreAction[9]:Set[DeityPet]
	
	PreAction[10]:Set[MailOfFrost]	
}

function Combat_Init()
{
 ;scratched for priority casting

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
		
	;UIElement[EQ2 Bot]:SetAlpha[0.3]		
		
	if !${Me.Equipment[Food].AutoConsumeOn}
		Me.Equipment[Food]:ToggleAutoConsume
		
	if !${Me.Equipment[Drink].AutoConsumeOn}
		Me.Equipment[Drink]:ToggleAutoConsume

	if !${Me.Maintained[Hover](exists)} && !${Me.Maintained[Call Ykeshan Spellbear](exists)}
		Me.Ability[Hover]:Use	

	; Cast broken Myth buff
	if ${Me.Ability[Focused Mind].IsReady} && !${Me.Maintained[Focused Mind](exists)}
		eq2execute /useability "Focused Mind"

	if !${Me.Maintained[Summon Animated Tome](exists)}
		Me.Ability[Summon Animated Tome]:Use	
		
	InitialBuffsDone:Set[TRUE]		
}

	call CheckHeals
	call RefreshPower

	if ${Me.Equipment[Food].AutoConsumeOn}
		Me.Equipment[Food]:ToggleAutoConsume
		
	if ${Me.Equipment[Drink].AutoConsumeOn}
		Me.Equipment[Drink]:ToggleAutoConsume

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case BuffAmplify
			if ${BuffAmplify}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffSeal
			if ${BuffSeal}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Tank_Buff
			BuffTarget:Set[${UIElement[cbBuffAccordShieldGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}

			break
		case Melee_Buff
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
					if ${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffRadianceProc@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

		case SeeInvis
			if ${BuffSeeInvis}
			{
				; If group see invis (Snow-Filled Steps) is available, use that.
				if ${Me.Ability[${SpellType[354]}](exists)}
				{
					if ${Me.Ability[${SpellType[354]}].IsReady}
						call CastSpellRange 354
					break
				}
				;buff myself first
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ToActor.ID}

				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
					}

				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case AA_Ward_Sages
			if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_Pet
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${PetForm}]}
			}
			break
		case DeityPet
			call SummonDeityPet
			break
		case MailOfFrost
			call CastSpellRange 27
			break			
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[2]		

	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	if ${CureMode}
		call CheckHeals

	call RefreshPower
	call UseCrystallizedSpirit 60

;; Fireshape = 387
;; Surge of Ro = 361
;; Iceshape = 388
;; Frigid Gift = 360
;; Freehand = 385
;; Catalyst = 389

;;; Cast AOEs and PBAOEs	** May slow down regular single mob DPS **
	if ${Mob.Count}>1
	{
		;Use Furnace of Ro (Blanket carpet on the ground, considered a pet?)
		if ${spellsused}<=${spellthreshold} && ${PBAoEMode} && ${Actor[${KillTarget}].Distance}<=10 && ${Me.Ability[${SpellType[95]}].IsReady} && ${Actor[${KillTarget}].Health}>50
		{
		;;;Fireshape and Surge of Ro
			if ${Me.Ability[${SpellType[387]}].IsReady} && ${Me.Ability[${SpellType[361]}].IsReady} && !${Me.Maintained[${SpellType[388]}](exists)}
			{
				call CastSpellRange 387
				call CastSpellRange 361
				;eq2execute /p "Surge of Ro and Fireshaper are up!"			
			}
			call CastSpellRange 95 0 1 0 ${KillTarget}
			;eq2execute /p "Furnace of Ro is down, please move the mobs onto the fire blanket!"
			spellsused:Inc
		}	
		;Hailstorm - Has an AOE component at the end
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Mob.Count}>2 && ${Me.Ability[${SpellType[508]}].IsReady} && !${Me.Maintained[${SpellType[508]}](exists)}
		{
			call CastSpellRange 508 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Fire Storm
		if ${spellsused}<=${spellthreshold} && ${PBAoEMode} && ${Mob.Count}>2 && ${Actor[${KillTarget}].Distance}<=10 && ${Me.Ability[${SpellType[96]}].IsReady} && !${Me.Maintained[${SpellType[96]}](exists)}
		{
			call CastSpellRange 96 0 1 0 ${KillTarget}
			spellsused:Inc
		}
		;Glacial Wind
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Mob.Count}>2 && ${Me.Ability[${SpellType[91]}].IsReady} && !${Me.Maintained[${SpellType[91]}](exists)}
		{
			call CastSpellRange 91 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Storm of Lightning
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Mob.Count}>2 && ${Me.Ability[${SpellType[92]}].IsReady} && !${Me.Maintained[${SpellType[92]}](exists)}
		{
			call CastSpellRange 92 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	;Use Protoflame if PetMode is selected
	if ${spellsused}<=${spellthreshold} && ${PetMode} && ${Me.Ability[${SpellType[324]}].IsReady} && ${Actor[${KillTarget}].Health}>85
	{
		call CastSpellRange 324 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;;;Coldshape and Frigid Gift		
	if ${Me.Ability[${SpellType[388]}].IsReady} && ${Me.Ability[${SpellType[360]}].IsReady} && !${Me.Maintained[${SpellType[387]}](exists)}
	{
		call CastSpellRange 388
		call CastSpellRange 360
		;eq2execute /p "Frigid Gift and Iceshaper are up!"
	}
	
	;;;Fiery Blast	*Cast Fusion, IC, Rays, and BoD* First cast Catalyst + Freehand
	if ${Me.Ability[${SpellType[396]}].IsReady} && (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>40
	{
		if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
		{
			call CastSpellRange 385		
			call CastSpellRange 389		
		}	
		call CastSpellRange 396 0 0 0 ${KillTarget}
		;Fusion
		if ${Me.Maintained[${SpellType[396]}](exists)} && ${PBAoEMode} && ${Actor[${KillTarget}].Distance}<=10 && ${Me.Ability[${SpellType[94]}].IsReady}
			call CastSpellRange 94 0 0 0 ${KillTarget}
		;Ice Comet
		if ${Me.Maintained[${SpellType[396]}](exists)} && ${Me.Ability[${SpellType[60]}].IsReady} 
			call CastSpellRange 60 0 0 0 ${KillTarget}
		;Rays
		if ${Me.Maintained[${SpellType[396]}](exists)} && ${RaysMode} && ${Me.Ability[${SpellType[500]}].IsReady}
			call CastSpellRange 500 0 0 0 ${KillTarget}
		;Blast of Devastation
		if ${Me.Maintained[${SpellType[396]}](exists)} && ${PBAoEMode} && ${Actor[${KillTarget}].Distance}<=10 && ${Me.Ability[${SpellType[509]}].IsReady}
			call CastSpellRange 509 0 0 0 ${KillTarget}
	}	
	
	;Fusion + Catalyst + Freehand
	if ${spellsused}<=${spellthreshold} && ${PBAoEMode} && ${Actor[${KillTarget}].Distance}<=10 && ${Me.Ability[${SpellType[94]}].IsReady}
	{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>5
		{
		if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 94 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		elseif ${Actor[${KillTarget}].Health}>35
		{
			if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 94 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	;Blast of Devastation + Catalyst + Freehand
	if ${spellsused}<=${spellthreshold} && ${PBAoEMode} && ${Actor[${KillTarget}].Distance}<=10 && ${Me.Ability[${SpellType[509]}].IsReady}
	{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>5
		{
		if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 509 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		elseif ${Actor[${KillTarget}].Health}>35
		{
			if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 509 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	
	;Ice Spears
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[73]}].IsReady}
		{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>5
			{
				call CastSpellRange 73 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		elseif ${Actor[${KillTarget}].Health}>35
			{
				call CastSpellRange 73 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		}	
	;Storming Tempest
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[70]}].IsReady} 
		{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>10
			{
				call CastSpellRange 70 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		elseif ${Actor[${KillTarget}].Health}>45
			{
				call CastSpellRange 70 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		}		
	;Ice Comet + Catalyst + Freehand
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[60]}].IsReady} 
	{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>5
		{
		if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 60 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		elseif ${Actor[${KillTarget}].Health}>35
		{
			if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 60 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	;Rays + Catalyst + Freehand
	if ${RaysMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[500]}].IsReady}
	{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>10
		{
			if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 500 0 0 0 ${KillTarget}
			;eq2execute /p "~~~ Rays of Destruction ~~~"
			spellsused:Inc
		}
		elseif ${Actor[${KillTarget}].Health}>35
		{
			if ${Me.Ability[${SpellType[385]}].IsReady} && ${Me.Ability[${SpellType[389]}].IsReady}
			{
				call CastSpellRange 385		
				call CastSpellRange 389		
				;eq2execute /p "Catalyst is being used, watch my health!"
			}	
			call CastSpellRange 500 0 0 0 ${KillTarget}
			;eq2execute /p "~~~ Rays of Destruction ~~~"			
			spellsused:Inc
		}
	}
	;Ball of Fire
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[62]}].IsReady} 
		{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>10
			{
				call CastSpellRange 62 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		elseif ${Actor[${KillTarget}].Health}>45
			{
			call CastSpellRange 62 0 0 0 ${KillTarget}
			spellsused:Inc
			}
		}
	;Thunderclap
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[506]}].IsReady}
	{
		call CastSpellRange 506 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;;;; Master Strike
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[Master's Strike].IsReady} && ${Mob.CheckActor[${KillTarget}]}
	{
		;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
		;;;;;;;;;;
		if (!${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)})
		{
			Target ${KillTarget}
			Me.Ability[Master's Strike]:Use
			spellsused:Inc
		}
	}
	;Bewilderment 
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[505]}].IsReady}
	{
		call CastSpellRange 505 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Magma Chamber
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[181]}].IsReady}
		{
		if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}>10
			{
				call CastSpellRange 181 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		elseif ${Actor[${KillTarget}].Health}>45
			{
			call CastSpellRange 181 0 0 0 ${KillTarget}
			spellsused:Inc
			}
		}
	;Flames of Velious
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[61]}].IsReady} && !${Me.Maintained[${SpellType[61]}](exists)}
	{
		call CastSpellRange 61 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Solar Flare
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[63]}].IsReady}
	{
		call CastSpellRange 63 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Immolation
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[71]}].IsReady} && !${Me.Maintained[${SpellType[71]}](exists)}
	{
		call CastSpellRange 71 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	;Incinerate
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[72]}].IsReady} && !${Me.Maintained[${SpellType[72]}](exists)}
	{
		call CastSpellRange 72 0 0 0 ${KillTarget}
		spellsused:Inc
	}			
}

function Post_Combat_Routine(int xAction)
{
	TellTank:Set[FALSE]
	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{
;;;Cast Cease or Concussive
	if ${Me.Ability[${SpellRange[180]}].IsReady}
		call CastSpellRange 180 0 0 0 ${KillTarget}
	elseif ${Me.Ability[${SpellRange[330]}].IsReady}
		call CastSpellRange 330 0 0 0 ${KillTarget}
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
	if ${ShardMode}
		call Shard

	if ${Me.Power}<40 && ${Me.ToActor.Health}>60 && ${Me.Inventory[${Manastone}](exists)} && ${Me.Inventory[${Manastone}].IsReady}
		Me.Inventory[${Manastone}]:Use

	;Conjuror Shard
	if ${Me.ToActor.Power}<70 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
		Me.Inventory[${ShardType}]:Use

	if ${Me.ToActor.Power}<50 && ${Me.ToActor.Health}>20 && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
		call CastSpellRange 309

	if ${Me.ToActor.Power}<5
		call CastSpellRange 310
}

function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	; Cure Arcane Me
	if ${Me.Arcane}>0
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}

		if ${Actor[${KillTarget}](exists)}
			Target ${KillTarget}
	}

	do
	{
		; Cure Arcane
		if ${Me.Group[${temphl}].Arcane}>0
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}

			if ${Actor[${KillTarget}](exists)}
				Target ${KillTarget}
		}
	}
	while ${temphl:Inc}<${grpcnt}

}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}