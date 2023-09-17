//--- Связь с основным файлом эксперта
#include "..\MultiSymbolPendingOrders.mq5"
//--- Подключаем свои библиотеки
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "Errors.mqh"
#include "TradeSignals.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//--- Свойства позиции
struct position_properties
  {
   uint              total_deals;      // Количество сделок
   bool              exists;           // Признак наличия/отсутствия открытой позиции
   string            symbol;           // Символ
   long              magic;            // Магический номер
   string            comment;          // Комментарий
   double            swap;             // Своп
   double            commission;       // Комиссия   
   double            first_deal_price; // Цена первой сделки позиции
   double            price;            // Текущая цена позиции
   double            current_price;    // Текущая цена символа позиции      
   double            last_deal_price;  // Цена последней сделки позиции
   double            profit;           // Прибыль/убыток позиции
   double            volume;           // Текущий объём позиции
   double            initial_volume;   // Начальный объём позиции
   double            sl;               // Stop Loss позиции
   double            tp;               // Take Profit позиции
   datetime          time;             // Время открытия позиции
   ulong             duration;         // Длительность позиции в секундах
   long              id;               // Идентификатор позиции
   ENUM_POSITION_TYPE type;             // Tип позиции
  };
//--- Свойства отложенного ордера
struct pending_order_properties
  {
   string            symbol;          // Символ
   long              magic;           // Магический номер
   string            comment;         // Комментарий
   double            price_open;      // Цена, указанная в ордере
   double            price_current;   // Текущая цена по символу ордера
   double            price_stoplimit; // Цена постановки Limit ордера при срабатывании StopLimit ордера
   double            volume_initial;  // Первоначальный объем при постановке ордера
   double            volume_current;  // Невыполненный объём
   double            sl;              // Уровень Stop Loss
   double            tp;              // Уровень Take Profit
   datetime          time_setup;      // Время постановки ордера
   datetime          time_expiration; // Время истечения ордера
   datetime          time_setup_msc;  // Время установки ордера на исполнение в миллисекундах с 01.01.1970
   datetime          type_time;       // Время жизни ордера
   ENUM_ORDER_TYPE   type;            // Tип позиции
  };
//--- Свойства сделок в истории
struct history_deal_properties
  {
   string            symbol;     // Символ
   string            comment;    // Комментарий
   ENUM_DEAL_TYPE    type;       // Тип сделки
   uint              entry;      // Направление
   double            price;      // Цена
   double            profit;     // Прибыль/убыток
   double            volume;     // Объём
   double            swap;       // Своп
   double            commission; // Комиссия
   datetime          time;       // Время
  };
//--- Свойства символа
struct symbol_properties
  {
   int               digits;           // Количество знаков в цене после запятой
   int               spread;           // Размер спреда в пунктах
   int               stops_level;      // Ограничитель установки Stop ордеров
   double            point;            // Значение одного пункта
   double            ask;              // Цена ask
   double            bid;              // Цена bid
   double            volume_min;       // Минимальный объем для заключения сделки
   double            volume_max;       // Максимальный объем для заключения сделки
   double            volume_limit;     // Максимально допустимый объем для позиции и ордеров в одном направлении
   double            volume_step;      // Минимальный шаг изменения объема для заключения сделки
   double            offset;           // Отступ от максимально возможной цены для операции
   double            up_level;         // Цена верхнего уровня stop level
   double            down_level;       // Цена нижнего уровня stop level
   ENUM_SYMBOL_TRADE_EXECUTION execution_mode; // Режим заключения сделок
  };
//--- переменные свойств позиции, ордера, сделки и символа
position_properties      pos;
pending_order_properties ord;
history_deal_properties  deal;
symbol_properties        symb;
//+------------------------------------------------------------------+
//| Торговый блок                                                    |
//+------------------------------------------------------------------+
void TradingBlock(int symbol_number)
  {
   double          tp=0.0;                 // Take Profit
   double          sl=0.0;                 // Stop Loss
   double          lot=0.0;                // Объем для расчета позиции в случае переворота позиции
   double          order_price=0.0;        // Цена для установки ордера
   ENUM_ORDER_TYPE order_type=WRONG_VALUE; // Тип ордера для открытия позиции
//--- Если вне временного диапазона
//    для установки отложенных ордеров
   if(!CheckTimeOpenOrders(symbol_number))
      return;
//--- Узнаем, есть ли позиция
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- Если позиции нет
   if(!pos.exists)
     {
      //--- Получим свойства символа
      GetSymbolProperties(symbol_number,S_ALL);
      //--- Скорректируем объём
      lot=CalculateLot(symbol_number,Lot[symbol_number]);
      //--- Если нет верхнего отложенного ордера
      if(!CheckExistPendingOrderByComment(symbol_number,comment_top_order))
        {
         //--- Получим цену для установки отложенного ордера
         order_price=CalculatePendingOrder(symbol_number,ORDER_TYPE_BUY_STOP);
         //--- Получим уровни Take Profit и Stop Loss
         sl=CalculateOrderStopLoss(symbol_number,ORDER_TYPE_BUY_STOP,order_price);
         tp=CalculateOrderTakeProfit(symbol_number,ORDER_TYPE_BUY_STOP,order_price);
         //--- Установим отложенный ордер
         SetPendingOrder(symbol_number,ORDER_TYPE_BUY_STOP,lot,0,order_price,sl,tp,ORDER_TIME_GTC,comment_top_order);
        }
      //--- Если нет нижнего отложенного ордера
      if(!CheckExistPendingOrderByComment(symbol_number,comment_bottom_order))
        {
         //--- Получим цену для установки отложенного ордера
         order_price=CalculatePendingOrder(symbol_number,ORDER_TYPE_SELL_STOP);
         //--- Получим уровни Take Profit и Stop Loss
         sl=CalculateOrderStopLoss(symbol_number,ORDER_TYPE_SELL_STOP,order_price);
         tp=CalculateOrderTakeProfit(symbol_number,ORDER_TYPE_SELL_STOP,order_price);
         //--- Установим отложенный ордер
         SetPendingOrder(symbol_number,ORDER_TYPE_SELL_STOP,lot,0,order_price,sl,tp,ORDER_TIME_GTC,comment_bottom_order);
        }
     }
  }
