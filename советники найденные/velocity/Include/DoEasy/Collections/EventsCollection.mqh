//+------------------------------------------------------------------+
//|                                             EventsCollection.mqh |
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
#include "..\Objects\Orders\Order.mqh"
#include "..\Objects\Events\EventBalanceOperation.mqh"
#include "..\Objects\Events\EventOrderPlaced.mqh"
#include "..\Objects\Events\EventOrderRemoved.mqh"
#include "..\Objects\Events\EventPositionOpen.mqh"
#include "..\Objects\Events\EventPositionClose.mqh"
#include "..\Objects\Events\EventModify.mqh"
//+------------------------------------------------------------------+
//| Коллекция событий счёта                                          |
//+------------------------------------------------------------------+
class CEventsCollection : public CListObj
  {
private:
   CListObj          m_list_events;                   // Список событий
   bool              m_is_hedge;                      // Флаг хедж-счёта
   long              m_chart_id;                      // Идентификатор графика управляющей программы
   int               m_trade_event_code;              // Код торгового события
   ENUM_TRADE_EVENT  m_trade_event;                   // Торговое событие на счёте
   CEvent            m_event_instance;                // Объект-событие для поиска по свойству
   MqlTick           m_tick;                          // Структура последнего тика
   
//--- Создаёт торговое событие в зависимости от (1) статуса и (2) типа изменения ордера
   void              CreateNewEvent(COrder* order,CArrayObj* list_history,CArrayObj* list_market);
   void              CreateNewEvent(COrderControl* order);
//--- Создаёт событие для (1) хеджевого счёта, (2) неттингового счёта
   void              NewDealEventHedge(COrder* deal,CArrayObj* list_history,CArrayObj* list_market);
   void              NewDealEventNetto(COrder* deal,CArrayObj* list_history,CArrayObj* list_market);
//--- Выбирает из списка и возвращает список рыночных отложенных ордеров
   CArrayObj*        GetListMarketPendings(CArrayObj* list);
//--- Выбирает из списка и возвращает список исторических (1) удалённых отложенных ордеров, (2) сделок, (3) всех закрывающих ордеров 
   CArrayObj*        GetListHistoryPendings(CArrayObj* list);
   CArrayObj*        GetListDeals(CArrayObj* list);
   CArrayObj*        GetListCloseByOrders(CArrayObj* list);
//--- Возвращает список (1) всех ордеров позиции по её идентификатору, (2) всех сделок позиции по её идентификатору
//--- (3) всех сделок на вход в рынок по идентификатору позиции, (4) всех сделок на выход из рынка по идентификатору позиции,
//--- (5) всех сделок на разворот позиции по идентификатору позиции
   CArrayObj*        GetListAllOrdersByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsInByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsOutByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsInOutByPosID(CArrayObj* list,const ulong position_id);
//--- Возвращает суммарный объём всех сделок (1) IN, (2) OUT позиции по её идентификатору
   double            SummaryVolumeDealsInByPosID(CArrayObj* list,const ulong position_id);
   double            SummaryVolumeDealsOutByPosID(CArrayObj* list,const ulong position_id);
//--- Возвращает (1) первый, (2) последний и (3) закрывающий ордер из списка всех ордеров позиции,
//--- (4) ордер по тикету, (5) рыночную позицию по идентификатору,
//--- (6) последнюю и (7) предпоследнюю сделку InOut по идентификатору позиции
   COrder*           GetFirstOrderFromList(CArrayObj* list,const ulong position_id);
   COrder*           GetLastOrderFromList(CArrayObj* list,const ulong position_id);
   COrder*           GetCloseByOrderFromList(CArrayObj* list,const ulong position_id);
   COrder*           GetHistoryOrderByTicket(CArrayObj* list,const ulong order_ticket);
   COrder*           GetPositionByID(CArrayObj* list,const ulong position_id);
//--- Возвращает флаг наличия объекта-события в списке событий
   bool              IsPresentEventInList(CEvent* compared_event);
//--- Обработчик события изменения существующего ордера/позиции
   void              OnChangeEvent(CArrayObj* list_changes,const int index);

public:
//--- Выбирает события из коллекции со временем в диапазоне от begin_time до end_time
   CArrayObj        *GetListByTime(const datetime begin_time=0,const datetime end_time=0);
//--- Возвращает полный список-коллекцию событий "как есть"
   CArrayObj        *GetList(void)                                                                       { return &this.m_list_events;                                           }
//--- Возвращает список по выбранному (1) целочисленному, (2) вещественному и (3) строковому свойству, удовлетворяющему сравниваемому критерию
   CArrayObj        *GetList(ENUM_EVENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL)  { return CSelect::ByEventProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_EVENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByEventProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_EVENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByEventProperty(this.GetList(),property,value,mode);  }
//--- Обновляет список событий
   void              Refresh(CArrayObj* list_history,
                             CArrayObj* list_market,
                             CArrayObj* list_changes,
                             const bool is_history_event,
                             const bool is_market_event,
                             const int  new_history_orders,
                             const int  new_market_pendings,
                             const int  new_market_positions,
                             const int  new_deals);
//--- Устанавливает идентификатор графика управляющей программы
   void              SetChartID(const long id)        { this.m_chart_id=id;         }
//--- Возвращает последнее торговое событие на счёте
   ENUM_TRADE_EVENT  GetLastTradeEvent(void)    const { return this.m_trade_event;  }
//--- Сбрасывает последнее торговое событие
   void              ResetLastTradeEvent(void)        { this.m_trade_event=TRADE_EVENT_NO_EVENT;   }
//--- Конструктор
                     CEventsCollection(void);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CEventsCollection::CEventsCollection(void) : m_trade_event(TRADE_EVENT_NO_EVENT),m_trade_event_code(TRADE_EVENT_FLAG_NO_EVENT)
  {
   this.m_list_events.Clear();
   this.m_list_events.Sort(SORT_BY_EVENT_TIME_EVENT);
   this.m_list_events.Type(COLLECTION_EVENTS_ID);
   this.m_is_hedge=bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   this.m_chart_id=::ChartID();
   ::ZeroMemory(this.m_tick);
  }
//+------------------------------------------------------------------+
//| Обновляет список событий                                         |
//+------------------------------------------------------------------+
void CEventsCollection::Refresh(CArrayObj* list_history,
                                CArrayObj* list_market,
                                CArrayObj* list_changes,
                                const bool is_history_event,
                                const bool is_market_event,
                                const int  new_history_orders,
                                const int  new_market_pendings,
                                const int  new_market_positions,
                                const int  new_deals)
  {
//--- Если списки пустые - выход
   if(list_history==NULL || list_market==NULL)
      return;
//--- Если событие в рыночном окружении
   if(is_market_event)
     {
      //--- если было изменение свойств ордера
      int total_changes=list_changes.Total();
      if(total_changes>0)
        {
         for(int i=total_changes-1;i>=0;i--)
           {
            this.OnChangeEvent(list_changes,i);
           }
        }
      //--- если увеличилось количество установленных отложенных ордеров
      if(new_market_pendings>0)
        {
         //--- Получаем список только установленных отложенных ордеров
         CArrayObj* list=this.GetListMarketPendings(list_market);
         if(list!=NULL)
           {
            //--- Сортируем новый список по времени установки ордера
            list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
            //--- Берём в цикле с конца списка количество ордеров, равное количеству новых установленных ордеров (последние N событий)
            int total=list.Total(), n=new_market_pendings;
            for(int i=total-1; i>=0 && n>0; i--,n--)
              {
               //--- Получаем ордер из списка, и если это отложенный ордер - устанавливаем торговое событие
               COrder* order=list.At(i);
               if(order!=NULL && order.Status()==ORDER_STATUS_MARKET_PENDING)
                  this.CreateNewEvent(order,list_history,list_market);
              }
           }
        }
     }
//--- Если событие в истории счёта
   if(is_history_event)
     {
      //--- Если увеличилось количество исторических ордеров
      if(new_history_orders>0)
        {
         //--- Получаем список только удалённых отложенных ордеров
         CArrayObj* list=this.GetListHistoryPendings(list_history);
         if(list!=NULL)
           {
            //--- Сортируем новый список по времени удаления ордера
            list.Sort(SORT_BY_ORDER_TIME_CLOSE_MSC);
            //--- Берём в цикле с конца списка количество ордеров, равное количеству новых удалённых отложенных ордеров (последние N событий)
            int total=list.Total(), n=new_history_orders;
            for(int i=total-1; i>=0 && n>0; i--,n--)
              {
               //--- Получаем ордер из списка, и если это удалённый отложенный ордер и у него нет идентификатора позиции, 
               //--- то это удаление ордера - устанавливаем торговое событие
               COrder* order=list.At(i);
               if(order!=NULL && order.Status()==ORDER_STATUS_HISTORY_PENDING && order.PositionID()==0)
                  this.CreateNewEvent(order,list_history,list_market);
              }
           }
        }
      //--- Если увеличилось количество сделок
      if(new_deals>0)
        {
         //--- Получаем список только сделок
         CArrayObj* list=this.GetListDeals(list_history);
         if(list!=NULL)
           {
            //--- Сортируем новый список по времени совершения сделки
            list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
            //--- Берём в цикле с конца списка количество сделок, равное количеству новых сделок (последние N событий)
            int total=list.Total(), n=new_deals;
            for(int i=total-1; i>=0 && n>0; i--,n--)
              {
               //--- Получаем сделку из списка и устанавливаем торговое событие
               COrder* order=list.At(i);
               if(order!=NULL)
                  this.CreateNewEvent(order,list_history,list_market);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Обработчик события изменения существующего ордера/позиции        |
//+------------------------------------------------------------------+
void CEventsCollection::OnChangeEvent(CArrayObj* list_changes,const int index)
  {
   COrderControl* order_changed=list_changes.Detach(index);
   if(order_changed!=NULL)
     {
      this.CreateNewEvent(order_changed);
      delete order_changed;
     }
  }
//+------------------------------------------------------------------+
//| Создаёт торговое событие в зависимости от типа изменения ордера  |
//+------------------------------------------------------------------+
void CEventsCollection::CreateNewEvent(COrderControl* order)
  {
   if(!::SymbolInfoTick(order.Symbol(),this.m_tick))
     {
      Print(DFUN,TextByLanguage("Не удалось получить текущие цены по символу события ","Failed to get current prices by event symbol "),order.Symbol());
      return;
     }
   CEvent* event=NULL;
//--- Сработал отложенный StopLimit-ордер
   if(order.GetChangeType()==CHANGE_TYPE_ORDER_TYPE)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_PLASED;
      event=new CEventOrderPlased(this.m_trade_event_code,order.Ticket());
     }
//--- Модификация
   else
     {
      //--- Модифицирована цена отложенного ордера
      if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE;
      //--- Модифицирована цена отложенного ордера и его StopLoss
      else if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE_STOP_LOSS)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE+TRADE_EVENT_FLAG_SL;
      //--- Модифицирована цена отложенного ордера и его TakeProfit
      else if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE+TRADE_EVENT_FLAG_TP;
      //--- Модифицирована цена отложенного ордера, его StopLoss и TakeProfit
      else if(order.GetChangeType()==CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_PRICE+TRADE_EVENT_FLAG_SL+TRADE_EVENT_FLAG_TP;
      //--- Модифицирован StopLoss отложенного ордера
      else if(order.GetChangeType()==CHANGE_TYPE_ORDER_STOP_LOSS)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_SL;
      //--- Модифицирован TakeProfit отложенного ордера
      else if(order.GetChangeType()==CHANGE_TYPE_ORDER_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_TP;
      //--- Модифицирован StopLoss и TakeProfit отложенного ордера
      else if(order.GetChangeType()==CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_MODIFY+TRADE_EVENT_FLAG_SL+TRADE_EVENT_FLAG_TP;

      //--- Модифицирован StopLoss позиции
      else if(order.GetChangeType()==CHANGE_TYPE_POSITION_STOP_LOSS)
         this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_MODIFY+TRADE_EVENT_FLAG_SL;
      //--- Модифицирован TakeProfit позиции
      else if(order.GetChangeType()==CHANGE_TYPE_POSITION_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_MODIFY+TRADE_EVENT_FLAG_TP;
      //--- Модифицирован StopLoss и TakeProfit позиции
      else if(order.GetChangeType()==CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT)
         this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_MODIFY+TRADE_EVENT_FLAG_SL+TRADE_EVENT_FLAG_TP;
      
      //--- Создаём событие модификации
      event=new CEventModify(this.m_trade_event_code,order.Ticket());
     }
//--- Создание события
   if(event!=NULL)
     {
      event.SetProperty(EVENT_PROP_TIME_EVENT,order.Time());                        // Время события
      event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_STOPLIMIT_TRIGGERED);  // Причина события (из перечисления ENUM_EVENT_REASON)
      event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,PositionTypeByOrderType((ENUM_ORDER_TYPE)order.TypeOrderPrev())); // Тип ордера, срабатывание которого привело к событию
      event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());               // Тикет ордера , срабатывание которого привело к событию
      event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());             // Тип ордера события
      event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());              // Тикет ордера события
      event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());          // Тип первого ордера позиции
      event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());           // Тикет первого ордера позиции
      event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                 // Идентификатор позиции
      event.SetProperty(EVENT_PROP_POSITION_BY_ID,0);                               // Идентификатор встречной позиции
      event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                  // Магический номер встречной позиции
         
      event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrderPrev());      // Тип ордера позиции до смены направления
      event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());           // Тикет ордера позиции до смены направления
      event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());         // Тип ордера текущей позиции
      event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());          // Тикет ордера текущей позиции
      
      event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PricePrev());            // Цена установки ордера до модификации
      event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLossPrev());           // Цена StopLoss до модификации
      event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfitPrev());         // Цена TakeProfit до модификации
      event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                // Цена Ask в момент события
      event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                // Цена Bid в момент события
         
      event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                      // Магический номер ордера
      event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimePrev());           // Время первого ордера позиции
      event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PricePrev());                  // Цена, на которой произошло событие
      event.SetProperty(EVENT_PROP_PRICE_OPEN,order.Price());                       // Цена установки ордера
      event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.Price());                      // Цена закрытия ордера
      event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                      // Цена StopLoss ордера
      event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                    // Цена TakeProfit ордера
      event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());            // Запрашиваемый объём ордера
      event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,0);                        // Исполненный объём ордера
      event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.Volume());            // Оставшийся (неисполненный) объём ордера
      event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                     // Исполненный объём позиции
      event.SetProperty(EVENT_PROP_PROFIT,0);                                       // Профит
      event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                          // Символ ордера
      event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                    // Символ встречной позиции
      //--- Установка идентификатора графика управляющей программы, расшифровка кода события и установка типа события
      event.SetChartID(this.m_chart_id);
      event.SetTypeEvent();
      //--- Если объекта-события нет в списке - добавляем
      if(!this.IsPresentEventInList(event))
        {
         this.m_list_events.InsertSort(event);
         //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
         event.SendEvent();
         this.m_trade_event=event.TradeEvent();
        }
      //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
      else
        {
         ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
         delete event;
        }
     }
  }
