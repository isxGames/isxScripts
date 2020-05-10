function main()
{
  variable index:item Items
  variable iterator ItemIterator
  Declare CurrentPage int 1
  Declare CurrentItem int 1 
  Declare BasePrice float 0
  Declare ThisTotal int
  Declare CurrentName sting
  variable string LastName = ""
  echo "started"
  
  EQ2Echo "This script searches through the broker and returns the current price range for the items you have in your inventory.\n" > allstore.txt
  EQ2Echo "(Note:  All prices are WITHOUT broker commission.)\n" >> allstore.txt
  
  Me:QueryInventory[Items, Location == "Inventory"]
  Items:GetIterator[ItemIterator]
  EQ2Echo "Total items :: ${Items.Used} \n" >> allstore.txt 
  
  if ${ItemIterator:First(exists)}
  {
    do
    {
      CurrentName:Set["${ItemIterator.Value.Name}"]
      if ${CurrentName.Compare["Unknown"]}==0
      {
        continue
      }     		
      
      EQ2Echo "\n${MyItemCount} :: ${ItemIterator.Value.Name}\n" >> allstore.txt 
      echo "Processing No. ${MyItemCount}"
      
      if ${CurrentName.Compare[${LastName}]}==0
      {
        EQ2Echo "				skipped. (duplicate)\n" >> allstore.txt
        continue
      }
      if (${ItemIterator.Value.Attuned})
        {
        EQ2Echo "				skipped. (attuned already)\n" >> allstore.txt
        continue
      }
      if (${ItemIterator.Value.NoTrade})
        {
        EQ2Echo "				skipped. (NO-TRADE)\n" >> allstore.txt
        continue
      }          
      
            
        broker Name "${ItemIterator.Value.Name}"

        ThisTotal:Set[0]
        wait 15
    
        CurrentPage:Set[1]

        if ${BrokerWindow.NumSearchResults}
        {
          do
          {
            BrokerWindow:GotoSearchPage[${CurrentPage}] 
            CurrentItem:Set[1]
            do
            {
                ;EQ2Echo "				${BrokerWindow.Broker[${CurrentItem}].Seller}  : ${BrokerWindow.Broker[${CurrentItem}].BasePriceString} (${BrokerWindow.Broker[${CurrentItem}].BasePrice} Silver) (${BrokerWindow.Broker[${CurrentItem}].Quantity}) \n" >> allstore.txt 
                ;EQ2Echo "				Item${CurrentItem} :: ${BrokerWindow.Broker[${CurrentItem}].BasePriceString} (Qty: ${BrokerWindow.Broker[${CurrentItem}].Quantity}) \n" >> allstore.txt 
                
                if (${BrokerWindow.Broker[${CurrentItem}].BasePrice} < 1)
                {
                    BasePrice:Set[${BrokerWindow.Broker[${CurrentItem}].BasePrice}]
                    EQ2Echo "				Item${CurrentItem} :: ${BasePrice}s (Qty: ${BrokerWindow.Broker[${CurrentItem}].Quantity}) \n" >> allstore.txt 	
                }						
                else
                {
                    BasePrice:Set[${BrokerWindow.Broker[${CurrentItem}].BasePrice}/100]
                    EQ2Echo "				Item${CurrentItem} :: ${BasePrice}g (Qty: ${BrokerWindow.Broker[${CurrentItem}].Quantity}) \n" >> allstore.txt 
                }
            }
            while "${CurrentItem:Inc}<=${BrokerWindow.NumSearchResults} "
            wait 10
            ThisTotal:Set[${Math.Calc[${ThisTotal}+${BrokerWindow.NumSearchResults}]}]
          }
          while "${CurrentPage:Inc}<=${BrokerWindow.TotalSearchPages}"
      
          EQ2Echo "				** Number for sale:${ThisTotal}\n" >> allstore.txt 
          wait 5
        }
        else
        {
          EQ2Echo "				None for sale\n" >> allstore.txt    
        } 
        LastName:Set["${CurrentName}"]
    }
    while ${ItemIterator:Next(exists)}
  }
  
  echo "done"
}
