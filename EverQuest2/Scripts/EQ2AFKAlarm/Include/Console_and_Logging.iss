


function ConsoleEcho(string textString)
{
	; In LGUI2, textboxes don't have AppendText - need to get current text, append, and set it back
	variable string currentText
	variable string newLine = "[${Time.Time24}] ${textString.Escape}"

	; Calculate maximum characters per line based on textbox width and font
	; Average character width for Segoe UI is roughly 0.5 * font height
	; Add some buffer for padding/margins
	variable int textboxWidth
	variable int fontSize
	variable int maxChars
	variable float charWidth

	; Get the actual rendered width of the parent window (textbox fills 100% of it)
	textboxWidth:Set[${LGUI2.Element[EQ2AFKAlarm Console].ActualWidth.Precision[0]}]

	; If that didn't work, use a safe default
	if ${textboxWidth} <= 0
		textboxWidth:Set[1800]

	fontSize:Set[${LGUI2.Element[Output].Font.Height}]
	charWidth:Set[${Math.Calc[${fontSize} * 0.5]}]
	; Reduce usable width by 10% for padding/margins
	maxChars:Set[${Math.Calc[(${textboxWidth} * 0.9) / ${charWidth}].Int}]

	; Trim the line if it's too long
	if ${newLine.Length} > ${maxChars}
	{
		newLine:Set["${newLine.Left[${Math.Calc[${maxChars} - 3]}]}..."]
	}

	newLine:Concat["\n"]

	currentText:Set["${LGUI2.Element[Output].Text}"]
	currentText:Concat["${newLine}"]
	LGUI2.Element[Output]:SetText["${currentText.Escape}"]

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