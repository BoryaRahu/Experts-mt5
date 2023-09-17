//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\StochasticOscillator.mq5";
class SimpleStochasticOscillator {
 private:
   int               signal;                             // 1 = buy, 2 = sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   SimpleStochasticOscillator();       //set default value
   ~SimpleStochasticOscillator();
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleStochasticOscillator::SimpleStochasticOscillator(void) {
   //Print("SimpleStochasticOscillator, constructor");
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleStochasticOscillator::~SimpleStochasticOscillator(void) {
   //Print("SimpleStochasticOscillator, destructor");
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleStochasticOscillator::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimpleStochasticOscillator::getSignal(void) {
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
void SimpleStochasticOscillator::checkSignal(void) {

   StochasticOscillator stc(PERIOD_H1, 5, 3, 3, MODE_SMA, STO_CLOSECLOSE, 5);

//   double stochasticLine1 = stc.getValue(0, 0); //1st candle
//   double stochasticLine2 = stc.getValue(0, 1); //2nd candle
//
//   double signalLine = stc.getValue(1, 0);     //1st candle

   //update v8.0
   if(stc.getValue(0, 4) < stc.getValue(1, 4)) {
      if(stc.getValue(0, 2) < stc.getValue(1, 2)) {
         if(stc.getValue(0, 1) <= stc.getValue(1, 1)) {
            if((stc.getValue(0, 1) <= 20.00) || (stc.getValue(1, 1) <= 20.00)) {
               if(stc.getValue(0, 0) > stc.getValue(1, 0)) {
                  setSignal(1);
               }
            }
         }
      }
   } else if(stc.getValue(0, 4) > stc.getValue(1, 4)) {
      if(stc.getValue(0, 2) > stc.getValue(1, 2)) {
         if(stc.getValue(0, 1) >= stc.getValue(1, 1)) {
            if((stc.getValue(0, 1) >= 20.00) || (stc.getValue(1, 1) <= 80.00)) {
               if(stc.getValue(0, 0) < stc.getValue(1, 0)) {
                  setSignal(2);
               }
            }
         }
      }
   }  

//
////Filter handle error
//   if(stochasticLine1 != -1 && stochasticLine2 != -1 && signalLine != -1) {
//      //Print("SimpleStochasticOscillator, all handle works");
//      if (stochasticLine2 <= 20.00) {
//         if(stochasticLine1 < signalLine) {
//            setSignal(1);
//         }
//      } else if (stochasticLine2 >= 80.00) {
//         if(stochasticLine1 > signalLine) {
//            setSignal(2);
//         }
//      }
//   } else {
//      Print("SimpleStochasticOscillator, no handle works");
//   }

}
//+------------------------------------------------------------------+