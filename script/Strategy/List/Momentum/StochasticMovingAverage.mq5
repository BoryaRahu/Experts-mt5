//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\StochasticOscillator.mq5";
#include "..\..\..\Indicators\MovingAverage.mq5";
#include "SimpleStochasticOscillator.mq5";

class StochasticMovingAverage {
 private:
   int               signal; // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   StochasticMovingAverage(); //set default value
   ~StochasticMovingAverage();
   int               getSignal();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StochasticMovingAverage::StochasticMovingAverage(void) {
   //Print("StochasticMovingAverage, constructor");
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StochasticMovingAverage::~StochasticMovingAverage(void) {
   //Print("StochasticMovingAverage, destructor");
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StochasticMovingAverage::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int StochasticMovingAverage::getSignal(void) {
   if(signal == 1 || signal == 2) {
      return signal;
   } else if(signal == 0) {
      //Print("No Signal found");
      return -1;
   } else {
      //Print("Invalid Signal");
      return -1;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StochasticMovingAverage::checkSignal(void) {
   //Candle candle(PERIOD_H1);
   SimpleStochasticOscillator sso;
   MovingAverage ma(PERIOD_H1, 100, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage maLow(PERIOD_H1, 1, MODE_EMA, PRICE_LOW, 3);
   MovingAverage maHigh(PERIOD_H1, 1, MODE_EMA, PRICE_HIGH, 3);
   
   double range;
   
   //double high = candle.getHigh(1);
   //double low = candle.getLow(1);
   if(sso.getSignal() == 1) {
      double upperRange = ma.getValue(0) + 0.0001;
      double lowerRange = ma.getValue(0) - 0.0001;
      if(maLow.getValue(0) < upperRange && maLow.getValue(0) > lowerRange) {
         setSignal(1);
      }
   } else if(sso.getSignal() == 2) {
      double upperRange = ma.getValue(0) + 0.0001;
      double lowerRange = ma.getValue(0) - 0.0001;
      if(maHigh.getValue(0) < upperRange && maLow.getValue(0) > lowerRange) {
         setSignal(2);
      }
   }
}
//+------------------------------------------------------------------+