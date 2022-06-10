//+------------------------------------------------------------------+
//|                                                    CPRLevels.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot PDH
#property indicator_label1  "PDH"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot PDL
#property indicator_label2  "PDL"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreenYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot Central Pivot
#property indicator_label3  "CentralPivot"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlack
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//--- plot Central Pivot(Upper band)
#property indicator_label4  "CentralPivot-Upper"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlueViolet
#property indicator_style4  STYLE_DOT
#property indicator_width4  2

//--- plot Central Pivot(Lower band)
#property indicator_label5  "CentralPivot-Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrBlueViolet
#property indicator_style5  STYLE_DOT
#property indicator_width5  2

//--- indicator buffers
double         PDHBuffer[];
double         PDLBuffer[];
double         CentralPivot[];
double         CentralPivotLower[];
double         CentralPivotUpper[];

//Include files
#include  <CustomFunctions01.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,PDHBuffer);
   SetIndexBuffer(1,PDLBuffer);
   SetIndexBuffer(2,CentralPivot);
   SetIndexBuffer(3,CentralPivotUpper);
   SetIndexBuffer(4,CentralPivotLower);

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
   bool IsNewCandle=CheckIfNewCandle(PERIOD_CURRENT);
   int i,pos,upTo, shift;

   pos=0;
   shift = 1;
   if(prev_calculated==0 || IsNewCandle)
      upTo=Bars-1;
   else
      upTo=0;

   for(i=pos; i<=upTo && !IsStopped(); i++)
     {
      if(CheckIfNewCandle(PERIOD_D1))
        {
         shift++;
        }
      PDLBuffer[i] = iLow(NULL, PERIOD_D1,shift);
      PDHBuffer[i] = iHigh(NULL, PERIOD_D1,shift);
      CentralPivot[i] = (iClose(NULL, PERIOD_D1,shift) + PDLBuffer[i] +  PDHBuffer[i])/3;
      CentralPivotLower[i] = (PDLBuffer[i] + PDHBuffer[i])/2;
      CentralPivotUpper[i] = 2*CentralPivot[i] - CentralPivotLower[i];
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
