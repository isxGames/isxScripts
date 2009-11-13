/* BLOOD MAGE BUFFS

Description:  Always get Blood Feast up; then Constructs, 
then All-In-One Buffs, then individual Buffs

Note to self:  Something fishy going on with VG - lol
*/  

/* BLOOD MAGE BUFFS */
function:bool Buffs()
{
	;; Always get Blood Feast up and running
	call UseAbility "${BloodFeast}"
	if ${Return}
		return TRUE
	
	; Make sure we pass our checks
	if ${Me.InCombat} || ${isPaused} || !${doBuffs}
		return FALSE

	;; This overrides all buffs 
	;; -- cast it or return if already have
	if ${Me.Ability[Construct's Augmentation](exists)} || ${Me.Effect[Construct's Augmentation](exists)}
	{
		if !${Me.Effect[Construct's Augmentation](exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
			Pawn[me]:Target
			waitframe
		}
		call UseAbility "Construct's Augmentation"
		if ${Return}
			return  TRUE
		return FALSE
	}
	
	;; This is a must which is not part of the AllInOneBuff
	call UseAbility "${SeraksMantle}"
	if ${Return}
		return TRUE	

	;; AllInOneBuff does not stack with Construct and overrides all previous buffs
	;; -- cast it or return if already have
	if ${Me.Ability[Favor of the Life Giver](exists)}
	{
		if !${Me.Effect[Serak's Amplification](exists)} || !${Me.Effect[Inspirit](exists)} || !${Me.Effect[Life Graft](exists)} || !${Me.Effect[Mental Stimulation](exists)} || !${Me.Effect[Accelerated Regeneration](exists)} || !${Me.Effect[${CerebralGraft}](exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
			Pawn[me]:Target
			waitframe
			call UseAbility "Favor of the Life Giver"
			if ${Return}
				return  TRUE
		}
		return FALSE
	}

/* ==== The following are your default buffs (No Constructs or AllInOne) ====*/
	
	;; The lame way to target yourself
	if ${Me.Ability[${HealthGraft}](exists)} && !${Me.Effect[${HealthGraft}](exists)}
	{
		if ${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
		}
		Pawn[me]:Target
		wait frame
		call UseAbility "${HealthGraft}"
		if ${Return}
			return TRUE
	}
	if ${Me.Ability[${SeraksAugmentation}](exists)} && !${Me.Effect[${SeraksAugmentation}](exists)}
	{
		if ${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
		}
		Pawn[me]:Target
		wait frame
		call UseAbility "${SeraksAugmentation}"
		if ${Return}
			return TRUE
	}
	if ${Me.Ability[${Vitalize}](exists)} && !${Me.Effect[${Vitalize}](exists)}
	{
		if ${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
		}
		Pawn[me]:Target
		wait frame
		call UseAbility "${Vitalize}"
		if ${Return}
			return TRUE

	}
	if ${Me.Ability[${MentalInfusion}](exists)} && !${Me.Effect[${MentalInfusion}](exists)}
	{
		if ${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
		}
		Pawn[me]:Target
		wait frame
		call UseAbility "${MentalInfusion}"
		if ${Return}
			return TRUE
	}
	if ${Me.Ability[${CerebralGraft}](exists)} && !${Me.Effect[${CerebralGraft}](exists)}
	{
		if ${Me.Target(exists)}
		{
			VGExecute /cleartargets
			wait 20 !${Me.Target(exists)}
		}
		Pawn[me]:Target
		wait frame
		call UseAbility "${CerebralGraft}"
		if ${Return}
			return TRUE
	}
	return FALSE
}

