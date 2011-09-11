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

		;; update our group members
		case FindGroupMembers
			call FindGroupMembers
			break

		;; turn on/off attacks, toggle sprinting, execute crits
		Default
			call SprintCheck
			if ${Me.InCombat}
			{
				call MeleeAttackOn
				if ${OkayToAttack}
				{
					if ${Me.Target(exists)}
					{
						if ${Me.TargetHealth}<=${StartAttack}
						{
							if ${Me.Target.Type.Equal[NPC]} || ${Me.Target.Type.Equal[AggroNPC]}
							{
								if ${Me.Target.Distance}<30 && ${Me.Target.HaveLineOfSightTo} && !${Me.Target.IsDead}
								{
									call CritFinishers
								}
							}
						}
					}
				}
			}
			break
	}
}


