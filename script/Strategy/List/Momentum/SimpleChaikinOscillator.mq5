//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\ChaikinOscillator.mq5";
class SimpleChaikinOscillator {
 private:
   int               signal; // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   SimpleChaikinOscillator(void);
   ~SimpleChaikinOscillator(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleChaikinOscillator::SimpleChaikinOscillator(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleChaikinOscillator::~SimpleChaikinOscillator(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleChaikinOscillator::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimpleChaikinOscillator::getSignal(void) {
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
void SimpleChaikinOscillator::checkSignal(void) {
   ChaikinOscillator co(PERIOD_H1, 3, 10, MODE_EMA, VOLUME_TICK);

   if(co.getValue(1) < 0) {
      if(co.getValue(0) > 0) {
         setSignal(1);
      }
   } else if(co.getValue(1) > 0) {
      if(co.getValue(0) < 0) {
         setSignal(2);
      }
   }
}
//+------------------------------------------------------------------+