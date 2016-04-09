atom(script) EQ2_ActorSpawned(string ID, string Name, string Level, string ActorType)
{
	  ; This event is fired every time that an Actor Spawns.
	  
	  ; This is just here as an example of how to use the event.  You probably wouldn't
	  ; want to echo every spawn since it will spam you.
	  echo New Actor (ID: ${ID}): [Level: ${Level} Type: ${ActorType}] ${Name}
}

atom(script) EQ2_ActorDespawned(string ID, string Name)
{
	  ; This event is fired every time that an Actor Despawns
	  
	  ; This is just here as an example of how to use the event.  You probably wouldn't
	  ; want to echo every despawn since it will spam you.
	  echo Actor Despawned (ID: ${ID}) ${Name}
}

function main()
{
	  ; If ISXEQ2 isn't loaded, then no reason to run this script.
	  if (!${ISXEQ2(exists)})
	  	return
	  	
	  ;Initialize/Attach the event Atoms that we defined previously
		Event[EQ2_ActorSpawned]:AttachAtom[EQ2_ActorSpawned]
    Event[EQ2_ActorDespawned]:AttachAtom[EQ2_ActorDespawned]	
        
		;Tell the user that the script has initialized and is running!
		echo ISXEQ2 Events Sample Script ACTIVE
	
	  ; This bit of scripting tells the script to "waitframe" over and
	  ; over while ${ISXEQ2(exists)}.  In other words, as long as the 
	  ; extension is loaded.
		do 
		{
				waitframe
		}
		while ${ISXEQ2(exists)}
	
	  ;We're done with the script, so let's detach all of the event atoms
		Event[EQ2_ActorSpawned]:DetachAtom[EQ2_ActorSpawned]
    Event[EQ2_ActorDespawned]:DetachAtom[EQ2_ActorDespawned]	

    
    ;Send a final message telling the user that the script has ended
  	echo ISXEQ2 Events Sample Script INACTIVE
}