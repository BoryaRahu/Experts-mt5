//+------------------------------------------------------------------+
//|                                            EventPositionOpen.mqh |
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
class CEventPositionOpen : public CEvent
  {
private:
//--- Создаёт и возвращает краткое сообщение события
   string            EventsMessage(void);  
public:
//--- Конструктор
                     CEventPositionOpen(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_MARKET_POSITION,event_code,ticket) {}
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
bool CEventPositionOpen::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   return(property==EVENT_PROP_POSITION_BY_ID ? false : true);
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CEventPositionOpen::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   if(property==EVENT_PROP_PRICE_CLOSE ||
      property==EVENT_PROP_PROFIT
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Выводит в журнал краткое сообщение о событии                     |
//+------------------------------------------------------------------+
void CEventPositionOpen::PrintShort(void)
  {
   ::Print(this.EventsMessage());
  }
//+------------------------------------------------------------------+
//| Отправляет событие на график                                     |
//+------------------------------------------------------------------+
void CEventPositionOpen::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.PositionID(),this.PriceOpen(),this.Symbol());
  }
//+------------------------------------------------------------------+
//| Создаёт и возвращает краткое сообщение события                   |
//+------------------------------------------------------------------+
string CEventPositionOpen::EventsMessage(void)
  {
//--- (1) заголовок, (2) исполненный объём ордера, (3) исполненный объём позиции, (4) цена, на которой произошло событие
//--- (5) цена StopLoss, (6) цена TakeProfit, (7) магический номер, (6) профит в валюте счёта
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string vol_ord=::DoubleToString(this.VolumeOrderExecuted(),DigitsLots(this.Symbol()));
   string vol_pos=::DoubleToString(this.VolumePositionExecuted(),DigitsLots(this.Symbol()));
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceEvent(),this.m_digits);
   string sl=(this.PriceStopLoss()>0 ? ", sl "+ ::DoubleToString(this.PriceStopLoss(),this.m_digits) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+ ::DoubleToString(this.PriceTakeProfit(),this.m_digits) : "");
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string profit=TextByLanguage(", профит ",", profit ")+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   //---
   string text="";
   //--- Разворот позиции
   if(this.GetProperty(EVENT_PROP_REASON_EVENT)<EVENT_REASON_ACTIVATED_PENDING)
     {
      //--- EURUSD: Buy #xx изменён на 0.1 Sell #xx [0.2 ордер SellLimit #XX] по цене х.ххххх, sl х.ххххх, tp x.xxxxx, magic, профит xxxx
      text=
        (
         this.Symbol()+" "+
         this.TypePositionPreviousDescription()+" #"+(string)this.TicketPositionPrevious()+
         TextByLanguage(" изменен на "," turned to ")+vol_pos+" "+this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
         " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic+profit
        );
     }
   else
     {
      //--- Добавление объёма
      if(this.GetProperty(EVENT_PROP_TICKET_ORDER_EVENT)!=this.GetProperty(EVENT_PROP_POSITION_ID))
        {
         //--- EURUSD: Добавлено 0.1 к Buy #xx [ордер BuyLimit #XX] по цене х.ххххх, magic
         text=
           (
            this.Symbol()+" "+
            TextByLanguage("Добавлено ","Added ")+vol_ord+TextByLanguage(" к "," to ")+
            this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
            " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+magic
           );
        }
      //--- Открытие позиции
      else
        {
         //--- EURUSD: Открыт 0.1 Buy #xx [ордер BuyLimit #XX] по цене х.ххххх, sl х.ххххх, tp x.xxxxx, magic
         text=
           (
            this.Symbol()+" "+
            TextByLanguage("Открыт ","Open ")+vol_pos+" "+
            this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
            " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic
           );
        }
     }
   return head+text;
  }
//+------------------------------------------------------------------+
