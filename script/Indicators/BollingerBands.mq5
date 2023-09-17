//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class BollingerBands {
 private:
   string              symbol;            // symbol name
   ENUM_TIMEFRAMES     period;            // period
   int                 bands_period;      // period for average line calculation
   int                 bands_shift;       // horizontal shift of the indicator
   double              deviation;         // number of standard deviations
   ENUM_APPLIED_PRICE  applied_price;     // type of price or handle
 public:
   BollingerBands(ENUM_TIMEFRAMES period, int band_period, int bands_shift, double deviation, ENUM_APPLIED_PRICE applied_price);
   double              getValue(int buffer, int index);
   int                 definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BollingerBands::BollingerBands(ENUM_TIMEFRAMES period,int bands_period,int bands_shift,double deviation,ENUM_APPLIED_PRICE applied_price) {
   symbol = _Symbol;
   this.period = period;
   this.bands_period = bands_period;
   this.bands_shift = bands_shift;
   this.deviation = deviation;
   this.applied_price = applied_price;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BollingerBands::definition(void) {
   int handle = iBands(symbol, period, bands_period, bands_shift, deviation, applied_price);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BollingerBands::getValue(int buffer, int index) {
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