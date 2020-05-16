;*************************************************************
;Shadowknight.iss
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20161128
	;;;;

	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare StartHO bool script 1
	declare UseReaver bool script TRUE
	declare UseBattleLeadershipAABuff bool script FALSE
	declare UseFearlessMoraleAABuff bool script FALSE
	declare UseDeathMarch bool script FALSE
	declare UseMastersRage bool script TRUE
	declare HasMythical bool script FALSE
	declare InPostDeathRoutine bool script FALSE
	declare NumNPCs int script
	declare DoAEs bool script 
	declare UseUnholyHunger bool script TRUE
	declare UseUnholyStrength bool script TRUE
	declare AlwaysUseAEs bool script FALSE
	declare UseFeignDeath bool script FALSE
	declare TacticsTarget string script
	declare UsePactOfNatureSalveAbility bool script FALSE
	declare CheckGroupAggroTimer uint script 0

	declare BuffArmamentMember string script
	declare BuffTacticsGroupMember string script

	call EQ2BotLib_Init

	FullAutoMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Full Auto Mode,FALSE]}]
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDefensiveStance,TRUE]}]
	OffensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseOffensiveStance,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	UseReaver:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseReaver,TRUE]}]
	UseBattleLeadershipAABuff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseBattleLeadershipAABuff,FALSE]}]
	UseFearlessMoraleAABuff:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseFearlessMoraleAABuff,FALSE]}]
	UseDeathMarch:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseDeathMarch,FALSE]}]
	UseMastersRage:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseMastersRage,TRUE]}]
	UseUnholyHunger:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseUnholyHunger,TRUE]}]
	UseUnholyStrength:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseUnholyStrength,TRUE]}]
	AlwaysUseAEs:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[AlwaysUseAEs,FALSE]}]
	UseFeignDeath:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseFeignDeath,FALSE]}]

	BuffArmamentMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffArmamentMember,]}]
	BuffTacticsGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffTacticsGroupMember,]}]

	if ${Me.Level} < 58
		UIElement[UseDeathMarch@Class@EQ2Bot Tabs@EQ2 Bot]:ToggleVisible

	if ${Me.Equipment[Sedition, Sword of the Bloodmoon](exists)}
		HasMythical:Set[TRUE]

	Event[EQ2_FinishedZoning]:AttachAtom[Shadowknight_FinishedZoning]
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


	;; This has to be set WITHIN any 'if' block that uses the timer.
	;ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
	Event[EQ2_FinishedZoning]:DetachAtom[Shadowknight_FinishedZoning]
}

function Buff_Init()
{
   PreAction[1]:Set[Armament_Target]
   PreSpellRange[1,1]:Set[30]

   PreAction[2]:Set[Self_Buff1]
   PreSpellRange[2,1]:Set[25]

   PreAction[3]:Set[Self_Buff2]
   PreSpellRange[3,1]:Set[26]

   PreAction[4]:Set[Group_Buff1]
   PreSpellRange[4,1]:Set[20]

   PreAction[5]:Set[Group_Buff2]
   PreSpellRange[5,1]:Set[21]

   PreAction[6]:Set[Tactics_Target]
   PreSpellRange[6,1]:Set[31]

   PreAction[7]:Set[OffensiveMode]
   PreSpellRange[7,1]:Set[290]

   PreAction[8]:Set[DefensiveMode]
   PreSpellRange[8,1]:Set[295]

   PreAction[9]:Set[Reaver]
   PreSpellRange[9,1]:Set[334]

   PreAction[10]:Set[BattleLeadershipAABuff]
   PreSpellRange[10,1]:Set[336]

   PreAction[11]:Set[FearlessMoraleAABuff]
   PreSpellRange[11,1]:Set[337]

   PreAction[12]:Set[Bloodletter]
   PreSpellRange[12,1]:Set[331]

   PreAction[13]:Set[AuraOfLeadershipAABuff]
   PreSpellRange[13,1]:Set[341]
   
   PreAction[14]:Set[CShout]
   PreSpellRange[14,1]:Set[345]   
   
   PreAction[15]:Set[SubtleStrikes]
   PreSpellRange[15,1]:Set[349] 
}

function Combat_Init()
{
	;; This is no longer used
	return
}

