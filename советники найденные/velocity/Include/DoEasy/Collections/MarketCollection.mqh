//+------------------------------------------------------------------+
//|                                             MarketCollection.mqh |
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
#include "..\Objects\Orders\MarketOrder.mqh"
#include "..\Objects\Orders\MarketPending.mqh"
#include "..\Objects\Orders\MarketPosition.mqh"
#include "OrderControl.mqh"
//+------------------------------------------------------------------+
//| Коллекция рыночных ордеров и позиций                             |
//+------------------------------------------------------------------+
class CMarketCollection : public CListObj
  {
private:
   struct MqlDataCollection
     {
      ulong          hash_sum_acc;           // Хэш-сумма всех ордеров и позиций на счёте
      int            total_market;           // Количество маркет-ордеров на счёте
      int            total_pending;          // Количество отложенных ордеров на счёте
      int            total_positions;        // Количество позиций на счёте
      double         total_volumes;          // Общий объём ордеров и позиций на счёте
     };
   MqlDataCollection m_struct_curr_market;   // Текущие данные рыночных ордеров и позиций на счёте
   MqlDataCollection m_struct_prev_market;   // Прошлые данные рыночных ордеров и позиций на счёте
   CListObj          m_list_all_orders;      // Список отложенных ордеров и позиций на счёте
   CArrayObj         m_list_control;         // Список контрольных ордеров
   CArrayObj         m_list_changed;         // Список изменённых ордеров
   COrder            m_order_instance;       // Объект-ордер для поиска по свойству
   ENUM_CHANGE_TYPE  m_change_type;          // Тип изменения ордера
   bool              m_is_trade_event;       // Флаг торгового события
   bool              m_is_change_volume;     // Флаг изменения общего объёма
   double            m_change_volume_value;  // Величина изменения общего объёма
   ulong             m_k_pow;                // Коэффициент для преобразования цены в число хэш-суммы
   int               m_new_market_orders;    // Количество новых маркет-ордеров
   int               m_new_positions;        // Количество новых позиций
   int               m_new_pendings;         // Количество новых отложенных ордеров
//--- Сохраняет текущие значения состояния данных счёта как прошлые
   void              SavePrevValues(void)                                                                { this.m_struct_prev_market=this.m_struct_curr_market;                  }
//--- Конвертирует данные ордера в число для хэш-суммы
   ulong             ConvertToHS(COrder* order) const;
//--- Добавляет ордер или позицию в список отложенных ордеров и позиций на счёте, устанавливает данные рыночных ордеров и позиций на счёте
   bool              AddToListMarket(COrder* order);
//--- (1) Создаёт и добавляет контрольный ордер в список контрольных ордеров, (2) контрольный ордер в список изменённых контрольных ордеров
   bool              AddToListControl(COrder* order);
   bool              AddToListChanges(COrderControl* order_control);
//--- Удаляет из списка контрольных ордеров ордер по тикету и идентификатору позиции
   bool              DeleteOrderFromListControl(const ulong ticket,const ulong id);
//--- Возвращает индекс контрольного ордера в списке по тикету и идентификатору позиции
   int               IndexControlOrder(const ulong ticket,const ulong id);
//--- Обработчик события изменения существующего ордера/позиции
   void              OnChangeEvent(COrder* order,const int index);
public:
//--- Возвращает список (1) всех отложенных ордеров и открытых позиций, (2) модифицированных ордеров и позиций
   CArrayObj*        GetList(void)                                                                       { return &this.m_list_all_orders;                                       }
   CArrayObj*        GetListChanges(void)                                                                { return &this.m_list_changed;                                          }
//--- Возвращает список ордеров и позиций со временем открытия в диапазоне от begin_time до end_time
   CArrayObj*        GetListByTime(const datetime begin_time=0,const datetime end_time=0);
//--- Возвращает список ордеров и позиций по выбранному (1) double, (2) integer и (3) string свойству, удовлетворяющему сравниваемому условию
   CArrayObj*        GetList(ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj*        GetList(ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL)  { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj*        GetList(ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
//--- Возвращает количество (1) новых маркет-ордеров, (2) новых отложенных ордеров, (3) новых позиций, (4) флаг произошедшего торгового события (5) величину изменённого объёма
   int               NewMarketOrders(void)                                                         const { return this.m_new_market_orders;                                      }
   int               NewPendingOrders(void)                                                        const { return this.m_new_pendings;                                           }
   int               NewPositions(void)                                                            const { return this.m_new_positions;                                          }
   bool              IsTradeEvent(void)                                                            const { return this.m_is_trade_event;                                         }
   double            ChangedVolumeValue(void)                                                      const { return this.m_change_volume_value;                                    }
//--- Конструктор
                     CMarketCollection(void);
//--- Обновляет список отложенных ордеров и позиций
   void              Refresh(void);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CMarketCollection::CMarketCollection(void) : m_is_trade_event(false),m_is_change_volume(false),m_change_volume_value(0)
  {
   this.m_list_all_orders.Sort(SORT_BY_ORDER_TIME_OPEN);
   this.m_list_all_orders.Clear();
   ::ZeroMemory(this.m_struct_prev_market);
   this.m_struct_prev_market.hash_sum_acc=WRONG_VALUE;
   this.m_list_all_orders.Type(COLLECTION_MARKET_ID);
   this.m_list_control.Clear();
   this.m_list_control.Sort();
   this.m_list_changed.Clear();
   this.m_list_changed.Sort();
   this.m_k_pow=(ulong)pow(10,6);
  }
//+------------------------------------------------------------------+
//| Обновляет список ордеров                                         |
//+------------------------------------------------------------------+
void CMarketCollection::Refresh(void)
  {
   ::ZeroMemory(this.m_struct_curr_market);
   this.m_is_trade_event=false;
   this.m_is_change_volume=false;
   this.m_new_pendings=0;
   this.m_new_positions=0;
   this.m_change_volume_value=0;
   this.m_list_all_orders.Clear();
#ifdef __MQL4__
   int total=::OrdersTotal();
   for(int i=0; i<total; i++)
     {
      if(!::OrderSelect(i,SELECT_BY_POS)) continue;
      long ticket=::OrderTicket();
      //--- Получаем индекс контрольного ордера по тикету и идентификатору позиции
      int index=this.IndexControlOrder(ticket);
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderType();
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL)
        {
         CMarketPosition *position=new CMarketPosition(ticket);
         if(position==NULL) continue;
         //--- Добавляем объект-позицию в список рыночных ордеров и позиций
         if(!this.AddToListMarket(position))
            continue;
         //--- Если ордера нет в списке контрольных ордеров и позиций - добавляем
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(order))
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольный ордер ","Failed to add a control order "),order.TypeDescription()," #",order.Ticket());
              }
           }
         //--- Если ордер уже есть в списке контрольных ордеров - проверяем его на предмет изменения свойств
         if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(position,index);
           }
        }
      else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         //--- Добавляем объект-отложенный ордер в список рыночных ордеров и позиций
         if(!this.AddToListMarket(order))
            continue;
         //--- Если ордера нет в списке контрольных ордеров и позиций - добавляем
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(order))
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольный ордер ","Failed to add a control order "),order.TypeDescription()," #",order.Ticket());
              }
           }
         //--- Если ордер уже есть в списке контрольных ордеров - проверяем его на предмет изменения свойств
         if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(order,index);
           }
        }
     }
