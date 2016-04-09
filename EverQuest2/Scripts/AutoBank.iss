function main()
{
        
 	Actor[nokillnpc]:DoTarget
        wait 1
        Target:DoFace
        wait 1
        Target:DoubleClick
        wait 1
	Me:BankDeposit[p,${Me.Platinum}]
	Me:BankDeposit[g,${Me.Gold}]
	Me:BankDeposit[s,${Me.Silver}]
	Me:BankDeposit[c,${Me.Copper}]
	Me:BankWithdraw[p,${Me.Platinum}]
	Me:BankWithdraw[g,${Me.Gold}]
}