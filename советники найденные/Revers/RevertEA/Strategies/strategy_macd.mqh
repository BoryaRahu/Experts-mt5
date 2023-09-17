//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
// 17 41
// norevert: 19 60 SL75 TP135
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_macd 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string  delimeter_macd_01=""; // --- Индикатор MACD
input int      MACD_FAST_EMA=11; // Период быстрой средней
input int      MACD_SLOW_EMA=27; // Период медленной средней
input int      MACD_PERIOD=0; // Период
input double   MACD_VAL=0; // Максимальное значение для long
input double   MACD_VAL_SHORT=0; // Минимальное значение для short

class pdx_strat_macd:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_macd(ENUM_TIMEFRAMES period);
   ~pdx_strat_macd();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_macd::pdx_strat_macd(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!MACD_PERIOD){
      return;
   }
   
   h = iMACD(_Symbol, period, MACD_FAST_EMA, MACD_SLOW_EMA, MACD_PERIOD, PRICE_CLOSE);;
}
pdx_strat_macd::~pdx_strat_macd(){
   if(!MACD_PERIOD){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_macd::data(){
   if(!MACD_PERIOD){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
   CopyBuffer(h, 1, 0, 1, buf1);
}
bool pdx_strat_macd::skipMe(bool isLong){
   if(!MACD_PERIOD){
      return false;
   }
   
   if(isLong){
      //Гистограмма MACD ниже линии
      if( buf0[0]<MACD_VAL ){}else{
         return true;
      }
   }else{
      //Гистограмма MACD выше линии.
      if( buf0[0]>MACD_VAL_SHORT ){}else{
         return true;
      }
   }
   
   return false;
}