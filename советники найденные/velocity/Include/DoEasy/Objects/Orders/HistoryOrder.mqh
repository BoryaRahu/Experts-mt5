//+------------------------------------------------------------------+
//|                                                 HistoryOrder.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include "Order.mqh"
//+------------------------------------------------------------------+
//| Исторический маркет-ордер                                        |
//+------------------------------------------------------------------+
class CHistoryOrder : public COrder
  {
public:
   //--- Конструктор
                     CHistoryOrder(const ulong ticket) : COrder(ORDER_STATUS_HISTORY_ORDER,ticket) {}
   //--- Поддерживаемые целочисленные свойства ордера
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
   //--- Поддерживаемые вещественные свойства ордера
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
  };
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное            |
//| целочисленное свойство, возвращает ложь в противном случае       |
//+------------------------------------------------------------------+
bool CHistoryOrder::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_TIME_EXP          || 
      property==ORDER_PROP_DEAL_ENTRY        || 
      property==ORDER_PROP_TIME_UPDATE       || 
      property==ORDER_PROP_TIME_UPDATE_MSC
      #ifdef __MQL5__                        ||
      property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_TIME_CLOSE        ||
      property==ORDER_PROP_TIME_CLOSE_MSC    ||
      (this.TypeOrder()==ORDER_TYPE_CLOSE_BY && property==ORDER_PROP_DIRECTION)
      #endif 
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное            |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CHistoryOrder::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
#ifdef __MQL5__
   if(property==ORDER_PROP_PROFIT            || 
      property==ORDER_PROP_PROFIT_FULL       || 
      property==ORDER_PROP_SWAP              || 
      property==ORDER_PROP_COMMISSION        ||
      property==ORDER_PROP_PRICE_CLOSE       ||
      property==ORDER_PROP_PRICE_STOP_LIMIT
     ) return false;
#endif 
   return true;
  }
//+------------------------------------------------------------------+
