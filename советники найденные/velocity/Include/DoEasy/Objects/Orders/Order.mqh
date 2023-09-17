//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property version   "1.00"
#property strict    // Нужно для mql4
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "..\..\Services\DELib.mqh"
//+------------------------------------------------------------------+
//| Класс абстрактного ордера                                        |
//+------------------------------------------------------------------+
class COrder : public CObject
  {
private:
   ulong             m_ticket;                                    // Тикет выбранного ордера/сделки (MQL5)
   long              m_long_prop[ORDER_PROP_INTEGER_TOTAL];       // Целочисленные свойства
   double            m_double_prop[ORDER_PROP_DOUBLE_TOTAL];      // Вещественные свойства
   string            m_string_prop[ORDER_PROP_STRING_TOTAL];      // Строковые свойства

   //--- Возвращает индекс массива, по которому фактически расположено (1) double-свойство и (2) string-свойство ордера
   int               IndexProp(ENUM_ORDER_PROP_DOUBLE property) const { return(int)property-ORDER_PROP_INTEGER_TOTAL;                        }
   int               IndexProp(ENUM_ORDER_PROP_STRING property) const { return(int)property-ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_DOUBLE_TOTAL;}
public:
   //--- Конструктор по умолчанию
                     COrder(void){;}
protected:
   //--- Защищённый параметрический конструктор
                     COrder(ENUM_ORDER_STATUS order_status,const ulong ticket);

   //--- Получает и возвращает целочисленные свойства выбранного ордера из его параметров
   long              OrderMagicNumber(void)        const;
   long              OrderTicket(void)             const;
   long              OrderTicketFrom(void)         const;
   long              OrderTicketTo(void)           const;
   long              OrderPositionID(void)         const;
   long              OrderPositionByID(void)       const;
   long              OrderOpenTimeMSC(void)        const;
   long              OrderCloseTimeMSC(void)       const;
   long              OrderType(void)               const;
   long              OrderState(void)              const;
   long              OrderTypeByDirection(void)    const;
   long              OrderTypeFilling(void)        const;
   long              OrderTypeTime(void)           const;
   long              OrderReason(void)             const;
   long              DealOrderTicket(void)         const;
   long              DealEntry(void)               const;
   bool              OrderCloseByStopLoss(void)    const;
   bool              OrderCloseByTakeProfit(void)  const;
   datetime          OrderOpenTime(void)           const;
   datetime          OrderCloseTime(void)          const;
   datetime          OrderExpiration(void)         const;
   datetime          PositionTimeUpdate(void)      const;
   datetime          PositionTimeUpdateMSC(void)   const;

   //--- Получает и возвращает вещественные свойства выбранного ордера из его параметров: (1) цену открытия, (2) цену закрытия, (3) профит,
   //---  (4) комиссию, (5) своп, (6) объём, (7) невыполненный объём (8) цену StopLoss, (9) цену TakeProfit (10) цену установки StopLimit-ордера
   double            OrderOpenPrice(void)          const;
   double            OrderClosePrice(void)         const;
   double            OrderProfit(void)             const;
   double            OrderCommission(void)         const;
   double            OrderSwap(void)               const;
   double            OrderVolume(void)             const;
   double            OrderVolumeCurrent(void)      const;
   double            OrderStopLoss(void)           const;
   double            OrderTakeProfit(void)         const;
   double            OrderPriceStopLimit(void)     const;

   //--- Получает и возвращает строковые свойства выбранного ордера из его параметров: (1) символ, (2) комментарий, (3) идентификатор на бирже
   string            OrderSymbol(void)             const;
   string            OrderComment(void)            const;
   string            OrderExternalID(void)         const;
   
   //--- Возвращает описание (1) причины, (2) направления, (3) типа сделки
   string            GetReasonDescription(const long reason)            const;
   string            GetEntryDescription(const long deal_entry)         const;
   string            GetTypeDealDescription(const long type_deal)       const;
   
public:
   //--- Устанавливает (1) целочисленное, (2) вещественное и (3) строковое свойство ордера
   void              SetProperty(ENUM_ORDER_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                               }
   void              SetProperty(ENUM_ORDER_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;             }
   void              SetProperty(ENUM_ORDER_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;             }
   //--- Возвращает из массива свойств (1) целочисленное, (2) вещественное и (3) строковое свойство ордера
   long              GetProperty(ENUM_ORDER_PROP_INTEGER property)      const { return this.m_long_prop[property];                              }
   double            GetProperty(ENUM_ORDER_PROP_DOUBLE property)       const { return this.m_double_prop[this.IndexProp(property)];            }
   string            GetProperty(ENUM_ORDER_PROP_STRING property)       const { return this.m_string_prop[this.IndexProp(property)];            }

   //--- Возвращает флаг поддержания ордером данного свойства
   virtual bool      SupportProperty(ENUM_ORDER_PROP_INTEGER property)        { return true; }
   virtual bool      SupportProperty(ENUM_ORDER_PROP_DOUBLE property)         { return true; }
   virtual bool      SupportProperty(ENUM_ORDER_PROP_STRING property)         { return true; }

   //--- Сравнивает объекты COrder между собой по всем возможным свойствам (для сортировки списков по указанному свойству объекта-ордера)
   virtual int       Compare(const CObject *node,const int mode=0) const;
//--- Сравнивает объекты COrder между собой по всем свойствам (для поиска равных объектов-событий)
   bool              IsEqual(COrder* compared_order) const;
//+------------------------------------------------------------------+
//| Методы упрощённого доступа к свойствам объекта-ордера            |
//+------------------------------------------------------------------+
   //--- Возвращает (1) тикет, (2) тикет родительского ордера, (3) тикет дочернего ордера, (4) магик, (5) причину выставления ордера,
   //--- (6) идентификатор позиции, (7) идентификатор встречной позиции, (8) идентификатор группы, (9) тип, (10) флаг закрытия по StopLoss,
   //--- (11) флаг закрытия по TakeProfit (12) время открытия, (13) время закрытия, (14) время открытия в милисекундах,
   //--- (15) время закрытия в милисекундах, (16) дату экспирации, (17) состояние, (18) статус (19) тип ордера по направлению
   long              Ticket(void)                                       const { return this.GetProperty(ORDER_PROP_TICKET);                     }
   long              TicketFrom(void)                                   const { return this.GetProperty(ORDER_PROP_TICKET_FROM);                }
   long              TicketTo(void)                                     const { return this.GetProperty(ORDER_PROP_TICKET_TO);                  }
   long              Magic(void)                                        const { return this.GetProperty(ORDER_PROP_MAGIC);                      }
   long              Reason(void)                                       const { return this.GetProperty(ORDER_PROP_REASON);                     }
   long              PositionID(void)                                   const { return this.GetProperty(ORDER_PROP_POSITION_ID);                }
   long              PositionByID(void)                                 const { return this.GetProperty(ORDER_PROP_POSITION_BY_ID);             }
   long              GroupID(void)                                      const { return this.GetProperty(ORDER_PROP_GROUP_ID);                   }
   long              TypeOrder(void)                                    const { return this.GetProperty(ORDER_PROP_TYPE);                       }
   bool              IsCloseByStopLoss(void)                            const { return (bool)this.GetProperty(ORDER_PROP_CLOSE_BY_SL);          }
   bool              IsCloseByTakeProfit(void)                          const { return (bool)this.GetProperty(ORDER_PROP_CLOSE_BY_TP);          }
   datetime          TimeOpen(void)                                     const { return (datetime)this.GetProperty(ORDER_PROP_TIME_OPEN);        }
   datetime          TimeClose(void)                                    const { return (datetime)this.GetProperty(ORDER_PROP_TIME_CLOSE);       }
   datetime          TimeOpenMSC(void)                                  const { return (datetime)this.GetProperty(ORDER_PROP_TIME_OPEN_MSC);    }
   datetime          TimeCloseMSC(void)                                 const { return (datetime)this.GetProperty(ORDER_PROP_TIME_CLOSE_MSC);   }
   datetime          TimeExpiration(void)                               const { return (datetime)this.GetProperty(ORDER_PROP_TIME_EXP);         }
   ENUM_ORDER_STATE  State(void)                                        const { return (ENUM_ORDER_STATE)this.GetProperty(ORDER_PROP_STATE);    }
   ENUM_ORDER_STATUS Status(void)                                       const { return (ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS);  }
   ENUM_ORDER_TYPE   TypeByDirection(void)                              const { return (ENUM_ORDER_TYPE)this.GetProperty(ORDER_PROP_DIRECTION); }
   
   //--- Возвращает (1) цену открытия, (2) цену закрытия, (3) профит, (4) комиссию, (5) своп, (6) объём, 
   //--- (7) невыполненный объём (8) StopLoss и (9) TakeProfit (10) цену установки StopLimit-ордера
   double            PriceOpen(void)                                    const { return this.GetProperty(ORDER_PROP_PRICE_OPEN);                 }
   double            PriceClose(void)                                   const { return this.GetProperty(ORDER_PROP_PRICE_CLOSE);                }
   double            Profit(void)                                       const { return this.GetProperty(ORDER_PROP_PROFIT);                     }
   double            Comission(void)                                    const { return this.GetProperty(ORDER_PROP_COMMISSION);                 }
   double            Swap(void)                                         const { return this.GetProperty(ORDER_PROP_SWAP);                       }
   double            Volume(void)                                       const { return this.GetProperty(ORDER_PROP_VOLUME);                     }
   double            VolumeCurrent(void)                                const { return this.GetProperty(ORDER_PROP_VOLUME_CURRENT);             }
   double            StopLoss(void)                                     const { return this.GetProperty(ORDER_PROP_SL);                         }
   double            TakeProfit(void)                                   const { return this.GetProperty(ORDER_PROP_TP);                         }
   double            PriceStopLimit(void)                               const { return this.GetProperty(ORDER_PROP_PRICE_STOP_LIMIT);           }
   
   //--- Возвращает (1) символ, (2) комментарий, (3) идентификатор на бирже
   string            Symbol(void)                                       const { return this.GetProperty(ORDER_PROP_SYMBOL);                     }
   string            Comment(void)                                      const { return this.GetProperty(ORDER_PROP_COMMENT);                    }
   string            ExternalID(void)                                   const { return this.GetProperty(ORDER_PROP_EXT_ID);                     }

   //--- Возвращает полный профит ордера
   double            ProfitFull(void)                                   const { return this.Profit()+this.Comission()+this.Swap();              }
   //--- Возвращает профит ордера в пунктах
   int               ProfitInPoints(void) const;
//--- Устанавливает идентификатор группы
   void              SetGroupID(long group_id)                                { this.SetProperty(ORDER_PROP_GROUP_ID,group_id);                 }
   
//+------------------------------------------------------------------+
//| Описания свойств объекта-ордера                                  |
//+------------------------------------------------------------------+
   //--- Возвращает описание (1) целочисленного, (2) вещественного и (3) строкового свойства ордера
   string            GetPropertyDescription(ENUM_ORDER_PROP_INTEGER property);
   string            GetPropertyDescription(ENUM_ORDER_PROP_DOUBLE property);
   string            GetPropertyDescription(ENUM_ORDER_PROP_STRING property);
   //--- Возвращает наименование статуса ордера
   string            StatusDescription(void)    const;
   //--- Возвращает наименование ордера или позиции
   string            TypeDescription(void)      const;
   //--- Возвращает описание состояния ордера
   string            StateDescription(void)     const;
   //--- Возвращает наименование направления сделки
   string            DealEntryDescription(void) const;
   //--- Возвращает тип по направлению ордера/позиции
   string            DirectionDescription(void) const;
   //--- Выводит в журнал описание свойств ордера (full_prop=true - все свойства, false - только поддерживаемые)
   void              Print(const bool full_prop=false);
   //---
  };
