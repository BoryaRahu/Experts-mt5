//+------------------------------------------------------------------+
//|                                                        Event.mqh |
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
#include "\..\..\Services\DELib.mqh"
#include "..\..\Collections\HistoryCollection.mqh"
#include "..\..\Collections\MarketCollection.mqh"
//+------------------------------------------------------------------+
//| Класс абстрактного события                                       |
//+------------------------------------------------------------------+
class CEvent : public CObject
  {
private:
   int               m_event_code;                                   // Код события
//--- Возвращает индекс массива, по которому фактически расположено (1) double-свойство и (2) string-свойство события
   int               IndexProp(ENUM_EVENT_PROP_DOUBLE property)const { return(int)property-EVENT_PROP_INTEGER_TOTAL;                         }
   int               IndexProp(ENUM_EVENT_PROP_STRING property)const { return(int)property-EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_DOUBLE_TOTAL; }
protected:
   ENUM_TRADE_EVENT  m_trade_event;                                  // Торговое событие
   bool              m_is_hedge;                                     // Флаг хедж-счёта
   long              m_chart_id;                                     // Идентификатор графика управляющей программы
   int               m_digits;                                       // Digits() символа
   int               m_digits_acc;                                   // Количество знаков после запятой для валюты счета
   long              m_long_prop[EVENT_PROP_INTEGER_TOTAL];          // Целочисленные свойства события
   double            m_double_prop[EVENT_PROP_DOUBLE_TOTAL];         // Вещественные свойства события
   string            m_string_prop[EVENT_PROP_STRING_TOTAL];         // Строковые свойства события
//--- возвращает факт наличия флага в торговом событии
   bool              IsPresentEventFlag(const int event_code)  const { return (this.m_event_code & event_code)==event_code;            }

//--- Защищённый параметрический конструктор
                     CEvent(const ENUM_EVENT_STATUS event_status,const int event_code,const ulong ticket);
public:
//--- Конструктор по умолчанию
                     CEvent(void){;}
 
//--- Устанавливает (1) целочисленное, (2) вещественное и (3) строковое свойство события
   void              SetProperty(ENUM_EVENT_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                      }
   void              SetProperty(ENUM_EVENT_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;    }
   void              SetProperty(ENUM_EVENT_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;    }
//--- Возвращает из массива свойств (1) целочисленное, (2) вещественное и (3) строковое свойство события
   long              GetProperty(ENUM_EVENT_PROP_INTEGER property)      const { return this.m_long_prop[property];                     }
   double            GetProperty(ENUM_EVENT_PROP_DOUBLE property)       const { return this.m_double_prop[this.IndexProp(property)];   }
   string            GetProperty(ENUM_EVENT_PROP_STRING property)       const { return this.m_string_prop[this.IndexProp(property)];   }

//--- Возвращает флаг поддержания событием данного свойства
   virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property)        { return true; }
   virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property)         { return true; }
   virtual bool      SupportProperty(ENUM_EVENT_PROP_STRING property)         { return true; }

//--- Устанавливает идентификатор графика управляющей программы
   void              SetChartID(const long id)                                { this.m_chart_id=id;                                    }
//--- Расшифровывает код события и устанавливает торговое событие, (2) возвращает торговое событие
   void              SetTypeEvent(void);
   ENUM_TRADE_EVENT  TradeEvent(void)                                   const { return this.m_trade_event;                             }
//--- Отправляет событие на график (реализация в потомках класса)
   virtual void      SendEvent(void) {;}

//--- Сравнивает объекты CEvent между собой по заданному свойству (для сортировки списков по указанному свойству объекта-события)
   virtual int       Compare(const CObject *node,const int mode=0) const;
//--- Сравнивает объекты CEvent между собой по всем свойствам (для поиска равных объектов-событий)
   bool              IsEqual(CEvent* compared_event);
//+------------------------------------------------------------------+
//| Методы упрощённого доступа к свойствам объекта-события           |
//+------------------------------------------------------------------+
//--- Возвращает (1) тип события, (2) время события в милисекундах, (3) статус события, (4) причину события, (5) тип сделки, (6) тикет сделки, 
//--- (7) тип ордера, на основании которого исполнена сделка, (8) тип открывающего ордера позиции, (9) тикет последнего ордера позиции, 
//--- (10) тикет первого ордера позиции, (11) идентификатор позиции, (12) идентификатор встречной позиции, (13) магик, (14) магик встречной, (15) время открытия позиции
   ENUM_TRADE_EVENT  TypeEvent(void)                                    const { return (ENUM_TRADE_EVENT)this.GetProperty(EVENT_PROP_TYPE_EVENT);           }
   long              TimeEvent(void)                                    const { return this.GetProperty(EVENT_PROP_TIME_EVENT);                             }
   ENUM_EVENT_STATUS Status(void)                                       const { return (ENUM_EVENT_STATUS)this.GetProperty(EVENT_PROP_STATUS_EVENT);        }
   ENUM_EVENT_REASON Reason(void)                                       const { return (ENUM_EVENT_REASON)this.GetProperty(EVENT_PROP_REASON_EVENT);        }
   ENUM_DEAL_TYPE    TypeDeal(void)                                     const { return (ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT);        }
   long              TicketDeal(void)                                   const { return this.GetProperty(EVENT_PROP_TICKET_DEAL_EVENT);                      }
   ENUM_ORDER_TYPE   TypeOrderEvent(void)                               const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_EVENT);      }
   ENUM_ORDER_TYPE   TypeFirstOrderPosition(void)                       const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION);   }
   long              TicketOrderEvent(void)                             const { return this.GetProperty(EVENT_PROP_TICKET_ORDER_EVENT);                     }
   long              TicketFirstOrderPosition(void)                     const { return this.GetProperty(EVENT_PROP_TICKET_ORDER_POSITION);                  }
   long              PositionID(void)                                   const { return this.GetProperty(EVENT_PROP_POSITION_ID);                            }
   long              PositionByID(void)                                 const { return this.GetProperty(EVENT_PROP_POSITION_BY_ID);                         }
   long              Magic(void)                                        const { return this.GetProperty(EVENT_PROP_MAGIC_ORDER);                            }
   long              MagicCloseBy(void)                                 const { return this.GetProperty(EVENT_PROP_MAGIC_BY_ID);                            }
   long              TimePosition(void)                                 const { return this.GetProperty(EVENT_PROP_TIME_ORDER_POSITION);                    }

