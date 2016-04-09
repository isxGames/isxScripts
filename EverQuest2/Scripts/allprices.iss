
function main()
{
  Declare MyItemCount int 1
  Declare CurrentPage int 1
  Declare CurrentItem int 1 
  Declare ThisTotal int
  Declare CurrentName sting
  Declare LastName string
  echo "started"
  Me:CreateCustomInventoryArray
EQ2Echo "Total items : ${Me.CustomInventoryArraySize} \n" >> allstore.txt 
 do
 	{
 	 EQ2Echo "\n		${MyItemCount} : ${Me.CustomInventory[${MyItemCount}].Name}\n" >> allstore.txt 
 	 echo "on number ${MyItemCount}"
 CurrentName:Set["${Me.CustomInventory[${MyItemCount}].Name}"]
 LastName:Set["${Me.CustomInventory[${Math.Calc[${MyItemCount}-1]}].Name}"]
if ${CurrentName.Compare[${LastName}]}==0
   {
   EQ2Echo skipped \n >> allstore.txt
    continue
   }

 
 	 broker Name "${Me.CustomInventory[${MyItemCount}].Name}"

 	    ThisTotal:Set[0]
 	 wait 15
 	
   CurrentPage:Set[1]

 if ${Vendor.NumItemsForSale}
  {
  do
  		{
 		 Vendor:GotoSearchPage[${CurrentPage}] 
 		    CurrentItem:Set[1]
		do
				{
				EQ2Echo "				${Vendor.Broker[${CurrentItem}].Seller}  : ${Vendor.Broker[${CurrentItem}].BasePriceString} (${Vendor.Broker[${CurrentItem}].BasePrice} Silver) (${Vendor.Broker[${CurrentItem}].Quantity}) \n" >> allstore.txt 
				 }
  		while "${CurrentItem:Inc}<=${Vendor.NumItemsForSale} "
  		wait 10
 	ThisTotal:Set[${Math.Calc[${ThisTotal}+${Vendor.NumItemsForSale}]}]
  		 }
  	while "${CurrentPage:Inc}<=${Vendor.TotalSearchPages}"
  	
 	 	 EQ2Echo  "		number for sale:${ThisTotal}\n" >> allstore.txt 
 	wait 5
 	}
 	else
 	{
 	EQ2Echo "None for sale\n" >> allstore.txt
 	}
 }
;while "${MyItemCount:Inc}<=10"
while "${MyItemCount:Inc}<=${Me.CustomInventoryArraySize}"	
 echo "done"
  }