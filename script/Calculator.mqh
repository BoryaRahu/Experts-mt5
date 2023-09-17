//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "Indicators\AverageTrueRange.mq5";
class Calculator {
 private:
   int               signal; //trade signal to make decision, 1 = buy, 2 = sell, 0 = default
   double            lot; //contract size 0.01 - 50 lot (FxPro)
   double            stopLoss; //maximum risk level
   double            takeProfit; //maximum profit level
   double            askPrice; //currency pair buying price
   double            bidPrice; //currency pair selling price
   double            entryPrice; //entry level to enter the market

   void              calculateLot(int signal, double entryPrice, double stopLoss);
   void              calculateStopLoss(int signal);
   void              calculateTakeProfit(int signal);

   void              setSignal(int signal);
   void              setLot(double lot);
   void              setStopLoss(double stopLoss);
   void              setTakeProfit(double takeProfit);
   void              setAskPrice(double askPrice);
   void              setBidPrice(double bidPrice);
   void              setEntryPrice(double entryPrice);

 public:
   Calculator(int signal); //Constructor, set default value then get SL, TP, entry, lot
   double            getLot();
   double            getStopLoss();
   double            getTakeProfit();
   double            getAskPrice();
   double            getBidPrice();
   double            getEntryPrice();
   ~Calculator(void); //Destructor set default value of 0s
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Constructor, set default value then get SL, TP, entry, lot       |
//+------------------------------------------------------------------+
Calculator::Calculator(int signal) {

   //Set default value of 0s
   setSignal(0);
   setLot(0);
   setStopLoss(0);
   setTakeProfit(0);
   setAskPrice(0);
   setBidPrice(0);
   setEntryPrice(0);

   setSignal(signal);
   setAskPrice(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits));
   setBidPrice(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits));

   if(this.signal == 1) {
      //calculate buy signal
      setEntryPrice(askPrice);
      calculateStopLoss(this.signal);
      calculateTakeProfit(this.signal);
      if(stopLoss != 0 && takeProfit != 0) {
         //if SL and TP have value, calculate lot size
         calculateLot(this.signal, entryPrice, stopLoss);
      } else {
         setLot(0);
      }

   } else if(this.signal == 2) {
      //calculate sell signal
      setEntryPrice(bidPrice);
      calculateStopLoss(this.signal);
      calculateTakeProfit(this.signal);
      if(stopLoss != 0 && takeProfit != 0) {
         //if SL and TP have value, calculate lot size
         calculateLot(this.signal, entryPrice, stopLoss);
      } else {
         setLot(0);
      }
   } else {
      Print("Invalid Signal Calculator");
   }
}
//+------------------------------------------------------------------+
//| Destructor set default value of 0s                               |
//+------------------------------------------------------------------+
Calculator::~Calculator(void) {
   //Set default value of 0s
   setSignal(0);
   setLot(0);
   setStopLoss(0);
   setTakeProfit(0);
   setAskPrice(0);
   setBidPrice(0);
   setEntryPrice(0);
}
//+------------------------------------------------------------------+
//| function to set signal with 1, 2, or 0                           |
//+------------------------------------------------------------------+
void Calculator::setSignal(int signal) {
   if(signal == 1 || signal == 2 || signal == 0) {
      this.signal = signal;
   } else {
      Print("Invalid Signal Input");
   }
}
//+------------------------------------------------------------------+
//| function the set lot value 0.01 - 1000 lot                       |
//+------------------------------------------------------------------+
void Calculator::setLot(double lot) {
   if(lot >= 0.01 && lot <= 1000.00 || lot == 0) {
      this.lot = lot;
   } else {
      Print("Invalid Lot");
   }
}
//+------------------------------------------------------------------+
//| function to set stoploss level                                   |
//+------------------------------------------------------------------+
void Calculator::setStopLoss(double stopLoss) {
   if(stopLoss > 0 || stopLoss == 0) {
      this.stopLoss = stopLoss;
   } else {
      Print("Invalid StopLoss");
   }
}
//+------------------------------------------------------------------+
//| function to set take profit level                                |
//+------------------------------------------------------------------+
void Calculator::setTakeProfit(double takeProfit) {
   if(takeProfit > 0 || takeProfit == 0) {
      this.takeProfit = takeProfit;
   } else {
      Print("Invalid TakeProfit");
   }
}
//+------------------------------------------------------------------+
//| function to set ask price                                        |
//+------------------------------------------------------------------+
void Calculator::setAskPrice(double askPrice) {
   if(askPrice > 0 || askPrice == 0) {
      this.askPrice = askPrice;
   } else {
      Print("Invalid AskPrice");
   }
}
//+------------------------------------------------------------------+
//| function to set bid price                                        |
//+------------------------------------------------------------------+
void Calculator::setBidPrice(double bidPrice) {
   if(bidPrice > 0 || bidPrice == 0) {
      this.bidPrice = bidPrice;
   } else {
      Print("Invalid BidPrice");
   }
}
//+------------------------------------------------------------------+
//| function to set entry price                                      |
//+------------------------------------------------------------------+
void Calculator::setEntryPrice(double entryPrice) {
   if(entryPrice > 0 || entryPrice == 0) {
      this.entryPrice = entryPrice;
   } else {
      Print("Invalid EntryPrice");
   }
}
//+------------------------------------------------------------------+
//| fuction to calculate lot at 2% risk                              |
//+------------------------------------------------------------------+
void Calculator::calculateLot(int signal,double entryPrice,double stopLoss) {

   double maxDlrsRisked = AccountInfoDouble(ACCOUNT_BALANCE) * 0.02; //2% of balance in $ format
   double maxPipsRisked = 1;  //default number 1 to prevent dividing by 0
   double pricePerPip = 1;    //default number 1 to prevent dividing by 0
   double lot;
   if(signal == 1) {
      //buy signal, calculate 2% risk contract
      maxPipsRisked = NormalizeDouble(((entryPrice - stopLoss)*10000),0);
      pricePerPip = maxDlrsRisked / maxPipsRisked;
      lot = NormalizeDouble(pricePerPip * 0.1, 2);
      setLot(lot);
   } else if(signal == 2) {
      //sell signal, calculate 2% risk contract
      maxPipsRisked = NormalizeDouble(((stopLoss - entryPrice)*10000),0);
      pricePerPip = maxDlrsRisked / maxPipsRisked;
      lot = NormalizeDouble(pricePerPip * 0.1, 2);
      setLot(lot);
   } else {
      Print("Invalid Signal, calculateLot");
      setLot(0);
   }
}
//+------------------------------------------------------------------+
//| function to calculate stoploss using ATR                         |
//+------------------------------------------------------------------+
void Calculator::calculateStopLoss(int signal) {
   AverageTrueRange atr(PERIOD_H1, 14);
   if(signal == 1) {
      double sl = NormalizeDouble(entryPrice - atr.getValue(0),5);
      if(sl < entryPrice) {
         setStopLoss(sl);
      } else {
         setStopLoss(0);
      }
   } else if(signal == 2) {
      double sl = NormalizeDouble(entryPrice + atr.getValue(0),5);
      if(sl > entryPrice) {
         setStopLoss(sl);
      } else {
         setStopLoss(0);
      }
   } else {
      Print("Invalid Signal, CalculateStopLoss");
   }
}
//+------------------------------------------------------------------+
//| function to calculate take profit using ATR (3x SL)              |
//+------------------------------------------------------------------+
void Calculator::calculateTakeProfit(int signal) {
   AverageTrueRange atr(PERIOD_H1, 14);
   if(signal == 1) {
      double tp = NormalizeDouble(entryPrice + (3 * atr.getValue(0)),5);
      if(tp > entryPrice) {
         setTakeProfit(tp);
      } else {
         setTakeProfit(0);
      }
   } else if(signal == 2) {
      double tp = NormalizeDouble(entryPrice - (3 * atr.getValue(0)),5);
      if(tp < entryPrice) {
         setTakeProfit(tp);
      } else {
         setTakeProfit(0);
      }
   } else {
      Print("Invalid Signal, CalculateStopLoss");
   }
}
//+------------------------------------------------------------------+
//| function to get lot value                                        |
//+------------------------------------------------------------------+
double Calculator::getLot(void) {
   if(lot >= 0.01 && lot <= 1000.00) {
      return lot;
   } else if(lot == 0) {
      return -1;
      Print("Default lot of ", lot);
   } else {
      return -1;
      Print("Invalid Lot");
   }
}
//+------------------------------------------------------------------+
//| function to get stoploss level                                   |
//+------------------------------------------------------------------+
double Calculator::getStopLoss(void) {
   if(stopLoss > 0) {
      return stopLoss;
   } else if(stopLoss == 0) {
      return -1;
      Print("Default StopLoss of ", stopLoss);
   } else {
      return -1;
      Print("Invalid StopLoss");
   }
}
//+------------------------------------------------------------------+
//| function to get take profit level                                |
//+------------------------------------------------------------------+
double Calculator::getTakeProfit(void) {
   if(takeProfit > 0) {
      return takeProfit;
   } else if(takeProfit == 0) {
      return -1;
      Print("Default TakeProfit of ", takeProfit);
   } else {
      return -1;
      Print("Invalid TakeProfit");
   }
}
//+------------------------------------------------------------------+
//| function to get ask price                                        |
//+------------------------------------------------------------------+
double Calculator::getAskPrice(void) {
   if(askPrice > 0) {
      return askPrice;
   } else if(askPrice == 0) {
      return -1;
      Print("Default AskPrice of ", askPrice);
   } else {
      return -1;
      Print("Invalid AskPrice");
   }
}
//+------------------------------------------------------------------+
//| function to get bid price                                        |
//+------------------------------------------------------------------+
double Calculator::getBidPrice(void) {
   if(bidPrice > 0) {
      return bidPrice;
   } else if(bidPrice == 0) {
      return -1;
      Print("Default BidPrice of ", bidPrice);
   } else {
      return -1;
      Print("Invalid BidPrice");
   }
}
//+------------------------------------------------------------------+
//| function to get entry price                                      |
//+------------------------------------------------------------------+
double Calculator::getEntryPrice(void) {
   if(entryPrice > 0) {
      return entryPrice;
   } else if(entryPrice == 0) {
      return -1;
      Print("Default EntryPrice of ", entryPrice);
   } else {
      return -1;
      Print("Invalid EntryPrice");
   }
}
//+------------------------------------------------------------------+