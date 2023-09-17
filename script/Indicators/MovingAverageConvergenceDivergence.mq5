//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
class MovingAverageConvergenceDivergence {
 private:
   string              symbol;              // symbol name
   ENUM_TIMEFRAMES     period;              // period
   int                 fast_ema_period;     // period for Fast average calculation
   int                 slow_ema_period;     // period for Slow average calculation
   int                 signal_period;       // period for their difference averaging
   ENUM_APPLIED_PRICE  applied_price;       // type of price or handle
 public:
   MovingAverageConvergenceDivergence(ENUM_TIMEFRAMES period, int fast_ema_period, int slow_ema_period, int signal_period, ENUM_APPLIED_PRICE applied_price);
   double              getValue(int buffer, int index);
   int                 definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageConvergenceDivergence::MovingAverageConvergenceDivergence(ENUM_TIMEFRAMES period,int fast_ema_period,int slow_ema_period,int signal_period,ENUM_APPLIED_PRICE applied_price) {
   symbol = _Symbol;
   this.period = period;
   this.fast_ema_period = fast_ema_period;
   this.slow_ema_period = slow_ema_period;
   this.signal_period = signal_period;
   this.applied_price = applied_price;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MovingAverageConvergenceDivergence::definition(void) {
   int handle = iMACD(symbol, period, fast_ema_period, slow_ema_period, signal_period, applied_price);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the MACD indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
double MovingAverageConvergenceDivergence::getValue(int buffer,int index){
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, buffer, 0, 3, myPriceArray);
      double value = NormalizeDouble(myPriceArray[index], 6);;
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+