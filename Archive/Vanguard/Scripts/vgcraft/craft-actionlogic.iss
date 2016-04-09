/* Logic for Choosing a Crafting Action */
/* Also for Complications */

/*

Problem Solving: Effectiveness of Remedy Actions (only remedies)
Reasoning: Potency of Utility Actions (only crafting)
Ingenuity: Potency of Station Actions (only crafting)
Finesse: Potency of Tool Actions (only crafting)

Station Skill: Potency of Station actions and complication frequency.  (shaping)
Utility Skill: Potency of Utility Actions (both crafting and remedies) (shaping Utilities)
Tool Skill: Potency of Tool Actions (both crafting and remedies)       (shaping tools)

*/




/* Contains the logic on what type of action to choose */
function:bool ChooseAction()
{
	variable bool hasQualityStep = FALSE
	variable bool lastStepDone = FALSE
	variable bool isHard = FALSE
	variable bool DifficultySet = FALSE
	variable string aDiff
	variable string sSkill
	variable int iCount
	variable int testProgress
	variable int testQuality
	variable int rateProg
	variable int rateQual
	variable int apPercent
	variable int apLeft
	variable int qualityStep
	variable int stepsLeft
	variable int totalStepsLeft
	variable int userAPLimit
	variable float userMaxQ
	variable float currentAPRatio
	variable float userMinQ
	variable float iTempQual


	variable bool doProgress = FALSE
	variable bool doQuality = FALSE
	variable bool doAllowItem = FALSE
	variable bool doLowCost = FALSE
	variable bool doHighCost = FALSE


	;
	; Take care of some bookeeping
	;
	lastAPDiff:Set[${Math.Calc[${Refining.ActionPointsUsed} - ${lastAP}]}]
	lastAP:Set[${Refining.ActionPointsUsed}]

	iCount:Set[${stepAPUsed[${currentStep}]}]
	stepAPUsed[${currentStep}]:Set[${Math.Calc[${iCount} + ${lastAPDiff}]}]
	stageAPUsed:Set[${Math.Calc[${stageAPUsed} + ${lastAPDiff}]}]

	; Update Quality trackers
	lastQualDiff:Set[${Math.Calc[${Refining.Quality} - ${lastQuality}]}]
	lastQuality:Set[${Refining.Quality}]

	call StepUsed ${Refining.Stage.Step[${currentStep}].TypeID}
	if ( ${Return} )
		lastStepDone:Set[TRUE]

	if (${lastQualDiff} > 0) && !${inCorrection} && !${lastStepDone} && !${currentActionName.Equal[NONE]}
		call updateActionStoreQuality "${currentActionName}" ${lastQualDiff}

	; Update Progress trackers
	if ( ${Refining.CurrentRecipe.ProgressBarPct} == 0 )
	{
		fLastProgDiff:Set[0]
		fCheckProgress:Set[0]
		fLastProgress:Set[0]
	}
	else
	{
		fLastProgDiff:Set[${Refining.CurrentRecipe.ProgressBarPct} - ${fCheckProgress}]
		if ( ${fLastProgDiff} < 0 )
		{
			fLastProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
		}
		else
		{
			fLastProgress:Set[${fCheckProgress}]
			if !${inCorrection} && !${lastStepDone} && !${currentActionName.Equal[NONE]}
				call updateActionStoreProgress "${currentActionName}" ${fLastProgDiff}
		}
		fCheckProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
	}

	if ${inCorrection} && !${lastCorrection.Equal[NONE]}
	{
		call DebugOut "VGCraft:: correction ${lastCorrection} cost ${lastAPDiff} AP"
		call StatsOut "VGCraft::      correction ${lastCorrection} cost ${lastAPDiff} AP"
	}
	elseif !${currentActionName.Equal[NONE]}
	{
		call DebugOut "VGCraft:: action ${currentActionName} cost ${lastAPDiff} AP"
		call DebugOut "VGCraft:: ${currentActionName} with progress ${fLastProgDiff.Int}%"
		;call DebugOut "VGCraft:: setting fLastProgress: ${fLastProgress} :: ${fCheckProgress}"
		call StatsOut "VGCraft:: action ${currentActionName} cost ${lastAPDiff} AP"
		call StatsOut "VGCraft:: ${currentActionName} with progress ${fLastProgDiff.Int}%"
	}


	;
	; These are used for computations later on
	;
	apLeft:Set[${Refining.OrigActionPointsAvail} - ${Refining.ActionPointsUsed}]

	if (${apLeft} <= 0)
		apLeft:Set[1]

	if (${Refining.OrigActionPointsAvail} > 0)
		apPercent:Set[${Math.Calc[(${apLeft} / ${Refining.OrigActionPointsAvail}) * 100]}]
	else
		apPercent:Set[0]

	testProgress:Set[1]
	testQuality:Set[0]

	; Find Total steps left in the Recipe
	call TotalStepsRemaining
	totalStepsLeft:Set[${Return}]

	call StepsRemaining
	stepsLeft:Set[${Return}]

	call DebugOut "VGCraft::   ---  AP left ${apLeft}  ---"
	call DebugOut "VGCraft::   --- TotalStepsRemaining: ${totalStepsLeft}  ---"
	call DebugOut "VGCraft::   --- StepsRemaining: ${stepsLeft} ---"

	if ${GV[bool,CraftingCatalystAvailable]}
	{
		call DebugOut "VGCraft:: Catalyst Step! using it now"
		cState:Set[CS_ACTION_WAIT]
		VGExecute "/craftingaddsecondary"
		return TRUE
	}

	if ${inCorrection} && ${complicationRemoved}
	{
		complicationRemoved:Set[FALSE]
		inCorrection:Set[FALSE]
	}

	; First, see if we need to fix any complications
	if ${doComplications} && ${Refining.ComplicationsCount} > 0 && ${totalStepsLeft} > 0
	{
		call CheckComplication
		if ${Return}
		{
			; CheckComplication has set the correct cState, so let main handle it
			call DebugOut "VGCraft -- CheckComplication() returned ${Return} -- returning TRUE from ChooseAction()"
			inCorrection:Set[TRUE]
			return TRUE
		}
		else
		{
			inCorrection:Set[FALSE]
		}
	}


	; Check to see if all the steps are greyed out
	if ( ${stepsLeft} == 0 )
	{
		call DebugOut "VG:Warning: Setting KickStart TRUE" 
		doKickStart:Set[TRUE]
		fLastProgress:Set[${Refining.CurrentRecipe.ProgressBarPct}]
	}

	currentStage:Set[${Refining.Stage.Index}]
	currentStageName:Set[${Refining.Stage.Name}]

	; Find which step is the Quality +Fuel Step
	call CheckFuelQualityStep
	qualityStep:Set[${Return}]

	; Make sure that we allow Item Use
	doAllowItem:Set[TRUE]

	; Now find out what step of this stage we should be working on
	; Try to find the "worst" step actions first
	call FindWorkStep TRUE TRUE
	currentStep:Set[${Return}]
	if (${currentStep} == 0)
	{
		call FindWorkStep TRUE FALSE
		currentStep:Set[${Return}]
		if (${currentStep} == 0)
		{
			call FindWorkStep FALSE FALSE
			currentStep:Set[${Return}]
			if (${currentStep} == 0)
			{
				call FindLastWorkStep
				currentStep:Set[${Return}]
			}
		}
	}

	if ${doKickStart} && (${currentStep} == 0)
	{
		; Kickstart Mode, but can't find a step to try, let's start over
		call DebugOut "VG:ChooseAction: Reseting all the tryKickStart vars"

		for ( iCount:Set[1]; ${iCount} < 10; iCount:Inc )
		{
			tryKickStart[${iCount}]:Set[FALSE]
		}
		return FALSE
	}



	currentStepName:Set[${Refining.Stage.Step[${currentStep}].Name}]

	;call DebugOut "VG:ChooseAction: Stage: (${currentStage}) ${currentStageName} :: Step: (${currentStep}) ${currentStepName}"

	;call DebugOut "VG:ChooseAction: TotalStepsLeft: ${totalStepsLeft}"


				/*
***************************************************		
				*/

	;
	; Calc doesn't seem to work quite right late in the recipe
	;if ${totalStepsLeft} > 3
	;	totalStepsLeft:Set[${totalStepsLeft} - 2]

	if (${totalStepsLeft} == 2)
	{
		totalStepsLeft:Set[${Math.Calc[${totalStepsLeft} - 1]}]
		if ${apLeft} > 100
			apLeft:Set[${Math.Calc[${apLeft} - 100]}]
	}

	if (${totalStepsLeft} > 1) && (${apLeft} > 100)
	{
		apLeft:Set[${Math.Calc[${apLeft} - 100]}]
	}

	;
	; Find the ratio of totalStepsLeft vs AP remaining
	currentAPRatio:Set[${Math.Calc[(${totalStepsLeft} / ${apLeft}) * 10000]}]


	; Get the difficulty of the current recipe
	aDiff:Set[${TaskMaster[Crafting].CurrentWorkOrder[${Refining.CurrentRecipe.Name}].Difficulty}]
	
	if (${aDiff.Equal[NULL]} || ${aDiff.Length} <= 0)
	{
		;echo "ActionLogic::ChooseAction:  Refining.CurrentRecipe.Name: '${Refining.CurrentRecipe.Name}' did not match any current work order names."
		;echo "ActionLogic::ChooseAction:  The script thinks that the current work order is: ${CurrentWorkOrderName} -- using that name instead." 
		call DebugOut "ActionLogic::ChooseAction:  Refining.CurrentRecipe.Name: '${Refining.CurrentRecipe.Name}' did not match any current work order names."
		call DebugOut "ActionLogic::ChooseAction:  The script thinks that the current work order is: ${CurrentWorkOrderName} -- using that name instead." 
		;; This is to catch when a work order name does not match any recipe names and then the script simply chooses to select the first work order recipe it finds!
		;echo "CurrentWorkOrderName: ${CurrentWorkOrderName}"
		aDiff:Set[${TaskMaster[Crafting].CurrentWorkOrder[${CurrentWorkOrderName}].Difficulty}]
	}

	;
	; Handle special case of Recipe tab
	;
	if ${doRecipeOnly}
	{
		;call DebugOut "VGCraft:: doRecipeOnly: TRUE"
		userMinQ:Set[${minQRecipe}]
		userMaxQ:Set[${maxQRecipe}]
		userAPLimit:Set[${apLimitRecipe}]
	}
	else
	{
		if (${Refining.OrigActionPointsAvail} <= 2000)
		{
			userAPLimit:Set[${apLimit2k}]
		}
		elseif (${Refining.OrigActionPointsAvail} <= 2500)
		{
			userAPLimit:Set[${apLimit25k}]
		}
		elseif (${Refining.OrigActionPointsAvail} <= 3000)
		{
			userAPLimit:Set[${apLimit3k}]
		}
		elseif (${Refining.OrigActionPointsAvail} >= 3001)
		{
			userAPLimit:Set[${apLimit35k}]
			isHard:Set[TRUE]
		}
	

		; Set the Limits based on the Difficulty of this recipe
		if ${aDiff.Equal[Very Easy]} || ${aDiff.Equal[Trivial]}
		{
			;call DebugOut "VGCraft:: minQVEasy: ${aDiff}"
			userMinQ:Set[${minQVEasy}]
			userMaxQ:Set[${maxQVEasy}]
			DifficultySet:Set[TRUE]
		}
		elseif ${aDiff.Equal[Easy]}
		{
			;call DebugOut "VGCraft:: minQEasy: ${aDiff}"
			userMinQ:Set[${minQEasy}]
			userMaxQ:Set[${maxQEasy}]
			DifficultySet:Set[TRUE]
		}
		elseif ${aDiff.Equal[Moderate]}
		{
			;call DebugOut "VGCraft:: minQMod: ${aDiff}"
			userMinQ:Set[${minQMod}]
			userMaxQ:Set[${maxQMod}]
			userAPLimit:Set[${Math.Calc[${userAPLimit} - 5]}]
			DifficultySet:Set[TRUE]
		}
		elseif ${aDiff.Equal[Difficult]}
		{
			;call DebugOut "VGCraft:: minQDiff: ${aDiff}"
			userMinQ:Set[${minQDiff}]
			userMaxQ:Set[${maxQDiff}]
			userAPLimit:Set[${Math.Calc[${userAPLimit} - 7]}]
			DifficultySet:Set[TRUE]
		}
		
		;
		; Set the Limits based on # of Total AP available in this recipe
		; This is to catch any that don't have a "Word" difficulty associated with them
		if (!${DifficultySet})
		{
			if (${Refining.OrigActionPointsAvail} <= 2000)
			{
				userMinQ:Set[${minQVEasy}]
				userMaxQ:Set[${maxQVEasy}]
				userAPLimit:Set[${apLimit2k}]
			}
			elseif (${Refining.OrigActionPointsAvail} <= 2500)
			{
				userMinQ:Set[${minQEasy}]
				userMaxQ:Set[${maxQEasy}]
				userAPLimit:Set[${apLimit25k}]
			}
			elseif (${Refining.OrigActionPointsAvail} <= 3000)
			{
				userMinQ:Set[${minQMod}]
				userMaxQ:Set[${maxQMod}]
				userAPLimit:Set[${apLimit3k}]
			}
			elseif (${Refining.OrigActionPointsAvail} >= 3001)
			{
				userMinQ:Set[${minQDiff}]
				userMaxQ:Set[${maxQDiff}]
				userAPLimit:Set[${apLimit35k}]
			}
		}
	}
	;echo "ActionLogic::ChooseAction:  aDiff: ${aDiff} -- userMinQ: ${userMinQ} -- userMaxQ: ${userMaxQ} -- userAPLimit: ${userAPLimit}"
	call DebugOut "ActionLogic::ChooseAction:  aDiff: ${aDiff} -- userMinQ: ${userMinQ} -- userMaxQ: ${userMaxQ} -- userAPLimit: ${userAPLimit}"


	UIElement[APLimit@CHUD]:SetText["${userAPLimit} vs ${currentAPRatio.Int}"]

				/*
     ***************************************************		
				 */

	call rateProgressStep ${currentStep}
	rateProg:Set[${Return}]

	call rateQualityStep ${currentStep}
	rateQual:Set[${Return}]

	call rateSkillStep ${currentStep}
	sSkill:Set[${Return}]

	if ${sSkill.Equal[Progress]}
	{
		testProgress:Inc[2]
		;call MyOutput "VG:ChooseAction: rateSkill Progress: ${testProgress} :: ${testQuality}"
	}
	elseif ${sSkill.Equal[Quality]}
	{
		testQuality:Inc[2]
		;call MyOutput "VG:ChooseAction: rateSkill Quality: ${testProgress} :: ${testQuality}"
	}
	elseif ${sSkill.Equal[ProgressOnly]}
	{
		testProgress:Inc[5]
		testQuality:Dec[5]
		;call MyOutput "VG:ChooseAction: rateSkill ProgressOnly: ${testProgress} :: ${testQuality}"
	}

	if ${rateProg} >= MOD
	{
		testProgress:Inc[2]
		;call MyOutput "VG:ChooseAction: rateProg >=4: ${testProgress} :: ${testQuality}"
	}

	if ${rateQual} > MOD
	{
		testQuality:Inc[${rateQual}]
		;call MyOutput "VG:ChooseAction: rateQual > 4: ${testProgress} :: ${testQuality}"
	}
	else
	{
		testQuality:Dec[2]
		;call MyOutput "VG:ChooseAction: rateQual < 3: ${testProgress} :: ${testQuality}"
	}

	; Test to see if we are over the limits
	if (${Refining.Quality} > ${userMaxQ})
	{
		; Dump Quality, push Progress
		testProgress:Inc[10]
		testQuality:Dec[${Math.Calc[${rateQual} + 5]}]

		;call MyOutput "VG:ChooseAction: maxQ Stop: ${Refining.Quality} > ${userMaxQ}   :: ${testProgress} :: ${testQuality}"
	}

	; 45 > 50
	; 50 > 50
	; 55 > 50
	if ${currentAPRatio} >= (${Math.Calc[${userAPLimit} - 10]})
	{
		; Getting close to stop limit, ramp Progress
		testProgress:Inc[2]
		;call MyOutput "VG:ChooseAction: #1 userAPLimit - 8 Ramp Prog: ${currentAPRatio} > ${userAPLimit}    :: ${testProgress} :: ${testQuality}"
	}
	if ${currentAPRatio} >= ${userAPLimit}
	{
		; At Stop limit, Slow Qual and Speed Prog
		testProgress:Inc[2]
		testQuality:Dec[4]
		;call MyOutput "VG:ChooseAction: #2 userAPLimit mid: ${currentAPRatio} > ${userAPLimit}    :: ${testProgress} :: ${testQuality}"
	}
	if ${currentAPRatio} >= (${Math.Calc[${userAPLimit} + 5]})
	{
		; Only do Progress!
		testProgress:Inc[5]
		testQuality:Dec[5]
		;call MyOutput "VG:ChooseAction: #3 userAPLimit + 5 Stop Qual: ${currentAPRatio} > ${userAPLimit}    :: ${testProgress} :: ${testQuality}"
	}


	;call DebugOut "VGCraft:: == APLimit == vs currAPRatio: ${userAPLimit} vs ${currentAPRatio}"
	;call DebugOut "VGCraft:: == MaxQ == vs Qual: ${userMaxQ} vs ${Refining.Quality} "

	; If we ran out of AP last action, try to find a lower cost one
	if ( ${ooAPCheck} )
	{
		doLowCost:Set[TRUE]
	}
	elseif (${Refining.Stage.Index} == 4) && (${stepsLeft} == 1)
	{
		doHighCost:Set[TRUE]
	}

	; If we do not have the Fuel->Quality step in this stage push Progress instead
	;call CheckFuelStage
	;if !${Return} && ${isHard}
	;{
	;	testProgress:Inc[5]
	;	testQuality:Dec[5]
	;	call MyOutput "VG:ChooseAction: not Fuel Stage: ${testProgress} :: ${testQuality}"
	;}

	; If we are below the user supplied MaxQ threshold ratio, push Quality
	if (${Refining.Quality} < ${userMaxQ})
	{
		; If we have a High Quality Action in this step
		if ${rateQual} > MOD
		{
			; 30 :: 20
			; 30 :: 25
			if ${userAPLimit} > ${Math.Calc[${currentAPRatio} + 10]}
			{
				; If we are far below the APLimit then PUMP Quality
				;call MyOutput "VG:#1 High Quality Action in this step and way below APLimit"
				testProgress:Dec[1]
				testQuality:Inc[5]
			}
			elseif ${userAPLimit} > ${Math.Calc[${currentAPRatio} + 5]}
			{
				; If we are just a bit below the APLimit then push Quality
				;call MyOutput "VG:#2 High Quality Action in this step and a bit below APLimit"
				testQuality:Inc[2]
			}
		}

		call isToolStep ${currentStep}
		; This is a Tool Step and we want to use Tools to Push Quality
		if !${preferUtility} && ${Return}
		{
			testProgress:Dec[2]
			testQuality:Inc[4]
		}

		; If this is the Quality + Fuel step, push Quality
		if (${qualityStep} == ${currentStep})
		{
			; Make sure that we allow Item Use
			doAllowItem:Set[TRUE]

			if ${preferUtility}
			{
				testProgress:Dec[1]
				testQuality:Inc[2]
				;call MyOutput "VG:ChooseAction: Fuel Step!: ${testProgress} :: ${testQuality}"
			}
			elseif ${Refining.Quality} >= ${userMaxQ}
			{
				; Prefer tools to Utilities when pushing Quality
				testProgress:Inc[4]
				testQuality:Dec[2]
				;call MyOutput "VG:ChooseAction: Fuel step, but prefer tools: ${testProgress} :: ${testQuality}"
			}
		}

		; If we are below the TargetQuality we should try to raise it
		if ( ${Refining.Quality} < ${userMinQ} )
		{
			testProgress:Dec[1]
			testQuality:Inc[3]
			;call MyOutput "VG:ChooseAction: Quality Low: ${testProgress} :: ${testQuality}"
		}
		;else
		;{
		;	testProgress:Inc[1]
		;	;testQuality:Dec[2]
		;	call MyOutput "VG:ChooseAction: Quality above MIN: ${testProgress} :: ${testQuality}"
		;}
	}

	if (${Refining.Quality} >= 850)
	{
		testProgress:Inc[1]
		testQuality:Dec[1]
		;call MyOutput "VG:ChooseAction: Quality > 850: ${testProgress} :: ${testQuality}"
	}

	if (${Refining.Quality} >= 999)
	{
		testProgress:Inc[5]
		testQuality:Dec[10]
		;call MyOutput "VG:ChooseAction: Quality > 999: ${testProgress} :: ${testQuality}"
	}

	call TableFuelLow
	if ${Return}
	{
		testProgress:Inc[10]
		testQuality:Dec[10]
		call MyOutput "VG:ChooseAction: FUEL LOW!: ${testProgress} :: ${testQuality}"
	}

	; If we have exceded the "recommended" AP for this Stage, push progress
	;if ${stageAPUsed} > ${allowedStageAP}
	;{
	;	testProgress:Inc[4]
	;	call MyOutput "VG:ChooseAction: Over allowedStageAP: ${stageAPUsed} :: ${allowedStageAP}"
	;}


	call MyOutput "VG:ChooseAction: testProg vs Qual:   ${testProgress} :: ${testQuality}"




	; Ok, call the FindAction sequence. We have to iterate through because we need
	; to find an action, even if the decision tree is not correct

	;call DebugOut "VG:ChooseAction #1: FindAction2 passed in parameters"
	call FindAction2 ${testProgress} ${testQuality} ${doAllowItem} ${doLowCost} ${doHighCost}
	if ${Return}
		return TRUE

	;call DebugOut "VG:ChooseAction #2: FindAction2 with doAllowItem=TRUE"
	call FindAction2 ${testProgress} ${testQuality} TRUE ${doLowCost} ${doHighCost}
	if ${Return}
		return TRUE

	;call DebugOut "VG:ChooseAction #3: FindAction2 with doAllowItem=TRUE doLowCost=FALSE doHighCost=TRUE"
	call FindAction2 ${testProgress} ${testQuality} TRUE FALSE TRUE
	if ${Return}
		return TRUE

	;call DebugOut "VG:ChooseAction #4: FindAction2 with doAllowItem=TRUE doLowCost=TRUE doHighCost=FALSE"
	call FindAction2 ${testProgress} ${testQuality} TRUE TRUE FALSE
	if ${Return}
		return TRUE

	call DebugOut "VG:ERROR: No action can be found... this is BAD!"
	return FALSE
}


