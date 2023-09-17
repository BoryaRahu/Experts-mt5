//+------------------------------------------------------------------+
//|                                                   Strategy_2.mq5 |
//|                                                         Alex2356 |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Alex2356"
#property link      "https://www.mql5.com/ru/users/alex2356/seller"
#property version   "1.00"
//---
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| ENUM_COPY_TICKS                                                  |
//+------------------------------------------------------------------+
/*
uint  tick_flags
  {
   COPY_TICKS_INFO =1,     // только Bid и Ask 
   COPY_TICKS_TRADE =2,    // только Last и Volume
   COPY_TICKS_ALL =-1,     // все тики
  };
*/
//+------------------------------------------------------------------+
//| Входные параметры эксперта                                       |
//+------------------------------------------------------------------+
input string               InpEaComment         =  "Strategy #2"; // EA Comment
input int                  InpMagicNum          =  1111;          // Magic number
input double               InpLots              =  0.1;           // Lots
input uint                 InpStopLoss          =  400;           // StopLoss in points
input uint                 InpTakeProfit        =  500;           // TakeProfit in points
//input t        parameters_trailing  =3;   
input    uint   tick_flags          = COPY_TICKS_ALL;    // Тики, вызванные изменениями Bid и/или Ask
input int                  InpPoints            =  15;            // Цена должна пройти NNN пунктов
input uchar                InpTicks             =  15;            // За XXX тиков

//--- массивы для приема тиков
MqlTick        tick_array_curr[];            // массив тиков полученный на текущем тике
MqlTick        tick_array_prev[];            // массив тиков полученный на предыдущем тике
ulong          tick_from=0;                  // если параметр tick_from=0, то отдаются последние tick_count тиков
uint           tick_count=15;                // количество тиков, которые необходимо получить 
//---
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtPoints=0.0;
bool           first_start=false;
long           last_trade_time=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!m_symbol.Name(Symbol()))              // sets symbol name
      return(INIT_FAILED);

   tick_count+=InpTicks;                     // будем запрашивать "tick_count" + "за XXX тиков"
   ExtStopLoss=InpStopLoss*Point();
   ExtTakeProfit=InpTakeProfit*Point();
   ExtPoints=InpPoints*Point();
   first_start=false;
//--- запросим тики (первое заполнение)
   int copied=CopyTicks(Symbol(),tick_array_curr,tick_flags,tick_from,tick_count);
   if(copied!=tick_count)
      first_start=false;
   else
     {
      first_start=true;
      ArrayCopy(tick_array_prev,tick_array_curr);
     }
   m_trade.SetExpertMagicNumber(InpMagicNum);
   m_trade.SetTypeFillingBySymbol(Symbol());
   m_trade.SetMarginMode();
   m_trade.LogLevel(LOG_LEVEL_NO);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- проверка на первый старт
   int copied=-1;
   if(!first_start)
     {
      copied=CopyTicks(Symbol(),tick_array_curr,tick_flags,tick_from,tick_count);
      if(copied!=tick_count)
         first_start=false;
      else
        {
         first_start=true;
         ArrayCopy(tick_array_prev,tick_array_curr);
        }
     }
//--- запросим тики
   copied=CopyTicks(Symbol(),tick_array_curr,tick_flags,tick_from,tick_count);
   if(copied!=tick_count)
      return;
   int index_new=-1;
   long last_time_msc=tick_array_prev[tick_count-1].time_msc;
   for(int i=(int)tick_count-1;i>=0;i--)
     {
      if(last_time_msc==tick_array_curr[i].time_msc)
        {
         index_new=i;
         break;
        }
     }
//---
   if(index_new!=-1 && !IsOpenedByMagic(InpMagicNum))
     {
      int shift=(int)tick_count-1-index_new-InpTicks;   // смещение в текущем массиве тиков
      shift=(shift<0)?0:shift;
      if(tick_array_curr[tick_count-1].ask-tick_array_curr[shift].ask>ExtPoints)
        {
         //--- открываем BUY
         double sl=(InpStopLoss==0)?0.0:tick_array_curr[tick_count-1].ask-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:tick_array_curr[tick_count-1].ask+ExtTakeProfit;
         m_trade.Buy(InpLots,m_symbol.Name(),tick_array_curr[tick_count-1].ask,
                     m_symbol.NormalizePrice(sl),
                     m_symbol.NormalizePrice(tp));
         last_trade_time=tick_array_curr[tick_count-1].time_msc;
        }
      else if(tick_array_curr[shift].bid-tick_array_curr[tick_count-1].bid>ExtPoints)
        {
         //--- открываем SELL
         double sl=(InpStopLoss==0)?0.0:tick_array_curr[tick_count-1].bid-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:tick_array_curr[tick_count-1].bid+ExtTakeProfit;
         m_trade.Sell(InpLots,m_symbol.Name(),tick_array_curr[tick_count-1].bid,
                      m_symbol.NormalizePrice(sl),
                      m_symbol.NormalizePrice(tp));
         last_trade_time=tick_array_curr[tick_count-1].time_msc;
        }
     }
   ArrayCopy(tick_array_prev,tick_array_curr);
//---
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
