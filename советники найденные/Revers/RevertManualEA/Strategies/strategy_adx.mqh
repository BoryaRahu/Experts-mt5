//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_adx 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_adx_01=""; // --- Индикатор ADX
input int      ADX_PERIOD=0; //Период
input int      ADX_VOL_MIN=0; //Мин. сила ADX (15-25)
input int      ADX_VOL_MAX=39; //Макс. сила ADX (33-40)
input bool     ADX_only_Minus=true; //Проверять ADX только при DI+ < DI-


class pdx_strat_adx:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_adx(ENUM_TIMEFRAMES period);
   ~pdx_strat_adx();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_adx::pdx_strat_adx(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   if(!ADX_PERIOD){
      return;
   }
   
   h = iADX(_Symbol, period, ADX_PERIOD);
}
pdx_strat_adx::~pdx_strat_adx(){
   if(!ADX_PERIOD){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_adx::data(){
   if(!ADX_PERIOD){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
   CopyBuffer(h, 1, 0, 1, buf1);
   CopyBuffer(h, 2, 0, 1, buf2);
}
bool pdx_strat_adx::skipMe(bool isLong){
   if(!ADX_PERIOD){
      return false;
   }
   
   if(ADX_only_Minus){
      if( ADX_VOL_MAX>0 && buf0[0]>ADX_VOL_MAX && buf1[0]<buf2[0] ){
         return true;
      }
      return false;
   }
   
   if( ADX_VOL_MIN>0 && buf0[0]<ADX_VOL_MIN ){
      return true;
   }
   if( ADX_VOL_MAX>0 && buf0[0]>ADX_VOL_MAX ){
      return true;
   }
   if(isLong){
      if(buf1[0]<buf2[0]){
         return true;
      }
   }else{
      if(buf1[0]>buf2[0]){
         return true;
      }
   }
   
   return false;
}