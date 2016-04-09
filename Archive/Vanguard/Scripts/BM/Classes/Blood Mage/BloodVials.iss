/* CHECK TOTAL BLOOD VIALS 

Description:  Why do I setup a variable than just go the
easy route of using Me.Inventory?  Because it takes a
little over 1.2 seconds to scan the inventory for a 
Blood Vial.
*/  

;; Establish our variable
variable int BloodVials = 0

/* CHECK FOR BLOOD VIALS */
function:bool CheckBloodVials()
{
	if ${Me.InCombat} || ${Me.HealthPct}<90 || ${BloodVials}<4
		return FALSE

	;; Update quantity - Saves 1.2 seconds doing it this way
	BloodVials:Set[${Me.Inventory[Vial of Blood].Quantity}]

	if ${BloodVials}<4
	{
		call UseAbility "Siphon Blood" "Sanguine Focus"
		if ${Return}
		{
			BloodVials:Inc
			return TRUE
		}
	}
	return FALSE
}
