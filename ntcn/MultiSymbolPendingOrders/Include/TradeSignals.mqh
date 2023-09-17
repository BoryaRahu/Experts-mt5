//--- Связь с основным файлом эксперта
#include "..\MultiSymbolPendingOrders.mq5"
//--- Подключаем свои библиотеки
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "Errors.mqh"
#include "TradeFunctions.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//+------------------------------------------------------------------+
//| Получает хэндлы агентов по указанным символам                    |
//+------------------------------------------------------------------+
void GetSpyHandles()
  {
//--- Пройдёмся по всем символам
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- Если торговля по символу разрешена
      if(Symbols[s]!="")
        {
         //--- Если хэндл ещё не получен...
         if(spy_indicator_handles[s]==INVALID_HANDLE)
           {
            spy_indicator_handles[s]=iCustom(Symbols[s],_Period,"EventsSpy.ex5",ChartID(),0,CHARTEVENT_TICK);
            //---
            if(spy_indicator_handles[s]==INVALID_HANDLE)
               Print("Не удалось установить агента на "+Symbols[s]+"");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Получает значения баров                                          |
//+------------------------------------------------------------------+
void GetBarsData(int symbol_number)
  {
//--- Количество баров для копирования в массивы ценовых данных
   int NumberOfBars=3;
//--- Установим обратный порядок индексации (... 3 2 1 0)
   ArraySetAsSeries(open[symbol_number].value,true);
   ArraySetAsSeries(high[symbol_number].value,true);
   ArraySetAsSeries(low[symbol_number].value,true);
   ArraySetAsSeries(close[symbol_number].value,true);
//--- Если полученных значений меньше, чем запрошено
//    вывести сообщение об этом
//--- Получим цену закрытия бара
   if(CopyClose(Symbols[symbol_number],_Period,0,NumberOfBars,close[symbol_number].value)<NumberOfBars)
     {
      Print("Не удалось скопировать значения ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") в массив цен Close! "
            "Ошибка ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
//--- Получим цену открытия бара
   if(CopyOpen(Symbols[symbol_number],_Period,0,NumberOfBars,open[symbol_number].value)<NumberOfBars)
     {
      Print("Не удалось скопировать значения ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") в массив цен Open! "
            "Ошибка ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
//--- Получим цену максимума бара
   if(CopyHigh(Symbols[symbol_number],_Period,0,NumberOfBars,high[symbol_number].value)<NumberOfBars)
     {
      Print("Не удалось скопировать значения ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") в массив цен High! "
            "Ошибка ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
//--- Получим цену минимума бара
   if(CopyLow(Symbols[symbol_number],_Period,0,NumberOfBars,low[symbol_number].value)<NumberOfBars)
     {
      Print("Не удалось скопировать значения ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") в массив цен Low! "
            "Ошибка ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
  }
//+------------------------------------------------------------------+
//| Определяет торговые сигналы                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetTradingSignal(int symbol_number)
  {
//--- Если позиции нет
   if(!pos.exists)
     {
     }
//--- Если позиция есть
   if(pos.exists)
     {
     }
//--- Отсутствие сигнала
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Проверяет условие и возвращает сигнал                            |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetSignal(int symbol_number)
  {
//--- Отсутствие сигнала
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
