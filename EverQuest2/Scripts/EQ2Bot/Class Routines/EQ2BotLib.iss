;============================================
;
;EQ2BotLib
;originally by Karye
;updated by Pygar and Amadeus
;============================================

#define _Eq2Botlib_

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
variable bool HeartMode=FALSE
variable string ShardGroupMember
variable string HeartGroupMember
variable bool ShardRequested=FALSE
variable bool HeartRequested=FALSE

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
variable string BDTrigger
;0 is in 1 is out
variable bool JoustStatus=FALSE
variable bool BDStatus=FALSE

;Potion vars
variable bool UsePotions
variable bool UseCurePotions
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

; SK FD Spells
variable(script) collection:int SKFDSpells

;AutoFollow Variables
variable bool AutoFollowMode=FALSE
variable bool RetainAutoFollowInCombat=FALSE
variable bool AutoFollowingMA=FALSE
variable bool CombatFollow=FALSE
variable string AutoFollowee
variable uint AutoFollowLastSetTime

;BGs
variable bool BG_NoCombat

;misc
variable bool EpicMode=FALSE
variable bool DoCallCheckPosition=FALSE
variable filepath StrRes_Filepath=${PATH_UI}/

function EQ2BotLib_Init()
{

	;INI Settings
	CharacterSet:AddSet[EQ2BotExtras]

	AutoFollowMode:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Auto Follow Mode,FALSE]}]
	RetainAutoFollowInCombat:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[RetainAutoFollowInCombat,FALSE]}]
	NoAutoMovement:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[NoAutoMovement,FALSE]}]
	NoAutoMovementInCombat:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[NoAutoMovementInCombat,FALSE]}]
	CombatFollow:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[CombatFollow,FALSE]}]
	EpicMode:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[EpicMode,FALSE]}]
	AutoFollowee:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[AutoFollowee,""]}]
	WarnTankWhenAggro:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Warn tank when I have a mob on me,FALSE]}]
	ShardMode:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Shard Mode,FALSE]}]
	ShardGroupMember:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Shard Group Member,""]}]
	HeartMode:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Heart Mode,FALSE]}]
	HeartGroupMember:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Heart Group Member,""]}]
	DoHOs:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[DoHOs,FALSE]}]
	RelaySession:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[RelaySession,""]}]
	ForwardGuildChat:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[ForwardGuildChat,FALSE]}]

	UsePotions:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Use potions for cures?,FALSE]}]
	UseCurePotions:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Use potions for cures?,FALSE]}]
	ArcanePotion:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Arcane Potion Name,NULL]}]
	ElementalPotion:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Elemental Potion Name,NULL]}]
	NoxiousPotion:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Noxious Potion Name,NULL]}]
	TraumaPotion:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[Trauma Potion Name,NULL]}]
	
	BG_NoCombat:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSetting[BG_NoCombat,TRUE]}]

	;Triggers
	AddTrigger AutoFollowTank "\\aPC @*@ @*@:@sender@\\/a tells@*@Follow Me@*@"
	AddTrigger StopAutoFollowing "\\aPC @*@ @*@:@sender@\\/a tells@*@Wait Here@*@"
	AddTrigger TooClose "@*@Your Target is too close! Move away!"
	AddTrigger ReceivedTell "\\aPC @*@ @*@:@Sender@\\/a tells you,@Message@"

	if ${ForwardGuildChat}
	{
		AddTrigger RelayGuildMessage "\\aPC @*@ @*@:@Sender@\\/a says to the guild,@Message@"
	}

	Event[EQ2_onIncomingChatText]:AttachAtom[ChatText]
	Event[EQ2_onIncomingText]:AttachAtom[MiscText]
	Event[EQ2_StartedZoning]:AttachAtom[EQ2_StartedZoning]
	Event[EQ2_FinishedZoning]:AttachAtom[EQ2_FinishedZoning]

	;HOs
	if ${DoHOs}
	{
		objHeroicOp:Initialize
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
	
	echo Loading Class UI Tab...
	ui -load -parent "Class@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_UI}/${Me.SubClass}.xml"
	
	; Optionally Load the String Tab for those Classes that actually have strings to modify.
	if ${StrRes_Filepath.FileExists[${Me.SubClass}_StrRes.xml]}
	{
			UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Strings]
			;UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[9]
			echo Loading Strings UI Tab...
			ui -load -parent "Strings@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_UI}/${Me.SubClass}_StrRes.xml"
	}
	
	echo Loading Extras UI Tab...
	ui -load -parent "Extras@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_UI}/EQ2BotExtras.xml"

	ExecuteAtom SaveEquipmentSet "Default"

	call PopulateMezSpells
	call PopulateInvisSpells
	call PopulateSKFDSpells

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

    ;Debug:Echo["${InvisSpells.Used} spells were added to the InvisSpells collection."]

    return ${InvisSpells.Used}
}

