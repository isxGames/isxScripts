/*
*===========================
* Anti-add by Kram
* Version 1.3 -- 3/1/2007
*
*===========================
* Basic Description:
* This script contains a series of useful functions for avoiding adds.
* See the features and version update notes for more info on each function as well as it's usage.
* -If an add is found, the function returns TRUE
* -If an add is NOT found, the function returns FALSE
*
*===========================
* Features:
* Check current target for possible adds before pulling
* Check target for nearby players to avoid kill stealing
* Avoid adds while fighting (not just while pulling)
* Check X, Y loc for adds
* Check path between you and target for adds
*
*===========================
* Setup:
* Download this file and save it into a "common" folder in your scripts folder
* Now add the following line to any script you wish to utilize these functions:
* #include "common\antiadd.iss"
*
*===========================
* Credits:
* Written by Kram
*
* With help from:
* Amadeus, Hendrix, Karye, and the IRC community
*
*===========================
* Version 1.1 -- 2/19/2007
* New Function added:
*	AvoidAdds, this function moves you away from incoming AggroNPC's if they come within your set range.
*	Usage:
*	call AvoidAdds 20
*	To take advantage of this feature, simply make the call in your fight function, or any
*	function that you want to actively move away from possible adds. The function will take
*	For an example of it's use see the Fight function of VGRanger v1.3 (or higher) at:
*	http://www.isxgames.com/forums/showthread.php?t=646
*
*===========================
* Version 1.2 -- 2/21/2007
* New Function added:
*	CheckForPlayers, this is the same function as CheckForAdds only it checks for nearby players
*	The point of this function is to check a mob for nearby players to avoid KS'ing.
*
*===========================
* Version 1.3 -- 3/1/2007
* New Function added:
*	CheckForAddsInPath, this function takes your target and checks for mobs between you and the target
*	It only considers mobs between you and the target in the shape of a cone
*	Usage of this one requires no parameter to be passed. Returns TRUE or FALSE
*
* New Function added:
*	CheckLocForAdds, this function takes x, y, range parameters. It checks for aggro mobs around the
*	radius of the x, y loc given.
*
*===========================
* Setting up:
* First download antiadd.iss (at the bottom of this post).
* Save the file into the common folder of your Scripts folder (if you dont have a common folder, make one)
* Now you must include the file in your script with the following line of code:
* #include common\antiadd.iss
* The include statement goes at the top of a script, before any functions.
* Once included you are ready to call the function.
*
*===========================
* Calling the Function:
* In the pull function of your script insert the following code after you've obtained your target:
*
* ;Checks for adds on current target, states that the agro radius oft the mobs is 15m
* call CheckForAdds 15
*
* if "${Return}"
*	{
*	echo True: We have an add, find a new target
*	}
*
* if "!${Return}"
*	{
*	echo False: No Adds, continue with pulling
*	}
*/

function CheckForAdds(int AgroDistance)
{
	declare PawnCounter int local 1
	AgroDistance:Set[${AgroDistance}*100]

	if !${Me.Target(exists)}
	{
		echo Anti-Add CheckForAdds: No Target
		return FALSE
	}

	do
	{
		if ${doNonAgroMobs}
		{
			if (${Pawn[${PawnCounter}].Type.Equal[NPC]} || ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]}) && ${Pawn[${PawnCounter}].ID}!=${Me.Target.ID}
			{
				if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance}
				{
					;echo Mob too close
					return TRUE
				}
			}
		}
		else
		{
			if ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]} && ${Pawn[${PawnCounter}].ID}!=${Me.Target.ID}
			{
				if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance}
				{
					;echo Mob too close
					return TRUE
				}
			}
		}
		PawnCounter:Set[${PawnCounter}+1]
	}
	while ${PawnCounter}<${VG.PawnCount}

	return FALSE
}

