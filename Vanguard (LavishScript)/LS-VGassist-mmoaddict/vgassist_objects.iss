objectdef charstates
  {  
   member:bool MeCombat()
   {
	If ${Me.InCombat}
	{
	return true
	}
	else
	{
	return false
	}
   }
  }