/* Finds the best action based on the passed in criteria */
function:bool FindAction2(int testProgress, int testQuality, bool useItem, bool doLowCost, bool doHighCost)
{
	variable int tstep
	variable int substep

	variable string aName
	variable int apLeft
	variable int testCost = 9999
	variable int testHighCost = 0
	variable int testProg = 0
	variable int testQual = 0
	variable int testAvgProg = 0
	variable int testAvgQual = 0
	variable int testNumUsed = 0

	apLeft:Set[${Refining.OrigActionPointsAvail} - ${Refining.ActionPointsUsed}]

	if (${apLeft} <= 0)
		apLeft:Set[1]

	aName:Set[NONE]

	tstep:Set[${currentStep}]

	;if (${testQuality} < 0)
	;	testQuality:Set[0]

	;if (${testProgress} < 0)
	;	testProgress:Set[0]

	;call DebugOut "VG:FindAction2: doProg: ${testProgress} doQual: ${testQuality} useItem: ${useItem} lowCost: ${doLowCost} highCost: ${doHighCost}"

	; Stage 1, Check to see if the user has Specified an Action #
	if ${doRecipeOnly} && (${Refining.Stage.Index} == 1)
	{
		variable int stepsLeft

		call StepsRemaining
		stepsLeft:Set[${Return}]

		;call DebugOut "VG:FindAction2: Recipe Only!"

		; Check to see how many Steps in this Stage
		if (${Refining.Stage.StepCount} == 2)
		{
			if (${stepsLeft} == 1)
			{
				; Two Steps in this stage, but only 1 left, Check use Chosen Action #
				if ${doStep2Action}
				{
					currentActionName:Set[${Refining.Stage.Step[2].AvailAction[${recipeStep2Action}].Name}]
					;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
					return TRUE
				}
				else
				{
					; Ok, then just use the 1st action
					currentActionName:Set[${Refining.Stage.Step[2].AvailAction[1].Name}]
					;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
					return TRUE
				}
			}
			else
			{
				; Do 1st Step in this stage, see if the user has Chosen an Action #
				if ${doStep1Action}
				{
					currentActionName:Set[${Refining.Stage.Step[1].AvailAction[${recipeStep1Action}].Name}]
					;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
					return TRUE
				}
				else
				{
					; Ok, the just use the first
					currentActionName:Set[${Refining.Stage.Step[1].AvailAction[1].Name}]
					;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
					return TRUE
				}
			}
		}
		else
		{
			; Only one Step in this stage, see if the user has Chosen an Action #
			if ${doStep1Action}
			{
				currentActionName:Set[${Refining.Stage.Step[1].AvailAction[${recipeStep1Action}].Name}]
				;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
				return TRUE
			}
			else
			{
				; Ok, the just use the first
				currentActionName:Set[${Refining.Stage.Step[1].AvailAction[1].Name}]
				;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
				return TRUE
			}
		}
	}

	; Stage 1, so use Supplied Material
	if ( ${Refining.Stage.Index} == 1 )
	{
		tstep:Set[1]
		do
		{
			substep:Set[1]
			do
			{
				if ( ${useSupplied} && ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[supplied material]} )
				{
					currentActionName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]
					;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
					return TRUE
				}
				elseif ( !${useSupplied} && ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[harvested material]} )
				{
					currentActionName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]
					;call DebugOut "VG:FindAction2: Found: ${currentActionName}"
					return TRUE
				}
			}
			while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} )
		}
		while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )
	}


	substep:Set[1]
	do
	{

			variable string newName
			variable int iCost = 0
			variable int iProg = 0
			variable int iQual = 0
			variable int avgProg = 0
			variable int avgQual = 0
			variable int qualLoss = 0
			variable bool hasItem = FALSE
			variable bool hasTool = FALSE
			variable float progRatio
			variable float qualRatio
			variable float testProgRatio
			variable float testQualRatio
			variable int numUsed = 0

			newName:Set[${Refining.Stage.Step[${currentStep}].AvailAction[${substep}].Name}]

			if !${actionStore.FindSet[${newName}](exists)} && !${newName.Equal[NULL]} && !${Me.IsLooting}
            {
				call DebugOut "VG:ERROR: ${newName} not in the actionStore, adding it"
				call addRecipeToActionStore
			}
            elseif ${newName.Equal[NULL]} && ${Me.IsLooting}
   			{
				cState:Set[CS_LOOT]
				call resetCounts
				statRecipeDone:Inc
			 	UIElement[TotalRecipe@CHUD]:SetText[${statRecipeDone}]
				UIElement[FailedRecipe@CHUD]:SetText[${statRecipeFailed}]
			}
			
			;call MyOutput "VG:Testing ActionName: ${newName}"

			iCost:Set[${actionStore.FindSet[${newName}].FindSetting[ActionPointCost,1]}]
			qualLoss:Set[${actionStore.FindSet[${newName}].FindSetting[QualLoss,0]}]
			iProg:Set[${actionStore.FindSet[${newName}].FindSetting[Progress,0]}]
			iQual:Set[${actionStore.FindSet[${newName}].FindSetting[Quality,0]}]
			avgProg:Set[${actionStore.FindSet[${newName}].FindSetting[AvgProg,0]}]
			avgQual:Set[${actionStore.FindSet[${newName}].FindSetting[AvgQual,0]}]
			hasItem:Set[${actionStore.FindSet[${newName}].FindSetting[ItemRequired,FALSE]}]
			hasTool:Set[${actionStore.FindSet[${newName}].FindSetting[ToolRequired,FALSE]}]
			numUsed:Set[${actionStore.FindSet[${newName}].FindSetting[NumUsed,0]}]

			if ${iCost} <= 0
				iCost:Set[1]

			;if ${avgQual} > 0
			;	avgQual:Set[${Math.Calc[${avgQual} / 10]}]

			;if ${doUseActionStore}
			;	call MyOutput "VG:FA2: ${newName} :: Cost: ${iCost} Prog: ${avgProg} Qual: ${avgQual} numUsed: ${numUsed}"
			;else
				;call MyOutput "VG:FA2: ${newName} :: Cost: ${iCost} Prog: ${iProg} Qual: ${iQual} hasItem: ${hasItem}"

			if !${useItem} && ${hasItem}
			{
				; Don't use Items
				continue
			}

			if ${iCost} > ${apLeft}
			{
				; Costs more than we have left!
				continue
			}

			; Find the lowest Cost action
			if ${doLowCost}
			{
				if (${iCost} < ${testCost})
				{
					; We only want the lowest cost Action
					aName:Set[${newName}]
					testCost:Set[${iCost}]
					testProg:Set[${iProg}]
					testQual:Set[${iQual}]
					testAvgProg:Set[${avgProg}]
					testAvgQual:Set[${avgQual}]
					testNumUsed:Set[${numUsed}]

					;call DebugOut "VGCraft::  ===  LowCost Selecting: ${newName}"
				}

				continue
			}

			; Find the highest Cost action
			if ${doHighCost}
			{
				if (${iCost} >= ${testHighCost})
				{
					; We only want the highest cost Action
					aName:Set[${newName}]
					testCost:Set[${iCost}]
					testHighCost:Set[${iCost}]
					testProg:Set[${iProg}]
					testQual:Set[${iQual}]
					testAvgProg:Set[${avgProg}]
					testAvgQual:Set[${avgQual}]
					testNumUsed:Set[${numUsed}]

					;call DebugOut "VGCraft::  ===  High cost Selecting: ${newName}"
				}

				continue
			}

			; If this action has never been used, force a few usages
			;if ${doUseActionStore} && (${numUsed} < 2)
			;{
			;	aName:Set[${newName}]
			;	testCost:Set[${iCost}]
			;	testHighCost:Set[${iCost}]
			;	testProg:Set[${iProg}]
			;	testQual:Set[${iQual}]
			;	testAvgProg:Set[${avgProg}]
			;	testAvgQual:Set[${avgQual}]
			;	testNumUsed:Set[${numUsed}]
			;	call DebugOut "VGCraft::  ===  Forcing unused Action: ${newName}"
			;	break
			;}

			if (${qualLoss} > 0)
			{
				;This action LOSES Quality, so make it "cost" more
				iCost:Inc[${Math.Calc[200 * ${qualLoss}]}]
				call MyOutput "VGCraft:: Lose Qual: ${newName} :: ${iCost}"
			}

			; Test to see if the last action for this Step would put us over the Greyed out mark
			call CheckOverProgress "${newName}"
			if ${Return}
			{
				; This step would put us over our Progress %, so make it "cost" more
				;call MyOutput "VGCraft:: Over Progress: ${newName}"
				iCost:Inc[50]
			}

			; Need to find the ratio of Cost to Progress to get the best one
			; Perhaps:
			;  avgProg/iCost
			; Example: 
			;  10 prog/100 cost = 0.10
			;   8 prog/50 cost = 0.16
			;   5 prog/50 cost = 0.10

			;if ${doUseActionStore}
			;{
			;	progRatio:Set[${Math.Calc[(${avgProg} / ${iCost}) * ${testProgress}]}]
			;	testProgRatio:Set[${Math.Calc[(${testAvgProg} / ${testCost}) * ${testProgress}]}]

			;	qualRatio:Set[${Math.Calc[(${avgQual} / ${iCost}) * ${testQuality}]}]
			;	testQualRatio:Set[${Math.Calc[(${testAvgQual} / ${testCost}) * ${testQuality}]}]
			;}
			;else
			;{
				progRatio:Set[${Math.Calc[(${iProg} / ${iCost}) * ${testProgress}]}]
				testProgRatio:Set[${Math.Calc[(${testProg} / ${testCost}) * ${testProgress}]}]

				qualRatio:Set[${Math.Calc[(${iQual} / ${iCost}) * ${testQuality}]}]
				testQualRatio:Set[${Math.Calc[(${testQual} / ${testCost}) * ${testQuality}]}]
			;}

			;call MyOutput "VG:FA2: ${newName} Prat: ${progRatio} :: ${testProgRatio}   Qrat: ${qualRatio} :: ${testQualRatio}"

			variable float newNum
			variable float testNum

			newNum:Set[${Math.Calc[${progRatio} + ${qualRatio}]}]
			testNum:Set[${Math.Calc[${testProgRatio} + ${testQualRatio}]}]

			; Want to find the Highest Progress + Quality Action
			if (${newNum} > ${testNum}) || ((${newNum} == ${testNum}) && (${iCost} > ${testCost}))
			{
				aName:Set[${newName}]
				testCost:Set[${iCost}]
				testProg:Set[${iProg}]
				testQual:Set[${iQual}]
				testAvgProg:Set[${avgProg}]
				testAvgQual:Set[${avgQual}]
				testNumUsed:Set[${numUsed}]

				;call MyOutput "VG:BOTH: ${newName} New: ${newNum} :: ${testNum} "
			}

	}
	while ( ${substep:Inc} <= ${Refining.Stage.Step[${currentStep}].AvailActionsCount} ) 

	if ${aName.Equal[NONE]}
	{
		call DebugOut "VG:FindAction2:Error: NOTHING FOUND!"
		return FALSE
	}
	else
	{
		call DebugOut "VG:FindAction2: Found: ${aName}"
		currentActionName:Set[${aName}]
		return TRUE
	}

}

