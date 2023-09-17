//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_cci 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_cci_01=""; // --- Индикатор CCI
input TypeOfCCI Type_CCI=CCI1; // Тип проверки
input    ENUM_TIMEFRAMES   CCI_Timeframe=PERIOD_M15; // Таймфрейм
input int      CCI_VAL=0; // Период
input int      CCI_FROM_MAX=143;
input int      CCI_FROM_MIN=-100;


class pdx_strat_cci:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_cci(ENUM_TIMEFRAMES period);
   ~pdx_strat_cci();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_cci::pdx_strat_cci(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!CCI_VAL){
      return;
   }
   
   h = iCCI(_Symbol, period, CCI_VAL, PRICE_CLOSE);
}
pdx_strat_cci::~pdx_strat_cci(){
   if(!CCI_VAL){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_cci::data(){
   if(!CCI_VAL){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
}
bool pdx_strat_cci::skipMe(bool isLong){
   if(!CCI_VAL){
      return false;
   }
   
   switch(Type_CCI){
      case CCI1:
         if(isLong){
            // значение индикатора CCI выше 100
            if( buf0[0]>CCI_FROM_MAX ){}else{
               return true;
            }
         }else{
            // значение индикатора CCI ниже 100
            if( buf0[0]<CCI_FROM_MIN ){}else{
               return true;
            }
         }
         break;
      case CCI2:
         if(isLong){
            if( buf0[0]<CCI_FROM_MIN ){}else{
               return true;
            }
         }else{
            if( buf0[0]>CCI_FROM_MAX ){}else{
               return true;
            }
         }
         break;
   }
   
   return false;
}