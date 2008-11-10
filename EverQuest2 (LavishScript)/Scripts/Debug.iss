;; Debug.iss
;;
;; Includeable debug object.
;; -------------------------
;; Provides the following:
;;	Debug script scope variable, debug type.
;; 
;;	MEMBERS:
;;		Enabled (bool type)
;;	
;;	METHODS:
;;		Enable
;;		Disable
;;		Echo[Arguments]					Echos a debug line with timestamp to the console.
;;		Log[Arguments]					Logs a line in a log file matching the script name in the script dir.
;;		SetFilename[string Filename]	Sets output filename used by Log method.
;;
;;	Example Script:
;;	
;;	#include Debug.iss
;;	
;;	function main()
;;	{
;;		Debug:Enable
;;		Debug:Echo["My script is started"]
;;		Debug:Log["I Ran my script"]
;;	}
	
#ifndef _DEBUG_
#define _DEBUG_

objectdef debug
{
	member:bool Enabled()
	{
		return ${This.IsEnabled}
	}
	
	method Enable()
	{
		This.IsEnabled:Set[TRUE]
	}
	
	method Disable()
	{
		This:IsEnabled:Set[FALSE]
	}
	
	method SetFilename(string Filename)
	{
		This.File:Set[${Filename}]
	}
	
	method Echo(... Args)
	{
		if ${This.Enabled}
		{
			echo ${Time.Time24} DEBUG: ${Args.Expand}
		}
	}
	
	method Log(... Args)
	{
		if ${This.Enabled}
		{
			redirect -append "${This.File}" "echo ${Time.Year}${Time.Month.LeadingZeroes[2]}${Time.Day.LeadingZeroes[2]} ${Time.Time24} DEBUG: ${Args.Expand.EscapeQuotes}"
		}
	}
	
	method Initialize()
	{
		This.IsEnabled:Set[FALSE]
		This.File:Set["${Script.CurrentDirectory}/${Script.Filename}.txt"]
	}
	
	variable bool IsEnabled
	variable string File
}

variable debug Debug

#endif /* _DEBUG_ */

