//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
class RelativeIndexVigor {
 private:
   string            symbol;        // symbol name
   ENUM_TIMEFRAMES   period;        // period
   int               ma_period;     // averaging period
 public:
                     RelativeIndexVigor(ENUM_TIMEFRAMES period, int ma_period);
   double            getValue(int buffer, int index);
   int               definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RelativeIndexVigor::RelativeIndexVigor(ENUM_TIMEFRAMES period,int ma_period) {
   symbol = _Symbol;
   this.period = period;
   this.ma_period = ma_period;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RelativeIndexVigor::definition(void) {
   int handle = iRVI(symbol, period, ma_period);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the RVI indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RelativeIndexVigor::getValue(int buffer,int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, buffer, 0, 3, myPriceArray);
      double value = NormalizeDouble(myPriceArray[index], 3);;
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+