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

function FindLowestHealth()
{
	;-------------------------------------------
	; Find lowest member's health that's below 90% 
	;-------------------------------------------
	if ${Me.IsGrouped}
	{
		gn:Set[0]
		low:Set[90]
		for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
		{
			;echo "gn=${i}, name=[${Group[${i}].Health.Int}]${Group[${i}].Name}, low=${low}, MyHealth=${Me.HealthPct}"

			;-------------------------------------------
			;No matter what, if Tank's health is below 40% then heal them 1st
			;-------------------------------------------
			if ${Group[${i}].Name.Equal[${Tank}]} && ${Group[${i}].Health}<60
			{
				gn:Set[${i}]
				low:Set[${Group[${i}].Health}]
				break
			}

			;-------------------------------------------
			;Fixed bug that reports your health is 100% some of the time
			;-------------------------------------------
			if ${Group[${i}].Name.Equal[${Me.FName}]} && ${Me.HealthPct}<${low}
			{
				gn:Set[${i}]
				low:Set[${Me.HealthPct}]
			}

			;-------------------------------------------
			;Heal only those defined by variable GHx
			;-------------------------------------------
			if ${GroupHeal}
			{
				if ${Group[${i}].Name.Find[${GH1}]} || ${Group[${i}].Name.Find[${GH2}]} || ${Group[${i}].Name.Find[${GH3}]} || ${Group[${i}].Name.Find[${GH4}]} || ${Group[${i}].Name.Find[${GH5}]} || ${Group[${i}].Name.Find[${GH6}]} || ${Group[${i}].Name.Find[${GH7}]} || ${Group[${i}].Name.Find[${GH8}]} || ${Group[${i}].Name.Find[${Tank}]}
				{
					if ${Group[${i}].Distance}<26 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
					{
						gn:Set[${i}]
						low:Set[${Group[${i}].Health}]
					}
				}
			}
			elseif !${GroupHeal}
			{
				if ${Group[${i}].Distance}<26 && ${Group[${i}].Health}>0 && ${Group[${i}].Health}<${low}
				{
					gn:Set[${i}]
					low:Set[${Group[${i}].Health}]
				}
			}
		}
		;if ${gn}>0
		;{
		;	echo "[${Time}][VG:BM] --> gn=${gn}, name=${Group[${gn}].Name}, low=${low}, MyHealth=${Me.HealthPct} -- Final Result"
		;}
		;elseif ${gn}==0
		;	echo "[${Time}][VG:BM] --> gn=${gn}, everyone's health is above 90% -- Final Result"
			
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
	}

	;-------------------------------------------
	; Set DTarget to Offensive's Target if nobody is below AttackHealRatio health
	;-------------------------------------------
	if ${Me.InCombat} && ${Me.Target.Distance}<50 && ${low}>${AttackHealRatio}
	{
		VGExecute /assistoffensive
	}
}