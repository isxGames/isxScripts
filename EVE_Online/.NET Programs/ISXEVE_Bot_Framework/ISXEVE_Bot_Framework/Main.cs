using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LavishScriptAPI;
using LavishVMAPI;

namespace ISXEVE_Bot_Framework
{
    class Main
    {
        /* LogIn class instance */
        LogIn _logIn = new LogIn();
        /* Config instance */
        Config _config = new Config();

        /* EventHandlers for Pulse */
        event EventHandler<LSEventArgs> Frame;

        /* Login, CharSelect, and Me references */
        EVE.ISXEVE.Login _login;
		EVE.ISXEVE.CharSelect _charSelect;
		EVE.ISXEVE.Me _me;

        public Main()
        {
            /* Attach Pulse to our Frame event handler */
            Frame += new EventHandler<LSEventArgs>(Pulse);

            /* Attach our AttachEvent to LogIn's LogInCompleted, so that it'll automatically re-attach OnFrame
             * upon completion of the login process */
            LogIn.LogInCompleted += new EventHandler(AttachEvent);
        }

        ~Main()
        {
            /* Detach Pulse from our Frame event handler */
            Frame -= new EventHandler<LSEventArgs>(Pulse);

            /* Clean up the LogInCompleted event */
            LogIn.LogInCompleted -= new EventHandler(AttachEvent);
        }

        public void LoadCharacters()
        {
            Settings.OpenSelectCharacter();

            if (Config.Instance.AutoStart)
            {
                Logging.OnLogMessage(this, "Main.LoadCharacters(): AutoStart enabled, starting.");
                Start();
            }
        }

        /* Attach to start the bot */
        public void Start()
        {
            AttachEvent();
        }

        /* Attach our Frame event handler to the OnFrame event */
        internal void AttachEvent()
        {
            LavishScript.Events.AttachEventTarget("ISXEVE_OnFrame", Frame);
			Logging.OnLogMessage(this, "AttachEvent(): Attaching Frame to ISXEVE_OnFrame");
        }

        /* Overload for AttachEvent */
        internal void AttachEvent(object sender, EventArgs e)
        {
            AttachEvent();
        }

        /* Detach our Frame event handler from the OnFrame event */
        internal void DetachEvent()
        {
			LavishScript.Events.DetachEventTarget("ISXEVE_OnFrame", Frame);
			Logging.OnLogMessage(this, "DetachEvent(): Detaching Frame from ISXEVE_OnFrame");
        }

        /* The method that will execute OnFrame */
        void Pulse(object sender, LSEventArgs e)
        {
            /* We have to use a FrameLock to do anything, even OnFrame */
            using (new FrameLock(true))
            {
                /* If Login exists, we're going to want to detach OnFrame so that we may do our login work */
				_login = new EVE.ISXEVE.Login();
				_charSelect = new EVE.ISXEVE.CharSelect();
                
                /* We must do this because trying to check Me validity when it isn't valid crashes, as does attempting
                 * to get a reference to any in-game object */
                if (_login.IsValid || _charSelect.IsValid)
                {
                    Logging.OnLogMessage(this, "Pulse(): At either Login or CharSelect screen; detaching and returning.");
                    DetachEvent();
                    _logIn.StartLogIn();
                    return;
                }

                /* If we're not at login or char select, we can get a Me reference */
				_me = new EVE.ISXEVE.Me();
                Logging.OnLogMessage(this, "Pulse(): Got new Me reference, Me.Corporation == " + _me.Corp.ID);
            }
        }
    }
}
