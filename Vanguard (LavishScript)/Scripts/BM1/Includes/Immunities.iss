;===================================================
;===      IMMUNITIES - do not attack            ====
;===================================================

;; Use these in your scripts
variable bool doArcane = TRUE
variable bool doPhysical = TRUE
variable bool OkayToAttack = FALSE

;-------------------------------------------
; This is an OnFrame event
;-------------------------------------------
atom(script) Immunities()
{
	if ${Me.Target(exists)} && ${Me.TargetHealth(exists)}
	{
		;-------------------------------------------
		; TARGET BUFFS - Ensure you set toggles for each specific target buff
		;-------------------------------------------
		if ${Me.TargetBuff[Electric Form](exists)}
		{
			doArcane:Set[FALSE]
		}
		if ${Me.TargetBuff[Earth Form](exists)}
		{
			doPhysical:Set[FALSE]
		}

		;-------------------------------------------
		; Set IMMUNITY based upon the Target's name
		;-------------------------------------------
		switch "${Me.Target.Name}"
		{
			case Corrupted Essence
				doArcane:Set[FALSE]
				doPhysical:Set[FALSE]
				OkayToAttack:Set[FALSE]
				return

			case Corrupted Residue
				doArcane:Set[FALSE]
				doPhysical:Set[FALSE]
				OkayToAttack:Set[FALSE]
				return

			case Descrier Sentry
				doArcane:Set[FALSE]
				break

			;; sister's event
			case Summoned Air Elemental
				doArcane:Set[FALSE]
				break

			;; sister's event
			case Summoned Earth Elemental
				doPhysical:Set[FALSE]
				break

			case Descrier Psionicist
				doArcane:Set[FALSE]
				break

			case Descrier Dreadwatcher
				doArcane:Set[FALSE]
				break

			case Sub-Warden Mer
				doArcane:Set[FALSE]
				break

			case OVERWARDEN
				doArcane:Set[FALSE]
				break

			case Omac
				doArcane:Set[FALSE]
				break

			case Salrin
				doArcane:Set[FALSE]
				break

			case Bandori
				doArcane:Set[FALSE]
				break

			case Guardian B27
				doArcane:Set[FALSE]
				break

			case Energized Marauder
				doArcane:Set[FALSE]
				break

			case Energized Resonator
				doArcane:Set[FALSE]
				break

			case Electric Elemental
				doArcane:Set[FALSE]
				break

			case Lesser Electric Elemental
				doArcane:Set[FALSE]
				break

			case Greater Electric Elemental
				doArcane:Set[FALSE]
				break

			case Energized Elemental
				doArcane:Set[FALSE]
				break

			case Construct of Lightning
				doArcane:Set[FALSE]
				break

			case Cartheon Wingwraith
				doArcane:Set[FALSE]
				break

			case Source of Arcane Energy
				doArcane:Set[FALSE]
				break

			case Ancient Infector
				doArcane:Set[FALSE]
				break

			case Cartheon Archivist
				doArcane:Set[FALSE]
				break

			case Cartheon Arcanist
				doArcane:Set[FALSE]
				break

			case Cartheon Scholar
				doArcane:Set[FALSE]
				break

			case Eyelord Seeker
				doArcane:Set[FALSE]
				break

			case Mechanized Stormsuit
				doArcane:Set[FALSE]
				break

			case Belzane
				;; this mob creates random immunities
				doArcane:Set[FALSE]
				break

			case Wing Grafted Slasher
				doPhysical:Set[FALSE]
				break

			case Enraged Death Hound
				doPhysical:Set[FALSE]
				break

			case Lesser Flarehound
				doPhysical:Set[FALSE]
				break

			case Lirikin
				doPhysical:Set[FALSE]
				break

			case Nathrix
				doPhysical:Set[FALSE]
				break

			case Shonaka
				doPhysical:Set[FALSE]
				break

			case Wisil
				doPhysical:Set[FALSE]
				break

			case Filtha
				doPhysical:Set[FALSE]
				break

			case SILIUSAURUS
				doPhysical:Set[FALSE]
				break

			case ARCHON TRAVIX
				doPhysical:Set[FALSE]
				break

			case Earthen Marauder
				doPhysical:Set[FALSE]
				break

			case Earthen Resonator
				doPhysical:Set[FALSE]
				break

			case Cartheon Devourer
				doPhysical:Set[FALSE]
				break

			case Rock Elemental
				doPhysical:Set[FALSE]
				break

			case Cartheon Soulslasher
				doPhysical:Set[FALSE]
				break

			case Cartheon Abomination
				doPhysical:Set[FALSE]
				break

			case Glowing Infineum
				doPhysical:Set[FALSE]
				break

			case Living Infineum
				doPhysical:Set[FALSE]
				break

			case Spawn of Infineum
				doPhysical:Set[FALSE]
				break

			case Myconid Fungal Ravager
				doPhysical:Set[FALSE]
				break

			case Xakrin Sage
				doPhysical:Set[FALSE]
				break

			case Hound of Rahz
				doPhysical:Set[FALSE]
				break

			case Ancient Juggernaut
				doPhysical:Set[FALSE]
				break

			case Mechanized Pyromaniac
				;doPhysical:Set[FALSE]
				break

			case Xakrin Razarclaw
				doPhysical:Set[FALSE]
				break

			case Assaulting Death Hound
				doPhysical:Set[FALSE]
				break

			case Blood-crazed Ettercap
				doPhysical:Set[FALSE]
				break

			case Flarehound
				doPhysical:Set[FALSE]
				break

			case Lixirikin
				doPhysical:Set[FALSE]
				break

			case Flarehound Watcher
				doPhysical:Set[FALSE]
				break

			case Nefarious Titan
				doPhysical:Set[FALSE]
				break

			case Nefarious Elemental
				doPhysical:Set[FALSE]
				break

			case Enraged Convocation
				doPhysical:Set[FALSE]
				break

			Default
				break
		}

		;-------------------------------------------
		; We are done setting immunities, now say we are okay to attack
		;-------------------------------------------
		OkayToAttack:Set[TRUE]
		
	}
	else
	{
		;-------------------------------------------
		; reset immunities based on what is checked in our UI
		;-------------------------------------------
		doPhysical:Set[${UIElement[doPhysical@Main@Tabs@BM1].Checked}]
		doArcane:Set[${UIElement[doArcane@Main@Tabs@BM1].Checked}]
		OkayToAttack:Set[FALSE]
	}
}

