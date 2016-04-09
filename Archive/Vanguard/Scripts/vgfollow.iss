function main(string master, int leash=3)
{

   echo *******************************
   echo * Initializing 'vgfollow.iss' *
   echo *******************************
   ;    * ~ By Twiddle ****************
   ;    ***************************************
   ;    * Syntax: run vgfollow <name> <leash> *
   ;    *                                     *
   ;    *    Both parameters are optional     *
   ;    ***************************************

   if ${master.Equal[""]} && ${Me.DTarget(exists)}
	master:Set[${Me.DTarget.Name}]

   if ${master.Equal[""]}
   {
	echo -> Missing Parameter or Target
	endscript vgfollow
   }

   echo -> Leash set to: '${leash}'
   echo -> Using master: '${master}'

   if !${Pawn[name,${master}](exists)}
	   echo -> Waiting for '${master}' to enter the world
   end if

   do 
   {

	do 
	{
		wait 3
	}
	while !${Pawn[name,${master}](exists)}

	if ${Pawn[${master}].Distance} > ${leash}
	{

		Pawn[name,${master}]:Face

		VG:ExecBinding[AutoRun]

		echo -> Starting follow (Distance: ${Pawn[${master}].Distance})

		do
		{
			Pawn[name,${master}]:Face
			waitframe
		}
		while ${Pawn[${master}].Distance} > ${Math.Calc[${leash}-2]} && ${Pawn[name,${master}](exists)}

		if ${Pawn[name,${master}](exists)}
			echo -> Stopping follow (Distance: ${Pawn[${master}].Distance})
		else
			echo -> Stopping follow ('${master}' no longer exists)

		VG:ExecBinding[AutoRun,release]

	}

   }
   while 1

}