function PostCombat_Init()
{
	return
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare ActorID uint local
	variable int temp

	if (!${InPostDeathRoutine} || !${CheckingBuffsOnce})
	{
		if ${ShardMode}
			call Shard
	}

	switch ${PreAction[${xAction}]}
	{
		case SubtleStrikes
			if (${Me.Group} > 2 && ${MainTank})
			{
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				break
			}
			if (${Me.Group} < 2)
				break
		
			if (!${MainTank})
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			else
			{
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
			}
			break

		case Armament_Target
			if (${Me.Group} > 2 || ${MainTank})
			{
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				break
			}
			if (${Me.Group} < 2)
				break
				
			variable string ArmamentTarget = ${UIElement[cbBuffArmamentGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}
			variable bool ArmamentTargetExists = FALSE
				
			if (${ArmamentTarget.Equal["No One"]} || ${ArmamentTarget.Length} == 0 || !${Actor[${ArmamentTarget.Token[2,:]},${ArmamentTarget.Token[1,:]}].Name(exists)})
			{
				;; if someone other than the SK is the MainTank, we can use that as a default
				ArmamentTarget:Set["${MainTankPC}:PC"]

				;; double-check				
				if (${Actor[${ArmamentTarget.Token[2,:]},${ArmamentTarget.Token[1,:]}].Name(exists)})
					ArmamentTargetExists:Set[TRUE]
			}
			else
				ArmamentTargetExists:Set[TRUE]
			
			Debug:Echo["EQ2Bot.SK-Debug:: ArmamentTarget is '${ArmamentTarget}'"]
				
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				if (${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID} != ${Actor[${ArmamentTarget.Token[2,:]},${ArmamentTarget.Token[1,:]},exactname].ID})
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
				else
					break
			}

			if ${ArmamentTargetExists}
			{
				ActorID:Set[${Actor[${ArmamentTarget.Token[2,:]},${ArmamentTarget.Token[1,:]},exactname].ID}]
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if ${Me.InRaid}
					{
						if (${Me.Raid[${ArmamentTarget.Token[1,:]}].InZone})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
					else
					{
						if (${Me.Group[${ArmamentTarget.Token[1,:]}].InZone})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
						wait 2
					}
				}
			}
			break

		case OffensiveMode
		    if ${OffensiveMode}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
		    }
		    else
		    {
    			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

		case DefensiveMode
		    if ${DefensiveMode}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
		    }
		    else
		    {
    			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		        Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

		case Self_Buff1
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		  	call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			break

		case Self_Buff2
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		  	call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			break


		case Group_Buff1
			if ${UseUnholyHunger}
			{
				if (!${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Zone.ShortName.Find[venril]} <= 0)
			  	call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case Group_Buff2
			if ${UseUnholyStrength}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			  	call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break


		case Tactics_Target
			variable bool TacticsTargetExists = FALSE	
			
			if (${Me.Group} < 2 || ${Me.Level} < 21)
			{
				UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].ItemByText["No One"]:Select
				TacticsTarget:Set[]
				break
			}
				
			if (${TacticsTarget.Length} == 0)
			{
				Debug:Echo["Tactics_Target:: TacticsTarget.Length == 0"]
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
					wait 20
				}
				
				if (${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text.Equal["No One"]} || ${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text.Length} == 0 || !${Actor[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text.Token[2,:]},${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text.Token[1,:]}](exists)})
				{
					Debug:Echo["Tactics_Target:: Invalid TacticsTarget -- setting automatically"]
					if (${MainTank})
					{
						if (${Me.Group[1].Type.Equal[Mercenary]})
							TacticsTarget:Set["${Me.Group[1].Name}:Mercenary"]
						else
							TacticsTarget:Set["${Me.Group[1].Name}:PC"]
					}
					else
						TacticsTarget:Set["${MainTankPC}:PC"]
						
						
          			UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot]:AddItem[${TacticsTarget}]
					UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].ItemByText[${TacticsTarget}]:Select
					Debug:Echo["Tactics_Target:: UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot]: '${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}'"]
				}			
				else
					TacticsTarget:Set[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]	
			}
			elseif (!${TacticsTarget.Equal[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]})
			{
				Debug:Echo["Tactics_Target:: ${TacticsTarget} != ${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}"]
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
					wait 20
				}
				TacticsTarget:Set[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				
				if (!${Actor[${TacticsTarget.Token[2,:]},${TacticsTarget.Token[1,:]}].Name(exists)})
				{
					if (${MainTank})
					{
						if (${Me.Group[1].Type.Equal[Mercenary]})
							TacticsTarget:Set["${Me.Group[1].Name}:Mercenary"]
						else
							TacticsTarget:Set["${Me.Group[1].Name}:PC"]
					}
					else
						TacticsTarget:Set["${MainTankPC}:PC"]
						
					UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot]:AddItem[${TacticsTarget}]
					UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].ItemByText[${TacticsTarget}]:Select
					Debug:Echo["Tactics_Target:: UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot]: '${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}'"]
				}					
			}
			else	
			{
				;Debug:Echo["Tactics_Target::  Tactics is already set and the correct group member has the buff ...breaking (TacticsTarget is '${TacticsTarget}')"]
				;TacticsTarget:Set[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				break
			}
				
			Debug:Echo["Tactics_Target:: TacticsTarget is '${TacticsTarget}' ...casting"]
			
			if (${Actor[${TacticsTarget.Token[2,:]},${TacticsTarget.Token[1,:]}].Name(exists)})
				TacticsTargetExists:Set[TRUE]
			else
			{
				if (${MainTank})
				{
					if (${Me.Group[1].Type.Equal[Mercenary]})
						TacticsTarget:Set["${Me.Group[1].Name}:Mercenary"]
					else
						TacticsTarget:Set["${Me.Group[1].Name}:PC"]
				}
				else
					TacticsTarget:Set["${MainTankPC}:PC"]
				
				UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot]:AddItem[${TacticsTarget}]
				UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].ItemByText[${TacticsTarget}]:Select
			}
			
			if (${Actor[${TacticsTarget.Token[2,:]},${TacticsTarget.Token[1,:]}].Name(exists)})
				TacticsTargetExists:Set[TRUE]
			else
			{
				; give up
				TacticsTargetExists:Set[FALSE]
				TacticsTarget:Set[]
				UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].ItemByText["No one"]:Select
			}
			
			ActorID:Set[${Actor[${TacticsTarget.Token[2,:]},${TacticsTarget.Token[1,:]},exactname].ID}]
			
			if (${Actor[${ActorID}].Distance} > ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range})
			{
				Debug:Echo["Tactics_Target:: '${TacticsTarget.Token[1,:]}' is out-of-range ....giving up."]
				TacticsTargetExists:Set[FALSE]
				TacticsTarget:Set[]
				UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].ItemByText["No one"]:Select
			}
			
			Debug:Echo["Tactics_Target:: Checking... '${TacticsTargetExists}' && '${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}'"]
			if (${TacticsTargetExists} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				Debug:Echo["Tactics_Target:: TacticsTargetExists and spell is not being currently maintained."]
				
				if ${Actor[${ActorID}].Type.Equal[PC]}
				{
					if ${Me.InRaid}
					{
						if (${Me.Raid[${TacticsTarget.Token[1,:]}].InZone})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								do 
								{
									waitframe
									Debug:Echo["waiting..."]
								}
								while !${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
								
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
					else
					{
						if (${Me.Group[${TacticsTarget.Token[1,:]}].InZone})
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
							{
								do 
								{
									waitframe
									Debug:Echo["waiting..."]
								}
								while !${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
								wait 2
							}
						}
					}
				}
				else
				{
					if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].ToAbilityInfo.Range} || !${NoAutoMovement})
					{
						do 
						{
							waitframe
							Debug:Echo["waiting..."]
						}
						while !${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1
						wait 2
					}
				}
			}
			break

		case Reaver
		    if ${UseReaver}
		    {
					if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
			     	call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
		    }
		    else
		    {
		        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		            Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

	    case BattleLeadershipAABuff
		    if ${UseBattleLeadershipAABuff}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
		    }
		    else
		    {
		        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		            Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

	    case FearlessMoraleAABuff
		    if ${UseFearlessMoraleAABuff}
		    {
    			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    		    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
    		    }
		    }
		    else
		    {
		        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
		            Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
		    }
			break

		case AuraOfLeadershipAABuff
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			    {
				    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
				        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			    }
			}
		  break

		case CShout
			if (${MainTank})
			{
				if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
				{
					if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				    {
					    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
					        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
				    }
				}
			}
		  break		  

		case Bloodletter
		  if ${Me.Level} < 80
		  	break
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.Maintained[${SpellType[295]}](exists)}
			{
			    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady})
			        call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},1]} 0 0 ${Me.ID}
			}
			break

		Default
			return BuffComplete
	}

}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, uint TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	variable bool bReturn
	variable string sReturn

	;; Notes:
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;

	if (${Me.IsRooted} || !${Me.CanTurn})
	{
		if ${Me.Ability[${SpellType[339]}].IsReady}
		{
			call CastSpellRange 339 0 0 0 ${Me.ID} 0 0 0 1
		}
	}

	if (${TargetID} != ${Me.ID})
	{
		call VerifyTarget ${TargetID} "SK-_CastSpellRange-${SpellType[${start}]}"
		if ${Return.Equal[FALSE]}
			return CombatComplete
	}

	;; we should actually cast the spell we wanted to cast originally before doing anything else
	LastSpellCast:Set[${start}]
	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	bReturn:Set[${Int[${Return}]}]


	return ${bReturn}
}

