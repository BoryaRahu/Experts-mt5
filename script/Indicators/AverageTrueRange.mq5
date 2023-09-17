//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
class AverageTrueRange {
 private:
   string            symbol;        // symbol name
   ENUM_TIMEFRAMES   period;        // period
   int               ma_period;      // averaging period
 public:
                     AverageTrueRange(ENUM_TIMEFRAMES period, int ma_period);
   double            getValue(int index);
   int               definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AverageTrueRange::AverageTrueRange(ENUM_TIMEFRAMES period,int ma_period) {
   symbol = _Symbol;
   this.period = period;
   this.ma_period = ma_period;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AverageTrueRange::definition(void) {
   int handle = iATR(symbol, period, ma_period);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
double AverageTrueRange::getValue(int index){
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