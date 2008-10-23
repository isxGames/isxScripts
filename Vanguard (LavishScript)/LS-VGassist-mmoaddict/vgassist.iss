#include "${LavishScript.CurrentDirectory}/scripts/common/KB_moveto.iss"
#include "${LavishScript.CurrentDirectory}/scripts/common/KB_functions.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_Settings.iss"

#include "${LavishScript.CurrentDirectory}/scripts/vgassist_cleric.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_bloodmage.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_disciple.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_shaman.iss"

#include "${LavishScript.CurrentDirectory}/scripts/vgassist_necro.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_sorc.iss"
;#include "${LavishScript.CurrentDirectory}/scripts/vgassist_psionicist.iss"
;#include "${LavishScript.CurrentDirectory}/scripts/vgassist_druid.iss"

#include "${LavishScript.CurrentDirectory}/scripts/vgassist_monk.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_rogue.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_bard.iss"
;#include "${LavishScript.CurrentDirectory}/scriapts/vgassist_ranger.iss"

;#include "${LavishScript.CurrentDirectory}/scripts/vgassist_dread.iss"
;#include "${LavishScript.CurrentDirectory}/scripts/vgassist_warior.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_pali.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_mez.iss"

#include "${LavishScript.CurrentDirectory}/scripts/vgassist_states.iss"
#include "${LavishScript.CurrentDirectory}/scripts/vgassist_pawns.iss"

variable bool assisting = TRUE
variable bool Paused = FALSE

variable string assistMember1
variable bool autofollow = FALSE
variable bool assistm = FALSE
variable bool facem = FALSE
variable bool movetot = FALSE
variable int mtotpct
variable bool aharv = FALSE
variable bool lootit = FALSE
variable bool restandfood = FALSE
variable string bigheal
variable string fastheal
variable string smallheal
variable string myname
variable string nocombatres
variable bool mountup = FALSE
variable string mymount
variable bool autotrade = FALSE
variable bool autogroup = FALSE
variable bool healerlow = FALSE
variable int grpnum
variable bool iamahealer = FALSE
variable string myclass
variable settingsetref setCounterSpell
variable string aName
variable string mobcasting
variable string nonecasting
variable string lasttargetid

;******************************************************
;******   Healer PowerLevel Mode variables       ******
;******************************************************
variable string plmember1
variable string plmember2
variable string plmember3
variable string plmember4
variable string plmember5
variable string plmember6
variable bool plmode = FALSE
variable bool pldebuff = FALSE
variable string pldebuff1
variable string pldebuff2

;******************************************************
;******            Necro variables               ******
;******************************************************

variable bool Use_Chains = FALSE
variable bool Use_Counter = FALSE
variable bool Use_Minions = FALSE
variable bool Use_Pet = FALSE
variable bool Use_Heal = FALSE
variable bool Use_Dbuff = FALSE
variable bool Use_DoT = TRUE
variable bool Use_DD = TRUE
variable bool Light_DPS = FALSE
variable bool CorpseSearch = FALSE

variable int HowManyDots
variable int HowManyNukes
variable int HowManyDebuffs

variable string MinionType1
variable string MinionType2

variable string Crit1
variable string Crit2
variable string Crit3

variable string Dot1
variable string Dot2
variable string Dot3
variable string Dot4
variable string Dot5
 
variable string Nuke1
variable string Nuke2

variable string Heal1

variable string Debuff1
variable string Debuff2

variable bool GraveDug = TRUE

variable int mt = 1
variable int i
variable int n
variable int d
variable int db
variable int Lasttarget
;******************************************************
;******            Paladin variables               ******
;******************************************************
variable string AegisStrike
variable string BarrierofFaith
variable string BladeofVolAnari
variable string BlessingofGloriannsProtection
variable string BlessingofLife
variable string BlessingofVaelion
variable string BlessingofVothdar
variable string BoonofValus
variable string BoonofVolAnari
variable string ChampionsMight
variable string Contrition
variable string Courage
variable string CryofIllumination
variable string CryofProwess
variable string CryofSolace
variable string DenyLife
variable string DevoutFoeman
variable string DevoutSanctuary
variable string DictumofValus
variable string Entwine
variable string FinalStand
variable string Forbiddance
variable string FuryofValus
variable string GiftofPeace
variable string GuardiansAssault
variable string HammerofJudgment
variable string HammerofValus
variable string HealingTouch
variable string HolyStrike
variable string JudgmentoftheBloodthirsty
variable string JudgmentoftheEnvious
variable string JudgmentoftheImpure
variable string JudgmentoftheProud
variable string JudgmentoftheUnforgiving
variable string JudgmentoftheWrathful
variable string LayingonofHands
variable string MarshallingCry
variable string MaulofValus
variable string ParagonofJustice
variable string PrayerofLife
variable string ProtectorsFury
variable string Retort
variable string Retribution
variable string RighteousSupplication
variable string SentinelsBlessing
variable string ShieldofChastening
variable string ShieldofGloriann
variable string ShieldofRebuke
variable string ShieldofResolve
variable string ShieldofSolace
variable string ShiningBeacon
variable string Smite
variable string StrikeofGloriann
variable string StrokeofConviction
variable string StrokeofFervor
variable string Succor
variable string Sunburst
variable string Upbraid
variable string Vanquish
variable string VothdarsMightyStrike
variable string WingsoftheAvenger
variable string WrathofVolAnari
variable string Zeal
variable bool palmaintanking = FALSE 
variable bool palassisting = FALSE
variable string shieldfocus
variable bool usejudgment = FALSE
variable string judgmentfocus
variable string palistance
variable bool palifightingundead = FALSE
variable bool palifightinghealers = FALSE
variable bool palimaxdps = FALSE
variable bool palimaxhate = FALSE
variable bool paliautores = FALSE
variable bool paliautocounter = FALSE
variable string paliundeaddebuff
variable string boonfocus
;******************************************************
variable string counterspell1
variable string counterspell2
variable bool counterselected = FALSE
variable bool counterall = FALSE
variable bool DispellSelected = FALSE
variable string dispellbuff
variable string dispell1
variable string itemtouse
;****************************************************
;******            Sorcerer variables              ******
;******************************************************
variable string AmplifyAcuity
variable string AmplifyDestruction
variable string AmplifyEfficiency
variable string ArcaneMantle
variable string AsayasInsight
variable string BlindingFire
variable string ChaosVolley
variable string Char
variable string ChromaticBarrier
variable string ChromaticHalo
variable string ColdWave
variable string ColorSpray
variable string EnergyShard
variable string Ring
variable string Disenchant
variable string Disperse
variable string ElementalMantle
variable string EnergyRift
variable string EtherealSanctuary
variable string FireBarrier
variable string Fireball
variable string FlameSpear
variable string ForceBarrier
variable string Forget
variable string Freeze
variable string Frostbite
variable string GatherEnergy
variable string GhostlySanctuary
variable string GlacialSanctuary
variable string Icequake
variable string Incinerate
variable string InidriasFrigidBlast
variable string InidriasInferno
variable string InnerSanctuary
variable string Invisibility
variable string MeteorStorm
variable string Mimic
variable string MirrorWard
variable string NaturalSanctuary
variable string NullingWard
variable string Reflect
variable string SearingSanctuary
variable string SeeInvisibility
variable string SeradonsFallingStar
variable string SeradonsVision
variable string ShockingGrasp
variable string Sleep
variable string TaqmirsBarrage
variable bool usearcane = FALSE
variable bool useice = FALSE
variable bool usefire = FALSE
variable bool usearea = FALSE
variable bool useaegroup = FALSE
variable bool useamplify = FALSE
variable bool usesorcslowcasting  = FALSE
variable bool usesorcforget = FALSE
variable string sorcslowcastingspeed
variable string sorcforgetnumber
variable int sorccountcast

