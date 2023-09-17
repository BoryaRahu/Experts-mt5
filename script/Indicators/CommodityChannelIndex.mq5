//+------------------------------------------------------------------+
//|                                                            NSATS |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class CommodityChannelIndex {
 private:
   string               symbol;            // symbol name
   ENUM_TIMEFRAMES      period;            // period
   int                  ma_period;         // averaging period
   ENUM_APPLIED_PRICE   applied_price;     // type of price or handle
   int                  numOfCandles;      // count of candles needed
 public:
   CommodityChannelIndex(ENUM_TIMEFRAMES period, int ma_period, ENUM_APPLIED_PRICE applied_price, int numOfCandles);
   double               getValue(int index);
   int                  definition(void);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CommodityChannelIndex::CommodityChannelIndex(ENUM_TIMEFRAMES period,int ma_period,ENUM_APPLIED_PRICE applied_price, int numOfCandles) {
   symbol = _Symbol;
   this.period = period;
   this.ma_period = ma_period;
   this.applied_price = applied_price;
   this.numOfCandles = numOfCandles;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CommodityChannelIndex::definition(void) {
   int handle = iCCI(symbol, period, ma_period, applied_price);
   if(handle==INVALID_HANDLE) {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d", symbol, EnumToString(period), GetLastError());
      return -1;
   } else {
      return handle;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CommodityChannelIndex::getValue(int index) {
   double myPriceArray[];
   int definition = definition();
   if(definition != -1) {
      ArraySetAsSeries(myPriceArray, true);
      CopyBuffer(definition, 0, 0, numOfCandles, myPriceArray);
      double value = NormalizeDouble(myPriceArray[index], 2);;
      return value;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+