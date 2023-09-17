//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "Trend\TrendHeader.mq5";
class Trend {
 private:
   int               trend;               // 1 = uptrend, 2 = downtrend, 3 = sideways, 0 = default
   void              checkTrend();        //return output from selected strategies
   void              setTrend(int trend);
 public:
                     Trend(void);
   int               getTrend();
                    ~Trend(void);
};
//+------------------------------------------------------------------+
//| Constructor automatically check trend                            |
//+------------------------------------------------------------------+
Trend::Trend(void) {
   setTrend(0);
   checkTrend();
}
//+------------------------------------------------------------------+
//| Destructor set trend to 0 (default)                              |
//+------------------------------------------------------------------+
Trend::~Trend(void) {
   setTrend(0);
}
//+------------------------------------------------------------------+
//| setTrend() set 4 value and prevent others                        |
//+------------------------------------------------------------------+
void Trend::setTrend(int trend) {
   if(trend == 1 || trend == 2 || trend == 3 || trend == 0) {
      this.trend = trend;
   } else {
      //Print("Invalid Trend Input");
   }
}
//+------------------------------------------------------------------+
//| checkTrend() check confirmation from trend type indicators       |
//+------------------------------------------------------------------+
void Trend::checkTrend(void) {
   SimplePSAR psar;
   setTrend(psar.getSignal());
   //setTrend(1);
}
//+------------------------------------------------------------------+
//| getTrend() return 1 or 2 as trend signal                         |
//+------------------------------------------------------------------+
int Trend::getTrend(void) {
   if(trend == 1 || trend == 2) {
      return trend;
   } else if(trend == 0) {
      //Print("No Trend found");
      return -1;
   } else {
      //Print("Invalid Trend");
      return -1;
   }
}
//+------------------------------------------------------------------+