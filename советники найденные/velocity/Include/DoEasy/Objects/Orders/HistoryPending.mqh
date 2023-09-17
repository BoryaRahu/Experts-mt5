//+------------------------------------------------------------------+
//|                                               HistoryPending.mqh |
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
//| Удалённый отложенный ордер                                       |
//+------------------------------------------------------------------+
class CHistoryPending : public COrder
  {
public:
   //--- Конструктор
                     CHistoryPending(const ulong ticket) : COrder(ORDER_STATUS_HISTORY_PENDING,ticket) {}
   //--- Поддерживаемые свойства ордера (1) вещественные, (2) целочисленные
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
  };
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное свойство,  |
//| возвращает ложь в противном случае                               |
//+------------------------------------------------------------------+
bool CHistoryPending::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_DEAL_ORDER_TICKET ||
      property==ORDER_PROP_DEAL_ENTRY        ||
      property==ORDER_PROP_TIME_UPDATE       ||
      property==ORDER_PROP_TIME_UPDATE_MSC   ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_CLOSE_BY_SL       ||
      property==ORDER_PROP_CLOSE_BY_TP
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное свойство,  |
//| возвращает ложь в противном случае                               |
//+------------------------------------------------------------------+
bool CHistoryPending::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   if(property==ORDER_PROP_COMMISSION  ||
      property==ORDER_PROP_SWAP        ||
      property==ORDER_PROP_PROFIT      ||
      property==ORDER_PROP_PROFIT_FULL ||
      property==ORDER_PROP_PRICE_CLOSE
      #ifdef __MQL5__                  ||
      property==ORDER_PROP_PRICE_STOP_LIMIT
      #endif 
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