//+------------------------------------------------------------------+
//| Открывает позицию                                                |
//+------------------------------------------------------------------+
void OpenPosition(int             symbol_number, // Номер символа
                  ENUM_ORDER_TYPE order_type,    // Тип ордера
                  double          lot,           // Объём
                  double          price,         // Цена
                  double          sl,            // Стоп Лосс
                  double          tp,            // Тейк Профит
                  string          comment)       // Комментарий
  {
//--- Установим номер мэджика в торговую структуру
   trade.SetExpertMagicNumber(MagicNumber);
//--- Установим размер проскальзывания в пунктах
   trade.SetDeviationInPoints(CorrectValueBySymbolDigits(Deviation));
//--- Режим Instant Execution и Market Execution
//    *** Начиная с 803 билда, уровни Stop Loss и Take Profit                             ***
//    *** можно устанавливать при открытии позиции в режиме SYMBOL_TRADE_EXECUTION_MARKET ***
   if(symb.execution_mode==SYMBOL_TRADE_EXECUTION_INSTANT ||
      symb.execution_mode==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      //--- Если позиция не открылась, вывести сообщение об этом
      if(!trade.PositionOpen(Symbols[symbol_number],order_type,lot,price,sl,tp,comment))
         Print("Ошибка при открытии позиции: ",GetLastError()," - ",ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| Закрывает позицию                                                |
//+------------------------------------------------------------------+
void ClosePosition(int symbol_number)
  {
//--- Узнаем, есть ли позиция  
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- Если позиции нет, выходим
   if(!pos.exists)
      return;
//--- Установим размер проскальзывания в пунктах
   trade.SetDeviationInPoints(CorrectValueBySymbolDigits(Deviation));
//--- Если позиция не закрылась, вывести сообщение об этом
   if(!trade.PositionClose(Symbols[symbol_number]))
      Print("Ошибка при закрытии позиции: ",GetLastError()," - ",ErrorDescription(GetLastError()));
  }
//+------------------------------------------------------------------+
//| Устанавливает отложенный ордер                                   |
//+------------------------------------------------------------------+
void SetPendingOrder(int                  symbol_number,   // Номер символа
                     ENUM_ORDER_TYPE      order_type,      // Тип ордера
                     double               lot,             // Объём
                     double               price_stoplimit, // Уровень StopLimit ордера
                     double               price,           // Цена
                     double               sl,              // Стоп Лосс
                     double               tp,              // Тейк Профит
                     ENUM_ORDER_TYPE_TIME type_time,       // Срок действия ордера
                     string               comment)         // Комментарий
  {
//--- Установим номер мэджика в торговую структуру
   trade.SetExpertMagicNumber(MagicNumber);
//--- Если отложенный ордер установить не удалось, вывести сообщение об этом
   if(!trade.OrderOpen(Symbols[symbol_number],
      order_type,lot,price_stoplimit,price,sl,tp,type_time,0,comment))
      Print("Ошибка при установке отложенного ордера: ",GetLastError()," - ",ErrorDescription(GetLastError()));
  }
//+------------------------------------------------------------------+
//| Изменяет отложенный ордер                                        |
//+------------------------------------------------------------------+
void ModifyPendingOrder(int                  symbol_number,   // Номер символа
                        ulong                ticket,          // Тикет ордера
                        ENUM_ORDER_TYPE      type,            // Тип ордера
                        double               price,           // Цена ордера
                        double               sl,              // Стоп Лосс ордера
                        double               tp,              // Тэйк Профит ордера
                        ENUM_ORDER_TYPE_TIME type_time,       // Срок действия ордера
                        datetime             time_expiration, // Время истечения ордера
                        double               price_stoplimit, // Цена
                        string               comment,         // Комментарий
                        double               volume)          // Объём
  {
//--- Если передан не нулевой объём, переустановим ордер
   if(volume>0)
     {
      //--- Если не удалось удалить ордер, выйдем
      if(!DeletePendingOrder(ticket))
         return;
      //--- Установим отложенный ордер
      SetPendingOrder(symbol_number,type,volume,0,price,sl,tp,type_time,comment);
      //--- Скорректируем Stop Loss позиции относительно ордера
      CorrectStopLossByOrder(symbol_number,price,type);
     }
//--- Если передан нулевой объём, модифицируем ордер
   else
     {
      //--- Если отложенный ордер изменить не удалось, вывести сообщение об этом
      if(!trade.OrderModify(ticket,price,sl,tp,type_time,time_expiration,price_stoplimit))
         Print("Ошибка при изменении цены отложенного ордера: ",
               GetLastError()," - ",ErrorDescription(GetLastError()));
      //--- Иначе скорректируем Stop Loss позиции относительно ордера
      else
         CorrectStopLossByOrder(symbol_number,price,type);
     }
  }
//+------------------------------------------------------------------+
//| Удаляет отложенный ордер                                         |
//+------------------------------------------------------------------+
bool DeletePendingOrder(ulong ticket)
  {
//--- Если отложенный ордер удалить не удалось, вывести сообщение об этом
   if(!trade.OrderDelete(ticket))
     {
      Print("Ошибка при удалении отложенного ордера: ",GetLastError()," - ",ErrorDescription(GetLastError()));
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Корректирует Stop Loss позиции относительно отложенного ордера   |
//+------------------------------------------------------------------+
void CorrectStopLossByOrder(int             symbol_number, // Номер символа
                            double          price,         // Цена ордера
                            ENUM_ORDER_TYPE type)          // Тип ордера
  {
//--- Если Stop Loss отключен, выйдем
   if(StopLoss[symbol_number]==0)
      return;
//--- Если Stop Loss включен
   double new_sl=0.0; // Новое значение для Stop Loss
//--- Получим значение одного пункта и
   GetSymbolProperties(symbol_number,S_POINT);
//--- Количество знаков в цене после запятой
   GetSymbolProperties(symbol_number,S_DIGITS);
//--- Получим Take Profit позиции
   GetPositionProperties(symbol_number,P_TP);
//--- Рассчитаем относительно типа ордера
   switch(type)
     {
      case ORDER_TYPE_BUY_STOP  :
         new_sl=NormalizeDouble(price+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         break;
      case ORDER_TYPE_SELL_STOP :
         new_sl=NormalizeDouble(price-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         break;
     }
//--- Модифицируем позицию
   if(!trade.PositionModify(Symbols[symbol_number],new_sl,pos.tp))
      Print("Ошибка при модификации позиции: ",GetLastError()," - ",ErrorDescription(GetLastError()));
  }
//+------------------------------------------------------------------+
//| Проверяет существование отложенного ордера по комментарию        |
//+------------------------------------------------------------------+
bool CheckExistPendingOrderByComment(int symbol_number,string comment)
  {
   int    total_orders  =0;  // Общее количество отложенных ордеров
   string symbol_order  =""; // Символ ордера
   string comment_order =""; // Комментарий ордера
//--- Получим количество отложенных ордеров
   total_orders=OrdersTotal();
//--- Пройдёмся в цикле по всем ордерам
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- Выберем ордер по тикету
      if(OrderGetTicket(i)>0)
        {
         //--- Получим имя символа
         symbol_order=OrderGetString(ORDER_SYMBOL);
         //--- Если символы равны
         if(symbol_order==Symbols[symbol_number])
           {
            //--- Получим комментарий ордера
            comment_order=OrderGetString(ORDER_COMMENT);
            //--- Если комментарии совпадают
            if(comment_order==comment)
               return(true);
           }
        }
     }
//--- Ордер с указанным комментарием не найден
   return(false);
  }
//+------------------------------------------------------------------+
//| Управление отложенными ордерами                                  |
//+------------------------------------------------------------------+
void ManagementPendingOrders()
  {
//--- Пройдёмся в цикле по всем символам
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- Если торговля по этому символу не разрешена,
      //    перейдём к следующему
      if(Symbols[s]=="")
         continue;
      //--- Узнаем, есть ли позиция
      pos.exists=PositionSelect(Symbols[s]);
      //--- Если позиции нет
      if(!pos.exists)
        {
         //--- Если последняя сделка новая и
         //    выход из позиции был по Take Profit или Stop Loss
         if(GetEventLastDealTicket(s) && 
            (GetEventStopLoss(s) || GetEventTakeProfit(s)))
            //--- Удалим все отложенные ордера на символе
            DeleteAllPendingOrders(s);
         //--- Перейдём к следующему символу
         continue;
        }
      //--- Если позиция есть
      ulong           order_ticket           =0;           // Тикет ордера
      int             total_orders           =0;           // Общее количество отложенных ордеров
      int             symbol_total_orders    =0;           // Количество отложенных ордеров на указанном символе
      string          opposite_order_comment ="";          // Комментарий противоположного ордера
      ENUM_ORDER_TYPE opposite_order_type    =WRONG_VALUE; // Тип ордера
      //--- Получим общее количество отложенных ордеров
      total_orders=OrdersTotal();
      //--- Получим количество отложенных ордеров на указанном символе
      symbol_total_orders=OrdersTotalBySymbol(Symbols[s]);
      //--- Получим свойства символа
      GetSymbolProperties(s,S_ASK);
      GetSymbolProperties(s,S_BID);
      //--- Получим комментарий выбранной позиции
      GetPositionProperties(s,P_COMMENT);
      //--- Если комментарий позиции от верхнего ордера,
      //    значит нужно удалить/изменить/установить нижний ордер
      if(pos.comment==comment_top_order)
        {
         opposite_order_type    =ORDER_TYPE_SELL_STOP;
         opposite_order_comment =comment_bottom_order;
        }
      //--- Если комментарий позиции от нижнего ордера,
      //    значит нужно удалить/изменить/установить верхний ордер
      if(pos.comment==comment_bottom_order)
        {
         opposite_order_type    =ORDER_TYPE_BUY_STOP;
         opposite_order_comment =comment_top_order;
        }
      //--- Если отложенных ордеров на этом символе нет
      if(symbol_total_orders==0)
        {
         //--- Если переворот позиции включен, установим противоположный ордер
         if(Reverse[s])
           {
            double tp=0.0;          // Take Profit
            double sl=0.0;          // Stop Loss
            double lot=0.0;         // Объем для расчета позиции в случае переворота позиции
            double order_price=0.0; // Цена для установки ордера
            //--- Получим цену для установки отложенного ордера
            order_price=CalculatePendingOrder(s,opposite_order_type);
            //--- Получим уровни Take Profit и Stop Loss
            sl=CalculateOrderStopLoss(s,opposite_order_type,order_price);
            tp=CalculateOrderTakeProfit(s,opposite_order_type,order_price);
            //--- Посчитаем двойной объём
            lot=CalculateLot(s,pos.volume*2);
            //--- Установим отложенный ордер
            SetPendingOrder(s,opposite_order_type,lot,0,order_price,sl,tp,ORDER_TIME_GTC,opposite_order_comment);
            //--- Скорректируем Stop Loss относительно ордера
            CorrectStopLossByOrder(s,order_price,opposite_order_type);
           }
         return;
        }
      //--- Если отложенные ордера на этом символе есть, то
      //    в зависимости от условий удалим или
      //    модифицируем противоположный отложенный ордер
      if(symbol_total_orders>0)
        {
         //--- Пройдёмся в цикле по всем ордерам от последнего к первому
         for(int i=total_orders-1; i>=0; i--)
           {
            //--- Если ордер выбран
            if((order_ticket=OrderGetTicket(i))>0)
              {
               //--- Получим символ ордера
               GetOrderProperties(O_SYMBOL);
               //--- Получим комментарий ордера
               GetOrderProperties(O_COMMENT);
               //--- Если символ ордера и позиции совпадают и
               //    комментарий противоположного ордера, то
               if(ord.symbol==Symbols[s] && 
                  ord.comment==opposite_order_comment)
                 {
                  //--- Если переворот позиции отключен
                  if(!Reverse[s])
                     //--- Удалим ордер
                     DeletePendingOrder(order_ticket);
                  //--- Если переворот позиции включен
                  else
                    {
                     double lot=0.0;
                     //--- Получим свойства текущего ордера
                     GetOrderProperties(O_ALL);
                     //--- Получим объём текущей позиции
                     GetPositionProperties(s,P_VOLUME);
                     //--- Если ордер уже был изменён, выйдем из цикла
                     if(ord.volume_initial>pos.volume)
                        break;
                     //--- Посчитаем двойной объём
                     lot=CalculateLot(s,pos.volume*2);
                     //--- Изменить (переустановить) ордер
                     ModifyPendingOrder(s,order_ticket,opposite_order_type,
                                        ord.price_open,ord.sl,ord.tp,
                                        ORDER_TIME_GTC,ord.time_expiration,
                                        ord.price_stoplimit,opposite_order_comment,lot);
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Удаляет все отложенные ордера                                    |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders(int symbol_number)
  {
   int   total_orders =0; // Количество отложенных ордеров
   ulong order_ticket =0; // Тикет ордера
//--- Получим количество отложенных ордеров
   total_orders=OrdersTotal();
//--- Пройдёмся в цикле по всем ордерам
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- Если ордер выбран
      if((order_ticket=OrderGetTicket(i))>0)
        {
         //--- Получим символ ордера
         GetOrderProperties(O_SYMBOL);
         //--- Если символ ордера и текущий символ совпадают
         if(ord.symbol==Symbols[symbol_number])
            //--- Удалим ордер
            DeletePendingOrder(order_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//| Возвращает количество ордеров на указанном символе               |
//+------------------------------------------------------------------+
int OrdersTotalBySymbol(string symbol)
  {
   int   count        =0; // Счётчик ордеров
   int   total_orders =0; // Количество отложенных ордеров
//--- Получим количество отложенных ордеров
   total_orders=OrdersTotal();
//--- Пройдёмся в цикле по всем ордерам
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- Если ордер выбран
      if(OrderGetTicket(i)>0)
        {
         //--- Получим символ ордера
         GetOrderProperties(O_SYMBOL);
         //--- Если символ ордера и указанный символ совпадают
         if(ord.symbol==symbol)
            //--- Увеличим счётчик
            count++;
        }
     }
//--- Вернём количество ордеров
   return(count);
  }
//+------------------------------------------------------------------+
//| Рассчитывает объем для позиции/отложенного ордера                |
//+------------------------------------------------------------------+
double CalculateLot(int symbol_number,double lot)
  {
//--- Для корректировки с учетом шага
   double corrected_lot=0.0;
//---
   GetSymbolProperties(symbol_number,S_VOLUME_MIN);  // Получим минимально возможный лот
   GetSymbolProperties(symbol_number,S_VOLUME_MAX);  // Получим максимально возможный лот
   GetSymbolProperties(symbol_number,S_VOLUME_STEP); // Получим шаг увеличения/уменьшения лота
//--- Скорректируем с учетом шага лота
   corrected_lot=MathRound(lot/symb.volume_step)*symb.volume_step;
//--- Если меньше минимального, вернем минимальный
   if(corrected_lot<symb.volume_min)
      return(NormalizeDouble(symb.volume_min,2));
//--- Если больше максимального, вернем максимальный
   if(corrected_lot>symb.volume_max)
      return(NormalizeDouble(symb.volume_max,2));
//---
   return(NormalizeDouble(corrected_lot,2));
  }
//+------------------------------------------------------------------+
//| Рассчитывает уровень (цену) отложенного ордера                   |
//+------------------------------------------------------------------+
double CalculatePendingOrder(int symbol_number,ENUM_ORDER_TYPE order_type)
  {
//--- Для рассчитанного значения Pending Order
   double price=0.0;
//--- Если нужно рассчитать значение для ордера SELL STOP
   if(order_type==ORDER_TYPE_SELL_STOP)
     {
      //--- Рассчитаем уровень
      price=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- Вернем рассчитанное значение, если оно ниже нижней границы stops level
      //    Если значение выше или равно, вернем скорректированное значение
      return(price<symb.down_level ? price : symb.down_level-symb.offset);
     }
//--- Если нужно рассчитать значение для ордера BUY STOP
   if(order_type==ORDER_TYPE_BUY_STOP)
     {
      //--- Рассчитаем уровень
      price=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- Вернем рассчитанное значение, если оно выше верхней границы stops level
      //    Если значение ниже или равно, вернем скорректированное значение
      return(price>symb.up_level ? price : symb.up_level+symb.offset);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Рассчитывает уровень Take Profit для отложенного ордера          |
//+------------------------------------------------------------------+
double CalculateOrderTakeProfit(int symbol_number,ENUM_ORDER_TYPE order_type,double price)
  {
//--- Если Take Profit нужен
   if(TakeProfit[symbol_number]>0)
     {
      double tp         =0.0; // Для рассчитанного значения Take Profit
      double up_level   =0.0; // Верхний уровень Stop Levels
      double down_level =0.0; // Нижний уровень Stop Levels
      //--- Если нужно рассчитать значение для ордера SELL STOP
      if(order_type==ORDER_TYPE_SELL_STOP)
        {
         //--- Определим нижний порог
         down_level=NormalizeDouble(price-symb.stops_level*symb.point,symb.digits);
         //--- Рассчитаем уровень
         tp=NormalizeDouble(price-CorrectValueBySymbolDigits(TakeProfit[symbol_number]*symb.point),symb.digits);
         //--- Вернем рассчитанное значение, если оно ниже нижней границы stops level
         //    Если значение выше или равно, вернем скорректированное значение
         return(tp<down_level ? tp : NormalizeDouble(down_level-symb.offset,symb.digits));
        }
      //--- Если нужно рассчитать значение для ордера BUY STOP
      if(order_type==ORDER_TYPE_BUY_STOP)
        {
         //--- Определим верхний порог
         up_level=NormalizeDouble(price+symb.stops_level*symb.point,symb.digits);
         //--- Рассчитаем уровень
         tp=NormalizeDouble(price+CorrectValueBySymbolDigits(TakeProfit[symbol_number]*symb.point),symb.digits);
         //--- Вернем рассчитанное значение, если оно выше верхней границы stops level
         //    Если значение ниже или равно, вернем скорректированное значение
         return(tp>up_level ? tp : NormalizeDouble(up_level+symb.offset,symb.digits));
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Рассчитывает уровень Stop Loss для отложенного ордера            |
//+------------------------------------------------------------------+
double CalculateOrderStopLoss(int symbol_number,ENUM_ORDER_TYPE order_type,double price)
  {
//--- Если Stop Loss нужен
   if(StopLoss[symbol_number]>0)
     {
      double sl         =0.0; // Для рассчитанного значения Stop Loss
      double up_level   =0.0; // Верхний уровень Stop Levels
      double down_level =0.0; // Нижний уровень Stop Levels
      //--- Если нужно рассчитать значение для ордера BUY STOP
      if(order_type==ORDER_TYPE_BUY_STOP)
        {
         //--- Определим нижний порог
         down_level=NormalizeDouble(price-symb.stops_level*symb.point,symb.digits);
         //--- Рассчитаем уровень
         sl=NormalizeDouble(price-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- Вернем рассчитанное значение, если оно ниже нижней границы stops level
         //    Если значение выше или равно, вернем скорректированное значение
         return(sl<down_level ? sl : NormalizeDouble(down_level-symb.offset,symb.digits));
        }
      //--- Если нужно рассчитать значение для ордера SELL STOP
      if(order_type==ORDER_TYPE_SELL_STOP)
        {
         //--- Определим верхний порог
         up_level=NormalizeDouble(price+symb.stops_level*symb.point,symb.digits);
         //--- Рассчитаем уровень
         sl=NormalizeDouble(price+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- Вернем рассчитанное значение, если оно выше верхней границы stops level
         //    Если значение ниже или равно, вернем скорректированное значение
         return(sl>up_level ? sl : NormalizeDouble(up_level+symb.offset,symb.digits));
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Рассчитывает уровень Trailing Stop                               |
//+------------------------------------------------------------------+
double CalculateTrailingStop(int symbol_number,ENUM_POSITION_TYPE position_type)
  {
//--- Переменные для расчётов
   double    level       =0.0;
   double    buy_point   =low[symbol_number].value[1];  // Значение Low для Buy
   double    sell_point  =high[symbol_number].value[1]; // Значение High для Sell
//--- Рассчитаем уровень для позиции BUY
   if(position_type==POSITION_TYPE_BUY)
     {
      //--- Минимум бара минус указанное количество пунктов
      level=NormalizeDouble(buy_point-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
      //--- Если рассчитанный уровень ниже, чем нижний уровень ограничения (stops level), 
      //    то расчет закончен, вернем текущее значение уровня
      if(level<symb.down_level)
         return(level);
      //--- Если же не ниже, то попробуем рассчитать от цены bid
      else
        {
         level=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- Если рассчитанный уровень ниже ограничителя, вернем текущее значение уровня
         //    Иначе установим максимально возможный близкий
         return(level<symb.down_level ? level : symb.down_level-symb.offset);
        }
     }
//--- Рассчитаем уровень для позиции SELL
   if(position_type==POSITION_TYPE_SELL)
     {
      // Максимум бара плюс указанное кол-во пунктов
      level=NormalizeDouble(sell_point+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
      //--- Если рассчитанный уровень выше, чем верхний уровень ограничения (stops level), 
      //    то расчёт закончен, вернем текущее значение уровня
      if(level>symb.up_level)
         return(level);
      //--- Если же не выше, то попробуем рассчитать от цены ask
      else
        {
         level=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(StopLoss[symbol_number]*symb.point),symb.digits);
         //--- Если рассчитанный уровень выше ограничителя, вернем текущее значение уровня
         //    Иначе установим максимально возможный близкий
         return(level>symb.up_level ? level : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Рассчитывает уровень Trailing Reverse Order                      |
//+------------------------------------------------------------------+
double CalculateTrailingReverseOrder(int symbol_number,ENUM_POSITION_TYPE position_type)
  {
//--- Переменные для расчётов
   double    level       =0.0;
   double    buy_point   =low[symbol_number].value[1];  // Значение Low для Buy
   double    sell_point  =high[symbol_number].value[1]; // Значение High для Sell
//--- Рассчитаем уровень для позиции BUY
   if(position_type==POSITION_TYPE_BUY)
     {
      //--- Минимум бара минус указанное количество пунктов
      level=NormalizeDouble(buy_point-CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- Если рассчитанный уровень ниже, чем нижний уровень ограничения (stops level), 
      //    то расчет закончен, вернем текущее значение уровня
      if(level<symb.down_level)
         return(level);
      //--- Если же не ниже, то попробуем рассчитать от цены bid
      else
        {
         level=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
         //--- Если рассчитанный уровень ниже ограничителя, вернем текущее значение уровня
         //    Иначе установим максимально возможный близкий
         return(level<symb.down_level ? level : symb.down_level-symb.offset);
        }
     }
//--- Рассчитаем уровень для позиции SELL
   if(position_type==POSITION_TYPE_SELL)
     {
      // Максимум бара плюс указанное кол-во пунктов
      level=NormalizeDouble(sell_point+CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
      //--- Если рассчитанный уровень выше, чем верхний уровень ограничения (stops level), 
      //    то расчёт закончен, вернем текущее значение уровня
      if(level>symb.up_level)
         return(level);
      //--- Если же не выше, то попробуем рассчитать от цены ask
      else
        {
         level=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(PendingOrder[symbol_number]*symb.point),symb.digits);
         //--- Если рассчитанный уровень выше ограничителя, вернем текущее значение уровня
         //    Иначе установим максимально возможный близкий
         return(level>symb.up_level ? level : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Изменяет уровень Trailing Stop                                   |
//+------------------------------------------------------------------+
void ModifyTrailingStop(int symbol_number)
  {
//--- Если отключен трейлинг или StopLoss, выйдем
   if(TrailingStop[symbol_number]==0 || StopLoss[symbol_number]==0)
      return;
//--- Если включен трейлинг и StopLoss
   double new_sl    =0.0;   // Для расчета нового уровня Stop loss
   bool   condition =false; // Для проверки условия на модификацию
//--- Получим флаг наличия/отсутствия позиции
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- Если нет позиции
   if(!pos.exists)
      return;
//--- Получим свойства символа
   GetSymbolProperties(symbol_number,S_ALL);
//--- Получим свойства позиции
   GetPositionProperties(symbol_number,P_ALL);
//--- Получим уровень для Stop Loss
   new_sl=CalculateTrailingStop(symbol_number,pos.type);
//--- В зависимости от типа позиции проверим соответствующее условие на модификацию Trailing Stop
   switch(pos.type)
     {
      case POSITION_TYPE_BUY  :
         //--- Если новое значение для Stop Loss выше,
         //    чем текущее значение плюс установленный шаг
         condition=new_sl>pos.sl+CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
         break;
      case POSITION_TYPE_SELL :
         //--- Если новое значение для Stop Loss ниже,
         //    чем текущее значение минус установленный шаг
         condition=new_sl<pos.sl-CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
         break;
     }
//--- Если Stop Loss есть, то сравним значения перед модификацией
   if(pos.sl>0)
     {
      //--- Если выполняется условие на модификацию ордера, т.е. новое значение ниже/выше, 
      //    чем текущее, модифицируем защитный уровень позиции
      if(condition)
        {
         if(!trade.PositionModify(Symbols[symbol_number],new_sl,pos.tp))
            Print("Ошибка при модификации позиции: ",GetLastError()," - ",ErrorDescription(GetLastError()));
        }
     }
//--- Если Stop Loss нет, то просто установим его
   if(pos.sl==0)
     {
      if(!trade.PositionModify(Symbols[symbol_number],new_sl,pos.tp))
         Print("Ошибка при модификации позиции: ",GetLastError()," - ",ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| Изменяет уровень Trailing Pending Order                          |
//+------------------------------------------------------------------+
void ModifyTrailingPendingOrder(int symbol_number)
  {
//--- Если переворот позиции отключен или
//    Trailing Stop отключен, выйдем
   if(!Reverse[symbol_number] || TrailingStop[symbol_number]==0)
      return;
//--- Если переворот позиции включен или Trailing Stop включен
   double          new_level              =0.0;         // Для расчета нового уровня отложенного ордера
   bool            condition              =false;       // Для проверки условия на модификацию
   int             total_orders           =0;           // Общее количество отложенных ордеров
   ulong           order_ticket           =0;           // Тикет ордера
   string          opposite_order_comment ="";          // Комментарий противоположного ордера
   ENUM_ORDER_TYPE opposite_order_type    =WRONG_VALUE; // Тип ордера

//--- Получим флаг наличия/отсутствия позиции
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- Если нет позиции
   if(!pos.exists)
      return;
//--- Получим количество отложенных ордеров
   total_orders=OrdersTotal();
//--- Получим свойства символа
   GetSymbolProperties(symbol_number,S_ALL);
//--- Получим свойства позиции
   GetPositionProperties(symbol_number,P_ALL);
//--- Получим уровень для Stop Loss
   new_level=CalculateTrailingReverseOrder(symbol_number,pos.type);
//--- Пройдёмся в цикле по всем ордерам от последнего к первому
   for(int i=total_orders-1; i>=0; i--)
     {
      //--- Если ордер выбран
      if((order_ticket=OrderGetTicket(i))>0)
        {
         //--- Получим символ ордера
         GetOrderProperties(O_SYMBOL);
         //--- Получим комментарий ордера
         GetOrderProperties(O_COMMENT);
         //--- Получим цену ордера
         GetOrderProperties(O_PRICE_OPEN);
         //--- В зависимости от типа позиции
         //    проверим соответствующее условие на модификацию Trailing Stop
         switch(pos.type)
           {
            case POSITION_TYPE_BUY  :
               //--- Если новое значение для ордера выше,
               //    чем текущее значение плюс установленный шаг, то условие исполнено
               condition=
               new_level>ord.price_open+CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
               //--- Определим тип и комментарий противоположного отложенного ордера для проверки
               opposite_order_type    =ORDER_TYPE_SELL_STOP;
               opposite_order_comment =comment_bottom_order;
               break;
            case POSITION_TYPE_SELL :
               //--- Если новое значение для ордера ниже,
               //    чем текущее значение минус установленный шаг, то условие исполнено
               condition=
               new_level<ord.price_open-CorrectValueBySymbolDigits(TrailingStop[symbol_number]*symb.point);
               //--- Определим тип и комментарий противоположного отложенного ордера для проверки
               opposite_order_type    =ORDER_TYPE_BUY_STOP;
               opposite_order_comment =comment_top_order;
               break;
           }
         //--- Если условие исполняется и 
         //    символ ордера и позиции совпадают и
         //    комментарий противоположного ордера, то
         if(condition && 
            ord.symbol==Symbols[symbol_number] && 
            ord.comment==opposite_order_comment)
           {
            double sl=0.0; // Стоп лосс
            double tp=0.0; // Тейк профит
            //--- Получим уровни Take Profit и Stop Loss
            sl=CalculateOrderStopLoss(symbol_number,opposite_order_type,new_level);
            tp=CalculateOrderTakeProfit(symbol_number,opposite_order_type,new_level);
            //--- Изменить ордер
            ModifyPendingOrder(symbol_number,order_ticket,opposite_order_type,new_level,sl,tp,
                               ORDER_TIME_GTC,ord.time_expiration,ord.price_stoplimit,ord.comment,0);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Обнуляет переменные свойств позиции                              |
//+------------------------------------------------------------------+
void ZeroPositionProperties()
  {
   pos.symbol       ="";
   pos.exists       =false;
   pos.comment      ="";
   pos.magic        =0;
   pos.price        =0.0;
   pos.current_price=0.0;
   pos.sl           =0.0;
   pos.tp           =0.0;
   pos.type         =WRONG_VALUE;
   pos.volume       =0.0;
   pos.commission   =0.0;
   pos.swap         =0.0;
   pos.profit       =0.0;
   pos.time         =NULL;
   pos.id           =0;
  }
//+------------------------------------------------------------------+
//| Получает свойства позиции                                        |
//+------------------------------------------------------------------+
void GetPositionProperties(int symbol_number,ENUM_POSITION_PROPERTIES position_property)
  {
//--- Узнаем, есть ли позиция
   pos.exists=PositionSelect(Symbols[symbol_number]);
//--- Если позиция есть, получим её свойства
   if(pos.exists)
     {
      switch(position_property)
        {
         case P_TOTAL_DEALS      :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.total_deals=CurrentPositionTotalDeals(symbol_number);                              break;
         case P_SYMBOL           : pos.symbol=PositionGetString(POSITION_SYMBOL);                  break;
         case P_MAGIC            : pos.magic=PositionGetInteger(POSITION_MAGIC);                   break;
         case P_COMMENT          : pos.comment=PositionGetString(POSITION_COMMENT);                break;
         case P_SWAP             : pos.swap=PositionGetDouble(POSITION_SWAP);                      break;
         case P_COMMISSION       : pos.commission=PositionGetDouble(POSITION_COMMISSION);          break;
         case P_PRICE_FIRST_DEAL :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.first_deal_price=CurrentPositionFirstDealPrice(symbol_number);                     break;
         case P_PRICE_OPEN       : pos.price=PositionGetDouble(POSITION_PRICE_OPEN);               break;
         case P_PRICE_CURRENT    : pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);    break;
         case P_PRICE_LAST_DEAL  :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.last_deal_price=CurrentPositionLastDealPrice(symbol_number);                       break;
         case P_PROFIT           : pos.profit=PositionGetDouble(POSITION_PROFIT);                  break;
         case P_VOLUME           : pos.volume=PositionGetDouble(POSITION_VOLUME);                  break;
         case P_INITIAL_VOLUME   :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.initial_volume=CurrentPositionInitialVolume(symbol_number);                        break;
         case P_SL               : pos.sl=PositionGetDouble(POSITION_SL);                          break;
         case P_TP               : pos.tp=PositionGetDouble(POSITION_TP);                          break;
         case P_TIME             : pos.time=(datetime)PositionGetInteger(POSITION_TIME);           break;
         case P_DURATION         : pos.duration=CurrentPositionDuration(SECONDS);                  break;
         case P_ID               : pos.id=PositionGetInteger(POSITION_IDENTIFIER);                 break;
         case P_TYPE             : pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); break;
         case P_ALL              :
            pos.symbol=PositionGetString(POSITION_SYMBOL);
            pos.magic=PositionGetInteger(POSITION_MAGIC);
            pos.comment=PositionGetString(POSITION_COMMENT);
            pos.swap=PositionGetDouble(POSITION_SWAP);
            pos.commission=PositionGetDouble(POSITION_COMMISSION);
            pos.price=PositionGetDouble(POSITION_PRICE_OPEN);
            pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);
            pos.profit=PositionGetDouble(POSITION_PROFIT);
            pos.volume=PositionGetDouble(POSITION_VOLUME);
            pos.sl=PositionGetDouble(POSITION_SL);
            pos.tp=PositionGetDouble(POSITION_TP);
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.id=PositionGetInteger(POSITION_IDENTIFIER);
            pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            pos.total_deals=CurrentPositionTotalDeals(symbol_number);
            pos.first_deal_price=CurrentPositionFirstDealPrice(symbol_number);
            pos.last_deal_price=CurrentPositionLastDealPrice(symbol_number);
            pos.initial_volume=CurrentPositionInitialVolume(symbol_number);
            pos.duration=CurrentPositionDuration(SECONDS);                                         break;
            //---
         default: Print("Переданное свойство позиции не учтено в перечислении!");                  return;
        }
     }
//--- Если позиции нет, обнулим переменные свойств позиции
   else
      ZeroPositionProperties();
  }
//+------------------------------------------------------------------+
//| Получает свойства предварительно выбранного ордера               |
//+------------------------------------------------------------------+
void GetOrderProperties(ENUM_ORDER_PROPERTIES order_property)
  {
   switch(order_property)
     {
      case O_SYMBOL          : ord.symbol=OrderGetString(ORDER_SYMBOL);                              break;
      case O_MAGIC           : ord.magic=OrderGetInteger(ORDER_MAGIC);                               break;
      case O_COMMENT         : ord.comment=OrderGetString(ORDER_COMMENT);                            break;
      case O_PRICE_OPEN      : ord.price_open=OrderGetDouble(ORDER_PRICE_OPEN);                      break;
      case O_PRICE_CURRENT   : ord.price_current=OrderGetDouble(ORDER_PRICE_CURRENT);                break;
      case O_PRICE_STOPLIMIT : ord.price_stoplimit=OrderGetDouble(ORDER_PRICE_STOPLIMIT);            break;
      case O_VOLUME_INITIAL  : ord.volume_initial=OrderGetDouble(ORDER_VOLUME_INITIAL);              break;
      case O_VOLUME_CURRENT  : ord.volume_current=OrderGetDouble(ORDER_VOLUME_CURRENT);              break;
      case O_SL              : ord.sl=OrderGetDouble(ORDER_SL);                                      break;
      case O_TP              : ord.tp=OrderGetDouble(ORDER_TP);                                      break;
      case O_TIME_SETUP      : ord.time_setup=(datetime)OrderGetInteger(ORDER_TIME_SETUP);           break;
      case O_TIME_EXPIRATION : ord.time_expiration=(datetime)OrderGetInteger(ORDER_TIME_EXPIRATION); break;
      case O_TIME_SETUP_MSC  : ord.time_setup_msc=(datetime)OrderGetInteger(ORDER_TIME_SETUP_MSC);   break;
      case O_TYPE_TIME       : ord.type_time=(datetime)OrderGetInteger(ORDER_TYPE_TIME);             break;
      case O_TYPE            : ord.type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);                break;
      case O_ALL             :
         ord.symbol=OrderGetString(ORDER_SYMBOL);
         ord.magic=OrderGetInteger(ORDER_MAGIC);
         ord.comment=OrderGetString(ORDER_COMMENT);
         ord.price_open=OrderGetDouble(ORDER_PRICE_OPEN);
         ord.price_current=OrderGetDouble(ORDER_PRICE_CURRENT);
         ord.price_stoplimit=OrderGetDouble(ORDER_PRICE_STOPLIMIT);
         ord.volume_initial=OrderGetDouble(ORDER_VOLUME_INITIAL);
         ord.volume_current=OrderGetDouble(ORDER_VOLUME_CURRENT);
         ord.sl=OrderGetDouble(ORDER_SL);
         ord.tp=OrderGetDouble(ORDER_TP);
         ord.time_setup=(datetime)OrderGetInteger(ORDER_TIME_SETUP);
         ord.time_expiration=(datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
         ord.time_setup_msc=(datetime)OrderGetInteger(ORDER_TIME_SETUP_MSC);
         ord.type_time=(datetime)OrderGetInteger(ORDER_TYPE_TIME);
         ord.type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);                                      break;
         //---
      default: Print("Переданное свойство отложенного ордера не учтено в перечислении!");            return;
     }
  }
//+------------------------------------------------------------------+
//| Получает свойства сделки по тикету                               |
//+------------------------------------------------------------------+
void GetHistoryDealProperties(ulong ticket,ENUM_DEAL_PROPERTIES history_deal_property)
  {
   switch(history_deal_property)
     {
      case D_SYMBOL     : deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);              break;
      case D_COMMENT    : deal.comment=HistoryDealGetString(ticket,DEAL_COMMENT);            break;
      case D_TYPE       : deal.type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE); break;
      case D_ENTRY      : deal.entry=(int)HistoryDealGetInteger(ticket,DEAL_ENTRY);          break;
      case D_PRICE      : deal.price=HistoryDealGetDouble(ticket,DEAL_PRICE);                break;
      case D_PROFIT     : deal.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);              break;
      case D_VOLUME     : deal.volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);              break;
      case D_SWAP       : deal.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);                  break;
      case D_COMMISSION : deal.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);      break;
      case D_TIME       : deal.time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);       break;
      case D_ALL        :
         deal.symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         deal.comment=HistoryDealGetString(ticket,DEAL_COMMENT);
         deal.type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
         deal.entry=(int)HistoryDealGetInteger(ticket,DEAL_ENTRY);
         deal.price=HistoryDealGetDouble(ticket,DEAL_PRICE);
         deal.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         deal.volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
         deal.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
         deal.commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         deal.time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);                        break;
         //---
      default: Print("Переданное свойство сделки не учтено в перечислении!");                return;
     }
  }
//+------------------------------------------------------------------+
//| Получает свойства символа                                        |
//+------------------------------------------------------------------+
void GetSymbolProperties(int symbol_number,ENUM_SYMBOL_PROPERTIES symbol_property)
  {
   int lot_offset=1; // Количество пунктов для отступа от уровней stops level
//---
   switch(symbol_property)
     {
      case S_DIGITS         : symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);                   break;
      case S_SPREAD         : symb.spread=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_SPREAD);                   break;
      case S_STOPSLEVEL     : symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);   break;
      case S_POINT          : symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);                           break;
      //---
      case S_ASK            :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.ask=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_ASK),symb.digits);                       break;
      case S_BID            :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.bid=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_BID),symb.digits);                       break;
         //---
      case S_VOLUME_MIN     : symb.volume_min=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MIN);                 break;
      case S_VOLUME_MAX     : symb.volume_max=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MAX);                 break;
      case S_VOLUME_LIMIT   : symb.volume_limit=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_LIMIT);             break;
      case S_VOLUME_STEP    : symb.volume_step=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_STEP);               break;
      //---
      case S_FILTER         :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);                      break;
         //---
      case S_UP_LEVEL       :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_ASK),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);                                 break;
         //---
      case S_DOWN_LEVEL     :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.bid=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_BID),symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);                               break;
         //---
      case S_EXECUTION_MODE :
         symb.execution_mode=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_EXEMODE); break;
         //---
      case S_ALL            :
         symb.digits=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_DIGITS);
         symb.spread=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_SPREAD);
         symb.stops_level=(int)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_ASK),symb.digits);
         symb.bid=NormalizeDouble(SymbolInfoDouble(Symbols[symbol_number],SYMBOL_BID),symb.digits);
         symb.volume_min=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MIN);
         symb.volume_max=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_MAX);
         symb.volume_limit=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_LIMIT);
         symb.volume_step=SymbolInfoDouble(Symbols[symbol_number],SYMBOL_VOLUME_STEP);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);
         symb.execution_mode=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(Symbols[symbol_number],SYMBOL_TRADE_EXEMODE); break;
         //---
      default : Print("Переданное свойство символа не учтено в перечислении!"); return;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает причину закрытия позиции по Take Profit               |
//+------------------------------------------------------------------+
bool GetEventTakeProfit(int symbol_number)
  {
   string last_comment="";
//--- Получим комментарий последней сделки на указанном символе
   last_comment=LastDealComment(symbol_number);
//--- Если в комментарии есть строка "tp"
   if(StringFind(last_comment,"tp",0)>-1)
      return(true);
//--- Если нет строки "tp"
   return(false);
  }
//+------------------------------------------------------------------+
//| Возвращает причину закрытия позиции по Stop Loss                 |
//+------------------------------------------------------------------+
bool GetEventStopLoss(int symbol_number)
  {
   string last_comment="";
//--- Получим комментарий последней сделки на указанном символе
   last_comment=LastDealComment(symbol_number);
//--- Если в комментарии есть строка "sl"
   if(StringFind(last_comment,"sl",0)>-1)
      return(true);
//--- Если нет строки "sl"
   return(false);
  }
//+------------------------------------------------------------------+
//| Возвращает комментарий последней сделки на указанном символе     |
//+------------------------------------------------------------------+
string LastDealComment(int symbol_number)
  {
   int    total_deals  =0;  // Всего сделок в списке выбранной истории
   string deal_symbol  =""; // Символ сделки 
   string deal_comment =""; // Комментарий сделки
//--- Если история сделок получена
   if(HistorySelect(0,TimeCurrent()))
     {
      //--- Получим количество сделок в полученном списке
      total_deals=HistoryDealsTotal();
      //--- Пройдемся по всем сделкам в полученном списке
      //    от последней сделки к первой
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- Получим комментарий сделки
         deal_comment=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_COMMENT);
         //--- Получим символ сделки
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- Если символ сделки и текущий символ равны, остановим цикл
         if(deal_symbol==Symbols[symbol_number])
            break;
        }
     }
//---
   return(deal_comment);
  }
//+------------------------------------------------------------------+
//| Возвращает событие последней сделки на указанном символе         |
//+------------------------------------------------------------------+
bool GetEventLastDealTicket(int symbol_number)
  {
   int    total_deals =0;  // Всего сделок в списке выбранной истории
   string deal_symbol =""; // Символ сделки
   ulong  deal_ticket =0;  // Тикет сделки
//--- Если история сделок получена
   if(HistorySelect(0,TimeCurrent()))
     {
      //--- Получим количество сделок в полученном списке
      total_deals=HistoryDealsTotal();
      //--- Пройдемся по всем сделкам в полученном списке
      //    от последней сделки к первой
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- Получим тикет сделки
         deal_ticket=HistoryDealGetTicket(i);
         //--- Получим символ сделки
         deal_symbol=HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
         //--- Если символ сделки и текущий символ равны, остановим цикл
         if(deal_symbol==Symbols[symbol_number])
           {
            //--- Если тикеты равны, выйдем
            if(deal_ticket==last_ticket_deal[symbol_number])
               return(false);
            //--- Если тикеты не равны, сообщим об этом и
            else
              {
               //--- Запомним тикет последней сделки
               last_ticket_deal[symbol_number]=deal_ticket;
               return(true);
              }
           }
        }
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Возвращает количество сделок текущей позиции                     |
//+------------------------------------------------------------------+
uint CurrentPositionTotalDeals(int symbol_number)
  {
   int    count       =0;  // Счетчик сделок по символу позиции
   int    total_deals =0;  // Всего сделок в списке выбранной истории
   string deal_symbol =""; // символ сделки
//--- Если история позиции получена
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Получим количество сделок в полученном списке
      total_deals=HistoryDealsTotal();
      //--- Пройдем по всем сделкам в полученном списке
      for(int i=0; i<total_deals; i++)
        {
         //--- Получим символ сделки
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- Если символ сделки и текущий символ совпадают, увеличим счетчик
         if(deal_symbol==Symbols[symbol_number])
            count++;
        }
     }
//---
   return(count);
  }
//+------------------------------------------------------------------+
//| Возвращает цену первой сделки текущей позиции                    |
//+------------------------------------------------------------------+
double CurrentPositionFirstDealPrice(int symbol_number)
  {
   int      total_deals =0;    // Всего сделок в списке выбранной истории
   string   deal_symbol ="";   // символ сделки
   double   deal_price  =0.0;  // Цена сделки
   datetime deal_time   =NULL; // Время сделки
//--- Если история позиции получена
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Получим количество сделок в полученном списке
      total_deals=HistoryDealsTotal();
      //--- Пройдем по всем сделкам в полученном списке
      for(int i=0; i<total_deals; i++)
        {
         //--- Получим цену сделки
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- Получим символ сделки
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- Получим время сделки
         deal_time=(datetime)HistoryDealGetInteger(HistoryDealGetTicket(i),DEAL_TIME);
         //--- Если время сделки и время открытия позиции равны, 
         //    а также равны символ сделки и текущий символ, выйдем из цикла
         if(deal_time==pos.time && deal_symbol==Symbols[symbol_number])
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| Возвращает цену последней сделки текущей позиции                 |
//+------------------------------------------------------------------+
double CurrentPositionLastDealPrice(int symbol_number)
  {
   int    total_deals =0;   // Всего сделок в списке выбранной истории
   string deal_symbol ="";  // Символ сделки 
   double deal_price  =0.0; // Цена
//--- Если история позиции получена
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Получим количество сделок в полученном списке
      total_deals=HistoryDealsTotal();
      //--- Пройдем по всем сделкам в полученном списке от последней сделки в списке к первой
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- Получим цену сделки
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- Получим символ сделки
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- Если символ сделки и текущий символ равны, остановим цикл
         if(deal_symbol==Symbols[symbol_number])
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| Возвращает начальный объем текущей позиции                       |
//+------------------------------------------------------------------+
double CurrentPositionInitialVolume(int symbol_number)
  {
   int             total_deals =0;           // Всего сделок в списке выбранной истории
   ulong           ticket      =0;           // Тикет сделки
   ENUM_DEAL_ENTRY deal_entry  =WRONG_VALUE; // Способ изменения позиции
   bool            inout       =false;       // Признак наличия разворота позиции
   double          sum_volume  =0.0;         // Счетчик совокупного объема всех сделок кроме первой
   double          deal_volume =0.0;         // Объем сделки
   string          deal_symbol ="";          // Символ сделки 
   datetime        deal_time   =NULL;        // Время совершения сделки
//--- Если история позиции получена
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Получим количество сделок в полученном списке
      total_deals=HistoryDealsTotal();
      //--- Пройдем по всем сделкам в полученном списке от последней сделки в списке к первой
      for(int i=total_deals-1; i>=0; i--)
        {
         //--- Если тикет ордера по его позиции в списке получен, то...
         if((ticket=HistoryDealGetTicket(i))>0)
           {
            //--- Получим объем сделки
            deal_volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            //--- Получим способ изменения позиции
            deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
            //--- Получим время совершения сделки
            deal_time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
            //--- Получим символ сделки
            deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
            //--- Когда время совершения сделки будет меньше или равно времени открытия позиции, выйдем из цикла
            if(deal_time<=pos.time)
               break;
            //--- иначе считаем совокупный объем сделок по символу позиции, кроме первой
            if(deal_symbol==Symbols[symbol_number])
               sum_volume+=deal_volume;
           }
        }
     }
//--- Если способ изменения позиции - разворот
   if(deal_entry==DEAL_ENTRY_INOUT)
     {
      //--- Если объём позиции увеличивался/уменьшался
      //    То есть, сделок больше одной
      if(fabs(sum_volume)>0)
        {
         //--- Текущий объем минус объем всех сделок кроме первой
         double result=pos.volume-sum_volume;
         //--- Если итог больше нуля, вернем итог, иначе вернем текущий объем позиции         
         deal_volume=result>0 ? result : pos.volume;
        }
      //--- Если сделок кроме входа больше не было,
      if(sum_volume==0)
         deal_volume=pos.volume; // вернём текущий объем позиции
     }
//--- Вернем начальный объем позиции
   return(NormalizeDouble(deal_volume,2));
  }
//+------------------------------------------------------------------+
//| Возвращает длительность текущей позиции                          |
//+------------------------------------------------------------------+
ulong CurrentPositionDuration(ENUM_POSITION_DURATION mode)
  {
   ulong     result=0;   // Итоговый результат
   ulong     seconds=0;  // Количество секунд
//--- Вычислим длительность позиции в секундах
   seconds=TimeCurrent()-pos.time;
//---
   switch(mode)
     {
      case DAYS      : result=seconds/(60*60*24);   break; // Посчитаем кол-во дней
      case HOURS     : result=seconds/(60*60);      break; // Посчитаем кол-во часов
      case MINUTES   : result=seconds/60;           break; // Посчитаем кол-во минут
      case SECONDS   : result=seconds;              break; // Без расчетов (кол-во секунд)
      //---
      default        :
         Print(__FUNCTION__,"(): Передан неизвестный режим длительности!");
         return(0);
     }
//--- Вернем результат
   return(result);
  }
//+------------------------------------------------------------------+
//| Проверка нового бара                                             |
//+------------------------------------------------------------------+
bool CheckNewBar(int symbol_number)
  {
//--- Получим время открытия текущего бара
//    Если возникла ошибка при получении, сообщим об этом
   if(CopyTime(Symbols[symbol_number],Period(),0,1,lastbar_time[symbol_number].time)==-1)
      Print(__FUNCTION__,": Ошибка копирования времени открытия бара: "+IntegerToString(GetLastError())+"");
//--- Если это первый вызов функции
   if(new_bar[symbol_number]==NULL)
     {
      //--- Установим время
      new_bar[symbol_number]=lastbar_time[symbol_number].time[0];
      Print(__FUNCTION__,": Инициализация ["+Symbols[symbol_number]+"][TF: "+TimeframeToString(Period())+"]["
            +TimeToString(lastbar_time[symbol_number].time[0],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"]");
      return(false);
     }
//--- Если время отличается
   if(new_bar[symbol_number]!=lastbar_time[symbol_number].time[0])
     {
      //--- Установим время и выйдем
      new_bar[symbol_number]=lastbar_time[symbol_number].time[0];
      return(true);
     }
//--- Дошли до этого места - значит бар не новый, вернем false
   return(false);
  }
//+------------------------------------------------------------------+
