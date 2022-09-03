//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Trademyner"
#property link      "http://www.trademyner.com"
#property version   "1.00"
#property strict

//Trade parameters
input double lotSize = 0.1;
input double RR = 1;
input int LossPips = 60;

//constants
const int entry_period = PERIOD_M30;


//Other params
double stopLossPrice;
double takeProfitPrice;
string comment;
int openOrderID;
int ea_id = 121;
string ea_name = "MACD_Cross_Over";
int candle_index = 0;

//Signal params
double curr_macd;
double prev_macd;
double curr_signal;
double prev_signal;
double curr_close;
double fast_ema_htf;
double slow_ema_htf;
int isCross;

//Include files
#include  <Trademyner\\CustomFunctions01.mqh>

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
         openOrderID = sendOrder(LossPips,RR,lotSize,comment, true);
         return;
        }
      else
         if(signal == 2) //Short
           {
            openOrderID = sendOrder(LossPips,RR,lotSize,comment, false);
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

   curr_macd = iMACD(NULL, entry_period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   prev_macd = iMACD(NULL, entry_period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 2);
   curr_signal = iMACD(NULL, entry_period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   prev_signal = iMACD(NULL, entry_period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 2);
   isCross = detect_indicator_cross(curr_macd, curr_signal, prev_macd, prev_signal);


//if(isCross == 1 && get_condition_2())
   if(isCross == 1)
     {
      Print("---Going long----------");
      Print("------------Current candle time is----------"+Time[0]);
      return 1;

     }
   else
      //if(isCross == 2 && get_condition_2(false))
      if(isCross == 2)
        {
         Print("---Going short----");
         Print("---Current candle time is----------"+Time[0]);
         return 2;
        }
   return 0;


  }

//+------------------------------------------------------------------+
// This condition checks that the faster EMA on a higher timeframe
// is above the slower EMA for longs (and reverse for shorts)
//+------------------------------------------------------------------+
bool get_condition_1(bool isLong = True)
  {
   int htf_period = PERIOD_H4;
   int fast_ema_period_htf = 50;
   int slow_ema_period_htf = 200;
   fast_ema_htf = iMA(NULL, htf_period, fast_ema_period_htf,0, MODE_EMA, PRICE_CLOSE,1);
   slow_ema_htf = iMA(NULL, htf_period, slow_ema_period_htf,0, MODE_EMA, PRICE_CLOSE,1);
   if(isLong)
     {
      return fast_ema_htf > slow_ema_htf;

     }
   else
     {
      return fast_ema_htf < slow_ema_htf;
     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// This condition that the price is above or below EMA on current
// timeframe
// in order to confirm trend
//+------------------------------------------------------------------+
bool get_condition_2(bool isLong = True)
  {

   int ema_period = 20;

   double ema = iMA(NULL, 0, ema_period,0, MODE_EMA, PRICE_CLOSE,1);
   double close = iClose(NULL, 0, 1);
   if(isLong)
     {
      return close > ema;

     }
   else
     {
      return close < ema;
     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
