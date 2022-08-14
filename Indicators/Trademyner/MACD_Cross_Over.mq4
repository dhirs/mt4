//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Trademyner"
#property link      "http://www.trademyner.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot SellSignal
#property indicator_label1  "SellSignal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5


//--- plot BuySignal
#property indicator_label2  "BuySignal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5

//Inputs
const int fast_ema_period = 50;
const int slow_ema_period = 200;
const int higher_tf = PERIOD_H4;

//Other vars
double curr_macd;
double prev_macd;
double curr_signal;
double prev_signal;
double curr_close;
double fast_ema_htf;
double slow_ema_htf;
int isCross;


//Include file
#include  <Trademyner\\CustomFunctions01.mqh>

//--- indicator buffers
double         SellSignalBuffer[];
double         BuySignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0,SellSignalBuffer);
   SetIndexBuffer(1,BuySignalBuffer);

   SetIndexArrow(0, SYMBOL_ARROWDOWN);
   SetIndexArrow(1, SYMBOL_ARROWUP);

   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);

   IndicatorDigits(Digits+2);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int limit=rates_total-prev_calculated;


   for(int i=0; i<limit; i++)
     {
      SellSignalBuffer[i] = EMPTY_VALUE;
      BuySignalBuffer[i] = EMPTY_VALUE;

      curr_macd = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i+1);
      prev_macd = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i + 2);
      curr_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i+1);
      prev_signal = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i + 2);

      fast_ema_htf = iMA(NULL, higher_tf, fast_ema_period,0, MODE_EMA, PRICE_CLOSE,i+1);
      slow_ema_htf = iMA(NULL, higher_tf, slow_ema_period,0, MODE_EMA, PRICE_CLOSE,i+1);


      int isCross = detect_indicator_cross(curr_macd, curr_signal, prev_macd, prev_signal);
      // if(isCross == 1 && i > 0 && fast_ema_htf > slow_ema_htf)
      // if(isCross == 1 && i > 0 && get_condition_2(i))
      if(isCross == 1 && i > 0)
        {
         BuySignalBuffer[i] = Low[i] - (High[i]-Low[i]);
         BuySignalBuffer[i-1] = EMPTY_VALUE;
        }
      else
         //if(isCross == 2 && i > 0  && fast_ema_htf < slow_ema_htf)
         //if(isCross == 2 && i > 0  && get_condition_2(i,false))
         if(isCross == 2 && i > 0)
           {
            SellSignalBuffer[i] = High[i] + (High[i]-Low[i]);
            SellSignalBuffer[i-1] = EMPTY_VALUE;
           }



     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool get_condition_2(int i, bool isLong = True)
  {

   int ema_period = 20;

   double ema = iMA(NULL, 0, ema_period,0, MODE_EMA, PRICE_CLOSE,i);
   double close = iClose(NULL, 0, i+1);
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