//+------------------------------------------------------------------+
//| Создаёт торговое событие в зависимости от статуса ордера         |
//+------------------------------------------------------------------+
void CEventsCollection::CreateNewEvent(COrder* order,CArrayObj* list_history,CArrayObj* list_market)
  {
   if(!::SymbolInfoTick(order.Symbol(),this.m_tick))
     {
      Print(DFUN,TextByLanguage("Не удалось получить текущие цены по символу события ","Failed to get current prices by event symbol "),order.Symbol());
      return;
     }
   this.m_trade_event_code=TRADE_EVENT_FLAG_NO_EVENT;
   ENUM_ORDER_STATUS status=order.Status();
//--- Установлен отложенный ордер
   if(status==ORDER_STATUS_MARKET_PENDING)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_PLASED;
      CEvent* event=new CEventOrderPlased(this.m_trade_event_code,order.Ticket());
      if(event!=NULL)
        {
         event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpenMSC());                             // Время события
         event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_DONE);                             // Причина события (из перечисления ENUM_EVENT_REASON)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeByDirection());                    // Тип сделки события
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Тикет ордера события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Тип ордера события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Тип ордера события
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Тикет ордера события
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Тикет ордера
         event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Идентификатор позиции
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Идентификатор встречной позиции
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                              // Магический номер встречной позиции
            
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Тип ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Тикет ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Тип ордера текущей позиции
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Тикет ордера текущей позиции
      
         event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Цена установки ордера до модификации
         event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // Цена StopLoss до модификации
         event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // Цена TakeProfit до модификации
         event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Цена Ask в момент события
         event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Цена Bid в момент события
         
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Магический номер ордера
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpenMSC());                    // Время ордера
         event.SetProperty(EVENT_PROP_PRICE_EVENT,this.m_tick.bid);                                // Цена Bid, на которой произошло событие
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Цена установки ордера
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Цена закрытия ордера
         event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // Цена StopLoss ордера
         event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // Цена TakeProfit ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Запрашиваемый объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Исполненный объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Оставшийся (неисполненный) объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                                 // Исполненный объём позиции
         event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Профит
         event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Символ ордера
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Символ встречной позиции
         //--- Установка идентификатора графика управляющей программы, расшифровка кода события и установка типа события
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Если объекта-события нет в списке - добавляем
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
            delete event;
           }
        }
     }
