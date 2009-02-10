;===================================================
;===               VGA Logic Tree               ====
;===================================================
/*
Check UI Interaction-----> Pause,Execute QueCommands

Not In Combat ->  General Downtime -----------------> Class Specific Downtime
		         |	|				|
			 |	-> Follow/Assist/trade/etc	-> GatherEnergy/Songs/Switch Weapons
			 |
			 -> Heal or Buff ---(Cp=Neither)------->|
I should Attack							|
	|							|
	->  Pre Combat Actions ->  Class Specific Pre Combat	|
	|	|	|	   |				|
	|	|	|	   ------(Cp=Pre)-------------->|
	|	|	|	   				|
	|	|	-> EmergencyActions----(Cp=Neither)---->|
	|	|						|
	|	-> MoveToTarget, Assist, Autoattack->Return	|
	|							|
	|							|
	-> Perform A Combat Action				|
	|	|						|
	|	-> Opening Sequence				|
	|	|	|					|
	|	|	-> Spells  -------->  Melee		|
	|	|	     |			|		|
	|	|	     -----------------------(Cp=while)->|	
	|	|						|
	|	-> Main Combat(dot,debuff,DD,AOE)		|
	|		|					|
	|		-> Spells  -------->  Melee		|
	|		     |			|		|
	|		     -----------------------(Cp=Both)-->|
	|							|
	-> Post Combat Sequence ->  Class Specific Post Combat	|
	|	|				|		|
	|	-> Spells  -------->  Melee	|		|	
	|	    |			|	|		|
	|	    --------------------------------(Cp=Both)-->|	
	->Return						|
								|->CheckAbilityToCast--TRUE-->*Execute Ability/Type/CP(CastingPassIdentity)
									|								|
									->FALSE ->Return						|
																	|
	-<<--------------<<------------------------------------<<---------------------------------------<<-----------------------------<<
	|																|
	->*Execute Ability/Type														|
		|															|
		->  Check Mob Resists Lists --TRUE--> Check Spell Type Lists --TRUE-->  Dont Execute (return)				|
			  |				   	|									|
			False				   	False									|
			  |				   	|									|
			  -----> Use Ability <-------------------									|
		  		     |													|
				     |													|
		  	    Check CP(CastingPass)											|			
				|													|
				-> Neither  -> MeCasting(Wait WhileCasting,Global) -> Return						|
				|													|
				-> While Only(MeCasting_While)										|
				|	|												|
				|	->While Casting Check EmergencyActions-------------------(Cp=Post)----------------------------->|
				|	|												|
				|	->MeCastingWaits ->Return									|
				|													|
				-> Both(MeCasting_Pre_Post)										|
				|	|												|
				|	->While Casting Check EmergencyActions-------------------(Cp=Post)----------------------------->|
				|	|												|		
				|	->MeCastingWaits										|
				|	|												|
				|	->AfterGlobal Check EmergencyActions --------------------------> Criticals --------(Cp=Post)--->|
				|					|					|			|
				|					|					->Return		|
				|					-------------------------(Cp=Post)----------------------------->|
				-> Post Only(MeCasting_Post)										|
					|												|
					->MeCastingWaits										|
					|												|
					->AfterGlobal Check EmergencyActions --------------------------> Criticals --------(Cp=Post)--->|
									|					|			|
									|					->Return		|
									-------------------------(Cp=Post)----------------------------->|			

*/
;===================================================
;===               Includes                     ====
;===================================================

;-------------------------------------------
;************Utilities Scripts**************
;-------------------------------------------
#include "${Script.CurrentDirectory}/scripts/vga/UTL_MoveTo.iss"
;#include "${Script.CurrentDirectory}/scripts/vga/UTL_faceslow.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_Objects.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_Variables.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_LavishLoad.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_LavishSave.iss"
#include "${Script.CurrentDirectory}/scripts/vga/UTL_LavishEvents.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_GUI_Utility.iss"

;-------------------------------------------
;************Main-Tab Scripts***************
;-------------------------------------------
#include "${Script.CurrentDirectory}/scripts/vga/ACT_BuffWatch.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_BuffWatch.iss"
#include "${Script.CurrentDirectory}/scripts/vga/ACT_Merchant.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Merchant.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Mob.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Mobs.iss"

;-------------------------------------------
;**********Healer-Tab Scripts***************
;-------------------------------------------

