//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\CommodityChannelIndex.mq5";
class SimpleCommodityChannelIndex {
 private:
   int               signal;                             // 1 = Buy, 2 = Sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   SimpleCommodityChannelIndex(void);
   ~SimpleCommodityChannelIndex(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleCommodityChannelIndex::SimpleCommodityChannelIndex(void) {
//Print("SimpleCommodityChannelIndex, constructor");
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SimpleCommodityChannelIndex::~SimpleCommodityChannelIndex(void) {
//Print("SimpleCommodityChannelIndex, destructor");
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleCommodityChannelIndex::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SimpleCommodityChannelIndex::getSignal(void) {
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
void SimpleCommodityChannelIndex::checkSignal(void) {
   CommodityChannelIndex cci(PERIOD_H1, 14, PRICE_TYPICAL, 10);
   

   if(cci.getValue(2) < -100) {
      if(cci.getValue(1) < -100) {
         if(cci.getValue(1) > cci.getValue(2)) {
            if(cci.getValue(0) > -100) {
               setSignal(1);
            }
         }
      }
   } else if(cci.getValue(2) > 100) {
      if(cci.getValue(1) > 100) {
         if(cci.getValue(1) < cci.getValue(2)) {
            if(cci.getValue(0) < 100) {
               setSignal(2);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+