//--- Удалён отложенный ордер
   if(status==ORDER_STATUS_HISTORY_PENDING)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_REMOVED;
      CEvent* event=new CEventOrderRemoved(this.m_trade_event_code,order.Ticket());
      if(event!=NULL)
        {
         ENUM_EVENT_REASON reason=
           (
            order.State()==ORDER_STATE_CANCELED ? EVENT_REASON_CANCEL :
            order.State()==ORDER_STATE_EXPIRED  ? EVENT_REASON_EXPIRED : EVENT_REASON_DONE
           );
         event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeCloseMSC());                            // Время события
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                        // Причина события (из перечисления ENUM_EVENT_REASON)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeByDirection());                    // Тип ордера события
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Тикет ордера события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Тип ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Тикет ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Идентификатор позиции
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Идентификатор встречной позиции
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                              // Магический номер встречной позиции
            
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Тип ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Тикет ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Тип ордера текущей позиции
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Тикет ордера текущей позиции
      
         event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Цена установки ордера до модификации
         event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // Цена StopLoss до модификации
         event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // Цена TakeProfit до модификации
         event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Цена Ask в момент события
         event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Цена Bid в момент события
         
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Магический номер ордера
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpenMSC());                    // Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_PRICE_EVENT,this.m_tick.bid);                                // Цена Bid, на которой произошло событие
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Цена установки ордера
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Цена закрытия ордера
         event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // Цена StopLoss ордера
         event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // Цена TakeProfit ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Запрашиваемый объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Исполненный объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Оставшийся (неисполненный) объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                                 // Исполненный объём позиции
         event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Профит
         event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Символ ордера
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Символ встречной позиции
         //--- Установка идентификатора графика управляющей программы и расшифровка кода события и установка типа события
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Если объекта-события нет в списке - добавляем
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
            delete event;
           }
        }
     }
//--- Открыта позиция (__MQL4__)
   if(status==ORDER_STATUS_MARKET_POSITION)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
      CEvent* event=new CEventPositionOpen(this.m_trade_event_code,order.Ticket());
      if(event!=NULL)
        {
         event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpen());                                // Время события
         event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_DONE);                             // Причина события (из перечисления ENUM_EVENT_REASON)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());                          // Тип сделки события
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Тикет сделки события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Тип ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Тикет ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Идентификатор позиции
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Идентификатор встречной позиции
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                              // Магический номер встречной позиции
            
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Тип ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Тикет ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Тип ордера текущей позиции
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Тикет ордера текущей позиции
      
         event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());                        // Цена установки ордера до модификации
         event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());                           // Цена StopLoss до модификации
         event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());                         // Цена TakeProfit до модификации
         event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                            // Цена Ask в момент события
         event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                            // Цена Bid в момент события
         
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Магический номер ордера/сделки/позиции
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());                       // Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                              // Цена, на которой произошло событие
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Цена открытия ордера/сделки/позиции
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Цена закрытия ордера/сделки/позиции
         event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // Цена StopLoss позиции
         event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // Цена TakeProfit позиции
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Запрашиваемый объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Исполненный объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Оставшийся (неисполненный) объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());                    // Исполненный объём позиции
         event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Профит
         event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Символ ордера
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Символ встречной позиции
         //--- Установка идентификатора графика управляющей программы и расшифровка кода события и установка типа события
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Если объекта-события нет в списке - добавляем
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
            delete event;
           }
        }
     }
