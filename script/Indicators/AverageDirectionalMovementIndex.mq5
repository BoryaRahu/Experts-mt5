//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
class AverageDirectionalMovementIndex {
 private:
   string            symbol;         // symbol name
   ENUM_TIMEFRAMES   period;         // period
   int               adx_period;     // averaging period
 public:
                     AverageDirectionalMovementIndex(ENUM_TIMEFRAMES period, int adx_period);
   double            getValue(int buffer, int index);
   int               definition(void);
};
//+------------------------------------------------------------------+
AverageDirectionalMovementIndex::AverageDirectionalMovementIndex(ENUM_TIMEFRAMES period,int adx_period) {
   symbol = _Symbol;
   this.period = period;
   this.adx_period = adx_period;
}
int AverageDirectionalMovementIndex::definition(void){
   int handle = iADX(symbol, period, adx_period);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
double AverageDirectionalMovementIndex::getValue(int buffer, int index){
   //The buffer numbers are the following: 0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE.
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, buffer, 0, 3, myPriceArray);
      double value = myPriceArray[index];
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+