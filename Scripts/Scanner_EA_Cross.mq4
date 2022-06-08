
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string Symbols[10] = {"AUDJPY", "AUDNZD"};
string sym;
double close_price;
input double period_slow = 50;
input double period_fast = 200;

double ema_slow, ema_fast;


void OnStart()
  {
           
      for (int i=0; i < ArraySize( Symbols ); i++)
      
      {
         sym = Symbols[i];
         ema_slow = iMA( sym, PERIOD_M15, period_slow,1, MODE_EMA, PRICE_CLOSE,0);
         ema_fast = iMA( sym, PERIOD_M15, period_fast,1, MODE_EMA, PRICE_CLOSE,0);
      }
   
  }

