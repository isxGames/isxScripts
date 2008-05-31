
; ///////////////////////////////////////////////////////////////////


; Buff Me OMG!   v 1.0     by Equidis


; Created on 5/23/2008


; PLEASE READ THE FOLLOWING:
; YOU MUST SET YOUR SPELLS BELOW.
; See the sections below the function main()



; BEFORE RUNNING THIS SCRIPT 
; BEFORE RUNNING THIS SCRIPT 
; BEFORE RUNNING THIS SCRIPT 
; BEFORE RUNNING THIS SCRIPT 

; READ ABOVE.... YOU NEED TO SET YOUR SPELLS!

; TO SET YOUR SPELLS, SEARCH FOR:   Tanktastic

; HE IS THE EXAMPLE BUFF ROUTINE FOR A 44 SHADOWKNIGHT

; ///////////////////////////////////////////////////////////////////





; This script is best run right after you have died.






; -> Some problems occurr for rebuffing for some TANKS:

; ///////////////////////////////////////////////////////////////////

; for example, Evasive Maneuvers (a Shadowknight spell) which I can cast on a group member
; which gives me additional parry, and helps them dodge more....
; Since it returns Single Target as the type, it's assumed the destination of the spell should
; be the person I am buffing, but returns MYSELF as the target
; Therefor, if u run this script while this type of spell is on
; It will unbuff it.

; So keep an eye out for that type of thing, where you share the same buff with a group member
; it can only be cast once, and it goes on you as well as your target.

; ///////////////////////////////////////////////////////////////////



variable bool notBuffed

variable string TargetName



function main()
{

; For each buff [1 or 2 or 3 etc] 
; buffTarget [1 or 2 etc] can be a player in the group to target for the buff.
; If the same buff goes on a different person, just make a new buff, and  set its target

variable string buffs[15]
variable string buffTarget[15]
variable int cBuff
variable bool isAlreadyBuffed
variable string myBuffTarget
variable int scanID

; NOTICE:

; In order to properly identify buffs
; You must use EXACT buff names including the punctuation and capitalization and spacing.
; BUFFS ARE CASE SENSITIVE

; BUFFS ARE CASE SENSITIVE
; BUFFS ARE CASE SENSITIVE
; BUFFS ARE CASE SENSITIVE
; BUFFS ARE CASE SENSITIVE
; BUFFS ARE CASE SENSITIVE
; BUFFS ARE CASE SENSITIVE
; BUFFS ARE CASE SENSITIVE


; LOOK AT Tanktastic's BUFF SECTION. JUST REPLACE HIS NAME, ADD MORE NAMES IF YOU LIKE.

; As you can see some examples of fake character names....
; You must set YOUR OWN character names, no XML files in this one sorry.

; To setup a buff system for your char:
; Change the     Tanktastic     name to your Char's name... The Tanktastic section
; is a good example of a lvl 44 Shadowknight buff routine...




; If your buff doesn't have a target, or needs to target self, don't set anything for the target!




; SET YOUR SPELLS HERE:




if ${Me.Name.Equal[Tanktastic]}
{

; My Buffs

buffs[1]:Set["Contract of Shadows"]
buffs[2]:Set["Insatiable Hunger"]
buffs[3]:Set["Cursed Caress"]
buffs[4]:Set["Unhallowed Aura"]
buffs[5]:Set["Calculated Evasion"]
buffs[6]:Set["Reaver"]
buffs[7]:Set["Stance: Plague Sword"]
buffs[8]:Set["Contract of Shadows"]

; Target of a specific buff

buffTarget[5]:Set["Healtastic"]
}



if ${Me.Name.Equal[Healtastic]}
{

; My Buffs

buffs[1]:Set["Dire Shroud"]
buffs[2]:Set["Baleful Efflux"]
buffs[3]:Set["Voracity"]
buffs[4]:Set["Immunities"]
buffs[5]:Set["Sinister Countenance"]
buffs[6]:Set["Abominus"]
buffs[7]:Set["Tendrils of Fear"]
buffs[8]:Set["Dread Invective"]
buffs[9]:Set["Harbinger"]
buffs[10]:Set["Harbinger"]

; Target of a specific buff

buffTarget[7]:Set["Tanktastic"]
buffTarget[8]:Set["Tanktastic"]
buffTarget[9]:Set["Tanktastic"]
}



call PauseTargettingScripts



; Perform buff routine....

cBuff:Set[1]

do
{

if ${buffs[${cBuff}].Length} > 4
{
; Perform possible events which would cause me to not want to buff right now...
call holdBuffs

; Perform buff .... we are no longer on hold or it's ok to buff right now...

myBuffTarget:Set[${buffTarget[${cBuff}]}]

if ${myBuffTarget.Length} > 2
{
; I have a buff target...

;//////////////////
;-> New targetting system added Removed this command.
;   call targetSomeone ${myBuffTarget}

; New Version:

TargetName:Set[${myBuffTarget}]

;//////////////////

scanID:Set[${Actor[${myBuffTarget}, PC, EXACT].ID}]
}
else
{
; Target myself....
scanID:Set[${Me.ID}]
TargetName:Set[${Me.Name}]
}

; Check my Maintained for an existing buff of this spell...
; To keep me from unbuffing it...

call scanMaintained "${buffs[${cBuff}]}" ${scanID}

if ${notBuffed}
{
; Cast the buff now....
call castBuff "${buffs[${cBuff}]}"
}

; This buff should be on you already or successfully buffed
}
}
while ${cBuff:Inc}<=15 


call ResumeTargettingScripts

}


