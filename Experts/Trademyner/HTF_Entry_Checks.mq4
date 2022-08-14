//+------------------------------------------------------------------+
//|                                             HTF_Entry_Checks.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//////////////////////////////////////////////////////////////////////
#include  <Trademyner\\CustomFunctions01.mqh>
//////////////////////////////////////////////////////////////////////

datetime LastActionTime = 0;
datetime t;
string sym;
int ma_period;
double ema_slow, ema_fast;
int macd_cross;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if((LastActionTime != Time[0]))
     {

      double curr_macd = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
      double prev_macd = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
      double curr_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
      double prev_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);

      macd_cross = detect_indicator_cross(curr_macd, curr_signal, prev_macd, prev_signal);

      if(macd_cross != 0)
        {
         performScan(macd_cross);
        }

      LastActionTime = Time[0];
     }
  }

//+------------------------------------------------------------------+
//| Scan the symbols for Long/Short triggers                         |
//+------------------------------------------------------------------+
void performScan(int direction)
  {
   int signal_4h;
   int signal_1h;

   for(int i=0; i < ArraySize(scan_symbols); i++)

     {
      sym = scan_symbols[i];
      signal_4h = get_signal(4, sym);
      signal_1h = get_signal(1,sym);


      if(signal_1h == 1 && signal_4h == 1 && direction == 1)
        {
         Print("Bullish signal for "+sym+"----"+Time[0]);
        }

      else
         if(signal_1h == 2 && signal_4h == 2 && direction == 2)
           {
            Print("Bearish signal for "+sym+"----"+Time[0]);
           }
     }
  }

//+------------------------------------------------------------------+
int get_signal(int period, string symbol)
  {
   switch(period)
     {

      case 1:
         ma_period = PERIOD_H1;
         break;
      case 4:
         ma_period = PERIOD_H4;
         break;

     }

   ema_fast = iMA(symbol, ma_period, 8,0, MODE_EMA, PRICE_CLOSE,0);
   ema_slow = iMA(symbol, ma_period, 20,0, MODE_EMA, PRICE_CLOSE,0);

   if(ema_fast > ema_slow)
     {
      return 1;
     }
   if(ema_fast < ema_slow)
     {
      return 2;
     }
   return 0;
  }
//+------------------------------------------------------------------+