/* Use the current selected Action */
function ExecuteAction()
{
	variable int useStep
	variable int useSubStep
	variable int currentAction


	if ( ${Refining.OrigActionPointsAvail} == 0 )
	{
		call DebugOut "VG:ERROR: No action points, but trying to use an Action!"
		doKickStart:Set[FALSE]
		call resetCounts
		return
	}

	useStep:Set[${currentStep}]

	call translateAction "${currentActionName}"
	useSubStep:Set[${Return}]

	;call DebugOut "VG:ExecuteAction :Last: ${fLastProgress} :: ${Refining.CurrentRecipe.ProgressBarPct}"
	;call DebugOut "VG:ExecuteAction: Step: ${useStep} :: ${useSubStep}"
	;call DebugOut "VG:ExecuteAction: Step: ${currentStepName} :: ${currentActionName}"

	if !${Refining.Stage.Step[${useStep}].AvailAction[${useSubStep}](exists)}
	{
		call ErrorOut "VG:ERROR: ${currentActionName} does not exist!"
		return
	}

	call DebugOut "VG:ExecuteAction: StepName:${currentStepName} ActionName:${currentActionName}  APCost: ${Refining.Stage.Step[${useStep}].AvailAction[${useSubStep}].ActionPointCost}"

	if ( ${doKickStart} )
	{
		call translateStep "${currentStepName}"
		useStep:Set[${Return}]

		call translateAction "${currentActionName}"
		useSubStep:Set[${Return}]

		call DebugOut "VG:ExecuteAction:KICK: Using step ${useStep} :: ${useSubStep}"

		; Hack to prevent loosing AP
		VGExecute "/craftingselectstep ${useStep}"
		wait 3

		VGExecute "/craftingselectaction ${useSubStep}"
		wait 3
	}
	else
	{
		call DebugOut "VG:ExecuteAction: Using: ${Refining.Stage.Step[${useStep}].AvailAction[${useSubStep}].Name}"

		Refining.Stage.Step[${useStep}].AvailAction[${useSubStep}]:Use
	}
}


