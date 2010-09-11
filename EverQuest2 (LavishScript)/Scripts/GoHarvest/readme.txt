Goharvest - Original concept By Mycroft

Portions of harvesting code - lifted from eq2harvest by ; Blazer , Syliac , Pygar , Cr4zyb4rd & Amadeus

* -> This is not designed to be used for 100% unnatended harvesting. <- *

What this does
--------------

This script will scan a defined size area - move from node to node harvesting your chosen type (UI checkboxes)
avoiding most items blocking your route to a node automatically without you having to define a set route.

Running the script
------------------

type run goharvest in Innerspaces command line.

Enter the area size in the box you wish to scan for nodes.

Choose the node types to harvest.

press Start.

If you want to only move within a set area , tick  max roam distance , set the scan range to be the distance you
want to roam and as soon as you hit START it will not go for nodes beyind that distance from your start point.

Idea behind this
----------------

I was after a way to harvest a smallish area where there were no agro mobs without it being too obvious.

Using eq2harvest , the character would 'wobble' back and forth around a small area even if there were no nodes to harvest.

So goharvest was coded.

Originally it was a small 10 line routine just to find a node close by and use moveto.iss to move to the node and harvest it.

After a short time I realised that obsticles were causing the character to get stuck on rocks / walls etc.

So I added a small routine to use the new Line of Sight (LOS) functions to try and avoid them.

This has grown into it's current form.


Advantages in using GoHarvest.

1) If scanning a relatively small area and there are no nodes close by then the script sits there till one spawn instead
 of constantly moving back and forth.

2) There is no pattern to the movement of the character , it will choose a node and head towards it...another time it will choose
 a different node/direction to take.

3) it will attempt to avoid obsticles in it's path and try and automatically find a way around 'corners' in the scenery to a node.


The LOS routine and how it works.. (If you are interested)
----------------------------------------------------------

The script finds a node , if it cannot see LOS to it, it scans in a 'cone' around the node pointing towards your character
in ever increasing distances from the node.

If at one of those points it finds it has LOS to character then your character is moved to that point and then onward to the node.

    |  Node   |
    |    .    |
    |   ...   |
    |  .....  |
    | X*ROCKS*|
    |  .      |
    |   .     |
    |    .    |
    |     .   |
    |      .  |
    |       X  -  character

If the max distance is reached then the angle of the cone checked is increased and the process starts again.

if it can't find any point that will let your character reach the node then it checks the same using your characters location
as it's start point and checking in the direction of the node in ever widening arcs.


    |  Node   |
    |   .     |
    |  .      |
    | .       |
    |X*ROCKS*.|
    | ........|
    |  .......|
    |   ......|
    |    .... |
    |     ..  |
          X  -  character


If both of these checks fail the node is skipped.

The routine is not 100% perfect , not all items blocking your path to a node can be scanned , some items such as fencing/tents
etc will cause it a few problems but combining this routine and moveto.iss's movement routine you should be able to reach 99%
of all nodes with few problems.
