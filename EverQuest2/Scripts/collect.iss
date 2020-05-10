/*
Setup: Once per running it;
Open a shinny that needs added, /run collection
put the mouse over the ADD button. In 3 seconds it will save the mouse x,y cordiantes. LOCK THE WINDOW SO YOU CANT MOVE IT!!!

After that every time your inventory is updated it will check for shinnies.  There is some lag in it right now though.  Meaning, if you get a shinny you need it might not recognize it till the next time your inventory changes.


How it works:
When your inventory changes it will scan the contents, if a shinny you need is found it will open the quest journal and click on add. **This will always add it to the button you had the mouse over!!  Meaning, generally it will add to the first collection!**

It will then close the quest journal.
*/

variable int ToClickX
variable int ToClickY
variable bool MouseClickSet=FALSE
variable bool JournalOpen=FALSE
variable bool InvChanged=FALSE
function main()
{
	wait 30
	call AddButton
	Event[EQ2_onInventoryUpdate]:AttachAtom[InvChange]
	;Event[EQ2_ExamineItemWindowAppeared]:AttachAtom[CloseWindow]

	call addShinny
	while 2
		{
			if ${InvChanged}
				call addShinny
				
			waitframe
		}
}

function addShinny()
{
	variable index:item Items
	variable iterator ItemIterator
 
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	wait 5

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if !${ItemIterator.Value(exists)}
				continue
			if !${ItemIterator.Value.IsCollectible}
				continue
				
			echo ${ItemIterator.Value}
			Me.Inventory[${ItemIterator.Value}]:Examine
			wait 5
			EQ2UIPage[Journals,JournalsQuest].Child[button,TabPages.Collection.CollectionTemplate.AddButton]:LeftClick
			call ClickAddButton
			waitframe
			EQ2Execute /close_top_window
	;        echo "DEBUG:: Transmuting ${ItemIterator.Value}."
	
			;ItemIterator.Value:Transmute
			wait 5
		}
		while ${ItemIterator:Next(exists)}
	}

	InvChanged:Set[FALSE]
 	echo "All Done"
	; Me:Clear
}

atom CloseWindow()
{
EQ2Execute /close_top_window
}

atom InvChange()
{
InvChanged:Set[TRUE]
}

function AddButton()
{
	ToClickX:Set[${Mouse.X}]
	ToClickY:Set[${Mouse.Y}]
	MouseClickSet:Set[TRUE]
	echo Button Added
}
function ClickAddButton()
{
	Mouse:SetPosition[${ToClickX},${ToClickY}]
	wait 20
	Mouse:LeftClick
}
