
; Emergency healer script, by Equidis.

; This script scans group members, and if any are below 100% health, it will cast a group heal.
; Not designed to target and heal, it's more of a general group heal..

; Warden and Fury Adep 3, and Master I, II Group heal is known to keep a tank in perfect health, and uses little power.
; It can also keep all group members at perfect health, unless you're overwhelmed by mobs, which any bot could not keep up with.

; I would normally just spam the group heal, but that was eating too much power at lower level,
; so now it will only hit it when someone in the group is low health




function main()
{


declare x int local
declare spell str local
declare Savespeed int local
declare Noticespeed int local
declare DivSpeed int local
declare temphl int local
declare notice int local
declare laststamp int local
declare triggerheal int local

variable string memhealth


; #### PLEASE SET YOUR HEALING SPELL NAME HERE..

spell:Set[Blessing of Earth]



; ## Notice Seconds, to display a message on screen
; ## Seconds = Seconds * 1... (Just put 1 for 1 seconds, and 30 for 30 seconds)
Noticespeed:Set[20]


eq2echo *********Emergency Healer**********
eq2echo A notification of this bot running will appear every ${Noticespeed} seconds.
eq2echo Healer is now running....

;announce "\\#FF6E6EProtecting Group Health" 1 2


    temphl:Set[1]

    laststamp:Set[${Time.Timestamp}]

do
{

wait ${Savespeed}

    notice:Set[${Time.Timestamp}-${laststamp}]
	

if ${notice} > ${Noticespeed}
{
eq2echo This is a notice: Emergency Healer is still running... ${Time}
    notice:Set[1]
    laststamp:Set[${Time.Timestamp}]
}

    
wait 20
triggerheal:Set[0]
lowest:Set[0]
grpheal:Set[0]
grpcnt:Set[${Me.GroupCount}]
hurt:Set[FALSE]
temphl:Set[1]

if ${Me.ToActor.Health} < 95
{
; I am low health.. Trigger the healing
triggerheal:Set[1]
Me.Ability[${spell}]:Use
}
        
; Save the data into an XML file repeatedly

x:Set[0]

do
{
x:Inc

memhealth:Set[${Me.Group[${x}].ToActor.Health}]

if ${memhealth.Equal[NULL]}
{
; There is no member in this slot...
}
else
{
if ${Me.Group[${x}].ToActor.Health} < 95
{
; A group member is low health.. Trigger the healing
Me.Ability[${spell}]:Use
triggerheal:Set[1]
}
}


}
while ${x}<5

if ${triggerheal}>0
{
	; Heal now
Me.Ability[${spell}]:Use
}


}
while 0 < 1

; Loop until endscript called (no UI has been made for this yet)

}
