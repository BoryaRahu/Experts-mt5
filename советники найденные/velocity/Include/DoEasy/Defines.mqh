//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
//+------------------------------------------------------------------+
//| Макроподстановки                                                 |
//+------------------------------------------------------------------+
//--- "Описание функции с номером строки ошибки"
#define DFUN_ERR_LINE            (__FUNCTION__+(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian" ? ", Стр. " : ", Line ")+(string)__LINE__+": ")
#define DFUN                     (__FUNCTION__+": ")        // "Описание функции"
#define COUNTRY_LANG             ("Russian")                // Язык страны
#define END_TIME                 (D'31.12.3000 23:59:59')   // Конечная дата для запросов данных истории счёта
#define TIMER_FREQUENCY          (16)                       // Минимальная частота таймера библиотеки в милисекундах
#define COLLECTION_PAUSE         (250)                      // Пауза таймера коллекции ордеров и сделок в милисекундах
#define COLLECTION_COUNTER_STEP  (16)                       // Шаг приращения счётчика таймера коллекции ордеров и сделок
#define COLLECTION_COUNTER_ID    (1)                        // Идентификатор счётчика таймера коллекции ордеров и сделок
#define COLLECTION_HISTORY_ID    (0x7778+1)                 // Идентификатор списка исторической коллекции
#define COLLECTION_MARKET_ID     (0x7778+2)                 // Идентификатор списка рыночной коллекции
#define COLLECTION_EVENTS_ID     (0x7778+3)                 // Идентификатор списка коллекции событий
//+------------------------------------------------------------------+
//| Структуры                                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Перечисления                                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Данные для поиска и сортировки                                   |
//+------------------------------------------------------------------+
enum ENUM_COMPARER_TYPE
  {
   EQUAL,                                                   // Равно
   MORE,                                                    // Больше
   LESS,                                                    // Меньше
   NO_EQUAL,                                                // Не равно
   EQUAL_OR_MORE,                                           // Больше или равно
   EQUAL_OR_LESS                                            // Меньше или равно
  };