function CheckLocForAdds(float CheckLocX, float CheckLocY, int AgroDistance)
{
	declare PawnCounter int local 1
	AgroDistance:Set[${AgroDistance}*100]

	do
	{
		if ${doNonAgroMobs}
		{
			if (${Pawn[${PawnCounter}].Type.Equal[NPC]} || ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]}) && ${Pawn[${PawnCounter}].ID}!=${Me.Target.ID}
			{
				if ${Math.Distance[${CheckLocX},${CheckLocY},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance}
				{
					;echo Mob too close
					return TRUE
				}
			}
		}
		else
		{
			if ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]} && ${Pawn[${PawnCounter}].ID}!=${Me.Target.ID}
			{
				if ${Math.Distance[${CheckLocX},${CheckLocY},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance}
				{
					;echo Mob too close
					return TRUE
				}
			}
		}
		PawnCounter:Set[${PawnCounter}+1]
	}
	while ${PawnCounter}<${VG.PawnCount}

	return FALSE
}

function AvoidAdds(int AgroDistance)
{
	if !${Me.Encounter}==0
	{
		;No adds, no worries
		return
	}

	declare PawnCounter int local 1
	AgroDistance:Set[${AgroDistance}*100]

	do
	{
		if ${doNonAgroMobs}
		{
			if (${Pawn[${PawnCounter}].Type.Equal[NPC]} || ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]}) && ${Pawn[${PawnCounter}].ID}!=${Me.Target.ID} && ${PawnCounter}>(${Me.Encounter}+1)
			{
				if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance} && ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}>9
				{
					;echo ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]} // ${AgroDistance}
					Call DebugIt "Avoiding Add"
					face ${Pawn[${PawnCounter}].X} ${Pawn[${PawnCounter}].Y}
					VG:ExecBinding[movebackward]
					wait 5
					VG:ExecBinding[movebackward, release]
					return
				}
			}
			PawnCounter:Set[${PawnCounter}+1]
		}
		else
		{
			if ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]} && ${Pawn[${PawnCounter}].ID}!=${Me.Target.ID} && ${PawnCounter}>(${Me.Encounter}+1)
			{
				if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance} && ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}>9
				{
					;echo ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]} // ${AgroDistance}
					Call DebugIt "Avoiding Add"
					face ${Pawn[${PawnCounter}].X} ${Pawn[${PawnCounter}].Y}
					VG:ExecBinding[movebackward]
					wait 5
					VG:ExecBinding[movebackward, release]
					return
				}
			}
			PawnCounter:Set[${PawnCounter}+1]
		}
	}
	while ${PawnCounter}<${VG.PawnCount}

	return FALSE
}

function CheckForPlayers(int AgroDistance)
{
	declare PawnCounter int local 1
	AgroDistance:Set[${AgroDistance}*100]

	if !${Me.Target(exists)}
	{
		echo Anti-Add Check for Players: No Target
		return FALSE
	}

	do
	{
		if ${Pawn[${PawnCounter}].Type.Equal[PC]} && ${Pawn[${PawnCounter}].Type.Equal[GroupMember]}
		{
			if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${AgroDistance}
			{
				;echo PC too close
				return TRUE
			}
		}
		PawnCounter:Set[${PawnCounter}+1]
	}
	while ${PawnCounter}<${VG.PawnCount}

	return FALSE
}

function CheckForAddsInPath()
{
	declare PawnCounter int local 1
	declare LocDistance int local

	if !${Me.Target(exists)}
	{
		echo Anti-Add AddsInPath: No Target
		return FALSE
	}

	LocDistance:Set[${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}]

	do
	{
		if ${doNonAgroMobs}
		{
			if ${Pawn[${PawnCounter}].Type.Equal[NPC]} || ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]}
			{
				if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${LocDistance}
				{
					if ${Math.Distance[${Me.X},${Me.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${LocDistance}
					{
						if (${Me.Heading}-${Me.Target.HeadingTo})<(90-${Me.Target.Distance})

						;echo Mob too close
						return TRUE
					}
				}
			}
		}
		else
		{
			if ${Pawn[${PawnCounter}].Type.Equal[AggroNPC]}
			{
				if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${LocDistance}
				{
					if ${Math.Distance[${Me.X},${Me.Y},${Pawn[${PawnCounter}].X},${Pawn[${PawnCounter}].Y}]}<${LocDistance}
					{
						if (${Me.Heading}-${Me.Target.HeadingTo})<(90-${Me.Target.Distance})
						{
							;echo Mob too close
							return TRUE
						}
					}
				}
			}
		}
		PawnCounter:Set[${PawnCounter}+1]
	}
	while ${PawnCounter}<${VG.PawnCount}

	return FALSE
}