//--- ����� � �������� ������ ��������
#include "..\MultiSymbolPendingOrders.mq5"
//--- ���������� ���� ����������
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "Errors.mqh"
#include "TradeFunctions.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//+------------------------------------------------------------------+
//| �������� ������ ������� �� ��������� ��������                    |
//+------------------------------------------------------------------+
void GetSpyHandles()
  {
//--- �������� �� ���� ��������
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- ���� �������� �� ������� ���������
      if(Symbols[s]!="")
        {
         //--- ���� ����� ��� �� �������...
         if(spy_indicator_handles[s]==INVALID_HANDLE)
           {
            spy_indicator_handles[s]=iCustom(Symbols[s],_Period,"EventsSpy.ex5",ChartID(),0,CHARTEVENT_TICK);
            //---
            if(spy_indicator_handles[s]==INVALID_HANDLE)
               Print("�� ������� ���������� ������ �� "+Symbols[s]+"");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| �������� �������� �����                                          |
//+------------------------------------------------------------------+
void GetBarsData(int symbol_number)
  {
//--- ���������� ����� ��� ����������� � ������� ������� ������
   int NumberOfBars=3;
//--- ��������� �������� ������� ���������� (... 3 2 1 0)
   ArraySetAsSeries(open[symbol_number].value,true);
   ArraySetAsSeries(high[symbol_number].value,true);
   ArraySetAsSeries(low[symbol_number].value,true);
   ArraySetAsSeries(close[symbol_number].value,true);
//--- ���� ���������� �������� ������, ��� ���������
//    ������� ��������� �� ����
//--- ������� ���� �������� ����
   if(CopyClose(Symbols[symbol_number],_Period,0,NumberOfBars,close[symbol_number].value)<NumberOfBars)
     {
      Print("�� ������� ����������� �������� ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") � ������ ��� Close! "
            "������ ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
//--- ������� ���� �������� ����
   if(CopyOpen(Symbols[symbol_number],_Period,0,NumberOfBars,open[symbol_number].value)<NumberOfBars)
     {
      Print("�� ������� ����������� �������� ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") � ������ ��� Open! "
            "������ ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
//--- ������� ���� ��������� ����
   if(CopyHigh(Symbols[symbol_number],_Period,0,NumberOfBars,high[symbol_number].value)<NumberOfBars)
     {
      Print("�� ������� ����������� �������� ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") � ������ ��� High! "
            "������ ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
//--- ������� ���� �������� ����
   if(CopyLow(Symbols[symbol_number],_Period,0,NumberOfBars,low[symbol_number].value)<NumberOfBars)
     {
      Print("�� ������� ����������� �������� ("
            +Symbols[symbol_number]+"; "+TimeframeToString(_Period)+") � ������ ��� Low! "
            "������ ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError())+"");
     }
  }
//+------------------------------------------------------------------+
//| ���������� �������� �������                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetTradingSignal(int symbol_number)
  {
//--- ���� ������� ���
   if(!pos.exists)
     {
     }
//--- ���� ������� ����
   if(pos.exists)
     {
     }
//--- ���������� �������
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| ��������� ������� � ���������� ������                            |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetSignal(int symbol_number)
  {
//--- ���������� �������
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
