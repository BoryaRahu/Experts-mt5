//+------------------------------------------------------------------+
//|                                             EventOrderPlased.mqh |
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
//| Событие установки отложенного ордера                             |
//+------------------------------------------------------------------+
class CEventOrderPlased : public CEvent
  {
public:
//--- Конструктор
                     CEventOrderPlased(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_MARKET_PENDING,event_code,ticket) {}
//--- Поддерживаемые свойства ордера (1) вещественные, (2) целочисленные
   virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
   virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
//--- (1) Выводит в журнал краткое сообщение о событии, (2) Отправляет событие на график
   virtual void      PrintShort(void);
   virtual void      SendEvent(void);
  };
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| целочисленное свойство, возвращает ложь в противном случае       |
//+------------------------------------------------------------------+
bool CEventOrderPlased::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   if(property==EVENT_PROP_TYPE_DEAL_EVENT         ||
      property==EVENT_PROP_TICKET_DEAL_EVENT       ||
      property==EVENT_PROP_TYPE_ORDER_POSITION     ||
      property==EVENT_PROP_TICKET_ORDER_POSITION   ||
      property==EVENT_PROP_POSITION_ID             ||
      property==EVENT_PROP_POSITION_BY_ID          ||
      property==EVENT_PROP_TIME_ORDER_POSITION
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CEventOrderPlased::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   if(property==EVENT_PROP_PRICE_CLOSE             ||
      property==EVENT_PROP_PROFIT
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Выводит в журнал краткое сообщение о событии                     |
//+------------------------------------------------------------------+
void CEventOrderPlased::PrintShort(void)
  {
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string sl=(this.PriceStopLoss()>0 ? ", sl "+::DoubleToString(this.PriceStopLoss(),this.m_digits) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+::DoubleToString(this.PriceTakeProfit(),this.m_digits) : "");
   string vol=::DoubleToString(this.VolumeOrderInitial(),DigitsLots(this.Symbol()));
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string type=this.TypeOrderFirstDescription()+" #"+(string)this.TicketOrderEvent();
   string event=TextByLanguage(" Установлен "," Placed ");
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceOpen(),this.m_digits);
   string txt=head+this.Symbol()+event+vol+" "+type+price+sl+tp+magic;
   //--- Если сработал StopLimit-ордер
   if(this.Reason()==EVENT_REASON_STOPLIMIT_TRIGGERED)
     {
      head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimeEvent())+" -\n";
      event=TextByLanguage(" Сработал "," Triggered ");
      type=
        (
         OrderTypeDescription(this.TypeOrderPosPrevious())+" #"+(string)this.TicketOrderEvent()+
         TextByLanguage(" по цене "," at price ")+DoubleToString(this.PriceEvent(),this.m_digits)+" -->\n"+
         vol+" "+OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderEvent()+
         TextByLanguage(" на цену "," on price ")+DoubleToString(this.PriceOpen(),this.m_digits)
        );
      txt=head+this.Symbol()+event+"("+TimeMSCtoString(this.TimePosition())+") "+vol+" "+type+sl+tp+magic;
     }
   ::Print(txt);
  }
//+------------------------------------------------------------------+
//| Отправляет событие на график                                     |
//+------------------------------------------------------------------+
void CEventOrderPlased::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.TicketOrderEvent(),this.PriceOpen(),this.Symbol());
  }
//+------------------------------------------------------------------+
