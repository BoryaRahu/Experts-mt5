//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class ChaikinOscillator {
 private:
   string               symbol;             // symbol name
   ENUM_TIMEFRAMES      period;             // period
   int                  fast_ma_period;     // fast period
   int                  slow_ma_period;     // slow period
   ENUM_MA_METHOD       ma_method;          // smoothing type
   ENUM_APPLIED_VOLUME  applied_volume;      // type of volume
 public:
   ChaikinOscillator(ENUM_TIMEFRAMES period, int fast_ma_period, int slow_ma_period, ENUM_MA_METHOD ma_method, ENUM_APPLIED_VOLUME applied_volume);
   long                 getValue(int index);
   int                  definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ChaikinOscillator::ChaikinOscillator(ENUM_TIMEFRAMES period,int fast_ma_period,int slow_ma_period,ENUM_MA_METHOD ma_method,ENUM_APPLIED_VOLUME applied_volume) {
   symbol = _Symbol;
   this.period = period;
   this.fast_ma_period = fast_ma_period;
   this.slow_ma_period = slow_ma_period;
   this.ma_method = ma_method;
   this.applied_volume = applied_volume;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChaikinOscillator::definition(void) {
   int handle = iChaikin(symbol, period, fast_ma_period, slow_ma_period, ma_method, applied_volume);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iChaikin indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long ChaikinOscillator::getValue(int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, 0, 0, 3, myPriceArray);
      double value = myPriceArray[index];
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+