//--- Новая сделка (__MQL5__)
   if(status==ORDER_STATUS_DEAL)
     {
      //--- Новая балансная оберация
      if((ENUM_DEAL_TYPE)order.TypeOrder()>DEAL_TYPE_SELL)
        {
         this.m_trade_event_code=TRADE_EVENT_FLAG_ACCOUNT_BALANCE;
         CEvent* event=new CEventBalanceOperation(this.m_trade_event_code,order.Ticket());
         if(event!=NULL)
           {
            ENUM_EVENT_REASON reason=
              (
               (ENUM_DEAL_TYPE)order.TypeOrder()==DEAL_TYPE_BALANCE ? (order.Profit()>0 ? EVENT_REASON_BALANCE_REFILL : EVENT_REASON_BALANCE_WITHDRAWAL) :
               (ENUM_EVENT_REASON)(order.TypeOrder()+REASON_EVENT_SHIFT)
              );
            event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpenMSC());                 // Время события
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Причина события (из перечисления ENUM_EVENT_REASON)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());              // Тип сделки события
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());               // Тикет сделки события
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());             // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());          // Тип ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());              // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());           // Тикет ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                 // Идентификатор позиции
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());            // Идентификатор встречной позиции
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                  // Магический номер встречной позиции
            
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());          // Тип ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());           // Тикет ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());         // Тип ордера текущей позиции
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());          // Тикет ордера текущей позиции
      
            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order.PriceOpen());            // Цена установки ордера до модификации
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order.StopLoss());               // Цена StopLoss до модификации
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order.TakeProfit());             // Цена TakeProfit до модификации
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,this.m_tick.ask);                // Цена Ask в момент события
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,this.m_tick.bid);                // Цена Bid в момент события
         
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                      // Магический номер ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpenMSC());        // Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                  // Цена, на которой произошло событие
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                   // Цена открытия ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceOpen());                  // Цена закрытия ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_PRICE_SL,0);                                     // Цена StopLoss сделки
            event.SetProperty(EVENT_PROP_PRICE_TP,0);                                     // Цена TakeProfit сделки
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());            // Запрашиваемый объём сделки
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume());           // Исполненный объём сделки
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,0);                         // Оставшийся (неисполненный) объём сделки
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());        // Исполненный объём позиции
            event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                          // Профит
            event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                          // Символ ордера
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                    // Символ встречной позиции
            //--- Установка идентификатора графика управляющей программы и расшифровка кода события и установка типа события
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Если объекта-события нет в списке - добавляем
            if(!this.IsPresentEventInList(event))
              {
               //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
               this.m_list_events.InsertSort(event);
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
               delete event;
              }
           }
        }
      //--- Если это не балансная операция
      else
        {
         if(this.m_is_hedge)
            this.NewDealEventHedge(order,list_history,list_market);
         else
            this.NewDealEventNetto(order,list_history,list_market);
        }
     }
  }
