variable int HudX
variable int HudY
variable bool NotifyMana
variable string NotifyPower

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

function main(int rCheck)
{
	ext -require isxeq2

	; Set the default location of the HUD
	HudX:Set[400]
	HudY:Set[400]

	HUD -fontsize 30
	HUD -add PowerStatus ${HudX},${HudY} "Current Power: \${Me.ToActor.Power}"

	do
	{
		waitframe
		ProcessTriggers()
		call CheckDebuff
		call CheckPower
		if ${rCheck}
			call RaidCheck
	}
	while 1
}

function CheckDebuff()
{
	Me:InitializeEffects

	if ${Me.Effect[detrimental,Mana](exists)} && !${NotifyMana}
	{
		HUD -add ManaSac 400,360 "DEBUFFED!!! MANA SACRAFICE!!!"
		HUDSet ManaSac -c FF0000
		NotifyMana:Set[1]
	}

	if !${Me.Effect[detrimental,Mana](exists)} && ${NotifyMana}
	{
		HUD -remove ManaSac
		NotifyMana:Set[0]
	}
}

function CheckPower()
{
	if ${Me.ToActor.Power}>60 && !${NotifyPower.Equal[YELLOW]}
	{
		HUDSet PowerStatus -c FFFF00
		NotifyPower:Set[YELLOW]
	}

	if ${Me.ToActor.Power}<=60 && ${Me.ToActor.Power}>42 && !${NotifyPower.Equal[GREEN]}
	{
		HUDSet PowerStatus -c 00FF00
		NotifyPower:Set[GREEN]
	}

	if ${Me.ToActor.Power}<=42 && !${NotifyPower.Equal[RED]}
	{
		HUDSet PowerStatus -c FF0000
		NotifyPower:Set[RED]
	}
}

function RaidCheck()
{
	declare raidcnt int local 1

	if !${Me.InRaid}
		return

	if !${Actor[Venril](exists)} || ${Actor[Venril].Health}>=65
		return

	do
	{
		if ${Me.Raid[${raidcnt}].ToActor(exists)} && !${Me.Raid[${raidcnt}].ToActor.IsDead} && ${Me.Raid[${raidcnt}].ToActor.Power}>=59
		{
			;eq2execute /ooc --==[ ${Me.Raid[${raidcnt}].Name} ]==-- You're Power is over 59% --==[ ${Me.Raid[${raidcnt}].Name} ]==--
			wait 0.3
			eq2execute /tell ${Me.Raid[${raidcnt}].Name} SPRINT NOW - Your power is too HIGH!

			call CheckDebuff
			call CheckPower
			wait 0.3
		}
		if ${Me.Raid[${raidcnt}].ToActor(exists)} && !${Me.Raid[${raidcnt}].ToActor.IsDead} && ${Me.Raid[${raidcnt}].ToActor.Power}<=42 && !${Me.Raid[${raidcnt}].ToActor.IsDead}
		{
			;eq2execute /shout --==[ ${Me.Raid[${raidcnt}].Name} ]==-- You're Power is under 42% --==[ ${Me.Raid[${raidcnt}].Name} ]==--
			wait 0.3
			eq2execute /tell ${Me.Raid[${raidcnt}].Name} Your power is dangerously LOW!

			call CheckDebuff
			call CheckPower
			wait 0.3
		}
	}
	while ${raidcnt:Inc}<=24
}
