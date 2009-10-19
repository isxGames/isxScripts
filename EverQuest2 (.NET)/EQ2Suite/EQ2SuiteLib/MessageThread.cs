/* "MessageThread.cs"
 *  
 * With the transition from C++/MFC to C#/.NET, I found myself wishing
 * I had a thread construct similar to Win32 threads with built-in message queues,
 * due to the ease of writing structured, asynchronous, highly complex software.
 * 
 * But I was unable to use the actual Win32 messaging for a number of reasons.
 * 
 * Firstly, a managed thread has no binding to the Win32 thread (or its system ID);
 * in fact, the CLR has the liberty of running a managed thread on any
 * varying number of actual threads in its lifetime.  Hell, it can even restrict
 * all managed threads to a single Win32 thread!
 * 
 * This means that sending a Win32 thread message might succeed but receiving
 * one might fail because you might not be running on the same system thread
 * you were 10 minutes ago.
 * 
 * Secondly, I don't know if the Win32 message queue is stored in user or kernel
 * space.  I erred in caution and assumed kernel. We want to avoid hoarding
 * kernel memory for application-level logic.
 * 
 * Thirdly, Win32 messages have a highly restrictive set of parameters. The
 * message type used here can be freely derived from.
 */

using System;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
//using System.Windows.Forms;
using System.Timers;
using System.Diagnostics;

namespace EQ2SuiteLib
{
	/***************************************************************************/
	/// <summary>
	/// 
	/// </summary>
	public abstract class MessageThread
	{
		#region Global Bookkeeping

		/// This protects all static data.
		private static object s_GlobalDataLock = new object();

		/// This maps managed thread ID's to TekMessageThread's.
		private static Dictionary<int, MessageThread> s_ActiveThreadDictionary = new Dictionary<int, MessageThread>();

		/***************************************************************************/
		public static MessageThread CurrentThread
		{
			get
			{
				MessageThread ThisMessageThread = null;

				lock(s_GlobalDataLock)
				{
					/// If this fails, ThisMessageThread will remain null.
					s_ActiveThreadDictionary.TryGetValue(Thread.CurrentThread.ManagedThreadId, out ThisMessageThread);
				}

				return ThisMessageThread;
			}
		}

		/***************************************************************************/
		public static List<MessageThread> EnumThreads()
		{
			lock (s_GlobalDataLock)
			{
				List<MessageThread> ThreadList = new List<MessageThread>(s_ActiveThreadDictionary.Values.Count);
				foreach (MessageThread ThisThread in s_ActiveThreadDictionary.Values)
					ThreadList.Add(ThisThread);
				return ThreadList;
			}
		}

		/***************************************************************************/
		public delegate void LastChanceExceptionHandlerType(MessageThread SourceThread, Exception e);

		/// The anonymous delegate initializer means I'll never have to worry about checking "null".
		/// The downside is that this empty delegate will always be called.  But who gives a fuck anyway.
		private static event LastChanceExceptionHandlerType s_LastChanceExceptionHandler = delegate { };

		/***************************************************************************/
		public static event LastChanceExceptionHandlerType LastChanceExceptionHandler
		{
			add
			{
				lock (s_GlobalDataLock)
				{
					s_LastChanceExceptionHandler += value;
				}
			}
			remove
			{
				lock (s_GlobalDataLock)
				{
					s_LastChanceExceptionHandler -= value;
				}
			}
		}

		/***************************************************************************/
		public static void CallLastChanceExceptionHandlers(Exception e)
		{
			lock (s_GlobalDataLock)
			{
				s_LastChanceExceptionHandler(MessageThread.CurrentThread, e);
			}
			return;
		}

		#endregion

		#region Instance Member Variables

		/************************************************************************************/
		private object m_Lock = new object();
		private EventWaitHandle m_ThreadInactiveEvent = new EventWaitHandle(true, EventResetMode.ManualReset);
		private EventWaitHandle m_QueueFilledEvent = new EventWaitHandle(false, EventResetMode.ManualReset);
		private Queue<ThreadMessage> m_MessageQueue = new Queue<ThreadMessage>();
		private WaitHandle[] m_aWaitHandles = new WaitHandle[0];
		private SortedDictionary<int, TimerDesc> m_Timers = new SortedDictionary<int, TimerDesc>();
		private Thread m_Thread = null;
		private string m_strName = null;

