//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include  <Trademyner\CustomFunctions01.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {

   int candle_index = 12;
   datetime time_current = TimeCurrent();
   string order_id = "T_"+time_current+candle_index;
   datetime time = Time[candle_index];
   double price = Low[candle_index];
   
   ObjectCreate(0,order_id, OBJ_TEXT, 0, time, price);
   ObjectSetText(order_id, "Hello", 8,NULL, clrGreen);

  }
//+------------------------------------------------------------------+
