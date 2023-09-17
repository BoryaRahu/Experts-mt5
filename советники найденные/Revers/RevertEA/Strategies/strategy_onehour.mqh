//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_onehour 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string  delimeter_onehour_01=""; // --- Время входа
input int      EnterHour=24; //Входить в, час
input int      EnterMin=0; //Входить в, мин
input int      EnterHour2=24; //Входить в, час (#2)


class pdx_strat_onehour:public pdx_strat_base{
protected:
   MqlDateTime curT;
public:
   pdx_strat_onehour();
   ~pdx_strat_onehour();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_onehour::pdx_strat_onehour(){
}
pdx_strat_onehour::~pdx_strat_onehour(){
}
void pdx_strat_onehour::data(){
}
bool pdx_strat_onehour::skipMe(bool isLong){
   TimeCurrent(curT);
   
   if( curT.hour!=EnterHour && curT.hour!=EnterHour2 ){
      return true;
   }
   if(EnterMin>0 && curT.min!=EnterMin){
      return true;
   }
   
   return false;
}