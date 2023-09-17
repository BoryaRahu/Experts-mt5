//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "Momentum\MomentumHeader.mq5";

class Momentum {
 private:
   int               momentum;                     // 1 = buy, 2 = sell, 0 = default
   void              checkMomentum();
   void              setMomentum(int momentum);
 public:
   Momentum(void);
   int               getMomentum();
   ~Momentum(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Constructor automatically check momentum                         |
//+------------------------------------------------------------------+
Momentum::Momentum(void) {
   setMomentum(0);
   checkMomentum();
}
//+------------------------------------------------------------------+
//| Destructor set momentum to 0 (default)                           |
//+------------------------------------------------------------------+
Momentum::~Momentum(void) {
   setMomentum(0);
}
//+------------------------------------------------------------------+
//| setMomentum() set 3 value and prevent others                     |
//+------------------------------------------------------------------+
void Momentum::setMomentum(int momentum) {
   if(momentum == 1 || momentum == 2 || momentum == 0) {
      this.momentum = momentum;
   } else {
      //Print("Invalid Momentum Input");
   }
}
//+------------------------------------------------------------------+
//| checkMomentum() check confirmation from momentum type indicators |
//+------------------------------------------------------------------+
void Momentum::checkMomentum(void) {
   SimpleCommodityChannelIndex cci;
   setMomentum(cci.getSignal());
   //setMomentum(1);
}
//+------------------------------------------------------------------+
//| getMomentum() return 1 or 2 as momentum signal                   |
//+------------------------------------------------------------------+
int Momentum::getMomentum(void) {
   if(momentum == 1 || momentum == 2) {
      return momentum;
   } else if(momentum == 0) {
      //Print("No Momentum found");
      return -1;
   } else {
      //Print("Invalid Momentum");
      return -1;
   }
}
//+------------------------------------------------------------------+