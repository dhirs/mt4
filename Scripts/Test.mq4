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
  
  int p_close = iLow(0,0, 0);
  drawArrow(0, "Arrow", p_close,0,1);
  }
//+------------------------------------------------------------------+
