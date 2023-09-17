//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\RelativeStrengthIndex.mq5";
class SimpleRelativeStrengthIndex {
 private:
   int               signal;                             // 1 = Buy, 2 = Sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
                     SimpleRelativeStrengthIndex();       //set default value
                    ~SimpleRelativeStrengthIndex();
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleRelativeStrengthIndex::SimpleRelativeStrengthIndex(void) {
//Print("SimpleRelativeStrengthIndex, constructor");
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleRelativeStrengthIndex::~SimpleRelativeStrengthIndex(void) {
//Print("SimpleRelativeStrengthIndex, destructor");
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleRelativeStrengthIndex::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimpleRelativeStrengthIndex::getSignal(void) {
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
void SimpleRelativeStrengthIndex::checkSignal(void) {
   RelativeStrengthIndex rsi(PERIOD_H1, 14, PRICE_CLOSE); //v2.3 use M15

   double rsiValue = rsi.getValue(0);

   if(rsiValue <= 30) {
      setSignal(1);
   } else if(rsiValue >= 70) {
      setSignal(2);
   }
   
}
//+------------------------------------------------------------------+