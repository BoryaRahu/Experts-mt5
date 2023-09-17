//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#property description "three ekrana eldera";
#define mystrateges_elder 1

#include "strategy_ma.mqh"

sinput string delimeter_elder_01=""; // --- Индикатор MA #2
input TypeOfMA Type_MA2=AMA; // Вид скользящей средней
input int      MA_IMA2=0; // Период
input int      MA_SHIFT2=1; // Смещение
input int      MA_FAST2=5; // Период быстрой скользящей для AMA
input int      MA_SLOW2=44; // Период медленной скользящей для AMA
input double   GFactor2=0.00011; //Уровень наклона не меньше
input    ENUM_TIMEFRAMES   MA_Timeframe2=PERIOD_H4;

sinput string delimeter_elder_02=""; // --- Индикатор MA #3
input TypeOfMA Type_MA3=AMA; // Вид скользящей средней
input int      MA_IMA3=0; // Период
input int      MA_SHIFT3=1; // Смещение
input int      MA_FAST3=5; // Период быстрой скользящей для AMA
input int      MA_SLOW3=44; // Период медленной скользящей для AMA
input double   GFactor3=0.00011; //Уровень наклона не меньше
input    ENUM_TIMEFRAMES   MA_Timeframe3=PERIOD_D1;


class pdx_strat_elder:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_elder(ENUM_TIMEFRAMES period, ENUM_TIMEFRAMES period2, ENUM_TIMEFRAMES period3);
   ~pdx_strat_elder();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_elder::pdx_strat_elder(ENUM_TIMEFRAMES period, ENUM_TIMEFRAMES period2, ENUM_TIMEFRAMES period3){
   pdxPeriod=period;
   
   if(!MA_IMA){
      return;
   }
   if(!MA_IMA2){
      return;
   }
   if(!MA_IMA3){
      return;
   }
   
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(rates2, true);
   ArraySetAsSeries(rates3, true);

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
   switch(Type_MA2)
     {
      case AMA:
         h2 = iAMA(_Symbol,period2,MA_IMA2, MA_FAST2, MA_SLOW2, MA_SHIFT2, PRICE_CLOSE);
         break;
      case DEMA:
         h2 = iDEMA(_Symbol,period2,MA_IMA2,MA_SHIFT2,PRICE_CLOSE);
         break;
      case FraMA:
         h2 = iFrAMA(_Symbol,period2,MA_IMA2,MA_SHIFT2,PRICE_CLOSE);
         break;
      case MA:
         h2 = iMA(_Symbol, period2, MA_IMA2, MA_SHIFT2, MODE_EMA, PRICE_CLOSE);
         break;
      case TEMA:
         h2 = iTEMA(_Symbol,period2,MA_IMA2,MA_SHIFT2,PRICE_CLOSE);
         break;
     }
   switch(Type_MA3)
     {
      case AMA:
         h3 = iAMA(_Symbol,period3,MA_IMA3, MA_FAST3, MA_SLOW3, MA_SHIFT3, PRICE_CLOSE);
         break;
      case DEMA:
         h3 = iDEMA(_Symbol,period3,MA_IMA3,MA_SHIFT3,PRICE_CLOSE);
         break;
      case FraMA:
         h3 = iFrAMA(_Symbol,period3,MA_IMA3,MA_SHIFT3,PRICE_CLOSE);
         break;
      case MA:
         h3 = iMA(_Symbol, period3, MA_IMA3, MA_SHIFT3, MODE_EMA, PRICE_CLOSE);
         break;
      case TEMA:
         h3 = iTEMA(_Symbol,period3,MA_IMA3,MA_SHIFT3,PRICE_CLOSE);
         break;
     }
}
pdx_strat_elder::~pdx_strat_elder(){
   if(!MA_IMA){
      return;
   }
   if(!MA_IMA2){
      return;
   }
   if(!MA_IMA3){
      return;
   }
   IndicatorRelease(h);
   IndicatorRelease(h2);
   IndicatorRelease(h3);
}
void pdx_strat_elder::data(){
   if(!MA_IMA){
      return;
   }
   if(!MA_IMA2){
      return;
   }
   if(!MA_IMA3){
      return;
   }
   CopyBuffer(h, 0, 0, 2, buf0);
   CopyBuffer(h2, 0, 0, 2, buf1);
   CopyBuffer(h3, 0, 0, 2, buf2);
}
bool pdx_strat_elder::skipMe(bool isLong){
   if(!MA_IMA){
      return false;
   }
   if(!MA_IMA2){
      return false;
   }
   if(!MA_IMA3){
      return false;
   }
   
   if(!getRates1(2, pdxPeriod)){
      return true;
   }
   if(!getRates2(2, MA_Timeframe2)){
      return true;
   }
   if(!getRates2(3, MA_Timeframe3)){
      return true;
   }
   
   if(isLong){
      if(rates[1].open<buf0[0] && rates[1].close>buf0[0]){}else{
         return true;
      }
      if(buf0[1]>buf0[0] && buf0[1]-buf0[0]>GFactor){}else{
         return true;
      }
      if(rates2[1].open<buf1[0] && rates2[1].close>buf1[0]){}else{
         return true;
      }
      if(buf1[1]>buf1[0] && buf1[1]-buf1[0]>GFactor2){}else{
         return true;
      }
      if(rates3[1].open<buf2[0] && rates3[1].close>buf2[0]){}else{
         return true;
      }
      if(buf2[1]>buf2[0] && buf2[1]-buf2[0]>GFactor3){}else{
         return true;
      }
   }else{
      if(rates[1].open>buf0[0] && rates[1].close<buf0[0]){}else{
         return true;
      }
      if(buf0[0]>buf0[1] && buf0[0]-buf0[1]>GFactor){}else{
         return true;
      }
      if(rates2[1].open>buf1[0] && rates2[1].close<buf1[0]){}else{
         return true;
      }
      if(buf1[0]>buf1[1] && buf1[0]-buf1[1]>GFactor2){}else{
         return true;
      }
      if(rates3[1].open>buf2[0] && rates3[1].close<buf2[0]){}else{
         return true;
      }
      if(buf2[0]>buf2[1] && buf2[0]-buf2[1]>GFactor3){}else{
         return true;
      }
   }
   
   return false;
}