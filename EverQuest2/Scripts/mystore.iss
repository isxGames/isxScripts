;*************************************************************
;mystore.iss
;version 20070502a
;by Milamber
;updated by Ronin
;
; 20070502a
;	Fixed Item Loop to new ISXEQ2 commands
;	and added container support.
;	
;	Usage: run mystore coffee 0 0 30 0 2
;	Will set the price of all items in Consignment 
;	Container #2 that matches Coffee to 30 silver.
;
;*************************************************************
;
;
;
; mystore.iss version 0.12 by Milamber 2005-Sept-10
;
; v0.12 minor changes
; added some minor changes including:
; substring match - it suffices to write: run mystore coffee 0 0 50 0
; to list all your various types of coffee for sale at 50s
; All option - if you want to sell everything you have for the same price
; you're now able to write: run mystore All 0 0 25 0
; which will set all your items for sale at 25s - !BEWARE! - this also includes
; the items that you have on you at the moment! Use this option with caution or
; you might sell rare / fabled items for just a few copper ;)
;
; v0.11 bug fix
; removed a line of code that wasn't needed concerning listing the items for sale 
;
; Useage example:
; run mystore "refreshing creamed robust coffee" 0 0 30 0
; This will set all your refreshing creamed robust coffee in your vault and inventory to 30sp and list them for sale. You need to be in your inn room and have the store open to do this.
;
; It will even work if you just run it with part of price
; example: run mystore "refreshing creamed robust coffee" 1
; will result in selling coffee for 1p each
;
; Feel free to comment on the forums :)
;

function main(string iName,int pp, int gp, int sp, int cp, int cnt=1)
{
if "${iName.Length} && ${Math.Calc[${pp}+${gp}+${sp}+${cp}]}"
{
call DeclareValues
itemName:Set[${iName}]
platina:Set[${Math.Calc[${pp}*10000]}]
gold:Set[${Math.Calc[${gp}*100]}]
silver:Set[${sp}]
copper:Set[${Math.Calc[${cp}/100]}]
price:Set[${Math.Calc[${platina}+${gold}+${silver}+${copper}]}]
itemsForSale:Set[${Me.Vending[${cnt}].NumItems}]

Do
{
  if ${Me.Vending[${cnt}].Consignment[${counter}].Name.Find[${itemName}]} || ${itemName.Equal["All"]}
  {
    Me.Vending[${cnt}].Consignment[${counter}]:SetPrice[${price}]
  }

  counter:Set[${counter}+1]
}
While "${counter}<=${itemsForSale}"
}
else
EQ2Echo You must insert itemName, platinum, gold, silver and copper when calling this script!
}



function DeclareValues()
{
declare itemName string script
declare platina int script
declare gold int script
declare silver int script
declare copper int script
declare itemsForSale int script
declare counter int script 1
declare price int script
}

