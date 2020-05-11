#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss"

function main(... Args)		
{
	; Uncomment to enable debugging
	Debug:Enable
	
	
	Debug:Echo["ChoiceWindow.Begin"]
	
	if (${Args.Used} != 2)
		return
	
	variable int Wait = ${Args[1]}
	variable string MethodToExecute = ${Args[2]}
	
	Debug:Echo["ChoiceWindow.Parameters:: Wait = ${Wait} || MethodToExecute = '${MethodToExecute}'"]
	
	Debug:Echo["ChoiceWindow.Wait:: Start Wait... (Thread Time: ${Script.RunningTime})"]
	wait ${Wait}
	Debug:Echo["ChoiceWindow.Wait:: Finished Wait... (Thread Time: ${Script.RunningTime})"]
	
	if ${MethodToExecute.Equal["DoChoice1"]}
	{
		Debug:Echo["ChoiceWindow.Execution:: Executing 'ChoiceWindow:DoChoice1'"]
		ChoiceWindow:DoChoice1
	}
	elseif ${MethodToExecute.Equal["DoChoice2"]}
	{
		Debug:Echo["ChoiceWindow.Execution:: Executing 'ChoiceWindow:DoChoice2'"]
		ChoiceWindow:DoChoice2
	}
	
	Debug:Echo["ChoiceWindow.End"]
	return
}