function main()
{
	echo Navigation Connector Script Loaded
	CurrentRegion:Set[${navi.CurrentRegion}]
	LastRegion:Set[${CurrentRegion}]
	while (1)
	{
		navi:AutoBox
		navi:ConnectOnMove
		waitframe
	}
}