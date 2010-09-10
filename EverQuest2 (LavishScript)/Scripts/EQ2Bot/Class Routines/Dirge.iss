;*****************************************************
;Dirge.iss 20100910a
;by Pygar
; see SVN logs for revision history
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090618
	;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare BowAttacksMode bool script 0
	declare RangedAttackOnlyMode bool script 0
	declare BuffSonata bool script 0
	declare AnnounceMode bool script 1
	declare MagNoteMode bool script 1

	declare BuffParry bool script FALSE
	declare BuffPower bool script FALSE
	declare BuffNoxious bool script FALSE
	declare BuffDPS bool script FALSE
	declare BuffStoneSkin bool script FALSE
	declare BuffTombs bool script FALSE
	declare BuffAgility bool script FALSE
	declare BuffMelee bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffSelf bool script FALSE
	declare BuffTarget string script
	declare UsePresetHO bool script FALSE
	declare BuffDontKillMessenger bool script FALSE
	declare ManageAutoAttackTiming boot script FALSE
	
	;Initialized by UI
	declare BuffGravitasTimers collection:int script
	declare BuffGravitasIterator iterator script
	declare BuffGravitasMember int script 1
	declare BuffGravitasListCurrent bool script FALSE
	declare CacophonyAnnounceText string script 
	declare BladeDanceAnnounceText string script
	declare GravitasAnnounceText string script
	declare JoustMode bool script 0

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	BowAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Bow Attack Spells,FALSE]}]
	RangedAttackOnlyMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]
	AnnounceMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Announce Cacophony,TRUE]}]
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]
	MagNoteMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MagNoteMode,TRUE]}]

	BuffParry:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Parry","FALSE"]}]
	BuffPower:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Power","FALSE"]}]
	BuffNoxious:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Noxious","FALSE"]}]
	BuffSonata:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Sonata","FALSE"]}]
	BuffDPS:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff DPS","FALSE"]}]
	BuffStoneSkin:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff StoneSkin","FALSE"]}]
	BuffTombs:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Tombs","FALSE"]}]
	BuffAgility:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Agility","FALSE"]}]
	BuffMelee:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Melee","FALSE"]}]
	BuffHate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Hate","FALSE"]}]
	BuffSelf:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Self","FALSE"]}]
	UsePresetHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Use Preset HOs","FALSE"]}]
	BuffDontKillMessenger:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Dont Kill The Messenger","FALSE"]}]
	ManageAutoAttackTiming:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Manage AutoAttack Timing","FALSE"]}]
	
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc[${ClassPulseTimer}+500]})
	{
		
		call DoBladeDance
		
	}

	if (${Script.RunningTime} >= ${Math.Calc[${ClassPulseTimer}+1500]})
	{
		
		ISXEQ2:ClearAbilitiesCache
		
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
	
}

function Class_Shutdown()
{

}

function Buff_Init()
{
	;echo buff init
	PreAction[1]:Set[Buff_Parry]
	PreSpellRange[1,1]:Set[20]

	PreAction[2]:Set[Buff_Power]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[Buff_Noxious]
	PreSpellRange[3,1]:Set[22]

	PreAction[4]:Set[Selos]
	PreSpellRange[4,1]:Set[381]

	PreAction[5]:Set[Buff_DPS]
	PreSpellRange[5,1]:Set[24]

	PreAction[6]:Set[Buff_AAHeroicStorytelling]
	PreSpellRange[6,1]:Set[396]

	PreAction[7]:Set[Buff_StoneSkin]
	PreSpellRange[7,1]:Set[26]

	PreAction[8]:Set[Buff_Tombs]
	PreSpellRange[8,1]:Set[27]

	PreAction[9]:Set[Buff_Agility]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[Buff_Melee]
	PreSpellRange[10,1]:Set[29]

	PreAction[11]:Set[Buff_Hate]
	PreSpellRange[11,1]:Set[30]

	PreAction[12]:Set[Buff_Self]
	PreSpellRange[12,1]:Set[31]

	PreAction[13]:Set[Buff_AAAllegro]
	PreSpellRange[13,1]:Set[390]

	PreAction[14]:Set[Buff_AADontKillTheMessenger]
	PreSpellRange[14,1]:Set[395]

	PreAction[15]:Set[Buff_AALuckOfTheDirge]
	PreSpellRange[15,1]:Set[382]

	PreAction[16]:Set[Buff_AAFortissimo]
	PreSpellRange[16,1]:Set[398]

	PreAction[17]:Set[Buff_AABattleCry]
	PreSpellRange[17,1]:Set[402]

	PreAction[18]:Set[Buff_AASonata]
	PreSpellRange[18,1]:Set[403]
}

