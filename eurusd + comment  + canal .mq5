#define VERSION "1.0"
#property version VERSION

#define PROJECT_NAME MQLInfoString(MQL_PROGRAM_NAME)


#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\OrderInfo.mqh> COrderInfo     m_order;
#include <Trade\Trade.mqh> CTrade trade;
#include <Trade\AccountInfo.mqh>  CAccountInfo   AI;  
#include <Trade\SymbolInfo.mqh>
COrderInfo        m_Order;   // entity for obtaining information on positions
CPositionInfo     m_Position;   // entity for obtaining information on positions
CTrade            m_Trade;      // entity for execution of trades
CSymbolInfo       m_symbol;  
input double Lots = 0.1;
input double RiskPercent = 2.0; //RiskPercent (0 = Fix)

input int OrderDistPoints = 200;
input int TpPoints = 200;
input int SlPoints = 200;
input int TslPoints = 5;
input int TslTriggerPoints = 5;

input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;
input int BarsN = 5;
input int ExpirationHours = 50;

input int Magic = 11123;


ulong buyPos, sellPos;
int totalBars,HighBig;

int OnInit(){
   trade.SetExpertMagicNumber(Magic);
   if(!trade.SetTypeFillingBySymbol(_Symbol)){
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
   }

   static bool isInit = false;
   if(!isInit){
      isInit = true;
      Print(__FUNCTION__," > EA (re)start...");
      Print(__FUNCTION__," > EA version ",VERSION,"...");
       
      for(int i = PositionsTotal()-1; i >= 0; i--){
         CPositionInfo pos;
         if(pos.SelectByIndex(i)){
            if(pos.Magic() != Magic) continue;
            if(pos.Symbol() != _Symbol) continue;

            Print(__FUNCTION__," > Found open position with ticket #",pos.Ticket(),"...");
            if(pos.PositionType() == POSITION_TYPE_BUY) buyPos = pos.Ticket();
            if(pos.PositionType() == POSITION_TYPE_SELL) sellPos = pos.Ticket();
         }
      }

      for(int i = OrdersTotal()-1; i >= 0; i--){
         COrderInfo order;
         if(order.SelectByIndex(i)){
            if(order.Magic() != Magic) continue;
            if(order.Symbol() != _Symbol) continue;

            Print(__FUNCTION__," > Found pending order with ticket #",order.Ticket(),"...");
            if(order.OrderType() == ORDER_TYPE_BUY_STOP) buyPos = order.Ticket();
            if(order.OrderType() == ORDER_TYPE_SELL_STOP) sellPos = order.Ticket();
         }
      }
   }

 HighBig=iMA(_Symbol,Timeframe,200,1,MODE_EMA,PRICE_MEDIAN); 

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){
   processPos(buyPos);
   processPos(sellPos);
   double   AwerageBuyPrice=0,AwerageSelPrice=0, PartCloseSelPrice=0,PartCloseBuyPrice =0 , SelClose=0 , BuyClose=0, BuyAver=0 , SelAver=0   ;  

   int bs=0,ss=0; 
   double SL = 0;
  double TLB = 0;
  double TLS = 0;
  double SSL= 0;   
  double BSS = 0;
  double BLL = 0;
  double SLL= 0;      
  double OPlast = 0;                            // unnormalized SL value      
  datetime   TIMElast=0;
 double _HighBig[];
  int total=PositionsTotal();
    ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==Magic)

            
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {                    
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     bs++;                                        
                    }
                  // ===
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     ss++;
                     }
                  }
          
    int totalORD=OrdersTotal();

        
    for(int k=totalORD-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==Magic)
            
            { 
          
                  if(m_Order.OrderType()== ORDER_TYPE_BUY_LIMIT)
                    {  
                    Print("HRLLL");
                    BLL++;
                     
                    }
                   if(m_Order.OrderType()==ORDER_TYPE_BUY_STOP)
                    {  
                    BSS++;
                    }
                    if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT)
                    {  
                    SLL++;
                    }
                     if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
                    {  
                    SSL++;
                    }
            }
         
  
  Print (DoubleToString(BLL,3));
  
   ArraySetAsSeries(_HighBig,true);
   CopyBuffer(HighBig,0,0,3,_HighBig);
   
   int bars = iBars(_Symbol,Timeframe);
   if(totalBars != bars){
      totalBars = bars;
      
      if(SLL==0 &&ss==0&&buyPos <= 0&& _HighBig[2]> _HighBig[1]
      ){
         double high = findHigh();
         if(high > 0){
           // executeBuy(high);
             executeSell(high);
         }
      }
      
      if(BLL==0 && bs==0&& sellPos <= 0&&  _HighBig[2] < _HighBig[1] 
       ){
         double low = findLow();
         if(low > 0){
         executeBuy(low);
           // executeSell(low);
         }
      }
   }
}

