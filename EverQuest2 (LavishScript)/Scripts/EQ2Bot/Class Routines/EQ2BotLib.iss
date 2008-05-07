;============================================
;
;EQ2BotLib version 20070337a
;by karye
;updated by pygar
;
; 20080425a (Amadeus)
; AutoFollowTank() should no longer attempt to autofollow if the person to whom the bot is trying to follow (or the bot itself) is on a 
; griffon-like transport or if they (or the bot) are currently climbing a wall.
;
; 20080406a (Amadeus)
; * Various fixes to Math.Calc (to Math.Calc64) when used in conjunction with Time.Timestamp
; * The 'autofollow' routine will now only auto follow a tank every 5 seconds at most.  
;
; 20080331a (Amadeus)
; * Added events for Zoning.  EQ2Bot should now autofollow the "AutoFollowee" after zoning.
; * Updated the 'AutoFollowTank()' function.
;
; 20080323a (Amadeus)
; * Added a collection called "MezSpells" which is intended to contain all spells that qualify as 'mez' type spells.  It is populated during initialization.
; * Added function CheckForMez().  Checks first if a mob is rooted and cannot turn, if so, it then checks the effects on the mob to see if any of the effects
;   are 'mez spells' as defined in the "MezSpells" collection
; * Added function CheckForStun(). If the mob is rooted and cannot turn, and it is NOT mezzed, then it must be stunned.
; * Added function ReacquireTargetFromMA()
;
; 20070337a
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

;EquipmentChanger
variable int TotalSlots=20
variable string CurrentEquipmentSet

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

;chat event vars
variable string OutTrigger
variable string InTrigger
;0 is in 1 is out
variable bool JoustStatus=FALSE
variable bool BDStatus=FALSE

;Potion vars
variable bool UsePotions
variable bool AWarn=TRUE
variable bool EWarn=TRUE
variable bool NWarn=TRUE
variable bool TWarn=TRUE
variable bool StartCure=FALSE
variable string ArcanePotion
variable string ElementalPotion
variable string NoxiousPotion
variable string TraumaPotion

; Mez Spells
variable(script) collection:int MezSpells

; Invis Spells
variable(script) collection:int InvisSpells

;AutoFollow Variables
variable bool AutoFollowMode=FALSE
variable bool AutoFollowingMA=FALSE
variable string AutoFollowee
variable int AutoFollowLastSetTime

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

	UsePotions:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Use potions for cures?,FALSE]}]
	ArcanePotion:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Arcane Potion Name,NULL]}]
	ElementalPotion:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Elemental Potion Name,NULL]}]
	NoxiousPotion:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Noxious Potion Name,NULL]}]
	TraumaPotion:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].GetString[Trauma Potion Name,NULL]}]

	;Triggers
	AddTrigger AutoFollowTank "\\aPC @*@ @*@:@sender@\\/a tells@*@Follow Me@*@"
	AddTrigger StopAutoFollowing "\\aPC @*@ @*@:@sender@\\/a tells@*@Wait Here@*@"
	AddTrigger ToClose "@*@Your Target is too close! Move away!"
	AddTrigger ReceivedTell "\\aPC @*@ @*@:@Sender@\\/a tells you,@Message@"

	if ${ForwardGuildChat}
	{
		AddTrigger RelayGuildMessage "\\aPC @*@ @*@:@Sender@\\/a says to the guild,@Message@"
	}

	Event[EQ2_onIncomingChatText]:AttachAtom[ChatText]
	Event[EQ2_StartedZoning]:AttachAtom[EQ2_StartedZoning]
	Event[EQ2_FinishedZoning]:AttachAtom[EQ2_FinishedZoning]

	;HOs
	if ${DoHOs}
	{
		objHeroicOp:Intialize
		objHeroicOp:LoadUI
	}

	;********************************************
	; Set these to whatever you want to use.... *
	;********************************************
	InTrigger:Set[dps in]
	OutTrigger:Set[dps out]
	BDTrigger:Set[BD Now!]


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

	call PopulateMezSpells
	call PopulateInvisSpells

	AutoFollowLastSetTime:Set[0]
	
	return OK
}

function PopulateInvisSpells()
{
    ;;;;
    ;; Syntax:  InvisSpells:Set["Spell Name",Level]
    ;;;;
    InvisSpells:Set["Veil of the Unseen",15]
    InvisSpells:Set["Illusory Mask",24]
    InvisSpells:Set["Invisibility",15]
    InvisSpells:Set["Untamed Shroud",45]
    InvisSpells:Set["Smuggle",11]
    InvisSpells:Set["Wind Walk",24]
    InvisSpells:Set["Totem of the Chameleon",15]

    ;echo "DEBUG: ${InvisSpells.Used} spells were added to the InvisSpells collection."

    return ${InvisSpells.Used}
}

