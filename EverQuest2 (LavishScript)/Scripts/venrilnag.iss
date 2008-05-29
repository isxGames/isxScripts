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
	if !${Me.InRaid}
		return

	if !${Actor[Venril](exists)} || ${Actor[Venril].Health}>=65
		return

	declare raidcnt int local 1

	do
	{
		if ${Actor[pc,exactname,${Me.Raid[${raidcnt}].Name}](exists)} && ${Actor[pc,exactname,${Me.Raid[${raidcnt}].Name}].Power}>60
		{
			eq2execute /ooc --==[ ${Me.Raid[${raidcnt}].Name} ]==-- You're Power is over 60% --==[ ${Me.Raid[${raidcnt}].Name} ]==--

			call CheckDebuff
			call CheckPower

			;wait 0.3
		}
		if ${Actor[pc,exactname,${Me.Raid[${raidcnt}].Name}](exists)} && ${Actor[pc,exactname,${Me.Raid[${raidcnt}].Name}].Power}<=40 && !${Actor[pc,exactname,${Me.Raid[${raidcnt}].Name}].IsDead}
		{
			eq2execute /shout --==[ ${Me.Raid[${raidcnt}].Name} ]==-- You're Power is over 60% --==[ ${Me.Raid[${raidcnt}].Name} ]==--

			call CheckDebuff
			call CheckPower

			;wait 0.3
		}
	}
	while ${raidcnt:Inc}<=24

}