/* ========================================================================================== */
/* ======================                 Functions               =========================== */
/* ========================================================================================== */


/* Always try to return High progress/Low Quality steps first */
/* Save the Quality for last! */
function:int FindWorkStep(bool doLowQual, bool doLowProg)
{
	variable string newName
	variable bool actionNoGood
	variable int stepsLeft
	variable int tstep
	variable int substep

	; Check to see if we have all the steps greyed out
	call StepsRemaining
	stepsLeft:Set[${Return}]

	call DebugOut "VGCraft:: FindWorkStep called:  Q: ${doLowQual}  P: ${doLowProg}"

	; Stage 1, Check to see if the user has Specified an Action #
	if ${doRecipeOnly} && (${Refining.Stage.Index} == 1)
	{
		call DebugOut "VG:FindWorkStep: Recipe Only!"

		; Check to see how many Steps in this Stage
		if (${Refining.Stage.StepCount} == 2)
		{
			if (${stepsLeft} == 1)
			{
				return 2
			}
			else
			{
				return 1
			}
		}
		else
		{
			; Only 1 Step in this stage
			return 1
		}
	}


	; Stage 1, so use Supplied Material
	if ( ${Refining.Stage.Index} == 1 )
	{
		tstep:Set[1]
		do
		{
			call ActionStepAllowed ${tstep}
			if ${Return}
			{
				substep:Set[1]
				do
				{
					if ( ${useSupplied} && ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[supplied material]} )
					{
						return ${tstep}
					}
					elseif ( !${useSupplied} && ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[harvested material]} )
					{
						return ${tstep}
					}
				}
				while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} )
			}
		}
		while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )
	}

	; Special case for 4th Stage with 2+ steps in it
	if ( ${Refining.Stage.Index} == 4 )
	{
		tstep:Set[1]
		do
		{
			call ActionStepAllowed ${tstep}
			if ${Return}
			{
				substep:Set[1]
				do
				{
					newName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]

					if (${stepsLeft} == 1)
					{
						; If there is only 1 Step left in 4th stage
						; find the Step with a No Progress and No Quality action
						if (${actionStore.FindSet[${newName}].FindSetting[Quality].Int} == 0) && (${actionStore.FindSet[${newName}].FindSetting[Progress].Int} == 0)
						{
							call DebugOut "VG:FWS: 4th Stage: Selecting LAST Step: ${tstep}"
							return ${tstep}
						}
					}
					else
					{
						if (${actionStore.FindSet[${newName}].FindSetting[Quality].Int} > 0) || (${actionStore.FindSet[${newName}].FindSetting[Progress].Int} > 0)
						{
							call DebugOut "VG:FWS: 4th Stage: Selecting other Step: ${tstep}"
							return ${tstep}
						}
					}
				}
				while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} )
			}
		}
		while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )
	}

	; Find a Step that obeys the doLowQual and doLowProg flags
	; Work our way down from the 'top' of the step List

	tstep:Set[${Refining.Stage.StepCount}]

	do
	{
		; First, check to see if we can use this Step
		call ActionStepAllowed ${tstep}
		if ${Return}
		{
			actionNoGood:Set[FALSE]
			substep:Set[1]
			do
			{
				;call MyOutput "VG:FindWorkStep: ${tstep}:${substep} :: ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}"

				newName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]

				if !${actionStore.FindSet[${newName}](exists)} && !${newName.Equal[NULL]} && !${Me.IsLooting}
				{
					call DebugOut "VG:ERROR: ${newName} not in the actionStore, adding it"
					call addRecipeToActionStore
				}
				elseif ${newName.Equal[NULL]} && ${Me.IsLooting}
				{
	                cState:Set[CS_LOOT]
	                call resetCounts
	                statRecipeDone:Inc
	                UIElement[TotalRecipe@CHUD]:SetText[${statRecipeDone}]
	                UIElement[FailedRecipe@CHUD]:SetText[${statRecipeFailed}]
	         	}

				;call MyOutput "VG:FWS: Testing ActionName: ${newName}"

				if ${doLowProg} && ${actionStore.FindSet[${newName}].FindSetting[Progress].Int} >= MOD
				{
					;Moderate progress, skip this step
					actionNoGood:Set[TRUE]
				}
				if ${doLowQual} && ${actionStore.FindSet[${newName}].FindSetting[Quality].Int} >= MOD
				{
					;Moderate Quality, skip this step
					actionNoGood:Set[TRUE]
				}
			}
			while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} )

			if !${actionNoGood}
			{
				; Step looks good, return it
				call DebugOut "VG:FWS: Selecting Step: ${tstep}"
				return ${tstep}
			}
		}
	}
	while ( ${tstep:Dec} > 0 )

	return 0
}

