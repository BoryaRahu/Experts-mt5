//--- ����� � �������� ������ ��������
#include "..\MultiSymbolPendingOrders.mq5"
//--- ���������� ���� ����������
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "Errors.mqh"
#include "TradeSignals.mqh"
#include "TradeFunctions.mqh"
#include "Auxiliary.mqh"
//+------------------------------------------------------------------+
//| ����������� ������������ ������� � ������                        |
//+------------------------------------------------------------------+
string CurrentPositionDurationToString(ulong time)
  {
//--- ������� � ������ ���������� �������
   string result="-";
//--- ���� ���� �������
   if(pos.exists)
     {
      //--- ���������� ��� ���������� ��������
      ulong days=0;
      ulong hours=0;
      ulong minutes=0;
      ulong seconds=0;
      //--- 
      seconds=time%60;
      time/=60;
      //---
      minutes=time%60;
      time/=60;
      //---
      hours=time%24;
      time/=24;
      //---
      days=time;
      //--- ���������� ������ � ��������� ������� DD:HH:MM:SS
      result=StringFormat("%02u d: %02u h : %02u m : %02u s",days,hours,minutes,seconds);
     }
//--- ������ ���������
   return(result);
  }
//+------------------------------------------------------------------+
//| ����������� ��� ������� � ������                                 |
//+------------------------------------------------------------------+
string PositionTypeToString(ENUM_POSITION_TYPE type)
  {
   string str="";
//---
   if(type==POSITION_TYPE_BUY)
      str="buy";
   else if(type==POSITION_TYPE_SELL)
      str="sell";
   else
      str="wrong value";
//---
   return(str);
  }
//+------------------------------------------------------------------+
//| ����������� ��������� � ������                                   |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
  {
   string str="";
//--- ���� ���������� �������� �����������, ����� ��������� �������� �������
   if(timeframe==WRONG_VALUE|| timeframe== NULL)
      timeframe= Period();
   switch(timeframe)
     {
      case PERIOD_M1  : str="M1";  break;
      case PERIOD_M2  : str="M2";  break;
      case PERIOD_M3  : str="M3";  break;
      case PERIOD_M4  : str="M4";  break;
      case PERIOD_M5  : str="M5";  break;
      case PERIOD_M6  : str="M6";  break;
      case PERIOD_M10 : str="M10"; break;
      case PERIOD_M12 : str="M12"; break;
      case PERIOD_M15 : str="M15"; break;
      case PERIOD_M20 : str="M20"; break;
      case PERIOD_M30 : str="M30"; break;
      case PERIOD_H1  : str="H1";  break;
      case PERIOD_H2  : str="H2";  break;
      case PERIOD_H3  : str="H3";  break;
      case PERIOD_H4  : str="H4";  break;
      case PERIOD_H6  : str="H6";  break;
      case PERIOD_H8  : str="H8";  break;
      case PERIOD_H12 : str="H12"; break;
      case PERIOD_D1  : str="D1";  break;
      case PERIOD_W1  : str="W1";  break;
      case PERIOD_MN1 : str="MN1"; break;
     }
//---
   return(str);
  }
//+------------------------------------------------------------------+