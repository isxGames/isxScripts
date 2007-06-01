;============================================
;
;EQ2BotLib version 20070337a
;by karye
;updated by pygar
;
; Added a condition around creating uplink name to stop session rejected messages
;
;Added Defiler Cyrstalize Spirit Healing function
;Use call UseCrystallizedSpirit SomeHealth%
;example:
;call UseCrystallizedSpirit 60

;Description: Helper functions for EQ2BotCommander,
; EQ2BotExtras and various karye class bots
;
;

#define _Eq2Botlib_
#includeoptional "\\Athena\ISScripts\release\EQ2HOLib.iss"

#ifndef _EQ2HOLIB_
	#include "../../EQ2HOLib.iss"
#endif

;EquipmentChanger
variable int TotalSlots=20
variable string CurrentEquipmentSet


;AutoFollow Variables
variable bool AutoFollowMode=FALSE
variable bool AutoFollowingMA=FALSE
variable string AutoFollowee

;Swap variables
variable int SwapStartTime
variable string ItemToBeEquiped
variable string OriginalItem
variable bool Swapping=FALSE

;Warn Tank variables
variable bool TellTank=FALSE
variable bool WarnTankWhenAggro=FALSE
variable string RelaySession
variable int StuckWarningTime

;Conj/Necro Shard&Heart request
variable bool ShardMode=FALSE
variable string ShardGroupMember
variable bool ShardRequested=FALSE

;Pet Attack Variables
variable int PetTarget
variable bool PetEngage
variable bool PetGuard

;HOs
variable bool DoHOs=FALSE
variable HeroicOp objHeroicOp

;Forward Tells
variable bool ForwardGuildChat

function EQ2BotLib_Init()
{

	;INI Settings
	AutoFollowMode:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Auto Follow Mode,FALSE]}]
	AutoFollowee:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[AutoFollowee,""]}]
	WarnTankWhenAggro:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Warn tank when I have a mob on me,FALSE]}]
	ShardMode:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Shard Mode,FALSE]}]
	ShardGroupMember:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Shard Group Member,""]}]
	DoHOs:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[DoHOs,FALSE]}]
	RelaySession:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[RelaySession,""]}]
	ForwardGuildChat:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[ForwardGuildChat,FALSE]}]

	;Triggers
	;AddTrigger AutoFollowTank "\\aPC @*@ @*@:@sender@\\/a tells@*@Follow Me@*@"
	;AddTrigger StopAutoFollowing "\\aPC @*@ @*@:@sender@\\/a tells@*@Wait Here@*@"
	AddTrigger ToClose "@*@Your Target is too close! Move away!"
	AddTrigger ReceivedTell "\\aPC @*@ @*@:@Sender@\\/a tells you,@Message@"

	if ${ForwardGuildChat}
	{
		AddTrigger RelayGuildMessage "\\aPC @*@ @*@:@Sender@\\/a says to the guild,@Message@"
	}

	;HOs
	if ${DoHOs}
	{
		objHeroicOp:Intialize
		objHeroicOp:LoadUI
	}


	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Class]
	UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Extras]



	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[7]:Move[4]
	UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[8]:Move[5]

	ui -load -parent "Class@EQ2Bot Tabs@EQ2 Bot" "EQ2Bot/UI/${Me.SubClass}.xml"
	ui -load -parent "Extras@EQ2Bot Tabs@EQ2 Bot" "EQ2Bot/UI/EQ2BotExtras.xml"

	ExecuteAtom SaveEquipmentSet "Default"

	#ifdef _EQ2HOLIB_
		if ${Session.NotEqual[${Me.Name}]}
		{
		uplink name ${Me.Name}
		}
	#endif

}

atom AutoFollowTank()
{


	AutoFollowMode:Set[TRUE]
	UIElement[AutoFollow@@Extras@EQ2Bot Tabs@EQ2 Bot]:SetChecked

	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[EQ2BotExtras]:Set["Auto Follow Mode",TRUE]:Save

	if ${Me.ToActor.WhoFollowingID}<0 && ${Actor[${AutoFollowee}].Distance}<45 && ${Actor[${AutoFollowee}](exists)} && !${AutoFollowingMA}
	{
		squelch face ${AutoFollowee}
		eq2execute /follow ${AutoFollowee}
		AutoFollowingMA:Set[TRUE]
	}


}

atom StopAutoFollowing()
{
	AutoFollowMode:Set[FALSE]
	AutoFollowingMA:Set[FALSE]
	UIElement[AutoFollow@@Extras@EQ2Bot Tabs@EQ2 Bot]:SetUnChecked

	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[EQ2BotExtras]:Set["Auto Follow Mode",FALSE]:Save

	EQ2Execute /stopfollow
}

