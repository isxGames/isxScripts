function Class_Declaration()
{
    declare KillTarget1 int script
    declare KillTarget2 int script
    ;declare mobcount int script
    declare debugval bool script FALSE

    declare oldebugval string script
    declare tempcounter int script 0

    declare CurState string script
    AddTrigger hoact HEROICOPPORTUNITY::@state@

}

function Buff_Init()
{
    PreAction[1]:Set[Self_Buff]
    PreSpellRange[1,1]:Set[25]
    PreSpellRange[1,2]:Set[26]

    PreAction[2]:Set[Group_Buff]
    PreSpellRange[2,1]:Set[20]
    PreSpellRange[2,2]:Set[21]

    PreAction[3]:Set[Tank_Buff]
    PreSpellRange[3,1]:Set[40]
    PreSpellRange[3,2]:Set[42]
}

function Combat_Init()
{
    Action[1]:Set[Debuff]
    MobHealth[1,1]:Set[80]
    MobHealth[1,2]:Set[98]
    Power[1,1]:Set[20]
    Power[1,2]:Set[100]
    SpellRange[1,1]:Set[50]
    SpellRange[1,2]:Set[51]

    Action[2]:Set[AoE_Debuff]
    MobHealth[2,1]:Set[60]
    MobHealth[2,2]:Set[98]
    Power[2,1]:Set[40]
    Power[2,2]:Set[100]
    SpellRange[2,1]:Set[55]
    SpellRange[2,2]:Set[56]

    Action[3]:Set[AoE]
    SpellRange[3,1]:Set[90]
    SpellRange[3,1]:Set[94]

    Action[4]:Set[Power_Drain]
    SpellRange[4,1]:Set[332]

    Action[5]:Set[Summon_Pet]
    MobHealth[5,1]:Set[70]
    MobHealth[5,2]:Set[100]
    SpellRange[5,1]:Set[329]

    Action[6]:Set[Dot]
    MobHealth[6,1]:Set[50]
    MobHealth[6,2]:Set[95]
    SpellRange[6,1]:Set[70]
    SpellRange[6,2]:Set[74]

    Action[7]:Set[Nuke_Attack]
    SpellRange[7,1]:Set[60]
    SpellRange[7,2]:Set[62]

    Action[8]:Set[Stun]
    SpellRange[8,1]:Set[190]
    SpellRange[8,2]:Set[191]

    Action[9]:Set[Self_Power]
    SpellRange[9,1]:Set[309]

    Action[10]:Set[Give_Power]
    SpellRange[10,1]:Set[333]
}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
    call debugger "Buff_Routine"
    switch ${PreAction[${xAction}]}
    {
        case Self_Buff
        if ${Math.Calc[${Me.Power}/${Me.MaxPower}*100]}<=90 && ${Math.Calc[${Me.Health}/${Me.MaxHealth}*100]}>=60
            {
                call CastSpellRange 333 0 0 0 ${Me.ID}
                call CastSpellRange 309 0 0 0 ${Me.ID}
            }
            break

        case Group_Buff
            call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
            break

        case Tank_Buff
            if ${Actor[${MainAssist}](exists)}
            {
                call CastSpellRange 40 0 0 0 ${Actor[${MainAssist}].ID}
                call CastSpellRange 41 0 0 0 ${Actor[${MainAssist}].ID}
                call CastSpellRange 42 0 0 0 ${Actor[${MainAssist}].ID}
            }
            break

        Default
            xAction:Set[20]
            break
    }
}