//+------------------------------------------------------------------+
//| Методы класса                                                    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Закрытый параметрический конструктор                             |
//+------------------------------------------------------------------+
COrder::COrder(ENUM_ORDER_STATUS order_status,const ulong ticket)
  {
//--- Сохранение целочисленных свойств
   this.m_ticket=ticket;
   this.m_long_prop[ORDER_PROP_STATUS]                               = order_status;
   this.m_long_prop[ORDER_PROP_MAGIC]                                = this.OrderMagicNumber();
   this.m_long_prop[ORDER_PROP_TICKET]                               = this.OrderTicket();
   this.m_long_prop[ORDER_PROP_TIME_OPEN]                            = (long)(ulong)this.OrderOpenTime();
   this.m_long_prop[ORDER_PROP_TIME_CLOSE]                           = (long)(ulong)this.OrderCloseTime();
   this.m_long_prop[ORDER_PROP_TIME_EXP]                             = (long)(ulong)this.OrderExpiration();
   this.m_long_prop[ORDER_PROP_TYPE]                                 = this.OrderType();
   this.m_long_prop[ORDER_PROP_STATE]                                = this.OrderState();
   this.m_long_prop[ORDER_PROP_DIRECTION]                            = this.OrderTypeByDirection();
   this.m_long_prop[ORDER_PROP_POSITION_ID]                          = this.OrderPositionID();
   this.m_long_prop[ORDER_PROP_REASON]                               = this.OrderReason();
   this.m_long_prop[ORDER_PROP_DEAL_ORDER_TICKET]                    = this.DealOrderTicket();
   this.m_long_prop[ORDER_PROP_DEAL_ENTRY]                           = this.DealEntry();
   this.m_long_prop[ORDER_PROP_POSITION_BY_ID]                       = this.OrderPositionByID();
   this.m_long_prop[ORDER_PROP_TIME_OPEN_MSC]                        = this.OrderOpenTimeMSC();
   this.m_long_prop[ORDER_PROP_TIME_CLOSE_MSC]                       = this.OrderCloseTimeMSC();
   this.m_long_prop[ORDER_PROP_TIME_UPDATE]                          = (long)(ulong)this.PositionTimeUpdate();
   this.m_long_prop[ORDER_PROP_TIME_UPDATE_MSC]                      = (long)(ulong)this.PositionTimeUpdateMSC();
   
//--- Сохранение вещественных свойств
   this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_OPEN)]         = this.OrderOpenPrice();
   this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_CLOSE)]        = this.OrderClosePrice();
   this.m_double_prop[this.IndexProp(ORDER_PROP_PROFIT)]             = this.OrderProfit();
   this.m_double_prop[this.IndexProp(ORDER_PROP_COMMISSION)]         = this.OrderCommission();
   this.m_double_prop[this.IndexProp(ORDER_PROP_SWAP)]               = this.OrderSwap();
   this.m_double_prop[this.IndexProp(ORDER_PROP_VOLUME)]             = this.OrderVolume();
   this.m_double_prop[this.IndexProp(ORDER_PROP_SL)]                 = this.OrderStopLoss();
   this.m_double_prop[this.IndexProp(ORDER_PROP_TP)]                 = this.OrderTakeProfit();
   this.m_double_prop[this.IndexProp(ORDER_PROP_VOLUME_CURRENT)]     = this.OrderVolumeCurrent();
   this.m_double_prop[this.IndexProp(ORDER_PROP_PRICE_STOP_LIMIT)]   = this.OrderPriceStopLimit();
   
