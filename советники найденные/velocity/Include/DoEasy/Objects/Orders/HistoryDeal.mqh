//+------------------------------------------------------------------+
//|                                                  HistoryDeal.mqh |
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
//| Историческая сделка                                              |
//+------------------------------------------------------------------+
class CHistoryDeal : public COrder
  {
public:
   //--- Конструктор
                     CHistoryDeal(const ulong ticket) : COrder(ORDER_STATUS_DEAL,ticket) {}
   //--- Поддерживаемые свойства сделки (1) вещественные, (2) целочисленные
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
  };
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное            |
//| целочисленное свойство, возвращает ложь в противном случае       |
//+------------------------------------------------------------------+
bool CHistoryDeal::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_TIME_EXP          || 
      property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_POSITION_BY_ID    ||
      property==ORDER_PROP_TIME_UPDATE       ||
      property==ORDER_PROP_TIME_UPDATE_MSC   ||
      property==ORDER_PROP_STATE             ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO         ||
      property==ORDER_PROP_TIME_CLOSE        ||
      property==ORDER_PROP_TIME_CLOSE_MSC    ||
      (
       this.OrderType()==DEAL_TYPE_BALANCE &&
       (
        property==ORDER_PROP_POSITION_ID     ||
        property==ORDER_PROP_DEAL_ENTRY      ||
        property==ORDER_PROP_MAGIC           ||
        property==ORDER_PROP_CLOSE_BY_SL     ||
        property==ORDER_PROP_CLOSE_BY_TP     ||
        property==ORDER_PROP_DEAL_ORDER_TICKET
       )
      )
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное            |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CHistoryDeal::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   if(property==ORDER_PROP_TP                || 
      property==ORDER_PROP_SL                || 
      property==ORDER_PROP_PRICE_CLOSE       ||
      property==ORDER_PROP_VOLUME_CURRENT    ||
      property==ORDER_PROP_PRICE_STOP_LIMIT  ||
      (
       this.OrderType()==DEAL_TYPE_BALANCE &&
       (
        property==ORDER_PROP_PRICE_OPEN      ||
        property==ORDER_PROP_COMMISSION      ||
        property==ORDER_PROP_SWAP            ||
        property==ORDER_PROP_VOLUME
       )
      )
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
