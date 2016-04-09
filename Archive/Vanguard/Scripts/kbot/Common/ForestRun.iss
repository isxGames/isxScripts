
#include KB_BNavObjects.iss

variable(global) bnav bNavi

function main()
{
	call bNavi.Initialize

	while (1)
	{
		bNavi:AutoBox
		bNavi:ConnectOnMove
		waitframe
	}
}