//--- MQ5
#else 
//--- Позиции
   int total_positions=::PositionsTotal();
   for(int i=0; i<total_positions; i++)
     {
      ulong ticket=::PositionGetTicket(i);
      if(ticket==0) continue;
      CMarketPosition *position=new CMarketPosition(ticket);
      if(position==NULL) continue;
      //--- Добавляем объект-позицию в список рыночных ордеров и позиций
      if(!this.AddToListMarket(position))
         continue;
      //--- Получаем индекс контрольного ордера по тикету и идентификатору позиции
      int index=this.IndexControlOrder(ticket,position.PositionID());
      //--- Если ордера нет в списке контрольных ордеров - добавляем
      if(index==WRONG_VALUE)
        {
         if(!this.AddToListControl(position))
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольую позицию ","Failed to add a control position "),position.TypeDescription()," #",position.Ticket());
           }
        }
      //--- Если ордер уже есть в списке контрольных ордеров - проверяем его на предмет изменения свойств
      else if(index>WRONG_VALUE)
        {
         this.OnChangeEvent(position,index);
        }
     }
//--- Ордера
   int total_orders=::OrdersTotal();
   for(int i=0; i<total_orders; i++)
     {
      ulong ticket=::OrderGetTicket(i);
      if(ticket==0) continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      //--- Маркет-ордер
      if(type<ORDER_TYPE_BUY_LIMIT)
        {
         CMarketOrder *order=new CMarketOrder(ticket);
         if(order==NULL) continue;
         //--- Добавляем объект-маркет-ордер в список рыночных ордеров и позиций
         if(!this.AddToListMarket(order))
            continue;
        }
      //--- Отложенный ордер
      else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         //--- Добавляем объект-отложенный ордер в список рыночных ордеров и позиций
         if(!this.AddToListMarket(order))
            continue;
         //--- Получаем индекс контрольного ордера по тикету и идентификатору позиции
         int index=this.IndexControlOrder(ticket,order.PositionID());
         //--- Если ордера нет в списке контрольных ордеров - добавляем
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(order))
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольный ордер ","Failed to add a control order "),order.TypeDescription()," #",order.Ticket());
              }
           }
         //--- Если ордер уже есть в списке контрольных ордеров - проверяем его на предмет изменения свойств
         else if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(order,index);
           }
        }
     }
