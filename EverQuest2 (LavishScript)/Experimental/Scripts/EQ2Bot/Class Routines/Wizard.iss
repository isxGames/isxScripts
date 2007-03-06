;*************************************************************
;Wizard.iss
;version 20061207a
;by Pygar
; Added Crystalized Spirit
; Fixed AoE Checks
;*************************************************************


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare DoTMode bool script TRUE
	declare BuffAccordShield bool script FALSE
	declare BuffSeeInvis bool script TRUE
	declare BuffRadianceProc collection:string script
	declare BuffAmplify bool script FALSE
	declare BuffSeal bool script FALSE
	declare StartHO bool script 1

	
	;Custom Equipment
	declare WeaponStaff string script 
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script
	
	declare EquipmentChangeTimer int script ${Time.Timestamp}
	
	call EQ2BotLib_Init
	
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	DoTMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast DoT Spells,TRUE]}]
	BuffAccordShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Accord Shield,FALSE]}]
	BuffSeeInvis:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff See Invis,TRUE]}]
	BuffAmplify:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAmplify,,FALSE]}]
	BuffSeal:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSeal,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	
	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Staff",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]		
	
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[26]
	PreSpellRange[1,3]:Set[27]

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
}

function Combat_Init()
{		
	Action[1]:Set[Combat_SelfBuff]
	MobHealth[1,1]:Set[50] 
	MobHealth[1,2]:Set[100] 
	SpellRange[1,1]:Set[361]

	Action[2]:Set[Combat_GroupBuff]
	MobHealth[2,1]:Set[50] 
	MobHealth[2,2]:Set[100] 
	SpellRange[2,1]:Set[360]
	
	Action[3]:Set[Debuffs]
	SpellRange[3,1]:Set[355]

	Action[4]:Set[Debuffs]
	SpellRange[4,1]:Set[50]

	Action[5]:Set[Special_Pet]
	MobHealth[5,1]:Set[50] 
	MobHealth[5,2]:Set[100] 
	SpellRange[5,1]:Set[324]

	Action[6]:Set[Combat_DS]
	MobHealth[6,1]:Set[30] 
	MobHealth[6,2]:Set[100] 
	SpellRange[6,1]:Set[355]
	
	Action[7]:Set[AoE_Nuke1]
	SpellRange[7,1]:Set[90]

	Action[8]:Set[AoE_Nuke2]
	SpellRange[8,1]:Set[91]

	Action[9]:Set[AoE_Nuke3]
	SpellRange[9,1]:Set[92]
	
	Action[10]:Set[Dot1]
	MobHealth[10,1]:Set[20] 
	MobHealth[10,2]:Set[100] 
	SpellRange[10,1]:Set[70]

	Action[11]:Set[Dot2]
	MobHealth[11,1]:Set[20] 
	MobHealth[11,2]:Set[100] 
	SpellRange[12,1]:Set[71]

	Action[12]:Set[Dot3]
	MobHealth[12,1]:Set[20] 
	MobHealth[12,2]:Set[100] 
	SpellRange[12,1]:Set[72]
	
	Action[13]:Set[Dot4]
	MobHealth[13,1]:Set[20] 
	MobHealth[13,2]:Set[100] 
	SpellRange[13,1]:Set[73]

	Action[14]:Set[AoE_PB1]
	SpellRange[14,1]:Set[94]
	
	Action[15]:Set[AoE_PB2]
	SpellRange[15,1]:Set[95]
	
	Action[16]:Set[AoE_PB3]
	SpellRange[16,1]:Set[96]
		
	Action[17]:Set[Stun]
	SpellRange[17,1]:Set[180]
	SpellRange[17,2]:Set[181]
	
	Action[18]:Set[Nuke]
	SpellRange[18,1]:Set[60]
	SpellRange[18,2]:Set[61]
	SpellRange[18,3]:Set[62]
	SpellRange[18,4]:Set[63]
	
	Action[19]:Set[Master_Strike]
	
}

function PostCombat_Init()
{
	
	PostAction[1]:Set[LoadDefaultEquipment]
	call RefreshPower
	
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
	}
	
	call CheckHeals
	call RefreshPower
	
	ExecuteAtom CheckStuck
	
	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

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

		Default
			xAction:Set[20]
			break
	}
}

