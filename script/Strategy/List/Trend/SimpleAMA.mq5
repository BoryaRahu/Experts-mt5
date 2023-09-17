//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\AdaptiveMovingAverage.mq5";
#include "..\..\..\Indicators\Candle.mq5";
class SimpleAMA {
 private:
   int               signal; // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   SimpleAMA(void);
   ~SimpleAMA(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleAMA::SimpleAMA(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleAMA::~SimpleAMA(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleAMA::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimpleAMA::getSignal(void) {
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
void SimpleAMA::checkSignal(void) {
   AdaptiveMovingAverage ama(PERIOD_H1, 15, 2, 30, 0, PRICE_CLOSE, 10);
   Candle cndl(PERIOD_H1, 10);

   // uptrend when ama below candle & downtrend when ama above candle
   if(cndl.getLow(9) > ama.getValue(9)) {
      if((cndl.getClose(4) > cndl.getClose(9)) && (cndl.getClose(4) > ama.getValue(4))) {
         if(cndl.getClose(0) > cndl.getClose(4) && (cndl.getClose(0) > ama.getValue(0))) {
            setSignal(1);
         }
      }
   } else if(cndl.getLow(9) < ama.getValue(9)) {
      if((cndl.getClose(4) < cndl.getClose(9)) && (cndl.getClose(4) < ama.getValue(4))) {
         if(cndl.getClose(0) < cndl.getClose(4) && (cndl.getClose(0) < ama.getValue(0))) {
            setSignal(2);
         }
      }
   }
}
//+------------------------------------------------------------------+