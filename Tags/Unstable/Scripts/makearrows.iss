;-----------------------------------------------------------------------------------------------
; makearrows.iss Version 1.0  Updated: 03/21/06
;
; Written by: CyberTF
; Coaching by: Hendrix
;
; Description:
; ------------
; Arrow making machine for Rangers
; Syntax: run makearrows
;
; TO DO LIST
; ----------
;	add a level check to summon the appropriate arrows
;
;-----------------------------------------------------------------------------------------------

function main()
{
   declare stwarn int 0
   declare matime Float 0

;------------------------------------------;
; set matime to skill time remaining so we ;
; don't start with NULL value and then     ;
; create and display our hud               ;
;------------------------------------------;
   matime:Set[${Me.Ability[Makeshift Arrows].TimeRemaining}]
   hud -add makearrow 10,10 "Makeshift Arrows: \${matime} seconds"

;-----------;
; MAIN LOOP ;
;-----------;
   do
    {
;-------------------------------------------;
; set matime again immediately so we don't  ;
; see any noticible jump in the hud display ;
; and start updating the hud with hudset    ;
;-------------------------------------------;
      matime:Set[${Me.Ability[Makeshift Arrows].TimeRemaining}]
      hudset makearrow -t "Makeshift Arrows: \${matime} seconds"
;-----------------------------------;
; check to see if our ability is up ;
;-----------------------------------;
      if ${Me.Ability[Makeshift Arrows].IsReady}
      {
;----------------------------------------------;
; reset matime and turn on our stealth warning ;
;----------------------------------------------;
      	matime:Set[0]
      	stwarn:Set[1]
;----------------;
; SECONDARY LOOP ;
;----------------;
        do
         {
;-------------------;
; are we stealthed? ;
;-------------------;
            if !${Me.Maintained[Stealth](exists)}
            	{
;------------------------------------------;
; reset the hud to something desctiptive   ;
; so we do not see the NULL value and then ;
; cast the ability and wait so we are not  ;
; spamming the skill (prevents queueing)   ;
;------------------------------------------;
            		hudset makearrow -t "Summoning arrows."
            		Me.Ability[Makeshift Arrows]:Use
            		wait 40
            		break
            	}
;-----------------------------------------------------;
; check if we are to be warned about being in stealth ;
; this will only fire once so we are not spamming     ;
; our hud with needless updates (sanity check)        ;
;-----------------------------------------------------;
            elseif ${stwarn}
            		{
            			hudset makearrow -t "Makeshift Arrows Ready. Will cast when not in stealth"
            			announce "Makeshift Arrows Ready\nWill cast when not in stealth!" 3 2
            			stwarn:Set[0]
            		}
         }
;-------------------------------------------------;
; loop until our skill has been successfully cast ;
;-------------------------------------------------;
        while ${Me.Ability[Makeshift Arrows].IsReady}
      }
    }
;------------------------------------;
; loop forever or until we endscript ;
;------------------------------------;
   while 1
}

function atexit()
{
;--------------------------------;
; clean up our mess before we go ;
;--------------------------------;
   hud -remove makearrow
}