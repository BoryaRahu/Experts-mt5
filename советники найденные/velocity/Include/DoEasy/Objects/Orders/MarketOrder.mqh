//+------------------------------------------------------------------+
//|                                                  MarketOrder.mqh |
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
//| Рыночный маркет-ордер                                            |
//+------------------------------------------------------------------+
class CMarketOrder : public COrder
  {
public:
   //--- Конструктор
                     CMarketOrder(const ulong ticket=0) : COrder(ORDER_STATUS_MARKET_ORDER,ticket) {}
   //--- Поддерживаемые свойства ордера (1) вещественные, (2) целочисленные
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property);
  };
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное            |
//| целочисленное свойство, возвращает ложь в противном случае       |
//+------------------------------------------------------------------+
bool CMarketOrder::SupportProperty(ENUM_ORDER_PROP_INTEGER property)
  {
   if(property==ORDER_PROP_TIME_EXP          || 
      property==ORDER_PROP_DEAL_ENTRY        || 
      property==ORDER_PROP_TIME_UPDATE       || 
      property==ORDER_PROP_TIME_UPDATE_MSC   ||
      property==ORDER_PROP_PROFIT_PT         ||
      property==ORDER_PROP_TIME_CLOSE        ||
      property==ORDER_PROP_TIME_CLOSE_MSC    ||
      property==ORDER_PROP_TICKET_FROM       ||
      property==ORDER_PROP_TICKET_TO
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если ордер поддерживает переданное            |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CMarketOrder::SupportProperty(ENUM_ORDER_PROP_DOUBLE property)
  {
   if(property==ORDER_PROP_PROFIT            || 
      property==ORDER_PROP_PROFIT_FULL       || 
      property==ORDER_PROP_SWAP              || 
      property==ORDER_PROP_COMMISSION        ||
      property==ORDER_PROP_PRICE_CLOSE       ||
      property==ORDER_PROP_SL                ||
      property==ORDER_PROP_TP                ||
      property==ORDER_PROP_PRICE_STOP_LIMIT
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
