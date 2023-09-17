//+------------------------------------------------------------------+
//|                                                   Strategy_3.mq5 |
//|                                                         Alex2356 |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Alex2356"
#property link      "https://www.mql5.com/ru/users/alex2356/seller"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <DoEasy\Engine.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Входные параметры эксперта                                       |
//+------------------------------------------------------------------+
input string               InpEaComment         =  "Strategy #3";    // EA Comment
input int                  InpMagicNum          =  1111;             // Magic number
input double               InpLot               =  0.1;              // Lots
input uint                 InpStopLoss          =  400;              // StopLoss in points
input uint                 InpTakeProfit        =  500;              // TakeProfit in points
input uint                 InpSlippage          =  0;                // Slippage in points
input ENUM_TIMEFRAMES      InpInd_Timeframe     =  PERIOD_H1;        // Timeframe for the calculation
//--- Параметры индикатора Trend direction and force
input int                  InpTrendPeriod       = 20;                // Trend period
input double               InpSmooth            = 3;                 // Smoothing period
input double               InpTriggerUp         =  0.05;             // Trigger up level
input double               InpTriggerDown       = -0.05;             // Trigger down level
//--- Параметры индикатора HMA Color
input uint                 InpPeriodHMA         =  100;              // HMA period
input ENUM_MA_METHOD       InpAvrMethod         =  MODE_LWMA;        // HMA averaging method
input ENUM_APPLIED_PRICE   InpAppPrice          =  PRICE_CLOSE;      // HMA Applied price
//---
CEngine        engine;
CTrade         trade;
//--- Объявление переменных и хендлов индикаторов
double         lot;
ulong          magic_number;
uint           stoploss;
uint           takeprofit;
uint           slippage;
int            InpInd_Handle1,InpInd_Handle2;
double         tdf[],hma[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Первичные проверки
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(InpEaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(InpEaComment,": No Connection!");
      return(INIT_FAILED);
     }
//--- Получение хэндла индикатора Trend direction and force
   InpInd_Handle1=iCustom(Symbol(),InpInd_Timeframe,"Speed Price\\Trend direction and force",
                          InpTrendPeriod,
                          InpSmooth,
                          InpTriggerUp,
                          InpTriggerDown
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(InpEaComment,": Failed to get Trend direction and force handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
       /* 
//--- Получение хэндла индикатора HMA Color
   InpInd_Handle2=iCustom(Symbol(),InpInd_Timeframe,"Speed Price\\HMA Color",
                          "",
                          InpPeriodHMA,
                          InpAvrMethod,
                          InpAppPrice,
                          "",
                          false,
                          false,
                          false,
                          false,
                          "",
                          "",
                          false
                          );
                       
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(InpEaComment,": Failed to get HMA Color handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
     */
//---
   ArrayInitialize(tdf,0.0);
   ArrayInitialize(hma,0.0);
   ArraySetAsSeries(tdf,true);
   ArraySetAsSeries(hma,true);
//--- setting trade parameters
   lot=NormalizeLot(Symbol(),fmax(InpLot,MinimumLots(Symbol())*2.0));
   magic_number=InpMagicNum;
   stoploss=InpStopLoss;
   takeprofit=InpTakeProfit;
   slippage=InpSlippage;
//--- 
   trade.SetDeviationInPoints(slippage);
   trade.SetExpertMagicNumber(magic_number);
   trade.SetTypeFillingBySymbol(Symbol());
   trade.SetMarginMode();
   trade.LogLevel(LOG_LEVEL_NO);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!MQLInfoInteger(MQL_TESTER))
      engine.OnTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Если работа в тестере
   if(MQLInfoInteger(MQL_TESTER))
      engine.OnTimer();

   if(!IsOpenedByMagic(InpMagicNum))
     {
      //--- Получение данных для расчета
      if(!GetIndValue())
         return;
      //---
      if(BuySignal())
        {
         //--- Получаем корректные цены StopLoss и TakeProfit относительно уровня StopLevel
         double sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY,0,stoploss);
         double tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY,0,takeprofit);
         //--- Открываем позицию Buy
         trade.Buy(lot,Symbol(),0,sl,tp);
        }
      else if(SellSignal())
        {
         //--- Получаем корректные цены StopLoss и TakeProfit относительно уровня StopLevel
         double sl=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL,0,stoploss);
         double tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL,0,takeprofit);
         //--- Открываем позицию Sell
         trade.Sell(lot,Symbol(),0,sl,tp);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   return(tdf[0]>=InpTriggerUp && hma[0]>=hma[1])?true:false;
  }
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(tdf[0]<=InpTriggerDown && hma[0]<=hma[1])?true:false;
  }
//+------------------------------------------------------------------+
//| Получение текущих значений индикаторов                           |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
  

 // return(CopyBuffer(InpInd_Handle1,0,0,1,tdf)<1 || CopyBuffer(InpInd_Handle2,0,0,2,hma)<2)?false:true;
  return true;
  }
//+------------------------------------------------------------------+
//| Проверка на открытые позиций с магиком                           |
//+------------------------------------------------------------------+
bool IsOpenedByMagic(int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Select a position on the index                                   |
//+------------------------------------------------------------------+
bool SelectByIndex(const int index)
  {
   ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
//---
   if(margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      ulong ticket=PositionGetTicket(index);
      if(ticket==0)
         return(false);
     }
   else
     {
      string name=PositionGetSymbol(index);
      if(name=="")
         return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
