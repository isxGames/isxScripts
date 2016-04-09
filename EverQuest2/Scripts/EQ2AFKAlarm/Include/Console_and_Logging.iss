


function ConsoleEcho(string textString)
{
	UIElement[Output@EQ2AFKAlarm Console]:Echo["[${Time.Time24}] ${textString.Escape}"]

	Log:Log["${textString.Escape}"]

}
function LogToFile(string textString)
{
	/* Temporarily Defunct pending bug */
	/* Using new debug object. */
	Log:Log["${TextString.Escape}"]
}

function CheckForConfigFolders()
{
	call CheckForRealmFolder
	call CheckForCharFolder
	call CheckForLogFolder
}
function CheckForRealmFolder()
{
	declare DataDir    filepath local "${Script.CurrentDirectory}/Data"
	declare PathToTest filepath local "${Script.CurrentDirectory}/Data"

	if ${PathToTest.PathExists}
	{
		Return
	}
	else
	{
		echo issue with Dirs
	}
}
function CheckForCharFolder()
{
	declare RealmDir   filepath local "${Script.CurrentDirectory}/Data"
	declare PathToTest filepath local "${Script.CurrentDirectory}/Data/${Me}"

	if ${PathToTest.PathExists}
	{
		Return
	}
	else
	{
		RealmDir:MakeSubdirectory[${Me}]
	}
}
function CheckForLogFolder()
{
	declare CharDir    filepath local "${Script.CurrentDirectory}/Data/${Me}"
	declare PathToTest filepath local "${Script.CurrentDirectory}/Data/${Me}/Logs"

	if ${PathToTest.PathExists}
	{
		Return
	}
	else
	{
		CharDir:MakeSubdirectory[Logs]
	}
}