;******************************************************
;******            Monk variables              ******
;******************************************************

variable string mkattack1
variable string mkattack2
variable string mkattack3
variable string mkagropush1
variable string mkjin1
variable string mkjin2
variable string mkjin3
variable string mkjinbuff1
variable string mkjinbuff2
variable string mkstance
variable string mkaum
variable string mksecret
variable string mkfeign
variable string mkfd
variable bool mkattack = FALSE

;******************************************************
;******            Cleric variables              ******
;******************************************************

variable string clbigheal
variable string clfastheal
variable string clsmallheal
variable bool clmeleetarg = FALSE
variable string clmeleerot = 1
variable string clmeleeattack1 
variable string clmeleeattack2
variable string clmeleeattack3
variable string clenergyattack1
variable string clmeleebuff1
variable string clmeleebuff2
variable string clcritattack1
variable string clcritattack2
variable string clcritattack3
variable bool clcrit = FALSE
variable bool clmeleebuff =FALSE

;******************************************************
;******            Rogue variables              ******
;******************************************************
variable string ArcofDaggers
variable string Backstab
variable string Blackjack
variable string BlindingFlash
variable string Blindside
variable string Clout
variable string DeadlyStrike
variable string Deter
variable string Drub
variable string ElusiveMark
variable string Fade
variable string FatalStroke
variable string Flee
variable string Hemorrhage
variable string Impale
variable string KeenEye
variable string KneeBreak
variable string Lacerate
variable string LethalStrikes
variable string Ploy
variable string Quickblade
variable string Ravage
variable string Relentless
variable string Revenge
variable string Ruin
variable string Shank
variable string Shiv
variable string SmokeBomb
variable string SmokeTrick
variable string Stalk
variable string TrickAttack
variable string ViciousStrike
variable string VitalStrikes
variable string WickedStrike
variable string dexscroll
variable string dexbuff
variable string strbuff
variable string strscroll
variable string poison
variable string bleedingbomb
variable string	explosivebomb
variable string	eviscerate
variable string ourbard
;******************************************************
;******            Disciple variables              ******
;******************************************************

variable bool discmel =FALSE
variable string discbigheal
variable string discfastheal
variable string discsmallheal
variable string discmeleerot = 1
variable string discmeleeattack1 
variable string discmeleeattack2
variable string discmeleeattack3
variable string discenergyattack1
variable string discmeleebuff1
variable string discmeleebuff2
variable string disccritattack1
variable string disccritattack2
variable string disccritattack3
variable bool disccrit = FALSE
variable bool discmeleebuff = FALSE
variable bool discplmode = FALSE

;******************************************************
;******            Bloodmage variables              ******
;******************************************************
variable string bmbigheal
variable string bmfastheal
variable string bmsmallheal
variable bool bmmeleetarg = FALSE
variable string bmmeleeattack1 

variable bool bmblasttarg = FALSE
variable int bmblastrot = 1
variable string bmblastattack1
variable string bmblastattack2
variable string bmblastattack3

variable bool bmdottarg = FALSE
variable int bmdotrot = 1
variable string bmdotattack1
variable string bmdotattack2
variable string bmdotattack3

variable bool bmbloodtarg = FALSE
variable int bmbloodrot = 1
variable string bmbloodattack1
variable string bmbloodattack2
variable string bmbloodattack3

variable bool bmcrittarg = FALSE
variable string bmcritattack1
variable string bmcritattack2
variable string bmcritattack3
;******************************************************
;******           Bard variables              ******
;******************************************************
variable string barddot1
variable string barddot2
variable string bardfinisher
variable string bardmeleedot1
variable string bardmelee1
variable string bardforcecrit
variable string bardmelee2
variable string bardmeleedot2
variable string bardmeleesong
variable bool usemeleesong = FALSE
variable string bardenergysong
variable string bardrunsong
variable string bardcastersong
variable bool usecastersong = FALSE
variable string bardcombatmixsong
variable bool usecombatmixsong = FALSE
variable string bardweapon1
variable string bardweapon2
variable string Drum
variable string Lute
variable string Horn
variable string Flute
variable string bardcrit1
variable string bardcrit2
variable string bardcrit3
variable string bardcrit4
variable string bardcrit5

;******************************************************
;******           Shaman variables              ******
;******************************************************
variable string shbigheal
variable string shfastheal
variable string shsmallheal

variable bool shdottarg = FALSE
variable string shdotattack1
variable string shdotattack2
variable string shdotattack3
variable string shdotattack4

variable bool shblasttarg = FALSE
variable int shblastrot = 1
variable string shblastattack1
variable string shblastattack2

variable bool shslowtarg = FALSE
variable string shslowattack1

variable bool shcann = FALSE
variable string shsmcann
variable string shbigcann

variable bool shcrittarg = FALSE
variable string shcritattack1
variable string shcritattack2
variable string shcritattack3
variable string shcritattack4
variable bool shplmode = FALSE

