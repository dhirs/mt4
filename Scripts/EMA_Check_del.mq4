//+------------------------------------------------------------------+
//|                                                EMA_Check_del.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
const string indicatorName = "Trademyner\\EMA_Cross_Over";
input int fast_ma_period = 50;
input int slow_ma_period = 200;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   Alert(Bars);
   for(int i=1; i<Bars; i++)
     {
     
  
      double ShortSignal = iCustom(NULL,0, indicatorName,0,i);
      double LongSignal = iCustom(NULL,0, indicatorName,2, i);
      if(ShortSignal != EMPTY_VALUE)
        {
         Print(i+"------"+ShortSignal);

        }
       
     }


  }
//+------------------------------------------------------------------+
