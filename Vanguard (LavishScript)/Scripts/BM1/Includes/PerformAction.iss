;
; The PerformAction routine executes whatever is
; defined by the PerformAction variable
;
function PerformAction()
{
	;-------------------------------------------
	; The variable "PerformAction" is set by
	; the FindAction subroutine
	;-------------------------------------------
	switch "${PerformAction}"
	{
		;; we are dead
		case Paused
			call Paused
			break

		;; we are dead
		case WeAreDead
			call WeAreDead
			break
			
		;; we are harvesting
		case WeAreHarvesting
			call WeAreHarvesting
			break
			
		;; Queued Commands - Find Group Members, Buffs, et cetera
		case QueuedCommand
			call QueuedCommand
			break

		;; target on me
		case TargetOnMe
			call TargetOnMe
			break

		;; go assist the tank
		case AssistTank
			call AssistTank
			break

		;; go assist the OffTank
		case AssistOffTank
			call AssistOffTank
			break

		;; use berries to remove poison
		case RemovePoison
			call RemovePoisons
			break

		;; strip an Enchantment off the target
		case RemoveEnchantment
			call RemoveEnchantments
			break

		;; stop all attacks if target does not exist
		case TargetIsDead
			call TargetIsDead
			break

		;; get some energy
		case RegainEnergy
			call RegainEnergy
			break

		;; we just chunked
		case WeChunked
			call WeChunked
			break

		;; follow player
		case FollowPlayer
			call FollowPlayer
			break

		;; use HoTs, heals, berries, or Blood Mage's ${Conduct}
		case VitalHeals
			call VitalHeals
			break

		;; go attack the current target
		case AttackTarget
			call AttackTarget
			NextAttackCheck:Set[${Script.RunningTime}]
			break

		;; go attack the current target
		case DoNotAttack
			call DoNotAttack
			break

		;; go buff someone that requested
		case BuffRequests
			call BuffRequests
			break

		;; go buff the area
		case BuffArea
			call BuffArea
			break

		;; pass out a requested symbiote
		case SymbioteRequest
			call SymbioteRequest
			break

		;; update our group members
		case FindGroupMembers
			call FindGroupMembers
			break

		;; Accept a Rez
		case RezAccept
			call RezAccept
			break
			
		;; turn on/off attacks, toggle sprinting, execute crits
		Default
			call SprintCheck
			if !${Me.InCombat}
			{
				isFurious:Set[FALSE]

				;; change form to healing form
				if !${Me.CurrentForm.Name.Equal["Sanguine Focus"]} && ${Me.Health}<50
				{
					Me.Form["Sanguine Focus"]:ChangeTo
					wait .5
				}

				;; turn off Blood Feast
				if ${Me.Ability[${BloodFeast}](exists)} && ${Me.Effect[${BloodFeast}](exists)}
				{
					call UseAbility "${BloodFeast}"
				}
			}
			break
	}
}