/* The other one failed to find what we wanted, so just get something! */
function:int FindLastWorkStep()
{
	variable int tstep
	variable int substep

	; Just return the first unused step
	tstep:Set[1]
	do
	{
		; Check to see if we can use this Step
		call ActionStepAllowed ${tstep}
		if ${Return}
		{
			call DebugOut "VG:find LAST workStep:  Selecting Step: ${tstep}"
			return ${tstep}
		}
	}
	while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )

	return 0
}

/* This step has been greyed out */
function:bool StepUsed(int StepTypeID)
{
	variable iterator i
	CompletedSteps:GetIterator[i]
	
	i:First
	
	if (!${i.IsValid})
	{
		return FALSE
	}
 
	do
	{
		if (${i.Value} == ${StepTypeID}) 
		{
			return TRUE
		}
		i:Next
	}
	while ${i.IsValid}
 
	return FALSE
}

/* Updates the average Quality in the actionStore for an Action */
function updateActionStoreQuality(string aName, int iDiff)
{
	variable int iCount
	variable float avgQual

	call MyOutput "VGCraft:: updateASQuality: ${iDiff} :: ${aName}"

	if ${actionStore.FindSet[${aName}](exists)}
	{
		if ${actionStore.FindSet[${aName}].FindSetting[Quality].Int} == 0
		{
			actionStore.FindSet[${aName}]:AddSetting[AvgQual,0]
			return
		}

		iCount:Set[${actionStore.FindSet[${aName}].FindSetting[NumUsed]}]
		avgQual:Set[${actionStore.FindSet[${aName}].FindSetting[AvgQual]}]

		if ${avgQual} > 0
			avgQual:Set[${Math.Calc[(${avgQual} + ${iDiff}) / 2]}]
		else
			avgQual:Set[${iDiff}]


		if ${avgQual} > 0
		{
			actionStore.FindSet[${aName}].FindSetting[NumUsed]:Set[${iCount:Inc}]
			actionStore.FindSet[${aName}].FindSetting[AvgQual]:Set[${avgQual}]
			call MyOutput "VGCraft:: updateASQuality added: ${avgQual} :: ${aName}"
		}
	}
	else
	{
		call DebugOut "VGCraft:: ERROR: Can't find in actionStore: ${aName}"
	}
}

