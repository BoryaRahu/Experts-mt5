//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\ParabolicSAR.mq5";
#include "..\..\..\Indicators\Candle.mq5";
class SimplePSAR {
 private:
   int               signal; // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   SimplePSAR(void);
   ~SimplePSAR(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimplePSAR::SimplePSAR(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimplePSAR::~SimplePSAR(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimplePSAR::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimplePSAR::getSignal(void) {
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
void SimplePSAR::checkSignal(void) {
   ParabolicSAR psar(PERIOD_H1, 0.02, 0.2);
   Candle candle(PERIOD_H1, 10);

   if (psar.getValue(0) < candle.getClose(0)) {
      setSignal(1);
   } else{
      setSignal(2);
   }
}
//+------------------------------------------------------------------+