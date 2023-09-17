//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\MovingAverage.mq5";
class MovingAverageCrossover {
 private:
   int               signal; // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   MovingAverageCrossover(void);
   ~MovingAverageCrossover(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageCrossover::MovingAverageCrossover(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageCrossover::~MovingAverageCrossover(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovingAverageCrossover::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MovingAverageCrossover::getSignal(void) {
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
void MovingAverageCrossover::checkSignal(void) {
   MovingAverage ma10(PERIOD_H1, 10, MODE_EMA, PRICE_CLOSE, 10);
   MovingAverage ma20(PERIOD_H1, 20, MODE_EMA, PRICE_CLOSE, 10);

   if(ma10.getValue(9) < ma20.getValue(9)) {
      if(ma10.getValue(4) < ma20.getValue(4)) {
         if(ma10.getValue(1) <= ma20.getValue(1)) {
            if(ma10.getValue(0) > ma20.getValue(0)) {
               setSignal(1); //Buy when MA cross above
            }
         }
      }
   } else if(ma10.getValue(9) > ma20.getValue(9)) {
      if(ma10.getValue(4) > ma20.getValue(4)) {
         if(ma10.getValue(1) >= ma20.getValue(1)) {
            if(ma10.getValue(0) < ma20.getValue(0)) {
               setSignal(2); //Sell when MA cross below
            }
         }
      }
   }
}
//+------------------------------------------------------------------+