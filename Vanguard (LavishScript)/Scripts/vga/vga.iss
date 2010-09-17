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
;************Zandros Objects  **************
;-------------------------------------------
#include "${Script.CurrentDirectory}/Obj_Face.iss"
#include "${Script.CurrentDirectory}/Obj_Move.iss"
#include "${Script.CurrentDirectory}/Obj_Follow.iss"



;-------------------------------------------
;************VG_Objects Scripts**************
;-------------------------------------------
#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_DiploGear.iss"
#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Friends.iss"
#include "${LavishScript.CurrentDirectory}/Scripts/vg_objects/Obj_Trash.iss"

;-------------------------------------------
;************Utilities Scripts**************
;-------------------------------------------
#include "${Script.CurrentDirectory}/UTL_MoveTo.iss"
#include "${Script.CurrentDirectory}/UTL_faceslow.iss"
#include "${Script.CurrentDirectory}/UTL_Objects.iss"
#include "${Script.CurrentDirectory}/UTL_Variables.iss"
#include "${Script.CurrentDirectory}/UTL_LavishLoad.iss"
#include "${Script.CurrentDirectory}/UTL_LavishSave.iss"
#include "${Script.CurrentDirectory}/UTL_LavishEvents.iss"
#include "${Script.CurrentDirectory}/Act_GUI_Utility.iss"
#include "${Script.CurrentDirectory}/Act_MoveToAttack.iss"
;#include "${Script.CurrentDirectory}/GUI_Friends.iss"
#include "${Script.CurrentDirectory}/Act_Interactions.iss"
;-------------------------------------------
;************Main-Tab Scripts***************
;-------------------------------------------
#include "${Script.CurrentDirectory}/ACT_BuffWatch.iss"
#include "${Script.CurrentDirectory}/GUI_BuffWatch.iss"
#include "${Script.CurrentDirectory}/ACT_Merchant.iss"
#include "${Script.CurrentDirectory}/GUI_Merchant.iss"
#include "${Script.CurrentDirectory}/Act_Mob.iss"
#include "${Script.CurrentDirectory}/GUI_Mobs.iss"
#include "${Script.CurrentDirectory}/GUI_Quests.iss"
#include "${Script.CurrentDirectory}/Act_Diplo.iss"
#include "${Script.CurrentDirectory}/GUI_Diplo.iss"

;-------------------------------------------
;**********Healer-Tab Scripts***************
;-------------------------------------------

#include "${Script.CurrentDirectory}/Act_Healing.iss"
#include "${Script.CurrentDirectory}/Act_Healing_By_Type.iss"
#include "${Script.CurrentDirectory}/Act_Healing_Cleric.iss"
#include "${Script.CurrentDirectory}/Act_Healing_Disciple.iss"
#include "${Script.CurrentDirectory}/Act_Healing_Druid.iss"
#include "${Script.CurrentDirectory}/Act_Healing_Paladin.iss"
#include "${Script.CurrentDirectory}/Act_Healing_Ranger.iss"
#include "${Script.CurrentDirectory}/Act_Healing_Shaman.iss"
#include "${Script.CurrentDirectory}/Act_Healing_BloodMage.iss"
#include "${Script.CurrentDirectory}/GUI_Healing.iss"
#include "${Script.CurrentDirectory}/Act_Buff.iss"
#include "${Script.CurrentDirectory}/Act_Ressurect.iss"


;-------------------------------------------
;**********Combat-Tab Scripts***************
;-------------------------------------------
#include "${Script.CurrentDirectory}/Act_Combat.iss"
#include "${Script.CurrentDirectory}/GUI_Combat_Main.iss"
#include "${Script.CurrentDirectory}/GUI_Melee.iss"
#include "${Script.CurrentDirectory}/GUI_Abilities.iss"
#include "${Script.CurrentDirectory}/Act_Interupt.iss"
#include "${Script.CurrentDirectory}/GUI_Spells.iss"
#include "${Script.CurrentDirectory}/Act_Crits.iss"
#include "${Script.CurrentDirectory}/GUI_Criticals.iss"
#include "${Script.CurrentDirectory}/GUI_Evade.iss"
#include "${Script.CurrentDirectory}/Act_Evade.iss"


