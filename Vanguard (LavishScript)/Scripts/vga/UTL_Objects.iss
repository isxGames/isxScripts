objectdef ClassRole
{
	member:bool healer()
		{
		if (${MyClass.Equal[Blood Mage]} || ${MyClass.Equal[Cleric]} || ${MyClass.Equal[Disciple]} || ${MyClass.Equal[Shaman]} || ${MyClass.Equal[Paladin]}|| ${MyClass.Equal[Druid]})
		return TRUE
		}
	member:bool tank()
		{
		If (${MyClass.Equal[Warrior]} || ${MyClass.Equal[Paladin]} || ${MyClass.Equal[Dread Knight]})
		return TRUE
		}
	member:bool melee()
		{
		If (${MyClass.Equal[Ranger]} || ${MyClass.Equal[Rogue]} || ${MyClass.Equal[Monk]} || ${MyClass.Equal[Bard]})
		return TRUE
		}
	member:bool caster()
		{
		If (${MyClass.Equal[Sorcerer]} || ${MyClass.Equal[Necromancer]} || ${MyClass.Equal[Psionicist]} || ${MyClass.Equal[Druid]})
		return TRUE
		}
	member:bool crowdcontroler()
		{
		If (${MyClass.Equal[Sorcerer]} || ${MyClass.Equal[Necromancer]} || ${MyClass.Equal[Psionicist]} || ${MyClass.Equal[Bard]})
		return TRUE
		}
	member:bool feigndeather()
		{
		If (${MyClass.Equal[Monk]} || ${MyClass.Equal[Necromancer]} || ${MyClass.Equal[Disciple]})
		return TRUE
		}
	member:bool resurrecter()
		{
		if (${MyClass.Equal[Blood Mage]} || ${MyClass.Equal[Cleric]} || ${MyClass.Equal[Disciple]} || ${MyClass.Equal[Shaman]} || ${MyClass.Equal[Paladin]})
		return TRUE
		}
	member:bool disspeller()
		{
		if (${MyClass.Equal[Sorcerer]} || ${MyClass.Equal[Bard]})
		return TRUE
		}
	member:bool stancepusher()
		{
		if (${MyClass.Equal[Monk]} || ${MyClass.Equal[Disciple]} || ${MyClass.Equal[Ranger]})
		return TRUE
		}
	member:bool JinUser()
		{
		if (${MyClass.Equal[Monk]} || ${MyClass.Equal[Disciple]})
		return TRUE
		}
}

variable ClassRole ClassRole

