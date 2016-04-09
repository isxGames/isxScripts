using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using LavishVMAPI;

namespace ISXEVE_Bot_Framework
{
    class LogIn
    {
        /* Private instance for logging */
        static LogIn _logIn;

        /* Flag for checking whether or not we've selected character */
        static bool _charSelected = false;

        /* Event for completing LogIn */
        public static event EventHandler LogInCompleted;

        /* Thread that will be used for the LogIn process */
        Thread _logInThread;

        /* Ultimately, I'll have to use a lengthy wait before checking whether or not I'm in the game, because CharSelect
         * will go invalid as soon as game loading begins, and checking Me.IsValid before it's valid also crashes, leaving
         * me with no way to determine if I'm still loading.
         * Our LogIn procsess must be thread-based due to OnFrame not working woth a damn for it. */
        public LogIn()
        {
            _logIn = this;
        }

        /* Notify anything attached to LogInCompleted that we have indeed completed login */
        protected static void OnLogInComplete()
        {
            if (LogInCompleted != null)
                LogInCompleted(_logIn, EventArgs.Empty);
        }

        public void StartLogIn()
        {
            if (_logInThread == null || !_logInThread.IsAlive)
            {
                Logging.OnLogMessage(this, "StartLogIn(): Starting login process.");

                /* Set and start our thread */
                _logInThread = new Thread(new ThreadStart(DoLogIn));
                _logInThread.IsBackground = true;
                _logInThread.Start();
            }
        }

        internal static void DoLogIn()
        {
            /* Flag for controlling the while loop, since return would kill the thread */
            bool shouldLoop = true;
            /* How long I'll wait between steps */
            int sleepTimer = 0;
            /* LogIn and CharSelect local variables */
			EVE.ISXEVE.CharSelect charSelect = new EVE.ISXEVE.CharSelect();
			EVE.ISXEVE.Login login;

            while (shouldLoop)
            {
                /* Use a new frame lock for every step, waiting at least one frame before re-locking to give EVE a break */
                using (new FrameLock(true))
                {
                    /* Update the login and reference */
					login = new EVE.ISXEVE.Login();
                    /* If Login is valid, we're sitting at the login screen. */
                    if (login.IsValid)
                    {
                        Logging.OnLogMessage(_logIn, "DoLogIn(): Login screen. Entering account info and connecting.");
                        /* If we're at the login screen, we should enter our info, connect, wait a while (10 seconds?)
                         * and then do char select. */
                        login.SetUsername(Settings.ActiveSettings.UserName);
                        login.SetPassword(Settings.ActiveSettings.PassWord);
                        login.Connect();
                        sleepTimer = 1;
                    }

                    /* If login was not valid, we should either be at charselect or ingame. */
                    else
                    {
                        /* Update CharSelect reference */
						charSelect = new EVE.ISXEVE.CharSelect();
                        /* If CharSelect also isn't valid, we're either loading or ingame. */
                        if (!login.IsValid && (!charSelect.IsValid || !charSelect.CharExists(Settings.ActiveSettings.ActiveCharacter.CharId)))
                        {
                            sleepTimer = 0;
                        }
                        else if (charSelect.IsValid)
                        {
                            /* We're at the CharSelect screen, so select a character. */
                            /* If we specified a character ID, first use it, then Click. */
                            if (Settings.ActiveSettings.ActiveCharacter.CharId > 0 && !_charSelected)
                            {
                                Logging.OnLogMessage(_logIn, "DoLogIn(): At CharSelect screen, selecting character.");
                                charSelect.ClickCharacter(Settings.ActiveSettings.ActiveCharacter.CharId);
                                /* Set _charSelected flag */
                                _charSelected = true;
                                /* This should take no more than five seconds */
                                sleepTimer = -2;
                            }
                            /* If we've either alread specified Character or didn't have one to specify,
                             * enter game. */
                            else
                            {
                                Logging.OnLogMessage(_logIn, "DoLogIn(): At CharSelect screen, entering game.");
                                /* Click our characte */
                                charSelect.ClickCharacter((int)charSelect.SelectedCharID); //todo -- don't cast this after the wrapper is fixed
                                /* Entering game could take up to 30 seconds */
                                sleepTimer = -1;
                                /* 30 seconds was too short, trying 40. */
                            }
                        }
                        /* If CharSelect was invalid as well, we're ingame. */
                        else if (LavishScriptAPI.LavishScriptObject.IsNullOrInvalid(login) &&
                            LavishScriptAPI.LavishScriptObject.IsNullOrInvalid(charSelect))
                        {
                            /* So stop looping. */
                            Logging.OnLogMessage(_logIn, "DoLogIn(): Stopping looping.");
                            shouldLoop = false;
                            break;
                        }
                    }
                }

                /* Either wait one frame or a specified length of time, whichever is longer. */
                if (sleepTimer > 0)
                {
                    Logging.OnLogMessage(_logIn, "DoLogIn(): Sleeping until Login is null or invalid.");
                    while (!LavishScriptAPI.LavishScriptObject.IsNullOrInvalid(login))
                        Thread.Sleep(0);
                }
                else if (sleepTimer == 0)
                {
                    Logging.OnLogMessage(_logIn, "DoLogIn(): Waiting a frame.");
                    Frame.Wait(false);
                }
                else if (sleepTimer == -1)
                {
                    Logging.OnLogMessage(_logIn, "DoLogIn(): Sleeping until CharSelect is null or invalid.");
                    while (!LavishScriptAPI.LavishScriptObject.IsNullOrInvalid(charSelect))
                        Thread.Sleep(0);
                }
                else
                {
                    Logging.OnLogMessage(_logIn, "DoLogIn(): Sleeping until CharSelect is valid and CharExists");
                }
            }
            /* Once outside the while loop, signal that we've finished login. */
            Logging.OnLogMessage(_logIn, "DoLogIn(): DoLogIn complete.");
            OnLogInComplete();
        }
    }
}