//--- Сохранение строковых свойств
   this.m_string_prop[this.IndexProp(ORDER_PROP_SYMBOL)]             = this.OrderSymbol();
   this.m_string_prop[this.IndexProp(ORDER_PROP_COMMENT)]            = this.OrderComment();
   this.m_string_prop[this.IndexProp(ORDER_PROP_EXT_ID)]             = this.OrderExternalID();
   
//--- Сохранение дополнительных целочисленных свойств
   this.m_long_prop[ORDER_PROP_PROFIT_PT]                            = this.ProfitInPoints();
   this.m_long_prop[ORDER_PROP_TICKET_FROM]                          = this.OrderTicketFrom();
   this.m_long_prop[ORDER_PROP_TICKET_TO]                            = this.OrderTicketTo();
   this.m_long_prop[ORDER_PROP_CLOSE_BY_SL]                          = this.OrderCloseByStopLoss();
   this.m_long_prop[ORDER_PROP_CLOSE_BY_TP]                          = this.OrderCloseByTakeProfit();
   this.m_long_prop[ORDER_PROP_GROUP_ID]                             = 0;
   
//--- Сохранение дополнительных вещественных свойств
   this.m_double_prop[this.IndexProp(ORDER_PROP_PROFIT_FULL)]        = this.ProfitFull();
  }
//+------------------------------------------------------------------+
//| Сравнивает объекты COrder между собой по всем возможным свойствам|
//+------------------------------------------------------------------+
int COrder::Compare(const CObject *node,const int mode=0) const
  {
   const COrder *order_compared=node;
//--- сравнение целочисленных свойств двух ордеров
   if(mode<ORDER_PROP_INTEGER_TOTAL)
     {
      long value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_ORDER_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- сравнение вещественных свойств двух ордеров
   else if(mode<ORDER_PROP_DOUBLE_TOTAL+ORDER_PROP_INTEGER_TOTAL)
     {
      double value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_ORDER_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- сравнение строковых свойств двух ордеров
   else if(mode<ORDER_PROP_DOUBLE_TOTAL+ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_STRING_TOTAL)
     {
      string value_compared=order_compared.GetProperty((ENUM_ORDER_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_ORDER_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Сравнивает объекты COrder между собой по всем свойствам          |
//+------------------------------------------------------------------+
bool COrder::IsEqual(COrder *compared_order) const
  {
   int beg=0, end=ORDER_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_INTEGER prop=(ENUM_ORDER_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_order.GetProperty(prop)) return false; 
     }
   beg=end; end+=ORDER_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_DOUBLE prop=(ENUM_ORDER_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_order.GetProperty(prop)) return false; 
     }
   beg=end; end+=ORDER_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_STRING prop=(ENUM_ORDER_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_order.GetProperty(prop)) return false; 
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Целочисленные свойства                                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Возвращает магик                                                 |
//+------------------------------------------------------------------+
long COrder::OrderMagicNumber() const
  {
#ifdef __MQL4__
   return ::OrderMagicNumber();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_MAGIC);           break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_MAGIC);                 break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_MAGIC);   break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_MAGIC); break;
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает тикет                                                 |
//+------------------------------------------------------------------+
long COrder::OrderTicket(void) const
  {
#ifdef __MQL4__
   return ::OrderTicket();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   :
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     :
      case ORDER_STATUS_DEAL              : res=(long)m_ticket;                                 break;
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает тикет родительского ордера                            |
//+------------------------------------------------------------------+
long COrder::OrderTicketFrom(void) const
  {
   long ticket=0;
#ifdef __MQL4__
   string order_comment=::OrderComment();
   if(::StringFind(order_comment,"from #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,6));
#endif
   return ticket;
  }
//+------------------------------------------------------------------+
//| Возвращает тикет дочернего ордера                                |
//+------------------------------------------------------------------+
long COrder::OrderTicketTo(void) const
  {
   long ticket=0;
#ifdef __MQL4__
   string order_comment=::OrderComment();
   if(::StringFind(order_comment,"to #")>WRONG_VALUE) ticket=::StringToInteger(::StringSubstr(order_comment,4));
#endif
   return ticket;
  }
//+------------------------------------------------------------------+
//| Возвращает идентификатор позиции                                 |
//+------------------------------------------------------------------+
long COrder::OrderPositionID(void) const
  {
#ifdef __MQL4__
   return ::OrderMagicNumber();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_IDENTIFIER);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_ID);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_POSITION_ID);   break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает идентификатор встречной позиции                       |
//+------------------------------------------------------------------+
long COrder::OrderPositionByID(void) const
  {
#ifdef __MQL4__
   return 0;
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_BY_ID);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_BY_ID); break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия в милисекундах                         |
//+------------------------------------------------------------------+
long COrder::OrderOpenTimeMSC(void) const
  {
#ifdef __MQL4__
   return (long)::OrderOpenTime();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_TIME_MSC);                 break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TIME_SETUP_MSC);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TIME_SETUP_MSC); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_TIME_MSC);         break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает время закрытия в милисекундах                         |
