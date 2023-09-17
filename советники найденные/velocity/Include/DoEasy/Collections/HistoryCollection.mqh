//+------------------------------------------------------------------+
//|                                            HistoryCollection.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include "ListObj.mqh"
#include "..\Services\Select.mqh"
#include "..\Objects\Orders\HistoryOrder.mqh"
#include "..\Objects\Orders\HistoryPending.mqh"
#include "..\Objects\Orders\HistoryDeal.mqh"
//+------------------------------------------------------------------+
//| Коллекция исторических ордеров и сделок                          |
//+------------------------------------------------------------------+
class CHistoryCollection : public CListObj
  {
private:
   CListObj          m_list_all_orders;      // Список всех исторических ордеров и сделок
   COrder            m_order_instance;       // Объект-ордер для поиска по свойству
   bool              m_is_trade_event;       // Флаг торгового события
   int               m_index_order;          // Индекс последнего добавленного ордера в коллекцию из списка истории терминала (MQL4, MQL5)
   int               m_index_deal;           // Индекс последней добавленной сделки в коллекцию из списка истории терминала (MQL5)
   int               m_delta_order;          // Разница в количестве ордеров по сравнению с прошлой проверкой
   int               m_delta_deal;           // Разница в количестве сделок по сравнению с прошлой проверкой
//--- Возвращает флаг наличия объекта-ордера по его типу и тикету в списке исторических ордеров и сделок
   bool              IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type);
//--- Возвращает тип и тикет "потерянного" ордера
   ulong             OrderSearch(const int start,ENUM_ORDER_TYPE &order_type);
//--- Создаёт объект-ордер и помещает его в список
   bool              CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type);
public:
   //--- Выбирает ордера из коллекции со временем в диапазоне от begin_time до end_time
   CArrayObj        *GetListByTime(const datetime begin_time=0,const datetime end_time=0,
                                   const ENUM_SELECT_BY_TIME select_time_mode=SELECT_BY_TIME_CLOSE);
   //--- Возвращает полный список-коллекцию "как есть"
   CArrayObj        *GetList(void)                                                                       { return &this.m_list_all_orders;                                       }
   //--- Возвращает список по выбранному (1) целочисленному, (2) вещественному и (3) строковому свойству, удовлетворяющему сравниваемому критерию
   CArrayObj        *GetList(ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL)  { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   //--- Возвращает количество (1) новых ордеров, (2) новых сделок, (3) флаг произошедшего торгового события
   int               NewOrders(void)    const                                                            { return this.m_delta_order;     }
   int               NewDeals(void)     const                                                            { return this.m_delta_deal;      }
   bool              IsTradeEvent(void) const                                                            { return this.m_is_trade_event;  }
   //--- Конструктор
                     CHistoryCollection();
   //--- Обновляет список ордеров, заполняет данные о количестве новых и устанавливает флаг торгового события
   void              Refresh(void);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CHistoryCollection::CHistoryCollection(void) : m_index_deal(0),m_delta_deal(0),m_index_order(0),m_delta_order(0),m_is_trade_event(false)
  {
   this.m_list_all_orders.Sort(#ifdef __MQL5__ SORT_BY_ORDER_TIME_OPEN #else SORT_BY_ORDER_TIME_CLOSE #endif );
   this.m_list_all_orders.Clear();
   this.m_list_all_orders.Type(COLLECTION_HISTORY_ID);
  }
//+------------------------------------------------------------------+
//| Обновляет список ордеров и сделок                                |
//+------------------------------------------------------------------+
void CHistoryCollection::Refresh(void)
  {
#ifdef __MQL4__
   int total=::OrdersHistoryTotal(),i=m_index_order;
   for(; i<total; i++)
     {
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)::OrderType();
      //--- Закрытые позиции и балансные/кредитные операции
      if(order_type<ORDER_TYPE_BUY_LIMIT || order_type>ORDER_TYPE_SELL_STOP)
        {
         CHistoryOrder *order=new CHistoryOrder(::OrderTicket());
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to the list"));
            delete order;
           }
        }
      else
        {
         //--- Удалённые отложенные ордера
         CHistoryPending *order=new CHistoryPending(::OrderTicket());
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to the list"));
            delete order;
           }
        }
     }
//---
   int delta_order=i-m_index_order;
   this.m_index_order=i;
   this.m_delta_order=delta_order;
   this.m_is_trade_event=(this.m_delta_order!=0 ? true : false);
//--- __MQL5__
#else 
   if(!::HistorySelect(0,END_TIME)) return;
//--- Ордера
   int total_orders=::HistoryOrdersTotal(),i=m_index_order;
   for(; i<total_orders; i++)
     {
      ulong order_ticket=::HistoryOrderGetTicket(i);
      if(order_ticket==0) continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(order_ticket,ORDER_TYPE);
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL || type==ORDER_TYPE_CLOSE_BY)
        {
         //--- Если ордера такого типа и с таким тикетом нет в списке, создаём объёкт-ордер и добавляем в список
         if(!this.IsPresentOrderInList(order_ticket,type))
           {
            if(!this.CreateNewOrder(order_ticket,type))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to the list"));
           }
         //--- Такой ордер уже есть в списке - значит нужный ордер размещён не последним в список истории. Найдём пропажу
         else
           {
            ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
            ulong ticket_lost=this.OrderSearch(i,type_lost);
            if(ticket_lost>0 && !this.CreateNewOrder(ticket_lost,type_lost))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to the list"));
           }
        }
      else
        {
         //--- Если отложенного ордера такого типа и с таким тикетом нет в списке, создаём объёкт-ордер и добавляем в список
         if(!this.IsPresentOrderInList(order_ticket,type))
           {
            if(!this.CreateNewOrder(order_ticket,type))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to the list"));
           }
         //--- Такой ордер уже есть в списке - значит нужный ордер размещён не последним в список истории. Найдём пропажу
         else
           {
            ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
            ulong ticket_lost=this.OrderSearch(i,type_lost);
            if(ticket_lost>0 && !this.CreateNewOrder(ticket_lost,type_lost))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to the list"));
           }
        }
     }
