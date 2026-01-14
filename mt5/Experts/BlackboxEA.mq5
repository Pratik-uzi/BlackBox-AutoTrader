//+------------------------------------------------------------------+
//| BLACKBOX EA – MT5 (FIXED & COMPLETE)                              |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>
CTrade trade;

//================ INPUTS =================//
input double RiskPercent = 1.0;
input int    LookbackSR  = 20;
input double TrapPct     = 0.05;

input double RR_TP1 = 2.0;
input double RR_TP2 = 3.0;
input double RR_BE  = 1.5;

input int EMA_Fast = 50;
input int EMA_Slow = 200;

input int ATR_Length = 14;
input double ATR_Mult = 1.2;

//================ GLOBAL =================//
bool   inBox = false;
int    direction = 0;
double boxHigh, boxLow, laxman;
ulong  ticket = 0;
bool   tp1Done = false;

//================ LOT =================//
double CalcLot(double slPoints)
{
   double riskMoney = AccountInfoDouble(ACCOUNT_EQUITY) * RiskPercent / 100.0;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   double lot = riskMoney / (slPoints * tickValue / tickSize);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   return NormalizeDouble(MathMax(minLot, MathMin(lot, maxLot)), 2);
}

//================ DAILY LEVELS =================//
double GetDailyHigh()
{
   int idx = iHighest(_Symbol, PERIOD_D1, MODE_HIGH, LookbackSR, 1);
   return iHigh(_Symbol, PERIOD_D1, idx);
}

double GetDailyLow()
{
   int idx = iLowest(_Symbol, PERIOD_D1, MODE_LOW, LookbackSR, 1);
   return iLow(_Symbol, PERIOD_D1, idx);
}

//================ ON TICK =================//
void OnTick()
{
   MqlRates rates[];
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 5, rates);

   double close = rates[0].close;
   double high  = rates[0].high;
   double low   = rates[0].low;

   // EMA handles
   static int emaFastH = iMA(_Symbol, PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   static int emaSlowH = iMA(_Symbol, PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
   static int atrH     = iATR(_Symbol, PERIOD_CURRENT, ATR_Length);

   double emaFast[], emaSlow[], atr[];
   CopyBuffer(emaFastH, 0, 0, 1, emaFast);
   CopyBuffer(emaSlowH, 0, 0, 1, emaSlow);
   CopyBuffer(atrH, 0, 0, 1, atr);

   bool bullBias = emaFast[0] > emaSlow[0] && close > emaFast[0];
   bool bearBias = emaFast[0] < emaSlow[0] && close < emaFast[0];

   if (PositionsTotal() == 0)
   {
      tp1Done = false;

      double dHigh = GetDailyHigh();
      double dLow  = GetDailyLow();

      // INIT BOX
      if (!inBox)
      {
         if (close > dHigh && bullBias)
         {
            inBox = true;
            direction = 1;
            laxman = close;
            boxHigh = high;
            boxLow = low;
         }
         if (close < dLow && bearBias)
         {
            inBox = true;
            direction = -1;
            laxman = close;
            boxHigh = high;
            boxLow = low;
         }
      }

      // TRACK BOX
      if (inBox)
      {
         boxHigh = MathMax(boxHigh, high);
         boxLow  = MathMin(boxLow, low);
      }

      // LONG ENTRY
      if (inBox && direction == 1)
      {
         if (low < laxman * (1 - TrapPct/100.0) && close > laxman)
         {
            double sl = boxLow - atr[0] * ATR_Mult;
            double R  = close - sl;
            double lot = CalcLot(R / _Point);

            trade.Buy(lot, _Symbol, close, sl, close + RR_TP2 * R);
            ticket = trade.ResultOrder();
            inBox = false;
         }
      }

      // SHORT ENTRY
      if (inBox && direction == -1)
      {
         if (high > laxman * (1 + TrapPct/100.0) && close < laxman)
         {
            double sl = boxHigh + atr[0] * ATR_Mult;
            double R  = sl - close;
            double lot = CalcLot(R / _Point);

            trade.Sell(lot, _Symbol, close, sl, close - RR_TP2 * R);
            ticket = trade.ResultOrder();
            inBox = false;
         }
      }
   }

   //================ TRADE MANAGEMENT =================//
   if (PositionsTotal() > 0)
   {
      ulong posTicket = PositionGetTicket(0);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl    = PositionGetDouble(POSITION_SL);
      double vol   = PositionGetDouble(POSITION_VOLUME);
      int type     = PositionGetInteger(POSITION_TYPE);

      double R = (type == POSITION_TYPE_BUY) ? entry - sl : sl - entry;
      double price = (type == POSITION_TYPE_BUY) ? close : close;

      // TP1 PARTIAL
      if (!tp1Done)
      {
         double tp1 = (type == POSITION_TYPE_BUY)
                      ? entry + RR_TP1 * R
                      : entry - RR_TP1 * R;

         if ((type == POSITION_TYPE_BUY && price >= tp1) ||
             (type == POSITION_TYPE_SELL && price <= tp1))
         {
            trade.PositionClosePartial(posTicket, vol * 0.7);
            tp1Done = true;
         }
      }

      // BREAKEVEN
      double be = (type == POSITION_TYPE_BUY)
                  ? entry + RR_BE * R
                  : entry - RR_BE * R;

      if ((type == POSITION_TYPE_BUY && price >= be) ||
          (type == POSITION_TYPE_SELL && price <= be))
      {
         trade.PositionModify(posTicket, entry, 0);
      }
   }
}
