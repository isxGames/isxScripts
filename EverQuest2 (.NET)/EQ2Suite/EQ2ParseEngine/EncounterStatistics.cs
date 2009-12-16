using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2ParseEngine
{
	/************************************************************************************/
	public class EncounterAbilityStatistics
	{
		protected string m_strAbilityName = string.Empty;
		protected int m_iTotalQuantity = 0;
		protected int? m_iMinimumQuantity = null;
		protected int? m_iMaximumQuantity = null;
		protected double m_fAverageQuantity = 0;
		protected ActionEventArgs.ActionType m_eActionType = ActionEventArgs.ActionType.Unknown;
		protected uint m_uiTotalSuccesses = 0;
		protected uint m_uiTotalCriticalSuccesses = 0;

		protected Queue<ActionEventArgs> m_AbilityQueue = new Queue<ActionEventArgs>();

		public void AddActionEvent(ActionEventArgs NewEvent)
		{
			if (m_eActionType == ActionEventArgs.ActionType.Unknown)
				m_eActionType = NewEvent.Action;

			m_AbilityQueue.Enqueue(NewEvent);

			if (!NewEvent.FailedAttempt)
			{
				if (m_iMinimumQuantity == null || NewEvent.Quantity < m_iMinimumQuantity)
					m_iMinimumQuantity = NewEvent.Quantity;
				if (m_iMaximumQuantity == null || NewEvent.Quantity > m_iMaximumQuantity)
					m_iMaximumQuantity = NewEvent.Quantity;
				if ((NewEvent.Attributes & ActionEventArgs.AttributeFlags.Critical) != 0)
					m_uiTotalCriticalSuccesses++;
				m_uiTotalSuccesses++;
				m_iTotalQuantity += NewEvent.Quantity;
				m_fAverageQuantity = (double)m_iTotalQuantity / (double)m_uiTotalSuccesses;
			}

			return;
		}
	}

	/************************************************************************************/
	public class EncounterAbilityCategory
	{
		protected Dictionary<string, EncounterAbilityStatistics> m_AbilityStatisticsMap = new Dictionary<string, EncounterAbilityStatistics>();

		public void AddActionEvent(ActionEventArgs NewEvent)
		{
			return;
		}
	}

	/************************************************************************************/
	public class EncounterActorStatistics
	{
		protected string m_strActorName = string.Empty;
		protected DateTime m_StartTime = DateTime.FromBinary(0);
		protected TimeSpan m_Duration = TimeSpan.FromTicks(0);
		protected uint m_uiTotalDamageOutput = 0;
		protected uint m_uiTotalHealsReceived = 0;
		protected double m_fTotalDPS = 0.0;
		protected uint m_uiTotalHits = 0;
		protected uint m_uiTotalCriticalHits = 0;
		protected uint m_uiTotalSwings = 0;
		protected uint m_uiTotalDamageReceived = 0;
		protected uint m_uiTotalPowerReceived = 0;
		protected uint m_uiTotalCuresOutput = 0;
		protected double m_fCriticalHealOutputRate = 0.0;
		protected double m_fCriticalDamageOutputRate = 0.0;

		protected Queue<ChatEventArgs> m_ChatEventQueue = new Queue<ChatEventArgs>();
		protected EncounterAbilityCategory m_DamageOutputCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_DamageReceivedCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_HealsOutputCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_HealsReceivedCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_PowerOutputCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_PowerReceivedCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_PowerDrainOutputCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_PowerDrainReceivedCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_CuresOutputCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_CuresReceivedCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_DispelsOutputCategory = new EncounterAbilityCategory();
		protected EncounterAbilityCategory m_DispelsReceivedCategory = new EncounterAbilityCategory();

		public void AddChatEvent(ChatEventArgs NewEvent)
		{
			m_ChatEventQueue.Enqueue(NewEvent);
			return;
		}

		public void AddActionEvent(ActionEventArgs NewEvent)
		{
			if (NewEvent.Source == m_strActorName)
			{
				switch (NewEvent.Action)
				{
					case ActionEventArgs.ActionType.Cure:
						m_CuresOutputCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.Dispel:
						m_DispelsOutputCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.Heal:
					case ActionEventArgs.ActionType.Ward:
						m_HealsOutputCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.PowerHeal:
						m_PowerOutputCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.PowerDrain:
						m_PowerDrainOutputCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.ColdDamage:
					case ActionEventArgs.ActionType.CrushingDamage:
					case ActionEventArgs.ActionType.DiseaseDamage:
					case ActionEventArgs.ActionType.DivineDamage:
					case ActionEventArgs.ActionType.FocusDamage:
					case ActionEventArgs.ActionType.HeatDamage:
					case ActionEventArgs.ActionType.MagicDamage:
					case ActionEventArgs.ActionType.MentalDamage:
					case ActionEventArgs.ActionType.PiercingDamage:
					case ActionEventArgs.ActionType.PoisonDamage:
					case ActionEventArgs.ActionType.SlashingDamage:
						m_DamageOutputCategory.AddActionEvent(NewEvent);
						break;
				}
			}
			
			if (NewEvent.Destination == m_strActorName)
			{
				switch (NewEvent.Action)
				{
					case ActionEventArgs.ActionType.Cure:
						m_CuresReceivedCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.Dispel:
						m_DispelsReceivedCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.Heal:
					case ActionEventArgs.ActionType.Ward:
						m_HealsReceivedCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.PowerHeal:
						m_PowerReceivedCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.PowerDrain:
						m_PowerDrainReceivedCategory.AddActionEvent(NewEvent);
						break;
					case ActionEventArgs.ActionType.ColdDamage:
					case ActionEventArgs.ActionType.CrushingDamage:
					case ActionEventArgs.ActionType.DiseaseDamage:
					case ActionEventArgs.ActionType.DivineDamage:
					case ActionEventArgs.ActionType.FocusDamage:
					case ActionEventArgs.ActionType.HeatDamage:
					case ActionEventArgs.ActionType.MagicDamage:
					case ActionEventArgs.ActionType.MentalDamage:
					case ActionEventArgs.ActionType.PiercingDamage:
					case ActionEventArgs.ActionType.PoisonDamage:
					case ActionEventArgs.ActionType.SlashingDamage:
						m_DamageReceivedCategory.AddActionEvent(NewEvent);
						break;
				}
			}

			return;
		}
	}

	/************************************************************************************/
	public class EncounterStatistics
	{
		protected DateTime? m_EncounterStartTime = null;
		protected TimeSpan m_TotalEncounterTime = TimeSpan.FromTicks(0);
		protected Dictionary<string, EncounterActorStatistics> m_ActorStatisticsMap = new Dictionary<string, EncounterActorStatistics>();

		public EncounterStatistics(DateTime EncounterStartTime)
		{
			StartEncounter(EncounterStartTime);
			return;
		}

		public void StartEncounter(DateTime EncounterStartTime)
		{
			if (m_EncounterStartTime == null)
				m_EncounterStartTime = EncounterStartTime;
			return;
		}

		public void EndEncounter(DateTime EncounterEndTime)
		{
			if (m_EncounterStartTime != null)
			{
				m_TotalEncounterTime += (EncounterEndTime - m_EncounterStartTime.Value);
				m_EncounterStartTime = null;
			}
			return;
		}

		public void AddChatEvent(ChatEventArgs NewEvent)
		{
			return;
		}

		public void AddActionEvent(ActionEventArgs NewEvent)
		{
			return;
		}
	}
}