function PopulateSKFDSpells()
{
	variable int keycount
	variable int iLevel=1
	variable int iType = 0
	variable string tempnme
	variable int tempvar=1
	variable string SpellName
	variable iterator SpellIterator

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Shadowknight FD Spells
	;;;;;
	LavishSettings[EQ2Bot]:AddSet[OtherSpells]
	LavishSettings[EQ2Bot].FindSet[OtherSpells]:Import[${PATH_SPELL_LIST}/Shadowknight.xml]
	LavishSettings[EQ2Bot].FindSet[OtherSpells].FindSet[Shadowknight]:GetSettingIterator[SpellIterator]
	if ${SpellIterator:First(exists)}
	{
		do
		{
			tempnme:Set["${SpellIterator.Key}"]

			iLevel:Set[${Arg[1,${tempnme}]}]
			iType:Set[${Arg[2,${tempnme}]}]
			SpellName:Set[${SpellIterator.Value}]

			;Debug:Echo["Debug: Processing Shadowknight Spell '${SpellName}' (Level: ${iLevel} - Type: ${iType})"]

			switch ${iType}
			{
				case 330
					;Debug:Echo["Shadowknight Spell '${SpellName}' (Level: ${iLevel} was added to the SKFDSpells collection"]
					SKFDSpells:Set[${SpellName},${iLevel}]
					break

				Default
					break
			}

		}
		while ${SpellIterator:Next(exists)}
	}
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	LavishSettings[EQ2Bot]:AddSet[OtherSpells]
	LavishSettings[EQ2Bot].FindSet[OtherSpells]:Import[${PATH_SPELL_LIST}/Illusionist.xml]
	LavishSettings[EQ2Bot].FindSet[OtherSpells].FindSet[Illusionist]:GetSettingIterator[SpellIterator]
	if ${SpellIterator:First(exists)}
	{
		do
		{
			tempnme:Set["${SpellIterator.Key}"]

			iLevel:Set[${Arg[1,${tempnme}]}]
			iType:Set[${Arg[2,${tempnme}]}]
			SpellName:Set[${SpellIterator.Value}]

			;Debug:Echo["Debug: Processing Illusionist Spell '${SpellName}' (Level: ${iLevel} - Type: ${iType})"]

			switch ${iType}
			{
				case 92
				case 352
				case 353
				case 356
					;Debug:Echo["Illusionist Spell '${SpellName}' (Level: ${iLevel} was added to the MezSpells collection"]
					MezSpells:Set[${SpellName},${iLevel}]
					break

				Default
					break
			}
		}
		while ${SpellIterator:Next(exists)}
	}
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Coercer Mez Spells
	;;;;;
	tempvar:Set[1]
	LavishSettings[EQ2Bot].FindSet[OtherSpells]:Import[${PATH_SPELL_LIST}/Coercer.xml]
	LavishSettings[EQ2Bot].FindSet[OtherSpells].FindSet[Coercer]:GetSettingIterator[SpellIterator]
	if ${SpellIterator:First(exists)}
	{
		do
		{
			tempnme:Set["${SpellIterator.Key}"]

			iLevel:Set[${Arg[1,${tempnme}]}]
			iType:Set[${Arg[2,${tempnme}]}]
			SpellName:Set[${SpellIterator.Value}]

			;Debug:Echo["Debug: Processing Coercer Spell '${SpellName}' (Level: ${iLevel} - Type: ${iType})"]

			switch ${iType}
			{
				case 351
				case 352
				case 353
					;Debug:Echo["Coercer Spell '${SpellName}' (Level: ${iLevel} was added to the MezSpells collection"]
					MezSpells:Set[${SpellName},${iLevel}]
					break

				Default
					break
			}
		}
		while ${tempvar:Inc} <= ${keycount}
	}
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;Debug:Echo["${MezSpells.Used} spells were added to the MezSpells collection."]

    return ${MezSpells.Used}
}

function AmIInvis(string param1)
{
	;; TODO: Add other class invisibility spells
    variable int i = 1
	variable bool bReturn = FALSE
	;Debug:Enable

	do
	{
		;Debug:Echo["\at\[EQ2Bot:AmIInvis\]\ax ${i} = ${Me.Effect[${i}].MainIconID} / ${Me.Effect[${i}].BackDropIconID}"]

		;; Illusory Mask (Illusionist) & Untamed Shroud (Fury)
		if (${Me.Effect[${i}].MainIconID} == 231 && ${Me.Effect[${i}].BackDropIconID} == 314)
		{
			bReturn:Set[TRUE]
			break
		}
		;; Veil of the Unseen (Illusionist)
		elseif (${Me.Effect[${i}].MainIconID} == 165 && ${Me.Effect[${i}].BackDropIconID} == 316)
		{
			bReturn:Set[TRUE]
			break
		}
	}
	while (${i:Inc} <= ${Me.NumEffects})

	if (${bReturn})
	{
		Debug:Echo["\at\[EQ2Bot:AmIInvis\]\ax Returning \arTRUE\ax! (Called By: ${param1})"]
		return TRUE
	}

	;Debug:Echo["\at\[EQ2Bot:AmIInvis\]\ax Returning \agFALSE\ax! (Called By: ${param1})"]
    return FALSE
}

