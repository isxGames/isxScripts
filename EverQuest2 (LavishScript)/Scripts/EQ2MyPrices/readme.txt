MyPrices - Version 0.12i

For update details see the bottom of this file.


Known Problems:
---------------

To fully use the selling part of this script , you MUST group all items of the same name listed in
the same container together on your broker list...

If you have 2 items listed in the same container (Ebon Cluster for example) and you list them seperately

Ebon Cluster
Ebon Cluster

instead of 

Ebon Cluster (2)

Then the script will fail to set one or both back up for sale.

This is a limitation of SoE's broker system and I cannot work around it.

Listing the same item seperately in 2 or more DIFFERENT containers will not cause this problem.


Items with Commas in the name have problems in the buying and selling parts of the script due to the fact Innerspace
currently reads the name in the UI box upto the comma then assumes the next part of the text is another item.


What this Script will do
------------------------

Selling
=======
It checks the prices of the items that you sell against all the same items being sold on the broker.

It flags up the item if.

1. Someone is selling the same item cheaper than you.
2. Your item is less than the lowest price someone else is selling at.

If you want the script to either reduce or raise your prices accordingly check the relevant boxes on the front GUI tab.

Buying
======

It will scan the broker list for items that you want to buy , if they are for sale at or under a set value then 
it buys them until the number of items you set have been bought or you run out of money.

(it will buy the cheapest items first)

If you can't afford to buy all the items you set (someone is selling 500 and you only have enough cash for 476) then
it will buy 476 of them.


Craft
=====

You can set it to automatically create a recipe list favourite for the Craft Script based on how many crafted items
you have left for sale on the broker.


Running This Script
-------------------

