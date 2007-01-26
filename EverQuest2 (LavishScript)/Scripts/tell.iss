;-----------------------------------------------------------------------------------------------
; tell.iss Version 1.0  Updated: 06/20/06
; 
; Description:
; ------------
; Plays a .wav file when a tell is recieved.
; You can change the sound that is played by changeing the last line.
; I have included 2 sound files (Intercom.wav, Phaser.wav) 
;-----------------------------------------------------------------------------------------------
#macro ProcessTriggers()  
if "${QueuedCommands}"  
{  
  do  
  {  
     ExecuteQueued  
  }  
  while "${QueuedCommands}"  
}  
#endmac  

function PlaySound(string Filename)  
{  
System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"] 



}  

function main()  
{  
  AddTrigger Tells "@who@/a tells you,"@what""  
  do  
  {  
     ProcessTriggers()  
     waitframe  
  }  
  while 1  
}  

function Tells(string Line)  
{  
  call PlaySound "${LavishScript.CurrentDirectory}/sounds/intercom.wav" 
}  

