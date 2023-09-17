//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_ma 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_ma_01=""; // --- Индикатор MA #1
input TypeOfMA Type_MA=AMA; // Вид скользящей средней
input int      MA_IMA=0; // Период
input int      MA_SHIFT=1; // Смещение
input int      MA_FAST=5; // Период быстрой скользящей для AMA
input int      MA_SLOW=44; // Период медленной скользящей для AMA
input double   GFactor=0.00011; //Уровень наклона не меньше


class pdx_strat_ama:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_ama(ENUM_TIMEFRAMES period);
   ~pdx_strat_ama();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_ama::pdx_strat_ama(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!MA_IMA){
      return;
   }
   
   ArraySetAsSeries(rates, true);
   
   switch(Type_MA)
     {
      case AMA:
         h = iAMA(_Symbol,period,MA_IMA, MA_FAST, MA_SLOW, MA_SHIFT, PRICE_CLOSE);
         break;
      case DEMA:
         h = iDEMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_CLOSE);
         break;
      case FraMA:
         h = iFrAMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_CLOSE);
         break;
      case MA:
         h = iMA(_Symbol, period, MA_IMA, MA_SHIFT, MODE_EMA, PRICE_CLOSE);
         break;
      case TEMA:
         h = iTEMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_CLOSE);
         break;
     }
}
pdx_strat_ama::~pdx_strat_ama(){
   if(!MA_IMA){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_ama::data(){
   if(!MA_IMA){
      return;
   }
   CopyBuffer(h, 0, 0, 2, buf0);
}
bool pdx_strat_ama::skipMe(bool isLong){
   if(!MA_IMA){
      return false;
   }
   
   if(!getRates1(2, pdxPeriod)){
      return true;
   }

   if(isLong){
      if(rates[1].open<buf0[0] && rates[1].close>buf0[0]){}else{
         return true;
      }
      if(buf0[1]>buf0[0]){}else{
         return true;
      }
      if(GFactor>0){
         if( buf0[1]-buf0[0]>GFactor){}else{
            return true;
         }
      }
   }else{
      if(rates[1].open>buf0[0] && rates[1].close<buf0[0]){}else{
         return true;
      }
      if(buf0[0]>buf0[1]){}else{
         return true;
      }
      if(GFactor>0){
         if(buf0[0]>buf0[1] && buf0[0]-buf0[1]>GFactor){}else{
            return true;
         }
      }
   }
   
   return false;
}