atom StartEQ2Bot()
{
	call StartBot
}

function Buff_Count(int SpellLine)
{
	declare tempvar int local 1
	declare mcount int local 0

	do
	{
		if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[${SpellLine}]}]}
		{
			mcount:Inc
		}
	}
	while ${tempvar:Inc}<=${Me.CountMaintained}
	return ${mcount}
}

function Swap()
{

	if !${Swapping}
	{
		if ${Me.Inventory[ExactName,${ItemToBeEquiped}](exists)}  && ${Me.Equipment[ExactName,${OriginalItem}](exists)}
		{
			SwapStartTime:Set[${Time.Timestamp}]
			Swapping:Set[TRUE]
			Me.Inventory[${ItemToBeEquiped}]:Equip
		}
		else
		{
			EQ2Echo I do not have a ${ItemToBeEquiped} or a  ${OriginalItem}
		}

	}
	else
	{
		if ${Math.Calc[${Time.Timestamp} - ${SwapStartTime}]}>=2
		{
			Me.Inventory[${OriginalItem}]:Equip
			Swapping:Set[FALSE]
			SwapStartTime:Set[0]
			ItemToBeEquiped:Set[]
			OriginalItem:Set[]
		}
	}


}

function IsHealer(int ID)
{
	switch ${Actor[${ID}].Class}
	{

		case inquisitor
		case templar
		case fury
		case warden
		case defiler
		case mystic
			return TRUE
		default
			return FALSE
	}
}

function IsFighter(int ID)
{
	switch ${Actor[${ID}].Class}
	{

		case guardian
		case berserker
		case shadowknight
		case paladin
		case bruiser
		case monk
			return TRUE
		default
			return FALSE
	}
}

function Shard()
{
	declare ShardType string local "NOSHARD"


	if ${Me.Inventory["Shard of Essence"](exists)}
	{
		ShardType:Set[Shard of Essence]
	}
	elseif ${Me.Inventory["Sliver of Essence"](exists)}
	{
		ShardType:Set[Sliver of Essence]
	}
	elseif  ${Me.Inventory["Scintilla of Essence"](exists)}
	{
		ShardType:Set[Scintilla of Essence]
	}
	elseif  ${Me.Inventory["Splintered Heart"](exists)}
	{
		ShardType:Set[Splintered Heart]
	}
	elseif  ${Me.Inventory["Dark Heart"](exists)}
	{
		ShardType:Set[Dark Heart]
	}
	elseif  ${Me.Inventory["Sacrificial Heart"](exists)}
	{
		ShardType:Set[Sacrificial Heart]
	}
	elseif  ${Me.Inventory["Ruinous Heart"](exists)}
	{
		ShardType:Set[Ruinous Heart]
	}

	if ${ShardType.NotEqual[NOSHARD]} && ${Me.ToActor.Power}<65 && ${Me.Inventory[${ShardType}].IsReady} && ${ShardMode}
	{

		Me.Inventory[${ShardType}]:Use
		ShardRequested:Set[FALSE]
	}

	if !${Me.Inventory[${ShardType}](exists)} && !${ShardRequested}
	{
		ShardRequested:Set[TRUE]
		EQ2Execute /tell ${ShardGroupMember} shard please

	}

}

function ToClose()
{
	; we are to close for a bow change to melee
	if ${Me.RangedAutoAttackOn}
	{
		eq2execute /togglerangedattack
		eq2execute /toggleautoattack
	}

}


function CheckGroupHealth(int MinHealth)
{
	declare counter int local 1

	do
	{

		;check groupmates health
		if ${Me.Group[${counter}].ToActor.Health}<${MinHealth} && ${Me.Group[${counter}].ToActor.Health}>0
		{
			Return FALSE
		}

		;check health of summoner pets
		if ${Me.Group[${counter}].Class.Equal[conjuror]} || ${Me.Group[${counter}].Class.Equal[necromancer]}
		{
			if ${Me.Group[${counter}].ToActor.Pet.Health}<${MinHealth} && ${Me.Group[${counter}].ToActor.Pet.Health}>0
			{
				Return FALSE
			}
		}

	}
	while ${counter:Inc}<${Me.GroupCount}

	;check my health
	if ${Me.ToActor.Health}<${MinHealth}
	{
		Return FALSE
	}

	Return TRUE
}

