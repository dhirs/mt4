//
// EA Studio Expert Advisor
//
// Created with: Expert Advisor Studio
// Website: https://eatradingacademy.com/software/expert-advisor-studio/
//
// Copyright 2022, Forex Software Ltd.
//
// Risk Disclosure
//
// Futures and forex trading contains substantial risk and is not for every investor.
// An investor could potentially lose all or more than the initial investment.
// Risk capital is money that can be lost without jeopardizing ones’ financial security or life style.
// Only risk capital should be used for trading and only those with sufficient risk capital should consider trading.

#property copyright "Forex Software Ltd."
#property version   "3.2"
#property strict

static input string _Properties_ = "------"; // --- Expert Properties ---
static input double Entry_Amount =     0.10; // Entry lots
       input int    Stop_Loss    =      100; // Stop Loss   (pips)
       input int    Take_Profit  =       30; // Take Profit (pips)

static input string ___0______   = "------"; // --- Bollinger Bands ---
       input int    Ind0Param0   =       10; // Period
       input double Ind0Param1   =     2.00; // Deviation

static input string ___1______   = "------"; // --- Force Index ---
       input int    Ind1Param0   =       38; // Period

static input string ___2______   = "------"; // --- Commodity Channel Index ---
       input int    Ind2Param0   =       45; // Period
       input int    Ind2Param1   =      -75; // Level
static input string _Settings___ = "------"; // --- Expert Settings ---
static input int    Magic_Number = 73425319; // Magic Number

#define TRADE_RETRY_COUNT   4
#define TRADE_RETRY_WAIT  100
#define OP_FLAT            -1

// Session time is set in seconds from 00:00
int  sessionSundayOpen          =     0; // 00:00
int  sessionSundayClose         = 86400; // 24:00
int  sessionMondayThursdayOpen  =     0; // 00:00
int  sessionMondayThursdayClose = 86400; // 24:00
int  sessionFridayOpen          =     0; // 00:00
int  sessionFridayClose         = 86400; // 24:00
bool sessionIgnoreSunday        = false;
bool sessionCloseAtSessionClose = false;
bool sessionCloseAtFridayClose  = false;

const double sigma        = 0.000001;
const int    requiredBars = 48;

double posType       = OP_FLAT;
int    posTicket     = 0;
double posLots       = 0;
double posStopLoss   = 0;
double posTakeProfit = 0;

