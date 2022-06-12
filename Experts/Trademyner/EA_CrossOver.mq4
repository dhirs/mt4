//+------------------------------------------------------------------+
//|                                                 EA_CrossOver.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//Trade parameters
input double lotSize = 0.8;
input double RR = 2;
input int LossPips = 40;
input int fast_ma_period = 50;
input int slow_ma_period = 200;

//Constants
const string indicatorName = "Trademyner\\EMA_Cross_Over";

//Other params
double stopLossPrice;
double takeProfitPrice;
string comment;
int openOrderID;
int ea_id = 122;
string ea_name = "EA_Cross_Over";
int candle_index = 0;

//Include files
#include  <CustomFunctions01.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Starting the strategy");
   comment = get_magic_number(ea_id);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CleanChart(ea_name);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(!CheckNewBar())
      return;

   if(!CheckIfOpenOrdersByComment(ea_id) && IsTradingAllowed())
     {

      int signal = check_signal();
      if(signal == 1)
        {
         sendOrder(LossPips,RR,lotSize,comment, true);
         return;
        }
      else
         if(signal == 2)
           {
            sendOrder(LossPips,RR,lotSize,comment, false);
            return;

           }
         else
           {
            Print("No Signal");
           }
     }

  }
//+------------------------------------------------------------------+
int check_signal()
  {

   double ShortSignal = iCustom(NULL,0, indicatorName,2,1);
   double LongSignal = iCustom(NULL,0, indicatorName,3,1);
   Print("----------ShortSignalBefore--------"+ShortSignal);
   Print("----------LongSignalBefore--------"+LongSignal);
   
   if(LongSignal != EMPTY_VALUE)
     {
      Print("-------Long-----------"+LongSignal+"---------------------");
      return 1;
     }
   if(ShortSignal != EMPTY_VALUE)
     {
      Print("-------Short-----------"+ShortSignal+"---------------------");
      return 2;
     }
   return 0;

  }
//+------------------------------------------------------------------+
