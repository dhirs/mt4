#include  <CustomFunctions01.mqh>
#include <CPR.mqh>


//Trade parameters
input double lotSize = 0.1;
input double RR = 2;
input int LossPips = 25;

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

void OnDeinit(const int reason)
  {
   CleanChart(ea_name);
   
  }

void OnTick()
  {
  
    
   if (!CheckIfOpenOrdersByComment(ea_id) && IsTradingAllowed())
   {
      //Long positions
      if( Close[0] > top_pivot)
      
         {
               Print("Cross above top pivot");
               stopLossPrice = GetStopLossPrice(True, Ask, LossPips);
               takeProfitPrice = GetTargetProfit(True, stopLossPrice, Ask,RR);
               Print("Entry Price = " + Ask);
               Print("Stop Loss Price = " + stopLossPrice);
               Print("Take Profit Price = " + takeProfitPrice);                
               openOrderID = OrderSend( NULL,OP_BUYLIMIT,lotSize,Ask,10,stopLossPrice,takeProfitPrice,comment);
               if(openOrderID < 0) 
               {
                  Alert("Order rejected. Order error: " + GetLastError());
               }
               else{
                  
                  Print("New Long Order "+comment+" "+ openOrderID);
                  Alert("Long Order");
                  
               }
         
         }
       else if(Close[0] < bottom_pivot)
         {
         
               Print("Cross below bottom pivot");
               stopLossPrice = GetStopLossPrice(False, Bid, LossPips);
               takeProfitPrice = GetTargetProfit(False, stopLossPrice, Bid,RR);
               Print("Entry Price = " + Bid);
               Print("Stop Loss Price = " + stopLossPrice);
               Print("Take Profit Price = " + takeProfitPrice);                
               openOrderID = OrderSend( NULL,OP_SELLLIMIT,lotSize,Bid,10,stopLossPrice,takeProfitPrice,comment);
              if(openOrderID < 0) 
               {
                  Alert("Order rejected. Order error: " + GetLastError());
               }
               else{
                  
                  Print("New Short Order "+comment+" "+ openOrderID);
                  Alert("Short Order");
                  
               }
         
         }
   }
     
  }

