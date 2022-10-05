//+------------------------------------------------------------------+
#property copyright "Dheeraj Saxena"
#property link      "www.trademyner.com"
#property strict

string scan_symbols[16] = {"AUDJPY", "AUDNZD", "AUDCAD", "AUDUSD", "AUDCHF", "AUDGBP", "NZDUSD", "GBPUSD", "USDJPY",
                           "EURUSD", "USDCAD", "EURGBP", "EURCAD", "EURAUD", "EURJPY", "EURCHF"
                          };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue()
  {
   if(_Digits >=4)
     {
      return 0.0001;
     }
   else
     {
      return 0.01;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DayOfWeekAlert()
  {

   Alert("");

   int dayOfWeek = DayOfWeek();

   switch(dayOfWeek)
     {
      case 1 :
         Alert("We are Monday. Let's try to enter new trades");
         break;
      case 2 :
         Alert("We are tuesday. Let's try to enter new trades or close existing trades");
         break;
      case 3 :
         Alert("We are wednesday. Let's try to enter new trades or close existing trades");
         break;
      case 4 :
         Alert("We are thursday. Let's try to enter new trades or close existing trades");
         break;
      case 5 :
         Alert("We are friday. Close existing trades");
         break;
      case 6 :
         Alert("It's the weekend. No Trading.");
         break;
      case 0 :
         Alert("It's the weekend. No Trading.");
         break;
      default :
         Alert("Error. No such day in the week.");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTargetProfit(bool bIsLongPosition, double stopLossPrice, double entryPrice, double RR)
  {
   double target;
   if(bIsLongPosition)
     {
      target = entryPrice + (entryPrice - stopLossPrice)*RR;

     }
   else
     {
      target = entryPrice - (stopLossPrice - entryPrice)*RR;

     }
   return NormalizeDouble(target, Digits);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossPrice(bool bIsLongPosition, double entryPrice, int maxLossInPips, bool isIndex = false)
  {
   double stopLossPrice;
   double pip_val;

   if(!isIndex)
     {
      pip_val = GetPipValue();
     }
   else
     {
      pip_val = 1;
     }
   if(bIsLongPosition)
     {
      stopLossPrice = entryPrice - maxLossInPips * pip_val;
     }
   else
     {
      stopLossPrice = entryPrice + maxLossInPips * pip_val;
     }
   return NormalizeDouble(stopLossPrice,Digits);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
  {
   if(!IsTradeAllowed())
     {
      Print("Expert Advisor is NOT Allowed to Trade. Check AutoTrading.");
      return false;
     }

   if(!IsTradeAllowed(Symbol(), TimeCurrent()))
     {
      Print("Trading NOT Allowed for specific Symbol and Time");
      return false;
     }

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
  {

   double accEquity = AccountEquity();
   Print("accEquity: " + accEquity);

   double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
   Print("lotSize: " + lotSize);

   double tickValue = MarketInfo(NULL,MODE_TICKVALUE);

   if(Digits <= 3)
     {
      tickValue = tickValue /100;
     }

   Print("tickValue: " + tickValue);

   double maxLossDollar = accEquity * maxRiskPrc;
   Print("maxLossDollar: " + maxLossDollar);

   double maxLossInQuoteCurr = maxLossDollar / tickValue;
   Print("maxLossInQuoteCurr: " + maxLossInQuoteCurr);

   double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * GetPipValue())/lotSize,2);

   return optimalLotSize;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
  {
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckIfOpenOrdersByComment(int ea_id)
  {
   string comment = get_magic_number(ea_id);
   int openOrders = OrdersTotal();

   for(int i = 0; i < openOrders; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if(OrderComment() == comment)
           {
            return true;
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_magic_number(int ea_id)
  {

   string str = Symbol() +string(ea_id);
   return str;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawHLine(const long            chart_ID=0,        // chart's ID
               string          name="HLine",      // line name
               const int             sub_window=0,      // subwindow index
               double                price=0,           // line price
               const bool            add_label=false,
               string          label_obj_name="Label text",  // label object name
               const string          label_obj_value="Label value",  // label object value
               const color           clr=clrRed,        // line color
               const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
               const string          indicator_name = "Indicator",
               const int             width=1,
               const bool            back=false,        // in the background
               const bool            selection=false,    // highlight to move
               const bool            hidden=true,       // hidden in the object list
               const long            z_order=0
              )         // priority for mouse click
  {
   name = name + indicator_name;
   label_obj_name = label_obj_name + indicator_name;
// draw line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());

     }

//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetInteger(chart_ID, name,OBJPROP_ALIGN, ALIGN_RIGHT);
//--- successful execution

// create line label

   if(add_label)
     {


      ObjectCreate(chart_ID, label_obj_name, OBJ_TEXT, 0, Time[0], price);
      ObjectSetString(chart_ID, label_obj_name,OBJPROP_TEXT, label_obj_value);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_RIGHT);

     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(const long            chart_ID=0,
               const string          name="Arrow",
               double                price=0,
               int ticketId = 0,
               bool bullish = True)

  {
   ObjectCreate(chart_ID, name, OBJ_ARROW, 0, Time[0], price);
   ObjectSetInteger(chart_ID,name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(chart_ID,name, OBJPROP_ARROWCODE, bullish?SYMBOL_ARROWUP:SYMBOL_ARROWDOWN);
   ObjectSetInteger(chart_ID,name, OBJPROP_COLOR, bullish?clrGreen:clrRed);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanChart(string ind_name)
  {
   int Window=0;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1; i>=0; i--)
     {
      if(StringFind(ObjectName(i),ind_name,0)>=0)
        {
         ObjectDelete(ObjectName(i));
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckNewBar()
  {

   static int LastBarCount;
   bool isNewBar = false;
   if(Bars > LastBarCount)
     {
      isNewBar = true;
      LastBarCount = Bars;
     }
   return isNewBar;

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int sendOrder(double LossPips, double RR, double lotSize, string comment, bool isBuy = true, bool isIndex = false)
  {
   double entryPrice;
   int o_type;
   int openOrderID;

   if(isBuy)
     {
      entryPrice = Ask;
      o_type = OP_BUYLIMIT;
     }
   else
     {
      entryPrice = Bid;
      o_type = OP_SELLLIMIT;
     }
   Print("Sending order for Strategy-"+comment+"-"+Symbol());
   double stopLossPrice = GetStopLossPrice(isBuy, entryPrice, LossPips, isIndex);
   double takeProfitPrice = GetTargetProfit(isBuy, stopLossPrice, entryPrice,RR);
   Print("Entry Price = " + entryPrice);
   Print("Stop Loss Price = " + stopLossPrice);
   Print("Take Profit Price = " + takeProfitPrice);
   openOrderID = OrderSend(NULL,o_type,lotSize,entryPrice,10,stopLossPrice,takeProfitPrice,comment);
   if(openOrderID < 0)
     {
      Print("Order rejected. Order error: " + GetLastError());
     }
   else
     {

      Print("New Order "+comment+" "+ openOrderID);
      return openOrderID;


     }

   return 0;

  }
//+------------------------------------------------------------------+
int detect_indicator_cross(double fast_val_curr,
                           double slow_val_curr,
                           double fast_val_prev,
                           double slow_val_prev)
  {

//cross_up check
   bool cond_11 = fast_val_curr > slow_val_curr;
   bool cond_22 = slow_val_prev > fast_val_prev;

   if(cond_11 && cond_22)
     {
      return 1;
     }
//cross_down check
   bool cond_1 = fast_val_curr < slow_val_curr;
   bool cond_2 = fast_val_prev > slow_val_prev;

   if(cond_1 && cond_2)
     {
      return 2;
     }

   return 0;

  }
//+------------------------------------------------------------------+
int detect_ema_cross(int slow_period, int fast_period)

  {
   double slow_val_curr = iMA(Symbol(), 0, slow_period, 0, MODE_EMA, PRICE_CLOSE, 0);
   double slow_val_prev = iMA(Symbol(), 0, slow_period, 0, MODE_EMA, PRICE_CLOSE, 1);
   double fast_val_curr = iMA(Symbol(), 0, fast_period, 0, MODE_EMA, PRICE_CLOSE, 0);
   double fast_val_prev = iMA(Symbol(), 0, fast_period, 0, MODE_EMA, PRICE_CLOSE, 1);

   int iCross = detect_indicator_cross(fast_val_curr,
                                       slow_val_curr,
                                       fast_val_prev,
                                       slow_val_prev);
   return iCross;

  }
//+------------------------------------------------------------------+

int detect_macd_cross(int entry_period, int fast =6, int slow = 12, int smoothing = 9)

  {
   double curr_macd = iMACD(NULL, entry_period, fast, slow, smoothing, PRICE_CLOSE, MODE_MAIN, 0);
   double prev_macd = iMACD(NULL, entry_period, fast, slow, smoothing, PRICE_CLOSE, MODE_MAIN, 1);
   double curr_signal = iMACD(NULL, entry_period, fast, slow, smoothing, PRICE_CLOSE, MODE_SIGNAL, 0);
   double prev_signal = iMACD(NULL, entry_period,fast, slow, smoothing, PRICE_CLOSE, MODE_SIGNAL, 1);

   int iCross = detect_indicator_cross(curr_macd,
                                       curr_signal,
                                       prev_macd,
                                       prev_signal);
   return iCross;

  }
//+------------------------------------------------------------------+
