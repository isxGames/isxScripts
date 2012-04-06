variable(global) int StartingCoin
variable(global) int GainedCoin
variable(global) int CurrentCoin

function main()
{
	StartingCoin:Set[${Math.Calc[(${Me.Platinum}*1000000)+(${Me.Gold}*10000)+(${Me.Silver}*100)+${Me.Copper}]}]
;//	echo StartingCoin: ${StartingCoin}
	
	while 1
	{
		CurrentCoin:Set[${Math.Calc[(${Me.Platinum}*1000000)+(${Me.Gold}*10000)+(${Me.Silver}*100)+${Me.Copper}]}]
;//		echo CurrentCoin: ${CurrentCoin}
		GainedCoin:Set[${Math.Calc[${CurrentCoin}-${StartingCoin}]}]
;//		echo GainedCoin: ${GainedCoin}
		
		DisplayCopper:Set[${Math.Calc[${GainedCoin}%100]}]
		DisplaySilver:Set[${Math.Calc[${GainedCoin}/100%100]}]
		DisplayGold:Set[${Math.Calc[${GainedCoin}/10000%100]}]
		DisplayPlatinum:Set[${Math.Calc[${GainedCoin}/10000\\100]}]
		
;//		echo P = ${DisplayPlatinum.LeadingZeroes[2]} G = ${DisplayGold.LeadingZeroes[2]} S = ${DisplaySilver.LeadingZeroes[2]} C = ${DisplayCopper.LeadingZeroes[2]}
	}	
}
