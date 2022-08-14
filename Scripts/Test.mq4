///////////////////////////////////////////////////////////////////////////////////////////////

#property copyright "Copyright 2022, Trademyner"
#property link      "http://www.trademyner.com"
#property version   "1.00"
#property strict

////////////////////////////////////////////Include custom functions///////////////////////////
#include  <Trademyner\\CustomFunctions01.mqh>
///////////////////////////////////////////////////////////////////////////////////////////////
string sym;
double close_price;
input double period_slow = 20;
input double period_fast = 8;
int ma_period;
double ema_slow,ema_fast;
int barcount = 100;
////////////////////////////////////////Main function start///////////////////////////////////
void OnStart()
  {
   for(int i=0; i < barcount; i++)
     {

      performScan(i);

     }

  }

//////////////////////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void performScan(int i)
  {
   double curr_macd = iMACD(NULL, 0, 6, 12, 9, PRICE_CLOSE, MODE_MAIN, i);
   double prev_macd = iMACD(NULL, 0, 6, 12, 9, PRICE_CLOSE, MODE_MAIN, i+1);
   double curr_signal = iMACD(NULL, 0, 6, 12, 9, PRICE_CLOSE, MODE_SIGNAL, i);
   double prev_signal = iMACD(NULL, 0, 6, 12, 9, PRICE_CLOSE, MODE_SIGNAL, i+1);

   int macd_cross = detect_indicator_cross(curr_macd, curr_signal, prev_macd, prev_signal);
   
   if(macd_cross != 0)
     {
      Print("------"+Time[i]+"---------"+macd_cross);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
