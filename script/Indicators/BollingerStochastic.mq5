//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\..\..\Indicators\BollingerBands.mq5";
#include "..\..\..\Indicators\StochasticOscillator.mq5";
#include "..\..\..\Indicators\MovingAverage.mq5";
#include "SimpleStochasticOscillator.mq5";
class BollingerStochastic {
 private:
   int               signal;                             // 1 = Buy, 2 = Sell, 0 = default
   void              setSignal(int signal);
   void              checkSignal();
 public:
   BollingerStochastic(void);
   ~BollingerStochastic(void);
   int               getSignal();
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BollingerStochastic::BollingerStochastic(void) {
   setSignal(0);
   checkSignal();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BollingerStochastic::~BollingerStochastic(void) {
   setSignal(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BollingerStochastic::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BollingerStochastic::getSignal(void) {
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
void BollingerStochastic::checkSignal(void) {
   BollingerBands bb(PERIOD_H1, 20, 0, 2.0, PRICE_CLOSE);
   SimpleStochasticOscillator sso;

   double upperBand = bb.getValue(1, 0);
   double lowerBand = bb.getValue(2, 0);

   MovingAverage maLow(PERIOD_H1, 1, MODE_EMA, PRICE_LOW, 3);
   MovingAverage maHigh(PERIOD_H1, 1, MODE_EMA, PRICE_HIGH, 3);
   MovingAverage maClose(PERIOD_H1, 1, MODE_EMA, PRICE_CLOSE, 3);

   //v5.0 follow the bollinger
   if((maClose.getValue(0) <= lowerBand) || (maLow.getValue(0) <= lowerBand)) {
      if(sso.getSignal() == 1) {
         setSignal(1);
      } 
   } else if((maClose.getValue(0) >= upperBand) || (maHigh.getValue(0) >= upperBand)) {
      if(sso.getSignal() == 2) {
         setSignal(2);
      } 
   }
}
//+------------------------------------------------------------------+