/*
===============================================
===============================================
 COMMON ROUTINES SHARED AND USED BY ALL CLASSES
===============================================
===============================================
 */
 
/*
FindLowestHealth v1.1
by:  Zandros, 27 Jan 2009

Description:
This will find the member with the lowest health, 
sets DTarget if less than variable AttackHealRatio, and sets
the following variables which you can use in your routines:

gn = Group Number (0 means none)
low = Health Percent (lowest member's health including your own)
 */

;; Variables used 
variable int gn
variable int low

;; toggle this if you want to heal only members in your group
variable bool GroupHeal = FALSE 

function FindLowestHealth()
{
	;-------------------------------------------
	; Find lowest member's health that's below 90% 
	;-------------------------------------------
	if ${Me.IsGrouped}
	{
		;; Set our variables
		gn:Set[0]
		low:Set[90]
		
		;; Scan everyone
		if !${GroupHeal}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Group[${i}].Distance}<26 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
				{
					gn:Set[${i}]
					low:Set[${Group[${i}].Health}]
				}
			}
		}
		;; Scan only those we want
		if ${GroupHeal}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${GroupMemberList.Element["${Group[${i}].Name}"](exists)}
				{
					if ${Group[${i}].Distance}<26 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
					{
						gn:Set[${i}]
						low:Set[${Group[${i}].Health}]
					}
				}
			}
		}
	}

	;-------------------------------------------
	; Set low to your health if not in a group
	;-------------------------------------------
	if !${Me.IsGrouped}
	{
		gn:Set[0]
		low:Set[${Me.HealthPct}]
	}

	;-------------------------------------------
	; Set DTarget to anyone's health below AttackHealRatio 
	;-------------------------------------------
	if ${low}<${AttackHealRatio}
	{
		if !${Me.IsGrouped}
			Pawn[me]:Target
		if ${Me.IsGrouped}
			Pawn[id,${Group[${gn}].ID}]:Target
		wait 1
	}

	;-------------------------------------------
	; Set DTarget to Offensive's Target if nobody is below AttackHealRatio health
	;-------------------------------------------
	if ${Me.IsGrouped} && ${Me.InCombat} && ${Me.Target.Distance}<50 && ${gn}==0
	{
		VGExecute /assistoffensive
	}
	
	;if ${gn}>0
	;{
	;	echo "[${Time}][VG:BM] --> FindLowestHealth:  gn=${gn}, name=${Group[${gn}].Name}, low=${low}, MyHealth=${Me.HealthPct} -- Final Result"
	;}
	;elseif ${gn}==0
	;	echo "[${Time}][VG:BM] --> gn=${gn}, everyone's health is above 90% -- Final Result"
}