		/// <summary>
		/// This set contains all timer ID's who have generated a pulse.
		/// </summary>
		private SetCollection<int> m_PulsedTimers = new SetCollection<int>();

		/// <summary>
		/// This is created once per thread because it's more efficient than creating on-the-fly.
		/// </summary>
		internal EventWaitHandle m_CallMessageCompletedEvent = new EventWaitHandle(false, EventResetMode.ManualReset);

		// We assume upon creation that this thread will process all
		//  messages it receives up to the moment of its invocation.
		private bool m_bAcceptNewMessages = true;

		/// <summary>
		/// If the thread is saturated with messages, then OnIdle runs the risk of never getting called.
		/// This variable does some bookkeeping to force an OnIdle call every so often if starvation occurs.
		/// OnIdle is too valuable for our algorithms to run such a risk.
		/// </summary>
		private DateTime m_LastOnIdleLocalCallTime = DateTime.Now;

		/************************************************************************************/
		private TimeSpan m_MaxIdleStarvationTimeSpan = TimeSpan.FromMinutes(0.5);
		protected TimeSpan MaxIdleStarvationTimeSpan
		{
			get { return m_MaxIdleStarvationTimeSpan; }
			set { m_MaxIdleStarvationTimeSpan = value; }
		}

		#endregion

		#region Boilerplate Startup & Entry-Point Code

		/***************************************************************************/
		public void Start()
		{
			/// TODO: Protect this variable access?
			if (null != m_Thread)
			{
				throw new Exception("Blocked attempt to start a thread instance that is already running.");
			}

			lock(m_Lock)
			{
				try
				{
					m_bAcceptNewMessages = true;
					m_Thread = new Thread(new ThreadStart(this.ThreadStartEntryPoint));

					/// Set the name if one is given, otherwise let the derived class do it later.
					if (!String.IsNullOrEmpty(m_strName))
						m_Thread.Name = m_strName;

					m_Thread.Start();
				}
				catch	(Exception e)
				{
					m_bAcceptNewMessages = false;
					throw new Exception ("TekMessageThread.Start() failed.", e);
				}
			}
			return;
		}

		/***************************************************************************/
		/// <summary>
		/// This is the C# entry point for the thread.
		/// Its sole purpose is to invoke the virtual Run function.
		/// </summary>
		private void ThreadStartEntryPoint()
		{
			Exception exUnhandled = null;

			try
			{
				lock (s_GlobalDataLock)
					s_ActiveThreadDictionary.Add(Thread.CurrentThread.ManagedThreadId, this);

				m_ThreadInactiveEvent.Reset();

				RegisterWaitHandle(m_QueueFilledEvent);
				
				Run();
			}

			/// All unhandled exceptions enter this block.
			catch (Exception e)
			{
				exUnhandled = e;
			}

			/// The special ThreadAbortException will always guarantee the execution of this finally-block.
			finally
			{
				lock (s_GlobalDataLock)
					s_ActiveThreadDictionary.Remove(Thread.CurrentThread.ManagedThreadId);

				m_bAcceptNewMessages = false;
				m_ThreadInactiveEvent.Set();

				/// If this thread is dying because of an unhandled exception,
				/// then we NOW run the handler, once we're safe outside any locks.
				if (null != exUnhandled)
				{
					/// Thread-safe eventing is bizarre.
					/// For now I'll assume I won't have to copy the event list into a temp object
					/// for safe synchronization (I can't figure out how to anyway).
					/// http://blogs.msdn.com/jaybaz_ms/archive/2004/03/19/92787.aspx
					/// http://blogs.msdn.com/jaybaz_ms/archive/2004/06/17/158636.aspx
					try
					{
						lock (s_GlobalDataLock)
							s_LastChanceExceptionHandler(this, exUnhandled);
					}
					catch
					{
						/// We intend to leave this thread without ANY further exceptions.
					}
				}

				/// Gather any data from the thread, then sever the connection to the live object(s).
				/// This will allow this thread object to be restarted, which may or may not be convenient.
				lock (m_Lock)
				{
					// Destroy all of the timers.
					foreach (TimerDesc ThisTimerDesc in m_Timers.Values)
					{
						ThisTimerDesc.m_Timer.Stop();
						ThisTimerDesc.m_Timer.Dispose();
					}

					m_Timers.Clear();
					m_PulsedTimers.Clear();
					m_Thread = null;
					ClearMessageQueue();
				}
			}

			return;
		}

