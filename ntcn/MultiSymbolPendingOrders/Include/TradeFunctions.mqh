//--- ����� � �������� ������ ��������
#include "..\MultiSymbolPendingOrders.mq5"
//--- ���������� ���� ����������
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "Errors.mqh"
#include "TradeSignals.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//--- �������� �������
struct position_properties
  {
   uint              total_deals;      // ���������� ������
   bool              exists;           // ������� �������/���������� �������� �������
   string            symbol;           // ������
   long              magic;            // ���������� �����
   string            comment;          // �����������
   double            swap;             // ����
   double            commission;       // ��������   
   double            first_deal_price; // ���� ������ ������ �������
   double            price;            // ������� ���� �������
   double            current_price;    // ������� ���� ������� �������      
   double            last_deal_price;  // ���� ��������� ������ �������
   double            profit;           // �������/������ �������
   double            volume;           // ������� ����� �������
   double            initial_volume;   // ��������� ����� �������
   double            sl;               // Stop Loss �������
   double            tp;               // Take Profit �������
   datetime          time;             // ����� �������� �������
   ulong             duration;         // ������������ ������� � ��������
   long              id;               // ������������� �������
   ENUM_POSITION_TYPE type;             // T�� �������
  };
//--- �������� ����������� ������
struct pending_order_properties
  {
   string            symbol;          // ������
   long              magic;           // ���������� �����
   string            comment;         // �����������
   double            price_open;      // ����, ��������� � ������
   double            price_current;   // ������� ���� �� ������� ������
   double            price_stoplimit; // ���� ���������� Limit ������ ��� ������������ StopLimit ������
   double            volume_initial;  // �������������� ����� ��� ���������� ������
   double            volume_current;  // ������������� �����
   double            sl;              // ������� Stop Loss
   double            tp;              // ������� Take Profit
   datetime          time_setup;      // ����� ���������� ������
   datetime          time_expiration; // ����� ��������� ������
   datetime          time_setup_msc;  // ����� ��������� ������ �� ���������� � ������������� � 01.01.1970
   datetime          type_time;       // ����� ����� ������
   ENUM_ORDER_TYPE   type;            // T�� �������
  };
//--- �������� ������ � �������
struct history_deal_properties
  {
   string            symbol;     // ������
   string            comment;    // �����������
   ENUM_DEAL_TYPE    type;       // ��� ������
   uint              entry;      // �����������
   double            price;      // ����
   double            profit;     // �������/������
   double            volume;     // �����
   double            swap;       // ����
   double            commission; // ��������
   datetime          time;       // �����
  };
//--- �������� �������
struct symbol_properties
  {
   int               digits;           // ���������� ������ � ���� ����� �������
   int               spread;           // ������ ������ � �������
   int               stops_level;      // ������������ ��������� Stop �������
   double            point;            // �������� ������ ������
   double            ask;              // ���� ask
   double            bid;              // ���� bid
   double            volume_min;       // ����������� ����� ��� ���������� ������
   double            volume_max;       // ������������ ����� ��� ���������� ������
   double            volume_limit;     // ����������� ���������� ����� ��� ������� � ������� � ����� �����������
   double            volume_step;      // ����������� ��� ��������� ������ ��� ���������� ������
   double            offset;           // ������ �� ����������� ��������� ���� ��� ��������
   double            up_level;         // ���� �������� ������ stop level
   double            down_level;       // ���� ������� ������ stop level
   ENUM_SYMBOL_TRADE_EXECUTION execution_mode; // ����� ���������� ������
  };
//--- ���������� ������� �������, ������, ������ � �������
position_properties      pos;
pending_order_properties ord;
history_deal_properties  deal;
symbol_properties        symb;
//+------------------------------------------------------------------+
//| �������� ����                                                    |
//+------------------------------------------------------------------+
void TradingBlock(int symbol_number)
  {
   double          tp=0.0;                 // Take Profit
   double          sl=0.0;                 // Stop Loss
   double          lot=0.0;                // ����� ��� ������� ������� � ������ ���������� �������
   double          order_price=0.0;        // ���� ��� ��������� ������
   ENUM_ORDER_TYPE order_type=WRONG_VALUE; // ��� ������ ��� �������� �������
//--- ���� ��� ���������� ���������
//    ��� ��������� ���������� �������
   if(!CheckTimeOpenOrders(symbol_number))
      return;
//--- ������, ���� �� �������
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- ���� ������� ���
   if(!pos.exists)
     {
      //--- ������� �������� �������
      GetSymbolProperties(symbol_number,S_ALL);
      //--- ������������� �����
      lot=CalculateLot(symbol_number,Lot[symbol_number]);
      //--- ���� ��� �������� ����������� ������
      if(!CheckExistPendingOrderByComment(symbol_number,comment_top_order))
        {
         //--- ������� ���� ��� ��������� ����������� ������
         order_price=CalculatePendingOrder(symbol_number,ORDER_TYPE_BUY_STOP);
         //--- ������� ������ Take Profit � Stop Loss
         sl=CalculateOrderStopLoss(symbol_number,ORDER_TYPE_BUY_STOP,order_price);
         tp=CalculateOrderTakeProfit(symbol_number,ORDER_TYPE_BUY_STOP,order_price);
         //--- ��������� ���������� �����
         SetPendingOrder(symbol_number,ORDER_TYPE_BUY_STOP,lot,0,order_price,sl,tp,ORDER_TIME_GTC,comment_top_order);
        }
      //--- ���� ��� ������� ����������� ������
      if(!CheckExistPendingOrderByComment(symbol_number,comment_bottom_order))
        {
         //--- ������� ���� ��� ��������� ����������� ������
         order_price=CalculatePendingOrder(symbol_number,ORDER_TYPE_SELL_STOP);
         //--- ������� ������ Take Profit � Stop Loss
         sl=CalculateOrderStopLoss(symbol_number,ORDER_TYPE_SELL_STOP,order_price);
         tp=CalculateOrderTakeProfit(symbol_number,ORDER_TYPE_SELL_STOP,order_price);
         //--- ��������� ���������� �����
         SetPendingOrder(symbol_number,ORDER_TYPE_SELL_STOP,lot,0,order_price,sl,tp,ORDER_TIME_GTC,comment_bottom_order);
        }
     }
  }