function Combat_Routine(int xAction)
{
	
	AutoFollowingMA:Set[FALSE]
	
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}
	
	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}
	
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
	}
	
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}
		
	call CheckHeals
	call RefreshPower
	
	switch ${Action[${xAction}]}
	{

		case Special_Pet
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
			if ${Return.Equal[OK]} 
			{ 				
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
			
		case AoE_PB1
		case AoE_PB2
		case AoE_PB3
			if ${PBAoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}

			}
			break
		
		case Combat_SelfBuff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
			if ${Return.Equal[OK]} 
			{ 				
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
			
		case Combat_GroupBuff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
			if ${Return.Equal[OK]} && ${Mob.Count}>1
			{ 				
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
			
		case Debuffs
			if ${DebuffMode} && ${PBAoEMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		
		case AoE_Nuke1
		case AoE_Nuke2
		case AoE_Nuke3
			if ${AoEMode} && ${Mob.Count}>1
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case Master_Strike
			if ${Me.Ability[Gnoll Master's Strike].IsReady} || ${Me.Ability[Orc Master's Strike].IsReady}
			{
				if ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
					Me.Ability[Droag Master's Strike]:Use
					;Me.Ability[Orc Master's Strike]:Use
					Me.Ability[Gnoll Master's Strike]:Use
					;Me.Ability[Ghost Master's Strike]:Use
					Me.Ability[Skeleton Master's Strike]:Use
					;Me.Ability[Zombie Master's Strike]:Use
					;Me.Ability[Centaur Master's Strike]:Use
					Me.Ability[Giant Master's Strike]:Use
					;Me.Ability[Treant Master's Strike]:Use
					;Me.Ability[Fairy Master's Strike]:Use
					Me.Ability[Lizardman Master's Strike]:Use
					Me.Ability[Goblin Master's Strike]:Use
					;Me.Ability[Golem Master's Strike]:Use
					;Me.Ability[Bixie Master's Strike]:Use
					;Me.Ability[Cyclops Master's Strike]:Use
					Me.Ability[Djinn Master's Strike]:Use
					;Me.Ability[Harpy Master's Strike]:Use
					;Me.Ability[Naga Master's Strike]:Use
					;Me.Ability[Aviak Master's Strike]:Use
					;Me.Ability[Beholder Master's Strike]:Use
					;Me.Ability[Ravasect Master's Strike]:Use
				}
			}

		case Dot1
		case Dot2
		case Dot3
		case Dot4
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]} 
			if ${Return.Equal[OK]} 
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
			}
			break
			
		case Nuke
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},4]} 0 0 ${KillTarget}
			break
		
		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget}
			break	
		case Root
			break			
		Default
			xAction:Set[20]
			break
	}

}

function Post_Combat_Routine(int xAction)
{

	
	TellTank:Set[FALSE]
	
	switch ${PostAction[${xAction}]}
	{
		case LoadDefaultEquipment
			ExecuteAtom LoadEquipmentSet "Default"
		case default
			xAction:Set[20]
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
	
	if ${Me.Ability[${SpellRange[181]}].IsReady} 
	{
		call CastSpellRange 181
	}
	else
	{
		call CastSpellRange 180
	}
	
	if ${Me.Ability[${SpellRange[230]}].IsReady} ${Actor[${aggroid}].Distance}<5
	{
		call CastSpellRange 230
		press -hold ${backward}
		wait 3
		press -release ${backward}
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
		press -hold ${backward}
		wait 3
		press -release ${backward}
		avoidhate:Set[TRUE]
	}
	
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
	

		
	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}
	
	;Conjuror Shard
	if ${Me.Power}<40 && ${Me.Inventory[${ShardType}](exists)} && ${Me.Inventory[${ShardType}].IsReady}
	{
		Me.Inventory[${ShardType}]:Use
	}
	
	if ${Me.InCombat} && ${Me.ToActor.Power}<20
	{
		call UseItem "Dracomancer Gloves" 		
	}
		
	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}	
	
	if ${Me.ToActor.Power}<45
	{
		call CastSpellRange 309
	}
	
	if ${Me.ToActor.Power}<35 && ${Me.ToActor.Health}>20
	{
		call CastSpellRange 310
	}
}

function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]
		
	; Cure Arcane Me
	if ${Me.Arcane}
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}
		
		if ${Actor[${KillTarget}](exists)}
		{
			Target ${KillTarget}
		}
	}
	
	do
	{
		; Cure Arcane 
		if ${Me.Group[${temphl}].Arcane} && ${Me.Group[${temphl}].ToActor(exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${temphl}].ID}
			
			if ${Actor[${KillTarget}](exists)}
			{
				Target ${KillTarget}
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}

	call UseCrystallizedSpirit 60
}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal["${WeaponMain}"]}
	{
		Me.Inventory["${WeaponMain}"]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}	

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal["${OffHand}"]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory["${OffHand}"]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}