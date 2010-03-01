using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2SuiteLib
{
	/// <summary>
	/// This class addresses the "pointer to a pointer" deficiency by explicitly boxing any scalar/value type.
	/// </summary>
	/// <typeparam name="T"></typeparam>
	public class BoxedScalar<T>
	{
		protected T m_Value = default(T);

		public BoxedScalar()
		{
			return;
		}

		public BoxedScalar(T StartingValue)
		{
			m_Value = StartingValue;
			return;
		}

		public static implicit operator T(BoxedScalar<T> ThisObject)
		{
			return ThisObject.m_Value;
		}

		public static implicit operator BoxedScalar<T>(T NewValue)
		{
			return new BoxedScalar<T>(NewValue);
		}

		public T Value
		{
			get
			{
				return m_Value;
			}
			set
			{
				m_Value = value;
				return;
			}
		}
	}
}