		/***************************************************************************/
		/// <summary>
		/// Derived classes override this function for their entry point.
		/// </summary>
		/// <returns></returns>
		protected virtual int Run()
		{
			DoMessageLoop(false);
			return 0;
		}

		#endregion

		#region Message Queue

		/************************************************************************************/
		/// <summary>
		/// Derive more complex message types from this according to your needs.
		/// </summary>
		public class ThreadMessage
		{
			/// <summary>
			/// Yes, this lock is ABSOLUTELY necessary even though CallMessage() and SignalReply() seem synchronous to each other (see below).
			/// </summary>
			private object m_objLock = new object();

			private EventWaitHandle m_WaitHandle = null;
			internal bool m_bAbortedCall = false;
			internal DateTime m_PostLocalTime = DateTime.FromBinary(0);

			internal EventWaitHandle WaitHandle
			{
				set
				{
					lock (m_objLock)
					{
						m_WaitHandle = value;
					}
					return;
				}
			}

			public DateTime PostTime
			{
				get
				{
					return m_PostLocalTime;
				}
			}

			public void SignalReply()
			{
				lock (m_objLock)
				{
					/// Before I added the lock, a bizarre thing would happen where the wait handle would survive the null check
					/// and then get set to null from elsewhere just before being accessed here.
					if (null != m_WaitHandle)
					{
						//Debug.WriteLine("SignalReply() called from thread \"" + TekMessageThread.CurrentThread.Name + "\"");

						m_WaitHandle.Set();
						m_WaitHandle = null;
						m_bAbortedCall = false;
					}
				}
				return;
			}

