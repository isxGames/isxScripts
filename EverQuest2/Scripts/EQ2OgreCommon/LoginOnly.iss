variable string BotVer=LoginOnly.1.00
/**
Auto login script. Used for logging in toons, and allows scripts easy access to login toons.
Written by: Kannkor

NOTE: In order to use the auto-login, you MUST have a login screen (loginscene) that does NOT retain information.
	There is currently no way (that I will use) to clear all fields via code. I have included an extremely basic loginscrene UI mod that keeps all fields clean.
	To use, copy the loginscene file into your UI directory.

**/

#include UICommon.inc
#include DoNotShareWithOthers/EQ2Chars.inc
function main(string LoginModifer, string CharToLogin)
{
	call FPreInit "${LoginModifer}" "${CharToLogin}"
}
function RegisterEvents()
{

}