//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_candle 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_candle_01=""; // --- Параметры свечи
input double   tickVol=0; // Разница в тиковых объемах
input double   bigVol=0;
input double   highVal=0;
input double   maxPros=0;
input double   maxProsMax=0;
input double   maxCons=0;
input uchar    skipIfNCandleUP=0;
input int      skipIfCloseBOpen=0; //Пропустить,если цена закрытия больше открытия у этого бара
input int      skipIfOpenBClose=0; //Пропустить,если цена открытия больше закрытия у этого бара
input double   ConsVsProsMin=0;
input double   ConsVsProsMax=0;
input int      CConsVsCProsMin=0;
input double   imaMaxMin=0;
input double   imaMaxMax=0;

class pdx_strat_candle:public pdx_strat_base{
protected:
   ENUM_TIMEFRAMES pdxPeriod;
public:
   pdx_strat_candle(ENUM_TIMEFRAMES period=PERIOD_D1);
   ~pdx_strat_candle();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_candle::pdx_strat_candle(ENUM_TIMEFRAMES period=PERIOD_D1){
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(rates2, true);
   pdxPeriod=period;
   
}
pdx_strat_candle::~pdx_strat_candle(){
}
void pdx_strat_candle::data(){
}
bool pdx_strat_candle::skipMe(bool isLong){
   if(!getRates1(21, _Period)){
      return true;
   }
   if(!getRates2(1, pdxPeriod)){
      return true;
   }

   if(isLong){
   
      if( ConsVsProsMin>0 || ConsVsProsMax>0 || CConsVsCProsMin>0 || imaMaxMin>0 || imaMaxMax>0 ){
            double imaPros=0;
            double imaCons=0;
            int imaCPros=0;
            int imaCCons=0;
            double imaMax=0;
            long tickPros=0;
            long tickCons=0;
            double imaMax2=0;
            int bigHigh=0;
            int bigLow=0;
            for(int k=1; k<20; k++){
               if( rates[k].close > rates[k].open ){
                  imaPros+=rates[k].close - rates[k].open;
                  imaCPros++;
                  if( imaMax2==0 || imaMax2< rates[k].close-rates[k].open ){
                     imaMax2=rates[k].close-rates[k].open;
                  }
                  tickPros+=rates[k].tick_volume;
                  if( rates[k].high> (rates[k].close-rates[k].open)*2 ){
                     bigHigh++;
                  }
               }else{
                  imaCons+=rates[k].open - rates[k].close;
                  imaCCons++;
                  if( imaMax==0 || imaMax<rates[k].open - rates[k].close ){
                     imaMax=rates[k].open - rates[k].close;
                  }
                  tickCons+=rates[k].tick_volume;
                  if( rates[k].low> (rates[k].open - rates[k].close)*2 ){
                     bigLow++;
                  }
               }
            }
            if( ConsVsProsMin>0 && imaCons > imaPros*ConsVsProsMin ){
               if(ConsVsProsMax>0){
                  if(imaCons < imaPros*ConsVsProsMax){
                     return true;
                  }
               }else{
                  return true;
               }
            }
            if(CConsVsCProsMin>0 && imaCCons>imaCPros*CConsVsCProsMin ){
               return true;
            }
            if( imaMaxMin>0 && imaMax>20*imaMaxMin ){
               if(imaMaxMax>0){
                  if(imaMax<20*imaMaxMax){
                     return true;
                  }
               }else{
                  return true;
               }
            }
      }
      if(skipIfCloseBOpen>0 && rates[skipIfCloseBOpen].close > rates[skipIfCloseBOpen].open){
         return true;
      }
      if(skipIfOpenBClose>0 && rates[skipIfOpenBClose].close < rates[skipIfOpenBClose].open){
         return true;
      }
      if(bigVol>0 && rates[3].close > rates[3].open && (rates[3].close - rates[3].open)<(rates[2].close - rates[2].open)*bigVol ){
         return true;
      }
      if( tickVol>0 && rates[1].tick_volume > rates[2].tick_volume*tickVol ){
         return true;
      }
      if(highVal>0){
         int skipHigh=1;
         for( int k=1; k<19; k++ ){
            if( rates[k].high>rates[0].high+symStop*highVal ){
               skipHigh=0;
               break;
            }
         }
         if(skipHigh){
            return true;
         }
      }
      if(skipIfNCandleUP>0){
         bool skipMe=true;
         for( int k=1; k<=skipIfNCandleUP; k++ ){
            if(rates[k].close < rates[k].open){
               skipMe=false;
               break;
            }
         }
         if(skipMe){
            return true;
         }
      }
      
      double perc=NormalizeDouble(((rates2[0].close-rates2[0].open)/rates2[0].open)*100, 2);
      if(perc>0){
         if(maxPros>0 && perc>maxPros){
            if(maxProsMax>0){
               if(perc<maxProsMax){
                  return true;
               }
            }else{
               return true;
            }
         }
      }else{
         if(maxCons>0 && perc>-maxCons){
            return true;
         }
      }
      
      
   }else{
   
   }
   
   return false;
}