input double ATRMultiplier=2.0;       //ATR Factor
input int ATRPeriod=100;              //ATR Period
input double Profit_Factor=1;          //Profit Factor
input double volume=0.01;              //Position Size
datetime timer=NULL;

int last_trade=-1;
double last_balance=0;

void OnDeinit(const int reason)
  {
   DeleteAll();
  }

int OnInit()
  {
   last_balance=AccountBalance();
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
      if(last_balance!=AccountBalance())
      {  //exited
         DrawExit((AccountBalance()-last_balance)>0?true:false);
         Comment("");
      }
      last_balance=AccountBalance();
      ///on bar open execution only
      if(timer==NULL)
      {
      
      }
      else if(timer==iTime(_Symbol, PERIOD_CURRENT, 0))
      {
         return;
      }
      timer=iTime(_Symbol, PERIOD_CURRENT, 0);
      //////////////////////////////////////////////////////
      if(OrdersTotal()>0)
         UpdateLine_SLTP();
      
      if(OrdersTotal()>0)
      {
         stop_trail();
         if(!OrderSelect(0, SELECT_BY_POS))
         {
            Alert("order select error: " + GetLastError());
            ExpertRemove();
         }
         if(OrderType()==OP_BUY && change_down())
         {
            if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE))
            {
               Alert("order close error: " + GetLastError());
               ExpertRemove();
            }
         }
         else if(OrderType()==OP_SELL && change_up())
         {
            if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE))
            {
               Alert("order close error: " + GetLastError());
               ExpertRemove();
            }
         }
         return;
      }
  
      bool long_condition=true;
      long_condition &= change_up();
      if(long_condition)
      {
         Buy();
         last_trade=OP_BUY;
         DrawBuy();
         DrawSLTP();
      }
      bool short_condition=true;
      short_condition &= change_down();
      if(short_condition)
      {
         Sell();
         last_trade=OP_SELL;
         DrawSell();
         DrawSLTP();
      }
      
//---
  }
//+------------------------------------------------------------------+


double countBuySellTotal()
{
   double s=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i, SELECT_BY_POS))
      {
         if(OrderType() == OP_BUY) s+=OrderLots();
         else if(OrderType() == OP_SELL) s-=OrderLots();
      }
   }
   return s;
}

bool change_up()
{
   return iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND", ATRMultiplier, ATRPeriod, 1000, 2, 1)==1 &&
   iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND", 2, 100, 1000, 2, 2)==-1;
}

bool change_down()
{
   return iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND", ATRMultiplier, ATRPeriod, 1000, 2, 1)==-1 &&
   iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND", 2, 100, 1000, 2, 2)==1;
}

void Buy()
{
   double price=Ask;
   double sl = iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND",ATRMultiplier, ATRPeriod, 1000, 0, 0);
   double tp = Ask + Profit_Factor*(price-sl);
   if(OrderSend(_Symbol, OP_BUY, volume, price, 3, sl,tp, NULL, 0, 0, clrNONE)==-1)
   {
      Alert("Error executing buy order: "+GetLastError());
      ExpertRemove();
   }
}

void Sell()
{
   double price=Bid;
   double sl = iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND", ATRMultiplier, ATRPeriod, 1000, 1, 0);
   double tp = Bid - Profit_Factor*(sl-price);
   if(OrderSend(_Symbol, OP_SELL, volume, price, 3, sl,tp, NULL, 0, 0, clrNONE)==-1)
   {
      Alert("Error executing sell order: "+GetLastError());
      ExpertRemove();
   }
}

void stop_trail()
{
   if(!OrderSelect(0, SELECT_BY_POS))
   {
      Alert("order select error: " + GetLastError());
      ExpertRemove();
   }
   double sl=0;
   if(OrderType() == OP_BUY)
   {
      sl = iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND",ATRMultiplier, ATRPeriod, 1000, 0, 0);
      if(sl<OrderStopLoss())
         return;
   }
   else if(OrderType() == OP_SELL)
   {
      sl = iCustom(_Symbol, PERIOD_CURRENT, "SuperTrend", "SPRTRND", ATRMultiplier, ATRPeriod, 1000, 1, 0);
      if(sl>OrderStopLoss())
         return;
   }
   if(!OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), 0, clrNONE))
   {
      //Alert("order modify error: " + GetLastError());
      //ExpertRemove();
   }
}