//+------------------------------------------------------------------+
//| Создаёт событие для хеджевого счёта                              |
//+------------------------------------------------------------------+
void CEventsCollection::NewDealEventHedge(COrder* deal,CArrayObj* list_history,CArrayObj* list_market)
  {
   double ask=::SymbolInfoDouble(deal.Symbol(),SYMBOL_ASK);
   double bid=::SymbolInfoDouble(deal.Symbol(),SYMBOL_BID);
   //--- Вход в рынок
   if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
      int reason=EVENT_REASON_DONE;
      //--- Ищем все сделки позиции в направлении её открытия и считаем их общий объём
      double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
      //--- Возьмём ордер сделки и последний ордер позиции из списка всех ордеров позиции
      ulong order_ticket=deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);
      COrder* order_first=this.GetHistoryOrderByTicket(list_history,order_ticket);
      COrder* order_last=this.GetLastOrderFromList(list_history,deal.PositionID());
      //--- Получим открытую позицию по тикету
      COrder* position=this.GetPositionByID(list_market,deal.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
      //--- Если последнего ордера нет, то первый и последний ордер позиции - один и тот же
      if(order_last==NULL)
         order_last=order_first;
      if(order_first!=NULL)
        {
         //--- Если не весь объём ордера открыт - значит частичное исполнение
         if(this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID())<order_first.Volume())
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            reason=EVENT_REASON_DONE_PARTIALLY;
           }
         //--- Если открывающий ордер - отложенный, значит - активирован отложенный ордер
         if(order_first.TypeOrder()>ORDER_TYPE_SELL && order_first.TypeOrder()<ORDER_TYPE_CLOSE_BY)
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
            //--- Если ордер исполнен частично, ставим в причину события частичное исполнение ордера
            reason=
              (this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID())<order_first.Volume() ? 
               EVENT_REASON_ACTIVATED_PENDING_PARTIALLY : 
               EVENT_REASON_ACTIVATED_PENDING
              );
           }
         CEvent* event=new CEventPositionOpen(this.m_trade_event_code,deal.PositionID());
         if(event!=NULL)
           {
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                        // Время события (Время открытия позиции)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Причина события (из перечисления ENUM_EVENT_REASON)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Тип сделки события
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Тикет сделки события
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Тип ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Тикет ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_last.TypeOrder());              // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_last.Ticket());               // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Идентификатор позиции
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last.PositionByID());             // Идентификатор встречной позиции
            //---
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                        // Магический номер встречной позиции
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Тип ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Тикет ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Тип ордера текущей позиции
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Тикет ордера текущей позиции
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                           // Символ встречной позиции
            //---
            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first.PriceOpen());            // Цена установки ордера до модификации
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first.StopLoss());               // Цена StopLoss до модификации
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first.TakeProfit());             // Цена TakeProfit до модификации
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                                  // Цена Ask в момент события
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                                  // Цена Bid в момент события
            //---
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Магический номер ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpenMSC());        // Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Цена, на которой произошло событие (Цена открытия позиции)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Цена открытия ордера (Цена установки открывающего ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last.PriceClose());                  // Цена закрытия ордера (Цена закрытия последнего ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // Цена StopLoss (Цена StopLoss ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // Цена TakeProfit (Цена TakeProfit ордера позиции)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_first.Volume());                                 // Запрашиваемый объём ордера
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,(order_first.Volume()-order_first.VolumeCurrent()));  // Исполненный объём ордера
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order_first.VolumeCurrent());                          // Оставшийся (неисполненный) объём ордера
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                                     // Исполненный объём позиции
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Профит
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Символ ордера
            //--- Установка идентификатора графика управляющей программы и расшифровка кода события и установка типа события
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Если объекта-события нет в списке - добавляем
            if(!this.IsPresentEventInList(event))
              {
               this.m_list_events.InsertSort(event);
               //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
               delete event;
              }
           }
        }
     }
   //--- Выход из рынка
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
      int reason=EVENT_REASON_DONE;
      //--- Возьмём первый и последний ордера позиции из списка всех ордеров позиции
      COrder* order_first=this.GetFirstOrderFromList(list_history,deal.PositionID());
      COrder* order_last=this.GetLastOrderFromList(list_history,deal.PositionID());
      //--- Получим открытую позицию по тикету
      COrder* position=this.GetPositionByID(list_market,deal.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
      if(order_first!=NULL && order_last!=NULL)
        {
         //--- Ищем все сделки позиции в направлении её открытия и закрытия, и считаем их общий объём
         double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
         double volume_out=this.SummaryVolumeDealsOutByPosID(list_history,deal.PositionID());
         //--- Рассчитываем текущий объём закрытой позиции
         int dgl=(int)DigitsLots(deal.Symbol());
         double volume_current=::NormalizeDouble(volume_in-volume_out,dgl);
         //--- Если не весь объём позиции закрыт - значит частичное исполнение
         if(volume_current>0)
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
           }
         //--- Если закрывающий ордер исполнен частично, ставим в причину события частичное исполнение закрывающего ордера
         if(order_last.VolumeCurrent()>0)
           {
            reason=EVENT_REASON_DONE_PARTIALLY;
           }
         //--- Если у закрывающего ордера позиции выставлен флаг закрытия по StopLoss - значит закрытие по StopLoss
         //--- Если StopLoss-ордер исполнен частично, ставим в причину события частичное исполнение ордера StopLoss
         if(order_last.IsCloseByStopLoss())
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
            reason=(order_last.VolumeCurrent()>0 ? EVENT_REASON_DONE_SL_PARTIALLY : EVENT_REASON_DONE_SL);
           }
         //--- Если у закрывающего ордера позиции выставлен флаг закрытия по TakeProfit - значит закрытие по TakeProfit
         //--- Если TakeProfit-ордер исполнен частично, ставим в причину события частичное исполнение ордера TakeProfit
         else if(order_last.IsCloseByTakeProfit())
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
            reason=(order_last.VolumeCurrent()>0 ? EVENT_REASON_DONE_TP_PARTIALLY : EVENT_REASON_DONE_TP);
           }
         //---
         CEvent* event=new CEventPositionClose(this.m_trade_event_code,deal.PositionID());
         if(event!=NULL)
           {
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                        // Время события (Время закрытия позиции)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Причина события (из перечисления ENUM_EVENT_REASON)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Тип сделки события
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Тикет сделки события
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Тип ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_last.TypeOrder());              // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Тикет ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_last.Ticket());               // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Идентификатор позиции
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last.PositionByID());             // Идентификатор встречной позиции
            //---
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                        // Магический номер встречной позиции
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Тип ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Тикет ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Тип ордера текущей позиции
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Тикет ордера текущей позиции
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order_last.Symbol());                     // Символ встречной позиции
            //---
            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first.PriceOpen());            // Цена установки ордера до модификации
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first.StopLoss());               // Цена StopLoss до модификации
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first.TakeProfit());             // Цена TakeProfit до модификации
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                                  // Цена Ask в момент события
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                                  // Цена Bid в момент события
            //---
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Магический номер ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpenMSC());        // Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Цена, на которой произошло событие (Цена закрытия позиции)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Цена открытия ордера (Цена установки открывающего ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last.PriceClose());                  // Цена закрытия ордера  (Цена закрытия последнего ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // Цена StopLoss (Цена StopLoss ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // Цена TakeProfit (Цена TakeProfit ордера позиции)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last.Volume());                               // Запрашиваемый объём ордера
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order_last.Volume()-order_last.VolumeCurrent());   // Исполненный объём ордера
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order_last.VolumeCurrent());                        // Оставшийся (текущий) объём ордера
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                                  // Оставшийся (текущий) объём позиции
            //---
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Профит
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Символ ордера
            //--- Установка идентификатора графика управляющей программы и расшифровка кода события и установка типа события
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Если объекта-события нет в списке - добавляем
            if(!this.IsPresentEventInList(event))
              {
               this.m_list_events.InsertSort(event);
               //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
               delete event;
              }
           }
        }
     }
   //--- Встречная позиция
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT_BY)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
      int reason=EVENT_REASON_DONE_BY_POS;
      //--- Возьмём первый и закрывающий ордера позиции из списка всех ордеров позиции
      COrder* order_first=this.GetFirstOrderFromList(list_history,deal.PositionID());
      COrder* order_close=this.GetCloseByOrderFromList(list_history,deal.PositionID());
      //--- Получим открытую позицию по идентификатору
      COrder* position=this.GetPositionByID(list_market,order_first.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
      if(order_first!=NULL && order_close!=NULL)
        {
         //--- Добавляем флаг закрытия встречной
         this.m_trade_event_code+=TRADE_EVENT_FLAG_BY_POS;
         //--- Возьмём первый ордер закрывающей позиции
         CArrayObj* list_close_by=this.GetListAllOrdersByPosID(list_history,order_close.PositionByID());
         COrder* order_close_by=list_close_by.At(0);
         if(order_close_by==NULL)
            return;
         //--- Ищем все сделки закрытой позиции в направлении её открытия и закрытия, и считаем их общий объём
         double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
         double volume_out=this.SummaryVolumeDealsOutByPosID(list_history,deal.PositionID());//+order_close.Volume();
         //--- Рассчитываем текущий объём закрытой позиции
         int dgl=(int)DigitsLots(deal.Symbol());
         double volume_current=::NormalizeDouble(volume_in-volume_out,dgl);
         //--- Ищем все сделки встречной позиции в направлении её открытия и закрытия, и считаем их общий объём
         double volume_opp_in=this.SummaryVolumeDealsInByPosID(list_history,order_close.PositionByID());
         double volume_opp_out=this.SummaryVolumeDealsOutByPosID(list_history,order_close.PositionByID());
         //--- Рассчитываем текущий объём встречной позиции
         double volume_opp_current=::NormalizeDouble(volume_opp_in-volume_opp_out,dgl);
         //--- Если не весь объём закрытой позиции закрыт - значит частичное закрытие
         if(volume_current>0 || order_close.VolumeCurrent()>0)
           {
            //--- Добавляем флаг частичного закрытия
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            //--- Если встречная позиция закрыта частично - значит частичное закрытие частью объёма встречной позиции
            reason=(volume_opp_current>0 ? EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY : EVENT_REASON_DONE_PARTIALLY_BY_POS);
           }
         //--- Если закрыт весь объём позиции и есть частичное исполнение встречной - значит закрытие частью объёма встречной позиции
         else
           {
            if(volume_opp_current>0)
              {
               reason=EVENT_REASON_DONE_BY_POS_PARTIALLY;
              }
           }
         CEvent* event=new CEventPositionClose(this.m_trade_event_code,deal.PositionID());
         if(event!=NULL)
           {
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                        // Время события
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Причина события (из перечисления ENUM_EVENT_REASON)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Тип сделки события
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Тикет сделки события
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_close.TypeOrder());             // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_close.Ticket());              // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpenMSC());        // Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Тип ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Тикет ордера, на основании которого открыта сделка позиции (первый ордер позиции)
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Идентификатор позиции
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_close.PositionByID());            // Идентификатор встречной позиции
            //---
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order_close_by.Magic());                   // Магический номер встречной позиции
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Тип ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Тикет ордера позиции до смены направления
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Тип ордера текущей позиции
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Тикет ордера текущей позиции
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order_close_by.Symbol());                 // Символ встречной позиции
            //---
            event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first.PriceOpen());            // Цена установки ордера до модификации
            event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first.StopLoss());               // Цена StopLoss до модификации
            event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first.TakeProfit());             // Цена TakeProfit до модификации
            event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                                  // Цена Ask в момент события
            event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                                  // Цена Bid в момент события
            //---
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Магический номер ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Цена, на которой произошло событие
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Цена открытия ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,deal.PriceClose());                        // Цена закрытия ордера/сделки/позиции
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // Цена StopLoss (Цена StopLoss ордера позиции)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // Цена TakeProfit (Цена TakeProfit ордера позиции)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,::NormalizeDouble(volume_in,dgl));// Первоначальный объём
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,deal.Volume());                  // Закрытый объём
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,volume_current);                  // Оставшийся (текущий) объём
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                // Оставшийся (текущий) объём
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Профит
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Символ ордера
            //--- Установка идентификатора графика управляющей программы и расшифровка кода события и установка типа события
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Если объекта-события нет в списке - добавляем
            if(!this.IsPresentEventInList(event))
              {
               this.m_list_events.InsertSort(event);
               //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
               delete event;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Создаёт событие для неттингового счёта                           |
//+------------------------------------------------------------------+
void CEventsCollection::NewDealEventNetto(COrder *deal,CArrayObj *list_history,CArrayObj *list_market)
  {
   double ask=::SymbolInfoDouble(deal.Symbol(),SYMBOL_ASK);
   double bid=::SymbolInfoDouble(deal.Symbol(),SYMBOL_BID);
//--- Подготовка данных по истории позиции
//--- Списки всех сделок и изменений направления позиции
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list_history,deal.PositionID());
   CArrayObj* list_changes=this.GetListAllDealsInOutByPosID(list_history,deal.PositionID());
   if(list_deals==NULL || list_changes==NULL)
      return;
   list_deals.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   list_changes.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   if(!list_changes.InsertSort(list_deals.At(0)))
      return;
   
//--- Ордера первой и последней сделок позиции
   CArrayObj* list_tmp=this.GetListAllOrdersByPosID(list_history,deal.PositionID());
   COrder* order_first_deal=list_tmp.At(0);
   list_tmp=CSelect::ByOrderProperty(list_tmp,ORDER_PROP_TICKET,deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET),EQUAL);
   COrder* order_last_deal=list_tmp.At(list_tmp.Total()-1);
   if(order_first_deal==NULL || order_last_deal==NULL)
      return;
