
/*Default param type is string*/
/*Newlines are the line terminators*/
/*	';' is a single line comment, but only if it isn't proceeded by another expression in which case it's a line terminator No rules for the evil line comment yet which is why everything is in block comments!*/
/* Code block curlys must be on their own line, whitespace doesn't matter*/
function:bool argTest(int a,int b,c,d,string e)
{
	echo A ${a} B ${b} C ${c} D ${d} E ${e}
}

function main()
{
	consoleclear
	variable int Count
	for (Count:Set[0] ; ${Count}<=10 ; Count:Inc)
  	echo ${Count}
  for (Count:Set[0] ; Count:Inc)
  	echo ${Count}
  while ${Count:Inc}<=10
  		echo ${Count}
	do
	{
	  echo ${Count}
	}
	while ${Count:Inc}<=10
	
	while ${Count:Inc}<=10
	{
	  if ${Count}%2==1
	    continue
	  echo ${Count}
	}
	/*
		Spaces are used to separate function call params.
		Quotes are needed for any string that requires a space in this instance
		meaing call argTest 1 2 "Testing C" TestingD AndE
		outputs A: 1 B: 2 C: Testing C D: TestingD E: AndE
	*/
	call argTest 1 2 "Testing C" TestingD AndE
	/*
		By spaces I mean ' ' or '\t' it doesn't matter which
	*/
	call argTest 1 2 "Testing C"	TestingD AndE
	
	switch f
	{
		/*Terminated by the new line*/
		case This is [all] "one" str,ing
			echo Test
		/*number*/
		case 1 
			break
	}
	if ${x} == 5
	{
		if ${y} == 6
			z:Set[17]
	}
	elseif ${x} == 6
		z:Set[10]
	else
	{
		y:Set[4]
		z:Set[26]
	}
		
	switch 1
	{
	}	
	echo ${t}
	
	/*Ends on the new line*/
	variable string string1 = This is string 1 
	
	/*Param1,3 and 4 are strings but param2 is an int*/
	variable ComplexType ct = "Param1" 2 "Param3" Param4
	
	/*commas separate params, string1:Set[] takes one, any extras are thrown away*/
	string1:Set[This is string 1,this is not string 1]
	
	/*Terminated by the ']'*/
	string1:Set[This is all one string] 
	
	/*Surrounded in quotes to ignore the comma*/
	string1:Set["This is string 1,this is all string 1"] 
	
	/*Quoted strings are separated by a space or comma depending on usage*/
	echo "This is string 1" "This would be a separate string"
	
	/*No quotes so terminates on the new line*/
	echo This is all one string
	
	echo \t\t I also accept \r\n escape sequences!
}