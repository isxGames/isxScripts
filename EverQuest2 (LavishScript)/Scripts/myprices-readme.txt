MyPrices - Version 0.08d

For update details see the bottom of this file.


Please read all of this before starting.

What this Script will do
------------------------

It checks the prices of the items that you sell against all the same items being sold on the broker.

It flags up the item if.

1. Someone is selling the same item cheaper than you.
2. Your item is less than the lowest price someone else is selling at.

If you want the script to either reduce or raise your prices accordingly check the relevant boxes on the front GUI tab.


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
ticking this will reduce your prices to match a lower one as long as it is not below the minimum price if set.

Auto-Match Higher Prices
------------------------
ticking this will increase your prices to match the lowest price above yours if your price is lower than anyone elses.

Set Prices for unlisted items
-----------------------------
This will make myprices match the price of any unlisted items on your broker list to the lowest price available and set them as for sale.

Leaving this unticked will make the script skip unlisted items.

Auto-Loop
---------
This causes the script to re-start at the beginning once it has scanned everything.


There are 2 Buttons.

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
it to change prices for you automatically), the script can store the name of each item and the minimum price you will accept for it 
(Minus Broker fee).

The script will then NOT lower your prices below that price.

To set/change the minimum sale price for an item click on it's name in the list , the current price and your current minimum price
will be shown on the left hand side.

Tick the Box marked Minimum Price if it's unticked , this makes the script check the minimum price when it scans that item.

Change the values in the boxes under 'Minimum Price' to match what you want them to be and press 'Save' , the setting and value
will be updated and the list will re-load.

To stop using a minimum price just untick the box, the Minium price boxes will grey out and the script will ignore any minimum price
set for that item when doing it's scan.

Automatically adding new items
------------------------------

If you toggle the 'set prices of unlisted items' option on and put new items in your broker box without listing them for sale and
setting a price the following will happen.

The script scans for the lowest price for an item currently on the broker.

1. If a minimum price for that item was set previously and the lowest price is LOWER then your minimum price the minimum price is used.
2. If a minimum price for that item was set previously and the lowest price is HIGHER then your minimum price the lowest price is matched.
3. If the item does not have a minimum price set then the item price is matched with the lowest price on the broker.

The item is then Listed for sale.

It may sound complicated , but what it means is you can just dump items in your broker list and let myprices set the price for you
and mark them as Listed.

If there are no broker items to compare a new item to then nothing will happen , you can either leave the item there until someone else
lists one or set a price using EQ2 broker system and myprices will store that as your price.


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

Continue to condense the script , for ease of initial coding I've used longer ways of doing some parts , these will be replaced
by more efficient code once it's all working as I want it to.

Code additional script routines to scan for Items to BUY with a max price set, the system will scan the broker list and if it finds anything that
matches at the right price or lower , it will automatically buy them (Upto a user set number).


Contact the author
------------------

If you do decide to try this script I'd be greatful for any bug reports or suggestions on the forum linked where you downloaded it from.

The more feedback I get the better I know which direction to take this and the faster I can squash any bugs that appear.


Updates :

Version : 0.08d
---------------
Additional option added :

Each item for sale now can be flagged to check for a minimum price or not , if not flagged then the lowest price on the broker
will always be matched  regardless of it's cost.

**** ALL ITEMS when you run this version for the FIRST time will be NOT flagged to check your minimum price ****

**** Go through the list and tick the box against the item you want a minimum price checked and press the save button *****

Added additional lag checking code for when the script is setting and unsetting items for sale to try and stop items being left unlisted.

Version : 0.08c (Large code Update)
---------------
Vastly simplified and improved the code to handle the item list color changes and GUI information updating.
(No more scrolling list - the color just changes without the text being moved - Thanks for the pointer Lax)

Updated a huge portion of the code to simplify the various methods/functions used.

Updated the GUI to remove all XMLSetting references it now calls various routines that use Lavishsettings instead.

Bugfix  : Adding a new item sometimes left the current price boxes for that item permanently empty.

Version : 0.08b
---------------

Small bugfix : Minimum prices of unlisted items were being set even though they already had a minimum price stored.

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

