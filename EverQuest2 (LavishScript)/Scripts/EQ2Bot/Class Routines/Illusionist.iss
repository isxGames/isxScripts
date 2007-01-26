;===============================================================================;
;Illusionist Plugin for Blazers EQ2Bot (Modified from Enchanter)		;
;										;
;TODO: Temporary Pets, Better HO Handeling (and Complete database),		;
; Better Mez Handeling, More AutoHunt Flags, Anti-Agro			 	;
;										;
;	By Mandrake								;
;===============================================================================;

function Class_Declaration()
{
	declare PetTarget int script
	declare PetEngage bool script

	;===============================================;
	;CurState variable for display on the UI	;
	;===============================================;

	declare CurState string script

	;===============================================================;
	;Trigger for Heroic Ops... Should be moved to main eq2bot	;
	;===============================================================;

	AddTrigger hoact HEROICOPPORTUNITY::@state@
	
	;===============================================================;
	;Check to see if class specific settings are set		;
	;If not, populate with defaults					;
	;===============================================================;

	if !${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[bool1].GetString[Name](exists)}
		{
		echo "Setting Defaults"
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[bool1]:Set[Name,"Use Pet"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[bool1]:Set[Value,"0"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1]:Set[Name,"Mez Type"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1]:Set[Value,"Everything"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1].Set[Values]:Set[val1,"Everything"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1].Set[Values]:Set[val2,"Protective"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1].Set[Values]:Set[val3,"Nothing"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1].Set[Values]:Set[val4,"Old"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Slider1]:Set[Value,"0"]
		SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Slider1]:Set[Name,"Nuke Power"]
		}

	;===============================================================;
	;Load the EQ2 Interface peices first				;
	;Then Load up the actual UI					;
	;===============================================================;

	ui -reload interface/eq2skin.xml
	ui -reload -skin eq2skin scripts/EQ2Bot/UI/eq2bot.xml
	;=======================================;
	;Set the window Title to player name	;
	;=======================================;
	Windowtext ${Me.Name}(${Session})

}

function Buff_Init()
{
	CurState:Set["Buffing: Self buffs"]
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]

	CurState:Set["Buffing: Group Buffs"]
	PreAction[2]:Set[Group_Buff_Conc]
	PreSpellRange[2,1]:Set[20]
	PreSpellRange[2,2]:Set[22]

	PreAction[3]:Set[Group_Buff]
	PreSpellRange[3,1]:Set[280]

	;===============================================================;
	;Check to see if we are using pets first			;
	;Do this BEFORE casting haste buffs, to save concentration	;
	;Otherwise /pet get lost					;
	;===============================================================;
	CurState:Set["Buffing: Pet"]
	if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[bool1].GetInt[Value]}
		{
		PreAction[4]:Set[Summon_Pet]
		PreSpellRange[4,1]:Set[355]
		} 
	else
		{
		;===============================================================;
		;Kill the pet to make room for other buffs			;
		;===============================================================;
		PreAction[4]:Set[Kill_Pet]
		}

	PreAction[5]:Set[Haste_Buff]
	PreSpellRange[5,1]:Set[354]
	
	PreAction[6]:Set[Caster_Buff]
	PreSpellRange[6,1]:Set[363]
}

function Combat_Init()
{
	Action[1]:Set[Mezmerise]

	Action[2]:Set[Pet_Attack]
	PetEngage:Set[FALSE]
	
	Action[3]:Set[Debuff]
	MobHealth[3,1]:Set[30]
	MobHealth[3,2]:Set[100]
	SpellRange[3,1]:Set[50]
	SpellRange[3,2]:Set[80]

	Action[4]:Set[Mezmerise]	
	
	Action[5]:Set[AoE]
	SpellRange[5,1]:Set[90]
	SpellRange[5,2]:Set[91]

	Action[6]:Set[Summon_Pet] 
	MobHealth[6,1]:Set[50] 
	MobHealth[6,2]:Set[100] 
	SpellRange[6,1]:Set[329] 
	
	Action[7]:Set[Dot]
	MobHealth[7,1]:Set[30]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[70]
	SpellRange[7,2]:Set[71]

	Action[8]:Set[Mezmerise]
	
	Action[9]:Set[Combat_Buff]
	MobHealth[9,1]:Set[50]
	MobHealth[9,2]:Set[100]
	SpellRange[9,1]:Set[384]

	Action[10]:Set[Nuke_Attack]
	SpellRange[10,1]:Set[60]
	SpellRange[10,2]:Set[61]
	SpellRange[10,3]:Set[155]

	Action[11]:Set[Self_Power]
	SpellRange[11,1]:Set[309]
	
	Action[12]:Set[Stun_Power_Drain]
	MobHealth[12,1]:Set[30]
	MobHealth[12,2]:Set[100]
	SpellRange[12,1]:Set[190]
}

