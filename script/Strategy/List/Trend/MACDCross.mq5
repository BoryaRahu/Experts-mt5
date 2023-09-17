//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\MovingAverageConvergenceDivergence.mq5";
class MACDCross {
 private:
   int               signal;                             // 1 = Uptrend, 2 = not Downtrend, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   MACDCross(void);
   ~MACDCross(void);
   int               getSignal();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACDCross::MACDCross(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACDCross::~MACDCross(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MACDCross::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MACDCross::getSignal(void) {
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
void MACDCross::checkSignal(void) {
   MovingAverageConvergenceDivergence macd(PERIOD_H1, 12, 26, 9, PRICE_CLOSE);

   double macdLine1 = macd.getValue(0,0);
   double macdLine2 = macd.getValue(0,1);
   double signalLine1 = macd.getValue(1, 0);
   double signalLine2 = macd.getValue(1, 1);

   if(signalLine1 < 0) {
      if(macdLine2 > signalLine2) {
         if(macdLine1 < signalLine1) {
            setSignal(1);
         }
      }
   } else if(signalLine1 > 0) {
      if(macdLine2 < signalLine2) {
         if(macdLine1 > signalLine1) {
            setSignal(2);
         }
      }
   } 
}
//+------------------------------------------------------------------+