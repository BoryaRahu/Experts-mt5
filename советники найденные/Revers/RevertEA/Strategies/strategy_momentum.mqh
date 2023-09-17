//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_momentum 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string  delimeter_momentum_01=""; // --- Индикатор Momentum
input TypeOfMomentum Type_Momentum=Momentum1; // Тип проверки
input int      MM_PERIOD=0; // Период
input int      MM_VOL_MAX=100; // Минимальное значение для long
input int      MM_VOL_MIN=100; // Максимальное значение для short

class pdx_strat_momentum:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_momentum(ENUM_TIMEFRAMES period);
   ~pdx_strat_momentum();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_momentum::pdx_strat_momentum(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!MM_PERIOD){
      return;
   }
   
   h = iMomentum(_Symbol, period, MM_PERIOD, PRICE_CLOSE);
}
pdx_strat_momentum::~pdx_strat_momentum(){
   if(!MM_PERIOD){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_momentum::data(){
   if(!MM_PERIOD){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
}
bool pdx_strat_momentum::skipMe(bool isLong){
   if(!MM_PERIOD){
      return false;
   }
   switch(Type_Momentum){
      case Momentum1:
         if(isLong){
            if(  buf0[0]>MM_VOL_MAX){}else{
               return true;
            }
         }else{
            if(  buf0[0]<MM_VOL_MIN){}else{
               return true;
            }
         }
         break;
      case Momentum2:
         if(isLong){
            if(  buf0[0]<MM_VOL_MIN){}else{
               return true;
            }
         }else{
            if(  buf0[0]>MM_VOL_MAX){}else{
               return true;
            }
         }
         break;
   }
   
   return false;
}