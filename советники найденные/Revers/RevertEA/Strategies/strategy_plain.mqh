//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_plain 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

class pdx_strat_plain:public pdx_strat_base{
protected:
public:
   pdx_strat_plain(ENUM_TIMEFRAMES period=PERIOD_H1);
   ~pdx_strat_plain();
   bool skipMe(bool isLong);
   void data();
};
pdx_strat_plain::pdx_strat_plain(ENUM_TIMEFRAMES period=PERIOD_H1){
}
pdx_strat_plain::~pdx_strat_plain(){
}
void pdx_strat_plain::data(){
}
bool pdx_strat_plain::skipMe(bool isLong){
   return false;
}