function Combat_Init()
{
	; Lucky Break
	; Verliens Keen of Despair 
	; Darksong Blade
	; Evade
	; Darrows Sorrowful Dirge
	; Cheap Shot
	Action[1]:Set[PresetHO]
	SpellRange[1,1]:Set[303]
	SpellRange[1,2]:Set[51]
	SpellRange[1,3]:Set[150]
	SpellRange[1,4]:Set[180]
	SpellRange[1,5]:Set[55]
	SpellRange[1,6]:Set[190]

	; Tarven's Crippling Crescendo
	Action[2]:Set[Tarvens]
	SpellRange[2,1]:Set[50]
	
	; Bump
	; Misfortune's Kiss
	; Shroud
	; Scream of Death
	Action[3]:Set[Stealth_Attack1]
	SpellRange[3,1]:Set[391]
	SpellRange[3,2]:Set[136]
	SpellRange[3,3]:Set[200]
	SpellRange[3,4]:Set[135]

	; Bump
	; Misfortune's Kiss
	; Shroud
	; Scream of Death
	Action[4]:Set[Stealth_Attack2]
	SpellRange[4,1]:Set[391]
	SpellRange[4,2]:Set[136]
	SpellRange[4,3]:Set[200]
	SpellRange[4,4]:Set[135]

	; Sinister Strike	
	Action[5]:Set[MasterStrike]

	; Daro's Dull Blade
	Action[6]:Set[Daros]
	SpellRange[6,1]:Set[110]

	; Thuri's Dolefull Thrust
	Action[7]:Set[ThuriDolefulThrust]
	SpellRange[7,1]:Set[151]

	; Luda's Nefarious Wail	
	Action[8]:Set[Luda]
	SpellRange[8,1]:Set[60]

	; Hymn of Horror
	Action[9]:Set[HymnofHorror]
	SpellRange[9,1]:Set[95]
	
	; Evasive Maneuvers
	Action[10]:Set[EvasiveManeuvers]
	SpellRange[10,1]:Set[405]

	; Howl of Death
	Action[11]:Set[HowlofDeath]
	SpellRange[11,1]:Set[152]

	; Rhythm Blade
	Action[12]:Set[AARhythm_Blade]
	SpellRange[12,1]:Set[397]
	
	; Lanet's Excruciating Scream
	Action[13]:Set[Lanets]
	SpellRange[13,1]:Set[52]
	
	; Jarol's Sorrowful Requiem
	Action[14]:Set[Jarols]
	SpellRange[14,1]:Set[63]
	
	; Brocks Thermal Shocker
	Action[15]:Set[ThermalShocker]
	
	; Turnstrike
	Action[16]:Set[AATurnstrike]
	SpellRange[16,1]:Set[387]
		
	; Jael's Dreadful Deprivation
	Action[17]:Set[Jael]
	SpellRange[17,1]:Set[250]
	
	; Messenger's Letter
	Action[18]:Set[MessengersLetter]
	SpellRange[18,1]:Set[505]
	
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{

	switch ${PreAction[${xAction}]}
	{
		case Buff_Parry
			if ${BuffParry}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Power
			if ${BuffPower}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Noxious
			if ${BuffNoxious}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_AASonata
			if ${BuffSonata} 
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_DPS
			if ${BuffDPS}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_StoneSkin
			if ${BuffStoneSkin}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Tombs
			if ${BuffTombs}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Agility
			if ${BuffAgility}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Melee
			if ${BuffMelee}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_AADontKillTheMessenger
			if ${BuffDontKillMessenger}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Hate
			if ${BuffHate}
				{			
				BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
	
					if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2
				}
				else
				{
				BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
			break
		case Buff_AABattleCry
			BuffTarget:Set[${UIElement[cbBuff_AABattleCry@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2
			break
		case Buff_Self
			if ${BuffSelf}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_AAHeroicStorytelling
		case Buff_AAAllegro
		case Buff_AALuckOfTheDirge
		case Buff_AAFortissimo
		case Selos
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			break
		Default
			return Buff Complete
			break
	}

}

function Combat_Routine(int xAction)
{
	declare StartTime time ${Time.Timestamp}
	declare strTime string
	declare DebuffCnt int  0
	
	; Do check for Power Building Items
	if ${ShardMode}
		call Shard 10

	call DoGravitas

	; Check if anyone needs the Dirge Heal and if anyone needs rezzed
	call CheckHeals

	; If we are specced for MagNote and it is check in the UI
	if ${MagNoteMode}
		call DoMagneticNote

	; If we are specced for BladeDance and the Criteria has been met for it
	if !${JoustMode}
		call DoBladeDance
	
	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${Actor[${KillTarget}].Distance}>${Position.GetMeleeMaxRange[${KillTarget}]} && ${Actor[${KillTarget}].Distance}<${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[250]}].MaxRange}]}
	{
		if ${BowAttacksMode} && ${Me.Equipment[Ranged].SubType.Equal[Bow]} && ${Me.Equipment[Ammo].NextSlotOpen}
		{
			; Jael's Dreadful Deprivation
			if ${Me.Ability[${SpellType[250]}].IsReady}
				eq2execute /useability ${SpellType[250]}
			
			eq2execute /auto 2
		}
		
		; Wail of the Banshee (Encounter DoT)
		if ${Me.Ability[${SpellType[62]}].IsReady}
		{
			eq2execute /useability ${SpellType[62]}
			
			; Thuri's Doleful Thrust
			call CheckPosition 1 0 ${KillTarget} 151 1
			if (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn}) && ${Me.Ability[${SpellType[151]}].IsReady}
			{
				eq2execute /useability ${SpellType[151]}
				wait 1
				while ${Me.CastingSpell}
				{
					waitframe
				}
			}
		}	
	}

	; Turn on Melee Autoattack if we are not in forced to use Ranged Attacks, and Autoattack is not already on.
	if !${RangedAttackOnlyMode} && ((${Actor[${KillTarget}].Distance}<=${Position.GetMeleeMaxRange[${KillTarget}]} && !${Me.AutoAttackOn}) || (${Me.RangedAutoAttackOn} && ${Actor[${KillTarget}].Distance}<=${Position.GetMeleeMaxRange[${KillTarget}]}))
		eq2execute /auto 1
	
	; This section fires only when JoustMode is enabled.
	if ${JoustMode}
		call joust
		
	if !${Mob.CheckActor[${KillTarget}]}
		return

	;Always use Cacophony of Blades if available and not under the effects of it from someone else.
	if ${Me.Ability[${SpellType[155]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
	{
		Me:InitializeEffects

		do
		{
			echo ISXEQ2.InitializingActorEffects
			waitframe
		}
		while ${ISXEQ2.InitializingActorEffects}

		;don't CoB if CoB is up
		if !${Me.Effect[beneficial,${SpellType[155]}](exists)} && (${Actor[${KillTarget}].Health}>=10 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
		{
			if ${CacophonyAnnounceText.Length}
			{
				eq2execute /raidsay ${CacophonyAnnounceText}
				eq2execute /g ${CacophonyAnnounceText}
			}
			call CastSpellRange 155 0 0 0 ${KillTarget} 0 0 1 0 1 0
		}
	}

	if ${DebuffMode}
	{
		if !${Me.Maintained[${SpellType[55]}](exists)} && ${Me.Ability[${SpellType[55]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			call CastSpellRange 55 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[56]}](exists)} && ${Me.Ability[${SpellType[56]}].IsReady} && ${Mob.CheckActor[${KillTarget}]} && ${DebuffCnt}<1
		{
			call CastSpellRange 56 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[57]}](exists)} && ${Me.Ability[${SpellType[57]}].IsReady} && ${Mob.CheckActor[${KillTarget}]} && ${DebuffCnt}<1
		{
			call CastSpellRange 57 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[54]}](exists)} && ${Me.Ability[${SpellType[54]}].IsReady} && ${Mob.CheckActor[${KillTarget}]} && ${DebuffCnt}<1
		{
			call CastSpellRange 54 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
	}
	
	if ${Me.Ability[${SpellType[62]}].IsReady} && ${Mob.CheckActor[${KillTarget}]}
	{
		call CastSpellRange 62 0 0 0 ${KillTarget} 0 0 1 0
		if (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
			call CastSpellRange 151 0 1 1 ${KillTarget} 0 0 1 0
	}

	if ${RangedAttackOnlyMode}
	{
		if !${Me.RangedAutoAttackOn}
			EQ2Execute /togglerangedattack

		if !${Me.CastingSpell} && ${Target.Distance}>35
		{
			Target ${KillTarget}
			call CheckPosition 3 0
		}
	}
	
	if ${DoHOs} && ${Mob.CheckActor[${KillTarget}]}
		objHeroicOp:DoHO
	
	switch ${Action[${xAction}]}
	{
		case PresetHO
			if ${UsePresetHO}
			{		
				if !${RangedAttackOnlyMode} && ${Mob.CheckActor[${KillTarget}]}
				{
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
					
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
						call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
					wait 30 ${EQ2.HOWindowActive}
					if !${EQ2.HOName.Equal[Bravo's Dance]}
					; inserting a single quote to make my code readable '
					{
						; If we are the MT NEVER use Evade to progress an HO
						if !${MainTank}
						{
							if ${Me.Ability[${SpellType[${SpellRange[${xAction},4]}]}].IsReady}
							{
								call CastSpellRange ${SpellRange[${xAction},4]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
							}
						}
						else
						{
							if ${Me.Ability[${SpellType[${SpellRange[${xAction},6]}]}].IsReady}
							{
								call CastSpellRange ${SpellRange[${xAction},6]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
							}
						}
					}
					elseif ${Me.Ability[${SpellType[${SpellRange[${xAction},5]}]}].IsReady}
						call CastSpellRange ${SpellRange[${xAction},5]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
				}
				call CastSpellRange ${SpellRange[${xAction},3]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
			}
			else
			{
				if !${RangedAttackOnlyMode} && ${Mob.CheckActor[${KillTarget}]}
				{
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
					{
						if ${ManageAutoAttackTiming}
						{
							call CalcAutoAttackTimer
							if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}
								call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
						}
					}
				}
			}
			break
		case Stealth_Attack1
			if !${RangedAttackMode} && (${Me.Ability[${SpellType[${SpellRange[${xAction},3]}]}].IsReady} || ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}) && ${Mob.CheckActor[${KillTarget}]}
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].TimeUntilReady}<.1 || ${Me.Ability[${SpellType[${SpellRange[${xAction},4]}]}].TimeUntilReady}<.1
				{
					while ${Me.CastingSpell}
					{
						;wait 2
					}
					;if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn}) && ${Mob.CheckActor[${KillTarget}]}
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1 0 1
						wait 5
						if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
						{
							call CastSpellRange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget} 0 0 1 0 1
						}
						elseif ${Me.Ability[${SpellType[${SpellRange[${xAction},4]}]}].IsReady}
						{
							call CastSpellRange ${SpellRange[${xAction},4]} 0 1 1 ${KillTarget} 0 0 1 0 1
						}
					}
					while ${Me.CastingSpell}
					{
						;wait 2
					}
				}
			}
			break
		case Stealth_Attack2
			if !${RangedAttackMode} && (${Me.Ability[${SpellType[${SpellRange[${xAction},3]}]}].IsReady} || ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}) && ${Mob.CheckActor[${KillTarget}]}
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].TimeUntilReady}<.1 || ${Me.Ability[${SpellType[${SpellRange[${xAction},4]}]}].TimeUntilReady}<.1
				{
					while ${Me.CastingSpell}
					{
						;wait 2
					}
					;	check if we have the bump AA and use it to stealth us
					;if ${Me.Ability[${SpellType[${SpellRange[${xAction},3]}]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn}) && ${Mob.CheckActor[${KillTarget}]}
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},3]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},3]} 0 1 0 ${KillTarget} 0 0 1 0 1
						wait 5
						if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
						{
							call CastSpellRange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget} 0 0 1 0 1
						}
						elseif ${Me.Ability[${SpellType[${SpellRange[${xAction},4]}]}].IsReady}
						{
							call CastSpellRange ${SpellRange[${xAction},4]} 0 1 1 ${KillTarget} 0 0 1 0 1
						}
					}
					while ${Me.CastingSpell}
					{
						;wait 2
					}
				}
			}
			break
		case MasterStrike
			if ${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)} || ${MainTank} || ${Target.Target.ID}!=${Me.ID} || ${RangedAttackOnlyMode} || !${Mob.CheckActor[${KillTarget}]}
			{
				break
			}

			if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
				call CheckPosition 1 1 ${KillTarget}
				Me.Ability[Sinister Strike]:Use
			}
			break
		case MessengersLetter	
		case Jael
			if ${BowAttacksMode} && ${Mob.CheckActor[${KillTarget}]} && ${Actor[${KillTarget}].Distance}>3 && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${ManageAutoAttackTiming}
				{
					call CalcAutoAttackTimer
					if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget} 0 0 1 0 2 0
				}
				else	
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget} 0 0 1 0 2 0
				}
			}
			break
		case EvasiveManeuvers
			if !${MainTank} && ${Mob.CheckActor[${KillTarget}]} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${ManageAutoAttackTiming}
				{
					call CalcAutoAttackTimer
					if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
				}
				else
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
				}
			}
			break
		case Daros
			if !${RangedAttackOnlyMode} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn}) && ${Mob.CheckActor[${KillTarget}]} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${ManageAutoAttackTiming}
				{
					call CalcAutoAttackTimer				
					if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 0 0 1 0 2 0
				}
				else
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 0 0 1 0 2 0
				}
			}
			break
		case Lanets
		case Luda
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					if ${ManageAutoAttackTiming}
					{
						call CalcAutoAttackTimer				
						if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}				
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
					}
				}
			}
			break
		case Tarvens
		case AARhythm_Blade
		case ThuriDolefulThrust
		case HowlofDeath
			{
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					if ${ManageAutoAttackTiming}
					{
						call CalcAutoAttackTimer				
						if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}								
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
			}
			break
		case HymnofHorror
			{
				if ${AoEMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					if ${ManageAutoAttackTiming}
					{
						call CalcAutoAttackTimer				
						if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}													
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
			}
			break			
		case Jarols
			{
				; Because it has a long cast time lets make sure it is worth it by having more than 2 mobs.
				if ${Mob.Count}>2 && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					if ${ManageAutoAttackTiming}
					{
						call CalcAutoAttackTimer				
						if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}																		
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
					}
				}
			}
			break			
		case ThermalShocker
			{
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use	
				}
			}
			break
		case AATurnstrike
			{
				if !${MainTank} && ${Actor[${KillTarget}].Target.ID}!=${Me.ID} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					if ${ManageAutoAttackTiming}
					{
						call CalcAutoAttackTimer				
						if ${TimeUntilNextAutoAttack} > ${Math.Calc[${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].CastingTime}+${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].RecoveryTime}]}																							
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
					else
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
			}
			break			
		default
			return CombatComplete
			break
	}

}