function MeClassCrashWorkAround()
{	
	if ${Me.Class.Equal[Warrior]}
		{
		MyClass:Set["Warrior"]
		UIElement[warriorfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Paladin]}
		{
		MyClass:Set["Paladin"]
		UIElement[paladinfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Dread Knight]}
		{
		MyClass:Set["Dread Knight"]
		UIElement[dreadknightfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Blood Mage]}
		{
		MyClass:Set["Blood Mage"]
		UIElement[bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Cleric]}
		{
		MyClass:Set["Cleric"]
		UIElement[clericfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Disciple]}
		{
		MyClass:Set["Disciple"]
		UIElement[disciplefrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Shaman]}
		{
		MyClass:Set["Shaman"]
		UIElement[shamanfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Ranger]}
		{
		MyClass:Set["Ranger"]
		UIElement[rangerfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Rogue]}
		{
		MyClass:Set["Rogue"]
		UIElement[roguefrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Monk]}
		{
		MyClass:Set["Monk"]
		UIElement[monkfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Bard]}
		{
		MyClass:Set["Bard"]
		UIElement[bardfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Sorcerer]}
		{
		MyClass:Set["Sorcerer"]
		UIElement[sorcererfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Necromancer]}
		{
		MyClass:Set["Necromancer"]
		UIElement[necromancerfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Psionicist]}
		{
		MyClass:Set["Psionicist"]
		UIElement[psionicistfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}
	if ${Me.Class.Equal[Druid]}
		{
		MyClass:Set["Druid"]
		UIElement[druidfrm@ClassFrm@Class@ABot@vga_gui]:Show
		}

}


objectdef GroupStatus
{
	member:bool Alive()
	{
		variable int icnt = 1
		do
		{
		If ${Group[${icnt}].ToPawn.IsDead} 
			return FALSE
		} 
		while ${icnt:Inc} <= ${Group.Count}
		return TRUE
	}
	member:bool AOEBuffClose()
	{
		variable int icnt = 1
		do
		{
		If ${Group[${icnt}].ToPawn.Distance} > 19
			return FALSE
		} 
		while ${icnt:Inc} <= ${Group.Count}
		return TRUE
	}

}

variable GroupStatus GroupStatus

objectdef AttackPosition
{
	; Returns angle 0-180 degrees:
	; 0 == Behind
	; 180 == In front
	; 90 == Directly beside (either side)
	member:float Angle(int64 ActorID)
	{
		variable float Retval
		variable float Heading=${Pawn[ID,${ActorID}].Heading}
		variable float HeadingTo=${Pawn[ID,${ActorID}].HeadingTo}
		Retval:Set[${Math.Calc[${Math.Cos[${Heading}]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}]} * ${Math.Sin[${HeadingTo}]}]}]
		Retval:Set[${Math.Acos[${Retval}]}]
		return ${Retval}
	}
	member:float TargetAngle()
	{
		variable float Retval
		variable float Heading=${Pawn[${Me.Target}].Heading}
		variable float HeadingTo=${Pawn[${Me.Target}].HeadingTo}
		Retval:Set[${Math.Calc[${Math.Cos[${Heading}]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}]} * ${Math.Sin[${HeadingTo}]}]}]
		Retval:Set[${Math.Acos[${Retval}]}]
		return ${Retval}
	}
	; Returns which side of the Actor I am on, Left or Right.
	member:string TargetSide(int64 ActorID)
	{
		variable float Side
		variable float Heading=${Pawn[${Me.Target}].Heading}
		variable float HeadingTo=${Pawn[${Me.Target}].HeadingTo}
		Side:Set[${Math.Calc[${Math.Cos[${Heading}+90]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}+90]} * ${Math.Sin[${HeadingTo}]}]}]
		if ${Side}>0
			return Left
		else
			return Right
	}
	; Returns which side of the Actor I am on, Left or Right.
	member:string Side(int64 ActorID)
	{
		variable float Side
		variable float Heading=${Pawn[ID,${ActorID}].Heading}
		variable float HeadingTo=${Pawn[ID,${ActorID}].HeadingTo}
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
	member:point3f PointAtAngle(int64 ActorID, float Angle, float Distance = 3)
	{
		variable float Heading=${Pawn[${ActorID}].Heading}
		Returning.Y:Set[${Pawn[${ActorID}].Y}]

		if ${This.Side[${ActorID}].Equal[Right]}
		{
			Angle:Set[-(${Angle})]
		}
		Returning.X:Set[-${Distance} * ${Math.Sin[-(${Heading}+(${Angle}))]} + ${Pawn[${ActorID}].X}]
		Returning.Z:Set[${Distance} * ${Math.Cos[-(${Heading}+(${Angle}))]} + ${Pawn[${ActorID}].Z}]
		return
	}
	
	; and this member will return a point in 3d space at any angle of attack from the
	; Actor passed to it, predicting that Actor's position based on their current speed
	; and direction, and the time argument passed to this function.
	member:point3f PredictPointAtAngle(int64 ActorID, float Angle, float Seconds=1, float Distance=3)
	{
		variable point3f Velocity

		Velocity:Set[${Pawn[${ActorID}].Velocity}]

		Returning:Set[${This.PointAtAngle[${ActorID},${Angle},${Distance}]}]

		Returning.X:Inc[${Velocity.X}*${Seconds}]
		Returning.Y:Inc[${Velocity.Y}*${Seconds}]
		Returning.Z:Inc[${Velocity.Z}*${Seconds}]
		return
	}

}

variable AttackPosition AttackPosition


objectdef MobResists
{
	member:bool Fire()
	{
		variable iterator Iterator
		Fire:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]} 
				return TRUE
		Iterator:Next
		}
	return FALSE
	}

	member:bool Ice()
	{
		variable iterator Iterator
		Ice:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]} 
				return TRUE
		Iterator:Next
		}
	return FALSE
	}
	member:bool Spiritual()
	{
		variable iterator Iterator
		Spiritual:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]} 
				return TRUE
		Iterator:Next
		}
	return FALSE
	}

	member:bool Physical()
	{
		variable iterator Iterator
		Physical:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]} 
				return TRUE
		Iterator:Next
		}
	return FALSE
	}

	member:bool Arcane()
	{
		variable iterator Iterator
		Arcane:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]} 
				return TRUE
		Iterator:Next
		}
	return FALSE
	}
	
}

variable MobResists MobResists

