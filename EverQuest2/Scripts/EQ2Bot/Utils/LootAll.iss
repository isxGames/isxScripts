#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/Debug.iss"

function main(uint LootWndID, uint Wait=0)
{
	;; Comment this to disable debug echos throughout
	Debug:Enable
	
	wait ${Wait}

	switch ${LootWindow[${LootWndID}].Type}
	{
		case Lottery
			if ${LootThisAlways}
				LootWindow[${LootWndID}]:RequestAll
			elseif ${deccnt}
				LootWindow[${LootWndID}]:DeclineLotto
			else
				LootWindow[${LootWndID}]:RequestAll
			break
		case Free For All
			if ${LootThisAlways}
				LootWindow[${LootWndID}]:LootAll
			if ${deccnt}
				LootWindow[${LootWndID}]:DeclineLotto
			else
				LootWindow[${LootWndID}]:LootAll
			break
		case Need Before Greed
			if ${LootThisAlways}
				LootWindow[${LootWndID}]:SelectNeed
			if ${deccnt}
				LootWindow[${LootWndID}]:DeclineNBG
			else
				LootWindow[${LootWndID}]:SelectGreed
			break
		case Unknown
		Default
			Debug:Echo["LootAll[EQ2Bot]:: Unknown LootWindow Type found: ${LootWindow[${LootWndID}].Type}"]
			break
	}
}