//--- Тип и тикеты ордеров первой и последней сделок позиции
   ENUM_ORDER_TYPE type_order_first_deal=(ENUM_ORDER_TYPE)order_first_deal.TypeOrder();
   ENUM_ORDER_TYPE type_order_last_deal=(ENUM_ORDER_TYPE)order_last_deal.TypeOrder();
   ulong ticket_order_first_deal=order_first_deal.Ticket();
   ulong ticket_order_last_deal=order_last_deal.Ticket();
   
//--- Текущая и прошлая позиции
   COrder* position_current=list_changes.At(list_changes.Total()-1);
   COrder* position_previous=(list_changes.Total()>1 ? list_changes.At(list_changes.Total()-2) : position_current);
   if(position_current==NULL || position_previous==NULL)
      return;
   ENUM_ORDER_TYPE type_position_current=(ENUM_ORDER_TYPE)position_current.TypeOrder();
   ulong ticket_position_current=position_current.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);
   ENUM_ORDER_TYPE type_position_previous=(ENUM_ORDER_TYPE)position_previous.TypeOrder();
   ulong ticket_position_previous=position_previous.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);

//--- Получим открытую позицию по тикету и запишем её объём
   COrder* position=this.GetPositionByID(list_market,deal.PositionID());
   double vol_position=(position!=NULL ? position.Volume() : 0);
//--- Исполненный объём ордера
   double vol_order_done=order_last_deal.Volume()-order_last_deal.VolumeCurrent();
//--- Оставшийся (неисполненный) объём ордера
   double vol_order_current=order_last_deal.VolumeCurrent();

//--- Вход в рынок
   if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
      int num_deals=list_deals.Total();
      int reason=(num_deals>1 ? EVENT_REASON_VOLUME_ADD : EVENT_REASON_DONE);
      //--- Если это не первая сделка в позиции, добавляем флаг изменения позиции
      if(num_deals>1)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_POSITION_CHANGED;
        }
      //--- Если не весь объём ордера открыт - значит частичное исполнение
      if(order_last_deal.VolumeCurrent()>0)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
         //--- Если это не первая сделка позиции - значит добавление объёма частичным исполнением, иначе - частичное открытие
         reason=(num_deals>1 ? EVENT_REASON_VOLUME_ADD_PARTIALLY : EVENT_REASON_DONE_PARTIALLY);
        }
      //--- Если открывающий ордер - отложенный, значит - активирован отложенный ордер
      if(order_last_deal.TypeOrder()>ORDER_TYPE_SELL && order_last_deal.TypeOrder()<ORDER_TYPE_CLOSE_BY)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
         //--- Если это не первая сделка позиции
         if(num_deals>1)
           {
            //--- Если ордер исполнен частично, ставим в причину события добавление объёма к позиции частичным исполнением отложенного ордера
            //--- иначе - добавление объёма к позиции исполнением отложенного ордера
            reason=
              (order_last_deal.VolumeCurrent()>0 ? 
               EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY  : 
               EVENT_REASON_VOLUME_ADD_BY_PENDING
              );
           }
         //--- Если это новая позиция
         else
           {
            //--- Если ордер исполнен частично, ставим в причину события частичноем исполнение отложенного ордера,
            //--- иначе - открытие позиции активацией отложенного ордера
            reason=
              (order_last_deal.VolumeCurrent()>0 ? 
               EVENT_REASON_ACTIVATED_PENDING_PARTIALLY  : 
               EVENT_REASON_ACTIVATED_PENDING
              );
           }
        }
      CEvent* event=new CEventPositionOpen(this.m_trade_event_code,deal.PositionID());
      if(event!=NULL)
        {
         //--- Параметры сделки события
         event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                     // Время события (Время открытия позиции)
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                               // Причина события (из перечисления ENUM_EVENT_REASON)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                  // Тип сделки события
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                   // Тикет сделки события
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                          // Магический номер ордера/сделки/позиции
         event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                      // Цена, на которой произошло событие (Цена открытия позиции)
         event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                          // Профит
         event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                              // Символ ордера
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                        // Символ встречной позиции
         event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                     // Идентификатор позиции
         
         //--- Параметры ордера события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);             // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);         // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());     // Идентификатор встречной позиции
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());          // Цена закрытия ордера (Цена закрытия последнего ордера позиции)
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());     // Запрашиваемый объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);              // Исполненный объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);            // Оставшийся (неисполненный) объём ордера
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                     // Магический номер встречной позиции
            
         //--- Параметры позиции
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);         // Тип ордера, на основании которого открыта первая сделка позиции
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);     // Тикет ордера, на основании которого открыта первая сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpenMSC());// Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());           // Цена открытия первого ордера позиции
         event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());              // Цена StopLoss (Цена StopLoss ордера позиции)
         event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());            // Цена TakeProfit (Цена TakeProfit ордера позиции)
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);        // Тип позиции до смены направления
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous);    // Тикет ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);        // Тип ордера текущей позиции
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current);    // Тикет ордера текущей позиции
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);             // Исполненный объём позиции

         event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first_deal.PriceOpen());    // Цена установки ордера до модификации
         event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first_deal.StopLoss());       // Цена StopLoss до модификации
         event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first_deal.TakeProfit());     // Цена TakeProfit до модификации
         event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                               // Цена Ask в момент события
         event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                               // Цена Bid в момент события
         
         //--- Установка идентификатора графика управляющей программы и расшифровка кода события, установка типа события
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Если объекта-события нет в списке - добавляем
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
            delete event;
           }
        }
     }
