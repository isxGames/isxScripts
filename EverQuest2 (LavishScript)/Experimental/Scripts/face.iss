
variable string faceWhere
variable int degrees
variable int targetID


function main()
{



do
{

targetID:Set[${Me.ToActor.Target.ID}]
degrees:Set[${Math.Abs[${Actor[${targetID}].HeadingTo}]} - ${Math.Abs[${Me.Heading}]}]
wait 01
call makeFaceString
echo ${degrees} ${faceWhere}
}
while 1

}


function makeFaceString()
{

; Turn right:  21 to 180   or  -190 to -340
; Turn left:   -21 to - 180   or  190 to 340
; Straight ahead:   -20 to 20

if (${degrees} >= 21 && ${degrees} <= 180) || (${degrees} <= -190 && ${degrees} >= -340) 
{
faceWhere:Set["Turn right"]
}


if (${degrees} <= -21 && ${degrees} >= -180) || (${degrees} >= 190 && ${degrees} <= 340) 
{
faceWhere:Set["Turn left"]
}

if (${degrees} <= 20 && ${degrees} >= -21)
{
faceWhere:Set["Go straight"]
}


}