//+------------------------------------------------------------------+
long COrder::OrderCloseTimeMSC(void) const
  {
#ifdef __MQL4__
   return (long)::OrderCloseTime();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TIME_DONE_MSC);     break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME_MSC);  break;
      default                             : res=0;                                                          break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает тип                                                   |
//+------------------------------------------------------------------+
long COrder::OrderType(void) const
  {
#ifdef __MQL4__
   return (long)::OrderType();
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_TYPE);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_TYPE);    break;
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает состояние ордера                                      |
//+------------------------------------------------------------------+
long COrder::OrderState(void) const
  {
#ifdef __MQL4__
   return ORDER_STATE_FILLED;
#else
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_STATE); break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_STATE);                 break;
      case ORDER_STATUS_MARKET_POSITION   : 
      case ORDER_STATUS_DEAL              : 
      default                             : res=0;                                              break;
     }
   return res;
#endif
  }
//+------------------------------------------------------------------+
//| Возвращает тип по направлению                                    |
//+------------------------------------------------------------------+
long COrder::OrderTypeByDirection(void) const
  {
   ENUM_ORDER_STATUS status=(ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS);
   if(status==ORDER_STATUS_MARKET_POSITION)
     {
      return(this.OrderType()==POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
     }
   else if(status==ORDER_STATUS_MARKET_PENDING || status==ORDER_STATUS_HISTORY_PENDING)
     {
      return
        (
         this.OrderType()==ORDER_TYPE_BUY_LIMIT || 
         this.OrderType()==ORDER_TYPE_BUY_STOP 
         #ifdef __MQL5__                        ||
         this.OrderType()==ORDER_TYPE_BUY_STOP_LIMIT 
         #endif ? 
         ORDER_TYPE_BUY : 
         ORDER_TYPE_SELL
        );
     }
   else if(status==ORDER_STATUS_MARKET_ORDER || status==ORDER_STATUS_HISTORY_ORDER)
     {
      return this.OrderType();
     }
   else if(status==ORDER_STATUS_DEAL)
     {
      return
        (
         (ENUM_DEAL_TYPE)this.TypeOrder()==DEAL_TYPE_BUY ? ORDER_TYPE_BUY   :
         (ENUM_DEAL_TYPE)this.TypeOrder()==DEAL_TYPE_SELL ? ORDER_TYPE_SELL : WRONG_VALUE
        );
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает тип исполнения по остатку                             |
//+------------------------------------------------------------------+
long COrder::OrderTypeFilling(void) const
  {
#ifdef __MQL4__
   return (long)ORDER_FILLING_RETURN;
#else 
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE_FILLING);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE_FILLING);break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает время жизни ордера                                    |
//+------------------------------------------------------------------+
long COrder::OrderTypeTime(void) const
  {
#ifdef __MQL4__
   return (long)ORDER_TIME_GTC;
#else 
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_TYPE_TIME);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_TYPE_TIME);break;
      default                             : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Причина или источник выставления ордера                          |
//+------------------------------------------------------------------+
long COrder::OrderReason(void) const
  {
#ifdef __MQL4__
   return
     (
      this.OrderCloseByStopLoss()   ?  ORDER_REASON_SL      :
      this.OrderCloseByTakeProfit() ?  ORDER_REASON_TP      :  
      this.OrderMagicNumber()!=0    ?  ORDER_REASON_EXPERT  : WRONG_VALUE
     );
#else 
   long res=WRONG_VALUE;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_REASON);          break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_REASON);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_REASON);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_REASON);  break;
      default                             : res=WRONG_VALUE;                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Тикет ордера, на основании которого выполнена сделка             |
//+------------------------------------------------------------------+
long COrder::DealOrderTicket(void) const
  {
#ifdef __MQL4__
   return ::OrderTicket();
#else 
   long res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetInteger(POSITION_IDENTIFIER);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetInteger(ORDER_POSITION_ID);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetInteger(m_ticket,DEAL_ORDER);         break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Направление сделки IN, OUT, IN/OUT                               |
//+------------------------------------------------------------------+
long COrder::DealEntry(void) const
  {
#ifdef __MQL4__
   return ::OrderType();
#else 
   long res=WRONG_VALUE;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_DEAL  : res=::HistoryDealGetInteger(m_ticket,DEAL_ENTRY);break;
      default                 : res=WRONG_VALUE;                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает флаг закрытия позиции по StopLoss                     |
//+------------------------------------------------------------------+
bool COrder::OrderCloseByStopLoss(void) const
  {
#ifdef __MQL4__
   return(::StringFind(::OrderComment(),"[sl")>WRONG_VALUE);
#else 
   return
     (
      this.Status()==ORDER_STATUS_MARKET_ORDER  ? this.OrderReason()==ORDER_REASON_SL :
      this.Status()==ORDER_STATUS_HISTORY_ORDER ? this.OrderReason()==ORDER_REASON_SL : 
      this.Status()==ORDER_STATUS_DEAL ? this.OrderReason()==DEAL_REASON_SL : false
     );
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает флаг закрытия позиции по TakeProfit                   |
//+------------------------------------------------------------------+
bool COrder::OrderCloseByTakeProfit(void) const
  {
#ifdef __MQL4__
   return(::StringFind(::OrderComment(),"[tp")>WRONG_VALUE);
#else 
   return
     (
      this.Status()==ORDER_STATUS_MARKET_ORDER  ? this.OrderReason()==ORDER_REASON_TP : 
      this.Status()==ORDER_STATUS_HISTORY_ORDER ? this.OrderReason()==ORDER_REASON_TP : 
      this.Status()==ORDER_STATUS_DEAL ? this.OrderReason()==DEAL_REASON_TP : false
     );
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия                                        |
//+------------------------------------------------------------------+
datetime COrder::OrderOpenTime(void) const
  {
#ifdef __MQL4__
   return ::OrderOpenTime();
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME);                 break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=(datetime)::OrderGetInteger(ORDER_TIME_SETUP);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_SETUP); break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME);         break;
      default                             : res=0;                                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает время закрытия                                        |
//+------------------------------------------------------------------+
datetime COrder::OrderCloseTime(void) const
  {
#ifdef __MQL4__
   return ::OrderCloseTime();
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_DONE);  break;
      case ORDER_STATUS_DEAL              : res=(datetime)::HistoryDealGetInteger(m_ticket,DEAL_TIME);         break;
      default                             : res=0;                                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает время экспирации                                      |
//+------------------------------------------------------------------+
datetime COrder::OrderExpiration(void) const
  {
#ifdef __MQL4__
   return ::OrderExpiration();
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=(datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);                  break;
      case ORDER_STATUS_HISTORY_PENDING   : res=(datetime)::HistoryOrderGetInteger(m_ticket,ORDER_TIME_EXPIRATION);  break;
      default                             : res=0;                                                                   break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Время изменения позиции в секундах                               |
//+------------------------------------------------------------------+
datetime COrder::PositionTimeUpdate(void) const
  {
#ifdef __MQL4__
   return 0;
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME_UPDATE); break;
      default                             : res=0;                                                    break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Время изменения позиции в милисекундах                           |
//+------------------------------------------------------------------+
datetime COrder::PositionTimeUpdateMSC(void) const
  {
#ifdef __MQL4__
   return 0;
#else 
   datetime res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=(datetime)::PositionGetInteger(POSITION_TIME_UPDATE_MSC);   break;
      default                             : res=0;                                                          break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Вещественные свойства                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Возвращает цену открытия                                         |
//+------------------------------------------------------------------+
double COrder::OrderOpenPrice(void) const
  {
#ifdef __MQL4__
   return ::OrderOpenPrice();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_PRICE_OPEN);          break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_PRICE_OPEN);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PRICE);       break;
      default                             : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает цену закрытия                                         |
//+------------------------------------------------------------------+
double COrder::OrderClosePrice(void) const
  {
#ifdef __MQL4__
   return ::OrderClosePrice();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PRICE);       break;
      default                             : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает профит                                                |
//+------------------------------------------------------------------+
double COrder::OrderProfit(void) const
  {
#ifdef __MQL4__
   return ::OrderProfit();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_PROFIT);           break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_PROFIT);   break;
      default                             : res=0;                                              break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает комиссию                                              |
//+------------------------------------------------------------------+
double COrder::OrderCommission(void) const
  {
#ifdef __MQL4__
   return ::OrderCommission();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_DEAL  : res=::HistoryDealGetDouble(m_ticket,DEAL_COMMISSION);  break;
      default                 : res=0;                                                 break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает своп                                                  |
//+------------------------------------------------------------------+
double COrder::OrderSwap(void) const
  {
#ifdef __MQL4__
   return ::OrderSwap();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_SWAP);          break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_SWAP);  break;
      default                             : res=0;                                           break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает объём                                                 |
//+------------------------------------------------------------------+
double COrder::OrderVolume(void) const
  {
#ifdef __MQL4__
   return ::OrderLots();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_VOLUME);                    break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_VOLUME_INITIAL);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_INITIAL);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetDouble(m_ticket,DEAL_VOLUME);            break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает невыполненный объем                                   |
