//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\RelativeIndexVigor.mq5";
class SimpleRelativeIndexVigor {
 private:
   int               signal;                             // 1 = Buy, 2 = Sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   SimpleRelativeIndexVigor(void);
   ~SimpleRelativeIndexVigor(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleRelativeIndexVigor::SimpleRelativeIndexVigor(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleRelativeIndexVigor::~SimpleRelativeIndexVigor(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleRelativeIndexVigor::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimpleRelativeIndexVigor::getSignal(void) {
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
void SimpleRelativeIndexVigor::checkSignal(void){
   RelativeIndexVigor rvi(PERIOD_H1, 10);
   
   double rviLine1 = rvi.getValue(0, 0);
   double rviLine2 = rvi.getValue(0, 1);
   
   double rviSignal = rvi.getValue(1, 0);
   
   //Filter handle error
   if(rviLine1 != -1 && rviLine2 != -1 && rviSignal != -1) {
      //Print("SimpleStochasticOscillator, all handle works");
      if (rviLine2 <= 20.00) {
         if(rviLine1 < rviSignal) {
            setSignal(1);
         }
      } else if (rviLine2 >= 80.00) {
         if(rviLine1 > rviSignal) {
            setSignal(2);
         }
      }
   } else {
      Print("SimpleRelativeIndexVigor, no handle works");
   }
}
//+------------------------------------------------------------------+