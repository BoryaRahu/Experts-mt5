// https://www.mql5.com/ru/articles/7038

#include <MT4Orders.mqh> // https://www.mql5.com/ru/code/16006

#include <fxsaber\Virtual\Virtual.mqh> // https://www.mql5.com/ru/code/22577

#define BESTINTERVAL_ONTESTER // Критерий оптимизации - прибыль лучшего интервала.
#define BESTINTERVAL_SLIPPAGE // Создание искусственного фильтра для вычисления BestInterval.
#include <fxsaber\BestInterval\BestInterval.mqh> // https://www.mql5.com/ru/code/22710

#define Ask SymbolInfoDouble(_Symbol, SYMBOL_ASK)

input int inPeriod = 25; // Период МАшки
input int inLow = -2;    // Нижняя граница разницы цены и МАшки - вход
input int inHigh = 0;    // Верхяя граница разницы цены и МАшки - выход

const int hnd = iMA(NULL, 0, inPeriod, 0, MODE_SMA, PRICE_CLOSE); // https://www.mql5.com/ru/forum/170952/page152#comment_14131263

const double dLow = inLow * _Point;
const double dHigh = inHigh * _Point;

double maArr[], prArr[];

void OnTick()
{
  static bool Position = false;

  CopyBuffer(hnd, 0, 0, 1, maArr);
  CopyClose(NULL, 0, 0, 1, prArr);
  
  const double pr = prArr[0] - maArr[0];

  Position = Position ? !((pr >= dHigh) && OrderSelect(0, SELECT_BY_POS) && OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0))
                      : (pr < dLow) && (OrderSend(_Symbol, OP_BUY, 1, Ask, 0, 0, 0) > 0);
}