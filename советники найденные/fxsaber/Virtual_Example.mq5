// Запуск ТС в реальном и виртуальном торговых окружениях

// #include <MT4Orders.mqh> // https://www.mql5.com/ru/code/16006
#include <fxsaber\Virtual\Virtual.mqh> // Виртуальное торговое окружение

input double Lots = 1;
input int Interval = 100;  // Время жизни позиции
input bool Example = true; // Какой пример кода выбрать

// Переворотная ТС
void System()
{
  if (!OrderSelect(OrdersTotal() - 1, SELECT_BY_POS))
    OrderSend(_Symbol, OP_BUY, Lots, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 100, 0, 0); // Если нет позиции - открываем
  else if (TimeCurrent() - OrderOpenTime() > Interval) // Если позиция прожила больше заданного времени
  {
    // Перевернули позицию
    OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 100);
    OrderSend(_Symbol, 1 - OrderType(), Lots, OrderClosePrice(), 100, 0, 0);
  }
}

void OnTick()
{
  static const int handle = VIRTUAL::Create(); // Создали хэндл виртуального торгового окружения. 0 - реальное торговое окружение

  if (Example)
  {
    if (VIRTUAL::SelectByHandle()) // Выбрали реальное торговое окружение
      System();                    // Запустили ТС на выбранном торговом окружении (реальное)

    if (VIRTUAL::SelectByHandle(handle)) // Выбрали виртуальное торговое окружение
    {
      VIRTUAL::NewTick();      // Добавили тик в виртуальное торговое окружение
      System();                // Запустили ТС на выбранном торговом окружении (виртуальное)
    }
  }
  else // Альтернативная запись тех же действий.
    // Пробегаемся по всем имеющимся торговым окружениям
    for (int i = 0; i <= VIRTUAL::Total(); i++)
      if (VIRTUAL::SelectByIndex(i)) // Выбрали соответствующее торговое окружение
      {
        VIRTUAL::NewTick(); // Добавили тик в выбранное торговое окружение

        System(); // Запустили ТС на выбранном торговом окружении
      }

  Comment(VIRTUAL::ToString()); // Вывели на чарт состояние виртуального торгового окружения
}