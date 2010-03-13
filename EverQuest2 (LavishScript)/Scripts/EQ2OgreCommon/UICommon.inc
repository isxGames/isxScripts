;variable string Ver=1.007
;*****Login procedure specifics**


variable string LogMeOn[200]=0
variable string MobName[200]=0
variable int Counter
variable string CharInfo[200,4]
variable string CharInfoShortList[200,4]
variable string LogOnPerson

function FPreInit(string LoginModifer, string CharToLogin)
{
	if !${ISXEQ2(exists)}
	{
		ext isxeq2
	}

	wait 100 ${Display.FPS}>1

	if !${ISXEQ2.IsReady}
	{
		wait 200 ${ISXEQ2.IsReady}
		wait 40
		if !${ISXEQ2.IsReady}
		{
			echo For some reason ISXEQ2 is still not ready - ending script
			Script:End
		}
	}

	variable int Clicks=0
	if ${Zone.Name.Equal[LoginScene]} 
	{
		while ${Clicks:Inc}<10
		{
			MouseClick -hold right
			wait 2.5
			MouseClick -release right 	
			wait 2.5
 		 }

	}

	ISXEQ2:EnableAfflictionEvents
	declare BuffJestersCapTimers collection:int script
	declare BuffGravitasTimers collection:int script
	call RegisterEvents
	if !${ISXEQ2.IsReady}
	{
		echo ISXEQ2 not found or corrupt. Load/reinstall isxeq2.
		Script:End
	}

	echo ********Ogre Combat Assistant: Version: ${BotVer}**********
	;If no Modifer is typed in, then we have to copy the login name to char name. Example: run Ogre Fred
	if ${CharToLogin.Length}<=0 && ${LoginModifer.NotEqual[resume]} && ${LoginModifer.NotEqual[true]} && ${LoginModifer.NotEqual[false]} && ${LoginModifer.NotEqual[pause]} && ${LoginModifer.NotEqual[paused]} && ${LoginModifer.NotEqual[debug]}
		CharToLogin:Set[${LoginModifer}]

	;echo LoginModifer - ${LoginModifer}, CharToLogin: ${CharToLogin}
	if ${CharToLogin.NotEqual[NULL]} && ${CharToLogin.Length}>0
	{
		call LoginMain ${CharToLogin}
		if ${Return.Equal[FAILURE]}
		{
			echo Failed to log onto character ${CharToLogin} - ending script.
			Script:End
		}
	}

	;Below was used to start the bot resumed only if specified by the user... 
	;Changing it so the user now has to specify paused
	;if ${LoginModifer.Equal[TRUE]} || ${LoginModifer.Equal[resume]}
	;{
	;	ResumeBotOnStartup:Set[TRUE]
	;}
	if ${LoginModifer.Equal[pause]} || ${LoginModifer.Equal[paused]}
	{
		ResumeBotOnStartup:Set[FALSE]
	}
	elseif ${LoginModifer.Equal[login]}
	{
		echo Logging on ${CharToLogin} only - no bot.
		Script:End
	}
	else
		ResumeBotOnStartup:Set[TRUE]
		Testing:Set[FALSE]
		call LoadTInfo
}

function LoginMain(string Temp, bool AuthCheck)
{
	call SetUpChars
	LogOnPerson:Set[${Temp}]
	call LoginISSSetUpShortListCharNames

	if ${AuthCheck}
	{
		;Means we only want to check if they exist.
		if ${CharInfoShortList[1,1].Equal[${Temp}]}
		{
			return TRUE
		}
		else
			return FALSE
	}

	if ${Me.Name.Equal[${Temp}]}
	{
		echo Already logged on ${Temp}
		return SUCCESS
	}

	if ${CharInfoShortList[1,1].Equal[NULL]} || ${CharInfoShortList[1,1].Length}<=0
	{
		echo ${LogOnPerson} not found. Add them to EQ2Chars.inc or retype the name.
		return FAILURE
	}
	else
	{
		call LoginISSLogin
		wait 1000 ${Me.Name.Equal[${CharInfoShortList[1,1]}]}
		if ${Me.Name.Equal[${CharInfoShortList[1,1]}]}
		{
			return SUCCESS
		}
		else
			return FAILURE
	}
}

