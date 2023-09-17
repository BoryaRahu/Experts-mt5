//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\AverageDirectionalMovementIndex.mq5";
class AverageDirectionalMovementIndexDIPosition {
 private:
   int               signal;                             // 1 = Uptrend, 2 = not Downtrend, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
                     AverageDirectionalMovementIndexDIPosition();       //set default value
                    ~AverageDirectionalMovementIndexDIPosition();
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AverageDirectionalMovementIndexDIPosition::AverageDirectionalMovementIndexDIPosition(void) {
//Print("AverageDirectionalMovementIndexDIPosition, constructor");
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AverageDirectionalMovementIndexDIPosition::~AverageDirectionalMovementIndexDIPosition(void) {
//Print("AverageDirectionalMovementIndexDIPosition, destructor");
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AverageDirectionalMovementIndexDIPosition::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
int AverageDirectionalMovementIndexDIPosition::getSignal(void) {
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
void AverageDirectionalMovementIndexDIPosition::checkSignal(void) {

   AverageDirectionalMovementIndex adx(PERIOD_H1, 14);

   double plusDI = adx.getValue(1,0);
   double minusDI = adx.getValue(2,0);

   if(plusDI > minusDI) {
      setSignal(1);
   } else if(plusDI < minusDI) {
      setSignal(2);
   }

}
//+------------------------------------------------------------------+