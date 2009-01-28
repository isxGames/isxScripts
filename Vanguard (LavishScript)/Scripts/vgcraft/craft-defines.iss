
/* ================ Definitions ================ */

/*             DO NOT CHANGE THESE!              */

#define LOWCOST  1
#define MAXPROG  2
#define MAXQUAL  3

/* Values for Recipe word descriptions */
#define VHIGH 16
#define HIGH   8
#define MOD    4
#define VLOW   2
#define LOW    1

/* Possible Values of cState */
#define  CS_WAIT             0  /* Waiting for something to finish */
#define  CS_STATION         10  /* Crafting Station start point */
#define  CS_STATION_SELECT  11  /*  Find and Target a Crafting Table */
#define  CS_STATION_RECIPE  12  /*  Select and Check recipe */
#define  CS_STATION_IWAIT   13  /*  Optional Wait for Manual add of Ingredients */
#define  CS_STATION_SETUP   14  /*  Setup the workbench with Ingredients */
#define  CS_STATION_BEGIN   15  /*  Waiting to begin recipe */
#define  CS_ACTION          20  /* Using Recipe actions */
#define  CS_ACTION_FIND     21  /*  Select Available Action */
#define  CS_ACTION_WAIT     22  /*  Waiting for Action to finish */
#define  CS_ACTION_MANUAL   23  /*  Requires User Input (manual typing) */
#define  CS_ACTION_OOAP     24  /*  Out Of Action Points */
#define  CS_ACTION_OOM      25  /*  Out Of Material (ingredients) */
#define  CS_ACTION_KICK     26  /*  Need kickstart action! */
#define  CS_ACTION_BELT     27  /*  Switch Toolbelts */
#define  CS_COMPLICATE      30  /* Checking Complication */
#define  CS_COMPLICATE_FIND 31  /*  Selecting Complication Action */
#define  CS_COMPLICATE_REDO 32  /*  Try Complication one more time */
#define  CS_COMPLICATE_WAIT 33  /*  Waiting for Complication Action to finish */
#define  CS_LOOT            40  /* Looting */
#define  CS_MOVE            50  /* Moving to Target */
#define  CS_MOVE_TPATH      51  /*  Move to a Target along LavishNav path */
#define  CS_MOVE_UPATH      52  /*  Move along a user defined path */
#define  CS_MOVE_FIND       53  /*  Find a valid Target to move to */
#define  CS_MOVE_TARGET     54  /*  Get target and start moving! */
#define  CS_MOVE_WAIT       55  /*  Waiting for movement to finish */
#define  CS_MOVE_TARGWAIT   56  /*  Waiting target to Return */
#define  CS_MOVE_LOS        57  /*  Waiting for Line Of Sight to NPC */
#define  CS_MOVE_MAP        58  /*  Get back on the MAP */
#define  CS_MOVE_DONE       59  /*  All done moving */
#define  CS_ORDER           60  /* Talking to Work Order NPC */
#define  CS_ORDER_TARGET    61  /*  Target and Talk to Work Order NPC */
#define  CS_ORDER_GET       62  /*  Getting new Work Orders */
#define  CS_ORDER_FINISH    63  /*  Finish old Work Orders */
#define  CS_ORDER_DONE      64  /*  Done with Order, collect loot!  */
#define  CS_ORDER_ABANDON   65  /*  Abandon this order! */
#define  CS_SUPPLY          70  /* Talking to Item/Resupply Vendor */
#define  CS_SUPPLY_BUY      71  /*  Buying supplies */
#define  CS_SUPPLY_SELL     72  /*  Sell any loot */
#define  CS_SUPPLY_SORT     73  /*  Moving supplies around inventory */
#define  CS_SUPPLY_WAIT     74  /*  Buy/Sell wait state */
#define  CS_REPAIR          80  /*  Repair Equipment */