function LoginISSSetUpShortListCharNames()
{
	variable int TempCounter=1
	Counter:Set[1]
	if ${LogOnPerson.Equal[0]}
	{
		echo No one..?
	}
	else
	{
		do
		{
			if ${LogOnPerson.Equal[${CharInfo[${TempCounter},1]}]}
			{
				CharInfoShortList[1,1]:Set[${CharInfo[${TempCounter},1]}]
				CharInfoShortList[1,2]:Set[${CharInfo[${TempCounter},2]}]
				CharInfoShortList[1,3]:Set[${CharInfo[${TempCounter},3]}]
				CharInfoShortList[1,4]:Set[${CharInfo[${TempCounter},4]}]
				TempCounter:Set[1]
				break
			}
		}
		while ${TempCounter:Inc}<=200
	}
}

function LoginISSLogin()
{
	variable string TempString
	if ${Zone.Name.Equal[LoginScene]}
	{
		;** Removing this for people with profit - Once things get working **
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.AutoPlayChar]:AddToTextBox[${CharInfoShortList[1,1]}]
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.Password]:AddToTextBox[${CharInfoShortList[1,2]}]
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.Username]:AddToTextBox[${CharInfoShortList[1,3]}]
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.AutoPlayWorld]:AddToTextBox[${CharInfoShortList[1,4]}]
		
		wait 20
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Button,LSUsernamePassword.WindowPage.ConnectButton]:LeftClick
		;call AddTextToBoxes
	}
	else
	{
		echo Not at Login Scene - /camping out and logging into the correct character.
		EQ2Execute /camp
		wait 200
		wait 100 ${Zone.Name.Equal[LoginScene]}
		
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.AutoPlayChar]:AddToTextBox[${CharInfoShortList[1,1]}]
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.Password]:AddToTextBox[${CharInfoShortList[1,2]}]
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.Username]:AddToTextBox[${CharInfoShortList[1,3]}]
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.AutoPlayWorld]:AddToTextBox[${CharInfoShortList[1,4]}]
		wait 30
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Button,LSUsernamePassword.WindowPage.ConnectButton]:LeftClick		
	}
}
function AddTextToBoxes()
{
	;Doesn't work while _at_ the loginscene.. which makes this useless.
	echo EQ2Execute /cl_autoplay_char ${CharInfoShortList[1,1]}
	EQ2Execute /cl_autoplay_char ${CharInfoShortList[1,1]}
	EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,WindowPage.Password]:AddToTextBox[${CharInfoShortList[1,2]}]
	EQ2Execute /cl_username ${CharInfoShortList[1,3]}
	EQ2Execute /cl_autoplay_world ${CharInfoShortList[1,4]}
	wait 1000
	EQ2UIPage[LoginScene,LSUsernamePassword].Child[Button,LSUsernamePassword.WindowPage.ConnectButton]:LeftClick
}
objectdef NPCTargetObject
{
	member:int ID()
	{
		;Check to see if the mob is an NPC or NamedNPC
		if ${Target.Type.Equal[NPC]} || ${Target.Type.Equal[NamedNPC]}
		{
			;NPCTargetID:Set[${Target.ID}]
			return ${Target.ID}
		}
		elseif ${Target.Target.Type.Equal[NPC]} || ${Target.Target.Type.Equal[NamedNPC]}
		{
			;NPCTargetID:Set[${Target.Target.ID}]
			return ${Target.Target.ID}
		}
		else
		{
			;NPCTargetID:Set[NULL]
			return 999999998
		}
	}
}
objectdef PCTargetObject
{
	member:int ID()
	{
		if ${Target.Type.Equal[PC]}
			return ${Target.ID}
		elseif ${Target.Target.Type.Equal[PC]}
			return ${Target.Target.ID}
		else
			return NULL
	}
}
objectdef EQ2Position
{
	;**********
	;objectdef of EQ2Position was used from "PositionUtils.iss" which was create by Valerian.
	;Modified so it will read spell TargetTypes such as PBAE's and read EffectRadius instead of MaxRange
	;**********
	; Returns angle 0-180 degrees:
	; 0 == Behind
	; 180 == In front
	; 90 == Directly beside (either side)
	member:float Angle(uint ActorID)
	{
		variable float Retval
		variable float Heading=${Actor[id,${ActorID}].Heading}
		variable float HeadingTo=${Actor[id,${ActorID}].HeadingTo}
		Retval:Set[${Math.Calc[${Math.Cos[${Heading}]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}]} * ${Math.Sin[${HeadingTo}]}]}]
		Retval:Set[${Math.Acos[${Retval}]}]
		return ${Retval}
	}

	; Returns which side of the Actor I am on, Left or Right.
	member:string Side(uint ActorID)
	{
		variable float Side
		variable float Heading=${Actor[id,${ActorID}].Heading}
		variable float HeadingTo=${Actor[id,${ActorID}].HeadingTo}
		Side:Set[${Math.Calc[${Math.Cos[${Heading}+90]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}+90]} * ${Math.Sin[${HeadingTo}]}]}]
		if ${Side}>0
			return Left
		else
			return Right
	}

	; This member will return a point in 3d space at any angle of attack from the
	; Actor passed to it. The returned point will be on the same side as the player's
	; current position, or directly behind/in front of the Actor. Angle should be
	; 0 to 180 (or -0 to -180 if you wish to get a point on the opposite side.)
	member:point3f PointAtAngle(uint ActorID, float Angle, float Distance = 5)
	{
		variable float Heading=${Actor[id,${ActorID}].Heading}
		Returning.Y:Set[${Math.Calc[${Actor[id,${ActorID}].Y}+2]}]

		if ${This.Side[${ActorID}].Equal[Right]}
		{
			Angle:Set[-(${Angle})]
		}
		;Distance:Set[${Math.Calc[(${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale})*.8]}]
		Distance:Set[${Math.Calc[(${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale})]}]

		Returning.X:Set[-${Distance} * ${Math.Sin[-(${Heading}+(${Angle}))]} + ${Actor[id,${ActorID}].X}]
		Returning.Z:Set[${Distance} * ${Math.Cos[-(${Heading}+(${Angle}))]} + ${Actor[id,${ActorID}].Z}]
		return
	}
	
	; and this member will return a point in 3d space at any angle of attack from the
	; Actor passed to it, predicting that Actor's position based on their current speed
	; and direction, and the time argument passed to this function.
	member:point3f PredictPointAtAngle(uint ActorID, float Angle, float Seconds=1, float Distance=3)
	{
		variable point3f Velocity

		Velocity:Set[${Actor[id,${ActorID}].Velocity}]

		Returning:Set[${This.PointAtAngle[${ActorID},${Angle},${Distance}]}]

		Returning.X:Inc[${Velocity.X}*${Seconds}]
		Returning.Y:Inc[${Velocity.Y}*${Seconds}]
		Returning.Z:Inc[${Velocity.Z}*${Seconds}]
		return
	}

	member:float GetBaseMaxRange(uint ActorID)
	{
		return ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale}]}
	}

	member:float GetMeleeMaxRange(uint ActorID)
	{
		return ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + 2]}
	}
	member:float GetBaseMinRange(uint ActorID)
	{
		return ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale}]}
	}
	member:bool GetAbilityMaxRange(uint ActorID, string abilString)
	{
		AbilityID:Set[${SpellOb.ID[${abilString}]}]
		;PercentMod:Set[${Math.Calc[(100+${PercentMod})/100]}]
		;SpellRange:Set[${Math.Calc[${SpellRange}*${PercentMod}]}]
		variable float AbilityRange
		variable float AbilityMinRange
		;If the spell type is for a pet - do a different check.
		if ${SpellOb.TargetType[${AbilityID}]}==3
		{
			if ${Me.Pet(exists)} && !${EQ2.CheckCollision[${Me.X},${Math.Calc[${Me.Y}+2]},${Me.Z},${Me.Pet.X},${Math.Calc[${Me.Pet.Y}+2]},${Me.Pet.Z}]}
			{
				AbilityRange:Set[${SpellOb.MaxRange[${AbilityID}]}]
				ActorID:Set[${Me.Pet.ID}]
				;return TRUE
				;Removed the TRUE because it should check the range below - just needed to add in ActorID to be the pets
			}
			else
				return FALSE
		}

		if ${SpellOb.TargetType[${AbilityID}]}==0 && ${SpellOb.EffectRadius[${AbilityID}]}==0
		{
			;TargetType 0 is self, EffectRadius of 0 means it's NOT an AE
			return TRUE
		}
		elseif ${SpellOb.TargetType[${AbilityID}]}==0 && ${SpellOb.EffectRadius[${AbilityID}]}>0
		{
			;TargetType 0 is self, EffectRadius above 0 means it's IS an AE
			AbilityRange:Set[${SpellOb.EffectRadius[${AbilityID}]}]
		}
		elseif ${SpellOb.TargetType[${AbilityID}]}==2
		{
			;TargetType 2 is group - If the target is yourself, return true, if it's not you, use the EffectRadius
			if ${ActorID}==${Me.ID} || ${UIElement[${ChkBoxIgnoreBeneficialAERangeID}].Checked}
			{
				return TRUE
			}
			else
			{
				;Need real range
				AbilityRange:Set[${SpellOb.EffectRadius[${AbilityID}]}]
			}
		}
		else
		{
			;Need real range for AbilityRange only - not needed for Min range
			AbilityRange:Set[${SpellOb.MaxRange[${AbilityID}]}]
			AbilityMinRange:Set[${SpellOb.MinRange[${AbilityID}]}]
		}

		if ${SpellOb.SpellBookType[${AbilityID}]}==0 && ${SpellOb.EffectRadius[${AbilityID}]}==0
			AbilityRange:Inc[${Int[${UIElement[${TEBoxSetupSpellRangeExtenderID}].Text}]}]

		;echo Is the box checked?? ${UIElement[${ChkBoxIgnoreRangeOnCASID}].Checked}
		if ${UIElement[${ChkBoxIgnoreRangeOnCASID}].Checked} && ${SpellOb.TargetType[${AbilityID}]}!=2 && ${Actor[id,${ActorID}].Type.NotEqual[PC]}
		{
			;echo Dist < ColR*ColS +AbilRange: ${Actor[id,${ActorID}].Distance} < ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + ${AbilityRange}]} -- Each one: ${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + ${AbilityRange}]
			return TRUE
		}

		;if ${DebugCasting} && ${AbilityID}!=4078480875
		;	echo ${Time} 	${abilString} ( ${SpellOb.Name[${AbilityID}]} ) 	if ${Actor[id,${ActorID}].Distance} < ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + ${AbilityRange}]} && (${AbilityMinRange}==0 || ${Actor[id,${ActorID}].Distance} > ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + ${AbilityMinRange}]} )

		;Could make a small extender for range. Either use percentage like above, or a raw #
		if ${Actor[id,${ActorID}].Distance} < ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + ${AbilityRange}]} && (${AbilityMinRange}==0 || ${Actor[id,${ActorID}].Distance} > ${Math.Calc[${Actor[id,${ActorID}].CollisionRadius} * ${Actor[id,${ActorID}].CollisionScale} + ${AbilityMinRange}]} )
			return TRUE
		else
		{
			;echo False???
			return FALSE
		}
	}
}
variable time BotDate
variable int VCheck=5356800
;variable int VCheck=2678400