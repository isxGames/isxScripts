function Class_Declaration()
{
   declare PetTarget int script
   declare PetEngage bool script
   addtrigger shard "@*@ says to the group,\"PUTYOUROWNDAMNDTRIGGERIN@grpmember@\""
   addtrigger shard "@*@ says to the raid party,\"PUTYOUROWNDAMNDTRIGGERIN@grpmember@\""
}
 
function Buff_Init()
{
   PreAction[1]:Set[Summon_Pet]
   PreSpellRange[1,1]:Set[356]
 
   PreAction[2]:Set[Group_Buff]
   PreSpellRange[2,1]:Set[21]
   PreSpellRange[2,2]:Set[22]

   PreAction[3]:Set[Self_Buff]
   PreSpellRange[3,1]:Set[25]
   PreSpellRange[3,2]:Set[26]
 
   PreAction[4]:Set[Pet_Buff]
   PreSpellRange[4,1]:Set[46]
   PreSpellRange[4,2]:Set[45]
   PreSpellRange[4,3]:Set[47]
   PreSpellRange[4,4]:Set[290]
 
}
 
function Combat_Init()
{
   Action[1]:Set[Pet_Attack]
   PetEngage:Set[FALSE]

   Action[2]:Set[Pet_DPS]
   MobHealth[2,1]:Set[65]
   MobHealth[2,2]:Set[100]
   MobHealth[2,3]:Set[2]
   MobHealth[2,4]:Set[75]
   SpellRange[2,1]:Set[400]
 
   Action[3]:Set[Horde]
   MobHealth[3,1]:Set[50]
   MobHealth[3,2]:Set[100]
   SpellRange[3,1]:Set[329]
   SpellRange[3,2]:Set[50]
   SpellRange[3,3]:Set[52]

   Action[4]:Set[Hordes]
   MobHealth[4,1]:Set[50]
   MobHealth[4,2]:Set[100]
   SpellRange[4,1]:Set[330]
 
   Action[5]:Set[AoE_PB]
   SpellRange[5,1]:Set[95]
 
   Action[6]:Set[AoE]
   SpellRange[6,1]:Set[90]
 
   Action[7]:Set[Dot]
   MobHealth[7,1]:Set[50]
   MobHealth[7,2]:Set[100]
   SpellRange[7,1]:Set[70]
   SpellRange[7,2]:Set[71]
 
   Action[8]:Set[Nuke_Attack]
   SpellRange[8,1]:Set[60]
   SpellRange[8,2]:Set[61]
 
   Action[9]:Set[Stun]
   MobHealth[9,1]:Set[45]
   MobHealth[9,2]:Set[100]
   SpellRange[9,1]:Set[190]
   
   Action[10]:Set[Heal_Pet]
   SpellRange[10,1]:Set[1]
 
   Action[11]:Set[Self_Power]
   SpellRange[11,1]:Set[309]
   
   Action[12]:Set[Tide]
   MobHealth[12,1]:Set[5]
   MobHealth[12,2]:Set[60]
   SpellRange[12,1]:Set[420]


   SpellRange[50,1]:Set[2]

}
 
function PostCombat_Init()
{
 
}
 
function Buff_Routine(int xAction)
{
   declare tempvar int local

   switch ${PreAction[${xAction}]}
   {
      case Summon_Pet
         call CastSpellRange ${PreSpellRange[${xAction},1]}
         break
 
      case Self_Buff
      case Group_Buff
      case No_Conc_Group_Buff
         call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
         break
 
      case Pet_Buff
         if ${Actor[MyPet](exists)}
         {
            call CastSpellRange ${PreSpellRange[${xAction},1]}
            call CastSpellRange ${PreSpellRange[${xAction},2]}
            call CastSpellRange ${PreSpellRange[${xAction},3]}
            call CastSpellRange ${PreSpellRange[${xAction},4]}
            
         }
         break

      Default
         xAction:Set[10]
         break
   }
}
 
function Combat_Routine(int xAction)
{
   
   grpcnt:Set[${Me.GroupCount}]
   tempgrp:Set[1]

   if ${Me.Ability[Displace Life].IsReady}
   {   
      do
      {
         if ${Me.Group[${tempgrp}].ToActor.Health}<65 && ${Me.Group[${tempgrp}].ToActor.Health}>5 && ${Me.ToActor.Health}>65
         {
            echo Healing ${Me.Group[${tempgrp}]} who has the ID of ${Me.Group[${tempgrp}].ID}
            call CastSpellRange 2 0 0 0 ${Me.Group[${tempgrp}].ID}
         }
      }
      while ${tempgrp:Inc}<${grpcnt}
   }

   switch ${Action[${xAction}]}
   {
      case Pet_Attack
         if !${PetEngage}
         {
            EQ2Execute /pet attack
            PetEngage:Set[TRUE]
            PetTarget:Set[${Target.ID}]
         }
 
         if ${PetTarget}!=${Target.ID}
         {
            EQ2Execute /pet backoff
            EQ2Execute /pet attack
            PetTarget:Set[${Target.ID}]
            PetEngage:Set[TRUE]
         }
          break

      case Pet_DPS
         if ${Target.IsHeroic}
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]}
            }
         
         }
         

         if ${Target.IsEpic}
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},3]} ${MobHealth[${xAction},4]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]}
            }
         
         }
         break
      
      case Tide
         if ${Target.IsEpic}
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]}
            }
         
         }
         break      

       case Horde
         call CastSpellRange ${SpellRange[${xAction},2]} ${SpellRange[${xAction},3]}
         call NPCCount
         if ${Return}<2 && ${Target.IsHeroic}
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]}
            }
         }
         break

       case Hordes
         call NPCCount
         if ${Return}>1 && ${Target.IsHeroic}
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]}
            }
         }
         break
 
      case AoE_PB
      case AoE
         call NPCCount
         if ${Return}>2
         {
            call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
         }
         break
 
      case Dot
         call CastSpellRange 49
         call CastSpellRange 71
         call NPCCount
         if ${Return}<3
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
            }
         }
         break
 
      case Nuke_Attack
         call CastSpellRange ${SpellRange[${xAction},2]}
         call CastSpellRange ${SpellRange[${xAction},1]}
         break
 
      case Stun
         if ${Target.IsHeroic}
         {
            call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
            if ${Return.Equal[OK]}
            {
               call CastSpellRange ${SpellRange[${xAction},1]}
            }
         }
         break
         

      case Heal_Pet
         if ${Me.PetHealth}<50 && ${Me.ToActor.Health}>80
         {
            call CastSpellRange ${SpellRange[${xAction},1]}
         }
         break
 
      case Self_Power
         if !${MainTank} && ${Me.PetHealth}>60 && ${Me.ToActor.Power}<40
         {
            call CastSpellRange ${SpellRange[${xAction},1]}
         }
         break
 
      Default
         xAction:Set[20]
         break
   }
}
 
function Post_Combat_Routine()
{
   PetEngage:Set[FALSE]
 
}
 
function Have_Aggro()
{
   if ${Me.AutoAttackOn}
   {
      EQ2Execute /toggleautoattack
   }
 
   if ${Target.Target.ID}==${Me.ID}
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
 

function shard(string trigline, string grpmember)
{
   
   target ${grpmember}
   do
   {
      face ${Target}
      if ${Target.Distance} > 10
         press -hold ${forward}
      else
         press -release ${forward}
   }
   while ${Target.Distance} > 10
   call CastSpell "${SpellType[360]}" 360
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