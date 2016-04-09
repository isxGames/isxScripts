variable(script) index:bookmark MyBookmarks
variable(script) bookmark HomeBookmark
variable(script) int Sorting = 1
objectdef obj_Bookmarks
{

	variable index:bookmark ObjBookmarks
	variable int ObjBookmarkCount
	variable iterator ObjBMIter
	

	method Initialize()
	{
	}

	method Acquire(string BMFilter)
	{
		BotCurrentState:Set["Acquiring bookmarks"]
		StatusUpdate:Yellow["Acquiring bookmarks"]
		ObjBookmarks:Clear
		MyBookmarks:Clear
		EVE:DoGetBookmarks[ObjBookmarks]
		StatusUpdate:Yellow["${ObjBookmarks.Used} bookmarks total"]
		ObjBookmarks:GetIterator[ObjBMIter]
		
		if ${ObjBMIter:First(exists)}
		do
		{
			if ${ObjBMIter.Value.Label.Find[${${BMFilter}BookmarkIdentifier}]} > 0
				MyBookmarks:Insert[${ObjBMIter.Value}]
			elseif ${ObjBMIter.Value.Label.Find[${HomeBookmarkIdentifier}]} > 0
				HomeBookmark:Set[${ObjBMIter.Value}]
		}
		while ${ObjBMIter:Next(exists)}
	}

	function GoTo(bookmark ObjGoToBookmark)
	{
		BotCurrentState:Set["GoTo"]
		StatusUpdate:Green["GoTo - ${ObjGoToBookmark.Label}"]
		StatusUpdate:Yellow["Begin GoTo"]
		variable int ObjDestinationCount
		
		if ${Me.InStation}
			call TheShip.Undock
			
		if ${ObjGoToBookmark.SolarSystemID} != ${Me.SolarSystemID}
		{
			BotCurrentState:Set["Auto Pilot"]
			StatusUpdate:Yellow["Bookmark not in system"]
			StatusUpdate:Green["Bookmark not in system, Autopilot"]
			do
			{
				ObjDestinationCount:Set[0]
				do
				{
					ObjGoToBookmark:SetDestination
					ObjDestinationCount:Set[${EVE.GetToDestinationPath}]
					wait ${Slow}
					StatusUpdate:Yellow["Destination count - ${ObjDestinationCount}"]
				}
				while ${ObjDestinationCount} < 1
				do
				{
					EVE:Execute[CmdToggleAutopilot]
					wait ${Math.Calc[${Slow} * 2]}
					StatusUpdate:Yellow["Autopilot on - ${Me.AutoPilotOn}"]
				}
				while !(${Me.AutoPilotOn})
				do
				{
					StatusUpdate:Yellow["Autopilot wait"]
					if ${EntityWatchOn}
						call StatusUpdate.White
					wait ${Math.Calc[${Slow} * 4]}
				}
				while ${Me.AutoPilotOn}
				do
				{
					wait ${Slow}
					StatusUpdate:Yellow["Cloaked - ${Me.ToEntity.IsCloaked}"]
				}
				while !(${Me.ToEntity.IsCloaked})
				wait ${Math.Calc[${Slow} * 4]}
			}
			while ${ObjGoToBookmark.SolarSystemID} != ${Me.SolarSystemID}
		}
		StatusUpdate:Yellow["GoTo in system"]
		BotCurrentState:Set["Warping"]
		StatusUpdate:Green["Bookmark in system, Warp"]
		do
		{
			ObjGoToBookmark:WarpTo
			wait ${Slow}
			StatusUpdate:Yellow["WarpTo should be 3 - ${Me.ToEntity.Mode}"]
		}
		while ${Me.ToEntity.Mode} != 3
		do
		{
			StatusUpdate:Yellow["Warping is 3 - ${Me.ToEntity.Mode}"]
			if ${EntityWatchOn}
				call StatusUpdate.White
			wait ${Slow}
		}
		while ${Me.ToEntity.Mode} == 3
		if ${ObjGoToBookmark.ToEntity(exists)}
		{
			BotCurrentState:Set["Approaching"]
			StatusUpdate:Yellow["GoTo found a station"]
			StatusUpdate:Green["Bookmark is a station, docking"]
			do
			{
				ObjGoToBookmark.ToEntity:Approach
				if ${EntityWatchOn}
					call StatusUpdate.White
				wait ${Math.Calc[${Slow} * 4]}
				StatusUpdate:Green["Approach left - ${ObjGoToBookmark.ToEntity.Distance}"]
			}
			while ${ObjGoToBookmark.ToEntity.Distance} > 400
			do
			{
				BotCurrentState:Set["Docking"]
				ObjGoToBookmark.ToEntity:Dock
				wait ${Math.Calc[${Slow} * 4]}
				StatusUpdate:Green["Still in space - ${Me.InSpace}"]
			}
			while ${Me.InSpace}
			wait ${Math.Calc[${Slow} * 4]}
			StatusUpdate:Green["Docked"]
		}
	}
}