function Post_Combat_Routine(int xAction)
{
	if ${Me.Maintained[Shroud](exists)}
		Me.Maintained[Shroud]:Cancel

	;reset rangedattack in case it was modified by joust call.
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]
	RangedAttackOnlyMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro(int agroid)
{

	;Evasive
	if ${Me.Ability[${SpellType[405]}].IsReady}
		call CastSpellRange 405 0 0 0 ${agroid} 0 0 1
	elseif ${Me.Ability[${SpellType[405]}].IsReady}
		call CastSpellRange 180 0 0 0 ${agroid} 0 0 1
	elseif ${Me.Ability[${SpellType[352]}].IsReady} && !${Actor[${agroid}].IsEpic} && ${agroid}!=${KillTarget}
		call CastSpellRange 352 0 0 0 ${agroid} 0 0 1

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

function CheckHeals()
{
	declare temphl int local 1
	declare tempgrp int local 1
	declare tempraid int local 1
	grpcnt:Set[${Me.GroupCount}]

	call UseCrystallizedSpirit 60
	call CommonHeals 40
	;oration of sacrifice heal
	do
	{
		;oration of sacrifice heal
		if !${MainTank} && ${Me.Ability[${SpellType[1]}].IsReady} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Health}<70 && !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.ToActor.Health}>75 && ${Me.Group[${temphl}].ToActor.Distance}<=20
		{
			EQ2Echo healing ${Me.Group[${temphl}].ToActor.Name}
			call CastSpellRange 1 0 0 0 ${Me.Group[${temphl}].ID} 0 0 1 0 2 0
		}
	}
	while ${temphl:Inc}<${grpcnt}

	;Res Fallen Groupmembers only if in range
	do
	{
		if ${Me.Group[${tempgrp}].ToActor.IsDead} && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady})
		{
			call CastSpellRange 300 301 1 0 ${Me.Group[${tempgrp}].ID}
			;short wait for accept
			wait 50
		}
	}
	while ${tempgrp:Inc}<${grpcnt}

	if ${Me.InRaid} && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady})
	{
		;Res Fallen RAID members only if in range
		do
		{
			if ${Me.Raid[${tempraid}].ToActor.IsDead} && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady}) && ${Me.Raid[${tempraid}].ToActor.Distance}<35
			{
				call CastSpellRange 300 301 1 0 ${Me.Raid[${tempraid}].ID}
				;short wait for accept
				wait 50
			}
		}
		while ${tempraid:Inc}<=24 && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady})
	}
}


