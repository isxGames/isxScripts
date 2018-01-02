; DumpLSTypes.iss
; by tinyromeo
;;;;;;
;
; This script issues an 'lstype -list' command, and then runs 'lstype' on all datatypes returned.   It produces all results in HTML format.
;
; It is designed to provide assistance to script writers, especially when using extensions for which there is minimal documentation.
;;;;;;

variable(script) file File=wiki.html
variable(script) file sFile

function main()
{
	variable index:string MainIndex
	;variable collection:string MainIndex
	variable iterator mIter
	variable int m
	
	File:Open
	File:Write["<Html>\n"]
	
	LavishScript:Eval["lstype -list",MainIndex]
	
;	LavishSettings:AddSet[poop]
	
;	MainIndex:GetIterator[mIter]
;	if ${mIter:First(exists)}
;	do
;	{
;		LavishSettings[poop]:AddSetting[${mIter.Value},${mIter.Value}]
;	}
;	while ${mIter:Next(exists)}
;	LavishSettings[poop]:Sort
;	LavishSettings[poop]:GetSettingIterator[mIter]
;	MainIndex:Clear
;	if ${mIter.First(exists)}
;	do
;	{

;	}
;	while ${mIter.Next(exists)}
	
	MainIndex:GetIterator[mIter]
	if ${mIter:First(exists)}
	do
	{
		if ${mIter.Value.Find[NULL]}
		{
			break
		}
		if ${mIter.Value.Find[LavishScript]} || ${mIter.Value.Find[--]}
		{
			continue
		}
		m:Set[${mIter.Value.Find[-]}]
		if ${m} > 0
			call output ${mIter.Value.Left[${m:Dec}]}
		else
			call output ${mIter.Value}
		
		;echo ${mIter.Value}
	}
	while ${mIter:Next(exists)}
	
	
	File:Write["</Html>"]
	File:Close
	
}

function output(string iput)
{
	variable bool meth = FALSE
	echo ${iput}
	;Redirect poop/${iput}.html lstype ${iput.Lower}
	File:Write["<a href="wiki/${iput}.html">${iput}</a><br>\n"]
	
	variable index:string SubIndex
	variable iterator sIter
	variable int n
	
	LavishScript:Eval["lstype ${iput.Lower}",SubIndex]
	sFile:SetFilename[wiki/${iput}.html]
	sFile:Open
	sFile:Write["<Html>\n"]
	SubIndex:GetIterator[sIter]
	if ${sIter:First(exists)}
	do
	{
		if ${sIter.Value.Find[NULL]}
		{
			break
		}
		
		sFile:Write["${sIter.Value}<br>\n"]
		
		continue
		if ${sIter.Value.Find[Methods]}
		{
			sFile:Write["${sIter.Value}<br>\n"]
			meth:Toggle
			continue
		}
		if ${sIter.Value.Find[Members]} || ${sIter.Value.Find[--]}
		{
			sFile:Write["${sIter.Value}<br>\n"]
			continue
		}
;		n:Set[${sIter.Value.Find[*]}]
;		if ${n} > 0
;		{
;			if !${meth}
;				sFile:Write["${sIter.Value.Left[${n:Dec}]}<br>\n"]
;			else
;				sFile:Write["${sIter.Value.Left[${n:Dec}]}<br>\n"]
;		}
;		else
;		{
			if !${meth}
				sFile:Write[" ${sIter.Value} <br>\n"]
			else
				sFile:Write["${sIter.Value}<br>\n"]
;		}
		
	}
	while ${sIter:Next(exists)}
	
	sFile:Write["</Html>"]
	sFile:Close
}