//+------------------------------------------------------------------+
//| Возможные варианты выбора по времени                             |
//+------------------------------------------------------------------+
enum ENUM_SELECT_BY_TIME
  {
   SELECT_BY_TIME_OPEN,                                     // По времени открытия
   SELECT_BY_TIME_CLOSE,                                    // По времени закрытия
   SELECT_BY_TIME_OPEN_MSC,                                 // По времени открытия в милисекундах
   SELECT_BY_TIME_CLOSE_MSC,                                // По времени закрытия в милисекундах
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Список флагов возможных вариантов изменения ордеров и позиций    |
//+------------------------------------------------------------------+
enum ENUM_CHANGE_TYPE_FLAGS
  {
   CHANGE_TYPE_FLAG_NO_CHANGE    =  0,                      // Нет изменений
   CHANGE_TYPE_FLAG_TYPE         =  1,                      // Изменение типа ордера
   CHANGE_TYPE_FLAG_PRICE        =  2,                      // Изменение цены
   CHANGE_TYPE_FLAG_STOP         =  4,                      // Изменение StopLoss
   CHANGE_TYPE_FLAG_TAKE         =  8,                      // Изменение TakeProfit
   CHANGE_TYPE_FLAG_ORDER        =  16                      // Флаг изменения свойств ордера
  };
//+------------------------------------------------------------------+
//| Возможные варианты изменения ордеров и позиций                   |
//+------------------------------------------------------------------+
enum ENUM_CHANGE_TYPE
  {
   CHANGE_TYPE_NO_CHANGE,                                   // Нет изменений
   CHANGE_TYPE_ORDER_TYPE,                                  // Изменение типа ордера
   CHANGE_TYPE_ORDER_PRICE,                                 // Изменение цены установки ордера
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS,                       // Изменение цены установки ордера и StopLoss 
   CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT,                     // Изменение цены установки ордера и TakeProfit
   CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT,           // Изменение цены установки ордера, StopLoss и TakeProfit
   CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT,                 // Изменение StopLoss и TakeProfit
   CHANGE_TYPE_ORDER_STOP_LOSS,                             // Изменение StopLoss ордера
   CHANGE_TYPE_ORDER_TAKE_PROFIT,                           // Изменение TakeProfit ордера
   CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT,              // Изменение StopLoss и TakeProfit позиции
   CHANGE_TYPE_POSITION_STOP_LOSS,                          // Изменение StopLoss позиции
   CHANGE_TYPE_POSITION_TAKE_PROFIT,                        // Изменение TakeProfit позиции
  };
//+------------------------------------------------------------------+
//| Данные для работы с ордерами                                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Тип (статус) абстрактного ордера                                 |
//+------------------------------------------------------------------+
enum ENUM_ORDER_STATUS
  {
   ORDER_STATUS_MARKET_PENDING,                             // Рыночный отложенный ордер
   ORDER_STATUS_MARKET_ORDER,                               // Рыночный маркет-ордер
   ORDER_STATUS_MARKET_POSITION,                            // Рыночная позиция
   ORDER_STATUS_HISTORY_ORDER,                              // Исторический маркет-ордер
   ORDER_STATUS_HISTORY_PENDING,                            // Удаленный отложенный ордер
   ORDER_STATUS_BALANCE,                                    // Балансная операция
   ORDER_STATUS_CREDIT,                                     // Кредитная операция
   ORDER_STATUS_DEAL,                                       // Сделка
   ORDER_STATUS_UNKNOWN                                     // Неизвестный статус
  };
//+------------------------------------------------------------------+
//| Целочисленные свойства ордера, сделки, позиции                   |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_INTEGER
  {
   ORDER_PROP_TICKET = 0,                                   // Тикет ордера
   ORDER_PROP_MAGIC,                                        // Мэджик ордера
   ORDER_PROP_TIME_OPEN,                                    // Время открытия (MQL5 Время сделки)
   ORDER_PROP_TIME_CLOSE,                                   // Время закрытия (MQL5 Время исполнения или снятия - ORDER_TIME_DONE)
   ORDER_PROP_TIME_OPEN_MSC,                                // Время открытия в милисекундах (MQL5 Время сделки в мсек.)
   ORDER_PROP_TIME_CLOSE_MSC,                               // Время закрытия в милисекундах (MQL5 Время исполнения или снятия - ORDER_TIME_DONE_MSC)
   ORDER_PROP_TIME_EXP,                                     // Дата экспирации ордера (для отложенных ордеров)
   ORDER_PROP_STATUS,                                       // Статус ордера (из перечисления ENUM_ORDER_STATUS)
   ORDER_PROP_TYPE,                                         // Тип ордера/сделки
   ORDER_PROP_REASON,                                       // Причина или источник сделки/ордера/позиции
   ORDER_PROP_STATE,                                        // Состояние ордера (из перечисления ENUM_ORDER_STATE)
   ORDER_PROP_POSITION_ID,                                  // Идентификатор позиции
   ORDER_PROP_POSITION_BY_ID,                               // Идентификатор встречной позиции
   ORDER_PROP_DEAL_ORDER_TICKET,                            // Тикет ордера, на основании которого выполнена сделка
   ORDER_PROP_DEAL_ENTRY,                                   // Направление сделки – IN, OUT или IN/OUT
   ORDER_PROP_TIME_UPDATE,                                  // Время изменения позиции в секундах
   ORDER_PROP_TIME_UPDATE_MSC,                              // Время изменения позиции в милисекундах
   ORDER_PROP_TICKET_FROM,                                  // Тикет родительского ордера
   ORDER_PROP_TICKET_TO,                                    // Тикет дочернего ордера
   ORDER_PROP_PROFIT_PT,                                    // Профит в пунктах
   ORDER_PROP_CLOSE_BY_SL,                                  // Признак закрытия по StopLoss
   ORDER_PROP_CLOSE_BY_TP,                                  // Признак закрытия по TakeProfit
   ORDER_PROP_GROUP_ID,                                     // Идентификатор группы ордеров/позиций
   ORDER_PROP_DIRECTION,                                    // Тип по направлению (Buy, Sell)
  }; 
#define ORDER_PROP_INTEGER_TOTAL    (24)                    // Общее количество целочисленных свойств
#define ORDER_PROP_INTEGER_SKIP     (0)                     // Количество неиспользуемых в сортировке свойств ордера
//+------------------------------------------------------------------+
//| Вещественные свойства ордера, сделки, позиции                    |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_DOUBLE
  {
   ORDER_PROP_PRICE_OPEN = ORDER_PROP_INTEGER_TOTAL,        // Цена открытия (MQL5 цена сделки)
   ORDER_PROP_PRICE_CLOSE,                                  // Цена закрытия
   ORDER_PROP_SL,                                           // Цена StopLoss
   ORDER_PROP_TP,                                           // Цена TaleProfit
   ORDER_PROP_PROFIT,                                       // Профит
   ORDER_PROP_COMMISSION,                                   // Комиссия
   ORDER_PROP_SWAP,                                         // Своп
   ORDER_PROP_VOLUME,                                       // Объём
   ORDER_PROP_VOLUME_CURRENT,                               // Невыполненный объем
   ORDER_PROP_PROFIT_FULL,                                  // Профит+комиссия+своп
   ORDER_PROP_PRICE_STOP_LIMIT,                             // Цена постановки Limit ордера при срабатывании StopLimit ордера
  };
#define ORDER_PROP_DOUBLE_TOTAL     (11)                    // Общее количество вещественных свойств
//+------------------------------------------------------------------+
//| Строковые свойства ордера, сделки, позиции                       |
//+------------------------------------------------------------------+
enum ENUM_ORDER_PROP_STRING
  {
   ORDER_PROP_SYMBOL = (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL), // Символ ордера
   ORDER_PROP_COMMENT,                                      // Комментарий ордера
   ORDER_PROP_EXT_ID                                        // Идентификатор ордера во внешней торговой системе
  };
#define ORDER_PROP_STRING_TOTAL     (3)                     // Общее количество строковых свойств
//+------------------------------------------------------------------+
//| Возможные критерии сортировки ордеров и сделок                   |
//+------------------------------------------------------------------+
#define FIRST_ORD_DBL_PROP          (ORDER_PROP_INTEGER_TOTAL-ORDER_PROP_INTEGER_SKIP)
#define FIRST_ORD_STR_PROP          (ORDER_PROP_INTEGER_TOTAL+ORDER_PROP_DOUBLE_TOTAL-ORDER_PROP_INTEGER_SKIP)
enum ENUM_SORT_ORDERS_MODE
  {
   //--- Сортировка по целочисленным свойствам
   SORT_BY_ORDER_TICKET          =  0,                      // Сортировать по тикету ордера
   SORT_BY_ORDER_MAGIC           =  1,                      // Сортировать по магику ордера
   SORT_BY_ORDER_TIME_OPEN       =  2,                      // Сортировать по времени открытия ордера
   SORT_BY_ORDER_TIME_CLOSE      =  3,                      // Сортировать по времени закрытия ордера
   SORT_BY_ORDER_TIME_OPEN_MSC   =  4,                      // Сортировать по времени открытия ордера в милисекундах
   SORT_BY_ORDER_TIME_CLOSE_MSC  =  5,                      // Сортировать по времени закрытия ордера в милисекундах
   SORT_BY_ORDER_TIME_EXP        =  6,                      // Сортировать по дате экспирации ордера
   SORT_BY_ORDER_STATUS          =  7,                      // Сортировать по статусу ордера (маркет-ордер/отложенный ордер/сделка/балансная,кредитная операция)
   SORT_BY_ORDER_TYPE            =  8,                      // Сортировать по типу ордера
   SORT_BY_ORDER_REASON          =  9,                      // Сортировать по причине/источнику сделки/ордера/позиции
   SORT_BY_ORDER_STATE           =  10,                     // Сортировать по состоянию ордера
   SORT_BY_ORDER_POSITION_ID     =  11,                     // Сортировать по идентификатору позиции
   SORT_BY_ORDER_POSITION_BY_ID  =  12,                     // Сортировать по идентификатору встречной позиции
   SORT_BY_ORDER_DEAL_ORDER      =  13,                     // Сортировать по ордеру, на основание которого выполнена сделка
   SORT_BY_ORDER_DEAL_ENTRY      =  14,                     // Сортировать по направлению сделки – IN, OUT или IN/OUT
   SORT_BY_ORDER_TIME_UPDATE     =  15,                     // Сортировать по времени изменения позиции в секундах
   SORT_BY_ORDER_TIME_UPDATE_MSC =  16,                     // Сортировать по времени изменения позиции в милисекундах
   SORT_BY_ORDER_TICKET_FROM     =  17,                     // Сортировать по тикету родительского ордера
   SORT_BY_ORDER_TICKET_TO       =  18,                     // Сортировать по тикету дочернего ордера
   SORT_BY_ORDER_PROFIT_PT       =  19,                     // Сортировать по профиту ордера в пунктах
   SORT_BY_ORDER_CLOSE_BY_SL     =  20,                     // Сортировать по признаку закрытия ордера по StopLoss
   SORT_BY_ORDER_CLOSE_BY_TP     =  21,                     // Сортировать по признаку закрытия ордера по TakeProfit
   SORT_BY_ORDER_GROUP_ID        =  22,                     // Сортировать по идентификатору группы ордеров/позиций
   SORT_BY_ORDER_DIRECTION       =  23,                     // Сортировать по направлению (Buy, Sell)
   //--- Сортировка по вещественным свойствам
   SORT_BY_ORDER_PRICE_OPEN      =  FIRST_ORD_DBL_PROP,     // Сортировать по цене открытия
   SORT_BY_ORDER_PRICE_CLOSE     =  FIRST_ORD_DBL_PROP+1,   // Сортировать по цене закрытия
   SORT_BY_ORDER_SL              =  FIRST_ORD_DBL_PROP+2,   // Сортировать по цене StopLoss
   SORT_BY_ORDER_TP              =  FIRST_ORD_DBL_PROP+3,   // Сортировать по цене TaleProfit
   SORT_BY_ORDER_PROFIT          =  FIRST_ORD_DBL_PROP+4,   // Сортировать по профиту
   SORT_BY_ORDER_COMMISSION      =  FIRST_ORD_DBL_PROP+5,   // Сортировать по комиссии
   SORT_BY_ORDER_SWAP            =  FIRST_ORD_DBL_PROP+6,   // Сортировать по свопу
   SORT_BY_ORDER_VOLUME          =  FIRST_ORD_DBL_PROP+7,   // Сортировать по объёму
   SORT_BY_ORDER_VOLUME_CURRENT  =  FIRST_ORD_DBL_PROP+8,   // Сортировать по невыполненному объему
   SORT_BY_ORDER_PROFIT_FULL     =  FIRST_ORD_DBL_PROP+9,   // Сортировать по критерию профит+комиссия+своп
   SORT_BY_ORDER_PRICE_STOP_LIMIT=  FIRST_ORD_DBL_PROP+10,  // Сортировать по цене постановки Limit ордера при срабатывании StopLimit ордера
   //--- Сортировка по строковым свойствам
   SORT_BY_ORDER_SYMBOL          =  FIRST_ORD_STR_PROP,     // Сортировать по символу
   SORT_BY_ORDER_COMMENT         =  FIRST_ORD_STR_PROP+1,   // Сортировать по комментарию
   SORT_BY_ORDER_EXT_ID          =  FIRST_ORD_STR_PROP+2    // Сортировать по идентификатору ордера во внешней торговой системе
  };
//+------------------------------------------------------------------+
//| Данные для работы с событиями счёта                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Список флагов торговых событий на счёте                          |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT_FLAGS
  {
   TRADE_EVENT_FLAG_NO_EVENT        =  0,                   // Нет события
   TRADE_EVENT_FLAG_ORDER_PLASED    =  1,                   // Отложенный ордер установлен
   TRADE_EVENT_FLAG_ORDER_REMOVED   =  2,                   // Отложенный ордер удалён
   TRADE_EVENT_FLAG_ORDER_ACTIVATED =  4,                   // Отложенный ордер активирован ценой
   TRADE_EVENT_FLAG_POSITION_OPENED =  8,                   // Позиция открыта
   TRADE_EVENT_FLAG_POSITION_CHANGED=  16,                  // Позиция изменена
   TRADE_EVENT_FLAG_POSITION_REVERSE=  32,                  // Разворот позиции
   TRADE_EVENT_FLAG_POSITION_CLOSED =  64,                  // Позиция закрыта
   TRADE_EVENT_FLAG_ACCOUNT_BALANCE =  128,                 // Балансная операция (уточнение в типе сделки)
   TRADE_EVENT_FLAG_PARTIAL         =  256,                 // Частичное исполнение
   TRADE_EVENT_FLAG_BY_POS          =  512,                 // Исполнение встречной позицией
   TRADE_EVENT_FLAG_PRICE           =  1024,                // Модификация цены установки
   TRADE_EVENT_FLAG_SL              =  2048,                // Исполнение по StopLoss
   TRADE_EVENT_FLAG_TP              =  4096,                // Исполнение по TakeProfit
   TRADE_EVENT_FLAG_ORDER_MODIFY    =  8192,                // Модификация ордера
   TRADE_EVENT_FLAG_POSITION_MODIFY =  16384,               // Модификация позиции
  };
//+------------------------------------------------------------------+
//| Список возможных торговых событий на счёте                       |
//+------------------------------------------------------------------+
enum ENUM_TRADE_EVENT
  {
   TRADE_EVENT_NO_EVENT = 0,                                // Нет торгового события
   TRADE_EVENT_PENDING_ORDER_PLASED,                        // Отложенный ордер установлен
   TRADE_EVENT_PENDING_ORDER_REMOVED,                       // Отложенный ордер удалён
//--- члены перечисления, совпадающие с членами перечисления ENUM_DEAL_TYPE
//--- (порядок следования констант ниже менять нельзя, удалять и добавлять новые - нельзя)
   TRADE_EVENT_ACCOUNT_CREDIT = DEAL_TYPE_CREDIT,           // Начисление кредита (3)
   TRADE_EVENT_ACCOUNT_CHARGE,                              // Дополнительные сборы
   TRADE_EVENT_ACCOUNT_CORRECTION,                          // Корректирующая запись
   TRADE_EVENT_ACCOUNT_BONUS,                               // Перечисление бонусов
   TRADE_EVENT_ACCOUNT_COMISSION,                           // Дополнительные комиссии
   TRADE_EVENT_ACCOUNT_COMISSION_DAILY,                     // Комиссия, начисляемая в конце торгового дня
   TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY,                   // Комиссия, начисляемая в конце месяца
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY,               // Агентская комиссия, начисляемая в конце торгового дня
   TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY,             // Агентская комиссия, начисляемая в конце месяца
   TRADE_EVENT_ACCOUNT_INTEREST,                            // Начисления процентов на свободные средства
   TRADE_EVENT_BUY_CANCELLED,                               // Отмененная сделка покупки
   TRADE_EVENT_SELL_CANCELLED,                              // Отмененная сделка продажи
   TRADE_EVENT_DIVIDENT,                                    // Начисление дивиденда
   TRADE_EVENT_DIVIDENT_FRANKED,                            // Начисление франкированного дивиденда
   TRADE_EVENT_TAX                        = DEAL_TAX,       // Начисление налога
//--- константы, относящиеся к типу сделки DEAL_TYPE_BALANCE из перечисления ENUM_DEAL_TYPE
   TRADE_EVENT_ACCOUNT_BALANCE_REFILL     = DEAL_TAX+1,     // Пополнение средств на балансе
   TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL = DEAL_TAX+2,     // Снятие средств с баланса
//--- Остальные возможные торговые события
//--- (менять порядок следования констант ниже, удалять и добавлять новые - можно)
   TRADE_EVENT_PENDING_ORDER_ACTIVATED    = DEAL_TAX+3,     // Отложенный ордер активирован ценой
   TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL,             // Отложенный ордер активирован ценой частично
   TRADE_EVENT_POSITION_OPENED,                             // Позиция открыта
   TRADE_EVENT_POSITION_OPENED_PARTIAL,                     // Позиция открыта частично
   TRADE_EVENT_POSITION_CLOSED,                             // Позиция закрыта
   TRADE_EVENT_POSITION_CLOSED_BY_POS,                      // Позиция закрыта встречной
   TRADE_EVENT_POSITION_CLOSED_BY_SL,                       // Позиция закрыта по StopLoss
   TRADE_EVENT_POSITION_CLOSED_BY_TP,                       // Позиция закрыта по TakeProfit
   TRADE_EVENT_POSITION_REVERSED_BY_MARKET,                 // Разворот позиции новой сделкой (неттинг)
   TRADE_EVENT_POSITION_REVERSED_BY_PENDING,                // Разворот позиции активацией отложенного ордера (неттинг)
   TRADE_EVENT_POSITION_REVERSED_BY_MARKET_PARTIAL,         // Разворот позиции частичным исполнением маркет-ордера (неттинг)
   TRADE_EVENT_POSITION_REVERSED_BY_PENDING_PARTIAL,        // Разворот позиции частичной активацией отложенного ордера (неттинг)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET,               // Добавлен объём к позиции новой сделкой (неттинг)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_MARKET_PARTIAL,       // Добавлен объём к позиции частичным исполнением маркет-ордера (неттинг)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING,              // Добавлен объём к позиции активацией отложенного ордера (неттинг)
   TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL,      // Добавлен объём к позиции частичной активацией отложенного ордера (неттинг)
   TRADE_EVENT_POSITION_CLOSED_PARTIAL,                     // Позиция закрыта частично
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS,              // Позиция закрыта частично встречной
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL,               // Позиция закрыта частично по StopLoss
   TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP,               // Позиция закрыта частично по TakeProfit
   TRADE_EVENT_TRIGGERED_STOP_LIMIT_ORDER,                  // Срабатывание StopLimit ордера
   TRADE_EVENT_MODIFY_ORDER_PRICE,                          // Изменение цены установки ордера
   TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS,                // Изменение цены установки ордера и StopLoss 
   TRADE_EVENT_MODIFY_ORDER_PRICE_TAKE_PROFIT,              // Изменение цены установки ордера и TakeProfit
   TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT,    // Изменение цены установки ордера, StopLoss и TakeProfit
   TRADE_EVENT_MODIFY_ORDER_STOP_LOSS_TAKE_PROFIT,          // Изменение StopLoss и TakeProfit ордера
   TRADE_EVENT_MODIFY_ORDER_STOP_LOSS,                      // Изменение StopLoss ордера
   TRADE_EVENT_MODIFY_ORDER_TAKE_PROFIT,                    // Изменение TakeProfit ордера
   TRADE_EVENT_MODIFY_POSITION_STOP_LOSS_TAKE_PROFIT,       // Изменение StopLoss и TakeProfit позиции
   TRADE_EVENT_MODIFY_POSITION_STOP_LOSS,                   // Изменение StopLoss позиции
   TRADE_EVENT_MODIFY_POSITION_TAKE_PROFIT,                 // Изменение TakeProfit позиции
  };
//+------------------------------------------------------------------+
//| Статус события                                                   |
//+------------------------------------------------------------------+
enum ENUM_EVENT_STATUS
  {
   EVENT_STATUS_MARKET_POSITION,                            // Событие рыночной позиции (открытие, частичное открытие, частичное закрытие, добавление объёма, разворот)
   EVENT_STATUS_MARKET_PENDING,                             // Событие рыночного отложенного ордера (установка)
   EVENT_STATUS_HISTORY_PENDING,                            // Событие исторического отложенного ордера (удаление)
   EVENT_STATUS_HISTORY_POSITION,                           // Событие исторической позиции (закрытие)
   EVENT_STATUS_BALANCE,                                    // Событие балансной операции (начисление баланса, снятие средств и события из перечисления ENUM_DEAL_TYPE)
   EVENT_STATUS_MODIFY                                      // Событие модификации ордера/позиции
  };
//+------------------------------------------------------------------+
//| Причина события                                                  |
//+------------------------------------------------------------------+
enum ENUM_EVENT_REASON
  {
   EVENT_REASON_REVERSE,                                    // Разворот позиции (неттинг)
   EVENT_REASON_REVERSE_PARTIALLY,                          // Разворот позиции частичным исполнением заявки (неттинг)
   EVENT_REASON_REVERSE_BY_PENDING,                         // Разворот позиции при срабатывании отложенного ордера (неттинг)
   EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY,               // Разворот позиции при при частичном срабатывании отложенного ордера (неттинг)
   //--- Все константы, относящиеся к развороту позиции, должны быть в списке выше
   EVENT_REASON_ACTIVATED_PENDING,                          // Срабатывание отложенного ордера
   EVENT_REASON_ACTIVATED_PENDING_PARTIALLY,                // Частичное срабатывание отложенного ордера
   EVENT_REASON_STOPLIMIT_TRIGGERED,                        // Срабатывание StopLimit-ордера
   EVENT_REASON_MODIFY,                                     // Модификация
   EVENT_REASON_CANCEL,                                     // Отмена
   EVENT_REASON_EXPIRED,                                    // Истечение срока действия ордера
   EVENT_REASON_DONE,                                       // Заявка исполнена полностью
   EVENT_REASON_DONE_PARTIALLY,                             // Заявка исполнена частично
   EVENT_REASON_VOLUME_ADD,                                 // Добавление объёма к позиции (неттинг)
   EVENT_REASON_VOLUME_ADD_PARTIALLY,                       // Добавление объёма к позиции частичным исполнением заявки (неттинг)
   EVENT_REASON_VOLUME_ADD_BY_PENDING,                      // Добавление объёма к позиции при срабатывании отложенного ордера (неттинг)
   EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY,            // Добавление объёма к позиции при частичном срабатывании отложенного ордера (неттинг)
   EVENT_REASON_DONE_SL,                                    // Закрытие по StopLoss
   EVENT_REASON_DONE_SL_PARTIALLY,                          // Частичное закрытие по StopLoss
   EVENT_REASON_DONE_TP,                                    // Закрытие по TakeProfit
   EVENT_REASON_DONE_TP_PARTIALLY,                          // Частичное закрытие по TakeProfit
   EVENT_REASON_DONE_BY_POS,                                // Закрытие встречной позицией
   EVENT_REASON_DONE_PARTIALLY_BY_POS,                      // Частичное закрытие встречной позицией
   EVENT_REASON_DONE_BY_POS_PARTIALLY,                      // Закрытие частичным объёмом встречной позиции
   EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY,            // Частичное закрытие частичным объёмом встречной позиции
   //--- Константы, относящиеся к типу сделки DEAL_TYPE_BALANCE из перечисления ENUM_DEAL_TYPE
   EVENT_REASON_BALANCE_REFILL,                             // Пополнение счёта
   EVENT_REASON_BALANCE_WITHDRAWAL,                         // Снятие средств со счёта
   //--- Список констант соотносится с TRADE_EVENT_ACCOUNT_CREDIT из перечисления ENUM_TRADE_EVENT, смещено на +13 относительно ENUM_DEAL_TYPE (EVENT_REASON_ACCOUNT_CREDIT-3)
   EVENT_REASON_ACCOUNT_CREDIT,                             // Начисление кредита
   EVENT_REASON_ACCOUNT_CHARGE,                             // Дополнительные сборы
   EVENT_REASON_ACCOUNT_CORRECTION,                         // Корректирующая запись
   EVENT_REASON_ACCOUNT_BONUS,                              // Перечисление бонусов
   EVENT_REASON_ACCOUNT_COMISSION,                          // Дополнительные комиссии
   EVENT_REASON_ACCOUNT_COMISSION_DAILY,                    // Комиссия, начисляемая в конце торгового дня
   EVENT_REASON_ACCOUNT_COMISSION_MONTHLY,                  // Комиссия, начисляемая в конце месяца
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY,              // Агентская комиссия, начисляемая в конце торгового дня
   EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY,            // Агентская комиссия, начисляемая в конце месяца
   EVENT_REASON_ACCOUNT_INTEREST,                           // Начисления процентов на свободные средства
   EVENT_REASON_BUY_CANCELLED,                              // Отмененная сделка покупки
   EVENT_REASON_SELL_CANCELLED,                             // Отмененная сделка продажи
   EVENT_REASON_DIVIDENT,                                   // Начисление дивиденда
   EVENT_REASON_DIVIDENT_FRANKED,                           // Начисление франкированного дивиденда
   EVENT_REASON_TAX                                         // Начисление налога
  };
#define REASON_EVENT_SHIFT    (EVENT_REASON_ACCOUNT_CREDIT-3)
//+------------------------------------------------------------------+
//| Целочисленные свойства события                                   |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_INTEGER
  {
   EVENT_PROP_TYPE_EVENT = 0,                               // Тип торгового события на счёте (из перечисления ENUM_TRADE_EVENT)
   EVENT_PROP_TIME_EVENT,                                   // Время события в милисекундах
   EVENT_PROP_STATUS_EVENT,                                 // Статус события (из перечисления ENUM_EVENT_STATUS)
   EVENT_PROP_REASON_EVENT,                                 // Причина события (из перечисления ENUM_EVENT_REASON)
   //---
   EVENT_PROP_TYPE_DEAL_EVENT,                              // Тип сделки события
   EVENT_PROP_TICKET_DEAL_EVENT,                            // Тикет сделки события
   EVENT_PROP_TYPE_ORDER_EVENT,                             // Тип ордера, на основании которого открыта сделка события (последний ордер позиции)
   EVENT_PROP_TICKET_ORDER_EVENT,                           // Тикет ордера, на основании которого открыта сделка события (последний ордер позиции)
   //---
   EVENT_PROP_TIME_ORDER_POSITION,                          // Время ордера, на основании которого открыта первая сделка позиции (первый ордер позиции на хедж-счёте)
   EVENT_PROP_TYPE_ORDER_POSITION,                          // Тип ордера, на основании которого открыта первая сделка позиции (первый ордер позиции на хедж-счёте)
   EVENT_PROP_TICKET_ORDER_POSITION,                        // Тикет ордера, на основании которого открыта первая сделка позиции (первый ордер позиции на хедж-счёте)
   EVENT_PROP_POSITION_ID,                                  // Идентификатор позиции
   //---
   EVENT_PROP_POSITION_BY_ID,                               // Идентификатор встречной позиции
   EVENT_PROP_MAGIC_ORDER,                                  // Магический номер ордера/сделки/позиции
   EVENT_PROP_MAGIC_BY_ID,                                  // Магический номер встречной позиции
   //---
   EVENT_PROP_TYPE_ORD_POS_BEFORE,                          // Тип позиции до смены направления
   EVENT_PROP_TICKET_ORD_POS_BEFORE,                        // Тикет ордера позиции до смены направления
   EVENT_PROP_TYPE_ORD_POS_CURRENT,                         // Тип текущей позиции
   EVENT_PROP_TICKET_ORD_POS_CURRENT,                       // Тикет ордера текущей позиции
  }; 
#define EVENT_PROP_INTEGER_TOTAL (19)                       // Общее количество целочисленных свойств события
#define EVENT_PROP_INTEGER_SKIP  (4)                        // Количество неиспользуемых в сортировке свойств события
//+------------------------------------------------------------------+
//| Вещественные свойства события                                    |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_DOUBLE
  {
   EVENT_PROP_PRICE_EVENT = EVENT_PROP_INTEGER_TOTAL,       // Цена, на которой произошло событие
   EVENT_PROP_PRICE_OPEN,                                   // Цена открытия ордера/сделки/позиции
   EVENT_PROP_PRICE_CLOSE,                                  // Цена закрытия ордера/сделки/позиции
   EVENT_PROP_PRICE_SL,                                     // Цена StopLoss ордера/сделки/позиции
   EVENT_PROP_PRICE_TP,                                     // Цена TakeProfit ордера/сделки/позиции
   EVENT_PROP_VOLUME_ORDER_INITIAL,                         // Запрашиваемый объём ордера
   EVENT_PROP_VOLUME_ORDER_EXECUTED,                        // Исполненный объём ордера
   EVENT_PROP_VOLUME_ORDER_CURRENT,                         // Оставшийся объём ордера
   EVENT_PROP_VOLUME_POSITION_EXECUTED,                     // Текущий исполненный объём позиции после сделки
   EVENT_PROP_PROFIT,                                       // Профит
   //---
   EVENT_PROP_PRICE_OPEN_BEFORE,                            // Цена установки ордера до модификации
   EVENT_PROP_PRICE_SL_BEFORE,                              // Цена StopLoss до модификации
   EVENT_PROP_PRICE_TP_BEFORE,                              // Цена TakeProfit до модификации
   EVENT_PROP_PRICE_EVENT_ASK,                              // Цена Ask в момент события
   EVENT_PROP_PRICE_EVENT_BID,                              // Цена Bid в момент события
  };
#define EVENT_PROP_DOUBLE_TOTAL  (15)                       // Общее количество вещественных свойств события
#define EVENT_PROP_DOUBLE_SKIP   (5)                        // Количество неиспользуемых в сортировке свойств события
//+------------------------------------------------------------------+
//| Строковые свойства события                                       |
//+------------------------------------------------------------------+
enum ENUM_EVENT_PROP_STRING
  {
   EVENT_PROP_SYMBOL = (EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_DOUBLE_TOTAL), // Символ ордера
   EVENT_PROP_SYMBOL_BY_ID                                  // Символ встречной позиции
  };
#define EVENT_PROP_STRING_TOTAL     (2)                     // Общее количество строковых свойств события
//+------------------------------------------------------------------+
//| Возможные критерии сортировки событий                            |
//+------------------------------------------------------------------+
#define FIRST_EVN_DBL_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP)
#define FIRST_EVN_STR_PROP       (EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_INTEGER_SKIP+EVENT_PROP_DOUBLE_TOTAL-EVENT_PROP_DOUBLE_SKIP)
enum ENUM_SORT_EVENTS_MODE
  {
   //--- Сортировка по целочисленным свойствам
   SORT_BY_EVENT_TYPE_EVENT               = 0,                       // Сортировать по типу события
   SORT_BY_EVENT_TIME_EVENT               = 1,                       // Сортировать по времени события
   SORT_BY_EVENT_STATUS_EVENT             = 2,                       // Сортировать по статусу события (из перечисления ENUM_EVENT_STATUS)
   SORT_BY_EVENT_REASON_EVENT             = 3,                       // Сортировать по причине события (из перечисления ENUM_EVENT_REASON)
   SORT_BY_EVENT_TYPE_DEAL_EVENT          = 4,                       // Сортировать по типу сделки события
   SORT_BY_EVENT_TICKET_DEAL_EVENT        = 5,                       // Сортировать по тикету сделки события
   SORT_BY_EVENT_TYPE_ORDER_EVENT         = 6,                       // Сортировать по типу ордера, на основании которого открыта сделка события (последний ордер позиции)
   SORT_BY_EVENT_TICKET_ORDER_EVENT       = 7,                       // Сортировать по тикету ордера, на основании которого открыта сделка события (последний ордер позиции)
   SORT_BY_EVENT_TIME_ORDER_POSITION      = 8,                       // Сортировать по времени ордера, на основании которого открыта сделка позиции (первый ордер позиции)
   SORT_BY_EVENT_TYPE_ORDER_POSITION      = 9,                       // Сортировать по типу ордера, на основании которого открыта сделка позиции (первый ордер позиции)
   SORT_BY_EVENT_TICKET_ORDER_POSITION    = 10,                      // Сортировать по тикету ордера, на основании которого открыта сделка позиции (первый ордер позиции)
   SORT_BY_EVENT_POSITION_ID              = 11,                      // Сортировать по идентификатору позиции
   SORT_BY_EVENT_POSITION_BY_ID           = 12,                      // Сортировать по идентификатору встречной позиции
   SORT_BY_EVENT_MAGIC_ORDER              = 13,                      // Сортировать по магическому номеру ордера/сделки/позиции
   SORT_BY_EVENT_MAGIC_BY_ID              = 14,                      // Сортировать по магическому номеру встречной позиции
   //--- Сортировка по вещественным свойствам
   SORT_BY_EVENT_PRICE_EVENT              =  FIRST_EVN_DBL_PROP,     // Сортировать по цене, на которой произошло событие
   SORT_BY_EVENT_PRICE_OPEN               =  FIRST_EVN_DBL_PROP+1,   // Сортировать по цене открытия позиции
   SORT_BY_EVENT_PRICE_CLOSE              =  FIRST_EVN_DBL_PROP+2,   // Сортировать по цене закрытия позиции
   SORT_BY_EVENT_PRICE_SL                 =  FIRST_EVN_DBL_PROP+3,   // Сортировать по цене StopLoss позиции
   SORT_BY_EVENT_PRICE_TP                 =  FIRST_EVN_DBL_PROP+4,   // Сортировать по цене TakeProfit позиции
   SORT_BY_EVENT_VOLUME_ORDER_INITIAL     =  FIRST_EVN_DBL_PROP+5,   // Сортировать по первоначальному объёму
   SORT_BY_EVENT_VOLUME_ORDER_EXECUTED    =  FIRST_EVN_DBL_PROP+6,   // Сортировать по текущему объёму
   SORT_BY_EVENT_VOLUME_ORDER_CURRENT     =  FIRST_EVN_DBL_PROP+7,   // Сортировать по оставшемуся объёму
   SORT_BY_EVENT_VOLUME_POSITION_EXECUTED =  FIRST_EVN_DBL_PROP+8,   // Сортировать по оставшемуся объёму
   SORT_BY_EVENT_PROFIT                   =  FIRST_EVN_DBL_PROP+9,   // Сортировать по профиту
   //--- Сортировка по строковым свойствам
   SORT_BY_EVENT_SYMBOL                   =  FIRST_EVN_STR_PROP,     // Сортировать по символу ордера/позици/сделки
   SORT_BY_EVENT_SYMBOL_BY_ID                                        // Сортировать по символу встречной позици
  };
//+------------------------------------------------------------------+