int kk=0;
int kk_long=0;
int kk_short=0;
int kk_e=0;
int kk_t=0;
int kk_s=0;
void DrawBuy()
{
   if(!OrderSelect(0, SELECT_BY_POS))
   {
      Alert("order select error: " + GetLastError());
      ExpertRemove();
   }
   double xx = iATR(_Symbol,0,14,0);
   ObjectCreate(ChartID(), "ARROW"+string(kk++), OBJ_ARROW_UP, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-2*xx);
   ObjectSetInteger(ChartID(), "ARROW"+string(kk-1), OBJPROP_COLOR, clrBlue);

   string s1,s2,s3;
   s1="E - "+OrderOpenPrice();
   s2="T - "+OrderTakeProfit() + "("+ ((OrderTakeProfit()-OrderOpenPrice())*MathPow(10,_Digits))+")";
   s3="S - "+OrderStopLoss() + "("+ ((OrderOpenPrice()-OrderStopLoss())*MathPow(10,_Digits))+")";

   ObjectCreate(ChartID(), "OBJ_TEXTLONG"+string(kk_long++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-3*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTLONG"+string(kk_long-1), OBJPROP_TEXT, "L");
   ObjectSetInteger(ChartID(), "OBJ_TEXTLONG"+string(kk_long-1), OBJPROP_COLOR, clrBlue);

   ObjectCreate(ChartID(), "OBJ_TEXTE"+string(kk_e++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-5*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTE"+string(kk_e-1), OBJPROP_TEXT, s1);
   
   ObjectCreate(ChartID(), "OBJ_TEXTT"+string(kk_t++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-6*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTT"+string(kk_t-1), OBJPROP_TEXT, s2);

   ObjectCreate(ChartID(), "OBJ_TEXTS"+string(kk_s++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-7*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTS"+string(kk_s-1), OBJPROP_TEXT, s3);


   ObjectCreate(ChartID(), "OBJ_TEXTID"+string(kk_id++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-8*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTID"+string(kk_id-1), OBJPROP_TEXT,  "ID - " + (string)OrderTicket());


   ObjectCreate(ChartID(), "OBJ_TEXTOT"+string(kk_ot++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-9*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTOT"+string(kk_ot-1), OBJPROP_TEXT,  "TIme - " + TimeToStr(OrderOpenTime()));
}

int kk_ot=0;
int kk_id=0;
void DrawSell()
{
   if(!OrderSelect(0, SELECT_BY_POS))
   {
      Alert("order select error: " + GetLastError());
      ExpertRemove();
   }
   double xx = iATR(_Symbol,0,14,0);
   ObjectCreate(ChartID(), "ARROW"+string(kk++), OBJ_ARROW_DOWN, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+2*xx);
   ObjectSetInteger(ChartID(), "ARROW"+string(kk-1), OBJPROP_COLOR, clrRed);

   string s1,s2,s3;
   s1="E - "+OrderOpenPrice();
   s2="T - "+OrderTakeProfit() + "("+ ((OrderOpenPrice()-OrderTakeProfit())*MathPow(10,_Digits))+")";
   s3="S - "+OrderStopLoss() + "("+ ((OrderStopLoss()-OrderOpenPrice())*MathPow(10,_Digits))+")";

   ObjectCreate(ChartID(), "OBJ_TEXTSHORT"+string(kk_short++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+3*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTSHORT"+string(kk_short-1), OBJPROP_TEXT, "S");
   ObjectSetInteger(ChartID(), "OBJ_TEXTSHORT"+string(kk_short-1), OBJPROP_COLOR, clrRed);

   ObjectCreate(ChartID(), "OBJ_TEXTE"+string(kk_e++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+7*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTE"+string(kk_e-1), OBJPROP_TEXT, s1);

   ObjectCreate(ChartID(), "OBJ_TEXTT"+string(kk_t++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+6*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTT"+string(kk_t-1), OBJPROP_TEXT, s2);

   ObjectCreate(ChartID(), "OBJ_TEXTS"+string(kk_s++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+5*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTS"+string(kk_s-1), OBJPROP_TEXT, s3);

   ObjectCreate(ChartID(), "OBJ_TEXTID"+string(kk_id++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+8*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTID"+string(kk_id-1), OBJPROP_TEXT, "ID - " + (string)OrderTicket());


   ObjectCreate(ChartID(), "OBJ_TEXTOT"+string(kk_ot++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+9*xx);
   ObjectSetString(ChartID(), "OBJ_TEXTOT"+string(kk_ot-1), OBJPROP_TEXT, "Time - " + TimeToStr(OrderOpenTime()));
}

int kk_se=0;
int kk_le=0;
int kk_sel=0;
int kk_lel=0;
int kk_sep=0;
int kk_lep=0;
void DrawExit(bool p)
{
   double xx = iATR(_Symbol,0,14,0);
   if(last_trade == OP_BUY)
   {
      if(p)
      {
         ObjectCreate(ChartID(), "ARROWLEP"+string(kk_lep++), OBJ_ARROW_DOWN, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+2*xx);
         ObjectSetInteger(ChartID(), "ARROWLEP"+string(kk_lep-1), OBJPROP_COLOR, clrBlue);
         ObjectCreate(ChartID(), "OBJ_TEXTLE"+string(kk_le++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+3*xx);
         ObjectSetString(ChartID(), "OBJ_TEXTLE"+string(kk_le-1), OBJPROP_TEXT, "LE");
      }
      else 
      {
         ObjectCreate(ChartID(), "ARROWLEL"+string(kk_lel++), OBJ_ARROW_UP, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-2*xx);
         ObjectSetInteger(ChartID(), "ARROWLEL"+string(kk_lel-1), OBJPROP_COLOR, clrBlue);
         ObjectCreate(ChartID(), "OBJ_TEXTLE"+string(kk_le++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-3*xx);
         ObjectSetString(ChartID(), "OBJ_TEXTLE"+string(kk_le-1), OBJPROP_TEXT, "LE");
      }
   }
   else
   {
      if(p)
      {
         ObjectCreate(ChartID(), "ARROWSEP"+string(kk_sep++), OBJ_ARROW_UP, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-2*xx);
         ObjectSetInteger(ChartID(), "ARROWSEP"+string(kk_sep-1), OBJPROP_COLOR, clrRed);
         ObjectCreate(ChartID(), "OBJ_TEXTLE"+string(kk_le++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), Low[0]-3*xx);
         ObjectSetString(ChartID(), "OBJ_TEXTLE"+string(kk_le-1), OBJPROP_TEXT, "SE");
      }
      else 
      {
         ObjectCreate(ChartID(), "ARROWSEL"+string(kk_sel++), OBJ_ARROW_DOWN, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+2*xx);
         ObjectSetInteger(ChartID(), "ARROWSEL"+string(kk_sel-1), OBJPROP_COLOR, clrRed);
         ObjectCreate(ChartID(), "OBJ_TEXTLE"+string(kk_le++), OBJ_TEXT, 0, iTime(_Symbol, PERIOD_CURRENT,0), High[0]+3*xx);
         ObjectSetString(ChartID(), "OBJ_TEXTLE"+string(kk_le-1), OBJPROP_TEXT, "SE");
      }
   }
}

double stop=0;
double profit=0;
int kk_trendsl=0;
int kk_trendtp=0;
void DrawSLTP()
{
   if(!OrderSelect(0, SELECT_BY_POS))
   {
      Alert("order select error: " + GetLastError());
      ExpertRemove();
   }
   ObjectCreate(ChartID(), "TRENDSL"+string(kk_trendsl++), OBJ_TREND, 0,OrderOpenTime(), OrderStopLoss(), TimeCurrent(), OrderStopLoss());
   ObjectSetInteger(ChartID(), "TRENDSL"+string(kk_trendsl-1), OBJPROP_COLOR, clrRed); 
   ObjectSetInteger(ChartID(),"TRENDSL"+string(kk_trendsl-1), OBJPROP_RAY,0);
   
   ObjectCreate(ChartID(), "TRENDTP"+string(kk_trendtp++), OBJ_TREND, 0, OrderOpenTime(), OrderTakeProfit(), TimeCurrent(), OrderTakeProfit());
   ObjectSetInteger(ChartID(), "TRENDTP"+string(kk_trendtp-1), OBJPROP_COLOR, clrBlue); 
   ObjectSetInteger(ChartID(),"TRENDTP"+string(kk_trendtp-1), OBJPROP_RAY,0);
   stop = OrderStopLoss();
   profit = OrderTakeProfit();
}

void UpdateLine_SLTP()
{
   if(!OrderSelect(0, SELECT_BY_POS))
   {
      Alert("order select error: " + GetLastError());
      ExpertRemove();
   }
   ObjectDelete(ChartID(), "TRENDSL"+string(kk_trendsl-1));
   ObjectDelete(ChartID(), "TRENDTP"+string(kk_trendtp-1));
   
   ObjectCreate(ChartID(), "TRENDSL"+string(kk_trendsl-1), OBJ_TREND, 0, OrderOpenTime(), stop, TimeCurrent(), stop);
   ObjectSetInteger(ChartID(), "TRENDSL"+string(kk_trendsl-1), OBJPROP_COLOR, clrRed); 
   ObjectSetInteger(ChartID(),"TRENDSL"+string(kk_trendsl-1), OBJPROP_RAY,0);
   
   ObjectCreate(ChartID(), "TRENDTP"+string(kk_trendtp-1), OBJ_TREND, 0, OrderOpenTime(), profit, TimeCurrent(), profit);
   ObjectSetInteger(ChartID(), "TRENDTP"+string(kk_trendtp-1), OBJPROP_COLOR, clrBlue); 
   ObjectSetInteger(ChartID(),"TRENDTP"+string(kk_trendtp-1), OBJPROP_RAY,0);
   
}

void DeleteAll()
{
   ObjectsDeleteAll();
}
