//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
class RelativeStrengthIndex {
 private:
   string              symbol;            // symbol name
   ENUM_TIMEFRAMES     period;            // period
   int                 ma_period;         // averaging period
   ENUM_APPLIED_PRICE  applied_price;     // type of price or handle
 public:
                     RelativeStrengthIndex(ENUM_TIMEFRAMES period, int ma_period, ENUM_APPLIED_PRICE applied_price);
   double            getValue(int index);
   int               definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RelativeStrengthIndex::RelativeStrengthIndex(ENUM_TIMEFRAMES period,int ma_period,ENUM_APPLIED_PRICE applied_price) {
   symbol = _Symbol;
   this.period = period;
   this.ma_period = ma_period;
   this.applied_price = applied_price;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RelativeStrengthIndex::definition(void) {
   int handle = iRSI(symbol, period, ma_period, applied_price);
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
double RelativeStrengthIndex::getValue(int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, 0, 0, 3, myPriceArray);
      double value = NormalizeDouble(myPriceArray[index], 2);;
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+