// ������ �� � �������� � ����������� �������� ����������

// #include <MT4Orders.mqh> // https://www.mql5.com/ru/code/16006
#include <fxsaber\Virtual\Virtual.mqh> // ����������� �������� ���������

input double Lots = 1;
input int Interval = 100;  // ����� ����� �������
input bool Example = true; // ����� ������ ���� �������

// ������������ ��
void System()
{
  if (!OrderSelect(OrdersTotal() - 1, SELECT_BY_POS))
    OrderSend(_Symbol, OP_BUY, Lots, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 100, 0, 0); // ���� ��� ������� - ���������
  else if (TimeCurrent() - OrderOpenTime() > Interval) // ���� ������� ������� ������ ��������� �������
  {
    // ����������� �������
    OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 100);
    OrderSend(_Symbol, 1 - OrderType(), Lots, OrderClosePrice(), 100, 0, 0);
  }
}

void OnTick()
{
  static const int handle = VIRTUAL::Create(); // ������� ����� ������������ ��������� ���������. 0 - �������� �������� ���������

  if (Example)
  {
    if (VIRTUAL::SelectByHandle()) // ������� �������� �������� ���������
      System();                    // ��������� �� �� ��������� �������� ��������� (��������)

    if (VIRTUAL::SelectByHandle(handle)) // ������� ����������� �������� ���������
    {
      VIRTUAL::NewTick();      // �������� ��� � ����������� �������� ���������
      System();                // ��������� �� �� ��������� �������� ��������� (�����������)
    }
  }
  else // �������������� ������ ��� �� ��������.
    // ����������� �� ���� ��������� �������� ����������
    for (int i = 0; i <= VIRTUAL::Total(); i++)
      if (VIRTUAL::SelectByIndex(i)) // ������� ��������������� �������� ���������
      {
        VIRTUAL::NewTick(); // �������� ��� � ��������� �������� ���������

        System(); // ��������� �� �� ��������� �������� ���������
      }

  Comment(VIRTUAL::ToString()); // ������ �� ���� ��������� ������������ ��������� ���������
}