/* Updates the average Progress in the actionStore for an Action */
function updateActionStoreProgress(string aName, int iDiff)
{
	variable int iCount
	variable float avgProg

	;call MyOutput "VGCraft:: updateASProgress: ${iDiff} :: ${aName}"

	if ${actionStore.FindSet[${aName}](exists)}
	{
		if ${actionStore.FindSet[${aName}].FindSetting[Progress].Int} == 0
		{
			actionStore.FindSet[${aName}]:AddSetting[AvgProg,0]
			return
		}

		iCount:Set[${actionStore.FindSet[${aName}].FindSetting[NumUsed]}]
		avgProg:Set[${actionStore.FindSet[${aName}].FindSetting[AvgProg]}]

		if ${avgProg} > 0
			avgProg:Set[${Math.Calc[(${avgProg} + ${iDiff}) / 2]}]
		else
			avgProg:Set[${iDiff}]

		if ${avgProg} > 0
		{
			actionStore.FindSet[${aName}].FindSetting[NumUsed]:Set[${iCount:Inc}]
			actionStore.FindSet[${aName}].FindSetting[AvgProg]:Set[${avgProg}]
			;call MyOutput "VGCraft:: updateASProgress added: ${avgProg} :: ${aName}"
		}
	}
	else
	{
		call DebugOut "VGCraft:: ERROR: Can't find in actionStore: ${aName}"
	}
}

/* Translates a Step Name into the Recipe Step Number */
function:int translateStep(string aName)
{
	variable int tstep
	tstep:Set[1]

	do
	{
		;call MyOutput "Step ${tstep}: ${Refining.CurrentRecipe.Step[${tstep}].Name}"

		if ( ${aName.Equal[${Refining.CurrentRecipe.Step[${tstep}].Name}]} )
			return ${tstep}
	}
	while ( ${tstep:Inc} <= ${Refining.CurrentRecipe.StepCount} )

	return 1
}

/* Translates an Action Name into the recipe Action Number */
function:int translateAction(string aName)
{
	variable int tstep
	tstep:Set[1]

	do
	{
		variable int substep
		substep:Set[1]
		do
		{
			;call MyOutput "Step ${tstep}:AvailAction ${substep}:${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Name}"
			
			if ( ${aName.Equal[${Refining.CurrentRecipe.Step[${tstep}].AvailAction[${substep}].Name}]} )
				return ${substep}
		}
		while ( ${substep:Inc} <= ${Refining.CurrentRecipe.Step[${tstep}].AvailActionsCount} ) 

	}
	while ( ${tstep:Inc} <= ${Refining.CurrentRecipe.StepCount} )

	return 1
}

/* Check to see if we are at the Fuel Using Stage */
function:int CheckFuelQualityStep()
{
	;Item Required:

	variable int tstep
	variable int substep

	; Cycle through all the possible AvailActions and see if we have one that requires a Fuel item

	tstep:Set[1]
	do
	{
		substep:Set[1]
		do
		{
			if ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[Item Required:]} && ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[Quality:]} && !${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[Progress:]} 
			{
				return ${tstep}
			}
		}
		while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} ) 
	}
	while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )

	return 0
}

/* Check to see if we are at the Fuel Using Stage */
function:bool CheckFuelStage()
{
	;Item Required:

	variable int tstep
	variable int substep

	tstep:Set[1]

	; Cycle through all the possible AvailActions and see if we have one that requires a Fuel item
	do
	{
		substep:Set[1]

		do
		{
			if ( ${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Description.Find[Item Required:]} )
				return TRUE
		}
		while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} ) 
	}
	while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )

	return FALSE
}

/* Check to see if this Action used again would put us over 50% usage */
function:bool CheckOverProgress(string aName)
{
	variable float stepProg
	variable float avgProg

	if ( ${StepProgress[${aName}](exists)} )
	{
		; Total progress on this step so far
		stepProg:Set[${StepProgress.Element[${aName}]}]
		avgProg:Set[${actionStore.FindSet[${aName}].FindSetting[AvgProg]}]

		;call DebugOut "VGCraft:: stepProg: ${stepProg}"
		;call DebugOut "VGCraft:: StepProgress: ${StepProgress.Element[${aName}]} :: ${Refining.CurrentRecipe.ProgressBarPct}"

		; There could be 3 steps in a stage, so that would be 33% instead of 50%
		if ( ${Refining.Stage.StepCount} > 2 )
		{
			if ((${avgProg} + ${stepProg}) > 40)
			{
				;call DebugOut "VGCraft:: Would be over 34% with ${aName}"
				return TRUE
			}
		}
		else
		{
			if ((${avgProg} + ${stepProg}) > 60)
			{
				;call DebugOut "VGCraft:: Would be over 50% with ${aName}"
				return TRUE
			}
		}
	}
	return FALSE
}

/* Mark a KickStart Step as tested and failed */
function markKickActionUsed()
{
	tryKickStart[${currentStep}]:Set[TRUE]
}

/* Mark a KickStart Step as tested and failed */
function markKickActionNotUsed()
{
	tryKickStart[${currentStep}]:Set[FALSE]
}

/* Make sure this step hasn't been greyed out yet */
/* Or hasn't been used in a tryKickStart action */
function:bool ActionStepAllowed(int iStep)
{
	if ${doKickStart}
	{
		; We are in kickstart mode, so select the 1st unused tryKickStart[]
		if !${tryKickStart[${iStep}]}
			return TRUE
	}
	else
	{
		call StepUsed ${Refining.Stage.Step[${iStep}].TypeID}
		if ( ! ${Return} )
		{
			; Not used yet, lets give it a try
			return TRUE
		}
	}

	return FALSE
}

