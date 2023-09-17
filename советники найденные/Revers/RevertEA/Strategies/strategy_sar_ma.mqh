//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_sar_ma 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string  delimeter_sar_ma_01=""; // --- Индикатор MA для SAR
input TypeOfMA SAR_MA_Type_MA=AMA; // Вид скользящей средней
input int      SAR_MA_IMA=0; // Период
input int      SAR_MA_SHIFT=1; // Смещение
input int      SAR_MA_FAST=5; // Период быстрой скользящей для AMA
input int      SAR_MA_SLOW=44; // Период медленной скользящей для AMA
sinput string  delimeter_sar_ma_02=""; // --- Индикатор SAR #1
input double   SAR_MA_VAL1=0.02; // Шаг изменения цены
input double   SAR_MA_VAL2=0.3; // Максимальный шаг


class pdx_strat_sar_ma:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_sar_ma(ENUM_TIMEFRAMES period);
   ~pdx_strat_sar_ma();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_sar_ma::pdx_strat_sar_ma(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!SAR_MA_IMA){
      return;
   }
   
   switch(SAR_MA_Type_MA)
     {
      case AMA:
         h = iAMA(_Symbol,period,SAR_MA_IMA, SAR_MA_FAST, SAR_MA_SLOW, SAR_MA_SHIFT, PRICE_CLOSE);
         break;
      case DEMA:
         h = iDEMA(_Symbol,period,SAR_MA_IMA,SAR_MA_SHIFT,PRICE_CLOSE);
         break;
      case FraMA:
         h = iFrAMA(_Symbol,period,SAR_MA_IMA,SAR_MA_SHIFT,PRICE_CLOSE);
         break;
      case MA:
         h = iMA(_Symbol, period, SAR_MA_IMA, SAR_MA_SHIFT, MODE_EMA, PRICE_CLOSE);
         break;
      case TEMA:
         h = iTEMA(_Symbol,period,SAR_MA_IMA,SAR_MA_SHIFT,PRICE_CLOSE);
         break;
     }
     
   h2 = iSAR(_Symbol, period, SAR_MA_VAL1, SAR_MA_VAL2);
}
pdx_strat_sar_ma::~pdx_strat_sar_ma(){
   if(!SAR_MA_IMA){
      return;
   }
   IndicatorRelease(h);
   IndicatorRelease(h2);
}
void pdx_strat_sar_ma::data(){
   if(!SAR_MA_IMA){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
   CopyBuffer(h2, 0, 0, 1, buf1);
}
bool pdx_strat_sar_ma::skipMe(bool isLong){
   if(!SAR_MA_IMA){
      return false;
   }
   if(isLong){
      // Точка индикатора Parabolic SAR находится выше линии EMA
      if( buf1[0]>buf0[0] ){}else{
         return true;
      }
   }else{
      // Точка индикатора Parabolic SAR находится ниже линии EMA
      if( buf1[0]<buf0[0] ){}else{
         return true;
      }
   }
   
   return false;
}