1.
Open the Innerspace command line Window (`)
Type run myprices

or

2. type /run myprices in your EQ2 chat window.


The script will then open the GUI , either doubleclick your market board or the closest non-agro NPC (should be the broker)
scan your broker system and list whats on it.


The Sell TAB
============

tickboxes 
=========

Auto-Match Lower Prices
-----------------------
ticking this will reduce your prices to match a lower one as long as it is not below the minimum price if set.

Merchant Match
-----------------------
ticking this will ensure that your sale prices are not set lower than prices you could get by selling that item to an NPC.

Auto-Match Higher Prices
------------------------
ticking this will increase your prices to match the lowest price above yours if your price is lower than anyone elses.

Set Prices for unlisted items
-----------------------------
This will make myprices match the price of any unlisted items on your broker list to the lowest price available.
if the item has had a minimum price set previously and the lowest price is too low , your minimum price will be used instead,

Leaving this unticked will make the script skip unlisted items.

Ignore Copper
-------------
This makes the script ignore any copper if a matching price is over one gold and includes copper

e.g if a matching price is 1g 59s 45c then the script sets the price to 1g 59s

Auto-Loop
---------
This causes the script to re-start at the beginning once it has scanned everything.

Scan Sales
----------

With this ticked the script will scan/compare the items you have up for sale, without this ticked it will not scan your
sales items , useful if all you want to do is scan for items to buy.

Logging
-------

Only use this if you are having problems with running the script , it creates a myprices.log file in the EQ2MyPrices folder , this
can get large FAST.

This contains details of what functions are being called with what parameters and what values are being returned.

You can PM me on the forums with the file and with details of the problem and it should hopefully give me an idea where to fix the problem
you are having.

To Toggle it on , run the script , toggle it ON then exit and re-run the script , run the scans etc that you usually do and then toggle
it off , this way I get to see what your options are set to on the Sell tab also, otherwise I won't see them.

Natural Scan
------------

This makes the script act in a more natural way , items aren't scanned in a particular order , there are pauses between broker checks for each
item in your list , the pause between automatic scans is randomised somewhat.


Match without Broker %
----------------------

If someone in  is selling an item for 25g without commission then yours will be set to 25g also, the broker fee is ignored.


Delay in Minutes
----------------

Enter a value here to make the script pause this number of minutes between scans if Auto-Loop is toggled on.


Buttons
=======

Start Scanning
--------------
Clicking this starts the script scanning your items on sale and checking the broker prices , the button changes to Stop scanning , the
script scans all your broker items until it reaches the last one

If the Scan Sales tickbox is unticked then your script will jump straight to the buy routine.

If you Press the button again during the scan it will wait for the current item scan to finish then stop.


Stop and Quit
-------------
This waits till the current item scan has finished and then exits the script totally.

Craft List
----------

Clicking on this will make myprices scan your broker list , compare whats there with the values you set under the craft tab
and add how many of what items you need to make to replenish your broker stocks to your craft script favourites list.

Next time you run craft you can choose 'myprices' from the list under the Advanced Tab , Press Load and then the Submit Queue button
and you can then start crafting what you need.

typing /craft myprices  will also start craft and auto-load the myprices list then start crafting automatically. 

Place Items
-----------

This will make the script scan your bags for items marked in your craft list , if any are found it will place them in the broker system for
you automatically.

1. It goes through your craft flagged items one by one.
2. The script searches for items of the same type , if found the items are placed in that box until they are all added or that box is full.
3. If there is no (more) space in a box with the same type of item or no matching items in your broker slots, then it places the items in
   the box with the enough space to fit ALL those items in your inventory.
4. If no box has enough space to fit all of those items it distributes them between the boxes (filling boxes with the most space first).
5. it stops when you have no more space left anywhere.


The Sell TAB
============

Setting a Minimum Price for Items to be sold at.
-----------------------------------------------

To stop people trying to fool the script by pricing something REALLY low then buying your goods when the price is changed (if you get
it to change prices for you automatically), the script can store the name of each item and the minimum price you will accept for it 
(Minus Broker fee).

The script will then NOT lower your prices below that price.

To set/change the minimum sale price for an item click on it's name in the list , the current price and your current minimum price
will be shown at the bottom.

Tick the Box marked Minimum Price if it's unticked , this makes the script check the minimum price when it scans that item.

Change the values in the boxes under 'Minimum Price' to match what you want them to be and press 'Save' , the setting and value
will be updated and the list will re-load.

To stop using a minimum price just untick the box, the minimum price boxes will grey out and the script will not check for
a minimum price for that item when doing it's scan.

Setting a Maximum Price for Items to be sold at.
----------------------------------------------

To stop the script matching someones overly high price the script can store the the maximum price you will accept for it 
(Minus Broker fee).

The script will then NOT raise or set your price for that item above that price.

To set/change the maximum sale price for an item click on it's name in the list , the current price and your current minimum price
and current maximum price will be shown at the bottom.

Tick the Box marked Max Price if it's unticked , this makes the script check the maximum price when it scans that item.

Change the values in the boxes under 'Maximum Price' to match what you want them to be and press 'Save' , the setting and value
will be updated and the list will re-load.

To stop using a maximum price just untick the box, the maximum price boxes will grey out and the script will not check for
a maximum price for that item when doing it's scan.



Setting an item to be marked as a craftable item 
------------------------------------------------

Click on it's entry on the Sell List , check the 'craft' checkbox and press save.


Automatically adding new items
------------------------------

If you toggle the 'set prices of unlisted items' option on and put new items in your broker box without listing them for sale and
the following will happen.

The script scans for the lowest price for each item currently on the broker.

1. If a minimum price for that item was set and the lowest price is LOWER then your minimum price the minimum price is used.
2. If a minimum price for that item was set and the lowest price is HIGHER then your minimum price the lowest price is matched.
4. If the item has a maximum price set and the lowest broker price is HIGHER than this then the price is set to your maximum price.
3. If the item does not have a minimum price or maximum price set then the item price is matched with the lowest price on the broker.

What this means is you can just dump items in your broker list and let myprices set the price for you and mark them as Listed.

If there are no broker items to compare a new item to then nothing will happen.

You can either leave the item there until someone else lists one or set a price using EQ2 broker system.


When the List is Populated
--------------------------
Yellow - The item was marked a craft item (links with the Craft script).


During the Scan
---------------

As the items are checked the color of the item changes in the GUI list.

Black  - The item price was unlisted and unchanged , there was nothing on the broker to compare it to.
Green  - The item price was matched to the current lowest price on the broker.
Red    - Your item is priced higher than the lowest price on the broker , but that price is below your minimum allowed price. 
Blue   - New unlisted Item added to the broker list
Orange - The item was not inside your broker containers when it was reached in the list , may have been sold or removed
         during the scan.


The Buy TAB
===========

Check the Buy Items checkbox to make the script look for items you wish to buy.

Type the name of the item in the name box (case doesn't matter , spelling does)

Enter the number of that item you want the script to buy

Enter the PP , Gold , Silver and Copper you are willing to pay for EACH item into the relevant boxes.

Press Save to add the item to the list.

Selecting an item in the listbox and pressing delete removes it from the list.

When you select an item in the list box the script will do a broker search using that name
 (helps to make sure you have the correct spelling)


The Craft TAB
=============

This lists the items that you marked as 'craft' on the Sell Tab.

Press Re-Scan to bring up the complete list of items marked as a craft item.

Click on each entry in the list and you have 2 boxes..

Craft Stack:  This should be the number of items you make every time you get a pristine result...
(e.g. a woodworker on a totem you would put 3, arrows you would put 100 in this box)

Stock Limit : Put how many (single) items you want as a minimum number in your broker list..
(if you wanted to keep 60 Chameleon Totems on your broker then enter 60 , 4000 arrows you'd enter 4000)


Press the Save button.


The Future
==========

Plans for developing this script are the following:

Add an option to make your sale price (minus the broker fee) the same as the sale price of the lowest priced item ignoring the 
brokers fee.

Add an option to set a maximum value to set your items too (for those using the increase item price option).

Continue to condense the script , for ease of initial coding I've used longer ways of doing some parts , these will be replaced
by more efficient code as I re-code parts of it.


Contact the author
------------------

If you do decide to try this script I'd be greatful for any bug reports or suggestions.

Discussion thread for myprices can be found at : http://www.isxgames.com/forums/showthread.php?t=1808

The more feedback I get the better I know which direction to take this and the faster I can squash any bugs that appear.

Revisions
=========

version 0.12i
-------------

Updated script so that if you add an item that nobody else currently has on the broker (nothing to compare your item to) and you have a
maximum price set for items of that name, then the script will set your new item to that price.

version 0.12h
-------------

Added an option to set a maximum price to sell each item for.


version 0.12g
-------------

Added an option to sell at the same price as the lowest price on the broker (ignoring the sellers broker fee)

If you sell on the Freeport broker and someone in Qeynos  is selling an item for 25g without commission then your same item will be 
set to 25g also.

It will appear on the Freeport broker as cheaper than the one for sale in Qeynos, but still show as more expensive to people scanning
the Qeynos broker due to higher broker charges.

version  0.12f
--------------
Recoded the scan routine , it will now recognise more items in the broker list that it used to miss because of (',") in the name.

Version 0.12c-0.12e
-------------------
Now has more logging (if toggled on)

Script will now Pause if your mouse moves off the Broker window for any reason as this causes problems with changing values on the broker 
the script will resume when the Broker window has the mouse on it again.


Version 0.12b
-------------

With Ama's recent fix to the commission system when run with the market bulletin boards the script will now auto-click your board then target
your character when run so you no longer need to open the broker system at all before running the script , just ensure you are within range
of a broker or your room board.

Version 0.12
------------

New button , Place Items

This will make the script scan your bags for items marked in your craft list , if any are found it will place them in the broker system for
you automatically , grouping items together if the same name.

1. It goes through your craft flagged items one by one.
2. The script searches for items of the same type , if found the items are placed in that box until they are all added or that box is full.
3. If there is no (more) space in a box with the same type of item or no matching items in your broker slots, then it places the items in
   the box with the enough space to fit ALL those items in your inventory.
4. If no box has enough space to fit all of those items it distributes them between the boxes (filling boxes with the most space first).
5. it stops when you have no more space left anywhere.


Version 0.11f Rev 7
-------------------

Added an extra option under the craft tab , you can now enter an alternative name for a craft item if the name of the item
and the craft recipe name are different , the alternative text is used to create the craft list instead of the item name.

Version 0.11f Rev 6
-------------------

Various small bugfixes

Version 0.11f Rev 5
-------------------

Added Natural Scan option , makes it look less like a script is doing the broker scans , slows down the list scan a little.

Version 0.11f Rev 4
-------------------

Added checkboxes 1-6 , select the boxes you want myprices to scan , it will totally ignore any broker boxes that aren't ticked.


Version 0.11f Rev 3
-------------------

Added a button to let you unset an item in the craft tab  , select the item in the list and press Unset , the item will be 
unmarked as a craft item and the list will refresh.

Fixed a bug where items marked as craft items on one character were also being saved as craft items on another.

Several Minor bugfixes.

Version 0,11f
-------------

Added new option 'Merchant Match' clicking this won't lower your prices below what you can get from selling to an NPC.

Added options to click on the buy list to do 'fuzzy' searches , you can set partial names 'master i)' Item start and end levels , 
price , and tier. This will only work by clicking on each entry in the buy tab , problems with people putting items up for sale
such as high level fabled conjuror shards at 60g stopped me adding it to the usual automatic buy search routine.

This change means you will NEED to goto your buy list , on items where you will just search for a particular name , click on
each entry, click on the 'name only' tickbox and press 'save'

Due to how ISXEQ2 currently handles the MaxPrice paramater (it doesn't search for actual cost price but the sellers set price) means
your search will return items minus the cost of commission in the list. 

Version 0.11c
-------------

New option on the Buy Tab , harvest checkbox , clicking this when editing the item you want to buy will tell the script that
the max stack size that can be bought for this item is 200 not 100.

Logging :  some people are having problems with the script not working properly  (I can't duplicate the problems here yet)

There is a new logging checkbox , run the script , check this box , exit the script and re-run the script..run the scan as normal and when
it's finished uncheck the textbox..

The log file can be found inside the EQ2MyPrices folder , PM me this file and I can see what functions are being called and 
what information is being passed/returned.

Hopefully this will give me some insight to whats going wrong and where.

If need be I'll add more logging inside each function using smaller updates till we narrow it down...

Several bugs squashed to do with buying.

Version 0.11b
-------------

Moved all the data files into EQ2MyPrices folder.

move your myprices_character.xml files from \scripts\XML\ to \EQ2MyPrices\XML\

This will be the last file move I promise.

Version 0.11a
-------------

1. I Changed the way the script stores datafiles , each character that uses the script now has their own datafile.

(If you run the script on more than one character then each item marked as a craftable item will now be specific to that character.)

If you want to use your existing (pre-version 11) datafile for one or more of your characters do the following

Copy/Move the file MyPrices.xml file into the XML folder inside your script folder

Rename the MyPrices.xml file charactername_MyPrices.xml

So if the character is called Mycroft

\scripts\myprices.xml becomes \scripts\XML\Mycroft_MyPrices.xml

2. I Updated the script to remove a lot of duplicate indexing - it's much more efficent and a fair bit smaller now.

3. The script will no longer unlist broker items unless the 'Auto-match Higher Prices' option is checked  or Re-List
   items if they are already listed for sale, this speeds up scans by a large amount.

Version 0.10b
-------------

Pressing the craft button will now crate a favourite in the craft script file containing details and numbers of
the stock your broker list is short, you can choose to load this list and craft will re-create the stock you are 
missing from your broker.

**Warning** : this is still work in progress , the list will be created correctly but the script doesn't actually
check you have run the craft script , the file/directory may not be there if you don't use the craft script or
don't download all of the SVN - checks for missing files will be added soon.


Version 0.10a
-------------

Started work on the script to produce a craft recipe file ready for loading , currently only echos whats needed onto the
lavish console (work in progress , try it and let me know what you think)

Fixed the text on the Sell Tab to be in the right places...


Version 0.9g
------------

Added an option to Pause the script between scans if Auto-Loop is toggled on

Fixed a problem with setting the minimum price of an item.


Version 0.9f
------------

Ok , the script now REALLY doesn't care how the items are sorted on your container list...I mean it this time...
sorting your items by Listed caused some wierd problems , now fixed.

Small update to other parts of the script also to simplify it somewhat.

Script will collect any money on your broker from sales automatically from each selling container as it scans them , 
you can now afford those extra items you wanted to be automatically bought :p 


Version 0.9b-0.9e
-----------------

Major code revision:

The script no longer cares where the item being looked at is in your broker list , it will work fine now however you
sort your list , by name , price , listed , it should find and list/change/unlist them without any problems.

Added : All changes are now logged in the Log Tab instead of the Lavish Console Window , press 'clear' to clear the entries.


Version 0.9a
------------

Buy Routine added:

The script can now buy items at or below a defined price upto a set number of items.

1) It does not stop until either you a) run out of money with more to buy or b) it has bought all the items you asked it to.
2) It currently doesn't check for empty bag slots , extra items bought SHOULD go into your overflow.

The buy script was fairly well tested with it constantly scanning for the last 2 days.

(It cost me the tune of 5pp - when a bug reared it's ugly head earlier on in it's coding)
which is why it's been soak tested for the last 2 days before being released.

But I still recommend you test it with something really cheap (2c) before you decide to trust it with a more expensive item.


New button : You can now toggle the scan sales option on and off if you wish to just scan for items to buy.


Version 0.8e
------------

1) Scanning now faster if more than one page of items is on the broker.
2) GUI has been reduced in size by about 50% in width and 10% in height.
3) New option [b]Ignore Copper[/b] , if the matching price is over 1 gold then any Copper is ignored when setting the new price.

(Doesn't work if you set a minimum price over 1 gold that includes coppers)

You can make a Buy Item list now , The function code to actually buy the items in the list has been snipped
out till I'm 100% sure it's working fully.

Feel free to test adding and deleting items in the list though.

Version : 0.08d
---------------
Additional option added :

Each item for sale now can be flagged to check for a minimum price or not , if not flagged then the lowest price on the broker
will always be matched  regardless of it's cost.

**** ALL ITEMS when you run this version for the FIRST time will be NOT flagged to check your minimum price ****

**** Go through the list and tick the box against all items you want a minimum price checked and press the save button on each *****

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

