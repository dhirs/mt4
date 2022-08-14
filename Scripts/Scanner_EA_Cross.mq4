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
input double period_slow = 200;
input double period_fast = 50;
int period = 0;
int barcount = 100;
double ema_slow_0, ema_slow_2, ema_fast_0, ema_fast_2;
////////////////////////////////////////Main function start///////////////////////////////////
void OnStart()
  {
   int signal, sym_signal;
   datetime t;


   for(int i=0; i < ArraySize(scan_symbols); i++)

     {
      sym = scan_symbols[i];
      sym_signal = 0;

      for(int j=0; j< barcount; j++)
        {

         ema_fast_0 = iMA(sym, PERIOD_M15, period_fast,0, MODE_EMA, PRICE_CLOSE,j);

         ema_fast_2 = iMA(sym, PERIOD_M15, period_fast,0, MODE_EMA, PRICE_CLOSE,j+1);

         ema_slow_0 = iMA(sym, PERIOD_M15, period_slow,0, MODE_EMA, PRICE_CLOSE,j);

         ema_slow_2 = iMA(sym, PERIOD_M15, period_slow,0, MODE_EMA, PRICE_CLOSE,j+1);

         signal = detect_indicator_cross(ema_fast_0, ema_slow_0, ema_fast_2, ema_slow_2);


         //cross up
         if(signal == 2)

           {
            t = iTime(sym, PERIOD_M15,j+1);
            Print("EMA Cross-up for "+sym+"-----"+t);
            sym_signal = 1;


           }
         else
            //cross down
            if(signal == 1)

              {
               t = iTime(sym, PERIOD_M15,j+1);
               Print("EMA Cross-down for "+sym+"-----"+t);
               sym_signal = 1;

              }

        }
      if(sym_signal == 0)
        {

         Print("No cross-overs found for "+ sym);

        }

     }

  }

//////////////////////////////////////////////////////////////////////////////////////////////////////
