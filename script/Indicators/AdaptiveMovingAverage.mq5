//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class AdaptiveMovingAverage {
 private:
   string               symbol;             // symbol name
   ENUM_TIMEFRAMES      period;             // period
   int                  ama_period;         // average period for AMA
   int                  fast_ma_period;     // fast MA period
   int                  slow_ma_period;     // slow MA period
   int                  ama_shift;          // horizontal shift of the indicator
   ENUM_APPLIED_PRICE   applied_price;      // type of the price or handle
   int                  numOfCandle;
 public:
   AdaptiveMovingAverage(ENUM_TIMEFRAMES period, int ama_period, int fast_ma_period, int slow_ma_period, int ama_shift, ENUM_APPLIED_PRICE applied_price, int numOfCandle);
   double               getValue(int index);
   int                  definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AdaptiveMovingAverage::AdaptiveMovingAverage(ENUM_TIMEFRAMES period,int ama_period,int fast_ma_period,int slow_ma_period,int ama_shift,ENUM_APPLIED_PRICE applied_price,int numOfCandle) {
   symbol = _Symbol;
   this.period = period;
   this.ama_period = ama_period;
   this.fast_ma_period = fast_ma_period;
   this.slow_ma_period = slow_ma_period;
   this.ama_shift = ama_shift;
   this.applied_price = applied_price;
   this.numOfCandle = numOfCandle;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AdaptiveMovingAverage::definition(void) {
   int handle = iAMA(symbol, period, ama_period, fast_ma_period, slow_ma_period, ama_shift, applied_price);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iAMA indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AdaptiveMovingAverage::getValue(int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, 0, 0, numOfCandle, myPriceArray);
      double value = myPriceArray[index];
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+