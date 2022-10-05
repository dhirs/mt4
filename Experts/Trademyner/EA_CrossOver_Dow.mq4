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
input double lotSize = 0.1;
input double RR = 6;
input int fast_ma_period = 8;
input int slow_ma_period = 20;

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
int atr_length = 14;
double atr_val;
int signal;

//Include files
#include  <Trademyner\CustomFunctions01.mqh>

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

      signal = check_signal();
      atr_val = iATR(NULL,0,atr_length,0);
            
      if(signal == 1)
        {
         openOrderID = sendOrder(atr_val,RR,lotSize,comment, true,true);
         return;
        }
      else
         if(signal == 2)
           {
            openOrderID = sendOrder(atr_val,RR,lotSize,comment, false,true);
            return;

           }
         else
           {
            Print("No Signal");
           }
     }
   if(CheckIfOpenOrdersByComment(ea_id))
     {

      if(OrderSelect(openOrderID,SELECT_BY_TICKET))
        {

         int orderType = OrderType();
         double ema_fast = iMA(0,PERIOD_CURRENT,fast_ma_period,0,MODE_EMA,PRICE_CLOSE,0);

         if(orderType == OP_BUYLIMIT)
           {
            if(Close[1] < ema_fast)
              {
               OrderClose(openOrderID,OrderLots(),Bid,3);

              }

           }
         if(orderType == OP_SELLLIMIT)
           {

            if(Close[1] > ema_fast)
              {
               OrderClose(openOrderID,OrderLots(),Ask,3);

              }
           }



        }

     }
  }
//+------------------------------------------------------------------+
int check_signal()
  {

   int signal = detect_ema_cross(slow_ma_period, fast_ma_period);
   return signal;

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
