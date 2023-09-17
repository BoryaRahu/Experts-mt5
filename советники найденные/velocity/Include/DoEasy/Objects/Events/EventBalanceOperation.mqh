//+------------------------------------------------------------------+
//|                                        EventBalanceOperation.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include "Event.mqh"
//+------------------------------------------------------------------+
//| Событие открытия позиции                                         |
//+------------------------------------------------------------------+
class CEventBalanceOperation : public CEvent
  {
public:
//--- Конструктор
                     CEventBalanceOperation(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_BALANCE,event_code,ticket) {}
//--- Поддерживаемые свойства ордера (1) вещественные, (2) целочисленные
   virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
   virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_EVENT_PROP_STRING property);
//--- (1) Выводит в журнал краткое сообщение о событии, (2) Отправляет событие на график
   virtual void      PrintShort(void);
   virtual void      SendEvent(void);
  };
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| целочисленное свойство, возвращает ложь в противном случае       |
//+------------------------------------------------------------------+
bool CEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   if(property==EVENT_PROP_TYPE_ORDER_EVENT        ||
      property==EVENT_PROP_TYPE_ORDER_POSITION     ||
      property==EVENT_PROP_TICKET_ORDER_EVENT      ||
      property==EVENT_PROP_TICKET_ORDER_POSITION   ||
      property==EVENT_PROP_POSITION_ID             ||
      property==EVENT_PROP_POSITION_BY_ID          ||
      property==EVENT_PROP_POSITION_ID             ||
      property==EVENT_PROP_MAGIC_ORDER             ||
      property==EVENT_PROP_TIME_ORDER_POSITION
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   return(property==EVENT_PROP_PROFIT ? true : false);
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| строковое свойство, возвращает ложь в противном случае           |
//+------------------------------------------------------------------+
bool CEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_STRING property)
  {
   return false;
  }
//+------------------------------------------------------------------+
//| Выводит в журнал краткое сообщение о событии                     |
//+------------------------------------------------------------------+
void CEventBalanceOperation::PrintShort(void)
  {
   string head="- "+this.StatusDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   ::Print(head+this.TypeEventDescription()+": "+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY));
  }
//+------------------------------------------------------------------+
//| Отправляет событие на график                                     |
//+------------------------------------------------------------------+
void CEventBalanceOperation::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.TypeEvent(),this.Profit(),::AccountInfoString(ACCOUNT_CURRENCY));
  }
//+------------------------------------------------------------------+
