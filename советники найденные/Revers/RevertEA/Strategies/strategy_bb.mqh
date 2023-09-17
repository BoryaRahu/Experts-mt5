//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_bb 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string  delimeter_bb_01=""; // --- Индикатор Bolinger Bands
input int      BB_IMA=0; // Период
input int      BB_SHIFT=0; // Смещение
input int      BB_DEVIATION=2; // Количество стандартных отклонений
input int      BB_isBorder=1; // Допустимый отступ от границ в пунктах

class pdx_strat_bb:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_bb(ENUM_TIMEFRAMES period);
   ~pdx_strat_bb();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_bb::pdx_strat_bb(ENUM_TIMEFRAMES period){
   pdxPeriod=period;
   
   if(!BB_IMA){
      return;
   }
   
   ArraySetAsSeries(rates, true);
   
   h = iBands(_Symbol, period, BB_IMA, BB_SHIFT, BB_DEVIATION, PRICE_CLOSE);;
}
pdx_strat_bb::~pdx_strat_bb(){
   if(!BB_IMA){
      return;
   }
   IndicatorRelease(h);
}
void pdx_strat_bb::data(){
   if(!BB_IMA){
      return;
   }
   CopyBuffer(h, 0, 0, 1, buf0);
   CopyBuffer(h, 1, 0, 3, buf1);
   CopyBuffer(h, 2, 0, 3, buf2);
}
bool pdx_strat_bb::skipMe(bool isLong){
   if(!BB_IMA){
      return false;
   }
   if(!getRates1(3, pdxPeriod)){
      return true;
   }

   if(isLong){
      double middleMe=(buf0[0]-buf2[0])/2;
      
      //если текущий бар выше скользящей средней - пропускаем
      if( rates[0].close>=buf0[0] ){
         return true;
      }
      //если предыдущий бар падает - пропускаем
      if( rates[1].close<=rates[1].open ){
         return true;
      }
      //если предпредыдущий бар не за нижней границей болинджера - пропускаем
      if( rates[2].low-BB_isBorder*myPoint>buf2[2] ){
         return true;
      }
      //если предпредыдущий бар закрыт не выше нижней границы болинджера - пропускаем
      if( rates[2].close<buf2[2] ){
         return true;
      }
   }else{
      double middleMe=(buf1[0]-buf0[0])/2;
      
      //если текущий бар нмже скользящей средней - пропускаем
      if( rates[0].close<=buf0[0] ){
         return true;
      }
      if( rates[0].close>buf0[0]+middleMe+middleMe/2 ){
         return true;
      }
      //если предыдущий бар растет - пропускаем
      if( rates[1].close>=rates[1].open ){
         return true;
      }
      //если предпредыдущий бар не за верхней границей болинджера - пропускаем
      if( rates[2].high+BB_isBorder*myPoint<buf1[2] ){
         return true;
      }
      //если предпредыдущий бар закрыт не нмже верхней границы болинджера - пропускаем
      if( rates[2].close>buf1[2] ){
         return true;
      }
   }
   
   return false;
}