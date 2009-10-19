using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using EQ2SuiteLib;

namespace EQ2GlassCannon
{
	/************************************************************************************/
	public class EmailQueueThread : MessageThread
	{
		/************************************************************************************/
		public class SMTPProfile
		{
			public string m_strServer = string.Empty;
			public int m_iPort = 25;
			public bool m_bUseSSL = false;
			public string m_strAccount = string.Empty;
			public string m_strPassword = string.Empty;
			public string m_strFromAddress = string.Empty;

			/************************************************************************************/
			public SMTPProfile Copy()
			{
				SMTPProfile NewProfile = new SMTPProfile();
				NewProfile.m_strServer = m_strServer;
				NewProfile.m_iPort = m_iPort;
				NewProfile.m_bUseSSL = m_bUseSSL;
				NewProfile.m_strAccount = m_strAccount;
				NewProfile.m_strPassword = m_strPassword;
				NewProfile.m_strFromAddress = m_strFromAddress;
				return NewProfile;
			}

			/************************************************************************************/
			public bool SendEMail(
				List<string> astrToAddressList,
				string strSubject,
				string strMessage)
			{
				try
				{
					SmtpClient ThisClient = new SmtpClient(m_strServer, m_iPort);

					bool bUsePassword = !string.IsNullOrEmpty(m_strAccount) || !string.IsNullOrEmpty(m_strPassword);
					if (bUsePassword)
					{
						ThisClient.Credentials = new System.Net.NetworkCredential(m_strAccount, m_strPassword);
						ThisClient.EnableSsl = m_bUseSSL;
					}

					foreach (string strThisToAddress in astrToAddressList)
					{
						ThisClient.Send(m_strFromAddress, strThisToAddress, strSubject, strMessage);
					}
				}
				catch
				{
					return false;
				}

				return true;
			}
		}

		/************************************************************************************/
		protected SMTPProfile m_CurrentProfile = null;

		/************************************************************************************/
		protected class NewProfileMessage : ThreadMessage
		{
			public SMTPProfile m_NewProfileCopy = null;
			public NewProfileMessage(SMTPProfile NewSettings)
			{
				m_NewProfileCopy = NewSettings.Copy();
				return;
			}
		}

		/************************************************************************************/
		public void PostNewProfileMessage(SMTPProfile NewProfile)
		{
			PostMessage(new NewProfileMessage(NewProfile));
			return;
		}

		/************************************************************************************/
		protected class EmailMessage : ThreadMessage
		{
			public List<string> m_astrToAddresses = null;
			public string m_strSubject = string.Empty;
			public string m_strBody = string.Empty;
			public EmailMessage(
				List<string> astrToAddresses,
				string strSubject,
				string strBody)
			{
				m_astrToAddresses = new List<string>(astrToAddresses);
				m_strSubject = strSubject;
				m_strBody = strBody;
				return;
			}
		}

		/************************************************************************************/
		public void PostEmailMessage(
			List<string> astrToAddresses,
			string strSubject,
			string strBody)
		{
			PostMessage(new EmailMessage(astrToAddresses, strSubject, strBody));
			return;
		}

		/************************************************************************************/
		protected override int Run()
		{
			Name = "E-mail queue thread";
			return base.Run();
		}

		/************************************************************************************/
		protected override void OnMessage(ThreadMessage NewMessage)
		{
			base.OnMessage(NewMessage);

			if (NewMessage is NewProfileMessage)
			{
				NewProfileMessage ThisMessage = (NewMessage as NewProfileMessage);
				m_CurrentProfile = ThisMessage.m_NewProfileCopy;
			}

			else if (NewMessage is EmailMessage)
			{
				EmailMessage ThisMessage = (NewMessage as EmailMessage);
				m_CurrentProfile.SendEMail(ThisMessage.m_astrToAddresses, ThisMessage.m_strSubject, ThisMessage.m_strBody);
			}

			return;
		}
	}
}