;******************************************************
variable string grp1 = ${Group[1]}
variable string grp2 = ${Group[2]}
variable string grp3 = ${Group[3]}
variable string grp4 = ${Group[4]}
variable string grp5 = ${Group[5]}
variable string grp6 = ${Group[6]}

variable bool hgrp1 = FALSE
variable bool hgrp2 = FALSE
variable bool hgrp3 = FALSE
variable bool hgrp4 = FALSE
variable bool hgrp5 = FALSE
variable bool hgrp6 = FALSE

variable bool rhgrp1 = FALSE
variable bool rhgrp2 = FALSE
variable bool rhgrp3 = FALSE
variable bool rhgrp4 = FALSE
variable bool rhgrp5 = FALSE
variable bool rhgrp6 = FALSE

variable bool fhgrp1 = FALSE
variable bool fhgrp2 = FALSE
variable bool fhgrp3 = FALSE
variable bool fhgrp4 = FALSE
variable bool fhgrp5 = FALSE
variable bool fhgrp6 = FALSE

variable bool bhgrp1 = FALSE
variable bool bhgrp2 = FALSE
variable bool bhgrp3 = FALSE
variable bool bhgrp4 = FALSE
variable bool bhgrp5 = FALSE
variable bool bhgrp6 = FALSE

variable int rhgrp1pct 
variable int rhgrp2pct 
variable int rhgrp3pct 
variable int rhgrp4pct 
variable int rhgrp5pct 
variable int rhgrp6pct 

variable int fhgrp1pct 
variable int fhgrp2pct 
variable int fhgrp3pct 
variable int fhgrp4pct 
variable int fhgrp5pct 
variable int fhgrp6pct 

variable int bhgrp1pct
variable int bhgrp2pct
variable int bhgrp3pct 
variable int bhgrp4pct 
variable int bhgrp5pct 
variable int bhgrp6pct 

variable int rhgrp1pct2 
variable int rhgrp2pct2 
variable int rhgrp3pct2 
variable int rhgrp4pct2 
variable int rhgrp5pct2 
variable int rhgrp6pct2 

variable int fhgrp1pct2 
variable int fhgrp2pct2 
variable int fhgrp3pct2 
variable int fhgrp4pct2 
variable int fhgrp5pct2
variable int fhgrp6pct2 

variable int bhgrp1pct2
variable int bhgrp2pct2
variable int bhgrp3pct2 
variable int bhgrp4pct2 
variable int bhgrp5pct2 
variable int bhgrp6pct2 

variable int FollowDist = 5
;********************************************
atom(script) VG_onGroupMemberCountChange() 
{
	if !${plmode}
	{
	grp1:Set[${Group[1]}]
	grp2:Set[${Group[2]}]
	grp3:Set[${Group[3]}]
	grp4:Set[${Group[4]}]
	grp5:Set[${Group[5]}]
	grp6:Set[${Group[6]}]
	}

} 



;********************************************
function main()
{
	echo Loading Settings and UI
	Settings:Load
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
   	ui -reload "${Script.CurrentDirectory}/XML/vgassist.xml"
	call preinterface
	LavishScript:RegisterEvent[VG__onGroupMemberCountChange]
	Event[VG_onGroupMemberCountChange]:AttachAtom[VG_onGroupMemberCountChange]
	LavishScript:RegisterEvent[VG__onPawnSpawned]
	lasttargetid:Set[${Me.Target}]
   Do
	{
        waitframe
	call targetchange
        While ${Me.HealthPct} <= 0
        {
         Wait 20
        }
        While ${Paused}
        {
         Wait 20
        }
	while ${assistMember1.Length} < 2
	{
	 wait 20
	}
	call counteringfunct
	call dispellfunct
	if ${autofollow}
		{
		call Dist_Check
		}
	if ${assistm}
		{
		call assist
		}
	if ${facem}
		{
		call facemob
		}
	if ${movetot}
		{
		call movetomelee
		}
	if ${aharv}
		{
		call Harv
		}
	if ${lootit}
		{
		call loot
		}
	if ${restandfood}
		{
		call restup
		}
	if ${pldebuff}
		{
		call powerleveldebuff
		}
	if ${hgrp1} && ${iamahealer}
		{
		call healgroup1
		}
	if ${hgrp2} && ${iamahealer}
		{
		call healgroup2
		}
	if ${hgrp3} && ${iamahealer}
		{
		call healgroup3
		}
	if ${hgrp4} && ${iamahealer}
		{
		call healgroup4
		}
	if ${hgrp5} && ${iamahealer}
		{
		call healgroup5
		}
	if ${hgrp6} && ${iamahealer}
		{
		call healgroup6
		}
	if ${myclass.Equal[Cleric]}
		{
		call cleric
		}
	if ${myclass.Equal[Blood Mage]}
		{
		call bloodmage
		}
        if ${myclass.Equal[necromancer]}
		{
		call necro
		}
	if ${myclass.Equal[Disciple]}
		{
		call disciple
		}
	if ${myclass.Equal[Monk]}
		{
		call monky
		}
	if ${Me.Class.Equal[Shaman]}
		{
		call shaman
		}
	if ${myclass.Equal[Rogue]}
		{
		FollowDist:Set[8]
		call rog
		}
	if ${myclass.Equal[Paladin]}
		{
		call pali
		}
	if ${myclass.Equal[Sorcerer]}
		{
		call sorcy
		call mezit
		}
	if ${myclass.Equal[Bard]}
		{
		call bardi
		call healermanacheck
		}
	call shouldimount
	if ${autogroup}
		{
		call groupup
		}
	if ${autotrade}
		{
		call tradeup
		}
	
	}
   While ${Me(exists)}
}
;********************************************
function targetchange()
{
	if ${Me.Target.Name.Equal[${lasttargetid}]}
	{
	return
	}
	Else
	{
	lasttargetid:Set[${Me.Target}]
	UIElement[PawnTypeEntry@MainPawnsFrame@PawnTypes@SubStats@StatsFrame@Stats@ABot@vgassist]:SetText[${Me.Target}]
	}

}
;********************************************
function healermanacheck()
{
	waitframe
	grpnum:Set[1]
	while ${grpnum} <= ${Group.Count}
	{
		;if (${Group[${grpnum}].Class.Equal[Blood Mage]} || ${Group[${grpnum}].Class.Equal[Cleric]} || ${Group[${grpnum}].Class.Equal[Disciple]} || ${Group[${grpnum}].Class.Equal[Shaman]}) && ${Group[${grpnum}].Energy} < 30 && ${Me.InCombat} && ${Group[${grpnum}].Distance} < 25
		;{
		;healerlow:Set[TRUE]
		;}
		if ${Group[${grpnum}].Class.Equal[Blood Mage]} || ${Group[${grpnum}].Class.Equal[Cleric]} || ${Group[${grpnum}].Class.Equal[Disciple]} || ${Group[${grpnum}].Class.Equal[Shaman]}
		{
			if ${Group[${grpnum}].Energy} > 10 && ${Pawn[${assistMember1}].CombatState} > 0 && ${Group[${grpnum}].Distance} < 25
			{
			healerlow:Set[FALSE]
			}
			if ${Group[${grpnum}].Energy} < 70 && ${Pawn[${assistMember1}].CombatState} < 1 && ${Group[${grpnum}].Distance} < 25
			{
			healerlow:Set[TRUE]
			}
			if && ${Group[${grpnum}].Energy} > 90 && ${Pawn[${assistMember1}].CombatState} < 1 && ${Group[${grpnum}].Distance} < 25
			{
			healerlow:Set[FALSE]
			}
		}
	grpnum:Set[${grpnum}+1]	
	}
	
}

