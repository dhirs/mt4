
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string Symbols[16] = {"AUDJPY", "AUDNZD", "AUDCAD", "AUDUSD", "AUDCHF", "AUDGBP", "NZDUSD", "GBPUSD", "USDJPY", 
"EURUSD", "USDCAD", "EURGBP", "EURCAD", "EURAUD", "EURJPY", "EURCHF"};

string sym;
double close_price;
input double period_slow = 50;
input double period_fast = 200;

double ema_slow_0, ema_slow_2, ema_fast_0, ema_fast_2;


void OnStart()
  {
           
      for (int i=0; i < ArraySize( Symbols ); i++)
      
      {
         sym = Symbols[i];
         
         ema_fast_0 = iMA( sym, PERIOD_M15, period_fast,0, MODE_EMA, PRICE_CLOSE,0);        
         
         ema_fast_2 = iMA( sym, PERIOD_M15, period_fast,2, MODE_EMA, PRICE_CLOSE,0);
         
         ema_slow_0 = iMA( sym, PERIOD_M15, period_slow,0, MODE_EMA, PRICE_CLOSE,0);
         
         ema_slow_2 = iMA( sym, PERIOD_M15, period_slow,2, MODE_EMA, PRICE_CLOSE,0);
         
         //cross up
         if ( ema_fast_0 > ema_fast_2 && ema_fast_0 > ema_slow_0 && ema_fast_2 < ema_slow_2 )
         
         {
            Alert("EMA Cross-up for "+sym+"-15m");
         
         }
         else if( ema_fast_0 < ema_fast_2 && ema_fast_0 < ema_slow_0 && ema_fast_2 > ema_slow_2 )
         
         {
            Alert("EMA Cross-down for "+sym+"-15m");
         
         }
         else{
            Alert("No cross-overs");
         
         }
         
      }
   
  }

