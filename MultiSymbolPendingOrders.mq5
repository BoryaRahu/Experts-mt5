//+------------------------------------------------------------------+
//|                                     MultiSymbolPendingOrders.mq5 |
//|            Copyright 2013, https://login.mql5.com/ru/users/tol64 |
//|                                  Site, http://tol64.blogspot.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2013, http://tol64.blogspot.com"
#property link        "http://tol64.blogspot.com"
#property description "email: hello.tol64@gmail.com"
#property version     "1.0"
//--- Количество торгуемых символов
#define NUMBER_OF_SYMBOLS 2
//--- Подключаем класс стандартной библиотеки
#include <Trade/Trade.mqh>
//--- Загрузка класса
CTrade   trade;
//--- Подключаем свои библиотеки
#include "Include/Enums.mqh"
#include "Include/InitializeArrays.mqh"
#include "Include/Errors.mqh"
#include "Include/TradeSignals.mqh"
#include "Include/TradeFunctions.mqh"
#include "Include/ToString.mqh"
#include "Include/Auxiliary.mqh"
//--- Внешние параметры эксперта
sinput long       MagicNumber       = 777;      // Магический номер
sinput int        Deviation         = 10;       // Проскальзывание
//---
sinput string delimeter_00=""; // --------------------------------
sinput string     Symbol_01            ="EURUSD";  // Символ 1
input  bool       TradeInTimeRange_01  =true;      // |     Торговля во временном диапазоне
input  ENUM_HOURS StartTrade_01        = h10;      // |     Час начала торговли
input  ENUM_HOURS StopOpenOrders_01    = h17;      // |     Час окончания установки ордеров
input  ENUM_HOURS EndTrade_01          = h22;      // |     Час окончания торговли
input  double     PendingOrder_01      = 50;       // |     Отложенный ордер
input  double     TakeProfit_01        = 100;      // |     Тейк Профит
input  double     StopLoss_01          = 50;       // |     Стоп Лосс
input  double     TrailingStop_01      = 10;       // |     Трейлинг Стоп
input  bool       Reverse_01           = true;     // |     Разворот позиции
input  double     Lot_01               = 0.1;      // |     Лот
//---
sinput string delimeter_01=""; // --------------------------------
sinput string     Symbol_02            ="AUDUSD";  // Символ 2
input  bool       TradeInTimeRange_02  =true;      // |     Торговля во временном диапазоне
input  ENUM_HOURS StartTrade_02        = h10;      // |     Час начала торговли
input  ENUM_HOURS StopOpenOrders_02    = h17;      // |     Час окончания установки ордеров
input  ENUM_HOURS EndTrade_02          = h22;      // |     Час окончания торговли
input  double     PendingOrder_02      = 50;       // |     Отложенный ордер
input  double     TakeProfit_02        = 100;      // |     Тейк Профит
input  double     StopLoss_02          = 50;       // |     Стоп Лосс
input  double     TrailingStop_02      = 10;       // |     Трейлинг Стоп
input  bool       Reverse_02           = true;     // |     Разворот позиции
input  double     Lot_02               = 0.1;      // |     Лот
//--- Массивы для хранения внешних параметров
string     Symbols[NUMBER_OF_SYMBOLS];          // Символ
bool       TradeInTimeRange[NUMBER_OF_SYMBOLS]; // Торговля во временном диапазоне
ENUM_HOURS StartTrade[NUMBER_OF_SYMBOLS];       // Час начала торговли
ENUM_HOURS StopOpenOrders[NUMBER_OF_SYMBOLS];   // Час окончания установки ордеров
ENUM_HOURS EndTrade[NUMBER_OF_SYMBOLS];         // Час окончания торговли
double     PendingOrder[NUMBER_OF_SYMBOLS];     // Отложенный ордер
double     TakeProfit[NUMBER_OF_SYMBOLS];       // Тейк Профит
double     StopLoss[NUMBER_OF_SYMBOLS];         // Стоп Лосс
double     TrailingStop[NUMBER_OF_SYMBOLS];     // Трейлинг Стоп
bool       Reverse[NUMBER_OF_SYMBOLS];          // Разворот позиции
double     Lot[NUMBER_OF_SYMBOLS];              // Лот

//--- Массив хэндлов для индикаторов-агентов
int spy_indicator_handles[NUMBER_OF_SYMBOLS];
//--- Массивы данных для проверки торговых условий 
struct PriceData
  {
   double            value[];
  };
PriceData open[NUMBER_OF_SYMBOLS];      // Цена открытия бара
PriceData high[NUMBER_OF_SYMBOLS];      // Цена максимума бара
PriceData low[NUMBER_OF_SYMBOLS];       // Цена минимума бара
PriceData close[NUMBER_OF_SYMBOLS];     // Цена закрытия бара
//--- Массивы для получения времени открытия текущего бара
struct Datetime
  {
   datetime          time[];
  };
Datetime lastbar_time[NUMBER_OF_SYMBOLS];
//--- Массив для проверки нового бара на каждом символе
datetime new_bar[NUMBER_OF_SYMBOLS];
//--- Массив для проверки тикета последней сделки на каждом символе
ulong last_deal_ticket[NUMBER_OF_SYMBOLS];
//--- Комментарии отложенных ордеров
string comment_top_order    ="top_order";
string comment_bottom_order ="bottom_order";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Инициализация массивов внешних параметров
   InitializeInputParameters();
//--- Проверим внешние параметры
   if(!CheckInputParameters())
      return(INIT_PARAMETERS_INCORRECT);
//--- Инициализация массивов хэндлов индикаторов
   InitializeHandlesArray();
