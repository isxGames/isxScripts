function main()	
{	
	if ${Script[bjshuffle](exists)}
	{	
		echo "BJShuffle is already running."
	}
	else
	{
		RunScript bjshuffle
	}
}	