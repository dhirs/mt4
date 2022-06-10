//+------------------------------------------------------------------+
//|                                                          CPR.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//Include files
#include  <CustomFunctions01.mqh>
#include <CPR.mqh>

//--- indicator buffers
double         PDHBuffer[];
double         PDLBuffer[];
double         CentralPivot[];
string const   IndicatorName = "TM_CPR";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   IndicatorSetString(INDICATOR_SHORTNAME,IndicatorName);
   IndicatorBuffers(3);
   IndicatorDigits(Digits);
   
   //Previous day high
   SetIndexBuffer(0,PDHBuffer);
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1,clrRed);
   SetIndexLabel(0,"Prev. Day High");
   
   //Previous day low
   SetIndexBuffer(1,PDLBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,clrGreen);
   SetIndexLabel(1,"Prev. Day Low");
   
   //Central Pivot
   SetIndexBuffer(2,CentralPivot);
   SetIndexStyle(2, DRAW_LINE,STYLE_SOLID,1,clrBlack);
   SetIndexLabel(2,"Central Pivot");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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


   for(int i=Bars-1; i > 0; i--)
     {
      PDLBuffer[i] = iLow(NULL, PERIOD_D1,1);
      PDHBuffer[i] = iHigh(NULL, PERIOD_D1,1);
      CentralPivot[i] = (iClose(NULL, PERIOD_D1,1) +  PDHBuffer[i])/3;
     }

   return(rates_total);


  }
/////////////////////////////////////////////////////////////////////
void OnDeinit(const int reason)
  {
//CleanChart(IndicatorName);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitialiseBuffers()
  {




  }
//+------------------------------------------------------------------+
