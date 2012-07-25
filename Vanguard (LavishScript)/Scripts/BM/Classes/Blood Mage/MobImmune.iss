/* MobImmune v1.0 by Zandros, 27 Jan 2009

Description:
Return TRUE or FALSE if target is immune to a type of ability you are about to use

parameters:
ABILITY = Any ability (spell) you are about to use

Example Code: 
call MobImmune "Union of Blood I"
if ${Return}
	"mob is immune"

External Routines that must be in your program:  None
*/

/* Toggle this on or off in your scripts to overide */
variable bool doArcane = TRUE
variable bool doPhysical = TRUE

;===================================================
;===      Known Mobs with Immunities            ====
;===================================================
function:bool MobImmune(string ABILITY)
{
	if  ${Me.Ability[${ABILITY}].School.Find[Arcane]} 
	{
		if !${doArcane}
		{
			return TRUE
		}
		if ${Me.Target.Name.Find[Energized Marauder]}
			return TRUE
		if ${Me.Target.Name.Find[Energized Resonator]}
			return TRUE
		if ${Me.Target.Name.Find[Energized Elemental]}
			return TRUE
		if ${Me.Target.Name.Equal[Construct of Lightning]}
			return TRUE
		if ${Me.Target.Name.Equal[Salrin]}
			return TRUE
		if ${Me.Target.Name.Find[Bandori]}
			return TRUE
		if ${Me.Target.Name.Equal[Cartheon Wingwraith]}
			return TRUE
		if ${Me.Target.Name.Find[Sage]}
			return TRUE
		if ${Me.Target.Name.Equal[Omac]}
			return TRUE
		if ${Me.Target.Name.Equal[Ancient Infector]}
			return TRUE
		if ${Me.Target.Name.Find[Eyelord]}
			return TRUE
		if ${Me.Target.Name.Equal[Ancient Infector]}
			return TRUE
		if ${Me.Target.Name.Equal[Cartheon Archivist]}
			return TRUE
		if ${Me.Target.Name.Equal[Cartheon Scholar]}
			return TRUE
		if ${Me.Target.Name.Find[Stormsuit]}
			return TRUE
		return FALSE
	}
	if ${Me.Ability[${ABILITY}].School.Find[Physical]}
	{
		if !${doPhysical}
		{
			return TRUE
		}
		if ${Me.Target.Name.Find[Earthen Marauder]}
			return TRUE
		if ${Me.Target.Name.Find[Earthen Resonator]}
			return TRUE
		if ${Me.Target.Name.Equal[SUMMONER RINIPIN]}
			return TRUE
		if ${Me.Target.Name.Equal[Cartheon Devourer]}
			return TRUE
		if ${Me.Target.Name.Equal[ARCHON TRAVIX]}
			return TRUE
		if ${Me.Target.Name.Find[Earth Elemental]}
			return TRUE
		if ${Me.Target.Name.Find[Rock Elemental]}
			return TRUE
		if ${Me.Target.Name.Equal[Cartheon Soulslasher]}
			return TRUE
		if ${Me.Target.Name.Equal[Cartheon Abomination]}
			return TRUE
		if ${Me.Target.Name.Find[Ettercap]}
			return TRUE
		if ${Me.Target.Name.Equal[Wisil]}
			return TRUE
		if ${Me.Target.Name.Equal[Filtha]}
			return TRUE
		if ${Me.Target.Name.Equal[Myconid Fungal Ravager]}
			return TRUE
		if ${Me.Target.Name.Equal[Xakrin Sage]}
			return TRUE
		if ${Me.Target.Name.Equal[Lixirikin]}
			return TRUE
		if ${Me.Target.Name.Equal[Nathrix]}
			return TRUE
		if ${Me.Target.Name.Equal[Shonaka]}
			return TRUE
		if ${Me.Target.Name.Find[SILIUSAURUS]}
			return TRUE
		if ${Me.Target.Name.Equal[Enraged Death Hound]}
			return TRUE
		if ${Me.Target.Name.Equal[Hound of Rahz]}
			return TRUE
		if ${Me.Target.Name.Equal[Ancient Juggernaut]}
			return TRUE
		if ${Me.Target.Name.Equal[Mechanized Pyromaniac]}
			return TRUE
		if ${Me.Target.Name.Equal[Lesser Flarehound]}
			return TRUE
		if ${Me.Target.Name.Equal[Xakrin Razarclaw]}
			return TRUE
		if ${Me.Target.Name.Equal[Assaulting Death Hound]}
			return TRUE
		return FALSE
	}
	return FALSE
}

/* IMMUNITY */
function Immunities()
{
	;-------------------------------------------
	; No Target then report No immunities
	;-------------------------------------------
	if !${Me.Target(exists)} || ${VG.InGlobalRecovery}>0
	{
		Immunity:Set[None]
		return
	}

	;-------------------------------------------
	; Checking for Arcane
	;-------------------------------------------
	call MobImmune "Despoil I"
	if ${Return}
	{
		Immunity:Set[Arcane]
		return
	}

	;-------------------------------------------
	; Checking for Physical
	;-------------------------------------------
	call MobImmune "Union of Blood I"
	if ${Return}
	{
		Immunity:Set[Physical]
		return
	}

	;-------------------------------------------
	; If it gets this far then No Immunities
	;-------------------------------------------
	Immunity:Set[None]
}
