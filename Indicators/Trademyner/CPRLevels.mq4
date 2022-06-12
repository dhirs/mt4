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
#property indicator_buffers 9
#property indicator_plots   9

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

//--- plot R1
#property indicator_label6  "R1"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_DASH
#property indicator_width6  1

//--- plot s1
#property indicator_label7  "S1"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGreen
#property indicator_style7  STYLE_DASH
#property indicator_width7  1

//--- plot r2
#property indicator_label8  "R2"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrRed
#property indicator_style8  STYLE_DASH
#property indicator_width8  1

//--- plot s2
#property indicator_label9  "S2"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrGreen
#property indicator_style9  STYLE_DASH
#property indicator_width9  1

//--- indicator buffers
double         PDHBuffer[];
double         PDLBuffer[];
double         CentralPivot[];
double         CentralPivotLower[];
double         CentralPivotUpper[];
double         R1[];
double         R2[];
double         S1[];
double         S2[];

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
   SetIndexBuffer(5,R1);
   SetIndexBuffer(6,S1);
   SetIndexBuffer(7,R2);
   SetIndexBuffer(8,S2);

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
      R1[i] = (2 * CentralPivot[i]) - PDLBuffer[i];
      R2[i] =  CentralPivot[i] + PDHBuffer[i]-PDLBuffer[i];
      S1[i] = (2 * CentralPivot[i]) - PDHBuffer[i];
      S2[i] =  CentralPivot[i] - (PDHBuffer[i]-PDLBuffer[i]);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
