
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

echo ${degrees}
}
while 1

}
