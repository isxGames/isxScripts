using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace ISXEVE_Bot_Framework
{
    class Logging
    {
        /* Static instance */
        private static Logging _instance = new Logging();

        /* Internal static event for logging */
        internal static event EventHandler<LogMessageEventArgs> LogMessage;
        FileStream fs;
        StreamWriter sw;

        /* Private class, can only be instanced by itself */
        private Logging()
        {
            /* Attach our file logging to the logging event */
            LogMessage += new EventHandler<LogMessageEventArgs>(Logging_LogMessage);

            fs = new FileStream(String.Format("{0}\\{1}", InnerSpaceAPI.InnerSpace.Path, ".NET Programs\\ISXEVE_Bot_Framework_Log.txt"),
                FileMode.OpenOrCreate);
            sw = new StreamWriter(fs);
        }

        ~Logging()
        {
            fs.Dispose();
            sw.Dispose();
        }

        /* Log the message to a file */
        /* If I can't create or open a file, detach this method from the handler and log an error so that
         * anything else reading log messages (Form displaying them, for example) can read the error */
        void Logging_LogMessage(object sender, LogMessageEventArgs e)
        {
            /* Format our log message */
            string logMessage = String.Format("{0}: {1}: {2}", System.DateTime.Now.ToShortTimeString(),
                sender, e.Message);
            /* Write a new line to the logfile through our stream */
            sw.WriteLine(logMessage);
        }

        /* Fire off the LogMessage event */
        public static void OnLogMessage(object sender, string message)
        {
            /* If our event has targets */
            if (LogMessage != null)
                /* Fire the event */
                LogMessage(sender, new LogMessageEventArgs(message));
        }
    }

    /* EventArgs class for our log event */
    internal class LogMessageEventArgs : EventArgs
    {
        public string Message { get; set; }

        public LogMessageEventArgs(string message)
        {
            Message = message;
        }
    }
}