;********************************************
atom seta()
{
   assistMember1:Set[${Me.DTarget}]
   echo "assist is ${assistMember1}"
}
;********************************************
atom setmbr1()
{
   plmember1:Set[${Me.DTarget}]
}
;********************************************
atom setmbr2()
{
   plmember2:Set[${Me.DTarget}]
}
;********************************************
;*                                          *
;********************************************
atom setmbr3()
{
   plmember3:Set[${Me.DTarget}]
}
;********************************************
;*                                          *
;********************************************
atom setmbr4()
{
   plmember4:Set[${Me.DTarget}]
}
;********************************************
;*                                          *
;********************************************
atom setmbr5()
{
   plmember5:Set[${Me.DTarget}]
}
;********************************************
;*                                          *
;********************************************
atom setmbr6()
{
	plmember6:Set[${Me.DTarget}]
} 
;********************************************
function groupup()
{
	if ${Me.GroupInvitePending}
	{
	vgexecute /groupacceptinvite
	}

} 
;********************************************
function tradeup()
{
	if ${Trade.State.Equal[INVITE_PENDING]} 
	{
	Trade:AcceptInvite 
	}
	if ${Trade.OtherAcceptedOffer}
	{
	Trade:AcceptOffer 
	}
} 

;********************************************     
function Dist_Check()
{
	if ${autofollow}
	{
	if ${Pawn[${assistMember1}].Distance} > ${FollowDist} && ${autofollow} && ${Pawn[${assistMember1}].Distance} < 200
		{
		call movetoobject ${Pawn[${assistMember1}].ID} ${FollowDist} 0
		}
	;if ${Pawn[${assistMember1}].IsMounted} && !${Me.InCombat}
	;	{
	;	}
	return
	}
}
;********************************************
function assist()
{
	if ${assistm} && ${Pawn[${assistMember1}].Distance} < 50
	{
	VGExecute /assist ${assistMember1}
	return
	}
}
;********************************************
function shouldimount()
{
	if ${mountup} && !${Pawn[${myname}].IsMounted} && ${Pawn[${assistMember1}].IsMounted} && !${Me.InCombat}
	{
	Me.Inventory[${mymount}]:Use
	call MeCasting
	}
}
;********************************************
function facemob()
{
	if ${facem}
	{
	call assist
	if ${Me.Target.ID(exists)} && ${Me.TargetHealth} > 0
		{
		face ${Me.Target.X} ${Me.Target.Y}
		}
	}

}
;********************************************
function movetomelee()
{
	if ${movetot}
	{
		call assist
		if ${Me.Target(exists)} && ${Me.Target.IsDead} && ${Me.Encounter} == 0 && ${Pawn[${assistMember1}].CombatState} < 1
		{
		call loot
		return
		}	
		if ${Pawn[${Me.Target}].Distance} > 4 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 100 && ${Me.TargetHealth} < ${mtotpct} && ${Pawn[${assistMember1}].CombatState} > 0
		{
			call assist
			call movetoobject ${Pawn[${Me.Target}].ID} 4 0
			while ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
				{
					Face
					VG:ExecBinding[movebackward]
					wait 1
					VG:ExecBinding[movebackward,release]
				}
		return
		}
		if ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1 && ${Me.TargetHealth} > 0 && ${Pawn[${Me.Target}].Distance} < 100 && ${Me.TargetHealth} < ${mtotpct} && ${Pawn[${assistMember1}].CombatState} > 0
				{
					Face
					VG:ExecBinding[movebackward]
					wait 1
					VG:ExecBinding[movebackward,release]
				}
		if ${Pawn[${Me.Target}].Distance} > 4 && ${Me.TargetHealth} > ${mtotpct}
		{
			return
		}
	return
	}
}
;********************************************
function Harv()
{
	if ${aharv}
	{
	call assist
	if (${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance} > 5 && ${Me.Target.Distance} < 15
	{
		call movetoobject ${Pawn[${Me.Target}].ID} 4 0
		while ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 1
			{
			Face
			VG:ExecBinding[movebackward]
			wait 1
			VG:ExecBinding[movebackward,release]
			}
		return
	}
	if (${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<5 && ${Pawn[${assistMember1}].CombatState} > 0
		{
		VGExecute /autoattack
		wait 10
		}
	}
}
;********************************************
function loot()
{
	if ${lootit}
	{
	call assist
	if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.ContainsLoot} && ${Pawn[${Me.Target}].Distance} < 6
			{
			wait 10
			VGExecute "/lootall"
			wait 10
			VGExecute "/cleartargets"
			} 	
	return
	}
}
;********************************************
function restup()
{
	if ${restandfood} 
	{
	if ${Me.Target(exists)} && (${Me.Target.IsDead} || ${Me.Target.Type.Equal[Corpse]}) && ${Me.EnergyPct} < 99
	{
	VGExecute /cleartarget
	wait 10
	Me.Inventory[${egg}]:Use
	while ${Me.HealthPct} <= 80 || ${Me.EnergyPct} <=90
				{
      				wait 1
				echo waiting
      				}
	VGExecute /stand
	}
	}
}
; ***********************************************
function MeCasting()
{
	;Sub to wait till casting is complete before running the next command
	wait 3

	while ${Me.IsCasting}
	{
		wait 3
	}

	while ${VG.InGlobalRecovery}
	{
		wait 3
	}

	while ${Me.ToPawn.IsStunned}
	{
		wait 3
	}

	return
}
;********************************************
function smallhealrt()
{
	if ${Me.Ability[${smallheal}].IsReady}
	{
	Me.Ability[${smallheal}]:Use
	Call MeCasting
	}
}
;********************************************
function bighealrt()
{
	if ${Me.Ability[${bigheal}].IsReady}
	{
	Me.Ability[${bigheal}]:Use
	Call MeCasting
	}
	elseif ${Me.Ability[${fastheal}].IsReady}
	{
	Me.Ability[${fastheal}]:Use
	Call MeCasting
	}
	return
}

;********************************************
function fasthealrt()
{
	Me.Ability[${fastheal}]:Use
	Call MeCasting
	return
}
;********************************************
function powerleveldebuff()
{
	if ${pldebuff}
	{
		call assist
		if ${Pawn[${Me.Target}].Distance} > 1 && ${Me.TargetHealth} > 40 && ${Pawn[${Me.Target}].Distance} < 25 && ${Me.TargetHealth} < ${mtotpct} && ${Pawn[${assistMember1}].CombatState} > 0
		{
			if !${Me.TargetDebuff[${pldebuff1}](exists)}
				{
				Me.Ability[${pldebuff1}]:Use
				Call MeCasting
				return
				}
			elseif !${Me.TargetDebuff[${pldebuff2}](exists)}
				{
				Me.Ability[${pldebuff2}]:Use
				Call MeCasting
				return
				}
		}
	}
}
;********************************************
function healgroup1()
{
	if !${plmode}
	{
	if ${rhgrp1} && ${Group[1].Health} > 0
		{
		if ${Group[1].Health} < ${rhgrp1pct} && ${Group[1].Health} > ${rhgrp1pct2} 
			{
			Pawn[${Group[1]}]:Target
			call smallhealrt
			}
		}
	if ${fhgrp1} && ${Group[1].Health} > 0
		{
		if ${Group[1].Health} < ${fhgrp1pct} && ${Group[1].Health} > ${fhgrp1pct2} 
			{
			Pawn[${Group[1]}]:Target
			call fasthealrt
			}
		}
	if ${bhgrp1} && ${Group[1].Health} > 0
		{
		if ${Group[1].Health} < ${bhgrp1pct} && ${Group[1].Health} > ${bhgrp1pct2} 
			{
			Pawn[${Group[1]}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Group[1]}].IsDead} && !${Me.InCombat} && ${Group[1].Distance} < 20
		{ 
			Pawn[${Group[1]}]:Target
			wait 2
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
	elseif ${plmode} && ${plmember1.Length} > 3
	{
	Pawn[${plmember1}]:Target
	wait 7
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${rhgrp1pct} && ${Me.DTargetHealth} > ${rhgrp1pct2} 
			{
			Pawn[${plmember1}]:Target
			call smallhealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${fhgrp1pct} && ${Me.DTargetHealth} > ${fhgrp1pct2} 
			{
			Pawn[${plmember1}]:Target
			call fasthealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${bhgrp1pct} && ${Me.DTargetHealth} > ${bhgrp1pct2} 
			{
			Pawn[${plmember1}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Me.DTarget}].IsDead} && !${Me.InCombat} && ${Pawn[${Me.DTarget}].Distance} < 20
		{ 
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
}
;********************************************
function healgroup2()
{
	if !${plmode}
	{
	if ${rhgrp2} && ${Group[2].Health} > 0
		{
		if ${Group[2].Health} < ${rhgrp2pct} && ${Group[2].Health} > ${rhgrp2pct2} 
			{
			Pawn[${Group[2]}]:Target
			call smallhealrt
			}
		}
	if ${fhgrp2} && ${Group[2].Health} > 0
		{
		if ${Group[2].Health} < ${fhgrp2pct} && ${Group[2].Health} > ${fhgrp2pct2} 
			{
			Pawn[${Group[2]}]:Target
			call fasthealrt
			}
		}
	if ${bhgrp2} && ${Group[2].Health} > 0
		{
		if ${Group[2].Health} < ${bhgrp2pct} && ${Group[2].Health} > ${bhgrp2pct2} 
			{
			Pawn[${Group[2]}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Group[2]}].IsDead} && !${Me.InCombat} && ${Group[2].Distance} < 20
		{ 
			Pawn[${Group[2]}]:Target
			wait 2
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
	elseif ${plmode} && ${plmember2.Length} > 3
	{
	Pawn[${plmember2}]:Target
	wait 7
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${rhgrp2pct} && ${Me.DTargetHealth} > ${rhgrp2pct2} 
			{
			Pawn[${plmember2}]:Target
			call smallhealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${fhgrp2pct} && ${Me.DTargetHealth} > ${fhgrp2pct2} 
			{
			Pawn[${plmember2}]:Target
			call fasthealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${bhgrp2pct} && ${Me.DTargetHealth} > ${bhgrp2pct2} 
			{
			Pawn[${plmember2}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Me.DTarget}].IsDead} && !${Me.InCombat} && ${Pawn[${Me.DTarget}].Distance} < 20
		{ 
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
}
;********************************************
function healgroup3()
{
	if !${plmode}
	{
	if ${rhgrp3} && ${Group[3].Health} > 0
		{
		if ${Group[3].Health} < ${rhgrp3pct} && ${Group[3].Health} > ${rhgrp3pct2} 
			{
			Pawn[${Group[3]}]:Target
			call smallhealrt
			}
		}
	if ${fhgrp3} && ${Group[3].Health} > 0
		{
		if ${Group[3].Health} < ${fhgrp3pct} && ${Group[3].Health} > ${fhgrp3pct2} 
			{
			Pawn[${Group[3]}]:Target
			call fasthealrt
			}
		}
	if ${bhgrp3} && ${Group[3].Health} > 0
		{
		if ${Group[3].Health} < ${bhgrp3pct} && ${Group[3].Health} > ${bhgrp3pct2} 
			{
			Pawn[${Group[3]}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Group[3]}].IsDead} && !${Me.InCombat} && ${Group[3].Distance} < 20
		{ 
			Pawn[${Group[3]}]:Target
			wait 2
			Me.Ability[${nocombatres}]:Use
			wait 20
			return
		}
	}
	elseif ${plmode} && ${plmember3.Length} > 3
	{
	Pawn[${plmember3}]:Target
	wait 7
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${rhgrp3pct} && ${Me.DTargetHealth} > ${rhgrp3pct3} 
			{
			Pawn[${plmember3}]:Target
			call smallhealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${fhgrp3pct} && ${Me.DTargetHealth} > ${fhgrp3pct3} 
			{
			Pawn[${plmember3}]:Target
			call fasthealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${bhgrp3pct} && ${Me.DTargetHealth} > ${bhgrp3pct3} 
			{
			Pawn[${plmember3}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Me.DTarget}].IsDead} && !${Me.InCombat} && ${Pawn[${Me.DTarget}].Distance} < 20
		{ 
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
}
;********************************************
function healgroup4()
{	
	if !${plmode}
	{
	if ${rhgrp4} && ${Group[4].Health} > 0
		{
		if ${Group[4].Health} < ${rhgrp4pct} && ${Group[4].Health} > ${rhgrp4pct2} 
			{
			Pawn[${Group[4]}]:Target
			call smallhealrt
			}
		}
	if ${fhgrp4} && ${Group[4].Health} > 0
		{
		if ${Group[4].Health} < ${fhgrp4pct} && ${Group[4].Health} > ${fhgrp4pct2} 
			{
			Pawn[${Group[4]}]:Target
			call fasthealrt
			}
		}
	if ${bhgrp4} && ${Group[4].Health} > 0
		{
		if ${Group[4].Health} < ${bhgrp4pct} && ${Group[4].Health} > ${bhgrp4pct2} 
			{
			Pawn[${Group[4]}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Group[4]}].IsDead} && !${Me.InCombat} && ${Group[4].Distance} < 20
		{ 
			Pawn[${Group[4]}]:Target
			wait 2
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
	elseif ${plmode} && ${plmember4.Length} > 3
	{
	Pawn[${plmember4}]:Target
	wait 7
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${rhgrp4pct} && ${Me.DTargetHealth} > ${rhgrp4pct4} 
			{
			Pawn[${plmember4}]:Target
			call smallhealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${fhgrp4pct} && ${Me.DTargetHealth} > ${fhgrp4pct4} 
			{
			Pawn[${plmember4}]:Target
			call fasthealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${bhgrp4pct} && ${Me.DTargetHealth} > ${bhgrp4pct4} 
			{
			Pawn[${plmember4}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Me.DTarget}].IsDead} && !${Me.InCombat} && ${Pawn[${Me.DTarget}].Distance} < 20
		{ 
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
}
;********************************************
function healgroup5()
{
	if !${plmode}
	{
	if ${rhgrp5} && ${Group[5].Health} > 0
		{
		if ${Group[5].Health} < ${rhgrp5pct} && ${Group[5].Health} > ${rhgrp5pct2} 
			{
			Pawn[${Group[5]}]:Target
			call smallhealrt
			}
		}
	if ${fhgrp5} && ${Group[5].Health} > 0
		{
		if ${Group[5].Health} < ${fhgrp5pct} && ${Group[5].Health} > ${fhgrp5pct2} 
			{
			Pawn[${Group[5]}]:Target
			call fasthealrt
			}
		}
	if ${bhgrp5} && ${Group[5].Health} > 0
		{
		if ${Group[5].Health} < ${bhgrp5pct} && ${Group[5].Health} > ${bhgrp5pct2} 
			{
			Pawn[${Group[5]}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Group[5]}].IsDead} && !${Me.InCombat} && ${Group[5].Distance} < 20
		{ 
			Pawn[${Group[5]}]:Target
			wait 2
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
	elseif ${plmode} && ${plmember5.Length} > 3
	{
	Pawn[${plmember5}]:Target
	wait 7
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${rhgrp5pct} && ${Me.DTargetHealth} > ${rhgrp5pct5} 
			{
			Pawn[${plmember5}]:Target
			call smallhealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${fhgrp5pct} && ${Me.DTargetHealth} > ${fhgrp5pct5} 
			{
			Pawn[${plmember5}]:Target
			call fasthealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${bhgrp5pct} && ${Me.DTargetHealth} > ${bhgrp5pct5} 
			{
			Pawn[${plmember5}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Me.DTarget}].IsDead} && !${Me.InCombat} && ${Pawn[${Me.DTarget}].Distance} < 20
		{ 
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
}
;********************************************
function healgroup6()
{
	if !${plmode}
	{
	if ${rhgrp6} && ${Group[6].Health} > 0
		{
		if ${Group[6].Health} < ${rhgrp6pct} && ${Group[6].Health} > ${rhgrp6pct2} 
			{
			Pawn[${Group[6]}]:Target
			call smallhealrt
			}
		}
	if ${fhgrp6} && ${Group[6].Health} > 0
		{
		if ${Group[6].Health} < ${fhgrp6pct} && ${Group[6].Health} > ${fhgrp6pct2} 
			{
			Pawn[${Group[6]}]:Target
			call fasthealrt
			}
		}
	if ${bhgrp6} && ${Group[6].Health} > 0
		{
		if ${Group[6].Health} < ${bhgrp6pct} && ${Group[6].Health} > ${bhgrp6pct2} 
			{
			Pawn[${Group[6]}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Group[6]}].IsDead} && !${Me.InCombat} && ${Group[6].Distance} < 20
		{ 
			Pawn[${Group[6]}]:Target
			wait 2
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
	elseif ${plmode} && ${plmember6.Length} > 3
	{
	Pawn[${plmember6}]:Target
	wait 7
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${rhgrp6pct} && ${Me.DTargetHealth} > ${rhgrp6pct6} 
			{
			Pawn[${plmember6}]:Target
			call smallhealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${fhgrp6pct} && ${Me.DTargetHealth} > ${fhgrp6pct6} 
			{
			Pawn[${plmember6}]:Target
			call fasthealrt
			}
		}
	if ${Me.DTargetHealth} > 0
		{
		if ${Me.DTargetHealth} < ${bhgrp6pct} && ${Me.DTargetHealth} > ${bhgrp6pct6} 
			{
			Pawn[${plmember6}]:Target
			call bighealrt
			}
		}
	if ${Pawn[${Me.DTarget}].IsDead} && !${Me.InCombat} && ${Pawn[${Me.DTarget}].Distance} < 20
		{ 
			Me.Ability[${nocombatres}]:Use
			Call MeCasting
			return
		}
	}
}


;********************************************
function preinterface()
{
  myname:Set[${Me}]
  myclass:Set[${Me.Class}]	
  nonecasting:Set[None]
  
  mymount:Set[${Me.Inventory[CurrentEquipSlot,Mount]}]
  If ${Me.Class.Equal[Blood Mage]} || ${Me.Class.Equal[Cleric]} || ${Me.Class.Equal[Disciple]} || ${Me.Class.Equal[Shaman]}
	{
	iamahealer:Set[TRUE]
	}
  If ${Me.Class.Equal[necromancer]}
   {
     HowManyDots:Set[4]
     HowManyNukes:Set[2]
     HowManyDebuffs:Set[2]
     HowManyCrits:Set[3]
     counterspell1:Set[Annul Magic]
   }
  If ${Me.Class.Equal[cleric]}
   {
     bigheal:Set[${clbigheal}]
     fastheal:Set[${clfastheal}]
     smallheal:Set[${clsmallheal}]
     nocombatres:Set[Resurrect]
   }
  If ${Me.Class.Equal[Disciple]}
   {
     bigheal:Set[${discbigheal}]
     fastheal:Set[${discfastheal}]
     smallheal:Set[${discsmallheal}]
     nocombatres:Set[Reincarnate]
   }
  If ${Me.Class.Equal[Blood Mage]}
   {
     bigheal:Set[${bmbigheal}]
     fastheal:Set[${bmfastheal}]
     smallheal:Set[${bmsmallheal}]
     nocombatres:Set[Awaken]
   }
    If ${Me.Class.Equal[Shaman]}
   {
     bigheal:Set[${shbigheal}]
     fastheal:Set[${shfastheal}]
     smallheal:Set[${shsmallheal}]
     nocombatres:Set[Spirit Call]
   }
 If ${Me.Class.Equal[Rogue]}
   {
	ArcofDaggers:Set[Arc of Daggers IV]
	Backstab:Set[Backstab VI]
	Blackjack:Set[Blackjack III]
	BlindingFlash:Set[Blinding Flash]
	Blindside:Set[Blindside]
	Clout:Set[Clout]
	DeadlyStrike:Set[Deadly Strike III]
	Deter:Set[Deter]
	Drub:Set[Drub V]
	ElusiveMark:Set[Elusive Mark III]
	Fade:Set[Fade]
	FatalStroke:Set[Fatal Stroke III]
	Flee:Set[Flee]
	Hemorrhage:Set[Hemorrhage V]
	Impale:Set[Impale IV]
	KeenEye:Set[Keen Eye V]
	KneeBreak:Set[Knee Break V]
	Lacerate:Set[Lacerate VI]
	LethalStrikes:Set[Lethal Strikes V]
	Ploy:Set[Ploy]
	Quickblade:Set[Quickblade]
	Ravage:Set[Ravage V]
	Relentless:Set[Relentless]
	Revenge:Set[Revenge V]
	Ruin:Set[Ruin III]
	Shank:Set[Shank IV]
	Shiv:Set[Shiv IV]
	SmokeBomb:Set[Smoke Bomb]
	SmokeTrick:Set[Smoke Trick]
	Stalk:Set[Stalk]
	TrickAttack:Set[Trick Attack IV]
	ViciousStrike:Set[Vicious Strike V]
	VitalStrikes:Set[Vital Strikes I]
	WickedStrike:Set[Wicked Strike VI]
	dexscroll:Set[Scroll of Cat's Feet II]
	dexbuff:Set[Cat's Feet II]
	strscroll:Set[Scroll of Bear's Strength I]
	strbuff:Set[Bear's Strength I]
	poison:Set[Scarlet Flame III]
	bleedingbomb:Set[Enflaming Veins Flechette III]
	explosivebomb:Set[Explosive Flechette V]
	eviscerate:Set[eviscerate]
     }
 If ${Me.Class.Equal[Paladin]}
   {
	AegisStrike:Set[Aegis Strike VI]
	BarrierofFaith:Set[Barrier of Faith]
	BladeofVolAnari:Set[Blade of Vol Anari IV]
	BlessingofGloriannsProtection:Set[Blessing of Gloriann's Protection IV]
	BlessingofLife:Set[Blessing of Life III]
	BlessingofVaelion:Set[Blessing of Vaelion II]
	BlessingofVothdar:Set[Blessing of Vothdar V]
	BoonofValus:Set[Boon of Valus V]
	BoonofVolAnari:Set[Boon of Vol Anari III]
	ChampionsMight:Set[Champion's Might VI]
	Contrition:Set[Contrition III]
	Courage:Set[Courage V]
	CryofIllumination:Set[Cry of Illumination II]
	CryofProwess:Set[Cry of Prowess]
	CryofSolace:Set[Cry of Solace IV]
	DenyLife:Set[Deny Life]
	DevoutFoeman:Set[Devout Foeman III]
	DevoutSanctuary:Set[Devout Sanctuary]
	DictumofValus:Set[Dictum of Valus IV]
	Entwine:Set[Entwine III]
	FinalStand:Set[Final Stand]
	Forbiddance:Set[Forbiddance]
	FuryofValus:Set[Fury of Valus]
	GiftofPeace:Set[Gift of Peace III]
	GuardiansAssault:Set[Guardian's Assault IV]
	HammerofJudgment:Set[Hammer of Judgment V]
	HammerofValus:Set[Hammer of Valus VI]
	HealingTouch:Set[Healing Touch VI]
	HolyStrike:Set[Holy Strike VII]
	JudgmentoftheBloodthirsty:Set[Judgment of the Bloodthirsty IV]
	JudgmentoftheEnvious:Set[Judgment of the Envious II]
	JudgmentoftheImpure:Set[Judgment of the Impure IV]
	JudgmentoftheProud:Set[Judgment of the Proud IV]
	JudgmentoftheUnforgiving:Set[Judgment of the Unforgiving]
	JudgmentoftheWrathful:Set[Judgment of the Wrathful II]
	LayingonofHands:Set[Laying on of Hands IV]
	MarshallingCry:Set[Marshalling Cry IV]
	MaulofValus:Set[Maul of Valus IV]
	ParagonofJustice:Set[Paragon of Justice III]
	PrayerofLife:Set[Prayer of Life]
	ProtectorsFury:Set[Protector's Fury IV]
	Retort:Set[Retort III]
	Retribution:Set[Retribution V]
	RighteousSupplication:Set[Righteous Supplication]
	SentinelsBlessing:Set[Sentinel's Blessing IV]
	ShieldofChastening:Set[Shield of Chastening]
	ShieldofGloriann:Set[Shield of Gloriann I]
	ShieldofRebuke:Set[Shield of Rebuke]
	ShieldofResolve:Set[Shield of Resolve]
	ShieldofSolace:Set[Shield of Solace]
	ShiningBeacon:Set[Shining Beacon III]
	Smite:Set[Smite V]
	StrikeofGloriann:Set[Strike of Gloriann III]
	StrokeofConviction:Set[Stroke of Conviction IV]
	StrokeofFervor:Set[Stroke of Fervor III]
	Succor:Set[Succor]
	Sunburst:Set[Sunburst IV]
	Upbraid:Set[Upbraid V]
	Vanquish:Set[Vanquish III]
	VothdarsMightyStrike:Set[Vothdar's Mighty Strike V]
	WingsoftheAvenger:Set[Wings of the Avenger]	
	WrathofVolAnari:Set[Wrath of Vol Anari III]
	Zeal:Set[Zeal]
     }
	If ${Me.Class.Equal[Bard]}
   {
	barddot1:Set[Fasant's Chant of Winter III]
	barddot2:Set[Fasant's Chant of the Flame III]
	barddot3:Set[Fasant's Chant of Corruption III]
	barddot4:Set[Ariezel's Insidious Shriek]
	bardfinisher:Set[Fox Overtakes the Hare III]
	bardmeleedot1:Set[Razor Parts Silk VI]
	bardmelee1:Set[Striking the Mountain VI]
	bardforcecrit:Set[Singing Blade]
	bardmelee2:Set[Sever the Tie VII]
	bardmeleedot2:Set[Thread the Needle V]
	bardcrit1:Set[Hummingbird Darts In VI]
	bardcrit2:Set[Lightning Kisses the Ground V]
	bardcrit3:Set[Hewing the Mountain V]
	bardcrit4:Set[Cleave the Mountain IV]
	bardcrit5:Set[Shatter the Mountain II]
	bardcombatbuff1:Set[BladeDancer's Focus]
	barddeagro:Set[Calming Lullaby]
	barddeagro2:Set[Fence]
     }
	If ${Me.Class.Equal[Sorcerer]}
   {  
	itemtouse:Set[Essal's Staff of Seduction]
	counterspell1:Set[Disperse]
	counterspell2:Set[Reflect]
	dispell1:Set[Disenchant IV]
	AmplifyAcuity:Set[Amplify Acuity]
	AmplifyDestruction:Set[Amplify Destruction]
	AmplifyEfficiency:Set[Amplify Efficiency]
	ArcaneMantle:Set[Arcane Mantle V]
	AsayasInsight:Set[Asaya's Insight III]
	BlindingFire:Set[Blinding Fire II]
	ChaosVolley:Set[Chaos Volley IV]
	Char:Set[Char VI]
	ChromaticBarrier:Set[Chromatic Barrier II]
	ChromaticHalo:Set[Chromatic Halo]
	ColdWave:Set[Cold Wave III]
	ColorSpray:Set[Color Spray III]
	EnergyShard:Set[Conjure Major Energy Shard]
	Ring:Set[Conjure Quicksilver Ring]
	Disenchant:Set[Disenchant IV]
	Disperse:Set[Disperse]
	ElementalMantle:Set[Elemental Mantle IV]
	EnergyRift:Set[Energy Rift VI]
	EtherealSanctuary:Set[Ethereal Sanctuary]
	FireBarrier:Set[Fire Barrier III]
	Fireball:Set[Fireball V]
	FlameSpear:Set[Flame Spear IV]
	ForceBarrier:Set[Force Barrier VII]
	Forget:Set[Forget III]
	Freeze:Set[Freeze IV]
	Frostbite:Set[Frostbite VII]
	GatherEnergy:Set[Gather Energy]
	GhostlySanctuary:Set[Ghostly Sanctuary]
	GlacialSanctuary:Set[Glacial Sanctuary]
	Icequake:Set[Icequake IV]
	Incinerate:Set[Incinerate IV]
	InidriasFrigidBlast:Set[Inidria's Frigid Blast]
	InidriasInferno:Set[Inidria's Inferno III]
	InnerSanctuary:Set[Inner Sanctuary]
	Invisibility:Set[Invisibility]
	MeteorStorm:Set[Meteor Storm]
	Mimic:Set[Mimic VI]
	MirrorWard:Set[Mirror Ward]
	NaturalSanctuary:Set[Natural Sanctuary]
	NullingWard:Set[Nulling Ward]
	Reflect:Set[Reflect]
	SearingSanctuary:Set[Searing Sanctuary]
	SeeInvisibility:Set[See Invisibility]
	SeradonsFallingStar:Set[Seradon's Falling Star III]
	SeradonsVision:Set[Seradon's Vision III]
	ShockingGrasp:Set[Shocking Grasp VI]
	Sleep:Set[Sleep III]
	TaqmirsBarrage:Set[Taqmir's Barrage IV]

     }

}

;********************************************
atom atexit()
{
   
   echo "-- Ending AssistBot --"
   VG:ExecBinding[moveforward,release]
   VG:ExecBinding[movebackward,release]
   Event[AddcounterSpell]:DetachAtom[AddcounterSpell]
   Event[RemoveCounterSpell]:DetachAtom[RemoveCounterSpell]
   Event[Shouldicounter]:DetachAtom[Shouldicounter]
   Event[BuildCounterList]:DetachAtom[BuildCounterList]	
   ui -unload "${Script.CurrentDirectory}/XML/vgassist.xml"
   Settings:Save
   endscript vgassist.iss
	
}   