//+------------------------------------------------------------------+
double COrder::OrderVolumeCurrent(void) const
  {
#ifdef __MQL4__
   return ::OrderLots();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_VOLUME_CURRENT);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_CURRENT);  break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает цену StopLoss                                         |
//+------------------------------------------------------------------+
double COrder::OrderStopLoss(void) const
  {
#ifdef __MQL4__
   return ::OrderStopLoss();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_SL);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_SL);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_SL);  break;
      default                             : res=0;                                           break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает цену TakeProfit                                       |
//+------------------------------------------------------------------+
double COrder::OrderTakeProfit(void) const
  {
#ifdef __MQL4__
   return ::OrderTakeProfit();
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetDouble(POSITION_TP);            break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_TP);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_TP);  break;
      default                             : res=0;                                           break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает цену постановки Limit ордера                          |
//| при срабатывании StopLimit ордера                                |
//+------------------------------------------------------------------+
double COrder::OrderPriceStopLimit(void) const
  {
#ifdef __MQL4__
   return 0;
#else 
   double res=0;
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetDouble(ORDER_PRICE_STOPLIMIT);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetDouble(m_ticket,ORDER_PRICE_STOPLIMIT); break;
      default                             : res=0;                                                       break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Строковые свойства                                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Возвращает символ                                                |
//+------------------------------------------------------------------+
string COrder::OrderSymbol(void) const
  {
#ifdef __MQL4__
   return ::OrderSymbol();
#else 
   string res="";
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetString(POSITION_SYMBOL);           break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_SYMBOL);                 break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_SYMBOL); break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_SYMBOL);   break;
      default                             : res="";                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает комментарий                                           |
//+------------------------------------------------------------------+
string COrder::OrderComment(void) const
  {
#ifdef __MQL4__
   return ::OrderComment();
#else 
   string res="";
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_POSITION   : res=::PositionGetString(POSITION_COMMENT);          break;
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_COMMENT);                break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_COMMENT);break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_COMMENT);  break;
      default                             : res="";                                             break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает идентификатор на бирже                                |