function Combat_Routine(int xAction)
{
	variable index:actor Actors
	variable iterator ActorIterator
	declare BuffTarget string local
	declare TankToTargetDistance float local
	declare KillTargetIsSoloMob bool local
	
	KillTargetIsSoloMob:Set[${Actor[${KillTarget}].IsSolo}]

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	call CheckGroupOrRaidAggro

	if ${DoHOs}
		objHeroicOp:DoHO

	if ${StartHO}
	{
		if !${EQ2.HOWindowActive}
			call CastSpellRange 303
	}

	if !${NoAutoMovementInCombat} && !${NoAutoMovement} && ${AutoMelee}
	{
		if ${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]}
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			Debug:Echo["Combat_Routine():: TankToTargetDistance: ${TankToTargetDistance}"]

			if (${MainTank} || ${TankToTargetDistance} <= 7.5)
				call CheckPosition 1 0 ${KillTarget}
		}
	}

	;; uncomment for venril fight
	;if (${Zone.ShortName.Find[venril]} > 0)
	;{
	;	if (${Me.Power} <= 47)
	;	{
	;		do
	;		{
	;			waitframe
	;		}
	;		while ${Me.Power} < 49
	;	}
  	;}

	if (${Me.IsRooted} || !${Me.CanTurn})
	{
    	if ${Me.Ability[${SpellType[339]}].IsReady}
    	{
      		call CastSpellRange 339 0 0 0 ${Me.ID} 0 0 0 1
    	}
	}

	;; AE Taunt and Debuff
	if ${PBAoEMode} && !${KillTargetIsSoloMob}
	{
		if ${MainTank}
		{
			;; Blasphemy
			if (${Me.Ability[${SpellType[170]}].IsReady})
			{
				call _CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
	}

	;; Siphon Strength (Always cast this when it is ready!)
  	if (!${KillTargetIsSoloMob} && ${Me.Ability[${SpellType[80]}].IsReady})
  	{
    	call _CastSpellRange 80 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	
	;; Swift Attack
  	if (${Me.Ability[${SpellType[381]}].IsReady})
  	{
    	call _CastSpellRange 381 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}

	call CheckHeals
	call CheckGroupOrRaidAggro

	DoAEs:Set[FALSE]
	if ${PBAoEMode}
	{
		if ${AlwaysUseAEs}
			DoAEs:Set[TRUE]
		else
		{
			EQ2:QueryActors[Actors, (Type =- "NPC" || Type =- "NamedNPC") && Distance <= 10]
		  	NumNPCs:Set[${Actors.Used}]
		  	DoAEs:Set[FALSE]
		  	if ${NumNPCs} > 2
		  		DoAEs:Set[TRUE]
		  	elseif ${Actor[${KillTarget}].IsEpic}
		  		DoAEs:Set[TRUE]
		  	elseif ${Actor[${KillTarget}].IsHeroic}
			{
				if ${Actor[${KillTarget}].Difficulty} >= 2
				{
					switch ${Actor[${KillTarget}].ConColor}
					{
						case Red
						case Orange
						case Yellow
						case White
							DoAEs:Set[TRUE]
							break
						default
							break
					}
				}
			}
		}
	}
	
	;; DeathMarch
	if (${UseDeathMarch} && ${Me.Ability[${SpellType[312]}].IsReady})
	{
		;;;;
		;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
		call VerifyTarget ${KillTarget} "SK-Combat-DeathMarch"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call _CastSpellRange 312 0 0 0 ${Me.ID} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
  
  	;; Self Reverse DS (with life tap proc)
	if ((!${KillTargetIsSoloMob} && ${Me.Ability[${SpellType[7]}].IsReady}) || (${MainTank} && ${Me.Health}<25))
	{
		if ${MainTank}
		{
			call VerifyTarget ${KillTarget} "SK-Combat-UnholyBlessing"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 7 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
		else
		{
			call VerifyTarget ${KillTarget} "SK-Combat-UnholyBlessing"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call CastSpellRange 7 0 0 0 ${MainTankID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
	}

	call CheckHeals
	call CheckGroupOrRaidAggro

	if ${DoAEs}
  	{
  		;; AE Taunt
    	if (${Me.Ability[${SpellType[340]}].IsReady})
    	{
    		;Debug:Echo["${SpellType[340]}..."]
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-HatefulRespite"
			if ${Return.Equal[FALSE]}
				return CombatComplete
	    	call _CastSpellRange 340 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}  
		elseif (${Me.Ability[${SpellType[170]}].IsReady})
    	{
    		;; Blaphemy
	    	call _CastSpellRange 170 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}
    
		;; MIST -- should be casted after AE taunt at the beginning of the fight  (Physical damage mit debuff)
    	if (${Me.Ability[${SpellType[55]}].IsReady})
    	{	
      		call _CastSpellRange 55 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
  		}   	
  		;; Grave Sacrament
    	if (${MainTank} && ${Me.Ability[${SpellType[45]}].IsReady})
    	{
    		;Debug:Echo["${SpellType[45]}..."]
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-GraveSacrament"
			if ${Return.Equal[FALSE]}
				return CombatComplete
	    	call _CastSpellRange 45 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}    	
  		;; Tap Veins
    	if (${Me.Ability[${SpellType[98]}].IsReady})
    	{
    		;Debug:Echo["${SpellType[98]}..."]
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-TapVeins"
			if ${Return.Equal[FALSE]}
				return CombatComplete
	    	call _CastSpellRange 98 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}

		call CheckHeals

		;; Zealous Smite
		if (${Me.Ability[${SpellType[508]}].IsReady})
		{
			;echo "${SpellType[508]}..."
			call _CastSpellRange 508 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}	
		;; Lance
		if ${Me.Ability[${SpellType[347]}](exists)}
		{
			;Debug:Echo["${SpellType[347]}..."]
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-Lance"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			if (${Me.Ability[${SpellType[347]}].IsReady})
			{
				call _CastSpellRange 347 0 0 0 ${Me.ID} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
		;hammer ground stun
		if !${Actor[${KillTarget}].IsEpic}
		{
			if (${Me.Ability[${SpellType[505]}].IsReady})
	    	{
				;;;;
				;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
				call VerifyTarget ${KillTarget} "SK-Combat-HammerGround"
				if ${Return.Equal[FALSE]}
					return CombatComplete
		   	 	call _CastSpellRange 505 0 0 0 ${Me.ID} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
		if ${NumNPCs} > 3
		{
			;; Pestilence
			if (${Me.Ability[${SpellType[99]}].IsReady})
			{					
				;Debug:Echo["${SpellType[99]}..."]
				call _CastSpellRange 99 0 0 0 ${KillTarget} 0 0 0 1
				if ${Return.Equal[CombatComplete]}
					return CombatComplete
			}
		}
		;; Doom Judgement
		if (${Me.Ability[${SpellType[97]}].IsReady})
		{
			;Debug:Echo["${SpellType[97]}..."]
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-DoomJudgement"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call _CastSpellRange 97 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}

		call CheckHeals
		
		;; Death Cloud
		if (${Me.Ability[${SpellType[95]}].IsReady})
		{
			;Debug:Echo["${SpellType[95]}..."]
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-DeathCloud"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call _CastSpellRange 95 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}		
		;; Unending Agony
		if (${Me.Ability[${SpellType[96]}].IsReady})
		{
			;echo "${SpellType[96]}..."
			;;;;
			;; Note:  _CastSpellRange() does not call VerifyTarget when the TargetID is ${Me.ID}
			call VerifyTarget ${KillTarget} "SK-Combat-UnendingAgony"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			call _CastSpellRange 96 0 0 0 ${Me.ID} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
		}			
	}	
  
	;Essence Siphon
	if ${Me.Ability[${SpellType[503]}].IsReady}
	{
		call _CastSpellRange 503 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	
	;; Divine Aura
	if ${Me.Health}<70 && ${Me.Ability[${SpellType[502]}].IsReady}
	{
		Debug:Echo["\arHealth < 70% -- Casting Divine Aura!\ax"]
		call VerifyTarget ${KillTarget} "SK-Combat-DivineAura"
		if ${Return.Equal[FALSE]}
			return CombatComplete
		call CastSpellRange 502 
	}

	call CheckGroupOrRaidAggro

	;; SK's Furor
	if ${Me.Health}<=60 && ${Me.Ability[${SpellType[507]}].IsReady}
		call CastSpellRange 507

  	;;;;;
	;;; Quick Spells for aggro
	; Hateful Slam (shield bash)
  	if (${Me.Ability[${SpellType[240]}].IsReady})
  	{
    	call _CastSpellRange 240 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	; Insidious Whisper
	if (${MainTank} && ${Me.Ability[${SpellType[160]}].IsReady})
  	{
    	call _CastSpellRange 160 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;;
	;;;;

  	call CheckPower
  	call CheckHeals
	call CheckGroupOrRaidAggro

  	if ${UseMastersRage}
  	{
		if ${Me.Ability["Master's Rage"].IsReady}
		{
			call VerifyTarget ${KillTarget} "SK-Combat-MastersRage"
			if ${Return.Equal[FALSE]}
				return CombatComplete
			Target ${KillTarget}
			Me.Ability["Master's Rage"]:Use
			do
			{
			 	waitframe
			}
			while ${Me.CastingSpell}
			wait 1
		}
  	}

  	;; Combat Leadership AA
  	;; NOTE:  Removing this for now -- I do not think it is worth the effort...
	;if ${Me.Ability[${SpellType[333]}](exists)}
	;{
	;    if (${Me.Ability[${SpellType[333]}].IsReady} && ${Zone.ShortName.Find[venril]} <= 0)
	;    {
	;		call VerifyTarget ${KillTarget} "SK-Combat-CombatLeadership"
	;		if ${Return.Equal[FALSE]}
	;			return CombatComplete
	;	    call CastSpellRange 333 0 0 0 ${Me.ID}
	;	}
	;}
	
	;;;; DPS Lineup
	;; Shadow Coil (dmg + dot)
	if (${Me.Ability[${SpellType[60]}].IsReady})
  	{
    	call _CastSpellRange 60 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Dreadful Wrath (dmg)
	if (${Me.Ability[${SpellType[154]}].IsReady})
  	{
    	call _CastSpellRange 154 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}		
	;; Devour Vitae (dmg, + heal)
	if (${Me.Ability[${SpellType[153]}].IsReady})
  	{
    	call _CastSpellRange 153 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}	

	call CheckHeals
	call CheckGroupOrRaidAggro

	;; Mana Sieve (dmg + DoT + power tap)
	if (${Me.Ability[${SpellType[81]}].IsReady})
  	{
    	call _CastSpellRange 81 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}			
	;; Joust (dmg)
	if (${Me.Ability[${SpellType[344]}].IsReady} && ${Actor[${KillTarget}].Distance} <= 7)
  	{
    	call _CastSpellRange 344 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}		
	;; Malice (dmg)
	if (${Me.Ability[${SpellType[62]}].IsReady})
  	{
    	call _CastSpellRange 62 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}	

	call CheckHeals
	call CheckGroupOrRaidAggro

	;; Siphon Strike (dmg, + dot)
	if (${Me.Ability[${SpellType[61]}].IsReady})
  	{
    	call _CastSpellRange 61 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Legionnaire's Smite (dmg)
	if (${Me.Ability[${SpellType[332]}].IsReady})
  	{
    	call _CastSpellRange 332 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Painbringer (low dmg)
	if (${Me.Ability[${SpellType[150]}].IsReady})
  	{
    	call _CastSpellRange 150 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}

	call CheckHeals
	call CheckGroupOrRaidAggro

	;; Soulrend (low dmg + knockdown)
	if (${Me.Ability[${SpellType[151]}].IsReady})
  	{
    	call _CastSpellRange 151 0 0 0 ${KillTarget}
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
	}
	;; Cleave Flesh (WIS debuff + dmg)
  	if (${Me.Ability[${SpellType[152]}].IsReady})
  	{
    	call _CastSpellRange 152 0 0 0 ${KillTarget} 0 0 0 1
		if ${Return.Equal[CombatComplete]}
			return CombatComplete
  	}
	;; Strike of Consistency
	if (${Me.Level} < 20)
	{
		if (${Me.Ability[${SpellType[348]}].IsReady})
	  	{
	    	call _CastSpellRange 348 0 0 0 ${KillTarget} 0 0 0 1
			if ${Return.Equal[CombatComplete]}
				return CombatComplete
	  	}
	}

	call CheckHeals
	call CheckGroupOrRaidAggro

	CurrentAction:Set[Combat :: CombatComplete]
	return CombatComplete
}

function Post_Combat_Routine(int xAction)
{
	CheckGroupAggroTimer:Set[0]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function CheckGroupOrRaidAggro()
{
	;; Call this function a maximum of one time each second while in combat mode.  Otherwise, a maximum of once every 5 seconds.
	if (${CheckGroupAggroTimer} > 0)
	{
		if (${Me.InCombatMode})
		{
			if (${Time.SecondsSinceMidnight} <= ${Math.Calc[${CheckGroupAggroTimer}+1]})
				return 0
		}
		else
		{
			if (${Time.SecondsSinceMidnight} <= ${Math.Calc[${CheckGroupAggroTimer}+5]})
				return 0
		}
	}

	variable index:actor Actors
	variable iterator ActorIterator
	variable uint MobTargetID 
	variable bool DebugEnabled = ${Debug.Enabled}
	variable bool DebugThisFunction = TRUE
	if (${DebugThisFunction} && !${DebugEnabled})
		Debug:Enable

	;; For now, do not do anything automatically when we are not maintank
	if (!${MainTank})
	{
		CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
		if (!${DebugEnabled} && ${DebugThisFunction})
			Debug:Disable
		return 0
	}

	if (${Me.IsDead})
	{
		Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax I am dead..."]
		CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
		if (!${DebugEnabled} && ${DebugThisFunction})
			Debug:Disable
		return 0
	}
	        
	EQ2:QueryActors[Actors, (Type =- "NPC" || Type =- "NamedNPC") && Distance <= 10]
	Actors:GetIterator[ActorIterator]
	NumNPCs:Set[${Actors.Used}]

	if ${ActorIterator:First(exists)}
	{
		Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Checking ${NumNPCs} NPCs..."]
		do
		{
			if (!${ActorIterator.Value.IsSolo} || ${NumNPCs} > 2)
			{
				if (${ActorIterator.Value.Target.Name(exists)} && !${ActorIterator.Value.Target.Name.Equal[${MainTankPC}]})
				{
					if ${Me.InRaid}
					{
						if (${Me.Raid[${ActorIterator.Value.Target.Name}].InZone})
						{
							if (!${ActorIterator.Value.Target.Name.Equal[${MainTankPC}]})
							{
								MobTargetID:Set[${ActorIterator.Value.Target.ID}]
								call IsFighter ${MobTargetID}
								if (${Return.Equal[FALSE]} && ${MobTargetID} != ${Me.ID})
								{
									;Debug:Echo["Return = FALSE - ActorIterator.Value.Target.Health: ${ActorIterator.Value.Target.Health}"]
									if ${Actor[${MobTargetID}].Health} < 85
									{
										if (${HasMythical})
										{
											if (${Me.Equipment[Sedition, Sword of the Bloodmoon].IsReady})
											{
												Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Using Mythical on ${Actor[${MobTargetID}]}!"]
												ActorIterator.Value:DoTarget
												wait 2
												Me.Equipment[Sedition, Sword of the Bloodmoon]:Use
												wait 5
												if (!${DebugEnabled} && ${DebugThisFunction})
													Debug:Disable
												CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
												return 1
											}
										}
										if ${Me.Ability[${SpellType[320]}].IsReady}
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Rescuing ${Actor[${MobTargetID}]}!"]
											call CastSpellRange 320 0 0 0 ${MobTargetID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
										elseif ${Me.Ability[${SpellType[338]}].IsReady}
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Sneering ${Actor[${MobTargetID}]}!"]
											call CastSpellRange 338 0 0 0 ${MobTargetID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
										elseif (${UseFeignDeath} && ${Me.Ability[${SpellType[330]}].IsReady})
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Feigning ${Actor[${MobTargetID}]}!"]
											call CastSpellRange 330 0 0 0 ${MobTargetID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
									}
									if ${Me.Ability[${SpellType[270]}].IsReady}
									{
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Casting 'Intercept' (line) on ${Actor[${MobTargetID}]}"]
										call CastSpellRange 270 0 0 0 ${MobTargetID} 0 0 0 1
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
										if (!${DebugEnabled} && ${DebugThisFunction})
											Debug:Disable
										CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
										return 1
									}
									if ${Me.Ability[${SpellType[160]}].IsReady}
									{
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Taunting ${ActorIterator.Value}"]
										call CastSpellRange 160 0 0 0 ${ActorIterator.Value.ID} 0 0 0 1
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
										if (!${DebugEnabled} && ${DebugThisFunction})
											Debug:Disable
										CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
										return 1
									}
									if !${Me.Maintained[${SpellType[240]}](exists)}
									{
										if ${Me.Ability[${SpellType[240]}].IsReady}
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Casting 'Knock Down' (line) on ${ActorIterator.Value}"]
											call CastSpellRange 240 0 0 0 ${ActorIterator.Value.ID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
									}
								}
								if (!${DebugEnabled} && ${DebugThisFunction})
									Debug:Disable
								CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
								return 0
							}
						}
					}
					else
					{
						if (${Me.Group[${ActorIterator.Value.Target.Name}].Health(exists)} && ${Me.Group[${ActorIterator.Value.Target.Name}].InZone})
						{
							Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is ${ActorIterator.Value.Target.Name} (MainTankPC is ${MainTankPC})"]
							if (!${ActorIterator.Value.Target.Name.Equal[${MainTankPC}]})
							{
								MobTargetID:Set[${ActorIterator.Value.Target.ID}]
								call IsFighter ${MobTargetID}
								if (${Return.Equal[FALSE]} && ${MobTargetID} != ${Me.ID})
								{
									;Debug:Echo["Return = FALSE - ActorIterator.Value.Target.Health: ${ActorIterator.Value.Target.Health}"]
									if ${Actor[${MobTargetID}].Health} < 80
									{
										if (${HasMythical})
										{
											if (${Me.Equipment[Sedition, Sword of the Bloodmoon].IsReady})
											{
												Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Using Mythical on ${Actor[${MobTargetID}]}!"]
												ActorIterator.Value:DoTarget
												wait 2
												Me.Equipment[Sedition, Sword of the Bloodmoon]:Use
												wait 5
												if (!${DebugEnabled} && ${DebugThisFunction})
													Debug:Disable
												CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
												return 1
											}
										}
										if ${Me.Ability[${SpellType[320]}].IsReady}
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Rescuing ${Actor[${MobTargetID}]}!"]
											call CastSpellRange 320 0 0 0 ${MobTargetID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
										elseif ${Me.Ability[${SpellType[338]}].IsReady}
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Sneering ${Actor[${MobTargetID}]}!"]
											call CastSpellRange 338 0 0 0 ${MobTargetID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
										elseif (${UseFeignDeath} && ${Me.Ability[${SpellType[330]}].IsReady})
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Feigning ${Actor[${MobTargetID}]}!"]
											call CastSpellRange 330 0 0 0 ${MobTargetID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
									}
									if ${Me.Ability[${SpellType[270]}].IsReady}
									{
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Casting 'Intercept' (line) on ${Actor[${MobTargetID}]}"]
										call CastSpellRange 270 0 0 0 ${MobTargetID} 0 0 0 1
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
										if (!${DebugEnabled} && ${DebugThisFunction})
											Debug:Disable
										CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
										return 1
									}
									if ${Me.Ability[${SpellType[160]}].IsReady}
									{
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Taunting ${ActorIterator.Value}"]
										call CastSpellRange 160 0 0 0 ${ActorIterator.Value.ID} 0 0 0 1
										Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
										if (!${DebugEnabled} && ${DebugThisFunction})
											Debug:Disable
										CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
										return 1
									}
									if !${Me.Maintained[${SpellType[240]}](exists)}
									{
										if ${Me.Ability[${SpellType[240]}].IsReady}
										{
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax Casting 'Knock Down' (line) on ${ActorIterator.Value}"]
											call CastSpellRange 240 0 0 0 ${ActorIterator.Value.ID} 0 0 0 1
											Debug:Echo["\at\[SK-CheckGroupOrRaidAggro\]\ax ${ActorIterator.Value}'s target is now ${ActorIterator.Value.Target.Name}"]
											if (!${DebugEnabled} && ${DebugThisFunction})
												Debug:Disable
											CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
											return 1
										}
									}
								}
								if (!${DebugEnabled} && ${DebugThisFunction})
									Debug:Disable
								CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
								return 0
							}
						}
					}
				}
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	if (!${DebugEnabled} && ${DebugThisFunction})
		Debug:Disable
	CheckGroupAggroTimer:Set[${Time.SecondsSinceMidnight}]
	return 0
}

function FeignDeath()
{
  if ${Me.Ability[${SpellType[330]}].IsReady}
  {
    CurrentAction:Set[Casting Feign Death!]
    call CastSpellRange 330 0 0 0 ${Me.ID} 0 0 0 1
  }
}

function HarmTouch()
{
	;; Cast Harmtouch on current KillTarget
	if ${Me.Ability[${SpellType[63]}].IsReady}
	{
		CurrentAction:Set[Combat :: Casting Harm Touch!]
		call CastSpellRange 63 0 0 0 ${KillTarget} 0 0 0 1
	}
}

function Have_Aggro()
{
}

function Lost_Aggro(uint mobid)
{
  	call CheckGroupOrRaidAggro
  	return
}

function MA_Lost_Aggro()
{
}

function MA_Dead()
{
	MainTank:Set[TRUE]
	MainAssist:Set[${Me.Name}]
	KillTarget:Set[]
}

function Cancel_Root()
{
}

function CheckHeals()
{
	variable int temphl = 0
	variable bool CastSalve = FALSE
	variable bool bReturn
	bReturn:Set[FALSE]

	;;;;; Salve (granted by Fury's "Pact of Nature" ability)
	;; TODO:  Add option to set UsePactOfNatureSalveAbility in UI.  For now, it's hard-coded in the initialization routine earlier in this file
	if (${UsePactOfNatureSalveAbility} && ${Me.Ability[id,1369045398].IsReady})
	{
		echo "[${Time.SecondsSinceMidnight}]\ao Checking for Heals/Cures\ax"
		do
		{
			if (${Me.Group[${temphl}].InZone} && !${Me.Group[${temphl}].IsDead})
			{
				if (${Me.Group[${temphl}].Arcane} >= 1 || ${Me.Group[${temphl}].Elemental} >= 1 || ${Me.Group[${temphl}].Noxious} >= 1 || ${Me.Group[${temphl}].Trauma} >= 1)
					CastSalve:Set[TRUE]
				elseif (${Me.Group[${temphl}].Health} <= 75)
					CastSalve:Set[TRUE]

				if (${CastSalve})
				{
					echo "\ayCasting Salve!\ax"
					if ${Me.CastingSpell}
					{
						do
						{
							eq2execute /cancel_spellcast
							wait 2
						}
						while ${Me.CastingSpell}
					}
					wait 2
					eq2execute /useabilityonplayer ${Me.Name} Salve
					wait 2
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					bReturn:Set[TRUE]
					waitframe
					break
				}
			}
		}
		while ${temphl:Inc} <= ${Me.Group}
	}
	return ${bReturn}
}

function CheckPower()
{
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed
	variable int i
	InPostDeathRoutine:Set[TRUE]

	;;;;;;;;;;;;;;;
	;; Do Buffs before anything else if NOT MainTank
	if !${MainTank}
	{
		i:Set[1]
		do
		{
			call Buff_Routine ${i}
			if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
				break
			call ProcessTriggers
			wait 2
		}
		while ${i:Inc}<=40

		if (${UseCustomRoutines})
		{
			i:Set[1]
			do
			{
				call Custom__Buff_Routine ${i}
				if ${Return.Equal[BuffComplete]} || ${Return.Equal[Buff Complete]}
					break
			}
			while ${i:Inc} <= 40
		}
		;;
		;;;;;;;;;;;;;;;
	}
	;; TODO:  Otherwise just do our really fast casting buffs!  (ie, stance, etc.)

	InPostDeathRoutine:Set[FALSE]
	return
}

atom(script) Shadowknight_FinishedZoning(string TimeInSeconds)
{
	if ${KillTarget} && ${Actor[${KillTarget}].Name(exists)}
	{
		if !${Actor[${KillTarget}].InCombatMode}
			KillTarget:Set[0]
	}
}