/* How many more Steps we can use in this Stage? */
/* If zero then they are all greyed out */
function:int StepsRemaining()
{
	variable int tstep
	variable int iCount

	iCount:Set[${Refining.Stage.StepCount}]
	tstep:Set[1]

	do
	{
		call StepUsed ${Refining.Stage.Step[${tstep}].TypeID}
		if ( ${Return} )
		{
			; This Step has been greyed out, so continue
			call MyOutput "STEP GRAYED OUT -- ${tstep} :: ${Refining.Stage.Step[${tstep}].TypeID}"
			iCount:Dec
		}
	}
	while ( ${tstep:Inc} <= ${Refining.Stage.StepCount} )

	return ${iCount}
}

/* Finds the total # of steps left in the recipe */
function:int TotalStepsRemaining()
{
	variable int tstep
	variable int iCount
	variable int iStage
	variable int stepCount

	stepCount:Set[0]
	iStage:Set[${currentStage}]

	do
	{
		tstep:Set[1]

		do
		{
			call StepUsed ${Refining.Stage[${iStage}].Step[${tstep}].TypeID}
			if !${Return}
			{
				stepCount:Inc
			}
		}
		while ( ${tstep:Inc} <= ${Refining.Stage[${iStage}].StepCount} )
	}
	while ( ${iStage:Inc} <= 4 )

	return ${stepCount}
}

/* Give a Word description a number rating from 0 to 16 */
function:int rateDescription(string aDesc)
{
	if ( ${aDesc.Find[Very High]} )
	{
		;return 16
		return VHIGH
	}
	elseif ( ${aDesc.Find[High]} )
	{
		;return 8
		return HIGH
	}
	elseif ( ${aDesc.Find[Moderate]} )
	{
		;return 4
		return MOD
	}
	elseif ( ${aDesc.Find[Very Low]} )
	{
		;return 1
		return VLOW
	}
	elseif ( ${aDesc.Find[Low]} )
	{
		;return 2
		return LOW
	}

	return 0
}

function:int rateProgressStep(int iStep)
{
	variable int tstep
	variable int substep
	variable int iProg

	tstep:Set[${iStep}]

	substep:Set[1]
	do
	{
		variable string newName
		newName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]

		if (${actionStore.FindSet[${newName}].FindSetting[Progress]} > ${iProg})
		{
			iProg:Set[${actionStore.FindSet[${newName}].FindSetting[Progress]}]
		}
	}
	while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} )

	return ${iProg}
}

function:int rateQualityStep(int iStep)
{
	variable int tstep
	variable int substep
	variable int iQual

	tstep:Set[${iStep}]

	substep:Set[1]
	do
	{
		variable string newName
		newName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]

		if (${actionStore.FindSet[${newName}].FindSetting[Quality].Int} > ${iQual})
		{
			iQual:Set[${actionStore.FindSet[${newName}].FindSetting[Quality]}]
		}
	}
	while ( ${substep:Inc} <= ${Refining.Stage.Step[${tstep}].AvailActionsCount} )

	return ${iQual}
}

/* Will rate the Skill Used for this step */
/* Returns:
		Progress
		Quality
		ProgressOnly
*/
function:string rateSkillStep(int iStep)
{
	variable int tstep
	variable int substep
	variable string newName
	variable string aType

	tstep:Set[${iStep}]

	substep:Set[1]

	newName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]

	aType:Set[${actionStore.FindSet[${newName}].FindSetting[Skill,NONE]}]

	if (${aType.Find[NONE]})
	{
		; Was never set correctly
		return "NONE"
	}
	elseif (${aType.Find[Utilities]})
	{
		; This step uses the Utilities skill
		if ${preferUtility}
			return "Quality"
		else
			return "Progress"
	}
	elseif (${aType.Find[Tools]})
	{
		; This step uses the Tools skill
		if ${preferUtility}
			return "Progress"
		else
			return "Quality"
	}
	else
	{
		; This step uses the Station skill
		return "ProgressOnly"
	}

	return "${aType}"
}

function:bool isToolStep(int iStep)
{
	variable int tstep
	variable int substep
	variable string newName
	variable bool needTool

	tstep:Set[${iStep}]
	substep:Set[1]

	newName:Set[${Refining.Stage.Step[${tstep}].AvailAction[${substep}].Name}]
	needTool:Set[${actionStore.FindSet[${newName}].FindSetting[ToolRequired,FALSE]}]

	return ${needTool}
}

/* -==================================--=================================- */
/* -==================================--=================================- */
/* -==================================--=================================- */


/* Change to the toolbelt with the requestd Tool in it */
/* Returns false if it can't find the tool */
function:bool ChangeToolBelts(string aTool)
{
	; Change to correct ToolBelt
	;Me.Inventory[${Me.Inventory[${aTool}].InContainer.Index}]:UseAsCraftingToolbelt

	variable int itemIndex = 0

	call DebugOut "VGCraft:: Looking for tool: ${aTool}"

	if ( (${aTool.Length} == 0) || ${aTool.Equal[NULL]} )
	{
		call DebugOut "VGCraft:: ChangeTool called with zero or null value: ${aTool}"
		return FALSE
	}

	while ( ${Me.Inventory[${itemIndex:Inc}].Name(exists)} )
	{
		if ( ${Me.Inventory[${itemIndex}].Name.Find[${aTool}]} && ${Me.Inventory[${itemIndex}].Type.Equal[Crafting Tool]} && ${Me.Inventory[${itemIndex}].InContainer.Name.Find[Toolbelt]} )
		{
			call DebugOut "VGCraft:: Switching to tool belt: ${Me.Inventory[${itemIndex}].InContainer.Name}"
			Me.Inventory[${Me.Inventory[${itemIndex}].InContainer.Index}]:UseAsCraftingToolbelt
			return TRUE
		}
	}

/*
	if ( ${Me.Inventory[${aTool}](exists)} && ${Me.Inventory[${aTool}].InContainer.Name.Find[Toolbelt]})
	{
		call DebugOut "VGCraft:: Switching to tool belt: ${Me.Inventory[${aTool}].InContainer.Name}"
		Refining:ChangeToolbelt[${Me.Inventory[${aTool}].InContainer.ID}]
		return TRUE
	}
*/

	return FALSE
}

/* =============================================================================== */
/* **************************** Complication and Fixes Code ******************************** */
/* =============================================================================== */

/* See if we need to look for some Correction Actions */
function:bool CheckComplication()
{
	variable int apLeft

	call MyOutput "CheckComplications() called"
	call MyOutput "Complictions Found: ${Refining.ComplicationsCount}"
	call MyOutput "Corrections Found: ${Refining.CorrectionsCount}"

	; Output some Complication stats
	;call ComplicationStats

	apLeft:Set[${Refining.OrigActionPointsAvail} - ${Refining.ActionPointsUsed}]

	; If we have less than 250 AP's left, don't do Corrections! (unless we are already doing a Fix)
	if ( ${apLeft} < 250 ) && !${inCorrection}
	{
		cState:Set[CS_ACTION]
		return FALSE
	}

	; If we have less than 180 AP's left, don't do Corrections!
	if ( ${apLeft} < 180 )
	{
		cState:Set[CS_ACTION]
		return FALSE
	}

	;if ( (${Refining.CurrentRecipe.StepCount} < 6) && (${apLeft} < 300) )
	;{
	;	cState:Set[CS_ACTION]
	;	return FALSE
	;}
	;if ( (${Refining.CurrentRecipe.StepCount} > 6) && (${apLeft} < 400) )
	;{
	;	cState:Set[CS_ACTION]
	;	return FALSE
	;}
	;if ( (${Refining.CurrentRecipe.ProgressBarPct} > 50) && (${apLeft} < 300) )
	;{
	;	cState:Set[CS_ACTION]
	;	return FALSE
	;}


	variable int tstep

	tstep:Set[${Refining.ComplicationsCount}]

	if ( ${IgnoredComplications[${Refining.Complication[${tstep}].Name}](exists)} )
	{
		; Already decided not to use this Correction
		cState:Set[CS_ACTION]
		return FALSE
	}


	; If we only have 1 complication, see if we should just leave it.
	; If we have 2 or more, always try to clear one
	if ( ${Refining.ComplicationsCount} == 1 )
	{
		;Penalty: Moderate
		;Penalty: Low
		;Penalty: Very Low

		if ( ${Refining.Complication[${tstep}].Description.Find[Penalty: High]} )
		{
			; Do nothing, we will try to clear it down below
		}
		elseif ( ${Refining.Complication[${tstep}].Description.Find[Penalty: Moderate]} )
		{
			; Do nothing, we will try to clear it down below
		}
		elseif ( ${Refining.Complication[${tstep}].Description.Find[Bonus:]} )
		{
			; It's a GOOD complication, leave it
			call DebugOut "Complication Bonus: ${Refining.Complication[${tstep}].Name}"

			cState:Set[CS_ACTION]
			return FALSE
		}
		elseif ( ${Refining.Complication[${tstep}].Description.Find[Quality Penalty:]} )
		{
			;Quality Penalty:
			; Always try to Fix these!
		}
		elseif ( ${Refining.Complication[${tstep}].Description.Find[Penalty: Very Low]} )
		{
			call DebugOut "Skipping Penalty Very Low: ${Refining.Complication[${tstep}].Name}"

			cState:Set[CS_ACTION]
			return FALSE
		}
	}


	if ( ${Refining.CorrectionsCount} > 0 )
	{
		cState:Set[CS_COMPLICATE_FIND]
		return TRUE
	}
	else
	{
		; No more Complications, back to action!
		cState:Set[CS_ACTION]
		return FALSE
	}
}

