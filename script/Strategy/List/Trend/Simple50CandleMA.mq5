//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\MovingAverage.mq5";
class Simple50CandleMA {
 private:
   int signal;                             // 1 = uptrend, 2 = downtrend, 0 = default
   void setSignal(int signal);
   void checkSignal();
 public:
   Simple50CandleMA(void);
   ~Simple50CandleMA(void);
   int getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Simple50CandleMA::Simple50CandleMA(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Simple50CandleMA::~Simple50CandleMA(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Simple50CandleMA::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Simple50CandleMA::getSignal(void) {
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
void Simple50CandleMA::checkSignal(void) {
   MovingAverage ma(PERIOD_H1, 7, MODE_SMA, PRICE_CLOSE, 50); // v2.3 Ganti M15

   double maCurrent = ma.getValue(0);   //the most recent candle
   double maPrevious = ma.getValue(49); //the 50th candle

   if(maCurrent > maPrevious) {
      setSignal(1);
   } else if(maCurrent < maPrevious) {
      setSignal(2);
   } else {
      setSignal(0);
   }
}
//+------------------------------------------------------------------+