//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_2ma_hl 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_2ma_hl_01=""; // --- Индикатор MA #1
input TypeOfMA Type_MA=AMA; // Вид скользящей средней
input int      MA_IMA=0; // Период
input int      MA_SHIFT=1; // Смещение
input int      MA_FAST=5; // Период быстрой скользящей для AMA
input int      MA_SLOW=44; // Период медленной скользящей для AMA
input double   GFactor=0.00011; //Уровень наклона не меньше
sinput string delimeter_2ma_hl_02=""; // --- Индикатор MA #2
input TypeOfMA Type_MA2=AMA; // Вид скользящей средней
input int      MA_IMA2=0; // Период
input int      MA_SHIFT2=1; // Смещение
input int      MA_FAST2=5; // Период быстрой скользящей для AMA
input int      MA_SLOW2=44; // Период медленной скользящей для AMA
input double   GFactor2=0.00011; //Уровень наклона не меньше


class pdx_strat_2ma_hl:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_2ma_hl(ENUM_TIMEFRAMES period);
   ~pdx_strat_2ma_hl();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_2ma_hl::pdx_strat_2ma_hl(ENUM_TIMEFRAMES period){
   
   pdxPeriod=period;
   
   switch(Type_MA)
     {
      case AMA:
         h = iAMA(_Symbol,period,MA_IMA, MA_FAST, MA_SLOW, MA_SHIFT, PRICE_HIGH);
         h2 = iAMA(_Symbol,period,MA_IMA, MA_FAST, MA_SLOW, MA_SHIFT, PRICE_LOW);
         break;
      case DEMA:
         h = iDEMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_HIGH);
         h2 = iDEMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_LOW);
         break;
      case FraMA:
         h = iFrAMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_HIGH);
         h2 = iFrAMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_LOW);
         break;
      case MA:
         h = iMA(_Symbol, period, MA_IMA, MA_SHIFT, MODE_EMA, PRICE_HIGH);
         h2 = iMA(_Symbol, period, MA_IMA, MA_SHIFT, MODE_EMA, PRICE_LOW);
         break;
      case TEMA:
         h = iTEMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_HIGH);
         h2 = iTEMA(_Symbol,period,MA_IMA,MA_SHIFT,PRICE_LOW);
         break;
     }
   switch(Type_MA2)
     {
      case AMA:
         h3 = iAMA(_Symbol,period,MA_IMA2, MA_FAST2, MA_SLOW2, MA_SHIFT2, PRICE_HIGH);
         h4 = iAMA(_Symbol,period,MA_IMA2, MA_FAST2, MA_SLOW2, MA_SHIFT2, PRICE_LOW);
         break;
      case DEMA:
         h3 = iDEMA(_Symbol,period,MA_IMA2,MA_SHIFT2,PRICE_HIGH);
         h4 = iDEMA(_Symbol,period,MA_IMA2,MA_SHIFT2,PRICE_LOW);
         break;
      case FraMA:
         h3 = iFrAMA(_Symbol,period,MA_IMA2,MA_SHIFT2,PRICE_HIGH);
         h4 = iFrAMA(_Symbol,period,MA_IMA2,MA_SHIFT2,PRICE_LOW);
         break;
      case MA:
         h3 = iMA(_Symbol, period, MA_IMA2, MA_SHIFT2, MODE_EMA, PRICE_HIGH);
         h4 = iMA(_Symbol, period, MA_IMA2, MA_SHIFT2, MODE_EMA, PRICE_LOW);
         break;
      case TEMA:
         h3 = iTEMA(_Symbol,period,MA_IMA2,MA_SHIFT2,PRICE_HIGH);
         h4 = iTEMA(_Symbol,period,MA_IMA2,MA_SHIFT2,PRICE_LOW);
         break;
     }
}
pdx_strat_2ma_hl::~pdx_strat_2ma_hl(){
   IndicatorRelease(h);
   IndicatorRelease(h2);
   IndicatorRelease(h3);
   IndicatorRelease(h4);
}
void pdx_strat_2ma_hl::data(){
   CopyBuffer(h, 0, 0, 1, buf0);
   CopyBuffer(h2, 0, 0, 1, buf1);
   CopyBuffer(h3, 0, 0, 1, buf2);
   CopyBuffer(h4, 0, 0, 1, buf3);
}
bool pdx_strat_2ma_hl::skipMe(bool isLong){
   if(!MA_IMA){
      return false;
   }
   if(!MA_IMA2){
      return false;
   }

   if(isLong){
      //Если линия 5 SMA High находится выше 20 SMA High
      if( buf0[0]>buf2[0] ){}else{
         return true;
      }
   }else{
      //Если линия 5 SMA High находится ниже 20 SMA Low
      if( buf0[0]<buf3[0] ){}else{
         return true;
      }
   }
   
   return false;
}