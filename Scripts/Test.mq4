int StartHour = 09; // Start operation hour
int LastHour = 23; // Last operation hour

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckActiveHours()
  {
// Set operations disabled by default.
   bool OperationsAllowed = false;
// Check if the current hour is between the allowed hours of operations. If so, return true.
   if((StartHour == LastHour) && (Hour() == StartHour))
      OperationsAllowed = true;
   if((StartHour < LastHour) && (Hour() >= StartHour) && (Hour() <= LastHour))
      OperationsAllowed = true;
   if((StartHour > LastHour) && (((Hour() >= LastHour) && (Hour() <= 23)) || ((Hour() <= StartHour) && (Hour() > 0))))
      OperationsAllowed = true;
   return OperationsAllowed;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("@hello");
   if(CheckActiveHours())
      Print("Trading enabled");
  }
//+------------------------------------------------------------------+