function castBuff(string spell)
{
call waitForBuffToBeReady "${spell}"
if ${TargetName.Equal[""]}
{
; Old Targetting System
Me.Ability["${spell}"]:Use
}
else
{
; New Targetting System
eq2execute /useabilityonplayer ${TargetName} ${spell}
}
wait 07
}



function waitForBuffToBeReady(string spell)
{
; This waits for the spell to be ready to be cast...
do
{
waitframe
if ${spell.Length} < 4
{
break
}
if ${Me.Ability["${spell}"].IsReady}
{
break
}
wait 03
}
while 1
}




function scanMaintained(string spell, int targetID)
{

; This scans your Maintained to see if you already have it...

; SET BY DEFAULT TO TRUE.. dont touch this :>
notBuffed:Set[TRUE]

variable string maintainedSpell
variable int mC
variable int maintainedTargetID
variable string maintainedType

mC:Set[1]

do
{

maintainedSpell:Set[${Me.Maintained[${mC}].Name}]
maintainedType:Set[${Me.Maintained[${mC}].Type}]
maintainedTargetID:Set[${Me.Maintained[${mC}].Target.ID}]

if ${maintainedSpell.Equal[${spell}]}
{

notBuffed:Set[FALSE]

 if ${maintainedType.Equal["Single Target"]}
 {
   if ${maintainedTargetID} > ${targetID} || ${maintainedTargetID} < ${targetID}
   {
    ; This spell is currently not on the desired target.
    ; The buff found belongs to another player....
    notBuffed:Set[TRUE]
   }
 }
if ${notBuffed} == FALSE
{
break
}
}
}
while ${mC:Inc} <= ${Me.CountMaintained}


}



function targetSomeone(string targetWho)
{
Actor[${targetWho}]:DoTarget
wait 05
}


function holdBuffs()
{
do
{
waitframe

if ${Me.ToActor.InCombatMode} || ${Me.IsMoving} || ${Me.CastingSpell} || ${Me.ToActor.Health} <= 90
{
; I am in combat or
; I am moving or
; I am casting or
; I am dying.
wait 10
}
else
{
; All is well
break
}
}
while 1
}






function PauseTargettingScripts()
{
; Pauses scripts that might change targetting..

if ${Script[heal](exists)}
{
Script[heal]:Pause
wait 10
}


if ${Script[assist](exists)}
{
Script[assist]:Pause
wait 10
}

if ${Script[eq2bot](exists)}
{
Script[eq2bot]:Pause
wait 10
}


}


function ResumeTargettingScripts()
{
; Resumse scripts that were paused...

if ${Script[assist](exists)}
{
Script[assist]:Resume
}

if ${Script[eq2bot](exists)}
{
Script[eq2bot]:Resume
}

if ${Script[heal](exists)}
{
Script[heal]:Resume
wait 10
}


}