function PostCombat_Init()
{
	CurState:Set["PostCombat: Healing"]
	PostAction[1]:Set[Heal_Wait]
}

function Buff_Routine(int xAction)
{
	CurState:Set["Buffing: ${PreAction[${xAction}]}"]
	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
			
		case Group_Buff_Conc
			if ${Me.UsedConc}<5
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
			
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
	
		case Haste_Buff
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.UsedConc}<5
				{			
					switch ${Me.Group[${tempgrp}].Class}
					{
						case berserker
						case guardian
						case bruiser
						case monk
						case brigand
						case swashbuckler
						case ranger
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
					}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		case Caster_Buff
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.UsedConc}<5
				{			
					switch ${Me.Group[${tempgrp}].Class}
					{
						case wizard
						case magician	
							call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
					}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		case Summon_Pet
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Kill_Pet
			eq2execute /pet getlost
			break

		case Single_Buff_Conc
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			break

		Default
			xAction:Set[10]
			break
	}
}

function Combat_Routine(int xAction)
{
	CurState:Set["Combat: ${Action[${xAction}]}"]
	switch ${Action[${xAction}]}
	{
		case Mezmerise
			;===============================================;
			;Check the xml setting to see what all to mez	;
			;===============================================;

			switch ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[Class Settings].Set[Select1].GetString[Value]}
			{
				case Nothing
				break
				case Everything
					;==============================================;
					;This method should mez any mobs that attack   ;
					;==============================================;
					call Mez_Area
					target ${Actor[${MainAssist}].Target.ID}
				break
				case Protective
					;=======================================================;
					;This should mez any mobs that are not on the MT	;
					;=======================================================;
					call Mez_Area Protective
					target ${Actor[${MainAssist}].Target.ID}
				break
			}
			break

		case Pet_Attack
			;=======================================;
			;Pet Attack needs a little TLC		;
			;Check to be sure mob is not mezzed	;
			;=======================================;
			call CheckMez ${Target.ID}
			if ${Return.Equal[NO]}
			{
				if ${MainTank}&&${Actor[MyPet].Target.ID}!=${Target.ID}&&${Target.ID}!=${Me.ID}
				{
				EQ2Execute /pet attack
				}
				elseif !${MainTank}&&${Actor[MyPet].Target.ID}!=${Actor[${MainAssist}].Target.ID}
				{
					target ${Actor[${MainAssist}].Target.ID}
					EQ2Execute /pet attack
				}
			}

			break

		case Debuff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
				call CastSpellRange ${SpellRange[${xAction},2]}
			}
			break
		
		case AoE
			if ${Mob.Count}>2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Summon_Pet
			;=======================================================;
			;Construct of Reason...					;
			;							;
			;=======================================================;
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Dot
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			}
			break

		case Nuke_Attack
			call CastSpellRange ${SpellRange[${xAction},3]}
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break

		case Self_Power
			if ${Me.ToActor.Power}<80 && ${Me.ToActor.Health}>85 && !${haveaggro}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break

		case Combat_Buff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				grpcnt:Set[${Me.GroupCount}]
				tempgrp:Set[1]
				do
				{
					switch ${Me.Group[${tempgrp}].Class}
					{
						case assassin
						case ranger
						case brigand
						case swashbuckler
						case dirge
						case troubador
						case berserker
						case guardian
						case bruiser
						case monk
						case paladin
						case shadowknight
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
					}
				}
				while ${tempgrp:Inc}<${grpcnt}
			}
			break

		case Stun_Power_Drain
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break
			
		Default
			xAction:Set[20]
			break
	}
}

function Post_Combat_Routine()
{
CurState:Set["PostCombat: ${PostAction[${xAction}]}"]
	switch ${PostAction[${xAction}]}
	{
	case Heal_Wait
		;===============================================;
		;If autohunt is on, dont just go pull another!	;
		;===============================================;

		if ${AutoHunt}
		{
			echo Waiting on health
			do
			{
				wait 10
			}
			while ${Me.Health} < 95	
		}
	break

	Default
		xAction:Set[20]
	break
	}

}

