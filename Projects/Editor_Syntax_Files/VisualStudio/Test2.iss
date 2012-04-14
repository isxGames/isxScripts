/* comment*/
/*
*
* Hello
*
*/
variable int i
;singleLine test
function commentTest()
{
	/* only multiline atm*/
	/* only multiline atm*/
	  ;linetest
	  if 1 ;test
	  ;linetest
	  echo test ;test
}

function:Bool test(int a,b,c=Hello,string d=World)
{
		call argTest 1 2 "Testing C" TestingD AndE
		
		variable(global) int i=0 
		variable(local) complexType CT = 1 2 "Three" 1.0 tr12 12t
		declarevariable i int
		declarevariable CT complexType local 1 2 "Three" 1.0 tr12 12t
		
		x:Set[12]
		echo ${X.Y:T[]:D(cast):T[1,2][]}
		X.Y:T[]:D(cast):T[1,2][]
}

function nestedTest()
{
	for (Count:Set[0] ; ${Count}<=10 ; Count:Inc)
	{
		while ${Count:Inc}<=10
		{
				do
				{
					switch f
					{
						case This is [all] "one" str,ing
						{
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
						}
						variablecase ${x}
							break
					}
				}
				while ${Count:Inc}<=10
		}
  	echo ${Count}
  	echo ${Count}
  }
}

function loopTest()
{
	for (Count:Set[0] ; ${Count}<=10 ; Count:Inc)
  	echo ${Count}
  while ${Count:Inc}<=10
  	echo ${Count}
	do
	{
		echo hi
	}
	while ${Count:Inc}<=10
}

function flowTest()
{
	switch f
	{
		case This is [all] "one" str,ing
			echo Test
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
}