atom PetAttack()
{
	if ${Me.ToActor.Pet.Target.ID}!=${KillTarget} && !${Actor[${KillTarget}].IsLocked}  && ${Mob.ValidActor[${KillTarget}]}
	{
		EQ2Execute /pet backoff
		target ${KillTarget}
		EQ2Execute /pet attack
		if ${PetGuard}
		{
			EQ2Execute /pet preserve_self
			EQ2Execute /pet preserve_master
		}
	}

}

function ReceivedTell(string line, string Sender, string Message)
{
	relay ${RelaySession} EQ2Echo ${Sender} tells ${Me.Name}, ${Message}
}

function RelayGuildMessage(string line, string Sender, string Message)
{
	relay ${RelaySession} EQ2Echo ${Sender} tells the guild, ${Message}
}

atom CheckStuck()
{
	if ${Actor[${Me.ToActor.WhoFollowing}].Distance}>25 && (${Math.Calc[${Time.Timestamp} - ${StuckWarningTime}]}>=10)  && ${Actor[${Me.ToActor.WhoFollowing}](exists)}
	{
		relay ${RelaySession} EQ2Echo ${Me.Name} IS STUCK

		StuckWarningTime:Set[${Time.Timestamp}]
	}


}

atom SaveEquipmentSet(string EquipmentSetName)
{
	variable int tempvar=1
	variable string EquipmentItem

	Do
	{
		if !${Me.Equipment[${tempvar}].Name.Equal[NULL]}
		{
			SettingXML[${charfile}].Set[EQ2BotExtras].Set[Equipment].Set[${EquipmentSetName}]:Set[${tempvar},${Me.Equipment[${tempvar}].Name}]
		}
	}
	while ${tempvar:Inc} <=22
	SettingXML[${charfile}]:Save


}

atom GetNaked()
{
	variable int tempvar=1

	if !${Me.InCombat}
	{
		Do
		{
			Me.Equipment[${tempvar}]:UnEquip
		}
		while ${tempvar:Inc} <=22
	}
}

atom LoadEquipmentSet(string EquipmentSetName)
{
	variable int tempvar=1

	if !${Me.InCombat}
	{

		Do
		{
			if ${Me.Equipment[${tempvar}].Name.NotEqual[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[Equipment].Set[${EquipmentSetName}].GetString[${tempvar}]}]} || !${Me.Equipment[${tempvar}](exists)}
			{
				Me.Inventory[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[Equipment].Set[${EquipmentSetName}].GetString[${tempvar}]}]:Equip
			}
		}
		while ${tempvar:Inc} <=22
	}
}

function UseItem(string Item)
{
		;if we have the item equiped and its ready well use it
		if ${Me.Equipment[ExactName,"${Item}"].IsReady}
		{
			Me.Equipment[ExactName,"${Item}"]:Use
		}
		;else lets check if its in our inventory and swap it in to use if ready and were not swaping any other items.
		elseif ${Me.Inventory[ExactName,"${Item}"].IsReady} && ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
		{
			Me.Inventory[ExactName,"${Item}"]:Equip
			Me.Equipment["${Item}"]:Use
		}
}

function UseCrystallizedSpirit(int Health)
{
	;Use a defiler crystalized spirit if we have 2 or more group members under ${Health}


	declare temphl int local
	declare grpheal int local 0

	grpcnt:Set[${Me.GroupCount}]
	temphl:Set[1]

	if ${Me.Inventory[Crystallized Spirit].IsReady}
	{
		if ${Me.ToActor.Health}>0 && ${Me.Group[${temphl}].ToActor.Health}<${Health}
		{
			grpheal:Inc
		}

		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)}
			{

				if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<${Health}
				{
					grpheal:Inc
				}

				if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
				{
					if ${Me.Group[${temphl}].ToActor.Pet.Health}<${Health} && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
					{
						grpheal:Inc
					}
				}

			}

		}
		while ${temphl:Inc}<${grpcnt}


		if ${grpheal}>=2
		{
			Me.Inventory[Crystallized Spirit]:Use
		}
	}
}


function GetActorID(string ActorName)
;function returns the Actor ID from a ActorName.  It prioritzes PCs over pets and npcs
{
	variable int ActorID=0
	variable int Counter=1

	EQ2:CreateCustomActorArray[byDist,50]
	do
	{
		if ${CustomActor[${Counter}].Name.Equal[${ActorName}]}
		{
			ActorID:Set[${CustomActor[${Counter}].ID}]
			if ${CustomActor[${Counter}].Type.Equal[PC]}
			{
				;There is a PC by this name so return it
				Return ${ActorID}
			}
		}
	}
	while ${Counter:Inc}<=${EQ2.CustomActorArraySize}

	;We either found no actor or a NPC so return that ID
	Return ${ActorID}
}