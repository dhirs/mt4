#include  <CustomFunctions01.mqh>

input int bandStdEntry = 2;
input int bandStdProfitExit = 1;
input int bandStdLossExit = 6;
input int bbPeriod = 50;
double stopLossPrice;
double takeProfitPrice;
string comment;
int openOrderID;
int ea_id = 121;
double lotSize = 1;
double pdh;
double pdl;

int OnInit()
  {
      Alert("Starting test strategy");
      return(INIT_SUCCEEDED);
      
  }

void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {
  
   pdh = iHigh(NULL, PERIOD_D1,1);  
   drawHLine(0,"PDH", 0,pdh,true,"PDHLabel","PDH",clrBlue,STYLE_DOT);
  
   pdl = iLow(NULL, PERIOD_D1,1); 
   drawHLine(0,"PDL", 0,pdl,true,"PDLLabel","PDL", clrGreen,STYLE_DOT);
       
   double bbLowerEntry = iBands( NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpperEntry = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_UPPER,0);
   double bbMid = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,0,0);
   
   double bbLowerProfitExit = iBands(NULL,0,bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpperProfitExit = iBands(NULL,0,bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_UPPER,0);
   
   double bbLowerLossExit = iBands(NULL,0,bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpperLossExit = iBands(NULL,0,bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_UPPER,0);
   
   comment = get_magic_number(ea_id);
   if (!CheckIfOpenOrdersByComment(ea_id))
   {
   if(Ask < bbMid && Open[0] > bbUpperEntry)
   
   {
         Print("Price is bellow bbLower" + bbLowerEntry + ", Sending buy order");
         stopLossPrice = NormalizeDouble(bbLowerLossExit,Digits);
         takeProfitPrice = NormalizeDouble(bbUpperProfitExit,Digits);;
         Print("Entry Price = " + Ask);
         Print("Stop Loss Price = " + stopLossPrice);
         Print("Take Profit Price = " + takeProfitPrice);
         
                
         openOrderID = OrderSend( NULL,OP_BUYLIMIT,lotSize,Ask,10,stopLossPrice,takeProfitPrice,comment);
         if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
         Print("New Long Order "+comment+" "+ openOrderID);
   
   }
   else if(Bid > bbMid && Open[0] < bbUpperEntry)
   {
   
         Print("Price is above bbUpper , Sending short order");
         stopLossPrice = NormalizeDouble(bbUpperLossExit,Digits);
         takeProfitPrice = NormalizeDouble(bbLowerProfitExit,Digits);
         Print("Entry Price = " + Bid);
         Print("Stop Loss Price = " + stopLossPrice);
         Print("Take Profit Price = " + takeProfitPrice);
   	  
   	   openOrderID = OrderSend(NULL,OP_SELLLIMIT,lotSize,Bid,10,stopLossPrice,takeProfitPrice,comment);
   	   if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());
   	   Print("New Short Order"+comment+" "+ openOrderID);
   
   }
   }
     
  }