function RemoveSKFD(string parm1)
{
    variable int i = 1
    Me:RequestEffectsInfo

    do
    {
        if (${SKFDSpells.Element[${Me.Effect[${i}].ToEffectInfo.Name}](exists)})
        {
            Debug:Echo["I am feigning death due to a Shadowknight...cancelling.  (Called By: ${param1})"]
            Me.Effect[${i}]:Cancel
        }
    }
    while ${i:Inc} <= ${Me.CountEffects}

    return OK
}

function CheckForMez(string param1)
{
    if !${Target.IsRooted}
        return FALSE
    if ${Target.CanTurn}
        return FALSE

    variable int i = 1

    Target:RequestEffectsInfo
    wait 5
    if (${Target.NumEffects} > 0)
    {
        do
        {
            ;Debug:Echo["Checking Target Effect #${i}: ${Target.Effect[${i}].ToEffectInfo.Name}"]
            if (${MezSpells.Element[${Target.Effect[${i}].ToEffectInfo.Name}](exists)})
            {
                ;Debug:Echo["${Target} is Mezzed!  (Called By: ${param1})"]
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

    Target:RequestEffectsInfo
    wait 5
    if (${Target.NumEffects} > 0)
    {
        do
        {
            ;Debug:Echo["Checking Target Effect #${i}: ${Target.Effect[${i}].ToEffectInfo.Name}"]
            if (${MezSpells.Element[${Target.Effect[${i}].ToEffectInfo.Name}](exists)})
                return FALSE
        }
        while ${i:Inc} < ${Target.NumEffects}
    }

    return TRUE
}

function ReacquireTargetFromMA()
{
    ;Debug:Echo["DEBUG (ReacquireTargetFromMA): Old Target: ${Target}"]
    if (${Actor[${MainAssistID}].Name(exists)})
    {
        target ${MainAssist}
        wait 2
        if (${Actor[${MainAssistID}].Target.Type.Equal[NPC]} || ${Actor[${MainAssistID}].Target.Type.Equal[NamedNPC]}) && ${Actor[${MainAssistID}].Target.InCombatMode}
	    {
			KillTarget:Set[${Actor[${MainAssistID}].Target.ID}]
			target ${KillTarget}
			;Debug:Echo["DEBUG (ReacquireTargetFromMA): New Target Acquired: ${Target}"]
			return TRUE
		}
    }

    target ${MainAssist}
    Debug:Echo["(ReacquireTargetFromMA): MA has no target right now..."]
    return FALSE
}

atom AutoFollowTank()
{
	if !${Me.InCombatMode}
	{
	  	UIElement[AutoFollow@@Extras@EQ2Bot Tabs@EQ2 Bot]:SetChecked

		CharacterSet.FindSet[EQ2BotExtras]:AddSetting["Auto Follow Mode",TRUE]
		CharacterSet:Export[${PATH_CHARACTER_CONFIG}/${Me.Name}.xml]

		;Debug:Echo["DEBUG-AutoFollowTank() -- AutoFollowTank(): Me.WhoFollowingID = ${Me.WhoFollowingID}"]
		;Debug:Echo["DEBUG-AutoFollowTank() -- AutoFollowTank(): Me.WhoFollowing = ${Me.WhoFollowing}"]
		;Debug:Echo["DEBUG-AutoFollowTank() -- AutoFollowTank(): AutoFollowee = ${AutoFollowee}"]

		;Debug:Echo["DEBUG-AutoFollowTank(): AutoFollowLastSetTime: ${AutoFollowLastSetTime}"]
		;Debug:Echo["DEBUG-AutoFollowTank(): Time Now: ${Time.Timestamp}"]
		;Debug:Echo["DEBUG-AutoFollowTank(): TimeLookingFor: ${Math.Calc64[${AutoFollowLastSetTime}+5]}"]
		if (${Time.Timestamp} > ${Math.Calc64[${AutoFollowLastSetTime}+5]})
		{
			;Debug:Echo["DEBUG-AutoFollowTank(): Following...."]
			if !${Me.WhoFollowing.Equal[${AutoFollowee}]} && ${Actor[pc,${AutoFollowee}].Distance} < 45 && ${Actor[pc,${AutoFollowee}].Name(exists)} && !${Actor[pc,${AutoFollowee}].OnGriffon} && (!${CombatFollow} || !${AutoFollowingMA})
			{
				if !${Me.WhoFollowing.Equal[${AutoFollowee}]}
				{
					;squelch face ${AutoFollowee}
					eq2execute /follow ${AutoFollowee}
					AutoFollowLastSetTime:Set[${Time.Timestamp}]
					AutoFollowingMA:Set[TRUE]
					AutoFollowMode:Set[TRUE]
				}
				else
				{
					AutoFollowingMA:Set[FALSE]
					;Debug:Echo["DEBUG-AutoFollowTank(): Either I am already following ${AutoFollowee}..."]
				}
			}
			else
			{
			    AutoFollowingMA:Set[FALSE]
			    ;Debug:Echo["DEBUG-AutoFollowTank(): Hmmm... ${AutoFollowee} does not seem to be in range at all..."]
			}
   	}
	}
}

atom StopAutoFollowing()
{
	AutoFollowMode:Set[FALSE]
	AutoFollowingMA:Set[FALSE]
	UIElement[AutoFollow@@Extras@EQ2Bot Tabs@EQ2 Bot]:SetUnChecked

	CharacterSet.FindSet[EQ2BotExtras]:AddSetting["Auto Follow Mode",FALSE]
	CharacterSet:Export[${PATH_CHARACTER_CONFIG}/${Me.Name}.xml]

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
        if (${Actor[pc,${AutoFollowee}].Name(exists)})
        {
            if (!${Me.WhoFollowing.Equal[${AutoFollowee}]})
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
			EQ2Echo "I do not have a ${ItemToBeEquiped} or a  ${OriginalItem}"
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

function IsHealer(uint ID)
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

function IsFighter(uint ID)
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

function IsMage(uint ID)
{
	switch ${Actor[${ID}].Class}
	{
		case warlock
		case wizard
		case necromancer
		case conjuror
		case coercer
		case illusionist
			return TRUE
		default
			return FALSE
	}
}

function IsScout(uint ID)
{
	switch ${Actor[${ID}].Class}
	{
		case ranger
		case assassin
		case swashbuckler
		case brigand
		case troubador
		case dirge
		case beastlord
			return TRUE
		default
			return FALSE
	}
}

function IsFighterOrScout(uint ID)
{
	switch ${Actor[${ID}].Class}
	{
		case guardian
		case berserker
		case shadowknight
		case paladin
		case bruiser
		case monk
		case ranger
		case assassin
		case swashbuckler
		case brigand
		case troubador
		case dirge
		case beastlord
			return TRUE
		default
			return FALSE
	}
}

function CommonPower(int sPower)
{
	;Potion Checks
	if ${UsePotions} && ${Me.Inventory[Essence of Power].IsReady} && ${Me.InCombatMode}
	{
		if ${Me.Power}<5
		{
			Me.Inventory[Essence of Power]:Use
			wait 2
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
		}
	}

	if ${UsePotions} && ${Me.Inventory[Essence of Clarity].IsReady} && ${Me.InCombatMode}
	{
		if ${Me.Power}<5
		{
			Me.Inventory[Essence of Clarity]:Use
			wait 2
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
		}
	}

	if (${Me.Power} < 50 && ${Me.Inventory[ExactName,ManaStone].Location.Equal[Inventory]} && ${Me.Inventory[ExactName,ManaStone].IsReady})
	{
		Me.Inventory[ExactName,ManaStone]:Use
		wait 2
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
	}

	;;;;;;;;;;;;;
	; Shard Usage
	;;;;;;;;;;;;;
	if !${sPower}
		sPower:Set[65]

	declare ShardTypeL string local "NOSHARD"
	declare HeartTypeL string local "NOHEART"

	if ${Me.Inventory["Shard of Essence"](exists)}
		ShardTypeL:Set[Shard of Essence]

	if ${Me.Inventory["Dark Heart"](exists)}
		HeartTypeL:Set[Dark Heart]

	if ${ShardTypeL.NotEqual[NOSHARD]} && ${Me.Power}<${sPower} && ${Me.Inventory[${ShardTypeL}].IsReady} && ${Me.InCombatMode}
	{
		Me.Inventory[${ShardTypeL}]:Use
		wait 2
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
		ShardRequested:Set[FALSE]
	}

	if !${Me.Inventory[${ShardTypeL}](exists)} && !${ShardRequested} && ${ShardMode}
	{
		ShardRequested:Set[TRUE]
		EQ2Execute /tell ${ShardGroupMember} shard please
	}

	if ${HeartTypeL.NotEqual[NOHEART]} && ${Me.Power}<${sPower} && ${Me.Inventory[${HeartTypeL}].IsReady} && ${Me.InCombatMode}
	{
		Me.Inventory[${HeartTypeL}]:Use
		wait 2
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
		HeartRequested:Set[FALSE]
	}

	if !${Me.Inventory[${HeartTypeL}](exists)} && !${HeartRequested} && ${HeartMode}
	{
		HeartRequested:Set[TRUE]
		EQ2Execute /tell ${HeartGroupMember} shard please
	}
}

function Shard(int sPower)
{
	;Shard is deprecated - Use CommonPower
	call CommonPower ${sPower}
}

function TooClose()
{
	; we are too close for a bow change to melee
	if ${Me.RangedAutoAttackOn}
	{
		eq2execute /togglerangedattack
		eq2execute /toggleautoattack
	}

}

function CheckGroupHealth(int MinHealth)
{
	declare counter int local 0

	if ${Me.Health} < ${MinHealth}
		Return FALSE

	if ${Me.Group} <= 1
		return TRUE

	do
	{
		;;; ADDED
		if (!${Me.Group[${counter}].InZone} || !${Me.Group[${counter}].Health(exists)})
			continue

		;check groupmates health
		if ${Me.Group[${counter}].Health} < ${MinHealth} && ${Me.Group[${counter}].Health} > 0
			Return FALSE

		;check health of summoner pets
		if ${Me.Group[${counter}].Class.Equal[conjuror]} || ${Me.Group[${counter}].Class.Equal[necromancer]} || ${Me.Group[${counter}].Class.Equal[illusionist]} || ${Me.Group[${counter}].Class.Equal[beastlord]}
		{
			if ${Me.Group[${counter}].Pet.Health} < ${MinHealth} && ${Me.Group[${counter}].Pet.Health} > 0
				Return FALSE
		}

	}
	while ${counter:Inc}<=${Me.Group}

	Return TRUE
}

function PetAttack(bool NoChecks=0)
{
	;Debug:Echo["Calling PetAttack() -- Me.Pet.Target.ID: ${Me.Pet.Target.ID}"]

	if !${Me.Pet.Name(exists)}
		return

	if (!${Actor[${KillTarget}].Name(exists)} || ${Actor[${KillTarget}].IsDead})
		return

	if ${NoChecks}
	{
		if ${Me.Pet.Target.Name(exists)}
		{
			EQ2Execute /pet backoff
			wait 2
		}
		target ${KillTarget}
		wait 1
		EQ2Execute /pet attack
		wait 30 (${Me.Pet.Target.ID} != ${KillTarget})
		if ${PetGuard}
		{
			EQ2Execute /pet preserve_self
			EQ2Execute /pet preserve_master
		}
		return
	}

	if ${Me.Pet.Target.ID} != ${KillTarget} && ${Actor[${KillTarget}].Distance}<${AssistHP}
	{
		if ${Me.Pet.Target.Name(exists)}
		{
			EQ2Execute /pet backoff
			wait 2
		}
		target ${KillTarget}
		wait 1
		EQ2Execute /pet attack
		wait 30 (${Me.Pet.Target.ID} != ${KillTarget})
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
	if (${AutoFollowMode})
	{
		if (${Actor[${Me.WhoFollowing}].Name(exists)})
		{
			if ${Actor[${Me.WhoFollowing}].Distance}>25 && (${Math.Calc64[${Time.Timestamp} - ${StuckWarningTime}]}>=10)
			{
				relay ${RelaySession} EQ2Echo ${Me.Name} IS STUCK
				StuckWarningTime:Set[${Time.Timestamp}]
			}
		}
	}
}

atom SaveEquipmentSet(string EquipmentSetName)
{
	variable int tempvar=1
	variable string EquipmentItem
	CharacterSet.FindSet[EQ2BotExtras]:AddSet[Equipment]
	CharacterSet.FindSet[EQ2BotExtras]:AddSet[${EquipmentSetName}]

	Do
	{
		if !${Me.Equipment[${tempvar}].Name.Equal[NULL]}
		{
			CharacterSet.FindSet[EQ2BotExtras].FindSet[Equipment].FindSet[${EquipmentSetName}]:AddSetting[${tempvar},${Me.Equipment[${tempvar}].Name}]
		}
	}
	while ${tempvar:Inc} <=22
	CharacterSet:Export[${charfile}]
}

atom GetNaked()
{
	variable int tempvar=1

	if !${Me.InCombatMode}
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

	if !${Me.InCombatMode}
	{
		Do
		{
			if ${Me.Equipment[${tempvar}].Name.NotEqual[${CharacterSet.FindSet[EQ2BotExtras].FindSet[Equipment].FindSet[${EquipmentSetName}].FindSetting[${tempvar}]}]} || !${Me.Equipment[${tempvar}](exists)}
			{
				Me.Inventory[${CharacterSet.FindSet[EQ2BotExtras].FindSet[Equipment].FindSet[${EquipmentSetName}].FindSetting[${tempvar}]}]:Equip
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
		wait 2
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
	}
	elseif ${Me.Inventory[ExactName,"${Item}"].IsReady} && !${Me.Inventory[ExactName,"${Item}"].InBank}
	{
		Me.Inventory[ExactName,"${Item}"]:Use
		wait 2
		do
		{
			waitframe
		}
		while ${Me.CastingSpell}
	}
}

function UseCrystallizedSpirit(int Health=60)
{
	;UseCrystalizedSpirit is depricated.  Use CommonHeals instead.
	call CommonHeals ${Health}
}

function CommonHeals(int Health)
{
	;Use a defiler crystalized spirit if we have 2 or more group members under ${Health}
	declare temphl int local
	declare grpheal int local 0

	grpcnt:Set[${Me.Group}]
	temphl:Set[0]

	if ${Me.Inventory[Crystallized Spirit].IsReady} && ${Me.InCombatMode}
	{
		if ${Me.Health}>0 && ${Me.Group[${temphl}].Health}<${Health}
			grpheal:Inc

		do
		{
			if (!${Me.Group[${counter}].InZone} || !${Me.Group[${counter}].Health(exists)})
				continue

			if !${Me.Group[${temphl}].IsDead} && ${Me.Group[${temphl}].Health}<${Health}
				grpheal:Inc

			if ${Me.Group[${temphl}].Class.Equal[conjuror]} || ${Me.Group[${temphl}].Class.Equal[necromancer]} || ${Me.Group[${temphl}].Class.Equal[beastlord]}
			{
				if ${Me.Group[${temphl}].Pet.Health}<${Health} && ${Me.Group[${temphl}].Pet.Health}>0
					grpheal:Inc
			}
		}
		while ${temphl:Inc}<=${grpcnt}

		if ${grpheal}>=2
		{
			Me.Inventory[Crystallized Spirit]:Use
			wait 2
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
		}
	}

	;fury gift heal
	if ${Me.Ability[Salve].IsReady}
	{
		if !${Me.InRaid} && ${Actor[${MainTankID}].Health} < 60
		{
	    	if (${Me.Ability[Salve].IsReady})
	    	{
		    	eq2execute /useabilityonplayer ${Actor[${MainTankID}].Name} Salve
				wait 2
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
		    	return
			}
		}
		elseif !${Me.InRaid} && !${MainTank} && ${Me.Health} < 75
		{
	    	if (${Me.Ability[Salve].IsReady})
	    	{
		    	eq2execute /useabilityonplayer ${Actor[${MainTankID}].Name} Salve
				wait 2
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
		    	return
			}
		}
		elseif ${Me.InRaid} && !${MainTank} && ${Me.Health} < 35
		{
	    	if (${Me.Ability[Salve].IsReady})
	    	{
		    	eq2execute /useabilityonplayer ${Me.Name} Salve
				wait 2
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
		    	return
			}
		}
	}

	if ${Me.Inventory[Innoruk's Child].IsReady} && ${Me.InCombatMode}
	{
		if ${Me.Health}<50
		{
			Me.Inventory[Innoruk's Child]:Use
			wait 2
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
		}
	}

	if ${UseCurePotions} && ${Me.InCombatMode}
		call CheckPotCures

	if ${Me.Inventory[Essence of Health].IsReady} && ${Me.InCombatMode}
	{
		if ${Me.Health}<25
		{
			Me.Inventory[Essence of Health]:Use
			wait 2
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
		}
	}

	if ${Me.Inventory[Essence of Regeneration].IsReady} && ${Me.InCombatMode}
	{
		if ${Me.Health}<25
		{
			Me.Inventory[Essence of Regeneration]:Use
			wait 2
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
		}
	}

}

;function returns the Actor ID from a ActorName.  It prioritzes PCs over pets and npcs
function GetActorID(string ActorName)
{
	variable index:actor Actors
	variable iterator ActorIterator

	EQ2:QueryActors[Actors, Distance <= 50]
	Actors:GetIterator[ActorIterator]

	if ${ActorIterator:First(exists)}
	{
		do
		{
			if ${ActorIterator.Value.Name.Equal[${ActorName}]}
			{
				if ${ActorIterator.Value.Type.Equal[PC]}
				{
					;There is a PC by this name so return it
					return ${ActorIterator.Value.ID}
				}
			}
		}
		while ${ActorIterator:Next(exists)}
	}

	;We either found no actor or a NPC so return that ID
	return 0
}


function CheckHealthiness(int GroupHealth, int MTHealth, int MyHealth)
{
	declare counter int local 1

	if ${Me.Group} > 1
	{
		do
		{
			;check groupmates health
			if (${Me.Group[${counter}].InZone} && !${Me.Group[${counter}].IsDead} && ${Me.Group[${counter}].Health(exists)})
			{
				if (${Me.Group[${counter}].Health} < ${GroupHealth})
					return FALSE

				;check health of summoner pets .. TO DO -- why do we care about these on epic/raid fights?
				if ${Me.Group[${counter}].Class.Equal[conjuror]} || ${Me.Group[${counter}].Class.Equal[necromancer]} || ${Me.Group[${counter}].Class.Equal[beastlord]}
				{
					if (${Me.Group[${counter}].Pet.Name(exists)} && !${Me.Group[${counter}].Pet.IsDead})
					{
						if ${Me.Group[${counter}].Pet.Health} < ${GroupHealth}
							return FALSE
					}
				}
			}
		}
		while ${counter:Inc}<=${Me.Group}
	}

	;check mt health
	if ${Actor[${MainTankID}].Health} < ${MTHealth}
		return FALSE

	;check my health
	if ${Me.Health} < ${MyHealth}
		return FALSE

	return TRUE
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
			if ${Message.Find[${OutTrigger}]} && ${JoustMode} && ${Me.InCombatMode}
				JoustStatus:Set[1]
			elseif ${Message.Find[${InTrigger}]} && ${JoustMode} && ${Me.InCombatMode}
				JoustStatus:Set[0]
			elseif ${Message.Find[${BDTrigger}]}
				BDStatus:Set[1]
		case 18
		case 8
			if (${Message.Upper.Find[SHARD]} || ${Message.Upper.Find[HEART]}) && ${Me.Class.Equal[summoner]}
				call QueueShardRequest ${Speaker} ${Speaker}
			break
		default
			break
	}
}

atom(script) MiscText(string Message)
{
	if ${Message.Upper.Find[TARGET ALREADY HAS A CONJUROR ESSENCE]} || ${Message.Upper.Find[TARGET ALREADY HAS A NECROMANCER HEART]}
		ShardQueue:Dequeue
}

;returns the ID of your healer in group, if none found, returns your ID
function FindHealer()
{
	declare tempgrp int local 0
	declare	healer int local 0

	if !${Me.Grouped}
		return ${Me.ID}

	healer:Set[${Me.ID}]

	do
	{
		switch ${Me.Group[${tempgrp}].Class}
		{
			case templar
			case fury
			case mystic
			case defiler
				healer:Set[${Me.Group[${tempgrp}].ID}]
				break
			case warden
			case inquisitor
				;don't trust priests that have melee configs unless no other priest is available
				if ${healer}==${Me.ID}
					healer:Set[${Me.Group[${tempgrp}].ID}]
				break
			default
				break
		}

	}
	while ${tempgrp:Inc}<=${Me.Group}

    if (${Me.InRaid})
    {
    	if (${healer} == ${Me.ID})
    	{
    		tempgrp:Set[0]

    		do
    		{
    			switch ${Me.Raid[${tempgrp}].Class}
    			{
    				case templar
    				case fury
    				case mystic
    				case defiler
    					healer:Set[${Me.Raid[${tempgrp}].ID}]
    					break
    				case warden
    				case inquisitor
    					if ${healer}==${Me.ID}
    						healer:Set[${Me.Raid[${tempgrp}].ID}]
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

function CheckPotCures()
{

	if ${Me.Arcane}>0
	{
	  ; check to see if we have more of our selected potion
		if ${Me.Inventory[Query, Location == "Inventory" && Name =- ${ArcanePotion}](exists)}
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

	if ${Me.Elemental}>0
	{
		if ${Me.Inventory[Query, Location == "Inventory" && Name =- ${ElementalPotion}](exists)}
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

	if ${Me.Noxious}>0
	{
		if ${Me.Inventory[Query, Location == "Inventory" && Name =- ${NoxiousPotion}](exists)}
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

	if ${Me.Trauma}>0
	{
		if ${Me.Inventory[Query, Location == "Inventory" && Name =- ${TraumaPotion}](exists)}
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
  	; Do not cast if we are moving, or if the potion is not ready, or if the first potion returned is in the bank
	if ${Me.IsMoving} || !${Me.Inventory[ExactName,"${Item}"].IsReady} || ${Me.Inventory[ExactName,"${Item}"].Location.Find[Bank]}
	{
		return
	}

  	; Use the potion
	Me.Inventory[ExactName,"${Item}"]:Use
	wait 2
	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	return SUCCESS
}

function SummonDeityPet()
{
	variable string DeityPet[13]
	variable int dcount

	DeityPet[1]:Set[Summon: Elemental of Karana]
	DeityPet[2]:Set[Summon: Beloved of Bristlebane]
	DeityPet[3]:Set[Summon: Rodcet Nife's Healing Companion]
	DeityPet[4]:Set[Summon: Imp of Ro]
	DeityPet[5]:Set[Summon: Pariah of Bertoxxulous]
	DeityPet[6]:Set[Summon: Servant of Thule]
	DeityPet[7]:Set[Summon: The Tribunal's Bailiff]
	DeityPet[8]:Set[Summon: Underfoot Attendant]
	DeityPet[9]:Set[Summon: Warrior of Zek]
	DeityPet[10]:Set[Summon: Peaceful Visage]
	DeityPet[11]:Set[Summon: Friend of Growth]
	DeityPet[12]:Set[Summon: Minion of Hate]
	DeityPet[13]:Set[Valiant Beast]

	while ${dcount:Inc}<=${DeityPet.Size}
	{
		if ${Me.Ability[${DeityPet[${dcount}]}].IsReady}
		{
			Me.Ability[${DeityPet[${dcount}]}]:Use

			wait 4
			while ${Me.CastingSpell}
			{
				wait 2
			}

			return Complete
		}
	}
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

objectdef SpellIcon
{
	variable string Name
	variable int Icon
	variable int Level

	method Initialize(string Nm, int Icn, int Lvl)
	{
		Name:Set[${Nm}]
		Icon:Set[${Icn}]
		Level:Set[${Lvl}]
	}
}

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

	variable string charfile="${PATH_CHARACTER_CONFIG}/${Me.Name}.xml"

	method PopulateCB(int HoIconID, string ElementFQN)
	{
		variable int Counter=1
		variable int iter=1
		variable index:SpellIcon Spl
		variable bool Found=FALSE
		variable int IconID

		UIElement[${ElementFQN}]:ClearItems

		if ${UIElement[EQ2 Bot].FindUsableChild[LimitToHighest,checkbox].Checked}
		{
			do
			{
				Found:Set[FALSE]
				if ${Me.Ability[${Counter}].HOIconID}==${HoIconID}
				{
					IconID:Set[${Me.Ability[${Counter}].ToAbilityInfo.MainIconID}${Me.Ability[${Counter}]..ToAbilityInfo.BackDropIconID.LeadingZeroes[4]}]
					for ( iter:Set[1] ; ${iter} <= ${Spl.Used} ; iter:Inc )
					{
						if (${Spl[${iter}].Icon} == ${IconID})
						{
							if ${Me.Ability[${Counter}].Class[1].Level} > ${Spl[${iter}].Level}
							{
								Spl[${iter}].Name:Set[${Me.Ability[${Counter}].Name}]
								Spl[${iter}].Icon:Set[${IconID}]
								Spl[${iter}].Level:Set[${Me.Ability[${Counter}].Class[1].Level}]
							}
							Found:Set[TRUE]
							break
						}
					}
					if !${Found}
						Spl:Insert[${Me.Ability[${Counter}].Name},${Me.Ability[${Counter}].ToAbilityInfo.MainIconID}${Me.Ability[${Counter}]..ToAbilityInfo.BackDropIconID.LeadingZeroes[4]},${Me.Ability[${Counter}].Class[1].Level}]
				}
			}
			while ${Counter:Inc}<=${Me.NumAbilities}

			for ( iter:Set[1] ; ${iter} <= ${Spl.Used} ; iter:Inc )
			{
				UIElement[${ElementFQN}]:AddItem[${Spl[${iter}].Name},${Spl[${iter}].Icon}${Spl[${iter}].Level.LeadingZeroes[2]}]
			}
		}
		else
		{
			do
			{
				if ${Me.Ability[${Counter}].HOIconID}==${HoIconID}
				{
					UIElement[${ElementFQN}]:AddItem[${Me.Ability[${Counter}].Name},"${Me.Ability[${Counter}].ToAbilityInfo.MainIconID.LeadingZeroes[4]}${Me.Ability[${Counter}]..ToAbilityInfo.BackDropIconID.LeadingZeroes[4]}${Me.Ability[${Counter}].Class[1].Level.LeadingZeroes[2]}"]
				}
			}
			while ${Counter:Inc}<=${Me.NumAbilities}
		}
		UIElement[${ElementFQN}]:Sort
	}

	method Initialize()
	{
		CharacterSet.FindSet[EQ2BotExtras]:AddSet[HeroicOp]
		switch ${Me.Archetype}
		{
			case fighter
				FighterSword1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterSword1,""]}]
				FighterSword2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterSword2,""]}]
				FighterHorn1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterHorn1,""]}]
				FighterHorn2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterHorn2,""]}]
				FighterBoot1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterBoot1,""]}]
				FighterBoot2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterBoot2,""]}]
				FighterArm1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterArm1,""]}]
				FighterArm2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterArm2,""]}]
				FighterFist1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterFist1,""]}]
				FighterFist2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[FighterFist2,""]}]
				break

			case scout
				ScoutCoin1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutCoin1,""]}]
				ScoutCoin2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutCoin2,""]}]
				ScoutDagger1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutDagger1,""]}]
				ScoutDagger2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutDagger2,""]}]
				ScoutCloak1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutCloak1,""]}]
				ScoutCloak2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutCloak2,""]}]
				ScoutMask1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutMask1,""]}]
				ScoutMask2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutMask2,""]}]
				ScoutBow1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutBow1,""]}]
				ScoutBow2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[ScoutBow2,""]}]
				break

			case mage
				This.MageStar1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageStar1,""]}]
				This.MageStar2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageStar2,""]}]
				This.MageLightning1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageLightning1,""]}]
				This.MageLightning2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageLightning2,""]}]
				This.MageFlame1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageFlame1,""]}]
				This.MageFlame2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageFlame2,""]}]
				This.MageStaff1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageStaff1,""]}]
				This.MageStaff2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageStaff2,""]}]
				This.MageWand1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageWand1,""]}]
				This.MageWand2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[MageWand2,""]}]
				break

			case priest
				PriestHammer1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestHammer1,""]}]
				PriestHammer2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestHammer2,""]}]
				PriestChalice1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestChalice1,""]}]
				PriestChalice2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestChalice2,""]}]
				PriestMoon1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestMoon1,""]}]
				PriestMoon2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestMoon2,""]}]
				PriestEye1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestEye1,""]}]
				PriestEye2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestEye2,""]}]
				PriestHolySymbol1:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestHolySymbol1,""]}]
				PriestHolySymbol2:Set[${CharacterSet.FindSet[EQ2BotExtras].FindSet[HeroicOp].FindSetting[PriestHolySymbol2,""]}]
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

		echo Loading HO Tab...
		ui -load -parent "HOs@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_UI}/${Me.Archetype}HOs.xml"
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



		if ${EQ2.HOWheelState}==0 || ${EQ2.HOWheelState}==4 || ${EQ2.HOWheelState}==6
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
							else
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
							else
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
		elseif ${EQ2.HOWheelState}==5 || ${EQ2.HOWheelState}==1 || ${EQ2.HOWheelState}==2


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
			case beastlord
				return scout
				break
			case default
				break
		}

	}
}