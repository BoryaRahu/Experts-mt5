//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_wpr 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string  delimeter_wpr_01=""; // --- Индикатор WPR
input int      WPR_PERIOD=0; // Период
input int      WPR_VAL=-80; // Пересекаемое значение для Long
input int      WPR_VAL_SHORT=-17; // Пересекаемое значение для Short

class pdx_strat_wpr:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_wpr(ENUM_TIMEFRAMES period);
   ~pdx_strat_wpr();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_wpr::pdx_strat_wpr(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!WPR_PERIOD){
      return;
   }
   
   h = iWPR(_Symbol, period, WPR_PERIOD);
}
pdx_strat_wpr::~pdx_strat_wpr(){
   if(!WPR_PERIOD){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_wpr::data(){
   if(!WPR_PERIOD){
      return;
   }
   CopyBuffer(h, 0, 0, 2, buf0);
}
bool pdx_strat_wpr::skipMe(bool isLong){
   if(!WPR_PERIOD){
      return false;
   }
   if(isLong){
      if( buf0[0]<WPR_VAL ){}else{
         return true;
      }
      if( buf0[1]>WPR_VAL ){}else{
         return true;
      }
   }else{
      //ждём подтверждения от Williams — показатель должен пересечь линию -20. 
      if( buf0[0]>WPR_VAL_SHORT ){}else{
         return true;
      }
      if( buf0[1]<WPR_VAL_SHORT ){}else{
         return true;
      }
   }
   
   return false;
}