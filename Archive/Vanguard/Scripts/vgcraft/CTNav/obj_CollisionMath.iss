/*
	CollisionMath Class
	
	Handles testing for intersection and/or collision between two 3d objects
	
	Instantiated as Navigator.AutoMapper.Collision
	
	-- CyberTech (cybertech@gmail.com)
	
*/
objectdef obj_CollisionMath
{
	method Initialize()
	{
	}

	; Test whether a Sphere intersects with an  axis-aligned box
	member:bool TestIntersect_Sphere_Box(lnavregionref Sphere, lnavregionref Box)
	{
		if ${Region1.Type.NotEqual["Sphere"]} || ${Region2.Type.NotEqual["Box"]}
		{
			Navigator:Echo["CollisionMath:TestIntersect_Sphere_Box: Parameter Regions should be of type Sphere and Box"]
			DebugPrint("CollisionMath:TestIntersect_Sphere_Box: ${Sphere.Name} - ${Sphere.Type}")
			DebugPrint("CollisionMath:TestIntersect_Sphere_Box: ${Box.Name} - ${Box.Type}")
			return FALSE
		}
		variable float borderDistance = 0
		variable float totalDistance = 0


		if ${Sphere.CenterPoint.X} < ${Box.X1}
		{
			borderDistance:Set[${Box.X1} - ${Sphere.CenterPoint.X}]
			totalDistance:Set[${totalDistance} + (${borderDistance} * ${borderDistance})]
    	} 
    	elseif ${Sphere.CenterPoint.X} > ${Box.X2}
    	{	
			borderDistance:Set[${Box.X2} - ${Sphere.CenterPoint.X}]
			totalDistance:Set[${totalDistance} + (${borderDistance} * ${borderDistance})]
    	}

		if ${Sphere.CenterPoint.Y} < ${Box.Y1}
		{
			borderDistance:Set[${Box.Y1} - ${Sphere.CenterPoint.Y}]
			totalDistance:Set[${totalDistance} + (${borderDistance} * ${borderDistance})]
    	} 
    	elseif ${Sphere.CenterPoint.Y} > ${Box.Y2}
    	{
			borderDistance:Set[${Box.Y2} - ${Sphere.CenterPoint.Y}]
			totalDistance:Set[${totalDistance} + (${borderDistance} * ${borderDistance})]
    	}

		if ${Sphere.CenterPoint.Z} < ${Box.Z1}
		{
			borderDistance:Set[${Box.Z1} - ${Sphere.CenterPoint.Z}]
			totalDistance:Set[${totalDistance} + (${borderDistance} * ${borderDistance})]
    	} 
    	elseif ${Sphere.CenterPoint.Z} > ${Box.Z2}
    	{
			borderDistance:Set[${Box.Z2} - ${Sphere.CenterPoint.Z}]
			totalDistance:Set[${totalDistance} + (${borderDistance} * ${borderDistance})]
    	}
    	    	
    	; Otherwise the sphere's center is within the box on this axis, so the
		; distance will be 0 and we do not need to accumulate anything at all
		
		; If the distance to the box is lower than the sphere's radius, both are overlapping
		if (${totalDistance} <= (${Sphere.Radius} * ${Sphere.Radius}))
		{
			return TRUE
		}
		return FALSE
	}

	; Test whether two axis-aligned boxes intersect
	member:bool TestIntersect_Box_Box(lnavregionref Region1, lnavregionref Region2)
	{
		if ${Region1.Type.NotEqual["Box"]} || ${Region2.Type.NotEqual["Box"]}
		{
			Navigator:Echo["CollisionMath:TestIntersect_Box_Box: Both regions must be a box"]
			DebugPrint("CollisionMath:TestIntersect_Box_Box: ${Region1.Name} - ${Region1.Type}")
			DebugPrint("CollisionMath:TestIntersect_Box_Box: ${Region2.Name} - ${Region2.Type}")
			return FALSE
		}
		
    	if	( \
    			(${Region1.X1} < ${Region2.X2}) && (${Region1.X2} > ${Region2.X1}) && \
    			(${Region1.Y1} < ${Region2.Y2}) && (${Region1.Y2} > ${Region2.Y1}) &&  \
    			(${Region1.Z1} < ${Region2.Z2}) && (${Region1.Z2} > ${Region2.Z1}) \
    		)
    	{
    		return TRUE
    	}
    	return FALSE
	}

	; Test whether two spheres intersect
	member:bool TestIntersect_Sphere_Sphere(lnavregionref Region1, lnavregionref Region2)
	{
		if ${Region1.Type.NotEqual["Sphere"]} || ${Region2.Type.NotEqual["Sphere"]}
		{
			Navigator:Echo["CollisionMath:TestIntersect_Sphere_Sphere: Both regions must be a Sphere"]
			DebugPrint("CollisionMath:TestIntersect_Sphere_Sphere: ${Region1.Name} - ${Region1.Type}")
			DebugPrint("CollisionMath:TestIntersect_Sphere_Sphere: ${Region2.Name} - ${Region2.Type}")
			return FALSE
		}

		declarevariable distance float local ${Math.Calc[${Math.Distance[${Region1.CenterPoint}, ${Region2.CenterPoint}]} * 2]}
		declarevariable radii float local ${Math.Calc[${Region1.Radius} + ${Region2.Radius}]}

  		; The spheres overlap if their combined radius is larger than the distance of their centers
		if (${distance} < (${radii} * ${radii}))
		{
			return TRUE
		}
		return FALSE
	}
	
	member:bool RegionsIntersect(lnavregionref Region1, lnavregionref Region2)
	{
		if ${Region1.Type.Equal[${Region2.Type}]}
		{
			switch ${Region1.Type}
			{
				case Box
					return ${This.TestIntersect_Box_Box[${Region1}, ${Region2}]}
					break
				
				case Sphere
					return ${This.TestIntersect_Sphere_Sphere[${Region1}, ${Region2}]}
					break
					
				default
					DebugPrint("CollisionMath:RegionsIntersect - Unhandled Object Type (${Region1.Type})")
					return FALSE
					break
			}
		}
		
		variable lnavregionref BoxRegion
		variable lnavregionref OtherRegion
		if ${Region1.Type.Equal["Box"]}
		{
			BoxRegion:SetRegion[${Region1}]
			OtherRegion:SetRegion[${Region2}]
		}
		else
		{
			BoxRegion:SetRegion[${Region2}]
			OtherRegion:SetRegion[${Region1}]
		}

		; Need to test for all handled region types that are not Boxes,
		; here, since we know one region is a box.
		switch ${OtherRegion.Type}
		{		
			case Sphere
				return ${This.TestIntersect_Sphere_Box[${OtherRegion}, ${BoxRegion}]}
				break
				
			default
				DebugPrint("CollisionMath:RegionsIntersect - Unhandled ObjectType Combination (${BoxRegion.Type} && ${OtherRegion.Type})")
				return FALSE
				break
		}		
		DebugPrint("CollisionMath:RegionsInterect: Fail - ${Region1.Name} & ${Region2.Name}")
		return FALSE
	}
	
	member:bool CollisionTest(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		variable point3f From
		From:Set[${FromX},${FromY},${FromZ}]
		
		variable point3f To
		To:Set[${ToX},${ToY},${ToZ}]
		
		variable point3f TEST1
		TEST1:Set[${VG.CheckCollision[${To}, ${From}].Location}]

		variable point3f TEST2
		TEST2:Set[${VG.CheckCollision[${From}, ${To}].Location}]
		
		
		if	( ${${TEST1}(exists)} || ${${TEST2}(exists)} )			 	
		{
			DebugPrint("\${VG.CheckCollision[${To}, ${From}]} = ${TEST1.X}")
			DebugPrint("\${VG.CheckCollision[${To}, ${From}]} = ${TEST2.X}")
			return TRUE
		}
		return FALSE
	}	

	member:float MaxCollisionFreeRadius(float X, float Y, float Z, float MaxRadius=2500.0)
	{
		/* 
			50 meters is the # given by Amadeus as safe to assume that everything thats going
			to be visible, is visible, to the Actor list.
			
			Reduce the box size by x% each round until we find the maximum collision-free size
			
			We start with a larger reduction % in order to get thru the search faster,
			but we then reduce that by this % every iteration in order to maximize
			the size of the smallest regions well be forced to make
		*/

		variable point3f Location
		Location:Set[${X},${Y},${Z}]
				
		variable float IncreasePercent = 0.03
			
		variable string Name
		variable float Radius = 0.5
		variable float LastGoodRadius = 0.5
				
		; Find our maximum collision-free radius
		while ${Radius} < ${MaxRadius}
		{
			Name:Set[${Actor[from, ${Location}, xyrange, ${Radius}, IsCollidable].Name}]
			if ${Name(exists)} && ${Name.NotEqual[NULL]}
			{
				break
			}

			LastGoodRadius:Set[${Radius}]

			; Increase our search radius
			Radius:Set[${Math.Calc[${Radius} + (${Radius} * ${IncreasePercent})]}]
		}

		 DebugPrint("CollisionMath:MaxCollisionFreeRadius - DEBUG: Last Colliding Actor: ${Name} ${Actor[${Name}].Distance} ${Actor[${Name}].CollisionRadius} @${Radius}")

		if ${LastGoodRadius} > 0.7
		{
			; Reduce by 5% for a safety margin
			LastGoodRadius:Set[${Math.Calc[${LastGoodRadius} - (${LastGoodRadius} * 0.05)]}]
		}

		DebugPrint("CollisionMath:MaxCollisionFreeRadius - DEBUG: Resulting Radius: ${LastGoodRadius}")

		return ${LastGoodRadius}
	}
}