//--- Разворот позиции
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_INOUT)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED+TRADE_EVENT_FLAG_POSITION_CHANGED+TRADE_EVENT_FLAG_POSITION_REVERSE;
      int reason=EVENT_REASON_REVERSE;
      //--- Если не весь объём ордера открыт - значит частичное исполнение
      if(order_last_deal.VolumeCurrent()>0)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
         reason=EVENT_REASON_REVERSE_PARTIALLY;
        }
      //--- Если открывающий ордер - отложенный, значит - активирован отложенный ордер
      if(order_last_deal.TypeOrder()>ORDER_TYPE_SELL && order_last_deal.TypeOrder()<ORDER_TYPE_CLOSE_BY)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
         //--- Если ордер исполнен частично, ставим в причину события разворот позиции частичным исполнением отложенного ордера
         reason=
           (order_last_deal.VolumeCurrent()>0 ? 
            EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY  : 
            EVENT_REASON_REVERSE_BY_PENDING
           );
        }
      CEvent* event=new CEventPositionOpen(this.m_trade_event_code,deal.PositionID());
      if(event!=NULL)
        {
         //--- Параметры сделки события
         event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                     // Время события (Время открытия позиции)
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                               // Причина события (из перечисления ENUM_EVENT_REASON)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                  // Тип сделки события
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                   // Тикет сделки события
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                          // Магический номер ордера/сделки/позиции
         event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                      // Цена, на которой произошло событие (Цена открытия позиции)
         event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                          // Профит
         event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                              // Символ ордера
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                        // Символ встречной позиции
         event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                     // Идентификатор позиции
            
         //--- Параметры ордера события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);             // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);         // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());     // Идентификатор встречной позиции
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());          // Цена закрытия ордера (Цена закрытия последнего ордера позиции)
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());     // Запрашиваемый объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);              // Исполненный объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);            // Оставшийся (неисполненный) объём ордера
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                     // Магический номер встречной позиции
            
         //--- Параметры позиции
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);         // Тип ордера, на основании которого открыта первая сделка позиции
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);     // Тикет ордера, на основании которого открыта первая сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpenMSC());// Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());           // Цена открытия первого ордера позиции
         event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());              // Цена StopLoss (Цена StopLoss ордера позиции)
         event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());            // Цена TakeProfit (Цена TakeProfit ордера позиции)
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);        // Тип ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous);    // Тикет ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);        // Тип ордера текущей позиции
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current);    // Тикет ордера текущей позиции
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);             // Исполненный объём позиции

         event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first_deal.PriceOpen());    // Цена установки ордера до модификации
         event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first_deal.StopLoss());       // Цена StopLoss до модификации
         event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first_deal.TakeProfit());     // Цена TakeProfit до модификации
         event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                               // Цена Ask в момент события
         event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                               // Цена Bid в момент события
         
         //--- Установка идентификатора графика управляющей программы и расшифровка кода события, установка типа события
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Если объекта-события нет в списке - добавляем
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
            delete event;
           }
        }
     }
//--- Выход из рынка
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
      int reason=EVENT_REASON_DONE;
      //--- Если позиция с идентификатором ещё в рынке - значит частичное исполнение
      if(this.GetPositionByID(list_market,deal.PositionID())!=NULL)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
        }
      //--- Если закрывающий ордер исполнен частично, ставим в причину события частичное исполнение закрывающего ордера
      if(order_last_deal.VolumeCurrent()>0)
        {
         reason=EVENT_REASON_DONE_PARTIALLY;
        }
      //--- Если у закрывающего ордера позиции выставлен флаг закрытия по StopLoss - значит закрытие по StopLoss
      //--- Если StopLoss-ордер исполнен частично, ставим в причину события частичное исполнение ордера StopLoss
      if(order_last_deal.IsCloseByStopLoss())
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
         reason=(order_last_deal.VolumeCurrent()>0 ? EVENT_REASON_DONE_SL_PARTIALLY : EVENT_REASON_DONE_SL);
        }
      //--- Если у закрывающего ордера позиции выставлен флаг закрытия по TakeProfit - значит закрытие по TakeProfit
      //--- Если TakeProfit-ордер исполнен частично, ставим в причину события частичное исполнение ордера TakeProfit
      else if(order_last_deal.IsCloseByTakeProfit())
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
         reason=(order_last_deal.VolumeCurrent()>0 ? EVENT_REASON_DONE_TP_PARTIALLY : EVENT_REASON_DONE_TP);
        }
      //---
      CEvent* event=new CEventPositionClose(this.m_trade_event_code,deal.PositionID());
      if(event!=NULL)
        {
         //--- Параметры сделки события
         event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                     // Время события (Время открытия позиции)
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                               // Причина события (из перечисления ENUM_EVENT_REASON)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                  // Тип сделки события
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                   // Тикет сделки события
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                          // Магический номер ордера/сделки/позиции
         event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                      // Цена, на которой произошло событие (Цена открытия позиции)
         event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                          // Профит
         event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                              // Символ ордера
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                        // Символ встречной позиции
         event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                     // Идентификатор позиции
         
         //--- Параметры ордера события
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);             // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);         // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());     // Идентификатор встречной позиции
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());          // Цена закрытия ордера (Цена закрытия последнего ордера позиции)
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());     // Запрашиваемый объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);              // Исполненный объём ордера
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);            // Оставшийся (неисполненный) объём ордера
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                     // Магический номер встречной позиции
            
         //--- Параметры позиции
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);         // Тип ордера, на основании которого открыта первая сделка позиции
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);     // Тикет ордера, на основании которого открыта первая сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpenMSC());// Время ордера, на основании которого открыта сделка позиции (первый ордер позиции)
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());           // Цена открытия первого ордера позиции
         event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());              // Цена StopLoss (Цена StopLoss ордера позиции)
         event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());            // Цена TakeProfit (Цена TakeProfit ордера позиции)
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);        // Тип ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous);    // Тикет ордера позиции до смены направления
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);        // Тип ордера текущей позиции
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current);    // Тикет ордера текущей позиции
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);             // Исполненный объём позиции

         event.SetProperty(EVENT_PROP_PRICE_OPEN_BEFORE,order_first_deal.PriceOpen());    // Цена установки ордера до модификации
         event.SetProperty(EVENT_PROP_PRICE_SL_BEFORE,order_first_deal.StopLoss());       // Цена StopLoss до модификации
         event.SetProperty(EVENT_PROP_PRICE_TP_BEFORE,order_first_deal.TakeProfit());     // Цена TakeProfit до модификации
         event.SetProperty(EVENT_PROP_PRICE_EVENT_ASK,ask);                               // Цена Ask в момент события
         event.SetProperty(EVENT_PROP_PRICE_EVENT_BID,bid);                               // Цена Bid в момент события
         
         //--- Установка идентификатора графика управляющей программы и расшифровка кода события, установка типа события
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Если объекта-события нет в списке - добавляем
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Отправляем сообщение о событии и устанавливаем значение последнего торгового события
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- Если это событие уже есть в списке - удаляем новый объект-событие и выводим отладочное сообщение
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event is already in the list."));
            delete event;
           }
        }
     }
  }  