function PopulateMezSpells()
{
	variable int keycount
	variable int iLevel=1
	variable int iType = 0
	variable string tempnme
	variable int tempvar=1
	variable string SpellName

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Illusionist Mez Spells
	;;;;;
	spellfile:Set[${mainpath}EQ2Bot/Spell List/Illusionist.xml]
	keycount:Set[${SettingXML[${spellfile}].Set[Illusionist].Keys}]
	do
	{
		tempnme:Set["${SettingXML[${spellfile}].Set[Illusionist].Key[${tempvar}]}"]

		iLevel:Set[${Arg[1,${tempnme}]}]
		iType:Set[${Arg[2,${tempnme}]}]
		SpellName:Set[${SettingXML[${spellfile}].Set[Illusionist].GetString["${tempnme}"]}]

		;echo "Debug: Processing Illusionist Spell '${SpellName}' (Level: ${iLevel} - Type: ${iType})"

        switch ${iType}
        {
            case 92
            case 352
            case 353
            case 356
                ;echo "DEBUG: Illusionist Spell '${SpellName}' (Level: ${iLevel} was added to the MezSpells collection"
                MezSpells:Set[${SpellName},${iLevel}]
                break

            Default
                break
        }


	}
	while ${tempvar:Inc} <= ${keycount}
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Coercer Mez Spells
	;;;;;
	tempvar:Set[1]
	spellfile:Set[${mainpath}EQ2Bot/Spell List/Coercer.xml]
	keycount:Set[${SettingXML[${spellfile}].Set[Coercer].Keys}]
	do
	{
		tempnme:Set["${SettingXML[${spellfile}].Set[Coercer].Key[${tempvar}]}"]

		iLevel:Set[${Arg[1,${tempnme}]}]
		iType:Set[${Arg[2,${tempnme}]}]
		SpellName:Set[${SettingXML[${spellfile}].Set[Coercer].GetString["${tempnme}"]}]

		;echo "Debug: Processing Coercer Spell '${SpellName}' (Level: ${iLevel} - Type: ${iType})"

        switch ${iType}
        {
            case 351
            case 352
            case 353
                ;echo "DEBUG: Coercer Spell '${SpellName}' (Level: ${iLevel} was added to the MezSpells collection"
                MezSpells:Set[${SpellName},${iLevel}]
                break

            Default
                break
        }


	}
	while ${tempvar:Inc} <= ${keycount}
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;echo "DEBUG: ${MezSpells.Used} spells were added to the MezSpells collection."

    return ${MezSpells.Used}
}

function AmIInvis(string param1)
{
    variable int i = 1
    
    do
    {
        if (${InvisSpells.Element[${Me.Maintained[${i}].Name}](exists)})
        {
            echo "DEBUG: I am invisible (therefore I will not cast spells.)  (Called By: ${param1})"
            return TRUE
        }
        
    }
    while ${i:Inc} <= ${Me.CountMaintained} 
    
    return FALSE
}

function CheckForMez(string param1)
{
    if !${Target.IsRooted}
        return FALSE
    if ${Target.CanTurn}
        return FALSE

    variable int i = 1

    Target:InitializeEffects
    wait 5
    if (${Target.NumEffects} > 0)
    {
        do
        {
            ;echo "DEBUG: Checking Target Effect #${i}: ${Target.Effect[${i}].Name}"
            if (${MezSpells.Element[${Target.Effect[${i}].Name}](exists)})
            {
                ;echo "DEBUG: ${Target} is Mezzed!  (Called By: ${param1})"
                return TRUE
            }
        }
        while ${i:Inc} < ${Target.NumEffects}
    }

    return FALSE
}

function CheckForStun()
{
    if !${Target.IsRooted}
        return FALSE
    if ${Target.CanTurn}
        return FALSE

    variable int i = 1

    Target:InitializeEffects
    wait 5
    if (${Target.NumEffects} > 0)
    {
        do
        {
            ;echo "DEBUG: Checking Target Effect #${i}: ${Target.Effect[${i}].Name}"
            if (${MezSpells.Element[${Target.Effect[${i}].Name}](exists)})
                return FALSE
        }
        while ${i:Inc} < ${Target.NumEffects}
    }

    return TRUE
}

function ReacquireTargetFromMA()
{
    ;echo "DEBUG (ReacquireTargetFromMA): Old Target: ${Target}"
    if (${Actor[Exactname,${MainAssist}](exists)})
    {
        target ${MainAssist}
        wait 2
        if (${Actor[ExactName,${MainAssist}].Target.Type.Equal[NPC]} || ${Actor[ExactName,${MainAssist}].Target.Type.Equal[NamedNPC]}) && ${Actor[ExactName,${MainAssist}].Target.InCombatMode}
	    {
			KillTarget:Set[${Actor[ExactName,${MainAssist}].Target.ID}]
			target ${KillTarget}
			;echo "DEBUG (ReacquireTargetFromMA): New Target Acquired: ${Target}"
			return TRUE
		}
    }

    target ${MainAssist}
    echo "DEBUG: (ReacquireTargetFromMA): MA has no target right now..."
    return FALSE
}

atom AutoFollowTank()
{
    if !${Me.InCombat}
    {
        UIElement[AutoFollow@@Extras@EQ2Bot Tabs@EQ2 Bot]:SetChecked

    	SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[EQ2BotExtras]:Set["Auto Follow Mode",TRUE]:Save

        ;echo "DEBUG-AutoFollowTank() -- AutoFollowTank(): Me.ToActor.WhoFollowingID = ${Me.ToActor.WhoFollowingID}"
        ;echo "DEBUG-AutoFollowTank() -- AutoFollowTank(): Me.ToActor.WhoFollowing = ${Me.ToActor.WhoFollowing}"
        ;echo "DEBUG-AutoFollowTank() -- AutoFollowTank(): AutoFollowee = ${AutoFollowee}"

    	;echo "DEBUG-AutoFollowTank(): AutoFollowLastSetTime: ${AutoFollowLastSetTime}"
    	;echo "DEBUG-AutoFollowTank(): Time Now: ${Time.Timestamp}"
    	;echo "DEBUG-AutoFollowTank(): TimeLookingFor: ${Math.Calc64[${AutoFollowLastSetTime}+5]}"
        if (${Time.Timestamp} > ${Math.Calc64[${AutoFollowLastSetTime}+5]})
        {
            ;echo "DEBUG-AutoFollowTank(): Following...."
            if (${Actor[pc,${AutoFollowee}](exists)} && ${Actor[pc,${AutoFollowee}].Distance} < 45)
            {
            	if !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]} 
            	{
            	    ; When an actor is on a griffon-like transport, their speed is always "1"
            	    if (${Actor[pc,${AutoFollowee}].Speed} != 1 && ${Me.ToActor.Speed} != 1)
            	    {
                	    if (!${Me.ToActor.IsClimbing} && !${Actor[pc,${AutoFollowee}].IsClimbing})
                	    {
                    		squelch face ${AutoFollowee}
                    		eq2execute /follow ${AutoFollowee}
                    		AutoFollowLastSetTime:Set[${Time.Timestamp}]
                    		AutoFollowingMA:Set[TRUE]
                    		AutoFollowMode:Set[TRUE]
                    	}
                    	else
                    	{
                    	    AutoFollowingMA:Set[FALSE]
                    	    ;echo "DEBUG-AutoFollowTank(): Either I or the 'AutoFollowee' is currently climbing a wall!"
                    	}
                    }
                    else
                    {
                        ;echo "DEBUG-AutoFollowTank(): Either I am, or the 'AutoFollowee' is, currently on a fast moving transport mount!"
                        AutoFollowingMA:Set[FALSE]
                    }
            	}
            	else
            	{
            	    AutoFollowingMA:Set[FALSE]
            	    ;echo "DEBUG-AutoFollowTank(): Either I am already following ${AutoFollowee}..."
            	}
            }
            else
            {
                AutoFollowingMA:Set[FALSE]
                ;echo "DEBUG-AutoFollowTank(): Hmmm... ${AutoFollowee} does not seem to be in range at all..."
            }
    	}
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

