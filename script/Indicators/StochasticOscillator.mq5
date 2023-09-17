//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+

class StochasticOscillator {
 private:
   string            symbol;          // symbol name
   ENUM_TIMEFRAMES   period;          // period
   int               k_period;        // K-period (number of bars for calculations)
   int               d_period;        // D-period (period of first smoothing)
   int               slowing;         // final smoothing
   ENUM_MA_METHOD    ma_method;       // type of smoothing
   ENUM_STO_PRICE    price_field;     // stochastic calculation method
   int               numOfCandle;
 public:
   StochasticOscillator(ENUM_TIMEFRAMES period, int k_period, int d_period, int slowing, ENUM_MA_METHOD ma_method, ENUM_STO_PRICE price_field, int numOfCandle);
   double            getValue(int buffer, int index);
   int               definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StochasticOscillator::StochasticOscillator(ENUM_TIMEFRAMES period,int k_period,int d_period,int slowing,ENUM_MA_METHOD ma_method,ENUM_STO_PRICE price_field, int numOfCandle) {
   symbol = _Symbol;
   this.period = period;
   this.k_period = k_period;
   this.d_period = d_period;
   this.slowing = slowing;
   this.ma_method = ma_method;
   this.price_field = price_field;
   this.numOfCandle = numOfCandle;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int StochasticOscillator::definition(void) {
   int handle = iStochastic(symbol, period, k_period, d_period, slowing, ma_method, price_field);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the STC indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StochasticOscillator::getValue(int buffer,int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, buffer, 0, numOfCandle, myPriceArray);
      double value = NormalizeDouble(myPriceArray[index], 2);;
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+