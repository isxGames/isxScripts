;*************************************************************
;Shadowknight.iss
;version 20061110b experimental
;by Pygar 
; FIXED: PBAoE should work, No crash on agro loss, Will use Coil and HT now
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration() 
{ 
	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE

	
	declare BuffArmamentMember string script
	declare BuffTacticsGroupMember string script

	
	declare WeaponHammer string script 
	declare WeaponSword string script
	declare WeaponSpear string script
	declare WeaponTwohanded string script
	declare WeaponAxe string script
	declare WeaponMain string script	
	declare OffHand string script
	declare EquipmentChangeTimer int script	
	
	
	call EQ2BotLib_Init
	
	FullAutoMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Full Auto Mode,FALSE]}]
	TauntMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Defensive Spells,TRUE]}]
	OffensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]

	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]

	BuffArmamentMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffArmamentMember,]}]
	BuffTacticsGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffTacticsGroupMember,]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Main",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	WeaponHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Hammer",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Spear",""]}]
	WeaponTwohanded:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Twohanded",""]}]
	WeaponAxe:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Axe",""]}]	

} 


function Buff_Init() 
{ 
   PreAction[1]:Set[Armament_Target] 
   PreSpellRange[1,1]:Set[30] 

   PreAction[2]:Set[Self_Buff] 
   PreSpellRange[2,1]:Set[25] 
   PreSpellRange[2,2]:Set[26] 

   PreAction[3]:Set[Group_Buff] 
   PreSpellRange[3,1]:Set[20] 
   PreSpellRange[3,2]:Set[21]

   PreAction[4]:Set[Tactics_Target] 
   PreSpellRange[5,1]:Set[31] 

} 

function Combat_Init() 
{ 
   Action[1]:Set[AoE_Taunt] 
   SpellRange[1,1]:Set[170]

   Action[2]:Set[Taunt] 
   SpellRange[2,1]:Set[160] 

   Action[3]:Set[Melee_Nuke] 
   Power[3,1]:Set[5] 
   Power[3,2]:Set[100]
   SpellRange[3,1]:Set[60]
   SpellRange[3,2]:Set[61]
   SpellRange[3,3]:Set[62]
   SpellRange[3,4]:Set[63]
   
   Action[4]:Set[Mist] 
   MobHealth[4,1]:Set[50] 
   MobHealth[4,2]:Set[100] 
   Power[4,1]:Set[20] 
   Power[4,2]:Set[100] 
   SpellRange[4,1]:Set[55]
   
   Action[5]:Set[PBAoE] 
   Power[5,1]:Set[20] 
   Power[5,2]:Set[100] 
   SpellRange[5,1]:Set[95]
   SpellRange[5,2]:Set[96]
   SpellRange[5,3]:Set[97]
   SpellRange[5,4]:Set[98]
   SpellRange[5,5]:Set[99]
   
   Action[6]:Set[Damage_Debuff] 
   MobHealth[6,1]:Set[5] 
   MobHealth[6,2]:Set[100] 
   Power[6,1]:Set[20] 
   Power[6,2]:Set[100] 
   SpellRange[6,1]:Set[80] 
   SpellRange[6,2]:Set[81]

   Action[7]:Set[Melee_Attack] 
   Power[7,1]:Set[5] 
   Power[7,2]:Set[100] 
   SpellRange[7,1]:Set[150] 
   SpellRange[7,2]:Set[151] 
   SpellRange[7,3]:Set[152] 
   SpellRange[7,4]:Set[153] 
   SpellRange[7,5]:Set[154] 
      
   Action[8]:Set[Shield_Attack] 
   Power[8,1]:Set[5] 
   Power[8,2]:Set[100] 
   SpellRange[8,1]:Set[240] 
   
   Action[9]:Set[Pet]
   MobHealth[9,1]:Set[50] 
   MobHealth[9,2]:Set[100] 
   SpellRange[9,1]:Set[45]

   
   Action[10]:Set[ThermalShocker]

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
	variable int temp
	
	call WeaponChange

	if ${ShardMode}
	{
		call Shard
	}
	
	switch ${PreAction[${xAction}]} 
	{ 
		
		case Armament_Target 
			BuffTarget:Set[${UIElement[cbBuffArmamentGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 1
			}
			break	

		case Self_Buff 
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 1
			}
			break 

		case Group_Buff 
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 1
			}
			break 

		case Tactics_Target 
			BuffTarget:Set[${UIElement[cbBuffTacticsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 1
			}
			break

		Default 
			xAction:Set[20] 
			break 
	}

} 

function Combat_Routine(int xAction)
{
	call WeaponChange
	
	if ${DoHOs}
	{
		
		objHeroicOp:DoHO
	}
	
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}
	
	;The following till FullAuto could be nested in FullAuto, but I think bot control of these abilities is better

	if ${Me.ToActor.Health}<90
	{
		call CastSpellRange 7
	}

	;echo in combat
	if ${FullAutoMode}
	{
		
		switch ${Action[${xAction}]} 
		{ 
		
			case Taunt 
				if ${TauntMode} 
				{ 
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				} 
				break
				

			case AoE_Taunt
				if ${TauntMode} 
				{ 
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break

			case Damage_Debuff
				if ${OffensiveMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
					if ${Return.Equal[OK]} 
					{ 
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
						if ${Return.Equal[OK]} 
						{ 						
							call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 1 0 ${KillTarget} 0 0 1
						} 
					}
				}
				break       

			case Pet
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
				if ${Return.Equal[OK]} 
				{ 
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				} 
				break		
			case Mist
				if ${Mob.Count}>1
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
					if ${Return.Equal[OK]} 
					{ 
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					}
				}
				break
			case PBAoE
				if ${PBAoEMode} && ${Mob.Count}>1
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
					if ${Return.Equal[OK]} 
					{ 
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},5]} 1 0 ${KillTarget} 
					}
				}
				break
			case Melee_Attack
				if ${OffensiveMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
					if ${Return.Equal[OK]} 
					{ 
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},5]} 1 0 ${KillTarget} 0 0 1
					}
				}
				break 
			
			case Shield_Attack
				if ${OffensiveMode}
				{
					If ${Me.Equipment[Secondary].Type.Equal[Shield]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
						if ${Return.Equal[OK]} 
						{ 
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
						}
					}
				}
				break
			
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				}	
				break
				
			case Melee_Nuke
				if ${OffensiveMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]} 
					if ${Return.Equal[OK]} 
					{ 
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},4]} 1 0 ${KillTarget}
					}
				}
				break 
							
			case default 
				;xAction:Set[20] 
				break 
		}
	}
} 

function Post_Combat_Routine(int xAction) 
{

} 

function Have_Aggro() 
{ 

} 

function Lost_Aggro(int mobid) 
{
	if ${FullAutoMode}
	{
		if ${TauntMode}
		{
			;intercept damage on the person now with agro
			call CastSpellRange 7 0 1 0 ${mobid} 0 0 1
			call CastSpellRange 270 0 1 0 ${mobid} 0 0 1
			call CastSpellRange 160 0 1 0 ${mobid} 0 0 1
			
			
			
			;use rescue if new agro target is under 65 health
			if ${Me.ToActor.Target.Target.Health}<65
			{
				call CastSpellRange 320 0 1 0 ${mobid} 0 0 1
			}
		}
	}
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

}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}	

	;equip off hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal[${OffHand}]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory[${OffHand}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}

