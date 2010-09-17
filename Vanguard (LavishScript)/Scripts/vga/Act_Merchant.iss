function merchant()
{
  if ${Me.Target.Type.Equal[Merchant]}
	{
	If ${Me.Target.Name.Equal[Grebthar the Hammer]} && ${DoPopCrates}
		{
		call CrateCrush
		}
  	call Repair
  	call Sell
	}
  if ${Me.Target.Name.Equal[Essence of Replenishment]}
	{
  	call Repair
	}
  if ${Me.Target.HasQuestFlag}	
	{
	call GetQuests
	call TurnInQuests
	}
  
}
function CrateCrush()
{
		If ${Me.Inventory[Supply Crate](exists)} || ${Me.Inventory[Storage Crate](exists)}
			{
			If ${Merchant.NumItemsForSale} < 1
				{
				Merchant:Begin[BuySell]
				wait 5
				}
			while ${Me.Inventory[Supply Crate](exists)}
				{
				Merchant.ForSaleItem["Crate Crusher 3000"]:Buy
				wait 3
			        Me.Inventory[Supply Crate]:Use
				wait 3
				}
			while ${Me.Inventory[Storage Crate](exists)}
				{
				Merchant.ForSaleItem["Crate Crusher 3000"]:Buy
				wait 3
			        Me.Inventory[Storage Crate]:Use
				wait 3
				}
			Merchant:End[BuySell]
			}
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
  wait 3
  Merchant:RepairAll
  Merchant:End
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

    if ${doSell} && !${Me.InCombat}
     {
	variable iterator Iterator
	Sell:GetSettingIterator[Iterator]
	Iterator:First
	while ( ${Iterator.Key(exists)} )
	{
		if !${Me.Inventory[exactname,${Iterator.Key}].Type.Equal[No Trade]} || !${Me.Inventory[exactname,${Iterator.Key}].Type.Equal[No Rent]} || !${Me.Inventory[exactname,${Iterator.Key}].Type.Equal[No Sell]} || !${Me.Inventory[exactname,${Iterator.Key}].Type.Equal[Quest]}
			{
			while ${Me.Inventory[exactname,${Iterator.Key}](exists)}
			{
			echo Selling ${Iterator.Key}
			Me.Inventory[exactname,${Iterator.Key}]:Sell[${Me.Inventory[ExactName,${Iterator.Value}].Quantity}]
			waitframe
			}
			}
		Iterator:Next
	}
      }

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
function GetQuests()
{
			variable int iCount
			iCount:Set[1]
			; Cycle through all the Pawns and find Quest Flag Mobs
			do
			{
				if ${Pawn[${iCount}].HasQuestFlag} && ${Pawn[${iCount}].Distance} < 15 
				{
					Pawn[${iCount}]:Target
					wait 5
					variable iterator Iterator
					Quests:GetSettingIterator[Iterator]
					while ( ${Iterator.Key(exists)} )
						{
						if ${LavishSettings[VGA_Quests].FindSet[Quests].FindSetting[${Iterator.Key}].FindAttribute[NPC].String.Equal["${Me.Target}"]}
							{
							if ${Pawn[${iCount}].Distance} > 5
								{
								call movetoobject ${Me.Target.ID} 4 0
								if ${DoNaturalFollow}
									IsFollowing:Set[FALSE]
								}
							if ${Dialog[General].ResponseCount}==0
								{
								Me.Target:DoubleClick
								Echo Bringing up Dialog
								wait 5
								}
							if !${Journal[Quest,${Iterator.Value}](exists)}	
								{
								Echo dont have ${Iterator.Value}  Getting ${Iterator.Key}
								Dialog[General,${Iterator.Key}]:Select
								wait 5
								Journal[Quest].CurrentDisplayed:Accept
								wait 3
								}
							}
						Iterator:Next
						}
					if ${Dialog[General].ResponseCount} >0
						{
						; Place Holder for Closing Dialog
						}
				}
			}
			while ${iCount:Inc} <= ${VG.PawnCount}
	
}
function TurnInQuests()
{
}
