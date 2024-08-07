//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

enum TypeOfFilling //Filling Mode
  {
   FOK,//ORDER_FILLING_FOK
   RETURN,// ORDER_FILLING_RETURN
   IOC,//ORDER_FILLING_IOC
  }; 

enum TypeOfMA //Type of MA
  {
   AMA,//Adaptive Moving Average
   DEMA,// Double Exponential Moving Average
   FraMA,//Fractal Adaptive Moving Average 
   MA,//Moving Average 
   TEMA,//Triple Exponential Moving Average
  }; 
enum TypeOfClose //Type of Close Position
  {
   none,//Ничего не делать
   reverse,//Реверсировка (открыть в противоположном направлении)
   martingale,//Мартингейл (открыть в том же направлении)
  }; 
enum TypeOfStop //Type of Stop Loss
  {
   point,//В пунктах
   percent,//В процентах от цены
   atr,//В процентах от ATR
   zero,//Не ставить стоп
   low1,//По low/high первого бара
   low2,//По low/high второго бара
   buffer0_0,//По значению первого буфера индикатора 1
   buffer1_3,//По значению второго (long) и четвертого (short) буфера индикатора 1
   buffer1_2,//По значению второго (long) и третьего (short) буфера индикатора 1
  }; 
enum TypeOfTake //Type of Take
  {
   point_take,//В пунктах
   multiplier,//Множитель к стопу
  }; 
enum TypeOfAdd //Type of Add Position
  {
   geomet,//В геометрической прогрессии
   arifmet,//В арифметической прогрессии
   even,//Через 1 сделку
   even2,//Через 2 сделки
   even3,//Через 3 сделки
  }; 
enum TypeOfRSI //Type of RSI
  {
   RSI1,//Если curVal <= rsiValMax, то Long
   RSI2,//Если curVal > rsiValMax, то Long
   RSI3,//Если curVal > rsiValMax, то Short
  };
enum TypeOfCCI //Type of CCI
  {
   CCI1,//Если curVal > CCI_FROM_MAX, то Long
   CCI2,//Если curVal > CCI_FROM_MAX, то Short
  };
enum TypeOfMomentum //Type of Momentum
  {
   Momentum1,//Если curVal > MM_VOL_MAX, то Long
   Momentum2,//Если curVal > MM_VOL_MAX, то Short
  };


#include "strategy_base.mqh"

class pdx_strat_base{
protected:
   int h;
   int h2;
   int h3;
   int h4;
   double buf0[];
   double buf1[];
   double buf2[];
   double buf3[];
   MqlRates rates[];
   MqlRates rates2[];
   MqlRates rates3[];
public:
   pdx_strat_base(){}
   ~pdx_strat_base(){}
   virtual bool skipMe(bool isLong){ return true; }
   virtual void data(){}
   bool getRates1(int count, ENUM_TIMEFRAMES period);
   bool getRates2(int count, ENUM_TIMEFRAMES period);
   bool getRates3(int count, ENUM_TIMEFRAMES period);
   double getBuf0(int ind);
   double getBuf1(int ind);
   double getBuf2(int ind);
   double getBuf3(int ind);
};
double pdx_strat_base::getBuf0(int ind){
   return (double) buf0[ind];
}
double pdx_strat_base::getBuf1(int ind){
   return (double) buf1[ind];
}
double pdx_strat_base::getBuf2(int ind){
   return (double) buf2[ind];
}
double pdx_strat_base::getBuf3(int ind){
   return (double) buf3[ind];
}
bool pdx_strat_base::getRates1(int count, ENUM_TIMEFRAMES period){
   if(CopyRates(_Symbol, period, 0, count, rates)!=count){
      Alert("Not enough bars ("+(string) count+")!");
      return false;
   }
   return true;
}
bool pdx_strat_base::getRates2(int count, ENUM_TIMEFRAMES period){
   if(CopyRates(_Symbol, period, 0, count, rates2)!=count){
      Alert("Not enough bars ("+(string) count+")!");
      return false;
   }
   return true;
}
bool pdx_strat_base::getRates3(int count, ENUM_TIMEFRAMES period){
   if(CopyRates(_Symbol, period, 0, count, rates3)!=count){
      Alert("Not enough bars ("+(string) count+")!");
      return false;
   }
   return true;
}

pdx_strat_base* pdxStrats[];