function Combat_Routine(int xAction)
{
    call debugger "Combat_Routine"
    if ${Math.Calc[${Me.Power}/${Me.MaxPower}*100]}<1
    {
	    Me.Equipment[ExactName,Pristine disease imbued ironwood wand]:Use 
    }
    
    switch ${Action[${xAction}]}
    {
        case AoE_Debuff
        call NPCCount
        call Nil_Crystal
        if ${Return}>2
        {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
                call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                if ${Return.Equal[OK]}
                {
                    call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
                }
            }
        }
        break

        case AoE
            Call Nil_Crystal
            call NPCCount
            if ${mobcount}>=2
            {
                call CastSpellRange 90 94
            }
            break

        case Power_Drain
            call CastSpellRange 332 0
            wait 3
            break

        case Dot
            if ${Target.Health}<=80
            {
            call Nil_Crystal
            }
            call NPCCount
            if ${mobcount}<3
            {
                call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
                if ${Return.Equal[OK]}
                {
                call CastSpellRange 70 74

                }
            }
            break

        case Summon_Pet
            if ${Me.Inventory[nil crystal].Quantity}>1
            {
                call NPCCount
                if ${mobcount}==1
                {
                    call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
                    if ${Return.Equal[OK]}
                    {
                        eq2echo Attempting to cast Summon Pet
                        call CastSpellRange 329

                    }
                }
            }
            break
        case Debuff
            if !${Me.AutoAttackOn}
            {
                EQ2Execute /toggleautoattack
            }
            call NPCCount
            if ${Return}<5
            {
                call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
                if ${Return.Equal[OK]}
                {
                    call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
                    if ${Return.Equal[OK]}
                    {
                        call Nil_Crystal
                        call CastSpellRange 332 0
                        call CastSpellRange 50 51
                        call CastSpellRange 55 56
                        ;call CastSpellRange 395 0
                    }
                }
            }
            break
        case Stun
            eq2echo Attempting to cast Stun
            Me.Ability[Arcane Augur]:Use
            call CastSpellRange 190 0
            break


        case Nuke_Attack
            call Nil_Crystal

            call CastSpellRange 331 0 1 2
            Call CastSpellRange 131 0 1 2
            Me.Ability[Word of Force]:Use
            call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
            call CastSpellRange 332 0
            break



        case Self_Power
            if ${Math.Calc[${Me.Power}/${Me.MaxPower}*100]}<80 && ${Math.Calc[${Me.Health}/${Me.MaxHealth}*100]}>85 && !${haveaggro}
            {
                call CastSpellRange 309
            }
            break

        case Give_Power
            if ${Math.Calc[${Me.Health}/${Me.MaxHealth}*100]}>85 && !${haveaggro}
            {
                grpcnt:Set[${Me.GroupCount}]
                tempgrp:Set[1]
                do
                {
                    switch ${Me.Group[${tempgrp}].ToActor.Class}
                    {
                        case priest
                        {
                            if ${Me.Group[${tempgrp}.ToActor.Power]}<80
                            {
                                call CastSpellRange 333 0 1 2 ${Me.Group[${tempgrp}].ToActor.ID}
                            }
                        }
                        case berserker
                        {
                            if ${Me.Group[${tempgrp}.ToActor.Power]}<80
                            {
                                call CastSpellRange 333 0 1 2 ${Me.Group[${tempgrp}].ToActor.ID}
                            }
                        }
                        case templar
                        case inquisitor
                        case druid
                        case fury
                        case warden
                        case shaman
                        case defiler
                        case mystic
                    }
                }
                while ${tempgrp:Inc}<${grpcnt}
            }
            break

        Default
            xAction:Set[20]
            break
    }
}

function Post_Combat_Routine()
{
    call debugger "Post_Combat_Routine"

    if ${Me.AutoAttackOn}
            {
                EQ2Execute /toggleautoattack
            }
    if ${Math.Calc[${Me.Health}/${Me.MaxHealth}*100]}>85 && !${haveaggro}
    {
        grpcnt:Set[${Me.GroupCount}]
        tempgrp:Set[1]
        do
        {
            switch ${Me.Group[${tempgrp}].ToActor.Class}
            {
                case priest
                {
                    if ${Me.Group[${tempgrp}.ToActor.Power]}<80
                    {
                        call CastSpellRange 333 0 1 2 ${Me.Group[${tempgrp}].ToActor.ID}
                    }
                }
                case berserker
                {
                    if ${Me.Group[${tempgrp}.ToActor.Power]}<80
                    {
                        call CastSpellRange 333 0 1 2 ${Me.Group[${tempgrp}].ToActor.ID}
                    }
                }
                case templar
                case inquisitor
                case druid
                case fury
                case warden
                case shaman
                case defiler
                case mystic
            }
        }
        while ${tempgrp:Inc}<${grpcnt}
    }
}

