/* -----------------------------------------------------------------------------------
 * EQ2CheckExt.iss, Version 1.00 30-Apr-2007 Created: By SuperNoob
 * 
 * Simple include to verify isxeq2 is loaded and ready.  Waits for a predefined length of time
 * for the ext to be ready before failing.
 *
 * example (in your main function):
 * #include eq2checkext
 */
#define WAITEXTPERIOD 120

echo "Verifying ISXEQ2 is loaded and ready "
wait WAITEXTPERIOD ${ISXEQ2.IsReady}
if !${ISXEQ2.IsReady}
{
  echo ISXEQ2 could not be loaded.  Script aborting.
  Script:End	
}
echo ISXEQ2 is ready, go forth and script