//+------------------------------------------------------------------+
//| ��������� �������                                                |
//+------------------------------------------------------------------+
void OpenPosition(int             symbol_number, // ����� �������
                  ENUM_ORDER_TYPE order_type,    // ��� ������
                  double          lot,           // �����
                  double          price,         // ����
                  double          sl,            // ���� ����
                  double          tp,            // ���� ������
                  string          comment)       // �����������
  {
//--- ��������� ����� ������� � �������� ���������
   trade.SetExpertMagicNumber(MagicNumber);
//--- ��������� ������ ��������������� � �������
   trade.SetDeviationInPoints(CorrectValueBySymbolDigits(Deviation));
//--- ����� Instant Execution � Market Execution
//    *** ������� � 803 �����, ������ Stop Loss � Take Profit                             ***
//    *** ����� ������������� ��� �������� ������� � ������ SYMBOL_TRADE_EXECUTION_MARKET ***
   if(symb.execution_mode==SYMBOL_TRADE_EXECUTION_INSTANT ||
      symb.execution_mode==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      //--- ���� ������� �� ���������, ������� ��������� �� ����
      if(!trade.PositionOpen(Symbols[symbol_number],order_type,lot,price,sl,tp,comment))
         Print("������ ��� �������� �������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| ��������� �������                                                |
//+------------------------------------------------------------------+
void ClosePosition(int symbol_number)
  {
//--- ������, ���� �� �������  
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- ���� ������� ���, �������
   if(!pos.exists)
      return;
//--- ��������� ������ ��������������� � �������
   trade.SetDeviationInPoints(CorrectValueBySymbolDigits(Deviation));
//--- ���� ������� �� ���������, ������� ��������� �� ����
   if(!trade.PositionClose(Symbols[symbol_number]))
      Print("������ ��� �������� �������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
  }
//+------------------------------------------------------------------+
//| ������������� ���������� �����                                   |
//+------------------------------------------------------------------+
void SetPendingOrder(int                  symbol_number,   // ����� �������
                     ENUM_ORDER_TYPE      order_type,      // ��� ������
                     double               lot,             // �����
                     double               price_stoplimit, // ������� StopLimit ������
                     double               price,           // ����
                     double               sl,              // ���� ����
                     double               tp,              // ���� ������
                     ENUM_ORDER_TYPE_TIME type_time,       // ���� �������� ������
                     string               comment)         // �����������
  {
//--- ��������� ����� ������� � �������� ���������
   trade.SetExpertMagicNumber(MagicNumber);
//--- ���� ���������� ����� ���������� �� �������, ������� ��������� �� ����
   if(!trade.OrderOpen(Symbols[symbol_number],
      order_type,lot,price_stoplimit,price,sl,tp,type_time,0,comment))
      Print("������ ��� ��������� ����������� ������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
  }
//+------------------------------------------------------------------+
//| �������� ���������� �����                                        |
//+------------------------------------------------------------------+
void ModifyPendingOrder(int                  symbol_number,   // ����� �������
                        ulong                ticket,          // ����� ������
                        ENUM_ORDER_TYPE      type,            // ��� ������
                        double               price,           // ���� ������
                        double               sl,              // ���� ���� ������
                        double               tp,              // ���� ������ ������
                        ENUM_ORDER_TYPE_TIME type_time,       // ���� �������� ������
                        datetime             time_expiration, // ����� ��������� ������
                        double               price_stoplimit, // ����
                        string               comment,         // �����������
                        double               volume)          // �����
  {
//--- ���� ������� �� ������� �����, ������������� �����
   if(volume>0)
     {
      //--- ���� �� ������� ������� �����, ������
      if(!DeletePendingOrder(ticket))
         return;
      //--- ��������� ���������� �����
      SetPendingOrder(symbol_number,type,volume,0,price,sl,tp,type_time,comment);
      //--- ������������� Stop Loss ������� ������������ ������
      CorrectStopLossByOrder(symbol_number,price,type);
     }
//--- ���� ������� ������� �����, ������������ �����
   else
     {
      //--- ���� ���������� ����� �������� �� �������, ������� ��������� �� ����
      if(!trade.OrderModify(ticket,price,sl,tp,type_time,time_expiration,price_stoplimit))
         Print("������ ��� ��������� ���� ����������� ������: ",
               GetLastError()," - ",ErrorDescription(GetLastError()));
      //--- ����� ������������� Stop Loss ������� ������������ ������
      else
         CorrectStopLossByOrder(symbol_number,price,type);
     }
  }
//+------------------------------------------------------------------+
//| ������� ���������� �����                                         |
//+------------------------------------------------------------------+
bool DeletePendingOrder(ulong ticket)
  {
//--- ���� ���������� ����� ������� �� �������, ������� ��������� �� ����
   if(!trade.OrderDelete(ticket))
     {
      Print("������ ��� �������� ����������� ������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ������������ Stop Loss ������� ������������ ����������� ������   |
//+------------------------------------------------------------------+
void CorrectStopLossByOrder(int             symbol_number, // ����� �������
                            double          price,         // ���� ������
                            ENUM_ORDER_TYPE type)          // ��� ������
  {
//--- ���� Stop Loss ��������, ������
   if(StopLoss[symbol_number]==0)
      return;
//--- ���� Stop Loss �������
   double new_sl=0.0; // ����� �������� ��� Stop Loss
//--- ������� �������� ������ ������ �
   GetSymbolProperties(symbol_number,S_POINT);
//--- ���������� ������ � ���� ����� �������
   GetSymbolProperties(symbol_number,S_DIGITS);
//--- ������� Take Profit �������
   GetPositionProperties(symbol_number,P_TP);
//--- ���������� ������������ ���� ������
   switch(type)
     {
      case ORDER_TYPE_BUY_STOP  :
         new_sl=NormalizeDouble(price+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         break;
      case ORDER_TYPE_SELL_STOP :
         new_sl=NormalizeDouble(price-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         break;
     }
//--- ������������ �������
   if(!trade.PositionModify(Symbols[symbol_number],new_sl,pos.tp))
      Print("������ ��� ����������� �������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
  }
//+------------------------------------------------------------------+
//| ��������� ������������� ����������� ������ �� �����������        |
//+------------------------------------------------------------------+
bool CheckExistPendingOrderByComment(int symbol_number,string comment)
  {
   int    total_orders  =0;  // ����� ���������� ���������� �������
   string symbol_order  =""; // ������ ������
   string comment_order =""; // ����������� ������
//--- ������� ���������� ���������� �������
   total_orders=OrdersTotal();
//--- �������� � ����� �� ���� �������
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- ������� ����� �� ������
      if(OrderGetTicket(i)>0)
        {
         //--- ������� ��� �������
         symbol_order=OrderGetString(ORDER_SYMBOL);
         //--- ���� ������� �����
         if(symbol_order==Symbols[symbol_number])
           {
            //--- ������� ����������� ������
            comment_order=OrderGetString(ORDER_COMMENT);
            //--- ���� ����������� ���������
            if(comment_order==comment)
               return(true);
           }
        }
     }
//--- ����� � ��������� ������������ �� ������
   return(false);
  }
//+------------------------------------------------------------------+
//| ���������� ����������� ��������                                  |
//+------------------------------------------------------------------+
void ManagementPendingOrders()
  {
//--- �������� � ����� �� ���� ��������
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- ���� �������� �� ����� ������� �� ���������,
      //    ������� � ����������
      if(Symbols[s]=="")
         continue;
      //--- ������, ���� �� �������
      pos.exists=PositionSelect(Symbols[s]);
      //--- ���� ������� ���
      if(!pos.exists)
        {
         //--- ���� ��������� ������ ����� �
         //    ����� �� ������� ��� �� Take Profit ��� Stop Loss
         if(GetEventLastDealTicket(s) && 
            (GetEventStopLoss(s) || GetEventTakeProfit(s)))
            //--- ������ ��� ���������� ������ �� �������
            DeleteAllPendingOrders(s);
         //--- ������� � ���������� �������
         continue;
        }
      //--- ���� ������� ����
      ulong           order_ticket           =0;           // ����� ������
      int             total_orders           =0;           // ����� ���������� ���������� �������
      int             symbol_total_orders    =0;           // ���������� ���������� ������� �� ��������� �������
      string          opposite_order_comment ="";          // ����������� ���������������� ������
      ENUM_ORDER_TYPE opposite_order_type    =WRONG_VALUE; // ��� ������
      //--- ������� ����� ���������� ���������� �������
      total_orders=OrdersTotal();
      //--- ������� ���������� ���������� ������� �� ��������� �������
      symbol_total_orders=OrdersTotalBySymbol(Symbols[s]);
      //--- ������� �������� �������
      GetSymbolProperties(s,S_ASK);
      GetSymbolProperties(s,S_BID);
      //--- ������� ����������� ��������� �������
      GetPositionProperties(s,P_COMMENT);
      //--- ���� ����������� ������� �� �������� ������,
      //    ������ ����� �������/��������/���������� ������ �����
      if(pos.comment==comment_top_order)
        {
         opposite_order_type    =ORDER_TYPE_SELL_STOP;
         opposite_order_comment =comment_bottom_order;
        }
      //--- ���� ����������� ������� �� ������� ������,
      //    ������ ����� �������/��������/���������� ������� �����
      if(pos.comment==comment_bottom_order)
        {
         opposite_order_type    =ORDER_TYPE_BUY_STOP;
         opposite_order_comment =comment_top_order;
        }
      //--- ���� ���������� ������� �� ���� ������� ���
      if(symbol_total_orders==0)
        {
         //--- ���� ��������� ������� �������, ��������� ��������������� �����
         if(Reverse[s])
           {
            double tp=0.0;          // Take Profit
            double sl=0.0;          // Stop Loss
            double lot=0.0;         // ����� ��� ������� ������� � ������ ���������� �������
            double order_price=0.0; // ���� ��� ��������� ������
            //--- ������� ���� ��� ��������� ����������� ������
            order_price=CalculatePendingOrder(s,opposite_order_type);
            //--- ������� ������ Take Profit � Stop Loss
            sl=CalculateOrderStopLoss(s,opposite_order_type,order_price);
            tp=CalculateOrderTakeProfit(s,opposite_order_type,order_price);
            //--- ��������� ������� �����
            lot=CalculateLot(s,pos.volume*2);
            //--- ��������� ���������� �����
            SetPendingOrder(s,opposite_order_type,lot,0,order_price,sl,tp,ORDER_TIME_GTC,opposite_order_comment);
            //--- ������������� Stop Loss ������������ ������
            CorrectStopLossByOrder(s,order_price,opposite_order_type);
           }
         return;
        }
      //--- ���� ���������� ������ �� ���� ������� ����, ��
      //    � ����������� �� ������� ������ ���
      //    ������������ ��������������� ���������� �����
      if(symbol_total_orders>0)
        {
         //--- �������� � ����� �� ���� ������� �� ���������� � �������
         for(int i=total_orders-1; i>=0; i--)
           {
            //--- ���� ����� ������
            if((order_ticket=OrderGetTicket(i))>0)
              {
               //--- ������� ������ ������
               GetOrderProperties(O_SYMBOL);
               //--- ������� ����������� ������
               GetOrderProperties(O_COMMENT);
               //--- ���� ������ ������ � ������� ��������� �
               //    ����������� ���������������� ������, ��
               if(ord.symbol==Symbols[s] && 
                  ord.comment==opposite_order_comment)
                 {
                  //--- ���� ��������� ������� ��������
                  if(!Reverse[s])
                     //--- ������ �����
                     DeletePendingOrder(order_ticket);
                  //--- ���� ��������� ������� �������
                  else
                    {
                     double lot=0.0;
                     //--- ������� �������� �������� ������
                     GetOrderProperties(O_ALL);
                     //--- ������� ����� ������� �������
                     GetPositionProperties(s,P_VOLUME);
                     //--- ���� ����� ��� ��� ������, ������ �� �����
                     if(ord.volume_initial>pos.volume)
                        break;
                     //--- ��������� ������� �����
                     lot=CalculateLot(s,pos.volume*2);
                     //--- �������� (��������������) �����
                     ModifyPendingOrder(s,order_ticket,opposite_order_type,
                                        ord.price_open,ord.sl,ord.tp,
                                        ORDER_TIME_GTC,ord.time_expiration,
                                        ord.price_stoplimit,opposite_order_comment,lot);
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| ������� ��� ���������� ������                                    |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders(int symbol_number)
  {
   int   total_orders =0; // ���������� ���������� �������
   ulong order_ticket =0; // ����� ������
//--- ������� ���������� ���������� �������
   total_orders=OrdersTotal();
//--- �������� � ����� �� ���� �������
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- ���� ����� ������
      if((order_ticket=OrderGetTicket(i))>0)
        {
         //--- ������� ������ ������
         GetOrderProperties(O_SYMBOL);
         //--- ���� ������ ������ � ������� ������ ���������
         if(ord.symbol==Symbols[symbol_number])
            //--- ������ �����
            DeletePendingOrder(order_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//| ���������� ���������� ������� �� ��������� �������               |
//+------------------------------------------------------------------+
int OrdersTotalBySymbol(string symbol)
  {
   int   count        =0; // ������� �������
   int   total_orders =0; // ���������� ���������� �������
//--- ������� ���������� ���������� �������
   total_orders=OrdersTotal();
//--- �������� � ����� �� ���� �������
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- ���� ����� ������
      if(OrderGetTicket(i)>0)
        {
         //--- ������� ������ ������
         GetOrderProperties(O_SYMBOL);
         //--- ���� ������ ������ � ��������� ������ ���������
         if(ord.symbol==symbol)
            //--- �������� �������
            count++;
        }
     }
//--- ����� ���������� �������
   return(count);
  }
//+------------------------------------------------------------------+
//| ������������ ����� ��� �������/����������� ������                |
//+------------------------------------------------------------------+
double CalculateLot(int symbol_number,double lot)
  {
//--- ��� ������������� � ������ ����
   double corrected_lot=0.0;
//---
   GetSymbolProperties(symbol_number,S_VOLUME_MIN);  // ������� ���������� ��������� ���
   GetSymbolProperties(symbol_number,S_VOLUME_MAX);  // ������� ����������� ��������� ���
   GetSymbolProperties(symbol_number,S_VOLUME_STEP); // ������� ��� ����������/���������� ����
//--- ������������� � ������ ���� ����
   corrected_lot=MathRound(lot/symb.volume_step)*symb.volume_step;
//--- ���� ������ ������������, ������ �����������
   if(corrected_lot<symb.volume_min)
      return(NormalizeDouble(symb.volume_min,2));
//--- ���� ������ �������������, ������ ������������
   if(corrected_lot>symb.volume_max)
      return(NormalizeDouble(symb.volume_max,2));
//---
   return(NormalizeDouble(corrected_lot,2));
  }
//+------------------------------------------------------------------+
//| ������������ ������� (����) ����������� ������                   |
//+------------------------------------------------------------------+
double CalculatePendingOrder(int symbol_number,ENUM_ORDER_TYPE order_type)
  {
//--- ��� ������������� �������� Pending Order
   double price=0.0;
//--- ���� ����� ���������� �������� ��� ������ SELL STOP
   if(order_type==ORDER_TYPE_SELL_STOP)
     {
      //--- ���������� �������
      price=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- ������ ������������ ��������, ���� ��� ���� ������ ������� stops level
      //    ���� �������� ���� ��� �����, ������ ����������������� ��������
      return(price<symb.down_level ? price : symb.down_level-symb.offset);
     }
//--- ���� ����� ���������� �������� ��� ������ BUY STOP
   if(order_type==ORDER_TYPE_BUY_STOP)
     {
      //--- ���������� �������
      price=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- ������ ������������ ��������, ���� ��� ���� ������� ������� stops level
      //    ���� �������� ���� ��� �����, ������ ����������������� ��������
      return(price>symb.up_level ? price : symb.up_level+symb.offset);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| ������������ ������� Take Profit ��� ����������� ������          |
//+------------------------------------------------------------------+
double CalculateOrderTakeProfit(int symbol_number,ENUM_ORDER_TYPE order_type,double price)
  {
//--- ���� Take Profit �����
   if(TakeProfit[symbol_number]>0)
     {
      double tp         =0.0; // ��� ������������� �������� Take Profit
      double up_level   =0.0; // ������� ������� Stop Levels
      double down_level =0.0; // ������ ������� Stop Levels
      //--- ���� ����� ���������� �������� ��� ������ SELL STOP
      if(order_type==ORDER_TYPE_SELL_STOP)
        {
         //--- ��������� ������ �����
         down_level=NormalizeDouble(price-symb.stops_level*symb.point,symb.digits);
         //--- ���������� �������
         tp=NormalizeDouble(price-CorrectValueBySymbolDigits(TakeProfit[symbol_number]*symb.point),symb.digits);
         //--- ������ ������������ ��������, ���� ��� ���� ������ ������� stops level
         //    ���� �������� ���� ��� �����, ������ ����������������� ��������
         return(tp<down_level ? tp : NormalizeDouble(down_level-symb.offset,symb.digits));
        }
      //--- ���� ����� ���������� �������� ��� ������ BUY STOP
      if(order_type==ORDER_TYPE_BUY_STOP)
        {
         //--- ��������� ������� �����
         up_level=NormalizeDouble(price+symb.stops_level*symb.point,symb.digits);
         //--- ���������� �������
         tp=NormalizeDouble(price+CorrectValueBySymbolDigits(TakeProfit[symbol_number]*symb.point),symb.digits);
         //--- ������ ������������ ��������, ���� ��� ���� ������� ������� stops level
         //    ���� �������� ���� ��� �����, ������ ����������������� ��������
         return(tp>up_level ? tp : NormalizeDouble(up_level+symb.offset,symb.digits));
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| ������������ ������� Stop Loss ��� ����������� ������            |
//+------------------------------------------------------------------+
double CalculateOrderStopLoss(int symbol_number,ENUM_ORDER_TYPE order_type,double price)
  {
//--- ���� Stop Loss �����
   if(StopLoss[symbol_number]>0)
     {
      double sl         =0.0; // ��� ������������� �������� Stop Loss
      double up_level   =0.0; // ������� ������� Stop Levels
      double down_level =0.0; // ������ ������� Stop Levels
      //--- ���� ����� ���������� �������� ��� ������ BUY STOP
      if(order_type==ORDER_TYPE_BUY_STOP)
        {
         //--- ��������� ������ �����
         down_level=NormalizeDouble(price-symb.stops_level*symb.point,symb.digits);
         //--- ���������� �������
         sl=NormalizeDouble(price-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- ������ ������������ ��������, ���� ��� ���� ������ ������� stops level
         //    ���� �������� ���� ��� �����, ������ ����������������� ��������
         return(sl<down_level ? sl : NormalizeDouble(down_level-symb.offset,symb.digits));
        }
      //--- ���� ����� ���������� �������� ��� ������ SELL STOP
      if(order_type==ORDER_TYPE_SELL_STOP)
        {
         //--- ��������� ������� �����
         up_level=NormalizeDouble(price+symb.stops_level*symb.point,symb.digits);
         //--- ���������� �������
         sl=NormalizeDouble(price+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- ������ ������������ ��������, ���� ��� ���� ������� ������� stops level
         //    ���� �������� ���� ��� �����, ������ ����������������� ��������
         return(sl>up_level ? sl : NormalizeDouble(up_level+symb.offset,symb.digits));
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| ������������ ������� Trailing Stop                               |
//+------------------------------------------------------------------+
double CalculateTrailingStop(int symbol_number,ENUM_POSITION_TYPE position_type)
  {
//--- ���������� ��� ��������
   double    level       =0.0;
   double    buy_point   =low[symbol_number].value[1];  // �������� Low ��� Buy
   double    sell_point  =high[symbol_number].value[1]; // �������� High ��� Sell
//--- ���������� ������� ��� ������� BUY
   if(position_type==POSITION_TYPE_BUY)
     {
      //--- ������� ���� ����� ��������� ���������� �������
      level=NormalizeDouble(buy_point-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
      //--- ���� ������������ ������� ����, ��� ������ ������� ����������� (stops level), 
      //    �� ������ ��������, ������ ������� �������� ������
      if(level<symb.down_level)
         return(level);
      //--- ���� �� �� ����, �� ��������� ���������� �� ���� bid
      else
        {
         level=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- ���� ������������ ������� ���� ������������, ������ ������� �������� ������
         //    ����� ��������� ����������� ��������� �������
         return(level<symb.down_level ? level : symb.down_level-symb.offset);
        }
     }
//--- ���������� ������� ��� ������� SELL
   if(position_type==POSITION_TYPE_SELL)
     {
      // �������� ���� ���� ��������� ���-�� �������
      level=NormalizeDouble(sell_point+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
      //--- ���� ������������ ������� ����, ��� ������� ������� ����������� (stops level), 
      //    �� ������ ��������, ������ ������� �������� ������
      if(level>symb.up_level)
         return(level);
      //--- ���� �� �� ����, �� ��������� ���������� �� ���� ask
      else
        {
         level=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- ���� ������������ ������� ���� ������������, ������ ������� �������� ������
         //    ����� ��������� ����������� ��������� �������
         return(level>symb.up_level ? level : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| ������������ ������� Trailing Reverse Order                      |
//+------------------------------------------------------------------+
double CalculateTrailingReverseOrder(int symbol_number,ENUM_POSITION_TYPE position_type)
  {
//--- ���������� ��� ��������
   double    level       =0.0;
   double    buy_point   =low[symbol_number].value[1];  // �������� Low ��� Buy
   double    sell_point  =high[symbol_number].value[1]; // �������� High ��� Sell
//--- ���������� ������� ��� ������� BUY
   if(position_type==POSITION_TYPE_BUY)
     {
      //--- ������� ���� ����� ��������� ���������� �������
      level=NormalizeDouble(buy_point-CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- ���� ������������ ������� ����, ��� ������ ������� ����������� (stops level), 
      //    �� ������ ��������, ������ ������� �������� ������
      if(level<symb.down_level)
         return(level);
      //--- ���� �� �� ����, �� ��������� ���������� �� ���� bid
      else
        {
         level=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
         //--- ���� ������������ ������� ���� ������������, ������ ������� �������� ������
         //    ����� ��������� ����������� ��������� �������
         return(level<symb.down_level ? level : symb.down_level-symb.offset);
        }
     }
//--- ���������� ������� ��� ������� SELL
   if(position_type==POSITION_TYPE_SELL)
     {
      // �������� ���� ���� ��������� ���-�� �������
      level=NormalizeDouble(sell_point+CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- ���� ������������ ������� ����, ��� ������� ������� ����������� (stops level), 
      //    �� ������ ��������, ������ ������� �������� ������
      if(level>symb.up_level)
         return(level);
      //--- ���� �� �� ����, �� ��������� ���������� �� ���� ask
      else
        {
         level=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
         //--- ���� ������������ ������� ���� ������������, ������ ������� �������� ������
         //    ����� ��������� ����������� ��������� �������
         return(level>symb.up_level ? level : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| �������� ������� Trailing Stop                                   |
//+------------------------------------------------------------------+
void ModifyTrailingStop(int symbol_number)
  {
//--- ���� �������� �������� ��� StopLoss, ������
   if(TrailingStop[symbol_number]==0 || StopLoss[symbol_number]==0)
      return;
//--- ���� ������� �������� � StopLoss
   double new_sl    =0.0;   // ��� ������� ������ ������ Stop loss
   bool   condition =false; // ��� �������� ������� �� �����������
//--- ������� ���� �������/���������� �������
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- ���� ��� �������
   if(!pos.exists)
      return;
//--- ������� �������� �������
   GetSymbolProperties(symbol_number,S_ALL);
//--- ������� �������� �������
   GetPositionProperties(symbol_number,P_ALL);
//--- ������� ������� ��� Stop Loss
   new_sl=CalculateTrailingStop(symbol_number,pos.type);
//--- � ����������� �� ���� ������� �������� ��������������� ������� �� ����������� Trailing Stop
   switch(pos.type)
     {
      case POSITION_TYPE_BUY  :
         //--- ���� ����� �������� ��� Stop Loss ����,
         //    ��� ������� �������� ���� ������������� ���
         condition=new_sl>pos.sl+CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
         break;
      case POSITION_TYPE_SELL :
         //--- ���� ����� �������� ��� Stop Loss ����,
         //    ��� ������� �������� ����� ������������� ���
         condition=new_sl<pos.sl-CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
         break;
     }
//--- ���� Stop Loss ����, �� ������� �������� ����� ������������
   if(pos.sl>0)
     {
      //--- ���� ����������� ������� �� ����������� ������, �.�. ����� �������� ����/����, 
      //    ��� �������, ������������ �������� ������� �������
      if(condition)
        {
         if(!trade.PositionModify(Symbols[symbol_number],new_sl,pos.tp))
            Print("������ ��� ����������� �������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
        }
     }
//--- ���� Stop Loss ���, �� ������ ��������� ���
   if(pos.sl==0)
     {
      if(!trade.PositionModify(Symbols[symbol_number],new_sl,pos.tp))
         Print("������ ��� ����������� �������: ",GetLastError()," - ",ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| �������� ������� Trailing Pending Order                          |
//+------------------------------------------------------------------+
void ModifyTrailingPendingOrder(int symbol_number)
  {
//--- ���� ��������� ������� �������� ���
//    Trailing Stop ��������, ������
   if(!Reverse[symbol_number] || TrailingStop[symbol_number]==0)
      return;
//--- ���� ��������� ������� ������� ��� Trailing Stop �������
   double          new_level              =0.0;         // ��� ������� ������ ������ ����������� ������
   bool            condition              =false;       // ��� �������� ������� �� �����������
   int             total_orders           =0;           // ����� ���������� ���������� �������
   ulong           order_ticket           =0;           // ����� ������
   string          opposite_order_comment ="";          // ����������� ���������������� ������
   ENUM_ORDER_TYPE opposite_order_type    =WRONG_VALUE; // ��� ������

//--- ������� ���� �������/���������� �������
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- ���� ��� �������
   if(!pos.exists)
      return;
//--- ������� ���������� ���������� �������
   total_orders=OrdersTotal();
//--- ������� �������� �������
   GetSymbolProperties(symbol_number,S_ALL);
//--- ������� �������� �������
   GetPositionProperties(symbol_number,P_ALL);
//--- ������� ������� ��� Stop Loss
   new_level=CalculateTrailingReverseOrder(symbol_number,pos.type);
//--- �������� � ����� �� ���� ������� �� ���������� � �������
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- ���� ����� ������
      if((order_ticket=OrderGetTicket(i))>0)
        {
         //--- ������� ������ ������
         GetOrderProperties(O_SYMBOL);
         //--- ������� ����������� ������
         GetOrderProperties(O_COMMENT);
         //--- ������� ���� ������
         GetOrderProperties(O_PRICE_OPEN);
         //--- � ����������� �� ���� �������
         //    �������� ��������������� ������� �� ����������� Trailing Stop
         switch(pos.type)
           {
            case POSITION_TYPE_BUY  :
               //--- ���� ����� �������� ��� ������ ����,
               //    ��� ������� �������� ���� ������������� ���, �� ������� ���������
               condition=
               new_level>ord.price_open+CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
               //--- ��������� ��� � ����������� ���������������� ����������� ������ ��� ��������
               opposite_order_type    =ORDER_TYPE_SELL_STOP;
               opposite_order_comment =comment_bottom_order;
               break;
            case POSITION_TYPE_SELL :
               //--- ���� ����� �������� ��� ������ ����,
               //    ��� ������� �������� ����� ������������� ���, �� ������� ���������
               condition=
               new_level<ord.price_open-CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
               //--- ��������� ��� � ����������� ���������������� ����������� ������ ��� ��������
               opposite_order_type    =ORDER_TYPE_BUY_STOP;
               opposite_order_comment =comment_top_order;
               break;
           }
         //--- ���� ������� ����������� � 
         //    ������ ������ � ������� ��������� �
         //    ����������� ���������������� ������, ��
         if(condition && 
            ord.symbol==Symbols[symbol_number] && 
            ord.comment==opposite_order_comment)
           {
            double sl=0.0; // ���� ����
            double tp=0.0; // ���� ������
            //--- ������� ������ Take Profit � Stop Loss
            sl=CalculateOrderStopLoss(symbol_number,opposite_order_type,new_level);
            tp=CalculateOrderTakeProfit(symbol_number,opposite_order_type,new_level);
            //--- �������� �����
            ModifyPendingOrder(symbol_number,order_ticket,opposite_order_type,new_level,sl,tp,
                               ORDER_TIME_GTC,ord.time_expiration,ord.price_stoplimit,ord.comment,0);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| �������� ���������� ������� �������                              |
//+------------------------------------------------------------------+
void ZeroPositionProperties()
  {
   pos.symbol       ="";
   pos.exists       =false;
   pos.comment      ="";
   pos.magic        =0;
   pos.price        =0.0;
   pos.current_price=0.0;
   pos.sl           =0.0;
   pos.tp           =0.0;
   pos.type         =WRONG_VALUE;
   pos.volume       =0.0;
   pos.commission   =0.0;
   pos.swap         =0.0;
   pos.profit       =0.0;
   pos.time         =NULL;
   pos.id           =0;
  }
//+------------------------------------------------------------------+
//| �������� �������� �������                                        |
//+------------------------------------------------------------------+
void GetPositionProperties(int symbol_number,ENUM_POSITION_PROPERTIES position_property)
  {
//--- ������, ���� �� �������
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- ���� ������� ����, ������� � ��������
   if(pos.exists)
     {
      switch(position_property)
        {
         case P_TOTAL_DEALS      :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.total_deals=CurrentPositionTotalDeals(symbol_number);                              break;
         case P_SYMBOL           : pos.symbol=PositionGetString(POSITION_SYMBOL);                  break;
         case P_MAGIC            : pos.magic=PositionGetInteger(POSITION_MAGIC);                   break;
         case P_COMMENT          : pos.comment=PositionGetString(POSITION_COMMENT);                break;
         case P_SWAP             : pos.swap=PositionGetDouble(POSITION_SWAP);                      break;
         case P_COMMISSION       : pos.commission=PositionGetDouble(POSITION_COMMISSION);          break;
         case P_PRICE_FIRST_DEAL :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.first_deal_price=CurrentPositionFirstDealPrice(symbol_number);                     break;
         case P_PRICE_OPEN       : pos.price=PositionGetDouble(POSITION_PRICE_OPEN);               break;
         case P_PRICE_CURRENT    : pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);    break;
         case P_PRICE_LAST_DEAL  :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.last_deal_price=CurrentPositionLastDealPrice(symbol_number);                       break;
         case P_PROFIT           : pos.profit=PositionGetDouble(POSITION_PROFIT);                  break;
         case P_VOLUME           : pos.volume=PositionGetDouble(POSITION_VOLUME);                  break;
         case P_INITIAL_VOLUME   :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.initial_volume=CurrentPositionInitialVolume(symbol_number);                        break;
         case P_SL               : pos.sl=PositionGetDouble(POSITION_SL);                          break;
         case P_TP               : pos.tp=PositionGetDouble(POSITION_TP);                          break;
         case P_TIME             : pos.time=(datetime)PositionGetInteger(POSITION_TIME);           break;
         case P_DURATION         : pos.duration=CurrentPositionDuration(SECONDS);                  break;
         case P_ID               : pos.id=PositionGetInteger(POSITION_IDENTIFIER);                 break;
         case P_TYPE             : pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); break;
         case P_ALL              :
            pos.symbol=PositionGetString(POSITION_SYMBOL);
            pos.magic=PositionGetInteger(POSITION_MAGIC);
            pos.comment=PositionGetString(POSITION_COMMENT);
            pos.swap=PositionGetDouble(POSITION_SWAP);
            pos.commission=PositionGetDouble(POSITION_COMMISSION);
            pos.price=PositionGetDouble(POSITION_PRICE_OPEN);
            pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);
            pos.profit=PositionGetDouble(POSITION_PROFIT);
            pos.volume=PositionGetDouble(POSITION_VOLUME);
            pos.sl=PositionGetDouble(POSITION_SL);
            pos.tp=PositionGetDouble(POSITION_TP);
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.id=PositionGetInteger(POSITION_IDENTIFIER);
            pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            pos.total_deals=CurrentPositionTotalDeals(symbol_number);
            pos.first_deal_price=CurrentPositionFirstDealPrice(symbol_number);
            pos.last_deal_price=CurrentPositionLastDealPrice(symbol_number);
            pos.initial_volume=CurrentPositionInitialVolume(symbol_number);
            pos.duration=CurrentPositionDuration(SECONDS);                                         break;
            //---
         default: Print("���������� �������� ������� �� ������ � ������������!");                  return;
        }
     }
//--- ���� ������� ���, ������� ���������� ������� �������
   else
      ZeroPositionProperties();
  }
//+------------------------------------------------------------------+
//| �������� �������� �������������� ���������� ������               |
//+------------------------------------------------------------------+
void GetOrderProperties(ENUM_ORDER_PROPERTIES order_property)
  {
   switch(order_property)
     {
      case O_SYMBOL          : ord.symbol=OrderGetString(ORDER_SYMBOL);                              break;
      case O_MAGIC           : ord.magic=OrderGetInteger(ORDER_MAGIC);                               break;
      case O_COMMENT         : ord.comment=OrderGetString(ORDER_COMMENT);                            break;
      case O_PRICE_OPEN      : ord.price_open=OrderGetDouble(ORDER_PRICE_OPEN);                      break;
      case O_PRICE_CURRENT   : ord.price_current=OrderGetDouble(ORDER_PRICE_CURRENT);                break;
      case O_PRICE_STOPLIMIT : ord.price_stoplimit=OrderGetDouble(ORDER_PRICE_STOPLIMIT);            break;
      case O_VOLUME_INITIAL  : ord.volume_initial=OrderGetDouble(ORDER_VOLUME_INITIAL);              break;
      case O_VOLUME_CURRENT  : ord.volume_current=OrderGetDouble(ORDER_VOLUME_CURRENT);              break;
      case O_SL              : ord.sl=OrderGetDouble(ORDER_SL);                                      break;
      case O_TP              : ord.tp=OrderGetDouble(ORDER_TP);                                      break;
      case O_TIME_SETUP      : ord.time_setup=(datetime)OrderGetInteger(ORDER_TIME_SETUP);           break;
      case O_TIME_EXPIRATION : ord.time_expiration=(datetime)OrderGetInteger(ORDER_TIME_EXPIRATION); break;
      case O_TIME_SETUP_MSC  : ord.time_setup_msc=(datetime)OrderGetInteger(ORDER_TIME_SETUP_MSC);   break;
      case O_TYPE_TIME       : ord.type_time=(datetime)OrderGetInteger(ORDER_TYPE_TIME);             break;
      case O_TYPE            : ord.type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);                break;
      case O_ALL             :
         ord.symbol=OrderGetString(ORDER_SYMBOL);
         ord.magic=OrderGetInteger(ORDER_MAGIC);
         ord.comment=OrderGetString(ORDER_COMMENT);
         ord.price_open=OrderGetDouble(ORDER_PRICE_OPEN);
         ord.price_current=OrderGetDouble(ORDER_PRICE_CURRENT);
         ord.price_stoplimit=OrderGetDouble(ORDER_PRICE_STOPLIMIT);
         ord.volume_initial=OrderGetDouble(ORDER_VOLUME_INITIAL);
         ord.volume_current=OrderGetDouble(ORDER_VOLUME_CURRENT);
         ord.sl=OrderGetDouble(ORDER_SL);
         ord.tp=OrderGetDouble(ORDER_TP);
         ord.time_setup=(datetime)OrderGetInteger(ORDER_TIME_SETUP);
         ord.time_expiration=(datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
         ord.time_setup_msc=(datetime)OrderGetInteger(ORDER_TIME_SETUP_MSC);
         ord.type_time=(datetime)OrderGetInteger(ORDER_TYPE_TIME);
         ord.type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);                                      break;
         //---
      default: Print("���������� �������� ����������� ������ �� ������ � ������������!");            return;
     }
  }
//+------------------------------------------------------------------+
//| �������� �������� ������ �� ������                               |
//+------------------------------------------------------------------+
void GetHistoryDealProperties(ulong ticket,ENUM_DEAL_PROPERTIES history_deal_property)
  {
   switch(history_deal_property)
     {
      case D_SYMBOL     : deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);              break;
      case D_COMMENT    : deal.comment=HistoryDealGetString(ticket,DEAL_COMMENT);            break;
      case D_TYPE       : deal.type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE); break;
      case D_ENTRY      : deal.entry=(int)HistoryDealGetInteger(ticket,DEAL_ENTRY);          break;
      case D_PRICE      : deal.price=HistoryDealGetDouble(ticket,DEAL_PRICE);                break;
      case D_PROFIT     : deal.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);              break;
      case D_VOLUME     : deal.volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);              break;
      case D_SWAP       : deal.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);                  break;
      case D_COMMISSION : deal.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);      break;
      case D_TIME       : deal.time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);       break;
      case D_ALL        :
         deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         deal.comment=HistoryDealGetString(ticket,DEAL_COMMENT);
         deal.type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
         deal.entry=(int)HistoryDealGetInteger(ticket,DEAL_ENTRY);
         deal.price=HistoryDealGetDouble(ticket,DEAL_PRICE);
         deal.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         deal.volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
         deal.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
         deal.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         deal.time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);                        break;
         //---
      default: Print("���������� �������� ������ �� ������ � ������������!");                return;
     }
  }
//+------------------------------------------------------------------+
//| �������� �������� �������                                        |
//+------------------------------------------------------------------+
void GetSymbolProperties(int symbol_number,ENUM_SYMBOL_PROPERTIES symbol_property)
  {
   int lot_offset=1; // ���������� ������� ��� ������� �� ������� stops level
//---
   switch(symbol_property)
     {
      case S_DIGITS         : symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);                   break;
      case S_SPREAD         : symb.spread=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_SPREAD);                   break;
      case S_STOPSLEVEL     : symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);   break;
      case S_POINT          : symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);                           break;
      //---
      case S_ASK            :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.ask=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_ASK),symb.digits);                       break;
      case S_BID            :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.bid=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_BID),symb.digits);                       break;
         //---
      case S_VOLUME_MIN     : symb.volume_min=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MIN);                 break;
      case S_VOLUME_MAX     : symb.volume_max=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MAX);                 break;
      case S_VOLUME_LIMIT   : symb.volume_limit=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_LIMIT);             break;
      case S_VOLUME_STEP    : symb.volume_step=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_STEP);               break;
      //---
      case S_FILTER         :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);                      break;
         //---
      case S_UP_LEVEL       :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_ASK),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);                                 break;
         //---
      case S_DOWN_LEVEL     :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.bid=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_BID),symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);                               break;
         //---
      case S_EXECUTION_MODE :
         symb.execution_mode=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_EXEMODE); break;
         //---
      case S_ALL            :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.spread=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_SPREAD);
         symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_ASK),symb.digits);
         symb.bid=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_BID),symb.digits);
         symb.volume_min=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MIN);
         symb.volume_max=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MAX);
         symb.volume_limit=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_LIMIT);
         symb.volume_step=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_STEP);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);
         symb.execution_mode=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_EXEMODE); break;
         //---
      default : Print("���������� �������� ������� �� ������ � ������������!"); return;
     }
  }
//+------------------------------------------------------------------+
//| ���������� ������� �������� ������� �� Take Profit               |
//+------------------------------------------------------------------+
bool GetEventTakeProfit(int symbol_number)
  {
   string last_comment="";
//--- ������� ����������� ��������� ������ �� ��������� �������
   last_comment=LastDealComment(symbol_number);
//--- ���� � ����������� ���� ������ "tp"
   if(StringFind(last_comment,"tp",0)>-1)
      return(true);
//--- ���� ��� ������ "tp"
   return(false);
  }
//+------------------------------------------------------------------+
//| ���������� ������� �������� ������� �� Stop Loss                 |
//+------------------------------------------------------------------+
bool GetEventStopLoss(int symbol_number)
  {
   string last_comment="";
//--- ������� ����������� ��������� ������ �� ��������� �������
   last_comment=LastDealComment(symbol_number);
//--- ���� � ����������� ���� ������ "sl"
   if(StringFind(last_comment,"sl",0)>-1)
      return(true);
//--- ���� ��� ������ "sl"
   return(false);
  }
//+------------------------------------------------------------------+
//| ���������� ����������� ��������� ������ �� ��������� �������     |
//+------------------------------------------------------------------+
string LastDealComment(int symbol_number)
  {
   int    total_deals  =0;  // ����� ������ � ������ ��������� �������
   string deal_symbol  =""; // ������ ������ 
   string deal_comment =""; // ����������� ������
//--- ���� ������� ������ ��������
   if(HistorySelect(0,TimeCurrent()))
     {
      //--- ������� ���������� ������ � ���������� ������
      total_deals=HistoryDealsTotal();
      //--- ��������� �� ���� ������� � ���������� ������
      //    �� ��������� ������ � ������
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- ������� ����������� ������
         deal_comment=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_COMMENT);
         //--- ������� ������ ������
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- ���� ������ ������ � ������� ������ �����, ��������� ����
         if(deal_symbol==Symbols[symbol_number])
            break;
        }
     }
//---
   return(deal_comment);
  }
//+------------------------------------------------------------------+
//| ���������� ������� ��������� ������ �� ��������� �������         |
//+------------------------------------------------------------------+
bool GetEventLastDealTicket(int symbol_number)
  {
   int    total_deals =0;  // ����� ������ � ������ ��������� �������
   string deal_symbol =""; // ������ ������
   ulong  deal_ticket =0;  // ����� ������
//--- ���� ������� ������ ��������
   if(HistorySelect(0,TimeCurrent()))
     {
      //--- ������� ���������� ������ � ���������� ������
      total_deals=HistoryDealsTotal();
      //--- ��������� �� ���� ������� � ���������� ������
      //    �� ��������� ������ � ������
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- ������� ����� ������
         deal_ticket=HistoryDealGetTicket(i);
         //--- ������� ������ ������
         deal_symbol=HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
         //--- ���� ������ ������ � ������� ������ �����, ��������� ����
         if(deal_symbol==Symbols[symbol_number])
           {
            //--- ���� ������ �����, ������
            if(deal_ticket==last_ticket_deal[symbol_number])
               return(false);
            //--- ���� ������ �� �����, ������� �� ���� �
            else
              {
               //--- �������� ����� ��������� ������
               last_ticket_deal[symbol_number]=deal_ticket;
               return(true);
              }
           }
        }
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| ���������� ���������� ������ ������� �������                     |
//+------------------------------------------------------------------+
uint CurrentPositionTotalDeals(int symbol_number)
  {
   int    count       =0;  // ������� ������ �� ������� �������
   int    total_deals =0;  // ����� ������ � ������ ��������� �������
   string deal_symbol =""; // ������ ������
//--- ���� ������� ������� ��������
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- ������� ���������� ������ � ���������� ������
      total_deals=HistoryDealsTotal();
      //--- ������� �� ���� ������� � ���������� ������
      for(int i=0; i<total_deals; i++)
        {
         //--- ������� ������ ������
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- ���� ������ ������ � ������� ������ ���������, �������� �������
         if(deal_symbol==Symbols[symbol_number])
            count++;
        }
     }
//---
   return(count);
  }
//+------------------------------------------------------------------+
//| ���������� ���� ������ ������ ������� �������                    |
//+------------------------------------------------------------------+
double CurrentPositionFirstDealPrice(int symbol_number)
  {
   int      total_deals =0;    // ����� ������ � ������ ��������� �������
   string   deal_symbol ="";   // ������ ������
   double   deal_price  =0.0;  // ���� ������
   datetime deal_time   =NULL; // ����� ������
//--- ���� ������� ������� ��������
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- ������� ���������� ������ � ���������� ������
      total_deals=HistoryDealsTotal();
      //--- ������� �� ���� ������� � ���������� ������
      for(int i=0; i<total_deals; i++)
        {
         //--- ������� ���� ������
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- ������� ������ ������
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- ������� ����� ������
         deal_time=(datetime)HistoryDealGetInteger(HistoryDealGetTicket(i),DEAL_TIME);
         //--- ���� ����� ������ � ����� �������� ������� �����, 
         //    � ����� ����� ������ ������ � ������� ������, ������ �� �����
         if(deal_time==pos.time && deal_symbol==Symbols[symbol_number])
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| ���������� ���� ��������� ������ ������� �������                 |
//+------------------------------------------------------------------+
double CurrentPositionLastDealPrice(int symbol_number)
  {
   int    total_deals =0;   // ����� ������ � ������ ��������� �������
   string deal_symbol ="";  // ������ ������ 
   double deal_price  =0.0; // ����
//--- ���� ������� ������� ��������
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- ������� ���������� ������ � ���������� ������
      total_deals=HistoryDealsTotal();
      //--- ������� �� ���� ������� � ���������� ������ �� ��������� ������ � ������ � ������
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- ������� ���� ������
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- ������� ������ ������
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- ���� ������ ������ � ������� ������ �����, ��������� ����
         if(deal_symbol==Symbols[symbol_number])
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| ���������� ��������� ����� ������� �������                       |
//+------------------------------------------------------------------+
double CurrentPositionInitialVolume(int symbol_number)
  {
   int             total_deals =0;           // ����� ������ � ������ ��������� �������
   ulong           ticket      =0;           // ����� ������
   ENUM_DEAL_ENTRY deal_entry  =WRONG_VALUE; // ������ ��������� �������
   bool            inout       =false;       // ������� ������� ��������� �������
   double          sum_volume  =0.0;         // ������� ����������� ������ ���� ������ ����� ������
   double          deal_volume =0.0;         // ����� ������
   string          deal_symbol ="";          // ������ ������ 
   datetime        deal_time   =NULL;        // ����� ���������� ������
//--- ���� ������� ������� ��������
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- ������� ���������� ������ � ���������� ������
      total_deals=HistoryDealsTotal();
      //--- ������� �� ���� ������� � ���������� ������ �� ��������� ������ � ������ � ������
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- ���� ����� ������ �� ��� ������� � ������ �������, ��...
         if((ticket=HistoryDealGetTicket(i))>0)
           {
            //--- ������� ����� ������
            deal_volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            //--- ������� ������ ��������� �������
            deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
            //--- ������� ����� ���������� ������
            deal_time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
            //--- ������� ������ ������
            deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
            //--- ����� ����� ���������� ������ ����� ������ ��� ����� ������� �������� �������, ������ �� �����
            if(deal_time<=pos.time)
               break;
            //--- ����� ������� ���������� ����� ������ �� ������� �������, ����� ������
            if(deal_symbol==Symbols[symbol_number])
               sum_volume+=deal_volume;
           }
        }
     }
//--- ���� ������ ��������� ������� - ��������
   if(deal_entry==DEAL_ENTRY_INOUT)
     {
      //--- ���� ����� ������� ������������/����������
      //    �� ����, ������ ������ �����
      if(fabs(sum_volume)>0)
        {
         //--- ������� ����� ����� ����� ���� ������ ����� ������
         double result=pos.volume-sum_volume;
         //--- ���� ���� ������ ����, ������ ����, ����� ������ ������� ����� �������         
         deal_volume=result>0 ? result : pos.volume;
        }
      //--- ���� ������ ����� ����� ������ �� ����,
      if(sum_volume==0)
         deal_volume=pos.volume; // ����� ������� ����� �������
     }
//--- ������ ��������� ����� �������
   return(NormalizeDouble(deal_volume,2));
  }
//+------------------------------------------------------------------+
//| ���������� ������������ ������� �������                          |
//+------------------------------------------------------------------+
ulong CurrentPositionDuration(ENUM_POSITION_DURATION mode)
  {
   ulong     result=0;   // �������� ���������
   ulong     seconds=0;  // ���������� ������
//--- �������� ������������ ������� � ��������
   seconds=TimeCurrent()-pos.time;
//---
   switch(mode)
     {
      case DAYS      : result=seconds/(60*60*24);   break; // ��������� ���-�� ����
      case HOURS     : result=seconds/(60*60);      break; // ��������� ���-�� �����
      case MINUTES   : result=seconds/60;           break; // ��������� ���-�� �����
      case SECONDS   : result=seconds;              break; // ��� �������� (���-�� ������)
      //---
      default        :
         Print(__FUNCTION__,"(): ������� ����������� ����� ������������!");
         return(0);
     }
//--- ������ ���������
   return(result);
  }
//+------------------------------------------------------------------+
//| �������� ������ ����                                             |
//+------------------------------------------------------------------+
bool CheckNewBar(int symbol_number)
  {
//--- ������� ����� �������� �������� ����
//    ���� �������� ������ ��� ���������, ������� �� ����
   if(CopyTime(Symbols[symbol_number],Period(),0,1,lastbar_time[symbol_number].time)==-1)
      Print(__FUNCTION__,": ������ ����������� ������� �������� ����: "+IntegerToString(GetLastError())+"");
//--- ���� ��� ������ ����� �������
   if(new_bar[symbol_number]==NULL)
     {
      //--- ��������� �����
      new_bar[symbol_number]=lastbar_time[symbol_number].time[0];
      Print(__FUNCTION__,": ������������� ["+Symbols[symbol_number]+"][TF: "+TimeframeToString(Period())+"]["
            +TimeToString(lastbar_time[symbol_number].time[0],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"]");
      return(false);
     }
//--- ���� ����� ����������
   if(new_bar[symbol_number]!=lastbar_time[symbol_number].time[0])
     {
      //--- ��������� ����� � ������
      new_bar[symbol_number]=lastbar_time[symbol_number].time[0];
      return(true);
     }
//--- ����� �� ����� ����� - ������ ��� �� �����, ������ false
   return(false);
  }
//+------------------------------------------------------------------+
