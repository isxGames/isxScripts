function merchant()
{
  call Repair
  call Sell
}
 
function Repair()
{
  variable int i = 1
  variable int finishplat
  variable int finishgold
  variable int finishsilver
  variable int finishcopper
  variable int startmoney = ${Me.Copper}
  startmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
  startmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
  startmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
  Merchant:Begin[Repair]
  wait 2

  do
  {
      Merchant.RepairItem[${i}]:Repair
  }
  while (${i:Inc} <= ${Merchant.NumItemsForRepair})
  variable int finishmoney
  finishmoney:Inc[${Me.Copper}]
  finishmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
  finishmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
  finishmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
  variable int diff
  ;finishmoney:Dec
  diff:Set[${startmoney} - ${finishmoney}]
  finishplat:Set[${Math.Abs[${Math.Calc[${diff}/100/100/100]}].Int}]
  diff:Dec[${Math.Abs[${Math.Calc[${finishplat}*100*100*100]}].Int}]
  finishgold:Set[${Math.Abs[${Math.Calc[${diff}/100/100]}].Int}]
  diff:Dec[${Math.Abs[${Math.Calc[${finishgold}*100*100]}].Int}]
  finishsilver:Set[${Math.Abs[${Math.Calc[${diff}/100]}].Int}]
  diff:Dec[${Math.Abs[${Math.Calc[${finishsilver}*100]}].Int}]
  finishcopper:Set[${diff}]
  echo Repairs cost ${finishplat}p ${finishgold}g ${finishsilver}s ${finishcopper}c
  Merchant:End        
}
 
function Sell()
{
  variable int i = 1
  variable int finishplat
  variable int finishgold
  variable int finishsilver
  variable int finishcopper
  variable int startmoney = ${Me.Copper}
  startmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
  startmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
  startmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
  Merchant:Begin[BuySell]
  wait 2

  ; Loop through the inventory, incrementing "i" by one each time until
  ; Me.Inventory[i] isn't valid anymore
  do
{
    if ${doSell}
     {
	variable iterator Iterator
	Sell:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if ${Me.Inventory[${i}].Name.Equal[${Iterator.Key}]}
		{
		Me.Inventory[${i}]:Sell[${Me.Inventory[${i}].Quantity}]
		}
		Iterator:Next
	}
      }
      i:Inc
  }
  while ${Me.Inventory[${i}].ID(exists)} 
  variable int finishmoney
  finishmoney:Inc[${Me.Copper}]
  finishmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
  finishmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
  finishmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
  variable int diff
  diff:Set[${finishmoney} - ${startmoney}]
  finishplat:Set[${Math.Abs[${Math.Calc[${diff}/100/100/100]}].Int}]
  diff:Dec[${Math.Abs[${Math.Calc[${finishplat}*100*100*100]}].Int}]
  finishgold:Set[${Math.Abs[${Math.Calc[${diff}/100/100]}].Int}]
  diff:Dec[${Math.Abs[${Math.Calc[${finishgold}*100*100]}].Int}]
  finishsilver:Set[${Math.Abs[${Math.Calc[${diff}/100]}].Int}]
  diff:Dec[${Math.Abs[${Math.Calc[${finishsilver}*100]}].Int}]
  finishcopper:Set[${diff}]
  echo Items sold for ${finishplat}p ${finishgold}g ${finishsilver}s ${finishcopper}c
  Merchant:End        
}