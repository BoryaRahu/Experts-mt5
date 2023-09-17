//+------------------------------------------------------------------+
//|                                           Heiken_Ashi_Expert.mq5 |
//|                                               Copyright VDV Soft |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "VDV Soft"
#property link      "vdv_2001@mail.ru"
#property version   "1.00"

#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

//--- the list of global variables

//--- input parameters
input double Lot=0.1;    // Размер лота / Size lot
//--- indicator handles
int      hHeiken_Ashi;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   hHeiken_Ashi=iCustom(NULL,PERIOD_CURRENT,"Examples\\Heiken_Ashi");
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      if(BarsCalculated(hHeiken_Ashi)>100)
        {
         CheckForOpenClose();
        }
//---
  }
//+------------------------------------------------------------------+
//| Проверка условий и открытие позиции                              |
//| Check of conditions and item opening                             |
//+------------------------------------------------------------------+
void CheckForOpenClose()
  {
//--- обрабатываем ордера только при поступлении первого тика новой свечи
//--- we process warrants only at receipt of the first tic of a new candle
   MqlRates rt[1];
   if(CopyRates(_Symbol,_Period,0,1,rt)!=1)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
   if(rt[0].tick_volume>1) return;
//--- для проверки условий нам необходимы три последних бара
//--- three last bars are necessary for check of conditions for us
#define  BAR_COUNT   3
//--- номер буфера индикатора для хранения Open
//--- number of the buffer of the indicator for storage Open
#define  HA_OPEN     0
//--- номер буфера индикатора для хранения High
//--- number of the buffer of the indicator for storage High
#define  HA_HIGH     1
//--- номер буфера индикатора для хранения Low
//--- number of the buffer of the indicator for storage Low
#define  HA_LOW      2
//--- номер буфера индикатора для хранения Close
//--- number of the buffer of the indicator for storage Close
#define  HA_CLOSE    3

   double   haOpen[BAR_COUNT],haHigh[BAR_COUNT],haLow[BAR_COUNT],haClose[BAR_COUNT];

   if(CopyBuffer(hHeiken_Ashi,HA_OPEN,0,BAR_COUNT,haOpen)!=BAR_COUNT
      || CopyBuffer(hHeiken_Ashi,HA_HIGH,0,BAR_COUNT,haHigh)!=BAR_COUNT
      || CopyBuffer(hHeiken_Ashi,HA_LOW,0,BAR_COUNT,haLow)!=BAR_COUNT
      || CopyBuffer(hHeiken_Ashi,HA_CLOSE,0,BAR_COUNT,haClose)!=BAR_COUNT)
     {
      Print("CopyBuffer from Heiken_Ashi failed, no data");
      return;
     }
//---- проверяем сигналы для продажи
//---- we check signals for sale
   if(haOpen[BAR_COUNT-2]>haClose[BAR_COUNT-2])// свеча на понижение / candle on fall
     {
      CPositionInfo posinf;
      CTrade trade;
      double lot=Lot;
      //--- проверяем есть открытая позиция, если на покупку закрываем ее
      //--- we check there is an open position if on purchase it is closed it
      if(posinf.Select(_Symbol))
        {
         if(posinf.Type()==POSITION_TYPE_BUY)
           {
            //            lot=lot*2;
            trade.PositionClose(_Symbol,3);
           }
        }
      //--- проверяем и устанавливаем уровень стопа
      //--- we check and instal stop level
      double stop_loss=NormalizeDouble(haHigh[BAR_COUNT-2],_Digits)+_Point*2;
      double stop_level=SymbolInfoDouble(_Symbol,SYMBOL_ASK)+SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
      if(stop_loss<stop_level) stop_loss=stop_level;
      //--- проверяем комбинацию: сформировалась свеча противоположного цвета
      //--- we check a combination: the candle of opposite colour was generated
      if(haOpen[BAR_COUNT-3]<haClose[BAR_COUNT-3])
        {
         if(!trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lot,SymbolInfoDouble(_Symbol,SYMBOL_BID),stop_loss,0))
            Print(trade.ResultRetcodeDescription());
        }
      else
      if(posinf.Select(_Symbol))
        {
         if(!trade.PositionModify(_Symbol,stop_loss,0))
            Print(trade.ResultRetcodeDescription());
        }
     }
//---- проверяем сигналы для покупки
//---- We check signals for purchase
   if(haOpen[BAR_COUNT-2]<haClose[BAR_COUNT-2])// свеча на повышение / сandle on increase
     {
      CPositionInfo posinf;
      CTrade trade;
      double lot=Lot;
      //--- проверяем есть открытая позиция, если на продажу закрываем ее
      //--- we check there is an open position if on sale it is closed it
      if(posinf.Select(_Symbol))
        {
         if(posinf.Type()==POSITION_TYPE_SELL)
           {
            //            lot=lot*2;
            trade.PositionClose(_Symbol,3);
           }
        }
      //--- проверяем и устанавливаем уровень стопа
      //--- we check and instal stop level
      double stop_loss=NormalizeDouble(haLow[BAR_COUNT-2],_Digits)-_Point*2;
      double stop_level=SymbolInfoDouble(_Symbol,SYMBOL_BID)-SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
      if(stop_loss>stop_level) stop_loss=stop_level;
      //--- проверяем комбинацию: сформировалась свеча противоположного цвета
      //--- we check a combination: the candle of opposite colour was generated
      if(haOpen[BAR_COUNT-3]>haClose[BAR_COUNT-3])
        {
         if(!trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lot,SymbolInfoDouble(_Symbol,SYMBOL_ASK),stop_loss,0))
            Print(trade.ResultRetcodeDescription());
        }
      else
      if(posinf.Select(_Symbol))
        {
         if(!trade.PositionModify(_Symbol,stop_loss,0))
            Print(trade.ResultRetcodeDescription());
        }

     }
  }
//+------------------------------------------------------------------+
