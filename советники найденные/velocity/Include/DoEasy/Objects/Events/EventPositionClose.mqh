//+------------------------------------------------------------------+
//|                                           EventPositionClose.mqh |
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
class CEventPositionClose : public CEvent
  {
private:
//--- Создаёт и возвращает краткое сообщение события
   string            EventsMessage(void);  
public:
//--- Конструктор
                     CEventPositionClose(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_HISTORY_POSITION,event_code,ticket) {}
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
bool CEventPositionClose::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если событие поддерживает переданное          |
//| вещественное свойство, возвращает ложь в противном случае        |
//+------------------------------------------------------------------+
bool CEventPositionClose::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Выводит в журнал краткое сообщение о событии                     |
//+------------------------------------------------------------------+
void CEventPositionClose::PrintShort(void)
  {
   ::Print(this.EventsMessage());
  }
//+------------------------------------------------------------------+
//| Отправляет событие на график                                     |
//+------------------------------------------------------------------+
void CEventPositionClose::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.PositionID(),this.PriceClose(),this.Symbol());
  }
//+------------------------------------------------------------------+
//| Создаёт и возвращает краткое сообщение события                   |
//+------------------------------------------------------------------+
string CEventPositionClose::EventsMessage(void)
  {
//--- (1) заголовок, (2) исполненный объём ордера, (3) исполненный объём позиции, (4) цена, на которой произошло событие
//--- (5) цена StopLoss, (6) цена TakeProfit, (7) магический номер, (6) профит в валюте счёта, (7,8) Варианты сообщения закрытия
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string vol_ord=::DoubleToString(this.VolumeOrderExecuted(),DigitsLots(this.Symbol()));
   string vol_pos=::DoubleToString(this.VolumePositionExecuted(),DigitsLots(this.Symbol()));
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceEvent(),this.m_digits);
   string sl=(this.PriceStopLoss()>0 ? ", sl "+ ::DoubleToString(this.PriceStopLoss(),this.m_digits) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+ ::DoubleToString(this.PriceTakeProfit(),this.m_digits) : "");
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string profit=TextByLanguage(", профит ",", profit ")+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   string close=TextByLanguage("Закрыт ","Close ");
   string in_pos="";
   //---
   if(this.GetProperty(EVENT_PROP_TYPE_EVENT)>TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL)
     {
      close=TextByLanguage("Закрыт объём ","Closed volume ")+vol_ord;
      in_pos=TextByLanguage(" в "," in ");
     }
   string opposite=
     (
      this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS)   ? 
      TextByLanguage(" встречным "," by opposite ")+this.SymbolCloseBy()+" "+
      this.TypeOrderDealDescription()+" #"+(string)this.PositionByID()+(this.MagicCloseBy()> 0 ? "("+(string)this.MagicCloseBy()+"]" : "")
                                                         : ""
     );
   //--- EURUSD: Закрыт 0.1 Sell #xx [0.2 ордер SellLimit #XX] по цене х.ххххх, sl х.ххххх, tp x.xxxxx, magic, профит xxxx
   string text=
     (
      this.Symbol()+" "+close+in_pos+this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
      opposite+" ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic+profit
     );
   return head+text;
  }
//+------------------------------------------------------------------+