function Have_Aggro()
{
    call debugger "Have_Aggro"
    if ${Me.AutoAttackOn}
    {
        EQ2Execute /toggleautoattack
    }

    if ${Target.Target.ID}==${Me.ID} && ${Target.ID}!=${Me.ID}
    {
        call CastSpellRange 180
    }

    if !${homepoint}
    {
        return
    }

    if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
    {
        call CastSpellRange 181

        call NPCCount
        if ${Return}<3
        {
            press -hold ${backward}
            wait 3
            press -release ${backward}
            avoidhate:Set[TRUE]
        }
    }
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{

}

function Cancel_Root()
{

}

function Nil_Crystal()
{
    call debugger "Nil_Crystal"
    if ${Me.Inventory[nil crystal].Quantity}<40
    {
        KillTarget1:Set[${Actor[${MainAssist}].Target.ID}]
        if ${Target.ID}!=${Actor[${KillTarget2}].ID} && ${Target.Health}<90
        {
            KillTarget2:Set[${Actor[${MainAssist}].Target.ID}]
            eq2echo Making a Nil Crystal.  Currently have: ${Me.Inventory[nil crystal].Quantity}
            call CastSpellRange 50 51
        }
    }
}

function GainExp()
{


}

function debugger(string temper)
{
    ;eq2echo here
    if ${debugval}
    {
        ;eq2echo here 2
        ;if "${oldebugval}"=="${temper}"
        ;{
        ;   eq2echo here 3
        ;   tempcounter:Set[${Math.Calc[tempcounter+1]}]
        ;   eq2echo here 4
        ;   if ${tempcounter}>5
        ;       {
        ;           return
        ;       }
        ;}
        ;}
        ;oldebugval:Set[${temper}]
        eq2echo I am at: ${temper}
    }
}

function hoact(string line, string state) 
{
;=======================================================;
;This needs to be re-visited, or put into the extension	;

;  This is NOT active yet.  Still working on it.



;=======================================================;

return


CurState:Set["Reacting to HO"]
	if ${SettingXML[${mainpath}/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[Position${EQ2.HOCurrentWheelSlot}].GetInt[${Me.Archetype}](exists)}
	{
	;===============================================================;
	;If the HO database is filled out for this HO, then advance it	;
	;===============================================================;
	call CastSpellRange ${SettingXML[scripts/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[FirstPosition${EQ2.HOCurrentWheelSlot}].GetInt[${Me.Archetype}]} 
	call CastSpellRange ${SettingXML[scripts/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[SecondPosition${EQ2.HOCurrentWheelSlot}].GetInt[${Me.Archetype}]} 
	}
	else
	{
	;=======================================================;
	;Otherwise, Create an empty entrie in the HO database	;
	;=======================================================;
	SettingXML[${mainpath}/XML/EQ2BotHO.xml].Set[${EQ2.HOName}]:Set[Description,${EQ2.HODescription}]:Save
	SettingXML[${mainpath}/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[FirstPosition${EQ2.HOCurrentWheelSlot}]:Set[${Me.Archetype},"000"]:Save
	SettingXML[${mainpath}/XML/EQ2BotHO.xml].Set[${EQ2.HOName}].Set[Wheel${EQ2.HOWheelState}].Set[SecondPosition${EQ2.HOCurrentWheelSlot}]:Set[${Me.Archetype},"000"]:Save
	}	

}