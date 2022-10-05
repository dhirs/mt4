#property copyright "Copyright 2022, Trademyner"
#property link      "http://www.trademyner.com"
#property version   "1.00"
#property strict

//Include files
#include  <Trademyner\\CustomFunctions01.mqh>

//Trade parameters
input double lotSize = 0.1;
input double RR = 2;
input int LossPips = 100;

//Constants
const int entry_period = PERIOD_H4;

//Other params
double stopLossPrice;
double takeProfitPrice;
string comment;
int openOrderID;
int ea_id = 121;
string ea_name = "MACD_Cross_Over_MTF_FX";
int candle_index = 0;

//Signal params
int signal;
bool isIndex = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Starting the strategy");
   comment = get_magic_number(ea_id);
   Print("___________"+comment+"_________");
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
   Print("-------------New bar--------------"+Time[0]);
   if(!CheckIfOpenOrdersByComment(ea_id) && IsTradingAllowed())
     {

      int signal = check_signal();
      //Long
      if(signal == 1)
        {
         openOrderID = sendOrder(LossPips,RR,lotSize,comment, true, isIndex);
         return;
        }
      else
         if(signal == 2) //Short
           {
            openOrderID = sendOrder(LossPips,RR,lotSize,comment, false, isIndex);
            return;

           }
         else
           {
            Print("No Signal");
           }
     }
   /* if(CheckIfOpenOrdersByComment(ea_id))
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

      }*/
  }
//+------------------------------------------------------------------+
int check_signal()
  {


   signal = get_condition_1();

   if(signal == 1)
     {
      Print("---Going long----------");
      Print("------------Current candle time is----------"+Time[0]);
      return 1;

     }
   else

      if(signal == 2)
        {
         Print("---Going short----");
         Print("---Current candle time is----------"+Time[0]);
         return 2;
        }
   return 0;


  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int get_condition_1()
  {


   int entry_tf_macd = detect_macd_cross(PERIOD_H4);
   double htf_ema_fast = iMACD(NULL, PERIOD_D1, 6, 12, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double htf_ema_slow = iMACD(NULL, PERIOD_D1, 6, 12, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

   if(entry_tf_macd == 1 && (htf_ema_fast > htf_ema_slow))
     {
      return 1;
     }

   if(entry_tf_macd == 2 && (htf_ema_fast < htf_ema_slow))
     {
      return 2;
     }


   return 3;

  }

//+------------------------------------------------------------------+