atom EQ2_StartedZoning()
{
}

atom EQ2_FinishedZoning(string TimeInSeconds)
{
    if ${AutoFollowMode}
    {
        if (${Actor[pc,${AutoFollowee}](exists)})
        {
            if (!${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
            {
        		squelch face ${AutoFollowee}
        		eq2execute /follow ${AutoFollowee}
        		AutoFollowingMA:Set[TRUE]
        		AutoFollowMode:Set[TRUE]
    	    }
        }
    }
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
		if ${Math.Calc64[${Time.Timestamp} - ${SwapStartTime}]}>=2
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
	declare ShardTypeL string local "NOSHARD"


	if ${Me.Inventory["Shard of Essence"](exists)}
	{
		ShardTypeL:Set[Shard of Essence]
	}
	elseif ${Me.Inventory["Sliver of Essence"](exists)}
	{
		ShardTypeL:Set[Sliver of Essence]
	}
	elseif ${Me.Inventory["Scintilla of Essence"](exists)}
	{
		ShardTypeL:Set[Scintilla of Essence]
	}
	elseif ${Me.Inventory["Scale of Essence"](exists)}
	{
		ShardTypeL:Set[Scale of Essence]
	}
	elseif ${Me.Inventory["Splintered Heart"](exists)}
	{
		ShardTypeL:Set[Splintered Heart]
	}
	elseif ${Me.Inventory["Darkness Heart"](exists)}
	{
		ShardTypeL:Set[Darkness Heart]
	}
	elseif ${Me.Inventory["Sacrificial Heart"](exists)}
	{
		ShardTypeL:Set[Sacrificial Heart]
	}
	elseif ${Me.Inventory["Ruinous Heart"](exists)}
	{
		ShardTypeL:Set[Ruinous Heart]
	}

	if ${ShardTypeL.NotEqual[NOSHARD]} && ${Me.ToActor.Power}<65 && ${Me.Inventory[${ShardTypeL}].IsReady}
	{
		Me.Inventory[${ShardTypeL}]:Use
		ShardRequested:Set[FALSE]
	}

	if !${Me.Inventory[${ShardTypeL}](exists)} && !${ShardRequested} && ${ShardMode}
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
	declare counter int local 0

	do
	{
		;check groupmates health
		if ${Me.Group[${counter}].ToActor.Health} < ${MinHealth} && ${Me.Group[${counter}].ToActor.Health} > 0
		{
			Return FALSE
		}

		;check health of summoner pets
		if ${Me.Group[${counter}].Class.Equal[conjuror]} || ${Me.Group[${counter}].Class.Equal[necromancer]} || ${Me.Group[${counter}].Class.Equal[illusionist]}
		{
			if ${Me.Group[${counter}].ToActor.Pet.Health} < ${MinHealth} && ${Me.Group[${counter}].ToActor.Pet.Health} > 0
			{
				Return FALSE
			}
		}

	}
	while ${counter:Inc} < ${Me.GroupCount}

	if ${Me.ToActor.Health} < ${MinHealth}
	{
		Return FALSE
	}

	Return TRUE
}

function PetAttack()
{
    ;echo "Calling PetAttack() -- Me.Pet.Target.ID: ${Me.Pet.Target.ID}"
    
    if !${Actor[id,${KillTarget}](exists)}
        return
    
	if ${Me.Pet.Target.ID} != ${KillTarget}
	{
		EQ2Execute /pet backoff
		target ${KillTarget}
		EQ2Execute /pet attack
		wait 4 (${Me.Pet.Target.ID} != ${KillTarget})
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
	if ${Actor[${Me.ToActor.WhoFollowing}].Distance}>25 && (${Math.Calc64[${Time.Timestamp} - ${StuckWarningTime}]}>=10)  && ${Actor[${Me.ToActor.WhoFollowing}](exists)}
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
		elseif ${Me.Inventory[ExactName,"${Item}"].IsReady} && ${Math.Calc64[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
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

				if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<${Health}
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


function CheckHealthiness(int GroupHealth, int MTHealth, int MyHealth)
{
	declare counter int local 1

	do
	{

		;check groupmates health
		if ${Me.Group[${counter}].ToActor.Health}<${GroupHealth} && ${Me.Group[${counter}].ToActor.Health}>0
		{
			Return FALSE
		}

		;check health of summoner pets
		if ${Me.Group[${counter}].Class.Equal[conjuror]} || ${Me.Group[${counter}].Class.Equal[necromancer]}
		{
			if ${Me.Group[${counter}].ToActor.Pet.Health}<${GroupHealth} && ${Me.Group[${counter}].ToActor.Pet.Health}>0
			{
				Return FALSE
			}
		}

	}
	while ${counter:Inc}<${Me.GroupCount}

	;check mt health
	call GetActorID ${MainTankPC}
	if ${Return} && ${Actor[${Return}].Health}<${MTHealth}
	{
		Return FALSE
	}

	;check my health
	if ${Me.ToActor.Health}<${MyHealth}
	{
		Return FALSE
	}

	Return TRUE
}

atom(script) ChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
	switch ${ChatType}
	{

		case 28
		case 27
		case 26
		case 15
		case 16
			if ${Message.Find[${OutTrigger}]} && ${JoustMode} && ${Me.InCombat}
			{
				JoustStatus:Set[1]
			}
			elseif ${Message.Find[${InTrigger}]} && ${JoustMode} && ${Me.InCombat}
			{
				JoustStatus:Set[0]
			}
			elseif ${Message.Find[${BDTrigger}]}
			{
				BDStatus:Set[1]
			}
		case 18
		case 8
			if (${Message.Upper.Find[SHARD]} || ${Message.Upper.Find[HEART]}) && ${Me.Class.Equal[summoner]}
			{
				call QueueShardRequest ${Speaker} ${Speaker}
			}
			break
		default
			break
	}
}

;returns the ID of your healer in group, if none found, returns your ID
function FindHealer()
{
	declare tempgrp int local 0
	declare	healer int local 0

	if !${Me.Grouped}
	{
		return ${Me.ID}
	}

	healer:Set[${Me.ID}]

	do
	{
		switch ${Me.GroupMember[${tempgrp}].Class}
		{
			case templar
			case fury
			case mystic
			case defiler
				healer:Set[${Me.GroupMember[${tempgrp}].ToActor.ID}]
				break
			case warden
			case inquisitor
				;don't trust priests that have melee configs unless no other priest is available
				if ${healer}==${Me.ID}
				{
					healer:Set[${Me.GroupMember[${tempgrp}].ToActor.ID}]
				}
				break
			Default
				break
		}

	}
	while ${tempgrp:Inc}<${Me.GroupCount}

    if (${Me.InRaid})
    {
    	if (${healer} == ${Me.ID})
    	{
    		tempgrp:Set[0]
    
    		do
    		{
    			switch ${Me.RaidMember[${tempgrp}].Class}
    			{
    				case templar
    				case fury
    				case mystic
    				case defiler
    					healer:Set[${Actor[exactname,pc,${Me.RaidMember[${tempgrp}].Name}].ID}]
    					break
    				case warden
    				case inquisitor
    					if ${healer}==${Me.ID}
    						healer:Set[${Actor[exactname,pc,${Me.RaidMember[${tempgrp}].Name}].ID}]
    					break
    				Default
    					break
    			}
    		}
    		while (${tempgrp:Inc} <= ${Me.RaidCount})
    	}
    }

	return ${healer}
}

function CheckCures()
{
    ; Create our custom inventory array so that we are up to date with quantities
    ; Possible furture feature - use counts to determine if we should fallback to a lesser potion
	Me:CreateCustomInventoryArray[nonbankonly]

    ; incurable afflictions have a value of -1
    ; so we test >=1 to insure we are not wasting potions
	if ${Me.Arcane}>=1
	{
	    ; check to see if we have more of our selected potion
		if ${Me.CustomInventory[${ArcanePotion}](exists)}
		{
			; Debug: echo casting arcane potion
			call CastPotion "${ArcanePotion}"
		}
		else
		{
		    ; Display a messagebox to let us know if we have run out of potions
		    ; Squelch causes error text to be hidden from console if we try to open
		    ; more than one messagebox
		    ; Possible future feature - move this to it's own function and give it audio feedback
			if ${AWarn}
			{
				Squelch MessageBox -ok "You have run out of \${ArcanePotion}" 3 2
				AWarn:Set[FALSE]
			}
		}
	}

	if ${Me.Elemental}>=1
	{
		if ${Me.CustomInventory[${ElementalPotion}](exists)}
		{
			; Debug: echo casting elemental potion
			call CastPotion "${ElementalPotion}"
		}
		else
		{
			if ${EWarn}
			{
				Squelch MessageBox -ok "You have run out of \${ElementalPotion}" 3 2
				EWarn:Set[FALSE]
			}
		}
	}

	if ${Me.Noxious}>=1
	{
		if ${Me.CustomInventory[${NoxiousPotion}](exists)}
		{
			; Debug: echo casting noxious potion
			call CastPotion "${NoxiousPotion}"
		}
		else
		{
			if ${NWarn}
			{
				Squelch MessageBox -ok "You have run out of \${NoxiousPotion}" 3 2
				NWarn:Set[FALSE]
			}
		}
	}

	if ${Me.Trauma}>=1
	{
		if ${Me.CustomInventory[${TraumaPotion}](exists)}
		{
			; Debug: echo casting trauma potion
			call CastPotion "${TraumaPotion}"
		}
		else
		{
			if ${TWarn}
			{
				Squelch MessageBox -ok "You have run out of \${TraumaPotion}"
				TWarn:Set[FALSE]
			}
		}
	}
}

function CastPotion(string Item)
{
    ; Do not cast if we are moving or if the potion is not ready
	if ${Me.IsMoving} || !${Me.Inventory[ExactName,"${Item}"].IsReady}
	{
		return
	}

    ; Use the potion
	Me.Inventory[ExactName,"${Item}"]:Use

	;if spells are being interupted do to movement
	;increase the wait below slightly. Default=10
	wait 10

    ; wait until we have finished casting
	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	return SUCCESS
}


;*************************************************************
;EQ2HOlib
;version 200607020a
;added soldier's instinct
;fixed bug with Archaic Shackles
;fixed bug with Soldier's Gambit
;State 6 = Last advance wheel
;State 5 = Second advance wheel for 3 stage ho advances
;State 4 = Initial advance wheel
;State 3 = scout cant change wheel?
;State 1 = Wheel is being completed
;State 2 = expired or completed wheel
;state 0 = scout can change wheel?
;
;
;States changed these are the new assumptions
;State 6 = Last advance wheel
;State 5 = Second advance wheel for 3 stage ho advances
;State 4 = Initial advance wheel
;State 3 = scout cant change wheel?
;State 1 = Wheel is being completed
;State 2 = HO in countdown
;state 0 = scout can change wheel?
;
;Note all HOs have 10seconds to complete
;All HO buffs last 6 mins
;TODO: Add check if we have enough time to complete HO before we cast?
;TODO: Refresh HO Buffs?
;TODO: Prioritize HOs?
;*************************************************************

objectdef HeroicOp
{
	variable string ScoutCoin1
	variable string ScoutCoin2
	variable string ScoutDagger1
	variable string ScoutDagger2
	variable string ScoutCloak1
	variable string ScoutCloak2
	variable string ScoutMask1
	variable string ScoutMask2
	variable string ScoutBow1
	variable string ScoutBow2

	variable string MageStar1
	variable string MageStar2
	variable string MageLightning1
	variable string MageLightning2
	variable string MageFlame1
	variable string MageFlame2
	variable string MageStaff1
	variable string MageStaff2
	variable string MageWand1
	variable string MageWand2

	variable string FighterHorn1
	variable string FighterHorn2
	variable string FighterBoot1
	variable string FighterBoot2
	variable string FighterArm1
	variable string FighterArm2
	variable string FighterFist1
	variable string FighterFist2
	variable string FighterSword1
	variable string FighterSword2

	variable string PriestHammer1
	variable string PriestHammer2
	variable string PriestChalice1
	variable string PriestChalice2
	variable string PriestMoon1
	variable string PriestMoon2
	variable string PriestHolySymbol1
	variable string PriestHolySymbol2
	variable string PriestEye1
	variable string PriestEye2

	variable string charfile="${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Character Config/${Me.Name}.xml"

	method Initialize()
	{

		switch ${Me.Archetype}
		{
			case fighter
				FighterSword1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterSword1,""]}]
				FighterSword2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterSword2,""]}]
				FighterHorn1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterHorn1,""]}]
				FighterHorn2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterHorn2,""]}]
				FighterBoot1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterBoot1,""]}]
				FighterBoot2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterBoot2,""]}]
				FighterArm1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterArm1,""]}]
				FighterArm2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterArm2,""]}]
				FighterFist1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterFist1,""]}]
				FighterFist2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[FighterFist1,""]}]
				break

			case scout
				ScoutCoin1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCoin1,""]}]
				ScoutCoin2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCoin2,""]}]
				ScoutDagger1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutDagger1,""]}]
				ScoutDagger2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutDagger2,""]}]
				ScoutCloak1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCloak1,""]}]
				ScoutCloak2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutCloak2,""]}]
				ScoutMask1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutMask1,""]}]
				ScoutMask2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutMask2,""]}]
				ScoutBow1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutBow1,""]}]
				ScoutBow2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[ScoutBow2,""]}]
				break

			case mage
				This.MageStar1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStar1,""]}]
				This.MageStar2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStar2,""]}]
				This.MageLightning1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageLightning1,""]}]
				This.MageLightning2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageLightning2,""]}]
				This.MageFlame1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageFlame1,""]}]
				This.MageFlame2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageFlame2,""]}]
				This.MageStaff1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStaff1,""]}]
				This.MageStaff2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageStaff2,""]}]
				This.MageWand1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageWand1,""]}]
				This.MageWand2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[MageWand2,""]}]
				break

			case priest
				PriestHammer1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHammer1,""]}]
				PriestHammer2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHammer2,""]}]
				PriestChalice1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestChalice1,""]}]
				PriestChalice2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestChalice2,""]}]
				PriestMoon1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestMoon1,""]}]
				PriestMoon2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestMoon2,""]}]
				PriestEye1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestEye1,""]}]
				PriestEye2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestEye2,""]}]
				PriestHolySymbol1:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHolySymbol1,""]}]
				PriestHolySymbol2:Set[${SettingXML[${charfile}].Set[EQ2BotExtras].Set[HeroicOp].GetString[PriestHolySymbol2,""]}]
				break

			case default
				break

		}
	}

	method Shutdown()
	{
		CurentTask:Set[Shutdown]
	}

	member ToText()
	{
		return ${Me.Name}
	}

	method LoadUI()
	{
		UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[HOs]

		UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[6]:Move[3]

		ui -load -parent "HOs@EQ2Bot Tabs@EQ2 Bot" "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/UI/${Me.Archetype}HOs.xml"
	}

	method DoHO()
	{
		;echo State: ${EQ2.HOWheelState}
		;echo Slot: ${EQ2.HOCurrentWheelSlot}
		;echo Advanced by:${This.LastManipulatorArchetype}
		;echo HO Name ${EQ2.HOName}
		;Make sure we have a target to cast on,

		Target ${Script[EQ2Bot].Variable[KillTarget]}

		;Beneficial spells will cast on the KillTarget's current target
		;Detrimentals will cast on the KillTarget
		;This is atomic so we dont need a wait check for the target
		;though the target could be dead by the time the HO advancement
		;or completion spell is cast



		if ${EQ2.HOWheelState}==0 || ${EQ2.HOWheelState}==1 || ${EQ2.HOWheelState}==6
		;State 0 = First wheel after HO intiation
		{
			switch ${This.LastManipulatorArchetype}
			{
				;Scout Intiated HO
				case scout
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							This:CastChalice
							break
						case fighter
							;Pritorizes horn over boot HO advancement. Horn is mostly taunts
							;For non tank fighters reverse boot and horn priority
							if ${Me.Ability[${FighterHorn1}].IsReady} || ${Me.Ability[${FighterHorn2}].IsReady}
							{
								This:CastHorn
							}
							elseif
							{
								This:CastBoot
							}
							break
						case mage
							break
						case default
							break
					}
				;Mage Initiated HO
				case mage
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							This:CastHammer
							break
						case fighter
							break
						case mage
							This:CastLightning
							break
						case default
							break
					}
				;Fighter initiated HO
				case fighter
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							;Priority is chalice which is most priest heals
							;Swap hammer and chalice prioirity for more damage
							;realated HOs
							if ${Me.Ability[${PriestChalice1}].IsReady} || ${Me.Ability[${PriestChalice2}].IsReady}
							{
								This:CastChalice
							}
							elseif
							{
								This:CastHammer
							}
							break
						case fighter
							This:CastSword
							break
						case mage
							;This HO advancement is not visible on the wheel.
							;It is a hidden 5th HO advancement choice from a fighter
							;Initiated HO
							This:CastLightning
							break
						case default
							break
					}
				;Priest Intiated HO
				case priest
					switch ${Me.Archetype}
					{
						case scout
							This:CastCoin
							break
						case priest
							This:CastHammer
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				case default
					break

			}

		}
		elseif ${EQ2.HOWheelState}==3
		;State 5 = Second wheel after HO intiation for 3 stage HO advancements
		{
			switch ${This.LastManipulatorArchetype}
			{
				;Scout Advanced HO
				case scout
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Mage Advanced HO
				case mage
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Fighter advanced HO
				case fighter
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							This:CastMoon
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Priest advanced HO
				case priest
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							This:CastLightning
							break
						case default
							break
					}
				case default
					break

			}

		}
		elseif ${EQ2.HOWheelState}==5 && ${EQ2.HOName(exists)}
		;State 6 = Second wheel after HO intiation for 2 stage HO advancements
		{
			switch ${This.LastManipulatorArchetype}
			{
				;Scout Advanced HO
				case scout
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Mage Advanced HO
				case mage
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							break
						case default
							break
					}
				;Fighter advanced HO
				case fighter
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							This:CastMoon
							break
						case fighter
							break
						case mage
							This:CastLightning
							break
						case default
							break
					}
				;Priest advanced HO
				case priest
					switch ${Me.Archetype}
					{
						case scout
							break
						case priest
							break
						case fighter
							break
						case mage
							;Three combos lead here so we will cast both
							;Moon->Fire
							;Chalice->Lightning
							;Hammer->lightning
							This:CastLightning
							This:CastFlame
							break
						case default
							break
					}
				case default
					break

			}

		}
		elseif ${EQ2.HOWheelState}==5 || ${EQ2.HOWheelState}==4 || ${EQ2.HOWheelState}==2


		{
			switch ${EQ2.HOName}
			{

				;*****************************************************************
				;	Fighter Intiated HOs
				;*****************************************************************

				case Sky Cleave
				;Single Target Slashing DD
				case Crushing Anvil
				; Encounter AoE Crushing DD
				case Hero's Armor
				;Self Armor Buff
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}
					break
				case Divine Blade
				;Single Target Divine DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					break
				case Crippling Shroud
				; Has a Chance to Slow Enemy Attack Speed When You Are Hit

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastMoon
					}
					break
				case  Chalice of Life
				;Group Instant Heal, Ward, & Health Regeneration

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				case Divine Nobility
				; Heal Over Time to a Group Memeber

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					break
				case Archaic Ruin
				;Single Target Mental DD
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastEye
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastArm
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastFlame
					}
					break
				case Thunder Slash
				;Single Target Divine, Magic, & Slashing DD (3 different hits)

					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					break
				case Ancient Wrath
				; Encounter AoE Long Duration Stun and DD

					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFlame
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastFist
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastHammer
					}
					break
				case Luck's Bite
				;Single Target Piercing DD

					if ${Me.Archetype.Equal[scout]}
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastBoot
					}
					break
				case Swindler's Gift
				;Group Attack Technique Buff (slashing, piercing, etc.)

					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastArm
					}
					break
				case Raging Sword
				;Powerful Slashing DD

					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastHorn
					}
					break
				case Ardent Challenge
				;Group Strength and Agility Buff (+10)

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastArm
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastMask
					}
					break
				case Scholar's Insight
				; Self Attack Speed Buff

					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastHorn
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastLightning
					}
					break
				case Storm of Ancients
				;Encounter AoE Magic DD

					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break
				case  Soldier's Instinct
				;Self Evocations and Disruptions Buff

					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFlame
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastArm
					}
					break
				case Arcane Salvation
				;Group Power Restoration
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastArm
					}
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				;*****************************************************************
				;	Scout Intiated HOs
				;*****************************************************************
				case Swindler's Luck
				;Self Attack Buff
				case Ringing Blow
				;Single Target Piercing DD
				case Bravo's Dance
				;Self Attack Speed Buff
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastDagger
					}
					break
				case Breaking Faith
				;Single Target Divine DD
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastEye
					}
					break
				case Archaic Shackles
				;Encounter AoE Attack Speed Debuff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastDagger
					}
					break
				case Crucible of Life
				;Full Power and Health Replenishment & Healing Proc Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCoin
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastChalice
					}
					break

				case Verdant Trinity
				;Group Instant Heal
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastChalice
					}
					break
				case Nature's Growth
				;Group Regeneration
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastMask
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					break
				case Capricious Strike
				;Single Target DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					break
				case Shield of Ancients
				;Group Armor Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastHorn
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastMoon
					}
					break
				case Trinity Divide
				;Encounter AoE Piercing DD
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastMask
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastHorn
					}
					break
				case Soldier's Gambit
				;Single Target Magic DD
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastSword
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break
				case Grand Proclamation
				;Group Increase Power Pool Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastMask
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastArm
					}
					break
				case Ancient's Embrace
				;Group Slashing Damage Shield Buff
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCloak
					}
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastArm
					}
					break
				case Strength in Unity
				;Group STR, AGI, INT, WIS Buff (+10)
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastArm
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastChalice
					}
					break
				case Ancient Demise
				;Encounter AoE Crushing DD
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastBoot
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCoin
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==3
					{
						This:CastHammer
					}
					break
				case Tears of Luclin
				;Powerful Magic DD
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastBoot
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break
				case Past's Awakening
				;Massive DD & Full Group Health and Power Restoration
					if ${Me.Archetype.Equal[fighter]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFist
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastStar
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastCloak
					}
					break

				;*****************************************************************
				;	Mage Intiated HOs
				;*****************************************************************

				case Arcane Fury
				;Single Target Magic DD
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break
				case Arcane Storm
				;Encounter Magic AoE DD
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}
					break
				case Arcane Enlightenment
				;Self Power Regeneration Buff
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastFlame
					}
					break
				case Arcane Chalice
				;Power Restoration
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastFlame
					}
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				case Arcane Aegis
				;Power Restoration
					if ${Me.Archetype.Equal[fighter]}
					{
						This:CastFist
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastStar
					}
					break
				case Suffocating Wrath
				;Encounter AoE Magic DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break
				case Ancient Crucible
				;Instant Health and Power Replenishment & Health and Power Regeneration
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastMoon
					}
					break
				case Arcane Trickery
				;Single Target Magic DD & Magic and Piercing Mitigation Debuff
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastFlame
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}
					break
				case Trickster's Grasp
				;Single Target Magic DoT
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastFlame
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastDagger
					}
					break
				case Shower of Daggers
				;Magic DD Proc Buff
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}
					break
				case Resonating Cascade
				;Power Regeneration Buff
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastMask
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastDagger
					}
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					break
				case Celestial Bloom
					if ${Me.Archetype.Equal[mage]}
					{
						This:CastLightning
					}
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				case Luminary Fate
				;Grants power regeneration over time.
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastDagger
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastEye
					}
					if ${Me.Archetype.Equal[mage]} && ${EQ2.HOCurrentWheelSlot}==2
					{
						This:CastFlame
					}
				;*****************************************************************
				;	Priest Intiated HOs
				;*****************************************************************

				case Divine Judgement
				;Single Target Divine DD
				case Inspiring Piety
				;Single Target Divine DD & Self Inspirations Buff (+10)
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastHammer
					}
					break
				case Blessing of Faith
				;Self Buff That has a Chance to Replish Power When You Are Hit
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastChalice
					}
					break
				case Piercing Faith
				;Single Target Piercing DD
					if ${Me.Archetype.Equal[priest]}
					{
						This:CastMoon
					}
					if ${Me.Archetype.Equal[scout]}
					{
						This:CastCloak
					}
					break
				case Divine Trickery
				;Single Target Divine DD & Divine and Piercing Mitigation Debuff
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastHammer
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCloak
					}
					break
				case Faith's Bulwark
				;Group Armor Buff
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastChalice
					}
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastCoin
					}
					break
				case Fervent Quickening
				;Increases defense by 10 and periodically grants power to the player that completes the Heroic Opportunity
					if ${Me.Archetype.Equal[scout]} && ${EQ2.HOCurrentWheelSlot}==0
					{
						This:CastDagger
					}
					if ${Me.Archetype.Equal[priest]} && ${EQ2.HOCurrentWheelSlot}==1
					{
						This:CastChalice
					}
					break
				case default
					echo ******UNKNOWN HO ${EQ2.HOName}*******
					break
			}
		}
	}
	;End Method HO


	;*****************************************************************
	;	Fighter Methods
	;*****************************************************************

	method CastSword()
	{
		if ${Me.Ability[${FighterSword1}].IsReady}
		{
			Me.Ability[${FighterSword1}]:Use
		}
		elseif ${Me.Ability[${FighterSword2}].IsReady}
		{
			Me.Ability[${FighterSword2}]:Use
		}
	}
	method CastHorn()
	{
		if ${Me.Ability[${FighterHorn1}].IsReady}
		{
			Me.Ability[${FighterHorn1}]:Use
		}
		elseif ${Me.Ability[${FighterHorn2}].IsReady}
		{
			Me.Ability[${FighterHorn2}]:Use
		}
	}
	method CastBoot()
	{
		if ${Me.Ability[${FighterBoot1}].IsReady}
		{
			Me.Ability[${FighterBoot1}]:Use
		}
		elseif ${Me.Ability[${FighterBoot2}].IsReady}
		{
			Me.Ability[${FighterBoot2}]:Use
		}
	}
	method CastFist()
	{
		if ${Me.Ability[${FighterFist1}].IsReady}
		{
			Me.Ability[${FighterFist1}]:Use
		}
		elseif ${Me.Ability[${FighterFist2}].IsReady}
		{
			Me.Ability[${FighterFist2}]:Use
		}
	}
	method CastArm()
	{
		if ${Me.Ability[${FighterArm1}].IsReady}
		{
			Me.Ability[${FighterArm1}]:Use
		}
		elseif ${Me.Ability[${FighterArm2}].IsReady}
		{
			Me.Ability[${FighterArm2}]:Use
		}
	}

	;*****************************************************************
	;	Scout Methods
	;*****************************************************************

	method CastCoin()
	{
		if ${Me.Ability[${ScoutCoin1}].IsReady}
		{
			Me.Ability[${ScoutCoin1}]:Use
		}
		elseif ${Me.Ability[${ScoutCoin2}].IsReady}
		{
			Me.Ability[${ScoutCoin2}]:Use
		}
	}
	method CastDagger()
	{
		if ${Me.Ability[${ScoutDagger1}].IsReady}
		{
			Me.Ability[${ScoutDagger1}]:Use
		}
		elseif ${Me.Ability[${ScoutDagger2}].IsReady}
		{
			Me.Ability[${ScoutDagger2}]:Use
		}
	}
	method CastCloak()
	{
		if ${Me.Ability[${ScoutCloak1}].IsReady}
		{
			Me.Ability[${ScoutCloak1}]:Use
		}
		elseif ${Me.Ability[${ScoutCloak2}].IsReady}
		{
			Me.Ability[${ScoutCloak2}]:Use
		}
	}
	method CastBow()
	{
		if ${Me.Ability[${ScoutBow1}].IsReady}
		{
			Me.Ability[${ScoutBow1}]:Use
		}
		elseif ${Me.Ability[${ScoutBow2}].IsReady}
		{
			Me.Ability[${ScoutBow2}]:Use
		}
	}
	method CastMask()
	{
		if ${Me.Ability[${ScoutMask1}].IsReady}
		{
			Me.Ability[${ScoutMask1}]:Use
		}
		elseif ${Me.Ability[${ScoutMask2}].IsReady}
		{
			Me.Ability[${ScoutMask2}]:Use
		}
	}

	;*****************************************************************
	;	Mage Methods
	;*****************************************************************

	method CastStar()
	{
		if ${Me.Ability[${MageStar1}].IsReady}
		{
			Me.Ability[${MageStar1}]:Use
		}
		elseif ${Me.Ability[${MageStar2}].IsReady}
		{
			Me.Ability[${MageStar2}]:Use
		}

	}
	method CastLightning()
	{
		if ${Me.Ability[${MageLightning1}].IsReady}
		{
			Me.Ability[${MageLightning1}]:Use
		}
		elseif ${Me.Ability[${MageLightning2}].IsReady}
		{
			Me.Ability[${MageLightning2}]:Use
		}
	}
	method CastFlame()
	{
		if ${Me.Ability[${MageFlame1}].IsReady}
		{
			Me.Ability[${MageFlame1}]:Use
		}
		elseif ${Me.Ability[${MageFlame2}].IsReady}
		{
			Me.Ability[${MageFlame2}]:Use
		}
	}
	method CastStaff()
	{
		if ${Me.Ability[${MageStaff1}].IsReady}
		{
			Me.Ability[${MageStaff1}]:Use
		}
		elseif ${Me.Ability[${MageStaff2}].IsReady}
		{
			Me.Ability[${MageStaff2}]:Use
		}
	}
	method CastWand()
	{
		if ${Me.Ability[${MageWand1}].IsReady}
		{
			Me.Ability[${MageWand1}]:Use
		}
		elseif ${Me.Ability[${MageWand2}].IsReady}
		{
			Me.Ability[${MageWand2}]:Use
		}
	}

	;*****************************************************************
	;	Priest Methods
	;*****************************************************************

	method CastChalice()
	{
		if ${Me.Ability[${PriestChalice1}].IsReady}
		{
			Me.Ability[${PriestChalice1}]:Use
		}
		elseif ${Me.Ability[${PriestChalice2}].IsReady}
		{
			Me.Ability[${PriestChalice2}]:Use
		}
	}
	method CastHammer()
	{
		if ${Me.Ability[${PriestHammer1}].IsReady}
		{
			Me.Ability[${PriestHammer1}]:Use
		}
		elseif ${Me.Ability[${PriestHammer2}].IsReady}
		{
			Me.Ability[${PriestHammer2}]:Use
		}
	}
	method CastEye()
	{
		if ${Me.Ability[${PriestEye1}].IsReady}
		{
			Me.Ability[${PriestEye1}]:Use
		}
		elseif ${Me.Ability[${PriestEye2}].IsReady}
		{
			Me.Ability[${PriestEye2}]:Use
		}
	}
	method CastHolySymbol()
	{
		if ${Me.Ability[${PriestHolySymbol1}].IsReady}
		{
			Me.Ability[${PriestHolySymbol1}]:Use
		}
		elseif ${Me.Ability[${PriestHolySymbol2}].IsReady}
		{
			Me.Ability[${PriestHolySymbol2}]:Use
		}
	}
	method CastMoon()
	{
		if ${Me.Ability[${PriestMoon1}].IsReady}
		{
			Me.Ability[${PriestMoon1}]:Use
		}
		elseif ${Me.Ability[${PriestMoon2}].IsReady}
		{
			Me.Ability[${PriestMoon2}]:Use
		}
	}

	member LastManipulatorArchetype()
	{

		switch ${EQ2.HOLastManipulator.Class}
		{
			case defiler
			case mystic
			case warden
			case fury
			case inquisitor
			case templar
				return priest
				break
			case berserker
			case guardian
			case monk
			case bruiser
			case paladin
			case shadowknight
				return fighter
				break
			case conjuror
			case necromancer
			case coercer
			case illusionist
			case wizard
			case warlock
				return mage
				break
			case troubador
			case dirge
			case swashbuckler
			case brigand
			case ranger
			case assasin
				return scout
				break
			case default
				break
		}

	}
}