//--- При смене направления позиции возвращает (1) тип ордера предыдущей позиции, (2) тикет ордера предыдущей позиции
//--- (3) тип ордера текущей позиции, (4) тикет ордера текущей позиции
//--- (5) тип и (6) тикет позиции до смены направления, (7) тип и (8) тикет позиции после смены направления
   ENUM_ORDER_TYPE   TypeOrderPosPrevious(void)                         const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE);   }
   long              TicketOrderPosPrevious(void)                       const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE); }
   ENUM_ORDER_TYPE   TypeOrderPosCurrent(void)                          const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT);  }
   long              TicketOrderPosCurrent(void)                        const { return (ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT);}
   ENUM_POSITION_TYPE TypePositionPrevious(void)                        const { return PositionTypeByOrderType(this.TypeOrderPosPrevious());                }
   ulong             TicketPositionPrevious(void)                       const { return this.TicketOrderPosPrevious();                                       }
   ENUM_POSITION_TYPE TypePositionCurrent(void)                         const { return PositionTypeByOrderType(this.TypeOrderPosCurrent());                 }
   ulong             TicketPositionCurrent(void)                        const { return this.TicketOrderPosCurrent();                                        }
   
//--- Возвращает (1) цену, на которой произошло событие, (2) цену открытия, (3) цену закрытия,
//--- (4) цену StopLoss, (5) цену TakeProfit, (6) профит, (7) Запрашиваемый объём ордера, 
//--- 8) Исполненный объём ордера, (9) Оставшийся объём ордера, (10) исполненный объём позиции
   double            PriceEvent(void)                                   const { return this.GetProperty(EVENT_PROP_PRICE_EVENT);                            }
   double            PriceOpen(void)                                    const { return this.GetProperty(EVENT_PROP_PRICE_OPEN);                             }
   double            PriceClose(void)                                   const { return this.GetProperty(EVENT_PROP_PRICE_CLOSE);                            }
   double            PriceStopLoss(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_SL);                               }
   double            PriceTakeProfit(void)                              const { return this.GetProperty(EVENT_PROP_PRICE_TP);                               }
   double            Profit(void)                                       const { return this.GetProperty(EVENT_PROP_PROFIT);                                 }
   double            VolumeOrderInitial(void)                           const { return this.GetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL);                   }
   double            VolumeOrderExecuted(void)                          const { return this.GetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED);                  }
   double            VolumeOrderCurrent(void)                           const { return this.GetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT);                   }
   double            VolumePositionExecuted(void)                       const { return this.GetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED);               }

//--- При модификации цен возвращает (1) цену установки ордера, (2) StopLoss, (3) TakeProfit до модификации
   double            PriceOpenBefore(void)                              const { return this.GetProperty(EVENT_PROP_PRICE_OPEN_BEFORE);                      }
   double            PriceStopLossBefore(void)                          const { return this.GetProperty(EVENT_PROP_PRICE_SL_BEFORE);                        }
   double            PriceTakeProfitBefore(void)                        const { return this.GetProperty(EVENT_PROP_PRICE_TP_BEFORE);                        }
   double            PriceEventAsk(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_EVENT_ASK);                        }
   double            PriceEventBid(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_EVENT_BID);                        }

//--- Возвращает (1) символ, (2) символ встречной позиции
   string            Symbol(void)                                       const { return this.GetProperty(EVENT_PROP_SYMBOL);                                 }
   string            SymbolCloseBy(void)                                const { return this.GetProperty(EVENT_PROP_SYMBOL_BY_ID);                           }
   
//+------------------------------------------------------------------+
//| Описания свойств объекта-ордера                                  |
//+------------------------------------------------------------------+
//--- Возвращает описание (1) целочисленного, (2) вещественного и (3) строкового свойства ордера
   string            GetPropertyDescription(ENUM_EVENT_PROP_INTEGER property);
   string            GetPropertyDescription(ENUM_EVENT_PROP_DOUBLE property);
   string            GetPropertyDescription(ENUM_EVENT_PROP_STRING property);
//--- Возвращает наименование (1) статуса, (2) типа события
   string            StatusDescription(void)                const;
   string            TypeEventDescription(void)             const;
//--- Возвращает наименование (1) ордера сделки события, (2) родительского ордера позиции, (3) ордера текущей позиции, (4) текущей позиции
//--- Возвращает наименование (5) ордера и (6) позиции до смены направления
   string            TypeOrderDealDescription(void)         const;
   string            TypeOrderFirstDescription(void)        const;
   string            TypeOrderEventDescription(void)        const;
   string            TypePositionCurrentDescription(void)   const;
   string            TypeOrderPreviousDescription(void)     const;
   string            TypePositionPreviousDescription(void)  const;
//--- Возвращает наименование причины сделки/ордера/позиции
   string            ReasonDescription(void)                const;

//--- Выводит в журнал (1) описание свойств ордера (full_prop=true - все свойства, false - только поддерживаемые),
//--- (2) краткое сообщение о событии (реализация в потомках класса)
   void              Print(const bool full_prop=false);
   virtual void      PrintShort(void) {;}
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CEvent::CEvent(const ENUM_EVENT_STATUS event_status,const int event_code,const ulong ticket) : m_event_code(event_code),m_digits(0)
  {
   this.m_long_prop[EVENT_PROP_STATUS_EVENT]       =  event_status;
   this.m_long_prop[EVENT_PROP_TICKET_ORDER_EVENT] =  (long)ticket;
   this.m_is_hedge=bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   this.m_digits_acc=(int)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   this.m_chart_id=::ChartID();
  }
