//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class ParabolicSAR {
 private:
   string            symbol;      // symbol name
   ENUM_TIMEFRAMES   period;      // period
   double            step;        // price increment step - acceleration factor
   double            maximum;     // maximum value of step
 public:
                     ParabolicSAR(ENUM_TIMEFRAMES period, double step, double maximum);
   double            getValue(int index);
   int               definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ParabolicSAR::ParabolicSAR(ENUM_TIMEFRAMES period,double step,double maximum) {
   symbol = _Symbol;
   this.period = period;
   this.step = step;
   this.maximum = maximum;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ParabolicSAR::definition(void) {
   int handle = iSAR(symbol, period, step, maximum);

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
double ParabolicSAR::getValue(int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, 0, 0, 3, myPriceArray);
      double value = NormalizeDouble(myPriceArray[index], 3);;
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+