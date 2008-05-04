/*
	CollisionMath Class
	
	Handles testing for intersection and/or collision between two 3d objects
	
	Originally written CyberTech (cybertech@gmail.com) and modified for use with EQ2 by Amadeus
	
*/

objectdef EQ2NavCollisionMath
{
	method Initialize()
	{
	}
	
	
	method Output(string Text)
	{
	    echo "EQ2NavCollisionMath:: ${Text}"
	}
	
	method Debug(string Text)
	{
	    echo "EQ2NavCollisionMath-Debug:: ${Text}"
	}

	; Test whether a Sphere or Radius intersects with an  axis-aligned box
	member:bool TestIntersect_Sphere_Box(lnavregionref Sphere, lnavregionref Box)
	{
		if (${Region1.Type.NotEqual["Sphere"]} && ${Region1.Type.NotEqual["Radius"]}) || ${Region2.Type.NotEqual["Box"]}
		{
			This:Debug["CollisionMath:TestIntersect_Sphere_Box: ${Sphere.Name} - ${Sphere.Type}"]
			This:Debug["CollisionMath:TestIntersect_Sphere_Box: ${Box.Name} - ${Box.Type}"]
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
			This:Output[CollisionMath:TestIntersect_Box_Box: Both regions must be a box"]
			This:Debug["CollisionMath:TestIntersect_Box_Box: ${Region1.Name} - ${Region1.Type}"]
			This:Debug["CollisionMath:TestIntersect_Box_Box: ${Region2.Name} - ${Region2.Type}"]
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

		if (${Region1.Type.NotEqual["Sphere"]} && ${Region1.Type.NotEqual["Radius"]} )|| \
		   (${Region2.Type.NotEqual["Sphere"]} && ${Region2.Type.NotEqual["Radius"]} )
		{
			This:Output["CollisionMath:TestIntersect_Sphere_Sphere: Both regions must be a Sphere or Radius"]
			This:Debug["CollisionMath:TestIntersect_Sphere_Sphere: ${Region1.Name} - ${Region1.Type}"]
			This:Debug["CollisionMath:TestIntersect_Sphere_Sphere: ${Region2.Name} - ${Region2.Type}"]
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
				
				case Radius
				case Sphere
					return ${This.TestIntersect_Sphere_Sphere[${Region1}, ${Region2}]}
					break
					
				default
					This:Debug["CollisionMath:RegionsIntersect - Unhandled Object Type (${Region1.Type})"]
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
			case Radius
			case Sphere
				return ${This.TestIntersect_Sphere_Box[${OtherRegion}, ${BoxRegion}]}
				break
				
			default
				This:Debug["CollisionMath:RegionsIntersect - Unhandled ObjectType Combination (${BoxRegion.Type} && ${OtherRegion.Type})"]
				return FALSE
				break
		}		
		This:Debug["CollisionMath:RegionsInterect: Fail - ${Region1.Name} & ${Region2.Name}"]
		return FALSE
	}
	
	member:bool CollisionTest(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
	    return ${EQ2.CheckCollision[${FromX},${FromY},${FromZ},${ToX},${ToY},${ToZ}]}
	}	

	member:float MaxCollisionFreeRadius(float X, float Y, float Z, float MaxRadius=12)
	{
		;;; This function is NOT working in EQ2 ..things will need to be added to ISXEQ2 in order for it 
		;;; to work properly.

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

		 This:Debug["CollisionMath:MaxCollisionFreeRadius - DEBUG: Last Colliding Actor: ${Name} ${Actor[${Name}].Distance} ${Actor[${Name}].CollisionRadius} @${Radius}"]

		if ${LastGoodRadius} > 0.7
		{
			; Reduce by 10% for a safety margin
			LastGoodRadius:Set[${Math.Calc[${LastGoodRadius} - (${LastGoodRadius} * 0.10)]}]
		}

		This:Debug[["CollisionMath:MaxCollisionFreeRadius - DEBUG: Resulting Radius: ${LastGoodRadius}"]

		return ${LastGoodRadius}
	}
}