datetime barTime;
double   pip;
double   stopLevel;
bool     isTrailingStop          = false;
bool     setProtectionSeparately = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   barTime        = Time[0];
   stopLevel      = MarketInfo(_Symbol, MODE_STOPLEVEL);
   pip            = GetPipValue();
   isTrailingStop = isTrailingStop && Stop_Loss > 0;

   return ValidateInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (ArraySize(Time) < requiredBars)
      return;

   if (Time[0] > barTime)
     {
      barTime = Time[0];
      OnBar();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBar()
  {
   UpdatePosition();

   if (posType != OP_FLAT && IsForceSessionClose())
     {
      ClosePosition();
      return;
     }

   if ( IsOutOfSession() )
      return;

   if (posType != OP_FLAT)
     {
      ManageClose();
      UpdatePosition();
     }

   if (posType != OP_FLAT && isTrailingStop)
     {
      double trailingStop = GetTrailingStopPrice();
      ManageTrailingStop(trailingStop);
      UpdatePosition();
     }

   int entrySignal = GetEntrySignal();

   if (posType == OP_FLAT && entrySignal != OP_FLAT)
     {
      OpenPosition(entrySignal);
      UpdatePosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePosition()
  {
   posType   = OP_FLAT;
   posTicket = 0;
   posLots   = 0;
   int total = OrdersTotal();

   for (int pos = total - 1; pos >= 0; pos--)
     {
      if (OrderSelect(pos, SELECT_BY_POS) &&
          OrderSymbol()      == _Symbol   &&
          OrderMagicNumber() == Magic_Number)
        {
         posType       = OrderType();
         posLots       = OrderLots();
         posTicket     = OrderTicket();
         posStopLoss   = OrderStopLoss();
         posTakeProfit = OrderTakeProfit();
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetEntrySignal()
  {
   // Bollinger Bands (Close, 10, 2.00)
   double ind0upBand1 = iBands(NULL, 0, Ind0Param0, Ind0Param1, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ind0dnBand1 = iBands(NULL, 0, Ind0Param0, Ind0Param1, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double ind0upBand2 = iBands(NULL, 0, Ind0Param0, Ind0Param1, 0, PRICE_CLOSE, MODE_UPPER, 2);
   double ind0dnBand2 = iBands(NULL, 0, Ind0Param0, Ind0Param1, 0, PRICE_CLOSE, MODE_LOWER, 2);
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   // Force Index (Simple, 38)
   double ind1val1  = iForce(NULL, 0, Ind1Param0, MODE_SMA, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 > 0 + sigma;
   bool   ind1short = ind1val1 < 0 - sigma;

   bool canOpenLong  = ind0long && ind1long;
   bool canOpenShort = ind0short && ind1short;

   return canOpenLong  && !canOpenShort ? OP_BUY
        : canOpenShort && !canOpenLong  ? OP_SELL
        : OP_FLAT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageClose()
  {
   // Commodity Channel Index (Typical, 45), Level: -75
   double ind2val1  = iCCI(NULL, 0, Ind2Param0, PRICE_TYPICAL, 1);
   double ind2val2  = iCCI(NULL, 0, Ind2Param0, PRICE_TYPICAL, 2);
   bool   ind2long  = ind2val1 > Ind2Param1 + sigma && ind2val2 < Ind2Param1 - sigma;
   bool   ind2short = ind2val1 < -Ind2Param1 - sigma && ind2val2 > -Ind2Param1 + sigma;

   if ( (posType == OP_BUY  && ind2long) ||
        (posType == OP_SELL && ind2short) )
      ClosePosition();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(int command)
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      int    ticket     = 0;
      int    lastError  = 0;
      bool   modified   = false;
      string comment    = IntegerToString(Magic_Number);
      color  arrowColor = command == OP_BUY ? clrGreen : clrRed;

      if (IsTradeContextFree())
        {
         double price      = command == OP_BUY ? Ask() : Bid();
         double stopLoss   = GetStopLossPrice(command);
         double takeProfit = GetTakeProfitPrice(command);

         if (setProtectionSeparately)
           {
            // Send an entry order without SL and TP
            ticket = OrderSend(_Symbol, command, Entry_Amount, price, 10, 0, 0, comment, Magic_Number, 0, arrowColor);

            // If the order is successful, modify the position with the corresponding SL and TP
            if (ticket > 0 && (Stop_Loss > 0 || Take_Profit > 0))
               modified = OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrBlue);
           }
         else
           {
            // Send an entry order with SL and TP
            ticket    = OrderSend(_Symbol, command, Entry_Amount, price, 10, stopLoss, takeProfit, comment, Magic_Number, 0, arrowColor);
            lastError = GetLastError();

            // If order fails, check if it is because inability to set SL or TP
            if (ticket <= 0 && lastError == 130)
              {
               // Send an entry order without SL and TP
               ticket = OrderSend(_Symbol, command, Entry_Amount, price, 10, 0, 0, comment, Magic_Number, 0, arrowColor);

               // Try setting SL and TP
               if (ticket > 0 && (Stop_Loss > 0 || Take_Profit > 0))
                  modified = OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrBlue);

               // Mark the expert to set SL and TP with a separate order
               if (ticket > 0 && modified)
                 {
                  setProtectionSeparately = true;
                  Print("Detected ECN type position protection.");
                 }
              }
           }
        }

      if (ticket > 0)
         break;

      lastError = GetLastError();
      if (lastError != 135 && lastError != 136 && lastError != 137 && lastError != 138)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Open Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition()
  {
   for(int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      bool closed;
      int lastError = 0;

      if ( IsTradeContextFree() )
        {
         double price = posType == OP_BUY ? Bid() : Ask();
         closed    = OrderClose(posTicket, posLots, price, 10, clrYellow);
         lastError = GetLastError();
        }

      if (closed)
         break;

      if (lastError == 4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Close Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyPosition()
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      bool modified;
      int lastError = 0;

      if ( IsTradeContextFree() )
        {
         modified  = OrderModify(posTicket, 0, posStopLoss, posTakeProfit, 0, clrBlue);
         lastError = GetLastError();
        }

      if (modified)
         break;

      if (lastError == 4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Modify Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossPrice(int command)
  {
   if (Stop_Loss == 0)
      return 0;

   double delta    = MathMax(pip * Stop_Loss, _Point * stopLevel);
   double stopLoss = command == OP_BUY ? Bid() - delta : Ask() + delta;

   return NormalizeDouble(stopLoss, _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfitPrice(int command)
  {
   if (Take_Profit == 0)
      return 0;

   double delta      = MathMax(pip * Take_Profit, _Point * stopLevel);
   double takeProfit = command == OP_BUY ? Bid() + delta : Ask() - delta;

   return NormalizeDouble(takeProfit, _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrailingStopPrice()
  {
   double bid = Bid();
   double ask = Ask();
   double stopLevelPoints = _Point * stopLevel;
   double stopLossPoints  = pip * Stop_Loss;

   if (posType == OP_BUY)
     {
      double stopLossPrice = High(1) - stopLossPoints;
      if (posStopLoss < stopLossPrice - pip)
         return stopLossPrice < bid
                 ? stopLossPrice >= bid - stopLevelPoints
                    ? bid - stopLevelPoints
                    : stopLossPrice
                 : bid;
     }

   if (posType == OP_SELL)
     {
      double stopLossPrice = Low(1) + stopLossPoints;
      if (posStopLoss > stopLossPrice + pip)
         return stopLossPrice > ask
                 ? stopLossPrice <= ask + stopLevelPoints
                    ? ask + stopLevelPoints
                    : stopLossPrice
                 : ask;
     }

   return posStopLoss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageTrailingStop(double trailingStop)
  {
   if ( (posType == OP_BUY  && MathAbs(trailingStop - Bid()) < _Point) ||
        (posType == OP_SELL && MathAbs(trailingStop - Ask()) < _Point) )
     {
      ClosePosition();
      return;
     }

   if ( MathAbs(trailingStop - posStopLoss) > _Point )
     {
      posStopLoss = NormalizeDouble(trailingStop, _Digits);
      ModifyPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid()
  {
   return MarketInfo(_Symbol, MODE_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ask()
  {
   return MarketInfo(_Symbol, MODE_ASK);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(int bar)
  {
   return Time[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(int bar)
  {
   return Open[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(int bar)
  {
   return High[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Low(int bar)
  {
   return Low[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int bar)
  {
   return Close[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue()
  {
   return _Digits == 4 || _Digits == 5 ? 0.0001
        : _Digits == 2 || _Digits == 3 ? 0.01
                        : _Digits == 1 ? 0.1 : 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeContextFree()
  {
   if ( IsTradeAllowed() )
      return true;

   uint startWait = GetTickCount();
   Print("Trade context is busy! Waiting...");

   while (true)
     {
      if (IsStopped())
         return false;

      uint diff = GetTickCount() - startWait;
      if (diff > 30 * 1000)
        {
         Print("The waiting limit exceeded!");
         return false;
        }

      if ( IsTradeAllowed() )
        {
         RefreshRates();
         return true;
        }

      Sleep(TRADE_RETRY_WAIT);
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOutOfSession()
  {
   int dayOfWeek    = DayOfWeek();
   int periodStart  = int(Time(0) % 86400);
   int periodLength = PeriodSeconds(_Period);
   int periodFix    = periodStart + (sessionCloseAtSessionClose ? periodLength : 0);
   int friBarFix    = periodStart + (sessionCloseAtFridayClose || sessionCloseAtSessionClose ? periodLength : 0);

   return dayOfWeek == 0 && sessionIgnoreSunday ? true
        : dayOfWeek == 0 ? periodStart < sessionSundayOpen         || periodFix > sessionSundayClose
        : dayOfWeek  < 5 ? periodStart < sessionMondayThursdayOpen || periodFix > sessionMondayThursdayClose
                         : periodStart < sessionFridayOpen         || friBarFix > sessionFridayClose;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsForceSessionClose()
  {
   if (!sessionCloseAtFridayClose && !sessionCloseAtSessionClose)
      return false;

   int dayOfWeek = DayOfWeek();
   int periodEnd = int(Time(0) % 86400) + PeriodSeconds(_Period);

   return dayOfWeek == 0 && sessionCloseAtSessionClose ? periodEnd > sessionSundayClose
        : dayOfWeek  < 5 && sessionCloseAtSessionClose ? periodEnd > sessionMondayThursdayClose
        : dayOfWeek == 5 ? periodEnd > sessionFridayClose : false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE ValidateInit()
  {
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
/*STRATEGY MARKET Premium Data; EURJPY; M15 */
/*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":100,"takeProfit":30,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Bollinger Bands","listIndexes":[4,3,0,0,0],"numValues":[10,2,0,0,0,0]},{"name":"Force Index","listIndexes":[2,0,0,0,0],"numValues":[38,0,0,0,0,0]}],"closeFilters":[{"name":"Commodity Channel Index","listIndexes":[4,5,0,0,0],"numValues":[45,-75,0,0,0,0]}]} */
