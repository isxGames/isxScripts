/* -----------------------------------------------------------------------------------
 * EQ2AutoLogin.iss, Version 1.40 (05/13/07)
 * Created: By hegvape
 *
 * 1.00 (02/28/07) - Initial release
 * 1.01 (03/03/07) - Changed [LoginScene,LoginScene] to [LoginScene,LSUsernamePassword]
 * 1.20 (04/25/07) - Using Lavish commands to provide password.
 * 1.30 (04/27/07) - Should now work with and without ISXEQ2, added timer for first screen before doing clicks
 * 1.40 (05/13/07) - Load isxeq2 if not already loaded. Changed the way it waits for isxeq2.
 *	
 * Todo: Different states: 
 		1. isxeq2 loading ok
 		2. isxeq2 outdated (not paied for)
 		3. isxeq2 not updated, forced patch
 		4. isxeq2 ok but old verion of everquest2.exe
 		5. lavish script only - no isx
 		6. ...
 * -----------------------------------------------------------------------------------
 * Description:
 * Send password to the login screen and click the connect button
 * Syntax: run eq2autologin <Station Password>
 */

function main(string StationPwd)
{
	variable int CntMsClks=1
	/* Check if password has been supplied when starting the script */
	if !${StationPwd.Length}
	{
		/* Optionally You can specify Your station password here if you didn't provide it when starting the script */
		StationPwd:Set[-?]
	}
	switch ${StationPwd}
	{
		case ?
		case /?
		case -?
			echo " "
			echo "Syntax: run eq2autologin <Station Password>"
			echo " "
			echo "	Where <Station Password> specifies your station account password."
			echo " "
			echo "	Use the InnerSpace Configuration to create game profiles for different accounts & passwords"
			echo "	Add eq2autologin to the startup sequence of Your game profiles"
			echo "	If You want to automate Your login further then add the parameters, described below, to the"
			echo "	'Main executable parameters' section. use [Make Shortcut] button to create icons on Your desktop"
			echo " "
			echo "	Parameters for EverQuest2.exe: cl_username <Station Account>;cl_autoplay_char <Character Name>;cl_autoplay_world <World Server>"
			echo "	Note! Character names are case sensitive and You need to separate the commands with a semicolon ';'."
			return
		case Default
	}
	
	/* Try to load ISXEQ2 if not already loaded */
	if !${Extension[ISXEQ2](exists)}
		ext isxeq2

	/* Checking the state of ISXEQ2 and do some waiting */
	if ${Extension[ISXEQ2](exists)}
	{
		echo "Eq2AutoLogin: Waiting for ISXEQ2 to get ready..."
		wait 300 ${ISXEQ2.IsReady}
		echo "Eq2AutoLogin: ISXEQ2 should now be Ready!"
		wait 40
	}
	else
	{
		echo "Eq2AutoLogin: No ISXEQ2 extension loaded!"
		/* Wait for Advertisement to show on screen */
		wait 70
	}
				
	/* Do mouse clicks to speed up the login (SOE Logo, ESRB Rating, Advertisement, EQ2 Title) */
	CntMsClks:Set[1]
	do
	{
		MouseClick -hold left
		waitframe 
		MouseClick -release left 	
		waitframe
  }
	while ${CntMsClks:Inc}<=4
	
	/* Check if isxeq2 is loaded. If not loaded, then use lavish commands to login */
	if ${Extension[ISXEQ2](exists)} 
	{ 
		/* Wait for patcher to finish */
		echo "Eq2AutoLogin: Using ISXEQ2 Login..."
		do
		{
			waitframe
		}
		while !${ISXEQ2.IsReady} && ${Extension[ISXEQ2](exists)}
		waitframe		
  	EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,LSUsernamePassword.WindowPage.Password]:AddToTextBox[${StationPwd}]
		waitframe
		EQ2UIPage[LoginScene,LSUsernamePassword].Child[Button,LSUsernamePassword.WindowPage.ConnectButton]:LeftClick
	}
	
	/* isxeq2 NOT loaded. Use Lavish commands to provide the password */
	else
	{
		echo "Eq2AutoLogin: Using Lavish login..."
		variable int InputChar=1 
		;InputChar:Set[1]
		do 
		{
			if ${StationPwd.GetAt[${InputChar}]} >=65 && ${StationPwd.GetAt[${InputChar}]} <=90
		 	{
				Keyboard:Type[${StationPwd.Mid[${InputChar},1]}]
			}
			else
			{
				Keyboard:Type[${StationPwd.Mid[${InputChar},1]}]
			}
			waitframe
		}
		while ${StationPwd.Length} >= ${InputChar:Inc}
		squelch press Enter
		squelch press Retur
	}
	echo "Eq2AutoLogin: Script Done!"
}