//--- Получаем хэндлы агентов
   GetSpyHandles();
//--- Инициализируем новый бар
   InitializeNewBarArray();
//--- Инициализаия прошла успешно
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Вывести в журнал причину деинициализации
   Print(GetDeinitReasonText(reason));
//--- При удалении с графика
   if(reason==REASON_REMOVE)
     {
      //--- Удалим хендлы индикаторов
      for(int s=NUMBER_OF_SYMBOLS-1; s>=0; s--)
         IndicatorRelease(spy_indicator_handles[s]);
     }
  }
//+------------------------------------------------------------------+
//| Обработка торговых событий                                       |
//+------------------------------------------------------------------+
void OnTrade()
  {
//--- Проверим состояние отложенных ордеров
   ManagePendingOrders();
  }
//+------------------------------------------------------------------+
//| Обработчик пользовательских событий и событий графика            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Идентификатор события
                  const long &lparam,   // Параметр события типа long
                  const double &dparam, // Параметр события типа double
                  const string &sparam) // Параметр события типа string
  {
//--- Если это пользовательское событие
   if(id>=CHARTEVENT_CUSTOM)
     {
      //--- Выйти, если запрещено торговать
      if(CheckTradingPermission()>0)
         return;
      //--- Если было событие "тик"
      if(lparam==CHARTEVENT_TICK)
        {
         //--- Проверим состояние отложенных ордеров
         ManagePendingOrders();
         //--- Проверим сигналы и торгуем по ним
         CheckSignalsAndTrade();
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Проверяет сигналы и торгует по событию "новый бар"               |
//+------------------------------------------------------------------+
void CheckSignalsAndTrade()
  {
//--- Пройдемся по всем указанным символам
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- Если торговля по этому символу не разрешена, выйдем
      if(Symbols[s]=="")
         continue;
      //--- Если бар не новый, перейти к следующему символу
      if(!CheckNewBar(s))
         continue;
      //--- Если есть новый бар
      else
        {
         //--- Если вне временного диапазона
         if(!IsInTradeTimeRange(s))
           {
            //--- Закроем позицию
            ClosePosition(s);
            //--- Удалим все отложенные ордера
            DeleteAllPendingOrders(s);
            //--- Перейдем к следующему символу
            continue;
           }
         //--- Получим данные баров
         GetBarsData(s);
         //--- Проверим условия и торгуем
         TradingBlock(s);
         //--- Если включен переворот позиции
         if(Reverse[s])
            //--- Подтягиваем стоп лосс для отложенного ордера
            ModifyPendingOrderTrailingStop(s);
         //--- Если отключен переворот позиции
         else
         //--- Подтягиваем стоп лосс
            ModifyTrailingStop(s);
        }
     }
  }
//+------------------------------------------------------------------+
//| Проверяет внешние параметры                                      |
//+------------------------------------------------------------------+
bool CheckInputParameters()
  {
//--- Пройдемся по всем указанным символам
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- Если символа нет или торговля во временном диапазоне отключена, переходим к следующему символу
      if(Symbols[s]=="" || !TradeInTimeRange[s])
         continue;
      //--- Проверим корректность времени начала и окончания торговли
      if(StartTrade[s]>=EndTrade[s])
        {
         Print(Symbols[s],
               ": Час начала торговли ("+IntegerToString(StartTrade[s])+") "
               "должен быть меньше часа окончания торговли ("+IntegerToString(EndTrade[s])+")!");
         return(false);
        }
      //--- Начинать торговлю можно не позднее чем за 1 час до времени установки отложенных ордеров.
      //    Установка отложенных ордеров должна выполняться не позднее чем за 1 час до окончания торговли.
      if(StopOpenOrders[s]>=EndTrade[s] ||
         StopOpenOrders[s]<=StartTrade[s])
        {
         Print(Symbols[s],
               ": Час окончания установки ордеров ("+IntegerToString(StopOpenOrders[s])+") "
               "должен быть меньше часа окончания ("+IntegerToString(EndTrade[s])+") и "
               "больше часа начала торговли  ("+IntegerToString(StartTrade[s])+")!");
         return(false);
        }
     }
//--- Параметры корректны
   return(true);
  }
//+------------------------------------------------------------------+
//| Проверяет, находимся ли в торговом временном диапазоне           |
//+------------------------------------------------------------------+
bool IsInTradeTimeRange(int symbol_number)
  {
//--- Если включена торговля во временном диапазоне
   if(TradeInTimeRange[symbol_number])
     {
      //--- Структура даты и времени
      MqlDateTime last_date;
      //--- Получим последние данные даты и времени
      TimeTradeServer(last_date);
      //--- Вне разрешенного временного диапазона
      if(last_date.hour<StartTrade[symbol_number] ||
         last_date.hour>=EndTrade[symbol_number])
         return(false);
     }
//--- В разрешенном временном диапазоне
   return(true);
  }
//+------------------------------------------------------------------+
//| Проверяет, находимся ли во временном диапазоне установки ордеров |
//+------------------------------------------------------------------+
bool IsInOpenOrdersTimeRange(int symbol_number)
  {
//--- Если включена торговля во временном диапазоне
   if(TradeInTimeRange[symbol_number])
     {
      //--- Структура даты и времени
      MqlDateTime last_date; 
      //--- Получим последние данные даты и времени
      TimeTradeServer(last_date);
      //--- Вне разрешенного временного диапазона
      if(last_date.hour<StartTrade[symbol_number] ||
         last_date.hour>=StopOpenOrders[symbol_number])
         return(false);
     }
//--- В разрешенном временном диапазоне
   return(true);
  }
//+------------------------------------------------------------------+