#include "${Script.CurrentDirectory}/scripts/vga/Act_Healing.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Healing.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Buff.iss"

;-------------------------------------------
;**********Combat-Tab Scripts***************
;-------------------------------------------
#include "${Script.CurrentDirectory}/scripts/vga/Act_Combat.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Combat_Main.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Melee.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Abilities.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Interupt.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Spells.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Crits.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Criticals.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Evade.iss"
#include "${Script.CurrentDirectory}/scripts/vga/Act_Evade.iss"


;-------------------------------------------
;**********Class-Tab Scripts***************
;-------------------------------------------
#include "${Script.CurrentDirectory}/scripts/vga/CLS_Shaman.iss"
#include "${Script.CurrentDirectory}/scripts/vga/CLS_Sorcerer.iss"
#include "${Script.CurrentDirectory}/scripts/vga/CLS_Bard.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_Bard.iss"
#include "${Script.CurrentDirectory}/scripts/vga/CLS_BloodMage.iss"
#include "${Script.CurrentDirectory}/scripts/vga/GUI_BloodMage.iss"

;===================================================
;===               Main Routine               ====
;===================================================

function main()
{
	;===================================================
	;===               ISX Load                     ====
	;===================================================	
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "[${Time}] --> Unable to load ISXVG, exiting script"
		endscript vga
	}
	;===================================================
	;===               Function Loads               ====
	;===================================================	
	call loadxmls
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
   	ui -reload "${Script.CurrentDirectory}/vga_gui.xml"
	;===================================================
	;===               Atoms and Events             ====
	;===================================================	
	call LavishEventLoad
	;===================================================
	;===               Populate GUI Lists           ====
	;===================================================
	call PopulateHealLists
	call PopulateSpellLists
	call PopulateMeleeLists
	call PopulateCritsLists
	call PopulateCombatMainLists
	call PopulateEvadeLists
	call PopulateMobLists
	call PopulateAbilitiesLists
	call PopulateBuffLists
	call PopulateSellLists
	call PopulateBardLists
	call PopulateBMLists
	call PopulateGroupMemberNames
	;===================================================
	;===               Bug WorkArounds              ====
	;===================================================
	call MeClassCrashWorkAround
	;===================================================
	;===               Main Loop                    ====
	;===================================================
   	do
   	{
		;-------------------------------------------
		;*****************Pause*********************
		;-------------------------------------------
		call PauseScript
		;-------------------------------------------
		;************Run Queued Stuff***************
		;-------------------------------------------
		while ${QueuedCommands}
			ExecuteQueued
		FlushQueued
		;-------------------------------------------
		;********Run Fight/Downtime Stuff***********
		;-------------------------------------------
		if !${fight.ShouldIAttack}
		{
			; Only run "downtimefunction" a max of once per second -- this helps with performance.  The "1" could be be a variable added to the UI if desired...
			if (${Math.Calc[${Math.Calc[${Script.RunningTime}-${LastDowntimeCall}]}/1000]} > 1)
			{
				LastDowntimeCall:Set[${Script.RunningTime}]
				call downtimefunction
			}
		}
		if ${fight.ShouldIAttack}
		{
			call combatfunction
		}
   	}
   	while ${Me(exists)}
}