;-------------------------------------------
;**********Class-Tab Scripts***************
;-------------------------------------------
#include "${Script.CurrentDirectory}/UTL_Class.iss"
#include "${Script.CurrentDirectory}/CLS_DreadKnight.iss"
#include "${Script.CurrentDirectory}/CLS_Warrior.iss"
#include "${Script.CurrentDirectory}/CLS_Paladin.iss"
#include "${Script.CurrentDirectory}/CLS_Bard.iss"
#include "${Script.CurrentDirectory}/CLS_Monk.iss"
#include "${Script.CurrentDirectory}/CLS_Ranger.iss"
#include "${Script.CurrentDirectory}/CLS_Rogue.iss"
#include "${Script.CurrentDirectory}/CLS_BloodMage.iss"
#include "${Script.CurrentDirectory}/CLS_Cleric.iss"
#include "${Script.CurrentDirectory}/CLS_Disciple.iss"
#include "${Script.CurrentDirectory}/CLS_Shaman.iss"
#include "${Script.CurrentDirectory}/CLS_Druid.iss"
#include "${Script.CurrentDirectory}/CLS_Necromancer.iss"
#include "${Script.CurrentDirectory}/CLS_Psionicist.iss"
#include "${Script.CurrentDirectory}/CLS_Sorcerer.iss"
#include "${Script.CurrentDirectory}/GUI_DreadKnight.iss"
#include "${Script.CurrentDirectory}/GUI_Warrior.iss"
#include "${Script.CurrentDirectory}/GUI_Paladin.iss"
#include "${Script.CurrentDirectory}/GUI_Bard.iss"
#include "${Script.CurrentDirectory}/GUI_Monk.iss"
#include "${Script.CurrentDirectory}/GUI_Ranger.iss"
#include "${Script.CurrentDirectory}/GUI_Rogue.iss"
#include "${Script.CurrentDirectory}/GUI_BloodMage.iss"
#include "${Script.CurrentDirectory}/GUI_Cleric.iss"
#include "${Script.CurrentDirectory}/GUI_Disciple.iss"
#include "${Script.CurrentDirectory}/GUI_Shaman.iss"
#include "${Script.CurrentDirectory}/GUI_Druid.iss"
#include "${Script.CurrentDirectory}/GUI_Necromancer.iss"
#include "${Script.CurrentDirectory}/GUI_Psionicist.iss"
#include "${Script.CurrentDirectory}/GUI_Sorcerer.iss"

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
	call DreadKnight_GUI
	call Warrior_GUI
	call Paladin_GUI
	call Bard_GUI
	call Monk_GUI
	call Ranger_GUI
	call Rogue_GUI
	call BloodMage_GUI
	call Cleric_GUI
	call Disciple_GUI
	call Shaman_GUI
	call Druid_GUI
	call Necromancer_GUI
	call Psionicist_GUI
	call Sorcerer_GUI
	call PopulateGroupMemberClassType
	;***************edited by maras**************	
	call SetupHOTTimer
	;***************end edited by maras**************
	;===================================================
	;===               Bug WorkArounds              ====
	;===================================================
	call MeClassCrashWorkAround
	
	;===================================================
	;===               Misc.                        ====
	;===================================================
	if !${Group(exists)}
	{
		; if we are not in a group, go ahead and set MT and MA to "me"
		; TODO:  Possibly pause the script (if we are grouped) until the player sets a tank/assist?
		tankpawn:Set[${Me.FName}]
		assistpawn:Set[${Me.FName}]
	}

	;===================================================
	;===           Key Bindings                     ====
	;===================================================
	bind -press ResetWindow CTRL+SHIFT+R "Script[vga]:QueueCommand[call ResetWindow]"
		
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
			if ${dofollowpawn}
				call followpawn
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
	if !${DoByPassVGAHeals}
		call Healcheck
	if ${DoClassDownTime}
		call Class_DownTime
	if ${DoResNotInCombat}
		call ResUp
	if ${DoMount}
		call shouldimount
	if ${DoDiplo}
		call AssistDiplo
	if ${dofollowpawn}
		call followpawn
	if ${doassistpawn} 
		call assistpawn
	call BuffUp
	if ${DoLoot}
		call lootit
	if ${doNonCombatStance}
		call changeformstance
	if ${doRestoreSpecial}
		call restorespecialpoints
	call ToggleOffCombatBuffSpells
	if ${DoShiftingImage}
		call ShiftingImage
	if ${DoAutoAcceptGroupInvite}
		call groupup
  if ${doTrash}
		obj_trash:Destroy
  if ${doHarvest}
		call Harvest
	if ${DoRemoveLowDiplo}
		call RemoveLowLevelDiplo
	if ${DoBurstNow}
	  DoBurstNow:Set[FALSE]
	return
}