#endif 
//--- Первый запуск
   if(this.m_struct_prev_market.hash_sum_acc==WRONG_VALUE)
     {
      this.SavePrevValues();
     }
//--- Если хэш-сумма всех ордеров и позиций изменилась
   if(this.m_struct_curr_market.hash_sum_acc!=this.m_struct_prev_market.hash_sum_acc)
     {
      this.m_new_market_orders=this.m_struct_curr_market.total_market-this.m_struct_prev_market.total_market;
      this.m_new_pendings=this.m_struct_curr_market.total_pending-this.m_struct_prev_market.total_pending;
      this.m_new_positions=this.m_struct_curr_market.total_positions-this.m_struct_prev_market.total_positions;
      this.m_change_volume_value=::NormalizeDouble(this.m_struct_curr_market.total_volumes-this.m_struct_prev_market.total_volumes,4);
      this.m_is_change_volume=(this.m_change_volume_value!=0 ? true : false);
      this.m_is_trade_event=true;
      this.SavePrevValues();
     }
  }
//+------------------------------------------------------------------+
//| Обработчик события изменения существующего ордера/позиции        |
//+------------------------------------------------------------------+
void CMarketCollection::OnChangeEvent(COrder* order,const int index)
  {
   COrderControl* order_control=this.m_list_control.At(index);
   if(order_control!=NULL)
     {
      this.m_change_type=order_control.ChangeControl(order);
      ENUM_CHANGE_TYPE change_type=(order.Status()==ORDER_STATUS_MARKET_POSITION ? CHANGE_TYPE_ORDER_TAKE_PROFIT : CHANGE_TYPE_NO_CHANGE);
      if(this.m_change_type>change_type)
        {
         order_control.SetNewState(order);
         if(!this.AddToListChanges(order_control))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить модифицированный ордер в список изменённых ордеров","Could not add modified order to the list of modified orders"));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Выбирает рыночные ордера или позиции из коллекции со временем    |
//| в диапазоне от begin_time, до end_time                           |
//+------------------------------------------------------------------+
CArrayObj* CMarketCollection::GetListByTime(const datetime begin_time=0,const datetime end_time=0)
  {
   CArrayObj* list=new CArrayObj();
   if(list==NULL)
     {
      ::Print(DFUN,TextByLanguage("Ошибка создания временного списка","Error creating temporary list"));
      return NULL;
     }
   datetime begin=begin_time,end=(end_time==0 ? END_TIME : end_time);
   list.FreeMode(false);
   ListStorage.Add(list);
   m_order_instance.SetProperty(ORDER_PROP_TIME_OPEN,begin);
   int index_begin=m_list_all_orders.SearchGreatOrEqual(&m_order_instance);
   if(index_begin==WRONG_VALUE)
      return list;
   m_order_instance.SetProperty(ORDER_PROP_TIME_OPEN,end);
   int index_end=m_list_all_orders.SearchLessOrEqual(&m_order_instance);
   if(index_end==WRONG_VALUE)
      return list;
   for(int i=index_begin; i<=index_end; i++)
      list.Add(m_list_all_orders.At(i));
   return list;
  }
//+------------------------------------------------------------------+
//| Добавляет ордер или позицию в список ордеров и позиций на счёте  |
//+------------------------------------------------------------------+
bool CMarketCollection::AddToListMarket(COrder *order)
  {
   if(order==NULL)
      return false;
   ENUM_ORDER_STATUS status=order.Status();
   if(this.m_list_all_orders.InsertSort(order))
     {
      if(status==ORDER_STATUS_MARKET_POSITION)
        {
         this.m_struct_curr_market.hash_sum_acc+=order.GetProperty(ORDER_PROP_TIME_UPDATE_MSC)+this.ConvertToHS(order);
         this.m_struct_curr_market.total_volumes+=order.Volume();
         this.m_struct_curr_market.total_positions++;
         return true;
        }
      if(status==ORDER_STATUS_MARKET_PENDING)
        {
         this.m_struct_curr_market.hash_sum_acc+=this.ConvertToHS(order);
         this.m_struct_curr_market.total_volumes+=order.Volume();
         this.m_struct_curr_market.total_pending++;
         return true;
        }
     }
   else
     {
      ::Print(DFUN,order.TypeDescription()," #",order.Ticket()," ",TextByLanguage("не удалось добавить в список","failed to add to the list"));
      delete order;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера по тикету в списке контрольных ордеров  |
//+------------------------------------------------------------------+
int CMarketCollection::IndexControlOrder(const ulong ticket,const ulong id)
  {
   int total=this.m_list_control.Total();
   for(int i=0;i<total;i++)
     {
      COrderControl* order=this.m_list_control.At(i);
      if(order==NULL)
         continue;
      if(order.PositionID()==id && order.Ticket()==ticket)
         return i;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Создаёт и добавляет ордер в список контрольных ордеров           |
//+------------------------------------------------------------------+
bool CMarketCollection::AddToListControl(COrder *order)
  {
   if(order==NULL)
      return false;
   COrderControl* order_control=new COrderControl(order.PositionID(),order.Ticket(),order.Magic(),order.Symbol());
   if(order_control==NULL)
      return false;
   order_control.SetTime(order.TimeOpenMSC());
   order_control.SetTimePrev(order.TimeOpenMSC());
   order_control.SetVolume(order.Volume());
   order_control.SetTime(order.TimeOpenMSC());
   order_control.SetTypeOrder(order.TypeOrder());
   order_control.SetTypeOrderPrev(order.TypeOrder());
   order_control.SetPrice(order.PriceOpen());
   order_control.SetPricePrev(order.PriceOpen());
   order_control.SetStopLoss(order.StopLoss());
   order_control.SetStopLossPrev(order.StopLoss());
   order_control.SetTakeProfit(order.TakeProfit());
   order_control.SetTakeProfitPrev(order.TakeProfit());
   if(!this.m_list_control.Add(order_control))
     {
      delete order_control;
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|Создаёт и добавляет контрольный ордер в список изменённых ордеров |
//+------------------------------------------------------------------+
bool CMarketCollection::AddToListChanges(COrderControl* order_control)
  {
   if(order_control==NULL)
      return false;
   COrderControl* order_changed=new COrderControl(order_control.PositionID(),order_control.Ticket(),order_control.Magic(),order_control.Symbol());
   if(order_changed==NULL)
      return false;
   order_changed.SetTime(order_control.Time());
   order_changed.SetTimePrev(order_control.TimePrev());
   order_changed.SetVolume(order_control.Volume());
   order_changed.SetTypeOrder(order_control.TypeOrder());
   order_changed.SetTypeOrderPrev(order_control.TypeOrderPrev());
   order_changed.SetPrice(order_control.Price());
   order_changed.SetPricePrev(order_control.PricePrev());
   order_changed.SetStopLoss(order_control.StopLoss());
   order_changed.SetStopLossPrev(order_control.StopLossPrev());
   order_changed.SetTakeProfit(order_control.TakeProfit());
   order_changed.SetTakeProfitPrev(order_control.TakeProfitPrev());
   order_changed.SetChangedType(order_control.GetChangeType());
   if(!this.m_list_changed.Add(order_changed))
     {
      delete order_changed;
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Преобразовывает цены ордера и его тип в число для хэш-суммы      |
//+------------------------------------------------------------------+
ulong CMarketCollection::ConvertToHS(COrder *order) const
  {
   if(order==NULL)
      return 0;
   ulong price=ulong(order.PriceOpen()*this.m_k_pow);
   ulong stop=ulong(order.StopLoss()*this.m_k_pow);
   ulong take=ulong(order.TakeProfit()*this.m_k_pow);
   ulong type=order.TypeOrder();
   ulong ticket=order.Ticket();
   return price+stop+take+type+ticket;
  }
//+------------------------------------------------------------------+
