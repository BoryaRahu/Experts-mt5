//--- Перечисление свойств позиции
enum ENUM_POSITION_PROPERTIES
  {
   P_TOTAL_DEALS     = 0,
   P_SYMBOL          = 1,
   P_MAGIC           = 2,
   P_COMMENT         = 3,
   P_SWAP            = 4,
   P_COMMISSION      = 5,
   P_PRICE_FIRST_DEAL= 6,
   P_PRICE_OPEN      = 7,
   P_PRICE_CURRENT   = 8,
   P_PRICE_LAST_DEAL = 9,
   P_PROFIT          = 10,
   P_VOLUME          = 11,
   P_INITIAL_VOLUME  = 12,
   P_SL              = 13,
   P_TP              = 14,
   P_TIME            = 15,
   P_DURATION        = 16,
   P_ID              = 17,
   P_TYPE            = 18,
   P_ALL             = 19
  };
//--- Перечисление свойств отложенного ордера
enum ENUM_ORDER_PROPERTIES
  {
   O_SYMBOL          = 0,
   O_MAGIC           = 1,
   O_COMMENT         = 2,
   O_PRICE_OPEN      = 3,
   O_PRICE_CURRENT   = 4,
   O_PRICE_STOPLIMIT = 5,
   O_VOLUME_INITIAL  = 6,
   O_VOLUME_CURRENT  = 7,
   O_SL              = 8,
   O_TP              = 9,
   O_TIME_SETUP      = 10,
   O_TIME_EXPIRATION = 11,
   O_TIME_SETUP_MSC  = 12,
   O_TYPE_TIME       = 13,
   O_TYPE            = 14,
   O_ALL             = 15
  };
//--- Перечисление свойств сделки
enum ENUM_DEAL_PROPERTIES
  {
   D_SYMBOL     = 0, // Символ
   D_COMMENT    = 1, // Комментарий
   D_TYPE       = 2, // Тип
   D_ENTRY      = 3, // Направление
   D_PRICE      = 4, // Цена
   D_PROFIT     = 5, // Прибыль/убыток
   D_VOLUME     = 6, // Объём
   D_SWAP       = 7, // Своп
   D_COMMISSION = 8, // Комиссия
   D_TIME       = 9, // Время
   D_ALL        = 10 // Все вышеперечисленные свойства сделки
  };
//--- Перечисление свойств символа
enum ENUM_SYMBOL_PROPERTIES
  {
   S_DIGITS          = 0,
   S_SPREAD          = 1,
   S_STOPSLEVEL      = 2,
   S_POINT           = 3,
   S_ASK             = 4,
   S_BID             = 5,
   S_VOLUME_MIN      = 6,
   S_VOLUME_MAX      = 7,
   S_VOLUME_LIMIT    = 8,
   S_VOLUME_STEP     = 9,
   S_FILTER          = 10,
   S_UP_LEVEL        = 11,
   S_DOWN_LEVEL      = 12,
   S_EXECUTION_MODE  = 13,
   S_ALL             = 14
  };
//--- Длительность позиции
enum ENUM_POSITION_DURATION
  {
   DAYS     = 0, // Дни
   HOURS    = 1, // Часы
   MINUTES  = 2, // Минуты
   SECONDS  = 3  // Секунды
  };
//--- Перечисление часов
enum ENUM_HOURS
  {
   h00 = 0,  // 00 : 00
   h01 = 1,  // 01 : 00
   h02 = 2,  // 02 : 00
   h03 = 3,  // 03 : 00
   h04 = 4,  // 04 : 00
   h05 = 5,  // 05 : 00
   h06 = 6,  // 06 : 00
   h07 = 7,  // 07 : 00
   h08 = 8,  // 08 : 00
   h09 = 9,  // 09 : 00
   h10 = 10, // 10 : 00
   h11 = 11, // 11 : 00
   h12 = 12, // 12 : 00
   h13 = 13, // 13 : 00
   h14 = 14, // 14 : 00
   h15 = 15, // 15 : 00
   h16 = 16, // 16 : 00
   h17 = 17, // 17 : 00
   h18 = 18, // 18 : 00
   h19 = 19, // 19 : 00
   h20 = 20, // 20 : 00
   h21 = 21, // 21 : 00
   h22 = 22, // 22 : 00
   h23 = 23  // 23 : 00
  };