void  OnTradeTransaction(
   const MqlTradeTransaction&    trans,
   const MqlTradeRequest&        request,
   const MqlTradeResult&         result
   ){
   
   if(trans.type == TRADE_TRANSACTION_ORDER_ADD){
      COrderInfo order;
      if(order.Select(trans.order)){
         if(order.Magic() == Magic){
            if(order.OrderType() == ORDER_TYPE_BUY_STOP){
               buyPos = order.Ticket();
            }else if(order.OrderType() == ORDER_TYPE_SELL_STOP){
               sellPos = order.Ticket();
            }
         }
      }
   }
}

void processPos(ulong &posTicket){
   if(posTicket <= 0) return;
   if(OrderSelect(posTicket)) return;
   
   CPositionInfo pos;
   if(!pos.SelectByTicket(posTicket)){
      posTicket = 0;
      return;
   }else{
      if(pos.PositionType() == POSITION_TYPE_BUY){
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         
         if(bid > pos.PriceOpen() + TslTriggerPoints * _Point){
            double sl = bid - TslPoints * _Point;
            sl = NormalizeDouble(sl,_Digits);
            
            if(sl > pos.StopLoss()){
               trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
            }
         }
      }else if(pos.PositionType() == POSITION_TYPE_SELL){
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         
         if(ask < pos.PriceOpen() - TslTriggerPoints * _Point){
            double sl = ask + TslPoints * _Point;
            sl = NormalizeDouble(sl,_Digits);
            
            if(sl < pos.StopLoss() || pos.StopLoss() == 0){
               trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
            }
         }
      }
   }
}

void executeBuy(double entry){
   entry = NormalizeDouble(entry,_Digits);
   
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(ask > entry + OrderDistPoints * _Point) return;
   
   double tp = entry + TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   
   double sl = entry - SlPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);

   double lots = Lots;
   if(RiskPercent > 0) lots = calcLots(entry-sl);
   
   datetime expiration = iTime(_Symbol,Timeframe,0) + ExpirationHours * PeriodSeconds(PERIOD_H1);


    trade.BuyLimit(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiration,"BuyStop EuroUsdM5");
   buyPos = trade.ResultOrder();
}

void executeSell(double entry){
   entry = NormalizeDouble(entry,_Digits);  

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(bid < entry - OrderDistPoints * _Point) return;

   double tp = entry - TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   
   double sl = entry + SlPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);
   
   double lots = Lots;
   if(RiskPercent > 0) lots = calcLots(sl-entry);
  
   datetime expiration = iTime(_Symbol,Timeframe,0) + ExpirationHours * PeriodSeconds(PERIOD_H1);

  // trade.SellStop(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiration);
    trade.SellLimit(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiration,"SellStop EuroUsdM5");
   
   sellPos = trade.ResultOrder();
}

double calcLots(double slPoints){
   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
   
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep;   
   double lots = MathFloor(risk / moneyPerLotstep) * lotstep;
   
   lots = MathMin(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   lots = MathMax(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   
   return lots;
}

double findHigh(){
   double highestHigh = 0;
   for(int i = 0; i < 200; i++){
      double high = iHigh(_Symbol,Timeframe,i);
      if(i > BarsN && iHighest(_Symbol,Timeframe,MODE_HIGH,BarsN*2+1,i-BarsN) == i){
         if(high > highestHigh){
          double price = high;
   string name = "High";
   int draw_style = DRAW_LINE;
   int line_color = clrPurple;
   int line_width = 5;
   datetime time1 = iTime(_Symbol, Timeframe, 0);
   datetime time2 = TimeCurrent();
   int shift = iBarShift(_Symbol,Timeframe, time1);
    if(!ObjectCreate(0,name,OBJ_HLINE, 0, time1, price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать горизонтальную линию! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
  // ObjectCreate(name, OBJ_HLINE, 0, time1, price);
   ObjectSetInteger(0,name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0,name, OBJPROP_STYLE, draw_style);
   ObjectSetInteger(0,name, OBJPROP_WIDTH, line_width);
   
            return high;
         }
      }
      highestHigh = MathMax(high,highestHigh);
   }
   return -1;
}

double findLow(){
   double lowestLow = DBL_MAX;
   for(int i = 0; i < 200; i++){
      double low = iLow(_Symbol,Timeframe,i);
      if(i > BarsN && iLowest(_Symbol,Timeframe,MODE_LOW,BarsN*2+1,i-BarsN) == i){
         if(low < lowestLow){
         double price = low;
         string name = "LOW";
   int draw_style = DRAW_LINE;
   int line_color = clrAqua;
   int line_width = 5;
   datetime time1 = iTime(_Symbol, Timeframe, 0);
   datetime time2 = TimeCurrent();
   int shift = iBarShift(_Symbol,Timeframe, time1);
    if(!ObjectCreate(0,name,OBJ_HLINE, 0, time1, price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать горизонтальную линию! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
  // ObjectCreate(name, OBJ_HLINE, 0, time1, price);
   ObjectSetInteger(0,name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0,name, OBJPROP_STYLE, draw_style);
   ObjectSetInteger(0,name, OBJPROP_WIDTH, line_width);
   
            return low;
         }
      }   
      lowestLow = MathMin(low,lowestLow);
   }
   return -1;
}