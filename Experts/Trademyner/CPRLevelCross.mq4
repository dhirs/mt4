//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include  <CustomFunctions01.mqh>
#include <CPR.mqh>


//Trade parameters
input double lotSize = 0.8;
input double RR = 2;
input int LossPips = 40;

//Other params
double stopLossPrice;
double takeProfitPrice;
string comment;
int openOrderID;
int ea_id = 121;
string ea_name = "CPRLevelCross";

///////////////////////////////Main Function/////////////////////////////////////////
int OnInit()
  {

   Print("Starting the strategy");
   set_chart_pivots(ea_name);
   comment = get_magic_number(ea_id);
   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CleanChart(ea_name);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {


   if(!CheckIfOpenOrdersByComment(ea_id) && IsTradingAllowed())
     {
      //Long positions
      if(check_long_short_condition())

        {
         sendOrder(LossPips,RR,lotSize,comment, true);
        }
      //Short positions
      if(check_long_short_condition(false))
        {

         sendOrder(LossPips,RR,lotSize,comment, false);

        }
     }

  }

//+------------------------------------------------------------------+
bool check_long_short_condition(bool isLong=true)
  {
   double prev_close = iClose(0,PERIOD_M15,1);
   double fast_ema = iMA(0,PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,0);
   double slow_ema = iMA(0,PERIOD_M15,200,0,MODE_EMA,PRICE_CLOSE,0);
   bool condition;
   if(isLong)
     {

      condition = prev_close > top_pivot && fast_ema > slow_ema;
     }
   else
     {
      condition = prev_close < bottom_pivot && fast_ema < slow_ema;
     }
   return condition;

  }
//+------------------------------------------------------------------+