//+------------------------------------------------------------------+
//| События новых баров и тиков со всех символов и таймфреймов       |
//+------------------------------------------------------------------+
enum ENUM_CHART_EVENT_SYMBOL
  {
   CHARTEVENT_NO         = 0,          // События отключены - 0
   CHARTEVENT_INIT       = 0,          // Событие "инициализация" - 0
   //---
   CHARTEVENT_NEWBAR_M1  = 0x00000001, // Событие "новый бар" на 1 -минутном графике - 1
   CHARTEVENT_NEWBAR_M2  = 0x00000002, // Событие "новый бар" на 2 -минутном графике - 2
   CHARTEVENT_NEWBAR_M3  = 0x00000004, // Событие "новый бар" на 3 -минутном графике - 4
   CHARTEVENT_NEWBAR_M4  = 0x00000008, // Событие "новый бар" на 4 -минутном графике - 8
   //---
   CHARTEVENT_NEWBAR_M5  = 0x00000010, // Событие "новый бар" на 5 -минутном графике - 16
   CHARTEVENT_NEWBAR_M6  = 0x00000020, // Событие "новый бар" на 6 -минутном графике - 32
   CHARTEVENT_NEWBAR_M10 = 0x00000040, // Событие "новый бар" на 10-минутном графике - 64
   CHARTEVENT_NEWBAR_M12 = 0x00000080, // Событие "новый бар" на 12-минутном графике - 128
   //---
   CHARTEVENT_NEWBAR_M15 = 0x00000100, // Событие "новый бар" на 15-минутном графике - 256
   CHARTEVENT_NEWBAR_M20 = 0x00000200, // Событие "новый бар" на 20-минутном графике - 512
   CHARTEVENT_NEWBAR_M30 = 0x00000400, // Событие "новый бар" на 30-минутном графике - 1024
   CHARTEVENT_NEWBAR_H1  = 0x00000800, // Событие "новый бар" на 1 -часовом графике  - 2048
   //---
   CHARTEVENT_NEWBAR_H2  = 0x00001000, // Событие "новый бар" на 2 -часовом графике  - 4096
   CHARTEVENT_NEWBAR_H3  = 0x00002000, // Событие "новый бар" на 3 -часовом графике  - 8192
   CHARTEVENT_NEWBAR_H4  = 0x00004000, // Событие "новый бар" на 4 -часовом графике  - 16384
   CHARTEVENT_NEWBAR_H6  = 0x00008000, // Событие "новый бар" на 6 -часовом графике  - 32768
   //---
   CHARTEVENT_NEWBAR_H8  = 0x00010000, // Событие "новый бар" на 8 -часовом графике  - 65536
   CHARTEVENT_NEWBAR_H12 = 0x00020000, // Событие "новый бар" на 12-часовом графике  - 131072
   CHARTEVENT_NEWBAR_D1  = 0x00040000, // Событие "новый бар" на дневном графике     - 262144
   CHARTEVENT_NEWBAR_W1  = 0x00080000, // Событие "новый бар" на недельном графике   - 524288
   //---
   CHARTEVENT_NEWBAR_MN1 = 0x00100000, // Событие "новый бар" на месячном графике    - 1048576
   CHARTEVENT_TICK       = 0x00200000, // Событие "новый тик"                        - 2097152
   //---
   CHARTEVENT_ALL        = 0xFFFFFFFF  // Все события включены                       - -1
  };
//+------------------------------------------------------------------+