function DoMagneticNote()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	grpcnt:Set[${Me.GroupCount}]

	if !${Me.Ability[${SpellType[383]}].IsReady}
		return

	EQ2:CreateCustomActorArray[byDist,${ScanRange},npc]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{

			
			if (${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID})  && (${CustomActor[${tcount}].Target.ID}!=${Actor[${MainTankPC}].ID})
			{
				call CastSpellRange 383 0 0 0 ${Actor[${MainTankPC}].ID} 0 0 0 0 1 0
				return
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}
}

function DoGravitas()
{
	variable int tVar
	variable string tTarget	
	variable string tTargetName
	variable string tClass
	
	if ${UIElement[lbBuffGravitas@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}==0 || !${Me.Ability[${SpellType[156]}].IsReady} || ${Me.Maintained[${SpellType[156]}](exists)}
		return

	;iterate through the members to cast gravitas on
	if ${UIElement[lbBuffGravitas@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0 && !${BuffGravitasListCurrent}
	{
		; Clear the current collection
		BuffGravitasTimers:Clear
		
		tVar:Set[1]
		do
		{
			tTarget:Set[${UIElement[lbBuffGravitas@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tVar}].Text}]
			tTargetName:Set[${tTarget.Token[1,:]}]
			tClass:Set[${Actor[${tTarget.Token[2,:]},${tTarget.Token[1,:]}].Class}]
			
				
			; Add All Selected Items to the Collection
			BuffGravitasTimers:Set[${tTargetName}|${tClass}, 0]

		}
		while ${tVar:Inc}<=${UIElement[lbBuffGravitas@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
		BuffGravitasListCurrent:Set[TRUE]

	}
	
	if ${BuffGravitasTimers.Used} > 0 
	{
		; Loop through all the Keys and process ONLY SHAMANS.
		if ${BuffGravitasTimers.FirstKey(exists)} && ${Me.Ability[${SpellType[156]}].IsReady}
		{
		  do
		  {
		    ; Check to see if the key is a SHAMAN if it is check the timer and if older than 120 sec.  Cast Gravitas on them
		    if ${BuffGravitasTimers.CurrentKey.Token[2,|].Equal[mystic]} || ${BuffGravitasTimers.CurrentKey.Token[2,|].Equal[defiler]}
		    {
		    	if ${Math.Calc[${Time.Timestamp} - ${BuffGravitasTimers.CurrentValue}]}>120
		    	{
		    		EQ2Execute /useabilityonplayer ${BuffGravitasTimers.CurrentKey.Token[1,|]} ${SpellType[156]}
						wait 5
		
						while ${Me.CastingSpell}
							wait 1
		
						if ${Me.Maintained[${SpellType[156]}](exists)}
						{
							if ${GravitasAnnounceText.Length}
								eq2execute /tell ${BuffGravitasTimers.CurrentKey.Token[1,|]} ${GravitasAnnounceText}
							BuffGravitasTimers:Set[${BuffGravitasTimers.CurrentKey}, ${Time.Timestamp}]
		  	  	}
		    	}
		    }
	  	}
	  	while ${BuffGravitasTimers.NextKey(exists)}
	 	; This makes sure we have a next key, and continues looping until we dont
	 	}
	 	
	 	; Loop through all the Keys and process ONLY CLERICS.
		if ${BuffGravitasTimers.FirstKey(exists)} && ${Me.Ability[${SpellType[156]}].IsReady}
		{
		  do
		  {
		    ; Check to see if the key is a CLERIC if it is check the timer and if older than 120 sec.  Cast Gravitas on them
		    if ${BuffGravitasTimers.CurrentKey.Token[2,|].Equal[templar]} || ${BuffGravitasTimers.CurrentKey.Token[2,|].Equal[inquisitor]}
		    {
		    	if ${Math.Calc[${Time.Timestamp} - ${BuffGravitasTimers.CurrentValue}]}>120
		    	{
		    		EQ2Execute /useabilityonplayer ${BuffGravitasTimers.CurrentKey.Token[1,|]} ${SpellType[156]}
						wait 5
		
						while ${Me.CastingSpell}
							wait 1
		
						if ${Me.Maintained[${SpellType[156]}](exists)}
						{
							if ${GravitasAnnounceText.Length}
								eq2execute /tell ${BuffGravitasTimers.CurrentKey.Token[1,|]} ${GravitasAnnounceText}
							BuffGravitasTimers:Set[${BuffGravitasTimers.CurrentKey}, ${Time.Timestamp}]
		  	  	}
		    	}
		    }
	  	}
	  	while ${BuffGravitasTimers.NextKey(exists)}
	 	; This makes sure we have a next key, and continues looping until we dont
	 	}
	 	
	 	; Loop through all the Keys and process ONLY DRUIDS.
		if ${BuffGravitasTimers.FirstKey(exists)} && ${Me.Ability[${SpellType[156]}].IsReady}
		{
		  do
		  {
		    ; Check to see if the key is a DRUID if it is check the timer and if older than 120 sec.  Cast Gravitas on them
		    if ${BuffGravitasTimers.CurrentKey.Token[2,|].Equal[warden]} || ${BuffGravitasTimers.CurrentKey.Token[2,|].Equal[fury]}
		    {
		    	if ${Math.Calc[${Time.Timestamp} - ${BuffGravitasTimers.CurrentValue}]}>120
		    	{
		    		EQ2Execute /useabilityonplayer ${BuffGravitasTimers.CurrentKey.Token[1,|]} ${SpellType[156]}
						wait 5
		
						while ${Me.CastingSpell}
							wait 1
		
						if ${Me.Maintained[${SpellType[156]}](exists)}
						{
							if ${GravitasAnnounceText.Length}
								eq2execute /tell ${BuffGravitasTimers.CurrentKey.Token[1,|]} ${GravitasAnnounceText}
							BuffGravitasTimers:Set[${BuffGravitasTimers.CurrentKey}, ${Time.Timestamp}]
		  	  	}
		    	}
		    }
	  	}
	  	while ${BuffGravitasTimers.NextKey(exists)}
	 	; This makes sure we have a next key, and continues looping until we dont
	 	}
	 	
	 	; Loop through all the Keys and process only those that are not Shamans, Clerics or Druids.
		if ${BuffGravitasTimers.FirstKey(exists)} && ${Me.Ability[${SpellType[156]}].IsReady}
		{
		  do
		  {
		    ; Check to see if the key is NOT A SHAMAN,CLERIC,DRUID if it is not then check the timer and if older than 120 sec.  Cast Gravitas on them
		    if ${BuffGravitasTimers.CurrentKey.Token[2,|].NotEqual[templar]} && ${BuffGravitasTimers.CurrentKey.Token[2,|].NotEqual[inquisitor]} && ${BuffGravitasTimers.CurrentKey.Token[2,|].NotEqual[warden]} && ${BuffGravitasTimers.CurrentKey.Token[2,|].NotEqual[fury]} && ${BuffGravitasTimers.CurrentKey.Token[2,|].NotEqual[mystic]} && ${BuffGravitasTimers.CurrentKey.Token[2,|].NotEqual[defiler]}
		    {
		    	if ${Math.Calc[${Time.Timestamp} - ${BuffGravitasTimers.CurrentValue}]}>120
		    	{
		    		EQ2Execute /useabilityonplayer ${${BuffGravitasTimers.CurrentKey}.Token[1,|]} ${SpellType[156]}
						wait 5
		
						while ${Me.CastingSpell}
							wait 1
		
						if ${Me.Maintained[${SpellType[156]}](exists)}
						{
							if ${GravitasAnnounceText.Length}
								eq2execute /tell ${${BuffGravitasTimers.CurrentKey}.Token[1,|]} ${GravitasAnnounceText}
							BuffGravitasTimers:Set[${BuffGravitasTimers.CurrentKey}, ${Time.Timestamp}]
		  	  	}
		    	}
		    }
	  	}
	  	while ${BuffGravitasTimers.NextKey(exists)}
	 	; This makes sure we have a next key, and continues looping until we dont
	 	} 	
	}
}

function StartHO()
{
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
		eq2execute /useability "Lucky Break"
}

function DoBladeDance()
{
	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388 0 0 0 ${KillTarget} 0 0 1 0 1 0
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			if ${BladeDanceAnnounceText.Length}
				eq2execute /gsay ${BladeDanceAnnounceText}
			BDStatus:Set[0]
		}
	}
}
function joust()
{
	if ${JoustStatus}==0 && ${RangedAttackOnlyMode}==1
	{
		;We've changed to in from an out status.
		RangedAttackOnlyMode:Set[0]
		EQ2Execute /toggleautoattack

		;if we're too far from killtarget, move in
		if ${Actor[${KillTarget}].Distance}>10 && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
			call CheckPosition 1 1
	}
	elseif ${JoustStatus}==1 && ${RangedAttackOnlyMode}==0 && !${Me.Maintained[${SpellType[388]}](exists)} && !${Me.Maintained[${SpellType[387]}](exists)}
	{
		;We've changed to out from an in status.
		;if aoe avoidance is up, use it
		if ${Me.Ability[${SpellType[388]}].IsReady}
		{
		if ${AnnounceMode}
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			call CastSpellRange 388 0 0 0 ${KillTarget} 0 0 0 0 1 0
		}
		elseif ${Me.Ability[${SpellType[387]}].IsReady}
			call CastSpellRange 387 0 1 0 ${KillTarget} 0 0 0 0 1 0
		else
		{
			RangedAttackOnlyMode:Set[1]
			EQ2Execute /togglerangedattack

			;if we're not at our healer, lets move to him
			call FindHealer

			echo Healer - ${return}
			if ${Actor[${return}].Distance}>2
				call FastMove ${Actor[${return}].X} ${Actor[${return}].Z} 1
		}
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed
	return
}