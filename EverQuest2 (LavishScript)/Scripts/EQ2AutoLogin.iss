/* -----------------------------------------------------------------------------------
 * EQ2AutoLogin.iss, Version 1.01 (03/03/07)
 * Created: By hegvape
 *
 * 1.00 (02/28/07) - Initial release
 * 1.01 (03/03/07) - Changed [LoginScene,LoginScene] to [LoginScene,LSUsernamePassword]
 *
 * -----------------------------------------------------------------------------------
 * Description:
 * Send password to the login screen and click the connect button
 * Syntax: run eq2autologin <Station Password>
 */

function main(string StationPwd)
{
	echo ",-------------------------------------------------------------------------------------------------------------------"
	echo "| EQ2AutoLogin.iss"	
	echo "|"
	echo "| Syntax: run eq2autologin <Station Password>"
	echo "| Where <Station Password> specifies your station password if not already provided inside the script"
	echo "| You can automate the Station Account name by starting everquest2.exe with the parameter 'cl_username YourUsername'"
	echo "| Use the InnerSpace uplink Console/Configuration to create different game profiles for different accounts/passwords"
	echo "`-------------------------------------------------------------------------------------------------------------------"

	/* Check if password has been supplied when starting the script */
	if !${StationPwd.Length} 
	{
		/* Specify Your station password here if you did not provide it when starting the script */
		StationPwd:Set[Station-password-here]
	}
	
	/* Do mouse clicks to speed up the login (SOE Logo, ESRB Rating, Advertisement, EQ2 Title) */
	variable int CntMsClks=1
	do
	{
		MouseClick -hold left
		waitframe 
		MouseClick -release left 	
		waitframe
  }
	while ${CntMsClks:Inc}<=4
	
	EQ2UIPage[LoginScene,LSUsernamePassword].Child[Textbox,LSUsernamePassword.WindowPage.Password]:AddToTextBox[${StationPwd}]
	waitframe
	EQ2UIPage[LoginScene,LSUsernamePassword].Child[Button,LSUsernamePassword.WindowPage.ConnectButton]:LeftClick
}