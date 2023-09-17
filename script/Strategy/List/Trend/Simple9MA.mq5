//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\MovingAverage.mq5";
class Simple9MA {
 private:
   int               signal; // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   Simple9MA();       //set default value
   ~Simple9MA();
   int               getSignal();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Simple9MA::Simple9MA(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Simple9MA::~Simple9MA(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Simple9MA::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Simple9MA::getSignal(void) {
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
void Simple9MA::checkSignal(void) {
   MovingAverage ma07(PERIOD_H1, 7, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma20(PERIOD_H1, 20, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma25(PERIOD_H1, 25, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma30(PERIOD_H1, 30, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma35(PERIOD_H1, 35, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma40(PERIOD_H1, 40, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma45(PERIOD_H1, 45, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma50(PERIOD_H1, 50, MODE_EMA, PRICE_CLOSE, 3);
   MovingAverage ma55(PERIOD_H1, 55, MODE_EMA, PRICE_CLOSE, 3);

   if((ma07.getValue(0) < ma20.getValue(0)) && (ma20.getValue(0) < ma25.getValue(0)) && (ma25.getValue(0) < ma30.getValue(0)) && (ma30.getValue(0) < ma35.getValue(0)) && (ma35.getValue(0) < ma40.getValue(0)) && (ma40.getValue(0) < ma45.getValue(0)) && (ma45.getValue(0) < ma50.getValue(0)) && (ma50.getValue(0) < ma55.getValue(0))) {
      setSignal(2);
   }
   if((ma07.getValue(0) > ma20.getValue(0)) && (ma20.getValue(0) > ma25.getValue(0)) && (ma25.getValue(0) > ma30.getValue(0)) && (ma30.getValue(0) > ma35.getValue(0)) && (ma35.getValue(0) > ma40.getValue(0)) && (ma40.getValue(0) > ma45.getValue(0)) && (ma45.getValue(0) > ma50.getValue(0)) && (ma50.getValue(0) > ma55.getValue(0))) {
      setSignal(1);
   }

}
//+------------------------------------------------------------------+