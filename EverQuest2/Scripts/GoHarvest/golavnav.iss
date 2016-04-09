#define _golavnav_

	
function CurrentRegion()
{
	variable string Region

	Region:Set[${LNavRegion[${World}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]

	if ${LNavRegion[${Region}].Type.Equal[Point]}
	{
		return ${LNavRegion[${Region}].Parent.ID}
	}
	return ${LNavRegion[${Region}].ID}
}



function SavePaths()
{
	Echo Saving map ${World}.xml
	LNavRegion[${World}]:Export[${ConfigPath}${World}.xml]
}

function AutoBox(float dist)
{
	variable float x1=${Math.Calc[${Me.X}-${dist}]}
	variable float x2=${Math.Calc[${Me.X}+${dist}]}
	variable float y1=${Math.Calc[${Me.Y}-${dist}]}
	variable float y2=${Math.Calc[${Me.Y}+${dist}]}
	variable float z1=${Math.Calc[${Me.Z}-${dist}]}
	variable float z2=${Math.Calc[${Me.Z}+${dist}]}
	variable string CurrentRegion
	variable string Region
	
	Region:Set[${LNavRegion[${World}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]
	
	if ${LNavRegion[${Region}].Type.Equal[Universe]}
	{
		LNavRegion[${Region}]:AddChild[box,"auto",-unique,${x1}, ${x2}, ${y1}, ${y2}, ${z1}, ${z2}]
		Region:Set[${LNavRegion[${World}].BestContainer[${Me.X},${Me.Y},${Me.Z}].ID}]
		CurrentRegion:Set[${LNavRegion[${Region}].Name}]
		LNavRegion[${CurrentRegion}]:SetAllPointsValid[TRUE]
		Echo adding avoid region ${Me.X} , ${Me.Y} , ${Me.Z}
	}
}

function FindClosestPoint(float myx, float myy, float myz)
{
	Region:Set[${LNavRegion[${World}].BestContainer[${myx},${myy}, ${myz}].ID}]
	Container:Set[${LNavRegion[${Region}].BestContainer[${myx},${myy},${myz}]}]
	return ${LNavRegion[${Container}].Type}
}