//+------------------------------------------------------------------+
//| Сравнивает объекты CEvent между собой по заданному свойству      |
//+------------------------------------------------------------------+
int CEvent::Compare(const CObject *node,const int mode=0) const
  {
   const CEvent *event_compared=node;
//--- сравнение целочисленных свойств двух событий
   if(mode<EVENT_PROP_INTEGER_TOTAL)
     {
      long value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_EVENT_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- сравнение вещественных свойств двух событий
   if(mode<EVENT_PROP_DOUBLE_TOTAL+EVENT_PROP_INTEGER_TOTAL)
     {
      double value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_EVENT_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- сравнение строковых свойств двух событий
   else if(mode<EVENT_PROP_DOUBLE_TOTAL+EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_STRING_TOTAL)
     {
      string value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_EVENT_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Сравнивает объекты CEvent между собой по всем свойствам          |
//+------------------------------------------------------------------+
bool CEvent::IsEqual(CEvent *compared_event)
  {
   int beg=0, end=EVENT_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_INTEGER prop=(ENUM_EVENT_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
     }
   beg=end; end+=EVENT_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_DOUBLE prop=(ENUM_EVENT_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
     }
   beg=end; end+=EVENT_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_STRING prop=(ENUM_EVENT_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Расшифровывает код события и устанавливает торговое событие      |
//+------------------------------------------------------------------+
void CEvent::SetTypeEvent(void)
  {
//--- Установка Digits() символа события
   this.m_digits=(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS);
//--- Отложенный ордер установлен (проверяем на равенство коду события, так как здесь может быть только один флаг)
   if(this.m_event_code==TRADE_EVENT_FLAG_ORDER_PLASED)
     {
      this.m_trade_event=TRADE_EVENT_PENDING_ORDER_PLASED;
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Отложенный ордер удалён (проверяем на равенство коду события, так как здесь может быть только один флаг)
   if(this.m_event_code==TRADE_EVENT_FLAG_ORDER_REMOVED)
     {
      this.m_trade_event=TRADE_EVENT_PENDING_ORDER_REMOVED;
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Модифицирован отложенный ордер
   if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_MODIFY))
     {
      //--- Если модифицирована цена установки
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_PRICE))
        {
         this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE;
         //--- Если модифицированы StopLoss и TakeProfit
         if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL) && this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT;
         //--- Если модифицирован StopLoss
         else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS;
         //--- Если модифицирован TakeProfit
         else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_PRICE_TAKE_PROFIT;
        }
      //--- Если цена установки не модифицирована
      else
        {
         //--- Если модифицированы StopLoss и TakeProfit
         if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL) && this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_STOP_LOSS_TAKE_PROFIT;
         //--- Если модифицирован StopLoss
         else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_STOP_LOSS;
         //--- Если модифицирован TakeProfit
         else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
            this.m_trade_event=TRADE_EVENT_MODIFY_ORDER_TAKE_PROFIT;
        }
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Модифицирована позиция
   if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_MODIFY))
     {
      //--- Если модифицированы StopLoss и TakeProfit
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL) && this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
         this.m_trade_event=TRADE_EVENT_MODIFY_POSITION_STOP_LOSS_TAKE_PROFIT;
      //--- Если модифицирован StopLoss
      else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
         this.m_trade_event=TRADE_EVENT_MODIFY_POSITION_STOP_LOSS;
      //--- Если модифицирован TakeProfit
      else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
         this.m_trade_event=TRADE_EVENT_MODIFY_POSITION_TAKE_PROFIT;
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Позиция открыта (Проверяем наличие множества флагов в коде события)
   if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_OPENED))
     {
   //--- Если это изменение существующей позиции
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_CHANGED))
        {
         //--- Если это отложенный ордер активирован ценой
         if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED))
           {
            //--- Если это разворот позиции
            if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_REVERSE))
              {
               //--- проверяем флаг частичного открытия и устанавливаем торговое событие 
               //--- "разворот позиции активацией отложенного ордера" или "разворот позиции частичной активацией отложенного ордера"
               this.m_trade_event=
                 (
                  !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                  TRADE_EVENT_POSITION_REVERSED_BY_PENDING : 
                  TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL
                 );
               this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
               return;
              }
            //--- Если это добавление объёма к позиции
            else
              {
               //--- проверяем флаг частичного открытия и устанавливаем торговое событие 
               //--- "добавлен объём к позиции активацией отложенного ордера" или "добавлен объём к позиции частичной активацией отложенного ордера"
               this.m_trade_event=
                 (
                  !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                  TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING : 
                  TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL
                 );
               this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
               return;
              }
           }
         //--- Если изменение позиции было осуществлено сделкой ро рынку
         else
           {
            //--- Если это разворот позиции
            if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_REVERSE))
              {
               //--- проверяем флаг частичного открытия и устанавливаем торговое событие "разворот позиции" или "разворот позиции частичным исполнением"
               this.m_trade_event=
                 (
                  !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                  TRADE_EVENT_POSITION_REVERSED_BY_MARKET : 
                  TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL
                 );
               this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
               return;
              }
            //--- Если это добавление объёма к позиции
            else
              {
               //--- проверяем флаг частичного открытия и устанавливаем торговое событие "добавлен объём к позиции" или "добавлен объём к позиции частичным исполнением"
               this.m_trade_event=
                 (
                  !this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? 
                  TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET : 
                  TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL
                 );
               this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
               return;
              }
           }
        }
   //--- Если это открытие новой позиции
      else
        {
         //--- Если это отложенный ордер активирован ценой
         if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED))
           {
            //--- проверяем флаг частичного открытия и устанавливаем торговое событие "отложенный ордер активирован" или "отложенный ордер активирован частично"
            this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_PENDING_ORDER_ACTIVATED : TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL);
            this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
            return;
           }
         //--- проверяем флаг частичного открытия и устанавливаем торговое событие "Позиция открыта" или "Позиция открыта частично"
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_OPENED : TRADE_EVENT_POSITION_OPENED_PARTIAL);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
     }
     