function Have_Aggro()
{
	
	;=======================================================;
	;TODO! (big) Double Check that we have agro		;
	;Lets cycle through mobs, see if they have me targeted	;
	;check for mez, then take evasive manouvers		;
	;=======================================================;
	call CheckMez ${Actor[${aggroid}].ID}
	if !${AutoHunt}&&${Return.Equal[NO]}
	{
		CurState:Set["I Have Agro!"]
		if ${Me.AutoAttackOn}
		{
			EQ2Execute /toggleautoattack
		}
	
		if ${Target.Target.ID}==${Me.ID}
		{
			;=======================;
			;Lets try Blink First	;
			;=======================;
			Target ${Actor[${aggroid}].ID}
			call CastSpellRange 387
			;=======================================================;
			;TODO: add some of the other anti-agro spells here	;
			;=======================================================;
		}

	} 
	else 
	{
	;===============================================;
	;If mob is mezzed, we dont "really" have agro	;
	;===============================================;
	haveaggro:Set[FALSE]
	}
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{
CurState:Set["MA Lost Agro!"]
;=======================================================;
;TODO:  check victim health, use illusionary allies OR	;
;Use new AA agro debuff					;
;=======================================================;
}

function Cancel_Root()
{

}


function Mez_Area(string mode)
{
EQ2:CreateCustomActorArray[byDist,20]
declare tcount int local 1
	do
	{
		;=======================================================;
		;If mob is agro, is an NPC, and not on the MT, continue	;
		;=======================================================;
		if ${CustomActor[${tcount}].InCombatMode} && ${CustomActor[${tcount}].Type.Equal[NPC]} && !(${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID})
		{
			;=============================================================;
			;If in protective mode, we dont care unless MT lost agro on it;
			;=============================================================;
			if "${mode.Equal[Protective]} && ${CustomActor[${tcount}].Target.ID}==${Actor[${MainAssist}].ID}"
			break
				;=========================================;
				;Check to make sure its not allready mezed;
				;=========================================;
				call CheckMez ${CustomActor[${tcount}].ID}
				if ${Return.Equal[NO]}
				{
					;=======================================;
					;Try primary mez first, if its ready	;
					;Abduct Mind is 352			;
					;=======================================;
					eq2echo Attempting to mez ${CustomActor[${tcount}].Name}
					if ${Me.Ability[${SpellType[352]}].IsReady} 
					{
						call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID}
						if ${Return.Equal[RESISTED]}
						{
							;=============================;
							;Use Secondary mez if resisted;
							;Briliant Regala is 385	      ;
							;=============================;
							call CastSpellRange 385 0 0 0 ${CustomActor[${tcount}].ID}
						}
					}
					else
					{
						;===================================================================================;
						;If primary mez is not ready, use secondary											;
						;if the world was perfect, this would get used any time there was more than 3 mobs	;
						;===================================================================================;
						call CastSpellRange 385 0 0 0 ${CustomActor[${tcount}].ID}
					}
				}						
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

}

function CheckMez(int MobID)
{
	;=======================================================================================;
	;This function checks the target passed to it, to see if a mez spell is active on it	;
	;Next Version, return the time remaining instead of yes/no				;
	;=======================================================================================;
	declare tempvar int local 1
	declare tmpreturn string local NO
	do
	{
		if ${Me.Maintained[${tempvar}].Target.ID}==${MobID}
		{
			;echo "Mob ${MobID} has ${Me.Maintained[${tempvar}].Name} on it looking for ${SpellType[352]}"
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[352]}]}
			{
				;echo "Normal Mez on"
				tmpreturn:Set[YES]
				return YES
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[385]}]}
			{
				;echo "Short mez On"
				tmpreturn:Set[SHORT]
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[353]}]}
			{
				;echo "Group mez On"
				tmpreturn:Set[GROUP]
			}
		}
	}
	while ${tempvar:Inc}<=${Me.CountMaintained}
	Return ${tmpreturn}
}

function hoact(string line, string state) 
{
;=======================================================;
;This needs to be re-visited, or put into the extension	;
;=======================================================;
CurState:Set["Reacting to HO"]
	
	if ${SettingXML[scripts/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[Position${EQ2.HOCurrentWheelSlot}].GetInt[${Me.Archetype}](exists)}
	{
	;===============================================================;
	;If the HO database is filled out for this HO, then advance it	;
	;===============================================================;
	call CastSpellRange ${SettingXML[scripts/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[Position${EQ2.HOCurrentWheelSlot}].GetInt[${Me.Archetype}]}
	}
	else
	{
	;=======================================================;
	;Otherwise, Create an empty entrie in the HO database	;
	;=======================================================;
	SettingXML[scripts/XML/EQ2BotHO.xml].Set[${EQ2.HOName}]:Set[Description,${EQ2.HODescription}]:Save
	SettingXML[scripts/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[Position${EQ2.HOCurrentWheelSlot}]:Set[${Me.Archetype},"000"]:Save
	}	

}