;===================================================
;===               CombatRoutine Function       ====
;===================================================
function combatfunction()
{
	;-------------------------------------------
	;**********FIX THE NULL or 0 HP*************
	;-------------------------------------------
	if ${Me.Target(exists)} && ${Me.TargetHealth}<1
	{
		wait 2
	}

	;-------------------------------------------
	;**********Fighting PreLoopCall*************
	;-------------------------------------------
	call PreCombatLoopFunction
	if ${DoClassPreCombat}
		call Class_PreCombat
	if ${Me.Pet(exists)}
		call SendInPets

	;-------------------------------------------
	;************Main Combat Loop***************
	;-------------------------------------------
	if ${newattack}
	  {
		call changeformstance
		call OpeningSpellSequence
		if ${DoClassOpener}
			call Class_Opener
	   }
	elseif !${newattack}
	{
		if !${Me.Target.Name.Equal[${tankpawn}]}
			call targettank
		if ${DoClassCombat}
			call Class_Combat
		if ${doKillingBlow}
			call KillingBlowAbility
		if ${doAOESpell}
			call AOESpell
		if ${doAOEMelee}
			call AOEMelee
		if ${doDotSpell}
    			call DotSpells
		if ${doDotMelee}
			call DotMelee
		if ${doDebuffSpell}
			call DebuffSpells
		if ${doDebuffMelee}
			call DebuffMelee
		if ${doCombatSeqSpell}
			call CombatSpellSequence
		if ${doCombatSeqMelee}
			call CombatMeleeSequence
	}

	;-------------------------------------------
	;**********Fighting PostLoopCall************
	;-------------------------------------------
	call PostCombatLoopFunction
	if ${DoClassPostCombat}
		call Class_PostCombat	

	return
}
;===================================================
;===         Pre Combat Loop Function           ====
;===================================================
function PreCombatLoopFunction()
{
	if ${DoLooseTarget} 
		call LooseTarget
	call EmergencyActions
	if !${DoByPassVGAHeals}
		call Healcheck
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
;===             Emergency Actions              ====
;===================================================
function EmergencyActions()
{
	call PauseScript
	call CheckPosition
	;-------------------------------------------
	;*****Check If I Need to Instant Heal*******
	;-------------------------------------------
	if ${ClassRole.healer} && !${DoByPassVGAHeals}
		call checkinstantheal
	;-------------------------------------------
	;***Check If I Need to Turn off Attack******
	;-------------------------------------------
	If ${doTurnOffAttack} 
		call TurnOffAttackfunct
	If ${doFurious}
		call CheckFurious
	If ${doTurnOffDuringBuff} 
		call TurnOffDuringBuff
	;-------------------------------------------
	;*******When in Doubt BURST************
	;------------------------------------------
  if ${DoClassBurst} && ${DoBurstNow}
		  call Class_Burst
	;-------------------------------------------
	;*******Check If I Need to Evade************
	;-------------------------------------------

	if ${doFD}
		call checkFD
	if ${doInvoln1}
		call checkinvoln1
	if ${doInvoln2}
		call checkinvoln2
	if ${doEvade1}
		call checkevade1
	if ${doEvade2}
		call checkevade2
	;-------------------------------------------
	;***Check If I Need to Counter a Spell******
	;-------------------------------------------	
	if ${doCounter}
		call counteringfunct
	;-------------------------------------------
	;***Check If I Need to Dispell a Spell******
	;-------------------------------------------
	if ${doDispell}
		call dispellfunct
	;-------------------------------------------
	;****Check If I Need to Push a Stance******
	;-------------------------------------------
	if ${doStancePush}
		call StancePushfunct
	if ${doClickies}
		call clickiesfunct
	if ${DoClassEmergency}
		call Class_Emergency
	return
}

;===================================================
;===             Post Casting Loop             ====
;===================================================
function PostCastingActions()
{
	call EmergencyActions
	if !${DoByPassVGAHeals}
		call Healcheck
	if ${DoLooseTarget}
		call LooseTarget
	if ${doPushAgro}
		call pushagrototank
	if ${doRescue}
		call rescue
	;-------------------------------------------
	;****Check for Class Specific Post**********
	;-------------------------------------------
	if ${DoClassPostCasting}
		call Class_PostCasting
	;-------------------------------------------
	;********Check If I Can Critical************
	;-------------------------------------------
	if ${doAOECrits}
		call functAOECrits
	if ${doBuffCrits}
		call functBuffCrits
	if ${doDotCrits}
		call functDotCrits
	if ${doCombatCrits}
		call functCombatCrits
	;-------------------------------------------
	;****Check If I Need to use my Counter******
	;-------------------------------------------
	if ${doCounterAttack}
		call functCounterAttacks
	if ${DoResInCombat}
		call ResUp
	return
}

;********************************************
atom atexit()
{
	VG:ExecBinding[straferight,release]
	VG:ExecBinding[strafeleft,release]
	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright,release]
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
        Event[VG_OnParlayOppTurnEnd]:DetachAtom[OnParlayOppTurnEnd]
	ui -unload "${Script.CurrentDirectory}/vga_gui.xml"
	endscript vga
}

function ResetWindow()
{
	UIElement[vga_gui]:Reset
	echo "VGA window has been reset"
}
