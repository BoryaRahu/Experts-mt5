//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "script\Access.mq5";
#include "script\Strategy\Analyzer.mq5";
#include "script\Calculator.mq5";
#include "script\Contract.mq5";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   Print("Hi I'm Aninditha, your friend in FX Market");
//Analyzer ann;
//ann.checkSignal();
   Comment("NSATS Activated");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Print("System Shutdown");
   Comment("NSATS Deactivated");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   Access accs;
   int signal;

   if(accs.getStatus() == 1) {
      //Comment("You may enter");
      Analyzer ann;
      if(ann.getSignal() == 1) {
         Calculator calc(ann.getSignal()); //Enter a buy trade
         Contract cntr;
         cntr.instantBuy(calc.getLot(),calc.getEntryPrice(),calc.getStopLoss(), calc.getTakeProfit(), "BuyComment");
      } else if(ann.getSignal() == 2) {
         Calculator calc(ann.getSignal()); //Enter a sell trade
         Contract cntr;
         cntr.instantSell(calc.getLot(),calc.getEntryPrice(),calc.getStopLoss(), calc.getTakeProfit(), "SellComment");
      }
   } else {
      //Comment("None shall pass");
   }

}
//+------------------------------------------------------------------+