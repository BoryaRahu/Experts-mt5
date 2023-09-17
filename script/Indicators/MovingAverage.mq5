//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
class MovingAverage {
 private:
   string symbol;                      // symbol name
   ENUM_TIMEFRAMES period;             // period
   int ma_period;                      // averaging period
   int ma_shift;                       // horizontal shift
   ENUM_MA_METHOD ma_method;           // smoothing type
   ENUM_APPLIED_PRICE applied_price;   // type of price or handle
   int numOfCandle;                    // numbers of candle data needed
 public:
   MovingAverage(ENUM_TIMEFRAMES period, int ma_period, ENUM_MA_METHOD ma_method, ENUM_APPLIED_PRICE applied_price, int numOfCandle);
   double getValue(int index);
   int definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage::MovingAverage(ENUM_TIMEFRAMES period, int ma_period, ENUM_MA_METHOD ma_method, ENUM_APPLIED_PRICE applied_price, int numOfCandle) {
   symbol = _Symbol;
   this.period = period;
   this.ma_period = ma_period;
   ma_shift = 0;
   this.ma_method = ma_method;
   this.applied_price = applied_price;
   this.numOfCandle = numOfCandle;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MovingAverage::definition(void) {
   int handle = iMA(symbol, period, ma_period, ma_shift, ma_method, applied_price);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MovingAverage::getValue(int index) {
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