//+------------------------------------------------------------------+
//|                                               EMA_Cross_Over.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

//--- plot Fast_EMA
#property indicator_label1  "Fast_EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DOT
#property indicator_width1  1

//--- plot Slow_EMA
#property indicator_label2  "Slow_EMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightSeaGreen
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- plot SellSignal
#property indicator_label3  "SellSignal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  10

//--- plot BuySignal
#property indicator_label4  "BuySignal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  10

//Inputs
const int fast_ma_period = 50;
const int slow_ma_period = 200;

//Include file
#include  <CustomFunctions01.mqh>
//--- indicator buffers
double         Fast_EMABuffer[];
double         Slow_EMABuffer[];
double         SellSignalBuffer[];
double         BuySignalBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Fast_EMABuffer);
   SetIndexBuffer(1,Slow_EMABuffer);
   SetIndexBuffer(2,SellSignalBuffer);
   SetIndexBuffer(3,BuySignalBuffer);

   SetIndexArrow(2, SYMBOL_ARROWDOWN);
   SetIndexArrow(3, SYMBOL_ARROWUP);
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
   double fast_ma_curr;
   double slow_ma_curr;
   double fast_ma_prev;
   double slow_ma_prev;

   for(int i=0; i<limit; i++)
     {

      Fast_EMABuffer[i] = iMA(0,PERIOD_CURRENT,fast_ma_period,0,MODE_EMA,PRICE_CLOSE,i);
      Slow_EMABuffer[i] = iMA(0,PERIOD_CURRENT,slow_ma_period,0,MODE_EMA,PRICE_CLOSE,i);
      SellSignalBuffer[i] = EMPTY_VALUE;
      BuySignalBuffer[i] = EMPTY_VALUE;

      fast_ma_curr = Fast_EMABuffer[i];
      slow_ma_curr = Slow_EMABuffer[i];

      fast_ma_prev = iMA(0,PERIOD_CURRENT,fast_ma_period,0,MODE_EMA,PRICE_CLOSE,i+1);      
      slow_ma_prev = iMA(0,PERIOD_CURRENT,slow_ma_period,0,MODE_EMA,PRICE_CLOSE,i+1);
     

      int isCrossDown = detect_indicator_cross(fast_ma_curr, slow_ma_curr, fast_ma_prev, slow_ma_prev);
      if(isCrossDown == 1 && i > 0)
        {
         if(i>0)
           {
            SellSignalBuffer[i] = High[i] + (High[i]-Low[i]);
            SellSignalBuffer[i-1] = EMPTY_VALUE;
           }


        }
      else
         if(isCrossDown == 2 && i > 0)
           {
            if(i > 0)
              {
               BuySignalBuffer[i] = Low[i] - (High[i]-Low[i]);
               BuySignalBuffer[i-1] = EMPTY_VALUE;
              }

           }


     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