//+------------------------------------------------------------------+
string COrder::OrderExternalID(void) const
  {
#ifdef __MQL4__
   return "";
#else 
   string res="";
   switch((ENUM_ORDER_STATUS)this.GetProperty(ORDER_PROP_STATUS))
     {
      case ORDER_STATUS_MARKET_ORDER      :
      case ORDER_STATUS_MARKET_PENDING    : res=::OrderGetString(ORDER_EXTERNAL_ID);                  break;
      case ORDER_STATUS_HISTORY_PENDING   :
      case ORDER_STATUS_HISTORY_ORDER     : res=::HistoryOrderGetString(m_ticket,ORDER_EXTERNAL_ID);  break;
      case ORDER_STATUS_DEAL              : res=::HistoryDealGetString(m_ticket,DEAL_EXTERNAL_ID);    break;
      default                             : res="";                                                   break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает профит ордера в пунктах                               |
//+------------------------------------------------------------------+
int COrder::ProfitInPoints(void) const
  {
   MqlTick tick={0};
   string symbol=this.Symbol();
   if(!::SymbolInfoTick(symbol,tick))
      return 0;
   ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)this.TypeOrder();
   double point=::SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(type==ORDER_TYPE_CLOSE_BY || point==0) return 0;
   if(this.Status()==ORDER_STATUS_HISTORY_ORDER)
      return int(type==ORDER_TYPE_BUY ? (this.PriceClose()-this.PriceOpen())/point : type==ORDER_TYPE_SELL ? (this.PriceOpen()-this.PriceClose())/point : 0);
   else if(this.Status()==ORDER_STATUS_MARKET_POSITION)
     {
      if(type==ORDER_TYPE_BUY)
         return int((tick.bid-this.PriceOpen())/point);
      else if(type==ORDER_TYPE_SELL)
         return int((this.PriceOpen()-tick.ask)/point);
     }
   else if(this.Status()==ORDER_STATUS_MARKET_PENDING)
     {
      if(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_BUY_STOP_LIMIT)
         return (int)fabs((tick.bid-this.PriceOpen())/point);
      else if(type==ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP || type==ORDER_TYPE_SELL_STOP_LIMIT)
         return (int)fabs((this.PriceOpen()-tick.ask)/point);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Описание причины                                                 |
//+------------------------------------------------------------------+
string COrder::GetReasonDescription(const long reason) const
  {
#ifdef __MQL4__
   return
     (
      this.IsCloseByStopLoss()            ?  TextByLanguage("Срабатывание StopLoss","Due to StopLoss")                  :
      this.IsCloseByTakeProfit()          ?  TextByLanguage("Срабатывание TakeProfit","Due to TakeProfit")              :
      this.Reason()==ORDER_REASON_EXPERT  ?  TextByLanguage("Выставлен из mql4-программы","Placed from mql4 program")   :
      TextByLanguage("Свойство не поддерживается в MQL4","Property is not supported in MQL4")
     );
#else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_MARKET_POSITION      : 
         res=
           (
            reason==POSITION_REASON_CLIENT   ?  TextByLanguage("Позиция открыта из десктопного терминала","Position is open from the desktop terminal") :
            reason==POSITION_REASON_MOBILE   ?  TextByLanguage("Позиция открыта из мобильного приложения","Position is open from the mobile app") :
            reason==POSITION_REASON_WEB      ?  TextByLanguage("Позиция открыта из веб-платформы","Position is open from the web platform") :
            reason==POSITION_REASON_EXPERT   ?  TextByLanguage("Позиция открыта из советника или скрипта","The position is open from the EA or script") : ""
           );
         break;
      case ORDER_STATUS_MARKET_ORDER         :
      case ORDER_STATUS_MARKET_PENDING       :
      case ORDER_STATUS_HISTORY_PENDING      : 
      case ORDER_STATUS_HISTORY_ORDER        : 
         res=
           (
            reason==ORDER_REASON_CLIENT      ?  TextByLanguage("Ордер выставлен из десктопного терминала","Order is set from the desktop terminal") :
            reason==ORDER_REASON_MOBILE      ?  TextByLanguage("Ордер выставлен из мобильного приложения","Order is set from the mobile app") :
            reason==ORDER_REASON_WEB         ?  TextByLanguage("Ордер выставлен из веб-платформы","Oder is set from the web platform") :
            reason==ORDER_REASON_EXPERT      ?  TextByLanguage("Ордер выставлен советником или скриптом","Order is set from the EA or script") :
            reason==ORDER_REASON_SL          ?  TextByLanguage("Срабатывание StopLoss","Due to StopLoss") :
            reason==ORDER_REASON_TP          ?  TextByLanguage("Срабатывание TakeProfit","Due to TakeProfit") :
            reason==ORDER_REASON_SO          ?  TextByLanguage("Ордер выставлен в результате наступления Stop Out","Due to Stop Out") : ""
           );
         break;
      case ORDER_STATUS_DEAL                 : 
         res=
           (
            reason==DEAL_REASON_CLIENT       ?  TextByLanguage("Сделка проведена из десктопного терминала","Deal was carried out from the desktop terminal") :
            reason==DEAL_REASON_MOBILE       ?  TextByLanguage("Сделка проведена из мобильного приложения","Deal was carried out from the mobile app") :
            reason==DEAL_REASON_WEB          ?  TextByLanguage("Сделка проведена из веб-платформы","Deal was carried out from the web platform") :
            reason==DEAL_REASON_EXPERT       ?  TextByLanguage("Сделка проведена из советника или скрипта","Deal was carried out from the EA or script") :
            reason==DEAL_REASON_SL           ?  TextByLanguage("Срабатывание StopLoss","Due to StopLoss") :
            reason==DEAL_REASON_TP           ?  TextByLanguage("Срабатывание TakeProfit","Due to TakeProfit") :
            reason==DEAL_REASON_SO           ?  TextByLanguage("Сделка проведена в результате наступления Stop Out","Due to Stop Out") :
            reason==DEAL_REASON_ROLLOVER     ?  TextByLanguage("Сделка проведена по причине переноса позиции","Due to position rollover") :
            reason==DEAL_REASON_VMARGIN      ?  TextByLanguage("Сделка проведена по причине начисления/списания вариационной маржи","Due to variation margin") :
            reason==DEAL_REASON_SPLIT        ?  TextByLanguage("Сделка проведена по причине сплита (понижения цены) инструмента","Due to the split") : ""
           );
         break;
      default                                : res="";   break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Описание направления сделки                                      |
//+------------------------------------------------------------------+
string COrder::GetEntryDescription(const long deal_entry) const
  {
#ifdef __MQL4__
   return TextByLanguage("Свойство не поддерживается в MQL4","Property is not supported in MQL4");
#else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_MARKET_POSITION   : 
         res=TextByLanguage("Свойство не поддерживается у позиции","Property not supported for position"); 
         break;
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   : 
         res=TextByLanguage("Свойство не поддерживается у отложенного ордера","The property is not supported for a pending order"); 
         break;
      case ORDER_STATUS_MARKET_ORDER      :
         res=TextByLanguage("Свойство не поддерживается у маркет-ордера","The property is not supported for a market-order"); 
         break;
      case ORDER_STATUS_HISTORY_ORDER     : 
         res=TextByLanguage("Свойство не поддерживается у исторического маркет-ордера","The property is not supported for a history market-order"); 
         break;
      case ORDER_STATUS_DEAL              : 
         res=
           (
            deal_entry==DEAL_ENTRY_IN     ?  TextByLanguage("Вход в рынок","Entry to the market") :
            deal_entry==DEAL_ENTRY_OUT    ?  TextByLanguage("Выход из рынка","Out from the market") :
            deal_entry==DEAL_ENTRY_INOUT  ?  TextByLanguage("Разворот","Turning in the opposite direction") :
            deal_entry==DEAL_ENTRY_OUT_BY ?  TextByLanguage("Закрытие встречной позицией","Closing by opposite position") : ""
           );
         break;
      default                             : res=""; break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает наименование типа сделки                              |
//+------------------------------------------------------------------+
string COrder::GetTypeDealDescription(const long deal_type) const
  {
#ifdef __MQL4__
   return TextByLanguage("Свойство не поддерживается в MQL4","Property is not supported in MQL4");
#else 
   string res="";
   switch(this.Status())
     {
      case ORDER_STATUS_DEAL              : 
         res=DealTypeDescription((ENUM_DEAL_TYPE)deal_type);
         break;
      case ORDER_STATUS_MARKET_POSITION   : 
         res=TextByLanguage("Свойство не поддерживается у позиции","Property not supported for position"); 
         break;
      case ORDER_STATUS_MARKET_PENDING    :
      case ORDER_STATUS_HISTORY_PENDING   : 
         res=TextByLanguage("Свойство не поддерживается у отложенного ордера","The property is not supported for a pending order"); 
         break;
      case ORDER_STATUS_MARKET_ORDER      :
         res=TextByLanguage("Свойство не поддерживается у маркет-ордера","The property is not supported for a market-order"); 
         break;
      case ORDER_STATUS_HISTORY_ORDER     : 
         res=TextByLanguage("Свойство не поддерживается у исторического маркет-ордера","The property is not supported for a history market-order"); 
         break;
      default  : res=""; break;
     }
   return res;
#endif 
  }
//+------------------------------------------------------------------+
//| Возвращает наименование статуса ордера                           |
//+------------------------------------------------------------------+
string COrder::StatusDescription(void) const
  {
   ENUM_ORDER_STATUS status=this.Status();
   ENUM_ORDER_TYPE   type=(ENUM_ORDER_TYPE)this.TypeOrder();
   return
     (
      status==ORDER_STATUS_BALANCE           ?  TextByLanguage("Балансная операция","Balance operation") :
      status==ORDER_STATUS_CREDIT            ?  TextByLanguage("Кредитная операция","Credits operation") :
      status==ORDER_STATUS_MARKET_ORDER || status==ORDER_STATUS_HISTORY_ORDER ?  
         (
          type==ORDER_TYPE_CLOSE_BY ? TextByLanguage("Закрывающий ордер","Order for closing by")         :
          TextByLanguage("Ордер на ","The order to ")+(type==ORDER_TYPE_BUY ? TextByLanguage("покупку","buy") : TextByLanguage("продажу","sell"))
         ) :
      status==ORDER_STATUS_DEAL              ?  TextByLanguage("Сделка","Deal")                          :
      status==ORDER_STATUS_MARKET_POSITION   ?  TextByLanguage("Позиция","Active position")              :
      status==ORDER_STATUS_MARKET_PENDING    ?  TextByLanguage("Установленный отложенный ордер","Active pending order") :
      status==ORDER_STATUS_HISTORY_PENDING   ?  TextByLanguage("Отложенный ордер","Pending order") :
      EnumToString(status)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование ордера или позиции                       |
//+------------------------------------------------------------------+
string COrder::TypeDescription(void) const
  {
   return
     (
      this.Status()==ORDER_STATUS_DEAL ? this.GetTypeDealDescription(this.TypeOrder()) :
      this.Status()==ORDER_STATUS_MARKET_POSITION ? this.DirectionDescription() :
      OrderTypeDescription((ENUM_ORDER_TYPE)this.TypeOrder())
     );
  }
//+------------------------------------------------------------------+
//| Возвращает описание состояния ордера                             |
//+------------------------------------------------------------------+
string COrder::StateDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL || this.Status()==ORDER_STATUS_MARKET_POSITION)
      return "";
   else switch(this.State())
     {
      case ORDER_STATE_STARTED         :  return TextByLanguage("Ордер проверен на корректность, но еще не принят брокером","The order is checked for correctness, but not yet accepted by the broker");
      case ORDER_STATE_PLACED          :  return TextByLanguage("Ордер принят","Order accepted");
      case ORDER_STATE_CANCELED        :  return TextByLanguage("Ордер снят клиентом","Order withdrawn by client");
      case ORDER_STATE_PARTIAL         :  return TextByLanguage("Ордер выполнен частично","The order is filled partially");
      case ORDER_STATE_FILLED          :  return TextByLanguage("Ордер выполнен полностью","The order is filled");
      case ORDER_STATE_REJECTED        :  return TextByLanguage("Ордер отклонен","Order rejected");
      case ORDER_STATE_EXPIRED         :  return TextByLanguage("Ордер снят по истечении срока его действия","Order withdrawn upon expiration");
      case ORDER_STATE_REQUEST_ADD     :  return TextByLanguage("Ордер в состоянии регистрации (выставление в торговую систему)","Order in the state of registration (placing in the trading system)");
      case ORDER_STATE_REQUEST_MODIFY  :  return TextByLanguage("Ордер в состоянии модификации","The order is in a state of modification.");
      case ORDER_STATE_REQUEST_CANCEL  :  return TextByLanguage("Ордер в состоянии удаления","Order is in deletion state");
      default                          :  return TextByLanguage("Неизвестное состояние","Unknown state");
     }
  }
//+------------------------------------------------------------------+
//| Возвращает наименование направления сделки                       |
//+------------------------------------------------------------------+
string COrder::DealEntryDescription(void) const
  {
   return(this.Status()==ORDER_STATUS_DEAL ? this.GetEntryDescription(this.GetProperty(ORDER_PROP_DEAL_ENTRY)) : "");
  }
//+------------------------------------------------------------------+
//| Возвращает тип по направлению ордера/позиции                     |
//+------------------------------------------------------------------+
string COrder::DirectionDescription(void) const
  {
   if(this.Status()==ORDER_STATUS_DEAL)
      return 
        (
         this.OrderType()==DEAL_TYPE_BALANCE ? 
           (
            this.OrderProfit()>0 ? TextByLanguage("Пополнение счёта","Account refilled") : 
            TextByLanguage("Вывод средств","Withdrawals from the account")
           )                                          :
         this.OrderType()==DEAL_TYPE_BUY     ? "Buy"  : 
         this.OrderType()==DEAL_TYPE_SELL    ? "Sell" :
         this.TypeDescription()
        );
   switch(this.TypeByDirection())
     {
      case ORDER_TYPE_BUY  :  return "Buy";
      case ORDER_TYPE_SELL :  return "Sell";
      default              :  return TextByLanguage("Неизвестный тип","Unknown type");
     }
  }
//+------------------------------------------------------------------+
//| Выводит в журнал свойства ордера                                 |
//+------------------------------------------------------------------+
void COrder::Print(const bool full_prop=false)
  {
   ::Print("============= ",TextByLanguage("Начало списка параметров: \"","The beginning of the parameter list: \""),this.StatusDescription(),"\" =============");
   int beg=0, end=ORDER_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_INTEGER prop=(ENUM_ORDER_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=ORDER_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_DOUBLE prop=(ENUM_ORDER_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=ORDER_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_ORDER_PROP_STRING prop=(ENUM_ORDER_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("================== ",TextByLanguage("Конец списка параметров: \"","End of the parameter list: \""),this.StatusDescription(),"\" ==================\n");
  }
//+------------------------------------------------------------------+
//| Возвращает описание целочисленного свойства ордера               |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_INTEGER property)
  {
   return
     (
   //--- Общие свойства
      property==ORDER_PROP_MAGIC             ?  TextByLanguage("Магик","Magic")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET            ?  TextByLanguage("Тикет","Ticket")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET_FROM       ?  TextByLanguage("Тикет родительского ордера","Ticket of parent order")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TICKET_TO         ?  TextByLanguage("Тикет наследуемого ордера","Inherited order ticket")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          " #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TIME_OPEN         ?  TextByLanguage("Время открытия","Time open")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS)
         )  :
      property==ORDER_PROP_TIME_CLOSE        ?  TextByLanguage("Время закрытия","Time close")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS)
         )  :
      property==ORDER_PROP_TIME_EXP          ?  TextByLanguage("Дата экспирации","Date of expiration")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          (this.GetProperty(property)==0     ?  TextByLanguage(": Не задана",": Not set") :
          ": "+::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS))
         )  :
      property==ORDER_PROP_TYPE              ?  TextByLanguage("Тип","Type")+": "+this.TypeDescription()                   :
      property==ORDER_PROP_DIRECTION         ?  TextByLanguage("Тип по направлению","Type by direction")+": "+this.DirectionDescription() :
      
      property==ORDER_PROP_REASON            ?  TextByLanguage("Причина","Reason")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+this.GetReasonDescription(this.GetProperty(property))
         )  :
      property==ORDER_PROP_POSITION_ID       ?  TextByLanguage("Идентификатор позиции","Position identifier")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_DEAL_ORDER_TICKET ?  TextByLanguage("Сделка на основании ордера с тикетом","Deal by order ticket")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": #"+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_DEAL_ENTRY        ?  TextByLanguage("Направление сделки","Deal entry")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+this.GetEntryDescription(this.GetProperty(property))
         )  :
      property==ORDER_PROP_POSITION_BY_ID    ?  TextByLanguage("Идентификатор встречной позиции","Identifier opposite position")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_TIME_OPEN_MSC     ?  TextByLanguage("Время открытия в милисекундах","Opening time in milliseconds")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+TimeMSCtoString(this.GetProperty(property))+" ("+(string)this.GetProperty(property)+")"
         )  :
      property==ORDER_PROP_TIME_CLOSE_MSC    ?  TextByLanguage("Время закрытия в милисекундах","Closing time in milliseconds")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+TimeMSCtoString(this.GetProperty(property))+" ("+(string)this.GetProperty(property)+")"
         )  :
      property==ORDER_PROP_TIME_UPDATE       ?  TextByLanguage("Время изменения позиции","Position change time")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(this.GetProperty(property)!=0 ? ::TimeToString(this.GetProperty(property),TIME_DATE|TIME_MINUTES|TIME_SECONDS) : "0")
         )  :
      property==ORDER_PROP_TIME_UPDATE_MSC   ?  TextByLanguage("Время изменения позиции в милисекундах","Time to change the position in milliseconds")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(this.GetProperty(property)!=0 ? TimeMSCtoString(this.GetProperty(property))+" ("+(string)this.GetProperty(property)+")" : "0")
         )  :
      property==ORDER_PROP_STATE             ?  TextByLanguage("Состояние","Statе")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": \""+this.StateDescription()+"\""
         )  :
   //--- Дополнительное свойство
      property==ORDER_PROP_STATUS            ?  TextByLanguage("Статус","Status")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": \""+this.StatusDescription()+"\""
         )  :
      property==ORDER_PROP_PROFIT_PT         ?  (
                                                 this.Status()==ORDER_STATUS_MARKET_PENDING ? 
                                                 TextByLanguage("Дистанция от цены в пунктах","Distance from price in points") : 
                                                 TextByLanguage("Прибыль в пунктах","Profit in points")
                                                )+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(string)this.GetProperty(property)
         )  :
      property==ORDER_PROP_CLOSE_BY_SL       ?  TextByLanguage("Закрытие по StopLoss","Close by StopLoss")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(this.GetProperty(property)   ?  TextByLanguage("Да","Yes") : TextByLanguage("Нет","No"))
         )  :
      property==ORDER_PROP_CLOSE_BY_TP       ?  TextByLanguage("Закрытие по TakeProfit","Close by TakeProfit")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(this.GetProperty(property)   ?  TextByLanguage("Да","Yes") : TextByLanguage("Нет","No"))
         )  :
      property==ORDER_PROP_GROUP_ID          ?  TextByLanguage("Идентификатор группы","Group's identifier")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+(string)this.GetProperty(property)
         )  :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Возвращает описание вещественного свойства ордера                |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_DOUBLE property)
  {
   int dg=(int)::SymbolInfoInteger(this.GetProperty(ORDER_PROP_SYMBOL),SYMBOL_DIGITS);
   int dgl=(int)DigitsLots(this.GetProperty(ORDER_PROP_SYMBOL));
   return
     (
      //--- Общие свойства
      property==ORDER_PROP_PRICE_CLOSE       ?  TextByLanguage("Цена закрытия","Price close")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==ORDER_PROP_PRICE_OPEN        ?  TextByLanguage("Цена открытия","Price open")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),dg)
         )  :
      property==ORDER_PROP_SL                ?  TextByLanguage("Цена StopLoss","Price StopLoss")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          (this.GetProperty(property)==0     ?  TextByLanguage(": Отсутствует",": Not set"):": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_TP                ?  TextByLanguage("Цена TakeProfit","Price TakeProfit")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          (this.GetProperty(property)==0     ?  TextByLanguage(": Отсутствует",": Not set"):": "+::DoubleToString(this.GetProperty(property),dg))
         )  :
      property==ORDER_PROP_PROFIT            ?  TextByLanguage("Прибыль","Profit")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_COMMISSION        ?  TextByLanguage("Комиссия","Comission")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_SWAP              ?  TextByLanguage("Своп","Swap")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),2)
         )  :
      property==ORDER_PROP_VOLUME            ?  TextByLanguage("Объём","Volume")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
          ) :
      property==ORDER_PROP_VOLUME_CURRENT    ?  TextByLanguage("Невыполненный объём","Unfulfilled volume")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),dgl)
          ) :
      property==ORDER_PROP_PRICE_STOP_LIMIT  ? 
         TextByLanguage("Цена постановки Limit ордера при активации StopLimit ордера","The price of placing Limit order when StopLimit order are activated")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),dg)
          ) :
      //--- Дополнительное свойство
      property==ORDER_PROP_PROFIT_FULL       ?  TextByLanguage("Прибыль+комиссия+своп","Profit+Comission+Swap")+
         (!this.SupportProperty(property)    ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
          ": "+::DoubleToString(this.GetProperty(property),2)
          ) :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Возвращает описание строкового свойства ордера                   |
//+------------------------------------------------------------------+
string COrder::GetPropertyDescription(ENUM_ORDER_PROP_STRING property)
  {
   return
     (
      property==ORDER_PROP_SYMBOL         ?  TextByLanguage("Символ","Symbol")+": \""+this.GetProperty(property)+"\""            :
      property==ORDER_PROP_COMMENT        ?  TextByLanguage("Комментарий","Comment")+
         (this.GetProperty(property)==""  ?  TextByLanguage(": Отсутствует",": Not set"):": \""+this.GetProperty(property)+"\"") :
      property==ORDER_PROP_EXT_ID         ?  TextByLanguage("Идентификатор на бирже","Exchange identifier")+
         (!this.SupportProperty(property) ?  TextByLanguage(": Свойство не поддерживается",": Property is not support") :
         (this.GetProperty(property)==""  ?  TextByLanguage(": Отсутствует",": Not set"):": \""+this.GetProperty(property)+"\"")):
      ""
     );
  }
//+------------------------------------------------------------------+
