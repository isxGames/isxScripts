
; Quick Script by equidis
; Runs any command on keypress. Define your commands inside of the script, it's not setup to use xml.
; Feel free to add that on and upload it =)
; Happy Gaming!

function main() 
{

; define for hotkey

#define s1 f5
#define s2 f6
#define s3 f7
#define s4 f8
#define s5 f9
#define s6 f10

#define close f11

; define what command to use when pressed

#define sc1 "run attack"
#define sc2 "run stop"
#define sc3 "run followme"
#define sc4 "run train"
#define sc5 "run targetme"
#define sc6 "run died"

#define closed "endscript qs"

; binds your hotkeys to your keyboard

bind hotrun1 "s1" sc1
bind hotrun2 "s2" sc2
bind hotrun3 "s3" sc3
bind hotrun4 "s4" sc4
bind hotrun5 "s5" sc5
bind hotrun6 "s6" sc6
bind hotrunclose "close" closed

; displays them onto your screen

HUD -add disphead 175,85 Quick Script Keys:
HUD -add disp1 185,105 s1: sc1
HUD -add disp2 185,125 s2: sc2
HUD -add disp3 185,145 s3: sc3
HUD -add disp4 185,165 s4: sc4
HUD -add disp5 185,185 s5: sc5
HUD -add disp6 185,205 s6: sc6
HUD -add dispfoot 185,225 close: closed



; Forever loop until they close it...

do
{
}
while 1>0

				
}

function atexit()
{

; Unbind keys, remove hud info...

; KEY BIND Removal:

bind -delete hotrun1
bind -delete hotrun2
bind -delete hotrun3
bind -delete hotrun4
bind -delete hotrun5
bind -delete hotrun6
bind -delete hotrunclose

; HUD Removal:

HUD -remove disphead
HUD -remove disp1
HUD -remove disp2
HUD -remove disp3
HUD -remove disp4
HUD -remove disp5
HUD -remove disp6
HUD -remove dispfoot

echo Quick Script has ended...(Keys returned to normal)

}
