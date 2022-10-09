//+------------------------------------------------------------------+
//|                                                         VWAP.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot VWAP
#property indicator_label1  "VWAP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         VWAPBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   SetIndexBuffer(0,VWAPBuffer);

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

   int session_start = iBarShift(_Symbol, PERIOD_CURRENT,iTime(_Symbol,PERIOD_D1,0));
   for(int i=session_start;i>=0;i--)
   {
      double sum = 0;
      double vol = 0;
      for(int j=session_start;j>=i;j--)
      {
         sum += (High[j]+Low[j]+Close[j])/3*Volume[j];
         vol += (double)Volume[j];
      }
      if(vol != 0)
         VWAPBuffer[i] = sum/vol;
     
   }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
