function main()
{
	variable int OrbClicked
	OrbClicked:Set[0]
	echo orb clicker started
	do
	{
		if ${Actor[Trakanon].Target(exists)}
		{
			eq2execute apply_verb ${Actor[Chelsith Orb].ID} Touch Chelsith Stone to the Orb
			OrbClicked:Set[1]
		}
	
	}
	while !${OrbClicked}

	echo Orb Clicker Done
}
