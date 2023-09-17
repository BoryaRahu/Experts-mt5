//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class Candle {
 private:
   string            symbol;
   ENUM_TIMEFRAMES   period;
   int               numOfCandle;
 public:
   Candle(ENUM_TIMEFRAMES period, int numOfCandle);
   double            getHigh(int index);
   double            getLow(int index);
   double            getClose(int index);
   double            getOpen(int index);
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Candle::Candle(ENUM_TIMEFRAMES period, int numOfCandle) {
   symbol = _Symbol;
   this.period = period;
   this.numOfCandle = numOfCandle;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Candle::getHigh(int index) {
   MqlRates priceInformation[];
   ArraySetAsSeries(priceInformation, true);

   //v9.0 use candle count variable & access with index
   int data = CopyRates(symbol, period, 0, numOfCandle, priceInformation);

   if(numOfCandle > 0) {
      return priceInformation[index].high;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Candle::getLow(int index) {
   MqlRates priceInformation[];
   ArraySetAsSeries(priceInformation, true);

   //v9.0 use candle count variable & access with index
   int data = CopyRates(symbol, period, 0, numOfCandle, priceInformation);

   if(numOfCandle > 0) {
      return priceInformation[index].low;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Candle::getClose(int index) {
   MqlRates priceInformation[];
   ArraySetAsSeries(priceInformation, true);

   //v9.0 use candle count variable & access with index
   int data = CopyRates(symbol, period, 0, numOfCandle, priceInformation);

   if(numOfCandle > 0) {
      return priceInformation[index].close;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Candle::getOpen(int index) {
   MqlRates priceInformation[];
   ArraySetAsSeries(priceInformation, true);

   //v9.0 use candle count variable & access with index
   int data = CopyRates(symbol, period, 0, numOfCandle, priceInformation);

   if(numOfCandle > 0) {
      return priceInformation[index].open;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+