//--- Позиция закрыта (Проверяем наличие множества флагов в коде события)
   if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_CLOSED))
     {
      //--- если позиция закрыта по StopLoss
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
        {
         //--- проверяем флаг частичного закрытия и устанавливаем торговое событие "Позиция закрыта по StopLoss" или "Позиция закрыта по StopLoss частично"
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_SL : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- если позиция закрыта по TakeProfit
      else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
        {
         //--- проверяем флаг частичного закрытия и устанавливаем торговое событие "Позиция закрыта по TakeProfit" или "Позиция закрыта по TakeProfit частично"
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_TP : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- если позиция закрыта встречной
      else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS))
        {
         //--- проверяем флаг частичного закрытия и устанавливаем торговое событие "Позиция закрыта встречной" или "Позиция закрыта встречной частично"
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_POS : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- Если позиция закрыта
      else
        {
         //--- проверяем флаг частичного закрытия и устанавливаем торговое событие "Позиция закрыта" или "Позиция закрыта частично"
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED : TRADE_EVENT_POSITION_CLOSED_PARTIAL);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
     }
//--- Балансная операция на счёте (уточняем событие по типу сделки)
   if(this.m_event_code==TRADE_EVENT_FLAG_ACCOUNT_BALANCE)
     {
      //--- Инициализируем торговое событие
      this.m_trade_event=TRADE_EVENT_NO_EVENT;
      //--- Возьмём тип сделки
      ENUM_DEAL_TYPE deal_type=(ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT);
      //--- если сделка - балансная операция
      if(deal_type==DEAL_TYPE_BALANCE)
        {
        //--- проверим профит сделки и установим событие (пополнение или снятие средств)
         this.m_trade_event=(this.GetProperty(EVENT_PROP_PROFIT)>0 ? TRADE_EVENT_ACCOUNT_BALANCE_REFILL : TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL);
        }
      //--- Остальные типы балансной операции совпадают с перечислением ENUM_DEAL_TYPE начиная от DEAL_TYPE_CREDIT
      else if(deal_type>DEAL_TYPE_BALANCE)
        {
        //--- установим это событие
         this.m_trade_event=(ENUM_TRADE_EVENT)deal_type;
        }
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает описание целочисленного свойства события              |
//+------------------------------------------------------------------+
string CEvent::GetPropertyDescription(ENUM_EVENT_PROP_INTEGER property)
  {
   return
     (
      property==EVENT_PROP_TYPE_EVENT              ?  TextByLanguage("Тип события","Event's type")+": "+this.TypeEventDescription()                                                       :
      property==EVENT_PROP_TIME_EVENT              ?  TextByLanguage("Время события","Time of event")+": "+TimeMSCtoString(this.GetProperty(property))                                    :
      property==EVENT_PROP_STATUS_EVENT            ?  TextByLanguage("Статус события","Status of event")+": \""+this.StatusDescription()+"\""                                             :
      property==EVENT_PROP_REASON_EVENT            ?  TextByLanguage("Причина события","Reason of event")+": "+this.ReasonDescription()                                                   :
      property==EVENT_PROP_TYPE_DEAL_EVENT         ?  TextByLanguage("Тип сделки","Deal's type")+": "+DealTypeDescription((ENUM_DEAL_TYPE)this.GetProperty(property))                     :
      property==EVENT_PROP_TICKET_DEAL_EVENT       ?  TextByLanguage("Тикет сделки","Deal's ticket")+": #"+(string)this.GetProperty(property)                                              :
      property==EVENT_PROP_TYPE_ORDER_EVENT        ?  TextByLanguage("Тип ордера события","Event's order type")+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property))    :
      property==EVENT_PROP_TYPE_ORDER_POSITION     ?  TextByLanguage("Тип ордера позиции","Position's order type")+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property)) :
      property==EVENT_PROP_TICKET_ORDER_POSITION   ?  TextByLanguage("Тикет первого ордера позиции","Position's first order ticket")+": #"+(string)this.GetProperty(property)              :
      property==EVENT_PROP_TICKET_ORDER_EVENT      ?  TextByLanguage("Тикет ордера события","Event's order ticket")+": #"+(string)this.GetProperty(property)                               :
      property==EVENT_PROP_POSITION_ID             ?  TextByLanguage("Идентификатор позиции","Position ID")+": #"+(string)this.GetProperty(property)                                       :
      property==EVENT_PROP_POSITION_BY_ID          ?  TextByLanguage("Идентификатор встречной позиции","Opposite position's ID")+": #"+(string)this.GetProperty(property)                  :
      property==EVENT_PROP_MAGIC_ORDER             ?  TextByLanguage("Магический номер","Magic number")+": "+(string)this.GetProperty(property)                                           :
      property==EVENT_PROP_MAGIC_BY_ID             ?  TextByLanguage("Магический номер встречной позиции","Magic number of opposite position")+": "+(string)this.GetProperty(property)    :
      property==EVENT_PROP_TIME_ORDER_POSITION     ?  TextByLanguage("Время открытия позиции","Position's opened time")+": "+TimeMSCtoString(this.GetProperty(property))                  :
      property==EVENT_PROP_TYPE_ORD_POS_BEFORE     ?  TextByLanguage("Тип ордера позиции до смены направления","Type order of position before changing direction")+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property)) :
      property==EVENT_PROP_TICKET_ORD_POS_BEFORE   ?  TextByLanguage("Тикет ордера позиции до смены направления","Ticket order of position before changing direction")+": #"+(string)this.GetProperty(property)                            :
      property==EVENT_PROP_TYPE_ORD_POS_CURRENT    ?  TextByLanguage("Тип ордера текущей позиции","Type order of current position")+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property))                                :
      property==EVENT_PROP_TICKET_ORD_POS_CURRENT  ?  TextByLanguage("Тикет ордера текущей позиции","Ticket order of current position")+": #"+(string)this.GetProperty(property)                                                           :
      EnumToString(property)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает описание вещественного свойства события               |
