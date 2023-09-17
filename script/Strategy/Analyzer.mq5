//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "List\Momentum.mq5";
#include "List\Trend.mq5";
#include "List\Volatility.mq5";
#include "List\Volume.mq5";

class Analyzer {
 private:

   int               signal;        // 1 = buy, 2 = sell, 0 = default
   int               trend;         // 1 = uptrend, 2 = downtrend, 3 = sideways, 0 = default
   int               momentum;      // 1 = buy, 2 = sell, 0 = default
   int               volatility;    // 1 = volatile, 2 = not volatile, 0 = default
   int               volume;        // 1 = high volume, 2 = low volume, 0 = default
   
   void              setSignal(int signal);
   void              setTrend(int trend);
   void              setMomentum(int momentum);
   void              setVolatility(int volatility);
   void              setVolume(int volume);
   
   int               getTrend();
   int               getMomentum();
   int               getVolatility();
   int               getVolume();
   
   void              checkSignal();

 public:
                     Analyzer();
   int               getSignal();

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//| Analyzer Constructor, set default value 0 and trigger checkSignal()    |
//+------------------------------------------------------------------------+
Analyzer::Analyzer() {

//default value
   setSignal(0);
   setTrend(0);
   setMomentum(0);
   setVolatility(0);
   setVolume(0);
   checkSignal();

}
//+------------------------------------------------------------------+
//| setSignal() helps set 3 default signal value and prevent others  |
//+------------------------------------------------------------------+
void Analyzer::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      //Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//| setTrend() helps set 4 default trend value and prevent others    |
//+------------------------------------------------------------------+
void Analyzer::setTrend(int trend) {
   if(trend == 1 || trend == 2 || trend == 3 || trend == 0) {
      this.trend = trend;
   } else {
      //Print("Invalid Trend Input");
   }
}
//+------------------------------------------------------------------+
//| setMomentum() helps set 3 momentum value and prevent others      |
//+------------------------------------------------------------------+
void Analyzer::setMomentum(int momentum) {
   if(momentum == 1 || momentum == 2 || momentum == 0) {
      this.momentum = momentum;
   } else {
      //Print("Invalid Momentum Input");
   }
}
//+------------------------------------------------------------------+
//| setVolatility() helps set 3 volatility value and prevent others  |
//+------------------------------------------------------------------+
void Analyzer::setVolatility(int volatility) {
   if(volatility == 1 || volatility == 2 || volatility == 0) {
      this.volatility = volatility;
   } else {
      //Print("Invalid Volatility Input");
   }
}
//+------------------------------------------------------------------+
//| setVolume() helps set 3 volume value and prevent others          |
//+------------------------------------------------------------------+
void Analyzer::setVolume(int volume) {
   if(volume == 1 || volume == 2 || volume == 0) {
      this.volume = volume;
   } else {
      //Print("Invalid Volume Input");
   }
}
//+------------------------------------------------------------------+
//| getSignal() return value or 1 or 2                               |
//+------------------------------------------------------------------+
int Analyzer::getSignal(void) {
   if(signal == 1 || signal == 2) {
      return signal;
   } else if(signal == 0) {
      //Print("No Signal found");
      return -1;
   } else {
      //Print("Invalid Signal");
      return -1;
   }
}
//+------------------------------------------------------------------+
//| getTrend() return value of 1 or 2                                |
//+------------------------------------------------------------------+
int Analyzer::getTrend(void) {
   if(trend == 1 || trend == 2) {
      return trend;
   } else if(trend == 0) {
      //Print("No Trend found");
      return -1;
   } else {
      //Print("Invalid Trend");
      return -1;
   }
}
//+------------------------------------------------------------------+
//| getMomentum() return value of 1 or 2                             |
//+------------------------------------------------------------------+
int Analyzer::getMomentum(void) {
   if(momentum == 1 || momentum == 2) {
      return momentum;
   } else if(momentum == 0) {
      //Print("No Momentum found");
      return -1;
   } else {
      //Print("Invalid Momentum");
      return -1;
   }
}
//+------------------------------------------------------------------+
//| getVolatility() return value or 1 or 2                           |
//+------------------------------------------------------------------+
int Analyzer::getVolatility(void) {
   if(volatility == 1 || volatility == 2) {
      return volatility;
   } else if(volatility == 0) {
      //Print("No Volatility found");
      return -1;
   } else {
      //Print("Invalid Volatility");
      return -1;
   }
}
//+------------------------------------------------------------------+
//| check trading signal to buy or sell                              |
//+------------------------------------------------------------------+
void Analyzer::checkSignal(void) {
   Trend tnd;
   Momentum mnt;
   Volatility vlt;
   Volume vol;

   setTrend(tnd.getTrend());
   setMomentum(mnt.getMomentum());
   setVolatility(vlt.getVolatility());
   setVolume(vol.getVolume());

   if (trend == 1) {
      //Uptrend
      if (volatility == 1) {
         if (volume == 1) {
            if(momentum == 1) {
               //Print("Uptrend BUY");
               setSignal(1); 
               //Comment("buy");
            } else if (momentum == 2) {
               //Print("Uptrend SELL");
               //setSignal(2); //not doing any thing
            }
         } else if (volume == 2) {
            //Print("Can't enter, Low volume");
         } else {
            //Print("Invalid Volume Analyzer : ", volume);
         }
      } else if (volatility == 2) {
         //Print("Can't enter, Low volatility");
      } else {
         //Print("Invalid Volatility Analyzer : ", volatility);
      }
   } else if (trend == 2) {
      //Downtrend
      if (volatility == 1) {
         if (volume == 1) {
            if(momentum == 1) {
               //Print("Downtrend BUY");
               //setSignal(0); //not doing any thing
            } else if (momentum == 2) {
               //Print("Downtrend SELL");
               setSignal(2);
               //Comment("sell");
            }
         } else if (volume == 2) {
            //Print("Can't enter, Low volume");
         } else {
            //Print("Invalid Volume Analyzer : ", volume);
         }
      } else if (volatility == 2) {
         //Print("Can't enter, Low volatility");
      } else {
         //Print("Invalid Volatility Analyzer : ", volatility);
      }
   } else if (trend == 3) {
      //TODO: find sideway strategy
   } else {
      //Print("Invalid Trend Analyzer : ", trend);
   }
}

//+------------------------------------------------------------------+