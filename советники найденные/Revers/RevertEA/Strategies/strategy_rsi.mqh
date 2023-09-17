//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_rsi 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_rsi_01=""; // --- Индикатор RSI
input TypeOfRSI Type_RSI=RSI1; // Тип проверки
input int      RSI_PERIOD=0; // Период
input int      rsiValMax=78;
input int      rsiValMin=0;

class pdx_strat_rsi:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_rsi(ENUM_TIMEFRAMES period);
   ~pdx_strat_rsi();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_rsi::pdx_strat_rsi(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!RSI_PERIOD){
      return;
   }
   
   h = iRSI(_Symbol,period,RSI_PERIOD,PRICE_CLOSE);
}
pdx_strat_rsi::~pdx_strat_rsi(){
   if(!RSI_PERIOD){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_rsi::data(){
   if(!RSI_PERIOD){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
}
bool pdx_strat_rsi::skipMe(bool isLong){
   if(!RSI_PERIOD){
      return false;
   }
   switch(Type_RSI){
      case RSI1:
         if(isLong){
            if( rsiValMax>0 && buf0[0]>rsiValMax ){
               return true;
            }
         }else{
            if( rsiValMin>0 && buf0[0]<rsiValMin ){
               return true;
            }
         }
         break;
      case RSI2:
         if(isLong){
            if( rsiValMax>0 && buf0[0]>rsiValMax ){}else{
               return true;
            }
         }else{
            if( rsiValMin>0 && buf0[0]<rsiValMin ){}else{
               return true;
            }
         }
         break;
      case RSI3:
         if(isLong){
            if( rsiValMin>0 && buf0[0]<rsiValMin ){}else{
               return true;
            }
         }else{
            if( rsiValMax>0 && buf0[0]>rsiValMax ){}else{
               return true;
            }
         }
         break;
   }
   
   return false;
}