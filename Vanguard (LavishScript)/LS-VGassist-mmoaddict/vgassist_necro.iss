


;********************************************
function necro()
{
	
   do
    {
     waitframe
     call dontkillyourself
     While ${Me.TargetHealth} <= ${mtotpct} && ${Me.TargetHealth} > 0
      {
       Call NecroSpellCombat
      }
     If ${Use_Pet} && !${Me.HavePet}
      {
       Call Needpet
      }
     If ${Use_Minions} && !${Me.InCombat}
      {
       Call getsomeminions
      }
     If ${CorpseSearch} && !${GraveDug} && !${Me.InCombat}
      {
       Call Gravediggn
      }
     
     Call assist   
        
    }
   While ${Me.TargetHealth} > 0 && ${Me.TargetHealth} < 100
   
}
function dontkillyourself()
{
	If ${Me.HealthPct} < 15 && ${Me.Effect[Bloodfeast](exists)}
	{
	Me.Ability[Bloodfeast]:Use
	}
	If ${Me.HealthPct} < 15 && ${Me.Effect[Transmogrify](exists)}
	{
	Me.Ability[Transmogrify]:Use
	}
}

; **************************
; ** Spell Combat Routine **
; **************************
function NecroSpellCombat()
  {
      GraveDug:Set[FALSE]
      If ${facem}
        {
         Call facemob
        }

      If ${Use_Pet} && ${Me.HavePet}
        {
          VGExecute /pet attack
          VGExecute /minion attack
          Call critical
          If ${Me.Pet.Ability[Sneer].IsReady}
           {
            Me.Pet.Ability[Sneer]:Use
           }
          Elseif ${Me.Pet.Ability[Rending Fist VII].IsReady}
           {
            Me.Pet.Ability[Rending Fist VII]:Use
           }
        }
            
      If ${Use_Counter}
        {
         Call necstopspell
         Call critical
        }

      Call HealMe
      
      If ${Use_Dbuff} && ${Me.TargetHealth} >= 50 
        {
         Call Debuff_Mob
        }

      If ${Use_DoT} && ${Me.TargetHealth} >= 25
        {
         Call Dots
        }

      If ${Use_DD} && ${Me.TargetHealth} >= 5
        {
         Call Nukes
        }
      
      Call assist

   }



    
;********************************************
;*                                          *
;********************************************
function Gravediggn()
{
  If ${Me.Target.Type.Equal[CORPSE]} && !${Me.Target.Name.Find[remains]}
   {
    Me.Ability[Necropsy]:Use
    Call MeCasting
    wait 25
    Loot:LootAll
    GraveDug:Set[TRUE]
   }
}
;********************************************
;*                                          *
;********************************************
function Eggtimer()
{
  If ${Light_DPS} && !${Me.Target.Type.Equal[CORPSE]}
   {
    wait 30
   }
}

;********************************************
function critical()
{
waitframe
 If ${Me.Ability[Sealed Fate V].IsReady}
  {
   Me.Ability[Sealed Fate V]:Use
   Call MeCasting
  }
 ElseIf ${Me.Ability[Shadow Feast III].IsReady}
  {
   Me.Ability[Shadow Feast III]:Use
   Call MeCasting
  }
 ElseIf ${Me.Ability[Bone Chill IV].IsReady}
  {
   Me.Ability[Bone Chill IV]:Use
   Call MeCasting
  }
}


;====================================================
function Dots()
{
 d:Set[1]
   while ${d}<=${HowManyDots}
   {
     if "${Me.Ability[${Dot${d}}].IsReady} && ${Me.Target.ID(exists)} && !${Me.TargetDebuff[${Dot${d}}](exists)}"
       {
         Call HealMe
         echo "Now casting [${Dot${d}}]"
         Me.Ability[${Dot${d}}]:Use
         call MeCasting
         call critical
         Call Eggtimer
       }
     d:Set[${d}+1]
   }
}

;================================================
function Nukes()
{
   n:Set[1]
    while ${n}<=${HowManyNukes}
     {
      if "${Me.Ability[${Nuke${n}}].IsReady} && ${Me.Target.ID(exists)}"
	{
         Call HealMe
         echo "Now casting [${Nuke${n}}]"
	 Me.Ability[${Nuke${n}}]:Use
	 call MeCasting
         call critical
         Call Eggtimer
	}
      n:Set[${n}+1]
     }
}
;================================================
function Debuff_Mob()
{
db:Set[1]
  while ${db}<=${HowManyDebuffs}
    {
      if "${Me.Ability[${Debuff${db}}].IsReady} && ${Me.Target.ID(exists)} && !${Me.TargetDebuff[${Debuff${db}}](exists)}"
	{
         echo "Now casting [${Debuff${db}}]"
	 Me.Ability[${Debuff${db}}]:Use
	 call MeCasting
         call critical
         Call Eggtimer
	}
      db:Set[${db}+1]
      ;echo "setting increment to ${db}"
     }
}
;=================================================
function HealMe()
{
  if ${Me.Ability[${Heal1}].IsReady} && ${Havetarget} && !${Me.Target.Type.Equal[CORPSE]} && ${Use_Heal} && ${Me.HealthPct} <= 60
    {
      echo "Better Hurry up and Heal"
      Me.Ability[${Heal1}]:Use
      call MeCasting
    }
}


;*******************************************************
;*****            must have minions                *****
;*******************************************************
function getsomeminions()
{
  if (${Me.HaveMinion} && ${Me.Minion}==2) || ${Me.Target.ID}==${Lasttarget}
     return
  elseif (!${Me.HaveMinion} || ${Me.Minion}<1) && !${Me.InCombat} && ${Use_Minions}
    {
      Pawn[corpse]:Target
      if ${Me.Target.Type.Equal[CORPSE]} && ${Me.Target(exists)} && ${Me.Ability[${MinionType1}].IsReady} 
        {
          Me.Ability[${MinionType1}]:Use
          call MeCasting
          Lasttarget:Set[${Me.Target.ID}]
        }
    }
   elseif (!${Me.HaveMinion} || ${Me.Minion}==1) && !${Me.InCombat} && ${Use_Minions}
    {
      Pawn[corpse]:Target
      if ${Me.Target.Type.Equal[CORPSE]} && ${Me.Target(exists)} && ${Me.Ability[${MinionType2}].IsReady} 
        {
          Me.Ability[${MinionType2}]:Use
          call MeCasting
          Lasttarget:Set[${Me.Target.ID}]
        }
    }
}

;*******************************************************
;*****            must have a pet                  *****
;*******************************************************
function Needpet()
{
  if ${Me.HavePet}
   return
  elseif "!${Me.InCombat} && ${Me.EnergyPct}>=50 && ${Use_Pet}"
    {
      Me.Ability[Awaken Abomination II]:Use
      call MeCasting
    }
}

;*************************************
;**           The End               **
;*************************************