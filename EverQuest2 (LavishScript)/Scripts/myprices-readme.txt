MyPrices - Version 0.08

For update details see the bottom of this file.


Please read all of this before starting.

What this Script will do
------------------------

Checks the prices of the items that you sell against all the same items being sold on the broker.

It flags up the item name if.

1. Someone is selling the same item cheaper than you.
2. Your item is less than the lowest price someone else is selling at.

If you want the script to match those values automatically check the relevant boxes on the front GUI tab.


Installing
----------

Copy/extract the contents of this archive into your scripts folder inside your C:\Program Files\InnerSpace\ folder.


Running
-------

Select a Broker , open up a broker window
either

1.
Open the Innerspace command line Window (`)
Type run myprices

or

2. type /run myprices in your EQ2 chat window.


The script will then open the GUI , scan your broker system and list whats in them.


There are 4 tickboxes 

Auto-Match Lower Prices
-----------------------
ticking this will make myprices reduce your price to match a lower one as long as it is not below the minimum price you will allow.

Auto-Match Higher Prices
------------------------
ticking this will make myprices increase your price to match the lowest price above yours if your price is lower than anyone elses.

Set Prices for unlisted items
-----------------------------
This will make myprices match the price of any unlisted items on your broker list to the lowest price available and set them as for sale.

Leaving this unticked will make the script skip unlisted items.

Auto-Loop
---------
This causes the script to re-start at the beginning once it has scanned everything.


There are 3 Buttons.

Rescan List
-----------
Re-loads the list on the right hand side from your broker list.

Start Scanning
--------------
Clicking this starts the script scanning your items on sale and checking the broker prices , the button changes to Stop scanning , the
script scans all your broker items until it reaches the last one

If you Press the button again during the scan it will wait for the current item scan to finish then stop.

Stop and Quit
-------------
This waits till the current item scan has finished and then exits the script totally.


Setting a Minimum Price for Items to be sold at.
-----------------------------------------------

To stop people trying to fool the script by pricing something REALLY low then buying your goods when the price is changed (if you get
it to change prices for you automatically), the script stores the name of each item and the minimum price you will accept for it 
(Minus Broker fee).

The script will NOT lower your prices below that price.

The first time a new item is added to that list (it's done automatically) the minimum price stored will match the current price you
have set.

To change the minimum sale price , click on it's name in the list , the current price and your current minimum price
will be shown on the left hand side.

Change the values in the boxes under 'Minimum Price' to match what you want them to be and press 'Save' , the value will be updated
and the list will re-load.


Automatically adding new items
------------------------------

If you toggle the 'set prices of unlisted items' option on and put new items in your broker box without listing for sale and setting
a price the following will happen.

1. The script scans for the lowest price for that item currently on the broker.
2. If that price is below a minimum price already set for that item previously then the price is set to your minimum price.
3. If you have a stored minimum price and the lowest price is higher then your minimum price the lowest price is matched.
4. If the item does not have a stored minimum price then the minimum price AND item price are matched with the lowest price on the broker.
5. The item is Listed for sale.

It may sound complicated , but what it means is you can just dump items in your broker list and let myprices set the price for you
and mark them as Listed.

If there are no broker items to compare a new item to then nothing will happen , you can either leave the item there until someone else
lists one or set a price using EQ2 broker system and myprices will store that as your minimum price.


During the Scan
---------------

As the items are checked the color of the item changes in the GUI list.

White  - The item was unable to be changed , there was nothing on the broker to compare it to.
Green  - The item price matches the current lowest price on the broker.
Yellow - Your item is the lowest price on the broker.
Red    - Your item is priced higher than the lowest price on the broker , but that price is below your minimum allowed price. 


The Future
----------

Plans for developing this script are the following:

I'm not 100% happy how the color of each item changes , currently the item has to be removed then re-added with the new color,
as soon as I know how it is possible to just change the color without moving the items name I will change this.

Continue to condense the script , for ease of initial coding I've used longer ways of doing some parts , these will be replaced
by more efficient code once it's all working as I want it to.

Code additional script routines to scan for Items to BUY with a max price set, the system will scan the broker list and if it finds anything that
matches at the right price or lower , it will automatically buy them (Upto a user set number).


Contact the author
------------------

If you do decide to try this script I'd be greatful for any bug reports or suggestions on the forum linked where you downloaded it from.

The more feedback I get the better I know which direction to take this and the faster I can squash any bugs that appear.


Updates :

Version : 0.08
--------------

Updated the script to remove all XMLSetting commands and use Lavishsettings instead.
(It's an old system thats not being supported any more according to Lax)

Condensed some of the script to remove duplicated code and replace them with single shared functions.

Added colored indicators to the Broker list in the GUI to mark how your items are priced compared with other broker prices.

Version : 0.07
--------------

Added various extra options to the GUI and made setting the minimum price totally GUI driven


Version : 0.06
--------------

Added an checkbox option to make the script set the price of any item thats added to your broker list but is not set as Listed.


What the script does is.

1. It finds an item thats unlisted. 
2. It checks that the item is in your minimum prices file (myprices.xml)
3. If it's not it adds the item into the minimum prices file and then goes onto the next item , leaving the item unlisted.

Next time it scans the your broker list again

1. It finds the item unlisted. 
2. it checks that the item is in your minimum prices file (myprices.xml)
3. It finds the lowest price that item is available and sets the price to that amount or if that items minimum price is more
   than the lowest price then it will set it to that minimum price instead..
4. It changes the minimum prices file to match this value 
5. It marks the item up as Listed.


This 2 pass system might sound a little wierd  , but due to how SoEs server handles the broker system it's the safest way I can
think of doing it.


What does this mean?

You can dump a load of items on the broker , start myprices , the script will go through the unlisted items and match the current
lowest price and then Set the item up as Listed for sale.

