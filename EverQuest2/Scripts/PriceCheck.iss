
function main()
{
  Declare MyItemCount int 1
  Declare CurrentPage int 1
  Declare CurrentItem int 1 
  Declare HardCount int 
  Declare ThisTotal int
  Declare CurrentName sting
  Declare LastName string
   Declare ThisTime string "${Time.Month}_${Time.Day}_${Time.Year}_at_${Time.Hour}_${Time.Minute}"
 target me
 Actor[special]:DoubleClick
 wait 5
  echo "started"
EQ2Echo "Total items to sell : ${Store.NumItemsICanSell} \n" >> PricesOn_${ThisTime}.txt 
 do
 	{
 	CurrentName:Set["${Store[${MyItemCount}].Name}"]
 LastName:Set["${Store[${Math.Calc[${MyItemCount}-1]}].Name}"]
if ${CurrentName.Compare[${LastName}]}==0
   {
    continue
   }
 	 EQ2Echo "\n		${MyItemCount} : ${Store[${MyItemCount}].Name}\n" >> PricesOn_${ThisTime}.txt 
 	 echo "on number ${MyItemCount}"
 	 broker Name "${Store[${MyItemCount}].Name}"

 	    ThisTotal:Set[0]
 	    HardCount:Set[0]
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
				EQ2Echo "				${Vendor.Broker[${CurrentItem}].Seller}  : ${Vendor.Broker[${CurrentItem}].BasePriceString} (${Vendor.Broker[${CurrentItem}].BasePrice} Silver) (${Vendor.Broker[${CurrentItem}].Quantity}) \n" >> PricesOn_${ThisTime}.txt 
					HardCount:Set[${Math.Calc[${HardCount}+${Vendor.Broker[${CurrentItem}].Quantity}]}]
				 }
  		while "${CurrentItem:Inc}<=${Vendor.NumItemsForSale} "
  		wait 10
 	ThisTotal:Set[${Math.Calc[${ThisTotal}+${Vendor.NumItemsForSale}]}]

  		 }
  	while "${CurrentPage:Inc}<=${Vendor.TotalSearchPages}"
  	
 	 	 EQ2Echo  "		number for sale:${ThisTotal} (${HardCount})\n" >> PricesOn_${ThisTime}.txt 
 	wait 5
 	}
 	else
 	{
 	EQ2Echo "None for sale\n" >> PricesOn_${ThisTime}.txt
 	}
 }
 ; uncomment the following line, and comment the one after it to just check the first 10 items, if you want to test this first
; while "${MyItemCount:Inc}<=10"
 while "${MyItemCount:Inc}<=${Store.NumItemsICanSell}"	
 echo "Done.  Look for the file PricesOn_${ThisTime}.txt in the folder where you have ISXEQ2.dll installed (typicaly C:\Program Files\InnerSpace\Extensions)"
  }