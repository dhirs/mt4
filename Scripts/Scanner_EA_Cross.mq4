//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include  <CustomFunctions01.mqh>

/*string Symbols[16] = {"AUDJPY", "AUDNZD", "AUDCAD", "AUDUSD", "AUDCHF", "AUDGBP", "NZDUSD", "GBPUSD", "USDJPY",
                      "EURUSD", "USDCAD", "EURGBP", "EURCAD", "EURAUD", "EURJPY", "EURCHF"
                     };*/

string Symbols[2] = { "EURJPY", "EURCHF" };

string sym;
double close_price;
input double period_slow = 200;
input double period_fast = 50;
int period = 0;
int barcount = 100;

double ema_slow_0, ema_slow_2, ema_fast_0, ema_fast_2;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   int signal, sym_signal;
   datetime t;


   for(int i=0; i < ArraySize(Symbols); i++)

     {
      sym = Symbols[i];
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


//+------------------------------------------------------------------+
