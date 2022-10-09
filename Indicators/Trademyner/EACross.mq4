//+------------------------------------------------------------------+
//|                                                      EACross.mq4 |
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
//--- plot FastEMA
#property indicator_label1  "FastEMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SlowEMA
#property indicator_label2  "SlowEMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSteelBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot UpArrow
#property indicator_label3  "UpArrow"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrSpringGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot DownArrow
#property indicator_label4  "DownArrow"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDarkOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- indicator buffers
double         FastEMABuffer[];
double         SlowEMABuffer[];
double         UpArrowBuffer[];
double         DownArrowBuffer[];
int slow_period = 20;
int fast_period = 8;
int signal;

#include  <Trademyner\CustomFunctions01.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,FastEMABuffer);
   SetIndexBuffer(1,SlowEMABuffer);
   SetIndexBuffer(2,UpArrowBuffer);
   SetIndexBuffer(3,DownArrowBuffer);
   SetIndexArrow(2, SYMBOL_ARROWUP);
   SetIndexArrow(3, SYMBOL_ARROWDOWN);

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
   bool IsNewCandle=CheckNewBar();
   int i,pos,upTo, shift;

   pos=0;
   shift = 1;
   if(prev_calculated==0 || IsNewCandle)
      upTo=Bars-1;
   else
      upTo=0;

   for(i=pos; i<=upTo && !IsStopped(); i++)
     {
      if(IsNewCandle)
        {
         shift++;
        }
      SlowEMABuffer[i] = iMA(Symbol(), 0, slow_period, 0, MODE_EMA, PRICE_CLOSE, i);
      FastEMABuffer[i] = iMA(Symbol(), 0, fast_period, 0, MODE_EMA, PRICE_CLOSE, i);
      signal = detect_ema_cross(slow_period, fast_period, i);
      if(signal == 1)
        {

         UpArrowBuffer[i] = iLow(0,0,i) - iATR(0,0,14,i-1);
        }
      if(signal == 2)
        {

         DownArrowBuffer[i] = iHigh(0,0,i) + iATR(0,0,14,i+1);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