//+------------------------------------------------------------------+
//| Выбирает события из коллекции со временем                        |
//| в диапазоне от begin_time, до end_time                           |
//+------------------------------------------------------------------+
CArrayObj *CEventsCollection::GetListByTime(const datetime begin_time=0,const datetime end_time=0)
  {
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
   this.m_event_instance.SetProperty(EVENT_PROP_TIME_EVENT,begin);
   int index_begin=this.m_list_events.SearchGreatOrEqual(&m_event_instance);
   if(index_begin==WRONG_VALUE)
      return list;
   this.m_event_instance.SetProperty(EVENT_PROP_TIME_EVENT,end);
   int index_end=this.m_list_events.SearchLessOrEqual(&m_event_instance);
   if(index_end==WRONG_VALUE)
      return list;
   for(int i=index_begin; i<=index_end; i++)
      list.Add(this.m_list_events.At(i));
   return list;
  }
//+------------------------------------------------------------------+
//| Выбирает из списка только рыночные отложенные ордера             |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListMarketPendings(CArrayObj* list)
  {
   if(list.Type()!=COLLECTION_MARKET_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком рыночной коллекции","Error. The list is not a list of the market collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_PENDING,EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//| Выбирает из списка только удалённые отложенные ордера            |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListHistoryPendings(CArrayObj* list)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_HISTORY_PENDING,EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//| Выбирает из списка только сделки                                 |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListDeals(CArrayObj* list)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_deals=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//|  Возвращает список всех закрывающих ордеров CloseBy из списка    |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListCloseByOrders(CArrayObj *list)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,ORDER_TYPE_CLOSE_BY,EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//|  Возвращает список всех ордеров позиции по её идентификатору     |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllOrdersByPosID(CArrayObj* list,const ulong position_id)
  {
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,NO_EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//| Возвращает список всех сделок позиции по её идентификатору       |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_deals=CSelect::ByOrderProperty(list,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Возвращает список всех сделок на вход в рынок (IN)               |
//| по идентификатору позиции                                        |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsInByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list,position_id);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_DEAL_ENTRY,DEAL_ENTRY_IN,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Возвращает список всех сделок на выход из рынка (OUT)            |
//| по идентификатору позиции                                        |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsOutByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list,position_id);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_DEAL_ENTRY,DEAL_ENTRY_OUT,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Возвращает список всех сделок на разворот (IN_OUT)               |
//| по идентификатору позиции                                        |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsInOutByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list,position_id);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_DEAL_ENTRY,DEAL_ENTRY_INOUT,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Возвращает суммарный объём всех сделок IN позиции                |
//| по её идентификатору                                             |
//+------------------------------------------------------------------+
double CEventsCollection::SummaryVolumeDealsInByPosID(CArrayObj *list,const ulong position_id)
  {
   double vol=0.0;
   CArrayObj* list_in=this.GetListAllDealsInByPosID(list,position_id);
   if(list_in==NULL)
      return 0;
   for(int i=0;i<list_in.Total();i++)
     {
      COrder* deal=list_in.At(i);
      if(deal==NULL)
         continue;
      vol+=deal.Volume();
     }
   return vol;
  }
//+------------------------------------------------------------------+
//| Возвращает суммарный объём всех сделок OUT позиции по её         |
//| идентификатору (учитывается участие во встречных закрытиях)      |
//+------------------------------------------------------------------+
double CEventsCollection::SummaryVolumeDealsOutByPosID(CArrayObj *list,const ulong position_id)
  {
   double vol=0.0;
   CArrayObj* list_out=this.GetListAllDealsOutByPosID(list,position_id);
   if(list_out!=NULL)
     {
      for(int i=0;i<list_out.Total();i++)
        {
         COrder* deal=list_out.At(i);
         if(deal==NULL)
            continue;
         vol+=deal.Volume();
        }
     }
   CArrayObj* list_by=this.GetListCloseByOrders(list);
   if(list_by!=NULL)
     {
      for(int i=0;i<list_by.Total();i++)
        {
         COrder* order=list_by.At(i);
         if(order==NULL)
            continue;
         if(order.PositionID()==position_id || order.PositionByID()==position_id)
           {
            vol+=order.Volume();
           }
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//| Возвращает первый ордер из списка всех ордеров позиции           |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetFirstOrderFromList(CArrayObj* list,const ulong position_id)
  {
   CArrayObj* list_orders=this.GetListAllOrdersByPosID(list,position_id);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   list_orders.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list_orders.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Возвращает последний ордер из списка всех ордеров позиции        |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetLastOrderFromList(CArrayObj* list,const ulong position_id)
  {
   CArrayObj* list_orders=this.GetListAllOrdersByPosID(list,position_id);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   list_orders.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list_orders.At(list_orders.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Возвращает последний закрывающий ордер                           |
//| из списка всех ордеров позиции                                   |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetCloseByOrderFromList(CArrayObj *list,const ulong position_id)
  {
   CArrayObj* list_orders=this.GetListAllOrdersByPosID(list,position_id);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_TYPE,ORDER_TYPE_CLOSE_BY,EQUAL);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   list_orders.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list_orders.At(list_orders.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Возвращает ордер по тикету                                       |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetHistoryOrderByTicket(CArrayObj *list,const ulong order_ticket)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of the history collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,NO_EQUAL);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_TICKET,order_ticket,EQUAL);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   COrder* order=list_orders.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Возвращает позицию по идентификатору                             |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetPositionByID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_MARKET_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком рыночной коллекции","Error. The list is not a list of the market collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_POSITION,EQUAL);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   COrder* order=list_orders.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Возвращает флаг наличия объекта-события в списке событий         |
//+------------------------------------------------------------------+
bool CEventsCollection::IsPresentEventInList(CEvent *compared_event)
  {
   int total=this.m_list_events.Total();
   if(total==0)
      return false;
   for(int i=total-1;i>=0;i--)
     {
      CEvent* event=this.m_list_events.At(i);
      if(event==NULL)
         continue;
      if(event.IsEqual(compared_event))
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
