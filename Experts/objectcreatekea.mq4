//+------------------------------------------------------------------+
//|                                              ObjectCreate EA.mq4 |
//|                              Copyright © 2011, RunnerUp^bitch3s^ |
//|                                                             none |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, RunnerUp^bitch3s^"
#property link      "none"

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {

   if (TimeHour(TimeCurrent()) <= 24){
   if (TimeHour(TimeCurrent()) >= 0){
   
  {
   //ObjectCreate("Horizontal line",OBJ_HLINE,0, datetime time1, double price1, datetime time2=0, double price2=0, datetime time3=0, double price3=0);
   ObjectCreate("Horizontal line",OBJ_HLINE,0,D'2004.02.20 12:30', Close[1]/* 1.0045 */);
  }
  }}


   return(0);
  }
//+------------------------------------------------------------------+