//--- сохранение индекса последнего добавленного ордера и разницы по сравнению с прошлой проверкой
   int delta_order=i-this.m_index_order;
   this.m_index_order=i;
   this.m_delta_order=delta_order;

//--- Сделки
   int total_deals=::HistoryDealsTotal(),j=m_index_deal;
   for(; j<total_deals; j++)
     {
      ulong deal_ticket=::HistoryDealGetTicket(j);
      if(deal_ticket==0) continue;
      CHistoryDeal *deal=new CHistoryDeal(deal_ticket);
      if(deal==NULL) continue;
      if(!this.m_list_all_orders.InsertSort(deal))
        {
         ::Print(DFUN,TextByLanguage("Не удалось добавить сделку в список","Could not add deal to the list"));
         delete deal;
        }
     }
//--- сохранение индекса последней добавленной сделки и разницы по сравнению с прошлой проверкой
   int delta_deal=j-this.m_index_deal;
   this.m_index_deal=j;
   this.m_delta_deal=delta_deal;
//--- Установка флага нового события в истории
   this.m_is_trade_event=(this.m_delta_order+this.m_delta_deal);
#endif 
  }
//+------------------------------------------------------------------+
//| Выбирает ордера из коллекции со временем                         |
//| в диапазоне от begin_time, до end_time                           |
//+------------------------------------------------------------------+
CArrayObj *CHistoryCollection::GetListByTime(const datetime begin_time=0,const datetime end_time=0,
                                             const ENUM_SELECT_BY_TIME select_time_mode=SELECT_BY_TIME_CLOSE)
  {
   ENUM_ORDER_PROP_INTEGER property=
     (
      select_time_mode==SELECT_BY_TIME_CLOSE       ?  ORDER_PROP_TIME_CLOSE      : 
      select_time_mode==SELECT_BY_TIME_OPEN        ?  ORDER_PROP_TIME_OPEN       :
      select_time_mode==SELECT_BY_TIME_CLOSE_MSC   ?  ORDER_PROP_TIME_CLOSE_MSC  : 
      ORDER_PROP_TIME_OPEN_MSC
     );

   CArrayObj *list=new CArrayObj();
   if(list==NULL)
     {
      ::Print(DFUN+TextByLanguage("Ошибка создания временного списка","Error creating temporary list"));
      return NULL;
     }
   datetime begin=begin_time,end=(end_time==0 ? END_TIME : end_time);
   if(begin_time>end_time) begin=0;
   list.FreeMode(false);
   ListStorage.Add(list);
   //---
   this.m_order_instance.SetProperty(property,begin);
   int index_begin=this.m_list_all_orders.SearchGreatOrEqual(&m_order_instance);
   if(index_begin==WRONG_VALUE)
      return list;
   this.m_order_instance.SetProperty(property,end);
   int index_end=this.m_list_all_orders.SearchLessOrEqual(&m_order_instance);
   if(index_end==WRONG_VALUE)
      return list;
   for(int i=index_begin; i<=index_end; i++)
      list.Add(this.m_list_all_orders.At(i));
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает флаг наличия объекта-ордера в списке по типу и тикету |
//+------------------------------------------------------------------+
bool CHistoryCollection::IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type)
  {
   CArrayObj* list=dynamic_cast<CListObj*>(&this.m_list_all_orders);
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,type,EQUAL);
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TICKET,order_ticket,EQUAL);
   return(list.Total()>0);
  }
//+------------------------------------------------------------------+
//| Возвращает тип и тикет "потерянного" ордера                      |
//+------------------------------------------------------------------+
ulong CHistoryCollection::OrderSearch(const int start,ENUM_ORDER_TYPE &order_type)
  {
   ulong order_ticket=0;
   for(int i=start-1;i>=0;i--)
     {
      ulong ticket=::HistoryOrderGetTicket(i);
      if(ticket==0)
         continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(ticket,ORDER_TYPE);
      if(this.IsPresentOrderInList(ticket,type))
         continue;
      order_ticket=ticket;
      order_type=type;
     }
   return order_ticket;
  }
//+------------------------------------------------------------------+
//| Создаёт объект-ордер и помещает его в список                     |
//+------------------------------------------------------------------+
bool CHistoryCollection::CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type)
  {
   COrder* order=NULL;
   if(order_type==ORDER_TYPE_BUY)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_BUY_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_BUY_STOP)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_STOP)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
#ifdef __MQL5__
   else if(order_type==ORDER_TYPE_BUY_STOP_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_STOP_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_CLOSE_BY)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
#endif 
   if(this.m_list_all_orders.InsertSort(order))
      return true;
   else
     {
      delete order;
      return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