;===================================================
;===          Main Downtime Function            ====
;===================================================
function downtimefunction()
{
	call Healcheck
	call ClassSpecificDowntime
	call followpawn
	call assistpawn
	call BuffUp
	call lootit
	return
}
;===================================================
;===    Class Specific Downtime Function        ====
;===================================================
function ClassSpecificDowntime()
{
	switch ${Me.Class}
	{
		case Bard
			call BardSong
			break
		
		case Blood Mage
			call BM_CheckEnergy
			call BM_DownTime
			break
	}
	
	return
}
;===================================================
;===               CombatRoutine Function       ====
;===================================================
function combatfunction()
{
	;-------------------------------------------
	;**********Fighting PreLoopCall*************
	;-------------------------------------------
	call PreCombatLoopFunction
	call ClassSpecificPreCombat
	call SendInPets

	;-------------------------------------------
	;************Main Combat Loop***************
	;-------------------------------------------
	if ${newattack}
		call OpeningSpellSequence
	elseif !${newattack}
	{
		call DotSpells
		call DotMelee
		call DebuffSpells
		call DebuffMelee
		call CombatSpellSequence
		call CombatMeleeSequence
		call AOESpell
		call AOEMelee
	}

	;-------------------------------------------
	;**********Fighting PostLoopCall************
	;-------------------------------------------
	call PostCombatLoopFunction
	call ClassSpecificPostCombat	

	return
}
;===================================================
;===         Pre Combat Loop Function           ====
;===================================================
function PreCombatLoopFunction()
{
 	call CheckPosition
	call EmergencyActions
	call Healcheck
	return
}
;===================================================
;===     Class Specific Pre Combat Loop         ====
;===================================================
function ClassSpecificPreCombat()
{
	switch ${Me.Class}
	{
		case Bard
			call BardSong
			break
			
		case Blood Mage
			break
			
		case Shaman
			call shamanmana
			break
	
	}
	
	return
}
;===================================================
;===         Post Combat Loop Function          ====
;===================================================
function PostCombatLoopFunction()
{
	return
}
;===================================================
;===     Class Specific Post Combat Loop        ====
;===================================================
function ClassSpecificPostCombat()
{
	switch ${Me.Class}
	{
		case Bard
			break
		
		case Blood Mage
			break
	}	
	
	return
}
;===================================================
;===             Emergency Actions              ====
;===================================================
function EmergencyActions()
{
	call PauseScript
	;-------------------------------------------
	;*****Check If I Need to Instant Heal*******
	;-------------------------------------------
	if ${ClassRole.healer}
		call checkinstantheal
	;-------------------------------------------
	;***Check If I Need to Turn off Attack******
	;-------------------------------------------
	call TurnOffAttackfunct
	;-------------------------------------------
	;*******Check If I Need to Evade************
	;-------------------------------------------

	call checkFD
	call checkinvoln1
	call checkinvoln2
	call checkevade1
	call checkevade2
	;-------------------------------------------
	;***Check If I Need to Counter a Spell******
	;-------------------------------------------	
	call counteringfunct
	;-------------------------------------------
	;***Check If I Need to Dispell a Spell******
	;-------------------------------------------
	call dispellfunct
	;-------------------------------------------
	;****Check If I Need to Push a Stance******
	;-------------------------------------------
	call StancePushfunct
	call clickiesfunct

	return
}

;===================================================
;===             Post Casting Loop             ====
;===================================================
function PostCastingActions()
{
	UpdateTempBuffWatch
	call EmergencyActions
	call Healcheck
	call pushagrototank
	call rescue
	;-------------------------------------------
	;********Check If I Can Critical************
	;-------------------------------------------
	call functAOECrits
	call functBuffCrits
	call functDotCrits
	call functCombatCrits
	;-------------------------------------------
	;****Check If I Need to use my Counter******
	;-------------------------------------------
	call counterattack
	;-------------------------------------------
	;****Check for Class Specific Post**********
	;-------------------------------------------
	call ClassSpecificPostCasting
	
	return
}
;===================================================
;===    Class Specific Post Casting Loop        ====
;===================================================
function ClassSpecificPostCasting()
{
	switch ${Me.Class}
	{
		case Blood Mage
			call BM_CheckBloodUnion
			call BM_CheckEnergy
			break
		
		case Shaman
			call shamanmana
			break
			
		case Sorcerer
			call SorcererMana
			break
	}
	
	return
}

;********************************************
atom atexit()
{
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	call LavishSave
	Event[VG_OnIncomingCombatText]:DetachAtom[VG_OnIncomingCombatText]
	Event[VG_onGroupMemberAdded]:DetachAtom[NeedBuffs]
	Event[VG_onGroupMemberDeath]:DetachAtom[NeedBuffs]
	Event[VG_onPawnStatusChange]:DetachAtom[VG_onPawnStatusChange]
	Event[VG_onCombatReaction]:DetachAtom[VG_onCombatReaction]
	Event[VG_onGroupMemberCountChange]:DetachAtom[VG_onGroupMemberCountChange]
	Event[VG_onGroupDisbanded]:DetachAtom[VG_onGroupDisbanded]
	Event[VG_onGroupFormed]:DetachAtom[VG_onGroupFormed]
	Event[VG_onGroupBooted]:DetachAtom[VG_onGroupBooted]
	Event[VG_onGroupMemberBooted]:DetachAtom[VG_onGroupMemberBooted]
	ui -unload "${Script.CurrentDirectory}/vga_gui.xml"
	endscript vga
}