			/// <summary>
			/// This function is not intended for generic failure conditions,
			/// but instead only for when the destination thread is terminating.
			/// </summary>
			internal void SignalAbort()
			{
				lock (m_objLock)
				{
					if (null != m_WaitHandle)
					{
						m_WaitHandle.Set();
						m_WaitHandle = null;
						m_bAbortedCall = true;
					}
				}
				return;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// This forces the idle handler to execute once again even if no new messages were added to the queue.
		/// </summary>
		public void KickIdle()
		{
			lock (m_Lock)
			{
				/// We trick GetMessage() into thinking there's another message.
				m_QueueFilledEvent.Set();
			}
			return;
		}

		/************************************************************************************/
		private static readonly ThreadMessage s_DummyNullMessage = new ThreadMessage();

		/// <summary>
		/// This is often used to kick the OnIdle() handling.
		/// This message is of zero data purpose to anyone outside of that.
		/// </summary>
		public void PostNullMessage()
		{
			PostMessage(s_DummyNullMessage);
			return;
		}

		/************************************************************************************/
		/// We make this a type rather than invading the message ID namespace
		/// that the application might decide on.
		public class QuitMessage : ThreadMessage
		{
		}

		/************************************************************************************/
		/// <summary>
		/// This is the friendly way to tell a thread to exit.
		/// </summary>
		/// <remarks>
		/// Derived threads might even create their own versions depending on what parameters
		/// they might want to convey.
		/// </remarks>
		public void PostQuitMessage()
		{
			PostMessage(new QuitMessage());
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// This function posts a quit message in the queue,
		/// guarantees it to be the only message in the queue,
		/// and forbids others from adding messages on top of it.
		/// </summary>
		/// <remarks>
		/// Sometimes a thread encounters a fatal condition and needs to cancel cleanly without question.
		/// There is no harm in calling this multiple times, even on a dead thread.
		/// </remarks>
		public void PostQuitMessageAndShutdownQueue(bool bClearQueue)
		{
			// Fortunately, critical sections are re-entrant.
			lock (m_Lock)
			{
				m_bAcceptNewMessages = true;
				if (bClearQueue)
					ClearMessageQueue();
				PostQuitMessage();
				m_bAcceptNewMessages = false;
			}

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// I made this bitch "protected" so that people couldn't post fake wait messages.
		/// And the member variables are read-only to prevent tampering.
		/// Timers are serious business!
		/// </summary>
		protected class WaitHandleSignalledMessage : ThreadMessage
		{
			private WaitHandle m_WaitHandle = null;
			public WaitHandle SignalledHandle { get { return m_WaitHandle; } }
			public WaitHandleSignalledMessage(WaitHandle ThisHandle)
			{
				m_WaitHandle = ThisHandle;
				return;
			}
		}

		/************************************************************************************/
		protected void RegisterWaitHandle(WaitHandle ThisHandle)
		{
			List<WaitHandle> TempList = new List<WaitHandle>(m_aWaitHandles);
			if (TempList.IndexOf(ThisHandle) != -1)
				throw new DuplicateWaitObjectException("Wait handle already exists in thread list."); /// Wow, I had no f'ing idea this exception type existed.

			TempList.Add(ThisHandle);
			m_aWaitHandles = TempList.ToArray();
			return;
		}

		/************************************************************************************/
		protected void UnregisterWaitHandle(WaitHandle ThisHandle)
		{
			List<WaitHandle> TempList = new List<WaitHandle>(m_aWaitHandles);
			int iLocation = TempList.IndexOf(ThisHandle);
			if (iLocation == -1)
				throw new ArgumentException("Wait handle doesn't exist in thread list.");

			TempList.RemoveAt(iLocation);
			m_aWaitHandles = TempList.ToArray();
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="NewEvent"></param>
		public bool PostMessage(ThreadMessage NewEvent)
		{
			if (null == NewEvent)
				return false;

			lock(m_Lock)
			{
				// First thing is check if the thread is even in a position to take messages.
				if (!m_bAcceptNewMessages)
					return false;

				NewEvent.m_PostLocalTime = DateTime.Now;
				m_MessageQueue.Enqueue(NewEvent);

				// Only set the event when transitioning from 0 to 1 total item(s).
				// This spares us a kernel call.
				if (m_MessageQueue.Count == 1)
					m_QueueFilledEvent.Set();
			}
			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Waits for a message to be handled by the thread before returning.
		/// </summary>
		/// <remarks>
		/// Can be called from any thread, but requires the receiving thread to call
		/// ThreadMessage.SignalReply() upon completion of processing.
		/// If called on the same thread as the destination,
		/// then it requires OnMessage() to be implemented.
		/// </remarks>
		/// <param name="NewMessage"></param>
		public bool CallMessage(ThreadMessage NewMessage, TimeSpan? WaitSpan)
		{
			/// TODO: Make sure this thread is even active, otherwise this call will crash.

			MessageThread CallerThread = CurrentThread;

			/// If we're calling from within the same thread...
			if (null != CallerThread && CallerThread.ID == ID)
			{
				OnMessage(NewMessage);
			}

			/// If we're calling from another thread...
			else
			{
				EventWaitHandle TempWaitHandle = null;

				if (null == CallerThread)
					TempWaitHandle = new EventWaitHandle(false, EventResetMode.ManualReset); // The GC will need to destroy this.
				else
					TempWaitHandle = CallerThread.m_CallMessageCompletedEvent;

				NewMessage.WaitHandle = TempWaitHandle;

				TempWaitHandle.Reset();
				PostMessage(NewMessage);

				/// Wait for the destination thread to reply to the message.
				if (WaitSpan == null)
				{
#if DEBUG
					/// This is EXTREMELY valuable in helping to find deadlocks.
					/// NOTE: It might happen inadvertently during debug breakpoints. Ignore it during these times.
					Debug.Assert(TempWaitHandle.WaitOne(30000, false), "CallMessage reply not received within 30 seconds from thread:\n\n" + Name);
#else
					TempWaitHandle.WaitOne();
#endif
				}
				else
				{
					if (!TempWaitHandle.WaitOne(WaitSpan.Value, false))
						return false;
				}

				if (NewMessage.m_bAbortedCall)
					return false;
			}

			return true;
		}

		/************************************************************************************/
		public bool CallMessage(ThreadMessage NewMessage)
		{
			return CallMessage(NewMessage, null);
		}

		/************************************************************************************/
		public class PingMessage : ThreadMessage
		{
			private List<KeyValuePair<string, string>> m_aInfoList = new List<KeyValuePair<string, string>>();

			public void AddInfo(string strKey, object objValue)
			{
				m_aInfoList.Add(new KeyValuePair<string,string>(strKey, objValue.ToString()));
				return;
			}

			public IEnumerable<KeyValuePair<string, string>> EnumInfo()
			{
				foreach (KeyValuePair<string, string> ThisPair in m_aInfoList)
					yield return ThisPair;
			}
		}

		/************************************************************************************/
		public PingMessage Ping(TimeSpan WaitTime)
		{
			if (!IsAlive)
				return null;

			PingMessage NewMessage = new PingMessage();
			if (!CallMessage(NewMessage, WaitTime))
				return null;

			return NewMessage;
		}

		/************************************************************************************/
		/// <summary>
		/// Retrieves a message from the queue.
		/// </summary>
		/// <remarks>
		/// This function will throw an exception if called from outside the context of the owner thread.
		/// </remarks>
		/// <param name="bWaitForMessageIfEmpty"></param>
		/// <returns>Returns NULL if no message was in the queue.</returns>
		protected ThreadMessage GetMessage(bool bWaitForMessageIfEmpty)
		{
			int iWaitObjectIndex = -1;
			if (bWaitForMessageIfEmpty)
				iWaitObjectIndex = WaitHandle.WaitAny(m_aWaitHandles); // TODO: Should we figure a way to abort this?
			else
				iWaitObjectIndex = WaitHandle.WaitAny(m_aWaitHandles, 0, false);

			WaitHandle ThisSignalledHandle = null;
			if (iWaitObjectIndex != WaitHandle.WaitTimeout)
				ThisSignalledHandle = m_aWaitHandles[iWaitObjectIndex];

			/// If a wait was signalled and it wasn't the standard queue filled event, return it.
			/// The recipient has an obligation to clear the signal or unregister the handle,
			/// otherwise the next call to GetMessage will return the same handle.
			if (ThisSignalledHandle != null && ThisSignalledHandle.SafeWaitHandle != m_QueueFilledEvent.SafeWaitHandle)
			{
				return new WaitHandleSignalledMessage(ThisSignalledHandle);
			}

			ThreadMessage NewIncomingMessage = null;

			lock(m_Lock)
			{
				// Dummy check.
				if (m_Thread.ManagedThreadId != Thread.CurrentThread.ManagedThreadId)
					throw new Exception("TekMessageThread.GetMessage can only be called from the context of the owner thread.");

				/// Check for any legit messages.
				if (m_MessageQueue.Count > 0)
				{
					NewIncomingMessage = m_MessageQueue.Dequeue();
				}

				/// Check our timer list and generate a pseudo-message.
				/// Timers have lowest priority just like Win32 because if the messages build
				/// up and if the message handler takes time to process (such as connection timeout),
				/// then the backlog of messages will drown out any other processing.
				else if (m_PulsedTimers.Count > 0)
				{
					int iTimerID = m_PulsedTimers[0];
					m_PulsedTimers.Remove(iTimerID);

					TimerDesc ThisTimerDesc = m_Timers[iTimerID];
					NewIncomingMessage = new TimerMessage(iTimerID, ThisTimerDesc.m_Context, ThisTimerDesc.m_Timer.Interval);
				}

				/// Now that there is NOTHING to retrieve, make the event block again.
				if (QueuedMessageCount == 0)
				{
					m_QueueFilledEvent.Reset();
				}
			}

			return NewIncomingMessage;
		}

		/************************************************************************************/
		/// <summary>
		/// This is the "proper" way to empty the message queue because it lets other threads who used
		/// CallMessage() know that they just got fucked. Leaving them in the dark isn't as fun when
		/// you're trashing your own process, ya know?
		/// </summary>
		protected void ClearMessageQueue()
		{
			lock (m_Lock)
			{
				while (m_MessageQueue.Count > 0)
				{
					ThreadMessage NextMessage = m_MessageQueue.Dequeue();
					NextMessage.SignalAbort();
				}
			}
		}

		/************************************************************************************/
		/// <summary>
		/// How many messages are currently waiting in the queue.
		/// </summary>
		public int QueuedMessageCount
		{
			get
			{
				lock (m_Lock)
				{
					int iTotal = m_MessageQueue.Count + m_PulsedTimers.Count;

					int iWaitStatus = WaitHandle.WaitAny(m_aWaitHandles, 0, false);
					if (iWaitStatus != WaitHandle.WaitTimeout && m_aWaitHandles[iWaitStatus].SafeWaitHandle != m_QueueFilledEvent.SafeWaitHandle)
						iTotal++;

					return iTotal;
				}
			}
		}

		/************************************************************************************/
		/// <summary>
		/// This is just a helper function.  Derived classes may or may not use this at their whim.
		/// The default Run() implementation calls this automatically.
		/// </summary>
		/// <returns>false if bExitIfEmptyQueue is true and a quit message was encountered.</returns>
		protected bool DoMessageLoop(bool bExitIfEmptyQueue)
		{
			while (true)
			{
				if (bExitIfEmptyQueue && QueuedMessageCount == 0)
					return true;

				ThreadMessage NextMessage = GetMessage(true);
				if (NextMessage != null)
				{
					try
					{
						OnMessage(NextMessage);
					}
					finally
					{
						/// Signal the message in case the handler forgets.
						/// NOTE: Don't do this anymore.
						/// Some derived threads get into the practice of caching and reordering messages for later processing.
						//NextMessage.SignalReply();
					}

					if (NextMessage is QuitMessage)
					{
						if (bExitIfEmptyQueue)
							return false;
						else
							break;
					}
					else if (NextMessage is PingMessage)
					{
						NextMessage.SignalReply();
					}
				}

				/// Call the idle handler if the queue is empty OR if starvation is occuring.
				if (QueuedMessageCount == 0 || (DateTime.Now - m_LastOnIdleLocalCallTime) > MaxIdleStarvationTimeSpan)
				{
					m_LastOnIdleLocalCallTime = DateTime.Now;
					OnIdle();
				}
			}

			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// This is a companion callback to DoMessageLoop().
		/// </summary>
		/// <param name="NewMessage"></param>
		protected virtual void OnMessage(ThreadMessage NewMessage)
		{
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// This is a companion callback to DoMessageLoop() that gets called whenever the
		/// message queue transitions from having at least one message to becoming empty.
		/// </summary>
		protected virtual void OnIdle()
		{
			return;
		}

		#endregion

		#region Timer Messaging

		/************************************************************************************/
		private class TimerDesc
		{
			public int m_iTimerID = 0;
			public System.Timers.Timer m_Timer = null;
			public MessageThread m_OwnerThread = null;
			public object m_Context = null;
			public TimerDesc(int iNewTimerID, System.Timers.Timer NewTimer, MessageThread OwnerThread, object NewContext)
			{
				m_iTimerID = iNewTimerID;
				m_Timer = NewTimer;
				m_OwnerThread = OwnerThread;
				m_Context = NewContext;
				return;
			}
			public void OnTimedEvent(object SourceObject, ElapsedEventArgs e)
			{
				m_OwnerThread.NotifyTimerPulse(m_iTimerID, true);
				return;
			}
		}

		/************************************************************************************/
		/// <summary>
		/// I made this bitch "protected" so that people couldn't post fake timer messages.
		/// And the member variables are read-only to prevent tampering.
		/// Timers are serious business!
		/// </summary>
		protected class TimerMessage : ThreadMessage
		{
			private int m_iTimerID = 0;
			public int TimerID { get { return m_iTimerID; } }
			private object m_Context = null;
			public object Context { get { return m_Context; } }
			private TimeSpan m_IntervalSpan = new TimeSpan();
			public TimeSpan Interval { get { return m_IntervalSpan; } }
			public TimerMessage(int iTimerID, object ContextObject, double fIntervalMilliseconds)
			{
				m_iTimerID = iTimerID;
				m_Context = ContextObject;
				m_IntervalSpan = TimeSpan.FromMilliseconds(fIntervalMilliseconds);
				return;
			}
		}

		/************************************************************************************/
		protected void CreateTimer(int iNewTimerID, double fIntervalMilliseconds, object objContext)
		{
			lock (m_Lock)
			{
				if (m_Timers.ContainsKey(iNewTimerID))
					throw new Exception("Cannot create timers with duplicate ID's.");

				System.Timers.Timer NewTimer = new System.Timers.Timer();
				NewTimer.Interval = fIntervalMilliseconds;

				TimerDesc NewTimerDesc = new TimerDesc(iNewTimerID, NewTimer, this, objContext);
				m_Timers.Add(iNewTimerID, NewTimerDesc);

				NewTimer.Elapsed += new ElapsedEventHandler(NewTimerDesc.OnTimedEvent);
				NewTimer.Start(); // GO!
			}
			return;
		}

		/************************************************************************************/
		protected void CreateTimer(int iNewTimerID, TimeSpan IntervalSpan, object objContext)
		{
			CreateTimer(iNewTimerID, IntervalSpan.TotalMilliseconds, objContext);
			return;
		}

		/************************************************************************************/
		protected void KillTimer(int iTimerID)
		{
			lock (m_Lock)
			{
				TimerDesc ThisTimerDesc = null;
				if (!m_Timers.TryGetValue(iTimerID, out ThisTimerDesc))
					return;
				m_Timers.Remove(iTimerID);

				ThisTimerDesc.m_Timer.Stop();
				ThisTimerDesc.m_Timer.Dispose();

				/// Remove the timer from the pulse table.
				NotifyTimerPulse(iTimerID, false);
			}
			return;
		}

		/************************************************************************************/
		/// <summary>
		/// The timer calls this to let the thread know to generate a fake message for the timer.
		/// </summary>
		internal void NotifyTimerPulse(int iTimerID, bool bPulse)
		{
			lock (m_Lock)
			{
				if (bPulse)
				{
					m_PulsedTimers.Add(iTimerID);

					/// Fool the derived thread into thinking a message is available.
					m_QueueFilledEvent.Set();
				}
				else
				{
					m_PulsedTimers.Remove(iTimerID);
				}
			}

			return;
		}

		#endregion

		#region Miscellaneous

		/************************************************************************************/
		/// <summary>
		/// This is the name of the thread, useful from the debugger.
		/// This is a write-once value; subsequent writes will only take place if the thread is restarted.
		/// </summary>
		public string Name
		{
			get
			{
				lock (m_Lock)
				{
					return m_strName;
				}
			}
			set
			{
				lock (m_Lock)
				{
					m_strName = value;

					if (null != m_Thread)
						m_Thread.Name = m_strName;
				}
				return;
			}
		}

		/************************************************************************************/
		public int ID
		{
			get
			{
				lock (m_Lock)
				{
					return m_Thread.ManagedThreadId;
				}
			}
		}

		/************************************************************************************/
		public bool IsAlive
		{
			get
			{
				lock (m_Lock)
				{
					return (m_Thread != null) && (m_Thread.IsAlive);
				}
			}
		}

		/************************************************************************************/
		public bool WaitForTermination(TimeSpan WaitTimeout)
		{
			//throw new NotImplementedException("TekMessageThread.WaitForTermination is not yet implemented.");
			//m_Thread.Join(iTimeout);
			if (!m_ThreadInactiveEvent.WaitOne((int)WaitTimeout.TotalMilliseconds, false))
				return false;

			return true;
		}

		#endregion
	}
}