//+------------------------------------------------------------------+
string CEvent::GetPropertyDescription(ENUM_EVENT_PROP_DOUBLE property)
  {
   int dg=(int)::SymbolInfoInteger(this.GetProperty(EVENT_PROP_SYMBOL),SYMBOL_DIGITS);
   int dgl=(int)DigitsLots(this.GetProperty(EVENT_PROP_SYMBOL));
   return
     (
      property==EVENT_PROP_PRICE_EVENT             ?  TextByLanguage("Цена на момент события","Price at the time of the event")+": "+::DoubleToString(this.GetProperty(property),dg)               :
      property==EVENT_PROP_PRICE_OPEN              ?  TextByLanguage("Цена открытия","Price open")+": "+::DoubleToString(this.GetProperty(property),dg)                                            :
      property==EVENT_PROP_PRICE_CLOSE             ?  TextByLanguage("Цена закрытия","Price close")+": "+::DoubleToString(this.GetProperty(property),dg)                                           :
      property==EVENT_PROP_PRICE_SL                ?  TextByLanguage("Цена StopLoss","Price StopLoss")+": "+::DoubleToString(this.GetProperty(property),dg)                                        :
      property==EVENT_PROP_PRICE_TP                ?  TextByLanguage("Цена TakeProfit","Price TakeProfit")+": "+::DoubleToString(this.GetProperty(property),dg)                                    :
      property==EVENT_PROP_VOLUME_ORDER_INITIAL    ?  TextByLanguage("Начальный объём ордера","Order initial volume")+": "+::DoubleToString(this.GetProperty(property),dgl)                        :
      property==EVENT_PROP_VOLUME_ORDER_EXECUTED   ?  TextByLanguage("Исполненный объём ордера","Order executed volume")+": "+::DoubleToString(this.GetProperty(property),dgl)                     :
      property==EVENT_PROP_VOLUME_ORDER_CURRENT    ?  TextByLanguage("Оставшийся объём ордера","Order remaining volume")+": "+::DoubleToString(this.GetProperty(property),dgl)                     :
      property==EVENT_PROP_VOLUME_POSITION_EXECUTED ? TextByLanguage("Текущий объём позиции","Position current volume")+": "+::DoubleToString(this.GetProperty(property),dgl)                      :
      property==EVENT_PROP_PROFIT                  ?  TextByLanguage("Профит","Profit")+": "+::DoubleToString(this.GetProperty(property),this.m_digits_acc)                                        :
      property==EVENT_PROP_PRICE_OPEN_BEFORE       ?  TextByLanguage("Цена открытия до модификации","Price open before modification")+": "+::DoubleToString(this.GetProperty(property),dg)         :
      property==EVENT_PROP_PRICE_SL_BEFORE         ?  TextByLanguage("Цена StopLoss до модификации","Price StopLoss before modification")+": "+::DoubleToString(this.GetProperty(property),dg)     :
      property==EVENT_PROP_PRICE_TP_BEFORE         ?  TextByLanguage("Цена TakeProfit до модификации","Price TakeProfit before modification")+": "+::DoubleToString(this.GetProperty(property),dg) :
      property==EVENT_PROP_PRICE_EVENT_ASK         ?  TextByLanguage("Цена Ask в момент события","Price Ask at the time of the event")+": "+::DoubleToString(this.GetProperty(property),dg)        :
      property==EVENT_PROP_PRICE_EVENT_BID         ?  TextByLanguage("Цена Bid в момент события","Price Bid at the time of the event")+": "+::DoubleToString(this.GetProperty(property),dg)        :
      EnumToString(property)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает описание строкового свойства события                  |
//+------------------------------------------------------------------+
string CEvent::GetPropertyDescription(ENUM_EVENT_PROP_STRING property)
  {
   return
     (
      property==EVENT_PROP_SYMBOL ? TextByLanguage("Символ","Symbol")+": \""+this.GetProperty(property)+"\""   :
      TextByLanguage("Символ встречной позиции","Symbol of opposite position")+": \""+this.GetProperty(property)+"\""
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование статуса события                          |
//+------------------------------------------------------------------+
string CEvent::StatusDescription(void) const
  {
   ENUM_EVENT_STATUS status=(ENUM_EVENT_STATUS)this.GetProperty(EVENT_PROP_STATUS_EVENT);
   return
     (
      status==EVENT_STATUS_MARKET_PENDING    ?  TextByLanguage("Установлен отложенный ордер","Pending order placed") :
      status==EVENT_STATUS_MARKET_POSITION   ?  TextByLanguage("Открыта позиция","Position is open")                 :
      status==EVENT_STATUS_HISTORY_PENDING   ?  TextByLanguage("Удален отложенный ордер","Pending order removed")    :
      status==EVENT_STATUS_HISTORY_POSITION  ?  TextByLanguage("Закрыта позиция","Position closed")                  :
      status==EVENT_STATUS_BALANCE           ?  TextByLanguage("Балансная операция","Balance operation")             :
      TextByLanguage("Неизвестный статус","Unknown status")
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование торгового события                        |
//+------------------------------------------------------------------+
string CEvent::TypeEventDescription(void) const
  {
   ENUM_TRADE_EVENT event=this.TypeEvent();
   return
     (
      event==TRADE_EVENT_NO_EVENT                              ?  TextByLanguage("Нет торгового события","No trade event")                                              :
      event==TRADE_EVENT_PENDING_ORDER_PLASED                  ?  TextByLanguage("Отложенный ордер установлен","Pending order placed")                                  :
      event==TRADE_EVENT_PENDING_ORDER_REMOVED                 ?  TextByLanguage("Отложенный ордер удалён","Pending order removed")                                     :
      event==TRADE_EVENT_ACCOUNT_CREDIT                        ?  TextByLanguage("Начисление кредита","Credit")                                                         :
      event==TRADE_EVENT_ACCOUNT_CHARGE                        ?  TextByLanguage("Дополнительные сборы","Additional charge")                                            :
      event==TRADE_EVENT_ACCOUNT_CORRECTION                    ?  TextByLanguage("Корректирующая запись","Correction")                                                  :
      event==TRADE_EVENT_ACCOUNT_BONUS                         ?  TextByLanguage("Перечисление бонусов","Bonus")                                                        :
      event==TRADE_EVENT_ACCOUNT_COMISSION                     ?  TextByLanguage("Дополнительные комиссии","Additional commission")                                     :
      event==TRADE_EVENT_ACCOUNT_COMISSION_DAILY               ?  TextByLanguage("Комиссия, начисляемая в конце торгового дня","Daily commission")                      :
      event==TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY             ?  TextByLanguage("Комиссия, начисляемая в конце месяца","Monthly commission")                           :
      event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY         ?  TextByLanguage("Агентская комиссия, начисляемая в конце торгового дня","Daily agent commission")      :
      event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY       ?  TextByLanguage("Агентская комиссия, начисляемая в конце месяца","Monthly agent commission")           :
      event==TRADE_EVENT_ACCOUNT_INTEREST                      ?  TextByLanguage("Начисления процентов на свободные средства","Interest rate")                          :
      event==TRADE_EVENT_BUY_CANCELLED                         ?  TextByLanguage("Отмененная сделка покупки","Canceled buy deal")                                       :
      event==TRADE_EVENT_SELL_CANCELLED                        ?  TextByLanguage("Отмененная сделка продажи","Canceled sell deal")                                      :
      event==TRADE_EVENT_DIVIDENT                              ?  TextByLanguage("Начисление дивиденда","Dividend operations")                                          :
      event==TRADE_EVENT_DIVIDENT_FRANKED                      ?  TextByLanguage("Начисление франкированного дивиденда","Franked (non-taxable) dividend operations")    :
      event==TRADE_EVENT_TAX                                   ?  TextByLanguage("Начисление налога","Tax charges")                                                     :
      event==TRADE_EVENT_ACCOUNT_BALANCE_REFILL                ?  TextByLanguage("Пополнение средств на балансе","Balance refill")                                      :
      event==TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL            ?  TextByLanguage("Снятие средств с баланса","Withdrawals")                                              :
      event==TRADE_EVENT_PENDING_ORDER_ACTIVATED               ?  TextByLanguage("Отложенный ордер активирован ценой","Pending order activated")                        :
      event==TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL       ?  TextByLanguage("Отложенный ордер активирован ценой частично","Pending order activated partially")     :
      event==TRADE_EVENT_POSITION_OPENED                       ?  TextByLanguage("Позиция открыта","Position is open")                                                  :
      event==TRADE_EVENT_POSITION_OPENED_PARTIAL               ?  TextByLanguage("Позиция открыта частично","Position is open partially")                               :
      event==TRADE_EVENT_POSITION_CLOSED                       ?  TextByLanguage("Позиция закрыта","Position closed")                                                   :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL               ?  TextByLanguage("Позиция закрыта частично","Position closed partially")                                :
      event==TRADE_EVENT_POSITION_CLOSED_BY_POS                ?  TextByLanguage("Позиция закрыта встречной","Position closed by opposite position")                    :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS        ?  TextByLanguage("Позиция закрыта встречной частично","Position closed partially by opposite position") :
      event==TRADE_EVENT_POSITION_CLOSED_BY_SL                 ?  TextByLanguage("Позиция закрыта по StopLoss","Position closed by StopLoss")                           :
      event==TRADE_EVENT_POSITION_CLOSED_BY_TP                 ?  TextByLanguage("Позиция закрыта по TakeProfit","Position closed by TakeProfit")                       :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL         ?  TextByLanguage("Позиция закрыта частично по StopLoss","Position closed partially by StopLoss")        :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP         ?  TextByLanguage("Позиция закрыта частично по TakeProfit","Position closed partially by TakeProfit")    :
      event==TRADE_EVENT_POSITION_REVERSED_BY_MARKET           ?  TextByLanguage("Разворот позиции по рыночному запросу","Position reversal by market request")         :
      event==TRADE_EVENT_POSITION_REVERSED_BY_PENDING          ?  TextByLanguage("Разворот позиции срабатыванием отложенного ордера","Position reversal by triggered a pending order")                            :
      event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET         ?  TextByLanguage("Добавлен объём к позиции по рыночному запросу","Added volume to position by market request")                                    :
      event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING        ?  TextByLanguage("Добавлен объём к позиции активацией отложенного ордера","Added volume to the position by activation of a pending order")        :
      
      event==TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL   ?  TextByLanguage("Разворот позиции частичным исполнением запроса","Position reversal by partially completed of market request")                   :
      event==TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL  ?  TextByLanguage("Разворот позиции частичным срабатыванием отложенного ордера","Position reversal by partially triggered a pending order")        :
      event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL ?  TextByLanguage("Добавлен объём к позиции частичным исполнением запроса","Added volume to position by partially completed of market request")    :
      event==TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL ? TextByLanguage("Добавлен объём к позиции активацией отложенного ордера","Added volume to the position by partially triggered a pending order")  :

      event==TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER            ?  TextByLanguage("Сработал StopLimit-ордер","StopLimit order triggered.")                                                                         :
      event==TRADE_EVENT_MODIFY_ORDER_PRICE                    ?  TextByLanguage("Модифицирована цена установки ордера ","Modified order price")                                                                  :
      event==TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS          ?  TextByLanguage("Модифицированы цена установки и StopLoss ордера","Modified of order price and StopLoss")                                        :
      event==TRADE_EVENT_MODIFY_ORDER_PRICE_TAKE_PROFIT        ?  TextByLanguage("Модифицированы цена установки и TakeProfit ордера","Modified of order price and TakeProfit")                                    :
      event==TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT ?  TextByLanguage("Модифицированы цена установки, StopLoss и TakeProfit ордера","Modified of order price, StopLoss and TakeProfit")             :
      event==TRADE_EVENT_MODIFY_ORDER_STOP_LOSS_TAKE_PROFIT    ?  TextByLanguage("Модифицированы цены StopLoss и TakeProfit ордера","Modified of order StopLoss and TakeProfit")                                  :
      event==TRADE_EVENT_MODIFY_ORDER_STOP_LOSS                ?  TextByLanguage("Модифицирован StopLoss ордера","Modified order StopLoss")                                                                       :
      event==TRADE_EVENT_MODIFY_ORDER_TAKE_PROFIT              ?  TextByLanguage("Модифицирован TakeProfit ордера","Modified order TakeProfit")                                                                   :
      event==TRADE_EVENT_MODIFY_POSITION_STOP_LOSS_TAKE_PROFIT ?  TextByLanguage("Модифицированы цены StopLoss и TakeProfit позиции","Modified of position StopLoss and TakeProfit")                              :
      event==TRADE_EVENT_MODIFY_POSITION_STOP_LOSS             ?  TextByLanguage("Модифицирован StopLoss позиции","Modified position StopLoss")                                                                   :
      event==TRADE_EVENT_MODIFY_POSITION_TAKE_PROFIT           ?  TextByLanguage("Модифицирован TakeProfit позиции","Modified position TakeProfit")                                                               :
      EnumToString(event)
     );   
  }
//+------------------------------------------------------------------+
//| Возвращает наименование ордера/позиции/сделки                    |
//+------------------------------------------------------------------+
string CEvent::TypeOrderDealDescription(void) const
  {
   ENUM_EVENT_STATUS status=this.Status();
   return
     (
      status==EVENT_STATUS_MARKET_PENDING  || status==EVENT_STATUS_HISTORY_PENDING  ?  OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_EVENT))      :
      status==EVENT_STATUS_MARKET_POSITION || status==EVENT_STATUS_HISTORY_POSITION ?  PositionTypeDescription((ENUM_POSITION_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT)) :
      status==EVENT_STATUS_BALANCE  ?  DealTypeDescription((ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT))  :  
      TextByLanguage("Неизвестный тип ордера","Unknown order type")
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование первого ордера позиции                   |
//+------------------------------------------------------------------+
string CEvent::TypeOrderFirstDescription(void) const
  {
   return OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION));
  }
//+------------------------------------------------------------------+
//| Возвращает наименование ордера, изменившего позицию              |
//+------------------------------------------------------------------+
string CEvent::TypeOrderEventDescription(void) const
  {
   return OrderTypeDescription(this.TypeOrderEvent());
  }
//+------------------------------------------------------------------+
//| Возвращает наименование текущей позиции                          |
//+------------------------------------------------------------------+
string CEvent::TypePositionCurrentDescription(void) const
  {
   return PositionTypeDescription(this.TypePositionCurrent());
  }
//+------------------------------------------------------------------+
//| Возвращает наименование ордера до смены направления             |
//+------------------------------------------------------------------+
string CEvent::TypeOrderPreviousDescription(void) const
  {
   return OrderTypeDescription(this.TypeOrderPosPrevious());
  }
//+------------------------------------------------------------------+
//| Возвращает наименование позиции до смены направления             |
//+------------------------------------------------------------------+
string CEvent::TypePositionPreviousDescription(void) const
  {
   return PositionTypeDescription(this.TypePositionPrevious());
  }
//+------------------------------------------------------------------+
//| Возвращает наименование причины сделки/ордера/позиции            |
//+------------------------------------------------------------------+
string CEvent::ReasonDescription(void) const
  {
   ENUM_EVENT_REASON reason=this.Reason();
   return 
     (
      reason==EVENT_REASON_ACTIVATED_PENDING                ?  TextByLanguage("Активирован отложенный ордер","Pending order activated")                           :
      reason==EVENT_REASON_ACTIVATED_PENDING_PARTIALLY      ?  TextByLanguage("Частичное срабатывание отложенного ордера","Pending order partially triggered")    :
      reason==EVENT_REASON_STOPLIMIT_TRIGGERED              ?  TextByLanguage("Срабатывание StopLimit-ордера","StopLimit-order triggered")                        :
      reason==EVENT_REASON_MODIFY                           ?  TextByLanguage("Модификация","Modified")                                                           :
      reason==EVENT_REASON_CANCEL                           ?  TextByLanguage("Отмена","Canceled")                                                                :
      reason==EVENT_REASON_EXPIRED                          ?  TextByLanguage("Истёк срок действия","Expired")                                                    :
      reason==EVENT_REASON_DONE                             ?  TextByLanguage("Рыночный запрос, выполненный в полном объёме","Fully completed market request")    :
      reason==EVENT_REASON_DONE_PARTIALLY                   ?  TextByLanguage("Выполненный частично рыночный запрос","Partially completed market request")        :
      reason==EVENT_REASON_VOLUME_ADD                       ?  TextByLanguage("Добавлен объём к позиции","Added volume to position")                              :
      reason==EVENT_REASON_VOLUME_ADD_PARTIALLY             ?  TextByLanguage("Добавлен объём к позиции частичным исполнением заявки","Volume added to the position by partially completed request")                 :
      reason==EVENT_REASON_VOLUME_ADD_BY_PENDING            ?  TextByLanguage("Добавлен объём к позиции активацией отложенного ордера","Added volume to position by pending order's triggered")                      :
      reason==EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY  ?  TextByLanguage("Добавлен объём к позиции частичной активацией отложенного ордера","Added volume to position by pending order's triggered partially")  :
      reason==EVENT_REASON_REVERSE                          ?  TextByLanguage("Разворот позиции","Position reversal")  :
      reason==EVENT_REASON_REVERSE_PARTIALLY                ?  TextByLanguage("Разворот позиции частичным исполнением заявки","Position reversal by partially completed of the request")                             :
      reason==EVENT_REASON_REVERSE_BY_PENDING               ?  TextByLanguage("Разворот позиции при срабатывании отложенного ордера","Position reversal on a triggered pending order")                               :
      reason==EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY     ?  TextByLanguage("Разворот позиции при при частичном срабатывании отложенного ордера","Position reversal on a partially triggered pending order")       :
      reason==EVENT_REASON_DONE_SL                          ?  TextByLanguage("Закрытие по StopLoss","Close by StopLoss triggered")                               :
      reason==EVENT_REASON_DONE_SL_PARTIALLY                ?  TextByLanguage("Частичное закрытие по StopLoss","Partially close by StopLoss triggered")           :
      reason==EVENT_REASON_DONE_TP                          ?  TextByLanguage("Закрытие по TakeProfit","Close by TakeProfit triggered")                           :
      reason==EVENT_REASON_DONE_TP_PARTIALLY                ?  TextByLanguage("Частичное закрытие по TakeProfit","Partially close by TakeProfit triggered")       :
      reason==EVENT_REASON_DONE_BY_POS                      ?  TextByLanguage("Закрытие встречной позицией","Closed by opposite position")                        :
      reason==EVENT_REASON_DONE_PARTIALLY_BY_POS            ?  TextByLanguage("Частичное закрытие встречной позицией","Closed partially by opposite position")    :
      reason==EVENT_REASON_DONE_BY_POS_PARTIALLY            ?  TextByLanguage("Закрытие частью объёма встречной позиции","Closed by incomplete volume of opposite position") :
      reason==EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY  ?  TextByLanguage("Частичное закрытие частью объёма встречной позиции","Closed partially by incomplete volume of opposite position")  :
      reason==EVENT_REASON_BALANCE_REFILL                   ?  TextByLanguage("Пополнение баланса","Balance refill")                                              :
      reason==EVENT_REASON_BALANCE_WITHDRAWAL               ?  TextByLanguage("Снятие средств с баланса","Withdrawals from the balance")                          :
      reason==EVENT_REASON_ACCOUNT_CREDIT                   ?  TextByLanguage("Начисление кредита","Credit")                                                      :
      reason==EVENT_REASON_ACCOUNT_CHARGE                   ?  TextByLanguage("Дополнительные сборы","Additional charge")                                         :
      reason==EVENT_REASON_ACCOUNT_CORRECTION               ?  TextByLanguage("Корректирующая запись","Correction")                                               :
      reason==EVENT_REASON_ACCOUNT_BONUS                    ?  TextByLanguage("Перечисление бонусов","Bonus")                                                     :
      reason==EVENT_REASON_ACCOUNT_COMISSION                ?  TextByLanguage("Дополнительные комиссии","Additional commission")                                  :
      reason==EVENT_REASON_ACCOUNT_COMISSION_DAILY          ?  TextByLanguage("Комиссия, начисляемая в конце торгового дня","Daily commission")                   :
      reason==EVENT_REASON_ACCOUNT_COMISSION_MONTHLY        ?  TextByLanguage("Комиссия, начисляемая в конце месяца","Monthly commission")                        :
      reason==EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY    ?  TextByLanguage("Агентская комиссия, начисляемая в конце торгового дня","Daily agent commission")   :
      reason==EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY  ?  TextByLanguage("Агентская комиссия, начисляемая в конце месяца","Monthly agent commission")        :
      reason==EVENT_REASON_ACCOUNT_INTEREST                 ?  TextByLanguage("Начисления процентов на свободные средства","Interest rate")                       :
      reason==EVENT_REASON_BUY_CANCELLED                    ?  TextByLanguage("Отмененная сделка покупки","Canceled buy deal")                                    :
      reason==EVENT_REASON_SELL_CANCELLED                   ?  TextByLanguage("Отмененная сделка продажи","Canceled sell deal")                                   :
      reason==EVENT_REASON_DIVIDENT                         ?  TextByLanguage("Начисление дивиденда","Dividend operations")                                       :
      reason==EVENT_REASON_DIVIDENT_FRANKED                 ?  TextByLanguage("Начисление франкированного дивиденда","Franked (non-taxable) dividend operations") :
      reason==EVENT_REASON_TAX                              ?  TextByLanguage("Начисление налога","Tax charges")                                                  :
      EnumToString(reason)
     );
  }
//+------------------------------------------------------------------+
//| Выводит в журнал свойства события                                |
//+------------------------------------------------------------------+
void CEvent::Print(const bool full_prop=false)
  {
   ::Print("============= ",TextByLanguage("Начало списка параметров события: \"","The beginning of the event parameter list: \""),this.StatusDescription(),"\" =============");
   int beg=0, end=EVENT_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_INTEGER prop=(ENUM_EVENT_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=EVENT_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_DOUBLE prop=(ENUM_EVENT_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=EVENT_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_STRING prop=(ENUM_EVENT_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("================== ",TextByLanguage("Конец списка параметров: \"","End of the parameter list: \""),this.StatusDescription(),"\" ==================\n");
  }
//+------------------------------------------------------------------+
