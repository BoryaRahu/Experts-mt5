//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class Contract {
 private:
   ENUM_ORDER_TYPE_FILLING getFilling(string symbol);
 public:
   void              instantBuy(double lot, double entry, double sl, double tp, string comment);
   void              instantSell(double lot, double entry, double sl, double tp, string comment);
};
//+------------------------------------------------------------------+
//| function to check broker filling type to make order              |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING Contract::getFilling(string symbol) {
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);

   ENUM_ORDER_TYPE_FILLING fill;

   if((filling & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) {
      fill = ORDER_FILLING_FOK;
   } else if((filling & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) {
      fill = ORDER_FILLING_IOC;
   }
   return fill;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Contract::instantBuy(double lot,double entry,double sl,double tp,string comment) {
   if(lot != -1) {
      //Declare and initialize the trade request and result of trade request
      MqlTradeRequest request ;
      MqlTradeResult result ;

      //Parameter of request
      request.action = TRADE_ACTION_DEAL;
      request.symbol = Symbol();
      request.volume = lot;
      request.price = entry;
      request.sl = sl;
      request.tp = tp;
      request.deviation = 5;
      request.type = ORDER_TYPE_BUY;
      request.type_filling = getFilling(Symbol());
      request.comment = comment;

      //create a buy order
      int ticket = OrderSend(request, result);

      //check error
      if(!ticket) {
         PrintFormat("OrderSend error %d",GetLastError());// if unable to send the request, output
      } else {
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      }
   } else {
      Print("No transaction made");
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Contract::instantSell(double lot,double entry,double sl,double tp,string comment) {
   if(lot != -1) {
      //Declare and initialize the trade request and result of trade request
      MqlTradeRequest request;
      MqlTradeResult result;

      //Parameter of request
      request.action = TRADE_ACTION_DEAL;
      request.symbol = Symbol();
      request.volume = lot;
      request.price = entry;
      request.sl = sl;
      request.tp = tp;
      request.deviation = 5;
      request.type = ORDER_TYPE_SELL;
      request.type_filling = getFilling(Symbol());;
      request.comment = comment;

      //create sell order
      int ticket = OrderSend(request, result);

      //check error
      if(!ticket) {
         PrintFormat("OrderSend error %d",GetLastError());// if unable to send the request, output
      } else {
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      }
   } else {
      Print("No transaction made");
   }
}
//+------------------------------------------------------------------+