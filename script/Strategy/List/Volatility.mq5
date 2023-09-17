//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "Volatility\VolatilityHeader.mq5";
class Volatility {
 private:
   int               volatility;                      // 1 = volatile, 2 = not volatile, 0 = default
   void              checkVolatility();               //return output from selected strategies
   void              setVolatility(int volatility);
 public:
                     Volatility(void);
   int               getVolatility();
                    ~Volatility(void);
};
//+------------------------------------------------------------------+
//| Constructor automatically check volatility                       |
//+------------------------------------------------------------------+
Volatility::Volatility(void) {
   setVolatility(0);
   checkVolatility();
}
//+------------------------------------------------------------------+
//| Destructor set volatility to 0 (default)                         |
//+------------------------------------------------------------------+
Volatility::~Volatility(void) {
   setVolatility(0);
}
//+------------------------------------------------------------------+
//| setVolatility() set 3 value and prevent others                   |
//+------------------------------------------------------------------+
void Volatility::setVolatility(int volatility) {
   if(volatility == 1 || volatility == 2 || volatility == 0) {
      this.volatility = volatility;
   } else {
      //Print("Invalid Volatility Input");
   }
}
//+----------------------------------------------------------------------+
//| checkVolatility() check confirmation from volatility type indicators |
//+----------------------------------------------------------------------+
void Volatility::checkVolatility(void) {
   //AverageDirectionalMovementIndex25Level adx25;
   //setVolatility(adx25.getSignal());
   setVolatility(1);
}
//+------------------------------------------------------------------+
//| getVolatility() return 1 or 2 as volatility signal               |
//+------------------------------------------------------------------+
int Volatility::getVolatility(void) {
   if(volatility == 1 || volatility == 2) {
      return volatility;
   } else if(volatility == 0) {
      //Print("No Volatility found");
      return -1;
   } else {
      //Print("Invalid Volatility");
      return -1;
   }
}
//+------------------------------------------------------------------+