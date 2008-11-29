


function ConsoleEcho(string textString)
{
	UIElement[Output@EQ2AFKAlarm Console]:Echo["[${Time.Time24}] ${textString.Escape}"]

	if ${Logging}
	{
		LogFile:Open
		LogFile:SeekEnd[0]
		LogFile:Write["[${Time.Time24}] ${textString.Escape}\n"]
		LogFile:Close
	}
}
function LogToFile(string textString)
{
	/* Temporarily Defunct pending bug */
}

function CheckForConfigFolders()
{
	call CheckForRealmFolder
	call CheckForCharFolder
	call CheckForLogFolder
}
function CheckForRealmFolder()
{
	declare DataDir    filepath local "${Script.CurrentDirectory}/EQ2AFKAlarm/Data"
	declare PathToTest filepath local "${Script.CurrentDirectory}/EQ2AFKAlarm/Data"

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
	declare RealmDir   filepath local "${Script.CurrentDirectory}/EQ2AFKAlarm/Data"
	declare PathToTest filepath local "${Script.CurrentDirectory}/EQ2AFKAlarm/Data/${Me}"

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
	declare CharDir    filepath local "${Script.CurrentDirectory}/EQ2AFKAlarm/Data/${Me}"
	declare PathToTest filepath local "${Script.CurrentDirectory}/EQ2AFKAlarm/Data/${Me}/Logs"

	if ${PathToTest.PathExists}
	{
		Return
	}
	else
	{
		CharDir:MakeSubdirectory[Logs]
	}
}