/* Find and Execute a Correction */
function:bool FindCorrection()
{
	variable int tstep
	variable int substep
	variable int useStep
	variable int useSubStep
	variable int highProg
	variable int highCost
	variable int lowCost
	variable int actionTypeBonus
	variable int actionProgressBonus

	useStep:Set[0]
	useSubStep:Set[0]
	highProg:Set[0]
	highCost:Set[0]
	lowCost:Set[999]
	actionTypeBonus:Set[0]
	actionProgressBonus:Set[0]

	;call DebugOut "VGCraft:: Find Corrections" 
	call DebugOut "Corrections Found: ${Refining.CorrectionsCount}"

	; Start with the highest (latest one to appear) Correction
	tstep:Set[${Refining.CorrectionsCount}]

	do
	{
		substep:Set[1]
		do
		{
			;Complication Reduction: Very High
			;Complication Reduction: High
			;Complication Reduction: Moderate
			;Complication Reduction: Low

			variable string anItem

			call DebugOut "Fixes Found: ${Refining.Correction[${tstep}].AvailActionsCount}"
			;call DebugOut "${Refining.Correction[${tstep}].AvailAction[${substep}].Description}"

			if ( ${IgnoredFixes[${Refining.Correction[${tstep}].AvailAction[${substep}].Name}](exists)} )
			{
				; Already decided not to use this Correction
				continue
			}

			; Utility Required: Cleaner (2)
			if ( ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Utility Required:]} )
			{
				if ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Token[5,"\n"].Find[Utility]}
					anItem:Set[${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Token[5,"\n"].Token[3," "]}]
				else
					anItem:Set[${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Token[6,"\n"].Token[3," "]}]

				; If the item is on the Table, then go ahead
				call IsItemOnTable "${anItem}"
				if ${Return}
				{
					; Proceed
					call DebugOut "Correction requires (HAVE): ${anItem}"
				}
				else
				{
					; Do not pass go
					call DebugOut "Correction requires (DO NOT HAVE): ${anItem}"
					continue
				}
			}

			; TODO: check to see if the required tool is in the current Toolbelt
			; Otherwise this 35 AP cost correction just turned into a 50 AP cost correction
			if ( ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Tool Type Required:]} )
			{
				; Tool Type Required: Saw
				; Tool Type Required: Repair Tool
				anItem:Set[${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Token[5,"\n"].Token[2,":"]}]
				call DebugOut "Correction requires tool: ${anItem}"
			}

			if ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Tools]}
			{
				actionTypeBonus:Set[2]
			}
			elseif ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Utilities]}
			{
				actionTypeBonus:Set[1]
			}
			else
			{
				actionTypeBonus:Set[0]
			}

			if ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Reduction: Complete]}
			{
				call DebugOut "VGCraft:: -- COMPLICATION COMPLETE REDUCTION --"
				actionTypeBonus:Set[8]
				actionProgressBonus:Set[8]
			}
			elseif ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Complication Reduction: Very High]}
			{
				actionProgressBonus:Set[9]
			}
			elseif ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Complication Reduction: High]}
			{
				actionProgressBonus:Set[6]
			}
			elseif ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Complication Reduction: Moderate]}
			{
				actionProgressBonus:Set[3]
			}
			else
			{
				actionProgressBonus:Set[1]
			}

			if ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Quality Bonus: Moderate]}
			{
				actionProgressBonus:Inc[${Math.Calc[${actionProgressBonus} + 6]}]
			}
			elseif ${Refining.Correction[${tstep}].AvailAction[${substep}].Description.Find[Quality Bonus:]}
			{
				actionProgressBonus:Inc[${Math.Calc[${actionProgressBonus} + 3]}]
			}

			if ( ${highProg} < ${Math.Calc[${actionProgressBonus} + ${actionTypeBonus}]} )
			{
				highProg:Set[${Math.Calc[${actionProgressBonus} + ${actionTypeBonus}]}]
				highCost:Set[${Refining.Correction[${tstep}].AvailAction[${substep}].ActionPointCost}]
				useStep:Set[${tstep}]
				useSubStep:Set[${substep}]
			}

/*
			if ( ${highCost} < ${Refining.Correction[${tstep}].AvailAction[${substep}].ActionPointCost} )
			{
				highProg:Set[${Math.Calc[${actionProgressBonus} + ${actionTypeBonus}]}]
				highCost:Set[${Refining.Correction[${tstep}].AvailAction[${substep}].ActionPointCost}]
				useStep:Set[${tstep}]
				useSubStep:Set[${substep}]
			}
*/
		}
		while ( ${substep:Inc} <= ${Refining.Correction[${tstep}].AvailActionsCount} ) 
	}
	while ( ${tstep:Dec} >= 1 )

	if ( (${useStep} > 0) && (${useSubStep} > 0) )
	{
		call DebugOut "VG:Correction: ${Refining.Correction[${useStep}].AvailAction[${useSubStep}].Name}"

		;call StatsOut "Correction: ${Refining.Correction[${useStep}].AvailAction[${useSubStep}].Name}"
		;call StatsOut "Correction: ${Refining.Correction[${useStep}].AvailAction[${useSubStep}].Description}"
		;call StatsOut "ActionPointsUsed: ${Refining.ActionPointsUsed}"

		cState:Set[CS_COMPLICATE_WAIT]
		inCorrection:Set[TRUE]

		lastCorrection:Set[${Refining.Correction[${useStep}].AvailAction[${useSubStep}].Name}]

		UIElement[Action@CHUD]:SetText["(Fix) ${lastCorrection}"]

		Refining.Correction[${useStep}].AvailAction[${useSubStep}]:Use

		return TRUE
	}
	else
	{
		call DebugOut "VG:No usable Correction action found" 
		call DebugOut "VGCraft:: Ignoring Complication!"
		call IgnoreComplication
		doFixRetry:Set[FALSE]
		cState:Set[CS_ACTION]
		inCorrection:Set[FALSE]
		return FALSE
	}


	return FALSE
}


/* We don't have the items/tools needed, so ignore it */
function IgnoreComplication()
{
	variable int tstep

	tstep:Set[${Refining.ComplicationsCount}]

	if ( !${IgnoredComplications[${Refining.Complication[${tstep}].Name}](exists)} )
	{
		IgnoredComplications:Set[${Refining.Complication[${tstep}].Name}, 1]
	}
}


/* We don't have the items/tools needed, so ignore it */
function IgnoreFix(string aFixName)
{
	if ( !${IgnoredFixes[${aFixName}](exists)} )
	{
		IgnoredFixes:Set[${aFixName}, 1]
	}
}

